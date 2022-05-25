@isTest(seeAllData = false)
private class Test_Batch_DataUpdatePopulaParentProduct
{
    
    /**
*  @description    :   The method is used to insert common data which are useful in testing
*  Create By       :   Dipesh Gupta
*  Created Date    :   27/05/2020
**/   
    @testSetup static void dataSetup()
    {
        //ByPass all the triggers
        Util.byPassAllTriggers = true;
        
        
        
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
        
        List<Program__c> programList = [Select Id From Program__c];
        System.assertEquals(3, programList.size());
        
        Product2 prod = new Product2();
        prod.Name = 'RI Product2';
        prod.Family = 'RI';
        prod.Program__c = programList[2].Id;
        prod.IsActive = true;
        prod.ProductCode = 'RIPRO2';
        insert prod;
        
        //List of Product
        List<Product2> products = new List<Product2>();
        
        //Add new Products in List
        products.add(new Product2(Name = 'RI Product', Family = 'RI', Program__c = programList[0].Id, IsActive = true,
                                  ProductCode = 'RIPRO'));
        
        products.add(new Product2(Name = 'PT Product', Family = 'PT', Program__c = programList[1].Id, IsActive = true,
                                  ProductCode = 'PTPRO',Parent_Product__c = prod.Id));
        
        //Insert
        insert products;
        
        
        List<Product2> productList = [Select Id From Product2];
        System.assertEquals(3, productList.size());
        
        //Create the opportunity record 
        Opportunity opp = TestUtilities.CreateNewOpportunity(true);
        
        //List to hold the Proposal record 
        List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
        
        //Add new quote record in list
        quotes.add(new SBQQ__Quote__c(SBQQ__Status__c = 'Draft', SBQQ__Type__c = 'Quote', SBQQ__Primary__c = true, SBQQ__Opportunity2__c = opp.Id ));
        //quotes.add(new SBQQ__Quote__c(SBQQ__Status__c = 'Draft', SBQQ__Type__c = 'Quote', SBQQ__Primary__c = true, SBQQ__Opportunity2__c = opp.Id));
        //quotes.add(new SBQQ__Quote__c(SBQQ__Status__c = 'Draft', SBQQ__Type__c = 'Quote', SBQQ__Primary__c = true, SBQQ__Opportunity2__c = opp.Id));
        
        //Insert list of Quote
        insert quotes;
        
        List<SBQQ__Quote__c> quoteList = [Select Id From SBQQ__Quote__c];
        System.assertEquals(1, quoteList.size());
        
        //List of quote line item to insert
        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        //Add new Quote lines n list
        quoteLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = quotes[0].Id, SBQQ__Product__c = products[0].Id, SBQQ__NetPrice__c = 100));
        quoteLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = quotes[0].Id, SBQQ__Product__c = productList[2].Id, SBQQ__NetPrice__c = 300,Top_Parent_Product__c = products[1].Id));
        
        //Insert tye listb of quote line 
        insert quoteLines;   
        
         //List of quote line item child to insert
        List<SBQQ__QuoteLine__c> quoteLinesChild = new List<SBQQ__QuoteLine__c>();
        quoteLinesChild.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = quotes[0].Id, SBQQ__RequiredBy__c = quoteLines[1].Id , SBQQ__NetPrice__c = 500,SBQQ__Product__c = products[0].Id));
        quoteLinesChild.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = quotes[0].Id, SBQQ__RequiredBy__c = quoteLines[0].Id , SBQQ__NetPrice__c = 4500, Top_Parent_Product__c = products[1].Id,SBQQ__Product__c = productList[2].Id));
        insert quoteLinesChild;
        
        
        
        
        List<SBQQ__QuoteLine__c> quoteLineList = [Select Id From SBQQ__QuoteLine__c];
        System.assertEquals(4, quoteLineList.size());
        
        
        //Reset variable
        Util.BypassAllTriggers = false;
        
    }
    
    static testMethod void test_dataUpdatePopulateParentProductWithQuery()
    {
        
        //Reset variable
        Util.BypassAllTriggers = true;
        
        //List of SBQQ__QuoteLine__c
        List<SBQQ__QuoteLine__c> quoteLineList = [Select Id, SBQQ__Quote__c, SBQQ__RequiredBy__c, Top_Parent_Product__c,SBQQ__Product__c, SBQQ__Product__r.Name, SBQQ__Product__r.Parent_Product__c, SBQQ__RequiredBy__r.Top_Parent_Product__c FROM SBQQ__QuoteLine__c];
        System.assertEquals(4, quoteLineList.size() );
        
        
        test.startTest();
        Batch_DataUpdatePopulateParentProduct batch = new Batch_DataUpdatePopulateParentProduct();
        batch.query = 'Select Id, SBQQ__Quote__c, SBQQ__RequiredBy__c, Top_Parent_Product__c, Related_Product_with_Parent_Product__c,SBQQ__Product__c, SBQQ__Product__r.Name, SBQQ__Product__r.Parent_Product__c, SBQQ__RequiredBy__r.Top_Parent_Product__c FROM SBQQ__QuoteLine__c ' 
        + 'Where Top_Parent_Product__c != null ORDER BY SBQQ__Quote__c ASC, Name ASC';
        database.executeBatch(batch);
      
        test.stopTest();
    }
    
    static testMethod void test_dataUpdatePopulateParentProductWithoutQuery()
    {
        
        //Reset variable
        Util.BypassAllTriggers = true;
        
        //List of SBQQ__QuoteLine__c
        List<SBQQ__QuoteLine__c> quoteLineList = [Select Id, SBQQ__Quote__c, SBQQ__RequiredBy__c, Top_Parent_Product__c,SBQQ__Product__c, SBQQ__Product__r.Name, SBQQ__Product__r.Parent_Product__c, SBQQ__RequiredBy__r.Top_Parent_Product__c FROM SBQQ__QuoteLine__c];
        System.assertEquals(4, quoteLineList.size() );
        
        
        test.startTest();
        Batch_DataUpdatePopulateParentProduct batch = new Batch_DataUpdatePopulateParentProduct();
        batch.query = '';
        database.executeBatch(batch);
      
        test.stopTest();
    }
    
}