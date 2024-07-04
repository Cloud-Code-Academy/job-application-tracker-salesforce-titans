trigger EventTrigger on Event (before insert, before update) {

    switch on Trigger.operationType {
        when BEFORE_INSERT, 
             BEFORE_UPDATE {
            EventTriggerHandler.validateInterviewSchedule(Trigger.new);
        }
    }
}