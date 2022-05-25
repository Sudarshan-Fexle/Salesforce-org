/*
Purpose         :   Batch to do the calculation and then update the SLA tracking dateTime fields on production tracking records using production Tracking history records.

Created By      :   Abhinav Sharma

Created Date    :   09/8/2020

Current Version :   v1.0

Revision Log    :   V_1.0 Created - CR-20200717-14438 - 09/8/2020
                    V_1.1 Modify By - Abhinav Sharma - CR-20201002-14573 - 10/2/2020
*/
global class Batch_SLATrackingHistoricalDataUpdate implements Database.Batchable<sObject>, Database.Stateful
{    
    global string debuglog = '';
    public String Query = null;
    public Set<Id> setOfPTIds = new Set<Id>();
    
    //Modify By - Abhinav Sharma - CR-20201002-14573 - 10/2/2020 Add the constructor to the Batch.So user can also pass quesry and Ids to the batch.
    global Batch_SLATrackingHistoricalDataUpdate(String queryString, set<Id> setOfProductionTrackingIds) 
    {
        debuglog = '';
        
        if(String.isNotBlank(queryString))
        {
            Query = queryString;
            if(setOfProductionTrackingIds.size() > 0)
            {
                setOfPTIds = setOfProductionTrackingIds;
                if(Query.containsIgnoreCase('Where'))
                {
                    Query += ' and Parent.Id IN : setOfPTIds';
                }
                else{
                    Query += 'where Parent.Id IN : setOfPTIds';
                }
            }
            
        }
        
        if(Query == null) 
        {
            Query = 'SELECT Parent.Id, Parent.Recordtype.Name, OldValue, NewValue, IsDeleted, Id, Field, CreatedDate, CreatedBy.Name From Production_Tracking__History where Parent.Recordtype.developerName = \''+ 'Mail_Shop' +'\'and (Field =\''+ 'status__c' +'\' or Field =\''+ 'status_detail__c' +'\')';
        }
    }
    
    global database.querylocator start(database.batchableContext bc) 
    {
        return Database.getQueryLocator(Query);
    }
    
    global void execute(database.batchablecontext bd, list<Production_Tracking__History> pTrackingHistories) 
    {
        String logMessage = '';
        Set<Id> setOfProductionTrackingIds = new Set<Id>();
        Map<Id,Production_Tracking__c> mapOfPTracking = new Map<Id,Production_Tracking__c>();
        Map<Id,List<Production_Tracking__History>> mapOfStatusPTH = new Map<Id,List<Production_Tracking__History>>();
        Map<Id,List<Production_Tracking__History>> mapOfStatusDetailPTH = new Map<Id,List<Production_Tracking__History>>();
  
                for(Production_Tracking__History pTrackHistory : pTrackingHistories)
            {
                if(pTrackHistory.Parent != null) 
                {
                    setOfProductionTrackingIds.add(pTrackHistory.Parent.Id);
                    
                    if(pTrackHistory.Field == 'Status__c')
                    {
                        if(!mapOfStatusPTH.containsKey(pTrackHistory.Parent.Id))
                        {
                            mapOfStatusPTH.put(pTrackHistory.Parent.Id, new List<Production_Tracking__History>{});
                        } 
                        mapOfStatusPTH.get(pTrackHistory.Parent.Id).add(pTrackHistory);
                    }
                    
                    if(pTrackHistory.Field == 'Status_Detail__c')
                    {
                        if(!mapOfStatusDetailPTH.containsKey(pTrackHistory.Parent.Id))
                        {
                            mapOfStatusDetailPTH.put(pTrackHistory.Parent.Id, new List<Production_Tracking__History>{});
                        } 
                        mapOfStatusDetailPTH.get(pTrackHistory.Parent.Id).add(pTrackHistory);
                    }
                }
            }
        
        if(setOfProductionTrackingIds.size() > 0)
        {
            for(Production_Tracking__c pTracking : [Select Proof_File_Received_DateTime__c, Live_Proof_File_Received_DateTime__c,ReadyforPrint_LP_Approval_DateTime__c,
                                                    Proof_Pending_Approval_DateTime__c,Proof_Approved_DateTime__c,Live_Proof_Pending_Approval_DateTime__c
                                                    FROM Production_Tracking__c 
                                                    WHERE Id IN: setOfProductionTrackingIds])
            {
                mapOfPTracking.put(pTracking.Id,pTracking);
            }
        }
        
        for(Id pTrackId : mapOfPTracking.keyset())
        {
            boolean isDataVendorUpdated = false;
            boolean isProofApprovalUpdated = false;
            boolean isArtVendorUpdated = false;
            boolean isLiveProofUpdated = false;
            DateTime proofDateTime ;
            DateTime liveProofDateTime;
            DateTime readyForPrintDateTime;
            DateTime proofStartDateTime;
            DateTime proofEndDateTime;
            if(mapOfStatusPTH.containsKey(pTrackId))
            {  
                for(Production_Tracking__History pTrackHistory : mapOfStatusPTH.get(pTrackId))
                {
                    if(pTrackHistory.NewValue == 'Proof' && (proofDateTime == null || proofDateTime < pTrackHistory.createdDate))
                    {
                        proofDateTime =  pTrackHistory.createdDate;
                    }
                    
                    else if(pTrackHistory.NewValue == 'Live Proof' && (liveProofDateTime == null || liveProofDateTime < pTrackHistory.createdDate))
                    {
                        liveProofDateTime = pTrackHistory.createdDate;
                    }
                    else if(pTrackHistory.OldValue == 'Ready for Print' && (readyForPrintDateTime == null || readyForPrintDateTime < pTrackHistory.CreatedDate))
                    {
                        readyForPrintDateTime = pTrackHistory.createdDate;
                    }
                    
                }
            }
            if(mapOfStatusDetailPTH.containsKey(pTrackId))
            {
                for(Production_Tracking__History pTHistory : mapOfStatusDetailPTH.get(pTrackId))
                {
                    if(pTHistory.NewValue == 'File Received' && pTHistory.CreatedDate >= proofDateTime){
                        if(liveProofDateTime == null || pTHistory.CreatedDate <= liveProofDateTime){
                            mapOfPTracking.get(pTrackId).Proof_File_Received_DateTime__c = pTHistory.CreatedDate;
                        }
                    }
                    if(pTHistory.NewValue == 'File Received' && pTHistory.CreatedDate >= liveProofDateTime ){
                        if(readyForPrintDateTime == null || pTHistory.CreatedDate <= readyForPrintDateTime){
                            mapOfPTracking.get(pTrackId).Live_Proof_File_Received_DateTime__c = pTHistory.CreatedDate;
                        }
                    }
                    if(pTHistory.NewValue == 'Pending Approval' && pTHistory.CreatedDate >= proofDateTime){ 
                        if(liveProofDateTime == null || pTHistory.CreatedDate <= liveProofDateTime){
                            mapOfPTracking.get(pTrackId).Proof_Pending_Approval_DateTime__c = pTHistory.CreatedDate;
                        }
                    }
                    if(pTHistory.NewValue == 'Pending Approval' && pTHistory.CreatedDate >= liveProofDateTime){
                        if(readyForPrintDateTime == null || pTHistory.CreatedDate <= readyForPrintDateTime){
                            mapOfPTracking.get(pTrackId).Live_Proof_File_Received_DateTime__c = pTHistory.CreatedDate;
                        }
                    }
                    if(pTHistory.NewValue == 'Approved' && pTHistory.CreatedDate >= proofDateTime){
                        if(liveProofDateTime == null || pTHistory.CreatedDate <= liveProofDateTime){
                            mapOfPTracking.get(pTrackId).Proof_Approved_DateTime__c = pTHistory.CreatedDate;
                        }
                    }
                    if(pTHistory.NewValue == 'Live Proof Approved' && mapOfPTracking.get(pTrackId).Live_Proof_Pending_Approval_DateTime__c < pTHistory.CreatedDate){
                       mapOfPTracking.get(pTrackId).Live_Proof_Pending_Approval_DateTime__c = pTHistory.CreatedDate; 
                    }
                }
             
            }
        }
        
        if(mapOfPTracking.size() > 0)
        {
            Util.BypassAllTriggers = true;
            logMessage = Util.createLog(Database.update((mapOfPTracking.values()),false));
            Util.BypassAllTriggers = false;
            
            if(logMessage != '') 
            {
                debuglog += logMessage;
            }
        }
    }     
    
    global void finish(Database.BatchableContext ctx)
    {
        if(debuglog != '') 
        {
            List<User> sfAdminUser = [Select Email FROM User WHERE Name = 'Salesforce Administrator' 
                                      AND IsActive = true 
                                      AND Profile.Name = 'System Administrator' 
                                      AND Email != null LIMIT 1];
            
            //Send log to admin
            if(sfAdminUser.size() > 0) 
            {
                Util.sendBatchStatus(ctx.getJobId(), 'Batch_SLATrackingHistoricalDataUpdate', debuglog, sfAdminUser[0].Email);
            }
        }
    }
}