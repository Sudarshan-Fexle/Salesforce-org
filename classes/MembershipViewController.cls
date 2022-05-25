/**
 *  Desription      :   Standard Controller for Membership detail page
 * 
 *  Created By      :   
 * 
 *  Created Date    :   09/26/2013
 * 
 *  Revision Logs   :   V1.0 - Created
 *                      V1.1 - Modified By - Mahendra Swarnakar - 3/17/2016 - CR-20150908-9224 
 *                      V1.2 - Modified By - Victor Hanson - 8/29/2017 - Issue--CR11062--QA--00005582
 * 						V1.3 - Modified By - Victor Hanson - 04/17/2018 - CR-20170804-11123 - added keyContactIds method
 * 						V1.4 - Modified By Abhinav Sharma - 10/01/2018 - CR-20180809-12494 Added Vist and Program package related list and hide others for enrollement record type
 *
 *                      V1.6 - Modified By Abhinav Sharma - 12/05/2018 - CR-20181116-12755 - Hide the Activity history of Subscription period/Opp/Membership Key contract for the Record type = Enrollment.  
            Merged By Rajeev Jain - 12/07/2018 - Account Merge - Hypercare
            v_1.7 - Modified by Mahendra Swarnkar 17-06-2019 CR-20190522-13123
			Modified By Dipesh Gupta 10/02/2019 - CR-20190524-13151 - Added 2 new field in the Event and Task Query, Record Type and Status formul;ad
			V_1.8 - Modified by Dipesh Gupta CR-20190522-13123 10/03/2019  -Remove the reference of 'Syndicated_Research_Interaction__c'.
			V_1.9 - Modified by Mahendra Swarnkar - 30/10/2019 - Added to set boolean flag according to user permissions for Opportunity Object MemeberShip Lookup field

 **/
