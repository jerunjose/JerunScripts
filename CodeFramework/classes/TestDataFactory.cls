/**
* @author       Jerun Jose Stanley @ Cloudwerx
* @description  General purpose Util class for triggers and other apex classes with no access rules enforced.
*				This class is tested by various other classes that invoke each util function
*/
@isTest
public class TestDataFactory{
    public static Id businessAccountRTID{
        get{
            if(businessAccountRTID == null)
                businessAccountRTID = [SELECT Id FROM RecordType WHERE SObjectType='Account' AND IsPersonType=false LIMIT 1].Id;
            return businessAccountRTID;
        }
        set;
    }
    
    public static Id personAccountRTID{
        get{
            if(personAccountRTID == null)
                personAccountRTID = [SELECT Id FROM RecordType WHERE IsPersonType=true LIMIT 1].Id;
            return personAccountRTID;
        }
        set;
    }
    
    public static User genSysAdminUser(String userName, String alias){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator' limit 1];
        User adminUser = new User(Alias = alias, Email=userName, EmailEncodingKey='UTF-8', 
                                  LastName='AdminTest', LanguageLocaleKey='en_US',LocaleSidKey='en_US', 
                                  ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', 
                                  UserName=userName);
        return adminUser;
    }
    
    public static User genBusinessUser(String userName, String alias, Id profileId){
        User intUser = new User(Alias = alias, Email=userName, EmailEncodingKey='UTF-8', 
                                LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US', 
                                ProfileId = profileId, TimeZoneSidKey='America/Los_Angeles', 
                                UserName=userName
                               );
        return intUser;
    }

    public static Account genAccountRecord(Boolean isPersonAccount){
        Account acc = new Account();
        acc.ShippingStreet = '13 Darlinghurst Road';
        acc.ShippingCity = 'Potts Point';
        acc.ShippingState = 'NSW';
        acc.ShippingPostalCode = '2011';
        acc.ShippingCountry = 'Australia';
        if(isPersonAccount){
            acc.RecordTypeId = TestDataFactory.personAccountRTID;
            acc.FirstName = 'Sample FN';
            acc.LastName = 'Sample LN';
        }else{
            acc.RecordTypeId = TestDataFactory.businessAccountRTID;
            acc.Name = 'Sample account';
        }
        return acc;
    }
    
    public static Contact genContactRecord(){
        Contact cont = new Contact();
        cont.Salutation = 'Mr';
        cont.FirstName = 'Sample';
        cont.LastName = 'Contact';
        cont.Email = 'sampleContact@example.com';
        cont.MailingStreet = '13 Darlinghurst Road';
        cont.MailingCity = 'Potts Point';
        cont.MailingState = 'NSW';
        cont.MailingPostalCode = '2011';
        cont.MailingCountry = 'Australia';
        cont.Phone = '0';
        return cont;
    }
    
    public static Lead genLeadRecord(){
        Lead ld = new Lead();
        ld.FirstName = 'sample FN';
        ld.LastName = 'sample LN';
        ld.Email = 'sample@domain.com';
        ld.State = 'NSW';
        return ld;
    }
    
    public static Opportunity genOpportunityRecord(){
        Opportunity opp = new Opportunity();
        opp.Name = 'test opportunity';
        opp.StageName = 'Reserved';
        opp.CloseDate = system.today().addDays(365);
        return opp;
    }
    
    public static Task genTask(){
        Task tsk = new Task();
        tsk.Status = 'Completed';
        tsk.ActivityDate = system.today();
        tsk.Type = 'Call';
        tsk.Subject = 'Follow-up';
        return tsk;
    }
}