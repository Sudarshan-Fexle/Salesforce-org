/**
 * Description		:	This class used to used to scheduled Queueable_UpdateParticipantAttendance job.
 * 
 * Created Date		:	04/14/2021
 * 
 * Test class           :       This Class Getting code coverage from Test_ZoomWebHooks - 91% 
 * 
 * Revision Log		:	V1.0 - Created - Saurabh Kumar - 04/13/2021 - CR-20210319-15008
 *                              V1.1 - 07/15/2021 - CR-20210709-15278 - Modified By - Chirag Soni - Added new method updateParticipantAttendance, 
 *                                                                                                  moved all the logic from Queueable_UpdateParticipantAttendance class to this method and commented reference 
 *                                                                                                  to Queueable_UpdateParticipantAttendance and added Scheduler_UpdateParticipantAttendance call
 *                                            
 * 
 * */
public class Scheduler_UpdateParticipantAttendance implements Schedulable{
	
    String zoomMeetingId;
    String nextPageToken;
    
    public Scheduler_UpdateParticipantAttendance(String zoomMeetingId, String nextPageToken){
        
        this.zoomMeetingId = zoomMeetingId;
        this.nextPageToken = nextPageToken;
    }
    
     public void execute(SchedulableContext context) {
        
        //07/15/2021 - CR-20210709-15278 - Modified By - Chirag Soni - commented
        //System.enqueueJob(new Queueable_UpdateParticipantAttendance(zoomMeetingId, nextPageToken));
        
        //07/15/2021 - CR-20210709-15278 - Modified By - Chirag Soni - added this call
        updateParticipantAttendance(zoomMeetingId, nextPageToken);
    }
    
    
/**
*  @description    : This class used to used to update Participant Attendance for Registration under eab event.
* 		     Logic: a). Queueable should hold all of the logic that's currently in ZoomServices.updateParticipantAttendance(String zoomMeetingId, String nextPageToken) method
*			        If zWrapper.next_page_token is not blank, re-execute the queueable, passing in the ZoomMeetingId & next_page_token
*			    b). Note: queueable is needed here, because we can have hundreds or thousands of participants in a meeting, and 400+ has caused apex cpu time limit exceptions.
*
*  @arg            : String zoomMeetingId, String nextPageToken
* 
*  @return         : Void
* 
*  @revision       : V1.0 - Created - Chirag Soni - 07/15/2021 - CR-20210709-15278 - moved all from executable method of Queueable_UpdateParticipantAttendance class to this method 
*                                                                and commented reference to Queueable_UpdateParticipantAttendance and added Scheduler_UpdateParticipantAttendance call 
* 					
* */
    
