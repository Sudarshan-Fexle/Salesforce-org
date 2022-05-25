/**
 *	Purpose			:	Batch is using to update Royall Membership's Status, based on Program Packages.  
 *						Program Packages ending yesterday will update the related Membership with the 'Prospect - Pure status', if there is not a subsequent Active Program Package.
 *						Program Packages with a FY Start Date of today will update the associated Membership with Status of 'Member - Payer'.
 *
 *	Created By		:	Victor Hanson
 *
 *	Created Date	:	03/20/2017	
 *
 *	Rivision Log	:	V_1.1 - Created
 *
 **/
global class Batch_RoyallMembershipUpdate implements database.Batchable<sobject>, Database.Stateful {
    //Debug Log
    global String debugLog;
	public string QueryString;
    
    /**
     * @description: get all program packages starting today or ending yesterday
     **/
    global database.querylocator start(database.batchableContext bc) {
        if (QueryString == null)
            QueryString = 'SELECT Id FROM Program_Package__c WHERE (FY_Start_Date__c = TODAY OR FY_End_Date__c = YESTERDAY)';
        debugLog = '';
        return database.getquerylocator(QueryString);
    }
    
    /**
     * @description: update the program packages, which will trigger an update to related Memberships
     **/
    global void execute(database.batchablecontext bd, list<sobject> sc) {
        list<Program_Package__c> programPackages = (list<Program_Package__c>) sc;
        //Update  Program Package records
        debugLog += Util.createLog(Database.update(programPackages,false));
    }
    
    global void finish(database.batchableContext bc) {
        //Checking logMessage  string for blank value but if it does not have blank value with it then emailed it to SFAdmin.
        if(debugLog != '') 
            Util.sendBatchStatus(bc.getJobId(), 'Batch_RoyallMembershipUpdate', debugLog, Label.Salesforce_Admin_Email);	
    }
    
}