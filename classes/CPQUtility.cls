/**
 *  Description     :  This class to hold all the utility properties for CPQ project
 *
 *  Created By      :  Subhash Garhwal
 *
 *  Created Date    :  06/22/2016
 *
 *  Revision Logs   :   V_1.0 - Created - Subhash Garhwal - CR-20160414-9762 
 *
 **/
public with sharing class CPQUtility {
    
    /**
     *  @description    :   This method is used to build the SOQL query string.
     *
     *  @args           :   Map<String, Schema.SObjectType>, String, Stirng, String
     *
     *  @return         :   String
     *
     *	@revision Log	:	V_1.0 - Created - Subhash Garhwal - CR-20160414-9762
     **/
    public static String buildSOQL(Map<String, Schema.SObjectType> globalDescribe, String objName, String additionRelationshipFields, String whereClause) {
        
        //SOQL query
        String SOQL = 'Select ';
        
        //Get the field of the object'
        for(String field : globalDescribe.get(objName).getDescribe().fields.getMap().keySet())
            SOQL += field + ',';
        
        //Check for addition fields
        if(String.isNotBlank(additionRelationshipFields))
        	SOQL += additionRelationshipFields;
        
        //Remove extra elements and add object
        SOQL = SOQL.removeEnd(',') + ' From ' + objName;
        
        //Check for Where Clause
        if(String.isNotBlank(whereClause))
        	SOQL += whereClause;
        
        //Return 
        return SOQL;
    }
}