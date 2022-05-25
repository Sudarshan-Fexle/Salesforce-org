/**
 *  Purpose		:   This trigger is to handle all the pre and post processing operation for Billing schedule line record
 * 
 *  Created By      :   Mahendra Swarnkar
 * 
 *  Created Date    :   01/09/2020
 * 
 *  Current Version	:   V1.0
 * 
 *  Revision Logs       :   V1.0 - Created
 * 			:   V1.1 - Modified - Victor Hanson - 04/23/2020 - CR-20200423-13977 - Added updatePeriodType method
 * 			:   V1.2 - Modified - Mahendra Swarnkar - 10/21/2020 - CR-20200715-14321 - Added populateTypeOnBSP and updateTypeOnBSP method
 *                      :   V1.3 - Modified - Mahendra Swarnkar - 12/08/2020 - CR-20200715-14321 - BSP: Update the logic for how the Type field is populated
 * 
 **/
public class BillingScheduleLineTriggerHelper {
	
    /**
    * 
    * 	@description	:   Added method to populate below fields on Billing Schedule Period
    * 							a) Fiscal Year => 
    * 							   Logic: If all of the Billing Schedule Period's related lines have BSL.Product_Family__c == ‘Enrollment Services’
    * 									  then Fiscal Year = Billing Schedule Line.Related Component Subscription. Related_Subscription_Component__r.Subscription_Period__r.Program_Package__r.Fiscal_Year__c
    * 									  Else	Fiscal Year = Billing_Schedule_Period_Start_Date__c
    *
    *  @args           :   List<Opportunity>, Map<Id, Opportunity>
    *
    *  @return         :   void
    *
    *  @revision Log   :   V1.0 - Created 
    * 
    **/    
   public static void populateFieldsOnBillingSchedulePeriod(List<Billing_Schedule_Line__c> newBillingScheduleLines, Map<Id, Billing_Schedule_Line__c> mapOldBillingScheduleLines) {
       
       //Set to hold the Billing Schedule Periods ids
       Set<Id> setBSPeriodIds = new Set<Id>();
       
       //Loop oveer the billing lines
       for(Billing_Schedule_Line__c bsl : newBillingScheduleLines) {
           
           //check for billing schedule period and pupulate the set
           if(bsl.Billing_Schedule_Period__c != null && (mapOldBillingScheduleLines == null || bsl.Billing_Schedule_Period__c != mapOldBillingScheduleLines.get(bsl.Id).Billing_Schedule_Period__c))
               setBSPeriodIds.add(bsl.Billing_Schedule_Period__c);
       }
       
       //Check for size
       if(setBSPeriodIds.size() > 0){
           
           //Map To hold the Billing Schedule Period Id with Map Product Family with list of billing schedule lines
           Map<Id, Map<String, List<Billing_Schedule_Line__c>>> MapPeriodIdWithMapProdFamilyWithBillingLines = new Map<Id, Map<String, List<Billing_Schedule_Line__c>>>();
           
           //Map To hold the Billing Schedule Period Id with Map Product Family with list of billing schedule lines
           Map<Id, Set<String>> MapPeriodIdWithSetProdFamilies = new Map<Id, Set<String>>();
           
           //Map to hold the Period Id with Fiscal Year for ES
           Map<Id, String> MapPeriodIdWithProgramPackageFiscalYear = new Map<Id, String>();
           
           //Map to hold the Period Id with Fiscal Year for Non-ES
           Map<Id, String> MapPeriodIdWithStartDateYear = new Map<Id, String>();
           
           //Get all the billing schedule lises related to billing schedule periods mentioned in the set setBSPeriodIds
           for(Billing_Schedule_Line__c bsline : [SELECT Id, Product_Family__c, Billing_Schedule_Period__c, Billing_Schedule_Period__r.Billing_Schedule_Period_Start_Date__c, 
                                                      Related_Subscription_Component__c, Related_Subscription_Component__r.Subscription_Period__c,
                                                      Related_Subscription_Component__r.Subscription_Period__r.Program_Package__c, 
                                                      Related_Subscription_Component__r.Subscription_Period__r.Program_Package__r.Fiscal_Year__c 
                                                  FROM Billing_Schedule_Line__c WHERE Billing_Schedule_Period__c IN : setBSPeriodIds]) 
           {
               
               //Pupulate the Map MapPeriodIdWithSetProdFamilies
               if(!MapPeriodIdWithSetProdFamilies.containsKey(bsline.Billing_Schedule_Period__c)) 
                   MapPeriodIdWithSetProdFamilies.put(bsline.Billing_Schedule_Period__c, new Set<String>());
                   
               //Check for product family
               if(String.isNotBlank(bsline.Product_Family__c)) {
                   MapPeriodIdWithSetProdFamilies.get(bsline.Billing_Schedule_Period__c).add(bsline.Product_Family__c);  
               }
               
               //Populate the Map period Id with fiscal Year for Non - ES
               if(!MapPeriodIdWithStartDateYear.containsKey(bsline.Billing_Schedule_Period__c) && bsline.Billing_Schedule_Period__r.Billing_Schedule_Period_Start_Date__c != null)
                   MapPeriodIdWithStartDateYear.put(bsline.Billing_Schedule_Period__c, String.valueOf((bsline.Billing_Schedule_Period__r.Billing_Schedule_Period_Start_Date__c).Year()));
               
               //Populate the Map period Id with fiscal Year for ES
               if(!MapPeriodIdWithProgramPackageFiscalYear.containsKey(bsline.Billing_Schedule_Period__c) 
                      && bsline.Related_Subscription_Component__c != null && bsline.Related_Subscription_Component__r.Subscription_Period__c != null
                     && bsline.Related_Subscription_Component__r.Subscription_Period__r.Program_Package__c != null
                      && bsline.Related_Subscription_Component__r.Subscription_Period__r.Program_Package__r.Fiscal_Year__c != null) {
                   
                   MapPeriodIdWithProgramPackageFiscalYear.put(bsline.Billing_Schedule_Period__c, bsline.Related_Subscription_Component__r.Subscription_Period__r.Program_Package__r.Fiscal_Year__c);   
               }                
           }
           
           //Check for size
           if(MapPeriodIdWithSetProdFamilies.size() > 0) {
               
               //List to hold the Billing Schedule Periods to be update
               List<Billing_Schedule_Period__c> listBillingPeriodsToBeUpdate = new List<Billing_Schedule_Period__c>();
               
               //Loop over all the billing period ids
               for(Id bsPeriodId : MapPeriodIdWithSetProdFamilies.keySet()) {
                   
                   //Billing Schedule Period instance
                   Billing_Schedule_Period__c bsPeriod = new Billing_Schedule_Period__c(Id = bsPeriodId, Fiscal_Year__c = null); 
                   
                   //check for size for the internal map i.e the map for product family with componentSubscriptions
                   if(MapPeriodIdWithSetProdFamilies.get(bsPeriodId) != null && MapPeriodIdWithSetProdFamilies.get(bsPeriodId).size() > 0 ) {
                       
                       //Flag to check for Enrollment Services
                       Boolean IsOnlyEnrollmentServices = true;
                       
                       //Loop over the product Keys
                       for(String productFamily : MapPeriodIdWithSetProdFamilies.get(bsPeriodId)){
                           
                           //Check if any Component relatedd to other Product Family
                           if(productFamily != 'Enrollment Services'){
                               IsOnlyEnrollmentServices = false;
                               break;
                           }
                       }
                       
                       //Check if all the components are belongs to Enrollment Services and then accordingly populate the Fiscal Year on the Billing schedule Periods 
                       if(IsOnlyEnrollmentServices){
                           
                           //Is All ES - then populate the Fiscal Year on the Billing schedule Periods From the related Membership Period
                           if(MapPeriodIdWithProgramPackageFiscalYear.size() > 0 && MapPeriodIdWithProgramPackageFiscalYear.containsKey(bsPeriodId) 
                              && String.isNotBlank(MapPeriodIdWithProgramPackageFiscalYear.get(bsPeriodId))){
                               
                               bsPeriod.Fiscal_Year__c = 'FY' + MapPeriodIdWithProgramPackageFiscalYear.get(bsPeriodId);   
                           }
                       } else {
                           
                           //If there is atlease on Component related Non-ES : then populate the Fiscal Year on the Billing schedule Periods With Period's Start date Year 
                           if(MapPeriodIdWithStartDateYear.size() > 0 && MapPeriodIdWithStartDateYear.containsKey(bsPeriodId) 
                              && String.isNotBlank(MapPeriodIdWithStartDateYear.get(bsPeriodId))) {
                               
                               bsPeriod.Fiscal_Year__c = 'FY' + MapPeriodIdWithStartDateYear.get(bsPeriodId);
                           }
                       }
                       
                       //Populate the List
                       listBillingPeriodsToBeUpdate.add(bsPeriod);
                   }
               }
               
               //Check for size
               if(listBillingPeriodsToBeUpdate.size() > 0) { 
                   
                   //Disable all Triggers
                   Util.BypassAllTriggers = true;
                   
                   update listBillingPeriodsToBeUpdate;
                   
                   //Enable all Triggers
                   Util.BypassAllTriggers = false;
               }
           }
       }
   }
   
