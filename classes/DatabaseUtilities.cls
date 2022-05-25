/**
*	Desription      :	Class to have the Database Utility Methods
* 
*	Created By      :   Abhinav Sharma
* 
*  Created Date    :   	11/22/2019
* 
*  Revision Logs   :    V1.0 - Created
*
**/
public without sharing class DatabaseUtilities 
{
    // using describe, check if user has access to the object
    public static String checkIfUserHasObjectLevelSecurity(String objectApiName, String recordId) 
    {
        Schema.SObjectType sObjectTypeObj = DatabaseUtilities.getObjectTypeOnBasisOfObjectName(objectApiName);
        if (sObjectTypeObj == null) 
        {
            return System.Label.Error_invalid_object_name;
        }
        Schema.DescribeSObjectResult d = sObjectTypeObj.getDescribe();
        Map<String, Schema.SObjectField> fieldDescribes = SObjectTypeObj.getDescribe().fields.getMap();
        
        // returns appropriate error message when a user does not have new or edit access accordingly, 
        // returns empty otherwise
        if (String.isEmpty(recordId) && !d.isCreateable()) 
        {
            return System.Label.Error_Object_not_creatable + ': ' + d.getLabel();
        } else if(String.isNotEmpty(recordId) && !d.isUpdateable()) 
        {
            return System.Label.Error_Object_not_updateble + ': ' + d.getLabel();
        }
        return '';
    }
    
    public static String getFieldsetQuery(String objectName,Schema.FieldSetMember[] fieldSet)
    {
        return getFieldsetQuery(objectName, fieldSet, new List<String>());
    }
    
    public static String getFieldsetQuery(String objectName,Schema.FieldSetMember[] fieldSet,List<String> mandatoryFields)
    {
        return getFieldsetQuery(objectName, fieldSet, mandatoryFields, '', '', '', false);
    }
    
    public static String getFieldsetQuery(String objectName, Schema.FieldSetMember[] fieldSet, 
                                          List<String> mandatoryFields, String whereClause, String orderBy, 
                                          String queryLimit, Boolean convertFieldPaths)
    {
        return getFieldsetQuery(objectName, fieldSet, mandatoryFields, whereClause, orderBy, queryLimit, convertFieldPaths, true);
    }
    
    public static String getFieldsetQuery(String objectName, Schema.FieldSetMember[] fieldSet, List<String> mandatoryFields, 
                                          String whereClause, String orderBy, String queryLimit, Boolean convertFieldPaths, 
                                          Boolean addPrefix)
    {
        Set<String> fieldsAlreadyInQuery = new Set<String>();
        fieldsAlreadyInQuery.add('id');
        String query = 'select id';
        
        for (String field: mandatoryFields) 
        {
            field = field.toLowerCase();
            if (field.endswith('__c') && !field.startsWith(Utilities.getPackagePrefix()) && addPrefix) 
            {
                field = Utilities.getPackagePrefix()+field;
            }
            query += ', '+field;
            fieldsAlreadyInQuery.add(field);
        }
        
        for(Schema.FieldSetMember fieldsetMember:fieldSet) 
        {
            String field = fieldsetMember.getFieldPath().toLowerCase();
            if (!fieldsAlreadyInQuery.contains(field))
            {
                query += ', ' + field;
                fieldsAlreadyInQuery.add(field);
            }
            
            // Add the converted fieldPath (instead of replacing it)
            if (convertFieldPaths) 
            {
                String convertedField = getConvertedFieldPath(fieldsetMember).toLowerCase();
                if (convertedField != field) 
                {
                    if (!fieldsAlreadyInQuery.contains(convertedField)) 
                    {
                        query += ', ' + convertedField;
                        fieldsAlreadyInQuery.add(convertedField);
                    }
                }
            }
        }
        query += ' from '+objectName;
        
        if(String.isNotBlank(whereClause)) 
        {
            query += ' '+whereClause;
        }
        if(String.isNotBlank(orderBy)) 
        {
            query += ' '+orderBy;
        }
        if(String.isNotBlank(queryLimit)) 
        {
            query += ' '+queryLimit;
        }
        
        return query;
    }
    
    public static String getConvertedFieldPath(Schema.FieldSetMember fsMember) 
    {
        return getConvertedFieldPath(fsMember.getFieldPath(),String.valueOf(fsMember.getType()));
    }

    public static String getConvertedFieldPath(String fieldPath , String fieldType) 
    {
        String fieldName = fieldPath;

        if (fieldName == 'Id') 
        {
            fieldName = 'Id';
        }
        else if (fieldName.endsWithIgnoreCase('.Id')) 
        {
			fieldName = fieldPath.left(fieldPath.length()-2) + 'Name';
        }
        else if (fieldPath.endsWithIgnoreCase('Id')) 
        {
            fieldName = fieldPath.left(fieldPath.length()-2) + '.Name';
        }
        else if(fieldType  == 'REFERENCE') 
        {
            if (fieldName.endsWithIgnoreCase('__c')) 
            {
                fieldName = fieldName.removeEndIgnoreCase('__c') + '__r.Name';
            } 
            else 
            {
                fieldName += '.Name';
            }
        }
		return fieldName; 
    }
    
    private static Map<Id, String> recordTypeLabelCache;
    public static String getRecordTypeLabel(ID typeID) 
    {
        if(recordTypeLabelCache == null) 
        {
            recordTypeLabelCache = new Map<Id, String>();
        }
        String label = recordTypeLabelCache.get(typeID);
        if(label == null) 
        {
            List<RecordType> rt = [select toLabel(name) from RecordType where id = :typeID];
            label = (rt.size() == 0)?null:rt.get(0).name;
            recordTypeLabelCache.put(typeID, label);
        }
        return label;
    }
    
    public static Id getRecordTypeIdForObject(String objName, String recTypeName) 
    {
         if(String.isEmpty(objName) || String.isEmpty(recTypeName))
            return null;
        return ((SObject)Type.forName(objName).newInstance())
            .getSObjectType()
            .getDescribe()
            .getRecordTypeInfosByName()
            .get(recTypeName)
            .getRecordTypeId();
    }
    
    public static Id getRecordTypeIdForObject(Schema.SObjectType objType, String recTypeName) 
    {
        if(objType == null || String.isEmpty(recTypeName))
            return null;
        return objType.getDescribe()
            .getRecordTypeInfosByName()
            .get(recTypeName)
            .getRecordTypeId();
    }
    
    public static String getKeyPrefixForObject(String objName) 
    {
        if(objName == null || String.isEmpty(objName))
            return null;
        return ((SObject)Type.forName(objName).newInstance())
            .getSObjectType()
            .getDescribe()
            .getKeyPrefix();
    }
    
    public static String getKeyPrefixForObject(Schema.SObjectType objType) 
    {
        if(objType == null )
            return null;
        return objType.getDescribe().getKeyPrefix();
    }
    
    public static Schema.SObjectType getObjectTypeOnBasisOfIdValue(Id recordId) 
    {
        return recordId.getSobjectType();
    }
    
    public static Schema.SObjectType getObjectTypeOnBasisOfObjectName(String objName) 
    {
        if(objName == null || String.isEmpty(objName))
            return null;
        return ((SObject)Type.forName(objName).newInstance())
            .getSObjectType();
    }
    
    public static Schema.DescribeSObjectResult getObjectDescribeOnBasisOfObjectName(String objName) 
    {
        if(objName == null || String.isEmpty(objName))
            return null;
        return ((SObject)Type.forName(objName).newInstance())
            .getSObjectType()
            .getDescribe();
    }
    
    public static Object readObjectValue(sObject obj, String path) 
    {
    	String[] parts = path.split('\\.');
    	for(Integer c = 0; c < parts.size()-1; c++) 
        {
    		obj = obj.getSObject(parts[c]);
    		if(obj == null) 
            {
    			return null;
    		}
    	} 
    	return obj.get(parts[parts.size()-1]);
    }
	
	// Add for Add mode Utility Start Here (Created by : Abhinav Sir)
	//Method for create log of DML insert or update opertion
	public Static String createLog(Database.SaveResult[] saveResults) 
    
    {
        String logMessage = '';
        for (Database.SaveResult saveResult : saveResults) 
        {
            if (!saveResult.isSuccess())
            {
                for(Database.Error err : saveResult.getErrors()) 
                {
                    logMessage += err.getStatusCode() + '&nbsp;' + err.getMessage() + '<br>';
                }
            }
        }
        return logMessage;
    }
    
    //Method for create log of DML delete opertion
    public Static String createLog(Database.DeleteResult[] deleteResults) 
    {
        String logMessage = '';
        for(Database.DeleteResult deleteResult : deleteResults) 
        {
            if (!deleteResult.isSuccess()) 
            {
                for(Database.Error err : deleteResult.getErrors()) 
                {
                    logMessage += err.getStatusCode() + '&nbsp;' + err.getMessage() + '<br>';
                }
            }
        }
        return logMessage;
    }
    
    //Method for create log of DML upsert opertion
    public Static String createLog(Database.UpsertResult[] upsertResults) 
    {
        String logMessage = '';
        for(Database.UpsertResult upsertResult : upsertResults) 
        {
            if (!upsertResult.isSuccess()) 
            {
                for(Database.Error err : upsertResult.getErrors()) 
                {
                    logMessage += err.getStatusCode() + '&nbsp;' + err.getMessage() + '<br>';
                }
            }
        }
        return logMessage;
    }
    
    //Method for create log of DML opertion errors in HTML format.
    public Static String errorHTMLLog(Database.Error [] errors) 
    {
        String errorHTMLLogs = '';
        for(Database.Error err : errors) 
        {
            errorHTMLLogs += '<tr><td>' + err.getStatusCode() + '</td><td>' + err.getMessage() + '</td></tr>';
        }
        if(errorHTMLLogs != '')
            errorHTMLLogs = '<table border="1"><tr><th>StatusCode</th><th>Message</th></tr>' + errorHTMLLogs + '</table>';
        return errorHTMLLogs;
    }
    
    public Static void sendBatchStatus(Id batchJobId, String batchName, String errors) 
    {
        List<AsyncApexJob> aSyncJobs = AsyncApexJobQueryBuilder.getJobsRelatedToBatch(batchJobId);
        if(aSyncJobs.size() != null && aSyncJobs.size() > 0) 
        {
            String emailMessage = 'Your batch job \"' + batchName + '\" has finished.  It processed job items'
                + aSyncJobs[0].totalJobItems +
                ' batches.  Of which, '
                + aSyncJobs[0].JobItemsProcessed
                + ' processed without any exceptions thrown and '
                + aSyncJobs[0].numberOfErrors
                + ' batches threw unhandled exceptions.' + '<br>' + errors;
            EmailHandler.sendEmail(aSyncJobs[0].CreatedBy.Email, batchName + ' has been completed', emailMessage, errors);        
        }
    }
    
    public Static void sendBatchStatus(Id batchJobId, String batchName, String errors, String emailRecipient) 
    {
        List<AsyncApexJob> aSyncJobs = AsyncApexJobQueryBuilder.getJobsRelatedToBatch(batchJobId);
        if(aSyncJobs.size() != null && aSyncJobs.size() > 0) 
        {
            String emailMessage = 'Your batch job \"' + batchName + '\" has finished.  It processed job items'
                + aSyncJobs[0].totalJobItems +
                ' batches.  Of which, '
                + aSyncJobs[0].JobItemsProcessed
                + ' processed without any exceptions thrown and '
                + aSyncJobs[0].numberOfErrors
                + ' batches threw unhandled exceptions.' + '<br>' + errors;
            EmailHandler.sendEmail(emailRecipient, batchName + ' has been completed', '', emailMessage);        
        }
    }
    
    //Unschedule all jobs with no Next Fire date, and un-schedule them.
    public static void unscheduleJobsWithoutNextFireDate() 
    {
        List<CronTrigger> jobs = CronTriggerQueryBuilder.getAllAllowedJobsWithoutNextFireTime();
        for (CronTrigger job : jobs) 
        {
            try 
            {
                system.abortJob(job.Id);
            } 
            catch(Exception ex) 
            {
                if(ex.getMessage().contains('Invalid parameter value'))
                    continue;
                else if(ex.getMessage().contains('Job does not exist or is already aborted'))
                    continue;
                else
                    throw new CustomException(ex.getMessage());
            }
        }
    }
    
    //Method that fetches the test classes from the system.
    public static Set<Id> extractTestClassesIds()
    {
        Set<Id> setApexClassIds = new Set<Id>();
        Id parentJobId;
        
        //Non test classes that contains @IstTest annotation in it. as well as Test in it.
        List<List<ApexClass>> isTestClassList = ApexClassQueryBuilder.retrieveAllTestClasses();
        if(isTestClassList.size() > 0) 
        {
            for(ApexClass aClass : isTestClassList[0]) 
            {
                setApexClassIds.add(aClass.Id);
            } 
        }
        
        //Loop on the apex class to get the Id of class.
        for(ApexClass testClasses : ApexClassQueryBuilder.retrieveClassesHavingTestMethodsInBetween()) 
        {
            if(testClasses.Body.substringBefore('()').containsIgnoreCase('@istest')) 
            {
                setApexClassIds.add(testClasses.Id);
            }
        }
        // Just for the testing purpose - Remove once done with testing.
        /* setApexClassIds = new Set<Id>();
        setApexClassIds.add('01pC0000000uy2ZIAQ');
        setApexClassIds.add('01p2K000003x4xy');*/
        
        return setApexClassIds;
    }
	// Add for Add mode Utility End Here (Created by : Abhinav Sir)
	
}