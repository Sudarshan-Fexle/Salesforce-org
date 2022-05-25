/*
Purpose         :   Batch to do the calculation and then update the milestone tracking due dates on production tracking records.

Created By      :   Mahendra Swarnkar

Created Date    :   01/05/2021

Current Version :   V_1.0

Revision Log    :   V_1.0 Created - CR-20201204-14725 - 01/05/2021
*/
global class Batch_PopulateProgramCostOnMembership implements Database.Batchable<sObject>, Database.Stateful {

    global string debuglog = '';
        
    global database.querylocator start(database.batchableContext bc) 
    {
        //create query to get all Membership on which Program Cost to be updated
        String query = 'Select Id, Program_Package__r.Membership__c From Royall_Program__c '+
                        'Where Program_Package__c != null AND Program_Package__r.Membership__c != null AND '+
                        'End_Date_CX__c >= Today AND Start_Date_CX__c <= Today AND Program_Cost__c != null '+
                        'AND Program_Package__r.Membership__r.Membership_Status__c Like \'%Member%\'';
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(database.batchablecontext bd, list<Royall_Program__c> royallPrograms) 
    {
        String logMessage = '';
        //set Membership Id
        Set<Id> setMembershipIds = new Set<Id>();
        
        for(Royall_Program__c royallProg : royallPrograms) {
            setMembershipIds.add(royallProg.Program_Package__r.Membership__c);
        }
        
        if(setMembershipIds.size() > 0) {
            
            //Memberships to be update
            List<Membership__c> listMembershipToUpdate = new LIst<Membership__c>();
            
            for(AggregateResult progAggregate : [SELECT SUM(Program_Cost__c) programCost, Program_Package__r.Membership__c membershipId 
                                                 FROM Royall_Program__c 
                                                 WHERE Program_Package__c != null AND Program_Package__r.Membership__c != null
                                                 AND End_Date_CX__c >= Today AND Start_Date_CX__c <= Today 
                                                 AND Program_Package__r.Membership__c IN: setMembershipIds
                                                 GROUP BY Program_Package__r.Membership__c])
            {
                listMembershipToUpdate.add(new Membership__c(Id = (Id)progAggregate.get('membershipId'), 
                                                             CX_Current_Contract_Value__c = (Double)progAggregate.get('programCost')
                                                            ));
                
            }
            
            //check list size before update            
            if(listMembershipToUpdate.size() > 0)
            {
                Util.BypassAllTriggers = true;
                logMessage = Util.createLog(Database.update(listMembershipToUpdate,false));
                Util.BypassAllTriggers = false;
                
                if(logMessage != '') 
                {
                    debuglog += logMessage;
                }
            }
        }
    }     
    
    global void finish(Database.BatchableContext ctx)
    {
        if(debuglog != '') 
        {
            //Send log to user
            //Util.sendBatchStatus(ctx.getJobId(), 'Batch_PopulateProgramCostOnMembership', debuglog, 'emailra');
            
        }
    }
}