/**
 * Apex Class: EventTriggerHandler
 * Description: This class is designed to handle the logic for the EventTrigger, preventing Events of Record Type = 'Interview'
 * from being scheduled on the weekend or overlapping at the same time
 * Created Date: 2024-06-17
 * Last Modified: 
 */

public with sharing class EventTriggerHandler {

    // Record Type Id for the Interview Record Type
    final static Id interviewRecordId = Schema.SObjectType.Event.getRecordTypeInfosByName().get('Interview').getRecordTypeId();

    // Main method, called in the EventTrigger
    public static void validateInterviewSchedule(List<Event> listNewEvents){

        List<Event> listInterviews = filterInterviews(listNewEvents);
        
        if (listInterviews.size() > 0){
            checkIfEventOnWeekend(listInterviews);
            checkIfEventOverlapsOtherEvents(listInterviews, getAllScheduledInterviewsInTimeframe(listInterviews));
        
        }

    }

    // Helper method, filters list of events for events of record type 'Interview'
    private static List<Event> filterInterviews(List<Event> listNewEvents){

        List<Event> listInterviews = new List<Event>();

        System.debug('interviewRecordId: ' + interviewRecordId);

        for(Event event : listNewEvents){
            if(event.RecordTypeId == interviewRecordId){
                listInterviews.add(event);
            }
        }

        return listInterviews;
    }

    // Checks if event is on weekend and displays an error
    private static void checkIfEventOnWeekend(List<Event> eventList){

        for(Event event : eventList){

            String weekdayOfEvent = event.StartDateTime.format('E');
        
            if(weekdayOfEvent == 'Sat' || weekdayOfEvent == 'Sun'){
                event.addError('Cannot create an interview on a weekend!');
            }
        }
    }

    // Gets all existing Interview records overlapping the StartDateTime to EndDateTime window of a list of Events
    private static List<Event> getAllScheduledInterviewsInTimeframe(List<Event> eventList){

        List<Long> eventStartAndEndTimes = new List<Long>();
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
        return [
            SELECT Id, StartDateTime, EndDateTime, RecordTypeId, OwnerId
            FROM Event 
            WHERE (StartDateTime < :latestEndTime AND EndDateTime > :earliestStartTime)
            AND RecordTypeId = :interviewRecordId
        ];

    }

    // Checks if a list of events overlap with existing events; if overlap occurs, an error is displayed

    // @TODO: CHECK IF OWNER ID MATCHES SAME OWNER ELSE OK.
    private static void checkIfEventOverlapsOtherEvents(List<Event> listNewEvents, List<Event> listExistingEvents){

        List<Long> eventStartAndEndTimes = new List<Long>();
        
        for(Event e : listNewEvents){
            eventStartAndEndTimes.add(e.StartDateTime.getTime());
            eventStartAndEndTimes.add(e.EndDateTime.getTime());
        }

        for(Event e : listExistingEvents){
            eventStartAndEndTimes.add(e.StartDateTime.getTime());
            eventStartAndEndTimes.add(e.EndDateTime.getTime());
        }

        eventStartAndEndTimes.sort();

        for(Event e : listNewEvents){
            Integer index = eventStartAndEndTimes.indexOf(e.StartDateTime.getTime());
            if(index != eventStartAndEndTimes.size()-1){
                if(eventStartAndEndTimes[index+1] != e.EndDateTime.getTime()){
                    e.addError('Interview overlaps with another interview!');
                }
            }

        }
        
    }

}