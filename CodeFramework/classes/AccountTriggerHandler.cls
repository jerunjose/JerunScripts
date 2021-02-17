/**
* @author       Jerun Jose Stanley @ Cloudwerx
* @description  Trigger handler for the Account object
*/
public class AccountTriggerHandler extends TriggerHandler{
    
    public override void onBeforeInsert(List<sObject> newRecords){
        if(UtilMethods.checkIfMethodEnabled(Code_Kill_Switch__c.Account_someRandomMethod__c))
        	someRandomMethod((List<Account>) newRecords, null);
    }
    
    private void someRandomMethod(List<Account> newRecords, Map<ID, Account> oldRecordsMap){
        String someConfigString = UtilMethods.apexConfigMap.get('someConfigString').Text_Value__c;
        UtilMethods.codeKillSwitch.Account_someRandomMethod__c = true;
    }
}