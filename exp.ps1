param(
	[string]$searchTerm
)

Import-Module -DisableNameChecking $PSScriptRoot\dev-powertools-core.psm1

function Open-Explorer {
	Param([string]$path)
	Write-Host "Opening explorer in $path"
	explorer $path
}

$path = "."

if ($searchTerm -ne "") {
	$dir = Get-Directory($searchTerm)
	if ($dir){
		$path = $dir.fullname
	}
}

Open-Explorer($path)

Remove-Module dev-powertools-core