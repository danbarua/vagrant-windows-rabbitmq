param([System.String]$BaseDir = "c:\tools",
      [System.String]$erlang_version = "17.0",
      [System.String]$rabbitmq_version = "3.3.2"
      )

#script vars

$erlang_dir = Join-Path -Path $BaseDir -ChildPath "Erlang"
$rabbit_dir = Join-Path -Path $BaseDir -ChildPath "RabbitMQ"

$erlang_download = "http://www.erlang.org/download/otp_win64_$erlang_version.exe"
$erlang_install = (Join-Path -Path $BaseDir -ChildPath "erlang.exe")

$rabbit_download = "http://www.rabbitmq.com/releases/rabbitmq-server/v$rabbitmq_version/rabbitmq-server-windows-$rabbitmq_version.zip"
$rabbit_package = (Join-Path -Path $BaseDir -ChildPath "rabbit.zip")
$sbin_dir = "$rabbit_dir\rabbitmq_server-$rabbitmq_version\sbin"

$rabbitmq_plugins = Join-Path -Path $sbin_dir -ChildPath "rabbitmq-plugins.bat"
$rabbitmq_service = Join-Path -Path $sbin_dir -ChildPath "rabbitmq-service.bat"
$rabbitmqctl = Join-Path -Path $sbin_dir -ChildPath "rabbitmqctl.bat"

#helper functions
#lifted from chocolatey ps utils
function Update-SessionEnvironment{
  $user = 'HKCU:\Environment'
  $machine ='HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment'
  #ordering is important here, $user comes after so we can override $machine
  $machine, $user |
    Get-Item |
    % {
      $regPath = $_.PSPath
      $_ |
        Select -ExpandProperty Property |
        % {
          Set-Item "Env:$($_)" -Value (Get-ItemProperty $regPath -Name $_).$_
        }
    }

  #Path gets special treatment b/c it munges the two together
  $paths = 'Machine', 'User' |
    % {
      (Get-EnvironmentVar 'PATH' $_) -split ';'
    } |
    Select -Unique
  $Env:PATH = $paths -join ';'
}

function Get-EnvironmentVar($key, $scope) {
  [Environment]::GetEnvironmentVariable($key, $scope)
}

function Set-EnvironmentVar($key, $value, $scope){
    [Environment]::SetEnvironmentVariable($key, $value, $scope)
}

#also lifted from Chocolatey https://github.com/chocolatey/chocolatey/blob/master/src/helpers/functions/Install-ChocolateyPath.ps1
function Add-ToPath {
param(
  [string] $pathToInstall,
  [System.EnvironmentVariableTarget] $pathType = [System.EnvironmentVariableTarget]::Machine
)
  Write-Host "Running 'Add-ToPath' with pathToInstall:`'$pathToInstall`' and pathType:`'$pathType`'";

  #get the PATH variable
  $envPath = Get-EnvironmentVar 'Path' $pathType
  if (!$envPath.ToLower().Contains($pathToInstall.ToLower()))
  {
    Write-Host "PATH environment variable does not have $pathToInstall in it. Adding..."
    $actualPath = Get-EnvironmentVar 'Path' $pathType

    $statementTerminator = ";"
    #does the path end in ';'?
    $hasStatementTerminator = $actualPath -ne $null -and $actualPath.EndsWith($statementTerminator)
    # if the last digit is not ;, then we are adding it
    If (!$hasStatementTerminator -and $actualPath -ne $null) {$pathToInstall = $statementTerminator + $pathToInstall}
    if (!$pathToInstall.EndsWith($statementTerminator)) {$pathToInstall = $pathToInstall + $statementTerminator}
    $actualPath = $actualPath + $pathToInstall

    [Environment]::SetEnvironmentVariable('Path', $actualPath, $pathType)    

    #add it to the local path as well so users will be off and running
    $envPSPath = $env:PATH
    $env:Path = $envPSPath + $statementTerminator + $pathToInstall
  }
}

#install logic
if(!(Test-Path $BaseDir)){
    Write-Host "Creating Base folder... -->$BaseDir"
    New-Item $BaseDir -Force -Type Directory -ErrorAction Stop
}

if (!(Test-Path $erlang_dir))
{
    if (!(Test-Path $erlang_install)){
        Write-Host "Downloading Erlang Runtime... $erlang_download->$erlang_install"
        (New-Object System.Net.WebClient).DownloadFile($erlang_download,"$erlang_install")
    }

    Write-Host "Installing Erlang Runtime... ->$erlang_dir"
    Start-Process -FilePath $erlang_install -ArgumentList "/S /D=$erlang_dir" -NoNewWindow -Wait
    Write-Host "Erlang Runtime installed."

    #Remove-Item -Force -Path $erlang_install

    Write-Host "Setting ERLANG_HOME variable... -->$erlang_dir"
    Set-EnvironmentVar 'ERLANG_HOME' $erlang_dir "Machine"
}


if (!(Test-Path $rabbit_dir)){
    Write-Host "Installing RabbitMQ to -->$rabbit_dir"

    if (!(Test-Path $rabbit_package)){
        Write-Host "Downloading RabbitMQ package... $rabbit_download`n-->$rabbit_package"
        (New-Object System.Net.WebClient).DownloadFile($rabbit_download,$rabbit_package)
    }
   
    Write-Host "Extracting RabbitMQ package... "
    New-Item $rabbit_dir -Force -Type Directory -ErrorAction Stop
    (New-Object -COM Shell.Application).NameSpace("$rabbit_dir").CopyHere((New-Object -COM Shell.Application).NameSpace("$rabbit_package").Items(), 16);
    
    Write-Host "Setting RABBITMQ_BASE: -->$rabbit_dir"
    Set-EnvironmentVar "RABBITMQ_BASE" $rabbit_dir "Machine"

    $rabbit_config_file = Join-Path -Path $rabbit_dir -ChildPath "rabbitmq.config"
    Write-Host "Setting RABBITMQ_CONFIG_FILE: -->$rabbit_config_file"
    Set-EnvironmentVar "RABBITMQ_CONFIG_FILE" $rabbit_config_file "Machine"

    Write-Host "Adding sbin folder to PATH: -->$sbin_dir"
    Add-ToPath $sbin_dir "Machine"

    #Remove-Item -Force -Path $rabbit_package
}

Update-SessionEnvironment

if(!(Get-Command rabbitmq-service -ErrorAction SilentlyContinue)) {
    Write-Error 'Could not find rabbitmq-service command. sbin folder not added to PATH correctly or PATH not refreshed.'
    return
}