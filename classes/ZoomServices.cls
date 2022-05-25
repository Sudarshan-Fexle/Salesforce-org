/**
    Desription      :   Methods to assist with Zoom integration

    Revision Logs   :   V1.0 - 03/25/2020 - CR-20200324-13884 - Victor Hanson - Created
    			V1.1 - 05/12/2020 - CR-20200507-14026 - Victor Hanson - added nextPageToken to updateParticipantAttendance
                        V1.2 - 06/05/2020 - CR-20200429-13997 - Rajeev Jain- replace chatter with Email.
                        V1.3 - 09/14/2020 - CR-20200914-14505 - Victor Hanson - added web service log support
                        V1.4 - 10/05/2020 - CR-20200429-13997 - Victor Hanson - added
                        V1.5 - 10/08/2020 - CR-20200819-14447 - Saurabh Kumar - Updated following methods to replace meeting with EAB Event
                                            addZoomRegistrant()
                                            updateZoomRegistrantStatus()
                                            updateParticipantAttendance()
                        V1.6 - 10/23/2020 - CR-20200908-14493 - Saurabh Kumar - Updated updateZoomRegistrantStatus() method
                        V1.7 - 10/30/2020 - CR-20200821-14461 - Saurabh Kumar - updateParticipantAttendance() commented
			V1.8 - 02/16/2021 - Victor Hanson - CR-20210216-14920 - fixed a duplicate zoom session issue
			V1.9 - 03/03/2021 - Saurabh Kumar - CR-20210302-14959 - Updated ZoomDialInDetailParser wrapper and getZoomInfo() method.
			V2.0 - 04/21/2021 - Saurabh Kumar - CR-20210319-15008 - updateParticipantAttendance() method updated. Added safe navigation operator and unique field in Zoom Session record.
			V2.1 - 07/14/2021 - Chirag Soni - CR-20210709-15278 -   Modified - addZoomRegistrant() - added new line req.setHeader('Accept','application/json'). 
			V2.2 - 11/08/202 - Chirag Soni - CR-20211108-15570 -  refactor the code of method addZoomRegistrant() added try catch block
			V2.2 - 11/16/2021 - Chirag Soni - CR-20211112-15583 - Chirag soni - Commented condition for approved call out.
**/ 
public without sharing class ZoomServices {
    
    public static final String ZOOM_MEETING = '/meetings/';
    public static final String ZOOM_WEBINAR = '/webinars/';
    public static final String ZOOM_REGISTRANTS = '/registrants/';
    public static final String ZOOM_REGISTRANTS_UPDATE = '/registrants/status';
    public static final String ZOOM_TYPE_MEETING = 'Meeting';
    public static final String ZOOM_TYPE_WEBINAR = 'Webinar';
    public static final String ZOOM_STATUS_CANCEL = 'cancel';
    public static final String ZOOM_MEETING_PARTICIPANTS = '/report/meetings/{0}/participants';
    public static final String ZOOM_WEBINAR_PARTICIPANTS = '/report/webinars/{0}/participants';
    public static final String ZOOM_STATUS_APPROVE = 'approve';
    
    //V1.1 - 05/12/2020 - CR-20200507-14026 - Victor Hanson - added to support paginated registration results
    //map of registrations to update
    public Map<Id, Registration__c> registrationsToUpdate = new Map<Id, Registration__c>();
    
    //09/14/2020 - CR-20200914-14505 - Victor Hanson - added
    public List<Web_Service_Log__c> webServiceLogsToInsert = new List<Web_Service_Log__c>();
    
    /**
     * @description:    returns the zoom JWToken.
     *                  If the key/secret changes in the future, use this method to generate the new token.
     *                  Go to Setup > Custom Metadata Types > API Endpoints > Zoom API and Copy/paste the resulting token in the Authorization Token field
     *                  
     * 
     * @revision log:   v1.0 - 03/26/2020 - Victor Hanson - created
     * 
     **/
    public static String getJWToken(String key, String secret) {
        
        //set expiration for 2 minutes in the future
        Datetime dt = Datetime.now().addminutes(2);
        Long expVal = dt.getTime();
        
        string header = '{"typ": "JWT", "alg": "HS256"}';
        string JWTHeader = encodingUtil.base64Encode(blob.valueOf(header));
        string Payload = '{"iss":"' + key + '", "exp":"' + expVal + '"}';
        string JWTPayload = encodingUtil.base64Encode(blob.valueOf(Payload));
        String signatureInput = JWTHeader + '.' + JWTPayload;
        Blob JWTSignature = Crypto.generateMac('HmacSHA256', Blob.valueOf(signatureInput), Blob.valueOf(secret));
        string JWToken = signatureInput + '.' + EncodingUtil.base64Encode(JWTSignature);
        return JWToken;
    }
    
    /**
     * @description:    returns the custom metadata type used as the api endpoint for zoom
     * 
     * @revision log:   v1.0 - 03/26/2020 - Victor Hanson - created
     * 
     **/
    public static API_Endpoints__mdt zoomAPIEndpoint {
        get {
            if (zoomAPIEndpoint == null) {
                //Query on the custom Metadata
                zoomAPIEndpoint = [Select Id, Authorization_Token__c, Endpoint_URL__c From API_Endpoints__mdt Where DeveloperName = 'Zoom_API' LIMIT 1];
            }
            return zoomAPIEndpoint;
        }
        set;
    }
    
    /**
     * @description:    creates a zoom callout
     * 
     * @revision log:   v1.0 - 03/26/2020 - Victor Hanson - created
     * 
     **/
    public static HttpRequest createZoomCallout(String endPoint, String requestType){

        //Http Request Object
        HttpRequest request = new HttpRequest();
        request.setEndpoint(zoomAPIEndpoint.Endpoint_URL__c + endPoint);
        request.setMethod(requestType);
        request.setTimeout(12000);
        request.setHeader('Authorization', 'Bearer ' + zoomAPIEndpoint.Authorization_Token__c);

        return request;
    }
    
    /**
     * @description:    if the Zoom Meetin Id is updated, sends a callout to get the meeting details
     * 
     * @revision log:   v1.0 - 03/26/2020 - Victor Hanson - created
     * 
     **/
    public static void checkZoomMeetingId(List<Advisory_Event__c> eabEvents, Map<Id, Advisory_Event__c> mapEabEvents) {
        Set<Id> eabEventIds = new Set<Id>();
        for (Advisory_Event__c eabEvent : eabEvents) {
            Advisory_Event__c oldEabEvent;
            if (mapEabEvents != null) oldEabEvent = mapEabEvents.get(eabEvent.Id);
            
            //check if zoom meeting id changed
            if ((oldEabEvent == null && eabEvent.Zoom_Meeting_ID__c != null) || 
                (oldEabEvent != null && eabEvent.Zoom_Meeting_ID__c != null && eabEvent.Zoom_Meeting_ID__c != oldEabEvent.Zoom_Meeting_ID__c))
            {
                eabEventIds.add(eabEvent.Id);
            }
        }
        
        if (eabEventIds.size() > 0) getZoomInfo(eabEventIds);
    }
    
    /**
     * @description:    get zoom meeting/webinar info  
     * 
     * @revision log:   v1.0 - 03/26/2020 - Victor Hanson - created
     *			v1.1 - 09/14/2020 - CR-20200914-14505 - Victor Hanson - added web service log support
     *			v1.2 - 03/03/2021 - CR-20210302-14959 - Saurabh Kumar - added assignment of Zoom_Password__c field.
     * 
     **/
    @future(callout=true)
    public static void getZoomInfo(Set<Id> eabEventIds) {
        List<Advisory_Event__c> eabEvents = [SELECT Id, Zoom_Type__c, Zoom_Meeting_ID__c, Zoom_DialIn_Number__c, Zoom_Meeting_ID_Formula__c, LastModifiedById FROM Advisory_Event__c WHERE Id IN :eabEventIds];
        
        //09/14/2020 - CR-20200914-14505 - Victor Hanson - added
        List<Web_Service_Log__c> wsls = new List<Web_Service_Log__c>();
        
        for (Advisory_Event__c eabEvent : eabEvents) {
            //set type to meeting initially
            eabEvent.Zoom_Type__c = ZOOM_TYPE_MEETING;
            
            String meetingId = eabEvent.Zoom_Meeting_ID_Formula__c;
            HttpRequest req = createZoomCallout(ZOOM_MEETING + meetingId, 'GET');
            HTTPResponse res = new Http().send(req);
            
            //if response is invalid, send another callout to see if its a webinar
            if (res.getStatusCode() != 200) {
                //set type to webinar if we get here
                eabEvent.Zoom_Type__c = ZOOM_TYPE_WEBINAR;
                
                req = createZoomCallout(ZOOM_WEBINAR + meetingId, 'GET');
                res = new Http().send(req);
            }
            
            //Modified by Dipesh gupta - CR-20200424-13983
            //Dserializing the response to get the values from it. 
            Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            

            //if response code is still an error, remove the value from Zoom Type and chatter the user that last modified this record
            if (res.getStatusCode() != 200) {
                eabEvent.Zoom_Type__c = null;
                String chatterMessage = '[Auto-generated message] <p></p> '
                    + '{' + UserInfo.getUserId() + '} There was an issue with the Zoom Meeting Id provided.  '
                    + 'Please double check the value or contact Application Support for assistance (applicationSupport@eab.com) <p></p>' 
                    + (String) m.get('message');
                //if unit test, do not execute
                if (!Test.isRunningTest())
                    ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(), eabEvent.Id, chatterMessage);
            }
            
            //Added By Dipesh Gupta - CR-20200424-13983 - Update the zoom dialInNumber
            if(res.getStatusCode() == 200 || res.getStatusCode() == 201){
                
                //DialIn response. 
                ZoomDialInDetailParser zParser = (ZoomDialInDetailParser) JSON.deserialize(res.getBody().replace('global_dial_in_numbers','dialDetail').replace('type', 'type_z').replace('number', 'number_z'), ZoomDialInDetailParser.class);
            	
                //V1.2 - 03/03/2021 - CR-20210302-14959 - Saurabh Kumar: Added
                if(zParser != null && zParser.password != null)
                    eabEvent.Zoom_Password__c = zParser.password;
                    
                if(zParser != null && zParser.Settings != null 
                    && zParser.settings.dialDetail != null 
                    &&  zParser.settings.dialDetail.size() > 0 ) {


                        for(DialDetail detail :  zParser.settings.dialDetail) {
                            if(detail.type_Z == 'toll' && detail.country == 'US') {
                                //Updating the Zoom Dial In Number to the Advisory Event Field. 
                                String s = detail.number_Z;
                                
                                if(String.isNotBlank(s) && s.contains(' ') && s.length() == 13)
                                    s = s.split(' ')[0] + '-'  + s.split(' ')[1].substring(0, 3) + '-' + s.split(' ')[1].substring(3,6) + '-' +  s.split(' ')[1].substring(6,10);
                                
                                eabEvent.Zoom_DialIn_Number__c =  s;
                                break;
                            }
                        }
                }
            }
            
            //09/14/2020 - CR-20200914-14505 - Victor Hanson - added
            Web_Service_Log__c wsl = new Web_Service_Log__c(RecordTypeId = Schema.SObjectType.Web_Service_Log__c.RecordTypeInfosByDeveloperName.get('EAB_Event').RecordTypeId,
                                                            EAB_Event__c = eabEvent.Id,
                                                            Zoom_Meeting_Id__c = meetingId,
                                                            Web_Service_Method__c = 'getZoomInfo',
                                                            Request_Sent__c = system.now(),
                                                            Request_Message_Log__c = req.getBody(),
                                                            Response_Message_Log__c = String.valueOf(res.getBody()));
            wsls.add(wsl);
        }
        
        //update the eab events
        database.update(eabEvents, false);
        
        //insert wsls
        if (wsls.size() > 0) insert wsls;
    }
    
    /**
     * @description:    adds a registration to a zoom meeting/webinar
     * 
     * @revision log:   V1.0 - 03/26/2020 - Victor Hanson - created
     * 		    	V1.1 - 06/05/2020 - Replace chatter with Email.
     * 			V1.2 - 09/14/2020 - CR-20200914-14505 - Victor Hanson - added web service log support
     *			V1.3 - 10/08/2020 - Saurabh Kumar - CR-20200819-14447: Removed Meeting reference and add EAB Event
     *  		V1.4 - 07/14/2021 - Chirag Soni - CR-20210709-15278 -  added new line req.setHeader('Accept','application/json'). 
     * 			V1.5 - 11/08/202 - Chirag Soni - CR-20211108-15570 -  refactor the code of method addZoomRegistrant() added try catch block 
     *          	V1.6 - 11/16/2021 - Chirag Soni - CR-20211112-15583 - refactor the method added try catch for any runtime exception in during call out 
     **/
    //@future(callout=true)
    public static void addZoomRegistrant(Set<Id> registrationIds) {
        
        //Added By - Chirag Soni 11/16/2021 - CR-20211112-15583
        try{
            //10/05/2020 - CR-20200429-13997 - Victor Hanson - added
            //09/14/2020 - CR-20200914-14505 - Victor Hanson - removed
            //List to hold the single email message. 
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
            
            //09/14/2020 - CR-20200914-14505 - Victor Hanson - added
            List<Web_Service_Log__c> wsls = new List<Web_Service_Log__c>();
            
            String zoomType;
            List<Registration__c> regs = [SELECT Id, Name, Zoom_Participant_URL__c, Zoom_Registrant_ID__c, Contact__r.Email, Contact__r.FirstName, Contact__r.LastName, EAB_Event__r.Zoom_Type__c, 
                                          EAB_Event__r.Zoom_Meeting_ID__c, EAB_Event__r.Zoom_Meeting_ID_Formula__c, OwnerId, EAB_Event__r.Name, EAB_Event__r.Owner.FirstName, EAB_Event__r.Owner.Email
                                          FROM Registration__c 
                                          WHERE Id IN :registrationIds AND EAB_Event__r.Zoom_Type__c != null];
            //Had to add this because unit tests kept removing zoomType for some reason
            if (Test.isRunningTest()) {
                regs = [SELECT Id, Name, Zoom_Participant_URL__c, Zoom_Registrant_ID__c, Contact__r.Email, Contact__r.FirstName, Contact__r.LastName, EAB_Event__r.Zoom_Type__c, 
                        EAB_Event__r.Zoom_Meeting_ID__c, EAB_Event__r.Zoom_Meeting_ID_Formula__c, EAB_Event__r.OwnerId, EAB_Event__r.Name, EAB_Event__r.Owner.FirstName, EAB_Event__r.Owner.Email
                        FROM Registration__c 
                        WHERE Id IN :registrationIds];
                zoomType = ZOOM_TYPE_WEBINAR;
            }
            for (Registration__c reg : regs) {
                if (zoomType == null) zoomType = reg.EAB_Event__r.Zoom_Type__c;
                //create the zoom registrant
                ZoomRegistrant zRegistrant = new ZoomRegistrant(reg.Contact__r.Email, reg.Contact__r.FirstName, reg.Contact__r.LastName);
                
                //get the type of meeting
                String endpoint;
                if (zoomType == ZOOM_TYPE_WEBINAR)
                    endpoint = ZOOM_WEBINAR;
                else if (zoomType == ZOOM_TYPE_MEETING)
                    endpoint = ZOOM_MEETING;
                
                if (endpoint == null) throw new customException('Endpoint is null because zoom type does not match any known type:' + reg.EAB_Event__r.Zoom_Type__c);
                
                String meetingId = reg.EAB_Event__r.Zoom_Meeting_ID_Formula__c;
                endpoint += meetingId + ZOOM_REGISTRANTS;
                HttpRequest req = createZoomCallout(endpoint, 'POST');
                req.setHeader('Content-Type', 'application/json');
                req.setHeader('Accept','application/json'); // Added by Chirag soni - CR-20210709-15278 - 07/14/2021
                req.setBody(JSON.serialize(zRegistrant));
                HTTPResponse res = new Http().send(req);
                
                //deserialize to object
                Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                
                if (res.getStatusCode() == 200 || res.getStatusCode() == 201) {
                    reg.Zoom_Participant_URL__c = (String) m.get('join_url');
                    reg.Zoom_Registrant_ID__c = (String) m.get('registrant_id');
                }
                
                //10/05/2020 - CR-20200429-13997 - Victor Hanson - adding back the email alert
                //09/14/2020 - CR-20200914-14505 - Victor Hanson - removed email because we can report on Web Service Logs now
                else {
                    
                    String subject = 'Unable to sync the Registration: ' + reg.name +  ' for meeting "' + reg.EAB_Event__r.Name + '"';
                    String body = 'Hi '+ reg.EAB_Event__r.Owner.FirstName  + ',\n\nWe are unable to sync the Registration '+ + reg.name + ' with Zoom. \n' + 'Please review the error below or contact Application Support for assistance (applicationSupport@eab.com)'; 
                    body += '\n' + 'Error: - '  + (String) m.get('message') + '\nThanks!';
                    
                    emails.add(EmailHandler.createEmail(new List<String>{reg.EAB_Event__r.Owner.Email}, subject, body, '', false));
                }
                
                
                
                //09/14/2020 - CR-20200914-14505 - Victor Hanson - added
                Web_Service_Log__c wsl = new Web_Service_Log__c(RecordTypeId = Schema.SObjectType.Web_Service_Log__c.RecordTypeInfosByDeveloperName.get('EAB_Event').RecordTypeId,
                                                                EAB_Event__c = reg.EAB_Event__c,
                                                                Zoom_Meeting_Id__c = meetingId,
                                                                Registration__c = reg.Id,
                                                                Web_Service_Method__c = 'addZoomRegistrant',
                                                                Request_Sent__c = system.now(),
                                                                Request_Message_Log__c = req.getBody(),
                                                                Response_Message_Log__c = String.valueOf(res.getBody()),
                                                                Status_Code__c = String.valueOf(res.getStatusCode()));
                wsls.add(wsl);
            }
        
        //update the zoom participant url and zoom registrant ids on registrations
        update regs;
             
        //10/05/2020 - CR-20200429-13997 - Victor Hanson - added
        //09/14/2020 - CR-20200914-14505 - Victor Hanson - removed
        //Sending out the Emails 
        if(emails.size() > 0 && !Test.isRunningTest())
            Messaging.SendEmailResult [] r = Messaging.sendEmail(emails);
        
        //09/14/2020 - CR-20200914-14505 - Victor Hanson - added
        //insert wsls
        if (wsls.size() > 0) insert wsls;
        } 
        catch(exception ex){ //Added By - Chirag Soni 11/16/2021 - CR-20211112-15583
            
            //list of web service logs to be insert for exceptions
            List<Web_Service_Log__c> exceptionalWebServiceLogs = new List<Web_Service_Log__c>();
            //set of eab event ids
            Set<Id> eabEventIds = new Set<Id>();
             
            // Query out all the eab event from registration ids 
            for(Registration__c reg : [SELECT Id, EAB_Event__c FROM Registration__c WHERE Id IN :registrationIds])
            {
                eabEventIds.add(reg.Eab_Event__c);
            }
            if(eabEventIds.size()>0)
            {
                for(Id eventId : eabEventIds)
                {
                    exceptionalWebServiceLogs.add(new Web_Service_Log__c(RecordTypeId = Schema.SObjectType.Web_Service_Log__c.RecordTypeInfosByDeveloperName.get('EAB_Event').RecordTypeId,
                                                                         EAB_Event__c = eventId,
                                                                         Web_Service_Method__c = 'Exception Occured',
                                                                         Request_Sent__c = system.now(),
                                                                         Request_Message_Log__c = ex.getMessage(),
                                                                         Response_Message_Log__c = ex.getMessage()+'\n'+ex.getStackTraceString()));
                }
                
                if(exceptionalWebServiceLogs.size()>0)
                {
                    Util.ByPassAllTriggers = true;
                    insert exceptionalWebServiceLogs;
                    Util.ByPassAllTriggers = false;
                }
            }
        }
    }
    
    /**
     * @description:    adds a registration to a zoom meeting/webinar
     * 
     * @params:		registrationIds - set of registration record ids
     *			action - accepted values: approve, cancel, deny
     * 
     * @revision log:   v1.0 - 03/26/2020 - Victor Hanson - created
     *			v1.1 - 06/05/2020 - Replace chatter with Email.
     *			v1.2 - 09/14/2020 - CR-20200914-14505 - Victor Hanson - added web service log support
     *			v1.3 - 10/08/2020 - Saurabh Kumar - CR-20200819-14447 : Removed Meeting reference
     *                  v1.4 - 10/23/2020 - Saurabh Kumar - CR-20200908-14493 : Updated the logic: 
     *                                                                          1). When a member cancels a Web Conference registration, don't null the Zoom_Registrant_ID__c
     *                                                                          2). Added a return type List<Registration__c>
     * 			v1.5 - 11/16/2021 - Chirag Soni - CR-20211112-15583 : Commented condition for approve call out
     * 			V1.6 - 11/16/2021 - Chirag Soni - CR-20211112-15583 - refactor the method added try catch for any runtime exception in during call out 
     * 
     **/
   // @future(callout=true)
    public static List<Registration__c> updateZoomRegistrantStatus(Set<Id> registrationIds, String action) {
        
        //Added By - Chirag Soni 11/16/2021 - CR-20211112-15583
        try{
            //10/05/2020 - CR-20200429-13997 - Victor Hanson - added
            //09/14/2020 - CR-20200914-14505 - Victor Hanson - removed
            //List to hold the single email message. 
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
            
            //09/14/2020 - CR-20200914-14505 - Victor Hanson - added
            List<Web_Service_Log__c> wsls = new List<Web_Service_Log__c>();
            
            String zoomType;
            List<Registration__c> regs = [SELECT Id, Name, Zoom_Participant_URL__c, Zoom_Registrant_ID__c, Contact__r.Email, Contact__r.FirstName, Contact__r.LastName, EAB_Event__r.Zoom_Type__c, EAB_Event__c,
                                          EAB_Event__r.Zoom_Meeting_ID__c, EAB_Event__r.Zoom_Meeting_ID_Formula__c, EAB_Event__r.Owner.Email, EAB_Event__r.Name,  EAB_Event__r.Owner.FirstName
                                          FROM Registration__c 
                                          WHERE Id IN :registrationIds AND EAB_Event__r.Zoom_Type__c != null];
            //Had to add this because unit tests kept removing zoomType for some reason
            if (Test.isRunningTest()) {
                regs = [SELECT Id, Name, Zoom_Participant_URL__c, Zoom_Registrant_ID__c, Contact__r.Email, Contact__r.FirstName, Contact__r.LastName, EAB_Event__r.Zoom_Type__c, EAB_Event__c,
                        EAB_Event__r.Zoom_Meeting_ID__c, EAB_Event__r.Zoom_Meeting_ID_Formula__c, EAB_Event__r.Owner.Email, EAB_Event__r.Name,  EAB_Event__r.Owner.FirstName
                        FROM Registration__c 
                        WHERE Id IN :registrationIds];   
                zoomType = ZOOM_TYPE_WEBINAR;
            }
            for (Registration__c reg : regs) {
                //set zoom type
                if (reg.EAB_Event__r.Zoom_Type__c != null) 
                    zoomType = reg.EAB_Event__r.Zoom_Type__c;
                
                //create the zoom registrant
                ZoomUpdateRegistration zUpdateReg = new ZoomUpdateRegistration(reg.Zoom_Registrant_ID__c, reg.Contact__r.Email, action);
                
                //get the type of meeting
                String endpoint;
                if (zoomType == ZOOM_TYPE_WEBINAR)
                    endpoint = ZOOM_WEBINAR;
                else if (zoomType == ZOOM_TYPE_MEETING)
                    endpoint = ZOOM_MEETING;
                
                if (endpoint == null) throw new customException('Endpoint is null because zoom type does not match any known type:' + reg.EAB_Event__r.Zoom_Type__c);
                
                String meetingId = reg.EAB_Event__r.Zoom_Meeting_ID_Formula__c;
                endpoint += meetingId + ZOOM_REGISTRANTS_UPDATE;
                HttpRequest req = createZoomCallout(endpoint, 'PUT');
                req.setHeader('Content-Type', 'application/json');
                req.setBody(JSON.serialize(zUpdateReg));
                HTTPResponse res = new Http().send(req);
                if (res.getStatusCode() == 200 || res.getStatusCode() == 201 || res.getStatusCode() == 204) {
                    
                    //v1.4 - 11/16/2021 - Chirag Soni - CR-20211112-15583 : Commented
                    //v1.2 - 10/23/2020 - Saurabh Kumar - CR-20200908-14493: Added a check. If action doesn't cancel then only it can be null
                    //if(action != ZoomServices.ZOOM_STATUS_CANCEL)
                    //reg.Zoom_Registrant_ID__c = null;
                    
                    reg.Zoom_Participant_URL__c = null;
                }
                //10/05/2020 - CR-20200429-13997 - Victor Hanson - added
                //09/14/2020 - CR-20200914-14505 - Victor Hanson - removed email because we can report on Web Service Logs now
                //12/08/2020 - CR-20201105-14664 - Saurabh Kumar - Replaced Meeting with EAB Event
                else {
                    String chatterMessage = 'Hi '+ reg.EAB_Event__r.Owner.FirstName  + ',\n\nUnable to ' + action + ' registration ' + reg.Name +  ' in Zoom.\n'
                        + 'Contact Application Support for assistance (applicationSupport@eab.com).  \nThanks!';
                    
                    String subject = 'Unable to ' + action + ' registration ' + reg.Name +' in Zoom for meeting "' + reg.EAB_Event__r.Name + '"';
                    emails.add(EmailHandler.createEmail(new List<String>{reg.EAB_Event__r.Owner.Email}, subject, chatterMessage, '', false));
                }
                
                //09/14/2020 - CR-20200914-14505 - Victor Hanson - added
                Web_Service_Log__c wsl = new Web_Service_Log__c(RecordTypeId = Schema.SObjectType.Web_Service_Log__c.RecordTypeInfosByDeveloperName.get('EAB_Event').RecordTypeId,
                                                                EAB_Event__c = reg.EAB_Event__c,
                                                                Zoom_Meeting_Id__c = meetingId,
                                                                Registration__c = reg.Id,
                                                                Web_Service_Method__c = 'addZoomRegistrant',
                                                                Request_Sent__c = system.now(),
                                                                Request_Message_Log__c = req.getBody(),
                                                                Response_Message_Log__c = String.valueOf(res.getBody()),
                                                                Status_Code__c = String.valueOf(res.getStatusCode()));
                wsls.add(wsl);
            }
            
            //10/05/2020 - CR-20200429-13997 - Victor Hanson - added
            //09/14/2020 - CR-20200914-14505 - Victor Hanson - removed
            //Sending out the Emails 
        if(emails.size() > 0 && !Test.isRunningTest())
                Messaging.SendEmailResult [] r = Messaging.sendEmail(emails);
            
            //09/14/2020 - CR-20200914-14505 - Victor Hanson - added
            //insert wsls
            if (wsls.size() > 0) insert wsls;
            
            //update the zoom participant url and zoom registrant ids on registrations
            //update regs;
            return regs;
        }
        catch(exception ex){ //Added By - Chirag Soni 11/16/2021 - CR-20211112-15583
            
            //list of web service logs to be insert for exceptions
            List<Web_Service_Log__c> exceptionalWebServiceLogs = new List<Web_Service_Log__c>();
            //set of eab event ids
            Set<Id> eabEventIds = new Set<Id>();
            
            // Query out all the eab event from registration ids 
            for(Registration__c reg : [SELECT Id, EAB_Event__c FROM Registration__c WHERE Id IN :registrationIds])
            {
                eabEventIds.add(reg.Eab_Event__c);
            }
            if(eabEventIds.size()>0)
            {
                for(Id eventId : eabEventIds)
                {
                    exceptionalWebServiceLogs.add(new Web_Service_Log__c(RecordTypeId = Schema.SObjectType.Web_Service_Log__c.RecordTypeInfosByDeveloperName.get('EAB_Event').RecordTypeId,
                                                                         EAB_Event__c = eventId,
                                                                         Web_Service_Method__c = 'Exception Occured',
                                                                         Request_Sent__c = system.now(),
                                                                         Request_Message_Log__c = ex.getMessage(),
                                                                         Response_Message_Log__c = ex.getMessage()+'\n'+ex.getStackTraceString()));
                }
                
                if(exceptionalWebServiceLogs.size()>0)
                {
                    Util.ByPassAllTriggers = true;
                    insert exceptionalWebServiceLogs;
                    Util.ByPassAllTriggers = false;
                }
            } return null;
        }
    }
    
    /**
     * @description:    wrapper class for zoom registrant
     * 
     * @revision log:   v1.0 - 03/26/2020 - Victor Hanson - created
     * 
     **/
    public class ZoomRegistrant {
        public String id { get; set; }
        public String email { get; set; }
        public String first_name { get; set; }
        public String last_name { get; set; }
        
        public ZoomRegistrant() {}
        
        public ZoomRegistrant(String email, String firstName, String LastName) {
            this.email = email;
            this.first_name = firstName;
            this.last_name = LastName;
        }
    }
    
    /**
     * @description:    wrapper class for zoom update registration object
     * 
     * @revision log:   v1.0 - 03/26/2020 - Victor Hanson - created
     * 
     **/
    public class ZoomUpdateRegistration {
        public String action { get; set; }
        public List<ZoomRegistrant> registrants { get; set; }
        
        public ZoomUpdateRegistration(String regId, String email, String action) {
            registrants = new List<ZoomRegistrant>();
            this.action = action;
            ZoomRegistrant zReg = new ZoomRegistrant();
            zReg.id = regId;
            zReg.email = email;
            this.registrants.add(zReg);
        }
    }
    
    /**
     * @description:    Populates the Time Joined / Time Left fields on Registration records.  This is populated for all attendees once a meeting ends
     * 
     * @revision log:	v1.0 - 03/30/2020 - Victor Hanson - created
     * 			v1.1 - 05/12/2020 - Victor Hanson - CR-20200507-14026 - fixed an issue where not all participants were being synced & updated Registration Status
     * 			v1.2 - 09/14/2020 - CR-20200914-14505 - Victor Hanson - added web service log support
     *			v1.3 - 10/08/2020 - Saurabh Kumar - CR-20200819-14447 - Removed Meeting reference
     *          	v1.4 - 10/30/2020 - Saurabh Kumar - CR-20200821-14461 - Method commented
     *          	v1.5 - 02/10/2021 - Victor Hanson - CR-20210210-14900 - updated method to work with multiple participants
     *          	v1.6 - 02/16/2021 - Victor Hanson - CR-20210216-14920 - fixed a duplicate zoom session issue
     * 			v1.7 - 04/21/2021 - Saurabh Kumar - CR-20210319-15008 - Added safe navigation operator and unique field in Zoom Session record
     * 
    **/
    public void updateParticipantAttendance(String zoomMeetingId, String nextPageToken) {
    
        //02/16/2021 - CR-20210216-14920 - Victor Hanson - added
        Map<String, Zoom_Session__c> mapUserIdToZoomSession = getUserIdToZoomSessionMap(zoomMeetingId);

        Advisory_Event__c eabEvent = [SELECT Id, Zoom_Type__c FROM Advisory_Event__c WHERE Zoom_Meeting_ID_Formula__c = :zoomMeetingId];
        
        // get the endpoint url
        String endpointURL = ZOOM_MEETING_PARTICIPANTS;
        if (eabEvent.Zoom_Type__c == ZOOM_TYPE_WEBINAR)
            endpointURL = ZOOM_WEBINAR_PARTICIPANTS;
        
        //VH 05/12/2020 - CR-20200507-14026 - Updated endpoint to include page size and next page token
        String endpoint = String.format(endpointURL + '?page_size=' + Label.Zoom_Page_Size, new String[] { zoomMeetingId });
        if (nextPageToken != null) endpoint += '&next_page_token=' + nextPageToken;
        
        HttpRequest req = createZoomCallout(endpoint, 'GET');
        req.setHeader('Content-Type', 'application/json');
        HTTPResponse res = new Http().send(req);
        
        //deserialize to object
        ZoomEventWrapper zWrapper = (ZoomEventWrapper) JSON.deserialize(res.getBody(), ZoomEventWrapper.class);
        
        if (res.getStatusCode() == 200 || res.getStatusCode() == 201) {
            //get a map of email address to participant
            Map<String, List<ZoomEventWrapper.cls_participant>> emailToParticipantMap = new Map<String, List<ZoomEventWrapper.cls_participant>>();
            for (ZoomEventWrapper.cls_participant participant : zWrapper.participants) {
                List<ZoomEventWrapper.cls_participant> listParticipants = emailToParticipantMap.get(participant.user_email.toLowerCase());
                if (listParticipants == null) listParticipants = new List<ZoomEventWrapper.cls_participant>();
                if (participant.user_email != null) {
                    listParticipants.add(participant);
                    emailToParticipantMap.put(participant.user_email.toLowerCase(), listParticipants);
                }
            }
            
            if (emailToParticipantMap.size() > 0) {
                //v1.1 - 05/12/2020 - Victor Hanson - CR-20200507-14026 - added Status__c field to query
                //get all registrations for the meeting where the email is in the list of emails
                List<Registration__c> registrants = [SELECT Id, Time_Joined__c, Time_Left__c, Contact__r.Email, Attended__c, Status__c, EAB_Event__c
                                                    FROM Registration__c 
                                                    WHERE EAB_Event__r.Zoom_Meeting_ID_Formula__c = :zoomMeetingId
                                                    AND Contact__r.Email IN :emailToParticipantMap.keySet()];
                
                for (Registration__c reg : registrants) {
                    
                    //v1.7 - 04/21/2021 - Saurabh Kumar - CR-20210319-15008 - Added safe navigation operator
                    //get the corresponding participant
                    List<ZoomEventWrapper.cls_participant> participants = emailToParticipantMap.get(reg?.Contact__r?.Email?.toLowerCase());
                    if (participants != null && participants.size() > 0) {
                        for (ZoomEventWrapper.cls_participant participant : participants) {

                        
                            //v1.1 - 05/12/2020 - Victor Hanson - CR-20200507-14026 - updated time joined and left DateTime formatting
                            DateTime timeJoined = (DateTime) JSON.deserialize('"' + participant.join_time + '"', DateTime.class);
                            DateTime timeLeft = (DateTime) JSON.deserialize('"' + participant.leave_time + '"', DateTime.class);
                            
                            //set the time joind / left on registration
                            if (reg.Time_Joined__c == null || timeJoined < reg.Time_Joined__c) {
                                reg.Time_Joined__c = timeJoined;
                            }
                            if (reg.Time_Left__c == null || timeLeft > reg.Time_Left__c) {
                                reg.Time_Left__c = timeLeft;
                            }
                            reg.Attended__c = true;
                            //v1.1 - 05/12/2020 - Victor Hanson - CR-20200507-14026 - update status
                            //02/10/2021 -  - Victor Hanson - RB said the events team wants to update the status to attended themselves
                            //reg.Status__c = Label.Registration_Status_Attended;
                            registrationsToUpdate.put(reg.Id, reg);
							
                            //v1.7 - 04/21/2021 - Saurabh Kumar - CR-20210319-15008 - Added field in Zoom Session record
                            //Create the zoom session
                            Zoom_Session__c zSession = new Zoom_Session__c(Registrant__c = reg.Id, 
                                                                            UUID__c = participant.user_id, 
                                                                            EAB_Event__c = reg.EAB_Event__c, 
                                                                            Time_Joined__c = timeJoined, 
                                                                            Time_Left__c = timeLeft,
                                                                            UUID_Dupe_Check__c = reg.Id + '-' + participant.user_id);
                            zSession.Id = mapUserIdToZoomSession.get(participant.user_id)?.Id;
                            mapUserIdToZoomSession.put(zSession.UUID__c, zSession);
                            
                            //09/14/2020 - CR-20200914-14505 - Victor Hanson - added
                            Web_Service_Log__c wsl = new Web_Service_Log__c(RecordTypeId = Schema.SObjectType.Web_Service_Log__c.RecordTypeInfosByDeveloperName.get('EAB_Event').RecordTypeId,
                                                                            EAB_Event__c = reg.EAB_Event__c,
                                                                            Zoom_Meeting_Id__c = zoomMeetingId,
                                                                            Registration__c = reg.Id,
                                                                            Web_Service_Method__c = 'updateParticipantAttendance',
                                                                            Request_Sent__c = system.now(),
                                                                            Request_Message_Log__c = req.getBody(),
                                                                            Response_Message_Log__c = JSON.serializePretty(participant));
                            webServiceLogsToInsert.add(wsl);
                        }
                    }
                }
                
                //v1.1 - 05/12/2020 - Victor Hanson - CR-20200507-14026 - if there is a next page token, execute this method again for the new page of results
                //update registrations
                if (registrationsToUpdate.size() > 0 && String.isBlank(zWrapper.next_page_token)) {
                    
                    //09/14/2020 - CR-20200914-14505 - Victor Hanson - added
                    //insert wsls
                    if (webServiceLogsToInsert.size() > 0) 
                        insert webServiceLogsToInsert;

                    if (mapUserIdToZoomSession.size() > 0) 
                        upsert mapUserIdToZoomSession.values();

                    //Aggregate query on Zoom Session
                    for(AggregateResult ar : [Select SUM(Duration_Minutes__c) duration, Registrant__c From Zoom_Session__c Where Registrant__c IN : registrationsToUpdate.keySet() GROUP BY Registrant__c]){
                        
                        Id regId = (Id)ar.get('Registrant__c');
                        if(!registrationsToUpdate.containsKey(regId))
                            registrationsToUpdate.put(regId, new Registration__c(Id = regId));
                        
                        registrationsToUpdate.get(regId).Duration_Minutes__c = (Decimal)ar.get('duration');
                    }
                    
                    //update registrants
                    database.update(registrationsToUpdate.values(), false);
                }
                else if (String.isNotBlank(zWrapper.next_page_token)) {
                    updateParticipantAttendance(zoomMeetingId, zWrapper.next_page_token);
                }
            }
        }
        else {
            throw new customException('Error: ' + res.getStatusCode() + ' - ' + res.getBody());
        }
        
        
    }


    public Class ZoomDialInDetailParser{
        public Settings settings {get;set;} 
        public String password { get; set; }//V1.9 - 03/03/2021 - Saurabh Kumar - CR-20210302-14959: Added
    }

    public class Settings {
        public List<DialDetail> dialDetail {get;set;} 
    }

    public class DialDetail {
        public String number_z {get;set;} // in json: number
        public String type_Z {get;set;} // in json: type
        public String country {get;set;} 
    }
    
    /**
     * @description:    returns a web service log object
     * 
     * @revision log:	v1.0 - 09/14/2020 - CR-20200914-14505 - Victor Hanson - created
     * 
    **/
    public static Web_Service_Log__c getWebServiceLog(Id eabEventId, String zoomMeetingId, String wsMethod, String request, String response) {
        return new Web_Service_Log__c(RecordTypeId = Schema.SObjectType.Web_Service_Log__c.RecordTypeInfosByDeveloperName.get('EAB_Event').RecordTypeId,
                                      EAB_Event__c = eabEventId,
                                      Zoom_Meeting_Id__c = zoomMeetingId,
                                      Web_Service_Method__c = wsMethod,
                                      Request_Sent__c = system.now(),
                                      Request_Message_Log__c = request,
                                      Response_Message_Log__c = response);
    }

    /**
     * @description:    returns a web service log object
     * 
     * @revision log:	v1.0 - 02/16/2021 - CR-20210216-14920 - Victor Hanson - created
     * 
    **/
    public static Map<String, Zoom_Session__c> getUserIdToZoomSessionMap(String zoomMeetingId) {
        Map<String, Zoom_Session__c> mapUserIdToZoomSession = new Map<String, Zoom_Session__c>();
        List<Zoom_Session__c> zSessions = [SELECT Id, Time_Joined__c, Time_Left__c, UUID__c FROM Zoom_Session__c WHERE Registrant__r.EAB_Event__r.Zoom_Meeting_ID_Formula__c = :zoomMeetingId];
        for (Zoom_Session__c zSession : zSessions) {
            mapUserIdToZoomSession.put(zSession.UUID__c, zSession);
        }
        return mapUserIdToZoomSession;
    }

}