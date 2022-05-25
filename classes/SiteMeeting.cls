/**
 * Desription      :   This class is used to store the helper methods for site meeting functionality on eab.com.
 * 
 * Revision Logs   :   V1.0 - Created
 * 		       V1.1 - 03/31/2016 - Abhinav Sharma - CR-20160309-9686
 * 		       V1.2 - 06/11/2019 - Victor Hanson - CR-20190611-13177 - updated to use eab.com Encryption & updated class name
 * 		       V1.3 - 09/27/2019 - Victor Hanson - CR-20190927-13374 - modified upsertRegistration
 * 		       V1.4 - 03/25/2020 - Victor Hanson - CR-20200324-13884 - added references to registration cap & current registration count
 * 		       V1.5 - 03/30/2020 - Victor Hanson - CR-20200330-13895 - updated populateMeetingWrapper to populate meeting_guid
 * 		       V1.6 - 09/27/2019 - Abhinav Sharma - CR-20200729-14382 - modified upsertRegistration - to add check for Event Type Cohort
 * 		       V1.7 - 09/23/2020 - Saurabh Kumar - CR-20200819-14449 - Updated following fields
 *									       from Date_Begins__c to Begins__c from Date_Ends__c to Ends__c
 *									       Removed the reference of Meeting__c
 * 		       V1.8 - 10/08/2020 - Saurabh Kumar - CR-20200819-14447 - Updated following stuff to replace the reference from Meeting__c to Advisory_Event__c
 *									       FindMeetingsByUser()
 *									       DeleteRegistration()
 *									       Registration//Wrapper class
 *									       Registration()//Constructor
 *									       MeetingWrapper//Wrapper calss
 *									       upsertRegistration()
 *									       FindRegisteredSubMeetings()
 *									       FindAllSubMeetings()
 *									       FindMeetings()
 *									       populateMeetingWrapper()
 *									       checkMeetingSync()
 * 		       V1.9 - 11/09/2020 - Saurabh Kumar - CR-20201105-14664 - 
 *									       1. Replaced Type with Event Type in following methods
 *									       FindMeetingsByUser()
 *									       populateMeetingWrapper()
 *									       FindRegisteredSubMeetings() 
 *									       FindAllSubMeetings()
 *									       2. Removed Description_Public__c
 *									       checkEventSync()
 * 		       V2.0 - 01/08/2020 - Saurabh Kumar - CR-20210106-14781
																				1. Updated MeetingWrapper: Added a new attribute WebsiteTagID.
																				2. Updated FindMeeings method: Replaced Meeting_GUID__c(MeetingGUID) with Website_Tag__c(WebsiteTagID).
 * 		       V2.1 - 06/08/2021 - Chirag Soni - CR-20210224-14940 - QA&UAT Issues (MRS 2.0 Phase 2/3) #36 : Updated method upsertRegistration - Created Dynamic Query in place of existing registration query. 
 * 		       V2.2 - Modified By - Lawrence Lam - CR-20210614-15211
 * 		       V2.3 - 2/8/2022 - Chirag Soni - CR-20220207-15771 - Added two new fields in Meeting class and updated the method populateMeetingWrapper()
 **/ 
