/* Created Date - 10/06/2024
Last Modified Date - 13/06/2024
 Author - Smita 
 Description - This has test methods to test InterviewEmailReminder batch class that sends email reminders to email address of job applicant */

@isTest
public with sharing class InterviewEmailReminderTest {
  @TestSetup
  static void makeData() {
    System.debug('********** 1: Start');

    //Query profile outside of loop
    Profile stdUsrProfile = [
      SELECT Id
      FROM Profile
      WHERE Name = 'Standard User'
    ];

    //Creating a test user
    List<User> listOfUsers = new List<User>();
    User testUser = new User(
      FirstName = 'Test',
      LastName = 'User',
      Email = 'smitaj.hodiggeri@gmail.com',
      Username = 'testuserwithinterviewtomorrow@example.com',
      Alias = 'tuser',
      TimeZoneSidKey = 'Australia/Sydney',
      LocaleSidKey = 'en_US',
      EmailEncodingKey = 'UTF-8',
      ProfileId = stdUsrProfile.Id,
      LanguageLocaleKey = 'en_US'
    );

    insert testUser;

    RecordType interviewRecordType = [
      SELECT Id
      FROM RecordType
      WHERE SObjectType = 'Event' AND Name = 'Interview'
      LIMIT 1
    ];
    //  List<Event> listOfInterviews = new List<Event>();
    Event interview1 = new Event();

    if (interviewRecordType != null && interviewRecordType.Id != null) {
      interview1.Subject = 'Meeting';
      interview1.StartDateTime = Datetime.now().addDays(1);
      interview1.EndDateTime = interview1.StartDateTime.addMinutes(30);
      interview1.OwnerId = testUser.Id;
      interview1.RecordTypeId = interviewRecordType.Id;
    }

    insert interview1;
  }

  @isTest
  static void testInterviewEmailReminderBatchClassPositive() {
    test.startTest();
    //Create instance of batch class
    InterviewEmailReminder testInterviewEmailReminder = new InterviewEmailReminder();
    // start the batch Job
    Id batchId = Database.executeBatch(testInterviewEmailReminder);
    System.debug('**** EMAIL INVOCATIONS: '+ Limits.getEmailInvocations());
    test.stopTest();

    //Assertions

    // Assert the number of emails sent
    Integer emailCount = InterviewEmailReminder.emailLimits;
    System.debug('**** EMAIL INVOCATIONS: '+ emailCount);

    // // Assert the number of emails sent matches the number of interviews tomorrow

    System.assertEquals(
      1,
      emailCount,
      'The number of Email invocations sent does not match the number of expected invocations'
    );

    //Query AsyncApexJob to get details about the batch job status -ve scenario

    AsyncApexJob batchJob = [
      SELECT Id, Status, NumberOfErrors
      FROM AsyncApexJob
      WHERE Id = :batchId
    ];
    // Check if the job status is 'Completed'
    System.assertEquals(
      'Completed',
      batchJob.status,
      'The batch job should be completed'
    );
    //Check if the number of errors is zero
    System.assertEquals(
      0,
      batchJob.NumberOfErrors,
      'The batch job should have no errors'
    );
  }

  @isTest
  static void testInterviewEmailReminderBatchClassNegative() {
    //Test data creation for -ve scenario

    //Query profile inside of -ve test data creaion method
    Profile stdUsrProfile = [
      SELECT Id
      FROM Profile
      WHERE Name = 'Standard User'
    ];

    //Creating a test user with no interviews tomorrow
    List<User> listOfUsersWithNoInterviewsTomorrow = new List<User>();
    User testNoInterviewUser = new User(
      FirstName = 'Test',
      LastName = 'User',
      Email = 'smitaj.hodiggeri@gmail.com',
      Username = 'testuserwithNOinterviewtomorrow@example.com',
      Alias = 'tuser',
      TimeZoneSidKey = 'Australia/Sydney',
      LocaleSidKey = 'en_US',
      EmailEncodingKey = 'UTF-8',
      ProfileId = stdUsrProfile.Id,
      LanguageLocaleKey = 'en_US'
    );

    insert testNoInterviewUser;

    RecordType interviewRecordType = [
      SELECT Id
      FROM RecordType
      WHERE SObjectType = 'Event' AND Name = 'Interview'
      LIMIT 1
    ];

    Event Nointerview1 = new Event();
    Nointerview1.Subject = 'Meeting';
    Nointerview1.StartDateTime = Datetime.now().addDays(2);
    Nointerview1.EndDateTime = Nointerview1.StartDateTime.addMinutes(30);
    Nointerview1.OwnerId = testNoInterviewUser.Id;
    Nointerview1.RecordTypeId = interviewRecordType.Id;

    insert Nointerview1;

    test.startTest();
    //Create instance of batch class
    InterviewEmailReminder testNOInterviewEmailReminder = new InterviewEmailReminder();
    // start the batch Job
    Id batchId = Database.executeBatch(testNOInterviewEmailReminder);

    Integer invocations = Limits.getEmailInvocations();

    test.stopTest();
    system.assertEquals(0, invocations, 'No emails should be sent');

    //Assertions for -ve scenario

    // // Assert the number of emails sent matches the number of interviews tomorrow

    // System.assertEquals(
    //   0,
    //   sentEmails.size(),
    //   'No Email Messages are sent as interviews are not tomorrow'
    // );

    //Query AsyncApexJob to get details about the batch job status

    AsyncApexJob batchJob = [
      SELECT Id, Status, NumberOfErrors
      FROM AsyncApexJob
      WHERE Id = :batchId
    ];
    // Check if the job status is 'Completed'
    System.assertEquals(
      'Completed',
      batchJob.status,
      'The batch job should be completed'
    );
    //Check if the number of errors is zero
    System.assertEquals(
      0,
      batchJob.NumberOfErrors,
      'The batch job should have no errors'
    );
  }
}
