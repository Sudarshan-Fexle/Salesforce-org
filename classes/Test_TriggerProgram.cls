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
@isTest(seeAllData = false)
private class Test_TriggerProgram {
/**
  *   Purpose         :   Test class for Trigger_Program
  *            
  *   Create By       :   
  *
  *   Created Date    :   
  *
  *   Revision Log    :   V_1.0 - Created - 
  *                       V_1.1 - Added - Padmesh Soni - CR-20150729-9114 - 08/04/2015 -  New method createIncentiveChangeLog added.
  *                       V_1.2 - Modified - Rajeev jain - CR-20151120-9402 - 04/19/2016 - Commmented out the myUnitTest2(Which was specific to Program Incentive change log credation unit testing)
  *                       V_1.3 - Modified By - Abhinav Sharma - CR-20150202-8645 - 07/13/2016 - Added new method (testupdateInstitutionFromMembershipRelatedProgramDeletion) + update existing method to refactor code
  *			  V_1.4 - Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
  			  V_1.5 - Modified By - Nikita kumari - 09/28/2021 - CR-20210910-15426 - Added new method testvalidateProgramAcronyms and Applied fiex in remaing methord for Duplicate Program_Acronym__c
  *
  **/

    //Modified by - Abhinav Sharma - CR-20150202-8645 - To refactor the existing code
    //Modified By - Nikita Kumari - CR-20210910-15426 - Add i in Program_Acronym__c
    /** Description : Method to test out various use cases associated with program trigger with respect to product records insert/update.
    **/    
    static testMethod void myUnitTest() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Insert program scenerio
        //Create is list of program to test the bulk scenerio
        List<Program__c> programs = new List<Program__c>();
        
        //create 20 records to test the bulk scenerio
        for(Integer i = 0; i < 20; i++) {
            programs.add(new Program__c(Name = 'testName' + i, Program_Acronym__c = 'testCode' + i, Business_line__c = 'businessLine', Status__c = 'Active'));
        }
        
        //insert data and start test from here
        Test.startTest();
        
        //Enabling triggers
        Util.byPassAllTriggers = false;
        
        //Insert programs
        insert programs;
        
        //Assert for the results
        System.assert(programs != null);
        System.assert(programs.size() > 0);
        
        //initialize a program map
        Map<Id, Program__c> mapPrograms = new Map<Id, Program__c>([SELECT Id, Name, Program_Acronym__c, 
                                                                    Business_line__c, Status__c 
                                                                   FROM Program__c 
                                                                   WHERE Id in : programs]);
       
        //Assert for the results
        System.assert(mapPrograms != null);
        System.assert(mapPrograms.values().size() > 0);
        
        //asserts for trigger results
        List<Product2> products = [SELECT Id, Name, ProductCode, Family, IsActive, Program__c 
                                   FROM Product2 
                                   WHERE Program__c != null AND Program__c in : programs];
        
        //Assert for the results
        System.assert(products != null);
        System.assert(products.size() > 0);
        System.assertEquals(programs.size(), products.size());
        
        //loop through the fetched products list and assert the results
        for(Product2 product : products) {
            
            //Checking for key presence in the map
            if(mapPrograms.containsKey(product.Program__c)) {
                
                //get the Programs record
                Program__c program = mapPrograms.get(product.Program__c);
                
                //assert for the values
                System.assertEquals(program.Name, product.Name);
                System.assertEquals(program.Program_Acronym__c, product.ProductCode);
                //System.assertEquals(program.Business_line__c, product.Family);
                System.assert(product.IsActive);
                
            } else {
                System.assert(false, 'No matching program found related to product :' + product.Name);
            }
        }
        
        //test the Update Case
        for(Program__c program : mapPrograms.values()) {
            
            //Setting program name
            program.Name = 'testUpdate';
            
            // VRH commented out 7/26/12 because of a new validation rule with FFDC
            //program.Program_Acronym__c = 'testUpdateAcrn';
            program.Business_line__c = 'testUpdateBusinessLine';
            program.Status__c = 'InActive';
        
        }
        
		 //Stop test here
        Test.stopTest();
		
		
        //update the records
        update mapPrograms.values();
        
        //Querying for the updated program recordd details
        mapPrograms = new Map<Id, Program__c>([SELECT Id, Name, Program_Acronym__c, Business_line__c, Status__c 
                                               FROM Program__c 
                                               WHERE Id in : mapPrograms.keySet()]);
        
