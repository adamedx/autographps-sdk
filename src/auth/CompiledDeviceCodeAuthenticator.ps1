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

$dotnetPlatform = if ( $PSVersionTable.PSEdition -eq 'Core' ) {
    'netcoreapp1.0'
} else {
    'net45'
}

$authLibraryPath = [System.Reflection.Assembly]::GetAssembly(([Microsoft.Identity.Client.PublicClientApplication])).location

# Use C# here due to threading complications when using AcquireTokenWithDeviceCodeAsync
try {
    add-type -referencedassemblies $authLibraryPath, System.Console, System.Threading.Tasks -ignorewarnings @'
    using System;
    using System.Threading.Tasks;
    using Microsoft.Identity.Client;

    public class CompiledDeviceCodeAuthenticator
    {
        public static Task ShowMessage(DeviceCodeResult deviceCodeResult)
        {
            Console.WriteLine(deviceCodeResult.Message);
            return Task.FromResult(0);
        }

        public static Task<AuthenticationResult> GetTokenWithCode(PublicClientApplication authContext, string[] scopes)
        {
            var asyncResult = authContext.AcquireTokenWithDeviceCodeAsync(
                scopes,
                ShowMessage);

            return asyncResult;
        }
    }
'@ 3> $null
} catch {
    write-warning "Unable to compile code for device code authentication flow -- device code signin will be disabled"
    write-warning $_.Exception
}
