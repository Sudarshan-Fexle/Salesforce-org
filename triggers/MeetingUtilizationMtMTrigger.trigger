trigger MeetingUtilizationMtMTrigger on Meeting_Utilization_MtM__c (after insert, after update) {
    //Check for Event
    if(Trigger.isAfter){
        
        //Check for Event
        if(Trigger.isInsert ) {
            
            //Added By - Dipesh Gupta - On 08/11/2019 - CR-20190626-13199
            MeetingUtilizationMtMTriggerHelper.populateMembership(Trigger.new, Trigger.oldMap);
            
        }
    }
}