/**
 *  Description     :   Service class for Zendesk integration, syncing ZD tickets with SF Cases
 *
 *  Created By      :   Victor Hanson
 *
 *  Created Date    :   08/01/2018
 *
 *  Revision Logs   :   V_1.0 - Created
 *		    :   V_1.1 - Modified By - Victor Hanson - CR-20191204-13549 - 12/04/2019 - clear case map so new case comments are inserted
 *		    :   V_1.2 - Modified By - Neha Sharam - CR-20210205-14877 - 03/18/2021 - Modify couple of method to have proper data type handling
 *		    :   V_1.3 - Modified By - Neha Sharma - CR-20201222-14760
 *		    :   V_1.4 - Modified By - Neha Sharma - Created - CR-20200731-14390 - 08/20/2021
 *		    :   V_1.5 - Modified By - Neha Sharma - CR-20210301-14957
 *		    :   V_1.6 - Modified By - Neha Sharma - CR-20210909-15424
 *		    :   V_1.7 - Modified By - Neha Sharma - 22/1/22 - CR-20211201-15611
**/
public class ZendeskService {
    
    /**
     * static variables
     **/
    final static String TICKET_STATUS_CLOSED = 'closed';
    final static String TICKET_STATUS_SOLVED = 'solved';
    final static String NAMED_CREDENTIALS_URL_PREFIX = 'callout:';
    final static String NAMED_CREDENTIALS_API_NAME = 'Zendesk_Credentials';
    public final static String ZENDESK_CALLOUT_PREFIX = NAMED_CREDENTIALS_URL_PREFIX + NAMED_CREDENTIALS_API_NAME;
    public final static Id RECORD_TYPE_ID_CASE_SSC_SUPPORT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SSC_Support').getRecordTypeId();
    public final static String SYNC_TYPE_TICKETS = 'tickets';
    public final static String SYNC_TYPE_ORGANIZATIONS = 'organizations';
    
    /**
     * variables
     **/
    public ZendeskWrapper zdWrapper { get; set; }
    public Map<Decimal, Case> casesToUpsert { get; set; }
    public List<CaseComment> caseCommentsToInsert { get; set; }
    public Map<Decimal, ZendeskWrapper> ticketIdToZDCommentWrapper { get; set; }
    public String next_page { get; set; }
    public String searchOverride;
    public List<String> zdTicketIdsToSync { get; set; }
    //Modified By - 08/28/2021 - Neha Sharma - Created - CR-20200731-14390
    public Map<Decimal, Site_Issue__c> memberSupportToUpsert { get; set; }
    
    /**
     *	@description	:   Sync tickets updated since this date.
     *
     *  @Revisions	:   V_1.0 - 09/05/2018 - Victor Hanson - Created
     *
     **/
    public Date syncSinceDate {
        get {
            if (syncSinceDate == null) {
                
                //get the last sync date from cache
                syncSinceDate = (date)Cache.Org.get('local.Default.zendeskLastSyncDate');
                if (syncSinceDate != null && syncSinceDate >= system.today())
                    syncSinceDate = null;
                
                //if there is no last sync date found, default to yesterday
                if (syncSinceDate == null) {
                    syncSinceDate = Date.today().addDays(-1);
                }
            }
            return syncSinceDate;
        }
        set;
    }
    
    /**
     *	@description	:   constructor
     *
     *  @Revisions	:   V_1.0 - 09/05/2018 - Victor Hanson - Created
     *
     **/
    public ZendeskService() {
        caseCommentsToInsert = new List<CaseComment>();
        ticketIdToZDCommentWrapper = new Map<Decimal, ZendeskWrapper>();
        zdTicketIdsToSync = new List<String>();
    }
    
    /**
     *   @description   :   Search for tickets to since since syncSinceDate, then populates the ids in zdTicketIdsToSync.
     *
     *  @Revisions	:   V_1.0 - 09/05/2018 - Victor Hanson - Created
     *
     **/
    public void getTicketsToSync() {
        zdTicketIdsToSync = new List<String>();
        HTTPResponse res = zendeskCallout(getSearchURL());
        
        //Updated by - Neha Sharam - 03/18/2021 - CR-20210205-14877
        //Start from here
        //I'd like to deserialize to the existing object if possible, so instead, can we do the following:
        //When the tickets are received, use deserializeUntyped 
        Map<String, Object> mapOfResponseBody = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        mapOfResponseBody = processResponseForDeserialization(mapOfResponseBody);
        
        //Once all non-string custom_field values are converted to strings, deserialize to ZendeskWrapper.class as usual
        zdWrapper = (ZendeskWrapper) JSON.deserialize(JSON.serialize(mapOfResponseBody), ZendeskWrapper.class);
        //End here
        
        next_page = zdWrapper.next_page;
        
        for (ZendeskWrapper.zdTicket ticket : zdWrapper.results) 
        {
            zdTicketIdsToSync.add(String.valueOf(ticket.id));
        }
    }
    
    /**
*   @description    :   returns the full search url
*
*  @Revisions       :   V_1.0 - 09/05/2018 - Victor Hanson - Created
*
**/
    public String getSearchURL() {
        
        if (searchOverride != null) return searchOverride;
        
        String searchURL;
        
        //if next page url is null, get tickets updated since the last sync date
        if (next_page == null) {
            
            searchURL = ZENDESK_CALLOUT_PREFIX + 
                String.format(Label.Zendesk_Search_Endpoint,
                              new List<String>{ DateTime.newInstance(syncSinceDate.year(), 
                                                                     syncSinceDate.month(), 
                                                                     syncSinceDate.day())
                                  .format('yyyy-MM-dd') }
                             );
        }
        else {
            //convert url from standard form (http://...) to sf callout format including namedCredential (callout:...)
            URL calloutURL = new URL(next_page);
            searchURL = ZENDESK_CALLOUT_PREFIX + calloutURL.getPath() + '?' + calloutURL.getQuery();
        }
        return searchURL;
    }
    
