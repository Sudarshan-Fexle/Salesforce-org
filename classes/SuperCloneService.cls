/*
Purpose         :   Utility/Controller class to have record cloning based methods/logics.

Created By      :   Abhinav Sharma

Created Date    :   11/25/2019

Current Version :   v1.0

Revision Log    :   V_1.0 Created
		:   V_1.1 - Modified By Dipesh Gupta, Issue--CR13887--QA--00009627 (CR-20200325-13887) to Change the reference of Es Campaign to the Project.
		:   V_1.2 - 05/20/2020 - CR-20200514-14041 - Victor Hanson - updated to remove excluded fields
		:   V_1.3 - Modified By - Neha Sharma - 04/30/2021 - CR-20210323-15016 - populate drop type on job ticket
*/
public without sharing class SuperCloneService 
{
    public Id doClone(String parentId, String projectId) 
    {
        String jobTicketRecordTypeId = Schema.SObjectType.Job_Ticket__c.getRecordTypeInfosByDeveloperName().get('Job_Ticket').getRecordTypeId();
        if(String.isNotBlank(parentId) && parentId instanceOf Id) 
        {
            Set<String> querySobject = new Set<String>();
            Map<String, String> mapObjApinameWithFieldToBeNull = new Map<String, String>();
            for(Super_Clone_Objects__mdt m : [SELECT Id, DeveloperName, Label, API_Name__c, Fields_To_Set_As_Blank__c
                                              FROM Super_Clone_Objects__mdt
                                              WHERE API_Name__c != null AND Applied_To__c = null
                                             ])
            {
                querySobject.add(m.API_Name__c) ;  
                
                //Check if there is any field for the object that needs to be nullified.
                if(String.isNotblank(m.Fields_To_Set_As_Blank__c))
                {
                    mapObjApinameWithFieldToBeNull.put(m.API_Name__c, m.Fields_To_Set_As_Blank__c);
                }
            }   
            if(querySobject.size() > 0) 
            {
            	Map<String,String> so = new Map<String,String>();
                Map<String,String> so1 = new Map<String,String>();
                for (Schema.ChildRelationship cr: DatabaseUtilities.getObjectTypeOnBasisOfIdValue(parentId).getDescribe().getChildRelationships())
                {
                    if(cr.getField().getDescribe().isAccessible()
                       && cr.getField().getDescribe().isCreateable()
                       && cr.getField().getDescribe().isAccessible()
                       && cr.getRelationshipName()!=null)
                    {
                        if(querySobject.contains(''+cr.getChildSObject()))
                        {
                            so.put(''+cr.getChildSObject(), ''+cr.getRelationshipName());
                            so1.put(''+cr.getRelationshipName(), ''+cr.getField());
                        }
                    }
                }
                if(so.values().size() > 0) 
                {
                    List<String> subqueries = prepareSubqueries(so);
                    Set <String> fieldMap = DatabaseUtilities.getObjectTypeOnBasisOfIdValue(parentId).getDescribe().fields.getMap().keySet();
                    //05/20/2020 - CR-20200514-14041 - Victor Hanson - updated code below to remove excluded fields
                    //if there are fields to exclude, remove them from the field map
                    String objAPIName = String.valueOf(DatabaseUtilities.getObjectTypeOnBasisOfIdValue(parentId));
                    if (mapObjApinameWithFieldToBeNull.containsKey(objAPIName)) {
                        String fieldsToExclude = mapObjApinameWithFieldToBeNull.get(objAPIName);
                        if (!String.isBlank(fieldsToExclude)) {
                            //remove excluded values from query
                            fieldMap.removeAll(fieldsToExclude.toLowerCase().split(','));
                        }
                    }
                    List<String> finalFields = new List<String>() ;
                    finalFields.addAll(fieldMap);
                    if(finalFields.size() > 0) 
                    {
                        String query =
                            'SELECT ' + String.join(finalFields, ',') +
                            ','+String.join(subqueries, ',') +
                            ' FROM ' +DatabaseUtilities.getObjectTypeOnBasisOfIdValue(parentId).getDescribe().getName() +
                            ' WHERE Id = \''+parentId+'\'';
                        
                        
                        List<Sobject> parentObj = Database.query(query);
                        if(parentObj != null && parentObj.size() > 0) 
                        {
                            Sobject parentRecord = parentObj[0];
                            if(String.isNotBlank(projectId)) 
                            {
                                //Changed ES Campaign to Project since we changed the Origination point for Job tickets. 
                                parentRecord.put('Project__c', projectId);
                                parentRecord.put('RecordTypeId', jobTicketRecordTypeId);
                                if(parentRecord.getSObjectType() == Schema.Job_Ticket__c.getSObjectType()) 
                                {
                                    Job_Ticket__c jTicket = (Job_Ticket__c)parentObj[0];
                            		parentRecord.put('Descriptive_Name__c', jTicket.Template_Name__c);
                                    
                            	    //Added By - Neha Sharma - 04/30/2021 - CR-20210323-15016 - populate drop type on job ticket
                                    parentRecord.put('Drop_Type__c','Pre Planned');
                                }
                            }
                            
                            for(Job_Ticket_MtM__c jTMTM : [Select Job_Ticket_Component__r.Component__c,Job_Ticket_Component__r.Size__c, Job_Ticket__c, 
                                                           Job_Ticket__r.Vendor_Type__c, Job_Ticket_Component__r.Qualifies_for_Digital_Printer__c,
                                                           Job_Ticket__r.Program__r.Program_Formal_Name__c, Job_Ticket__r.Program__c
                                                           From Job_Ticket_MtM__c 
                                                           Where Job_Ticket__c =: parentId 
                                                           And Job_Ticket_Component__r.Component__c != null
                                                           AND Job_Ticket_Component__r.Size__c != null])
                            {
                                Boolean isCheckCompSize = jTMTM.Job_Ticket_Component__r.Size__c.contains('#10');
                                if(isCheckCompSize && jTMTM.Job_Ticket_Component__r.Component__c == 'Envelope' && (jtMtM.Job_Ticket__r.Vendor_Type__c == null || jtMtM.Job_Ticket__r.Vendor_Type__c != null) 
                                   && (jtMtM.Job_Ticket__r.Program__c == null || 
                                       (jtMtM.Job_Ticket__r.Program__c != null && 
                                        !jtMtM.Job_Ticket__r.Program__r.Program_Formal_Name__c.containsIgnoreCase(Constants.FULFILLMENT))))
                                {
                                	parentRecord.put('Vendor_Type__c','Digital');    
                                }
                                else
                                   parentRecord.put('Vendor_Type__c','Offset'); 
                            }
                            
                            Sobject clonedRecord = parentRecord.clone();
                            Util.ByPassAllTriggers = false;
                            insert clonedRecord;
                            
                            
                            List<sObject> childObjects = cloneChildren(parentRecord, clonedRecord, 
                                                                       so, so1, mapObjApinameWithFieldToBeNull);
                            
                            //Modified by - Dipesh Gupta- 04/29/2020 - CR-20200211-13722 - Components are added to Job Ticket with wrong Component Type

                            Set<Id> setOfJobTicketComponentId = new Set<Id>();
                            Map<Id,String> mapOfJTCIdWithType = new Map<Id,String>();
                            
                            for(sObject sobjChild : childObjects)
                            {
                            	 setOfJobTicketComponentId.add((Id)sobjChild.get('Job_Ticket_Component__c'));   
                            }
                            
                            List<Job_Ticket_MtM__c> listOfJobTicketMtM = [SELECT Id, Job_Ticket_Component__c,
                                                                          Component_type__c, Job_Ticket_Component__r.Component__c 
                                                                          FROM Job_Ticket_MtM__c 
                                                                          WHERE Job_Ticket_Component__c IN : setOfJobTicketComponentId
                                                                          AND Job_Ticket__c =:parentId];
                            
                            for(Job_Ticket_MtM__c jTM : listOfJobTicketMtM)
                            {
                                mapOfJTCIdWithType.put(jTM.Job_Ticket_Component__c,jTM.Job_Ticket_Component__r.Component__c);
                            }
                            
                            for(sObject sobjChild : childObjects)
                            {
                                if(mapOfJTCIdWithType.containsKey((Id)sobjChild.get('Job_Ticket_Component__c')))
                            	sobjChild.put('Component_Type__c',mapOfJTCIdWithType.get((Id)sobjChild.get('Job_Ticket_Component__c')));   
                            }//End
                           
                            insert childObjects;
                            Util.ByPassAllTriggers = false;
                            
                            return clonedRecord.Id; 
                        }
                    }
                }    
            }
        }
        return null;
    }
    
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
                    record.put(childRelatedListObjects1.get(childObjectDefinition), child.Id);
                }
                childObjects.addAll(records);
            }
        }
        return childObjects;
    }
    
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
	
}