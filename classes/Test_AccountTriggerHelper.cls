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
private class Test_AccountTriggerHelper {
/*
 *  Purpose         :   This class is helper class for trigger on Membership object.
 *
 *  Create By       :   
 *
 *  Created Date    :   10/2/2012
 *
 *  Revision Log    :   V_1.0 Created
 *                      V_1.1 Modified By - Abhinav Sharma - 06/30/2016 - CR-20160419-9779 - Updated the existing method - testPopulateRegion
                        V_1.2 Modified By - Rajeev Jain - SFDC Royall Migration Release - 06/28/2016 - Manual merge of the shift_update_acc_years_status_test test class.
                            - Following method manually merged and improved asserts for it. test1, test2, test3, test1_hd, test2_hd, test3_hd
                        V_1.3 Modified By - Mahendra Swarnkar - CR-20160802-10078 - 09/10/2016 - Added a test method "test_PopulateSolutionFlagFieldOnAccount" for "populateSolutionFlagFieldOnAccount"
                        V_1.4 Modified By - Mahendra Swarnkar - CR-20161102-10332 - 1/2/2017
                        V_1.5 Modified By - Mahendra Swarnkar - Updated as per the run all Test.
                        V_1.6 Modified By - Mahendra Swarnkar - 3/25/2017 - as per the Run All Test
                        V_1.7 Modified By - Abhinav Sharma - CR-20170222-10716 - 4/24/2017 - Add a new method for testSyncUpChildrenCasesFieldsFuntionality
                        V_1.8 Modified by - 05/08/2017 - Mahendra Swarnkar - CR-20170221-10707 -Added new method testPopulateAssociatePrincipalOnopportunity
                        V_1.9 Modified by - 08/04/2017 - Subhash Garhwal - CR-20170803-11120 -Added new method testUpdateRelationshipIntractionFields
                        V_2.0 Modified By - 08/31/2017 - Dipesh Gupta - CR-20170426-10878 - Check the functionality of method populateProjectFieldsFromAccount of AccountTriggerHelper Created a new Test Method 
 			testProjectFieldPopulationOfAccount.
		        V_2.1 Modified By Dipesh Gupta 09/07/2017 - CR-20170221-10712, Added a new Method populateRoyalProgramJobNoFieldByAccount to test the functionality to populate royall program job no field.
                        V_2.2 Modified by Abhinav Sharma- 08/11/2020 - CR-20180808-12492 -- Commented Solution_Adopted__c,Solution_Status__c
 			V_2.3 - Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
*
**/    
    
    //Modified By - Abhinav Sharma - 06/30/2016 - CR-20160419-9779 
    //Modified By - Ajit Surana - CR-20141216-8346 - 02/03/2015
    //Verify that the Region is updated properly when the Primary Country on the Institution is updated
    static testmethod void testPopulateRegion() {
        
        //Start test from here
        Test.startTest();
        
        // create an institution
        Account acct = TestUtilities.CreateNewAccount(false);
        acct.Primary_Country__c = 'Bulgaria';
        insert acct;
        
        // get the account
        acct = [SELECT Id, Region__c FROM Account WHERE Id = :acct.Id];
        
        // verify the region has chnaged accordingly
        system.assertEquals('Europe', acct.Region__c);
        
        acct.Primary_Country__c = 'Honduras';
        update acct;
        
        // get the account
        acct = [SELECT Id, Region__c FROM Account WHERE Id = :acct.Id];
        
        // verify the region has chnaged accordingly
        system.assertEquals('Latin America', acct.Region__c);
        
        //Setting primary country as russia
        acct.Primary_Country__c = 'Russia';
        update acct;
        
        // get the account
        acct = [SELECT Id, Region__c FROM Account WHERE Id = :acct.Id];
        
        // verify the region has chnaged accordingly
        system.assertEquals('Australasia', acct.Region__c);
        
        //update primary country to have null as value
        acct.Primary_Country__c = null;
        update acct;
        
        // get the account
        acct = [SELECT Id, Region__c FROM Account WHERE Id = :acct.Id];
        
        // verify the region has chnaged accordingly
        system.assertEquals(null, acct.Region__c);
        
        //Setting primary country as USA
        acct.Primary_Country__c = 'USA';
        update acct;
        
        // get the account
        acct = [SELECT Id, Region__c FROM Account WHERE Id = :acct.Id];
        
        // verify the region has chnaged accordingly
        system.assertEquals('USA', acct.Region__c);
        
        //Added by Ajit Surana - CR-20141216-8346 - 02/03/2015
        //Update Account "Primary Country's field value to United Kingdom
        acct.Primary_Country__c = 'United Kingdom';
        update acct;
        
        //Query to get the results
        acct = [SELECT Id, Region__c FROM Account WHERE Id = :acct.Id];
        
        //Assert for results
        system.assertEquals('UK', acct.Region__c);
        
        //Stop test here
        Test.stopTest();
        
        //Update Account "Primary Country's field value to Ireland
        acct.Primary_Country__c = 'Ireland';
        update acct;
        
        //Query to get the results
        acct = [SELECT Id, Region__c FROM Account WHERE Id = :acct.Id];
        
        //Assert for results
        system.assertEquals('Europe', acct.Region__c);
        
        //Update Account "Primary Country's field value to Spain
        acct.Primary_Country__c = 'Spain';
        update acct;
        
        //Query to get the results
        acct = [SELECT Id, Region__c FROM Account WHERE Id = :acct.Id];
        
        //Assert for results
        system.assertEquals('Latin America', acct.Region__c);
        
        //Update Account "Primary Country's field value to PortugalUn
        acct.Primary_Country__c = 'Portugal';
        update acct;
        
        //Query to get the results
        acct = [SELECT Id, Region__c FROM Account WHERE Id = :acct.Id];
        
        //Assert for results
        system.assertEquals('Latin America', acct.Region__c);
    }
    
    //This method test the populateTopParentInstitute method
    static testmethod void testPopulateTopParentInstitute() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Create test data
        Account parentAccountLevel1 = new Account(Name = 'Test-Parent');
        insert parentAccountLevel1;
        
        //Create test data
        Account parentAccountLevel2 = new Account(Name = 'Test-Parent', ParentId = parentAccountLevel1.Id);
        insert parentAccountLevel2;
        
        //Create test data
        Account parentAccountLevel3 = new Account(Name = 'Test-Parent', ParentId = parentAccountLevel2.Id);
        insert parentAccountLevel3;
        
        //Create test data
        Account parentAccountLevel4 = new Account(Name = 'Test-Parent', ParentId = parentAccountLevel3.Id);
        insert parentAccountLevel4;
        
        //Create account data
        List<Account> accountsToCommit = new List<Account>();
        
        //Create test data 
        for(Integer i = 0; i < 5; i++) {
            
            //Add data
            accountsToCommit.add(new Account(Name = 'TestLevel-1', ParentId = parentAccountLevel1.Id));
            accountsToCommit.add(new Account(Name = 'TestLevel-2', ParentId = parentAccountLevel2.Id));
            accountsToCommit.add(new Account(Name = 'TestLevel-3', ParentId = parentAccountLevel3.Id));
            accountsToCommit.add(new Account(Name = 'TestLevel-4', ParentId = parentAccountLevel4.Id));
        }
        
        //Start test from here
        Test.startTest();
        
        //insert data in bulk
        insert accountsToCommit;
        
