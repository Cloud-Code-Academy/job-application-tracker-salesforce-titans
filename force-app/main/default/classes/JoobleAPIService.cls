/**
 * Apex Class: JoobleAPIService
 * Description: This class makes a callout to the Jooble API to retrieve job postings based on given keywords and location. 
 * Created to be used in conjunction with the joobleJobSearch lwc
 * Created Date: 2024-06-10
 * Last Modified: 2024-06-15
 */

public with sharing class JoobleAPIService {


    // Makes callout to the Jooble API (see related Named / External Credential). 
    //If successful, returns the response body.
    @AuraEnabled(cacheable=true)
    public static String postJoobleSearchRequest(String keywords, String location) {
        
        HttpRequest request = new HttpRequest();
		request.setEndpoint('callout:JoobleAPI');
		request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setBody(createRequestBody(keywords, location));
	
        Http http = new Http();
        HttpResponse response;

        try {
            response = http.send(request);
        } catch (Exception e) {
            System.debug('Error making HTTP request: ' + e.getMessage());
        }

		if(response.getStatusCode() >= 200 || response.getStatusCode() <= 299){
            System.debug('Response Status: ' + response.getStatus());
            System.debug('Response Body: ' + response.getBody());

            return response.getBody();

        } else {
            System.debug(response.getStatusCode() );
            return response.getBody();
        }
    }
	
    // Creates the request body for the callout based on keywords and location parameters
    // input by user from the joobleJobSearch lwc
    private static String createRequestBody(String keywords, String location) {

        Map<String, Object> jsonMap = new Map<String, Object>();
        jsonMap.put('keywords', keywords);
        jsonMap.put('location', location);

        String payload = JSON.Serialize(jsonMap);
        System.debug(payload);

        return payload;

    }

}