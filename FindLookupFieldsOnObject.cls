set<String> objectsToCheck = new set<String>();
objectsToCheck.add('Account');

Map<String, Schema.SObjectType> gdMap = Schema.getGlobalDescribe();
String fieldsList = '';
for(String objName : objectsToCheck){
    Schema.Describesobjectresult dsr = gdMap.get(objName).getDescribe();
    Map<String, Schema.SObjectField> fieldMap = dsr.fields.getMap();
    for(Schema.SObjectField fld : fieldMap.Values()){
        Schema.DescribeFieldResult dfr = fld.getDescribe();
        if(dfr.getType() == Schema.DisplayType.Reference){
            for(Schema.SObjectType reference : dfr.getReferenceTo()){
                fieldsList += 'Object '+objName+' has field '+dfr.getName()+' with reference to '+reference.getDescribe().getName()+'\n';
            }
        }
    }
}
system.debug(fieldsList);
