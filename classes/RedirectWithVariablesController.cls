/**
 *	Desription      :	Wrapper class to define attributes/properties associated with "Visualforce TableGrid".
 * 
 *	Created By      :   
 * 
 *  Created Date    :   
 * 
 *  Revision Logs   :   V1.0 - Created
 * 					:	V1.1 - Modified by - Subhash Garhwal - 07/01/2015 - CR-20150618-9014
 * 					:	V1.2 - Modified by - Mahendra Swarnkar - 5/25/2015 - CR-20160323-9712
 * 
 *
 **/
public with sharing class RedirectWithVariablesController {
    /*
*  Method name:    redirectUser
*  @description    Redirects the user to the given object + parameters
*  @return         PageReference The page the user needs to be redirect to.
*/
    public PageReference redirectUser(){
        
        String SPLITREDIRECT_PARAMETER = '!!';
        String SPLITREDIRECT_VALUE = '--';
        String SPLITREDIRECT_OBJECT = '--';
        String REDIRECT_PARAMETER = '!-!';
        String REDIRECT_AMPERSAND = '-!-';
        String SPLITSECONDARY_PARAMETER = '///';
        
        //Variable to hold the RecordType Id
        String recordTypeId = ''; 
        
        // Build a map of the parameters
        String newID = ApexPages.currentPage().getParameters().get('newid');
        
        String redirectParameter = ApexPages.currentPage().getParameters().get('redirect');
        List<String> newParams = redirectParameter.Split(SPLITREDIRECT_PARAMETER);
        
        //Get object name
        String strObject ;
        for (String thisParam : newParams)
            if(thisParam.Split(SPLITREDIRECT_VALUE, 2)[0] == 'object')
            strObject = thisParam.Split(SPLITREDIRECT_VALUE, 2)[1];
        
        if(strObject != null)
        {
            String paramName;
            String paramValue;
            String lookupTarget;
            String lookupID;
            String lookupNameValue;
            String retURLValue = ApexPages.currentPage().getParameters().get('retURL');
            String saveURLValue = ApexPages.currentPage().getParameters().get('saveURL');
            Map<String, String> allParams = New Map<String, String>();        
            
            // Identify the fields, against which we'll match the parameters
            Schema.Sobjecttype oTarget = Schema.getGlobalDescribe().get(strObject);  
            sObject oTargetObj = oTarget.newSObject();
            Map<String, Schema.SObjectField> targetFields = oTargetObj.getSObjectType().getDescribe().fields.getMap();
            
            for (String thisParam : newParams)
            {
                paramName = thisParam.Split(SPLITREDIRECT_VALUE, 2)[0];
                paramValue = thisParam.Split(SPLITREDIRECT_VALUE, 2)[1];
                
                if(targetFields.get(paramName) != null)
                {
                    DescribeFieldResult field = targetFields.get(paramName).getDescribe();
                    
                    // This is the Account's Parent lookup field, which appears to behave
                    // differently than the standard lookup fields. 
                    // We'll explicitly identify the name and ID values
                    if(strObject == 'Account' && paramName.toUpperCase() == 'PARENTID')
                    {
                        if(newID == null || paramValue != 'newid')
                            lookupID = paramValue;
                        else
                            lookupID = newID;
                        
                        Account targetAccount = [SELECT		Name 
                                                 FROM 	Account
                                                 WHERE	ID = :lookupID];
                        allParams.put('ParentId',
                                      targetAccount.Name);
                        allParams.put('ID_ParentId',
                                      lookupID);
                    } else if(field.getReferenceTo().size() > 0)
                        // This is a lookup field, and we need to identify the IDs 
                        // and source data
                    {
                        // Identify the target object
                        lookupTarget = field.getReferenceTo()[0].getDescribe().getName();
                        
                        // Identify the source of the ID we'll use to query it
                        if(newID == null || paramValue != 'newid')
                            lookupID = paramValue;
                        else
                            lookupID = newID;
                        
                        List<sObject> oLookupTarget = Database.query('SELECT Name FROM ' + lookupTarget + ' WHERE ID = :lookupID');
                        
                        //Added by - Subhash Garhwal - 07/01/2015 - CR-20150618-9014
                        //Check for list size
                        if(oLookupTarget.size() > 0)
                        	lookupNameValue = (String)oLookupTarget[0].get('Name');
                        
                        //if the recordTypeId is passed in, reference the id direclty in the url without trying to translate to lookupNameVal
                        if (paramName == 'RecordTypeId') {
                            
                            //Added by - Mahendra Swarnkar - 5/25/2015 - CR-20160323-9712 - Starts from here
                            //Set RecordType Id
                            recordTypeId = lookupID;
                            //Added by - Mahendra Swarnkar - 5/25/2015 - CR-20160323-9712 - Ends here
                            allParams.put(paramName,
                                          lookupID);
                        }
                        else {
                            allParams.put(paramName,
                                          lookupNameValue);
                            allParams.put('ID_' + paramName,
                                          lookupID);
                        }
                    } else
                        // This means it's NOT a lookup, and the value should be taken as-is
                    {
                        allParams.put(paramName, 
                                      paramValue);
                    }                    
                } else if(paramName == 'returnURL')
                    // This allows us to control the retURL for saveURL implementations...
                {
                    retURLValue = paramValue;
                    
                } else if(paramName == 'afterSaveURL')
                    // This allows us to control the retURL for saveURL implementations...
                {
                    saveURLValue = paramValue;
                    
                } else if(paramName == 'recordTypeName')
                {
                    RecordType recordTypeValue = [SELECT           ID 
                                                  FROM                 RecordType 
                                                  WHERE               SObjectType = :strObject AND 
                                                  DeveloperName = :paramValue];
                    
                    //Added by - Mahendra Swarnkar - 5/25/2015 - CR-20160323-9712 - Starts from here
                    if (recordTypeValue != null)
                        allParams.put('RecordTypeId', 
                                      recordTypeValue.ID);
                    //Added by - Mahendra Swarnkar - 5/25/2015 - CR-20160323-9712 - Ends here
                    
                } else if(paramName == 'RTS')
                {
                    allParams.put(paramName, 
                                  paramValue);
                }
            }
            
            //Allow record type selection? if set to yes, then allow RTS
            String strEnableRTS = allParams.get('RTS');
            
            //Create a generic object based on the name
            Schema.Sobjecttype oGenericObj = Schema.getGlobalDescribe().get(strObject);     
            
            //If a real object has been given
            if(oGenericObj != null){
                
                PageReference pReference = null;
                
                //Check if we have to use record type selection or not
                if(strEnableRTS != null){
                    
                    //If we need RTS, the URL will have to point to the recordtypeselect.jsp
                    if(oGenericObj.getDescribe().custom){
                        pReference = new PageReference('/setup/ui/recordtypeselect.jsp?ent=' + strEnableRTS.right(15) + '&save_new_url=/' + oGenericObj.getDescribe().getKeyPrefix() + '/e?');                   
                    }
                    else{
                        pReference = new PageReference('/setup/ui/recordtypeselect.jsp?ent=' + strObject + '&save_new_url=/' + oGenericObj.getDescribe().getKeyPrefix() + '/e?');                   
                    }
                    
                }else{
                    
                    //Else create the page reference to the edit page of this object
                    pReference = new PageReference('/' +  oGenericObj.getDescribe().getKeyPrefix() + '/e');
                }
                
                //Also get a separate reference - we always need to get the parameters based on the edit page
                PageReference pEditReference = new PageReference('/' +  oGenericObj.getDescribe().getKeyPrefix() + '/e?nooverride=1');
                
                //Get all current parameters - this could be either edit page or the record type selection.
                Map<String, String> m = pReference.getParameters();
                
                //Create the parameters for the URL (translates field to ID)             
                //Check for RecordType Id
               	if(String.isNotBlank(recordTypeId))
                	pEditReference.getParameters().put('RecordType',recordTypeId);
                m.putAll(RedirectUtility.createLabelParameters(pEditReference, oGenericObj.newSObject(), allParams));
                m.put('nooverride', '1');
                m.put('retURL', retURLValue);
                
                if(saveURLValue != null)
                {                    
                    saveURLValue = saveURLValue.Replace('redirect2', 'redirect');
                    saveURLValue = saveURLValue.Replace(REDIRECT_PARAMETER, '?');
                    saveURLValue = saveURLValue.Replace(REDIRECT_AMPERSAND, '&');
                    saveURLValue = saveURLValue.Replace(SPLITSECONDARY_PARAMETER, SPLITREDIRECT_PARAMETER);
                    m.put('saveURL', saveURLValue);
                }
                //Return the page
                system.debug('pReference: ' + pReference);
                return pReference;
            }
        }
        
        //Return null if someone is playing with the URL
        return null;
    }
}