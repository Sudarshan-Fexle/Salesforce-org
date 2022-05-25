/** 
  * Description     :   Trigger is used to the Automation and manuplation of data when a Product Lead Reord Insert Update
  *
  * Created By      :   Abhinav Sharma
  *
  * Created Date    :  07/04/2018
  *
  * Revision Log    :  V1.1 - Created.
  * 		        :  V1.2 - Abhinav sharma - 09/13/2018 - CR-20180910-1258 - New Method - updateLastMQLOpportunityAndStatusChange, Commented - populateProductLeadName
  * 		        :  V1.3 - Created - Dipesh Gupta -05/07/2020 - CR-20200429-14006 (Automated email notification to PDR for hot lead)
  *                 :  V1.4 - Modified By Rajeev Jain -09/28/2020 - CR-20200917-14522 - Add the logic to blank the hot mail date if stage != 'AQL'

**/
trigger Trigger_ProductLead on Product_Lead__c (after insert, after update,before update, before insert) {
    
    
    //return immediately if method returns true 
    if(Util.areTriggersOnThisObjectBypassed('Product_Lead__c')) return;
    
    //BYpassing the Trigger
    If(Util.BypassAllTriggers) {
        return;
    }
    
    //Check if this is the after case
    if(Trigger.isAfter) {
        
        //Check for the trigger for the update Case
        if(Trigger.isUpdate || Trigger.isInsert) {
     		//Commented out the method - CR-20180910-1258 - Abhinav Sharma      
        	//ProductLeadTriggerHelper.populateProductLeadName(Trigger.New);
            ProductLeadTriggerHelper.updateLastMQLOpportunityAndStatusChange(Trigger.New, Trigger.OldMap);
            
            //Mahendra updated on 28/05/2019
            ProductLeadTriggerHelper.populateExternalId(Trigger.New, Trigger.OldMap);
        }
        //Modified by Dipesh Gupta -05/07/2020 - CR-20200429-14006 (Automated email notification to PDR for hot lead)
        if(Trigger.isUpdate)
        {
            ProductLeadTriggerHelper.sendMailToProductOwner(trigger.new,trigger.OldMap);
        }
    }
    
    //Modified By Rajeev Jain -09/28/2020 - CR-20200917-14522 - Add the logic to blank the hot mail date if stage != 'AQL'
     //Check if this is the after case
    if(Trigger.isBefore) {

         //Check for the trigger for the update Case
        if(Trigger.isUpdate || Trigger.isInsert) {
            ProductLeadTriggerHelper.updateMaildate(trigger.new,trigger.OldMap); 
        }
    }    
        
}