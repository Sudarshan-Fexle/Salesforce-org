/**
*  @description	:   Trigger to Insert the manipulation on the pse__Timecard_Header__c Object
* 
*  Created By   :   Nikita Kumari
* 
* Revision Log  :   V1.0 - Created - 06/10/2021 - CR-20210518-15162.
*		:   V1.1 - Modified By - Nikita kumari - 09/21/2021 - CR-20210917-15447 - Issue with Actual fields not populating correctly on PSA Projects
**/

trigger Timecard_Trigger on pse__Timecard_Header__c (before insert, before Update, after insert, after update, after delete) {
    
    try { 
        
        //Calling Methods.
        //return immediately if method returns true
        if(Util.areTriggersOnThisObjectBypassed('pse__Timecard_Header__c')) return;
        
        //Another Bypass
        if(Util.ByPassAllTriggers) return;
        
        //Calling methods - 
        if(trigger.isAfter) {
            
            //Check for the is insert Case
            if(trigger.isInsert || trigger.isUpdate) {
                TimecardTriggerHelper.rollUpTimeOnPSAProject(trigger.new, trigger.oldMap);
            } 
        }
    }catch(DMLException e) {
        
        //Add Error Message on Page
        if(Trigger.isDelete)
            Trigger.Old[0].addError(e.getDmlMessage(0));
        else
            Trigger.New[0].addError(e.getDmlMessage(0));
        
        //Catching all Exceptions
    } catch(Exception e) {
        
        //Add Error Message on Page
        if(Trigger.isDelete)
            Trigger.Old[0].addError(e.getMessage());
        else
            Trigger.New[0].addError(e.getMessage());
    }
}