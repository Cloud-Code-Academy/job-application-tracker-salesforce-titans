@isTest
public class BatchCleanUpStaleJobApplicationsTest {

    @testSetup
    static void setup() {
        // Create test job applications
       Account acc = new Account(Name = 'Test Account');
        insert acc;
        system.debug(acc.Id);

       
        List<Job_Application__c> applications = new List<Job_Application__c>();

        // Add job applications with various statuses and follow dates
        applications.add(new Job_Application__c(
            Status__c = 'Saved',
            Company_Name__c = acc.Id,
            Position_Title__c = 'CEO 1',
            Follow_up_date__c = Date.today().addDays(-31),
            Notes__c = 'Initial note'
        ));
        applications.add(new Job_Application__c(
            Status__c = 'Applying',
            Company_Name__c = acc.Id,
            Position_Title__c = 'VIP',
            Follow_up_date__c = Date.today().addDays(-40),
            Notes__c = null
        ));
        applications.add(new Job_Application__c(
            Status__c = 'Closed',
            Company_Name__c = acc.Id,
            Position_Title__c = 'CEO 2',
            Follow_up_date__c = Date.today().addDays(-10),
            Notes__c = 'Not stale yet'
        ));
        applications.add(new Job_Application__c(
            Status__c = 'Closed',
            Follow_up_date__c = Date.today().addDays(-50),
            Company_Name__c = acc.Id,
            Position_Title__c = 'VIP2',
            Notes__c = 'Already closed'
        ));
        applications.add(new Job_Application__c(
            Status__c = 'Accepted',
            Follow_up_date__c = Date.today().addDays(-60),
            Company_Name__c = acc.Id,
            Position_Title__c = 'CEO',
            Notes__c = 'Already accepted'
        ));
        applications.add(new Job_Application__c(
            Status__c = 'Negotiating',
            Company_Name__c = acc.Id,
            Position_Title__c = 'CEO',
            Follow_up_date__c = Date.today().addDays(-10),
            Notes__c = 'Not stale yet'
        ));

        insert applications;
        system.debug(applications);
    }

    @isTest
    static void testBatchCleanUpStaleJobApplications() {
        // Verify initial state
        List<Job_Application__c> initialApplications = [
            SELECT Id, Status__c, Follow_up_date__c, Notes__c 
            FROM Job_Application__c
        ];
        System.assertEquals(6, initialApplications.size());

        // Run the batch job
        Test.startTest();
        System.debug('Inside Start test');
        BatchCleanUpStaleJobApplications batch = new BatchCleanUpStaleJobApplications();
        Database.executeBatch(batch);
        System.debug('Inside Start test');
        Test.stopTest();

        // Verify final state
        List<Job_Application__c> finalApplications = [
            SELECT Id, Status__c, Follow_up_date__c, Notes__c 
            FROM Job_Application__c
        ];
        
        for (Job_Application__c app : finalApplications) {
            System.debug(app);
            if (app.Status__c == 'Closed' && app.Follow_up_date__c <= Date.today().addDays(-30) && !app.Notes__c.contains('Already closed')) {
                System.assert(app.Notes__c.contains('Closed by automated process'), 'Application should be closed by automated process');
            } else if (app.Status__c == 'Closed' || app.Status__c == 'Accepted') {
                System.assert(!app.Notes__c.contains('Closed by automated process'), 'Application should not be closed by automated process');
            } else if (app.Status__c == 'Open' && app.Follow_up_date__c > Date.today().addDays(-30)) {
                System.assertEquals('Not stale yet', app.Notes__c, 'Notes should not be updated for non-stale applications');
            }
        }
    }
}