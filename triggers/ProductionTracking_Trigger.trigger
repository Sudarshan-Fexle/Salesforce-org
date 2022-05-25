/** 
  * Description     :   Trigger is reponsible to haldle various events on production tracking object
  *
  * Created By      :   Dipesh Gupta
  *
  * Created Date    :   02/14/2020
  *
  * Revision Log    :   V1.0 Created - CR-20200128-13670 
  * 			V1.1 Modified - CR-20200304-13828 - 04/07/2020 - Victor Hanson - added populateActiveProductionTracking method
  *     		V1.2 Modified - CR-20200221-13792 - 04/27/2020 - Dipesh Gupta - Added a new method - updateJobTicket 
  * 			V1.3 Modified - CR-20200515-14047 - 05/18/2020 - Victor Hanson - added checkReadyForLiveProof
  * 			V1.4 Modified - CR-20200527-14113 - 05/28/2020 - Victor Hanson - Commented out checkReadyForProof & checkReadyForLiveProof
  * 			V1.5 Modified - CR-20200611-14176 - 06/29/2020 - Victor Hanson - added updateProductionTrackingFields
  *			V1.6 Modified - CR-20200616-14191 - 06/19/2020 - Dipesh Gupta - added
  *                     V1.7 Modified - CR-20200717-14331 - 07/28/2020 - Abhinav Sharma - created
  *			V1.8 Modified - CR-20200817-14438 - 8/27/2020 - Abhinav Sharma - created
  *			V1.9 Modified - CR-20201012-14597 - 12/01/2020 - Victor Hanson - added
  *			V2.0 Modified - CR-20210322-15011 - 04/1/2020 - Neha Sharma - added
  *			V2.1 Modified - CR-20210625-15252 - 06/28/2021 - Mahendra Swarnkar
  *                    	V2.2 Modified - CR-20210916-15441 - 10/01/2021 - Nikita Kumari - Added and calling new methods 'populatePostageClassOnPT'
  *                     V2.3 Modified - CR-20210924-15459 - 10/04/2021 - Shalu Sharma - Added and calling new methods 'createInventoryAndTransForPrintPT' and 'populateMailshopPTStatusOnInventoryTransaction'
  *			V2.4 Modified - CR-20210920-15450 - 10/25/2021 - Subhash - Added calling new mehtod "unLockProductionTrackingRecordOnBackTracking"
 **/
