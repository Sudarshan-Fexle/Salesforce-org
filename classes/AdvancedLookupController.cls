/*
Purpose         :   Advanced Custom Lookup Controller
Created By      :   Saurabh Kumar
Created Date    :   08/05/2020
Current Version :   V_1.0
Revision Log    :   V_1.0 Created - Saurabh Kumar - 08/05/2020 - CR-20200821-14455
*/
public with sharing class AdvancedLookupController 
{
    @AuraEnabled
    public static List<SObjectResult> getResults(String objectName , String searchValue, String whereClause) 
    {
        String query = '';
        List<SObJectResult> sObjectResultList = new List<SObJectResult>();
      
        if(String.isBlank(searchValue) && String.isBlank(whereClause))
            query += 'SELECT Id , Name'+' FROM '+objectName+' ORDER BY Name DESC LIMIT 5';
        else if(String.isNotBlank(searchValue) && String.isBlank(whereClause))
            query += 'SELECT Id , Name'+' FROM '+objectName+' WHERE Name LIKE \'%' + searchValue + '%\'';
        
        if(String.isBlank(searchValue) && String.isNotBlank(whereClause))
            query += 'SELECT Id , Name'+' FROM '+objectName+' WHERE '+whereClause+' ORDER BY Name DESC LIMIT 5';
        else if(String.isNotBlank(searchValue) && String.isNotBlank(whereClause))
            query += 'SELECT Id , Name'+' FROM '+objectName+' WHERE '+whereClause+' AND Name LIKE \'%' + searchValue + '%\'';
      
        for(sObject so : Database.Query(query)) 
        {
            String fieldvalue = (String)so.get('Name');
            sObjectResultList.add(new SObjectResult(fieldvalue, so.Id));
        } 
        return sObjectResultList;
    }
    
    public class SObjectResult 
    {
        @AuraEnabled
        public String recName;
        
        @AuraEnabled
        public Id recId;
        
        public SObjectResult(String recNameTemp, Id recIdTemp) 
        {
            recName = recNameTemp;
            recId = recIdTemp;
        }
    }
}