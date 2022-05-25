/**
 *  Purpose      :  Helper class for Meetingutilization.
 *
 *  Create By    :  
 *  
 *  Revision Log  :  V1.0 -  Created 
 *                   V1.1 - 02/04/2014 - Bhavi Sharma - New methods added (UpdateInteractionInformation) - CR-20140124-4353
 *                   V1.2 - 02/14/2014 - CR-20120823-1396 - Remove subquery in Batch_MeetingUtilizations = Method modified (UpdateMeetingSummary) and (FindMemberships)
 *                   V1.3 - 04/18/2014 - CR-20140331-4909 - Updates to batch failure process - Modify by - Abhinav Sharma
 *                   V1.4 - 08/14/2017 - Mahendra Swarnkar - CR-20170509-10928 - Added a new method - (sentEmailTOAllTravelMemberReceipients,handleBeforeLogic, startsApproval, validateApprovalForDenyReason ) 
 *                   V1.5 - 10/27/2017 - Mahendra Swarnkar - CR-20171018-11725 - Modified the method "startsApproval" :- to Separate out the Approval processes for EAB and HC
 *                   V1.6 - 01/23/2018 - Mahendra Swarnkar - CR-20180116-11885 - Modified the method "startsApproval" - updated to have check for Entity__c == 'All' 
 *                   V1.7 - 03/21/2018 - CR-20170915-11367 - Abhinav sharma - commented the method - sentEmailTOAllTravelMemberReceipients
 *                   V1.8 - 03/27/2019 - Modifed By Dipesh Gupta - CR-20190111-12831 - Commented method - UpdateInteractionInformation
 *                   V1.9 - CR-20190419-13012 Add lines to handleBeforeLogic as per Cr Workorder
 *                   V2.0 - 07/27/2021 - Modified By - Chirag Soni - CR-20210511-15133 - changes related to Travel assistance are moved to registration
**/
public without sharing class MeetingUtilities {
    
    public static Boolean IS_ALREADY_PROCESSED = false;
    
  // Added by - Mahendra Swarnakar - 09/07/2017 - CR-20170509-10928 
    /**
     *  @description    :   This method is used to perfor all the before event logics. 
     *
     *  @args           :   Map new Meeting Utilization 
     *
     *  @return         :   
     *
     * @Version         :   V1.0 - Modfied By - Chirag Soni - 07/27/2021  - CR-20210511-15133 - Travel compensation request related changes moved to RegistrationHelper
     **/
    public static void handleBeforeLogic(List<Meeting_Utilization__c> meeetinUtilizations, map<Id, Meeting_Utilization__c> oldmapMeetingUtilization) {
        
        //Set to hold the user IDs
        Set<Id> setOfUsersIds = new Set<Id>();
		
	//Changes as per CR-20190419-13012
	//Set to hold the Membership IDs
	Set<Id> setOfMembershipIds = new Set<Id>();
        
        //Loop through meeting utilizations
        for(Meeting_Utilization__c mu : meeetinUtilizations) {
		
	     //Changes as per CR-20190419-13012
	     //Check for the Membership
	     if(mu.Membership__c != null && mu.Start_Date__c >= system.Today()) {     
                //Populate the Set
                setOfMembershipIds.add(mu.Membership__c);
	     }
            //Commented By - Chirag Soni - 07/27/2021  - CR-20210511-15133 - Travel compensation request related changes moved to RegistrationHelper - From Here
            /*
            //Check for the Department Authorization
            if(mu.Department_Authorization__c != null) {
                
                //Populate the Set
              setOfUsersIds.add(mu.Department_Authorization__c);    
            }
            
            //Check for the Requester
             if(mu.Requester_Name__c != null) {
                 
             	//Populate the Set
              	setOfUsersIds.add(mu.Requester_Name__c);    
            }
            
            //Populat ethe Is_Esclated__c field to true on insert/Update use case
            if(mu.Travel_Assistance_Request__c == true
                && mu.Department_Authorization__c != null
                && mu.Start_Date__c.addDays(-7) < System.today()
                && mu.Is_Esclated__c == false
                 && (
                    oldmapMeetingUtilization == null
                    ||
                    (
                        oldmapMeetingUtilization != null
                      &&
                        (
                            mu.Start_Date__c != oldmapMeetingUtilization.get(mu.Id).Start_Date__c
                            ||
                            mu.Travel_Assistance_Request__c != oldmapMeetingUtilization.get(mu.Id).Travel_Assistance_Request__c
                      )
                    )
                )
      ){
                  mu.Is_Esclated__c = true; 
            }
        }
        
        //Checking for size value
        if(setOfUsersIds.size() > 0) {
            
          //Map to hold the contacts
          Map<Id, Contact> mapContacts = new Map<Id, Contact>();
            
            //Loop through contact records and populate the mapContacts
            for(Contact con : [Select Id, Employee_User_Record__c 
                               FROM Contact WHERE Employee_User_Record__c != null
                               AND Employee_User_Record__c IN : setOfUsersIds]) {
                mapContacts.put(con.Employee_User_Record__c, con);
            }
            
            //loop over the new meeeting Utilizations records
            for(Meeting_Utilization__c muu : meeetinUtilizations) {
                
		//Populate the Department_Authorization_Contact__c
		if(muu.Department_Authorization__c != null
                  && mapContacts.containsKey(muu.Department_Authorization__c)
                )
                    muu.Department_Authorization_Contact__c = mapContacts.get(muu.Department_Authorization__c).ID;
                else
                    muu.Department_Authorization_Contact__c = null;
                
                //Populate the Requester_Name_Contact__c
                if(muu.Requester_Name__c != null
                  && mapContacts.containsKey(muu.Requester_Name__c)
                )
                    muu.Requester_Name_Contact__c = mapContacts.get(muu.Requester_Name__c).ID;
                else
                    muu.Requester_Name_Contact__c = null;
            }    
        }*/
    }
        //Commented By - Chirag Soni - 07/27/2021  - CR-20210511-15133 - Travel compensation request related changes moved to RegistrationHelper - Till Here
		
		//Changes as per CR-20190419-13012
		//Check for size
		if(setOfMembershipIds.size() > 0){  

			//Map to hold the memberships
			Map<Id, Membership__c> mapMemberships = new Map<Id, Membership__c>([Select Id, Active_Contract_Main_Contact__c from Membership__c where Id IN : setOfMembershipIds AND Active_Contract_Main_Contact__c != null]);

			//Check for size
			if(mapMemberships != null && mapMemberships.size() > 0){

				//Loop through meeting utilizations
				for(Meeting_Utilization__c mu : meeetinUtilizations) {
                    			//Check for condition
					if( mu.Start_Date__c >= system.Today() && mu.Membership__c != null && mu.Contact__c != null && mapMemberships.containsKey(mu.Membership__c) && mu.Contact__c == mapMemberships.get(mu.Membership__c).Active_Contract_Main_Contact__c){
						
                        			//Populate the main pointt of contact
                        			mu.Main_Point_of_Contact__c = true;
					}
				}
			}	
		}
    }
    
    // get the number of meetings in the last 12 months for a given list of Utilization records
    public static void UpdateMeetingSummary(Set<Id> membershipIds) {
        // get all of the membership/opportunity records we are going to update
        List<Membership__c> memberships = FindMemberships(membershipIds);
        // pass these memberships on to the method that is going to process them
        UpdateMeetingSummary(memberships);
    }
    
    public static String UpdateMeetingSummary(List<Membership__c> memberships) {
        
        /** Commented by Abhinav Sharma 
            Added new logic to remove SOQL queries **/
        // now we have all Memberships with Memberships.Opportunities and Memberships.Meeting_Utilizations
        /*for (Membership__c membership : memberships) {
            // clear out the existing count fields
            membership.Membership_Meeting_Util_last_12_Mo__c = 0;
            membership.Membership_Teleconf_Util_last_12_Mo__c = 0;
            membership.Next_Teleconf_Start_Date__c = null;
            membership.Next_Meeting_Start_Date__c = null;
            membership.Closest_Active_Meeting_End_Date__c = null;
            membership.Closest_Teleconf_End_Date__c = null;
            
            // set the number of meetings attended for this membership in the past 12 months
            // go through each membership to determine the next closest start/end date
            for (Meeting_Utilization__c meeting : membership.Meeting_Utilizations__r) {
                if (meeting.Start_Date__c < system.today())
                    membership.Membership_Meeting_Util_last_12_Mo__c++;
                
                if (membership.Next_Meeting_Start_Date__c == null && meeting.Start_Date__c >= system.today())
                    membership.Next_Meeting_Start_Date__c = meeting.Start_Date__c;
                else if (membership.Next_Meeting_Start_Date__c < meeting.Start_Date__c && meeting.Start_Date__c > system.today())
                    membership.Next_Meeting_Start_Date__c = meeting.Start_Date__c;
                
                if (membership.Closest_Active_Meeting_End_Date__c == null && meeting.End_Date__c >= system.today().addDays(-365))
                    membership.Closest_Active_Meeting_End_Date__c = meeting.End_Date__c;
                else if (membership.Closest_Active_Meeting_End_Date__c > meeting.End_Date__c)
                    membership.Closest_Active_Meeting_End_Date__c = meeting.End_Date__c;
            }
            for (Utilization_Data_Object__c teleconf : membership.Teleconference_Utilizations__r) {
                if (teleconf.Start_Date__c < system.today())
                    membership.Membership_Teleconf_Util_last_12_Mo__c++;
                
                if (membership.Next_Teleconf_Start_Date__c == null && teleconf.Start_Date__c >= system.today())
                    membership.Next_Teleconf_Start_Date__c = teleconf.Start_Date__c;
                else if (membership.Next_Teleconf_Start_Date__c < teleconf.Start_Date__c && teleconf.Start_Date__c > system.today())
                    membership.Next_Teleconf_Start_Date__c = teleconf.Start_Date__c;
                
                if (membership.Closest_Teleconf_End_Date__c == null && teleconf.End_Date__c >= system.today().addDays(-365))
                    membership.Closest_Teleconf_End_Date__c = teleconf.End_Date__c;
                else if (membership.Closest_Teleconf_End_Date__c > teleconf.End_Date__c)
                    membership.Closest_Teleconf_End_Date__c = teleconf.End_Date__c;
            }
            
            
        } 
        
        /***Upto Here*/
        
        //Added By Abhinav Sharma - 02/14/2014 - CR-20120823-1396 - Remove subquery in Batch_MeetingUtilizations
        
        //Map to hold "Membsership Id" as key and List<Meeting_Utilization__c> as value
        Map<Id, List<Meeting_Utilization__c>> mapMembershipWithMemberUtilizations = new Map<Id, List<Meeting_Utilization__c>>();

        //Loop through "Membership Utilization" records associated with membership record
        for(Meeting_Utilization__c mU : [Select Start_Date__c, End_Date__c, Id, Membership__c FROM Meeting_Utilization__c 
                                        WHERE (Start_Date__c >= LAST_N_DAYS:365) AND Membership__c IN : memberships]) {
    
            //Check if map already has a record for the membership, then add in existing list
            if(mapMembershipWithMemberUtilizations.containsKey(mU.Membership__c)) {
              
                //Get the Values of the Map and add record to it.
                mapMembershipWithMemberUtilizations.get(mU.Membership__c).add(mU);
            
            } else {
              
                //Create a new List at values and add record to it.
                mapMembershipWithMemberUtilizations.put(mU.Membership__c, new List<Meeting_Utilization__c>{mU});  
            }
        }
        
        //Map to hold "Membsership Id" as key and List<Utilization_Data_Object__c> as value
        Map<Id, List<Utilization_Data_Object__c>> mapMembershipWithTeleconferenceUtilizations = new Map<Id, List<Utilization_Data_Object__c>>();
    
        //Loop through "Membership Utilization" records associated with membership record
        for(Utilization_Data_Object__c tU : [SELECT ID, Start_Date__c, End_Date__c, Membership__c FROM Utilization_Data_Object__c 
                                                    WHERE (Start_Date__c >= LAST_N_DAYS:365) AND Membership__c IN : memberships]) {
            
            //Check if map already has a record for the membership, then add in existing list
            if(mapMembershipWithTeleconferenceUtilizations.containsKey(tU.Membership__c)) {
              
                //Get the Values of the Map and add record to it.
                mapMembershipWithTeleconferenceUtilizations.get(tU.Membership__c).add(tU);
            
            } else {
              
                //Create a new List at values and add record to it.
                mapMembershipWithTeleconferenceUtilizations.put(tU.Membership__c, new List<Utilization_Data_Object__c>{tU});  
            }
        }

        //Loop through membership records
        for (Membership__c membership : memberships) {

            // clear out the existing count fields
            membership.Membership_Meeting_Util_last_12_Mo__c = 0;
            membership.Membership_Teleconf_Util_last_12_Mo__c = 0;
            membership.Next_Teleconf_Start_Date__c = null;
            membership.Next_Meeting_Start_Date__c = null;
            membership.Closest_Active_Meeting_End_Date__c = null;
            membership.Closest_Teleconf_End_Date__c = null;

            // set the number of meetings attended for this membership in the past 12 months
            // go through each membership to determine the next closest start/end date
            //Cheching if membership in current context have children "Teleconfrence Utilization" with it and if yes, then do all the calculations
            if(mapMembershipWithMemberUtilizations.get(membership.Id) != null) {
                    
                //Loop through children "Membership Utilization" records
                for (Meeting_Utilization__c meeting : mapMembershipWithMemberUtilizations.get(membership.Id)) {
        
                    if (meeting.Start_Date__c < system.today())
                        membership.Membership_Meeting_Util_last_12_Mo__c++;

                    if (membership.Next_Meeting_Start_Date__c == null && meeting.Start_Date__c >= system.today())
                        membership.Next_Meeting_Start_Date__c = meeting.Start_Date__c;
                    else if (membership.Next_Meeting_Start_Date__c < meeting.Start_Date__c && meeting.Start_Date__c > system.today())
                        membership.Next_Meeting_Start_Date__c = meeting.Start_Date__c;

                    if (membership.Closest_Active_Meeting_End_Date__c == null && meeting.End_Date__c >= system.today().addDays(-365))
                        membership.Closest_Active_Meeting_End_Date__c = meeting.End_Date__c;
                    else if (membership.Closest_Active_Meeting_End_Date__c > meeting.End_Date__c)
                        membership.Closest_Active_Meeting_End_Date__c = meeting.End_Date__c;
                }
            }

            //Cheching if membership in current context have children "Teleconfrence Utilization" with it and if yes, then do all the calculations
            if(mapMembershipWithTeleconferenceUtilizations.get(membership.Id) != null) {
                    
                //Loop through children "Teleconference Utilization" records
                for (Utilization_Data_Object__c teleconf : mapMembershipWithTeleconferenceUtilizations.get(membership.ID)) {
                
                    if (teleconf.Start_Date__c < system.today())
                        membership.Membership_Teleconf_Util_last_12_Mo__c++;

                    if (membership.Next_Teleconf_Start_Date__c == null && teleconf.Start_Date__c >= system.today())
                        membership.Next_Teleconf_Start_Date__c = teleconf.Start_Date__c;
                    else if (membership.Next_Teleconf_Start_Date__c < teleconf.Start_Date__c && teleconf.Start_Date__c > system.today())
                        membership.Next_Teleconf_Start_Date__c = teleconf.Start_Date__c;

                    if (membership.Closest_Teleconf_End_Date__c == null && teleconf.End_Date__c >= system.today().addDays(-365))
                        membership.Closest_Teleconf_End_Date__c = teleconf.End_Date__c;
                    else if (membership.Closest_Teleconf_End_Date__c > teleconf.End_Date__c)
                        membership.Closest_Teleconf_End_Date__c = teleconf.End_Date__c;
                }
            }
        }
        
        //String to hold the log Message
        String logMessage = '';
        
        // update the memberships
        if (memberships.size() > 0) {
            
            /** Added by Bhavi on 10/06/2012 - CR-20120913-1491 **/
            //Bypass triggers
            Util.BypassAllTriggers = true;
            /** Up To Here: Added by Bhavi on 10/06/2012 - CR-20120913-1491 **/
            
            //Modified By - Abhinav Sharma - 04/19/2014 - CR-20140331-4909
            if(System.isBatch()) {
                logMessage = Util.createLog(Database.update((memberships),false));
            } else {
                update memberships;
            }
        }
        //Returning log message string
        return logMessage;
    }
    
    //Update by Abhinav Sharma - Updated to remove SOQL queries 
    //CR-20120823-1396 - 02/14/2014 - Remove subquery in Batch_MeetingUtilizations
    public static List<Membership__c> FindMemberships(Set<Id> membershipIds) {
        List<Membership__c> membershipMap = [SELECT Name, Id, Membership_Meeting_Util_last_12_Mo__c, Membership_Teleconf_Util_last_12_Mo__c ,
                                            Next_Teleconf_Start_Date__c, Next_Meeting_Start_Date__c, Closest_Active_Meeting_End_Date__c, Closest_Teleconf_End_Date__c
                                            FROM Membership__c WHERE Id IN :membershipIds];
        return membershipMap;
    }
    
    /**
     *  @description    :   This method is to update the Interaction infomration on Institution Role
     *
     *  @args           :   List of new Member Utilizations records, Map of old Member Utilizations 
     *
     *  @return         :   void
     *
     **/
  /*  public static void UpdateInteractionInformation(List<Meeting_Utilization__c> newMeetingUtilizations, Map<Id, Meeting_Utilization__c> mapOldMeetingUtilizations) {
        
        //Create a set to hold teh contact Ids
        Set<Id> contactIds = new Set<Id>();
        
        //Check if Interaction information need to be updated
        //Insert Scenerio
        if(newMeetingUtilizations != null && mapOldMeetingUtilizations == null) {
            
            //Loop through the new Member Utilizations
            for(Meeting_Utilization__c meetingUtilization : newMeetingUtilizations) {
                
                //Check for the Contact Id
                if(meetingUtilization.Contact__c != null && meetingUtilization.Institution__c != null && meetingUtilization.Start_Date__c != null) {
                    
                    //Add new contact Id
                    contactIds.add(meetingUtilization.Contact__c);
                }
            }
        } else if(newMeetingUtilizations != null && mapOldMeetingUtilizations != null) {
            //Update Scenerio   
            //Loop through the new Member Utilizations
            for(Meeting_Utilization__c meetingUtilization : newMeetingUtilizations) {
                
                //Check for the Contact Id
                //if Contact__c, Institution__c or CallType changed
                if(meetingUtilization.Contact__c != null && meetingUtilization.Institution__c != null 
                    && (meetingUtilization.Contact__c != mapOldMeetingUtilizations.get(meetingUtilization.Id).Contact__c 
                        || meetingUtilization.Institution__c != mapOldMeetingUtilizations.get(meetingUtilization.Id).Institution__c
                        || meetingUtilization.Start_Date__c != mapOldMeetingUtilizations.get(meetingUtilization.Id).Start_Date__c)
                ) {
                    
                    //Add Old contact Id 
                    if(meetingUtilization.Contact__c != mapOldMeetingUtilizations.get(meetingUtilization.Id).Contact__c && mapOldMeetingUtilizations.get(meetingUtilization.Id).Contact__c != null)
                        contactIds.add(mapOldMeetingUtilizations.get(meetingUtilization.Id).Contact__c);
                    
                    //Add new contact Id
                    contactIds.add(meetingUtilization.Contact__c);
                }
            }
        } else if(newMeetingUtilizations == null && mapOldMeetingUtilizations != null) {
            //Delete Scenerio
            //Loop through the new Member Utilizations
            for(Meeting_Utilization__c meetingUtilization : mapOldMeetingUtilizations.values()) {
                
                //Check for the Contact Id
                if(meetingUtilization.Contact__c != null && meetingUtilization.Institution__c != null && meetingUtilization.Start_Date__c != null) {
                    
                    //Add new contact Id
                    contactIds.add(meetingUtilization.Contact__c);
                }
            }
        }
        
        //Chekc if Institution Roles need to be updated
        if(contactIds.size() > 0)
             InstitutionRoleTriggerHelper.UpdateInteractionInformationByContactIds(null, contactIds, true);
    }*/
   
    //Commented By Abhinav Sharma - sentEmailTOAllTravelMemberReceipients - CR-20170915-11367 - 03/21/2018
    // Added By Mahendra Swarnkar - 08/14/2017 - CR-20170509-10928
    /**
     *  @description    :   This method is to Sent an email to all the receipients on the Record Requester Name (//Contact, //Department Authorization) (merged the email alert "Travel Compensation Request - Approved")
     *
     *  @args           :   List of new Member Utilizations records, Map of old Member Utilizations 
     *
     *  @return         :   void
     *
     **/
  /*  public static void sentEmailTOAllTravelMemberReceipients(List<Meeting_Utilization__c> newMeetingUtilizations, Map<Id, Meeting_Utilization__c> mapOldMeetingUtilizations) {
        
        //Set to hold the eligible meeting utilization record Id
    Set<Id> listEligibleMeetingUtilizationIds = new Set<Id>();
        
        //Loop over the meeting utilization records
        for(Meeting_Utilization__c mu : newMeetingUtilizations) {
            
            //Check for uodate Use case
            if(mapOldMeetingUtilizations != null) {
                
                //CHeck for Approval Status change
                if(mu.Approval_Status__c == 'Approved' 
                   && mu.Approval_Status__c != mapOldMeetingUtilizations.get(mu.Id).Approval_Status__c
                ) {
                    //Populate the set
                    listEligibleMeetingUtilizationIds.add(mu.Id);
                }
            }
        }
        
        //Check for size
        if(listEligibleMeetingUtilizationIds.size() > 0 ) {
          
            //Map to hold the eligible meeting utilization records
      Map<Id, Meeting_Utilization__c> mapEligibleMeetingUtilizationRecords = new Map<Id, Meeting_Utilization__c>();
            
            //Map to hold the meeting utilization recordId with list of "To Addresses"
      Map<Id, List<String>> mapMeetingUtilizationIdWithListOfToAddress = new Map<Id, List<String>>();
            
            //Query over the meeting utilization records
            for(Meeting_Utilization__c mUtili : [Select Id, Name, Start_Date__c, Institution__c, Institution__r.Name,
                                                   Contact__c, Contact__r.Name, Contact__r.Email,
                                                   Department_Authorization__c, Department_Authorization__r.Name, Department_Authorization__r.Email,
                                                   Requester_Name__c, Requester_Name__r.Name, Requester_Name__r.Email
                                                  From Meeting_Utilization__c 
                                                   where Id IN : listEligibleMeetingUtilizationIds
                                                  AND Approval_Status__c =: 'Approved']
      ) {
        
                //Populate the map
                mapEligibleMeetingUtilizationRecords.put(mUtili.Id, mUtili);
                
                //List to hold the To Email Address
        Set<String> setToEmailAddress = new Set<String>(); */
          
        //Check for emails fields on contact/Users records and then populate the list of To email Addresses 
                /*if(mUtili.Contact__c != null
                    && String.isNotBlank(mUtili.Contact__r.Email) ) 
                {
                    //populate the list of To email Addresses
                    setToEmailAddress.add(mUtili.Contact__r.Email);
                } */
                
              //Check for emails fields on contact/Users records and then populate the list of To email Addresses 
            /*     if(mUtili.Department_Authorization__c != null
                    && String.isNotBlank(mUtili.Department_Authorization__r.Email) )
                {
                    //populate the list of To email Addresses
                    setToEmailAddress.add(mUtili.Department_Authorization__r.Email);
                }
              
                //Check for emails fields on contact/Users records and then populate the list of To email Addresses 
                if(mUtili.Requester_Name__c != null
                    && String.isNotBlank(mUtili.Requester_Name__r.Email) )
                {
                    //populate the list of To email Addresses
                    setToEmailAddress.add(mUtili.Requester_Name__r.Email);
                }
                
                //Cnverting Set of string into the list of String
                List<String> listToEmailAddress = new List<String> ();
                listToEmailAddress.addAll(setToEmailAddress);
                
                //Populate the map
                mapMeetingUtilizationIdWithListOfToAddress.put(mUtili.Id, listToEmailAddress);
            }
            
            //Check for size
            if(mapEligibleMeetingUtilizationRecords.size() > 0) {
      
                //List of emails
        List<Messaging.SingleEmailMessage> listOfMail = new List<Messaging.SingleEmailMessage>();
                
                //loop over the meeting utlization
                for(Meeting_Utilization__c mUtil : mapEligibleMeetingUtilizationRecords.values()) {
                    
                    //Check for condition
                    if(mapMeetingUtilizationIdWithListOfToAddress.containsKey(mUtil.Id)
                        && mapMeetingUtilizationIdWithListOfToAddress.get(mUtil.Id) != null
                        && mapMeetingUtilizationIdWithListOfToAddress.get(mUtil.Id).size() > 0
                    ) { 
                        String travelMemberRequestDetailURL = '';
                        
                        //Check for Production Istance.
                        if(Util.IS_PRODUCTION_INSTANCE)
                          travelMemberRequestDetailURL = Label.MemberTravelCompensationSiteProductionURL + '?id=' + mUtil.Id+'&Instance=Production';
            else
                            travelMemberRequestDetailURL = Label.MemberTravelCompensationSiteSBURL + '?id=' + mUtil.Id+'&Instance=SandBox';
                        
                        //Create an Instance of Email
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail.setToAddresses(mapMeetingUtilizationIdWithListOfToAddress.get(mUtil.Id));
                        
                        //String to hold the email subjects
                        String emailSub = 'Travel Compensation Request: ' + mUtil.Name + ' Has Been Approved.';
                        
                        //Set the Subject of the email
                      mail.setSubject(emailSub);
                      mail.setPlainTextBody('');
                        
                        //String to hold the EMail Content/Body
                        String htmlString = 'Hi ';
                        if(mUtil.Requester_Name__c != null){
                            htmlString += mUtil.Requester_Name__r.Name;
                        }
                        htmlString += ',<br/><br/>';
                        
                        htmlString += 'The travel request you submitted regarding Travel Assistance for ';
                        if( mUtil.Contact__c != null ) {
                          htmlString += '<B>'+ mUtil.Contact__r.Name +'</B>';
                        }
                        htmlString += ', ';
                        if( mUtil.Institution__c != null ) {
                          htmlString += '<B>'+mUtil.Institution__r.Name+'</B>';
                        }
                        
                        
                        htmlString += ' regarding the <a href="'+System.Url.getSalesforceBaseUrl().toExternalForm()+'/'+mUtil.Id+'" ><B>'+mutil.Name+'</B></a> on ';
                        if(mutil.Start_Date__c !=  null){
                            Date d = mutil.Start_Date__c;
                            htmlString += d.month() + '/' + d.day()+ '/' + d.year();
                        }
                        htmlString += ' has been approved. To view this request, please ';
                        htmlString += '<a href="'+System.Url.getSalesforceBaseUrl().toExternalForm()+'/'+mUtil.Id+'" >click here</a>. <br/><br/>';
                        
                        system.debug('#####System.Url.getSalesforceBaseUrl():: ' + (System.Url.getSalesforceBaseUrl().toExternalForm()) +'/'+mUtil.Id );
                        
                        htmlString += '<B>Please click the following link to trigger the travel arrangement emails that get sent to the member and Balboa:- </B> ';
                        htmlString += '<a href="'+travelMemberRequestDetailURL+'" > '+travelMemberRequestDetailURL+'</a>. ';
                        htmlString += 'After clicking this link, you can close the tab.<br/><br/>';
                        
                        htmlString += 'Please let ';
                        if(mutil.Department_Authorization__c != null ){
              htmlString += mutil.Department_Authorization__r.Name;
                        }
                        htmlString += ' know if you have any questions.<br/><br/>';
                      
                        htmlString += 'Thanks.<br/><br/>';
                      
                        //Set the Emails Body
                      mail.setHtmlBody(htmlString);
                    
                        //Add email to the list
                        listOfMail.add(mail);
                    }
                }
                
                //Check for the size
                if(listOfMail.size() > 0 )
                    
                    //Sent the Emails
                    Messaging.sendEmail(listOfMail);
            }
        }
    } */
    
    //Added By Mahendra Swarnkar - 08/17/2017 - CR-20170509-10928 
  /**
     *  @description    :   This method is used to invoke the Approval Process. 
     *
     *  @args           :   List Meeting_Utilization__c, old Map Meeting_Utilization__c
     *
     *  @return         :   
     *
     *  @Version        :   V1.0 - Commented By - Chirag Soni - 07/27/2021  - CR-20210511-15133 - Travel compensation request related changes moved to RegistrationHelper
     **/
    /*public static void startsApproval(List<Meeting_Utilization__c> newMeetingUtilizations, Map<Id, Meeting_Utilization__c> mapOldMeetingUtilizations) {
        
        //Set to hold the esclated record Ids
        Set<Id> esclatedRecordIds = new Set<Id>();
        
        //Map to hold the esclated record Id with their Entity Type
        Map<Id, String> mapEsclatedRecordIdWithEntityValue = new Map<Id, String>();
        
        //Set to hold the Eligible record Ids
        Set<Id> eligibleRecordIds = new Set<Id>();
        
        //Loop over the Pss records
        for(Meeting_Utilization__c mUtil : newMeetingUtilizations) {
           
            //For Insert and Update case
            if(mUtil.Department_Authorization__c != null
                 && mUtil.Start_Date__c != null
                && mUtil.Travel_Assistance_Request__c == true 
                 && (
                    mapOldMeetingUtilizations == null
                    ||
                    (
                      mapOldMeetingUtilizations != null
                        &&
                        (
                            mUtil.Travel_Assistance_Request__c !=  mapOldMeetingUtilizations.get(mUtil.id).Travel_Assistance_Request__c
                            ||
                          mUtil.Start_Date__c !=  mapOldMeetingUtilizations.get(mUtil.id).Start_Date__c
                            ||
                            (
                                mUtil.Is_Esclated__c == true
                                &&
                                mUtil.Is_Esclated__c !=  mapOldMeetingUtilizations.get(mUtil.id).Is_Esclated__c
                            )
                        )
                    )
        )
      ) {
                
                //Check for the condition if the Meeting Utilization records fall under the Standartd Travell Approval Process, Then kick starts the  Standartd Travell Approval Process for these records
                if((mUtil.Start_Date__c).addDays(-7) >= System.today()) {
                   
                    // create the new approval request to submit
                    Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                    
                    //Specific approver
                    req.setObjectId(mUtil.Id);
                    
                    //Modified By Mahendra Swarnkar - 1/23/2018 - CR-20180116-11885 - updated to have check for Entity__c == 'All'
                    //Modified By Mahendra Swarnkar - 10/27/2017 - CR-20171018-11725 - Separate out the Approval processes for EAB and HC - Starts from here
                    if(mUtil.Entity__c == 'EAB' || mUtil.Entity__c == 'All'){
                        req.setProcessDefinitionNameOrId('Travel_Compensation_Non_Escalated');
                    } else {
                        if(mUtil.Entity__c == 'HC')
                          req.setProcessDefinitionNameOrId('Travel_Compensation_Non_Escalated_HC');
                    }
                    //Modified By Mahendra Swarnkar - 10/27/2017 - CR-20171018-11725 - Separate out the Approval processes for EAB and HC - Ends here    
                        
                    
                    req.setSkipEntryCriteria(true);
                    req.setComments('');
                    
                    //Process the Approval process.
          Approval.ProcessResult result = Approval.process(req);
                }
                else {
                    //Check for the esclated meeting utilization records  
                    //compare the statrts date 
                    if((mUtil.Start_Date__c).addDays(-7) < System.today()  ){
                    
                        //Check for the approval status if pending then add them in to the esclated set i.e which are already in the standard travell approval Process but esclated due to date 
                        if( mapOldMeetingUtilizations != null && mUtil.Approval_Status__c == 'Pending' ) {
                          esclatedRecordIds.add(mUtil.Id);
                            mapEsclatedRecordIdWithEntityValue.put(mUtil.Id, mUtil.Entity__c);
            }
                        else{
                            
                            //starts the Esclated approval Process for newly created esclated Meeting Utilization records
                            if(mapOldMeetingUtilizations == null 
                                 || ( mapOldMeetingUtilizations != null && String.isBlank(mUtil.Approval_Status__c))){
                             
                                // create the new approval request to submit
                                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                                
                                //Specific approver
                                req.setObjectId(mUtil.Id);
                
                                //Modified By Mahendra Swarnkar - 1/23/2018 - CR-20180116-11885 - updated to have check for Entity__c == 'All'
                //Modified By Mahendra Swarnkar - 10/27/2017 - CR-20171018-11725 - Separate out the Approval processes for EAB and HC - Starts from here
                                if(mUtil.Entity__c == 'EAB' || mUtil.Entity__c == 'All'){
                  req.setProcessDefinitionNameOrId('Travel_Compensation_Escalated');
                                } else {
                                    if(mUtil.Entity__c == 'HC')
                    req.setProcessDefinitionNameOrId('Travel_Compensation_Escalated_HC'); 
                                }
                //Modified By Mahendra Swarnkar - 10/27/2017 - CR-20171018-11725 - Separate out the Approval processes for EAB and HC - Ends here
                                
                req.setSkipEntryCriteria(true);
                                req.setComments('');
                                
                                //Process the Approval process.
                                Approval.ProcessResult result = Approval.process(req);
                            }
                        }
                    }
        }
            }
    }
    //Check for size
    if(esclatedRecordIds.size() > 0 && mapEsclatedRecordIdWithEntityValue.size() > 0) {
      
            //Set to hold the Process Instanceids
      Set<Id> setProcessInstanceIds = new Set<Id> ();
      
            //Query all the existing Approval Process Instances for Meeting Utilization
      for(ProcessInstance pi : [SELECT Id, TargetObjectId 
                                        FROM ProcessInstance 
                                        WHERE TargetObjectId IN : esclatedRecordIds 
                                        AND Status='Pending']
      ) {
                //Populate the set
        setProcessInstanceIds.add(pi.Id);
      }
      
            //Check for size
            if(setProcessInstanceIds.size() > 0) {
        
                //Query all the ProcessInstanceWorkitems related to the existing approval Process Instances
        for(ProcessInstanceWorkitem workItem : [SELECT Id, ProcessInstanceId, OriginalActorId, ActorId FROM ProcessInstanceWorkitem 
                                                        where ProcessInstanceId IN : setProcessInstanceIds]
                ) {
                    //String to hold the id
                    String OriginalActorIdstring = workItem.OriginalActorId;
                    
                    //Check for the Prefix and ten revoke/Recall the existing Approval Process
                    if(!OriginalActorIdstring.contains('00G')) {
                    
                        //Approval.ProcessWorkItemRequest req1 = new Approval.ProcessWorkItemRequest();
                        Approval.ProcessWorkItemRequest req1 = new Approval.ProcessWorkItemRequest();
                        req1.setWorkItemId(workItem.id);
                        req1.setAction('Removed'); // This means to remove/recall Approval Request
                        req1.setComments('Recall Approval Process.');
                        
                        System.debug('###setProcessInstanceIds : '+ setProcessInstanceIds + ' @@@@ workItem' + workItem);
                        Approval.ProcessResult result = Approval.process(req1);
                        
                    }
        }   
      }
            
            //loop over the esclated meeting Utilization requests and then kick starts the esclated Approval Process
      for(id mUtilId : esclatedRecordIds) {
        
        // create the new approval request to submit
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                
                //Specific approver
                req.setObjectId(mUtilId);
                req.setSkipEntryCriteria(true);
                req.setComments('');
                
                //Modified By Mahendra Swarnkar - 1/23/2018 - CR-20180116-11885 - updated to have check for Entity__c == 'All'
                //Modified By Mahendra Swarnkar - 10/27/2017 - CR-20171018-11725 - Separate out the Approval processes for EAB and HC - Starts from here
                if( mapEsclatedRecordIdWithEntityValue.containsKey(mUtilId) 
                     && String.isNotBlank(mapEsclatedRecordIdWithEntityValue.get(mUtilId)) 
                     && (mapEsclatedRecordIdWithEntityValue.get(mUtilId) == 'EAB' || mapEsclatedRecordIdWithEntityValue.get(mUtilId) == 'All') ) {
                    req.setProcessDefinitionNameOrId('Travel_Compensation_Escalated');
                } else {
                    if( mapEsclatedRecordIdWithEntityValue.containsKey(mUtilId) 
                        && String.isNotBlank(mapEsclatedRecordIdWithEntityValue.get(mUtilId)) 
                        && mapEsclatedRecordIdWithEntityValue.get(mUtilId) == 'HC')
                        req.setProcessDefinitionNameOrId('Travel_Compensation_Escalated_HC'); 
                }
                //Modified By Mahendra Swarnkar - 10/27/2017 - CR-20171018-11725 - Separate out the Approval processes for EAB and HC - Ends here
                
        //Process the Approval process.
        Approval.ProcessResult result = Approval.process(req);
      }
    }
  }*/
    
    // Added by - Mahendra Swarnakar - 09/07/2017 - CR-20170509-10928 
    /**
     *  @description    :   This method is used to  validate the approval process. 
     *
     *  @args           :   Map new Meeting Utilization,  Map old Meeting Utilization
     *
     *  @return         :   
     *
     *  @Version        :   V1.0 - Commented By - Chirag Soni - 07/27/2021  - CR-20210511-15133 - Travel compensation request related changes moved to RegistrationHelper
     **/
    /*
    public static void validateApprovalForDenyReason(map<Id, Meeting_Utilization__c> newMeetingUtilization,  map<Id, Meeting_Utilization__c> oldmapMeetingUtilization) {
        
        //Map to hold Meeting Utilization
        map<Id, Meeting_Utilization__c> mapMeetings = new map<Id, Meeting_Utilization__c>();
        
        // Build a list of rejected approval processes
        for ( Meeting_Utilization__c mu : newMeetingUtilization.values() )
        {
            //Check for Approver 
            if(mu.Department_Authorization__c != null){
             
                //Check for approval status 
                if ( 
                  (
                      mu.Approval_Status__c == 'Rejected' 
                  ) 
                    && mu.Approval_Status__c != oldmapMeetingUtilization.get( mu.Id ).Approval_Status__c
        ) {
                    //Populate the map pss
                    mapMeetings.put(mu.Id, mu);
                }
            }
        }
    
        //cHECK FOR size
        if (mapMeetings.size() > 0 )
        {
            //Map to hold the latest Approval
            map<Id, ProcessInstance> latestInstance = new map<Id, ProcessInstance>();
    
            //Query over the approval process with its steps
            for (ProcessInstance pi : [  SELECT TargetObjectId, Status, CreatedDate,
                                            (
                                            SELECT Id, ProcessInstanceId, StepStatus, Comments, CreatedDate
                                            FROM Steps
                                            WHERE StepStatus = 'Rejected'
                                            ORDER BY CreatedDate DESC
                                            )
                                            FROM ProcessInstance
                                            WHERE TargetObjectId In
                                            :mapMeetings.keySet()
                                            ORDER BY CreatedDate DESC
                                        ])
            {
          //Populate the map for latest Approval Instance
                if (!latestInstance.containsKey(pi.TargetObjectId))
                {
                    latestInstance.put(pi.TargetObjectId, pi);
                }
                else
                {
                    ProcessInstance maxInstance = latestInstance.get(pi.TargetObjectId);
                    if ( maxInstance.CreatedDate < pi.CreatedDate  )
                    {
                        latestInstance.put(pi.TargetObjectId, pi);
                    }
                }
            }
            
            //Check for map size
            if(latestInstance.size() > 0){
             
                // only process the latest processInstance for any Meeting Utilization
                for ( ProcessInstance pi : latestInstance.values())
                {
                    //instance of Latest Process instance step 
                    ProcessInstanceStep latestPis = new ProcessInstanceStep();
                    
                    //Only process the latest step of any processInstance
                    for ( ProcessInstanceStep pis : pi.Steps)
                    {
                        //Check for lattest Instance
                        if ( latestPis.Id == null)
                        {
                            latestPis = pis;
                        }
                        else
                        {
                            //Compare the created date of processInstances to find the lattest ProcessInstance
                            if ( latestPis.CreatedDate < pis.CreatedDate)
                            {
                                latestPis = pis;
                            }
                        }
                    }
                        
                    //Check for the Meeting Utilization object
                    if(mapMeetings.get(pi.TargetObjectId) != null) 
                    {
                        //Check for the approval is rejected or approved by the latest step status
                        if ( latestPis.StepStatus == 'Rejected' ) 
                        {
                            //validate the Comment
                            if(latestPis.Comments == null 
                                || latestPis.Comments.trim().length() == 0
                                
                            ) {
                                //String to hold the error message
                                String errorMessage = '';
                                
                                //Check for Comment field value on approval VF page
                                if(latestPis.Comments == null || latestPis.Comments.trim().length() == 0)
                                    errorMessage = errorMessage + System.label.Meeting_Utilization_Approval_Rejected_Error;
                                    
                                //bind the error message to the Meeting Utilization
                                mapMeetings.get(pi.TargetObjectId).addError(errorMessage);      
                            }
                        }
                    }
                }
            }    
        }
  }*/
  
  /**
     *  @description    :   This method is used to  create Meeting Utilization MtM. 
     *
     *  @args           :   List new Meeting Utilization
     *
     *  @return         : 
     * 
     *   @createdBy    :   Dipesh Gupta - 10/10/2019 - CR-20190626-13199
     *
     **/
    public static void createMUMTM(List<Meeting_Utilization__c> meetingUtilizations) {
        
        //Set of Eab Event ids 
        Set<Id> setEabEventIds = new Set<Id>();
        
        //Loop over new Meeting_Utilization__c
        for(Meeting_Utilization__c mU : meetingUtilizations){
            
            //Check for EAB_Event__c
            if(mu.EAB_Event__c != null){
                
                //Adding Ids into set
                setEabEventIds.add(mU.EAB_Event__c);
            }
        }
        
        //Check on set of Eab Event Ids
        if(setEabEventIds.Size() > 0){
            
            //list of Meeting_Utilization_MtM__c which has to be insert 
            List<Meeting_Utilization_MtM__c> mUMTMToBeInserted = new List<Meeting_Utilization_MtM__c>();
            
            //Map of Eab event Id with Event Rule  
            Map<Id, List<Event_Rule__c>> mapEabEventIdwithER = new Map<Id, List<Event_Rule__c>>();
            
            //Loop over related Event Rules 
            for(Event_Rule__c eR : [SELECT Id, Advisory_Event__c FROM Event_Rule__c WHERE Advisory_Event__c != Null AND Rule__r.RecordType.DeveloperName='Program' AND Advisory_Event__c IN: setEabEventIds ]){
                
                //Check of Id contains
                if(!mapEabEventIdwithER.containsKey(eR.Advisory_Event__c))
                    mapEabEventIdwithER.put(eR.Advisory_Event__c, new List<Event_Rule__c>());
                               
                //Putting values into Map 
                mapEabEventIdwithER.get(eR.Advisory_Event__c).add(eR);
            }
            
            //Map size check 
            if(mapEabEventIdwithER.Size() > 0){
                
                //Loop over Meeting_Utilization__c
                for(Meeting_Utilization__c mU : meetingUtilizations){
                    //Check of Eab Event Id contains
                    if(mapEabEventIdwithER.containsKey(mU.EAB_Event__c)){
                        
                        //Loop over Event Rule to create Meeting_Utilization_MtM__c
                        for(Event_Rule__c  eR : mapEabEventIdwithER.get(mU.EAB_Event__c)){
                             
                            //Adding new Meeting_Utilization_MtM__c which has to be insert 
                            mUMTMToBeInserted.add(new Meeting_Utilization_MtM__c(Event_Rule__c = eR.ID, Meeting_Utilization__c= mU.Id/*, Membership__c = mU.Membership__c*/));
                        }
                    }
                }
            }
            
            //Check of null  
            if(mUMTMToBeInserted.size()>0){
                
                //Inserting new Meeting_Utilization_MtM__c
                insert mUMTMToBeInserted;
            }
        } 
    }
}