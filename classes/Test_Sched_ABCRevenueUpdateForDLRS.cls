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
/**
 *  Purpose         :   Test class for Sched_ABCRevenueUpdateForDLRS
 *
 *  Created By      :   Mahendra Swarnkar
 *  
 *  Created Date    :   02/06/2020
 *
 *  Revision Log    :   V1.0 - Created
 *			V1.1 - Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
 *  Code Coverage   :	
 *
 **/
@isTest(SeeAllData = false)
public class Test_Sched_ABCRevenueUpdateForDLRS {
	
    static testMethod void myUnitTest() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing triggers
        Util.BypassAllTriggers = true;
        
        //List to hold Institution records
        List<Account> accounts = new List<Account>();
        
        //Creating of Account records
        accounts.add(new Account(Name = 'Ascension Health - St. Louis - MO', Status__c = 'Active'));
        accounts.add(new Account(Name = 'RWJBarnabas Health - West Orange - NJ', Status__c = 'Active'));
        insert accounts;
        
        //Query on Opportunity record types
        List<RecordType> recordTypesOfOpp = [Select Id, DeveloperName From RecordType Where sObjectType = 'Opportunity' AND DeveloperName = 'BI_Contract_Maintenance'];
        
        //List to hold Opportunity Records
        List<Opportunity> opportunities = new List<Opportunity>();
        
        //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
        //Creating Opportunity records
        opportunities.add(new Opportunity(Sales_Pursuit_Products__c = 'APS',RecordTypeId = recordTypesOfOpp[0].Id, Name = 'Test Opp1', StageName = 'Phone Appointment Scheduled', CloseDate = System.today().addDays(30)));
        opportunities.add(new Opportunity(Sales_Pursuit_Products__c = 'APS',RecordTypeId = recordTypesOfOpp[0].Id, Name = 'Test Opp2', StageName = 'Proposal In Progress', CloseDate = System.today().addDays(30)));
        insert opportunities;
        
        //List to hold Program records
        List<Program__c> programs = new List<Program__c>();
        
        //Creating Program records
        programs.add(new Program__c(Name = 'American HealthLine', Program_Acronym__c = 'AHCP',  Create_memberships__c = 'No', Status__c = 'Active'));
        programs.add(new Program__c(Name = 'Physician Boot Camp on Leadership Fundamentals', Program_Acronym__c = 'ACBP',   Create_memberships__c = 'No', Status__c = 'Active'));
        insert programs;
        
        //Query on Contact record types
        List<RecordType> recordTypesOfCon = [Select Id, DeveloperName From RecordType Where sObjectType = 'Contact' AND DeveloperName = 'External'];
        
        //List to hold Contact records
        List<Contact> contacts = new List<Contact>();
        
        //Creating Contact Records
        contacts.add(new Contact(RecordTypeId = recordTypesOfCon[0].Id, LastName = 'Test1', AccountId = accounts[0].Id, Primary_Address_Line_1__c = '21 A',
                                Primary_City__c = 'Tzerland', Primary_Postal_Code__c = '12345', Primary_Country__c = 'Switzerland', Email='dummyemail@testemail.com',
                                 Title = 'King of the North', Phone = '555-555-5555', EAB_Role__c = 'Advisor', EAB_Department__c = 'Academic Affairs'));
        contacts.add(new Contact(RecordTypeId = recordTypesOfCon[0].Id, LastName = 'Test2', AccountId = accounts[0].Id, Primary_Address_Line_1__c = '21 A',
                                Primary_City__c = 'Tzerland', Primary_Postal_Code__c = '12345', Primary_Country__c = 'Switzerland', Email='dummyemail@testemail.com',
                                 Title = 'King of the North', Phone = '555-555-5555', EAB_Role__c = 'Advisor', EAB_Department__c = 'Academic Affairs'));
        contacts.add(new Contact(RecordTypeId = recordTypesOfCon[0].Id, LastName = 'Test3', AccountId = accounts[1].Id, Primary_Address_Line_1__c = '21 A', 
                                 Email='dummyemail@testemail.com', Title = 'King of the North', Phone = '555-555-5555', EAB_Role__c = 'Advisor', EAB_Department__c = 'Academic Affairs',
                                Primary_City__c = 'Tzerland', Primary_Postal_Code__c = '12345', Primary_Country__c = 'Switzerland'));
        contacts.add(new Contact(RecordTypeId = recordTypesOfCon[0].Id, LastName = 'Test4', AccountId = accounts[1].Id, Primary_Address_Line_1__c = '21 A',
                                Primary_City__c = 'Tzerland', Primary_Postal_Code__c = '12345', Primary_Country__c = 'Switzerland', Email='dummyemail@testemail.com',
                                 Title = 'King of the North', Phone = '555-555-5555', EAB_Role__c = 'Advisor', EAB_Department__c = 'Academic Affairs'));
        insert contacts;
        
        
        //List to hold Contract ABC
        List<Contract__c> contracts = new List<Contract__c>();
        
