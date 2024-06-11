public with sharing class JoobleAPIService {


    public static void postJoobleSearchRequest(String keywords, String location) {
        
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

            createJobApplicationListFromJson(response.getBody());
        } else {
            System.debug( response.getStatusCode() );
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


    // TODO: Create Job Application List ELSE update postJoobleSearchRequest to return response body and wire into LWC
    private static List<Job_Application__c> createJobApplicationListFromJson(String jsonResponse) {

        Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);
        List<Map<String, Object>> jobMap = (List<Map<String, Object>>) result.get('jobs');

        List<Job_Application__c> jobApplications = new List<Job_Application__c>();

        for( Map<String, Object> jobMapItem : jobMap) {
            Job_Application__c job = new Job_Application__c();
            job.Name = (String) jobMapItem.get('title');
            job.Status__c = (String) jobMapItem.get('status');
            job.Location__c = (String) jobMapItem.get('location');
            job.Position_Title__c = (String) jobMapItem.get('title');
            job.Salary__c = (Decimal) jobMapItem.get('salary');
            job.Description__c = (String) jobMapItem.get('snippet');
            job.URL__c = (String) jobMapItem.get('link');
            job.Notes__c = (String) jobMapItem.get('source');

            jobApplications.add(job);
        
        }

       

        // SAMPLE RETURNED JSON
        //  {
        //     "totalCount": 3,
        //     "jobs": [
        //         {
        //             "title": "CDL Independent Contractor",
        //             "location": "Baileyville, KS",
        //             "snippet": "&nbsp;...Owner Operators - Earn as much as $150,000/yr!\r\n As a 100% employee owned trucking company, we understand what it means to truly OWN <b>IT.</b> What's good for you is good for us. No one gives Owner Operators more support. When you partner with PTL, you won't compete with our...&nbsp;",
        //             "salary": "",
        //             "source": "j-vers.jn24-13",
        //             "type": "",
        //             "link": "https://jooble.org/away/-4510683636227621313?p=1&pos=1&cid=3505&ckey=it&jobAge=76&relb=175&brelb=115&scr=663.5437413043478&bscr=436.04303&aq=1290493540529646283&elckey=-7792926014217166103",
        //             "company": "Paschall Truck Lines, Inc.",
        //             "updated": "2024-06-07T14:36:08.0570000",
        //             "id": -4510683636227621313
        //         },
        //         {
        //             "title": "Retail Merchandiser",
        //             "location": "Pawnee City, NE",
        //             "snippet": "&nbsp;...wide-variety of clients/retailers for weekly, bi-weekly, and monthly visits. \r\n \r\n Let’s get started as an independent contractor  , <b>it’</b>s quick & easy;  CLICK APPLY  or text  SFSJOBS to 97211\r\n Things to Consider: \r\n You control when and how much you work \r\n Create your...&nbsp;",
        //             "salary": "",
        //             "source": "SPAR, Inc.",
        //             "type": "Temporary",
        //             "link": "https://jooble.org/desc/-5948660689118270713?ckey=it&rgn=17560&pos=2&groupId=39341&elckey=-7792926014217166103&p=1&aq=1290493540529646283&cid=3505&jobAge=259&relb=100&brelb=100&bscr=387.99484&scr=387.99484000000007",
        //             "company": "SPAR, Inc.",
        //             "updated": "2024-05-31T00:00:00.0000000",
        //             "id": -5948660689118270713
        //         },
        //         {
        //             "title": "Director of Finance",
        //             "location": "Pawnee City, NE",
        //             "snippet": "&nbsp;...maintains all appropriate records and reports applicable to the financial operation of the organization. \r\n•\tWorks collaboratively with <b>IT </b>to develop and maintain a plan for successful progression through Interoperability initiatives. \r\n•\tMaintains collegial and...&nbsp;",
        //             "salary": "",
        //             "source": "ninjagig.com",
        //             "type": "",
        //             "link": "https://jooble.org/desc/7290817825546820524?ckey=it&rgn=17560&pos=3&groupId=39341&elckey=-7792926014217166103&p=1&aq=1290493540529646283&cid=3505&jobAge=43&relb=100&brelb=100&bscr=346.2494&scr=346.2493999999999",
        //             "company": "Pawnee County Memorial Hospital/Rural Health Clinic",
        //             "updated": "2024-06-09T00:00:00.0000000",
        //             "id": 7290817825546820524
        //         }
        //     ]
        // }

        return jobApplications;
    }

}
