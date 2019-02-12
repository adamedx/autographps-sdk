# Copyright 2019, Adam Edwards
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

ScriptClass DeviceCodeAuthenticator {
    static {
        $initialized = $false

        function Authenticate($authContext, $scopes) {
            if ( ! $this.initialized ) {
                . $psscriptroot/CompiledDeviceCodeAuthenticator.ps1
                $this.initialized = $true
            }

            # Due to the way the auth library uses async calls to notify when
            # device code auth is done and the difficulty of using real OS
            # threads in PowerShell, we'll work around this by having the
            # compiled authenticator write its user prompts to a memory stream
            # and notify us when there is a prompt to display -- configure
            # this infrastructure before attempting to get the token:
            $messageStream = [System.IO.MemoryStream]::new()
            $reader = [System.IO.StreamReader]::new($messageStream, [System.Text.Encoding]::Unicode)
            $messageReadyEvent = [System.Threading.ManualResetEvent]::new($false)

            try {
                $asyncResult = [CompiledDeviceCodeAuthenticator]::GetTokenWithCode($authContext, $scopes, $messageStream, $messageReadyEvent)

                # Need to sleep periodically otherwise console signals like SIG-INT / CTRL-C
                # won't work and you'll be hung if you want to cancel -- you'll have to terminate
                # the process :(.
                while ( ! $asyncResult.IsCompleted ) {
                    # See if there is a message from the compiled authenticator -- if so,
                    # display it in this console
                    if ( $messageReadyEvent -and $messageReadyEvent.WaitOne(0) ) {
                        # Get the message -- it contains the URI for devicde code auth and the device code
                        $messageStream.position = 0
                        $message = $reader.ReadToEnd()

                        # Display the message
                        write-host -fore cyan -nonewline $message

                        # Release state that is no longer needed now that we've shown the message
                        $messageReadyEvent.Close()
                        $messageReadyEvent = $null
                    }
                    start-sleep -milliseconds 500
                }

                $asyncResult
            } finally {
                if ( $messageReadyEvent ) {
                    $messageReadyEvent.Close()
                }
            }
        }
    }
}
