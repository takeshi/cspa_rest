Set-ExecutionPolicy Unrestricted
$ErrorActionPreference = 'Stop'

Try { 
	# variables
	$cspaUrl = 'https://github.com/edwindj/cspa_rest/archive/master.zip'
	$installRootDir = 'c:\cspa\'
	$prerequisitesDir = 'c:\cspa\prerequisites'
	$RPath = 'C:\Program Files\R\R-3.1.1\bin\i386'

<#
	# install the prerequisites
	Write-Host "Installing the prerequisites"
	$file = Join-Path $prerequisitesDir "python-2.7.8.msi"
	Start-Process msiexec -ArgumentList ("/qb /i " + $file) -Wait
	$file = Join-Path $prerequisitesDir "DotNET2SDK.exe"
	Start-Process $file -ArgumentList "/q:a /c:""install.exe /qb!""" -Wait
	$file = Join-Path $prerequisitesDir "node-v0.10.32-x86.msi"
	Start-Process msiexec -ArgumentList ("/qb /i " + $file) -Wait

	$file = Join-Path $prerequisitesDir "R-3.1.1-win.exe"
	Start-Process $file -ArgumentList ("/SILENT") -Wait
	$file = Join-Path $prerequisitesDir "curl-7.38.0-win32-local.msi"
	Start-Process msiexec -ArgumentList ("/qb /i " + $file) -Wait
#>

	# set Environment Variables (Get-ChildItem Env: to check)
	Write-Host "Set Environment Variables"
	# powershell equivalent of setx PATH "%PATH%;C:\Program Files\R\R-3.1.1\bin\i386" /M
	$oldPath = [Environment]::GetEnvironmentVariable('path', 'machine');
	If ($oldPath.Split(";") -notcontains $RPath) 
	{
		[Environment]::SetEnvironmentVariable('path', "$($oldPath);$($RPath)",'Machine')
	}
	$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine")
		
	cmd /c "C:\Program Files (x86)\Microsoft.NET\SDK\v2.0\Bin\sdkvars.bat"
	
	$sdkPath = "C:\Program Files (x86)\Microsoft.NET\SDK\v2.0\Bin;C:\Windows\Microsoft.NET\Framework\v2.0.50727;C:\Program Files (x86)\Microsoft Visual Studio 8\VC\bin;C:\Program Files (x86)\Microsoft Visual Studio 8\Common7\IDE;C:\Program Files (x86)\Microsoft Visual Studio 8\VC\vcpackages;"
	[Environment]::SetEnvironmentVariable('path', "$($env:Path);$($sdkPath)")
	[Environment]::SetEnvironmentVariable('LIB', "C:\Program Files (x86)\Microsoft Visual Studio 8\VC\lib;C:\Program Files (x86)\Microsoft.NET\SDK\v2.0\Lib;")
	[Environment]::SetEnvironmentVariable('INCLUDE', "C:\Program Files (x86)\Microsoft Visual Studio 8\VC\include;C:\Program Files (x86)\Microsoft.NET\SDK\v2.0\include;")
	[Environment]::SetEnvironmentVariable('NetSamplePath', "C:\Program Files (x86)\Microsoft.NET\SDK\v2.0")
	[Environment]::SetEnvironmentVariable('VCBUILD_DEFAULT_CFG', "Debug^|Win32")
	[Environment]::SetEnvironmentVariable('VCBUILD_DEFAULT_OPTIONS', "/useenv")
	
	# create or empty installation folder
	Write-Host "Create or empty installation folder " $installRootDir
	If (![System.IO.Directory]::Exists($installRootDir)) {
		[System.IO.Directory]::CreateDirectory($installRootDir)
	}
	Else {
		Remove-Item -Recurse -Force (Join-Path $installRootDir "*")
	}

	# download the package
	Write-Host "Downloading " $cspaUrl "..."
	$file = Join-Path $installRootDir "master.zip"
	$downloader = new-object System.Net.WebClient
	$downloader.DownloadFile($cspaUrl, $file)

	# unzip the package
	$installDir = Join-Path $installRootDir "cspa_rest"
	Write-Host "Extracting " $file " to " $installDir "..."
	$shellApplication = new-object -com shell.application
	$zipPackage = $shellApplication.NameSpace($file)
	$destinationFolder = $shellApplication.NameSpace($installRootDir)
	$destinationFolder.CopyHere($zipPackage.Items(),0x10)
	Start-Sleep -s 5
	Rename-Item -path (Join-Path $installRootDir "cspa_rest-master") -newName $installDir

	# download and install Node.js modules
    Write-Host "Download and install Node.js modules..." $rLibDir

	
	
	Set-Location $installDir
	Start-Process npm -ArgumentList "install" -Wait

	# download and install R packages
	# create or clean a local folder for R packages
	$rLibDir = (Join-Path $installDir "R_packages")
	Write-Host "Create or clean local R packages folder " $rLibDir
	If (![System.IO.Directory]::Exists($rLibDir)) {
		[System.IO.Directory]::CreateDirectory($rLibDir)
	}
	Else {
		Remove-Item -Recurse -Force (Join-Path $rLibDir "*")
	}
	[Environment]::SetEnvironmentVariable('R_LIBS', "$rLibDir", 'Machine')
	[Environment]::SetEnvironmentVariable('R_LIBS', "$rLibDir")

    Write-Host "Download and install R packages into " $rLibDir "..."
	$rCmd = [string]::Format("""install.packages(c('docopt', 'editrules', 'getopt', 'igraph', 'jsonlite', 'lpSolveAPI', 'rjson', 'rspa', 'whisker'), c('{0}'), repos=c('http://cran.us.r-project.org'))""", $rLibDir.Replace("\","/"))
	Start-Process (Join-Path $RPath "R.exe") -ArgumentList "-e $rCmd" -Wait
}
Catch {
	Write-Host 'Caught exception: ' $_.Exception.Message
}