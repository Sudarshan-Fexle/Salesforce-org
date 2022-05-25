/**
 *  Description     :   This class is there to merge/delete out duplicate Is System Component records.
 *
 *  Created Date    :   02/04/2020 
 * 
 *  Revision Logs   :   V1.0 - Created
 *
**/
global without sharing class Batch_ISSystemComponentDuplicacyMerge implements Database.Batchable<SObject>
{
	String isSystemComponentComponentFieldsNamesString = '';
    Set<String> setIsSystemComponentFieldsNameString;
    public String queryStr;
	public Set<Id> setOfIds;
    
    global Batch_ISSystemComponentDuplicacyMerge(Set<Id> setOfIds) 
    {
        setIsSystemComponentFieldsNameString = new Set<String>();
        
        Map<String, Schema.SObjectField> IsSystemComponentFieldsMap = Is_System_Component__c.sObjectType.getDescribe().fields.getMap();
        for(String fieldName : IsSystemComponentFieldsMap.keySet()) {
            Schema.DescribeFieldResult field = IsSystemComponentFieldsMap.get(fieldName).getDescribe();
            if(!field.isCalculated() && field.isCreateable() && field.isUpdateable() 
               && !field.getLocalName().equalsIgnoreCase('Parent_IsSystemComponent__c')) 
            {
                setIsSystemComponentFieldsNameString.add(field.getLocalName());
                if(isSystemComponentComponentFieldsNamesString == '')
                    isSystemComponentComponentFieldsNamesString = field.getLocalName(); 
                else
                    isSystemComponentComponentFieldsNamesString += ',' + field.getLocalName();
            }
        }
        this.setOfIds  = setOfIds;
        if(String.isBlank(queryStr)) 
        {
            if(setOfIds != null && setOfIds.size() > 0)
            {
                queryStr = 'SELECT ' + isSystemComponentComponentFieldsNamesString 
                    + ', (Select ' + isSystemComponentComponentFieldsNamesString 
                    + ' FROM IS_System_Components1__r Where Parent_IsSystemComponent__c != null) FROM IS_System_Component__c WHERE Id IN:setOfIds AND  Parent_IsSystemComponent__c = null '
                    + ' AND Modification_Count_Rollup__c > 0 ORDER By createddate DESC';
            }
            else
            {
                queryStr = 'SELECT ' + isSystemComponentComponentFieldsNamesString 
                    + ', (Select ' + isSystemComponentComponentFieldsNamesString 
                    + ' FROM IS_System_Components1__r Where Parent_IsSystemComponent__c != null) FROM IS_System_Component__c WHERE Parent_IsSystemComponent__c = null '
                    + ' AND Modification_Count_Rollup__c > 0 ORDER By createddate DESC';    
            }    
        }
    }
    
    global Database.Querylocator start(Database.BatchableContext BC) 
    {
    	return Database.getQueryLocator(queryStr);
    }
    
    global void execute(Database.BatchableContext BC, List<IS_System_Component__c> scope) 
    {
        Map<Id, List<Id>> mapParentIsSystemComponentWithListOfChilderenIsSystemComponent = new Map<Id, List<Id>>();
        Map<Id, IS_System_Component__c> mapParentIsSystemComponent = new Map<Id, IS_System_Component__c>();
        Map<Id, IS_System_Component__c> mapIsSystemComponent = new Map<Id, IS_System_Component__c>((List<IS_System_Component__c>)database.query('Select ' + IsSystemComponentComponentFieldsNamesString + ' From IS_System_Component__c where Id IN: scope'));
        for(IS_System_Component__c parentIsSysComp : scope) 
        {
            if(parentIsSysComp.IS_System_Components1__r != null && parentIsSysComp.IS_System_Components1__r.size() > 0) 
            {
                mapParentIsSystemComponent.put(parentIsSysComp.Id, mapIsSystemComponent.get(parentIsSysComp.Id));
                List<Id> listOfIds = new List<Id>();
                mapParentIsSystemComponentWithListOfChilderenIsSystemComponent.put(parentIsSysComp.Id, listOfIds);
                for(IS_System_Component__c child : parentIsSysComp.IS_System_Components1__r) 
                {
                    IS_System_Component__c pIsSystemComponent = mapParentIsSystemComponent.get(parentIsSysComp.Id);
                    for(String fieldAPIName : setIsSystemComponentFieldsNameString) 
                    {
                        if(pIsSystemComponent.get(fieldAPIName) == null && child.get(fieldAPIName) != null) 
                        {
                            pIsSystemComponent.put(fieldAPIName, child.get(fieldAPIName));   
                        }
                    }
                    mapParentIsSystemComponent.put(pIsSystemComponent.Id, pIsSystemComponent);
                    List<Id> mergingIsSystemComponent = mapParentIsSystemComponentWithListOfChilderenIsSystemComponent.get(pIsSystemComponent.Id);
                    mergingIsSystemComponent.add(child.Id);
                    mapParentIsSystemComponentWithListOfChilderenIsSystemComponent.put(pIsSystemComponent.Id, mergingIsSystemComponent);
                }
            }
        }
        
        List<IS_System_Modification__c> isSystemModificationsToUpdate = new List<IS_System_Modification__c>();
        Map<Id, List<IS_System_Modification__c>> mapIsSystemModifications = new Map<Id, List<IS_System_Modification__c>>();
        for(IS_System_Modification__c isSysMod: [Select Id, IS_System_Component__c, Parent_Object__c, Object_API_Name__c , Object_Type__c
                                                 From IS_System_Modification__c Where IS_System_Component__c != null 
                                                 And IS_System_Component__r.Parent_IsSystemComponent__c !=null])
		{
            if(!mapIsSystemModifications.containsKey(isSysMod.IS_System_Component__c)) 
            {
                mapIsSystemModifications.put(isSysMod.IS_System_Component__c, new List<IS_System_Modification__c>());    
            }
            mapIsSystemModifications.get(isSysMod.IS_System_Component__c).add(isSysMod);
        }
        for(IS_System_Component__c parentIsSystemComp  : mapParentIsSystemComponent.values()) 
        {
            if(mapParentIsSystemComponentWithListOfChilderenIsSystemComponent.containsKey(parentIsSystemComp.Id)) 
            {
                for(Id isSystemCompIds : mapParentIsSystemComponentWithListOfChilderenIsSystemComponent.get(parentIsSystemComp.Id)) 
                {
                    if(mapIsSystemModifications.containsKey(isSystemCompIds))
                    {
                        for(IS_System_Modification__c isSysModifications : mapIsSystemModifications.get(isSystemCompIds))
                        {
                            IS_System_Modification__c isSysMod = new IS_System_Modification__c();
                            isSysMod.Id = isSysModifications.Id;
                            isSysMod.IS_System_Component__c = parentIsSystemComp.Id;
                            isSystemModificationsToUpdate.add(isSysMod);
                        }
                    }
                }        
            }
        }
        if(isSystemModificationsToUpdate.size() > 0) 
        {
            Util.BypassAllTriggers = true;
            Database.SaveResult[] isSystemModificationsToUpdateeResult = Database.update(isSystemModificationsToUpdate ,false);
            Util.BypassAllTriggers = false;
        }
    }
    
    global void finish(Database.BatchableContext BC) 
    {
        
    }
}