public without sharing class MembershipViewController {
    
    public Membership__c Membership { get; set; }
    // read access to related list objects
    public boolean ReadAccess_MemKeyContact { get; set; }
    public boolean ReadAccess_Opportunity { get; set; }
    public boolean ReadAccess_MemInteraction { get; set; }
    public boolean ReadAccess_SyndicatedResearch { get; set; }
    public boolean ReadAccess_MeetingUtils { get; set; }
    public boolean ReadAccess_TeleconfUtils { get; set; }
    public boolean ReadAccess_OtherUtils { get; set; }
    public boolean ReadAccess_Projects { get; set; }
    public boolean ReadAccess_Program_Package {get; set;}
    public boolean ReadAccess_Visit {get; set;}
    
    //Added By - Mahendra Swarnakar - 3/17/2016 - CR-20150908-9224 - Starts From Here
    public boolean ReadAccess_StaffAssignments { get; set; }
    //Added By - Mahendra Swarnakar - 3/17/2016 - CR-20150908-9224 - Ends Here
    
    // customized version of the OpenActivity object
    public class EventOrTask implements Comparable {
        public Id ObjectId { get; set; }
        public Id WhoId { get; set; }
        public String WhoName { get; set; }
        public Id WhatId { get; set; }
        public String WhatName { get; set; }
        public String Subject { get; set; }
        public Date ActivityDate { get; set; }
        public Id OwnerId { get; set; }
        public String OwnerName { get; set; }
        public String EventType { get; set; }
        public boolean IsTask { get; set; }
        
        //Added 2 new Properties. 
        public String eventRecordType { get; set; }
        public String eventStatusFormula { get; set; }

		public EventOrTask(Event evt) {
            ObjectId = evt.Id;
            WhoId = evt.WhoId;
            WhoName = evt.Who.Name;
            WhatId = evt.WhatId;
            WhatName = evt.What.Name;
            Subject = evt.Subject;
            ActivityDate = evt.ActivityDate;
            OwnerId = evt.OwnerId;
            OwnerName = evt.Owner.Name;
            EventType = evt.Event_Type__c;
            IsTask = false;
            eventRecordType = evt.RecordType.Name;
            eventStatusFormula = evt.Status_F__c;
        }
        
        public EventOrTask(Task tsk) {
            ObjectId = tsk.Id;
            WhoId = tsk.WhoId;
            WhoName = tsk.Who.Name;
            WhatId = tsk.WhatId;
            WhatName = tsk.What.Name;
            Subject = tsk.Subject;
            ActivityDate = tsk.ActivityDate;
            OwnerId = tsk.OwnerId;
            OwnerName = tsk.Owner.Name;
            EventType = tsk.Event_Type__c;
            IsTask = true;
            eventRecordType = tsk.RecordType.Name;
            eventStatusFormula = tsk.Status_F__c;
        }
        
        // allows us to sort all EventOrTasks by ActivityDate DESC
        public Integer compareTo(Object compareTo) {
            EventOrTask wrapper = (EventOrTask) compareTo;
            if (ActivityDate == wrapper.ActivityDate) return 0;
            if (ActivityDate < wrapper.ActivityDate) return 1;
            return -1;        
        }
    }
    
    private Integer NumTasksToDisplay { get; set; }
    private Integer NumHistoricalTasksToDisplay { get; set; }
    private Integer NumMemberInteractionsToDisplay { get; set; }
    private Integer NumSyndicatedToDisplay { get; set; }
    
    // the number of records to increment the related lists by
    private Integer ItemIncrementor = 5;
    
    // incrementally increase the number of records to display and refresh the list
    public void ShowMoreTasks() {
        NumTasksToDisplay += ItemIncrementor;
        OpenEventOrTaskList = null;
    }
    
    public void ShowMoreActivityHistory() {
        NumHistoricalTasksToDisplay += ItemIncrementor;
        HistoricalEventOrTaskList = null;
    }
    
    public void ShowMoreMemberInteractions() {
        NumMemberInteractionsToDisplay += ItemIncrementor;
        /*<!--Modified By Dipesh Gupta -CR-20190524-13152 - Date-06/14/2019 -->*/
        //MemberInteractions = null;
    }
    
    public void ShowMoreSyndicated() {
        NumSyndicatedToDisplay += ItemIncrementor;
        //ResearchInteractions = null;
    }
    
    /**
     *  @description    :   Returns the related subscription and subscripton periods for the Membership's Program
     *
     *  @return         :   List<SBQQ__Subscription__c>
     * 
     * 	@revision logs	:	V1.0 - Created - Victor Hanson - 8/29/2017 - Issue--CR11062--QA--00005582
     *
    **/
    private List<SBQQ__Subscription__c> relatedSubscriptions {
        get {
            if (relatedSubscriptions == null) relatedSubscriptions = [SELECT Id, (SELECT Id FROM Program_Subscriptions__r) 
                                                                      FROM SBQQ__Subscription__c 
                                                                      WHERE Program__c = :Membership.Program__c
                                                                      AND SBQQ__Account__c = :Membership.Account_Name__c];
            return relatedSubscriptions;
        }
        set;
    }
    
    /**
     *  @description    :   Returns the set of Ids for related subscription and subscripton periods for the Membership's Program
     *
     *  @return         :   Set<Id>
     * 
     * 	@revision logs	:	V1.0 - Created - Victor Hanson - 8/29/2017 - Issue--CR11062--QA--00005582
     *
    **/
    private Set<Id> subscriptionIds {
        get {
            if (subscriptionIds == null) {
                subscriptionIds = new Set<Id>();
                for (SBQQ__Subscription__c s : relatedSubscriptions) {
                    
                    subscriptionIds.add(s.Id);
                    
                    for (Subscription_Period__c pSub : s.Program_Subscriptions__r) subscriptionIds.add(pSub.Id);
                }
            }
            return subscriptionIds;
        }
        set;
    }
    
    /**
     *  @description    :   Returns the set of Ids for related Membership Key Contacts
     *
     *  @return         :   Set<Id>
     * 
     * 	@revision logs	:	V1.0 - Created - Victor Hanson - 04/17/2018 - CR-20170804-11123
     *
    **/
    private Set<Id> keyContactIds {
        get {
            if (keyContactIds == null) {
                keyContactIds = new Set<Id>();
                for (Membership_Key_Contact__c keyContact : [SELECT Id, Contact__c FROM Membership_Key_Contact__c WHERE Membership__c = :Membership.Id AND Contact__c != null]) {
                    
                    keyContactIds.add(keyContact.Contact__c);
                }
            }
            return keyContactIds;
        }
        set;
    }
    
    /**
     *  @description    :   Returns the set of Ids for related Membership/Opp/Subscription/Subscription Periods
     *
     *  @return         :   Set<Id>
     * 
     * 	@revision logs	:	V1.0 - Created - Victor Hanson - 8/29/2017 - Issue--CR11062--QA--00005582
     * 						V1.1 - Modified - Victor Hanson - 04/17/2018 - CR-20170804-11123 - added reference to keyContactIds
     * 						V1.2 - Modified By Abhinav Sharma - 12/05/2018 - CR-20181116-12755 - Check the record type before Filling WhatId.. 
     *
    **/
    public Set<Id> whatIds {
        get {
            if (whatIds == null) {
                whatIds = new Set<Id>();
                
                //Check for the Membership Record Type - If the membership record type is "Standard", then only add the Opportunity in the what ids. 
                if(Membership.RecordType.DeveloperName == Constants.MEMBERSHIP_RECORD_TYPE_RECORD_TYPE_1)
                	whatIds.addAll(RelatedOpps.keySet());
                
                whatIds.add(Membership.Id);
                
                //Check for the Membership Record Type - If the membership record type is "Standard", then only add the Opportunity in the what ids. 
                if(Membership.RecordType.DeveloperName == Constants.MEMBERSHIP_RECORD_TYPE_RECORD_TYPE_1)
                	whatIds.addAll(subscriptionIds);
            }
            return whatIds;
        }
        set;
    }
    
    /**
     *  @description    :   Returns the set of Ids for related Membership Key Contacts
     *
     *  @return         :   Set<Id>
     * 
     * 	@revision logs	:	V1.0 - Created - Victor Hanson - 04/17/2018 - CR-20170804-11123
     * 					:   V1.1 - Modified By Abhinav Sharma - 12/05/2018 - CR-20181116-12755- check of record type while fill the WhoId set.
     *
    **/
    public Set<Id> whoIds {
        get {
            if (whoIds == null) {
                whoIds = new Set<Id>();
                //Check for the Membership Record Type - If the membership record type is "Standard", then only add the Opportunity in the what ids. 
                if(Membership.RecordType.DeveloperName == Constants.MEMBERSHIP_RECORD_TYPE_RECORD_TYPE_1)
                	whoIds.addAll(keyContactIds);
            }
            return whoIds;
        }
        set;
    }
    
    // get the total number of Events and Tasks - used to determine if the "show 5 more" link will be displayed below the Related List
    /**
     *  @description	: 	get all historical activities (event & task)
     * 
     * 	@revision logs	:	V1.0 - Created - Victor Hanson - 04/17/2018 - CR-20170804-11123
     *
    **/
    public List<EventOrTask> openActivities {
        get {
            if (openActivities == null) {
                openActivities = new List<EventOrTask>();
                // also add any events associated with the Membership or Related Opps
                List<Event> openEvents = [SELECT Id, Subject, ActivityDate, WhoId, WhatId, OwnerId, What.Name, Who.Name, 
                                          Event_Type__c, Owner.Name, What.Type, RecordType.Name, Status_F__c
                                          FROM Event 
                                          WHERE (WhatId IN :whatIds OR WhoId IN :whoIds)
                                          AND EndDateTime >= TODAY
                                          ORDER BY ActivityDate DESC LIMIT :(NumTasksToDisplay + ItemIncrementor)];
                // add all of these events to our wrapper list
                for (Event evt : openEvents) {
                    openActivities.add(new EventOrTask(evt));
                }
                
                // check for open tasks as well
                List<Task> openTasks = [SELECT Id, Subject, ActivityDate, WhoId, WhatId, OwnerId, What.Name, Who.Name,  
                                        Event_Type__c, Owner.Name, What.Type, RecordType.Name, Status_F__c
                                        FROM Task 
                                        WHERE (WhatId IN :whatIds OR WhoId IN :whoIds)
                                        AND ActivityDate >= TODAY
                                        ORDER BY ActivityDate DESC LIMIT :(NumTasksToDisplay + ItemIncrementor)];
                // add all of these tasks to our wrapper list
                for (Task tsk : openTasks) {
                    openActivities.add(new EventOrTask(tsk));
                }
                openActivities.sort();
            }
            return openActivities;
        }
        set;
    }
    
    // list of all open events and tasks for the Membership and Child Opps
    public List<EventOrTask> openEventOrTaskList {
        get {
            if (openEventOrTaskList == null) {
                openEventOrTaskList = new List<EventOrTask>();
                
                openActivities = null; //force requery
                
                //add records
                for (Integer i = 0; i < openActivities.size(); i++) {
                    if (i < NumTasksToDisplay) {
                        openEventOrTaskList.add(openActivities[i]);
                    }
                    else break;
                }
                
            }
            return openEventOrTaskList;
        }
        set;
    }
    
    /**
     *  @description	: 	get all historical activities (event & task)
     * 
     * 	@revision logs	:	V1.0 - Created - Victor Hanson - 04/17/2018 - CR-20170804-11123
     *
    **/
    public List<EventOrTask> historicalActivities {
        get {
            if (HistoricalActivities == null) {
                HistoricalActivities = new List<EventOrTask>();
                // also add any events associated with the Membership or Related Opps
                List<Event> historicalEvents = [SELECT Id, Subject, ActivityDate, WhoId, WhatId, OwnerId, What.Name, Who.Name,  
                                                Event_Type__c, Owner.Name, What.Type, Status_F__c, recordType.Name
                                                FROM Event 
                                                WHERE (WhatId IN :whatIds OR WhoId IN :whoIds)
                                                AND EndDateTime < :DateTime.now() AND CreatedDate >= LAST_N_YEARS:2
                                                ORDER BY EndDateTime DESC
                                                LIMIT :(NumHistoricalTasksToDisplay + ItemIncrementor) ALL ROWS];
                // add all of these events to our wrapper list
                for (Event evt : historicalEvents) {
                    HistoricalActivities.add(new EventOrTask(evt));
                }
                
                // check for open tasks as well
                List<Task> historicalTasks = [SELECT Id, Subject, ActivityDate, WhoId, WhatId, OwnerId, What.Name, Who.Name,  
                                              Event_Type__c, Owner.Name, What.Type, Status_F__c, recordType.Name
                                              FROM Task 
                                              WHERE (WhatId IN :whatIds OR WhoId IN :whoIds)
                                              AND ActivityDate < :Date.today() AND CreatedDate >= LAST_N_YEARS:2
                                              ORDER BY ActivityDate DESC
                                              LIMIT :(NumHistoricalTasksToDisplay + ItemIncrementor) ALL ROWS];
                // add all of these tasks to our wrapper list
                for (Task tsk : historicalTasks) {
                    HistoricalActivities.add(new EventOrTask(tsk));
                }
                HistoricalActivities.sort();
            }
            return HistoricalActivities;
        }
        set;
    }
    
    // list of all historical events and tasks for the Membership and Child Opps, ordered by endDate descending
    public List<EventOrTask> HistoricalEventOrTaskList {
        get {
            if (HistoricalEventOrTaskList == null) {
                HistoricalEventOrTaskList = new List<EventOrTask>();
                
                HistoricalActivities = null; //force requery
                
                //add records
                for (Integer i = 0; i < HistoricalActivities.size(); i++) {
                    if (i < NumHistoricalTasksToDisplay) {
                        HistoricalEventOrTaskList.add(HistoricalActivities[i]);
                    }
                    else break;
                }
                
            }
            return HistoricalEventOrTaskList;
        }
        set;
    }
    
    
    
    public MembershipViewController(ApexPages.StandardController controller) {
        //Initialize membership record 
        String memId = controller.getId();
        //Added a RecordType.DeveloperName field in the Query.
        Membership = [SELECT Id, Name, Program__c, Account_Name__c, Program__r.Name, Account_Name__r.Name, RecordType.DeveloperName FROM Membership__c WHERE Id = :memId LIMIT 1];
        
        
        // Added the Staff Assignment Object in the object name list  - Mahendra Swarnakar - 3/17/2016 - CR-20150908-9224
        // Commented Visit__c By Dipesh Gupta -CR-20190524-13151 - Date-06/18/2019
        // determine which related lists we have access to
        // Modified by Dipesh Gupta CR-20190522-13123 10/03/2019  -Remove the reference of 'Syndicated_Research_Interaction__c'.
        List<String> objectNameList = new List<String> { 'Membership_Key_Contact__c', 'Meeting_Utilization__c', 'Opportunity',
                                                         'Utilization_Data_Object__c', 'Other_Utilization__c',
                                                         'Project__c', 'Call__c'/*, 'Syndicated_Research_Interaction__c'*/, 'Team_Membership__c',
            											  'Program_Package__c', 'Visit__c'
            											};
        Map<String, String> userPermissionMap = Util.CheckUserPermission(UserInfo.getUserId(), objectNameList, 'PermissionsRead');
        for (String objName : userPermissionMap.keySet()) {
            String hasAccess = userPermissionMap.get(objName);
            
            // Modified By Mahendra Swarnkar - 30/10/2019 - CR-20190514-13105 - Added to set boolean flag according to user permissions for Opportunity Object MemeberShip Lookup field
            
            if (objName == 'Membership_Key_Contact__c' && hasAccess == 'true' && Schema.sObjectType.Opportunity.fields.Membership__c.isAccessible()) ReadAccess_MemKeyContact = true;
            else if (objName == 'Opportunity' && hasAccess == 'true' && Schema.sObjectType.Opportunity.fields.Membership__c.isAccessible()) ReadAccess_Opportunity = true;
            else if (objName == 'Meeting_Utilization__c' && hasAccess == 'true' && Schema.sObjectType.Opportunity.fields.Membership__c.isAccessible()) ReadAccess_MeetingUtils = true;
            else if (objName == 'Utilization_Data_Object__c' && hasAccess == 'true' && Schema.sObjectType.Opportunity.fields.Membership__c.isAccessible()) ReadAccess_TeleconfUtils = true;
            else if (objName == 'Other_Utilization__c' && hasAccess == 'true' && Schema.sObjectType.Opportunity.fields.Membership__c.isAccessible()) ReadAccess_OtherUtils = true;
            else if (objName == 'Project__c' && hasAccess == 'true' && Schema.sObjectType.Opportunity.fields.Membership__c.isAccessible()) ReadAccess_Projects = true;
            
            /*<!--Modified By Dipesh Gupta -CR-20190524-13152 - Date-06/14/2019 -->*/
            /*else if (objName == 'Call__c' && hasAccess == 'true') ReadAccess_MemInteraction = true;*/
           // else if (objName == 'Syndicated_Research_Interaction__c' && hasAccess == 'true') ReadAccess_SyndicatedResearch = true;
            
            //Added to set boolean flag according to user permissions for Staff Assignment Object related list - Mahendra Swarnakar - 3/17/2016 - CR-20150908-9224
            else if (objName == 'Team_Membership__c' && hasAccess == 'true') ReadAccess_StaffAssignments = true;
            
            //Modified By Abhinav Sharma - 10/01/2018 - CR-20180809-12494 Added Vist and Program package Variables
            else if(objName == 'Program_Package__c' && hasAccess == 'true') ReadAccess_Program_Package = true;
            
            //Modified By Dipesh Gupta -CR-20190524-13151 - Date-06/18/2019
            //else if(objName == 'Visit__c' && hasAccess == 'true') ReadAccess_Visit = true;

        }
        // set the default num of items to show in custom Related Lists
        NumTasksToDisplay = ItemIncrementor;
        NumHistoricalTasksToDisplay = ItemIncrementor;
        NumMemberInteractionsToDisplay = ItemIncrementor;
        NumSyndicatedToDisplay = ItemIncrementor;
    }
    
    // get the opportunities related to this Membership
    public Map<Id, Opportunity> RelatedOpps {
        get {
            if (RelatedOpps == null) {
                RelatedOpps = new Map<Id, Opportunity>([SELECT Id FROM Opportunity WHERE Membership__c = :Membership.Id]);
            }
            return RelatedOpps;
        }
        set;
    }
    
    /*<!--Modified By Dipesh Gupta -CR-20190524-13152 - Date-06/14/2019 -->*/
    /*// count the number of membership interactions
    public Integer NumMemberInteractions {
        get {
            // get all projects where Institution and Program are equal to Membership's institution / program
            Map<Id, Project__c> projectMap = new Map<Id, Project__c>([SELECT Id
                                         FROM Project__c 
                                         WHERE (Product__c != null AND Product__c = :Membership.Program__c 
                                         AND Institution__c != null AND Institution__c = :Membership.Account_Name__c)
                                         OR (Primary_Paid_Membership__c = :Membership.Id)]);
            NumMemberInteractions = [SELECT COUNT()
                                  FROM Call__c
                                  WHERE Member__c IN :projectMap.keySet() 
                                  AND CreatedDate >= LAST_N_YEARS:2
                                  LIMIT :NumMemberInteractionsToDisplay + 1];
            return NumMemberInteractions;
        }
        set;
    }
    
    public List<Call__c> MemberInteractions {
        get {
            if (MemberInteractions == null) {
                // get all projects where Institution and Program are equal to Membership's institution / program
                Map<Id, Project__c> projectMap = new Map<Id, Project__c>([SELECT Id
                                             FROM Project__c 
                                             WHERE (Product__c != null AND Product__c = :Membership.Program__c 
                                             AND Institution__c != null AND Institution__c = :Membership.Account_Name__c)
                                             OR (Primary_Paid_Membership__c = :Membership.Id)]);
                MemberInteractions = [SELECT Id, Name, Call_Brief_Notes__c, RecordType.Name, CreatedById,
                                      CreatedDate, Project_Name__c, Member__c, Member__r.Name
                                      FROM Call__c
                                      WHERE Member__c IN :projectMap.keySet() 
                                      AND CreatedDate >= LAST_N_YEARS:2 ORDER BY CreatedDate DESC
                                      LIMIT :NumMemberInteractionsToDisplay];
            }
            return MemberInteractions;
        }
        set;
    }*/
    //Modified by Mahendra Swarnkar 17-06-2019 CR-20190522-13123
    // count the number of research interactions
  /*  public Integer NumResearchInteractions {
        get {
            NumResearchInteractions = [SELECT COUNT()
                                        FROM Syndicated_Research_Interaction__c
                                        WHERE Institution__c = :Membership.Account_Name__c AND Primary_Program__c = :Membership.Program__c
                                        AND CreatedDate >= LAST_N_YEARS:2 
                                        LIMIT :NumSyndicatedToDisplay + 1];
            return NumResearchInteractions;
        }
        set;
    }*/
    
    /*public List<Syndicated_Research_Interaction__c> ResearchInteractions {
        get {
            if (ResearchInteractions == null) {
                ResearchInteractions = [SELECT Id, Name, Contact__c, Contact__r.Name, Researcher__c, Researcher__r.Name,
                                               
                                               
                                               Date_of_Interaction__c,
                                                Interaction_Type__c, Primary_Study__c, Primary_Study__r.Name,
                                               Primary_Program__c, Primary_Program__r.Name, Status__c
                                        FROM Syndicated_Research_Interaction__c
                                        WHERE Institution__c = :Membership.Account_Name__c AND Primary_Program__c = :Membership.Program__c
                                        AND CreatedDate >= LAST_N_YEARS:2 
                                        
                                        
                                        ORDER BY Date_Of_Interaction__c DESC
                                        LIMIT :NumSyndicatedToDisplay];
            }
            return ResearchInteractions;
        }
        set;
    }*/
    
}