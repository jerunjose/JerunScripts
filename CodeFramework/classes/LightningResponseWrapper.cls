/**
* @author       Jerun Jose Stanley @ Cloudwerx
* @description  Generic wrapper class used on any lightning components
*/
public class LightningResponseWrapper{
    // Object when the transaction is successful
    @auraEnabled public Object successRespObj;
    // Object when the transaction ran into an exception
    @auraEnabled public ExceptionResponseWrapper exceptionRespObj = new ExceptionResponseWrapper();
    // A Boolean flag to test if an exception occurred
    @auraEnabled public boolean isException = false;
    
    // Wrapper class to hold details of the exception
    public class ExceptionResponseWrapper{
        @auraEnabled public string title;
        @auraEnabled public string message;
        @auraEnabled public string logNum;
        @auraEnabled public string severity;
        @auraEnabled public boolean skipDatabaseLogging = false;
        @auraEnabled public string type;
    }
}