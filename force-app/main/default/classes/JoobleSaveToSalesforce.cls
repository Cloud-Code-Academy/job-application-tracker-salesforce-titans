
public with sharing class JoobleSaveToSalesforce {

    @AuraEnabled(cacheable=true)
    public static void saveToSalesforce(String selectedRows) {

        try {

            System.debug('*** INSIDE SAVE TO SALESFORCE');
            System.debug('*** Retrieved rows: ' + selectedRows);

            List<Object> jobRecords = (List<Object>) JSON.deserializeUntyped(selectedRows);
            System.debug('*** jobMAP' + jobRecords);

            Map<String, String> joobleIDtoAccountNames = new Map<String, String>();
            List<Job_Application__c> jobApplications = new List<Job_Application__c>();
    
            for(Object record : jobRecords) {
                Map<String, Object> dataObject = (Map<String,Object>) record;

                String accountName = (String) dataObject.get('company');
                accountNames.add(accountName);


                Job_Application__c job = new Job_Application__c();
                job.Name = (String) dataObject.get('title');
                job.Status__c = (String) dataObject.get('status');
                job.Location__c = (String) dataObject.get('location');
                job.Position_Title__c = (String) dataObject.get('title');
                String salaryString = (String) dataObject.get('salary');
                job.Salary__c = String.isEmpty(salaryString) ? 0 : Decimal.valueOf(salaryString);
                job.Description__c = (String) dataObject.get('snippet');
                job.URL__c = (String) dataObject.get('link');
                job.Notes__c = (String) dataObject.get('source');
    
                jobApplications.add(job);
            }
            
            insert jobApplications;
    
        } catch (Exception e) {
            System.debug('Error in saveToSalesforce: ' + e.getMessage());
            System.debug('Stack trace: ' + e.getStackTraceString());
            
        }
       
    }

    private static Map<Id, Account>

}