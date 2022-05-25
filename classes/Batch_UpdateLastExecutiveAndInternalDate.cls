/**
 *	Purpose		:	Batch is used to used to populate Project object's given below:-
 * 						1. Last Executive Update
 * 						2. Last Internal Check-in
 * 
 *	Created By	:	Dipesh Gupta
 *
 *	Created Date	:	01/22/2020	
 *
 *	Rivision Log	:	V_1.0 - Created
 *                      :       V_1.1 - Modified By - Neha Sharma - 10/21/2020 - CR-20200602-14130 - Comment out the criteria of Event Type('In Person Visit','Phone Appointment) from query as well as condition
 *
 **/
global class Batch_UpdateLastExecutiveAndInternalDate implements database.Batchable<sobject>, Database.Stateful {
    
    //Debug Log
    global String debugLog;
	public string QueryString;

    /**
     * @description: Get All of our Project Records for the Batch
     **/
    global database.querylocator start(database.batchableContext bc) {
	// Modified By - Neha Sharma - 10/21/2020 - CR-20200602-14130
        //Date instance 
        Date myDate = date.newinstance(2020,01, 01);
        
        if (QueryString == null)
            QueryString = 'SELECT Id, Last_Executive_Update__c, Last_Internal_Check_In__c FROM Project__c WHERE LastModifieddate = THIS_YEAR AND RecordType.DeveloperName = \'SSC\'';
            debugLog = '';
        return database.getquerylocator(QueryString);
    }

     /**
     * @description: Update the Project records which will kick off the Site Live Logic upon update
     **/
    global void execute(Database.BatchableContext bd, List<Project__c> projects) {

        //Member Success Record Type Id 
        Id memberSuccessRTId = Util.RecordTypeId('Event', 'Member Success');
        
        if(projects.size() > 0) {
            
            //Map to hold the projects
        	Map<Id, Project__c> mapProjects = new Map<Id, Project__c>();
            
            //Map to hold the Project id with Date. Last Executive
            Set<Id> setProjectIdForLastExecutiveUpdate = new Set<Id>();
            
            //Map to hold the Project id with Date. Last Interaction Check Ins
            Set<Id> setProjectIdForLastInteractionCheckIns = new Set<Id>();
            
            //Modified By - Neha Sharma - 10/21/2020 - CR-20200602-14130 -Comment out the criteria of Event Type('In Person Visit','Phone Appointment) from query as well as condition
            //Get all Member success Events related to Tech Projects
            for(Event e : [SELECT Id, Subject, WhatId, ActivityDate, Event_Type__c, Event_Purpose__c FROM Event 
                           WHERE WhatId IN : projects
                           AND What.RecordType.DeveloperName = 'SSC'
                           AND RecordTypeId =: memberSuccessRTId 
                           ORDER BY ActivityDate DESC])
            {
                //If Event Type is In Person Visit or Phone Appointment and Subject contains 'Executive Update' then populate  Last_Executive_Update__c with most recent Activity Date 
                if(!setProjectIdForLastExecutiveUpdate.contains(e.WhatId) && String.isNotBlank(e.Subject) && e.Subject.containsIgnoreCase('Executive Update')  
                  /* && (e.Event_Type__c == 'In Person Visit' || e.Event_Type__c == 'Phone Appointment') */ && e.ActivityDate < System.today()) {
                    	
					setProjectIdForLastExecutiveUpdate.add(e.WhatId);
                       
                    if(!mapProjects.containsKey(e.WhatId))
                    	mapProjects.put(e.WhatId, new Project__c(Id = e.WhatId));
                    
					mapProjects.get(e.WhatId).Last_Executive_Update__c = e.ActivityDate;
				} 	
                 
                //If event purpose is Internal Discussion then populate  Last_Internal_Check_In__c with most recent Activity Date 
                if(!setProjectIdForLastInteractionCheckIns.contains(e.WhatId) && e.Event_Purpose__c == 'Internal Discussion'  && e.ActivityDate < System.today()) {
                    
                    setProjectIdForLastInteractionCheckIns.add(e.WhatId);
                    
                    if(!mapProjects.containsKey(e.WhatId))
                        mapProjects.put(e.WhatId, new Project__c(Id = e.WhatId));
                    
                    mapProjects.get(e.WhatId).Last_Internal_Check_In__c = e.ActivityDate;
                }
            }
            //Empty check on Map
            if(mapProjects.size() > 0 && mapProjects.values() != null && mapProjects.values().size() > 0) {
                
                //Bypassing the triggers.
                Util.ByPassAllTriggers = true; 
                    //Update  Project records
                    debugLog += Util.createLog(Database.update(mapProjects.values()));
                util.ByPassAllTriggers = false;
            }
        }
    }
    
    global void finish(database.batchableContext bc) {
        //Checking logMessage  string for blank value but if it does not have blank value with it then emailed it to SFAdmin.
        if(debugLog != '') 
            Util.sendBatchStatus(bc.getJobId(), 'Betch_UpdateLastExecutiveAndInternalDate', debugLog, UserInfo.getUserEmail());	
    }
}