/**
 *	Purpose			:	Site Profile Logging functionlity
 *
 *	Created By		:	Victor Hanson
 *
 *	Created Date		:	08/25/2014
 *
 *	Current Version		:	V1.0 - Created
 *                      		V1.1 - Modified - 06/21/2019 - Victor Hanson - excludeNulls from serialize method
 *                      		V1.2 - Modified - 07/01/2019 - Victor Hanson - added support for meetings
 *                      		V1.3 - Modified - 01/12/2021 - Victor Hanson - CR-20200821-14460 - link web service log to eab events
 **/
public class SiteProfileLogger {
	
    private static final integer MAX_REQUEST_RESPONSE_LOG_LENGTH = 32768;
    private static final integer MAX_RESPONSE_MESSAGE_LENGTH = 5000;
    
    //get the Web Service Log's Site Profile record type id
    public static Id wsLogSiteProfileRTId {
        get {
            if (wsLogSiteProfileRTId == null)
                wsLogSiteProfileRTId = Schema.SObjectType.Web_Service_Log__c.RecordTypeInfosByName.get('Site Profile').RecordTypeId;
            return wsLogSiteProfileRTId;
        }
        set;
    }
    
    //get the Web Service Log's Institution record type id
    public static Id wsLogInstitutionRTId {
        get {
            if (wsLogInstitutionRTId == null)
                wsLogInstitutionRTId = Schema.SObjectType.Web_Service_Log__c.RecordTypeInfosByName.get('Institution').RecordTypeId;
            return wsLogInstitutionRTId;
        }
        set;
    }
	
    //holds the original siteUser prior to processing
    public static SiteUser originalSiteUser {
        get {
            if (originalSiteUser == null) originalSiteUser = new SiteUser();
            return originalSiteUser;
        }
        set;
    }
    
    	/**
	 * 	@description		:	This method is to create a Log record for Site Profile requests
	 *
	 *	@param			:	SiteUser
	 *
	 *	@return			:	void
	 *
	 **/
	public static void Log(SiteUser sUser){
        Site_Profile__c sProfile = sUser.Site_Profile;
        if (sProfile == null) {
		    	
		    string userId = string.valueOf(sUser.User_Id);
		    if (userId == null && sUser.Attendee != null) userId = string.valueOf(sUser.Attendee.User_Id);
		    
		    if (userId != null) {
        		list<Site_Profile__c> siteProfiles = [SELECT Id, Type__c, Status__c, Username__c FROM Site_Profile__c WHERE User_Id__c = :userId LIMIT 1];
                if (siteProfiles.size() > 0) sProfile = siteProfiles[0];
		    }
        }
        
        if (sProfile != null) { 
            //Create a webservice log record
            Web_Service_Log__c webServiceLog = new Web_Service_Log__c(RecordTypeId = wsLogSiteProfileRTId,
                                                                      Site_Profile__c = sProfile.Id,
                                                                      Web_Service_Method__c = originalSiteUser.Command,
                                                                      Request_Sent__c = system.now(),
                                                                      Response_Message_Log__c = JSON.serializePretty(sUser, true),
                                                                      Response_Message__c = sUser.Response,
                                                                      Requested_By__c = sUser.Modified_By,
                                                                      Request_Message_Log__c = JSON.serializePretty(originalSiteUser, true));
            //trim field excess+3 and add elipse (...) to show that the log value had to be trimmed
            if (webServiceLog.Response_Message_Log__c != null && webServiceLog.Response_Message_Log__c.length() > MAX_REQUEST_RESPONSE_LOG_LENGTH) {
                webServiceLog.Response_Message_Log__c = webServiceLog.Response_Message_Log__c.subString(0, (MAX_REQUEST_RESPONSE_LOG_LENGTH-3)) + '...';
            }
            
            if (webServiceLog.Request_Message_Log__c != null && webServiceLog.Request_Message_Log__c.length() > MAX_REQUEST_RESPONSE_LOG_LENGTH) {
                webServiceLog.Request_Message_Log__c = webServiceLog.Request_Message_Log__c.subString(0, (MAX_REQUEST_RESPONSE_LOG_LENGTH-3)) + '...';
            }
            
            if (webServiceLog.Response_Message__c != null && webServiceLog.Response_Message__c.length() > MAX_RESPONSE_MESSAGE_LENGTH) {
                webServiceLog.Response_Message__c = webServiceLog.Response_Message__c.subString(0, (MAX_RESPONSE_MESSAGE_LENGTH-3)) + '...';
            }
            
            //insert log
            insert webServiceLog;
        }
	}
    
