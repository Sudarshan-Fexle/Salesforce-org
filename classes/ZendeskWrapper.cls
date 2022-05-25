/**
 *  Description     :   Wrapper for Zendesk objects
 *
 *  Created By      :	Victor Hanson
 *
 *  Created Date    :   08/01/2018
 *
 *  Revision Logs   :   V_1.0 - Created
 *		    :   V_1.1 - 12/04/2019 - Victor Hanson - Modified - CR-20191204-13549 - added license type to zdUserIdtoSFUserMap
 *		    :   V_1.2 - Modified By - Neha Sharma - CR-20200731-14390
 *		    :   V_1.3 - Modified By - Neha Sharma - CR-20210301-14957
 *		    :   V_1.4 - Modified By - Neha Sharma - 22/1/22 - CR-20211201-15611
**/
public class ZendeskWrapper {
    
    /**
     * public variables
     **/
    public List<zdTicket> results { get; set; }
    public List<zdTicket> tickets { get; set; }
    public List<zdUser> users { get; set; }
    public List<zdComment> comments { get; set; }
    public List<zdOrganization> organizations { get; set; }
    public zdError error { get; set; }
    public String next_page { get; set; }
    public String previous_page { get; set; }
    public Integer count { get; set; }
    
    /**
     * Constructor
     **/
    public ZendeskWrapper() {
        tickets = new List<zdTicket>();
        comments = new List<zdComment>();
        users = new List<zdUser>();
        organizations = new List<zdOrganization>();
    }
    
    /**
     * Tickets are how customers communicate with agents in zendesk support
     **/
    public class zdTicket {
        public String url { get; set; }
        public Decimal id { get; set; }
        public String external_id { get; set; }
        public DateTime created_at { get; set; }
        public DateTime updated_at { get; set; }
        public String type { get; set; }
        public String subject { get; set; }
        public String description { get; set; }
        public String priority { get; set; }
        public String status { get; set; }
        public Decimal requester_id { get; set; }
        public Decimal assignee_id { get; set; }
        public Decimal organization_id { get; set; }
        public DateTime due_at { get; set; }
        public List<String> tags { get; set; }
        public List<zdCustomField> custom_fields { get; set; }
        public Integer comment_count { get; set; }
        public zdVia via { get; set; }
        public zdSatisfaction_rating satisfaction_rating { get; set; }
        
        //Modify By - Neha Sharma - CR-20200731-14390
        public boolean create_salesforce_ticket {get;set;}
        
        //returns tags in a comma delimited string
        public String getTags() {
            String returnedTags;
            if (tags != null) {
                returnedTags = String.join(tags, ', ');
                
                //check if string length is too long for the field
                if (returnedTags.length() > Case.Tags__c.getDescribe().getLength()) {
                    returnedTags = returnedTags.substring(0, Case.Tags__c.getDescribe().getLength());
                }
            }
            return returnedTags;
        }
    }
    
    /**
	 *	represents the conversation between requesters, collaborators, and agents
	**/
    public class zdComment {
        public Decimal id { get; set; }
        public String type { get; set; }
        public Decimal author_id { get; set; }
        public String plain_body { get; set; }
        public DateTime created_at { get; set; }
        public Boolean xpublic { get; set;}
    }
    
    /**
	 *	custom fields added to zendesk
	**/
    public class zdCustomField {
        public Decimal id { get; set; }
        public String value { get; set; }
    }
    
    /**
	 *	zendesk user, such as requester
	**/
    public class zdUser {
        public Decimal id { get; set; }
        public String email { get; set; }
        public String name { get; set; }
        public Decimal organization_id { get; set; }
        public zdUser_Fields user_fields { get; set; }
    }
    
    /**
     * user field
     **/
    public class zdUser_Fields {
        public String project_role { get; set; }
        public String project_role_notes { get; set; }
        
        //Added By - Neha Sharma - CR-20210301-14957 - variable to hold the membership key contact role
        public String membership_key_contact_role { get; set; }
    }
    
    /**
	 *	error details
	**/
    public class zdError {
        public String title { get; set; }
        public String message { get; set; }
    }
    
    /**
	 *	explains how the ticket was created
	**/
    public class zdVia {
        public String channel { get; set; }
    }
    
    /**
	 * zendesk 
	**/
    public class zdOrganization {
    	public Decimal id { get; set; }
        public zdOrganization_Fields organization_fields { get; set; }
    }
    
