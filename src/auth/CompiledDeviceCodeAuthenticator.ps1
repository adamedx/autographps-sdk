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

# Use C# here due to threading complications when using AcquireTokenWithDeviceCodeAsync.
#
try {
    add-type -referencedassemblies $authLibraryPath, System.Console, System.Threading.Tasks, System.Threading, System.Runtime.Extensions -ignorewarnings @'
    using System;
    using System.IO;
    using System.Threading;
    using System.Threading.Tasks;
    using Microsoft.Identity.Client;

    public class CompiledDeviceCodeAuthenticator
    {
        public static ManualResetEvent messageReadyEvent;
        public static MemoryStream messageStream;

        public static Task ShowMessage(DeviceCodeResult deviceCodeResult)
        {
            // Note that here instead of performing a Console.WriteLine for the message,
            // we actually write it to a memory stream. This handles a particular situation with
            // PowerShell remote sessions where Console.WriteLine is actually not
            // writing to the PowerShell host, it's simply "lost" to a .NET console that is not
            // associated to the PowerShell host that displays text to the user. To work around this,
            // we send the message to a stream supplied by the caller of GetTokenWithCode -- the caller
            // is expected to read the message from that stream once we signal the event also
            // supplied by this caller in the method below. That caller which is presumably running with
            // the ability to invoke 'write-host' to the PowerShell host can then display the message
            // to the user who can then complete the actions necessary for the original call to acquire
            // the token to complete.
            StreamWriter writer = new StreamWriter(messageStream, System.Text.Encoding.Unicode);
            writer.WriteLine(deviceCodeResult.Message); // Write the user prompt message to the stream
            writer.Flush();
            messageReadyEvent.Set(); // Notify the initiator that the user prompt with device code information is ready to read
            return Task.FromResult(0);
        }

        public static Task<AuthenticationResult> GetTokenWithCode(PublicClientApplication authContext, string[] scopes, MemoryStream messageStream, ManualResetEvent messageReadyEvent)
        {
            CompiledDeviceCodeAuthenticator.messageStream = messageStream;
            CompiledDeviceCodeAuthenticator.messageReadyEvent = messageReadyEvent;
            var asyncResult = authContext.AcquireTokenWithDeviceCode(
                scopes,
                ShowMessage).ExecuteAsync();

            return asyncResult;
        }
    }
'@ 3> $null
} catch {
    write-warning "Unable to compile code for device code authentication flow -- device code signin will be disabled"
    write-warning $_.Exception
}
