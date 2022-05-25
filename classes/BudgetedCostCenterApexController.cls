/**
 *	Purpose         :   Controller class for BudgetedCostCenter lightning component and it is used for following purpose :
 *                          1. Search Dimension 1 Object record by Name field
 *			    2. Update Id, Name & Reporting code of selected dimension 1 record on EAB Event (Budgeted Cost Center) Quick Action.
 *
 *	Revision Log    :   V_1.0 Created - Chirag Soni - 05/28/2021 - CR-20210323-15018
 **/

public without sharing class BudgetedCostCenterApexController 
{    
    
   /** 
    *   Description     :   This method is used to retrive all active records based on search value .
    *
    *   @argument       :   String, String, String
    *   
    *   return type     :   List of Custom wrapper class 
    * 
    *   Revision Logs   :   V_1.0 - Created 
    **/
    
    @AuraEnabled(cacheable = true)
    public static List<SObJectResult> getResults(String ObjectName, String fieldName, String additionalFieldName, String searchValue) 
    {
        try 
        {
            // list to hold and return search results
            List<SObJectResult> sObjectResultList = new List<SObJectResult>();
            
            // check for blank value
            if(String.isNotBlank(ObjectName) && String.isNotBlank(fieldName) && String.isNotBlank(searchValue) && String.isNotBlank(additionalFieldName)) 
            {
                //Query record based on value
                String dataBaseQuery = 'Select Id,'+fieldName+', '+additionalFieldName+' FROM '+ObjectName+' WHERE '+fieldName+' LIKE \'%' + searchValue + '%\' AND Active__c = true';
                for(sObject so : Database.Query(dataBaseQuery)) 
                { 
                    String fieldvalue = (String)so.get(fieldName);
                    String reportingCode = (String)so.get(additionalFieldName);
                    
                    //set attribute in wrapper
                    sObjectResultList.add(new SObjectResult(fieldvalue, so.Id, reportingCode));
                }
            }
            
            return sObjectResultList;    
        }
        catch(Exception ex)
        {
            return null;  
        }
    }
    
   /** 
    *   Description     :   This method is used Update Id, Name & Reporting code of selected dimension 1 record on EAB Event.
    *
    *   @argument       :   Id, String, String, String
    *   
    *   return type     :   String 
    * 
    *   Revision Logs   :   V_1.0 - Created
    **/
    
    @AuraEnabled(cacheable = false)
    public static String saveAndUpdateEABEvent(Id eabEventId, String recordName, String reportingCode, String selectRecordId)
    {
        try
        {
            // check for black parameters
            if(String.isNotBlank(eabEventId) && String.isNotBlank(reportingCode)){
                
                // find and update event record in sobject type
                Schema.SObjectType token = eabEventId.getSobjectType();
                Sobject customObject = token.newSObject();
                customObject.put('Id', eabEventId);
                customObject.put('Budgeted_Cost_Center_ID__c', selectRecordId);
                customObject.put('Budgeted_Cost_Center_Name__c', recordName); 
                customObject.put('Budgeted_Cost_Center_Reporting_Code__c', reportingCode);
                update customObject;
            }
            return 'SUCCESS';  
        }
        catch(Exception ex)
        {
            return ex.getMessage();  
        }
    } 
    
   /**
    *	Purpose         :   Custom Wrapper class to hold Dimension 1 Records
    *
    *	Revision Log    :   V_1.0 Created - Chirag Soni - 05/28/2021 - CR-20210323-15018
    **/
    
    public class SObJectResult 
    {
        @AuraEnabled
        public String recordName {get; set;}
        
        @AuraEnabled
        public Id recordId {get; set;}
        
        @AuraEnabled
        public String reportingCode {get; set;}
        
        public SObJectResult(String recordNameTemp, Id recordIdTemp, String  reportingCodeTemp) 
        {
            recordName = recordNameTemp;
            recordId = recordIdTemp;
            reportingCode = reportingCodeTemp;
        }
    }
}