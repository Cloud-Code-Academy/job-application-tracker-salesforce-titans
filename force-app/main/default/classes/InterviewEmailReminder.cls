/**
 * Apex Class: InterviewEmailReminder
 * Description: This batch class triggers email reminders for interview events happening tomorrow.
 * This batch class is scheduled to run daily more details on ScheduleDailyInterviewEmailReminder and look in Scheduled jobs in setup.
 * Created Date: 2024-06-14
 * Last Modified: 2024-06-16
 */

public with sharing class InterviewEmailReminder implements Database.Batchable<sObject>, Database.Stateful {
  @TestVisible
  static Integer emailLimits;

  // Start method
  public Database.QueryLocator start(Database.BatchableContext BC) {
    return Database.getQueryLocator(
      'SELECT Id, Subject, Owner.Email, StartDateTime, Interviewer__r.Account.Name,EndDateTime, Interviewer__r.Name FROM Event WHERE RecordType.Name = \'Interview\' AND StartDateTime = NEXT_N_DAYS:1'
    );
  }

  //Execute Method
  public void execute(Database.BatchableContext BC, List<Event> interviews) {
    try {
      List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
      for (Event interview : interviews) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSaveAsActivity(false);
        mail.setTargetObjectId(interview.OwnerId);

        mail.setToAddresses(new List<String>{ interview.Owner.Email });

        // mail.setTemplateId('00XdM000002InU9UAK');
        // mail.setSubject(
        //   'Your interview with ' + interview.Interviewer__r.Account.Name
        // );
        // mail.setPlainTextBody(
        //   'You have an interview tomorrow with ' +
        //     interview.Interviewer__r.Name +
        //     ' starting ' +
        //     interview.StartDateTime
        // );
        //Query email template id
        EmailTemplate emailTemplate = [
          SELECT Id, Subject, Description, HtmlValue, DeveloperName, Body
          FROM EmailTemplate
          WHERE name = 'Interview Reminder'
        ];
        //Set Template Id
        mail.setTemplateID(emailTemplate.Id);
        //This is important for the merge
        mail.setWhatId(interview.Id);

        // mail.setPlainTextBody(emailTemplate.Body);

        emailList.add(mail);
      }

      if (!emailList.isEmpty()) {
        Messaging.Email[] allEmails = new List<Messaging.Email>();
        for (Integer j = 0; j < emailList.size(); j++) {
          allEmails.add(emailList.get(j));
        }

        Messaging.sendEmail(allEmails);

        // Sets the emailLimits class variable for reference in the ScheduleDailyInterviewReminderTest class
        InterviewEmailReminder.emailLimits = Limits.getEmailInvocations();
      }
    } catch (Exception e) {
      // ErrorLogUtility.logError(e);
    }
  }

  //finish
  public void finish(Database.BatchableContext BC) {
  }
}