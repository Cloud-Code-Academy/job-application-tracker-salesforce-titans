/**
 * Apex Class: JoobleAPIService
 * Description: This class makes a callout to the Jooble API to retrieve job postings based on given keywords and location. 
 * Created to be used in conjunction with the joobleJobSearch lwc
 * Created Date: 2024-06-10
 * Last Modified: 2024-07-01
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

		    if(response.getStatusCode() >= 200 || response.getStatusCode() <= 299){
                return response.getBody();
            } else {
                return null;
            }

        } catch (Exception e) {
            ErrorLogUtility.logError(e);
            return null;
        }
    }
	
    // Creates the request body for the callout based on keywords and location parameters
    // input by user from the joobleJobSearch lwc
    private static String createRequestBody(String keywords, String location) {

        String payload = '';

        try{
            Map<String, Object> jsonMap = new Map<String, Object>();
            jsonMap.put('keywords', keywords);
            jsonMap.put('location', location);

            payload = JSON.Serialize(jsonMap);

        } catch(Exception e){
            ErrorLogUtility.logError(e);
        }
        
        return payload;

    }

}