    /** returns the full ticket url **/
    //
    /**
     *   @description    :   returns the full ticket url
     *                       ie: https://gradesfirst.zendesk.com/api/api/v2/tickets/show_many.json?ids={0}
     *                       &include=comment_count,users,organizations&sort_by=updated_at&sort_order=desc
     *
     *  @Revisions       :   V_1.0 - 09/05/2018 - Victor Hanson - Created
     *
     **/
    public String getTicketURL() {
        String ticketURL = ZENDESK_CALLOUT_PREFIX + 
            String.format(Label.Zendesk_Ticket_Endpoint,
                          new List<String>{ String.join(zdTicketIdsToSync, ',') }
                         );
        if (test.isRunningTest()) ticketURL = 'ticketURL';
        return ticketURL;
    }
    
    /** returns the full ticket comment url **/
    public String getTicketCommentURL(Decimal zdId) {
        return ZENDESK_CALLOUT_PREFIX + String.format(
            Label.Zendesk_Ticket_Comment_Endpoint,
            new List<String> {
                String.valueOf(zdId)
                    }
        );
    }
    
    /**
     *   @description    :   calls the Zendesk endpoint to Get Tickets
     *
     *  @Revisions       :   V_1.0 - 08/01/2018 - Victor Hanson - Created
     *
     **/
    public void getTickets() {
        ticketIdToZDCommentWrapper = new Map<Decimal, ZendeskWrapper>();
        getTicketsToSync();
        
        if (zdTicketIdsToSync.size() > 0) {
            
            HTTPResponse res = zendeskCallout(getTicketURL());           
            //Updated by - Neha Sharam - 03/18/2021 - CR-20210205-14877
            //Start here
            Map<String, Object> mapOfResponseBody = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            mapOfResponseBody = processResponseForDeserialization(mapOfResponseBody);
            //Once all non-string custom_field values are converted to strings, deserialize to ZendeskWrapper.class as usual
            zdWrapper = (ZendeskWrapper) JSON.deserialize(JSON.serialize(mapOfResponseBody), ZendeskWrapper.class);
            //End here
            
            //populate the map of existing cases to be updated
            populateCaseMap();
        }
        
        //update last sync date
        Cache.Org.put('local.Default.zendeskLastSyncDate', Date.today());
    }
    
    /**
     *   @description    :   perform the callout to zendesk
     *
     *  @Revisions       :   V_1.0 - 08/01/2018 - Victor Hanson - Created
     *
     **/
    public HttpResponse zendeskCallout(String endpoint) {
        return zendeskCallout(endpoint, 'GET', null);
    }
    
    /**
     *   @description    :   perform the callout to zendesk with options
     *
     *  @Revisions       :   V_1.0 - 08/01/2018 - Victor Hanson - Created
     *
     **/
    public HttpResponse zendeskCallout(String endpoint, String method, String body) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setTimeout(120000);
        req.setMethod(method);
        if (body != null) {
            req.setHeader('content-type', 'application/json');
            req.setBody(body);
        }
        
        Http http = new Http();
        HTTPResponse res = http.send(req);
        
        //check for bad response code
        if (res.getStatusCode() != 200) {
            throw new customException('REQUEST:\r\n' + req + '\r\n\r\nRESPONSE:\r\n' + res.getBody());
        }
        
