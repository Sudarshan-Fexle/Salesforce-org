/** 
*  Purpose         :  This trigger is to control the automation on Job Ticket object.
* 
*  Created By      :   Dipesh Gupta
*
*  Created Date    :   10/14/2019
*
*  Revision Logs   :   V_1.0 - Created  - CR-20191011-13405
*		   :   V_1.1 - Modified By -  Dipesh Gupta - CR-20200128-13670
		   :   V_1.2 - Modified By - Abhinav Sharma - CR-20200325-13887 - 04/03/2020. Added a new Method createBoxFoldersForJobTicket
*		   :   V_1.3 - Modified By - Dipesh Gupta - CR-20200325-13887 - Added a new Method checkIfJobTicketDuplicated
*		   :   V_1.4 - Modified By - Dipesh Gupta - CR-20200212-13739 - Added a new method - populateFiscalYearWithSubsPeriodYear
*		   :   V_1.5 - Modified By - Victor Hanson - CR-20200611-14176 - 06/11/2020 - added updateProductionTracking
*		   :   V_1.6 - Modified By - Abhinav Sharma - CR-20200709-14285 - 07/10/2020 - Update box folder name
*		   :   V_1.8 - Modified By - Abhinav Sharma - 02/18/2021 - CR-20200212-13739 (Issue--CR13739--QA--00010369 - Update Subscription Period on newly created record)
*		   :   V_1.9 - Modified By - Abhinav Sharma - CR-20201111-14688  
*          	   :   V_2.0 - Modified By - Abhinav Sharma - CR-20210510-15129 - Remove the calling of "checkDuplicateJobTicketWithInstitutionProgramFY" method
*		   :   V_2.1 - Modified By - Abhinav Sharma - 05/19/2021 - CR-20210518-15161 - Remove the method "approveJobTicketMTM"
*		   :   V_2.2 - Modified By - Mahendra Swarnakar - CR-20210325-15027 - 04/26/2021 - add JobTicketTriggerHelper.createPrintPTRecordsOnDropOnDemand
*		   :   V_2.3 - Modified By - Abhinav Sharma - 09/22/2021 - CR-20210913-15431 - Box folders not getting created and/or linked in some JTs
*		   :   V_2.4 - Modified By - Shalu Sharma - 22/12/2021 - CR-20211213-15624 - Added new method "populatePTPrintQuantityContractedOnInventory"
**/
trigger Trigger_JobTicket on Job_Ticket__c (before insert, before update, after Insert, after update)
{
    //Check for the trigger Bypass. 
    if(Util.ByPassAllTriggers || Util.areTriggersOnThisObjectBypassed('Job_Ticket__c'))
        return;
    
    try
    {
       		
        if (Trigger.isBefore && Trigger.isUpdate) 
        {	
            
            JobTicketTriggerHelper.validateJobTicketMTM(trigger.new, trigger.oldMap);
            JobTicketTriggerHelper.changeReasonRequiredForLockedRecord(trigger.new, trigger.oldMap);
            
        }
        //Modified By Dipesh Gupta - CR-20200212-13739 - Added a new method - populateFiscalYearWithSubsPeriodYear
        if(Trigger.isBefore)
        {
            if(Trigger.isInsert || Trigger.isUpdate){
                JobTicketTriggerHelper.populateFiscalYearWithSubsPeriodYear(trigger.new, trigger.oldMap);
                //Added By - Abhinav Sharma - 02/18/2021 - CR-20200212-13739 (Issue--CR13739--QA--00010369 - Update Subscription Period on newly created record)
                JobTicketTriggerHelper.populateSubscriptionPeriodOnJobTicket(trigger.new, trigger.oldMap);
                //Added By - Abhinav Sharma - 02/18/2021 - CR-20200212-13739 (Issue--CR13739--QA--00010518 - As per Julie's Chatter)
                JobTicketTriggerHelper.populateJobCodeWithSubsPeriodJobNo(trigger.new, trigger.oldMap);
            }
        }
        
         if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
           JobTicketTriggerHelper.checkUpdateJobTicketName(Trigger.new, Trigger.oldMap);
           //JobTicketTriggerHelper.checkDuplicateNamesOnJT(trigger.new);
	 }

	//Add for CR-20200128-13670 By Dipesh Gupta
        //Check for the after update case. 
        if(Trigger.isAfter && Trigger.isUpdate){
            JobTicketTriggerHelper.populateProjectManagerOnProductionTracking(trigger.new, trigger.oldMap);
            JobTicketTriggerHelper.createFulfillmentRecords(trigger.new, trigger.oldMap);
	    //Added By Mahendra Swarnakar - CR-20210325-15027 - 04/26/2021
            JobTicketTriggerHelper.createPrintPTRecordsOnDropOnDemand(trigger.new, trigger.oldMap);
            
            //Commented By - Abhinav Sharma - 09/22/2021 - CR-20210913-15431 - Box folders not getting created and/or linked in some JTs
            //Added By Abhinav Sharma - CR-20200325-13887 - 04/03/2020.
            //JobTicketTriggerHelper.createBoxFoldersForJobTicket(trigger.new, trigger.oldMap);
            
            //Added by Victor Hanson - CR-20200611-14176 - 06/11/2020
            JobTicketTriggerHelper.updateProductionTracking(trigger.new, trigger.oldMap);
	    
            //Added By Abhinav Sharma - 07/10/2020. - CR-20200709-14285 - Update box folder name 
            JobTicketTriggerHelper.updateBoxFolderNameForJT(trigger.new, trigger.oldMap);
            
            //Added By - Shalu Sharma - 22/12/2021 - CR-20211213-15624 - Added new method "populatePTPrintQuantityContractedOnInventory"
	    JobTicketTriggerHelper.populatePTPrintQuantityContractedOnInventory(Trigger.new, Trigger.oldMap);
        }
        
        //Added By - Abhinav Sharma - 09/22/2021 - CR-20210913-15431 - Box folders not getting created and/or linked in some JTs
        if(Trigger.isAfter && Trigger.isInsert){
            JobTicketTriggerHelper.createBoxFoldersForJobTicket(trigger.new, trigger.oldMap);
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