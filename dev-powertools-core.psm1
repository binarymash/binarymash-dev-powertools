function Get-Repo{
	Param([string]$searchTerm)
	
	$baseDir = [Environment]::GetEnvironmentVariable("dpt-repo-dirs")

	if ($baseDir -eq $null){
		throw "No repo directory is set... run install"
	}

	$matchingDirs = ls $baseDir *$searchTerm* -Directory

	if($matchingDirs.Count -eq 0)
	{
		Write-Host "Didn't find anything to match $searchTerm"
	} 
	elseif($matchingDirs.Count -eq 1)
	{
		Join-Path -Path "$baseDir" -ChildPath "$matchingDirs"	
	}
	else
	{
		Write-Host "There are multiple matching matches:"
		$global:index = 0
		Write-Host ($matchingDirs | format-table -Property @{name="Index";expression={$global:index;$global:index+=1}},name | out-string)
		$choice = Read-Host -Prompt 'Make your choice:'
		$selectedDir = $matchingDirs[$choice-1]
		(Get-ChildItem -Path $baseDir -Filter $selectedDir).fullname
	}
}

export-modulemember -function Get-Repo 