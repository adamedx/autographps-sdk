# Copyright 2020, Adam Edwards
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

. (import-script RESTResponse)
. (import-script ../common/PreferenceHelper)
. (import-script HttpUtilities)

ScriptClass RESTRequest {
    static {
        const PoshGraphUserAgent (. {
                                      $osversion = [System.Environment]::OSVersion.version.tostring()
                                      $platform = 'Windows NT'
                                      $os = 'Windows NT'
                                      if ( $PSVersionTable.PSEdition -eq 'Core' ) {
                                          if ( ! $PSVersionTable.OS.contains('Windows') ) {
                                              $platform = $PSVersionTable.Platform
                                              if ( $PSVersionTable.OS.contains('Linux') ) {
                                                  $os = 'Linux'
                                              } else {
                                                  $os = [System.Environment]::OSVersion.Platform
                                              }
                                          }
                                      }
                                      $language = [System.Globalization.CultureInfo]::CurrentCulture.name
                                      'PoshGraph/0.9 PowerShell/{4} ({0}; {1} {2}; {3})' -f $platform, $os, $osversion, $language, $PSVersionTable.PSversion
                                  })
    }

    $uri = strict-val [Uri]
    $headers = strict-val [HashTable]
    $method = strict-val [String]
    $body = $null
    $userAgent = $null
    $returnRequest = $false

    function __initialize([Uri] $uri, $method = "GET", [HashTable] $headers = @{}, $body = $null, $userAgent = $null, [bool] $returnRequest) {
        $this.returnRequest = $returnRequest
        $this.headers = $headers
        $this.method = $method
        $this.uri = $uri
        $this.body = if ( $body -eq $null ) {
            $null
        } elseif ( $body -is [String] ) {
            $body | convertfrom-json | out-null
            $body
        } else {
            $body | convertto-json -depth 6
        }

        $this.userAgent = if ( $userAgent ) {
            $userAgent
        } else {
            $this.scriptclass.PoshGraphUserAgent
        }
    }

    function Invoke {
        [cmdletbinding(SupportsShouldProcess=$true)]
        param($PSCmdletArgument, $logEntry)
        if ( ! $this.returnRequest -and ( ! $PSCmdletArgument -or $PSCmdletArgument.shouldprocess($this.uri, $this.method) ) ) {
            # Disable progress display
            $progresspreference = 'SilentlyContinue'

            $optionalArguments = if ( $this.body -ne $null -and $this.body.length -gt 0 ) {
                @{body=$this.body}
            } else {
                @{}
            }

            if ( $this.headers -ne $null ) {
                write-verbose "Request Headers:"
                $this.headers.keys | foreach {
                    $outputValue = if ( $_ -ne 'Authorization' ) {
                        $this.headers[$_]
                    } else {
                        '<authtoken>'
                    }
                }
                _write-headersverbose $this.headers (@{Authorization='<redacted authtoken>'})
            }

            write-verbose "Request Body: `n`n$($this.body)`n`n"

            $httpResponse = try {
                if ( $logEntry ) { $logEntry |=> LogRequestStart }
                Invoke-WebRequest -Uri $this.uri -headers $this.headers -method $this.method -useragent $this.userAgent -usebasicparsing @optionalArguments
            } catch {
                # Here we handle http errors returned by the endpoint differently than other errors (say failure to reach the endpoint),
                # so we try to identify http protocol errors via the exception type. Also, there are a variety of exceptions that can be
                # encountered depending on the underlying .NET http client implementation, and again we rely on the exception type
                # to make the correct interpretation.
                # TODO: Abstract this to a class that has knowledge of the specifics of the http clients
                $exceptionType = $_.exception.gettype()
                if ( $exceptionType -ne [System.Net.WebException] -and $exceptionType.fullName -ne 'Microsoft.PowerShell.Commands.HttpResponseException' -and ! $exceptionType.fullname.startswith('System.Net.Http') -and ( $exceptionType.fullname -notlike 'AutoGraph*HttpResponseException') ) {
                    write-verbose "Encountered unexpected exception of type '$($exceptionType.FullName)'"
                    throw
                }

                $response = $_.exception.response

                # TODO: Understand why the line below breaks in unit tests only when
                # $::.RESTResponse |=> is used instead of 'RESTResponse' |::>. In that situation
                # the '$::' variable was null! This would then result in an exception when
                # attempting to access the 'RESTResponse' property. Most likely the behavior is
                # an artifact of ScriptClass or a side-effect of loading and unloading modules,
                # during testing, or perhaps some other module-scoping issue.
                $responseStreamOutput = ( 'RESTResponse' |::> GetErrorResponseDetails $response)

                $responseOutput = if ( $responseStreamOutput -ne $null -and $responseStreamOutput.length -gt 0 ) {
                    $responseStreamOutput
                } else {
                    # Sometimes the response stream has already been read and the value
                    # can be obtained from the error record's ToString()
                    $_.ToString()
                }

                if ( $logEntry ) { $logEntry |=> LogError $response $responseOutput }

                _write-responseverbose $response $responseOutput
                write-error -message $responseStreamOutput -targetobject ([PSCustomObject] @{CustomTypeName='RESTException';PSErrorRecord=$_;ResponseStream=$responseStreamOutput}) -erroraction silentlycontinue
                throw
            }

            _write-responseverbose $httpResponse $httpResponse.rawContent

            $restResponse = new-so RESTResponse $httpResponse
            if ( $logEntry ) { $logEntry |=> LogSuccess $restResponse }
            $restResponse
        } else {
            if ( $this.returnRequest ) {
                $headers = $this.headers.clone()
                if ( $headers['Authorization'] ) {
                    $headers['Authorization'] = '<authtoken>'
                }

                if ( $headers['client-request-id'] ) {
                    $headers.remove('client-request-id')
                }

                $content = [ordered] @{}
                $content['Method'] = $this.method
                $content['Uri'] = $this.uri
                $content['Body'] = $this.body
                $content['Headers'] = $headers

                new-so RESTResponse ([PSCustomObject] $content) $null $true
            } else {
                [PSCustomObject] @{PSTypeName='RESTResponse'}
            }
        }
    }

    function _write-headersverbose( $headers, $substitutions = @{} ) {
        if ( $headers -ne $null ) {

            $headerOutput = @{}
            $headers.keys | foreach {
                $headerOutput[$_] = if ( ! $substitutions.containskey($_) ) {
                    $headers[$_]
                } else {
                    $substitutions[$_]
                }
            }

            ([PSCustomObject] $headerOutput) | fl | out-string | write-verbose
        }
    }

    function _write-responseverbose( $response, $content ) {
        write-verbose ' '
        write-verbose 'Response:'
        write-verbose '********'
        if ( $response -ne $null ) {
            $response | out-string | write-verbose
        } else {
            write-verbose 'No response.'
        }

        write-verbose ' '
        write-verbose 'Response Detail:'
        write-verbose "***************"

        $bodyTruncated = $false
        $bodyLength = 0
        $truncationSize = 1024
        $contentString = if ( $VerbosePreference -ne 'SilentlyContinue' ) {
            $fullOutput = ($content | out-string)
            $bodyLength = $fullOutput.length
            if ( ($GraphVerboseOutputPreference -ne 'High') -and ($fullOutput.length -gt $truncationSize) ) {
                $bodyTruncated = $true
                $fullOutput.SubString(0, 512)
            } else {
                $fullOutput
            }
        }

        $bodyLines = @("`n`n")
        $bodyLines += $contentString
        $bodyLines += @("`n`n")
        (-join $bodyLines) | write-verbose

        if ( $bodyTruncated ) {
            write-verbose "***Above response of length $bodyLength characters truncated to $truncationSize characters***"
            write-verbose "***To disable truncation and see full response,***"
            write-verbose "**set `$GraphVerboseOutputPreference to the value 'High'**"
        }

        write-verbose ' '
        write-verbose "Response Headers:"
        write-verbose "****************`n"

        $responseHeaders = if ( $response | gm headers -erroraction ignore ) {
            'HttpUtilities' |::> NormalizeHeaders $response.headers
        }

        if ( $response -ne $null ) {
            _write-headersverbose $responseHeaders
        }
    }
}
