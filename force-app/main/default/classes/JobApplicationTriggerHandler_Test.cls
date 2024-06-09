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
}