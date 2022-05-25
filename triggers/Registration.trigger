/**
    Desription      :   Trigger for the Registration object

    Revision Logs   :   V1.0 - 03/25/2020 - Created - CR-20200324-13884 - Victor Hanson
                        V1.1 - Dipesh Gupta - CR-20200424-13983 - 04/20/2020 - Added one new method - sendCalendarInvites
		        V1.2 - Victor Hanson - CR-20200804-14400 - 08/04/2020 - updated reference to sendCalendarInvites()
			V1.3 - Saurabh Kumar - CR-20200821-14453 - 09/28/2020 - Added populatePartnerStatus & createMembershipMtMRecords methods
		        V1.4 - Saurabh Kumar - CR-20200821-14460 - 10/05/2020 - Added populateRegistrationField method.
		        V1.5 - Saurabh Kumar - CR-20200821-14454 - 10/27/2020 - Added following methods validateRegistrations(), createRegistrationsForChildEABEvents() & updateRelatedRegistrationStatus()
		        V1.6 - Saurabh Kumar - CR-20200821-14465 - 10/28/2020 - Added new methods populateCampaignMemberRegistrationField() & populateStatusAndApprovalReason()
			V1.7 - Saurabh Kumar - CR-20200821-14454 - 01/28/2021 - Added new method populateInstitutionRegistrationCount()
			V1.8 - Saurabh Kumar - CR-20200821-14465 - 01/29/2021 - Added new method populateIsOnInviteList()
			V1.9 - Saurabh Kumar - CR-20200821-14459 - 02/01/2021 - Added new method syncMeetingUtilization()
			V2.0 - Victor Hanson - CR-20210211-14905 - 02/17/2021
                	V2.1 - Victor Hanson - CR-20210308-14971 - 03/10/2021 - Updated populateInstitutionRegistrationCount()
			V2.2 - Saurabh Kumar - CR-20201116-14696 - 03/26/2021 - Added new method createAndPopulateCampaignMemberStatus()
            		V2.3 - Saurabh Kumar - CR-20201116-14696 - 03/30/2021 - Added new method postChatterOnStatusMismatch()
			V2.4 - Saurabh Kumar - CR-20210128-14854 - 04/02/2021
			V2.5 - Saurabh Kumar - CR-20210318-15005 - 04/20/2021
    			V2.6 - Chirag Soni - CR-20210408-15071 - 05/31/2021 -  Added cancelParentsEligibleRegistrations() method
			V2.7 - Chirag Soni - CR-20211025-15548 - 10/26/2021 -  Added Checks to bypass recursive call of checkRegistrations and sendCalendarInvites
                        V2.8 - Chirag Soni - CR-20211108-15570 - 11/08/2021 - Commented IsRegisteredOnZoom util check for check registration method
			V2.9 - Chirag Soni - CR-20210614-15213 - 10/28/2021 - Added populateElevatedMealRSVPFieldOnParentEvent()
    			V3.0 - Chirag Soni - CR-20210511-15133 - 07/08/21 -  Added populateTravelCompensationFields() method
			V3.1 - Chirag Soni - CR-20210511-15133 - 07/22/21 -  Added startsApproval(), validateApprovalForDenyReason() methods
			V3.2 - Chirag Soni - CR-20220204-15768 - 2/7/2022 - corrected the order of execution of methods checkRegistration and sendCalendarInvite
			V3.3 - Chirag Soni - CR-20210606-15193 - comment out the method
**/ 
trigger Registration on Registration__c (before insert, before update, after insert, after update, after delete, after undelete) {
    
    //12/23/2020 - CR-20200821-14454 - Victor Hanson - corrected object name on line below to Registration
    //Check for the trigger Bypass. 
    if(Util.ByPassAllTriggers || Util.areTriggersOnThisObjectBypassed('Registration'))
        return;
    
    //02/03/2021 - Victor Hanson - Moved the institution count logic above bypass because this always need to execute regardless of bypass
    //V1.7 - Saurabh Kumar - CR-20200821-14454 - 01/28/2020
    if(Trigger.isAfter 
        && !RegistrationHelper.bypasspopulateInstitutionRegistrationCount 
        && (Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete || Trigger.isUndelete)) 
    {
        //03/10/2021 - CR-20210308-14971 - Victor Hanson - Updated to include isBeforeInsert boolean
        RegistrationHelper.populateInstitutionRegistrationCount(Trigger.new, Trigger.oldMap, false);
    }

   
    try
    {
        //V1.4 - Added by Saurabh Kumar - CR-20200821-14460 - 10/05/2020
        if(Trigger.isBefore){
            
            //V1.5 - Saurabh Kumar - CR-20200821-14454 - 10/27/2020
            if(Trigger.isInsert){
	    
                //03/10/2021 - CR-20210308-14971 - Victor Hanson - added to get registration count before calculating status
                RegistrationHelper.populateInstitutionRegistrationCount(Trigger.new, Trigger.oldMap, true);

                RegistrationHelper.validateRegistrations(Trigger.new);
                
                //02/17/2021 - CR-20210211-14905 - Victor Hanson - commented out line below because this moved to populatePartnerStatus()
                //V1.6 - Saurabh Kumar - CR-20200821-14465 - 10/28/2020
                //RegistrationHelper.populateStatusAndApprovalReason(Trigger.new);
            }
            
            if(Trigger.isInsert || Trigger.isUpdate){
                RegistrationHelper.populateRegistrationField(Trigger.new, Trigger.oldMap);
                
                //V1.8 - Added by Saurabh Kumar - CR-20200821-14465 - 01/29/2021
                RegistrationHelper.populateIsOnInviteList(Trigger.new, Trigger.oldMap);
                
                // Saurabh Kumar - CR-20210128-14854 - 04/02/2021
                RegistrationHelper.validateRegistrationToSyncAcquia(Trigger.new, Trigger.oldMap);
                //Added By -  Chirag Soni  - Chirag Soni - 07/08/2021 - CR-20210511-15133 - populateTravelCompensationFields
                RegistrationHelper.populateTravelCompensationFields(Trigger.new, Trigger.oldMap);
                
                //Added By -  Chirag Soni  - Chirag Soni - 07/22/2021 - CR-20210511-15133 - validateApprovalForDenyReason
                //Check for the update event
                if(Trigger.isUpdate){
                    RegistrationHelper.validateApprovalForDenyReason(Trigger.NewMap, Trigger.oldMap);
            	}
            }
        }
            
        if (trigger.isAfter) {
            
            //V1.3 - Saurabh Kumar - CR-20200821-14453 - 09/30/2020 
            if(Trigger.isInsert){
                
                //Saurabh Kumar - CR-20200821-14454 - 10/27/2020
                RegistrationHelper.createRegistrationsForChildEABEvents(Trigger.new); 
                
                RegistrationHelper.createMembershipMtMRecords(Trigger.newMap);
                
                //Saurabh Kumar - CR-20200821-14465 - 10/28/2020
                RegistrationHelper.populateCampaignMemberRegistrationField(Trigger.newMap);
            }
            
            if(Trigger.isInsert || Trigger.isUpdate){
                
                //Chirag Soni - CR-20210408-15071 - 05/31/2021
                RegistrationHelper.cancelParentsEligibleRegistrations(Trigger.new, Trigger.oldMap);
                
		//Modified By - Chirag Soni - CR-20210606-15193 - comment out the method
                //update registration count on related eab event
                //RegistrationHelper.updateRegistrationCount(Trigger.new, Trigger.oldMap);
                
                // Commented By -  Chirag Soni - CR-20211108-15570
                // Added By - Chirag Soni - CR-20211025-15548 - 10/26/2021 
                //if(!Util.IsRegisteredOnZoom){
                    
                    //Util.IsRegisteredOnZoom = true;
                    //check registrations and add them to zoom
                    //CR-20220204-15768 - 2/7/2022 - Commented 
                    //RegistrationHelper.checkRegistrations(Trigger.new, Trigger.oldMap);
                //}
                
                //08/04/2020 - CR-20200804-14400 - Victor Hanson - updated reference to sendCalendarInvites()
                //Send the calendar Invites. 
                // Added By - Chirag Soni - CR-20211025-15548 - 10/26/2021 
                //CR-20220204-15768 - 2/7/2022 - Commented 
               /* if(!Util.IsInviteSent)
                {
                    Util.IsInviteSent = true;
                    //08/04/2020 - CR-20200804-14400 - Victor Hanson - updated reference to sendCalendarInvites()
                    //Send the calendar Invites.
                    RegistrationHelper.sendCalendarInvites(Trigger.new, Trigger.oldMap, false);
                }*/
              
                //Saurabh Kumar - CR-20200821-14453 - 09/28/2020 
                RegistrationHelper.populatePartnerStatus(Trigger.new, Trigger.oldMap);
                
                //Added By - Chirag Soni - 12/15/2021 - CR-20211214-15632 - added condition and boolean check to avoid recursive execution
                if(!RegistrationHelper.isChildRegistrationUpdated){
                    RegistrationHelper.updateRelatedRegistrationStatus(Trigger.new, Trigger.oldMap);
                    RegistrationHelper.isChildRegistrationUpdated = true;
                }
                
                //Saurabh Kumar - CR-20200821-14459 - 02/01/2021
                //This method should be calling after processing createMembershipMtMRecords method. Created MembershipMtM is being used in Meeting Utilization
                RegistrationHelper.syncMeetingUtilization(Trigger.new, Trigger.oldMap);
                
                if(RegistrationHelper.isCreateAndPopulateCampaignMemberStatusExecute){
                    
                    //Saurabh Kumar - CR-20201116-14696 - 03/26/2021
                    RegistrationHelper.createAndPopulateCampaignMemberStatus(Trigger.new, Trigger.oldMap);
                }
                
                 //Saurabh Kumar - CR-20210128-14854 - 04/07/2021
                 RegistrationHelper.syncContactAndRegistrationsWithAcquia(Trigger.new, Trigger.oldMap);
               
               
                //Added By -  Chirag Soni  - Chirag Soni - 07/22/2021 - CR-20210511-15133 - startsApproval
                //Call the helper class methid to start the Approval Process.
                if(!RegistrationHelper.isApprovalProcessSubmitted)
                    RegistrationHelper.startsApproval(Trigger.new, Trigger.oldMap);
		//Added By - Chirag Soni - 10/28/2021 - CR-20210614-15213 - populateElevatedMealRSVPFieldOnParentEvent
            	RegistrationHelper.populateElevatedMealRSVPFieldOnParentEvent(Trigger.new, Trigger.oldMap);
                
            }
	    
            if(Trigger.isUpdate && !RegistrationHelper.isAlreadyChatterPostedForRegistrationAndCamapignMemberStatusMissMatch){
                
                //Saurabh Kumar - CR-20201116-14696 - 03/30/2021
                RegistrationHelper.postChatterOnStatusMismatch(Trigger.new, Trigger.oldMap);
            }
            
            // Saurabh Kumar - CR-20210318-15005 - 04/20/2021 - Added
            if(Trigger.isInsert || Trigger.isUpdate){
                
                
                //Note: This method must be calling in last because we are going to reset Automated_Update__c flag field.
                RegistrationHelper.manageRegistrationFields(Trigger.new, Trigger.oldMap);
                
                //CR-20220204-15768 - 2/7/2022 - Added 
                RegistrationHelper.checkRegistrations(Trigger.new, Trigger.oldMap);
                
                //CR-20220204-15768 - 2/7/2022 - Added 
                if(!Util.IsInviteSent)
                {
                    //Send the calendar Invites.
                    RegistrationHelper.sendCalendarInvites(Trigger.new, Trigger.oldMap, false);
                }
              
            }
            
        }
    }
    catch(Exception e)
    {
        //Add Error Message on Page
        if(Trigger.isDelete)
            Trigger.Old[0].addError(e.getMessage() + e.getLineNumber());
        else
            Trigger.New[0].addError(e.getMessage() + e.getLineNumber());
    }
}