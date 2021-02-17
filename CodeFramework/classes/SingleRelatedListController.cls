/**
* @author       Jerun Jose Stanley @ Cloudwerx
* @description  Controller for the Single Related List aura component
*/
public with sharing class SingleRelatedListController {
    // Variables to hold the JSON parameter names
    public static final String FIELDS_PARAM = 'fields';
    public static final String NUMBER_OF_RECORDS_PARAM = 'numberOfRecords';
    public static final String RECORD_ID_PARAM = 'recordId';
    public static final String SOBJECT_API_NAME_PARAM = 'sobjectApiName';
    public static final String SOBJECT_LABEL_PARAM = 'sobjectLabel';
    public static final String SOBJECT_LABEL_PLURAL_PARAM = 'sobjectLabelPlural';
    public static final String PARENT_RELATIONSHIP_API_NAME_PARAM = 'parentRelationshipApiName';
    public static final String RELATED_FIELD_API_NAME_PARAM = 'relatedFieldApiName';
    public static final String SORTED_DIRECTION_PARAM = 'sortedDirection';
    public static final String SORTED_BY_PARAM = 'sortedBy';
    public static final String RECORDS_PARAM = 'records';
    public static final String ICON_NAME_PARAM = 'iconName';
    
    // Init method to retrieve the records and assign the variables
    @AuraEnabled
    public static LightningResponseWrapper initData(String jsonData){
        LightningResponseWrapper reponseWrapper = new LightningResponseWrapper();
        try{
            // Prepare the response map
            Map<String, Object> responseMap = new Map<String, Object>();
            // Call util to retrieve the records
            responseMap.put(RECORDS_PARAM, getRecords(jsonData));
            
            // Parse the request data map
            Map<String, Object> requestMap = (Map<String, Object>)JSON.deserializeUntyped(jsonData);
            
            // Use object describe to find the object detail
            String sobjectApiName = (String)requestMap.get(SOBJECT_API_NAME_PARAM);
            responseMap.put(ICON_NAME_PARAM, getIconName(sobjectApiName));
            String recordId = (String)requestMap.get(RECORD_ID_PARAM);
            responseMap.put(PARENT_RELATIONSHIP_API_NAME_PARAM, getParentRelationshipName(recordId, sobjectApiName));
            Schema.SObjectType sobjectType = Schema.getGlobalDescribe().get(sobjectApiName);
            Schema.DescribeSObjectResult sobjectDescribe = sobjectType.getDescribe();
            responseMap.put(SOBJECT_LABEL_PARAM, sobjectDescribe.getLabel());
            responseMap.put(SOBJECT_LABEL_PLURAL_PARAM, sobjectDescribe.getLabelPlural());
            reponseWrapper.successRespObj = (object)JSON.serialize(responseMap);
        }
        catch(Exception ex){
            reponseWrapper = ApplicationLogUtility.createLogException(ex, UtilMethods.consts.LIT_ERROR_CODE_EXCEPTION, UtilMethods.consts.LIT_SEVERITY_ERROR);
        }
        return reponseWrapper;
    }
    
    // Util method to retrieve records
    @AuraEnabled
    public static List<Sobject> getRecords(String jsonData){
        Map<String, Object> root = (Map<String, Object>)JSON.deserializeUntyped(jsonData);
        String fields = (String)root.get(FIELDS_PARAM);
        Integer numberOfRecords = (Integer)root.get(NUMBER_OF_RECORDS_PARAM);
        String recordId = (String)root.get(RECORD_ID_PARAM);
        String relatedFieldApiName = (String)root.get(RELATED_FIELD_API_NAME_PARAM);
        String sobjectApiName = (String)root.get(SOBJECT_API_NAME_PARAM);
        String orderBy = (String)root.get(SORTED_BY_PARAM) + ' ' + (String)root.get(SORTED_DIRECTION_PARAM);
        
        String query = 'Select '+fields+' From '+sobjectApiName+' WHERE ' +relatedFieldApiName+ '= :recordId ORDER BY ' +orderBy+' Limit :numberOfRecords';
        return Database.query(String.escapeSingleQuotes(query));
    }
    
    // Util method to find relationship name
    private static String getParentRelationshipName(Id recordId, String parentSobjectName){
        Schema.DescribeSObjectResult descrRes = recordId.getSObjectType().getDescribe();
        String name;
        for (Schema.ChildRelationship cr: descrRes.getChildRelationships()){
            if(cr.getChildSObject().getDescribe().getName() == parentSobjectName){
                name = cr.getRelationshipName();
                break;
            }
        }
        return name;
    }
    
    // Use object describe to get the URL for the object tab icon
    @AuraEnabled
    public static String getIconName(String sobjectApiName){
        String iconName;
        List<Schema.DescribeTabSetResult> tabSetDesc = Schema.DescribeTabs();
        List<Schema.DescribeTabResult> tabDesc = new List<Schema.DescribeTabResult>();
        List<Schema.DescribeIconResult> iconDesc = new List<Schema.DescribeIconResult>();
        
        for(Schema.DescribeTabSetResult tsr : tabSetDesc) {
            tabDesc.addAll(tsr.getTabs());
        }
        
        for(Schema.DescribeTabResult tr : tabDesc) {
            if( sobjectApiName == tr.getSobjectName() ) {
                if( tr.isCustom() ) {
                    iconDesc.addAll(tr.getIcons());
                } else {
                    iconName = 'standard:' + sobjectApiName.toLowerCase();
                }
            }
        }
        for (Schema.DescribeIconResult ir : iconDesc) {
            if (ir.getContentType() == 'image/svg+xml'){
                iconName = 'custom:' + ir.getUrl().substringBetween('custom/','.svg').substringBefore('_');
                break;
            }
        }
        return iconName;
    }
}