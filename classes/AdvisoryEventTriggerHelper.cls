/**
 *  Description     :   Helper class for Trigger Meeting 
 * 
 *  Created By      :   Bhavi Sharma
 * 
 *  Created Date    :   02/22/2013
 * 
 *  Revision Logs   :   V1.0 - Created
 *                      V1.1 - Modified - Victor Hanson - 1/26/15 - added method: populateTopParent
                        V1.2 - Modified - Bhavi Sharma - 02/23/15 - added method: manageMeetingFollowers
                        V1.3 - Modified - Bhavi Sharma - 03/03/15 - added method: createDefaultTeamMembers
                        V1.4 - Modified - Bhavi Sharma - 03/04/15 - added method: manageCloneRulesFromParent
                        V1.5 - Modified - Bhavi Sharma - 03/05/15 - added method: deleteRulesForUseForParent
                        V1.6 - Modified - Rajeev jain - CR-20200424-13983 - 04/29/2020 - Added a new Method, updateCommunicationTemplate
                        V1.7 - Modified - Saurabh Kumar - CR-20200821-14453 - 09/29/2020 - Added a new Method syncRegistrationPartnerStatus
                        V1.8 - Modified - Saurabh Kumar - CR-20200821-14465 - 10/28/2020 - Added a new method populateRegistrationOnCampaignMember()
                        V1.9 - Modified - Saurabh Kumar - CR-20200819-14450 - 11/03/2020 - Removed the references of "Rules_Thresholds__c" and "Rules_Titles__c" fields
                        V2.0 - Modified - Saurabh Kumar - CR-20201105-14664 - 11/18/2020 - Removed the references of Manager__c from manageMeetingFollowers() method
                        V2.1 - Modified - Saurabh Kumar - CR-20201117-14698 - 11/20/2020 Added a new method populateTargetApexScriptOnMassActionConfiguration()
                        V2.2 - Modified - Victor Hanson - CR-20200821-14459 - 02/03/2021
                        V2.3 - Modified - Mahendra Swarnakar - 03/04/2021 - CR-20210301-14956 - Error when trying to edit any fields on Cappex Membership pages
                        V2.4 - Modified - Saurabh Kumar - CR-20210210-14902 - 02/16/2021 - Added a new method cloneRegistrationsFromParentEventToChildEvent()
                        V2.5 - Modified - Saurabh Kumar - 05/02/2021 - CR-20210128-14855
                        V2.6 - Modified - Chirag Soni  - CR-20210511-15137 - 10/28/2021 - Modified Method -  cloneRegistrationsFromParentEventToChildEvent() - Added a logic to Create Elevated meal registration records when EAB Event is Elevated Meal
                        V2.7 - Modified - Chirag Soni - CR-20211112-15583 - 11/17/2021 - QA/UAT Issue #101 fixes updated method updateCommunicationTemplate - commented else part from last .
                        V2.8 - Modified - Lawrence Lam - 07/25/2021 - CR-20210606-15193 - Prevent callout if Campaign ID = null.
			V2.9 - Modified - Chirag Soni - 02/09/2022 - CR-20220208-15772 - updated method processAcquiaAutomation(),  Added scheduled Batch_AcquiaSync and commented enqueuing of AcquiaHttpCallout
         
 * 
 **/
public class AdvisoryEventTriggerHelper {
    
    //This flag is to set the Registration creation limit
    public static Integer LIMIT_REGISTRATION_CREATE = 2000;
    
    public final static String USE_PARENT_S_RULES = 'Use parent\'s rules';
    public final static String CLONE_PARENT_S_RULES = 'Clone rules from parent';
    public final static String ESTABLISH_INDEPENDENT_RULES = 'Establish independent rules';
    
    //Created by Saurabh KUmar - 05/02/2021 - CR-20210128-14855: Set to hold EAB Event Ids to avoid multiple acquia callout for same record.
    public static Set<Id> eabEventIdsWhichAlreadyProceedWithAcquia = new Set<Id>();
    
    //Added - Saurabh Kumar - CR-20210210-14902 - 02/16/2021
    public static Boolean isMethodAlreadyExecuted = false;

    //02/03/2021 - CR-20200821-14459 - Victor Hanson - prevent method from executing more than once per invocation
    public static Boolean populateTopParentHasExecuted = false;
    //02/03/2021 - CR-20200821-14459 - Victor Hanson - Map to hold the communication template with the event type
    public static Map<String, Id> mapCommunicationTemplates { get; set; }
    
    //V1.9 - Modified - Saurabh Kumar - CR-20200819-14450 - 11/03/2020 - Removed the references of "Rules_Thresholds__c" and "Rules_Titles__c" fields
    //Map to Hold the appropriate unique rule field for each record type
    public static Map<String, String> mapRuleFieldsWithRecordTypeDeveloperName = new Map<String, String>{
                                                                                        'Rules_Programs__c' => 'Program'
                                                                                        //'Rules_Thresholds__c' => 'Threshold',
                                                                                        //'Rules_Titles__c' => 'Title'
                                                                                        };
    
    //Map to hold the Record Types
    public static Map<Id, RecordType> mapMeetingRecordTypes {
        
        get {
            //Check if it's null, only then query
            if(mapMeetingRecordTypes == null) {
                
                mapMeetingRecordTypes = new Map<Id, RecordType>([Select Id, Name, DeveloperName from RecordType where SObjectType = 'Advisory_Event__c' AND IsActive = true]);
            }
            return mapMeetingRecordTypes;
        }
    }
    
    //This map is to hold the mapping of Source Primary  role to Target Primary role for each record Type
    //Key = Meeting.RecordType.DeveloperName
    //Value = Map
    //Key = Child Team Member Role
    //Value = Parent Team Member Role
    public final static Map<String, Map<String, String>> MAP_RECORD_TYPE_WITH_TARGET_SOURCE_ROLE 
                            = new Map<String, Map<String, String>> {
                                                                    'Series' => new Map<String, String> {
                                                                                                            'Series Planner' => 'Series Planner', 
                                                                                                            'Series Coordinator' => 'Series Coordinator'
                                                                                                        },
                                                                    'Event' => new Map<String, String> {
                                                                                                            'Event Planner' => 'Series Planner', 
                                                                                                            'Event Coordinator' => 'Series Coordinator', 
                                                                                                            'On Site Planner' => 'Series Planner'
                                                                                                        },
                                                                    'Session' => new Map<String, String> {
                                                                                                            'Event Planner' => 'Event Planner', 
                                                                                                            'Event Coordinator' => 'Event Coordinator', 
                                                                                                            'On Site Planner' => 'Event Planner'
                                                                                                        }
                                                                };

    /**
     * @description :   Populates the masterAPIName field of a record looks up to a parent of the same record type.  
     *                  (ie: institution top parent Id could be populated using this method)
     * 
     * @params      :   trigger.new, trigger.oldMap, object name, parent field name, master field name
     * 
     * @return      :   void
     **/
    public static voId populateTopParent(list<SObject> newListSObj, map<Id, SObject> oldMapSObj, string objectAPIName, string parentAPIName, string masterAPIName) {
        
        //02/03/2021 - CR-20200821-14459 - Victor Hanson - prevent method from executing more than once per invocation
        if (populateTopParentHasExecuted) {
            return;
        }

        list<SObject> sObjList = newListSObj;
        if (trigger.isDelete) sObjList = oldMapSObj.values();
        
        // Identify all the parents of the affected records
        Set<Id> objParents = new Set<Id>();
        if (newListSObj != null) {
            for(SObject obj : newListSObj)
                objParents.add((string)obj.get(parentAPIName));
        }
        
        // If we're inserting or updating, set the Master
        if(Trigger.isBefore && (Trigger.isInsert || Trigger.IsUpdate))
        {
            
            // Get the details of the parents, including their Master SObjs
            string parentQry = 'SELECT ' + masterAPIName + ', ' + parentAPIName.replace('__c', '__r') + '.' + masterAPIName + ' FROM ' + objectAPIName + ' WHERE Id IN :objParents';
            Map<Id, SObject> parentSObjs = new Map<Id, SObject>(database.query(parentQry));
            
            // Cycle through all the changed SObjs
            for(SObject SObj : newListSObj)
            {
                // If inserting and there's no parent, or 
                // updating and there's no change to the parent, 
                // do nothing
                if((Trigger.IsInsert && SObj.get(parentAPIName) == null) ||
                   (Trigger.IsUpdate && SObj.get(parentAPIName) == oldMapSObj.get(SObj.Id).get(parentAPIName)))
                {                
                    
                    //
                    // The following all assume a change to the parent
                    //
                    
                    // If the current Parent has been emptied, it has no master
                } else if(SObj.get(parentAPIName) == null)
                {
                    SObj.put(masterAPIName, null);
                    
                    // if the matching parent record has no parent, the current record uses
                    // the matching parent as its master
                } else if(parentSObjs.get((string)SObj.get(parentAPIName)).get(masterAPIName) == null)
                {
                    
                    SObj.put(masterAPIName, SObj.get(parentAPIName));
                    
                    // Otherwise, the current record uses the master of its parent as its master
                } else
                {
                   // string s = string.valueOf();
                    SObj.put(masterAPIName, parentSObjs.get((string)SObj.get(parentAPIName)).get(masterAPIName));                
                }
            }
            // If we're deleting or updating, set the children's master
        } else if(Trigger.isAfter && (Trigger.IsUpdate || Trigger.IsDelete))
        {
            Map<Id, Id> changedParents = new Map<Id, Id>();
            if(Trigger.IsDelete)
            {
                // Since we've deleted a SObj, let's Identify the deleted parent and
                // simply let the isUpdate trigger handle the re-parenting of the children
                for(SObject SObj : oldMapSObj.values())
                    changedParents.put(SObj.Id, null);
            } else
            {
                // If the Master has changed, let's capture the SObjs whose children need to be reset
                for(SObject SObj : newListSObj) {
                    if(SObj.get(masterAPIName) != oldMapSObj.get(SObj.Id).get(masterAPIName))
                        changedParents.put(SObj.Id, (string)SObj.get(masterAPIName));
                }
            }
            
            // If we've Identified any changed parents, let's update the appropriate children
            if(changedParents.size() > 0)
            {
                
                // Find all the related children
                set<Id> parentIdSet = changedParents.keySet();
                string childQry = 'SELECT ' + masterAPIName + ', ' + parentAPIName + ' FROM ' + objectAPIName + ' WHERE ' + parentAPIName + ' IN :parentIdSet';
                List<SObject> reParenting = new List<SObject>(database.query(childQry));
                
                if(reParenting.size() > 0)
                {
                    // Reset the childrens' Master to be the master of their parents
                    for(SObject SObj : reParenting)
                        SObj.put(masterAPIName, changedParents.get((string)SObj.get(parentAPIName)));
                    
                    update reParenting;
                }
            }
        }

        //02/03/2021 - CR-20200821-14459 - Victor Hanson - prevent method from executing more than once per invocation
        populateTopParentHasExecuted = true;
    }
    
