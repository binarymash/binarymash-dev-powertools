function Get-BaseDirs{
	[CmdletBinding()]
	$baseDir = [Environment]::GetEnvironmentVariable("DPT_BASE_DIRS")

	if ($baseDir -eq $null) {
		throw "No repo directory is set... run install"
	}
	
	Write-Output $baseDir
}


function Get-Directories{
	[CmdletBinding()]
	param (
		[string]
		$SearchTerm
	)

	$baseDir = Get-BaseDirs
	
	Get-ChildItem $baseDir *$SearchTerm* -Directory
}


function Get-Directory{
	[CmdletBinding()]
	param (
		[string]
		$SearchTerm
	)
	
	Select-Directory (Get-Directories $SearchTerm)
}


function Get-GitRepos{
	[CmdletBinding()]	
	param (
		[string]
		$SearchTerm)

	Get-Directories $SearchTerm | Where-Object {$(Test-IsGitRepo($_)) -eq $True}
}


function Get-GitRepo{
	[CmdletBinding()]	
	param (
		[string]
		$SearchTerm
	)
	
	Select-Directory (Get-GitRepos $SearchTerm)
}


function Select-Directory{
	[CmdletBinding()]	
	param (
		$Directories
	)

	if ($Directories.Count -eq 0) {
		Write-Host "Didn't find anything to match $searchTerm"
	} 
	elseif ($Directories.Count -eq 1) {
		$Directories[0]
	}
	else {	
		Write-Host "There are multiple matching matches:"
		$global:index = 0
		Write-Host ($Directories | format-table -Property @{name="Index";expression={$global:index;$global:index+=1}},fullname | out-string)
		$selection = Read-Host -Prompt 'Make your selection:'
		$Directories[$selection-1]
	}
}


function Test-IsGitRepo{
	[CmdletBinding()]
	param (
		[Parameter (Mandatory = $True)]
		[System.IO.DirectoryInfo]
		$Repo
	)
	process{
		Push-Location $Repo.fullname
		
		$isRepo = test-path .git
		
		Pop-Location	
		
		$isRepo
	}
}


function Get-GitStatus{
	[CmdletBinding()]	
	param (
		[Parameter (Mandatory = $True)]
		[System.IO.DirectoryInfo]
		$Repo
	)
	$status = ""
	Write-Progress -Activity "Checking $Repo" -Status " "  
	$host.ui.RawUI.WindowTitle = $Repo.fullname
	
	Push-Location $Repo.fullname
	
	if ($(Test-IsGitRepo($Repo)) -eq $true) {		
		(git fetch) 2>&1>$null
		($status = git status) 2>&1>$null
	} else {
		Write-Output "invalid"
	}
	
	Pop-Location

	if ($status -like '*Your branch is behind*') {
		Write-Output "stale"
	} elseif ($status -like '*up-to*date*') {
		Write-Output "up-to-date"
	} else {
		Write-Output "unknown"
	}
}


function Get-StaleGitRepos{
<#
.DESCRIPTION
Reports if repositories are out of date

.PARAMETER SearchTerm
(Optional) A search term for the repository to analyse. 

.EXAMPLE
Get-StaleGitRepos
For all registered git repos reports whether they are out of date

.EXAMPLE
Get-StaleGitRepos myRepo
Searches for a registered folder whose name contains myRepo and, if found, reports on whether it is out of date

.EXAMPLE
stale myRepo
Searches for a registered folder whose name contains myRepo and, if found, reports on whether it is out of date
#>
[CmdletBinding()]	
	[Alias("stale")]
	param (
		[string]
		$SearchTerm
	)
	function Get-StaleRepos()
	{
		param([System.Collections.Generic.List[System.IO.DirectoryInfo]]$repos)
		
		$staleRepos = New-Object System.Collections.Generic.List[System.IO.DirectoryInfo]
		foreach($repo in $repos) {
			$status = Get-GitStatus($repo)			

			if ($status -eq "stale") {
				$staleRepos.Add($repo)
			}		
		}

		$staleRepos
	}
	
	$repos = Get-GitRepos ($SearchTerm)
	
	if ($repos.Count -eq 0) {
		Write-Output "No repos found"
	} else {
		$staleRepos = Get-StaleRepos($repos)
	
		if ($staleRepos.Count -ne 0) {
			Write-Host "The following repositories are out of date: "
			$staleRepos | ForEach-Object {Write-Host $_}
		} else {
			Write-Host "There are no stale repositories"
		}
	}
}


function Open-RepoExplorer {
<#
.DESCRIPTION
Opens the location of the specified folder in the file explorer

.PARAMETER SearchTerm
A search term for the repository to open. 

.EXAMPLE
Open-RepoExplorer myRepo
Searches for a registered folder whose name contains myRepo and, if found, opens this location in the file explorer

.EXAMPLE
exp myRepo
Searches for a registered folder whose name contains myRepo and, if found, opens this location in the file explorer
#>
	[CmdletBinding()]	
	[Alias("exp")]
	param (
		[string]
		$SearchTerm
	)

	$pathToOpen = $null

	if ($SearchTerm -eq "") {
		$pathToOpen = "."
	} else {
		$dir = Get-Directory($SearchTerm)
		if ($dir) {
			$pathToOpen = $dir.fullname
		}
	}

	if ($pathToOpen) {
		Write-Host "Opening explorer in $pathToOpen"
		explorer $pathToOpen
	}	
}


function Open-RepoLocation {
<#
.DESCRIPTION
Opens the location of the specified folder

.PARAMETER SearchTerm
A search term for the repository to open. 

.EXAMPLE
Open-RepoLocation myRepo
Searches for a registered folder whose name contains myRepo and, if found, opens this location

.EXAMPLE
Open-RepoLocation myRepo
Searches for a registered folder whose name contains myRepo and, if found, opens this location

.EXAMPLE
repo myRepo
Searches for a registered folder whose name contains myRepo and, if found, opens this location
#>
	[CmdletBinding()]	
	[Alias("repo")]
	param (
		[string]
		$SearchTerm
	)
	
	if ($SearchTerm -eq "") {
		Get-GitRepos | ForEach-Object {Write-Output $_.name}
		
	} else {
		$dir = Get-GitRepo($SearchTerm)
		if ($dir -eq $null) {
			Write-Output "Cannot switch to $SearchTerm"
		} else {
			Push-Location $dir.fullname
		}
	}
}


function Open-VsCode {
<#
.DESCRIPTION
Launches Visual Studio Code, optionally opening the specified folder

.PARAMETER SearchTerm
(Optional) A search term for the folder to open. 

.EXAMPLE
Open-VsCode
Launches Visual Studio code but does not load any folder

.EXAMPLE
Open-VsCode myRepo
Searches for a folder whose name contains myRepo and, if found, opens this folder in Visual Studio Code

.EXAMPLE
vsc myRepo
Searches for a folder whose name contains myRepo and, if found, opens this folder in Visual Studio Code
#>
	[CmdletBinding()]	
	[Alias("vsc")]
	param (
		[string]
		$SearchTerm
	)
	
	$pathToOpen = $null

	if ($SearchTerm -eq "") {
		$pathToOpen = "."	
	}
	else {
		$dir = Get-Directory($SearchTerm)
		if ($dir) {
			$pathToOpen = $dir.fullname	
		}
	}

	if ($pathToOpen) {
		Write-Host "Opening Visual Studio Code in $pathToOpen"
		code $pathToOpen
	}	
}