trigger ProductionTracking_Trigger on Production_Tracking__c (before insert, before update, after insert, after update) {
    
    //If trigger is Bypassed. 
    if(Util.BypassAllTriggers)
        return;
    
    if(Util.areTriggersOnThisObjectBypassed('Production_Tracking__c'))
        return;
    
    //CR-20200527-14113 - 05/28/2020 - Victor Hanson - commented out
    try 
    {
        if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate))
        {
            ProductionTrackingTriggerHelper.populateProjectManagerOnProductionTracking(trigger.new,trigger.oldmap);
            
            //CR-20200611-14176 - 06/11/2020 - Victor Hanson - added
            ProductionTrackingTriggerHelper.updateProductionTrackingFields(Trigger.new);
            
            //CR-20210916-15441 - 10/01/2021 - Nikita Kumari - added 
            ProductionTrackingTriggerHelper.populatePostageClassOnPT(Trigger.new);
            
            //CR-20200616-14191 - 06/19/2020 - Dipesh Gupta - added
            ProductionTrackingTriggerHelper.populate_JT_PMManagerWithJTProjectManagersManagerId(Trigger.new, Trigger.oldMap);
            
            //CR-20200304-13828 - 04/10/2020 - Victor Hanson - added
            if (Trigger.isUpdate) 
            {
                ProductionTrackingTriggerHelper.updateProdTrackingArtFileName(Trigger.new, Trigger.oldMap);
                
                //Modified - CR-20210625-15252 - 06/28/2021 - Mahendra Swarnkar
                if(ProductionTrackingTriggerHelper.EXECUTE_TRIGGER_CALLOUT_BEFORE_UPDATE)
                {                
                    //CR-20201012-14597 - 01/04/2021 - Victor Hanson - added
                    ProductionTrackingTriggerHelper.checkProofApproved(Trigger.new, Trigger.oldMap);
                }
                
                //CR-20210322-15011 - 04/1/2020 - Neha Sharma - added
                ProductionTrackingTriggerHelper.updateFieldsOnPTracking(Trigger.new, Trigger.oldMap);
                
                //Modified - CR-20210625-15252 - 06/28/2021 - Mahendra Swarnkar
                ProductionTrackingTriggerHelper.EXECUTE_TRIGGER_CALLOUT_BEFORE_UPDATE = false;
            }
            
            //CR-20200717-14331 - Abhinav Sharma - created
            ProductionTrackingTriggerHelper.populate_DueDateFieldOnPTracking(trigger.new,trigger.oldmap); 
            
            //CR-20200817-14438 - 8/27/2020 - Abhinav Sharma - created
            ProductionTrackingTriggerHelper.populate_SLATrackingDateTimeFieldOnPTracking(trigger.new,trigger.oldmap);  
            
            //11/24/2020 - CR-20201012-14597 - Victor Hanson - added
            ProductionTrackingTriggerHelper.checkMailDateConfirmed(trigger.new,trigger.oldmap);
            
            ProductionTrackingTriggerHelper.updatePTArtFileNameOnStatusChange(trigger.new,trigger.oldmap);
        }
        
        if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) 
        {
            //12/01/2020 - CR-20201012-14597 - Victor Hanson - added
            ProductionTrackingTriggerHelper.checkMailDateConfirmationRequest(trigger.new,trigger.oldmap);
            
            //CR-20200304-13828 - 04/07/2020 - Victor Hanson - added
            ProductionTrackingTriggerHelper.populateActiveProductionTracking(Trigger.new);
            
            //Added By Abhinav Sharma - CR-20200408-13920 - 04/10/2020
            ProductionTrackingTriggerHelper.createArtifactForProductionTracking(Trigger.new, Trigger.oldMap);
            
            //Modified - CR-20210625-15252 - 06/28/2021 - Mahendra Swarnkar
            if(ProductionTrackingTriggerHelper.EXECUTE_TRIGGER_CALLOUT_AFTER_INSERT_OR_UPDATE){    
                //CR-20200304-13828 - 04/07/2020 - Victor Hanson - added
                ProductionTrackingTriggerHelper.checkApproved(Trigger.new, Trigger.oldMap);
                
                //Modified - CR-20210625-15252 - 06/28/2021 - Mahendra Swarnkar
                ProductionTrackingTriggerHelper.EXECUTE_TRIGGER_CALLOUT_AFTER_INSERT_OR_UPDATE = false;
            }
            
            //CR-20200304-13828 - 04/07/2020 - Victor Hanson - added
            ProductionTrackingTriggerHelper.checkReadyForPrint(Trigger.new, Trigger.oldMap);
            
            //CR-20201012-14597 - 11/23/2020 - Victor Hanson - added
            ProductionTrackingTriggerHelper.checkSendMailDateConfirmed(Trigger.new, Trigger.oldMap);
            
	    //Added By - Abhinav Sharma - 10/19/2021 - CR-20210924-15459 - Check Inventory asscoiated with PT or not
            ProductionTrackingTriggerHelper.checkInventroyAssociatedWithPT(trigger.new,trigger.oldmap);
            
            if (Trigger.isUpdate) 
            {
                //Created - 04/10/2020 - CR-20200408-13920
                ProductionTrackingTriggerHelper.updateJobTicketFields(Trigger.new, Trigger.oldMap);
                
                //Created - 04/23/2020 - CR-20200408-13920
                //update Artifact approval status when Proof or Live Proof approvals are completed
                ProductionTrackingTriggerHelper.updateArtifactApprovalStatus(Trigger.newMap, Trigger.oldMap);
                
                //Update the Job Ticket. CR-20200221-13792 - 04/27/2020 - Dipesh Gupta
                ProductionTrackingTriggerHelper.updateJobTicket(Trigger.new, Trigger.oldMap);
                
                //Added 04/26/2021 - CR-20210325-15027
                ProductionTrackingTriggerHelper.updateCreativePackageApprovalStatus(Trigger.new, Trigger.oldMap);
                //CR-20210924-15459 - 10/04/2021 - Shalu Sharma - Added calling new method "createInventoryAndTransForPrintPT"
            	ProductionTrackingTriggerHelper.createInventoryAndTransForPrintPT(Trigger.new, Trigger.oldMap);
                
                //CR-20210924-15459 - 10/04/2021 - Shalu Sharma - Added calling new method "populateMailshopPTStatusOnInventoryTransaction"
                ProductionTrackingTriggerHelper.populateMailshopPTStatusOnInventoryTransaction(Trigger.new, Trigger.oldMap);
		
		//CR-20210920-15450 - 10/25/2021 - Subhash - Added calling new mehtod "unLockProductionTrackingRecordOnBackTracking"
                ProductionTrackingTriggerHelper.unLockProductionTrackingRecordOnBackTracking(Trigger.new, Trigger.oldMap);
            }
        }
    } 
    catch(DMLException e) 
    {
        //Add Error Message on Page
        if(Trigger.isDelete)
            Trigger.Old[0].addError(e.getDmlMessage(0));
        else
            Trigger.New[0].addError(e.getDmlMessage(0) + ': ' + e.getStackTraceString());
    }  
    
    //Catching all Exceptions
    catch(Exception e) 
    {
        //Add Error Message on Page
        if(Trigger.isDelete)
            Trigger.Old[0].addError(e.getMessage());
        else
            Trigger.New[0].addError(e.getMessage() + ': ' + e.getStackTraceString());
    }    
}