    /**
     * organization field
     **/
    public class zdOrganization_Fields {
        public String salesforce_id { get; set; }
        public String membership_status { get; set; }
    }
    
    /**
     * satisfaction rating
     **/
    public class zdSatisfaction_rating {
        public String score { get; set; }
        public String comment { get; set; }
        public String reason { get; set; }
    }
    
    /**
     * returns a map of zdTickets with map<ticket_id, ticket>
     **/
    public Map<Decimal, zdTicket> ticketMap {
        get {
            if (ticketMap == null || ticketMap.size() == 0) {
                ticketMap = new Map<Decimal, zdTicket>();
                if (tickets != null && tickets.size() > 0) {
                    for (zdTicket ticket : tickets) {
                        ticketMap.put(ticket.id, ticket);
                    }
                }
            }
            return ticketMap;
        }
        set;
    }
    
    /**
     * returns a map of zdUsers with map<zdUserId, zdUser>
     **/
    public Map<Decimal, zdUser> userMap {
        get {
            if (userMap == null || userMap.size() == 0) {
                userMap = new Map<Decimal, zdUser>();
                if (users != null && users.size() > 0) {
                    for (zdUser usr : users) {
                        userMap.put(usr.id, usr);
                    }
                }
            }
            return userMap;
        }
        set;
    }
    
    /**
     * returns a map of emails -> zdUserId to query contact/leads and map them back to the zdUser
     **/
    public Map<String, Decimal> emailtoZDUserMap {
        get {
            if (emailtoZDUserMap == null || emailtoZDUserMap.size() == 0) {
                emailtoZDUserMap = new Map<String, Decimal>();
                if (users != null && users.size() > 0) {
                    for (zdUser usr : users) {
                        if (usr.email != null)
                            emailtoZDUserMap.put(usr.email, usr.id);
                    }
                }
            }
            return emailtoZDUserMap;
        }
        set;
    }
    
    /**
     * returns a map of emails -> sfUserId, which is used to determine the Case Owner in SF
     **/
    public Map<Decimal, User> zdUserIdtoSFUserMap {
        get {
            if (zdUserIdtoSFUserMap == null || zdUserIdtoSFUserMap.size() == 0) {
                zdUserIdtoSFUserMap = new Map<Decimal, User>();
                
                if (users != null && users.size() > 0) {
                    //get set of emails
                    List<User> users = [SELECT Id, ProfileId, Email FROM User WHERE Email IN :emailtoZDUserMap.keySet()];
                    if (users.size() > 0) {
                        for (User u : users) {
                            
                            //get zdUser id from email
                            Decimal zdUserId = emailtoZDUserMap.get(u.Email);
                            if (zdUserId != null) {
                                zdUserIdtoSFUserMap.put(zdUserId, u);
                            }
                        }
                    }
                    else {
                        zdUserIdtoSFUserMap.put(123, new User());
                    }
                    
                }
            }
            return zdUserIdtoSFUserMap;
        }
        set;
    }
    
    /**
     * returns a map of UserId -> Contact or Lead object
     **/
    public Map<Decimal, SObject> zdUserIdToSObjectMap {
        get {
            if (zdUserIdToSObjectMap == null && emailtoZDUserMap != null) {
                zdUserIdToSObjectMap = new Map<Decimal, SObject>();
                List<SObject> sObjList = new List<SObject>();
                sobjList.addAll([SELECT Id, Email FROM Lead WHERE Email IN :emailtoZDUserMap.keySet()]);
                sObjList.addAll([SELECT Id, Email FROM Contact WHERE Email IN :emailtoZDUserMap.keySet()]);
                
                //use the email address to get the zdUserId that corresponds to the Lead or Contact
                for (SObject record : sObjList) {
                    String zdUserEmail = (String)record.get('Email');
                    Decimal zdUserId = emailtoZDUserMap.get(zdUserEmail);
                    zdUserIdToSObjectMap.put(zdUserId, record);
                }
            }
            return zdUserIdToSObjectMap;
        }
        set;
    }
    
