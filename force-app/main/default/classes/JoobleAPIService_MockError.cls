/**
 * Apex Class: JoobleAPIService_MockGenerator
 * Description: This class is used to test the JoobleAPIService class, creating mock data for testing.
 * Created Date: 2024-06-16
 * Last Modified: 2024-07-01
 */

 @isTest
 public with sharing class JoobleAPIService_MockError implements HttpCalloutMock {

    // Creates a mock HTTP response for POST request
    public HTTPResponse respond(HTTPRequest request) {
        
        HttpResponse response = new HttpResponse();
        
        if (request.getMethod() == 'POST') {
            response.setHeader('Content-Type', 'application/json');
            response.setStatusCode(404);
            response.setBody('{"error": "Not Found"}');
        } 
        
        return response;
    }

}