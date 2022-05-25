/**
* Description		:	This class used to schedule Batch_Acquia Sync
* 
* Created Date		:	2/9/2022
*
* Revision Log		:	V1.0 - Created - Chirag Soni - 02/9/2022 - CR-20220208-15772
*
* */

public class Schedule_AcquiaSync implements Schedulable,Database.AllowsCallouts{
    
    Map<Id, Advisory_Event__c> mapOfEABEventsToGenerateNewAcquiaSegements;
    Map<Id, Advisory_Event__c> mapOfEABEventsToRegenerateAcquiaCampaigns;
    List<Id> registrationsIds;
    
    public Schedule_AcquiaSync(List<Id> setOfIds){
        this.registrationsIds = setOfIds;
    }
    
    public Schedule_AcquiaSync (Map<Id, Advisory_Event__c> mapOfEABEventsToGenerateNewAcquiaSegements, Map<Id, Advisory_Event__c> mapOfEABEventsToRegenerateAcquiaCampaigns){
        
        this.mapOfEABEventsToGenerateNewAcquiaSegements = mapOfEABEventsToGenerateNewAcquiaSegements;
        this.mapOfEABEventsToRegenerateAcquiaCampaigns = mapOfEABEventsToRegenerateAcquiaCampaigns;
    }
    
    // Execute batch - Batch_AcquiaSync
    public void execute(SchedulableContext context) {
        
        if(registrationsIds != null && registrationsIds.size() > 0)
        {
            List<Id> registrationIdsToResync = new List<Id>();
            List<Id> registrationIdsTosync = new List<Id>();
            
            for(Registration__c reg : [SELECT Id, Acquia_Id__c, LastModifiedDate, Requires_Acquia_Sync__c, EAB_Event__r.Acquia_Segment_Id__c, EAB_Event__r.LastModifiedDate FROM Registration__c WHERE Id IN :registrationsIds])
            {
                DateTime dt =  DateTime.now().addMinutes(-5);
                
                if(reg.EAB_Event__r.Acquia_Segment_Id__c == null && reg.EAB_Event__r.LastModifiedDate > dt){
                    registrationIdsToResync.add(reg.Id);
                }
                else{
                    registrationIdsTosync.add(reg.Id);
                }
                
            }
            
            // reschedule class if acquia segment Id not populated 
            if(registrationIdsToResync.size()>0){
                //create croj exp to schedule after 5 seconds
                DateTime sysTime = dateTime.now().addSeconds(30);
                String cronExpr = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
                //String to hold Apex Job Name
                String apexJobName = 'Registration_AcquiaSync' + ' ' + sysTime+' '+math.random();
                System.schedule(apexJobName, cronExpr, new Schedule_AcquiaSync(registrationIdsToResync));
            }
            // execute batch job when acquia segment Id is created 
            if(registrationIdsTosync.size()>0){
                Database.executeBatch(new Batch_AcquiaSync(registrationIdsTosync), 200); 
            }
        }
        else if((mapOfEABEventsToGenerateNewAcquiaSegements != null && mapOfEABEventsToGenerateNewAcquiaSegements.size() > 0) || 
                (mapOfEABEventsToRegenerateAcquiaCampaigns != null && mapOfEABEventsToRegenerateAcquiaCampaigns.size() > 0))
        {
            Database.executeBatch(new Batch_AcquiaSync(mapOfEABEventsToGenerateNewAcquiaSegements, mapOfEABEventsToRegenerateAcquiaCampaigns), 200); 
        }
        
    }
}