param(
	[string]$searchTerm
)

Import-Module $PSScriptRoot\dev-powertools-core.psm1

if ($searchTerm -ne "") {
	$dir = Get-Repo($searchTerm)
}

if ($dir -eq $null) {
	Write-Output "Cannot switch to $searchTerm"
} else {
	pushd $dir
}

Remove-Module dev-powertools-core