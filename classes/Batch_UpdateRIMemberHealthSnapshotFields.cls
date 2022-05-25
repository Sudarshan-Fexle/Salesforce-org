/*
    Purpose            :    Batch to populate "RI Member Health Snapshot" section fields on membership records.
    
    Created By         :    Abhinav Sharma
    
    Current Version    :    v1.0
    
    Revision Log       :    v1.0 - Abhinav Sharma - CR-20160114-9516 - 02/25/2016
							V1.1 - Modified by Abhinav Sharma - CR-20161031-10294 - 11/21/2016 - Process only updated records
							V1.2 - Modified By - Mahendra Swarnkar - CR-20170221-10705 - 4/27/2017 - Commented out the code to by pass the auto population of following fields on Membership record.
									Fields are as follows:-
										"Average_QA_Grade__c", "Average_QA_Recommend__c", "Days_Since_Last_Teleconference_Date__c",
										"Days_Since_Last_Recognized_ROI__c", "Next_Executive_Sponsor_Update__c", "Logins_Last_Month__c"
										"Executive_Sponsor_Current_Through__c", "Users_Last_Month__c", "Next_Teleconference_Date__c",
										"Last_Executive_Sponsor_Update__c".	 
							
*/
    
global class Batch_UpdateRIMemberHealthSnapshotFields implements Database.Batchable<SObject>, Database.Stateful {
    
    //Variable to store dynamic soql query
    public String query;
    
    //String variable to hold the entire log message string value
    global String debugLogStr; 

    //Batch Constructor
    global Batch_UpdateRIMemberHealthSnapshotFields() {
        debugLogStr = '';
    }

    //Start Method
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        //Checking query variable for null value
        if (query == null)
			
			//V1.2 - Modified By - Mahendra Swarnkar - CR-20170221-10705 - 4/27/2017 - Commented out the code to by pass the auto population of Membership fields. - Starts from here
			query = 'SELECT Id, Executive_Sponsor__c, Primary_Project__c, Program__c,'
                    + ' Program__r.Program_Acronym__c, Membership_Status__c,'
                        + ' (SELECT Id, Primary_Paid_Membership__c FROM Projects__r) '
                    + ' From Membership__c '
                    + ' WHERE LastModifiedDate >= YESTERDAY ';
            
            /*            
            query = 'SELECT Id, Days_Since_Last_Teleconference_Date__c, Next_Teleconference_Date__c,'
                    + ' Days_Since_Last_Recognized_ROI__c, Last_Executive_Sponsor_Update__c,'
                    + ' Next_Executive_Sponsor_Update__c, Average_QA_Grade__c, Average_QA_Recommend__c,'
                    + ' Executive_Sponsor__c, Executive_Sponsor_Current_Through__c,'
                    + ' Logins_Last_Month__c, Users_Last_Month__c, Primary_Project__c, Program__c,'
                    + ' Program__r.Program_Acronym__c, Membership_Status__c,'
                        + ' (SELECT Id, Primary_Paid_Membership__c FROM Projects__r) '
                    + ' From Membership__c '
                    + ' WHERE LastModifiedDate >= YESTERDAY ';
        	*/
        //V1.2 - Modified By - Mahendra Swarnkar - CR-20170221-10705 - 4/27/2017 - Commented out the code to by pass the auto population of Membership fields. - Ends here
        
        return Database.getQueryLocator(query);
    }

    //Execute method
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        
        //Map of memberships in current scope
        Map<Id, Membership__c> mapOfMembershipsAreInCurrentScope = new map<Id, Membership__c>((List<Membership__c>)scope);
        
        //Map of membership records
        Map<Id, Membership__c> mapOfMemberships = new Map<Id, Membership__c>();
                                                                                   
        //Map of projects
        Map<Id, Project__c> mapOfProjects = new Map<Id, Project__c>();
        
        //Set of primary projects IDs
        Set<Id> setOfPrimaryProjects = new Set<Id>();
        
        //Today's Date
        Date todaysDate = System.today();
        
        //previous month num value
        Integer previousMonthNumValue = System.today().addMonths(-1).month();
        
        //Today's Date year
        String todaysDateYearString = String.valueOf(System.today().Year());
        
        //Loop through scope records and populate collections with appropriate values
        for(Membership__c mem : mapOfMembershipsAreInCurrentScope.values()) {
            
            //Checking for membership status
            if(String.isNotBlank(mem.Membership_Status__c)
                && mem.Membership_Status__c == System.Label.ELIGIBLE_MEMBERSHIP_STATUS) {
            	
				//V1.2 - Modified By - Mahendra Swarnkar - CR-20170221-10705 - 4/27/2017 - Commented out the code to by pass the auto population of Membership fields. - Starts from here
                //populating map of membership with default values
                 mapOfMemberships.put(mem.Id, new membership__c(Id = mem.Id, Executive_Sponsor__c = null));
                    
                /*    
                mapOfMemberships.put(mem.Id, new membership__c(Id = mem.Id,
                                                                Days_Since_Last_Teleconference_Date__c = null,
                                                                Next_Teleconference_Date__c = null, 
                                                                Days_Since_Last_Recognized_ROI__c = null,
                                                                Last_Executive_Sponsor_Update__c = null,
                                                                Next_Executive_Sponsor_Update__c = null,
                                                                Average_QA_Grade__c = null,
                                                                Average_QA_Recommend__c = null,
                                                                Executive_Sponsor__c = null,
                                                                Executive_Sponsor_Current_Through__c = null,
                                                                Logins_Last_Month__c = null,
                                                                Users_Last_Month__c = null)
                                                                );
				*/
            	//V1.2 - Modified By - Mahendra Swarnkar - CR-20170221-10705 - 4/27/2017 - Commented out the code to by pass the auto population of Membership fields. - Ends here
                
				//Loop over children project records
                if(mem.Projects__r != null && mem.Projects__r.size() > 0) {
                    for(Project__c pro : mem.Projects__r)
                        mapOfProjects.put(pro.Id, pro);              
                }
            
                //CHecking for the field value and populating collection with primary project
                if(mem.Primary_Project__c != null)
                    setOfPrimaryProjects.add(mem.Primary_Project__c);
            }            
        }    
        
        //V1.2 - Commented out By - Mahendra Swarnkar - CR-20170221-10705 - 4/27/2017 - by pass the auto population of "Average_QA_Grade__c" and "Average_QA_Recommend__c" FIelds on the Membership record. - Starts from here
        /*
        //Checking for map size value
        if(mapOfMemberships.keySet().size() > 0) {
            
            //List of events
            List<Event> events = new List<Event>();
        
            //Get all record types on event object
            Map<String, Id> eventRecordTypesMap = Util.recordtypemap(Batch_UpdateRIMemberHealthFieldsConstant.EVENT_OBJECT);

            //Set to hold the eligible record type IDs
            Set<Id> eligibleEventRecordTypes = new Set<Id>();
                        
            //Looping over map keyset and accordingly populating collection with map retrieved values
            for(String recordTypeLabel : eventRecordTypesMap.keySet()) {
                if(recordTypeLabel != null 
                   && recordTypeLabel.equalsIgnoreCase(Batch_UpdateRIMemberHealthFieldsConstant.EVENT_RECORD_TYPE_PT_QA_CALL)
                   && eventRecordTypesMap.get(recordTypeLabel) != null  
                  )
                    eligibleEventRecordTypes.add(eventRecordTypesMap.get(recordTypeLabel));     
            }
            
            //Map to hold the membership Id as key and corresponding "Average QA Grade" calculation as value
            Map<Id, Decimal> mapMembershipIdWithAverageQAGrade = new Map<Id, Decimal>();
        
            //Map to hold the membership Id as key and corresponding "Average QA Recommend" calculation as value
            Map<Id, Decimal> mapMembershipIdWithAverageQARecommend = new Map<Id, Decimal>();
            
            //Map to hold the membership record Id as key and events "GPA" field sum as value
            Map<Id, Decimal> mapofMembershipIdWIthGPASum = new Map<Id, Decimal>();
            
            //Map to hold the membership Id as key and events "Would Recommanded" field sum as value
            Map<Id, Decimal> mapofMembershipIdWithWouldRecommandedSum = new Map<Id, Decimal>();
            
            //Map to hold the membership ID as key and List of eligible events as key
            Map<Id, List<Event>> mapOfMembershipIdWithEvents = new Map<Id, List<Event>>();
            
            //Map to hold the membership Id as key and eligible event records count having a valid and Non-N/A value 
            //for the Grade field
            Map<Id, Integer> mapOfMembershipIdWithEventsCountHavingValidGrade = new Map<Id, Integer>();
            
            //Map to hold the membership Id as key and eligible event records count having a valid and Non-N/A value 
            //for the Would Recommend field
            Map<Id, Integer> mapOfMembershipIdWithEventsCountHavingValidWouldRecommend = new Map<Id, Integer>();
            
            //Loop through event records
            for (Event ev : [SELECT Id, WhatId, GPA__c, Grade__c, Would_Recommend__c
                             FROM Event 
                             WHERE WhatId != null 
                             AND WhatId IN : mapOfMemberships.keySet()
                             AND RecordTypeId != null
                             AND RecordTypeId IN : eligibleEventRecordTypes
                             AND Cancelled_Did_Not_Occur__c = false
                             AND EndDateTime != null
                             AND EndDateTime >= LAST_N_DAYS : 365]) {
                if(mapOfMembershipIdWithEvents.containsKey(ev.WhatId)) 
                    mapOfMembershipIdWithEvents.get(ev.WhatId).add(ev);  
                else  
                    mapOfMembershipIdWithEvents.put(ev.WhatId, new List<Event>{ev});                      
            }
            
            //Checking for map size and null value
            if(mapOfMembershipIdWithEvents != null && mapOfMembershipIdWithEvents.keySet().size() > 0) {
                
                //temp variables
                Decimal sumOfGPA;
                Decimal sumOfWouldRecommanded;
                
                //Loop through map keys
                for(Id mID : mapOfMembershipIdWithEvents.keySet()) {
                    
                    //Initialization
                    sumOfGPA = 0.0;
                    sumOfWouldRecommanded = 0.0;
                    
                    //Loop through map Values
                    for(Event e : mapOfMembershipIdWithEvents.get(mID)) {
                        
                        //Cheking for the "Grade" value
                        if(e.Grade__c != Batch_UpdateRIMemberHealthFieldsConstant.GRADE_NA
                            && String.isNotBlank(e.Grade__c)) {
                            sumOfGPA += e.GPA__c;
                            if(!mapOfMembershipIdWithEventsCountHavingValidGrade.containsKey(mID))
                                mapOfMembershipIdWithEventsCountHavingValidGrade.put(mID, 1);
                            else
                                mapOfMembershipIdWithEventsCountHavingValidGrade.put(mID, (mapOfMembershipIdWithEventsCountHavingValidGrade.get(mID) + 1));
                        }
                            
                                
                        //Checking for null value and populating variable accordingly
                        if(e.Would_Recommend__c != null) {
                            sumOfWouldRecommanded += e.Would_Recommend__c;
                            if(!mapOfMembershipIdWithEventsCountHavingValidWouldRecommend.containsKey(mID))
                                mapOfMembershipIdWithEventsCountHavingValidWouldRecommend.put(mID, 1);
                            else
                                mapOfMembershipIdWithEventsCountHavingValidWouldRecommend.put(mID, (mapOfMembershipIdWithEventsCountHavingValidWouldRecommend.get(mID) + 1));
                        }
                            
                        //Populating map with appropriate values
                        mapofMembershipIdWIthGPASum.put(mID, sumOfGPA);
                        mapofMembershipIdWithWouldRecommandedSum.put(mID, sumOfWouldRecommanded);
                    }
                    
                    //Checking for value in map. Doing calculation for average and then populate fields on membership accordingly
                    if(mapOfMemberships.containsKey(mID)
                        && mapOfMemberships.get(mID) != null) {
                            
                        if(mapofMembershipIdWIthGPASum.containsKey(mID) 
                            && mapofMembershipIdWIthGPASum.get(mID) != null
                            && mapOfMembershipIdWithEventsCountHavingValidGrade.containsKey(mID)
                            && mapOfMembershipIdWithEventsCountHavingValidGrade.get(mId) != null)    
                            mapOfMemberships.get(mID).Average_QA_Grade__c = mapofMembershipIdWIthGPASum.get(mID)/mapOfMembershipIdWithEventsCountHavingValidGrade.get(mID);
                            
                        if(mapofMembershipIdWithWouldRecommandedSum.containsKey(mID) 
                            && mapofMembershipIdWithWouldRecommandedSum.get(mID) != null
                            && mapOfMembershipIdWithEventsCountHavingValidWouldRecommend.containsKey(mID)
                            && mapOfMembershipIdWithEventsCountHavingValidWouldRecommend.get(mId) != null)    
                            mapOfMemberships.get(mID).Average_QA_Recommend__c = mapofMembershipIdWithWouldRecommandedSum.get(mID)/mapOfMembershipIdWithEventsCountHavingValidWouldRecommend.get(mID);    
                    }
                }
            }
        }
		*/
        //V1.2 - Commented out By - Mahendra Swarnkar - CR-20170221-10705 - 4/27/2017 - by pass the auto population of "Average_QA_Grade__c" and "Average_QA_Recommend__c" FIelds on the Membership record - Ends here
        /*<!--Modified By Dipesh Gupta -CR-20190524-13152 - Date-06/14/2019 -->*/
        //Map to hold project ID as key and list of it's children "Member Interaction" records as value
        //Map<Id, List<Call__c>> mapOfProjectIdWithMemberInterections = new Map<Id, List<Call__c>>();
        
        //Map to hold membership record ID as key and it's most recent eligible children "Opportunity and ROI" record as value
        Map<Id, Opportunity_and_ROI__c> mapOfProjectIdWithOpportunityAndROIs = new Map<Id, Opportunity_and_ROI__c>();
        
        //Map to hold the Contact ID - Project ID as key and associated children project role record as value having Role equals to "Executive Sponsor"
        Map<String, Project_Role__c> mapContactIdWithProjectRole = new Map<String, Project_Role__c>();
        Map<ID, Project_Role__c> mapProjectIdWithPrimaryProjectRole = new Map<ID, Project_Role__c>();
        
        //Map to hold the "Project ID - Membership Id" as key and list of it's children "PTD Utilization" records as value
        //Spring clean up Map<String, List<Utilization__c>> mapProjectIDMembershipIdWithPTDUtilizations = new Map<String, List<Utilization__c>>();
        //Spring clean up  Map<String, List<Utilization__c>> mapProjectIDMembershipIdWithPTDUtilizations_1 = new Map<String, List<Utilization__c>>();
        
        //Checking for null and size value
        if(mapOfProjects != null && mapOfProjects.keyset().size() > 0) {
        	/*    
            //Querying member interaction records associated with project records
            //Populating map to hold the parent project record Id value as key and children MI records as value
            for(Call__c c : [SELECT Id, Interaction_Type__c, Current_Status__c, Call_Date__c, Member__c,
                             Member__r.Product__c, Member__r.Product__r.Program_Acronym__c, Sponsor_Update__c,
                             Senior_Member_On_Call__c
                             FROM Call__c
                             WHERE Member__c != null AND Member__c IN : mapOfProjects.keyset()
                            ]) {
                if(mapOfProjectIdWithMemberInterections.containsKey(c.Member__c)) 
                    mapOfProjectIdWithMemberInterections.get(c.Member__c).add(c);  
                else  
                    mapOfProjectIdWithMemberInterections.put(c.Member__c, new List<Call__c>{c});
            }
            
            //Querying "Opportunity and ROI" records associated with project records
            //Populating map to hold the parent project record Id value as key and children "Opportunity and ROI" records as value
            //We will only consider past dates and today's date
            for(Opportunity_and_ROI__c oAR : [SELECT ID, ROI_Member_Sign_Off_Date__c, Project__c 
                                                FROM Opportunity_and_ROI__c
                                                WHERE Project__c != null
                                                AND Project__c IN : mapOfProjects.keyset()
                                                AND ROI_Member_Sign_Off_Date__c != null
                                                AND ROI_Member_Sign_Off_Date__c <=: todaysDate
                                                AND Value_Opportunity_Sign_Off_Contact__c != null
                                                AND ROI_Dollar_Amount__c != null
                                                AND ROI_Dollar_Amount__c >= 1
                                                AND Value_Opportunity_ROI_Type__c != null
                                                AND Value_Opportunity_ROI_Type__c != ''
                                                AND Value_Opportunity_ROI_Type__c =: Batch_UpdateRIMemberHealthFieldsConstant.OPPORTUNITY_IDENTIFIED_STATUS
                                                ORDER By ROI_Member_Sign_Off_Date__c ASC]) {
                mapOfProjectIdWithOpportunityAndROIs.put(mapOfProjects.get(oAR.Project__c).Primary_Paid_Membership__c, oAR);    
            }
            */
            
             //Modified by - Dipesh Gupta - 05-27-2020 - CR-20200519-14068   - Role field changes 
            //Querying "Project Role" records associated with project records
            
            for(Project_Role__c pR : [SELECT ID, Contact__c, Role__c, Contact__r.Contact_Status__c, Project__c 
                                        FROM Project_Role__c
                                        WHERE Project__c != null
                                        AND Project__c IN : mapOfProjects.keyset()
                                        AND Contact__c != null
                                        AND Contact__r.Contact_Status__c =: Batch_UpdateRIMemberHealthFieldsConstant.CONTACT_STATUS_ACTIVE
                                        AND Role__c != null AND Role__c != '' 
                                        AND Role__c includes ('Executive Sponsor')]) {
                mapContactIdWithProjectRole.put(pR.Contact__c + Batch_UpdateRIMemberHealthFieldsConstant.DASH_CHARACTER + pR.Project__c, pR);   
            }
            
            /*
            //Querying "PTD Utilization" records assciated with project records
            for(Utilization__c ptDUtil : [SELECT ID, Total_Logins__c, Distinct_Users__c, Month_Num__c,
                                          Date__c, Project__c, Project__r.Primary_Paid_Membership__c 
                                          FROM Utilization__c
                                          WHERE Project__c != null
                                          AND Project__c IN : mapOfProjects.keyset()
                                          AND Project__r.Primary_Paid_Membership__c != null
                                          AND Distinct_Users__c != null
                                          AND Distinct_Users__c > 0
                                          AND Month_Num__c != null
                                          AND Month_Num__c = : previousMonthNumValue
                                          AND Year__c != null
                                          AND Year__c =: todaysDateYearString]) {
                 if(mapProjectIDMembershipIdWithPTDUtilizations.containsKey(ptDUtil.Project__c + Batch_UpdateRIMemberHealthFieldsConstant.DASH_CHARACTER + ptDUtil.Project__r.Primary_Paid_Membership__c)) 
                    mapProjectIDMembershipIdWithPTDUtilizations.get(ptDUtil.Project__c + Batch_UpdateRIMemberHealthFieldsConstant.DASH_CHARACTER + ptDUtil.Project__r.Primary_Paid_Membership__c).add(ptDUtil);  
                else  
                    mapProjectIDMembershipIdWithPTDUtilizations.put(ptDUtil.Project__c + Batch_UpdateRIMemberHealthFieldsConstant.DASH_CHARACTER + ptDUtil.Project__r.Primary_Paid_Membership__c, new List<Utilization__c>{ptDUtil});                               
            }
            
            //Querying "PTD Utilization" records assciated with project records
            for(Utilization__c ptDUtil_1 : [SELECT ID, Total_Logins__c, Distinct_Users__c, Month_Num__c,
                                              Date__c, Project__c, Project__r.Primary_Paid_Membership__c 
                                              FROM Utilization__c
                                              WHERE Project__c != null
                                              AND Project__c IN : mapOfProjects.keyset()
                                              AND Project__r.Primary_Paid_Membership__c != null
                                              AND Total_Logins__c != null
                                              AND Total_Logins__c > 0
                                              AND Month_Num__c != null
                                              AND Month_Num__c =: previousMonthNumValue
                                              AND Year__c != null
                                              AND Year__c =: todaysDateYearString]) {
                 if(mapProjectIDMembershipIdWithPTDUtilizations_1.containsKey(ptDUtil_1.Project__c + Batch_UpdateRIMemberHealthFieldsConstant.DASH_CHARACTER + ptDUtil_1.Project__r.Primary_Paid_Membership__c)) 
                    mapProjectIDMembershipIdWithPTDUtilizations_1.get(ptDUtil_1.Project__c + Batch_UpdateRIMemberHealthFieldsConstant.DASH_CHARACTER + ptDUtil_1.Project__r.Primary_Paid_Membership__c).add(ptDUtil_1);  
                else  
                    mapProjectIDMembershipIdWithPTDUtilizations_1.put(ptDUtil_1.Project__c + Batch_UpdateRIMemberHealthFieldsConstant.DASH_CHARACTER + ptDUtil_1.Project__r.Primary_Paid_Membership__c, new List<Utilization__c>{ptDUtil_1});                               
            }
			*/
        }
        
        //Checking for null and size value
        if(setOfPrimaryProjects != null && setOfPrimaryProjects.size() > 0) {
            
             //Modified by - Dipesh Gupta - 05-27-2020 - CR-20200519-14068 
            //Querying "Project Role" records associated with project records
            for(Project_Role__c pR : [SELECT ID, Contact__c, Role__c, Contact__r.Contact_Status__c,
                                        LastModifiedDate, Project__c
                                        FROM Project_Role__c
                                        WHERE Project__c != null
                                        AND Project__c IN : setOfPrimaryProjects
                                        AND Contact__c != null
                                        AND Contact__r.Contact_Status__c =: Batch_UpdateRIMemberHealthFieldsConstant.CONTACT_STATUS_ACTIVE
                                        AND Role__c != null AND Role__c != '' 
                                        AND Role__c Includes ('Executive Sponsor')
                                        ORDER By LastModifiedDate ASC]) {
                mapProjectIdWithPrimaryProjectRole.put(pR.Project__c, pR);
            }                                    
        }
        
        /*    
        //Map of Member interaction records where key => membership record ID and value => MI record
        Map<Id, Call__c> mapOfMembershipIdWithMemberInteraction = new Map<Id, Call__c>();
        Map<Id, Call__c> mapOfMembershipIdWithMemberInteraction_1 = new Map<Id, Call__c>();
        Map<Id, Call__c> mapOfMembershipIdWithMemberInteraction_2 = new Map<Id, Call__c>();
        Map<Id, Call__c> mapOfMembershipIdWithMemberInteraction_3 = new Map<Id, Call__c>();
        
        //Map of Teleconference utilization
        Map<Id, Utilization_Data_Object__c> mapOfMembershipIdWithTeleconferenceUtilization = new Map<Id, Utilization_Data_Object__c>();
        Map<Id, Utilization_Data_Object__c> mapOfMembershipIdWithTeleconferenceUtilization_1 = new Map<Id, Utilization_Data_Object__c>();
        
        //Map to hold the membership ID as key and list of telefonference utilization records as value
        Map<Id, List<Utilization_Data_Object__c>> mapMembershipIdWithListOfTeleConfs = new Map<Id, List<Utilization_Data_Object__c>>();
        
        //Loop through children teleconference utilization records
        for(Utilization_Data_Object__c tU : [SELECT Id, End_Date__c, Membership__c, Event_Name__c, 
                                             Utilization_Metric__c, ParticipationCount__c, Program__c,
                                             Membership__r.Program__c, Membership__r.Membership_Status__c,
                                             Membership__r.Program__r.Program_Acronym__c
                                             FROM Utilization_Data_Object__c
                                             WHERE Membership__c != null 
                                             AND Membership__c IN : mapOfMemberships.keySet()
                                             AND Membership__r.Program__c != null
                                             AND Membership__r.Program__r.Program_Acronym__c != null
                                             AND Membership__r.Membership_Status__c != null
                                             AND Membership__r.Membership_Status__c != ''
                                             AND Membership__r.Membership_Status__c =: System.Label.ELIGIBLE_MEMBERSHIP_STATUS]) {
            if(mapMembershipIdWithListOfTeleConfs.containsKey(tU.Membership__c)) 
                    mapMembershipIdWithListOfTeleConfs.get(tU.Membership__c).add(tU);  
                else  
                    mapMembershipIdWithListOfTeleConfs.put(tU.Membership__c, new List<Utilization_Data_Object__c>{tU});                                         
        }
        
        //Loop through scope membership records
        for(Id membershipId : mapMembershipIdWithListOfTeleConfs.keySet()) {
                    
            //Loop through children project records
            for(Utilization_Data_Object__c oU : mapMembershipIdWithListOfTeleConfs.get(membershipId)) {
                        
                //Workaround to populate "Days Since Last Teleconference Date" field with related calculations 
                //Checking if current context record satisfy all of the eligibility criteria's
                //Start from here
                //We will only consider past dates and today's date
                if(oU.Membership__c != null 
                   && oU.Event_Name__c != null 
                   && oU.End_Date__c != null
                   && oU.End_Date__c <= todaysDate
                   && String.isNotBlank(oU.Utilization_Metric__c)
                   && oU.Utilization_Metric__c.equalsIgnoreCase(Batch_UpdateRIMemberHealthFieldsConstant.UTILIZATION_METRIC_TELECONFERENCES) 
                   && oU.ParticipationCount__c > 0
                   && oU.Program__c != null
                   && oU.Program__c.equalsIgnoreCase(oU.Membership__r.Program__r.Program_Acronym__c)
                  ) {
                            
                      //Populate collection with appropriate values for "Days Since Last Teleconference Date" field related calculations 
                      if(!mapOfMembershipIdWithTeleconferenceUtilization.containsKey(membershipId))
                          mapOfMembershipIdWithTeleconferenceUtilization.put(membershipId, oU);
                      else {
                          if(mapOfMembershipIdWithTeleconferenceUtilization.get(membershipId) != null
                             && mapOfMembershipIdWithTeleconferenceUtilization.get(membershipId).End_Date__c != null
                             && oU.End_Date__c > mapOfMembershipIdWithTeleconferenceUtilization.get(membershipId).End_Date__c)
                              mapOfMembershipIdWithTeleconferenceUtilization.put(membershipId, oU);        
                      }
                }
                //Upto here
                        
                //Workaround to populate "Next Teleconference Date" field with related calculations 
                //Checking if current context record satisfy all of the eligibility criteria's
                //Start from here
                //We will only consider future dates
                if(oU.Membership__c != null 
                   && oU.Event_Name__c != null 
                   && oU.End_Date__c != null
                   && oU.End_Date__c > todaysDate
                   && String.isNotBlank(oU.Utilization_Metric__c)
                   && oU.Utilization_Metric__c.equalsIgnoreCase(Batch_UpdateRIMemberHealthFieldsConstant.UTILIZATION_METRIC_TELECONFERENCES) 
                   && (oU.ParticipationCount__c == null || oU.ParticipationCount__c == 0)
                   && oU.Program__c != null
                   && oU.Program__c.equalsIgnoreCase(oU.Membership__r.Program__r.Program_Acronym__c)
                  ) {
                        
                      //Populate collection with appropriate values for "Next Teleconference Date" field related calculations 
                      if(!mapOfMembershipIdWithTeleconferenceUtilization_1.containsKey(membershipId))
                          mapOfMembershipIdWithTeleconferenceUtilization_1.put(membershipId, oU);
                      else {
                          if(mapOfMembershipIdWithTeleconferenceUtilization_1.get(membershipId) != null
                             && mapOfMembershipIdWithTeleconferenceUtilization_1.get(membershipId).End_Date__c != null
                             && oU.End_Date__c < mapOfMembershipIdWithTeleconferenceUtilization_1.get(membershipId).End_Date__c)
                              mapOfMembershipIdWithTeleconferenceUtilization_1.put(membershipId, oU);        
                      }
                }
                //Upto here
            }            
        }
        
        //Map to hold the project ID as key and corresponding summation of fields as value
        Map<String, Decimal> mapProjectIdMembershipIdWithSumOfLoginsLastMonth = new Map<String, Decimal>();
        Map<String, Decimal> mapProjectIdMembershipIdWithSumOfUsersLastMonth = new Map<String, Decimal>();
        
        //Checking map for null and size value
        if(mapProjectIDMembershipIdWithPTDUtilizations != null && mapProjectIDMembershipIdWithPTDUtilizations.keySet().size() > 0) {
            
            //Iteration over map keys and corresponding values
            for(String proMemId : mapProjectIDMembershipIdWithPTDUtilizations.keySet()) {
                Decimal loginLastMonth = 0;
                for(Utilization__c uti : mapProjectIDMembershipIdWithPTDUtilizations.get(proMemId)) {
                    if(uti.Total_Logins__c == null)
                        uti.Total_Logins__c = 0;
                    
                    //Populating variable with sum of last logins
                    loginLastMonth += uti.Total_Logins__c;  
                }
                
                //Populating map with appropriate combination of key and value
                mapProjectIdMembershipIdWithSumOfLoginsLastMonth.put(proMemId, loginLastMonth);
            }
        }
        
        //Checking map for null and size value
        if(mapProjectIDMembershipIdWithPTDUtilizations_1 != null 
            && mapProjectIDMembershipIdWithPTDUtilizations_1.keySet().size() > 0) {
            
            //Iteration over map keys and corresponding values
            for(String projMemId : mapProjectIDMembershipIdWithPTDUtilizations_1.keySet()) {
                Decimal usersLastMonth = 0;
                for(Utilization__c util : mapProjectIDMembershipIdWithPTDUtilizations_1.get(projMemId)) {
                    if(util.Distinct_Users__c == null)
                        util.Distinct_Users__c = 0;
                    
                    //Populating variable with sum of last logins
                    usersLastMonth += util.Distinct_Users__c;   
                }
                
                //Populating map with appropriate combination of key and value
                mapProjectIdMembershipIdWithSumOfUsersLastMonth.put(projMemId, usersLastMonth);
            }
        }
        
        //Map to hold the membership record Id as key and commulative sum of fields value from all children project records as value
        Map<Id, Decimal> mapMembershipIdWithCommulativeSumOfLoginsLastMonth = new Map<Id, Decimal>();
        Map<Id, Decimal> mapMembershipIdWithCommulativeSumOfUsersLastMonth = new Map<Id, Decimal>();
        
        //Checking map for null and size value
        if(mapProjectIdMembershipIdWithSumOfLoginsLastMonth != null 
            && mapProjectIdMembershipIdWithSumOfLoginsLastMonth.keySet().size() > 0) {
            for(String combinedKey : mapProjectIdMembershipIdWithSumOfLoginsLastMonth.keySet()) {
                if(String.isNotBlank(combinedKey) 
                    && combinedKey.split(Batch_UpdateRIMemberHealthFieldsConstant.DASH_CHARACTER) != null
                    && combinedKey.split(Batch_UpdateRIMemberHealthFieldsConstant.DASH_CHARACTER).size() == 2
                ) {
                    if(!mapMembershipIdWithCommulativeSumOfLoginsLastMonth.containsKey(combinedKey.split(Batch_UpdateRIMemberHealthFieldsConstant.DASH_CHARACTER)[1]))
                        mapMembershipIdWithCommulativeSumOfLoginsLastMonth.put(ID.valueOf(combinedKey.split(Batch_UpdateRIMemberHealthFieldsConstant.DASH_CHARACTER)[1]), mapProjectIdMembershipIdWithSumOfLoginsLastMonth.get(combinedKey));       
                    else
                        mapMembershipIdWithCommulativeSumOfLoginsLastMonth.put(ID.valueOf(combinedKey.split(Batch_UpdateRIMemberHealthFieldsConstant.DASH_CHARACTER)[1]), (mapMembershipIdWithCommulativeSumOfLoginsLastMonth.get(ID.valueOf(combinedKey.split(Batch_UpdateRIMemberHealthFieldsConstant.DASH_CHARACTER)[1])) + mapProjectIdMembershipIdWithSumOfLoginsLastMonth.get(combinedKey)));
                }
            }   
        }
        
        //Checking map for null and size value
        if(mapProjectIdMembershipIdWithSumOfUsersLastMonth != null 
            && mapProjectIdMembershipIdWithSumOfUsersLastMonth.keySet().size() > 0) {
            for(String combineKey : mapProjectIdMembershipIdWithSumOfUsersLastMonth.keySet()) {
                if(String.isNotBlank(combineKey) 
                    && combineKey.split(Batch_UpdateRIMemberHealthFieldsConstant.DASH_CHARACTER) != null
                    && combineKey.split(Batch_UpdateRIMemberHealthFieldsConstant.DASH_CHARACTER).size() == 2
                ) {
                    if(!mapMembershipIdWithCommulativeSumOfUsersLastMonth.containsKey(combineKey.split(Batch_UpdateRIMemberHealthFieldsConstant.DASH_CHARACTER)[1]))
                        mapMembershipIdWithCommulativeSumOfUsersLastMonth.put(ID.valueOf(combineKey.split(Batch_UpdateRIMemberHealthFieldsConstant.DASH_CHARACTER)[1]), mapProjectIdMembershipIdWithSumOfUsersLastMonth.get(combineKey));       
                    else
                        mapMembershipIdWithCommulativeSumOfUsersLastMonth.put(ID.valueOf(combineKey.split(Batch_UpdateRIMemberHealthFieldsConstant.DASH_CHARACTER)[1]), (mapMembershipIdWithCommulativeSumOfUsersLastMonth.get(ID.valueOf(combineKey.split(Batch_UpdateRIMemberHealthFieldsConstant.DASH_CHARACTER)[1])) + mapProjectIdMembershipIdWithSumOfUsersLastMonth.get(combineKey)));
                }
            }   
        }
        
        //Checking map for null and size value
        if(mapOfProjectIdWithMemberInterections != null && mapOfProjectIdWithMemberInterections.keySet().size() > 0) {
            
            //Checking member interaction records for eligibility
            //Populating collection with appropriate values
            for(Id projectId : mapOfProjectIdWithMemberInterections.keySet()) {
                for(Call__c mI : mapOfProjectIdWithMemberInterections.get(projectId)) {
                    
                    //Checking if program acronyms matches in between records or not    
                    if(mI.Member__c != null
                        && mapOfProjects.get(mI.Member__c) != null
                        && mapOfProjects.get(mI.Member__c).Primary_Paid_Membership__c != null
                        && mapOfMembershipsAreInCurrentScope.containsKey(mapOfProjects.get(mI.Member__c).Primary_Paid_Membership__c) 
                        && mapOfMembershipsAreInCurrentScope.get(mapOfProjects.get(mI.Member__c).Primary_Paid_Membership__c) != null
                        && mapOfMembershipsAreInCurrentScope.get(mapOfProjects.get(mI.Member__c).Primary_Paid_Membership__c).Program__c != null
                        && mI.Member__r.Product__c != null
                        && mapOfMembershipsAreInCurrentScope.get(mapOfProjects.get(mI.Member__c).Primary_Paid_Membership__c).Program__r.Program_Acronym__c == mI.Member__r.Product__r.Program_Acronym__c) { 
                        
                        //Workaround to populate "Days Since Last Teleconference Date" field with related calculations    
                        //Checking if current context record satisfy all of the eligibility criteria's
                        //Start from here
                        //We wull only consider past dates and today's date
                        if(mI.Interaction_Type__c == Batch_UpdateRIMemberHealthFieldsConstant.INTERACTION_TYPE_WEB_CONFERENCES 
                            && mI.Current_Status__c == Batch_UpdateRIMemberHealthFieldsConstant.CURRENT_STATUS_COMPLETED 
                            && mI.Call_Date__c != null && mI.Member__c != null && mI.Call_Date__c <= todaysDate) {
                                
                            //Populate collection with appropriate values for "Days Since Last Teleconference Date" field related calculations 
                            if(!mapOfMembershipIdWithMemberInteraction.containsKey(mapOfProjects.get(mI.Member__c).Primary_Paid_Membership__c)) {
                                mapOfMembershipIdWithMemberInteraction.put(mapOfProjects.get(mI.Member__c).Primary_Paid_Membership__c, mI);
                            } else {
                                if(mapOfMembershipIdWithMemberInteraction.get(mapOfProjects.get(mI.Member__c).Primary_Paid_Membership__c) != null
                                    && mapOfMembershipIdWithMemberInteraction.get(mapOfProjects.get(mI.Member__c).Primary_Paid_Membership__c).Call_Date__c != null
                                    && mI.Call_Date__c > mapOfMembershipIdWithMemberInteraction.get(mapOfProjects.get(mI.Member__c).Primary_Paid_Membership__c).Call_Date__c
                                )
                                mapOfMembershipIdWithMemberInteraction.put(mapOfProjects.get(mI.Member__c).Primary_Paid_Membership__c, mI);        
                            }
                        }
                        //Upto here    
                        
                        //Workaround to populate "Next Teleconference Date" field with related calculations    
                        //Checking if current context record satisfy all of the eligibility criteria's
                        //We will only consider future dates
                        if(mI.Interaction_Type__c == Batch_UpdateRIMemberHealthFieldsConstant.INTERACTION_TYPE_WEB_CONFERENCES 
                            && (mI.Current_Status__c == Batch_UpdateRIMemberHealthFieldsConstant.CURRENT_STATUS_REQUESTED 
                                || mI.Current_Status__c == Batch_UpdateRIMemberHealthFieldsConstant.CURRENT_STATUS_SCHEDULED)
                            && mI.Call_Date__c != null && mI.Member__c != null && mI.Call_Date__c > todaysDate) {
                                
                            //Populate collection with appropriate values for "Next Teleconference Date" field related calculations
                            if(!mapOfMembershipIdWithMemberInteraction_1.containsKey(mapOfProjects.get(mI.Member__c).Primary_Paid_Membership__c)) {
                                mapOfMembershipIdWithMemberInteraction_1.put(mapOfProjects.get(mI.Member__c).Primary_Paid_Membership__c, mI);
                            } else {
                                if(mapOfMembershipIdWithMemberInteraction_1.get(mapOfProjects.get(mI.Member__c).Primary_Paid_Membership__c) != null
                                    && mapOfMembershipIdWithMemberInteraction_1.get(mapOfProjects.get(mI.Member__c).Primary_Paid_Membership__c).Call_Date__c != null
                                    && mI.Call_Date__c < mapOfMembershipIdWithMemberInteraction_1.get(mapOfProjects.get(mI.Member__c).Primary_Paid_Membership__c).Call_Date__c
                                )
                                mapOfMembershipIdWithMemberInteraction_1.put(mapOfProjects.get(mI.Member__c).Primary_Paid_Membership__c, mI);        
                            }
                        }
                        
                        //Workaround to populate "Last Executive Sponsor Update" field with calculated value    
                        //Checking if current context record satisfy all of the eligibility criteria's
                        //Start from here
                        //We will only consider past dates and today's date
                        if(mI.Sponsor_Update__c == true 
                            && mI.Current_Status__c == Batch_UpdateRIMemberHealthFieldsConstant.CURRENT_STATUS_COMPLETED 
                            && mI.Senior_Member_On_Call__c != null && mI.Call_Date__c != null && mI.Member__c != null
                            && mI.Call_Date__c <= todaysDate
                            && mapContactIdWithProjectRole.containsKey(mI.Senior_Member_On_Call__c + Batch_UpdateRIMemberHealthFieldsConstant.DASH_CHARACTER + mI.Member__c)
                            && mapContactIdWithProjectRole.get(mI.Senior_Member_On_Call__c + Batch_UpdateRIMemberHealthFieldsConstant.DASH_CHARACTER + mI.Member__c) != null) {
                            
                            //Populate collection with appropriate values for "Last Executive Sponsor Update" field related calculations 
                            if(!mapOfMembershipIdWithMemberInteraction_2.containsKey(mapOfProjects.get(mI.Member__c).Primary_Paid_Membership__c)) {
                                mapOfMembershipIdWithMemberInteraction_2.put(mapOfProjects.get(mI.Member__c).Primary_Paid_Membership__c, mI);
                            } else {
                                if(mapOfMembershipIdWithMemberInteraction_2.get(mapOfProjects.get(mI.Member__c).Primary_Paid_Membership__c) != null
                                    && mapOfMembershipIdWithMemberInteraction_2.get(mapOfProjects.get(mI.Member__c).Primary_Paid_Membership__c).Call_Date__c != null
                                    && mI.Call_Date__c > mapOfMembershipIdWithMemberInteraction_2.get(mapOfProjects.get(mI.Member__c).Primary_Paid_Membership__c).Call_Date__c
                                )
                                mapOfMembershipIdWithMemberInteraction_2.put(mapOfProjects.get(mI.Member__c).Primary_Paid_Membership__c, mI);        
                            }   
                        }
                        //Upto here
                        
                        //Workaround to populate "Next Executive Sponsor Update" field with calculated value    
                        //Checking if current context record satisfy all of the eligibility criteria's
                        //We only have to consider future dates
                        //Start from here
                        if(mI.Sponsor_Update__c == true 
                            && mI.Current_Status__c == Batch_UpdateRIMemberHealthFieldsConstant.CURRENT_STATUS_SCHEDULED 
                            && mI.Senior_Member_On_Call__c != null && mI.Call_Date__c != null && mI.Member__c != null
                            && mI.Call_Date__c > todaysDate
                            && mapContactIdWithProjectRole.containsKey(mI.Senior_Member_On_Call__c + Batch_UpdateRIMemberHealthFieldsConstant.DASH_CHARACTER + mI.Member__c)
                            && mapContactIdWithProjectRole.get(mI.Senior_Member_On_Call__c + Batch_UpdateRIMemberHealthFieldsConstant.DASH_CHARACTER + mI.Member__c) != null) {
                            
                            //Populate collection with appropriate values for "Last Executive Sponsor Update" field related calculations 
                            if(!mapOfMembershipIdWithMemberInteraction_3.containsKey(mapOfProjects.get(mI.Member__c).Primary_Paid_Membership__c)) {
                                mapOfMembershipIdWithMemberInteraction_3.put(mapOfProjects.get(mI.Member__c).Primary_Paid_Membership__c, mI);
                            } else {
                                if(mapOfMembershipIdWithMemberInteraction_3.get(mapOfProjects.get(mI.Member__c).Primary_Paid_Membership__c) != null
                                    && mapOfMembershipIdWithMemberInteraction_3.get(mapOfProjects.get(mI.Member__c).Primary_Paid_Membership__c).Call_Date__c != null
                                    && mI.Call_Date__c < mapOfMembershipIdWithMemberInteraction_3.get(mapOfProjects.get(mI.Member__c).Primary_Paid_Membership__c).Call_Date__c
                                )
                                mapOfMembershipIdWithMemberInteraction_3.put(mapOfProjects.get(mI.Member__c).Primary_Paid_Membership__c, mI);        
                            }   
                        }
                        //Upto here        
                    }
                }           
            }
        }
        */
        //Loop through membership records
        for(Membership__c membership : mapOfMembershipsAreInCurrentScope.values()) {
            
            //Checking for membership status
            if(String.isNotBlank(membership.Membership_Status__c)
                && membership.Membership_Status__c == System.Label.ELIGIBLE_MEMBERSHIP_STATUS) {
                    
            	//Populate "Executive Sponsor" field with calculated value
                if(membership.Primary_Project__c != null 
                    && mapProjectIdWithPrimaryProjectRole.containsKey(membership.Primary_Project__c)
                    && mapProjectIdWithPrimaryProjectRole.get(membership.Primary_Project__c) != null) {
                    mapOfMemberships.get(membership.Id).Executive_Sponsor__c = mapProjectIdWithPrimaryProjectRole.get(membership.Primary_Project__c).Contact__c;
                    //mapOfMemberships.get(membership.Id).Executive_Sponsor_Current_Through__c = mapProjectIdWithPrimaryProjectRole.get(membership.Primary_Project__c).LastModifiedDate;
                } else {
                    mapOfMemberships.get(membership.Id).Executive_Sponsor__c = null;
                    //mapOfMemberships.get(membership.Id).Executive_Sponsor_Current_Through__c = null;
                }
                    
                /*
                //Populate "Days_Since_Last_Teleconference_Date__c" field with appropriate value
                //Start from here
                //Checking for the values in the map
                if(mapOfMembershipIdWithTeleconferenceUtilization.containsKey(membership.Id)
                    && mapOfMembershipIdWithMemberInteraction.containsKey(membership.Id)
                    && mapOfMembershipIdWithTeleconferenceUtilization.get(membership.Id) != null
                    && mapOfMembershipIdWithMemberInteraction.get(membership.Id) != null) {
                    
                    //Comparing the date fields value and populating membership field accordingly
                    if(mapOfMembershipIdWithTeleconferenceUtilization.get(membership.Id).End_Date__c > mapOfMembershipIdWithMemberInteraction.get(membership.Id).Call_Date__c)
                        mapOfMemberships.get(membership.Id).Days_Since_Last_Teleconference_Date__c = mapOfMembershipIdWithTeleconferenceUtilization.get(membership.Id).End_Date__c.daysBetween(todaysDate);
                    else
                        mapOfMemberships.get(membership.Id).Days_Since_Last_Teleconference_Date__c = mapOfMembershipIdWithMemberInteraction.get(membership.Id).Call_Date__c.daysBetween(todaysDate);    
                
                //Getting the most recent date value from the eligible MI record
                } else if(!mapOfMembershipIdWithTeleconferenceUtilization.containsKey(membership.Id)
                            && mapOfMembershipIdWithMemberInteraction.containsKey(membership.Id)
                            && mapOfMembershipIdWithMemberInteraction.get(membership.Id) != null) {
                            mapOfMemberships.get(membership.Id).Days_Since_Last_Teleconference_Date__c = mapOfMembershipIdWithMemberInteraction.get(membership.Id).Call_Date__c.daysBetween(todaysDate);                  
                
                //Getting the most recent date value from the eligible Other Utilization record
                } else if(!mapOfMembershipIdWithMemberInteraction.containsKey(membership.Id)
                            && mapOfMembershipIdWithTeleconferenceUtilization.containsKey(membership.Id)
                            && mapOfMembershipIdWithTeleconferenceUtilization.get(membership.Id) != null) {
                            mapOfMemberships.get(membership.Id).Days_Since_Last_Teleconference_Date__c = mapOfMembershipIdWithTeleconferenceUtilization.get(membership.Id).End_Date__c.daysBetween(todaysDate);
                
                //Setting null as a value if no eligible record exists
                } else {
                    mapOfMemberships.get(membership.Id).Days_Since_Last_Teleconference_Date__c = null;       
                }   
                //Upto here
                
                //Populate "Next Teleconference Date" field with appropriate value
                //Start from here
                //Checking for the values in the map
                if(mapOfMembershipIdWithTeleconferenceUtilization_1.containsKey(membership.Id)
                    && mapOfMembershipIdWithMemberInteraction_1.containsKey(membership.Id)
                    && mapOfMembershipIdWithTeleconferenceUtilization_1.get(membership.Id) != null
                    && mapOfMembershipIdWithMemberInteraction_1.get(membership.Id) != null) {
                    
                    //Comparing the date fields value and populating membership field accordingly
                    if(mapOfMembershipIdWithTeleconferenceUtilization_1.get(membership.Id).End_Date__c < mapOfMembershipIdWithMemberInteraction_1.get(membership.Id).Call_Date__c)
                        mapOfMemberships.get(membership.Id).Next_Teleconference_Date__c = mapOfMembershipIdWithTeleconferenceUtilization_1.get(membership.Id).End_Date__c;
                    else
                        mapOfMemberships.get(membership.Id).Next_Teleconference_Date__c = mapOfMembershipIdWithMemberInteraction_1.get(membership.Id).Call_Date__c;    
                
                //Getting the most recent date value from the eligible MI record
                } else if(!mapOfMembershipIdWithTeleconferenceUtilization_1.containsKey(membership.Id)
                            && mapOfMembershipIdWithMemberInteraction_1.containsKey(membership.Id)
                            && mapOfMembershipIdWithMemberInteraction_1.get(membership.Id) != null) {
                            mapOfMemberships.get(membership.Id).Next_Teleconference_Date__c = mapOfMembershipIdWithMemberInteraction_1.get(membership.Id).Call_Date__c;                  
                
                //Getting the most recent date value from the eligible Other Utilization record
                } else if(!mapOfMembershipIdWithMemberInteraction_1.containsKey(membership.Id)
                            && mapOfMembershipIdWithTeleconferenceUtilization_1.containsKey(membership.Id)
                            && mapOfMembershipIdWithTeleconferenceUtilization_1.get(membership.Id) != null) {
                            mapOfMemberships.get(membership.Id).Next_Teleconference_Date__c = mapOfMembershipIdWithTeleconferenceUtilization_1.get(membership.Id).End_Date__c;
                
                //Setting null as a value if no eligible record exists
                } else {
                    mapOfMemberships.get(membership.Id).Next_Teleconference_Date__c = null;       
                }   
                //Upto here 
                
                //Populate "Days Since Last Recognized ROI" field with calculated value
                if(mapOfProjectIdWithOpportunityAndROIs != null
                    && mapOfProjectIdWithOpportunityAndROIs.containsKey(membership.Id)
                    && mapOfProjectIdWithOpportunityAndROIs.get(membership.Id) != null) {
                    mapOfMemberships.get(membership.Id).Days_Since_Last_Recognized_ROI__c = mapOfProjectIdWithOpportunityAndROIs.get(membership.Id).ROI_Member_Sign_Off_Date__c.daysBetween(todaysDate);
                } else {
                    mapOfMemberships.get(membership.Id).Days_Since_Last_Recognized_ROI__c = null;        
                }
                
                //Populate "Last Executive Sponsor Update" field with calculated value
                if(mapOfMembershipIdWithMemberInteraction_2 != null
                    && mapOfMembershipIdWithMemberInteraction_2.containsKey(membership.Id)
                    && mapOfMembershipIdWithMemberInteraction_2.get(membership.Id) != null) {
                    mapOfMemberships.get(membership.Id).Last_Executive_Sponsor_Update__c = mapOfMembershipIdWithMemberInteraction_2.get(membership.Id).Call_Date__c;    
                } else {
                    mapOfMemberships.get(membership.Id).Last_Executive_Sponsor_Update__c = null;        
                }
                
                //Populate "Next Executive Sponsor Update" field with calculated value
                if(mapOfMembershipIdWithMemberInteraction_3 != null
                    && mapOfMembershipIdWithMemberInteraction_3.containsKey(membership.Id)
                    && mapOfMembershipIdWithMemberInteraction_3.get(membership.Id) != null) {
                    mapOfMemberships.get(membership.Id).Next_Executive_Sponsor_Update__c = mapOfMembershipIdWithMemberInteraction_3.get(membership.Id).Call_Date__c;    
                } else {
                    mapOfMemberships.get(membership.Id).Next_Executive_Sponsor_Update__c = null;        
                }
                
                //Populate "Logins Last Month" field with appropriate value
                if(mapMembershipIdWithCommulativeSumOfLoginsLastMonth != null
                    && mapMembershipIdWithCommulativeSumOfLoginsLastMonth.containsKey(membership.Id)
                    && mapMembershipIdWithCommulativeSumOfLoginsLastMonth.get(membership.Id) != null) {
                    mapOfMemberships.get(membership.Id).Logins_Last_Month__c = mapMembershipIdWithCommulativeSumOfLoginsLastMonth.get(membership.Id);   
                } else {
                    mapOfMemberships.get(membership.Id).Logins_Last_Month__c = null;
                }
                
                //Populate "Users Last Month" field with appropriate value
                if(mapMembershipIdWithCommulativeSumOfUsersLastMonth != null
                    && mapMembershipIdWithCommulativeSumOfUsersLastMonth.containsKey(membership.Id)
                    && mapMembershipIdWithCommulativeSumOfUsersLastMonth.get(membership.Id) != null) {
                    mapOfMemberships.get(membership.Id).Users_Last_Month__c = mapMembershipIdWithCommulativeSumOfUsersLastMonth.get(membership.Id); 
                } else {
                    mapOfMemberships.get(membership.Id).Users_Last_Month__c = null;
                }
                */
            }
        }
        
        //Clonning of map
        Map<Id, Membership__c> cloneOfMapMemberships = new Map<Id, Membership__c>();
        cloneOfMapMemberships = mapOfMemberships;
        
        //Re-Initialization of map
        mapOfMemberships = new Map<Id, Membership__c>();
        
        //Loop through membership records
        for(Membership__c mship : mapOfMembershipsAreInCurrentScope.values()) {
            
            //Checking for membership status
            if(String.isNotBlank(mship.Membership_Status__c)
                && mship.Membership_Status__c == System.Label.ELIGIBLE_MEMBERSHIP_STATUS) {
                     
            	//V1.1 - Modified by Abhinav Sharma - CR-20161031-10294 - 11/19/2016
                //Check the existing record vs the version of the record in scope and see if 
                //the key fields are different or not. If so, add the record to the list to be updated.
                if(cloneOfMapMemberships.containskey(mship.Id) 
                	&& cloneOfMapMemberships.get(mship.Id) != null
                    && 
                    (
                        (
                            cloneOfMapMemberships.get(mship.Id).Executive_Sponsor__c !=
                            mship.Executive_Sponsor__c
                        )
                        
                        //V1.2 - Modified By - Mahendra Swarnkar - CR-20170221-10705 - 4/27/2017 - Commented out the code to by pass the auto population of Membership fields. - Starts from here
                        /*
                        ||
                        
                        (
                            cloneOfMapMemberships.get(mship.Id).Days_Since_Last_Teleconference_Date__c !=
                            mship.Days_Since_Last_Teleconference_Date__c
                        )
                        || 
                        (
                            cloneOfMapMemberships.get(mship.Id).Next_Teleconference_Date__c !=
                            mship.Next_Teleconference_Date__c
                        )
                        || 
                        (
                            cloneOfMapMemberships.get(mship.Id).Days_Since_Last_Recognized_ROI__c !=
                            mship.Days_Since_Last_Recognized_ROI__c
                        )
                        || 
                        (
                            cloneOfMapMemberships.get(mship.Id).Last_Executive_Sponsor_Update__c !=
                            mship.Last_Executive_Sponsor_Update__c
                        )
                        || 
                        (
                            cloneOfMapMemberships.get(mship.Id).Next_Executive_Sponsor_Update__c !=
                            mship.Next_Executive_Sponsor_Update__c
                        )
                        || 
                        (
                            cloneOfMapMemberships.get(mship.Id).Average_QA_Grade__c !=
                            mship.Average_QA_Grade__c
                        )
                        || 
                        (
                            cloneOfMapMemberships.get(mship.Id).Average_QA_Recommend__c !=
                            mship.Average_QA_Recommend__c
                        )
                        || 
                        (
                            cloneOfMapMemberships.get(mship.Id).Executive_Sponsor_Current_Through__c !=
                            mship.Executive_Sponsor_Current_Through__c
                        )
                        || 
                        (
                            cloneOfMapMemberships.get(mship.Id).Logins_Last_Month__c !=
                            mship.Logins_Last_Month__c
                        )
                        || 
                        (
                            cloneOfMapMemberships.get(mship.Id).Users_Last_Month__c !=
                            mship.Users_Last_Month__c
                        )
						*/
                        //V1.2 - Modified By - Mahendra Swarnkar - CR-20170221-10705 - 4/27/2017 - Commented out the code to by pass the auto population of Membership fields. - Ends here
                    )      
				) {
					mapOfMemberships.put(mship.Id, cloneOfMapMemberships.get(mship.Id));
                }    
            } else {
                
                //V1.1 - Modified by Abhinav Sharma - CR-20161031-10294  - 11/21/2016 
                //Checking if any of the key field is having "Non-null" value with it or not
                if(
					(
                        mship.Executive_Sponsor__c != null
                        //V1.2 - Modified By - Mahendra Swarnkar - CR-20170221-10705 - 4/27/2017 - Commented out the code to by pass the auto population of Membership fields. - Starts from here
                        /*
                        ||
                        mship.Days_Since_Last_Teleconference_Date__c != null
                  		|| 
                        mship.Next_Teleconference_Date__c != null
                  		|| 
                        mship.Days_Since_Last_Recognized_ROI__c != null
                        || 
                        mship.Last_Executive_Sponsor_Update__c != null
                        || 
                        mship.Next_Executive_Sponsor_Update__c != null
                        || 
                        mship.Average_QA_Grade__c != null
                        || 
                        mship.Average_QA_Recommend__c != null
                        ||  
                        mship.Executive_Sponsor_Current_Through__c != null
                        || 
                        mship.Logins_Last_Month__c != null
                        || 
                        mship.Users_Last_Month__c != null
						*/
                		//V1.2 - Modified By - Mahendra Swarnkar - CR-20170221-10705 - 4/27/2017 - Commented out the code to by pass the auto population of Membership fields. - Ends here        
                    )
                ) {
                    //V1.2 - Modified By - Mahendra Swarnkar - CR-20170221-10705 - 4/27/2017 - Commented out the code to by pass the auto population of Membership fields. - Starts from here 
            		
                    mapOfMemberships.put(mship.Id, new membership__c(Id = mship.Id, Executive_Sponsor__c = null));
                    
                    /*mapOfMemberships.put(mship.Id, new membership__c(Id = mship.Id,
                                                                    Days_Since_Last_Teleconference_Date__c = null,
                                                                    Next_Teleconference_Date__c = null, 
                                                                    Days_Since_Last_Recognized_ROI__c = null,
                                                                    Last_Executive_Sponsor_Update__c = null,
                                                                    Next_Executive_Sponsor_Update__c = null,
                                                                    Average_QA_Grade__c = null,
                                                                    Average_QA_Recommend__c = null,
                                                                    Executive_Sponsor__c = null,
                                                                    Executive_Sponsor_Current_Through__c = null,
                                                                    Logins_Last_Month__c = null,
                                                                    Users_Last_Month__c = null)
                                                                );        
            		*/
					        
                    //V1.2 - Modified By - Mahendra Swarnkar - CR-20170221-10705 - 4/27/2017 - Commented out the code to by pass the auto population of Membership fields. - Ends here
                }
            }    
        }    
        
        //String variable to hold the error message string in case of any failure
        String logMessage = '';
            
        //Checking list for size value
        if(mapOfMemberships != null && mapOfMemberships.values().size() > 0) {
            
            //Bypassing trigger for a while
            Util.byPassAllTriggers = true;
            
            //Making a try to update the list of records and recording error messages will be emailed to the SFAdmin 
            logMessage = Util.createLog(Database.update((mapOfMemberships.values()),false));
            
            //Enabling trigger again
            Util.BypassAllTriggers = false;
        }
        
        //Checking errors log messages string for blank value and append it to final error message string only and only if it have proper value with it
        if(logMessage != '') 
            debugLogStr += logMessage;
    }
    
    //Finish method
    global void finish(Database.BatchableContext BC) {
    
        //Checking error string for blank value but if it does not have blank value with it then emailed it to SFAdmin.
        if(debugLogStr != '')
            Util.sendBatchStatus(BC.getJobId(), 'Batch_UpdateRIMemberHealthSnapshotFields', debugLogStr, Label.Salesforce_Admin_Email);
    
    	//Start from here
        //Start the next batch by kicking off a scheduled job
        //the reason we don't just piggyback 
        //Build the system time of now + 20 Seconds to schedule the batch apex.
        Datetime sysTime = System.now();
        sysTime = sysTime.addSeconds(20);
        String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        Sched_UpdateSolutionRelatedDataOnAccount schedCon = new Sched_UpdateSolutionRelatedDataOnAccount();
        
        //Schedule the next job, and give it the system time so name is unique
        if(!Test.isRunningTest())
            System.schedule('Sched_UpdateSolutionRelatedDataOnAccount' + sysTime.getTime(), chron_exp, schedCon);
        
    	//Upto here
    }
}