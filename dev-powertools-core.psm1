function Get-Repo{
	Param([string]$searchTerm)
	
	$baseDir = [Environment]::GetEnvironmentVariable("dpt-repo-dirs")	
	$matchingDirs = Get-Repos($searchTerm)
	
	if($matchingDirs.Count -eq 0)
	{
		Write-Host "Didn't find anything to match $searchTerm"
	} 
	elseif($matchingDirs.Count -eq 1)
	{
		$matchingDirs[0]
	}
	else
	{
		Write-Host "There are multiple matching matches:"
		$global:index = 0
		Write-Host ($matchingDirs | format-table -Property @{name="Index";expression={$global:index;$global:index+=1}},fullname | out-string)
		$choice = Read-Host -Prompt 'Make your choice:'
		$matchingDirs[$choice-1]
	}
}

function Get-Repos{
	Param([string]$searchTerm)

	$baseDir = [Environment]::GetEnvironmentVariable("dpt-repo-dirs")

	if ($baseDir -eq $null){
		throw "No repo directory is set... run install"
	}
	
	ls $baseDir *$searchTerm* -Directory
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


export-modulemember -function Get-Repo 
export-modulemember -function Get-Repos 
export-modulemember -function Get-GitStatus 
export-modulemember -function Get-GitDisplayStatus
