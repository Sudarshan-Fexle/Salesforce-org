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
@isTest(seeAllData=false)
private class Test_ContractControllerExtension {
/**
  *   Purpose         :   Test class for ContractControllerExtension
  *            
  *   Create By       :   Deepak Kumar
  * 
  *   Created Date    :   07/15/2017
  *
  *   Revision Log    :   V_1.0 - Created -Deepak Kumar - CR-20170403-10807 
  * 					  V_1.1 - CR-20180301-12089 Validation Error fix- Subhash Garhwal - 03/07/2018
  *                       
  * 
  *   Coverage        :   V_1.0 - 
**/

    static testMethod void myUnitTest() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //ByPass all the triggers
        Util.byPassAllTriggers = true;
        
        //List to hold the Subscription record's type 
        List<RecordType> recordTypes = [Select Id, Name from RecordType Where SobjectType = 'SBQQ__Subscription__c' AND IsActive = true
                                        AND DeveloperName IN ('Program', 'Component') ORDER By DeveloperName ASC];
        
        
        //List to hold Institution records
		List<Account> accounts = new List<Account>();
		
		//Add the account record into list
		accounts.add(new Account(Name = 'Test1', Status__c = 'Active' ));
		accounts.add(new Account(Name = 'Test2', Status__c = 'Active' ));
		
		//Insert the accountlist
		insert accounts;
		
		//List contract record 
		List<Contract> contracts = new List<Contract>();
		
		//Create Contract record 
    	Contract contract1 =  TestUtilities.createNewStandardContract(accounts[0].Id, false);
    	Contract contract2 =  TestUtilities.createNewStandardContract(accounts[1].Id, false);
    	
    	//Add into list
    	contracts.add(contract1); contracts.add(contract2);  
    	
    	//Insert the contract list
    	insert contracts;
    	
    	//Insert the Program test data
    	Program__c testProg = new Program__c(Name='Test Trigger Program', New_Business_Marketer__c = 'RI Marketer', Program_Acronym__c='ZZZ', Create_memberships__c='No', Business_line__c = 'PT');
        
        //Insert the data
        insert testProg;
    	
    	//Create membership data
        Membership__c membership = new Membership__c(Account_Name__c = accounts[0].id, Program__c = testProg.id);
        
        //Insert the membership 
        insert membership;
    	
    	//List of Product
        List<Product2> listOfProduct = new List<Product2>();
        
        //Add new Products in List
        listOfProduct.add(new Product2(Name = 'RI Product', Family = 'RI', IsActive = true,
                           SBQQ__Component__c = true, ProductCode = 'RIPRO', Offer__c = false));
        
        listOfProduct.add(new Product2(Name = 'PT Product', Family = 'PT', IsActive = true,
                            SBQQ__Component__c = true, ProductCode = 'PTPRO', Offer__c = false));

        listOfProduct.add(new Product2(Name = 'PT Product', Family = 'PT', IsActive = true,
                            SBQQ__Component__c = false, ProductCode = 'PTPRO', Offer__c = true));

		//Insert the productlist 
        insert listOfProduct;
    	
		//List to hold the Subscription 
		List<SBQQ__Subscription__c> subscriptions = new List<SBQQ__Subscription__c>();
        
        //Create subscription record 
        SBQQ__Subscription__c subs1 = TestUtilities.createNewSubscription(membership.Id, false);
        subs1.SBQQ__Contract__c = contracts[0].Id;
        subs1.RecordTypeId = recordTypes[1].Id;
        subs1.SBQQ__Product__c = listOfProduct[0].Id;
        
        SBQQ__Subscription__c subs2 = TestUtilities.createNewSubscription(membership.Id, false);
        subs2.RecordTypeId = recordTypes[1].Id;
        subs2.SBQQ__Contract__c = contracts[0].Id;
        subs2.SBQQ__Product__c = listOfProduct[2].Id;
          
        SBQQ__Subscription__c subs3 = TestUtilities.createNewSubscription(membership.Id, false);
        //Changed the Record type from 0 to 1, to avoid FIELD_FILTER_VALIDATION_EXCEPTION, The Subscription must be of a Program record type.: [Program_Subscription__c] 
        //Error - CR-20180301-12089 Validation Error - Subhash Garhwal - 03/07/2018
        subs3.RecordTypeId = recordTypes[1].Id;
    	subs3.SBQQ__Contract__c = contracts[1].Id;
    	subs3.SBQQ__Product__c = listOfProduct[1].Id;
        
    	//add the subscription record into subscription list
    	subscriptions.add(subs1); subscriptions.add(subs2); subscriptions.add(subs3); 
    	
