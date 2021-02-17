public with sharing class LookupController {

	@AuraEnabled(cacheable=true)
	public static List<SObject> getLookupSerachRecords(String searchString, String selectedSObject, String SOQLWhereClause, String titleField, list<String> subtitleFields, Integer recordLimit){
		if(!String.isEmpty(searchString)){
			String searchSOSLInput = santizeStringForSOSL(searchString);
			if(searchString.length() > 1){
				String searchSelectClause = 'Id, '+titleField;
				for(String fld : subtitleFields){
					searchSelectClause += ', '+fld;
				}
				String SOSLQuery = 'FIND {*'+searchSOSLInput+'*} returning '+selectedSObject+' ('+searchSelectClause;
				if(!String.isEmpty(SOQLWhereClause))
					SOSLQuery += ' WHERE ' +SOQLWhereClause;
				SOSLQuery += ')';
				List<List<SObject>> searchList = search.query(SOSLQuery);
				return searchList[0];
			}
			return null;
		}
		return null;
	}

	//Account acc = new Account();
	//acc.Name = 'test account abc*def';
	// insert acc;
	
	// FIND {abc} returning Account (ID, Name) - matches
	// FIND {def} returning Account (ID, Name) - matches
	// FIND {abc\-def} returning Account (ID, Name) - matches
	// FIND {ab} returning Account (ID, Name) - matches
	// FIND {abc def} returning Account (ID, Name) - matches
	// FIND {abcdef} returning Account (ID, Name) - matches
	// FIND {abcef} returning Account (ID, Name) - matches
	// FIND {abcf} returning Account (ID, Name) - matches
	// FIND {abcfa} returning Account (ID, Name) - does not match
	// FIND {aba} returning Account (ID, Name) - does not match
	// FIND {bc} returning Account (ID, Name) - does not match
	// FIND {*bc} returning Account (ID, Name) - does not match
	// FIND {?bc} returning Account (ID, Name) - does not match
	
	// FIND {\-def} returning Account (ID, Name) - matches
	// FIND {\-de} returning Account (ID, Name) - does not match
	// FIND {\-de*} returning Account (ID, Name) - does not match
	// FIND {*\-de} returning Account (ID, Name) - does not match
	// FIND {*\-de*} returning Account (ID, Name) - does not match
	// FIND {*de} returning Account (ID, Name) - does not match
	// FIND {*de*} returning Account (ID, Name) - matches
	// FIND {de*} returning Account (ID, Name) - matches
	
	// FIND {account abcd} returning Account (ID, Name) - matches
	// FIND {account abc\-def} returning Account (ID, Name) - matches
	// FIND {accountabcd} returning Account (ID, Name) - does not match
	
	// based on the above. it might be best to remove all non alpha numeric non space characters as this improves the search matches
	// Also tried implementing more robust escape utils from popular blogs, but handling backslash and partial match returns were not upto needs
	public static String santizeStringForSOSL(String inputText){
			return inputText.replaceAll('[^a-zA-Z0-9\\s]', '');
	}
}