/**
 *  Purpose   	  :   Test class for ProductTriggerHelper
 *  
 *  CreatedDate   :   09/29/2021
 *  
 *  RevisionLog   :   V_1.0 - Created - Nikita Kumari - CR-20210910-15426
 *  
**/
@isTest(seeAllData = false)
private class Test_ProductTriggerHelper {
    @testSetup static void setup() {
    
        //Bypass Triggers
	Util.BypassAllTriggers = true;
        
        //Create is list of program
        List<Program__c> programs = new List<Program__c>();
        
        for(Integer i = 0; i <5; i++) {
            programs.add(new Program__c(Name = 'testName' + i, Program_Acronym__c = 'testCode' + i, Business_line__c = 'businessLine', Status__c = 'Active'));
        }
        
        //Insert programs
        insert programs;
        
        //Bypass Triggers
	Util.BypassAllTriggers = false;
        
    }
    
  /**
   *   Purpose         :   Test method populateProductOnProgram
   *            
   *   Create By       :   Nikita Kumari
   *
   *   Created Date    :   09/29/2021
   *
   *   Revision Log    :   V_1.0 - Created - Nikita Kumari 
   *
  **/
    static testMethod void test_populateProductOnProgram(){
        
        //list of program
        List<Program__c> programs = [Select Id,Name,Program_Acronym__c,Business_line__c,Status__c From Program__c];
        
        List<Product2> products = new List<Product2>();
        //Creating Product records
        products.add(new Product2(Name = 'EDIF - Independent School Executive Forum', ProductCode = 'EDIF',
                                 Program_Name_Member_Facing__c = 'Independent School Executive Forum',
                                 Family = 'RI', IsActive = true,
                                 Program__c = programs[0].Id, c2g__CODASalesTaxStatus__c = 'Taxable'));
        			 products.add(new Product2(Name = 'EDIF - Independent School Executive Forum1', ProductCode = 'EDIF1',
                                 Program_Name_Member_Facing__c = 'Independent School Executive Forum1',
                                 Family = 'RI', IsActive = true,
                                 Program__c = programs[1].Id, c2g__CODASalesTaxStatus__c = 'Taxable'));
        //Test Start here
        Test.startTest();
	
        //Insert products   
        insert products;
        System.assertEquals(programs[0].Id, products[0].Program__c);
        System.assertEquals(programs[1].Id, products[1].Program__c);
        
        products[0].Program__c = programs[2].Id;
        products[1].Program__c = programs[3].Id;
        
        //update products
        update products;
        
        System.assertEquals(programs[2].Id, products[0].Program__c);
        System.assertEquals(programs[3].Id, products[1].Program__c);
        
        //Stop test here
        Test.stopTest();
    }
    