    /**
     *  @description    :   This method is to manage the entity subscription for users
                                1. Calls the Chatter AddFollower method in the ChatterHelper class to add the record?s Manager to the feed.  
                                2. If there is a previous value for the Manager, calls the removeFollower method to remove the previous user.
     * 
     *  @args           :   List of new and old meeting records
     * 
     *  @return         :   void
     * 
     *  @revision log   :   Modified - Saurabh Kumar - CR-20201105-14664 - 11/18/2020 -  Removed the references of Manager__c from manageMeetingFollowers() method
     **/
    public static void manageMeetingFollowers(List<Advisory_Event__c> newMeetings, Map<Id, Advisory_Event__c> mapOldMeetings) {
        
        //Create a set to hold the follower users and following records
        Set<String> setUsersWithRecordIdsToFollow = new Set<String>();
        
        //Create a set to hold the users to remove and records
        Set<String> setUsersWithRecordIdsToUnFollow = new Set<String>();
        
        //V1.1 Modified - Saurabh Kumar - CR-20201105-14664 - 11/18/2020 -  Removed the references of Manager__c: Start
        //Loop through the meeting records and populate set
        /*for(Advisory_Event__c meeting : newMeetings) {
            
            //Insert Case
            if(meeting.Manager__c != null && meeting.Is_Closed__c != true && mapOldMeetings == null) {
                
                //Add in list to create the Subscription record
                setUsersWithRecordIdsToFollow.add(meeting.Manager__c + '-' + meeting.Id);
            } else if(mapOldMeetings != null 
                && (meeting.Manager__c != mapOldMeetings.get(meeting.Id).Manager__c
                    || meeting.Is_Closed__c != mapOldMeetings.get(meeting.Id).Is_Closed__c)) {
                
                //Update Case
                if(meeting.Manager__c != null
                    && ((meeting.Manager__c != mapOldMeetings.get(meeting.Id).Manager__c
                        && meeting.Is_Closed__c != true)
                        || 
                        (meeting.Is_Closed__c != mapOldMeetings.get(meeting.Id).Is_Closed__c
                        && mapOldMeetings.get(meeting.Id).Is_Closed__c == true))) {
                    
                    //Add in list to create the Subscription record
                    setUsersWithRecordIdsToFollow.add(meeting.Manager__c + '-' + meeting.Id);
                }
                
                //Remove from Closed Meetings
                if(meeting.Manager__c != null
                    && meeting.Is_Closed__c != mapOldMeetings.get(meeting.Id).Is_Closed__c
                    && meeting.Is_Closed__c == true) {
                    
                    //Add in list to create the Subscription record
                    setUsersWithRecordIdsToUnFollow.add(mapOldMeetings.get(meeting.Id).Manager__c + '-' + meeting.Id);
                } 
                
                //Removed Old one
                if(mapOldMeetings.get(meeting.Id).Manager__c != null
                    && meeting.Manager__c != mapOldMeetings.get(meeting.Id).Manager__c) {
                    
                    //Add in list to remove the Subscription record
                    setUsersWithRecordIdsToUnFollow.add(mapOldMeetings.get(meeting.Id).Manager__c + '-' + meeting.Id);
                }
            }
        }*/
        //V1.1 Modified - Saurabh Kumar - CR-20201105-14664 - 11/18/2020 -  Removed the references of Manager__c: End
        
        //Call helper class method to delete the Subscrition records
        ChatterHelper.RemoveFollower(setUsersWithRecordIdsToUnFollow);
        
        //Call helper class method to create the Subscrition records
        ChatterHelper.AddFollower(setUsersWithRecordIdsToFollow);
    }
    
    /**
     *  @description    :   This method is to create the Team Member records on Event records when they are created.
     			    When a new ABC Event is created, create default Team Member records, 
                            where some values will default based on the presence of correspondents on the ABC Event?s parent. 
                            If no parent is defined, or the parent does not have a Team Member with the indicated role, 
                            then a Team Member record is still created, but will not yet have a person defined.
                            Check the variable : MAP_RECORD_TYPE_WITH_SOURCE_TARGET_ROLE
     * 
     *  @args           :   List of Meetings
     * 
     *  @return         :   void
     * 
     **/
    public static void createDefaultTeamMembers(List<Advisory_Event__c> meetings) {
        
        //Create a set of Parent Meetings
        Set<Id> parentMeetingsIds = new Set<Id>();
        
        //loop through the meetings and find the Parent Event
        for(Advisory_Event__c meeting : meetings) {
            
            //Check for the Null
            if(meeting.Parent_Event__c != null)
                parentMeetingsIds.add(meeting.Parent_Event__c);
        }
        
        //Map to hold the parent meetings and related Team Members
        Map<Id, Map<String, Id>> mapParentWithTeamMemberRole = new Map<Id, Map<String, Id>>();
        
        //Check parentMeetingsIds size, query data
        if(parentMeetingsIds.size() > 0) {
            
            //Query Team Member Roles
            for(Team_Member__c teamMember : [Select Id, Advisory_Event__c, Primary_Role__c, Team_Member__c from Team_Member__c where Advisory_Event__c != null AND Advisory_Event__c IN: parentMeetingsIds AND Primary_Role__c != null]) {
                
                //Add data in Map
                if(!mapParentWithTeamMemberRole.containsKey(teamMember.Advisory_Event__c))
                    mapParentWithTeamMemberRole.put(teamMember.Advisory_Event__c, new Map<String, Id>{});
                
                //Map roles with contact
                Map<String, Id> mapRole = mapParentWithTeamMemberRole.get(teamMember.Advisory_Event__c);
                mapRole.put(teamMember.Primary_Role__c, teamMember.Team_Member__c);
                
                //put this map back in original map
                mapParentWithTeamMemberRole.put(teamMember.Advisory_Event__c, mapRole);
            }
        }
        
        //List of teamMembers to be inserted
        List<Team_Member__c> teamMembers = new List<Team_Member__c>();
        
        //Now Loop through the new Meetings again, and create the defaults team member based on the record type
        //loop through the meetings and find the Parent Event
        for(Advisory_Event__c meeting : meetings) {
            
            //Check for the record type first, and create the only appropriate team members
            if(meeting.RecordTypeId != null
                && MAP_RECORD_TYPE_WITH_TARGET_SOURCE_ROLE.containsKey(mapMeetingRecordTypes.get(meeting.RecordTypeId).DeveloperName)) {
                
                //Get the mapping from map
                Map<String, String> mapTargetSourceRoleMapping = MAP_RECORD_TYPE_WITH_TARGET_SOURCE_ROLE.get(mapMeetingRecordTypes.get(meeting.RecordTypeId).DeveloperName);
                
                //Check Parent Id, if not exists, then create the default Team Member for all Target Roles
                if(meeting.Parent_Event__c == null
                    || !mapParentWithTeamMemberRole.containsKey(meeting.Parent_Event__c)
                    || mapParentWithTeamMemberRole.get(meeting.Parent_Event__c).size() == 0) {
                    //Create the default Team member records
                    for(String targetRole : mapTargetSourceRoleMapping.keySet()) {
                        
                        //Create a new Team Member record
                        teamMembers.add(new Team_Member__c(Advisory_Event__c = meeting.Id, Primary_Role__c = targetRole, Team_Member__c = null));
                    }
                } else if(mapParentWithTeamMemberRole.containsKey(meeting.Parent_Event__c)
                    && mapParentWithTeamMemberRole.get(meeting.Parent_Event__c).size() > 0) {
                    
                    //Exsiting Roles and Contacts
                    Map<String, Id> mapExistingRoleWithTeamMember = mapParentWithTeamMemberRole.get(meeting.Parent_Event__c);
                    
                    //Loop through the map and check if there is any existing team Member
                    //If yes, then add the same
                    //Else create a default team member record
                    //Create the default Team member records
                    for(String targetRole : mapTargetSourceRoleMapping.keySet()) {
                        
                        //Source role
                        String sourceRole = mapTargetSourceRoleMapping.get(targetRole);
                        
                        //Check if role already exsits on parent, the use the same contact, else create default
                        if(mapExistingRoleWithTeamMember.containsKey(sourceRole)) {
                            
                            //Create a new Team Member record and with existing Contact
                            teamMembers.add(new Team_Member__c(Advisory_Event__c = meeting.Id, Primary_Role__c = targetRole, Team_Member__c = mapExistingRoleWithTeamMember.get(sourceRole)));
                        } else {
                            
                            //Create a new Team Member record and with existing Contact
                            teamMembers.add(new Team_Member__c(Advisory_Event__c = meeting.Id, Primary_Role__c = targetRole, Team_Member__c = null));
                        }
                    }   
                }
            }
        }
        
        //Check for the size and insert the results
        if(teamMembers.size() > 0)
            insert teamMembers;
    }
    
