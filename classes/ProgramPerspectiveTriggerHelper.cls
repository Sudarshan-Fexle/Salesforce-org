/**
 *  Description     :  Helper class for Trigger_ProgramPerspective trigger.
 *
 *  Created By      :  Subhash Garhwal
 *
 *  Created Date    :  06/25/2015
 *
 *  Revision Logs   :   V_1.0 - Created - Subhash Garhwal - CR-20150618-9014            
 *                      V_1.1 - Code Added - Padmesh Soni - 08/04/2015 - CR-20150729-9114 - New createIncentiveChangeLog method added
 *                      V_1.2 - Code Added  - Padmesh Soni - 08/12/2015 - CR-20150729-9114 - New renameCPC method added.
 *                      V_1.3 - Modified - Rajeev Jain - CR-20151120-9402 - 04/19/2016 - Removed the usage of createIncentiveChangeLog method
 *                      V_1.4 - Modified - Abhinav Sharma - CR-20200806-14405 - 08/26/2020 - Error In Update Program Collection record
 *                                                      
 **/
public without sharing class ProgramPerspectiveTriggerHelper {
    
    //List to hold Staff Assignments
    //This list is to Summarize RPPs on Staff Assignments when, Staff Assignment is deleted
    public static List<Team_Membership__c> teamMemberships;
        
    /**
     *  @description    :   Method to check Program Group and Perspective combination.
     *
     *  @args           :   List<Program_Perspective__c>, Map<Id, Program_Perspective__c>
     *
     *  @return         :   void
     *
     **/
    public static void validateProgramPerspective(List<Program_Perspective__c> programPerspectives, Map<Id, Program_Perspective__c> mapOldPPerspectives) {
        
        //Map to hold Unique Name (Program_Group__c + Perspective_c) as key and List of new Program Perspectives
        Map<String, List<Program_Perspective__c>> mapPPerspectivesWithUniqueName = new Map<String, List<Program_Perspective__c>>(); 
        
        //Loop through Program Perspective
        for(Program_Perspective__c pP : programPerspectives) {
            
            //Check for appropriate condition
            if(pP.Unique_Name__c != null && (mapOldPPerspectives == null || pP.Program_Group__c != mapOldPPerspectives.get(pP.Id).Program_Group__c
                || pP.Perspective__c != mapOldPPerspectives.get(pP.Id).Perspective__c || pP.Effective_Start__c != mapOldPPerspectives.get(pP.Id).Effective_Start__c
                || pP.Effective_End__c != mapOldPPerspectives.get(pP.Id).Effective_End__c)) {
                
                //Check for already contained Unique Name
                if(mapPPerspectivesWithUniqueName.containsKey(pP.Unique_Name__c)) {
                    
                    //Loop through Program Perspectives records
                    for(Program_Perspective__c exiPP : mapPPerspectivesWithUniqueName.get(pP.Unique_Name__c)) {
                        
                        //Check for current record�s effective date if conflicting with any existing one
                        if((pP.Effective_End__c == null && exiPP.Effective_End__c == null)
                            || (pP.Effective_End__c != null && exiPP.Effective_End__c == null && pP.Effective_End__c >= exiPP.Effective_Start__c)
                            || (pP.Effective_End__c == null && exiPP.Effective_End__c != null && pP.Effective_Start__c <= exiPP.Effective_End__c)
                            || (pP.Effective_Start__c <= exiPP.Effective_End__c && pP.Effective_Start__c >= exiPP.Effective_Start__c)
                            || (pP.Effective_End__c >= exiPP.Effective_Start__c && pP.Effective_End__c <= exiPP.Effective_End__c)
                            || (exiPP.Effective_Start__c <= pP.Effective_End__c && exiPP.Effective_Start__c >= pP.Effective_Start__c)
                            || (exiPP.Effective_End__c >= pP.Effective_Start__c && exiPP.Effective_End__c <= pP.Effective_End__c))
                            //Add Error
                            throw new CustomException(Label.DUPLICATE_COMBINATION);     
                    }
                    
                    //Add Program_Perspective in map
                    mapPPerspectivesWithUniqueName.get(pP.Unique_Name__c).add(pP);
                
                } else {
                    
                    //Populate map
                    mapPPerspectivesWithUniqueName.put(pP.Unique_Name__c, new List<Program_Perspective__c> {pP});
                }
            }
        }

        //Check for set size
        if(mapPPerspectivesWithUniqueName.size() > 0) {
            
            //Query through Program_Perspective__c
            for(Program_Perspective__c pP : [Select Id, Unique_Name__c, Effective_Start__c, Effective_End__c From Program_Perspective__c Where Unique_Name__c IN : mapPPerspectivesWithUniqueName.keySet() AND Id NOT IN : programPerspectives]) {
                
                //Check if map contains key
                if(mapPPerspectivesWithUniqueName.containsKey(pP.Unique_Name__c)) {
                
                    //Loop through Program Perspectives records
                    for(Program_Perspective__c exiPP : mapPPerspectivesWithUniqueName.get(pP.Unique_Name__c)) {
                        
                        //Check for current record�s effective date if conflicting with any existing one
                        if((pP.Effective_End__c == null && exiPP.Effective_End__c == null)
                            || (pP.Effective_End__c != null && exiPP.Effective_End__c == null && pP.Effective_End__c >= exiPP.Effective_Start__c)
                            || (pP.Effective_End__c == null && exiPP.Effective_End__c != null && pP.Effective_Start__c <= exiPP.Effective_End__c)
                            || (pP.Effective_Start__c <= exiPP.Effective_End__c && pP.Effective_Start__c >= exiPP.Effective_Start__c)
                            || (pP.Effective_End__c >= exiPP.Effective_Start__c && pP.Effective_End__c <= exiPP.Effective_End__c)
                            || (exiPP.Effective_Start__c <= pP.Effective_End__c && exiPP.Effective_Start__c >= pP.Effective_Start__c)
                            || (exiPP.Effective_End__c >= pP.Effective_Start__c && exiPP.Effective_End__c <= pP.Effective_End__c))
                            //Add Error
                            throw new CustomException(Label.DUPLICATE_COMBINATION);
                    }
                }
            }
        }
    }

    /**
     *  @description    :   Method to check In Use values on record delation, If "In Use" values > 0, then throw error.
     *
     *  @args           :   List<Program_Perspective__c>
     *
     *  @return         :   void
     *
     **/
    public static void validateBeforeDelete(List<Program_Perspective__c> programPerspectives) {

        //Loop through Program_Perspective__c
        for(Program_Perspective__c pP : programPerspectives) {
            
            //Check for In Use fields value
            if(pP.In_use_Plans_Direct__c > 0 || pP.In_use_Plans_Indirect__c > 0 || pP.In_use_Staff_Direct__c > 0 || pP.In_use_Staff_Indirect__c > 0)
                throw new CustomException(Label.PROGRAM_PERSPECTIVE_IN_USE);
        }
    }
    
    /**
     *  @decription :   This method is used to update all the related RPPs name, if PPs name is changed.
     *                  For this we will blank update all the related RPPs, do to this Renaming workflow will execute and update RPPs names according   
     *
     *  @args       :   List<Program_Perspective__c>, Map<Id, Program_Perspective__c>
     *
     *  @return     :   void
     *
     **/
    public static void updateRPPs(List<Program_Perspective__c> programPerspectives, Map<Id, Program_Perspective__c> mapOldPPs) {
        
        //Set to hold Program_Perspective__c Ids
        Set<Id> setPPIds = new Set<Id>();
        
        //Loop through Program_Perspective__c
        for(Program_Perspective__c pP : programPerspectives) {
            
            //Check for appropriate condition
            if(pP.Name != mapOldPPs.get(pP.Id).Name)
                setPPIds.add(pP.Id);
        }
        
        //Check for set size
        if(setPPIds.size() > 0) {
            
            //List of RPPs
            List<Role_Program_Perspective__c> rPPs = [Select Id, Staff_Assignment__c, Staff_Assignment__r.Name, Program_Perspective__c, Program_Perspective__r.Name From Role_Program_Perspective__c Where Program_Perspective__c IN : setPPIds];
            
            //Loop through Role Program Perspective
            for(Role_Program_Perspective__c rPP : rPPs)
                rPP.Name = Util.parseNull(rPP.Staff_Assignment__r.Name) + '-' + Util.parseNull(rPP.Program_Perspective__r.Name);
            
            //Update RPPs to fire renaming workflow
            if(rPPs.size() > 0)
                update rPPs;
        }
    }
    
    /**
     *  @description    :   This method is used to populate Staff Assignment's static list (teamMemberships) to summarize RPPs on SA.
     *  
     *  @args           :   List<Program_Perspective__c>
     *
     *  @return         :   void
     *
     **/
    public static void SummarizeRPPs(List<Program_Perspective__c> programPerspectives) {
        
        //Set to hold PP Ids
        Set<Id> setPPIds = new Set<Id>();
        
        //Loop through PP
        for(Program_Perspective__c pP : programPerspectives)
            setPPIds.add(pP.Id);
        
        //Check for set size
        if(setPPIds.size() > 0) {
            
            //Set to hold Staff Assignment Ids
            Set<Id> setSAIds = new Set<Id>();
            
            //Query through RPPs
            for(Role_Program_Perspective__c rPP : [Select Id, Staff_Assignment__c From Role_Program_Perspective__c Where Staff_Assignment__c != null
                                                            AND Program_Perspective__c IN : setPPIds])
                setSAIds.add(rPP.Staff_Assignment__c);
            
            //Query through Staff Assignments
            teamMemberships = [Select Id, Program_Perspectives__c From Team_Membership__c Where Id IN : setSAIds];
        }
    }
    
    /**
     *  @description    :   This method is used to call TeamMemebershipTriggerHelper class method to Summarize RPPs on SA
     *  
     *  @args           :   
     *
     *  @return         :   void
     *
     **/
    public static void SummarizeRPPs() {
        
        //Check Staff Assignment list
        if(teamMemberships != null && teamMemberships.size() > 0){
             //Modified - Abhinav Sharma - CR-20200806-14405 - Error In Update Program Collection record (Move recalculateProgramPerspectives method functinality in Batch and comment existing)
            Database.executeBatch(new Batch_UpdateProgramPerspectives(teamMemberships));
        }
        // TeamMembershipTriggerHelper.recalculateProgramPerspectives(teamMemberships);
    }
    
    /**
     *  @description    :   Method to create Incentive Change Log (ICL) record when some specific fields are update.
     *                          
     *                          Field modified          Change Type         Populate In ICL
     *                      
     *                      1.  Short name              Text                Collection Perspective  
     *
     *                      2.  Effective dates         Effective dates     Collection Perspective
     *                                                                      Start date, end date (depending on chg)
     *                      
     *                      3.  Active                  Status              Collection Perspective
     *
     *  @args           :   List for new program persperctive value, Map for old value
     *
     *  @return         :   void
     *
     **/
     
    //Code Added by - Padmesh Soni - 08/04/2015 - CR-20150729-9114
    //V_1.3 - Commented By - Rajeev Jain - CR-20151120-9402 - 04/19/2016 - Removed the usage of createIncentiveChangeLog method
    /*public static void createIncentiveChangeLog(List<Program_Perspective__c> programPerspectives, Map<Id,Program_Perspective__c> mapOldProgramPerspectives){

        //List of IncentiveChangeLog to insert IncentiveChangeLog records
        List<Incentive_Change_Log__c> incentiveChangeLogs = new List<Incentive_Change_Log__c>();

        //Loop throgh program perspective
        for(Program_Perspective__c npp : programPerspectives) {

            //Check if dates fields are updated, comparing old and new fields
            if(npp.Effective_Start__c != mapOldProgramPerspectives.get(npp.Id).Effective_Start__c || 
                npp.Effective_End__c != mapOldProgramPerspectives.get(npp.Id).Effective_End__c) {
        
                Incentive_Change_Log__c iCL = new Incentive_Change_Log__c(Collection_Perspective__c = npp.Id, 
                                                                          Change_Type__c = ISSPConstants.INCENTIVE_CHANGE_LOG_VALUE_TYPE_EFFECTIVE_DATES);
    
                //Check if start date changed
                if(npp.Effective_Start__c != mapOldProgramPerspectives.get(npp.Id).Effective_Start__c )
                    iCL.Start_Date__c = npp.Effective_Start__c;
                
                //Check if end date changed 
                if(npp.Effective_End__c != mapOldProgramPerspectives.get(npp.Id).Effective_End__c)
                    iCL.End_Date__c = npp.Effective_End__c;
        
                    //Add list
                    incentiveChangeLogs.add(iCL);
            }

            //Check if status field are updated ,comparing old and new field
            if(npp.Active__c != mapOldProgramPerspectives.get(npp.Id).Active__c)
                incentiveChangeLogs.add(new Incentive_Change_Log__c(Collection_Perspective__c = npp.Id,
                                                                    Change_Type__c = ISSPConstants.INCENTIVE_CHANGE_LOG_CHANGE_TYPE_STATUS));
        }
        
        //Check for list size and insert list
        if(incentiveChangeLogs.size() > 0) {
            
            insert incentiveChangeLogs;
            
            //By pass the triggers here
            Util.BypassAllTriggers = true;
        }
    }*/
    
    //Code Added  - Padmesh Soni - 08/12/2015 - CR-20150729-9114 - New renameCP method added.
    /**
     *  @description    :   This method is used to rename Collection Perspective record before the record is commited.
     *
     *  @args           :   List<Program_Perspective__c>, map<Id, Program_Perspective__c>
     *
     *  @return         :   void
     *
     **/
    public static void renameCP(List<Program_Perspective__c> cPs, Map<Id, Program_Perspective__c> mapOldCPs){
    
        //Loop through Collection Perspective    
        for(Program_Perspective__c cP : cPs){
     
            //Rename the name field
            cP.Name = cP.CP_Name__c;    
        }
    }
}