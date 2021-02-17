/**
* @author       Jerun Jose Stanley @ Cloudwerx
* @description  Controller class for the Single File Upload aura component
*/
public class SingleFileUploadController {
	public class SingleFileParams extends LightningInnerClass{
        @AuraEnabled public String fileName {get; set;}
        @AuraEnabled public Id fileDocumentId {get; set;}
        @AuraEnabled public String fileUploadedDate {get; set;}
        @AuraEnabled public String fileUploadedBy {get; set;}
    }

    //Method to delete the file being shown
    @AuraEnabled
    public static LightningResponseWrapper deleteContentDocument(ID contentDocumentId){
        LightningResponseWrapper reponseWrapper = new LightningResponseWrapper();
        try{
            ContentDocument cd = new ContentDocument(id = contentDocumentId);
            delete cd;
            Boolean response = true;
            reponseWrapper.successRespObj = (object)response;
        }
        catch(Exception ex){
            reponseWrapper = ApplicationLogUtility.createLogException(ex, UtilMethods.consts.LIT_ERROR_CODE_EXCEPTION, UtilMethods.consts.LIT_SEVERITY_ERROR);
        }
        return reponseWrapper;
    }
}