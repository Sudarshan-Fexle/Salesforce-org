/*
Web service implementation class for CrimsonSummit Attendee Service

Revision 1.1    SUNJ    Get Speaker Note from the main event.
Revision 1.2    SUNJ    Move unit test to TestCrimsonSummit_Attendee_Service. 
Revision 1.3 -  Modified by Saurabh Kumar - 10/09/2020 - CR-20200819-14447: Replaced Meeting reference with EAB Event
*/
@RestResource(urlMapping='/CrimsonSummit/Attendee/*')
global with sharing class CrimsonSummit_Attendee_Service {

    // object to hold attendee data
    global class Attendee{
        public Attendee() {
            Sessions = new List<Session>();
            SpeakerNote = '';
        }
        public String Id { get; set; }
        public String ContactId { get; set; }
        public String FirstName { get; set; }
        public String FullName { get; set; }
        public String Organization { get; set; }
        public String CityState { get; set; }
        public String SpeakerNote { get; set; }
        public List<Session> Sessions { get; set; }
    }
    global class Session {
        public String Id { get; set; }
        public String Meeting { get; set; }
        public string MeetingDate { get; set; }
        public String Location { get; set; }
    }
    
    //Updated by Saurabh Kumar - 10/09/2020 - CR-20200819-14447: Replaced Meeting reference with EAB Event
    @HttpGet
    global static List<Attendee> getAll() {
        RestRequest req = RestContext.request;
        //RestResponse res = RestContext.response;
        String meetingName = EncodingUtil.urlDecode(req.requestURI.substring(req.requestURI.lastIndexOf('/')+1), 'UTF-8');
        
        List<Registration__c> registrations = [
            SELECT Id, Contact__c, Contact__r.Counter_ID__c, Contact__r.FirstName, Contact__r.LastName,
            Contact__r.Suffix__c, Contact__r.Account.Account_Formal_Name__c, Contact__r.Account.Primary_City__c,
            Contact__r.Account.Primary_State_Province__c/*, Speaker_Note__c*/
            FROM Registration__c
            WHERE EAB_Event__r.Parent_Event__r.Name = :meetingName AND Status__c = 'Registered'//Updated by Saurabh Kumar - 10/09/2020 - CR-20200819-14447: from Meeting__r.Parent_Meeting__r.Name to EAB_Event__r.Parent_Event__r.Name
            ORDER BY Contact__r.FirstName, Contact__r.LastName
        ];
        
        List<Attendee> attendees = new List<Attendee>();
        Map<Id, Attendee> attendeeIds = new Map<Id, Attendee>();
        for(Registration__c reg : registrations)
        {
            if(attendeeIds.containsKey(reg.Contact__c)){
                Attendee attendee1 = attendeeIds.get(reg.Contact__c);
                /*if(reg.Speaker_Note__c != null && attendee1.SpeakerNote == '') {
                    attendee1.SpeakerNote = reg.Speaker_Note__c;
                }*/
                continue;
            }
            
            Attendee attendee = new Attendee();
            attendee.Id = reg.Contact__c;
            attendee.ContactId = reg.Contact__r.Counter_ID__c;
            attendee.FirstName = reg.Contact__r.FirstName;
            if(reg.Contact__r.Suffix__c == null) {
                attendee.FullName = reg.Contact__r.FirstName + ' ' + reg.Contact__r.LastName;
            } else {
                attendee.FullName = reg.Contact__r.FirstName + ' ' + reg.Contact__r.LastName + ', ' + reg.Contact__r.Suffix__c;
            }
            attendee.Organization = reg.Contact__r.Account.Account_Formal_Name__c + '';
            attendee.CityState = reg.Contact__r.Account.Primary_City__c + ', ' + reg.Contact__r.Account.Primary_State_Province__c;
            /*if(reg.Speaker_Note__c == null)
                attendee.SpeakerNote = '';
            else
                attendee.SpeakerNote = reg.Speaker_Note__c;*/
            attendees.add(attendee);
            
            attendeeIds.put(reg.Contact__c, attendee);
        }
        
        //Updated by Saurabh Kumar - 10/09/2020 - CR-20200819-14447: Replaced Meeting with EAB Event. Start
        // We want to return all the registration with speaker note at the main EAB Event level
        registrations = [
            SELECT Id, Contact__c, EAB_Event__r.Name, EAB_Event__r.Begins__c, EAB_Event__r.Location__c 
            FROM Registration__c
            WHERE EAB_Event__r.Parent_Event__r.Parent_Event__r.Name = :meetingName
            ORDER BY Contact__c, EAB_Event__r.Begins__c
        ];
        
        for(Registration__c reg : registrations) {
            // This should not happen.  Just in case this cause any issue ...
            if(!attendeeIds.containsKey(reg.Contact__c)) continue;
            
            Attendee attendee = attendeeIds.get(reg.Contact__c);
            Session session = new Session();
            session.Id = reg.Id;
            session.Meeting = reg.EAB_Event__r.Name;
            session.MeetingDate = reg.EAB_Event__r.Begins__c.format('EEE h:mmaa').replace('AM', 'am').replace('PM','pm');
            if(reg.EAB_Event__r.Location__c == null) {
                session.Location = 'TBD';
            } else {
                session.Location = reg.EAB_Event__r.Location__c;
            }
            attendee.Sessions.add(session);
        }
        
        // We want to return all the registration with speaker note at the main meeting level
        /*registrations = [
            SELECT Id, Contact__c, Meeting__r.Name, Meeting__r.DateTime__c, Meeting__r.Location__c 
            FROM Registration__c
            WHERE Meeting__r.Parent_Meeting__r.Parent_Meeting__r.Name = :meetingName
                AND Meeting__r.Display_On_Badge__c = TRUE
            ORDER BY Contact__c, Meeting__r.DateTime__c
        ];
        
        
        for(Registration__c reg : registrations) {
        
            // This should not happen.  Just in case this cause any issue ...
            if(!attendeeIds.containsKey(reg.Contact__c)) continue;
            
            Attendee attendee = attendeeIds.get(reg.Contact__c);
            Session session = new Session();
            session.Id = reg.Id;
            session.Meeting = reg.Meeting__r.Name;
            session.MeetingDate = reg.Meeting__r.DateTime__c.format('EEE h:mmaa').replace('AM', 'am').replace('PM','pm');
            if(reg.Meeting__r.Location__c == null) {
                session.Location = 'TBD';
            } else {
                session.Location = reg.Meeting__r.Location__c;
            }
            attendee.Sessions.add(session);
        }*/
        //Updated by Saurabh Kumar - 10/09/2020 - CR-20200819-14447: Replaced Meeting with EAB Event. End
        return attendees;
    }
}