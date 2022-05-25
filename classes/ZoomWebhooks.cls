/**
 * Description 	    :	Handles zoom webhook events
 * 
 *  Revision Logs   :   V1.0 - 03/27/2020 - Victor Hanson - Created
 *                      V1.1 - 05/12/2020 - CR-20200507-14026 - Victor Hanson - Updated Time_Started__c & Time_Ended__c deserialization to work across any timezone
 *                      V1.2 - 10/08/2020 - CR-20200819-14447 - Saurabh Kumar - Replaced Meeting with EAB Events in following methods
 *                                                              meetingUpdates()
 *                      V1.3 - 10/26/2020 - CR-20200821-14461 - Saurabh Kumar - meetingUpdates() method updated to create/update Zoom Session record.
 *                      V1.4 - 10/29/2020 - CR-20200821-14461 - Saurabh Kumar - Added new constants, updated processWebhook(), updateParticipantAttendance() methods & created participantJoinedOrLeft() method.
 * 			V1.5 - 11/17/2020 - CR-20200821-14461 - Saurabh Kumar - Updated meetingUpdates() method. Replaced Begins__c with Time_Started__c & Ends__c with Time_Ended__c
 * 			V1.6 - 04/14/2021 - CR-20210319-15008 - Saurabh Kumar - Updated meetingUpdates() method to execute updateParticipantAttendance() method via Scheduler.
 * 
 **/
