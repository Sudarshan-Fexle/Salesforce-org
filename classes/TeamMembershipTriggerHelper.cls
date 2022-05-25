/**
 *  Purpose         :   This class is to work as helper class for Team Membership Trigger
 * 
 *  Created By      :   Bhavi Sharma
 * 
 *  Created Date    :   03/31/2015  
 * 
 *  Revision Logs   :   V_1.0 - Created
 *                      V_1.1 - Modified By - Subhash Garhwal - 06/30/2015 - CR-20150618-9014
 *                      V_1.2 - Modified By - Abhinav Sharma - 10/14/2015 - CR-20151014-9322
 *                      V_1.3 - Modified By - Mahendra swarnkar - 2/11/2016 - CR-20151022-9348
 *                      V_1.4 - Modified By - Mahendra swarnkar - 03/16/2016 - CR-20150908-9224 - Added a new Method "updateInstitutionToReplicateSolutionData" to replicate the solution data on the Account and updated the "validateTeamMemberships" method to provide the uniqueness for the SA's 
 *                      V_1.6 - Modified By - Rajeev Jain -In test sandbox - 05/29/2016 - In order to conflict found with Release 50 CR 9224
 *                      V_1.7 - Modified By - Rajeev Jain - 04/20/2016 - CR-20151120-9402 - Added CreateIncentiveChangeLogs method 
 *                      V_1.8 - Modified By - Mahendra Swarnkar -09/09/2016 - CR-10078 
 *                      V_1.9 - Modified By - Subhash Garhwal - 11/07/2017 - Issue--CR11744--QA--00007311 - Added bypass logic to avoid SOQL limit issue (BYPASS_TEAMMEMBERSHIP_TRIGGER_FOR_MERGE)
 *                      V_2.0 - Modified By - Abhinav Sharma - 6/5/2018 - CR-20171211-11842 - Added 'populateStaffAssignmentRecordName' method.
                        V_2.1 - Modified By - Rajeev Jain - CR-20170812-11145 - Update the Active Institution field updateActiveInstitution
                        V_2.2 - Modified By - Dipesh Gupta - 01/03/2020 - Added a new method checkClonedStaffAssignmentAndUpdateSourceAndCloneRPP
 *                      V_2.3 - Modified By - Rajeev Jain - 02/17/2020 - CR-20190925-13366 -  Remove zzzSolution(Solution__c) field from updateInstitutionToReplicateSolutionData method.
                        V_2.3 - Modified By - Abhinav Sharma- 08/11/2020 - CR-20180808-12492 -  Commented Solution_Adopted__c,Solution_Ended__c,Solution_Status__c Field of account object
 *			V_2.4 - Modified By - Abhinav Sharma - CR-20200806-14405 - 08/26/2020 - Error In Update Program Collection record
 *			V_2.5 - Modified By - Saurabh Kumar - CR-20200819-14449 - 09/22/2020 - Added a new method populateEABEventFields from Staff Assignment(Team_Membership__c)
 *                      V_2.6 - Modified By - Saurabh Kumar - CR-20200821-14455 - 10/16/2020 - Added a new method associateRecentRegistrationWithStaffAssignment
 * 			V_2.7 - Modified By - Saurabh Kumar - CR-20210209-14888 - 02/09/2020 - associateRecentRegistrationWithStaffAssignment() method updated.
 * 			V_2.8 - Modified By - Chirag Soni - CR-20210308-14970 - 07/26/2021 - modified method updateRPPs - added check isupdateRPPsMethodExecutedOnce to bypass the recursive execution of method.
  * * 			V_2.9 - Modified By - Chirag Soni - CR-20210824-15376 - 10/27/2021 - updated the method associateRecentRegistrationWithStaffAssignment()
**/ 
public without sharing class TeamMembershipTriggerHelper {
    
    //Flag to contol the trigger execution 
    public static Boolean BYPASS_TEAMMEMBERSHIP_TRIGGER_FOR_MERGE = false;
    
    public static Boolean isMethodExecutedOnce = false;
    
    //Added By - Chirag Soni - CR-20210308-14970 - 07/26/2021
    public static Boolean isupdateRPPsMethodExecutedOnce = false;
    
    //Updated/Added - By Mahendra swarnkar - 03/16/2016 - CR-20150908-9224 - Starts from here
    //Added By Mahendra swarnkar - 2/11/2016 - CR-20151022-9348
    //Start from here
    //Constant Variable to hold the Staff Assignment record type "Opportunity_Staff_Assignments" developer Name
    Public static String StaffAssignmentRTypes_Opportunity = 'Opportunity_Staff_Assignments';
    Public static String StaffAssignmentRTypes_Membership = 'Membership';
    Public static String StaffAssignmentRTypes_Project = 'Project';
    //Updated/Added - By Mahendra swarnkar - 03/16/2016 - CR-20150908-9224 - Ends here    
    
    //Map to hold the Staff Assignment record types Developer name as key and record type Id as a value
    public static Map<String, Id> mapStaffAssignmentRecordTypes { 
        get{
            //check for mapStaffAssignmentRecordTypes
            if(mapStaffAssignmentRecordTypes == null){
                
                //Initializing the map
                mapStaffAssignmentRecordTypes = new Map<String, Id>();
                
                //Query for Staff Assignments record types and then populating map mapStaffAssignmentRecordTypes
                for(RecordType rt : [select Id, DeveloperName From RecordType where SobjectType = 'Team_Membership__c' AND IsActive = true]){
                    mapStaffAssignmentRecordTypes.put(rt.DeveloperName, rt.Id);    
                }
            }
            //Return map mapStaffAssignmentRecordTypes
            return mapStaffAssignmentRecordTypes;
        }
    }
    //Ends here    
    
    //V_1.5 - Added by  - Rajeev Jain - 04/20/2016 - CR-20151120-9402
    //Flag to By pass this method in order to run again
    public Static Boolean isByPassIncentiveChangeLogMethod = false;
    
    //Modified - By Mahendra swarnkar - 03/16/2016 - CR-20150908-9224 - To provide the uniqueness for the staff assignment records
    /**
     *  @description    :   This methiod is to validate the data before inserting into database. If there is any error, display error message to user.
     *
     *  @args           :   List of Team Memberships
     *
     *  @return         :   void
     *
    **/
    public static void validateTeamMemberships(List<Team_Membership__c> teamMemberships) {

        //Map to hold Unique Key (Staff_member__c + Role__c + Institution__c) and List of Staff Assignments
        Map<String, List<Team_Membership__c>> mapTMWithUK = new Map<String, List<Team_Membership__c>>();
    
        //Map to hold Unique Key (Staff_member__c + Role__c + Opportunity__c) and List of Staff Assignments
        Map<String, List<Team_Membership__c>> mapTMWith_UK_WithOpp = new Map<String, List<Team_Membership__c>>();
    
        //Map to hold Unique Key (Staff_member__c + Role__c + membership) and List of Staff Assignments
        Map<String, List<Team_Membership__c>> mapTMWith_UK_WithMemeberShip = new Map<String, List<Team_Membership__c>>();
    
        //Map to hold Unique Key (Staff_member__c + Role__c + project) and List of Staff Assignments
        Map<String, List<Team_Membership__c>> mapTMWith_UK_WithProject = new Map<String, List<Team_Membership__c>>();
    
        //Set to hold teh roles
        Set<Id> rolesIds = new Set<Id>();
    
        //Added By - Abhinav Sharma - 10/14/2015 - CR-20151014-9322 - Staff Assignment: Too many query rows: 50001
        //Start from here
        //Set to hold the institutions
        Set<Id> setInstitutionsIds = new Set<Id>();
    
        //Set to hold the staff members records
        Set<Id> setStaffMembersIds = new Set<Id>();
        //Upto here
    
        //Sets to hold the opportiunity/membership/project ids members records
        Set<Id> setOpportunityIds = new Set<Id>();
        Set<Id> setMemeberShipIds = new Set<Id>();
        Set<Id> setProjectIds = new Set<Id>();
    
        //String to hold the Error message shown on the UI
        String ERROR_MESSAGE = '';
    
        //Constructing unique key for the staff assignment records  
        //Loop through the roles
        for(Team_Membership__c tM : teamMemberships) {

            //01/05/2021 - CR-20200821-14455 - Victor Hanson - bypass for EAB Event record type
            if (tM.RecordTypeId == Constants.RECORD_TYPE_ID_EAB_EVENT_OF_STAFF_ASSIGNMENT) {
                continue;
            }
    
            //Generate Unique Key
            String uniqueKey = '';
    
            if(tM.Staff_member__c != null)
                uniqueKey += tM.Staff_member__c;
    
            if(tM.Role__c != null)
                uniqueKey += tM.Role__c;
    
            //check for the record type and accordingly create the unique key
            if(tM.RecordTypeId == mapStaffAssignmentRecordTypes.get(StaffAssignmentRTypes_Opportunity)
                && tm.Opportunity__c != null) {
                uniqueKey += tM.Opportunity__c;
    
            } else {
    
                if(tM.RecordTypeId == mapStaffAssignmentRecordTypes.get(StaffAssignmentRTypes_Membership)
                    && tm.Membership__c != null) {
                    uniqueKey += tM.Membership__c;
            
                } else{
                
                    if(tM.RecordTypeId == mapStaffAssignmentRecordTypes.get(StaffAssignmentRTypes_Project)
                        && tm.Project__c != null) {
                        uniqueKey += tM.Project__c;
                    
                    } else {
            
                        // for Default and assigned record types
                        if(tM.Institution__c != null)
                            uniqueKey += tM.Institution__c;
                    }
                }
            }
    
            //Temporary list to hold staff assignment records and this list will be used to check 
            //that the current record’s effective date will conflict with any existing one or not
            List<Team_Membership__c>  listTemporarySAs = new List<Team_Membership__c>() ;
    
            //Check if any new record has same unique key and accordingly populate the Error message 
            //string variable and also populate the temporary list for staff assignmment records 
            if(mapTMWithUK.containsKey(uniqueKey)){
            
                listTemporarySAs = mapTMWithUK.get(uniqueKey);
                ERROR_MESSAGE = Label.ERROR_UNIQUENESS_TEAM_MEMBERSHIP;
            
            } else {
    
                if(mapTMWith_UK_WithOpp.containsKey(uniqueKey)){
            
                    listTemporarySAs = mapTMWith_UK_WithOpp.get(uniqueKey);
                    ERROR_MESSAGE = Label.ERROR_UNIQUENESS_TEAM_MEMBERSHIP_WITH_OPPORTUNITY;    
                
                } else {
    
                    if(mapTMWith_UK_WithMemeberShip.containsKey(uniqueKey)){
                        
                        listTemporarySAs = mapTMWith_UK_WithMemeberShip.get(uniqueKey);
                        ERROR_MESSAGE = Label.ERROR_UNIQUENESS_TEAM_MEMBERSHIP_MEMBERSHIP;
                    
                    } else {
                        
                        if(mapTMWith_UK_WithProject.containsKey(uniqueKey)){
                            listTemporarySAs = mapTMWith_UK_WithProject.get(uniqueKey);
                            ERROR_MESSAGE = Label.ERROR_UNIQUENESS_TEAM_MEMBERSHIP_PROJECT;
                        }
                    }
                }
            }
    
            //Check for size
            if(listTemporarySAs.size() > 0) {
    
                //Loop through Staff Assignment
                for(Team_Membership__c exTM : listTemporarySAs) {
    
                    //Check for current record’s effective date if conflicting with any existing one
                    if((tM.End_date__c == null && exTM.End_date__c == null)
                        || (tM.End_date__c != null && exTM.End_date__c == null && tM.End_date__c >= exTM.Start_date__c)
                        || (tM.End_date__c == null && exTM.End_date__c != null && tM.Start_date__c <= exTM.End_date__c)
                        || (tM.Start_date__c <= exTM.End_date__c && tM.Start_date__c >= exTM.Start_date__c)
                        || (tM.End_date__c >= exTM.Start_date__c && tM.End_date__c <= exTM.End_date__c)
                        || (exTM.Start_date__c <= tM.End_date__c && exTM.Start_date__c >= tM.Start_date__c)
                        || (exTM.End_date__c >= tM.Start_date__c && exTM.End_date__c <= tM.End_date__c))
                        throw new CustomException(ERROR_MESSAGE);      
                }
    
                //Emptied the error message string 
                ERROR_MESSAGE = '';
    
                //Add Staff Assignment in there respective map
                if(mapTMWithUK.containsKey(uniqueKey)){
                    mapTMWithUK.get(uniqueKey).add(tM);
                } else {
                    if(mapTMWith_UK_WithOpp.containsKey(uniqueKey))
                        mapTMWith_UK_WithOpp.get(uniqueKey).add(tM);
                    else {
                        if(mapTMWith_UK_WithMemeberShip.containsKey(uniqueKey))
                            mapTMWith_UK_WithMemeberShip.get(uniqueKey).add(tM);
                        else {
                            if(mapTMWith_UK_WithProject.containsKey(uniqueKey))
                                mapTMWith_UK_WithProject.get(uniqueKey).add(tM);
                        }
                    }
                }
    
            } else {
    
                //Populate map
                if(tM.RecordTypeId == mapStaffAssignmentRecordTypes.get(StaffAssignmentRTypes_Opportunity)) {
                    mapTMWith_UK_WithOpp.put(uniqueKey, new List<Team_Membership__c> {tM});
                } else {
                    if(tM.RecordTypeId == mapStaffAssignmentRecordTypes.get(StaffAssignmentRTypes_Membership)) {
                        mapTMWith_UK_WithMemeberShip.put(uniqueKey, new List<Team_Membership__c> {tM});
                    } else {
                        if(tM.RecordTypeId == mapStaffAssignmentRecordTypes.get(StaffAssignmentRTypes_Project)) {
                            mapTMWith_UK_WithProject.put(uniqueKey, new List<Team_Membership__c> {tM});
                        } else {
                            mapTMWithUK.put(uniqueKey, new List<Team_Membership__c> {tM});
                        }
                    }
                }
            }
    
            //Adding roles in Set
            if(tM.Role__c != null)
                rolesIds.add(tM.Role__c);
    
            //Added By - Abhinav Sharma - 10/14/2015 - CR-20151014-9322 - Staff Assignment: Too many query rows: 50001
            //Start from here
            //Adding institution Ids into the set
            if(tM.Institution__c != null)
                setInstitutionsIds.add(tM.Institution__c);
    
            //Adding staff members Ids into the set
            if(tM.Staff_member__c != null)
                setStaffMembersIds.add(tM.Staff_member__c);
            //Upto here
    
            //Adding Opportunity Ids into the set
            if(tM.Opportunity__c != null)
                setOpportunityIds.add(tM.Opportunity__c);
    
            //Adding MemberShip Ids into the set
            if(tM.Membership__c != null)
                setMemeberShipIds.add(tM.Opportunity__c);
    
            //Adding Project Ids into the set
            if(tM.Project__c != null)
                setProjectIds.add(tM.Opportunity__c);    
        }
    
        // Modified By - Mahendra swarnkar - 03/16/2016 - CR-20150908-9224 - Starts from here
        //Modified By - Mahendra Swarnkar - 2/11/2016 - CR-20151022-9348 - Added additional filter 
        //criteria to fetch staff assignment records with RecordTypeId != Opportunity Staff Assignments.
        //Modified By - Abhinav Sharma - 10/14/2015 - CR-20151014-9322 - Added additional filter criteria's to reduce the exported records count
        //Query database to check if there is already a record with the same name
        if(rolesIds.size() > 0 && setStaffMembersIds.size() > 0 
            && (setInstitutionsIds.size() > 0 || setOpportunityIds.size() > 0 || setMemeberShipIds.size() > 0 || setProjectIds.size() > 0)) {
    
            for(Team_Membership__c tM : [Select Id,RecordTypeId, Staff_member__c, Start_date__c, End_date__c, Role__c, Institution__c, Opportunity__c, Membership__c,  Project__c
                            FROM Team_Membership__c 
                            where Role__c != null AND Role__c IN: rolesIds 
                            AND Staff_member__c != null AND Staff_member__c IN : setStaffMembersIds
                            AND ((Institution__c != null AND Institution__c IN : setInstitutionsIds) 
                            OR (Opportunity__c != null AND Opportunity__c IN : setOpportunityIds)
                            OR (Membership__c != null AND Membership__c IN : setMemeberShipIds)
                            OR (Project__c != null AND Project__c IN : setProjectIds))
                            AND ID NOT IN: teamMemberships]) {
    
                //Generate Unique Key
                String uniqueKey = '';
    
                if(tM.Staff_member__c != null)
                    uniqueKey += tM.Staff_member__c;
    
                if(tM.Role__c != null)
                    uniqueKey += tM.Role__c;
    
                //check for the record type and accordingly create the unique key
                if(tM.RecordTypeId == mapStaffAssignmentRecordTypes.get(StaffAssignmentRTypes_Opportunity)
                    && tm.Opportunity__c != null) {
                    uniqueKey += tM.Opportunity__c;
    
                } else {
                    
                    if(tM.RecordTypeId == mapStaffAssignmentRecordTypes.get(StaffAssignmentRTypes_Membership)
                        && tm.Membership__c != null) {
                        uniqueKey += tM.Membership__c;
                    
                    } else {
    
                        if(tM.RecordTypeId == mapStaffAssignmentRecordTypes.get(StaffAssignmentRTypes_Project)
                            && tm.Project__c != null) {
                            uniqueKey += tM.Project__c;
                        
                        } else {
                            if(tM.Institution__c != null)
                                uniqueKey += tM.Institution__c;
                        }
                    }
                }
    
                //Temporary list to hold staff assignment records and this list will be used to check that the current record’s effective date will conflict with any existing one or not
                List<Team_Membership__c>  listTemporarySAs = new List<Team_Membership__c>() ;
    
                //Check if any new record has same unique key
                if(mapTMWithUK.containsKey(uniqueKey)){
                
                    listTemporarySAs = mapTMWithUK.get(uniqueKey);
                    ERROR_MESSAGE = Label.ERROR_UNIQUENESS_TEAM_MEMBERSHIP;
                
                } else {
    
                    if(mapTMWith_UK_WithOpp.containsKey(uniqueKey)){
                        listTemporarySAs = mapTMWith_UK_WithOpp.get(uniqueKey);
                        ERROR_MESSAGE = Label.ERROR_UNIQUENESS_TEAM_MEMBERSHIP_WITH_OPPORTUNITY;
                    } else {
                        if(mapTMWith_UK_WithMemeberShip.containsKey(uniqueKey)){
                            listTemporarySAs = mapTMWith_UK_WithMemeberShip.get(uniqueKey);
                            ERROR_MESSAGE = Label.ERROR_UNIQUENESS_TEAM_MEMBERSHIP_MEMBERSHIP;
                        } else {
                            if(mapTMWith_UK_WithProject.containsKey(uniqueKey)) {
                                listTemporarySAs = mapTMWith_UK_WithProject.get(uniqueKey);
                                ERROR_MESSAGE = Label.ERROR_UNIQUENESS_TEAM_MEMBERSHIP_PROJECT;
                            }
                        }
                    }
                }
    
                //Check if any new record has same unique key
                if(listTemporarySAs.size() > 0) {
    
                    //Loop through Staff Assignment
                    for(Team_Membership__c exTM : listTemporarySAs) {
    
                        //Check for current record’s effective date if conflicting with any existing one
                        if((tM.End_date__c == null && exTM.End_date__c == null)
                            || (tM.End_date__c != null && exTM.End_date__c == null && tM.End_date__c >= exTM.Start_date__c)
                            || (tM.End_date__c == null && exTM.End_date__c != null && tM.Start_date__c <= exTM.End_date__c)
                            || (tM.Start_date__c <= exTM.End_date__c && tM.Start_date__c >= exTM.Start_date__c)
                            || (tM.End_date__c >= exTM.Start_date__c && tM.End_date__c <= exTM.End_date__c)
                            || (exTM.Start_date__c <= tM.End_date__c && exTM.Start_date__c >= tM.Start_date__c)
                            || (exTM.End_date__c >= tM.Start_date__c && exTM.End_date__c <= tM.End_date__c))
                            throw new CustomException(ERROR_MESSAGE);      
                    }
                }
            }
        } 
    }
    
    //Added by - Subhash Garhwal - 06/30/2015 - CR-20150618-9014
    /**
     *  @description    :   This method is used to validate all the related Role Program Perspective records,
     *                      if Staff Assignments start or end date is changed.
     *
     *  @args           :   List<Team_Membership__c>, Map<Id, Team_Membership__c>
     *
     *  @return         :   void
     *
     **/
    public static void validateUpdate(List<Team_Membership__c> staffAssigns, Map<Id, Team_Membership__c> mapOldSAs) {
        
        //Set to hold Staff Assignment Ids
        Set<Id> setSAIds = new Set<Id>();
        
        //Loop through Staff Assignment list
        for(Team_Membership__c sA : staffAssigns) {
            
            //Check for Effective start and Effective End date
            if(sA.Start_date__c != mapOldSAs.get(sA.Id).Start_date__c || sA.End_date__c != mapOldSAs.get(sA.Id).End_date__c)                
                setSAIds.add(sA.Id);
        }
        
        //Check for set size
        if(setSAIds.size() > 0) {
            
            //List to update Role Program Perspective
            List<Role_Program_Perspective__c> rPPerspectives = new List<Role_Program_Perspective__c>();
            
            //Query through Role Program Perspective
            for(Role_Program_Perspective__c rPP : [Select Id, Staff_Assignment__c, Staff_Assignment__r.Start_date__c, 
                                                   Staff_Assignment__r.End_date__c,
                                                   Effective_Start__c, Effective_End__c From Role_Program_Perspective__c 
                                                   Where Staff_Assignment__c != null AND Staff_Assignment__c IN : setSAIds]) {
                
                //Check for Appropriate condition to update record
                if((rPP.Staff_Assignment__r.Start_date__c != null 
                    && (rPP.Effective_Start__c == null || rPP.Effective_Start__c < rPP.Staff_Assignment__r.Start_date__c))
                    || (rPP.Staff_Assignment__r.End_date__c != null 
                        && (rPP.Effective_End__c == null || rPP.Effective_End__c > rPP.Staff_Assignment__r.End_date__c))) {
                        
                    //Update Effective Start date
                    if(rPP.Staff_Assignment__r.Start_date__c != null && rPP.Effective_Start__c != null 
                       && (rPP.Effective_Start__c < rPP.Staff_Assignment__r.Start_date__c
                        ||  rPP.Effective_Start__c > rPP.Staff_Assignment__r.End_date__c))
                        rPP.Effective_Start__c = rPP.Staff_Assignment__r.Start_date__c;
                    
                    else if(rPP.Effective_Start__c == null)
                        rPP.Effective_Start__c = rPP.Staff_Assignment__r.Start_date__c;
                    
                    //Update Effective End date
                    if(rPP.Staff_Assignment__r.End_date__c != null && rPP.Effective_End__c != null 
                       && rPP.Effective_End__c > rPP.Staff_Assignment__r.End_date__c)
                        rPP.Effective_End__c = rPP.Staff_Assignment__r.End_date__c;
                    
                    else if(rPP.Effective_End__c == null)
                        rPP.Effective_End__c = rPP.Staff_Assignment__r.End_date__c;
                    
                    //Add Role Program Perspective record in list
                    rPPerspectives.add(rPP);                
                }                                               
            }
            
            //Check for list size
            if(rPPerspectives.size() > 0)
                update rPPerspectives;
        }
    }
    
    /**
     *  @description    :   This method is used to populate Program Perspective fields value with all related Role Program Perspectives
     *                      Short Name field, if Role Program Perspectives Effective End date >= today
     *
     *  @args           :   List<Team_Membership__c>
     *
     *  @return         :   void
     *
     **/
    //Modified by Abhinav Sharma - CR-20200806-14405 - 08/26/2020 - Error In Update Program Collection record (Comment method)
    /*public static void recalculateProgramPerspectives(List<Team_Membership__c> staffAssignments) {
        
        //Check for list size
        if(staffAssignments.size() > 0) {
            
            //Map to hold Staff Assignment Id as key and Program Perspective as value
            Map<Id, String> mapSAIdWithPP = new Map<Id, String>();
            
            //Set to hold Staff Assignment Id and Shot Name
            Set<String> setSAIdWIthSN = new Set<String>();
            
            //Query through Role Program Perspectives
            for(Role_Program_Perspective__c rPP : [Select Id, Staff_Assignment__c, Perspective_Short_Name__c 
                                                   From Role_Program_Perspective__c Where Staff_Assignment__c != null
                                                   AND Staff_Assignment__c IN : staffAssignments 
                                                   AND (Effective_End__c = null OR Effective_End__c >= TODAY) 
                                                   AND Perspective_Short_Name__c != null]) {
                
                //Check if map contains staff assinmentId 
                if(mapSAIdWithPP.containsKey(rPP.Staff_Assignment__c) 
                   && !setSAIdWIthSN.contains(rPP.Staff_Assignment__c + '-' + rPP.Perspective_Short_Name__c))
                    mapSAIdWithPP.put(rPP.Staff_Assignment__c, mapSAIdWithPP.get(rPP.Staff_Assignment__c) + ', ' + rPP.Perspective_Short_Name__c);
                else if(!setSAIdWIthSN.contains(rPP.Staff_Assignment__c + '-' + rPP.Perspective_Short_Name__c))
                    mapSAIdWithPP.put(rPP.Staff_Assignment__c, rPP.Perspective_Short_Name__c);                                      
                
                //Add values in set
                setSAIdWIthSN.add(rPP.Staff_Assignment__c + '-' + rPP.Perspective_Short_Name__c);
            }
            
            //Loop through Staff Assignment list
            for(Team_Membership__c sA : staffAssignments) {
                
                //Check if map contains Staff Assignment Id
                if(mapSAIdWithPP.containsKey(sA.Id))
                    sA.Program_Perspectives__c = mapSAIdWithPP.get(sA.Id);
                else
                    sA.Program_Perspectives__c = null;   
            }
            
            //Update
            update staffAssignments;    
        }
    }*/
    
    /**
     *  @description    :   This method is used to update all the related RPPs name, if SA name is changed.
     *
     *  @args           :   List<Team_Membership__c>, Map<Id, Team_Memebership__c>
     *
     *  @return         :   void
     *
     *  Revisions       : V_1.1 - Modified By - Chirag Soni - CR-20210308-14970 - 07/26/2021 - added check isupdateRPPsMethodExecutedOnce to bypass the recursive execution of method.
     **/
    
    public static void updateRPPs(List<Team_Membership__c> teamMemberships, Map<Id, Team_Membership__c> mapOldTMs) {
        
        //Modified By - Chirag Soni - CR-20210308-14970 - Check to bypass recursive execution of method
        if(isupdateRPPsMethodExecutedOnce) return;  
        
        isupdateRPPsMethodExecutedOnce = true; // Set to true for first execution.
        
        //Set to hold Staff Assignment Ids
        Set<Id> setSAIds = new Set<Id>();
        
        //Loop through Staff Assignments
        for(Team_Membership__c sA : teamMemberships) {
            
            //Check for appropriate condition to fire trigger
            if(sA.Name != mapOldTMs.get(sA.Id).Name || mapOldTMs == null)
                setSAIds.add(sA.Id);
        }
        
        //Check for set size
        if(setSAIds.size() > 0) {
            
            //List of Staff Assignment
            List<Team_Membership__c> teamMembershipsToUpdate = [Select Id, Staff_member__r.FirstName, 
                                                                Staff_member__r.LastName, Role__c,
                                                                Role__r.Name From Team_Membership__c 
                                                                Where Id IN : setSAIds];
            
            //Loop through Staff Assignment
            for(Team_Membership__c tM : teamMembershipsToUpdate){
                tM.Name = Util.parseNull(tM.Staff_member__r.FirstName) + ' ' + Util.parseNull(tM.Staff_member__r.LastName) + '-' + Util.parseNull(tM.Role__r.Name);
                tM.Name = tM.Name.left(80);
                system.debug('&&&&&' + tM.Name);
            }
                
            //Check for list size
            if(teamMembershipsToUpdate.size() > 0)
                update teamMembershipsToUpdate;
            
            //List of RPPs
            List<Role_Program_Perspective__c> rPPs = [Select Id, Staff_Assignment__c, Staff_Assignment__r.Name, 
                                                      Program_Perspective__c, Program_Perspective__r.Name 
                                                      From Role_Program_Perspective__c 
                                                      Where Staff_Assignment__c IN : setSAIds];
            
            //Loop through Role Program Perspective
            for(Role_Program_Perspective__c rPP : rPPs){
                rPP.Name = Util.parseNull(rPP.Staff_Assignment__r.Name) + '-' + Util.parseNull(rPP.Program_Perspective__r.Name);
                rPP.Name = rPP.Name.left(80);
                system.debug('@@@@@' + rPP.Name);
            }
            
            //Update RPPs to fire renaming workflow
            if(rPPs.size() > 0)
                update rPPs;
        }
    }
    
    //Added - By Mahendra swarnkar - 03/16/2016 - CR-20150908-9224 
    /**
     *  @description    :   This method is used to update all the related Institution(Acount) records to replicate the Solution data on the Institution(Acount).
     *
     *  @args           :   List<Team_Membership__c>, Map<Id, Team_Memebership__c>
     *
     *  @return         :   
     *
    **/
    public static void updateInstitutionToReplicateSolutionData(List<Team_Membership__c> teamMemberships, Map<Id, Team_Membership__c> mapOldTMs) {

        //Ensuring that there will be no multiple times execution of same logic in a single context
        if(!isMethodExecutedOnce) {
    
            //Set to hold the Account Ids
            Set<ID> setAccountIds = new Set<ID>();
    
            //Set to hold the SA Id value for whom "Role End" date value got changed
            Set<Id> setSAIds = new Set<Id>();
    
            //Loop through staff assignment records
            for(Team_Membership__c tm :teamMemberships) {
    
                //Insert use case
                if(mapOldTMs == null) {
    
                    if(tm.Institution__c != null) 
                        setAccountIds.add(tm.Institution__c);
                }
                
                //Update use case
                if(mapOldTMs != null) {
    
                    //Checking for field values changes
                    if(tm.Start_date__c != mapOldTMs.get(tm.Id).Start_date__c
                        || tm.Institution__c != mapOldTMs.get(tm.Id).Institution__c
                        || tm.Staff_member__c != mapOldTMs.get(tm.Id).Staff_member__c
                        || tm.Role__c != mapOldTMs.get(tm.Id).Role__c) {
    
                        if(tm.Institution__c != null) 
                            setAccountIds.add(tm.Institution__c);
    
                        if(mapOldTMs.get(tm.Id).Institution__c != null) 
                            setAccountIds.add(mapOldTMs.get(tm.Id).Institution__c);
                    }
    
                    //Checking if "Role End" field value got changed
                    if(tm.End_date__c != mapOldTMs.get(tm.Id).End_date__c) {
    
                        if(tm.Institution__c != null) 
                            setAccountIds.add(tm.Institution__c);
                        
                        setSAIds.add(tm.Id);
                    }
                }
            }
    
            //Checking for the size value
            if(setAccountIds.size() > 0) {
    
                //Collection helpful in further calculations    
                Map<Id, Account> mapOfAccount = new Map<Id, Account>();
                Map<Id, List<Team_Membership__c>> mapAccountIdWithSAs = new Map<Id, List<Team_Membership__c>>();
                Map<Id, Integer> mapAccountIdWithActiveSACount = new Map<Id, Integer>();
                Map<Id, Integer> mapAccountIdWithActiveARCount = new Map<Id, Integer>();
                Map<Id, Date> mapAcountIdwithSAEarliestRoleStart = new Map<Id, Date>();
                Map<Id, Date> mapAcountIdwithInactiveSALatestRoleStart = new Map<Id, Date>();
                Map<Id, Date> mapAcountIdwithSALatestRoleEnd = new Map<Id, Date>();
                Map<Id, Date> mapAcountIdwithInactiveSALatestRoleEnd = new Map<Id, Date>();
                
                //Modified by Mahendra Swarnkar - 05/05/2020 - CR-20200218-13769 - Solution_Partner__c deleted
                //Loop through Account records and retrieveing all the related details
                //Commented by Abhinav Sharma- 08/11/2020 - CR-20180808-12492 - Solution_Adopted__c,Solution_Ended__c,Solution_Status__c
                for(Account acc : [SELECT Id /*Solution_Adopted__c, Solution_Ended__c, Solution_Status__c,*/ /*Solution_Partner__c*/
                                    FROM Account
                                    WHERE ID IN : setAccountIds])
                    mapOfAccount.put(acc.Id, acc);
    
                //Modified by Mahendra Swarnkar - 05/05/2020 - CR-20200218-13769 - Solution_Partner__c deleted
                //Loop through staff assignment records
                for(Team_Membership__c tm : [SELECT Id, Start_date__c, End_date__c, Staff_member__c, Institution__c, Status__c,Staff_member__r.Name,
                                                Role__c, Role__r.Active__c, Role__r.Name
                                                /*Institution__r.Solution_Adopted__c, Institution__r.Solution_Ended__c,
                                                Institution__r.Solution_Status__c, *//*Institution__r.Solution_Partner__c*/
                                                FROM Team_Membership__c 
                                                WHERE Institution__c != null 
                                                    AND Institution__c IN : setAccountIds
                                                    AND Role__c != null
                                                    ORDER BY LastModifiedDate ASC]) {   
                    
                    if(tm.Role__r.Name == 'Solutions Executive') {
                     
                        //Populating map gto hold parent account ID as key and associated staff assignment records as value
                        if(!mapAccountIdWithSAs.containsKey(tm.Institution__c)){
                            mapAccountIdWithSAs.put(tm.Institution__c, new List<Team_Membership__c>{tm});
                        }
                        else{
                            mapAccountIdWithSAs.get(tm.Institution__c).add(tm);
                        }
                        
                        //Checking for "Inactive" status
                        if(tm.Status__c == 'Inactive') {
                            
                            //Checking for key presence in map and populating it with latest start date value for Active SA records
                            if(!mapAcountIdwithInactiveSALatestRoleStart.containsKey(tm.Institution__c))
                                mapAcountIdwithInactiveSALatestRoleStart.put(tm.Institution__c, tm.Start_date__c);
                            else {
                                if((mapAcountIdwithInactiveSALatestRoleStart.get(tm.Institution__c) == null 
                                    || (tm.Start_date__c > mapAcountIdwithInactiveSALatestRoleStart.get(tm.Institution__c))))
                                    mapAcountIdwithInactiveSALatestRoleStart.put(tm.Institution__c, tm.Start_date__c);
                            }
                            
                            //Checking for key presence in map and populating it with latest start date value for Active SA records
                            if(tm.Start_date__c > System.today()){
                                Continue; 
                            }else{
                                if(!mapAcountIdwithInactiveSALatestRoleEnd.containsKey(tm.Institution__c))
                                    mapAcountIdwithInactiveSALatestRoleEnd.put(tm.Institution__c, tm.End_Date__c);
                                else {
                                    if((mapAcountIdwithInactiveSALatestRoleEnd.get(tm.Institution__c) == null 
                                        || (tm.Start_date__c > mapAcountIdwithInactiveSALatestRoleEnd.get(tm.Institution__c))))
                                        mapAcountIdwithInactiveSALatestRoleEnd.put(tm.Institution__c, tm.End_Date__c);
                                }
                            }    
                        }                                    
                        
                        //Checking for key presence in map and populating it with earliest start date value for Active SA records
                        if(!mapAcountIdwithSAEarliestRoleStart.containsKey(tm.Institution__c))
                            mapAcountIdwithSAEarliestRoleStart.put(tm.Institution__c, tm.Start_date__c);
                        else {
                            if((mapAcountIdwithSAEarliestRoleStart.get(tm.Institution__c) == null 
                                || (tm.Start_date__c < mapAcountIdwithSAEarliestRoleStart.get(tm.Institution__c))))
                                mapAcountIdwithSAEarliestRoleStart.put(tm.Institution__c, tm.Start_date__c);
                        }
                           
                           //Checking for "Active" status
                           if(tm.Status__c == 'Active') {
                               
                               //Checking for key presence in map and populating it with latest End date value for Active SA records
                               if(!mapAcountIdwithSALatestRoleEnd.containsKey(tm.Institution__c))
                                   mapAcountIdwithSALatestRoleEnd.put(tm.Institution__c, tm.End_Date__c);
                               else {
                                   if((mapAcountIdwithSALatestRoleEnd.get(tm.Institution__c) == null 
                                       || (tm.End_Date__c > mapAcountIdwithSALatestRoleEnd.get(tm.Institution__c))))
                                       mapAcountIdwithSALatestRoleEnd.put(tm.Institution__c, tm.End_Date__c);
                               }
                               
                               //Populating map with appropriate key and value pair
                               if(!mapAccountIdWithActiveSACount.containsKey(tm.Institution__c))
                                   mapAccountIdWithActiveSACount.put(tm.Institution__c, 1);
                               else
                                   mapAccountIdWithActiveSACount.put(tm.Institution__c, (mapAccountIdWithActiveSACount.get(tm.Institution__c) + 1));
                           }
                           
                           //Checking if "Assignment Role" associated with SA records for that institution record are active
                           if(tm.Role__c != null && tm.Role__r.Active__c != null && tm.Role__r.Active__c == true) {
                               
                               //Populating map with appropriate key and value pair
                               if(!mapAccountIdWithActiveARCount.containsKey(tm.Institution__c))
                                   mapAccountIdWithActiveARCount.put(tm.Institution__c, 1);
                               else
                                   mapAccountIdWithActiveARCount.put(tm.Institution__c, (mapAccountIdWithActiveARCount.get(tm.Institution__c) + 1));
                           }       
                        
                    }
                }
                
                //Checking map for size value
                if(mapAccountIdWithSAs.keySet().size() > 0) {
                    
                    //Loop through map keyset and values
                    for(Id accId : mapAccountIdWithSAs.keySet()){
                        
                        //Map to hold solution staff values
                        Map<String, String> mapForSolutionStaff = new Map<String, String>();
                        
                        for(Team_Membership__c tMem : mapAccountIdWithSAs.get(accId)) {
    
                            //Checking if SA is Active
                            if(tMem.Role__c != null 
                                && tMem.Role__r.Active__c != null 
                                && tMem.Role__r.Active__c == true
                                && tMem.Institution__c != null
                                && mapOfAccount.containsKey(tMem.Institution__c)
                                && mapOfAccount.get(tMem.Institution__c) != null) {
                                
                                 //Commented by Abhinav Sharma- 08/11/2020 - CR-20180808-12492 - Solution_Adopted__c
                                //Setting "Solution Adopted" field value on institution
                               /* if(mapAcountIdwithSAEarliestRoleStart.containsKey(tMem.Institution__c) 
                                    && tMem.Role__r.Name != 'Solutions Executive') {
                                    if(mapOfAccount.get(tMem.Institution__c).Solution_Adopted__c == null)          
                                        mapOfAccount.get(tMem.Institution__c).Solution_Adopted__c = mapAcountIdwithSAEarliestRoleStart.get(tMem.Institution__c);
                                    else {
                                        if(mapOfAccount.get(tMem.Institution__c).Solution_Adopted__c != mapAcountIdwithSAEarliestRoleStart.get(tMem.Institution__c))        
                                            mapOfAccount.get(tMem.Institution__c).Solution_Adopted__c = mapAcountIdwithSAEarliestRoleStart.get(tMem.Institution__c);
                                    }
                                }*/
                                    
                                //Check for Staff Assignment status
                                if(tMem.Status__c == 'Active'){
                                    if(tMem.Role__r.Name != 'Solutions Executive' ){
                                    
                                        //Commented by Abhinav Sharma- 08/11/2020 - CR-20180808-12492 - Solution_Status__c 
                                        //Insert use Case 
                                        /*if(mapOldTMs == null ) {
                                            
                                            //Setting "Solution Status" field value on institution
                                            mapOfAccount.get(tMem.Institution__c).Solution_Status__c = System.Label.SOLUTION_PARTNER_STATUS_ACTIVE;
                                        } else {
                                            
                                            //Setting "Solution Status" field value on institution
                                            mapOfAccount.get(tMem.Institution__c).Solution_Status__c = System.Label.SOLUTION_PARTNER_STATUS_ACTIVE;
                                        }*/
                                        //Modified by Mahendra Swarnkar - 05/05/2020 - CR-20200218-13769 - Solution_Partner__c deleted
                                        //Setting "Solution Partner" field value on institution
                                        /*if(mapOfAccount.get(tMem.Institution__c).Solution_Partner__c != tMem.Staff_member__c)
                                            mapOfAccount.get(tMem.Institution__c).Solution_Partner__c =  tMem.Staff_member__c;*/
                                        
                                        //Commented by Abhinav Sharma- 08/11/2020 - CR-20180808-12492 - Solution_Adopted__c,Solution_Ended__c
                                        //Setting "Solution Ended" field value on institution
                                        /*if(mapAcountIdwithSALatestRoleEnd.containsKey(tMem.Institution__c)) {
                                            if(mapOfAccount.get(tMem.Institution__c).Solution_Ended__c == null)        
                                                mapOfAccount.get(tMem.Institution__c).Solution_Ended__c = mapAcountIdwithSALatestRoleEnd.get(tMem.Institution__c);
                                            else {
                                                if(mapOfAccount.get(tMem.Institution__c).Solution_Ended__c != mapAcountIdwithSALatestRoleEnd.get(tMem.Institution__c))        
                                                    mapOfAccount.get(tMem.Institution__c).Solution_Ended__c = mapAcountIdwithSALatestRoleEnd.get(tMem.Institution__c);
                                            }   
                                        }*/   
                                    }
                                    
                                    //Check for size
                                    if(mapForSolutionStaff.size() > 0 
                                        && mapForSolutionStaff.containsKey(tMem.Role__r.Name)){
                                        
                                        //Populating map for solution staff values
                                        if(String.isNotBlank(mapForSolutionStaff.get(tMem.Role__r.Name)) 
                                            && mapForSolutionStaff.get(tMem.Role__r.Name) != tMem.Staff_member__r.Name)
                                            mapForSolutionStaff.put(tMem.Role__r.Name, tMem.Staff_member__r.Name);
                                    } else{
                                        
                                        if(tMem.Staff_member__c != null 
                                            && (tMem.Role__r.Name == 'Solutions Partner' 
                                                || tMem.Role__r.Name == 'Solutions Executive')){
                                                mapForSolutionStaff.put(tMem.Role__r.Name, tMem.Staff_member__r.Name);              
                                        }
                                    }
                                }
                                //Commented by Abhinav Sharma- 08/11/2020 - CR-20180808-12492 - Solution_Adopted__c,Solution_Ended__c
                                /*else{
                                    if(tMem.Status__c == 'Inactive'
                                        && mapAcountIdwithInactiveSALatestRoleEnd.containsKey(tMem.Institution__c)
                                        && tMem.Role__r.Name != 'Solutions Executive'){
                                        
                                        //Setting "Solution Ended" field value on institution
                                        if(mapOfAccount.get(tMem.Institution__c).Solution_Ended__c == null)        
                                            mapOfAccount.get(tMem.Institution__c).Solution_Ended__c = mapAcountIdwithInactiveSALatestRoleEnd.get(tMem.Institution__c);
                                        else {
                                            if(mapOfAccount.get(tMem.Institution__c).Solution_Ended__c < mapAcountIdwithInactiveSALatestRoleEnd.get(tMem.Institution__c))        
                                                mapOfAccount.get(tMem.Institution__c).Solution_Ended__c = mapAcountIdwithInactiveSALatestRoleEnd.get(tMem.Institution__c);
                                        }   
                                    }
                                }*/
                            }
                        }
                        
                        //Setting the Solution Staff field value on the Institution
                        if(mapForSolutionStaff.size()>0){
                            String solutionStaffString= '';
                            for(String solutionStaff: mapForSolutionStaff.keySet()){
                                solutionStaffString = solutionStaffString + solutionStaff +': ' + mapForSolutionStaff.get(solutionStaff) +'\n';
                                
                            }
                        }
                    }    
    
                    //Loop through map keyset and values
                    for(Id accountId : mapAccountIdWithSAs.keySet()){
                        for(Team_Membership__c tMe : mapAccountIdWithSAs.get(accountId)) {
    
                            //Checking for presence of key in map
                            if(tMe.Role__r.Name != 'Solutions Executive' 
                                && !mapAccountIdWithActiveSACount.containsKey(tMe.Institution__c)) {
    
                                //Modified by Mahendra Swarnkar - 05/05/2020 - CR-20200218-13769 - Solution_Partner__c deleted
                                //Setting "Solution Partner" field value on institution
                                //mapOfAccount.get(tMe.Institution__c).Solution_Partner__c = null;
                                
                                //Commented by Abhinav Sharma- 08/11/2020 - CR-20180808-12492 - Solution_Adopted__c,Solution_Ended__c,Solution_Status__c 
                                //Checking for SA record Id on which "Role End" field got changed
                                /*if(setSAIds.contains(tMe.Id) && mapOfAccount.get(tMe.Institution__c) != null) {
                                    if(mapOfAccount.get(tMe.Institution__c).Solution_Ended__c < tMe.End_date__c) {
                                        mapOfAccount.get(tMe.Institution__c).Solution_Ended__c = tMe.End_date__c;
                                    }
                                }
                                
                                //Checking for SA record Id on which RoleStart date is grater that today and 
                                //blank out the  solution status field value on the institution.  
                                if(mapAcountIdwithInactiveSALatestRoleStart.containsKey(tMe.Institution__c) 
                                   && mapAcountIdwithInactiveSALatestRoleStart.get(tMe.Institution__c) > System.today() )
                                    mapOfAccount.get(tMe.Institution__c).Solution_Status__c = null;
                                else    
                                    mapOfAccount.get(tMe.Institution__c).Solution_Status__c = System.Label.SOLUTION_PARTNER_STATUS_FORMER;*/
                            }
                        }
                    }
                }
                
                //Check for size 
                if(mapOfAccount.values().size() > 0) {
                
                    //Modified By - Mahendra Swarnkar -09/09/2016 - CR-10078 - COmmented the "Trigger Bypass" statement only in order to populate the Solution Flag on the Institution.
                    //disable the all the triggers
                    //Util.BypassAllTriggers = true;
                    
                    //update the Accounts
                    update mapOfAccount.values();
                    
                    //Enable the all the triggers
                    //Util.BypassAllTriggers = false;
                }
            }        
        }
        
        //Setting flag value
        isMethodExecutedOnce = true;
    }
    
    //V_1.5 - Added By - Rajeev Jain - 04/20/2016 - CR-20151120-9402 - Added CreateIncentiveChangeLogs method
     /**
     *  @description    :   This method is used to create Incentive Change Log, whenever a new Staff Assignement records insert and Date Rand Modified
     *  
     *  @args           :   List<Program_Relationship__c>, map<Id, Program_Relationship__c>
     *
     *  @return         :   void
     *
     **/
    public static void incentiveChangeLog(List<Team_Membership__c> sAss, Map<Id, Team_Membership__c> mapOldSAss){
        /* 
        //List of Incentive Change logs
        List<Incentive_Change_Log__c> incentiveChangeLogs = new List<Incentive_Change_Log__c>();
        
        //Loop throughs SA records
        for(Team_Membership__c sA : sAss){
            
            //Check if Record is newly inserts
            if(mapOldSAss == null)
                incentiveChangeLogs.add(new Incentive_Change_Log__c(Staff_Assignment__c = sA.Id,
                                                                    Change_Type__c = ISSPConstants.INCENTIVE_CHANGE_LOG_CHANGE_TYPE_NEW,
                                                                    Change_Element__c = ISSPConstants.INCENTIVE_CHANGE_LOG_CHANGE_ElEMENT_STAFF_ASSIGNMENT));
            
            //Add new Incentive change log into list for update case
            else if(mapOldSAss != null && (sA.Start_date__c != mapOldSAss.get(sA.Id).Start_date__c || sA.End_date__c != mapOldSAss.get(sA.Id).End_date__c)) {
                    
                Incentive_Change_Log__c iCL = new Incentive_Change_Log__c(Staff_Assignment__c = sA.Id, 
                                                                          Change_Type__c = ISSPConstants.INCENTIVE_CHANGE_LOG_CHANGE_TYPE_MODIFIED,
                                                                          Change_Element__c = ISSPConstants.INCENTIVE_CHANGE_LOG_CHANGE_ElEMENT_STAFF_ASSIGNMENT);
                    
                //check for start date
                if(sA.Start_date__c != mapOldSAss.get(sA.Id).Start_date__c){
                    iCL.Start_Date__c = sA.Start_date__c;
                    iCL.Change_Value__c = ISSPConstants.INCENTIVE_CHANGE_LOG_CHANGE_VALUE_START_DATE;
                }
                
                //Check for end date 
                if(sA.End_date__c != mapOldSAss.get(sA.Id).End_date__c){
                    iCL.End_Date__c = sA.End_date__c;
                    iCL.Change_Value__c = ISSPConstants.INCENTIVE_CHANGE_LOG_CHANGE_VALUE_END_DATE;
                }
                
                //Add list 
                incentiveChangeLogs.add(iCL);
            }
        }
        isByPassIncentiveChangeLogMethod = true;
         //Check insertIcg Size
        if(incentiveChangeLogs.size() > 0)
            insert incentiveChangeLogs;
*/
    }
    
    /**
     *  @description    :   This method is used to populate staff assignment record name.
     *
     *  @args           :   List<Team_Membership__c>, Map<Id, Team_Memebership__c>
     *
     *  @return         :   void
     *
     **/ 
    public static void populateStaffAssignmentRecordName(List<Team_Membership__c> teamMemberships, Map<Id, Team_Membership__c> mapOldTMs) {
        
        //Set to hold Staff Assignment Ids
        Set<Id> setSAIds = new Set<Id>();
        
        //Loop through Staff Assignments
        for(Team_Membership__c sA : teamMemberships) {
            
            //Check for appropriate condition to fire trigger
            if(mapOldTMs == null || (mapOldTMs != null && (sA.Role__c != mapOldTMs.get(sA.Id).Role__c || sA.Staff_member__c != mapOldTMs.get(sA.Id).Staff_member__c )) )
                setSAIds.add(sA.Id);
        }
        
        //Check for set size
        if(setSAIds.size() > 0) {
            
            //List of Staff Assignment
            List<Team_Membership__c> teamMembershipsToUpdate = [Select Id, Staff_member__r.FirstName, 
                                                                Staff_member__r.LastName, Role__c,
                                                                Role__r.Name From Team_Membership__c 
                                                                Where Id IN : setSAIds];
            
            //Loop through Staff Assignment
            for(Team_Membership__c tM : teamMembershipsToUpdate){
                tM.Name = Util.parseNull(tM.Staff_member__r.FirstName) + ' ' + Util.parseNull(tM.Staff_member__r.LastName) + '-' + Util.parseNull(tM.Role__r.Name);
                tM.Name = tM.Name.left(80);
            }
                
            //Check for list size
            if(teamMembershipsToUpdate.size() > 0)
                update teamMembershipsToUpdate;
            
        }
    }
    
    
    /**
     *  @description    :   This method is used to Update the Active Institution on the staff Assignment.
     *
     *  @args           :   List<Team_Membership__c>
     *
     *  @return         :   void
     * 
     *  Created By      :   Added by Rajeev Jain - CR-20170812-11145 - Update the Active Institution field 

     *
     **/ 
    public static void updateActiveInstitution(List<Team_Membership__c> newStaffAssignments) {
    
        //Check for the New Assignment 
        if(newStaffAssignments != null){ 
        
            //Loop through the new Staff Assignment list. 
            for(Team_Membership__c teamMembership : newStaffAssignments) {    
                
                //Check for the Status of Staff Assignment is active
                if(teamMembership.Start_date__c <= Date.Today() && (teamMembership.End_date__c == null || teamMembership.End_date__c >= Date.Today()) ) {
                    teamMembership.Active_Institution__c = teamMembership.Institution__c;    
                }
                
                //Check if the End Date is less than today and Active institution is still Populated than Nullify
                if(teamMembership.End_date__c < Date.today() && teamMembership.Active_Institution__c != null )
                    teamMembership.Active_Institution__c = null;   
            }
        } 
    }
    
    
    //This method is a subsctitute of Edit role button finctionality work to make it LEX compatible. 
    public static void checkClonedStaffAssignmentAndUpdateSourceAndCloneRPP(List<Team_Membership__c> newStaffAssignments){
        
        //Boolean to check if the RPP clone needed.
        Boolean isRppCloneNeeded = false;
            
        //Map to hold the Staff assignments that needs an update.
        Map<Id, Team_Membership__c> mapStaffAssignmentToBeUpdated = new Map<Id, Team_Membership__c>();
        
        //Map to hold old with new Record . 
        Map<Id, Team_Membership__c> mapOldSourceStaffAssignmentWithNew = new Map<Id, Team_Membership__c>();
        
        String sourceId = '';
        
        //Check if the staff assignment is coming from the edit role functionality.
        for(Team_Membership__c staffAssignment : newStaffAssignments) {
            
            //Check field if they have values. 
            if(String.isNotBlank(staffAssignment.Source_Staff_Assignment__c)) {
                
                sourceId = staffAssignment.Source_Staff_Assignment__c;
                
                if(staffAssignment.Rpp_Clone_Needed__c == 'true')
                    isRppCloneNeeded = true;
                
                //Map only contains the instance of new as a value and Id of old as key
                mapOldSourceStaffAssignmentWithNew.put(staffAssignment.Source_Staff_Assignment__c, staffAssignment);
                
                mapStaffAssignmentToBeUpdated.put(staffAssignment.Source_Staff_Assignment__c, 
                                                  New Team_Membership__c(Id = staffAssignment.Source_Staff_Assignment__c, 
                                                                         End_date__c = staffAssignment.Start_date__c - 1, 
                                                                         Latest_Cloned_Staff_Assignment__c = staffAssignment.Id
                                                                        ));
            }
        }
        
        //Check if the Map size is not empty. 
        if(!mapStaffAssignmentToBeUpdated.isEmpty()) {
            
            //Updating the record. 
            update mapStaffAssignmentToBeUpdated.values();
            
            if(isRppCloneNeeded) {
                
                //SOQL String to  build dynamic query string for RPP
                String SOQL = 'Select ';
                
                //Sobject getDescribe method to fatch all the RPP fields and add fields in SOQL query string
                for(String rPPField : Role_Program_Perspective__c.getSobjectType().getDescribe().fields.getMap().KeySet())
                    SOQL +=  rPPField + ',';
                
                //Add Where clouse
                SOQL = SOQL.removeEnd(',') + ' From Role_Program_Perspective__c Where Staff_Assignment__c =\'' + sourceId + '\'';
                
                System.debug('SOQL===='+SOQL);
                
                
                //Query through RPP
                List<Role_Program_Perspective__c> rPPs = Database.query(SOQL);
                
                //Check for RPP list
                if(rPPs.size() > 0) {
                    
                    //Clone Role Program Perspective using Salesforce standard method deepClone
                    List<Role_Program_Perspective__c> clonedRPPs = rPPs.deepClone(false,true);
                        
                    //Loop through Clone RPPs list to assign RPP to new Staff Assignmet
                    for(Role_Program_Perspective__c rPP : clonedRPPs) {
                        
                        //Populate effective dates
                        rPP.Effective_Start__c = mapOldSourceStaffAssignmentWithNew.get(rPP.Staff_Assignment__c).Start_date__c;
                        rPP.Effective_End__c = mapOldSourceStaffAssignmentWithNew.get(rPP.Staff_Assignment__c).End_date__c;
                        
                        //Change Staff Assignment
                        rPP.Staff_Assignment__c = mapOldSourceStaffAssignmentWithNew.get(rPP.Staff_Assignment__c).Id;
                    }   
                    
                    //Insert cloned RPPs
                    insert clonedRPPs;
                }  
            }
        }
    }
    
    /**
     *  @description    :   This method is used to Update EAB Event fields(Coordinator, Event Manager, Onsite Manager)
     *
     *  @args           :   List<Team_Membership__c>, Map<Id, Team_Membership__c>
     *
     *  @return         :   void
     * 
     *  Created By      :   Added by Saurabh Kumar - CR-20200819-14449
     **/ 
    public static void populateEABEventFields(List<Team_Membership__c> newStaffAssignments, Map<Id, Team_Membership__c> mapOfOldAssignments){
        
        //Set to hold EAB Events' Ids
        Set<Id> eabEventIds = new Set<Id>();
        
        for(Team_Membership__c staffAssignment : newStaffAssignments != null ? newStaffAssignments : mapOfOldAssignments.values()){
           
            if(( (mapOfOldAssignments == null || newStaffAssignments == null) //Insert and delete check
                	&& staffAssignment.Staff_member__c != null && staffAssignment.Role__c != null && 
                	staffAssignment.EAB_Event__c != null && staffAssignment.RecordTypeId == Constants.RECORD_TYPE_ID_EAB_EVENT_OF_STAFF_ASSIGNMENT)
              || (mapOfOldAssignments != null && (
                  mapOfOldAssignments.get(staffAssignment.Id).Staff_member__c != staffAssignment.Staff_member__c
                  || mapOfOldAssignments.get(staffAssignment.Id).Role__c != staffAssignment.Role__c
                  || mapOfOldAssignments.get(staffAssignment.Id).EAB_Event__c != staffAssignment.EAB_Event__c
                  || (mapOfOldAssignments.get(staffAssignment.Id).RecordTypeId != staffAssignment.RecordTypeId
                     && (staffAssignment.RecordTypeId == Constants.RECORD_TYPE_ID_EAB_EVENT_OF_STAFF_ASSIGNMENT
                        || mapOfOldAssignments.get(staffAssignment.Id).RecordTypeId == Constants.RECORD_TYPE_ID_EAB_EVENT_OF_STAFF_ASSIGNMENT)
                     ))
                 )//Update check
              ){
                eabEventIds.add(staffAssignment.EAB_Event__c != null ? staffAssignment.EAB_Event__c : mapOfOldAssignments.get(staffAssignment.Id).EAB_Event__c);
            }
            
        }
        if(eabEventIds.size() == 0)
            return;
        TeamMembershipTriggerHelper.updateEABEventFields(eabEventIds, new Set<Id> ());
    }
    
    /**
     *  @description    :   This method hold logic to update the EAB Event field values
     *
     *  @args           :   Set<Id> eabEventIds, Set<Id> contactIdsToAvoid
     *
     *  @return         :   void
     * 
     *  Created By      :   Added by Saurabh Kumar - CR-20200819-14449
     **/ 
    public static void updateEABEventFields(Set<Id> eabEventIds, Set<Id> contactIdsToAvoid){
        
        //Collection to hold Assignment Role Name by EAB Event Id to avoid overridinand duplicacy
        Map<Id, Set<String>> assignmentRoleNamesByEABEventId = new Map<Id, Set<String>>();
        
        //Map to hold EAB Events which should be updated
        Map<Id, Advisory_Event__c> eabEventsToBeUpdated = new Map<Id, Advisory_Event__c>();
        
        for(Team_Membership__c staffAssignment : [Select Id, EAB_Event__c, Role__c, Role__r.Name, Staff_member__c,
                                    Staff_member__r.Employee_User_Record__c From Team_Membership__c Where EAB_Event__c IN : eabEventIds
                                    AND Staff_member__c != null AND Staff_member__r.Employee_User_Record__c != null
                                    AND Role__c != null AND EAB_Event__c != null AND Staff_member__c NOT IN : contactIdsToAvoid AND
                                    RecordTypeId =: Constants.RECORD_TYPE_ID_EAB_EVENT_OF_STAFF_ASSIGNMENT ORDER BY LastModifiedDate DESC]){
            
            if(!eabEventsToBeUpdated.containsKey(staffAssignment.EAB_Event__c))
            	eabEventsToBeUpdated.put(staffAssignment.EAB_Event__c, new Advisory_Event__c(Id = staffAssignment.EAB_Event__c,
                                                                                                Coordinator__c = null,
                                                                                                Event_Manager__c = null,
                                                                                                Onsite_Lead__c = null));
        	if(Constants.SET_OF_ASSIGNMENT_ROLE_NAMES.contains(staffAssignment.Role__r.Name)){
            	
                if(!assignmentRoleNamesByEABEventId.containsKey(staffAssignment.EAB_Event__c) || 
                   !assignmentRoleNamesByEABEventId.get(staffAssignment.EAB_Event__c).contains(staffAssignment.Role__r.Name) ){
                		
                       if(staffAssignment.Role__r.Name == Constants.ASSIGNMENT_ROLE_NAME_EVENT_COORDINATOR)
                       		eabEventsToBeUpdated.get(staffAssignment.EAB_Event__c).Coordinator__c = staffAssignment.Staff_member__r.Employee_User_Record__c;
                       else if(staffAssignment.Role__r.Name == Constants.ASSIGNMENT_ROLE_NAME_EVENT_MANAGER)
                           eabEventsToBeUpdated.get(staffAssignment.EAB_Event__c).Event_Manager__c = staffAssignment.Staff_member__r.Employee_User_Record__c;
                       else if(staffAssignment.Role__r.Name == Constants.ASSIGNMENT_ROLE_NAME_ONSITE_EVENT_MANAGER)
                           eabEventsToBeUpdated.get(staffAssignment.EAB_Event__c).Onsite_Lead__c = staffAssignment.Staff_member__r.Employee_User_Record__c;
                       
                       if(!assignmentRoleNamesByEABEventId.containsKey(staffAssignment.EAB_Event__c))
                           assignmentRoleNamesByEABEventId.put(staffAssignment.EAB_Event__c, new Set<String> ());
                       assignmentRoleNamesByEABEventId.get(staffAssignment.EAB_Event__c).add(staffAssignment.Role__r.Name);
                }
            }
      	}
        if(eabEventsToBeUpdated.size() > 0){
            Util.byPassAllTriggers = true;
            update eabEventsToBeUpdated.values();
            Util.byPassAllTriggers = false;
        }
    }
    /**
     *  @description    :   This method is used to create Registration record according to below mentioned schenario -
     *                      On Insert / Update -
     *                      1. If there is already a Registration created for the related Contact (Staff_Member__c). 
     *                         If so, update the Staff Assignment's Registration lookup to reference the existing Registration
     *                      2. If no Registration exists for the Staff Assignment's Contact, create a new Registration
     *                         Once the registration is created, update Staff Assignment.Registration with the RegistrationId
     * 
     *                      On Delete -
     *                      1. If no other Staff Assignments exist on the EAB Event for that Contact
     *                      Get the Registration for that Contact & EAB Event — Update the Status = Cancelled
     *                      2. If at least one other Staff Assignment still exists on the EAB Event for that Contact
     *                      no additional action is required
     *
     *
     *  @args           :   List<Team_Membership__c>, Map<Id, Team_Membership__c>
     *
     *  @return         :   void
     * 
     *  Created By      :   V1.0 Added by Saurabh Kumar - 10/16/2020 - CR-20200821-14455
     * 			:   V1.1 - Updated by - Saurabh Kumar - 02/09/2020 - CR-20210209-14888: Updated list variable (registrationsToUpdate) to map variable to avoid duplicate Id in the list error.
     *   		:   V1.2 - Updated by - Chirag Soni - 10/27/2021 - CR-20210824-15376 - updated the method - If a staff assignment is added to a cohort record, do not create an internal registration record. 
     **/ 
    public static void associateRecentRegistrationWithStaffAssignment(List<Team_Membership__c> newStaffAssignments, Map<Id, Team_Membership__c> mapOfOldAssignments){
        
        //Set to hold EAB Events' Ids in case of Insert / Update Staff Assignment
        Set<Id> eabEventIds = new Set<Id>();
        
        //Set to hold EAB Events' Ids in case of Deletion Staff Assignment
        Set<Id> eabEventIdsToDeleteSA = new Set<Id>();
        
        //Set to hold Staff Members' Ids in case of Insert / Update Staff Assignment
        Set<Id> staffMemberIds = new Set<Id>();
        
        //Set to hold Staff Members' Ids in case of Deletion Staff Assignment
        Set<Id> staffMemberIdsToDeleteSA = new Set<Id>();
		
        //V1.1 Updated by Saurabh Kumar - 02/09/2020 - CR-20210209-14888: Updated list variable (registrationsToUpdate) to map variable to avoid duplicate Id in the list error.
        //To hold registration records to update status
        Map<Id, Registration__c> registrationsToUpdate = new Map<Id, Registration__c>();

        for(Team_Membership__c staffAssignment : newStaffAssignments != null ? newStaffAssignments : mapOfOldAssignments.values()){
           
            if(( (mapOfOldAssignments == null || newStaffAssignments == null) //Insert and delete check
                	&& staffAssignment.Staff_member__c != null && staffAssignment.Role__c != null && 
                	staffAssignment.EAB_Event__c != null && staffAssignment.RecordTypeId == Constants.RECORD_TYPE_ID_EAB_EVENT_OF_STAFF_ASSIGNMENT)
              || (mapOfOldAssignments != null && (
                  mapOfOldAssignments.get(staffAssignment.Id).Staff_member__c != staffAssignment.Staff_member__c
                  || mapOfOldAssignments.get(staffAssignment.Id).Role__c != staffAssignment.Role__c
                  || mapOfOldAssignments.get(staffAssignment.Id).EAB_Event__c != staffAssignment.EAB_Event__c
                  || (mapOfOldAssignments.get(staffAssignment.Id).RecordTypeId != staffAssignment.RecordTypeId
                     && (staffAssignment.RecordTypeId == Constants.RECORD_TYPE_ID_EAB_EVENT_OF_STAFF_ASSIGNMENT
                        || mapOfOldAssignments.get(staffAssignment.Id).RecordTypeId == Constants.RECORD_TYPE_ID_EAB_EVENT_OF_STAFF_ASSIGNMENT)
                     ))
                 )//Update check
              ){
                  if(newStaffAssignments != null){ //Insert and update check
                      eabEventIds.add(staffAssignment.EAB_Event__c);
                      staffMemberIds.add(staffAssignment.Staff_member__c);
                  }else{ //Delete check
                      eabEventIdsToDeleteSA.add(staffAssignment.EAB_Event__c);
                      staffMemberIdsToDeleteSA.add(staffAssignment.Staff_member__c);
                  }
              }
        }
        //Check for EAB Event Ids & Staff Member Ids (In Insert and Update)
        if(eabEventIds.size() > 0 && staffMemberIds.size() > 0){
            
            //Added By - Chirag Soni - CR-20210824-15376 - Added the map to hold EAB event 
            Map<Id, Advisory_Event__c> mapOfEABEventOnIds = new Map<Id, Advisory_Event__c>([Select Id, RecordTypeId From Advisory_Event__c Where Id In : eabEventIds]);
            
            //To hold contact with their Registration records
            Map<Id,Contact> mapOfContactWithRegistrations = new Map<Id,Contact>(
                [SELECT ID, NAME, (SELECT ID, NAME FROM Registrations__r 
                                   WHERE RecordTypeId =: Constants.REGISTRATION_RECORD_TYPE_ID_INTERNAL_ATTENDEE 
                                   AND EAB_Event__c IN : eabEventIds AND Contact__c IN : staffMemberIds
                                   /*AND Status__c =: Constants.STATUS_REGISTERED*/ ORDER BY LastModifiedDate DESC LIMIT 1) 
                                   FROM Contact WHERE Id IN :staffMemberIds]);
            
            //Check for null // Insert / Update 
            if(newStaffAssignments != null && mapOfContactWithRegistrations != null){
                
                //To hold Staff Member Id with registration to create and bind to Staff Member record 
                Map<Id,Registration__c> registrationByStaffMemberId = new Map<Id,Registration__c>();
                //To hold Staff Assignment (Staff Member) for which registartion record not found & need to create
                List<Team_Membership__c> staffAssignmentWithoutRegistration = new List<Team_Membership__c>();
                
                for(Team_Membership__c newStaffAssignment : newStaffAssignments){
                    //If Registration created for the related Contact (Staff_Member__c). 
                    //If so, update the Staff Assignment's Registration lookup to reference the existing Registration
                    if(mapOfContactWithRegistrations.containsKey(newStaffAssignment.Staff_member__c)){
                        if(mapOfContactWithRegistrations.get(newStaffAssignment.Staff_member__c).Registrations__r.size() == 1){
                            Registration__c recentRegistration = mapOfContactWithRegistrations.get(newStaffAssignment.Staff_member__c).Registrations__r;
                            recentRegistration.Status__c = Constants.STATUS_REGISTERED;
                            recentRegistration.Cancellation_Reason__c = null;
                            registrationsToUpdate.put(recentRegistration.Id, recentRegistration);
                            newStaffAssignment.Registration__c = recentRegistration.Id;
                        }
                        else{
                            //If no Registration exists for the Staff Assignment's Contact, create a new Registration
                            //Once the registration is created, update Staff Assignment.Registration with the RegistrationId
                            //Modified By - Chirag Soni - CR-20210824-15376 - 10/27/2021 - Added the check to not create Registrations for Cohort Events
                            if(mapOfEABEventOnIds!=null && !registrationByStaffMemberId.containsKey(newStaffAssignment.Staff_member__c) 
                               && mapOfEABEventOnIds.values().size()>0 && mapOfEABEventOnIds.get(newStaffAssignment.EAB_Event__c).RecordTypeId != null
                               && mapOfEABEventOnIds.get(newStaffAssignment.EAB_Event__c).RecordTypeId != Constants.RECORD_TYPE_ID_ADV_EVENT_COHORT){
                                registrationByStaffMemberId.put(newStaffAssignment.Staff_member__c, 
                                                                new Registration__c(RecordTypeId = Constants.REGISTRATION_RECORD_TYPE_ID_INTERNAL_ATTENDEE, 
                                                                                    Contact__c = newStaffAssignment.Staff_member__c, EAB_Event__c = newStaffAssignment.EAB_Event__c,
                                                                                    Status__c = Constants.STATUS_REGISTERED));
                            }
                            staffAssignmentWithoutRegistration.add(newStaffAssignment);
                        }
                    }
                }
                //Check for null & size
                if(registrationByStaffMemberId != null && registrationByStaffMemberId.size() > 0 && staffAssignmentWithoutRegistration.size() > 0){
                    try{
                        //Insert Dml
                    	insert registrationByStaffMemberId.values();
                    }catch(Exception e){}
                    
                    for(Team_Membership__c staffAssignmentToAssociate : staffAssignmentWithoutRegistration){
                        //Once the registration is created, update Staff Assignment.Registration with the RegistrationId
                        if(registrationByStaffMemberId.containsKey(staffAssignmentToAssociate.Staff_member__c)){
                            staffAssignmentToAssociate.Registration__c = registrationByStaffMemberId.get(
                                staffAssignmentToAssociate.Staff_member__c).Id;
                        }
                    }
                }
            }
        }  
        //Check for EAB Event Ids & Staff Member Ids (In Delete)
        if(eabEventIdsToDeleteSA.size() > 0 && staffMemberIdsToDeleteSA.size() > 0){
            
            //To hold contact with their Registration records
            Map<Id,Contact> mapOfContactWithRegistrations = new Map<Id,Contact>(
                [SELECT ID, NAME, (SELECT ID, NAME FROM Registrations__r 
                                   WHERE RecordTypeId =: Constants.REGISTRATION_RECORD_TYPE_ID_INTERNAL_ATTENDEE 
                                   AND EAB_Event__c != null AND EAB_Event__c IN : eabEventIdsToDeleteSA 
                                   AND Status__c =: Constants.STATUS_REGISTERED ORDER BY LastModifiedDate DESC LIMIT 1) FROM Contact WHERE Id IN : staffMemberIdsToDeleteSA]);
            
            //To hold contact with their Staff Assignment records
            Map<Id,Contact> mapOfContactWithStaffAssignments = new Map<Id,Contact>(
                [SELECT ID, NAME, (SELECT ID, NAME FROM Staff_Assignments__r 
                                   WHERE RecordTypeId =: Constants.RECORD_TYPE_ID_EAB_EVENT_OF_STAFF_ASSIGNMENT 
                                   AND EAB_Event__c != null AND EAB_Event__c IN : eabEventIdsToDeleteSA
                                   ORDER BY LastModifiedDate DESC LIMIT 2) FROM Contact WHERE Id IN : staffMemberIdsToDeleteSA]);
            
            if(newStaffAssignments == null && mapOfContactWithStaffAssignments != null){
                
                for(Team_Membership__c staffAssignmentToDelete : mapOfOldAssignments.values()){
                    
                    //To hold registration records to update status to Cancelled
                    //If no other Staff Assignments exist on the EAB Event for that Contact
                    if(mapOfContactWithStaffAssignments.containsKey(staffAssignmentToDelete.Staff_member__c)
                       && mapOfContactWithStaffAssignments.get(staffAssignmentToDelete.Staff_member__c).Staff_Assignments__r.size() == 1){
                           if(mapOfContactWithRegistrations.get(staffAssignmentToDelete.Staff_member__c).Registrations__r.size() == 1){
                               Registration__c recentRegistration = mapOfContactWithRegistrations.get(staffAssignmentToDelete.Staff_member__c).Registrations__r;
                               recentRegistration.Status__c = Constants.STATUS_CANCELLED;
                               recentRegistration.Cancellation_Reason__c = Constants.CANCELLED_REASON;
                               registrationsToUpdate.put(recentRegistration.Id, recentRegistration) ; 
                           }
                       }
                }
            }
        }
        //Update Dml
        if(registrationsToUpdate.size() > 0){
            Util.BypassAllTriggers = true;
            update registrationsToUpdate.values();
            Util.BypassAllTriggers = false;
        }

    }
}