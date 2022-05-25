/*
    Purpose         :   Controller class for "CreateRecordFromFieldset" LWC. 
    Created By      :   Abhinav Sharma
    Created Date    :   09/28/2020
    Current Version :   V1.0
    Revision Log    :   V_1.0 Created - CR-20210924-15459 - Abhinav Sharma
*/
public with sharing class FieldSetHelper 
{    
    @AuraEnabled (cacheable=true)
    public static String getFieldsFromFieldSet(String strObjectApiName, String strfieldSetName)
    {
        if(!String.isEmpty(strObjectApiName) && !String.isEmpty(strfieldSetName))
        {   
            Map<String, String> returnMap = new Map<String, String>();

            //get fields from FieldSet
            SObject sObj = (SObject)(Type.forName('Schema.'+ strObjectApiName)?.newInstance());
            
            List<Schema.FieldSetMember> lstFSMember = sObj?.getSObjectType()?.getDescribe()?.fieldSets.getMap().get(strfieldSetName)?.getFields();
            returnMap.put('FIELD_LIST',JSON.serialize(lstFSMember));
            returnMap.put('OBJECT_LABEL', sObj?.getSObjectType()?.getDescribe()?.getLabel());
			return JSON.serialize(returnMap);
        }                                                              
        return null;
    }
}