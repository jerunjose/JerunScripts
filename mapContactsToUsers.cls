list<Contact> contList = [SELECT Id, Email FROM Contact WHERE RecordType.Name = 'Ironfish Contact Record Type' AND Email != null AND CRM_User_Account__c = null];
set<String> emails = new set<String>();
String emailSuffix = '.invalid';
for(Contact cont : contList){
    emails.add(cont.Email);
    emails.add(cont.Email+emailSuffix);
}
map<String, Id> EmailToUserIdMap = new map<String, Id>();
list<User> usersList = [SELECT Id, Email FROM User where Email IN :emails];
for(User usr : usersList){
    EmailToUserIdMap.put(usr.Email, usr.Id);
}
for(Contact cont : contList){
    cont.CRM_User_Account__c = EmailToUserIdMap.get(cont.Email);
    if(cont.CRM_User_Account__c == null){
      cont.CRM_User_Account__c = EmailToUserIdMap.get(cont.Email+emailSuffix);
    }
}
list<Database.SaveResult> srs = Database.update(contList, false);
system.debug(srs);
