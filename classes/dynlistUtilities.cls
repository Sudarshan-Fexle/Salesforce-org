/*
Purpose         :   Custom Related List Utilities (Dynamic Related List)
Created By      :   Abhinav Sharma
Created Date    :   07/24/2021
Current Version :   v1.0
Revision Log    :   V_1.0 Created - Abhinav Sharma - 07/24/2021
*/
public without sharing class dynlistUtilities 
{    
    private static String pkgPrefix = null;
    
    //Objects not having name field on them
    public static Set<String> setOfObjectForNameFieldNotAvailable = dynlistUtilities.setOfObjectsAPINameNotHavingNameField();
    public static Map<String, String> mapOfObjectAPINameWithSynonymField = dynlistUtilities.mapOfObjectsAPINameWithSynonymField();
    
    public static final String DYNLIST_ORG_HOST_URL = dynlistUtilities.getSfOrgBaseURL() + dynlistConstants.CHAR_BACK_SLASH;
    public static final String DYNLIST_RECORD_TYPE_HOST_URL = dynlistUtilities.getSfOrgBaseURL() + System.Label.DYNLIST_RECORD_TYPE_URL_PATH;
    
    //Flag to bypass the triggers
    public static Boolean BypassAllTriggers = false;
    
    public static String getPackagePrefix() 
    {
        if (pkgPrefix == null) 
        {
            List<ApexClass> nameSpaceClasses = [SELECT NamespacePrefix FROM ApexClass 
                                                WHERE Name =: System.Label.DYNLIST_NAMESPACE_PREFIX_CLASS_NAME];
            if(nameSpaceClasses.size() > 0) 
            {
                pkgPrefix = nameSpaceClasses[0].NamespacePrefix;
            }
            else 
            {
                pkgPrefix = null;
            }
        }
        return pkgPrefix;
    }
    
    //Method to get the SFDC Instance base URL
    public static String getSfOrgBaseURL()
    {
        return System.URL.getSalesforceBaseUrl().toExternalForm();
    }
    
    //Method to get the SFDC Instance host URL
    public static String getSfInstance()
    {
        return System.URL.getSalesforceBaseUrl().getHost().remove('-api');
    }
    
    private static Boolean isThisASandbox = null;
    public static Boolean isSandbox() 
    {
        if (isThisASandbox == null) 
        {
            Organization currOrg = [Select IsSandbox, InstanceName from Organization where Id = :UserInfo.getOrganizationId() limit 1];
            isThisASandbox = currOrg.IsSandbox;
            mySalesforceInstance = currOrg.InstanceName;
        }
        return isThisASandbox;
    }
    
    private static String mySalesforceInstance = null;
    public static String getMySalesforceInstance()
    {
        if (String.isBlank(mySalesforceInstance)) 
        {
            Organization currOrg = [Select IsSandbox, InstanceName from Organization where Id = :UserInfo.getOrganizationId() limit 1];
            isThisASandbox = currOrg.IsSandbox;
            mySalesforceInstance = currOrg.InstanceName;
        }
        return mySalesforceInstance;
    }
    
    //Field Set Utilities
    public static dynlistQueryWrapper getFieldsetQuery(
        String objectName,
        Schema.FieldSetMember[] fieldSet,
        List<String> mandatoryFields,
        String whereClause,
        String orderBy,
        String queryLimit,
        Boolean convertFieldPaths,
        Boolean addPrefix,
        Boolean enableWithSecurityEnforced,
        String offset,
        String sOQLSelectFieldsString,
        String nullFirstOrLastString,
        List<String> additionalFields,
        Map<String, String> mapOfNonQueryableFields
    ) 
    {
        dynlistQueryWrapper datalistQuery = new dynlistQueryWrapper();
        Set<String> fieldsAlreadyInQuery = new Set<String>();
        
        String query = dynlistConstants.SOQL_STRING_REQUIRED_PREFIX;
        String queryTempString = dynlistConstants.CHAR_BLANK_STRING;
        Boolean isAllFieldsInAccessible = true;
        Boolean objectNotHavingNameField = false;
        
        if(pkgPrefix == null)
        {
            pkgPrefix = dynlistUtilities.getPackagePrefix();
        }
        
        //Checking if this is object which is not having name field available on it
        if(String.isNotBlank(objectName)) 
        {
            if(setOfObjectForNameFieldNotAvailable.contains(objectName.toLowerCase())) 
            {
                objectNotHavingNameField = true;    
            }    
        }
        
        //Processing mandatory fields
        if(mandatoryFields != null) 
        {
            for (String field : mandatoryFields) 
            {
                if(field != null) 
                {
                    field = field.trim().toLowerCase();
                    
                    if (
                        String.isNotBlank(pkgPrefix) &&
                        field.endswith(dynlistConstants.CHAR_DOUBLE_UNDERSCORE_C) &&
                        !field.startsWith(pkgPrefix) &&
                        addPrefix
                    ) 
                    {
                        field = pkgPrefix + field;
                    }
                    
                    if(dynlistUtilities.getFieldIsAccessible(objectName, field) || enableWithSecurityEnforced) 
                    {
                        queryTempString += field + dynlistConstants.CHAR_COMMA;
                        fieldsAlreadyInQuery.add(field);
                    }
                }
            }    
        }
        
        //Processing SOQL String fields
        if (String.isNotBlank(sOQLSelectFieldsString)) 
        {
            //If we have more than one field mentioned in the comma seperated fashion
            if(sOQLSelectFieldsString.trim().split(dynlistConstants.CHAR_COMMA).size() > 0) 
            {
                for (String fieldName : sOQLSelectFieldsString.trim().split(dynlistConstants.CHAR_COMMA)) 
                {
                    if(fieldName != null) 
                    {
                        fieldName = fieldName.trim().toLowerCase();
                        
                        if (
                            String.isNotBlank(pkgPrefix) &&
                            fieldName.endswith(dynlistConstants.CHAR_DOUBLE_UNDERSCORE_C) &&
                            !fieldName.startsWith(pkgPrefix) &&
                            addPrefix
                        ) 
                        {
                            fieldName = pkgPrefix + fieldName;
                        }
                        
                        if(!fieldsAlreadyInQuery.contains(fieldName) && 
                           (
                               dynlistUtilities.getFieldIsAccessible(objectName, fieldName)
                               ||
                               enableWithSecurityEnforced
                           )) 
                        {
                            queryTempString += fieldName + dynlistConstants.CHAR_COMMA;
                            fieldsAlreadyInQuery.add(fieldName);
                            isAllFieldsInAccessible = false;
                        }
                    }
                }  
            }
            //If only one field is mentioned
            else 
            {
                sOQLSelectFieldsString = sOQLSelectFieldsString.trim().toLowerCase();
                
                if (
                    String.isNotBlank(pkgPrefix) &&
                    sOQLSelectFieldsString.endswith(dynlistConstants.CHAR_DOUBLE_UNDERSCORE_C) &&
                    !sOQLSelectFieldsString.startsWith(pkgPrefix) &&
                    addPrefix
                ) 
                {
                    sOQLSelectFieldsString = pkgPrefix + sOQLSelectFieldsString;
                }
                
                if(!fieldsAlreadyInQuery.contains(sOQLSelectFieldsString) && 
                   (
                       dynlistUtilities.getFieldIsAccessible(objectName, sOQLSelectFieldsString)
                       ||
                       enableWithSecurityEnforced
                   )) 
                {
                    queryTempString += sOQLSelectFieldsString +  dynlistConstants.CHAR_COMMA;
                    fieldsAlreadyInQuery.add(sOQLSelectFieldsString);
                    isAllFieldsInAccessible = false;
                }
            }
        }
        //Processing Field Set Fields
        else 
        {
            if (fieldSet != null) 
            {
                for (Schema.FieldSetMember fieldsetMember : fieldSet) 
                {
                    String field = fieldsetMember.getFieldPath().toLowerCase();
                    
                    if (!fieldsAlreadyInQuery.contains(field) 
                        && 
                        (
                            dynlistUtilities.getFieldIsAccessible(objectName, field)
                            ||
                            enableWithSecurityEnforced
                        )        
                       ) 
                    {
                        queryTempString += field + dynlistConstants.CHAR_COMMA;
                        fieldsAlreadyInQuery.add(field);
                        isAllFieldsInAccessible = false;
                    }
                    
                    // Add the converted fieldPath (instead of replacing it)
                    if (convertFieldPaths) 
                    {
                        String convertedField = getConvertedFieldPath(fieldsetMember, objectName).toLowerCase();
                        if (convertedField != field) 
                        {
                            if (!fieldsAlreadyInQuery.contains(convertedField)) 
                            {
                                queryTempString += convertedField + dynlistConstants.CHAR_COMMA;
                                fieldsAlreadyInQuery.add(convertedField);
                            }
                        }
                    }
                }
            }
        }
        
        //Adding additional fields to the SOQL Query string
        if(additionalFields != null && additionalFields.size() > 0) 
        {
            for(String fName : additionalFields) 
            {
                queryTempString += fName.trim().toLowerCase() + dynlistConstants.CHAR_COMMA;
                fieldsAlreadyInQuery.add(fName.trim().toLowerCase());
            }
            
            //Adding ID field
            queryTempString += dynlistConstants.ID_FIELD_API_NAME + dynlistConstants.CHAR_COMMA;
            fieldsAlreadyInQuery.add(dynlistConstants.ID_FIELD_API_NAME);
            
            //Adding name fields
            if(!objectNotHavingNameField) 
            {
                queryTempString += dynlistConstants.NAME_FIELD_NAME_LOWERCASE + dynlistConstants.CHAR_COMMA;
                fieldsAlreadyInQuery.add(dynlistConstants.NAME_FIELD_NAME_LOWERCASE);
            }
            else 
            {
                String synonymFieldName = dynlistConstants.CHAR_BLANK_STRING;
                if(mapOfObjectAPINameWithSynonymField != null) 
                {
                    if(
                        String.isNotBlank(objectName)
                        && mapOfObjectAPINameWithSynonymField != null 
                        && mapOfObjectAPINameWithSynonymField.get(objectName.toLowerCase()) != null
                    ) 
                    {
                        synonymFieldName = mapOfObjectAPINameWithSynonymField.get(objectName.toLowerCase());
                        queryTempString += synonymFieldName + dynlistConstants.CHAR_COMMA;
                        fieldsAlreadyInQuery.add(synonymFieldName);
                    }
                }    
            }
        }
        
        //Eliminating Duplicate field names (if any)
        String processedSOQLQuery = dynlistConstants.CHAR_BLANK_STRING;
        Set<String> setOfUniqueFieldsName = new Set<String>();
        
        if(String.isNotBlank(queryTempString) && queryTempString.trim().split(dynlistConstants.CHAR_COMMA).size() > 0) 
        {
            for(String fieldNameStr : queryTempString.trim().split(dynlistConstants.CHAR_COMMA)) 
            {
                if(!setOfUniqueFieldsName.contains(fieldNameStr.trim().toLowerCase())) 
                {
                    processedSOQLQuery += fieldNameStr.trim().toLowerCase() + dynlistConstants.CHAR_COMMA;
                    setOfUniqueFieldsName.add(fieldNameStr);
                }    
            }            
        }
        else 
        {
            processedSOQLQuery = queryTempString;    
        }
        
        Set<String> setOfNonQueryableFields = dynlistUtilities.getSetOfNonQueryableFields(mapOfNonQueryableFields, objectName, setOfUniqueFieldsName);
        if(setOfNonQueryableFields.size() > 0) 
        {
            String tempQueryString = dynlistConstants.CHAR_BLANK_STRING;
            for(String fName : processedSOQLQuery.trim().split(dynlistConstants.CHAR_COMMA)) 
            {
                if(!setOfNonQueryableFields.contains(fName)) 
                {
                    tempQueryString += fName.trim().toLowerCase() + dynlistConstants.CHAR_COMMA;
                }
            }
            if(String.isNotBlank(tempQueryString)) 
            {
                processedSOQLQuery = tempQueryString; 
            }
        }
        
        if(String.isNotBlank(processedSOQLQuery)) 
        {
            processedSOQLQuery = processedSOQLQuery.removeEnd(dynlistConstants.CHAR_COMMA);
            query += processedSOQLQuery;
        }
        
        query += dynlistConstants.CHAR_BLANK_SPACE + dynlistConstants.SOQL_STRING_FROM_KEYWORD + objectName;
        
        //populate selectQueryForInAccessibilityCheck porperty with select query string literal
        datalistQuery.selectQueryForInAccessibilityCheck = query + dynlistConstants.CHAR_BLANK_SPACE + dynlistConstants.CHAR_LIMIT 
            + dynlistConstants.CHAR_BLANK_SPACE + dynlistConstants.CHAR_ONE;
        
        if (String.isNotBlank(whereClause)) 
        {
            query += dynlistConstants.CHAR_BLANK_SPACE + whereClause;
        }
        
        if (enableWithSecurityEnforced) 
        {
            query +=
                dynlistConstants.CHAR_BLANK_SPACE +
                dynlistConstants.SOQL_STRING_WITH_SECURITY_ENFORCED_KEYWORD;
        }
        
        if (String.isNotBlank(orderBy)) 
        {
            query += dynlistConstants.CHAR_BLANK_SPACE + orderBy;
        }
        
        if (String.isNotBlank(nullFirstOrLastString)) 
        {
            query += dynlistConstants.CHAR_BLANK_SPACE + nullFirstOrLastString;
        }
        
        if (String.isNotBlank(queryLimit)) 
        {
            query += dynlistConstants.CHAR_BLANK_SPACE + queryLimit;
        }
        else 
        {
            query += dynlistConstants.CHAR_BLANK_SPACE +
                		dynlistConstants.CHAR_LIMIT +
                		dynlistConstants.CHAR_BLANK_SPACE +
                		':noOfMaxRowsAllowedToQuery ';
        }
        
        if (String.isNotBlank(offset)) 
        {
            query += dynlistConstants.CHAR_BLANK_SPACE + offset;
        }
        datalistQuery.queryString = query;
        datalistQuery.isAllFieldsInAccessible = isAllFieldsInAccessible; 
        datalistQuery.setOfNonQueryableFields = setOfNonQueryableFields;
        return datalistQuery;
    }
    
    public static String getConvertedFieldPath(Schema.FieldSetMember fsMember, String objectName) 
    {
        String parentObjectName = dynlistConstants.CHAR_BLANK_STRING;
        if(fsMember != null && fsMember.getType() != null && fsMember.getType() == Schema.DisplayType.Reference) 
        {
            if(fsMember.getFieldPath() != null) 
            {
                Schema.SObjectType sObjectTypeObj = dynlistUtilities.getObjectTypeOnBasisOfObjectName(objectName);
                if(sObjectTypeObj != null) 
                {
                    Map<String, Schema.SObjectField> fieldDescribes = sObjectTypeObj.getDescribe().fields.getMap();
                    if(fieldDescribes != null) 
                    {
                        if(fieldDescribes.get(fsMember.getFieldPath()) != null && fieldDescribes.get(fsMember.getFieldPath()).getDescribe() != null) 
                        {
                            parentObjectName = fieldDescribes.get(fsMember.getFieldPath()).getDescribe().getReferenceTo()[0].getDescribe().getName();     
                        }
                    }    
                }
            }
        }
        
        return getConvertedFieldPath(
            fsMember.getFieldPath(),
            String.valueOf(fsMember.getType()),
            objectName,
            parentObjectName
        );
    }
    
    public static String getConvertedFieldPath(
        String fieldPath,
        String fieldType,
        String objectName,
        String parentObjectName
    ) 
    {
        String fieldName = fieldPath;
        
        String synonymFieldName = dynlistConstants.CHAR_BLANK_STRING;
        if(mapOfObjectAPINameWithSynonymField != null) 
        {
            if(
                String.isNotBlank(parentObjectName)
                && mapOfObjectAPINameWithSynonymField != null 
                && mapOfObjectAPINameWithSynonymField.get(parentObjectName.toLowerCase()) != null
            ) 
            {
                synonymFieldName = mapOfObjectAPINameWithSynonymField.get(parentObjectName.toLowerCase());
            }
        }
        
        if (
            String.isNotBlank(fieldName) &&
            !dynlistConstants.SET_OF_SPECIAL_REFERENCE_FIELDS.contains(
                fieldName.trim().toLowerCase()
            )
        ) {
            if (fieldName == dynlistConstants.ID_FIELD_NAME) 
            {
                fieldName = dynlistConstants.ID_FIELD_NAME;
            } else if (fieldName.endsWithIgnoreCase(dynlistConstants.CHAR_FULL_STOP + dynlistConstants.ID_FIELD_NAME)) 
            {
                fieldName = fieldPath.left(fieldPath.length() - 2);
                if(String.isNotBlank(synonymFieldName)) 
                {
                    fieldName += synonymFieldName; 
                }
                else 
                {
                    fieldName += dynlistConstants.NAME_FIELD_NAME;
                }        
            } 
            else if (fieldPath.endsWithIgnoreCase(dynlistConstants.ID_FIELD_NAME)) 
            {
                fieldName = fieldPath.left(fieldPath.length() - 2) + dynlistConstants.CHAR_FULL_STOP;
                
                if(String.isNotBlank(synonymFieldName)) 
                {
                    fieldName += synonymFieldName; 
                }
                else 
                {
                    fieldName += dynlistConstants.NAME_FIELD_NAME;
                }
            } 
            else if (fieldType == dynlistConstants.DATA_TYPE_REFERENCE) 
            {
                if (fieldName.endsWithIgnoreCase(dynlistConstants.CHAR_DOUBLE_UNDERSCORE_C)) 
                {
                    fieldName = fieldName.removeEndIgnoreCase(dynlistConstants.CHAR_DOUBLE_UNDERSCORE_C) + dynlistConstants.CHAR_DOUBLE_UNDERSCORE_R + dynlistConstants.CHAR_FULL_STOP;
                    if(String.isNotBlank(synonymFieldName)) 
                    {
                        fieldName += synonymFieldName; 
                    }
                    else 
                    {
                        fieldName += dynlistConstants.NAME_FIELD_NAME;
                    }
                } 
                else 
                {
                    fieldName += dynlistConstants.CHAR_FULL_STOP;
                    if(String.isNotBlank(synonymFieldName)) 
                    {
                        fieldName += synonymFieldName; 
                    }
                    else 
                    {
                        fieldName += dynlistConstants.NAME_FIELD_NAME;
                    }
                }
            }
        }
        return fieldName;
    }
    
    private static Map<Id, String> recordTypeLabelCache;
    public static String getRecordTypeLabel(ID typeID) 
    {
        if (recordTypeLabelCache == null) 
        {
            recordTypeLabelCache = new Map<Id, String>();
        }
        String label = recordTypeLabelCache.get(typeID);
        if (label == null) 
        {
            List<RecordType> rt = [
                SELECT toLabel(name)
                FROM RecordType
                WHERE id = :typeID AND IsActive = true
            ];
            label = (rt.size() == 0) ? null : rt.get(0).name;
            recordTypeLabelCache.put(typeID, label);
        }
        return label;
    }
    
    public static Id getRecordTypeIdForObject(
        String objName,
        String recTypeName
    ) 
    {
        if (String.isEmpty(objName) || String.isEmpty(recTypeName))
            return null;
        return ((SObject) Type.forName(objName).newInstance())
            .getSObjectType()
            .getDescribe()
            .getRecordTypeInfosByName()
            .get(recTypeName)
            .getRecordTypeId();
    }
    
    public static Id getRecordTypeIdForObject(
        Schema.SObjectType objType,
        String recTypeName
    ) 
    {
        if (objType == null || String.isEmpty(recTypeName))
            return null;
        return objType.getDescribe()
            .getRecordTypeInfosByName()
            .get(recTypeName)
            .getRecordTypeId();
    }
    
    public static String getKeyPrefixForObject(String objName) 
    {
        if (objName == null || String.isEmpty(objName))
            return null;
        return ((SObject) Type.forName(objName).newInstance())
            .getSObjectType()
            .getDescribe()
            .getKeyPrefix();
    }
    
    public static String getKeyPrefixForObject(Schema.SObjectType objType) 
    {
        if (objType == null)
            return null;
        return objType.getDescribe().getKeyPrefix();
    }
    
    public static Schema.SObjectType getObjectTypeOnBasisOfIdValue(Id recordId) 
    {
        return recordId.getSobjectType();
    }
    
    public static Map<String, Schema.SObjectField> getFieldsMap(String objName) 
    {
        if (objName == null || String.isEmpty(objName)) 
        {
            return null;
        }
        Schema.DescribeSObjectResult objDescribe = dynlistUtilities.getObjectDescribeOnBasisOfObjectName(
            objName
        );
        if (objDescribe != null) 
        {
            return objDescribe.fields.getMap();
        }
        return null;
    }
    
    public static Schema.SObjectType getObjectTypeOnBasisOfObjectName(
        String objName
    ) 
    {
        if (objName == null || String.isEmpty(objName)) 
        {
            return null;
        }
        if (
            Type.forName(objName) != null &&
            ((SObject) Type.forName(objName).newInstance()) != null
        ) 
        {
            return ((SObject) Type.forName(objName).newInstance()).getSObjectType();
        }
        return null;
    }
    
    public static Schema.DescribeSObjectResult getObjectDescribeOnBasisOfObjectName(
        String objName
    ) 
    {
        if (objName == null || String.isEmpty(objName))
            return null;
        
        if (
            Type.forName(objName) != null &&
            ((SObject) Type.forName(objName).newInstance()) != null
        ) 
        {
            return ((SObject) Type.forName(objName).newInstance())
                .getSObjectType()
                .getDescribe();
        }
        return null;
    }
    
    public static SObject getObjectOnBasisOfObjectName(String objName) 
    {
        if (objName == null || String.isEmpty(objName))
            return null;
        return ((SObject) Type.forName(objName).newInstance());
    }
    
    public static Boolean getObjectIsAccessible(String objectName) 
    {
        if (objectName == null || String.isEmpty(objectName))
            return null;
        return ((sObject)Type.forName(objectName).newInstance()).getSObjectType().getDescribe().isAccessible();    
    }
    
    public static Boolean getFieldIsAccessible(String objectName, String fieldName) 
    {
        if (String.isBlank(objectName))
            return false;
        
        if (String.isBlank(fieldName))
            return false;
        
        if(
            ((sObject)Type.forName(objectName).newInstance()) != null
            && ((sObject)Type.forName(objectName).newInstance()).getSObjectType() != null
            && ((sObject)Type.forName(objectName).newInstance()).getSObjectType().getDescribe() != null
        ) 
        {
            if(((sObject)Type.forName(objectName).newInstance()).getSObjectType().getDescribe().isAccessible()) 
            {
                Map<String, Schema.SObjectField> fieldsMap = dynlistUtilities.getFieldsMap(objectName);
                if(fieldsMap != null && fieldsMap.values().size() > 0) 
                {
                    if(fieldsMap.get(fieldName) != null) 
                    {
                        DescribeFieldResult fieldDescribe = fieldsMap.get(fieldName).getDescribe();
                        return fieldDescribe.isAccessible();         
                    }
                } 
            }      
        }
        return false;
    }
    
    public static List<String> getPicklistFieldValues(
        String objName,
        String fieldAPIName
    ) 
    {
        if (String.isBlank(objName)) 
        {
            return null;
        }
        
        if (String.isBlank(fieldAPIName)) 
        {
            return null;
        }
        
        List<String> picklistValues = new List<String>();
        Schema.SObjectType objectType = ((SObject) Type.forName(objName).newInstance()).getSObjectType();
        if (objectType != null) 
        {
            Schema.DescribeSObjectResult objectResult = objectType.getDescribe();
            if (objectResult != null) 
            {
                Map<String, Schema.SObjectField> mapOfFieldsResults = objectResult.fields.getMap();
                if (mapOfFieldsResults != null) 
                {
                    if (mapOfFieldsResults.get(fieldAPIName) != null) 
                    {
                        Schema.DescribeFieldResult fieldResult = mapOfFieldsResults.get(
                            fieldAPIName
                        )
                            .getDescribe();
                        if (fieldResult != null) 
                        {
                            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                            for (Schema.PicklistEntry pickListVal : ple) 
                            {
                                picklistValues.add(pickListVal.getValue());
                            }
                            return picklistValues;
                        }
                    }
                }
            }
        }
        return null;
    }
    
    public static Boolean isUserHaveDeleteObjectAccess(String objectApiName) 
    {
        if(String.isNotBlank(objectApiName)) 
        {
            Schema.SObjectType sObjectTypeObj = dynlistUtilities.getObjectTypeOnBasisOfObjectName(objectApiName);
            if (sObjectTypeObj == null) 
            {
                return false;
            }
            Schema.DescribeSObjectResult d = sObjectTypeObj.getDescribe();
            return d.isDeletable();        
        }
        return false;
    }
    
    public static Boolean isUserHaveUpdateObjectAccess(String objectApiName) 
    {
        if(String.isNotBlank(objectApiName)) 
        {
            Schema.SObjectType sObjectTypeObj = dynlistUtilities.getObjectTypeOnBasisOfObjectName(objectApiName);
            if (sObjectTypeObj == null) 
            {
                return false;
            }
            Schema.DescribeSObjectResult d = sObjectTypeObj.getDescribe();
            return d.isUpdateable();
        }
        return false;
    }
    
    // using describe, check if user has access to the object
    public static String checkIfUserHasObjectLevelSecurity(
        String objectApiName,
        String recordId
    ) 
    {
        Schema.SObjectType sObjectTypeObj = dynlistUtilities.getObjectTypeOnBasisOfObjectName(
            objectApiName
        );
        if (sObjectTypeObj == null) 
        {
            return System.Label.DYNLIST_INVALID_OBJECT_NAME;
        }
        Schema.DescribeSObjectResult d = sObjectTypeObj.getDescribe();
        
        // returns appropriate error message when a user does not have new or edit access accordingly,
        // returns empty otherwise
        if (String.isEmpty(recordId) && !d.isCreateable()) 
        {
            return System.Label.DYNLIST_OBJECT_NOT_CREATABLE +
                dynlistConstants.CHAR_BLANK_SPACE +
                dynlistConstants.CHAR_COLON +
                dynlistConstants.CHAR_BLANK_SPACE +
                d.getLabel();
        } else if (String.isNotEmpty(recordId) && !d.isUpdateable()) 
        {
            return System.Label.DYNLIST_OBJECT_NOT_UPDATABLE +
                dynlistConstants.CHAR_BLANK_SPACE +
                dynlistConstants.CHAR_COLON +
                dynlistConstants.CHAR_BLANK_SPACE +
                d.getLabel();
        }
        return dynlistConstants.CHAR_BLANK_STRING;
    }
    
    public static Object readObjectValue(sObject obj, String path) 
    {
        String[] parts = path.split('\\.');
        for (Integer c = 0; c < parts.size() - 1; c++) 
        {
            obj = obj.getSObject(parts[c]);
            if (obj == null) 
            {
                return null;
            }
        }
        return obj.get(parts[parts.size() - 1]);
    }
    
    public static Schema.DescribeFieldResult getFieldDescribeResult(
        Schema.SObjectType objectType,
        Schema.FieldSetMember member
    ) 
    {
        String fieldPath = member.getFieldPath();
        return getFieldDescribeResult(objectType, fieldPath);
    }
    
    private static Map<String, Schema.DescribeFieldResult> fieldDescribeResultCache = new Map<String, Schema.DescribeFieldResult>();
    public static Schema.DescribeFieldResult getFieldDescribeResult(
        Schema.SObjectType objectType,
        String fieldPath
    ) 
    {
        Schema.DescribeSobjectResult objectDescribe = objectType.getDescribe();
        String key = objectDescribe.getName() + fieldPath;
        Schema.DescribeFieldResult value = fieldDescribeResultCache.get(key);
        
        if (value == null) 
        {
            List<String> path = fieldPath.split('\\.');
            Schema.SObjectType type = objectType;
            
            if(pkgPrefix == null)
            {
                pkgPrefix = dynlistUtilities.getPackagePrefix();
            }
            
            while (path.size() > 1) 
            {
                String lookupName = getLookupName(path.remove(0));
                Schema.DescribeFieldResult describe = null;
                try 
                {
                    describe = type.getDescribe()
                        .fields.getMap()
                        .get(lookupName)
                        .getDescribe();
                } catch (Exception e) 
                {
                    describe = type.getDescribe()
                        .fields.getMap()
                        .get(pkgPrefix + lookupName)
                        .getDescribe();
                }
                type = describe.getReferenceTo()[0];
            }
            
            Map<String, Schema.SObjectField> objectFields = type.getDescribe().fields.getMap();
            Schema.SObjectField objectField = objectFields.get(path[0]);
            
            if (objectField == null) 
            {
                if(String.isNotBlank(pkgPrefix)) 
                {
                	objectField = objectFields.get(pkgPrefix + path[0]);    
                }
                else 
                {
                    objectField = objectFields.get(path[0]);
                }
            }
            if(objectField != null) 
            {
            	value = objectField.getDescribe();   
                fieldDescribeResultCache.put(key, value);
            }
        }
        return value;
    }
    
    private static String getLookupName(String crossObjectReference) 
    {
        return crossObjectReference.endsWith(dynlistConstants.CHAR_DOUBLE_UNDERSCORE_R)
            ? crossObjectReference.replace(
                dynlistConstants.CHAR_DOUBLE_UNDERSCORE_R,
                dynlistConstants.CHAR_DOUBLE_UNDERSCORE_C
            )
            : crossObjectReference + dynlistConstants.ID_FIELD_NAME;
    }
    
    /***********************************************************
* Description: Sanitize the string if the user does not have view encrypted data permission.
*
* @param: hasEncryptedData - if the user has encrypted data permission
* @param: stringToSanitize - the string to santitize before returning to client
* @param: fieldType - this is the type of field to sanitize, only perform if encrypted string
*
* @return: boolean
* ********************************************************/
    public static String sanitizeEncryptedData(
        boolean hasEncryptedData,
        String stringToSanitize
    ) 
    {
        if (hasEncryptedData && stringToSanitize != null) 
        {
            String mask = dynlistConstants.CHAR_X;
            return mask.repeat(stringToSanitize.length());
        } 
        else 
        {
            return dynlistConstants.CHAR_BLANK_STRING;
        }
    }
    
    //Return true if user has View Encrypted Data permission.
    public static boolean userHasEncryptedData(Id userId) 
    {
        List<PermissionSetAssignment> psaEncrypt = [
            SELECT Id
            FROM PermissionSetAssignment
            WHERE
            PermissionSet.PermissionsViewEncryptedData = TRUE
            AND AssigneeId = :userId
        ];
        
        if (psaEncrypt.isEmpty()) 
        {
            return false;
        } else 
        {
            return true;
        }
    }
    
    public static Map<String, Dynamic_Related_List_Manager__mdt> getMapOfDynamicRelatedListManager() 
    {
        return Dynamic_Related_List_Manager__mdt.getAll();        
    }
    
    public static Set<String> setOfObjectsAPINameNotHavingNameField() 
    {
        Map<String, Dynamic_Related_List_Manager__mdt> mapOfDynamicRelatedListManagerSettings = dynlistUtilities.getMapOfDynamicRelatedListManager();
        Set<String> setOfObjectsWithoutNameField = new Set<String>();
        if(mapOfDynamicRelatedListManagerSettings != null) 
        {
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
                        if(dynlistSetting.Type__c.equalsIgnoreCase(dynlistConstants.TYPE_OBJECT_NOT_HAVING_NAME_FIELD)) 
                        {
                            setOfObjectsWithoutNameField.add(dynlistSetting.Object_API_Name__c.toLowerCase());
                        }        
                    } 
                }
            }
        }
        return setOfObjectsWithoutNameField;
    }
    
    public static Map<String, String> mapOfObjectsAPINameWithSynonymField() 
    {
        Map<String, Dynamic_Related_List_Manager__mdt> mapOfDynamicRelatedListManagerSettings = dynlistUtilities.getMapOfDynamicRelatedListManager();
        Map<String, String> mapOfObjNameWithSynonymName = new Map<String, String>();
        if(mapOfDynamicRelatedListManagerSettings != null) 
        {
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
                        if(dynlistSetting.Type__c.equalsIgnoreCase(dynlistConstants.TYPE_OBJECT_NOT_HAVING_NAME_FIELD)) 
                        {
                            if(String.isNotBlank(dynlistSetting.Synonym_Field_API_Name__c))
                            {
                                mapOfObjNameWithSynonymName.put(dynlistSetting.Object_API_Name__c.toLowerCase(), dynlistSetting.Synonym_Field_API_Name__c.toLowerCase());        
                            }
                        }        
                    } 
                }
            }
        }
        return mapOfObjNameWithSynonymName;
    }
    
    public static Map<String, Dynamic_Related_List_Manager__mdt> mapOfObjectsNotHavingNameField() 
    {
        Map<String, Dynamic_Related_List_Manager__mdt> mapOfDynamicRelatedListManagerSettings = dynlistUtilities.getMapOfDynamicRelatedListManager();
        Map<String, Dynamic_Related_List_Manager__mdt> mapOfObjNotHavingNameField = new Map<String, Dynamic_Related_List_Manager__mdt>();
        if(mapOfDynamicRelatedListManagerSettings != null) 
        {
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
                        if(dynlistSetting.Type__c.equalsIgnoreCase(dynlistConstants.TYPE_OBJECT_NOT_HAVING_NAME_FIELD)) 
                        {
                            if(String.isNotBlank(dynlistSetting.Synonym_Field_API_Name__c))
                            {
                                mapOfObjNotHavingNameField.put(dynlistSetting.Object_API_Name__c.toLowerCase(), dynlistSetting);        
                            }
                        }        
                    } 
                }
            }
        }
        return mapOfObjNotHavingNameField;
    }
    
    //dynlistColumn
    @AuraEnabled(cacheable=false)
    public static List<dynlistOption> traverseAllFields(String sObjName)  
    {
        List<dynlistOption> options = new List<dynlistOption>();
        Schema.SObjectType sObjectTypeObj = dynlistUtilities.getObjectTypeOnBasisOfObjectName(
            sObjName
        );
        Map<String, Schema.SObjectField> fieldDescribes = sObjectTypeObj.getDescribe().fields.getMap();
        
        //return all the object fields which is editable and readable
        for (String fieldMember : fieldDescribes.keySet()) 
        {
            Schema.DescribeFieldResult descFieldResult = fieldDescribes.get(
                fieldMember
            )
                .getDescribe();
            if (
                descFieldResult.isAccessible() &&
                (descFieldResult.isCreateable() || descFieldResult.isUpdateable())
            ) 
            {
                dynlistOption optionWrap = new dynlistOption(
                    descFieldResult.getName(),
                    descFieldResult.getLabel()
                );
                options.add(optionWrap);
            }
        }
        return options;
    }
    
    //ctrlFilters
    //Start From here
    public static String getQuery(
        String objectName,
        Set<String> fields,
        List<String> mandatoryFields,
        String whereClause,
        String orderBy,
        String queryLimit,
        Boolean convertFieldPaths,
        Boolean addPrefix,
        Boolean enableWithSecurityEnforced,
        String offset
    ) 
    {
        Set<String> fieldsAlreadyInQuery = new Set<String>();
        fieldsAlreadyInQuery.add(dynlistConstants.ID_FIELD_API_NAME);
        String query = dynlistConstants.SOQL_STRING_REQUIRED_PREFIX;
        
        if(pkgPrefix == null)
        {
            pkgPrefix = dynlistUtilities.getPackagePrefix();
        }
        
        for (String field : mandatoryFields) 
        {
            field = field.toLowerCase();
            if (
                String.isNotBlank(pkgPrefix) &&
                field.endswith(dynlistConstants.CHAR_DOUBLE_UNDERSCORE_C) &&
                !field.startsWith(pkgPrefix) &&
                addPrefix
            ) 
            {
                field = pkgPrefix + field;
            }
            query +=
                dynlistConstants.CHAR_COMMA +
                dynlistConstants.CHAR_BLANK_SPACE +
                field;
            fieldsAlreadyInQuery.add(field);
        }
        
        for (String field : fields) {
            String fieldApiName = field.toLowerCase();
            if (!fieldsAlreadyInQuery.contains(fieldApiName)) 
            {
                query +=
                    dynlistConstants.CHAR_COMMA +
                    dynlistConstants.CHAR_BLANK_SPACE +
                    field;
                fieldsAlreadyInQuery.add(fieldApiName);
            }
        }
        query += dynlistConstants.SOQL_STRING_FROM_KEYWORD + objectName;
        
        if (String.isNotBlank(whereClause)) 
        {
            query += dynlistConstants.CHAR_BLANK_SPACE + whereClause;
        }
        
        if (enableWithSecurityEnforced) 
        {
            query +=
                dynlistConstants.CHAR_BLANK_SPACE +
                dynlistConstants.SOQL_STRING_WITH_SECURITY_ENFORCED_KEYWORD;
        }
        
        if (String.isNotBlank(orderBy)) 
        {
            query += dynlistConstants.CHAR_BLANK_SPACE + orderBy;
        }
        if (String.isNotBlank(queryLimit)) 
        {
            query += dynlistConstants.CHAR_BLANK_SPACE + queryLimit;
        }
        if (String.isNotBlank(offset)) 
        {
            query += dynlistConstants.CHAR_BLANK_SPACE + offset;
        }
        return query;
    }
    
    public static Boolean contains(
        List<Schema.DisplayType> aListActingAsSet,
        Schema.DisplayType typeToCheck
    ) 
    {
        if (aListActingAsSet != null && aListActingAsSet.size() > 0) 
        {
            for (Schema.DisplayType aType : aListActingAsSet) 
            {
                if (aType == typeToCheck) 
                {
                    return true;
                }
            }
        }
        return false;
    }
    
    /**
*  Method to return good formated string for SOQL query based on Array values.
*  Use in SoqlBuilder for field in: array where condition , without passing bound attribute.
*  @param  objectList any array types (like an Set,List).
*  @return - good formated string for SOQL query. Format : ('a1H0Y000001hXtVUAU','a1H0Y000001hdfyUAA','a1H0Y000001hdg3UAA')
*/
    public static String getArrayStringForQuery(Object objectList)
    {
        String objectListString = String.valueOf(objectList);
        return getArrayStringForQuery(objectListString);
    }
    
    /**
*  Method to return good formated string for SOQL query based on Array values.
*  Use in SoqlBuilder for field in: array where condition , without passing bound attribute.
*  @param  objectListString string Array.
*  @return - good formated string for SOQL query. Format : ('a1H0Y000001hXtVUAU','a1H0Y000001hdfyUAA','a1H0Y000001hdg3UAA')
*/
    public static String getArrayStringForQuery(String objectListString)
    {
        String soqlFormatArrayString = '';
        Pattern p = Pattern.compile('[^,{\\s][^\\,]*[^,]*[^,}\\s]');
        Matcher m = p.matcher(String.escapeSingleQuotes(objectListString));
        List<String> listValues = new List<String>();
        while (m.find() == true) {
            listValues.add('\'' + m.group(0) + '\'');
        }
        if(!listValues.isEmpty()){
            soqlFormatArrayString +=  '(' + String.join(listValues, ',') + ')';
        }else{
            soqlFormatArrayString = '(\'\')';
        }
        return soqlFormatArrayString;
    }
    
    public static DateTime isoTime2DateTime(String isoTime) 
    {
        DateTime val = (DateTime)JSON.deserialize('"'+isoTime+'"',DateTime.class);
        return val;
    }
    
    public static String dateTime2isoTime(DateTime val) 
    {
        String isoTime = JSON.serialize(val);
        isoTime = isoTime.replace('.000','').replace('"',''); // Strip the quote of the JSON string to be normal text
        return isoTime;
    }
    
    public static Set<String> getSetOfNonQueryableFields(Map<String, String> mapOfNonQueryableFields, String objectName, Set<String> setOfFieldNames) 
    {
        Set<String> setOfNonQueryableFields = new Set<String>();
        if(mapOfNonQueryableFields != null && String.isNotBlank(objectName) && setOfFieldNames != null && setOfFieldNames.size() > 0) 
        {
            if(mapOfNonQueryableFields.containsKey(objectName.toLowerCase()) && String.isNotBlank(mapOfNonQueryableFields.get(objectName.toLowerCase()))) 
            {
                for(String field : setOfFieldNames) 
                {
                    if(mapOfNonQueryableFields.get(objectName.toLowerCase()).split(dynlistConstants.CHAR_COMMA).size() > 0) 
                    {
                        for(String fieldToSkip : mapOfNonQueryableFields.get(objectName.toLowerCase()).split(dynlistConstants.CHAR_COMMA)) 
                        {
                            if(fieldToSkip.equalsIgnoreCase(field)) 
                            {
                                setOfNonQueryableFields.add(fieldToSkip);
                            }    
                        }
                    }
                    else 
                    {
                        if(mapOfNonQueryableFields.get(objectName.toLowerCase()).equalsIgnoreCase(field)) 
                        {
                            setOfNonQueryableFields.add(field);
                        }
                    }        
                }
            }
        }
        return setOfNonQueryableFields;
    }
    
    //Map of fields names of which current logged in user is not having access
    public static Map<String, Set<String>> getInAccessibleFieldsDetails(String query) 
    {
        Map<String, Set<String>> mapOfInAccessibleFields = new Map<String, Set<String>>();
        if(String.isNotBlank(query)) 
        {
            SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.READABLE, Database.query(query));
            mapOfInAccessibleFields = securityDecision.getRemovedFields();    
        }
        return mapOfInAccessibleFields;
    }
    
    //Method to validate a string for a validate salesforce ID value
    public static Boolean isaValidateSalesforceID(String idString) 
    {
        Boolean isAValidateIDValue = false;
        if(String.isNotBlank(idString)) 
        {
            if(idString instanceOf Id) 
            {
                isAValidateIDValue = true;     
            }    
        }
        return isAValidateIDValue;
    }
    
    public static Boolean isSelectedValuesContainsThisValue(String selectedValues, String thisValue, String fieldName, String operation) 
    {
        Boolean isContainsValue = false;
        Set<String> setOfUserRoleAccessFields = dynlistConstants.USER_ROLE_ACCESS_SPECIAL_FIELDS;
        
        //Special handling for the UserRole access based fields
        if(String.isNotBlank(fieldName) && setOfUserRoleAccessFields.contains(fieldName.trim())) 
        {
            if(String.isNotBlank(thisValue)) 
            {
                if(dynlistConstants.USER_ROLE_OBJECT_ACCESS_MAPPING.containsKey(thisValue.trim())) 
                {
                    thisValue = dynlistConstants.USER_ROLE_OBJECT_ACCESS_MAPPING.get(thisValue.trim());
                }
            }    
        }
        
        if(String.isNotBlank(selectedValues) && String.isNotBlank(thisValue)) 
        {
            for(String st : selectedValues.split(dynlistConstants.CHAR_COMMA)) 
            {
                if(operation == dynlistConstants.CHAR_EQUALS && st.trim().equalsIgnoreCase(thisValue)) 
                {
                    isContainsValue = true;
                    break;
                }    
                else if (operation == dynlistConstants.CHAR_NOT_EQUALS && st.trim().equalsIgnoreCase(thisValue))
                {
                    isContainsValue = false;
                    break;
                }
            }    
        }
        return isContainsValue;
    }
}