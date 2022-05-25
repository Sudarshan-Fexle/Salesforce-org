/**
*  Description     :  This class is for handle triggers on Opportunity.
*
*  Created By      :  Sudarshan singh
*
*  Created Date    :  03/06/2022
*
*  Revision Logs   :  V1.0 - Created - Sudarshan Singh 
*
**/
public without sharing class OpportunityTriggerHandler {
    
    /**
    * 
    *   @description    :   In this method update the tracking of stage using stage picklist field and maintain order of Stage field values. 
    *
    *   @args           :   List<Account>, Map<Id,Opportunity>
    *
    *   @return         :   void
    *
    *   @revision Log   :   V1.1 - Created  - 03/06/2022 - Sudarshan singh - Comment
    * 
    **/
    // public static void updateStageTracking(List<Opportunity> listOfNewOpportunity, Map<Id,Opportunity> mapOfOldOpportunity){
        
    //     //Get all the values of stage picklist
    //     List<Schema.PicklistEntry> value = Opportunity.StageName.getDescribe().getPicklistValues();

    //     //Hold values of stage
    //     List<String> listOfPickListStage = new List<String>();

    //     //Traverse on value of stage
    //     for (Integer i = 0; i < value.size(); i++) {    
    //         listOfPickListStage.add(value[i].getValue());
    //     }

    //     //Traverse on Opportunity
    //     for(Opportunity opp : listOfNewOpportunity){

    //         //Check valid condition for insert and update
    //         if(mapOfOldOpportunity == null || opp.StageName != mapOfOldOpportunity.get(opp.Id).StageName){
            
    //             //If stage tracking is not empty
    //             if (opp.Stage_Tracking__c != null) {

    //                 //Split stage tracking to get all stage name.
    //                 List<String> listOfOldStage = opp.Stage_Tracking__c.split(' ==> ');
    //                 listOfOldStage.add(opp.StageName);
    //                 opp.Stage_Tracking__c = '';

    //                 //Traverse satges of pickList
    //                 for (String newStage : listOfPickListStage) {
                        
    //                     if(listOfOldStage.contains(newStage)){
                            
    //                         if (String.isBlank(opp.Stage_Tracking__c))
    //                             opp.Stage_Tracking__c = newStage;    
    //                         else
    //                             opp.Stage_Tracking__c = opp.Stage_Tracking__c + ' ==> ' + newStage;
    //                     }
    //                 }
    //             }

    //             //If stage tracking is empty
    //             else
    //                 opp.Stage_Tracking__c =  opp.stageName;
            
    //         }
    //     }
    // }

    /**
    * 
    *   @description    :   In this method update the tracking of stage using stage picklist field and check the stage in not previous from current stage. 
    *
    *   @args           :   List<Account>, Map<Id,Opportunity>
    *
    *   @return         :   void
    *
    *   @revision Log   :   V1.1 - Created  - 03/06/2022 - Sudarshan singh - Comment
    * 
    **/
    public static void updateStageTracking(List<Opportunity> listOfNewOpportunity, Map<Id,Opportunity> mapOfOldOpportunity){
            
        //Get all the values of stage picklist
        List<Schema.PicklistEntry> value = Opportunity.StageName.getDescribe().getPicklistValues();

        //Hold values of stage name as keys of map
        Map< String, Integer> mapOfStage = new Map<String, Integer>();

        //Traverse on value of stage
        for (Integer i = 0; i < value.size(); i++) {
            mapOfStage.put(value[i].getValue(), i);    
        }

        if (mapOfOldOpportunity != null) {
            
            //Traverse on Opportunity
            for(Opportunity opp : listOfNewOpportunity){

                //Check valid condition for insert and update
                if(opp.StageName != mapOfOldOpportunity.get(opp.Id).StageName){
                //Get index of new stage from mapOfStage
                Integer indexOfNewStage = mapOfStage.get(opp.StageName);

                //Get index of last old stage from mapOfStage
                Integer indexOfOldStage = mapOfStage.get(mapOfOldOpportunity.get(opp.Id).StageName);

                //Check if the stage is previous to current stage
                if (indexOfNewStage < indexOfOldStage)
                    opp.addError('Please select stage above previous stage');
            
                }
            
            }
        }
    }
}