   /**
    * 
    * 	@description	:   when a BSL is added, populate the field "PO#" from Billing Schedule Period.
    *
    *  @revision Log   :   V1.0 - 04/23/2020 - Mahendra Swarnkar - Created - CR-20200422-13970
    * 
    **/
   public static void updatePOField(List<Billing_Schedule_Line__c> newBillingScheduleLines) {
       
       //Set of Billing Schedule Periods
       Set<Id> BillingSchedulePeriodIds = new Set<Id>();
       
       //get a list of all Billing Scheduel Periods
       for (Billing_Schedule_Line__c bsl : newBillingScheduleLines) {
           if (bsl.Billing_Schedule_Period__c != null)
               BillingSchedulePeriodIds.add(bsl.Billing_Schedule_Period__c);
       }
       
       if (BillingSchedulePeriodIds.size() > 0) {
           Map<Id, Billing_Schedule_Period__c> mapBillingSchedulePeriods = new Map<Id, Billing_Schedule_Period__c>(
                                       [SELECT Id, PO__c FROM Billing_Schedule_Period__c WHERE Id IN :BillingSchedulePeriodIds]);
           
           if (mapBillingSchedulePeriods.size() > 0) {
               for (Billing_Schedule_Line__c bsl : newBillingScheduleLines) {
                   if (mapBillingSchedulePeriods.containsKey(bsl.Billing_Schedule_Period__c)) {
                       if(String.isNotBlank(mapBillingSchedulePeriods.get(bsl.Billing_Schedule_Period__c).PO__c))
                            bsl.PO__c = mapBillingSchedulePeriods.get(bsl.Billing_Schedule_Period__c).PO__c;
                   }
               }
           }
       }
   }
   
