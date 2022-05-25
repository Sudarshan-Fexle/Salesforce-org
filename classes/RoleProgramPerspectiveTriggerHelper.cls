/**
 *  Purpose         :   This class is to work as helper class for Role Program Perspective Trigger
 * 
 *  Created By      :   Subhash Garhwal
 * 
 *  Created Date    :   06/30/2015 
 * 
 *  Revision Logs   :   V_1.0 - Created - CR-20150618-9014
 *                      V_1.1 - Modified - Subhash Garhwal - CR-20150618-9014 - Add new method preventDuplicates
 *                      V_1.2 - Modified - Abhinav Sharma - CR-20200806-14405 - 08/26/2020 - Error In Update Program Collection record
 *                      V_1.3 - Modified - Mahendra Swarnkar - CR-20201123-14708 - 09/01/2021 - Population of the Current Program Responsibilities field on Staff Assignment
 * 
 **/ 
public without sharing class RoleProgramPerspectiveTriggerHelper {
    
    /**
     *  @description    :   This method is used to populate Program Perspective fields value with all related Role Program Perspectives
     *                      Short Name field, if Role Program Perspectives Effective End date >= today and record is created or updated or deleted
     *
     *  @args           :   List<Role_Program_Perspective__c>, Map<Id, Role_Program_Perspective__c>
     *
     *  @return         :   void
     *
     **/
    public static void validateUpdate(List<Role_Program_Perspective__c> rPPerspectives, Map<Id, Role_Program_Perspective__c> mapOldRPPs) {
        
        //Commented By - Mahendra Swarnkar - CR-20201123-14708 - 09/01/2021 - Population of the Current Program Responsibilities field on Staff Assignment
        /*//Set to hold staff assignment Ids
        Set<Id> setSAIds = new Set<Id>();
        
        //Loop through Role Program Perspective
        for(Role_Program_Perspective__c rPP : rPPerspectives != null ? rPPerspectives : mapOldRPPs.values()) {
            
            //Check for appropriate condition
            if(rPPerspectives != null && rPP.Staff_Assignment__c != null && (mapOldRPPs == null || rPP.Effective_End__c != mapOldRPPs.get(rPP.Id).Effective_End__c
                || rPP.Perspective_Short_Name__c != mapOldRPPs.get(rPP.Id).Perspective_Short_Name__c || rPP.Staff_Assignment__c != mapOldRPPs.get(rPP.Id).Staff_Assignment__c))
                setSAIds.add(rPP.Staff_Assignment__c);
            
            //Check for delete case
            if(rPPerspectives == null && rPP.Staff_Assignment__c != null)
                setSAIds.add(rPP.Staff_Assignment__c);
        }
        
        //Check for set size
        if(setSAIds.size() > 0) {
            
            //Call TeamMembershipTriggerHelper class method to populate correct Program Perspectives on Staff Assignment
            //TeamMembershipTriggerHelper.recalculateProgramPerspectives([Select Id, Program_Perspectives__c From Team_Membership__c Where Id IN : setSAIds]);
            
            //Modified - Abhinav Sharma - CR-20200806-14405 - Error In Update Program Collection record (Move recalculateProgramPerspectives method functinality in Batch and comment existing)
            List<Team_Membership__c> listOfTeamMemberships = [Select Id, Program_Perspectives__c From Team_Membership__c Where Id IN : setSAIds];
            if(listOfTeamMemberships.size() > 0){
                Database.executeBatch(new Batch_UpdateProgramPerspectives(listOfTeamMemberships));
            }
        } */  
    }
    
    /**
     *  @description    :   This metthod is used to prevent the duplicate RPPs on Staff Assignment.
     *                      Duplicate Defination:
     *                      RPPs exist for the same Staff Assignment where the Program Perspective is the same and the dates overlap.
     *
     *  @args           :   List<Role_Program_Perspective__c>, Map<Id, Role_Program_Perspective__c>
     *
     *  @return         :   void
     *
     **/
    public static void preventDuplicates(List<Role_Program_Perspective__c> rPPs, Map<Id, Role_Program_Perspective__c> mapOldRPPs) {
        
        //Map to hold unique Key (Combination of Staff Assignment and Program Perspective) with List of RPPs
        Map<String, List<Role_Program_Perspective__c>> mapRPPsWithUK = new Map<String, List<Role_Program_Perspective__c>>();
        
        //Set to hold Staff Assignment Ids
        Set<Id> setSAIds = new Set<Id>();
        
        //Loop through Role Program Perspective
        for(Role_Program_Perspective__c rPP : rPPs) {
            
            //Check for appropriate condition
            if(rPP.Staff_Assignment__c != null && (mapOldRPPs == null || rPP.Effective_Start__c != mapOldRPPs.get(rPP.Id).Effective_Start__c
                || rPP.Effective_End__c != mapOldRPPs.get(rPP.Id).Effective_End__c || rPP.Program_Perspective__c != mapOldRPPs.get(rPP.Id).Program_Perspective__c)) {
                    
                //Generate Unique Key
                String uniqueKey = rPP.Staff_Assignment__c;
                if(rPP.Program_Perspective__c != null)
                    uniqueKey = uniqueKey + '-' + rPP.Program_Perspective__c;
                
                //Check if any new record has same unique key
                if(mapRPPsWithUK.containsKey(uniqueKey)) {
                    
                    //Loop through Staff Assignment
                    for(Role_Program_Perspective__c exRPP : mapRPPsWithUK.get(uniqueKey)) {
                        
                        //Check for current record’s effective date if conflicting with any existing one
                        if((rPP.Effective_End__c == null && exRPP.Effective_End__c == null)
                            || (rPP.Effective_End__c != null && exRPP.Effective_End__c == null && rPP.Effective_End__c >= exRPP.Effective_Start__c)
                            || (rPP.Effective_End__c == null && exRPP.Effective_End__c != null && rPP.Effective_Start__c <= exRPP.Effective_End__c)
                            || (rPP.Effective_Start__c <= exRPP.Effective_End__c && rPP.Effective_Start__c >= exRPP.Effective_Start__c)
                            || (rPP.Effective_End__c >= exRPP.Effective_Start__c && rPP.Effective_End__c <= exRPP.Effective_End__c)
                            || (exRPP.Effective_Start__c <= rPP.Effective_End__c && exRPP.Effective_Start__c >= rPP.Effective_Start__c)
                            || (exRPP.Effective_End__c >= rPP.Effective_Start__c && exRPP.Effective_End__c <= rPP.Effective_End__c))
                            //Add Error
                            throw new CustomException(Label.ERROR_UNIQUENESS_RPP);      
                    }
                    
                    //Add Staff Assignment in map
                    mapRPPsWithUK.get(uniqueKey).add(rPP);
                
                } else {
                    
                    //Populate map
                    mapRPPsWithUK.put(uniqueKey, new List<Role_Program_Perspective__c> {rPP});
                }
                
                //Afdd SA in Set
                setSAIds.add(rPP.Staff_Assignment__c);
            }
        }
        
        //Check for size
        if(setSAIds.size() > 0 && mapRPPsWithUK.size() > 0) {
            
            //Query through RPPs
            for(Role_Program_Perspective__c rPP : [Select Id, Staff_Assignment__c, Program_Perspective__c, Effective_Start__c, Effective_End__c From
                                                          Role_Program_Perspective__c Where Staff_Assignment__c IN : setSAIds AND Id NOT IN : rPPs]) {
                
                //Generate Unique Key
                String uniqueKey = rPP.Staff_Assignment__c;
                if(rPP.Program_Perspective__c != null)
                    uniqueKey = uniqueKey + '-' + rPP.Program_Perspective__c;
                
                //Check if any new record has same unique key
                if(mapRPPsWithUK.containsKey(uniqueKey)) {
                    
                    //Loop through Staff Assignment
                    for(Role_Program_Perspective__c exRPP : mapRPPsWithUK.get(uniqueKey)) {
                        
                        //Check for current record’s effective date if conflicting with any existing one
                        if((rPP.Effective_End__c == null && exRPP.Effective_End__c == null)
                            || (rPP.Effective_End__c != null && exRPP.Effective_End__c == null && rPP.Effective_End__c >= exRPP.Effective_Start__c)
                            || (rPP.Effective_End__c == null && exRPP.Effective_End__c != null && rPP.Effective_Start__c <= exRPP.Effective_End__c)
                            || (rPP.Effective_Start__c <= exRPP.Effective_End__c && rPP.Effective_Start__c >= exRPP.Effective_Start__c)
                            || (rPP.Effective_End__c >= exRPP.Effective_Start__c && rPP.Effective_End__c <= exRPP.Effective_End__c)
                            || (exRPP.Effective_Start__c <= rPP.Effective_End__c && exRPP.Effective_Start__c >= rPP.Effective_Start__c)
                            || (exRPP.Effective_End__c >= rPP.Effective_Start__c && exRPP.Effective_End__c <= rPP.Effective_End__c))
                            //Add Error
                            throw new CustomException(Label.ERROR_UNIQUENESS_RPP);      
                    }
                }                                               
            }   
        }
    }
}