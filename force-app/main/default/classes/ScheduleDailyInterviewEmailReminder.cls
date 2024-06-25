/**
 * Apex Class: ScheduleDailyInterviewEmailReminder
 * Description: This schedule class triggers the batch class of sending email reminders to all job applicants whose interview is tomorrow.
 * scheduled job name - DailyInterviewEmailReminder
 * Created Date: 2024-06-14
 * Last Modified: 2024-06-16
 */
global with sharing class ScheduleDailyInterviewEmailReminder implements Schedulable {
  // The execute method is the entry point of the scheduled job.
  global void execute(SchedulableContext SC) {
    // We create a new instance of our apex batch class.
    InterviewEmailReminder singleInterviewEmailReminder = new InterviewEmailReminder();

    Database.executeBatch(singleInterviewEmailReminder, 200);
  }
}