   /**
    * 
    * 	@description	:   when a BSL is added, check if the program subscription has an opt-out.  If so, clear the Type field on the related BSP
    *
    *  @revision Log   :   V1.0 - 04/23/2020 - Victor Hanson - Created
    * 
    **/    
   public static void updatePeriodType(List<Billing_Schedule_Line__c> newBillingScheduleLines) {
       Map<Id, Billing_Schedule_Period__c> mapBSPeriodsToUpdate = new Map<Id, Billing_Schedule_Period__c>();
       Set<Id> componentSubscriptionIds = new Set<Id>();
       
       //get a list of all Component Subscriptions so we can get opt-out details from the program subscription
       for (Billing_Schedule_Line__c bsl : newBillingScheduleLines) {
           if (bsl.Related_Subscription_Component__c != null)
               componentSubscriptionIds.add(bsl.Related_Subscription_Component__c);
       }
       
       if (componentSubscriptionIds.size() > 0) {
           Map<Id, SBQQ__Subscription__c> mapComponentSubscriptionsWithOptOut = new Map<Id, SBQQ__Subscription__c>([SELECT Id, Program_Subscription__r.Opt_Out__c FROM SBQQ__Subscription__c 
                                                                                                                    WHERE Id IN :componentSubscriptionIds AND Program_Subscription__r.Opt_Out__c != null]);
           if (mapComponentSubscriptionsWithOptOut.size() > 0) {
               //loop through each BSL to see if we need to update the BSP
               for (Billing_Schedule_Line__c bsl : newBillingScheduleLines) {
                   //if the subscription has an opt out, clear the Type value on the related billing schedule period
                   if (mapComponentSubscriptionsWithOptOut.containsKey(bsl.Related_Subscription_Component__c)) {
                       mapBSPeriodsToUpdate.put(bsl.Billing_Schedule_Period__c, new Billing_Schedule_Period__c(Id=bsl.Billing_Schedule_Period__c, Type__c = null));
                   }
               }
           }
           
           if (mapBSPeriodsToUpdate.size() > 0) {
               update mapBSPeriodsToUpdate.values();
           }
       }
   }
   
   
   /**
    * 
    * 	@description	:   when a BSL is added, populate the field "PO#" from Billing Schedule Period.
    *
    *  @revision Log   :   V1.0 - 04/24/2020 - Mahendra Swarnkar - Created - CR-20200424-13982
    * 
    **/
   public static void updatBillingSchedulePeriodStartAndEndDate(List<Billing_Schedule_Line__c> newBillingScheduleLines, Map<Id, Billing_Schedule_Line__c> oldMapBillingScheduleLines) {
       
       //Set to hold the Billing schedule period ids
       Set<Id> setBSPIds = new Set<Id>();
       
       //Loop over the new Billing schedule lines
       for(Billing_Schedule_Line__c bsl : newBillingScheduleLines) {
           
           //Check for condition (Insert/update case)
           if(bsl.Billing_Schedule_Period__c != null 
              && (oldMapBillingScheduleLines == null || bsl.Billing_Schedule_Period__c != oldMapBillingScheduleLines.get(bsl.Id).Billing_Schedule_Period__c 
                  || bsl.Related_Subscription_Component__c != oldMapBillingScheduleLines.get(bsl.Id).Related_Subscription_Component__c )){
               setBSPIds.add(bsl.Billing_Schedule_Period__c);
           }
       }
       
       //Check for size
       if(setBSPIds.size() > 0) {
           
           //Set to hold the invoicing arrangement
           Set<String> setInvoiceArrangement = new Set<String>();
           setInvoiceArrangement.add('ES-50-50');
           setInvoiceArrangement.add('ES-75-25');
           
           //<ap to hold the billing schedule periods to be updated
           Map<Id,Billing_Schedule_Period__c> mapBSPtoUpdate = new Map<Id,Billing_Schedule_Period__c>();
           
           //Query over the billing schedule periods and related billing schedule lines where the invoicing arrangements is either 'ES-50-50' OR 'ES-75-25'
           for(Billing_Schedule_Period__c bsp : [SELECT Id, BSP_Invoicing_Arrangement__c, Billing_Schedule_Period_Start_Date__c, Billing_Schedule_Period_End_Date__c, 
                                                  (SELECT Id, Related_Subscription_Component__c, Related_Subscription_Component__r.Subscription_Period__c, 
                                                    Related_Subscription_Component__r.Subscription_Period__r.Period_Start_Date__c, 
                                                    Related_Subscription_Component__r.Subscription_Period__r.Period_End_Date__c 
                                                    FROM Billing_Schedule_Lines__r 
                                                    WHERE Related_Subscription_Component__c != null AND Related_Subscription_Component__r.Subscription_Period__c != null 
                                                    limit 1)
                                                 FROM Billing_Schedule_Period__c 
                                                 WHERE Id IN : setBSPIds AND BSP_Invoicing_Arrangement__c != null 
                                                 AND BSP_Invoicing_Arrangement__c IN :setInvoiceArrangement ])
           {
            
               //Check for related billing schedule lines
               if(bsp.Billing_Schedule_Lines__r != null && bsp.Billing_Schedule_Lines__r.size() > 0){
                   
                   //get the billing schedule line
                   Billing_Schedule_Line__c billingScheduleLine = bsp.Billing_Schedule_Lines__r[0];
                   
                   //Check if the start/end dates on the billing schedule period is not matched with the start/end dates 
                   //on the subscription period related to component subscription on billing schedule line
                   if(billingScheduleLine.Related_Subscription_Component__c != null 
                          && billingScheduleLine.Related_Subscription_Component__r.Subscription_Period__c != null
                       && (bsp.Billing_Schedule_Period_Start_Date__c != billingScheduleLine.Related_Subscription_Component__r.Subscription_Period__r.Period_Start_Date__c 
                           || bsp.Billing_Schedule_Period_End_Date__c != billingScheduleLine.Related_Subscription_Component__r.Subscription_Period__r.Period_End_Date__c)
                   ) {
                      //Update the start/end dates on the billing schedule period from the related subscription period
                      mapBSPtoUpdate.put(bsp.Id, new Billing_Schedule_Period__c(Id = bsp.Id, Billing_Schedule_Period_Start_Date__c = billingScheduleLine.Related_Subscription_Component__r.Subscription_Period__r.Period_Start_Date__c, 
                                                                                  Billing_Schedule_Period_End_Date__c = billingScheduleLine.Related_Subscription_Component__r.Subscription_Period__r.Period_End_Date__c ));
                   }
               }
           }
           
           if(mapBSPtoUpdate.size() > 0 && mapBSPtoUpdate.values() != null && mapBSPtoUpdate.values().size() > 0) {
               Util.BypassAllTriggers = true;
               update mapBSPtoUpdate.values();
               Util.BypassAllTriggers = false;
           }
       }
   }
   
