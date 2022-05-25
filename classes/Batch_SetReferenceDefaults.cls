/**
*  Description     :    Batch class to update few fields on Reference records(Dedicated_Advisor__c, NASA_Principal__c, NASA_Associate_Principal__c) 
*
*  Created By      :    Rajeev Jain      
* 
*  Created Date    :    09/05/2016   
* 
*  Revision Logs   :    V_1.0 - Created - Release 53 - CR-20160809-10096 
*                       V_1.1 - Modified By Dipesh Gupta - 10/07/2019 - CR-20190919-13355 - Removed NASA_Associate_Principal__c from query as per requirment 
**/
global class Batch_SetReferenceDefaults implements Database.Batchable<SObject>, Database.Stateful {
    
    //Debug Log
    global String debugLog;
    public String queryStr = null;
    
    //Batch Constructor
    global Batch_SetReferenceDefaults() {
        
        //Inititlize debug Log
        debugLog = '';
        
        //Checking for the null value and accordingly setting the defaults
        if(queryStr == null) {
            //Modified By Dipesh Gupta - 10/07/2019 - CR-20190919-13355 - Removed NASA_Associate_Principal__c from query as per requirment 
			//Constructing query string for fetching records from the database
            queryStr = 'SELECT Id, Membership__c, Dedicated_Advisor__c, RecordTypeId, Reference_Module__c, Reference_Lead__c,' +
            			' Member_Type__c, Contact_Name__c, Institution__c, NASA_Principal__c ' +
						' FROM Reference__c WHERE' +
                		' (Reference_Status__c = \'Pending Approval\' OR Reference_Status__c = \'Scheduled\' OR Reference_Status__c = \'Vetted\')';     
            
            //Debugging for the query string
            System.debug('@@@@ Query string in constructor ' + queryStr);
        }            
    }
    
    // Start(Database.BatchableContext) method of the Database.Batchable class
    global Database.queryLocator start(Database.BatchableContext ctx) {
                         
        //Debug log helpful in analysis
        System.debug('******** Batch Process for Reference Updates Started ******* ');
        
        //Query all reference records which are in specific status
        return Database.getQueryLocator(queryStr);       
    }
    
    // Execute(Database.BatchableContext, list<Sobject>) method of the Database.Batchable class
    global void execute(Database.BatchableContext ctx, list<Sobject> scope){
        
        try{
            
            //List to Hold the Reference Request Records which are needs to update
            List<Reference__c> referenceRequests = new List<Reference__c>();
            
            //String variable to hold the error message string in case of any failure
            String logMessage = '';
            
            //Call the Reference Trigger Helper class method
            ReferenceTriggerHelper.setReferenceDefaults((List<Reference__c>)scope);
            
            //Set to hold the contact records IDs associated to reference record via "Contact Name"
            Set<Id> setContactsIds = new Set<Id>();
            
            //Now check if specific fields are not null then update those records
            //Loop over references
            for(Reference__c ref : (List<Reference__c>)scope) {
                referenceRequests.add(ref);
                if(ref.Contact_Name__c != null)
                	setContactsIds.add(ref.Contact_Name__c);
            }
                
            //Check the size of the list 
            if(referenceRequests.size() > 0) {
                
                //ByPass All Triggers
                Util.byPassAllTriggers = true;
                
                //Error recording and updating records
                logMessage = Util.createLog(Database.update(referenceRequests, false));
                
                //Enabling triggers
                Util.byPassAllTriggers = false;
                
                //Checking set for it's size
                if(setContactsIds.size() > 0) {
                    
                    //List of reference request contacts to be updated
                    List<Reference_Request_Contact__c> listOfReferenceRequestContacts = new List<Reference_Request_Contact__c>(); 
                    
                    //Retrieving "Reference Request Contact" records associated with current scope based reference records
                    for(Reference_Request_Contact__c rrC : [SELECT ID, Reference_Contact__c, Reference_Modules__c, Approver__c 
                                                            FROM Reference_Request_Contact__c
                                                            WHERE Reference_Contact__c != null
                                                            AND Reference_Contact__c IN : setContactsIds
                                                           ]) {
                    	listOfReferenceRequestContacts.add(rrC);                                           
                    }
                    
                    //Checking list for it's size
                    if(listOfReferenceRequestContacts.size() > 0) {
                        
                        //ByPass All Triggers
                		Util.byPassAllTriggers = true;
                        
                        //Populating "approver" field value on the list based RRC records
                        ReferenceRequestContactHelper.populateApprover(listOfReferenceRequestContacts);
                        
                        //Error recording and updating records
                        logMessage += Util.createLog(Database.update(listOfReferenceRequestContacts, false));
                        
                        //Checking errors log messages string for blank value and append 
                        //it to final error message string only and only if it have proper value with it
                        if(logMessage != '') 
                            debugLog += logMessage;
                        
                        //Enabling triggers
                		Util.byPassAllTriggers = false;
                    }
                }
            }
        }catch(Exception e){
            debugLog += e + '';
        }
    }
    
    //Handles errors if found any
    global void finish(Database.BatchableContext ctx) {
        
        //Debug log helpful in analysis
        System.debug('******** Batch Process for Reference Updates Completed ******* ');
        
        //Create final email message
        if(debugLog != '') {
            
            //Send log to admin
            Util.sendBatchStatus(ctx.getJobId(), 'Batch_SetReferenceDefaults', debugLog, Label.Salesforce_Admin_Email);
        }
    }
}