/*
Purpose         :   Field Set helper class for Standard Table of (Dynamic Related List)
Created By      :   Abhinav Sharma
Created Date    :   11/24/2021
Current Version :   v1.0
Revision Log    :   V_1.0 Created - Abhinav Sharma - 11/24/2021
*/
public with sharing class dynlistFieldSetHelper 
{
    @AuraEnabled (cacheable=true)
    public static String getFieldsAndRecords(String strObjectApiName, String strfieldSetName,
                                             String criteriaField, String criteriaFieldValue)
    {
        Map<String, String> returnMap = new Map<String,String>();
        if(!String.isEmpty(strObjectApiName) && !String.isEmpty(strfieldSetName))
        {
            //get fields from FieldSet
            SObject sObj = (SObject)(Type.forName(dynlistConstants.CHAR_SCHEMA + dynlistConstants.CHAR_FULL_STOP + strObjectApiName).newInstance());
            if(sObj != null) 
            {
                SObjectType sObjType = sObj.getSObjectType();
                if(sObjType != null && sObjType.getDescribe().isAccessible())
                {
                    List<Schema.FieldSetMember> lstFSMember = sObjType.getDescribe().fieldSets.getMap().get(strfieldSetName).getFields();
                    
                    //prepare SOQL query based on fieldAPIs	
                    String query = 'SELECT ';
                    for(Schema.FieldSetMember f : lstFSMember) 
                    {
                        query += String.escapeSingleQuotes(f.getFieldPath()) + ', ';
                    }
                    query += 'Id FROM ' + String.escapeSingleQuotes(strObjectApiName);
                    
                    //Just in case criteria field not specified then it will return all records
                    if(!(String.isEmpty(criteriaField) && String.isEmpty(criteriaFieldValue)))
                    {
                        query += ' WHERE ' + String.escapeSingleQuotes(criteriaField) + '=\'' + String.escapeSingleQuotes(criteriaFieldValue) + '\'';
                    }
                    
                    //execute query
                    List<SObject> lstRecords = Database.query(query);
                    
                    //prepare a map which will hold fieldList and recordList and return it
                    returnMap.put('FIELD_LIST', JSON.serialize(lstFSMember));
                    returnMap.put('RECORD_LIST', JSON.serialize(lstRecords));
                    return JSON.serialize(returnMap);
                }
                else
                {
                    return null;
                }        
            }
        }
        return null;
    }
}