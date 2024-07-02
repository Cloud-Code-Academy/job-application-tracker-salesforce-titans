/**
 * Apex Class: EventTriggerHandler
 * Description: This class is designed to handle the logic for the EventTrigger, preventing Events of Record Type = 'Interview'
 * from being scheduled on the weekend or overlapping at the same time
 * Created Date: 2024-06-17
 * Last Modified: 2024-07-01
 */

public with sharing class EventTriggerHandler {

    // Record Type Id for the Interview Record Type
    final static Id INTERVIEW_RECORD_TYPE_ID = Schema.SObjectType.Event.getRecordTypeInfosByName().get('Interview').getRecordTypeId();

    // Main method, called in the EventTrigger
    public static void validateInterviewSchedule(List<Event> listNewEvents){

        List<Event> listInterviews = filterInterviews(listNewEvents);
        
        if (!listInterviews.isEmpty()){
            checkIfEventOnWeekend(listInterviews);
            List<Event> overlappingInterviews = getAllScheduledInterviewsInTimeframe(listInterviews);
            checkIfEventOverlapsOtherEvents(listInterviews, overlappingInterviews);
        
        }

    }

    // Filters list of events for events of record type 'Interview'
    private static List<Event> filterInterviews(List<Event> listNewEvents){

        List<Event> listInterviews = new List<Event>();

        try {

            for(Event event : listNewEvents){
                if(event.RecordTypeId == INTERVIEW_RECORD_TYPE_ID){
                    listInterviews.add(event);
                }
            }

        } catch(Exception e){
            ErrorLogUtility.logError(e);
        }

        return listInterviews;
    }

    // Checks if event is on weekend and displays an error
    private static void checkIfEventOnWeekend(List<Event> eventList){

        try{

            for(Event event : eventList){

                String weekdayOfEvent = event.StartDateTime.format('E');
            
                if(weekdayOfEvent == 'Sat' || weekdayOfEvent == 'Sun'){
                    event.addError('Cannot create an interview on a weekend!');
                }
            }

        } catch(Exception e){
            ErrorLogUtility.logError(e);
        }
        
    }

    // Gets all existing Interview records overlapping the StartDateTime to EndDateTime window of a list of Events
    private static List<Event> getAllScheduledInterviewsInTimeframe(List<Event> eventList){

        List<Event> allOverlappingInterviews = new List<Event>();

        try {

            List<Datetime> eventDateTimes = new List<Datetime>();

            for(Event e : eventList){
                eventDateTimes.add(e.StartDateTime);
                eventDateTimes.add(e.EndDateTime);
            }

            // SORT DATETIMES OLDEST TO NEWEST
            eventDateTimes.sort();

            Datetime earliestStartTime = eventDateTimes[0];
            Datetime latestEndTime = eventDateTimes[eventDateTimes.size()-1];
            

            // Return all Interview Events where the StartDateTime is BEFORE the latest EndDateTime of the latest ending Event
            // and the EndDateTime is AFTER the earliest StartDateTime of the earliest starting Event
            allOverlappingInterviews = [
                SELECT Id, StartDateTime, EndDateTime, RecordTypeId, OwnerId
                FROM Event 
                WHERE (StartDateTime < :latestEndTime AND EndDateTime > :earliestStartTime)
                AND RecordTypeId = :INTERVIEW_RECORD_TYPE_ID
            ];

        } catch(Exception e){
            ErrorLogUtility.logError(e);
        }
        
        return allOverlappingInterviews;

    }

    // Checks if a list of events overlaps with existing events for the same owner; if overlap occurs, an error is displayed
    private static void checkIfEventOverlapsOtherEvents(List<Event> listNewEvents, List<Event> listExistingEvents){

        try {

            for(Event newEvent : listNewEvents){

                for(Event existingEvent : listExistingEvents){
                    if(newEvent.StartDateTime < existingEvent.EndDateTime && newEvent.EndDateTime > existingEvent.StartDateTime && 
                        newEvent.OwnerId == existingEvent.OwnerId){
                        newEvent.addError('Interview overlaps with another interview!');
                    }
                }
            }

        } catch(Exception e){
            ErrorLogUtility.logError(e);
        }
        
    }

}