        return res;
    }
    
    /**
     *   @description    :   populate the map of cases to be upserted
     *
     *  @Revisions       :   V_1.0 - 08/02/2018 - Victor Hanson - Created
     *			         :   V_1.1 - Modified By - 04/28/2021 - Neha Sharma - Created - CR-20200731-14390
     *
     **/
    public void populateCaseMap() {
        
        casesToUpsert = new Map<Decimal, Case>();
        memberSupportToUpsert = new Map<Decimal, Site_Issue__c>();
        
        if (zdWrapper.tickets.size() > 0) {
            
            //Modified By - Neha Sharma - 19/10/21 - CR-20210301-14957 - modify query - added Case_Category__c field
            //get all related cases
            for (Case c : [SELECT Id, (Select Id,Case__c,Zendesk_Ticket_Id__c from Member_Support__r) Zendesk_Ticket_Id__c, Product_Name__c,Create_Member_Support_Ticket__c,RecordTypeId, Requester_Lead__c,
                           ContactId, Subject, Zendesk_Ticket_Id__c,Description, Case_Category__c,Type, Priority,
                           Status, OwnerId, AccountId, Tags__c, Project_Source_MS__c
                           FROM Case
                           WHERE Zendesk_Ticket_Id__c IN :zdWrapper.ticketMap.keySet()])
            {
                
                casesToUpsert.put(c.Zendesk_Ticket_Id__c, c);
                if(c.Member_Support__r.size() > 0){
                    Site_Issue__c memSupport = c.Member_Support__r[0];
       				memberSupportToUpsert.put(c.Zendesk_Ticket_Id__c,memSupport);
                }
                	
            }
            
            //loop through all tickets, creating cases if they don't already exist
            for (ZendeskWrapper.zdTicket ticket : zdWrapper.tickets) {
                casesToUpsert.put(ticket.id, getCaseFromTicket(ticket));
                
                //performs a callout to get the individual ticket's comments
                getZDComments(ticket.id);
            }
            
            
            
            
            //Modified By - 04/28/2021 - Neha Sharma - Created - CR-20200731-14390
            if(casesToUpsert.size() > 0)
            {
                for(Case ca : casesToUpsert.values()){
                    if(ca.Create_Member_Support_Ticket__c == true){
                        Site_Issue__c memberSupport ;
                        if(memberSupportToUpsert.containsKey(ca.Zendesk_Ticket_Id__c))
                        {
                            memberSupport = memberSupportToUpsert.get(ca.Zendesk_Ticket_Id__c);
                        }
                        else{
                            memberSupport = new Site_Issue__c();
                        }
                        memberSupport.Case__c = ca.Id;
                        memberSupport.RecordTypeId = constants.MEMBER_SUPPORT_SSC_RMS_RT_ID;
                        memberSupport.Project__c = ca.Project_Source_MS__c;
                        memberSupport.Drill_Down_Information__c = Label.Zendesk_URL + ca.Zendesk_Ticket_Id__c;
                        memberSupport.Site_Issue_Priority__c = ca.Priority;
                        //Modified By - Neha Sharma - 22/1/22 - CR-20211201-15611
                         if (zdWrapper.zdProductToProductModuleAffectedMap.size() > 0) 
                        {
                            memberSupport.Product_Triage__c = zdWrapper.zdProductToProductModuleAffectedMap.get(ca.Product_Name__c);
                        }
                        //Modified By - Neha Sharma - 19/10/21 - CR-20210301-14957 - start
                        if (zdWrapper.zdIssuecategoryToSupportCategoryMap.size() > 0) 
                        {
                            memberSupport.Support_Category__c = zdWrapper.zdIssuecategoryToSupportCategoryMap.get(ca.Case_Category__c);
                        }
                        //Modified By - Neha Sharma - 19/10/21 - CR-20210301-14957 - end
                        //Modified By - Neha Sharma - 22/1/22 - CR-20211201-15611
                        memberSupport.status__c = 'New';
                        memberSupport.Tier__c = 'Tier I';
                        memberSupport.Institution__c = ca.AccountId; 
                        //Modified By - Neha Sharma - CR-20210301-14957
                        memberSupport.Site_Issue_Short_Description__c = ca.Subject;
                        memberSupportToUpsert.put(ca.Zendesk_Ticket_Id__c,memberSupport);
                    }
                }
            }
        }
    }
    
    /**
     *   @description    :   Sync the Ticket details to the Case
     *
     *  @Revisions       :   V_1.0 - 08/02/2018 - Victor Hanson - Created
     *
     **/
    private Case getCaseFromTicket(ZendeskWrapper.zdTicket ticket) {
        
        //get the case or create new
        Case c = casesToUpsert.get(ticket.id);
        if (c == null) {
            c = new Case(RecordTypeId = RECORD_TYPE_ID_CASE_SSC_SUPPORT,
            Zendesk_Ticket_Id__c = ticket.id);
            //if it's a newly created case, set the created at time to the ticket's created date/time
            c.CreatedDate = ticket.created_at;
            
            //if the status is closed when created, set the closed date/time
            if (ticket.status != null && (ticket.status.equalsIgnoreCase(TICKET_STATUS_CLOSED) 
                                          || ticket.status.equalsIgnoreCase(TICKET_STATUS_SOLVED)))
                c.ClosedDate = ticket.updated_at;
        }
        
        //get the requester and set either the contact or requester lead
        SObject requester = zdWrapper.zdUserIdToSObjectMap.get(ticket.requester_id);
        if (requester != null) {
            if (requester.getSObjectType() == Contact.sObjectType)
                c.ContactId = requester.Id;
            else if (requester.getSObjectType() == Lead.sObjectType)
                c.Requester_Lead__c = requester.Id;
        }
        else {
            if (zdWrapper.userMap != null && zdWrapper.userMap.get(ticket.requester_id) != null) {
                c.ZD_Requester_Name__c = zdWrapper.userMap.get(ticket.requester_id).name;
            }
        }
        
        //set the institution based on the Ticket 'organization.salesforce_id' field
        ZendeskWrapper.zdOrganization zdOrg = zdWrapper.organizationMap.get(ticket.organization_id);
        if (zdOrg != null && zdOrg.organization_fields.salesforce_id != null) {
            String counterId = zdOrg.organization_fields.salesforce_id;
        
            
            //get the account from counter Id and assign to case
            Account a = zdWrapper.counterIdToAccountMap.get(counterId);
            if (a != null) c.AccountId = a.Id;
        }
        
        if (ticket.status != null && ticket.status.equalsIgnoreCase(TICKET_STATUS_SOLVED))
            ticket.status = TICKET_STATUS_CLOSED;
        
        //sync the case fields
        c.OwnerId = getOwnerId(ticket.assignee_id);
        c.Subject = ticket.subject;
        c.Description = ticket.description;
        c.Type = ticket.type;
        c.Priority = ticket.priority;
        c.Status = ticket.status;
        c.Tags__c = ticket.getTags();
        
        //abbreviate fields just in case they exceed allowed size
        if (c.Subject != null && c.Subject.length() > 255)
            c.Subject = c.Subject.abbreviate(255);
        if (c.Description != null && c.Description.length() > 32000)
            c.Description = c.Description.abbreviate(32000);
        
        //populate origin with channel value if present
        if (ticket.via != null)
            c.Origin = ticket.via.channel;
        
        //populate satisfaction rating if present & NOT ('offered' or 'unoffered')
        if (ticket.satisfaction_rating != null && !ticket.satisfaction_rating.score.contains('offered') ) {
            c.Satisfaction_Rating__c = ticket.satisfaction_rating.score;
        }
	// Modified By - Neha Sharma - CR-20201222-14760
        boolean componentPopulated = false;
        
        
        //populate custom fields from ZD to SF using the custom data mapping defined in Sync Fields object
        for (ZendeskWrapper.zdCustomField zdField : ticket.custom_fields) {
            
            //continue to next record if null
            if (zdField.value == null) continue;
            
            Sync_Field__c syncField = ZendeskWrapper.zdFieldToSyncMap.get(String.valueOf(zdField.id));
            if (syncField != null) {
                
                //must type cast due to uncertain field type
                if (syncField.Target_Field_Type__c != null &&
                    syncField.Target_Field_Type__c.equalsIgnoreCase('String')) 
                {
                    // Modified By - Neha Sharma - CR-20201222-14760
                    if(String.valueOf(syncField.Target_Field_API_Name__c) == 'Component__c')
                    {
                        if(String.valueOf(zdField.value) != 'null')
                        {
                            c.put(String.valueOf(syncField.Target_Field_API_Name__c), String.valueOf(zdField.value).replaceAll('_', ' '));
                            componentPopulated = True;
                        } 
                        else if(componentPopulated == false){
                            c.put(String.valueOf(syncField.Target_Field_API_Name__c), String.valueOf(zdField.value));
                        }
                    }
                    else{
                        c.put(String.valueOf(syncField.Target_Field_API_Name__c), String.valueOf(zdField.value).replaceAll('_', ' '));
                    }
                }
                else if (String.isNotBlank(syncField.Target_Field_Type__c) &&
                         syncField.Target_Field_Type__c.equalsIgnoreCase('Integer')) 
                {
                    try
                    {
                        c.put(String.valueOf(syncField.Target_Field_API_Name__c), Integer.valueOf(zdField.value));
                    }
                    catch(Exception e) {}
                }
                else if (String.isNotBlank(syncField.Target_Field_Type__c) &&
                         syncField.Target_Field_Type__c.equalsIgnoreCase('Decimal')) 
                {
                    try
                    {
                        c.put(String.valueOf(syncField.Target_Field_API_Name__c), Decimal.valueOf(Double.valueOf(zdField.value)));
                    }
                    catch(Exception e) {}
                }
		//Modified By - 04/28/2021 - Neha Sharma - Created - CR-20200731-14390
                 else if (String.isNotBlank(syncField.Target_Field_Type__c) &&
                         syncField.Target_Field_Type__c.equalsIgnoreCase('Boolean')) 
                {
                    try
                    {
                        c.put(String.valueOf(syncField.Target_Field_API_Name__c), Boolean.valueOf(zdField.value));
                    }
                    catch(Exception e) {}
                }
                //Modified By - Neha Sharma - 6/21/21 - CR-20201222-14760 - End here
            }
        }
        
        //get the projects for the related institution
        String counterId = zdWrapper.getCounterId(ticket);
        
        //clear project field, because if the Product changes, we want to re-assign the project or leave it blank
        c.Project_Source_MS__c = null;
        List<Project__c> projects = zdWrapper.counterIdToProjectMap.get( counterId );
        
        //get the set of acronyms that correspond to the ticket's Product
        Set<String> validAcronymsForProduct = zdWrapper.zdProductToAcronymMap.get( c.Product_Name__c );
        
        if (projects != null) {
            for (Project__c proj : projects) {
                
                //if the project is in the list of acronyms, set the Case's Project
                if (validAcronymsForProduct != null && validAcronymsForProduct.contains(proj.Program_Acronym__c)) {
                    c.Project_Source_MS__c = proj.Id;
                    
                    //if the case's Institution is blank, populate it with the project's institution
                    if (c.AccountId == null) c.AccountId = proj.Institution__c;
                }
            }
        }
        return c;
    }
    
    /**
     *   @description    :   Get the case owner id based on the Zendesk assignee_id
     *
     *  @Revisions       :   V_1.0 - 08/02/2018 - Victor Hanson - Created
     *                      V_1.1 - 12/04/2019 - Victor Hanson - Modified - added logic to address chatter user problems
     *
     **/
    private Id getOwnerId(Decimal assigneeId) {
        Id caseOwnerId;
        User u = zdWrapper.zdUserIdtoSFUserMap.get(assigneeId);
        
        //if the assignee_id doesn't correspond to a SF User OR it is a user without access to Cases, assign to generic after hours user
        if (u == null || !zdWrapper.profileIdsWithCaseAccess.contains(u.ProfileId)) {
            caseOwnerId = Label.After_Hours_User_Id;
        }
        else {
            caseOwnerId = u.Id;
        }
        return caseOwnerId;
    }
    
    /**
     *   @description    :   Upsert Cases
     *
     *  @Revisions       :   V_1.0 - 08/02/2018 - Victor Hanson - Created
     *
     **/
    public List<Database.UpsertResult> upsertCases() {
        util.BypassAllTriggers = true;
        List<Database.UpsertResult> upsertResults = database.upsert(casesToUpsert.values(), false);
        util.BypassAllTriggers = false;
        List<Web_Service_Log__c> errorLogs = new List<Web_Service_Log__c>();
        
        for(Integer i = 0, size = upsertResults.size(); i < size; i++) {
            if(!upsertResults[i].isSuccess()) {
                errorLogs.add(getErrorLog(casesToUpsert.values()[i], upsertResults[i]));
            }
        }
        
        if (errorLogs.size() > 0)
            insert errorLogs;
        
        return upsertResults;
    }
    
     /**
     *   @description    :   Upsert Member Support
     *
     *  @Revisions       :   V_1.0 - 04/28/2021 - Neha Sharma - Created - CR-20200731-14390
     *			     V_1.1 - Neha Sharma - 19/10/21 - CR-20210301-14957
     *
    **/
    public List<Database.UpsertResult> upsertMemberSupport() {
        if(zdTicketIdToCaseMap.size() > 0)
        {
            for(Case ca : zdTicketIdToCaseMap.values())
            {
                if(memberSupportToUpsert.size() > 0)
                {
                    if(memberSupportToUpsert.containsKey(ca.Zendesk_Ticket_Id__c) && memberSupportToUpsert.get(ca.Zendesk_Ticket_Id__c).Case__c == null)
                    {
                        memberSupportToUpsert.get(ca.Zendesk_Ticket_Id__c).Case__c = ca.Id;
                        if(caseCommentsToInsert.size() > 0 && caseCommentsToInsert[caseCommentsToInsert.size()-1].parentId == ca.Id)
                        {
                             memberSupportToUpsert.get(ca.Zendesk_Ticket_Id__c).Crimson_Site_Issue_Description__c = caseCommentsToInsert[caseCommentsToInsert.size()-1].CommentBody;
                        }
                       
                    } 
                }
            }
        }
        util.BypassAllTriggers = true;
        List<Database.UpsertResult> upsertResults = database.upsert(memberSupportToUpsert.values(), false);
        util.BypassAllTriggers = false;
        List<Web_Service_Log__c> errorLogs = new List<Web_Service_Log__c>();
        
        for(Integer i = 0, size = upsertResults.size(); i < size; i++) {
            if(!upsertResults[i].isSuccess()) {
                errorLogs.add(getErrorLog(memberSupportToUpsert.values()[i], upsertResults[i]));
            }
            
        }
        
        if (errorLogs.size() > 0)
            insert errorLogs;
        
        return upsertResults;
    }
    
    /**
     *   @description    :   Upsert Case Comments
     *
     *  @Revisions       :   V_1.0 - 08/10/2018 - Victor Hanson - Created
     *                       V_1.1 - 12/04/2019 - Victor Hanson - Modified - CR-20191204-13549 - Removed unnecessary code
     *
    **/
    public List<Database.UpsertResult> upsertCaseComments() {
        
        util.BypassAllTriggers = true;
        List<Database.UpsertResult> upsertResults = database.upsert(caseCommentsToInsert, false);
        util.BypassAllTriggers = false;
        List<Web_Service_Log__c> errorLogs = new List<Web_Service_Log__c>();
        
        for(Integer i = 0, size = upsertResults.size(); i < size; i++) {
            if(!upsertResults[i].isSuccess()) {
                errorLogs.add(getErrorLog(caseCommentsToInsert[i], upsertResults[i]));
            }
        }
        
        if (errorLogs.size() > 0)
            insert errorLogs;
        
        return upsertResults;
    }
    
    /**
     * returns an error log based on an sObject and upsertResult
     **/
    /**
     *   @description    :   
     *
     *  @Revisions       :   V_1.0 - 09/05/2018 - Victor Hanson - Created
     *
     **/
    @TestVisible private Web_Service_Log__c getErrorLog(SObject sObj, Database.UpsertResult upsertResult) {
        return new Web_Service_Log__c(RecordTypeId = Schema.SObjectType.Web_Service_Log__c.RecordTypeInfosByDeveloperName.get('Default').RecordTypeId,
                                      //External_Id__c = sObj.get('Zendesk_Ticket_Id__c') != null ? (String) sObj.get('Zendesk_Ticket_Id__c') : null,
                                      Web_Service_Method__c = 'Zendesk ' + String.valueOf(sObj.getSObjectType()) + ' upsert',
                                      Request_Sent__c = system.now(),
                                      Request_Message_Log__c = JSON.serializePretty(sObj),
                                      Response_Message_Log__c = JSON.serializePretty(upsertResult.getErrors()),
                                      Response_Message__c = 'Error');
    }
    
    /**
     *   @description    :   calls the Zendesk endpoint to Get Ticket Comments
     *
     *  @Revisions       :   V_1.0 - 08/10/2018 - Victor Hanson - Created
     *                      V_1.1 - 12/04/2019 - Victor Hanson - CR-20191204-13549 - added replaceAll to first portion of zdCommentBody
     *
     **/
    public void getZDComments(Decimal ticketId) {
        
        HTTPResponse res = zendeskCallout(getTicketCommentURL(ticketId));
        
        //VH 9/30/18: had to replace public with xpublic due to reserved word
        //VH 10/15/18: Also had to split the resBody into 4 parts due to "Regex too complicated" error
        //which was caused by using substring() on a large string (2mb+)
        String zdCommentBody = '';
        Integer n = (res.getBody().length()/4);
        zdCommentBody = res.getBody().substring(0, n).replaceAll('"public"', '"xpublic"');
        zdCommentBody += res.getBody().substring(n, (n*2)).replaceAll('"public"', '"xpublic"');
        zdCommentBody += res.getBody().substring((n*2), (n*3)).replaceAll('"public"', '"xpublic"');
        zdCommentBody += res.getBody().substring((n*3)).replaceAll('"public"', '"xpublic"');
        
        //String zdCommentBody = res.getBody().replaceAll('"public"', '"xpublic"');
        
        //Updated by - Neha Sharam - 03/18/2021 - CR-20210205-14877
        //Start here
        Map<String, Object> mapOfResponseBody = (Map<String, Object>) JSON.deserializeUntyped(zdCommentBody);
        mapOfResponseBody = processResponseForDeserialization(mapOfResponseBody);
        
        //Once all non-string custom_field values are converted to strings, deserialize to ZendeskWrapper.class as usual
        ZendeskWrapper zdCommentWrapper = (ZendeskWrapper) JSON.deserialize(JSON.serialize(mapOfResponseBody), ZendeskWrapper.class);
        //End here
        
        //populate the map of existing cases to be updated
        ticketIdToZDCommentWrapper.put(ticketId, zdCommentWrapper);
    }
    
    /**
     *   @description    :   populate the map of CaseComments to be inserted
     *
     *  @Revisions       :   V_1.0 - 08/02/2018 - Victor Hanson - Created
     *                       V_1.1 - 12/04/2019 - Victor Hanson - Modified - CR-20191204-13549 - clear case map
     *
     **/
    public void populateCaseCommentMap() {
        //clear the case map
        zdTicketIdToCaseMap = null;
        caseCommentsToInsert = new List<CaseComment>();
        
        if (zdTicketIdToCaseMap.size() > 0) {
            for (Case c : zdTicketIdToCaseMap.values()) {
                
                //get the list of Case Comments and Zendesk Ticket Comments
                List<CaseComment> existingCaseComments = c.CaseComments;
                ZendeskWrapper commentWrapper = ticketIdToZDCommentWrapper.get(c.Zendesk_Ticket_Id__c);
                
                //are there more zdComments than existing case comments?  If so, sync the new comments from ZD to SF
                if (commentWrapper != null && commentWrapper.comments.size() > existingCaseComments.size()) {
                    
                    //if some comments have already been synced with the Case, only insert the new Comments
                    integer startInt = existingCaseComments.size(); //existingCaseComments.size() > 0 ? existingCaseComments.size()-1 : existingCaseComments.size();
                    for (integer i = startInt; i < commentWrapper.comments.size(); i++) {
                        caseCommentsToInsert.add(getCaseComment(c.Id, commentWrapper.comments[i], commentWrapper));
                    }
                    //Modified By - Neha Sharma - 19/10/21 - CR-20210301-14957
		    //Modified By - Neha Sharma - CR-20210909-15424
                    if( memberSupportToUpsert != null && memberSupportToUpsert.size() > 0){
                        if(memberSupportToUpsert.get(c.Zendesk_Ticket_Id__c).Case__c  == c.Id)
                        {
                            memberSupportToUpsert.get(c.Zendesk_Ticket_Id__c).Crimson_Site_Issue_Description__c = commentWrapper.comments[commentWrapper.comments.size() - 1].plain_body;
                            
                        }
                    }
                }
            }
        }
    }
    
    /**
     *   @description    :   populate the CaseComment based on the Zendesk Comment
     *
     *  @Revisions       :   V_1.0 - 08/10/2018 - Victor Hanson - Created
     *
     **/
    private CaseComment getCaseComment(Id caseId, ZendeskWrapper.zdComment zdComment, ZendeskWrapper commentWrapper) {
        //get the author details
        ZendeskWrapper.zdUser author = commentWrapper.userMap.get(zdComment.author_id);
        
        //if the author is a SF User, get their SF ID and set them as the creator
        Id authorUserId;
        if (commentWrapper.zdUserIdtoSFUserMap != null && commentWrapper.zdUserIdtoSFUserMap.containsKey(zdComment.author_id))
            authorUserId = commentWrapper.zdUserIdtoSFUserMap.get(zdComment.author_id).Id;
        
        String commentBody = author.name + ' [' + author.email + '] ';
        commentBody += zdComment.created_at.format() + '\n';
        commentBody += zdComment.plain_body;
        commentBody = commentBody.abbreviate(3000);
        if (zdComment.xpublic == null) zdComment.xpublic = false;
        return new CaseComment(ParentId = caseId,
                               CommentBody=commentBody,
                               CreatedDate = zdComment.created_at,
                               CreatedById = authorUserId,
                               IsPublished = zdComment.xpublic);
    }
    
    /**
     *   @description    :   map of zdTicketId => Case
     *
     *  @Revisions       :   V_1.0 - 08/10/2018 - Victor Hanson - Created
     *
     **/
    private Map<Decimal, Case> zdTicketIdToCaseMap {
        get {
            if (zdTicketIdToCaseMap == null) {
                zdTicketIdToCaseMap = new Map<Decimal, Case>();
                
                if (zdWrapper.ticketMap != null) {
                    
                    //get all related cases w/CaseComments
                    for (Case c : [SELECT Id, Zendesk_Ticket_Id__c, 
                                   (SELECT Id, CreatedDate FROM CaseComments ORDER BY CreatedDate ASC)
                                   FROM Case
                                   WHERE Zendesk_Ticket_Id__c IN :zdWrapper.ticketMap.keySet()])
                    {
                        zdTicketIdToCaseMap.put(c.Zendesk_Ticket_Id__c, c);
                    }
                }
            }
            return zdTicketIdToCaseMap;
        }
        set;
    }
    
    //Modify Neha Sharma - CR-20210301-14957
    public Map<String, List<ZendeskWrapper.zdUser>> getProjectRoles(Set<Id> contactIds) {
        
        //get contacts with project roles and add them to the users list
        Map<String, List<ZendeskWrapper.zdUser>> usersMap = new Map<String, List<ZendeskWrapper.zdUser>>();
        
        for (Contact c : [SELECT Id, Email, Name, Account.Zendesk_Id__c,
                          (SELECT Contact__c, Role__c, Project__r.Product__r.Program_Acronym__c, 
                           Project__r.Primary_Paid_Membership__r.Membership_Status_Text__c, Notes__c
                           FROM Project_Roles__r 
                           WHERE Project__r.Product__r.Integration_Support__c = :Constants.ZENDESK)
                          FROM Contact WHERE Id IN :contactIds]) 
        {
            List<ZendeskWrapper.zdUser> zdUserList = usersMap.get('users');
            
            if (zdUserList == null) zdUserList = new List<ZendeskWrapper.zdUser>();
            ZendeskWrapper.zdUser zdUser = new ZendeskWrapper.zdUser();
            zdUser.email = c.Email;
            zdUser.name = c.Name;
            zdUser.organization_id = c.Account.Zendesk_Id__c;
            //zdUser.organization_id = c.Account.Zend
            ZendeskWrapper.zdUser_Fields zdUserFields = new ZendeskWrapper.zdUser_Fields();
            zdUserFields.project_role = '';
            zdUserFields.project_role_notes = '';
            for(Project_Role__c pr : c.Project_Roles__r) {
                zdUserFields.project_role += '[' + pr.Project__r.Product__r.Program_Acronym__c + ' - ' + pr.Role__c + ']\r\n';
                
                if (pr.notes__c != null) {
                    zdUserFields.project_role_notes += '[' + pr.Project__r.Product__r.Program_Acronym__c + ' - ' + pr.Notes__c + ']\r\n';
                }
            }
            zdUser.user_fields = zdUserFields;
            zdUserList.add(zdUser);
            usersMap.put('users', zdUserList);
        }
        
        //send to zendesk
        return usersMap;
    }
    
    
    //Modify Neha Sharma - CR-20210301-14957
    public Map<String, List<ZendeskWrapper.zdUser>> getMembershipKeyContactRole(Set<Id> contactIds,Map<Id, Map<Double, List<Membership_Key_Contact__c>>> mapOfContactWithMembershipKeyCon) {
        
        //get contacts with project roles and add them to the users list
        Map<String, List<ZendeskWrapper.zdUser>> usersMap = new Map<String, List<ZendeskWrapper.zdUser>>();
        
        for (Contact c : [SELECT Id, Email, Name, Account.Zendesk_Id__c
                          FROM Contact WHERE Id IN :contactIds]) 
        {
            List<ZendeskWrapper.zdUser> zdUserList = usersMap.get('users');
            
            if (zdUserList == null) zdUserList = new List<ZendeskWrapper.zdUser>();
            ZendeskWrapper.zdUser zdUser = new ZendeskWrapper.zdUser();
            zdUser.email = c.Email;
            zdUser.name = c.Name;
            zdUser.organization_id = c.Account.Zendesk_Id__c;
            ZendeskWrapper.zdUser_Fields zdUserFields = new ZendeskWrapper.zdUser_Fields();
            zdUserFields.membership_key_contact_role = '';
            
            //Modified By - Neha Sharma - CR-20210301-14957
            if(mapOfContactWithMembershipKeyCon.size() > 0 && mapOfContactWithMembershipKeyCon.containsKey(c.Id))
            {
                if(mapOfContactWithMembershipKeyCon.get(c.Id).containsKey(c.Account.Zendesk_Id__c)){

                    for(Membership_Key_Contact__c memKayCon : mapOfContactWithMembershipKeyCon.get(c.Id).get(c.Account.Zendesk_Id__c)){

                        zdUserFields.membership_key_contact_role += '['+ memKayCon.Membership__r.Program_Acronym__c + ' - '+ memKayCon.Role__c + ']\r\n';
                    }
                } 
               
            }
            zdUser.user_fields = zdUserFields;
            zdUserList.add(zdUser);
            usersMap.put('users', zdUserList);
        }
        
        
        //send to zendesk
        return usersMap;
    }
    
    
    /**
     *   @description    :   calls the Zendesk endpoint to POST user details with project role
     *
     *  @Revisions       :   V_1.0 - 08/10/2018 - Victor Hanson - Created
     *
     **/
    public void syncProjectRoles(Set<Id> contactIds) {
        
        Map<String, List<ZendeskWrapper.zdUser>> userMap = getProjectRoles(contactIds);
        
        //if there are users with project roles to send to ZD, perform the callout
        if (userMap.size() > 0) {
            HTTPResponse res = zendeskCallout(ZENDESK_CALLOUT_PREFIX + Label.Zendesk_Create_or_Update_Many, 'POST', JSON.serialize(getProjectRoles(contactIds)));
            
            
            //Updated by - Neha Sharam - 03/18/2021 - CR-20210205-14877
            //Start here
            Map<String, Object> mapOfResponseBody = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            mapOfResponseBody = processResponseForDeserialization(mapOfResponseBody);
            
            //Once all non-string custom_field values are converted to strings, deserialize to ZendeskWrapper.class as usual
            ZendeskWrapper zdUserSyncWrapper = (ZendeskWrapper) JSON.deserialize(JSON.serialize(mapOfResponseBody), ZendeskWrapper.class);
            //End here
        }
    }
    
    /**
     *   @description    :   calls the Zendesk endpoint to POST user details with membershipKeyContact role
     *
     *   @Revisions      :   V_1.0 - Modified By - Neha Sharma - 19/10/21 - CR-20210301-14957
     *
     **/
    public void syncMembershipKeyContactRoleRoles(Set<Id> contactIds, Map<Id, Map<Double, List<Membership_Key_Contact__c>>> mapOfContactWithMembershipKeyCon ) {
        
        Map<String, List<ZendeskWrapper.zdUser>> userMap = getMembershipKeyContactRole(contactIds,mapOfContactWithMembershipKeyCon);
        
        //if there are users with project roles to send to ZD, perform the callout
        if (userMap.size() > 0) {
            HTTPResponse res = zendeskCallout(ZENDESK_CALLOUT_PREFIX + Label.Zendesk_Create_or_Update_Many, 'POST', JSON.serialize(getMembershipKeyContactRole(contactIds,mapOfContactWithMembershipKeyCon)));
            
            Map<String, Object> mapOfResponseBody = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            mapOfResponseBody = processResponseForDeserialization(mapOfResponseBody);
            
            ZendeskWrapper zdUserSyncWrapper = (ZendeskWrapper) JSON.deserialize(JSON.serialize(mapOfResponseBody), ZendeskWrapper.class);
            
        }
    }
    
    /**
     *   @description    :   return the organization list endpoint
     *                       ie: https://gradesfirst1437647639.zendesk.com/api/v2/organizations.json
     *
     *  @Revisions       :   V_1.0 - 08/01/2018 - Victor Hanson - Created
     *
     **/
    public String getOrganizationListEndpoint() {
        String orgEndpoint;
        if (next_page == null) {
            orgEndpoint = ZENDESK_CALLOUT_PREFIX + Label.Zendesk_Organizations_Endpoint;
        }
        else {
            URL calloutURL = new URL(next_page);
            orgEndpoint = ZENDESK_CALLOUT_PREFIX + calloutURL.getPath() + '?' + calloutURL.getQuery();
        }
        return orgEndpoint;
    }
    
    /**
     *   @description    :   sync organization and membership data with zendesk
     *
     *  @Revisions       :   V_1.0 - 08/01/2018 - Victor Hanson - Created
     *
     **/
    public void syncOrganizations() {
        
        //1. get orgs from zendesk
        Map<String, Decimal> counterIdToOrgId = new Map<String, Decimal>();
        List<ZendeskWrapper.zdOrganization> zdOrgsToUpdate = new List<ZendeskWrapper.zdOrganization>();
        HTTPResponse res = zendeskCallout(getOrganizationListEndpoint(), 'GET', null);
        
        //Updated by - Neha Sharam - 03/18/2021 - CR-20210205-14877
        //Start here
        Map<String, Object> mapOfResponseBody = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        mapOfResponseBody = processResponseForDeserialization(mapOfResponseBody);
        
        //Once all non-string custom_field values are converted to strings, deserialize to ZendeskWrapper.class as usual
        zdWrapper = (ZendeskWrapper) JSON.deserialize(JSON.serialize(mapOfResponseBody), ZendeskWrapper.class);
        //End here
        
        next_page = zdWrapper.next_page;
        
        for (ZendeskWrapper.zdOrganization zdOrg : zdWrapper.organizations) {
            if (zdOrg.organization_fields.salesforce_id != null) {
                counterIdToOrgId.put(zdOrg.organization_fields.salesforce_id, zdOrg.id);
            }
            
        }
        
        //2. map those orgs to SF Institutions, updating the Account.Zendesk_Id__c field
        List<Account> acctsToUpdate = [SELECT Id, Zendesk_Id__c, Counter_ID__c
                                       FROM Account 
                                       WHERE Counter_Id__c IN :counterIdToOrgId.keySet() 
                                       AND Zendesk_Id__c = null];
        for (Account a : acctsToUpdate) {
            ZendeskWrapper.zdOrganization zdOrg = zdWrapper.counterIdToZDOrgMap.get(a.Counter_Id__c);
            if (zdOrg != null) {
                a.Zendesk_Id__c = zdOrg.id;
            }
        }
        
        //3. Get all active Zendesk Supported Memberships, and push those to Zendesk
        for (Account a : [SELECT Id, Zendesk_Id__c, Counter_ID__c,
                          (SELECT Id, Program__r.Name, Membership_Status_Text__c
                           FROM Memberships__r 
                           WHERE Program__r.Integration_Support__c = :Constants.ZENDESK
                           AND Membership_Status_Text__c LIKE 'Member%')
                          FROM Account WHERE Counter_Id__c IN :counterIdToOrgId.keySet()]) 
        {
            ZendeskWrapper.zdOrganization zdOrg = zdWrapper.counterIdToZDOrgMap.get(a.Counter_Id__c);
            if (zdOrg != null) {
                zdOrg.organization_fields.membership_status = '';
                for (Membership__c m : a.Memberships__r) {
                    zdOrg.organization_fields.membership_status += '[' + m.Program__r.Name + ' - ' + m.Membership_Status_Text__c + ']\r\n';
                }
                zdOrgsToUpdate.add(zdOrg);
            }
        }
        if (zdOrgsToUpdate.size() > 0) {
            Map<String, List<ZendeskWrapper.zdOrganization>> orgMap = new Map<String, List<ZendeskWrapper.zdOrganization>>();
            orgMap.put('organizations', zdWrapper.organizationMap.values());
            HTTPResponse postRes = zendeskCallout(ZENDESK_CALLOUT_PREFIX + Label.Zendesk_Update_Many_Orgs, 'PUT', JSON.serialize(orgMap));
           
        }
        
        //perform DML operations once all callouts have completed to avoid SF errors
        if (acctsToUpdate.size() > 0) {
            util.bypassAllTriggers = true;
            update acctsToUpdate;
            util.bypassAllTriggers = false;
        }
    }
    
    //Added by - Neha Sharam - 03/18/2021 - CR-20210205-14877
    //Start from here
    //Utility method to process response string to make sure 
    //any non-string custom field values will be converted into strings
    //So then typed Deserialization can happen without any error and data type handling can be done properly
    public static Map<String, Object> processResponseForDeserialization(Map<String, Object> mapOfResponseBody) 
    {
        if(mapOfResponseBody != null) 
        {
            //Set of allowed ID values
            Set<String> setOfAllowedIds = (ZendeskWrapper.zdFieldToSyncMap != null) 
                ? ZendeskWrapper.zdFieldToSyncMap.keySet() 
                : new Set<String>();
            
            Set<String> setOfNonEligibleIDs = new Set<String>();
            
            
           
            //to iterate over the map of custom_fields
            for(String mainKey : mapOfResponseBody.keySet()) 
            {
                if(String.isNotBlank(mainKey) && (mainKey.trim().equalsIgnoreCase('results') || mainKey.trim().equalsIgnoreCase('tickets'))) 
                {
                    //List of results
                    List<Object> listOfResults = (List<Object>) mapOfResponseBody.get(mainKey);
                    List<Object> listOfUpdatedResults = new List<Object>();
                    
                    for(object resultsObj : listOfResults) 
                    {
                        Map<String, object> mapOfResultDetails = (Map<String, object>)resultsObj;
                        
                        for(String resultsKey : mapOfResultDetails.keySet()) 
                        {
                            //Updating custom fields values
                            if(String.isNotBlank(resultsKey) && resultsKey.trim().equalsIgnoreCase('custom_fields')) 
                            {
                                List<Object> listOfCustomFields = (List<Object>) mapOfResultDetails.get(resultsKey);
                                List<Object> listOfUpdatedFieldsObj = new List<Object>();
                                
                                for(object fieldObj : listOfCustomFields)
                                {
                                    //@@@@@ field {id=38725267, value=member_support_team}
                                    Map<String, object> mapOfFieldDetails = (Map<String, object>)fieldObj;
                                   
                                    Map<String, object> mapOfUpdatedFieldDetails = new Map<String, object>();
                                    
                                    //id, value
                                    for(String fieldKey : mapOfFieldDetails.keySet()) 
                                    {
                                        if(String.isNotBlank(fieldKey))
                                        {
                                            if(mapOfFieldDetails.get('id') != null) 
                                            {
                                                //Only allowed IDs should be processed
                                                if(setOfAllowedIds.contains(String.valueOf(mapOfFieldDetails.get('id')).trim())) 
                                                {
                                                    if( fieldKey.trim().equalsIgnoreCase('value'))
                                                    {
                                                        if(mapOfFieldDetails.get(fieldKey) != null) {
                                                            mapOfFieldDetails.put(fieldKey, String.valueOf(mapOfFieldDetails.get('value')));     
                                                        }
                                                        else {
                                                            mapOfFieldDetails.put(fieldKey, 'null');
                                                        }
                                                    }
                                                }
                                                else 
                                                {
                                                    if( fieldKey.trim().equalsIgnoreCase('value'))
                                                    {
                                                        mapOfFieldDetails.put(fieldKey, 'null'); 
                                                    }
                                                    setOfNonEligibleIDs.add(String.valueOf(mapOfFieldDetails.get('id')));
                                                }
                                            }    
                                        }
                                        if(!setOfNonEligibleIDs.contains(String.valueOf(mapOfFieldDetails.get('id')))) 
                                        {
                                            listOfUpdatedFieldsObj.add((Object)mapOfFieldDetails);
                                        }
                                        
                                    }
                                }
                                listOfCustomFields = new List<Object>();
                                listOfCustomFields = listOfUpdatedFieldsObj;
                                
                                mapOfResultDetails.put('custom_fields', listOfCustomFields);
                            }
                        }
                        listOfUpdatedResults.add((Object)mapOfResultDetails);
                    }
                    mapOfResponseBody.put(mainKey, listOfUpdatedResults);
                } 
            }
        }
        else {
            mapOfResponseBody = new Map<String, Object>();
        }
        
        system.debug('mapOfResponseBody--- ' + mapOfResponseBody);
        return mapOfResponseBody;
        //End here
    }
}