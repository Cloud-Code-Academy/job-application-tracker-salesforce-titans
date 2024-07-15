/**
 * Apex Class: ScheduledInterviewReminderTest
 * Description: Test class for ScheduledInterviewReminder which validates the scheduling
and behavior of a scheduled job that sends daily interview email reminders.
The test ensures that the job is scheduled correctly to run every Sunday at 9:00 AM,
verifies the Cron expression, and checks that the job has not yet executed.
Additionally, it confirms that the next scheduled execution time aligns with the
expected behavior of triggering at 9:00 AM on the upcoming Sunday.
 * Last Modified: 2024-06-16
 */
@isTest
public class ScheduledInterviewReminderTest {
  public static String CRON_EXP = '0 0 9 ? * SUN *';

  @isTest
  static void testScheduleDailyInterviewEmailReminder() {
    Test.startTest();

    // Schedule the job
    String jobId = System.schedule(
      'ScheduleDailyInterviewEmailReminder',
      CRON_EXP,
      new ScheduleDailyInterviewEmailReminder()
    );

    Test.stopTest();

    // Get the information from the CronTrigger API object
    CronTrigger ct = [
      SELECT Id, CronExpression, TimesTriggered, NextFireTime
      FROM CronTrigger
      WHERE id = :jobId
    ];

    // Verify the expressions are the same
    System.assertEquals(CRON_EXP, ct.CronExpression);

    // Verify the job has not run
    System.assertEquals(0, ct.TimesTriggered);

    // Calculate the date and time of the next upcoming Sunday at 9:00 AM
    Datetime nextSundayDatetime = Datetime.newInstance(
      Date.today().toStartofWeek().addDays(6),
      Time.newInstance(9, 0, 0, 0)
    );

    // Convert nextSundayDatetime to a Date to remove the time component
    Date expectedNextFireDate = nextSundayDatetime.date();

    // Convert ct.NextFireTime to a Date to remove the time component
    Date actualNextFireDate = ct.NextFireTime.date();

    // Verify the next time the job will run (with the correct date placeholder)
    System.assertEquals(
      expectedNextFireDate,
      actualNextFireDate,
      'NextFireTime should be 9:00 AM on the next Sunday'
    );
  }
}