param(
	[string]$searchTerm
)

Import-Module -DisableNameChecking $PSScriptRoot\dev-powertools-core.psm1

function Open-VsCode {
	Param([string]$path)
	Write-Host "Opening Visual Studio Code in $path"
	code $path
}

if ($searchTerm -eq ""){
	Open-VsCode "."	
}
else {
	$dir = Get-Directory($searchTerm)
	if ($dir){
		Open-VsCode $dir.fullname	
	}
}


Remove-Module dev-powertools-core