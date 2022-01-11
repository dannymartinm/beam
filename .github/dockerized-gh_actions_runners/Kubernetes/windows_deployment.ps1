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


# Using this file you can apply and delete k8s deployment using image, repo and toke from
# var.env file (which should be located on this script folder)
#Usage example: 
# ./windows_deployment.ps1 apply 
# ./windows_deployment.ps1 delete

$output_file="github-actions-windows-deployment-populated.yml"


#Environment functions
function Set-PsEnv {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
    param($localEnvFile = "var.env")


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
            $line = $line.Replace("`"", "")
            $kvp = $line -split "=", 2
            if ($PSCmdlet.ShouldProcess("$($kvp[0])", "set value $($kvp[1])")) {
                [Environment]::SetEnvironmentVariable($kvp[0].Trim(), $kvp[1].Trim(), "Process") | Out-Null
            }
        }
    }
}

Set-PsEnv

#Reading base 64 encoded vars
$IMAGE = [System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String($env:IMAGE))
$GITHUB_TOKEN = [System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String($env:GITHUB_TOKEN))
$GITHUB_REPO = [System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String($env:GITHUB_REPO)) 


#Replacing in file

(Get-Content -Path "github-actions-windows-deployment.yml") | ForEach-Object {
    $_.replace('_IMAGE', $IMAGE ).replace('_GITHUB_REPO', $GITHUB_REPO).replace('_GITHUB_TOKEN', $GITHUB_TOKEN)
} | Set-Content $output_file 


if($args[0] -eq "apply")
{
    kubectl apply -f $output_file
}
elseif($args[0] -eq "delete"){
    kubectl delete -f $output_file
}


Remove-Item $output_file