/*
Purpose         :   Test Class for "dynlistFieldFactory" apex class
Created By      :   Abhinav Sharma
Created Date    :   09/09/2021
Current Version :   v1.0
Revision Log    :   V_1.0 Created - Abhinav Sharma - 09/09/2021
*/
@isTest(seeAllData=false)
private without sharing class dynlistFieldFactory_Test 
{
    //this method is basically to test all the use cases associated with 
    //"dynlistFieldFactory.traverseFieldForDataGrid(Map<String, Schema.SObjectField> fieldsMap,String sOQLSelectFieldsString)" method
    @isTest(seeAllData=false)
    static void testtraverseFieldForDataGrid()
    {
        //List of Opportunity
        List<Opportunity> oppList = dynlistTestDataFactory.createListOfOpportunitiesTestData();
        System.assertEquals(5,oppList.size());
        
        //map to hold schema of Fields of Sobject
        Map<String, Schema.SObjectField> fieldsMap = dynlistUtilities.getFieldsMap(dynlistConstants.OBJECT_NAME_OPPORTUNITY);
        //Soql Selected Fields String
        String sOQLSelectFieldsString = dynlistConstants.CHAR_BLANK_STRING;
        
        for(String str : fieldsMap.keyset())
        {
            if(dynlistUtilities.getFieldIsAccessible(dynlistConstants.OBJECT_NAME_OPPORTUNITY, String.valueOf(fieldsMap.get(str))))
            {
                sOQLSelectFieldsString += String.valueOf(fieldsMap.get(str)) + dynlistConstants.CHAR_COMMA;
            }	
        }
        
        //List of dynlistField of Sobject for CUSTOM_TYPE_RATING
        List<dynlistField> fields = dynlistFieldFactory.traverseFieldSet(fieldsMap,sOQLSelectFieldsString, new Set<String>(),
                                                                         new Set<String>(), dynlistConstants.OBJECT_NAME_OPPORTUNITY);
        
        // Fill setOfObjFieldNameWithType CUSTOM_TYPE_RATING
        Set<String> setOfObjFieldNameWithType = new Set<String>();
        setOfObjFieldNameWithType.add(dynlistConstants.CUSTOM_TYPE_RATING + dynlistConstants.CHAR_DASH + dynlistConstants.OBJECT_NAME_OPPORTUNITY + dynlistConstants.CHAR_DASH + dynlistConstants.NAME_FIELD_NAME_LOWERCASE);
        
        //List of dynlistField of Sobject for CUSTOM_TYPE_RATING
        fields = dynlistFieldFactory.traverseFieldSet(fieldsMap,sOQLSelectFieldsString, new Set<String>(),
                                                      setOfObjFieldNameWithType, dynlistConstants.OBJECT_NAME_OPPORTUNITY);
        
        // Fill setOfObjFieldNameWithType CUSTOM_TYPE_MATCHING
        setOfObjFieldNameWithType = new Set<String>();
        setOfObjFieldNameWithType.add(dynlistConstants.CUSTOM_TYPE_MATCHING + dynlistConstants.CHAR_DASH + dynlistConstants.OBJECT_NAME_OPPORTUNITY + dynlistConstants.CHAR_DASH + dynlistConstants.NAME_FIELD_NAME_LOWERCASE);
        
        //List of dynlistField of Sobject for CUSTOM_TYPE_RATING
        fields = dynlistFieldFactory.traverseFieldSet(fieldsMap,sOQLSelectFieldsString, new Set<String>(),
                                                      setOfObjFieldNameWithType, dynlistConstants.OBJECT_NAME_OPPORTUNITY);
        
        
        // Fill setOfObjFieldNameWithType CUSTOM_TYPE_COLOR
        setOfObjFieldNameWithType = new Set<String>();
        setOfObjFieldNameWithType.add(dynlistConstants.CUSTOM_TYPE_COLOR + dynlistConstants.CHAR_DASH + dynlistConstants.OBJECT_NAME_OPPORTUNITY + dynlistConstants.CHAR_DASH + dynlistConstants.NAME_FIELD_NAME_LOWERCASE);
        //List of dynlistField of Sobject for CUSTOM_TYPE_RATING
        fields = dynlistFieldFactory.traverseFieldSet(fieldsMap,sOQLSelectFieldsString, new Set<String>(),
                                                      setOfObjFieldNameWithType, dynlistConstants.OBJECT_NAME_OPPORTUNITY);
        
        
        Schema.DescribeSObjectResult objectDescribe = Opportunity.sObjectType.getDescribe();
        Schema.FieldSet fieldSetObj = objectDescribe.FieldSets.getMap().get(System.Label.DYNLIST_DEFAULT_FIELD_SET_NAME);
        
        List<dynlistField> dynlistFieldList = dynlistFieldFactory.traverseFieldSet(fieldSetObj,fieldsMap, new Set<String>(),
                                                                                   new Set<String>(), dynlistConstants.OBJECT_NAME_OPPORTUNITY);
        System.assert(dynlistFieldList.size() > 0);
        
        //List of dynlistRow in which storing data
        List<dynlistRow> rows = new List<dynlistRow>();
        
        List<String> listOfAdditionalFieldsForQuery = new List<String>();
        listOfAdditionalFieldsForQuery.add('Stagename');
        Boolean objectNotHavingNameField = false;
        String groupByFieldName = dynlistConstants.CHAR_BLANK_STRING;
        String summarizeByFieldName = dynlistConstants.CHAR_BLANK_STRING;
        
        //wrapper that makes SOQL Query
        dynlistQueryWrapper dynListQryWrapper = new dynlistQueryWrapper();
        
        //calling utility function to get String of SOQL Query
        dynListQryWrapper = dynlistUtilities.getFieldsetQuery(dynlistConstants.OBJECT_NAME_OPPORTUNITY,
                                                              null,
                                                              null,
                                                              null,
                                                              null,
                                                              null,
                                                              true,
                                                              false,
                                                              true,
                                                              null,
                                                              sOQLSelectFieldsString,
                                                              null,
                                                              listOfAdditionalFieldsForQuery,
                                                              new Map<String, String>());
        
        Integer noOfMaxRowsAllowedToQuery = dynlistLimitsLogger.getMaxAllowedQueryRowsCount();
        
        //Sobject Data retrived from SOQL Query
        List<sObject> sObjectData = Database.query(dynListQryWrapper.queryString);
        
        System.assert(sObjectData.size() > 0);
        
        map<String, Set<Id>> mapOfObjAPINamewithRelatedRecordsIds = new Map<String, Set<Id>>();
        for (Sobject obj : sObjectData) 
        {
            for (dynlistField fDW : fields) 
            {
                if (
                    String.isNotBlank(fDW.name) &&
                    obj.get(fDW.name) != null &&
                    String.isNotBlank(String.valueOf(obj.get(fDW.name)))
                ) 
                {
                    if (fDW.type == dynlistConstants.FIELD_TYPE_REFERENCE) 
                    {
                        Id recordId = String.valueOf(obj.get(fDW.name));
                        String sObjName = recordId.getSObjectType().getDescribe().getName();
                        if (!mapOfObjAPINamewithRelatedRecordsIds.containsKey(sObjName)) 
                        {
                            mapOfObjAPINamewithRelatedRecordsIds.put(sObjName,new Set<Id>());
                        }
                        mapOfObjAPINamewithRelatedRecordsIds.get(sObjName).add(recordId);
                    }
                }
            }
        }
        
        //Map to hold Lookup data
        map<String, map<String, String>> mapOfLoopUpFieldsData = new Map<String, map<String, String>>();
        for (String i : mapOfObjAPINamewithRelatedRecordsIds.keySet()) 
        {
            Set<Id> temp = new Set<Id>();
            temp.addAll(mapOfObjAPINamewithRelatedRecordsIds.get(i));
            String soqlString ='SELECT Id, Name FROM ' + i + ' Where Id IN: temp';
            List<sobject> sObjData = new List<sObject>();
            sObjData = Database.query(soqlString);
            map<String, String> tempMap = new Map<String, String>();
            for (sObject obj : sObjData) 
            {
                if (!tempMap.containsKey(obj.Id)) 
                {
                    tempMap.put(String.valueOf(obj.get(dynlistConstants.ID_FIELD_NAME)),String.valueOf(obj.get(dynlistConstants.NAME_FIELD_NAME)));
                }
            }
            mapOfLoopUpFieldsData.put(i, tempMap);
        }
        
        //End here
        //Loop over data and traverse for fields and rows
        Integer rowNum = 1;
        for (Sobject obj : sObjectData) 
        {
            if(rowNum == 2)
            {
                dynlistRow row = new dynlistRow();
                //checking if object is having name field available on it
                if(!objectNotHavingNameField) 
                {
                    row.title = obj.get(dynlistConstants.NAME_FIELD_NAME) != null
                        ? String.valueOf(obj.get(dynlistConstants.NAME_FIELD_NAME))
                        : dynlistConstants.CHAR_BLANK_STRING;    
                }
                row.rowNumber = rowNum;
                row.recId = String.valueOf(obj.get(dynlistConstants.ID_FIELD_NAME));
                if (String.isNotBlank(groupByFieldName)) 
                {
                    row.groupByFieldValue = obj.get(groupByFieldName) != null
                        ? String.valueOf(
                            obj.get(groupByFieldName)
                        )
                        : dynlistConstants.CHAR_BLANK_STRING;
                }
                if (String.isNotBlank(summarizeByFieldName)) 
                {
                    row.summarizeByFieldValue = obj.get(summarizeByFieldName ) != null
                        ? String.valueOf( obj.get(summarizeByFieldName)) : null;
                }
                row.fields = dynlistFieldFactory.traverseFieldForDataGrid(
                    fields,
                    obj,
                    mapOfLoopUpFieldsData,
                    rowNum,
                    row.recId,
                    dynlistConstants.OBJECT_NAME_OPPORTUNITY,
                    dynlistConstants.NAME_FIELD_NAME,
                    dynlistConstants.CHAR_DESC,
                    new Set<String>()
                );
                
                row.selected = false;
                row.editMode = false;
                rows.add(row);
                rowNum++;
                
            }
            
            if(rowNum == 3)
            {
                dynlistRow row = new dynlistRow();
                
                //checking if object is having name field available on it
                if(!objectNotHavingNameField) 
                {
                    row.title = obj.get(dynlistConstants.NAME_FIELD_NAME) != null
                        ? String.valueOf(obj.get(dynlistConstants.NAME_FIELD_NAME))
                        : dynlistConstants.CHAR_BLANK_STRING;    
                }
                row.rowNumber = rowNum;
                row.recId = String.valueOf(obj.get(dynlistConstants.ID_FIELD_NAME));
                if (String.isNotBlank(groupByFieldName)) 
                {
                    row.groupByFieldValue = obj.get(groupByFieldName) != null
                        ? String.valueOf(
                            obj.get(groupByFieldName)
                        )
                        : dynlistConstants.CHAR_BLANK_STRING;
                }
                if (String.isNotBlank(summarizeByFieldName)) 
                {
                    row.summarizeByFieldValue = obj.get(summarizeByFieldName ) != null
                        ? String.valueOf( obj.get(summarizeByFieldName)) : null;
                }
                row.fields = dynlistFieldFactory.traverseFieldForDataGrid(
                    fields,
                    obj,
                    mapOfLoopUpFieldsData,
                    rowNum,
                    row.recId,
                    dynlistConstants.OBJECT_NAME_OPPORTUNITY,
                    dynlistConstants.NAME_FIELD_NAME,
                    'DESCS',
                    new Set<String>()
                );
                
                row.selected = false;
                row.editMode = false;
                rows.add(row);
                rowNum++;
            }
            
            if(rowNum == 4)
            {
                dynlistRow row = new dynlistRow();
                
                //checking if object is having name field available on it
                if(!objectNotHavingNameField) 
                {
                    row.title = obj.get(dynlistConstants.NAME_FIELD_NAME) != null
                        ? String.valueOf(obj.get(dynlistConstants.NAME_FIELD_NAME))
                        : dynlistConstants.CHAR_BLANK_STRING;    
                }
                row.rowNumber = rowNum;
                row.recId = String.valueOf(obj.get(dynlistConstants.ID_FIELD_NAME));
                if (String.isNotBlank(groupByFieldName)) 
                {
                    row.groupByFieldValue = obj.get(groupByFieldName) != null
                        ? String.valueOf(
                            obj.get(groupByFieldName)
                        )
                        : dynlistConstants.CHAR_BLANK_STRING;
                }
                if (String.isNotBlank(summarizeByFieldName)) 
                {
                    row.summarizeByFieldValue = obj.get(summarizeByFieldName ) != null
                        ? String.valueOf( obj.get(summarizeByFieldName)) : null;
                }
                row.fields = dynlistFieldFactory.traverseFieldForDataGrid(
                    fields,
                    obj,
                    mapOfLoopUpFieldsData,
                    rowNum,
                    row.recId,
                    dynlistConstants.OBJECT_NAME_OPPORTUNITY,
                    dynlistConstants.NAME_FIELD_NAME,
                    null,
                    new Set<String>()
                );
                
                row.selected = false;
                row.editMode = false;
                rows.add(row);
                rowNum++;
                
            }
            dynlistRow row = new dynlistRow();
            
            //checking if object is having name field available on it
            if(!objectNotHavingNameField) 
            {
                row.title = obj.get(dynlistConstants.NAME_FIELD_NAME) != null
                    ? String.valueOf(obj.get(dynlistConstants.NAME_FIELD_NAME))
                    : dynlistConstants.CHAR_BLANK_STRING;    
            }
            row.rowNumber = rowNum;
            row.recId = String.valueOf(obj.get(dynlistConstants.ID_FIELD_NAME));
            if (String.isNotBlank(groupByFieldName)) 
            {
                row.groupByFieldValue = obj.get(groupByFieldName) != null
                    ? String.valueOf(
                        obj.get(groupByFieldName)
                    )
                    : dynlistConstants.CHAR_BLANK_STRING;
            }
            if (String.isNotBlank(summarizeByFieldName)) 
            {
                row.summarizeByFieldValue = obj.get(summarizeByFieldName ) != null
                    ? String.valueOf( obj.get(summarizeByFieldName)) : null;
            }
            row.fields = dynlistFieldFactory.traverseFieldForDataGrid(
                fields,
                obj,
                mapOfLoopUpFieldsData,
                rowNum,
                row.recId,
                dynlistConstants.OBJECT_NAME_OPPORTUNITY,
                dynlistConstants.NAME_FIELD_NAME,
                dynlistConstants.CHAR_ASC,
                new Set<String>()
            );
            
            row.selected = false;
            row.editMode = false;
            rows.add(row);
            rowNum++;
        }
        System.assert(rows.size() > 0);
    }
    
    @isTest(seeAllData=true)
    static void testtraverseFieldForDataGrid2()
    {
        List<AccountHistory> aHs = [SELECT CreatedDate,Field,Id,IsDeleted,NewValue,OldValue FROM AccountHistory LIMIT 1];
        if(aHs != null && aHs.size() > 0) 
        {
            Map<String, Schema.SObjectField> fieldsMap = dynlistUtilities.getFieldsMap(dynlistConstants.OBJECT_NAME_ACCOUNT_HISTORY);
            String sOQLSelectFieldsString = dynlistConstants.CHAR_BLANK_STRING;
            
            for(String str : fieldsMap.keyset())
            {
                if(dynlistUtilities.getFieldIsAccessible(dynlistConstants.OBJECT_NAME_ACCOUNT_HISTORY, String.valueOf(fieldsMap.get(str))))
                {
                    sOQLSelectFieldsString += String.valueOf(fieldsMap.get(str)) + dynlistConstants.CHAR_COMMA;
                }	
            }
            
            //List of dynlistField of Sobject for CUSTOM_TYPE_RATING
            List<dynlistField> fields = dynlistFieldFactory.traverseFieldSet(fieldsMap, sOQLSelectFieldsString, new Set<String>(),
                                                                             new Set<String>(), dynlistConstants.OBJECT_NAME_ACCOUNT_HISTORY);
            
            dynlistFieldFactory.parentFieldNameSettedInConfiguration = 'AccountId';
            
            dynlistFieldFactory.traverseFieldForDataGrid(
                fields,
                new AccountHistory(),
                new map<String, map<String, String>>(),
                1,
                aHs[0].Id,
                dynlistConstants.OBJECT_NAME_ACCOUNT_HISTORY,
                dynlistConstants.ID_FIELD_NAME,
                dynlistConstants.CHAR_ASC,
                new Set<String>()
            );            
        }
    }     
}