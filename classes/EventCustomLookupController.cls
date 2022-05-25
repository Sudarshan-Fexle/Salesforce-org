/**
* 
*  @description    :   This class used to populate the event on Opportunity and ROI object
*
*  @args           :   
*
*  @return         :   void
*
*  @revision Log   :   V1.1 - Created - Dipesh Gupta 
*                      V1.2 - Created - Neha Sharma - CR-20200716-14327 - 10/21/2020 - Search Events related to associated Institution of Opportunity and ROI
* 
**/
public with sharing class EventCustomLookupController {
    
    @AuraEnabled (cacheable=true)
    public static List<RecordsData> fetchRecords( String objectName, String filterField, String searchString, String recId ) {
        List<RecordsData> recordsDataList = new List<RecordsData>();
        String query = '';
        
        if(String.isNotBlank(objectName) && String.isNotBlank(filterField) &&  String.isNotBlank(searchString))
        {
            
            try {
                String additionalFieldsForDetails = '';
                //Modified by - Neha Sharma - CR-20200716-14327 - 10/23/2020 - Search Events related to associated Institution of Opportunity and ROI
                Id accountId;
                
                if(String.isNotBlank(recId))
                    accountId = [Select Membership__r.Account_Name__c From Opportunity_and_ROI__c Where Id =:recId]?.Membership__r.Account_Name__c;
                
                if(objectName == 'EVENT')
                    additionalFieldsForDetails = ', ActivityDate, Who.Name';
                
                Set<Id> listOfFilterByRecordTypeId = new Set<Id>{constants.RECORD_TYPE_ID_SYNDICATED_RESEARCH,constants.RECORD_TYPE_ID_MEMBER_SUCCESS};
                    
                    if(String.isNotBlank(accountId))
                    query = 'SELECT Id,'+ filterField + additionalFieldsForDetails + ',RecordTypeId FROM '+ objectName+ ' WHERE '+ filterField + ' LIKE '+ '\'%' + String.escapeSingleQuotes(searchString.trim()) + '%\'' + 'AND  RecordTypeId IN: listOfFilterByRecordTypeId And WhatId =\''+accountId+'\'';
                
                if(String.isNotBlank(query)){
                    for(SObject s : Database.query(query)){
           
                        RecordsData recordsData = new RecordsData();
                        recordsData.value = String.valueOf(s.get('id'));
                        recordsData.label = String.valueOf(s.get(filterField)); 
                        if(objectName == 'EVENT') {
                            if(s.getSobject('who') != null && s.get('ActivityDate') != null) {
                                recordsData.details =  (String) s.getSobject('who').get('Name') + ' - ' +   String.valueOf(Date.valueOf(s.get('ActivityDate'))); 
                            }  
                        }	
                        
                        recordsDataList.add(recordsData);
                    } 
                }    
            } catch (Exception err) {
                if ( String.isNotBlank( err.getMessage() ) && err.getMessage().contains( 'error:' ) ) {
                    throw new AuraHandledException(err.getMessage().split('error:')[1].split(':')[0] + '.');
                } else {
                    throw new AuraHandledException(err.getMessage());
                }
            }
            
            return recordsDataList;
        }
        else{
            return null;
        }
        
    }
    
    @AuraEnabled 
    public static void updateOpportunityROI( String recId, String relatedOnsite, String relatedSLInteraction, String relatedCollaborative, String relatedBenchmarkingStudy ) {
        
        Opportunity_and_ROI__c opp = [Select Id From Opportunity_and_ROI__c Where Id = : recId];

        if(String.isNotBlank(relatedSLInteraction))
        {
            opp.Related_SL_Interaction__c = relatedSLInteraction;
        }else{
            opp.Related_SL_Interaction__c ='';
        }
        if(String.isNotBlank(relatedCollaborative))
        {
            opp.Related_Collaborative__c = relatedCollaborative;
        }else{
            opp.Related_Collaborative__c ='';
        }
        if(String.isNotBlank(relatedBenchmarkingStudy))
        {
            opp.Related_Benchmarking_Study__c = relatedBenchmarkingStudy;
        }else{
            opp.Related_Benchmarking_Study__c ='';
        }
        
        try{ 
            update opp;
            
        }catch (Exception err) {
            if ( String.isNotBlank( err.getMessage() ) && err.getMessage().contains( 'error:' ) ) {
                
                throw new AuraHandledException(err.getMessage().split('error:')[1].split(':')[0] + '.');
            } else {
                throw new AuraHandledException(err.getMessage());
            }
        }
    }
    
    @AuraEnabled (cacheable=true)
    public static RecordsData fetchOppRecord( String recId) {
        
        Opportunity_and_ROI__c opp = [Select Id,
                                      //Related_Onsite__c,
                                      Related_SL_Interaction__c,Related_Collaborative__c,Related_Benchmarking_Study__c From Opportunity_and_ROI__c Where Id = : recId];
        Set<String> setOfEventIds = new Set<String>();
        //setOfEventIds.add(opp.Related_Onsite__c);
        setOfEventIds.add(opp.Related_SL_Interaction__c);
        setOfEventIds.add(opp.Related_Collaborative__c);
        setOfEventIds.add(opp.Related_Benchmarking_Study__c);
        Map<Id,Event> mapOfEvent = new Map<Id,Event>([Select Id,Subject From Event Where Id IN : setOfEventIds]);
        
        // wrapper instance
        RecordsData recordsData = new RecordsData();
        
        /* if(opp.Related_Onsite__c != null)
           {
				recordsData.relatedOnsite = opp.Related_Onsite__c;
				recordsData.relatedOnsiteName = mapOfEvent.get(opp.Related_Onsite__c).Subject;
		   }else{
				recordsData.relatedOnsite = '';
				recordsData.relatedOnsiteName = '';
		   }*/
        if(opp.Related_SL_Interaction__c != null)
        {
            recordsData.relatedSLInteraction = opp.Related_SL_Interaction__c;
            recordsData.relatedSLInteractionName = mapOfEvent.get(opp.Related_SL_Interaction__c).Subject;
        }else{
            recordsData.relatedSLInteraction = '';
            recordsData.relatedSLInteractionName = '';
        }
        if(opp.Related_Collaborative__c != null)
        {
            recordsData.relatedCollaborative = opp.Related_Collaborative__c;
            recordsData.relatedCollaborativeName = mapOfEvent.get(opp.Related_Collaborative__c).Subject;
        }else{
            recordsData.relatedCollaborative = '';
            recordsData.relatedCollaborativeName = '';
        }
        if(opp.Related_Benchmarking_Study__c != null)
        {
            recordsData.relatedBenchmarkingStudy = opp.Related_Benchmarking_Study__c;
            recordsData.relatedBenchmarkingStudyName = mapOfEvent.get(opp.Related_Benchmarking_Study__c).Subject;
        }else{
            recordsData.relatedBenchmarkingStudy = '';
            recordsData.relatedBenchmarkingStudyName = '';
        }
        
        if(opp != null){
            return recordsData;
        }else{
            return null;
        }
        
    }
    
    
    public class RecordsData{
        @AuraEnabled public String label {get;set;}
        @AuraEnabled public String details {get; set;}
        @AuraEnabled public String value {get;set;}
        @AuraEnabled public String relatedOnsite {get;set;}
        @AuraEnabled public String relatedOnsiteName {get;set;}
        @AuraEnabled public String relatedSLInteraction {get;set;}
        @AuraEnabled public String relatedSLInteractionName {get;set;}
        @AuraEnabled public String relatedCollaborative {get;set;}
        @AuraEnabled public String relatedCollaborativeName {get;set;}
        @AuraEnabled public String relatedBenchmarkingStudy {get;set;}
        @AuraEnabled public String relatedBenchmarkingStudyName {get;set;}
    }
    
    
}