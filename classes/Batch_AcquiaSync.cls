/**
 * Description		:	This class used to make call out to Acquia third party system.
 * 				Logic: https://quip.com/mVgUANJsjJCU/Acquia-Automate-creation-of-segments-CR-20210128-14855
 * 
 * Created Date		:	2/9/2022
 ********************************************************************************************************************************************************************
 * Old Revisions     	:  	V1.0 - Created - Saurabh Kumar - 03/17/2021 - CR-20210128-14855
 * 			:	V1.1 - Modified - Saurabh Kumar - 04/02/2021 - CR-20210128-14854: Added methods to sync contact & registrations to Acquia system.
 * 						                                                  Logic: https://quip.com/3c2nAxWFsg3z/Acquia-Registration-Data-Sync-CR-20210128-14854
 * 			:   	V1.2 - Modified - Chirag Soni - 06/04/2021 - CR-20210128-14854: QA&UAT Issues (MRS 2.0 Phase 2/3) - Issue #43 Added Event date and event time variable in order to send in Acquia System. 
 ********************************************************************************************************************************************************************
 * Revision Log		:	V1.0 - Created - Chirag Soni - 02/9/2022 - CR-20220208-15772 - Moved all the logic from AcquiaHttpCallout class to this class
 *
 *  			
 **/

