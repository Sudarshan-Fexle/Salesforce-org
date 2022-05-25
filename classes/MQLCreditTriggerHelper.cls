/**
*  Purpose         :  This Class is having all the automation logic method on MQL Credit object.
* 
*  Created By      :  Nikita Kumari
*
*  Created Date    :  02/08/2022
*
*  Revision Logs   :  V_1.0 - Created - CR-20220119-15726
**/
public class MQLCreditTriggerHelper {
    
    /*
     * Purpose		 : This method is used to populate fields on before event 
     * 
     * Revision Logs 	 : V_1.0 - Created - CR-20220119-15726
     */
    public static void populateFieldOnBefore(List<MQL_Credit__c> newMQLCredits, Map<Id, MQL_Credit__c> mapOldMQLCredits)
    {
        //to hold associated event ids
        Map<Id, List<MQL_Credit__c>> mapOfEventIdsWithMQLCreditDetails = new Map<Id, List<MQL_Credit__c>>();
        
        for(MQL_Credit__c mqlCredit : newMQLCredits)
        {            
            //check update and insert case
            if(mapOldMQLCredits == null
               || (mapOldMQLCredits != null 
                   && 
                   (mapOldMQLCredits.get(mqlCredit.Id).MQL_Credit_Date__c != mqlCredit.MQL_Credit_Date__c
                    || mapOldMQLCredits.get(mqlCredit.Id).Credit_Approval__c != mqlCredit.Credit_Approval__c
                    || mapOldMQLCredits.get(mqlCredit.Id).Event_ID__c != mqlCredit.Event_ID__c
                    )
                  )
                )
            {
                
                if(String.isBlank(mqlCredit.Event_ID__c)){
                    mqlCredit.Credit_Approval__c = 'Pending';
                    mqlCredit.MQL_Credit_Date__c = null;
                }else{
                    mqlCredit.Credit_Approval__c = 'Approved';
                }
                if(String.isNotBlank(mqlCredit.Event_ID__c)){
                    if(!mapOfEventIdsWithMQLCreditDetails.containsKey(mqlCredit.Event_ID__c))
                    {
                        mapOfEventIdsWithMQLCreditDetails.put(Id.valueOf(mqlCredit.Event_ID__c), new List<MQL_Credit__c>());
                    }
                    mapOfEventIdsWithMQLCreditDetails.get(mqlCredit.Event_ID__c).add(mqlCredit);
                }
            }
        }
        
        //check map size
        if(mapOfEventIdsWithMQLCreditDetails.size() > 0 && mapOfEventIdsWithMQLCreditDetails.keySet().size() > 0)
        {
            for(Event evnt : [Select Id, StartDateTime, Cancelled_Did_Not_Occur__c From Event Where StartDateTime != null and Id IN :mapOfEventIdsWithMQLCreditDetails.keySet()])
            {
                if(mapOfEventIdsWithMQLCreditDetails.containsKey(evnt.Id))
                {
                    for(MQL_Credit__c mqlCredit :mapOfEventIdsWithMQLCreditDetails.get(evnt.Id))
                    {
                        if(evnt.Cancelled_Did_Not_Occur__c){
                            mqlCredit.Credit_Approval__c = 'Pending';
                        }
                        mqlCredit.MQL_Credit_Date__c = Date.valueOf(evnt.StartDateTime);
                    }
                }
            }
        }
    }
    
    /*
     * Purpose		 : This method is used to identify the related event's opp RT and If condition didn't match then will throw an error on rec update and create
     * 
     * Revision Logs     : V_1.0 - Created - CR-20220119-15726
     */
    public static void checkEventRelatedOppRT(List<MQL_Credit__c> newMQLCredits, Map<Id, MQL_Credit__c> mapOldMQLCredits)
    {
        //to hold associated event ids
        Map<Id, List<MQL_Credit__c>> mapOfEventIdsWithMQLCreditDetails = new Map<Id, List<MQL_Credit__c>>();
        
        for(MQL_Credit__c mqlCredit : newMQLCredits)
        {            
            //check update and insert case
            if(String.isNotBlank(mqlCredit.Event_ID__c) && (mapOldMQLCredits == null 
                                                  || (mapOldMQLCredits != null 
                                                      && mapOldMQLCredits.get(mqlCredit.Id).Event_ID__c != mqlCredit.Event_ID__c))
              )
            {
                if(!mapOfEventIdsWithMQLCreditDetails.containsKey(mqlCredit.Event_ID__c))
                {
                    mapOfEventIdsWithMQLCreditDetails.put(Id.valueOf(mqlCredit.Event_ID__c), new List<MQL_Credit__c>());
                }
                mapOfEventIdsWithMQLCreditDetails.get(mqlCredit.Event_ID__c).add(mqlCredit);
            }
        }
        
        //check map size
        if(mapOfEventIdsWithMQLCreditDetails.size() > 0 && mapOfEventIdsWithMQLCreditDetails.keySet().size() > 0)
        {
            Map<Id, Set<Id>> mapOfOppIdWithEventIds = new Map<Id, Set<Id>>();
            //set of event ids for which we need to skip creation/update on MQL Credit
            Set<Id> setOfEventIdsToSkip = new Set<Id>();
            
            for(Event evnt : [Select Id, WhatId From Event Where WhatId != null and Id IN :mapOfEventIdsWithMQLCreditDetails.keySet()])
            {
                if(String.valueOf(evnt.WhatId).startsWithIgnoreCase(Constants.OPPORTUNITY_REC_ID_PREFIX))
                {
                    if(!mapOfOppIdWithEventIds.containsKey(evnt.WhatId))
                    {
                        mapOfOppIdWithEventIds.put(evnt.WhatId, new Set<Id>());
                    }
                    mapOfOppIdWithEventIds.get(evnt.WhatId).add(evnt.Id);
                }
                else{
                    setOfEventIdsToSkip.add(evnt.Id);
                }
            }
            
            if(mapOfOppIdWithEventIds.size() > 0 && mapOfOppIdWithEventIds.keySet().size() > 0)
            {
                for(Opportunity opp : [Select Id,Name From Opportunity 
                                       Where Id IN :mapOfOppIdWithEventIds.keySet() 
                                       AND RecordTypeId != null AND RecordType.DeveloperName NOT IN: Constants.OPPORTUNITY_RT_DEV_NAME_FOR_ADD_MQL_CREDIT_REC])
                {
                    if(mapOfOppIdWithEventIds.containsKey(opp.Id)){
                        setOfEventIdsToSkip.addALL(mapOfOppIdWithEventIds.get(opp.Id));
                    }
                }
            }
            
            if(setOfEventIdsToSkip.size() > 0)
            {
                for(Id eventId : mapOfEventIdsWithMQLCreditDetails.keySet())
                {
                    if(setOfEventIdsToSkip.contains(eventId))
                    {
                        for(MQL_Credit__c mqlCred : mapOfEventIdsWithMQLCreditDetails.get(eventId))
                        {
                            mqlCred.addError(System.Label.MQL_Credit_Opp_Error_Msg);
                        }
                    }
                }
            }
        }
    }
}