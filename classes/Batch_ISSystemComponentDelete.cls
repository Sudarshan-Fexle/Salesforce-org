/**
*  Description     :   This class is there to find duplicate account records.
*
*  Created Date    :   02/04/2020 
* 
*  Revision Logs   :   V1.0 - Created
*
**/
global without sharing class Batch_ISSystemComponentDelete implements Database.Batchable<SObject> 
{
    public String queryStr;
    public Set<Id> setOfIds;
    
    global Batch_ISSystemComponentDelete(Set<Id> setOfIds)
    {    
        if(String.isBlank(queryStr)) 
        {
            queryStr = 'Select Id, Modification_Count_Rollup__c From IS_System_Component__c Where Modification_Count_Rollup__c = 0';
            if(setOfIds != null && setOfIds.size() > 0)
            {
                queryStr += ' AND Id IN : setOfIds';
            }
        }
        this.setOfIds = setOfIds;
    }
    
    global Database.Querylocator start(Database.BatchableContext BC) 
    {
        return Database.getQueryLocator(queryStr);
    }
    
    global void execute(Database.BatchableContext BC, list<IS_System_Component__c> scope) 
    {
        List<IS_System_Component__c> isSystemComponentToDelete = new List<IS_System_Component__c>();
        isSystemComponentToDelete.addAll(scope);
        if(isSystemComponentToDelete.size() > 0) 
        {
            Util.BypassAllTriggers = true;
            Database.delete(isSystemComponentToDelete ,false);
            Util.BypassAllTriggers = false;
        }
    }
    
    global void finish(Database.BatchableContext BC) 
    {
        
    }
}