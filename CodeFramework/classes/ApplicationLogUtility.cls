/**
* @author       Jerun Jose Stanley
* @description  Utility class for the Application Log
*/
public without sharing class ApplicationLogUtility implements Queueable {
    private Exception ex;
    private String errorCode;
    private String severityType;

    public ApplicationLogUtility(Exception ex, String errorCode, String severityType){
        this.ex = ex;
        this.errorCode = errorCode;
        this.severityType = severityType;
    }

    public void execute(QueueableContext context){
        ApplicationLogUtility.createLogException(ex, errorCode, severityType, false);
    }

    public static final Integer ERROR_DESCRIPTION_LENGTH = 32768;
    public static final Integer EXCEPTION_REASON_LENGTH = 255;

    public static LightningResponseWrapper createLogException(Exception ex, String errorCode, String severityType, Boolean skipForDMLException){
        LightningResponseWrapper.ExceptionResponseWrapper exceptionWrapper = new LightningResponseWrapper.ExceptionResponseWrapper();
        LightningResponseWrapper reponseWrapper = new LightningResponseWrapper();
        reponseWrapper.exceptionRespObj = exceptionWrapper;
        reponseWrapper.isException = true;

        exceptionWrapper.title = UtilMethods.consts.UNEXPECTED_EXCEPTION;
        exceptionWrapper.severity = severityType;

        if(skipForDMLException && ex instanceof DMLException){
            exceptionWrapper.message = ex.getDmlMessage(0);
            String validationMessage = findValidationMessage(exceptionWrapper.message);
            if(validationMessage != null){
                exceptionWrapper.message = validationMessage;
            }
            exceptionWrapper.skipDatabaseLogging = true;
            exceptionWrapper.type = string.valueOf(ex.getDmlType(0));            
        }

        if(!exceptionWrapper.skipDatabaseLogging){
            String logNumber = logExceptionToRecord(errorCode, ex, new Application_Log__c());
            exceptionWrapper.logNum = logNumber;
            exceptionWrapper.message = 'Please contact system administrator for assistance. Use the reference number '+exceptionWrapper.logNum+' on your communications with the administrator.';
        }

        return reponseWrapper;
    }

    public static String findValidationMessage(String exceptionMessage){
        String validationMessage;
        // To check if this is a validation rule error thrown by some other apex code.
        String keyWord = 'FIELD_CUSTOM_VALIDATION_EXCEPTION';
        if(exceptionMessage.containsIgnoreCase(keyWord)){
            Integer startPos = exceptionMessage.indexOf(keyWord);
            String rightPart = exceptionMessage.substring(startPos + keyWord.length() + 2, exceptionMessage.length());
            Integer endPos = rightPart.indexOf('.');
            String messagePart = rightPart.substring(0, endPos);
            validationMessage = messagePart;
        }
        return validationMessage;
    }
    
    public static LightningResponseWrapper createLogException(Exception ex, String errorCode, String severityType){
        return ApplicationLogUtility.createLogException(ex, errorCode, severityType, true);
    }

    public static String logExceptionToRecord(String errorCode, Exception ex, Application_Log__c log){
        String exceptionMessage = ex.getMessage();
        String Stacktrace = ex.getStackTraceString();
        String traceFirstLine = Stacktrace.substringAfter('\n');

        mapLogFields(traceFirstLine, exceptionMessage, Stacktrace, errorCode, log);
        return insertLogRecord(log);
    }

    public static void mapLogFields(String traceFirstLine, String errorMessage, String errorDescription, String errorCode, Application_Log__c log){
        if(errorMessage.length() > EXCEPTION_REASON_LENGTH){
            errorMessage = errorMessage.substring(0,EXCEPTION_REASON_LENGTH);
        }
        if(errorDescription.length() > ERROR_DESCRIPTION_LENGTH){
            errorDescription = errorDescription.substring(0,ERROR_DESCRIPTION_LENGTH);
        }

        log.Class_Name__c = getClassName(traceFirstLine);
        log.Method_Name__c = getMethod(traceFirstLine);
        log.Application_Name__c = UtilMethods.consts.LIT_APP_NAME;
        log.Error_Code__c = errorCode;
        log.Error_Description__c = errorDescription;
        log.Exception_Reason__c = errorMessage;
    }

    public static String insertLogRecord(Application_Log__c log){
        String logNumber;
        if(log.Id == null){
            insert log;
            logNumber = [select Id, Name from Application_Log__c where id =: log.id].Name;
        }else{
            logNumber = log.Name;
        }
        return logNumber;
    }

    public static String createLogWarning(String traceFirstLine, String errorMessage, String errorDescription){
        Application_Log__c log = new Application_Log__c();
        mapLogFields(traceFirstLine, errorMessage, errorDescription, 'Warning', log);
        return insertLogRecord(log);
    }

    //https://salesforce.stackexchange.com/questions/153835/get-currently-executing-class-method-name
    public static String getClassName(String line){
        if (line.startsWith('Class.'))
            line = line.substringAfter('Class.');
        return line.substringBefore(':').substringBeforeLast('.');
    }
    public static String getMethod(String line){
        return line.substringBefore(':').substringAfterLast('.');
    }
}