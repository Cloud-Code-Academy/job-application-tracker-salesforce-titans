@isTest
public with sharing class ErrorLogUtility_Test {
    
    @isTest
    static void testLogError_Positive(){
        
        Exception e = ErrorLogUtility_Mock.catchException();

        Test.startTest();
            ErrorLogUtility.logError(e);
        Test.stopTest();

        List<ErrorLog__c> testErrorLog = [ 
            SELECT Id, ExceptionMessage__c, StackTrace__c, ClassName__c, MethodName__c, ExceptionType__c, LineNumber__c 
            FROM ErrorLog__c
        ];

        System.assertEquals(1, testErrorLog.size(), 'Expected one test error log record created');
        System.assertEquals(
            'Divide by 0', 
            testErrorLog[0].ExceptionMessage__c, 
            'Expected test error log message to be /"Divide by 0/"'
        );
        System.assert(
            testErrorLog[0].StackTrace__c.contains('Class.ErrorLogUtility_Mock.catchException: line 9, column 1'),
            'Expected different test error log stack trace'
        );
        System.assertEquals(
            'ErrorLogUtility_Mock',
            testErrorLog[0].ClassName__c,
            'Expected different test error log class name'
        );
        System.assertEquals(
            'catchException',
            testErrorLog[0].MethodName__c,
            'Expected different test error log method name'
        );
        System.assertEquals(
            'System.MathException',
            testErrorLog[0].ExceptionType__c,
            'Expected /"System.MathException/" for error type name'
        );
        System.assertEquals(
            9,
            testErrorLog[0].LineNumber__c,
            'Expected a different line number on test error log'
        );
    
    }

    @isTest
    static void testLogError_Negative(){

        Exception e = ErrorLogUtility_Mock.noException();

        Test.startTest();
        try{
            ErrorLogUtility.logError(e);
        }catch(Exception error){
            System.assertEquals(
                'System.NullPointerException', 
                error.getTypeName(), 
                'Expected a null pointer exception but did not get one'
            );
        }
            
        Test.stopTest();

        List<ErrorLog__c> testErrorLog = [ 
            SELECT Id, ExceptionMessage__c, StackTrace__c, ClassName__c, MethodName__c, ExceptionType__c, LineNumber__c 
            FROM ErrorLog__c
        ];

        System.assertEquals(0, testErrorLog.size(), 'No error log record should be inserted');

    }



}