  /**
   *   Purpose         :   Test method validateShortOrder
   *            
   *   Create By       :   Abhishek Mishra
   *
   *   Created Date    :   09/29/2021
   *
   *   Revision Log    :   V_1.0 - Created - Abhishek Mishra 
   *
  **/
    static testMethod void test_validateShortOrder(){
        
        //list of program
        List<Program__c> programs = [Select Id,Name,Program_Acronym__c,Business_line__c,Status__c From Program__c];
        
        List<Product2> products = new List<Product2>();
        //Creating Product records
        products.add(new Product2(Name = 'EDIF - Independent School Executive Forum', ProductCode = 'EDIF',
                                 Program_Name_Member_Facing__c = 'Independent School Executive Forum',
                                 Family = 'RI', IsActive = true,SBQQ__Component__c = false,Offer__c=false,
                                 Program__c = programs[0].Id, c2g__CODASalesTaxStatus__c = 'Taxable'));
        			 products.add(new Product2(Name = 'ADIF - Independent School Executive Forum1', ProductCode = 'ADIF',
                                 Program_Name_Member_Facing__c = 'Independent School Executive Forum1',
                                 Family = 'RI', IsActive = true,SBQQ__Component__c = false,Offer__c=false,
                                 Program__c = programs[1].Id, c2g__CODASalesTaxStatus__c = 'Taxable'));
        			 products.add(new Product2(Name = 'BDIF - Independent School Executive Forum1', ProductCode = 'BDIF',
                                 Program_Name_Member_Facing__c = 'Independent School Executive Forum1',
                                 Family = 'None', IsActive = true,SBQQ__Component__c = false,Offer__c=false,
                                 Program__c = programs[2].Id, c2g__CODASalesTaxStatus__c = 'Taxable'));
        
        //Test Start here
        Test.startTest();
        //Insert products   
        insert products;
        
        products[0].SBQQ__Component__c = true;
        products[1].Offer__c = true;
        products[2].Family = 'RI';
        
        update products;
        products = [Select Id,Name,Family,SBQQ__Component__c,Program__c,Offer__c, SBQQ__SortOrder__c, Sort_Order_Formula__c From Product2 ORDER BY Family ASC, Name ASC];
        System.assertEquals(1, products[0].SBQQ__SortOrder__c);
        System.assertEquals(2, products[1].SBQQ__SortOrder__c);
        System.assertEquals(3, products[2].SBQQ__SortOrder__c);
        
        //Stop test here
        Test.stopTest();
        
    }
    /**
     *   Purpose         :   Test method validateProgramCodes
     *            
     *   Create By       :   Nikita Kumari
     *
     *   Created Date    :   09/29/2021
     *
     *   Revision Log    :   V_1.0 - Created - Nikita Kumari 
     *
     **/
    static testMethod void test_validateProgramCodes(){
        
        //Bypass Triggers
	Util.BypassAllTriggers = true;
	
        List<Product2> productsList = new List<Product2>();
        
        productsList.add(new Product2(Name = 'EDIF - Independent School Executive Forum', ProductCode = 'zzz',
                                 Program_Name_Member_Facing__c = 'Independent School Executive Forum',
                                 Family = 'RI', IsActive = true,SBQQ__Component__c = false,Offer__c=false,
                                 c2g__CODASalesTaxStatus__c = 'Taxable'));
				 
        productsList.add(new Product2(Name = 'EDIF - Independent School Executive Forum', ProductCode = 'zzz',
                                 Program_Name_Member_Facing__c = 'Independent School Executive Forum',
                                 Family = 'RI', IsActive = true,SBQQ__Component__c = false,Offer__c=false,
                                 c2g__CODASalesTaxStatus__c = 'Taxable'));
        insert productsList;
        
	Util.BypassAllTriggers = false;
        
        List<Product2> products = new List<Product2>();
        //Creating Product records
        products.add(new Product2(Name = 'EDIF - Independent School Executive Forum', ProductCode = 'EDIF',
                                 Program_Name_Member_Facing__c = 'Independent School Executive Forum',
                                 Family = 'RI', IsActive = true,SBQQ__Component__c = false,Offer__c=false,
                                 c2g__CODASalesTaxStatus__c = 'Taxable'));
        products.add(new Product2(Name = 'ADIF - Independent School Executive Forum1', ProductCode = 'ADIF',
                                 Program_Name_Member_Facing__c = 'Independent School Executive Forum1',
                                 Family = 'RI', IsActive = true,SBQQ__Component__c = false,Offer__c=false,
                                 c2g__CODASalesTaxStatus__c = 'Taxable'));
        products.add(new Product2(Name = 'BDIF - Independent School Executive Forum1', ProductCode = 'BDIF',
                                 Program_Name_Member_Facing__c = 'Independent School Executive Forum1',
                                 Family = 'None', IsActive = true,SBQQ__Component__c = false,Offer__c=false,
                                 c2g__CODASalesTaxStatus__c = 'Taxable'));
        products.add(new Product2(Name = 'CDIF - Independent School Executive Forum2', ProductCode = 'CDIF',
                                 Program_Name_Member_Facing__c = 'Independent School Executive Forum1',
                                 Family = 'None', IsActive = true,SBQQ__Component__c = false,Offer__c=false,
                                 c2g__CODASalesTaxStatus__c = 'Taxable'));
        products.add(new Product2(Name = 'DDIF - Independent School Executive Forum1',
                                 Program_Name_Member_Facing__c = 'Independent School Executive Forum1',
                                 Family = 'None', IsActive = true,SBQQ__Component__c = false,Offer__c=false,
                                 c2g__CODASalesTaxStatus__c = 'Taxable'));
        
        insert products;
        
       
        Product2 prduct = new Product2(Name = 'EDIF - Independent School Executive Forum', ProductCode = 'EDIF',
                                 	Program_Name_Member_Facing__c = 'Independent School Executive Forum',
                                 	Family = 'RI', IsActive = true,SBQQ__Component__c = false,Offer__c=false,
                                 	c2g__CODASalesTaxStatus__c = 'Taxable');
        //Test Start here
        Test.startTest(); 
        
         try {
             
            Insert prduct;
        
        } catch(Exception e) {
            
            String Recordlink = URL.getSalesforceBaseUrl().toExternalForm()+'/'+ products[0].Id;
            String errormsg = System.Label.ERROR_PRODUCT_DUPLICATE_PRODUCT_CODE_WITH_RECORDLINK + RecordLink; 
            
            //Assert failed in case of exception
            System.assertEquals(e.getMessage().contains(errormsg), true);  
        }
        
        products[2].ProductCode = 'EDIF';
        
         try {
             
            update products;
        
        } catch(Exception e) {
            
            String Recordlink = URL.getSalesforceBaseUrl().toExternalForm()+'/'+ products[0].Id;
            String errormsg = System.Label.ERROR_PRODUCT_DUPLICATE_PRODUCT_CODE_WITH_RECORDLINK + RecordLink;
            
            //Assert failed in case of exception
            System.assertEquals(e.getMessage().contains(errormsg), true);  
        }
        Product2 prodct = new Product2(Name = 'BDIF - Independent School Executive Forum1',
                                 Program_Name_Member_Facing__c = 'Independent School Executive Forum1',
                                 Family = 'None', IsActive = true,SBQQ__Component__c = false,Offer__c=false,
                                 c2g__CODASalesTaxStatus__c = 'Taxable');
        insert prodct;
        List<Product2> prodctList = [Select Id,Name,ProductCode From Product2 Where ProductCode = null];
        System.assertEquals(2,prodctList.size());
        
        products[3].ProductCode = null;
        update products[3];
        
        prodctList = [Select Id,Name,ProductCode From Product2 Where ProductCode = null];
        System.assertEquals(3,prodctList.size());
        
        List<Product2> prodList = new List<Product2>();
        prodList.add(new Product2(Name = 'New Names', Family = 'Enrollment Services',IsActive = true,
                                  ProductCode = 'ESNN',SBQQ__SortOrder__c = 2,SBQQ__Component__c = true));
        prodList.add(new Product2(Name = 'New Names1', Family = 'Enrollment Services',IsActive = true,
                                  ProductCode = 'ESNN',SBQQ__SortOrder__c = 2,SBQQ__Component__c = true));
        
        try {
             
            insert prodList;
        
        } catch(Exception e) {
           
            String errormsg = System.Label.ERROR_PRODUCT_DUPLICATE_PRODUCT_CODE; 
            
            //Assert failed in case of exception
            System.assertEquals(e.getMessage().contains(errormsg), true);  
        }
        
       
        Product2 product = new Product2(Name = 'EDIF - Independent School Executive Forum', ProductCode = 'zzz',
                                 Program_Name_Member_Facing__c = 'Independent School Executive Forum',
                                 Family = 'RI', IsActive = true,SBQQ__Component__c = false,Offer__c=false,
                                 c2g__CODASalesTaxStatus__c = 'Taxable');
         
        
        try {
             
            insert product;
        
        } catch(Exception e) {
            
            String Recordlink = URL.getSalesforceBaseUrl().toExternalForm()+'/'+ productsList[0].Id + '; ' + URL.getSalesforceBaseUrl().toExternalForm()+'/' + productsList[1].Id;
            String errormsg = System.Label.ERROR_PRODUCT_DUPLICATE_PRODUCT_CODE_WITH_RECORDLINK + RecordLink;
            
            //Assert failed in case of exception
            System.assertEquals(e.getMessage().contains(errormsg), true);  
        }
        
        //Stop test here
        Test.stopTest();
    }

}