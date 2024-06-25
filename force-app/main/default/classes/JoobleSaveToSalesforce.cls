/**
 * Apex Class: JoobleSaveToSalesforce
 * Description: This class creates the appropriate Account and Job Application records based on the JSON data payload
 * returned from the joobleJobSearch lwc. 
 * Created Date: 2024-06-13
 * Last Modified: 2024-06-15
 */

public with sharing class JoobleSaveToSalesforce {

    // Process JSON payload of job records and save to Salesforce
    @AuraEnabled(cacheable=false)
    public static void saveToSalesforce(String payload) {

        try {

            List<Object> jobRecords = (List<Object>) JSON.deserializeUntyped(payload);

            // Parse JSON Data to create a map of Job Applications and Company Names
            Map<String, Job_Application__c> mapJoobleIdToJobApplication = new Map<String, Job_Application__c>();
            Map<String, String> mapJoobleIdToCompanyName = new Map<String, String>();
    
            for(Object record : jobRecords) {
                Map<String, Object> dataObject = (Map<String,Object>) record;

                Job_Application__c job = new Job_Application__c();
                Long joobleId = (Long) dataObject.get('id');
                String joobleIdString = String.valueOf(joobleId);
                String companyName = (String) dataObject.get('company');
                job.Name = (String) dataObject.get('title');
                job.Location__c = (String) dataObject.get('location');
                job.Position_Title__c = (String) dataObject.get('title');
                String salaryString = (String) dataObject.get('salary');
                job.Salary__c = String.isEmpty(salaryString) ? 0 : Decimal.valueOf(salaryString);
                job.Description__c = (String) dataObject.get('snippet');
                job.URL__c = (String) dataObject.get('link');
                String source = 'Source: ' + (String) dataObject.get('source');
                job.Notes__c = source;
                job.Status__c = 'Saved';
    
                mapJoobleIdToJobApplication.put(joobleIdString, job);
                mapJoobleIdToCompanyName.put(joobleIdString, companyName);
            }

            // Process Company Names 
            Map<String, Account> mapAccountNameToAccount = processCompanyNames(mapJoobleIdToCompanyName);

            // Create Map of JoobleId : Accounts 
            Map<String, Account> mapJoobleIdToAccount = new Map<String, Account>();
            for (String joobleIdString : mapJoobleIdToCompanyName.keySet()) {
                mapJoobleIdToAccount.put(joobleIdString, mapAccountNameToAccount.get(mapJoobleIdToCompanyName.get(joobleIdString)));
            }

            // Update Map of Jooble Id : Applications with Account Id from mapJoobleIdToAccount
            for(String joobleIdString : mapJoobleIdToJobApplication.keySet()) {
                mapJoobleIdToJobApplication.get(joobleIdString).Company_Name__c = mapJoobleIdToAccount.get(joobleIdString).Id;
            }

            // Insert Job Application records
            insert mapJoobleIdToJobApplication.values();

            } catch (Exception e) {

            System.debug('Error in saveToSalesforce: ' + e.getMessage());
            System.debug('Stack trace: ' + e.getStackTraceString());
            
        }
       
    }

    // Process Company Names and insert to Salesforce if needed
    private static Map<String, Account> processCompanyNames(Map<String, String> mapJoobleIdToCompanyName){

        Set<String> companyNames = new Set<String>(mapJoobleIdToCompanyName.values());  

        // Get existing accounts in Salesforce that match the Company Names
        List<Account> existingAccounts = [ 
            SELECT Id, Name
            FROM Account
            WHERE Name IN :companyNames
        ];

        // Create Map of Account Name : Account
        Map<String, Account> mapAccountNameToAccount = new Map<String, Account>();

        for(Account a : existingAccounts) {
            mapAccountNameToAccount.put(a.Name, a);
        }

        // Create Account record for Accounts that do not already exist in Salesforce
        List<Account> accountsToInsert = new List<Account>(); 

        for (String companyName : companyNames){
            if (!mapAccountNameToAccount.containsKey(companyName)) {
                Account newAccount = new Account(Name = companyName);
                accountsToInsert.add(newAccount);
                mapAccountNameToAccount.put(companyName, newAccount);
            }
        }
        // Insert Account records
        if(!accountsToInsert.isEmpty()){
            insert accountsToInsert;
        }

        return mapAccountNameToAccount;

    }

}