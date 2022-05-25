/**
*  Description     :    Schedule class to blank update the ABC revenue records, to execute the DLRS operations.  
*
*  Created By      :    Mahendra Swarnkar
* 
*  Created Date    :    02/06/2020   
* 
*  Revision Logs   :    V_1.0 - Created - CR-20200123-13654
*                      
**/
global class Sched_ABCRevenueUpdateForDLRS implements Schedulable, Database.Batchable<sObject> {
    
    public static Boolean EXECUTE_ABC_REVENUE_TRIGGER = false;
    public List<Id> recordIds;
    public Integer batchSize = 200;
    
    public List<ABC_Revenue__c> listABCRevenueToUpdate;
    
    public Sched_ABCRevenueUpdateForDLRS() {}
    
    public Sched_ABCRevenueUpdateForDLRS(List<ABC_Revenue__c> listABCRevenue) {
        
        recordIds = new List<Id>();
        for (ABC_Revenue__c rev : listABCRevenue) recordIds.add(rev.Id);
     }
    
    //schedulable logic to start the batch job
    global void execute(SchedulableContext ctx){
        Sched_ABCRevenueUpdateForDLRS b = new Sched_ABCRevenueUpdateForDLRS();
        b.recordIds = recordIds;
        database.executeBatch(b, batchSize);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String qryString = 'SELECT Id FROM ABC_Revenue__c WHERE Id IN :recordIds ORDER BY Program_Subscription__c ASC, Contract_ABC__c ASC';
        return Database.getQueryLocator(qryString);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> lstSobects) {
        if(lstSobects != null && lstSobects.size() > 0) {
            List<ABC_Revenue__c> revsToUpdate = (List<ABC_Revenue__c>) lstSobects;
            
            //set the flag to true so the shadow fields are updated for DLRS
            Sched_ABCRevenueUpdateForDLRS.EXECUTE_ABC_REVENUE_TRIGGER = true;
            
            //update records - this will update the shadow fields and trigger the DLRS logic to execute
            List<Database.SaveResult> sResults = Database.update(revsToUpdate, false);
            
            //check for records that threw errors so we can retry them
            List<Id> errorIds = new List<Id>();
            for (Database.SaveResult sr : sResults) {
                if (!sr.isSuccess()) {
                    errorIds.add(sr.getId());
                }
            }
            
            //if there were any errors, schedule a job to update those records in a batch size of 1
            if (errorIds.size() > 0) {
                dateTime sysTime = dateTime.now().addMinutes(2);
                String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
                
                Sched_ABCRevenueUpdateForDLRS sched = new Sched_ABCRevenueUpdateForDLRS();
                sched.recordIds = recordIds;
                sched.batchSize = 1;
                System.schedule('Sched_ABCRevenueUpdateForDLRS_secondary' + sysTime.getTime(),chron_exp, sched);
            }
        }
    }
    global void finish(Database.BatchableContext BC) {
        
    }
}