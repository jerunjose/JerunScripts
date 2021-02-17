/**
* @author       Jerun Jose Stanley @ Cloudwerx
* @description  Primitive trigger for the Account object
*/
trigger AccountTrigger on Account (before insert, after insert, before update, after update, before delete, after delete) {
    TriggerManager.invoke(AccountTriggerHandler.class);
}