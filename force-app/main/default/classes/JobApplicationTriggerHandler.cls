public with sharing class JobApplicationTriggerHandler {

    public static void createTasks(List<Job_Application__c> newApplications, Map<Id, Job_Application__c> oldApplicationMap) {
        List<Task> tasksToInsert = new List<Task>();
        
        for (Job_Application__c application : newApplications) {
            Job_Application__c oldApplication = oldApplicationMap.get(application.Id);

            if (application.Status__c != oldApplication.Status__c) {
                
                tasksToInsert.addAll( generateTaskList(application) );
            }
        }
        
        if (!tasksToInsert.isEmpty()) {
            insert tasksToInsert;
        }
    }
    
    private static List<Task> generateTaskList(Job_Application__c application) {
        List<Task> tasks = new List<Task>();
        final Date ONE_WEEK = Date.today() + 7;
        final Date THREE_DAYS = Date.today() + 3;
        final Date ONE_DAY = Date.today() + 1;
        final String NORMAL_PRIORITY = 'Normal';
        final String HIGH_PRIORITY = 'High';
        final String LOW_PRIORITY = 'Low';
        final Id appId = application.Id;

        switch on application.Status__c {
            when 'Saved' {
                tasks.add( createTask( appId, 'Check job alignment', ONE_WEEK, HIGH_PRIORITY ));
                tasks.add( createTask( appId, 'Review highlighted skills', ONE_WEEK, NORMAL_PRIORITY ));
                tasks.add( createTask( appId, 'Mark excitement', ONE_WEEK, LOW_PRIORITY ));
            }
            when 'Applying' {
                tasks.add( createTask( appId, 'Find a contact', ONE_WEEK, HIGH_PRIORITY ));
                tasks.add( createTask( appId, 'Set up interview', ONE_WEEK, HIGH_PRIORITY ));
                tasks.add( createTask( appId, 'Identify potential referrals', ONE_WEEK, NORMAL_PRIORITY ));
                tasks.add( createTask( appId, 'Customize achievements', ONE_WEEK, NORMAL_PRIORITY ));
                tasks.add( createTask( appId, 'Submit your application', ONE_WEEK, LOW_PRIORITY ));
            }
            when 'Applied' {
                tasks.add( createTask( appId, 'Contact hiring manager', ONE_WEEK, HIGH_PRIORITY ));
                tasks.add( createTask( appId, 'Follow up your application', ONE_WEEK, NORMAL_PRIORITY ));
                tasks.add( createTask( appId, 'Identify other job opportunities', ONE_WEEK, LOW_PRIORITY ));
                tasks.add( createTask( appId, 'Schedule a networking call', ONE_WEEK, LOW_PRIORITY ));
            }
            when 'Interviewing' {
                tasks.add( createTask( appId, 'Prepare your blurb', THREE_DAYS, HIGH_PRIORITY ));
                tasks.add( createTask( appId, 'Practice interview questions', THREE_DAYS, NORMAL_PRIORITY ));
                tasks.add( createTask( appId, 'Research the company', THREE_DAYS, HIGH_PRIORITY ));
                tasks.add( createTask( appId, 'Set up for the interview', THREE_DAYS, NORMAL_PRIORITY ));
                tasks.add( createTask( appId, 'Send thank you', THREE_DAYS, LOW_PRIORITY ));
            }

            when 'Negotiating' {
                tasks.add( createTask( appId, 'Research your market value', THREE_DAYS, HIGH_PRIORITY ));
                tasks.add( createTask( appId, 'Prepare negotiation scripts', THREE_DAYS, NORMAL_PRIORITY ));
                tasks.add( createTask( appId, 'Evaluate job offer', THREE_DAYS, LOW_PRIORITY ));
            }

            when 'Accepted' {
                tasks.add( createTask( appId, 'Plan resignation', ONE_WEEK, HIGH_PRIORITY ));
                tasks.add( createTask( appId, 'Relax and recharge', ONE_WEEK, NORMAL_PRIORITY ));
                tasks.add( createTask( appId, 'Prepare to onboard', ONE_WEEK, NORMAL_PRIORITY ));
            }

            when 'Closed' {
                tasks.add( createTask( appId, 'Request feedback', THREE_DAYS, HIGH_PRIORITY ));
                tasks.add( createTask( appId, 'Review and reflect', ONE_WEEK, NORMAL_PRIORITY ));
            }
        }
        
        return tasks;
    }
    
    private static Task createTask(Id whatId, String subject, Date dueDate, String priority) {

        final String NOT_STARTED_STATUS = 'Not Started';
        

        Task task = new Task();
        task.WhatId = whatId;
        task.Subject = subject;
        task.ActivityDate = dueDate;
        task.Status = NOT_STARTED_STATUS;
        task.OwnerId = UserInfo.getUserId();
        task.Priority = priority;
        return task;
    }

    
}