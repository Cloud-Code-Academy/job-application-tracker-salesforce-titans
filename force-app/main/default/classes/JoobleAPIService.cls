public with sharing class JoobleAPIService {


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

            // createJobApplicationListFromJson(response.getBody());
        } else {
            System.debug( response.getStatusCode() );
            return 'No jobs found';
        }

    }
		
    private static String createRequestBody(String keywords, String location) {

        Map<String, Object> jsonMap = new Map<String, Object>();
        jsonMap.put('keywords', keywords);
        jsonMap.put('location', location);

        String payload = JSON.Serialize(jsonMap);
        System.debug(payload);

        return payload;

    }

}
