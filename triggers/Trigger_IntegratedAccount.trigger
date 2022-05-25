/**
 *  Purpose         :   This trigger is to handle all the pre and post processing operations for Integrated_Account__c object
 *
 *  Create By       :   Colin
 *
 *  Created Date    :   06/24/2016
 *
 *  Revision Logs   :   V_1.0 - Created - Colin - CR-20160414-9762
 *			V_1.1 - Modified - 08/17/2016 - Subhash Garhwal - CR-20160414-9762 - Added a new call preventIntegratedAccountDeletion
 *			V_1.2 - Modified By - Subhash Garhwal - 09/27/2017 - CR-20170926-11418 -  Added the Util.areTriggersOnThisObjectBypassed flag.
 *			V_1.3 - Commented By - Mahendra Swarnkar - 03/17/2020 - CR-20200217-13756 - RT deleted
 * 
 *						
 **/
trigger Trigger_IntegratedAccount on Integrated_Account__c (before insert, before update, before delete, after insert, after update, after delete) {
    
    //return immediately if method returns true	
    if(Util.areTriggersOnThisObjectBypassed('Integrated_Account__c')) return;	

    try {
        
        //Check trigger context
        if (Trigger.isBefore) {
            
            //Check for the request type
            if(Trigger.isInsert){
                //Commented by Mahendra Swarnkar - 03/17/2020 - CR-20200217-13756 - RT deleted : Contract LOA From Opportunity.
                //Prevents the user from creating an Integrated Account record if there is a Proposal in "In Review" or "Approved Status" associated with the Contract LOA Opp
                //IntegratedTriggerHelper.preventIntegratedAccountDeletionCreation(Trigger.New);
                
            }
            
            //Check for the request type
            if(Trigger.isUpdate){
                
                //Prevents the user from modifying the Integrated Account record if it has a CIA record which references it
                IntegratedTriggerHelper.preventEditOfIntegratedAccount (Trigger.New, Trigger.OldMap);
                
            }
            
            //Check for request type
            if (Trigger.isDelete) {
                
                //Call Helper class method
                IntegratedTriggerHelper.preventDeleteOfIntegratedAccount (Trigger.Old);
                
                //Added - 08/17/2016 - Subhash Garhwal - CR-20160414-9762
                //Call helper class method to validate integrated account
                //Commented by Mahendra Swarnkar - 03/17/2020 - CR-20200217-13756 - RT deleted : Contract LOA From Opportunity.
                //IntegratedTriggerHelper.preventIntegratedAccountDeletionCreation(Trigger.old);
            }  
        }  
		
        //Check for the Trigger After
        if(Trigger.isAfter) {
        	
            //Check for the is insert/Delete/Update
            if(Trigger.isinsert || Trigger.isUpdate || Trigger.isDelete) {
            	
                IntegratedTriggerHelper.populateIntegratedAccountOnProposal(Trigger.new, Trigger.oldMap);
            }
        }
       
    }
    
    catch(DMLException e) {
        
        //Add Error Message on Page
        if(Trigger.isDelete)
            Trigger.Old[0].addError(e.getDmlMessage(0) + e.getStackTraceString());
        else
            Trigger.New[0].addError(e.getDmlMessage(0) + e.getStackTraceString());
        
        //Catching all Exceptions
    } catch(Exception e) {
        
        //Add Error Message on Page
        if(Trigger.isDelete)
            Trigger.Old[0].addError(e.getMessage() + e.getStackTraceString());
        else
            Trigger.New[0].addError(e.getMessage() + e.getStackTraceString());
    }
    
}