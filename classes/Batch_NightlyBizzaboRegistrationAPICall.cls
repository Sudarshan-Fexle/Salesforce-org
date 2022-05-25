/**
 * 	@Description	:	This batch class used to hit Registration API call to Bizzabo and get Registration records.
 * 						Logic: Batch API calls (every night) which return all registrants in associated call. 
 * 						Registration records are either created (if existing registration record is not found for associated contact) 
 * 						or updated (if existing registration record is found for associated contact)
 * 
 *  @Created By		:	Saurabh Kumar 
 * 
 *  @Created Date	:	10/24/2020
 * 
 *  @Revision Log	:	V1.0 CR-20201022-14631 - Created
 *			:	V1.1 CR-20201117-14699 - 11/17/2020 - Updated by Saurabh Kumar
 * 			:	V1.2 CR-20200819-14449 - 12/17/2020 - Updated by Saurabh Kumar - Removed the meeting reference.
 * */
global class Batch_NightlyBizzaboRegistrationAPICall implements Database.Batchable<Sobject>, Database.AllowsCallouts, Database.Stateful, Schedulable{
    /*
    //Constant Variables
    public static final String HTTP_REQUEST_GET_TYPE = 'GET';
    public static final String AUTHORIZATION = 'Authorization';
    public static final String ACCEPT = 'Accept';
    public static final String APPLICATION_VND_BIZZABO = 'application/vnd.bizzabo.v2.0+json';
    public static final String BEARER = 'Bearer ';
    public static final String CONTACT_STATUS_ACTIVE = 'Active';
    
    //Set to hold email address for that send an email to Admin
    Set<String> setOfEmailsForNoContacts;
    
    //Set to hold email address of duplicate contacts for that send an email to Admin
    Set<String> setOfDuplicateContactEmails;
    
    String parameters;
    String meetingId;
    
    global Batch_NightlyBizzaboRegistrationAPICall(){}
    
    global Batch_NightlyBizzaboRegistrationAPICall(String parameters, String meetingId){
        
        this.parameters = parameters;
        this.meetingId = meetingId;
    }
    */
    global Iterable<sobject> start(Database.BatchableContext bc){
        
        /*setOfEmailsForNoContacts = new Set<String>();
        setOfDuplicateContactEmails = new Set<String>();*/
        return [Select Id From Contact Limit 1];
    }
    global void execute(Database.BatchableContext bc, List<Contact> scope){
        /*
        if(String.isBlank(parameters) || String.isBlank(meetingId))
            return;
        
        //Get end points
        List<API_Endpoints__mdt> communicationAPIDetails = [Select Id, Authorization_Token__c, 
                                                     Endpoint_URL__c From API_Endpoints__mdt 
                                                     Where MasterLabel = 'Bizzabo Registrations' LIMIT 1];
        if(communicationAPIDetails.size() == 0)
            return;
        
        Set<String> emailsWhichAlreadyAddressed = new Set<String>();
        Map<String, Duplicate_No_Active_Contact_Email__c> dupNoConEmailsToInsert = new Map<String, Duplicate_No_Active_Contact_Email__c>();
        
        //Get all emails which are already addressed
        for(Duplicate_No_Active_Contact_Email__c dupNoConEmail : [Select Email__c From Duplicate_No_Active_Contact_Email__c])
        	emailsWhichAlreadyAddressed.add(dupNoConEmail.Email__c.toLowerCase());
        
        HttpRequest request = new HttpRequest();
        request.setEndpoint(communicationAPIDetails[0].Endpoint_URL__c+parameters);
        request.setMethod(HTTP_REQUEST_GET_TYPE);
        request.setTimeout(120000);
        request.setHeader(AUTHORIZATION, BEARER+communicationAPIDetails[0].Authorization_Token__c);
        request.setHeader(ACCEPT, APPLICATION_VND_BIZZABO);
        HttpResponse res = new Http().send(request);

        if(res == null || res.getBody() == null || res.getStatusCode() != 200)
            return;
        Registration registrations =  (Registration) System.JSON.deserialize(res.getBody(), Registration.class);
        
        if(registrations == null || registrations.content == null)
            return;
        
        //Map to hold Registration by Contact's Email
        Map<String, Registration__c> registrationByEmail = new Map<String, Registration__c>();
        
        //Set to hold Email Addresses which come from Bizzabo
        Set<String> setOfEmails = new Set<String>();
        
        //Map to hold Contact by Email
        Map<String, Contact> contactsByEmails = new Map<String, Contact>();
            
        //Map to hold Registration records to upsert
        Map<String, Registration__c> registrationByEmailToUpsert = new Map<String, Registration__c>();
        
        for(Content contnt : registrations.content){
            if(contnt.properties.email != null)
                setOfEmails.add(contnt.properties.email.toLowerCase());
        }
        
        if(setOfEmails.size() == 0)
            return;
        
        for(Registration__c registration : [Select Id, Status__c, Contact__r.Email From Registration__c Where Meeting__c != null AND Meeting__c =: meetingId])
            registrationByEmail.put(registration.Contact__r.Email.toLowerCase(), registration);
        
        //Block to hold contact by emails and hold email if any duplicate is there
        for(Contact con : [Select Id, Email From Contact Where Email IN : setOfEmails AND Email != null AND Contact_Status__c =: CONTACT_STATUS_ACTIVE]){
            if(contactsByEmails.containsKey(con.Email.toLowerCase())){
                
                if(!emailsWhichAlreadyAddressed.contains(con.Email.toLowerCase())){
                    setOfDuplicateContactEmails.add(con.Email.toLowerCase());
                    
                    //V1.1 CR-20201117-14699 - 11/17/2020 - Updated by Saurabh Kumar: Start
                    String str = con.Email.toLowerCase();
                    if(str.length() > 38)
                        str = str.substringBefore('@');
                    if(str.length() > 38)
                        str = str.substring(str.length() - 38);
                    
                    dupNoConEmailsToInsert.put(con.Email.toLowerCase(), new Duplicate_No_Active_Contact_Email__c(Name = str, Email__c = con.Email.toLowerCase()));
                    //V1.1 CR-20201117-14699 - 11/17/2020 - Updated by Saurabh Kumar: End
                }
                contactsByEmails.remove(con.Email.toLowerCase());
                
            }else if(!setOfDuplicateContactEmails.contains(con.Email.toLowerCase())){
                contactsByEmails.put(con.Email.toLowerCase(), con);
            }
            
        }
            
        //Block to process Registrations
        for(Content contnt : registrations.content){
            
            if(contnt.properties.email.toLowerCase() == null || setOfDuplicateContactEmails.contains(contnt.properties.email.toLowerCase()))
                continue;
            if(!contactsByEmails.containsKey(contnt.properties.email.toLowerCase()) ){
                
                if(!emailsWhichAlreadyAddressed.contains(contnt.properties.email.toLowerCase())){
                    setOfEmailsForNoContacts.add(contnt.properties.email.toLowerCase());
                    
                    //V1.1 CR-20201117-14699 - 11/17/2020 - Updated by Saurabh Kumar: Start
                    String str = contnt.properties.email.toLowerCase().trim();
                    if(str.length() > 38)
                        str = str.substringBefore('@');
                    if(str.length() > 38)
                        str = str.substring(str.length() - 38);
                    
                    dupNoConEmailsToInsert.put(contnt.properties.email.toLowerCase().trim(), new Duplicate_No_Active_Contact_Email__c(Name = str, Email__c = contnt.properties.email.toLowerCase().trim()));
                    //V1.1 CR-20201117-14699 - 11/17/2020 - Updated by Saurabh Kumar: End
                }
            }else{
                //Valid contact exist and creating data to upsert the registration
                String status = null;
                 if(contnt.status == 'completed' && contnt.validity == 'valid')
                    status = 'Registered';
                if(contnt.checkedin == true)
                    status = 'Attended';
                if(contnt.validity == 'invalid')
                    status = 'Cancelled';
                
                //Update case
                if(registrationByEmail.containsKey(contnt.properties.email.toLowerCase())){
                    
                    Registration__c reg = registrationByEmail.get(contnt.properties.email.toLowerCase());
                    if(status != null && status != reg.Status__c){
                        
                        reg.Status__c = status;
                    	registrationByEmailToUpsert.put(contnt.properties.email.toLowerCase(), reg);
                    }
                }else{//Insert Case
                    registrationByEmailToUpsert.put(contnt.properties.email.toLowerCase(), new Registration__c(Bizzabo_Registration_ID__c = contnt.Id,
                                                                                                   Status__c = status, Contact__c = contactsByEmails.get(contnt.properties.email.toLowerCase()).Id,
                                                                                                   Meeting__c = meetingId));
                }
            }
        }
        if(registrationByEmailToUpsert.size() > 0){
            
            Util.byPassAllTriggers = true;
            upsert registrationByEmailToUpsert.values();
            Util.byPassAllTriggers = false;
        }
        if(dupNoConEmailsToInsert.size() > 0){
            insert dupNoConEmailsToInsert.values();
        }*/
    }
    global void finish(Database.BatchableContext bc){
        /*
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        
        String duplicateContactsEmails = '';
        for(String emailAddress : setOfDuplicateContactEmails)
            duplicateContactsEmails += emailAddress + ', ';
        duplicateContactsEmails = duplicateContactsEmails.removeEnd(', ');
        
        if(String.isNotBlank(duplicateContactsEmails)){
            String body = 'Hello Events Team,\n'
                +'\n'
                +'The following email address was received in the Bizzabo response and there are multiple active contacts.\n'
                +'\n'
                +'Email address in question: '+duplicateContactsEmails+'\n'
                +'\n'
                +'Please follow up on this as well as create a new registration record. This error will continue to be received until resolved.\n'
                +'\n'
                +'Thank you!';
            Messaging.SingleEmailMessage email = EmailHandler.createEmail(new List<String> {Label.LABEL_EMAIL_TO_NOTIFY_IN_CASE_OF_INVALID_CONTACT_FOR_BIAZZO_REGISTRATION}, 
                                                                          Label.LABEL_EMAIL_SUBJECT_TO_NOTIFY_IN_CASE_OF_DUPLICATE_CONTACT_FOR_BIZAAO_REGISTRTON, 
                                                                          body, null, false); 
            emails.add(email);
        }
        
        String noContactEmails = '';
        
        for(String emailAddress : setOfEmailsForNoContacts)
            noContactEmails += emailAddress + ', ';
        noContactEmails = noContactEmails.removeEnd(', ');
        
        if(String.isNotBlank(noContactEmails)){
            String body = 'Hello Events Team,\n'
                		  +'\n'
                		  +'The following email address was received in the Bizzabo response and there is no active contact.\n'
                          +'\n'
                          +'Email address in question: '+noContactEmails+'\n'
                          +'\n'
                          +'Please follow up on this as well as create a new registration record. This error will continue to be received until resolved.\n'
                          +'\n'
                          +'Thank you!';
            Messaging.SingleEmailMessage email = EmailHandler.createEmail(new List<String> {Label.LABEL_EMAIL_TO_NOTIFY_IN_CASE_OF_INVALID_CONTACT_FOR_BIAZZO_REGISTRATION}, 
                                                              Label.LABEL_EMAIL_SUBJECT_TO_NOTIFY_IN_CASE_OF_NO_CONTACT_FOR_BIZAAO_REGISTRATION, 
                                                              body, null, false); 
            emails.add(email);
        }
        
        if(emails.size() > 0)
            Messaging.sendEmail(emails);*/
    }
    
    /*//Wrappers to hold response from Bizzabo
    class Content {	
		public boolean checkedin;
		public String validity;
		public String status;
		public String id;
        public Properties properties;
	}
	class Properties {
		public String email;
	}
    class Registration{
        List<Content> content;
    }*/
    
    global void execute(SchedulableContext sc){
        /*
        String meetingId = 'a492K000001lO6KQAU';//'a49W00000000vHX';
        String eventId = '240888';
        
        Database.executeBatch(new Batch_NightlyBizzaboRegistrationAPICall('?eventId='+eventId+'&page=0&size=200', meetingId));
        Database.executeBatch(new Batch_NightlyBizzaboRegistrationAPICall('?eventId='+eventId+'&page=1&size=200', meetingId));
        Database.executeBatch(new Batch_NightlyBizzaboRegistrationAPICall('?eventId='+eventId+'&page=2&size=200', meetingId));
        Database.executeBatch(new Batch_NightlyBizzaboRegistrationAPICall('?eventId='+eventId+'&page=3&size=200', meetingId));
        Database.executeBatch(new Batch_NightlyBizzaboRegistrationAPICall('?eventId='+eventId+'&page=4&size=200', meetingId));
        Database.executeBatch(new Batch_NightlyBizzaboRegistrationAPICall('?eventId='+eventId+'&page=5&size=200', meetingId));
        Database.executeBatch(new Batch_NightlyBizzaboRegistrationAPICall('?eventId='+eventId+'&page=6&size=200', meetingId));
        Database.executeBatch(new Batch_NightlyBizzaboRegistrationAPICall('?eventId='+eventId+'&page=7&size=200', meetingId));
        Database.executeBatch(new Batch_NightlyBizzaboRegistrationAPICall('?eventId='+eventId+'&page=8&size=200', meetingId));
        Database.executeBatch(new Batch_NightlyBizzaboRegistrationAPICall('?eventId='+eventId+'&page=9&size=200', meetingId));
        Database.executeBatch(new Batch_NightlyBizzaboRegistrationAPICall('?eventId='+eventId+'&page=10&size=200', meetingId));
        Database.executeBatch(new Batch_NightlyBizzaboRegistrationAPICall('?eventId='+eventId+'&page=11&size=200', meetingId));
        Database.executeBatch(new Batch_NightlyBizzaboRegistrationAPICall('?eventId='+eventId+'&page=12&size=200', meetingId));
        Database.executeBatch(new Batch_NightlyBizzaboRegistrationAPICall('?eventId='+eventId+'&page=13&size=200', meetingId));
        Database.executeBatch(new Batch_NightlyBizzaboRegistrationAPICall('?eventId='+eventId+'&page=14&size=200', meetingId));
        Database.executeBatch(new Batch_NightlyBizzaboRegistrationAPICall('?eventId='+eventId+'&page=15&size=200', meetingId));
        Database.executeBatch(new Batch_NightlyBizzaboRegistrationAPICall('?eventId='+eventId+'&page=16&size=200', meetingId));
        Database.executeBatch(new Batch_NightlyBizzaboRegistrationAPICall('?eventId='+eventId+'&page=17&size=200', meetingId));
        Database.executeBatch(new Batch_NightlyBizzaboRegistrationAPICall('?eventId='+eventId+'&page=18&size=200', meetingId));
        Database.executeBatch(new Batch_NightlyBizzaboRegistrationAPICall('?eventId='+eventId+'&page=19&size=200', meetingId));
        Database.executeBatch(new Batch_NightlyBizzaboRegistrationAPICall('?eventId='+eventId+'&page=20&size=200', meetingId));*/
    }
}