/**
 *	Purpose			:	Controller class for meeting deatil page. 
 						This class controls the visibility of related list 
 						and custmom buttons on related list. 	
 *
 *	Created By		:	Bhavi Sharma	
 *	
 *	Created Date		:	02/03/2015
 *
 *	Revision Logs		:	V_1.0 - Created
 					V_1.1 Modified - Bhavi Sharma - 03/13/2015 -  New Event Rule onbject has been introduced
					V_1.2 Modified - Saurabh Kumar - 11/03/2020 - Removed the references of "Rules_Thresholds__c" and "Rules_Titles__c" fields
 
 *
 **/ 
public with sharing class MeetingDetailController {
	
	//Properties
    public List<String> relatedLists {get; set;} 
    public List<Event_Rule__c> rulesList{get; set;}
	Map<String, Set<String>> mapRecordTypeWithRelatedList = new Map<String, Set<String>> {
																							'Meeting' => new Set<String> {'EventRules', 'ParentMeetings', 'OpenActivities', 'NotesAndAttachments', 'ActivityHistories', 'Histories'},
																							'Series' => new Set<String> {'Registrations', 'Venues', 'TeamMembers', 'EventRules', 'EventBudgets', 'RegistrationMemberships', 'OpenActivities', 'NotesAndAttachments', 'ActivityHistories', 'Histories' },
																							'Session' => new Set<String> {'Registrations', 'Venues', 'TeamMembers', 'EventRules', 'EventBudgets', 'RegistrationMemberships', 'OpenActivities', 'NotesAndAttachments', 'ActivityHistories', 'Histories' }
																						};
	public Map<String, Id> mapRuleRecordTypes {get; private set;}
	
	//Buttons display properties
	public Boolean displayNewTitleButton {get; private set;}
	public Boolean displayNewProgramButton {get; private set;}
	public Boolean displayNewThresholdButton {get; private set;}
	
    //Constants
    final static String USE_PARENT_S_RULES = 'Use parent';
    final static String ESTABLISH_INDEPENDENT_RULES = 'Establish independent rules';
    
	//Constructor
	public MeetingDetailController(ApexPages.StandardController controller) {
		
		//Get Record
		Advisory_Event__c meeting = (Advisory_Event__c)controller.getRecord();
		
        //return if meeting is null
        if (controller.getId() == null) return;
        
		//Set defaults
		displayNewTitleButton = false;
		displayNewProgramButton = false;
		displayNewThresholdButton = false;
        relatedLists = new List<String>{'Registrations', 'Venues', 'TeamMembers', 'EventRules', 'Rules', 'EventBudgets', 'RegistrationMemberships', 'ParentMeetings', 'OpenActivities', 'NotesAndAttachments', 'ActivityHistories', 'Histories' };
		
        	//V_1.2 Modified - Saurabh Kumar - 11/03/2020 - Removed the references of "Rules_Thresholds__c" and "Rules_Titles__c" fields
		//Get Meeting info
		meeting = [Select Id, RecordTypeId, RecordType.DeveloperName, Rules_Programs__c  from Advisory_Event__c where Id =: meeting.Id];
		
	    //Rule Query
        String RULE_Query = 'Select Id, Name';
        
        //Get fields from field
        for(Schema.FieldSetMember f : SObjectType.Event_Rule__c.FieldSets.RulesRelatedList.getFields()) {
            RULE_Query += ',' + f.getFieldPath();
        }
        
        RULE_Query += ' from Event_Rule__c where Advisory_Event__c = \'' + meeting.Id + '\'';
        rulesList = Database.query(RULE_Query);
        
        //Record Type Map
        mapRuleRecordTypes = new Map<String, Id>();
        for(RecordType rT : [Select Id, DeveloperName from RecordType where SObjectType = 'Rule__c' and IsActive = true]) 
        	mapRuleRecordTypes.put(rt.DeveloperName, rT.Id);
        
        //V_1.2 Modified - Saurabh Kumar - 11/03/2020 - Removed the references of "Rules_Thresholds__c" and "Rules_Titles__c" fields
	//Set buttons display
        //if(meeting.Rules_Titles__c == null || (String.IsNotBlank(meeting.Rules_Titles__c) && !meeting.Rules_Titles__c.startsWithIgnoreCase(MeetingDetailController.USE_PARENT_S_RULES)))
    		//displayNewTitleButton = true;
		//if(meeting.Rules_Thresholds__c == null || (String.IsNotBlank(meeting.Rules_Thresholds__c) && !meeting.Rules_Thresholds__c.startsWithIgnoreCase(MeetingDetailController.USE_PARENT_S_RULES)))
    		//displayNewThresholdButton = true;
        if(meeting.Rules_Programs__c == null || (String.IsNotBlank(meeting.Rules_Programs__c) && !meeting.Rules_Programs__c.startsWithIgnoreCase(MeetingDetailController.USE_PARENT_S_RULES)))
        	displayNewProgramButton = true;
	}
    
    /**
     * @description: map of RecordTypeName -> Short Name.  Used to default the short name field on Advisory Event when creating a new record.
     **/
    private map<string, string> recordTypeToDefaultShortName {
        get {
            if (recordTypeToDefaultShortName == null) {
                recordTypeToDefaultShortName = new map<string, string> { 'Series' => 'Enter Acronym Here', 'Event' => 'Enter Location Here', 'Session' => 'Enter Description Here' };
            }
            return recordTypeToDefaultShortName;
        }
        set;
    }
    
    private string redirectURL(string retURL) {
        //get the object id
        string prefix = Advisory_Event__c.sObjectType.getDescribe().getKeyPrefix();
        string rtid = ApexPages.currentPage().getParameters().get('RecordType');
        string rtName;
        if (rtid != null) rtName = [SELECT Name FROM RecordType WHERE Id = :rtid].Name;
        string urlString = '/apex/RedirectWithVariables?redirect=object--Advisory_Event__c'
            			+ '!!Name--Will Auto-Populate'
            			+ '!!Rules_Programs__c--' + ESTABLISH_INDEPENDENT_RULES + '!!Rules_Thresholds__c--' + ESTABLISH_INDEPENDENT_RULES + '!!Rules_Titles__c--' + ESTABLISH_INDEPENDENT_RULES;
        if (!string.isBlank(retURL)) urlString += '!!returnURL--/' + retURL;
        if (!string.isBlank(rtid)) urlString += '!!RecordTypeId--' + rtid;
        if (recordTypeToDefaultShortName.containsKey(rtName)) urlString += '!!Short_Name__c--' + recordTypeToDefaultShortName.get(rtName);
        return urlString;
    }
    
    //if this is a completely new Meeting, redirect with record type defaulted and fields auto-populated
    public pageReference redirect() {
        string id = ApexPages.currentPage().getParameters().get('id');
        string retURL = ApexPages.currentPage().getParameters().get('retURL');
        PageReference pg;
        if (string.isBlank(id)) {
            pg = new PageReference(redirectURL(retURL));
        }
        
        return pg;
    }
}