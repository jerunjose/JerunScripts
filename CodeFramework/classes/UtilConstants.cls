/**
* @author       Jerun Jose Stanley @ Cloudwerx
* @description  Utility class to hold constants that are used across the application.
*/
public without sharing class UtilConstants{
    public static Id apiUserId{
        get{
            if(apiUserId == null)
                apiUserId = [SELECT Id FROM User where IsActive = true AND Profile.Name = 'Integration Service' LIMIT 1].Id;
            return apiUserId;
        }
        set;
    }

    public static Id hubspotUserId{
        get{
            if(hubspotUserId == null)
                hubspotUserId = [SELECT Id FROM User where IsActive = true AND Profile.Name = 'Hubspot' LIMIT 1].Id;
            return hubspotUserId;
        }
        set;
    }

    public UtilConstants(){
        this.FIELD_LABELS = new map<String, map<String, String>>();
        addObjectFieldsToMap(Schema.SObjectType.Account);
    }

    public void addObjectFieldsToMap(Schema.DescribeSObjectResult objDesc){
        map<String, String> fldLabels = new map<String, String>();
        for(Schema.SObjectField fld : objDesc.fields.getMap().Values()){
            Schema.DescribeFieldResult fldDesc = fld.getDescribe();
            fldLabels.put(fldDesc.getName(), fldDesc.getLabel());
        }
        this.FIELD_LABELS.put(objDesc.getName(), fldLabels);
    }

    // Object Field labels
    @AuraEnabled public final map<String, map<String, String>> FIELD_LABELS;

    // Generic String values
    @AuraEnabled public final String UNEXPECTED_EXCEPTION = 'An unexpected error occurred';
    
    @AuraEnabled public final String LIT_APP_NAME = 'Salesforce';
    @AuraEnabled public final String LIT_ERROR_CODE_EXCEPTION = 'Exception';
    @AuraEnabled public final String LIT_SEVERITY_ERROR = 'Error';
}