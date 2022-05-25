/**
    Desription      :   Helper class for the Registration object

    Revision Logs   :   V1.0 - 03/25/2020 - Created - CR-20200324-13884 - Victor Hanson
                    :   V1.1 - 04/20/2020 - CR-20200424-13983 - Dipesh Gupta - Added one new method - sendCalendarInvites
                        V1.2 - 06/12/2020 - CR-20200612-14180 - Victor Hanson - updated callWebServiceToSendCommunicationtTemplate
                        V1.3 - 07/16/2020 - CR-20200707-14273 - Victor Hanson - updated createWebServiceBody to include timezone info
                        V1.4 - 08/04/2020 - CR-20200804-14400 - Victor Hanson - updated getLongDate to fix an issue with null timezone
                        V1.5 - 08/04/2020 - CR-20200803-14398 - Victor Hanson - added references to meetingUpdated
                        V1.6 - 09/25/2020 - CR-20200923-14547 - Abhinav Sharma - Add logic to RegistrationHelper to pull contact email for calendar invites when company_email__c is null.
                        V1.7 - 09/30/2020 - CR-20200929-14565 - Saurabh Kumar - Added checks to resolve null pointer exception in checkRegistrations method
                        V1.8 - 09/28/2020 - CR-20200821-14453 - Saurabh Kumar - Created populatePartnerStatus, updatePartnerStatus & createMembershipMtMRecords methods.
                        V1.9 - 10/05/2020 - CR-20200821-14460 - Saurabh Kumar - Created populateRegistrationField method.
                        V2.0 - 10/08/2020 - CR-20200819-14447 - Saurabh Kumar - Updated following methods to replace reference from Meeting to EAB Event
                                                                                updateRegistrationCount()
                                                                                checkRegistrations()
                                                                                callWebServiceToSendCommunicationtTemplate()
                                                                                createWebServiceBody()
                                                                                sendCalendarInvites()
                        V2.1 - 10/23/2020 - CR-20200908-14493 - Saurabh Kumar - checkRegistrations() method updated.
                        V2.2 - 10/26/2020 - CR-20200821-14454 - Saurabh Kumar - Added new methods createRegistrationsForChildEABEvents(), validateRegistrations() & updateRelatedRegistrationStatus()
                        V2.3 - 10/27/2020 - CR-20200821-14465 - Saurabh Kumar - Added new methods populateStatusAndApprovalReason(), populateCampaignMemberRegistrationField()
                        V2.4 - 11/11/2020 - CR-20200820-14451 - Saurabh Kumar - Update Method updateCorrectRecordType()
                        V2.5 - 11/13/2020 - CR-20201106-14675 - Saurabh Kumar - Replaced Origin__c's picklist values from Microsite with EAB.com & Manual with Salesforce.
                        V2.6 - 11/19/2020 - CR-20200821-14465 - Saurabh Kumar - Updated populateRegistrationField() method.
			V2.7 - 01/05/2021 - CR-20200819-14449 - Saurabh Kumar - Added a new method populateExpectedAttendeeOnEABEvent().
			V2.8 - 01/28/2021 - CR-20200821-14454 - Saurabh Kumar - Added a new method populateInstitutionRegistrationCount().
			V2.9 - 01/29/2021 - CR-20200821-14465 - Saurabh Kumar - Added a new method populateIsOnInviteList().
			V3.0 - 02/01/2021 - CR-20200821-14459 - Saurabh Kumar - Added a method syncMeetingUtilization().
			V3.1 - 02/04/2021 - Saurabh Kumar - Updated sendCalendarInvites(), checkRegistrations(), populateRegistrationField() methods to avoid unwanted query.

			V3.2 - 02/18/2021 - CR-20210217-14921 - Saurabh Kumar - Updated createRegistrationsForChildEABEvents() method to avoid registration creation for closed event.
									      - Updated populateStatusAndApprovalReason() to assign default value Registered in case of Manual Registration
			V3.3 - 02/17/2021 - CR-20210211-14905 - Victor Hanson
			V3.4 - 03/03/2021 - CR-20210303-14965 - Victor Hanson 
			V3.5 - 03/03/2021 - CR-20210303-14964 - Victor Hanson
			V3.6 - 03/10/2021 - CR-20210308-14971 - Victor Hanson
			V3.7 - 03/11/2021 - CR-20210311-14986 - Victor Hanson - added approval status & declined reason to prevent validation rule from firing during update
			V3.8 - Modified By - Saurabh Kumar - 04/08/2021 - CR-20210324-15021
			V3.9 - Modified By - Neha Sharma - 04/19/2021 - CR-20210324-15023 - check public name is not blank 
			V4.0 - 03/02/2021 - CR-20210114-14812 - Saurabh Kumar
			V4.1 - Modified By - Saurabh Kumar - 02/16/2021 - CR-20210208-14884: Logic updated to avoid Membership Status from filter.
			V4.2 - 04/15/2021 - CR-20210312-14994 - Saurabh Kumar - Updated syncMeetingUtilization() method to bypass creating Meeting Utilization for Onsite & Conference eab event record types.
			V4.3 - 03/26/2021 - CR-20201116-14696 - Saurabh Kumar - Added a method createAndPopulateCampaignMemberStatus(). 
			V4.4 - 03/30/2021 - CR-20201116-14696 - Saurabh Kumar - Added a method postChatterOnStatusMismatch().
			V4.5 - 03/03/2021 - CR-20210302-14959 - Saurabh Kumar - Updated callWebServiceToSendCommunicationtTemplate() method.
			V4.6 - 02/26/2021 - CR-20210224-14940 - Saurabh Kumar - Updated populatePartnerStatus() method.
                        V4.7 - Modified By - Saurabh Kumar - CR-20201116-14696 - 03/30/2021 
                        V4.8 - Modified By - Saurabh Kumar - 04/13/2021 - CR-20210128-14854: Populate Registration_Approved_Date__c field when registration status is registered.
                        V4.9 - Modified By - Saurabh Kumar - 04/19/2021 - CR-20210318-15005: Moved "Populate the Registration's Status Field Value" process builder logic to this method 
            		V5.0 - Modified By - Chirag Soni - 05/20/2021 - CR-20210312-14994 : UAT Issues (MRS2.0) - Updated syncMeetingUtilization() method to creating Meeting Utilization only for event record type.
            		V5.1 - Modified By - Chirag Soni - 05/20/2021 - CR-20201116-14696 : UAT Issues (MRS2.0) - Updated createAndPopulateCampaignMemberStatus() method.
            		V5.2 - Modified By - Chirag Soni - 05/20/2021 - CR-20210318-15005 : UAT Issues (MRS2.0) - Updated populateRegistrationField()method.
            		V5.3 - Modified By - Chirag Soni - 05/26/2021 - CR-20210318-15005 : UAT Issues (MRS2.0) - Updated populateRegistrationField()method.
            		V5.4 - Modified By - Chirag Soni - 06/04/2021 - CR-20201116-14696 : UAT Issues (MRS2.0) - Updated createAndPopulateCampaignMemberStatus()method.
			V5.5 - Modified By - Chirag Soni - 07/14/2021 - CR-20210709-15278 : modified checkRegistration() and syncContactAndRegistrationsWithAcquia() method commented enqueuing of EnqueueJob_ZoomServices class and scheduled the ScheduleJob_ZoomServices class
								                            commented the methods callCommunicationTemplateService, callWebServiceToSendCommunicationtTemplate, createWebServiceBody, parseDateTime, getLongDate and moved all the logic to Schedule_CommunicationTemplateService class.
                        V5.6 - Modified By - Chirag Soni - 07/28/2021 - CR-20210716-15294 : Updated sendCalendarInvites() - For Sending Elevated Meal Registration Records for the Calendar Invite When Elevated_Meal_RSVP__c Field is "Yes" or "Maybe"
                        V5.7 - Modified By - Chirag Soni - 06/29/2021 - CR-20210625-15241 : modified approval status = waitlist and approval status = declined check in populateRegistrationField() method
                        V5.8 - Modified By - Chirag Soni - 07/29/2021 - CR-20210526-15185 : Updated updateRelatedRegistrationStatus, updatePartnerStatus(),populateStatusAndApprovalReason() - Commented the Bypass Flags to update the status and Added the code to update Approval status on child registration When Parent Registration is udpated.
                        V5.9 - Modified By - Chirag Soni - 05/31/2021 - CR-20210408-15071 : Added new method cancelParentsEligibleRegistrations().
			V6.0 - Modified By - Chirag Soni - 06/22/2021 - CR-20210504-15118 : added a new method createMembershipMtMRecordsLogic() - moved all the logic from createMembershipMtMRecords method to createMembershipMtMRecordsLogic() except initial checks.
			V6.1 - Modified By - Chirag Soni - 08/23/2021 - CR-20210818-15364 : Updated Method checkRegistrations() - Added the check to send calendar Invite when Mirror Registration = 'Inherit all from parent' While creating EAB event
			V6.2 - Modified By - Chirag Soni - 09/08/2021 - CR-20210902-15405 : Updated Method createRegistrationsForChildEABEvents() - UAT issue fixes - Added the logic to handle bulk registrations
                        V6.3 - Modified By - Chirag Soni - 10/18/2021 - CR-20210628-15254 : Added the logic to send calendar invite when event format is "In-Person"
			V6.4 - Modified By - Chirag Soni - CR-20211108-15570 - 11/08/2021 - Remove Check - !System.isFuture() &&
			V6.5 - Modified By - Chirag Soni - 10/28/2021 - CR-20210614-15213
			V6.6 - Modified By - Chirag Soni - 11/01/2021 - CR-20211008-15504 - Updated Method checkRegistrations() - Added a check for VOID status in the zoom cancelled registration part\
			V6.7 - Modified By - Chirag Soni - 08/12/2021 - CR-20210511-15137 - Added the RecordTypeId field in the query
			V6.8 - Modified By - Chirag Soni - 07/08/2021 - CR-20210511-15133 : added a new method populateTravelCompensationFields() - used to populate Travel Compensation Fields.
			V6.9 - Modified By - Chirag Soni - 12/06/2021 - CR-20211112-15583 - Updated method checkRegistrations -  QA/UAT Issue #114 - Comment out the cancel call out to zoom
			V7.0 - Modified By - Chirag Soni - 01/04/2022 - CR-20211224-15650 - Added parentReg not null check in if condition.
			V7.1 - Modified By - Chirag Soni - 1/13/2022 -  CR-20220113-15705 - Updated method sendCalendarInvites - added contains check in else if condition.
			V7.2 - Modified By - Chirag Soni - 12/15/2021 - CR-20211214-15632 - Added util.bypass check in  updateRelatedRegistrationStatus method and calling updateRelatedRegistrationStatus method directly from manageregistrationField
			V7.3 - Modified By - Lawrence Lam - CR-20210606-15193
			V7.4 - Modified By - Chirag Soni - CR-20210606-15193
			V7.5 - Modified By - Chirag Soni - CR-20211215-15634 - Update Method - manageRegistrationFields()
			V7.6 - Modified By - Chirag Soni - 02/09/2022 - CR-20220208-15772 - Updated methoed syncContactAndRegistrationsWithAcquia(), Added scheduled Batch_AcquiaSync and commented enqueuing of AcquiaHttpCallout
			V7.7 - Modified By - Chirag Soni - CR-20220307-15987 - added oldMap Registration
            V7.8 - Modified By - Chirag Soni - CR-20220429-16152 - Updated method createAndPopulateCampaignMemberStatus() - Refactor the code in order to improve CPU time limit SOQL limit exception.
**/ 
public without sharing class RegistrationHelper {
	
    public static final String STATUS_REGISTERED = 'Registered';
    public static final String STATUS_CANCELLED = 'Cancelled';
    public static final String STATUS_VOID = 'VOID';
    public static final String CAMPAIGN_MEMBER_STATUS_WAITLISTED = 'Waitlisted';//Modified By - Chirag Soni - 05/20/2021 - CR-20201116-14696
    public static final String REGISTRATION_STATUS_NO_SHOW = 'No Show';
    public static final String REGISTRATION_STATUS_PARTIAL_ATTEND = 'Partial Attend';
    public static final String REGISTRATION_STATUS_ATTENDED = 'Attended';
    public static final String REGISTRATION_STATUS_DECLINED = 'Declined';
    public static final String REGISTRATION_STATUS_REGISTRATION_REQUESTED_TRANSLATED_VALUE = 'Reg. Req.';
    public static final String UTILIZATION_METRIC_MEETINGS = 'Meetings';
    public static final String USER_TYPE_GUEST = 'Guest';
    public static final String REGISTRATION_APPROVAL_REASON_NO_PARTNERSHIP = 'No Partnership';
    public static final Set<String> SET_OF_REGISTRATION_STATUS_COMPLETED = new Set<String> {'Closed - Completed','Closed - Cancelled'};
        
    //Added - Saurabh Kumar - CR-20201116-14696 - 03/30/2021   
    public static boolean isCreateAndPopulateCampaignMemberStatusExecute = true;        
    public static boolean isAlreadyChatterPostedForRegistrationAndCamapignMemberStatusMissMatch = false;
    public static final Set<String> SET_OF_ADDITIONAL_REGISTRATION_STATUS = new Set<String> {'Partial Attend','VOID','Waitlist'};
    
    //02/03/2021 - CR-20200821-14459 - Victor Hanson - bypass registration DLRS in some scenarios
    public static Boolean bypassRegistrationDLRS = false;
    public static Boolean bypasspopulateInstitutionRegistrationCount = false;
    //04/02/2021 - CR-20210128-14854 - Added by Saurabh Kumar.
    //Modified By - Lawrence Lam - CR-20210606-15193
    public static set<String> registrationIdsWhichAlreadyProceedToSyncWithAcquia = new Set<String>();
    //Added By - Chirag Soni - 07/08/2021 - CR-20210511-15133 - bypass approval if once submitted for a record  
    public static boolean isApprovalProcessSubmitted = false;
    
    //Added By - Chirag Soni - 12/15/2021 - CR-20211214-15632 - added boolean check to avoid recursive execution
    public static boolean isChildRegistrationUpdated = false;
    
    /**
     * Desription      :   Summarize the total number of Registrations where Status = Registered
     * 
     * Revision Logs   :   v1.0 - 03/25/2020 - Created - CR-20200324-13884 - Victor Hanson
     *                 :   v1.1 - 10/08/2020 - Updated by Saurabh Kumar - CR-20200819-14447 : Commented the code which is no more useful
    **/ 
    public static void updateRegistrationCount(List<Registration__c> registrations, Map<Id, Registration__c> oldRegistrationsMap) {
        
        /*
        //set of eab events where we need to update the registration count
        Set<Id> eabEventIds = new Set<Id>();
        Set<Id> meetingIds = new Set<Id>();
        
        List<Advisory_Event__c> eabEventsToUpdate = new List<Advisory_Event__c>();
        
        for (Registration__c reg : registrations) {
            //get the old registration so we can check for status change
            Registration__c oldReg;
            if (oldRegistrationsMap != null) oldReg = oldRegistrationsMap.get(reg.Id);
            
            //check status
            if (((oldReg == null && reg.Status__c == STATUS_REGISTERED) || 
                 (oldReg != null && reg.Status__c == STATUS_REGISTERED && oldReg.Status__c != STATUS_REGISTERED) || 
                 (oldReg != null && oldReg.Status__c == STATUS_REGISTERED && reg.Status__c != STATUS_REGISTERED))) 
            {
                meetingIds.add(reg.Meeting__c);
            }
        }
        
        //if meeting ids are present, get the related EAB Events so we can update the count
        if (meetingIds.size() > 0) {
            List<Meeting__c> meetings = [SELECT Id, EAB_Event__c FROM Meeting__c WHERE Id IN :meetingIds];
            
            //Modified by Mahendra Swarnkar - 04/02/2020 -CR-20200401-13900 - Start Here
            for (Meeting__c meeting : meetings) {
                if(String.isNotBlank(meeting.EAB_Event__c))
                    eabEventIds.add(meeting.EAB_Event__c);
            }
            
            if(eabEventIds.size() > 0){
                List<AggregateResult> groupedResults = [SELECT Meeting__r.EAB_Event__c eventId, COUNT(Id)regCount FROM Registration__c 
                                                        WHERE Meeting__r.EAB_Event__c IN :eabEventIds AND Status__c = :STATUS_REGISTERED GROUP BY Meeting__r.EAB_Event__c];
                
                for (AggregateResult gr : groupedResults) {
                    eabEventsToUpdate.add(new Advisory_Event__c(Id = (Id) gr.get('eventId'),
                                                                Current_Registration_Count__c = (Decimal) gr.get('regCount')));
                }
            }
            //Modified by Mahendra Swarnkar - 04/02/2020 -CR-20200401-13900 - End Here
            
            if (eabEventsToUpdate.size() > 0) update eabEventsToUpdate;
        }*/
    }
    
    
    /**
     * Desription      :   When Registration Status is created/updated and Status changes to Registered or Cancelled, submit callout to Zoom to update registrant
     * 
     * Revision Logs   :   v1.0 - 03/26/2020 - CR-20200324-13884 - Victor Hanson - Created
     *                     v1.1 - 08/13/2020 - CR-20200812-14420 - Victor Hanson - work with either related meeting OR EAB Event
     *                     v1.2 - 10/08/2020 - CR-20200819-14447 - Saurabh Kumar - Removed Meeting reference
     *                     v1.3 - 10/23/2020 - CR-20200908-14493 - Saurabh Kumar - Added a logic : If Registration.Zoom_Registrant_ID__c != Null and the Status is changing to 
     *                                                                             Registered, add the Registration Id to a new list (ie: registrationIdsToUpdateApprovedInZoom)
                                                                                   For records in this Set<Id>, they should be sent to the EnqueueJob_ZoomServices
     *                     v1.4 - 02/04/2021 - Saurabh Kumar - Added a check to avoid unwanted processing.
     *                     v1.5 - 07/14/2021 - CR-20210709-15278 - Chirag Soni - commented enqueuing of EnqueueJob_ZoomServices class and scheduled the ScheduleJob_ZoomServices class for execution after 15 second.
     *			   V1.6 - 11/01/2021 - CR-20211008-15504 - Chirag Soni - Added a check for VOID status in the zoom cancelled registration part
     *			   V1.7 - 11/16/2021 - CR-20211112-15583 - Chirag Soni - commented apporved callout and its associated variable 
     *		           V1.8 - 12/06/2021 - CR-20211112-15583 - Chirag Soni - QA/UAT Issue #114 - Comment out the cancel call out to zoom and its related variables 
    **/ 
    public static void checkRegistrations(List<Registration__c> registrations, Map<Id, Registration__c> oldRegistrationsMap) {
        
        //12/06/2021 - CR-20211112-15583 - Chirag Soni - QA/UAT Issue #114 - Comment out the cancel call out to zoom and its related variables 
        //set of registration Ids to send to zoom
        Set<Id> registrationIdsToSyncWithZoom = new Set<Id>();
        //Set<Id> registrationIdsToCancelInZoom = new Set<Id>();
        
        //11/16/2021 - CR-20211112-15583 - Chirag soni - Commented 
        //Set<Id> registrationIdsToUpdateApprovedInZoom = new Set<Id>();//v1.3 - 10/23/2020 - CR-20200908-14493 - Saurabh Kumar - Added
        
        //get registrations with related meeting info so we know whether or not to sync with Zoom
        //Set<Id> meetingIds = new Set<Id>();//Commented by Saurabh Kumar CR-20200819-14447 - 10/08/2020
        Set<Id> eabEventIds = new Set<Id>();
        for (Registration__c reg : registrations) {

            //v1.4 - 02/04/2021 - Saurabh Kumar - Added a check to avoid unwanted processing.
            if (reg.EAB_Event__c != null && (oldRegistrationsMap == null || oldRegistrationsMap.get(reg.Id).Status__c != reg.Status__c
                                             || oldRegistrationsMap.get(reg.Id).EAB_Event__c != reg.EAB_Event__c) )
                eabEventIds.add(reg.EAB_Event__c);
        }
        
        //CR-20200812-14420 - 08/13/2020 - Victor Hanson - get list of meetings & eab events depending on the relationship
        //Map<Id, Meeting__c> meetingMap = new Map<Id, Meeting__c>();//Commented by Saurabh Kumar CR-20200819-14447 - 10/08/2020
        Map<Id, Advisory_Event__c> eabEventMap = new Map<Id, Advisory_Event__c>();
        
        //if (meetingIds.size() > 0)////Commented by Saurabh Kumar CR-20200819-14447 - 10/08/2020
        //meetingMap = new Map<Id, Meeting__c>([SELECT Id, EAB_Event__r.Zoom_Meeting_ID__c, EAB_Event__r.Zoom_Type__c FROM Meeting__c WHERE Id IN :meetingIds]);
        if (eabEventIds.size() > 0)
            //Modified By - Chirag Soni - CR-20210818-15364 - 08/23/2021 -  Added the Mirror_Registration__c in the query
            eabEventMap = new Map<Id, Advisory_Event__c>([SELECT Id, Zoom_Meeting_ID__c, Zoom_Type__c, Mirror_Registrations__c FROM Advisory_Event__c WHERE Id IN :eabEventIds]);
       
        for (Registration__c reg : registrations) {
            Registration__c oldReg;
            if (oldRegistrationsMap != null) oldReg = oldRegistrationsMap.get(reg.Id);
            
            //CR-20200812-14420 - 08/13/2020 - Victor Hanson - break out zoom meeting id and zoom type 
            String zoomMeetingId;
            String zoomType;
            
            //get the related EAB Event or Meeting
            if (reg.EAB_Event__c != null && eabEventMap.containsKey(reg.EAB_Event__c)) {
                Advisory_Event__c eabEvent = eabEventMap.get(reg.EAB_Event__c);
                zoomMeetingId = eabEvent.Zoom_Meeting_ID__c;
                zoomType = eabEvent.Zoom_Type__c;
            }
            
            //if the status updated to Registered, add to list of registrations to cancel
            //Modified By - Chirag Soni - CR-20210818-15364 - 08/23/2021 - Added the check to send calendar Invite when Mirror Registration = 'Inherit all from parent' While creating EAB event
            if (zoomMeetingId != null && (zoomType != null || eabEventMap.get(reg.EAB_Event__c).Mirror_Registrations__c == Constants.EAB_EVENT_INHERI_REGISTRATION_INHERIT_ALL_FROM_PARENT)  && reg.Status__c == STATUS_REGISTERED 
                && ((oldReg == null ) || oldReg != null && oldReg.Status__c != reg.Status__c))
            {
                //12/21/2020 - CR-20200908-14493 - Victor Hanson - add id to different list depending on whether or not they have ever been registered before
                //11/16/2021 - CR-20211112-15583 - Chirag soni - Commented Zoom_Registrant_ID__c
                if (/*reg.Zoom_Registrant_ID__c == null &&*/ reg.RecordTypeId != Constants.REGISTRATION_RECORD_TYPE_ID_INTERNAL_ATTENDEE && String.isBlank(reg.Zoom_Participant_URL__c)) {
                    registrationIdsToSyncWithZoom.add(reg.Id);
                }
                 //11/16/2021 - CR-20211112-15583 - Chirag soni - Commented 
                /*else if (reg.Zoom_Registrant_ID__c != null) {
                    registrationIdsToUpdateApprovedInZoom.add(reg.Id);//v1.3 - 10/23/2020 - CR-20200908-14493 - Saurabh Kumar - Added
                }*/
            }
            
            //Added check (meeting != null && meeting.EAB_Event__c != null) by Saurabh Kumar - CR-20200929-14565 - 09/30/2020
            //if the registration is cancelled, add to list of registrations to cancel
            //Modified By - Chirag Soni - CR-20210818-15364 - 08/23/2021 - Added the check to send calendar Invite when Mirror Registration = 'Inherit all from parent' While creating EAB event
            //Modified BY - Chirag Soni - CR-20211008-15504 - 11/01/2021 - Added a check for VOID status
            //12/06/2021 - CR-20211112-15583 - Chirag Soni - QA/UAT Issue #114 - Comment out the cancel call out to zoom and its related variables 
            /*if (zoomMeetingId != null && (zoomType != null || eabEventMap.get(reg.EAB_Event__c).Mirror_Registrations__c == Constants.EAB_EVENT_INHERI_REGISTRATION_INHERIT_ALL_FROM_PARENT) 
                && oldReg != null && oldReg.Status__c == STATUS_REGISTERED && (reg.Status__c == STATUS_CANCELLED))
            {
                registrationIdsToCancelInZoom.add(reg.Id);
            }*/
        }
        
        //12/06/2021 - CR-20211112-15583 - Chirag Soni - QA/UAT Issue #114 - Comment out the cancel call out to zoom and its related variables 
        //v1.7 - 11/16/2021 - CR-20211112-15583 - Chirag soni - Commented registrationIdsToUpdateApprovedInZoom
        //v1.3 - 10/23/2020 - CR-20200908-14493 - Saurabh Kumar - Added registrationIdsToUpdateApprovedInZoom
        if (registrationIdsToSyncWithZoom.size() > 0 )/*|| registrationIdsToCancelInZoom.size() > 0) /*|| registrationIdsToUpdateApprovedInZoom.size() > 0) */{
            
            // -- 07/14/2021 - CR-20210709-15278 - Chirag Soni - commented enqueuing of job and schedule ScheduleJob_ZoomServices class -- start
            // System.enqueueJob(new EnqueueJob_ZoomServices(registrationIdsToSyncWithZoom, registrationIdsToCancelInZoom, registrationIdsToUpdateApprovedInZoom));
            
            //12/06/2021 - CR-20211112-15583 - Chirag Soni - QA/UAT Issue #114 - Comment out the cancel call out to zoom and its related variables 
            // map to strore the Registrations ids for all the scenerios
            map<integer, Set<Id>> mapOfRegistrationIdsToSync = new map<integer, Set<Id>>();
            //map<integer, Set<Id>> mapOfRegistrationIdsCancel = new map<integer, Set<Id>>();
            
            //v1.7 - 11/16/2021 - CR-20211112-15583 - Chirag soni - Commented mapOfRegistrationIdsToApprove
            //map<integer, Set<Id>> mapOfRegistrationIdsToApprove = new map<integer, Set<Id>>();
            
            //logic to process record in chunk of 100 records per map key -- start
            if(registrationIdsToSyncWithZoom.size() > 100)
            {
                integer count = 1;
                integer i = 1;
                for(Id regId  : registrationIdsToSyncWithZoom){
                    
                    if(count <= 100)
                    {
                        if(!mapOfRegistrationIdsToSync.containsKey(i))
                            mapOfRegistrationIdsToSync.put(i, new Set<Id>());
                        
                        mapOfRegistrationIdsToSync.get(i).add(regId);
                        count++;
                        
                    }
                    else{
                        count = 1;
                        i++;
                        if(!mapOfRegistrationIdsToSync.containsKey(i))
                            mapOfRegistrationIdsToSync.put(i, new Set<Id>());
                        
                        mapOfRegistrationIdsToSync.get(i).add(regId);
                    }
                }
            }
            else{
                mapOfRegistrationIdsToSync.put(1, registrationIdsToSyncWithZoom); 
            }
            
            //12/06/2021 - CR-20211112-15583 - Chirag Soni - QA/UAT Issue #114 - Comment out the cancel call out to zoom and its related variables 
            // for cancelled registrations
            /*if(registrationIdsToCancelInZoom.size() > 100)
            {
                integer count = 1;
                integer i = 1;
                for(Id regId  : registrationIdsToCancelInZoom){
                    
                    if(count <= 100)
                    {
                        if(!mapOfRegistrationIdsCancel.containsKey(i))
                            mapOfRegistrationIdsCancel.put(i, new Set<Id>());
                        
                        mapOfRegistrationIdsCancel.get(i).add(regId);
                        count++;
                        
                    }
                    else{
                        count = 1;
                        i++;
                        if(!mapOfRegistrationIdsCancel.containsKey(i))
                            mapOfRegistrationIdsCancel.put(i, new Set<Id>());
                        
                        mapOfRegistrationIdsCancel.get(i).add(regId);
                    }
                }
            }
            else
            {
                mapOfRegistrationIdsCancel.put(1, registrationIdsToCancelInZoom);
            }*/
            
             //11/16/2021 - CR-20211112-15583 - Chirag soni - Commented approved condition
            //for approved registrations
            /*if(registrationIdsToUpdateApprovedInZoom.size() > 100)
            { 
                integer count = 1;
                integer i = 1;
                for(Id regId  : registrationIdsToUpdateApprovedInZoom){
                    
                    if(count <= 100)
                    {
                        if(!mapOfRegistrationIdsToApprove.containsKey(i))
                            mapOfRegistrationIdsToApprove.put(i, new Set<Id>());
                        
                        mapOfRegistrationIdsToApprove.get(i).add(regId);
                        count++;
                        
                    }
                    else{
                        count = 1;
                        i++;
                        if(!mapOfRegistrationIdsToApprove.containsKey(i))
                            mapOfRegistrationIdsToApprove.put(i, new Set<Id>());
                        
                        mapOfRegistrationIdsToApprove.get(i).add(regId);
                    }
                }
            }
            else 
            {
                mapOfRegistrationIdsToApprove.put(1, registrationIdsToUpdateApprovedInZoom); 
            }
            //logic to process record in chunk of 100 records per map key -- end 
            */
	    //Modified By - Chirag Soni - CR-20211108-15570 - 11/08/2021 - Remove Check - !System.isFuture() &&
            // check size of map
             //11/16/2021 - CR-20211112-15583 - Chirag soni - Commented mapOfRegistrationIdsToApprove
             //12/06/2021 - CR-20211112-15583 - Chirag Soni - QA/UAT Issue #114 - Comment out the cancel call out to zoom and its related variables 
            if(mapOfRegistrationIdsToSync.size()>0)/* || mapOfRegistrationIdsCancel.size()>0 ) ||  mapOfRegistrationIdsToApprove.size()>0 )*/
            {
                integer delayInInsertCase = oldRegistrationsMap == null ? 80:25;
                DateTime sysTime = dateTime.now().addSeconds(delayInInsertCase); 
                String cronExpr = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
                
                //String to hold Apex Job Name
                String apexJobName = 'ScheduleJob_ZoomServices' + ' ' + dateTime.now()+' '+math.random();
                
                // passs set of registration ids to constructor of this class 
                //11/16/2021 - CR-20211112-15583 - Chirag soni - Commented mapOfRegistrationIdsToApprove
                //12/06/2021 - CR-20211112-15583 - Chirag Soni - QA/UAT Issue #114 - Comment out the cancel call out to zoom and its related variables 
                ScheduleJob_ZoomServices scheduleJobZoomServices = new ScheduleJob_ZoomServices(mapOfRegistrationIdsToSync,/* mapOfRegistrationIdsCancel, mapOfRegistrationIdsToApprove,*/ 1);
                System.schedule(apexJobName , cronExpr , scheduleJobZoomServices);
            }
            // -- 07/14/2021 - CR-20210709-15278 - Chirag Soni - commented enqueuing of job and schedule ScheduleJob_ZoomServices class -- end
        }
    }

    /*  Desription     :   This method used to check if the Registration status- Registered the condition satisfied then send the calendar invite.
     * 
     * Revision Logs   :    v1.0 - 04/27/2020 - Dipesh gupta - CR-20200424-13983.
     * 		       :    v1.1 - 07/16/2020 - Victor Hanson - CR-20200707-14273 - break out registrations into registered & void
     * 		       :    v1.2 - 08/04/2020 - Victor Hanson - CR-20200804-14400 - Only send calendar invite notification if Meeting.End_DateTime is in the future
     *		       :    v1.3 - 10/29/2020 - Saurabh Kumar - CR-20200819-14447 - Replaced Meeting with EAB Event
     *		       :    v1.4 - 02/04/2021 - Saurabh Kumar - Added a check to avoid unwanted query
     *                 :    V1.5 - 07/27/2021 - Chirag Soni - CR-20210709-15278 - commented methods call and added scheduler in place of it 
     * 		       :    V1.6 - 07/26/2021 - Chirag Soni - CR-20210716-15294 - Send Elevated Meal Registration Records for the Calendar Invite
     *                 :    V1.7 - 10/18/2021 - Chirag Soni - CR-20210628-15254 - Added the logic to send calendar invite when event format is "In-Person"
     * 		       :    V1.8 - 1/13/2022 - Chirag Soni - CR-20220113-15705 - Added eabEvents.ContainsKey(reg.EAB_Event__c) check in else condition.
     */
    public static void sendCalendarInvites(List<Registration__c> registrations, Map<Id, Registration__c> oldRegistrationsMap, boolean meetingUpdated) {
        
        //Set to hold the Registration Ids. 
        Set<Id> setOfRegistrationIds = new Set<Id>();
        Set<Id> setOfVOIDRegistrationIds = new Set<Id>();
        
        //Added By - Chirag Soni - 07/26/2021 - CR-20210716-15294 - Set to hold Elevated Meal Registration records - From Here
        Set<Id> setofElevatedMealRegistrationIds = new Set<Id>();
        
        set<String> Set_Rsvps_Values = new Set<String>{'Yes', 'Maybe'};
        
        //map to store EAB Event primary venue
        Map<Id, Id> mapOfEABEventIdWithPrimaryVenue = new Map<Id, Id>();
        
        //get all meetings
        Set<Id> eabEventIds = new Set<Id>();
        for (Registration__c reg : registrations) {
            
            //02/07/2021 - CR-20210207-14878 - Victor Hanson - Added
            //v1.4 - 02/04/2021 - Saurabh Kumar - Added a check to avoid unwanted query
            if (reg.RecordTypeId != Constants.REGISTRATION_RECORD_TYPE_ELEVATED_MEAL && (reg.EAB_Event__c != null && (reg.Status__c == STATUS_REGISTERED || reg.Status__c == STATUS_VOID || reg.Status__c == STATUS_CANCELLED))
                && (oldRegistrationsMap == null 
                    || reg.EAB_Event__c != oldRegistrationsMap.get(reg.Id).EAB_Event__c 
                    || reg.Status__c != oldRegistrationsMap.get(reg.Id).Status__c 
                    || reg.Zoom_Participant_URL__c != oldRegistrationsMap.get(reg.Id).Zoom_Participant_URL__c ) )  
            {   
                eabEventIds.add(reg.EAB_Event__c);
                
            }
            //Added By - Chirag Soni - 07/26/2021  - CR-20210716-15294 - Send Elevated Meal Registration Records for the Calendar Invite - From Here
            else if (Set_Rsvps_Values.Contains(reg.RSVP__c) && reg.RecordTypeId == Constants.REGISTRATION_RECORD_TYPE_ELEVATED_MEAL && (oldRegistrationsMap == null 
                                                                                                                                        || reg.EAB_Event__c != oldRegistrationsMap.get(reg.Id).EAB_Event__c 
                                                                                                                                        || reg.RSVP__c != oldRegistrationsMap.get(reg.Id).RSVP__c 
                                                                                                                                        || reg.Zoom_Participant_URL__c != oldRegistrationsMap.get(reg.Id).Zoom_Participant_URL__c ))
            {
                eabEventIds.add(reg.EAB_Event__c);
            }
            //Added By - Chirag Soni - 07/26/2021  - CR-20210716-15294 - Send Elevated Meal Registration Records for the Calendar Invite - Till Here
        }
        
        if(eabEventIds.size() == 0)
            return;
        
        //Updated by Saurabh Kumar - CR-20200819-14447 - Replaced Meeting with EAB Event
        //Map<Id, Meeting__c> mapMeetings = new Map<Id, Meeting__c>([SELECT Id, End_DateTime__c FROM Meeting__c WHERE Id IN :meetingIds]);
        Map<Id, Advisory_Event__c> eabEvents = new Map<Id, Advisory_Event__c>([SELECT 
                                                                               Id,Ends__c,Event_Format__c,RecordTypeId,Disable_Calendar_Invites__c, 
                                                                               Zoom_DialIn_Number__c,Zoom_Meeting_ID__c 
                                                                               FROM Advisory_Event__c WHERE Id IN :eabEventIds]);
        
        //Added by - Chirag Soni - 10/18/2021 - CR-20210628-15254 - Added the loop to hold primary venue name - Start Here  
        for(Venue__c venue : [Select Id, Advisory_Event__c, Name, Venue_Address__c From Venue__c Where Primary__c = True AND Advisory_Event__c IN: eabEvents.keySet() AND Advisory_Event__r.Event_Format__c =: Constants.EAB_EVENT_IN_PERSON_EVENT_FORMAT]){
            	if(venue != null && !mapOfEABEventIdWithPrimaryVenue.containsKey(venue.Advisory_Event__c)){
                	mapOfEABEventIdWithPrimaryVenue.put(venue.Advisory_Event__c,venue.Id);
            	}
        }
        //Added by - Chirag Soni - 10/18/2021 - CR-20210628-15254 - Added the loop to hold primary venue name - Till Here   
        
        for(Registration__c reg : registrations) {
        	
            Registration__c oldReg;
            if (oldRegistrationsMap != null) oldReg = oldRegistrationsMap.get(reg.Id);
            
            Advisory_Event__c eabEvent;
            if(reg.EAB_Event__c != null && eabEvents.containsKey(reg.EAB_Event__c))
                eabEvent = eabEvents.get(reg.EAB_Event__c);
            
            //01/27/2021 - CR-20200821-14465 - Victor Hanson - Do not send invite if Disable Calendar Invites is checked
            if (eabEvent != null && eabEvent.Disable_Calendar_Invites__c) {
                continue;
            }

            //08/04/2020 - CR-20200804-14400 - Only send calendar invite notification if Meeting.End_DateTime is in the future
            //Check if the insert case/ status or URL changed. 
            if(reg.RecordTypeId != Constants.REGISTRATION_RECORD_TYPE_ELEVATED_MEAL 
               && (reg.Status__c == STATUS_REGISTERED || reg.Status__c == STATUS_VOID || reg.Status__c == STATUS_CANCELLED) && 
               String.isNotBlank(reg.EAB_Event__c) && eabEvents.ContainsKey(reg.EAB_Event__c) 
               && eabEvents.get(reg.EAB_Event__c).RecordTypeId != Constants.RECORD_TYPE_ID_EAB_EVENT_ELEVATED_MEAL
               && eabEvent != null
               && eabEvent.Ends__c >= DateTime.now()
               && (String.isNotBlank(reg.Zoom_Participant_URL__c) || (oldReg != null && oldReg.Zoom_Participant_URL__c != reg.Zoom_Participant_URL__c)) 
               && (oldReg == null || (oldReg != null 
                                      && (oldReg.Status__c != reg.Status__c 
                                          || oldReg.Zoom_Participant_URL__c != reg.Zoom_Participant_URL__c)))
              ) 
            {
                if (reg.Status__c == STATUS_REGISTERED )
                    setOfRegistrationIds.add(reg.Id);
                else if (reg.Status__c == STATUS_VOID || reg.Status__c == STATUS_CANCELLED)
                    setOfVOIDRegistrationIds.add(reg.Id);
            }
            //Added By - Chirag Soni - 07/26/2021  - CR-20210716-15294 - Send Elevated Meal Registration Records for the Calendar Invite - From Here
            else if(Set_Rsvps_Values.Contains(reg.RSVP__c) && reg.RecordTypeId == Constants.REGISTRATION_RECORD_TYPE_ELEVATED_MEAL 
                    && String.isNotBlank(reg.EAB_Event__c) &&  eabEvents.ContainsKey(reg.EAB_Event__c) 
                    && eabEvents.get(reg.EAB_Event__c).RecordTypeId == Constants.RECORD_TYPE_ID_EAB_EVENT_ELEVATED_MEAL
                    && eabEvent.Ends__c >= DateTime.now()
                    && (String.isNotBlank(reg.Zoom_Participant_URL__c) || (oldReg != null && oldReg.Zoom_Participant_URL__c != reg.Zoom_Participant_URL__c)) 
                    && (oldReg == null || (oldReg != null 
                                           && (oldReg.RSVP__c != reg.RSVP__c 
                                               || oldReg.Zoom_Participant_URL__c != reg.Zoom_Participant_URL__c)))
                   ) 
            {
                setofElevatedMealRegistrationIds.add(reg.Id);
            }
            //Added By - Chirag Soni - 07/26/2021  - CR-20210716-15294 - Send Elevated Meal Registration Records for the Calendar Invite - Till Here

            //Added By - Chirag Soni - 10/18/2021  - CR-20210628-15254 - Added the logic to send calendar invite when event format is "In-Person" - starts Here
            //Added By - Chirag Soni - 1/13/2022 -  CR-20220113-15705 - Added check in below condition i.e. eabEvents.ContainsKey(reg.EAB_Event__c)
            else if (eabEvents.ContainsKey(reg.EAB_Event__c) && eabEvents.get(reg.EAB_Event__c).Event_Format__c != null && eabEvents.get(reg.EAB_Event__c).Event_Format__c == Constants.EAB_EVENT_IN_PERSON_EVENT_FORMAT && 
                     String.isBlank(reg.Zoom_Participant_URL__c) && 
                     String.isBlank(eabEvents.get(reg.EAB_Event__c).Zoom_DialIn_Number__c) && mapOfEABEventIdWithPrimaryVenue.get(reg.EAB_Event__c) != null && 
                     String.isBlank(eabEvents.get(reg.EAB_Event__c).Zoom_Meeting_ID__c) && reg.Status__c != null)
            {
                if (reg.Status__c == STATUS_REGISTERED)
                    setOfRegistrationIds.add(reg.Id);
                else if (reg.Status__c == STATUS_VOID || reg.Status__c == STATUS_CANCELLED)
                    setOfVOIDRegistrationIds.add(reg.Id);
            }
            //Added By - Chirag Soni - 10/18/2021  - CR-20210628-15254 - Added the logic to send calendar invite when event format is "In-Person" - Till Here
        }
        
        if(setOfRegistrationIds.size() > 0) {
            
            //07/27/2021 - Chirag Soni - CR-20210709-15278 - commented methods call and added scheduler in place of it 
            // callCommunicationTemplateService(setOfRegistrationIds, Constants.HTTP_REQUEST_POST_TYPE, meetingUpdated);
            //create croj exp to schedule after 10 seconds
            DateTime sysTime = dateTime.now().addSeconds(10);
            String cronExpr = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
            
            //String to hold Apex Job Name
            String apexJobName = 'Schedule_CommunicationTemplateService' + ' ' + dateTime.now()+' '+math.random();
            
            // passs set of registration ids to constructor of this class 
            Schedule_CommunicationTemplateService scheduleCommunicationTemplateServices = new Schedule_CommunicationTemplateService(setOfRegistrationIds, Constants.HTTP_REQUEST_POST_TYPE, meetingUpdated);
            System.schedule(apexJobName , cronExpr , scheduleCommunicationTemplateServices);
        }
        
        if(setOfVOIDRegistrationIds.size() > 0) {
            
            //07/27/2021 - Chirag Soni - CR-20210709-15278 - commented methods call and added scheduler in place of it  
            // callCommunicationTemplateService(setOfVOIDRegistrationIds, 'DELETE', meetingUpdated);
            
            //create croj exp to schedule after 10 seconds
            DateTime sysTime = dateTime.now().addSeconds(10);
            String cronExpr = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
            
            //String to hold Apex Job Name
            String apexJobName = 'Schedule_CommunicationTemplateService' + ' ' + dateTime.now()+' '+math.random();
            
            // passs set of registration ids to constructor of this class 
            Schedule_CommunicationTemplateService scheduleCommunicationTemplateServices = new Schedule_CommunicationTemplateService(setOfVOIDRegistrationIds, 'DELETE', meetingUpdated);
            System.schedule(apexJobName , cronExpr , scheduleCommunicationTemplateServices);
        }
        
        //Added By - Chirag Soni - 07/26/2021  - CR-20210716-15294 - Send Elevated Meal Registration Records for the Calendar Invite - From Here
        if(setofElevatedMealRegistrationIds.size() > 0) {
            
            //07/27/2021 - Chirag Soni - CR-20210709-15278 - commented methods call and added scheduler in place of it  
            //callCommunicationTemplateService(setofElevatedMealRegistrationIds, Constants.HTTP_REQUEST_POST_TYPE, meetingUpdated);
            //create croj exp to schedule after 10 seconds
            DateTime sysTime = dateTime.now().addSeconds(10);
            String cronExpr = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
            
            //String to hold Apex Job Name
            String apexJobName = 'Schedule_CommunicationTemplateService' + ' ' + dateTime.now()+' '+math.random();
            
            // passs set of registration ids to constructor of this class 
            Schedule_CommunicationTemplateService scheduleCommunicationTemplateServices = new Schedule_CommunicationTemplateService(setofElevatedMealRegistrationIds, Constants.HTTP_REQUEST_POST_TYPE, meetingUpdated);
            System.schedule(apexJobName , cronExpr , scheduleCommunicationTemplateServices);
        }
        //Added By - Chirag Soni - 07/26/2021  - CR-20210716-15294 - Send Elevated Meal Registration Records for the Calendar Invite - Till Here
    }
	
    /**
     *  @description    : Method is used to populate populate Partner Status field.
     *                    Auto-population logic: Get all of the Contact Institution's active Memberships. If at least one of those active 
     *                    Memberships programs match the EAB Event's Primary Program or related Event Rule Program, Partner Status=Partner. 
     *                    Otherwise, Partner Status=Prospect
     *
     *  @arg            : List<Registration__c> newRegistrations, Map<Id, Registration__c> oldRegistrations
     * 
     *  @return         : Void
     * 
     *  @revision       : V1.0 created: Saurabh Kumar 09/28/2020 - CR-20200821-14453
     * 			: V1.1 updated: Saurabh Kumar 02/26/2021 - CR-20210224-14940: Updated code to add status check in case status is updating from Cancelled to something else.
     * */
    public static void populatePartnerStatus(List<Registration__c> newRegistrations, Map<Id, Registration__c> oldRegistrations){
        
        //Set to hold registration Ids to process
        Set<Id> registrationIds = new Set<Id>();
        
        for(Registration__c registration : newRegistrations){
            
            //V1.1 updated: Saurabh Kumar 02/26/2021 - CR-20210224-14940: Updated code to add status check in case status is updating from Cancelled to something else.
            if((oldRegistrations == null || registration.Contact__c != oldRegistrations.get(registration.Id).Contact__c 
                || registration.EAB_Event__c != oldRegistrations.get(registration.Id).EAB_Event__c ) 
                || (registration.Status__c != oldRegistrations.get(registration.Id).Status__c && oldRegistrations.get(registration.Id).Status__c == Constants.REGISTRATION_STATUS_CANCELLED)){
                   registrationIds.add(registration.Id);
               } 
        }
        if(registrationIds.size() > 0)
            RegistrationHelper.updatePartnerStatus(registrationIds, new Set<Id> ());
    }
    
    /**
     *  @description    : Method is used to update populate Partner Status field.
     *                    Auto-population logic: Get all of the Contact Institution's active Memberships. If at least one of those active 
     *                    Memberships programs match the EAB Event's Primary Program or related Event Rule Program, Partner Status=Partner. 
     *                    Otherwise, Partner Status=Prospect
     *
     *  @arg            : 
     * 
     *  @return         : Void
     * 
     *  @revision       : V1.0 created: Saurabh Kumar 09/28/2020 - CR-20200821-14453
     *			: V1.1 Modified By - Chirag Soni - 07/29/2021 - CR-20210526-15185 - Commented the Bypass Flags
     *			: V1.2 Modified By - Chirag Soni - CR-20210606-15193 - add util bybpass
     *			: V1.3 Modified By - Chirag Soni - CR-20220307-15987 - added oldMap Registration 
     * */
    public static void updatePartnerStatus(Set<Id> registrationIds, Set<Id> parentIdsToSkip){
        
        if(registrationIds.size() == 0)
            return;
        
        //Map to hold EAB Event Id by Registration Id
        Map<Id, Id> eabEventIdByRegistrationId = new Map<Id, Id>();
        
        //Map to hold Institution Id by Registration Id
        Map<Id, Id> institutionIdByRegistrationId = new Map<Id, Id>();
        
        //Map to hold EAB Event's Program by Registration Id
        Map<Id, Id> eabEventProgramByRegistrationId = new Map<Id, Id>();
        
        //Map to hold Rules by EAB Event Ids
        Map<Id, List<Event_Rule__c>> rulesByEABEventIds = new Map<Id, List<Event_Rule__c>>();
        
        //Map to hold Memberships by Institution
        Map<Id, List<Membership__c>> membershipsByInstitutionIds = new Map<Id, List<Membership__c>>();
        
        //02/22/2021 - CR-20210217-14921 - Victor Hanson - added Parent_Registration__c
        //02/17/2021 - CR-20210211-14905 - Victor Hanson
        //Map to hold Registration should be updated
        Map<Id, Registration__c> registrationsToBeUpdated = new Map<Id, Registration__c>([Select Id, EAB_Event__c, EAB_Event__r.Primary_Program__c, Contact__c, Cancellation_Reason__c, Declined_Reason__c,
                                                                                            Contact__r.AccountId, Status__c, Origin__c, Approval_Reason__c, Parent_Registration__c, Partner_Status__c,
                                                                                            Approval_Status__c, Automated_Update__c, Registered_on_Date__c
                                                                                            From Registration__c
                                                                                            Where Id IN : registrationIds AND EAB_Event__c != null AND Contact__c != null
                                                                                            AND Contact__r.AccountId != null AND EAB_Event__c NOT IN : parentIdsToSkip AND Contact__c
                                                                                            NOT IN : parentIdsToSkip AND Contact__r.AccountId NOT IN : parentIdsToSkip AND 
                                                                                            EAB_Event__r.Primary_Program__c NOT IN : parentIdsToSkip]);

        for(Registration__c registration : registrationsToBeUpdated.values()){
                                      
            eabEventIdByRegistrationId.put(registration.Id, registration.EAB_Event__c);
            institutionIdByRegistrationId.put(registration.Id, registration.Contact__r.AccountId);
            eabEventProgramByRegistrationId.put(registration.Id, registration.EAB_Event__r.Primary_Program__c);
        }
        
        //Block to get all related Rules and Programs
        if(eabEventIdByRegistrationId.size() > 0){
            for(Event_Rule__c evtRule : [Select Id, Rule__r.Program__c, Advisory_Event__c From Event_Rule__c 
                                         Where Advisory_Event__c != null 
                                         AND Rule__r.Program__c != null 
                                         AND Advisory_Event__c IN : eabEventIdByRegistrationId.values() 
                                         AND Rule__r.Program__c NOT IN : parentIdsToSkip])
            {
                
                if(!rulesByEABEventIds.containsKey(evtRule.Advisory_Event__c)) 
                    rulesByEABEventIds.put(evtRule.Advisory_Event__c, new List<Event_Rule__c>());
                rulesByEABEventIds.get(evtRule.Advisory_Event__c).add(evtRule);
            }
        }
        
        //Block to get all related Memberships and Programs
        if(institutionIdByRegistrationId.size() > 0){
            for(Membership__c membership : [Select Id, Program__c, Membership_Status__c, Account_Name__c From Membership__c Where 
                                            Membership_Status__c LIKE 'Member -%' AND Program__c != null AND Account_Name__c IN : 
                                            institutionIdByRegistrationId.values() AND Program__c NOT IN : parentIdsToSkip
                                            AND Id NOT IN : parentIdsToSkip]){
                                                if(!membershipsByInstitutionIds.containsKey(membership.Account_Name__c))
                                                    membershipsByInstitutionIds.put(membership.Account_Name__c, new List<Membership__c>());
                                                membershipsByInstitutionIds.get(membership.Account_Name__c).add(membership);
                                            }
        }
        
        //Block to populate Partner Status
        for(Id registrationId : registrationIds){
            //02/17/2021 - CR-20210211-14905 - Victor Hanson - added below because registrationsToBeUpdated converted to map
            if (registrationsToBeUpdated.get(registrationId) == null) {
                registrationsToBeUpdated.put(registrationId, new Registration__c(Id = registrationId));
            }
            registrationsToBeUpdated.get(registrationId).Partner_Status__c = Constants.REGISTRATION_PARTNER_STATUS_PROSPECT;
            
            Id accountId = institutionIdByRegistrationId.containsKey(registrationId) ? institutionIdByRegistrationId.get(registrationId) : null;
            Id eabEventId = eabEventIdByRegistrationId.containsKey(registrationId) ? eabEventIdByRegistrationId.get(registrationId) : null;
            Id eabEventProgramId = eabEventProgramByRegistrationId.containsKey(registrationId) ? eabEventProgramByRegistrationId.get(registrationId) : null;
            
            if(accountId != null && membershipsByInstitutionIds.containskey(accountId)){
                for(Membership__c membership : membershipsByInstitutionIds.get(accountId)){
                    
                    if(membership.Program__c == eabEventProgramId){
                       registrationsToBeUpdated.get(registrationId).Partner_Status__c = Constants.REGISTRATION_PARTNER_STATUS_PARTNER;
                       break;
                        
                    }else if(eabEventId != null && rulesByEABEventIds.containsKey(eabEventId)){
                        for(Event_Rule__c evtRule : rulesByEABEventIds.get(eabEventId)){
                            //02/16/2021 - CR-20210211-14905 - Victor Hanson - commented out portion of if statement below
                            if(membership.Program__c == evtRule.Rule__r.Program__c /*|| eabEventProgramId == evtRule.Rule__r.Program__c*/){
                                registrationsToBeUpdated.get(registrationId).Partner_Status__c = Constants.REGISTRATION_PARTNER_STATUS_PARTNER;
                                break;
                            }
                                
                        }
                    }
                    
                    if(registrationsToBeUpdated.get(registrationId).Partner_Status__c == Constants.REGISTRATION_PARTNER_STATUS_PARTNER)
                        break;
                }
            }
        }
        List<Registration__c> regs = new List<Registration__c>();
        if(registrationsToBeUpdated.size() > 0){
            
            //Commented By - Chirag Soni - 07/29/2021 - CR-20210526-15185 - Commented the Bypass Flags 
            //Util.ByPassAllTriggers = true;
            
            bypassRegistrationDLRS = true;
            //Modified By - Chirag Soni - CR-20220214-15914
            bypasspopulateInstitutionRegistrationCount = true;
            //02/17/2021 - CR-20210211-14905 - Victor Hanson - recalculate status and approval reason because it could change depending on Partner Status
            regs = populateStatusAndApprovalReason(registrationsToBeUpdated.values());
            
            //CR-20220307-15987 - Chirag Soni - 02/08/2022 - Get oldMapRegistrations before updating child registration records  
            Map<Id,Registration__c> oldMapRegistrations = new Map<Id,Registration__c>([SELECT Id, Status__c FROM Registration__c WHERE Id IN :regs]);
            
            update regs;
            //Modified By - Chirag Soni - CR-20220214-15914 - update related registrations after parent updated 
            //CR-20220307-15987 - Chirag Soni - 02/08/2022 - Added oldMapRegistrations
            updateRelatedRegistrationStatus(regs, oldMapRegistrations);
            
            bypassRegistrationDLRS = false;
            //Modified By - Chirag Soni - CR-20220214-15914
            bypasspopulateInstitutionRegistrationCount = false;
            //Commented By - Chirag Soni - 07/29/2021 - CR-20210526-15185 - Commented the Bypass Flags 
            //Util.ByPassAllTriggers = false;         
        }
    }
    
    /**
     *  @description    : Method is used to create Membership MtM records in case on Registration insertion.
     *                    Logic: When a registration is inserted, get the related EAB Event's Event Rules where Program is populated. Then get the active Memberships related to the Registration's Contact Institution where Program is in the list of Event Rule Programs.
                                 Create a Membership MtM record for each of the Contact Institution's active Membership where the Program matches a corresponding Event Rule Program.
                                 Membership MtM.Registration = registration.Id
                                 Membership MtM.Membership = membership.Id
     *
     *  @arg            : Map<Id, Registration__c> newRegistrations
     * 
     *  @return         : Void
     * 
     *  @revision       : V1.0 Created: Saurabh Kumar 09/30/2020 - CR-20200821-14453
     * 			: V1.1 Updated: Saurabh Kumar 02/16/2021 - CR-20210208-14884: Logic updated to avoid Membership Status from filter.
     *                  : V1.2 Updated: Chirag Soni 06/23/2021 - CR-20210504-15118 : moved all the logic from createMembershipMtMRecords method to createMembershipMtMRecordsLogic() except initial checks
     * */
    public static void createMembershipMtMRecords(Map<Id, Registration__c> newRegistrations){
        
        //Set to hold Registration Ids which should be processed
        Set<Id> registrationIds = new Set<Id>();
        
        for(Registration__c registration : newRegistrations.values()){
            
            if(registration.EAB_Event__c != null && registration.Contact__c != null)
                registrationIds.add(registration.Id);
        }
        
        if(registrationIds.size() == 0)
            return;
        
        // pass the set of registration ids to createMembershipMtMRecordsLogic -  added by chirag soni - CR-20210504-15118 
        createMembershipMtMRecordsLogic(registrationIds);
    }
    
    /**
 *  @description    : Method is used to create Membership MtM records in case on Registration insertion AND Event rule insertion on EAB Event.
 *                    Logic 1 - When a registration is inserted, get the related EAB Event's Event Rules where Program is populated. Then get the active Memberships related to the Registration's Contact Institution where Program is in the list of Event Rule Programs.
 *			     		        Create a Membership MtM record for each of the Contact Institution's active Membership where the Program matches a corresponding Event Rule Program.    
 *					  Logic 2 - Whenever Event Rule is created under EAB Event, get all EAB Event's related registration records and check Membership MtM record is there for registration record if no  
                        	    Create a Membership MtM record for each of the Contact Institution's active Membership where the Program matches a corresponding Event Rule Program. 
					 Membership MtM.Registration = registration.Id
 *					 Membership MtM.Membership = membership.Id
 *
 *  @arg            : Set<Id> regitrationIds
 * 
 *  @return         : Void
 * 
 *  @revision       : V1.0 Created: Chirag Soni 06/23/2021 - CR-20210504-15118 - moved all the logic from createMembershipMtMRecords method to createMembershipMtMRecordsLogic() except initial checks
 * */
    
    public static void createMembershipMtMRecordsLogic(Set<Id> registrationIds)
    {
        //Map to hold EAB Event Id by Registration Id
        Map<Id, Id> eabEventIdByRegistrationId = new Map<Id, Id>();
        
        //Map to hold Institution Id by Registration Id
        Map<Id, Id> institutionIdByRegistrationId = new Map<Id, Id>();
        
        //Map to hold Rules by EAB Event Ids
        Map<Id, List<Event_Rule__c>> rulesByEABEventIds = new Map<Id, List<Event_Rule__c>>();
        
        //Map to hold Memberships by Institution
        Map<Id, List<Membership__c>> membershipsByInstitutionIds = new Map<Id, List<Membership__c>>();
        
        //Map to hold Membership MtM records by Membership & Registration Ids
        Map<String, Membership_MtM__c> membershipsMtMByMembershipAndRegistrationIds = new Map<String, Membership_MtM__c>();
        
        for(Registration__c registration : [Select Id, EAB_Event__c, Contact__c, Contact__r.AccountId From
                                           Registration__c Where Id IN : registrationIds AND EAB_Event__c != null AND Contact__c != null
                                           AND Contact__r.AccountId != null ]){
                                               
            eabEventIdByRegistrationId.put(registration.Id, registration.EAB_Event__c);
            institutionIdByRegistrationId.put(registration.Id, registration.Contact__r.AccountId);
        }
        
        //Block to get all related Rules and Programs
        if(eabEventIdByRegistrationId.size() > 0){
            for(Event_Rule__c evtRule : [Select Id, Advisory_Event__c, Rule__r.Program__c From Event_Rule__c 
                                         Where Advisory_Event__c != null 
                                         AND Rule__r.Program__c != null 
                                         AND Advisory_Event__c IN : eabEventIdByRegistrationId.values()])
            {
                
                if(!rulesByEABEventIds.containsKey(evtRule.Advisory_Event__c)) 
                    rulesByEABEventIds.put(evtRule.Advisory_Event__c, new List<Event_Rule__c>());
                rulesByEABEventIds.get(evtRule.Advisory_Event__c).add(evtRule);
            }
        }
        //Added By - Chirag Soni - CR-20210504-15118 - 08/03/2021 - Added code to store old Membership Ids that exist on the MTM Records -  From Here
        Set<Id> setOfMembershipIds = new Set<Id>();
        for(Registration__c registration : [SELECT Id, (SELECT Id,Membership__c FROM Membership_MtMs__r) FROM Registration__c WHERE Id IN :registrationIds]){
            if(registration.Membership_MtMs__r.size()>0){
                for(Membership_MtM__c memberShipMTM : registration.Membership_MtMs__r){
                    setOfMembershipIds.add(memberShipMTM.Membership__c);
                }
            }
        }
        //Added By - Chirag Soni - CR-20210504-15118 - 08/03/2021 - Added code to store old Membership Ids that exist on the MTM Records - Till Here
        
        //V1.1 Updated: Saurabh Kumar 02/16/2021 - CR-20210208-14884: Logic updated to avoid Membership Status from filter. Removed "Membership_Status__c LIKE 'Member -%' AND" from where clause.
        //Block to get all related Memberships and Programs
        if(institutionIdByRegistrationId.size() > 0){
            //Modified By - Chirag Soni - 08/03/2021 - Added check to avoid duplicate Membership Ids on MTM Records
            for(Membership__c membership : [Select Id, Program__c, Membership_Status__c, Account_Name__c From Membership__c Where 
                                            Program__c != null AND Account_Name__c IN : 
                                            institutionIdByRegistrationId.values() AND Id Not IN : setOfMembershipIds ]){
                                                if(!membershipsByInstitutionIds.containsKey(membership.Account_Name__c))
                                                    membershipsByInstitutionIds.put(membership.Account_Name__c, new List<Membership__c>());
                                                membershipsByInstitutionIds.get(membership.Account_Name__c).add(membership);
                                            }
        }
        
        //Block to create Membership MtM records
        for(Id registrationId : registrationIds){
            
            Id accountId = institutionIdByRegistrationId.containsKey(registrationId) ? institutionIdByRegistrationId.get(registrationId) : null;
            Id eabEventId = eabEventIdByRegistrationId.containsKey(registrationId) ? eabEventIdByRegistrationId.get(registrationId) : null;
            
            if(accountId != null && membershipsByInstitutionIds.containskey(accountId) && eabEventId != null && rulesByEABEventIds.containsKey(eabEventId)){
                for(Membership__c membership : membershipsByInstitutionIds.get(accountId)){
                     
                    for(Event_Rule__c evtRule : rulesByEABEventIds.get(eabEventId)){
                        if(membership.Program__c == evtRule.Rule__r.Program__c){
                            membershipsMtMByMembershipAndRegistrationIds.put(membership.Id+''+registrationId, new Membership_MtM__c(Membership__c = membership.Id, 
                                                                                                                                   Registration__c = registrationId));
                            break;
                        }
                        
                    }
                }
            }
        }
        
        if(membershipsMtMByMembershipAndRegistrationIds.size() > 0){
            Util.ByPassAllTriggers = true;
            insert membershipsMtMByMembershipAndRegistrationIds.values();
            Util.ByPassAllTriggers = false;
        }
    }
    
    /**
     *  @description    :   This method is used to hold populate Registration field
     *                      1. Registered By : Auto-populate with the user that changes the Approval Status to 'Approved'
     * 
     *  @args           :   List<Registration__c> newRegistrations, Map<Id, Registration__c> oldRegistrations
     * 
     *  @return         :   Void
     * 
     *  @revision Log   :   V1.0 - Created  - Saurabh Kumar - 10/05/2020 - CR-20200821-14460
     *                  :   V1.1 - Modified - Saurabh Kumar - 11/11/2020 - CR-20200820-14451
     *                             Logic: Registration's Contact is not an Employee, update RecordType to Core Registration else Internal Attendee.
     *                  :   V1.2 - Modified - Saurabh Kumar - 11/19/2020 - CR-20200821-14465
     *                             Logic: Registration.Approval Status is updated to "Approved"
     *                                    if EABEvent.Approval_Required__c = TRUE & Registration is on the Invite List, Approval Type = Invite List
     *                                    else if EABEvent.Approval_Required__c = TRUE & Registration is NOT on the Invite List, Approval Type = Manual
     *			:   V1.3 - Modified - Saurabh Kumar - 02/04/2021 - Reduce unwanted SOQL
     *			           Logic: Moved "Populate Registration's Origin Value" process builder logic here. If created by user type is Guest then
     *				   Origin should be EAB.com else Salesforce in case of insert only. And added check to avoid unwanted processing
    *			:   V1.4 - Modified - Saurabh Kumar - 03/02/2021 - CR-20210114-14812
    *			           Logic: All registraints would be core registration if EAB_Event__c.Allow_Employee_Registrations__c = true.
    * 		        :   V1.5 - Modified - Saurabh Kumar - 04/13/2021 - CR-20210128-14854: Populate Registration_Approved_Date__c field when registration status is registered.
    * 			:   V1.6 - Modified - Saurabh Kumar - 04/19/2021 - CR-20210318-15005: Moved "Populate the Registration's Status Field Value" process builder logic to this method
    *  			:   V1.7 - Modified - Chirag Soni - 05/20/2021 - CR-20210318-15005 : UAT Issues (MRS2.0) - If Registration Approval status = Approved and Registration status is not equal to Attended then registration status must be registered.
    *			:   V1.8 - Modified - Chirag Soni - 05/26/2021 - CR-20210318-15005 : UAT Issues (MRS2.0) - If Registration Approval status = Approved and Registration status is not equal to Cancelled then registration status must be registered
    *			:   V1.9 - Modified - Chirag Soni - 06/15/2021 - CR-20210318-15005 - Critical : UAT Issues (MRS2.0) - If Registration Approval status = Approved and Registration status equal to Registration Requested then only registration status must be registered
     * 			:   V2.0 - Modified - Chirag Soni - 06/29/2021 - CR-20210625-15241 : modified approval status = waitlist and approval status = declined check in populateRegistrationField() method. 
     * */
    public static void populateRegistrationField(List<Registration__c> newRegistrations, Map<Id, Registration__c> oldRegistrations){
        
        //Set to hold Contact Id
        Set<Id> contactIds = new Set<Id>();
        
        //Set to hold EAB Event's Id
        Set<Id> eabEventIds = new Set<Id>();
        
        //03/02/2021 - CR-20210114-14812 - Saurabh Kumar - added
        //Set to hold EAB Event Ids to query
        Set<Id> eventIds = new Set<Id>();
        
        for(Registration__c registration : newRegistrations){
            
            //03/02/2021 - CR-20210114-14812 - Saurabh Kumar - added
            if(registration.EAB_Event__c != null)
                eventIds.add(registration.EAB_Event__c);
            
            //02/22/2021 - CR-20210217-14921 - Victor Hanson - added
            if (Trigger.isInsert && registration.Status__c == Constants.REGISTRATION_STATUS_WAITLIST) {
                registration.Declined_Reason__c = 'Event Reg Capacity';
            }

            //V1.3 - Added - Saurabh Kumar - 02/04/2021: Start
            if(oldRegistrations == null){
                
                registration.Origin__c = UserInfo.getUserType() == USER_TYPE_GUEST ? Constants.REGISTRATION_ORIGIN_EAB_DOT_COM : Constants.REGISTRATION_ORIGIN_SALESFORCE;
            }
            
            if( (registration.EAB_Event__c != null && registration.Status__c != Constants.REGISTRATION_STATUS_CANCELLED) &&
              	(oldRegistrations == null || oldRegistrations.get(registration.Id).EAB_Event__c != registration.EAB_Event__c
                 || oldRegistrations.get(registration.Id).Approval_Status__c != registration.Approval_Status__c ) ) {
                eabEventIds.add(registration.EAB_Event__c);
            }
	    //V1.3 - Added - Saurabh Kumar - 02/04/2021: End
			
            if(registration.Approval_Status__c == Constants.KEYWORD_APPROVED && (oldRegistrations == null || 
                                                                                 registration.Approval_Status__c != oldRegistrations.get(registration.Id).Approval_Status__c)){
                registration.Registered_By__c = UserInfo.getUserId();
            }
            if( registration.Contact__c != null && (oldRegistrations == null || registration.Contact__c != oldRegistrations.get(registration.Id).Contact__c)){
                contactIds.add(registration.Contact__c);
            }

            //01/05/2021 - CR-20200821-14465 - Victor Hanson - Populates duplicate matching field.  This field is used in dupe matching logic because we can only reference one lookup field
            if (registration.Contact__c != null && registration.EAB_Event__c != null) {
                registration.Duplicate_Matching__c = registration.Contact__c + '-' + registration.EAB_Event__c;
            }
            
            //V1.5 - Modified - Saurabh Kumar - 04/13/2021 - CR-20210128-14854: Populate Registration_Approved_Date__c field when registration status is registered.
            if(registration.Status__c == Constants.REGISTRATION_STATUS_REGISTERED && (oldRegistrations == null || oldRegistrations.get(registration.Id).Status__c != registration.Status__c))
                registration.Registration_Approved_Date__c = System.today();
        }
        
        //03/02/2021 - CR-20210114-14812 - Saurabh Kumar - added: Start
        Map<Id, Advisory_Event__c> mapOfEABEvents = new Map<Id, Advisory_Event__c>();
        if(eventIds.size() > 0)
            //Modified By - 08/12/2021 - CR-20210511-15137 - Chirag Soni - Modified By - Added the RecordTypeId field in the query
            mapOfEABEvents = new Map<Id, Advisory_Event__c>([Select Id, RecordTypeId, Invite_List__c, Approval_Required__c, Allow_Employee_Registrations__c From Advisory_Event__c Where Id IN : eventIds]);
        
        //03/02/2021 - CR-20210114-14812 - Saurabh Kumar - added: End
        
        if(contactIds.size() > 0){
            
            //Query on Contact
            Map<Id, Contact> mapOfContacts = new Map<Id, Contact>([Select Id, RecordTypeId From Contact Where Id IN : contactIds]);
            
            //Update correct record type
            for(Registration__c reg : newRegistrations){
                
                if(reg.Contact__c == null)
                    continue;
                
                //03/02/2021 - CR-20210114-14812 - Saurabh Kumar - added "&& reg.EAB_Event__c != null && !mapOfEABEvents.get(reg.EAB_Event__c).Allow_Employee_Registrations__c"
                if(mapOfContacts.get(reg.Contact__c).RecordTypeId == Constants.CONTACT_RECORD_TYPE_ID_EMPLOYEE && reg.EAB_Event__c != null && 
                   !mapOfEABEvents.get(reg.EAB_Event__c).Allow_Employee_Registrations__c)
                    reg.RecordTypeId = Constants.REGISTRATION_RECORD_TYPE_ID_INTERNAL_ATTENDEE;
                
                //Modified By - 10/28/2021 - CR-20210511-15137 - Chirag Soni - Modified By - Added a Record type Check to filter out Elevated Meal Events - From Here
                else if(reg.EAB_Event__c != null && mapOfEABEvents.get(reg.EAB_Event__c).RecordTypeId != Constants.RECORD_TYPE_ID_EAB_EVENT_ELEVATED_MEAL)
                    reg.RecordTypeId = Constants.REGISTRATION_RECORD_TYPE_ID_CORE_REGISTRATION;
                else if(reg.EAB_Event__c != null && mapOfEABEvents.get(reg.EAB_Event__c).RecordTypeId == Constants.RECORD_TYPE_ID_EAB_EVENT_ELEVATED_MEAL){
                    reg.RecordTypeId = Constants.REGISTRATION_RECORD_TYPE_ELEVATED_MEAL;
                }
                //Modified By - 10/28/2021 - CR-20210511-15137 - Chirag Soni - Modified By - Added a Record type Check to filter out Elevated Meal Events - Till Here
            }
        }
        
        //Block to populate Approval Type
        if(eabEventIds.size() > 0){
            
            //Map to hold EAB Event
            Map<Id, Advisory_Event__c> mapOfEABEvent = new Map<Id, Advisory_Event__c>();
            
            //Set to hold Campaign Id
            Set<Id> campaignIds = new Set<Id>();
            
            //Map to hold Campaign records
            Map<Id, Campaign> mapOfCampaigns = new Map<Id, Campaign>();
            
            //Map to hold CampaignMember records
            Map<Id, CampaignMember> mapOfCampaignMembers = new Map<Id, CampaignMember>();
            
            //03/02/2021 - CR-20210114-14812 - Saurabh Kumar - Updated query to set
            //for(Advisory_Event__c eabEvent : [Select Id, Invite_List__c, Approval_Required__c From Advisory_Event__c Where Id IN : eabEventIds]){
            for(Id eabEventId : eabEventIds){
                
                //03/02/2021 - CR-20210114-14812 - Saurabh Kumar - Added below statement.
                Advisory_Event__c eabEvent = mapOfEABEvents.get(eabEventId);
                
                mapOfEABEvent.put(eabEvent.Id, eabEvent);
                if(eabEvent.Invite_List__c != null)
                    campaignIds.add(eabEvent.Invite_List__c);
            }
            
            //Query on Campaign
            if(campaignIds.size() > 0){
            
                mapOfCampaigns = new Map<Id, Campaign>([Select Id, (Select Id, ContactId From CampaignMembers) From Campaign Where Id IN : campaignIds]);
                for (Campaign c : mapOfCampaigns.values()) {
                    for (CampaignMember cm : c.CampaignMembers) {
                        mapOfCampaignMembers.put(cm.ContactId, cm);
                    }
                }
            }
            
            for(Registration__c registration : newRegistrations) {

                //12/23/2020 - Victor Hanson - only populate registered automatically if there isn't an approval reason that needs manual review & this is an insert.
                if (mapOfCampaignMembers.containsKey(registration.Contact__c) && String.isBlank(registration.Approval_Reason__c) && oldRegistrations == null) {
                    registration.Status__c = Constants.REGISTRATION_STATUS_REGISTERED;
                    registration.Approval_Status__c = Constants.KEYWORD_APPROVED;
                }
                
                if(registration.EAB_Event__c != null && registration.Approval_Status__c == Constants.KEYWORD_APPROVED && (oldRegistrations == null || registration.Approval_Status__c != oldRegistrations.get(registration.Id).Approval_Status__c)) {
                    
                    Advisory_Event__c eabEvent = mapOfEABEvent.get(registration.EAB_Event__c);
                    
                    if(eabEvent.Approval_Required__c) {
                        
                        //don't overwrite with manual if a value already exists (ie: Auto-Approve Partner)
                        if (registration.Approval_Type__c == null)
                            registration.Approval_Type__c = Constants.REGISTRATION_APPROVAL_TYPE_MANUAL;
                        
                        if(mapOfCampaigns.containsKey(eabEvent.Invite_List__c) && registration.Contact__c != null && mapOfCampaignMembers.containsKey(registration.Contact__c)) {

                            registration.Approval_Type__c = Constants.REGISTRATION_APPROVAL_TYPE_INVITE_LIST;
                        }
                    }
                }
                                                                                   
            }
        }
        
        //Modified - Saurabh Kumar - 04/19/2021 - CR-20210318-15005: Moved "Populate the Registration's Status Field Value" process builder logic to this method: Start
        //Modified - Chirag Soni - 05/20/2021 - CR-20210318-15005 : UAT Issues (MRS2.0) - If Registration Approval status = Approved and Registration status is not equal to Attended then registration status must be registered.
        //Modified - Chirag Soni - 05/26/2021 - CR-20210318-15005 : UAT Issues (MRS2.0) - If Registration Approval status = Approved and Registration status is not equal to Cancelled then registration status must be registered.  
        //Modified - Chirag Soni - 06/15/2021 - CR-20210318-15005 - Critical : UAT Issues (MRS2.0)  #58 - If Registration Approval status = Approved and Registration status equal to Registration Requested then only registration status must be registered

        for(Registration__c registration : newRegistrations){
            
            
            //Added by - Chirag Soni - CR-20210625-15241 - UAT issue fixes - condition to check if registration is created via Inherit all from parent.
            if(oldRegistrations == null && registration.Parent_Registration__c != null)
            continue;
                
            if(registration.Status__c == Constants.REGISTRATION_STATUS_REGISTRATION_REQUESTED && (oldRegistrations == null || oldRegistrations.get(registration.Id).Status__c != registration.Status__c))
                registration.Registration_Request_Date__c = System.today();
            
            //Added by - Chirag Soni - CR-20210606-15193 - 02/24/2022 - from here 
            if(registration.Status__c == Constants.REGISTRATION_STATUS_REGISTERED && (oldRegistrations == null || oldRegistrations.get(registration.Id).Status__c != registration.Status__c))
                registration.Registered_on_Date__c = System.today();
            //Added by - Chirag Soni - CR-20210606-15193 - 02/24/2022 - till here
            
            if(registration.Approval_Status__c == Constants.KEYWORD_APPROVED && registration.Status__c == Constants.REGISTRATION_STATUS_REGISTRATION_REQUESTED && (oldRegistrations == null || oldRegistrations.get(registration.Id).Approval_Status__c != registration.Approval_Status__c))
            {
                registration.Status__c = Constants.REGISTRATION_STATUS_REGISTERED;
            } 
            
            //Modified - Chirag Soni - 06/29/2021 - CR-20210625-15241 : modified approval status = waitlist and approval status = declined check in populateRegistrationField() method - Start
            if(registration.Approval_Status__c == Constants.REGISTRATION_APPROVAL_STATUS_WAITLIST && (oldRegistrations == null || oldRegistrations.get(registration.Id).Approval_Status__c != registration.Approval_Status__c)){
                
                registration.Status__c = Constants.REGISTRATION_STATUS_WAITLIST;
                registration.Declined_Reason__c = Constants.REGISTRATION_WAITLIST_DECLINED_REASON_EVENT_REG_CAPACITY;
            }
            
            if(registration.Approval_Status__c == Constants.REGISTRATION_APPROVAL_STATUS_DECLINED && (oldRegistrations == null || oldRegistrations.get(registration.Id).Approval_Status__c != registration.Approval_Status__c)){
                
                registration.Status__c = Constants.REGISTRATION_STATUS_DECLINED; 
                registration.Declined_Reason__c = Constants.REGISTRATION_WAITLIST_DECLINED_REASON_EVENT_REG_CAPACITY;
            }
            //Modified - Chirag Soni - 06/29/2021 - CR-20210625-15241 : modified approval status = waitlist and approval status = declined check in populateRegistrationField() method - End    
        }
        //Modified - Saurabh Kumar - 04/19/2021 - CR-20210318-15005: Moved "Populate the Registration's Status Field Value" process builder logic to this method: End
    }
    
    /**
     *  @description    :   This method is used to create Registration for each child EAB Events
     *                      Logic: When a registration is created, check if the EAB Event has any Child EAB Events. 
     *                             Create Registrations for each child EAB Event where Mirror Registrations = 'Child Inherits All Parent'
     * 
     *  @args           :   List<Registration__c> newRegistrations
     * 
     *  @return         :   Void
     * 
     *  @revision Log   :   V1.0 Created - Saurabh Kumar - 10/26/2020 - CR-20200821-14454
     * 			:   V1.1 Updated - Saurabh Kumar - 02/18/2021 - CR-20210217-14921 : Update where clause to avoid registration creation for closed event.
     *		        :   V1.2 Updated - Chirag Soni - 09/08/2021 - CR-20210902-15405 - UAT issue fixes - To insert or update multiple registration on child
     *			:   V1.3 Updated - Chirag Soni - 10/28/2021 - CR-20210511-15137 - Added a Logic to Create Elevated meal registration records when EAB Event is Elevated Meal
     * 
     * */
    public static void createRegistrationsForChildEABEvents(List<Registration__c> newRegistrations){
        
        //Map to hold Registration by EAB Event Ids
        //Modified By - Chirag Soni - CR-20210902-15405 - 09/08/2021 - Updated the value from registration to list of registrations
        Map<Id, List<Registration__c>> registrationsByEABEventIds = new Map<Id, List<Registration__c>>();
        
        for(Registration__c reg : newRegistrations){
            //Updated By - Chirag Soni - CR-20210902-15405 - 09/08/2021 - UAT issue fixes - To insert or update multiple registration on child - From Here
            if(reg.EAB_Event__c != null && !registrationsByEABEventIds.ContainsKey(reg.EAB_Event__c))
                registrationsByEABEventIds.put(reg.EAB_Event__c, new List<Registration__c>());
            //Added By - Chirag Soni
            if(registrationsByEABEventIds.ContainsKey(reg.EAB_Event__c))
            	registrationsByEABEventIds.get(reg.EAB_Event__c).add(reg);
            //Updated By - Chirag Soni - CR-20210902-15405 - 09/08/2021 - UAT issue fixes - To insert or update multiple registration on child - Till Here
        }
       
        if(registrationsByEABEventIds.size() == 0)
            return;
        
        //Map to hold registration which should be created
        
        //Commented By - Chirag Soni - 09/08/2021 - CR-20210902-15405 - UAT issue fixes - Updated the Map to list of registration
        //Map<Id, Registration__c> registrationsByEABEventToInsert = new Map<Id, Registration__c>();
        
        //Added By - Chirag Soni - 09/08/2021 - CR-20210902-15405 - UAT issue fixes - add the list to hold registrations
        List<Registration__c> registrationsByEABEventToInsert = new List<Registration__c>();
        
        //Updated - Saurabh Kumar - 02/18/2021 - CR-20210217-14921: Added AND Status__c NOT IN : SET_OF_REGISTRATION_STATUS_COMPLETED
        //Query on EAB Event
        //Modified By - Chirag Soni -  10/28/2021 - CR-20210511-15137 - included the RecordTypeId in the query
        for(Advisory_Event__c eabEvent : [Select Id, RecordTypeId, Mirror_Registrations__c, Parent_Event__c From Advisory_Event__c Where Parent_Event__c != null AND Mirror_Registrations__c =: Constants.EAB_EVENT_INHERI_REGISTRATION_INHERIT_ALL_FROM_PARENT
                                          AND Parent_Event__c IN : registrationsByEABEventIds.keySet() AND Status__c NOT IN : SET_OF_REGISTRATION_STATUS_COMPLETED]){
          //Added By - Chirag Soni - 09/08/2021 - CR-20210902-15405 - UAT issue fixes - To insert or update multiple registration on child
          if(registrationsByEABEventIds != null && registrationsByEABEventIds.get(eabEvent.Parent_Event__c) != null){
              for(Registration__c parentRegistration: registrationsByEABEventIds.get(eabEvent.Parent_Event__c)){                             
                    
                    Registration__c reg = parentRegistration.clone();
                    //Commented By - Chirag Soni - 09/08/2021 - CR-20210902-15405 - UAT issue fixes
                    //Registration__c reg = registrationsByEABEventIds.get(eabEvent.Parent_Event__c).clone();
                    //12/23/2020 - CR-20200821-14454 - Victor Hanson - populate parent registration lookup
                    reg.Parent_Registration__c = parentRegistration.Id;
                    reg.EAB_Event__c = eabEvent.Id;
                    reg.Duplicate_Matching__c = reg.Contact__c + '-' + reg.EAB_Event__c;
                    reg.Automated_Update__c = true;
                  	
                    //Added By -  Chirag Soni -  08/10/2021 - CR-20210511-15137 - Create Elevated meal registration records when EAB Event is Elevated Meal - From Here
                    if(eabEvent.RecordTypeId == Constants.RECORD_TYPE_ID_EAB_EVENT_ELEVATED_MEAL){
                        reg.RecordTypeId = Constants.REGISTRATION_RECORD_TYPE_ELEVATED_MEAL;
                        registrationsByEABEventToInsert.add(reg);
                    }
                    else
                        registrationsByEABEventToInsert.add(reg);
                    //Added By -  Chirag Soni -  08/10/2021 - CR-20210511-15137 - Create Elevated meal registration records when EAB Event is Elevated Meal - Till Here
                    
                    //Commented By - Chirag Soni - 09/08/2021 - CR-20210902-15405 - UAT issue fixes
                    //registrationsByEABEventToInsert.put(eabEvent.Id, reg);
                    
                    //Added By - Chirag Soni - 09/08/2021 - CR-20210902-15405 - UAT issue fixes - Adding registrations to registrationsByEABEventToInsert
                    //Commented by - Chirag Soni - 10/28/2021 - CR-20210511-15137 - Moved the below line into the above if condition
                    //registrationsByEABEventToInsert.add(reg);
                }
          }
        } 
        
        if(registrationsByEABEventToInsert.size() > 0){
            //Util.BypassAllTriggers = true;
            bypassRegistrationDLRS = true;
            //Added By - Chirag Soni - 09/08/2021 - CR-20210902-15405 - insert list of registration
            insert registrationsByEABEventToInsert;
            bypassRegistrationDLRS = false;
            //Util.BypassAllTriggers = false;
            
         }
    }
    
    /**
     *  @description    :   This method is used to validate registration records
     *                      Logic: When a registration is created on an EAB Event where Mirror Registrations = 'Parent registrants eligible'
     *                             Check if there is a Registration on the parent EAB Event for that Contact. If not, do not allow them to register 
     *                             (error message: Contact not eligible because they are not registered for parent event.)
     * 
     *  @args           :   List<Registration__c> newRegistrations
     * 
     *  @return         :   Void
     * 
     *  @revision Log   :   V1.0 Created - Saurabh Kumar - 10/27/2020 - CR-20200821-14454
     * 
     * */
    public static void validateRegistrations(List<Registration__c> newRegistrations){
        
        //Set to hold EAB Event Ids
        Set<Id> eabEventIds = new Set<Id>();
        
        for(Registration__c reg : newRegistrations){
            if(reg.EAB_Event__c != null && reg.Contact__c != null)
                eabEventIds.add(reg.EAB_Event__c);
        }
        
        //Map to hold current EAB Event
        Map<Id, Advisory_Event__c> eabEvents = new Map<Id, Advisory_Event__c>();
        
        //Set to hold Parent EAB Event Id
        Set<Id> parentEABEventId = new Set<Id>();
        
        //Query on Current EAB Event
        for(Advisory_Event__c eabEvent : [Select Id, Mirror_Registrations__c, Parent_Event__c From Advisory_Event__c Where Id IN : eabEventIds]){
            
            eabEvents.put(eabEvent.Id, eabEvent);
            if(eabEvent.Parent_Event__c != null)
                parentEABEventId.add(eabEvent.Parent_Event__c);
        }
        //Query on parent EAB Event and it's registrations
        Map<Id, Advisory_Event__c> parentEABEvents = new Map<Id, Advisory_Event__c>([Select Id, (Select Id, Contact__c From Registrations__r) From Advisory_Event__c Where Id IN : parentEABEventId]);
        
        //Process on new Registrations to validate
        for(Registration__c reg : newRegistrations){
            
            if(reg.EAB_Event__c == null || reg.Contact__c == null || eabEvents.get(reg.EAB_Event__c).Mirror_Registrations__c != Constants.EAB_EVENT_INHERI_REGISTRATION_PARENT_REGISTRATIONS_ELIGIBLE)
                continue;
            if(eabEvents.get(reg.EAB_Event__c).Parent_Event__c == null || !parentEABEvents.containsKey(eabEvents.get(reg.EAB_Event__c).Parent_Event__c) || 
               parentEABEvents.get(eabEvents.get(reg.EAB_Event__c).Parent_Event__c).Registrations__r.size() == 0){
                   if(reg.RecordTypeId != Constants.REGISTRATION_RECORD_TYPE_ID_INTERNAL_ATTENDEE)
                        reg.addError(Label.ERROR_CONTACT_NOT_ELIGIBLE_FOR_REGISTRATION);
            }else{
                Boolean isRegistrationUnderParentEABEventForTheContact = false;
                for(Registration__c existingReg : parentEABEvents.get(eabEvents.get(reg.EAB_Event__c).Parent_Event__c).Registrations__r){
                    
                    if(existingReg.Contact__c == reg.Contact__c){
                        isRegistrationUnderParentEABEventForTheContact = true;
                        break;
                    }
                }
                if(!isRegistrationUnderParentEABEventForTheContact && reg.RecordTypeId != Constants.REGISTRATION_RECORD_TYPE_ID_INTERNAL_ATTENDEE)
                    reg.addError(Label.ERROR_CONTACT_NOT_ELIGIBLE_FOR_REGISTRATION);
            }
            
        }
    }
    
    /**
     *  @description    :   This method is used to auto populate registration fields
     *                      Logic: https://app.lucidchart.com/invitations/accept/bf8c77cc-4896-4858-add1-0a88a4554640
     * 
     *  @args           :   List<Registration__c> newRegistrations
     * 
     *  @return         :   Void
     * 
     *  @revision Log   :   V1.0 Created - Saurabh Kumar - 10/27/2020 - CR-20200821-14454
     * 			    V1.1 Updated - Victor Hanson - 02/16/2021 - CR-20210211-14905 - Update Approval_Reason__c field value from "All Require Approval" to "No Partnership".
     * 			    V1.2 Updated - Saurabh Kumar - 02/19/2021 - CR-20210217-14921 - Assigned Registration Status is Registered default in case of Salesforce registration.
     * 			    V1.3 Updated - Saurabh Kumar - 03/09/2021 - CR-20210308-14971 - Removed inline query and inner loop to resolve " Aggregate query has too many rows" error.
     *		            V1.4 Updated - Chirag Soni  - 07/29/2021 - CR-20210526-15185 - update the approval status to approved and approval reason to null when registration is in invite list. 
     * */
    public static List<Registration__c> populateStatusAndApprovalReason(List<Registration__c> newRegistrations){
        
        //Set to hold EAB Event Ids
        Set<Id> eabEventIds = new Set<Id>();
        
        //Map to hold EAB Events
        Map<Id, Advisory_Event__c> mapOfEABEvents = new Map<Id, Advisory_Event__c>();
        
        //Set to hold Campaign Ids
        Set<Id> campaignIds = new Set<Id>();
        
        //Map to hold Campaign
        Map<Id, Campaign> mapOfCampaigns = new Map<Id, Campaign>();
        
        //Set to hold contact Ids
        Set<Id> contactIds = new Set<Id>();
        
        //Map to hold contacts
        Map<Id, Contact> mapOfContacts = new Map<Id, Contact>();
        
        //V1.3 Updated - Saurabh Kumar - 03/09/2021 - CR-20210308-14971: Added
        Map<Id, List<Registration__c>> registrationsByEABEvent = new Map<Id, List<Registration__c>>();
        
        for(Registration__c reg : newRegistrations){
            
            if(reg.EAB_Event__c != null)
                eabEventIds.add(reg.EAB_Event__c);
            if(reg.Contact__c != null)
                contactIds.add(reg.Contact__c);
        }

        //map of institution to number of registrants
        Map<String, Integer> mapAcctIdToNumRegs = new Map<String, Integer>();
        
        //Query on EAB Event
        if(eabEventIds.size() > 0){
            
            //V1.3 Updated - Saurabh Kumar - 03/09/2021 - CR-20210308-14971: Added a map and fill it by doing query: Start
            for(Registration__c reg : [Select Id, Contact__c, Contact__r.AccountId, Status__c, EAB_Event__c From Registration__c WHERE Status__c = :Constants.REGISTRATION_STATUS_REGISTERED AND EAB_Event__c IN : eabEventIds]){
                
                if(!registrationsByEABEvent.containsKey(reg.EAB_Event__c))
                    registrationsByEABEvent.put(reg.EAB_Event__c, new List<Registration__c>());
                
                registrationsByEABEvent.get(reg.EAB_Event__c).add(reg);
            }
            //V1.3 Updated - Saurabh Kumar - 03/09/2021 - CR-20210308-14971: Added a map and fill it by doing query: End
            
            //2/16/2021 - CR-20210211-14905 - Victor Hanson - added Auto_Approve_Partners__c
            //V1.3 Updated - Saurabh Kumar - 03/09/2021 - CR-20210308-14971: Removed follow inline query
            //,(Select Id, Contact__c, Contact__r.AccountId, Status__c From Registrations__r WHERE Status__c = :Constants.REGISTRATION_STATUS_REGISTERED)
            for(Advisory_Event__c eabEvent : [Select Id, Invite_List__c, Cap_Per_Institution__c, Institution__c, Approval_Required__c,Status__c,Auto_Approve_Partners__c From Advisory_Event__c
                                            Where Id IN : eabEventIds]){
                mapOfEABEvents.put(eabEvent.Id, eabEvent);
                if(eabEvent.Invite_List__c != null)
                    campaignIds.add(eabEvent.Invite_List__c);

                //V1.3 Updated - Saurabh Kumar - 03/09/2021 - CR-20210308-14971: Removed inline query list and utilizing map instead.: Start
                if(registrationsByEABEvent.containsKey(eabEvent.Id)){
                    
                    for (Registration__c r : registrationsByEABEvent.get(eabEvent.Id)) {
                        //03/03/2021 - CR-20210303-14965 - Victor Hanson - include EABEvent Id in the key
                        Integer numRegs = mapAcctIdToNumRegs.get(r.Contact__r.AccountId + '-' + eabEvent.Id);
                        if (numRegs == null) numRegs = 0;
                        numRegs++;
                        //03/03/2021 - CR-20210303-14965 - Victor Hanson - include EABEvent Id in the key
                        mapAcctIdToNumRegs.put(r.Contact__r.AccountId + '-' + eabEvent.Id, numRegs);
                    }
                }
               //V1.3 Updated - Saurabh Kumar - 03/09/2021 - CR-20210308-14971: Removed inline query list and utilizing map instead.: End
            }
        }
        
        //Query on Campaign
        if(campaignIds.size() > 0){
            
            mapOfCampaigns = new Map<Id, Campaign>([Select Id, (Select Id, ContactId, Registration__c, Registration__r.Contact__c, Registration__r.Contact__r.AccountId From CampaignMembers) 
                                                   From Campaign Where Id IN : campaignIds]);
        }
        
        //Query on contacts
        if(contactIds.size() > 0){
            
            mapOfContacts = new Map<Id, Contact>([Select Id, AccountId, RecordType.Name From Contact Where Id IN : contactIds]);
        }
        
        //02/17/2021 - CR-20210211-14905 - Victor Hanson - replace query with boolean using new feature management class
        Boolean isEABEventManager = FeatureManagement.checkPermission('EAB_Event');
        //Query on Permission Set Assignment 
        /*List<PermissionSetAssignment> eabEventManagerpermissionSetAssignment = [Select Id FROM PermissionSetAssignment Where PermissionSet.IsOwnedByProfile = False AND 
                                                                 AssigneeId =: UserInfo.getUserId() AND PermissionSet.Name =: Constants.PERMISSION_SET_NAME_ADVISORY_EVENT_MANAGER LIMIT 1];*/
        //Block to populate values in fields
        for(Registration__c reg : newRegistrations){
           
            //Set the institution registration count
            Integer noOfCriteraMatchedRegistration;
            if (mapOfContacts.containsKey(reg.Contact__c)) {
                //03/03/2021 - CR-20210303-14965 - Victor Hanson - include EABEvent Id in the key
                noOfCriteraMatchedRegistration = mapAcctIdToNumRegs.get(mapOfContacts.get(reg.Contact__c).AccountId + '-' + reg.EAB_Event__c);
                //reg.Institution_Registration_Count__c = noOfCriteraMatchedRegistration;
            }

            //03/03/2021 - CR-20210303-14965 - Victor Hanson - commented out below because we added if statement that only processes if Status == null or registration requested
            //02/22/2021 - CR-20210217-14921 - Victor Hanson - if Status is Cancelled or Void, skip setting the Status
            /*if (reg.Status__c == Constants.REGISTRATION_STATUS_CANCELLED || reg.Status__c == Constants.REGISTRATION_STATUS_VOID || reg.Status__c == REGISTRATION_STATUS_REGISTERED) {
                continue;
            }*/

            //03/03/2021 - CR-20210303-14965 - Victor Hanson - prevents automated recalculation of Status unless Status == null OR Status == Registration Requested 
            if (reg.Status__c == null || reg.Status__c == Constants.REGISTRATION_STATUS_REGISTRATION_REQUESTED) {

                //02/22/2021 - CR-20210217-14921 - Victor Hanson - Added parent reg == null check because child registrations should receive Status from parent
                if(reg.Origin__c == Constants.REGISTRATION_ORIGIN_SALESFORCE && reg.Parent_Registration__c == null){
                    
                    //03/03/2021 - CR-20210303-14964 - Victor Hanson - added reg.status check to prevent null status value
                    //02/17/2021 - CR-20210211-14905 - Victor Hanson - added isEABEventManager
                    if(reg.Status__c != null && (isEABEventManager || reg.Automated_Update__c)){
                        //Do nothing
                        
                    } else if(reg.EAB_Event__c != null && mapOfEABEvents.containsKey(reg.EAB_Event__c)) {
                        
                        if(mapOfEABEvents.get(reg.EAB_Event__c).Status__c == Constants.EAB_EVENT_STATUS_OPEN_REGISTRATION)
                             reg.Status__c = Constants.REGISTRATION_STATUS_REGISTERED;
                        else if(mapOfEABEvents.get(reg.EAB_Event__c).Status__c == Constants.EAB_EVENT_STATUS_OPEN_WAITLIST_ONLY) {
                            //03/11/2021 - CR-20210311-14986 - Victor Hanson - added approval status & declined reason to prevent validation rule from firing during update
                            reg.Approval_Status__c = 'Waitlist';
                            reg.Declined_Reason__c = 'Event Reg Capacity';
                            reg.Status__c = Constants.REGISTRATION_STATUS_WAITLIST;
                        }
                        
                        //Commented By - Mahendra Swarnakar - 03/04/2021 - CR-20210301-14956 - Error when trying to edit any fields on Cappex Membership pages
                        /*else
                            reg.addError(Label.ERROR_REGISTRATION_CAN_NOT_SAVE);*/
                    }
                    
                }//02/23/2021 - CR-20210217-14921 - Victor Hanson - modified else if below to include Partner Status requirement.  This prevents unnecessary updates
                else if(reg.Origin__c == Constants.REGISTRATION_ORIGIN_EAB_DOT_COM && reg.Parent_Registration__c == null && reg.Partner_Status__c != null){

                    //03/03/2021 - CR-20210303-14965 - Victor Hanson - include EABEvent Id in the mapAcctIdToNumReg key
                    //if over institution cap, set status & approval reason, and return
                    if(mapOfEABEvents.containsKey(reg.EAB_Event__c) 
                        && mapOfEABEvents.get(reg.EAB_Event__c).Cap_Per_Institution__c != null 
                       
                        //V1.3 Updated - Saurabh Kumar - 03/09/2021 - CR-20210308-14971: Map replaced from mapOfEABEvents to registrationsByEABEvent
                        && registrationsByEABEvent.containsKey(reg.EAB_Event__c) && registrationsByEABEvent.get(reg.EAB_Event__c).size() > 0 //mapOfEABEvents.get(reg.EAB_Event__c).Registrations__r.size() > 0
                        && reg.Contact__c != null 
                        && mapOfContacts.get(reg.Contact__c).AccountId != null 
                        && mapOfContacts.get(reg.Contact__c).RecordType.Name != Constants.CONTACT_RECORD_TYPE_DEVELOPER_NAME_EMPLOYEE
                        && mapAcctIdToNumRegs.containsKey(mapOfContacts.get(reg.Contact__c).AccountId + '-' + reg.EAB_Event__c)
                        && noOfCriteraMatchedRegistration >= mapOfEABEvents.get(reg.EAB_Event__c).Cap_Per_Institution__c) 
                    {
                        reg.Status__c = Constants.REGISTRATION_STATUS_REGISTRATION_REQUESTED;
                        reg.Approval_Reason__c = Constants.REGISTRATION_APPROVAL_REASON_OVER_INSTITUTION_CAP;
                        reg.Approval_Status__c = null;
                    }
                    else if(reg.EAB_Event__c == null || !mapOfEABEvents.containsKey(reg.EAB_Event__c) || !mapOfEABEvents.get(reg.EAB_Event__c).Approval_Required__c){
                        reg.Status__c = Constants.REGISTRATION_STATUS_REGISTERED;
                        
                    }else{
                        reg.Status__c = Constants.REGISTRATION_STATUS_REGISTERED;
                        
                        if (reg.Partner_Status__c == Constants.REGISTRATION_PARTNER_STATUS_PARTNER 
                            && mapOfEABEvents.get(reg.EAB_Event__c) != null 
                            && mapOfEABEvents.get(reg.EAB_Event__c).Auto_Approve_Partners__c) 
                        {
                            //do nothing -- leave status as registered
                        }
                        else if(reg.EAB_Event__c == null || reg.Contact__c == null || mapOfEABEvents.size() == 0 || !mapOfEABEvents.containsKey(reg.EAB_Event__c) || 
                            mapOfEABEvents.get(reg.EAB_Event__c).Invite_List__c == null || mapOfCampaigns.get(mapOfEABEvents.get(reg.EAB_Event__c).Invite_List__c).CampaignMembers.size() == 0)
                        {
                            
                            reg.Status__c = Constants.REGISTRATION_STATUS_REGISTRATION_REQUESTED;
                            
                            //only set this status if EAB Event has an Invite List
                            if (reg.EAB_Event__c != null && mapOfEABEvents.get(reg.EAB_Event__c)?.Invite_List__c != null) {
                                reg.Approval_Reason__c = Label.REGISTRATION_APPROVAL_REASON_NOT_ON_INVITE_LIST;
                            	//Chirag Soni  - 07/29/2021 - CR-20210526-15185 - added 
                           	reg.Approval_Status__c = null;
                            }
                        }
                        else
                        {
                            Boolean isContactExistsUnderCampaign = false;
                            
                            if(mapOfEABEvents.containsKey(reg.EAB_Event__c) && mapOfCampaigns.containsKey(mapOfEABEvents.get(reg.EAB_Event__c).Invite_List__c)){
                                
                                for(CampaignMember cm : mapOfCampaigns.get(mapOfEABEvents.get(reg.EAB_Event__c).Invite_List__c).CampaignMembers){
                                
                                    //if(cm.Registration__c != null && cm.Registration__r.Contact__c != null && cm.Registration__r.Contact__c == reg.Contact__c){
                                    if(cm.ContactId != null && cm.ContactId == reg.Contact__c){
                                        isContactExistsUnderCampaign = true;
                                        break;
                                    }
                                }
                            }

                            if(!isContactExistsUnderCampaign){
                                
                                reg.Status__c = Constants.REGISTRATION_STATUS_REGISTRATION_REQUESTED;

                                //only set this status if EAB Event has an Invite List
                                if (reg.EAB_Event__c != null && mapOfEABEvents.get(reg.EAB_Event__c)?.Invite_List__c != null) {
                                    reg.Approval_Reason__c = Label.REGISTRATION_APPROVAL_REASON_NOT_ON_INVITE_LIST;
                                    //Chirag Soni  - 07/29/2021 - CR-20210526-15185 - added 
                                    reg.Approval_Status__c = null;
                                }
                                
                            }
                            else{
                                    reg.Status__c = Constants.STATUS_REGISTERED;
	                            //Chirag Soni  - 07/29/2021 - CR-20210526-15185 - added 
	                            reg.Approval_Status__c = Constants.KEYWORD_APPROVED;
	                            reg.Approval_Reason__c = null;
                            }
                        }
                    }

                    //02/23/2021 - CR-20210217-14921 - Victor Hanson - added
                    if (mapOfEABEvents.get(reg.EAB_Event__c).Status__c == Constants.EAB_EVENT_STATUS_OPEN_WAITLIST_ONLY) {
                        if (reg.Status__c == Constants.REGISTRATION_STATUS_REGISTERED) {
                            reg.Approval_Status__c = 'Waitlist';
                            reg.Declined_Reason__c = 'Event Reg Capacity';
                            reg.Status__c = Constants.REGISTRATION_STATUS_WAITLIST;
                        }
                        else {
                            reg.Status__c = Constants.REGISTRATION_STATUS_REGISTRATION_REQUESTED;
                        }
                    }
                }
            }

            //if status is Registration Requested, approval is required, and approval reason is blank, populate with generic 'All Require Approval' value
            if (mapOfEABEvents.containsKey(reg.EAB_Event__c) 
                && mapOfEABEvents.get(reg.EAB_Event__c).Approval_Required__c 
                && reg.Status__c == Constants.REGISTRATION_STATUS_REGISTRATION_REQUESTED
                && reg.Approval_Reason__c == null) 
            {
                //V1.1 Updated - Saurabh Kumar - 02/11/2021 - CR-20210211-14905 - Update Approval_Reason__c field value from "All Require Approval" to "No Partnership".
                //reg.Approval_Reason__c = REGISTRATION_APPROVAL_REASON_NO_PARTNERSHIP;

                //02/16/2021 - CR-20210211-14905 - Victor Hanson - Partner Status determines Approval Reason
                if (reg.Partner_Status__c == Constants.REGISTRATION_PARTNER_STATUS_PARTNER
                    || mapOfEABEvents.get(reg.EAB_Event__c).Auto_Approve_Partners__c == false) {
                    reg.Approval_Reason__c = Constants.REGISTRATION_APPROVAL_REASON_ALL_REQUIRE_APPROVAL;
                }
                else {
                    reg.Approval_Reason__c = REGISTRATION_APPROVAL_REASON_NO_PARTNERSHIP;
                }
            }
        }
        return newRegistrations;
    }
    
    /**
     *  @description    :   This method is used to auto populate Campaign Member's Registration field
     *                      Logic: When a Registration is created and a corresponding Campaign Member exists, update the CampaignMember.Registration__c with the registration id.
     * 
     *  @args           :   Map<Id, Registration__c> newRegistrations
     * 
     *  @return         :   Void
     * 
     *  @revision Log   :   V1.0 Created - Saurabh Kumar - 10/28/2020 - CR-20200821-14454
     *                      V1.1 Modified By - Saurabh Kumar - 04/08/2021 - CR-20210324-15021
     * 
     * */
    public static void populateCampaignMemberRegistrationField(Map<Id, Registration__c> newRegistrations){
        
        //Set to hold Contact Id
        Set<Id> contactIds = new Set<Id>();
        
        //Set to hold EAB Event Ids
        Set<Id> eabEventIds = new Set<Id>();
        
        //Map to hold Contacts
        Map<Id, Contact> mapOfContacts = new Map<Id, Contact>();
        
        //Map to hold EAB Event
        Map<Id, Advisory_Event__c> mapOfEABEvents = new Map<Id, Advisory_Event__c>();
        
        //Map to hold Campaign Memebr to update
        Map<Id, CampaignMember> mapOfCampaignMembers = new Map<Id, CampaignMember>();
        
        for(Registration__c reg : newRegistrations.values()){
            
            if(reg.Contact__c != null)
                contactIds.add(reg.Contact__c);
            if(reg.EAB_Event__c != null)
                eabEventIds.add(reg.EAB_Event__c);
        }
        
        //Query on Contact
        if(contactIds.size() > 0){
            mapOfContacts = new Map<Id, Contact>([Select Id, (Select Id, CampaignId, Registration__c From CampaignMembers) From Contact Where Id IN : contactIds]);
        }
        
        //Query on EAB Event
        if(eabEventIds.size() > 0){
            mapOfEABEvents = new Map<Id, Advisory_Event__c>([Select Id, Invite_List__c From Advisory_Event__c Where Id IN : eabEventIds]);
        }
        
        //Block to process and populate Registration on Campaign Member 
        for(Registration__c reg : newRegistrations.values()){
            
            if(reg.Contact__c == null || reg.EAB_Event__c == null)
                continue;
            for(CampaignMember cm : mapOfContacts.get(reg.Contact__c).CampaignMembers){ 
            
                
                if(cm.Registration__c != null)
                    continue;
                Advisory_Event__c eabEvent = mapOfEABEvents.get(reg.EAB_Event__c);
                
                if(eabEvent.Invite_List__c == cm.CampaignId)
                    //V1.1 Modified By - Saurabh Kumar - 04/08/2021 - CR-20210324-15021
                    mapOfCampaignMembers.put(cm.Id, new CampaignMember(Id = cm.Id, Registration__c = reg.Id));
                   // mapOfCampaignMembers.put(eabEvent.Invite_List__c, new CampaignMember(Id = cm.Id, Registration__c = reg.Id));
                   
                   
            }
        }
        
        if(mapOfCampaignMembers.size() > 0){
            Util.BypassAllTriggers = true;
            update mapOfCampaignMembers.values();
            Util.BypassAllTriggers = false;
        }
    }
    
    /**
     *  @description    :   This method is used to update Child EAB Event's Registration status
     *                      Logic: When a Registration's Status is updated & the related EAB Event has any child EAB Events.
     *                             Get all Registrations on the Child EAB Events where Mirror Registrations = 'Child Inherits All Parent' 
     *                              & Status is equal to the parent registration's original status.
     *                             Update those Registration's Status to the updated Status value (Approved, Cancelled, or VOID)
     *
     * 
     *  @args           :   List<Registration__c> newRegistrations, Map<Id, Registration__c> oldRegistrations
     * 
     *  @return         :   Void
     * 
     *  @revision Log   :   V1.0 Created - Saurabh Kumar - 11/05/2020 - CR-20200821-14454
     *                  :   V1.1 Modified - Chirag Soni - 07/29/2021 - CR-20210526-15185 - commented the mapOfRegistrationByEABEventId, removed its all references and added new map because we can have multiple registrations on single eab event id
     *                  :   V1.2 Modified - Chirag Soni - 12/14/2021 - CR-20211214-15632 - added Util.bypass check before updating the child registration records 
     * 			:   V1.3 Modified - Chirag Soni - 01/04/2022 - CR-20211224-15650 - Added parentReg not null check in if condition. 
     * */
    public static void updateRelatedRegistrationStatus(List<Registration__c> newRegistrations, Map<Id, Registration__c> oldRegistrations){
        
        //07/29/2021 - CR-20210526-15185 - Chirag Soni - Commented this line because we can have multiple registrations on same event id.
        //Map to hold updated Registration by EAB Event
        //Map<Id, Registration__c> mapOfRegistrationByEABEventId = new Map<Id, Registration__c>();
        
        //07/29/2021 - CR-20210526-15185 - Chirag Soni - added.
        Map<Id, Registration__c> mapOfRegistrationById = new Map<Id, Registration__c>();
        Set<Id> parentEventIds = new Set<Id>();
        
        Set<Id> contactIds = new Set<Id>();
        
        //Map to hold Registrations to update
        Map<Id, Registration__c> registrationsToUpdate = new Map<Id, Registration__c>();
        
        for(Registration__c reg : newRegistrations){
            
            if(reg.Status__c != null && reg.EAB_Event__c != null &&
               (oldRegistrations == null || (reg.Status__c != oldRegistrations.get(reg.Id).Status__c) )){
                     
                   //07/29/2021 - CR-20210526-15185 - Chirag Soni - Commented this line because we can have multiple registrations on same event id.
                   //mapOfRegistrationByEABEventId.put(reg.EAB_Event__c, reg);
                   
                   contactIds.add(reg.Contact__c);
                   
                   //07/29/2021 - CR-20210526-15185 - Chirag Soni - added.
                   mapOfRegistrationById.put(reg.Id, reg);
                   parentEventIds.add(reg.EAB_Event__c);
               }
        }
        
        if(mapOfRegistrationById.size() == 0)
            return;
       
        //Query on child EAB Event's registrations
        for(Registration__c reg : [Select Id, Status__c, EAB_Event__c, Parent_Registration__c, Cancellation_Reason__c, Approval_Status__c, Declined_Reason__c, Approval_Reason__c
                                    ,Partner_Status__c, Automated_Update__c From  Registration__c 
                                    Where EAB_Event__c != null 
                                    AND EAB_Event__r.Parent_Event__c != null 
                                    AND EAB_Event__r.Mirror_Registrations__c =: Constants.EAB_EVENT_INHERI_REGISTRATION_INHERIT_ALL_FROM_PARENT
                                    AND EAB_Event__r.Parent_Event__c IN : parentEventIds AND Contact__c IN :contactIds])  //07/29/2021 - CR-20210526-15185 - Chirag Soni - removed mapOfRegistrationByEABEventId.keySet() and EAB_Event__r.Parent_Event__c.
        {
            Registration__c parentReg = mapOfRegistrationById.get(reg.Parent_Registration__c); //07/29/2021 - CR-20210526-15185 - Chirag Soni - modified 
            Registration__c oldParentReg;
            if (parentReg != null)
                oldParentReg = oldRegistrations?.get(parentReg.Id);
            
            //03/11/2021 - CR-20210311-14986 - Victor Hanson - modified if statement to populate child status with parent value if child status is reg requested
            //03/03/2021 - CR-20210303-14964 - Victor Hanson - added check for oldParentReg.Status__c == null
            //if old parent registration satus matches child registration status and the parent registration status is changed, update the child status to match
            //01/04/2022 - Chirag Soni - 01/04/2022 - CR-20211224-15650 - Added parentReg not null check in if condition.
           if(parentReg != null && parentReg.Status__c != reg.Status__c &&(oldParentReg == null || oldParentReg.Status__c == null || oldParentReg.Status__c == reg.Status__c || reg.Status__c == Constants.REGISTRATION_STATUS_REGISTRATION_REQUESTED))
                //07/29/2021 - CR-20210526-15185 - Chirag Soni - modified removed reference of mapOfRegistrationByEABEventId. 
               
           
                registrationsToUpdate.put(reg.Id, new Registration__c(Id = reg.Id, 
                                                                     //Added - CR-20210606-15193 - Chirag Soni - 02/24/2022
                                                                     Registered_on_Date__c = mapOfRegistrationById.get(reg.Parent_Registration__c).Registered_on_Date__c,
                                                                     Status__c = mapOfRegistrationById.get(reg.Parent_Registration__c).Status__c,
                                                                     Cancellation_Reason__c =  mapOfRegistrationById.get(reg.Parent_Registration__c).Cancellation_Reason__c,
                                                                     Approval_Status__c =  mapOfRegistrationById.get(reg.Parent_Registration__c).Approval_Status__c,
                                                                     Declined_Reason__c =  mapOfRegistrationById.get(reg.Parent_Registration__c).Declined_Reason__c,
                                                                     Approval_Reason__c = mapOfRegistrationById.get(reg.Parent_Registration__c).Approval_Reason__c,
                                                                     Automated_Update__c = true));
        }
        
        if(registrationsToUpdate.size() > 0){
            
            //02/07/2021 - CR-20210207-14880 - Victor Hanson - removed bypassAllTriggers
            //12/14/2021 - CR-20211214-15632 - Chirag Soni - Added Util.bypassAllTriggers = true;
            //Util.bypassAllTriggers = true;
            bypassRegistrationDLRS = true;
            bypasspopulateInstitutionRegistrationCount = true;
            update registrationsToUpdate.values();
            bypasspopulateInstitutionRegistrationCount = false;
            bypassRegistrationDLRS = false;
            //12/14/2021 - CR-20211214-15632 - Chirag Soni - Added Util.bypassAllTriggers = false
            //Util.bypassAllTriggers = false;

        }
    }
    
    /**
     *  @description    :   This method is used to update Institution Registration count.
     *                      Logic: Registration count should be the sum of all Registrations for that EAB Events where the Contact's Instituton 
     * 			    is the same and Status=Registered.
     *
     * 
     *  @args           :   List<Registration__c> newRegistrations, Map<Id, Registration__c> oldRegistrations
     * 
     *  @return         :   Void
     * 
     *  @revision Log   :   V1.0 Created - Saurabh Kumar - 01/28/2021 - CR-20200821-14454
     * 
     * */
    public static void populateInstitutionRegistrationCount(List<Registration__c> newRegistrations, Map<Id, Registration__c> oldRegistrations, boolean isBeforeInsert){
        
        if (bypasspopulateInstitutionRegistrationCount) {
            return;
        }

        //Set to hold EAB Event Ids
        Set<Id> eabEventIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();
        
        for(Registration__c registration : newRegistrations != null ? newRegistrations : oldRegistrations.values()){
            
            if( (oldRegistrations == null || newRegistrations == null) && registration.Contact__c != null && registration.EAB_Event__c != null){
                
                eabEventIds.add(registration.EAB_Event__c);
                contactIds.add(registration.Contact__c);
                
            }else if(oldRegistrations != null && ( ( registration.Status__c == Constants.REGISTRATION_STATUS_REGISTERED
                                                    && (registration.Contact__c != oldRegistrations.get(registration.Id).Contact__c
                                                    || registration.EAB_Event__c != oldRegistrations.get(registration.Id).EAB_Event__c) )
                                                    || (registration.Status__c != oldRegistrations.get(registration.Id).Status__c 
                                                    && (registration.Status__c == Constants.REGISTRATION_STATUS_REGISTERED
                                                    || oldRegistrations.get(registration.Id).Status__c == Constants.REGISTRATION_STATUS_REGISTERED ) ) ) ){

                if(registration.EAB_Event__c != null)
                    eabEventIds.add(registration.EAB_Event__c);
                if(registration.EAB_Event__c != oldRegistrations.get(registration.Id).EAB_Event__c && oldRegistrations.get(registration.Id).EAB_Event__c != null)
                    eabEventIds.add(oldRegistrations.get(registration.Id).EAB_Event__c);
                
                if (registration.Contact__c != null)
                    contactIds.add(registration.Contact__c);
            }
        }
        if(eabEventIds.size() == 0 || contactIds.size() == 0)
            return;
        
        Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT Id, AccountId FROM Contact WHERE Id IN :contactIds]);

        //get contacts so we can find account Ids
        for (Contact c : contactMap.values()) {
            accountIds.add(c.AccountId);
        }
        Map<Id, Registration__c> mapOfRegistrationsToUpdate = new Map<Id, Registration__c>();
        
        //02/23/2021 - CR-20210217-14921 - Victor Hanson - added Institution_Registration_Count__c
        //TODO: Convert to map to avoid aggregate query error
        for(Advisory_Event__c eabEvent : [Select Id, Cap_Per_Institution__c, (Select Id, Status__c, Contact__c, Contact__r.AccountId, Institution_Registration_Count__c From Registrations__r Where Contact__c != null AND Contact__r.AccountId IN :accountIds) FROM Advisory_Event__c WHERE Id IN : eabEventIds]){
            
            Map<Id, Integer> numberOfRegistrationsByAccountId = new Map<Id, Integer>();
            
            //Block to count number of registrations
            for(Registration__c reg : eabEvent.Registrations__r){
                
                if(!numberOfRegistrationsByAccountId.containsKey(reg.Contact__r.AccountId))
                    numberOfRegistrationsByAccountId.put(reg.Contact__r.AccountId, 0);
                if(reg.Status__c == Constants.REGISTRATION_STATUS_REGISTERED)
                    numberOfRegistrationsByAccountId.put(reg.Contact__r.AccountId, numberOfRegistrationsByAccountId.get(reg.Contact__r.AccountId)+1);
            }
            //Block to process the counting
            //03/10/2021 - CR-20210308-14971 - Victor Hanson - Added so we can get the reg count before insert to help with calculating status
            if (isBeforeInsert) {
                for (Registration__c reg : newRegistrations) {
                    Id acctId = contactMap?.get(reg.Contact__c)?.accountId;
                    if (acctId != null)
                        reg.Institution_Registration_Count__c = numberOfRegistrationsByAccountId.get(acctId);
                    
                    if (reg.Institution_Registration_Count__c >= eabEvent.Cap_Per_Institution__c && reg.Parent_Registration__c == null) {
                        reg.Approval_Reason__c = Constants.REGISTRATION_APPROVAL_REASON_OVER_INSTITUTION_CAP;
                        reg.Approval_Status__c = null;
                    }
                }
            }
            else {
                for(Registration__c reg : eabEvent.Registrations__r){

                    //02/23/2021 - CR-20210217-14921 - Victor Hanson - Only update if number of registrations is changing
                    if (reg.Institution_Registration_Count__c != numberOfRegistrationsByAccountId.get(reg.Contact__r.AccountId)) {
                        mapOfRegistrationsToUpdate.put(reg.Id, new Registration__c(
                                                                                Id = reg.Id, 
                                                                                Institution_Registration_Count__c = numberOfRegistrationsByAccountId.get(reg.Contact__r.AccountId),
                                                                                Automated_Update__c = true));
                    }
                    
                }
            }
       }
        if(mapOfRegistrationsToUpdate.size() > 0 && !isBeforeInsert){
            Boolean prevBypassValue = util.BypassAllTriggers;
            Util.ByPassAllTriggers = true;
            bypassRegistrationDLRS = true;
            bypasspopulateInstitutionRegistrationCount = true;
            update mapOfRegistrationsToUpdate.values();
            bypasspopulateInstitutionRegistrationCount = false;
            bypassRegistrationDLRS = false;
            Util.ByPassAllTriggers = prevBypassValue;
        }
    }
    
    /**
     *  @description    :   This method is used to update Is_On_Invite_List__c.
     *                      Logic: Logic that evaluates if the registrant is on the invite list regardless of how their registration is created. 
     * 			    This field would be blank if no invite list.
     *
     * 
     *  @args           :   List<Registration__c> newRegistrations, Map<Id, Registration__c> oldRegistrations
     * 
     *  @return         :   Void
     * 
     *  @revision Log   :   V1.0 Created - Saurabh Kumar - 01/29/2021 - CR-20200821-14465(UAT Issues MRS2.0)
     * 
     * */
    public static void populateIsOnInviteList(List<Registration__c> newRegistrations, Map<Id, Registration__c> oldRegistrations){
        
        //Set to hold EAB Event Ids
        Set<Id> eabEventIds = new Set<Id>();
        
        for(Registration__c reg : newRegistrations){
            
            if((oldRegistrations == null && reg.EAB_Event__c != null && reg.Contact__c != null)
               || (oldRegistrations != null && (reg.EAB_Event__c != oldRegistrations.get(reg.Id).EAB_Event__c || reg.Contact__c != oldRegistrations.get(reg.Id).Contact__c) )){
                   
                   eabEventIds.add(reg.EAB_Event__c);
               }
        }
        if(eabEventIds.size() == 0)
            return;
        //Set to hold Campaign Ids 
        Set<Id> campaignIds = new Set<Id>();
        
        //Map to hold EAB Events
        Map<Id, Advisory_Event__c> mapOfEABEvents = new Map<Id, Advisory_Event__c>();
        
        for(Advisory_Event__c eabEvent : [Select Id, Invite_List__c From Advisory_Event__c Where Id IN : eabEventIds]){
            
            mapOfEABEvents.put(eabEvent.Id, eabEvent);
            if(eabEvent.Invite_List__c != null)
                campaignIds.add(eabEvent.Invite_List__c);
        }
        
        Map<Id, Campaign> mapOfCampaigns = new Map<Id, Campaign>();
        //Query on associated campaigns
        if(campaignIds.size() > 0){
            mapOfCampaigns = new Map<Id, Campaign>([Select Id, (Select Id, ContactId From CampaignMembers) From Campaign Where Id IN : campaignIds]);
        }
        
        for(Registration__c reg : newRegistrations){
            
            if((oldRegistrations == null && reg.EAB_Event__c != null && reg.Contact__c != null)
               || (oldRegistrations != null && (reg.EAB_Event__c != oldRegistrations.get(reg.Id).EAB_Event__c || reg.Contact__c != oldRegistrations.get(reg.Id).Contact__c) )){
                   
                   if(mapOfEABEvents.containsKey(reg.EAB_Event__c) && mapOfEABEvents.get(reg.EAB_Event__c).Invite_List__c != null){
                       
                       Campaign cap = mapOfCampaigns.get(mapOfEABEvents.get(reg.EAB_Event__c).Invite_List__c);
                           
                       Boolean isContactFound = false;
                       for(CampaignMember capMember : cap.CampaignMembers){
                           
                           if(capMember.ContactId != null && reg.Contact__c == capMember.ContactId){
                               isContactFound = true;
                               break;
                           }
                       }
                       reg.Is_On_Invite_List__c = isContactFound ? 'Yes' : 'No';
                       
                   }else{
                       reg.Is_On_Invite_List__c = null;
                   }
               }
        }
    }
    
    /**
     * @description     : This method is used to create Meeting Utilization on Registration Creation and sync records on update
     * 
     * @args            : List<Registration__c> newRegistrations, Map<Id, Registration__c> mapOfOldRegistrations
     * 
     * @return          : void
     * 
     * @revision log    : V1.0 Created Saurabh Kumar -  CR-20200821-14459 - 02/01/2021
     * 		        : V1.1 Updated by Saurabh Kumar - CR-20210312-14994 - 04/15/2021: Updated where clause and bypass creating Meeting Utilization for Onsite & Conference & cohort eab event record types.
     *                  : V1.2 Updated by Chirag Soni - CR-20210312-14994 - 05/20/2021: UAT Issues (MRS2.0) - Updated where clause to create meeting utilization only for Event record type.
     *			: V1.3 Modified By - Chirag Soni - CR-20210606-15193
     * */
    public static void syncMeetingUtilization(List<Registration__c> newRegistrations, Map<Id, Registration__c> mapOfOldRegistrations){
        
        //Meeting Utilization to upsert
        Map<Id, Meeting_Utilization__c> meetingUtilizationByRegistrationIdToUpsert = new Map<Id, Meeting_Utilization__c>();
        
        //Set to hold Registration Ids
        Set<Id> registrationIds = new Set<Id>();
        
        for(Registration__c registration : newRegistrations){
            
            //Insert Case
            if(mapOfOldRegistrations == null){
                registrationIds.add(registration.Id);
            }else if(registration.Meeting_Utilization__c != null 
                    && (registration.Status__c != mapOfOldRegistrations.get(registration.Id).Status__c
                    || registration.Net_Promoter_Score__c != mapOfOldRegistrations.get(registration.Id).Net_Promoter_Score__c
                    || registration.Overall_Evaluation__c != mapOfOldRegistrations.get(registration.Id).Overall_Evaluation__c))
            {//Update Case
                String status = registration.Status__c == Constants.REGISTRATION_STATUS_REGISTRATION_REQUESTED ? REGISTRATION_STATUS_REGISTRATION_REQUESTED_TRANSLATED_VALUE : registration.Status__c;
                meetingUtilizationByRegistrationIdToUpsert.put(registration.Id, new Meeting_Utilization__c(Id = registration.Meeting_Utilization__c, 
                                                                                                           Status__c = status,
                                                                                                           ParticipationCount__c = registration.Status__c == Constants.REGISTRATION_STATUS_REGISTERED || registration.Status__c == REGISTRATION_STATUS_ATTENDED ? 1 : 0,
                                                                                                           Net_Promoter_Score__c = registration.Net_Promoter_Score__c,
                                                                                                           Overall_Meeting_Evaluation__c = registration.Overall_Evaluation__c));
                
            }
        }
        
        //Process the record to insert Meeting Utilization
        if(registrationIds.size() > 0){
            
            //Get the list of sync fields
            List<Sync_Field__c> syncFields = Constants.SYNC_FIELDS_LIST;
            
            //V1.1 Updated by Saurabh Kumar - CR-20210312-14994 - 04/15/2021: Updated where clause and bypass creating Meeting Utilization for Onsite & Conference eab event record types.
            for(Registration__c reg : [Select Id, Status__c, Contact__c, Contact__r.Name, Contact__r.Title, Contact__r.AccountId, EAB_Event__c, EAB_Event__r.Name,
                                       EAB_Event__r.Begins__c, EAB_Event__r.Ends__c, EAB_Event__r.Public_Name__c,EAB_Event__r.Location__c, EAB_Event__r.Primary_Program__c,
                                       EAB_Event__r.Primary_Program__r.Program_Acronym__c,(Select Id, Membership__c, Membership__r.Active_Subscription__r.SBQQ__Account__c,
                                                                                           Membership__r.Program__c From Membership_MtMs__r) From Registration__c Where EAB_Event__c != null AND
                                       EAB_Event__r.RecordTypeId = :Constants.RECORD_TYPE_ID_ADV_EVENT_EVENT AND
                                       ID IN : registrationIds]){
                 
                 String name = reg.EAB_Event__r.Public_Name__c != null ? reg.EAB_Event__r.Public_Name__c : '' + ' ' + reg.EAB_Event__r.Location__c != null ? reg.EAB_Event__r.Location__c : '';
                 
		 //Modified By - Neha Sharma - 04/19/2021 - CR-20210324-15023 - check public name is not blank                        
                 name = (String.isNotBlank(name) && name.length() > 59) ? name.substring(0, 58) : name;
                                                            
                 String beginsDate = reg.EAB_Event__r.Begins__c != null ? String.valueOf(reg.EAB_Event__r.Begins__c.format('MM/dd/yyyy')) : '';
                 name = beginsDate.substring(0, 10)+' - '+name+' - '+reg.EAB_Event__r.Primary_Program__r.Program_Acronym__c;
                                           
                 if(String.isNotBlank(name) && name.length() > 80)
                    name = name?.substring(0, 80);
                                           
                
                String eventName = reg.EAB_Event__r.Public_Name__c;
                if (String.isNotBlank(eventName) && eventName.length() > 100) {
                    eventName = eventName.substring(0, 100);
                }
                eventName += ','; //add comma to the end of event name to keep it consistent with how the value is stored today
                 
                 Boolean isCEO = false;
                 Boolean isCXO = false;
                 for(Sync_Field__c syncField : syncFields){
                    
                     if(syncField.Source_Field_API_Name__c.equalsIgnoreCase(reg.Contact__r.Title)){
                         
                         if(syncField.Target_Field_API_Name__c == 'CEO__c')
                            isCEO = true;
                         if(syncField.Target_Field_API_Name__c == 'CXO__c')
                            isCXO = true;
                         
                         if(isCEO && isCXO)
                             break;
                     }
                 }
                
                 String membership;
                 String PayerInstitution;
                 for(Membership_MtM__c membershipMtM : reg.Membership_MtMs__r){
                       
                     if(membership == null && membershipMtM.Membership__c != null && membershipMtM.Membership__r.Program__c == reg.EAB_Event__r.Primary_Program__c)
                         membership = membershipMtM.Membership__c;
                     if(PayerInstitution == null && membershipMtM.Membership__c != null && membershipMtM.Membership__r.Active_Subscription__r.SBQQ__Account__c != null)
                         PayerInstitution = membershipMtM.Membership__r.Active_Subscription__r.SBQQ__Account__c;
                     
                     if(membership != null && PayerInstitution != null)
                         break;
                 } 
                 meetingUtilizationByRegistrationIdToUpsert.put(reg.Id, new Meeting_Utilization__c(
                                                                OwnerId = Label.DEFAULT_MEETING_UTILIZATION_OWNER_ID,
                                                                Name = name,
                                                                CEO__c = isCEO,
                                                                CXO__c = isCXO,
                                                                Contact_Name__c = reg.Contact__r.Name,
                                                                Contact_Title__c = reg.Contact__r.Title,
                                                                Contact__c = reg.Contact__c,
                                                                End_Date__c = Date.valueOf(reg.EAB_Event__r.Ends__c),
                                                                EventId__c = reg.EAB_Event__c,
                                                                Event_Name__c = eventName,
                                                                Institution__c = reg.Contact__r.AccountId,
                                                                Membership__c = membership,
                                                                ParticipationCount__c = reg.Status__c == Constants.REGISTRATION_STATUS_REGISTERED || 
                                                                                        reg.Status__c == REGISTRATION_STATUS_ATTENDED ? 1 : 0,
                                                                Payer_Institution__c = PayerInstitution != null ? PayerInstitution : reg.Contact__r.AccountId,
                                                                Program__c = reg.EAB_Event__r.Primary_Program__r.Program_Acronym__c,
                                                                Start_Date__c = Date.valueOf(reg.EAB_Event__r.Begins__c),
                                                                Status__c = reg.Status__c == Constants.REGISTRATION_STATUS_REGISTRATION_REQUESTED ? REGISTRATION_STATUS_REGISTRATION_REQUESTED_TRANSLATED_VALUE : reg.Status__c,
                                                                Utilization_Metric__c = UTILIZATION_METRIC_MEETINGS,
                                                                EAB_Event__c = reg.EAB_Event__c
                 ));                                                             
            }
        }
        
        if(meetingUtilizationByRegistrationIdToUpsert.size() > 0){
            Util.BypassAllTriggers = true;
            bypassRegistrationDLRS = true;
            upsert meetingUtilizationByRegistrationIdToUpsert.values();
            bypassRegistrationDLRS = false;
            Util.BypassAllTriggers = false;
        }
        
        if(mapOfOldRegistrations != null)
            return;
        
        //Map to hold registration to update
        Map<Id, Registration__c> mapOfRegistrationToUpdate = new Map<Id, Registration__c>();
        
        for(Registration__c registration : newRegistrations){
            
            if(meetingUtilizationByRegistrationIdToUpsert.containsKey(registration.Id)){
                
                mapOfRegistrationToUpdate.put(registration.Id, new Registration__c(Id = registration.Id,
                Meeting_Utilization__c = meetingUtilizationByRegistrationIdToUpsert.get(registration.Id).Id));
            }
        }
        if(mapOfRegistrationToUpdate.size() > 0){
            Util.BypassAllTriggers = true;
            bypassRegistrationDLRS = true;
	    //Modified By - Chirag Soni - CR-20210606-15193
            bypasspopulateInstitutionRegistrationCount = true;
            update mapOfRegistrationToUpdate.values();
	    //Modified By - Chirag Soni - CR-20210606-15193
            bypasspopulateInstitutionRegistrationCount = false;
            bypassRegistrationDLRS = false;
            Util.BypassAllTriggers = false;
        }
    }
    
    /**
     *  @description    :   This method is used to create campaign member when registration is created.
     *                      Logic : When a Registration is manually created on an EAB Event where Marketo Campaign field
     *                      is populated. If EABEvent.Status NOT IN ('Closed - Completed', 'Closed - Cancelled') &
     *                      Registration.Status is IN Constants.CAMPAIGN_MEMBER_MARKETO_STATUSES.
     *                      (i) Check the Campaign for a Campaign Member for that Registration.Contact. if one doesn't exist, 
     *                      create the new Campaign Member and set the Status based on the Registration Status.
     * 
     *                      MRS2.0 UAT Issues - new logics added 
     *                      If a registration has a Partial Attend status on the EAB Event Registration, the Campaign Member Status should be Attended.
     * 			    If a registration has a Cancelled status on the EAB Event Registration, the Campaign Member Status should be Cancelled.
     * 			    If a registration has a VOID status on the EAB Event Registration,the Campaign Member Status should be Cancelled.
     * 			    If EAB Event registrations status is Declined then it should not flip/update in Marketo.
     *                     
     * 
     *  @args           :   List<Registration__c> newRegistrations,  Map<Id, Registration__c> mapOfOldRegistrations
     * 
     *  @return         :   Void
     * 
     *  @revision Log   :   V1.0 - Created - Saurabh Kumar - 03/26/2021 - CR-20201116-14696
     *                      V1.1 - Modified by - Chirag Soni - 05/20/2021 - MRS2.0 UAT Issues fixes. 
     * 			    		V1.2 - Modified by - Chirag Soni - 06/04/2021 - MRS2.0 UAT Issues fixes.
     * 			    		V1.3 - Modified by - Chirag Soni - 06/16/2021 - MRS2.0 UAT Issues fixes.
     * 						V1.4 - Modified by - Chirag Soni - 05/11/2022 - CR-20220429-16152 - Refactor the code in order to improve CPU time limit SOQL limit exception.
     * */
    
    public static void createAndPopulateCampaignMemberStatus(List<Registration__c> newRegistrations,  Map<Id, Registration__c> mapOfOldRegistrations){
        
        //map to hold registration on EAB Event ids
        Map<Id, Registration__c> mapOfRegistrationOnEabEventId = new Map<Id, Registration__c>();
        //set to hold contact ids 
        Set<Id> contactIds = new Set<Id>();
        
        for(Registration__c registration : newRegistrations)
        {
            //Initial condition for registration insert/update 
            if(registration.RecordTypeId == Constants.REGISTRATION_RECORD_TYPE_ID_CORE_REGISTRATION && 
               registration.Contact__c != null && registration.EAB_Event__c  != null && (mapOfOldRegistrations == null ||
                                                                                         registration.Status__c != mapOfOldRegistrations.get(registration.id).Status__c ||
                                                                                         registration.Contact__c != mapOfOldRegistrations.get(registration.id).Contact__c ||
                                                                                         registration.EAB_Event__c != mapOfOldRegistrations.get(registration.id).EAB_Event__c))
            {
                //Condition for registration status
                if(Constants.CAMPAIGN_MEMBER_MARKETO_STATUSES.contains(registration.Status__c) ||  SET_OF_ADDITIONAL_REGISTRATION_STATUS.contains(registration.Status__c))
                {
                    // fill map with eab id and registration
                    mapOfRegistrationOnEabEventId.put(registration.EAB_Event__c, registration);
                    contactIds.add(registration.Contact__c);
                }
            }
        }
        //check contact ids map keys
        if(!mapOfRegistrationOnEabEventId.keySet().isEmpty() &&  !contactIds.isEmpty())
        {
            //map to hold Campaign Id over EAB Event Id 
            Map <Id, Id> mapOfEabEventIdAndCampaignId = new Map <Id, Id>();
            List<Campaign> listOfCampaign = new List<Campaign>();
            
            for(Advisory_Event__c eabEvent : [SELECT Id, Marketo_Campaign__c FROM Advisory_Event__c
                                              WHERE Id IN :mapOfRegistrationOnEabEventId.keySet() AND Marketo_Campaign__c != null])
            {
                mapOfEabEventIdAndCampaignId.put(eabEvent.Id, eabEvent.Marketo_Campaign__c);
                listOfCampaign.add(new Campaign (Id = eabEvent.Marketo_Campaign__c));
            }
            
            //check size of map and list 
            if(!mapOfEabEventIdAndCampaignId.values().isEmpty() && !listOfCampaign.isEmpty())
            {
                // get exisiting list of campaign member
                List<CampaignMember> listOfExistingCampaignMember = Util.getExistingRegistrationOrCampaignMember(listOfCampaign, contactIds);
                
                // map to hold Existing CampaignMember on contact id
                Map<Id, CampaignMember> mapOfCampaignMemberByContactIdToUpsert = new Map<Id, CampaignMember>();
                //-----------------------check if existing campaign members are found ------------------------------------------------------//
                if(listOfExistingCampaignMember != null && !listOfExistingCampaignMember.isEmpty())
                {
                    for(Registration__c registration : newRegistrations){
                        for(CampaignMember cm : listOfExistingCampaignMember){
                            
                            // if existing campaign found 
                            if(registration.Contact__c == cm.ContactId)
                            {
                                CampaignMember campaignMemberToUpsert = new CampaignMember();
                                campaignMemberToUpsert.Id = cm.Id;
                                campaignMemberToUpsert.Registration__c =registration.Id;
                                
                                //MRS2.0 UAT Issue - Added SET_OF_ADDITIONAL_REGISTRATION_STATUS check 
                                if(!SET_OF_ADDITIONAL_REGISTRATION_STATUS.contains(registration.Status__c)){
                                    campaignMemberToUpsert.Status = registration.Status__c;
                                }
                                else if (registration.Status__c == REGISTRATION_STATUS_PARTIAL_ATTEND){ // check for partial attended status
                                    campaignMemberToUpsert.Status = Constants.REGISTRATION_STATUS_ATTENDED;
                                }
                                else if(registration.Status__c == STATUS_VOID){ // check for VOID
                                    campaignMemberToUpsert.Status = Constants.STATUS_CANCELLED;
                                }
                                else if(registration.Status__c == Constants.REGISTRATION_STATUS_WAITLIST){ // if registration status is waitlist the cm status should be waitlisted
                                    campaignMemberToUpsert.Status = CAMPAIGN_MEMBER_STATUS_WAITLISTED;
                                }
                                mapOfCampaignMemberByContactIdToUpsert.put(registration.Contact__c, campaignMemberToUpsert);
                                break;  
                            }
                        }
                    }
                }
                ////-----------------------Codition for remaining registrations whose campaign members are not found------------------------------------------------------//
                if(mapOfCampaignMemberByContactIdToUpsert.size() < newRegistrations.size())
                {
                    for(Registration__c registration : newRegistrations)
                    {
                        if(!(mapOfCampaignMemberByContactIdToUpsert.containsKey(registration.Contact__c)) && registration.RecordTypeId == Constants.REGISTRATION_RECORD_TYPE_ID_CORE_REGISTRATION){
                            // Insert Remaining Campaign Members
                            CampaignMember campaignMemberToUpsert = new CampaignMember();
                            campaignMemberToUpsert.CampaignId = mapOfEabEventIdAndCampaignId.get(registration.EAB_Event__c);
                            campaignMemberToUpsert.ContactId= registration.Contact__c;
                            campaignMemberToUpsert.Registration__c =registration.Id;
                            
                            //MRS2.0 UAT Issue - Added SET_OF_ADDITIONAL_REGISTRATION_STATUS check 
                            if(!SET_OF_ADDITIONAL_REGISTRATION_STATUS.contains(registration.Status__c)){
                                campaignMemberToUpsert.Status = registration.Status__c;
                            }
                            else if (registration.Status__c == REGISTRATION_STATUS_PARTIAL_ATTEND){ // check for partial attended status
                                campaignMemberToUpsert.Status = Constants.REGISTRATION_STATUS_ATTENDED;
                            }
                            else if(registration.Status__c == STATUS_VOID){ // check for VOID
                                campaignMemberToUpsert.Status = Constants.STATUS_CANCELLED;
                            }
                            else if(registration.Status__c == Constants.REGISTRATION_STATUS_WAITLIST){ // if registration status is waitlist the cm status should be waitlisted
                                campaignMemberToUpsert.Status = CAMPAIGN_MEMBER_STATUS_WAITLISTED;
                            }
                            
                            mapOfCampaignMemberByContactIdToUpsert.put(registration.Contact__c, campaignMemberToUpsert);
                        }
                    }
                }
                //check size of campaign member map values 
                if(!mapOfCampaignMemberByContactIdToUpsert.values().isEmpty()){
                    CampaignMemberTriggerHelper.isCreateAndPopulateRegistrationExecute = false;
                    isCreateAndPopulateCampaignMemberStatusExecute = false;
                    try{
                        upsert mapOfCampaignMemberByContactIdToUpsert.values();
                    }
                    catch(Exception ex ){
                        newRegistrations[0].addError(ex.getMessage());
                    }
                    isCreateAndPopulateCampaignMemberStatusExecute = true;
                    CampaignMemberTriggerHelper.isCreateAndPopulateRegistrationExecute = true;
                }
            }
        }
    }
    
    /**
     *  @description    :   This method is used to post chatter when registration status is updated
       	                    Login 1 : When a Registration's Status is Update and it's related to a Marketo Campaign Member
        	            OR a Marketo Campaign Member's Status is updated and it's related to a Registration record:
                	    if the Status value cannot be synchronized to the corresponding record because it doesn't meet the rules mentioned above, post a chatter.
                            Basically, we should be able to include logic in the afterUpdate portion of trigger to check if the corresponding record's Status was 
                            updated to match the EABEvent or CampaignMember where Status changed. If the values don't match because the update didn't occur due to not meeting the criteria mentioned above:
                            Chatter should @mention the EABEvent's Event Manager and the Campaign's Demand Generation Manager (Campaign.OwnerId)
                                            
     * 
     *  @args           :   List<Registration__c> newRegistrations,  Map<Id, Registration__c> mapOfOldRegistrations
     * 
     *  @return         :   Void
     * 
     *  @revision Log   :   V1.0 - Created - Saurabh Kumar - 03/30/2021 - CR-20201116-14696
     * 
     * */
    public static void postChatterOnStatusMismatch(List<Registration__c> newRegistrations,  Map<Id, Registration__c> mapOfOldRegistrations){
        
        // set to hold Contact id 
        Set<Id> contactIds = new Set<Id>();
        // map to hold contact id and status 
        Map<Id, List<Registration__c>> mapOfRegistraionsOnEabIds = new Map<Id, List<Registration__c>>();
        
        for(Registration__c registration : newRegistrations){
            
            if(registration.Status__c != mapOfOldRegistrations.get(registration.id).Status__c && String.isNotBlank(registration.EAB_Event__c) && String.isNotBlank(registration.Contact__c)){
                   
                   if(!(mapOfRegistraionsOnEabIds.containsKey(registration.EAB_Event__c)))
                       mapOfRegistraionsOnEabIds.put(registration.EAB_Event__c, new List<Registration__c>());
                       
                       mapOfRegistraionsOnEabIds.get(registration.EAB_Event__c).add(registration);
                       contactIds.add(registration.Contact__c);
               }
        }
        if(mapOfRegistraionsOnEabIds.size() == 0)
            return; 
        
        // Map to hold campaign ids and Eab Events
        Map<Id, List<Advisory_Event__c>> mapOfEabEventsOnCampaignId = new   Map<Id, List<Advisory_Event__c>>();
        
        for(Advisory_Event__c eabEvent : [SELECT Id, Marketo_Campaign__c, Event_Manager__c FROM Advisory_Event__c WHERE 
                                          Id IN :mapOfRegistraionsOnEabIds.keySet() AND Marketo_Campaign__c != null])
        {
            if(!(mapOfEabEventsOnCampaignId.containsKey(eabEvent.Marketo_Campaign__c)))
                mapOfEabEventsOnCampaignId.put(eabEvent.Marketo_Campaign__c, new List<Advisory_Event__c>());
                
                mapOfEabEventsOnCampaignId.get(eabEvent.Marketo_Campaign__c).add(eabEvent);
        }
        if(mapOfEabEventsOnCampaignId.size() == 0)
            return;
        
        // set to hold user id for mention user in chatter post
        Set<Id> userIdsToPostChatter = new Set<Id>();
        for(CampaignMember campaignMember : [SELECT Id, ContactId, Status, CampaignId, Campaign.OwnerId FROM CampaignMember 
                                             WHERE CampaignId IN :mapOfEabEventsOnCampaignId.keySet()
                                             AND ContactId IN :contactIds])
        {
            for(Advisory_Event__c eabEvent : mapOfEabEventsOnCampaignId.get(campaignMember.CampaignId)){
                
                for(Registration__c registration : mapOfRegistraionsOnEabIds.get(eabEvent.Id)){
                    
                    if(campaignMember.ContactId == registration.Contact__c && registration.Status__c != campaignMember.Status){
                        if(String.isNotBlank(eabEvent.Event_Manager__c))
                            userIdsToPostChatter.add(eabEvent.Event_Manager__c);
                        userIdsToPostChatter.add(campaignMember.Campaign.OwnerId);
                    }
                }
            }
        }
        if(userIdsToPostChatter.size()>0){
            List<Id> userIds = new List<Id>();
            userIds.addAll(userIdsToPostChatter);
            //post chatter and mention user in it
            
            if(!Test.isRunningTest())
                ConnectApi.FeedItem feed = ChatterHelper.PostChatterFeedItem(ConnectApi.FeedType.News,'me', Label.MESSAGE_REGISTRATION_CAMPAIGN_MEMBER_STATUS_MISMATCH , userIds); 
            isAlreadyChatterPostedForRegistrationAndCamapignMemberStatusMissMatch = true;
        }
    }
	
    /**
    *  @description    :  This method is used to update Requires_Acquia_Sync__c field on Registration.
                          Logic :     1. Related EAB Event Status = Open OR the event is within 2 weeks of event end date; after that no changes to the registration records would occur.
   			              2. Registration is created OR one of the fields on Registration referenced in the �https://myeab.quip.com/3c2nAxWFsg3z/Acquia-Registration-Data-Sync-CR-20210128-14854#EYaACAwh4ko� section is updated
	                                            
    * 
    *  @args           :   List<Registration__c> newRegistrations,  Map<Id, Registration__c> mapOfOldRegistrations
    * 
    *  @return         :   Void
    * 
    *  @revision Log   :   V1.0 - Created - Saurabh Kumar - 04/02/2021 - CR-20210128-14854
    *		       :   V1.1 - Modified By - Lawrence Lam - CR-20210606-15193
    * 
    * */
    public static void validateRegistrationToSyncAcquia (List<Registration__c> newRegistrations,  Map<Id, Registration__c> mapOfOldRegistrations){
        
        Set<Id> eabEventIds = new Set<Id>();
        
        for(Registration__c registration : newRegistrations){
            
            // Checking if record is inserting or updating
            if(registration.EAB_Event__c != null && ( mapOfOldRegistrations == null || registration.Status__c != mapOfOldRegistrations.get(registration.Id).Status__c ||
               registration.Partner_Status__c != mapOfOldRegistrations.get(registration.Id).Partner_Status__c ||
               registration.Zoom_Participant_URL__c != mapOfOldRegistrations.get(registration.Id).Zoom_Participant_URL__c ||
               registration.Zoom_Registrant_ID__c != mapOfOldRegistrations.get(registration.Id).Zoom_Registrant_ID__c ||
               registration.Zoom_Reminder_Email_Sent__c != mapOfOldRegistrations.get(registration.Id).Zoom_Reminder_Email_Sent__c || 
               registration.Alternate_Contact_Email__c != mapOfOldRegistrations.get(registration.Id).Alternate_Contact_Email__c ||
               registration.Dinner_RSVP__c != mapOfOldRegistrations.get(registration.Id).Dinner_RSVP__c)){
               	
                   eabEventIds.add(registration.EAB_Event__c);
               }
        }
        if(eabEventIds.size() == 0)
            return;
        Map<Id, Advisory_Event__c> mapOfEABEvents = new Map<Id, Advisory_Event__c>([Select Id, Acquia_Segment_Id__c, Campaign_Template__c, Status__c, Ends__c From Advisory_Event__c Where Id IN : eabEventIds]);
        
        Set<String> eabEventStatus = new Set<String>{};
            
        //Block to process Requires_Acquia_Sync__c true
        for(Registration__c registration : newRegistrations){
	    //Modified By - Lawrence Lam - CR-20210606-15193
            // Checking if record is inserting or updating
            if(registration.EAB_Event__c != null && mapOfEABEvents.containsKey(registration.EAB_Event__c) && String.isNotBlank(mapOfEABEvents.get(registration.EAB_Event__c).Campaign_Template__c) &&
               	(mapOfEABEvents.get(registration.EAB_Event__c).Status__c != 'Closed - Cancelled' || 
                 System.today().addDays(14) >= Date.valueOf(mapOfEABEvents.get(registration.EAB_Event__c).Ends__c) ) &&
               ( mapOfOldRegistrations == null || registration.Status__c != mapOfOldRegistrations.get(registration.Id).Status__c ||
               registration.Partner_Status__c != mapOfOldRegistrations.get(registration.Id).Partner_Status__c ||
               registration.Zoom_Participant_URL__c != mapOfOldRegistrations.get(registration.Id).Zoom_Participant_URL__c ||
               registration.Zoom_Registrant_ID__c != mapOfOldRegistrations.get(registration.Id).Zoom_Registrant_ID__c ||
               registration.Zoom_Reminder_Email_Sent__c != mapOfOldRegistrations.get(registration.Id).Zoom_Reminder_Email_Sent__c || 
               registration.Alternate_Contact_Email__c != mapOfOldRegistrations.get(registration.Id).Alternate_Contact_Email__c ||
               registration.Dinner_RSVP__c != mapOfOldRegistrations.get(registration.Id).Dinner_RSVP__c) &&
               (!registration.Requires_Acquia_Sync__c)){
               	
                   registration.Requires_Acquia_Sync__c = true;
               }
        }
    }
	   
    /**
    *  @description    :  This method is used to make callout ('/api/contacts/new?includeCustomObjects=true') when registration is created or updated with registration.Requires_Acquia_Sync__c = true
                                                
    * 
    *  @args           :   List<Registration__c> newRegistrations,  Map<Id, Registration__c> mapOfOldRegistrations
    * 
    *  @return         :   Void
    * 
    *  @revision Log   :   V1.0 - Created - Saurabh Kumar - 04/07/2021 - CR-20210128-14854
    * 		       :   V1.1 - Modified - Chirag Soni - 07/15/2021 - CR-20210709-15278 - created registration list which needs to send for acquia call to avoid too many queueable error
    * 		       :   V1.2 - Modified - Lawrence Lam - 07/18/2021 - CR-20210606-15193 - Modified to call Registrations in Bulk
    * 		       :   V1.3 - Modified - Chirag Soni - 02/09/2022 - CR-20220208-15772 - scheduled Batch_AcquiaSync and commented enqueuing of AcquiaHttpCallout
    * */
    public static void syncContactAndRegistrationsWithAcquia(List<Registration__c> newRegistrations,  Map<Id, Registration__c> mapOfOldRegistrations){
        List<Id> acquiaCalloutList = new List<Id>();
        
        for(Registration__c registration : newRegistrations){
            
            //Avoid multiple callout for same record in same transaction
            if(registrationIdsWhichAlreadyProceedToSyncWithAcquia.contains(registration.Id))
                continue;
            
            //Checking if Requires_Acquia_Sync__c is true then make callout to sync with Acquia
            if(registration.Requires_Acquia_Sync__c && registration.RecordTypeId != Constants.REGISTRATION_RECORD_TYPE_ID_INTERNAL_ATTENDEE){
                
                //prevent duplicate contact creation in acquia
                if(mapOfOldRegistrations != null && registration.Acquia_Id__c == null )
                {
                    continue;
                }
                // regular process
                else{
                    acquiaCalloutList.add(registration.Id);
                    registrationIdsWhichAlreadyProceedToSyncWithAcquia.add(registration.Id);
                }
                
            }
        }
        if(acquiaCalloutList.size()>0){
            
            //create croj exp to schedule after 5 seconds
            DateTime sysTime = dateTime.now().addSeconds(5);
            String cronExpr = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
            //String to hold Apex Job Name
            String apexJobName = 'Registration_AcquiaSync' + ' ' + sysTime+' '+math.random();
            System.schedule(apexJobName, cronExpr, new Schedule_AcquiaSync(acquiaCalloutList)); 
            //CR-20220208-15772 - 02/09/2022 - Chirag Soni - Commented  
            //System.enqueueJob(new AcquiaHTTPCallout(acquiaCalloutList));
        }
    }


    /**
    *  @description    :  This method is used to reset flag and update approval fields.
    *			  Moved "Populate the Registration's Status Field Value" process builder logic to this method.                                          
    * 
    *  @args           :   List<Registration__c> newRegistrations,  Map<Id, Registration__c> mapOfOldRegistrations
    * 
    *  @return         :   Void
    * 
    *  @revision Log   :   V1.0 - Created - Saurabh Kumar - 04/19/2021 - CR-20210318-15005
    * 		       :   V1.1 - Modified - Chirag Soni - 12/15/2021 - CR-20211214-15632 - Added updateRelatedRegistrationStatus method call to update respective child registrations after parent registraion field populate.
    *		       :   V1.2 - Modified - Chirag Soni - 2/1/2022 - CR-20211215-15634 - Added condition to update RSVP when Registration status is cancelled. 
    *		       :   V1.3 - Modified - Chirag Soni - 3/8/2022 - CR-20220307-15987 - added mapOfOldRegistrations in updateRelatedRegistrationStatus method call.
    * */
    public static void manageRegistrationFields(List<Registration__c> newRegistrations,  Map<Id, Registration__c> mapOfOldRegistrations){
        
        Map<Id, Registration__c> registrationsToUpdate = new Map<Id, Registration__c>();
        Set<Id> eabEventIds = new Set<Id>();
        
        for(Registration__c registration : newRegistrations){
            
            if(registration.Automated_Update__c)
                registrationsToUpdate.put(registration.Id, new Registration__c(Id = registration.Id, Automated_Update__c = false));
            
            if(registration.EAB_Event__c != null && registration.Partner_Status__c == Constants.REGISTRATION_PARTNER_STATUS_PARTNER && (mapOfOldRegistrations == null|| registration.Partner_Status__c != mapOfOldRegistrations.get(registration.Id).Partner_Status__c || registration.EAB_Event__c != mapOfOldRegistrations.get(registration.Id).EAB_Event__c)){
                
                eabEventIds.add(registration.EAB_Event__c); 
            }
            
            // Added - Chirag Soni - CR-20211215-15634 - 2/1/2022 -- from here
            if(registration.RecordTypeId == Constants.REGISTRATION_RECORD_TYPE_ELEVATED_MEAL && 
               registration.Status__c == STATUS_CANCELLED && (mapOfOldRegistrations == null || registration.Status__c != mapOfOldRegistrations.get(registration.Id).Status__c))
            {
                if(registrationsToUpdate.containsKey(registration.Id)){
                    registrationsToUpdate.get(registration.Id).RSVP__c = 'No';
                }
                else{
                    registrationsToUpdate.put(registration.Id, new Registration__c(Id = registration.Id, RSVP__c = 'No'));
                }
            }// Added - Chirag Soni - CR-20211215-15634 - 2/1/2022 -- till here
        }
        
        if(eabEventIds.size() > 0){
            
            Map<Id, Advisory_Event__c> mapOfEABEvents = new Map<Id, Advisory_Event__c>([Select Id, Cap_Per_Institution__c, Auto_Approve_Partners__c, Status__c From Advisory_Event__c Where Id IN : eabEventIds]);
            
            for(Registration__c registration : newRegistrations){
                //Added by - Chirag Soni - 11/19/2021 - CR-20211117-15587 - Added a contains check to avoid null exception
                if(registration.EAB_Event__c != null && mapOfEABEvents.containsKey(registration.EAB_Event__c) && mapOfEABEvents.get(registration.EAB_Event__c).Auto_Approve_Partners__c && registration.Partner_Status__c == Constants.REGISTRATION_PARTNER_STATUS_PARTNER
                   && mapOfEABEvents.get(registration.EAB_Event__c).Status__c == Constants.EAB_EVENT_STATUS_OPEN_REGISTRATION && (mapOfEABEvents.get(registration.EAB_Event__c).Cap_Per_Institution__c == null
                                                                                                                                  || registration.Institution_Registration_Count__c == null
                                                                                                                                  || registration.Institution_Registration_Count__c < mapOfEABEvents.get(registration.EAB_Event__c).Cap_Per_Institution__c) &&
                   (mapOfOldRegistrations == null || registration.Institution_Registration_Count__c != mapOfOldRegistrations.get(registration.Id).Institution_Registration_Count__c ||
                    registration.Partner_Status__c != mapOfOldRegistrations.get(registration.Id).Partner_Status__c || registration.EAB_Event__c != mapOfOldRegistrations.get(registration.Id).EAB_Event__c)
                  ){
                      
                      if(!registrationsToUpdate.containsKey(registration.Id))
                          registrationsToUpdate.put(registration.Id, new Registration__c(Id = registration.Id));
                          registrationsToUpdate.get(registration.Id).Approval_Reason__c = null;
                          registrationsToUpdate.get(registration.Id).Approval_Status__c = Constants.KEYWORD_APPROVED;
                          registrationsToUpdate.get(registration.Id).Approval_Type__c = Constants.REGISTRATION_APPROVAL_TYPE_AUTO_APPROVE_PARTNER;
                          registrationsToUpdate.get(registration.Id).Status__c = Constants.REGISTRATION_STATUS_REGISTERED; 
                    }
            }
        }
        if(registrationsToUpdate.size() > 0){
            Boolean prevBypassValue = util.BypassAllTriggers;
            Util.ByPassAllTriggers = true;
            bypasspopulateInstitutionRegistrationCount = true;
	    //Modified By - Chirag Soni - CR-20210606-15193
            bypassRegistrationDLRS = true;
            
            //Modified - Chirag Soni - 12/15/2021 - CR-20211214-15632 - update related child registrations - from here 
            List<Registration__c> registrationsToUpdateChilds = new List<Registration__c>(); 
            for(Registration__c registration : newRegistrations){
                if(registrationsToUpdate.containsKey(registration.Id) && registration.Parent_Registration__c == null)
                {
                    Registration__c reg = registrationsToUpdate.get(registration.Id);
                    reg.EAB_Event__c = registration.EAB_Event__c;
                    reg.Cancellation_Reason__c = registration.Cancellation_Reason__c;
                    reg.Declined_Reason__c = registration.Declined_Reason__c;
                    reg.Automated_Update__c = false;
                    registrationsToUpdateChilds.add(reg);
                }
            }
            if(registrationsToUpdateChilds.size()>0){
                // Modified - Chirag Soni - CR-20220307-15987 - added mapOfOldRegistrations in below method call.
                updateRelatedRegistrationStatus(registrationsToUpdateChilds, mapOfOldRegistrations); 
            }
            //Modified - Chirag Soni - 12/15/2021 - CR-20211214-15632 - update related child registrations - till here 
            
            update registrationsToUpdate.values();
            
            bypasspopulateInstitutionRegistrationCount = false;
	    //Modified By - Chirag Soni - CR-20210606-15193
            bypassRegistrationDLRS = false;
            Util.ByPassAllTriggers = prevBypassValue;
        }
    }
   /**
    *  @description    :   This method is used to cancelled all the child registration when parent registration status is cancelled
    * 			   Logic :- When registration status is updated as Cancelled. Get all the child EAB Event's Registrations Where
    *                      Child Eab event Inherit Registrations = Parent Registrants Eligible and update all the child registration status to 
    *                      Cancelled where child registration.contact = parent registration.contact.
    * 
    *  @args           :   List<Registration__c> newRegistrations,  Map<Id, Registration__c> mapOfOldRegistrations
    * 
    *  @return         :   Void
    * 
    *  @revision Log   :   V1.0 - Created - Chirag Soni - 05/31/2021 - CR-20210408-15071
    *			   V1.1 - Modified By - Chirag Soni - CR-20210606-15193
    * 
    * */
    
    public static void cancelParentsEligibleRegistrations(List<Registration__c> newRegistrations,  Map<Id, Registration__c> mapOfOldRegistrations){
        
        //Set to hold contact ids
        Set<Id> contactIds = new Set<Id>();
        
        //map to hold EAB Event ids and list of registrations
        map<Id, List<Registration__c>> mapOfRegistrationsOnEabEventIds = new map<Id, List<Registration__c>>();
        
        for(Registration__c registration : newRegistrations){
            
            if(registration.Status__c == STATUS_CANCELLED && registration.EAB_Event__c != null && registration.Contact__c != null &&
               (mapOfOldRegistrations == null || registration.Status__c != mapOfOldRegistrations.get(registration.Id).Status__c)){
                   
                   //add contact ids & EAB Event ids
                   contactIds.add(registration.Contact__c);
                   
                   //check if eab event id not exist put new event id and add registration in the new list 
                   if(!mapOfRegistrationsOnEabEventIds.containsKey(registration.EAB_Event__c))
                       mapOfRegistrationsOnEabEventIds.put(registration.EAB_Event__c, new List<Registration__c>());
                   
                   mapOfRegistrationsOnEabEventIds.get(registration.EAB_Event__c).add(registration);
               }
        }
        //check set and map size size
        if(contactIds.size()>0 && mapOfRegistrationsOnEabEventIds.size()>0){
            
            //List of registration to update
            List<Registration__c> registrationsToUpdate = new  List<Registration__c>();
            
            //Query child eab events and respective registrations
            for(Advisory_Event__c eabEvent : [SELECT Id, Parent_Event__c, (SELECT Id, Status__c, Contact__c FROM Registrations__r WHERE Contact__c IN :contactIds) 
                                              FROM Advisory_Event__c WHERE Parent_Event__c IN :mapOfRegistrationsOnEabEventIds.keySet() AND Mirror_Registrations__c = :Constants.EAB_EVENT_INHERI_REGISTRATION_PARENT_REGISTRATIONS_ELIGIBLE])
            {
                for(Registration__c registration : eabEvent.Registrations__r)
                {
                    //get parent registrations and set cancellation reason in child registrant same as parent's cancellation reason
                    for(Registration__c parentRegistration : mapOfRegistrationsOnEabEventIds.get(eabEvent.Parent_Event__c)){
                        
                        if(registration.Contact__c == parentRegistration.Contact__c){
                            registrationsToUpdate.add(new Registration__c(Id = registration.id, Status__c = STATUS_CANCELLED, Cancellation_Reason__c = parentRegistration.Cancellation_Reason__c));
                        }
                    }
                }
            }
            //check size of registrations list 
            if(registrationsToUpdate.size()>0)
            {
	    	//Modified By - Chirag Soni - CR-20210606-15193
                bypasspopulateInstitutionRegistrationCount = true;
                Util.ByPassAllTriggers = true;
                bypassRegistrationDLRS = true;
                //update child registration status and cancellation reason
                update registrationsToUpdate;
                Util.ByPassAllTriggers = false;
                bypassRegistrationDLRS = false;
                bypasspopulateInstitutionRegistrationCount = false;
            }
        }
    }

    /**
     *  @description    :   This method is used to populate Travel Compensation Fields
     *
     *  @args           :   List<Registration__c> registrations, Map<Id, Registration__c> oldRegistrationsMap
     *
     *  @return         :   Void 
     *
     *  Version		:   V_1.0 - Created By -  Chirag Soni - 07/08/2021 - CR-20210511-15133  
     *
     **/
    
    public static void populateTravelCompensationFields(List<Registration__c> newRegistrations, map<Id, Registration__c> oldRegistrationsMap) {
        
        //Set to hold the user IDs
        Set<Id> setOfUsersIds = new Set<Id>();
        
        //Loop through Registrations
        for(Registration__c registration : newRegistrations) {

            //Check for the Department Authorization
            if(registration.Department_Authorization__c != null) {
                
              //Populate the Set
              setOfUsersIds.add(registration.Department_Authorization__c);    
            }
            
            //Check for the Requester
             if(registration.Requester_Name__c != null) {
                 
               //Populate the Set
              setOfUsersIds.add(registration.Requester_Name__c);    
            }
            
            //Populate the Is_Escalated__c field to true on insert/Update use case **
            if(registration.Travel_Assistance_Request__c == true
                && registration.Department_Authorization__c != null
                && registration.Start_Date__c.addDays(-7) < System.today()
                && registration.Is_Escalated__c == false
                 && (
                    oldRegistrationsMap == null || ( oldRegistrationsMap != null &&
                    (registration.Start_Date__c != oldRegistrationsMap.get(registration.Id).Start_Date__c
                     ||
                     registration.Travel_Assistance_Request__c != oldRegistrationsMap.get(registration.Id).Travel_Assistance_Request__c
                    )
                    )
                )
				)
                {
                 registration.Is_Escalated__c = true;
            	}
        }
        
        //Size Check over the userIds
        if(setOfUsersIds.size() > 0) {
            
          //Map to hold the contacts
          Map<Id, Contact> mapOfIdAndContacts = new Map<Id, Contact>();
            
            //Loop through contact records and populate the mapContacts
            for(Contact contact : [Select Id, Employee_User_Record__c FROM Contact WHERE Employee_User_Record__c != null
                               AND Employee_User_Record__c IN : setOfUsersIds]) {
                mapOfIdAndContacts.put(contact.Employee_User_Record__c, contact);
            }
            
            //loop over the new Registrations records
            for(Registration__c registration : newRegistrations) {
                
				//Populate the Department_Authorization_Contact__c
				if(registration.Department_Authorization__c != null && mapOfIdAndContacts.containsKey(registration.Department_Authorization__c))
                    registration.Department_Authorization_Contact__c = mapOfIdAndContacts.get(registration.Department_Authorization__c).ID;
                else
                    registration.Department_Authorization_Contact__c = null;
                
                //Populate the Requester_Name_Contact__c
                if(registration.Requester_Name__c != null && mapOfIdAndContacts.containsKey(registration.Requester_Name__c))
                    registration.Requester_Name_Contact__c = mapOfIdAndContacts.get(registration.Requester_Name__c).ID;
                else
                    registration.Requester_Name_Contact__c = null;
            }    
        }
    }

    /**
     *  @description    :   This method is used to invoke the Approval Process. 
     *
     *  @args           :   List<Registration__c> registrations, Map<Id, Registration__c> oldRegistrationsMap
     *
     *  @return         :   Void 
     *
     *  Version		:   V_1.0 - Created By -  Chirag Soni - 07/21/2021 - CR-20210511-15133  
     *
     **/
    public static void startsApproval(List<Registration__c> registrations, Map<Id, Registration__c> oldRegistrationsMap) {
        
        //Set to hold the esclated record Ids
        Set<Id> esclatedRecordIds = new Set<Id>();
        
        //Set to hold the Eligible record Ids
        Set<Id> eligibleRecordIds = new Set<Id>();
        
        //Loop over the registration records
        for(Registration__c registration : registrations) {
           
            //For Insert and Update case
            if(registration.Department_Authorization__c != null && registration.Start_Date__c != null && registration.Travel_Assistance_Request__c == true 
               && (oldRegistrationsMap == null || ( oldRegistrationsMap != null &&
               (registration.Travel_Assistance_Request__c !=  oldRegistrationsMap.get(registration.id).Travel_Assistance_Request__c
                || registration.Start_Date__c !=  oldRegistrationsMap.get(registration.id).Start_Date__c ||
                (registration.Is_Escalated__c == true && registration.Is_Escalated__c !=  oldRegistrationsMap.get(registration.id).Is_Escalated__c)
                ))))
                {
        
                //Check for the condition if the Registration records fall under the Standartd Travell Approval Process, Then kick starts the  Standartd Travell Approval Process for these records
                if((registration.Start_Date__c).addDays(-7) >= System.today()) {
                    // create the new approval request to submit
                    Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                    
                    //Specific approver
                    req.setObjectId(registration.Id);            
                    req.setProcessDefinitionNameOrId('Travel_Compensation_Non_Escalated');
                    req.setSkipEntryCriteria(true);
                    req.setComments('');
                    
                    //Process the Approval process.
                    Approval.ProcessResult result = Approval.process(req);
                    isApprovalProcessSubmitted = true;
                }
                else {
                    //Check for the esclated registration records  
                    //compare the statrts date 
                    if((registration.Start_Date__c).addDays(-7) < System.today()){
                        //Check for the approval status if pending then add them in to the esclated set i.e which are already in the standard travell approval Process but esclated due to date 
                        if( oldRegistrationsMap != null && registration.Travel_Compensation_Approval_Status__c == 'Pending' ){
                          esclatedRecordIds.add(registration.Id);
                        }
                        else{
                            //starts the Esclated approval Process for newly created esclated Registration records
                            if(oldRegistrationsMap == null || ( oldRegistrationsMap != null && String.isBlank(registration.Travel_Compensation_Approval_Status__c))){

                                // create the new approval request to submit
                                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                                //Specific approver
                                req.setObjectId(registration.Id);
                                req.setProcessDefinitionNameOrId('Travel_Compensation_Escalated');
                                req.setSkipEntryCriteria(true);
                                req.setComments('');
                                
                                //Process the Approval process.
                                Approval.ProcessResult result = Approval.process(req);
                                isApprovalProcessSubmitted = true;
                            }
                        }
                    }
                }
            }
        }
        //Check for size
        if(esclatedRecordIds.size() > 0 /*&& mapEsclatedRecordIdWithEntityValue.size() > 0*/) {
            //Set to hold the Process Instanceids
            Set<Id> setProcessInstanceIds = new Set<Id> ();
            //Query all the existing Approval Process Instances for Registration
            for(ProcessInstance pi : [SELECT Id, TargetObjectId 
                                        FROM ProcessInstance 
                                        WHERE TargetObjectId IN : esclatedRecordIds 
                                        AND Status='Pending']) 
            {
                //Populate the set
                setProcessInstanceIds.add(pi.Id);
            }
      
            //Check for size
            if(setProcessInstanceIds.size() > 0) {
                //Query all the ProcessInstanceWorkitems related to the existing approval Process Instances
                for(ProcessInstanceWorkitem workItem : [SELECT Id, ProcessInstanceId, OriginalActorId, ActorId FROM ProcessInstanceWorkitem 
                                                        where ProcessInstanceId IN : setProcessInstanceIds]
                )
                {
                    //String to hold the id
                    String OriginalActorIdstring = workItem.OriginalActorId;
                    
                    //Check for the Prefix and ten revoke/Recall the existing Approval Process
                    if(!OriginalActorIdstring.contains('00G')) {
                        Approval.ProcessWorkItemRequest req1 = new Approval.ProcessWorkItemRequest();
                        req1.setWorkItemId(workItem.id);
                        req1.setAction('Removed'); // This means to remove/recall Approval Request
                        req1.setComments('Recall Approval Process.');
                        Approval.ProcessResult result = Approval.process(req1);
                        isApprovalProcessSubmitted = true;
                        
                    }
                }   
            }
            
            //loop over the esclated Registration requests and then kick starts the esclated Approval Process
            for(id registrationId : esclatedRecordIds) {
                // create the new approval request to submit
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                //Specific approver
                req.setObjectId(registrationId);
                req.setSkipEntryCriteria(true);
                req.setComments('');    
                req.setProcessDefinitionNameOrId('Travel_Compensation_Escalated');
                //Process the Approval process.
                Approval.ProcessResult result = Approval.process(req);
                isApprovalProcessSubmitted = true;
            }
        }
    }

    /**
     *  @description    :   This method is used to  validate the approval process. 
     *
     *  @args           :   List<Registration__c> registrations, Map<Id, Registration__c> oldRegistrationsMap
     *
     *  @return         :   Void 
     *
     *  Version		:   V_1.0 - Created By -  Chirag Soni - 07/21/2021 - CR-20210511-15133  
     *
     **/
    public static void validateApprovalForDenyReason(Map<Id, Registration__c> registrations,  Map<Id, Registration__c> mapOfOldRegistrations) {
        
        //Map to hold Registrations
        map<Id, Registration__c> mapOfRegistrations = new map<Id, Registration__c>();
        
        // Build a list of rejected approval processes
        for ( Registration__c registration : registrations.values() )
        {
            //Check for Approver 
            if(registration.Department_Authorization__c != null){
                //Check for approval status 
                if ((registration.Travel_Compensation_Approval_Status__c == 'Rejected') 
                    && registration.Travel_Compensation_Approval_Status__c != mapOfOldRegistrations.get( registration.Id ).Travel_Compensation_Approval_Status__c)
                {
                    //holding the registrations in map
                    mapOfRegistrations.put(registration.Id, registration);
                }
            }
        }
    
        //cHECK FOR size
        if (mapOfRegistrations.size() > 0 )
        {
            //Map to hold the latest Approval
            map<Id, ProcessInstance> latestInstance = new map<Id, ProcessInstance>();
    
            //Query over the approval process with its steps
            for (ProcessInstance pi : [  SELECT TargetObjectId, Status, CreatedDate,
                                            (
                                            SELECT Id, ProcessInstanceId, StepStatus, Comments, CreatedDate
                                            FROM Steps
                                            WHERE StepStatus = 'Rejected'
                                            ORDER BY CreatedDate DESC
                                            )
                                            FROM ProcessInstance
                                            WHERE TargetObjectId In
                                            :mapOfRegistrations.keySet()
                                            ORDER BY CreatedDate DESC
                                        ])
            {
                //Populate the map for latest Approval Instance
                if (!latestInstance.containsKey(pi.TargetObjectId))
                {
                    latestInstance.put(pi.TargetObjectId, pi);
                }
                else
                {
                    ProcessInstance maxInstance = latestInstance.get(pi.TargetObjectId);
                    if ( maxInstance.CreatedDate < pi.CreatedDate  )
                    {
                        latestInstance.put(pi.TargetObjectId, pi);
                    }
                }
            }
            
            //Check for map size
            if(latestInstance.size() > 0){
             
                // only process the latest processInstance for any Registrations
                for ( ProcessInstance pi : latestInstance.values())
                {
                    //instance of Latest Process instance step 
                    ProcessInstanceStep latestPis = new ProcessInstanceStep();
                    
                    //Only process the latest step of any processInstance
                    for ( ProcessInstanceStep pis : pi.Steps)
                    {
                        //Check for lattest Instance
                        if ( latestPis.Id == null)
                            latestPis = pis;
                        else
                        {
                            //Compare the created date of processInstances to find the lattest ProcessInstance
                            if ( latestPis.CreatedDate < pis.CreatedDate)
                            {
                                latestPis = pis;
                            }
                        }
                    }
                        
                    //Check for the Registration object
                    if(mapOfRegistrations.get(pi.TargetObjectId) != null) 
                    {
                        //Check for the approval is rejected or approved by the latest step status
                        if ( latestPis.StepStatus == 'Rejected' ) 
                        {
                            //validate the Comment
                            if(latestPis.Comments == null || latestPis.Comments.trim().length() == 0 )
                            {
                                //String to hold the error message
                                String errorMessage = '';
                                //Check for Comment field value on approval VF page
                                if(latestPis.Comments == null || latestPis.Comments.trim().length() == 0)
                                    errorMessage = errorMessage + System.label.Registration_Approval_Rejected_Error;
                                    
                                //bind the error message to the Registration
                                mapOfRegistrations.get(pi.TargetObjectId).addError(errorMessage);      
                            }
                        }
                    }
                }
            }    
        }
    }
    /**
     *  @description    :   This method is used to send partner and Travel emails and to update travel email status
     *
     *  @args           :   List<Registration__c> registrations, Map<Id, Registration__c> oldRegistrations
     *
     *  @return         :   Void 
     *
     *  Version			:   V_1.0 - Created By -  Chirag Soni - 11/08/2021 - CR-20210511-15133  
     *
     **/
   /* public static void sendPartnerAndGoTravelEmailsAndUpdateTravelEmailStatus(List<Registration__c> registrations, Map<Id, Registration__c> oldRegistrations){	
	
	//Map to hold Registration Ids
        Set<Id> setOfRegistrationIds = new Set<Id>();
        
        //Set of EAB event
        Set<Id> setOfEABEventIds = new Set<Id>();
        
	//Variable to hold document URL
        String EABLogo;
        
        for(Registration__c registration : registrations){
            
            if((registration.Travel_Compensation_Approval_Status__c == Constants.KEYWORD_APPROVED) 
                && registration.RecordTypeId == Constants.REGISTRATION_RECORD_TYPE_ID_CORE_REGISTRATION && oldRegistrations != null
                && registration.Travel_Compensation_Approval_Status__c != oldRegistrations.get(registration.Id).Travel_Compensation_Approval_Status__c 
                && oldRegistrations.get(registration.Id).Travel_Compensation_Approval_Status__c != Constants.KEYWORD_APPROVED && registration.EAB_Event__c != null
              )
            {
                //Store registration in the map
                setOfRegistrationIds.add(registration.Id);
                setOfEABEventIds.add(registration.EAB_Event__c);
            }                  
        }
    
       //Set size check on registrations records 
       if(setOfRegistrationIds.size() == 0)
            return;

        //Query on registrations
        Map<Id, Registration__c> mapRegs = new Map<Id, Registration__c>([Select Id,Name, Status__c, What_Travel_is_being_offered__c, Valid_Through_Date__c,
                                                                        EAB_Event__c, EAB_Event__r.Begins__c, EAB_Event__r.Ends__c,
                                                                        First_Name__c,Contact__r.Asst_Email__c,Contact__r.Email,Contact__r.Account.Account_Formal_Name__c,
                                                                        Contact__c, Contact__r.Company_Email__c, Contact_Email__c, Contact__r.Phone,Contact__r.Name, 
                                                                        Contact_Institution__c, Contact__r.Account.Primary_City__c, Contact__r.Account.Primary_State_Province__c,
                                                                        Assistant__c, Assistant_Email__c, Contact__r.AssistantPhone, Contact__r.Account.Primary_Postal_Code__c,
                                                                        EAB_Event__r.Public_Name__c,EAB_Event__r.Location__c,EAB_Event__r.Event_Manager__c,
                                                                        EAB_Event__r.Begins_Long_Date__c,EAB_Event__r.Ends_Long_Date__c,
                                                                        Must_Arrive_at_Meeting_Location_By__c,Must_Depart_No_Earlier_Than__c, EAB_Event__r.Event_Manager__r.Name,
                                                                        Department_Authorization__c,Department_Authorization__r.Name, Department_Authorization__r.Email,
                                                                        Requester_Name__c, Requester_Name__r.Email, Requester_Name__r.Name,Maximum_Hotel_Nights__c, 
                                                                        Travel_Compensation_Approval_Status__c, Travel_Assistance_Request__c
                                                                        From Registration__c Where Id IN : setOfRegistrationIds]);


        
        //List of venues
        list<Venue__c> venues = [Select Id, Name,Venue_Address__c, Accommodations__c, Advisory_Event__c From Venue__c Where Advisory_Event__c IN : setOfEABEventIds And Primary__c = true];
        
        //Map of primary Venues
        Map<Id, Venue__c> mapOfEventIdWithPrimaryVenue = new Map<Id, Venue__c>();

        for(Id eventId : setOfEABEventIds){
            if(!mapOfEventIdWithPrimaryVenue.containsKey(eventId)){
                mapOfEventIdWithPrimaryVenue.put(eventId, new Venue__c());
            }
        }
        //Checking the venue and hotel room is blocked or not on a event
        if(venues.size()>0){
            for(Venue__c venue : venues){
                if(!mapOfEventIdWithPrimaryVenue.containsKey(venue.Advisory_Event__c)){
                    mapOfEventIdWithPrimaryVenue.put(venue.Advisory_Event__c, new Venue__c());
                }
                //filling mapOfEventIdWithPrimaryVenue
                mapOfEventIdWithPrimaryVenue.put(venue.Advisory_Event__c, venue);
            }
        }
	
        
        //Fetch document for Image URL
        Document[] doc = [SELECT Id,LastModifiedDate FROM Document WHERE DeveloperName =:Label.Send_Partner_And_Go_Travel_Email_Footer_EAB_Logo];
        if(doc.isEmpty()) {
            EABLogo ='';
        } else {
            EABLogo =  Url.getSalesforceBaseUrl().toExternalForm()+'/servlet/servlet.ImageServer?id='+doc[0].Id+'&oid='+UserInfo.getOrganizationId()+'&lastMod='+doc[0].LastModifiedDate.getTime();
        }
        
        //single email message
        Messaging.SingleEmailMessage[] mails =   new List<Messaging.SingleEmailMessage>();
		
		//Process the registrationRecords
        for(Registration__c reg : mapRegs.values()){
            
            if(reg.Travel_Compensation_Approval_Status__c == Constants.KEYWORD_APPROVED){
                
                //Send Internal Travel Email when hotel room is blocked or not blocked
                if(reg != null){
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    
                    //Setting Email Body
                    if(mapOfEventIdWithPrimaryVenue.containsKey(reg.EAB_Event__c))
                    	mail.setHtmlBody(TravelCompEmailTemplateWrapper.getInternalTravelEmailBody(reg, mapOfEventIdWithPrimaryVenue.get(reg.EAB_Event__c), EABLogo));
                    String[] ccAddresses = new String[] {reg.Requester_Name__r.Email};
                    mail.setccAddresses(ccAddresses);
                    String toAddresses = Label.Internal_Travel_Email_To_Address;
                    //address that will be used when a recipient replies to the email
                    mail.setReplyTo(reg.Department_Authorization__r.Email);  
                    mail.setToAddresses(new String[] {toAddresses});
                    mail.setSubject(Label.Travel_Email_Subject + ' | ' + reg.EAB_Event__r.Public_Name__c);
                    mails.add(mail);
                }

                //Send Partner facing email
                if(reg != null){
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

                    //Setting Email Body
                    mail.setHtmlBody(TravelCompEmailTemplateWrapper.getPartnerFacingEmailBody(reg, EABLogo));
                    String[] ccAddresses = new String[] {reg.Assistant_Email__c};
                    mail.setccAddresses(ccAddresses);
                    mail.setBccAddresses(new String[]{Label.Partner_Facing_Email_BCC_Address});
                    String toAddresses = reg.Contact_Email__c;

                    //address that will be used when a recipient replies to the email
                    mail.setReplyTo(reg.Requester_Name__r.Email);
                    mail.setToAddresses(new String[] {toAddresses});
                    mail.setSubject(Label.Travel_Email_Subject + ' | ' + reg.EAB_Event__r.Public_Name__c);
                    mails.add(mail);
                }
            }
	}

        //variable to hold travelEmailStatus
        String travelEmailStatus = '';
        try {
            if(mails.size()>0 && mapRegs.values().size()>0){
                Messaging.sendEmail(mails);
                for (Registration__c reg : mapRegs.values()) {
                    reg.Travel_Email_Status__c = 'Travel Email Sent '+System.now().format('MM/dd/yyyy HH:mm:ss');
                } 
                Util.ByPassAllTriggers = true;
                update mapRegs.values();
                Util.ByPassAllTriggers = false;
            }
        }
        catch(Exception e) {
            List<Registration__c> listOfRegistrationsWithTravelEmailStatus = new List<Registration__c>();
            for (Registration__c reg : mapRegs.values()) {
                reg.Travel_Email_Status__c = 'Travel Email Not Sent '+e.getMessage();
                listOfRegistrationsWithTravelEmailStatus.add(reg);
            }
            if(listOfRegistrationsWithTravelEmailStatus.size()>0){
                Util.ByPassAllTriggers = true;
                update listOfRegistrationsWithTravelEmailStatus;
                Util.ByPassAllTriggers = false;
            }
        }
    }*/
    /**
     *  @description    :   This method is used to auto populate Elevated Meal RSVP Field On ParentEvent
     *
     *  @args           :   List<Registration__c> registrations, Map<Id, Registration__c> oldRegistrations
     *
     *  @return         :   Void 
     *
     *  Version		:   V_1.0 - Created By -  Chirag Soni - 10/28/2021 - CR-20210614-15213 
     *			:   V_1.1 - Modified By - Chirag Soni - CR-20210606-15193
     *
     **/
    public static void populateElevatedMealRSVPFieldOnParentEvent(List<Registration__c> registrations, Map<Id, Registration__c> oldRegistrations){	
	
	//Map to hold Registration by EAB Event Ids
        Map<Id, Registration__c> registrationsByEABEventIds = new Map<Id, Registration__c>();
        
        for(Registration__c registration : registrations){
            
            if(registration.EAB_Event__c != null && registration.RecordTypeId == Constants.REGISTRATION_RECORD_TYPE_ELEVATED_MEAL && registration.Contact__c != null 
               && registration.RSVP__c != null /*&& registration.Elevated_Meal_RSVP__c != null*/ || (oldRegistrations != null && (oldRegistrations.get(registration.Id).RSVP__c != null 
               && registration.RSVP__c != oldRegistrations.get(registration.Id).RSVP__c)))
               //Store registration in the map
				registrationsByEABEventIds.put(registration.EAB_Event__c, registration);
        }

       if(registrationsByEABEventIds.size() == 0)
            return;
        
	//Map to hold current EAB Event
        Map<Id, Advisory_Event__c> eabEvents = new Map<Id, Advisory_Event__c>();
        
        //Set to hold Parent EAB Event Id
        Set<Id> parentEABEventId = new Set<Id>();
        
        //Query on Current EAB Event
        for(Advisory_Event__c eabEvent : [Select Id, Parent_Event__c, Parent_Event__r.RecordTypeId From Advisory_Event__c Where Id IN : registrationsByEABEventIds.keySet()]){

            eabEvents.put(eabEvent.Id, eabEvent);
            
            if(eabEvent.Parent_Event__c != null && eabEvent.Parent_Event__r.RecordTypeId != Constants.RECORD_TYPE_ID_EAB_EVENT_CONFERENCE)
                parentEABEventId.add(eabEvent.Parent_Event__c);
        }
		
        //Query on parent EAB Event and it's registrations
        Map<Id, Advisory_Event__c> parentEABEvents = new Map<Id, Advisory_Event__c>([Select Id, (Select Id, Contact__c,Duplicate_Matching__c, Elevated_Meal_RSVP__c, RecordTypeId, EAB_Event__c From Registrations__r) From Advisory_Event__c
																					Where Id IN : parentEABEventId]);

	//Map to hold registrations to update Elevated Meal RSVP on registration
        Map<String, Registration__c> mapOfRegistrationsByEABEventToUpdate = new Map<String, Registration__c>();
		
	//Process on new Registrations to validate
        for(Registration__c reg : registrations){
            //variable to hold contacId
            Id contactId;
			//storing contactId of registrations
			if(reg.EAB_Event__c != null && reg.RecordTypeId == Constants.REGISTRATION_RECORD_TYPE_ELEVATED_MEAL && reg.Contact__c != null)
				contactId = reg.Contact__c;
				
			for(Id parentEABEvent : parentEABEvents.keySet()){
				
				if(parentEABEvents.get(parentEABEvent).Registrations__r.size()>0){
					for(Registration__c registration : parentEABEvents.get(parentEABEvent).Registrations__r){
						if(registration.Contact__c != null && registration.Contact__c == contactId && registration.RecordTypeId == Constants.REGISTRATION_RECORD_TYPE_ID_CORE_REGISTRATION){
					
							registration.Elevated_Meal_RSVP__c = reg.RSVP__c;
							//Added a Duplicate matching 
							registration.Duplicate_Matching__c = registration.Contact__c + '-' + registration.EAB_Event__c;
							mapOfRegistrationsByEABEventToUpdate.put(registration.Duplicate_Matching__c, registration);
						}
					}
				}
			}
		}
        //update registration (Elevated meal RSVP) on parent event
        if(mapOfRegistrationsByEABEventToUpdate != null){
            //Modified By - Chirag Soni - CR-20210606-15193
            bypasspopulateInstitutionRegistrationCount = true;
            Util.ByPassAllTriggers = true;
            bypassRegistrationDLRS = true;
            update mapOfRegistrationsByEABEventToUpdate.values();
            Util.ByPassAllTriggers = false;
            bypassRegistrationDLRS = false;
            bypasspopulateInstitutionRegistrationCount = false;
        }
	}
}