   /**
     * 
     *  @description	:   Added method to validate the Billing schedule Periods
     *
     *  @args		:   List<Billing_Schedule_Line__c>, Map<Id, Billing_Schedule_Line__c>
     *
     *  @return	:   void
     *
     *  @revision Log	:   V1.1 - Created - 06/15/2020 - Mahendra Swarnkar - CR-20200605-14143 - Before delete validate that Sales_Credit_Note and Sales_Invoice is not tag on BSP. 
     * 
   **/
   public static void validateBSLs(List<Billing_Schedule_Line__c> newBSLList, Map<Id, Billing_Schedule_Line__c> mapOldBSLs) {
       
       set<Id> setOfBSP = new set<Id>();
       Map<Id,Billing_Schedule_Period__c> mapOfBSP = new Map<Id,Billing_Schedule_Period__c>();
       
       for(Billing_Schedule_Line__c bsl : newBSLList != null ? newBSLList : mapOldBSLs.values()) {
           if(newBSLList == null && mapOldBSLs !=  null){
               if(bsl.Billing_Schedule_Period__c != null){
                   setOfBSP.add(bsl.Billing_Schedule_Period__c);
               }
           }    
       }
       
       if(setOfBSP.size() > 0){
           for(Billing_Schedule_Period__c bsp : [select Id,Sales_Invoice__c,Sales_Credit_Note_Record__c From Billing_Schedule_Period__c
                                                 WHERE Id =:setOfBSP AND (Sales_Invoice__c != null Or Sales_Credit_Note_Record__c != null 
                                                                          Or Consolidated_Invoice_Record__c != null)]){
               mapOfBSP.put(bsp.Id,bsp);
           }
       }
       
       for(Billing_Schedule_Line__c bsl : newBSLList != null ? newBSLList : mapOldBSLs.values()){
           if(mapOfBSP.containsKey(bsl.Billing_Schedule_Period__c)){
               bsl.addError('You can not delete ' + bsl.name);
           }
       }
    } 
    
