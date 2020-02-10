<#
.SYNOPSIS
Initialize Specified Application
.DESCRIPTION
Modify Env Path
.PARAMETER AppName
name of app for which to init
Should also replace functionalities provided by PARAM psConsoleType
Console type: for future use, `Init-App` replaces it for now.
.EXAMPLE

.NOTES
targetting apps i.e., choco, python (ML)

Required following Env Vars,
 - $PFilesX64Dir
#>

[CmdletBinding()] Param (
  [ValidateSet('resetEnvPath', 'choco', 'dotnet', 'git', 'fb-tools', 'pwsh', 'python')] [string] $AppName)

function AddToEnvPath([string] $path = ';') {
  if (! (Test-Path $path)) {
    Write-Host "Not valid path: $path"
    return
  }
  if ($Env:Path.Contains($path) -Eq $False) {
    $Env:Path += ';' + $path
  }
}

<#
.SYNOPSIS
The Main function of this Script
.DESCRIPTION
Modify Env Path
.PARAMETER InitType
Customized init based on type
.EXAMPLE
InitVariables choco
.NOTES
To facilitate calling it nested
#>
function InitVariables([string] $InitType = 'resetEnvPath') {
  'Init for app: ' + $InitType

  switch( $InitType ) {
    'choco' {
      $path = 'C:\WINDOWS\CPE\lib\powershell'
      if ($Env:PSModulePath.Contains($path) -Eq $False) { $Env:PSModulePath += ';' + $path }

      # choco sources list
      # choco source add -n=chocolatey -s="https://chocolatey.org/api/v2/"
      # choco source remove -n cpe_client
      $Env:ChocolateyInstall = 'D:\PFiles_x64\Chocolatey'
      $Env:ChocolateyToolsLocation = 'D:\PFiles_x64\chocolatey\tools'
      AddToEnvPath( $Env:ChocolateyInstall + '\bin' )
      return
    }
    # restore path to default
    # ** this should be taken care of using post chef run script
    # however, this one should run a validation check whether is PATH is clean!
    'resetEnvPath' {
      $Env:Path = 'C:\windows\system32;C:\windows;C:\windows\System32\Wbem;C:\Users\atiq\AppData\' +
        'Local\Microsoft\WindowsApps;C:\windows\System32\WindowsPowerShell\v1.0;' + $PSHOME + ';' +
        $PwshScriptDir
      return
    }
    # rest are path updates
    'dotnet' {
      # decoration '$(' is required to not consider space as argument delimeter
      AddToEnvPath( $Env:ProgramFiles + '\dotnet' )
      return
    }
    'fb-tools' {  # required for analyze tooling
      # CPE\lib to PSModulePath, firt line is FB only
      $Env:PSModulePath += ';C:\WINDOWS\CPE\lib\powershell'
      # set choco paths but don't add to PATH, hence slightly different than `InitVariables choco`
      $Env:ChocolateyInstall = 'D:\PFiles_x64\Chocolatey'
      $Env:ChocolateyToolsLocation = 'D:\PFiles_x64\chocolatey\tools'
      AddToEnvPath $Env:ChocolateyToolsLocation
      # Usually not required: do a cc-certs renewal based on expiration value and the
      # dialog box for init won't appear again!
      # AddToEnvPath 'C:\Tools'
      return
    }
    # planned deprecation by 'Git Util' net core app
    'git' {
      AddToEnvPath( $PFilesX64Dir + '\git\cmd' )
      return
    }
    'pwsh' {
      AddToEnvPath $PwshScriptDir
      return
    }
    'python' {
      AddToEnvPath( $PFilesX64Dir + '\python3;' + $PFilesX64Dir + '\python3\Scripts' )
      return
    }
    'build' {
      return
    }
    default {
      'Invalid command line argument: ' + $InitType
      return
    }
  }
}

InitVariables $AppName
