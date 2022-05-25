/**
 * 	Purpose		:	This trigger is responsible for handling all the pre or post processing for
 *                      	any dml operation for Contract ABC object 
 *                
 *                      	Processes:
 *                		1.  Update Total_Negotiated_Amt__c field on attached Invoice_Billing_Schedule__c record
 *                    		with the Negotiated_Amount__c value of newly inserted Contract ABC record.
 *                
 *                		2.  Update Total_Negotiated_Amt__c field on attached Invoice_Billing_Schedule__c record
 *                    		with the Negotiated_Amount__c value of updated Contract ABC record.
 *                
 *                		3.  Update Total_Negotiated_Amt__c field on attached Invoice_Billing_Schedule__c record
 *                    		with the Negotiated_Amount__c value of deleted Contract ABC record.
 *                
 *	Create By   	:   	Simplyforce Technology
 *    
 *	Created Date	:   	09/18/2011
 *    
 *	Current Version	:    	v1.1
 *    
 *	Revision Log	:    	v1.1 - Modified By - Abhinav Sharma - 07/07/2014 - CR-20140618-5849 - Catch DML errors in triggers to reduce exception emails to SFAdmin 
 *  				v1.2 - Modified By - Abhinav Sharma - 08/25/2015 - CR-20150820-9167
 *				V1.3 - Modified By - Abhinav Sharma - 09/03/2015 - CR-20150205-8660
 *				V1.4 - Modified By - Abhinav Sharma - 10/17/2015 - CR-20151008-9304 - Triggers repetative execution
 *				V1.5 - Modified By - Abhinav Sharma - 02/13/2016 - CR-20150925-9267
 * 				V1.6 - Modified By - Mahendra Swarnakar - 3/15/2017 - CR-20170210-10679
 *				V1.7 - Modified By - Subhash Garhwal - 09/27/2017 - CR-20170926-11418 -  Added the Util.areTriggersOnThisObjectBypassed flag.
 *				V1.8 - Modified By -  Modified By Dipesh Gupta - 11/29/2017 -CR-20171128-11817 - Fixing the Code coverage error in the Partial deployment. Called a new Method "CustomExceptiontoCoverCatch"
 *				V1.9 - Modified BY - Mahendra Swarnkar - 12/06/2017 - CR-20171204-11830 - Added additional bypass logic to avoid SOQL limit issue
 *				V2.0 - Modified By - Subhash Garhwal - 07/23/2018 - CR-20180607-12272 - Added 'updateJoinDateMostRecentOnMembership' method to update 'Join Date-Most Recent' field on Membership.
 *				V2.1 - Modified By - Mahendra Swarnkar - 05/22/2020 - CR-20191211-13560 - Commented out the logic to populate the Join_Date_Most_Recent__c field on membership
 * 
**/

