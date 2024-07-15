global class ScheduleCloseStaleJobApplications implements Schedulable {
    global void execute(SchedulableContext sc) {
        BatchCleanUpStaleJobApplications batch = new BatchCleanUpStaleJobApplications ();
        Database.executeBatch(batch);
    }

    
}