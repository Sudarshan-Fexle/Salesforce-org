/**
 *  Purpose         :  This trigger is to control the automation on Job Ticket MTM object.
 * 
 *  Created By      :   Dipesh Gupta
 *
 *  Created Date    :   11/22/2019
 *
 *  Revision Logs   :   V_1.0 - Created  - Dipesh Gupta - CR-20191011-13405
 * 			V_1.1 - 04/30/2020 - Victor Hanson - CR-20200211-13722 - added updateJobTicketMtMFields
 * 			V_1.2 - Modified By Dipesh Gupta - CR-20200511-14035 - Default Component Code to CEEB
 *                      V_1.3 - Added By - Abhinav Sharama - CR-20210106-14784 - 01/19/2021 - JobTicket MTM validation rules for 'Other'
 *			V_1.4 - Modified By Mahendra Swarnakar - CR-20210325-15027 - 04/26/2021
 *                      V_1.5 - Modified By - Shalu Sharma - CR-20210924-15459 - 10/05/2021 - Added method calling "populatesAvailablePriorYearInventoryOnJobTicket"
**/
trigger Trigger_JobTicketMTM on Job_Ticket_MtM__c (before insert, before update, after insert, after update, after delete, before delete) 
{
    
    //to execute the populatesAvailablePriorYearInventoryOnJobTicket method from AssociatedJobComponentsController component only 
    if(Trigger.isAfter && Trigger.isUpdate 
       && (Util.ByPassAllTriggers || Util.areTriggersOnThisObjectBypassed('Job_Ticket_MtM__c'))
       && AssociatedJobComponentsController.executePopulatesAvailablePriorYearInventoryOnJobTicket) 
    {
        //Added By - Shalu Sharma - CR-20210924-15459 - 10/05/2021 - added method calling populatesAvailablePriorYearInventoryOnJobTicket
        JobTicketMTMTriggerHelper.populatesAvailablePriorYearInventoryOnJobTicket(trigger.new, trigger.oldMap);
    }
    
    //Check for the trigger Bypass. 
    if(Util.ByPassAllTriggers || Util.areTriggersOnThisObjectBypassed('Job_Ticket_MtM__c'))
        return;
    
    try 
    {
        if (Trigger.isBefore) 
        {
            if (Trigger.isInsert) 
            {
                //04/30/2020 - Victor Hanson - CR-20200211-13722 - added updateJobTicketMtMFields
                //update fields on job ticket mtm
                JobTicketMTMTriggerHelper.updateJobTicketMtMFields(Trigger.new);
                //Modified By Dipesh Gupta - CR-20200511-14035 - Default Component Code to CEEB
                JobTicketMTMTriggerHelper.populateDefaultComponentCodeFromJT(Trigger.new);
            }
            
            if (Trigger.isInsert || Trigger.isUpdate) 
            {
                //Added By - Abhinav Sharama - CR-20210106-14784 - 01/19/2021 - JobTicket MTM validation rules for 'Other'
                JobTicketMTMTriggerHelper.validationOnCustomTextFields(Trigger.new);
            }
        }
        
        //Check for the after update case.
        if(Trigger.isAfter)
        {
        	if(Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete) 
            {
                JobTicketMTMTriggerHelper.updateJobTicketFields(trigger.new, trigger.oldMap);
            	
                if(Trigger.isUpdate) 
                {
                    JobTicketMTMTriggerHelper.checkForLockedRecordEdts(trigger.new, trigger.oldMap);

                    //Added By - Shalu Sharma - CR-20210924-15459 - 10/05/2021 - Added method calling "populatesAvailablePriorYearInventoryOnJobTicket"
                    JobTicketMTMTriggerHelper.populatesAvailablePriorYearInventoryOnJobTicket(trigger.new, trigger.oldMap);
                }
                
		//Modified By Mahendra Swarnakar - CR-20210325-15027 - 04/26/2021
                if(Trigger.isInsert) 
                {
                    JobTicketMTMTriggerHelper.populateComponentCodeForOndemandJT(trigger.new, trigger.oldMap);
                }
            }
        }
    }
    catch(Exception e) 
    {
        //Add Error Message on Page
        if(Trigger.isDelete)
            Trigger.Old[0].addError(e.getMessage());
        else
            Trigger.New[0].addError(e.getMessage());
    }
}