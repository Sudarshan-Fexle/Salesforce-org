/**
 *  Purpose         :   Batch class is used to delete all component change detail record from org Comparison.
 *
 *  Created By      :   Dipesh Gupta
 *
 *  Created Date    :   01/28/2020
 *
 *  Revision Logs   :   
 *                     
**/
global class Batch_DeleteCompChangeDetail implements Database.Batchable<sObject> , Database.Stateful {
    
    public String debugLogs;
    public Set<Id> setOfOrgComparisonIds;
    public Boolean orgComparisonDeletionNeeded;
    
    global Batch_DeleteCompChangeDetail(Set<Id> setOfOrgComparisonIds, Boolean orgComparisonDeletionNeeded)
    {
        this.setOfOrgComparisonIds = setOfOrgComparisonIds;
        this.orgComparisonDeletionNeeded = orgComparisonDeletionNeeded;
        this.debugLogs = '';
    }
    
    //Start Method 
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        String queryStr = '';
        
        if(setOfOrgComparisonIds != null && setOfOrgComparisonIds.size() > 0){
            queryStr = 'Select Id from Component_Changes_Detail__c where Org_Comparison__c IN : setOfOrgComparisonIds';
        }
        if(String.isNotBlank(queryStr)){
            return Database.getQueryLocator(queryStr);
        }
        
        return null;
        
    }
    
    global void execute(Database.BatchableContext BC, List<Component_Changes_Detail__c> scope){
        
        if(scope !=null && scope.size()>0){
            Util.byPassAllTriggers = true;
           
            debugLogs += DatabaseUtilities.createLog(Database.delete(scope, false));
            
        }
        
    }
    
    global void finish(Database.BatchableContext BC){
		
        if(orgComparisonDeletionNeeded && setOfOrgComparisonIds.size() > 0) {
        	
            List<Org_Comparision__c> OrgComparisonToBeDeleted = new List<Org_Comparision__c>();
            for(Id orgComparisonId : setOfOrgComparisonIds)
            	OrgComparisonToBeDeleted.add(new Org_Comparision__c(Id = orgComparisonId));
            
            //Check the size of list that is going to deleted. 
            if(OrgComparisonToBeDeleted.size() > 0) 
               debugLogs += DatabaseUtilities.createLog(Database.delete(OrgComparisonToBeDeleted, false));
            
        }
        
        if(debugLogs != '')
        {
            Util.sendBatchStatus(BC.getJobId(), 'Batch_DeleteCompChangeDetail', debugLogs, userInfo.getUserEmail());        
        }
   	}
    
}