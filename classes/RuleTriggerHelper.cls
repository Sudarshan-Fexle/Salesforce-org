/**
 *  Purpose         :   This class is to hold all the helper methods for Rule Trigger
 *
 *  Created By      :   Bhavi Sharma
 *
 *  Created Date    :   02/10/2015
 *
 *  Revision Logs   :   V_1.0 - Created
                        V1.2 - Modified - Bhavi Sharma - 03/05/15 - added method: validateRuleBeforeInsert
                        V1.3 - Modified - Saurabh Kumar - CR-20200821-14453 - 09/29/2020 - Added a method syncRegistrationPartnerStatus
                        V1.4 - Modified - Saurabh Kumar - CR-20200819-14450 - 11/03/2020 - Removed references of "Rules_Thresholds__c" and "Rules_Titles__c" fields
                        V1.5 - Modified - Saurabh Kumar - CR-20201105-14664 - 11/09/2020 - Removed references of Ultimate_Threshold_Parent__c, Ultimate_Title_Parent__c, Title_String__c
                        V1.6 - Modified - Saurabh Kumar - UAT Issues (MRS2.0) - 01/27/2021 - Added a method populateProgramNamesOnEABEvent
			V1.7 - Modified - Mahendra Swarnakar - 03/04/2021 - CR-20210301-14956 - Error when trying to edit any fields on Cappex Membership pages
			V1.8 - Modified - Saurabh Kumar - CR-20210302-14960 - 03/04/2021 - Added a method createEventRules & updated validatePrimaryRule() method.
 			V1.9 - Modified - Saurabh Kumar - CR-20201222-14763 - 03/24/2021 - Added a flag to bypass cloning of Event Rule in case of Add Program Rule via LWC(Custom Button on EAB Event)
			V2.0 - Modified - Chirag Soni - CR-20210302-14960 -  05/20/2021  : Modified method validatePrimaryRule() - UAT Issues (MRS2.0) - Fixed "program rule creation always defaulted the first program rule to be the primary program if none were selected".
            		V2.1 - Modified - Chirag Soni - CR-20210302-14960 - 05/21/2021 : Modified method updateMeeting() - When primary program is updated on parent EAB Event it should update on all child event where Rule Program is Use Parent's rule.
 **/ 
