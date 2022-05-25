/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 * 
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
//V_1.1 - Modified by - Deepak Kumar - 07/04/2017 - Q2C
//V_1.2 - Modified by - Dipesh Gupta - 06/09/2020
@isTest(seeAllData = false)
private class testDealSummaryController {


    // Added by - Dipesh Gupta - 06/09/2020
	//Setup Test data
    @testSetup static void setupTestData() {
        
        //Set Flag
        Util.BypassAllTriggers = true;
        
        test.startTest();
        //List to insert Program records
        List<Program__c> programs = new List<Program__c>();
        
        //Add Program Record in list
        programs.add(TestUtilities.CreateNewProgram(false));
        programs.add(TestUtilities.CreateNewProgram(false));
        programs.add(TestUtilities.CreateNewProgram(false));
        
        //Add additional field values
        programs[0].Business_line__c = CPQConstants.PROGRAM_BUSINESS_LINE_RI;
        programs[1].Business_line__c = CPQConstants.PROGRAM_BUSINESS_LINE_PT;
        programs[2].Business_line__c = CPQConstants.PROGRAM_BUSINESS_LINE_CLN;
        
        //Insert
        insert programs;
        
        List<Program__c> ListOfPrograms = [Select Id From Program__c];
        System.assertEquals(3,ListOfPrograms.size());
        
        //List of Product
        List<Product2> products = new List<Product2>();
        
        //Add new Products in List
        products.add(new Product2(Name = 'RI Product', Family = 'RI', Program__c = programs[0].Id, IsActive = true,
                                  ProductCode = 'DASConsulting',ProductShortName__c= 'RIP'));
        
        products.add(new Product2(Name = 'PT Product', Family = 'PT', Program__c = programs[1].Id, IsActive = true,
                                  ProductCode = 'PTPRO'));
        
        products.add(new Product2(Name = 'Consulting Product', Family = 'Consulting', Program__c = programs[2].Id,
                                  IsActive = true, ProductCode = 'ConsultingPRO',Offer__c=true));
        
        //Insert
        insert products;
        
        List<Product2> ListOfProducts = [Select Id From Product2];
        System.assertEquals(3,ListOfProducts.size());
        
        //Create the opportunity record 
        Opportunity opp = TestUtilities.CreateNewOpportunity(true);
        
        List<Opportunity> ListOfOpportunity = [Select Id From Opportunity];
        System.assertEquals(1,ListOfOpportunity.size());
        
        //List to hold the Proposal record 
        List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
        
        //Add new quote record in list
        quotes.add(new SBQQ__Quote__c(SBQQ__Status__c = 'Draft', SBQQ__Type__c = 'Quote', SBQQ__Primary__c = true, SBQQ__Opportunity2__c = opp.Id ));        
        //Insert list of Quote
        insert quotes;
        
        List<SBQQ__Quote__c> quoteList = [Select Id From SBQQ__Quote__c];
        System.assertEquals(1, quoteList.size());
        
        //List of quote line item to insert
        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        //Add new Quote lines n list
        quoteLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = quotes[0].Id, SBQQ__Product__c = products[0].Id, SBQQ__NetPrice__c = 100,SBQQ__SegmentLabel__c = 'Year 1',SBQQ__ListPrice__c = 88,SBQQ__CustomerPrice__c= 123,Number_of_Students__c=1000,Operating_Expense__c=12,Proof_of_Concept__c=false));
        quoteLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = quotes[0].Id, SBQQ__Product__c = products[2].Id, SBQQ__NetPrice__c = 300,Top_Parent_Product__c = products[1].Id));
        
        //Insert tye listb of quote line 
        insert quoteLines;
        
        List<SBQQ__QuoteLine__c> quoteLineList = [Select Id From SBQQ__QuoteLine__c];
        System.assertEquals(2, quoteLineList.size());
        
        //List of quote line item child to insert
        List<SBQQ__QuoteLine__c> quoteLinesChild = new List<SBQQ__QuoteLine__c>();
        quoteLinesChild.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = quotes[0].Id, Product_Category__c= 'Travel Fee',SBQQ__RequiredBy__c = quoteLines[0].Id ,Opt_Out__c= 'Annual Opt Out on Anniversary without penalty fee',Early_Termination_Date__c = system.today()+23, SBQQ__NetPrice__c = 500,SBQQ__Product__c = products[0].Id));
        quoteLinesChild.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = quotes[0].Id,Product_Category__c= 'Annual Fee', SBQQ__RequiredBy__c = quoteLines[1].Id , SBQQ__NetPrice__c = 4500, Top_Parent_Product__c = products[1].Id,SBQQ__Product__c = products[2].Id));
        quoteLinesChild.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = quotes[0].Id,Product_Category__c= 'Implementation Fee', SBQQ__RequiredBy__c = quoteLines[1].Id , SBQQ__NetPrice__c = 4500, Top_Parent_Product__c = products[1].Id,SBQQ__Product__c = products[2].Id));
        insert quoteLinesChild;
        
        List<SBQQ__QuoteLine__c> listOfquoteLine = [Select Id From SBQQ__QuoteLine__c];
        System.assertEquals(5, listOfquoteLine.size());
        
        test.stopTest();
        
    }
	
    testMethod static void  test_Init()
    {
        List<SBQQ__Quote__c> quoteList = [Select Id From SBQQ__Quote__c];
        
        PageReference pageRef = Page.DealSummary;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('id', String.valueOf(quoteList[0].Id));
        
        DealSummaryController obj = new DealSummaryController();
    }
    
    testMethod static void  test_getoptOutValues()
    {
        List<SBQQ__QuoteLine__c> quoteLineList = [Select Id,Opt_Out__c,SBQQ__Quote__c,SBQQ__ProductName__c,SBQQ__SegmentLabel__c,SBQQ__ListPrice__c,SBQQ__Uplift__c,SBQQ__UpliftAmount__c,SBQQ__TotalDiscountAmount__c,Customer_Total__c From SBQQ__QuoteLine__c];
        System.assertEquals(5, quoteLineList.size());
        DealSummaryController obj = new DealSummaryController();
        
        String str = obj.getoptOutValues(quoteLineList[0]);
        System.assertEquals(str, 'Annual Opt Out on Anniversary without penalty fee');
        
    }
    
    testMethod static void  test_getClosestOptOutDate()
    {
        List<SBQQ__QuoteLine__c> quoteLineList = [Select Id,Opt_Out__c,Early_Termination_Date__c From SBQQ__QuoteLine__c Where Early_Termination_Date__c != null AND Opt_Out__c != null ];
        DealSummaryController obj = new DealSummaryController();
        Date erlyTermDate = obj.getClosestOptOutDate(quoteLineList[0]);
        System.assertEquals(erlyTermDate, system.today()+23);
        
    }
    
    testMethod static void  test_dasImplications()
    {
        List<SBQQ__QuoteLine__c> quoteLineList = [Select Id,Opt_Out__c,Early_Termination_Date__c From SBQQ__QuoteLine__c ];
        DealSummaryController obj = new DealSummaryController();
        String dasCode = obj.dasImplications(quoteLineList[0]);
        System.assertEquals(dasCode, 'RIP');
        
    }
    
    // inner class
    testMethod static void  test_quoteLineRecord()
    {
        List<SBQQ__QuoteLine__c> quoteLineList = [Select Id,SBQQ__AdditionalDiscount__c , SBQQ__CustomerPrice__c , SBQQ__Quote__c,SBQQ__ProductName__c,SBQQ__SegmentLabel__c,SBQQ__ListPrice__c,SBQQ__Uplift__c,SBQQ__UpliftAmount__c,SBQQ__TotalDiscountAmount__c,Customer_Total__c From SBQQ__QuoteLine__c];
        DealSummaryController.quoteLineRecord obj = new DealSummaryController.quoteLineRecord(quoteLineList[0].SBQQ__ProductName__c,quoteLineList[0].SBQQ__SegmentLabel__c,quoteLineList[0].SBQQ__ListPrice__c,quoteLineList[0].SBQQ__UpliftAmount__c,quoteLineList[0].SBQQ__Uplift__c,quoteLineList[0].SBQQ__TotalDiscountAmount__c,quoteLineList[0].Customer_Total__c , quoteLineList[0].SBQQ__AdditionalDiscount__c, quoteLineList[0].SBQQ__CustomerPrice__c);
    
    }
    
    // inner class
    testMethod static void  test_Header()
    {
        List<SBQQ__QuoteLine__c> quoteLineList = [Select Id,SBQQ__Quote__c,SBQQ__PreviousSegmentUplift__c,SBQQ__PackageTotal__c,Previous_Period_Negotiated__c,Opt_Out__c,Profit__c,Annualized_Contract_Value__c,Opt_out_Notice_Date__c,Penalty_Fee_Amount__c,Days_Notice__c,Board_Notification_Date__c,Proof_of_Concept_Decision_Date__c,Proof_of_Concept__c,Operating_Expense__c,Number_of_Students__c,SBQQ__CustomerPrice__c,SBQQ__AdditionalDiscount__c,Product_Category__c,Onsites_Offered__c,SBQQ__ProductName__c,SBQQ__SegmentLabel__c,SBQQ__ListPrice__c,SBQQ__Uplift__c,SBQQ__UpliftAmount__c,SBQQ__TotalDiscountAmount__c,Customer_Total__c From SBQQ__QuoteLine__c];
        
        DealSummaryController.Header obj = new DealSummaryController.Header();
        List<DealSummaryController.quoteLineRecord> listOfAnnualSubRecords = new list<DealSummaryController.quoteLineRecord>();
        List<DealSummaryController.quoteLineRecord> listOfTravelSubRecords = new list<DealSummaryController.quoteLineRecord>();
        List<DealSummaryController.quoteLineRecord> listOfInitSubRecords = new list<DealSummaryController.quoteLineRecord>();
        obj.annualSubRecords= listOfAnnualSubRecords;
        obj.travelSubRecords= listOfTravelSubRecords;
        obj.initSubRecords= listOfInitSubRecords;
        obj.ProductName= quoteLineList[0].SBQQ__ProductName__c;
        obj.yearLabel= quoteLineList[0].SBQQ__SegmentLabel__c;
        obj.total= quoteLineList[0].Customer_Total__c;
        obj.OfferLabels= quoteLineList[0].Onsites_Offered__c;
        obj.category= quoteLineList[0].Product_Category__c;
        obj.segLabel= quoteLineList[0].SBQQ__SegmentLabel__c;
        obj.price= quoteLineList[0].SBQQ__ListPrice__c;
        obj.upliftAmt= quoteLineList[0].SBQQ__UpliftAmount__c;
        obj.upliftPercent= quoteLineList[0].SBQQ__Uplift__c;
        obj.addlDiscount= quoteLineList[0].SBQQ__AdditionalDiscount__c;
        obj.customerPrice= quoteLineList[0].SBQQ__CustomerPrice__c;
        obj.numOfStudents= quoteLineList[0].Number_of_Students__c;
        obj.opExpense= quoteLineList[0].Operating_Expense__c;
        obj.proofOfConcept= quoteLineList[0].Proof_of_Concept__c;
        obj.proofOfConceptDate= quoteLineList[0].Proof_of_Concept_Decision_Date__c;
        obj.boardNotificationDate= quoteLineList[0].Board_Notification_Date__c;
        obj.penaltyFee= quoteLineList[0].Penalty_Fee_Amount__c;
        obj.DaysNotice= quoteLineList[0].Days_Notice__c;
        obj.optOutDate= quoteLineList[0].Opt_out_Notice_Date__c;
        obj.firstYearValue= quoteLineList[0].Annualized_Contract_Value__c;
        obj.profit= quoteLineList[0].Profit__c;
        obj.optOut= quoteLineList[0].Opt_Out__c;
        obj.previousYear= quoteLineList[0].Previous_Period_Negotiated__c;
        obj.previousYearUplift= quoteLineList[0].SBQQ__PreviousSegmentUplift__c;
        obj.dasCode= 'DASConsulting';
        obj.packageTotal= quoteLineList[0].SBQQ__PackageTotal__c;
        obj.annualTotal= quoteLineList[0].Annualized_Contract_Value__c;
        obj.travelTotal= quoteLineList[0].Annualized_Contract_Value__c;
        obj.impTotal= quoteLineList[0].Annualized_Contract_Value__c;
        obj.TabNumber= 2;
        
        
        
        
    }
    
    // test getParentProducts get set variable
    testMethod static void  test_getParentProducts()
    {
        List<SBQQ__QuoteLine__c> quoteLineList = [Select Id,Opt_Out__c,Early_Termination_Date__c From SBQQ__QuoteLine__c Where Early_Termination_Date__c != null AND Opt_Out__c != null ];
        List<SBQQ__Quote__c> quoteList = [Select Id From SBQQ__Quote__c];
        
        
        DealSummaryController obj = new DealSummaryController();
        Map<Id,DealSummaryController.Header> mapOfmm = new Map<Id,DealSummaryController.Header>();
        DealSummaryController.Header headerInstance = new DealSummaryController.Header();
        obj.proposal = quoteList[0];
         
        mapOfmm = obj.getParentProducts ;
        System.assert(mapOfmm.size()>0);
    }
    
     // test getOfferValues get set variable
    testMethod static void  test_getOfferValues()
    {
        List<SBQQ__QuoteLine__c> quoteLineList = [Select Id,Opt_Out__c,Early_Termination_Date__c From SBQQ__QuoteLine__c Where Early_Termination_Date__c != null AND Opt_Out__c != null ];
        List<SBQQ__Quote__c> quoteList = [Select Id From SBQQ__Quote__c];
        
        
        DealSummaryController obj = new DealSummaryController();
        obj.proposal = quoteList[0];
        Set<String> str= obj.getOfferValues;
        System.assert(str.contains('Consulting Product') );

    }
	
}