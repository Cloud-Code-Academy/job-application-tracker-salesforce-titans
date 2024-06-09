global with sharing class ScheduleDailyInterviewEmailReminder implements Schedulable {
  // The execute method is the entry point of the scheduled job.
  global void execute(SchedulableContext SC) {
    // We create a new instance of our apex batch class.
    InterviewEmailReminder singleInterviewEmailReminder = new InterviewEmailReminder();

    Database.executeBatch(singleInterviewEmailReminder, 200);
  }
}
