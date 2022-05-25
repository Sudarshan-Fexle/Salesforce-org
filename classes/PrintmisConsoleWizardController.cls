/*
Purpose         :   Controller class for Associated Job Component and Customize Job Component screens. 

Created By      :   Chirag Soni

Created Date    :   10/19/2021

Current Version :   v1.0

Revision Log    :   V_1.0 Created

*/
public with sharing class PrintmisConsoleWizardController 
{
    
    // Method to fetch lookup default value 
    @AuraEnabled
    public static sObject fetchDefaultRecord(string recordId , string sObjectApiName) {
        
        string sRecId = recordId;    
        string sQuery = 'Select Id,Name From ' + sObjectApiName + ' Where Id = : sRecId LIMIT 1';
        for (sObject obj: database.query(sQuery)) {
            return obj;
        }
        return null;
    }
    
    @AuraEnabled(cacheable=true)
    public static list<SObJectLookUpResult> fetchLookupData(string searchKey , string sObjectApiName) {    
        
        String subFieldName = sObjectApiName == 'Production_Tracking__c' ? 'Job_Ticket__r.Name': 'Mail_Vendor__r.Name';
        List<String> subFiledDetails = subFieldName.split('\\.');
        
        List < SObJectLookUpResult > returnList = new List < SObJectLookUpResult > ();
        
        string sWildCardText = '%' + searchKey + '%';
        
        string sQuery = 'Select Id,Name, '+subFieldName+' From ' + sObjectApiName + ' Where Name Like : sWildCardText order by createdDate DESC LIMIT 5';
        for (sObject so: database.query(sQuery)) {
            
            String subField = String.valueof(so.getSobject(subFiledDetails[0])?.get(subFiledDetails[1]));
            String recordName = (String)so.get('Name');
            
            returnList.add(new SObJectLookUpResult(so.Id, recordName, subField));
        }
        return returnList;
    }
    
    @AuraEnabled(cacheable=true)
    public static LightningResponseEntity retrieveProductionTrackingHistory(Id recordId) 
    {
        //to hold response for component
        LightningResponseEntity responseEntity = new LightningResponseEntity();
        String objectName = '';
        if(string.isNotBlank(recordId)){
            objectName = recordId.getSObjectType().getDescribe().getName();
        }
        
        if(string.isNotBlank(objectName)){
            
            if(objectName == 'Job_Ticket__c') // If Job Ticket is selected 
            {
                List<ProductionTrackingRecord> ptList = new List<ProductionTrackingRecord>();
                PrintmisWizardWrapper wrapper;
                
                for (Production_Tracking__c ptRecord : [SELECT Id, Name, Status__c, Status_Detail__c, RecordType.Name, BOX_Folder_Link__c, Drop_Type__c  FROM Production_Tracking__c WHERE Job_Ticket__c = :recordId])
                {
                    ptList.add(new ProductionTrackingRecord(ptRecord));
                }
                if(ptList.size()>0)
                {
                    wrapper = new PrintmisWizardWrapper(null,null, ptList, null);
                    responseEntity.setBody(wrapper);
                    responseEntity.setSuccess(true); 
                }
                else{
                responseEntity.setMessage('No Production Tracking records are found on this job ticket.');
                responseEntity.setSuccess(true);
               }
            }
            
            else if(objectName ==  'Production_Tracking__c') // If production tracking is selected 
            {
                List<PTHistoryWrapper> pTHistoryWrapperList  = new List<PTHistoryWrapper>();
                List<Production_Tracking__History> pTHistoryList = new List<Production_Tracking__History>();
                List<WebServiceLogs> webServiceLogs = new List<WebServiceLogs>();
                List<Artifact__c> artifacts = new List<Artifact__c>();
                PrintmisWizardWrapper wrapper;

                // Get the sObject describe result for the Production Tracking  object
                DescribeSObjectResult sObjectResult = recordId.getSobjectType().getDescribe();
                Map<String, SObjectField> fields = sObjectResult.fields.getMap();
                
                pTHistoryList = [SELECT Id,Createddate,CreatedBy.Name,Field, OldValue,NewValue 
                                 FROM Production_Tracking__History 
                                 WHERE ParentId =: recordId order By createdDate desc];
                if(pTHistoryList.size() > 0){
                    for(Production_Tracking__History pTHistory : pTHistoryList)
                    {
                        PTHistoryWrapper wrap = new PTHistoryWrapper();
                        //wrap.createdDate = string.valueOf(pTHistory.Createddate);
                        wrap.createdDate = (pTHistory.Createddate).format('MM/dd/yyyy HH:mm:ss a');
                        wrap.user = pTHistory.CreatedBy.Name;
                        if(string.isNotBlank(string.valueOf(pTHistory.OldValue))){
                            wrap.action = 'Changed ' +fields.get(pTHistory.Field).getDescribe().getLabel()+ ' from  '+pTHistory.OldValue +' to ' + pTHistory.NewValue;
                        }
                        else{
                            if((pTHistory.Field).contains('locked') || (pTHistory.Field).contains('created'))
                            {
                                 wrap.action = 'Changed ' + pTHistory.Field + ' to ' + pTHistory.NewValue;
                            }
                            else{
                                 wrap.action = 'Changed ' + fields.get(pTHistory.Field).getDescribe().getLabel() + ' to ' + pTHistory.NewValue;
                            }
                               
                            
                        }
                        pTHistoryWrapperList.add(wrap);  
                    }
                }
                
                for(Web_Service_Log__c webSerLog :[Select Id, Name, CreatedDate,URL__c,Job_Ticket__r.Name, Web_Service_Method__c, 
                                                   Production_Tracking__r.Name,Production_Tracking__c,Response_Message__c, 
                                                   Response_Message_Log__c, Direction__c   
                                                   FROM Web_Service_Log__c 
                                                   WHERE Production_Tracking__c  =: recordId ])
                {
                    webServiceLogs.add(new WebServiceLogs(webSerLog));
                }
                for(Artifact__c artifact : [Select Id,Name, Status__c, Source__c, Target__c, CreatedDate, (SELECT Id, Name, Status__c,Direction__c, CreatedDate 
                                                                                                FROM Artifact_Transfers__r) 
                                            from artifact__c 
                                            where Production_Tracking__c =: recordId])
                {
                    artifacts.add(artifact);
                }
                if(webServiceLogs.size() > 0 && pTHistoryWrapperList.size() >0 && artifacts.size() > 0) // if all records exist
                {
                    wrapper = new PrintmisWizardWrapper(pTHistoryWrapperList,webServiceLogs, null, artifacts);
                    responseEntity.setBody(wrapper);
                    responseEntity.setSuccess(true);   
                }
                else if(webServiceLogs.size() == 0 && pTHistoryList.size() == 0 && artifacts.size() == 0)  
                {
                    responseEntity.setMessage('No record(s) to display.');
                    responseEntity.setSuccess(true);
                }
                else
                {
                    wrapper = new PrintmisWizardWrapper(pTHistoryWrapperList,webServiceLogs, null, artifacts);
                    responseEntity.setBody(wrapper);
                    responseEntity.setMessage('No record(s) to display.');
                    responseEntity.setSuccess(true); 
                }
            }
        }
        return responseEntity; 
    }
    
    
    // wrapper for production tracking history records 
    public class PTHistoryWrapper{
        @AuraEnabled public string createdDate {get;set;}
        @AuraEnabled public string user {get;set;}
        @AuraEnabled public string action {get;set;}
    }
    
    // wrapper for production tracking records
    public class ProductionTrackingRecord{
        @AuraEnabled public production_Tracking__c ptTracking {get;set;}
        
        public ProductionTrackingRecord(production_Tracking__c ptTracking)
        {
            this.ptTracking = ptTracking; 
        }
    }
    
    // wrapper for production tracking web service logs records
    public class WebServiceLogs{
        @AuraEnabled public Web_Service_Log__c webSerLog {get;set;}
        
        public WebServiceLogs(Web_Service_Log__c webSerLog)
        {
            this.webSerLog =  webSerLog;
        }
    }
    

    
    // Main wrapper for lightning response entity
    public class PrintmisWizardWrapper {
        @AuraEnabled public List<PTHistoryWrapper> PTHistories {get;set;}
        @AuraEnabled public List<WebServiceLogs> webServiceLogs {get;set;}
        @AuraEnabled public List<ProductionTrackingRecord> productionTrackingRecord {get;set;}
        @AuraEnabled public List<Artifact__c> artifacts {get;set;}
        
        public PrintmisWizardWrapper(List<PTHistoryWrapper> PTHistories,List<WebServiceLogs> webServiceLogs, 
                                     List <ProductionTrackingRecord> productionTrackingRecord, List<Artifact__c> artifacts)
        {
            this.PTHistories = PTHistories;
            this.webServiceLogs = webServiceLogs;
            this.productionTrackingRecord = productionTrackingRecord;
            this.artifacts = artifacts;
        }
    }
    
    
    
/*
*	Purpose         :   Custom Wrapper class dynamic record details 
*
*	Revision Log    :   V_1.0 Created - Chirag Soni
*/
    
    // Wrapper to lookup results - used in printmis custom lookup lwc component 
    public class SObJectLookUpResult 
    {
        @AuraEnabled
        public String recordName {get; set;}
        
        @AuraEnabled
        public Id recordId {get; set;}
        
        @AuraEnabled
        public String subField {get; set;}
        
        public SObJectLookUpResult( Id recordIdTemp, String recordNameTemp, String  subFieldTemp) 
        {
            recordName = recordNameTemp;
            recordId = recordIdTemp;
            subField = subFieldTemp;
            
        }
    }
    
}