    /**
     *  @description    :   This method is to clone the Rules from Parent. 
                            Rules for the current ABC Event are managed according to the selection of any of the �Rules � � picklist fields.
                            If set to �Clone rules from Parent�:
                                    o   Clone the parent�s rules for that rule type
                                    o   Set the value of the picklist to �Establish independent rules�
     *
     *  @args           :   List of new meeting records, Old meeting records map
     *
     *  @return         :   void
     *
     **/
    public static void manageCloneRulesFromParent(List<Advisory_Event__c> newMeetings, Map<Id, Advisory_Event__c> mapOldMeetings) {
        
        //Create a set of Parent Events with Id, and rules type they have
        Map<Id, Set<String>> mapParentMeetingsWithType = new Map<Id, Set<String>>();
        
        //This set is to hold the record types developer names which need to be queried from parent
        Set<String> setRecordTypesDeveloperName = new Set<String>();
        
        //Create a list of Meeting records to update with value "Estabalished"
        List<Advisory_Event__c> establishedMeetings = new List<Advisory_Event__c>();
        
        //Loop through the records
        for(Advisory_Event__c meeting : newMeetings) {
            
            //Modified - Saurabh Kumar - CR-20200819-14450 - 11/03/2020 - Removed the references of "Rules_Thresholds__c" and "Rules_Titles__c" fields            
            //Check for the meeting record's Parent and Value for the rule field
            if((meeting.Rules_Programs__c == CLONE_PARENT_S_RULES
                    //|| meeting.Rules_Thresholds__c == CLONE_PARENT_S_RULES
                    //|| meeting.Rules_Titles__c == CLONE_PARENT_S_RULES
                    )
                && (mapOldMeetings == null 
                    || mapOldMeetings.get(meeting.Id).Rules_Programs__c != meeting.Rules_Programs__c
                    //|| mapOldMeetings.get(meeting.Id).Rules_Thresholds__c != meeting.Rules_Thresholds__c
                   // || mapOldMeetings.get(meeting.Id).Rules_Titles__c != meeting.Rules_Titles__c
                   )
            ) {
                
                //Set Value to established rule
                Advisory_Event__c establishedMeeting = new Advisory_Event__c(Id = meeting.Id);
                
                //Check if mapParentMeetingsWithType has an instance
                if(meeting.Parent_Event__c != null && !mapParentMeetingsWithType.containsKey(meeting.Parent_Event__c))
                    mapParentMeetingsWithType.put(meeting.Parent_Event__c, new Set<String>{});
                
                //Loop through the Rules field and check if any of the value was change
                for(String fieldName : mapRuleFieldsWithRecordTypeDeveloperName.keyset()) {
                    
                    //Chekc for old and new
                    if(meeting.get(fieldName) != null 
                        && String.valueOf(meeting.get(fieldName)) == CLONE_PARENT_S_RULES
                        && (mapOldMeetings == null 
                            || mapOldMeetings.get(meeting.Id).get(fieldName) == null 
                            || String.valueOf(meeting.get(fieldName)) != String.valueOf(mapOldMeetings.get(meeting.Id).get(fieldName)))
                    ) {
                        
                        //Set Established
                        establishedMeeting.put(fieldName, ESTABLISH_INDEPENDENT_RULES);
                        
                        //Add Record Type Name in Map
                        if(meeting.Parent_Event__c != null)
                            mapParentMeetingsWithType.get(meeting.Parent_Event__c).add(mapRuleFieldsWithRecordTypeDeveloperName.get(fieldName));
                    }
                    
                    //Add in global record type set
                    if(meeting.Parent_Event__c != null)
                        setRecordTypesDeveloperName.addAll(mapParentMeetingsWithType.get(meeting.Parent_Event__c));
                }
                
                //Add in list to be updated
                establishedMeetings.add(establishedMeeting);
            }
        }
        
        //Query data from Parent Event
        if(mapParentMeetingsWithType.size() >= 0) {
            
            //Set a map to hold the Parent Meeting Id, with it's Rule Record Type and Rules
            Map<Id, Map<String, List<Rule__c>>> mapParentMeetingRuleswitRecordType = new Map<Id, Map<String, List<Rule__c>>>(); 
            Set<Id> parentMeetingsIdsSet = mapParentMeetingsWithType.keySet();
                
            //Prepare the query to fetch the rule data
            String SOQLQuery = 'Select Id ';
                    
            //fetch fields from fieldset to support the dynamic behaviour
            for(Schema.FieldSetMember f : SObjectType.Rule__c.FieldSets.RuleCloningList.getFields())
                SOQLQuery += ', ' + f.getFieldPath();
            SOQLQuery += ' FROM Rule__c where Advisory_Event__c IN: parentMeetingsIdsSet AND RecordType.DeveloperName IN: setRecordTypesDeveloperName';
            
            //Query Parent Rules
            for(Rule__c rule : (List<Rule__c>)database.query(SOQLQuery)) {
                
                //Add in map
                if(!mapParentMeetingRuleswitRecordType.containsKey(rule.Advisory_Event__c))
                    mapParentMeetingRuleswitRecordType.put(rule.Advisory_Event__c, new Map<String, List<Rule__c>>{});
                    
                //Check if record type is already in map
                Map<String, List<Rule__c>> mapRecordTypeWithRules = mapParentMeetingRuleswitRecordType.get(rule.Advisory_Event__c);
                String ruleRecordTypeDeveloperName = RuleTriggerHelper.mapRuleRecordTypes.get(rule.RecordTypeId).DeveloperName;
                if(!mapRecordTypeWithRules.containsKey(ruleRecordTypeDeveloperName))
                    mapRecordTypeWithRules.put(ruleRecordTypeDeveloperName, new List<Rule__c>{});
                
                //Add rule and put it back in map
                mapRecordTypeWithRules.get(ruleRecordTypeDeveloperName).add(rule);
                mapParentMeetingRuleswitRecordType.put(rule.Advisory_Event__c, mapRecordTypeWithRules);
            }
            
            //Now Loop through the new records again and create the lost of rules to be cloned
            List<Rule__c> completeCloneRulesList = new List<Rule__c>();
            
            //Iterate list
            //Loop through the records
            for(Advisory_Event__c meeting : newMeetings) {
                
                //Modified - Saurabh Kumar - CR-20200819-14450 - 11/03/2020 - Removed the references of "Rules_Thresholds__c" and "Rules_Titles__c" fields
                //Check for the meeting record's Parent and Value for the rule field
                if(meeting.Parent_Event__c != null
                    && (meeting.Rules_Programs__c == CLONE_PARENT_S_RULES
                        //|| meeting.Rules_Thresholds__c == CLONE_PARENT_S_RULES
                        //|| meeting.Rules_Titles__c == CLONE_PARENT_S_RULES
                       )
                    && (mapOldMeetings == null 
                        || mapOldMeetings.get(meeting.Id).Rules_Programs__c != meeting.Rules_Programs__c
                        //|| mapOldMeetings.get(meeting.Id).Rules_Thresholds__c != meeting.Rules_Thresholds__c
                       // || mapOldMeetings.get(meeting.Id).Rules_Titles__c != meeting.Rules_Titles__c
                       )
                ) {
                    
                    //Loop through the Rules field and check if any of the value was change
                    for(String fieldName : mapRuleFieldsWithRecordTypeDeveloperName.keyset()) {
                        
                        //Get the Existing Parent Rules related to this record
                        Map<String, List<Rule__c>> mapRTypesWithRules = mapParentMeetingRuleswitRecordType.get(meeting.Parent_Event__c);
                        
                        //Check for old and new
                        if(meeting.get(fieldName) != null 
                            && String.valueOf(meeting.get(fieldName)) == CLONE_PARENT_S_RULES
                            && (mapOldMeetings == null 
                                || mapOldMeetings.get(meeting.Id).get(fieldName) == null 
                                || String.valueOf(meeting.get(fieldName)) != String.valueOf(mapOldMeetings.get(meeting.Id).get(fieldName)))
                        ) {
                            
                            //Get the related record type developer name
                            String recordTypeDeveloperName = mapRuleFieldsWithRecordTypeDeveloperName.get(fieldName);
                            
                            //Check if this field need to be processed
                            if(mapRTypesWithRules == null || !mapRTypesWithRules.containsKey(recordTypeDeveloperName))
                                continue;
                            
                            //Related
                            List<Rule__c> relatedRules = mapRTypesWithRules.get(recordTypeDeveloperName);
                            
                            //Clone this records and Update the ABC Event Id
                            List<Rule__c> clonedRelatedRules = relatedRules.deepClone(false);
                            
                            for(Rule__c rule : clonedRelatedRules) {
                                
                                //Copy Event Id
                                rule.Advisory_Event__c = meeting.Id;    
                            }
                            
                            //Add in main list
                            completeCloneRulesList.addAll(clonedRelatedRules);
                        }
                    }
                }
            }
            
            //Insert rules
            if(completeCloneRulesList.size() > 0)
                insert completeCloneRulesList;
        }
                
        //Update meetings
        if(establishedMeetings.size() > 0)
            update establishedMeetings;
    }
    
