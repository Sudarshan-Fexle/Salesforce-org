/**
*  Description     :   This class is there to find duplicate Is System Component records.
*
*  Created Date    :   02/04/2020 
* 
*  Revision Logs   :   V1.0 - Created
*
**/
global without sharing class Batch_ISSystemDuplicateFinder implements Database.Batchable<SObject>, Database.Stateful 
{  
    //Query String
    public String queryStr;
    public Set<Id> setOfIds;
    public Map<String, List<IS_System_Component__c>> mapIsSystemComponentIdsWithUniqueKey = new Map<String, List<IS_System_Component__c>>();
    
    global Batch_ISSystemDuplicateFinder(Set<Id> setOfIds)
    {	
        this.setOfIds  = setOfIds;
        
        if(String.isBlank(queryStr)) 
        {
            queryStr = 'SELECT Id, Parent_IsSystemComponent__c, Object_Type__c, Parent_API_Name__c, Item_API_Name__c, Object_Label__c, Modification_Count_Rollup__c, Status__c FROM IS_System_Component__c WHERE Modification_Count_Rollup__c > 0 AND Parent_IsSystemComponent__c = null';
            if(setOfIds != null && setOfIds.size() > 0)
            {
                queryStr += ' AND Id IN :setOfIds';
            }
            queryStr += ' Order By Item_API_Name__c ASC';  
        }
    }
    
    global Database.Querylocator start(Database.BatchableContext BC) 
    {
        return Database.getQueryLocator(queryStr);
    }
    
    global void execute(Database.BatchableContext BC, list<IS_System_Component__c> scope) 
    {
        //Map
        Map<String, List<IS_System_Component__c>> mapIsSystemComponentIdsWithUniqueKeyString = new Map<String, List<IS_System_Component__c>>();
        
        for(IS_System_Component__c isSysComponent : scope) 
        {
            String uniqueKeyIsSystemComponent = ''; //String to hold uniqueKey
            
            //Logic to build the unique key on the basis of component fields values
            //Start from here
            if(isSysComponent.Parent_API_Name__c != null && isSysComponent.Item_API_Name__c != null)
            {
                if(isSysComponent.Parent_API_Name__c.contains('.'))
                {
                    uniqueKeyIsSystemComponent = (isSysComponent.Parent_API_Name__c).removeEnd('.') + isSysComponent.Item_API_Name__c + isSysComponent.Object_Type__c;
                }
                else if(isSysComponent.Parent_API_Name__c.contains('-'))
                {
                    uniqueKeyIsSystemComponent = (isSysComponent.Parent_API_Name__c).removeEnd('-') + isSysComponent.Item_API_Name__c + isSysComponent.Object_Type__c;
                }
                else
                {
                    uniqueKeyIsSystemComponent = isSysComponent.Parent_API_Name__c + isSysComponent.Item_API_Name__c + isSysComponent.Object_Type__c;
				}
            }
            else if(isSysComponent.Parent_API_Name__c == null && isSysComponent.Item_API_Name__c != null)
            {
                uniqueKeyIsSystemComponent = isSysComponent.Item_API_Name__c + isSysComponent.Object_Type__c;
            }
            //End here
            
            if(String.isNotBlank(uniqueKeyIsSystemComponent) && String.isNotEmpty(uniqueKeyIsSystemComponent)){
                if(!mapIsSystemComponentIdsWithUniqueKey.containsKey(uniqueKeyIsSystemComponent)) 
                {
                    mapIsSystemComponentIdsWithUniqueKey.put(uniqueKeyIsSystemComponent, new List<IS_System_Component__c>());
                    mapIsSystemComponentIdsWithUniqueKey.get(uniqueKeyIsSystemComponent).add(isSysComponent);
                    mapIsSystemComponentIdsWithUniqueKeyString.put(uniqueKeyIsSystemComponent,new List<IS_System_Component__c>());
                    mapIsSystemComponentIdsWithUniqueKeyString.get(uniqueKeyIsSystemComponent).add(isSysComponent);
                }
                else{
                    mapIsSystemComponentIdsWithUniqueKey.get(uniqueKeyIsSystemComponent).add(isSysComponent);
                    
                    if(!mapIsSystemComponentIdsWithUniqueKeyString.containsKey(uniqueKeyIsSystemComponent))
                    	mapIsSystemComponentIdsWithUniqueKeyString.put(uniqueKeyIsSystemComponent,new List<IS_System_Component__c>());
					mapIsSystemComponentIdsWithUniqueKeyString.get(uniqueKeyIsSystemComponent).add(isSysComponent);
                }
            }
        }
        
        System.debug('mapIsSystemComponentIdsWithUniqueKey::::>' +mapIsSystemComponentIdsWithUniqueKey);
        System.debug('mapIsSystemComponentIdsWithUniqueKeyString::::>' +mapIsSystemComponentIdsWithUniqueKeyString);
        
        //List to hold the duplicate Is System Component records that going to be updated
        List<IS_System_Component__c> dupsComponentsToBeUpdated = new List<IS_System_Component__c>();
        
        if(mapIsSystemComponentIdsWithUniqueKeyString.size() > 0){
            
            for(String isSysCompUniqueKeyString : mapIsSystemComponentIdsWithUniqueKeyString.keyset()) 
            {
                ID parentID = mapIsSystemComponentIdsWithUniqueKey.get(isSysCompUniqueKeyString)[0].ID;
                mapIsSystemComponentIdsWithUniqueKey.get(isSysCompUniqueKeyString)[0].Parent_IsSystemComponent__c = null;
                dupsComponentsToBeUpdated.add(mapIsSystemComponentIdsWithUniqueKey.get(isSysCompUniqueKeyString)[0]);
                
                //Looping over dups to associate parent component reference on them
                for(Integer i =1; i< mapIsSystemComponentIdsWithUniqueKey.get(isSysCompUniqueKeyString).size(); i++) 
                {
                    mapIsSystemComponentIdsWithUniqueKey.get(isSysCompUniqueKeyString)[i].Parent_IsSystemComponent__c = parentID;
                    dupsComponentsToBeUpdated.add(mapIsSystemComponentIdsWithUniqueKey.get(isSysCompUniqueKeyString)[i]);
                }
            }
        }
        
        if(dupsComponentsToBeUpdated.size() > 0) 
        {
            Util.BypassAllTriggers = true;
            Database.SaveResult[] isSystemComponentToUpdateResult = Database.update(dupsComponentsToBeUpdated ,false);
            Util.BypassAllTriggers = false;
        }
    }

    //Finish method
    global void finish(Database.BatchableContext BC) 
    {
    }
}