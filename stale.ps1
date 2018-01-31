param(
	[string]$searchTerm
)

Import-Module $PSScriptRoot\dev-powertools-core.psm1

$staleRepos = New-Object System.Collections.Generic.List[System.IO.DirectoryInfo]
$repos = Get-Repos ($searchTerm)

if ($repos.Count -eq 0) {
	Write-Output "No repos found"
} else {
	foreach($repo in $repos){
		$status = Get-GitStatus($repo)			
		$displayStatus = Get-GitDisplayStatus($status)

		if ($displayStatus -eq "stale") {
			$staleRepos.Add($repo)
		}		
	}

	if ($staleRepos.Count -ne 0){
		Write-Host "The following repositories are out of date: "
		$staleRepos | % {Write-Host $_}
	} else {
		Write-Host "There are no stale repositories"
	}
}
Remove-Module dev-powertools-core