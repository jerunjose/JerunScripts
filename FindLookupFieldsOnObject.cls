set<String> objectsToCheck = new set<String>();
objectsToCheck.add('User');
objectsToCheck.add('Account');
objectsToCheck.add('Opportunity');
objectsToCheck.add('Contact');
objectsToCheck.add('Project_1__c');
objectsToCheck.add('Property__c');
objectsToCheck.add('Branch_Project_Assignment__c');
objectsToCheck.add('Property_Assignment__c');
objectsToCheck.add('Staff_Assignment__c');
objectsToCheck.add('Task');
objectsToCheck.add('Event');

Map<String, Schema.SObjectType> gdMap = Schema.getGlobalDescribe();
String fieldsList = '';
fieldsList += 'Object,field,reference object\n';
for(String objName : objectsToCheck){
    Schema.Describesobjectresult dsr = gdMap.get(objName).getDescribe();
    Map<String, Schema.SObjectField> fieldMap = dsr.fields.getMap();
    for(Schema.SObjectField fld : fieldMap.Values()){
        Schema.DescribeFieldResult dfr = fld.getDescribe();
        if(dfr.getType() == Schema.DisplayType.Reference){
            for(Schema.SObjectType reference : dfr.getReferenceTo()){
                fieldsList += objName+','+dfr.getName()+','+reference.getDescribe().getName()+'\n';
            }
        }
    }
}
system.debug(fieldsList);
