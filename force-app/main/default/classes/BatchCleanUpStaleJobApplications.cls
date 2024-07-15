global class BatchCleanUpStaleJobApplications implements Database.Batchable<SObject> {

    global Database.QueryLocator start(Database.BatchableContext bc) {
        // Query to find stale job applications
        Date dateThreshold = Date.today().addDays(-30);
        String query = 'SELECT Id, Status__c, Follow_up_date__c, Company_Name__c, Notes__c FROM Job_Application__c ' +
               'WHERE Status__c NOT IN (\'Closed\', \'Accepted\') ' +
               'AND Follow_up_date__c <= :dateThreshold';
            System.debug(query);
        return Database.getQueryLocator(query);
        
    }

    global void execute(Database.BatchableContext bc, List<Job_Application__c> scope) {
        for (Job_Application__c application : scope) {
            application.Status__c = 'Closed';
            application.Notes__c = (application.Notes__c == null ? '' : application.Notes__c + '\n') + 
                                   'Closed by automated process';
        }
        update scope;
    }

    global void finish(Database.BatchableContext bc) {
        
    }
}