Id recordId = '00120000012PKJvAAO';

Schema.DescribeSObjectResult R = recordId.getSObjectType().getDescribe();
List<Schema.ChildRelationship> C = R.getChildRelationships();
system.debug(c.size());

Integer startInt = 0;
integer endInt = 250;

endInt  = math.min(endInt, c.size());

string results = '\n';
for(Integer i = startInt; startInt < endInt; startInt++){
    Schema.ChildRelationship c1 = c[startInt];
    DescribeSObjectResult drs = c1.getChildSObject().getDescribe();
    if(drs.isQueryable() && drs.isAccessible()){
        String childObj = drs.getName();
        DescribeFieldResult dfs = c1.getField().getDescribe();
        if(dfs.isAccessible() && dfs.isFilterable()){
            String childField = dfs.getName();
            try{
                String query = 'SELECT id from '+childObj+' WHERE '+childField+' = \''+recordId+'\'';
                list<SObject> recList = database.query(query);
                Integer count = recList.size();
                if(count > 0){
                    results += query + ' with size of '+ String.valueOf(count) + '\n';
                }
            }catch(Exception ex){
                system.debug(ex);
            }
        }
    }
}
system.debug(results);
