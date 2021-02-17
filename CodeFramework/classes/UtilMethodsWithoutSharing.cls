/**
* @author       Jerun Jose Stanley @ Cloudwerx
* @description  General purpose Util class for triggers and other apex classes with no access rules enforced.
*				This class is tested by various other classes that invoke each util function
*/
public class UtilMethodsWithoutSharing {
    public static void upsertRecords(list<SObject> recordsList){
        upsert recordsList;
    }
    
    public static void deleteRecords(list<SObject> recordsList){
        delete recordsList;
    }
    
    public static void updateOpportunityRecord(Opportunity opty){
        update opty;
    }
}