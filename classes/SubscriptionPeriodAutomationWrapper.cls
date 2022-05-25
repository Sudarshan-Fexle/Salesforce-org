/**
 *   Purpose         :   This class used to handle Subscription Period Field
 *               
 *   Created By      :   Subhash Garhwal
 *   
 *   Created Date    :   05/24/2017
 *   
 *   Revision Logs   :   V_1.0 - Created
 *                       
 **/
public without sharing class SubscriptionPeriodAutomationWrapper {

	//Field for Subscription Period automation
	Public  List<SBQQ__Subscription__c> componentSubscription;
	Public  SBQQ__Subscription__c programSubscription ;
	Public  Date periodStartDate;
	Public  Date periodEndDate;
	Public  String uniqueKey;
	Public  String subscriptionPeriodType ;
	public  Decimal segmentIndex;
	public String recordType;
	public String stage;
	public String contract;

	public  SubscriptionPeriodAutomationWrapper() {
		componentSubscription = new List<SBQQ__Subscription__c>();
		programSubscription = new SBQQ__Subscription__c();
		SubscriptionPeriodType = '';
	}
}