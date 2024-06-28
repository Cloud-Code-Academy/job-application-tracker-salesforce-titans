public with sharing class ErrorLogUtility {
    
    
    public static void logError(Exception e){

        ErrorLog__c errorLog = createErrorLog(e);
        insert as System errorLog;

    }


    private static ErrorLog__c createErrorLog(Exception e){

        ErrorLog__c errorLog = new ErrorLog__c();
        errorLog.ExceptionMessage__c = e.getMessage();
        errorLog.ExceptionType__c = e.getTypeName();
        errorLog.LineNumber__c = e.getLineNumber();
        String stackTrace = e.getStackTraceString();
        errorLog.StackTrace__c = stackTrace;
        errorLog.ClassName__c = stackTrace.substringAfter('.').substringBefore('.'); 
        errorLog.MethodName__c = stackTrace.substringBefore(':').substringAfter(errorLog.ClassName__c).substringAfter('.');

        return errorLog;

    }
}