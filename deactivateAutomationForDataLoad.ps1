function deactivateProcessBuilders(){
	cd mdAPISource\flowDefinitions
	$filesList = Get-ChildItem -Recurse | Select-String "activeVersionNumber" -List | Select Path
	foreach ($filePath in $filesList.Path) {
		Set-Content -path "$filePath" -value '<?xml version="1.0" encoding="UTF-8"?><FlowDefinition xmlns="http://soap.sforce.com/2006/04/metadata"><activeVersionNumber>0</activeVersionNumber></FlowDefinition>'
	}
	cd ..
	cd ..
}
function deactivateTriggers(){
	cd mdAPISource\triggers
	$filesList = Get-ChildItem -Recurse | Select-String "<status>Active</status>" -List | Select Path
	foreach ($filePath in $filesList.Path) {
		((Get-Content -path "$filePath" -Raw) -replace "<status>Active</status>",'<status>Inactive</status>') | Set-Content -Path "$filePath"
	}
	cd ..
	cd ..
}
function deactivateWorkflows(){
	cd mdAPISource\workflows
	$filesList = Get-ChildItem -Recurse | Select-String "<active>true</active>" -List | Select Path
	foreach ($filePath in $filesList.Path) {
		((Get-Content -path "$filePath" -Raw) -replace "<active>true</active>",'<active>false</active>') | Set-Content -Path "$filePath"
	}
	cd ..
	cd ..
}
function deactivateValidationRules(){
	cd mdAPISource\objects
	$filesList = Get-ChildItem -Recurse | Select-String "<active>true</active>" -List | Select Path
	foreach ($filePath in $filesList.Path) {
		((Get-Content -path "$filePath" -Raw) -replace "<validationRules>.*?\n?.*?\n?.*?<fullName>(.*?)</fullName>.*?\n?.*?<active>true</active>",'<validationRules><fullName>$1</fullName><active>false</active>') | Set-Content -Path "$filePath"
	}
	cd ..
	cd ..
}

deactivateValidationRules
deactivateProcessBuilders
deactivateTriggers
deactivateWorkflows