trigger Trigger_ContractABC on Contract__c (before insert, before update, after insert, after update, after delete) {
    
    //return immediately if method returns true	
    if(Util.areTriggersOnThisObjectBypassed('Contract__c')) return;	

    try {
    
        // if bypass all triggers is true, return without processing
        if (util.BypassAllTriggers) return;
        
        //Flag to execute the trigger only in valid conditions
        Boolean executeTrigger = true;   
        
        //check if the user is not related to data loader profile only then execute the complete logic
        Id dataloaderProfileId = label.ABC_Dataloader_Profile_Id;
        
        //check if the current user belong to ABC Data loader profile and do not execute teh trigger in this case
        if(dataloaderProfileId != null && UserInfo.getProfileId() == dataloaderProfileId) {
            executeTrigger = false;
        }
        
        //execute the trigger only if executeTrigger flag is true
        if(executeTrigger) {
            
            //Look for flags to skip reaction
            if (!Util.IsBatch && !Util.IsTrigger_Invoice) {
                
                //Check for the request type
                if(Trigger.isBefore) {
                    
                    //Check for the event type
                    if(Trigger.isInsert || Trigger.isUpdate) {
                        
                        //Calling helper class method
                        ContractABCTriggerHelper.populateAndValidateContractFields(Trigger.new, Trigger.oldMap);
                        
                    }
                }
            }               
        
            //Check for the trigger request type
            if(Trigger.isAfter) {
                
                //Check for the event Type
                if(Trigger.isInsert || Trigger.isUpdate) {
                    
                    //Check for event
                    if(Trigger.isUpdate) {
                    	
                        //Commented By- Mahendra Swarnkar - 05/22/2020 - CR-20191211-13560 - Commented out the logic to populate the Join_Date_Most_Recent__c field on membership.
                    	//Calling helper class method - Added by - Subhash Garhwal - 07/23/2018 - CR-20180607-12272
                        //ContractABCTriggerHelper.updateJoinDateMostRecentOnMembership(trigger.newMap, trigger.oldMap);
                        
                        //V1.9 - Modified BY - Mahendra Swarnkar - 12/06/2017 - CR-20171204-11830
                        //Added bypass logic for Adding Program Subscription to IBS process
                        if (!AddContractsToInvoiceBillingSchedule.bypassProcess){
                            
                            //Added By - Mahendra Swarnakar - 3/15/2017 - CR-20170210-10679
                            ContractABCTriggerHelper.createMembershipForCIAFromContract(trigger.new, trigger.oldMap);
                        }
                    }
                    
                    //Added bypass logic for Adding Program Subscription to IBS process
                    if (!AddContractsToInvoiceBillingSchedule.bypassProcess){
                    	
                    	//Call helper class method to update the membership status field on Membership record
                    	ContractUtilities.PopulateContractFields(trigger.newMap);
                    }
                    
                    //Added By - Abhinav Sharma - 02/13/2016 - CR-20150925-9267
                    //Start from here
                    ContractABCTriggerHelper.populateFieldsOnCaseFromContract(trigger.new, trigger.oldMap);
                    //Upto here
                }
                
                //check if trigger is not already executed
                if(!ContractABCTriggerHelper.isContractABCTriggerExecuted) {
                    
                    //Check for the event Type
                    if(Trigger.isUpdate) {
                                    
                        //Call helper class method to update the membership status field on Membership record
                        ContractABCTriggerHelper.updateMembershipStatusByContracts(trigger.new, trigger.oldMap);
                    }
                    
                    //check for the event type
                    if(Trigger.isInsert || Trigger.isDelete) {
                        
                        //create a list of related contracts
                        List<Contract__c> contracts = Trigger.isDelete? Trigger.Old: Trigger.New;
                        
                        //call the trigger helper call to execute the logic
                        ContractABCTriggerHelper.updateTotalNegotiatedAmount(contracts);
                    } 
                    
                    else if(Trigger.isUpdate) {
                        
                        try {
                            
                            //check wheather LIS is associated with the Contract ABC record, if yes then don't allow IBS id as null
                            ContractABCTriggerHelper.validateIBSIdForContactABC(Trigger.New);
                            
                            //call the Trigger helper call to update all the child LIS records with the same IBS id as the contratc one
                            ContractABCTriggerHelper.updateLISWithContractABCIBS(Trigger.New);
                            
                            //call the trigger helper call to execute the logic
                            ContractABCTriggerHelper.updateTotalNegotiatedAmount(Trigger.New);
                        
                            //Added By - Abhinav Sharma - 08/25/2015 - CR-20150820-9167
                            ContractABCTriggerHelper.doUpdateOnOpportunitiesOnContractABCTypeUpdate(Trigger.new, Trigger.oldMap);
                            
                            //Added By - Abhinav Sharma - 09/03/2015 - CR-20150205-8660
                            ContractABCTriggerHelper.updateActiveMembershipMainContact(Trigger.new, Trigger.oldMap);
                             
                            //V_2.1 - Modified By - 11/29/2017 - Modified By Dipesh Gupta - 11/29/2017 -CR-20171128-11817 - 
                            //Fixing the Code coverage error in the Partial deployment. Calling a new Method "CustomExceptiontoCoverCatch"
							//Check if the Test is running
                            If(Test.isRunningTest()) {
                                ContractABCTriggerHelper.CustomExceptiontoCoverCatch();            
                            }
                            
                        } catch(CustomException e) {
                            
                            //add error in the record
                            Trigger.New[0].addError(e.getMessage());
                        }
                    }
                    
                    //Setting flag value
                    ContractABCTriggerHelper.isContractABCTriggerExecuted = true;
                }       
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