    @future(callout=true)
    public static void updateParticipantAttendance(String zoomMeetingId, String nextPageToken)
    {
        Map<String, Zoom_Session__c> mapUserIdToZoomSession = ZoomServices.getUserIdToZoomSessionMap(zoomMeetingId);
        
        //map of registrations to update
        Map<Id, Registration__c> registrationsToUpdate = new Map<Id, Registration__c>();
        
        //Map to hold Web_Service_Log__c data for insertion
        List<Web_Service_Log__c> webServiceLogsToInsert = new List<Web_Service_Log__c>();
        
         //07/15/2021 - CR-20210709-15278 - Modified By - Chirag Soni - updated to list of advisory event.
        List<Advisory_Event__c> eabEvents = [SELECT Id, Zoom_Type__c FROM Advisory_Event__c WHERE Zoom_Meeting_ID_Formula__c = :zoomMeetingId];
        
        // get the endpoint url
        String endpointURL = ZoomServices.ZOOM_MEETING_PARTICIPANTS;
        if (eabEvents.Size()>0 && eabEvents[0].Zoom_Type__c == ZoomServices.ZOOM_TYPE_WEBINAR)
            endpointURL = ZoomServices.ZOOM_WEBINAR_PARTICIPANTS;
        
        String endpoint = String.format(endpointURL + '?page_size=' + Label.Zoom_Page_Size, new String[] { zoomMeetingId });
        if (nextPageToken != null) endpoint += '&next_page_token=' + nextPageToken;
        
        HttpRequest req = ZoomServices.createZoomCallout(endpoint, 'GET');
        req.setHeader('Content-Type', 'application/json');
        HTTPResponse res = new Http().send(req);
        
        //deserialize to object
        ZoomEventWrapper zWrapper = (ZoomEventWrapper) JSON.deserialize(res.getBody(), ZoomEventWrapper.class);
        
         if (res.getStatusCode() == 200 || res.getStatusCode() == 201) 
         {
            //get a map of email address to participant
            Map<String, List<ZoomEventWrapper.cls_participant>> emailToParticipantMap = new Map<String, List<ZoomEventWrapper.cls_participant>>();
            for (ZoomEventWrapper.cls_participant participant : zWrapper.participants) 
            {
                List<ZoomEventWrapper.cls_participant> listParticipants = emailToParticipantMap.get(participant.user_email.toLowerCase());
                if (listParticipants == null) listParticipants = new List<ZoomEventWrapper.cls_participant>();
                if (participant.user_email != null) {
                    listParticipants.add(participant);
                    emailToParticipantMap.put(participant.user_email.toLowerCase(), listParticipants);
                }
            }
           
            if (emailToParticipantMap.size() > 0) 
            {
                
                //get all registrations for the meeting where the email is in the list of emails
                List<Registration__c> registrants = [SELECT Id, Time_Joined__c, Time_Left__c, Contact__r.Email, Attended__c, Status__c, EAB_Event__c
                                                    FROM Registration__c 
                                                    WHERE EAB_Event__r.Zoom_Meeting_ID_Formula__c = :zoomMeetingId
                                                    AND Contact__r.Email IN :emailToParticipantMap.keySet()];
                
                for (Registration__c reg : registrants) 
                {
                    
                    //get the corresponding participant
                    List<ZoomEventWrapper.cls_participant> participants = emailToParticipantMap.get(reg?.Contact__r?.Email?.toLowerCase());
                    if (participants != null && participants.size() > 0) 
                    { 
                        for (ZoomEventWrapper.cls_participant participant : participants) 
                        {

                            DateTime timeJoined = (DateTime) JSON.deserialize('"' + participant.join_time + '"', DateTime.class);
                            DateTime timeLeft = (DateTime) JSON.deserialize('"' + participant.leave_time + '"', DateTime.class);
                            
                            //set the time joind / left on registration
                            if (reg.Time_Joined__c == null || timeJoined < reg.Time_Joined__c) 
                            {
                                reg.Time_Joined__c = timeJoined;
                            }
                            if (reg.Time_Left__c == null || timeLeft > reg.Time_Left__c) 
                            {
                                reg.Time_Left__c = timeLeft;
                            }
                            reg.Attended__c = true;
                            
                            registrationsToUpdate.put(reg.Id, reg);

                            //Create the zoom session
                            Zoom_Session__c zSession = new Zoom_Session__c(Registrant__c = reg.Id, 
                                                                            UUID__c = participant.user_id, 
                                                                            EAB_Event__c = reg.EAB_Event__c, 
                                                                            Time_Joined__c = timeJoined, 
                                                                            Time_Left__c = timeLeft,
                                                                            UUID_Dupe_Check__c = reg.Id + '-' + participant.user_id);
                            zSession.Id = mapUserIdToZoomSession.get(participant.user_id)?.Id;
                            mapUserIdToZoomSession.put(zSession.UUID__c, zSession);
                            
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
                 
                //update registrations
                if (registrationsToUpdate.size() > 0) 
                {
                    
                    //insert wsls
                    if (webServiceLogsToInsert.size() > 0) 
                        insert webServiceLogsToInsert;
                         
                    if (mapUserIdToZoomSession.size() > 0) 
                        upsert mapUserIdToZoomSession.values();

                    //Aggregate query on Zoom Session
                    for(AggregateResult ar : [Select SUM(Duration_Minutes__c) duration, Registrant__c From Zoom_Session__c Where Registrant__c IN : registrationsToUpdate.keySet() GROUP BY Registrant__c])
                    {
                        
                        Id regId = (Id)ar.get('Registrant__c');
                        if(!registrationsToUpdate.containsKey(regId))
                            registrationsToUpdate.put(regId, new Registration__c(Id = regId));
                        
                        registrationsToUpdate.get(regId).Duration_Minutes__c = (Decimal)ar.get('duration');
                    }
                    
                    //update registrants
                    database.update(registrationsToUpdate.values(), false);
                }
                if (String.isNotBlank(zWrapper.next_page_token)) 
                { 
                    //07/15/2021 - CR-20210709-15278 - Modified By - Chirag Soni - commented
                    //  System.enqueueJob(new Queueable_UpdateParticipantAttendance(zoomMeetingId, zWrapper.next_page_token));
                    
                    //07/15/2021 - CR-20210709-15278 - Modified By - Chirag Soni - added this call
                    DateTime sysTime = dateTime.now().addMinutes(2);
                    String cronExpr = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
                    
                    //String to hold Apex Job Name
                    String apexJobName = 'Scheduler_UpdateParticipantAttendance' + ' ' + dateTime.now()+' '+math.random();
                    
                    Scheduler_UpdateParticipantAttendance schedule = new Scheduler_UpdateParticipantAttendance(zoomMeetingId, zWrapper.next_page_token);
                    System.schedule(apexJobName , cronExpr , schedule);
                    
                }
            }
        }
        else {
            throw new customException('Error: ' + res.getStatusCode() + ' - ' + res.getBody());
        }
    }
}