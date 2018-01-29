param(
	[string]$searchTerm
)

function Open-Explorer {
	Param([string]$path)
	Write-Host "Opening explorer in $path"
	explorer $path
}

if ($searchTerm -eq "") {
	Open-Explorer(".")
} else {
	$repoDir = [Environment]::GetEnvironmentVariable("dpt-repo-dirs")

	if ($repoDir -eq $null){
		throw "No repo directory is set. Run installDevPowertools"
	}

	$dirs = ls $repoDir *$searchTerm* -Directory

	if($dirs.Count -gt 1)
	{
		Write-Host "There are multiple matching repositories:"
		$global:index = 0
		$dirs | format-table -Property @{name="Index";expression={$global:index;$global:index+=1}},name
		$choice = Read-Host -Prompt 'Select the repo to switch to:'
		$selectedDir = $dirs[$choice-1]
		$dir = (Get-ChildItem -Path $repoDir -Filter $selectedDir).fullname
		Open-Explorer($dir)
	}
	else {
		$path = Join-Path -Path "$repoDir" -ChildPath "$dir"
		Open-Explorer($path)
	}
}
