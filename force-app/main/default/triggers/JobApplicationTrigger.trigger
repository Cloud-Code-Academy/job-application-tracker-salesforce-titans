/**
 * Apex Trigger: JobApplicationTrigger
 * Description: This trigger inserts Task records based on the Status__c of the Job_Application__c record 
 * when the Job_Application__c is created and updated. See the JobApplicationTriggerHandler Apex Class. 
 * Created Date: 2024-06-09
 * Last Modified: 
 */

trigger JobApplicationTrigger on Job_Application__c (after insert, after update) {

    switch on Trigger.operationType {
        when AFTER_INSERT {
            JobApplicationTriggerHandler.createJobApplicationTasksOnInsert(Trigger.new);
        }

        when AFTER_UPDATE {
            JobApplicationTriggerHandler.createJobApplicationTasksOnUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}