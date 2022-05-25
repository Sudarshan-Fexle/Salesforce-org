/**
 *  Description     :  Batch executes nightly to update all Membership's field 'Current Period Annual Fee' and 'Current Year Travel Fee' for all active Component Subscription 
 *
 *  Created By      :  Subhash Garhwal
 *
 *  Created Date    :  05/11/2018
 *
 *  Revision Logs   :  V1.1 - Modified By - Subhsah Garhwal - CR-20180504-12213
 * 					   V1.2 - Modified By - Victor Hanson - CR-20191031-13488 - Added Membership_Status_Text__c to the list of fields being queried
 * 
 **/
global class Batch_UpdateCurrentYearFeesOnMembership implements Database.Batchable<sObject>, Database.Stateful {

	//Start method
	global Database.QueryLocator start(Database.BatchableContext BC){
	
		//Set to hod the membership ids
		Set<Id> programSubIds = new Set<Id>();
	
		//Query over the active Subscription Periods
		for(SBQQ__Subscription__c subscription : [Select Id, Program_Subscription__c From SBQQ__Subscription__c  Where Program_Subscription__c != Null AND SBQQ__Product__c != Null 
																AND RecordType.DeveloperName =: CPQConstants.SBQQ_SUBSCRIPTION_RECORD_TYPE_DEVELOPERNAME_COMPONENT 
																AND SBQQ__SegmentStartDate__c <= TODAY AND SBQQ__SegmentEndDate__c >= TODAY]) {
				
			//Add Membership Ids into the set
			programSubIds.add(subscription.Program_Subscription__c);	
		}
        
		//QueryLocator
        return Database.getQueryLocator([Select Id, Active_Subscription__c, Current_Year_Annual_Fee__c, Current_Year_Travel_Fee__c, Current_Period_Start_Date__c, Current_Period_End_Date__c, Membership_Status_Text__c
        								 From Membership__c Where Active_Subscription__c IN : programSubIds]);  
		
    }

	//Execute method
	global void execute(Database.BatchableContext BC, List<Membership__c> memberships){

		//Set to hold the Membership Ids
		Map<Id, Membership__c> mapIdToMembership = new Map<Id, Membership__c>(memberships);
		
		//Null Check
		if(mapIdToMembership != Null)
		
			//Calling method to update the Memberships
			MembershipTriggerHelper.updateCurrentYearFees(mapIdToMembership, null);
		
	}
	
	//Finish Method
	global void finish(Database.BatchableContext BC){}
}