    	//Insert the subscriptions list  
    	insert subscriptions;
    	
        
        //List to hold the subscriptionPeriod 
    	List<Subscription_Period__c> subscriptionPeriods = new List<Subscription_Period__c>();
    	
    	//Create SubscriptionPeriod
    	Subscription_Period__c subsPeriod1 = TestUtilities.createNewSubscriptionPeriod(subscriptions[0].Id, false);
    	Subscription_Period__c subsPeriod2 = TestUtilities.createNewSubscriptionPeriod(subscriptions[1].Id, false);
    	
    	subsPeriod1.Program_Subscription__c = subscriptions[0].Id;
    	subsPeriod1.Contract__c = contracts[0].Id;
    	  
    	subsPeriod2.Program_Subscription__c = subscriptions[1].Id; 
    	subsPeriod2.Contract__c = contracts[1].Id;
    	
    	//add into list
    	subscriptionPeriods.add(subsPeriod1);  subscriptionPeriods.add(subsPeriod2);
    	
    	//Insert the subscriptionPeriods
    	insert subscriptionPeriods; 
    	
    	//set the page reference
        PageReference pageRef = Page.stdContractDetail;
        test.setCurrentPage(pageRef);
    	
    	//Start Testing from here
        Test.startTest();
        
        //Standard controller       
        ApexPages.StandardController sc = new ApexPages.standardController(contracts[0]);
        
        //Controller
        ContractControllerExtension controller = new ContractControllerExtension(sc);
        
    	//Assert for result
    	System.assertEquals(5, controller.displayCount1);        
        System.assertEquals(5, controller.displayCount1);
        System.assertEquals(5, controller.displayCount1);
        //System.assertEquals(false, controller.isSelected);
        
       	/*System.assertEquals(1, controller.listProgSubscriptions.size());
       	System.assertEquals(1, controller.totalProgramSubscriptionCount);
       	System.assertEquals(1, controller.listSubscriptionPeriods.size());
       	System.assertEquals(1, controller.totalSubscriptionPeriodCount);
       	System.assertEquals(1, controller.listProgComponentSubscriptions.size());
       	System.assertEquals(1, controller.totalProgramComponentSubscriptionCount);  */
       	
       	//Call the controller method 
       	controller.showMoreRelatedList1();
       	controller.showMoreRelatedList2();
       	controller.showMoreRelatedList3();
       	
       	//Re-Inliation of standard controller
      	sc = new ApexPages.standardController(contracts[1]);
        
        //Controller
        controller = new ContractControllerExtension(sc);
      	
       /*System.assertEquals(0, controller.listProgSubscriptions.size());
       	System.assertEquals(0, controller.totalProgramSubscriptionCount);
       System.assertEquals(1, controller.listSubscriptionPeriods.size());
       	System.assertEquals(1, controller.totalSubscriptionPeriodCount); */
       	
       	//Call the controller save method 
       	controller.doSave();
       	
       	//Assert for result
       	
       	//Call the saveAndClose
       	controller.saveAndClose(); 
       	
