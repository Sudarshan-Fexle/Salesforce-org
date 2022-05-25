public class G2MClient {
    public static final String BaseUrl = 'https://www4.gotomeeting.com/axis/services/G2M_Organizers/';
    public static final Long Version = 2;
    
    public static final String xsiNameSpace = 'http://www.w3.org/2001/XMLSchema-instance';
    public static final String xsiPrefix = 'xsi';
    public static final String xsdNameSpace = 'http://www.w3.org/2001/XMLSchema';
    public static final String xsdPrefix = 'xsd';
    public static final String soapenvNameSpace = 'http://schemas.xmlsoap.org/soap/envelope/';
    public static final String soapenvPrefix = 'soapenv';
    public static final String encodingNameSpace = 'http://schemas.xmlsoap.org/soap/encoding/';
    public static final String encodingPrefix = 'encodingStyle';
    public static final String g2mNameSpace = 'G2M_Organizers';
    public static final String g2mPrefix = 'g2m';
    public static final String SOAPAction = 'SOAPAction';

    public static final String InTestModeUserId = 'G2MClient_User_InTestMode@g2m.com';
    public static final String InTestModeUserId2 = 'G2MClient_User2_InTestMode@g2m.com';
    public static final String InFaultModeUserId = 'G2MClient_User_InFaultMode@g2m.com';

    private static final String XML_Logon = '<?xml version="1.0" encoding="UTF-8"?>' +
'<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">' +
'<soapenv:Body>' +
'<ns1:logonResponse soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:ns1="G2M_Organizers" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">' +
'<logonReturn xsi:type="xsd:string" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">token</logonReturn>' +
'</ns1:logonResponse>' +
'</soapenv:Body>'+
'</soapenv:Envelope>';

    private static final String XML_Logoff = '<?xml version="1.0" encoding="UTF-8"?>' +
'<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">' +
'<soapenv:Body />' +
'</soapenv:Envelope>';

    private static final String XML_CreateMeeting = '<?xml version="1.0" encoding="UTF-8"?>' +
'<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">' +
'<soapenv:Body>' +
'<ns1:createMeetingResponse soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:ns1="G2M_Organizers">' +
'<createMeetingReturn href="#id0"/>' +
'</ns1:createMeetingResponse>' +
'<multiRef id="id0" soapenc:root="0" soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xsi:type="ns2:MeetingInfo" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/" xmlns:ns2="G2M_Organizers">' +
'<meetingFields soapenc:arrayType="ns2:Field[4]" xsi:type="soapenc:Array">' +
'<meetingFields href="#id1"/>' +
'<meetingFields href="#id2"/>' +
'<meetingFields href="#id3"/>' +
'<meetingFields href="#id4"/>' +
'</meetingFields>' +
'<meetingId href="#id5"/>' +
'</multiRef>' +
'<multiRef id="id5" soapenc:root="0" soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xsi:type="xsd:long" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/">meetingid</multiRef>' +
'<multiRef id="id3" soapenc:root="0" soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xsi:type="ns3:Field" xmlns:ns3="G2M_Organizers" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/">' +
'<name xsi:type="xsd:string">uniqueMeetingId</name>' +
'<value xsi:type="xsd:string">unique id</value>' +
'</multiRef>' +
'<multiRef id="id1" soapenc:root="0" soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xsi:type="ns4:Field" xmlns:ns4="G2M_Organizers" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/">' +
'<name xsi:type="xsd:string">joinURL</name>' +
'<value xsi:type="xsd:string">meeting url</value>' +
'</multiRef>' +
'<multiRef id="id4" soapenc:root="0" soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xsi:type="ns5:Field" xmlns:ns5="G2M_Organizers" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/">' +
'<name xsi:type="xsd:string">conferenceCallInfo</name>' +
'<value xsi:type="xsd:string">calling number</value>' +
'</multiRef>' +
'<multiRef id="id2" soapenc:root="0" soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xsi:type="ns6:Field" xmlns:ns6="G2M_Organizers" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/">' +
'<name xsi:type="xsd:string">maxParticipants</name>' +
'<value xsi:type="xsd:string">26</value>' +
'</multiRef>' +
'</soapenv:Body>' +
'</soapenv:Envelope>';

    private static final String XML_DeleteMeeting = '<?xml version="1.0" encoding="UTF-8"?>' +
'<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">' +
'<soapenv:Body>' +
'<ns1:deleteMeetingResponse soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:ns1="G2M_Organizers"/>' +
'</soapenv:Body>' +
'</soapenv:Envelope>';

    private static final String XML_UpdateMeeting = '<?xml version="1.0" encoding="UTF-8"?>' +
'<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">' +
'<soapenv:Body>' +
'<ns1:updateMeetingResponse soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:ns1="G2M_Organizers"/>' +
'</soapenv:Body>' +
'</soapenv:Envelope>';

    public static final String XML_FaultResponse = '<?xml version="1.0" encoding="utf-8"?>' +
'<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">' +
'<soapenv:Body>' +
'<soapenv:Fault>' +
'<faultcode xmlns:ns1="G2M_Organizers">ns1:InvalidLogin</faultcode>' +
'<faultstring>error</faultstring>' +
'<detail>' +
'<ns2:hostname xmlns:ns2="http://xml.apache.org/axis/">g2mbr1.sjc.expertcity.com</ns2:hostname>' +
'</detail>' +
'</soapenv:Fault>' +
'</soapenv:Body>' +
'</soapenv:Envelope>';

    public String UserName { get; private set; }
    public String Password { get; private set; }
    public String Token { get; private set; }
    private Boolean InTestMode { get; set; }
    private Boolean InFaultMode { get; set; }

    public class G2MClientException extends Exception {
    }

    public G2MClient(String userName, String password) {
        this.UserName = userName;
        this.Password = password;
        this.Token = '';
        InTestMode = (userName == InTestModeUserId) || (userName == InTestModeUserId2) || (userName == InFaultModeUserId);
        InFaultMode = (userName == InFaultModeUserId);
    }
    public G2MClient(String userName, String password, String token) {
        this.UserName = userName;
        this.Password = password;
        this.Token = token;
        InTestMode = (userName == InTestModeUserId) || (userName == InTestModeUserId2) || (userName == InFaultModeUserId);
        InFaultMode = (userName == InFaultModeUserId);
    }

    public Boolean logon() {
        String actionName = 'logon';

        if(Token != '')
            return true;
            
        try
        {
            Dom.Document document = new Dom.Document();
            Dom.XMLNode body = CreateSOAPBody(document);
            Dom.XMLNode action = body.addChildElement(g2mPrefix + ':' + actionName, null, null);
            action.setAttribute(soapenvPrefix + ':' + encodingPrefix, encodingNameSpace);
            AppendTextNode(action, 'id', 'string', UserName);
            AppendTextNode(action, 'password', 'string', Password);
            AppendTextNode(action, 'version', 'long', String.valueOf(Version));
    
            HttpRequest request = CreateRequest(document, actionName);
            //return request.getBody();
    
            document = GetResponse(request);
            //return document.toXmlString();
    
            Token = document
                .getRootElement()
                .getChildElement('Body', soapenvNamespace)
                .getChildElement(actionName + 'Response', g2mNameSpace)
                .getChildElement(actionName + 'Return', null)
                .getText();
    
            if(Token != '') {
                return true;
            }
            else {
                return false;            
            }
        }
        catch(G2MClientException ex) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new String[] {G2MEventControllerExt.ErrorEmail});
                mail.setSubject('[ABC Salesforce]: logon');
                mail.setPlainTextBody('Exception: ' + ex);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                        
            return false;
        }
    }

    public void logoff() {
        String actionName = 'logoff'; 
        
        if(Token == '') return;
        
        try {
            Dom.Document document = new Dom.Document();
            Dom.XMLNode body = CreateSOAPBody(document);
            Dom.XMLNode action = body.addChildElement(g2mPrefix + ':' + actionName, null, null);
            action.setAttribute(soapenvPrefix + ':' + encodingPrefix, encodingNameSpace);
            AppendTextNode(action, 'connectionId', 'string', Token);

            HttpRequest request = CreateRequest(document, actionName);
            //return request.getBody();

            document = GetResponse(request);
            // return document.toXmlString();
        }
        catch(Exception ex) {
        }
        
        Token = '';
    }

    public String createMeeting(Event event) {                  
        String actionName = 'createMeeting';
        
        HttpRequest request = CreateRequest(createCreateMeetingRequest(event, actionName), actionName);
        //return request.getBody();

        Dom.Document document = GetResponse(request);
        //return document.toXmlString();

        Dom.XMLNode[] nodes = document
            .getRootElement()
            .getChildElement('Body', soapenvNamespace)
            .getChildElements();

        String meetingIdNodeId;
        for(Dom.XMLNode node : nodes) {
            Dom.XMLNode meetingIdNode = node.getChildElement('meetingId', null);
            if(meetingIdNode != null) {
                meetingIdNodeId = meetingIdNode.getAttributeValue('href', null).replace('#', '');
                break;
            }
        }

        for(Dom.XMLNode node : nodes) {
            String idValue = node.getAttributeValue('id', null);
            if(idValue == meetingIdNodeId) {
                //event.Gotomeeting_Id__c = node.getText();
            }
            else if(node.getChildElement('name', null) != null && node.getChildElement('name', null).getText() == 'joinURL') {
                //event.Gotomeeting_Url__c = node.getChildElement('value', null).getText();
            }
            else if(node.getChildElement('name', null) != null && node.getChildElement('name', null).getText() == 'conferenceCallInfo') {
                //event.Gotomeeting_Dialing__c = node.getChildElement('value', null).getText();
            }
        }
        //event.Gotomeeting_Organizer_Saved_Id__c = event.Gotomeeting_Organizer_Id__c;
        //event.Gotomeeting_Hash__c = G2MEventControllerExt.GetEventHash(event);
        //return event.Gotomeeting_Id__c;
        return null;
    }
    public Dom.Document createCreateMeetingRequest(Event event, String actionName) {
        Dom.Document document = new Dom.Document();
        Dom.XMLNode body = CreateSOAPBody(document);
        Dom.XMLNode action = body.addChildElement(g2mPrefix + ':' + actionName, null, null);
        action.setAttribute(soapenvPrefix + ':' + encodingPrefix, encodingNameSpace);
        AppendTextNode(action, 'connectionId', 'string', Token);
        Dom.XMLNode meetingParametersNode = AppendTextNode(action, 'meetingParameters', 'g2m:MeetingParameters', null);
        //AppendTextNode(meetingParametersNode, 'subject', 'string', event.Gotomeeting_Meeting_Name__c);
        AppendTextNode(meetingParametersNode, 'startTime', 'dateTime', event.StartDateTime.formatGmt('yyyy-MM-dd\'T\'kk:mm:ss\'Z\''));
        AppendTextNode(meetingParametersNode, 'endTime', 'dateTime', event.EndDateTime.formatGmt('yyyy-MM-dd\'T\'kk:mm:ss\'Z\''));
        //AppendTextNode(meetingParametersNode, 'timeZoneKey', 'string', '61');
        AppendTextNode(meetingParametersNode, 'conferenceCallInfo', 'string', 'Free');
        AppendTextNode(meetingParametersNode, 'meetingType', 'string', 'Scheduled');
        AppendTextNode(meetingParametersNode, 'passwordRequired', 'boolean', 'false');

        return document;
    }

    public String updateMeeting(Event event) {
        String actionName = 'updateMeeting';

        HttpRequest request = CreateRequest(createUpdateMeetingRequest(event, actionName), actionName);
        //return request.getBody();

        Dom.Document document = GetResponse(request);
        // return document.toXmlString();

        //event.Gotomeeting_Hash__c = G2MEventControllerExt.GetEventHash(event);
        return null;
    }
    public Dom.Document createUpdateMeetingRequest(Event event, String actionName) {
        Dom.Document document = new Dom.Document();
        Dom.XMLNode body = CreateSOAPBody(document);
        Dom.XMLNode action = body.addChildElement(g2mPrefix + ':' + actionName, null, null);
        action.setAttribute(soapenvPrefix + ':' + encodingPrefix, encodingNameSpace);
        AppendTextNode(action, 'connectionId', 'string', Token);
        //AppendTextNode(action, 'meetingId', 'long', event.Gotomeeting_Id__c);
        Dom.XMLNode meetingParametersNode = AppendTextNode(action, 'meetingParameters', 'g2m:MeetingParameters', null);
        //AppendTextNode(meetingParametersNode, 'subject', 'string', event.Gotomeeting_Meeting_Name__c);
        AppendTextNode(meetingParametersNode, 'startTime', 'dateTime', event.StartDateTime.formatGmt('yyyy-MM-dd\'T\'kk:mm:ss\'Z\''));
        AppendTextNode(meetingParametersNode, 'endTime', 'dateTime', event.EndDateTime.formatGmt('yyyy-MM-dd\'T\'kk:mm:ss\'Z\''));
        AppendTextNode(meetingParametersNode, 'conferenceCallInfo', 'string', 'Free');
        //AppendTextNode(meetingParametersNode, 'meetingType', 'string', 'Scheduled');
        //AppendTextNode(meetingParametersNode, 'passwordRequired', 'boolean', 'false');
        //AppendTextNode(meetingParametersNode, 'timeZoneKey', 'string', '61');

        return document;
    }

    public String deleteMeeting(Event event) {
        //String retVal = deleteMeeting(event.Gotomeeting_Id__c);
        
        //event.Gotomeeting_Id__c = null;
        //event.Gotomeeting_Url__c = null;
        //event.Gotomeeting_Dialing__c = null;
        //event.Gotomeeting_Hash__c = null;
        //event.Gotomeeting_Organizer_Saved_Id__c = null;
                            
        return null;
    }
    public String deleteMeeting(String g2mId) {
        String actionName = 'deleteMeeting';

        HttpRequest request = CreateRequest(createDeleteMeetingRequest(actionName, g2mId), actionName);
        //return request.getBody();

        Dom.Document document = GetResponse(request);
        //return response.getBody();
        
        return null;
    }
    public Dom.Document createDeleteMeetingRequest(String actionName, String g2mId) {
        Dom.Document document = new Dom.Document();
        Dom.XMLNode body = CreateSOAPBody(document);
        Dom.XMLNode action = body.addChildElement(g2mPrefix + ':' + actionName, null, null);
        action.setAttribute(soapenvPrefix + ':' + encodingPrefix, encodingNameSpace);
        AppendTextNode(action, 'connectionId', 'string', Token);
        AppendTextNode(action, 'meetingId', 'long', g2mId);

        return document;
    }

    public virtual Dom.Document GetResponse(HttpRequest request) {
        if(InTestMode) {
            Dom.Document document = new Dom.Document();
            if(InFaultMode) {
                document.load(XML_FaultResponse);

                String fault = GetFault(document);
                if(fault != null && fault != '' ) {
                    throw new G2MClientException(fault);
                }
            }
            else {
                String action = request.getHeader(SOAPAction);
                if(action == 'logon')
                    document.load(XML_Logon);
                else if(action == 'logoff')
                    document.load(XML_Logoff);
                else if(action == 'createMeeting')
                    document.load(XML_CreateMeeting);
                else if (action == 'deleteMeeting')
                    document.load(XML_DeleteMeeting);
                else if(action == 'updateMeeting')
                    document.load(XML_UpdateMeeting);
            }

            return document;
        }
        else {
            HttpResponse response = new Http().send(request);
            if (response.getStatusCode() != 200) {
                Integer start = System.Now().millisecond();
                while(System.Now().millisecond()< start+10){ }
                
                response = new Http().send(request);
                if (response.getStatusCode() != 200) {
                    String action = request.getHeader(SOAPAction);
                    throw new G2MClientException(action + ': ' + response.toString());
                }
            }
            Dom.Document docResponse = response.getBodyDocument();

            String fault = GetFault(docResponse);
            if(fault != null && fault != '' ) {
                throw new G2MClientException(fault);
            }

            return docResponse;
        }
    }

    private static String GetFault(Dom.Document document) {
        Dom.XMLNode node = document
            .getRootElement()
            .getChildElement('Body', soapenvNamespace)
            .getChildElement('Fault', soapenvNamespace);

        if(node == null) return null;

        return node.getChildElement('faultstring', null).getText();
    }
    private static HttpRequest CreateRequest(Dom.Document doc, String action) {
        HttpRequest request = new HttpRequest();
        request.setEndPoint(BaseUrl);
        request.setMethod('POST');
        request.setBody(doc.toXmlString());
        request.setHeader('Content-Type', 'application/soap+xml; charset=UTF-8');
        request.setHeader(SOAPAction, action);

        System.debug('request=' + request.getBody());
        return request;
    }

    private static Dom.XMLNode CreateSOAPBody(Dom.Document docRequest) {
        Dom.XMLNode envelope = docRequest.createRootElement('Envelope', soapenvNamespace, soapenvPrefix);
        envelope.setAttribute('xmlns:' + xsdPrefix, xsdNamespace);
        envelope.setAttribute('xmlns:' + xsiPrefix, xsiNamespace);
        envelope.setAttribute('xmlns:' + g2mPrefix, g2mNamespace);
        envelope.addChildElement('Header', soapenvNamespace, soapenvPrefix);

        return envelope.addChildElement('Body', soapenvNamespace, soapenvPrefix);
    }

    private static Dom.XMLNode AppendTextNode(Dom.XMLNode parent, String name, String typeName, String value) {
        Dom.XMLNode node = parent.addChildElement(name, null, null);
        if(typeName.contains(':'))
            node.setAttribute('xsi:type', typeName);
        else
            node.setAttribute('xsi:type', 'xsd:' + typeName);
        if(value != null)
            node.addTextNode(value);

        return node;
    }
    
    public static void SendEmail(Id eventId, Id organizerId, String templateName) {
        EmailTemplate et = [SELECT Id FROM EmailTemplate WHERE developerName =: templateName];
            
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTargetObjectId(organizerId);
        mail.setTemplateId(et.Id);
        mail.setWhatId(eventId);
        mail.setSaveAsActivity(false);
        mail.setBccSender(false);
        mail.setUseSignature(false);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});    
    }
    public static void SendEventExceptionEmail(Event event, Exception ex, String to, String subject) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] {to});
        mail.setSubject('[ABC Salesforce]: ' + subject);
        Org_Setting__c os = Org_Setting__c.getOrgDefaults();
        if(os != null) 
        {
            mail.setHtmlBody('<p>We could not create / update / delete Gotomeeting associate for the following event: <a href="' + os.Org_Host_URL__c + '/' + event.Id + '">' + event.Subject + '</a>.</p>'
                             + '<p>Error: ' + ex + '</p>'
                             + '<p>You can click on "Synch Gotomeeting" button on the event detail page to retry the failed action later.</p>'
                             + '<p>Thanks.</p>');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });        
        }
    }
    public static void SendDeleteG2MExceptionEmail(String g2mId, Exception ex, String to) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] {to});
        mail.setSubject('[ABC Salesforce]: Failed to delete Gotomeeting');
        mail.setHtmlBody('<p>We could not delete Gotomeeting (Id: ' + g2mId + ') when the associated event is deleted.</p>'
            + '<p>Error: ' + ex + '</p>'
            + '<p>Please delete it from Gotomeeting client yourself.</p>'
            + '<p>Thanks.</p>');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
    }
}