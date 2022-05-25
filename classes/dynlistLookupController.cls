/*
Purpose         :   Lookup Controller Class (Dynamic Related List)
Created By      :   Abhinav Sharma
Created Date    :   07/25/2021
Current Version :   v1.0
Revision Log    :   V_1.0 Created - Abhinav Sharma - 07/25/2021
*/
public with sharing class dynlistLookupController 
{
    @AuraEnabled(cacheable=false)
    public static SObjectResultsWrapper getResults(
        String objectName, //Account
        String searchValue, //Burlington
        String parentObjName, //Opportunity
        String fieldName, //Account_Filter_Lookup_1__c,
        Boolean removeLookupFilters,
        String recordsToDisplayCount,
        String currentRowRecordId
    ) 
    {   
        try 
        {
            SObjectResultsWrapper sObjResultWrapper = new SObjectResultsWrapper();
            String query = dynlistConstants.CHAR_BLANK_STRING;
            String nameSynonymFieldName = dynlistLookupController.getNameSynonymFieldName(objectName);
            
            if(String.isBlank(recordsToDisplayCount)) 
            {
                recordsToDisplayCount = dynlistConstants.CHAR_TEN;    
            }
            
            if (String.isNotBlank(parentObjName) && String.isNotBlank(objectName) && String.isNotBlank(fieldName)) 
            {
                //Method to build basis SOQL query FROM clause
                query += dynlistLookupController.buildSOQLUptoFROMClause(objectName, searchValue, parentObjName, fieldName, 
                                                                          removeLookupFilters, nameSynonymFieldName);
                
                //Method to build basis SOQL query WHERE clause
                String whereClause = dynlistLookupController.buildSOQLWhereClause(objectName, searchValue, parentObjName, fieldName, 
                                                                          removeLookupFilters, nameSynonymFieldName, currentRowRecordId);
                query += whereClause;
                
                //Method to build order by and other further clauses
                query += dynlistLookupController.buildSOQLOrderByFurtherClauses(nameSynonymFieldName, recordsToDisplayCount);
                
                //Make Count Query to check whether load more records option is needed or not
                String limitForCountQuery = dynlistConstants.CHAR_BLANK_SPACE + dynlistConstants.CHAR_LIMIT + dynlistConstants.CHAR_BLANK_SPACE + String.valueOf((recordsToDisplayCount + 1));
                
                List<sObject> sobjList = Database.query('Select Id FROM ' + objectName + dynlistConstants.CHAR_BLANK_SPACE + whereClause + limitForCountQuery);
                Integer recordCount = sobjList.size();
                Boolean isLoadMoreNeeded = false;
                if(recordCount > Integer.valueOf(recordsToDisplayCount)) 
                {
                    isLoadMoreNeeded = true;
                }
                
                sObjResultWrapper = new SObjectResultsWrapper(dynlistLookupController.getUpdatedSObjectResults(query, nameSynonymFieldName), isLoadMoreNeeded);
            }
            return sObjResultWrapper;    
        }
        catch(Exception err) 
        {
            if (String.isNotBlank(err.getMessage()) && err.getMessage().contains(dynlistConstants.ERROR_WITH_COLON)) 
            {
                throw new AuraHandledException(err.getMessage().split(dynlistConstants.ERROR_WITH_COLON)[1].split(dynlistConstants.CHAR_COLON)[0] + dynlistConstants.CHAR_FULL_STOP);
            } 
            else 
            {
                throw new AuraHandledException(err.getMessage());
            }
        }
    }
    
    @AuraEnabled(cacheable=false)
    public static SObjectResultsWrapper getMoreResults(
        String objectName, //Account
        String searchValue, //Burlington
        String parentObjName, //Opportunity
        String fieldName, //Account_Filter_Lookup_1__c,
        Boolean removeLookupFilters,
        String lastId,
        String requestMoreRecordsCount,
        Integer alreadyQueriesRecordsCount,
        String currentRowRecordId
    ) 
    {
        try 
        {
            SObjectResultsWrapper sObjResultWrapper = new SObjectResultsWrapper();
            String query = dynlistConstants.CHAR_BLANK_STRING;
            String nameSynonymFieldName = dynlistLookupController.getNameSynonymFieldName(objectName);
            
            if(String.isBlank(requestMoreRecordsCount)) 
            {
                requestMoreRecordsCount = dynlistConstants.CHAR_TWENTY_FIVE;    
            }
            
            if (String.isNotBlank(parentObjName) && String.isNotBlank(objectName) && String.isNotBlank(fieldName) && String.isNotBlank(lastId)) 
            {
                //Method to build basis SOQL query FROM clause
                query += dynlistLookupController.buildSOQLUptoFROMClause(objectName, searchValue, parentObjName, fieldName, 
                                                                          removeLookupFilters, nameSynonymFieldName);
                
                //Method to build basis SOQL query WHERE clause
                String whereClause = dynlistLookupController.buildSOQLWhereClause(objectName, searchValue, parentObjName, fieldName, 
                                                                          removeLookupFilters, nameSynonymFieldName, currentRowRecordId);
                query += whereClause;
                
                if(query.containsIgnoreCase(dynlistConstants.CHAR_WHERE)) 
                {
                    query += ' AND Id < \'' + lastId + '\' ORDER BY Id ' + dynlistConstants.CHAR_DESC_LOWERCASE + ' LIMIT ' + requestMoreRecordsCount;    
                }
                else
                {
                    query += ' WHERE Id < \'' + lastId + '\' ORDER BY Id ' + dynlistConstants.CHAR_DESC_LOWERCASE + ' LIMIT ' + requestMoreRecordsCount;
                }
                
                //Make Count Query to check whether load more records option is needed or not
                String limitForCountQuery = dynlistConstants.CHAR_BLANK_SPACE + dynlistConstants.CHAR_LIMIT + dynlistConstants.CHAR_BLANK_SPACE + String.valueOf((requestMoreRecordsCount + alreadyQueriesRecordsCount + 1));
                List<sObject> sobjList = Database.query('Select Id FROM ' + objectName + dynlistConstants.CHAR_BLANK_SPACE + whereClause + limitForCountQuery);
                Integer recordCount = sobjList.size();
                
                Boolean isLoadMoreNeeded = false;
                if(recordCount > (Integer.valueOf(requestMoreRecordsCount) + alreadyQueriesRecordsCount))
                {
                    isLoadMoreNeeded = true;
                }
                sObjResultWrapper = new SObjectResultsWrapper(dynlistLookupController.getUpdatedSObjectResults(query, nameSynonymFieldName), isLoadMoreNeeded);
            }
            return sObjResultWrapper;    
        }
        catch(Exception err) 
        {
            if (String.isNotBlank(err.getMessage()) && err.getMessage().contains(dynlistConstants.ERROR_WITH_COLON)) 
            {
                throw new AuraHandledException(err.getMessage().split(dynlistConstants.ERROR_WITH_COLON)[1].split(dynlistConstants.CHAR_COLON)[0] + dynlistConstants.CHAR_FULL_STOP);
            } 
            else 
            {
                throw new AuraHandledException(err.getMessage());
            }
        }
    }
    
    public static String getLookupFiltersWhereClauseString(
        String objectName, //Account
        String parentObjName, //Opportunity
        String fieldName, //Account_Filter_Lookup_1__c,
        String currentRowRecordId
    ) 
    {
        try 
        {
            String filtersWhereClauseString = dynlistConstants.CHAR_BLANK_STRING;
            
            if(String.isNotBlank(objectName) && String.isNotBlank(parentObjName) && String.isNotBlank(fieldName)) 
            {
                dynlistLookupFilterUtils.LookupFilter lookupJson;
                List<Dynlist_Application_Setting__c> applicationSettings = [Select Id, Text_area_value__c, Text_area_value_2__c, Text_area_value_3__c 
                                                                            From Dynlist_Application_Setting__c 
                                                                            Where Name =: System.Label.DYNLIST_LOOKUP_FILTERS_RECORD_NAME  
                                                                            LIMIT 1];
                
                if (applicationSettings != null && applicationSettings.size() == 1) 
                {
                    String fieldNameString = parentObjName + dynlistConstants.CHAR_FULL_STOP + fieldName;
                    String filtersJSON = dynlistConstants.CHAR_BLANK_STRING;
                    Boolean isALookupWithFilters = false;
                    
                    if(String.isNotBlank(applicationSettings[0].Text_area_value__c)) 
                    {
                        filtersJSON = applicationSettings[0].Text_area_value__c;
                        if(applicationSettings[0].Text_area_value__c.containsIgnoreCase(fieldNameString)) 
                        {
                            isALookupWithFilters = true;    
                        }
                    }
                    
                    if(String.isNotBlank(applicationSettings[0].Text_area_value_2__c)) 
                    {
                        filtersJSON += applicationSettings[0].Text_area_value_2__c;
                        
                        if(applicationSettings[0].Text_area_value_2__c.containsIgnoreCase(fieldNameString)) 
                        {
                            isALookupWithFilters = true;    
                        }
                    }
                    
                    if(String.isNotBlank(applicationSettings[0].Text_area_value_3__c)) 
                    {
                        filtersJSON += applicationSettings[0].Text_area_value_3__c;
                        
                        if(applicationSettings[0].Text_area_value_3__c.containsIgnoreCase(fieldNameString)) 
                        {
                            isALookupWithFilters = true;    
                        }
                    }
                    if(isALookupWithFilters == true) 
                    {
                        lookupJson = (dynlistLookupFilterUtils.LookupFilter) JSON.deserialize(filtersJSON,dynlistLookupFilterUtils.LookupFilter.class);    
                    }
                    else 
                    {
                        lookupJson = null;    
                    }
                }
                if(lookupJson != null && lookupJson.records != null && lookupJson.records.size() > 0) 
                {
                    List<dynlistField> fieldsList = new List<dynlistField>();
                    for(dynlistLookupFilterUtils.Record filterRecord : lookupJson.records) 
                    {
                        if(filterRecord.TargetEntityDefinition != null && filterRecord.TargetEntityDefinition.FullName != null) 
                        {
                            if(filterRecord.TargetEntityDefinition.FullName.equalsIgnoreCase(objectName)) 
                            {
                                if(filterRecord.SourceFieldDefinition != null && filterRecord.SourceFieldDefinition.FullName != null) 
                                {
                                    if(filterRecord.SourceFieldDefinition.FullName.equalsIgnoreCase(parentObjName + dynlistConstants.CHAR_FULL_STOP + fieldName)) 
                                    {
                                        if(filterRecord.Metadata != null 
                                           && filterRecord.Metadata.filterItems != null 
                                           && filterRecord.Metadata.filterItems.size() > 0
                                          ) 
                                        {
                                            for(dynlistLookupFilterUtils.FilterItem filterItem : filterRecord.Metadata.filterItems) 
                                            {
                                                dynlistField fieldWrapper = new dynlistField();
                                                if(String.isNotBlank(filterItem.field) && String.isNotBlank(filterItem.operation)) 
                                                {
                                                    fieldWrapper.label = filterItem.field;
                                                    fieldWrapper.operation = filterItem.operation;
                                                    fieldWrapper.valueField = filterItem.valueField;
                                                    fieldWrapper.value = filterItem.value;
                                                    fieldWrapper.fieldName = filterItem.field;
                                                    fieldWrapper.name = filterItem.field;
                                                    fieldsList.add(fieldWrapper);        
                                                }
                                            }    
                                        }
                                    }
                                }
                            }
                        }
                    }
                    if(fieldsList.size() > 0)
                    {
                        String filtersDetails = dynlistLookupFilterUtils.getLookupFilterForField(lookupJson,objectName,parentObjName,fieldName,fieldsList,currentRowRecordId);
                        if(String.isNotBlank(filtersDetails)) 
                        {
                            dynlistSOQLBuilder builder = dynlistLookupFilterUtils.processLookupFilters(new dynlistSOQLBuilder(), 
                                                                                                       (dynlistLookupFilterUtils.SobjectLookupFilter)JSON.deserialize(filtersDetails, 
                                                                                                        dynlistLookupFilterUtils.SobjectLookupFilter.class),
                                                                                                       fieldsList,
                                                                                                       objectName
                                                                                                      );
                            if(builder != null) 
                            {
                                //queryString SELECT Id FROM WHERE ( Name like '%Burlington%'  AND  CreatedBy.FirstName != 'XYZ' )
                                filtersWhereClauseString = builder.toQuery();
                                
                                if(filtersWhereClauseString.split(dynlistConstants.CHAR_WHERE).size() > 1) 
                                {
                                    //( Name like '%Burlington%'  AND  CreatedBy.FirstName != 'XYZ' )
                                    filtersWhereClauseString = (filtersWhereClauseString.split(dynlistConstants.CHAR_WHERE)[1].trim());
                                } 
                                else 
                                {
                                    filtersWhereClauseString = dynlistConstants.CHAR_BLANK_STRING; 
                                }
                            }
                        }        
                    }
                }    
            }
            return filtersWhereClauseString;        
        }
        catch(Exception err) 
        {
            if (String.isNotBlank(err.getMessage()) && err.getMessage().contains(dynlistConstants.ERROR_WITH_COLON)) 
            {
                throw new AuraHandledException(err.getMessage().split(dynlistConstants.ERROR_WITH_COLON)[1].split(dynlistConstants.CHAR_COLON)[0] + dynlistConstants.CHAR_FULL_STOP);
            } 
            else 
            {
                throw new AuraHandledException(err.getMessage());
            }
        }
    }
    
    private static String getNameSynonymFieldName(String objectName) 
    {
        String nameSynonymFieldName = dynlistConstants.CHAR_BLANK_STRING;
        if(String.isNotBlank(objectName)) 
        {
            if(dynlistUtilities.setOfObjectForNameFieldNotAvailable.contains(objectName.toLowerCase())) 
            {
                if(dynlistUtilities.mapOfObjectAPINameWithSynonymField != null) 
                {
                    if(
                        String.isNotBlank(objectName)
                        && dynlistUtilities.mapOfObjectAPINameWithSynonymField != null 
                        && dynlistUtilities.mapOfObjectAPINameWithSynonymField.get(objectName.toLowerCase()) != null
                    ) 
                    {
                        nameSynonymFieldName = dynlistUtilities.mapOfObjectAPINameWithSynonymField.get(objectName.toLowerCase());
                    }
                }      
            }    
        }
        return nameSynonymFieldName;
    }
    
    private static List<SObJectResult> getUpdatedSObjectResults(String query, String nameSynonymFieldName) 
    {
        List<SObJectResult> sObjectResultList = new List<SObJectResult>();
        if(String.isNotBlank(query)) 
        {
            for (sObject so : Database.Query(query)) 
            {
                String fieldvalue = dynlistConstants.CHAR_BLANK_STRING;
                if(String.isNotBlank(nameSynonymFieldName)) 
                {
                    fieldvalue = (String) so.get(nameSynonymFieldName);
                }
                else 
                {
                    fieldvalue = (String) so.get(dynlistConstants.NAME_FIELD_NAME);    
                }
                sObjectResultList.add(new SObjectResult(fieldvalue, so.Id));
            }         
        }
        return sObjectResultList;
    }
        
    private static string buildSOQLOrderByFurtherClauses(String nameSynonymFieldName, String recordsToDisplayCount) 
    {
        String query = dynlistConstants.CHAR_BLANK_STRING;
        query += dynlistConstants.CHAR_BLANK_SPACE + dynlistConstants.CHAR_ORDER_BY + dynlistConstants.CHAR_BLANK_SPACE + dynlistConstants.ID_FIELD_NAME
                + dynlistConstants.CHAR_BLANK_SPACE + dynlistConstants.CHAR_DESC + dynlistConstants.CHAR_BLANK_SPACE; 
        if(String.isNotBlank(recordsToDisplayCount)) 
        {
        	query += dynlistConstants.CHAR_BLANK_SPACE + dynlistConstants.CHAR_LIMIT + dynlistConstants.CHAR_BLANK_SPACE + recordsToDisplayCount;    
        }
        return query;    
    }
    
    private static string buildSOQLWhereClause(
        String objectName, //Account
        String searchValue, //Burlington
        String parentObjName, //Opportunity
        String fieldName, //Account_Filter_Lookup_1__c,
        Boolean removeLookupFilters,
        String nameSynonymFieldName,
        String currentRowRecordId
    ) 
    {
        String query = dynlistConstants.CHAR_BLANK_STRING;
        String fieldFiltersWhereClauseString = dynlistLookupController.getLookupFiltersWhereClauseString(objectName, parentObjName, fieldName, currentRowRecordId);
        
        if (objectName.equalsIgnoreCase(dynlistConstants.RECORD_TYPE_API_NAME)) 
        {
            if (String.isBlank(searchValue)) 
            {
                query += ' WHERE SobjectType =\'' + parentObjName + '\' AND IsActive = true ';
            }
            else 
            {
                query += ' WHERE SobjectType =\'' + parentObjName + '\' AND IsActive = true AND Name LIKE \'%' + searchValue + '%\'';    
            }
        } 
        else 
        {
            if (String.isBlank(searchValue)) 
            {
                if(String.isNotBlank(fieldFiltersWhereClauseString) && !removeLookupFilters) 
                {
                    query += ' WHERE ' + fieldFiltersWhereClauseString;
                }
            }
            else 
            {
                if(String.isNotBlank(nameSynonymFieldName)) 
                {
                    query += ' WHERE ' + nameSynonymFieldName + ' ' + 'LIKE \'%' + searchValue + '%\'';
                }
                else 
                {
                    query += ' WHERE Name LIKE \'%' + searchValue + '%\'';        
                }
                
                if(String.isNotBlank(fieldFiltersWhereClauseString) && !removeLookupFilters) 
                {
                    query += ' AND ' + fieldFiltersWhereClauseString;
                }
            } 
        }
        return query;
    }    
    
    private static string buildSOQLUptoFROMClause(
        String objectName, //Account
        String searchValue, //Burlington
        String parentObjName, //Opportunity
        String fieldName, //Account_Filter_Lookup_1__c,
        Boolean removeLookupFilters,
        String nameSynonymFieldName
    ) 
    {
    	String query = 'SELECT Id ,';
            
        if(String.isNotBlank(nameSynonymFieldName)) 
        {
            query += dynlistConstants.CHAR_BLANK_SPACE + nameSynonymFieldName + ' FROM ' + objectName;
        }
        else 
        {
            query += ' Name' + ' FROM ' + objectName;    
        }
        return query;
    }
    
    public class SObjectResultsWrapper 
    {
        @AuraEnabled
        public List<SObjectResult> sObjectResults { get; set; }
        
        @AuraEnabled
        public Boolean loadMoreRecordsAvailable { get; set; }
        
        public SObjectResultsWrapper() 
        {
            this.sObjectResults = new List<SObjectResult>();
            loadMoreRecordsAvailable = false;
        }
        
        public SObjectResultsWrapper(List<SObjectResult> sObjectResults, Boolean loadMoreRecordsAvailable) 
        {
            this.sObjectResults = sObjectResults;
            this.loadMoreRecordsAvailable = loadMoreRecordsAvailable;
        }
    }
     
    public class SObjectResult 
    {
        @AuraEnabled
        public String recName { get; set; }
        
        @AuraEnabled
        public Id recId { get; set; }
        
        public SObjectResult(String recNameTemp, Id recIdTemp) 
        {
            recName = recNameTemp;
            recId = recIdTemp;
        }
    }
}