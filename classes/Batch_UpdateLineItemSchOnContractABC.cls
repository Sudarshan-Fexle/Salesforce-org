/**
*  Description     :   This batch class is run to update Line Item Schedule on Contract ABC object. 
*
*  Created By      :   Shalu Sharma
*
*  Created Date    :   07/09/2021
*
*  Current Version :   v1.0
*       
*  Revision Log    :   V_1.0 Created 
*
**/
global class Batch_UpdateLineItemSchOnContractABC implements Database.Batchable<sObject>, Database.Stateful
{
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        //to hold query
        String query = 'Select Id, Contract__c, Amount__c From Line_Item_Schedule__c Where Contract__c != null And Amount__c != null';
        return Database.getQueryLocator(query); 
            
    }
    
    global void execute(Database.BatchableContext BC,List<Line_Item_Schedule__c> listOfLineItemSchedules) 
    {
        //call trigger helper to roll-up amount from Line Item Schedule to Contract ABC
        if(listOfLineItemSchedules.size() > 0)
            LineItemScheduleTriggerHelper.populateLineItemScheduleTotalOnContractABC(listOfLineItemSchedules, null);

    }
    
    global void finish(Database.BatchableContext BC)
    {  
        Util.sendBatchStatus(BC.getJobId(), 'Batch_UpdateLineItemSchOnContractABC', 'Batch run is completed.', 'nikita.kumari@fexle.com');
    } 
}