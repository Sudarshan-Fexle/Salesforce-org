/*
Purpose         :   Utility/Controller class to have record cloning based methods/logics.

Created By      :   Dipesh Gupta

Created Date    :   04/06/2020

Current Version :   v1.0

Revision Log    :   V_1.0 Created
		:   V_1.1 - Modified By - Abhinav Sharma - CR-20210510-15129 - 05/12/2021
		:   V_1.2 - Modified By - Neha Sharma - 04/30/2021 - CR-20210323-15016 - populate drop type on job ticket

*/
public without sharing class SuperCloneServiceForCloneJobTicket 
{
    Map<Id, Id> mapOldMtMIdWithNewCloneMtMId = new Map<Id, Id>();
    
    public Id doClone(String parentId, String esCampaignId, Id projectId, String fiscalYearValue, Boolean keepColorsVlaue) 
    {
        if(String.isNotBlank(parentId) && parentId instanceOf Id && String.isNotBlank(esCampaignId) && String.isNotBlank(projectId) && String.isNotBlank(fiscalYearValue))
        {
            if(keepColorsVlaue)
            {
                String jobTicketRecordTypeId = Schema.SObjectType.Job_Ticket__c.getRecordTypeInfosByDeveloperName().get('Job_Ticket').getRecordTypeId();
                Set<String> querySobject = new Set<String>();
                Map<String, String> mapOfObjApiNameWithFieldToBeNull = new Map<String, String>();
                
                for(Super_Clone_Objects__mdt m : [SELECT Id, DeveloperName, Label, API_Name__c, Fields_To_Set_As_Blank__c
                                                  FROM Super_Clone_Objects__mdt
                                                  WHERE API_Name__c != null AND Applied_To__c != null
                                                 ])
                {
                    querySobject.add(m.API_Name__c) ;  
                    
                    //Check if there is any field for the object that needs to be nullified.
                    if(String.isNotblank(m.Fields_To_Set_As_Blank__c))
                    {
                        mapOfObjApiNameWithFieldToBeNull.put(m.API_Name__c, m.Fields_To_Set_As_Blank__c);
                    }
                }
                
                if(querySobject.size() > 0)
                {
                    Map<String,String> mapOfChildObjWithChildRelationshipName = new Map<String,String>();
                    Map<String,String> mapOfChildRelationshipNameWithFields = new Map<String,String>();
                    for (Schema.ChildRelationship cr: DatabaseUtilities.getObjectTypeOnBasisOfIdValue(parentId).getDescribe().getChildRelationships())
                    {
                        if(cr.getField().getDescribe().isAccessible()
                           && cr.getField().getDescribe().isCreateable()
                           && cr.getField().getDescribe().isAccessible()
                           && cr.getRelationshipName()!=null)
                        {
                            if(querySobject.contains(''+cr.getChildSObject()))
                            {
                                mapOfChildObjWithChildRelationshipName.put(''+cr.getChildSObject(), ''+cr.getRelationshipName());
                                mapOfChildRelationshipNameWithFields.put(''+cr.getRelationshipName(), ''+cr.getField());
                            }
                        }
                    }
                    if(mapOfChildObjWithChildRelationshipName.size() > 0)
                    {
                        List<String> getSubQueries = prepareSubqueries(mapOfChildObjWithChildRelationshipName);
                        Set <String> fieldMap = DatabaseUtilities.getObjectTypeOnBasisOfIdValue(parentId).getDescribe().fields.getMap().keySet(); // Chec
                        List<String> finalFields = new List<String>() ;
                        finalFields.addAll(fieldMap);
                        if(finalFields.size() > 0)
                        {
                            String query =
                                'SELECT ' + String.join(finalFields, ',') +
                                ','+String.join(getSubQueries, ',') +
                                ' FROM ' +DatabaseUtilities.getObjectTypeOnBasisOfIdValue(parentId).getDescribe().getName() +
                                ' WHERE Id = \''+parentId+'\'';
                            
                            List<Sobject> parentObject = Database.query(query);
                            if(parentObject != null && parentObject.size() > 0)
                            {
                                Sobject parentRecord = parentObject[0];
                                if(String.isNotBlank(esCampaignId)) 
                                { 
                                    parentRecord.put('Fiscal_Year__c',fiscalYearValue);
                                    parentRecord.put('RecordTypeId', jobTicketRecordTypeId);
                                    parentRecord.put('Project__c',projectId);
                                    parentRecord.put('Status__c','Draft');
                                    parentRecord.put('Auto_Generated__c',false);
                                    
                                    //Added By - Neha Sharma - 04/30/2021 - CR-20210323-15016 - populate drop type on job ticket
                                    parentRecord.put('Drop_Type__c','Pre Planned');
                                    
                                    String objectSObejctType = String.valueOf(parentRecord.getSObjectType());
                                    
                                    if(mapOfObjApiNameWithFieldToBeNull != null
                                       && mapOfObjApiNameWithFieldToBeNull.containsKey(objectSObejctType)
                                       && mapOfObjApiNameWithFieldToBeNull.get(objectSObejctType) != null)
                                    {
                                        List<String> fieldList = new List<String>();
                                        
                                        //Get the field list.
                                        if(mapOfObjApiNameWithFieldToBeNull.get(objectSObejctType).contains(',')) 
                                        {
                                            fieldList.addAll(mapOfObjApiNameWithFieldToBeNull.get(objectSObejctType).split(','));
                                        }
                                        else
                                        {
                                            fieldList.add(mapOfObjApiNameWithFieldToBeNull.get(objectSObejctType));
                                        }
                                        for(String fieldName : fieldList)
                                        {
                                            parentRecord.put(fieldName.trim(), null);
                                        }
                                    }
                                    
                                    if(parentRecord.getSObjectType() == Schema.Job_Ticket__c.getSObjectType()) 
                                    {
                                        Job_Ticket__c jTicket = (Job_Ticket__c)parentObject[0];
                                        parentRecord.put('Descriptive_Name__c', jTicket.Template_Name__c);
                                        parentRecord.put('Name', jTicket.Name);
                                    }
                                }
                                
				// Commented By - Abhinav Sharma - CR-20210510-15129 - 05/12/2021
                                Sobject clonedParentRecord = parentRecord.clone();
                                //Util.ByPassAllTriggers = true;
                                //JobTicketTriggerHelper.Bypass_DublicateJobTicket = true;
                                insert clonedParentRecord;
                                //JobTicketTriggerHelper.Bypass_DublicateJobTicket = false;
                                
                                List<sObject> childObjects = cloneChildren(parentRecord, clonedParentRecord,mapOfChildObjWithChildRelationshipName, 
                                                                           mapOfChildRelationshipNameWithFields, mapOfObjApiNameWithFieldToBeNull);
                                
                                insert childObjects;
                                
                                Map<String, String> mapOfGrandChildObjNameWithChildRelationshipName = new Map<String,String>();
                                Map<String, String> mapOfGrandChildRelationshipNameWithField = new Map<String,String>();
                                Map<Id,List<SObject>> mapOfJobTicketMtMWithAF = new Map<Id,List<SObject>>();
                                
                                querySobject.add('Associated_Features__c');
                                
                                if(querySobject.size() > 0)
                                {
                                    for (Schema.ChildRelationship cr: DatabaseUtilities.getObjectTypeOnBasisOfObjectName('Job_Ticket_MtM__c').getDescribe().getChildRelationships())
                                    {
                                        if(cr.getField().getDescribe().isAccessible()
                                           && cr.getField().getDescribe().isCreateable()
                                           && cr.getField().getDescribe().isAccessible()
                                           && cr.getRelationshipName()!=null)
                                        {
                                            if(querySobject.contains(''+cr.getChildSObject()))
                                            {
                                                mapOfGrandChildObjNameWithChildRelationshipName.put(''+cr.getChildSObject(), ''+cr.getRelationshipName());
                                                mapOfGrandChildRelationshipNameWithField.put(''+cr.getRelationshipName(), ''+cr.getField());
                                            }
                                        }
                                    }
                                    
                                    List<String> grandChildSubqueries = prepareSubqueries(mapOfGrandChildObjNameWithChildRelationshipName);
                                    Set <String> secondParentfieldMap = DatabaseUtilities.getObjectTypeOnBasisOfObjectName('Job_Ticket_MtM__c').getDescribe().fields.getMap().keySet();
                                    List<String> secondParentfinalFields = new List<String>() ;
                                    secondParentfinalFields.addAll(secondParentfieldMap);
                                    if(secondParentfinalFields.size() > 0) 
                                    {
                                        String query1 =
                                            'SELECT ' + String.join(secondParentfinalFields, ',') +
                                            ','+String.join(grandChildSubqueries, ',') +
                                            ' FROM ' +DatabaseUtilities.getObjectTypeOnBasisOfObjectName('Job_Ticket_MtM__c').getDescribe().getName() +
                                            ' WHERE Job_Ticket__c = \''+parentId+'\'';
                                        
                                        List<Job_Ticket_MTM__c> listOfMtMOrGrandChildRecords = Database.query(query1);
                                        for(Job_Ticket_MTM__c mtm  : listOfMtMOrGrandChildRecords){ 
                                            mapOfJobTicketMtMWithAF.put(mtm.Id,mtm.Associated_Features__r);
                                        }
                                        
                                        List<sObject> getresult = cloneGrandChildren(mapOfJobTicketMtMWithAF,
                                                                                     mapOfGrandChildObjNameWithChildRelationshipName,childObjects);
                                        insert getresult;
                                    }
                                    Util.ByPassAllTriggers = false;
                                    return clonedParentRecord.Id;
                                }
                            }
                        }
                    }
                }
            }
            else
            {
                String jobTicketRecordTypeId = Schema.SObjectType.Job_Ticket__c.getRecordTypeInfosByDeveloperName().get('Job_Ticket').getRecordTypeId();
                Set<String> querySobject = new Set<String>();
                Map<String, String> mapOfObjApiNameWithFieldToBeNull = new Map<String, String>();
                
                for(Super_Clone_Objects__mdt m : [SELECT Id, DeveloperName, Label, API_Name__c, Fields_To_Set_As_Blank__c
                                                  FROM Super_Clone_Objects__mdt
                                                  WHERE API_Name__c != null AND Applied_To__c != null
                                                 ])
                {
                    querySobject.add(m.API_Name__c) ;  
                    
                    //Check if there is any field for the object that needs to be nullified.
                    if(String.isNotblank(m.Fields_To_Set_As_Blank__c))
                    {
                        mapOfObjApiNameWithFieldToBeNull.put(m.API_Name__c, m.Fields_To_Set_As_Blank__c);
                    }
                }
                
                if(querySobject.size() > 0)
                {
                    Map<String,String> mapOfChildObjWithChildRelationshipName = new Map<String,String>();
                    Map<String,String> mapOfChildRelationshipNameWithFields = new Map<String,String>();
                    for (Schema.ChildRelationship cr: DatabaseUtilities.getObjectTypeOnBasisOfIdValue(parentId).getDescribe().getChildRelationships())
                    {
                        if(cr.getField().getDescribe().isAccessible()
                           && cr.getField().getDescribe().isCreateable()
                           && cr.getField().getDescribe().isAccessible()
                           && cr.getRelationshipName()!=null)
                        {
                            if(querySobject.contains(''+cr.getChildSObject()))
                            {
                                mapOfChildObjWithChildRelationshipName.put(''+cr.getChildSObject(), ''+cr.getRelationshipName());
                                mapOfChildRelationshipNameWithFields.put(''+cr.getRelationshipName(), ''+cr.getField());
                            }
                        }
                    }
                    if(mapOfChildObjWithChildRelationshipName.size() > 0)
                    {
                        List<String> getSubQueries = prepareSubqueries(mapOfChildObjWithChildRelationshipName);
                        Set <String> fieldMap = DatabaseUtilities.getObjectTypeOnBasisOfIdValue(parentId).getDescribe().fields.getMap().keySet(); // Chec
                        List<String> finalFields = new List<String>() ;
                        finalFields.addAll(fieldMap);
                        if(finalFields.size() > 0)
                        {
                            String query =
                                'SELECT ' + String.join(finalFields, ',') +
                                ','+String.join(getSubQueries, ',') +
                                ' FROM ' +DatabaseUtilities.getObjectTypeOnBasisOfIdValue(parentId).getDescribe().getName() +
                                ' WHERE Id = \''+parentId+'\'';
                            
                            List<Sobject> parentObject = Database.query(query);
                            
                            if(parentObject != null && parentObject.size() > 0)
                            {
                                Sobject parentRecord = parentObject[0];
                                if(String.isNotBlank(esCampaignId)) 
                                { 
                                    parentRecord.put('Fiscal_Year__c',fiscalYearValue);
                                    parentRecord.put('RecordTypeId', jobTicketRecordTypeId);
                                    parentRecord.put('Project__c',projectId);
                                    parentRecord.put('Status__c','Draft');
                                    parentRecord.put('Auto_Generated__c',false);
                                    
                                    //Added By - Neha Sharma - 04/30/2021 - CR-20210323-15016 - populate drop type on job ticket
                                    parentRecord.put('Drop_Type__c','Pre Planned');
                                    
                                    String objectSObejctType = String.valueOf(parentRecord.getSObjectType());
                                    
                                    if(mapOfObjApiNameWithFieldToBeNull != null
                                       && mapOfObjApiNameWithFieldToBeNull.containsKey(objectSObejctType)
                                       && mapOfObjApiNameWithFieldToBeNull.get(objectSObejctType) != null)
                                    {
                                        List<String> fieldList = new List<String>();
                                        
                                        //Get the field list.
                                        if(mapOfObjApiNameWithFieldToBeNull.get(objectSObejctType).contains(',')) 
                                        {
                                            fieldList.addAll(mapOfObjApiNameWithFieldToBeNull.get(objectSObejctType).split(','));
                                        }
                                        else
                                        {
                                            fieldList.add(mapOfObjApiNameWithFieldToBeNull.get(objectSObejctType));
                                        }
                                        for(String fieldName : fieldList)
                                        {
                                            parentRecord.put(fieldName.trim(), null);
                                        }
                                    }
                                    
                                    if(parentRecord.getSObjectType() == Schema.Job_Ticket__c.getSObjectType()) 
                                    {
                                        Job_Ticket__c jTicket = (Job_Ticket__c)parentObject[0];
                                        parentRecord.put('Descriptive_Name__c', jTicket.Template_Name__c);
                                        parentRecord.put('Name', jTicket.Name);
                                    }
                                }
                                
                                Sobject clonedParentRecord = parentRecord.clone();
                                
				//Commented By - Abhinav Sharma - CR-20210510-15129 - 05/12/2021
                                //Util.ByPassAllTriggers = true;
                                //JobTicketTriggerHelper.Bypass_DublicateJobTicket = true;
                                insert clonedParentRecord;
                                //JobTicketTriggerHelper.Bypass_DublicateJobTicket = false;
                                
                                List<sObject> childObjects = cloneChildren(parentRecord, clonedParentRecord,mapOfChildObjWithChildRelationshipName, 
                                                                           mapOfChildRelationshipNameWithFields, mapOfObjApiNameWithFieldToBeNull);
                                
                                insert childObjects;
                                Util.ByPassAllTriggers = false;
                                return clonedParentRecord.Id;
                            }
                        }
                    }
                }
            }
        }
        return null;
    }
    
    //Method to have clone Child Record
    private List<sObject> cloneChildren(
        Sobject parent,
        Sobject child,
        Map<String , String> childRelatedListObjects,
        Map<String , String> childRelatedListObjects1,
        Map<String, String> mapObjApinameWithFieldToBeNull
    )
    {
        List<sObject> childObjects = new List<SObject>();
        for (String childObjectDefinition : childRelatedListObjects.values())
        {
            List<sObject> parentRecords = parent.getSObjects(childObjectDefinition);
            if (parentRecords != null)
            {
                List<sObject> records = parentRecords.deepClone();
                for (sObject record : records)
                {
                    //Check if the record's Sobject Type is matched with the Map,
                    //this map contains the comma seprated field list which is going to be nullified during clone.
                    
                    String objectSObejctType = String.valueOf(record.getSObjectType());
                    
                    if(mapObjApinameWithFieldToBeNull != null
                       && mapObjApinameWithFieldToBeNull.containsKey(objectSObejctType)
                       && mapObjApinameWithFieldToBeNull.get(objectSObejctType) != null)
                    {
                        List<String> fieldList = new List<String>();
                        
                        //Get the field list.
                        if(mapObjApinameWithFieldToBeNull.get(objectSObejctType).contains(',')) 
                        {
                            fieldList.addAll(mapObjApinameWithFieldToBeNull.get(objectSObejctType).split(','));
                        }
                        else
                        {
                            fieldList.add(mapObjApinameWithFieldToBeNull.get(objectSObejctType));
                        }
                        for(String fieldName : fieldList)
                        {
                            record.put(fieldName.trim(), null);
                        }
                    }
                    System.debug('childObjectDefinition ' + childRelatedListObjects1.get(childObjectDefinition));
                    record.put(childRelatedListObjects1.get(childObjectDefinition), child.Id);
                }
                childObjects.addAll(records);
            }
        }
        return childObjects;
    }
    
    //Method to have prepareSubquries for Parent Object
    private List<String> prepareSubqueries(Map<String , String> childrelatedListObjects)
    {
        List<String> subqueries = new List<String>();
        for(String childObject : childrelatedListObjects.keySet())
        {
            List<String> childFields = new List<String>();
            Map <String, Schema.SObjectField> fieldMap = DatabaseUtilities.getObjectDescribeOnBasisOfObjectName(childObject).fields.getMap();
            for(Schema.SObjectField sof : fieldMap.values())
            {
                DescribeFieldResult dfr = sof.getDescribe();
                if(dfr.isCreateable())
                {
                    childFields.add(dfr.getName());
                }
            }
            if(!childFields.isEmpty())
            {
                String query = '(SELECT ' + String.join(childFields, ',')
                    + ' FROM ' + childrelatedListObjects.get(childObject) + ')';
                subqueries.add(query);
            }
        }
        return subqueries;
    }
    
    //Method to have clone childs of Child Object 
    private List<sObject> cloneGrandChildren(
        Map<Id,List<Sobject>> mapOfASJobTicket,
        Map<String,String> childRelatedListObjects,
        List<sObject> childObjectsClone
    )
    {
        List<sObject> childObjects = new List<SObject>();
        //for(sObject obj : childObjectsClone)
        //{ 
            Integer i = 0;
            for(Id objId : mapOfASJobTicket.keySet())
            {
                for(sObject sobj :  mapOfASJobTicket.get(objId))
                {
                    Sobject cloneObj = sobj.Clone();
                    if(String.valueOf(cloneObj.getSObjectType()) == 'Associated_Features__c' && cloneObj.get('Job_Ticket_MtM__c') == objId)
                    { 
                        cloneObj.put('Job_Ticket_MtM__c', childObjectsClone[i].Id);
                    }
                    childObjects.add(cloneObj);
                }
                i++;
            }
        //}
        return childObjects;
    }
}