/*
Purpose         :   Data Grid Controller Class (Dynamic Related List)
Created By      :   Abhinav Sharma
Created Date    :   07/24/2021
Current Version :   v1.0
Revision Log    :   V_1.0 Created - Abhinav Sharma - 07/24/2021
*/
@SuppressWarnings('PMD.UnusedLocalVariable')
public with sharing class dynlistDataGridController 
{
    private static String pkgPrefix = null;
    
    @AuraEnabled(cacheable=false)
    public static dynlistDataGrid getDataRecords(
        Map<String, Object> dataGridRequest
    )
    {
        dynlistDataGrid result = new dynlistDataGrid();
        dynlistQueryWrapper dynListQryWrapper = new dynlistQueryWrapper();
        try 
        {
            if (dataGridRequest != null) 
            {
                List<dynlistRow> rows = new List<dynlistRow>();
                dynlistDataGridRequestWrapper dataGridRequestWrapper = dynlistDataGridController.getRequestWrapperBasedDetails(dataGridRequest);
                
                if (dynlistDataGridUtilities.doPrimaryValidations(dataGridRequestWrapper) != null) 
                {
                    result.setError(dynlistDataGridUtilities.doPrimaryValidations(dataGridRequestWrapper));
                    return result;
                }
                
                Schema.SObjectType sObjectTypeObj = dynlistUtilities.getObjectTypeOnBasisOfObjectName(dataGridRequestWrapper.objectName);
                
                if(pkgPrefix == null)
                {
                    pkgPrefix = dynlistUtilities.getPackagePrefix();
                }
                
                if (sObjectTypeObj == null) 
                {
                    sObjectTypeObj = dynlistUtilities.getObjectTypeOnBasisOfObjectName(pkgPrefix + dataGridRequestWrapper.objectName);
                }
                
                if (sObjectTypeObj == null) 
                {
                    result.setError(System.Label.DYNLIST_INVALID_OBJECT_NAME);
                    return result;
                }
                
                Schema.DescribeSObjectResult objectDescribe = sObjectTypeObj.getDescribe();
                if (objectDescribe == null) 
                {
                    result.setError(System.Label.DYNLIST_ERROR_UNABLE_TO_DESCRIBE_OBJECT);
                    return result;
                }
                
                result.viewable = (objectDescribe.isAccessible());
                result.isObjAccessible = (objectDescribe.isAccessible());
                result.isObjCreatable = (objectDescribe.isCreateable());
                result.isObjUpdatable = (objectDescribe.isUpdateable());
                result.isObjDeletable = (objectDescribe.isDeletable());
                result.isUndeletable = (objectDescribe.isUndeletable());
                result.isCustom = (objectDescribe.isCustom());
                
                if (result.viewable) 
                {
                    Schema.FieldSet fieldSetObj;
                    
                    if (String.isNotBlank(dataGridRequestWrapper.fieldsetName)) 
                    {
                        fieldSetObj = objectDescribe.FieldSets.getMap().get(dataGridRequestWrapper.fieldsetName);
                        if (fieldSetObj == null) 
                        {
                            fieldSetObj = objectDescribe.FieldSets.getMap().get(pkgPrefix + dataGridRequestWrapper.fieldsetName);
                        }
                        if (fieldSetObj == null) 
                        {
                            result.setError(System.Label.DYNLIST_INVALID_FIELD_SET_NAME);
                            return result;
                        }
                    }
                    
                    Boolean objectNotHavingNameField = false;
                    Set<String> setOfObjectForNameFieldNotAvailable = new Set<String>();
                    Set<String> setOfObjectsAPINameForWhichNewWillBeDisabled = new Set<String>();
                    Set<String> setOfObjectsAPINameForWhichEditWillBeDisabled = new Set<String>();
                    Set<String> setOfObjectsAPINameForWhichDeleteWillBeDisabled = new Set<String>();
                    
                    Map<String, Dynamic_Related_List_Manager__mdt> mapOfDynamicRelatedListManagerSettings = dynlistUtilities.getMapOfDynamicRelatedListManager();
                    Map<String, String> mapOfNonQueryableFields = new Map<String, String>();
                    Set<String> setOfCustomTypesSettings = new Set<String>();
                    if(mapOfDynamicRelatedListManagerSettings != null) 
                    {
                        Set<String> setOfCustomTypes = new Set<String>();
                        setOfCustomTypes = dynlistConstants.SET_OF_CUSTOM_TYPES;
                        for(String nameOfDynListSetting : mapOfDynamicRelatedListManagerSettings.keySet())
                        {
                            if(mapOfDynamicRelatedListManagerSettings.get(nameOfDynListSetting) != null) 
                            {
                                Dynamic_Related_List_Manager__mdt dynlistSetting = mapOfDynamicRelatedListManagerSettings.get(nameOfDynListSetting);
                                if(dynlistSetting != null 
                                   && String.isNotBlank(dynlistSetting.Type__c) 
                                   && String.isNotBlank(dynlistSetting.Object_API_Name__c)
                                   && dynlistSetting.Active__c
                                  ) 
                                {
                                    //Checking if this is object which is not having name field available on it
                                    if(dynlistSetting.Type__c.equalsIgnoreCase(dynlistConstants.TYPE_OBJECT_NOT_HAVING_NAME_FIELD)) 
                                    {
                                        setOfObjectForNameFieldNotAvailable.add(dynlistSetting.Object_API_Name__c.toLowerCase());
                                    }
                                    
                                    //Checking if this is object for whom NEW options will be disabled
                                    if(dynlistSetting.Type__c.equalsIgnoreCase(dynlistConstants.TYPE_OBJECT_DISABLE_NEW_OPTION)) 
                                    {
                                        setOfObjectsAPINameForWhichNewWillBeDisabled.add(dynlistSetting.Object_API_Name__c.toLowerCase());
                                    } 
                                    
                                    //Checking if this is object for whom EDIT options will be disabled
                                    if(dynlistSetting.Type__c.equalsIgnoreCase(dynlistConstants.TYPE_OBJECT_DISABLE_EDIT_OPTION)) 
                                    {
                                        setOfObjectsAPINameForWhichEditWillBeDisabled.add(dynlistSetting.Object_API_Name__c.toLowerCase());
                                    }    
                                    
                                    //Checking if this is object for whom Delete options will be disabled
                                    if(dynlistSetting.Type__c.equalsIgnoreCase(dynlistConstants.TYPE_OBJECT_DISABLE_DELETE_OPTION)) 
                                    {
                                        setOfObjectsAPINameForWhichDeleteWillBeDisabled.add(dynlistSetting.Object_API_Name__c.toLowerCase());
                                    }
                                    
                                    //Checking if this is object for which we have non queryable fields
                                    if(dynlistSetting.Type__c.equalsIgnoreCase(dynlistConstants.TYPE_OBJECT_NON_QUERYABLE_FIELDS)) 
                                    {
                                        if(String.isNotBlank(dynlistSetting.Non_Queryable_Fields__c)) 
                                        {
                                            mapOfNonQueryableFields.put(dynlistSetting.Object_API_Name__c.toLowerCase(), dynlistSetting.Non_Queryable_Fields__c.trim());        
                                        }
                                    }
                                    
                                    if(setOfCustomTypes.contains(dynlistSetting.Type__c)) 
                                    {
                                        if(String.isNotBlank(dynlistSetting.Synonym_Field_API_Name__c)) 
                                        {
                                            String tempKey = dynlistConstants.CHAR_BLANK_STRING;
                                            if(dynlistSetting.Synonym_Field_API_Name__c.split(dynlistConstants.CHAR_COMMA).size() > 0) 
                                            {
                                                for(String fldNameString : dynlistSetting.Synonym_Field_API_Name__c.split(dynlistConstants.CHAR_COMMA)) 
                                                {
                                                    tempKey = dynlistSetting.Type__c + dynlistConstants.CHAR_DASH + dynlistSetting.Object_API_Name__c 
                                                        + dynlistConstants.CHAR_DASH + fldNameString.toLowerCase();
                                                    setOfCustomTypesSettings.add(tempKey);
                                                }    
                                            }
                                            else 
                                            {
                                                tempKey = dynlistSetting.Type__c + dynlistConstants.CHAR_DASH + dynlistSetting.Object_API_Name__c 
                                                    + dynlistConstants.CHAR_DASH + dynlistSetting.Synonym_Field_API_Name__c.toLowerCase();
                                                setOfCustomTypesSettings.add(tempKey);    
                                            }
                                        }                                        
                                    }
                                } 
                            }
                        }
                    }
                    if(String.isNotBlank(dataGridRequestWrapper.objectName)) 
                    {
                        if(setOfObjectForNameFieldNotAvailable.contains(dataGridRequestWrapper.objectName.toLowerCase())) 
                        {
                            objectNotHavingNameField = true;    
                        }  
                        
                        if(setOfObjectsAPINameForWhichNewWillBeDisabled.contains(dataGridRequestWrapper.objectName.toLowerCase())) 
                        {
                            result.specialObjStandardNewNotAllowed = true;
                        }
                        else 
                        {
                            result.specialObjStandardNewNotAllowed = false;
                        }
                        
                        if(setOfObjectsAPINameForWhichEditWillBeDisabled.contains(dataGridRequestWrapper.objectName.toLowerCase())) 
                        {
                            result.specialObjStandardEditNotAllowed = true;  
                        }
                        else 
                        {
                            result.specialObjStandardEditNotAllowed = false;
                        }
                        
                        if(setOfObjectsAPINameForWhichDeleteWillBeDisabled.contains(dataGridRequestWrapper.objectName.toLowerCase())) 
                        {
                            result.specialObjStandardDeleteNotAllowed = true;  
                        }
                        else
                        {
                            result.specialObjStandardDeleteNotAllowed = false;
                        }
                        
                        String objNameSynonymFieldName = dynlistConstants.CHAR_BLANK_STRING;
                        if(dynlistUtilities.setOfObjectForNameFieldNotAvailable.contains(dataGridRequestWrapper.objectName.toLowerCase())) 
                        {
                            if(
                                dynlistUtilities.mapOfObjectAPINameWithSynonymField != null 
                                && dynlistUtilities.mapOfObjectAPINameWithSynonymField.get(dataGridRequestWrapper.objectName.toLowerCase()) != null
                            ) 
                            {
                                objNameSynonymFieldName = dynlistUtilities.mapOfObjectAPINameWithSynonymField.get(dataGridRequestWrapper.objectName.toLowerCase());
                            }
                        }
                        if(String.isNotBlank(objNameSynonymFieldName)) 
                        {
                            result.nameSynonymFieldName = objNameSynonymFieldName;   
                        }
                    }
                    
                    String whereClause, orderBy, queryLimit, offsetBy = dynlistConstants.CHAR_BLANK_STRING;
                    
                    if (String.isNotBlank(dataGridRequestWrapper.whereClauseString)) 
                    {
                        whereClause =
                            dynlistConstants.CHAR_WHERE +
                            dynlistConstants.CHAR_BLANK_SPACE +
                            dataGridRequestWrapper.whereClauseString;
                    }
                    
                    if (String.isNotBlank(dataGridRequestWrapper.correctContextRecordId)) 
                    {
                        //if user wants to display the related list on the basis of parent fields
                        if(String.isNotBlank(dataGridRequestWrapper.recordPageParentToParentFieldNameMappings) 
                           && String.isNotBlank(dataGridRequestWrapper.recordPageParentObjectAPIName))
                        {
                            //to hold the API Names of the parent fields which is related to current record along with their mapping 
                            List<String> listOfParentFieldsAPINameWithMapping = new List<String>();
                            
                            //TODO :: Need to handle uniqueness of fields
                            String queryString = dynlistConstants.CHAR_BLANK_STRING;
                            for(String parentToParentName : dataGridRequestWrapper.recordPageParentToParentFieldNameMappings.split(dynlistConstants.CHAR_COMMA))
                            {
                                listOfParentFieldsAPINameWithMapping.add(parentToParentName);
                                
                                if(!queryString.contains(parentToParentName.split(dynlistConstants.CHAR_ARROW)[0]))
                                {                                    
                                    queryString += String.isNotBlank(queryString) ? 
                                        (dynlistConstants.CHAR_COMMA + parentToParentName.split(dynlistConstants.CHAR_ARROW)[0]) : 
                                    'SELECT ID,' + parentToParentName.split(dynlistConstants.CHAR_ARROW)[0];
                                }
                            }
                            
                            if(String.isNotBlank(queryString) && listOfParentFieldsAPINameWithMapping.size() > 0)
                            {
                                queryString += ' FROM '+ dataGridRequestWrapper.recordPageParentObjectAPIName + ' WHERE Id = \''+ dataGridRequestWrapper.correctContextRecordId +'\'';
                                Map<String, String> mapOfFieldsAPINameWithValues = new Map<String,String>();
                                
                                whereClause = (whereClause != null && whereClause.contains(dynlistConstants.CHAR_WHERE))
                                    ? (whereClause +
                                       dynlistConstants.CHAR_BLANK_SPACE +
                                       dynlistConstants.CHAR_AND +
                                       dynlistConstants.CHAR_BLANK_SPACE)
                                    : (dynlistConstants.CHAR_WHERE + dynlistConstants.CHAR_BLANK_SPACE);
                                        
                                        for(sObject sObjDetails : Database.query(queryString))
                                    {
                                        for(String parentMapping : listOfParentFieldsAPINameWithMapping)
                                        {
                                            if(!whereClause.contains(parentMapping.split(dynlistConstants.CHAR_ARROW)[1]))
                                            {
                                                whereClause +=  parentMapping.split(dynlistConstants.CHAR_ARROW)[1] +
                                                    dynlistConstants.CHAR_BLANK_SPACE +
                                                    dynlistConstants.CHAR_EQUAL +
                                                    dynlistConstants.CHAR_BLANK_SPACE +
                                                    (String.isBlank((String)sObjDetails.get(parentMapping.split(dynlistConstants.CHAR_ARROW)[0])) ? dynlistConstants.CHAR_NULL : 
                                                     '\'' +
                                                     sObjDetails.get(parentMapping.split(dynlistConstants.CHAR_ARROW)[0])+
                                                     '\'' 
                                                    ) +
                                                    dynlistConstants.CHAR_BLANK_SPACE +
                                                    dynlistConstants.CHAR_AND + dynlistConstants.CHAR_BLANK_SPACE;
                                            }
                                        }
                                    }
                                
                                whereClause = whereClause.removeEnd(dynlistConstants.CHAR_AND + dynlistConstants.CHAR_BLANK_SPACE);
                            }
                        }
                        else if(String.isBlank(dataGridRequestWrapper.recordPageParentToParentFieldNameMappings) 
                                && String.isNotBlank(dataGridRequestWrapper.recordPageParentFieldAPIName))
                        {
                            whereClause = (whereClause != null && whereClause.contains(dynlistConstants.CHAR_WHERE))
                                ? (whereClause +
                                   dynlistConstants.CHAR_BLANK_SPACE +
                                   dynlistConstants.CHAR_AND +
                                   dynlistConstants.CHAR_BLANK_SPACE)
                                : (dynlistConstants.CHAR_WHERE + dynlistConstants.CHAR_BLANK_SPACE);
                                    whereClause +=
                                    dataGridRequestWrapper.recordPageParentFieldAPIName +
                                    dynlistConstants.CHAR_BLANK_SPACE +
                                    dynlistConstants.CHAR_EQUAL +
                                    dynlistConstants.CHAR_BLANK_SPACE +
                                    '\'' +
                                    dataGridRequestWrapper.correctContextRecordId +
                                    '\'';
                        }
                    }
                    
                    if (
                        String.isNotBlank(dataGridRequestWrapper.defaultSortFieldName) &&
                        String.isNotBlank(dataGridRequestWrapper.defaultSortDirection)
                    ) 
                    {
                        orderBy =
                            dynlistConstants.CHAR_BLANK_SPACE +
                            dynlistConstants.CHAR_ORDER_BY +
                            dynlistConstants.CHAR_BLANK_SPACE +
                            dataGridRequestWrapper.defaultSortFieldName +
                            dynlistConstants.CHAR_BLANK_SPACE +
                            dataGridRequestWrapper.defaultSortDirection;
                    }
                    
                    if (dataGridRequestWrapper.limitValue != null) 
                    {
                        Integer limitCount = dataGridRequestWrapper.limitValue;
                        queryLimit =
                            dynlistConstants.CHAR_BLANK_SPACE +
                            dynlistConstants.CHAR_LIMIT +
                            dynlistConstants.CHAR_BLANK_SPACE +
                            ':limitCount ';
                    }
                    
                    if (dataGridRequestWrapper.offSetValue != null) 
                    {
                        Integer offsetCount = dataGridRequestWrapper.offSetValue;
                        offsetBy =
                            dynlistConstants.CHAR_BLANK_SPACE +
                            dynlistConstants.CHAR_OFFSET +
                            dynlistConstants.CHAR_BLANK_SPACE +
                            ':offsetCount ';
                    }
                    
                    //TODO : We will utilize it in future for search functionality
                    if (String.isNotBlank(dataGridRequestWrapper.searchByString)) {}
                    
                    List<sObject> sObjectData = new List<sObject>();
                    
                    List<String> listOfAdditionalFieldsForQuery = new List<String>();
                    
                    if(String.isNotBlank(dataGridRequestWrapper.groupByFieldName)) 
                    {
                        listOfAdditionalFieldsForQuery.add(dataGridRequestWrapper.groupByFieldName);                        
                    }
                    
                    if(String.isNotBlank(dataGridRequestWrapper.summarizeByFieldName)) 
                    {
                        listOfAdditionalFieldsForQuery.add(dataGridRequestWrapper.summarizeByFieldName);                        
                    }
                    
                    if(String.isNotBlank(dataGridRequestWrapper.defaultSortFieldName)) 
                    {
                        listOfAdditionalFieldsForQuery.add(dataGridRequestWrapper.defaultSortFieldName);                        
                    }
                    
                    dynListQryWrapper = dynlistUtilities.getFieldsetQuery(
                        dataGridRequestWrapper.objectName,
                        fieldSetObj != null ? fieldSetObj.getFields() : null,
                        null,
                        String.isNotBlank(whereClause) ? whereClause : null,
                        String.isNotBlank(orderBy) ? orderBy : null,
                        String.isNotBlank(queryLimit) ? queryLimit : null,
                        true, //convertFieldPaths
                        false, //addPrefix
                        dataGridRequestWrapper.enforceWithSecurityMode, //enableWithSecurityEnforced
                        String.isNotBlank(offsetBy) ? offsetBy : null,
                        dataGridRequestWrapper.sOQLSelectFieldsString,
                        dataGridRequestWrapper.nullFirstOrLastString,
                        listOfAdditionalFieldsForQuery,
                        mapOfNonQueryableFields
                    );
                    
                    if(dynListQryWrapper != null && String.isNotBlank(dynListQryWrapper.queryString)) 
                    {
                        //if all fields are not inaccessible
                        if(!dynListQryWrapper.isAllFieldsInAccessible) 
                        {
                            Integer noOfMaxRowsAllowedToQuery = dynlistLimitsLogger.getMaxAllowedQueryRowsCount();
                            sObjectData = Database.query(dynListQryWrapper.queryString);
                            List<dynlistField> fields = new List<dynlistField>();
                            
                            if (String.isBlank(dataGridRequestWrapper.sOQLSelectFieldsString)) 
                            {
                                //Traverse the field set and fill out fields details wrapper list
                                fields = dynlistFieldFactory.traverseFieldSet(
                                    fieldSetObj,
                                    objectDescribe.fields.getMap(),
                                    dynListQryWrapper.setOfNonQueryableFields,
                                    setOfCustomTypesSettings,
                                    dataGridRequestWrapper.objectName
                                );
                            } 
                            else 
                            {
                                Map<String, Schema.SObjectField> objectAllFieldsMap = dynlistUtilities.getFieldsMap(
                                    dataGridRequestWrapper.objectName
                                );
                                if (objectAllFieldsMap != null) 
                                {
                                    fields = dynlistFieldFactory.traverseFieldSet(
                                        objectAllFieldsMap,
                                        dataGridRequestWrapper.sOQLSelectFieldsString,
                                        dynListQryWrapper.setOfNonQueryableFields,
                                        setOfCustomTypesSettings,
                                        dataGridRequestWrapper.objectName
                                    );
                                }
                            }
                            
                            if (sObjectData != null && sObjectData.size() > 0) 
                            {
                                //Handle Custom lookup onload values start here
                                //Start from here
                                //Map to hold object API Name and related record ids
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
                                                String sObjName = recordId.getSObjectType()
                                                    .getDescribe()
                                                    .getName();
                                                if (
                                                    !mapOfObjAPINamewithRelatedRecordsIds.containsKey(
                                                        sObjName
                                                    )
                                                ) 
                                                {
                                                    mapOfObjAPINamewithRelatedRecordsIds.put(
                                                        sObjName,
                                                        new Set<Id>()
                                                    );
                                                }
                                                mapOfObjAPINamewithRelatedRecordsIds.get(sObjName)
                                                    .add(recordId);
                                            }
                                        }
                                    }
                                }
                                
                                //Map to hold Lookup data
                                map<String, map<String, String>> mapOfLoopUpFieldsData = new Map<String, map<String, String>>();
                                for (String objName : mapOfObjAPINamewithRelatedRecordsIds.keySet()) 
                                {
                                    Set<Id> temp = new Set<Id>();
                                    temp.addAll(mapOfObjAPINamewithRelatedRecordsIds.get(objName));
                                    
                                    String nameSynonymFieldName = dynlistConstants.CHAR_BLANK_STRING;
                                    if(objName != null && dynlistUtilities.setOfObjectForNameFieldNotAvailable.contains(objName.toLowerCase())) 
                                    {
                                        if(dynlistUtilities.mapOfObjectAPINameWithSynonymField != null) 
                                        {
                                            if(
                                                String.isNotBlank(objName)
                                                && dynlistUtilities.mapOfObjectAPINameWithSynonymField != null 
                                                && dynlistUtilities.mapOfObjectAPINameWithSynonymField.get(objName.toLowerCase()) != null
                                            ) 
                                            {
                                                nameSynonymFieldName = dynlistUtilities.mapOfObjectAPINameWithSynonymField.get(objName.toLowerCase());
                                            }
                                        }      
                                    }
                                    String soqlString = 'SELECT Id, ';
                                    
                                    if(String.isNotBlank(nameSynonymFieldName)) 
                                    {
                                        if(!nameSynonymFieldName.equalsIgnoreCase(dynlistConstants.ID_FIELD_API_NAME)) 
                                        {
                                            soqlString += dynlistConstants.CHAR_BLANK_SPACE + nameSynonymFieldName + ' FROM ' + objName + ' Where Id IN: temp';        
                                        }
                                        else 
                                        {
                                            soqlString = dynlistConstants.CHAR_BLANK_STRING;
                                            soqlString = 'SELECT Id FROM ' + objName + ' Where Id IN: temp';
                                        }
                                    }
                                    else 
                                    {
                                        soqlString += ' Name FROM ' + objName + ' Where Id IN: temp';
                                    }
                                    
                                    List<sobject> sObjData = new List<sObject>();
                                    sObjData = Database.query(soqlString);
                                    map<String, String> tempMap = new Map<String, String>();
                                    for (sObject obj : sObjData) 
                                    {
                                        if (!tempMap.containsKey(obj.Id)) 
                                        {
                                            String namefield = dynlistConstants.CHAR_BLANK_STRING;
                                            if(String.isNotBlank(nameSynonymFieldName)) 
                                            {
                                                namefield = String.valueOf(obj.get(nameSynonymFieldName));
                                            }
                                            else 
                                            {
                                                namefield = String.valueOf(obj.get(dynlistConstants.NAME_FIELD_NAME));
                                            }
                                            tempMap.put(
                                                String.valueOf(obj.get(dynlistConstants.ID_FIELD_NAME)),
                                                namefield
                                            );
                                        }
                                    }
                                    mapOfLoopUpFieldsData.put(objName, tempMap);
                                }
                                //End here
                                
                                //Loop over data and traverse for fields and rows
                                Integer rowNum = 1;
                                for (Sobject obj : sObjectData) 
                                {
                                    dynlistRow row = new dynlistRow();
                                    row.errorMessageForRow = dynlistConstants.CHAR_BLANK_STRING;
                                    
                                    //checking if object is having name field available on it
                                    if(!objectNotHavingNameField) 
                                    {
                                        row.title = obj.get(dynlistConstants.NAME_FIELD_NAME) != null
                                            ? String.valueOf(obj.get(dynlistConstants.NAME_FIELD_NAME))
                                            : dynlistConstants.CHAR_BLANK_STRING;    
                                    }
                                    
                                    row.rowNumber = rowNum;
                                    row.recId = String.valueOf(obj.get(dynlistConstants.ID_FIELD_NAME));
                                    
                                    if (String.isNotBlank(dataGridRequestWrapper.groupByFieldName)) 
                                    {
                                        row.groupByFieldValue = obj.get(
                                            dataGridRequestWrapper.groupByFieldName
                                        ) != null
                                            ? String.valueOf(
                                                obj.get(dataGridRequestWrapper.groupByFieldName)
                                            )
                                            : dynlistConstants.CHAR_BLANK_STRING;
                                    }
                                    
                                    if (
                                        String.isNotBlank(dataGridRequestWrapper.summarizeByFieldName)
                                    ) 
                                    {
                                        row.summarizeByFieldValue = obj.get(
                                            dataGridRequestWrapper.summarizeByFieldName
                                        ) != null
                                            ? String.valueOf(
                                                obj.get(dataGridRequestWrapper.summarizeByFieldName)
                                            )
                                            : null;
                                    }
                                    
                                    row.fields = dynlistFieldFactory.traverseFieldForDataGrid(
                                        fields,
                                        obj,
                                        mapOfLoopUpFieldsData,
                                        rowNum,
                                        row.recId,
                                        dataGridRequestWrapper.objectName,
                                        dataGridRequestWrapper.defaultSortFieldName,
                                        dataGridRequestWrapper.defaultSortDirection,
                                        dynListQryWrapper.setOfNonQueryableFields
                                    );
                                    row.selected = false;
                                    row.editMode = false;
                                    rows.add(row);
                                    rowNum++;
                                }
                                result.rows = rows;
                                
                                //Logic to fill out allColumns - only if needed in case when "Columns and Filters" section is enabled
                                if(dataGridRequestWrapper != null && dataGridRequestWrapper.isColumnsAndFiltersSectionNeeded) 
                                {
                                    Map<String, Schema.SObjectField> allFieldsDescribes = sObjectTypeObj.getDescribe().fields.getMap();
                                    List<dynlistColumn> allFieldsColumns = new List<dynlistColumn>();
                                    Set<String> setNonQueryableFields = dynlistUtilities.getSetOfNonQueryableFields(mapOfNonQueryableFields, dataGridRequestWrapper.objectName, allFieldsDescribes.keySet());
                                    for (String fieldMember : allFieldsDescribes.keySet()) 
                                    {
                                        Schema.DescribeFieldResult descFieldResult = allFieldsDescribes.get(fieldMember).getDescribe();
                                        if (descFieldResult.isAccessible()) 
                                        {
                                            if(!setNonQueryableFields.contains(descFieldResult.getName().toLowerCase())) 
                                            {
                                                dynlistColumn fieldDetails = new dynlistColumn();
                                                fieldDetails.value = descFieldResult.getName();
                                                fieldDetails.label = descFieldResult.getLabel();
                                                allFieldsColumns.add(fieldDetails);        
                                            }
                                        }
                                    }
                                    if (allFieldsColumns.size() > 0) 
                                    {
                                        allFieldsColumns.sort();
                                    }
                                    result.allColumns = allFieldsColumns;    
                                } 
                                else 
                                {
                                    result.allColumns = new List<dynlistColumn>();
                                }
                                
                                //Kanban View Specific Data
                                if (
                                    String.isNotBlank(dataGridRequestWrapper.view) &&
                                    dataGridRequestWrapper.view == dynlistConstants.VIEW_TYPE_KANBAN &&
                                    String.isNotBlank(dataGridRequestWrapper.groupByFieldName)
                                ) 
                                {
                                    Map<String, List<dynlistRow>> kanbanRows = new Map<String, List<dynlistRow>>();
                                    List<dynlistColumn> columns = new List<dynlistColumn>();
                                    
                                    for (
                                        String groupByFieldValue : dynlistUtilities.getPicklistFieldValues(
                                            dataGridRequestWrapper.objectName,
                                            dataGridRequestWrapper.groupByFieldName
                                        )
                                    ) 
                                    {
                                        dynlistColumn colm = new dynlistColumn();
                                        colm.label = groupByFieldValue;
                                        colm.isDropEnabled = true;
                                        columns.add(colm);
                                    }
                                    
                                    result.kanbanRows = new Map<String, List<dynlistRow>>();
                                    
                                    for (dynlistColumn col : columns) 
                                    {
                                        result.kanbanRows.put(col.label, new List<dynlistRow>{});
                                    }
                                    
                                    for (dynlistRow rowInstance : result.rows) 
                                    {
                                        if(result.kanbanRows.containsKey(rowInstance.groupByFieldValue)) 
                                        {
                                            result.kanbanRows.get(rowInstance.groupByFieldValue).add(rowInstance);
                                        }
                                    }
                                    result.columns = columns;
                                }
                                else 
                                {
                                    result.columns = new List<dynlistColumn>();
                                }
                                
                                //Addition handling for removal of ID rows for reference type fields changes for history objects
                                List<dynlistRow> eligibleRows = new List<dynlistRow>();
                                for(dynlistRow rIns : result.rows) 
                                {
                                    Boolean rowIsCandidateToBeSkipped = false;
                                    for(dynlistField fIns : rIns.fields) 
                                    {
                                        if(fIns.fieldHistoryForReferenceField == true) 
                                        {
                                            rowIsCandidateToBeSkipped = true;
                                        }
                                        
                                        if(rowIsCandidateToBeSkipped) 
                                        {
                                            if(
                                                String.isNotBlank(fIns.fieldName) 
                                                && (
                                                    fIns.fieldName.equalsIgnoreCase(dynlistConstants.HISTORY_OBJECT_OLD_VALUE_FIELD_API_NAME) 
                                                    ||
                                                    fIns.fieldName.equalsIgnoreCase(dynlistConstants.HISTORY_OBJECT_NEW_VALUE_FIELD_API_NAME)
                                                )    
                                            ) 
                                            {
                                                if(String.isNotBlank(fIns.value) && dynlistUtilities.isaValidateSalesforceID(fIns.value))
                                                {
                                                    rIns.needToRemovedExplicitly = true;
                                                    break;
                                                }
                                            }    
                                        }
                                    }
                                    if(rIns.needToRemovedExplicitly == false) 
                                    {
                                        eligibleRows.add(rIns);    
                                    }
                                }
                                result.rows = new List<dynlistRow>();
                                result.rows.addAll(eligibleRows);
                                eligibleRows = new List<dynlistRow>();
                                result.setBody(result.rows.size());
                            } 
                            else 
                            {
                                result.setBody(null);
                                result.setMessage(System.Label.DYNLIST_NO_RECORDS_TO_DISPLAY);
                                result.setSuccess(true);
                            }        
                        }
                        else 
                        {
                            result.setError(System.Label.DYNLIST_ERROR_ALL_FIELDS_INACCESSIBLE);
                        }
                    }
                    else 
                    {
                        result.setError(System.Label.DYNLIST_ERROR_NO_RESULTS_RETURNED);
                    }
                } 
                else 
                {
                    result.setError(System.Label.DYNLIST_ERROR_INSUFFIECIENT_OBJECT_ACCESS);
                }
            } 
            else 
            {
                result.setError(System.Label.DYNLIST_REQUEST_PARAMS_MISSING);
            }
        } 
        catch (Exception e) 
        {
            if(String.isNotBlank(e.getMessage()) && e.getMessage().contains(dynlistConstants.SECURE_QUERY)) 
            {
                String inAccessibleFieldsName = dynlistConstants.CHAR_BLANK_STRING;
                if(String.isNotBlank(dynListQryWrapper.selectQueryForInAccessibilityCheck)) 
                {
                    Map<String, Set<String>> mapOfInAccessibleFields = dynlistUtilities.getInAccessibleFieldsDetails(dynListQryWrapper.selectQueryForInAccessibilityCheck);
                    for(String key : mapOfInAccessibleFields.keySet()) 
                    {
                        for(String value : mapOfInAccessibleFields.get(key)) 
                        {
                            inAccessibleFieldsName += value + dynlistConstants.CHAR_COMMA + dynlistConstants.CHAR_BLANK_SPACE;
                        }
                    }
                    if(String.isNotBlank(inAccessibleFieldsName)) 
                    {
                        inAccessibleFieldsName = inAccessibleFieldsName.trim().removeEnd(dynlistConstants.CHAR_COMMA);
                    }
                }
                result.setError(System.Label.DYNLIST_ERROR_ACCESS_ENFORCED_MODE + dynlistConstants.CHAR_BLANK_SPACE + inAccessibleFieldsName);
            }
            else 
            {
                if(String.isNotBlank(e.getMessage()) && e.getMessage().contains(System.Label.DYNLIST_NO_SUCH_COLUMN_NAME_ON_ENTITY)) 
                {
                    result.setError(dynlistConstants.EXCEPTION_SUFFIX + e.getMessage()); 
                }
                else 
                {
                    result.setError(dynlistConstants.EXCEPTION_SUFFIX + e.getMessage() + dynlistConstants.CHAR_NEW_LINE + e.getStackTraceString());        
                }
            }
        }
        return result;
    }
    
    @AuraEnabled(cacheable=false)
    public static dynlistDataGrid saveRecordData(
        String sObjectName,
        String rowsWrapper
    ) 
    {
        dynlistDataGrid res = new dynlistDataGrid();
        try 
        {
            Map<Id, String> mapOfUpdatedRecIdWithErrorMsg = new Map<Id, String>();
            Boolean isErrorAppearInSaveAction = false;
            
            List<dynlistRow> rows = (List<dynlistRow>) JSON.deserialize(
                rowsWrapper,
                List<dynlistRow>.class
            );
            List<Sobject> objectRecordsToUpdate = new List<Sobject>();
            if (rows.size() > 0) 
            {
                for (dynlistRow oDW : rows) 
                {
                    if (oDW.selected) 
                    {
                        SObject objRecord = dynlistUtilities.getObjectOnBasisOfObjectName(sObjectName);
                        objRecord.put(dynlistConstants.ID_FIELD_NAME, oDW.recId);
                        for (dynlistField fDW : oDW.fields) 
                        {
                            if (fDW.readOnly != null && !fDW.readOnly) 
                            {
                                if (
                                    fDW.type == dynlistConstants.DATA_TYPE_CURRENCY ||
                                    fDW.type == dynlistConstants.DATA_TYPE_PERCENT ||
                                    fDW.type == dynlistConstants.DATA_TYPE_DECIMAL ||
                                    fDW.type == dynlistConstants.DATA_TYPE_DOUBLE ||
                                    fDW.type == dynlistConstants.DATA_TYPE_RATING
                                ) 
                                {
                                    if (String.isNotBlank(fDW.value)) 
                                    {
                                        try
                                        {
                                            objRecord.put(fDW.name, Decimal.valueOf(fDW.value));
                                        }
                                        catch (exception e)
                                        {
                                            objRecord.put(fDW.name, Integer.valueOf(fDW.value));
                                        }    
                                    } else 
                                    {
                                        objRecord.put(fDW.name, null);
                                    }
                                }
                                else if (
                                    fDW.type == dynlistConstants.DATA_TYPE_INTEGER ||
                                    fDW.type == dynlistConstants.DATA_TYPE_MATCHING
                                ) 
                                {
                                    if (String.isNotBlank(fDW.value))
                                        objRecord.put(fDW.name, Integer.valueOf(fDW.value));
                                    else
                                        objRecord.put(fDW.name, null);
                                } 
                                else if (fDW.type == dynlistConstants.DATA_TYPE_DATE) 
                                {
                                    if (String.isNotBlank(fDW.value))
                                        objRecord.put(fDW.name, Date.valueOf(fDW.value));
                                    else
                                        objRecord.put(fDW.name, null);
                                } 
                                else if (fDW.type == dynlistConstants.DATA_TYPE_DATETIME) 
                                {
                                    if (String.isNotBlank(fDW.value))
                                        objRecord.put(
                                            fDW.name,
                                            DateTime.valueofGmt(
                                                fDW.value.replace(
                                                    dynlistConstants.CHAR_T,
                                                    dynlistConstants.CHAR_BLANK_SPACE
                                                )
                                            )
                                        );
                                    else
                                        objRecord.put(fDW.name, null);
                                } 
                                else if (fDW.type == dynlistConstants.DATA_TYPE_TIME) 
                                {
                                    if (String.isNotBlank(fDW.value)) 
                                    {
                                        Time timeChange = Time.newInstance(
                                            Integer.valueOf(
                                                fDW.value.split(dynlistConstants.CHAR_COLON)[0]
                                            ),
                                            Integer.valueOf(
                                                fDW.value.split(dynlistConstants.CHAR_COLON)[1]
                                            ),
                                            Integer.valueOf(
                                                fDW.value.removeEndIgnoreCase(
                                                    dynlistConstants.CHAR_SMALL_Z
                                                )
                                                .split(dynlistConstants.CHAR_COLON)[2]
                                            ),
                                            0
                                        );
                                        objRecord.put(fDW.name, timeChange);
                                    } 
                                    else
                                        objRecord.put(fDW.name, null);
                                } 
                                else if (fDW.type == dynlistConstants.DATA_TYPE_BOOLEAN) 
                                {
                                    if (String.isNotBlank(fDW.value)) 
                                    {
                                        objRecord.put(fDW.name, Boolean.valueOf(fDW.value));
                                    } 
                                    else 
                                    {
                                        objRecord.put(fDW.name, null);
                                    }
                                } 
                                else if (fDW.type == dynlistConstants.DATA_TYPE_MULTIPICKLIST) 
                                {
                                    if (fDW.values != null && fDW.values.size() > 0) 
                                    {
                                        String selectedValues = dynlistConstants.CHAR_BLANK_STRING;
                                        for (String mPicklistValue : fDW.values) 
                                        {
                                            selectedValues +=
                                                mPicklistValue + dynlistConstants.CHAR_SEMI_COLON;
                                        }
                                        objRecord.put(fDW.name, selectedValues);
                                    } 
                                    else 
                                    {
                                        objRecord.put(fDW.name, null);
                                    }
                                } 
                                else 
                                {
                                    if (String.isNotBlank(fDW.value))
                                        objRecord.put(fDW.name, fDW.value);
                                    else
                                        objRecord.put(fDW.name, null);
                                }
                                
                                if(String.isBlank(fDW.value) && fDW.required != null && fDW.required)
                                {
                                    mapOfUpdatedRecIdWithErrorMsg.put((Id)objRecord.get(dynlistConstants.ID_FIELD_NAME), System.Label.DYNLIST_ERROR_FIELD_IS_REQUIRED);
                                    isErrorAppearInSaveAction = true;
                                }
                            }
                        }
                        if(!mapOfUpdatedRecIdWithErrorMsg.containsKey((Id)objRecord.get(dynlistConstants.ID_FIELD_NAME)))
                            objectRecordsToUpdate.add(objRecord);
                    }
                }
                
                if (objectRecordsToUpdate.size() > 0) 
                {
                    if (dynlistUtilities.isUserHaveUpdateObjectAccess(sObjectName)) 
                    {
                        //to hold index of updated records
                        //NOTE:-If getId() field contains a value, the object was successfully inserted or updated. If this field is empty, the operation was not successful for that object.
                        Integer i = 0;
                        for (Database.SaveResult updateResult : Database.Update(objectRecordsToUpdate, false)) 
                        {
                            if (updateResult.isSuccess()) 
                            {
                                mapOfUpdatedRecIdWithErrorMsg.put(updateResult.getId(), dynlistConstants.CHAR_BLANK_STRING);
                            }
                            else 
                            {         
                                for(Database.Error err : updateResult.getErrors()) 
                                {
                                    isErrorAppearInSaveAction = true;
                                    mapOfUpdatedRecIdWithErrorMsg.put(objectRecordsToUpdate[i].Id, err.getMessage());
                                }
                            }
                            i++;
                        }
                        
                        if(!isErrorAppearInSaveAction)
                        {
                            res.messages.add(System.Label.DYNLIST_RECORDS_SAVED_SUCCESSFULLY);
                        }
                        else
                        {
                            res.messages.add(System.Label.DYNLIST_RECORD_UPDATION_ERROR_OCCURE);
                        }
                        res.setBody(mapOfUpdatedRecIdWithErrorMsg);
                        res.setSuccess(true);
                    }    
                    else 
                    {
                        res.setError(System.Label.DYNLIST_ERROR_OBJECT_UPDATE_ACCESS_MISSING);
                    }
                } 
                else if(mapOfUpdatedRecIdWithErrorMsg.size() > 0 
                        && mapOfUpdatedRecIdWithErrorMsg.keySet().size() > 0) 
                {
                    if(!isErrorAppearInSaveAction)
                    {
                        res.messages.add(System.Label.DYNLIST_RECORDS_SAVED_SUCCESSFULLY);
                    }
                    else
                    {
                        res.messages.add(System.Label.DYNLIST_RECORD_UPDATION_ERROR_OCCURE);
                    }
                    res.setBody(mapOfUpdatedRecIdWithErrorMsg);
                    res.setSuccess(true);
                }
                else 
                {
                    res.setError(System.Label.DYNLIST_NO_RECORD_TO_UPDATE);
                }
            }
        } 
        catch (Exception ex) 
        {
            if (
                ex.getMessage()
                .contains(dynlistConstants.ERROR_TYPE_FIELD_CUSTOM_VALIDATION_EXCEPTION)
            ) 
            {
                res.setError(
                    ex.getMessage()
                    .substringBetween(
                        dynlistConstants.ERROR_TYPE_FIELD_CUSTOM_VALIDATION_EXCEPTION +
                        (dynlistConstants.CHAR_COMMA + dynlistConstants.CHAR_BLANK_SPACE),
                        dynlistConstants.CHAR_COLON + dynlistConstants.CHAR_BLANK_SPACE
                    ) +
                    dynlistConstants.CHAR_BLANK_SPACE +
                    ex.getLineNumber()
                );
            } 
            else 
            {
                res.setError(
                    ex.getMessage() +
                    dynlistConstants.CHAR_BLANK_SPACE +
                    ex.getLineNumber() + dynlistConstants.CHAR_BLANK_SPACE + ex.getStackTraceString()
                );
            }
        }
        return res;
    }
    
    @AuraEnabled(cacheable=false)
    public static String updateRecordOnDrop(Id recId, String kanbanField, String kanbanNewValue) 
    {
        SObject o1 = recId.getSObjectType().newSObject(recId);
        o1.put(kanbanField,kanbanNewValue);
        //update o1;
        return 'Success';
    }
    
    @AuraEnabled(cacheable=false)
    public static dynlistDataGrid deleteRecordData(
        String sObjectName,
        String rowsWrapper,
        String selectedRecord
    ) 
    {
        dynlistDataGrid res = new dynlistDataGrid();
        try 
        {
            List<dynlistRow> rows = (List<dynlistRow>) JSON.deserialize(
                rowsWrapper,
                List<dynlistRow>.class
            );
            
            Map<Id, sobject> mapOfIdWithObjRecord = new Map<Id, sobject>();
            
            if (String.isNotBlank(selectedRecord)) 
            {                
                for(String rowId :selectedRecord.split(dynlistConstants.CHAR_COMMA))
                {
                    sObject objRecord = dynlistUtilities.getObjectOnBasisOfObjectName(sObjectName);
                    objRecord.put(dynlistConstants.ID_FIELD_NAME, Id.valueOf(rowId));
                    mapOfIdWithObjRecord.put((Id)objRecord.get(dynlistConstants.ID_FIELD_NAME), objRecord);
                }
                
            } 
            else 
            {
                if (rows.size() > 0) 
                {
                    for (dynlistRow oDW : rows) 
                    {
                        if (oDW.selected) 
                        {
                            SObject objRecord = dynlistUtilities.getObjectOnBasisOfObjectName(sObjectName);
                            objRecord.put(dynlistConstants.ID_FIELD_NAME, oDW.recId);
                            mapOfIdWithObjRecord.put((Id)objRecord.get(dynlistConstants.ID_FIELD_NAME), objRecord);
                        }
                    }
                }
            }
            if (mapOfIdWithObjRecord.size() > 0) 
            {
                if (dynlistUtilities.isUserHaveDeleteObjectAccess(sObjectName)) 
                {
                    Map<Id, String> mapOfDeletedIdWithErrorMsg = new Map<Id, String>();
                    Boolean isErrorAppearInDeleteAction = false;
                    
                    for(Database.DeleteResult deleteResult : Database.delete(mapOfIdWithObjRecord.values(), false)) 
                    {
                        if (!deleteResult.isSuccess()) 
                        {
                            for(Database.Error err : deleteResult.getErrors()) 
                            {
                                isErrorAppearInDeleteAction = true;
                                mapOfDeletedIdWithErrorMsg.put(deleteResult.getId(), err.getMessage());
                            }
                        }
                        else 
                        {
                            mapOfDeletedIdWithErrorMsg.put(deleteResult.getId(), dynlistConstants.CHAR_BLANK_STRING);
                        }
                    }
                    
                    if(!isErrorAppearInDeleteAction)
                    {
                        res.messages.add(System.Label.DYNLIST_RECORD_DELETED_SUCCESSFULLY);
                    }
                    else
                    {
                        res.messages.add(System.Label.DYNLIST_RECORD_DELETION_ERROR_OCCURE);
                    }
                    res.setBody(mapOfDeletedIdWithErrorMsg);
                    res.setSuccess(true);
                }
                else 
                {
                    res.setError(System.Label.DYNLIST_ERROR_OBJECT_DELETE_ACCESS_MISSING);
                }
            }
        } 
        catch (Exception ex) 
        {
            res.isSuccess = false;
            if (
                ex.getMessage()
                .contains(dynlistConstants.ERROR_TYPE_FIELD_CUSTOM_VALIDATION_EXCEPTION)
            ) 
            {
                res.setError(
                    ex.getMessage()
                    .substringBetween(
                        dynlistConstants.ERROR_TYPE_FIELD_CUSTOM_VALIDATION_EXCEPTION +
                        (dynlistConstants.CHAR_COMMA + dynlistConstants.CHAR_BLANK_SPACE),
                        dynlistConstants.CHAR_COLON + dynlistConstants.CHAR_BLANK_SPACE
                    )
                );
            } 
            else 
            {
                res.setError(ex.getMessage() +
                             dynlistConstants.CHAR_BLANK_SPACE +
                             ex.getLineNumber());
            }
        }
        return res;
    }
    
    @AuraEnabled(cacheable=false)
    public static String refreshDataGridViewStates() 
    {
        return System.Label.DYNLIST_REFRESH_SUCCESSFULLY;           
    }
    
    private static dynlistDataGridRequestWrapper getRequestWrapperBasedDetails(Map<String, Object> dataGridRequest) 
    {
        //Request Data
        dynlistDataGridRequestWrapper dataGridRequestWrapper = new dynlistDataGridRequestWrapper();
        
        if (dataGridRequest.get(dynlistConstants.DATA_GRID_REQUEST_PARAM_VIEW) != null) 
        {
            dataGridRequestWrapper.view = String.valueOf(dataGridRequest.get(dynlistConstants.DATA_GRID_REQUEST_PARAM_VIEW));
        }
        
        if (dataGridRequest.get(dynlistConstants.DATA_GRID_REQUEST_PARAM_PAGE_SIZE) != null 
            && dataGridRequest.get(dynlistConstants.DATA_GRID_REQUEST_PARAM_PAGE_SIZE) != dynlistConstants.CHAR_BLANK_STRING) 
        {
            dataGridRequestWrapper.pageSize = Integer.valueOf(dataGridRequest.get(dynlistConstants.DATA_GRID_REQUEST_PARAM_PAGE_SIZE));
        }
        
        if (dataGridRequest.get(dynlistConstants.DATA_GRID_REQUEST_PARAM_OBJECT_NAME) != null) 
        {
            dataGridRequestWrapper.objectName = String.valueOf(dataGridRequest.get(dynlistConstants.DATA_GRID_REQUEST_PARAM_OBJECT_NAME));
        }
        
        if (dataGridRequest.get(dynlistConstants.DATA_GRID_REQUEST_PARAM_FIELD_SET_NAME) != null) 
        {
            dataGridRequestWrapper.fieldSetName = String.valueOf(dataGridRequest.get(dynlistConstants.DATA_GRID_REQUEST_PARAM_FIELD_SET_NAME));
        }
        
        if (dataGridRequest.get(dynlistConstants.DATA_GRID_REQUEST_PARAM_WHERE_CLAUSE) != null) 
        {
            dataGridRequestWrapper.whereClauseString = String.valueOf(dataGridRequest.get(dynlistConstants.DATA_GRID_REQUEST_PARAM_WHERE_CLAUSE));
        }
        
        if (dataGridRequest.get(dynlistConstants.DATA_GRID_REQUEST_PARAM_GROUP_BY_FIELD_NAME) != null) 
        {
            dataGridRequestWrapper.groupByFieldName = String.valueOf(dataGridRequest.get(dynlistConstants.DATA_GRID_REQUEST_PARAM_GROUP_BY_FIELD_NAME));
        }
        
        if (dataGridRequest.get(dynlistConstants.DATA_GRID_REQUEST_PARAM_SUMMARIZE_BY_FIELD_NAME) != null) 
        {
            dataGridRequestWrapper.summarizeByFieldName = String.valueOf(dataGridRequest.get(dynlistConstants.DATA_GRID_REQUEST_PARAM_SUMMARIZE_BY_FIELD_NAME));
        }
        
        if (dataGridRequest.get(dynlistConstants.DATA_GRID_REQUEST_SOQL_SELECT_FIELDS_NAME) != null) 
        {
            dataGridRequestWrapper.sOQLSelectFieldsString = String.valueOf(dataGridRequest.get(dynlistConstants.DATA_GRID_REQUEST_SOQL_SELECT_FIELDS_NAME));
        }
        
        if (dataGridRequest.get(dynlistConstants.DATA_GRID_REQUEST_PARAM_DEFAULT_SORT_FIELD_NAME) != null) 
        {
            dataGridRequestWrapper.defaultSortFieldName = String.valueOf(dataGridRequest.get(dynlistConstants.DATA_GRID_REQUEST_PARAM_DEFAULT_SORT_FIELD_NAME));
        }
        
        if (dataGridRequest.get(dynlistConstants.DATA_GRID_REQUEST_PARAM_DEFAULT_SORT_DIRECTION) != null) 
        {
            dataGridRequestWrapper.defaultSortDirection = String.valueOf(dataGridRequest.get(dynlistConstants.DATA_GRID_REQUEST_PARAM_DEFAULT_SORT_DIRECTION));
        }
        
        if (dataGridRequest.get(dynlistConstants.DATA_GRID_REQUEST_PARAM_NULLS_FIRST_OR_LAST) != null) 
        {
            dataGridRequestWrapper.nullFirstOrLastString = String.valueOf(dataGridRequest.get(dynlistConstants.DATA_GRID_REQUEST_PARAM_NULLS_FIRST_OR_LAST));
        }
        
        if (dataGridRequest.get(dynlistConstants.DATA_GRID_REQUEST_PARAM_LIMIT_STRING) != null 
            && dataGridRequest.get(dynlistConstants.DATA_GRID_REQUEST_PARAM_LIMIT_STRING) != dynlistConstants.CHAR_BLANK_STRING) 
        {
            dataGridRequestWrapper.limitValue = Integer.valueOf(dataGridRequest.get(dynlistConstants.DATA_GRID_REQUEST_PARAM_LIMIT_STRING));
        }
        
        if (dataGridRequest.get(dynlistConstants.DATA_GRID_REQUEST_PARAM_OFFSET_STRING) != null 
            && dataGridRequest.get(dynlistConstants.DATA_GRID_REQUEST_PARAM_OFFSET_STRING) != dynlistConstants.CHAR_BLANK_STRING) 
        {
            dataGridRequestWrapper.offSetValue = Integer.valueOf(dataGridRequest.get(dynlistConstants.DATA_GRID_REQUEST_PARAM_OFFSET_STRING));
        }
        
        if (dataGridRequest.get(dynlistConstants.DATA_GRID_REQUEST_PARAM_CURRENT_CONTEXT_RECORD_ID) != null) 
        {
            dataGridRequestWrapper.correctContextRecordId = String.valueOf(dataGridRequest.get(dynlistConstants.DATA_GRID_REQUEST_PARAM_CURRENT_CONTEXT_RECORD_ID));
        }
        
        if (dataGridRequest.get(dynlistConstants.DATA_GRID_REQUEST_PARAM_SEARCH_BY) != null) 
        {
            dataGridRequestWrapper.searchByString = String.valueOf(dataGridRequest.get(dynlistConstants.DATA_GRID_REQUEST_PARAM_SEARCH_BY));
        }
        
        if (dataGridRequest.get(dynlistConstants.DATA_GRID_REQUEST_PARAM_ENFORCE_WITH_SECURITY_MODE) != null) 
        {
            dataGridRequestWrapper.enforceWithSecurityMode = Boolean.valueOf(dataGridRequest.get(dynlistConstants.DATA_GRID_REQUEST_PARAM_ENFORCE_WITH_SECURITY_MODE));
        }
        
        if (dataGridRequest.get(dynlistConstants.IS_COLUMNS_AND_FILTERS_SECTION_NEEDED) != null) 
        {
            dataGridRequestWrapper.isColumnsAndFiltersSectionNeeded = Boolean.valueOf(dataGridRequest.get(dynlistConstants.IS_COLUMNS_AND_FILTERS_SECTION_NEEDED));
        }
        
        if (dataGridRequest.get(dynlistConstants.RECORD_PAGE_PARENT_FIELD_API_NAME) != null) 
        {
            dataGridRequestWrapper.recordPageParentFieldAPIName = String.valueOf(dataGridRequest.get(dynlistConstants.RECORD_PAGE_PARENT_FIELD_API_NAME));
            dynlistFieldFactory.parentFieldNameSettedInConfiguration = dataGridRequestWrapper.recordPageParentFieldAPIName;
        }
        
        if (dataGridRequest.get(dynlistConstants.RECORD_PAGE_PARENT_OBJECT_API_NAME) != null) 
        {
            dataGridRequestWrapper.recordPageParentObjectAPIName = String.valueOf(dataGridRequest.get(dynlistConstants.RECORD_PAGE_PARENT_OBJECT_API_NAME));
        }
        
        if (dataGridRequest.get(dynlistConstants.RECORD_PAGE_PARENT_TO_PARENT_FIELD_MAPPING) != null) 
        {
            dataGridRequestWrapper.recordPageParentToParentFieldNameMappings = String.valueOf(dataGridRequest.get(dynlistConstants.RECORD_PAGE_PARENT_TO_PARENT_FIELD_MAPPING));
        }
        
        if (dataGridRequest.get(dynlistConstants.IS_SYSTEM_MODE) != null) 
        {
            dataGridRequestWrapper.isSystemMode = Boolean.valueOf(dataGridRequest.get(dynlistConstants.IS_SYSTEM_MODE));
        }
        return dataGridRequestWrapper;
    }
}