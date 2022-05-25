/**
 *  Purpose      :  Helper class for MeetingUtilizationMtMTrigger.
 *
 *  Create By    :  Dipesh Gupta - 08/11/2019 - CR-20190626-13199 
 *  
 *  Revision Log  :  v1.0 -  Created 
 * 
**/
public class MeetingUtilizationMtMTriggerHelper {

    // Added by - Dipesh Gupta - 08/11/2019 - CR-20190626-13199 
    /**
     *  @description    :   This method is used to populate Membership on Meeting Utilization MtM. 
     *
     *  @args           :   Map new Meeting Utilization MtM 
     *
     *  @return         : 	void  
     * 
     *  @RevisionLog 	:
     * 
     *
     **/
    public static void populateMembership(List<Meeting_Utilization_MtM__c> meeetinUtilizationMtMs, Map<Id, Meeting_Utilization_MtM__c> oldmapMeetingUtilizationMtM) {
     
        //Set of Meeting Utilization Id
        Set<Id> setOfMeetingUtilization = new Set<Id>();
        
        //Set of Event Rule Id
        Set<Id> setOfEventRule = new Set<Id>();
        
        //List of Meeting Utilization MtM to be update
        List<Meeting_Utilization_MtM__c> mUMtMToBeUpdated = new List<Meeting_Utilization_MtM__c>();
        
        //Insert case check 
        if(meeetinUtilizationMtMs != null && oldmapMeetingUtilizationMtM == null){
            
            //Loop over Meeting Utilization MtM to get Meeting Utilization and Event Rule
            for(Meeting_Utilization_MtM__c mUMtM : meeetinUtilizationMtMs){
                
                //Null Check
                if(mUMtM.Meeting_Utilization__c != null)
                    setOfMeetingUtilization.add(mUMtM.Meeting_Utilization__c);
                
                //Null Check
                if(mUMtM.Event_Rule__c != null)
                    setOfEventRule.add(mUMtM.Event_Rule__c);
            }
            
            //Size check over sets
            if(setOfMeetingUtilization.size() > 0 && setOfEventRule.size() > 0){  
                
                //Map of Event Rule Id and Program
                Map<Id,String> mapOfEventRuleIdwithProgram = new Map<Id,String>();
                
                //Map of Meeting utilization Id and Account 
                Map<Id,String> mapOfMeetingUtilizationIdwithAccount = new Map<Id,String>();
                
                //Map of Unique Key and membership
                Map<String, Membership__c> mapOfUniqueIdWithMembership = new Map<String, Membership__c>();
                
                
                //Loop over Meeting Utilization Account
                for(Meeting_Utilization__c mU : [SELECT Id, Contact__r.AccountId FROM Meeting_Utilization__c WHERE Id IN: setOfMeetingUtilization]){
                    
                    //Putting Meeting Utilization Id with AccountId 
                    mapOfMeetingUtilizationIdwithAccount.put(mU.Id, mU.Contact__r.AccountId);
                }
                
                //Loop over Event rule to get Program
                for(Event_Rule__c eR : [SELECT Id, Rule__r.Program__c FROM Event_Rule__c WHERE Id IN: setOfEventRule]){
                    
                    //Putting Event Rule Id with Program Id  
                    mapOfEventRuleIdwithProgram.put(eR.Id, eR.Rule__r.Program__c);
                }
                
                //Loop over Membership to get Program
                for(Membership__c mem : [SELECT Id, Account_Name__c, Program__c  FROM Membership__c WHERE Account_Name__c IN: mapOfMeetingUtilizationIdwithAccount.Values() AND 
                                         Program__c IN: mapOfEventRuleIdwithProgram.Values()]){
                                             
                   //Unique Key of account and Program
                   String UNIQUE_ID = mem.Account_Name__c + ' - ' + mem.Program__c;
                   System.debug('@@@@@@@----->>>'+UNIQUE_ID); 
                                             
                   //Putting Unique Key with Membership  
                   mapOfUniqueIdWithMembership.put(UNIQUE_ID, mem);                        
                 }
                
                //Loop over Meeting Utilization MtM to get Meeting Utilization and Event Rule
                for(Meeting_Utilization_MtM__c mUMtM : meeetinUtilizationMtMs){
                    
                    //Unique Key of account and Program
                    String UNIQUE_ID = mapOfMeetingUtilizationIdwithAccount.get(mUMtM.Meeting_Utilization__c) + ' - ' + mapOfEventRuleIdwithProgram.get(mUMtM.Event_Rule__c);
                   System.debug('####----->>>'+UNIQUE_ID); 
                    
                    //Adding updated value
                    Meeting_Utilization_MtM__c meetMTM = new Meeting_Utilization_MtM__c();
                    meetMTM.Id = mUMtM.Id;
                    // map null check
                    if(mapOfUniqueIdWithMembership != null && mapOfUniqueIdWithMembership.size() > 0)
                    {
                        meetMTM.Membership__c = String.valueOf(mapOfUniqueIdWithMembership.get(UNIQUE_ID).Id);
                    }
                    mUMtMToBeUpdated.add(meetMTM);
                    //mUMtMToBeUpdated.add(new Meeting_Utilization_MtM__c(Id = mUMtM.Id, Membership__c = String.valueOf(mapOfUniqueIdWithMembership.get(UNIQUE_ID).Id)));
                }
                
                //Null Check 
                if(mUMtMToBeUpdated != null && mUMtMToBeUpdated.size() > 0 ){
                    
                    //updating
                    update mUMtMToBeUpdated;
                }
                
            }
        }
    }
}