@RestResource(urlMapping='/zoomWebhookService')
global without sharing class ZoomWebhooks {
    
    public static final String ZOOM_MEETING_STARTED = 'meeting.started';
    public static final String ZOOM_MEETING_ENDED = 'meeting.ended';
    public static final String ZOOM_WEBINAR_STARTED = 'webinar.started';
    public static final String ZOOM_WEBINAR_ENDED = 'webinar.ended';
    
    
    /**
     * @description:     handles the httpPost webhooks from zoom
     * 
     * @revision log:    V1.0 - 03/26/2020 - Victor Hanson - created
     * 
     **/
    @HttpPost
    global static void doPost() {
        RestRequest req = RestContext.request;
        try {
            
            //deserialize the request and process based on event type
            processWebhook((ZoomEventWrapper) JSON.deserialize(req.requestBody.toString().replace('"object"', '"cls_object"'), ZoomEventWrapper.class));
        }
        catch(exception e) {
            //TODO: add error handling
        }
    }
    
    /**
     * @description:    send the webhook to the appropriate method for processing
     * 
     * @revision log:   V1.0 - 03/26/2020 - Victor Hanson - created
     * 			v1.1 - 09/14/2020 - CR-20200914-14505 - Victor Hanson - added try/catch with web service log support
     *			v1.2 - 10/30/2020 - Saurabh Kumar - CR-20200821-14461 - Added else if part
     *			v1.3 - 04/14/2021 - Saurabh Kumar - CR-20210319-15008 - Updated to create Web Service Log even no exception occurs
     * 
     **/
    public static void processWebhook(ZoomEventWrapper zWrapper) {
        
        //v1.3 - 04/14/2021 - Saurabh Kumar - CR-20210319-15008: Added
        String exceptionMessage;
        String stackTraceString;
        
        try {
            if (zWrapper.event.equalsIgnoreCase(ZOOM_MEETING_STARTED) || zWrapper.event.equalsIgnoreCase(ZOOM_MEETING_ENDED) || zWrapper.event.equalsIgnoreCase(ZOOM_WEBINAR_STARTED) || zWrapper.event.equalsIgnoreCase(ZOOM_WEBINAR_ENDED))
                meetingUpdates(zWrapper.event, zWrapper.payload.cls_object);
        }
        catch(Exception ex) {
            
            //v1.3 - 04/14/2021 - Saurabh Kumar - CR-20210319-15008: Added
            exceptionMessage = ex.getMessage();
            stackTraceString = ex.getStackTraceString();
        }
        
        //v1.3 - 04/14/2021 - Saurabh Kumar - CR-20210319-15008: Below code pulled out from catch block.
        //create a web service log for any errors
        List<Advisory_Event__c> eabEvents = [SELECT Id FROM Advisory_Event__c WHERE Zoom_Meeting_Id__c = :zWrapper.payload.cls_object.id];
        if (eabEvents.size() > 0) {
            Web_Service_Log__c wsl = new Web_Service_Log__c(RecordTypeId = Schema.SObjectType.Web_Service_Log__c.RecordTypeInfosByDeveloperName.get('EAB_Event').RecordTypeId,
                                                            EAB_Event__c = eabEvents[0].Id,
                                                            Zoom_Meeting_Id__c = zWrapper.payload.cls_object.id,
                                                            Web_Service_Method__c = zWrapper.event,
                                                            Request_Sent__c = system.now(),
                                                            Request_Message_Log__c = JSON.serializePretty(zWrapper),
                                                            Response_Message_Log__c = exceptionMessage + '---' + stackTraceString,
                                                            Error_Message__c = exceptionMessage);
            insert wsl;
        }
    }
    
    /**
     * @description:    Updates the meeting Time Started / Time Ended fields with the actual time started/ended dateTimes from zoom
     * 
     * @revision log:   v1.0 - 03/26/2020 - Victor Hanson - created
     * 			V1.1 - 05/12/2020 - CR-20200507-14026 - Victor Hanson - Updated Time_Started__c & Time_Ended__c deserialization to work across any timezone
     * 			V1.2 - 09/14/2020 - CR-20200914-14505 - Victor Hanson - added web service log support
     *			V1.3 - 10/08/2020 - CR-20200819-14447 - Saurabh Kumar - Replaced Meeting with EAB Event
     *                  V1.4 - 10/30/2020 - CR-20200821-14461 - Saurabh Kumar - Commented zService.updateParticipantAttendance(zoomMeeting.id, null);
     * 			V1.5 - 11/17/2020 - CR-20200821-14461 - Saurabh Kumar - Replaced Begins__c with Time_Started__c & Ends__c with Time_Ended__c
     * 			V1.6 - 04/14/2021 - CR-20210319-15008 - Saurabh Kumar - Updated method to execute updateParticipantAttendance() method via Scheduler
     * 
     **/
    public static void meetingUpdates(String zoomEvent, ZoomEventWrapper.cls_object zoomMeeting) {
        
        //Get EAB Event
        List<Advisory_Event__c> eabEvents = [SELECT Id, Begins__c, Ends__c FROM Advisory_Event__c WHERE Zoom_Meeting_ID_Formula__c = :zoomMeeting.id];
        
        if (eabEvents.size() > 0) {
            for (Advisory_Event__c eabEvent : eabEvents) {
                //V1.1 - 05/12/2020 - CR-20200507-14026 - Victor Hanson - Updated Time_Started__c & Time_Ended__c deserialization to work across any timezone
                //V1.4 - 11/17/2020 - CR-20200821-14461 - Saurabh Kumar - Replaced Begins__c with Time_Started__c & Ends__c with Time_Ended__c
                if (!String.isBlank(zoomMeeting.start_time))
                    eabEvent.Time_Started__c = (DateTime) JSON.deserialize('"' + zoomMeeting.start_time + '"', DateTime.class);
                if (!String.isBlank(zoomMeeting.end_time)) {
                    //update the meeting Time Ended
                    eabEvent.Time_Ended__c = (DateTime) JSON.deserialize('"' + zoomMeeting.end_time + '"', DateTime.class);
                    
                    //V1.3 - 10/30/2020 - CR-20200821-14461 - Saurabh Kumar: Start
                    //V1.1 - 05/12/2020 - CR-20200507-14026 - Victor Hanson - skip this callout if unit test
                    //v1.6 - 04/23/2021 - CR-20210319-15008 - Saurabh Kumar - commented Test.isRunning check inorder execute in test class. 
                    //if (!Test.isRunningTest()) {
                        //update joined/left times on registrations
                        //ZoomServices zService = new ZoomServices();
                        
                        //V1.6 - 04/14/2021 - CR-20210319-15008 - Saurabh Kumar - Calling updateParticipantAttendance logic via scheduler instead direct calling in 2 minutes future.: Start
                        DateTime sysTime = dateTime.now().addMinutes(2);
                        String cronExpr = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
                        
                        //String to hold Apex Job Name
                        String apexJobName = 'Scheduler_UpdateParticipantAttendance' + ' ' + dateTime.now()+' '+math.random();
                        
                        Scheduler_UpdateParticipantAttendance schedule = new Scheduler_UpdateParticipantAttendance(zoomMeeting.id, null);
                        System.schedule(apexJobName , cronExpr , schedule);
                        //V1.1 - 05/12/2020 - CR-20200507-14026 - Victor Hanson - updated method params
                        //zService.updateParticipantAttendance(zoomMeeting.id, null);
                        //V1.6 - 04/14/2021 - CR-20210319-15008 - Saurabh Kumar - Calling updateParticipantAttendance logic via scheduler instead direct calling in 2 minutes future.: End
                    
                    //V1.3 - 10/30/2020 - CR-20200821-14461 - Saurabh Kumar: End
                }
            }
            update eabEvents;
        }
        else {
            throw new customException('Error: No Meeting found with Zoom Meeting Id: ' + zoomMeeting.id);
        }
        
        /*//get the meeting
        List<Meeting__c> meetings = [SELECT Id, Time_Started__c, Time_Ended__c, EAB_Event__c FROM Meeting__c WHERE EAB_Event__r.Zoom_Meeting_ID_Formula__c = :zoomMeeting.id];
        
        if (meetings.size() > 0) {
            //09/14/2020 - CR-20200914-14505 - added
            List<Web_Service_Log__c> wsls = new List<Web_Service_Log__c>();
            for (Meeting__c meeting : meetings) {
                //09/14/2020 - CR-20200914-14505 - create a web service log to track that this callout was received
                Web_Service_Log__c wsl = ZoomServices.getWebServiceLog(meeting.EAB_Event__c,
                                                                       zoomMeeting.id, 
                                                                       zoomEvent, 
                                                                       JSON.serializePretty(zoomMeeting),
                                                                       null);
                wsls.add(wsl);
                
                //V1.1 - 05/12/2020 - CR-20200507-14026 - Victor Hanson - Updated Time_Started__c & Time_Ended__c deserialization to work across any timezone
                if (!String.isBlank(zoomMeeting.start_time))
                    meeting.Time_Started__c = (DateTime) JSON.deserialize('"' + zoomMeeting.start_time + '"', DateTime.class);
                if (!String.isBlank(zoomMeeting.end_time)) {
                    //update the meeting Time Ended
                    meeting.Time_Ended__c = (DateTime) JSON.deserialize('"' + zoomMeeting.end_time + '"', DateTime.class);
                }
                
                //09/14/2020 - CR-20200914-14505 - added modified if statement
                if (!String.isBlank(zoomMeeting.end_time) || (zoomEvent != null && zoomEvent.equalsIgnoreCase(ZOOM_MEETING_ENDED))) {
                    //V1.1 - 05/12/2020 - CR-20200507-14026 - Victor Hanson - skip this callout if unit test
                    if (!Test.isRunningTest()) {
                        //update joined/left times on registrations
                        ZoomServices zService = new ZoomServices();
                        //V1.1 - 05/12/2020 - CR-20200507-14026 - Victor Hanson - updated method params
                        zService.updateParticipantAttendance(zoomMeeting.id, null);
                    }
                }
            }
            update meetings;
            //v1.2 - 09/14/2020 - insert web service logs
            if (wsls.size() > 0) insert wsls;
        }
        else {
            throw new customException('Error: No Meeting found with Zoom Meeting Id: ' + zoomMeeting.id);
        }*/
    }
    
}