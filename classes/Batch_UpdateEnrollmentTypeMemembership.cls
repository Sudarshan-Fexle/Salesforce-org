/**
 *	Purpose			:	Batch is used to update populate the Current/Previous/next program Package on the related membership Object.
 *
 *	Created By		:	Dipesh Gupta
 *
 *	Created Date	:	01/27/2020	
 *
 *	Rivision Log	:	V_1.0 - Created - CR-20190718-13214
 *
 **/
global class Batch_UpdateEnrollmentTypeMemembership implements Database.Batchable<sObject>, Database.Stateful {
    
    
    //Debug Log
    global String debugLog;
    public string queryString;
    
    /**
* @description: Get All of our Enrollment Membership Records for the Batch
**/
    global  Database.QueryLocator start(Database.BatchableContext BC) {
        
        Integer currentYear =  (System.now()).Year();
        Integer previousYear = currentYear - 1;
        Integer nextYear =  currentYear + 1;
        
        Set<String> setOfYear = new Set<String>{String.valueOf(currentYear), String.valueOf(previousYear), String.valueOf(nextYear)};
            
            if (queryString == null)
            queryString = 'SELECT Id, Membership__c, Total_Adjusted_Contracted_Cost__c, Account_Status__c, Client_Status_New__c, Fiscal_Year__c FROM Program_Package__c WHERE Fiscal_Year__c IN : setOfYear AND Membership__r.RecordType.DeveloperName = \'Enrollment\'';
        return Database.getQueryLocator(queryString);
    }
    
    /**
* @description: Update the Current/Previous/next program Package on the related membership Object.
**/
    global void execute(Database.BatchableContext BC, list<sObject> sc) {
        
        //Initializing list
        List<Program_Package__c> programPackages = (List<Program_Package__c>) sc;
        
        if(programPackages.size() > 0){
            try
            {
                //Calling mehtod which update Current/Previous/Next program Package on the related membership Object.
                ProgramPackageRoyallTriggerHelper.updateProgramPackageOnMembership(programPackages, null);
                debugLog = 'Hi' + '<br>' + 'Your records are updated successfully' + '<br>'+ '<br>' +'Thanks!'; 
            }
            catch(Exception e)
            {
                //create log message 
                debugLog = 'Hi' + '<br>' + 'Your records are not updated because for following below reason :-' + '<br>' + e.getMessage() + '<br>' + '<br>' +'Thanks!';
            }            
            
        }
    }
    
    global void finish(Database.BatchableContext BC) 
    {
        //Checking logMessage  string for blank value but if it does not have blank value with it then emailed it to SFAdmin.
        if(debugLog != '') 
            Util.sendBatchStatus(bc.getJobId(), 'Batch_UpdateEnrollmentTypeMemembership', debugLog, Label.Salesforce_Admin_Email);	
    }
}