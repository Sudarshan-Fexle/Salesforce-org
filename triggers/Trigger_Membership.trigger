/*
    Purpose	:       This trigger is responsible for handling all the pre or post processing for
    			any dml operation for Membership object

			Processes:
			1.  Copy Associate value from Owner's record to Membership's Owner Associate field

    Create By   :   	Simplyforce Technology

    Created Date:   	01/18/2012

    Current Version:    

    Revision Log:       V1.0 - Created
                        V1.1 - Modified By - Bhavi - 06/15/2012 - Added after update event on trigger.
			- Delete  Key Member Contacts records if Membership Status does not starts with "Membership" - CR-20120518-905
                        V1.2 - Modified By - Bhavi - 11/07/2012 - CR-20121019-1641
                        V1.3 - Modified By - Bhavi - 03/28/2013 - CR-20121207-1868
                        V1.4 - Modified By - Abhinav Sharma - 07/07/2014 - CR-20140618-5849 - Catch DML errors in triggers to reduce exception emails to SFAdmin
                        V1.5 - Modified By - Ajit Surana - 03/28/2015 - CR-20150312-8758
                        V1.6 - Modified By - Abhinav Sharma - 09/03/2015 - CR-20150205-8660
                        V1.7 - Modified By - Jeffery Sun - 09/30/2015 - CR-20130328-2770  
			V1.8 - Modified By - Mahendra Swarnakar -04/27/2017 - CR-20170327-10781
			V1.9 - Modified By - Subhash Garhwal - 09/27/2017 - CR-20170926-11418 -  Added the Util.areTriggersOnThisObjectBypassed flag.
			V2.0 - Modified By - Deepak kumawat - 10/09/2017 - CR-20170928-11596 - Apollo Release - Apollo Release -  Added a new call for Entity field and call a new method "updateChildObjectsEntityField"
			V2.1 - Modified By - Abhinav Sharma - CR-20180205-11984 - 03/09/2018 - Additional parameter Old Map Pass - populateFieldsOnMembershipInBeforeEvent      
			V2.2 - Modified By - Subhash Garhwal - 07/12/2018 - CR-20180504-12213 - Added 'updateCurrentYearFees' method	
			V2.3 - Modified By - Subhash Garhwal - 09/26/2018 - CR-20180720-12456 - Added extra parameters in 'updateMembershipStatusByContracts' and 'populateContactData' to reduce the SOQL count.  
			V2.4 - Modified By - Rajeev Jain - 10/04/2018 - CR-20180809-12494 - updated 'populateOwnerAssociate' method to update 'Membership Owner Name' field
			V2.5 - Modified By - Abhinav Sharma - CR-20181109-12739
			V2.6 - Modified By - Subhash Garhawal - 12/26/2018 - CR-20181019-12685 - Added a new Method "populatePreviousCurrentNextYearProgramCost".
			V2.7 - Modified By - Mahendra Swarnkar - 03/05/2019 - CR-20190215-12886 - Invoked the Method "updateCurrentYearFees".
			V2.8 - Modified By - Victor Hanson - 06/01/2019 - CR-20190520-13117 - added reference to "checkForActiveMembership" method
			V2.9 - Modified By - Dipesh Gupta - 09/05/2019 - CR-20190618-13185 - Invoked the Method "populateSubscriptionFieldsonNewMembership".
                        V3.0 - Modified By - Dipesh Gupta - 12/19/2019 - CR-20191029-13473 - added "populateMainContactOnContractABC" method
                        V3.1 - Modified By - Mahendra Swarnkar - 08/17/2020 - CR-20181004-12632 - MS 4: Removing key contact status upon membership drop.
			V3.2 - Modified By - Mahendra Swarnkar - 08/17/2020 - CR-20200427-13986 - MS 1: Need to change the logic of Payer Status Field.
			V3.3 - Modified By - Neha Sharma - 11/03/2020 - CR-20200930-14569 - Commented out method calling which is used for only Membership Owner update and added "UpdateOwnerOnMembership" method for insert generic owner
			V3.4 - Modified By - Neha Sharma - 11/10/2020 - CR-20201021-14625 - Add automation of cases for cappex.
			V3.5 - Modified By - Saurabh Kumar - 09/29/2020 - CR-20200821-14453 - added syncRegistrationPartnerStatus method
			V3.6 - Modified By - Subhash Garhwal - CR-20210211-14910 - 02/15/2021 - to resolve the 101 issue
			V3.7 - Modified By - Mahendra Swarnkar - 12/1/2020 - CR-20200720-14338
			V3.8 - Modified By - Subhash Garhwal - CR-20210211-14910 - 02/15/2021 - to resolve the 101 issue

*/
trigger Trigger_Membership on Membership__c (before insert, before update, before delete, after insert, after update, after delete) {

  try {
        //Comment out the nethod calling - Rajeev Jain 10/04/2018 - CR-20180720-12456 
        //Check for trigger
        //if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) 
        //Util.validateEntityValue(Trigger.new, Trigger.oldMap, 'Membership__c', 'Entity__c', 'Program__c', 'Entity__c', 'Program__r', 'Program__c');
        
        //return immediately if method returns true  
      	if(Util.areTriggersOnThisObjectBypassed('Membership__c')) return;
              
        //Updated by - Mahendra Swarnkar - 3/30/2016 - CR-20160107-9497 - removed the logic that  bypasses trigger_membership for users with the ABC Dataloader profile. starts from here
        
        // if bypass all triggers is set to true, return without processing
        if (Util.BypassAllTriggers) return;
    	//Updated by - Mahendra Swarnkar - 3/30/2016 - CR-20160107-9497 - removed the logic that  bypasses trigger_membership for users with the ABC Dataloader profile. Ends here.

      //Modified By - Mahendra Swarnkar - CR-20210422-15100 - 04/22/2021 - Start from here
      //Added By Subhash - CR-20210211-14910 - 02/15/2021 - to resolve the 101 issue
      if(Sched_ProgramPackageCreation.IsFromSched_ProgramPackageCreation) {
        //Check for the request type
        if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) 
		MembershipTriggerHelper.updateMembershipFieldsForEnrollmentRecordType(Trigger.new, trigger.oldMap);
		return;
      }
      //Modified By - Mahendra Swarnkar - CR-20210422-15100 - 04/22/2021 - Ends here
      
        //Check for the request type
        if(Trigger.isBefore) {

            //Check for the event type
            if(Trigger.isInsert || Trigger.isUpdate) {

                //Call Helper class method to update the Owner Associate
                MembershipTriggerHelper.populateOwnerAssociate(Trigger.New, Trigger.OldMap);

                //Modified By - Neha Sharma - 11/03/2020 - CR-20200930-14569 - This method update a generic user as Membership Owner
                MembershipTriggerHelper.UpdateOwnerOnMembership(Trigger.New, Trigger.OldMap);
                //End here

                //Call Helper class method to update the Payer Status - Added By Mahendra Swarnkar - 08/17/2020 - CR-20200427-13986
                MembershipTriggerHelper.populatePayerStatus(Trigger.New, Trigger.OldMap);
		//Added 'Trigger.oldMap' - Subhash Garhawal - CR-20180720-12456
                //Call helper class method to update the membership status field on Membership record
                MembershipTriggerHelper.updateMembershipStatusByContracts(Trigger.New);
 
                //Call the helper class method to populate Assigned Marketer
                MembershipTriggerHelper.membershipPopulateAssignedMarketer(Trigger.New, Trigger.isBefore);
        
		//Modified By Abhinav Sharma - CR-20180205-11984 - 03/09/2018 - Additional parameter Old Map Pass 
                //Added By - Abhinav Sharma - 09/03/2015 - CR-20150205-8660
                //Start from here
                //Calling helper class method
                MembershipTriggerHelper.populateFieldsOnMembershipInBeforeEvent(Trigger.new, Trigger.OldMap);
                //Upto here
        	
		MembershipTriggerHelper.updateMembershipFieldsForEnrollmentRecordType(Trigger.new, trigger.oldMap);
		 
               //Check if the code is executed only on the test class. 
                If(Test.isRunningTest() && ProgramTriggerHelper.CHECK_TRIGGER_EXCEPTION) {
                  ProgramTriggerHelper.CustomExceptiontoCoverCatch();            
                }
            }
	    
            //Added By - Saurabh Kumar - 09/29/2020 - CR-20200821-14453
            if(Trigger.isDelete){
                MembershipTriggerHelper.syncRegistrationPartnerStatus(Trigger.new, Trigger.oldMap);
            }
	    
        } else if(Trigger.isAfter) {
      
            //Check if the insert event
            if(Trigger.isInsert) {
				
                //Commented as it is not performing any operation - Issue--CR14032--QA--00009867 - CR-20200508-14032
                //Call helper class method
                //MembershipTriggerHelper.UpdateRelationshipGradeNotes(Trigger.New);

                //Call the helper class method to populate Assigned Marketer
                MembershipTriggerHelper.membershipPopulateAssignedMarketer(Trigger.New, Trigger.isBefore);
                
                
                //Added By - Dipesh Gupta - 09/05/2019 - CR-20190618-13185
                //Call the helper class method to populate Membership field through Program Subscription
                SBQQ_SubscriptionTriggerHelper.populateSubscriptionFieldsonNewMembership(Trigger.New);

            } else if(Trigger.isUpdate) {

	    	//Added 'Trigger.oldMap' - Subhash Garhawal - CR-20180720-12456
                //Call helper class method to update the Contact data
                MembershipTriggerHelper.populateContactData(Trigger.New, Trigger.oldMap);
				
                //Commented as it is not is performing any operation - Issue--CR14032--QA--00009867 - CR-20200508-14032
                //Call helper class method
                //MembershipTriggerHelper.UpdateRelationshipGradeNotes(Trigger.New);

                //Call the helper class method to populate Assigned Marketer
                MembershipTriggerHelper.membershipPopulateAssignedMarketer(Trigger.New, Trigger.isBefore);
                
                //V1.15 - Modified By - Victor Hanson - 06/01/2019 - CR-20190520-13117 - added reference to "checkForActiveMembership" method
                MembershipTriggerHelper.checkForActiveMembership(Trigger.new, Trigger.oldMap);
                
                //Modified By - Dipesh Gupta - 12/19/2019 - CR-20191029-13473 - added "populateMainContactOnContractABC" method
                MembershipTriggerHelper.populateMainContactOnContractABC(Trigger.new, Trigger.oldMap);
                
		//Modified By - Mahendra Swarnkar - 08/17/2020 - CR-20181004-12632 - MS 4: Removing key contact status upon membership drop.
                MembershipTriggerHelper.UpdateMKConStatusChange(Trigger.new, Trigger.oldMap);
		
                //Modified By - Mahendra Swarnkar - 12/1/2020 - CR-20200720-14338 - Populate Main Contact on related Sales Invoice Line Item.
                MembershipTriggerHelper.updateMainContactOnSIL(Trigger.new, Trigger.oldMap);
                
                //Added By Dipesh Gupta - CR-20200408-13916 - 06/02/2020
                if(!system.isBatch())
                    MembershipTriggerHelper.populateMainContactOnMeetingUtility(Trigger.new, Trigger.oldMap);
            }
            
            //Added by - Ajit Surana - 03/28/2015 - CR-20150312-8758
            if(Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete) {
                
              //Calling helper class method
              MembershipTriggerHelper.populateIndustryMemberOnAccount(Trigger.new, Trigger.oldMap);
              
                //Check for Event Type 
                if(Trigger.isInsert || Trigger.isUpdate) {
                    
                    //Added By - Mahendra Swarnakar -04/27/2017 - CR-20170327-10781
                    //Call the helper class method to populate opportunity and project fields from opportunity
                    MembershipTriggerHelper.populateOpportunityAndProjectFieldsFromMembership(Trigger.new, Trigger.oldMap);  
                    //Modified By - Subhash Garhawal - 12/26/2018 - CR-20181019-12685
                    //Call the helper class method to populate Previous/Current/Next Year Program Cost (CPQ)
                    //MembershipTriggerHelper.populatePreviousCurrentNextYearProgramCost(Trigger.new, Trigger.oldMap);
                    //MembershipTriggerHelper.updateCurrentYearFees(Trigger.newMap, Trigger.oldMap);
                    //Added - 07/03/2019 - CR-20190305-12910 - populate owner field on membership object functionality
                    //Modified By - Neha Sharma - 11/03/2020 - CR-20200930-14569 - comment this method which is used for update Membership Owner
                    //MembershipTriggerHelper.populateOwnerByRSLOnProgramSubscription(Trigger.new, Trigger.oldMap);
                    
                    //Added - 11/11/2019 - CR-20190419-13012 - populate Main Contact Signer On Contact
                    MembershipTriggerHelper.populateMainContactSignerOnContact(Trigger.new, Trigger.oldMap);
                    
                    //Created By - Neha Sharma - 11/10/2020 - CR-20201021-14625 - Add automation of cases for cappex.
                    MembershipTriggerHelper.createCappexRequestCases(Trigger.new, Trigger.oldMap);
                    
                    //Added By - Saurabh Kumar - 09/29/2020 - CR-20200821-14453
                    MembershipTriggerHelper.syncRegistrationPartnerStatus(Trigger.new, Trigger.oldMap);
                    
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