    /**
     *  @description    :   deleteRulesForUseForParent
     *                      If set to �Use parent�s rules�:
                                    o   Do not allow any insertion of rules for that rule type
                                    o   #2) Delete any existing rules for that type from the current ABC Event.
     * 
     *  @args           :   List of rules being updated
     * 
     *  @return         :   void
     * 
     **/
    public static void deleteRulesForUseForParent(List<Advisory_Event__c> newMeetings, Map<Id, Advisory_Event__c> mapOldMeetings) {
        
        //Create a set of Parent Events with Id, and rules type they have
        Map<Id, Set<String>> mapMeetingsWithType = new Map<Id, Set<String>>();
        Map<Id, Set<String>> mapParentMeetingsWithType = new Map<Id, Set<String>>();
        Map<Id, Set<Id>> mapParentWithNewMeetings = new Map<Id, Set<Id>>();
        
        //Create a list of Advisory Events to be updated with the Primary Program field
        Map<Id, Advisory_Event__c> mapMeetings = new Map<Id, Advisory_Event__c>();
        
        //This set is to hold the record types developer names which need to be queried from parent
        Set<String> setRecordTypesDeveloperName = new Set<String>();
        
        //Loop through the meetings and check if New value is Use Parent's rule
        //Loop through the records
        for(Advisory_Event__c meeting : newMeetings) {
            
            //Modified - Saurabh Kumar - CR-20200819-14450 - 11/03/2020 - Removed the references of "Rules_Thresholds__c" and "Rules_Titles__c" fields
            //Check for the meeting record's Parent and Value for the rule field
            if((meeting.Rules_Programs__c == USE_PARENT_S_RULES
                    //|| meeting.Rules_Thresholds__c == USE_PARENT_S_RULES
                    //|| meeting.Rules_Titles__c == USE_PARENT_S_RULES
               )
                && (mapOldMeetings == null 
                    || mapOldMeetings.get(meeting.Id).Rules_Programs__c != meeting.Rules_Programs__c
                    //|| mapOldMeetings.get(meeting.Id).Rules_Thresholds__c != meeting.Rules_Thresholds__c
                    //|| mapOldMeetings.get(meeting.Id).Rules_Titles__c != meeting.Rules_Titles__c
                   )
            ) {
                
                //Check if mapMeetingsWithType has an instance
                if(!mapMeetingsWithType.containsKey(meeting.Id))
                    mapMeetingsWithType.put(meeting.Id, new Set<String>{});
                if(!mapParentMeetingsWithType.containsKey(meeting.Parent_Event__c))
                    mapParentMeetingsWithType.put(meeting.Parent_Event__c, new Set<String>{});
                if(!mapParentWithNewMeetings.containsKey(meeting.Parent_Event__c))
                    mapParentWithNewMeetings.put(meeting.Parent_Event__c, new Set<Id>{});
                
                //Loop through the Rules field and check if any of the value was change
                for(String fieldName : mapRuleFieldsWithRecordTypeDeveloperName.keyset()) {
                    
                    //Chekc for old and new
                    if(meeting.get(fieldName) != null 
                        && String.valueOf(meeting.get(fieldName)) == USE_PARENT_S_RULES
                        && (mapOldMeetings == null 
                            || mapOldMeetings.get(meeting.Id).get(fieldName) == null 
                            || String.valueOf(meeting.get(fieldName)) != String.valueOf(mapOldMeetings.get(meeting.Id).get(fieldName)))
                    ) {
                        
                        //Add Record Type Name in Map
                        mapMeetingsWithType.get(meeting.Id).add(mapRuleFieldsWithRecordTypeDeveloperName.get(fieldName));
                        mapParentMeetingsWithType.get(meeting.Parent_Event__c).add(mapRuleFieldsWithRecordTypeDeveloperName.get(fieldName));
                        mapParentWithNewMeetings.get(meeting.Parent_Event__c).add(meeting.Id);
                    }
                    
                    //Add in global record type set
                    setRecordTypesDeveloperName.addAll(mapMeetingsWithType.get(meeting.Id));
                }
            }   
        }
        
        //Query data from Parent Event
        if(mapMeetingsWithType.size() == 0)
            return;
            
        //Set a map to hold the Parent Meeting Id, with it's Rule Record Type and Rules
        Map<Id, Map<String, List<Rule__c>>> mapParentMeetingRuleswitRecordType = new Map<Id, Map<String, List<Rule__c>>>(); 
        Set<Id> parentMeetingsIdsSet = mapMeetingsWithType.keySet();
        
        //List to hold the rules to be deleted
        List<Rule__c> rulesToDelete = new List<Rule__c>();
        List<Event_Rule__c> eRulesToDelete = new List<Event_Rule__c>();
        List<Event_Rule__c> eRulesToCreate = new List<Event_Rule__c>();
            
        //Query Parent Rules
        for(Rule__c rule : [Select Id, Advisory_Event__c, RecordType.DeveloperName FROM Rule__c where Advisory_Event__c IN: parentMeetingsIdsSet AND RecordType.DeveloperName IN: setRecordTypesDeveloperName]) {
            
            //Check and add in list to be deleted
            if(mapMeetingsWithType.containsKey(rule.Advisory_Event__c) && mapMeetingsWithType.get(rule.Advisory_Event__c).contains(rule.RecordType.DeveloperName))
                rulesToDelete.add(rule);
        }
        
        //Query Parent Rules
        for(Event_Rule__c eRule : [Select Id, Advisory_Event__c, Rule__r.RecordType.DeveloperName FROM Event_Rule__c where Advisory_Event__c IN: parentMeetingsIdsSet AND Rule__r.RecordType.DeveloperName IN: setRecordTypesDeveloperName]) {
            
            //Check and add in list to be deleted
            if(mapMeetingsWithType.containsKey(eRule.Advisory_Event__c) && mapMeetingsWithType.get(eRule.Advisory_Event__c).contains(eRule.Rule__r.RecordType.DeveloperName))
                eRulesToDelete.add(eRule);
        }
        
        //Query Parent Rules
        for(Event_Rule__c rule : [Select Id, Advisory_Event__c, Advisory_Event__r.Primary_Program__c, Rule__c, Rule__r.RecordType.DeveloperName FROM Event_Rule__c where Advisory_Event__c IN: mapParentMeetingsWithType.keySet() AND Rule__r.RecordType.DeveloperName IN: setRecordTypesDeveloperName]) {
            //Check and add in list to be deleted
            if(mapParentMeetingsWithType.containsKey(rule.Advisory_Event__c) && mapParentMeetingsWithType.get(rule.Advisory_Event__c).contains(rule.Rule__r.RecordType.DeveloperName)) {
                for(Id meetingId : mapParentWithNewMeetings.get(rule.Advisory_Event__c)) {
                    
                    //Add in list
                    eRulesToCreate.add(new Event_Rule__c(Advisory_Event__c = meetingId, Rule__c = rule.Rule__c));
                    if(rule.Rule__r.RecordType.DeveloperName == 'Program' && !mapMeetings.containsKey(rule.Advisory_Event__c))
                        mapMeetings.put(rule.Advisory_Event__c, new Advisory_Event__c(Id = meetingId, Primary_Program__c = rule.Advisory_Event__r.Primary_Program__c));     
                }
            }
        }
        //Check for the size and delete the list
        if(rulesToDelete.size() > 0)
            delete rulesToDelete;
        if(eRulesToDelete.size() > 0)
            delete eRulesToDelete;
        if(eRulesToCreate.size() > 0)
            insert eRulesToCreate;
        if(mapMeetings.size() > 0)
            update mapMeetings.values();
    }
    