    /**
     * returns a map of source field to sync field.  ie: Map<(string)zdCustomFieldID, SyncField>
     **/
    public static Map<String, Sync_Field__c> zdFieldToSyncMap {
        get {
            if (zdFieldToSyncMap == null) {
                zdFieldToSyncMap = new Map<String, Sync_Field__c>();
                for (Sync_Field__c syncField : [SELECT Id, Source_Field_API_Name__c, 
                                                Target_Field_API_Name__c, Target_Field_Type__c
                                                FROM Sync_Field__c
                                                WHERE Source_Object_API_Name__c = 'Ticket']) 
                {
                    zdFieldToSyncMap.put(String.valueOf(syncField.Source_Field_API_Name__c), syncField);
                }
            }
            return zdFieldToSyncMap;
        }
        set;
    }
    
    /**
     * counterIdToProjectMap returns a map of <account.counterId, List<Project>>
     **/
    public Map<String, List<Project__c>> counterIdToProjectMap {
        get {
            if (counterIdToProjectMap == null || counterIdToProjectMap.size() == 0) {
                counterIdToProjectMap = new Map<String, List<Project__c>>();
                
                
                if (organizations != null && organizations.size() > 0) {
                    
                    //get all organization.salesforce_id values
                    Set<String> counterIds = new Set<String>();
                    for (zdOrganization o : organizations) {
                        if (o.organization_fields.salesforce_id != null) counterIds.add(o.organization_fields.salesforce_id);
                    }
                    
                    //get all projects associated to an institutions with counter id
                    for (Project__c proj : [SELECT Id, Program_Acronym__c, Institution__r.Counter_Id__c
                                            FROM Project__c
                                            WHERE  Institution__r.Counter_Id__c IN :counterIds
                                            AND Program_Acronym__c IN :zdAcronyms
                                            AND Project_Phase__c NOT IN :Constants.SET_PROJECT_PHASES_TO_IGNORE]) 
                    {
                        
                        List<Project__c> pList = counterIdToProjectMap.get(proj.Institution__r.Counter_Id__c);
                        if (pList == null) pList = new List<Project__c>();
                        pList.add(proj);
                        counterIdToProjectMap.put(proj.Institution__r.Counter_Id__c, pList);
                    }
                    if (counterIdToProjectMap.size() == 0) counterIdToProjectMap.put('123', new List<Project__c>());
                }
            }
            return counterIdToProjectMap;
        }
        set;
    }
    
    /**
     * return project key from project
     **/
    public String getProjectKey(Project__c proj) {
        string key = proj.Institution__r.Counter_Id__c + '-' + proj.Product__r.Program_Acronym__c;
        return key;
    }
    
    /**
     * return project key from zdTicket and organization
     **/
    public String getCounterId(zdTicket ticket) {
        String counterId;
        if (organizationMap != null) {
           
            zdOrganization org = organizationMap.get(ticket.organization_id);
            if (org != null && org.organization_fields.salesforce_id != null)
                counterId = (string)org.organization_fields.salesforce_id;
            
        }
        return counterId;
       
    }
    
    /**
     * return a map of OrganizationId -> zdOrganization
     **/
    public Map<Double, zdOrganization> organizationMap {
        get {
            if (organizationMap == null || organizationMap.size() == 0) {
                organizationMap = new Map<Double, zdOrganization>();
                
                if (organizations != null && organizations.size() > 0) {
                    for (zdOrganization o : organizations) {
                        organizationMap.put(o.id, o);
                    }
                }
            }
            return organizationMap;
        }
        set;
    }
    
    /**
     * returns a map of Map<ZDOrg.organization_fields.salesforce_id, ZDOrganization>
     **/
    public Map<String, zdOrganization> counterIdToZDOrgMap {
        get {
            if (counterIdToZDOrgMap == null || counterIdToZDOrgMap.size() == 0) {
                counterIdToZDOrgMap = new Map<String, zdOrganization>();
                if (organizations != null && organizations.size() > 0) {
                    for (zdOrganization o : organizations) {
                        if (o.organization_fields.salesforce_id != null) {
                            counterIdToZDOrgMap.put(o.organization_fields.salesforce_id, o);
                        }   
                    }
                }
            }
            return counterIdToZDOrgMap;
        }
        set;
    }
    
    /**
     * returns a map of Map<Account.Counter_Id__c, Account>
     **/
    public Map<String, Account> counterIdToAccountMap {
        get {
            if (counterIdToAccountMap == null || counterIdToAccountMap.size() == 0) {
                counterIdToAccountMap = new Map<String, Account>();
                if (organizations != null && organizations.size() > 0) {
                    for (Account a : [SELECT Id, Zendesk_Id__c, Counter_ID__c
                                      FROM Account 
                                      WHERE Counter_Id__c IN :counterIdToZDOrgMap.keySet()]) 
                    {
                        counterIdToAccountMap.put(a.Counter_Id__c, a);
                    }
                }
            }
            return counterIdToAccountMap;
        }
        set;
    }
    