global class Batch_AcquiaSync implements Database.Batchable<Sobject>, Database.AllowsCallouts{
    
    // --- Acquia Named Credential and End Point Details ---// 
    public static final String NAMED_CREDENTIAL_ACQUIA = 'Acquia';
    public static final String NAMED_CREDENTIAL_ACQUIA_SANDBOX = 'Acquia_Sandbox';
    public static final String END_POINT_NEW_SEGMENTS_POST_FIX = '/api/segments/new';
    public static final String END_POINT_CLONE_CAMPAIGN_POST_FIX = '/api/campaigns/clone/<ID>';
    public static final String END_POINT_EDIT_CAMPAIGN_POST_FIX = '/api/campaigns/<ID>/edit';
    public static final String END_POINT_CONTACT_REGISTRATION_SYNC_POST_FIX = '/api/contacts/new';//Added by Saurabh Kumar - CR-20210128-14854 - 04/06/2021
    public static final String END_POINT_CONTACT_TO_CAMPAIGN_POST = '/api/campaigns/<ID>/contact/<CONTACTID>/add';//Added by Lawrence Lam - CR-20210606-15193 - 06/28/2021
    public static final String END_POINT_CONTACT_TO_SEGMENT_POST = '/api/segments/<ID>/contact/<CONTACTID>/add';//Added by Lawrence Lam - CR-20210606-15193 - 06/28/2021
    public static final String END_POINT_CONTACT_REGISTRATION_SYNC_PATCH_FIX = '/api/contacts/<ID>/edit';//Added by Lawrence Lam - CR-20210606-15193 - 06/28/2021
    public static final String END_POINT_CONTACT_REGISTRATION_BULK_PUT = '/api/contacts/batch/edit';//Added by Lawrence Lam - CR-20210606-15193 - 06/28/2021
    public static final String END_POINT_CONTACT_REGISTRATION_BULK_POST = '/api/contacts/batch/new';//Added by Lawrence Lam - CR-20210606-15193 - 06/28/2021
    
    public static String END_POINT_NEW_SEGMENTS =  'callout:'+NAMED_CREDENTIAL_ACQUIA + END_POINT_NEW_SEGMENTS_POST_FIX;
    public static String END_POINT_CLONE_CAMPAIGN = 'callout:'+NAMED_CREDENTIAL_ACQUIA + END_POINT_CLONE_CAMPAIGN_POST_FIX;
    public static String END_POINT_EDIT_CAMPAIGN = 'callout:'+NAMED_CREDENTIAL_ACQUIA + END_POINT_EDIT_CAMPAIGN_POST_FIX;
    public static String END_POINT_CONTACT_REGISTRATION_SYNC = 'callout:'+NAMED_CREDENTIAL_ACQUIA+END_POINT_CONTACT_REGISTRATION_SYNC_POST_FIX;//Added by Saurabh Kumar - CR-20210128-14854 - 04/06/2021
    public static String END_POINT_CONTACT_TO_CAMPAIGN_SYNC = 'callout:'+NAMED_CREDENTIAL_ACQUIA+END_POINT_CONTACT_TO_CAMPAIGN_POST;//Added by Lawrence Lam - CR-20210606-15193 - 06/28/2021
    public static String END_POINT_CONTACT_TO_SEGMENT_SYNC = 'callout:'+NAMED_CREDENTIAL_ACQUIA+END_POINT_CONTACT_TO_SEGMENT_POST;//Added by Lawrence Lam - CR-20210606-15193 - 08/17/2021
    public static String END_POINT_CONTACT_REGISTRATION_SYNC_PATCH = 'callout:'+NAMED_CREDENTIAL_ACQUIA+END_POINT_CONTACT_REGISTRATION_SYNC_PATCH_FIX;//Added by Lawrence Lam - CR-20210606-15193 - 06/28/2021
    public static String END_POINT_CONTACT_REGISTRATION_BULK_SYNC_POST = 'callout:'+NAMED_CREDENTIAL_ACQUIA+END_POINT_CONTACT_REGISTRATION_BULK_POST;//Added by Lawrence Lam - CR-20210606-15193 - 06/28/2021
    public static String END_POINT_CONTACT_REGISTRATION_BULK_SYNC_PUT = 'callout:'+NAMED_CREDENTIAL_ACQUIA+END_POINT_CONTACT_REGISTRATION_BULK_PUT;//Added by Lawrence Lam - CR-20210606-15193 - 06/28/2021
    
    
    public static final String FIELD_MAPPING_CUSTOM_METADATA_ACQUIA_CAMPAIGN = 'Campaign_Template_to_External_CampaignID';
    
    Map<Id, Advisory_Event__c> mapOfEABEventsToGenerateNewAcquiaSegements;
    Map<Id, Advisory_Event__c> mapOfEABEventsToRegenerateAcquiaCampaigns;
    
    //Added by Saurabh Kumar - CR-20210128-14854 - 04/02/2021
    Contact contact;
    List<Registration__c> registrations;
    public static String WSLOGS_INSTITUTION_RECORD_TYPE_ID = Schema.SObjectType.Web_Service_Log__c.getRecordTypeInfosByName().get('Institution').getRecordTypeId();
    
    //Added by Lawrence Lam - CR-20210606-15193 - 07/25/2021
    public static Boolean preventAcquiaCampaignCloning = [Select isActive__c from Acquia_Metadata__mdt where Type__c = 'campaignCloningOverride' limit 1].isActive__c;
    
    
    /**
     * 	Description		:	Constructor to sync EAB Event with Acquia 
     * 
     *  @args			:	Map<Id, Advisory_Event__c> mapOfEABEventsToGenerateNewAcquiaSegements, Map<Id, Advisory_Event__c> mapOfEABEventsToRegenerateAcquiaCampaigns
     * 
     *  @return			:	Void
     * 
     *  @revision log	:	V1.0 - Created - Saurabh Kumar - 03/23/2021 - CR-20210128-14855
     * 					:   V1.1 - Created - Chirag Soni - 02/09/2022 - CR-20220208-15772 - moved this method from AcquiaHttpCallout class to this class	
     * */
    
    public Batch_AcquiaSync (Map<Id, Advisory_Event__c> mapOfEABEventsToGenerateNewAcquiaSegements, Map<Id, Advisory_Event__c> mapOfEABEventsToRegenerateAcquiaCampaigns){
        
        this.mapOfEABEventsToGenerateNewAcquiaSegements = mapOfEABEventsToGenerateNewAcquiaSegements;
        this.mapOfEABEventsToRegenerateAcquiaCampaigns = mapOfEABEventsToRegenerateAcquiaCampaigns;
    }
    
     /**
     * 	Description		:	Constructor to sync Registration with Acquia 
     * 
     *  @args			:	List<Id> setOfIds
     * 
     *  @return			:	Void
     * 
     *  @revision log	:	V1.0 - Created - Saurabh Kumar - 04/02/2021 - CR-20210128-14854
     * 					:   V1.1 - Created - Chirag Soni - 02/09/2022 - CR-20220208-15772 - moved this method from AcquiaHttpCallout class to this class
     * */
    
    public Batch_AcquiaSync(List<Id> setOfIds){
        
        if(setOfIds == null || setOfIds.size() == 0)
            return;
        
        registrations = new List<Registration__c>();
        
        if(setOfIds.get(0).getSObjectType() == Schema.Registration__c.SObjectType){
            registrations = [Select Id, Name,Acquia_Id__c,Registration_Approved_Date__c,EAB_Event__r.Begins__c,Registered_on_Date__c,EAB_Event__r.Public_Name__c,Status__c,EAB_Event__r.Location__c,Alternate_Contact_Email__c,Partner_Status__c,
                             Dinner_RSVP__c,Zoom_Participant_URL__c,Requires_Acquia_Sync__c,EAB_Event__r.Zoom_Meeting_ID__c,EAB_Event__r.Zoom_DialIn_Number__c,EAB_Event__r.Zoom_One_Touch_Mobile_Dial_In__c,
                             EAB_Event__r.Zoom_Password__c,EAB_Event__r.Event_Id__c,EAB_Event__r.Event_Website__c,EAB_Event__r.Evaluation_Link__c,Contact__c,
                             Contact__r.FirstName, Contact__r.LastName, /*Contact__r.Acquia_Id__c,*/Contact__r.Title,Contact__r.AssistantName,Contact__r.Asst_Email__c,/*Contact__r.Requires_Acquia_Sync__c,*/
                             Contact__r.Contact_Status__c,Contact__r.Email,Contact__r.Account.Account_Formal_Name__c,Contact__r.Primary_Address_Line_1__c,Contact__r.Primary_Address_Line_2__c,
                             Contact__r.Primary_City__c,Contact__r.Primary_State_Province__c,Contact__r.Primary_Postal_Code__c,Contact__r.Primary_Country__c,Contact__r.Account.Time_Zone_ID__c,
                             Event_Acquia_Segment_Id__c,EAB_Event__r.External_Campaign_Id__c,Local_Event_End_Date__c,Local_Event_End_Time__c,Local_Event_Start_Date__c,Local_Event_Start_Time__c,Local_Timezone__c,
                             EAB_Event__r.Ends__c, EAB_Event__r.Acquia_Segment_Id__c,EAB_Event__r.Length_Days__c
                             From Registration__c
                             Where ID IN : setOfIds AND Requires_Acquia_Sync__c = true AND Contact__c != null];
            if(registrations.size() > 0)
                contact = new Contact();
               
        } 
    }
    
    
    //This method is just a placed holder 
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id FROM Registration__c LIMIT 1';
        return Database.getQueryLocator(query);
    }
    
    //batch execute method 
    global void execute(Database.BatchableContext BC, List<sObject> sObjects) 
    {
        if(mapOfEABEventsToGenerateNewAcquiaSegements != null && mapOfEABEventsToGenerateNewAcquiaSegements.size() > 0)
            generateAcquiaSegment(mapOfEABEventsToGenerateNewAcquiaSegements);
        if(mapOfEABEventsToRegenerateAcquiaCampaigns != null && mapOfEABEventsToRegenerateAcquiaCampaigns.size() > 0)
            reGenerateAcquiaCampaign(mapOfEABEventsToRegenerateAcquiaCampaigns);
        if(registrations != null && contact != null)//Added by Saurabh Kumar - 04/05/2021 - CR-20210128-14854
            syncContactAndRegistrationsWithAcquia(registrations);
    }
    
     /**
     * 	Description		:	This method is used to generate Acquia Segment and populate Acquia_Segment_Id__c with Acquia Segment Id.
     * 					Logic: When eab event is created or Campaign Template is populated then generate Acquia Segment & Acquia Campaign Ids.
     * 
     *  @args			:	Map<Id, Advisory_Event__c> mapOfEABEvents
     * 
     *  @return			:	Void
     * 
     *  @revision log	:	V1.0 - Created - Saurabh Kumar - 03/18/2021 - CR-20210128-14855
     * 					:   V1.1 - Modified -Lawrence Lam - 07/18/2021 - CR-20210606-15193 - Removed Campaign ID Callout because Cloning via REST API does not clone flow diagram inside of Acquia
     * 					:   V1.2 - Created - Chirag Soni - 02/09/2022 - CR-20220208-15772 - moved this method from AcquiaHttpCallout class to this class
     * */
    public static void generateAcquiaSegment(Map<Id, Advisory_Event__c> mapOfEABEvents){
        
        if(mapOfEABEvents == null || mapOfEABEvents.size() == 0)
            return;
        
        validateEndPoints();
        
        Map<Id, Advisory_Event__c> mapOfEABEventsToUpdate = new Map<Id, Advisory_Event__c>();
        
        List<Web_Service_Log__c> wslogs = new   List<Web_Service_Log__c>();
        
        List<id> parentEventIdList = new List<Id>();
        for(Advisory_Event__c eabEvent : mapOfEABEvents.values()){
            if(eabEvent.Parent_Event__c != null){
                parentEventIdList.add(eabEvent.Parent_Event__c);
            }
        }
        Map<Id,Advisory_Event__c> parentEventMap = new Map<Id,Advisory_Event__c>([Select Id, Short_Name__c from Advisory_Event__c where id in: parentEventIdList]);
        
        //Block to get EAB Event and process for new Acquia Segment Call
        for(Advisory_Event__c eabEvent : mapOfEABEvents.values()){
            
            //CR-20210606-15193 - Prevent Creation if segment was already created
            if(preventAcquiaCampaignCloning && eabEvent.Acquia_Segment_Id__c != null){
                mapOfEABEventsToUpdate.put(eabEvent.Id, new Advisory_Event__c(Id = eabEvent.Id, Acquia_Segment_Id__c = eabEvent.Acquia_Segment_Id__c, Campaign_Template__c = eabEvent.Campaign_Template__c, Name = eabEvent.Name, External_Campaign_Id__c = eabEvent.External_Campaign_Id__c));
                continue;
            }
            String requestBody = AcquiaSegment.newSegmentRequestJsonGenerator(eabEvent.Event_Formatted_Name__c, eabEvent.Event_Id__c);
            HttpResponse response = doCallout(END_POINT_NEW_SEGMENTS, Constants.HTTP_REQUEST_POST_TYPE, requestBody);
            if(response.getStatusCode() == 201 && response.getBody() != null){
                
                //Json deserialization
                Map<String, Object> mapOfObjects = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                Map<String, Object> mapOfAttributes = (Map<String, Object>)mapOfObjects.get('list');
                Integer acquiaSegmentId = (Integer)mapOfAttributes.get('id');
                
                if(acquiaSegmentId != null)
                    mapOfEABEventsToUpdate.put(eabEvent.Id, new Advisory_Event__c(Id = eabEvent.Id, Acquia_Segment_Id__c = acquiaSegmentId, Campaign_Template__c = eabEvent.Campaign_Template__c, Name = eabEvent.Name, External_Campaign_Id__c = eabEvent.External_Campaign_Id__c));
            }
            wslogs.add(new Web_Service_Log__c(RecordTypeId = Schema.SObjectType.Web_Service_Log__c.RecordTypeInfosByDeveloperName.get('EAB_Event').RecordTypeId,
                                              EAB_Event__c = eabEvent.Id,
                                              Web_Service_Method__c = 'generateAcquiaSegment',
                                              Status_Code__c = String.valueOf(response.getStatusCode()),
                                              Request_Sent__c = system.now(),
                                              Request_Message_Log__c = requestBody,
                                              Response_Message__c = response.getStatus(),
                                              Response_Message_Log__c = String.valueOf(response.getBody())));
            
        }
        
        if(mapOfEABEventsToUpdate.size() == 0)
            return;
        
        //Get field value mapping
        Map<String, String> mapOfAcquiaCampaignIdByCampaignTemplate = getFieldValueMapping();
        
        //conditional prevention of campaign cloning because Acquia APIs does not clone campaigns with the proper flow diagram via REST API
        //CR-20210606-15193 - remove if statement after Acquia fixes API functionality
        //LL - 7/18/2021
        if(preventAcquiaCampaignCloning){
            
            Map<id, Advisory_Event__c> tempMapOfAcquiaCampaignToAssignToSegments = new Map<Id,Advisory_Event__c>();
            for(Advisory_Event__c eabEvent : mapOfEABEvents.values()){
                if(eabEvent.Acquia_Segment_Id__c!= null && eabEvent.External_Campaign_Id__c!= 0 && eabEvent.External_Campaign_Id__c != null){
                    tempMapOfAcquiaCampaignToAssignToSegments.put(eabEvent.Id, eabEvent);
                }else if (eabEvent.External_Campaign_Id__c==null){
                    //default campaigns to zero
                    mapOfEABEventsToUpdate.get(eabEvent.Id).External_Campaign_Id__c = 0;
                }
            }
            //assign segment to campaign if a valid value
            if(!tempMapOfAcquiaCampaignToAssignToSegments.isEmpty()){
                assignAcquiaCampaignToSegment(tempMapOfAcquiaCampaignToAssignToSegments);
            }
        }else{
            mapOfEABEventsToUpdate = generateAcquiaCampaign(mapOfEABEventsToUpdate, mapOfAcquiaCampaignIdByCampaignTemplate);
        }
        
        Util.BypassAllTriggers = true;
        update mapOfEABEventsToUpdate.values();
        
        //create web service logs 
        if(wslogs.size()>0){
            insert wslogs;
        }
        Util.BypassAllTriggers = false;
    }
    
    
     /**
     * 	Description		:	This method is used to generate Acquia Campaign and populate External_Campaign_Id__c with Acquia Campaign Id.
     * 						In first call out, Campaign Id is generated but inactive so making another call out to make it active.
     * 
     *  @args			:	Map<Id, Advisory_Event__c> mapOfEABEventsToUpdate
     * 
     *  @return			:	Map<Id, Advisory_Event__c> mapOfEABEventsToUpdate
     * 
     *  @revision log	:	V1.0 - Created - Saurabh Kumar - 03/18/2021 - CR-20210128-14855
     * 					:   V1.1 - Created - Chirag Soni - 02/09/2022 - CR-20220208-15772 - moved this method from AcquiaHttpCallout class to this class
     * */
    
    public static Map<Id, Advisory_Event__c> generateAcquiaCampaign(Map<Id, Advisory_Event__c> mapOfEABEventsToUpdate, Map<String, String> mapOfAcquiaCampaignIdByCampaignTemplate){
        
        //Block to generate Acquia Campaign Id and activate it
        for(Advisory_Event__c eabEvent : mapOfEABEventsToUpdate.values()){
            
            if(eabEvent.Acquia_Segment_Id__c == null || eabEvent.Campaign_Template__c == null || !mapOfAcquiaCampaignIdByCampaignTemplate.containsKey(eabEvent.Campaign_Template__c))
                continue;
            String requestBody = AcquiaSegment.acquiaCampaignRequestJsonGenerator(eabEvent.name, true, String.valueOf(eabEvent.Acquia_Segment_Id__c));
            
            HttpResponse response = doCallout(END_POINT_CLONE_CAMPAIGN.replace('<ID>', mapOfAcquiaCampaignIdByCampaignTemplate.get(eabEvent.Campaign_Template__c)), Constants.HTTP_REQUEST_POST_TYPE, requestBody);
            if(response.getStatusCode() == 200 && response.getBody() != null){
                
                Map<String, Object> mapOfObjects = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                Map<String, Object> mapOfAttributes = (Map<String, Object>)mapOfObjects.get('campaign');
                Integer externalCampaignId = (Integer)mapOfAttributes.get('id');
                Boolean isPublished = (Boolean)mapOfAttributes.get('isPublished');
                
                eabEvent.External_Campaign_Id__c = externalCampaignId;
                
                if(externalCampaignId != null && isPublished == false){
                    
                    //By default created Acquia Campaign is inactive so next call to make it active
                    requestBody = AcquiaSegment.acquiaCampaignRequestJsonGenerator(eabEvent.name, true, String.valueOf(eabEvent.Acquia_Segment_Id__c));
                    
                    HttpResponse resp = doCallout(END_POINT_EDIT_CAMPAIGN.replace('<ID>', String.valueOf(externalCampaignId)), Constants.HTTP_REQUEST_PATCH_TYPE, requestBody);
                }
                
            }
        }
        return mapOfEABEventsToUpdate;
    }
    
    
     /**
     * 	Description		:	This method is used to deactivate existing campaign and re-generate Acquia Campaign in case of update.
     * 
     *  @args			:	(Map<Id, Advisory_Event__c> mapOfEABEvents
     * 
     *  @return			:	Void
     * 
     *  @revision log	:	V1.0 - Created - Saurabh Kumar - 03/18/2021 - CR-20210128-14855
     * 					:	V1.1 - Modified - Lawrence Lam - 07/25/2021 - CR-20210606-15193
     * 					:   V1.2 - Created - Chirag Soni - 02/09/2022 - CR-20220208-15772 - moved this method from AcquiaHttpCallout class to this class
     * */
    public static void reGenerateAcquiaCampaign(Map<Id, Advisory_Event__c> mapOfEABEvents){
        
        if(mapOfEABEvents == null || mapOfEABEvents.size() == 0)
            return;
        
        validateEndPoints();
        
        Map<Id, Advisory_Event__c> mapOfEABEventsToUpdate = new Map<Id, Advisory_Event__c>();
        
        for(Advisory_Event__c eabEvent : mapOfEABEvents.values()){
            
            if(eabEvent.External_Campaign_Id__c == null || eabEvent.Acquia_Segment_Id__c == null)
                continue;
            
            //Deactivate the existing Acquia Campaign
            String requestBody = AcquiaSegment.acquiaCampaignRequestJsonGenerator(eabEvent.name, false, String.valueOf(eabEvent.Acquia_Segment_Id__c));
            HttpResponse resp = doCallout(END_POINT_EDIT_CAMPAIGN.replace('<ID>', String.valueOf(eabEvent.External_Campaign_Id__c)), Constants.HTTP_REQUEST_PATCH_TYPE, requestBody);
            if(resp.getStatusCode() == 200 && resp.getBody() != null){
                
                //Calling method to regenerate Acquia Campaign and activate new one
                mapOfEABEventsToUpdate.put(eabEvent.id, new Advisory_Event__c(Id = eabEvent.Id, Acquia_Segment_Id__c = eabEvent.Acquia_Segment_Id__c, Campaign_Template__c = eabEvent.Campaign_Template__c, Name = eabEvent.Name, External_Campaign_Id__c = eabEvent.External_Campaign_Id__c));
            }
        }
        
        if(mapOfEABEventsToUpdate.size() == 0)
            return;
        
        //CR-20210606-15193 - Remove if statement and only leave else once API cloning is fixed.
        if(preventAcquiaCampaignCloning){
            //Remove Campaign Id on Event for manual population.
            for(string eventId : mapOfEABEvents.keySet()){
                mapOfEABEventsToUpdate.get(eventId).External_Campaign_Id__c = 0;
            }
        }else{
            mapOfEABEventsToUpdate = generateAcquiaCampaign(mapOfEABEventsToUpdate, getFieldValueMapping());
        }
        
        Util.BypassAllTriggers = true;
        update mapOfEABEventsToUpdate.values();
        Util.BypassAllTriggers = false;
    }
    
    
    /**
     * 	Description		:	Temporary function to assign the campaign to the segment.
     * 					Temporary because REST API cloning function currently doesn't work as per Acquia Support (7/18/2021)
     * 						
     *  @args			:	(Map<Id, Advisory_Event__c> mapOfEABEvents
     * 
     *  @return			:	Void
     * 
     *  @revision log	:	V1.0 - Created - Lawrence Lam - 07/18/2021 - CR-20210606-15193
     * 					:V1.1 - Created - Chirag Soni - 02/09/2022 - CR-20220208-15772 - moved this method from AcquiaHttpCallout class to this class
     * */
    public static void assignAcquiaCampaignToSegment(Map<Id, Advisory_Event__c> mapOfEABEvents){
        
        if(mapOfEABEvents == null || mapOfEABEvents.size() == 0)
            return;
        
        validateEndPoints();
        
        Map<Id, Advisory_Event__c> mapOfEABEventsToUpdate = new Map<Id, Advisory_Event__c>();
        
        for(Advisory_Event__c eabEvent : mapOfEABEvents.values()){
            
            if(eabEvent.External_Campaign_Id__c == null || eabEvent.Acquia_Segment_Id__c == null)
                continue;
            
            //sync segment to new cloned campaign
            String requestBody = AcquiaSegment.acquiaCampaignRequestJsonGenerator(eabEvent.name, true, String.valueOf(eabEvent.Acquia_Segment_Id__c));
            HttpResponse resp = doCallout(END_POINT_EDIT_CAMPAIGN.replace('<ID>', String.valueOf(eabEvent.External_Campaign_Id__c)), Constants.HTTP_REQUEST_PATCH_TYPE, requestBody);
            
        }
    }
    
    
     /**
     * 	Description		:	Method to make call out
     * 
     *  @args			:	String endPoint, String method, String requestBody
     * 
     *  @return			:	HttpResponse
     * 
     *  @revision log	:	V1.0 - Created - Saurabh Kumar - 03/18/2021 - CR-20210128-14855
     * 					: 	V1.1 - Created - Chirag Soni - 02/09/2022 - CR-20220208-15772 - moved this method from AcquiaHttpCallout class to this class
     * */
    public static HttpResponse doCallout(String endPoint, String method, String requestBody){
        
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setTimeout(120000);
        request.setMethod(method);
        request.setHeader('Content-Type', 'application/json');
        
        if(String.isNotBlank(requestBody))
        	request.setBody(requestBody);
        
        Http http = new Http();
        HttpResponse response = http.send(request);
        
        return response;
    }

	
    /**
     * 	Description		:	Method to get field value mapping from custom meta data
     * 
     *  @args			:	
     * 
     *  @return			:	Map<String, String>
     * 
     *  @revision log	:	V1.0 - Created - Saurabh Kumar - 03/18/2021 - CR-20210128-14855
     * 					:   V1.1 - Created - Chirag Soni - 02/09/2022 - CR-20220208-15772 - moved this method from AcquiaHttpCallout class to this class
     * */
    public static Map<String, String> getFieldValueMapping(){
        
        //Block to get Field Mapping value for Campaign Id
        Map<String, String> mapOfAcquiaCampaignIdByCampaignTemplate = new Map<String, String>();
        for(Field_Mapping__mdt fieldMapping : [Select Active__c, Source_Field_API_Name__c, Source_Object_API_Name__c, Source_Value__c, Target_Field_API_Name__c, Target_Object_API_Name__c, Target_Value__c, (Select Field_Mapping__c, Source_Value__c, Target_Value__c From Field_Mapping_Values__r) From Field_Mapping__mdt Where DeveloperName =: FIELD_MAPPING_CUSTOM_METADATA_ACQUIA_CAMPAIGN AND Active__c = true]){
            
            for(Field_Mapping_Value__mdt fieldMappingValue : fieldMapping.Field_Mapping_Values__r)
            	mapOfAcquiaCampaignIdByCampaignTemplate.put(fieldMappingValue.Source_Value__c, fieldMappingValue.Target_Value__c);
        }
        
        return mapOfAcquiaCampaignIdByCampaignTemplate;
    }

    
    /**
     * 	Description		:	This method is used to change the end point in case of SBX.
     * 
     *  @args			:	
     * 
     *  @return			:	void
     * 
     *  @revision log	:	V1.0 - Created - Saurabh Kumar - 03/18/2021 - CR-20210128-14855
     * 					:   V1.1 - Created - Chirag Soni - 02/09/2022 - CR-20220208-15772 - moved this method from AcquiaHttpCallout class to this class
     * */
    public static void validateEndPoints(){
        
        if([SELECT IsSandbox FROM Organization].IsSandbox){
            
            END_POINT_NEW_SEGMENTS =  'callout:'+NAMED_CREDENTIAL_ACQUIA_SANDBOX + END_POINT_NEW_SEGMENTS_POST_FIX;
            END_POINT_CLONE_CAMPAIGN = 'callout:'+NAMED_CREDENTIAL_ACQUIA_SANDBOX + END_POINT_CLONE_CAMPAIGN_POST_FIX;
    	    END_POINT_EDIT_CAMPAIGN = 'callout:'+NAMED_CREDENTIAL_ACQUIA_SANDBOX + END_POINT_EDIT_CAMPAIGN_POST_FIX;
            END_POINT_CONTACT_REGISTRATION_SYNC = 'callout:'+NAMED_CREDENTIAL_ACQUIA_SANDBOX+END_POINT_CONTACT_REGISTRATION_SYNC_POST_FIX;
            END_POINT_CONTACT_TO_CAMPAIGN_SYNC = 'callout:'+NAMED_CREDENTIAL_ACQUIA_SANDBOX+END_POINT_CONTACT_TO_CAMPAIGN_POST;
            END_POINT_CONTACT_TO_SEGMENT_SYNC = 'callout:'+NAMED_CREDENTIAL_ACQUIA_SANDBOX+END_POINT_CONTACT_TO_SEGMENT_POST;
            END_POINT_CONTACT_REGISTRATION_SYNC_PATCH = 'callout:'+NAMED_CREDENTIAL_ACQUIA_SANDBOX+END_POINT_CONTACT_REGISTRATION_SYNC_PATCH_FIX;
            END_POINT_CONTACT_REGISTRATION_BULK_SYNC_POST = 'callout:'+NAMED_CREDENTIAL_ACQUIA_SANDBOX+END_POINT_CONTACT_REGISTRATION_BULK_POST;
            END_POINT_CONTACT_REGISTRATION_BULK_SYNC_PUT = 'callout:'+NAMED_CREDENTIAL_ACQUIA_SANDBOX+END_POINT_CONTACT_REGISTRATION_BULK_PUT;
        }
    }
    
    
    /**
     * 	Description		:	This method is used to sync Contact & Registrations with Acquia system.
     * 
     *  @args			:	Contact con, List<Registration__c> registrations
     * 
     *  @return			:	void
     * 
     *  @revision log	:	V1.0 - Created - Saurabh Kumar - 04/02/2021 - CR-20210128-14854
     * 					: 	V1.1 - Modified - Lawrence Lam - CR-20210606-15193 - Call Contact Patch rather than POST creating a new contact in Acquia
     * 					:   V1.2 - Created - Chirag Soni - 02/09/2022 - CR-20220208-15772 - moved this method from AcquiaHttpCallout class to this class
     * */
    public static void syncContactAndRegistrationsWithAcquia(List<Registration__c> registrations){
        
        if((registrations == null || registrations.size() == 0))
            return;
         
        validateEndPoints();
        
        //Sync contact & registrations
        //TODO - rewrite for bulk context
        String requestBody = syncContactAndRegistrationsWithAcquiaRequestJsonGenerator(registrations);
        List<Web_Service_Log__c> webserviceLogList = new List<Web_Service_Log__c>();
        //String contactAcquiaIdString = String.valueOf(contact.Id != null ? contact.Acquia_Id__c : registrations[0].Acquia_Id__c);
        String contactAcquiaIdString = String.valueOf(registrations[0].Acquia_Id__c);
        HttpResponse response;
        //if(String.isEmpty(contactAcquiaIdString)){
        // response = doCallout(END_POINT_CONTACT_REGISTRATION_SYNC, Constants.HTTP_REQUEST_POST_TYPE, requestBody);
       // }else{ 
        response = doCallout(END_POINT_CONTACT_REGISTRATION_BULK_SYNC_PUT, Constants.HTTP_REQUEST_PUT_TYPE , requestBody);
       // }
        for(Registration__c reg : registrations){
            //String contactId = registrations[0].Contact__c;
            webserviceLogList.add(new Web_Service_Log__c(RecordTypeId = WSLOGS_INSTITUTION_RECORD_TYPE_ID, 
                                                         Registration__c = reg.Id,
                                                         Web_Service_Method__c = 'syncContactAndRegistrationsWithAcquia', 
                                                         Contact__c = reg.Contact__c, 
                                                         Response_Message__c = String.valueOf(response.getStatusCode()),
                                                         Request_Message_Log__c = requestBody.length() < 32768 ? requestBody :  requestBody.substring(0, 32768), 
                                                                 Response_Message_Log__c = response.getBody().length() < 32768 ? response.getBody() : response.getBody().substring(0, 32768)));
        }
        
        //insert webServiceLog;
        
        
        if((response.getStatusCode() == 200 || response.getStatusCode() == 201) && response.getBody() != null){
       		
            //Map to hold Aquia Registration Id by Salesforce Registration Name
            Map<String, Integer> acquiaRegistrationIdByName = new Map<String, Integer>();
            List<AcquiaContact.contact> acquiaContactList = (List<AcquiaContact.contact>)System.JSON.deserialize(response.getBody().left(response.getBody().length()-1).replace('{"contacts":',''), List<AcquiaContact.contact>.class);
            //Modified - Test class issue fixes - 08/26/2021
            Integer contactAcquiaId;
            //if(!Test.isRunningTest()){
                for(AcquiaContact.contact acquiaContact : acquiaContactList){
                    contactAcquiaId = acquiaContact.id;
                    acquiaRegistrationIdByName.put(acquiaContact.fields.all.registration_name, acquiaContact.id);
                    
                //}
                /*
		for(acquiaContact.data registrationValue : acquiaContact.contact.customObjects.data[0].data){
		acquiaRegistrationIdByName.put(registrationValue.name, registrationValue.id);
		}*/
            }
            //callout and map contacts to Campaign
            
            for(Registration__c reg : registrations){ 
                
                if(reg.EAB_Event__c != null && String.isNotBlank(String.valueOf(reg.EAB_Event__r.External_Campaign_Id__c)) && String.isBlank(String.valueOf(reg.Acquia_Id__c))){
                    //response = doCallout(END_POINT_CONTACT_TO_CAMPAIGN_SYNC.replace('<ID>',String.valueOf(reg.EAB_Event__r.External_Campaign_Id__c)).replace('<CONTACTID>',String.valueOf(contactAcquiaId)), Constants.HTTP_REQUEST_POST_TYPE,null);
                    
                    if(acquiaRegistrationIdByName.size()>0 && acquiaRegistrationIdByName.containsKey(reg.Name) && reg.EAB_Event__r.Acquia_Segment_Id__c != null)
                    {                        
                        response = doCallout(END_POINT_CONTACT_TO_SEGMENT_SYNC.replace('<ID>',String.valueOf(reg.EAB_Event__r.Acquia_Segment_Id__c)).replace('<CONTACTID>',String.valueOf(acquiaRegistrationIdByName.get(reg.Name))), Constants.HTTP_REQUEST_POST_TYPE,null);
                        
                        webserviceLogList.add(new Web_Service_Log__c(Web_Service_Method__c = 'syncContactAndRegistrationsWithAcquia', 
                                                                     RecordTypeId = WSLOGS_INSTITUTION_RECORD_TYPE_ID,
                                                                     Contact__c = reg.Contact__c, 
                                                                     Response_Message__c = String.valueOf(response.getStatusCode()),
                                                                     Request_Message_Log__c = requestBody.length() < 32768 ? requestBody :  requestBody.substring(0, 32768), 
                                                                     Response_Message_Log__c = response.getBody().length() < 32768 ? response.getBody() : response.getBody().substring(0, 32768)));
                    }
                }
            }
            
            //insert all webservice logs
            insert webserviceLogList;
            
            //Block to populate acquia Id on contact
            //Contact contactToUpdate = new Contact(Id = contactId, Acquia_Id__c = contactAcquiaId, Requires_Acquia_Sync__c = false, Last_Acquia_Sync_DateTime__c = System.now());
            //update contactToUpdate;
            
            //Process to populate acquia id on registrations
            Map<Id, Registration__c> registrationsToUpdate = new Map<Id, Registration__c>();
            Set<Id> contactsIdsToUpdate = new Set<Id>();
            
            for(Registration__c reg : registrations){
                if(acquiaRegistrationIdByName.containsKey(reg.Name) || Test.isRunningTest()){
                    registrationsToUpdate.put(reg.Id, new Registration__c(Id = reg.Id, Acquia_Id__c = acquiaRegistrationIdByName.get(reg.Name), Requires_Acquia_Sync__c = false, Last_Acquia_Sync_DateTime__c = System.now()));
                }
                if(String.isNotBlank(reg.Contact__c))
                {
                    contactsIdsToUpdate.add(reg.Contact__c);
                }
            }
           
            if(registrationsToUpdate.size() > 0){
                Util.BypassAllTriggers = true;
                RegistrationHelper.bypassRegistrationDLRS = true;
                RegistrationHelper.bypasspopulateInstitutionRegistrationCount = true;
                update registrationsToUpdate.values();
                RegistrationHelper.bypasspopulateInstitutionRegistrationCount = false;
                RegistrationHelper.bypassRegistrationDLRS = false;
                Util.BypassAllTriggers = false;
            }
             if(contactsIdsToUpdate.size()>0){
                 
                List<Contact> contactsToUpdate = new List<Contact>();
                for(Contact  contact : [SELECT Id, Requires_Acquia_Sync__c FROM Contact WHERE Id IN :contactsIdsToUpdate AND Requires_Acquia_Sync__c  = true])
                {
                    contact.Requires_Acquia_Sync__c  = false;
                    contactsToUpdate.add(contact);
                }
                 
                if(contactsToUpdate.size()>0)
                {
                    update contactsToUpdate;
                }
            }
        }
    }
    
    
     /**
     * 	Description		:	This method is used to Json parameter for /api/contacts/new?includeCustomObjects callout
     * 
     *  @args			:	Contact con, List<Registration__c> registrations
     * 
     *  @return			:	String
     * 
     *  @revision log	:	V1.0 - Created - Saurabh Kumar - 04/02/2021 - CR-20210128-14854
     * 					:	V1.1 - Modified - Chirag Soni - 06/04/2021 - CR-20210128-14854: QA&UAT Issues (MRS 2.0 Phase 2/3) - Issue #43 Added Event date and event time variable in order to send in Acquia System.
     * 					:	V1.2 - Modified - Lawrence Lam - 07/18/2021 - CR-20210606-15193: modified to be registration inserting Contact
     * 					:	V1.3 - Created - Chirag Soni - 02/09/2022 - CR-20220208-15772 - moved this method from AcquiaHttpCallout class to this class
     * */
    public static String syncContactAndRegistrationsWithAcquiaRequestJsonGenerator(List<Registration__c> registrations){
        
        //list of registration data
        /*
        List<AcquiaContact.data> listRegData = new List<AcquiaContact.data>();
        
        for(Registration__c reg : registrations){
            
            //Registration attributes
            AcquiaContact.attributes att = new AcquiaContact.attributes();
            att.longdate = String.valueOf(reg.EAB_Event__r.Begins__c.format('EEEEE, MMMMM dd'));
            att.eventname = String.valueOf(reg.EAB_Event__r.Public_Name__c);
            att.status = reg.Status__c;
            //att.localtime = '08:30 AM';// [Convert Registration.EAB_Event__r.Begins__c to the timezone in Registration.Contact__r.Account.Time_Zone_Id__c and send in the format hh:mm a (ie: 4:29 pm)]
            //att.locallongdate = 'Friday, Febraury 26';// [Get Registration.EAB_Event__r.Begins__c and convert to Local Long Date in the format EEEE, MMMM d (ie: Friday, February 26). (Note: If timezone is blank, default to EST)]
            
            //v1.1 - 06/04/2021 - CR-20210128-14854 - Modified By - Chirag Soni - QA&UAT Issues (MRS 2.0 Phase 2/3) Issue #43 Start here.
            DateTime dtTime = reg.EAB_Event__r.Begins__c;
            att.eventdate = Date.newInstance(dtTime.year(), dtTime.month(), dtTime.day());
            att.eventtime = dtTime.format('hh:mm a');
            //v1.1 - 06/04/2021 - CR-20210128-14854 - Modified By - Chirag Soni - QA&UAT Issues (MRS 2.0 Phase 2/3) end.
             
            att.location = reg.EAB_Event__r.Location__c;
            att.alternatecontactemail = reg.Alternate_Contact_Email__c;
            att.partnerstatus = reg.Partner_Status__c;
            att.dinnerrsvp = reg.Dinner_RSVP__c;
            att.zoomparticipanturl = reg.Zoom_Participant_URL__c;
            att.zoommeetingid = reg.EAB_Event__r.Zoom_Meeting_ID__c;
            att.zoomdialinnumber = reg.EAB_Event__r.Zoom_DialIn_Number__c;
            att.onetouchmobiledialin = reg.EAB_Event__r.Zoom_One_Touch_Mobile_Dial_In__c;
            att.eventid = String.valueOf(reg.EAB_Event__r.Event_Id__c);
            att.registrationapproveddate = String.valueOf(reg.Registration_Approved_Date__c);
            att.eventwebsite = reg.EAB_Event__r.Event_Website__c;
            att.evaluationlink = reg.EAB_Event__r.Evaluation_Link__c;
            
            //V1.2 - 08/24/2021 - CR-20210606-15193 - Modified - Lawrence Lam- added Local Dates/Times
            att.localtimezone = reg.Local_Timezone__c;
            att.localeventstartdate = DateTime.newInstance(reg.Local_Event_Start_Date__c.year(), reg.Local_Event_Start_Date__c.month(), reg.Local_Event_Start_Date__c.day()).format('EEEEE, MMMMM dd');
            att.localeventstarttime = DateTime.newInstance(Date.today(), reg.Local_Event_Start_Time__c).format('hh:mm a');
            att.localeventenddate = DateTime.newInstance(reg.Local_Event_End_Date__c.year(), reg.Local_Event_End_Date__c.month(), reg.Local_Event_End_Date__c.day()).format('EEEEE, MMMMM dd');
            att.localeventendtime = DateTime.newInstance(Date.today(), reg.Local_Event_End_Time__c).format('hh:mm a');
                
            //Registration data
            AcquiaContact.data regData = new AcquiaContact.data();
            regData.Name = reg.Name;
            regData.id = Integer.valueOf(reg.Acquia_Id__c);
            regData.attributes = att;
            
            listRegData.add(regData);
        }
        
        //Custom Object Data
        AcquiaContact.data custObjData = new AcquiaContact.data();
        custObjData.id = 1; //this will always be 1
        custObjData.alias = 'registrations'; //this will always be 'registrations'
        custObjData.data = listRegData;
        
        //custom object
        AcquiaContact.customObjects custObjects = new AcquiaContact.customObjects();
        custObjects.data = new List<AcquiaContact.data> { custObjData };
        */
        
        //Contact data
        List<AcquiaContact.All> acquiaRegistrationData = new List<AcquiaContact.All>();
        for(Registration__c reg : registrations){
            AcquiaContact.All aContact = new AcquiaContact.All();
            //aContact.id = String.valueOf(con.Id != null ? con.Acquia_Id__c : reg.Acquia_Id__c);
            aContact.id = String.valueOf(reg.Acquia_Id__c);
            //aContact.title = reg.Contact__r.Title.left(64);
            //aContact.longtitle = reg.Contact__r.Title;
            //v1.1 - 07/18/2021 - CR-20210606-15193 - Added LongTitle to include full title for use in Acquia analytics.
                
            aContact.assistant_name = reg.Contact__r.AssistantName;
            aContact.assistant_email = reg.Contact__r.Asst_Email__c;
            //aContact.contact_status = con.Id != null ? con.Contact_Status__c : reg.Contact__r.Contact_Status__c; // TBD: Chattered to Rachel & MK
            aContact.firstname = reg.Contact__r.FirstName;
            aContact.lastname =  reg.Contact__r.LastName;
            
            aContact.company = reg.Contact__r.Account.Account_Formal_Name__c;
            aContact.address1 = reg.Contact__r.Primary_Address_Line_1__c;
            aContact.address2 = reg.Contact__r.Primary_Address_Line_2__c;
            aContact.city = reg.Contact__r.Primary_City__c;
            aContact.state_abbreviation = reg.Contact__r.Primary_State_Province__c;
            aContact.zipcode = reg.Contact__r.Primary_Postal_Code__c;
            aContact.country1 = reg.Contact__r.Primary_Country__c;// TBD: Chattered to Rachel & MK
            aContact.timezone = reg.Contact__r.Account.Time_Zone_ID__c;
            aContact.preferred_locale = '';
            aContact.points = null;
            
              
            aContact.registeredondate = String.valueOf(reg.Registered_on_Date__c) ;
            
            
            //include custom objects in the contact
            //aContact.customObjects = custObjects;
            aContact.registration_name = reg.name;
            aContact.email = reg.Contact__r.email;
            
            String longEventBeginsDate = String.valueOf(reg.EAB_Event__r.Begins__c.format('EEEEE, MMMMM d'));
            String longEventEndsDate = String.valueOf(reg.EAB_Event__r.Ends__c.format('EEEEE, MMMMM d'));
            
            //Long event date calculation
            if(longEventBeginsDate == longEventEndsDate)
            {
                aContact.longevent_date = longEventBeginsDate;
            }
            else 
            {
                aContact.longevent_date =  longEventBeginsDate+ ' - '+longEventEndsDate;
            }
            
            aContact.eventstartdate = String.valueOf(reg.EAB_Event__r.Begins__c.format('EEEEE, MMMMM d'));
            aContact.eventname = String.valueOf(reg.EAB_Event__r.Public_Name__c);
            aContact.status = reg.Status__c;

            DateTime dtTime = reg.EAB_Event__r.Begins__c;
            aContact.eventdate = Date.newInstance(dtTime.year(), dtTime.month(), dtTime.day());
            String eventime =  dtTime.format('h:mm a').toLowerCase();
             
            if(eventime.contains('am')){
                aContact.eventtime = eventime.replaceAll('am','a.m.');
            }
            else{
                aContact.eventtime = eventime.replaceAll('pm','p.m.');
            }

           
            //v1.1 - 06/04/2021 - CR-20210128-14854 - Modified By - Chirag Soni - QA&UAT Issues (MRS 2.0 Phase 2/3) end.
             
            aContact.location = reg.EAB_Event__r.Location__c;
            //aContact.alternatecontactemail = reg.Alternate_Contact_Email__c;
            aContact.partnerstatus = reg.Partner_Status__c;
            aContact.dinnerrsvp = reg.Dinner_RSVP__c;
            aContact.zoomparticipanturl = reg.Zoom_Participant_URL__c;
            aContact.zoommeetingid = reg.EAB_Event__r.Zoom_Meeting_ID__c;
            aContact.zoomdialinnumber = reg.EAB_Event__r.Zoom_DialIn_Number__c;
            aContact.zoompassword = reg.EAB_Event__r.Zoom_Password__c;
            aContact.onetouchmobiledialin = reg.EAB_Event__r.Zoom_One_Touch_Mobile_Dial_In__c;
            aContact.eventid = String.valueOf(reg.EAB_Event__r.Event_Id__c);
            aContact.registrationapproveddate = String.valueOf(reg.Registration_Approved_Date__c);
            aContact.eventwebsite = reg.EAB_Event__r.Event_Website__c;
            aContact.evaluationlink = reg.EAB_Event__r.Evaluation_Link__c;
            
            //v1.2 - 08/24/2021 - CR-20210606-15193 - Modified - Lawrence Lam- added Local Dates/Times
            aContact.localtimezone = reg.Local_Timezone__c;
            aContact.localeventstartdate = DateTime.newInstance(reg.Local_Event_Start_Date__c.year(), reg.Local_Event_Start_Date__c.month(), reg.Local_Event_Start_Date__c.day()).format('EEEEE, MMMMM d');
            
            
            String localeventstarttime = DateTime.newInstance(Date.today(), reg.Local_Event_Start_Time__c).format('h:mm a').toLowerCase();
            
            if(localeventstarttime.contains('am')){
                aContact.localeventstarttime = localeventstarttime.replaceAll('am','a.m.');
            }
            else{
                aContact.localeventstarttime = localeventstarttime.replaceAll('pm','p.m.');
            }

            aContact.localeventenddate = DateTime.newInstance(reg.Local_Event_End_Date__c.year(), reg.Local_Event_End_Date__c.month(), reg.Local_Event_End_Date__c.day()).format('EEEEE, MMMMM d');
            
            String localeventendtime = DateTime.newInstance(Date.today(), reg.Local_Event_End_Time__c).format('h:mm a').toLowerCase();
            if(localeventendtime.contains('am')){
                aContact.localeventendtime = localeventendtime.replaceAll('am','a.m.'); 
            }
            else{
                aContact.localeventendtime = localeventendtime.replaceAll('pm','p.m.');
            }

            aContact.eventenddate = String.valueOf(reg.EAB_Event__r.Ends__c.format('EEEEE, MMMMM d'));

            String eventendtime =  reg.EAB_Event__r.Ends__c.format('h:mm a').toLowerCase();
            if(eventendtime.contains('am')){
                aContact.eventendtime = eventendtime.replaceAll('am','a.m.');
            }
            else{
                aContact.eventendtime = eventendtime.replaceAll('pm','p.m.');
            }
            acquiaRegistrationData.add(aContact);
        }
        return AcquiaContact.parse(acquiaRegistrationData);
    }
    
    //----------------- Batch Finish Method-----------------//
    global void finish(Database.BatchableContext BC) {
        // execute any post-processing operations
    }
}