    /**
     *  @description    :   deleteRulesForUseForParent
     *                      If set to ESTABLISH_INDEPENDENT_RULES
                                    o   #1) Delete any existing rules for that type from the current ABC Event.
     * 
     *  @args           :   List of rules being updated
     * 
     *  @return         :   void
     * 
     **/
    public static void deleteRulesForEstablishedIndependentRule(List<Advisory_Event__c> newMeetings, Map<Id, Advisory_Event__c> mapOldMeetings) {
        
        //Create a set of Parent Events with Id, and rules type they have
        Map<Id, Set<String>> mapMeetingsWithType = new Map<Id, Set<String>>();
        
        //This set is to hold the record types developer names which need to be queried from parent
        Set<String> setRecordTypesDeveloperName = new Set<String>();
        
        //Loop through the meetings and check if New value is Use Parent's rule
        //Loop through the records
        for(Advisory_Event__c meeting : newMeetings) {
            
            //Modified - Saurabh Kumar - CR-20200819-14450 - 11/03/2020 - Removed the references of "Rules_Thresholds__c" and "Rules_Titles__c" fields
            //Check for the meeting record's Parent and Value for the rule field
            if((meeting.Rules_Programs__c == ESTABLISH_INDEPENDENT_RULES && mapOldMeetings.get(meeting.Id).Rules_Programs__c == USE_PARENT_S_RULES)
                //|| (meeting.Rules_Thresholds__c == ESTABLISH_INDEPENDENT_RULES && mapOldMeetings.get(meeting.Id).Rules_Thresholds__c == USE_PARENT_S_RULES)
                //|| (meeting.Rules_Titles__c == ESTABLISH_INDEPENDENT_RULES && mapOldMeetings.get(meeting.Id).Rules_Titles__c == USE_PARENT_S_RULES)
            ) {
                
                //Check if mapMeetingsWithType has an instance
                if(!mapMeetingsWithType.containsKey(meeting.Id))
                    mapMeetingsWithType.put(meeting.Id, new Set<String>{});
                
                //Loop through the Rules field and check if any of the value was change
                for(String fieldName : mapRuleFieldsWithRecordTypeDeveloperName.keyset()) {
                    
                    //Chekc for old and new
                    if(meeting.get(fieldName) != null 
                        && String.valueOf(meeting.get(fieldName)) == ESTABLISH_INDEPENDENT_RULES
                        && mapOldMeetings.get(meeting.Id).get(fieldName) != null 
                        && String.valueOf(mapOldMeetings.get(meeting.Id).get(fieldName)) == USE_PARENT_S_RULES
                    ) {
                        
                        //Add Record Type Name in Map
                        mapMeetingsWithType.get(meeting.Id).add(mapRuleFieldsWithRecordTypeDeveloperName.get(fieldName));
                    }
                    
                    //Add in global record type set
                    setRecordTypesDeveloperName.addAll(mapMeetingsWithType.get(meeting.Id));
                }
            }   
        }
        
        //Query data from Parent Event
        if(mapMeetingsWithType.size() == 0)
            return;
            
        //List to hold the rules to be deleted
        List<Event_Rule__c> eRulesToDelete = new List<Event_Rule__c>();
            
        //Query Parent Rules
        for(Event_Rule__c eRule : [Select Id, Advisory_Event__c, Rule__r.RecordType.DeveloperName FROM Event_Rule__c where Advisory_Event__c IN: mapMeetingsWithType.keySet() AND Rule__r.RecordType.DeveloperName IN: setRecordTypesDeveloperName]) {
            
            //Check and add in list to be deleted
            if(mapMeetingsWithType.containsKey(eRule.Advisory_Event__c) && mapMeetingsWithType.get(eRule.Advisory_Event__c).contains(eRule.Rule__r.RecordType.DeveloperName))
                eRulesToDelete.add(eRule);
        }
        
        //Check for the size and delete the list
        if(eRulesToDelete.size() > 0)
            delete eRulesToDelete;
    }
    
    //Method to update Calendar Communication template.
    //Added By Rajeev jain - CR-20200424-13983 - 04/29/2020 - Added a new Method, updateCommunicationTemplate
    //Modified By - Chirag Soni - CR-20211112-15583 - QA/UAT Issue #101 fixes commented else part. 
    public static void updateCommunicationTemplate(List<Advisory_Event__c> newEvents, Map<Id, Advisory_Event__c> oldMapAdvisoryEvents) {
        
        if (mapCommunicationTemplates == null) 
        {
            //02/03/2021 - CR-20200821-14459 - Victor Hanson - updated so the query only executes when necessary
            mapCommunicationTemplates = new Map<String, Id>();

            //Query on the Communication template.
            for(Communication_Template__c comTempl :[Select Id, Name,  Event_Type__c 
                                                    From Communication_Template__c 
                                                    Where RecordType.DeveloperName = 'Calendar_Invite' ]) {
                
                //Check if the comma seprated values exist on the event type. 
                if(String.isNotBlank(comTempl.Event_Type__c) && comTempl.Event_Type__c.contains(',')){
                    for(String evtType : comTempl.Event_Type__c.split(',')) 
                        mapCommunicationTemplates.put(evtType, comTempl.Id);
                }else 
                    mapCommunicationTemplates.put(comTempl.Event_Type__c, comTempl.Id);            
            }
        }
        
        for(Advisory_Event__c aEvent: newEvents) {
            
            //Chck if the nwly Created rcord or updated the event Type. 
            if(oldMapAdvisoryEvents == null || (oldMapAdvisoryEvents != null && oldMapAdvisoryEvents.get(aEvent.Id).Event_Type__c != aEvent.Event_Type__c)) {
                
                if(String.isNotBlank(aEvent.Event_Type__c) && mapCommunicationTemplates.containsKey(aEvent.Event_Type__c))
                    aEvent.Communication_Template__c = mapCommunicationTemplates.get(aEvent.Event_Type__c);
                 //Modified By - Chirag Soni - CR-20211112-15583 - QA/UAT Issue #101 fixes commented else part. 
                //else
                   // aEvent.Communication_Template__c = null;
            }
        }
    }
    
    /**
     * @description     : This method is used to sync Partner Status field on Registration in case of update & delete
     * 
     * @args            : List<Advisory_Event__c> newEABEvents, Map<Id, Advisory_Event__c> oldEABEvents
     * 
     * @return          : Void
     * 
     * @revision log    : V1.0 Created - CR-20200821-14453 09/29/2020
     * */
    public static void syncRegistrationPartnerStatus(List<Advisory_Event__c> newEABEvents, Map<Id, Advisory_Event__c> oldEABEvents){
        
        //Set to hold EAB Event Ids for which should be proceed
        Set<Id> eabEventIds = new Set<Id>();
        
        //Set to hold EAB Event Ids which should be skipped in data processing in case of delete only.
        Set<Id> parentIdsToSkipped = new Set<Id>();
        
        //Map to hold Registration which should be synced
        Map<Id, Registration__c> registrations = new Map<Id, Registration__c>();
     
        for(Advisory_Event__c eabEvent : newEABEvents != null ? newEABEvents : oldEABEvents.values()){
           
            if(newEABEvents == null && eabEvent.Primary_Program__c != null){
                
                parentIdsToSkipped.add(eabEvent.Id);
                eabEventIds.add(eabEvent.Id);
            } else if(eabEvent.Primary_Program__c != oldEABEvents.get(eabEvent.Id).Primary_Program__c && (eabEvent.Primary_Program__c != null
                                                     || oldEABEvents.get(eabEvent.Id).Primary_Program__c != null)){
                eabEventIds.add(eabEvent.Id);
            }
        }
        
        if(eabEventIds.size() == 0)
            return;
                 
        /*registrations = new Map<Id, Registration__c>([Select Id, EAB_Event__c From Registration__c Where EAB_Event__c != null AND Contact__c != null AND
                                            EAB_Event__c IN : eabEventIds AND Contact__r.AccountId != null]);
        if(registrations.size() > 0)
            RegistrationHelper.updatePartnerStatus(registrations.keySet(), parentIdsToSkipped);*/
        
        //Modified By - Mahendra Swarnakar - 03/04/2021 - CR-20210301-14956 - Error when trying to edit any fields on Cappex Membership pages
                        
        registrations = new Map<Id, Registration__c>([Select Id, Name, Origin__c, Parent_Registration__c, Automated_Update__c, EAB_Event__c, EAB_Event__r.Status__c 
                                                      From Registration__c Where EAB_Event__c != null AND Contact__c != null 
                                                      AND Contact__r.AccountId != null AND EAB_Event__c IN : eabEventIds 
                                                      AND (EAB_Event__r.Status__c =: Constants.EAB_EVENT_STATUS_OPEN_REGISTRATION 
                                                      OR EAB_Event__r.Status__c =:Constants.EAB_EVENT_STATUS_OPEN_WAITLIST_ONLY)
                                                     ]);
        
        Boolean isEABEventManager = FeatureManagement.checkPermission('EAB_Event');
        
        if( isEABEventManager && registrations.size() > 0)
            RegistrationHelper.updatePartnerStatus(registrations.keySet(), parentIdsToSkipped);
        //Ends Here - CR-20210301-14956
        
    }
    
