/**
* @author       Jerun Jose Stanley @ Cloudwerx
* @description  Class to allow child classes to be passed as arguments or response in lightning compoenent along with constants
*				Use the LightningInnerClass virtual class if you do not need the constants to be passed in the response.
*/
public virtual class LightningComponentResponse {
    @AuraEnabled public UtilConstants utilConst{get; private set;}
    @AuraEnabled public map<String, Apex_Configuration__mdt> apexConfigMap{get; private set;}
    
    public LightningComponentResponse(){
        utilConst = UtilMethods.consts;
        apexConfigMap = UtilMethods.apexConfigMap;
    }
}