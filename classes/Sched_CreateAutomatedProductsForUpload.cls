/**
 *  Description     :  Scheduler class to create Automated Products
 *
 *  Created By      :  Subhash Garhwal
 *
 *  Created Date    :  11/04/2019
 *
 *  Revision Logs   :   V_1.0 - Created - Subhash Garhwal
 *			V_1.1 - Modified By - Subhash Garhwal - 10/2/2020 - CR-20200930-14570 
 *                      
 *
 **/
global class Sched_CreateAutomatedProductsForUpload implements Schedulable {
	
	// Comment By - Subhash Garhwal - 10/2/2020 - CR-20200930-14570
	//Set to hold the Proposal Ids
	//Set<Id> setProposalIds = new Set<Id>();
    
    //Jobs Status values
    public static final Set<String> setJosStatus = new Set<String>{'COMPLETE', 'DELETED','WAITING', 'ACQUIRED', 'EXECUTING', 'PAUSED', 'BLOCKED','PAUSED_BLOCKED', 'Holding', 'Queued', 'Preparing', 'Processing'};
	
    // Comment By - Subhash Garhwal - 10/2/2020 - CR-20200930-14570
    //Constructor
    public Sched_CreateAutomatedProductsForUpload() {
        //this.setProposalIds = setProposalIds;
    }
    
    //Execute method
    global void execute(SchedulableContext ctx) {
        
        try{	
		// Modified By - Subhash Garhwal - 10/2/2020 - CR-20200930-14570
        	//Call method 
        	executeAutomatedProductCreationProcess();    
        
        } catch(Exception excep) {
            
            //Check if batch job is failed due to more than queuable jobs and then re-execute the batch 
            if(excep.getMessage().containsIgnoreCase('Too many queueable') || excep.getmessage().contains('UNABLE_TO_LOCK_ROW')) {
                
                // Modified By - Subhash Garhwal - 10/2/2020 - CR-20200930-14570
                dateTime sysTime = dateTime.now().addMinutes(3);
                String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
                Sched_CreateAutomatedProductsForUpload job = new Sched_CreateAutomatedProductsForUpload();
                
                System.schedule('Sched_CreateAutomatedProductsForUpload_Again' + sysTime.getTime(), chron_exp, job);
                
            } else{
                throw new CustomException(excep.getMessage() + '  @@@@  ' + excep.getStackTraceString());
            }
            
        }
    	
    }
    
    /**
     *  @description		:	Execute Automated Project creation
     *  
     *	@args           	:   Set<Id>
     *
     *  @return         	:   void
     * 
     *  @Revision Logs		:	V1.1 - 11/04/2019 - Created
     * 
    **/
	public static void executeAutomatedProductCreationProcess() {
      
        //Set to hold Automated Product's Product Code
        Set<String> setProductCodes = new Set<String>{'ESDISC', 'ESEMF', 'ESADLDISC'};
            
        //Set to hold Automated Product's Product Code
        Set<String> setProductCodesForPriceBookEntry = new Set<String>{'ESDISC', 'ESEMF', 'ESADLDISC', 'Multi Year Discount', 'Additional Discount', 'Program Costs'};
        
	// Modified By - Subhash Garhwal - 10/2/2020 - CR-20200930-14570     
        //SOQL over the Proposals
        List<SBQQ__Quote__c> proposals = [Select Id, Legacy_Migrated_ES_Client__c, Is_Enrollment_Services__c, SBQQ__StartDate__c, SBQQ__EndDate__c,SBQQ__FirstSegmentTermEndDate__c,
        										 (Select Id, SBQQ__ProductCode__c From SBQQ__LineItems__r Where SBQQ__ProductCode__c IN : setProductCodes)
        										 From SBQQ__Quote__c Where Legacy_Migrated_ES_Client__c = 'Migrated' AND Is_Enrollment_Services__c = true
        										 						   AND Add_Discount_Product__c = true];
        
        //Map to insert Main Proposal Lines
        Map<String, SBQQ__QuoteLine__c> mapMainProposalLines = new Map<String, SBQQ__QuoteLine__c>();
        
        //Map to insert Child Proposal Lines
        Map<String, List<SBQQ__QuoteLine__c>> mapCProposalLines = new Map<String, List<SBQQ__QuoteLine__c>>();
        
        //Check for Proposals
        if(proposals != null && proposals.size() > 0){
            
            //Map to hold the Product code with related PriceBookEntryId (Standard Price book entry for USD currency code) 
            Map<String,Id> mapProductCodeWithPriceBookEntryId = new Map<String,Id>();
            
            for(PricebookEntry priceBookEntryRecord : [Select Id, ProductCode From PricebookEntry where ProductCode IN : setProductCodesForPriceBookEntry AND IsActive = true AND CurrencyIsoCode = 'USD' AND Pricebook2.Name = 'Standard Price Book'])
                mapProductCodeWithPriceBookEntryId.put(priceBookEntryRecord.ProductCode, priceBookEntryRecord.Id );
            
            //Map to hold the Product code with related Dimensions (Standard Price book entry for USD currency code) 
            Map<String,Id> mapProductCodeWithDimensionId = new Map<String,Id>();
            
            for(SBQQ__Dimension__c dimensionRecord : [Select Id, SBQQ__Product__c, SBQQ__Product__r.ProductCode From SBQQ__Dimension__c where SBQQ__Product__c != null AND SBQQ__Product__r.ProductCode != null AND SBQQ__Product__r.ProductCode IN : setProductCodesForPriceBookEntry ])
				mapProductCodeWithDimensionId.put(dimensionRecord.SBQQ__Product__r.ProductCode, dimensionRecord.Id );
            
            
            // Options
            //SOQL over the Products   
            //List<Product2> products = [Select Id, ProductCode, Name, Parent_Product__c, (Select Id, SBQQ__OptionalSKU__c, SBQQ__OptionalSKU__r.Name From SBQQ__OptionalFor__r) From Product2 Where ProductCode IN : setProductCodes];
            List<Product2> products = [Select Id, ProductCode, Name, Parent_Product__c, SBQQ__SortOrder__c, SBQQ__SubscriptionPricing__c, SBQQ__SubscriptionBase__c, 
                                       SBQQ__SubscriptionType__c, SBQQ__SubscriptionTerm__c,
                                       (Select Id, SBQQ__Type__c, SBQQ__OptionalSKU__c, SBQQ__OptionalSKU__r.Name, SBQQ__OptionalSKU__r.Product_Category__c, 
                                        SBQQ__OptionalSKU__r.SBQQ__SubscriptionPricing__c, SBQQ__OptionalSKU__r.SBQQ__SubscriptionBase__c, 
                                        SBQQ__OptionalSKU__r.SBQQ__SubscriptionType__c, SBQQ__OptionalSKU__r.SBQQ__SubscriptionTerm__c,
                                        SBQQ__OptionalSKU__r.SBQQ__SortOrder__c, SBQQ__OptionalSKU__r.ProductCode, SBQQ__Feature__c
                                        From SBQQ__Options__r) 
                                       From Product2 Where ProductCode IN : setProductCodes];
            
            //Check for size
            if(products.size() > 0) {
                
                //Map to hold the Parent Product
                Map<String, SBQQ__QuoteLine__c> mapParentProposalLines = new Map<String, SBQQ__QuoteLine__c>();
                
                //Map to hold the Child Prodcuts
                Map<String, List<SBQQ__QuoteLine__c>> mapChildProposalLines = new Map<String, List<SBQQ__QuoteLine__c>>();
                
		// Modified By - Subhash Garhwal - 10/2/2020 - CR-20200930-14570
                //Map to update the Proposals
                Map<Id, SBQQ__Quote__c> mapProposalsToUpdate = new Map<Id, SBQQ__Quote__c>();
                
                //Loop over Products
                for(Product2 prduct : products) {
                    
                    //Check Product Code in map
                    if(String.isNotBlank(prduct.ProductCode) && !mapParentProposalLines.containsKey(prduct.ProductCode)) {
                        
                        SBQQ__QuoteLine__c parentQuoteline = new SBQQ__QuoteLine__c(SBQQ__Product__c = prduct.Id, SBQQ__Quantity__c = 1, Top_Parent_Product__c = prduct.Parent_Product__c,
                                                                                              Sort__c = prduct.SBQQ__SortOrder__c,
                                                                                              SBQQ__SubscriptionPricing__c = prduct.SBQQ__SubscriptionPricing__c, 
                                                                                              SBQQ__SubscriptionBase__c = prduct.SBQQ__SubscriptionBase__c, 
                                                                                              SBQQ__SubscriptionType__c = prduct.SBQQ__SubscriptionType__c, 
                                                                                              SBQQ__ProductSubscriptionType__c = prduct.SBQQ__SubscriptionType__c,
                                                                                              SBQQ__DefaultSubscriptionTerm__c = prduct.SBQQ__SubscriptionTerm__c
                                                                                             );
                        
                        //Populate the Price book entry field for the parent quoteLine
                        if(prduct.ProductCode != null && mapProductCodeWithPriceBookEntryId.size() > 0 && mapProductCodeWithPriceBookEntryId.containsKey(prduct.ProductCode)){
                        	parentQuoteline.SBQQ__PricebookEntryId__c = mapProductCodeWithPriceBookEntryId.get(prduct.ProductCode);    
                        
                        } /*else {
                            parentQuoteline.SBQQ__PricebookEntryId__c = '01u2K00000SZSnlQAH';
                        }*/
                        
                        //Add Parent Product in map
                        mapParentProposalLines.put(prduct.ProductCode, parentQuoteline);
                        
                        //Loop over the Child Products
                        if(prduct.SBQQ__Options__r != null && prduct.SBQQ__Options__r.size() > 0) {
                            
                            //Check Product Id in map
                            if(!mapChildProposalLines.containsKey(prduct.ProductCode))
                                mapChildProposalLines.put(prduct.ProductCode, new List<SBQQ__QuoteLine__c>());
				
                            //Loop over the Child Products
                            for(SBQQ__ProductOption__c pO : prduct.SBQQ__Options__r) {
                                SBQQ__QuoteLine__c childQuoteline = new SBQQ__QuoteLine__c( 
                                    SBQQ__Product__c = pO.SBQQ__OptionalSKU__c, SBQQ__Quantity__c = 1, SBQQ__ProductOption__c = pO.Id, 
                                    Product_Category__c = pO.SBQQ__OptionalSKU__r.Product_Category__c, 
                                    SBQQ__SubscriptionPricing__c = pO.SBQQ__OptionalSKU__r.SBQQ__SubscriptionPricing__c, 
                                    SBQQ__SubscriptionBase__c = pO.SBQQ__OptionalSKU__r.SBQQ__SubscriptionBase__c, 
                                    SBQQ__SubscriptionType__c = pO.SBQQ__OptionalSKU__r.SBQQ__SubscriptionType__c, 
                                    SBQQ__ProductSubscriptionType__c = pO.SBQQ__OptionalSKU__r.SBQQ__SubscriptionType__c,
                                    SBQQ__DefaultSubscriptionTerm__c = pO.SBQQ__OptionalSKU__r.SBQQ__SubscriptionTerm__c,
                                    SBQQ__OptionType__c = pO.SBQQ__Type__c, Sort__c = pO.SBQQ__OptionalSKU__r.SBQQ__SortOrder__c,
                                    SBQQ__DynamicOptionId__c = pO.SBQQ__Feature__c/*, SBQQ__Bundle__c = false*/
                                    
                                );

                                //Populate the Price book entry field for the Child quoteLine
                                if(pO.SBQQ__OptionalSKU__r.ProductCode != null && mapProductCodeWithPriceBookEntryId.size() > 0 && mapProductCodeWithPriceBookEntryId.containsKey(pO.SBQQ__OptionalSKU__r.ProductCode)){
                                    childQuoteline.SBQQ__PricebookEntryId__c = mapProductCodeWithPriceBookEntryId.get(pO.SBQQ__OptionalSKU__r.ProductCode);    
                                
                                } /*else {
                                    childQuoteline.SBQQ__PricebookEntryId__c = '01u2K00000SZSnlQAH';
                                }*/
                                
                                if(pO.SBQQ__OptionalSKU__r.ProductCode != null && mapProductCodeWithDimensionId.size() > 0 && mapProductCodeWithDimensionId.containsKey(pO.SBQQ__OptionalSKU__r.ProductCode)){
                                	childQuoteline.SBQQ__Dimension__c = mapProductCodeWithDimensionId.get(pO.SBQQ__OptionalSKU__r.ProductCode);
                                }
                                
                                if(pO.SBQQ__OptionalSKU__r.ProductCode == 'Multi Year Discount' 
                                   	|| pO.SBQQ__OptionalSKU__r.ProductCode == 'Additional Discount'
                                  	|| pO.SBQQ__OptionalSKU__r.ProductCode == 'Program Costs'){
                                    
                                    childQuoteline.SBQQ__OptionLevel__c =  1;
                                	
                                    //Check for products and populate the Segment key to group the grand parent child lines
									if(pO.SBQQ__OptionalSKU__r.ProductCode == 'Multi Year Discount')
                                    	childQuoteline.SBQQ__SegmentKey__c =  '131988';
                                    if(pO.SBQQ__OptionalSKU__r.ProductCode == 'Additional Discount')
                                    	childQuoteline.SBQQ__SegmentKey__c =  '131989';
                                    if(pO.SBQQ__OptionalSKU__r.ProductCode == 'Program Costs')
                                    	childQuoteline.SBQQ__SegmentKey__c =  '131990';
								}
								
                                //Add Child Proposal Line
                                mapChildProposalLines.get(prduct.ProductCode).add(childQuoteline);
                            }
                        }
                    }		
                }
                
                //Loop over the Main Proposal Lines
                for(String mainPLCode : mapParentProposalLines.keySet()) {
                    
                    //Loop over the Proposal
                    for(SBQQ__Quote__c proposal : proposals) {
                        
                        //check for ES proposal and inserted via data loader operations
                        if(proposal.Is_Enrollment_Services__c && proposal.Legacy_Migrated_ES_Client__c == 'Migrated') {
                            
                            //Variable to check if Main PL is already exists
                            Boolean isMainPLExists = false;
                            
                            //Loop over the Proposal Lines
                            for(SBQQ__QuoteLine__c pL : proposal.SBQQ__LineItems__r) {
                                
                                //Check code
                                if(mainPLCode == pL.SBQQ__ProductCode__c) {
                                    
                                    isMainPLExists = true;
                                    break;
                                }  
                            }
                            
                            //Check if main lines is not exist already
                            if(isMainPLExists == false) {
                                
                                //Clone Proposal Line for main line
                                SBQQ__QuoteLine__c pL = mapParentProposalLines.get(mainPLCode).clone();
                                
                                //Update fields
                                pL.SBQQ__Quote__c = proposal.Id;
                                
                                //10/2/2020 - Subhash Garhwal - Added code to update the Proposal - CR-20200930-14570
                                mapProposalsToUpdate.put(proposal.Id, new SBQQ__Quote__c(Id = proposal.Id, Add_Discount_Product__c = false));
                                
                                //Add Record in map of main lines 
                                mapMainProposalLines.put(mainPLCode + '-' + proposal.Id, pL);
                                
                                if(mapChildProposalLines.containsKey(mainPLCode)) {
                                    
                                    //Get No of child lines to insert.
                                    Double numChildQuotelines = calculateLinesForProposal(proposal.SBQQ__StartDate__c, proposal.SBQQ__EndDate__c, proposal.SBQQ__FirstSegmentTermEndDate__c);
                                    
                                    //Loop over the child Proposal Lines
                                    for(SBQQ__QuoteLine__c cPL : mapChildProposalLines.get(mainPLCode)) {
                                        
                                        //Check for counter
                                        if(numChildQuotelines > 0){
                                            
                                            //populate the quoteline start and end dates
                                            Date quotelineStartDate = proposal.SBQQ__StartDate__c;
                                            Date quotelineEndDate = proposal.SBQQ__FirstSegmentTermEndDate__c != null ? proposal.SBQQ__FirstSegmentTermEndDate__c : quotelineStartDate.addYears(1).addDays(-1);
                                            
                                            //Create the quote lines
                                            for(Double i =  1; i <= numChildQuotelines; i++ ) {
                                                
                                                //Clone Proposal Line for child lines
                                                SBQQ__QuoteLine__c childPL = cPL.clone();
                                                
                                                //Update child quoteline fields
                                                childPL.SBQQ__Quote__c = proposal.Id;
                                                childPL.SBQQ__SegmentIndex__c = (Integer)i;
                                                childPL.SBQQ__SegmentLabel__c = 'Year  ' + (Integer)i;
                                                childPL.SBQQ__Quantity__c = 1;
                                                
                                                childPL.SBQQ__StartDate__c = quotelineStartDate;
                                                childPL.SBQQ__EndDate__c = quotelineEndDate;
                                                
                                                //Check for last quoteline and populate the end date accordingly
                                                if(i == numChildQuotelines)
                                                    childPL.SBQQ__EndDate__c = proposal.SBQQ__EndDate__c;
                                                
                                                //populate the map of child quotelines 
                                                if(!mapCProposalLines.containsKey(mainPLCode + '-' + proposal.Id))
                                                    mapCProposalLines.put(mainPLCode + '-' + proposal.Id, new List<SBQQ__QuoteLine__c>());
                                                
                                                //Add Record in map of child quotelines
                                                mapCProposalLines.get(mainPLCode + '-' + proposal.Id).add(childPL);
                                                
                                                //Check for first segment term end date on proposal and then accordingly set the quoteline start date and end date for next year quoteline
                                                if(i == 1 && proposal.SBQQ__FirstSegmentTermEndDate__c != null ) {
                                                    
                                                    quotelineStartDate = (proposal.SBQQ__FirstSegmentTermEndDate__c).addDays(1);
                                                    quotelineEndDate = quotelineStartDate.addYears(1).addDays(-1); 
                                                    
                                                } else {
                                                    
                                                    quotelineStartDate = quotelineEndDate.addDays(1);
                                                    quotelineEndDate = quotelineStartDate.addYears(1).addDays(-1); 
                                                    
                                                }
                                            }
                                        }
                                    }	
                                }
                            }
                        }
                    }
                }
                
                //Check for Proposal Line List
                if(mapMainProposalLines.size() > 0) {
                    
		    // Modified By - Subhash Garhwal - 10/2/2020 -
                    //Check for Proposal size
                    if(mapProposalsToUpdate.size() > 0) {
                    	
                    	Util.byPassAllTriggers = true;
                    	
                    	update mapProposalsToUpdate.values();
                    	 
                    	Util.byPassAllTriggers = false;
                    }
                    	
                    insert mapMainProposalLines.values();
                    
                    //List to insert Child PLs
                    List<SBQQ__QuoteLine__c> childProposalLines = new List<SBQQ__QuoteLine__c>();
                    
                    //Loop over the Child Proposal Lines
                    for(String cPLCode : mapCProposalLines.keySet()) {
                        
                        //Check code
                        if(mapMainProposalLines.containsKey(cPLCode)) {
                            
                            //Loop over the Child PLS
                            for(SBQQ__QuoteLine__c pL : mapCProposalLines.get(cPLCode)) {
                                
                                //Update Patent PL
                                pL.SBQQ__RequiredBy__c = mapMainProposalLines.get(cPLCode).Id;
                                
                                //Add record in list
                                childProposalLines.add(pL);
                            }
                        }
                    }
                    
                    //Check size
                    if(childProposalLines.size() > 0)
                        insert childProposalLines;
                }
            }
        }
	}
    
    /**
     *  @description		:   Method to calculate and then return the no of quote lines required to create
     *  
     *	@args           	:   Date, Date, Date
     *
     *  @return         	:   Double
     * 
     *  @Revision Logs		:   V1.1 - Created 
     * 
    **/
    public static Double calculateLinesForProposal(Date quoteStartDate, Date quoteEndDate, Date quoteFirstYearSegmentTermEndDate) {
     	
        Double noOfQuoteLines = 0 ;
        
        //Check for start and end date on Component subscription 
        if (quoteStartDate != null && quoteEndDate != null){
            
            //get total no of months
            Integer monthsDuration = (quoteStartDate).monthsBetween(quoteEndDate);
            
            //get no of years
            noOfQuoteLines = System.Math.ceil((Decimal)monthsDuration/12);
            
            //check for first year segment term end date
            if(quoteFirstYearSegmentTermEndDate != null) {
                
                //Reset the Start date for the 2nd year of the quote if any 
                quoteStartDate = quoteFirstYearSegmentTermEndDate.addDays(1);
                
                //re calculate the total no of months
                monthsDuration = (quoteStartDate).monthsBetween(quoteEndDate);
                
                //re calculate the number of years (counting start from the 2nd year) 
            	noOfQuoteLines = (System.Math.ceil((Decimal)monthsDuration/12));
                
                //compansate year counter for the first year. as in the above step we are getting the no of years from 2nd year
                noOfQuoteLines = noOfQuoteLines + 1 ;
            }
        }
                
        return noOfQuoteLines;
    }
}