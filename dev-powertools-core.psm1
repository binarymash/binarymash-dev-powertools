function Get-Directories{
	param([string]$searchTerm)

	$baseDir = [Environment]::GetEnvironmentVariable("dpt-repo-dirs")

	if ($baseDir -eq $null){
		throw "No repo directory is set... run install"
	}
	
	ls $baseDir *$searchTerm* -Directory
}

function Get-Directory{
	param([string]$searchTerm)
	
	Select-Directory (Get-Directories $searchTerm)
}

function Get-GitRepos{
	Param([string]$searchTerm)

	Get-Directories $searchTerm | where {Is-GitRepo($_) -eq $True}
}

function Get-GitRepo{
	param([string]$searchTerm)
	
	Select-Directory (Get-GitRepos $searchTerm)
}

function Select-Directory{
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

function Is-GitRepo{
	param([System.IO.DirectoryInfo]$repo)

	pushd $repo.fullname
	
	$isRepo = test-path .git
	
	popd	
	
	Write-Output $isRepo
}

function Get-GitStatus{
	param([System.IO.DirectoryInfo]$repo)

	Write-Progress -Activity "Checking $repo" -Status " "  
	$host.ui.RawUI.WindowTitle = $repo.fullname
	
	pushd $repo.fullname
	
	if (Is-GitRepo($repo) -eq $true) {		
		(git fetch) 2>&1>$null
		($status = git status) 2>&1>$null
	} else {
		Write-Host "$repo is not a git repo"
	}
	
	popd
	
	Write-Output $status		
}

function Get-GitDisplayStatus{
	param([string]$status)
	
	if ($status -like '*Your branch is behind*') {
		Write-Output "stale"
	} elseif ($status -like '*up-to*date*'){
		Write-Output "up-to-date"
	} else {
		Write-Output "unknown"
	}
}

export-modulemember -function *
