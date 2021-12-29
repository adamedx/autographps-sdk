# Copyright 2021, Adam Edwards
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

. (import-script ../graphservice/GraphEndpoint)
. (import-script GraphApplication)
. (import-script ../auth/AuthProvider)
. (import-script ../auth/V2AuthProvider)

ScriptClass GraphIdentity {
    $App = strict-val [PSCustomObject]
    $Token = strict-val [PSCustomObject] $null
    $GraphEndpoint = strict-val [PSCustomObject] $null
    $TenantName = $null
    $TenantDisplayId = $null
    $TenantDisplayName = $null
    $AllowMSA = $false

    function __initialize([PSCustomObject] $app, [PSCustomObject] $graphEndpoint, [String] $tenantName, [boolean] $allowMSA) {
        $this.App = $app
        $this.GraphEndpoint = $graphEndpoint
        $this.TenantName = $tenantName
        $this.AllowMSA = $allowMSA

        $defaultAppId = $::.Application.DefaultAppId.tostring()

        $chinaEndpointUri = ( $::.GraphEndpoint |=> GetCloudEndpoint ChinaCloud ).Graph.tostring().trimend('/')

        if ( ( $graphEndpoint.Graph.tostring().trimend('/') -eq $chinaEndpointUri ) -and
             ( $app.AppId.tostring() -eq $defaultAppId ) ) {
             write-warning "Initializing connection to China cloud using the default application identifier '$defaultAppId', but this public cloud app may not be available in the China cloud, so authentication may fail. Consider creating a new public client application in a China cloud tenant and specify that application's application identifier (also known as client id) with Connect-GraphApi or related commands via their AppId parameter if you experience authentication failures and retry the failing command."
        }

        $this |=> __UpdateTenantDisplayInfo
    }

    function GetUserInformation {
        if ( $this.App.AuthType -eq 'Delegated' ) {
                 $providerInstance = $::.AuthProvider |=> GetProviderInstance
                 $providerInstance |=> GetUserInformation $this.token
        } else {
            [PSCustomObject]@{
                AppId = $this.App.AppId
                userId = $null
                scopes = $null
                userObjectId = $null
            }
        }
    }

    function Authenticate($scopes = $null, $noBrowserUI = $false, $groupId = $null, [securestring] $certificatePassword) {
        if ( $this.token ) {
            $tokenTimeLeft = $this.token.expireson - [DateTime]::UtcNow
            write-verbose ("Found existing token with {0} minutes left before expiration" -f $tokenTimeLeft.TotalMinutes)
        }

        write-verbose ("Getting token for resource {0} from auth endpoint: {1} for groupid '{2}'" -f $this.graphEndpoint.GraphResourceUri, $this.graphEndpoint.Authentication, $groupId)

        $this.Token = getGraphToken $this.graphEndpoint $scopes $noBrowserUI $groupId $certificatePassword

        if ($this.token -eq $null) {
            throw "Failed to acquire token, no additional error information"
        }

        $this |=> __UpdateTenantDisplayInfo
    }

    function ClearAuthentication($groupId) {
        if ( $this.token -and $this.app.AuthType -eq 'Delegated' ) {
            $authUri = $this.graphEndpoint |=> GetAuthUri $this.TenantName $this.AllowMSA

            $providerInstance = $::.AuthProvider |=> GetProviderInstance
            $authContext = $providerInstance |=> GetAuthContext $this.app $this.graphEndpoint.GraphResourceUri $authUri $groupId
            $providerInstance |=> ClearToken $authContext $this.token
        }

        $this.token = $null
    }

    function getGraphToken($graphEndpoint, $scopes, $noBrowserUI, $groupId, [securestring] $certificatePassword) {
        write-verbose "Attempting to get token in tenant '$($this.tenantName)' for '$($graphEndpoint.GraphResourceUri)' ..."
        write-verbose "Using app id '$($this.App.AppId)'"
        $isConfidential = ($this.app |=> IsConfidential)
        write-verbose ("Is confidential client: '{0}'" -f $isConfidential)

        write-verbose ("Adding scopes to request: {0}" -f ($scopes -join ';'))

        $authUri = $graphEndpoint |=> GetAuthUri $this.TenantName $this.AllowMSA
        write-verbose ("Sending auth request to auth uri '{0}'" -f $authUri)
        write-verbose ("Using redirect uri (reply url) '{0}'" -f $this.App.RedirectUri)

        $providerInstance = $::.AuthProvider |=> GetProviderInstance

        $authContext = $providerInstance |=> GetAuthContext $this.app $graphEndpoint.GraphResourceUri $authUri $groupId $certificatePassword

        $authResult = if ( $this.token ) {
            $providerInstance |=> AcquireRefreshedToken $authContext $this.token
        } else {
            if ( $this.App.AuthType -eq 'Apponly' ) {
                $providerInstance |=> AcquireFirstAppToken $authContext
            } else {
                # The latest version of posh-git seems to corrupt the state of the thread if it is imported into the PS session.
                # This causes auth to fail with a ThreadStateException from MSAL with a message  indicating that an MTA operation
                # is being attempted in an STA thread, and that is illegal. This occurs when MSAL is trying to show the auth web dialog
                # and may impact device code auth as well.

                # The good news though is that apparently with a retry MSAL will be just fine -- we can just try again on this
                # same thread as a workaround until posh-git (or MSAL?) fixes the issue. We do this only when we encounter this specific
                # error.

                # It's not clear what additional instability is caused by posh-git here, so regardless of whether the workaround here
                # unblocks this module's functionality, it may be wise to remove posh-git whenever strange behavior arises with any module
                # to see if that fixes things. In general limiting posh-git to use cases where you really need it (e.g working
                # with a source control system) is advisable to avoid non-determinism and hard to troubleshoot errors.

                # Note that this workaround is only needed in the interactive case -- if no UX thread (e.g. a web dialog) is shown,
                # there is no MTA / STA issue.

                $remainingAttempts = 2
                $interactiveTokenResult = $null

                do {
                    $interactiveTokenResult = if ( $isConfidential ) {
                        $providerInstance |=> AcquireFirstUserTokenConfidential $authContext $scopes
                    } else {
                        $providerInstance |=> AcquireFirstUserToken $authContext $scopes $noBrowserUI
                    }

                    # This is terrible -- since we're in PowerShell and async thread operations are inconvenient, we'll
                    # just synchronously wait for the result :(. If we don't do this, we can't check the status
                    # as it can change asynchronously
                    $interactiveTokenResult.Result | out-null

                    $isThreadException = if ( $interactiveTokenResult.Status -eq 'Faulted' ) {
                        if ( $interactiveTokenResult | gm exception -erroraction ignore ) {
                            ( $interactiveTokenResult.Exception -is [Exception] ) -and ( $interactiveTokenResult.Exception.InnerException -is [System.Threading.ThreadStateException] )
                        }
                    }

                    if ( ! $isThreadException ) {
                        $remainingAttempts = 0
                    } elseif ( $remainingAttempts -gt 1 ) {
                        write-verbose "Encountered thread exception accessing MSAL, a retry will be attempted"
                    }
                } while ( --$remainingAttempts -gt 0 )

                if ( $interactiveTokenResult ) {
                    $interactiveTokenResult
                }
            }
        }

        write-verbose ("`nToken request status: {0}" -f $authResult.Status)

        if ( $authResult.Status -eq 'Faulted' ) {
            throw "Failed to acquire token for uri '$($graphEndpoint.GraphResourceUri)' for AppID '$($this.App.AppId)'`n" + $authResult.exception, $authResult.exception
        }

        $result = $authResult.Result

        if ( $authResult.IsFaulted ) {
            write-verbose $authResult.Exception
            throw [Exception]::new(("An authentication error occurred: '{0}'. See verbose output for additional details" -f $authResult.Exception.message), $authResult.Exception)
        }

        if ( ! $this.tenantDisplayId -and ( $result | gm -erroraction ignore tenantid ) ) {
            if ( $result.tenantid ) {
                $this.tenantDisplayId = $result.tenantid
            }
        }

        $result
    }

    function GetTenantId($specifiedTenantId) {
        if ( $specifiedTenantId ) {
            $specifiedTenantId
        } else {
            $this |=> __UpdateTenantDisplayInfo
            $this.tenantDisplayId
        }
    }

    function __UpdateTenantDisplayInfo {
        $tenant = if ( $this.token -and ( $this.token | gm authority -erroraction ignore ) ) {
            (([uri] $this.token.authority).segments | select -last 1).trimend('/')
        }

        if ( ! $tenant ) {
            $tenant = if ( $this.token -and ( $this.token | gm user -erroraction ignore ) ) {
                if ( $this.token.user | gm identityprovider -erroraction ignore ) {
                    (([uri] $this.token.user.identityprovider).segments | select -first 2 | select -last 1).trimend('/')
                }
            }
        }

        $tenantName = $null
        $tenantId = try {
            if ( $this.token ) {
                $this.token.tenantId
            }
        } catch {
        }

        $isGuid = $false
        $parsedTenantId = $null

        if ( $tenant ) {
            $outputGuid = (new-guid).guid
            $isGuid = [guid]::TryParse($tenant, [ref] $outputguid)
            if ( $isGuid ) {
                $parsedTenantid = $outputguid
            }
        }

        if ( ! $isGuid ) {
            $tenantName = $tenant
        }

        if ( ! $tenantName ) {
            $tenantName = $this.tenantName
        }

        if ( ! $tenantId ) {
            if ( $parsedTenantId ) {
                $tenantId = $parsedTenantId
            } else {
                # Last resort is to hope that the tenant name is actually
                # the same as the tenant id -- this is quite often the case
                $tenantGuid = (new-guid).guid
                $isTenantNameGuid = [guid]::TryParse($tenantName, [ref] $tenantGuid)
                if ( $isTenantNameGuid ) {
                    $tenantId = $tenantGuid
                }
            }
        }

        $this.tenantDisplayId = $tenantId
        $this.tenantDisplayName = $tenantName
    }
}