    /** 
      *  @description	:   This method is used to populate the Type field on the Billing schedule Periods.
      *
      *  @args		:   List<Billing_Schedule_Line__c>, Map<Id, Billing_Schedule_Line__c>
      *
      *  @return	:   void
      *
      *  @revision Log	:   V1.1 - Created - 09/07/2020 - Mahendra Swarnkar - CR-20200715-14321
      * 
    **/
    public static void populateTypeOnBSP(List<Billing_Schedule_Line__c> newBSLList, Map<Id, Billing_Schedule_Line__c> mapOldBSLs) {
    	
        set<Id> setOfBSP = new set<Id>();
        
        for(Billing_Schedule_Line__c bsl : newBSLList ) {
            
            if(mapOldBSLs == null || bsl.Related_Subscription_Component__c != mapOldBSLs.get(bsl.Id).Related_Subscription_Component__c) {
                
                if(bsl.Billing_Schedule_Period__c != null)
                    setOfBSP.add(bsl.Billing_Schedule_Period__c);
            }    
        }
        
        if(setOfBSP.size() > 0) {
            updateTypeOnBSP(setOfBSP);
        }
    }
    
    /** 
      *  @description	:   This method is used to populate the Type field on the Billing schedule Periods.
      *
      *  @args		:   List<Billing_Schedule_Line__c>, Map<Id, Billing_Schedule_Line__c>
      *
      *  @return	:   void
      *
      *  @revision Log	:   V1.1 - Created - 09/07/2020 - Mahendra Swarnkar - CR-20200715-14321
      * 
    **/
    public static void updateTypeOnBSP(set<Id> setOfBSP) {
        
		if(setOfBSP != null && setOfBSP.size() > 0) {
            
            Map<Id,Billing_Schedule_Period__c> mapOfBSP = new Map<Id,Billing_Schedule_Period__c>();
            
            for(Billing_Schedule_Period__c bsp : [select Id,Type__c, Type_Override__c, 
                                                  	(
                                                      Select Id, Related_Subscription_Component__c, Related_Subscription_Component__r.Subscription_Period__c,
                                                        Related_Subscription_Component__r.Subscription_Period__r.Period_Start_Date__c, Related_Subscription_Component__r.Subscription_Period__r.Period_End_Date__c, 
                                                        Related_Subscription_Component__r.Subscription_Period__r.Stage__c, Related_Subscription_Component__r.Subscription_Period__r.Renewal_Health__c,
                                                        Related_Subscription_Component__r.Subscription_Period__r.Projection_Likelihood__c, Related_Subscription_Component__r.Subscription_Period__r.Decision_Type__c
                                                      From Billing_Schedule_Lines__r 
                                                    )  
                                                  	From Billing_Schedule_Period__c 
                                                  	WHERE Id =:setOfBSP ]) 
            {
                //Modified By - Mahendra Swarnkar - 12/08/2020 - CR-20200715-14321 - check BSL associated Subscription Periods for Type on BSH .
                if(String.isNotBlank(bsp.Type_Override__c) && bsp.Type_Override__c != bsp.Type__c /*&& bsp.Billing_Schedule_Lines__r == null*/) {
                    
                	mapOfBSP.put(bsp.Id,new Billing_Schedule_Period__c(Id = bsp.Id, Type__c = bsp.Type_Override__c));
                    
                } else if(bsp.Billing_Schedule_Lines__r != null && bsp.Billing_Schedule_Lines__r.size() > 0) {
                        
                    Subscription_Period__c sPeriod;
                    Boolean isSubscriptionPeriodDetailsMatched = true;
                    
                    for(Billing_Schedule_Line__c bsl : bsp.Billing_Schedule_Lines__r) {
                        
                        if(bsl.Related_Subscription_Component__c != null && bsl.Related_Subscription_Component__r.Subscription_Period__c != null) {
                            
                            if(sPeriod == null) {
                                
                                sPeriod = new Subscription_Period__c(Id = bsl.Related_Subscription_Component__r.Subscription_Period__c, 
                                                                     Period_Start_Date__c = bsl.Related_Subscription_Component__r.Subscription_Period__r.Period_Start_Date__c,
                                                                     Period_End_Date__c = bsl.Related_Subscription_Component__r.Subscription_Period__r.Period_End_Date__c,
                                                                     Stage__c = bsl.Related_Subscription_Component__r.Subscription_Period__r.Stage__c,
                                                                     Renewal_Health__c = bsl.Related_Subscription_Component__r.Subscription_Period__r.Renewal_Health__c, 
                                                                     Projection_Likelihood__c = bsl.Related_Subscription_Component__r.Subscription_Period__r.Projection_Likelihood__c,
                                                                     Decision_Type__c = bsl.Related_Subscription_Component__r.Subscription_Period__r.Decision_Type__c 
                                                                    );
                            } else if(sPeriod.Id != bsl.Related_Subscription_Component__r.Subscription_Period__c) {
                                Subscription_Period__c sPeriod1 = new Subscription_Period__c(Id = bsl.Related_Subscription_Component__r.Subscription_Period__c, 
                                                                                              Period_Start_Date__c = bsl.Related_Subscription_Component__r.Subscription_Period__r.Period_Start_Date__c,
                                                                                              Period_End_Date__c = bsl.Related_Subscription_Component__r.Subscription_Period__r.Period_End_Date__c,
                                                                                              Stage__c = bsl.Related_Subscription_Component__r.Subscription_Period__r.Stage__c,
                                                                                              Renewal_Health__c = bsl.Related_Subscription_Component__r.Subscription_Period__r.Renewal_Health__c, 
                                                                                              Projection_Likelihood__c = bsl.Related_Subscription_Component__r.Subscription_Period__r.Projection_Likelihood__c,
                                                                                              Decision_Type__c = bsl.Related_Subscription_Component__r.Subscription_Period__r.Decision_Type__c 
                                                                                            );
                                if(sPeriod.Period_Start_Date__c != sPeriod1.Period_Start_Date__c || sPeriod.Period_End_Date__c != sPeriod1.Period_End_Date__c
                                  	|| sPeriod.Stage__c != sPeriod1.Stage__c || sPeriod.Renewal_Health__c != sPeriod1.Renewal_Health__c
                                    || sPeriod.Projection_Likelihood__c != sPeriod1.Projection_Likelihood__c || sPeriod.Decision_Type__c != sPeriod1.Decision_Type__c
								){
                                    isSubscriptionPeriodDetailsMatched = false;
                                        
                                    //Period Start Dates; Period End Dates; Stages; Renewal Healths; & Projection Likelihoods
									mapOfBSP.put(bsp.Id,new Billing_Schedule_Period__c(Id = bsp.Id, Type__c = Constants.BILLING_SCHEDULE_PERIOD_TYPE_MULTIPLE_SUBSCRIPTION_PERIODS_ASSOCIATED_WITH_THIS_BSP));
                                    break;
                                }
                            }   
                        }    
                    }
                    
                    if(!mapOfBSP.containsKey(bsp.Id) && sPeriod != null && isSubscriptionPeriodDetailsMatched) {
                        
                        String typeValue;
                        
                        if(sPeriod.Stage__c == CPQConstants.SUBSCRIPTION_PERIOD_STAGE_ATL || (sPeriod.Renewal_Health__c == Constants.SP_RENEWAL_HEALTH_VERBAL && sPeriod.Projection_Likelihood__c == Constants.SP_PROJECTION_LIKELIHOOD_CORRECT)){
                            
                            typeValue = Constants.BILLING_SCHEDULE_PERIOD_TYPE_BILLABLE_FEE;
                            
                        } else if(sPeriod.Decision_Type__c == CPQConstants.SUBSCRIPTION_PERIOD_DECISION_TYPE_OPT_OUT && sPeriod.Stage__c != CPQConstants.SUBSCRIPTION_PERIOD_STAGE_ATL && (sPeriod.Renewal_Health__c != Constants.SP_RENEWAL_HEALTH_VERBAL || sPeriod.Projection_Likelihood__c != Constants.SP_PROJECTION_LIKELIHOOD_CORRECT)) {
                            
                            typeValue = Constants.BILLING_SCHEDULE_PERIOD_TYPE_RISK_FEE_OPT_OUT;
                            
                        } else if(sPeriod.Decision_Type__c == CPQConstants.SUBSCRIPTION_PERIOD_DECISION_TYPE_OPT_IN && sPeriod.Stage__c != CPQConstants.SUBSCRIPTION_PERIOD_STAGE_ATL && (sPeriod.Renewal_Health__c != Constants.SP_RENEWAL_HEALTH_VERBAL || sPeriod.Projection_Likelihood__c != Constants.SP_PROJECTION_LIKELIHOOD_CORRECT)) {
                            
                            typeValue = Constants.BILLING_SCHEDULE_PERIOD_TYPE_RISK_FEE_OPT_IN;
                        } else if(sPeriod.Decision_Type__c == CPQConstants.SUBSCRIPTION_PERIOD_DECISION_TYPE_FIXED_TERM && sPeriod.Stage__c != CPQConstants.SUBSCRIPTION_PERIOD_STAGE_ATL) {
                            
                            typeValue = Constants.BILLING_SCHEDULE_PERIOD_TYPE_RISK_FEE_OTHER;
                        }
                        
                        if(String.isNotBlank(typeValue))
                            
                            mapOfBSP.put(bsp.Id,new Billing_Schedule_Period__c(Id = bsp.Id, Type__c = typeValue));
                        else
							mapOfBSP.put(bsp.Id,new Billing_Schedule_Period__c(Id = bsp.Id, Type__c = null));
                    }
                    
                } else
					mapOfBSP.put(bsp.Id,new Billing_Schedule_Period__c(Id = bsp.Id, Type__c = null));
            }
            
            if(mapOfBSP.size() > 0 && mapOfBSP.values() != null && mapOfBSP.values().size() > 0){
                Util.BypassAllTriggers = true;
                update mapOfBSP.values();
                Util.BypassAllTriggers = false;
            }
        }
    }
    
}