    /**
     * @description     : This method is used to populate Registration on Campaign Member.
     *                    Logic: When an Campaign is populated in EABEvent.Invite_List__c, if there are existing Registrations on the EAB Event, check to see if they can be 
     *                          linked to one of the Campaign Members related to the Invite_List__c campaign
     * 
     * @args            : List<Advisory_Event__c> newEABEvents, Map<Id, Advisory_Event__c> oldEABEvents
     * 
     * @return          : Void
     * 
     * @revision log    : V1.0 Created - CR-20200821-14465 10/28/2020
     * */
    public static void populateRegistrationOnCampaignMember(List<Advisory_Event__c> newEABEvents, Map<Id, Advisory_Event__c> oldEABEvents){
        
        //Set to hold EAB Event Id
        Set<Id> eabEventId = new Set<Id>();
        
        //Set to hold Campaign Id
        Set<Id> campaignId = new Set<Id>();
        
        //Map to hold Campaign Member which should be updated
        Map<Id, CampaignMember> mapOfCampaignMemberToUpdate = new Map<Id, CampaignMember>();
        
        for(Advisory_Event__c eabEvent : newEABEvents){
            
            if(eabEvent.Invite_List__c != null && oldEABEvents.get(eabEvent.Id).Invite_List__c != eabEvent.Invite_List__c){
                eabEventId.add(eabEvent.Id);
                campaignId.add(eabEvent.Invite_List__c);
            }
                
        }
        
        if(eabEventId.size() == 0)
            return;
        
        //Query on EAB Event
        Map<Id, Advisory_Event__c> mapOfEABEvents = new Map<Id, Advisory_Event__c>([Select Id, Invite_List__c, (Select Id, Contact__c From Registrations__r) From Advisory_Event__c
                                                                                   Where Id IN : eabEventId]);
        //Query on Campaign
        Map<Id, Campaign> mapOfCampaign = new Map<Id, Campaign>([Select Id, (Select Id, ContactId, Registration__c From CampaignMembers) From Campaign Where Id IN : campaignId]);
        
        for(Advisory_Event__c eabEvent : mapOfEABEvents.values()){
           
            if(!mapOfCampaign.containsKey(eabEvent.Invite_List__c) || mapOfCampaign.get(eabEvent.Invite_List__c).CampaignMembers.size() == 0 || eabEvent.Registrations__r.size() == 0)
                continue;
            for(Registration__c reg : eabEvent.Registrations__r){
                
                for(CampaignMember cm : mapOfCampaign.get(eabEvent.Invite_List__c).CampaignMembers){
                    
                    if(cm.Registration__c != null || reg.Contact__c != cm.ContactId)
                        continue;
                    mapOfCampaignMemberToUpdate.put(cm.Id, new CampaignMember(Id = cm.Id, Registration__c = reg.Id));
                }
            }   
        }
        if(mapOfCampaignMemberToUpdate.size() > 0){
            Util.BypassAllTriggers = true;
            update mapOfCampaignMemberToUpdate.values();
            Util.BypassAllTriggers = false;
        }
    }
    
     /**
     * @description     : This method is used to populate Target Apex Script on Mass Action Configuration record.
     *                    a. When Invite List & Mass Action Configuration fields are both populated
						  b. Query for the Mass Action Configuration record where Id = EABEvent.Mass_Action_Configuration__c
						  c. Update the Mass Action Configuration's dca_mass_action__Target_Apex_Script__c with the code below
						  d. note: when populating the apex script field, replace the following text values:
                             Replace CAMPAIGN_ID with the Id of the EABEvent.Invite_List__c campaign
                             Replace REPORT_COLUMN_NAME with the value from the 
                             MassActionConfiguration.dca_mass_action__Source_Report_Column_Name__c
     * 
     * @args            : List<Advisory_Event__c> newEABEvents, Map<Id, Advisory_Event__c> oldEABEvents
     * 
     * @return          : Void
     * 
     * @revision log    : V1.0 Created - CR-20201117-14698 11/20/2020
     * */
    public static void populateTargetApexScriptOnMassActionConfiguration(List<Advisory_Event__c> newEABEvents, Map<Id, Advisory_Event__c> oldEABEvents){
        
        //Set to hold Mass Action Configuration Id
        Set<Id> massActionConfigId = new Set<Id>();
        
        for(Advisory_Event__c eabEvent : newEABEvents){
            
            //On Insert
            if(eabEvent.Invite_List__c != null && eabEvent.Mass_Action_Configuration__c != null && (oldEABEvents == null 
               // On Update
               || (oldEABEvents.get(eabEvent.Id).Invite_List__c != eabEvent.Invite_List__c
               || oldEABEvents.get(eabEvent.Id).Mass_Action_Configuration__c != eabEvent.Mass_Action_Configuration__c)
              )){
                massActionConfigId.add(eabEvent.Mass_Action_Configuration__c);
            }       
        } 
        
        if(massActionConfigId.size() == 0)
            return;
        
        //Query on Mass Action Configuration
        Map<Id, dca_mass_action__Mass_Action_Configuration__c> mapOfMassActionConfiguration = new Map<Id, dca_mass_action__Mass_Action_Configuration__c>([Select Id, dca_mass_action__Target_Apex_Script__c, dca_mass_action__Source_Report_Column_Name__c From dca_mass_action__Mass_Action_Configuration__c Where Id IN : massActionConfigId]);
        
        if(mapOfMassActionConfiguration.size() > 0){
            
            //To update Mass Action Configuration records
            List<dca_mass_action__Mass_Action_Configuration__c> massActionConfigToBeUpdate = new List<dca_mass_action__Mass_Action_Configuration__c>();
            
            for(Advisory_Event__c eabEvent : newEABEvents){
                
                //Check for Contains
                if(mapOfMassActionConfiguration.containsKey(eabEvent.Mass_Action_Configuration__c)){
                	dca_mass_action__Mass_Action_Configuration__c massActionConfig = mapOfMassActionConfiguration.get(eabEvent.Mass_Action_Configuration__c);
                 
                    //Populate Target Apex Script On Mass Action Configuration record
                    massActionConfig.dca_mass_action__Target_Apex_Script__c = getTargetApexScript(eabEvent.Invite_List__c, 
                                                                  massActionConfig.dca_mass_action__Source_Report_Column_Name__c);
                    massActionConfigToBeUpdate.add(massActionConfig);
                }
            }
            
            //Check for size
            if(massActionConfigToBeUpdate.size() > 0){
            	update massActionConfigToBeUpdate;
            }
        }
    }
    
     /**
     * @description     : This method is used to get Target Apex Script.
     *                 
     * 
     * @args            : Id campaignId, String reportColumnName
     * 
     * @return          : String
     * 
     * @revision log    : V1.0 Created - CR-20201117-14698 11/20/2020
     * */
    public static String getTargetApexScript(Id campaignId, String reportColumnName){
        
        String targetApexScript = 
            'void execute(List <Map <String, Object>> sourceRecordsBatch) { \n'+ 
            'Id campaignId = \''+campaignId+'\''+';\n'+
            '//get the campaign details \n'+
            'Map<Id, CampaignMember> mapOfCampaignMembersByContactId = new Map<Id, CampaignMember>();\n'+
            'Campaign campaign;\n'+
            'for(Campaign cam : [SELECT Id, Primary_Program__c, (Select Id, ContactId FROM CampaignMembers) FROM Campaign WHERE Id =: campaignId]){\n'+
            'campaign = cam;\n'+
            'for (CampaignMember cm : cam.CampaignMembers)\n'+
            'mapOfCampaignMembersByContactId.put(cm.ContactId, cm);\n'+
            '}\n'+
            '//get all contact ids \n'+
            'Set <Id> contactIds = new Set <Id> ();\n'+
            'for (Map <String, Object> sourceRecord: sourceRecordsBatch) {\n'+
            'contactIds.add((Id) sourceRecord.get(\''+reportColumnName+'\''+'));\n'+
            '}\n'+
            '//get the contacts w/site profile \n'+
            'Map <Id, Contact> contactMap = new Map <Id, Contact> ([SELECT Id, EAB_com_Site_Profile__c FROM Contact WHERE Id IN: contactIds]);\n'+
            'Map <Id, CampaignMember> campaignMembers = new Map <Id, CampaignMember> ();\n'+
            'for (Map <String, Object> sourceRecord: sourceRecordsBatch) {\n'+
            '//get contact w/site profile details \n'+
            'Contact c = contactMap.get((Id) sourceRecord.get(\''+reportColumnName+'\''+'));\n'+
            '//continue if null \n'+
            'if (c == null) continue;\n'+
            'if(mapOfCampaignMembersByContactId.containsKey(c.Id) || campaignMembers.containsKey(c.Id)) continue;\n'+
            '//add campaign member \n'+
            'campaignMembers.put(c.Id, new CampaignMember(ContactId = c.Id, Site_Profile__c = c.EAB_com_Site_Profile__c, CampaignId = campaignId,'+
            'Primary_Program__c = campaign.Primary_Program__c));\n}\n'+
            'if (campaignMembers.size() > 0)\n' +
            'insert campaignMembers.values();\n}';
         return targetApexScript;
    }
    
