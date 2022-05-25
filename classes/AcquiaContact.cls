/**
 *  Description     :   Wrapper for Acquia Segment object
 *
 *  Revision Logs   :   V1.0 - 02/25/2021 - CR-20210128-14855 - Victor Hanson - Created
 *		    :   V1.1 - 06/04/2021 - CR-20210128-14854 - Modified By - Chirag Soni - QA&UAT Issues (MRS 2.0 Phase 2/3) - Issue #43 Added Event date and event time variable in order to send in Acquia System. 
 *		    :   V1.2 - 09/28/2021 - CR-20210606-15193 - Modified By - Lawrence Lam - modified to have only Registrations marked into Acquia as Contacts
**/
public class AcquiaContact{
    
/**
 *  Description     :   convert acquia contact object into json their API can understand
 *
 *  Revision Logs   :   v1.0 - 02/25/2021 - CR-20210128-14855 - Victor Hanson - Created
**/
    //09/28/2021 - CR-20210606-15193 - Modified By - Lawrence Lam
    public static String parse(AcquiaContact.All aContact) {
        String json = JSON.serialize(aContact);
        return JsonUtilities.replaceFields(json, fieldsToReplace_External);
    }
    
/**
 *  Description     :   convert acquia contact object into json their API can understand
 *
 *  Revision Logs   :   v1.0 - 09/28/2021 - CR-20210606-15193 - Lawrence Lam - Created
**/
    public static String parse(List<AcquiaContact.All> aContactList) {
        String json = JSON.serialize(aContactList);
        return JsonUtilities.replaceFields(json, fieldsToReplace_External);
    }
    
/**
 *  Description     :   convert raw acquia contact json into json we can understand
 *
 *  Revision Logs   :   v1.0 - 02/25/2021 - CR-20210128-14855 - Victor Hanson - Created
**/
    public static AcquiaContact parse(String json) {
        json = JsonUtilities.replaceFields(json, fieldsToReplace);
        return (AcquiaContact) System.JSON.deserialize(json, AcquiaContact.class);
    }
    
    public contact contact;
    public class contact {
        public Integer id;	//1
        public Integer points;	//0
        public fields fields;
        public tags[] tags;
        public utmtags[] utmtags;
        public stage stage;
        public customObjects customObjects;
    }
    
    public class fields {
        public all all;
    }
    
    public class all {
        public String id;
        public String title;
        public String longtitle;
        public String assistant_name;
        public String assistant_email;
        public String contact_status;
        public String firstname;
        public String lastname;	
        public String email;	
        public String company;	
        public String phone;
        public Integer points;	
        public String address1;
        public String address2;
        public String city;
        public String state_abbreviation;
        public String zipcode;
        public String country1;
        public String preferred_locale;
        public String timezone;
        public String longdate;
        public String eventid;	
        public String eventname; 
        public String status;	 

        public Date eventdate; 
        public String eventtime;
        
        public String location;
        public String alternatecontactemail;
        public String partnerstatus;
        public String dinnerrsvp;
        public String zoomparticipanturl; 
        public String zoommeetingid;	  
        public String zoomdialinnumber;	  
        public String onetouchmobiledialin;
        public String zoompassword; 
        public String registrationapproveddate;
        public String eventwebsite;
        public String evaluationlink;
	
        //V1.2 - 08/24/2021 - CR-20210606-15193 - Modified - Lawrence Lam- added Local Dates/Times
        public String localtimezone;
        public String localeventstartdate;
        public String localeventstarttime;
        public String localeventenddate;
        public String localeventendtime;
        public String registration_name;
        public String longevent_date;
        public String eventstartdate;
        public String eventenddate;
        public String eventendtime;
        public String registeredondate;
    }
    
    class tags {
        public Integer id;
        public String tag;
    }
    
    class utmtags {
    }
    
    class stage {
    }
    
    public class customObjects {
        public data[] data;
    }
    
    public class data {
        public data[] data;
        public Integer id;
        public String name;	
        public String alias;
        public language language;
        public category category;
        public boolean isPublished;
        public String dateAdded;
        public String dateModified;
        public attributes attributes;
    }
    class language {
    }
    
    class category {
    }
    
    public class attributes {
        public String longdate;	
        public String eventid;	
        public String eventname;
        public String status;	
        
        public Date eventdate; 
        public String eventtime; 
        public String location;	
        public String alternatecontactemail;
        public String partnerstatus;	
        public String dinnerrsvp;	
        public String zoomparticipanturl;
        public String zoommeetingid;
        public String zoomdialinnumber;	
        public String onetouchmobiledialin;
        public String registrationapproveddate;
        public String eventwebsite;
        public String evaluationlink;
        
	//V1.2 - 08/24/2021 - CR-20210606-15193 - Modified - Lawrence Lam- added Local Dates/Times
        public String localtimezone;
        public String localeventstartdate;
        public String localeventstarttime;
        public String localeventenddate;
        public String localeventendtime;
        public String registeredondate;
    }
    
    public static Map<String, String> fieldsToReplace {
        get {
            if (fieldsToReplace == null) {
                fieldsToReplace = new Map<String, String> {
                    	'event-id' => 'event_id',
                        'long-date' => 'long_date',
                        'event-name' => 'event_name',
                        'local-time' => 'local_time',
                        'local-long-date' => 'local_long_date',
                        'alternate-contact-email' => 'alternate_contact_email',
                        'partner-status' => 'partner_status',
                        'dinner-rsvp' => 'dinner_rsvp',
                        'zoom-participant-url' => 'zoom_participant_url',
                        'zoom-meeting-id' => 'zoom_meeting_id',
                        'zoom-dial-in-number' => 'zoom_dial_in_number',
                        'one-touch-mobile-dial-in' => 'one_touch_mobile_dial_in'
                        };
                            }
            return fieldsToReplace;
        }
        set;
    }
    
    //08/24/2021 - CR-20210606-15193 - Modified By - Chirag Soni
    public static Map<String, String> fieldsToReplace_External {
        get {
            if (fieldsToReplace == null || Test.isRunningTest()) {
                fieldsToReplace = new Map<String, String> {
                    	'event_id' => 'event-id',
                        'long_date' => 'long-date',
                        'event_name' => 'event-name',
                        'local_time' => 'local-time',
                        'local_long_date' => 'local-long-date',
                        'alternate_contact_email' => 'alternate-contact-email',
                        'partner_status' => 'partner-status',
                        'dinner_rsvp' => 'dinner-rsvp',
                        'zoom_participant_url' => 'zoom-participant-url',
                        'zoom_meeting_id' => 'zoom-meeting-id',
                        'zoom_dial_in_number' => 'zoom-dial-in-number',
                        'one_touch_mobile_dial_in' => 'one-touch-mobile-dial-in'
                        };
                            }
            return fieldsToReplace;
        }
        set;
    }
}