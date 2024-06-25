/**
 * Apex Class: JoobleAPIService_MockGenerator
 * Description: This class is used to test the JoobleAPIService class, creating mock data for testing.
 * Created Date: 2024-06-16
 * Last Modified: 
 */

public with sharing class JoobleAPIService_MockGenerator implements HttpCalloutMock {

    // Creates a mock HTTP response for POST request
    public HTTPResponse respond(HTTPRequest request) {
        
        HttpResponse response = new HttpResponse();
        
        if (request.getMethod() == 'POST') {
            response.setHeader('Content-Type', 'application/json');
            response.setStatusCode(200);
            response.setBody(
                '{"totalCount": 2,"jobs": [{"title": "Salesforce Developer","location": "Memphis, TN","snippet": "Keeping it cool","salary": "100,000","source": "Jooble website","type": "Full-time","link": "https://jooble.org", "company": "SF Consulting","updated": "2024-06-12T00:00:00.0000000","id": -3906237570091029095},{"title": "Jr Developer","location": "Memphis, TN","snippet": "maintains code base","salary": "70,000","source": "LinkedIn","type": "Full-time","link": "https://jooble.org","company": "Genius Consulting","updated": "2024-06-16T00:00:00.0000000","id": -3454369782349469392}]}'
            );
        } 
        
        return response;
    }

}