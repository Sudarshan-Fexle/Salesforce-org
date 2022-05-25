//Modified By - Abhinav Sharma - 03/31/2016 - CR-20160309-9686
//Modified By - Saurabh Kumar - 10/09/2020 - CR-20200819-14447: Updated Meeting with EAB Event in following 
//                                           Registration//Wrapper
//                                           MeetingWrapper//Wrapper
//                                           DeleteRegistration()
//                                           FindMeetingsByUser()
//                                           CreateRegistration()
//                                           FindRegistrations()
//                                           FindRegisteredSubMeetings()
//                                           FindAllSubMeetings()
//                                           FindMeetings()
//Modifed By - Saurabh Kumar - 11/09/2020 - CR-20201105-14664: Updated EAB Event's Type with EAB Event's Event Type
//                                           
public without sharing class CrimsonMeeting {
    
    public final static Blob KEY = EncodingUtil.base64Decode('LwD3u7JuXDCJJd+9/ztO7Ya2vJfxeznhgJUype2z6hg=');
    
    // object to hold meeting data
    public class Meeting {
        public Meeting() {}
        public String Name { get; set; }
        public String Type { get; set; }
        public String ParentMeetingId { get; set; }
        public String Id { get; set; }
        public String Date_Time { get; set; }
        
        //Added By - Abhinav Sharma - 03/31/2016 - CR-20160309-9686
        //Start from here
        public String status { get; set; }
        //Upto here
    }
    
    // object to hold registration data
    public class Registration {
        public Registration() {}
        public String RegistrationId { get; set; }
        public String ContactId { get; set; }
        public String ContactName { get; set; }
        public String EABEventId { get; set; }//Updated by Saurabh Kumar - 10/09/2020 CR-20200819-14447: Replaced MeetingId with EABEventId
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
        public String EABEventId { get; set; }//Updated by Saurabh Kumar - 10/09/2020 CR-20200819-14447: Replaced MeetingId with EABEventId
        public String ContactId { get; set; }
        public String RegistrationId { get; set; }
        public String Status { get; set; }
        public String Response { get; set; }
        public String ParentMeetingId { get; set; }
        public String EndpointURL { get; set; }
        public MeetingWrapper() { }
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
    }
    
    
    /***
    *   
    *   the main functionality of the class begins here
    *   
    ***/
    public MeetingWrapper mWrapper {
        get {
            if (mWrapper == null)
                mWrapper = new MeetingWrapper();
            return mWrapper;
        }
        set;
    }
    
    public String DecryptedString { get; set; }
    
    public static String Decrypt(blob encryptedRequest) {
        // decrypt the string in to a blob using our private KEY
        blob decryptedData = Crypto.decryptWithManagedIV('AES256', KEY, encryptedRequest);
        system.debug('@@decryptedData: ' + decryptedData.toString());
        return decryptedData.toString();
    }
    
    // take in an encrypted request
    public CrimsonMeeting(String encryptedRequest) {
        try {
            // convert the string in to a blob to be decrypted
            //encryptedRequest = EncodingUtil.urlDecode(encryptedRequest, 'UTF-8');
            blob encryptedBlob = EncodingUtil.base64Decode(encryptedRequest);
            DecryptedString = Decrypt(encryptedBlob);
            
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
        // perform the requested action
        if (mWrapper.Command == null) mWrapper.Response = 'Error: Null is not a valid command';
        else if (mWrapper.Command.equalsIgnoreCase('FindMeetings')) FindMeetings();
        else if (mWrapper.Command.equalsIgnoreCase('FindRegistrations')) FindRegistrations();
        else if (mWrapper.Command.equalsIgnoreCase('FindRegisteredSubMeetings')) FindRegisteredSubMeetings();
        else if (mWrapper.Command.equalsIgnoreCase('FindAllSubMeetings')) FindAllSubMeetings();
        else if (mWrapper.Command.equalsIgnoreCase('CreateRegistration')) CreateRegistration();
        else if (mWrapper.Command.equalsIgnoreCase('DeleteRegistration')) DeleteRegistration();
        else if (mWrapper.Command.equalsIgnoreCase('FindMeetingsByUser')) FindMeetingsByUser();
        else {
            mWrapper.Response = 'Error: Unrecognized command: ' + mWrapper.Command;
        }
        system.debug('@@mWrapper: ' + mWrapper);
    }
    
    //Modified By - Abhinav Sharma - 03/31/2016 - CR-20160309-9686
    //Modified By - Saurabh Kumar - 10/09/2020 - CR-20200819-14447: Replaced Meeting with EAB Event
    public void FindMeetingsByUser() {
        
        // build the where clause
        String whereClause = '';
        
        // if the contact id is not present, return with error
        if (mWrapper.ContactId == null || mWrapper.ContactId == '') {
            mWrapper.Response = 'Contact Id is required.';
            return;
        }
        
        //Modified By - Saurabh Kumar - 10/09/2020 - CR-20200819-14447: Replaced Meeting with EAB Event. Start
        // 1. find all registrations for that contact id
        List<Registration__c> registrations = [SELECT Id, EAB_Event__c, Status__c FROM Registration__c 
                                                WHERE Contact__c = :mWrapper.ContactId LIMIT 1000];
        
        //Map to hold the EAB Event Id as key and corresponding registration record as value
        Map<Id, Registration__c> eabEventToRegistrationMap = new Map<Id, Registration__c>();
        
        // 2. compile a list of all unique EAB Event ids
        Set<Id> eabEventIdSet = new Set<Id>();
        
        //Loop through registration records as populating collections
        for (Registration__c reg : registrations) {
            if(reg.EAB_Event__c != null) {
                eabEventIdSet.add(reg.EAB_Event__c);
                eabEventToRegistrationMap.put(reg.EAB_Event__c, reg);
            }
        }
            
        // 3. Find all EAB Events based on the set of EAB Event ids
        // Modifed By - Saurabh Kumar - 11/09/2020 - CR-20201105-14664: Updated EAB Event's Type with EAB Event's Event Type
        List<Advisory_Event__c> eabEvents = [SELECT Id, Parent_Event__c, Begins__c, Name, Event_Type__c 
        				     FROM Advisory_Event__c 
                                     	     WHERE Id IN :eabEventIdSet LIMIT 1000];
        
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
            meeting.Type = item.Event_Type__c;//Modifed By - Saurabh Kumar - 11/09/2020 - CR-20201105-14664: Updated EAB Event's Type with EAB Event's Event Type
            
            if (meeting.Date_Time != null)
                meeting.Date_Time = item.Begins__c.format('MM/dd/yyyy hh:mm a', 'America/New_York');
            
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
        List<Meeting__c> meetings = [SELECT Id, Parent_Meeting__c, DateTime__c, Name, Type__c 
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
            
            if (meeting.Date_Time != null)
                meeting.Date_Time = item.DateTime__c.format('MM/dd/yyyy hh:mm a', 'America/New_York');
            
            if (item.Parent_Meeting__c != null)
                meeting.ParentMeetingId = item.Parent_Meeting__c;
            
            // add this new registration to our list
            mWrapper.Meetings.add(meeting);
        }*/
        
        //Modified By - Saurabh Kumar - 10/09/2020 - CR-20200819-14447: Replaced Meeting with EAB Event. End
        // set successful message
        mWrapper.Response = 'Success';
    }
    
    // Delete a registration
    //Modified By - Saurabh Kumar - 10/09/2020 - CR-20200819-14447: Replaced Meeting with EAB Event
    public void DeleteRegistration() {
        
        //Modified By - Saurabh Kumar - 10/09/2020 - CR-20200819-14447: Replaced Meeting with EAB Event. Start
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
            // first, find the EAB Event record
            List<Advisory_Event__c> eabEvents = [Select Id, Parent_Event__c From Advisory_Event__c Where Id =: mWrapper.EABEventId];
            if (eabEvents.size() == 0) {
                mWrapper.Response = 'Invalid EAB Event Id.';
                return;
            }
            
            // second, find the contact record
            List<Contact> contacts = [SELECT Id, Name FROM Contact WHERE Id = :mWrapper.ContactId];
            
            if (contacts.size() == 0) {
                mWrapper.Response = 'Invalid Contact Id.';
                return;
            }
            
            registrations = [SELECT Id FROM Registration__c WHERE Contact__c = :mWrapper.ContactId AND EAB_Event__c = :mWrapper.EABEventId];
        }
        
        try {
            delete registrations;
        }
        catch(Exception ex) {
            mWrapper.Response = 'Error:' + ex.getMessage();
            return;
        }
        
        /*if (mWrapper.RegistrationId == null && (mWrapper.MeetingId == null || mWrapper.ContactId == null)) {
            mWrapper.Response = 'Registration Id or Meeting Id and Contact Id are required.';
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
            // first, find the meeting record
            List<Meeting__c> meetings = [SELECT Id, Parent_Meeting__c FROM Meeting__c WHERE Id = :mWrapper.MeetingId];
            if (meetings.size() == 0) {
                mWrapper.Response = 'Invalid Meeting Id.';
                return;
            }
            
            // second, find the contact record
            List<Contact> contacts = [SELECT Id, Name FROM Contact WHERE Id = :mWrapper.ContactId];
            
            if (contacts.size() == 0) {
                mWrapper.Response = 'Invalid Contact Id.';
                return;
            }
            
            registrations = [SELECT Id FROM Registration__c WHERE Contact__c = :mWrapper.ContactId AND Meeting__c = :mWrapper.MeetingId];
        }
        
        try {
            delete registrations;
        }
        catch(Exception ex) {
            mWrapper.Response = 'Error:' + ex.getMessage();
            return;
        }*/
        
        //Modified By - Saurabh Kumar - 10/09/2020 - CR-20200819-14447: Replaced Meeting with EAB Event. End
        // set successful message
        mWrapper.Response = 'Success';
    }
    
    // Add a registration
    //Modified By - Saurabh Kumar - 10/09/2020 - CR-20200819-14447: Replaced Meeting with EAB Event
    public void CreateRegistration() {
        
        //Modified By - Saurabh Kumar - 10/09/2020 - CR-20200819-14447: Replaced Meeting with EAB Event. Start
        if (mWrapper.EABEventId == null || mWrapper.ContactId == null) {
            mWrapper.Response = 'EAB Event Id and Contact Id are required.';
            return;
        }
        
        try {
               List<Advisory_Event__c> eabEvents = new List<Advisory_Event__c>();
              //Added by Bhavi Sharma - 02/22/2013 - CR-20130220-2539
              //Fetching all the child EAB Event records for mWrapper.EABEventId
              Map<Id, Advisory_Event__c> childL1EABEvents = new Map<Id, Advisory_Event__c>([SELECT ID FROM Advisory_Event__c 
                                            WHERE Parent_Event__c != null AND Parent_Event__c =: mWrapper.EABEventId ]);
              eabEvents.addAll(childL1EABEvents.values());
              // find all sub-child EAB Event
              Map<Id, Advisory_Event__c> childL2EABEvents = new Map<Id, Advisory_Event__c>([SELECT ID FROM Advisory_Event__c 
                                            WHERE Parent_Event__c != null AND Parent_Event__c IN :childL1EABEvents.keySet() ]);
              eabEvents.addAll(childL2EABEvents.values());
              
              //Create a new list of registration to be inserted
              List<Registration__c> registrations = new List<Registration__c>(); 
              
              //Loop through the EAB Event
              for(Advisory_Event__c eabEvent : eabEvents){
                  
                  //Add new registration record
                  registrations.add(new Registration__c(EAB_Event__c = eabEvent.Id, Contact__c = mWrapper.ContactId, Status__c = mWrapper.Status));
              }
           
            // create/insert the meeting
            registrations.add(new Registration__c(EAB_Event__c = mWrapper.EABEventId, Contact__c = mWrapper.ContactId, Status__c = mWrapper.Status));
            
            //Check if tehre are records to insert
            if(registrations.size() > 0) {
                insert registrations;
                
                // set the registration id
                mWrapper.RegistrationId = String.valueOf(registrations[registrations.size() - 1].Id).subString(0, 15);
            }
        }
        catch(Exception ex) {
            mWrapper.Response = 'Error:' + ex.getMessage();
            return;
        }
        /*if (mWrapper.MeetingId == null || mWrapper.ContactId == null) {
            mWrapper.Response = 'Meeting Id and Contact Id are required.';
            return;
        }
        
        try {
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
              
              //Create a new list of registration to be inserted
              List<Registration__c> registrations = new List<Registration__c>(); 
              
              //Loop through the meetings
              for(Meeting__c meeting : meetings){
                  
                  //Add new registration record
                  registrations.add(new Registration__c(Meeting__c = meeting.Id, Contact__c = mWrapper.ContactId, Status__c = mWrapper.Status));
              }
           
            // create/insert the meeting
            registrations.add(new Registration__c(Meeting__c = mWrapper.MeetingId, Contact__c = mWrapper.ContactId, Status__c = mWrapper.Status));
            
            //Check if tehre are records to insert
            if(registrations.size() > 0) {
                insert registrations;
                
                // set the registration id
                mWrapper.RegistrationId = String.valueOf(registrations[registrations.size() - 1].Id).subString(0, 15);
            }
        }
        catch(Exception ex) {
            mWrapper.Response = 'Error:' + ex.getMessage();
            return;
        }*/
        //Modified By - Saurabh Kumar - 10/09/2020 - CR-20200819-14447: Replaced Meeting with EAB Event. End
        
        
        // set successful message
        mWrapper.Response = 'Success';
    }
    
    // find all attendees based on the information that was provided
    //Modified By - Saurabh Kumar - 10/09/2020 - CR-20200819-14447: Replaced Meeting with EAB Event
    public void FindRegistrations() {
        
        // build the where clause
        String whereClause = '';
        
        //Modified By - Saurabh Kumar - 10/09/2020 - CR-20200819-14447: Replaced Meeting with EAB Event. Start
        // check to make sure we have the data we need to find registrations
        if ((mWrapper.RegistrationId == null || mWrapper.RegistrationId == '') && (mWrapper.EABEventId == null || mWrapper.EABEventId == '')) {
            mWrapper.Response = 'At least one of the following fields must be filled in: ContactId, RegistrationId, EABEventId';
            return;
        }
            
        if (mWrapper.EABEventId != null && mWrapper.EABEventId != '') {
            whereClause += 'EAB_Event__c = \'' + mWrapper.EABEventId + '\'';
        }
        if (mWrapper.RegistrationId != null && mWrapper.RegistrationId != '') {
            system.debug('@@RegistrationId: ' + mWrapper.RegistrationId);
            Id eabEventId;
            // first, find the registration record so we can get the meeting id
            List<Registration__c> registrations = [SELECT Id, EAB_Event__c FROM Registration__c WHERE Id = :mWrapper.RegistrationId];
            if (registrations.size() > 0) eabEventId = registrations[0].EAB_Event__c;
            if (whereClause != '') whereClause += ' OR ';
            whereClause += 'EAB_Event__c = \'' + eabEventId + '\'';
        }
        system.debug('@@WhereClause:' + whereClause);
        string qryString = 'SELECT Id, Contact__c, Contact__r.Name, EAB_Event__c, Status__c, Contact__r.Salutation, Contact__r.Primary_City__c, Contact__r.Fax, Contact__r.Primary_State_Province__c, '
                        + 'Contact__r.FirstName, Contact__r.LastName, Contact__r.Suffix__c, Contact__r.Advisory_com_Name_Tag__c, Contact__r.Title, Contact__r.Advisory_com_Twitter__c, '
                        + 'Contact__r.Advisory_com_Share_LinkedIn__c, Contact__r.Advisory_com_Share_Phone__c, Contact__r.Advisory_com_Share_Pinterest__c, Contact__r.Advisory_com_Share_Twitter__c, '
                        + 'Contact__r.Advisory_com_Share_Facebook__c, Contact__r.Advisory_com_Share_Fax__c, Contact__r.Advisory_com_Share_Image__c, Contact__r.Advisory_com_Share_Interests__c, Contact__r.Advisory_com_Share_Information__c,'
                        + 'Contact__r.Primary_Address_Line_1__c, Contact__r.Primary_Address_Line_2__c, Contact__r.Primary_Country__c, Contact__r.Email,  Contact__r.Advisory_com_Pinterest__c, '
                        + 'Contact__r.Phone, Contact__r.Advisory_com_LinkedIn__c, Contact__r.Advisory_com_Interests__c, Contact__r.Account.Account_Formal_Name__c, Contact__r.Primary_Postal_Code__c, Contact__r.Advisory_com_Share_Email__c '
                        + ' FROM Registration__c WHERE ' + whereClause + ' LIMIT 1000';
        List<Registration__c> registrations = database.query(qryString);
        
        // Add all registrations to the registration list
        for (Registration__c item : registrations) {
            Registration reg = new Registration();
            reg.RegistrationId = item.Id;
            reg.ContactId = item.Contact__c;
            reg.ContactName = item.Contact__r.Name;
            reg.EABEventId = item.EAB_Event__c;
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
           // reg.facebook = item.Contact__r.Advisory_com_Facebook__c;
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
        
        /*// check to make sure we have the data we need to find registrations
        if ((mWrapper.RegistrationId == null || mWrapper.RegistrationId == '') && (mWrapper.MeetingId == null || mWrapper.MeetingId == '')) {
            mWrapper.Response = 'At least one of the following fields must be filled in: ContactId, RegistrationId, MeetingId';
            return;
        }
            
        if (mWrapper.MeetingId != null && mWrapper.MeetingId != '') {
            whereClause += 'Meeting__c = \'' + mWrapper.MeetingId + '\'';
        }
        if (mWrapper.RegistrationId != null && mWrapper.RegistrationId != '') {
            system.debug('@@RegistrationId: ' + mWrapper.RegistrationId);
            Id meetingId;
            // first, find the registration record so we can get the meeting id
            List<Registration__c> registrations = [SELECT Id, Meeting__c FROM Registration__c WHERE Id = :mWrapper.RegistrationId];
            if (registrations.size() > 0) meetingId = registrations[0].Meeting__c;
            if (whereClause != '') whereClause += ' OR ';
            whereClause += 'Meeting__c = \'' + meetingId + '\'';
        }
        system.debug('@@WhereClause:' + whereClause);
        string qryString = 'SELECT Id, Contact__c, Contact__r.Name, Meeting__c, Status__c, Contact__r.Salutation, Contact__r.Primary_City__c, Contact__r.Fax, Contact__r.Primary_State_Province__c, '
                        + 'Contact__r.FirstName, Contact__r.LastName, Contact__r.Suffix__c, Contact__r.Advisory_com_Name_Tag__c, Contact__r.Title, Contact__r.Advisory_com_Twitter__c, '
                        + 'Contact__r.Advisory_com_Share_LinkedIn__c, Contact__r.Advisory_com_Share_Phone__c, Contact__r.Advisory_com_Share_Pinterest__c, Contact__r.Advisory_com_Share_Twitter__c, '
                        + 'Contact__r.Advisory_com_Share_Facebook__c, Contact__r.Advisory_com_Share_Fax__c, Contact__r.Advisory_com_Share_Image__c, Contact__r.Advisory_com_Share_Interests__c, Contact__r.Advisory_com_Share_Information__c,'
                        + 'Contact__r.Primary_Address_Line_1__c, Contact__r.Primary_Address_Line_2__c, Contact__r.Primary_Country__c, Contact__r.Email,  Contact__r.Advisory_com_Pinterest__c, '
                        + 'Contact__r.Phone, Contact__r.Advisory_com_LinkedIn__c, Contact__r.Advisory_com_Interests__c, Contact__r.Account.Account_Formal_Name__c, Contact__r.Primary_Postal_Code__c, Contact__r.Advisory_com_Share_Email__c '
                        + ' FROM Registration__c WHERE ' + whereClause + ' LIMIT 1000';
        List<Registration__c> registrations = database.query(qryString);
        
        // Add all registrations to the registration list
        for (Registration__c item : registrations) {
            Registration reg = new Registration();
            reg.RegistrationId = item.Id;
            reg.ContactId = item.Contact__c;
            reg.ContactName = item.Contact__r.Name;
            reg.MeetingId = item.Meeting__c;
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
           // reg.facebook = item.Contact__r.Advisory_com_Facebook__c;
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
        }*/
        
        //Modified By - Saurabh Kumar - 10/09/2020 - CR-20200819-14447: Replaced Meeting with EAB Event. End
        system.debug('@@Registrations:' + registrations);
        // set successful message
        mWrapper.Response = 'Success';
    }
    
    //Modified By - Saurabh Kumar - 10/09/2020 - CR-20200819-14447: Replaced Meeting with EAB Event.
    public void FindRegisteredSubMeetings() {
        // build the where clause
        String whereClause = '';
        Id contactId;
        
        //Modified By - Saurabh Kumar - 10/09/2020 - CR-20200819-14447: Replaced Meeting with EAB Event. Start
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
            mWrapper.Response = 'EAB Event Id and Contact Id or Registration Id are required.';
            return;
        }
        //Modifed By - Saurabh Kumar - 11/09/2020 - CR-20201105-14664: Updated EAB Event's Type with EAB Event's Event Type
        List<Advisory_Event__c> eabEvents = database.query('SELECT Id, Parent_Event__c, '+
                                                            '(SELECT Id, EAB_Event__c, EAB_Event__r.Begins__c, EAB_Event__r.Name, EAB_Event__r.Parent_Event__c, EAB_Event__r.Event_Type__c, Contact__c FROM Registrations__r WHERE Contact__c = \'' + contactId + '\')' +
                                                            ' FROM Advisory_Event__c WHERE ' + whereClause + ' LIMIT 1000');
        
        // Add all registrations to the registration list
        for (Advisory_Event__c item : eabEvents) {
            for (Registration__c reg : item.Registrations__r) {
                Meeting meeting = new Meeting();
                meeting.Id = reg.EAB_Event__c;
                meeting.Name = reg.EAB_Event__r.Name;
                meeting.Type = reg.EAB_Event__r.Event_Type__c;//Modifed By - Saurabh Kumar - 11/09/2020 - CR-20201105-14664: Updated EAB Event's Type with EAB Event's Event Type
                if (meeting.Date_Time != null)
                    meeting.Date_Time = reg.EAB_Event__r.Begins__c.format('MM/dd/yyyy hh:mm a', 'America/New_York');
                if (reg.EAB_Event__r.Parent_Event__c != null)
                    meeting.ParentMeetingId = reg.EAB_Event__r.Parent_Event__c;
                // add this new registration to our list
                mWrapper.Meetings.add(meeting);
            }
        }
        /*if ((mWrapper.MeetingId != null && mWrapper.MeetingId != '') && (mWrapper.ContactId != null && mWrapper.ContactId != '')) {
            contactId = mWrapper.ContactId;
            whereClause += 'Parent_Meeting__c = \'' + mWrapper.MeetingId + '\'';
        }
        else if (mWrapper.RegistrationId != null && mWrapper.RegistrationId != '') {
            Id meetingId;
            // first, find the registration record so we can get the Meeting and Contact id
            List<Registration__c> registrations = [SELECT Id, Meeting__c, Contact__c FROM Registration__c WHERE Id = :mWrapper.RegistrationId];
            if (registrations.size() > 0) {
                meetingId = registrations[0].Meeting__c;
                contactId = registrations[0].Contact__c;
            }
            else {
                mWrapper.Response = 'Invalid Registration Id.';
                return;
            }
            whereClause += 'Parent_Meeting__c = \'' + meetingId + '\'';
        }
        else { // if the required fields aren't passed in, send back an error
            mWrapper.Response = 'Meeting Id and Contact Id or Registration Id are required.';
            return;
        }
        system.debug('@@WhereClause:' + whereClause);
        List<Meeting__c> meetings = database.query('SELECT Id, Parent_Meeting__c, '+
                                                            '(SELECT Id, Meeting__c, Meeting__r.DateTime__c, Meeting__r.Name, Meeting__r.Parent_Meeting__c, Meeting__r.Type__c, Contact__c FROM Registrations__r WHERE Contact__c = \'' + contactId + '\')' +
                                                            ' FROM Meeting__c WHERE ' + whereClause + ' LIMIT 1000');
        
        // Add all registrations to the registration list
        for (Meeting__c item : meetings) {
            for (Registration__c reg : item.Registrations__r) {
                Meeting meeting = new Meeting();
                meeting.Id = reg.Meeting__c;
                meeting.Name = reg.Meeting__r.Name;
                meeting.Type = reg.Meeting__r.Type__c;
                if (meeting.Date_Time != null)
                    meeting.Date_Time = reg.Meeting__r.DateTime__c.format('MM/dd/yyyy hh:mm a', 'America/New_York');
                if (reg.Meeting__r.Parent_Meeting__c != null)
                    meeting.ParentMeetingId = reg.Meeting__r.Parent_Meeting__c;
                // add this new registration to our list
                mWrapper.Meetings.add(meeting);
            }
        }*/
        //Modified By - Saurabh Kumar - 10/09/2020 - CR-20200819-14447: Replaced Meeting with EAB Event.End
        // set successful message
        mWrapper.Response = 'Success';
    }
    
    //Modified By - Saurabh Kumar - 10/09/2020 - CR-20200819-14447: Replaced Meeting with EAB Event.
    public void FindAllSubMeetings() {
        // build the where clause
        String whereClause = '';
        
        //Modified By - Saurabh Kumar - 10/09/2020 - CR-20200819-14447: Replaced Meeting with EAB Event. Start
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
        //Modifed By - Saurabh Kumar - 11/09/2020 - CR-20201105-14664: Updated EAB Event's Type with EAB Event's Event Type
        List<Advisory_Event__c> eabEvents = database.query('SELECT Id, Parent_Event__c, '+
                                                            '(SELECT Id, EAB_Event__c, EAB_Event__r.Begins__c, EAB_Event__r.Name, EAB_Event__r.Parent_Event__c, EAB_Event__r.Event_Type__c, Contact__c FROM Registrations__r)' +
                                                            ' FROM Advisory_Event__c WHERE ' + whereClause + ' LIMIT 1000');
        
        // Add all registrations to the registration list
        for (Advisory_Event__c item : eabEvents) {
            for (Registration__c reg : item.Registrations__r) {
                Meeting meeting = new Meeting();
                meeting.Id = reg.EAB_Event__c;
                meeting.Name = reg.EAB_Event__r.Name;
                meeting.Type = reg.EAB_Event__r.Event_Type__c;//Modifed By - Saurabh Kumar - 11/09/2020 - CR-20201105-14664: Updated EAB Event's Type with EAB Event's Event Type
                if (meeting.Date_Time != null)
                    meeting.Date_Time = reg.EAB_Event__r.Begins__c.format('MM/dd/yyyy hh:mm a', 'America/New_York');
                if (reg.EAB_Event__r.Parent_Event__c != null)
                    meeting.ParentMeetingId = reg.EAB_Event__r.Parent_Event__c;
                // add this new registration to our list
                mWrapper.Meetings.add(meeting);
            }
        }
        /*Id meetingId;
        if ((mWrapper.MeetingId != null && mWrapper.MeetingId != '')) {
            whereClause += 'Parent_Meeting__c = \'' + mWrapper.MeetingId + '\'';
        }
        else if (mWrapper.RegistrationId != null && mWrapper.RegistrationId != '') {
            // first, find the registration record so we can get the Meeting and Contact id
            List<Registration__c> registrations = [SELECT Id, Meeting__c FROM Registration__c WHERE Id = :mWrapper.RegistrationId];
            if (registrations.size() > 0) {
                meetingId = registrations[0].Meeting__c;
            }
            else {
                mWrapper.Response = 'Invalid Registration Id.';
                return;
            }
            whereClause += 'Parent_Meeting__c = \'' + meetingId + '\'';
        }
        else { // if the required fields aren't passed in, send back an error
            mWrapper.Response = 'Meeting Id or Registration Id are required.';
            return;
        }
        system.debug('@@WhereClause:' + whereClause);
        List<Meeting__c> meetings = database.query('SELECT Id, Parent_Meeting__c, '+
                                                            '(SELECT Id, Meeting__c, Meeting__r.DateTime__c, Meeting__r.Name, Meeting__r.Parent_Meeting__c, Meeting__r.Type__c, Contact__c FROM Registrations__r)' +
                                                            ' FROM Meeting__c WHERE ' + whereClause + ' LIMIT 1000');
        
        // Add all registrations to the registration list
        for (Meeting__c item : meetings) {
            for (Registration__c reg : item.Registrations__r) {
                Meeting meeting = new Meeting();
                meeting.Id = reg.Meeting__c;
                meeting.Name = reg.Meeting__r.Name;
                meeting.Type = reg.Meeting__r.Type__c;
                if (meeting.Date_Time != null)
                    meeting.Date_Time = reg.Meeting__r.DateTime__c.format('MM/dd/yyyy hh:mm a', 'America/New_York');
                if (reg.Meeting__r.Parent_Meeting__c != null)
                    meeting.ParentMeetingId = reg.Meeting__r.Parent_Meeting__c;
                // add this new registration to our list
                mWrapper.Meetings.add(meeting);
            }
        }*/
        //Modified By - Saurabh Kumar - 10/09/2020 - CR-20200819-14447: Replaced Meeting with EAB Event. End
        // set successful message
        mWrapper.Response = 'Success';
    }
    
    //Modified By - Saurabh Kumar - 10/09/2020 - CR-20200819-14447: Replaced Meeting with EAB Event.
    public void FindMeetings() {
        // build the where clause
        String whereClause = '';
        
        //Modified By - Saurabh Kumar - 10/09/2020 - CR-20200819-14447: Replaced Meeting with EAB Event. Start
        Id eabEventId;
        if ((mWrapper.ParentMeetingId != null && mWrapper.ParentMeetingId != '')) {
            whereClause += 'Parent_Event__c = \'' + mWrapper.ParentMeetingId + '\'';
        }
        else { // if the required fields aren't passed in, send back an error
            whereClause += 'Parent_Event__c = null'; // parent_meeting__c = null
        }
        //Modifed By - Saurabh Kumar - 11/09/2020 - CR-20201105-14664: Updated EAB Event's Type with EAB Event's Event Type
        List<Advisory_Event__c> eabEvents = database.query('SELECT Id, Parent_Event__c, Name, Event_Type__c, Begins__c' +
                                                            ' FROM Advisory_Event__c WHERE ' + whereClause + ' LIMIT 1000');
        
        // Add all registrations to the registration list
        for (Advisory_Event__c item : eabEvents) {
            Meeting meeting = new Meeting();
            meeting.Id = item.Id;
            meeting.Name = item.Name;
            meeting.Type = item.Event_Type__c;//Modifed By - Saurabh Kumar - 11/09/2020 - CR-20201105-14664: Updated EAB Event's Type with EAB Event's Event Type
            if (item.Begins__c != null)
                meeting.Date_Time = item.Begins__c.format('MM/dd/yyyy hh:mm a', 'America/New_York');
            if (item.Parent_Event__c != null)
                meeting.ParentMeetingId = item.Parent_Event__c;
            // add this new registration to our list
            mWrapper.Meetings.add(meeting);
        }
        
        /*Id meetingId;
        if ((mWrapper.ParentMeetingId != null && mWrapper.ParentMeetingId != '')) {
            whereClause += 'Parent_Meeting__c = \'' + mWrapper.ParentMeetingId + '\'';
        }
        else { // if the required fields aren't passed in, send back an error
            whereClause += 'Parent_Meeting__c = null'; // parent_meeting__c = null
        }
        system.debug('@@WhereClause:' + whereClause);
        List<Meeting__c> meetings = database.query('SELECT Id, Parent_Meeting__c, Name, Type__c, DateTime__c' +
                                                            ' FROM Meeting__c WHERE ' + whereClause + ' LIMIT 1000');
        
        // Add all registrations to the registration list
        for (Meeting__c item : meetings) {
        
            Meeting meeting = new Meeting();
            meeting.Id = item.Id; 
            meeting.Name = item.Name;
            meeting.Type = item.Type__c;
            if (item.DateTime__c != null)
                meeting.Date_Time = item.DateTime__c.format('MM/dd/yyyy hh:mm a', 'America/New_York');
            if (item.Parent_Meeting__c != null)
                meeting.ParentMeetingId = item.Parent_Meeting__c;
            // add this new registration to our list
            mWrapper.Meetings.add(meeting);
        }*/
        //Modified By - Saurabh Kumar - 10/09/2020 - CR-20200819-14447: Replaced Meeting with EAB Event. End
        // set successful message
        mWrapper.Response = 'Success';
    }
    
    // return an encrypted version of this object
    public String ToEncryptedString() {
        String encryptedString = '';
        String origData = JSON.serialize(mWrapper);
        blob blobData = blob.valueOf(origData);
        blob encryptedBlob = Crypto.encryptWithManagedIV('AES256', KEY, blobData);
        encryptedString = EncodingUtil.base64Encode(encryptedBlob);
        return encryptedString;
    }
}