    	/**
	 * 	@description		:	This method is to create a Log record for Site Profile requests
	 *
	 *	@param			:	SiteUser
	 *
	 *	@return			:	void
	 *
	 **/
    public static void Log(string institutionId, string institutionJSON, string command, string result, string response){
        
        //Create a webservice log record
        Web_Service_Log__c webServiceLog = new Web_Service_Log__c(RecordTypeId = wsLogInstitutionRTId,
                                                                  Institution__c = institutionId,
                                                                  Web_Service_Method__c = command,
                                                                  Request_Sent__c = system.now(),
                                                                  Response_Message_Log__c = response,
                                                                  Response_Message__c = result,
                                                                  Request_Message_Log__c = JSON.serializePretty(JSON.deserializeUntyped(institutionJSON)));
        
        //insert log
        insert webServiceLog;
    }

    	/**
	 * 	@description		:	This method is to create a Log record for Site Meeting requests
	 *
	 *	@param			:	SiteMeeting
	 *
	 *	@return			:	void
	 *
	 **/
	public static void Log(SiteMeeting originalSMeeting, SiteMeeting sMeeting){
        
        if (sMeeting.mWrapper != null) { 

            //01/12/2021 - Victor Hanson - CR-20200821-14460 - link web service log to eab events
            Advisory_Event__c eabEvent;
            Tag__c tag;
            if (originalSMeeting.mWrapper.MeetingGUID != null) {
                List<Advisory_Event__c> eabEvents = [SELECT Id FROM Advisory_Event__c WHERE Meeting_GUID__c = :originalSMeeting.mWrapper.MeetingGUID];
                if (eabEvents.size() > 0) {
                    eabEvent = eabEvents[0];
                }
                //  02/04/2021 - Victor Hanson - Added for debugging purposes - Start
                else if (originalSMeeting.mWrapper.MeetingGUID instanceOf Id) {
                    //check if this is a Tag
                    List<Tag__c> tags = [SELECT Id FROM Tag__c WHERE Id = :originalSMeeting.mWrapper.MeetingGUID];
                    if (tags.size() > 0) 
                        tag = tags[0];
                }
                //  02/04/2021 - Victor Hanson - Added for debugging purposes - End
            }

            //Create a webservice log record
            Web_Service_Log__c webServiceLog = new Web_Service_Log__c(RecordTypeId = wsLogSiteProfileRTId,
                                                                      Site_Profile__c = sMeeting.mWrapper.siteProfileId,
                                                                      Web_Service_Method__c = originalSMeeting.mWrapper.Command,
                                                                      Request_Sent__c = system.now(),
                                                                      Response_Message_Log__c = JSON.serializePretty(sMeeting, true),
                                                                      Response_Message__c = sMeeting.mWrapper.Response,
                                                                      Request_Message_Log__c = JSON.serializePretty(originalSMeeting.DecryptedString, true));
            //01/12/2021 - Victor Hanson - CR-20200821-14460 - link web service log to eab events
            if (eabEvent != null)
                webServiceLog.EAB_Event__c = eabEvent?.Id;

            //  02/04/2021 - Victor Hanson - Added for debugging purposes - Start
            if (tag != null)
                webServiceLog.Tag__c = tag.Id;
            //  02/04/2021 - Victor Hanson - Added for debugging purposes - End
            
            if (eabEvent != null && webServiceLog.Site_Profile__c == null)
                webServiceLog.RecordTypeId = Schema.SObjectType.Web_Service_Log__c.RecordTypeInfosByDeveloperName.get('EAB_Event').RecordTypeId;

            //trim field excess+3 and add elipse (...) to show that the log value had to be trimmed
            if (webServiceLog.Response_Message_Log__c != null && webServiceLog.Response_Message_Log__c.length() > MAX_REQUEST_RESPONSE_LOG_LENGTH) {
                webServiceLog.Response_Message_Log__c = webServiceLog.Response_Message_Log__c.subString(0, (MAX_REQUEST_RESPONSE_LOG_LENGTH-3)) + '...';
            }
            
            if (webServiceLog.Request_Message_Log__c != null && webServiceLog.Request_Message_Log__c.length() > MAX_REQUEST_RESPONSE_LOG_LENGTH) {
                webServiceLog.Request_Message_Log__c = webServiceLog.Request_Message_Log__c.subString(0, (MAX_REQUEST_RESPONSE_LOG_LENGTH-3)) + '...';
            }
            
            if (webServiceLog.Response_Message__c != null && webServiceLog.Response_Message__c.length() > MAX_RESPONSE_MESSAGE_LENGTH) {
                webServiceLog.Response_Message__c = webServiceLog.Response_Message__c.subString(0, (MAX_RESPONSE_MESSAGE_LENGTH-3)) + '...';
            }
            
            //insert log
            insert webServiceLog;
        }
	}

