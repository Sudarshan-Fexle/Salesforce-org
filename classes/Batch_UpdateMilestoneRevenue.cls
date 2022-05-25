/*
* Version - V_1.0
* Created By : Seemu Saikia
* Created Date : 05/24/2019
* CR-20190424-13023
* This batch class updates Revenue__c field on MileStone (pse__Milestone__c)
*/

global class Batch_UpdateMilestoneRevenue implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        // collect the batches of records or objects to be passed to execute
        String checkDate = Label.PSE_MilestoneBatchDate;
        
        String query = 'SELECT Id,CreatedDate,Revenue__c,EAB_Deployment__c FROM pse__Milestone__c where createdDate > ' 
            + checkDate + ' AND  Revenue__c = null';
        
        //Added by Mahendra Swarnakar - 06/19/2019 - Starts from here
        String projectIds = Label.PSE_ProjectIDs;
        
        if(String.IsNotBlank(projectIds))
        query = query + ' AND pse__Project__c NOT IN (' + projectIds + ')' ;
        //Added by Mahendra Swarnakar - 06/19/2019 - Ends here
        
        system.debug('query----'+ query  );
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<pse__Milestone__c> listMileStone) {
        //Set to hold Deployment Id of Milestone records 
        Set<Id> deploymentIds = new Set<Id>();
        //List<pse__Milestone__c> mileStoneList = new list<pse__Milestone__c>();
        
        List<ABC_Revenue__c> revenueRecs = new List<ABC_Revenue__c>(); 
        Map<Id,List<ABC_Revenue__c>> mapDeploymentToRevenue = new Map<Id,List<ABC_Revenue__c>>();
        Map<Id,pse__Milestone__c> mapUpdateMileStoneRec = new Map<Id,pse__Milestone__c>();
        
        //Fill set with deployment ids of Milestone records 
        for(pse__Milestone__c mileStoneRecs : listMileStone){
            deploymentIds.add(mileStoneRecs.EAB_Deployment__c);
            //mileStoneList.add(mileStoneRecs);
        }
        //Query All ABC Revenue records with deployment ids in set
        if(deploymentIds != null)
            revenueRecs = [Select id , Deployment__c from ABC_Revenue__c where Fee_Type__c ='Setup_Implementation' AND Deployment__c in:deploymentIds];
        
        //fill map deploymentid -> list of Revenues
        if(revenueRecs != null){
            for(id depId : deploymentIds){
                
                List<ABC_Revenue__c> revRecTemp = new List<ABC_Revenue__c>();
                
                for(ABC_Revenue__c revRec : revenueRecs){
                    
                    if(revRec.Deployment__c == depId){
                        System.debug(revRec.id);
                        revRecTemp.add(revRec);
                    }
                }
                mapDeploymentToRevenue.put(depId,revRecTemp);
            }
        }
        
        if(mapDeploymentToRevenue != null){
            for(pse__Milestone__c mileStoneRec:listMileStone){
                
                if(mapDeploymentToRevenue.containsKey(mileStoneRec.EAB_Deployment__c)){
                    
                    if(mapDeploymentToRevenue.get(mileStoneRec.EAB_Deployment__c).size()> 0){
                        System.debug(mileStoneRec.EAB_Deployment__c);
                        mileStoneRec.Revenue__c = mapDeploymentToRevenue.get(mileStoneRec.EAB_Deployment__c)[0].Id;
                    }
                }
                
                mapUpdateMileStoneRec.put(mileStoneRec.id,mileStoneRec);
            }
        }
        
        if(mapUpdateMileStoneRec != null){
            
            update mapUpdateMileStoneRec.values();
        }
    }   
    
    global void finish(Database.BatchableContext BC) {
        // execute any post-processing operations
    }
}