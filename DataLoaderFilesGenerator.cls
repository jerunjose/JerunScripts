public class DataLoaderFilesGenerator {
	public static String rootFolderForAllFiles = 'c:\\Users\\jerun\\dataloader\\v48.0.0\\downloaded-content\\';
    public static String extractJobSuffix = '_Extract';
	public static String insertJobSuffix = '_Insert';
	public static String updateJobSuffix = '_Update';
	public static String sandboxIdField = 'Record_Id_from_production__c';

    class ObjectProcessResults{
        String SOQLQuery;
        String mappingFileForInsert;
        String mappingFileForUpdate;
    }
    
    class DataSet{
        String objAPIName;
        String filterString;
		// can also expand to input an external id field
		// the set of objects can be converted to a map of objAPIName --> ext field
		// this also drives the upsertFields to be a map of fld --> ext field which can then resolve the mapping file.
		
		public DataSet(String objAPIName, String filterString){
			this.objAPIName = objAPIName;
			this.filterString = filterString;
		}
		
		public DataSet(String objAPIName){
			this.objAPIName = objAPIName;
		}
    }
    
	public static String generateBeansForDataSet(Integer dataSetNumber, DataSet ds, ObjectProcessResults opr, list<String> dataLoaderJobNames, list<String> updateJobNames){
		String beansForDatSet = '';

		// Create the bean for extract job
		String extractJobName = String.ValueOf(dataSetNumber)+'_'+ds.objAPIName+extractJobSuffix;
		dataLoaderJobNames.add(extractJobName);
		String extractFileName = extractJobName+'.csv';
		String SOQLQueryWithFilters = opr.SOQLQuery + (ds.filterString == null ? '' : (' WHERE '+ds.filterString));
		String extractJobBean = prepareExtractBean(extractJobName, ds.objAPIName, SOQLQueryWithFilters, extractFileName);
		beansForDatSet+= extractJobBean;

		// Create the bean for create job
		String insertJobName = String.ValueOf(dataSetNumber)+'_'+ds.objAPIName+insertJobSuffix;
		dataLoaderJobNames.add(insertJobName);
		String insertJobBean = prepareUpsertBean(insertJobName, ds.objAPIName, sandboxIdField, opr.mappingFileForInsert, extractFileName);
		beansForDatSet+= insertJobBean;

		// Create the bean for update job
		if(!String.isEmpty(opr.mappingFileForUpdate)){
			String updateJobName = String.ValueOf(dataSetNumber)+'_'+ds.objAPIName+updateJobSuffix;
			updateJobNames.add(updateJobName);
			String updateJobBean = prepareUpsertBean(updateJobName, ds.objAPIName, sandboxIdField, opr.mappingFileForUpdate, extractFileName);
			beansForDatSet+= updateJobBean;
		}
		return beansForDatSet;	
	}
    
    public static String openBean(String jobName){
        String beanTag = '';
        beanTag+= '\n\t<bean id="'+jobName+'" class="com.salesforce.dataloader.process.ProcessRunner" singleton="false">';
        beanTag+= '\n\t\t<property name="name" value="'+jobName+'"/>';
        beanTag+= '\n\t\t<property name="configOverrideMap">';
        beanTag+= '\n\t\t\t<map>';
        return beanTag;
    }
    
    public static String closeBean(String beanTag){
        beanTag+= '\n\t\t\t</map>';
        beanTag+= '\n\t\t</property>';
        beanTag+= '\n\t</bean>';
        return beanTag;
    }
    
    public static String prepareExtractBean(String jobName, String objAPIName, String SOQLQuery, String FileName){
        String processConfFile = openBean(jobName);
        processConfFile+= '\n\t\t\t\t<entry key="process.operation" value="extract"/>';
        processConfFile+= '\n\t\t\t\t<entry key="dataAccess.type" value="csvWrite"/>';
        processConfFile+= '\n\t\t\t\t<entry key="sfdc.entity" value="'+objAPIName+'"/>';
        processConfFile+= '\n\t\t\t\t<entry key="sfdc.extractionSOQL" value="'+SOQLQuery+'"/>';
        processConfFile+= '\n\t\t\t\t<entry key="dataAccess.name" value="'+rootFolderForAllFiles+FileName+'"/>';
        processConfFile = closeBean(processConfFile);
        return processConfFile;
    }
    
    public static String prepareUpsertBean(String jobName, String objAPIName, String externalIdField, String mappingFileName, String loadFileName){
        String processConfFile = openBean(jobName);
        processConfFile+= '\n\t\t\t\t<entry key="process.operation" value="upsert"/>';
        processConfFile+= '\n\t\t\t\t<entry key="dataAccess.type" value="csvRead"/>';
        processConfFile+= '\n\t\t\t\t<entry key="sfdc.entity" value="'+objAPIName+'"/>';
        processConfFile+= '\n\t\t\t\t<entry key="sfdc.externalIdField" value="'+externalIdField+'"/>';
        processConfFile+= '\n\t\t\t\t<entry key="process.mappingFile" value="'+rootFolderForAllFiles+mappingFileName+'"/>';
        processConfFile+= '\n\t\t\t\t<entry key="dataAccess.name" value="'+rootFolderForAllFiles+loadFileName+'"/>';
        processConfFile = closeBean(processConfFile);
        return processConfFile;
    }
    
    public static ContentVersion prepFile(String content, String fileName){
        ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S';
        cv.VersionData = Blob.valueOf(content);
        cv.Title = fileName;
        cv.PathOnClient = fileName;
        return cv;
    }
    
    public static void executeJob(){
		list<DataSet> datasets = new list<DataSet>();
		// 1. Insert account where IsPersonAccount = false
        datasets.add(new DataSet('Account', 'IsPersonAccount = false'));
		// 2. Insert contact where IsPersonAccount = false --- tested that no staff records have a lookup to account that is a personaccount
        datasets.add(new DataSet('Contact', 'IsPersonAccount = false'));
		// 3. Insert users where contactid != null --- tested that no user records have a lookup to contact that is a personaccount
        datasets.add(new DataSet('User', 'ContactId != null'));
		// 4. Insert account where IsPersonAccount = true
        datasets.add(new DataSet('Account', 'IsPersonAccount = true'));
		// 5. Insert all other
		datasets.add(new DataSet('Project_1__c'));
		datasets.add(new DataSet('Property__c'));
		datasets.add(new DataSet('Branch_Project_Assignment__c'));
		datasets.add(new DataSet('Staff_Assignment__c'));
		datasets.add(new DataSet('Property_Assignment__c'));
		datasets.add(new DataSet('Incentive__c'));
		datasets.add(new DataSet('Opportunity'));
		datasets.add(new DataSet('Lead', 'IsConverted = false'));
		
		processDataSets(datasets);
	}
	
    public static void processDataSets(list<DataSet> datasets){
        set<String> setUpObjects = new set<String>();
        // Not adding user object as portal users don't get carried over. These would also need to be loaded with external ids
        //setUpObjects.add('User');
        //setUpObjects.add('Group');
        setUpObjects.add('RecordType');
        
		set<String> objectsToLoad = new set<String>();
        for(DataSet ds : datasets){
			objectsToLoad.add(ds.objAPIName);
		}

        // Variables to hold the process results
        map<String, ObjectProcessResults> objProcessResultsMap = new map<String, ObjectProcessResults>();
        String processConfFile = '<beans>';
        list<ContentVersion> filesList = new list<ContentVersion>();
        // Begin processing
		Integer dataSetNumber = 1;
		list<String> dataLoaderJobNames = new list<String>();
		list<String> updateJobNames = new list<String>();
		for(DataSet ds : datasets){
			String objAPIName =  ds.objAPIName;
			ObjectProcessResults opr = objProcessResultsMap.get(objAPIName);
			// If the object has not been processed yet.
			if(opr == null){
				Map<String, Schema.SObjectField> fieldMap = Schema.describeSObjects(new String[]{objAPIName})[0].fields.getMap();
				set<String> insertFields = new set<String>();
				set<String> upsertFields = new set<String>();
				set<String> queryFields = new set<String>();
				for( String fieldName : fieldMap.KeySet() ) {
					Schema.SObjectField fld = fieldMap.get(fieldName);
					Schema.DescribeFieldResult dfr = fld.getDescribe();
					if(dfr.isCreateable()){
						if(dfr.getType() == Schema.DisplayType.REFERENCE){
							String parentObjAPIName = String.ValueOf(dfr.getReferenceTo()[0]);
							if(setUpObjects.contains(parentObjAPIName)){
								insertFields.add(fieldName);
							}else if(objectsToLoad.contains(parentObjAPIName)){
								upsertFields.add(fieldName);
							}
						}else{
							insertFields.add(fieldName);
						}
					}
				}
				insertFields.remove(sandboxIdField);
				
				// Generate the SOQL String
				queryFields.addAll(insertFields);
				queryFields.addAll(upsertFields);
				String SOQLSelectFields = 'Id';
				for(String fld : queryFields){
					SOQLSelectFields += ', '+fld;
				}
				String SOQLQuery = 'SELECT '+SOQLSelectFields+' FROM '+objAPIName;
				
				// Generate the insert mapping file
				String mappingFileForInsert = '#Mapping values from source file (left) and upsert to Salesforce (right)';
				// All the fields that can be created have a direct mapping. These should all be simple input fields.
				// This also includes reference fields to users or groups which are available in the system and don't need mapping.
				for(String fld : insertFields){
					mappingFileForInsert += '\n'+fld+'='+fld;
				}
				// Add the mapping for the Id field to go to the SandboxId field in this.
				mappingFileForInsert += '\nId'+'='+sandboxIdField;
				
				String mappingFileForUpdate = '';
				if(!upsertFields.isEmpty()){
					// Now process the upsert fields.
					// The upsert fields are all lookup fields that have the parent objects within the scope of the data copy.
					// If the object has already been processed, we should be able to map the field being loaded in the record create job.
					// This will be needed if the object being loaded is a detail object.
					// If not, add the field to an update mapping job which can be run after all the inserts are processed.
					// All the fields that can be created have a direct mapping. These should all be simple input fields.
					for(String fld : upsertFields){
						String relationshipFieldName;
						if(fld.endsWithIgnoreCase('Id')){
							relationshipFieldName = fld.removeEndIgnoreCase('Id');
						}else{
							relationshipFieldName = fld.replace('__c', '__r');
						}
						String mappingString = '\n'+fld+'='+relationshipFieldName+'.'+sandboxIdField;
						if(objProcessResultsMap.containsKey(fld)){
							mappingFileForInsert += mappingString;
						}else{
							mappingFileForUpdate += mappingString;
						}
					}
				}
				
				String insertMappingFileName = objAPIName+insertJobSuffix+'.sdl';
				filesList.add(prepFile(mappingFileForInsert, insertMappingFileName));

				String updateMappingFileName;
				if(!String.isEmpty(mappingFileForUpdate)){
					updateMappingFileName = objAPIName+updateJobSuffix+'.sdl';
					filesList.add(prepFile(mappingFileForUpdate, updateMappingFileName));
				}
            
				// All the processing for this object is done. Lets mark it as complete.
				// This would mean that any reference to this object can be marked in the insert jobs.
				opr = new ObjectProcessResults();
				opr.SOQLQuery = SOQLQuery;
				opr.mappingFileForInsert = insertMappingFileName;
				opr.mappingFileForUpdate = updateMappingFileName;
				
				objProcessResultsMap.put(objAPIName, opr);

				// When user records have been processed, it is safe to perform polymorphic lookups for user and queue objects
				if(objAPIName == 'User')
					setUpObjects.add('Group');
			}

			processConfFile+= generateBeansForDataSet(dataSetNumber, ds, opr, dataLoaderJobNames, updateJobNames);
			dataSetNumber++;
        }
		// Add all the update jobs after the extract and inserts are done
		dataLoaderJobNames.addAll(updateJobNames);
        processConfFile+= '\n</beans>';
		filesList.add(prepFile(processConfFile, 'process-conf.xml'));

        ContentWorkspace cw = [select id, RootContentFolderId from ContentWorkspace WHERE Name = 'Data Loader Config Files'];
        list<ContentDocument> filesToDelete = new list<ContentDocument>();
        for(ContentDocumentLink cdl : [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :cw.Id]){
            ContentDocument cd = new ContentDocument(id = cdl.ContentDocumentId);
            filesToDelete.add(cd);
        }
        if(!filesToDelete.isEmpty()){
            delete filesToDelete;
        }
        insert filesList;
        list<ContentDocumentLink> cdlList = new list<ContentDocumentLink>();
        for(ContentVersion cv : [SELECT ContentDocumentId FROM ContentVersion Where Id IN :filesList]){
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = cv.ContentDocumentId;
            cdl.ShareType = 'I';
            cdl.Visibility = 'AllUsers';
            cdl.LinkedEntityId = cw.Id;
            cdlList.add(cdl);
        }
        insert cdlList;
        
        String URLToDownloadFrom = 'https://ironfish--tsaishen.my.salesforce.com/sfc/#search?searchWorkspaceIds=%5B%22'+cw.Id+'%22%5D';
        System.debug(URLToDownloadFrom);

        // Note to self - Salesforce documentation says polymorphic lookups don't support external Id - which means that owner id would not support external Id.
        // If this is the case, then what would happen if you delete the queue on lead object - not used so no impact? 
    }
}