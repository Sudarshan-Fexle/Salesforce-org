/**
*   Purpose         :   This class is helper class for Trigger on Member Interactions.
*
*   Create By       :   Bhavi Sharma
*
*   Created Date    :   06/13/2013
*
*   Current Version :   v1.0
*
*   Revision Logs   :   v1.0 - Created - CR-20130228-2612
                        V_1.1 - Bhavi Sharma - 12/20/2013 - New method added(updateOpportunityELSSentCounter) - CR-20130925-3694
                        V_1.2 - 02/04/2014 - Bhavi Sharma - New methods added (UpdateInteractionInformationByContactIds) - CR-20140124-4353
                        V_1.3 - 04/18/2014 - Abhinav Sharma - New Method added (ValidateAndPopulateDataOnInteratcionRecords) - CR-20130730-3316
                        V_1.4 - Mahendra Swarnkar - CR-20160610-9915 - 08/27/2016 - Added new method "updateDateOfFirstELOnWarmLead"
						V_1.5 - Modified By Dipesh Gupta 03/04/2019 - CR-20190301-12905 - Updated the null checks - Method - updateProject
						V_1.6 - Modified By Dipesh Gupta 03/04/2019 - CR-20190529-13156 - Modified Record type name from 'SSC' to 'Tech'
**/
public without sharing class MemberInteractionTriggerHelper {
    /*Modified By Dipesh Gupta -CR-20190524-13152 - Date-06/14/2019*/
    /*
    //Method to populate lookup on MemberInteraction from associated Membership 
    public static void PopulateMemberInteractionData(List<Call__c> newMemberInteractions) {
        
        //Set for hold project Ids
        Set<Id> projectIds = new Set<Id>();
        
        //Loop through Trigger.new record
        for(Call__c memberInteraction : newMemberInteractions) {
            
            //Check MemberInteraction's Member__c value is not null
            if(memberInteraction.Member__c != null) {
                
                //add Project Id into set of Ids 
                projectIds.add(memberInteraction.Member__c);
            }
        } 
        
        //Check for size of ProjectIds set
        if(projectIds.size() > 0 ) {
                
            //Create a map instance of Key = ProjectId & Values = Project record
            Map<Id, Project__c> mapOfProjects = new Map<Id, Project__c>();
            
            //Loop through Projects list
            for(Project__c project : [SELECT Id, Primary_Paid_Membership__c, Primary_Paid_Membership__r.Account_Name__c FROM Project__c 
                                            WHERE Id IN:projectIds]) {
                
                //put Project record into map
                mapOfProjects.put(project.Id, project);
            }
            
            //check for mapOfProjects size
            if(mapOfProjects.size() > 0) {
                
                //Loop through Trigger.new record
                for(Call__c memberInteraction : newMemberInteractions) {
                    
                    //Check for mapOfProjects contains memberInteraction's project
                    if(mapOfProjects.containsKey(memberInteraction.Member__c )){
                        
                        memberInteraction.Institution__c = mapOfProjects.get(memberInteraction.Member__c).Primary_Paid_Membership__r.Account_Name__c;
                        memberInteraction.Membership__c = mapOfProjects.get(memberInteraction.Member__c).Primary_Paid_Membership__c;
                    }
                }
            }
        }
    }
    
    //Added By - Abhinav Sharma - 04/18/2014 - CR-20130730-3316 - Review MI field "Date in Last"
    /**
     *  @description    :   This method is to update the Call_Date__c on Interaction on the basis of below written logic:-
     *                      If Call_Date__c  is within the last 365 days then 
     *                           Date_in_Past_Year_Counter__c = 1,
     *                      If Call_Date__c is not within the last 365 days then 
     *                           Date_in_Past_Year_Counter__c = 0,
     *
     *  @args           :   List<Call__c> newMemberInteractions 
     *
     *  @return         :   void
     *
    **
    public static void ValidateAndPopulateDataOnInteratcionRecords(List<Call__c> newMemberInteractions) {
        
        //Loop through list of membersh Interaction records
        for(Call__c mI : newMemberInteractions) {
            
            //Checking for Call Date field value (Proceed further only and only if it is having not null value with it)
            if(mI.Call_Date__c != null) {
                
                //If Call_Date__c  is within the last 365 days then setting Date_in_Past_Year_Counter__c = 1 otherwise 0
                //If Call_Date__c is in future then no value will be set for the field
                if(mI.Call_Date__c > System.today()) {
                    mI.Date_in_Past_Year_Counter__c = null;
                } else {
                    //Checking for status field value and if exist then excluding "Cancelled" or "Void - Delete" values
                    if(String.isBlank(mI.Current_Status__c) || (mI.Current_Status__c != 'Cancelled' && mI.Current_Status__c != 'Void - Delete')) {
                        if(mI.Call_Date__c >= System.today().addDays(-365))
                            mI.Date_in_Past_Year_Counter__c = 1;
                        else
                            mI.Date_in_Past_Year_Counter__c = 0;
                    } else {
                        mI.Date_in_Past_Year_Counter__c = null;
                    }
                }
            } else {
                mI.Date_in_Past_Year_Counter__c = null;
            }
        }
    }
    
    //Commented of_els_sent__c (Commented below method for the same) - By Mahendra Swarnkar - spring clean up - 04/29/2019
    /**
     *  @description    :   This method is to update the ELS Sent counter on Parent Opportunities
     *
     *  @args           :   List of new member interactions, Map of old membership interactions
     *
     *  @return         :   void
     *
     ** 
    public static void updateOpportunityELSSentCounter(List<Call__c> newMemberInteractions, Map<Id, Call__c> mapOldMemberInteractions ) {
        /*
        //Set to hold the Opportunity Ids where # of ELS Sent to be updated
        Set<Id> oppIds = new Set<Id>();
        
        //Loop through the records
        //Insert scenario
        if(newMemberInteractions != null && mapOldMemberInteractions == null) {
            
            //Loop through the records
            for(Call__c mI : newMemberInteractions) {
                
                //Check if insert case, then add opportunity in Set directly or in update scenario check if the Opportunity is changed of Status is changed
                if(mI.Opportunity__c != null && mI.Current_Status__c == Constants.MEMBER_INTERACTION_CURRENT_STATUS_COMPLETED)
                    oppIds.add(mI.Opportunity__c);
            }
        }
        
        //Update case
        if(newMemberInteractions != null && mapOldMemberInteractions != null) {
            
            //Loop through the records
            for(Call__c mI : newMemberInteractions) {
                
                //Check if insert case, then add opportunity in Set directly or in update scenario check if the Opportunity is changed of Status is changed
                if((mI.Opportunity__c !=  mapOldMemberInteractions.get(mI.Id).Opportunity__c) 
                    || ((mI.Current_Status__c == Constants.MEMBER_INTERACTION_CURRENT_STATUS_COMPLETED || mapOldMemberInteractions.get(mI.Id).Current_Status__c == Constants.MEMBER_INTERACTION_CURRENT_STATUS_COMPLETED) 
                        && mI.Current_Status__c != mapOldMemberInteractions.get(mI.Id).Current_Status__c)
                ) {
                    
                    //Add Opportunity Id in set
                    if(mI.Opportunity__c != null)
                        oppIds.add(mI.Opportunity__c);
                    if(mapOldMemberInteractions.get(mI.Id).Opportunity__c != null)
                        oppIds.add(mapOldMemberInteractions.get(mI.Id).Opportunity__c);  
                }
            }
        }
        
        //Delete Case
        if(newMemberInteractions == null && mapOldMemberInteractions != null) {
            
            //Loop through the records
            for(Call__c mI : mapOldMemberInteractions.values()) {
                
                //Check if insert case, then add opportunity in Set directly or in update scenario check if the Opportunity is changed of Status is changed
                if(mI.Opportunity__c != null && mI.Current_Status__c == Constants.MEMBER_INTERACTION_CURRENT_STATUS_COMPLETED)
                    oppIds.add(mI.Opportunity__c);
            }
        }
        
        //Check for the size and see if there are opprotunities to update
        if(oppIds.size() > 0) {
            
            //Create a list of Opportunities to be updated
            List<Opportunity> opportunities = new List<Opportunity>();
            
            //Set to hold the used opps
            Set<Id> usedOps = new Set<Id>();
            
            // Fetch count of all the Member Interactions grouped by OppId and Status = Completed
            for(AggregateResult aR : [Select Count(Id) cntELS, Opportunity__c oppId from Call__c where Opportunity__c != null 
                                                                            AND Current_Status__c =: Constants.MEMBER_INTERACTION_CURRENT_STATUS_COMPLETED
                                                                            AND Opportunity__c IN: oppIds Group by Opportunity__c]) {
                                                                                
                //Get the Opportunity Id
                Id oppId = (Id)aR.get('oppId');
                Integer totaolELS = (Integer)aR.get('cntELS');
                
                //Add in opportunity list
                opportunities.add(new Opportunity(Id = oppId, of_ELs_Sent__c = totaolELS));
                usedOps.add(oppId);
            }
            
            //Get the unused ids
            oppIds.removeAll(usedOps);
            
            //loop through the unused opps and set the counter to zero
            for(Id oppId : oppIds) {
                
                //Add in opportunity list
                opportunities.add(new Opportunity(Id = oppId, of_ELs_Sent__c = 0));
            }
            
            //Check if data to update
            if(opportunities.size() > 0) {
                
                //Bypass Triggers
                Util.BypassAllTriggers = true;
                update opportunities;
            }
        }
	
    }
    
    /**
     *  @description    :   This method is to update the Interaction infomration on Institution Role
     *
     *  @args           :   List of new Calls records, Map of old Calls 
     *
     *  @return         :   void
     *
     **/
    /*public static void UpdateInteractionInformation(List<Call__c> newCalls, Map<Id, Call__c> mapOldCalls) {
        
        //Create a set to hold teh contact Ids
        Set<Id> contactIds = new Set<Id>();
        
        //Check if Interaction information need to be updated
        //Insert Scenerio
        if(newCalls != null && mapOldCalls == null) {
            
            //Loop through the new Calls
            for(Call__c call : newCalls) {
                
                //Check for the Contact Id
                if(call.Contact__c != null && call.Institution__c != null && call.Call_Date__c != null) {
                    
                    //Add new contact Id
                    contactIds.add(call.Contact__c);
                }
            }
        } else if(newCalls != null && mapOldCalls != null) {
            //Update Scenerio   
            //Loop through the new Calls
            for(Call__c call : newCalls) {
                
                //Check for the Contact Id
                //if Contact__c, Institution__c or CallType changed
                if(call.Contact__c != null && call.Institution__c != null 
                    && (call.Contact__c != mapOldCalls.get(call.Id).Contact__c 
                        || call.Institution__c != mapOldCalls.get(call.Id).Institution__c
                        || call.Call_Date__c != mapOldCalls.get(call.Id).Call_Date__c)
                ) {
                    
                    //Add Old contact Id 
                    if(call.Contact__c != mapOldCalls.get(call.Id).Contact__c && mapOldCalls.get(call.Id).Contact__c != null)
                        contactIds.add(mapOldCalls.get(call.Id).Contact__c);
                    
                    //Add new contact Id
                    contactIds.add(call.Contact__c);
                }
            }
        } else if(newCalls == null && mapOldCalls != null) {
            //Delete Scenerio
            //Loop through the new Calls
            for(Call__c call : mapOldCalls.values()) {
                
                //Check for the Contact Id
                if(call.Contact__c != null && call.Institution__c != null && call.Call_Date__c != null) {
                    
                    //Add new contact Id
                    contactIds.add(call.Contact__c);
                }
            }
        }
        
        //Chekc if Institution Roles need to be updated
        if(contactIds.size() > 0)
             InstitutionRoleTriggerHelper.UpdateInteractionInformationByContactIds(null, contactIds, true);
    }*/
    
        
    /**
     *  @description    :   Method to populate the field "Date Of First EL" on warm lead record with "Completion Date" field value on the Member Interaction object 
     *                      (if more than one Member Interation records, the record with the earliest non-NULL Completion Date), if:-
                                a) Member Interaction should be associated with an Opportunity (Opportunity__c)
                                b) Member Interaction Record type is "Southwind EL Request"
                                c) "Completion Date" field is not NULL
     * 
     *  @args           :   List of new Calls records, Map of old Calls 
     *
     *  @return         :   void
     *
    **    
    public static void updateDateOfFirstELOnWarmLead(List<Call__c> newCalls, Map<Id, Call__c> mapOldCalls) {
                         
        //Get all record types on case object
        Map<String, Id> caseRecordTypesMap = Util.recordtypemap(Constants.OBJECT_MEMBER_INTERACTION);
        Id rTypes = caseRecordTypesMap.get(Constants.MEMBER_INTERACTION_RT_SOUTHWIND);
        
        //Check for record type 
        if(rTypes != null) {    
         
            //Set to hold Member Intraction Ids
            Set<Id> setOpportunityIds = new Set<Id>();
            
            //Loop over new MI Records
            for(Call__c mI : newCalls != null ? newCalls : mapOldCalls.values()) {
                
                //Insert use case
                if(newCalls != null && mapOldCalls == null && mI.RecordTypeId == rTypes && mI.Opportunity__c != null) 
                    setOpportunityIds.add(mI.Opportunity__c);
                
                //Update use case
                if(newCalls != null && mapOldCalls != null) {
                      
                    //Checking for the comment body/Is publised field change
                    if(mI.Opportunity__c != mapOldCalls.get(mI.Id).Opportunity__c 
                        || mI.Completion_Date__c != mapOldCalls.get(mI.Id).Completion_Date__c
                        || mI.RecordTypeId != mapOldCalls.get(mI.Id).RecordTypeId 
                    ) {
                        
                        //Checking for fields values in the new instances of the MI records
                        if(mI.Opportunity__c != null)
                            setOpportunityIds.add(mI.Opportunity__c);   
                            
                        //Checking for fields values in the new instances of the MI records 
                        if(mapOldCalls.containsKey(mI.Id) && mapOldCalls.get(mI.Id) != null
                            && mapOldCalls.get(mI.Id).Opportunity__c != null)
                            setOpportunityIds.add(mapOldCalls.get(mI.Id).Opportunity__c);  
                    } 
                }
                
                //Delete use case
                if(newCalls == null && mapOldCalls != null && mI.Opportunity__c != null 
                   && mI.RecordTypeId == rTypes && mI.Completion_Date__c != null)  
                    setOpportunityIds.add(mI.Opportunity__c);
            }
            
            //Check for set of OpportunityIds
            if(setOpportunityIds.size() > 0) {
                
                //List to Update Warm Lead Records
                Map<Id, Warm_Lead__c> mapWarmLeadsTOBeUpdated = new Map<Id, Warm_Lead__c>();
                
                //Fetching parent opportunity records details along with their children warm lead and Member interaction records 
                for(opportunity opp : [SELECT Id , 
                                        (SELECT Id, Completion_Date__c FROM Member_Interactions11__r 
                                            WHERE Completion_Date__c != null 
                                                AND Opportunity__c != null
                                                AND Opportunity__c IN : setOpportunityIds
                                                AND RecordTypeId != null
                                                AND RecordTypeId =: rTypes
                                                ORDER BY Completion_Date__c ASC LIMIT 1),
                                            (SELECT Id, Opportunity__c, Warm_Lead__c FROM Warm_Leads_MtM__r
                                                WHERE Warm_Lead__c != null 
                                                AND Opportunity__c != null
                                                AND Opportunity__c IN : setOpportunityIds)
                                        FROM Opportunity 
                                        WHERE Id IN: setOpportunityIds]) {

                    //Checking if warm lead MtMs exists under opportunity record(s)
                    if(opp.Warm_Leads_MtM__r != null && opp.Warm_Leads_MtM__r.size() > 0) {
                        
                        //Checking if "Member Interaction" records exists under "Opportunity" records
                        if(opp.Member_Interactions11__r != null && opp.Member_Interactions11__r.size() > 0) {
                            
                            //Loop through warm lead MtM children records
                            for(Warm_Lead_MtM__c wL : opp.Warm_Leads_MtM__r)
                                mapWarmLeadsTOBeUpdated.put(wL.Warm_Lead__c, new Warm_Lead__c(Id = wL.Warm_Lead__c, Date_Of_First_EL__c = opp.Member_Interactions11__r[0].Completion_Date__c)); 
                        
                        } else {
                            
                            //Loop through warm lead children records
                            for(Warm_Lead_MtM__c wLM : opp.Warm_Leads_MtM__r)
                                mapWarmLeadsTOBeUpdated.put(wLM.Warm_Lead__c, new Warm_Lead__c(Id = wLM.Warm_Lead__c, Date_Of_First_EL__c = null)); 
                        
                        }
                    }                
                }
                
                //Check for update warm lead list size
                if(mapWarmLeadsTOBeUpdated != null && mapWarmLeadsTOBeUpdated.values().size() > 0) {
            
                    //ByPass ALL trigger
                    Util.byPassAlltriggers = true;
                    
                    //update Lead warm records
                    update mapWarmLeadsTOBeUpdated.values();
                    
                    //Enabling trigger back
                    Util.byPassAlltriggers = false;
                }
            }
        }
    }
    
     /**
     *  @description    :   This method is used to update the Last Executive Update, Last Internal Check-in fields on the parent Projects. 
     * 
     *  @args           :   List<Call__c> newMemberIntractions, Map<Id, Call__c> oldMemberInteractionMap
     *
     *  @return         :   void
     * 
     *  Version Logs    :   V_1.1 - Added By Dipesh Gupta - 03/04/2019 - CR-20190301-12905 Updated the null checks.
     *
    **  
    public static void updateProjects(List<Call__c> newMemberIntractions, Map<Id, Call__c> oldMemberInteractionMap) {
      
        //Set to hold the Member Interaction Ids
        set<Id> setMemberInteractionIds = new set<Id>();
        
        //check for the member interaction list null case. 
        if(newMemberIntractions != null && newMemberIntractions.size() > 0) {
            
            //loop on the member interction. 
            for(Call__c memberInteraction : newMemberIntractions) {
        
                //Check for the new or specific update condition. 
                if(oldMemberInteractionMap == null || (oldMemberInteractionMap != null 
                 && (oldMemberInteractionMap.get(memberInteraction.Id).RecordTypeId != memberInteraction.RecordTypeId
                    || 
                    oldMemberInteractionMap.get(memberInteraction.Id).Call_Type__c != memberInteraction.Call_Type__c
                    ||
                    oldMemberInteractionMap.get(memberInteraction.Id).Call_Brief_Notes__c != memberInteraction.Call_Brief_Notes__c 
                    ||
                    oldMemberInteractionMap.get(memberInteraction.Id).Call_Date__c != memberInteraction.Call_Date__c 
                    )
                )) {
                  
                    //Filling set. 
                    setMemberInteractionIds.add(memberInteraction.Member__c);
                   
                    //Since the reparenting is false on the member__c field the project will not be changed. 
                    //We will not have the case of Project change. 
                }
            }
           
            //Map to hold the Project id with Date. Last Executive
            Map<Id, Date> mapLastExecutiveUpdate = new Map<Id, Date>();
            
            //Map to hold the Project id with Date. Last Interaction Check Ins
            Map<Id, Date> mapLastInteractionCheckIns = new Map<Id, Date>();
            
            //Strng to hold the record types. 
            Id MEMBER_INTERACTION_RECORD_TYPE_ID = Schema.SObjectType.Call__c.getRecordTypeInfosByName().get('Standard').getRecordTypeId();

            //Check for the set size. 
            if(setMemberInteractionIds.size() > 0) {   
            
                //List to hold the Projects. 
                List<Project__c> projectsToBeUpdated = new List<Project__c>();
                
                //CR-20190529-13156 - Modified Record type name from 'SSC' to 'Tech' - Dipesh Gupta - 09/05/2019
                //Query on the member Interaction. 
                for(Call__c memInteraction : [Select Id, Name, Call_Brief_Notes__c, RecordTypeId, Call_Type__c, Call_Date__c, Member__c From Call__c 
                                              Where Member__c IN: setMemberInteractionIds 
                                              AND Call_Date__c != null AND Member__r.RecordType.Name = 'Tech' Order By Member__c]) {
                  
                  //CR-20190301-12905 - Added the Null check for Call_Brief_Notes__c field. - Dipesh Gupta - 03/04/2019
                  if(String.isNotBlank(memInteraction.Call_Brief_Notes__c) && 
                     memInteraction.Call_Brief_Notes__c.containsIgnoreCase('Executive Update')) {
                          
                      //Check for the mem Interaction Conditions. 
                        if(!mapLastExecutiveUpdate.containsKey(memInteraction.Member__c))
                          mapLastExecutiveUpdate.put(memInteraction.Member__c, memInteraction.Call_Date__c);
                        else {
                          //Check - if next iteration has the earliest date then update the map with the earliest date. 
                            if(memInteraction.Call_Date__c > mapLastExecutiveUpdate.get(memInteraction.Member__c))
                              mapLastExecutiveUpdate.put(memInteraction.Member__c, memInteraction.Call_Date__c);                                  
                        }
                     }
                     //CR-20190301-12905 - Added the Null check for Call_Type__c field. - Dipesh Gupta - 03/04/2019                             
                     if(String.isNotBlank(memInteraction.Call_Type__c) 
                        && memInteraction.Call_Type__c.containsIgnoreCase('Internal Discussion')){
                        
                         /*Last Internal check Ins
                         if(memInteraction.RecordTypeId == MEMBER_INTERACTION_RECORD_TYPE_ID) {
                           
                             //Check for the mem Interaction Conditions. 
                            if(!mapLastInteractionCheckIns.containsKey(memInteraction.Member__c))
                                mapLastInteractionCheckIns.put(memInteraction.Member__c, memInteraction.Call_Date__c);
                            else {
                                //Check - if next iteration has the earliest date then update the map with the earliest date. 
                                if(memInteraction.Call_Date__c > mapLastInteractionCheckIns.get(memInteraction.Member__c))
                                    mapLastInteractionCheckIns.put(memInteraction.Member__c, memInteraction.Call_Date__c);                                  
                            }
                         }                                 
          }
                }                
                //Map to hold the Project with the Ids.
                Map<Id, Project__c> mapProjectToBeUpdated = new Map<Id, Project__c>();
                
                //Loop through the Maps. 
                for(Id proj : mapLastExecutiveUpdate.keyset()) {
                  mapProjectToBeUpdated.put(proj, new Project__c(Id = proj, Last_Executive_Update__c = mapLastExecutiveUpdate.get(proj), Last_Internal_Check_In__c = Null));  
                }
                
                //Loop through the Maps.
                for(Id proj : mapLastInteractionCheckIns.keyset()) {
                    
                    if(!mapProjectToBeUpdated.containsKey(proj))
                      mapProjectToBeUpdated.put(proj, new Project__c( Id = proj, Last_Internal_Check_In__c = mapLastInteractionCheckIns.get(proj)));
                    else
                        mapProjectToBeUpdated.get(proj).Last_Internal_Check_In__c = mapLastInteractionCheckIns.get(proj); 

                }
                                
                if(mapProjectToBeUpdated.size() > 0) {
                                        
                    Util.ByPassAllTriggers = true;
                      update mapProjectToBeUpdated.values();
                    Util.BypassAlltriggers = false;
                }
                    
            }
        }
    }*/
}