/**
 * Apex Class: ErrorLogUtility_Mock
 * Description: This class creates mock exceptions used for testing the ErrorLogUtility class
 * Created Date: 2024-06-27
 * Last Modified: 2024-07-01
 */


@isTest
public class ErrorLogUtility_Mock {
 
    public static Exception catchException(){

        Exception testException;
        
        try{
           integer i = 1/0;    
        }
        catch(Exception e){
            testException = e;
        }

        return testException;

    }
    

    public static Exception noException(){

        Exception testException;
        try{
            String test = 'Hello, no exceptions today';
        } catch(Exception e){
            testException = e;
        }

        return testException;
        
    }
}