function Get-BaseDirs{
	[CmdletBinding()]
	$baseDir = [Environment]::GetEnvironmentVariable("DPT_BASE_DIRS")

	if ($baseDir -eq $null){
		throw "No repo directory is set... run install"
	}
	
	Write-Output $baseDir
}

function Get-Directories{
	[CmdletBinding()]
	param([string]$searchTerm)

	$baseDir = Get-BaseDirs
	
	ls $baseDir *$searchTerm* -Directory
}

function Get-Directory{
	[CmdletBinding()]
	param([string]$searchTerm)
	
	Select-Directory (Get-Directories $searchTerm)
}

function Get-GitRepos{
	[CmdletBinding()]	
	param([string]$searchTerm)

	Get-Directories $searchTerm | where {$(Test-IsGitRepo($_)) -eq $True}
}

function Get-GitRepo{
	[CmdletBinding()]	
	param([string]$searchTerm)
	
	Select-Directory (Get-GitRepos $searchTerm)
}

function Select-Directory{
	[CmdletBinding()]	
	param($directories)

	if($directories.Count -eq 0)
	{
		Write-Host "Didn't find anything to match $searchTerm"
	} 
	elseif($directories.Count -eq 1)
	{
		$directories[0]
	}
	else
	{	
		Write-Host "There are multiple matching matches:"
		$global:index = 0
		Write-Host ($directories | format-table -Property @{name="Index";expression={$global:index;$global:index+=1}},fullname | out-string)
		$selection = Read-Host -Prompt 'Make your selection:'
		$directories[$selection-1]
	}
}

function Test-IsGitRepo{
	[CmdletBinding()]
	param(
		[Parameter(Mandatory=$True)]
		[System.IO.DirectoryInfo]
		$repo
	)
	process{
		pushd $repo.fullname
		
		$isRepo = test-path .git
		
		popd	
		
		$isRepo
	}
}

function Get-GitStatus{
	[CmdletBinding()]	
	param(
		[Parameter(Mandatory=$True)]
		[System.IO.DirectoryInfo]$repo
	)
	$status = ""
	Write-Progress -Activity "Checking $repo" -Status " "  
	$host.ui.RawUI.WindowTitle = $repo.fullname
	
	pushd $repo.fullname
	
	if ($(Test-IsGitRepo($repo)) -eq $true) {		
		(git fetch) 2>&1>$null
		($status = git status) 2>&1>$null
	} else {
		Write-Output "invalid"
	}
	
	popd

	if ($status -like '*Your branch is behind*') {
		Write-Output "stale"
	} elseif ($status -like '*up-to*date*'){
		Write-Output "up-to-date"
	} else {
		Write-Output "unknown"
	}
}

<#
.DESCRIPTION
Reports if repositories are out of date

.PARAMETER searchTerm
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
#>function Get-StaleGitRepos{
	[CmdletBinding()]	
	[Alias("stale")]
	param(
		[string]$searchTerm
	)
	function Get-StaleRepos()
	{
		param([System.Collections.Generic.List[System.IO.DirectoryInfo]]$repos)
		
		$staleRepos = New-Object System.Collections.Generic.List[System.IO.DirectoryInfo]
		foreach($repo in $repos){
			$status = Get-GitStatus($repo)			

			if ($status -eq "stale") {
				$staleRepos.Add($repo)
			}		
		}

		$staleRepos
	}
	
	$repos = Get-GitRepos ($searchTerm)
	
	if ($repos.Count -eq 0) {
		Write-Output "No repos found"
	} else {
		$staleRepos = Get-StaleRepos($repos)
	
		if ($staleRepos.Count -ne 0){
			Write-Host "The following repositories are out of date: "
			$staleRepos | % {Write-Host $_}
		} else {
			Write-Host "There are no stale repositories"
		}
	}
}

<#
.DESCRIPTION
Opens the location of the specified folder in the file explorer

.PARAMETER searchTerm
A search term for the repository to open. 

.EXAMPLE
Open-RepoExplorer myRepo
Searches for a registered folder whose name contains myRepo and, if found, opens this location in the file explorer

.EXAMPLE
exp myRepo
Searches for a registered folder whose name contains myRepo and, if found, opens this location in the file explorer
#>
function Open-RepoExplorer {
	[CmdletBinding()]	
	[Alias("exp")]
	param(
		[string]$searchTerm
	)

	$pathToOpen = $null

	if ($searchTerm -eq ""){
		$pathToOpen = "."
	} else {
		$dir = Get-Directory($searchTerm)
		if ($dir){
			$pathToOpen = $dir.fullname
		}
	}

	if($pathToOpen){
		Write-Host "Opening explorer in $pathToOpen"
		explorer $pathToOpen
	}	
}

<#
.DESCRIPTION
Opens the location of the specified folder

.PARAMETER searchTerm
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
function Open-RepoLocation {
	[CmdletBinding()]	
	[Alias("repo")]
	param(
		[string]$searchTerm
	)
	
	if ($searchTerm -eq "") {
		Get-GitRepos | % {Write-Output $_.name}
		
	} else {
		$dir = Get-GitRepo($searchTerm)
		if ($dir -eq $null) {
			Write-Output "Cannot switch to $searchTerm"
		} else {
			pushd $dir.fullname
		}
	}
}

<#
.DESCRIPTION
Launches Visual Studio Code, optionally opening the specified folder

.PARAMETER searchTerm
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
function Open-VsCode {
	[CmdletBinding()]	
	[Alias("vsc")]
	param([string]$searchTerm)
	$pathToOpen = $null

	if ($searchTerm -eq ""){
		$pathToOpen = "."	
	}
	else {
		$dir = Get-Directory($searchTerm)
		if ($dir){
			$pathToOpen = $dir.fullname	
		}
	}

	if($pathToOpen) {
		Write-Host "Opening Visual Studio Code in $pathToOpen"
		code $pathToOpen
	}	
}