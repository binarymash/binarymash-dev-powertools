param(
	[string]$searchTerm
)

Import-Module -DisableNameChecking $PSScriptRoot\dev-powertools-core.psm1

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


Remove-Module dev-powertools-core