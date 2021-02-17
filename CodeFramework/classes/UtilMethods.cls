/**
* @author       Jerun Jose Stanley @ Cloudwerx
* @description  General purpose Util class for triggers and other apex classes
*				This class is tested by various other classes that invoke each util function
*/
public class UtilMethods {
    // Variable used to hold all constants and static values - Referenced in code and components
    public static UtilConstants consts;
    // Variable used to hold the Apex Configuration custom metadata - Referenced in code and components
    public static map<String, Apex_Configuration__mdt> apexConfigMap = new map<String, Apex_Configuration__mdt>();
    // Variabl to control switch logic for logic elements
    // To disable a functionality use the below format.
    // UtilMethods.codeKillSwitch.Account_method1 = true;
    public static Code_Kill_Switch__c codeKillSwitch;
    // Internal variable which holds the API name for the fields in the Trigger Flags setting
    private static map<Schema.SObjectField, String> killSwitchAPIMap;
    
    // Static block to initialise variables
    static{
        consts = new UtilConstants();
        populateApexConfigMap();
        findTriggerFlagValues();
    }
    
    // Method to retrive and populate the custom metadata values configured
    private static void populateApexConfigMap(){
        UtilMethods.apexConfigMap = new map<String, Apex_Configuration__mdt>();
        for(Apex_Configuration__mdt setting : [SELECT DeveloperName, Text_Value__c, Text_Area_Value__c, Number_Value__c, Date_Value__c, DateTime_Value__c, Boolean_Value__c FROM Apex_Configuration__mdt]){
            UtilMethods.apexConfigMap.put(setting.DeveloperName, setting);
        }
    }
    
    // Method to retrieve the trigger flags from custom settings configured
    private static void findTriggerFlagValues(){
        codeKillSwitch = Code_Kill_Switch__c.getInstance();
        killSwitchAPIMap = new map<Schema.SObjectField, String>();
        Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Code_Kill_Switch__c.fields.getMap();
        for(String key : fieldMap.KeySet()){
            killSwitchAPIMap.put(fieldMap.get(key), key);
        }
    }
    
    // Util method to detect if a method has been disabled using the configuration
    // This method will be called by all trigger handlers
    public static Boolean checkIfMethodEnabled(Schema.SObjectField flagField){
        String fieldAPIName = killSwitchAPIMap.get(flagField);
        Object flagSet = codeKillSwitch.get(fieldAPIName);
        if(flagSet == null)
            return true;
        else
            return !(Boolean)flagSet;
    }
    
    public static set<String> getPickListValuesOfField(Schema.SObjectField fieldToken){
        set<String> pickListValuesList= new set<String>();
        Schema.DescribeFieldResult fieldResult = fieldToken.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
        }
        return pickListValuesList;
    }
    
    public static String getRecordURL(Id recordId, String objAPIName, Boolean isCommunity){
        if(isCommunity)
            return '/s/detail/'+recordId;
        else
            return '/lightning/r/'+objAPIName+'/'+recordId+'/view';
    }
    
    public static void flagErrorOnTriggerRecords(DMLException ex){
        list<SObject> errorList = Trigger.isDelete ? trigger.old : trigger.new;
        for(SObject so : errorList)
            so.addError(ex.getDmlMessage(0));
    }
    
    public static boolean checkRecordEditAccess(Id recordId){
        boolean hasAccess = false;
        for(UserRecordAccess urAcc : [SELECT RecordId, HasEditAccess FROM UserRecordAccess WHERE UserId =: UserInfo.getUserId() AND RecordId =: recordId]){
            hasAccess = urAcc.HasEditAccess;
        }
        
        return hasAccess;
    }
}