//V1.0 - Created
//V1.1 - Modified By - Abhinav Sharma - 07/07/2014 - CR-20140618-5849 - Catch DML errors in triggers to reduce exception emails to SFAdmin
//V1.2 - Modified By - Subhash Garhwal - 06/09/2017 - Q2C Phase 2
//V1.3 - Modified By - Subhash Garhwal - 09/27/2017 - CR-20170926-11418 -  Added the Util.areTriggersOnThisObjectBypassed flag.
//V1.4 - Modified By - Mahendra Swarnakar -02/27/2020 - CR-20200217-13758
//V1.5 - Modified By - Shalu Sharma - CR-20210528-15187 - Added calling for new "populateLineItemScheduleTotalOnContractABC" method to populate Line_Item_Schedule_Total__c on Contract ABC
trigger TriggerLineItemSchedule on Line_Item_Schedule__c (before insert, before delete, after update, after insert, after delete) {

    //return immediately if method returns true	
    if(Util.areTriggersOnThisObjectBypassed('Line_Item_Schedule__c')) return;	

    try {
    
        // if a trigger bypass is active, return immediately without processing
        //if (Util.BypassAllTriggers) {
            //return;
        //}
    	
    	//Check for trigger context
    	if(Trigger.isbefore) {
    		
    		//Check for event
    		if(Trigger.isInsert) {
    			
    			//Subhash Garhwal - 06/09/2017
    			LineItemScheduleTriggerHelper.updateContractABC(Trigger.new);
    		}
    		
    		//Check for event
    		if(Trigger.isDelete) {
    			                    
		        //Loop through the Line Items and make sure that they do not have a parent Sales Invoice.
		        for(Line_Item_Schedule__c lineItemSchedule : trigger.old) {
		            if(lineItemSchedule.Sales_Invoice__c != null) {
		                lineItemSchedule.addError('This Line Item has already been billed. You cannot delete it.');
		            }
		        }
			
                //Modified by Mahendra Swarnakar -02/27/2020 - CR-20200217-13758 - Start here
                Set<Id> lisIds = new Set<Id>();
                
                for (Line_Item_Schedule__c lis : Trigger.old) {
                    if (lis.Invoiced__c) {
                        String msg = 'A Line Item Schedule that has been invoiced cannot be deleted';
                        lis.addError(msg);
                    }
                    else if (!lis.Bypass_Delete_Validation__c) {
                        lisIds.add(lis.Id);
                    }
                }
                
                if (!lisIds.isEmpty()) {
                    
                    List<pse__Milestone__c> billingMilestones = [
                        select
                        Id,
                        Line_Item_Schedule__c
                        from pse__Milestone__c
                        where Line_Item_Schedule__c in :lisIds
                    ];
                    
                    if (!billingMilestones.isEmpty()) {
                        for (pse__Milestone__c billingMilestone : billingMilestones) {
                            Line_Item_Schedule__c lis = Trigger.oldMap.get(billingMilestone.Line_Item_Schedule__c);
                            String msg = 'This Line Item schedule is associated with a Billing Milestone. You must delete the ' +
                                'Billing Milestone which will then delete the Line Item Schedule.';
                            lis.addError(msg);
                        }
                    }
                    
                    List<pse__Miscellaneous_Adjustment__c> adminFeeMAs = [select Id, Line_Item_Schedule__c from pse__Miscellaneous_Adjustment__c
		    							  where Line_Item_Schedule__c in :lisIds and pse__Transaction_Category__c = 'Ready-to-Bill Revenue'];
                    
                    if (!adminFeeMAs.isEmpty()) {
                        for (pse__Miscellaneous_Adjustment__c adminFeeMA : adminFeeMAs) {
                            Line_Item_Schedule__c lis = Trigger.oldMap.get(adminFeeMA.Line_Item_Schedule__c);
                            String msg = 'This Line Item Schedule has a relationship with a Miscellaneous Adjustment used for Admin Fees and ' +
                                'cannot be deleted. To credit Admin Fees back to the customer, manually create a Miscellaneous Adjustment ' +
                                'of type Ready To Bill Revenue with a negative dollar amount on the Project and generate and release ' +
                                'a Billing Event. This will create another LIS with a negative dollar amount.';
                            lis.addError(msg);
                        }
                    }
                }
                //Modified by Mahendra Swarnakar -02/27/2020 - CR-20200217-13758 - End Here   
            }
    	}
    	
    	//Check for trigger context
    	if(Trigger.isAfter) {
            
            //Added By - Shalu Sharma - CR-20210528-15187 - Added calling for new "populateLineItemScheduleTotalOnContractABC" method 
            if(Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete)
            {
             	LineItemScheduleTriggerHelper.populateLineItemScheduleTotalOnContractABC(Trigger.new, Trigger.oldMap);   
            }
    		
    		//Check for event
    		if(Trigger.isUpdate) {
    			
    			//Subhash Garhwal - 06/09/2017
    			LineItemScheduleTriggerHelper.updateProgramSubscriptionOnSalesInvoiceAndCreditNote(Trigger.new, Trigger.oldMap);
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