/*
Purpose         :   Batch to do the calculation and then update the milestone tracking due dates on production tracking records.

Created By      :   Abhinav Sharma

Created Date    :   07/31/2020

Current Version :   v1.0

Revision Log    :   V_1.0 Created - CR-20200717-14331 - 07/31/2020
*/
global class Batch_UpdateMilestoneTrackingStatusOnPT implements Database.Batchable<sObject>, Database.Stateful
{    
    global string debuglog = '';
    public String Query = null;
    global Map<Integer,Milestone_Tracking__mdt> mapOfMilestoneTracking = new Map<Integer,Milestone_Tracking__mdt>();
    
    global Batch_UpdateMilestoneTrackingStatusOnPT() 
    {
        debuglog = '';
        for(Milestone_Tracking__mdt milestone : [SELECT Id,Order__c,Due_Date_Label__c,Days__c,Help_Text__c,Status__c,
                                                 Status_Details__c,PT_Due_Date_Field_Name__c 
                                                 FROM Milestone_Tracking__mdt 
                                                 WHERE order__c != null 
                                                 AND Operation_Type__c = 'Component'])
        {
            mapOfMilestoneTracking.put(Integer.valueOf(milestone.order__c), milestone);
        }
        
        
        if(Query == null) 
        {
            Query = 'SELECT Id,Status_Detail__c,status__c,Planned_Mail_Date__c,Art_Due_to_Vendor_Date__c,Live_Proof_Approval_Due_Date__c,Data_Due_to_Vendor_Date__c,Proof_Approval_Date__c FROM Production_Tracking__c WHERE Planned_Mail_Date__c != null AND status__c != \''+'Mailed'+'\'';
        }
    }
    
    global database.querylocator start(database.batchableContext bc) 
    {
        return Database.getQueryLocator(Query);
    }
    
    global void execute(database.batchablecontext bd, list<Production_Tracking__c> pTrackingList) 
    {
        String logMessage = '';
        
        List<Production_Tracking__c> productionTrackingList = PrintmisUtility.checkPTrackingAtRiskOROnTrack(pTrackingList, mapOfMilestoneTracking);
           
        if(productionTrackingList.size() > 0)
        {
            Util.BypassAllTriggers = true;
            logMessage = Util.createLog(Database.update(productionTrackingList,false));
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
                Util.sendBatchStatus(ctx.getJobId(), 'Batch_UpdateMilestoneTrackingStatusOnPT', debuglog, sfAdminUser[0].Email);
            }
        }
    }
}