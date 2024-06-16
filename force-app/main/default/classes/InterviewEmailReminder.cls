public with sharing class InterviewEmailReminder implements Database.Batchable<sObject>, Database.Stateful {
  public InterviewEmailReminder() {
  }

  public Database.QueryLocator start(Database.BatchableContext BC) {
    System.debug('**** INSIDE START');
    return Database.getQueryLocator(
      'SELECT Id, Subject, Owner.Email, StartDateTime, Interviewer__r.Account.Name,EndDateTime, Interviewer__r.Name FROM Event WHERE RecordType.Name = \'Interview\' AND StartDateTime = NEXT_N_DAYS:1'
    );
  }

  public void execute(Database.BatchableContext BC, List<Event> interviews) {
    System.debug('****INSIDE EXECUTE');

    try {
      List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
      for (Event interview : interviews) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new List<String>{ interview.Owner.Email });
        // mail.setTemplateId('00XdM000002InU9UAK');
        mail.setSubject(
          'Your interview with ' + interview.Interviewer__r.Account.Name
        );
        mail.setPlainTextBody(
          'You have an interview tomorrow with ' +
            interview.Interviewer__r.Name +
            ' starting ' +
            interview.StartDateTime
        );
        emailList.add(mail);
      }

      if (!emailList.isEmpty()) {
        Messaging.Email[] allEmails = new List<Messaging.Email>();
        for (Integer j = 0; j < emailList.size(); j++) {
          allEmails.add(emailList.get(j));
        }
        System.debug('****EMAIL SENDING' + allEmails);

        Messaging.sendEmail(allEmails);
      }
    } catch (Exception e) {
      System.debug('EXCEPTION HIT:' + e.getMessage());
    }
  }

  public void finish(Database.BatchableContext BC) {
  }

  // private Id getEmailTemplateId() {
  //      return Id interviewReminderEmailTemplateId = [SELECT Id,
  //  FROM EmailTemplate
  // where DeveloperName='Blank' LIMIT 1];

  // }
}

/*
public class ComplexAccountBatch implements Database.Batchable<sObject>, Database.Stateful {

    // We're keeping track of failed batches.
    private List<String> failedBatches = new List<String>();

    // The start method is the same as in the simple example.
    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator('SELECT Id, Description FROM Account');
    }

    // The execute method is also similar, but now we're also catching any exceptions.
    public void execute(Database.BatchableContext BC, List<Account> records) {
        try {
            for(Account a : records) {
                a.Description = 'Processed by complex batch job.';
            }
            update records;
        } catch (Exception e) {
            handleBatchError(BC, e);
        }
    }

    // The finish method now sends an email if there were any failed batches.
    public void finish(Database.BatchableContext BC) {
        if (!failedBatches.isEmpty()) {
            // Email the Salesforce admin.
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new List<String>{'admin@example.com'});
            mail.setSubject('Batch Apex Job Failed Batches');
            mail.setPlainTextBody('The following batches failed:\n' + String.join(failedBatches, '\n'));
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
        }
    }

    // This is the error handler method.
    public void handleBatchError(Database.BatchableContext BC, Exception e) {
        failedBatches.add('Batch ID: ' + BC.getJobId() + '. Error: ' + e.getMessage());
    }
}
*/

