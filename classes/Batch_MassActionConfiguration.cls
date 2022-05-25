/**
 *  Description     :   Batch Class is used to execute the Mass Action Configuration. 
 * 			This will run on every night. 
 *                      Logic : 
 *                      When Invite List & Mass Action Configuration fields are both populated
                        1) Query for the Mass Action Configuration record where Id = EABEvent.Mass_Action_Configuration__c
                        2) Update the Mass Action Configuration's dca_mass_action__Target_Apex_Script__c with the code below
                        note: when populating the apex script field, replace the following text values:
                        1) Replace CAMPAIGN_ID with the Id of the EABEvent.Invite_List__c campaign
                        2) Replace REPORT_C﻿OLUMN_NAME with the value from the MassActionConfiguration.dca_mass_action__Source_Report_Column_Name__c
 *
 *  Created By      :   Saurabh Kumar
 *
 *  Created Date    :   11/19/2020
 *
 *  Revision Logs   :   V_1.0 - Created - CR-20201117-14698
 *                      
 **/
global class Batch_MassActionConfiguration implements Database.Batchable<sObject>, Database.Stateful  {
    
    //Debug Logs
    global String debugLog;
    public string QueryString;
    
    //Start method to query the EAB Events. 
    global Database.QueryLocator start(Database.BatchableContext BC){
    
        if(QueryString == null) 
            QueryString = 'Select Id, Name, Mass_Action_Configuration__c, Invite_List__c From Advisory_Event__c where Begins__c >= TODAY AND Mass_Action_Configuration__c != null AND Invite_List__c != null';
        if(Test.isRunningTest())
            QueryString += ' LIMIT 1';
        
        return  Database.getQueryLocator(QueryString);
    }
    
    //Execute
    global void execute(Database.BatchableContext BC, List<Advisory_Event__c> eabEvents){
        
        Enqueue_MassActionConfiguration emac;
        for(Advisory_Event__c eabEvent : eabEvents){
            
            emac = new Enqueue_MassActionConfiguration(eabEvent);
            System.enqueueJob(emac);
        }
    }
    
    global void finish(Database.BatchableContext BC){
         
    }
}