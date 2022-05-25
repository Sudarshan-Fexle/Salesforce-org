/**
*  Description     :    Schedule class to update few fields on Reference records(Dedicated_Advisor__c, NASA_Principal__c, NASA_Associate_Principal__c) 
*                       Calls Batch_SetReferenceDefaults daily on at nigh 9:00 PM EST
*
*  Created By      :    Rajeev Jain      
* 
*  Created Date    :    09/05/2016   
* 
*  Revision Logs   :    V_1.0 - Created - Release 53 - CR-20160809-10096 
*                      
**/
global class Schedule_SetReferenceDefaults implements Schedulable{
    
    global void execute(SchedulableContext ctx){
        
        //Just Instantiate Batch Class
        Batch_SetReferenceDefaults batch = new Batch_SetReferenceDefaults();
        Database.executeBatch(batch, Integer.valueOf(System.Label.Batch_SetReferenceDefaults_SIZE));
    }
}