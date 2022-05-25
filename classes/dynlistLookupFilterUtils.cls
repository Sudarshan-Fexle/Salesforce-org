/*
Purpose         :   Util class to fetch and parse lookup filters (Dynamic Related List)
Created By      :   Abhinav Sharma
Created Date    :   10/26/2021
Current Version :   v1.0
Revision Log    :   V_1.0 Created - Abhinav Sharma - 10/26/2021
*/
public with sharing class dynlistLookupFilterUtils implements Queueable, Database.AllowsCallouts 
{   
    private Set<String> remainingDeveloperNames;
    private List<String> lookupFilterList;
    private String session_Id;
    
    //Default constructor for visualforce page LightningLookupFiltersSetup
    public dynlistLookupFilterUtils() {}
    
    //Constructor for queueable jobs
    public dynlistLookupFilterUtils(Set<String> remainingDeveloperNames, List<String> lookupFilters,String session_Id) 
    {
        this.remainingDeveloperNames = remainingDeveloperNames;
        this.lookupFilterList = lookupFilters;
        this.session_Id = session_Id;
    }
    
    /**
    *  Method to fetch lookup filters and update application setting.
    */
    public void execute(QueueableContext context) 
    {
        List<String> developerNames = new List<String>();
        developerNames.addAll(remainingDeveloperNames);
        for(String devName : developerNames) 
        {
            String response = getLookupFilter(devName,session_Id);
            remainingDeveloperNames.remove(devName);
            if(String.isNotBlank(response)) 
            {
                lookupFilterList.add(response);
            }
            if(Limits.getCallouts() == Limits.getLimitCallouts()) 
            {
                break;
            }
        }
        if(remainingDeveloperNames.size() > 0) 
        {
            System.enqueueJob(New dynlistLookupFilterUtils(remainingDeveloperNames,lookupFilterList,session_Id));
        }
        else 
        {
            upsertApplicationSetting(lookupFilterList);
        }
    }
    
    private static FINAL String ORG_INSTANCE;
    private static FINAL String TOOLINGAPI_ENDPOINT;
    private static FINAL String LOOKUPFILTER_DEV_QUERY;
    private static FINAL String LOOKUPFILTER_DATA_QUERY;
    
    static
    {
        ORG_INSTANCE = dynlistUtilities.getMySalesforceInstance();
        TOOLINGAPI_ENDPOINT = dynlistConstants.CHAR_HTTPS + ORG_INSTANCE + System.Label.DYNLIST_TOOLING_API_ENDPOINT;
        LOOKUPFILTER_DEV_QUERY = System.Label.DYNLIST_TOOLING_LOOKUP_FILTERS_QUERY;
        LOOKUPFILTER_DATA_QUERY = System.Label.DYNLIST_TOOLING_LOOKUP_DATA_QUERY;
    }
    
    /**
    *  Method to call sendToolingQueryRequest.
    *  @param - developerName of lookup filter, current user sessionId
    *  @return - Body of response.
    */
    private static String getLookupFilter(String developerName, String sessionId) 
    {
        return sendToolingQueryRequest(LOOKUPFILTER_DATA_QUERY + '\'' + developerName + '\'', sessionId);
    }
    
    /**
    *  Method to hit tooling API.
    *  @param  query structure, current user sessionId
    *  @return - Body of response.
    */
    private static String sendToolingQueryRequest(String queryStr, String sessionId)
    {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(TOOLINGAPI_ENDPOINT  + dynlistConstants.CHAR_QUERY_STRING_LITERAL + queryStr);
        if(String.isBlank(sessionId)) 
        {
            return null;
        }
        
        /*Set authorization by using current users session Id*/
        req.setHeader(dynlistConstants.CHAR_AUTHORIZATION, dynlistConstants.CHAR_BEARER + dynlistConstants.CHAR_BLANK_SPACE + sessionId);
        req.setHeader(dynlistConstants.CHAR_CONTENT_TYPE, dynlistConstants.CHAR_APPLICATION_JSON);
        req.setMethod(dynlistConstants.HTTP_GET_METHOD);
        req.setTimeout(dynlistConstants.HTTP_MAX_TIMEOUT_VALUE);
        Http http = new Http();
        HTTPResponse res = http.send(req);
        if(res.getStatusCode() >= dynlistConstants.HTTP_CALLOUT_SUCCESS_STATUS_CODE && res.getStatusCode() < dynlistConstants.HTTP_CALLOUT_STATUS_CODE_300) 
        {
            return res.getBody();
        }
        return null;
    }
    
    /**
    *  Method to fetch lookup filter developer names using tooling API.
    *  @return - List of LookupFilter's DeveloperName.
    */
    private static List<String> getLookupFilterDeveloperName() 
    {
        List<String> developerNames = new List<String>();
        String response = sendToolingQueryRequest(LOOKUPFILTER_DEV_QUERY, UserInfo.getSessionId());
        if(String.isNotBlank(response)) 
        {
            dynlistLookupFilterUtils.LookupFilter responseJson = (dynlistLookupFilterUtils.LookupFilter) JSON.deserialize(response, dynlistLookupFilterUtils.LookupFilter.class);
            if(responseJson != null && responseJson.records != null && responseJson.records.size() > 0) 
            {
                for(dynlistLookupFilterUtils.Record record : responseJson.records) 
                {
                    if(String.isNotBlank(record.DeveloperName)) 
                    {
                        developerNames.add(record.DeveloperName);
                    }
                }
            }
        }
        return developerNames;
    }
    
    /**
    *  Method to upsert lookup filter json in application setting
    *  and queue asynchronous jobs in case of more than 99 filters
    */
    public static void upsertLookupFilters() 
    {
        try {
            List<String> developerNames = getLookupFilterDeveloperName();
            List<String> lookupFilters = new List<String>();
            Set<String> remainingDeveloperNames = new Set<String>();
            if(developerNames != null && developerNames.size() > 0) 
            {
                remainingDeveloperNames.addAll(developerNames);
                for(String devName : developerNames) 
                {
                    String response = getLookupFilter(devName, UserInfo.getSessionId());
                    remainingDeveloperNames.remove(devName);
                    if(String.isNotBlank(response)) 
                    {
                        lookupFilters.add(response);
                    }
                    if(Limits.getCallouts() == Limits.getLimitCallouts()) 
                    {
                        break;
                    }
                }
                if(remainingDeveloperNames.size() > 0) 
                {
                    System.enqueueJob(New dynlistLookupFilterUtils(remainingDeveloperNames,lookupFilters, UserInfo.getSessionId()));
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO,  System.Label.DYNLIST_LOOKUP_FILTERS_ASYNCHRONOUS ));
                }
                else 
                {
                    upsertApplicationSetting(lookupFilters);
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM, System.Label.DYNLIST_REFRESH_LOOKUP_FILTERS_SUCCESS ));
                }
            }
            else 
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, System.Label.DYNLIST_LOOKUP_FILTER_PERMISSION_ERROR));
            }
        } 
        catch(Exception e) 
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()));
        }
    }
    
    /**
    *  Method to upsert lookup filter json in application setting.
    *  @param - list of lookup filter json
    */
    private static void upsertApplicationSetting(List<String> lookupFilters) 
    {
        dynlistLookupFilterUtils.LookupFilter finalJson = new dynlistLookupFilterUtils.LookupFilter();
        List<dynlistLookupFilterUtils.Record> records = new List<dynlistLookupFilterUtils.Record>();
        for(String lookupFilter : lookupFilters) 
        {
            dynlistLookupFilterUtils.LookupFilter lookupJson = (dynlistLookupFilterUtils.LookupFilter) JSON.deserialize(lookupFilter, dynlistLookupFilterUtils.LookupFilter.class);
            if(lookupJson != null && lookupJson.records != null && lookupJson.records.size() > 0) 
            {
                records.add(lookupJson.records[0]);
            }
        }
        finalJson.records = records;
        String actualJSONString = JSON.serialize(finalJson);
        
        if(String.isNotBlank(actualJSONString)) 
        {
            List<Dynlist_Application_Setting__c> applicationSettings = [Select Id, Display__c, Text_area_value__c, 
                                                                        Text_area_value_2__c, Text_area_value_3__c  
                                                                        From Dynlist_Application_Setting__c  
                                                                        Where Name =: System.Label.DYNLIST_LOOKUP_FILTERS_RECORD_NAME  
                                                                        LIMIT 1];
            
            String filtersJSON = dynlistConstants.CHAR_BLANK_STRING;
            if(applicationSettings != null && applicationSettings.size() == 1) 
            {
                if(actualJSONString.length() > Integer.valueOf(System.Label.DYNLIST_LONG_TEXT_AREA_CHAR_LIMIT)) 
                {
                    Decimal extendedByTimes = Decimal.valueOf(actualJSONString.length()/Integer.valueOf(System.Label.DYNLIST_LONG_TEXT_AREA_CHAR_LIMIT));
                    Integer extendedByTimesInt = Integer.valueOf(Math.floor(extendedByTimes));
                    applicationSettings[0].Text_area_value__c = actualJSONString.substring(0, (Integer.valueOf(System.Label.DYNLIST_LONG_TEXT_AREA_CHAR_LIMIT)-1));
                    
                    if(extendedByTimesInt == 1) 
                    {
                        applicationSettings[0].Text_area_value_2__c = actualJSONString.substring((Integer.valueOf(System.Label.DYNLIST_LONG_TEXT_AREA_CHAR_LIMIT)-1), 
                                                       actualJSONString.length());
                    }
                    
                    if(extendedByTimesInt == 2) 
                    {
                        Integer twoTimesofAllowedLimited = 2 * Integer.valueOf(System.Label.DYNLIST_LONG_TEXT_AREA_CHAR_LIMIT);
                        
                        applicationSettings[0].Text_area_value_2__c = actualJSONString.substring((Integer.valueOf(System.Label.DYNLIST_LONG_TEXT_AREA_CHAR_LIMIT)-1), 
                                                       (twoTimesofAllowedLimited-1));
                        
                        applicationSettings[0].Text_area_value_3__c = actualJSONString.substring(twoTimesofAllowedLimited-1, actualJSONString.length());
                    }
                }
                else 
                {
                    applicationSettings[0].Text_area_value__c = actualJSONString;        
                }
            }
            else 
            {
                if(actualJSONString.length() > Integer.valueOf(System.Label.DYNLIST_LONG_TEXT_AREA_CHAR_LIMIT)) 
                {
                    Decimal extendedByTimesElse = Decimal.valueOf(actualJSONString.length()/Integer.valueOf(System.Label.DYNLIST_LONG_TEXT_AREA_CHAR_LIMIT));
                    Integer extendedByTimesIntElse = Integer.valueOf(Math.floor(extendedByTimesElse));
                    
                    applicationSettings = new List<Dynlist_Application_Setting__c>();
                    
                    Dynlist_Application_Setting__c appSetting = new Dynlist_Application_Setting__c();
                    appSetting.Display__c = dynlistConstants.CHAR_HIDDEN;
                    appSetting.Name = System.Label.DYNLIST_LOOKUP_FILTERS_RECORD_NAME;
                    appSetting.Text_area_value__c = actualJSONString.substring(0, (Integer.valueOf(System.Label.DYNLIST_LONG_TEXT_AREA_CHAR_LIMIT)-1));
                    
                    if(extendedByTimesIntElse == 1) 
                    {
                        appSetting.Text_area_value_2__c = actualJSONString.substring(Integer.valueOf(System.Label.DYNLIST_LONG_TEXT_AREA_CHAR_LIMIT), actualJSONString.length());
                    }
                    
                    if(extendedByTimesIntElse == 2) 
                    {
                        Integer twoTimesofAllowedLimitedElse = 2 * Integer.valueOf(System.Label.DYNLIST_LONG_TEXT_AREA_CHAR_LIMIT);
                        appSetting.Text_area_value_2__c = actualJSONString.substring(Integer.valueOf(System.Label.DYNLIST_LONG_TEXT_AREA_CHAR_LIMIT), (twoTimesofAllowedLimitedElse-1));
                        appSetting.Text_area_value_3__c = actualJSONString.substring(twoTimesofAllowedLimitedElse, actualJSONString.length());
                    }
                    
                    applicationSettings.add(appSetting);
                }
                else 
                {
                    applicationSettings = new List<Dynlist_Application_Setting__c>();
                    applicationSettings.add(new Dynlist_Application_Setting__c(Name=System.Label.DYNLIST_LOOKUP_FILTERS_RECORD_NAME, 
                                                                               Text_area_value__c= actualJSONString, 
                                                                               Display__c= dynlistConstants.CHAR_HIDDEN));        
                }
            }
            
            if(applicationSettings != null && applicationSettings.size() == 1) 
            {
                upsert applicationSettings;
            }
        }
    }
    
    //========================================================Lookup Filters==============================================//
    public static dynlistSOQLBuilder processLookupFilters(dynlistSOQLBuilder builder, SobjectLookupFilter sobjectLookupFilter, List<dynlistField> uiRecordFields, String objectName) 
    {
        addLookupFilters(builder, sobjectLookupFilter, uiRecordFields, objectName); 
        return builder;
    }
    
    /**
    *  Method to add lookup filter conditions in dynlistSOQLBuilder instance. 
    *  Use existing dynlistSOQLBuilder from LookupController(searchSObject) to add filter conditions.
    *  @param  builder dynlistSOQLBuilder.class instance.
    *  @param  sobjectLookupFilter dynlistLookupFilterUtils.SobjectLookupFilter.class instance, holding all required data for a lookup field .
    *  @param  uiRecordFields List of dynlistField.class instance, holding all fields detail on UI(fieldSet).
    *  @exception
    */
    public static void addLookupFilters(dynlistSOQLBuilder builder, SobjectLookupFilter sobjectLookupFilter, List<dynlistField> uiRecordFields, String objectName) 
    {
        try
        {
            if(sobjectLookupFilter.filterMetadata != null && sobjectLookupFilter.filterMetadata.filterItems!= null && sobjectLookupFilter.filterMetadata.filterItems.size() > 0) 
            {
                Map<String,dynlistField> uiRecordFieldsMap = new Map<String,dynlistField>();
                
                if(uiRecordFields != null && uiRecordFields.size() > 0) 
                {
                    uiRecordFieldsMap =  getUIRecordInstance(uiRecordFields);
                }
                
                Map<String, Object> currentFieldNotOnUIData = new Map<String, Object>();
                if(sobjectLookupFilter.currentFieldNotOnUIData.size() == 1) 
                {
                    currentFieldNotOnUIData = sobjectLookupFilter.currentFieldNotOnUIData[0].getPopulatedFieldsAsMap();
                }
                
                /*@@@@ sobjectLookupFilter.filterMetadata.filterItems (
                * FilterItem:[field=Account.Name, operation=contains, value=Burlington, valueField=null], 
                * FilterItem:[field=Account.CreatedBy.FirstName, operation=notEqual, value=XYZ, valueField=null]
                * )*/
                for(FilterItem filter : sobjectLookupFilter.filterMetadata.filterItems) 
                {
                    String fieldName = filter.field.substringAfter(dynlistConstants.CHAR_FULL_STOP);
                    
                    //When on right hand side we have a fixed value/values
                    if(String.isBlank(filter.valueField)) 
                    {
                        //Checking that containing $
                        if(filter.field.indexOf(dynlistConstants.CHAR_DOLLOR) != -1) 
                        {
                            String fieldValue;
                            
                            //$Source Field - Value
                            if(filter.field.indexOf(dynlistConstants.CHAR_DOLLOR_SOURCE) != -1) 
                            {
                                fieldValue = getSourceFieldValue(sobjectLookupFilter.currentFieldOnUI, currentFieldNotOnUIData, uiRecordFieldsMap, fieldName);
                            }
                            //$User Field - Value || $User Role Field - Value || $Profile Field - Value
                            else if(filter.field.indexOf(dynlistConstants.CHAR_DOLLOR_USER) != -1 
                                    || filter.field.indexOf(dynlistConstants.CHAR_DOLLOR_USER_ROLE) != -1 
                                    || filter.field.indexOf(dynlistConstants.CHAR_DOLLOR_PROFILE) != -1) 
                            {
                                fieldValue = sobjectLookupFilter.userFieldsData.get(filter.field);
                            }
                            
                            //if fieldName is RecordTypeId then do Special handling for the case of record types
            				if(String.isNotBlank(fieldName) && fieldName.trim().equalsIgnoreCase(dynlistConstants.RECORD_TYPE_ID_FIELD_NAME))
                            {
                            	//get record type ID by record type label, if provided values is not a valid ID value
                                if(!dynlistUtilities.isaValidateSalesforceID(filter.value)) 
                                {
                                    filter.value = dynlistUtilities.getRecordTypeIdForObject(objectName, filter.value);        
                                }
                                else 
                                {
                                    filter.value = filter.value.trim();   
                                }
                            }
                            else 
                            {
                            	addFilterWhereClauseByType(builder,filter.operation,fieldValue,filter.value,sobjectLookupFilter.fieldsDataType.get(filter.field),true, objectName, fieldName, filter.field);
                            }
                            continue;
                        }
                        //Parent - Value
                        else 
                        {
                            addFilterWhereClauseByType(builder,filter.operation,fieldName,filter.value,sobjectLookupFilter.fieldsDataType.get(filter.field),false, objectName, fieldName, filter.field);
                            continue;
                        }
                    }
                    //When on right hand side we have a field reference
                    else 
                    {
                        String valueFieldName = filter.valueField.substringAfter(dynlistConstants.CHAR_FULL_STOP);
                        
                        //checking $ presence on the both sides
                        if(filter.field.indexOf(dynlistConstants.CHAR_DOLLOR) != -1 && filter.valueField.indexOf(dynlistConstants.CHAR_DOLLOR) != -1) 
                        {
                            String column;
                            String value;
                            
                            //$Source.dynlist__Number__c - Field
                            if(filter.field.indexOf(dynlistConstants.CHAR_DOLLOR_SOURCE) != -1) 
                            {
                                column = getSourceFieldValue(sobjectLookupFilter.currentFieldOnUI, currentFieldNotOnUIData, uiRecordFieldsMap, fieldName);
                            }
                            else
                            {
                                column = sobjectLookupFilter.userFieldsData.get(filter.field);
                            }
                            
                            if(filter.valueField.indexOf(dynlistConstants.CHAR_DOLLOR_SOURCE) != -1) 
                            {
                                value = getSourceFieldValue(sobjectLookupFilter.currentFieldOnUI, currentFieldNotOnUIData, uiRecordFieldsMap, valueFieldName);
                            }
                            else
                            {
                                value = sobjectLookupFilter.userFieldsData.get(filter.valueField);
                            }
                            
                            addFilterWhereClauseByType(builder,filter.operation,column,value,sobjectLookupFilter.fieldsDataType.get(filter.field),true, objectName, fieldName, filter.field);
                            continue;
                        }
                        else if(filter.field.indexOf(dynlistConstants.CHAR_DOLLOR) != -1) 
                        {
                            String value;
                            if(filter.field.indexOf(dynlistConstants.CHAR_DOLLOR_SOURCE) != -1) 
                            {
                                value = getSourceFieldValue(sobjectLookupFilter.currentFieldOnUI, currentFieldNotOnUIData, uiRecordFieldsMap, fieldName);
                            }
                            else if(sobjectLookupFilter.userFieldsData.containsKey(filter.field)) 
                            {
                                value = sobjectLookupFilter.userFieldsData.get(filter.field);
                            }
                            addFilterWhereClauseByType(builder,filter.operation,valueFieldName,value,sobjectLookupFilter.fieldsDataType.get(filter.valueField),false, objectName, fieldName, filter.field);
                            continue;
                        }
                        else if(filter.valueField.indexOf(dynlistConstants.CHAR_DOLLOR) != -1) 
                        {
                            String value;
                            if(filter.valueField.indexOf(dynlistConstants.CHAR_DOLLOR_SOURCE) != -1) 
                            {
                                value = getSourceFieldValue(sobjectLookupFilter.currentFieldOnUI, currentFieldNotOnUIData, uiRecordFieldsMap, valueFieldName);
                            }
                            else if(sobjectLookupFilter.userFieldsData.containsKey(filter.valueField)) 
                            {
                                value = sobjectLookupFilter.userFieldsData.get(filter.valueField);
                            }
                            addFilterWhereClauseByType(builder,filter.operation,fieldName,value,sobjectLookupFilter.fieldsDataType.get(filter.field),false, objectName, fieldName, filter.field);
                            continue;
                        }
                        else 
                        {
                            System.debug('@@@@@ Parent Lookup field == Parent Lookup field');
                            continue;
                            //TODO Lookup field == Lookup field
                        }
                    }
                }
                if(String.isNotBlank(sobjectLookupFilter.filterMetadata.booleanFilter)) 
                {
                    builder.setConditionLogic(sobjectLookupFilter.filterMetadata.booleanFilter);
                }
            }
        } 
        catch(Exception e) 
        {
            System.debug('@@Exception:::'+e.getMessage()+'StackTraceString:::'+e.getStackTraceString());
            return;
        }
    }
    
    /**
    *  Method to collect all required data for a lookup in dynlistLookupFilterUtils.SobjectLookupFilter.class instance.
    *  @param  lookupJson dynlistLookupFilterUtils.LookupFilter.class instance, holding all filters detail in org.
    *  @param  objectName lookup field's referenced object name.
    *  @param  sourceObjectName lookup field's object name.
    *  @param  sourceFieldName lookup field's API name.
    *  @param  uiRecordFields List of dynlistField.class instance, holding all fields detail on UI(fieldSet).
    *  @param  recordId Id of sourceObjectName's current record on UI(in case of edit).
    *  @return - dynlistLookupFilterUtils.SobjectLookupFilter class instance in a Json format.
    *  @exception - Returns null, if any exception occurs.
    */
    public static String getLookupFilterForField(LookupFilter lookupJson, String objectName, String sourceObjectName, String sourceFieldName,List<dynlistField> uiRecordFields, String recordId) 
    {
        try 
        {
            Map<String, Schema.SObjectType> objMap = Schema.getGlobalDescribe();
            Map<String, Map<String, Schema.SObjectField>> objFieldsMap = new Map<String, Map<String, Schema.SObjectField>>();
            SobjectLookupFilter sobjectLookupFilter = new SobjectLookupFilter();
            Map<String, String> userFieldsMapping = new Map<String, String>();
            Map<String,dynlistField> uiRecordFieldsMap =  getUIRecordInstance(uiRecordFields);
            
            for (Record filterData : lookupJson.records) 
            {
                if(filterData.TargetEntityDefinition == null || filterData.SourceFieldDefinition == null) 
                {
                    continue;
                }
                Boolean isFound = false;
                String lookupSobjectName = filterData.TargetEntityDefinition.FullName;
                String currentSourceObjName = filterData.SourceFieldDefinition.FullName.substringBefore(dynlistConstants.CHAR_FULL_STOP);
                if (lookupSobjectName.endsWithIgnoreCase(objectName) && currentSourceObjName.endsWithIgnoreCase(sourceObjectName) 
                    && filterData.SourceFieldDefinition.FullName.substringAfter(dynlistConstants.CHAR_FULL_STOP).endsWithIgnoreCase(sourceFieldName)) 
                {
                    if(!filterData.Metadata.active) 
                    {
                        break;
                    }
                    sobjectLookupFilter.sourceObjectName = currentSourceObjName;
                    sobjectLookupFilter.targetObjectName = lookupSobjectName;
                    sobjectLookupFilter.sourceFieldName = filterData.SourceFieldDefinition.FullName.substringAfter(dynlistConstants.CHAR_FULL_STOP);
                    isFound = true;
                    sobjectLookupFilter.addFilterMetadata(filterData.Metadata);
                    for (FilterItem filter : filterData.Metadata.filterItems) 
                    {
                        String fieldName = filter.field.substringAfter(dynlistConstants.CHAR_FULL_STOP);
                        
                        //Possible values for field in lookup filter is $Source,$User,$UserRole,$Profile and Lookup object's field.
                        //Same values for valueField
                        //Handling According to that possible values
                        if(filter.field.indexOf(dynlistConstants.CHAR_DOLLOR) != -1) 
                        {
                            if(filter.field.indexOf(dynlistConstants.CHAR_DOLLOR_SOURCE) != -1) 
                            {
                                if(uiRecordFieldsMap.containsKey(filter.field.substringAfter(dynlistConstants.CHAR_FULL_STOP))) 
                                {
                                    sobjectLookupFilter.addCurrentFieldOnUI(filter.field.substringAfter(dynlistConstants.CHAR_FULL_STOP));
                                    addFieldsMap(objMap,objFieldsMap,currentSourceObjName);
                                    if(!sobjectLookupFilter.fieldsDataType.containsKey(filter.field)) 
                                    {
                                        sobjectLookupFilter.fieldsDataType.put(filter.field, objFieldsMap.get(currentSourceObjName.toLowerCase()).get(fieldName.toLowerCase()).getDescribe().getType());   
                                    }
                                }
                                else 
                                {
                                    sobjectLookupFilter.addCurrentFieldNotOnUI(filter.field.substringAfter(dynlistConstants.CHAR_FULL_STOP));
                                    addFieldsMap(objMap,objFieldsMap,currentSourceObjName);
                                    if(!sobjectLookupFilter.fieldsDataType.containsKey(filter.field)) 
                                    {
                                        sobjectLookupFilter.fieldsDataType.put(filter.field, objFieldsMap.get(currentSourceObjName.toLowerCase()).get(fieldName.toLowerCase()).getDescribe().getType());   
                                    }
                                }
                            }
                            else if(filter.field.indexOf(dynlistConstants.CHAR_DOLLOR_USER_ROLE) != -1) 
                            {
                                userFieldsMapping.put(filter.field.removeStart(dynlistConstants.CHAR_DOLLOR),filter.field);
                                addFieldsMap(objMap,objFieldsMap,dynlistConstants.CHAR_USER_ROLE_LOWERCASE);
                                if(!sobjectLookupFilter.fieldsDataType.containsKey(filter.field)) 
                                {
                                    sobjectLookupFilter.fieldsDataType.put(filter.field, objFieldsMap.get(dynlistConstants.CHAR_USER_ROLE_LOWERCASE).get(fieldName.toLowerCase()).getDescribe().getType());
                                }
                                
                            }
                            else if(filter.field.indexOf(dynlistConstants.CHAR_DOLLOR_USER) != -1) 
                            {
                                userFieldsMapping.put(filter.field.substringAfter(dynlistConstants.CHAR_FULL_STOP),filter.field);
                                addFieldsMap(objMap,objFieldsMap,dynlistConstants.CHAR_USER_LOWERCASE);
                                if(!sobjectLookupFilter.fieldsDataType.containsKey(filter.field)) 
                                {
                                    sobjectLookupFilter.fieldsDataType.put(filter.field, 
                                                                           objFieldsMap.get(dynlistConstants.CHAR_USER_LOWERCASE).get(fieldName.toLowerCase()).getDescribe().getType());
                                }
                            }
                            else if(filter.field.indexOf(dynlistConstants.CHAR_DOLLOR_PROFILE) != -1) 
                            {
                                String profileFieldName = filter.field.removeStart(dynlistConstants.CHAR_DOLLOR).toLowerCase();
                                userFieldsMapping.put(profileFieldName.contains(dynlistConstants.CHAR_MANAGE_USERS_LOWERCASE)?profileFieldName.replace(dynlistConstants.CHAR_MANAGE_USERS_LOWERCASE, dynlistConstants.CHAR_PERMISSIONS_MANAGE_USERS_LOWERCASE):profileFieldName,filter.field);
                                addFieldsMap(objMap,objFieldsMap,dynlistConstants.CHAR_PROFILE_LOWERCASE);
                                if(!sobjectLookupFilter.fieldsDataType.containsKey(filter.field)) 
                                {
                                    sobjectLookupFilter.fieldsDataType.put(filter.field, objFieldsMap.get(dynlistConstants.CHAR_PROFILE_LOWERCASE).get(fieldName.toLowerCase()==dynlistConstants.CHAR_MANAGE_USERS_LOWERCASE?dynlistConstants.CHAR_PERMISSIONS_MANAGE_USERS_LOWERCASE:fieldName.toLowerCase()).getDescribe().getType());
                                }
                            }
                        }
                        else if(fieldName.contains(dynlistConstants.CHAR_FULL_STOP))
                        {
                            String relationFieldName = fieldName.substringBefore(dynlistConstants.CHAR_FULL_STOP).endsWith(dynlistConstants.CHAR_DOUBLE_UNDERSCORE_R)?fieldName.substringBefore(dynlistConstants.CHAR_FULL_STOP).replace(dynlistConstants.CHAR_DOUBLE_UNDERSCORE_R,dynlistConstants.CHAR_DOUBLE_UNDERSCORE_C):fieldName.substringBefore(dynlistConstants.CHAR_FULL_STOP);
                            String relatedObjName = fieldName.substringBefore(dynlistConstants.CHAR_FULL_STOP);
                            if(relationFieldName.endsWith(dynlistConstants.CHAR_DOUBLE_UNDERSCORE_C)) 
                            {
                                relatedObjName = String.valueOf(objMap.get(lookupSobjectName.toLowerCase()).getDescribe().fields.getMap().get(relationFieldName.toLowerCase()).getDescribe().getReferenceTo()[0]);
                            }
                            addFieldsMap(objMap,objFieldsMap,relatedObjName);
                            if(!sobjectLookupFilter.fieldsDataType.containsKey(filter.field)) 
                            {
                                if(String.isNotBlank(relatedObjName) 
                                   && objFieldsMap.get(relatedObjName.toLowerCase()) != null 
                                   && String.isNotBlank(fieldName)
                                  ) 
                                {
                                    sobjectLookupFilter.fieldsDataType.put(filter.field, objFieldsMap.get(relatedObjName.toLowerCase()).get(fieldName.substringAfter(dynlistConstants.CHAR_FULL_STOP).toLowerCase()).getDescribe().getType());          
                                }
                            }
                        }
                        //In case of RecordTypeId it will come here
                        else 
                        {
                            addFieldsMap(objMap,objFieldsMap,filter.field.substringBefore(dynlistConstants.CHAR_FULL_STOP));
                            if(!sobjectLookupFilter.fieldsDataType.containsKey(filter.field)) 
                            {
                                sobjectLookupFilter.fieldsDataType.put(filter.field, objFieldsMap.get(filter.field.substringBefore(dynlistConstants.CHAR_FULL_STOP).toLowerCase()).get(fieldName.toLowerCase()).getDescribe().getType());
                            }
                        }
                        if(String.isNotBlank(filter.valueField)) 
                        {
                            String valueFieldName = filter.valueField.substringAfter(dynlistConstants.CHAR_FULL_STOP);
                            if(filter.valueField.indexOf(dynlistConstants.CHAR_DOLLOR) != -1) 
                            {
                                if(filter.valueField.indexOf(dynlistConstants.CHAR_DOLLOR_SOURCE) != -1) 
                                {
                                    if(uiRecordFieldsMap.containsKey(filter.valueField.substringAfter(dynlistConstants.CHAR_FULL_STOP))) 
                                    {
                                        sobjectLookupFilter.addCurrentFieldOnUI(filter.valueField.substringAfter(dynlistConstants.CHAR_FULL_STOP));
                                    }
                                    else 
                                    {
                                        sobjectLookupFilter.addCurrentFieldNotOnUI(filter.valueField.substringAfter(dynlistConstants.CHAR_FULL_STOP));
                                    }
                                }
                                else if(filter.valueField.indexOf(dynlistConstants.CHAR_DOLLOR_USER_ROLE) != -1) 
                                {
                                    userFieldsMapping.put(filter.valueField.removeStart(dynlistConstants.CHAR_DOLLOR),filter.valueField);
                                }
                                else if(filter.valueField.indexOf(dynlistConstants.CHAR_DOLLOR_USER) != -1) 
                                {
                                    userFieldsMapping.put(filter.valueField.substringAfter(dynlistConstants.CHAR_FULL_STOP),filter.valueField);
                                }
                                else if(filter.valueField.indexOf(dynlistConstants.CHAR_DOLLOR_PROFILE) != -1) 
                                {
                                    String profileFieldName = filter.valueField.removeStart(dynlistConstants.CHAR_DOLLOR).toLowerCase();
                                    userFieldsMapping.put(profileFieldName.contains(dynlistConstants.CHAR_MANAGE_USERS_LOWERCASE)?profileFieldName.replace(dynlistConstants.CHAR_MANAGE_USERS_LOWERCASE, dynlistConstants.CHAR_PERMISSIONS_MANAGE_USERS_LOWERCASE):profileFieldName,filter.valueField);
                                }
                            }
                            else if(valueFieldName.contains(dynlistConstants.CHAR_FULL_STOP))
                            {
                                String relationvalueFieldName = valueFieldName.substringBefore(dynlistConstants.CHAR_FULL_STOP).endsWith(dynlistConstants.CHAR_DOUBLE_UNDERSCORE_R)?valueFieldName.substringBefore(dynlistConstants.CHAR_FULL_STOP).replace(dynlistConstants.CHAR_DOUBLE_UNDERSCORE_R,dynlistConstants.CHAR_DOUBLE_UNDERSCORE_C):valueFieldName.substringBefore(dynlistConstants.CHAR_FULL_STOP);
                                String relatedObjName = valueFieldName.substringBefore(dynlistConstants.CHAR_FULL_STOP);
                                if(relationvalueFieldName.endsWith(dynlistConstants.CHAR_DOUBLE_UNDERSCORE_C)) 
                                {
                                    relatedObjName = String.valueOf(objMap.get(lookupSobjectName.toLowerCase()).getDescribe().fields.getMap().get(relationvalueFieldName.toLowerCase()).getDescribe().getReferenceTo()[0]);
                                }
                                addFieldsMap(objMap,objFieldsMap,relatedObjName);
                                if(!sobjectLookupFilter.fieldsDataType.containsKey(filter.valueField)) 
                                {
                                    sobjectLookupFilter.fieldsDataType.put(filter.valueField, objFieldsMap.get(relatedObjName.toLowerCase()).get(valueFieldName.substringAfter(dynlistConstants.CHAR_FULL_STOP).toLowerCase()).getDescribe().getType());
                                }
                            }
                            else 
                            {
                                addFieldsMap(objMap,objFieldsMap,filter.valueField.substringBefore(dynlistConstants.CHAR_FULL_STOP));
                                if(!sobjectLookupFilter.fieldsDataType.containsKey(filter.valueField)) 
                                {
                                    sobjectLookupFilter.fieldsDataType.put(filter.valueField, objFieldsMap.get(filter.valueField.substringBefore(dynlistConstants.CHAR_FULL_STOP).toLowerCase()).get(valueFieldName.toLowerCase()).getDescribe().getType());
                                }
                            }
                        }  
                    }
                    if(isFound) 
                    {
                        break;
                    }
                }
            }
            
            //recordId --> 0065g00000FPwz4AAD (opp Id)
            if(sobjectLookupFilter.currentFieldNotOnUI.size() > 0 && String.isNotBlank(sobjectLookupFilter.sourceObjectName) && String.isNotBlank(recordId)) 
            {
                dynlistSOQLBuilder currentRecordBuilder = dynlistSOQLBuilder.create()
                    .addSelect(new List<String>(sobjectLookupFilter.currentFieldNotOnUI))
                    .addFrom(sobjectLookupFilter.sourceObjectName);
                currentRecordBuilder.addWhere(dynlistSOQLBuilder.eq(dynlistConstants.ID_FIELD_NAME, recordId));
                
                List<Sobject> results = Database.query(currentRecordBuilder.toQuery());
                if(results != null && results.size() == 1) 
                {
                    sobjectLookupFilter.currentFieldNotOnUIData.add(results[0]);
                }
            }
            if(userFieldsMapping.size() > 0) 
            {
                dynlistSOQLBuilder builder = dynlistSOQLBuilder.create()
                    .addSelect(new List<String>(userFieldsMapping.keySet()))
                    .addFrom(dynlistConstants.CHAR_USER);
                builder.addWhere(dynlistSOQLBuilder.eq(dynlistConstants.ID_FIELD_NAME, UserInfo.getUserId()));
                List<Sobject> results = Database.query(builder.toQuery());
                if(results != null && results.size() == 1) 
                {
                    for(String str : userFieldsMapping.keySet()) 
                    {
                        String fieldName = userFieldsMapping.get(str);
                        if(fieldName.indexOf(dynlistConstants.CHAR_DOLLOR_USER_ROLE) != -1) 
                        {
                            sobjectLookupFilter.userFieldsData.put(fieldName,results[0].getSobject(dynlistConstants.CHAR_USER_ROLE) != null?String.valueOf(results[0].getSobject(dynlistConstants.CHAR_USER_ROLE).get(str.substringAfter(dynlistConstants.CHAR_FULL_STOP))):null);
                        }
                        else if(fieldName.indexOf(dynlistConstants.CHAR_DOLLOR_PROFILE) != -1) 
                        {
                            sobjectLookupFilter.userFieldsData.put(fieldName,results[0].getSobject(dynlistConstants.CHAR_PROFILE) != null?String.valueOf(results[0].getSobject(dynlistConstants.CHAR_PROFILE).get(str.substringAfter(dynlistConstants.CHAR_FULL_STOP))):null);
                        }
                        else
                        {
                            sobjectLookupFilter.userFieldsData.put(fieldName,String.valueOf(results[0].get(str)));
                        }
                    }
                }
            }
            return JSON.serialize(sobjectLookupFilter);
        }
        catch(Exception e) 
        {
            System.debug('@@Exception:::'+e.getMessage()+'StackTraceString:::'+e.getStackTraceString());
            return null;
        }
    }
    
    /**
    *  Method to type-cast values on the basis of fieldType.
    *  It sends updated Object type of value to addFilterWhereClause method.
    *  @param  builder  dynlistSOQLBuilder.class instance with already added simple query(like [Select Id from Account]).
    *  @param  operation dynlistLookupFilterUtils.FilterItem.operation value holding restrictions to compare two values or to add condition in dynlistSOQLBuilder instance.
    *  @param  column Field's API name to add in dynlistSOQLBuilder instance or holds value for comparison(In case of isCompare:true).
    *  @param  value Holding value to add condition to dynlistSOQLBuilder or holds value for comparison(In case of isCompare:true).
    *  @param  fieldType Holds Schema.DisplayType of column attribute.
    *  @param  isCompare If True: compare two values in column and value attributes and False: to add column and value directly to dynlistSOQLBuilder instance.
    */
    @TestVisible
    private static void addFilterWhereClauseByType(dynlistSOQLBuilder builder, String operation, String column, String value, Schema.DisplayType fieldType, Boolean isCompare, String objectName, String fieldName, String filterFieldName) 
    {
        if(String.isNotBlank(filterFieldName)) 
        {
            if(dynlistConstants.PICKLIST_SELECTABLE_FIELDS.contains(filterFieldName.trim())) 
            {
            	fieldType = Schema.DisplayType.Picklist;    
            }    
        }
        
        if(String.isNotBlank(value) && value.equalsIgnoreCase(dynlistConstants.CHAR_NULL_LOWERCASE)) 
        {
            value = null;
        }
        if (Schema.DisplayType.Currency==fieldType || Schema.DisplayType.Double==fieldType) 
        {
            if(isCompare) 
            {
                Boolean result = compareDoubleValues(operation, String.isNotBlank(column)?Double.valueOf(column):null, String.isNotBlank(value)?Double.valueOf(value):null);
                addIdFilter(builder, result);
            }
            else 
            {
                addFilterWhereClause(builder, operation, column,String.isNotBlank(value)?Double.valueOf(value):null, objectName);
            }
        }
        else if 
        (
            Schema.DisplayType.Picklist == fieldType 
            ||
            (
				String.isNotBlank(column) && column.trim().equalsIgnoreCase(dynlistConstants.RECORD_TYPE_ID_FIELD_NAME)
            )
        )
        {
            //Special handling for the case of record types
            if(String.isNotBlank(column)) 
            {
                if(String.isNotBlank(value)) 
                {
                    if(value.trim().split(dynlistConstants.CHAR_COMMA).size() > 1) 
                    {
                        String updatedValue = dynlistConstants.CHAR_BLANK_STRING;
                        
                        //get record type ID by record type label, if provided values is not a valid ID value
                        for(String val : value.trim().split(dynlistConstants.CHAR_COMMA)) 
                        {
                    		if(!dynlistUtilities.isaValidateSalesforceID(val)) 
                            {
                                if(column.trim().equalsIgnoreCase(dynlistConstants.RECORD_TYPE_ID_FIELD_NAME)) 
                                {
                                	updatedValue += dynlistUtilities.getRecordTypeIdForObject(objectName, val.trim()) + dynlistConstants.CHAR_COMMA;    
                                }
                                else 
                                {
                                    updatedValue += val.trim() + dynlistConstants.CHAR_COMMA;
                                }
                            }
                            else 
                            {
                            	updatedValue += val.trim() + dynlistConstants.CHAR_COMMA;
                            }
                        }
                        updatedValue = updatedValue.removeEnd(dynlistConstants.CHAR_COMMA);
                        value = updatedValue;
                    }
                    else 
                    {
                        //get record type ID by record type label, if provided values is not a valid ID value
                        if(!dynlistUtilities.isaValidateSalesforceID(value)) 
                        {
                            if(column.trim().equalsIgnoreCase(dynlistConstants.RECORD_TYPE_ID_FIELD_NAME)) 
                            {
                            	value = dynlistUtilities.getRecordTypeIdForObject(objectName, value.trim());    
                            }
                            else 
                            {
                                value = value.trim();
                            }
                        }
                        else 
                        {
                        	value = value.trim();   
                        }
                    }
                }
            }
            
            if(isCompare) 
            {
                Boolean result = compareStringValues(operation, column, value, fieldType, fieldName);
                addIdFilter(builder, result);
            }
            //Handling picklist specially because it holds multiple values in comparison
            else if(operation == dynlistConstants.CHAR_NOT_EQUALS && String.isNotBlank(value)) 
            {
                builder.addWhere(dynlistSOQLBuilder.valueNotIn(column, value.split(dynlistConstants.CHAR_COMMA)));
            }
            else if(operation == dynlistConstants.CHAR_EQUALS && String.isNotBlank(value)) 
            {
                builder.addWhere(dynlistSOQLBuilder.valueIn(column, value.split(dynlistConstants.CHAR_COMMA)));
            }
            else 
            {
                addFilterWhereClause(builder, operation, column,value, objectName);
            }
        }
        else if (Schema.DisplayType.Integer==fieldType) 
        {
            if(isCompare) 
            {
                Boolean result = compareDoubleValues(operation, String.isNotBlank(column)?Double.valueOf(column):null, String.isNotBlank(value)?Double.valueOf(value):null);
                addIdFilter(builder, result);
            }
            else 
            {
                addFilterWhereClause(builder, operation, column,String.isNotBlank(value)?Integer.valueOf(value):null, objectName);
            }
        } 
        else if (Schema.DisplayType.Date==fieldType) 
        {
            Date d = null;
            if(String.isNotBlank(value)) 
            {
                try 
                {
                    if (value.contains(dynlistConstants.CHAR_Z)) 
                    {
                        DateTime dt = dynlistUtilities.isoTime2DateTime(value);
                        d = dt.date();
                    } 
                    else 
                    {
                        d = Date.parse(value);
                    }
                }
                catch(Exception e) 
                {
                    if (!value.contains(dynlistConstants.CHAR_COLON)) 
                    {
                        value += dynlistConstants.CHAR_BLANK_SPACE + dynlistConstants.CHAR_ZERO_ZERO_TIME_STRING;
                    }
                    d = Date.valueOf(value);
                }
            }
            if(isCompare) 
            {
                Boolean result = compareDateValues(operation, String.isNotBlank(column)?Date.valueOf(column):null, d);
                addIdFilter(builder, result);
            }
            else 
            {
                addFilterWhereClause(builder, operation, column,d,objectName);
            }
        } 
        else if (Schema.DisplayType.DateTime==fieldType) 
        {
            DateTime dt = null;
            if(String.isNotBlank(value)) 
            {
                try 
                {
                    if (value.contains(dynlistConstants.CHAR_Z)) 
                    {
                        dt = dynlistUtilities.isoTime2DateTime(value);
                    } 
                    else 
                    {
                        dt = DateTime.parse(value);
                    }
                }
                catch(Exception e) 
                {
                    dt = DateTime.valueOf(value);
                }
            }
            if(isCompare) 
            {
                Boolean result = compareDateTimeValues(operation, String.isNotBlank(column)?DateTime.valueOf(column):null, dt);
                addIdFilter(builder, result);
            }
            else 
            {
                addFilterWhereClause(builder, operation, column,dt, objectName);
            }
        } 
        else if (Schema.DisplayType.Reference==fieldType) 
        {
            if(isCompare) 
            {
                Boolean result = compareReferenceValues(operation, String.isNotBlank(column)?column:null, String.isNotBlank(value)?value:null);
                addIdFilter(builder, result);
            }
            else 
            {
                addFilterWhereClause(builder, operation, column,String.isNotBlank(value)?value:null,objectName);
            }
        } 
        else if (Schema.DisplayType.Boolean==fieldType) 
        {
            if(isCompare) 
            {
                Boolean result = compareStringValues(operation, column, value, fieldType, fieldName);
                addIdFilter(builder, result);
            }
            else 
            {
                addFilterWhereClause(builder, operation, column,Boolean.valueOf(value),objectName);
            }
        }
        else
        {
            if(isCompare) 
            {
                Boolean result = compareStringValues(operation, column, value, fieldType, fieldName);
                addIdFilter(builder, result);
            }
            else 
            {
                addFilterWhereClause(builder, operation, column,value,objectName);
            }
        }
    }
    
    /**
    *  Method to add  ID conditions in dynlistSOQLBuilder instance.
    *  It adds Id != null(if result True) and Id == null(if result False).
    *  @param  builder  dynlistSOQLBuilder.class instance.
    *  @param  result Boolean holding true or false.
    */
    @TestVisible
    private static void addIdFilter(dynlistSOQLBuilder builder, Boolean result) 
    {
        if(result != null && result == true) 
        {
            builder.addWhere(dynlistSOQLBuilder.ne(dynlistConstants.ID_FIELD_NAME, null));
        }
        else if(result != null && result == false) 
        {
            builder.addWhere(dynlistSOQLBuilder.eq(dynlistConstants.ID_FIELD_NAME, null));
        }
    }
    
    /**
    *  Method to add lookup filter conditions in dynlistSOQLBuilder instance.
    *  It adds conditions on the basis of operation.
    *  @param  builder  dynlistSOQLBuilder.class instance with already added simple query(like [Select Id from Account]).
    *  @param  operation dynlistLookupFilterUtils.FilterItem.operation value holding restrictions to compare two values or to add condition in dynlistSOQLBuilder instance.
    *  @param  column Field's API name to add in dynlistSOQLBuilder instance.
    *  @param  value Holding value to add condition to dynlistSOQLBuilder.
    *  @param  typeForSpecialHandling Attribute for dynlistSOQLBuilder to specially handle data and datatime.
    */
    @TestVisible
    private static void addFilterWhereClause(dynlistSOQLBuilder builder, String operation, String column, Object val, String objectName) 
    {
        if (operation == dynlistConstants.CHAR_EQUALS && String.isNotBlank(column)) 
        {
            builder.addWhere(dynlistSOQLBuilder.eq(column, val));
        }
        else if (operation == dynlistConstants.CHAR_NOT_EQUALS && String.isNotBlank(column)) 
        {
            builder.addWhere(dynlistSOQLBuilder.ne(column, val));
        }
        //Handling null values because null values can only be compared for equals and notEquals(Adding then as Id filter).
        else if(String.isBlank(String.valueOf(val))) 
        {
            if (operation == dynlistConstants.CHAR_GREATER_THAN || operation == dynlistConstants.CHAR_LESS_THAN 
                || operation == dynlistConstants.CHAR_CONTAINS || operation == dynlistConstants.CHAR_STARTS_WITH) 
            {
                addIdFilter(builder, true);
            }
            else if (operation == dynlistConstants.CHAR_GREATER_OR_EQUAL || operation == dynlistConstants.CHAR_NOT_CONTAIN 
                     || operation == dynlistConstants.CHAR_LESS_OR_EQUAL) 
            {
                addIdFilter(builder, false);
            }
        }
        else if (operation == dynlistConstants.CHAR_GREATER_THAN && String.isNotBlank(column)) 
        {
            builder.addWhere(dynlistSOQLBuilder.gt(column, val));
        }
        else if (operation == dynlistConstants.CHAR_GREATER_OR_EQUAL && String.isNotBlank(column)) 
        {
            builder.addWhere(dynlistSOQLBuilder.ge(column, val));
        }
        else if (operation == dynlistConstants.CHAR_LESS_THAN && String.isNotBlank(column)) 
        {
            builder.addWhere(dynlistSOQLBuilder.lt(column, val));
        }
        else if (operation == dynlistConstants.CHAR_LESS_OR_EQUAL && String.isNotBlank(column)) 
        {
            builder.addWhere(dynlistSOQLBuilder.le(column, val));
        }
        else if (operation == dynlistConstants.CHAR_CONTAINS && String.isNotBlank(column)) 
        {
            builder.addWhere(dynlistSOQLBuilder.valueLike(column, '%'+val+'%'));
        }
        else if (operation == dynlistConstants.CHAR_NOT_CONTAIN && String.isNotBlank(column)) 
        {
            builder.addWhere(dynlistSOQLBuilder.valueNotLike(column, '%'+val+'%'));
        }
        else if(operation == dynlistConstants.CHAR_STARTS_WITH && String.isNotBlank(column)) 
        {
            builder.addWhere(dynlistSOQLBuilder.valueLike(column, val+'%'));
        }
    }
    
    /**
    *  Method to compare two double values and used only possible operations for double.
    *  @param  operation dynlistLookupFilterUtils.FilterItem.operation value holding restrictions to compare two values.
    *  @param  value1 First value to compare.
    *  @param  value2 Second value to compare with.
    */
    @TestVisible
    private static Boolean compareDoubleValues(String operation, Double value1, Double value2) 
    {
        if (operation == dynlistConstants.CHAR_EQUALS) 
        {
            return value1 == value2;
        }
        else if (operation == dynlistConstants.CHAR_NOT_EQUALS) 
        {
            return value1 != value2;
        }
        //Handling null values because null values can only be compared for equals and notEquals(Adding Id filter using compareNullvalues method).
        else if(String.isBlank(String.valueOf(value1)) || String.isBlank(String.valueOf(value2))) 
        {
            return compareNullvalues(operation);
        }
        else if (operation == dynlistConstants.CHAR_GREATER_THAN) 
        {
            return value1 > value2;
        }
        else if (operation == dynlistConstants.CHAR_GREATER_OR_EQUAL) 
        {
            return value1 >= value2;
        }
        else if (operation == dynlistConstants.CHAR_LESS_THAN) 
        {
            return value1 < value2;
        }
        else if (operation == dynlistConstants.CHAR_LESS_OR_EQUAL) 
        {
            return value1 <= value2;
        }
        return true;
    }
    
    /**
    *  Method to compare two date values and used only possible operations for date.
    *  @param  operation dynlistLookupFilterUtils.FilterItem.operation value holding restrictions to compare two values.
    *  @param  date1 First value to compare.
    *  @param  date2 Second value to compare with.
    */
    @TestVisible
    private static Boolean compareDateValues(String operation, Date date1, Date date2) 
    {
        if (operation == dynlistConstants.CHAR_EQUALS) 
        {
            return date1 == date2;
        }
        else if (operation == dynlistConstants.CHAR_NOT_EQUALS) 
        {
            return date1 != date2;
        }
        else if(String.isBlank(String.valueOf(date1)) || String.isBlank(String.valueOf(date2))) 
        {
            return compareNullvalues(operation);
        }
        else if (operation == dynlistConstants.CHAR_GREATER_THAN) 
        {
            return date1 > date2;
        }
        else if (operation == dynlistConstants.CHAR_GREATER_OR_EQUAL) 
        {
            return date1 >= date2;
        }
        else if (operation == dynlistConstants.CHAR_LESS_THAN) 
        {
            return date1 < date2;
        }
        else if (operation == dynlistConstants.CHAR_LESS_OR_EQUAL) 
        {
            return date1 <= date2;
        }
        return true;
    }
    
    /**
    *  Method to compare two datetime values and used only possible operations for datetime.
    *  @param  operation dynlistLookupFilterUtils.FilterItem.operation value holding restrictions to compare two values.
    *  @param  dateTime1 First value to compare.
    *  @param  dateTime2 Second value to compare with.
    */
    @TestVisible
    private static Boolean compareDateTimeValues(String operation, DateTime dateTime1, DateTime dateTime2) 
    {
        if (operation == dynlistConstants.CHAR_EQUALS) 
        {
            return dateTime1 == dateTime2;
        }
        else if (operation == dynlistConstants.CHAR_NOT_EQUALS) 
        {
            return dateTime1 != dateTime2;
        }
        else if(String.isBlank(String.valueOf(dateTime1)) || String.isBlank(String.valueOf(dateTime2))) 
        {
            return compareNullvalues(operation);
        }
        else if (operation == dynlistConstants.CHAR_GREATER_THAN) 
        {
            return dateTime1 > dateTime2;
        }
        else if (operation == dynlistConstants.CHAR_GREATER_OR_EQUAL) 
        {
            return dateTime1 >= dateTime2;
        }
        else if (operation == dynlistConstants.CHAR_LESS_THAN) 
        {
            return dateTime1 < dateTime2;
        }
        else if (operation == dynlistConstants.CHAR_LESS_OR_EQUAL) 
        {
            return dateTime1 <= dateTime2;
        }
        return true;
    }
    
    /**
    *  Method to compare two Id values and used only possible operations for Id.
    *  @param  operation dynlistLookupFilterUtils.FilterItem.operation value holding restrictions to compare two values.
    *  @param  id1 First value to compare.
    *  @param  id2 Second value to compare with.
    */
    @TestVisible
    private static Boolean compareReferenceValues(String operation, String id1, String id2) 
    {
        if(String.isBlank(id1) || String.isBlank(id2)) 
        {
            return compareNullvalues(operation);
        }
        else if (operation == dynlistConstants.CHAR_EQUALS) 
        {
            if(id1 instanceOf Id && id2 instanceOf Id) 
            {
                return Id.valueOf(id1) == Id.valueOf(id2);
            }
            return false;
        }
        else if (operation == dynlistConstants.CHAR_NOT_EQUALS) 
        {
            if(id1 instanceOf Id && id2 instanceOf Id) 
            {
                return Id.valueOf(id1) != Id.valueOf(id2);
            }
            return false;
        }
        else if (operation == dynlistConstants.CHAR_STARTS_WITH) 
        {
            return id1.startsWith(id2);
        }
        return true;
    }
    
    /**
    *  Method to compare two String values and used only possible operations for String.
    *  @param  operation dynlistLookupFilterUtils.FilterItem.operation value holding restrictions to compare two values.
    *  @param  str1 First value to compare.
    *  @param  str2 Second value to compare with.
    */
    @TestVisible
    private static Boolean compareStringValues(String operation, String str1, String str2, Schema.DisplayType fieldType, String fieldName) 
    {
        Boolean result = false;        
        if(Schema.DisplayType.Picklist == fieldType) 
        {
            if(operation == dynlistConstants.CHAR_EQUALS 
               || operation == dynlistConstants.CHAR_NOT_EQUALS) 
            {
                return dynlistUtilities.isSelectedValuesContainsThisValue(str2, str1, fieldName, operation); 
            }
        } 
        
        else if (operation == dynlistConstants.CHAR_EQUALS) 
        {
            return str1 == str2;
        }
        else if (operation == dynlistConstants.CHAR_NOT_EQUALS) 
        {
            return str1 != str2;
        }
        else if(String.isBlank(String.valueOf(str1)) || String.isBlank(String.valueOf(str2))) 
        {
            return compareNullvalues(operation);
        }
        else if (operation == dynlistConstants.CHAR_STARTS_WITH) 
        {
            return str1.startsWith(str2);
        }
        else if (operation == dynlistConstants.CHAR_CONTAINS) 
        {
            return str1.contains(str2);
        }
        else if (operation == dynlistConstants.CHAR_NOT_CONTAIN) 
        {
            return !str1.contains(str2);
        }
        return true;
    }
    
    /**
    *  Method to return True for some operations and false for rest (skipping equal and notEquals, they are compared even if null values).
    *  @param  operation LookupFilterUtils.FilterItem.operation value holding restrictions to compare two values.
    */
    @TestVisible
    private static Boolean compareNullvalues(String operation) 
    {
        if (operation == dynlistConstants.CHAR_GREATER_THAN || operation == dynlistConstants.CHAR_LESS_THAN 
            || operation == dynlistConstants.CHAR_CONTAINS || operation == dynlistConstants.CHAR_STARTS_WITH) 
        {
            return true;
        }
        else 
        {
            return false;
        }
    }
    
    /**
    *  Method to fetch fields updated data from UI(if on UI) or data from database passed in attributes.
    *  @param  currentFieldOnUI Set holding all field's API name on UI(FieldSet).
    *  @param  currentFieldNotOnUIData Set holding all fields API name not on UI and are in used in filter.
    *  @param  uiRecordFieldsMap Map of Key Field API name and value Field.class instance, holding all fields detail on UI(fieldSet).
    *  @param  field API name of field to return value for.
    *  @return String value of field.
    */
    private static String getSourceFieldValue(Set<String> currentFieldOnUI, Map<String, Object> currentFieldNotOnUIData, Map<String,dynlistField> uiRecordFieldsMap, String field) 
    {
        String value;
        
        if(currentFieldOnUI.contains(field) && uiRecordFieldsMap.containsKey(field)) 
        {
            value = uiRecordFieldsMap.get(field).value;
        }
        else if(currentFieldNotOnUIData.containsKey(field)) 
        {
            value = String.valueOf(currentFieldNotOnUIData.get(field));
        }
        return value;
    }
    
    /**
    *  Method to fetch fields updated data from UI(if on UI) or data from database passed in attributes.
    *  @param  uiRecordFieldsMap List of Field.class instance, holding all fields detail on UI(fieldSet).
    *  @return Map of Key Field API name and value Field.class instance, holding all fields detail on UI(fieldSet).
    */
    private static Map<String,dynlistField> getUIRecordInstance(List<dynlistField> uiRecordFields) 
    {
        Map<String,dynlistField> uiRecordFieldsMap = new Map<String,dynlistField>();
        for(dynlistField recordField : uiRecordFields)
        {
            uiRecordFieldsMap.put(recordField.name , recordField);
        }
        return uiRecordFieldsMap;
    }
    
    /**
    *  Method to add describe result of object in existing map if not exist.
    *  @param  objMap Instance of GlobalDescribe of Objects.
    *  @param  objFieldsMap Map of Map objects API Name their SobjectField detail.
    *  @param  objName Object's API name to make describe call on.
    */
    private static void addFieldsMap(Map<String, Schema.SObjectType> objMap, Map<String, Map<String, Schema.SObjectField>> objFieldsMap, String objName) 
    {
        if(String.isNotBlank(objName) && !objFieldsMap.containsKey(objName.toLowerCase())) 
        {
            if(objMap.get(objName.toLowerCase()) != null && objMap.get(objName.toLowerCase()).getDescribe() != null) 
            {
                objFieldsMap.put(objName.toLowerCase(), objMap.get(objName.toLowerCase()).getDescribe().fields.getMap());        
            }
        }
    }
    
    /**
    *  Method to convert boolean logic for filter to compatible for dynlistSOQLBuilder setConditionLogic method.
    *  @param  booleanFilter holds filter string as ('((1 OR 2 OR 3) AND 4)'), it should hold maximum 10 values.
    *  @return converted condition logic as ((({A} OR {B} OR {C}) AND {D})).
    */
    private static String convertBooleanFilter(String booleanFilter) 
    {
        if(String.isNotBlank(booleanFilter))
        {
            if(booleanFilter.contains(dynlistConstants.CHAR_TEN)) 
            {
                booleanFilter = booleanFilter.replace(dynlistConstants.CHAR_TEN, dynlistConstants.REGEX_LOOKYP_FILTERS);
            }
            String[] filterChars = booleanFilter.split(dynlistConstants.CHAR_BLANK_STRING);
            for(String str : filterChars) 
            {
                if(dynlistConstants.BOOLEAN_FILTER_MAPPING.containsKey(str)) 
                {
                    booleanFilter = booleanFilter.replace(str, dynlistConstants.BOOLEAN_FILTER_MAPPING.get(str));
                }
            }
        }
        return booleanFilter;
    }
    
    /**
    * SobjectLookupFilter class representing all required data for a lookup field's filter to parse futher.
    */
    public class SobjectLookupFilter 
    {
        public String sourceObjectName {get;set;}
        public String sourceFieldName {get;set;}
        public String targetObjectName {get;set;}
        public Set<String> currentFieldOnUI {get;set;}
        public Set<String> currentFieldNotOnUI {get;set;}
        public Metadata filterMetadata {get;set;}
        public Map<String,String> userFieldsData {get;set;}
        public List<sObject> currentFieldNotOnUIData {get;set;}
        public Map<String, Schema.DisplayType> fieldsDataType {get;set;}
        public SobjectLookupFilter() 
        {
            this.currentFieldOnUI = new Set<String>();
            this.userFieldsData = new Map<String,String>();
            this.currentFieldNotOnUI = new Set<String>();
            this.currentFieldNotOnUIData = new List<sObject>();
            this.fieldsDataType = new Map<String, Schema.DisplayType>();
        }
        public void addCurrentFieldOnUI(String fieldName) 
        {
            this.currentFieldOnUI.add(fieldName);
        }
        public void addFilterMetadata(Metadata filterMetadata) 
        {
            this.filterMetadata = filterMetadata;
        }
        public void addCurrentFieldNotOnUI(String fieldName) 
        {
            this.currentFieldNotOnUI.add(fieldName);
        }
    }
    
    /**
    * LookupFilter,Record,SourceFieldDefinition,TargetEntityDefinition,Metadata,FilterItem class 
    * representing instance to holde lookup filters as fetched from tooling API.
    */
    public class LookupFilter 
    {
        public Record[] records {get;set;}
    }
    public class Record 
    {
        public SourceFieldDefinition SourceFieldDefinition {get;set;}
        public TargetEntityDefinition TargetEntityDefinition {get;set;}
        public Metadata Metadata {get;set;}
        public String DeveloperName {get;set;}
    }
    public class SourceFieldDefinition 
    {
        public String FullName {get;set;}
    }
    public class TargetEntityDefinition 
    {
        public String FullName {get;set;}
    }
    public class Metadata 
    {
        public Boolean active {get;set;}
        public String booleanFilter{get;set{
            booleanFilter = convertBooleanFilter(value);
        }}
        public String description {get;set;}
        public String errorMessage {get;set;}
        public FilterItem[] filterItems {get;set;}
        public String infoMessage {get;set;}
        public Boolean isOptional {get;set;}
    }
    public class FilterItem 
    {
        public String field {get;set;}
        public String operation {get;set;}
        public String value {get;set;}
        public String valueField {get;set;}
    }
}