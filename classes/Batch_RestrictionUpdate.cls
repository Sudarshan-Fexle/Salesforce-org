//Modified by - Mahendra Swarnakar - CR-20161102-10332 - 12/20/2016 - Comment out "CRMfusionDBR101.DB_Globals.triggersDisabled" flag
global class Batch_RestrictionUpdate implements Database.Batchable<SObject>, Database.Stateful {
    
    global final String Query;
    global boolean IsDelete = false;
    global String debugLog;
    
    global Batch_RestrictionUpdate(Set<Id> idList){
        
        system.debug('@@Batch_RestrictionUpdate running');
        debugLog = '';
        
        // using IN for dynamic soql requires the following format "('[id1]','[id2]',etc...)"
        String ids = '(';
        
        for (Id i : idList)
            ids += '\'' + i + '\',';
            
        // trim that last comma (,)
        ids = ids.subString(0, ids.length()-1);
        ids += ')';
        
        if (Query == null) {
            Query='SELECT Id, Account__c, Contact__c FROM Restricted_MtM__c WHERE Restriction__c IN ' + ids + ' OR Id IN ' + ids;
        }
    }
     
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator(Query);
    }
    
    global void execute(Database.BatchableContext BC,List<sObject> scope)
    {
        List<Restricted_MtM__c> restrictionMTMs = (List<Restricted_MtM__c>)scope;
        
        if (!IsDelete) {
        
            //simply update the events, the trigger will take care of the processing
            String logMessage = Util.createLog(Database.update((restrictionMTMs),false));
            
            //Checking errors log messages string for blank value and append it to final error message string only and only if it have proper value with it
            if(logMessage != '') 
                debugLog += logMessage;
        }
        
        else {
            
            Set<Id> acctIds = new Set<Id>();
            Set<Id> conIds = new Set<Id>();
            
            for (Restricted_MtM__c rMTM : restrictionMTMs) {
                if (rMTM.Account__c != null) acctIds.add(rMTM.Account__c);
                if (rMTM.Contact__c != null) conIds.add(rMTM.Contact__c);
            }
            
            // get all accounts and contacts associated with this restriction
            List<Account> accts = [SELECT Account_Restriction_Status__c FROM Account WHERE Id IN :acctIds];
            List<Contact> cons = [SELECT Contact_Restriction_Status__c FROM Contact WHERE Id IN :conIds];
            
            // go through each record and remove the restriction status
            for (Account a : accts)
                a.Account_Restriction_Status__c = '';
            for (Contact c : cons)
                c.Contact_Restriction_Status__c = '';
            
            // set flags so we bypass triggers
            Util.IsBatch = true;
            Util.BypassAllTriggers = true;
            //CRMfusionDBR101.DB_Globals.triggersDisabled = true;
            
            //String to hold the log message
            String logMessage = '';
            
            //simply update the events, the trigger will take care of the processing
            if (accts.size() > 0)
                logMessage = Util.createLog(Database.update((accts),false));
            
            //Checking errors log messages string for blank value and append it to final error message string only and only if it have proper value with it
            if(logMessage != '') 
                debugLog += logMessage;
                
            //simply update the events, the trigger will take care of the processing
            if (cons.size() > 0)
                logMessage = Util.createLog(Database.update((cons),false));
            
            //Checking errors log messages string for blank value and append it to final error message string only and only if it have proper value with it
            if(logMessage != '') 
                debugLog += logMessage;
            
            Util.IsBatch = false;
            Util.BypassAllTriggers = false;
            
            // deleting these restriction mtm records will properly update the associated institution/contact
            if (restrictionMTMs.size() > 0)
                logMessage = Util.createLog(Database.delete((restrictionMTMs),false));
            
            //Checking errors log messages string for blank value and append it to final error message string only and only if it have proper value with it
            if(logMessage != '') 
                debugLog += logMessage;
            
            //CRMfusionDBR101.DB_Globals.triggersDisabled = false;
        }
    }
    
    
    global void finish(Database.BatchableContext BC)
    {
        //Checking logMessage  string for blank value but if it does not have blank value with it then emailed it to SFAdmin.
        if(debugLog != '') {
            
            //User Instance
            //Refactored By Doug Roberts - 08/31/2015 - Remove query for SF user email and change to custom label
            //List<User> sfAdminUser = [Select Email FROM User WHERE Name = 'Salesforce Administrator' AND IsActive = true AND Profile.Name = 'System Administrator' AND Email!= null LIMIT 1];
            
            //Send log to admin
            //if(sfAdminUser.size() > 0)
                Util.sendBatchStatus(BC.getJobId(), 'Batch_MembershipNextActivityDate', debugLog, Label.Salesforce_Admin_Email);
        }
    }
}