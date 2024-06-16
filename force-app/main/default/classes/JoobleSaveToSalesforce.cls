
public with sharing class JoobleSaveToSalesforce {

    @AuraEnabled(cacheable=false)
    public static void saveToSalesforce(String payload) {

        try {

            System.debug('*** INSIDE SAVE TO SALESFORCE');
            System.debug('*** Retrieved rows: ' + payload);

            List<Object> jobRecords = (List<Object>) JSON.deserializeUntyped(payload);
            System.debug('*** jobMAP' + jobRecords);

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
                job.Notes__c = (String) dataObject.get('source');
                job.Status__c = 'Saved';
    
                mapJoobleIdToJobApplication.put(joobleIdString, job);
                mapJoobleIdToCompanyName.put(joobleIdString, companyName);
            }


            System.debug('*** mapJoobleIdToJobApplication: '+ mapJoobleIdToJobApplication);
            System.debug('*** mapJoobleIdToCompanyName: '+ mapJoobleIdToCompanyName);

            // Process Company Names and insert to Salesforce if needed
            Set<String> companyNames = new Set<String>(mapJoobleIdToCompanyName.values());  

            System.debug('*** companyNames: '+ companyNames);
             
            // Get existing accounts in Salesforce that match company names
            List<Account> existingAccounts = [ 
                SELECT Id, Name
                FROM Account
                WHERE Name IN :companyNames
            ];

            System.debug('*** existingAccounts: '+ existingAccounts);

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

            System.debug('*** accounts to insert: '+ accountsToInsert);
            System.debug('*** accounts map name to account AFTER INSERT OPERATION: '+ mapAccountNameToAccount);


            // Create Map of JoobleId : Accounts 
            Map<String, Account> mapJoobleIdToAccount = new Map<String, Account>();
            for (String joobleIdString : mapJoobleIdToCompanyName.keySet()) {
                mapJoobleIdToAccount.put(joobleIdString, mapAccountNameToAccount.get(mapJoobleIdToCompanyName.get(joobleIdString)));
            }

            // Update Map of Jooble Id : Applications with Account Id from mapJoobleIdToAccount
            for(String joobleIdString : mapJoobleIdToJobApplication.keySet()) {
                mapJoobleIdToJobApplication.get(joobleIdString).Company_Name__c = mapJoobleIdToAccount.get(joobleIdString).Id;
            }

            insert mapJoobleIdToJobApplication.values();

            System.debug('*** mapJoobleIdToJobApplication AFTER INSERT OPERATION: '+ mapJoobleIdToJobApplication);

            } catch (Exception e) {
            System.debug('Error in saveToSalesforce: ' + e.getMessage());
            System.debug('Stack trace: ' + e.getStackTraceString());
            
        }
       
    }

}