    /**
     * @description     : This method is used to clone all registrations from parent event to child event.
     * 			  Logic:checks if the EAB Event's Parent_Event__c is populated on insert or updated with a Parent Event where Mirror_Registrations__c = "Inherit all from parent".
     * 			  i.  When the criteria above is met, get all Registrations associated with the Parent Event where status = Registered, Registration Requested, or Waitlist.
     *                    ii. Registrations returned from the query above should be cloned to the child EAB Event that was created/updated.
     *
     * @args            : List<Advisory_Event__c> eabEvents, Map<Id, Advisory_Event__c> oldEABEvents
     * 
     * @return          : Void
     * 
     * @revision log    : V1.0 Created by Saurabh KUmar - 02/16/2021 - CR-20210210-14902
     *                  : V1.1 - Modified By - Chirag Soni - 08/10/2021 - CR-20210511-15137 - Added a logic to Create Elevated meal registration records when EAB Event is Elevated Meal
     * */
    public static void cloneRegistrationsFromParentEventToChildEvent(List<Advisory_Event__c> eabEvents, Map<Id, Advisory_Event__c> oldEABEvents){
        
        if(isMethodAlreadyExecuted)
            return;
        isMethodAlreadyExecuted = true;
        
        //Map to hold parent event Id by child event Id
        Map<Id, Id> parentEventIdByChildEventId = new Map<Id, Id>();

        //Added BY - Chirag Soni - 10/28/2021 - CR-20210511-15137 - Set to hold EABEvent Id with elevated meal record type
        Set<Id> setOfEABEventWithElevatedMealRecordType = new Set<Id>();
        
        for(Advisory_Event__c eabEvent : eabEvents){
            
            if(eabEvent.Parent_Event__c != null && eabEvent.Mirror_Registrations__c == Constants.EAB_EVENT_INHERI_REGISTRATION_INHERIT_ALL_FROM_PARENT && (oldEABEvents == null || oldEABEvents.get(eabEvent.Id).Parent_Event__c != eabEvent.Parent_Event__c
                                                                                                                                                          || oldEABEvents.get(eabEvent.Id).Mirror_Registrations__c != eabEvent.Mirror_Registrations__c) )
                parentEventIdByChildEventId.put(eabEvent.Id, eabEvent.Parent_Event__c);

                //Added BY - Chirag Soni - 10/28/2021 - CR-20210511-15137 - Added a condition to Fill the set setOfEABEventWithElevatedMealRecordType - From here
                if(eabEvent.RecordTypeId == Constants.RECORD_TYPE_ID_EAB_EVENT_ELEVATED_MEAL){
                    setOfEABEventWithElevatedMealRecordType.add(eabEvent.Id);
                }
                //Added BY - Chirag Soni - 10/28/2021 - CR-20210511-15137 - Added a condition to Fill the set setOfEABEventWithElevatedMealRecordType - Till here
        }
        
        if(parentEventIdByChildEventId.size() == 0)
            return;
        
        //Set to hold registration status
        Set<String> setOfRegistrationStatus = new Set<String>{Constants.REGISTRATION_STATUS_REGISTERED, Constants.REGISTRATION_STATUS_REGISTRATION_REQUESTED, Constants.REGISTRATION_STATUS_WAITLIST};
        
        //Map to hold cloned registrations to insert by old registration and event Id
        Map<String, Registration__c> registrationByOldRegAndEventId = new Map<String, Registration__c>();
        
        //Query to gey all registrations from parent event
        for(Registration__c reg : [Select Id, RecordTypeId, Contact__c, Legacy_Registration_Id__c, Meeting__c, Status__c, Assistant_s_Email__c, Speaker_Note__c, Assistant_s_Name__c, Do_you_plan_to_travel_with_a_colleague__c, How_do_you_plan_to_travel_to_meeting__c, Should_Travel_Services_contact__c, Approval_Reason__c, Approval_Request_Date__c, Approval_Status__c, Calendar_Hold_Sent__c, MRS_Update__c, NASA_Member__c, Origin__c, Duration__c, Waitlist_Priority__c, Entity__c, Attended__c, Time_Joined__c, Time_Left__c, Zoom_Participant_URL__c, Zoom_Registrant_ID__c, Zoom_Reminder_Email_Sent__c, External_Event_Reg_ID__c, Bizzabo_Registration_ID__c, APS_Consultant__c, Accessibility_Needs__c, Adult_Learner_Strategic_Leader__c, Advancement_Strategic_Leader__c, Alternate_Contact_Email__c, Approval_Type__c, Assistant__c, Campaign_Member_Invite__c, Cancellation_Reason__c, City__c, Contact_Email__c, Contact_Institution__c, Contact_Notes__c, Contact_Title__c, Date_Cancelled__c, Declined_Calendar_Hold__c, EAB_Event_Public_Name__c, Duration_Minutes__c, EAB_Event__c, EAB_Role__c, Eligibility__c, Enrollment_Undergrad_Strategic_Leader__c, First_Name__c, Last_Name__c, Net_Promoter_Score__c, Overall_Evaluation__c, Parent_Event__c, Participation_Count__c, Partner_Status__c, Research_Strategic_Leader__c, Send_Communications_To__c, State__c, Strategic_Account_Segment__c, Student_Success_Strategic_Leader__c, Type_of_Staff__c, Walk_In__c, Assistant_Email__c, Membership_MtMs__c, Registered_By__c, Previous_Event_Attendance__c, Automated_Update__c, Parent_Registration__c, Duplicate_Matching__c, Registration_Request_Date__c, Institution_Registration_Count__c, EAB_Event_Primary_Program__c, Declined_Reason__c, Institution_Registrations_Remaining__c, Parent_EAB_Event__c, Inherit_Registrations__c, Duration_Attended__c, Is_On_Invite_List__c, Toggle_Validation_Bypass__c, Meeting_Utilization__c, Duration_Attended_Image__c From Registration__c Where EAB_Event__c != null
                                   AND EAB_Event__c IN : parentEventIdByChildEventId.values() AND Status__c IN : setOfRegistrationStatus]){
        	
            //Block to clone registration from parent event to child event
            for(Id eventId : parentEventIdByChildEventId.keySet()){
            
                if(reg.EAB_Event__c != parentEventIdByChildEventId.get(eventId))
                    continue;
                Registration__c clonedRegistration = reg.clone();
                clonedRegistration.Parent_Registration__c = reg.Id;
                clonedRegistration.EAB_Event__c = eventId;
                clonedRegistration.Duplicate_Matching__c = clonedRegistration.Contact__c + '-' + clonedRegistration.EAB_Event__c;
                clonedRegistration.Automated_Update__c = true;
               
                //Added BY - Chirag Soni - 10/28/2021 - CR-20210511-15137 - Create Elevated meal registration records when EAB Event is Elevated Meal - From Here
                if(setOfEABEventWithElevatedMealRecordType.Contains(eventId)){
                    clonedRegistration.RecordTypeId = Constants.REGISTRATION_RECORD_TYPE_ELEVATED_MEAL;
                    registrationByOldRegAndEventId.put(clonedRegistration.Duplicate_Matching__c, clonedRegistration);
                }
                else{
                    registrationByOldRegAndEventId.put(clonedRegistration.Duplicate_Matching__c, clonedRegistration);
                }
            }
                //Added BY - Chirag Soni - 10/28/2021 - CR-20210511-15137 - Create Elevated meal registration records when EAB Event is Elevated Meal - From Here
        }
        
        if(registrationByOldRegAndEventId.size() > 0){
            //RegistrationHelper.bypassRegistrationDLRS = true;
            insert registrationByOldRegAndEventId.values();
            //RegistrationHelper.bypassRegistrationDLRS = false;
        }
    }
    
    /**
     * @description     : This method is used to validate EAB Event record when Campaign Template is updating. Validation Rule to prevent changes to Campaign Template when there are one or more Registrations for the EAB Event.
     * 			  Logic: https://quip.com/mVgUANJsjJCU/Acquia-Automate-creation-of-segments-CR-20210128-14855
     *
     * @args            : List<Advisory_Event__c> eabEvents, Map<Id, Advisory_Event__c> oldEABEvents
     * 
     * @return          : Void
     * 
     * @revision log    : V1.0 Created by Saurabh Kumar - 03/18/2021 - CR-20210128-14855
     * */
    public static void validateCampaignTemplete(List<Advisory_Event__c> eabEvents, Map<Id, Advisory_Event__c> oldEABEvents){
        
        //Set to hold eab event Id
        Set<Id> eabEventIds = new Set<Id>();
        
        for(Advisory_Event__c eabEvent : eabEvents){
            
            if(eabEvent.Campaign_Template__c != oldEABEvents.get(eabEvent.Id).Campaign_Template__c)
                eabEventIds.add(eabEvent.Id);
        }
        
        if(eabEventIds.size() == 0)
            return;
        Map<Id, List<Registration__c>> mapOfRegistrationsByEABEvent = new Map<Id, List<Registration__c>>();
        for(Registration__c reg : [Select Id, EAB_Event__c From Registration__c Where EAB_Event__c IN : eabEventIds]){
            
            if(!mapOfRegistrationsByEABEvent.containsKey(reg.EAB_Event__c))
                mapOfRegistrationsByEABEvent.put(reg.EAB_Event__c, new List<Registration__c>());
            mapOfRegistrationsByEABEvent.get(reg.EAB_Event__c).add(reg);
        }
        
        for(Advisory_Event__c eabEvent : eabEvents){
            
            if(eabEvent.Campaign_Template__c != oldEABEvents.get(eabEvent.Id).Campaign_Template__c && mapOfRegistrationsByEABEvent.containsKey(eabEvent.Id) && mapOfRegistrationsByEABEvent.get(eabEvent.Id).size() > 0)
                eabEvent.addError(Label.ERROR_CAMPAIGN_TEMPLATE_CAN_NOT_EDIT_WHEN_REGISTRATION_THERE);
        }
    }
    
