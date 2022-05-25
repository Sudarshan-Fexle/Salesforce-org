/**
 *  Purpose         :   Controller class for the Deal Summary VF Page.                     
 * 
 *  Created By      :   Colin McGloin
 * 
 *  Created Date    :   5/4/2017
 * 
 * Revision Logs    :   V_1.0 - Created
 *                      V_1.1 - Modified - Subhash Garhwal - 5/25/2021 - CR-20210521-15172 - Modified code logic for multilevel Products
 *
 *
 **/ 

public with sharing class DealSummaryController {

    //Proposal Record
    public SBQQ__Quote__c proposal {get; set;}
    public List<quoteLineRecord> rows {get; set;}

    public DealSummaryController() {

        inIt();
        
    }

    public void inIt () {

        //Grab our Proposal ID from the VF Page
        Id proposalId = ApexPages.currentPage().getParameters().get('id');

        //Query for values needed for our Proposal record
        if(proposalId != null) {
            proposal = [SELECT Id, Name, SBQQ__Status__c, SBQQ__StartDate__c, SBQQ__EndDate__c, Invoice_Frequency__c, Days_Notice__c, Penalty_Fee_Amount__c, 
            		Board_Notification_Date__c, Include_Free_Travel__c, Proposal_Name__c, Proposal_Version__c, SBQQ__CustomerAmount__c, SBQQ__Type__c
                        FROM SBQQ__Quote__c
                        WHERE Id = :proposalId];

        }

    }

    public class Header {

        public String ProductName {get; set;}
        public String yearLabel {get; set;}
        public Decimal total {get; set;}
        public String OfferLabels {get; set;}
        
        public Date groupStartDate {get;set;}
        public Date groupEndDate {get;set;}
        public Boolean showGroupdetails {get;set;}

        public List<quoteLineRecord> annualSubRecords {get; set;}
        public List<quoteLineRecord> travelSubRecords {get; set;}
        public List<quoteLineRecord> initSubRecords {get; set;}
        
        //5/25/2021 - Subhash Garhwal - CR-20210521-15172
        public Map<String, List<quoteLineRecord>> mapQuoteLineRecordsWithProductName {get;set;}
        public Map<String, Decimal> mapParentQLWithTotal {get;set;}
        public Set<String> setYears {get;set;}
        public List<String> productsName {get;set;}
        public Map<String, Decimal> mapParentQLWithPreviousPeriodNegotiated {get;set;}
        public Boolean isRenewal {get;set;}
        public Boolean isThreeLevel {get;set;}

        //Used for the tab fields
        public String category {get; set;}
        public String segLabel {get; set;}
        public Decimal price {get; set;}
        public Decimal upliftAmt {get; set;}
        public Decimal upliftPercent {get; set;}
        public Decimal addlDiscount {get; set;}
        public Decimal customerPrice {get; set;}
        public Decimal numOfStudents {get; set;}
        public Decimal opExpense {get; set;}
        public Boolean proofOfConcept {get; set;}
        public Date proofOfConceptDate {get; set;}
        public Date boardNotificationDate {get; set;}
        public Decimal penaltyFee {get; set;}
        public Decimal DaysNotice {get; set;}
        public Date optOutDate {get; set;}
        public Decimal firstYearValue {get; set;}
        public Decimal profit {get; set;}
        public String optOut {get; set;}
        public Decimal previousYear {get; set;}
        public Decimal previousYearUplift {get; set;}
        public String dasCode {get; set;}
        public Decimal packageTotal {get; set;}

        public Decimal annualTotal {get; set;}
        public Decimal travelTotal {get; set;}
        public Decimal impTotal {get; set;}
        
        //Used to assign a number to the product so we can pick which values to display or not                                    
        public Integer TabNumber {get; set;}

        public Header (){

        }
    }

    public class quoteLineRecord implements Comparable {

        public String quoteProduct {get; set;}
        public String yearLabel {get; set;}
        public Decimal listPrice {get; set;}
        public Decimal UpliftAmount {get; set;}
        public Decimal UpliftPercent {get; set;}
        public Decimal addtlDiscount {get; set;}
        public Decimal total {get; set;}
        public Decimal postageCost {get;set;}
        public Decimal mediaCost {get;set;}

        public quoteLineRecord (String product, String year, Decimal price, Decimal postageCost, Decimal mediaCost, Decimal uplift, Decimal upliftPer, Decimal discount, Decimal total){

            this.quoteProduct = product;
            this.yearLabel = year;
            this.ListPrice = price;
            this.UpliftAmount = uplift;
            this.UpliftPercent = upliftPer;
            this.addtlDiscount = discount;
            this.total = total != null ? total : 0;
            this.postageCost = postageCost != null ? postageCost : 0;
            this.mediaCost = mediaCost != null ? mediaCost : 0;

        }
        
        public Integer compareTo(Object compareTo) {
                quoteLineRecord compareToQL = (quoteLineRecord)compareTo;
                if (yearLabel == compareToQL.yearLabel) return 0;
                if (yearLabel > compareToQL.yearLabel) return 1;
            return -1;        
        }
        
    }
    
    /**
     * @description: Gets our individual Product information for the Tabbed section at the top of the VF Page
     **/

    public Map <Id, Header> getParentProducts {

        get {

            //Create our Map
            Map <Id, Header> mapProductToQLRecords = new Map <Id, Header> ();

            //Create our List
            List <Header> topProducts = new List <Header> ();
            Integer counter = 1;

            List<SBQQ__QuoteLine__c> parentQuoteLines = new List<SBQQ__QuoteLine__c>();
            
            //5/25/2021 - Subhash Garhwal - CR-20210521-15172 - Added SBQQ__RequiredBy__c = null filter
            //Grab all our Records
            parentQuoteLines = [SELECT SBQQ__ProductName__c, Product_Category__c, SBQQ__SegmentLabel__c, SBQQ__ListPrice__c, SBQQ__UpliftAmount__c,
                                    SBQQ__AdditionalDiscount__c, SBQQ__CustomerPrice__c, Number_of_Students__c, Operating_Expense__c,
                                    Proof_of_Concept__c, Proof_of_Concept_Decision_Date__c, Board_Notification_Date__c, Penalty_Fee_Amount__c, Days_Notice__c,
                                    Opt_Out_Effective_Date__c, Annualized_Contract_Value__c, Profit__c, Opt_Out__c, Previous_Period_Negotiated__c,
                                    Previous_Period_Plus_Uplift__c, SBQQ__ProductOption__c, SBQQ__RequiredBy__c, SBQQ__RequiredBy__r.Operating_Expense__c,
                                    SBQQ__RequiredBy__r.SBQQ__ProductName__c, SBQQ__PackageTotal__c,SBQQ__Uplift__c, Early_Termination_Date__c, SBQQ__Group__c,
                                    SBQQ__Group__r.SBQQ__StartDate__c, SBQQ__Group__r.SBQQ__EndDate__c, SBQQ__Quote__c, SBQQ__Quote__r.SBQQ__StartDate__c, SBQQ__Quote__r.SBQQ__EndDate__c,
                                    SBQQ__Quote__r.SBQQ__Type__c
                                    FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: proposal.Id AND SBQQ__RequiredBy__c = null ORDER BY SBQQ__ProductName__c ASC];

            for (SBQQ__QuoteLine__c qL : parentQuoteLines){

                if (qL.SBQQ__RequiredBy__c == null){

                    if (mapProductToQLRecords.get(qL.Id) == null){

                    //Map our Product to the Header Column Wrapper
                    Header tabProduct = new Header();
                    tabProduct.ProductName = qL.SBQQ__ProductName__c;
                    tabProduct.category = qL.Product_Category__c;
                    tabProduct.segLabel = qL.SBQQ__SegmentLabel__c;
                    tabProduct.price = qL.SBQQ__ListPrice__c;
                    tabProduct.addlDiscount = qL.SBQQ__AdditionalDiscount__c;
                    tabProduct.customerPrice = qL.SBQQ__CustomerPrice__c;
                    tabProduct.numOfStudents = qL.Number_of_Students__c;
                    tabProduct.opExpense = qL.Operating_Expense__c;
                    tabProduct.proofOfConcept = qL.Proof_of_Concept__c;
                    tabProduct.proofOfConceptDate = qL.Proof_of_Concept_Decision_Date__c;
                    tabProduct.boardNotificationDate = qL.Board_Notification_Date__c;
                    tabProduct.penaltyFee = qL.Penalty_Fee_Amount__c;
                    tabProduct.daysNotice = qL.Days_Notice__c;
                    tabProduct.boardNotificationDate = qL.Board_Notification_Date__c;
                    tabProduct.firstYearValue = qL.Annualized_Contract_Value__c;
                    tabProduct.profit = qL.Profit__c;
                    tabProduct.previousYear = qL.Previous_Period_Negotiated__c;
                    tabProduct.previousYearUplift = qL.Previous_Period_Plus_Uplift__c;
                    tabProduct.packageTotal = qL.SBQQ__PackageTotal__c;
                    tabProduct.total = 0;
                    tabProduct.annualTotal = 0;
                    tabProduct.travelTotal = 0;
                    tabProduct.impTotal = 0;
                    tabProduct.isRenewal = qL.SBQQ__Quote__r.SBQQ__Type__c == 'Renewal' ? true : false;
                    tabProduct.isThreeLevel = false;

                    //Added in by Colin McGloin - 09/07/2017
                    tabProduct.optOut = qL.Opt_Out__c;
                    tabProduct.optOutDate = qL.Early_Termination_Date__c;

                    tabProduct.annualSubRecords = new List<quoteLineRecord>();
                    tabProduct.travelSubRecords = new List<quoteLineRecord>();
                    tabProduct.initSubRecords = new List<quoteLineRecord>();
                    tabProduct.mapQuoteLineRecordsWithProductName = new Map<String, List<quoteLineRecord>>();
                    tabProduct.mapParentQLWithTotal = new Map<String,Decimal>();
                    tabProduct.setYears = new Set<String>();
                    tabProduct.productsName = new List<String>();
                    tabProduct.mapParentQLWithPreviousPeriodNegotiated = new Map<String,Decimal>();
                    
                    //Check for Group
                    if(String.isNotBlank(qL.SBQQ__Group__c)) {
                        
                        tabProduct.groupStartDate = qL.SBQQ__Group__r.SBQQ__StartDate__c != null ? qL.SBQQ__Group__r.SBQQ__StartDate__c : qL.SBQQ__Quote__r.SBQQ__StartDate__c;
                        tabProduct.groupEndDate = qL.SBQQ__Group__r.SBQQ__EndDate__c != null ? qL.SBQQ__Group__r.SBQQ__EndDate__c : qL.SBQQ__Quote__r.SBQQ__EndDate__c;
                        tabProduct.showGroupdetails = true;
                    } else
                        tabProduct.showGroupdetails = false;
                        
                    //Check if one of the Products has a DAS Option
                    if (dasImplications(qL) != null){
                        tabProduct.dasCode = dasImplications(qL);
                    }
                    //Check if one of the Products has an Opt Out
                    //Commented out by Colin McGloin - 09/07/2017
                    /*if (getoptOutValues(qL) != null){
                        tabProduct.optOut = getoptOutValues(qL);
                    }
                    //Get the closest Opt Out Effective Date if there is one associated with the Quote Line
                    if (getClosestOptOutDate(qL) != null){
                        tabProduct.optOutDate = getClosestOptOutDate(qL);
                    }*/

                    //Add a counter for tracking which tab is which
                    tabProduct.TabNumber = counter;
                    //Increase each go around
                    counter++;

                    //Add the record to the list
                    mapProductToQLRecords.put(qL.Id, tabProduct);

                    }

                }

            }
            
            //5/25/2021 - Subhash Garhwal - CR-20210521-15172 - Added SBQQ__RequiredBy__c = null filter
            //Get 1st level of child Quote Lines and in same SOQL get Grand Child using inline SOQL
            List<SBQQ__QuoteLine__c> childQuoteLines = [SELECT SBQQ__ProductName__c, Product_Category__c, SBQQ__SegmentLabel__c, SBQQ__ListPrice__c, SBQQ__UpliftAmount__c,
                                                                SBQQ__AdditionalDiscount__c, SBQQ__CustomerPrice__c, Number_of_Students__c, Operating_Expense__c,
                                                                Proof_of_Concept__c, Proof_of_Concept_Decision_Date__c, Board_Notification_Date__c, Penalty_Fee_Amount__c,
                                                                Days_Notice__c, Opt_Out_Effective_Date__c, Annualized_Contract_Value__c, Profit__c, Opt_Out__c,
                                                                Previous_Period_Negotiated__c, Previous_Period_Plus_Uplift__c, SBQQ__ProductOption__c, SBQQ__RequiredBy__c,
                                                                SBQQ__RequiredBy__r.Operating_Expense__c, SBQQ__RequiredBy__r.SBQQ__ProductName__c, SBQQ__PackageTotal__c,
                                                                SBQQ__Uplift__c, Early_Termination_Date__c, Postage_Costs__c, Media_Costs__c,SBQQ__RequiredBy__r.Previous_Period_Negotiated__c,
                                                                
                                                                (Select Id, Name, SBQQ__ProductName__c, Product_Category__c, SBQQ__SegmentLabel__c, SBQQ__ListPrice__c, SBQQ__UpliftAmount__c,
                                                                        SBQQ__AdditionalDiscount__c, SBQQ__CustomerPrice__c, Number_of_Students__c, Operating_Expense__c,
                                                                        Proof_of_Concept__c, Proof_of_Concept_Decision_Date__c, Board_Notification_Date__c, Penalty_Fee_Amount__c, Days_Notice__c,
                                                                        Opt_Out_Effective_Date__c, Annualized_Contract_Value__c, Profit__c, Opt_Out__c, Previous_Period_Negotiated__c,
                                                                        Previous_Period_Plus_Uplift__c, SBQQ__ProductOption__c, SBQQ__RequiredBy__c, SBQQ__RequiredBy__r.Operating_Expense__c,
                                                                        SBQQ__RequiredBy__r.SBQQ__ProductName__c, SBQQ__PackageTotal__c,SBQQ__Uplift__c, Early_Termination_Date__c,
                                                                        SBQQ__RequiredBy__r.SBQQ__RequiredBy__c, Postage_Costs__c, Media_Costs__c, SBQQ__RequiredBy__r.Previous_Period_Negotiated__c
                                                                        From SBQQ__Quote_Lines__r Where Product_Category__c NOT IN : CPQConstants.SET_PRODUCT_CATEGORY_TO_SKIP_FOR_DEAL_SUMMARY
                                                                        ORDER BY SBQQ__SegmentLabel__c ASC NULLS LAST, SBQQ__ProductName__c ASC)
                                                                	FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: proposal.Id AND SBQQ__RequiredBy__c IN : parentQuoteLines
                                                                        AND Product_Category__c NOT IN : CPQConstants.SET_PRODUCT_CATEGORY_TO_SKIP_FOR_DEAL_SUMMARY
                                                                  	ORDER BY SBQQ__SegmentLabel__c ASC NULLS LAST, SBQQ__ProductName__c ASC];
            
            //Loop over the child QuoteLines
            for (SBQQ__QuoteLine__c qL : childQuoteLines){

                //Grab our Header Wrapper and add our Quote Line Rows to the Header Wrapper
                if (mapProductToQLRecords.get(qL.SBQQ__RequiredBy__c) != null){
                    
                    //Check if Quote Line is having grand child or not
                    if(qL.SBQQ__Quote_Lines__r.size() == 0) {
                        addQuoteLinesUnderParentQL(qL, qL.SBQQ__ProductName__c, mapProductToQLRecords, qL.SBQQ__RequiredBy__c); 
                    } else if(qL.SBQQ__Quote_Lines__r.size() > 0) {
                        
                        //Update 3 level check
                        mapProductToQLRecords.get(qL.SBQQ__RequiredBy__c).isThreeLevel = true;
                        
                        //Loop over the Grand childs
                        for(SBQQ__QuoteLine__c gQL : qL.SBQQ__Quote_Lines__r)
                            addQuoteLinesUnderParentQL(gQL, gQL.SBQQ__ProductName__c + '-' + gQL.SBQQ__RequiredBy__r.SBQQ__ProductName__c, mapProductToQLRecords, gQL.SBQQ__RequiredBy__r.SBQQ__RequiredBy__c);
                    } 

                }

            }
	    
            //Returns our map of records or a null value which we can use to hide the VF Panel
            if (mapProductToQLRecords.size() > 0){
                return mapProductToQLRecords;
            }
            else return null;

        }

        set;

   }
   
    /**
     * 
     *  @description    :   Methos to add the Proposal Lines under parent Proposal Line
     * 
     *  @args           :   SBQQ__QuoteLine__c, String, Map <Id, Header>, String
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - 05/04/2017 - Created - Victor Hanson - CR-20170403-10807
     * 
     **/
    private void addQuoteLinesUnderParentQL(SBQQ__QuoteLine__c qL, String productType, Map <Id, Header> mapProductToQLRecords, String mainProductId) {
        
        //Get Main Product Details
        Header mainProduct = mapProductToQLRecords.get(mainProductId);
        
        //Check if with selected type Product is already added
        if(!mainProduct.mapQuoteLineRecordsWithProductName.containsKey(productType))
            mainProduct.mapQuoteLineRecordsWithProductName.put(productType, new List<quoteLineRecord>());
        
        //New Quoteline record to display in list
        quoteLineRecord quoteLine = new quoteLineRecord(productType, qL.SBQQ__SegmentLabel__c, qL.SBQQ__ListPrice__c, qL.Postage_Costs__c, qL.Media_Costs__c, qL.SBQQ__UpliftAmount__c, qL.SBQQ__Uplift__c, qL.SBQQ__AdditionalDiscount__c, qL.SBQQ__CustomerPrice__c);
        
        //Add Record in list
        mainProduct.mapQuoteLineRecordsWithProductName.get(productType).add(quoteLine);
        
        //Check if Product Name exists in list
        if(!mainProduct.productsName.contains(productType))
            mainProduct.productsName.add(productType);
            
        
        //Check if Product if total already added or not
        if(!mainProduct.mapParentQLWithTotal.containsKey(productType))
            mainProduct.mapParentQLWithTotal.put(productType,0);
        
        //Add Customer Price in total
        if(qL.SBQQ__CustomerPrice__c != null)
            mainProduct.mapParentQLWithTotal.put(productType, mainProduct.mapParentQLWithTotal.get(productType) + qL.SBQQ__CustomerPrice__c);
        
        //Check if Product if previous Period amount already added or not
        if(!mainProduct.mapParentQLWithPreviousPeriodNegotiated.containsKey(productType) && mainProduct.isThreeLevel == true && qL.SBQQ__RequiredBy__c != null
            && qL.SBQQ__RequiredBy__r.Previous_Period_Negotiated__c != null)
            mainProduct.mapParentQLWithPreviousPeriodNegotiated.put(productType,qL.SBQQ__RequiredBy__r.Previous_Period_Negotiated__c);
        else if(mainProduct.mapParentQLWithPreviousPeriodNegotiated.containsKey(productType) && mainProduct.isThreeLevel == true && qL.SBQQ__RequiredBy__c != null
            && qL.SBQQ__RequiredBy__r.Previous_Period_Negotiated__c != null && mainProduct.mapParentQLWithPreviousPeriodNegotiated.get(productType) == 0)
            mainProduct.mapParentQLWithPreviousPeriodNegotiated.put(productType,qL.SBQQ__RequiredBy__r.Previous_Period_Negotiated__c);
        else if(!mainProduct.mapParentQLWithPreviousPeriodNegotiated.containsKey(productType))
            mainProduct.mapParentQLWithPreviousPeriodNegotiated.put(productType,0);
        
        //Add Labels in set
        mainProduct.setYears.add(qL.SBQQ__SegmentLabel__c);
    }

    /**
     * @description: Populates our Opt Out field
     *
     **/

    public String getoptOutValues (SBQQ__QuoteLine__c quoteLineToCheck) {

            //Create our List & Set for Opt Out Values
            List <SBQQ__QuoteLine__c> optOutQuoteLines = new List <SBQQ__QuoteLine__c> ();
            String optOutValues;

            //Grab our Opt Out Records
            optOutQuoteLines = [SELECT SBQQ__ProductCode__c, Opt_Out__c, SBQQ__RequiredBy__c
                                FROM SBQQ__QuoteLine__c 
                                WHERE SBQQ__RequiredBy__c = :quoteLineToCheck.Id AND Opt_Out__c != null];

            //If we have some values to work with
            if (optOutQuoteLines.size() > 0){

                for ( SBQQ__QuoteLine__c qL : optOutQuoteLines){
                    if (String.isEmpty(optOutValues)){

                        String prodOptOut = qL.Opt_Out__c;
                        optOutValues = prodOptOut;

                    }

                    else {

                        String prodOptOut = ',' + qL.Opt_Out__c;
                        optOutValues += prodOptOut;

                    }

                }

            }

            if (String.isNotEmpty(optOutValues)){
                return optOutValues;
            }
            else return null;

    }

    /**
     * @description: Populates our Opt Out Effective date with the earliest value
     **/

    public Date getClosestOptOutDate (SBQQ__QuoteLine__c quoteLineToCheck) {

            //Create our List & Set for Opt Out Values
            List <SBQQ__QuoteLine__c> optOutQuoteLines = new List <SBQQ__QuoteLine__c> ();
            Date optOutEffectiveDate;

            //Grab our Opt Out Records
            optOutQuoteLines = [SELECT Id, SBQQ__ProductCode__c, Opt_Out__c, Early_Termination_Date__c
                                FROM SBQQ__QuoteLine__c 
                                WHERE Id = :quoteLineToCheck.Id AND Opt_Out__c != null AND Early_Termination_Date__c != NULL
                                ORDER BY Early_Termination_Date__c DESC];

            //Grab our earliest Early Termination Date
            if (optOutQuoteLines.size() > 0){

                optOutEffectiveDate = optOutQuoteLines[0].Early_Termination_Date__c;

            }

            //Return our Early Termination Date value or Null
            if (optOutQuoteLines.size() > 0){
                return optOutEffectiveDate;
            }
            else return null;

    }

    /**
     * @description: Populates our Offer field
     **/

    public Set<String> getOfferValues {

        get {

            //Create our List & Set for Offer Values
            List <SBQQ__QuoteLine__c> offerQuoteLines = new List <SBQQ__QuoteLine__c> ();
            Set<String> offerValues = new Set<String>();

            //Grab our Offer Records
            offerQuoteLines = [SELECT SBQQ__ProductName__c, SBQQ__Product__c, SBQQ__Product__r.Offer__c
                                            FROM SBQQ__QuoteLine__c 
                                            WHERE SBQQ__Quote__c = :proposal.Id AND SBQQ__Product__r.Offer__c = TRUE];

            if (offerQuoteLines.size() > 0){

                for ( SBQQ__QuoteLine__c qL : offerQuoteLines){

                    offerValues.add(qL.SBQQ__ProductName__c);

                }

            }

            if (offerValues.size() > 0){
                return offerValues;
            }
            else return null;

        }
        set;

    }

    /**
     * @description: Does the record have a DAS feature?
     **/

     public string dasImplications (SBQQ__QuoteLine__c quoteLineToCheck) {

        //Grab all of the current DAS Codes from a stored custom label and dump them into a Set for easy check in our logic
        List <String> dasCodesList = Label.CPQ_DAS_Product_Codes.split(';');
        Set<String> dasCodes = new Set<String>(dasCodesList);

        //Set our String
        string dasProductCode;

            //Query for the Feature category
            for (SBQQ__QuoteLine__c checkForDAS : [SELECT Id, Name, SBQQ__Product__c, SBQQ__Product__r.ProductCode, SBQQ__Product__r.ProductShortName__c, SBQQ__RequiredBy__c
                                                    FROM SBQQ__QuoteLine__c
                                                    WHERE SBQQ__RequiredBy__c = :quoteLineToCheck.Id]){

            //If our Feature Category is equal to DAS then change the flag to true
            if (dasCodes.contains(checkForDAS.SBQQ__Product__r.ProductCode)){
                //Populate in the Short Code for the Name
                dasProductCode = checkForDAS.SBQQ__Product__r.ProductShortName__c;
                }
            }

            //Return a Product Code if one was related to DAS
            if (dasProductCode != null){

                //Return the Product Short Code
                return dasProductCode;
            }
            else return null;
     }


}