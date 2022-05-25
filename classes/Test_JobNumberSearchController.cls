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

@isTest
public class Test_JobNumberSearchController {
/**
  *   Purpose         :   Test class for JobNumberSearchController 
  *            
  *   Create By       :    
  * 
  *   Created Date    :   06/26/2020
  *
  *   Revision Log    :   V_1.0 - Created - 
  *                       
  * 
  *   Coverage        :   V_1.0 - 
**/
 
    @TestSetup
    static void setupData(){
        
        Util.BypassAllTriggers = true;
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        Product2 prod = new Product2(Name = 'Test Product');
        insert prod;
        
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
                //create Test data for Account object as an institute
        Account account = new Account(Name = 'AccountTest1');
        insert account;
        
        Program_Package__c prog = new Program_Package__c(Name = 'TestProgram',  Account__c = acc.Id, Fiscal_Year__c = '2019');
        insert prog;
        
        List<Royall_Program__c> royalPs = new List<Royall_Program__c>();
        
        royalPs.add(new Royall_Program__c(Name = 'Test Royal Program', Status__c = 'Opportunity', Program_Package__c = prog.Id, Contact_Quantity__c = 20, Target_Audience_New__c = 'Advancement Accounts', Type__c= 'Re-engagement'));
        insert royalPs;
        
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
        
        
        //List of Product
        List<Product2> products = new List<Product2>();
        
        //Add new Products in List
        products.add(new Product2(Name = 'RI Product', Family = 'RI', Program__c = programs[0].Id, IsActive = true,
                      ProductCode = 'RIPRO'));
    
    products.add(new Product2(Name = 'PT Product', Family = 'PT', Program__c = programs[1].Id, IsActive = true,
                      ProductCode = 'PTPRO'));
    
    //Insert
    insert products;
        
        
       //List to hold the Proposal record 
        List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
        
        //Add new quote record in list
        quotes.add(new SBQQ__Quote__c(SBQQ__Status__c = 'Draft', SBQQ__Type__c = 'Quote', SBQQ__Primary__c = true, SBQQ__Account__c = acc.Id));
        quotes.add(new SBQQ__Quote__c(SBQQ__Status__c = 'Accepted', SBQQ__Type__c = 'Quote', SBQQ__Primary__c = true));
        quotes.add(new SBQQ__Quote__c(SBQQ__Status__c = 'Approved', SBQQ__Type__c = 'Quote', SBQQ__Primary__c = true));
        
        //Insert list of Quote
        insert quotes;
        
        //List of quote line item to insert
        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        
        //Add new Quote lines n list
        quoteLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = quotes[0].Id, SBQQ__Product__c = products[0].Id, SBQQ__NetPrice__c = 100));
        quoteLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = quotes[1].Id, SBQQ__Product__c = products[0].Id, SBQQ__NetPrice__c = 500));
        
        //Insert tye listb of quote line 
        insert quoteLines;
        
        
        //List to hold the record's type 
        List<RecordType> recordTypes = [Select Id, Name from RecordType Where SobjectType = 'SBQQ__Subscription__c' AND IsActive = true
                                        AND DeveloperName =: CPQConstants.SBQQ_SUBSCRIPTION_RECORD_TYPE_DEVELOPERNAME_PROGRAM];
        


        //Create contact
        Contact contact = new Contact(LastName = 'TestingABC', AccountId = account.Id, Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855');
        insert contact;

        //create Contract ABC test data
        Contract__c contractABC = new Contract__c(Name = 'TestContract1', Invoicing_Arrangement__c = 'Special', Payer_Account__c = account.Id,
                                                Year__c = '2017', Type__c = 'NBB', Main_Contact__c = contact.Id, Invoice_Contact__c = contact.Id,
                                                Negotiated_Amount__c = 12 );

        //Insert the contract ABC
        insert contractABC;

        //List to hold subscription
        List<SBQQ__Subscription__c> subscriptions = new List<SBQQ__Subscription__c>();  

        //Add new subscription record in list
        subscriptions.add(new SBQQ__Subscription__c(SBQQ__Quantity__c = 1, Previous_Period_Plus_Uplift__c = 1000,
                                                    SBQQ__ListPrice__c = 0, RecordTypeId = recordTypes[0].Id, SBQQ__Product__c = products[0].Id,
                                                    SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0, SBQQ__ProrateMultiplier__c = 2,
                                                    Status__c = 'Committed', Official_Drop_Date__c = Date.today()));
        subscriptions.add(new SBQQ__Subscription__c(SBQQ__Quantity__c = 3, Previous_Period_Plus_Uplift__c = 2000,
                                                    SBQQ__ListPrice__c = 0, RecordTypeId = recordTypes[0].Id, SBQQ__Product__c = products[1].Id,
                                                    SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0, SBQQ__ProrateMultiplier__c = 2,
                                                    Status__c = 'Committed', Official_Drop_Date__c = Date.today()));                                                       
        //Insert
        insert subscriptions;        

        //List to hold the Subscription Period records
        List<Subscription_Period__c> listOfSubscriptionPeriod = new List<Subscription_Period__c>();
        List<User> usrs = [Select Id, Name From User Order By Name ASC Limit 2];
        //Add the new 
        listOfSubscriptionPeriod.add(new  Subscription_Period__c(Program_Subscription__c = subscriptions[0].Id, Period_Start_Date__c = Date.Today(), Period_End_Date__c = Date.Today() + 5,Institution__c = account.Id,
                                                                Stage__c = 'Honorary', Segment_Index__c = 3, Opt_Out_Date__c = Date.today(), Renewal_Owner__c = usrs[0].Id, Research_Strategic_Leader__c = usrs[0].Id));
        listOfSubscriptionPeriod.add(new  Subscription_Period__c(Program_Subscription__c = subscriptions[0].Id, Period_Start_Date__c = Date.Today() + 2,Period_End_Date__c = Date.Today() + 5, 
                                                                Stage__c = 'Pending', Segment_Index__c = 100, Opt_Out_Date__c = Date.today(), Renewal_Owner__c = usrs[0].Id, Research_Strategic_Leader__c = usrs[0].Id));
        listOfSubscriptionPeriod.add(new  Subscription_Period__c(Program_Subscription__c = subscriptions[1].Id, Period_Start_Date__c = Date.Today() + 3, Period_End_Date__c = Date.Today() + 5,
                                                                Stage__c = CPQConstants.SUBSCRIPTION_PERIOD_STAGE_DROPPED, Segment_Index__c = 13, Opt_Out_Date__c = Date.today(), Renewal_Owner__c = usrs[0].Id, Research_Strategic_Leader__c = usrs[0].Id));                                                     
        listOfSubscriptionPeriod.add(new  Subscription_Period__c(Program_Subscription__c = subscriptions[1].Id, Period_Start_Date__c = Date.Today() + 5, Period_End_Date__c = Date.Today() + 8,Institution__c = account.Id,
                                                                Stage__c = 'Pending', Segment_Index__c = 15, Opt_Out_Date__c = Date.today(), Renewal_Owner__c = usrs[0].Id, Research_Strategic_Leader__c = usrs[0].Id));                                                      
        //Insert the listOfSubscriptionPeriod
        insert listOfSubscriptionPeriod;
        
        
        
         // Create Account
        Account inst = new Account(Vendor_Type__c = 'Vendor', Name = 'Test1',Account_Formal_Name__c = 'Central State University',r_School_Code__c = '1234');
        insert inst;
        
        //Create a user for running the process
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];

        User user1 = testUtilities.CreateNewUser(sysAdminProfile, false);
        user1.LastName = 'sysAdminUser';
        insert user1;
        
        //Creating ES Campaign record
        List<ES_Campaign__c> escCampaigns = new List<ES_Campaign__c>();
        escCampaigns.add(new ES_Campaign__c(Fiscal_Year__c = '2019', Status__c = 'Open', School__c = inst.Id, Project_Manager__c = user1.id));
        escCampaigns.add(new ES_Campaign__c(Fiscal_Year__c = '2020', Status__c = 'In Process', School__c = inst.Id, Project_Manager__c = user1.id));
        insert escCampaigns;
        
        
        Project__c project = new Project__c(Name = 'Test Project', Institution__c = inst.Id);
        insert project;
        
        List<Profile> ps = [select id, name from Profile where  name = 'System Administrator' LIMIT 1];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = ps[0].Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser32525698@testorg.com');
        insert u;
        
        /* Insert Job_Ticket__c
        List<Job_Ticket__c> jobTickets = new List<Job_Ticket__c>();
        jobTickets.add(new Job_Ticket__c(ES_Campaign__c = escCampaigns[0].Id, Mail_Quantity__c = 500, Status__c = 'Draft', Art_Director__c = u.Id, Descriptive_Name__c = '### Test Record ###', Project_Manager__c = u.Id, Change_Reason__c = 'Testing before update' ));
        
        
        jobTickets.add(new Job_Ticket__c(Vendor_Type__c = 'Offset',ES_Campaign__c = escCampaigns[1].Id, Mail_Quantity__c = 1000, Status__c = 'Draft', Art_Director__c = u.Id, Descriptive_Name__c = '### Test Record ###', Project_Manager__c = u.Id, 
                                         Project__c = project.id,Change_Reason__c = 'Testing before update', Mail_Date__c = system.today(),Production_Manager__c = u.Id,of_Drops__c =2,of_Letter_Versions__c = 1));
        
        
        insert jobTickets;*/
        
        
    }
    
    static testMethod void unitTest(){
        
        Test.startTest();
        
        List<Object> returnedList = JobNumberSearchController.retrievejobNumberSearch('Te');
        
        Test.stopTest();
    
        system.assert(returnedList.size()>0);
    }
    
}