        //Assert for the results
        System.assert(mapPrograms != null);
        System.assert(mapPrograms.values().size() > 0);
        
        //asserts for trigger results
        products = [SELECT Id, Name, ProductCode, Family, IsActive, Program__c 
                    FROM Product2 
                    WHERE Program__c in : mapPrograms.keySet()];
        
        //Assert for the results
        System.assert(products != null);
        System.assert(products.size() > 0);
        System.assertEquals(programs.size(), products.size());
        
        //loop through the fetched products list and assert the results
        for(Product2 product : products) {
            
            //Checking for the presence of the key in the map
            if(mapPrograms.containsKey(product.Program__c)) {
                
                //get the Programs record
                Program__c program = mapPrograms.get(product.Program__c);
                
                //assert for the values
                System.assertEquals(program.Name, product.Name);
                System.assertEquals(program.Program_Acronym__c, product.ProductCode);
                //System.assertEquals(program.Business_line__c, product.Family);
                
                
            } else {
                System.assert(false, 'No matching program found related to product :' + product.Name);
            }
        }
        
        
    }
    
    //Modified by - Abhinav Sharma - CR-20150202-8645 - To refactor the existing code
    //Modified by - Nikita Kumari - CR-20210910-15426 - 09/28/2021
    //Added By - Ajit Surana - CR-20150312-8758 - 03/30/2015
    /** Description : Method to check if a program Industry Member for Meetings value is updated,
     *                then update the all related institutions related to program membership.
    **/
    static testMethod void testUpdateInstitutionFromMembershipRelatedProgram() {
    
        //Bypassing dupeblocker
        Util.IsTest(true);

        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;

        //List to hold Account records
        List<Account> accList = new List<Account>();
        
        accList.add(new Account(Name = 'Test Account1'));
        accList.add(new Account(Name = 'Test Account2'));
        
        //Insert record
        insert accList;
        
        //Assert for the results
        System.assert(accList != null);
        System.assertEquals(2, accList.size());
        
        //Insert Program data
        List<Program__c> progList = new List<Program__c>();
        
        //Adding program instances into the list
        progList.add(new Program__c(Program_Acronym__c = 'TEST1', Program_Formal_Name__c = 'Test Program Formal', 
                     Name = 'Test Program', Create_Memberships__c = 'No', Business_line__c = 'RI',
                     Industry_Member_for_Meetings__c = false, New_Business_Marketer__c = 'RI Marketer'));         
        
        progList.add(new Program__c(Program_Acronym__c = 'TEST2', Program_Formal_Name__c = 'Test Program Formal', 
                     Name = 'Test Program', Create_Memberships__c = 'No', Business_line__c = 'RI', 
                     Industry_Member_for_Meetings__c = false, New_Business_Marketer__c = 'RI Marketer'));
        
        
        //Enabling triggers again
        insert progList;
        
        //Assert for the results
        System.assert(progList != null);
        System.assertEquals(2, progList.size());
        
        // Test Class Fix Start Here 19Feb By: Mahendra Swarnkar - CR-20190904-13309
        //Creating Contact record 
        Contact cont = TestUtilities.CreateNewContact(True);
        
        
        //Opportunity
        //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
        Opportunity opportunity = new Opportunity(Name = 'Test Opp', StageName = Constants.CONTRACT_RECEIVED, Main_Contact__c = cont.Id,
                                                  Amount = 1, CloseDate = System.today(), AccountId = accList[0].ID,Sales_Pursuit_Products__c = 'APS');
        // Test Class Fix End Here 19Feb By: Mahendra Swarnkar - CR-20190904-13309
        
        insert opportunity;
        System.assert(opportunity != null);
        
        //Contract
        Contract__c contract = new Contract__c(Name='Test1', Payer_Account__c = accList[0].ID, Program__c = progList[0].Id, 
                                               Start__c = System.Today().addDays(-10), End__c = System.Today().addDays(355), 
                                               Contract_Renewal_Opportunity__c = opportunity.Id);
        insert contract;
        System.assert(contract != null);
        
        //Update contract record
        contract.Start__c = Date.today() - 7;
        contract.End__c = Date.today() - 7;
        contract.Status__c = Constants.CLOSED;
        update contract;
        System.assert(contract != null);
           
        //List to hold Membership data
        List<Membership__c> membershipList = new List<Membership__c>();
        
        membershipList.add(new Membership__c(Name = 'Membership Test1', Account_Name__c = accList[0].Id, 
                                             Program__c = progList[0].Id, Active_Contract_Idenfied__c = contract.Id,
                                             Earliest_Contract__c = contract.Id,
                                             Latest_Contract__c = contract.Id, Membership_Status_Text__c = 'Member - Pure'));
        membershipList.add(new Membership__c(Name = 'Membership Test2', Account_Name__c = accList[1].Id, 
                                             Program__c = progList[1].Id, Active_Contract_Idenfied__c = contract.Id,
                                             Earliest_Contract__c = contract.Id,
                                             Latest_Contract__c = contract.Id, Membership_Status_Text__c = 'Member - Pure'));
        
        //Enabling triggers
        Util.byPassAllTriggers = false;
        
        //insert record
        insert membershipList;
        
        //Assert for the results
        System.assert(membershipList != null);
        System.assertEquals(2, membershipList.size());
        
        //Start test from here
        Test.startTest();
        
        //Enabling triggers
        Util.byPassAllTriggers = false;
        
        //Updating program instance with update value for Industry_Member_for_Meetings__c field
        progList[0].Industry_Member_for_Meetings__c = true;
        update progList;
        
        //Retrieving updated membership records details from the database.
        //Those are associated with the program records
        membershipList = [SELECT Id /*, Industry_Member__c */ FROM Membership__c WHERE Program__c != null];
        
        //Assert for the results
        System.assert(membershipList != null);
        System.assertEquals(2, membershipList.size());
        //System.assertEquals(true, membershipList[0].Industry_Member__c);
        //System.assertEquals(false, membershipList[1].Industry_Member__c);
        
        //Commented by Mahendra Swarnkar - 02/12/2020 - CR-20190904-13307 - field Industry_Member__c on object Account is deleted
        //Query to fetch Account record data
        /*accList = [SELECT Id, Name, Industry_Member__c 
                   FROM Account ORDER BY Name ASC];*/
        
        //Assert for results
        //System.assert(accList != null);
        //System.assertEquals(3, accList.size());
        
        //Commented by Mahendra Swarnkar - 02/12/2020 - CR-20190904-13307 - field Industry_Member__c on object Account is deleted
        //System.assertEquals(true,accList[0].Industry_Member__c);
        //System.assertEquals(false,accList[1].Industry_Member__c);
        
        //Test will stop here
        Test.stopTest();
    }
    
    //Modified by - Abhinav Sharma - CR-20150202-8645 - To refactor the existing code
    //Modified by - Nikita Kumari - CR-20210910-15426 - 09/28/2021
    //Added by - Subhash Garhwal - 06/26/2015 - CR-20150618-9014
    /** Description : Method to test out "KeyInformationChangedNotification" method relatedfunctionality.
    **/
    static testMethod void myUnitTest1() {
        
        //Bypassing dupeblocker
        Util.IsTest(true);

        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Create an institution
        Account account = TestUtilities.CreateNewAccount(false);
        
        //Insert
        insert account;
        System.assert(account != null);
        
        //Create a Contact
        List<Contact> contacts = new List<Contact>();
        Contact contact_1 = new Contact(FirstName = 'Test', LastName = 'Contact', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855', 
                                        AccountId = account.Id, Employee_User_Record__c = Userinfo.getUserId());
        Contact contact_2 = new Contact(FirstName = 'Test', LastName = 'Contact', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855', 
                                        AccountId = account.Id, Employee_User_Record__c = Userinfo.getUserId());
        
        //Populating list for the instances
        contacts.add(contact_1);
        contacts.add(contact_2);
        
        //Insert contacts
        insert contacts;
        System.assert(contacts != null);
        System.assertEquals(2, contacts.size());
        
        //List of Program
        List<Program__c> programs = new List<Program__c>();
        
        //Add new Programs in list
        programs.add(new Program__c(Name = 'Test Program 1', Status__c = 'Active',Program_Acronym__c = 'TEST1'));
        programs.add(new Program__c(Name = 'Test Program 2', Status__c = 'Active',Program_Acronym__c = 'TEST2'));
        programs.add(new Program__c(Name = 'Test Program 3', Status__c = 'Active',Program_Acronym__c = 'TEST3'));
        
        //Insert
        insert programs;
        
        //Assert for the results
        System.assert(programs != null);
        System.assertEquals(3, programs.size());
        
        //List of Program Groups
        List<Program_Group__c> programGroups = new List<Program_Group__c>();
        
        //Add new Program Groups in list
        programGroups.add(new Program_Group__c(Name = 'Test PG 1', Effective_Start__c = System.today().addDays(-3), Effective_End__c = System.today(),
                                               Business_Owner__c = contacts[0].Id, Short_Name__c = 'test1211', Active__c = true));
        
        programGroups.add(new Program_Group__c(Name = 'Test PG 2', Effective_Start__c = System.today().addDays(-5), Effective_End__c = System.today(),
                                               Business_Owner__c = contacts[0].Id, Short_Name__c = 'test121121', Active__c = true));
        
        programGroups.add(new Program_Group__c(Name = 'Test PG 3', Effective_Start__c = System.today().addDays(-2), Effective_End__c = System.today(),
                                               Business_Owner__c = contacts[0].Id, Short_Name__c = 'test121112', Active__c = true));
        
        //Insert
        insert programGroups;
        
        //Assert
        System.assert(programGroups != null);
        System.assert(programGroups.size() > 0);
        
        //List of Perspective
        List<Perspective__c> perspectives = new List<Perspective__c>();
        
        //Add new Perspective record in list
        perspectives.add(new Perspective__c(Name = 'Per1', Business_Owner__c = contacts[1].Id, Short_Name__c = '1232Test230', Active__c = true));
        perspectives.add(new Perspective__c(Name = 'Per2', Business_Owner__c = contacts[1].Id, Short_Name__c = '1332Test230', Active__c = true));
        perspectives.add(new Perspective__c(Name = 'Per3', Business_Owner__c = contacts[1].Id, Short_Name__c = '1222Test230', Active__c = true));
        
        //Insert
        insert perspectives;
        
        //Assert
        System.assert(perspectives != null);
        System.assert(perspectives.size() > 0);
        
        //List of Program Perspective
        List<Program_Perspective__c> programPerspectives = new List<Program_Perspective__c>();
        
        //Add new Program Perspective in list
        programPerspectives.add(new Program_Perspective__c(Name = 'CP1', Program_Group__c = programGroups[0].Id, Perspective__c = perspectives[0].Id,
                                                           Business_Owner__c = contacts[1].Id, Effective_Start__c = System.today(), Effective_End__c = System.today().addDays(4), Active__c = true));
        
        programPerspectives.add(new Program_Perspective__c(Name = 'CP2', Program_Group__c = programGroups[1].Id, Perspective__c = perspectives[1].Id,
                                                           Business_Owner__c = contacts[1].Id, Effective_Start__c = System.today(), Effective_End__c = System.today().addDays(4), Active__c = true));
        
        programPerspectives.add(new Program_Perspective__c(Name = 'CP3', Program_Group__c = programGroups[2].Id, Perspective__c = perspectives[2].Id,
                                                           Business_Owner__c = contacts[1].Id, Effective_Start__c = System.today(), Effective_End__c = System.today().addDays(4), Active__c = true));
                                                           
        programPerspectives.add(new Program_Perspective__c(Name = 'CP4', Program_Group__c = programGroups[0].Id, Perspective__c = perspectives[1].Id,
                                                           Business_Owner__c = contacts[1].Id, Effective_Start__c = System.today(), Effective_End__c = System.today().addDays(4), Active__c = true));
        
        //Insert
        insert programPerspectives;
        
        //Assert
        System.assert(programPerspectives != null);
        System.assert(programPerspectives.size() > 0);
        
        //List of Program Relationship
        List<Program_Relationship__c> programRelationships = new List<Program_Relationship__c>();
        
        //Add new Program Relationship in list
        programRelationships.add(new Program_Relationship__c(Name = 'CPC1', Program_Perspective__c = programPerspectives[0].Id, 
                                                             Program__c = programs[0].Id, Business_Owner__c = contacts[1].Id, 
                                                             Effective_Start__c = System.today().addDays(1), 
                                                             Effective_End__c = System.today().addDays(2)));
        
        //Insert
        insert programRelationships;
        
        //Assert
        System.assert(programRelationships != null);
        System.assert(programRelationships.size() > 0);
        
        //Start testing from here
        Test.startTest();
        
        //Enabling triggers
        Util.byPassAllTriggers = false;
        
        //Assert for result
        System.assertEquals(0, Limits.getEmailInvocations());
        
        //Update programs
        programs[2].Effective_Start__c = System.today();
        programs[2].Effective_End__c = System.today().addDays(5);
        programs[2].Business_line__c = 'PT';
        
        //Update programs
        update programs;
        
        //Assert for result
        System.assertEquals(0, Limits.getEmailInvocations());
        
        //Update programs
        programs[0].Effective_Start__c = System.today();
        programs[0].Effective_End__c = System.today().addDays(5);
        programs[1].Business_line__c = 'PT';
        
        //Enabling triggers
        Util.BypassAllTriggers = false;
        
        //Update
        programs[0].Program_Abbreviation__c = 'Abb 1 change';
        programs[0].Name = 'Test Program 1 update';
        programs[0].Status__c = 'Inactive';
        programs[1].Program_Abbreviation__c = 'Abb 2 change';
        programs[1].Program_Abbreviation__c = 'Abb 3 change';
        update programs;
        
        //Stop testing here
        Test.stopTest();
    }
    
    //Modified by - Abhinav Sharma - CR-20150202-8645 - To refactor the existing code
    /** Description : Method to test out the functionality for updating the instituton records from membership that is related
     *                  to a program on program record deletion.
    **/
    static testMethod void testupdateInstitutionFromMembershipRelatedProgramDeletion(){
        
        //Bypassing dupeblocker
        Util.IsTest(true);

        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Commented by Mahendra Swarnkar - 02/12/2020 - CR-20190904-13307 - field Industry_Member__c on object Account is deleted
        //Create an institution
        List<Account> accounts = new List<Account>();
        accounts.add(new Account(Name = 'acc 1'/*, Industry_Member__c = true*/));
        accounts.add(new Account(Name = 'acc 2'/*, Industry_Member__c = true*/));
        accounts.add(new Account(Name = 'acc 3'/*, Industry_Member__c = true*/));
        accounts.add(new Account(Name = 'acc 4'/*, Industry_Member__c = true*/));
        
        //Insert
        insert accounts;
        
        //Assert for result
        System.assert(accounts.size() > 0);
        
        //Create a Contact
        Contact contact = new Contact(FirstName = 'Test', LastName = 'Contact', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855', 
                                      AccountId = accounts[0].Id,
                                      Employee_User_Record__c = Userinfo.getUserId());
        
        //Insert
        insert contact;  
        
        //List of Program
        List<Program__c> programs = new List<Program__c>();
        
        //Add new Programs in list
        programs.add(new Program__c(Name = 'Test Program 1', Status__c = 'Active'));
        programs.add(new Program__c(Name = 'Test Program 2', Status__c = 'Active'));
        programs.add(new Program__c(Name = 'Test Program 3', Status__c = 'Active'));
        programs.add(new Program__c(Name = 'Test Program 4', Status__c = 'Active', Business_line__c = 'Hello', Program_Line__c = 'Royall'));
        
        //Insert
        insert programs;
        
        //Assert
        System.assert(programs != null);
        System.assert(programs.size() > 0);
        
        //List to hold Membership data
        List<Membership__c> membershipList = new List<Membership__c>();
        
        membershipList.add(new Membership__c(Name = 'Membership Test1', Account_Name__c = accounts[0].Id, 
                                             Program__c = programs[0].Id,Membership_Status_Text__c = 'Member - Pure'));
        membershipList.add(new Membership__c(Name = 'Membership Test1', Account_Name__c = accounts[1].Id, 
                                             Program__c = programs[1].Id,Membership_Status_Text__c = 'Member - Pure'));
        membershipList.add(new Membership__c(Name = 'Membership Test1', Account_Name__c = accounts[2].Id, 
                                             Program__c = programs[2].Id,Membership_Status_Text__c = 'Member - Pure'));
        membershipList.add(new Membership__c(Name = 'Membership Test1', Account_Name__c = accounts[3].Id, 
                                             Program__c = programs[2].Id,Membership_Status_Text__c = 'Member - Pure'));
        
        //Insert Mwmbership records
        insert membershipList;
        
        //Assert
        System.assert(membershipList != null);
        System.assert(membershipList.size() > 0);
        
        //Test Start method here
        Test.startTest();
        
        //Enabling triggers
        Util.byPassAllTriggers = false;
        
        try {
        	
             //Delete program
        	delete programs;
        
        }catch(exception e) {
            
        }
       
        //Query over Account
        List<Account> accList = [SELECT Id, Name/*, Industry_Member__c */
                                 FROM Account ORDER BY Name ASC];
        
        //Assert for result
        System.assert(accList != null);
        System.assert(accList.size() > 0);
       /* System.assertEquals(false, accList[0].Industry_Member__c);
        System.assertEquals(false, accList[1].Industry_Member__c);
        System.assertEquals(false, accList[2].Industry_Member__c); */
                
        //Test Stop method here
        Test.stopTest();
        
    }
    
    @isTest static void testCheckException() {
        Util.ByPassAllTriggers = false;
        
        //List to hold the Programs
        List<Program__c> progList = new List<Program__c>(); 
        
        progList.add(new Program__c(Program_Acronym__c = 'TEST1', Program_Formal_Name__c = 'Test Program Formal', 
                     Name = 'Test Program', Create_Memberships__c = 'No', 
                     Industry_Member_for_Meetings__c = false, New_Business_Marketer__c = 'RI Marketer', Program_Line__c = 'Royall', Business_line__c = 'Hello'));
        
        ProgramTriggerHelper.CHECK_TRIGGER_EXCEPTION = true;
        try {
            insert progList;
        }
        catch(Exception e){
            
        }
        
    }


    /** Added by - Nikita kumari - 09/28/2021 - CR-20210910-15426
     * Description : Method to test out the functionality for validating the ProgramAcronyms of new program.
    **/
    static testMethod void testvalidateProgramAcronyms(){
        
        
        //Create is list of program to test the bulk scenerio
        List<Program__c> programs = new List<Program__c>();
        
        Test.startTest();
        
        //create 20 records to test the bulk scenerio
        for(Integer i = 0; i < 4; i++) {
            programs.add(new Program__c(Name = 'testPROGRAMACRONYM' + i, Program_Acronym__c = 'PROGRAMACRONYM' + i, Business_line__c = 'RI', Status__c = 'Active'));
        }
        
        programs[0].Program_Acronym__c = null;
        
        //insert data
        insert programs;
        
        List<Program__c> prgms = new List<Program__c>();
        prgms.add(new Program__c(Name = 'testName', Program_Acronym__c = 'testCode1', Business_line__c = 'RI', Status__c = 'Active'));
        prgms.add(new Program__c(Name = 'testName', Program_Acronym__c = 'PROGRAMACRONYM1', Business_line__c = 'RI', Status__c = 'Active'));
        
        try {
            Insert prgms;
        
        } catch(Exception e) {
            
            String Recordlink = URL.getSalesforceBaseUrl().toExternalForm()+'/'+ programs[1].Id;
            String errormsg = System.Label.ERROR_PROGRAM_DUPLICATE_PROGRAM_ACRONYM_WITH_RECORDLINK + Recordlink; 
            
            //Assert failed in case of exception
            System.assertEquals(e.getMessage().contains(errormsg), true,e.getMessage());
        }
        
        Program__c program = new Program__c(Name = 'testPROGRAMACRONYM', Business_line__c = 'PT', Status__c = 'Active');
        
        insert program;
        
        List<Program__c> programList = [Select Id,Program_Acronym__c,Business_line__c From Program__c Where Program_Acronym__c = null];
        System.assertEquals(2, programList.size());
        
        List<Program__c> progrmList = new List<Program__c>();
        progrmList.add(new Program__c(Name = 'testPROGRAMACRONYM', Program_Acronym__c = 'PROGRAMACRONYM', Business_line__c = 'RI', Status__c = 'Active'));
        progrmList.add(new Program__c(Name = 'testPROGRAMACRONYM1', Program_Acronym__c = 'PROGRAMACRONYM', Business_line__c = 'RI', Status__c = 'Active'));
      
        try {
            Insert progrmList;
        
        } catch(Exception e) {
            
            String errormsg = System.Label.ERROR_PROGRAM_DUPLICATE_PROGRAM_ACRONYM; 
            
            //Assert failed in case of exception
            System.assertEquals(e.getMessage().contains(errormsg), true);
            
        }
	
        //Stop Test here
        Test.stopTest();
    }
}