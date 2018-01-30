param(
	[string]$searchTerm
)

Import-Module $PSScriptRoot\dev-powertools-core.psm1

function Open-Explorer {
	Param([string]$path)
	Write-Host "Opening explorer in $path"
	explorer $path
}

$dir = "."

if ($searchTerm -ne "") {
	$dir = Get-Repo($searchTerm)
}

Open-Explorer($dir)

Remove-Module dev-powertools-core