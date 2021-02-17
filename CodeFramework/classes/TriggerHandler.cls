/**
* @author       Jerun Jose Stanley @ Cloudwerx
* @description  Generic Triggerhandler to dispatch trigger event actions
*/
public abstract class TriggerHandler implements TriggerManager.ITriggerHandler {
    
    public virtual void onBeforeInsert(List<sObject> newRecords) {}
    
    public virtual void onBeforeUpdate(List<SObject> oldRecords, List<SObject> newRecords, Map<ID, SObject> oldRecordsMap, Map<ID, SObject> newRecordsMap) {}
    
    public virtual void onBeforeDelete(List<sObject> oldRecords, Map<ID, sObject> oldRecordsMap) {}
    
    public virtual void onAfterInsert(List<sObject> newRecords, Map<ID, sObject> newRecordsMap) {}
    
    public virtual void onAfterUpdate(List<sObject> oldRecords, List<sObject> newRecords, Map<ID, sObject> oldRecordsMap, Map<ID, sObject> newRecordsMap) {}
    
    public virtual void onAfterDelete(List<sObject> oldRecords, Map<ID, sObject> oldRecordsMap) {}
    
    public virtual void onAfterUndelete(List<sObject> newRecords, Map<ID, sObject> newRecordsMap) {}

    @TestVisible
    private virtual void invoke(List<SObject> newRecords,
                               List<SObject> oldRecords,
                               Map<ID, sObject> newRecordsMap,
                               Map<ID, sObject> oldRecordsMap,
                               boolean isBefore,
                               boolean isAfter,
                               boolean isInsert,
                               boolean isUpdate,
                               boolean isDelete,
                               boolean isUndelete) {
        if(isBefore)
        {
            if(isInsert) onBeforeInsert(newRecords);
            else if(isUpdate) onBeforeUpdate(oldRecords, newRecords, oldRecordsMap, newRecordsMap);
            else if(isDelete) onBeforeDelete(oldRecords, oldRecordsMap);
        }
        else if(isAfter)
        {
            if(isInsert) onAfterInsert(newRecords, newRecordsMap);
            else if(isUpdate) onAfterUpdate(oldRecords, newRecords, oldRecordsMap, newRecordsMap);
            else if(isDelete) onAfterDelete(oldRecords, oldRecordsMap);
            else if(isUndelete) onAfterUndelete(newRecords, newRecordsMap);
        }
    }
    
    public virtual void invoke() {
        invoke(Trigger.new,
               Trigger.old,
               Trigger.newMap, 
               Trigger.oldMap, 
               Trigger.isBefore,
               Trigger.isAfter, 
               Trigger.isInsert, 
               Trigger.isUpdate, 
               Trigger.isDelete, 
               Trigger.isUndelete);
    }
}