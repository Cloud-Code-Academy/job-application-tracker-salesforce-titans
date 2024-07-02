/**
 * Apex Class: JoobleAPIService_Test
 * Description: This class is used to test the JoobleAPIService class, used in tandem with the JoobleAPIService_MockGenerator
 * Created Date: 2024-06-16
 * Last Modified: 
 */

 @isTest
public with sharing class JoobleAPIService_Test {


    @isTest
    static void testPostJoobleSearchRequest_Positive(){


        Test.setMock(HttpCalloutMock.class, new JoobleAPIService_MockGenerator());

        String keywords = 'Developer';
        String location = 'Memphis, TN';

        Test.startTest();
            String response = JoobleAPIService.postJoobleSearchRequest(keywords, location);
        Test.stopTest();

        System.assert(response.contains('Developer'), 'The response should contain the keywords /"Developer/."');
        System.assert(response.contains('Memphis, TN'),'The response should contain the location /"Memphis, TN/"');

    }

    @isTest
    static void testPostJoobleSearchRequest_Negative(){

        Test.setMock(HttpCalloutMock.class, new JoobleAPIService_MockError());

        String keywords = 'Developer';
        String location = 'Memphis, TN';

        Test.startTest();
            String response = JoobleAPIService.postJoobleSearchRequest(keywords, location);
        Test.stopTest();

        System.assert(response == '{"error": "Not Found"}', 'Unsuccessful callout should return /"error/"');

    }
    

}