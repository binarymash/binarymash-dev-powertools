param(
	[string]$searchTerm
)

Import-Module -DisableNameChecking $PSScriptRoot\dev-powertools-core.psm1

function Get-StaleRepos()
{
	param([System.Collections.Generic.List[System.IO.DirectoryInfo]]$repos)
	
	$staleRepos = New-Object System.Collections.Generic.List[System.IO.DirectoryInfo]
	foreach($repo in $repos){
		$status = Get-GitStatus($repo)			
		$displayStatus = Get-GitDisplayStatus($status)

		if ($displayStatus -eq "stale") {
			$staleRepos.Add($repo)
		}		
	}	
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
Remove-Module dev-powertools-core