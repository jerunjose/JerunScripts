/**
* @author       Jerun Jose Stanley @ Cloudwerx
* @description  Manager to define trigger handler interface and dispatch trigger actions
*/
public class TriggerManager {
    
    public interface ITriggerHandler {
        void onBeforeInsert(List<sObject> newRecords);
        
        void onBeforeUpdate(List<SObject> oldRecords, List<SObject> newRecords, Map<ID, SObject> oldRecordsMap, Map<ID, SObject> newRecordsMap);
        
        void onBeforeDelete(List<sObject> oldRecords, Map<ID, sObject> oldRecordsMap);
        
        void onAfterInsert(List<sObject> newRecords, Map<ID, sObject> newRecordsMap);
        
        void onAfterUpdate(List<sObject> oldRecords, List<sObject> newRecords, Map<ID, sObject> oldRecordsMap, Map<ID, sObject> newRecordsMap);
        
        void onAfterDelete(List<sObject> oldRecords, Map<ID, sObject> oldRecordsMap);
        
        void onAfterUndelete(List<sObject> newRecords, Map<ID, sObject> newRecordsMap);
        
        void invoke();
    }
    
    /**
* @description  Invoke trigger handler by type 
*               Usage: in trigger make call like  TriggerManager.invoke(AccountTriggerHandler.class);
*/
    public static void invoke(Type type) {
        
        Object handler = type.newInstance();
        if (handler instanceof ITriggerHandler) {
            ((ITriggerHandler) handler).invoke();
        }
        else {
            system.debug(LoggingLevel.ERROR, type + ' type doesn\'t extend TriggerHandler interface');
            throw new UnsupportedTriggerHandlerException('Custom Trigger Handler must extend TriggerHandler abstract class');
        }        
    }
    
    public class UnsupportedTriggerHandlerException extends Exception {}
}