    /**
     * @description     : This method is used to generate Acquia Segements & Campaign.
     * 			  Logic: https://quip.com/mVgUANJsjJCU/Acquia-Automate-creation-of-segments-CR-20210128-14855
     * 			  1. When EAB Event is inserted & Campaign Template is feeded, make call out to Acquia system and generate Acquia Segment & Campaign Id and populate them in Acquia_Segment_Id__c & External_Campaign_Id__c respectively.
     * 			  2. When EAB_Event__c.Campaign_Template__c is getting change, make call out to deactivate existing Acquia Campaign Id and generate new Acquia Campaign Id.
     *
     * @args            : List<Advisory_Event__c> eabEvents, Map<Id, Advisory_Event__c> oldEABEvents
     * 
     * @return          : Void
     * 
     * @revision log    : V1.0 Created by Saurabh KUmar - 03/18/2021 - CR-20210128-14855
     * 			: V1.1 Modified - Lawrence Lam - 07/25/2021 - CR-20210606-15193 - Prevent callout if Campaign ID = null.
     * 			: V1.2 Modified - Chirag Soni - 02/09/2022 - CR-20220208-15772 - added scheduling of 
     * */ 
    public static void processAcquiaAutomation(List<Advisory_Event__c> eabEvents, Map<Id, Advisory_Event__c> oldEABEvents){
        
        Map<Id, Advisory_Event__c> mapOfEABEventsToGenerateNewAcquiaSegements = new  Map<Id, Advisory_Event__c>();
        Map<Id, Advisory_Event__c> mapOfEABEventsToRegenerateAcquiaCampaigns = new  Map<Id, Advisory_Event__c>();
        
        for(Advisory_Event__c eabEvent : eabEvents){
            
            if(!Constants.SET_OF_EAB_EVENT_OPEN_STATUS.contains(eabEvent.Status__c) || eabEventIdsWhichAlreadyProceedWithAcquia.contains(eabEvent.Id))
                continue;
            
            if(eabEvent.Campaign_Template__c != null){
                if(oldEABEvents == null || (eabEvent.Campaign_Template__c != oldEABEvents.get(eabEvent.Id).Campaign_Template__c && (eabEvent.Acquia_Segment_Id__c == null || eabEvent.External_Campaign_Id__c == null) )){
                    mapOfEABEventsToGenerateNewAcquiaSegements.put(eabEvent.Id, eabEvent);
                }
                else if(eabEvent.Campaign_Template__c != oldEABEvents.get(eabEvent.Id).Campaign_Template__c && eabEvent.Acquia_Segment_Id__c != null && eabEvent.External_Campaign_Id__c != null){
                    mapOfEABEventsToRegenerateAcquiaCampaigns.put(eabEvent.Id, eabEvent);
                }
                //CR-20210606-15193 - remove once cloning is fixed.
                else if(Batch_AcquiaSync.preventAcquiaCampaignCloning && eabEvent.External_Campaign_Id__c != null && eabEvent.External_Campaign_Id__c != 0
                        && eabEvent.External_Campaign_Id__c != oldEABEvents.get(eabEvent.Id).External_Campaign_Id__c){
                            mapOfEABEventsToGenerateNewAcquiaSegements.put(eabEvent.Id, eabEvent);
                        }
                
                if(mapOfEABEventsToGenerateNewAcquiaSegements.size() > 0 || mapOfEABEventsToRegenerateAcquiaCampaigns.size() > 0){
                     
                    eabEventIdsWhichAlreadyProceedWithAcquia.add(eabEvent.Id);
                    
                    //Added - CR-20220208-15772 - 02/09/2022 - Chirag Soni 
                    //create croj exp to schedule after 2 seconds
                    DateTime sysTime = dateTime.now().addSeconds(2);
                    String cronExpr = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
                    //String to hold Apex Job Name
                    String apexJobName = 'Schedule_AcquiaSync' + ' ' + sysTime+' '+math.random();
                    System.schedule(apexJobName, cronExpr, new Schedule_AcquiaSync(mapOfEABEventsToGenerateNewAcquiaSegements, mapOfEABEventsToRegenerateAcquiaCampaigns));
                    
                    //CR-20220208-15772 - 02/09/2022 - Chirag Soni - Commented  
                    //System.enqueueJob(new AcquiaHTTPCallout(mapOfEABEventsToGenerateNewAcquiaSegements, mapOfEABEventsToRegenerateAcquiaCampaigns));
                    
                }
                
                mapOfEABEventsToGenerateNewAcquiaSegements = new  Map<Id, Advisory_Event__c>();
                mapOfEABEventsToRegenerateAcquiaCampaigns = new  Map<Id, Advisory_Event__c>();
                
            }
        }
    }
    
    
     /**
     * @description     : This method is used to sync event information to acquia 
     *
     * @args            : List<Advisory_Event__c> eabEvents, Map<Id, Advisory_Event__c> oldEABEvents
     * 
     * @return          : Void
     * 
     * @revision log    : V1.0 Created by Chirag Soni - 02/11/2022 - CR-20210606-15193 
     *  
     ***/
    public static void syncEventInfoWithAcquia(List<Advisory_Event__c> eabEvents, Map<Id, Advisory_Event__c> oldEABEvents){
        
        //only run in update case 
        if(oldEABEvents != null)
        {
            //set to hold event ids 
            Set<Id> setEventIds = new Set<Id>();
            
            for(Advisory_Event__c eabEvent : eabEvents)
            {
                if(String.isNotBlank(eabEvent.Campaign_Template__c) && eabEvent.Acquia_Segment_Id__c!= null && (eabEvent.Begins__c != oldEABEvents.get(eabEvent.Id).Begins__c ||
                                                                                                                eabEvent.Ends__c != oldEABEvents.get(eabEvent.Id).Ends__c || 
                                                                                                                eabEvent.Public_Name__c != oldEABEvents.get(eabEvent.Id).Public_Name__c || 
                                                                                                                eabEvent.Location__c != oldEABEvents.get(eabEvent.Id).Location__c || 
                                                                                                                eabEvent.Zoom_Meeting_ID__c != oldEABEvents.get(eabEvent.Id).Zoom_Meeting_ID__c ||
                                                                                                                eabEvent.Event_Id__c != oldEABEvents.get(eabEvent.Id).Event_Id__c ||
                                                                                                                eabEvent.Event_Website__c != oldEABEvents.get(eabEvent.Id).Event_Website__c ||
                                                                                                                eabEvent.Evaluation_Link__c != oldEABEvents.get(eabEvent.Id).Evaluation_Link__c ))
                {
                    //add event Ids 
                    setEventIds.add(eabEvent.id);
                }
            }
            
            if(setEventIds.size()>0){
                
                //get all eligible registrations
                List<Registration__c> registrationToSync = [SELECT Id, Requires_Acquia_Sync__c, Acquia_Id__c,Zoom_Participant_URL__c , RecordTypeId FROM Registration__c WHERE EAB_Event__c IN :setEventIds AND RecordTypeId != :Constants.REGISTRATION_RECORD_TYPE_ID_INTERNAL_ATTENDEE AND Acquia_Id__c != null];     
                
                
                if(registrationToSync != null && registrationToSync.size()> 0)
                {
                    for(Registration__c reg : registrationToSync)
                    {
                        reg.Requires_Acquia_Sync__c = true;
                    }
                    
                    //update requires acquia sync to registrations 
                    Util.byPassAllTriggers = true;
                    update registrationToSync;
                    Util.byPassAllTriggers = false;
                    
                    //sync the updated information with acquia.
                    RegistrationHelper.syncContactAndRegistrationsWithAcquia(registrationToSync, null);
                }
            }
        }
    }

    /**
    * @description     : This method sets Acquia Segment Id and Acquia Campaign Id to null on new events
    *
    * @args            : List<Advisory_Event__c> eabEvents, Map<Id, Advisory_Event__c> oldEABEvents
    * 
    * @return          : Void
    * 
    * @revision log    : V1.0 Created - Lawrence Lam - 07/25/2021 - CR-20210606-15193
    * */
    
     public static void overrideAcquiaIdValues(List<Advisory_Event__c> eabEvents){
         for(Advisory_Event__c eabEvent : eabEvents){
             eabEvent.Acquia_Segment_Id__c = null;
             eabEvent.External_Campaign_Id__c = null;
         }
     }
}