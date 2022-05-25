/**
 *  Description     :  Batch job to check for approved docs in SpringCM.  If a SpringCM record has been approved, download the Word+PDF versions and replace them in Salesforce
 *
 *  Created By      :  Victor Hanson
 *
 *  Created Date    :  06/09/2017
 *
 *  Revision Logs   :   V1.0 - Created - 06/09/2017 - Victor Hanson
 * 						V1.1 - Modified - 12/11/2017 - Victor Hanson - Issue--CR11831--QA--00007557 - Fixed a bug where Proposals weren't being updated when redlines were denied
 **/
global class Batch_SpringCMDocStatus implements Database.Batchable<SObject>, Schedulable, Database.AllowsCallouts, Database.Stateful  {
	
    global string debugLog = '';
    global string query;
    /**
	 *	@description	:	Querylocator to query proposals pending approval 
	 *						
	 *	@args			:	Database.BatchableContext
	 *
	 *	@return			:	database.querylocator
	 *
	 *	@revision Log	:	V_1.0 - 06/09/2017 - Created - Victor Hanson 
	 *
	 **/
    global database.querylocator start(Database.BatchableContext BC)
    {
        if (Query == null)
        {
            Query = 'Select Id, Name, External_Document_GUID__c, SBQQ__DocumentStatus__c, LOA_Word_Document_ID__c, LOA_PDF_Document_ID__c, LOA_Document_Version__c, Redlines_Approved_Date__c'
                + ' from SBQQ__Quote__c where SBQQ__DocumentStatus__c = \'' + Label.Redlines_Pending_Approval + '\'';
        }
        
        return Database.getQueryLocator(query);
    }
	
    /**
	 *	@description	:	Execute method
	 *						
	 *	@args			:	Database.BatchableContext, list<sObject>
	 *
	 *	@return			:	void
	 *
	 *	@revision Log	:	V_1.0 - 06/09/2017 - Created - Victor Hanson 
	 *
	 **/
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        List<SBQQ__Quote__c> proposals = (list<SBQQ__Quote__c>)scope;
        list<SBQQ__Quote__c> proposalsToUpdate = new list<SBQQ__Quote__c>();
        list<ContentVersion> contentVersionsToInsert = new list<ContentVersion>();
        
        try {
            
            //instantiate SpringCMHelper
            SpringCMHelper helper = new SpringCMHelper(proposals[0].Id);
            
            //loop through proposals
            for (SBQQ__Quote__c proposal : proposals) {
                
                //callout to springCM to get the value from the Status field for this document
                helper.proposalId = proposal.Id;
                helper.documentGUID = proposal.External_Document_GUID__c;
                string status;
                
                if(!Test.isRunningTest())
                	status = helper.getDocumentStatus();
                else
                    status = Label.SpringCM_Approved_Status;
                
                //if the "Status" field in SpringCM has been updated to Approved,
                // and update DocStatus on Proposal and replace Word/PDF version of documents
                if (status.equalsIgnoreCase(Label.SpringCM_Approved_Status) && 
                    proposal.SBQQ__DocumentStatus__c != Label.Redlines_Approved) 
                {
                    
                    //update the document status and LOA Document Version
                    proposal.SBQQ__DocumentStatus__c = Label.Redlines_Approved;
                    proposal.Redlines_Approved_Date__c = Date.today();
                    integer intVersion = integer.valueOf(proposal.LOA_Document_Version__c)+1;
                    proposal.LOA_Document_Version__c = String.valueOf(intVersion);
                    proposalsToUpdate.add(proposal);
                    
                    //replace Word version of documents with the redlined version from SpringCM
                    contentVersionsToInsert.add(
                        helper.createContentVersion(proposal, 'docx')
                    );
                    
                    //replace PDF version of documents with the redlined version from SpringCM
                    contentVersionsToInsert.add(
                        helper.createContentVersion(proposal, 'pdf')
                    );
                    
                    //begin the document comparison process
                    helper.startSpringCMWorkflow_CompareDocs();
                }
                else if (status.equalsIgnoreCase(Label.SpringCM_Denied_Status) && proposal.SBQQ__DocumentStatus__c == Label.Redlines_Pending_Approval) {
                    //update the document status to Redlines Denied
                    proposal.SBQQ__DocumentStatus__c = Label.Redlines_Denied;
                    proposalsToUpdate.add(proposal); //line added - 12/11/2017 - Victor Hanson - Issue--CR11831--QA--00007557
                }
            }
            
            //update proposals
            if (proposalsToUpdate.size() > 0) update proposalsToUpdate;
            if (contentVersionsToInsert.size() > 0) insert contentVersionsToInsert;
            
        }
        catch(Exception e) {
            debugLog += '\r\n' + e.getMessage();
        }
    }
    
    /**
	 *	@description	:	Finish method.  restart the job if there are still proposals pending approval
	 *						
	 *	@args			:	Database.BatchableContext
	 *
	 *	@return			:	void
	 *
	 *	@revision Log	:	V_1.0 - 06/09/2017 - Created - Victor Hanson 
	 *
	 **/
    global void finish(Database.BatchableContext BC) {
        
        //Emailing recorded errors details to SFAdmin.
        if(debugLog != '') {
            //Send log to admin
            Util.sendBatchStatus(BC.getJobId(), 'Batch_SpringCMDocStatus', debugLog, Label.Salesforce_Admin_Email);
        }
        
		//check if there are still pending approvals.  If so, reschedule the job
		integer pendingApprovalCount = [SELECT COUNT() FROM SBQQ__Quote__c WHERE SBQQ__DocumentStatus__c = :Label.Redlines_Pending_Approval];
        if (pendingApprovalCount > 0) 
            scheduleSpringCMDocStatusJob();
    }
    
    public void execute(SchedulableContext ctx) {
        // execute the job
        Database.executeBatch(new Batch_SpringCMDocStatus(), 1);
    }
    
	//schedule job
    global static void scheduleSpringCMDocStatusJob() {
        list<AsyncApexJob> springCMJobs = [SELECT Id, ApexClassID, ApexClass.Name FROM AsyncApexJob WHERE ApexClass.Name = 'Batch_SpringCMDocStatus' AND CompletedDate = null];
        if (springCMJobs.size() == 0) {
            
            //scheduleBatch(Database.Batchable batchable, String jobName, Integer minutesFromNow, Integer scopeSize)
            //Schedule the next job, and give it the system time so name is unique
            System.scheduleBatch(new Batch_SpringCMDocStatus(), 'Sched_SpringCMDocStatus' + system.now().getTime(), integer.valueOf(Label.Batch_SpringCMDocStatus_Interval), 1);
        }
    }
}