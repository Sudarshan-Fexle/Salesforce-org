/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
 //Modified By - Subhash Garhwal - 09/27/2017 - CR-20170926-11418 -  Added the Util.areTriggersOnThisObjectBypassed flag.
 //Modified By - Subhash Garhwal - 10/08/2018 - CR-20180720-12456- Added ByPassAllTriggers check 
trigger dlrs_ABC_RevenueTrigger on ABC_Revenue__c
    (before delete, before insert, before update, after delete, after insert, after undelete, after update)
{
    
    //return immediately if method returns true 
    if(Util.areTriggersOnThisObjectBypassed('ABC_Revenue__c')) return;
    
    //Modified By - Subhash Garhwal - 10/08/2018 - CR-20180720-12456
    if(Util.ByPassAllTriggers) return;
    
    //Modified By - Subhash Garhwal - 10/08/2018 - CR-20180720-12456
    if(Util.BYPASS_DLRS_ABC_REVENUE_RECOGNITION_BATCH) return;
    
    //Modified By - Mahendra Swarnkar - 01/24/2019 - CR-20200123-13654
    if(System.isBatch() && !Sched_ABCRevenueUpdateForDLRS.EXECUTE_ABC_REVENUE_TRIGGER && !Batch_Revenue.EXECUTE_ABC_REVENUE_TRIGGER_VIA_BATCH_REVENUE) {
        
        if(Trigger.isAfter && !Trigger.isDelete){
        	// Modified By - Neha Sharma - CR-20200506-14020
            dateTime sysTime = dateTime.now().addMinutes(5);
            String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
            
            Sched_ABCRevenueUpdateForDLRS sched = new Sched_ABCRevenueUpdateForDLRS(Trigger.new);
            
            System.schedule('Sched_ABCRevenueUpdateForDLRS' + sysTime.getTime(),chron_exp, sched);
        }
    } else {
        if (Trigger.isUpdate && Trigger.isBefore) {
            //Modified By - Victor Hanson - CR-20200123-13654
            //populate shadow fields before insert/update when not executed in a batch context
            for (ABC_Revenue__c newRev : Trigger.new) {
                newRev.Negotiated_Amount_Shadow__c = newRev.Negotiated_Amount__c;
                newRev.Actual_Recognized_to_Date_Shadow__c = newRev.Actual_Recognized_to_Date__c;
                newRev.Secured_Amount_GAAP_Shadow__c = newRev.Secured_Amount_GAAP__c;
                newRev.GAAP_Amount_Shadow__c = newRev.GAAP_Amount__c;
            }
        }
        
    	dlrs.RollupService.triggerHandler();
    } 
}