    /**
     * returns a set of zendesk acronyms (ie: gradesfirst={BHGF, BHGFAD, BHGFAT, BHGFCU})
     **/
    public Map<String, Set<String>> zdProductToAcronymMap {
        get {
            if (zdProductToAcronymMap == null) {
                zdProductToAcronymMap = new Map<String, Set<String>>();
                for (Field_Mapping_Value__mdt f : [SELECT Id, Source_Value__c, Target_Value__c
                                                  FROM Field_Mapping_Value__mdt
                                                  WHERE Field_Mapping__r.Label = :Label.Zendesk_Field_Map_Label])
                {
		    //Modified By - 04/28/2021 - Neha Sharma - Created - CR-20200731-14390
                    //String key = f.Source_Value__c.toLowerCase().replaceAll(' ', '_');
                    String key = f.Source_Value__c.toLowerCase();
                    Set<String> acronyms = zdProductToAcronymMap.get( key );
                    if (acronyms == null) acronyms = new Set<String>();
                    acronyms.addAll( f.Target_Value__c.split(',') );
                    zdProductToAcronymMap.put( key, acronyms );
                    zdAcronyms.addAll(acronyms);
                }
            }
            return zdProductToAcronymMap;
        }
        set;
    }
    
    /**
     * returns a set of ZD Product Acronyms
     **/
    private Set<String> zdAcronyms {
        get {
            if (zdAcronyms == null) {
                zdAcronyms = new Set<String>();
                for (String key : zdProductToAcronymMap.keySet()) {
                    for (String acronym : zdProductToAcronymMap.get(key)) {
                        zdAcronyms.add(acronym);
                    }
                }
            }
            return zdAcronyms;
        }
        set;
    }

    /**
     * returns a list of profile ids with access to cases
     **/
     public Set<String> profileIdsWithCaseAccess {
         get {
            if (profileIdsWithCaseAccess == null) {
                profileIdsWithCaseAccess = new Set<String>();
                List<ObjectPermissions> casePerms = [SELECT Parent.ProfileId  FROM ObjectPermissions
                                                    WHERE Parent.IsOwnedByProfile = true AND SObjectType = 'Case'];
                for (ObjectPermissions op : casePerms)
                    profileIdsWithCaseAccess.add(op.Parent.ProfileId);
            }
            return profileIdsWithCaseAccess;
         }
         set;
     }
    
    /**
     * returns a set of zendesk support category 
     * Added By - Neha Sharma - 19/10/21 - CR-20210301-14957
     **/
    public Map<String, String> zdIssuecategoryToSupportCategoryMap {
        get {
            if (zdIssuecategoryToSupportCategoryMap == null) {
                zdIssuecategoryToSupportCategoryMap = new Map<String, String>();
                for (Field_Mapping_Value__mdt f : [SELECT Id, Source_Value__c, Target_Value__c
                                                  FROM Field_Mapping_Value__mdt
                                                  WHERE Field_Mapping__r.Label = :Label.Zendesk_Issue_Category_Label])
                {
                    zdIssuecategoryToSupportCategoryMap.put(f.Source_Value__c.toLowerCase(), f.Target_Value__c );
                }
            }
            return zdIssuecategoryToSupportCategoryMap;
        }
        set;
    }
    
    /**
     * returns a set of zendesk support category 
     * Added By - Neha Sharma - 22/1/22 - CR-20211201-15611
     **/
    public Map<String, String> zdProductToProductModuleAffectedMap{
        get {
            if (zdProductToProductModuleAffectedMap == null) {
                zdProductToProductModuleAffectedMap = new Map<String, String>();
                for (Field_Mapping_Value__mdt f : [SELECT Id, Source_Value__c, Target_Value__c
                                                  FROM Field_Mapping_Value__mdt
                                                  WHERE Field_Mapping__r.Label = :Label.Zendesk_Product_Module_Affected_Label])
                {
                    zdProductToProductModuleAffectedMap.put(f.Source_Value__c.toLowerCase(), f.Target_Value__c );
                }
            }
            return zdProductToProductModuleAffectedMap;
        }
        set;
    }
}