       	//Testing stop here
        Test.Stoptest(); 
       	
    }
    
    static testMethod void myUnitTest2() {
        
        //Bypassing all triggers
        Util.byPassAllTriggers = true;
        Util.IsTest(true);
        
        //List to hold the record's type 
        List<RecordType> recordTypes = [Select Id, Name from RecordType Where SobjectType = 'SBQQ__Subscription__c' AND IsActive = true
                                        AND DeveloperName =: CPQConstants.SBQQ_SUBSCRIPTION_RECORD_TYPE_DEVELOPERNAME_PROGRAM];
        
        //create Test data for Account object as an institute
        Account account1 = new Account(Name = 'AccountTest1');
        Account account2 = new Account(Name = 'AccountTest2');
       
        List<Account> accounts = new List<Account>();
        
        accounts.add(account1);
        accounts.add(account2);
        
        insert accounts;

        //List contract record 
		List<Contract> contracts = new List<Contract>();
		
		//Create Contract record 
    	Contract contract1 =  TestUtilities.createNewStandardContract(accounts[0].Id, false);
    	Contract contract2 =  TestUtilities.createNewStandardContract(accounts[1].Id, false);
    	
    	//Add into list
    	contracts.add(contract1); contracts.add(contract2);  
    	
    	//Insert the contract list
    	insert contracts;

        //List to hold subscription
        List<SBQQ__Subscription__c> subscriptions = new List<SBQQ__Subscription__c>();  

        //Add new subscription record in list
        subscriptions.add(new SBQQ__Subscription__c(SBQQ__Quantity__c = 1, Previous_Period_Plus_Uplift__c = 1000,
                                                    SBQQ__ListPrice__c = 0, RecordTypeId = recordTypes[0].Id, SBQQ__Contract__c = contracts[0].Id,
                                                    SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0, SBQQ__ProrateMultiplier__c = 2,
                                                    Status__c = 'Committed', Official_Drop_Date__c = Date.today()));
        subscriptions.add(new SBQQ__Subscription__c(SBQQ__Quantity__c = 3, Previous_Period_Plus_Uplift__c = 2000,
                                                    SBQQ__ListPrice__c = 0, RecordTypeId = recordTypes[0].Id,  SBQQ__Contract__c = contracts[1].Id,
                                                    SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0, SBQQ__ProrateMultiplier__c = 2,
                                                    Status__c = 'Committed', Official_Drop_Date__c = Date.today()));                                                       
        //Insert
        insert subscriptions;        

        //List to hold the Subscription Period records
        List<Subscription_Period__c> listOfSubscriptionPeriod = new List<Subscription_Period__c>();
        
        //Add the new 
        listOfSubscriptionPeriod.add(new  Subscription_Period__c(Program_Subscription__c = subscriptions[0].Id, Period_Start_Date__c = Date.Today(), 
                                                                Stage__c = 'Honorary', Segment_Index__c = 3, Opt_Out_Date__c = Date.today()));
        listOfSubscriptionPeriod.add(new  Subscription_Period__c(Program_Subscription__c = subscriptions[0].Id, Period_Start_Date__c = Date.Today() + 2, 
                                                                Stage__c = 'Pending', Segment_Index__c = 100, Opt_Out_Date__c = Date.today()));
        listOfSubscriptionPeriod.add(new  Subscription_Period__c(Program_Subscription__c = subscriptions[1].Id, Period_Start_Date__c = Date.Today() + 3, 
                                                                Stage__c = CPQConstants.SUBSCRIPTION_PERIOD_STAGE_DROPPED, Segment_Index__c = 13, Opt_Out_Date__c = Date.today()));                                                     
        listOfSubscriptionPeriod.add(new  Subscription_Period__c(Program_Subscription__c = subscriptions[1].Id, Period_Start_Date__c = Date.Today() + 5, 
                                                                Stage__c = 'Pending', Segment_Index__c = 15, Opt_Out_Date__c = Date.today()));                                                      
        //Insert the listOfSubscriptionPeriod
        insert listOfSubscriptionPeriod;
            
        //Test Start here 
        Test.startTest();
        
        //Enabling triggers
        Util.byPassAllTriggers = false;
        
        //Standard controller       
        ApexPages.StandardController sc = new ApexPages.standardController(contracts[0]);
        
        //Controller
        ContractControllerExtension controller = new ContractControllerExtension(sc);
        
        //Call the controller method 
       	controller.showMoreRelatedList1();
       	controller.showMoreRelatedList2();
       	controller.showMoreRelatedList3();
        list<SBQQ__Subscription__c> abs = controller.listProgSubscriptions;
        integer count = controller.totalProgramSubscriptionCount;
        
        list<Subscription_Period__c> sPeriods =  controller.listSubscriptionPeriods;
        
        integer sPCount =  controller.totalSubscriptionPeriodCount;
        
        list<SBQQ__Subscription__c> sPs =  controller.listProgComponentSubscriptions;
        
        integer CSubCount =  controller.totalProgramComponentSubscriptionCount;
        
       	//Re-Inliation of standard controller
      	sc = new ApexPages.standardController(contracts[1]);
        
        //Wrapper class  -Setting property for the As per UI - Select Contact and then select PS, and then Select Sub Period. 
		ContractControllerExtension.ContractControllerWrappper wrapper = new ContractControllerExtension.ContractControllerWrappper(subscriptions[0], true, 1);
        wrapper.subscriptionPeriodList = listOfSubscriptionPeriod;
		List<ContractControllerExtension.ContractControllerWrappper> contrlWrpper = new List<ContractControllerExtension.ContractControllerWrappper>();      
        contrlWrpper.add(wrapper);
            
        //Controller 
        controller = new ContractControllerExtension(sc);
        controller.contractControllerWrapperList = contrlWrpper;
       	controller.isSelected = true;
       	//Call the controller save method 
       	controller.doSave();
       	
       	//Assert for result
       	
       	//Call the saveAndClose
       	controller.saveAndClose(); 
       	
       	//Testing stop here
        Test.Stoptest(); 
    }
    
}