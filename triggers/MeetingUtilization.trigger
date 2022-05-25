/**
    Purpose         :   VRH created this trigger to support CR-180 which involves

    Created By      :   Victor Hanson

    Created Date    :   

    Current Version :   V_1.0
    
    Revision Log    :   V_1.0 - Created
                        V_1.1 - Modified By - updating Meeting/Teleconference counts on Memberships
			V_1.2 - Modified By - Bhavi Sharma - 02/04/2014 - CR-20140124-4353
			V_1.3 - Modified By - Saurabh Kumar - 10/28/2020 - CR-20200821-14465 - A new method added populateRegistration();

    			V_1.4 - Modified By - Abhinav Sharma - 07/07/2014 - CR-20140618-5849 - Catch DML errors in triggers to reduce exception emails to SFAdmin
			V_1.5 - Modified By - Mahendra Swarnkar - On 08/14/2017 - CR-20170509-10928 - Invoked (sentEmailTOAllTravelMemberReceipients,handleBeforeLogic, startsApproval, validateApprovalForDenyReason) method
			V_1.6 - Modified By - Subhash Garhwal - 09/27/2017 - CR-20170926-11418 -  Added the Util.areTriggersOnThisObjectBypassed flag.
    			V_1.7 - Modified By - Deepak Kumawat - 10/06/2017 - Apollo Release -  Added a new call for Entity field.
			V_1.8 - Modified By - Abhinav Sharma - 03/21/2018 - CR-20170915-11367 - Commented Out the sentEmailTOAllTravelMemberReceipients
			V_1.9 - Modified By - Dipesh Gupta - 03/27/2019 - CR-20190111-12831 - Commented method - UpdateInteractionInformation
    			V_2.0 - Modified By - Dipesh Gupta - 10/10/2019 - CR-20190626-13199 - Added a new method - createMUMTM
    			V_2.1 - Modified By - Victor Hanson - 02/02/2021 - CR-20200821-14459 - Commented validateEntityValue reference
                        V_2.2 - Modified By - Chirag Soni - 07/27/2021  - CR-20210511-15133 - changes related to Travel assistance are moved to registration
**/
trigger MeetingUtilization on Meeting_Utilization__c (before insert, before update, after delete, after insert, after update) {
	 
	//try {
        
        /*02/02/2021 - CR-20200821-14459 - Victor Hanson
                        Commented out validateEntityValue because all newly created records will be EAB and Sharing Rule has been updated
                        so Entity can be (BLANK), All, EAB, or Royall and still be visible to EAB folks.  Old HC entity records are still hidden
        
    	//Check for trigger
    	if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate))
            Util.validateEntityValue(Trigger.new, Trigger.oldMap, 'Meeting_Utilization__c', 'Entity__c', 'Institution__c', 'Entity__c', 'Institution__r', 'Account');
        */
    	
    	//return immediately if method returns true	
    	if(Util.areTriggersOnThisObjectBypassed('Meeting_Utilization__c')) return;
    
        // if we are bypassing all triggers, return without processing
        if (Util.BypassAllTriggers) return;
        
        //Check for before event
        if(trigger.isBefore) {
            
            // check for insert/Update event
            if(trigger.isInsert || trigger.isUpdate) {
                
                //Added By - Mahendra Swarnkar - On 08/14/2017 - CR-20170509-10928 
				MeetingUtilities.handleBeforeLogic(trigger.new, Trigger.oldMap); 
                
                //Check for the update event
                /*if(Trigger.isUpdate){
                    
                    //Added By - Mahendra Swarnkar - On 08/14/2017 - CR-20170509-10928
                    //Commented By - Chirag Soni - 07/27/2021  - CR-20210511-15133 - changes related to Travel assistance are moved to registration
                    //MeetingUtilities.validateApprovalForDenyReason(Trigger.NewMap, Trigger.oldMap);  
                }*/
            }
        }
        
        //Check for Event
        if(Trigger.isAfter){
            
            //Check for Event
            if(Trigger.isInsert){
                
                //Added By - Dipesh Gupta - On 10/10/2019 - CR-20190626-13199
                //Call the helper class method to create Meeting_Utilization_MtM__c.
                MeetingUtilities.createMUMTM(Trigger.new);
            }
            
            //Check for Event
            /*if(Trigger.isInsert || Trigger.isUpdate ) {
                
                //Added By - Mahendra Swarnkar - On 08/14/2017 - CR-20170509-10928
                //Commented By - Chirag Soni - 07/27/2021  - CR-20210511-15133 - changes related to Travel assistance are moved to registration
                //Call the helper class methid to start the Approval Process.
                //MeetingUtilities.startsApproval(Trigger.new, Trigger.oldMap);
            }*/
            
            //Check for Event
            /*if(Trigger.isUpdate){
                
                //Commented By - Abhinav Sharma - 03/21/2018 - CR-20170915-11367
                //Added By - Mahendra Swarnkar - On 08/14/2017 - CR-20170509-10928
                //Call the helper class methid to Sent an email to all the receipients of Meeting Utilization.
                //MeetingUtilities.sentEmailTOAllTravelMemberReceipients(Trigger.new, Trigger.oldMap);
            }*/  
        }
        
        if(trigger.isAfter) {
            
        	// to hold all of the membership Ids associated witht he teleconference records we are updating
            Set<Id> membershipIds = new Set<Id>();
            list<Meeting_Utilization__c> memberships = (Trigger.IsDelete)? Trigger.old : Trigger.new;
            for (Meeting_Utilization__c meeting : memberships)
                membershipIds.add(meeting.Membership__c);
                
            // update the memberships with the correct number of teleconferences
            MeetingUtilities.UpdateMeetingSummary(membershipIds);
            
            //Update Institution Roles
            //MeetingUtilities.UpdateInteractionInformation(Trigger.New, Trigger.oldMap);
            
        }
        
    //Catching DML Exceptions
    /*} catch(DMLException e) {

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
    }*/
}