        //Creating Contract ABC Records
        contracts.add(new Contract__c(Name = 'Test ContractABC1', Payer_Account__c = accounts[0].Id, Source_Opportunity__c = opportunities[0].Id, 
                                      Program__c = programs[0].Id,  Invoicing_Arrangement__c = 'Annual', Main_Contact__c = contacts[0].Id,
                                      Invoice_Contact__c = contacts[1].Id, Year__c = '2016', Type__c = 'NBB', Start__c = System.today().addDays(-15),
                                      End__c = System.today().addDays(+10), Status__c = 'Pending', Term_Type__c = 'Opt Out', Years_in_Term__c = 2,
                                      Contract_Count__c = 2, Contract_Currency__c = 'EUR - Euro', Initial_Invoice_Date__c = System.today(),
                                      Opt_Out_Date__c = System.today()));
        contracts.add(new Contract__c(Name = 'Test ContractABC2', Payer_Account__c = accounts[1].Id, Source_Opportunity__c = opportunities[1].Id, 
                                      Program__c = programs[1].Id,  Invoicing_Arrangement__c = 'Semi-Annual', Main_Contact__c = contacts[2].Id,
                                      Invoice_Contact__c = contacts[3].Id, Year__c = '2017', Type__c = 'Renewal', Start__c = System.today().addDays(-5),
                                      End__c = System.today().addDays(10), Status__c = 'Void', Term_Type__c = 'Fixed Term', Years_in_Term__c = 3,
                                      Contract_Count__c = 3, Contract_Currency__c = 'QAR - Qatar Rial', Initial_Invoice_Date__c = System.today(),
                                      Opt_Out_Date__c = System.today()));
        insert contracts;
        
        //Assertions
        System.assert(contracts != null);
        System.assertEquals(2, contracts.size());
        System.assertEquals(null, contracts[0].Negotiated_Amount_RevRec__c);
        System.assertEquals(null, contracts[0].GAAP_Amount_RevRec__c);
        System.assertEquals(null, contracts[1].Negotiated_Amount_RevRec__c);
        System.assertEquals(null, contracts[1].GAAP_Amount_RevRec__c);
        
        //List to hold ABC Revenue Records
        List<ABC_Revenue__c> aBCRevenues = new List<ABC_Revenue__c>();
        
        //Creating ABC Revenue Records
        aBCRevenues.add(new ABC_Revenue__c(Contract_ABC__c = contracts[0].Id, Recognition_Start_Date__c = System.today().addDays(-2),
                                           Recognition_End_Date__c = System.today().addDays(2), Expected_Amount_to_Recognize__c = 250,
                                           Negotiated_Amount__c = 350, Secured_Amount__c = 350, GAAP_Amount__c = 0.0, Actual_Recognized_to_Date__c = 0.00, Rev_Rec_Complete__c = true));
        aBCRevenues.add(new ABC_Revenue__c(Contract_ABC__c = contracts[0].Id, Recognition_Start_Date__c = System.today().addDays(-5), 
                                           Recognition_End_Date__c = System.today().addDays(5), Expected_Amount_to_Recognize__c = 100,
                                           Negotiated_Amount__c = 500, Secured_Amount__c = 500, GAAP_Amount__c = 0, Rev_Rec_Complete__c = true));
        aBCRevenues.add(new ABC_Revenue__c(Contract_ABC__c = contracts[0].Id, Recognition_Start_Date__c = System.today().addDays(-4),
                                           Recognition_End_Date__c = System.today().addDays(4), Expected_Amount_to_Recognize__c = 200,
                                           Negotiated_Amount__c = 500, Secured_Amount__c = 500, GAAP_Amount__c = 1000, Rev_Rec_Complete__c = true));
        aBCRevenues.add(new ABC_Revenue__c(Contract_ABC__c = contracts[1].Id, Recognition_Start_Date__c = System.today().addDays(-3),
                                           Recognition_End_Date__c = System.today().addDays(3), Expected_Amount_to_Recognize__c = 250,
                                           Negotiated_Amount__c = 200, Secured_Amount__c = 200, GAAP_Amount__c = 1000));
        aBCRevenues.add(new ABC_Revenue__c(Contract_ABC__c = contracts[1].Id, Recognition_Start_Date__c = System.today().addDays(-2),
                                           Recognition_End_Date__c = System.today().addDays(2), Expected_Amount_to_Recognize__c = 250,
                                           Negotiated_Amount__c = 350, Secured_Amount__c = 350, GAAP_Amount__c = 0.0, Rev_Rec_Complete__c = true));
        aBCRevenues.add(new ABC_Revenue__c(Contract_ABC__c = contracts[1].Id, Recognition_Start_Date__c = System.today().addDays(-2),
                                           Recognition_End_Date__c = System.today().addDays(2), Expected_Amount_to_Recognize__c = 250,
                                           Negotiated_Amount__c = 0, Secured_Amount__c = 0, GAAP_Amount__c = 0.0));
        
        //Bypass Trigger
        insert aBCRevenues;
        
        //Bypassing triggers
        Util.BypassAllTriggers = false;
        
        //Test stops from here
        Test.startTest(); 
        
        //instance of Scheduler
        Sched_ABCRevenueUpdateForDLRS sh1 = new Sched_ABCRevenueUpdateForDLRS(aBCRevenues);
        
        //Cron expression string
        String sch = '0 0 23 * * ?';
        
        //schedule the scheduler
        system.schedule('Test Schedule', sch, sh1);
        
        //Test stops from here
        Test.stopTest(); 
    }
}