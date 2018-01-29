function Register-Path {
	Add-UserPath($PSScriptRoot)
}

function Set-EnvironmentVariables {
	Set-EnvironmentVariable(@('dpt-repo-dirs', 'Enter root directories that contain your repositories'))
}

function Set-EnvironmentVariable {
	Param([array]$variable)
	if ($variable -ne $null) {
		$name = $variable[0];
		$prompt = $variable[1];

		$value = [Environment]::GetEnvironmentVariable($name);
		
		if($value -eq $null)
		{    
			$value = "Not set";
		}
		
		$input = (Read-Host -Prompt "- $prompt ($value)");
		if ($input -ne ''){
			[Environment]::SetEnvironmentVariable($name, $input, "User");						
		}
	}
}

function Install-PoshGit {
	if (Get-Module -ListAvailable -Name posh-git) {
		Write-Host "- posh-git is already installed."
	} else {
		Write-Host "- posh-git is not installed, so we'll install it now..."
		(new-object Net.WebClient).DownloadString("http://psget.net/GetPsGet.ps1") | iex
		install-module posh-git
		if (!$?) {
			throw "Failed to install posh-git"
		}  
		Write-Host "- Installed posh-git"
	}
}

function Add-UserPath {            
	Param([array]$pathToAdd)
	$verifiedPathsToAdd = $Null
	foreach($path in $pathToAdd) {
		if($env:Path -like "*$path*") {
		Write-Host "- $path already exists in PATH" }
		else {
			$verifiedPathsToAdd += ";$path"
			Write-Host "-`$verifiedPathsToAdd updated to contain: $path"
		}
		if ($verifiedPathsToAdd -ne $null) {
			Write-Host "- Adding $Path to PATH"
			[Environment]::SetEnvironmentVariable("Path",$env:Path + $verifiedPathsToAdd,"User")            
		}
	}
}

Register-Path
Set-EnvironmentVariables
Install-PoshGit
