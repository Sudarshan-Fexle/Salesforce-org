/**
*  Description     :   Performs Custom logic created by EAB which applies to the VVS Package on Opportunity
*
*  Created By      :   Colin McGloin
*
*  Created Date    :   05/08/2019
*
*  Revision Logs   :   V_1.0 - Created

*/

public class VVSCustomHelper {
    
    public static void runVVSLogic (List<Opportunity> newOpps, Map<Id, Opportunity> mapOldOpps) {
        
        //List of Opportunities
        List<Opportunity> vvsOpps = new List<Opportunity>();
        
        //Map for storing our Opportunity Stages
        Map<String, Opportunity_Stage__c> mapOppStage = new Map<String, Opportunity_Stage__c>();

        //Set our IDs once to use again
        Id EAB_Initiating = CPQConstants.OPP_RT_ID_EAB_INITIATING;
        Id EAB_Continuing = CPQConstants.OPP_RT_ID_EAB_CONTINUING;
        
        //Loop through our records
        for (Opportunity opp : newOpps){
            
            //Check for key VVS fields on Insert
            if (opp.Opportunity_Stage__c == null || opp.Type == null || opp.Contact__c == null) {
                vvsOpps.add(opp);
            }
            
            //Check for field changes which apply to VVS
            if (mapOldOpps != null && 
                (opp.StageName != mapOldOpps.get(opp.Id).StageName || opp.RecordTypeId != mapOldOpps.get(opp.Id).RecordTypeId)) {
                    vvsOpps.add(opp);
                }
            
        }
        
        //If we have records then go run our VVS Logic
        if (vvsOpps.size() > 0){
            
            //Query for all our SP Opportunity Stage records
            List<Opportunity_Stage__c> allOppStages = [SELECT Id, Name FROM Opportunity_Stage__c];
            
            //Check to see if there are records
            if (allOppStages.size() > 0) {
                
                //Loop through out records and pop them into a Map for help finding later
                for (Opportunity_Stage__c oppStage : allOppStages){
                    
                    //Check map for record
                    if(mapOppStage.get(oppStage.Name) == null){
                        mapOppStage.put(oppStage.Name, oppStage);
                    }
                    
                }
            }
            
            //Loop through our Opportunities
            for (Opportunity opp : vvsOpps){
                
                //Check for our Record Type and populate Type field based on that
                if (opp.RecordTypeId == EAB_Initiating){
                    opp.Type = 'NBB';
                } else if (opp.RecordTypeId == EAB_Continuing){
                    opp.Type = 'Existing Client';
                }
                
                //Check for our Stage and grab the correct SP Opportunity Stage record or clear the field
                if (opp.StageName != null && mapOppStage.get(opp.StageName) != null){
                    opp.Opportunity_Stage__c = mapOppStage.get(opp.StageName).Id;
                } else if (opp.StageName != null && mapOppStage.get(opp.StageName) == null){
                    opp.Opportunity_Stage__c = null;
                }
                
                //Check to see if Main Contact is populated and default Contact to that value if so
                if (opp.Main_Contact__c != null && opp.Contact__c == null){
                    opp.Contact__c = opp.Main_Contact__c;
                }
            }
        }
        
    }
    
}