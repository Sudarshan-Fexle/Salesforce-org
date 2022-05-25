/*
Purpose         :   Batch to for update the subscription period youvisit package value from CPQ subscription.

Created By      :   Neha Sharma

Created Date    :   10/19/2020

Current Version :   v1.0

Revision Log    :   V_1.0 - Created - CR-20200910-14498 - 10/19/2020
                :   V_1.1 - Modified by - Neha Sharma - CR-20210105-14771 - 05/21/2021 - Update Virtual Tour Package Type Lookup
*/
global class Batch_UpdateYouVisitPackageTypeSP implements Database.Batchable<sObject> 
{
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        //Modified by - Neha Sharma - CR-20210105-14771 - 05/21/2021 - And Subscription_Period__c != null
        String query = ' Select Id, You_Visit_Package_Type_m__c, Subscription_Period__c, SBQQ__SegmentIndex__c,Program_Subscription__c,'+
            ' Program_Subscription__r.You_Visit_Package_Type_m__c From SBQQ__Subscription__c'+
            ' Where SBQQ__ProductName__c = \'Program Costs\' And You_Visit_Package_Type_m__c != null'+
            ' And Program_Subscription__c != null And RecordTypeId = \''+CPQConstants.SUBSCRIPTION_RT_ID_COMPONENT+'\' order by Program_Subscription__c,SBQQ__SegmentIndex__c Desc';
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<SBQQ__Subscription__c> subscriptionList) 
    {
        
        //Modified by - Neha Sharma - CR-20210105-14771 - 05/21/2021 - List of Program Subscription to be updated
        //to hold program subscriptions that going to be updated
        Map<Id, SBQQ__Subscription__c> mapOfProgSubscriptionToBeUpdate = new Map<Id,SBQQ__Subscription__c>();
        //to hold subscription periods that going to be updated
        List<Subscription_Period__c> subscriptionPeriodToBeUpdate = new List<Subscription_Period__c>();
        
        for(SBQQ__Subscription__c sub : subscriptionList) {
            
            //Added by - Neha Sharma - CR-20210105-14771 - 05/21/2021 - Update Virtual Tour Package Type Lookup
            //check component record type and product
            
            //check segment index then assign You Visit Package value
            if(!mapOfProgSubscriptionToBeUpdate.containsKey(sub.Program_Subscription__c) && sub.Program_Subscription__r.You_Visit_Package_Type_m__c == null){
                mapOfProgSubscriptionToBeUpdate.put(sub.Program_Subscription__c,new SBQQ__Subscription__c(Id = sub.Program_Subscription__c, You_Visit_Package_Type_m__c = sub.You_Visit_Package_Type_m__c));
                  
            }
        }
        
        //check list size before update
        if(mapOfProgSubscriptionToBeUpdate.size() > 0 && mapOfProgSubscriptionToBeUpdate.values().size() > 0){
            //Bypassing triggers
            Util.byPassAllTriggers = true;
            Update mapOfProgSubscriptionToBeUpdate.values();
            Util.byPassAllTriggers = false;
        
            
            //get releated subscription periods of Program Subscription
            for(Subscription_Period__c subPeriod : [Select Id, Program_Subscription__c, Program_Subscription__r.You_Visit_Package_Type_m__c,YouVisit_Package_Type__c 
                                                    From Subscription_Period__c 
                                                    Where Program_Subscription__c != null And Program_Subscription__c IN: mapOfProgSubscriptionToBeUpdate.keySet()])
            {
                //assign You Visit package Type value                                
                subscriptionPeriodToBeUpdate.add(new Subscription_Period__c(Id = subPeriod.Id, YouVisit_Package_Type__c = subPeriod.Program_Subscription__r.You_Visit_Package_Type_m__c));
            }
            
            //check list size before update
            if(subscriptionPeriodToBeUpdate.size() > 0){
                //Bypassing triggers
                Util.byPassAllTriggers = true;
                Update subscriptionPeriodToBeUpdate;
                Util.byPassAllTriggers = false;
            }
        }
        
    }   
    
    global void finish(Database.BatchableContext BC) 
    {
        
    }
}