        //Assert for the results
        accountsToCommit = [Select Id, Top_Parent_Institution__c from Account where ID IN: accountsToCommit AND Top_Parent_Institution__c =: parentAccountLevel1.Id];
        
        System.assertEquals(20, accountsToCommit.size());   
        
        //Update parent Id with blank
        for(Account acc : accountsToCommit) {
            
            //Update parent with Null
            acc.ParentId = null;
        }
        
        //Update accounts
        update accountsToCommit;
        
        //Assert for the results
        accountsToCommit = [Select Id, Top_Parent_Institution__c from Account where ID IN: accountsToCommit AND Top_Parent_Institution__c =: parentAccountLevel1.Id];
        
        System.assertEquals(0, accountsToCommit.size());    
        
        //stop test here
        Test.stopTest();
    }
    
     //This method test the populateTopParentInstitute method
    static testmethod void testPopulateTopParentInstituteForUpdate() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
		
		//BYpassing trigger. 
		Util.BypassAllTriggers = true; 
        
        //Create test data
        Account parentAccountLevel1 = new Account(Name = 'Test-Parent');
        insert parentAccountLevel1;
        
        //Create test data
        Account parentAccountLevel2 = new Account(Name = 'Test-Parent', ParentId = parentAccountLevel1.Id);
        insert parentAccountLevel2;
        
        //Create test data
        Account parentAccountLevel3 = new Account(Name = 'Test-Parent', ParentId = parentAccountLevel2.Id);
        insert parentAccountLevel3;
        
        //Create test data
        Account parentAccountLevel4 = new Account(Name = 'Test-Parent', ParentId = parentAccountLevel3.Id);
        insert parentAccountLevel4;
        
		//BYpassing trigger. 
		Util.BypassAllTriggers = false; 
        
		
        //Create account data
        List<Account> accountsToCommit = new List<Account>();
        
        //Create test data 
        for(Integer i = 0; i < 5; i++) {
            
            //Add data
            accountsToCommit.add(new Account(Name = 'TestLevel-1'));
            accountsToCommit.add(new Account(Name = 'TestLevel-2'));
            accountsToCommit.add(new Account(Name = 'TestLevel-3'));
            accountsToCommit.add(new Account(Name = 'TestLevel-4'));
        }
        
        //insert data in bulk
        insert accountsToCommit;
        
        //Update parent Id with blank
        for(Account acc : accountsToCommit) {
            
            //Update parent with Null
            acc.ParentId = parentAccountLevel4.Id;
        }
        
        //Start test from here
        Test.startTest();
        
        //Update accounts
        update accountsToCommit;
        
        //Assert for the results
        accountsToCommit = [Select Id, Top_Parent_Institution__c from Account where ID IN: accountsToCommit AND Top_Parent_Institution__c =: parentAccountLevel1.Id];
        
       
        
        //stop test here
        Test.stopTest();
    }
    
    //Test Method to test if on deletion of Account all associated children Restriction MtM records will be deleted or not.
    static testmethod void testDeleteAllRestrcitionMtmFuntionality() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //List to hold the account records
        List<Account> accounts = new List<Account>();
        
        //Create test data 
        for(Integer i = 0; i < 2; i++) {
            accounts.add(new Account(Name = 'TestLevel ' + i));
        }
        
        //Bypassing all the triggers
        Util.BypassAllTriggers = true;
        
        //Insert accounts
        insert accounts;
        
        //Assert for results
        System.assertEquals(2, accounts.size());
        
        //Restriction
        Restrictions__c restrict = new Restrictions__c();
        restrict.Category__c = 'Critical Background Information';
        restrict.Expiration_Date__c = system.today().addDays(10);
        
        //Bypassing all the triggers
        Util.BypassAllTriggers = true;
        
        insert restrict;
        
        //List Restriction Mtms
        List<Restricted_MtM__c> restrictionMtMs = new List<Restricted_MtM__c>();
        
        Restricted_MtM__c rest_1 = new Restricted_MtM__c(Account__c = accounts[0].Id, Restriction__c = restrict.Id);
        Restricted_MtM__c rest_2 = new Restricted_MtM__c(Account__c = accounts[0].Id, Restriction__c = restrict.Id);
        Restricted_MtM__c rest_3 = new Restricted_MtM__c(Account__c = accounts[1].Id, Restriction__c = restrict.Id);
        Restricted_MtM__c rest_4 = new Restricted_MtM__c(Account__c = accounts[1].Id, Restriction__c = restrict.Id);
        
        //Populating list with the records
        restrictionMtMs.add(rest_1);
        restrictionMtMs.add(rest_2);
        restrictionMtMs.add(rest_3);
        restrictionMtMs.add(rest_4);
        
        //Bypassing all the triggers
        Util.BypassAllTriggers = true;
        
        //Insert restriction
        insert restrictionMtMs;
        
        //Assert for the results
        System.assertEquals(4, restrictionMtMs.size());
        restrictionMtMs = [SELECT ID FROM Restricted_MtM__c WHERE Account__c =: accounts[0].Id];
        System.assertEquals(2, restrictionMtMs.size());
        restrictionMtMs = [SELECT ID FROM Restricted_MtM__c WHERE Account__c =: accounts[1].Id];
        System.assertEquals(2, restrictionMtMs.size());
        
        //Test start From here
        Test.startTest();
        
        //Util.BypassAllTriggers = false;
        
        //Delete Accounts
        //delete accounts;
        
        //Bypassing all the triggers
        //Util.BypassAllTriggers = true;
        
        //Assert for results
        restrictionMtMs = [Select ID FROM Restricted_MtM__c];
        accounts = [Select ID FROM Account];
        System.assertEquals(4, restrictionMtMs.size());
        System.assertEquals(2, accounts.size());
        
        //Stop Test Here
        Test.stopTest();
    }
    
    //Added By - Abhinav Sharma - 07/03/2014 - CR-20140618-5845
    //Test Method to test if on updation of Account all associated children Case records will be updated with "Member Type" field value or not
    static testmethod void testUpdateAllCasesMemberTypeFuntionality() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing all triggers
        Util.BypassAllTriggers = true;
        
        //Querying Details for "Member & Employee Support" record type on Case Object
        List<RecordType> rdType = [SELECT ID FROM RecordType Where sObjectType = 'Case' AND IsActive = true 
                                                AND DeveloperName = 'Member_Employee_Support'];
        
        //List to hold the Account records
        List<Account> accounts = new List<Account>();
        
        //Institutions
        Account acct_1 = TestUtilities.CreateNewAccount(false);
        Account acct_2 = TestUtilities.CreateNewAccount(false);
        Account acct_3 = TestUtilities.CreateNewAccount(false);
        
        //Populating list with account records
        accounts.add(acct_1); accounts.add(acct_2); accounts.add(acct_3);
        
        //Insert accounts
        insert accounts;
        
        //Assert for the results
        System.assertEquals(3, accounts.size());
        
        //Bypassing all triggers
        Util.BypassAllTriggers = true;
        
        //List to hold the case records
        List<Case> cases = new List<Case>();
                                
        //Case
        Case aCase_1 = new Case(RecordTypeId = rdType[0].Id, Origin = 'Email', Subject = 'Test 1', 
                                Description = 'test 1', AccountId = accounts[0].Id);
                                
        //Case
        Case aCase_2 = new Case(RecordTypeId = rdType[0].Id, Origin = 'Phone', Subject = 'Test 2', 
                                Description = 'test 2', AccountId = accounts[1].Id);
                                
        //Case
        Case aCase_3 = new Case(RecordTypeId = rdType[0].Id, Origin = 'Web', Subject = 'Test 3', 
                                Description = 'test 3', AccountId = accounts[2].Id);
                                
        //Case
        Case aCase_4 = new Case(RecordTypeId = rdType[0].Id, Origin = 'Phone', Subject = 'Test 4', 
                                Description = 'test 4', AccountId = accounts[1].Id);
                    
        //Populating list with records instances
        cases.add(aCase_1); cases.add(aCase_2); cases.add(aCase_3); cases.add(aCase_4);
        
        //Insert Case
        insert cases;
        
        //Assert for the results
        System.assertEquals(4, cases.size());

        //Start Test from here
        Test.startTest();
        
        //Enabling all triggers
        Util.BypassAllTriggers = false;
        
        //Updating list of accounts
        accounts[0].Description = 'Testing RIAMLargeContract Testing';
        accounts[1].Description = 'RIAMLargeContract';
        accounts[2].Description = 'Testing RIAM';
        update accounts;
        
        System.assertEquals(3, accounts.size());
        
        //Set to hold the Account Ids
        Set<Id> setAccounts = new Set<Id>();
        
        //Loop through list of accounts
        for(Account acc : accounts) {
            setAccounts.add(acc.Id);            
        }
        
        //Asserting for results
        cases = [SELECT Id, Subject, Member_Type__c FROM Case WHERE AccountId IN : setAccounts ORDER BY Subject ASC];
        System.assertEquals(4, cases.size());  
        System.assertEquals('RIAMLargeContract', cases[0].Member_Type__c);
        System.assertEquals('RIAMLargeContract', cases[1].Member_Type__c);
        System.assertEquals(null, cases[2].Member_Type__c);
        System.assertEquals('RIAMLargeContract', cases[3].Member_Type__c);
        
        //Enabling all triggers
        Util.BypassAllTriggers = false;
        
        //Updating the existing case records
        cases[3].AccountId = null;
        cases[2].AccountId = accounts[1].Id;
        cases[1].AccountId = accounts[2].Id;
        
        //Update case records
        update cases;
        
        //Asserting for results
        cases = [SELECT Id, Subject, Member_Type__c FROM Case ORDER BY Subject ASC LIMIT 5];
        System.assertEquals(4, cases.size());  
        System.assertEquals('RIAMLargeContract', cases[0].Member_Type__c);
        System.assertEquals(null, cases[1].Member_Type__c);
        System.assertEquals('RIAMLargeContract', cases[2].Member_Type__c);
        System.assertEquals(null, cases[3].Member_Type__c);
    
        //Disable triggers execution for avoiding the limits errors
        Util.byPassAllTriggers = true;
    }
    
    //V1.6 - Modified By - Mahendra Swarnkar - 3/25/2017 - as per the Run all test.
    // test for one Account with 2 concurrent active years
    static testMethod void test1() {
        
        //Bypass all the triggers
        Util.BypassAllTriggers = true;
        
        //Set the custom setting data
        Account_Status_Management__c cs = new Account_Status_Management__c(Enable_Update_Account_Status_Trigger__c=true);
        insert cs;
        
        //Get the current fiscal year
        integer currentFY = shift_get_fiscal_year.current();   
        
        //Create Account associated to Opportnity with a Contact set to primary in the Contact Role
        Account acc1 = new Account ( Name = 'Shift CRM'  );
        insert acc1;
        
        //Get the Royall record type of Program Package 
        List<RecordType> ppRoyallRecordType = [Select Id From RecordType 
                                                Where sObjectType =: 'Program_Package__c' AND DeveloperName =: Label.PROGRAM_PACKAGE_RECORD_TYPE_DEVELOPER_NAME_ROYALL]; 
        
        //List to old the Program package records 
        List<Program_Package__c> listRoyallPPs = new List<Program_Package__c>();
        
        //Populate the list
        listRoyallPPs.add( new Program_Package__c ( Account__c = acc1.id, Name = 'ShiftTest1', Client_Status_New__c = 'In Play', 
                                                    Fiscal_Year__c = string.ValueOf(currentFY - 1) ,
                                                    RecordTypeId = ppRoyallRecordType[0].Id ));

        listRoyallPPs.add( new Program_Package__c ( Account__c = acc1.id, Name = 'ShiftTest2', Client_Status_New__c = 'Secured',
                                                    Fiscal_Year__c = string.ValueOf(currentFY), 
                                                    RecordTypeId = ppRoyallRecordType[0].Id ));
        
        listRoyallPPs.add( new Program_Package__c ( Account__c = acc1.id, Name = 'ShiftTest3', Client_Status_New__c = 'Secured',
                                                    Fiscal_Year__c = string.ValueOf(currentFY + 1), 
                                                    RecordTypeId = ppRoyallRecordType[0].Id ));
        
        //Test Starts form here
        Test.startTest();
        
        //Bypass all the triggers
        Util.BypassAllTriggers = false;
        
        //Insert the PP records
        insert listRoyallPPs;
        
        //test stops here
        Test.stopTest();
        
        //Query the Account records 
        Account result =  [SELECT Name, r_Current_Year_Status__c, r_Next_Year_Status__c, r_Previous_Year_Status__c 
                            FROM Account WHERE Id =: acc1.id ];
                            
        //Asserts on results
        //System.assertEquals( 2, result.Concurrent_Active_Years__c, 'Error in concurrent years' ); 
        System.assertEquals( 'Secured', result.r_Current_Year_Status__c , 'Error in Current year status' ); 
        System.assertEquals( 'Secured', result.r_Next_Year_Status__c, 'Error in Next year status' );    
        System.assertEquals( 'In Play', result.r_Previous_Year_Status__c , 'Error in Previous year status' );
    }
    
    //Test where an account has concurrent years set to 0 after deletion of prog. packages
    static testMethod void test2() {
        Test.startTest();
        
        Account_Status_Management__c cs = new Account_Status_Management__c(Enable_Update_Account_Status_Trigger__c=true);
        insert cs;
        
        integer currentFY = shift_get_fiscal_year.current(); 
    
        //Create Account associated to Opportnity with a Contact set to primary in the Contact Role
        Util.BypassAllTriggers = true;
         
        Account acc1 = new Account ( Name = 'Shift CRM'  );
        insert acc1;
        
        Util.BypassAllTriggers = false;
        
        List<Program_Package__c> ppList = new List<Program_Package__c>();
        Program_Package__c ppk1= new Program_Package__c ( Account__c = acc1.id, Name = 'ShiftTest1',
                                                            Fiscal_Year__c = string.ValueOf(currentFY - 1) ,
                                                                Client_Status_New__c = 'Secured' );
        ppList.add(ppk1);
        
        Program_Package__c ppk2= new Program_Package__c ( Account__c = acc1.id, Name = 'ShiftTest2', 
                                                            Fiscal_Year__c = string.ValueOf(currentFY), 
                                                            Client_Status_New__c = 'Lost', Client_Lost_Date__c = system.today(),
                                                            Reason_for_Loss__c = 'Creative', Lost_To__c = 'In-House'
                                                        );
        ppList.add(ppk2);

        Program_Package__c ppk3= new Program_Package__c ( Account__c = acc1.id, Name = 'ShiftTest3', 
                                                            Fiscal_Year__c = string.ValueOf(currentFY + 1), 
                                                                Client_Status_New__c = 'Secured' );
        ppList.add(ppk3);
        
        Program_Package__c ppk4= new Program_Package__c ( Account__c = acc1.id, Name = 'ShiftTest4', 
                                                            Fiscal_Year__c = string.ValueOf(currentFY + 2 ), 
                                                                Client_Status_New__c = 'Secured' );

        ppList.add(ppk4);        
        Program_Package__c ppk5= new Program_Package__c ( Account__c = acc1.id, Name = 'ShiftTest5', 
                                                            Fiscal_Year__c = string.ValueOf(currentFY + 3 ), 
                                                                Client_Status_New__c = 'Committed' );
        ppList.add(ppk5);
        
        insert ppList;
        delete ppList;
        undelete ppList;        

        Test.StopTest();

        Account result2= [SELECT Name, r_Current_Year_Status__c, r_Next_Year_Status__c, r_Previous_Year_Status__c 
                            FROM Account WHERE Name = 'Shift CRM'];

        //System.assertEquals( 3, result2.Concurrent_Active_Years__c, 'Error in concurrent years' ); 
        System.assertEquals( 'Lost', result2.r_Current_Year_Status__c , 'Error in Current year status' ); 
        System.assertEquals( 'Secured' , result2.r_Next_Year_Status__c, 'Error in Next year status' );    
        System.assertEquals( 'Secured', result2.r_Previous_Year_Status__c , 'Error in Previous year status' ); 
       
    }

    //Test an account which concurrent years is set to 0 because there were no client status defined
    static testMethod void test3() {
        Test.startTest();
        
        Account_Status_Management__c cs = new Account_Status_Management__c(Enable_Update_Account_Status_Trigger__c=true);
        insert cs;

        Util.BypassAllTriggers = true;
        
        //Create Account associated to Opportnity with a Contact set to primary in the Contact Role 
        Account acc1 = new Account ( Name = 'Shift CRM'  );
        insert acc1;
        
        Util.BypassAllTriggers = false;
        
        integer currentFY = shift_get_fiscal_year.current(); 
        
        Program_Package__c ppk1= new Program_Package__c ( Account__c = acc1.id, Name = 'ShiftTest1', 
                                                            Fiscal_Year__c = string.ValueOf(currentFY) );
        insert ppk1;
        System.debug(ppk1);
        Test.stopTest();

        Account result=  [SELECT Name, r_Current_Year_Status__c, 
                            r_Next_Year_Status__c, r_Previous_Year_Status__c 
                                FROM Account WHERE Name = 'Shift CRM'];
                            
        //System.assertEquals( 0, result.Concurrent_Active_Years__c, 'Error in concurrent years' ); 
        System.assertEquals( null, result.r_Current_Year_Status__c , 'Error in Current year status' ); 
        System.assertEquals( null, result.r_Next_Year_Status__c, 'Error in Next year status');    
        System.assertEquals( null, result.r_Previous_Year_Status__c , 'Error in Previous year status' );     
    } 
    // test for one Account with 2 concurrent active years
    // Modified By - Seemu Saikia -CR-20190501-13072- 05/07/2019 - #Spring CleanUp

    static testMethod void test1_hd() {
        Test.startTest();
        
        Account_Status_Management__c cs = new Account_Status_Management__c(Enable_Update_Account_Status_Trigger__c=true);
        insert cs;

        integer currentFY = shift_get_fiscal_year.current();   
        
        //Create Account associated to Opportnity with a Contact set to primary in the Contact Role
        Util.BypassAllTriggers = true;
         
        Account acc1 = new Account ( Name = 'Shift CRM'  );
        insert acc1;
        
        Util.BypassAllTriggers = false;

        Test.stopTest();
        
        Account result =  [SELECT Name, r_HD_Current_Year_Engagement_Status__c, 
                            r_HD_Next_Year_Engagement_Status__c, r_HD_Previous_Year_Engagement_Status__c 
                                FROM Account WHERE Id =: acc1.id ];
                            
        //System.assertEquals( 2, result.Concurrent_Active_Years_HD__c, 'Error in concurrent years' ); 
        //System.assertEquals( 'Secured', result.r_HD_Current_Year_Engagement_Status__c , 'Error in Current year status' ); 
        //System.assertEquals( 'Secured', result.r_HD_Next_Year_Engagement_Status__c, 'Error in Next year status' );    
        //System.assertEquals( 'In Play', result.r_HD_Previous_Year_Engagement_Status__c , 'Error in Previous year status' );

    }
    
    //Test where an account has concurrent years set to 0 after deletion of prog. packages
    //Modified By - Seemu Saikia -CR-20190501-13072- 05/07/2019 - #Spring CleanUp

    static testMethod void test2_hd() {
        Test.startTest();
        
        Account_Status_Management__c cs = new Account_Status_Management__c(Enable_Update_Account_Status_Trigger__c=true);
        insert cs;

        integer currentFY = shift_get_fiscal_year.current(); 
    
        //Create Account associated to Opportnity with a Contact set to primary in the Contact Role
        Util.BypassAllTriggers = true;
         
        Account acc1 = new Account ( Name = 'Shift CRM'  );
        insert acc1;
        
        Util.BypassAllTriggers = false;
        
        Test.stopTest();

        Account result2= [SELECT Name, r_HD_Current_Year_Engagement_Status__c, r_HD_Next_Year_Engagement_Status__c, r_HD_Previous_Year_Engagement_Status__c 
                            FROM Account WHERE Name = 'Shift CRM'];

        //System.assertEquals( 3, result2.Concurrent_Active_Years_HD__c, 'Error in concurrent years' ); 
        //System.assertEquals( 'Lost', result2.r_HD_Current_Year_Engagement_Status__c , 'Error in Current year status' ); 
        //System.assertEquals( 'Secured' , result2.r_HD_Next_Year_Engagement_Status__c, 'Error in Next year status' );    
        //System.assertEquals( 'Secured', result2.r_HD_Previous_Year_Engagement_Status__c , 'Error in Previous year status' );
            
    }

    //Test an account which concurrent years is set to 0 because there were no client status defined
    //Modified By - Seemu Saikia -CR-20190501-13072- 05/07/2019 - #Spring CleanUp

    static testMethod void test3_hd() {
        
        Test.startTest();
        
        Account_Status_Management__c cs = new Account_Status_Management__c(Enable_Update_Account_Status_Trigger__c=true);
        insert cs;

        //Create Account associated to Opportnity with a Contact set to primary in the Contact Role
        Util.BypassAllTriggers = true;
         
        Account acc1 = new Account ( Name = 'Shift CRM'  );
        insert acc1;
        
        Util.BypassAllTriggers = false;
        
        integer currentFY = shift_get_fiscal_year.current(); 
        Test.stopTest();
        Account result=  [SELECT Name, r_HD_Current_Year_Engagement_Status__c, 
                            r_HD_Next_Year_Engagement_Status__c, r_HD_Previous_Year_Engagement_Status__c 
                                FROM Account WHERE Name = 'Shift CRM'];
                            
        //System.assertEquals( 0, result.Concurrent_Active_Years_HD__c, 'Error in concurrent years' ); 
        System.assertEquals( null, result.r_HD_Current_Year_Engagement_Status__c , 'Error in Current year status' ); 
        System.assertEquals( null, result.r_HD_Next_Year_Engagement_Status__c, 'Error in Next year status');    
        System.assertEquals( null, result.r_HD_Previous_Year_Engagement_Status__c , 'Error in Previous year status' );     
    }
    
    
    //Commented by Abhinav Sharma- 08/11/2020 - CR-20180808-12492 -- Solution_Adopted__c,Solution_Status__c
    //Test to test the PopulateSolutionFlagFieldOnAccount method.
    /*public static testMethod void test_PopulateSolutionFlagFieldOnAccount() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        List<Account> accounts =  new List<Account>();
        
        accounts.add( new Account ( Name = 'Test 1', Account_Formal_Name__c = 'Test Account 1', Solution_Adopted__c = system.today(), Solution_Status__c = 'Active' ));
        accounts.add( new Account ( Name = 'Test 2', Account_Formal_Name__c = 'Test Account 2', Solution_Adopted__c = system.today(), Solution_Status__c = '' ));
        
        //Start test from here
        Test.startTest();
        
        //Enabling all Triggers
        Util.byPassAllTriggers = False;
        
        insert accounts;
        
        //QUery through Account records
        accounts = [SELECT Id, Solution_Status__c, Solutions_Flag_Image_Holder__c FROM Account ORDER BY Account_Formal_Name__c ASC ];
        
        //Asserts on result
        System.assertEquals(2, accounts.size());
        System.assertEquals('Active', accounts[0].Solution_Status__c);
        System.assertEquals('Active', accounts[0].Solutions_Flag_Image_Holder__c);
        System.assertEquals(true, String.isBlank(accounts[1].Solution_Status__c));
        System.assertEquals(true, String.isBlank(accounts[1].Solutions_Flag_Image_Holder__c));
        
        //Update the Accounts
        accounts[0].Solution_Status__c = 'Former';
        accounts[1].Solution_Status__c = 'Former';
        
        //Add More account records
        accounts.add( new Account ( Name = 'Test 3', Account_Formal_Name__c = 'Test Account 3', Solution_Adopted__c = system.today(), ParentId = accounts[0].Id, Solution_Status__c = 'Active' ));
        accounts.add( new Account ( Name = 'Test 4', Account_Formal_Name__c = 'Test Account 4', Solution_Adopted__c = system.today(), ParentId = accounts[1].Id, Solution_Status__c = 'Active' ));
        upsert accounts;
        
        //QUery through Account records
        accounts = [SELECT Id, Solution_Status__c, Solutions_Flag_Image_Holder__c FROM Account ORDER BY Account_Formal_Name__c ASC ];
        
        //Asserts on result
        System.assertEquals(4, accounts.size());
        System.assertEquals('Former', accounts[0].Solution_Status__c);
        System.assertEquals('Former', accounts[0].Solutions_Flag_Image_Holder__c);
        System.assertEquals('Former', accounts[1].Solution_Status__c);
        System.assertEquals('Former', accounts[1].Solutions_Flag_Image_Holder__c);
        System.assertEquals('Active', accounts[2].Solution_Status__c);
        System.assertEquals('Active', accounts[2].Solutions_Flag_Image_Holder__c);
        System.assertEquals('Active', accounts[3].Solution_Status__c);
        System.assertEquals('Active', accounts[3].Solutions_Flag_Image_Holder__c);
        
        //Add More account records
        accounts.add( new Account ( Name = 'Test 5', Account_Formal_Name__c = 'Test Account 5', ParentId = accounts[2].Id, Solution_Status__c = '', Solution_Adopted__c = system.today() ));
        accounts.add( new Account ( Name = 'Test 6', Account_Formal_Name__c = 'Test Account 6', ParentId = accounts[3].Id, Solution_Status__c = '', Solution_Adopted__c = system.today() ));
        upsert accounts;
        
        //QUery through Account records
        accounts = [SELECT Id, Solution_Status__c, Solutions_Flag_Image_Holder__c FROM Account ORDER BY Account_Formal_Name__c ASC ];
        
        //Asserts on result
        System.assertEquals(6, accounts.size());
        System.assertEquals('Former', accounts[0].Solution_Status__c);
        System.assertEquals('Former', accounts[0].Solutions_Flag_Image_Holder__c);
        System.assertEquals('Former', accounts[1].Solution_Status__c);
        System.assertEquals('Former', accounts[1].Solutions_Flag_Image_Holder__c);
        System.assertEquals('Active', accounts[2].Solution_Status__c);
        System.assertEquals('Active', accounts[2].Solutions_Flag_Image_Holder__c);
        System.assertEquals('Active', accounts[3].Solution_Status__c);
        System.assertEquals('Active', accounts[3].Solutions_Flag_Image_Holder__c);
        
        System.assertEquals(true, String.isBlank(accounts[4].Solution_Status__c));
        System.assertEquals('Active', accounts[4].Solutions_Flag_Image_Holder__c);
        System.assertEquals(true, String.isBlank(accounts[5].Solution_Status__c));
        System.assertEquals('Active', accounts[5].Solutions_Flag_Image_Holder__c);
        
        //Update the Accounts
        accounts[2].Solution_Status__c = 'Former';
        accounts[3].Solution_Status__c = '';
        update accounts;
        
        //QUery through Account records
        accounts = [SELECT Id, Solution_Status__c, Solutions_Flag_Image_Holder__c FROM Account ORDER BY Account_Formal_Name__c ASC ];
        
        //Asserts on result
        System.assertEquals(6, accounts.size());
        System.assertEquals('Former', accounts[0].Solution_Status__c);
        System.assertEquals('Former', accounts[0].Solutions_Flag_Image_Holder__c);
        System.assertEquals('Former', accounts[1].Solution_Status__c);
        System.assertEquals('Former', accounts[1].Solutions_Flag_Image_Holder__c);
        System.assertEquals('Former', accounts[2].Solution_Status__c);
        System.assertEquals('Former', accounts[2].Solutions_Flag_Image_Holder__c);
        System.assertEquals(true, String.isBlank(accounts[3].Solution_Status__c));
        System.assertEquals('Former', accounts[3].Solutions_Flag_Image_Holder__c);
        
        System.assertEquals(true, String.isBlank(accounts[4].Solution_Status__c));
        System.assertEquals('Former', accounts[4].Solutions_Flag_Image_Holder__c);
        System.assertEquals(true, String.isBlank(accounts[5].Solution_Status__c));
        System.assertEquals('Former', accounts[5].Solutions_Flag_Image_Holder__c);
        
        //Stop test here
        Test.stopTest();     
    } */
    
    //Added By - Mahendra Swarnkar - CR-20161102-10332 - 1/2/2017
    //Test method to test populateTopParentInstitutionOnContacts methods functionality
    static testMethod void testpopulateTopParentInstitutionOnContacts() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.isTesting = true;
        Util.BypassAllTriggers = true;
        
        //Create a restricted account
        Account acc = new Account(Name = 'Test Case Account 1');
        insert acc;
        
        //Create account 
        //List to hold Account records
        List<Account> accounts = new List<Account>();
        
        //Add accounts in list
        accounts.add(new Account(Name = 'Test Account0', Top_Parent_Institution__c = acc.Id));
        accounts.add(new Account(Name = 'Test Account1'));
        
        //Insert 
        insert accounts;
        System.assert(accounts.size() > 0);
            
        //Create contact
        //List to hold contact records
        List<Contact> contacts = new List<Contact>();
        
        //Add new contacts in list
        contacts.add(new Contact(FirstName = 'Test', LastName = 'Contact 1',Employee_User_Record__c = Userinfo.getUserId(), 
                                 Email = 'test@test.com', AccountId = accounts[0].Id, Contact_Status__c = 'Active', 
                                 Top_Parent_Institution__c = acc.Id, Title = 'Test', Phone = '614-555-8855'));
        contacts.add(new Contact(FirstName = 'Test', LastName = 'Contact 2',Employee_User_Record__c = Userinfo.getUserId(), 
                                 Email = 'test@test.com', AccountId = accounts[0].Id, Contact_Status__c = 'Active', 
                                 Top_Parent_Institution__c = acc.Id, Title = 'Test', Phone = '614-555-8855'));
        contacts.add(new Contact(FirstName = 'Test', LastName = 'Contact 3',Employee_User_Record__c = Userinfo.getUserId(), 
                                 Email = 'test@test.com', AccountId = accounts[1].Id, Contact_Status__c = 'Active', 
                                 Top_Parent_Institution__c = acc.Id, Title = 'Test', Phone = '614-555-8855'));
        contacts.add(new Contact(FirstName = 'Test', LastName = 'Contact 4',Employee_User_Record__c = Userinfo.getUserId(), 
                                 Email = 'test@test.com', AccountId = accounts[1].Id, Contact_Status__c = 'InActive - Other', 
                                 Top_Parent_Institution__c = acc.Id, Title = 'Test', Phone = '614-555-8855'));
    
        //Insert  
        insert contacts;
        
        // Test start here
        Test.startTest();
        
        //Enabling triggers again
        Util.BypassAllTriggers = false;
        
        //Updating fields value
        accounts[1].ParentId = acc.Id;
        update accounts[1];
        
        //Retrive contact updated values
        List<Contact> ContactList = [Select ID, Top_Parent_Institution__c From Contact 
                                     ORDER BY LastName ASC];
        
        //Assert for results
        System.assert(ContactList.size() > 0);
        System.assertEquals(4, ContactList.size());
        System.assertEquals(acc.Id, ContactList[0].Top_Parent_Institution__c);
        System.assertEquals(acc.Id, ContactList[1].Top_Parent_Institution__c);
        System.assertEquals(acc.Id, ContactList[2].Top_Parent_Institution__c);
        
        //Enabling triggers again
        Util.BypassAllTriggers = false;
        
        accounts[0].ParentId = null;
        update accounts[0];
        
        //Retrive contact updated values
        ContactList = [SELECT ID,Top_Parent_Institution__c 
                       FROM Contact 
                       ORDER BY LastName ASC];
        
        //Assert for result
        System.assert(ContactList.size() > 0);
        System.assertEquals(4, ContactList.size());
        System.assertEquals(accounts[0].Id, ContactList[0].Top_Parent_Institution__c);
        System.assertEquals(accounts[0].Id, ContactList[1].Top_Parent_Institution__c);
        
        //Method stop here
        Test.stopTest();  
    } 
    
    //Added By - Abhinav Sharma - CR-20170222-10716 - 4/24/2017 - For syncUpChildrenCasesField in case of the International Speaker Request record type
    static testmethod void testSyncUpChildrenCasesFieldsFuntionality() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing all triggers
        Util.BypassAllTriggers = true;
        
        //Querying Details for "Member & Employee Support" record type on Case Object
        List<RecordType> rdType = [SELECT ID FROM RecordType Where sObjectType = 'Case' AND IsActive = true 
                                                AND DeveloperName = 'Member_Employee_Support'/*'International_Speaker_Request'*/];
        
        //Account record
        Account parentAccountLevel = new Account(Name = 'Test-Parent');
        insert parentAccountLevel;
        
        //List to hold the account test data
        List<Account> accountList = New List<Account>();
        
        //Create test data 
        Account parentAccountLevel1 = new Account(Name = 'Test-Parent', ParentId = parentAccountLevel.Id, Primary_Country__c = 'test');
        Account parentAccountLevel2 = new Account(Name = 'Test-Parent', ParentId = parentAccountLevel.Id, Primary_Country__c = 'Russia');
        Account parentAccountLevel3 = new Account(Name = 'Test-Parent', ParentId = parentAccountLevel.Id, Primary_Country__c = 'Singapore');
        
        //Populating list with records instances
        accountList.add(parentAccountLevel1); accountList.add(parentAccountLevel2); accountList.add(parentAccountLevel3);
        
        //Insert Case
        insert accountList;
        
        //Bypassing all triggers
        Util.BypassAllTriggers = true;
        
        //List to hold the case records
        List<Case> cases = new List<Case>();
                                
        //Case
        Case aCase_1 = new Case(RecordTypeId = rdType[0].Id, Origin = 'Email', Subject = 'Test 1', 
                                Description = 'test 1', AccountId = accountList[0].Id, Country__c = 'Sweden');
                                
        //Case
        Case aCase_2 = new Case(RecordTypeId = rdType[0].Id, Origin = 'Phone', Subject = 'Test 2', 
                                Description = 'test 2', AccountId = accountList[1].Id, Country__c = 'Singapore' );
                                
        //Case
        Case aCase_3 = new Case(RecordTypeId = rdType[0].Id, Origin = 'Web', Subject = 'Test 3', 
                                Description = 'test 3', AccountId = accountList[2].Id, Country__c = 'United Kingdom');
                                
        //Populating list with records instances
        cases.add(aCase_1); cases.add(aCase_2); cases.add(aCase_3);
        
        //Insert Case
        insert cases;
        
        //Assert for the results
        System.assertEquals(3, cases.size());

        //Start Test from here
        Test.startTest();
        
        //Enabling all triggers
        Util.BypassAllTriggers = false;
        
        //Updating list of accounts
        accountList[0].Primary_Country__c = 'Sweden22'; 
        update accountList;
        
        //Set to hold the Account Ids
        Set<Id> setAccounts = new Set<Id>();
        
        //Loop through list of accounts
        for(Account acc : accountList) {
            setAccounts.add(acc.Id);            
        }
        
        //Asserting for results
        cases = [SELECT Id, Parent_System__c, Country__c  FROM Case WHERE AccountId IN : setAccounts ORDER BY Subject ASC];
        System.assertEquals(3, cases.size());  
        System.assertEquals('Sweden', cases[0].Country__c);
        System.assertEquals('Singapore', cases[1].Country__c);
        System.assertEquals('United Kingdom', cases[2].Country__c);
        
        //Method stop here
        Test.stopTest();  
    }
    
    
    /**
     *  @description    :   Testing updation of  "Associate Principal" field on the Opportunity
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     *  @revision Log   :   Added By - Mahendra Swarnkar - 05/8/2017 - CR-20170221-10707 
     *
     **/
    static testMethod void testPopulateAssociatePrincipalOnopportunity() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //Creating Account records
        List<Account> accounts = new List<Account>();
        
        //Add new account in list
        accounts.add(new Account(Name = 'Account 1', Associate_Principal__c = UserInfo.getUserId()));
        accounts.add(new Account(Name = 'Account 2'));
        insert accounts;
        
        
        //Get Contract LOA record type
        List<RecordType> recordTypes = [Select Id, Name FROM RecordType WHERE SobjectType = 'Opportunity' ORDER BY DeveloperName ASC];
        System.assert(recordTypes != null);
        
        //Insert Opportunities
        List<Opportunity> opportunities = new List<Opportunity>(); 
        //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
        opportunities.add(new Opportunity(Sales_Pursuit_Products__c = 'APS',Name = 'Test1', RecordTypeId = recordTypes[0].Id, AccountId = accounts[0].Id,  
                                            StageName = 'Pending', CloseDate = System.today().addDays(7), Batch_Status__c = 'Testing1'));
        
        opportunities.add(new Opportunity(Sales_Pursuit_Products__c = 'APS',Name = 'Test2', RecordTypeId = recordTypes[0].Id, AccountId = accounts[0].Id, Batch_Status__c = 'Testing2', 
                                            StageName = 'Pending', CloseDate = System.today().addDays(7), Associate_Principal__c = 'testA'));
        
        opportunities.add(new Opportunity(Sales_Pursuit_Products__c = 'APS',Name = 'Test3', RecordTypeId = recordTypes[0].Id, AccountId = accounts[1].Id, Batch_Status__c = 'Testing3',
                                            StageName = 'Pending', CloseDate = System.today().addDays(7), Associate_Principal__c = 'testB'));
        
        //Start testing from here
        Test.startTest();
        
        //Need to execute trigger
        Util.byPassAllTriggers = false;
        
        //Setting flag values
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;
        
        //Insert opportunity
        insert opportunities;
        
        //Fetching opportunites
        List<Opportunity> Oppos = [Select Id, Associate_Principal__c From Opportunity Order By Batch_Status__c ASC ];
        
        //Results on Asserts
        System.assertEquals(3, Oppos.size());
        System.assertEquals(Userinfo.getName(), Oppos[0].Associate_Principal__c);
        System.assertEquals(Userinfo.getName(), Oppos[1].Associate_Principal__c);
        System.assertEquals(null, Oppos[2].Associate_Principal__c);
        
        //Update Accounts
        accounts[1].Associate_Principal__c = UserInfo.getUserId();
        accounts[0].Associate_Principal__c = null;
        update accounts;
        
        //Fetching opportunites
        Oppos = [Select Id, Associate_Principal__c From Opportunity Order By Batch_Status__c ASC ];
        
        //Results on Asserts
        System.assertEquals(3, Oppos.size());
        System.assertEquals(null, Oppos[0].Associate_Principal__c);
        System.assertEquals(null, Oppos[1].Associate_Principal__c);
        System.assertEquals(Userinfo.getName(), Oppos[2].Associate_Principal__c);
        
        //Stop testing here
        Test.stopTest();       
    }
    
    /**
     *  @description    :   Testing updation of  "Associate Principal" field on the Opportunity
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     *  @revision Log   :   Added By - Subhash Garhwal - 04/8/2017 - CR-20170803-11120 
     *
     **/
    static testMethod void testUpdateRelationshipIntractionFields() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //Creating Account records
        List<Account> accounts = new List<Account>();
        
        //Add new account in list
        accounts.add(new Account(Name = 'Account 1', Associate_Principal__c = UserInfo.getUserId()));
        insert accounts;
        
        //Retreiving "External" Record type for Contact object
        RecordType externalRecordType = [SELECT ID, DeveloperName FROM RecordType 
                                            WHERE SobjectType = 'Contact' AND IsActive = true AND DeveloperName = 'External' LIMIT 1];
                                            
        // Create a test Contact
        Contact c = new Contact(accountid = accounts[0].Id , Lastname = 'testing ' + String.valueOf(Math.random()), 
                                Recordtypeid = externalRecordType.ID, Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', 
                                Phone = '614-555-8855');
        insert c;
        
        //Commented bvy Mahendra Swarnkar - 06/18/2019- CR-20190524-13150
        /*//List of record types
        List<RecordType> rdTypes = [SELECT ID FROM RecordType WHERE sObjectType = 'Relationship_Interaction__c'
                                    AND IsActive = true AND DeveloperName = 'Basic_Interaction'];
        
        //List of Relationship_Interaction__c
        List<Relationship_Interaction__c> testRIs = new List<Relationship_Interaction__c>();
        
        //Populating list with multiple RI records instances
        for(Integer i=0;i<120;i++) { 
            testRIs.add(new Relationship_Interaction__c(Name = 'TestAcct ' + i, Institution__c = accounts[0].Id, 
                                                        Start_Date_Time__c = System.now(), RecordTypeId = rdTypes[0].Id,
                                                        Interaction_Type__c = '1-on-1 Networking CXO Networking',
                                                        Assigned_To__c = UserInfo.getUserId(),Primary_Contact__c = c.Id,
                                                        End_Date_Time__c = System.now().addDays(5), Interaction_Level__c = 'testing'));
        }
        
        //Insert record
        insert testRIs;*/
        
        //List to insert 
        //Start testing from here
        Test.startTest();
        
        //Need to execute trigger
        Util.byPassAllTriggers = false;
        
        //Update Accounts
        accounts[0].EA_AE__c = UserInfo.getUserId();
        accounts[0].GM__c = UserInfo.getUserId();
        accounts[0].Principal__c = UserInfo.getUserId();
        accounts[0].Associate_Principal__c = UserInfo.getUserId();
        
        //Update
        update accounts;
        
        //Stop testing here
        Test.stopTest();       
    }
    
    //Test method  
    /**
     *  @description    :   Testing updation of  Nuber of Hospital field on project
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     *  @revision Log   :   Added By - Dipesh Gupta - 08/31/2017 - CR-20170426-10878 
     *
     **/
     
     static testMethod Void testProjectFieldPopulationOfAccount() {
       
       //Creating A account, on which Number_of_Hospitals_in_System__c is populated.
       //Creating Account records
        List<Account> accounts = new List<Account>();
        
        //Add new account in list
        accounts.add(new Account(Name = 'Account 1',  Number_of_Hospitals_in_System__c = 100));
        accounts.add(new Account(Name = 'Account 2',  Number_of_Hospitals_in_System__c = 101));
        insert accounts;
        /*
        //Creating Projects under the Account
         List<Project__c> projects = new list<Project__c> ();
        
        //List of project Record type 
        List<RecordType> rTProject = [Select Id From RecordType where Name = 'APS'/*'CCA'* And sobjecttype = 'Project__c'];
     
        projects.add(new Project__c(Name = 'ProjectTest1', Institution__c = accounts[0].Id, RecordTypeId = rTProject[0].Id));
        projects.add(new Project__c(Name = 'ProjectTest2', Institution__c = accounts[1].Id, RecordTypeId = rTProject[0].Id));
         
        insert  projects;
        
        //Query on the project to check the number of Hospital field 
        List<Project__c> prjs = [Select Id, Number_of_Hospitals__c From  Project__c Where Institution__r.Number_of_Hospitals_in_System__c != null order by CreatedDate DESC];
        
        system.assertEquals(2, prjs.size());
        system.assertEquals(accounts[0].Number_of_Hospitals_in_System__c, prjs[0].Number_of_Hospitals__c);
        system.assertEquals(accounts[1].Number_of_Hospitals_in_System__c, prjs[1].Number_of_Hospitals__c);
        
         
         //Update the Account 
         List<Account> accountInserted = [Select Id, Number_of_Hospitals_in_System__c From Account order by CreatedDate DESC];
         
         system.assertEquals(2, accountInserted.size());
         
         accountInserted[0].Number_of_Hospitals_in_System__c = 99;
         accountInserted[1].Number_of_Hospitals_in_System__c = 102;
         
         //Update
         update accountInserted;
         
         //Query on the project to check the number of Hospital field 
        List<Project__c> prjs1 = [Select Id, Number_of_Hospitals__c From  Project__c Where Institution__r.Number_of_Hospitals_in_System__c != null order by CreatedDate DESC];
        
        system.assertEquals(2, prjs1.size());   
        system.assertEquals(accountInserted[0].Number_of_Hospitals_in_System__c, prjs1[0].Number_of_Hospitals__c);
        system.assertEquals(accountInserted[1].Number_of_Hospitals_in_System__c, prjs1[1].Number_of_Hospitals__c);
*/
     }
     
     //Test method  
    /**
     *  @description    :   Testing updation of  Job Number on Royal Program
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     *  @revision Log   :   Added By - Dipesh Gupta - 09/07/2017 -  CR-20170221-10712,
     *
     **/
     static testmethod void populateRoyalProgramJobNoFieldByAccount() {
      
      //List to hold the Accoun
      List<Account> accounts = New List<Account>();
      
      //Add new account in list
        accounts.add(new Account(Name = 'Account 1',  r_School_Code__c = '11'));
        accounts.add(new Account(Name = 'Account 2',  r_School_Code__c = 'AB'));
       insert accounts;
          
      //Inserting program Package under the Account 
      //Get the Royall record type of Program Package 
        List<RecordType> ppRoyallRecordType = [Select Id From RecordType 
                                                Where sObjectType =: 'Program_Package__c' AND DeveloperName =: Label.PROGRAM_PACKAGE_RECORD_TYPE_DEVELOPER_NAME_ROYALL]; 
        
        //List to old the Program package records 
        List<Program_Package__c> listProgramPackage = new List<Program_Package__c>();
        
        //Populate the list
        listProgramPackage.add( new Program_Package__c ( Account__c = accounts[0].id, Name = 'ShiftTest1', Client_Status_New__c = 'In Play', 
                                                    Fiscal_Year__c = '2017' ,
                                                    RecordTypeId = ppRoyallRecordType[0].Id ));

        listProgramPackage.add( new Program_Package__c ( Account__c = accounts[1].id, Name = 'ShiftTest2', Client_Status_New__c = 'Secured',
                                                    Fiscal_Year__c = '2018', 
                                                    RecordTypeId = ppRoyallRecordType[0].Id ));
    
    insert listProgramPackage;
    
    //===============================================================Royall Programs==============================================================================================
        //Insert the Program records
        List<Royall_Program__c> rPrograms = new List<Royall_Program__c> ();
        
        rPrograms.add(new Royall_Program__c ( Name = 'Test Program1', Program_Package__c = listProgramPackage[0].Id, Target_Audience_New__c = 'Financial Aid Clients',
                                                Campaign_New__c = 'Other', Type__c = 'Discount Allocation', Probability__c = 10,
                                                Contact_Quantity__c = 1, 
                                                Status__c = 'opportunity', Billable_Travel__c = 20));
                                                
        rPrograms.add(new Royall_Program__c ( Name = 'Test Program2', Program_Package__c = listProgramPackage[1].Id, Target_Audience_New__c = 'Financial Aid Clients',
                                                Campaign_New__c = 'Other', Type__c = 'Discount Allocation', Probability__c = 10,Contact_Quantity__c = 1, 
                                                Status__c = 'opportunity', Billable_Travel__c = 20));
        //Insert programs
        insert  rPrograms;
        
        List<Royall_Program__c> royallPrograms = [Select Id, Name From Royall_Program__c order by CreatedDate DESC];
        
        system.assertEquals('11' , royallPrograms[0].Name.SubString(0,2) );
        system.assertEquals('AB',royallPrograms[1].Name.SubString(0,2) );
        system.assertEquals('1117',royallPrograms[0].Name.SubString(0,4));
        system.assertEquals('AB18', royallPrograms[1].Name.SubString(0,4));
        system.assertEquals('111753',royallPrograms[0].Name);
        system.assertEquals('AB1853', royallPrograms[1].Name);
        
        
        //Query on the Account 
        List<Account> listAccount = [Select Id, r_School_Code__c From Account order by CreatedDate DESC];
        
        listAccount[0].r_School_Code__c = 'XY';
        listAccount[1].r_School_Code__c = 'ZX';
        
        update listAccount;
        
        //Query on the royall program 
        List<Royall_Program__c> royallPrograms1 = [Select Id, Name From Royall_Program__c order by CreatedDate DESC];
        
        system.assertEquals('XY' , royallPrograms1[0].Name.SubString(0,2) );
        system.assertEquals('ZX', royallPrograms1[1].Name.SubString(0,2) ); 
    } 
    
    static testmethod void testValidateAccountToSyncAcquia() {
    
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
         
        //List to hold the Accoun
        List<Account> accounts = New List<Account>();
        
        //Add new account in list
        accounts.add(new Account(Name = 'Account 1',  r_School_Code__c = '11', Account_Formal_Name__c = 'Test First'));
        accounts.add(new Account(Name = 'Account 2',  r_School_Code__c = 'AB', Account_Formal_Name__c = 'Test Second'));
        insert accounts;
        
         //Retreiving "External" Record type for Contact object
        RecordType externalRecordType = [SELECT ID, DeveloperName FROM RecordType 
                                            WHERE SobjectType = 'Contact' AND IsActive = true AND DeveloperName = 'External' LIMIT 1];
        
        List<Contact> contacts = new List<Contact>();
        
        for(Account acc : accounts)
        {
            contacts.add(new Contact(accountid = acc.Id , Lastname = 'testing ' + String.valueOf(Math.random()), 
                                Recordtypeid = externalRecordType.ID, Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', 
                                Phone = '614-555-8855'));
        }
         
        insert contacts;
         
        //Need to execute trigger
        Util.byPassAllTriggers = false;
        
        Test.startTest();
        
        Set<Id> accountIds = new Set<Id>();
        
        //update account formal name
        for(Account acc : accounts)
        {
            acc.Account_Formal_Name__c = 'Test Second update'+Math.random();
            accountIds.add(acc.Id);
        }
        
        Update accounts;
        
        Test.stopTest();
        
        for(Contact contact : [SELECT Id, Requires_Acquia_Sync__c FROM Contact WHERE AccountId IN :accountIds])
        {
            System.assertEquals(true, contact.Requires_Acquia_Sync__c);
        }
        
        //code coverage increase 
        AccountTriggerHelper.updateOpportunityName(accounts, null); 
    }
    
    //code coverage increase
    static testmethod void testBeginVendorApproval(){
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
         
        //create new user
        Profile abcDataLoader = [SELECT Id FROM Profile WHERE Name = 'ABC DataLoader' AND Id = :label.ABC_Dataloader_Profile_Id];
        User u1 = TestUtilities.CreateNewUser(abcDataLoader, true);
        
        Util.byPassAllTriggers = false;
        
        System.runAs(u1)
        {
        //List to hold the Accoun
        List<Account> accounts = New List<Account>();
        
        //Add new account in list
        accounts.add(new Account(Name = 'Account 1',  r_School_Code__c = '11', Account_Formal_Name__c = 'Test First'));
        accounts.add(new Account(Name = 'Account 2',  r_School_Code__c = 'AB', Account_Formal_Name__c = 'Test Second'));
        insert accounts;
        }
        
        
    }
}