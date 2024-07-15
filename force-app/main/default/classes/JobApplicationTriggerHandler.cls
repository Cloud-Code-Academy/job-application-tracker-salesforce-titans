/**
 * Apex Class: JobApplicationTriggerHandler
 * Description: This class handles the creation of Task records based on the Status__c of the Job_Application__c record. 
 * Created to be used in conjunction with the JobApplicationTrigger.
 * Created Date: 2024-06-06
 * Last Modified: 2024-07-01
 */

public with sharing class JobApplicationTriggerHandler {

    // Inserts a list of tasks based on Job Application Status; called in the Job Application Trigger AFTER_INSERT
    public static void createJobApplicationTasksOnInsert(List<Job_Application__c> newApplications){

        try{
            List<Task> tasksToCreate = new List<Task>();
            Map<String, List<Job_Application_Task__mdt>> templatesByStatus = getJobApplicationTasksByStatus();

            for (Job_Application__c newApplication : newApplications) {
                List<Job_Application_Task__mdt> taskTemplatesToClone = templatesByStatus.get(newApplication.Status__c);
                List<Task> tasks = createTasksFromTemplates(newApplication, taskTemplatesToClone);
                tasksToCreate.addAll(tasks);
            }

            if (!tasksToCreate.isEmpty()) {
                insert tasksToCreate;
            }

        } catch(Exception e){
            ErrorLogUtility.logError(e);
        }
        
    }

    // Inserts a list of tasks based on Job Application Status; called in the Job Application Trigger AFTER_UPDATE
    public static void createJobApplicationTasksOnUpdate(List<Job_Application__c> newApplications, Map<Id, Job_Application__c> oldApplicationsMap) {
        
        try{
            List<Task> tasksToCreate = new List<Task>();
            Map<String, List<Job_Application_Task__mdt>> templatesByStatus = getJobApplicationTasksByStatus();

            for (Job_Application__c newApplication : newApplications) {
                Job_Application__c oldApplication = oldApplicationsMap.get(newApplication.Id);
                
                if (newApplication.Status__c != oldApplication.Status__c) {
                    List<Job_Application_Task__mdt> taskTemplatesToClone = templatesByStatus.get(newApplication.Status__c);
                    List<Task> tasks = createTasksFromTemplates(newApplication, taskTemplatesToClone);
                    tasksToCreate.addAll(tasks);
                }
            }
            
            if (!tasksToCreate.isEmpty()) {
                insert tasksToCreate;
            }
            
        } catch(Exception e){
            ErrorLogUtility.logError(e);
        }
        
    }


    // Retrieves the Job Application Task custom metadata templates and creates a Map of the templates by Job Application Status
    private static Map<String, List<Job_Application_Task__mdt>> getJobApplicationTasksByStatus() {
        
        Map<String, List<Job_Application_Task__mdt>> templatesByStatus = new Map<String, List<Job_Application_Task__mdt>>();

        try{

            List<Job_Application_Task__mdt> taskTemplates = [
                SELECT Job_Application_Status__c, Task_Subject__c, Task_Status__c, Task_Priority__c, Task_Due_Days__c
                FROM Job_Application_Task__mdt
                WITH SYSTEM_MODE
            ];
            
            for (Job_Application_Task__mdt template : taskTemplates) {
                if (!templatesByStatus.containsKey(template.Job_Application_Status__c)) {
                    templatesByStatus.put(template.Job_Application_Status__c, new List<Job_Application_Task__mdt>{template});
                } else {
                    templatesByStatus.get(template.Job_Application_Status__c).add(template);
                }
                
            }

        } catch (Exception e){
            ErrorLogUtility.logError(e);
        }

        return templatesByStatus;
    }

    // Creates a list of task records based on provided list of Job Application Task custom metadata templates
    private static List<Task> createTasksFromTemplates(Job_Application__c newApplication, List<Job_Application_Task__mdt> templates) {

        List<Task> taskList = new List<Task>();

        try {
            for (Job_Application_Task__mdt template : templates) {

                Task newTask = new Task(
                    WhatId = newApplication.Id,
                    Subject = template.Task_Subject__c,
                    Priority = template.Task_Priority__c,
                    ActivityDate = Date.today().addDays((Integer)template.Task_Due_Days__c),
                    Status = template.Task_Status__c
                );
    
                taskList.add(newTask);
            }

        } catch(Exception e){
            ErrorLogUtility.logError(e);
        }

        return taskList;
    }

    // Sets the Primary_Contact__c lookup on the Job Application record to the Contact associated to the related Account
    public static void setPrimaryContact(List<Job_Application__c> newJobApplications) { 

        try {

            Set<Id> accountIds = new Set<Id>();
            Map<Id, Id> accountToContactMap = new Map<Id, Id>();
        
            // Collect Account Ids from new job applications
            for (Job_Application__c jobApp : newJobApplications) {
                if (jobApp.Company_Name__c != null && jobApp.Primary_Contact__c == null) {
                    accountIds.add(jobApp.Company_Name__c);
                }
            }
        
            // Query related contacts in bulk
            if (!accountIds.isEmpty()) {
                List<Contact> relatedContacts = [
                    SELECT Id, AccountId
                    FROM Contact
                    WHERE AccountId IN :accountIds
                ];
        
                for (Contact contact : relatedContacts) {
                    accountToContactMap.put(contact.AccountId, contact.Id);
                }
            }
        
            // Update the primary contact for job applications
            for (Job_Application__c jobApp : newJobApplications) {
                if (jobApp.Primary_Contact__c == null && accountToContactMap.containsKey(jobApp.Company_Name__c)) {
                    jobApp.Primary_Contact__c = accountToContactMap.get(jobApp.Company_Name__c);
                }
            }

        } catch (Exception e){
            ErrorLogUtility.logError(e);
        }
            
    }

}