    	/**
	 * 	@description		:	This method is to create a Log record for Site Meeting requests
	 *
	 *	@param			:	SiteMeeting
	 *
	 *	@return			:	void
	 *
	 **/
	public static void Log(SiteMeeting originalSMeeting, SiteMeeting sMeeting, SiteUser sUser){
        
	        if (sUser.site_Profile != null && sUser.site_Profile.Id != null) { 

                String response = sMeeting.mWrapper.Response;
                if (String.isBlank(response)) {
                    response = sUser?.Response;
                }

	            //Create a webservice log record
	            Web_Service_Log__c webServiceLog = new Web_Service_Log__c(RecordTypeId = wsLogSiteProfileRTId,
	                                                                      Site_Profile__c = sUser.site_Profile.Id,
	                                                                      Web_Service_Method__c = originalSMeeting.mWrapper.Command,
	                                                                      Request_Sent__c = system.now(),
	                                                                      Response_Message_Log__c = JSON.serializePretty(sMeeting, true),
	                                                                      Response_Message__c = response,
	                                                                      Request_Message_Log__c = originalSMeeting.DecryptedString);
	            //trim field excess+3 and add elipse (...) to show that the log value had to be trimmed
	            if (webServiceLog.Response_Message_Log__c != null && webServiceLog.Response_Message_Log__c.length() > MAX_REQUEST_RESPONSE_LOG_LENGTH) {
	                webServiceLog.Response_Message_Log__c = webServiceLog.Response_Message_Log__c.subString(0, (MAX_REQUEST_RESPONSE_LOG_LENGTH-3)) + '...';
	            }
            
	            if (webServiceLog.Request_Message_Log__c != null && webServiceLog.Request_Message_Log__c.length() > MAX_REQUEST_RESPONSE_LOG_LENGTH) {
	                webServiceLog.Request_Message_Log__c = webServiceLog.Request_Message_Log__c.subString(0, (MAX_REQUEST_RESPONSE_LOG_LENGTH-3)) + '...';
	            }
            
	            if (webServiceLog.Response_Message__c != null && webServiceLog.Response_Message__c.length() > MAX_RESPONSE_MESSAGE_LENGTH) {
	                webServiceLog.Response_Message__c = webServiceLog.Response_Message__c.subString(0, (MAX_RESPONSE_MESSAGE_LENGTH-3)) + '...';
	            }
            
	            //insert log
	            insert webServiceLog;
	        }
	}
}