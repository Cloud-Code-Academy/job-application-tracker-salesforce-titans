/**
 * Apex Class: JobApplicationTriggerHandler_Test
 * Description: This class tests the JobApplicationTriggerHandler, with bulk insert and update actions 
 * and validates the appropriate Task records are created based on the Job Application Status.
 * Created Date: 2024-06-09
 * Last Modified: 
 */

@isTest
public class JobApplicationTriggerHandler_Test {

    @isTest
    static void testCreateJobApplicationTasksOnInsert() {

        Account testCompany = new Account(Name = 'Test Company');
        insert testCompany;

        List<Job_Application__c> testJobApps = new List<Job_Application__c>();
        for( Integer i = 1; i <= 300; i++){
            Job_Application__c jobApp = new Job_Application__c( 
                Status__c = 'Saved', 
                Company_Name__c = testCompany.Id,
                Position_Title__c = 'Position' + i
            );
            testJobApps.add(jobApp);
        }

        Test.startTest();
            insert testJobApps;
        Test.stopTest();

        List<Task> tasks = [SELECT Subject, Priority, ActivityDate, Status, WhatId FROM Task WHERE WhatId IN :testJobApps];
        System.assertEquals(900, tasks.size(), 'The number of task records created is incorrect');

        Task testTask = tasks[0];
        System.assert(
            testTask.Subject.contains('Check if the job description aligns with your interests and values') || 
            testTask.Subject.contains('Review the highlighted skills to see if the role is a good fit') || 
            testTask.Subject.contains('Research the company or role and mark your excitement level'), 
            'Unexpected task subject for created Task'
        );
        System.assertEquals('Normal', testTask.Priority, 'Unexpected task priority for created Task');
        System.assertEquals('Not Started', testTask.Status, 'Unexpected task status for created Task');

    }

    @isTest
    static void testCreateJobApplicationTasksOnUpdate() {
        
        Account testCompany = new Account(Name = 'Test Company');
        insert testCompany;

        List<Job_Application__c> testJobApps = new List<Job_Application__c>();
        for( Integer i = 1; i <= 300; i++){
            Job_Application__c jobApp = new Job_Application__c( 
                Status__c = 'Saved', 
                Company_Name__c = testCompany.Id,
                Position_Title__c = 'Position' + i
            );
            testJobApps.add(jobApp);
        }

        insert testJobApps;

        List<Task> tasksCreatedOnInsert = [SELECT Subject, Priority, ActivityDate, Status, WhatId FROM Task WHERE WhatId IN :testJobApps];

        for(Task task : tasksCreatedOnInsert){
            task.Status = 'Completed';
        }

        update tasksCreatedOnInsert;

        for(Job_Application__c jobApp : testJobApps){
            jobApp.Status__c = 'Accepted';
        }
        
        Test.startTest();
            update testJobApps;
        Test.stopTest();


        List<Task> tasksCreatedOnUpdate = [SELECT Subject, Priority, ActivityDate, Status, WhatId FROM Task WHERE WhatId IN :testJobApps AND Status != 'Completed'];
        System.assertEquals(900, tasksCreatedOnUpdate.size(), 'The number of task records created from update is incorrect');

        Task testTask = tasksCreatedOnUpdate[0];

        System.assert(
            testTask.Subject.contains('Plan your resignation if applicable') || 
            testTask.Subject.contains('Prepare for your first day of onboarding') || 
            testTask.Subject.contains('Take some time to relax and recharge'), 
            'Unexpected task subject for created Task'
        );
        System.assertEquals('Normal', testTask.Priority, 'Unexpected task priority for created Task');
        System.assertEquals('Not Started', testTask.Status, 'Unexpected task status for created Task');
    }

    @isTest
    static void testSetPrimaryContact() {
        // Create test data
        Account testAccount1 = new Account(Name = 'Test Account 1');
        Account testAccount2 = new Account(Name = 'Test Account 2');
        insert new List<Account> { testAccount1, testAccount2 };

        Contact testContact1 = new Contact(LastName = 'Test Contact 1', AccountId = testAccount1.Id);
        Contact testContact2 = new Contact(LastName = 'Test Contact 2', AccountId = testAccount2.Id);
        insert new List<Contact> { testContact1, testContact2 };

        Job_Application__c jobApp1 = new Job_Application__c(Company_Name__c = testAccount1.Id, Position_Title__c ='Title1');
        Job_Application__c jobApp2 = new Job_Application__c(Company_Name__c = testAccount2.Id, Position_Title__c = 'Title2');

        Job_Application__c jobApp3 = new Job_Application__c(Company_Name__c = testAccount1.Id, Position_Title__c = 'Title3'); // Should not change

    

        // Call the method
        Test.startTest();
        insert new List<Job_Application__c> { jobApp1, jobApp2, jobApp3 };
        Test.stopTest();
        List<Job_Application__c> newJobApplications = [SELECT Id, Company_Name__c, Primary_Contact__c FROM Job_Application__c WHERE Id IN :new List<Id>{jobApp1.Id, jobApp2.Id, jobApp3.Id}];
        system.debug(newJobApplications);
        // Verify the results
        for (Job_Application__c jobApp : newJobApplications) {
            system.debug(jobApp.Id);
            system.debug(jobApp.Primary_Contact__c);
            if (jobApp.Id == jobApp1.Id) {
                System.assertEquals(testContact1.Id, jobApp.Primary_Contact__c, 'Primary Contact should be set for jobApp1');
            } else if (jobApp.Id == jobApp2.Id) {
                System.assertEquals(testContact2.Id, jobApp.Primary_Contact__c, 'Primary Contact should be set for jobApp2');
            } else if (jobApp.Id == jobApp3.Id) {
                System.assertEquals(testContact1.Id, jobApp.Primary_Contact__c, 'Primary Contact should remain unchanged for jobApp3');
            }
        }
    }
}


