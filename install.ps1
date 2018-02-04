function Show-Splash {
	Write-Host		
	Write-Host "-----------------------------------------------------------------------------"
	Write-Host "  Dev-Powertools"
	Write-Host "  Repository: https://github.com/binarymash/dev-powertools"
	Write-Host "  License: https://github.com/binarymash/dev-powertools/blob/master/LICENSE"
	Write-Host "-----------------------------------------------------------------------------"
	Write-Host	
}

function Install-Module {
	$module = Get-Module "dev-powertools"
	if(!$module){
		Write-Host "- The BinaryMash.DevPowertools module is not yet installed. To install, do one of the following:"
		Write-Host
		Write-Host "  1. Modify the PSModulePath environment variable to include $PSScriptRoot, or"
		Write-Host "  2. Copy the dev-powertools folder into one of the following locations:"
		Write-Host "    - If you want to install just for the current user, copy to $home\Documents\WindowsPowerShell\Modules\"
		Write-Host "    - If you want to install for all users, copy to $Env:ProgramFiles\WindowsPowerShell\Modules\"
		Write-Host
		Write-Host "You'll need to restart your powershell session to pick up all of these changes!" -ForegroundColor Yellow
	}
}

function Set-EnvironmentVariables {
	Set-EnvironmentVariable(@('DPT_BASE_DIRS', 'Enter the base directory that contains your repositories'))
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
		$poshGitChoice = $false

		while(!$poshGitChoice){
			$selection = $(Read-Host -Prompt '- posh-git is not installed. Do you want to install it? [Y|n]').ToLower()
			if ($selection -in @("y","n","")){
				$poshGitChoice = $true
			}
		}

		if($selection -ne "n"){
			Write-Host "Installing posh-git..."
			(new-object Net.WebClient).DownloadString("http://psget.net/GetPsGet.ps1") | iex
			install-module posh-git
			if (!$?) {
				throw "Failed to install posh-git"
			}  
			Write-Host "- Installed posh-git"	
		}
	}
}

Show-Splash
Set-EnvironmentVariables
Install-PoshGit
Install-Module
