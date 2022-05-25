/**
 *  Purpose         :   This trigger is to handle all the pre and post processing operations for Product object
 *
 *  Create By       :   Subhash Garhwal
 *
 *  Created Date    :   07/13/2017
 *
 *  Revision Logs   :   V_1.0 - Created - Subhash Garhwal - CR-20170403-10807
 *					:   V_1.1 - Modified By - Subhash Garhwal - 09/27/2017 - CR-20170926-11418 -  Added the Util.areTriggersOnThisObjectBypassed flag.
 *					:   V_1.2 - Modified By - Victor Hanson - 09/27/2019 - CR-20181208-12776 - Added populateProductOnProgram
 *					:   V_1.3 - Modified By - Nikita kumari - 09/28/2021 - CR-20210910-15426 - Added validateProgramCodes
 **/
trigger Trigger_Product on Product2 (after delete, after insert, after update, before insert, before update) {

    //return immediately if method returns true	
    if(Util.areTriggersOnThisObjectBypassed('Product2')) return;	
	
    if(Util.BypassAllTriggers) return;
    
    try {
        
        //Check for trigger context
        if(Trigger.isAfter) {
            
            //Check for trigger event
            if(Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete) {
                
                //Call helper class method
                ProductTriggerHelper.validateShortOrder(Trigger.new, Trigger.oldMap);
                
                if (!Trigger.isDelete) {
                    //populate product lookup on program
                    ProductTriggerHelper.populateProductOnProgram(Trigger.new, Trigger.oldMap);
                }
            }
        }
        //Added by - 09/28/2021 - Nikita Kumari - CR-20210910-15426 
        if(Trigger.isBefore) {
            //Check for trigger event
            if(Trigger.isInsert || Trigger.isUpdate){
                ProductTriggerHelper.validateProgramCodes(Trigger.new, Trigger.oldMap);
            }
            
        }
        
    //Catching DML Exceptions
    } catch(DMLException e) {

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