param(
  [ValidateSet('Debug','Release')][string]$Configuration = 'Release',
  [ValidateSet('android-arm64','android-x86_64')][string]$RuntimeIdentifier = 'android-arm64'
)
$ErrorActionPreference = 'Stop'
$project = Join-Path $PSScriptRoot '..\src\SmartBridge.Android\SmartBridge.Android.csproj'
$sdk = if ($env:ANDROID_HOME) { $env:ANDROID_HOME } else { Join-Path $HOME 'AndroidSdk' }
$java = if ($env:JAVA_HOME) { $env:JAVA_HOME } else { 'C:\Program Files\Microsoft\jdk-17.0.20.101-hotspot' }
dotnet build $project -f net10.0-android -c $Configuration `
  -p:AndroidSdkDirectory=$sdk `
  -p:JavaSdkDirectory=$java `
  -p:AndroidPackageFormat=apk `
  -p:RuntimeIdentifier=$RuntimeIdentifier
Write-Host "APK output: src\SmartBridge.Android\bin\$Configuration\net10.0-android\$RuntimeIdentifier\"
