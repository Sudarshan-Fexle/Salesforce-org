/**
 *  Purpose         :   This trigger is to handle all the pre and post processing operations for lead object
 *
 *  Create By       :   Bhavi Sharma
 *
 *  Created Date    :   01/31/2014
 *
 *  Revision Logs   :   V_1.0 - Created
 *					:   V_1.1 - Modified By - Abhinav Sharma - 07/07/2014 - CR-20140618-5849 - Catch DML errors in triggers to reduce exception emails to SFAdmin
 *					:   V_1.2 - Modified By - Subhash Garhwal - 09/27/2017 - CR-20170926-11418 -  Added the Util.areTriggersOnThisObjectBypassed flag.
 *					:   V_1.3 - Modified By - Neha Sharma - 05/18/2021 - CR-20181203-12773 - Retain Acquisition Program data upon conversion
 *					:   V_1.4 - Modified By - Neha Sharma - 08/31/2021 - CR-20201029-14644
 **/
trigger Trigger_Lead on Lead (after update, before delete) {
    
    //return immediately if method returns true	
    if(Util.areTriggersOnThisObjectBypassed('Lead')) return;	

    try {
        //Check for the request Type
        if(Trigger.isAfter) {
            
            //Check for the event type
            if(Trigger.isUpdate) {
                
                 //Added By - Neha Sharma - 08/31/2021 - CR-20201029-14644 - 
                LeadTriggerHelper.UpdateContactToVetStatusOnPdLead(Trigger.New, Trigger.oldMap);
                
                //Call helper class method to check when lead is being converted
                //Then pass the Lead Address information to Contact record - CR-20130419-2900
                LeadTriggerHelper.copyAddressToContactOnConversion(Trigger.New, Trigger.oldMap);
                
                //Added By - Neha Sharma - 05/18/2021 - CR-20181203-12773 - Retain Acquisition Program data upon conversion
                LeadTriggerHelper.copyAcquisitionfieldToContactOnConversion(Trigger.New, Trigger.oldMap);
                
               
            }
        }
        // added by Seemu Saikia on 06/19/2019 for CR-20190213-12882
        //Check for the request Type
        if(Trigger.isBefore) {
            
            //Check for the event type
            if(Trigger.isDelete) {
               system.debug('Before Delete'); 
               LeadTriggerHelper.deleteProductLeadsandCampaignMembers(Trigger.oldMap);
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