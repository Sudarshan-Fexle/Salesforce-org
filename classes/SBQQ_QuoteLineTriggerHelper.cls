/**
*  Description     :  Helper class for SBQQ_QuoteLineTrigger trigger.
*
*  Created By      :  Subhash Garhwal
*
*  Created Date    :  06/22/2016
*
*  Revision Logs   :  	V_1.0 - Created - Subhash Garhwal - CR-20160414-9762
*                     	V_1.1 - Modified - 08/10/2016 - Subhash Garhwal - CR-20160414-9762 - Added a new method "validateQuoteYearOneDiscount"
*                       V_1.2 - Modified - 08/19/2016 - Subhash Garhwal - CR-20160414-9762 - Added a new method "updateStandardPricing" and moved 
*                                                       				     syncProgramOpportunities method logic in future mmethod to avoid SOQL limit.    
*                       V_1.3 - Modified - 06/15/2017 - Subhash Garhwal - CR-20170403-10807 Added a new method "updateThresholdValueOnOpportunity"
*                       V_1.4 - Modified - 07/03/2017 - Victor Hanson   - CR-20170403-10807  - Added new methods "updateSegmentLabel" & "updatePreviousSegmentPrice"
*                       V_1.5 - Modified - 07/10/2017 - Subhash Garhwal - Issue--CR10808--QA--00004805  - Added new method "validateAmendProposalLines"
*                       V_1.6 - Modified - 07/21/2017 - Saurabh Kumar   - "populateRenewalPriceFields" method is updated 
*                       V_1.7 - Modified - 08/1/2017  - Subhash Garhwal - Added "validateOpportunityProducts" method (Issue--CR10808--QA--00005213)
*                       V_1.8 - Modified - 08/1/2017  - Subhash Garhwal - Added "blankOptOutAndEarlyTerminationDateOnMainProposalLine" method (Issue--CR11094--QA--00005437)
*                       V_1.9 - Modified - 08/18/2017 - Subhash Garhwal - Issue--CR11141--QA--00005513 - Added a new method "syncPHCustomerTotal" 
*                       V_2.0 - Modified - 08/19/2017 - Saurabh Kumar   - Issue--CR10808--QA--00005213 - Removed "validateOpportunityProducts" method because 
*                                                                                                      Rollup_Products_to_Opportunity dlrs is working for the requirement.
*                       V_2.1 - Modified - 08/24/2017 - Colin McGloin   - Added method to default "Operating Expense" and "Number of Students" if there is a value on the Instition on the Opp
*                       V_2.2 - Modified - 08/30/2017 - Victor Hanson   - Issue--CR11094--UAT--00005444 - Added method to default "Renewed Subscription" field 
*                                                                                                       on QuoteLine if there is an active membership for this acct/program
*                       V_2.3 - Modified - 10/27/2017 - Victor Hanson   - Issue--CR11062--QA--00007197 - Updated "populateRenewalPriceFields" so uplift only set 5% in y1 on create
*                       V_2.4 - Modified - 10/30/2017 - Subhash Garhwal - Issue--CR11744--QA--00007201 - Moved logic to future method
*                       V_2.5 - Modified - 03/27/2018 - Subhash Garhwal - Added checks to avoid SOQL issue
*                       V_2.6 - Modified - 04/13/2018 - Subhash Garhwal - CR-20180403-12145 - Updated "populateAmendProposalLinesListPrice" and "populateRenewalPriceFields" so List Unit Price won't update from Renewed Subscription
*                       V_2.7 - Modified - 06/25/2018 - Subhash Garhwal - CR-20180403-12145 - Updated "populateRenewalPriceFields" - Added logic for list price.
*                       V_2.8 - Modified - 07/26/2018 - Victor Hanson    - CR-20180715-12441 - Updated "updatePreviousSegmentPrice"
*                       V_2.9 - Modified - 09/25/2018 - Subhash Garhawal - CR-20180607-12270 - Added 'updateProSubscriptionStatusForAmendment'
*                       V_3.0 - Modified - 01/04/2019 - Victor Hanson    - CR-20181019-12685 - Added 'updateQuantity'
*                       V_3.1 - Modified - 01/11/2019 - Subhash Garhwal  - CR-20181019-12685 - Added 'syncupProgramPackages' method
*                       V_3.2 - Modified - 03/12/2019 - Subhash Garhwal  - CR-20190107-12809
*                       V_3.3 - Modified - 05/13/2019 - Mahendra Swarnkar - CR-20190306-12914 - Added new method populateSpecialPriceType
*                       V_3.4 - Modified - 05/24/2019 - Subhash Garhwal   - CR-20181019-12685 - Added 'ValidateESAMAndESOAMProducts' method
*			V_3.5 - Modified - 08/07/2019 - Victor Hanson     - CR-20181019-12685 - Added 'populateQuoteLineFieldsForCPQ' to resolve an issue in the latest release of CPQ
*			V_3.6 - Modified - 09/12/2019 - Victor Hanson     - CR-20190912-13336 - Added 'updateProrateMultiplier' to resolve an ES Proration bug
* 			V_3.7 - Modified - 09/04/2019 - Mahendra Swarnkar - CR-20190219-12888 - Modified "updateOptOutOnMainProposalLine" and "updateOptOutType"
*                       V_3.8 - Modified - 11/13/2019 - Victor Hanson     - CR-20191104-13494 - populateRenewalPriceFields() has been updated to no longer overwrite SpecialPrice if it's already populated
*			V_3.9 - Modified - 12/13/2019 - Victor Hanson     - CR-20191030-13484 - Added 'populateInvoicingArrangement' for billing sched project
*			V_4.0 - Modified - 04/16/2020 - Subhash Garhwal   - CR-20200409-13923
*			V_4.1 - Modified - 09/24/2020 - Subhash Garhwal   - CR-20200908-14494 - Added code to varify the Segment Label
*			V_4.2 - Modified - 10/2/2020  - Subhash Garhwal   -  CR-20200930-14570
*			V_4.3 - Modified - 01/05/2021 - Subhash Garhwal   - CR-20210105-14768
*			V_4.4 - Modified - 11/04/2020 - Mahendra Swarnkar - CR-20200611-14175 - 2-New product - Degree Rules Integration BHDR
*			V_4.5 - Modified - 02/05/2021 - Subhash Garhwal   - CR-20210113-14805
*			V_4.6 - Modified - 06/15/2021 - Mahendra Swarnkar - CR-20210615-15214  
*			V_4.7 - Modified - 08/31/2021 - Mahendra Swarnkar - CR-20201120-14707 - CPQ: Invoicing Arrangement in CPQ inconsistent at times
**/
public without sharing class SBQQ_QuoteLineTriggerHelper {
    
    public static Boolean executePopulateInstanceNameOnLines  = false;
    
    //Flag to contol the Quote Line trigger execution
    public static Boolean BYPASS_AutomatedProductCreation_METHOD  = false;
    
    //Flag to contol the Quote Line trigger execution
    public static Boolean VALIDATE_RENEWAL_PROPOSALLINE = false;
    
    //Flag to contol the Quote Line trigger execution
    public static Boolean RENEWAL_PROPOSALLINE_FROM_SCHEDULER = false; 
    
    //Flag to contol the Quote Line trigger execution
    public static Boolean executeSyncProgramOpportunitiesLogic = true;
    
    //Flag to check update case with insert
    public static Boolean isUpdateWithInsert = false;
    
    //Flag to set the Early Termination Date on renewal Proposals
    public static Boolean isClearEarlyTerminationDate = false;
    
    //Flag to bypass Sort order method
    public static Boolean BYPASS_SORT_ORDER_METHOD = false;
    
    //Flag to bypass UPDATEPREVIOUSSEGMENTPRICE method
    public static Boolean BYPASS_UPDATEPREVIOUSSEGMENTPRICE = false;
    
    //Flag to bypass populateAmendProposalLinesListPrice method
    public static Boolean BYPASS_POPULATEAMENDPROPOSALLINESLISTPRICE = false;
    
    //Modified By - Mahendra Swarnkar - 08/31/2021 - CR-20201120-14707 - CPQ: Invoicing Arrangement in CPQ inconsistent at times
    //Flag to bypass populateAmendProposalLinesListPrice method
    //public static Boolean BYPASS_populateInvoicingArrangement = false;
    
    // Modified - Subhash Garhwal - CR-20200908-14494
    //Flag to bypass populateESLinesOnAmendment method
    public static Boolean BYPASS_populateESLinesOnAmendment = false;
    
    //Flag to bypass populateCSVFieldsOnMainProposalLines method
    public static Boolean BYPASS_populateCSVFieldsOnMainProposalLines = false;
    
    //EAB Research Family
    public static final String PRODUCT_FAMILY_RESEARCH = 'EAB Research';
    
    
    //keep track of the IDs we have queried, so our quoteMap doesn't keep querying the same value
    public static set<Id> queriedIds {
        get {
            if (queriedIds == null) queriedIds = new set<Id>();
            return queriedIds;
        }
        set;
    }
    
    /**
     * 
     * @description: map of quotes for used for reference across multiple helper methods.  Store in one location so we don't waste SOQL queries
     * 
     *  @return         :   Map<Id, SBQQ__Quote__c>
     *
     *  @revision Log   :   V_1.0 - 08/30/2017 - Created - Victor Hanson
     * 			:   V_1.1 - Modified By - Mahendra Swarnkar - 08/31/2021 - CR-20201120-14707 - CPQ: Invoicing Arrangement in CPQ inconsistent at times
     * 
     **/
    public static Map<Id, SBQQ__Quote__c> quoteMap {
        get {
            if (quoteMap == null) quoteMap = new Map<Id, SBQQ__Quote__c>();
            
            //if there are more quoteIds than items in the map, re-query for the map
            //Modified By - Mahendra Swarnkar - 08/31/2021 - CR-20201120-14707 - Added Invoice_Frequency__c field in query
            if (quoteIds.size() > queriedIds.size())  {
                quoteMap = new Map<Id, SBQQ__Quote__c>([SELECT Id, SBQQ__Type__c, SBQQ__MasterContract__c, SBQQ__Opportunity2__r.AccountId, Invoice_Frequency__c 
                                                        FROM SBQQ__Quote__c WHERE Id IN :SBQQ_QuoteLineTriggerHelper.quoteIds]);
                
                //add all the quoteIds to the set of queried ids
                queriedIds.addAll(quoteIds);
            }
            
            return quoteMap;
        }
        set;
    }
    
    /**
     * 
     * @description: set of quote ids.  Used by SBQQ_QuotLineTriggerHelper.quoteMap to cache a map of quotes
     * 
     *  @return         :   Map<Id, SBQQ__Quote__c>
     *
     *  @revision Log   :   V_1.0 - 08/30/2017 - Created - Victor Hanson
     * 
     **/
    public static Set<Id> quoteIds {
        get {
            if (quoteIds == null) quoteIds = new Set<Id>();
            return quoteIds;
        }
        set;
    }
    
    /**
     * 
     * @description: display an error in the quote line editor when Calculator Error Message is populated.
     * 
     *  @args           :   List<SBQQ__QuoteLine__c>
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - 05/04/2017 - Created - Victor Hanson - CR-20170403-10807
     * 
     **/
    /*public static void checkErrorsOnQuoteLine(List<SBQQ__QuoteLine__c> quoteLines, Map<Id, SBQQ__QuoteLine__c> mapOldQuoteLines) {
        //this is used to avoid duplicate error messages
        set<string> errors = new set<string>();
                
        //Loop over the quote Lines
        for(SBQQ__QuoteLine__c qL : quoteLines) {
          
            if(String.isNotBlank(qL.Calculator_Error_Message__c) && !errors.contains(qL.Calculator_Error_Message__c)) {
                
                ql.addError(qL.Calculator_Error_Message__c);
                errors.add(qL.Calculator_Error_Message__c);//add the error to our set so we can avoid displaying duplicate errors
            }
        }
    }*/
     
    /**
     * 
     * @description    :  This method is used to Add the warning MSG for Large Deal
     * 
     *  @args           :   List<SBQQ__QuoteLine__c>
     *
     *  @return         :   void  
     *
     *  @revision Log   :   V_1.0 - 05/10/2017 - Created - Subhash Garhwal - CR-20170403-10807
     * 
     **/
    /*public static void validateLargeDeals(List<SBQQ__QuoteLine__c> proposalLines, Map<Id, SBQQ__QuoteLine__c> mapOldProposalLines) {
        
        //VH 6/28/17: This isn't working as intended -- it always displays error.  Commenting out for now.
        //Subhash Garhwal 6/30/2017: uncomment the code with some changes
        
        //Set to hold the UK (Quote Id + ProductId)
        Set<String> setUKQuoteIdAndProductIds = new Set<String>();
        Set<String> setUKQuoteIdAndProductIdToRemoveValidation = new Set<String>();
        
        //Loop over the Proposal Lines
        for(SBQQ__QuoteLine__c pL : proposalLines) {
            
            //Check for Calculator Error MSG
            if(mapOldProposalLines != null && pL.Calculator_Error_Message__c != mapOldProposalLines.get(pL.Id).Calculator_Error_Message__c && String.isNotBlank(mapOldProposalLines.get(pL.Id).Calculator_Error_Message__c))
                pL.Calculator_Error_Message__c = null;  
    */
            //Check for Values
            /*if (pL.SBQQ__RequiredBy__c == null && pL.SBQQ__PackageTotal__c >= Integer.valueOf(Label.PROPOSAL_LINE_PRODUCT_VALUE)) {
                
                //see if we've already warned this user about this large deal
                Boolean hasSeenError;
                
                //Create unique combination
                String uK = (pL.SBQQ__Quote__c + pL.Product_Code_Combination__c).replaceAll( '\\s+', '').replaceAll('-','');
                
                hasSeenError = (Boolean)Cache.Session.get('local.Default.' + uK);
                
                //Check UK in set
                if(setUKQuoteIdAndProductIds.contains('' + uK) && hasSeenError != null && hasSeenError)
                    hasSeenError = null;

                //Check for UK in avoid validation set
                if(setUKQuoteIdAndProductIdToRemoveValidation.contains('' + uK) && (hasSeenError == null || !hasSeenError))
                    hasSeenError = true;

                //Check if error already shows to user  
                if(pL.ConfirmedBigDealNotification__c == false) {
                    
                    //Check if MSG already displayed
                    if (hasSeenError == null || !hasSeenError) {
                    
                        //Set MSG
                        pL.Calculator_Error_Message__c = Label.LARGE_DEAL_MSG;
                        pL.ConfirmedBigDealNotification__c = true;
                        
                        //add to the session cache so we know we've seen this error before
                        Cache.Session.put('local.Default.' + uK, true);
                        
                        //Add values in set
                        setUKQuoteIdAndProductIds.add('' + uK);
                    } else {
                        
                        //Set Notification variables to avoid the error MSG again
                        pL.Calculator_Error_Message__c = null;
                        pL.ConfirmedBigDealNotification__c = true;

                        //Update entry in session
                        Cache.Session.put('local.Default.'+ + uK, false);
                        
                        
                        //Add UK in map
                        setUKQuoteIdAndProductIdToRemoveValidation.add('' + uK);
                    }
                    
                } else
                    pL.Calculator_Error_Message__c = null;
            } */
            
            
    /*  
        }
    }
    */
    /**
     *  @description    :   Moved "Update of proposal line" process builder logic into this method.
     *                      This method is used to calculate Standard Pricing of proposal line.
     *
     *  @args           :   List<SBQQ__QuoteLine__c>, Map<Id, SBQQ__QuoteLine__c>
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - 08/19/2016 - Created - Subhash Garhwal - CR-20160414-9762
     *
     **/
    public static void updateStandardPricing(List<SBQQ__QuoteLine__c> quoteLines, Map<Id, SBQQ__QuoteLine__c> mapOldQuoteLines) {
        
        //Loop over the quote Lines
        for(SBQQ__QuoteLine__c qL : quoteLines) {
            
            //01/14/2021 - CR-20210107-14791 - Victor Hanson - bypass when Opp is Contracted
            if (qL.Opportunity_Contracted__c) 
                continue;
            
            //Check trigger condition
            if(mapOldQuoteLines == null || qL.Standard_Price_Percentage__c != mapOldQuoteLines.get(qL.Id).Standard_Price_Percentage__c
                || qL.SBQQ__CustomerTotal__c != mapOldQuoteLines.get(qL.Id).SBQQ__CustomerTotal__c
                || qL.Standard_Pricing__c != mapOldQuoteLines.get(qL.Id).Standard_Pricing__c) {
                
                //Check for SBQQ__CustomerTotal__c
                if(qL.SBQQ__CustomerTotal__c != null) {
                    
                    //Check for Standard_Price_Percentage__c
                    if(qL.Standard_Price_Percentage__c != null && qL.Standard_Price_Percentage__c > 0)
                        qL.Standard_Pricing__c = Math.ROUND((qL.SBQQ__CustomerTotal__c * qL.Standard_Price_Percentage__c) + qL.SBQQ__CustomerTotal__c);
                    else
                        qL.Standard_Pricing__c = Math.ROUND(qL.SBQQ__CustomerTotal__c);
                }       
            }
        }
    }
    
    /**
    *   @description    :   If a Quote has a variance in Discounts between Years in a category then the field "Yearly Discount Variance" on the
    *                       Quote should be marked as true
    *                       If the quote line is edited or deleted and there are no associated Quote Lines which meet the criteria from number 1
    *                       – then the field on the associated Quote should be marked as false
    *
    *   @args           :   List<SBQQ__QuoteLine__c>, Map<Id, SBQQ__QuoteLine__c>
    *
    *   @return         :   void
    *
    *   @revision Log   :   V_1.0 - Created - Subhash Garhwal - 08/10/2016 - Requested By Colin - CR-20160414-9762
    *
    **/
    public static void validateQuoteYearOneDiscount(List<SBQQ__QuoteLine__c> quoteLines, Map<Id, SBQQ__QuoteLine__c> mapOldQuoteLines) {
        
        //Map to hold the quotes
        Map<Id, SBQQ__Quote__c> mapQuotes = new Map<Id, SBQQ__Quote__c>();
        
        //Loop over quote lines
        for(SBQQ__QuoteLine__c qL : quoteLines != null ? quoteLines : mapOldQuoteLines.values()) {
            
            //Insert Case
            if(mapOldQuoteLines == null && qL.SBQQ__Quote__c != null)
                mapQuotes.put(qL.SBQQ__Quote__c, new SBQQ__Quote__c(Id = qL.SBQQ__Quote__c, Yearly_Discount_Variance__c = false));
            
            //Update case
            if(mapOldQuoteLines != null && quoteLines != null &&
               (qL.SBQQ__Quote__c != mapOldQuoteLines.get(qL.Id).SBQQ__Quote__c || qL.SBQQ__Discount__c != mapOldQuoteLines.get(qL.Id).SBQQ__Discount__c
                || qL.SBQQ__SubscriptionCategory__c  != mapOldQuoteLines.get(qL.Id).SBQQ__SubscriptionCategory__c
                || qL.SBQQ__Product__c  != mapOldQuoteLines.get(qL.Id).SBQQ__Product__c
                || qL.SBQQ__RequiredBy__c  != mapOldQuoteLines.get(qL.Id).SBQQ__RequiredBy__c
                || qL.SBQQ__AdditionalDiscountAmount__c != mapOldQuoteLines.get(qL.Id).SBQQ__AdditionalDiscountAmount__c)) {
                    
                    //Check for quote
                    if(qL.SBQQ__Quote__c != null)
                        mapQuotes.put(qL.SBQQ__Quote__c, new SBQQ__Quote__c(Id = qL.SBQQ__Quote__c, Yearly_Discount_Variance__c = false));
                    
                    //Check for old quote
                    if(mapOldQuoteLines.get(qL.Id).SBQQ__Quote__c != null)
                        mapQuotes.put(mapOldQuoteLines.get(qL.Id).SBQQ__Quote__c, new SBQQ__Quote__c(Id = mapOldQuoteLines.get(qL.Id).SBQQ__Quote__c, Yearly_Discount_Variance__c = false));                    
                }
            
            //Delete case
            if(quoteLines == null && qL.SBQQ__Quote__c != null)
                mapQuotes.put(qL.SBQQ__Quote__c, new SBQQ__Quote__c(Id = qL.SBQQ__Quote__c, Yearly_Discount_Variance__c = false));  
        }
        
        //Check for size
        if(mapQuotes.size() > 0) {
            
            //Map to hold the quote Lines with Quote
            Map<Id, Map<String, Map<String, Integer>>> mapQuoteWithQuoteLines = new Map<Id, Map<String, Map<String,Integer>>>();
        
            //Query through QuoteLines
            for(SBQQ__QuoteLine__c qL : [Select Id, SBQQ__Quote__c, SBQQ__Product__c, SBQQ__SubscriptionCategory__c , SBQQ__Discount__c, SBQQ__RequiredBy__c,
                                                SBQQ__RequiredBy__r.SBQQ__Product__c, SBQQ__AdditionalDiscountAmount__c ,Discount_Custom__c 
                                         From SBQQ__QuoteLine__c 
                                         Where SBQQ__Quote__c IN :mapQuotes.keySet()]) {
                
                //Check for required values
                if(qL.SBQQ__SubscriptionCategory__c != null && CPQConstants.QUOTE_LINE_PROGRAM_SUBSCRIPTIONCATEGORY.contains(qL.SBQQ__SubscriptionCategory__c)) {
                    
                    
                    //Create a uniqe Key (Product - SubscriptionCategory)
                    String uniqeIdentifier = qL.SBQQ__Product__c + '-' + qL.SBQQ__SubscriptionCategory__c;
                    
                    //String to hold discount
                    String discount;
                    
                    //Check to see the user is using USD or % dropdown option
                    if (qL.SBQQ__Discount__c == null && qL.SBQQ__AdditionalDiscountAmount__c != null){
                        discount = String.valueOf(qL.Discount_Custom__c);
                    }
                    //Check for discount
                    else if(qL.SBQQ__Discount__c == null || qL.SBQQ__Discount__c == 0 || qL.SBQQ__Discount__c == 0.00)
                        discount = 'null';
                    else
                        discount = String.valueOf(qL.SBQQ__Discount__c);
                    
                    //Check Quote Id in map
                    if(!mapQuoteWithQuoteLines.containsKey(qL.SBQQ__Quote__c))
                        mapQuoteWithQuoteLines.put(qL.SBQQ__Quote__c, new Map<String, Map<String, Integer>>());
                    
                    //Check unique key in map
                    if(!mapQuoteWithQuoteLines.get(qL.SBQQ__Quote__c).containsKey(uniqeIdentifier))
                        mapQuoteWithQuoteLines.get(qL.SBQQ__Quote__c).put(uniqeIdentifier, new Map<String, Integer>());
                    
                    //Check discount in map
                    if(!mapQuoteWithQuoteLines.get(qL.SBQQ__Quote__c).get(uniqeIdentifier).containsKey(discount))
                        mapQuoteWithQuoteLines.get(qL.SBQQ__Quote__c).get(uniqeIdentifier).put(discount, 0);
                    
                    
                    //Increase counter
                    Integer discountCounter = mapQuoteWithQuoteLines.get(qL.SBQQ__Quote__c).get(uniqeIdentifier).get(discount) + 1;
                    
                    //Populate counter in map
                    mapQuoteWithQuoteLines.get(qL.SBQQ__Quote__c).get(uniqeIdentifier).put(discount, discountCounter);
                }   
            }
            
            //Check for map size
            if(mapQuoteWithQuoteLines.size() > 0) {
                
                //Loop over quote Ids
                for(Id qId : mapQuoteWithQuoteLines.keySet()) {
                    
                    //Loop through unique identifiers
                    for(String uK : mapQuoteWithQuoteLines.get(qId).keySet()) {
                        
                        //Check for map size
                        if(mapQuoteWithQuoteLines.get(qId).get(uK).size() > 1 && mapQuotes.containsKey(qId))
                            mapQuotes.get(qId).Yearly_Discount_Variance__c = true;  
                            
                    }
                }
            }
            
            //Update
            update mapQuotes.values();
        }
    }
    
    /**
     *  @description    :   Method to update/sync the sort order with Parent prodcuts short order
     *
     *  @args           :   List<SBQQ__QuoteLine__c>
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - 05/13/2017 - Created - Subhash Garhwal - CR-20170403-10807 
     *
     **/
    public static void syncSortOrder(List<SBQQ__QuoteLine__c> proposalLines) {
    
        //Set to hold the Product Ids
        Set<Id> setProductIds = new Set<Id>();
    
        //Loop over the Proposals
        for(SBQQ__QuoteLine__c pL : proposalLines) {
      
        //Check for product
        if(pL.SBQQ__Product__c != null)
            setProductIds.add(pL.SBQQ__Product__c);
        }
    
        //Check for set size
        if(setProductIds.size() > 0) {
      
            //Map to hold the Product details
            Map<Id, Product2> mapProducts = new Map<Id, Product2>([Select Id, SBQQ__SortOrder__c From Product2 Where Id IN : setProductIds]);
      
            //Loop over the Proposals
            for(SBQQ__QuoteLine__c pL : proposalLines) {
        
                //Check for product
                if(pL.SBQQ__Product__c != null && mapProducts.containsKey(pL.SBQQ__Product__c) && mapProducts.get(pL.SBQQ__Product__c).SBQQ__SortOrder__c != null) {
          
                //Set Sort order
                pL.Sort__c = mapProducts.get(pL.SBQQ__Product__c).SBQQ__SortOrder__c;
          
                BYPASS_SORT_ORDER_METHOD = true;
                }
            }  
        }
    }
     
  /**
    * 
    *   @description    :   This method used to populate Program_Threshold_Value__c on opportunity 
    *
    *   @args           :   List<SBQQ__QuoteLine__c> , Map<Id,SBQQ__QuoteLine__c> 
    *
    *   @return         :   void
    *
    *   @revision Log   :   V1.1 - Created - 06/15/2017 - Subhash Garhwal - Q2C Phase 2 - CR-20170403-10807
    * 
    **/
    public static void updateThresholdValueOnOpportunity(List<SBQQ__QuoteLine__c> quoteLines) {

        //Set to hold proposal id
        Set<Id>  setQuoteIds = new Set<Id>();

        //Map to hold opportunity
        Map<Id,Opportunity> mapOfOpportunity = new Map<Id,Opportunity>();

        //Loop through quotes lines
        for(SBQQ__QuoteLine__c qL : quoteLines) {

            //Check condition
            if(qL.SBQQ__Quote__c != null)
            setQuoteIds.add(qL.SBQQ__Quote__c);

        }

        //Process if size is greater than zero
        if(setQuoteIds.Size() >0) {

        //Added Check for SBQQ__Quote__r.SBQQ__Opportunity2__c != null - 11/22/2019 
        //Map to hold quotes lines
        List<SBQQ__QuoteLine__c> existingquoteLines = [Select Id, SBQQ__Quote__c, SBQQ__Quote__r.SBQQ__Primary__c, SBQQ__Product__c,
                                                           SBQQ__Product__r.Program__c, SBQQ__Product__r.Program__r.Large_Contract_Threshold__c,
                                                           SBQQ__Quote__r.SBQQ__Opportunity2__c, SBQQ__Quote__r.SBQQ__Opportunity2__r.RecordType.DeveloperName
                                                           From SBQQ__QuoteLine__c Where 
                                                           SBQQ__Quote__r.SBQQ__Opportunity2__c != null
                                                           AND SBQQ__Quote__r.SBQQ__Opportunity2__r.RecordType.DeveloperName IN :CPQConstants.SET_OPPORTUNITY_RECORDTYPE_DEVELOPERNAMES
                                                           AND SBQQ__Quote__c IN : setQuoteIds 
                                                           AND SBQQ__Quote__r.SBQQ__Primary__c = true   
                                                           AND SBQQ__Product__r.Program__c != null  
                                                           Order by SBQQ__Product__r.Program__r.Large_Contract_Threshold__c  DESC ];

            //Added Check for existingquoteLines != null - 11/22/2019
            //Process if size is greater than zero
            if(existingquoteLines != null && existingquoteLines.Size() >0) {

                //Loop through quote lines
                for(SBQQ__QuoteLine__c qL : existingquoteLines) {
  
                    if(!mapOfOpportunity.containsKey(qL.SBQQ__Quote__r.SBQQ__Opportunity2__c))
                        mapOfOpportunity.put(qL.SBQQ__Quote__r.SBQQ__Opportunity2__c, 
                                         new Opportunity(Id =  qL.SBQQ__Quote__r.SBQQ__Opportunity2__c, 
                                         Program_Threshold_Value__c = qL.SBQQ__Product__r.Program__r.Large_Contract_Threshold__c));
          
                }
  
                //Process if size of map is greater than zero
                if(mapOfOpportunity.Size()>0) {
          
                    //Bypassing triggers
                    Util.byPassAllTriggers = true;
                    
                    //Update cases
                    update mapOfOpportunity.values();

                    //Enabling triggers
                    Util.byPassAllTriggers = false;          
                }
            }   
        }
    }
  
  /**
    * 
    *   @description    :   This method used to calculate total of First_Year_Credit_Adjustment__c and Profit Credit Adjustment on Proposal from related Proposal Lines 
    *
    *   @args           :   List<SBQQ__QuoteLine__c>, Map<Id, SBQQ__QuoteLine__c>
    *
    *   @return         :   void
    *
    *   @revision Log   :   V1.1 - Created - 07/07/2017 - Subhash Garhwal - Q2C Phase 2 - CPQ16
    * 
    **/
    public static void rollUpCreditAndProfitAdjustment(List<SBQQ__QuoteLine__c> quoteLines, Map<Id, SBQQ__QuoteLine__c> mapOldQuoteLines){
    
        //Map to hold Proposals 
        Map<Id,SBQQ__Quote__c> mapProposals = new Map<Id,SBQQ__Quote__c>();

        //Loop through the Quote Lines
        for(SBQQ__QuoteLine__c qL : quoteLines != null ? quoteLines : mapOldQuoteLines.values()) {
            
            //01/14/2021 - CR-20210107-14791 - Victor Hanson - bypass when Opp is Contracted
            if (qL.Opportunity_Contracted__c) 
                continue;

            //Check for insert case
            if(qL.SBQQ__Quote__c != null && mapOldQuoteLines == null)
                mapProposals.put(qL.SBQQ__Quote__c, new SBQQ__Quote__c(Id = qL.SBQQ__Quote__c, Sum_of_First_Year_Credit_Adjustment__c = 0, Sum_of_Profit_Credit_Adjustment__c = 0));

            //Check for update casse
            if(quoteLines != null && mapOldQuoteLines != null && 
            (qL.SBQQ__Quote__c != mapOldQuoteLines.get(qL.Id).SBQQ__Quote__c 
            || qL.First_Year_Credit_Adjustment__c != mapOldQuoteLines.get(qL.Id).First_Year_Credit_Adjustment__c 
            || qL.Profit_Credit_Adjustment__c != mapOldQuoteLines.get(qL.Id).Profit_Credit_Adjustment__c)) {

                //Check new updated values not equal to null
                if(qL.SBQQ__Quote__c != null )
                    mapProposals.put(qL.SBQQ__Quote__c, new SBQQ__Quote__c(Id = qL.SBQQ__Quote__c, Sum_of_First_Year_Credit_Adjustment__c = 0, Sum_of_Profit_Credit_Adjustment__c = 0));

                //Check for old 
                if(mapOldQuoteLines.get(qL.Id).SBQQ__Quote__c != null)
                    mapProposals.put(mapOldQuoteLines.get(qL.Id).SBQQ__Quote__c, 
                                     new SBQQ__Quote__c(Id = mapOldQuoteLines.get(qL.Id).SBQQ__Quote__c, Sum_of_First_Year_Credit_Adjustment__c = 0, Sum_of_Profit_Credit_Adjustment__c = 0));
            }

            //Check for delete case
            if(quoteLines == null && qL.SBQQ__Quote__c != null && (qL.First_Year_Credit_Adjustment__c != null  || qL.Profit_Credit_Adjustment__c != null))
                mapProposals.put(qL.SBQQ__Quote__c, new SBQQ__Quote__c(Id = qL.SBQQ__Quote__c, Sum_of_First_Year_Credit_Adjustment__c = 0, Sum_of_Profit_Credit_Adjustment__c = 0));
        }

        //Check for Proposals
        if(mapProposals.Size() > 0) {

            //Loop through aggreagate query
            for(AggregateResult aResult : [SELECT SUM(First_Year_Credit_Adjustment__c) fYCA, SUM(Profit_Credit_Adjustment__c) pCA, SBQQ__Quote__c proId FROM SBQQ__QuoteLine__c 
                      WHERE SBQQ__Quote__c IN: mapProposals.keySet() GROUP BY SBQQ__Quote__c]) {
                
                //Get Proposal Id
                Id proposalId = Id.valueOf(String.valueof(aResult.get('proId')));
        
                //Check Proposal Id in map
                if(mapProposals.containsKey(proposalId)) {
          
                //Update the Adjustments
                mapProposals.get(proposalId).Sum_of_First_Year_Credit_Adjustment__c = (Decimal) aResult.get('fYCA');
                mapProposals.get(proposalId).Sum_of_Profit_Credit_Adjustment__c = (Decimal) aResult.get('pCA');
                }
            }
            
            //Updates values
            if(mapProposals.size() > 0) {
               
                Util.byPassAllTriggers = true;
                update mapProposals.values();
                Util.byPassAllTriggers = false;
            }
        }
    }
    
    /**
     * 
     *   @description    :   This method used to validate the Customer Price for Amend Proposal Lines 
     *
     *   @args           :   List<SBQQ__QuoteLine__c>, Map<Id, SBQQ__QuoteLine__c>
     *
     *   @return         :   void
     *
     *   @revision Log   :   V1.1 - Created  - 07/08/2017 - Subhash Garhwal - Q2C Phase 2 - Issue - 00004805
     *                       V1.2 - Modified - 05/08/2018 - Victor Hanson - Commented out due to CR-20180607-12270
     * 
     **/
    /*public static void validateAmendProposalLines(List<SBQQ__QuoteLine__c> quoteLines, Map<Id, SBQQ__QuoteLine__c> mapOldQuoteLines){
        
        //set of quote ids
        set<Id> quoteIds = new set<Id>();
        
        //get a map of quotes so we can get the master contract
        for (SBQQ__QuoteLine__c qL : quoteLines) {
            
            //if this quote isn't already in our map, add it to the list of quotes we need to query
            if (qL.SBQQ__Quote__c != null && !SBQQ_QuoteLineTriggerHelper.quoteIds.contains(qL.SBQQ__Quote__c))
              SBQQ_QuoteLineTriggerHelper.quoteIds.add(qL.SBQQ__Quote__c);
        }
        
        //get the contract for amendments
        set<Id> contractIds = new set<Id>();
        for(SBQQ__Quote__c q : SBQQ_QuoteLineTriggerHelper.quoteMap.values()) {
            if (q.SBQQ__Type__c == 'Amendment' && q.SBQQ__MasterContract__c != null)
                contractIds.add(q.SBQQ__MasterContract__c);
        }
        
        //only process if this is an amendment (ie: it has a master contract)
        if (contractIds.size() > 0) {
            
            //map of subscriptionKey -> Subscription (key: ContractID + RequiredByProduct + ProductID + StartYear)
            map<string, SBQQ__Subscription__c> mapKeytoSubscription = SBQQ_SubscriptionTriggerHelper.getComponentSubscriptionsFromContracts(contractIds);
            
            //map of quoteLineID -> quoteLineKey (key: ContractID + RequiredByProduct + ProductID + StartYear)
            map<Id, String> mapIdtoQuoteLineKey = getQuoteLineUniqueKeyMap(quoteLines, SBQQ_QuoteLineTriggerHelper.quoteMap, true);
            
            //Loop over the Proposal Lines
            for(SBQQ__QuoteLine__c pL : quoteLines) {
                
                //make sure there is a value for this
                if (mapIdtoQuoteLineKey.containsKey(pL.Id)) {
                    
                    //unique proposalLineKey, which we will use to match with the corresponding subscription
                    string pLKey = mapIdtoQuoteLineKey.get(pL.Id);
                    
                    //subscription that corresponds to the same unique key as the proposal line
                    SBQQ__Subscription__c matchingSubscription = mapKeytoSubscription.get(plKey);
                    
                    //Check for Amended Proposal Line and apply validation for customer Price
                    if (matchingSubscription != null 
                        && matchingSubscription.Customer_Amount__c != pL.SBQQ__CustomerTotal__c
                        && pL.SBQQ__CustomerTotal__c != 0) 
                    {
                        string exceptionMessage = Label.AMENDMENT_PROPOSAL_LINE_MSG + '\r\n'
                            + pL.SBQQ__SegmentLabel__c + ' Expected: ' + matchingSubscription.Customer_Amount__c + '\r\n'
                            + pL.SBQQ__SegmentLabel__c + ' Actual ' + pL.SBQQ__CustomerTotal__c;
                        throw new CustomException(exceptionMessage);
                    }
                }
            }
        }
    }*/
    
    /**
     * 
     *   @description    :   Returns a map<QuoteLineID -> ContractID + RequiredByProduct + ProductID + StartYearYear>
     *                       This can be used to match QuoteLines to their corresponding Subscription, if you 
     *                       get a corresponding map of subscriptions via the getComponentSubscriptionsFromContracts method, 
     *                       because it returns a map using the same unique key
     *
     *   @args           :   List<SBQQ__QuoteLine__c>, map<Id, SBQQ__Quote__c>
     *
     *   @return         :   map<Id, String>
     *
     *   @revision Log   :   V1.1 - Created - 07/12/2017 - Victor Hanson - Q2C Phase 2
     * 
     **/
    public static map<Id, String> getQuoteLineUniqueKeyMap(list<SBQQ__QuoteLine__c> quoteLines, map<Id, SBQQ__Quote__c> qtMap, boolean includeYear) {
        
        //set of product options
        set<Id> productOptionIds = new set<Id>();
        
        //map of quoteLineID -> quoteLineKey
        map<Id, String> mapIdtoQuoteLineKey = new map<Id, String>();
        
        //get product options
        for (SBQQ__QuoteLine__c pL : quoteLines) productOptionIds.add(pL.SBQQ__ProductOption__c);
        
        //get product option map
        map<Id, SBQQ__ProductOption__c> pOptionMap = new map<Id, SBQQ__ProductOption__c>([SELECT Id, SBQQ__ConfiguredSKU__c
                                                                                          FROM SBQQ__ProductOption__c WHERE Id IN :productOptionIds]);
        
        for(SBQQ__QuoteLine__c pL : quoteLines) {
            
            SBQQ__Quote__c quote = qtMap.get(pL.SBQQ__Quote__c);
            
            //make sure ProductOption is populdated, and it doesn't have an upgraded subscription
            if (pL.SBQQ__ProductOption__c != null && pL.SBQQ__UpgradedSubscription__c == null) {
                
                string pLKey = quote.SBQQ__MasterContract__c + '-' + pOptionMap.get(pL.SBQQ__ProductOption__c).SBQQ__ConfiguredSKU__c + '-' 
                         + pL.SBQQ__Product__c;
                if (includeYear) pLKey += '-' + pL.SBQQ__StartDate__c.year();
                
                mapIdtoQuoteLineKey.put(pL.Id, pLKey);
            }
        }
        
        return mapIdtoQuoteLineKey;
    }
    
    /**
     * 
     *   @description    :   This method used to pass the Opt Out value from Child Opt Out Propoal Line to main Proposal Line. 
     *
     *   @args           :   List<SBQQ__QuoteLine__c>, Map<Id, SBQQ__QuoteLine__c>
     *
     *   @return         :   void
     *
     *   @revision Log   :   V1.1 - Created - 07/11/2017 - Subhash Garhwal - Q2C Phase 2 - Issue--CR10808--QA--00004849
     *              	     V1.2 - Modified - 10/30/2017 - Subhash Garhwal - Issue--CR11744--QA--00007201 - Moved logic to future method
     * 			     V1.3 - Modified - 09/04/2019 - Mahendra Swarnkar - CR-20190219-12888
     * 			     V1.4 - Modified - 07/30/2020 - Mahendra Swarnkar
     * 
     **/
    public static void updateOptOutOnMainProposalLine(List<SBQQ__QuoteLine__c> quoteLines, Map<Id, SBQQ__QuoteLine__c> mapOldQuoteLines){
      
        //Set to hold the main proposal line Ids
        Set<Id> setMainProposalIds = new Set<Id>();
      
        //Check for list
        if(quoteLines != null) {
            
            //Loop over the Proposal Line
            for(SBQQ__QuoteLine__c pL : quoteLines) {
            
                //01/14/2021 - CR-20210107-14791 - Victor Hanson - bypass when Opp is Contracted
                if (pL.Opportunity_Contracted__c) {
                    continue;
                }
                
                //Modified - 09/04/2019 - Mahendra Swarnkar - CR-20190219-12888 - Added check for "Opt In" 
                //Check for Opt Out type
                if((pL.Product_Category__c == 'Opt Out' || pL.Product_Category__c == 'Opt In')&& pL.SBQQ__RequiredBy__c != null && (mapOldQuoteLines == null
                    || pL.SBQQ__RequiredBy__c != mapOldQuoteLines.get(pL.Id).SBQQ__RequiredBy__c))
                    setMainProposalIds.add(pL.SBQQ__RequiredBy__c);  
            }
        }
        
        //Check for new value
        if(quoteLines == null && mapOldQuoteLines != null) {
          
            //Loop over the Proposal Line
            for(SBQQ__QuoteLine__c pL : mapOldQuoteLines.values()) {
                
                //Modified - 09/04/2019 - Mahendra Swarnkar - CR-20190219-12888 - Added check for "Opt In"
                //Check for Opt Out type
                if((pL.Product_Category__c == 'Opt Out' || pL.Product_Category__c == 'Opt In')&& pL.SBQQ__RequiredBy__c != null)
                    setMainProposalIds.add(pL.SBQQ__RequiredBy__c);  
            }
        }
      
        //Check for set size
        if(setMainProposalIds.size() > 0 ) {
            // commented by Subhash Garhwal 08/07/2020
            /*if(!system.isScheduled() && !system.isFuture() && !system.isBatch() ){
                //Call future method
                SBQQ_QuoteLineTriggerHelper.updateOptOutTypefuture(setMainProposalIds);
                
                } else {
                SBQQ_QuoteLineTriggerHelper.updateOptOutType(setMainProposalIds);
                }*/
            
            // Added by Subhash Garhwal 08/07/2020
            dateTime sysTime = dateTime.now().addMinutes(5);
            String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
            Sched_UpdateOptOutType job = new Sched_UpdateOptOutType(setMainProposalIds);
            System.schedule('Sched_UpdateOptOutType' + sysTime.getTime(),chron_exp, job);
        }
    }
    
    @future
    public static void updateOptOutTypefuture(Set<Id> setMainProposalIds) {
        SBQQ_QuoteLineTriggerHelper.updateOptOutType(setMainProposalIds);
        
    }
    
    public static void updateOptOutType(Set<Id> setMainProposalIds) {
        
        //Check for set size
        if(setMainProposalIds.size() > 0) {
        
            //Map to update the main Proposal Lines
            Map<Id, SBQQ__QuoteLine__c> mapMainProposalLines = new Map<Id, SBQQ__QuoteLine__c>();
        
            //Modified - 09/04/2019 - Mahendra Swarnkar - CR-20190219-12888 - Added check for "Opt In"
            //SOQL over the Opt Out Proposal Lines
            for(SBQQ__QuoteLine__c pL : [Select Id, (Select Id, SBQQ__Product__c, SBQQ__Product__r.Opt_Out__c From SBQQ__Quote_Lines__r Where (Product_Category__c = 'Opt Out' OR Product_Category__c = 'Opt In') AND SBQQ__RequiredBy__c != null
                                        AND SBQQ__Product__c != null AND SBQQ__Product__r.Opt_Out__c != null) From SBQQ__QuoteLine__c Where Id IN : setMainProposalIds]) {
          
                //Check for values
                if(pL.SBQQ__Quote_Lines__r != null && pL.SBQQ__Quote_Lines__r.size() > 0) {
            
                    mapMainProposalLines.put(pL.Id, new SBQQ__QuoteLine__c(Id = pL.Id, Opt_Out__c = pL.SBQQ__Quote_Lines__r[0].SBQQ__Product__r.Opt_Out__c));
            
                } else
                    mapMainProposalLines.put(pL.Id, new SBQQ__QuoteLine__c(Id = pL.Id, Opt_Out__c = null));
            }
      
            //Check for map size
            if(mapMainProposalLines.size() > 0) {
        
                //By Pass all the trigger process
                Util.BypassAllTriggers = true;
                
                //Update
                update mapMainProposalLines.values();
                
                Util.BypassAllTriggers = false;
            }
        }
    }
    
    /**
     * 
     *   @description    :   Sets the QuoteLine's SBQQ__PreviousSegmentPrice__c field based on the previous year's Subscription
     *
     *   @args           :   List<SBQQ__QuoteLine__c>
     *
     *   @return         :   void
     *
     *   @revision Log   :   V1.1 - Created - 07/12/2017 - Victor Hanson - Q2C Phase 2 - CR-20170403-10807
     *                       V1.2 - Modified - 07/26/2018 - Victor Hanson - CR-20180715-12441
     *                       V1.3 - Modified - 06/04/2019 - Subhash Garhwal - CR-20181019-12685 - Added check to resolve Attempt to de-reference error
     * 
     **/
    public static void updatePreviousSegmentPrice(List<SBQQ__QuoteLine__c> quoteLines) {
        
        map<string, SBQQ__Subscription__c> mapKeyToComponentSubscription = new map<string, SBQQ__Subscription__c>();
        set<Id> quoteIds = new set<Id>();
        //get the map of ProductOptionID -> ProductOption - this is so we can retrieve the parent product id
        set<Id> productOptionIds = new set<Id>();
        
        for (SBQQ__QuoteLine__c qL : quotelines) {
            
            //01/14/2021 - CR-20210107-14791 - Victor Hanson - bypass when Opp is Contracted
            if (qL.Opportunity_Contracted__c) 
                continue;

            if (qL.SBQQ__Quote__c != null) quoteIds.add(qL.SBQQ__Quote__c);
            if (qL.SBQQ__ProductOption__c != null) productOptionIds.add(qL.SBQQ__ProductOption__c);
        }
        
        if (quoteIds.size() > 0) {
          
          BYPASS_UPDATEPREVIOUSSEGMENTPRICE = true;
            
            //get the related quotes and associated Contract
            set<Id> contractIds = new set<Id>();
            map<Id, SBQQ__Quote__c> quoteMap = new map<Id, SBQQ__Quote__c>([SELECT Id, SBQQ__MasterContract__c
                                           FROM SBQQ__Quote__c 
                                           WHERE Id IN :quoteIds
                                        AND SBQQ__MasterContract__c != null]);
            
            if(quoteMap != null && quoteMap.size() > 0) {
                
                for (SBQQ__Quote__c q : quoteMap.values())
                {
                    contractIds.add(q.SBQQ__MasterContract__c);
                }
                
                //get the map of ProductOptionID -> ProductOption - this is so we can retrieve the parent product id
                map<Id, SBQQ__ProductOption__c> productOptionMap = new map<Id, SBQQ__ProductOption__c>([SELECT Id, SBQQ__ConfiguredSKU__c
                                                                        FROM SBQQ__ProductOption__c
                                                                        WHERE Id IN :productOptionIds]);
                
                
                //if contracts were returned, get the Component Subscriptions related to the Master Contract
                if (contractIds.size() > 0) {
                    
                    //returns map<ContractID + RequiredByProductID + ProductID + StartYear, Subscription>
                    map<string, SBQQ__Subscription__c> mapKeyToSubscription = SBQQ_SubscriptionTriggerHelper.getComponentSubscriptionsFromContracts(contractIds);
                    
                    //create a map of QuoteLines with the same key
                    map<string, SBQQ__QuoteLine__c> mapKeyToQuoteLines = new map<string, SBQQ__QuoteLine__c>();
                    
                    for (SBQQ__QuoteLine__c qL : quoteLines) {
                        
                        //skip if this doesn't have a start date
                        if (qL.SBQQ__StartDate__c == null) continue;
                        
                        //get the related Quote
                        SBQQ__Quote__c quote = quoteMap.get(qL.SBQQ__Quote__c);
                        
                        //get the related product option
                        SBQQ__ProductOption__c option = productOptionMap.get(qL.SBQQ__ProductOption__c);
                       
                        if(option != null && quote != null) {
                            
                            //create the unique key map<ContractID + RequiredByProductID + ProductID + (StartYear - 1), Subscription>
                            string key = quote.SBQQ__MasterContract__c + '-' + option.SBQQ__ConfiguredSKU__c + '-' + qL.SBQQ__Product__c + '-' 
                                    + (qL.SBQQ__StartDate__c.Year()-1);
                            
                            //see if there is a related subscription in the previous year
                            SBQQ__Subscription__c previousYearSubscription = mapKeyToSubscription.get(key);
                            
                            //if there is a previous year subscription on the same quote for this product, set previousYearSubscription
                            //VH 7/26/2018 - Only update if segment index = 1
                            if (previousYearSubscription != null && qL.SBQQ__SegmentIndex__c == 1)
                                qL.SBQQ__PreviousSegmentPrice__c = previousYearSubscription.Customer_Amount__c; 
                        }
                    }
                }
            }
        }
    }
    
    /**
     * 
     *   @description    :   Fixes an issue where the SegmentLabel on Amendment QuoteLines is off by 1,
     *             which causes an issue in the QuoteLineEditor where it combines two years in one, then skips a year.
     *
     *   @args           :   List<SBQQ__QuoteLine__c>
     *
     *   @return         :   void
     *
     *   @revision Log   :   V1.1 - Created - 07/12/2017 - Victor Hanson - Q2C Phase 2 - CR-20170403-10807
     * 			     V1.2   Modified- 07/24/2020 - Subhash Garhwal - change the key - CR-20200727-14366
     *			     V1.3 - Modified - 09/24/2020 - Subhash Garhwal - CR-20200908-14494 - Added code to varify the Segment Label
     * 
     **/
    public static void updateSegmentLabel(List<SBQQ__QuoteLine__c> quoteLines) {
        
        //map<segmentkey + '-' + segmentLabel, list<quoteline>>
        map<string, list<SBQQ__QuoteLine__c>> mapKeyToQuoteLines = new map<string, list<SBQQ__QuoteLine__c>>();
        for (SBQQ__QuoteLine__c qL : quoteLines) {
            
            //01/14/2021 - CR-20210107-14791 - Victor Hanson - bypass when Opp is Contracted
            if (qL.Opportunity_Contracted__c) 
                continue;
            
            //9/24/2020 - Subhash Garhwal - CR-20200908-14494 - Added logic for Segment Label
            //if(qL.SBQQ__SegmentIndex__c != null)
                //qL.SBQQ__SegmentLabel__c = 'Year ' + qL.SBQQ__SegmentIndex__c;    
            
            if (!string.isBlank(qL.SBQQ__SegmentKey__c) && qL.SBQQ__SegmentLabel__c != null) {
                
                //create the unique key
                //string key = qL.SBQQ__SegmentKey__c + '-' + qL.SBQQ__SegmentLabel__c;
                string key = qL.SBQQ__Product__c + '-' + qL.SBQQ__RequiredBy__c + '-' + qL.SBQQ__SegmentKey__c + '-' + qL.SBQQ__SegmentLabel__c;
                
                //get all quotelines with this key
                list<SBQQ__QuoteLine__c> qLines = mapKeyToQuoteLines.get(key);
                if (qLines == null) qLines = new list<SBQQ__QuoteLine__c>();
                qLines.add(qL);
                
                //if there are 2 records with the same segment, move the later one
                if (qLines.size() > 1) {
                    SBQQ__QuoteLine__c latestQL;
                    for (SBQQ__QuoteLine__c qLines2 : qLines) {
                        if (latestQL == null || qLines2.SBQQ__EndDate__c > latestQL.SBQQ__EndDate__c) 
                            latestQL = qLines2;
                    }
                    list<string> segmentParts = latestQL.SBQQ__SegmentLabel__c.split('  ');
                    if (segmentParts.size() > 1) {
                        integer segmentInt = integer.valueOf(segmentParts[1]);
                        segmentInt += 1;
                        latestQL.SBQQ__SegmentLabel__c = segmentparts[0] + '  ' + segmentInt;
                    }
                    
                    //add 1 to the next mapKey
                    //string key2 = latestQL.SBQQ__SegmentKey__c + '-' + latestQL.SBQQ__SegmentLabel__c;
                    string key2 = latestQL.SBQQ__Product__c + '-' + latestQL.SBQQ__RequiredBy__c + '-' + latestQL.SBQQ__SegmentKey__c + '-' + latestQL.SBQQ__SegmentLabel__c;
                    list<SBQQ__QuoteLine__c> qLines2 = mapKeyToQuoteLines.get(key2);
                    if (qLines2 == null) qLines2 = new list<SBQQ__QuoteLine__c>();
                    qLines2.add(latestQL);
                    mapKeyToQuoteLines.put(key2, qLines2);                    
                }
                
                mapKeyToQuoteLines.put(key, qLines);
            }
        }
    }
    
    /**
     * 
     *   @description    :   This method used to populate the List Price for Amendment QuoteLines based on Prior Subscription price
     *
     *   @args           :   List<SBQQ__QuoteLine__c>, Map<Id, SBQQ__QuoteLine__c>
     *
     *   @return         :   void
     *
     *   @revision Log   :   V1.1 - Created - 07/08/2017 - Subhash Garhwal - Q2C Phase 2 - Issue - 00004805
     *                       V1.2 - Modified - 04-13-2018 - Subhash Garhwal -CR-20180403-12145
     *                       V1.3 - Modified - 01/14/2021 - Victor Hanson - CR-20210107-14791 - bypass quotelines where Opp is Contracted
     * 
     **/
    public static void populateAmendProposalLinesListPrice(List<SBQQ__QuoteLine__c> quoteLines, Map<Id, SBQQ__QuoteLine__c> mapOldQuoteLines, Boolean isInsert, Boolean isUpdate) 
    {
        
        //get a map of quotes so we can get the master contract
        for (SBQQ__QuoteLine__c qL : quoteLines) {

            //01/14/2021 - CR-20210107-14791 - Victor Hanson - bypass when Opp is Contracted
            if (qL.Opportunity_Contracted__c) 
                continue;

            //if this quote isn't already in our map, add it to the list of quotes we need to query
            if (qL.SBQQ__Quote__c != null && !SBQQ_QuoteLineTriggerHelper.quoteIds.contains(qL.SBQQ__Quote__c))
              SBQQ_QuoteLineTriggerHelper.quoteIds.add(qL.SBQQ__Quote__c);
        }
        
        //01/14/2021 - CR-20210107-14791 - Victor Hanson - only process if there are records
        if (SBQQ_QuoteLineTriggerHelper.quoteIds.size() > 0) {
            //populate renewal pricing fields
            populateRenewalPriceFields(quoteLines, mapOldQuoteLines, SBQQ_QuoteLineTriggerHelper.quoteMap, isInsert, isUpdate);
        }
        
        //Subhash Garhwal - 04/13/2018 - CR-20180403-12145 comment out the List Price updation logic
        /*
        //get the contract for amendments
        set<Id> contractIds = new set<Id>();
        for(SBQQ__Quote__c q : SBQQ_QuoteLineTriggerHelper.quoteMap.values()) {
            
            //if master contract is populated, add ID to list
            if (q.SBQQ__MasterContract__c != null)
                contractIds.add(q.SBQQ__MasterContract__c);
        }
        
        //only process if this is an amendment (ie: it has a master contract)
        if (contractIds.size() > 0) {
            
            //map of subscriptionKey -> Subscription (key: ContractID + RelatedProduct + ProductName)
            map<string, SBQQ__Subscription__c> mapKeytoSubscription = new map<string, SBQQ__Subscription__c>();
            
            //get all component subscriptions on the contract
            for (SBQQ__Subscription__c subscription : [SELECT Id, SBQQ__SegmentStartDate__c, SBQQ__Contract__c, Customer_Amount__c, SBQQ__ListPrice__c,
                                                       Program_Subscription__c, SBQQ__Product__c, SBQQ__RequiredByProduct__c, Related_Product__c
                                                       FROM SBQQ__Subscription__c 
                                                       WHERE SBQQ__Contract__c IN :contractIds
                                                       AND RecordTypeId = :CPQConstants.SUBSCRIPTION_RT_ID_COMPONENT
                                                       AND SBQQ__Quantity__c >= 1]) 
            {
                mapKeytoSubscription.put(subscription.SBQQ__Contract__c + '-' + subscription.Related_Product__c + '-' + subscription.SBQQ__Product__c, subscription);
            }
            
            for (SBQQ__QuoteLine__c pL : quoteLines) {
                
                //VH 8/3/17 - verify this isn't the main quoteline when adding prices, uplift, etc... - Issue--CR11094--UAT--00005331
                if (pL.SBQQ__RequiredBy__c != null) {
                    
                    //get the related quote
                    SBQQ__Quote__c quote = SBQQ_QuoteLineTriggerHelper.quoteMap.get(pL.SBQQ__Quote__c);
                    
                    //get the subscription on the related contract with the same Product/SubProduct (ie: HCAB - Annual Fee)
                    SBQQ__Subscription__c subscription = mapKeytoSubscription.get(quote.SBQQ__MasterContract__c + '-' + pL.Related_Product__c + '-' + pL.SBQQ__Product__c);
                    
                    //set the listPrice based on the subscription's list price
                    if (subscription != null) 
                    pL.SBQQ__ListPrice__c = subscription.SBQQ__ListPrice__c;
                }
            }
            
        } */
        
        //Bypass
        //BYPASS_POPULATEAMENDPROPOSALLINESLISTPRICE = true;
    }
    
    /**
     * 
     *   @description    :  Populate fields on Renewal QuoteLines based on the related Subscription
     *
     *   @args           :  List<SBQQ__QuoteLine__c>, Map<Id, SBQQ__QuoteLine__c>
     *
     *   @return         :  void
     *
     * 	 @revision Log   :  V1.1 - Created - 07/14/2017 - Victor Hanson - Q2C Phase 2 - Issue--CR10808--QA--00004991
     *   		    V1.2 - Modified - 04-13-2018 - Subhash Garhwal - CR-20180403-12145 - removed SBQQ__ListPrice__c logic
     * 			    V1.3 - Modified - 10-15-2019 - Mahendra Swarnkar - CR-20191014-13409 - Updated method to invoke a future method to populate the Previous period negotiated value on main quoteline.
     *                      V1.4 - Modified - 11/13/2019 - Victor Hanson - CR-20191104-13494 - Upated to no longer overwrite SpecialPrice if it's already populated
     * 			    V1.5 - Modified - 08/11/2020 - Victor Hanson - CR-20200730-14388 - Update logic for EAB Research renewals
     * 
     **/
    public static void populateRenewalPriceFields(List<SBQQ__QuoteLine__c> quoteLines, Map<Id, SBQQ__QuoteLine__c> mapOldQuoteLines, Map<Id, SBQQ__Quote__c> quoteMap, Boolean isInsert, Boolean isUpdate) {
        
        //get the list of renewed subscriptions
        set<Id> renewedSubscriptionIds = new set<Id>();
        Set<Id> setMainQuoteLineId = new Set<Id>();
        
        //convert the list of quotelines to a map
        map<Id, SBQQ__QuoteLine__c> mapQuoteLines = new map<Id, SBQQ__QuoteLine__c>();
        if ( isUpdate ) {
            mapQuoteLines.putAll(quoteLines);
        }
        
        for(SBQQ__QuoteLine__c qL : quoteLines) {
            
            //01/14/2021 - CR-20210107-14791 - Victor Hanson - bypass when Opp is Contracted
            if (qL.Opportunity_Contracted__c) 
                continue;
            
            //V_1.6 - Modified - 07/21/2017 - Saurabh Kumar - Added a check to fix null pointer exception
            //if this is a renewal, continue
            if (qL.SBQQ__RenewedSubscription__c != null && qL.Proposal_Type__c == CPQConstants.SBQQ_QUOTE_TYPE_RENEWAL)
                renewedSubscriptionIds.add(qL.SBQQ__RenewedSubscription__c);  
            
            //Added By Mahendra Swarnkar - 10/15/2019 -  CR-20191014-13409 
            //Populate the set to hold the main proposal lines
            if(qL.SBQQ__RequiredBy__c != null && qL.SBQQ__SegmentIndex__c == 1 && qL.Product_Category__c == CPQConstants.QUOTE_LINE_PROGRAM_SUBSCRIPTIONCATEGORY_ANNUAL_FEE && !mapQuoteLines.containsKey(qL.SBQQ__RequiredBy__c)){
                setMainQuoteLineId.add(qL.SBQQ__RequiredBy__c);
            }
        }
        
        if(renewedSubscriptionIds.size() > 0){
            
            //08/11/2020 - CR-20200730-14388 - Victor Hanson - Added RequiredbyProduct and Family fields
            //get all the subscriptions
            map<Id, SBQQ__Subscription__c> subscriptionMap = new map<Id, SBQQ__Subscription__c>();
            for(SBQQ__Subscription__c subsc : [SELECT Id, SBQQ__ListPrice__c, Product_Code__c, SBQQ__SpecialPrice__c, SBQQ__RenewalUpliftRate__c, SBQQ__RenewalPrice__c, 
                                                        Top_Parent_Product__c, Top_Parent_Product__r.Family, SBQQ__AdditionalDiscountAmount__c, SBQQ__Discount__c ,
                                                        SBQQ__RequiredByProduct__c, SBQQ__RequiredByProduct__r.Family
                                                        FROM SBQQ__Subscription__c WHERE Id IN :renewedSubscriptionIds]
            ){
                subscriptionMap.put(subsc.Id, subsc);
            }   
            
            if(subscriptionMap.size() > 0 ) {
                
                //Map main quotelines to be update
                Map<Id, Decimal> mapMainQuoteIdWithPreviousPeriodNegotiatedValue = new Map<Id, Decimal>();
                
                //List main quotelines to be update
                List<SBQQ__QuoteLine__c> listMainQuoteLineToBeUpdate = new List<SBQQ__QuoteLine__c>();
                
                for (SBQQ__QuoteLine__c qL : quoteLines) {
                    
                    //get the old quoteline, if this is an update
                    SBQQ__QuoteLine__c oldQL;
                    
                    if (mapOldQuoteLines != null && mapOldQuoteLines.containsKey(qL.Id))
                        oldQL = mapOldQuoteLines.get(qL.Id);
                    
                    if(qL.SBQQ__RenewedSubscription__c != null && qL.SBQQ__RequiredBy__c != null 
                        && subscriptionMap.containsKey(qL.SBQQ__RenewedSubscription__c) 
                        && subscriptionMap.get(qL.SBQQ__RenewedSubscription__c) != null
                    ){
                        
                        
                        //get the related subscription
                        SBQQ__Subscription__c subscription = subscriptionMap.get(qL.SBQQ__RenewedSubscription__c);
                        
                        // Populate the special Price type
                        qL.SBQQ__SpecialPriceType__c = CPQConstants.SBQQ_QUOTE_TYPE_RENEWAL;
                        
                        //Only set the listprice to renewalPrice when RenewalPrice is not null or zero.
                        if (subscription.SBQQ__RenewalPrice__c != null && subscription.SBQQ__RenewalPrice__c != 0 ) {
                            
                    	    //08/11/2020 - CR-20200730-14388 - Victor Hanson - Also set list price if renewal sub family is EAB Research
                            //Only set the listprice to renewalPrice when RenewalPrice is not null or zero. and don't set list price for ES products as it will set from the calculator
                            if((subscription.SBQQ__RequiredByProduct__c != null && subscription.SBQQ__RequiredByProduct__r.Family == PRODUCT_FAMILY_RESEARCH) || Sched_QuoteLinesTrigger.quoteLineTriggerFromScheduler
                               || (subscription.Top_Parent_Product__c != null && subscription.Top_Parent_Product__r.Family != 'Enrollment Services') )
                            {
                                qL.SBQQ__ListPrice__c = subscription.SBQQ__RenewalPrice__c;
                            }
                            
                            /*Mahendra Swarnkar - 12/31/2019 - CR-20191216-13563 - Fix for :-  
                            *    a) Issue #491 (population of Additional discount in Segment product section) - populating SBQQ__SpecialPrice__c with subscription.SBQQ__RenewalPrice__c in insert case
                            */
                            if(isInsert){
                                qL.SBQQ__SpecialPrice__c = subscription.SBQQ__RenewalPrice__c;
                        	//08/11/2020 - CR-20200730-14388 - Victor Hanson - Don't populate additionalDiscountAmount if Family is EAB Research
                                //clear the additionalDiscount for EAB Research products
                                if (subscription.SBQQ__RequiredByProduct__c != null && subscription.SBQQ__RequiredByProduct__r.Family != PRODUCT_FAMILY_RESEARCH) {
                                    qL.SBQQ__AdditionalDiscountAmount__c = null;
                                }
                            }
                            
                            /*Mahendra Swarnkar - 12/31/2019 - CR-20191216-13563 - Fix for :-  
                            *    b) Issue #428(not retaining the values on QLE) -  populating SBQQ__SpecialPrice__c with subscription.SBQQ__RenewalPrice__c in update case, only if SBQQ__SpecialPrice__c is null 
                            */
                            if (isUpdate && qL.SBQQ__SpecialPrice__c == null  )  {
                                qL.SBQQ__SpecialPrice__c = subscription.SBQQ__RenewalPrice__c;
                            }
                            //Added By mahendra Swarnkar - 06/15/2021 - CR-20210615-15214 - Starts from here
                            if(subscription.Product_Code__c == 'Additional Discount'){
                                qL.SBQQ__SpecialPrice__c = 0;
                                qL.SBQQ__ListPrice__c = 0;
                                qL.SBQQ__ProratedPrice__c = 0;
                            }
                            //Added By mahendra Swarnkar - 06/15/2021 - CR-20210615-15214 - Ends here
                        }
                        
                        if(isInsert && Sched_QuoteLinesTrigger.quoteLineTriggerFromScheduler){
                            
                            //08/11/2020 - CR-20200730-14388 - Victor Hanson - Don't populate additionalDiscountAmount if Family is EAB Research
                            if(subscription.SBQQ__AdditionalDiscountAmount__c != null && (subscription.SBQQ__RequiredByProduct__c == null || subscription.SBQQ__RequiredByProduct__r.Family != PRODUCT_FAMILY_RESEARCH)){
                                qL.SBQQ__AdditionalDiscountAmount__c = subscription.SBQQ__AdditionalDiscountAmount__c; 
                                
                            } else{
                                qL.SBQQ__AdditionalDiscountAmount__c = null;
                            }
                                
                            //08/11/2020 - CR-20200730-14388 - Victor Hanson - Don't populate additionalDiscountAmount if Family is EAB Research
                            if(subscription.SBQQ__Discount__c != null && (subscription.SBQQ__RequiredByProduct__c == null || subscription.SBQQ__RequiredByProduct__r.Family != 'EAB Research')) {
                                qL.SBQQ__Discount__c = subscription.SBQQ__Discount__c;
                            } else {
                                qL.SBQQ__Discount__c = null;
                            }
                        }   
                        
                        //only populate the following fields if segment index is 1.  Issue--CR10808--QA--00005034
                        if (qL.SBQQ__SegmentIndex__c == 1) {
                            
                            qL.SBQQ__PreviousSegmentPrice__c = subscription.SBQQ__RenewalPrice__c;
                            qL.SBQQ__PreviousSegmentUplift__c = 0;
                            
                            if (isInsert)
                                qL.SBQQ__Uplift__c = subscription.SBQQ__RenewalUpliftRate__c;
                            
                            //set the main QuoteLine's previous period negotiated
                            if (qL.Product_Category__c == CPQConstants.QUOTE_LINE_PROGRAM_SUBSCRIPTIONCATEGORY_ANNUAL_FEE) {
                                
                                if(mapQuoteLines.size() > 0 && mapQuoteLines.containsKey(qL.SBQQ__RequiredBy__c) && mapQuoteLines.get(qL.SBQQ__RequiredBy__c) != null){
                                    
                                    mapQuoteLines.get(qL.SBQQ__RequiredBy__c).Previous_Period_Negotiated__c = subscription.SBQQ__RenewalPrice__c;
                                }
                                //Added By Mahendra Swarnkar - 10/15/2019 -  CR-20191014-13409 - Starts from here
                                //populate the map to hold the main quotelines to be update with the Previous Period Negotiated Value
                                else if(setMainQuoteLineId.size() > 0 && setMainQuoteLineId.contains(qL.SBQQ__RequiredBy__c)){
                                    
                                    //If not from the scheduler
                                    if(!Sched_QuoteLinesTrigger.quoteLineTriggerFromScheduler){                                    
                                        mapMainQuoteIdWithPreviousPeriodNegotiatedValue.put(qL.SBQQ__RequiredBy__c, subscription.SBQQ__RenewalPrice__c);
                                    } else {
                                        listMainQuoteLineToBeUpdate.add(new SBQQ__QuoteLine__c(Id = qL.SBQQ__RequiredBy__c, Previous_Period_Negotiated__c = subscription.SBQQ__RenewalPrice__c));
                                    }
                                }
                                //Added By Mahendra Swarnkar - 10/15/2019 -  CR-20191014-13409 - Ends here
                            }
                        }
                    }
                }
                
                //Added By Mahendra Swarnkar - 10/15/2019 -  CR-20191014-13409 - Starts from here
                if(mapMainQuoteIdWithPreviousPeriodNegotiatedValue.size() > 0 ){
                    
                    //If not from the scheduler
                    if(!Sched_QuoteLinesTrigger.quoteLineTriggerFromScheduler){
                        
                        //call the future method to update the main quotelines
                        updatePreviousPeriodNegotiated(mapMainQuoteIdWithPreviousPeriodNegotiatedValue);
                    } else {
                        
                        //Check for size
                        if(listMainQuoteLineToBeUpdate.size() > 0 ){
                            
                            //Bypass the triggers
                            Util.BypassAllTriggers = true;
                            
                            //Update the quotelines.
                            update listMainQuoteLineToBeUpdate;
                            
                            //Enable the trigger
                            Util.BypassAllTriggers = false;
                        }
                    }
                }
                //Added By Mahendra Swarnkar - 10/15/2019 -  CR-20191014-13409 - Starts from here
            }
        }
    }
    
    //Future Method to populate the Previous Period Negotiated Value on the main quoteline.
    @future
    public static void updatePreviousPeriodNegotiated(Map<Id, Decimal> mapMainQuoteIdWithPreviousPeriodNegotiatedValue) {
        
        //Check for size
        if(mapMainQuoteIdWithPreviousPeriodNegotiatedValue !=null && mapMainQuoteIdWithPreviousPeriodNegotiatedValue.size() > 0) {
            
            //List to hold the main quotelines to be update
            List<SBQQ__QuoteLine__c> listQuotelines = new List<SBQQ__QuoteLine__c>();
            
            //Loop over the quoteline Ids
            for(Id mainQuoteId : mapMainQuoteIdWithPreviousPeriodNegotiatedValue.keySet()) {
                
                //Populate the  list
                listQuotelines.add(new SBQQ__QuoteLine__c(Id = mainQuoteId, Previous_Period_Negotiated__c = mapMainQuoteIdWithPreviousPeriodNegotiatedValue.get(mainQuoteId)));
            }
            
            //Check for size
            if(listQuotelines.size() > 0 ){
                
                //Bypass the triggers
                Util.BypassAllTriggers = true;
                
                //Update the quotelines.
                update listQuotelines;
                
                //Enable the trigger
                Util.BypassAllTriggers = false;
            }
        }
    }
    
    /**
     * 
     *   @description    :   This method used to update Quantity=0 on amendment quotes if the Product already exists
     *
     *   @args           :   List<SBQQ__QuoteLine__c>, Map<Id, SBQQ__QuoteLine__c>
     *
     *   @return         :   void
     *
     *   @revision Log   :   V1.1 - Created - 07/08/2017 - Subhash Garhwal - Q2C Phase 2 - Issue - 00004805
     * 
     **/
    public static void updateQuantityOnAmendmentQuoteLines(List<SBQQ__QuoteLine__c> quoteLines) {
        
        //existing products
        map<Id, list<SBQQ__QuoteLine__c>> existingProductsMap = new map<Id, list<SBQQ__QuoteLine__c>>();
        
        //add productId for all Program Subscriptions where Existing = true
        for (SBQQ__QuoteLine__c qL : quoteLines) {
            
            //01/14/2021 - CR-20210107-14791 - Victor Hanson - bypass when Opp is Contracted
            if (qL.Opportunity_Contracted__c) 
                continue;
            
            //create a map of ProductID to QuoteLines
            if (qL.SBQQ__Bundle__c 
                && qL.SBQQ__Existing__c) {
                    
                    list<SBQQ__QuoteLine__c> qLines = existingProductsMap.get(qL.SBQQ__Product__c);
                    if (qLines == null) qLines = new list<SBQQ__QuoteLine__c>();
                    qLines.add(qL);
                    existingProductsMap.put(qL.SBQQ__Product__c, qLines);
            }
        }
        
        for (SBQQ__QuoteLine__c qL : quoteLines) {
            
            //if there are any Bundled QuoteLines with an existing product, the existing product(s) quantity need to be changed to zero
            if (qL.SBQQ__Bundle__c 
                && qL.SBQQ__Existing__c == false
                && existingProductsMap.containsKey(qL.SBQQ__Product__c)) {
                    
                //get the existing product(s) quantity to zero
                for (SBQQ__QuoteLine__c existingQuoteLine : existingProductsMap.get(qL.SBQQ__Product__c)) {
                    
                    //if quantity if greater than zero, change it to zero
                    if (existingQuoteLine.SBQQ__Quantity__c > 0)
                        existingQuoteLine.SBQQ__Quantity__c = 0;
                }
            }
        }
    }
    
    /**
     * 
     *   @description    :   Auto-populates invoiceArrangement on quoteLine so it's transferred to subscription and can be used in billing sched creation 
     *
     *   @args           :   List<SBQQ__QuoteLine__c>
     *
     *   @return         :   void
     *
     *   @revision Log   :   V1.0 - Created - 12/13/2019 - Victor Hanson - CR-20191030-13484
     * 			 :   V1.1 - Modified By - Mahendra Swarnkar - 08/31/2021 - CR-20201120-14707 - CPQ: Invoicing Arrangement in CPQ inconsistent at times
     * 
     **/
    public static void populateInvoicingArrangement(List<SBQQ__QuoteLine__c> quoteLines, Map<Id, SBQQ__QuoteLine__c> oldMapOfQuoteLines) {
        
        Set<Id> setProposalIds = new Set<Id>();
        
        //Loop over the Proposal Line
        for(SBQQ__QuoteLine__c pL : quoteLines) {
            
            //Modified By - Mahendra Swarnkar - 08/31/2021 - CR-20201120-14707 - CPQ: Invoicing Arrangement in CPQ inconsistent at times
            if(Trigger.isUpdate || Trigger.isInsert || String.isBlank(pL.Invoicing_Arrangement__c)){
                
                setProposalIds.add(pL.SBQQ__Quote__c);
            }
        }
        
        //Check for set size
        if(setProposalIds.size() > 0) {
            
            //Modified By - Mahendra Swarnkar - 08/31/2021 - CR-20201120-14707 - CPQ: Invoicing Arrangement in CPQ inconsistent at times
            //Map to hold the Proposals
            //Map<Id, SBQQ__Quote__c> mapProposals = new Map<Id, SBQQ__Quote__c>([Select Id, Invoice_Frequency__c From SBQQ__Quote__c Where Id IN : setProposalIds AND Invoice_Frequency__c != null]);
            Map<Id, SBQQ__Quote__c> mapProposals = quoteMap.size() > 0 && quoteMap.keyset().size() > 0 ? quoteMap : new Map<Id, SBQQ__Quote__c>();
            //Loop over the Proposal Line
            for(SBQQ__QuoteLine__c pL : quoteLines) {
                
                //VH 12/13/2019 - added to set invoicing arrangement field on main quoteLine so it transfers to Program Subscription
                SBQQ__Quote__c quote = mapProposals.get(pL.SBQQ__Quote__c);
                
                if (quote != null && pL.Invoicing_Arrangement__c != quote.Invoice_Frequency__c){
                    pL.Invoicing_Arrangement__c = quote.Invoice_Frequency__c;
                }
            }
            
            //Modified By - Mahendra Swarnkar - 08/31/2021 - CR-20201120-14707 - Commented bypass recursive calling check
            //BYPASS_populateInvoicingArrangement = true;
        }
    }
    /*
     *   @description    :   This method used to pass the Opt Out and Early Termination Date field values to blank 
     *
     *   @args           :   List<SBQQ__QuoteLine__c>
     *
     *   @return         :   void
     *
     *   @revision Log   :   V1.0 - Created - 08/11/2017 - Subhash Garhwal - Q2C Phase 2 - Issue--CR11094--QA--00005437
     *                       V1.2 - Modified - 03/12/2019 - Subhash Garhwal - CR-20190107-12809
     *                       V1.3 - Modified - 01/14/2021 - Victor Hanson -  - bypass quotelines where Opp is Contracted
     *			     V1.4 - Modified - 02/05/2021 - Subhash Garhwal - CR-20210113-14805
     * 
     **/
    public static void blankOptOutAndEarlyTerminationDateOnMainProposalLine(List<SBQQ__QuoteLine__c> quoteLines, Boolean isInsert){
        
      //Set to hold the Proposal Ids
      Set<Id> setProposalIds = new Set<Id>();
      
      //Check for flag
      if(isInsert){
      	isClearEarlyTerminationDate = true;    
      }
      //Loop over the Proposal Line
      for(SBQQ__QuoteLine__c pL : quoteLines) {
        
        //Commented condition for "pL.SBQQ__RequiredBy__c" By Subhash - 02/05/2021 - CR-20210113-14805
        //Check for Opt Out type
        if(isClearEarlyTerminationDate && !pL.Opportunity_Contracted__c /*&& pL.SBQQ__RequiredBy__c == null*/ && pL.SBQQ__Quote__c != null && pL.SBQQ__RenewedSubscription__c != null)
          setProposalIds.add(pL.SBQQ__Quote__c);
      }
      
      //Check for set size
      if(setProposalIds.size() > 0) {
        
        //Map to hold the Proposals
        Map<Id, SBQQ__Quote__c> mapProposals = new Map<Id, SBQQ__Quote__c>([Select Id From SBQQ__Quote__c Where Id IN : setProposalIds AND SBQQ__Type__c = 'Renewal']);
        
        //Loop over the Proposal Line
        for(SBQQ__QuoteLine__c pL : quoteLines) {
      
		//Commented condition for "pL.SBQQ__RequiredBy__c" By Subhash - 02/05/2021 - CR-20210113-14805
                //Check for Opt Out type
      		if(isClearEarlyTerminationDate /*&& pL.SBQQ__RequiredBy__c == null*/ && pL.SBQQ__Quote__c != null && pL.SBQQ__RenewedSubscription__c != null && mapProposals.containsKey(pL.SBQQ__Quote__c)) {
      
                  //V_2.9 - Modified - 03/12/2019 - Subhash Garhwal - CR-20190107-12809
                  //Check if Quote line is a component
                  if(pl.Component__c == false){
                      
                      //Blank the opt out related fields
                      pL.Early_Termination_Date__c = null;
                      pL.Opt_Out__c = null;
                      
                      //Added By Subhash - 02/05/2021 - CR-20210113-14805 - Starts from here
                      pL.Penalty_Fee_Amount__c = null;
                      pL.Days_Notice__c = null;
                      //Added By Subhash - 02/05/2021 - CR-20210113-14805 - Ends here
               }
            }
         }  
      }  
    }
    
    /**
     * 
     *   @description    :   This method fixes a rounding bug that is present on creation of some renewals, where an Additional Discount of -1 USD is added to some annual fees
     *
     *   @args           :   List<SBQQ__QuoteLine__c>, Map<Id, SBQQ__QuoteLine__c> mapOldQuoteLines
     *
     *   @return         :   void
     *
     *   @revision Log   :   V1.0 - Created - 08/15/2017 - Victor Hanson - Q2C Phase 2 - Issue--CR11094--QA--00005466
     * 
     **/
    public static void checkRenewalsForRoundingBug(List<SBQQ__QuoteLine__c> quoteLines, Map<Id, SBQQ__QuoteLine__c> mapOldQuoteLines){
      
      //check to see if this is a future method
        if (system.isFuture() || system.isBatch() || system.isQueueable() || system.isScheduled()) {
            
            //loop through each quoteLine
            for (SBQQ__QuoteLine__c qL : quoteLines) {
                
                //check to see if the additional discount amount has changed
                if (qL.SBQQ__AdditionalDiscountAmount__c != null && 
                    (mapOldQuoteLines == null || 
                     mapOldQuoteLines != null && qL.SBQQ__AdditionalDiscountAmount__c != mapOldQuoteLines.get(qL.Id).SBQQ__AdditionalDiscountAmount__c)) 
                {
                    
                    //if additional discount is being populated or changed within a future / batch job and the value is equal to 1, 
                    //clear it out, because that is being done by the SBQQ package due to a rounding issue.
                    if (math.abs(qL.SBQQ__AdditionalDiscountAmount__c) == 1)
                      qL.SBQQ__AdditionalDiscountAmount__c = null;
                }
            }
        }
    }
    
    /**
     * 
     *   @description    :   This method is used to update the place holder Customer Total field value with Custom Total field
     *
     *   @args           :   List<SBQQ__QuoteLine__c>
     *
     *   @return         :   void
     *
     *   @revision Log   :   V1.0 - Created - 08/18/2017 - Subhash Garhwal - Q2C Phase 2 - Issue--CR11141--QA--00005513
     * 
     **/
    public static void syncPHCustomerTotal(List<SBQQ__QuoteLine__c> quoteLines, Map<Id, SBQQ__QuoteLine__c> oldMapQuoteLines){
        
        //Map to update the Proposal Lines
        Map<Id, SBQQ__QuoteLine__c> mapProposalLinesToUpdate = new Map<Id, SBQQ__QuoteLine__c>();
        
        //Updated by Subhash Garhwal - 04/16/2020 - CR-20200409-13923 - Start here
        //List of quoteLines to update
        List<SBQQ__QuoteLine__c> quoteLinesToUpdate = new List<SBQQ__QuoteLine__c>();
        
        //Loop over the Prposal Line
        for(SBQQ__QuoteLine__c pL : quoteLines){
            
            //01/14/2021 - CR-20210107-14791 - Victor Hanson - bypass when Opp is Contracted
            if (pL.Opportunity_Contracted__c) 
                continue;
            //pL.Customer_Total_History__c = pL.SBQQ__CustomerTotal__c;
            
            if(oldMapQuoteLines == null || (pL.SBQQ__CustomerPrice__c != oldMapQuoteLines.get(pL.Id).SBQQ__CustomerPrice__c)){
                quoteLinesToUpdate.add(new SBQQ__QuoteLine__c(Id = pL.Id, Customer_Total_History__c = pL.SBQQ__CustomerTotal__c));
            }
        }
        
        if(quoteLinesToUpdate.size() > 0){
            //By pass all trigger
            util.bypassAllTriggers = true;
            
            if(!Test.isRunningTest())
                update quoteLinesToUpdate;
            
            util.bypassAllTriggers = false;
        }
        //Updated by Subhash Garhwal - 04/16/2020 - CR-20200409-13923 - End here
    }
    
    /**
     * 
     *   @description    :   Defaults "Renewed Subscription" field on QuoteLine if there is an active membership for this acct/program
     *
     *   @args           :   List<SBQQ__QuoteLine__c>
     *
     *   @return         :   void
     *
     *   @revision Log   :   V1.0 - Created - 08/30/2017 - Victor Hanson - Q2C Phase 2 - Issue--CR11094--UAT--00005444
     *                       V1.1 - 01/14/2021 - CR-20210107-14791 - Victor Hanson - bypass contracted or if record type is not renewal
     * 
     **/
    public static void checkForRenewalSubscription(list<SBQQ__QuoteLine__c> quoteLines) {
        
        //if we've already executed this once, return immediately
        if (Util.codeBypass.contains('checkForRenewalSubscription')) return;
        
        //record the fact that we have executed this method, so we don't run it again
        Util.codeBypass.add('checkForRenewalSubscription');
        
        //map of Account-Product-SegmentIndex -> QuoteLine
        Map<String, SBQQ__QuoteLine__c> mapKeyToQuoteLine = new Map<String, SBQQ__QuoteLine__c>();
        
        //get all Account and Product Ids
        Set<Id> productIds = new Set<Id>();
        Set<Id> productOptionIds = new Set<Id>();
        Set<Id> quoteIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        
        for (SBQQ__QuoteLine__c qL : quoteLines) {
            
            //01/14/2021 - CR-20210107-14791 - Victor Hanson - bypass when Opp is Contracted
            if (qL.Opportunity_Contracted__c) 
                continue;

            productIds.add(qL.SBQQ__Product__c);
            productOptionIds.add(qL.SBQQ__ProductOption__c);
            
            if (qL.SBQQ__Quote__c != null && !SBQQ_QuoteLineTriggerHelper.quoteIds.contains(qL.SBQQ__Quote__c))
                SBQQ_QuoteLineTriggerHelper.quoteIds.add(qL.SBQQ__Quote__c);
        }
        
        //make a map of productOptions
        Map<Id, SBQQ__ProductOption__c> mapProductOptions = new Map<Id, SBQQ__ProductOption__c>([SELECT Id, SBQQ__ConfiguredSKU__c
                                                                                                 FROM SBQQ__ProductOption__c WHERE Id IN :productOptionIds]);
        
        //get all proposals, so we can get the institution ids
        for (SBQQ__Quote__c quote : SBQQ_QuoteLineTriggerHelper.quoteMap.values()) {
            
            accountIds.add(quote.SBQQ__Opportunity2__r.AccountId);
        }
        
        //create our AccountId-Product(EDAF)-subProduct(annualFee)-SegmentIndex -> QuoteLine map
        for (SBQQ__QuoteLine__c qL : quoteLines) {
            
            //if the quote and productOption maps contain the corresponding values, add the key/value combo
            if (SBQQ_QuoteLineTriggerHelper.quoteMap.containsKey(qL.SBQQ__Quote__c) && mapProductOptions.containsKey(qL.SBQQ__ProductOption__c)) {
                
                //01/14/2021 - CR-20210107-14791 - Victor Hanson - skip if not renewal
                if (SBQQ_QuoteLineTriggerHelper.quoteMap.get(qL.SBQQ__Quote__c)?.SBQQ__Type__c != Constants.RENEWAL) {
                    continue;
                }

                Id accountId = SBQQ_QuoteLineTriggerHelper.quoteMap.get(qL.SBQQ__Quote__c).SBQQ__Opportunity2__r.AccountId;
                Id productId = mapProductOptions.get(qL.SBQQ__ProductOption__c).SBQQ__ConfiguredSKU__c;
                string key = accountId + '-' + productId + '-' + qL.SBQQ__Product__c + '-' + Integer.valueOf(qL.SBQQ__SegmentIndex__c);
                mapKeyToQuoteLine.put(key, qL);
            }
        }

        //01/14/2021 - CR-20210107-14791 - Victor Hanson - return immediately if no values in map
        if (mapKeyToQuoteLine.size() == 0) {
            return;
        }
        
        //key of AccountId-Product2Id to track which records we've already processed
        Set<String> checkedProducts = new Set<String>();
        
        //get all CPQ Subscriptions that are related to an active membership
        for (SBQQ__Subscription__c progSubscription : [SELECT Id, SBQQ__SubscriptionEndDate__c, 
                                                       SBQQ__Product__c, SBQQ__Account__c,SBQQ__SegmentEndDate__c,
                                                       (SELECT Id, SBQQ__SegmentIndex__c, SBQQ__Product__c 
                                                        FROM Subscriptions1__r) 
                                                       FROM SBQQ__Subscription__c
                                                       WHERE SBQQ__Account__c IN :accountIds
                                                       AND SBQQ__Product__c IN :productIds
                                                       AND Membership__r.Membership_Status__c LIKE 'Member %'
                                                       AND Stage_Period__c NOT IN : CPQConstants.SUBSCRIPTION_STAGE
                                                       ORDER BY SBQQ__SubscriptionEndDate__c DESC])
        {
            
            //continue if we've already got the Subscriptions for this Acct/Product
            if (checkedProducts.contains(progSubscription.SBQQ__Account__c + '-' + progSubscription.SBQQ__Product__c))
                continue;
            
            for (SBQQ__Subscription__c componentSubscription : progSubscription.Subscriptions1__r) {
                
                //create our key: AccountId-Product(EDAF)-subProduct(annualFee)-SegmentIndex
                //re-create the key so we can get the corresponding quoteLine
                string key = progSubscription.SBQQ__Account__c + '-' 
                    + progSubscription.SBQQ__Product__c + '-' 
                    + componentSubscription.SBQQ__Product__c + '-'
                    + componentSubscription.SBQQ__SegmentIndex__c;
                
                //get the quoteLine for the corresponding Account/Product/Segment
                SBQQ__QuoteLine__c qL = mapKeyToQuoteLine.get(key);
                
                //don't process if quoteLine is null
                if (qL != null) {
                    
                    //Updated condition to check "qL.SBQQ__RenewedSubscription__c" By Subhash - 02/05/2021 - CR-20210113-14805
                    //verify that the subscription's end date is earlier than the quoteLine's start date
                    if (qL.SBQQ__RenewedSubscription__c == null && progSubscription.SBQQ__SubscriptionEndDate__c < qL.SBQQ__StartDate__c)
                        qL.SBQQ__RenewedSubscription__c = componentSubscription.Id;
                }
                
            }
            
            //add this account/product combo to the set of checked products, because we only want to
            //process the first one, since it will be the most recent due to the ORDER BY part of query
            checkedProducts.add(progSubscription.SBQQ__Account__c + '-' + progSubscription.SBQQ__Product__c);
        }
    }
    
    /**
     * 
     *   @description    :   If a Proposal Line's Upgraded Subscription is updated as part of an amendment, then update the Program Subscription Status accordingly
     *
     *   @args           :   List<SBQQ__QuoteLine__c>
     *
     *   @return         :   void
     *
     *   @revision Log   :   V1.0 - Created - Subhash Garhawal 09/25/2018 -CR-20180607-12270
     * 
     **/
    public static void updateProSubscriptionStatusForAmendment(list<SBQQ__QuoteLine__c> quoteLines, Map<Id, SBQQ__QuoteLine__c> mapOldQuoteLines) {
        
        //Set to hold the subscription Ids
        Set<Id> setOfSubscriptionIds = new Set<Id>();
                
        //List to hold the Program Subscription to be updated
        List<SBQQ__Subscription__c> programSubscriptionsToBeUpdated = new List<SBQQ__Subscription__c>();
        
        //Loop over the quoteLines
        for(SBQQ__QuoteLine__c qL : quoteLines) {
            
            //Check for Upgraded Subscription
            if(qL.SBQQ__UpgradedSubscription__c != null &&  (mapOldQuoteLines == null || mapOldQuoteLines.get(qL.Id).SBQQ__UpgradedSubscription__c != qL.SBQQ__UpgradedSubscription__c)){
                
                //Add Ids into the set
                setOfSubscriptionIds.add(qL.SBQQ__UpgradedSubscription__c);
            }
        }
        
        //Size check
        if(setOfSubscriptionIds.size() > 0) {
            
            //Querey over the Program Subscription
            for(SBQQ__Subscription__c sub : [Select Id, SBQQ__Contract__c From SBQQ__Subscription__c Where Id IN : setOfSubscriptionIds
                                            AND SBQQ__Contract__r.Status =: CPQConstants.CONTRACT_STATUS_ACTIVATED_AMENDED]) {
                
                //Add values into the list to be updated
                programSubscriptionsToBeUpdated.add(new SBQQ__Subscription__c(Id = sub.Id, Status__c = 'Void-Amended'));
            }
        }
        //Size Check
        if (programSubscriptionsToBeUpdated.size() > 0) {
            
            util.bypassAllTriggers = true;
            update programSubscriptionsToBeUpdated;
            util.bypassAllTriggers = false;
        }
    }
    
    /**
     * 
     *   @description    :   If a quoteline has Quantity > 1, check if the product quantity is ediable.  If not, reset quantity to 1.
     *                       This fixes an issue that was seen when adding an upsell to an Enrollment Services Subscription and renewing.
     *
     *   @revision Log   :   V1.0 - Created - 01/04/2019 - Victor Hanson - CR-20181019-12685
     * 
     **/
    public static void updateQuantity(list<SBQQ__QuoteLine__c> quoteLines) {
        //get a list of product ids for QLs that have quantity greater than 1
        Set<Id> productIds = new Set<Id>();
        for (SBQQ__QuoteLine__c ql : quoteLines) {
            
            //01/14/2021 - CR-20210107-14791 - Victor Hanson - bypass when Opp is Contracted
            if (qL.Opportunity_Contracted__c) 
                continue;

            if (ql.SBQQ__Quantity__c > 1 || ql.SBQQ__PriorQuantity__c > 1 && ql.SBQQ__Product__c != null) {
                productIds.add(ql.SBQQ__Product__c);
            }
        }
        
        if (productIds.size() > 0) {
            Map<Id, Product2> productMap = new Map<Id, Product2>([SELECT Id, SBQQ__QuantityEditable__c, SBQQ__DefaultQuantity__c
                                                                 FROM Product2 WHERE Id IN :productIds]);
            for (SBQQ__QuoteLine__c ql : quoteLines) {
                Product2 product = productMap.get(ql.SBQQ__Product__c);
                //if quantity is greater than 1 and the product is not allowed to have quantity modified, set it back to default
                if (product != null && ql.SBQQ__Quantity__c > 1 && !product.SBQQ__QuantityEditable__c) {
                    ql.SBQQ__Quantity__c = (product.SBQQ__DefaultQuantity__c != null) ? product.SBQQ__DefaultQuantity__c : 1;
                }
                //amendment scenario
                else if (product != null && ql.SBQQ__PriorQuantity__c > 1 && !product.SBQQ__QuantityEditable__c) {
                    
                    ql.SBQQ__PriorQuantity__c = (product.SBQQ__DefaultQuantity__c != null) ? product.SBQQ__DefaultQuantity__c : 1;
                }
            }
        }
    }
    
    /**
     * 
     *   @description    :   This method fixes an issue on Renewals related to Contracts with Upsells / Adjustments where the renewal amount isn't carried forward properly
     *
     *   @args           :   List<SBQQ__QuoteLine__c>, Map<Id, SBQQ__QuoteLine__c> mapOldQuoteLines
     *
     *   @return         :   void
     *
     *   @revision Log   :   V1.0 - Created - 01/10/2019 - Victor Hanson - CR-20181019-12685
     * 
     **/
    public static void checkRenewalInitialPrice(List<SBQQ__QuoteLine__c> quoteLines, Map<Id, SBQQ__QuoteLine__c> mapOldQuoteLines){
      
        //check to see if this is a future method
        if (system.isFuture() || system.isBatch() || system.isQueueable() || system.isScheduled()) {
            
            //loop through each quoteLine
            for (SBQQ__QuoteLine__c qL : quoteLines) {
                
                //check to see if the additional discount amount has changed
                //mapOldQuoteLines != null && qL.SBQQ__AdditionalDiscountAmount__c != mapOldQuoteLines.get(qL.Id).SBQQ__AdditionalDiscountAmount__c
                if (qL.SBQQ__AdditionalDiscountAmount__c != null && 
                    (mapOldQuoteLines == null ||
                    mapOldQuoteLines != null && qL.SBQQ__AdditionalDiscountAmount__c != mapOldQuoteLines.get(qL.Id).SBQQ__AdditionalDiscountAmount__c)) 
                {
                    
                    //if additional discount is being populated or changed within a future / batch job and the value isn't 
                    //equal to the renewal amount from the related Subscription, 
                    //clear it out, because that is being done by the SBQQ package by default and has to be overridden
                    qL.SBQQ__AdditionalDiscountAmount__c = null;
                }
            }
        }
    }
    
    /**
     * 
     *   @description    :   This method is used to update the Total_Pending_Signature_Program_Cost_CPQ__c, Total_Pending_Signature_Postage_Cost_CPQ__c and 
     *                       Total_Pending_Signature_Media_Cost__c field values on Program Packages
     *
     *   @args           :   List<SBQQ__QuoteLine__c>, Map<Id, SBQQ__QuoteLine__c>
     *
     *   @return         :   void
     *
     *   @revision Log   :   V1.0 - Created - 01/11/2019 - Subhash Garhwal - CR-20181019-12685
     * 
     **/
    public static void syncupProgramPackages(List<SBQQ__QuoteLine__c> proposalLines, Map<Id, SBQQ__QuoteLine__c> mapOldProposalLines){
        
        //Set to hold the Subscription Period Ids
        Set<Id> setRenewedSubPeriodIds = new Set<Id>();
        
        //Set to hold the Subscription Period Ids for Total Pending Contracted Qty
        Set<Id> setRenewedSubPeriodForPendingContractedQty = new Set<Id>();
        
        //Loop over the Proposal Lines
        for(SBQQ__QuoteLine__c pL : proposalLines) {
            
            //Updated By Mahendra Swarnkar - 04/03/2019 - CR-20181019-12685 - to include the Postage cost and media cost fields in the conditions
            //if this is a renewal, continue
            if ((mapOldProposalLines == null && pL.SBQQ__RenewedSubscription__c != null 
                  && ((pL.SBQQ__CustomerTotal__c != null && pL.SBQQ__CustomerTotal__c > 0) || (pL.Postage_Costs__c != null && pL.Postage_Costs__c > 0) 
                        || (pL.Media_Costs__c != null && pL.Media_Costs__c > 0)))
                || (mapOldProposalLines != null && (pL.SBQQ__CustomerTotal__c != mapOldProposalLines.get(pL.Id).SBQQ__CustomerTotal__c 
                || pL.SBQQ__RenewedSubscription__c != mapOldProposalLines.get(pL.Id).SBQQ__RenewedSubscription__c
                || pL.Postage_Costs__c != mapOldProposalLines.get(pL.Id).Postage_Costs__c
                || pL.Media_Costs__c != mapOldProposalLines.get(pL.Id).Media_Costs__c))) {
        
                //Check new Subs
                if(pL.SBQQ__RenewedSubscription__c != null && pL.Renewed_Subscription_Period_Id__c != null)
                    setRenewedSubPeriodIds.add(pL.Renewed_Subscription_Period_Id__c);
        
                //Check old Sub
                if(mapOldProposalLines != null && mapOldProposalLines.get(pL.Id).SBQQ__RenewedSubscription__c != null && mapOldProposalLines.get(pL.Id).Renewed_Subscription_Period_Id__c != null)
                    setRenewedSubPeriodIds.add(mapOldProposalLines.get(pL.Id).Renewed_Subscription_Period_Id__c);               
            }
        
            //Check for Renewal
            if((mapOldProposalLines == null && pL.SBQQ__RenewedSubscription__c != null)
                || (mapOldProposalLines != null && (pL.SBQQ__RenewedSubscription__c != mapOldProposalLines.get(pL.Id).SBQQ__RenewedSubscription__c || pL.Paper_New_Names__c != mapOldProposalLines.get(pL.Id).Paper_New_Names__c
                    || pL.E_Only_New_Names__c != mapOldProposalLines.get(pL.Id).E_Only_New_Names__c || pL.Paper_Inquiry_Pool__c != mapOldProposalLines.get(pL.Id).Paper_Inquiry_Pool__c
                    || pL.E_Only_Inquiry_Pool__c != mapOldProposalLines.get(pL.Id).E_Only_Inquiry_Pool__c || pL.Paper_PRE_Names__c != mapOldProposalLines.get(pL.Id).Paper_PRE_Names__c
                    || pL.E_Only_PRE_Names__c != mapOldProposalLines.get(pL.Id).E_Only_PRE_Names__c))) {
        
                //Check new Subs
                if(pL.SBQQ__RenewedSubscription__c != null && pL.Renewed_Subscription_Period_Id__c != null)
                    setRenewedSubPeriodForPendingContractedQty.add(pL.Renewed_Subscription_Period_Id__c);
        
                //Check old Sub
                if(mapOldProposalLines != null && mapOldProposalLines.get(pL.Id).SBQQ__RenewedSubscription__c != null && mapOldProposalLines.get(pL.Id).Renewed_Subscription_Period_Id__c != null)
                    setRenewedSubPeriodForPendingContractedQty.add(mapOldProposalLines.get(pL.Id).Renewed_Subscription_Period_Id__c);           
            }
        }
        
        //Check Subscription Periods and Call Program Package class to populate Pending details
        if(setRenewedSubPeriodIds.size() > 0)
            ProgramPackageRoyallTriggerHelper.syncRenewalDetailsOnProgramPackage(setRenewedSubPeriodIds);
        
        //Check Subscription Periods and Call Program Package class to populate Pending details
        if(setRenewedSubPeriodForPendingContractedQty.size() > 0)
            ProgramPackageRoyallTriggerHelper.validateTotalContractedContactQty(setRenewedSubPeriodForPendingContractedQty, CPQConstants.ORIGIN_PROPOSAL_LINE);
    }
    
    /**
     * 
     *   @description    :   auto-populates custom attribute values on existing proposal lines on amendment.
     *
     *   @args           :   List<SBQQ__QuoteLine__c>, Map<Id, SBQQ__QuoteLine__c>
     *
     *   @return         :   void
     *
     *   @revision Log   :   V1.0 - Created - 04/22/2019 - Victor Hanson - 
     * 
     **/
    public static void populateESLinesOnAmendment(List<SBQQ__QuoteLine__c> quoteLines) {
        
        // Modified - Subhash Garhwal - CR-20200908-14494
        if(BYPASS_populateESLinesOnAmendment == false){
        Map<String, SBQQ__QuoteLine__c> mapKeyToQuoteLine = new Map<String, SBQQ__QuoteLine__c>();
        
        Set<Id> qIds = new Set<Id>();
        for (SBQQ__QuoteLine__c ql : quoteLines) {

            //01/14/2021 - CR-20210107-14791 - Victor Hanson - bypass when Opp is Contracted
            if (qL.Opportunity_Contracted__c) 
                continue;

            if (ql.SBQQ__Existing__c != null && ql.SBQQ__Existing__c == true && ql.SBQQ__RequiredBy__c != null) {
                qIds.add(ql.SBQQ__Quote__c);
            }
        }
        
        if (qIds.size() == 0) return;
        
        
        //get custom attributes
        Set<Id> parentProductIds = new Set<Id>();
        
	//Modified By - Rajeev Jain - CPQ Release 25 - 01/17/2021
        for (SBQQ__QuoteLine__c ql : [SELECT Id, Opportunity_Contracted__c, SBQQ__Product__c 
                                      FROM SBQQ__QuoteLine__c
                                      WHERE SBQQ__Quote__c IN :qIds 
                                      AND SBQQ__Existing__c = true]) 
        {
            parentProductIds.add(ql.SBQQ__Product__c);
        }
        
        if(parentProductIds.size() > 0) {

            
            Map<Id, List<ProductConfiguratorController.CustomAttribute>> productIdToCustomAttMap 
                = ProductConfiguratorController.getConfigurationAttributes(parentProductIds);
            
            String configAttFields = getConfigAttFields(productIdToCustomAttMap);
            
            if (configAttFields == null || configAttFields == '') return;
            
            //get a list of existing lines
            String qlQuery = 'SELECT Id, SBQQ__Quote__c, SBQQ__RequiredBy__c, SBQQ__Existing__c, SBQQ__Product__c, ' 
                + getConfigAttFields(productIdToCustomAttMap)
                + ' FROM SBQQ__QuoteLine__c '
                + ' WHERE SBQQ__Quote__c IN :qIds '
                + ' AND SBQQ__Existing__c = true';
            
            List<SBQQ__QuoteLine__c> qls = database.query(qlQuery);
            
            for (SBQQ__QuoteLine__c ql : qls) {
                mapKeyToQuoteLine.put(ql.SBQQ__Quote__c + '-' + ql.Id, ql);
            }
            
            
            //get each line's parent product, then populate each custom attribute
            for (SBQQ__QuoteLine__c ql : quoteLines) {
                
                SBQQ__QuoteLine__c parentQuoteLine = mapKeyToQuoteLine.get(ql.SBQQ__Quote__c + '-' + ql.SBQQ__RequiredBy__c);
                if (parentQuoteLine != null && parentQuoteLine.SBQQ__RequiredBy__c != null) {
                    parentQuoteLine = mapKeyToQuoteLine.get(ql.SBQQ__Quote__c + '-' + parentQuoteLine.SBQQ__RequiredBy__c);
                }
                
                //continue if parent quote line or segmentIndex is null
                if (parentQuoteLine == null || ql.SBQQ__SegmentIndex__c == null) continue;
                
                //populate each custom attribute
                for (ProductConfiguratorController.CustomAttribute attr : productIdToCustomAttMap.get( parentQuoteLine.SBQQ__Product__c )) {
                    
                    String csvFieldVal = String.valueOf(parentQuoteLine.get(attr.attribute.SBQQ__TargetField__c));
                    if (csvFieldVal != null) {
                        
                        Map<String, Object> obj = new Map<String, Object>();
                        try {
                            obj = (Map<String, Object>)JSON.deserializeUntyped(csvFieldVal);
                        }
                        catch(Exception e) {
                            system.debug('@@json parse error: '+e.getMessage());
                            continue;
                        }
                        
                        //
                        String yearString = (String)obj.get('yearValues');
                        List<String> listYears = yearString.split('\\|');
                        
                        if (ql.SBQQ__SegmentIndex__c != null && ql.SBQQ__SegmentIndex__c > 0 && listYears.size() > (ql.SBQQ__SegmentIndex__c-1)) {
                            
                            String value = listYears.get(integer.valueOf(ql.SBQQ__SegmentIndex__c-1));
                            
                            if (value != null) {
                                
                                try {
                                    
                                    if (attr.field.fieldType == 'Number' || attr.field.fieldType == 'PERCENT') {
                                        ql.put(attr.attribute.CSV_Map_Field__c, Decimal.valueOf(value));
                                    }
                                    else {
                                        ql.put(attr.attribute.CSV_Map_Field__c, value);
                                    }   
                                } catch(Exception e) {
                                    system.debug('@@json parse error: '+e.getMessage());
                                    continue;
                                } 
                            }
                        }
                    }
                }
            }
        }
	    // Modified - Subhash Garhwal - CR-20200908-14494
            BYPASS_populateESLinesOnAmendment = true;
        } 
    }
    
    /**
     * 
     *  @description    :   Returns a comma delimited list of Configuration Attribute fields associated with Quote Line Products
     * 
     *  @Revision Logs  :   V1.1 - 04/22/2019 - Created - Victor Hanson - CR-20181019-12685
     * 
    **/
    public static String getConfigAttFields (Map<Id, List<ProductConfiguratorController.CustomAttribute>> productIdToCustomAttMap) {
        Set<String> setFields = new Set<String>();
        List<String> allFields = new List<String>();
        
        
        //cycle through the whole map, adding each field to a set
        for (List<ProductConfiguratorController.CustomAttribute> customAttList : productIdToCustomAttMap.values()) {
            for (ProductConfiguratorController.CustomAttribute ca : customAttList) {
                
                if (ca.attribute.CSV_Map_Field__c != null && ca.attribute.SBQQ__TargetField__c != null) {
                    setFields.add(ca.attribute.CSV_Map_Field__c);
                    setFields.add(ca.attribute.SBQQ__TargetField__c);
                }
            }
        }
        allFields.addAll(setFields);
        return String.join(allFields, ',');
    }
    
    /**
     * 
     *   @description    :   This method used to update the Special Price type to blank if special price type is custom and special price is blank
     *
     *   @args           :   List<SBQQ__QuoteLine__c>, Map<Id, SBQQ__QuoteLine__c>
     *
     *   @return         :   void
     *
     *   @revision Log   :   V1.1 - Created - 05/13/2019 - Mahendra Swarnkar - CR-20190306-12914
     * 
     **/
    public static void populateSpecialPriceType(List<SBQQ__QuoteLine__c> quoteLines, Map<Id, SBQQ__QuoteLine__c> mapOldQuotelines) {
        
        for(SBQQ__QuoteLine__c qL : quoteLines) {

            //01/14/2021 - CR-20210107-14791 - Victor Hanson - bypass when Opp is Contracted
            if (qL.Opportunity_Contracted__c) 
                continue;

            //Insert/update case
            if(mapOldQuotelines == null || (mapOldQuotelines != null && (qL.SBQQ__SpecialPriceType__c != mapOldQuotelines.get(qL.Id).SBQQ__SpecialPriceType__c || qL.SBQQ__SpecialPrice__c != mapOldQuotelines.get(qL.Id).SBQQ__SpecialPrice__c ))){ 
                if(qL.SBQQ__SpecialPriceType__c == 'Custom' && qL.SBQQ__SpecialPrice__c == null)
                    qL.SBQQ__SpecialPriceType__c = null;
            }
        }
    }
    
    /**
     * 
     *   @description    :   This method used to Validate ESAM and ESOAM Paper and E-Only Year values
     *
     *   @args           :   List<SBQQ__QuoteLine__c>, Map<Id, SBQQ__QuoteLine__c>
     *
     *   @return         :   void
     *
     *   @revision Log   :   V1.1 - Created - 05/24/2019 - Subhash Garhwal - CR-20181019-12685
     * 
     **/
    public static void ValidateESAMAndESOAMProducts(List<SBQQ__QuoteLine__c> proposalLines, Map<Id, SBQQ__QuoteLine__c> mapOldProposalLines) {
        
        //Set to hold the Proposal Id
        Set<Id> setProposalIds = new Set<Id>();
        
        
        //Loop over the Proposal Lines
        for(SBQQ__QuoteLine__c pL : proposalLines) {
            
            //Check for field values
            if((pL.Related_Product_with_Parent_Product__c != null && (pL.Related_Product_with_Parent_Product__c.contains('ESAM') || pL.Related_Product_with_Parent_Product__c.contains('ESOAM')))
                && ((mapOldProposalLines == null && ((pL.Paper_Inquiry_Pool__c != null && pL.Paper_Inquiry_Pool__c > 0) || (pL.Paper_New_Names__c != null && pL.Paper_New_Names__c > 0)
                                                     || (pL.Paper_PRE_Names__c != null && pL.Paper_PRE_Names__c > 0) || (pL.E_Only_Inquiry_Pool__c != null && pL.E_Only_Inquiry_Pool__c > 0)
                                                     || (pL.E_Only_New_Names__c != null && pL.E_Only_New_Names__c > 0) || (pL.E_Only_PRE_Names__c != null && pL.E_Only_PRE_Names__c > 0)
                                                    )) || (mapOldProposalLines != null && (pL.Paper_Inquiry_Pool__c != mapOldProposalLines.get(pL.Id).Paper_Inquiry_Pool__c || pL.Paper_New_Names__c != mapOldProposalLines.get(pL.Id).Paper_New_Names__c
                                                      || pL.Paper_PRE_Names__c != mapOldProposalLines.get(pL.Id).Paper_PRE_Names__c || pL.E_Only_Inquiry_Pool__c != mapOldProposalLines.get(pL.Id).E_Only_Inquiry_Pool__c
                                                      || pL.E_Only_New_Names__c != mapOldProposalLines.get(pL.Id).E_Only_New_Names__c || pL.E_Only_PRE_Names__c != mapOldProposalLines.get(pL.Id).E_Only_PRE_Names__c)))) {
                
                //Get Proposal Id
                setProposalIds.add(pL.SBQQ__Quote__c);      
            }
        }
        
        if(setProposalIds.size() > 0) {
            
            //Map to hold the ESAM Product related details
            Map<String, Map<Decimal, Boolean>> mapESAMSubProductPaperAndEOnlyValues = new Map<String, Map<Decimal, Boolean>>();
            
            //Map to hold the ESOAM Product related details
            Map<String, Map<Decimal, Boolean>> mapESOAMSubProductPaperAndEOnlyValues = new Map<String, Map<Decimal, Boolean>>();
            
            //SOQL over the Super Child Proposal Lines
            for(SBQQ__QuoteLine__c pL : [Select Id, Name, SBQQ__Quote__c, Related_Product__c, SBQQ__RequiredBy__c, SBQQ__RequiredBy__r.SBQQ__RequiredBy__c, SBQQ__RequiredBy__r.SBQQ__RequiredBy__r.SBQQ__ProductCode__c,
                                                Paper_Inquiry_Pool__c, Paper_New_Names__c, Paper_PRE_Names__c, E_Only_Inquiry_Pool__c, E_Only_New_Names__c,
                                                E_Only_PRE_Names__c, SBQQ__SegmentIndex__c From SBQQ__QuoteLine__c Where SBQQ__Quote__c IN : setProposalIds
                                                AND SBQQ__RequiredBy__r.SBQQ__RequiredBy__c != null AND SBQQ__RequiredBy__r.SBQQ__RequiredBy__r.SBQQ__ProductCode__c IN : CPQConstants.SET_ESAM_ESOAM_CODES
                                                AND SBQQ__SegmentIndex__c != null]) {
                
                //Check Related Product (Sub Product)
                if(CPQConstants.MAP_PAPER_AND_EONLY_FIELDS_WITH_SUBPRODUCT.containsKey(pL.Related_Product__c)) {
                    
                    //Variable to identify if value is available in field or not
                    Boolean isValue = false;
                    
                    //Loop over the Fields
                    for(String pLField : CPQConstants.MAP_PAPER_AND_EONLY_FIELDS_WITH_SUBPRODUCT.get(pL.Related_Product__c)) {
                        
                        //Check for value
                        if(pL.get(pLField) != null && Integer.valueOf(pL.get(pLField)) > 0) {
                            
                            isValue = true;
                            break;
                        }
                    }
                    
                    if(isValue) {
                        
                        String Key =  pL.SBQQ__Quote__c + '-' + pL.Related_Product__c;
                            
                        //Check for Ultimate Parent
                        if(pL.SBQQ__RequiredBy__r.SBQQ__RequiredBy__r.SBQQ__ProductCode__c == 'ESAM') {
                            
                            //Check same field value for ESOAM Product
                            if(mapESOAMSubProductPaperAndEOnlyValues.containsKey(Key) && mapESOAMSubProductPaperAndEOnlyValues.get(Key).containsKey(pL.SBQQ__SegmentIndex__c))
                                throw new CustomException('ESAM & ESOAM both products can\'t have value for Paper and E-Only for same year');
                            else {
                                
                                //Check Related Product in map
                                if(!mapESAMSubProductPaperAndEOnlyValues.containsKey(Key))
                                    mapESAMSubProductPaperAndEOnlyValues.put(Key, new Map<Decimal, Boolean>());
                                
                                //Add details in map
                                mapESAMSubProductPaperAndEOnlyValues.get(Key).put(pL.SBQQ__SegmentIndex__c, true);
                            }
                        } else if(pL.SBQQ__RequiredBy__r.SBQQ__RequiredBy__r.SBQQ__ProductCode__c == 'ESOAM') {
                            
                            //Check same field value for ESOAM Product
                            if(mapESAMSubProductPaperAndEOnlyValues.containsKey(Key) && mapESAMSubProductPaperAndEOnlyValues.get(Key).containsKey(pL.SBQQ__SegmentIndex__c))
                                throw new CustomException('ESAM & ESOAM both products can\'t have value for Paper and E-Only for same year');
                            else {
                                
                                //Check Related Product in map
                                if(!mapESOAMSubProductPaperAndEOnlyValues.containsKey(Key))
                                    mapESOAMSubProductPaperAndEOnlyValues.put(Key, new Map<Decimal, Boolean>());
                                
                                //Add details in map
                                mapESOAMSubProductPaperAndEOnlyValues.get(Key).put(pL.SBQQ__SegmentIndex__c, true);
                            }       
                        }
                    }                                       
                }
            }
        }
    }
    
    /**
     *
     *   @description    :   Populate the "Increase Grade Committed Term Length" on Quote.
     *
     *   @args           :   List<SBQQ__Quote__c>
     *
     *   @return         :   void
     *
     *   @revision Log   :   V_1.0 - Created - Mahendra Swarnkar - CR-20181019-12685
     *               	     V_2.0 - Modified - Mahendra Swarnkar - 10/08/2019 - CR-20190911-13329
     *
    **/
    public static void validateGradeCriteriaCommittedTermLength(List<SBQQ__QuoteLine__c> quoteLines, Map<Id, SBQQ__QuoteLine__c> mapOldProposalLines) {
        
        //Set to hold the proposal Ids
        Set<ID> setProposalIds = new Set<ID>();
        
        //Loop Over the quotelines
        for(SBQQ__QuoteLine__c ql : quoteLines != null ? quoteLines : mapOldProposalLines.values()){ 
            
            if( quoteLines != null && ql.Early_Termination_Date__c != null && (mapOldProposalLines == null || (mapOldProposalLines != null &&
                                               (ql.Penalty_Fee_Amount__c != mapOldProposalLines.get(ql.Id).Penalty_Fee_Amount__c
                                                || ql.Early_Termination_Date__c != mapOldProposalLines.get(ql.Id).Early_Termination_Date__c
                                                || ql.SBQQ__EndDate__c != mapOldProposalLines.get(ql.Id).SBQQ__EndDate__c
                                                || ql.SBQQ__StartDate__c != mapOldProposalLines.get(ql.Id).SBQQ__StartDate__c
                                                || ql.SBQQ__AdditionalDiscountAmount__c != mapOldProposalLines.get(ql.Id).SBQQ__AdditionalDiscountAmount__c)))) {
                
                //Populate the set
                setProposalIds.add(ql.SBQQ__Quote__c);
            }
            
            //chek for delete case 
            if(quoteLines == null && mapOldProposalLines != null && mapOldProposalLines.get(ql.Id).SBQQ__Quote__c != null && mapOldProposalLines.get(ql.Id).Early_Termination_Date__c != null) {
                setProposalIds.add(mapOldProposalLines.get(ql.Id).SBQQ__Quote__c);
            }            
        }
        
        //Check for size
        if(setProposalIds.size() > 0){
            
            //Map to hold the Proposal Id as a key and list of related proposal lines as a value
            Map<Id, List<SBQQ__QuoteLine__c>> mapProposalIdWithListOfProposalLines = new Map<Id, List<SBQQ__QuoteLine__c>>();
            
            //Map to hold the proposal Id as a key and maximum opt out date on a product.
            Map<Id, Date> mapProposalIdWithMinEarlyTerminationDate = new Map<Id, Date>();
            
            //Query over the proposal lines
            for(SBQQ__QuoteLine__c qline : [Select Id, SBQQ__RequiredBy__c, Early_Termination_Date__c, Penalty_Fee_Amount__c, SBQQ__StartDate__c, SBQQ__EndDate__c,
                                                   SBQQ__CustomerTotal__c, SBQQ__AdditionalDiscountAmount__c, SBQQ__Quote__r.Grade_Criteria_Committed_Term_Length__c
                                                   From SBQQ__QuoteLine__c Where SBQQ__Quote__c IN : setProposalIds]){
                                                    
                
                //Populate the Map proposal Id with list of proposal lines
                if(!mapProposalIdWithListOfProposalLines.containsKey(qline.SBQQ__Quote__c))
                    mapProposalIdWithListOfProposalLines.put(qline.SBQQ__Quote__c, new List<SBQQ__QuoteLine__c>());
            
                mapProposalIdWithListOfProposalLines.get(qline.SBQQ__Quote__c).add(qline);
                
                //Check for conditions
                if(qline.SBQQ__RequiredBy__c == null && qline.Early_Termination_Date__c != null 
                    && (!mapProposalIdWithMinEarlyTerminationDate.containsKey(qline.SBQQ__Quote__c) 
                        || (mapProposalIdWithMinEarlyTerminationDate.containsKey(qline.SBQQ__Quote__c)
                            && mapProposalIdWithMinEarlyTerminationDate.get(qline.SBQQ__Quote__c) > qline.Early_Termination_Date__c))) {
                    
                    //Populate the Map Proposal Id with min opt Put date on quote
                    mapProposalIdWithMinEarlyTerminationDate.put(qline.SBQQ__Quote__c, qline.Early_Termination_Date__c);
                }
            }
            
            //check for size
            if(mapProposalIdWithListOfProposalLines != null && mapProposalIdWithListOfProposalLines.size() > 0){
                
                List<SBQQ__Quote__c> listProposalsToBeUpdate = new List<SBQQ__Quote__c>();
                
                //Loop over the Proposal Ids
                for(ID proposalId : mapProposalIdWithListOfProposalLines.keySet()){
                    
                    //Check for size
                    if(mapProposalIdWithListOfProposalLines.get(proposalId) != null
                        && mapProposalIdWithListOfProposalLines.get(proposalId).size() > 0 
                        && mapProposalIdWithMinEarlyTerminationDate.size() > 0 
                        && mapProposalIdWithMinEarlyTerminationDate.containsKey(proposalId) 
                        && mapProposalIdWithMinEarlyTerminationDate.get(proposalId) != null){
                        
                        //Get min opt Out date
                        Date minEarlyTerminationDate = mapProposalIdWithMinEarlyTerminationDate.get(proposalId);
                        
                        //Hold the Total Additional discount from the previous years of opt out date
                        Decimal totalDiscountOnEarlyTerminationDate = 0;
                        
                        //Hold the Total penalty fee applied on the Quote
                        Decimal totalPenaltyFee = 0;
                        Decimal gradeCriteriaCommittedTermLength = 0;
                        
                        //Hold the immidiate next year's Total Program fee (i.e customer Total)
                        Decimal totalNextYearProgramFee = 0;
                            
                        //Loop over the related quote lines
                        for( SBQQ__QuoteLine__c quoteLine : mapProposalIdWithListOfProposalLines.get(proposalId)) {
                            
                            //check for condition and then sum up the total additional Discounts for the year of opt out date
                            if(quoteLine.SBQQ__StartDate__c != null && quoteLine.SBQQ__EndDate__c != null && quoteLine.SBQQ__StartDate__c  <= minEarlyTerminationDate && quoteLine.SBQQ__EndDate__c >= minEarlyTerminationDate && quoteLine.SBQQ__AdditionalDiscountAmount__c != null){
                                totalDiscountOnEarlyTerminationDate = totalDiscountOnEarlyTerminationDate + quoteLine.SBQQ__AdditionalDiscountAmount__c;
                            }
                            
                            //check for condition and then sum up the total Immidiate next year's program fee
                            if(quoteLine.SBQQ__StartDate__c != null && quoteLine.SBQQ__EndDate__c != null 
                                && quoteLine.SBQQ__StartDate__c  <= (minEarlyTerminationDate.addYears(1)) 
                                && quoteLine.SBQQ__EndDate__c >= (minEarlyTerminationDate.addYears(1)) 
                                && quoteLine.SBQQ__CustomerTotal__c != null){
                                totalNextYearProgramFee = totalNextYearProgramFee + quoteLine.SBQQ__CustomerTotal__c;
                            }
                            
                            //check for condition and then sum up the total penalty fee amount 
                            if(quoteLine.SBQQ__RequiredBy__c == null && quoteLine.Penalty_Fee_Amount__c != null){
                                
                                totalPenaltyFee = totalPenaltyFee + quoteLine.Penalty_Fee_Amount__c;
                            }
                        }
                        
                         //For comparison hold the highest value in between total discount on early termination date and 10% of next years total program fee.
                         Decimal comparisonValue = (totalNextYearProgramFee * 0.1) >= totalDiscountOnEarlyTerminationDate ? (totalNextYearProgramFee * 0.1) : totalDiscountOnEarlyTerminationDate;
                        
                        //check if Total Penalty fee amount and set the flag to increase the committed term length. 
                        if(totalPenaltyFee > 0 && comparisonValue > 0 && totalPenaltyFee > comparisonValue) {
                        
                            //listProposalsToBeUpdate.add(new SBQQ__Quote__c(Id = proposalId, Increase_Grade_Committed_Term_Length__c = true, Grade_Criteria_Committed_Term_Length__c = gradeCriteriaCommittedTermLength));
                            listProposalsToBeUpdate.add(new SBQQ__Quote__c(Id = proposalId, Increase_Grade_Committed_Term_Length__c = true));
                        
                        } else{
                            listProposalsToBeUpdate.add(new SBQQ__Quote__c(Id = proposalId, Increase_Grade_Committed_Term_Length__c = false));
                        }   
                    }
                }
                
                //Check for size
                if(listProposalsToBeUpdate.size() > 0){
                    
                    //Bypass all the triggers
                    Util.bypassAllTriggers = true;
                    
                    //Update the proposal records 
                    update listProposalsToBeUpdate;
                    
                    //Enable all the triggers.
                    Util.bypassAllTriggers = false;
                }
            }
        }
    }
    
    /**
     * 
     *   @description    :  Auto-populates listPrice and specialPrice fields on QuoteLine.
     *                      This was done to fix a bug that CPQ Support can't pinpoint, but we know that when these fields
     *                      are not populated and you attempt to contract an Opportunity, Subscriptions don't get created.
     *
     *   @args           :  List<SBQQ__QuoteLine__c>, Map<Id, SBQQ__QuoteLine__c>
     *
     *   @return         :  void
     *
     *   @revision Log   :  V1.0 - Created - 08/07/2019 - Victor Hanson
     * 
     **/
    public static void populateQuoteLineFieldsForCPQ(List<SBQQ__QuoteLine__c> quoteLines) {
        //loop through all quoteLines and verify fields are populated
        for (SBQQ__QuoteLine__c ql : quoteLines) {
            //01/14/2021 - CR-20210107-14791 - Victor Hanson - bypass when Opp is Contracted
            if (qL.Opportunity_Contracted__c) 
                continue;

            if (ql.SBQQ__ListPrice__c == null) ql.SBQQ__ListPrice__c = 0;
            if (ql.SBQQ__SpecialPrice__c == null) ql.SBQQ__SpecialPrice__c = ql.SBQQ__ListPrice__c;
        }
    }
    
    /**
     * 
     *   @description    :  Auto-populates proration fields on quoteline
     *
     *   @args           :  List<SBQQ__QuoteLine__c>
     *
     *   @return         :  void
     *
     *   @revision Log   :  V1.0 - Created - 09/12/2019 - Victor Hanson - CR-20190912-13336
     * 			    V1.1 - Modified By - Subhash Garhwal - 01/05/2021 - CR-20210105-14768
     * 
     **/
    public static void updateProrateMultiplier(List<SBQQ__QuoteLine__c> quoteLines) {
        
        Set<String> setProductCodeToSetProration = new Set<String>{'AdditionalOnsites','ImplementationFee','ImplementationFeeSS'};
            
        if(quoteLines != null) {
            
            for (SBQQ__QuoteLine__c ql : quoteLines) {
                
                //01/14/2021 - CR-20210107-14791 - Victor Hanson - bypass when Opp is Contracted
                if (qL.Opportunity_Contracted__c) {
                    continue;
                }

            //if the quoteline has default prorate multiplier = 1
                if ( ( ql.SBQQ__Product__c != null && String.isNotBlank(ql.SBQQ__ProductCode__c)  && setProductCodeToSetProration.contains(ql.SBQQ__ProductCode__c))
                    || (ql.Default_Prorate_Multiplier_to_1__c != null && ql.Default_Prorate_Multiplier_to_1__c == true && ql.SBQQ__ProrateMultiplier__c != 1)) {
                        
                    decimal priceOverride = ql.SBQQ__ListPrice__c;
                    decimal additionalDiscountFromPercentToNumber = 0;
                    //if discount is populated, update priceOverride
                    if(ql.SBQQ__Discount__c != null && priceOverride != null) {
                        additionalDiscountFromPercentToNumber = (ql.SBQQ__Discount__c * priceOverride)/100;
                        priceOverride = priceOverride - additionalDiscountFromPercentToNumber;
                    }
                
                    if (ql.SBQQ__AdditionalDiscountAmount__c != null) {
                        priceOverride = priceOverride - ql.SBQQ__AdditionalDiscountAmount__c;
                    }
                
                    ql.SBQQ__ProrateMultiplier__c = 1;
                    ql.SBQQ__CustomerPrice__c = priceOverride;
                    ql.SBQQ__NetPrice__c = priceOverride;
                    ql.SBQQ__PartnerPrice__c = priceOverride;
                    ql.SBQQ__ProratedPrice__c = priceOverride;
                    ql.SBQQ__RegularPrice__c = priceOverride;
                    //VH added 07/26/2019 to fix issue #272
                    if (ql.SBQQ__ListPrice__c == 0) {
                        ql.SBQQ__ProratedListPrice__c = null;
                    }
                    else {
                        //VH 09/06/2019: fix for issue #357
                        ql.SBQQ__ProratedListPrice__c = ql.SBQQ__ListPrice__c;
                    }
                    
                        
                }
            }
        }
    }
    /**
     * 
     *   @description    :  Populates the Top Parent Products on the proposal lines
     *
     *   @args           :  List<SBQQ__QuoteLine__c>, Map<Id, SBQQ__QuoteLine__c>
     *
     *   @return         :  void
     *
     *   @revision Log   :  V1.0 - Created - 09/13/2019 - Mahendra Swarnkar - CR-20190911-13331
     * 
     **/
    public static void populateTopParentOnQuoteLines(List<SBQQ__QuoteLine__c> quoteLines) {
        
        //Map to hold the proposal Id with map of all of its child proposal lines
        Map<Id, Map<Id,SBQQ__QuoteLine__c>> mapProposalIdwithProposalLines = new Map<Id, Map<Id,SBQQ__QuoteLine__c>>();
        
        //loop through all quoteLines and verify fields are populated
        for (SBQQ__QuoteLine__c ql : quoteLines) {
            
            //01/14/2021 - CR-20210107-14791 - Victor Hanson - bypass when Opp is Contracted
            if (qL.Opportunity_Contracted__c) 
                continue;
            
            //Populate the Map
            if(!mapProposalIdwithProposalLines.containsKey(ql.SBQQ__Quote__c) && ql.Top_Parent_Product__c == null )
                mapProposalIdwithProposalLines.put(ql.SBQQ__Quote__c, new Map<Id, SBQQ__QuoteLine__c>());
            
        }

        //Check for size
        if(mapProposalIdwithProposalLines.size() > 0){
            
            //MAp Proposal lines to be updated
            Map<Id, SBQQ__QuoteLine__c> mapQuotelinesToBeUpdate = new Map<Id, SBQQ__QuoteLine__c>();
            
            //MAp parent line with list of child lines  
            Map<Id, List<SBQQ__QuoteLine__c>> mapParentQuotelineWithChildQuotelines = new Map<Id, List<SBQQ__QuoteLine__c>>();
            
	    //Modified By - Rajeev Jain - CPQ Release 25 - 01/17/2021
            //Query all the proposal lines related to the quotelines
            for(SBQQ__QuoteLine__c propLine : [Select Id, Opportunity_Contracted__c, SBQQ__Quote__c, SBQQ__RequiredBy__c, Top_Parent_Product__c, SBQQ__Product__c, SBQQ__Product__r.Parent_Product__c, SBQQ__RequiredBy__r.Top_Parent_Product__c From SBQQ__QuoteLine__c Where SBQQ__Quote__c IN : mapProposalIdwithProposalLines.keyset()]) {
                
                
                //populate the top parent product field value for Main proposal lines
                if(propLine.SBQQ__RequiredBy__c == null) { 
                    
                    //check  for Product
                    if(propLine.SBQQ__Product__c != null ){
                    
                        //If product have the parent product then populate top parent with parent product
                        if(propLine.SBQQ__Product__r.Parent_Product__c != null && propLine.Top_Parent_Product__c != propLine.SBQQ__Product__r.Parent_Product__c){
                            
                            propLine.Top_Parent_Product__c = propLine.SBQQ__Product__r.Parent_Product__c;
                            mapQuotelinesToBeUpdate.put(propLine.Id, propLine); 
                        } else  if(propLine.SBQQ__Product__r.Parent_Product__c == null){
                            
                            //if product not have the parent product then populate the top parent product with the product it self
                            if(propLine.Top_Parent_Product__c != propLine.SBQQ__Product__c) {
                            
                                propLine.Top_Parent_Product__c = propLine.SBQQ__Product__c;
                                mapQuotelinesToBeUpdate.put(propLine.Id, propLine); 
                            }
                        }
                        
                    } else {
                        
                        // if product is not populated on the quoteline then Top_Parent_Product__c is blank
                        if(propLine.Top_Parent_Product__c != null){
                        
                            propLine.Top_Parent_Product__c = null;
                            mapQuotelinesToBeUpdate.put(propLine.Id, propLine);
                        }   
                    }
                }
                
                //Populate the map parent lines with list of child lines
                if(propLine.SBQQ__RequiredBy__c != null ) {
                    
                    //check  for Product
                    if(propLine.SBQQ__Product__c != null && propLine.SBQQ__Product__r.Parent_Product__c != null && propLine.Top_Parent_Product__c != propLine.SBQQ__Product__r.Parent_Product__c){
                        propLine.Top_Parent_Product__c = propLine.SBQQ__Product__r.Parent_Product__c;
                            mapQuotelinesToBeUpdate.put(propLine.Id, propLine); 
                    
                    } else if(propLine.SBQQ__RequiredBy__r.Top_Parent_Product__c != null) {
                        propLine.Top_Parent_Product__c = propLine.SBQQ__RequiredBy__r.Top_Parent_Product__c;
                        mapQuotelinesToBeUpdate.put(propLine.Id, propLine);
                    }
                        
                    if(!mapParentQuotelineWithChildQuotelines.containsKey(propLine.SBQQ__RequiredBy__c))
                        mapParentQuotelineWithChildQuotelines.put(propLine.SBQQ__RequiredBy__c, new List<SBQQ__QuoteLine__c>());
                    
                    mapParentQuotelineWithChildQuotelines.get(propLine.SBQQ__RequiredBy__c).add(propLine);
                }
                
                //Popuate the map proposal with all relatd child proposal lines
                if(mapProposalIdwithProposalLines.containsKey(propLine.SBQQ__Quote__c)
                    && mapProposalIdwithProposalLines.get(propLine.SBQQ__Quote__c).size() > 0
                    && !mapProposalIdwithProposalLines.get(propLine.SBQQ__Quote__c).containsKey(propLine.Id))   
                    mapProposalIdwithProposalLines.get(propLine.SBQQ__Quote__c).put(propLine.Id, propLine);
            }
            
            //Check for size
            if(mapParentQuotelineWithChildQuotelines.size() > 0){
                
                //Loop over the parent quoteline Ids
                for(Id parentQuoteline : mapParentQuotelineWithChildQuotelines.keySet()){
                    
                    //method call to populate the top parent product on child lines
                    mapQuotelinesToBeUpdate = populateTopParentProductOnChildQuoteLines(mapParentQuotelineWithChildQuotelines, mapParentQuotelineWithChildQuotelines.get(parentQuoteline), mapQuotelinesToBeUpdate, mapProposalIdwithProposalLines);    
                }
                
                
                //update the quotelines
                if(mapQuotelinesToBeUpdate.size() > 0){
                    
                    //Bypass all the triggers
                    Util.bypassAllTriggers = true;
                    
                    //Update the proposal records 
                    update mapQuotelinesToBeUpdate.values();
                    
                    //Enable all the triggers.
                    Util.bypassAllTriggers = false;
                }               
            }
        }
    }
    
    /**
     * 
     *   @description    :  populate the top parent product on child quote lines (Recursive method)
     *
     *   @args           :  List<SBQQ__QuoteLine__c>, Map<Id, SBQQ__QuoteLine__c>
     *
     *   @return         :  void
     *
     *   @revision Log   :  V1.0 - Created - 09/13/2019 - Mahendra Swarnkar - CR-20190911-13331
     * 			 :  V1.1 - Modified By - CR-20210107-14791 - Victor Hanson - 01/14/2021 - bypass when Opp is Contracted
     * 
     **/
    public static Map<Id, SBQQ__QuoteLine__c> populateTopParentProductOnChildQuoteLines(Map<Id, List<SBQQ__QuoteLine__c>> mapParentQuotelineWithChildQuotelines, List<SBQQ__QuoteLine__c> childQuoteLines, Map<Id, SBQQ__QuoteLine__c> mapQuotelinesToBeUpdate, Map<Id, Map<Id,SBQQ__QuoteLine__c>> mapProposalIdwithProposalLines) {
        
        for(SBQQ__QuoteLine__c qline : childQuoteLines){
            
            //01/14/2021 - CR-20210107-14791 - Victor Hanson - bypass when Opp is Contracted
            if (qline.Opportunity_Contracted__c) 
                continue;
            
            //chek if quotelines is also having the chile quotelines
            if(mapParentQuotelineWithChildQuotelines.size() > 0 
                && mapParentQuotelineWithChildQuotelines.containsKey(qline.Id) 
                && mapParentQuotelineWithChildQuotelines.get(qline.Id) != null 
                && mapParentQuotelineWithChildQuotelines.get(qline.Id).size() > 0) {
                
                //method call to populate the top parent product on child lines
                mapQuotelinesToBeUpdate = populateTopParentProductOnChildQuoteLines(mapParentQuotelineWithChildQuotelines, mapParentQuotelineWithChildQuotelines.get(qline.Id), mapQuotelinesToBeUpdate, mapProposalIdwithProposalLines);
            
            } else {
                
                //Parent line instance
                SBQQ__QuoteLine__c parentQuoteline; 
                    
                //check if parent line is updated then pull the updated value
                if(mapQuotelinesToBeUpdate.containsKey(qline.SBQQ__RequiredBy__c)) {
                        
                    parentQuoteline = mapQuotelinesToBeUpdate.get(qline.SBQQ__RequiredBy__c);
                    
                } else {
                    
                    //if parent line not updated
                    if(mapProposalIdwithProposalLines.containsKey(qline.SBQQ__Quote__c) 
                        && mapProposalIdwithProposalLines.get(qline.SBQQ__Quote__c).containsKey(qline.SBQQ__RequiredBy__c)){
                        
                        parentQuoteline = mapProposalIdwithProposalLines.get(qline.SBQQ__Quote__c).get(qline.SBQQ__RequiredBy__c);
                    }
                }
                
                
                //Populate the top parent product value for the line
                /*if(parentQuoteline != null && qline.Top_Parent_Product__c != parentQuoteline.Top_Parent_Product__c){
                    qline.Top_Parent_Product__c = parentQuoteline.Top_Parent_Product__c;
                    mapQuotelinesToBeUpdate.put(qline.Id, qline);
                }*/
                
                //check  for Product and Populate the top parent product value for the line
                if(qline.SBQQ__Product__c != null && qline.SBQQ__Product__r.Parent_Product__c != null && qline.Top_Parent_Product__c != qline.SBQQ__Product__r.Parent_Product__c){
                    qline.Top_Parent_Product__c = qline.SBQQ__Product__r.Parent_Product__c;
                    mapQuotelinesToBeUpdate.put(qline.Id, qline);   
                    
                } else if(parentQuoteline != null && parentQuoteline.Top_Parent_Product__c != null && qline.Top_Parent_Product__c != parentQuoteline.Top_Parent_Product__c) {
                    qline.Top_Parent_Product__c = parentQuoteline.Top_Parent_Product__c;
                    mapQuotelinesToBeUpdate.put(qline.Id, qline);
                }                
            }
        }
        
        return mapQuotelinesToBeUpdate;
    }
    
    /**
     * 
     *   @description    :  Updates the Main products line fields
     *
     *   @args           :  List<SBQQ__QuoteLine__c>
     *
     *   @return         :  void
     *
     *   @revision Log   :  V1.0 - Created - 10/01/2019 - Mahendra Swarnkar - 
     * 
     **/
    public static void updateFieldsForMainProductLines(List<SBQQ__QuoteLine__c> quoteLines) {
        
        //Updated by Subhash Garhwal - CR-20200406-13909 - 04/07/2020 - Name changed from YouVisit main to Virtual Tour Main
        //Set to hold the ES main Products Name
        //Set<String> setESMainProductNames = new Set<String>{'Common/Other Application Marketing', 'Custom Application Marketing', 'Pipeline Analytics Main', 'SEO Audit Main', 'Special Urgent Mailing Main', 'Transfer Recruitment', 'Yield Optimization','Year Round Search','Virtual Tour Main', 'Virtual Tour Legacy', 'Virtual Tour Legacy (existing partners only)'};
        Set<String> setESMainProductCodes = new Set<String>{'ESOAM', 'ESAM', 'ESPAA', 'ESSEOM', 'ESSUMM', 'ESXFRR', 'ESYO','ESYRS','YOUVM', 'YOUVL', 'YOUVUG'};
        
        //Set to hold the product Ids
        Set<Id> setProductIds = new Set<Id>();
        
        //Loop Over the quotelines
        for (SBQQ__QuoteLine__c ql : quoteLines) {
            
            //01/14/2021 - CR-20210107-14791 - Victor Hanson - bypass when Opp is Contracted
            if (qL.Opportunity_Contracted__c) 
                continue;
        
            if ((ql.SBQQ__ListPrice__c != null && ql.SBQQ__ListPrice__c != 0)) {
                
                //Populate the Product Id set
                setProductIds.add(ql.SBQQ__Product__c);
            }
        }
        
        //Cheeck for aize
        if(setProductIds.size() > 0){
            
            //Query all products
            Map<Id,Product2> mapProducts = new Map<Id,Product2>([Select Id, name, SBQQ__Component__c, ProductCode from Product2 where Id IN : setProductIds OR ProductCode IN : setESMainProductCodes ]); 
            
            Set<String> setESMainProductNames = new Set<String>();
            for(Product2 prod : mapProducts.values()){
                if(prod.ProductCode != null && setESMainProductCodes.contains(prod.ProductCode))
                    setESMainProductNames.add(prod.Name);
            }
            //Loop over the quotelines
            for(SBQQ__QuoteLine__c ql : quoteLines) {    
            
                //check for main product lines
                if ((ql.SBQQ__ListPrice__c != null && ql.SBQQ__ListPrice__c != 0) && 
                    ql.SBQQ__Product__c != null && mapProducts.containsKey(ql.SBQQ__Product__c) && ( mapProducts.get(ql.SBQQ__Product__c).SBQQ__Component__c == false 
                        || (mapProducts.get(ql.SBQQ__Product__c).SBQQ__Component__c == true && setESMainProductNames.contains(ql.Related_Product__c)))) {
                    
                    //set the values
                    ql.SBQQ__CustomerPrice__c = 0;
                    ql.SBQQ__NetPrice__c = 0;
                    ql.SBQQ__ListPrice__c = 0;
                    ql.SBQQ__ProratedListPrice__c = 0;
                    ql.SBQQ__ProratedPrice__c = 0;
                    ql.SBQQ__RegularPrice__c = 0;
                    ql.SBQQ__SpecialPrice__c = 0;
                    //Check for the renewal Proposal.
                    ql.SBQQ__AdditionalDiscountAmount__c = 0;
                    
                }
            }
        }
    }
    /**
     * 
     *   @description    :  Populates the Previous contract Last Years quantity in the respective csv fields
     *
     *   @args           :  List<SBQQ__QuoteLine__c>
     *
     *   @return         :  void
     *
     *   @revision Log   :  V1.0 - Created - 10/15/2019 - Mahendra Swarnkar - CR-20190911-13329
     * 
     **/
    public static void populatePreviousContractLastYearQuantity(List<SBQQ__QuoteLine__c> quoteLines) {
        
        //Set Renewed Subscription Ids.
        Set<Id> setRenewedSubscriptionIds = new Set<Id>();
        
        //Loop over the quotelines
        for(SBQQ__QuoteLine__c qline: quoteLines) {
            
            //01/14/2021 - CR-20210107-14791 - Victor Hanson - bypass when Opp is Contracted
            if (qline.Opportunity_Contracted__c) 
                continue;

            //check if it is renewal line
            if(qline.SBQQ__RenewedSubscription__c != null){
                setRenewedSubscriptionIds.add(qline.SBQQ__RenewedSubscription__c);
            }
        }
        
        //Check for size
        if(setRenewedSubscriptionIds.size() > 0){
            //Map to hold the products name with respective paper/eonly quantity fields(CSV)
            Map<String, Set<String>> MAP_PRODUCT_NAME_TO_CSV_QUANTITY_FIELDS = CPQConstants.MAP_PRODUCT_NAME_TO_ADJUSTABLE_QUANTITY_FIELDS;
        
            //set to hold the paper eonly fields (CSV) from all the products.
            Set<String> setAllPaperEonlyCSVFields = new Set<String> ();
            
            //Populate the set
            for(String prodName : MAP_PRODUCT_NAME_TO_CSV_QUANTITY_FIELDS.keySet()){
                
                //check for size and populate set only for sub products
                if(!prodName.equalsIgnoreCase('Transfer Recruitment') && MAP_PRODUCT_NAME_TO_CSV_QUANTITY_FIELDS.get(prodName) != null && MAP_PRODUCT_NAME_TO_CSV_QUANTITY_FIELDS.get(prodName).size() > 0)
                    setAllPaperEonlyCSVFields.addAll(MAP_PRODUCT_NAME_TO_CSV_QUANTITY_FIELDS.get(prodName));
            }
            // map to hold the mapping betweeen quoteline fields (CSV) name with the Subscription fields name (CSV)  
            Map<String,String> mapQuotelineFieldsWithSubscriptionFieldMapping = mapQuotelineFieldsToSubscriptionFieldsMapping;
            
            //Map to hold the renewed subscriptions
            Map<Id, SBQQ__Subscription__c> mapRenewedSubscriptions = new Map<Id, SBQQ__Subscription__c>();
            
            //Check for size
            if(mapQuotelineFieldsWithSubscriptionFieldMapping != null && mapQuotelineFieldsWithSubscriptionFieldMapping.size() > 0 && mapQuotelineFieldsWithSubscriptionFieldMapping.values() != null ){
                
                //build query for subscriptions
                String qryStringSubscription = 'Select Id, SBQQ__Quantity__c, SBQQ__CustomerPrice__c, Subscription_Period__c, Subscription_Period__r.Program_Subscription__c, Subscription_Period__r.Program_Subscription__r.Program_Subscription__c,' + String.join(mapQuotelineFieldsWithSubscriptionFieldMapping.values(),',') + ' from SBQQ__Subscription__c ';
                
                //Fetch Subscription records and populate the map
                for(SBQQ__Subscription__c subs : (List<SBQQ__Subscription__c>)database.query(qryStringSubscription + + ' where Id IN : setRenewedSubscriptionIds')) {
                    mapRenewedSubscriptions.put(subs.Id, subs);
                }
                
                //Check for size
                if(mapRenewedSubscriptions.size() > 0){
                    
                    //Loop over the quotelines
                    for(SBQQ__QuoteLine__c qline: quoteLines) {
                        
                        //check if it is renewal line
                        if(qline.SBQQ__RenewedSubscription__c != null && mapRenewedSubscriptions.containsKey(qline.SBQQ__RenewedSubscription__c)) {
                            
                            //Get the renewed subscription
                            SBQQ__Subscription__c renewedSubscription = mapRenewedSubscriptions.get(qline.SBQQ__RenewedSubscription__c);
                            
                            //Loop over the CSV fields
                            for(String fApiNameQuoteline : mapQuotelineFieldsWithSubscriptionFieldMapping.keySet()){
                                
                                //Check if it is CSV field
                                if(fApiNameQuoteline.contains('CSV__c') && mapQuotelineFieldsWithSubscriptionFieldMapping.get(fApiNameQuoteline) != null){
                                    // Get the value from the field
                                    String fieldApiNameSubscription = mapQuotelineFieldsWithSubscriptionFieldMapping.get(fApiNameQuoteline);
                                    
                                    //Check for size
                                    if(renewedSubscription != null ){
                                        
                                        //Check for size
                                        if( String.IsNotBlank((String)renewedSubscription.get(fieldApiNameSubscription) )){
                                            
                                            //Deserialize the jason string from the Subscription field and hold the values into the map
                                            Map<String, Object> mapCSVFieldValueFromSubscription = (Map<String, Object>)JSON.deserializeUntyped((String)renewedSubscription.get(fieldApiNameSubscription));
                                            if(mapCSVFieldValueFromSubscription != null && mapCSVFieldValueFromSubscription.size() > 0 && mapCSVFieldValueFromSubscription.containsKey('yearValues') && String.isNotBlank((String)mapCSVFieldValueFromSubscription.get('yearValues'))){
                                                
                                                //Get the all Years values
                                                List<String> yearValuesSubs =  ((String)mapCSVFieldValueFromSubscription.get('yearValues')).replace('|','AAAA').split('AAAA');
                                                
                                                if(String.IsNotBlank((String)qline.get(fApiNameQuoteline))) {
                                                    
                                                    //Deserialize the jason string from the quoteline field and hold the values into the map
                                                    Map<String, Object> mapCSVFieldValueFromQuoteline = (Map<String, Object>)JSON.deserializeUntyped((String)qline.get(fApiNameQuoteline));
                                                    
                                                    //Check for size
                                                    if(yearValuesSubs != null && yearValuesSubs.size() > 0 && mapCSVFieldValueFromQuoteline != null  && mapCSVFieldValueFromQuoteline.size() > 0) {
                                                        
                                                        //Add the previous contract's last year quantity from the sunbscription into the jason string on the quoteline field
                                                        mapCSVFieldValueFromQuoteline.put('pYearQuantity', yearValuesSubs[yearValuesSubs.size()-1]);
                                                        qline.put(fApiNameQuoteline, JSON.serialize(mapCSVFieldValueFromQuoteline));
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }   
                            }
                            
                            /* //Populate the previous Year price
                            if(renewedSubscription.SBQQ__CustomerPrice__c != null)
                                qline.Previous_Year_Value__c = renewedSubscription.SBQQ__CustomerPrice__c;*/
                        }
                    }
                }
            }
        }
    }
    
    /**
     * 
     *   @description    :  returns the mapping of CSV field between the Quoteline and subscription
     *
     *   @args           :  
     *
     *   @return         :  Map<String,String>
     *
     *   @revision Log   :  V1.0 - Created - 10/15/2019 - Mahendra Swarnkar - CR-20190911-13329
     * 
     **/
    public static Map<String,String> mapQuotelineFieldsToSubscriptionFieldsMapping {
        
        get {
            //check for size
            if (mapQuotelineFieldsToSubscriptionFieldsMapping == null){
                
                mapQuotelineFieldsToSubscriptionFieldsMapping = new Map<String,String>();
                
                //Loop over the field mappings
                for(Field_Mapping__mdt fmapping : [SELECT Id, Source_Object_API_Name__c, Source_Field_API_Name__c, Target_Object_API_Name__c, Target_Field_API_Name__c,
                                                      (SELECT Id, Source_Value__c, Target_Value__c, Field_Mapping__r.Source_Field_API_Name__c, Field_Mapping__r.Target_Field_API_Name__c FROM Field_Mapping_Values__r)
                                                    FROM Field_Mapping__mdt WHERE DeveloperName = 'QuoteLine_to_Subscription' AND Active__c = true]) 
                {
                    //Loop over the field mapping values
                    for (Field_Mapping_Value__mdt fldMapValue : fmapping.Field_Mapping_Values__r) {
                        
                        //check for the source and Target values andd the populate the map
                        if (fldMapValue.get('Source_Value__c') != null && fldMapValue.get('Target_Value__c') != null && ((String)fldMapValue.get('Source_Value__c')).contains('CSV__c')) 
                            mapQuotelineFieldsToSubscriptionFieldsMapping.put( (String)fldMapValue.get('Source_Value__c'), (String)fldMapValue.get('Target_Value__c') );
                    }
                }
            } 
            //Return the map
            return mapQuotelineFieldsToSubscriptionFieldsMapping;
        }
        set;
    }
    
    /**
     * 
     *   @description    :  Populates the quoteline fields 
     *                      1) Previous contract Last Years quantity in the Previous_Year_Quantity__c field 
     *                      2) previous contract Last years value in the Previous_Year_Value__c field. 
     *                      3) set Is_Eligible_For_Approval__c field to true to invoke the deal desk approval when matching the condition:- 
     *                          a) If any sub product’s quantity (total for Paper and e-only) is the same or less as the previous contract’s last year’s quantity , but the price is greater than 6.5%, send to Deal Desk for approval. Ignore for products that don’t have quantity fields
     *                          b) If any sub product’s price or quantity (total for Paper and e-only) is less than the previous contract’s last year’s price or quantity, send to Deal Desk for approval. Ignore for products that don’t have quantity fields
     *
     *   @args           :  List<SBQQ__QuoteLine__c>
     *
     *   @return         :  void
     *
     *   @revision Log   :  V1.0 - Created - 10/16/2019 - Mahendra Swarnkar - CR-20190911-13329
     * 
     **/
    public static void populatePrevContractLastYearTotalQuantityAndValue(List<SBQQ__QuoteLine__c> quoteLines) {
        
        //Set to hold the 
        Set<Id> setQuoteIds = new Set<Id>();
        
        //loop over the quotelines
        for(SBQQ__QuoteLine__c ql : quoteLines){
            
            //01/14/2021 - CR-20210107-14791 - Victor Hanson - bypass when Opp is Contracted
            if (qL.Opportunity_Contracted__c) 
                continue;

            //Check for the renewals and then populate the quote id set
            if(ql.SBQQ__Quote__c != null && ql.SBQQ__RenewedSubscription__c != null)
                setQuoteIds.add(ql.SBQQ__Quote__c);
        }
        //check for size
        if(setQuoteIds.size() > 0){
            
            //call the future method
            populatePrevContractLastYearTotalQuantityAndValueFuture(setQuoteIds);
        }

    }
    
    //@future
    public static void populatePrevContractLastYearTotalQuantityAndValueFuture(Set<Id> setQuoteIds) {
    
        //Check for size
        if(setQuoteIds.size() > 0){
            
            //Fetch quoteline records records and hold them into the map
            Map<Id, SBQQ__QuoteLine__c> mapQuotelines = new Map<Id, SBQQ__QuoteLine__c>([Select Id, SBQQ__RequiredBy__c,SBQQ__CustomerTotal__c, /*Previous_Year_Value__c,*/ Previous_Period_Negotiated__c, Is_Eligible_For_Approval__c, Total_Paper_E_Only_Quantity__c,
                                                                                         E_Only_New_Names_CSV__c, Paper_New_Names_CSV__c,E_Only_PRE_Names_CSV__c, Paper_PRE_Names_CSV__c,Paper_Inquiry_Pool_CSV__c, SBQQ__Product__c,
                                                                                         E_Only_Inquiry_Pool_CSV__c,Paper_Client_Provided_Inquiries_CSV__c,E_Only_Client_Provided_Inquiries_CSV__c,
                                                                                         Paper_EAB_Generated_Inquiries_CSV__c,E_Only_EAB_Generated_Inquiries_CSV__c,Paper_Transfer_Marketing_CSV__c, 
                                                                                         E_only_Transfer_Marketing_CSV__c, Paper_Quantity_Fulfillment_CSV__c,E_Only_Quantity_Fulfillment_CSV__c, Student_Journey_Quantity_Arch_CSV__c,
                                                                                         Student_Journey_Quantity_Bus_CSV__c, Student_Journey_Quantity_COE_CSV__c, Student_Journey_Quantity_DC_CSV__c, Student_Journey_Quantity_Edu_CSV__c,
                                                                                         Student_Journey_Quantity_Eng_CSV__c, Student_Journey_Quantity_GW_CSV__c, Student_Journey_Quantity_CSV__c, Student_Journey_Quantity_Law_CSV__c,
                                                                                         Student_Journey_Quantity_Nur_CSV__c, Student_Journey_Quantity_Pha_CSV__c, High_Affinity_Audience_Quantity_CSV__c, Deposit_IQ_Quantity_CSV__c,
                                                                                         Yield_IQ_Quantity_CSV__c, Guaranteed_Inquiries_CSV__c, Candidate_Names_CSV__c
                                                                                         From SBQQ__QuoteLine__c where SBQQ__Quote__c IN : setQuoteIds AND SBQQ__RenewedSubscription__c != null]);
            
            //Check for size
            if(mapQuotelines.size() > 0 ){
                
                // map to hold the mapping betweeen quoteline fields (CSV) name with the Subscription fields name (CSV)  
                Map<String, Set<String>> MAP_PRODUCT_NAME_TO_CSV_QUANTITY_FIELDS = CPQConstants.MAP_PRODUCT_NAME_TO_ADJUSTABLE_QUANTITY_FIELDS;
        
                //set to hold the paper eonly fields (CSV) from all the products.
                Set<String> setAllPaperEonlyCSVFields = new Set<String> ();
                
                //Populate the set
                for(String prodName : MAP_PRODUCT_NAME_TO_CSV_QUANTITY_FIELDS.keySet()){
                    
                    //check for size and populate set only for sub products
                    if(!prodName.equalsIgnoreCase('Transfer Recruitment') && MAP_PRODUCT_NAME_TO_CSV_QUANTITY_FIELDS.get(prodName).size() > 0)
                        setAllPaperEonlyCSVFields.addAll(MAP_PRODUCT_NAME_TO_CSV_QUANTITY_FIELDS.get(prodName));
                }
                
                //Map to hold the quotelines to be update
                Map<Id,SBQQ__QuoteLine__c> mapProposalLinesToUpdate = new Map<Id,SBQQ__QuoteLine__c>();
                
                //loop over the quotelines
                for(SBQQ__QuoteLine__c qline : mapQuotelines.values()) {
                    
                    //Parent (Middle) quoteline
                    SBQQ__QuoteLine__c parentQuoteline;
                    
                    //Top parent (main) quote line 
                    SBQQ__QuoteLine__c topParentQuoteline;
                    
                    //Check for size
                    if(qline.SBQQ__RequiredBy__c != null && mapQuotelines.containsKey(qline.SBQQ__RequiredBy__c)){
                        
                        //get the parent line
                        parentQuoteline = mapQuotelines.get(qline.SBQQ__RequiredBy__c);
                        
                        // check for size
                        if(parentQuoteline != null && parentQuoteline.SBQQ__RequiredBy__c != null
                            && mapQuotelines.containsKey(parentQuoteline.SBQQ__RequiredBy__c)) {
                            
                            //Get the main quoteline
                            topParentQuoteline = mapQuotelines.get(parentQuoteline.SBQQ__RequiredBy__c);   
                        }
                        else{
                            //set top parent and parent line 
                            topParentQuoteline = parentQuoteline;
                            parentQuoteline = qline;
                        }
                    }
                    
                    //check if middle quote line already proccessed then continue to next line 
                    //VH 10/28/2019 - added null check on parentQuoteLine
                    if(parentQuoteline != null && mapProposalLinesToUpdate.size() > 0 && !mapProposalLinesToUpdate.containsKey(parentQuoteline.Id)) continue;
                    
                    //Chekc for size
                    if(topParentQuoteline != null && parentQuoteline != null){
                        
                        //Holds tje sum of paper and e only quantity for first year                        
                        Integer totalPaperEonlyQuantity = 0;
                        
                        //Holds tje sum of paper and e only quantity for Previous contracts last year
                        Integer totalPaperEonlyQuantityPreviousContractLastYear = 0;
                        
                        //Loop over the CSV field names on quoteline. 
                        for(String fApiNameQuoteline : setAllPaperEonlyCSVFields){
                            
                            if(String.IsNotBlank((String)topParentQuoteline.get(fApiNameQuoteline))){
                                
                                //Get the CSV field values from the main quote line and deserialize it and stored in to the map
                                Map<String, Object> mapCSVFieldValueFromQuoteline = (Map<String, Object>)JSON.deserializeUntyped((String)topParentQuoteline.get(fApiNameQuoteline));
                                
                                //Check for the  matching sub products
                                if( mapCSVFieldValueFromQuoteline.containsKey('requiredByProductId') 
                                    && String.isNotBlank((String)mapCSVFieldValueFromQuoteline.get('requiredByProductId'))
                                    && parentQuoteline.SBQQ__Product__c != null
                                    && ((String)mapCSVFieldValueFromQuoteline.get('requiredByProductId')).contains(parentQuoteline.SBQQ__Product__c)) {
                                    
                                    if(mapCSVFieldValueFromQuoteline.containsKey('yearValues')
                                        && String.isNotBlank((String)mapCSVFieldValueFromQuoteline.get('yearValues'))){
                                        
                                        //Get the all years values
                                        List<String> yearValuesQuoteline = ((String)mapCSVFieldValueFromQuoteline.get('yearValues')).replace('|','AAAA').split('AAAA');
                                    
                                        //check for size and sum the first year quantity
                                        if(yearValuesQuoteline != null && yearValuesQuoteline.size() > 0)
                                            totalPaperEonlyQuantity = totalPaperEonlyQuantity + Integer.valueOf(yearValuesQuoteline[0]);
                                        
                                        //Get the previous contract's last year quantity and sum up it  
                                        if(mapCSVFieldValueFromQuoteline.containsKey('pYearQuantity'))
                                            totalPaperEonlyQuantityPreviousContractLastYear = totalPaperEonlyQuantityPreviousContractLastYear + (Integer)mapCSVFieldValueFromQuoteline.get('pYearQuantity');
                                     }
                                }
                            }
                        }
                        
                        //check for size and populate the field
                        if(totalPaperEonlyQuantity > 0 ) 
                            parentQuoteline.Total_Paper_E_Only_Quantity__c = totalPaperEonlyQuantity;
                        
                        //check for size and populate the field
                        if(totalPaperEonlyQuantityPreviousContractLastYear > 0) 
                            parentQuoteline.Previous_Year_Quantity__c = totalPaperEonlyQuantityPreviousContractLastYear;
                        
                        Decimal previousYearvalueToCompare = 0;
                         
                        //calculate the Previous contract's last year value for comparision
                        /*if(parentQuoteline.Previous_Year_Value__c != null) 
                            previousYearvalueToCompare = parentQuoteline.Previous_Year_Value__c + (parentQuoteline.Previous_Year_Value__c * 0.065);
                        */
                        if(parentQuoteline.Previous_Period_Negotiated__c != null) 
                            previousYearvalueToCompare = parentQuoteline.Previous_Period_Negotiated__c + (parentQuoteline.Previous_Period_Negotiated__c * 0.065);
                        //check the conditions to check if this proposal is eligible for sending the proposal to deal desk approval on the basis of (previous contracts last year quatity/prices and first year quatity/prices on the renewal proposal)    
                        if(parentQuoteline.Total_Paper_E_Only_Quantity__c > 0 && parentQuoteline.Previous_Period_Negotiated__c > 0 /*parentQuoteline.Previous_Year_Value__c > 0*/
                            && ((parentQuoteline.Total_Paper_E_Only_Quantity__c <= parentQuoteline.Previous_Year_Quantity__c 
                                && parentQuoteline.SBQQ__CustomerTotal__c > previousYearvalueToCompare)
                                || parentQuoteline.Total_Paper_E_Only_Quantity__c < parentQuoteline.Previous_Year_Quantity__c
                                || parentQuoteline.SBQQ__CustomerTotal__c < parentQuoteline.Previous_Period_Negotiated__c /*parentQuoteline.SBQQ__CustomerTotal__c < parentQuoteline.Previous_Year_Value__c*/))
                        {
                            //set the flag so that when user submit for approval it can be sent to the deal desk for approval
                            parentQuoteline.Is_Eligible_For_Approval__c = true;       
                        }
                        
                        //Populare the map
                        mapProposalLinesToUpdate.put(parentQuoteline.Id, parentQuoteline);
                    }
                }
                
                //check for size
                if(mapProposalLinesToUpdate.size() > 0 && mapProposalLinesToUpdate.values() != null && mapProposalLinesToUpdate.values().size() > 0) {
                    
                    //By pass all the triggers
                    Util.BypassAllTriggers = true;
                    
                    //Update the quote lines
                    update mapProposalLinesToUpdate.values();
                    
                    //Re-enables the triggers
                    Util.BypassAllTriggers = false;
                }
            }
        }
        
    }
    
    /**
     * 
     *   @description    :  To create the mandatory product when proposal and proposal line is inserted through DataLoader
     *
     *   @args           :  List<SBQQ__QuoteLine__c>
     *
     *   @return         :  void
     *
     *   @revision Log   :  V1.0 - Created - Subhash Garhwal - 11/07/2019
     *              	    V1.1 - Modified By - Subhash Garhwal - 10/2/2020 - CR-20200930-14570 - Added ApexJob check
     * 
     **/
    public static void validateAutomatedProductCreationProcess(List<SBQQ__QuoteLine__c> quoteLines){
        
        //Variable to control the Discount Product automation
        Boolean addDiscountProducts = false;
        
        for(SBQQ__QuoteLine__c ql : quoteLines){
            if(ql.SBQQ__RequiredBy__c == null) {
                
                addDiscountProducts = true;
                break;
            }
        } 
        
        if(addDiscountProducts && !System.isScheduled() ){
            
            //Check if scheduler is already scheduled
            List<AsyncApexJob> schedCreateAutomatedProductsForUploadJob = [Select Id,Status From AsyncApexJob Where Status IN ('Queued', 'Preparing') AND ApexClass.Name = 'Sched_CreateAutomatedProductsForUpload' ORDER BY CreatedDate DESC LIMIT 1];
            
            if(schedCreateAutomatedProductsForUploadJob.size() == 0) {
                
                dateTime sysTime = dateTime.now().addMinutes(5);
                String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
                Sched_CreateAutomatedProductsForUpload job = new Sched_CreateAutomatedProductsForUpload();
                System.schedule('Sched_CreateAutomatedProductsForUpload' + sysTime.getTime(), chron_exp, job);
                BYPASS_AutomatedProductCreation_METHOD = true;  
            }
            
        }
    }

    /**
     * 
     *   @description    :  Method to Check if a proposal created is of renewal type and then schedule Sched_QuoteLinesTrigger
     *
     *   @args           :  List<SBQQ__QuoteLine__c>
     *
     *   @return         :  void
     *
     *   @revision Log   :  V1.0 - Created - Subhash Garhwal - 01/18/2020 - CR-20200116-13628
     * 
     **/
    public static void validateRenewalProposal(List<SBQQ__QuoteLine__c> quoteLines) {
        
        //Set to hold the Quote ids
        Set<Id> setQuoteIds = new Set<Id>();
        
        //List to hold the Proposals to update
        List<SBQQ__Quote__c> listProposalsTobeUpdate = new List<SBQQ__Quote__c>();
        
        //loop over the new quotelines
        for(SBQQ__QuoteLine__c qLine : quoteLines) {
            
            //check for the conditions and populate the set and list
            if(!setQuoteIds.contains(qLine.SBQQ__Quote__c) && qLine.Proposal_Type__c == 'Renewal'){
                setQuoteIds.add(qLine.SBQQ__Quote__c);
                listProposalsTobeUpdate.add(new SBQQ__Quote__c(Id = qLine.SBQQ__Quote__c, Is_Renewal_From_QLE__c = True ));
            }
        }
        
        //Check for Size
        if(setQuoteIds.size() > 0 ) {
            
            //Map to hold the Proposals
            Map<Id, SBQQ__Quote__c> mapProposals = new Map<Id, SBQQ__Quote__c>([Select Id, Is_Renewal_From_QLE__c From SBQQ__Quote__c where Id IN : setQuoteIds ]); 
            
            //Loop over the lines
            for(SBQQ__QuoteLine__c quoteline : quoteLines) {
                
                //Check if quote line is created for renewal proposal.(Insert case of Renewal Prposal)
                if(String.isNotBlank(quoteline.Proposal_Type__c) && quoteline.Proposal_Type__c == 'Renewal' 
                   && mapProposals.size() > 0 && mapProposals.containsKey(quoteline.SBQQ__Quote__c) 
                   && mapProposals.get(quoteline.SBQQ__Quote__c).Is_Renewal_From_QLE__c == false
                ) {
                      //Set the flag
                      VALIDATE_RENEWAL_PROPOSALLINE = true;
                      break;
                } 
            }
            
            //Check for the flag
            if(VALIDATE_RENEWAL_PROPOSALLINE){
                
                //Set variable to true
                RENEWAL_PROPOSALLINE_FROM_SCHEDULER = true;
                
                //Call Scheduler from here
                Sched_QuoteLinesTrigger.scheduleQuotelineTrigger(setQuoteIds , quoteLines, SBQQ_QuoteLineTriggerHelper.BYPASS_SORT_ORDER_METHOD, SBQQ_QuoteLineTriggerHelper.BYPASS_UPDATEPREVIOUSSEGMENTPRICE, SBQQ_QuoteLineTriggerHelper.BYPASS_POPULATEAMENDPROPOSALLINESLISTPRICE, SBQQ_QuoteLineTriggerHelper.executeSyncProgramOpportunitiesLogic, trigger.isInsert, trigger.isUpdate);
                
                //Check for size and update the Proposal
                if(listProposalsTobeUpdate.size() > 0) {
                    Util.BypassAllTriggers = true;
                    update listProposalsTobeUpdate;
                    Util.BypassAllTriggers = false;
                }
            }
        }
    }
    
    /**
     * 
     *   @description    :  Method to Update the Primary Quote on the Opportunity if it is blank while creating the renewals from the scheduler.
     *
     *   @args           :  List<SBQQ__QuoteLine__c>
     *
     *   @return         :  void
     *
     *   @revision Log   :  V1.0 - Created - Subhash Garhwal - 01/18/2020 - CR-20200116-13628
     * 
     **/
    public static void updateOpportunityPrimaryProposal(Set<Id> setQuoteIds) {
        
        //Check for size
        if(setQuoteIds != null && setQuoteIds.size() > 0) {
            
            //List to hold the Opportunities to update
            List<Opportunity> listOpportunityToUpdate = new List<Opportunity>();
            
            //Get the proposal records
            for(SBQQ__Quote__c primaryQuote: [Select Id, SBQQ__Opportunity2__c, SBQQ__Opportunity2__r.SBQQ__PrimaryQuote__c, SBQQ__Primary__c From SBQQ__Quote__c 
                                                where Id IN : setQuoteIds AND SBQQ__Primary__c = true AND SBQQ__Opportunity2__c != null AND SBQQ__Opportunity2__r.SBQQ__PrimaryQuote__c = null ]) {
                
                //Populate the list
                listOpportunityToUpdate.add(new Opportunity(Id = primaryQuote.SBQQ__Opportunity2__c, SBQQ__PrimaryQuote__c = primaryQuote.Id ));
            }
            
            //Check for size
            if(listOpportunityToUpdate.size() > 0){
                
                //Update the opportunity records
                update listOpportunityToUpdate;
            }
        }
    } 
    /**
     * 
     *   @description    :  Auto-populates Start date on the Amendment if it is blank (Specifically for the implementation fee old product line).
     *
     *   @args           :  List<SBQQ__QuoteLine__c>, Map<Id, SBQQ__QuoteLine__c>
     *
     *   @return         :  void
     *
     *   @revision Log   :  V1.0 - Created - 01/31/2020 - Mahendra Swarnkar - CR-20190725-13235 AND CR-20200226-13809
     * 
     **/
    public static void populateStartDateOnImplementationFee(List<SBQQ__QuoteLine__c> quoteLines, Map<Id, SBQQ__QuoteLine__c> mapOldQuoteLines) {
        
        Set<Id> setQuoteIds = new Set<Id>();
        Set<Id> setGroupIds = new Set<Id>();
        
        //if(Trigger.isUpdate) {
            
            //loop through all quoteLines and verify fields are populated
            for (SBQQ__QuoteLine__c ql : quoteLines) { 
            
                //01/14/2021 - CR-20210107-14791 - Victor Hanson - bypass when Opp is Contracted
                if (qL.Opportunity_Contracted__c) {
                    continue;
                }
                
                if(ql.SBQQ__ProductCode__c == 'ImplementationFee' || ql.SBQQ__ProductCode__c == 'ImplementationFeeSS'){
                    
                    if(ql.SBQQ__Quote__c != null)
                        setQuoteIds.add(ql.SBQQ__Quote__c);
                    
                    if(ql.SBQQ__Group__c != null)
                        setGroupIds.add(ql.SBQQ__Group__c);
                    
                    //if (/*ql.SBQQ__Existing__c &&*/ ql.SBQQ__StartDate__c == null && ql.SBQQ__EffectiveStartDate__c != null ) 
                    //    ql.SBQQ__StartDate__c = ql.SBQQ__EffectiveStartDate__c;
                    
                    if (/*ql.SBQQ__Existing__c &&*/ ql.SBQQ__SegmentIndex__c == null ) 
                        ql.SBQQ__SegmentIndex__c = 1;
                }
            }
            
            if(setQuoteIds.size() > 0){
                Map<Id,SBQQ__Quote__c> mapQuotes = new Map<Id,SBQQ__Quote__c>(); 
                Map<Id,SBQQ__QuoteLineGroup__c> mapGroups = new Map<Id,SBQQ__QuoteLineGroup__c>(); 
                for(SBQQ__Quote__c quote: [Select Id, SBQQ__StartDate__c, SBQQ__EndDate__c, SBQQ__FirstSegmentTermEndDate__c, (Select Id, SBQQ__StartDate__c, SBQQ__EndDate__c From SBQQ__LineItemGroups__r Where ID IN : setGroupIds) From SBQQ__Quote__c where ID IN : setQuoteIds ]){
                    mapQuotes.put(quote.Id, quote);
                    if(quote.SBQQ__LineItemGroups__r != null && quote.SBQQ__LineItemGroups__r.size() > 0){
                        for(SBQQ__QuoteLineGroup__c qgroup: quote.SBQQ__LineItemGroups__r)
                            mapGroups.put(qgroup.Id, qgroup);
                    }
                }
                if(mapQuotes.size() > 0){
                    
                    for (SBQQ__QuoteLine__c qline : quoteLines) { 
                
                        if(qline.SBQQ__ProductCode__c == 'ImplementationFee' || qline.SBQQ__ProductCode__c == 'ImplementationFeeSS'){
                            Date ProposalLinecalculatedEndDate; 
                            Date startDate;
                            Date endDate;
                            SBQQ__QuoteLineGroup__c qlgroup;
                            SBQQ__Quote__c quote;
                            
                            if(qline.SBQQ__Group__c != null && mapGroups.size() > 0 && mapGroups.containsKey(qline.SBQQ__Group__c) && mapGroups.get(qline.SBQQ__Group__c) != null) 
                                qlgroup = mapGroups.get(qline.SBQQ__Group__c);
                            
                            if(qline.SBQQ__Quote__c != null && mapQuotes.containsKey(qline.SBQQ__Quote__c) && mapQuotes.get(qline.SBQQ__Quote__c) != null) 
                                quote = mapQuotes.get(qline.SBQQ__Quote__c);
                            
                            if(quote != null){
                                
                                if(qlgroup != null) {
                                    startDate = qlgroup.SBQQ__StartDate__c != null ? qlgroup.SBQQ__StartDate__c : quote.SBQQ__StartDate__c;
                                    endDate = qlgroup.SBQQ__EndDate__c != null ? qlgroup.SBQQ__EndDate__c : quote.SBQQ__EndDate__c;  
                                    
                                } else {
                                    startDate = quote.SBQQ__StartDate__c;
                                    endDate = quote.SBQQ__EndDate__c;
                                }
                                
                                //calculates the end date for proposal line.
                                ProposalLinecalculatedEndDate = getEndDateForImplementationFee(startDate, endDate);
                                
                                /*if(qline.SBQQ__Quote__r.SBQQ__FirstSegmentTermEndDate__c != null){
                                    ProposalLinecalculatedEndDate = qline.SBQQ__Quote__r.SBQQ__FirstSegmentTermEndDate__c;
                                }*/
                                if(quote.SBQQ__FirstSegmentTermEndDate__c != null && startDate < quote.SBQQ__FirstSegmentTermEndDate__c){
                                    ProposalLinecalculatedEndDate = quote.SBQQ__FirstSegmentTermEndDate__c;
                                }
                                qline.SBQQ__StartDate__c = startDate;
                                qline.SBQQ__EndDate__c = ProposalLinecalculatedEndDate;
                            }                            
                        }
                    }
                }
            }
        //}
    }
    
    public static Date getEndDateForImplementationFee(Date ProposalStartDate, Date ProposalEndDate) {
    
        //Dayes to Add
        Integer daysToAdd = 364;
        
        //Start Date Leap Year calculation
        if(Date.isLeapYear(ProposalStartDate.Year()) && (ProposalStartDate.month() ==1 || (ProposalStartDate.month() == 2 && ProposalStartDate.day() < 29))) {
            daysToAdd = 365;
        }
        
        Date returnDate;
        
        if(ProposalStartDate.daysBetween(ProposalEndDate) > 363) {
            returnDate = ProposalStartDate.addDays(daysToAdd);
        } else {
            returnDate = ProposalEndDate;
        }
    
        //End Date Leap Year calculation
        if(daysToAdd == 364 && Date.isLeapYear(returnDate.year()) && returnDate.month() > 2) {
            returnDate = returnDate.addDays(1);
        }
    
        return (Date.newInstance(returnDate.year(),returnDate.month(),returnDate.day()));
    }
    
     /**
     * 
     *   @description    :  Auto-populates all CSV field on the main proposal lines if relates sub-child lines is not blank.
     *
     *   @args           :  List<SBQQ__QuoteLine__c>, Map<Id, SBQQ__QuoteLine__c>
     *
     *   @return         :  void
     *
     *   @revision Log   :  V1.0 - Created - Subhash - 2/10/2020 - CR-20200210-13716
     *              	    V1.1 - Modified - Subhash - 9/9/2020 - CR-20200908-14494 - Moved the process in future to avoid any kind of exception while loading Legacy data  
     *                      V1.2 - Modified - Victor Hanson - 01/14/2021 - CR-20210107-14791 - bypass quotelines where Opp is Contracted
     * 
     **/
    public static void populateCSVFieldsOnMainProposalLines(List<SBQQ__QuoteLine__c> quoteLines, Map<Id, SBQQ__QuoteLine__c> mapOldQuoteLines) {
        
    	// Modified - Subhash Garhwal - CR-20200908-14494
        if(BYPASS_populateCSVFieldsOnMainProposalLines == false){
            BYPASS_populateCSVFieldsOnMainProposalLines = true;
        
            //Set of proposal Ids
            Set<Id> setProposalIds = new Set<Id>();
        
            //Loop over the new Lines
            for (SBQQ__QuoteLine__c ql : quoteLines) { 
                
                //01/14/2021 - CR-20210107-14791 - Victor Hanson - bypass when Opp is Contracted
                if (qL.Opportunity_Contracted__c) {
                    continue;
                }

                //Condition
                if(ql.SBQQ__SegmentIndex__c != null && ql.SBQQ__RequiredBy__c !=null && ql.SBQQ__Quote__c != null
                && (mapOldQuoteLines == null || mapOldQuoteLines != null)) 
                {
                   setProposalIds.add(ql.SBQQ__Quote__c);
                }
            }
        
            if(setProposalIds.size() > 0) {
            
                //Get quotes created via data loader only
                List<SBQQ__Quote__c> quotes = [Select Id, Legacy_Migrated_ES_Client__c From SBQQ__Quote__c Where Id IN:setProposalIds 
                                                And Legacy_Migrated_ES_Client__c = 'Migrated' /*AND Is_Enrollment_Services__c = true*/];
            
                //Check for size
                if(quotes.size() > 0) {
                
                    //Map to hold the Grans parent Id with parent Ids
                    Map<Id, set<Id>> mapGrandParentLineIdWithParentLineIds = new Map<Id, set<Id>>();
                
                    //Map to hold the parent Ids with child Ids 
                    Map<Id, List<SBQQ__QuoteLine__c>> mapParentLineIdWithchildLines = new Map<Id, List<SBQQ__QuoteLine__c>>();
                
                    /* Modified By - Subhash Garhwal - CR-20200908-14494
                    String querystr = 'SELECT Id, SBQQ__RequiredBy__c, SBQQ__SegmentIndex__c, SBQQ__RequiredBy__r.SBQQ__RequiredBy__c, SBQQ__RequiredBy__r.SBQQ__Product__c ';
                    for(Schema.FieldSetMember fsm : SObjectType.SBQQ__QuoteLine__c.FieldSets.CSV_Related_Field.getFields()) {
                        querystr += ', ' + fsm.getFieldPath();
                    }
                    querystr+= ' from Account limit 2';
                    */
        			
                    /*CR-20210325-15031 - 03/31/2021 - Added "Include_Digital_Media_Yield_IQ__c" and "Include_Digital_Media_Yield_IQ_CSV__c" in the query*/
                    //Updated by Victor Hanson - CR-20200408-13918 - 06/08/2020 - added fields to query (You_Visit_Package_Type_CSV__c, Yield_IQ_Quantity_CSV__c)
                    //Updated by Mahendra Swarnkar - CR-20200408-13918 - 05/18/2020 - to add a check for Implemention lines.
                    //Add all these fields into the field set.
                    for(SBQQ__QuoteLine__c qLine : [Select Id, SBQQ__RequiredBy__c, SBQQ__SegmentIndex__c, SBQQ__RequiredBy__r.SBQQ__RequiredBy__c, SBQQ__RequiredBy__r.SBQQ__Product__c, Related_Product_with_Parent_Product__c,
                                                    You_Visit_Package_Type__c, You_Visit_Package_Type_CSV__c, Yield_IQ_Quantity__c, Yield_IQ_Quantity_CSV__c, 
                                                    Web_Application_Versions_Transfer__c, Web_Application_Versions_Transfer_CSV__c, Web_Application_Versions_Other__c, Web_Application_Versions_Other_CSV__c, 
                                                    Web_Application_Versions_International__c, Web_App_Versions_International_CSV__c, Web_Application_Versions_Freshman__c, Web_Application_Versions_Freshman_CSV__c, 
                                                    Urgent_DepositIQ_Quantity__c, Urgent_DepositIQ_Quantity_CSV__c, SEO_Audit__c, SEO_Audit_CSV__c, Quantity_Base_Price_Up_to_5_000_3__c, Quantity_Base_Price_Up_to_5_000_3_CSV__c, 
                                                    Quantity_Base_Price_Up_to_5_000_2__c, Quantity_Base_Price_Up_to_5_000_2_CSV__c, Quantity_Base_Price_Up_to_5_000_1__c, Quantity_Base_Price_Up_to_5_000_1_CSV__c, 
                                                    Proposing_an_Interactive_Offer__c, Proposing_an_Interactive_Offer_CSV__c, Propose_Quick_Pay__c, Propose_Quick_Pay_CSV__c,
                                                    Postage_Type_for_IP_Deadline_Marketing__c, Postage_for_IP_Deadline_Marketing_CSV__c, Postage_for_Pre_Name_Deadline_Marketing__c, Postage_type_for_PRE_Names_CSV__c, 
                                                    Postage_for_New_Name_Deadline_Marketing__c, Postage_type_for_New_Name_CSV__c, PostageType_SpecialUrgentMailing__c, PostageType_SpecialUrgentMailng_CSV__c, 
                                                    Pipeline_analytics_Yes_No__c, Pipeline_Analytics_Yes_No_CSV__c, Participate_in_Undergrad_also__c, Participate_in_Undergrad_also_CSV__c,
                                                    Parent_First__c, Parent_First_CSV__c, Paper_Transfer_Marketing__c, Paper_Transfer_Marketing_CSV__c, Paper_Special_Urgent_Mailing__c, Paper_Special_Urgent_Mailing_CSV__c, 
                                                    Paper_Quantity_Fulfillment__c, Paper_Quantity_Fulfillment_CSV__c, Paper_PRE_Names__c, Paper_PRE_Names_CSV__c, Paper_Offer_or_PDF3__c, Paper_Offer_or_PDF3_CSV__c,
                                                    Paper_Offer_or_PDF2__c, Paper_Offer_or_PDF2_CSV__c, Paper_Offer_or_PDF1__c, Paper_Offer_or_PDF1_CSV__c, Paper_New_Names__c, Paper_New_Names_CSV__c,
                                                    Paper_Inquiry_Pool__c, Paper_Inquiry_Pool_CSV__c, Paper_Client_Provided_Inquiries__c, Paper_Client_Provided_Inquiries_CSV__c, Package_Size__c, Package_Size_CSV__c,
                                                    One_Time_Refresh_Studio_Services__c, One_Time_Refresh_Studio_Services_CSV__c, of_Transfers_Quantity__c, of_Transfers_Quantity_CSV__c, 
                                                    Number_of_PTK_Names__c, Number_of_PTK_Names_CSV__c, Number_of_Destinations__c, Number_of_Destinations_CSV__c, New_Creative_or_Reprint3__c, New_Creative_or_Reprint3_CSV__c,
                                                    New_Creative_or_Reprint2__c, New_Creative_or_Reprint2_CSV__c, New_Creative_or_Reprint1__c, New_Creative_or_Reprint1_CSV__c,
                                                    Multiple_colleges_or_large_Institution__c, Multiple_colleges_or_large_Inst_CSV__c, Multiple_colleges_large_Inst_Transfer__c, TF_Multiple_colleges_or_large_Inst_CSV__c,
                                                    Is_This_A_Standalone_FAO_Client__c, Is_This_A_Standalone_FAO_Client_CSV__c, Include_Transfer_FAO__c, Include_Transfer_FAO_CSV__c,
                                                    Include_Transfer_Deposit_IQ__c, Include_Transfer_Deposit_IQ_CSV__c, Include_Retention_Analysis__c, Include_Retention_Analysis_CSV__c,
                                                    Include_Net_Price_Calculator__c, Include_Net_Price_Calculator_CSV__c, Include_Inquiry_Scoring__c, Include_Inquiry_Scoring_CSV__c, Include_Full_Budget_Model__c, Include_Full_Budget_Model_CSV__c,
                                                    Include_Four_Year_Tuition__c, Include_Four_Year_Tuition_CSV__c, Include_Financial_Aid_Optimization__c, Include_Financial_Aid_Optimization_CSV__c,
                                                    Include_Digital_Media__c, Include_Digital_Media_CSV__c, Include_Descriptive_without_Monitoring__c, Incl_Descriptive_w_o_Monitoring_CSV__c,
                                                    Include_Descriptive_Monitoring__c, Include_Descriptive_Monitoring_CSV__c, Include_a_Regional_Public_Yield_Bundle__c, Include_a_Regnl_Public_Yield_Bundle_CSV__c,
                                                    How_Many_Additional_Language_Versions__c, How_Many_Additional_Language_Version_CSV__c, How_Many_Additional_Destinations__c, How_Many_Additional_Destinations_CSV__c,
                                                    E_only_Transfer_Marketing__c, E_only_Transfer_Marketing_CSV__c, E_Only_Quantity_Fulfillment__c, E_Only_Quantity_Fulfillment_CSV__c,
                                                    E_Only_PRE_Names__c, E_Only_PRE_Names_CSV__c, E_Only_New_Names__c, E_Only_New_Names_CSV__c, E_Only_Inquiry_Pool__c, E_Only_Inquiry_Pool_CSV__c,
                                                    E_Only_Client_Provided_Inquiries__c, E_Only_Client_Provided_Inquiries_CSV__c, Estimated_Common_App_Starts__c, Estimated_Common_App_Starts_CSV__c,
                                                    EAM_Visit_Yes_No__c, EAM_Visit_Yes_No_CSV__c, Duration_of_Fulfillment_Program__c, Duration_of_Fulfillment_Program_CSV__c,
                                                    Digital_Media_Transfer_Marketing__c, Digital_Media_Transfer_Marketing_CSV__c, Digital_Media_PRE_Names__c, Digital_Media_PRE_Names_CSV__c,
                                                    Digital_Media_New_Names__c, Digital_Media_New_Names_CSV__c, Digital_Media_Inquiry_Pool__c, Digital_Media_Inquiry_Pool_CSV__c,
                                                    Did_Prior_Yr_Fulflmnt_have_anyPaper__c, Did_Prior_Yr_Fulflmnt_have_anyPaper_CSV__c, Deposit_IQ_Quantity__c, Deposit_IQ_Quantity_CSV__c,
                                                    Average_Overlap_New_Names__c, Average_Overlap_New_Names_CSV__c,Include_Digital_Media_Yield_IQ__c, Include_Digital_Media_Yield_IQ_CSV__c 
                                                    From SBQQ__QuoteLine__c 
                                                    Where SBQQ__Quote__c IN : quotes  
                                                    And SBQQ__RequiredBy__c != null
                                                    AND (SBQQ__Product__r.productCode != 'ImplementationFee' OR SBQQ__Product__r.productCode != 'ImplementationFeeSS' )
                                                    ORDER BY SBQQ__SegmentIndex__c ASC, SBQQ__StartDate__c Desc
                                                    ]
                        )
                    {
                    
                    //Populating Grand parent map from Middle line
                    if(qLine.SBQQ__RequiredBy__c != null  && qLine.SBQQ__RequiredBy__r.SBQQ__RequiredBy__c == null && !mapGrandParentLineIdWithParentLineIds.containsKey(qLine.SBQQ__RequiredBy__c))
                        mapGrandParentLineIdWithParentLineIds.put(qLine.SBQQ__RequiredBy__c,new Set<Id>());
                    
                    if(mapGrandParentLineIdWithParentLineIds.containsKey(qLine.SBQQ__RequiredBy__c))
                        mapGrandParentLineIdWithParentLineIds.get(qLine.SBQQ__RequiredBy__c).add(qLine.Id);
                    
                    //populating parent to child lines map from child line
                    if(qLine.SBQQ__RequiredBy__c != null && qLine.SBQQ__RequiredBy__r.SBQQ__RequiredBy__c != null && !mapParentLineIdWithchildLines.containsKey(qLine.SBQQ__RequiredBy__c))
                        mapParentLineIdWithchildLines.put(qLine.SBQQ__RequiredBy__c, new List<SBQQ__QuoteLine__c>());
                    
                    if(mapParentLineIdWithchildLines.containsKey(qLine.SBQQ__RequiredBy__c))
                        mapParentLineIdWithchildLines.get(qLine.SBQQ__RequiredBy__c).add(qLine); 
                    }
                
                    //Size check
                    if(mapGrandParentLineIdWithParentLineIds.size() > 0) {
                    
                        //List to hold the proposal lines to be update
                        Map<Id, SBQQ__QuoteLine__c> parentQuoteLinesToUpdate = new Map<Id, SBQQ__QuoteLine__c>();
                    
                        //Loop over the grand parent line ids
                        for(Id grandLineId : mapGrandParentLineIdWithParentLineIds.keySet()){
                        
                            //Check for size
                            if(mapGrandParentLineIdWithParentLineIds.get(grandLineId) != null && mapGrandParentLineIdWithParentLineIds.get(grandLineId).size() > 0) {
                            
                                //Looop over the mid line Ids
                                for(Id midLineId : mapGrandParentLineIdWithParentLineIds.get(grandLineId)) {
                                
                                    //check for size
                                    if(mapParentLineIdWithchildLines.size() > 0 && mapParentLineIdWithchildLines.containsKey(midLineId)
                                        && mapParentLineIdWithchildLines.get(midLineId) != null && mapParentLineIdWithchildLines.get(midLineId).size() > 0) 
                                    {
                                    
                                        //Map of Mid parent ProductId (Inquiry Pool product Id) with Field api name with values
                                        Map<String, Map<String, List<String>>> mapCSVFieldAndValues = new Map<String, Map<String, List<String>>>();
                                        Map<String,String> mapCSVMatchingFields = new Map<String,String>();
                                    
                                        //Loop over the grand child lines
                                        for(SBQQ__QuoteLine__c grandChildPropLine : mapParentLineIdWithchildLines.get(midLineId)) {
                                        
                                            if(String.isNotBlank(grandChildPropLine.Related_Product_with_Parent_Product__c)){
                                            
                                                mapCSVMatchingFields = CPQConstants.mapChildParentCodeWithCSVFieldMapping.get(grandChildPropLine.Related_Product_with_Parent_Product__c);
                                            
                                                if(mapCSVMatchingFields != null && mapCSVMatchingFields.size() > 0){
                                                
                                                    //Loop over the CSV related fields list
                                                    for(String csvField : mapCSVMatchingFields.keySet()) {
                                                    
                                                        Object fieldValues = grandChildPropLine.get(csvField);
                                                    
                                                        //CSVFieldValues
                                                        if(fieldValues != null){
                                                            if(!mapCSVFieldAndValues.containsKey(grandChildPropLine.SBQQ__RequiredBy__r.SBQQ__Product__c))
                                                                mapCSVFieldAndValues.put(grandChildPropLine.SBQQ__RequiredBy__r.SBQQ__Product__c, new Map<String, List<String>>());
                                                        
                                                            if(!mapCSVFieldAndValues.get(grandChildPropLine.SBQQ__RequiredBy__r.SBQQ__Product__c).containsKey(csvField))
                                                                mapCSVFieldAndValues.get(grandChildPropLine.SBQQ__RequiredBy__r.SBQQ__Product__c).put(csvField, new List<String>());
                                                        
                                                            mapCSVFieldAndValues.get(grandChildPropLine.SBQQ__RequiredBy__r.SBQQ__Product__c).get(csvField).add(String.valueOf(fieldValues));
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    
                                        //Check for size
                                        if(mapCSVFieldAndValues.size() > 0) {
                                    
                                            //Proposal Line Instance
                                            SBQQ__QuoteLine__c grandParentLine ;
                                        
                                            if(parentQuoteLinesToUpdate.containsKey(grandLineId)&& parentQuoteLinesToUpdate.get(grandLineId) != null)
                                                grandParentLine = parentQuoteLinesToUpdate.get(grandLineId);
                                            else
                                                grandParentLine = new SBQQ__QuoteLine__c(Id = grandLineId);
                                        
                                        
                                            // loop over the mid line Product Ids (i.e. Inquiry pool Product Id)
                                            for(String midLineProductId : mapCSVFieldAndValues.keySet()) {
                                           
                                                String requiredByProductIdString = '"requiredByProductId":' + '"' +midLineProductId+ '"';
                                            
                                                //Loop over the Field Api Names (i.e. Average_Overlap_New_Names__c) corresponding to CSV fields (i.e. Average_Overlap_New_Names_CSV__c)
                                                for(String fApiName : mapCSVFieldAndValues.get(midLineProductId).keySet()){
                                                
                                                    //Check for size
                                                    if(mapCSVFieldAndValues.get(midLineProductId).get(fApiName) != null && mapCSVFieldAndValues.get(midLineProductId).get(fApiName).size() > 0){
                                                    
                                                        String fieldApi = '"csvFieldName":' + '"' + fApiName + '"';
                                                    
                                                        //List to hold the all year's values for a CSV field  
                                                        List<String> listAllYearValues = mapCSVFieldAndValues.get(midLineProductId).get(fApiName);
                                                    
                                                        //Convert all year values in a coma saperated string
                                                        String allYearValues = String.valueOf(listAllYearValues);
                                                        
                                                        // Modified By - Subhash Garhwal - 10/2/2020 - CR-20200930-14570
                                                        //allYearValues = allYearValues.replaceAll(', ', '\\|').replaceAll('\\(', '"').replaceAll('\\)', '"');
                                                        allYearValues = allYearValues.replaceAll(', ', '|').replaceAll('\\(', '"').replaceAll('\\)', '"');
                                                    
                                                        String yearValue = '"yearValues":' + allYearValues;
                                                    
                                                        //Form a formatted value for a CSV field
                                                        // Example for Inquiry poo Product field Average_Overlap_New_Names_CSV__c : {"csvFieldName":"Average_Overlap_New_Names__c","yearValues":"20|20|20","requiredByProductId":"01t2K000006GX38QAG"}
                                                        String csvField = '{' + fieldApi + ',' + yearValue + ',' + requiredByProductIdString + '}';
                                                    
                                                        //Get the CSV Field API Name from the Map (i.e. Average_Overlap_New_Names_CSV__c) and then populate the value in that field 
                                                        if(mapCSVMatchingFields != null && mapCSVMatchingFields.size() > 0 && mapCSVMatchingFields.containsKey(fApiName)) 
                                                            grandParentLine.put(mapCSVMatchingFields.get(fApiName),csvField);
                                                    }
                                                }
                                            
                                                //Add to list to update the grand parent lines
                                                parentQuoteLinesToUpdate.put(grandParentLine.Id, grandParentLine);
                                            }
                                        }   
                                    }   
                                }
                            }
                        }
                    
                        //Size check
                        if(parentQuoteLinesToUpdate.size() > 0) {
                        
                            //Disable All triggers
                            Util.BypassAllTriggers = true;
                        
                            //update grand parent proposal Lines
                            update parentQuoteLinesToUpdate.values();
                        
                            //Enable All triggers
                            Util.BypassAllTriggers = false;
                        }
                    }
                }
            }
        }
    }           
    
    /**
     * 
     *   @description    :  Set the "Is_Discount_On_YouVisit_Implementation__c" field to true on related sub product line, if found any discount for youvisit sub product's implemetation fee lines.
     *
     *   @args           :  List<SBQQ__QuoteLine__c>, Map<Id, SBQQ__QuoteLine__c>
     *
     *   @return         :  void
     *
     *   @revision Log   :  V1.0 - Created - Subhash - 2/10/2020 - CR-20200210-13716
     * 
     **/
    public static void CheckDiscountOnYouVisitImplementation(List<SBQQ__QuoteLine__c> quoteLines, Map<Id, SBQQ__QuoteLine__c> mapOldQuoteLines) {
        /*
        //Set to hold the YouVisit subproducts which have the implementation fee. 
        Set<String> setRelatedProducts = new Set<String>{'Studio Services', 'Additional Languages', '2nd Virtual Tour', '360 Degree Video', 'Additional Action Zones', 'Content Licensing', 'Hotspots/Positional Media'};
        
        //Map to hold the sub product lines
        Map<Id,SBQQ__QuoteLine__c> mapMidParentQuoteline = new Map<Id,SBQQ__QuoteLine__c>(); 
        
        //loop through all quoteLines
        for (SBQQ__QuoteLine__c ql : quoteLines) { 
            
            //Check the discount on any you visit sub product's Implementation fee
            if(ql.SBQQ__RequiredBy__c != null && ql.SBQQ__ProductCode__c == 'ImplementationFee' && String.isNotBlank(ql.Related_Product__c) 
               && setRelatedProducts.contains(ql.Related_Product__c) && (ql.SBQQ__Discount__c != null || ql.SBQQ__AdditionalDiscountAmount__c != null)) 
            {
                //Populate the map
                mapMidParentQuoteline.put(ql.SBQQ__RequiredBy__c, new SBQQ__QuoteLine__c(Id = ql.SBQQ__RequiredBy__c, Is_Discount_On_YouVisit_Implementation__c = true));   
            } else {
                //Populate the map
                mapMidParentQuoteline.put(ql.SBQQ__RequiredBy__c, new SBQQ__QuoteLine__c(Id = ql.SBQQ__RequiredBy__c, Is_Discount_On_YouVisit_Implementation__c = false));
            }
        }
        
        //Check for size        
        if(mapMidParentQuoteline.size() > 0 && mapMidParentQuoteline.values() != null && mapMidParentQuoteline.values().size() > 0){
            
            //Disable the triggers 
            Util.BypassAllTriggers = true;
            
            //Update the quotelines
            update mapMidParentQuoteline.values();
            
            //Enable the triggers
            Util.BypassAllTriggers = false;
        }*/
    }
    
    /**
     * 
     *   @description    :  This method used to Validate BHDR on Proposal
     *
     *   @args           :  List<SBQQ__QuoteLine__c>, Map<Id, SBQQ__QuoteLine__c>
     *
     *   @return         :  void
     *
     *   @revision Log   :  V1.0 - Created - Mahendra Swarnkar - 11/04/2020 - CR-20200611-14175 - 2-New product - Degree Rules Integration BHDR
     * 
     **/
    public static void validateBHDRonProposal(List<SBQQ__QuoteLine__c> proposalLines, Map<Id, SBQQ__QuoteLine__c> mapOldProposalLines)
    {
        Set<String> SET_BHDR_CODES = new Set<String>{'BHDR'};
        Set<String> SET_BHAP_CODES = new Set<String>{'BHAP'};   
        Set<Id> setProposalIds = new Set<Id>();
        
        //if(BYPASS_VALIDATEBHDRONPROPOSAL_METHOD) return;

        for(SBQQ__QuoteLine__c pL : proposalLines) 
        {
            //if(pL.Related_Product_with_Parent_Product__c != null && pL.Related_Product_with_Parent_Product__c.contains('BHDR')
            //   )

            if(pL.SBQQ__Product__c != null && pL.SBQQ__ProductCode__c == 'BHDR')
            {
                setProposalIds.add(pL.SBQQ__Quote__c);   
            }
        }

        if(setProposalIds.size() > 0) {

            Map<String, Integer> mapBHDRWithCount = new Map<String, Integer>{'BHDR' => 0};
            Map<String, Integer> mapBHAPWithCount = new Map<String, Integer>{'BHAP' => 0};
            Set<Id> setOfAccountId = new Set<Id>();

            for(SBQQ__QuoteLine__c pL : [Select Id, Name,SBQQ__Quote__c, SBQQ__Quote__r.SBQQ__Account__c, SBQQ__Product__c,SBQQ__ProductCode__c 
                                        From SBQQ__QuoteLine__c 
                                         Where SBQQ__Quote__c IN : setProposalIds
                                         AND SBQQ__Product__c != null And Related_Product__c = null
                                         AND (SBQQ__ProductCode__c =: SET_BHAP_CODES
                                          OR SBQQ__ProductCode__c =: SET_BHDR_CODES)
                                        ]) 
            {
                if(pL.SBQQ__ProductCode__c == 'BHDR') {
                    mapBHDRWithCount.put('BHDR', mapBHDRWithCount.get('BHDR') +1);
                }

                if(pL.SBQQ__ProductCode__c == 'BHAP') {
                    mapBHAPWithCount.put('BHAP', mapBHAPWithCount.get('BHAP') +1);
                }

                if(mapBHDRWithCount.get('BHDR') > 0 && mapBHAPWithCount.get('BHAP') == 0) {
                    setOfAccountId.add(pL.SBQQ__Quote__r.SBQQ__Account__c);
                }
            }
            if(mapBHDRWithCount.get('BHDR') > 1 && mapBHAPWithCount.get('BHAP') > 0) {
                throw new CustomException('The proposal already includes the BHDR product.');
            }
            else if(setOfAccountId.size() > 0 && mapBHDRWithCount.get('BHDR') > 0 && mapBHAPWithCount.get('BHAP') == 0) {
                List<Membership__c> memberships = [Select Id FROM Membership__c
                                                    WHERE Account_Name__c != null
                                                    AND Account_Name__c =: setOfAccountId 
                                                    AND program__c != null
                                                    AND (NOT Membership_Status_Text__c like 'Member%')
                                                    AND program__r.Program_Acronym__c != null
                                                    AND program__r.Program_Acronym__c IN : SET_BHAP_CODES
                                                ];
                if(memberships != null && memberships.size() > 0 )  
                {
                    throw new CustomException('The Institution don\'t have an active BHAP membership.'); 
                }
            }
        }
    }
    
    //Added BY Mahendra Swarnkar - CR-20210727-15318 - 07/28/2021
    public static void populateInstanceNameOnLines(List<SBQQ__QuoteLine__c> proposalLines, Map<Id, SBQQ__QuoteLine__c> mapOldProposalLines) {
        
        Set<ID> setProposalIds = new Set<ID>();
        
        Set<ID> setParentLineIds = new Set<ID>();
        Map<String,Integer> mapProductCodeWithInstance = new Map<String,Integer>();
        
        for(SBQQ__QuoteLine__c qlines : proposalLines) {
            setProposalIds.add(qlines.SBQQ__Quote__c);
        }
        
        if(setProposalIds.size() > 0){
        	
            Map<ID, List<SBQQ__QuoteLine__c>> mapParentLineIDWithListAllChildLines = new Map<ID, List<SBQQ__QuoteLine__c>>();
            
            Map<ID, SBQQ__QuoteLine__c> mapQuoteLines = new Map<ID,SBQQ__QuoteLine__c>();
            List<SBQQ__QuoteLine__c> listQuotelinesTobeUpdate = new List<SBQQ__QuoteLine__c>();
            
            for(SBQQ__QuoteLine__c qline : [Select ID, SBQQ__Quote__c, SBQQ__ProductCode__c, Instance_Name__c, SBQQ__RequiredBy__c, SBQQ__RequiredBy__r.Instance_Name__c,SBQQ__RequiredBy__r.SBQQ__RequiredBy__c, SBQQ__RequiredBy__r.SBQQ__RequiredBy__r.Instance_Name__c  From SBQQ__QuoteLine__c Where SBQQ__Quote__c IN : setProposalIds ORDER BY CreatedDate ASC])
            {
                
                if(qline.SBQQ__RequiredBy__c == null) {
                    
                    String key = qline.SBQQ__Quote__c +'-'+ qline.SBQQ__ProductCode__c;
                    
                    Integer instanceNumber = mapProductCodeWithInstance.containsKey(key) ? (mapProductCodeWithInstance.get(key) + 1) : 1;
                    mapProductCodeWithInstance.put(key, instanceNumber);
                    
                    String instanceName = qline.SBQQ__ProductCode__c + '-Instance' + instanceNumber;
                    
                    if(qline.Instance_Name__c == null || !instanceName.equalsIgnoreCase(qline.Instance_Name__c)){
                        qline.Instance_Name__c = qline.SBQQ__ProductCode__c + '-Instance' + instanceNumber;
                        listQuotelinesTobeUpdate.add(qline);
                    }
                    
                    if(!mapParentLineIDWithListAllChildLines.containsKey(qline.Id))
                        mapParentLineIDWithListAllChildLines.put(qline.Id, new List<SBQQ__QuoteLine__c>());
                } else {
                    
                    Id parentLineId = qline.SBQQ__RequiredBy__r.SBQQ__RequiredBy__c != null ? qline.SBQQ__RequiredBy__r.SBQQ__RequiredBy__c : qline.SBQQ__RequiredBy__c;
                    
                    if(!mapParentLineIDWithListAllChildLines.containsKey(parentLineId))
                        mapParentLineIDWithListAllChildLines.put(parentLineId, new List<SBQQ__QuoteLine__c>());
                    
                    mapParentLineIDWithListAllChildLines.get(parentLineId).add(qline);
                }
                
                mapQuoteLines.put(qline.Id, qline);
            }
            
            if(mapParentLineIDWithListAllChildLines.size() > 0) {
                
                for(ID parentLineId : mapParentLineIDWithListAllChildLines.keySet()){
                    
                    if(mapQuoteLines.containsKey(parentLineId) && mapQuoteLines.get(parentLineId) != null
                       && mapParentLineIDWithListAllChildLines.get(parentLineId) != null 
                       && mapParentLineIDWithListAllChildLines.get(parentLineId).size() > 0)
                    {
                        for(SBQQ__QuoteLine__c childLine : mapParentLineIDWithListAllChildLines.get(parentLineId)){
                            
                            if(childLine.Instance_Name__c == null || childLine.Instance_Name__c != mapQuoteLines.get(parentLineId).Instance_Name__c){
                                
                                childLine.Instance_Name__c = mapQuoteLines.get(parentLineId).Instance_Name__c;
                                listQuotelinesTobeUpdate.add(childLine);
                            }
                        }
                    }
                }
            }
            
            if(listQuotelinesTobeUpdate.size() > 0 ){
                Util.BypassAllTriggers = true;
                update listQuotelinesTobeUpdate;
                Util.BypassAllTriggers = false;
            }
        }
    }
}