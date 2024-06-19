@isTest
public with sharing class EventTriggerHandler_Test {
        
    @isTest
   static void testCheckIfEventOnWeekend(){

        final Id INTERVIEW_RECORD_TYPE_ID = Schema.SObjectType.Event.getRecordTypeInfosByName().get('Interview').getRecordTypeId();
        final Datetime WEEKEND_DATE_TIME = Datetime.newInstance(2024, 6, 22, 12, 00, 00);
        final Datetime WORKWEEK_DATE_TIME = Datetime.newInstance(2024, 6, 18, 12, 00, 00);
        
        Event testWeekendInterview = new Event(Subject = 'Weekend Interview', StartDateTime = WEEKEND_DATE_TIME, EndDateTime = WEEKEND_DATE_TIME.addHours(1), RecordTypeId = INTERVIEW_RECORD_TYPE_ID);
        Event testWorkWeekInterview = new Event(Subject = 'Work Week Interview', StartDateTime = WORKWEEK_DATE_TIME, EndDateTime = WORKWEEK_DATE_TIME.addHours(1), RecordTypeId = INTERVIEW_RECORD_TYPE_ID);
        Event testWeekendEvent = new Event(Subject = 'Non-Interview Event', StartDateTime = WEEKEND_DATE_TIME, EndDateTime = WEEKEND_DATE_TIME.addHours(1));

        Test.startTest();

            try {
                insert testWeekendInterview;
                System.assert(false, 'Expected an exception but did not get one');
            } catch (DmlException e) {
                System.assert(e.getMessage().contains('Cannot create an interview on a weekend'), 'Expected error message to be: \'Cannot create an interview on a weekend\'');
            }
            
            insert new List<Event>{testWorkWeekInterview, testWeekendEvent};

        Test.stopTest();

        List<Event> insertedEvents = [SELECT Id FROM Event];
        System.assertEquals(2, insertedEvents.size(), 'Expected non-interview weekend events and interviews scheduled during the regular work week to be created');

   }


   @isTest
   static void testCheckIfEventOverlapsOtherEvents(){

        final Id INTERVIEW_RECORD_TYPE_ID = Schema.SObjectType.Event.getRecordTypeInfosByName().get('Interview').getRecordTypeId();
        final Id EVENT_RECORD_TYPE_ID = Schema.SObjectType.Event.getRecordTypeInfosByName().get('Event').getRecordTypeId();
        final Datetime INTERVIEW_START_DATETIME = Datetime.newInstance(2024, 6, 18, 10, 00, 00);
        final Datetime INTERVIEW_END_DATETIME = INTERVIEW_START_DATETIME.addHours(2);

        Event existingInterview = new Event(Subject = 'Existing Interview', StartDateTime = INTERVIEW_START_DATETIME, EndDateTime = INTERVIEW_END_DATETIME, RecordTypeId = INTERVIEW_RECORD_TYPE_ID);
        insert existingInterview;
        
        Event overlappingInterview = new Event(Subject = 'Overlapping Interview', StartDateTime = INTERVIEW_START_DATETIME.addHours(1), EndDateTime = INTERVIEW_END_DATETIME.addHours(1), RecordTypeId = INTERVIEW_RECORD_TYPE_ID);
        Event nonOverlappingInterview = new Event(Subject = 'Non-overlapping Interview', StartDateTime = INTERVIEW_START_DATETIME.addHours(2), EndDateTime = INTERVIEW_END_DATETIME.addHours(2), RecordTypeId = INTERVIEW_RECORD_TYPE_ID);
        Event nonInterviewEvent = new Event(Subject = 'Non-Interview Event', StartDateTime = INTERVIEW_START_DATETIME.addHours(1), EndDateTime = INTERVIEW_END_DATETIME.addHours(1), RecordTypeId = EVENT_RECORD_TYPE_ID);

        Test.startTest();
            try {
                insert overlappingInterview;
                System.assert(false, 'Expected an exception but did not get one');
            } catch (DmlException e) {
                System.assert(e.getMessage().contains('Interview overlaps with another interview!'), 'Expected error message to be: \'Interview overlaps with another interview!\'');
            }

            insert new List<Event>{nonInterviewEvent, nonOverlappingInterview};
        Test.stopTest();

        List<Event> insertedEvents = [SELECT Id FROM Event];
        System.assertEquals(2, insertedEvents.size(), 'Expected non-interview weekend events and interviews scheduled during the regular work week to be created');

   }


}