public without sharing class RuleTriggerHelper {
    
    //Flag to control the trigger execution
    public static Boolean EXECUTE_RULE_TRIGGER = true;
    public static Boolean EXECUTE_RULE_UNIQUENESS = true;
    public final static String RECORD_TYPE_RULE_DEVELOPER_NAME_PROGRAM = 'Program';
    public final static String RECORD_TYPE_RULE_DEVELOPER_NAME_TITLE = 'Title';
    
    //Added - Saurabh Kumar - CR-20201222-14763 - 03/24/2021
    public static Boolean EXECUTE_RULE_TRIGGER_METHOD = true;//V1.7 - Added - Saurabh Kumar - CR-20201222-14763 - 03/24/2021
    
    //Map to hold the Record Types
    public static Map<Id, RecordType> mapRuleRecordTypes {
        
        get {
            //Check if it's null, only then query
            if(RuleTriggerHelper.mapRuleRecordTypes == null) {
                
                mapRuleRecordTypes = new Map<Id, RecordType>([Select Id, Name, DeveloperName from RecordType where SObjectType = 'Rule__c' AND IsActive = true]);
            }
            return mapRuleRecordTypes;
        }
    } 
    
    //Map to hold the Record Type with rule Type
    public static Map<String, String> mapRecordTypeWithRuleType = new Map<String, String>{
                                                                                        'Program' => 'Program',
                                                                                        'Threshold' => 'Threshold Type',
                                                                                        'Title' => 'Job Function'
                                                                                        };
    
    //Map to Hold the appropriate unique API field for each record type
    public static Map<String, String> mapRecordTypeWithField = new Map<String, String>{
                                                                                        'Program' => 'Program__c',
                                                                                        'Threshold' => 'Threshold_Type__c',
                                                                                        'Title' => 'Job_Function__c'
                                                                                        };
    
    //V1.4 - Modified - Saurabh Kumar - CR-20200819-14450 - 11/03/2020 - Removed references of "Rules_Thresholds__c" and "Rules_Titles__c" fields                                                                                       
    //Map to Hold the appropriate unique Meeting API field for each record type
    public static Map<String, String> mapRecordTypeWithMeetingField = new Map<String, String>{
                                                                                        'Program' => 'Rules_Programs__c'
                                                                                        //'Threshold' => 'Rules_Thresholds__c',
                                                                                        //'Title' => 'Rules_Titles__c'
                                                                                        };
    
    /**
     *  @description    :   This method is to maintain the Rule's Unique validation. 
                            ?   Only one record may exist for a given Threshold Type, where Record Type = ?Threshold?
                            ?   Only one record may exist for a given Program, where Record Type = ?Program?
                            ?   Only one record may exist for a given Job Function, where Record Type = ?TItle?
                            
     * 
     *  @args           :   New Rules
     * 
     *  @return         :   void
     * 
     **/ 
    public static void validateRulesUniqueness(List<Rule__c> rules, Map<Id, Rule__c> mapOldRules) {
        
        //Check if method need to be executed
        if(RuleTriggerHelper.EXECUTE_RULE_UNIQUENESS == false)
            return;
        
        //Map to hold the RecordType and existing related values set
        Map<Id, Map<Id, Set<String>>> mapMeetingWithRecordTypeWithValues = new Map<Id, Map<Id, Set<String>>>();
        
        //Set to hold record types of new records
        Set<Id> selectedRecordTypes = new Set<Id>();
        
        //Set to hold the meeting Ids
        Set<Id> meetingIds = new Set<Id>();
        
        //Loop through the rules and create a set of Record Types
        for(Rule__c rule : rules) {
            
            //If record type is populated, add in set
            if(mapOldRules == null || 
                (rule.RecordTypeId != mapOldRules.get(rule.Id).RecordTypeId
                || rule.Job_Function__c != mapOldRules.get(rule.Id).Job_Function__c
                || rule.Program__c != mapOldRules.get(rule.Id).Program__c
                || rule.Threshold_Type__c != mapOldRules.get(rule.Id).Threshold_Type__c)) {
                
                if(rule.RecordTypeId != null)
                    selectedRecordTypes.add(rule.RecordTypeId);
                if(rule.Advisory_Event__c != null)
                    meetingIds.add(rule.Advisory_Event__c);
            }
        }
        
        //Chekc for the record type se size and continue
        if(selectedRecordTypes.size() == 0)
            return;
        
        //Query all the rules related to these selectedRecordTypes
        //and populate map with Record Type, with existing rule info
        for(Rule__c rule : [Select Id, Advisory_Event__c, RecordTypeId, RecordType.DeveloperName, Job_Function__c, Program__c, Threshold_Type__c from Rule__c 
                            where Advisory_Event__c IN: meetingIds AND RecordType.DeveloperName IN: mapRecordTypeWithField.keyset() 
                            AND Id Not IN: selectedRecordTypes 
                            AND (Job_Function__c != null OR Program__c != null OR Threshold_Type__c != null)]) {
            
            //Populate value in Map
            if(!mapMeetingWithRecordTypeWithValues.containsKey(rule.Advisory_Event__c))
                mapMeetingWithRecordTypeWithValues.put(rule.Advisory_Event__c, new Map<Id, Set<String>>{});
            
            //Create a new map
            Map<Id, Set<String>> mapRecordTypeWithValues = mapMeetingWithRecordTypeWithValues.get(rule.Advisory_Event__c);
            
            //Check if map exists
            if(!mapRecordTypeWithValues.containsKey(rule.RecordTypeId))
                mapRecordTypeWithValues.put(rule.RecordTypeId, new Set<String>{});
                                                                            
            //Add value in mapMeetingWithRecordTypeWithValues
            if(rule.get(mapRecordTypeWithField.get(rule.RecordType.DeveloperName)) != null) {
            
                mapRecordTypeWithValues.get(rule.RecordTypeId).add(String.valueOf(rule.get(mapRecordTypeWithField.get(rule.RecordType.DeveloperName))));
                mapMeetingWithRecordTypeWithValues.put(rule.Advisory_Event__c, mapRecordTypeWithValues);
            }
        }
        
        //Chekc if there is any rule already in the system, only then check for the uniqueness
        if(mapMeetingWithRecordTypeWithValues.size() == 0)
            return;
            
        //Loop through the new records again
        for(Rule__c rule : rules) {
            
            //Check if there is already a record for the same record type
            if(rule.RecordTypeId != null 
                && mapMeetingWithRecordTypeWithValues.containsKey(rule.Advisory_Event__c)
                && mapMeetingWithRecordTypeWithValues.get(rule.Advisory_Event__c).containsKey(rule.RecordTypeId)) {
                
                //Pull the values for Map and hold in a temporary set
                Set<String> existingValues = mapMeetingWithRecordTypeWithValues.get(rule.Advisory_Event__c).get(rule.RecordTypeId);
                
                //Get related unique field name for this recor type
                String uniqueFieldName = mapRecordTypeWithField.get(RuleTriggerHelper.mapRuleRecordTypes.get(rule.RecordTypeId).DeveloperName);
                
                //Get the field's value from new record and check if this already exists in mapMeetingWithRecordTypeWithValues map
                //If yes, then throw the error message
                if(String.isNotBlank(uniqueFieldName) && rule.get(uniqueFieldName) != null) {
                    
                    //get Value
                    String newValue = String.valueOf(rule.get(uniqueFieldName));
                    
                    //Check if this exists already
                    if(existingValues.contains(newValue)) {
                        
                        //Error Message
                        String errorMessage = Label.Rule_UniqueRuleError;
                        errorMessage = errorMessage.replace('#RuleType', RuleTriggerHelper.mapRuleRecordTypes.get(rule.RecordTypeId).DeveloperName);
                        errorMessage = errorMessage.replace('#RecordType', RuleTriggerHelper.mapRuleRecordTypes.get(rule.RecordTypeId).Name);
                        
                        //Throw Error
                        throw new CustomException(errorMessage);
                    } else {
                        
                        //Add in the existing map to make sure, current list doesnot have any duplicate
                        mapMeetingWithRecordTypeWithValues.get(rule.Advisory_Event__c).get(rule.RecordTypeId).add(newValue);
                    }
                }
            }
        }
        
        //Do not execute the method again
        RuleTriggerHelper.EXECUTE_RULE_UNIQUENESS = false;
    }
    
    /**
     *  @description    :   This method is to verify that only one program can be set as Primary.
                                ?   If the current record is marked as Primary, all other ?Program? records for the same meeting are un-marked.
                                ?   If only one record remains, it is marked as Primary
                                ?   If more than one record remains and none are marked as Primary, the record most recently modified is marked as Primary. 
                                ?   The Program field on the corresponding Event record is populated with whichever Rule record is set to ?Primary?
                                                                
     * 
     *  @args           :   List of new Rules
     * 
     *  @return         :   void
     * 
     *  @revision log	:   V1.1 - Modified - Saurabh Kumar - CR-20210302-14960 - 03/05/2021 : Fixed "Once Primary is checked, it cannot be un-checked" issue.
     *                  :   V1.2 - Modified - Chirag Soni - CR-20201222-14763  -  05/20/2021  : UAT Issues (MRS2.0) - Fixed "program rule creation always defaulted the first
     *                   														               program rule to be the primary program if none were selected".   
     **/
    public static void validatePrimaryRule(List<Rule__c> rules) {
        
        //Check for the Program rules and create a set of Meeting Ids to check with
        Set<Id> meetingIds = new Set<Id>();
        
        //flag to check for primary
        boolean isPrimaryFound = false;
        
        //Loop through the records and populate a set for Program meetings
        for(Rule__c rule : rules) {
            
            if(rule.Primary__c){
                isPrimaryFound = true;
            }
            
            //Check for the Program rules and populate the meeting Ids set
            if(rule.Advisory_Event__c != null 
                && rule.RecordTypeId != null 
                && RuleTriggerHelper.mapRuleRecordTypes.get(rule.RecordTypeId).DeveloperName == RuleTriggerHelper.RECORD_TYPE_RULE_DEVELOPER_NAME_PROGRAM) {
                
                //Populate the meeting IDs 
                meetingIds.add(rule.Advisory_Event__c);
            }
        }
        
        //Fetch the related Rules with these meetings
        if(meetingIds.size() == 0)
            return;
        
        //Map to hold the metting Id as key, and related list of primary rules as values
        Map<Id, List<Rule__c>> mapMeetingWithRelatedPrimaryRules = new Map<Id, List<Rule__c>>();
        
        //Query the related rules of type Program
        for(Rule__c rule : [Select Id, Advisory_Event__c, Primary__c from Rule__c where Advisory_Event__c IN: meetingIds 
                                                            AND RecordType.DeveloperName =: RuleTriggerHelper.RECORD_TYPE_RULE_DEVELOPER_NAME_PROGRAM
                                                            AND Primary__c = true
                                                            AND ID NOT IN: rules]) {
            
            //Add in Map
            if(!mapMeetingWithRelatedPrimaryRules.containsKey(rule.Advisory_Event__c))
                mapMeetingWithRelatedPrimaryRules.put(rule.Advisory_Event__c, new List<Rule__c>());
            
            //Add rule record
            mapMeetingWithRelatedPrimaryRules.get(rule.Advisory_Event__c).add(rule);
        }
        
        //List to hold the rules to update from Primary to non Primary
        List<Rule__c> nonPrimaryRulesToUpdate = new List<Rule__c>();
        
        //Loop through the new records again and check if there is any record need to be set as non primary
        for(Rule__c rule : rules) {
            
            //Check for the Program rules and populate the meeting Ids set
            if(rule.Advisory_Event__c != null 
                && rule.RecordTypeId != null 
                && RuleTriggerHelper.mapRuleRecordTypes.get(rule.RecordTypeId).DeveloperName == RuleTriggerHelper.RECORD_TYPE_RULE_DEVELOPER_NAME_PROGRAM) {
                
                //Check if this rule is set as primary and there is other record which need to be set as non primary
                if(mapMeetingWithRelatedPrimaryRules.containsKey(rule.Advisory_Event__c)) {
                    
                    //Chekc if current rule is cam as primary, only the mark the other as not primary
                    if(rule.Primary__c == true) {
                        
                        //Existing primary rules
                        List<Rule__c> existingRules = mapMeetingWithRelatedPrimaryRules.get(rule.Advisory_Event__c);
                        
                        //Loop through these records and set them as primary
                        for(Rule__c eRule : existingRules) {
                            
                            eRule.Primary__c = false;
                        }
                        //Add in list to update
                        nonPrimaryRulesToUpdate.addAll(existingRules);
                    }
                } 
                //V1.2 - Modified - Chirag Soni - CR-20210302-14960 -  UAT Issues (MRS2.0)
                else if(rule.Program__c == rules[rules.size()-1].Program__c && !isPrimaryFound){
                    
                 //V1.1 - Commented - Saurabh Kumar - CR-20210302-14960 - 03/05/2021 : Fixed "Once Primary is checked, it cannot be un-checked" issue.
                 //Set this rule as Primary
                 rule.Primary__c = true;
                }
            }
        }
        
        //Update the from primary to non primary
        if(nonPrimaryRulesToUpdate.size() > 0) {
            
            //no need to execute the triggers
            RuleTriggerHelper.EXECUTE_RULE_TRIGGER = false;
            
            //Update 
            update nonPrimaryRulesToUpdate;
            
            //Activate trigger again, so the other methods and be executed
            RuleTriggerHelper.EXECUTE_RULE_TRIGGER = true;
        }
    }
    
    /**
     *  @description    :   This method is to check for the Primary rules and update the Meeting record accordingly
     *
     *  @args           :   List of new Rules
     *
     *  @return         :   void
     *  
     *  @revision log	:  V1.0 - Modified by - Chirag Soni - CR-20210302-14960 - 05/21/2021 
     *                  :  When primary program is updated on parent EAB Event it should update on all child event where Rule Program is Use Parent's rule.
     *
     */
    public static void updateMeeting(List<Rule__c> rules, Map<Id, Rule__c> mapOldRules) {
        
        //Create a list of Meeting records to be updated
        Map<Id, Advisory_Event__c> mapMeetings = new Map<Id, Advisory_Event__c>();
        
        //Set to hold the Title Meeting Ids
        Set<Id> titleMeetingIds = new Set<Id>();
        
        //
        
        //Loop through the rules and populate the set of meetings to be updated
        for(Rule__c rule : rules != null?rules:mapOldRules.values()) {
            
            //Check for the Program rules and populate the meeting Ids set
            if(rule.Advisory_Event__c != null 
                && rule.RecordTypeId != null) {
                
                if(RuleTriggerHelper.mapRuleRecordTypes.get(rule.RecordTypeId).DeveloperName == RuleTriggerHelper.RECORD_TYPE_RULE_DEVELOPER_NAME_PROGRAM
                    && rule.Primary__c == true
                    && (mapOldRules == null || rule.Program__c != mapOldRules.get(rule.Id).Program__c || rule.Primary__c != mapOldRules.get(rule.Id).Primary__c)) {
                
                    //Populate the meeting IDs 
                    mapMeetings.put(rule.Advisory_Event__c, new Advisory_Event__c(Id = rule.Advisory_Event__c, Primary_Program__c = rule.Program__c));
                } else if(RuleTriggerHelper.mapRuleRecordTypes.get(rule.RecordTypeId).DeveloperName == RuleTriggerHelper.RECORD_TYPE_RULE_DEVELOPER_NAME_TITLE 
                    && (mapOldRules == null && String.IsNotBlank(rule.Job_Function__c)
                        || (rules != null && mapOldRules != null && rule.Job_Function__c != mapOldRules.get(rule.Id).Job_Function__c)
                        || (rules == null&& String.IsNotBlank(rule.Job_Function__c)))) {
                        
                    //Add in set
                    titleMeetingIds.add(rule.Advisory_Event__c);
                }
            }
        }
        
        //TitleString Use Case
        AggregateResult[] results = [SELECT Advisory_Event__c meetingId, Job_Function__c jobFunction FROM Rule__C where Advisory_Event__c != null AND Job_Function__c != null AND Advisory_Event__c IN: titleMeetingIds AND RecordType.DeveloperName =: RECORD_TYPE_RULE_DEVELOPER_NAME_TITLE GROUP BY Advisory_Event__c, Job_Function__c];
        
        //Check if there are records to process
        if(results.size() > 0) {
            
            //Loop through the agreegate results
            for(AggregateResult result : results) {
                
                //Get Meeting Id
                Id meetingId = Id.valueOf(String.valueOf(result.get('meetingId')));
                
                //V1.5 - Modified - Saurabh Kumar - CR-20201105-14664 - 11/09/2020 - Removed references of Ultimate_Threshold_Parent__c, Ultimate_Title_Parent__c, Title_String__c: Start
                //Check if value already existis in Map, if not then add
                /*if(!mapMeetings.containsKey(meetingId))
                    mapMeetings.put(meetingId, new Advisory_Event__c(Id = meetingId, Title_String__c = ''));
                
                //Get the Job Function and Add in the Meeting Title_String__c
                if(String.isBlank(mapMeetings.get(meetingId).Title_String__c))
                    mapMeetings.get(meetingId).Title_String__c = String.valueOf(result.get('jobFunction'));
                else
                    mapMeetings.get(meetingId).Title_String__c += '///' + String.valueOf(result.get('jobFunction'));*/
                //V1.5 - Modified - Saurabh Kumar - CR-20201105-14664 - 11/09/2020 - Removed references of Ultimate_Threshold_Parent__c, Ultimate_Title_Parent__c, Title_String__c: End
                //Remove the records which have been processed from set
                if(titleMeetingIds.contains(meetingId))
                    titleMeetingIds.remove(meetingId);
            }
        }
        
        //V1.5 - Modified - Saurabh Kumar - CR-20201105-14664 - 11/09/2020 - Removed references of Ultimate_Threshold_Parent__c, Ultimate_Title_Parent__c, Title_String__c
        //Set the remaining Meeting records as null
        //for(Id meetingId : titleMeetingIds)
            //mapMeetings.put(meetingId, new Advisory_Event__c(Id = meetingId, Title_String__c = null));
        
        //Check if meetings are to update
        if(mapMeetings.size() > 0)
        {
            //Added - Chirag Soni - CR-20210302-14960 - 05/21/2021 : UAT Issues (MRS2.0) - When primary program is updated on parent EAB Event it should update on all child event also where Rule Program is Use Parent's rule.
            // adding all child event in same map 
            for(Advisory_Event__c eabEvent : [Select Id, Parent_Event__c, Primary_Program__c From Advisory_Event__c Where Rules_Programs__c =: Constants.EAB_EVENT_RULE_PROGRAMS_USE_PARENT_RULES AND Parent_Event__c IN : mapMeetings.keyset()]){
                
                mapMeetings.put(eabEvent.Id, new Advisory_Event__c(Id = eabEvent.Id, Primary_Program__c = mapMeetings.get(eabEvent.Parent_Event__c).Primary_Program__c));
            }
            update mapMeetings.values();  
        }
    } 
    
    /**
     *  @description    :   If set to ?Establish independent rules?:
                                o   Allow the creation and deletion of rules for that rule type at the current ABC Event?s level
                            If set to ?Use parent?s rules?:
                                o   Do not allow any insertion of rules for that rule type
                                o   Delete any existing rules for that type from the current ABC Event.
     * 
     *  @args           :   list of new records 
     * 
     *  @return         :   void
     * 
     **/
    public static void validateRuleBeforeInsert(List<Rule__c> rules) {
        
        //Create a set of Meetings
        Set<Id> meetingIds = new Set<Id>();
        
        //Loop through the records
        for(Rule__c rule : rules) {
            
            //Check for the rule's record type and that specic rule picklist value on related meeting
            if(rule.Advisory_Event__c != null && rule.RecordTypeId != null)
                meetingIds.add(rule.Advisory_Event__c);
        }
        
        //V1.4 - Modified - Saurabh Kumar - CR-20200819-14450 - 11/03/2020 - Removed references of "Rules_Thresholds__c" and "Rules_Titles__c" fields
        //Fetch related Meetings From DB
        Map<Id, Advisory_Event__c> mapMeetings = new Map<Id, Advisory_Event__c>([Select Id, Rules_Programs__c from Advisory_Event__c where Id IN: meetingIds]);
    
        //Loop through the records again, and check  if rules are allowed to create
        for(Rule__c rule : rules) {
            
            //Check for the rule's record type and that specic rule picklist value on related meeting
            if(rule.Advisory_Event__c != null && rule.RecordTypeId != null) {
                
                //Get the Record type
                String rTypeDeveloperName = mapRuleRecordTypes.get(rule.RecordTypeId).DeveloperName;
                
                //Get the related field name
                String fieldName = RuleTriggerHelper.mapRecordTypeWithMeetingField.get(rTypeDeveloperName);
                
                //Related meeting record
                Advisory_Event__c relatedMeeting = mapMeetings.get(rule.Advisory_Event__c);
                
                System.debug(':::::'+ fieldName);
                System.debug(':::::'+ String.valueOf(relatedMeeting.get(fieldName)));
                System.debug(':::::'+ AdvisoryEventTriggerHelper.USE_PARENT_S_RULES);
                System.debug(':::::'+ String.valueOf(relatedMeeting.get(fieldName)) == AdvisoryEventTriggerHelper.USE_PARENT_S_RULES);
                
             
                //Check if this filed's value is "USE_PARENT_S_RULES", then dont allow creating a new rule
                if(relatedMeeting.get(fieldName) != null 
                    && String.valueOf(relatedMeeting.get(fieldName)) == AdvisoryEventTriggerHelper.USE_PARENT_S_RULES) {
                    
                    //Throw exception and break the code
                    throw new CustomException(Label.ERROR_BLOCKED_INSERT_USE_PARENT_S_RULE);            
                }
            }
        }
    }
    
    /**
     *  @descrition     :   When a Rule is Created, find any Advisory Events below the current Advisory Event in the hierarchy 
                                where the ?Rules ?? field = ?Use Parent?s Rules? 
                                and create Event Rule records linking the Rule to the child Advisory Event records.
     * 
     *  @args           :   List of new Rules
     * 
     *  @return         :   void
     * 
     **/
    public static void manageCloneRulesFromParent(List<Rule__c> rules) {
        
        //Create a list of Event Rules to be created
        List<Event_Rule__c> eRules = new List<Event_Rule__c>();
        
        //Create list to hold the meetings with Related rules
        Map<String, List<Rule__c>> meetingsMap = new Map<String, List<Rule__c>>();
        
        System.debug('meetingsMap:::::'+ meetingsMap);
        
        //Loop through the rules and create a a set of ids
        for(Rule__c rule : rules) {
            
            //Check for the event
            if(rule.Advisory_Event__c != null) {
                
                //Create a event rule
                eRules.add(new Event_Rule__c(Advisory_Event__c = rule.Advisory_Event__c, Rule__c = rule.Id));
                String eventId = rule.Advisory_Event__c;
                
                //We are using a workflow rule which is always putting 15 characters Id in a Text field, So we need first 15 carchartes only for comparison
                eventId = eventId.Left(15); 
                if(!meetingsMap.containsKey(eventId))
                    meetingsMap.put(eventId, new List<Rule__c>());
                meetingsMap.get(eventId).add(rule);
            }
        }
        
        //If meetingsMap.keySet()
        if(meetingsMap.size() == 0)
            return;
        
        System.debug('meetingsMap:::::'+ meetingsMap);
        
        //V1.4 - Modified - Saurabh Kumar - CR-20200819-14450 - 11/03/2020 - Removed references of "Rules_Thresholds__c" and "Rules_Titles__c" fields
        //V1.5 - Modified - Saurabh Kumar - CR-20201105-14664 - 11/09/2020 - Removed references of Ultimate_Threshold_Parent__c, Ultimate_Title_Parent__c
        //Fetch Meeting having current meetings as parent
        for(Advisory_Event__c aM : [Select Id, Ultimate_Program_Parent__c, Rules_Programs__c from Advisory_Event__c 
                                            where (NOT (Id IN: meetingsMap.keySet()))
                                                    AND ( Ultimate_Program_Parent__c IN: meetingsMap.keySet() 
                                                        //OR Ultimate_Threshold_Parent__c IN: meetingsMap.keySet() 
                                                        //OR Ultimate_Title_Parent__c IN: meetingsMap.keySet()
                                                        )
                                   ]) {
            
            //Check for the Rules tyle
            if((meetingsMap.containsKey(aM.Ultimate_Program_Parent__c) && aM.Rules_Programs__c == AdvisoryEventTriggerHelper.USE_PARENT_S_RULES)
                //|| (meetingsMap.containsKey(aM.Ultimate_Threshold_Parent__c) /*&& aM.Rules_Thresholds__c == AdvisoryEventTriggerHelper.USE_PARENT_S_RULES*/)
                //|| (meetingsMap.containsKey(aM.Ultimate_Title_Parent__c) /*&& aM.Rules_Titles__c == AdvisoryEventTriggerHelper.USE_PARENT_S_RULES*/)
              ) {
                
                System.debug('meetingsMap:::::'+ meetingsMap);
                //Get the related meetings and clone
                for(String meetingId : meetingsMap.keySet()) {
                    for(Rule__c rule : meetingsMap.get(meetingId)) {
                        
                        //Check if teh rule record type and Rule -* fields are applicable
                        String recordTypeDeveloperName = mapRuleRecordTypes.get(rule.RecordTypeId).DeveloperName;
                        String fieldName = mapRecordTypeWithMeetingField.get(recordTypeDeveloperName);
                        if(mapRecordTypeWithMeetingField.containsKey(recordTypeDeveloperName)
                            && aM.get(fieldName) !=null 
                            && String.valueOf(aM.get(fieldName)) == AdvisoryEventTriggerHelper.USE_PARENT_S_RULES) {
                        
                            eRules.add(new Event_Rule__c(Advisory_Event__c = aM.Id, Rule__c = rule.Id));
                        }
                    }       
                }
            }
        }
        
        //Check and insert
        if(eRules.size() > 0)
            insert eRules;
    }
    
    /**
     * @description     : This method is used to sync Partner Status field on Registration in case of insert, delete & update
     * 
     * @args            : List<Rule__c> newRules, Map<Id, Rule__c> oldRules
     * 
     * @return          : void
     * 
     * @revision log    : V1.0 Created - CR-20200821-14453 09/29/2020
     * */
    public static void syncRegistrationPartnerStatus(List<Rule__c> newRules, Map<Id, Rule__c> oldRules){
        
        //Set to hold EAB Event Ids which should be processed
        Set<Id> eabEventIds = new Set<Id>();
        
        //Set to hold Rule Id which should be skipped to match the program
        Set<Id> ruleIdToSkipped = new Set<Id>();
        
        //Map to hold Registration which should be synced
        Map<Id, Registration__c> registrations = new Map<Id, Registration__c>();
        
        for(Rule__c rule : newRules != null ? newRules : oldRules.values()){
            
            if(oldRules == null && rule.Program__c != null){
                eabEventIds.add(rule.Advisory_Event__c);
                
            }else if(newRules == null && rule.Program__c != null){
                ruleIdToSkipped.add(rule.Id);
                eabEventIds.add(rule.Advisory_Event__c);
                
            }else if(rule.Program__c != null && rule.Program__c != oldRules.get(rule.Id).Program__c){
                eabEventIds.add(rule.Advisory_Event__c);
            }
        }
        
        if(eabEventIds.size() == 0)
            return;
       /*registrations = new Map<Id, Registration__c>([Select Id, EAB_Event__c From Registration__c Where EAB_Event__c != null AND Contact__c != null AND
                                            EAB_Event__c IN : eabEventIds AND Contact__r.AccountId != null]);
        if(registrations.size() > 0)
            RegistrationHelper.updatePartnerStatus(registrations.keySet(), ruleIdToSkipped);*/ 
        
        //Modified By - Mahendra Swarnakar - 03/04/2021 - CR-20210301-14956 - Error when trying to edit any fields on Cappex Membership pages
                        
        registrations = new Map<Id, Registration__c>([Select Id, Name, Origin__c, Parent_Registration__c, Automated_Update__c, EAB_Event__c, EAB_Event__r.Status__c 
                                                      From Registration__c Where EAB_Event__c != null AND Contact__c != null 
                                                      AND Contact__r.AccountId != null AND EAB_Event__c IN : eabEventIds 
                                                      AND (EAB_Event__r.Status__c =: Constants.EAB_EVENT_STATUS_OPEN_REGISTRATION 
                                                           OR EAB_Event__r.Status__c =:Constants.EAB_EVENT_STATUS_OPEN_WAITLIST_ONLY)
                                                     ]);
        
        Boolean isEABEventManager = FeatureManagement.checkPermission('EAB_Event');
        
        if( isEABEventManager && registrations.size() > 0)
            RegistrationHelper.updatePartnerStatus(registrations.keySet(), ruleIdToSkipped);
        //Ends Here - CR-20210301-14956
    }
    
    /**
     * @description     : This method is used to populate associated program names on EAB Event object in case of insert, delete & update
     * 
     * @args            : List<Rule__c> newRules, Map<Id, Rule__c> oldRules
     * 
     * @return          : void
     * 
     * @revision log    : V1.0 Created Saurabh Kumar -  UAT Issues (MRS2.0) - 01/27/2021
     * */
    public static void populateProgramNamesOnEABEvent(List<Rule__c> newRules, Map<Id, Rule__c> oldRules){
        
        //Set to hold EAB Event Id
        Set<Id> eabEventIds = new Set<Id>();
        
        for(Rule__c rule : newRules != null ? newRules : oldRules.values()){
            
            //Insert case
            if( (rule.Program__c != null && oldRules == null)
                || (oldRules != null && rule.Program__c != oldRules.get(rule.Id).Program__c)
                || (newRules == null && rule.Program__c != null)
              ){
                eabEventIds.add(rule.Advisory_Event__c);
            }                                                                
        }
        if(eabEventIds.size() == 0)
            return;
        //Map to hold EAB Events to populate Associated_Programs__c
        Map<Id, Advisory_Event__c> mapOfEABEventsToUpdate = new Map<Id, Advisory_Event__c>();
        
        for(Advisory_Event__c eabEvent : [Select Id, Associated_Programs__c, (Select Id, Program__r.Name From Rules__r Where Program__c != null) From Advisory_Event__c Where Id IN : eabEventIds]){
        	
            if(!mapOfEABEventsToUpdate.containsKey(eabEvent.Id)){
             	
                mapOfEABEventsToUpdate.put(eabEvent.Id, new Advisory_Event__c(Id = eabEvent.Id, Associated_Programs__c = ''));
            }
            
            for(Rule__c rule : eabEvent.Rules__r){
                
                mapOfEABEventsToUpdate.get(eabEvent.Id).Associated_Programs__c += rule.Program__r.Name+'\n';
            }
             
        }
        if(mapOfEABEventsToUpdate.size() > 0){
            Util.ByPassAllTriggers = true;
            update mapOfEABEventsToUpdate.values();
            Util.ByPassAllTriggers = false;
        }
    }
    
    /**
     * @description     : This method is used to create Event Rule for all child EAB Events.
     * 			  Logic: When an Rule is Inserted, create a corresponding Event Rule for all Child EAB Events where Rules_Programs__c == 'Use parent's rules'.
     * 
     * @args            : List<Rule__c> newRules
     * 
     * @return          : void
     * 
     * @revision log    : V1.0 Created Saurabh Kumar -  CR-20210302-14960 - 03/04/2021
     * */
    public static void createEventRules(List<Rule__c> newRules){
        
        //Set to hold EAB Event Id
        Set<Id> eabEventIds = new Set<Id>();
        
        for(Rule__c rule : newRules){
            
            if(rule.Advisory_Event__c != null)
                eabEventIds.add(rule.Advisory_Event__c);
        }
        
        if(eabEventIds.size() == 0)
            return;
        
        //Map to hold Event Rule to create
        Map<String, Event_Rule__c> mapOfEventRuleByRuleAndEABEvent = new Map<String, Event_Rule__c>();
        
        //Block to query on all child events and process to create Event Rule on all child events
        for(Advisory_Event__c eabEvent : [Select Id, Parent_Event__c, Parent_Event__r.Primary_Program__c From Advisory_Event__c Where Rules_Programs__c =: Constants.EAB_EVENT_RULE_PROGRAMS_USE_PARENT_RULES AND Parent_Event__c IN : eabEventIds]){
            
            for(Rule__c rule : newRules){
                
                if(rule.Advisory_Event__c != null && rule.Advisory_Event__c == eabEvent.Parent_Event__c)
                    mapOfEventRuleByRuleAndEABEvent.put(rule.Id+'-'+eabEvent.Id, new Event_Rule__c(Rule__c = rule.Id, Advisory_Event__c = eabEvent.Id));
            }
        }
        if(mapOfEventRuleByRuleAndEABEvent.size() > 0)
            insert mapOfEventRuleByRuleAndEABEvent.values();
    }
}