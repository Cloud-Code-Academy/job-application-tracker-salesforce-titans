@isTest
public class ScheduleCloseStaleJobApplicationsTest {

    @testSetup
    static void setup() {
        // Create test job applications
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        System.debug('Account ID: ' + acc.Id);

        List<Job_Application__c> applications = new List<Job_Application__c>();

        // Add job applications with various statuses and follow-up dates
        applications.add(new Job_Application__c(
            Status__c = 'Saved',
            Follow_up_date__c = Date.today().addDays(-31),
            Company_Name__c = acc.Id,
            Position_Title__c = 'VIP',
            Notes__c = 'Initial note'
        ));
        applications.add(new Job_Application__c(
            Status__c = 'Interviewing',
            Follow_up_date__c = Date.today().addDays(-40),
            Company_Name__c = acc.Id,
            Position_Title__c = 'Trainer',
            Notes__c = null
        ));
      
        applications.add(new Job_Application__c(
            Status__c = 'Accepted',
            Follow_up_date__c = Date.today().addDays(-60),
            Company_Name__c = acc.Id,
            Position_Title__c = 'CEO',
            Notes__c = 'Already accepted'
        ));
        applications.add(new Job_Application__c(
            Status__c = 'Applying',
            Follow_up_date__c = Date.today().addDays(-10),
            Company_Name__c = acc.Id,
            Position_Title__c = 'VIP',
            Notes__c = 'Not stale yet'
        ));

        insert applications;
    }

    @isTest
    static void testScheduledJob() {
        // Verify initial state
        List<Job_Application__c> initialApplications = [
            SELECT Id, Status__c, Follow_up_date__c, Notes__c 
            FROM Job_Application__c
        ];
        System.assertEquals(4, initialApplications.size(), 'Initial applications count mismatch');

        // Run the scheduled job and the batch job within the same test context
        Test.startTest();
        // Schedule the job
        ScheduleCloseStaleJobApplications scheduleJob = new ScheduleCloseStaleJobApplications();
        String jobId = System.schedule('Test Schedule Job', '0 0 0 1 1 ? 2040', scheduleJob);
        
        // Execute the batch job
        Database.executeBatch(new BatchCleanUpStaleJobApplications());
        Test.stopTest();

        // Verify the scheduled job
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobId];
        System.assertEquals('0 0 0 1 1 ? 2040', ct.CronExpression, 'Cron expression mismatch');
        System.assertEquals(0, ct.TimesTriggered, 'TimesTriggered should be 0');
        System.assertNotEquals(null, ct.NextFireTime, 'NextFireTime should not be null');

        // Query the applications again to check their status after the job execution
        List<Job_Application__c> finalApplications = [
            SELECT Id, Status__c, Follow_up_date__c, Notes__c 
            FROM Job_Application__c
        ];

        System.debug('Final Applications: ' + finalApplications);

        // Verify the final state of job applications
        for (Job_Application__c app : finalApplications) {
            System.debug('Application: ' + app);
            if (app.Status__c == 'Closed' && app.Follow_up_date__c <= Date.today().addDays(-30)) {
                System.assert(app.Notes__c != null && app.Notes__c.contains('Closed by automated process'), 
                              'Application should be closed by automated process: ' + app);
            } else if (app.Status__c == 'Closed' && app.Notes__c == 'Already closed') {
                System.assert(app.Notes__c != null && app.Notes__c.contains('Already closed'), 
                              'Application should remain closed and note should not be updated: ' + app);
            }else if (app.Status__c == 'Saved' && app.Follow_up_date__c > Date.today().addDays(-30)) {
                System.assertEquals('Initial note', app.Notes__c, 
                                    'Notes should not be updated for non-stale applications: ' + app);
            }
        }
    }
}