public without sharing class SiteMeeting {
    
    public String DecryptedString { get; set; }
    public SiteUser sUser {
        get {
            if (sUser == null) sUser = new SiteUser();
            return sUser;
        }
        set;
    }
    
    // object to hold meeting data
    public class Meeting {
        public Meeting() {}
        public String name { get; set; }
        public String eabEventType { get; set; }
        public String type { get; set; }
        public String parentMeetingId { get; set; }
        public String id { get; set; }
        public String start_dateTime { get; set; }
        
        //Added By - Abhinav Sharma - 03/31/2016 - CR-20160309-9686
        //Start from here
        public String status { get; set; }
        //Upto here
        
        //Added - CR-20220207-15771 - 2/8/2022 - Chirag Soni - Added two new fields Meeting class
        public String time_zone_keyword { get; set; }
        public String website_keyword { get; set; }
              
        //Added By - Victor Hanson - 06/12/2019 - CR-20190611-13177
        //Primary Program from the meeting's related EAB Event
        public String primaryProgramId { get; set; }
        public String publicName { get; set; }
        public String startDate { get; set; }
        public String endDate { get; set; }
        public String publicDescription { get; set; }
        public String city_state { get; set; }
        public String end_dateTime { get; set; }
        public boolean nearCapacity { get; set; }
        
        public Decimal registration_cap { get; set; }
        public Decimal current_registration_count { get; set; }
        public String meeting_guid { get; set; }
        
        //Added By Dipesh Gupta - CR-20200406-13910
        public Boolean show_time{get; set;}

        //Added By - Victor Hanson - 06/12/2019 - CR-20190611-13177
        //web program access
        public List<SiteUser.WebProgramAccess> webProgramAccessList {
            get {
                if (webProgramAccessList == null) webProgramAccessList = new List<SiteUser.WebProgramAccess>();
                return webProgramAccessList;
            }
            set;
        }
    }
    
    // object to hold registration data
    public class Registration {
        public Registration() {}
        public Registration(Registration__c registration) {
            //Updated by Victor Hanson - CR-20200819-14447 - 01/25/2021 - set EABEventId to EAB Event Id instead of GUID
            //Updated by Saurabh Kumat - CR-20200819-14447: Replaced this line with below line this.MeetingId = registration.Meeting__r.Meeting_GUID__c != null ? registration.Meeting__r.Meeting_GUID__c : registration.Meeting__c;
            this.EABEventId = registration.EAB_Event__c;
            this.Status = registration.Status__c;
            this.registrationId = registration.Id;
        }
        public String RegistrationId { get; set; }
        public String ContactId { get; set; }
        public String ContactName { get; set; }
        public String EABEventId { get; set; }//Updated by Saurabh Kumar - CR-20200819-14447 - 10/08/2020: updated from MeetingId to EABEventId
        public String Status { get; set; }
        
        public boolean shareInformation { get; set; }
        public boolean shareEmail { get; set; }
        public boolean shareFacebook { get; set; }
        public boolean shareFax { get; set; }
        public boolean shareImage { get; set; }
        public boolean shareInterests { get; set; }
        public boolean shareLinkedIn { get; set; }
        public boolean sharePhone { get; set; }
        public boolean sharePinterest { get; set; }
        public boolean shareTwitter { get; set; }
        
        public string prefix { get; set; }
        public string suffix { get; set; }
        public string firstName { get; set; }
        public string lastName { get; set; }
        public string displayName { get; set; } //advisory_com_name_tag
        public string title { get; set; }
        public string address1 { get; set; }
        public string address2 { get; set; }
        public string country { get; set; }
        public string email { get; set; }
        public string phone { get; set; }
        public string linkedin { get; set; }
        public string topicIds { get; set; }
        public string organization { get; set; }
        public string city { get; set; }
        public string zipCode { get; set; }
        public string state { get; set; }
        public string facebook { get; set; }
        public string pinterest { get; set; }
        public string twitter { get; set; }
        public string fax { get; set; }
    }
    
    // this is the main object we will be writing to and encrypting to send as a response
    public class MeetingWrapper {
        public String Command { get; set; }
        public String EABEventId { get; set; }//Updated by Saurabh Kumar - CR-20200819-14447 - 10/08/2020 : Replaced MeetingId with EABEventId
        public String MeetingGUID { get; set; }
        public String WebsiteTagID { get; set; }//Added by Saurabh Kumar - CR-20210106-14781 - 01/08/2020
        public String ParentMeetingGUID { get; set; }
        public String ContactId { get; set; }
        public String RegistrationId { get; set; }
        public String Status { get; set; }
        public String Response { get; set; }
        public String ParentMeetingId { get; set; }
        public String EndpointURL { get; set; }
        public String siteProfileId { get; set; }
        public MeetingWrapper() {}
        public List<Meeting> Meetings {
            get {
                if (Meetings == null)
                    Meetings = new List<Meeting>();
                return Meetings;
            }
            set;
        }
        
        public List<Registration> Registrations {
            get {
                if (Registrations == null)
                    Registrations = new List<Registration>();
                return Registrations;
            }
            set;
        }

        public Integer User_Id { get; set; }
    }
    
    
   /**
    *   
    *   the main functionality of the class begins here
    *   
    **/
    public MeetingWrapper mWrapper {
        get {
            if (mWrapper == null)
                mWrapper = new MeetingWrapper();
            return mWrapper;
        }
        set;
    }
    
    public SiteMeeting() { }

    // take in an encrypted request
    public SiteMeeting(String encryptedRequest) {
        try {
            // convert the string in to a blob to be decrypted
            //encryptedRequest = EncodingUtil.urlDecode(encryptedRequest, 'UTF-8');
            blob encryptedBlob = EncodingUtil.base64Decode(encryptedRequest);
            DecryptedString = EncryptionHelper.decrypt(encryptedBlob);
            system.debug('@@DecryptedString:' + DecryptedString);//NOPMD - 12/23/2020 - CR-20200819-14447 - Victor Hanson
            //VH 12/21/2020 - CR-20200819-14447 - We changed MeetingId -> EABEventId but changing it in WP will take additional time, so we will just translate the value for now
            DecryptedString = DecryptedString.replaceAll('"MeetingId"', '"EABEventId"');
            // convert this JSON Request in to our MeetingWrapper object
            mWrapper = (MeetingWrapper)JSON.deserializeStrict(DecryptedString, MeetingWrapper.class);
            
            // perform whatever action is being requested
            PerformAction();
            
        }
        catch(Exception ex) {
            mWrapper.Response = 'Error: ' + ex.getMessage() + ' on line number: ' + ex.getLineNumber();
        }
    }
    
    public void PerformAction() {
        
        //VH added 6/21/2019 for registration updates on EAB.com WP Site
        //get Contact Id
        if (mWrapper.User_Id != null) {
            List<Site_Profile__c> sProfiles = [SELECT Id, Contact__c, Username__c, User_Id__c, Last_Access__c, Verify__c,
                                               Verify_Date__c, Bypass_Domain_Validation__c, Password__c, Status__c, 
                                               Tokens_Available__c, Menu_Customizations__c
                                               FROM Site_Profile__c 
                                               WHERE User_Id__c = :String.valueOf(mWrapper.User_Id)];
            if (sProfiles != null) {
                mWrapper.ContactId = sProfiles[0].Contact__c;
                mWrapper.siteProfileId = sProfiles[0].Id;
                
                //VH added 08/07/2019 so the getUpdatedSiteUserDetails method has the details it needs to run successfully
                sUser.Site_Profile = sProfiles[0];
                sUser.Command = mWrapper.Command;
            }
        }

        // perform the requested action
        if (mWrapper.Command == null) mWrapper.Response = 'Error: Null is not a valid command';
        else if (mWrapper.Command.equalsIgnoreCase('FindMeetings')) FindMeetings();
        else if (mWrapper.Command.equalsIgnoreCase('FindRegistrations')) FindRegistrations();
        else if (mWrapper.Command.equalsIgnoreCase('FindRegisteredSubMeetings')) FindRegisteredSubMeetings();
        else if (mWrapper.Command.equalsIgnoreCase('FindAllSubMeetings')) FindAllSubMeetings();
        else if (mWrapper.Command.equalsIgnoreCase('upsertRegistration')) upsertRegistration();
        else if (mWrapper.Command.equalsIgnoreCase('DeleteRegistration')) DeleteRegistration();
        else if (mWrapper.Command.equalsIgnoreCase('FindMeetingsByUser')) FindMeetingsByUser();
        else {
            mWrapper.Response = 'Error: Unrecognized command: ' + mWrapper.Command;
        }
    }
    
    //Modified By - Abhinav Sharma - 03/31/2016 - CR-20160309-9686
    //Modified By - Saurabh Kumar - 10/08/2020 - CR-20200819-14447
    //Modified By - Saurabh Kumar - 11/09/2020 - CR-20201105-14664: Replaced Type__c with Event_Type__c
    public void FindMeetingsByUser() {
        
        // build the where clause
        String whereClause = '';
        
        // if the contact id is not present, return with error
        if (mWrapper.ContactId == null || mWrapper.ContactId == '') {
            mWrapper.Response = 'Contact Id is required.';
            return;
        }
        
        //Updated by Saurabh Kumar - 10/08/2020 - CR-20200819-14447 Replaced Meeting to EAB Event: Start
        // 1. find all registrations for that contact id
        List<Registration__c> registrations = [SELECT Id, EAB_Event__c, Status__c FROM Registration__c 
                                               WHERE Contact__c = :mWrapper.ContactId LIMIT 1000];
        
        //Map to hold the EAB Event Id as key and corresponding registration record as value
        Map<Id, Registration__c> eabEventToRegistrationMap = new Map<Id, Registration__c>();
        
        // 2. compile a list of all unique EAB Event ids
        //Set<Id> eabEventIdSet = new Set<Id>();
        
        //Loop through registration records as populating collections
        for (Registration__c reg : registrations) {
            if(reg.EAB_Event__c != null) {
                //eabEventIdSet.add(reg.EAB_Event__c);
                eabEventToRegistrationMap.put(reg.EAB_Event__c, reg);
            }
        }
        
        //Modified By - Saurabh Kumar - 11/09/2020 - CR-20201105-14664: Replaced Type__c with Event_Type__c
        // 3. Find all EAB Events based on the set of EAB Event ids
        List<Advisory_Event__c> eabEvents = [Select Id, Parent_Event__c, Begins__c, Ends__c, Name, Event_Type__c From Advisory_Event__c 
                                             Where Id IN : eabEventToRegistrationMap.keySet() Limit 1000];
        
        // Add all registrations to the registration list
        for (Advisory_Event__c item : eabEvents) {
            
            //Meeting class instance
            Meeting meeting = new Meeting();
            
            //Populating meeting class properties with appropriate values
            if(eabEventToRegistrationMap.containsKey(item.Id)
               && eabEventToRegistrationMap.get(item.Id) != null)
               meeting.status = eabEventToRegistrationMap.get(item.Id).Status__c;
            
            meeting.Id = item.Id;
            meeting.Name = item.Name;
            meeting.Type = item.Event_Type__c;//Modified By - Saurabh Kumar - 11/09/2020 - CR-20201105-14664: Replaced Type__c with Event_Type__c
            
            if (item.Begins__c != null)
                meeting.start_dateTime = item.Begins__c.format('MM/dd/yyyy hh:mm a', 'America/New_York');

            if (item.Ends__c != null)
                meeting.end_dateTime = item.Ends__c.format('MM/dd/yyyy hh:mm a', 'America/New_York');
            
            if (item.Parent_Event__c != null)
                meeting.ParentMeetingId = item.Parent_Event__c;
            
            // add this new registration to our list
            mWrapper.Meetings.add(meeting);
        }
        /*// 1. find all registrations for that contact id
        List<Registration__c> registrations = [SELECT Id, Meeting__c, Status__c FROM Registration__c 
                                                WHERE Contact__c = :mWrapper.ContactId LIMIT 1000];
        
        //Map to hold the meeting Id as key and corresponding registration record as value
        Map<Id, Registration__c> meetingToRegistrationMap = new Map<Id, Registration__c>();
        
        // 2. compile a list of all unique meeting ids
        Set<Id> meetingIdSet = new Set<Id>();
        
        //Loop through registration records as populating collections
        for (Registration__c reg : registrations) {
            if(reg.Meeting__c != null) {
                meetingIdSet.add(reg.Meeting__c);
                meetingToRegistrationMap.put(reg.Meeting__c, reg);
            }
        }
            
        // 3. Find all meetings based on the set of meeting ids
        List<Meeting__c> meetings = [SELECT Id, Parent_Meeting__c, DateTime__c, End_DateTime__c, Name, Type__c 
                                     FROM Meeting__c 
                                     WHERE Id IN :meetingIdSet LIMIT 1000];
        
        // Add all registrations to the registration list
        for (Meeting__c item : meetings) {
            
            //Meeting class instance
            Meeting meeting = new Meeting();
            
            //Populating meeting class properties with appropriate values
            if(meetingToRegistrationMap.containsKey(item.Id)
               && meetingToRegistrationMap.get(item.Id) != null)
               meeting.status = meetingToRegistrationMap.get(item.Id).Status__c;
            
            meeting.Id = item.Id;
            meeting.Name = item.Name;
            meeting.Type = item.Type__c;
            
            if (item.DateTime__c != null)
                meeting.start_dateTime = item.DateTime__c.format('MM/dd/yyyy hh:mm a', 'America/New_York');

            if (item.End_DateTime__c != null)
                meeting.end_dateTime = item.End_DateTime__c.format('MM/dd/yyyy hh:mm a', 'America/New_York');
            
            if (item.Parent_Meeting__c != null)
                meeting.ParentMeetingId = item.Parent_Meeting__c;
            
            // add this new registration to our list
            mWrapper.Meetings.add(meeting);
        }*/
        //Updated by Saurabh Kumar - 10/08/2020 - CR-20200819-14447 Replaced Meeting to EAB Event: End
        // set successful message
        mWrapper.Response = 'Success';
    }
    
    //Modified by Saurabh Kumar - 10/08/2020 - CR-20200819-14447: Replaced the Meeting reference with EAB Event
    // Delete a registration
    public void DeleteRegistration() {
        if (mWrapper.RegistrationId == null && (mWrapper.EABEventId == null || mWrapper.ContactId == null)) {
            mWrapper.Response = 'Registration Id or EAB Event Id and Contact Id are required.';
            return;
        }
        
        List<Registration__c> registrations = new List<Registration__c>();
        
        if (mWrapper.RegistrationId != null) {
            // find the Registration record
            registrations = [SELECT Id FROM Registration__c WHERE Id = :mWrapper.RegistrationId];
            if (registrations.size() == 0) {
                mWrapper.Response = 'Invalid Registration Id.';
                return;
            }
        }
        else {
            //Updated by Saurabh Kumar - CR-20200819-14447 - 10/08/2020 : Update query from Meeting to EAB Event
            // first, find the meeting record
            //List<Meeting__c> meetings = [SELECT Id, Parent_Meeting__c FROM Meeting__c WHERE Id = :mWrapper.MeetingId];
            List<Advisory_Event__c> eabEvents = [Select Id, Parent_Event__c From Advisory_Event__c Where Id =: mWrapper.EABEventId];
            if (eabEvents.size() == 0) {
                mWrapper.Response = 'Invalid Meeting Id.';
                return;
            }
            
            // second, find the contact record
            List<Contact> contacts = [SELECT Id, Name FROM Contact WHERE Id = :mWrapper.ContactId];
            
            if (contacts.size() == 0) {
                mWrapper.Response = 'Invalid Contact Id.';
                return;
            }
            //Updated by Saurabh Kumar - CR-20200819-14447 - 10/08/2020 : Update query from Meeting to EAB Event
            registrations = [SELECT Id FROM Registration__c WHERE Contact__c = :mWrapper.ContactId AND EAB_Event__c = :mWrapper.EABEventId];
        }
        
        try {
            delete registrations;
        }
        catch(Exception ex) {
            mWrapper.Response = 'Error:' + ex.getMessage();
            return;
        }
        
        // set successful message
        mWrapper.Response = 'Success';
    }
    
    /**
     * 
     * @description:    add or update a registration
     * 
     * @revisions  :    09/27/2019 - Victor Hanson - CR-20190927-13374 - set status to registered when meeting type is Web Conference
     * 		        04/02/2020 - Victor Hanson - CR-20200331-13896 - added check for Event Type to determine Registration Status
     *                  08/13/2020 - Abhinav sharma -CR-20200729-14382 - added check for Event Type "Cohort" to determine Registration Status 
     *		        10/08//2020 - Saurabh Kumar - CR-20200819-14447 - Replaced the reference of Meeting with EAB Event
     *              	06/08/2021 - Updated By - Chirag Soni - CR-20210224-14940 - QA&UAT Issues (MRS 2.0 Phase 2/3) #36 : Created Dynamic Query in place of existing registration query 
     **/
    public void upsertRegistration() {

        //Create a new list of registration to be inserted
        List<Registration__c> registrations = new List<Registration__c>(); 
        
        //Updated by Saurabh Kumar - CR-20200819-14447 - 10/08/2020 : Replaced MeetingId with EABEventId
        //check for null
        if (mWrapper.EABEventId == null || (mWrapper.User_Id == null && mWrapper.ContactId == null )) {
            mWrapper.Response = 'EAB Event Id and (User_Id or ContactId) are required.';
            return;
        }

        //VH 06/21/2019: Added getUser action to return all the user details
        sUser.User_Id = mWrapper.User_Id;
        
        try {
            //Updated by Saurabh Kumar - CR-20200819-14447 - 01/21/2021: Added logic to identify record Id and object type and using this in query.
            String meetingGUID = '';
            Id eabEventId;
            
            if ( Pattern.compile( '[a-zA-Z0-9]{15}|[a-zA-Z0-9]{18}' ).matcher( mWrapper.EABEventId ).matches() ){
                Id recordId = mWrapper.EABEventId;
                Schema.SObjectType token = recordId.getSObjectType();
                if(String.valueOf(token) == 'Advisory_Event__c')
                    eabEventId = recordId;
                else{
                    mWrapper.Response = 'Invalid EAB Event Id: '+mWrapper.EABEventId;
                    return;
                }
            }else
                meetingGUID = mWrapper.EABEventId;
            
            //01/21/2021 -  - Victor Hanson
            List<Registration__c> existingRegistrations;

            //Updated by Saurabh Kumar - CR-20200819-14447 - 10/08/2020 : Updated Meeting__c with EAB_Event__c: Start
            //see if a registration already exists
            if (mWrapper.User_Id != null) {
                
                //Updated By Chirag Soni - 06/08/2021 - CR-20210224-14940 - QA&UAT Issues (MRS 2.0 Phase 2/3) #36 : Commented below query becuase it is retriving existing registration based on OR conditions. Start here - 
                //remove previous query :- It is retriving existing registration of some other event based on blank meetingGUID if registration is not found for eabEventId
                
                
                String eventORmeetingGUID =  eabEventId != null ? 'EAB_Event__c = \''+eabEventId+'\'' : 'EAB_Event__r.Meeting_GUID__c = \''+meetingGUID+'\'';
                String queryRegistrations =  'SELECT Id, Status__c FROM Registration__c '+ 
                    						   'WHERE Contact__r.EAB_com_Site_Profile__r.User_Id__c = \''+String.valueOf(mWrapper.User_Id)+'\' '+
                    						          'AND EAB_Event__c != null AND '+ eventORmeetingGUID;
                
                // Query existing registrations
                existingRegistrations = Database.query(queryRegistrations);
                
                //Updated By Chirag Soni - QA&UAT Issues (MRS 2.0 Phase 2/3) #36 : Commented query becuase it is retriving existing registration based on OR conditions. End here - 
                
                //if registrations exist, set the registration ID so the existing record is updated
                if (existingRegistrations.size() > 0) {
                    mWrapper.RegistrationId = existingRegistrations[0].Id;
                }
            }
            
            //if registrationId is null, create the registration based on Contact + Meeting Id
            if (mWrapper.RegistrationId == null) {
                
                //12/23/2020 - CR-20200819-14447 - Victor Hanson - commented out because child event logic is in RegistrationHelper.createRegistrationsForChildEABEvents
                /*List<Advisory_Event__c> eabEvents = new List<Advisory_Event__c>();
                
                
                //Added by Bhavi Sharma - 02/22/2013 - CR-20130220-2539
                //Fetching all the child EAB Event records for mWrapper.EABEventId
                /*Map<Id, Advisory_Event__c> childL1EABEvents = new Map<Id, Advisory_Event__c>([SELECT ID FROM Advisory_Event__c 
                                            WHERE Parent_Event__c != null AND Parent_Event__c =: mWrapper.EABEventId ]);
                eabEvents.addAll(childL1EABEvents.values());
                // find all sub-child EAB Event
                Map<Id, Advisory_Event__c> childL2EABEvents = new Map<Id, Advisory_Event__c>([SELECT ID FROM Advisory_Event__c 
                                            WHERE Parent_Event__c != null AND Parent_Event__c IN :childL1EABEvents.keySet()]);
                eabEvents.addAll(childL2EABEvents.values());
                
                //Loop through the EAB Events
                for(Advisory_Event__c advisoryEvent : eabEvents){
                    
                    //Add new registration record
                    registrations.add(new Registration__c(EAB_Event__c = advisoryEvent.Id, Contact__c = mWrapper.ContactId, Status__c = mWrapper.Status, Origin__c = Constants.REGISTRATION_ORIGIN_EAB_DOT_COM));
                }*/
            
                // create/insert the meeting
                registrations.add(new Registration__c(EAB_Event__c = mWrapper.EABEventId, Contact__c = mWrapper.ContactId, Status__c = mWrapper.Status, Origin__c = Constants.REGISTRATION_ORIGIN_EAB_DOT_COM));
                
                /*
                List<Meeting__c> meetings = new List<Meeting__c>();
                
                //Added by Bhavi Sharma - 02/22/2013 - CR-20130220-2539
                //Fetching all the child meeting records for mWrapper.MeetingId
                Map<Id, Meeting__c> childL1Meetings = new Map<Id, Meeting__c>([SELECT ID FROM Meeting__c 
                                            WHERE Parent_Meeting__c != null AND Parent_Meeting__c =: mWrapper.MeetingId 
                                            AND  Auto_Subscribe__c = true ]);
                meetings.addAll(childL1Meetings.values());
                // find all sub-child meetings
                Map<Id, Meeting__c> childL2Meetings = new Map<Id, Meeting__c>([SELECT ID FROM Meeting__c 
                                            WHERE Parent_Meeting__c != null AND Parent_Meeting__c IN :childL1Meetings.keySet()
                                            AND  Auto_Subscribe__c = true ]);
                meetings.addAll(childL2Meetings.values());
                
                //Loop through the meetings
                for(Meeting__c meeting : meetings){
                    
                    //Add new registration record
                    registrations.add(new Registration__c(Meeting__c = meeting.Id, Contact__c = mWrapper.ContactId, Status__c = mWrapper.Status));
                }
            
                // create/insert the meeting
                registrations.add(new Registration__c(Meeting__c = mWrapper.MeetingId, Contact__c = mWrapper.ContactId, Status__c = mWrapper.Status));
                */
            }
            else {
                //01/21/2021 - - Victor Hanson - only update status to registration requested if it's not Registered.
                if (existingRegistrations.size() > 0 && 
                    (mWrapper.Status != Constants.REGISTRATION_STATUS_REGISTRATION_REQUESTED || 
                    (mWrapper.Status == Constants.REGISTRATION_STATUS_REGISTRATION_REQUESTED && existingRegistrations[0].Status__c != Constants.REGISTRATION_STATUS_REGISTERED))) 
                {
		    // Modified By - Lawrence Lam - CR-20210614-15211
                    Registration__c registrationToUpdate = new  Registration__c(Id=mWrapper.RegistrationId, Status__c = mWrapper.Status);
                    if(mWrapper.Status == Constants.REGISTRATION_STATUS_CANCELLED){
                        registrationToUpdate.Cancellation_Reason__c = 'Cancelled via EAB.com';
                    }
                    registrations.add(new Registration__c(Id=mWrapper.RegistrationId, Status__c = mWrapper.Status));
                }
            }
            

            //Check if there are records to insert
            if(registrations.size() > 0) {
                
                //12/22/2020 - CR-20200821-14465 - Victor Hanson - removed per Rachel: Invite List replaces this functionality [start here]
                //09/27/2019 - Victor Hanson - CR-20190927-13374 - check if any webConferences are being inserted
                /*Set<Id> eabEventIds = new Set<Id>();
                for (Registration__c reg : registrations)
                    eabEventIds.add(reg.EAB_Event__c);
                
                Map<Id, Advisory_Event__c> eabEventMap = new Map<Id, Advisory_Event__c>([SELECT Id, Event_Type__c FROM Advisory_Event__c WHERE Id IN :eabEventIds]);
                
                for (Registration__c reg : registrations) {
                    Advisory_Event__c eabEvent = eabEventMap.get(reg.EAB_Event__c);
                    
		    //08/13/2020 - Abhinav sharma -CR-20200729-14382 - added "Cohort" value in check
                    //check if the EAB Event is a web conference
                    if (eabEvent != null && 
                          (eabEvent.Event_Type__c == 'Web Conference'//Modified By - Saurabh Kumar - 11/09/2020 - CR-20201105-14664: Replaced Type__c with Event_Type__c
                        || eabEvent.Event_Type__c == 'Research Working Sessions' 
                        || eabEvent.Event_Type__c == 'Prospect Webinar' 
                        || eabEvent.Event_Type__c == 'Research Webinar'
			|| eabEvent.Event_Type__c == 'Cohort')) 
                    {
                        
                        //default status to registered for web conferences
                        //04/02/2020 - Victor Hanson - CR-20200331-13896 - added check for Event Type to determine Registration Status
                        if (reg.Status__c == 'Registration Requested') 
                        {
                            reg.Status__c = RegistrationHelper.STATUS_REGISTERED;
                            reg.Approval_Status__c = 'Approved';
                        }
                    }
                }
                */
                //12/22/2020 - CR-20200821-14465 - Victor Hanson - [end here]

                /*//09/27/2019 - Victor Hanson - CR-20190927-13374 - check if any webConferences are being inserted
                Set<Id> meetingIds = new Set<Id>();
                for (Registration__c reg : registrations)
                    meetingIds.add(reg.Meeting__c);
                
                Map<Id, Meeting__c> meetingMap = new Map<Id, Meeting__c>([SELECT Id, Type__c, EAB_Event__r.Event_Type__c FROM Meeting__c WHERE Id IN :meetingIds]);
                
                for (Registration__c reg : registrations) {
                    Meeting__c meeting = meetingMap.get(reg.Meeting__c);
                    
                    //08/13/2020 - Abhinav sharma -CR-20200729-14382 - added "Cohort" value in check
                    //check if the meeting is a web conference
                    if (meeting != null && 
                          (meeting.Type__c == 'Web Conference'
                        || meeting.EAB_Event__r.Event_Type__c == 'Research Working Sessions' 
                        || meeting.EAB_Event__r.Event_Type__c == 'Prospect Webinar' 
                        || meeting.EAB_Event__r.Event_Type__c == 'Research Webinar'
                        || meeting.EAB_Event__r.Event_Type__c == 'Cohort')) 
                    {
                        
                        //default status to registered for web conferences
                        //04/02/2020 - Victor Hanson - CR-20200331-13896 - added check for Event Type to determine Registration Status
                        if (reg.Status__c == 'Registration Requested') 
                        {
                            reg.Status__c = RegistrationHelper.STATUS_REGISTERED;
                            reg.Approval_Status__c = 'Approved';
                        }
                    }
                }*/
                //Updated by Saurabh Kumar - CR-20200819-14447 - 10/08/2020 : Updated Meeting__c with EAB_Event__c: End
                upsert registrations;
                
                // set the registration id
                mWrapper.RegistrationId = String.valueOf(registrations[registrations.size() - 1].Id).subString(0, 15);
            }
        }
        catch(Exception ex) {
            sUser.Response = 'Error:' + ex.getMessage();
            System.debug('site exception '+ex.getMessage()+' Line '+ex.getStackTraceString());
            return;
        }
        
        
        //VH 06/21/2019: Added getUser action to return all the user details
        sUser = SiteUserHelper.getUpdatedSiteUserDetails(mWrapper.ContactId, sUser);
        
        // set successful message
        sUser.Response = 'Success';
    }
    
    //Updated by Saurabh Kumar - CR-20200819-14447 - 10/08/2020 : Replaced Meeting__c to EAB_Event__c
    // find all attendees based on the information that was provided
    public void FindRegistrations() {
        
        // build the where clause
        String whereClause = '';
        
        //Updated by Saurabh Kumar - CR-20200819-14447 - 10/08/2020 : Replaced MeetingId to EABEventId
        // check to make sure we have the data we need to find registrations
        if ((mWrapper.RegistrationId == null || mWrapper.RegistrationId == '') && (mWrapper.EABEventId == null || mWrapper.EABEventId == '')) {
            mWrapper.Response = 'At least one of the following fields must be filled in: ContactId, RegistrationId, EABEventId';
            return;
        }
        
        //Updated by Saurabh Kumar - CR-20200819-14447 - 10/08/2020 : Replaced Meetin__c to EAB_Event__c
        if (mWrapper.EABEventId != null && mWrapper.EABEventId != '') {
            whereClause += 'EAB_Event__c = \'' + mWrapper.EABEventId + '\'';
        }
        if (mWrapper.RegistrationId != null && mWrapper.RegistrationId != '') {
            Id eabEventId;
            // first, find the registration record so we can get the EAB Event id
            List<Registration__c> registrations = [SELECT Id, EAB_Event__c FROM Registration__c WHERE Id = :mWrapper.RegistrationId];
            if (registrations.size() > 0) eabEventId = registrations[0].EAB_Event__c;
            if (whereClause != '') whereClause += ' OR ';
            whereClause += 'EAB_Event__c = \'' + eabEventId + '\'';
        }
        //Updated by Saurabh Kumar - CR-20200819-14447 : Replaced Meeting__c to EAB_Event__c
        string qryString = 'SELECT Id, Contact__c, Contact__r.Name, EAB_Event__c, Status__c, Contact__r.Salutation, Contact__r.Primary_City__c, Contact__r.Fax, Contact__r.Primary_State_Province__c, '
                        + 'Contact__r.FirstName, Contact__r.LastName, Contact__r.Suffix__c, Contact__r.Advisory_com_Name_Tag__c, Contact__r.Title, Contact__r.Advisory_com_Twitter__c, '
                        + 'Contact__r.Advisory_com_Share_LinkedIn__c, Contact__r.Advisory_com_Share_Phone__c, Contact__r.Advisory_com_Share_Pinterest__c, Contact__r.Advisory_com_Share_Twitter__c, '
                        + 'Contact__r.Advisory_com_Share_Facebook__c, Contact__r.Advisory_com_Share_Fax__c, Contact__r.Advisory_com_Share_Image__c, Contact__r.Advisory_com_Share_Interests__c, Contact__r.Advisory_com_Share_Information__c,'
                        + 'Contact__r.Primary_Address_Line_1__c, Contact__r.Primary_Address_Line_2__c, Contact__r.Primary_Country__c, Contact__r.Email, Contact__r.Advisory_com_Pinterest__c, '
                        + 'Contact__r.Phone, Contact__r.Advisory_com_LinkedIn__c, Contact__r.Advisory_com_Interests__c, Contact__r.Account.Account_Formal_Name__c, Contact__r.Primary_Postal_Code__c, Contact__r.Advisory_com_Share_Email__c '
                        + ' FROM Registration__c WHERE ' + whereClause + ' LIMIT 1000';
        List<Registration__c> registrations = database.query(qryString);
        
        // Add all registrations to the registration list
        for (Registration__c item : registrations) {
            Registration reg = new Registration();
            reg.RegistrationId = item.Id;
            reg.ContactId = item.Contact__c;
            reg.ContactName = item.Contact__r.Name;
            reg.EABEventId = item.EAB_Event__c;//Updated by Saurabh Kumar - CR-20200819-14447 : Replaced MeetingId to EABEventId
            reg.Status = item.Status__c;
            
            reg.prefix = item.Contact__r.Salutation;
            reg.suffix = item.Contact__r.Suffix__c;
            reg.firstName = item.Contact__r.FirstName;
            reg.lastName = item.Contact__r.LastName;
            reg.displayName = item.Contact__r.Advisory_com_Name_Tag__c;
            reg.title = item.Contact__r.Title;
            reg.address1 = item.Contact__r.Primary_Address_Line_1__c;
            reg.address2 = item.Contact__r.Primary_Address_Line_2__c;
            reg.state = item.Contact__r.Primary_State_Province__c;
            reg.country = item.Contact__r.Primary_Country__c;
            reg.email = item.Contact__r.Email;
            reg.phone = item.Contact__r.Phone;
            reg.linkedIn = item.Contact__r.Advisory_com_LinkedIn__c;
            reg.topicIds = item.Contact__r.Advisory_com_Interests__c;
            reg.organization = item.Contact__r.Account.Account_Formal_Name__c;
            reg.city = item.Contact__r.Primary_City__c;
            reg.zipCode = item.Contact__r.Primary_Postal_Code__c;
            //reg.facebook = item.Contact__r.Advisory_com_Facebook__c;
            reg.pinterest = item.Contact__r.Advisory_com_Pinterest__c;
            reg.twitter = item.Contact__r.Advisory_com_Twitter__c;
            reg.fax = item.Contact__r.Fax;
            
            reg.shareEmail = item.Contact__r.Advisory_com_Share_Email__c;
            reg.shareFacebook = item.Contact__r.Advisory_com_Share_Facebook__c;
            reg.shareFax = item.Contact__r.Advisory_com_Share_Fax__c;
            reg.shareImage = item.Contact__r.Advisory_com_Share_Image__c;
            reg.shareInformation = item.Contact__r.Advisory_com_Share_Information__c;
            reg.shareInterests = item.Contact__r.Advisory_com_Share_Interests__c;
            reg.shareLinkedIn = item.Contact__r.Advisory_com_Share_LinkedIn__c;
            reg.sharePhone = item.Contact__r.Advisory_com_Share_Phone__c;
            reg.sharePinterest = item.Contact__r.Advisory_com_Share_Pinterest__c;
            reg.shareTwitter = item.Contact__r.Advisory_com_Share_Twitter__c;
            
            // add this new registration to our list
            mWrapper.Registrations.add(reg);
        }
        // set successful message
        mWrapper.Response = 'Success';
    }
    
    //Updated by Saurabh Kumar - CR-20200819-14447 - 10/08/2020 : Replaced Meeting with EAB Event
    //Updated by Saurabh Kumar - CR-20201105-14664 - 11/09/2020 : Replaced Type with Event Type
    public void FindRegisteredSubMeetings() {
        // build the where clause
        String whereClause = '';
        Id contactId;
        if ((mWrapper.EABEventId != null && mWrapper.EABEventId != '') && (mWrapper.ContactId != null && mWrapper.ContactId != '')) {
            contactId = mWrapper.ContactId;
            whereClause += 'Parent_Event__c = \'' + mWrapper.EABEventId + '\'';
        }
        else if (mWrapper.RegistrationId != null && mWrapper.RegistrationId != '') {
            Id eabEventId;
            // first, find the registration record so we can get the Meeting and Contact id
            List<Registration__c> registrations = [SELECT Id, EAB_Event__c, Contact__c FROM Registration__c WHERE Id = :mWrapper.RegistrationId];
            if (registrations.size() > 0) {
                eabEventId = registrations[0].EAB_Event__c;
                contactId = registrations[0].Contact__c;
            }
            else {
                mWrapper.Response = 'Invalid Registration Id.';
                return;
            }
            whereClause += 'Parent_Event__c = \'' + eabEventId + '\'';
        }
        else { // if the required fields aren't passed in, send back an error
            mWrapper.Response = 'Meeting Id and Contact Id or Registration Id are required.';
            return;
        }
        //Updated by Saurabh Kumar - CR-20200819-14447 - 10/08/2020 : Replaced Meeting with EAB Event: Start
        //Modified By - Saurabh Kumar - 11/09/2020 - CR-20201105-14664: Replaced Type__c with Event_Type__c
        List<Advisory_Event__c> eabEvents = database.query('SELECT Id, Parent_Event__c, '+
                                                            '(SELECT Id, EAB_Event__c, EAB_Event__r.Begins__c, EAB_Event__r.Name, EAB_Event__r.Parent_Event__c, EAB_Event__r.Event_Type__c, Contact__c FROM Registrations__r WHERE Contact__c = \'' + contactId + '\')' +
                                                            ' FROM Advisory_Event__c WHERE ' + whereClause + ' LIMIT 1000');
        // Add all registrations to the registration list
        for (Advisory_Event__c item : eabEvents) {
            for (Registration__c reg : item.Registrations__r) {
                Meeting meeting = new Meeting();
                meeting.Id = reg.EAB_Event__c;
                meeting.Name = reg.EAB_Event__r.Name;
                meeting.Type = reg.EAB_Event__r.Event_Type__c;
                if (meeting.start_dateTime != null)
                    meeting.start_dateTime = reg.EAB_Event__r.Begins__c.format('MM/dd/yyyy hh:mm a', 'America/New_York');
                if (reg.EAB_Event__r.Parent_Event__c != null)
                    meeting.ParentMeetingId = reg.EAB_Event__r.Parent_Event__c;
                // add this new registration to our list
                mWrapper.Meetings.add(meeting);
            }
        }
        /*List<Meeting__c> meetings = database.query('SELECT Id, Parent_Meeting__c, '+
                                                            '(SELECT Id, Meeting__c, Meeting__r.DateTime__c, Meeting__r.Name, Meeting__r.Parent_Meeting__c, Meeting__r.Type__c, Contact__c FROM Registrations__r WHERE Contact__c = \'' + contactId + '\')' +
                                                            ' FROM Meeting__c WHERE ' + whereClause + ' LIMIT 1000');
        
        // Add all registrations to the registration list
        for (Meeting__c item : meetings) {
            for (Registration__c reg : item.Registrations__r) {
                Meeting meeting = new Meeting();
                meeting.Id = reg.Meeting__c;
                meeting.Name = reg.Meeting__r.Name;
                meeting.Type = reg.Meeting__r.Type__c;
                if (meeting.start_dateTime != null)
                    meeting.start_dateTime = reg.Meeting__r.DateTime__c.format('MM/dd/yyyy hh:mm a', 'America/New_York');
                if (reg.Meeting__r.Parent_Meeting__c != null)
                    meeting.ParentMeetingId = reg.Meeting__r.Parent_Meeting__c;
                // add this new registration to our list
                mWrapper.Meetings.add(meeting);
            }
        }*/
        //Updated by Saurabh Kumar - CR-20200819-14447 - 10/08/2020 : Replaced Meeting with EAB Event: End
        // set successful message
        mWrapper.Response = 'Success';
    }
    
    //Updated by Saurabh Kumar - CR-20200819-14447 - 10/08/2020 : Replaced Meeting with EAB Event
    //Modified By - Saurabh Kumar - 11/09/2020 - CR-20201105-14664: Replaced Type__c with Event_Type__c
    public void FindAllSubMeetings() {
        // build the where clause
        String whereClause = '';
        Id eabEventId;
        if ((mWrapper.EABEventId != null && mWrapper.EABEventId != '')) {
            whereClause += 'Parent_Event__c = \'' + mWrapper.EABEventId + '\'';
        }
        else if (mWrapper.RegistrationId != null && mWrapper.RegistrationId != '') {
            // first, find the registration record so we can get the EAB Event and Contact id
            List<Registration__c> registrations = [SELECT Id, EAB_Event__c FROM Registration__c WHERE Id = :mWrapper.RegistrationId];
            if (registrations.size() > 0) {
                eabEventId = registrations[0].EAB_Event__c;
            }
            else {
                mWrapper.Response = 'Invalid Registration Id.';
                return;
            }
            whereClause += 'Parent_Event__c = \'' + eabEventId + '\'';
        }
        else { // if the required fields aren't passed in, send back an error
            mWrapper.Response = 'EAB Event Id or Registration Id are required.';
            return;
        }
        
        //Updated by Saurabh Kumar - CR-20200819-14447 - 10/08/2020 : Replaced Meeting with EAB Event: Start
        //Modified By - Saurabh Kumar - 11/09/2020 - CR-20201105-14664: Replaced Type__c with Event_Type__c
        List<Advisory_Event__c> eabEvents = database.query('SELECT Id, Parent_Event__c, '+
                                                            '(SELECT Id, EAB_Event__c, EAB_Event__r.Begins__c, EAB_Event__r.Name, EAB_Event__r.Parent_Event__c, EAB_Event__r.Event_Type__c, Contact__c FROM Registrations__r)' +
                                                            ' FROM Advisory_Event__c WHERE ' + whereClause + ' LIMIT 1000');
        
        // Add all registrations to the registration list
        for (Advisory_Event__c item : eabEvents) {
            for (Registration__c reg : item.Registrations__r) {
                Meeting meeting = new Meeting();
                meeting.Id = reg.EAB_Event__c;
                meeting.Name = reg.EAB_Event__r.Name;
                meeting.Type = reg.EAB_Event__r.Event_Type__c;//Modified By - Saurabh Kumar - 11/09/2020 - CR-20201105-14664: Replaced Type__c with Event_Type__c
                if (meeting.start_dateTime != null)
                    meeting.start_dateTime = reg.EAB_Event__r.Begins__c.format('MM/dd/yyyy hh:mm a', 'America/New_York');
                if (reg.EAB_Event__r.Parent_Event__c != null)
                    meeting.ParentMeetingId = reg.EAB_Event__r.Parent_Event__c;
                // add this new registration to our list
                mWrapper.Meetings.add(meeting);
            }
        }
        /*List<Meeting__c> meetings = database.query('SELECT Id, Parent_Meeting__c, '+
                                                            '(SELECT Id, Meeting__c, Meeting__r.DateTime__c, Meeting__r.Name, Meeting__r.Parent_Meeting__c, Meeting__r.Type__c, Contact__c FROM Registrations__r)' +
                                                            ' FROM Meeting__c WHERE ' + whereClause + ' LIMIT 1000');
        
        // Add all registrations to the registration list
        for (Meeting__c item : meetings) {
            for (Registration__c reg : item.Registrations__r) {
                Meeting meeting = new Meeting();
                meeting.Id = reg.Meeting__c;
                meeting.Name = reg.Meeting__r.Name;
                meeting.Type = reg.Meeting__r.Type__c;
                if (meeting.start_dateTime != null)
                    meeting.start_dateTime = reg.Meeting__r.DateTime__c.format('MM/dd/yyyy hh:mm a', 'America/New_York');
                if (reg.Meeting__r.Parent_Meeting__c != null)
                    meeting.ParentMeetingId = reg.Meeting__r.Parent_Meeting__c;
                // add this new registration to our list
                mWrapper.Meetings.add(meeting);
            }
        }*/
        //Updated by Saurabh Kumar - CR-20200819-14447 - 10/08/2020 : Replaced Meeting with EAB Event: End
        // set successful message
        mWrapper.Response = 'Success';
    }
    
    /**
     * @description     : test the populateMeetingLookup method
     * 
     * @revision log    : 06/11/2019 - Modified - Victor Hanson - Updated to work with MeetingGUID for CR-20190611-13177
     *                  : 10/08/2020 - Modified - Saurabh Kumar - Replaced Meeting with EAB Event for CR-20200819-14447
     * 			: 01/08/2020 - Modified - Saurabh Kumar - Replaced Meeting_GUID__c(MeetingGUID) with Website_Tag__c(WebsiteTagID)
    **/
    public void FindMeetings() {
        // build the where clause
        String whereClause = '';
        Id eabEventId;
        boolean getChildMeetings = false;
		
        //01/08/2020 - Modified - Saurabh Kumar - Replaced Meeting_GUID__c(MeetingGUID) with Website_Tag__c(WebsiteTagID): Start
        if (mWrapper.MeetingGUID != null) {
            if (mWrapper.MeetingGUID instanceOf Id)
                whereClause += '(Parent_Event__c = \'' + mWrapper.MeetingGUID + '\' OR Id = \'' + mWrapper.MeetingGUID + '\' OR Website_Tag__c = \'' +  mWrapper.MeetingGUID + '\' OR Parent_Event__r.Website_Tag__c = \'' + mWrapper.MeetingGUID + '\'';
            else
                whereClause += '(Meeting_GUID__c = \'' + mWrapper.MeetingGUID + '\' OR Parent_Event__r.Meeting_GUID__c = \'' + mWrapper.MeetingGUID + '\'';

            if(mWrapper.WebsiteTagID != null && mWrapper.WebsiteTagID == '')
                whereClause += 'OR Website_Tag__c = \'' +  mWrapper.MeetingGUID + '\' OR Parent_Event__r.Website_Tag__c = \'' + mWrapper.MeetingGUID + '\' OR Id = \'' + mWrapper.MeetingGUID + '\'';
            
            whereClause += ')';
        }
        /*if (mWrapper.WebsiteTagID != null && mWrapper.WebsiteTagID != '') {
            whereClause += '(Website_Tag__c = \'' + mWrapper.WebsiteTagID + '\' OR Parent_Event__r.Website_Tag__c = \'' + mWrapper.WebsiteTagID + '\')';
            
        }*/
        //01/08/2020 - Modified - Saurabh Kumar - Replaced Meeting_GUID__c(MeetingGUID) with Website_Tag__c(WebsiteTagID): End
        else if ((mWrapper.ParentMeetingId != null && mWrapper.ParentMeetingId != '')) {
            whereClause += 'Parent_Event__c = \'' + mWrapper.ParentMeetingId + '\'';
        }
        else { // if the required fields aren't passed in, send back an error
            whereClause += 'Parent_Event__c = null'; // parent_meeting__c = null
        }
        
        //get meeting wrapper details
        populateMeetingWrapper(whereClause, null);
        
        // set successful message
        mWrapper.Response = 'Success';
    }

    /**
     * @description:    get all of the web programs for a program
     * 
     **/    
    public static Map<Id, List<SiteUser.WebProgramAccess>> getProgramIdToWebProgramAccessMap(Set<Id> programIds) {
        Map<Id, List<SiteUser.WebProgramAccess>> mapProgIdToWPA = new Map<Id, List<SiteUser.WebProgramAccess>>();
        // get the web program access associated with these programs
        List<Web_Program_Access_MTM__c> webProgAccessMTMList  = [SELECT Id, Adv_com_Program_Id__c, Web_Program__r.Program_Code_to_Member__c, Web_Program__r.Description__c, Membership_Program__c
                                                                 FROM Web_Program_Access_MTM__c 
                                                                 WHERE Membership_Program__c IN :programIds 
                                                                 LIMIT 500];

        List<SiteUser.WebProgramAccess> WebProgramAccess = new List<SiteUser.WebProgramAccess>();
        for (Web_Program_Access_MTM__c wpaMTM : webProgAccessMTMList) {
            List<SiteUser.WebProgramAccess> tempWPAList = mapProgIdToWPA.get(wpaMTM.Membership_Program__c);
            if (tempWPAList == null) tempWPAList = new List<SiteUser.WebProgramAccess>();
            tempWPAList.add(new SiteUser.WebProgramAccess(wpaMTM));
            mapProgIdToWPA.put(wpaMTM.Membership_Program__c, tempWPAList);
        }
        return mapProgIdToWPA;
    }

    /**
     * @description:    check to see if key fields on EAB Event were updated.  If so, send updated meeting info to wordpress
     *
     * @revision log:   V1.0 - 06/19/2019 - Victor Hanson - created
     * 			V1.1 - 03/25/2020 - Victor Hanson - added reference to Current Registration Count & modified callout to send details via FindMeetings
     * 
     **/
    public static void checkEventSync(List<Advisory_Event__c> newEABEvents, Map<Id, Advisory_Event__c> mapOldEABEvents) {
        Set<Id> meetingIdsToSync = new Set<Id>();
        
        //get a map of all Advisory Events with meeting & Parent Meeting
        Set<Id> eventIds = new Set<Id>();
        Map<Id, Advisory_Event__c> eabEventMap = new Map<Id, Advisory_Event__c>();
        //09/23/2020 - Saurabh Kumar - CR-20200819-14449 - Removed the reference of Meeting__c
        /*for (Advisory_Event__c eabEvent : newEABEvents) {
            if (eabEvent.Meeting__c != null) 
                eventIds.add(eabEvent.Id);
        }*/
        
        if (eventIds.size() > 0) {
            //get all eab events
            //09/23/2020 - Saurabh Kumar - CR-20200819-14449 - Removed the reference of Meeting__r.Parent_Meeting__c, Meeting__r.Parent_Meeting__r.Meeting_GUID__c
            eabEventMap = new Map<Id, Advisory_Event__c>([SELECT Id, Meeting_GUID__c, Parent_Event__c FROM Advisory_Event__c WHERE Id IN :eventIds]);
            
        }
        
        //get ids of eab events to sync
        for (Advisory_Event__c newEABEvent : newEABEvents) {

            //get old event
            Advisory_Event__c oldEABEvent;
            if (mapOldEABEvents != null && mapOldEABEvents.containsKey(newEABEvent.Id)) {
                oldEABEvent = mapOldEABEvents.get(newEABEvent.Id);
            }

            //if it's an old event or one of the key fields have been updated, add sync list
            if (/*newEABEvent.Meeting__c != null &&*/ //09/23/2020 - Saurabh Kumar - CR-20200819-14449 - Removed the reference of Meeting__c
                (oldEABEvent == null || 
                newEABEvent.Status__c != oldEABEvent.Status__c ||
                newEABEvent.Begins__c != oldEABEvent.Begins__c ||   //09/23/2020 - Saurabh Kumar - CR-20200819-14449 - Updated code from Date_Begins__c to Begins__c
                newEABEvent.Ends__c != oldEABEvent.Ends__c ||       //09/23/2020 - Saurabh Kumar - CR-20200819-14449 - Updated code from Date_Ends__c to Ends__c
                newEABEvent.Public_Name__c != oldEABEvent.Public_Name__c ||
                //newEABEvent.Description_Public__c != oldEABEvent.Description_Public__c ||//11/09/2020 - Saurabh Kumar - CR-20201105-14664 - Removed Description_Public__c
                newEABEvent.Near_Capacity__c != oldEABEvent.Near_Capacity__c ||
                newEABEvent.Current_Registration_Count__c != oldEABEvent.Current_Registration_Count__c ||
                newEABEvent.Registration_Cap__c != oldEABEvent.Registration_Cap__c))
            {
                //if there are events to sync, send the callout
                if (eabEventMap.containsKey(newEABEvent.Id)) {
                    
                    //get eabEvent from map
                    Advisory_Event__c tempEvent = eabEventMap.get(newEABEvent.Id);
                    
                    //setup a new instance of SiteMeeting
                    SiteMeeting sm = new SiteMeeting();
                    
                    //09/23/2020 - Saurabh Kumar - CR-20200819-14449 - Removed the reference of Meeting__c
                    if (tempEvent.Parent_Event__c != null) {
                        //sm.mWrapper.ParentMeetingId = tempEvent.Meeting__r.Parent_Meeting__c;
                        //sm.mWrapper.ParentMeetingGUID = tempEvent.Meeting__r.Parent_Meeting__r.Meeting_GUID__c;
                    }
                    else
                        sm.mWrapper.MeetingGUID = newEABEvent.Meeting_GUID__c;
                    
                    //get list of eab event wrappers
                    sm.FindMeetings();
                    
                    //convert to json and suppress nulls
                    sendMeetingInfoToWordpress(JSON.serializePretty(sm.mWrapper, true));
                }
            }
        }

        
    }

    /**
     * @description:    check to see if key fields on Meetings were updated.  If so, send updated meeting info to wordpress
     *
     * @revision log:   V1.0 - 06/19/2019 - Victor Hanson - created
     *                  V1.1 - 10/08/2020 - Saurabh Kumar - CR-20200819-14447: Replaced Meeting with EAB Event
     * 
     **/
    public static void checkMeetingSync(List<Advisory_Event__c> newEABEvents, Map<Id, Advisory_Event__c> mapOldEABEvents) {
        Set<Id> eabEventIdsToSync = new Set<Id>();

        //get ids of eab events to sync
        for (Advisory_Event__c newEABEvent : newEABEvents) {

            //get old EAB event
            Advisory_Event__c oldEABEvent;
            if (mapOldEABEvents != null && mapOldEABEvents.containsKey(newEABEvent.Id)) {
                oldEABEvent = mapOldEABEvents.get(newEABEvent.Id);
            }
            //Modified By Dipesh Gupta - CR-20200406-13910 Updating the condition to trigger the request on change of Show_Specific_Meeting_Times_in_eab_com__c
            //if it's an old event or one of the key fields have been updated, add sync list
            if (oldEABEvent == null || 
                oldEABEvent.Begins__c != oldEABEvent.Begins__c ||
                oldEABEvent.Ends__c != oldEABEvent.Ends__c ||
                //oldEABEvent.EAB_Event__c != oldEABEvent.EAB_Event__c ||
                oldEABEvent.Show_Event_Times_on_eab_com__c != oldEABEvent.Show_Event_Times_on_eab_com__c
               )
            {
                eabEventIdsToSync.add(newEABEvent.Id);
            }
        }

        //if there are events to sync, send the callout
        if (eabEventIdsToSync.size() > 0) {
            
            //get list of eab event wrappers
            SiteMeeting sMeeting = new SiteMeeting();
            sMeeting.populateMeetingWrapper(null, eabEventIdsToSync);

            //convert to json and suppress nulls
            sendMeetingInfoToWordpress(JSON.serialize(sMeeting.mWrapper, true));
        }
        
        /*Set<Id> meetingIdsToSync = new Set<Id>();

        //get ids of eab events to sync
        for (Meeting__c newMeeting : newMeetings) {

            //get old event
            Meeting__c oldMeeting;
            if (mapOldMeetings != null && mapOldMeetings.containsKey(newMeeting.Id)) {
                oldMeeting = mapOldMeetings.get(newMeeting.Id);
            }
            //Modified By Dipesh Gupta - CR-20200406-13910 Updating the condition to trigger the request on change of Show_Specific_Meeting_Times_in_eab_com__c
            //if it's an old event or one of the key fields have been updated, add sync list
            if (oldMeeting == null || 
                newMeeting.DateTime__c != oldMeeting.DateTime__c ||
                newMeeting.End_DateTime__c != oldMeeting.End_DateTime__c ||
                newMeeting.EAB_Event__c != oldMeeting.EAB_Event__c ||
                newMeeting.Show_Specific_Meeting_Times_in_eab_com__c != oldMeeting.Show_Specific_Meeting_Times_in_eab_com__c
               )
            {
                meetingIdsToSync.add(newMeeting.Id);
            }
        }

        //if there are events to sync, send the callout
        if (meetingIdsToSync.size() > 0) {
            
            //get list of eab event wrappers
            SiteMeeting sMeeting = new SiteMeeting();
            sMeeting.populateMeetingWrapper(null, meetingIdsToSync);

            //convert to json and suppress nulls
            sendMeetingInfoToWordpress(JSON.serialize(sMeeting.mWrapper, true));
        }*/
    }

    /**
     * @description:    send updated EAB Event data to wordpress site that hosts EAB.com
     * 
     * @revision log:   V1.0 - 06/19/2019 - Victor Hanson - created
     * 
     **/
    @future (callout=true)
    public static void sendMeetingInfoToWordpress(String jsonBody){


        //setup our Request
        HttpRequest req = siteContentRecommendationsHelper.buildWordpressHTTPCallout('POST', Label.EAB_WP_EVENT_UPDATE_ENDPOINT);
        req.setBody(jsonBody);

        //set our Http
        Http http = new Http();

        if(Test.isRunningTest()) {
            return;
        }

        //send callout
        HttpResponse response = http.send(req);
        
        //If our message fails to send to Wordpress then send an email to SF Admin account to notify
        if (response.getStatusCode() != 200){
            
            // Create and send an email with the results of the Callout
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    
            //Set our Mail 
            mail.setToAddresses(new String[] {Label.Salesforce_Admin_Email});
            mail.setReplyTo(Label.Salesforce_Admin_Email);
            mail.setSenderDisplayName('Send Meeting Info to Wordpress failed');
            mail.setSubject('Send Meeting Info to Wordpress failed');
            mail.setPlainTextBody('The callout to Wordpress failed with the following errors:' + '\n' + 'Status Code: ' + response.getStatusCode() + '\n\n' + 
                                    'Error Body: ' + response.getBody() + '\n\n' +
                                    'Request Body: ' + jsonBody);
            
            //Send our email
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
            
        }
    }

    /**
     * @description:    populate meeting wrapper info from either EAB Event or Meeting objects
     * 
     * @revision log:   V1.0 - 06/19/2019 - Victor Hanson - created
     *                  V1.1 - 03/30/2020 - Victor Hanson - CR-20200330-13895 - added reference to meeting guid
     *                  V1.2 - 10/08/2020 - Saurabh Kumar - CR-20200819-14447 - Replaced Meeting with EAB Event
     *                  V1.3 - 11/09/2020 - Saurabh Kumar - CR-20201105-14664 - Replaced Type__c with Event_Type__c
     * 			V1.4 - 2/8/2022 - Chirag Soni - CR-20220207-15771 - added two new fields in respone i.e. Time_Zone_Acronym__c, Website_Keyword__c
     **/
    public void populateMeetingWrapper(String whereClause, Set<Id> eabEventIds) {
        
        //get list of Primary Programs so we can get the web program access
        Set<Id> primaryProgramIds = new Set<Id>();
        String eabFieldSOQL = 'SELECT Id, Parent_Event__c, Name, Event_Type__c, Begins__c, Ends__c, ' +
                                    'Public_Name__c, RecordType.Name, Primary_Program__c, ' +
                                    'Short_Name__c, Near_Capacity__c, Meeting_GUID__c, '+
            			    'Time_Zone_Acronym__c, Website_Keyword__c, '+
                                    'Current_Registration_Count__c, Registration_Cap__c, Show_Event_Times_on_eab_com__c ';

        List<Advisory_Event__c> eabEvents;
        if (whereClause != null) {
            eabEvents = database.query(eabFieldSOQL +
                                    ' FROM Advisory_Event__c WHERE ' + whereClause + ' LIMIT 1000');
        }
        else if (eabEventIds != null) {
            eabEvents = database.query(eabFieldSOQL +
                                    ' FROM Advisory_Event__c WHERE Id IN :eabEventIds LIMIT 1000');
        }
        
        // Add all Meetings / Events to the meetings wrapper list
        for (Advisory_Event__c m : eabEvents) {
            Meeting meetingWrapper = new Meeting();
            meetingWrapper.Id = m.Id;
            meetingWrapper.Name = m.Name;
            
            //Added - CR-20220207-15771 - 2/8/2022 - Chirag Soni 
            meetingWrapper.time_zone_keyword = m.Time_Zone_Acronym__c;
            meetingWrapper.website_keyword  = m.Website_Keyword__c;
            
            meetingWrapper.Type = m.Event_Type__c;//Modified By - Saurabh Kumar - 11/09/2020 - CR-20201105-14664: Replaced Type__c with Event_Type__c
            if (m.Begins__c != null)
                meetingWrapper.start_dateTime = m.Begins__c.format('MM/dd/yyyy hh:mm a', 'America/New_York');
            
            if (m.Ends__c != null)
                meetingWrapper.end_dateTime = m.Ends__c.format('MM/dd/yyyy hh:mm a', 'America/New_York');

            if (m.Parent_Event__c != null)
                meetingWrapper.ParentMeetingId = m.Parent_Event__c;
            //if (m.EAB_Event__c != null) {
                meetingWrapper.PublicName = m.Public_Name__c;
                meetingWrapper.EABEventType = m.RecordType.Name;
                meetingWrapper.City_State = m.Short_Name__c;
                meetingWrapper.nearCapacity = m.Near_Capacity__c;
                //vh added 03/25/2020 - CR-20200324-13884
                meetingWrapper.registration_cap = m.Registration_Cap__c;
                meetingWrapper.current_registration_count = m.Current_Registration_Count__c;
                meetingWrapper.meeting_guid = m.Meeting_GUID__c;
            //}
            
            //Added By Dipesh Gupta.  CR-20200406-13910
            meetingWrapper.show_time = m.Show_Event_Times_on_eab_com__c;
           
            // add this new meeting to our list
            mWrapper.Meetings.add(meetingWrapper);

            //add primary program id to set
            if (m.Primary_Program__c != null) {
                meetingWrapper.primaryProgramId = m.Primary_Program__c;
                primaryProgramIds.add(m.Primary_Program__c);
            }
        }

        if (primaryProgramIds.size() > 0) {
            //get the map of ProgramID to Web Program Access
            Map<Id, List<SiteUser.WebProgramAccess>> mapProgIdToWPA = getProgramIdToWebProgramAccessMap(primaryProgramIds);

            //loop through each meeting and include the web program access list
            for (Meeting m : mWrapper.Meetings) {
                if (m.primaryProgramId != null && mapProgIdToWPA != null && mapProgIdToWPA.containsKey(m.primaryProgramId)) {
                    m.webProgramAccessList = mapProgIdToWPA.get(m.primaryProgramId);
                }
            }
        }
        
        /*//get list of Primary Programs so we can get the web program access
        Set<Id> primaryProgramIds = new Set<Id>();
        String meetingFieldSOQL = 'SELECT Id, Parent_Meeting__c, Name, Type__c, DateTime__c, End_DateTime__c, ' +
                                    'EAB_Event__c, EAB_Event__r.Public_Name__c, EAB_Event__r.RecordType.Name, EAB_Event__r.Primary_Program__c, ' +
                                    'EAB_Event__r.Short_Name__c, EAB_Event__r.Near_Capacity__c, Meeting_GUID__c, '+
                                    'EAB_Event__r.Current_Registration_Count__c, EAB_Event__r.Registration_Cap__c, Show_Specific_Meeting_Times_in_eab_com__c ';

        List<Meeting__c> meetings;
        
        if (whereClause != null) {
            meetings = database.query(meetingFieldSOQL +
                                    ' FROM Meeting__c WHERE ' + whereClause + ' LIMIT 1000');
        }
        else if (meetingIds != null) {
            meetings = database.query(meetingFieldSOQL +
                                    ' FROM Meeting__c WHERE Id IN :meetingIds LIMIT 1000');
        }
        
        // Add all Meetings / Events to the meetings wrapper list
        for (Meeting__c m : meetings) {
            Meeting meetingWrapper = new Meeting();
            meetingWrapper.Id = m.Id;
            meetingWrapper.Name = m.Name;
            meetingWrapper.Type = m.Type__c;
            if (m.DateTime__c != null)
                meetingWrapper.start_dateTime = m.DateTime__c.format('MM/dd/yyyy hh:mm a', 'America/New_York');
            
            if (m.End_DateTime__c != null)
                meetingWrapper.end_dateTime = m.End_DateTime__c.format('MM/dd/yyyy hh:mm a', 'America/New_York');

            if (m.Parent_Meeting__c != null)
                meetingWrapper.ParentMeetingId = m.Parent_Meeting__c;
            if (m.EAB_Event__c != null) {
                meetingWrapper.PublicName = m.EAB_Event__r.Public_Name__c;
                meetingWrapper.EABEventType = m.EAB_Event__r.RecordType.Name;
                meetingWrapper.City_State = m.EAB_Event__r.Short_Name__c;
                meetingWrapper.nearCapacity = m.EAB_Event__r.Near_Capacity__c;
                //vh added 03/25/2020 - CR-20200324-13884
                meetingWrapper.registration_cap = m.EAB_Event__r.Registration_Cap__c;
                meetingWrapper.current_registration_count = m.EAB_Event__r.Current_Registration_Count__c;
                meetingWrapper.meeting_guid = m.Meeting_GUID__c;
            }
            
            //Added By Dipesh Gupta.  CR-20200406-13910
            meetingWrapper.show_time = m.Show_Specific_Meeting_Times_in_eab_com__c;
           
            // add this new meeting to our list
            mWrapper.Meetings.add(meetingWrapper);

            //add primary program id to set
            if (m.EAB_Event__c != null && m.EAB_Event__r.Primary_Program__c != null) {
                meetingWrapper.primaryProgramId = m.EAB_Event__r.Primary_Program__c;
                primaryProgramIds.add(m.EAB_Event__r.Primary_Program__c);
            }
        }

        if (primaryProgramIds.size() > 0) {
            //get the map of ProgramID to Web Program Access
            Map<Id, List<SiteUser.WebProgramAccess>> mapProgIdToWPA = getProgramIdToWebProgramAccessMap(primaryProgramIds);

            //loop through each meeting and include the web program access list
            for (Meeting m : mWrapper.Meetings) {
                if (m.primaryProgramId != null && mapProgIdToWPA != null && mapProgIdToWPA.containsKey(m.primaryProgramId)) {
                    m.webProgramAccessList = mapProgIdToWPA.get(m.primaryProgramId);
                }
            }
        }*/
    }

}