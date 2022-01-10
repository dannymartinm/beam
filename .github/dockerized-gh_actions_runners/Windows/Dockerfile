FROM mcr.microsoft.com/windows/servercore:ltsc2019

ARG RUNNER_VERSION=2.285.1


#Installing chocolatey package manager
RUN powershell Set-ExecutionPolicy Bypass -Scope Process -Force;\
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;\
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

WORKDIR /actions

#Installing choco dependencies
RUN powershell choco upgrade chocolatey --confirm;\
    choco install git --confirm

RUN powershell choco install python --version=3.7.9 --confirm

#Downloading actions runner file
RUN powershell Invoke-WebRequest -Uri https://github.com/actions/runner/releases/download/v2.285.1/actions-runner-win-x64-2.285.1.zip -OutFile actions-runner-win-x64-2.285.1.zip;\
    Expand-Archive -LiteralPath $PWD\actions-runner-win-x64-2.285.1.zip -DestinationPath $PWD

COPY entrypoint.ps1 ./entrypoint.ps1
COPY .env ./.env

ENTRYPOINT [ "powershell" ]
CMD [ "./entrypoint.ps1" ]



