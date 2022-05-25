/*
Purpose         :   Batch to do the calculation and then update the milestone tracking due dates on production tracking records.

Created By      :   Abhinav Sharma

Created Date    :   07/31/2020

Current Version :   v1.0

Revision Log    :   V_1.0 Created - CR-20200717-14331 - 07/31/2020
*/
global class Batch_UpdateMilestoneTrackingFields implements Database.Batchable<sObject>, Database.Stateful
{    
    global string debuglog = '';
    public String Query = null;
    
    global Batch_UpdateMilestoneTrackingFields() 
    {
        debuglog = '';
        if(Query == null) 
        {
            Query = 'SELECT Parent.Id, Parent.Recordtype.Name, OldValue, NewValue, IsDeleted, Id, Field, CreatedDate, CreatedBy.Name From Production_Tracking__History where (Field =\''+ 'status__c' +'\' or Field =\''+ 'status_detail__c' +'\') ORDER BY CreatedDate ASC';
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
        
        Set<String> proofStatusDetails = new Set<String>{'Submitted','File Received','Pending Approval','Approved'};
        Set<String> liveProofStatusDetails = new Set<String>{'Submitted','File Received','Pending Approval'};
                
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
            for(Production_Tracking__c pTracking : [Select Art_Due_to_Vendor_Date__c, Live_Proof_Approval_Due_Date__c,
                                                    Data_Due_to_Vendor_Date__c, Proof_Approval_Date__c 
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
            DateTime artDueDate;
            DateTime liveProofDate;
            DateTime readyPrintDate;
            if(mapOfStatusPTH.containsKey(pTrackId))
            {  
                for(Production_Tracking__History pTrackHistory : mapOfStatusPTH.get(pTrackId))
                {
                    if((pTrackHistory.NewValue == 'Proof') && isArtVendorUpdated == false && isProofApprovalUpdated == false)
                    {
                        artDueDate =  pTrackHistory.createdDate;
                        isArtVendorUpdated = true;
                        isProofApprovalUpdated =true;
                    }
                    if( pTrackHistory.NewValue == 'Live Proof' && isLiveProofUpdated == false && isDataVendorUpdated == false)
                    {
                        liveProofDate = pTrackHistory.createdDate;
                        isLiveProofUpdated = true;  
                        isDataVendorUpdated = true;
                    }
                    if(pTrackHistory.OldValue == 'Live Proof')
                    {
                        readyPrintDate = pTrackHistory.createdDate;
                    }
                }
            }
            if(mapOfStatusDetailPTH.containsKey(pTrackId))
            {
                for(Production_Tracking__History pTHistory : mapOfStatusDetailPTH.get(pTrackId))
                {
                    String pTNewValue = String.ValueOf(pTHistory.NewValue) != null ? String.ValueOf(pTHistory.NewValue) : '';
                    String pTOldValue = String.ValueOf(pTHistory.OldValue) != null ? String.ValueOf(pTHistory.OldValue) : '';
                    if(artDueDate != null && (proofStatusDetails.contains(pTNewValue) ||  proofStatusDetails.contains(pTOldValue))&& artDueDate <=  pTHistory.createdDate &&  (liveProofDate == null || liveProofDate >  pTHistory.createdDate )  && isArtVendorUpdated == true)
                    {                            
                        isArtVendorUpdated = false;
                        mapOfPTracking.get(pTrackId).Art_Due_to_Vendor_Date__c = Date.valueOf(pTHistory.createdDate);
                    }
                    
                    if(liveProofDate != null && (liveProofStatusDetails.contains(pTNewValue) ||  liveProofStatusDetails.contains(pTOldValue)) && liveProofDate <=  pTHistory.createdDate &&  (readyPrintDate == null || readyPrintDate >  pTHistory.createdDate) && isDataVendorUpdated == true)
                    {
                        isDataVendorUpdated = false;
                        mapOfPTracking.get(pTrackId).Data_Due_to_Vendor_Date__c = Date.valueOf(pTHistory.createdDate);
                    }
                    if(artDueDate != null  && (pTOldValue == 'Approved' || pTNewValue == 'Approved') && artDueDate <=  pTHistory.createdDate &&  (liveProofDate == null || liveProofDate >  pTHistory.createdDate) && isProofApprovalUpdated == true)
                    {
                        mapOfPTracking.get(pTrackId).Proof_Approval_Date__c = Date.valueOf(pTHistory.createdDate);
                        isProofApprovalUpdated = false;
                    }
                    if(liveProofDate != null  && (pTOldValue == 'Pending Approval' ||pTNewValue == 'Pending Approval') && liveProofDate <=  pTHistory.createdDate &&  (readyPrintDate == null || readyPrintDate >  pTHistory.createdDate) && isLiveProofUpdated == true)
                    {
                        mapOfPTracking.get(pTrackId).Live_Proof_Approval_Due_Date__c = Date.valueOf(pTHistory.createdDate);
                        isLiveProofUpdated = false;
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
                Util.sendBatchStatus(ctx.getJobId(), 'Batch_Account_OutreachProgs_v2', debuglog, sfAdminUser[0].Email);
            }
        }
    }
}