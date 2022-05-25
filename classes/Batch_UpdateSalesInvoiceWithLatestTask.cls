/**
 *	Purpose			:	Batch is used to Update Latest Activity Details fields on existing Sales Invoice records. 
 *
 *	Created By		:	Dipesh Gupta
 *
 *	Created Date	:	12/31/2019	
 *
 *	Rivision Log	:	V_1.1 - Created
 *
 **/
global class Batch_UpdateSalesInvoiceWithLatestTask implements database.Batchable<sobject>, Database.Stateful {
    
    
    //Debug Log
    global String debugLog;
    
    /**
     * @description: Get All of our Task Records for which are related to Sales Invoice the Batch
     **/
    global database.querylocator start(database.batchableContext bc) {
        
        //Record type id of Finance RT on task object
        Id financeRtId = Util.RecordTypeId('Task', 'Finance');
        
        //Variable to hold from which object we need to fetch task
        String objectName = 'c2g__codaInvoice__c';
        
        //Dynamic query 
        String str = 'SELECT Id, WhatId, ActivityDate, Subject, Grade__c, CallDisposition, Status__c, Next_Steps__c FROM Task WHERE RecordTypeId = \''+financeRtId+'\' AND What.Type =  \''+objectName+'\'  ORDER BY CreatedDate DESC';
        System.debug('List Data--->>'+str);
        
        return database.getquerylocator(str);
    }

     /**
     * @description: Update the Sales invoice records 
     **/
    global void execute(database.batchablecontext bd, list<Task> tasks) {

       if(!tasks.IsEmpty()){
            
            //List of Sales Invoice to be update
            List<c2g__codaInvoice__c> salesInvoiceToBeUpdate = new List<c2g__codaInvoice__c>();
            
            //Map of Sales Invoice with related list of Task
            Map<Id, List<Task>> mapOfSalesInvoiceWithTasks  = new Map<Id, List<Task>>(); 
            
            //Loop over Task
            for(Task t : tasks){

                //Contains check and putting values into Map
                if(!mapOfSalesInvoiceWithTasks.containsKey(t.WhatId))
                    MapOfSalesInvoiceWithTasks.put(t.WhatId, new List<Task>());
                
                mapOfSalesInvoiceWithTasks.get(t.WhatId).add(t);
            }
            
            //Empty check on Map
            if(!mapOfSalesInvoiceWithTasks.IsEmpty()){
                
                //Loop Over key Set 
                for(Id salesInvoiceId : MapOfSalesInvoiceWithTasks.KeySet()){
                    
                    //Taking instance of Sales Invoice Object
                    c2g__codaInvoice__c salesInvoice = new c2g__codaInvoice__c();
                    
                    salesInvoice.Id	= salesInvoiceId;
                    salesInvoice.Last_Follow_Up_Date__c	= mapOfSalesInvoiceWithTasks.get(salesInvoiceId)[0].ActivityDate;
                    salesInvoice.Last_Follow_Up_Note__c	= mapOfSalesInvoiceWithTasks.get(salesInvoiceId)[0].Subject;
                    salesInvoice.Grade__c	= mapOfSalesInvoiceWithTasks.get(salesInvoiceId)[0].Grade__c;
                    salesInvoice.Grading_Notes__c	= mapOfSalesInvoiceWithTasks.get(salesInvoiceId)[0].CallDisposition;
                    salesInvoice.Follow_Up_Status__c	= mapOfSalesInvoiceWithTasks.get(salesInvoiceId)[0].Status__c ;
                    salesInvoice.Follow_Up_Status_Notes__c	= mapOfSalesInvoiceWithTasks.get(salesInvoiceId)[0].Next_Steps__c;
                    
                    //Adding Values into list
                    salesInvoiceToBeUpdate.add(salesInvoice);
                }
                
                //Empty check on list which hase to be update
                if(!salesInvoiceToBeUpdate.IsEmpty()){
                    
                    //Bypassing the triggers.
                    Util.ByPassAllTriggers = true;
                            debugLog += Util.createLog(Database.update(salesInvoiceToBeUpdate , false));
                    util.ByPassAllTriggers = false;
                    
                }
            }
        }

    }

    global void finish(database.batchableContext bc) {
        //Checking logMessage  string for blank value but if it does not have blank value with it then emailed it to SFAdmin.
        if(debugLog != '') 
            Util.sendBatchStatus(bc.getJobId(), 'Batch_UpdateSalesInvoiceWithLatestTask', debugLog, Label.Salesforce_Admin_Email);	
    }
    
}