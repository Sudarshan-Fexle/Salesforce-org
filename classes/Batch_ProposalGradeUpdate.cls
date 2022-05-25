/**
 *  Purpose         :   Toggle the Execute_Price_Rules__c field on Proposals to trigger recalculation of price rules.
 * 						Proposal Grade is calculated via Price Rules, so this batch is executed when Grade Criteria records are changed.
 *
 *  Created By      :   Victor Hanson
 *
 *  Created Date    :   04/26/2018
 *
 *  Revision Logs   :   V_1.0 - Created
 *
 **/ 
global class Batch_ProposalGradeUpdate  implements Database.Batchable<SObject>, Database.Stateful {
    
    public String DebugLog = '';
    public Integer TotalErrors = 0;
    
    //String variable to hold the entire log message string value
    global String debugLogStr;
    
    global Batch_ProposalGradeUpdate () {
        debugLogStr = '';
    }
    
    //start Method
    global Database.Querylocator start(Database.BatchableContext BC)  {
        
        //return query result
        return Database.getQueryLocator(Label.Batch_ProposalGradeUpdate_Query);
    }

    //Execute method
    global void execute(Database.BatchableContext BC, List<SObject> scope) {
        
        //Loop through scope and change the Execute_Price_Rules__c value, which triggers price rules to fire on the Proposal 
        for(SBQQ__Quote__c proposal : (List<SBQQ__Quote__c>)scope) {
            proposal.Execute_Price_Rules__c = !proposal.Execute_Price_Rules__c;
            
        }   
        
        //update the list of records.  Error messages will be emailed to the SFAdmin 
        string logMessage = Util.createLog(Database.update((scope),false));
        
        //Checking errors log messages string for blank value and append it to final error message string only and only if it have proper value with it
        if(logMessage != '') 
            debugLogStr += logMessage;
    }
    
    //finish method
    global void finish(Database.BatchableContext BC) {
        
        //Checking logMessage  string for blank value but if it does not have blank value with it then emailed it to SFAdmin.
        if(debugLogStr != '')
            Util.sendBatchStatus(BC.getJobId(), 'Batch_UpdateDeploymentStatus', debugLogStr,Label.Salesforce_Admin_Email);
    }
}