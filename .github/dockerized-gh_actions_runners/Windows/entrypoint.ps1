# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#Environment functions
function Set-PsEnv {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
    param($localEnvFile = ".env")


    #return if no env file
    if (!( Test-Path $localEnvFile)) {
        Throw "could not open $localEnvFile"
    }

    #read the local env file
    $content = Get-Content $localEnvFile -ErrorAction Stop
    Write-Verbose "Parsed .env file"

    #load the content to environment
    foreach ($line in $content) {
        if ($line.StartsWith("#")) { continue };
        if ($line.Trim()) {
            $line = $line.Replace("`"","")
            $kvp = $line -split "=",2
            if ($PSCmdlet.ShouldProcess("$($kvp[0])", "set value $($kvp[1])")) {
                [Environment]::SetEnvironmentVariable($kvp[0].Trim(), $kvp[1].Trim(), "Process") | Out-Null
            }
        }
    }
}

function Remove {
    param (
        $RUNNER_TOKEN
    )
    ./config.cmd remove --unattended --token "$RUNNER_TOKEN"
}

Set-PsEnv
$registration_url="https://api.github.com/repos/$Env:GITHUB_REPO/beam/actions/runners/registration-token"
Write-Output "Requesting registration URL at '${registration_url}'"
$GITHUB_TOKEN= Write-Output $Env:GITHUB_TOKEN

Write-Output $GITHUB_TOKEN

$payload= Invoke-WebRequest  ${registration_url} -UseBasicParsing -Method 'POST' -Headers @{'Authorization'="token $GITHUB_TOKEN"} | ConvertFrom-Json

[Environment]::SetEnvironmentVariable("RUNNER_TOKEN", $payload.token)
Write-Output $env:RUNNER_TOKEN

./config.cmd --name $env:COMPUTERNAME --token $payload.token --url https://github.com/$Env:GITHUB_REPO/beam --work _work --unattended --replace --labels windows,windows-latest

./run.cmd
