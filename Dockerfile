FROM microsoft/windowsservercore
LABEL Inspired by alexellisio/msbuild and nugardt/msbuild

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

WORKDIR "C:\temp"

# Note: Install Full MSBuild 14
RUN Invoke-WebRequest "https://download.microsoft.com/download/E/E/D/EEDF18A8-4AED-4CE0-BEBE-70A83094FC5A/BuildTools_Full.exe" -OutFile BuildTools_Full.exe -UseBasicParsing; \
        ./BuildTools_Full.exe /Silent /Full /NoRestart | Out-Null; \
        Start-Sleep 2; \
        Remove-Item -Force BuildTools_Full.exe"

RUN $env:PATH = 'C:\Program Files (x86)\MSBuild\14.0\bin;' + $env:PATH; \
[Environment]::SetEnvironmentVariable('PATH', $env:PATH, [EnvironmentVariableTarget]::Machine);

# Note: Install 4.5.2 Dev Pack
RUN Invoke-WebRequest "https://download.microsoft.com/download/4/3/B/43B61315-B2CE-4F5B-9E32-34CCA07B2F0E/NDP452-KB2901951-x86-x64-DevPack.exe" -OutFile "NDP452-KB2901951-x86-x64-DevPack.exe -UseBasicParsing
RUN & cmd /c start /WAIT "NDP452-KB2901951-x86-x64-DevPack.exe /install /quiet"

# Note: Add NuGet v4.1.0
RUN Invoke-WebRequest "https://dist.nuget.org/win-x86-commandline/v4.1.0/nuget.exe" -OutFile "C:\windows\nuget.exe" -UseBasicParsing

# Note: Install Web Targets
RUN "C:\windows\nuget.exe" Install MSBuild.Microsoft.VisualStudio.Web.targets -Version 14.0.0.3;
WORKDIR "C:\Program Files (x86)\MSBuild\Microsoft\VisualStudio\v14.0"
RUN Copy-Item -Recurse -Path "C:\temp\MSBuild.Microsoft.VisualStudio.Web.targets.14.0.0.3\tools\VSToolsPath\*" -Destination .

RUN rm -r "C:\temp"

WORKDIR "C:\app"

CMD ["powershell", "build/build.ps1"]
