/**
 *  Purpose         :   This trigger is to handle all the pre and post processing operations for OpportunityLineItem object
 *
 *  Create By       :   Subhash Garhwal
 *
 *  Created Date    :   06/29/2016
 *
 *  Revision Logs   :   V_1.0 - Created - Subhash Garhwal - CR-20160414-9762
			V_1.1 - Modified By - Subhash Garhwal - 09/27/2017 - CR-20170926-11418 -  Added the Util.areTriggersOnThisObjectBypassed flag.
			V_1.2 - Modified By - Subhash Garhwal - 10/01/2019
 **/
trigger OpportunityLineItemTrigger on OpportunityLineItem (before insert, before update, after insert, after update) {
	
	//return immediately if method returns true	
        if(Util.areTriggersOnThisObjectBypassed('OpportunityLineItem')) return;	
	
	try {
		
		//Bypass flag
        if(Util.BypassAllTriggers) return;
        
        //Check for trigger context
        if(Trigger.isAfter) {
        	
        	//Check for trigger event
        	if(Trigger.isInsert) {
        		
        		//Call Helper class method to Sync Program Opportunities
        		//VH 4/12/17: Commented out because we no longer use program opportunities
                //if(OpportunityLineItemTriggerHelper.isExecuteProgramOppSync)
        		//	OpportunityLineItemTriggerHelper.syncProgramOpportunities(Trigger.new);
        	}
        }
        
        if(Trigger.isAfter) {
            
            //Check for trigger event
        	if(Trigger.isUpdate || Trigger.isInsert) {
                //if(OpportunityLineItemTriggerHelper.isExecuteProgramOppSync)
                    //Method added by Subhash Garhwal - 10/01/2019
        			OpportunityLineItemTriggerHelper.validateUnitPriceWithCustomerPrice(Trigger.new,Trigger.oldMap);
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