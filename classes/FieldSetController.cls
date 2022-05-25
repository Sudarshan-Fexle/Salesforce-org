/**
    Purpose         :   Generic Field Set Component Controller class
    
    Created By      :   Abhinav Sharma
    
    Created Date    :   12/21/2019
    
    Current Version :   v1.0
    
    Revision Log    :   V_1.0 Created - Abhinav Sharma - 12/21/2019
                    :   V_1.1 Modified By -Abhinav Sharma - 6/5/2020 -  CR-20200524-14104 - Access modifier based changes here for the @auraenabled properties
**/
public with sharing class FieldSetController 
{
	public static DescribeSObjectResult sObjectResult;

    @AuraEnabled(Cacheable=true)
    public static MetadataResponse getObjectMetadata(Id recordId) 
    {
        MetadataResponse response = new MetadataResponse();
        try 
        {
            if (String.isBlank(recordId)) 
            {
                newException('Record Id required to identify SObjectType', null);    
            } 
            sObjectResult = recordId.getSobjectType().getDescribe();
            response.sObjectName = sObjectResult.getName();
        } 
        catch (Exception ex) 
        {
            newException(ex.getMessage(), ex.getStackTraceString());
        }
        return response;
    }

    @AuraEnabled(Cacheable=true)
    public static MetadataResponse getFieldSetMetadata(Id recordId, String fieldSetName) 
    {
        MetadataResponse response = new MetadataResponse();
        try 
        {
            response = getObjectMetadata(recordId);
            response.sObjectName = sObjectResult.getName();
            if (String.isBlank(fieldsetName)) 
            {
            	newException('Fieldset Name required to get Field Metadata', null);    
            } 
            Map<String, FieldSet> fieldSets = sObjectResult.fieldSets.getMap();
            if (fieldSets.containsKey(fieldSetName)) 
            {
                Map<String, SObjectField> fields = sObjectResult.fields.getMap();
                response.fieldSetLabel = fieldSets.get(fieldSetName).getLabel();
                response.fieldsMetadata = new List<String>();
                for (FieldSetMember fieldSetMember : fieldSets.get(fieldSetName).getFields()) 
                {
                    String fieldName = fieldSetMember.getFieldPath();
                    if (!fieldName.contains('.')) 
                    {
                        DescribeFieldResult fd = fields.get(fieldName).getDescribe();
                        if (fd.isAccessible()) 
                        {
                            response.fieldsMetadata.add(JSON.serialize(
                                new Map<String, Object>{
                                    'fieldSetProperties' => fieldSetMember,
                                    'fieldDescribeProperties' => fd
                                }
                            ));
                        }
                    } 
                    else 
                    {
                        newException('Relationship Fields not supported FieldSet: "'+fieldSetName+'" Field Name: "'+fieldName+'"', null);
                    }
                }
                if (response.fieldsMetadata.isEmpty()) 
                {
            		newException('No accessible fields for the current user in FieldSet "'+fieldSetName+'"', null);        
                }
            } 
            else 
            {
                newException('Fieldset "'+fieldSetName+'" not found for SObject "'+sObjectResult.getName()+'"', null);
            }
        } 
        catch (Exception ex) 
        {
            newException(ex.getMessage(), ex.getStackTraceString());
        }
        return response;
    }

    private static void newException(String exceptionMessage, String stackTraceString) 
    {
        AuraHandledException ex = new AuraHandledException(exceptionMessage);
        ex.setMessage(exceptionMessage + (String.isNotBlank(stackTraceString) ? ' ' + stackTraceString : ''));
        throw ex;
    }

    public class MetadataResponse 
    {
        @AuraEnabled
        public String fieldSetLabel {get;set;}

        @AuraEnabled
        public String sObjectName {get;set;}

        @AuraEnabled
        public List<String> fieldsMetadata {get;set;}
	}
    
    @AuraEnabled(cacheable=true)
    public static FieldWrapper  getFields(String objectApiName,String fieldSetName) 
    {
        if(String.isNotBlank(objectApiName) && String.isNotBlank(fieldSetName))
        {
            //To hold fieldApiName in list
            List<String> fieldAPINames = new List<String>();

            //Describe call for specific object and fields
            Schema.DescribeSobjectResult[] objectDescribes = Schema.describeSObjects(new List<String>{objectApiName});
            Schema.FieldSet fieldSetObj = objectDescribes[0].FieldSets.getMap().get(fieldSetName);
            Map<String, Schema.SObjectField> fields=  objectDescribes[0].fields.getMap();
            
            //Fill field api name in list using fieldset members
            List<Schema.FieldSetMember> fieldSetMembers =  fieldSetObj.getFields();
            for(Schema.FieldSetMember fieldSetMember : fieldSetMembers)
            {
                Schema.DescribeFieldResult fieldDescribe = fields.get(fieldSetMember.getFieldPath()).getDescribe();
                if(objectDescribes[0].isAccessible() && fieldDescribe.isAccessible())
                {
                    fieldAPINames.add(fieldSetMember.getFieldPath());
                }
            }
                
            if(fieldAPINames.size() > 0)
            {
                FieldWrapper fieldWrapper = new FieldWrapper(fieldAPINames);
                return fieldWrapper;
            }
        }
        return  null; 
    }

    @AuraEnabled(cacheable=true)
    public static List<opportunity> getOpportuntiyDetail(String recId){

        List<opportunity> opportunities = [Select Id, AccountId FROM opportunity WHERE Id =: recId];
        System.debug('opportunities --'+opportunities) ;
        return opportunities;
    }

    public class FieldWrapper
    {
        @AuraEnabled 
        public List<String> fields{get;set;}
        
        public FieldWrapper(List<String> fields)
        {
            this.fields = fields;         
        }  
    }
}