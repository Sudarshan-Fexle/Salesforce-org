@isTest(seeAllData = false)
private class TestMembershipTriggerHelper 
{
/**
 *  Purpose     :   Test class for NBBTriggerHelper.
 *               
 *  Create By   :   Bhavi
 *   
 *  Created Date:   11/16/2013
 *   
 *  Revision Log:   V1.1 - Created
 *                  V1.2 - Modified By - Mahendra Swarnakar - 09/15/2016 - CR-20160519-9865
 *                  V1.3 - Modified By - Dipesh Gupta - 08/30/2017 - CR-20170426-10878
 *		    V1.4 - Modified By - Neha Sharma - 11/10/2020 - CR-20201021-14625
 *		    V1.5 - Modified By - Abhinav Sharma - 17/06/2020 - CR-20200318-13865
 *		    V1.6 - Modified By - Mahendra Swarnakar - 12/01/2020 - CR-20200720-14338
 *                  V1.7 - Modified By - Neha Sharma - 04/13/2021 - CR-20210324-15022 - MRS test class update
 *		    V1.8 - Modified By - Neha Sharma - 04/21/2021 - CR-20210310-14984
 *		    V1.9 - Modified By - Shalu Sharma - 07/27/2021 - CR-20210621-15227
 *		    V2.0 - Modified By - Neha Sharma - CR-20210608-15200 - 08/12/2021
 *  Coverage    :  
**/
    
    // Added on 8/6/2012 per CR-20120730-1221 
    /* Purpose: to verify that the process_membership is updating the Active_SW_Memberships__c field
     * on the membership records associated with a given account when the business_line_c field
     * of an associated program is 'SW' */
    
    /* static testMethod void testProcessAccount() {

    //Bypassing dupeblocker
    Util.IsTest(true);
    
    //Bypassing Triggers so then test data can be created easily
    Util.byPassAllTriggers = true;
    
    Contact testContact = TestUtilities.CreateNewContact(true);
    
    Program__c swProgram = new Program__c(
    Program_Acronym__c = 'TEST',
    Program_Formal_Name__c = 'Test Program Formal',
    Name = 'Test Program',
    Create_Memberships__c = 'No',
    Renewal_Unit_Count__c = 1,
    Business_Line__c = 'SW');         
    insert swProgram;
    System.assertNotEquals(null,swProgram.id);
    
    Account testAcct = TestUtilities.CreateNewAccount(false); 
    insert testAcct;
    
    //update testAcct;
    System.assertNotEquals(null,testAcct.id);
    
    Contract__c testContract = new Contract__c(
    Name='TestContract', Status__c = 'PAYER', Start__c = system.today().addDays(-1), End__c = system.today().addDays(2),
    Negotiated_Amount__c = 1,
    Type__c = 'NBB',
    Year__c = '2010',
    Join_Date__c = system.today().addDays(-5),
    Payer_Account__c = testAcct.Id,
    Main_Contact__c = testContact.Id,
    Invoice_Contact__c = testContact.Id,
    Program__c = swProgram.Id);
    insert testContract;
    System.assertNotEquals(null,testContract.id);
    
    Membership__c testMembership = TestUtilities.CreateNewMembership(testAcct.Id,swProgram.Id,true);
    testMembership.Active_Contract_Idenfied__c = testContract.Id;
    
    //Start test from here
    Test.startTest();
    
    //Enabling triggers again
    Util.byPassAllTriggers = false;
    
    //update record
    update testMembership;
    
    System.assertNotEquals(null,testMembership.id);
    System.assertNotEquals(null,testAcct.Memberships__r);
    
    testAcct = [select id,  (select id, Membership_Status__c, Program__r.Business_Line__c, Prospect_Status__c, Renewal_Unit_Count__c, Program__r.Program_Acronym__c, Program__r.Integration_Support__c from Memberships__r)from Account where id=:testAcct.id];
    System.assertNotEquals(0,testAcct.Memberships__r.size());
    
    if(testAcct != null) {
    
    List<Membership__c> memberships = testAcct.Memberships__r;
    Account processedTestAccount = MembershipTriggerHelper.process_membership(testAcct, memberships);
    
    //Assert for the Paid_SW_Memberships__c
    //System.assertEquals(swProgram.Program_Acronym__c, testAcct.Paid_SW_Memberships__c.trim());
    
    testMembership.Active_Contract_Idenfied__c = testContract.Id;
    
    //update record
    update testMembership;
    
    //testAcct = [select id, Active_SW_Memberships__c, Paid_SW_Memberships__c, (select id, Membership_Status__c, Program__r.Business_Line__c, Prospect_Status__c, Renewal_Unit_Count__c, Program__r.Program_Acronym__c from Memberships__r)from Account where id=:testAcct.id];
    }
    
    //Test will stop here
    Test.stopTest();
    }*/
    
    //Added By - Ajit Surana - CR-20150312-8758 - 03/30/2015
    static testMethod void testpopulateIndustryMemberOnAccount() {
        
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
        
        //Insert Program data
        List<Program__c> progList = new List<Program__c>();
        
        progList.add(new Program__c(Program_Acronym__c = 'TEST', Program_Formal_Name__c = 'Test Program Formal', 
                                    Business_line__c = 'RI', Name = 'Test Program', Create_Memberships__c = 'No', 
                                    Industry_Member_for_Meetings__c = true, 
                                    New_Business_Marketer__c = 'RI Marketer'));         
        
        progList.add(new Program__c(Program_Acronym__c = 'TEST', Program_Formal_Name__c = 'Test Program Formal', 
                                    Business_line__c = 'RI', Name = 'Test Program', Create_Memberships__c = 'No', 
                                    Industry_Member_for_Meetings__c = false, New_Business_Marketer__c = 'RI Marketer'));
        insert progList;
        
        // Test Class Fix Start Here 19Feb By: Mahendra Swarnkar - CR-20190904-13309
        //Creating Contact record 
        Contact cont = TestUtilities.CreateNewContact(True);
        
        //Modified By - Neha Sharma - 04/21/2021 - CR-20201110-14683
        //Opportunity
        Opportunity opportunity = new Opportunity(Name = 'Test Opp', StageName = Constants.CONTRACT_RECEIVED, Main_Contact__c = cont.Id,
                                                  Amount = 1, CloseDate = System.today(), AccountId = accList[0].ID, Sales_Pursuit_Products__c = 'APS');
        insert opportunity;
        // Test Class Fix End Here 19Feb By: Mahendra Swarnkar - CR-20190904-13309
        
        //Contract
        Contract__c contract = new Contract__c(Name='Test1', Payer_Account__c = accList[0].ID, Program__c = progList[0].Id, 
                                               Start__c = System.Today().addDays(-10), End__c = System.Today().addDays(355), 
                                               Contract_Renewal_Opportunity__c = opportunity.Id);
        insert contract;
        
        //Update contract record
        contract.Start__c = Date.today() - 7;
        contract.End__c = Date.today() - 7;
        contract.Status__c = Constants.CLOSED;
        update contract;
        
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
        
        //Start test from here
        Test.startTest();
        
        //Enabling triggers again
        Util.byPassAllTriggers = false;
        
        //insert record
        insert membershipList;
        
        membershipList = [Select Id, Active_Core_Membership__c, Membership_Status__c, 
                          Program__r.Business_line__c
                          FROM Membership__c Where Program__c != null];
        
        //Commented by Mahendra Swarnkar - 02/12/2020 - CR-20190904-13307 - field Industry_Member__c on object Account is deleted
        //Query to fetch Account record data
        accList = [Select Id, Name/*, Industry_Member__c*/ FROM Account ORDER BY Name ASC];
        
        //Assert for results
        //System.assertEquals(true,accList[0].Industry_Member__c);
        //System.assertEquals(false,accList[1].Industry_Member__c);
        
        //Update the Membership record data
        membershipList[0].Account_Name__c =  accList[1].Id;
        membershipList[1].Account_Name__c =  accList[0].Id;
        
        //update record
        update membershipList;
        
        //Commented by Mahendra Swarnkar - 02/12/2020 - CR-20190904-13307 - field Industry_Member__c on object Account is deleted
        //Query to fetch Account record data
        accList = [Select Id, Name/*, Industry_Member__c*/ FROM Account ORDER BY Name ASC];
        
        //Assert for results
        //System.assertEquals(false,accList[0].Industry_Member__c);
        //System.assertEquals(true,accList[1].Industry_Member__c);
        
        //delete record
        delete membershipList[0];
        
        //Commented by Mahendra Swarnkar - 02/12/2020 - CR-20190904-13307 - field Industry_Member__c on object Account is deleted
        //Query to fetch Account record data
        accList = [Select Id, Name/*, Industry_Member__c*/ FROM Account ORDER BY Name ASC];
        
        //Assert for results
        //System.assertEquals(false,accList[0].Industry_Member__c);
        
        //Test will stop here
        Test.stopTest();
    }   
    
    //Modified by Mahendra Swarnkar - 8/26/2016 - CR-20160606-9903
    // Modified by Mahendra Swarnkar - 8/26/2016 - CR-20160725-10063
    //Added by Mahendra Swarnakar -  5/16/2016 CR-20160219-9619
    // Test method to validate population of "Most Recent QA Call Date" field value on membership records
    static testMethod void testPopulateMostRecentQACallDate() {
        
        //Setting flags for test 
        Util.IsTest(true);
        Util.IsTesting = true;
        Util.BypassAllTriggers = true;
        
        //Insert Account
        Account acc = new Account(Name = 'testacct');
        insert acc;
        
        //Insert Account
        Program__c prog = new Program__c(Name = 'testprog', Program_Acronym__c = 'test');
        insert prog;
        
        //Insert Membership
        Membership__c mem = new Membership__c(Account_Name__c = acc.id, Program__c = prog.id);
        insert mem;
        
        Membership__c mem1 = new Membership__c(Account_Name__c = acc.id, Program__c = prog.id,recordTypeId = Schema.getGlobalDescribe().get('Membership__c').getDescribe().getRecordTypeInfosByName().get('Enrollment').getRecordTypeId());
        insert mem1;
        //List to hold the event list
        List<Event> evntList = new List<Event>();
        
        //Date/DateTime Instances
        DateTime DTStart = System.now().addDays(Integer.valueOf(System.Label.POPULATE_MOST_RECENT_QA_CALL_ADD_DAYS)-2);
        Date DStart = DTStart.date();
        
        //Populating event list
        Event event = new Event(whatId = mem1.Id, StartDateTime = DTStart.addDays(3), ActivityDateTime = DTStart.addDays(3), ActivityDate = DStart.addDays(3),
                                EndDateTime = DTStart.addDays(4), Project_Sponsor_On_Call__c = 'Yes', Event_Type__c = 'CM QA Call', recordTypeId = Schema.getGlobalDescribe().get('Event').getDescribe().getRecordTypeInfosByName().get('Quality Assurance').getRecordTypeId());
        evntList.add(event);
        Event tsk1 = new Event(whatId = mem.Id, StartDateTime = DTStart.addDays(3), ActivityDateTime = DTStart.addDays(3), ActivityDate = DStart.addDays(3),
                               EndDateTime = DTStart.addDays(5), Project_Sponsor_On_Call__c = 'Yes', Event_Type__c = 'CM QA Call');
        Event tsk2 = new Event(whatId = mem.Id, StartDateTime = DTStart.addDays(3), ActivityDateTime = DTStart.addDays(3), ActivityDate = DStart.addDays(3),
                               EndDateTime = DTStart.addDays(4), Project_Sponsor_On_Call__c = 'Yes', Event_Type__c = 'CM QA Call', recordTypeId = Schema.getGlobalDescribe().get('Event').getDescribe().getRecordTypeInfosByName().get('Quality Assurance').getRecordTypeId());
        evntList.add(tsk1);
        evntList.add(tsk2);
        insert evntList;
        evntList = new List<Event>();
        for(integer i=1; i<=6; i++)
        {
            Event tsk = new Event(
                whatId = mem.Id,
                StartDateTime = DTStart.addDays(-i),
                ActivityDateTime = DTStart.addDays(-i),
                ActivityDate = DStart.addDays(-i),
                EndDateTime = DTStart.addDays(-i),
                Project_Sponsor_On_Call__c = 'Yes',
                Event_Type__c = 'CM QA Call');
            
            if(i==1)
            {
                tsk.Event_Type__c = 'PT QA Call';
                tsk.Would_Refer__c = '5'; 
                tsk.Would_Buy_Again__c = '6'; 
                tsk.Grade__c = 'C';
                tsk.Event_Purpose__c = 'Evergreen Action';
                tsk.StartDateTime = DTStart;
                tsk.EndDateTime = DTStart;
                tsk.ActivityDateTime = DTStart;
                tsk.ActivityDate = DStart;
                tsk.Project_Sponsor_On_Call__c = 'Yes';
                
            }
            else if(i==2)
            {
                tsk.Event_Type__c = 'PT QA Call';
                tsk.Would_Refer__c = '8'; // should come over to Membership.Most_Recent_QA_Call_Recommended_Grade__c
                tsk.Would_Buy_Again__c = '9'; // should come over to Most_Recent_QA_Call_Renew_Grade__c
                tsk.Grade__c = 'B';
                tsk.StartDateTime = DTStart;
                tsk.ActivityDateTime = DTStart;
                tsk.Event_Purpose__c = 'Evergreen Action';
                tsk.ActivityDate = DStart;
                tsk.Project_Sponsor_On_Call__c = 'Yes';
                tsk.EndDateTime = DTStart.addDays(1);
            }
            else if(i==3){
                tsk.Event_Type__c = 'RI QA Call';
                tsk.Executive_Type__c = 'N/A';
                tsk.Grade__c = 'c';
                tsk.Would_Refer__c = '8'; 
                tsk.Would_Buy_Again__c = '9';
                tsk.StartDateTime = DTStart;
                tsk.ActivityDateTime = DTStart;
                tsk.ActivityDate = DStart;
                tsk.Project_Sponsor_On_Call__c = 'Yes';
                tsk.EndDateTime = DTStart.addDays(1);
            }
            
            //Modified by Dipesh Gupta - 08/02/2019 - CR-20190801-13252
            else if(i==4){
                tsk.Event_Type__c = 'Phone Appointment';
                tsk.Executive_Type__c = 'N/A';
                tsk.Grade__c = 'B';
                tsk.Would_Refer__c = '8'; 
                tsk.Would_Buy_Again__c = '9';
                tsk.StartDateTime = DTStart;
                tsk.ActivityDateTime = DTStart;
                tsk.ActivityDate = DStart;
                tsk.Project_Sponsor_On_Call__c = 'Yes';
                tsk.EndDateTime = DTStart.addDays(1);
            }
            else
            {
                tsk.Grade__c = 'A';
            }
            evntList.add(tsk);
        }
        
        //Bypass all the triggers
        Util.BypassAllTriggers = true;
        
        //Insert events
        insert evntList;
        
        //Setting flag values and enabling triggers
        Util.byPassAllTriggers = false;
        
        //Set to hold the Membership Ids
        Set<Id> setMemIds = new Set<Id>();
        setMemIds.add(mem.Id);
        
        //Start testing from here
        Test.startTest();
        
        //Setting flag values and enabling triggers
        Util.byPassAllTriggers = false;
        
        //Memthod call to update membership record with most recent QA call date, Grads etc 
        if(setMemIds.size() > 0)
            MembershipTriggerHelper.PopulateMostRecentQACall(setMemIds);
        
        //Start testing from here
        Test.stopTest();
        
        //Fatching Membership record
        List<Membership__c> listMembership = [select Id, Most_Recent_QA_Call_Grade__c, Most_Recent_QA_Call_Renew_Grade__c, Most_Recent_QA_Call_Recommend_Grade__c from Membership__c where Id IN : setMemIds];
        
        //Asserts on result
        System.assertEquals(1, listMembership.size());
        System.assertEquals('B', listMembership[0].Most_Recent_QA_Call_Grade__c);
        System.assertEquals('8', listMembership[0].Most_Recent_QA_Call_Recommend_Grade__c);
        System.assertEquals('9', listMembership[0].Most_Recent_QA_Call_Renew_Grade__c);
    }
    
    //Added By - Mahendra Swarnakar - 09/15/2016 - CR-20160519-9865
    //Modified By - Shalu Sharma - 07/27/2021 - CR-20210621-15227
    static testMethod void testmembershipPopulateAssignedMarketer() 
    {
        //Setting flags for test 
        Util.IsTest(true);
        Util.IsTesting = true;
        Util.BypassAllTriggers = true;
        
        //Get System Admin profile list
        List<Profile> profile = [select Id, Name From Profile Where Name = 'System Administrator'];
        
        //Test User Create
        List<User> users = new List<User>();
        users.add(new User(Username= Math.random()+'@abc.com', LastName='TESTER1', FirstName='Test1', Email=Math.random()+'@test.com',
                           Alias='Test1', EmailEncodingKey='UTF-8', languagelocalekey='en_US', ProfileId=profile[0].Id, 
                           timezonesidkey='America/Los_Angeles', localesidkey='en_US', EmployeeNumber = '12121212', IsActive = true));
        users.add(new User(Username= Math.random()+'@abc.com', LastName='TESTER2', FirstName='Test1', Email=Math.random()+'@test.com',
                           Alias='Test2', EmailEncodingKey='UTF-8', languagelocalekey='en_US', ProfileId=profile[0].Id, 
                           timezonesidkey='America/Los_Angeles', localesidkey='en_US', EmployeeNumber = '12121212', IsActive = true));
        
        //insert users
        insert users;
        
        //List to hold Account records
        List<Account> accList = new List<Account>();
        
        accList.add(new Account(Name = 'Test Account1', Academy_Programs_Available_for_Outreach__c= 'Academy1'));
        accList.add(new Account(Name = 'Test Account2', BI_Programs_Available_for_Outreach__c = 'BIProgram1'));
        
        //Insert record
        insert accList;
        
        //Insert Program data
        List<Program__c> progList = new List<Program__c>();
        
        progList.add(new Program__c(Program_Acronym__c = 'TEST', Program_Formal_Name__c = 'Test Program Formal', 
                                    Business_line__c = 'RI', Name = 'Test Program', Create_Memberships__c = 'No', 
                                    Industry_Member_for_Meetings__c = true, 
                                    New_Business_Marketer__c = 'RI Marketer'));         
        
        progList.add(new Program__c(Program_Acronym__c = 'TEST', Program_Formal_Name__c = 'Test Program Formal', 
                                    Business_line__c = 'RI', Name = 'Test Program', Create_Memberships__c = 'No', 
                                    Industry_Member_for_Meetings__c = false, New_Business_Marketer__c = 'RI Marketer'));
        insert progList;
        
        // Test Class Fix Start Here 19Feb By: Mahendra Swarnkar - CR-20190904-13309
        //Creating Contact record 
        Contact cont = TestUtilities.CreateNewContact(True);
        
        //Modified By - Neha Sharma - 04/21/2021 - CR-20201110-14683
        //Opportunity
        Opportunity opportunity = new Opportunity(Name = 'Test Opp', StageName = Constants.CONTRACT_RECEIVED, Main_Contact__c = cont.Id,
                                                  Amount = 1, CloseDate = System.today(), AccountId = accList[0].ID, Sales_Pursuit_Products__c = 'APS');
        // Test Class Fix End Here 19Feb By: Mahendra Swarnkar - CR-20190904-13309
        
        insert opportunity;
        
        //Contract
        Contract__c contract = new Contract__c(Name='Test1', Payer_Account__c = accList[0].ID, Program__c = progList[0].Id, 
                                               Start__c = System.Today().addDays(-10), End__c = System.Today().addDays(355), 
                                               Contract_Renewal_Opportunity__c = opportunity.Id);
        insert contract;
        
        //Update contract record
        contract.Start__c = Date.today() - 7;
        contract.End__c = Date.today() - 7;
        contract.Status__c = Constants.CLOSED;
        update contract;
        
        //List to hold Account Team Member to be insert 
        List<AccountTeamMember> accountTeamMembers = new List<AccountTeamMember>();
        
        //List to hold Account Team Member to be insert 
        accountTeamMembers.add(new AccountTeamMember(UserId = users[0].Id, AccountId = accList[0].Id, TeamMemberRole = 'Research & Insights - RM'));
        accountTeamMembers.add(new AccountTeamMember(UserId = users[0].Id, AccountId = accList[0].Id, TeamMemberRole = 'AE or EA'));
        
        //insert Account Team Members
        insert accountTeamMembers;
        
        //List to hold Membership data
        List<Membership__c> membershipList = new List<Membership__c>();
        
        membershipList.add(new Membership__c(Name = 'Membership Test1', Account_Name__c = accList[0].Id, 
                                             Program__c = progList[0].Id, Active_Contract_Idenfied__c = contract.Id,
                                             Earliest_Contract__c = contract.Id,
                                             Latest_Contract__c = contract.Id, Membership_Status_Text__c = 'Member - Pure'));
        membershipList.add(new Membership__c(Name = 'Membership Test2', Account_Name__c = accList[1].Id, 
                                             Program__c = progList[1].Id,
                                             Earliest_Contract__c = contract.Id,
                                             Latest_Contract__c = contract.Id, Membership_Status_Text__c = 'prospect'));

        //Start test from here
        Test.startTest();
        
        //Commented by Mahendra Swarnkar - 02/12/2020 - CR-20190904-13307 - field Industry_Member__c on object Account is deleted
        //Query to fetch Account record data
        accList = [Select Id, Name/*, Industry_Member__c*/, Academy_Programs_Available_for_Outreach__c, BI_Programs_Available_for_Outreach__c FROM Account ORDER BY Name ASC];
        
        //Assert for results
        System.assertEquals('Academy1',accList[0].Academy_Programs_Available_for_Outreach__c);
        System.assertEquals('BIProgram1',accList[1].BI_Programs_Available_for_Outreach__c);
        
        //Enabling triggers again
        Util.byPassAllTriggers = false;
        
        //insert record
        insert membershipList;
        
        membershipList = [Select Id, Active_Core_Membership__c, Membership_Status__c, 
                          Program__r.Business_line__c
                          FROM Membership__c Where Program__c != null];
        
        //Modified By - Shalu Sharma - 07/27/2021 - CR-20210621-15227 
        System.assert(membershipList[0].Active_Core_Membership__c != null);
        System.assert(membershipList[1].Active_Core_Membership__c != null);
        
        //Commented by Mahendra Swarnkar - 02/12/2020 - CR-20190904-13307 - field Industry_Member__c on object Account is deleted
        //Query to fetch Account record data
        accList = [Select Id, Name/*, Industry_Member__c*/ FROM Account ORDER BY Name ASC];
        
        //Assert for results
        //System.assertEquals(true,accList[0].Industry_Member__c);
        //System.assertEquals(false,accList[1].Industry_Member__c);
        
        //Update the Membership record data
        membershipList[0].Account_Name__c =  accList[1].Id;
        membershipList[1].Account_Name__c =  accList[0].Id;
        
        Util.byPassAllTriggers = true;
        //update record
        update membershipList;
        Util.byPassAllTriggers = false;
        
        //Commented by Mahendra Swarnkar - 02/12/2020 - CR-20190904-13307 - field Industry_Member__c on object Account is deleted
        //Query to fetch Account record data
        accList = [Select Id, Name/*, Industry_Member__c*/, Academy_Programs_Available_for_Outreach__c, BI_Programs_Available_for_Outreach__c FROM Account ORDER BY Name ASC];
        
        //Assert for results
        //System.assertEquals(false,accList[0].Industry_Member__c);
        //System.assertEquals(null,accList[0].Academy_Programs_Available_for_Outreach__c);
        //System.assertEquals(true,accList[1].Industry_Member__c);
        //System.assertEquals(null,accList[1].BI_Programs_Available_for_Outreach__c);
        
        //Added by DIpesh Gupta - 
        //Creating a New Membership
        //List to hold Membership data
        List<Membership__c> membershipList1 = new List<Membership__c>();
        
        membershipList1.add(new Membership__c(Name = 'MembershipTesting', Account_Name__c = accList[0].Id, 
                                              Program__c = progList[0].Id, Active_Contract_Idenfied__c = contract.Id,
                                              Earliest_Contract__c = contract.Id,
                                              Latest_Contract__c = contract.Id, Membership_Status_Text__c = 'Member - Pure'));
        Util.byPassAllTriggers = true;                                     
        insert membershipList1;
        Util.byPassAllTriggers = false;
        //Creating Projects 
        List<Project__c> projects = new list<Project__c> ();
        
        //List of project Record type
        //Modified By Dipesh Gupta - 09/26/2019 - CR-20190529-13156 - APS replaced by Tech (SSC) as per Taylor Chatter
        List<RecordType> rTProject = [Select Id From RecordType where Name = 'Tech' And sobjecttype = 'Project__c'];
        
        projects.add(new Project__c(Name = 'ProjectTest', Primary_Paid_Membership__c =  membershipList1[0].Id, RecordTypeId = rTProject[0].Id));
        
        Util.byPassAllTriggers = true;
        insert projects;
        Util.byPassAllTriggers = false;
        
        //Test will stop here
        Test.stopTest();
        
        //Updating the contract ABC
        List<Contract__c> conABC = [Select Id, Start__c,  End__c,Negotiated_Amount__c From Contract__c Where Name='Test1'];
        
        conABC[0].Start__c  = Date.Today();
        conABC[0].End__c = Date.Today().addDays(+3);
        conABC[0].Negotiated_Amount__c = 120;
        
        update conABC[0];
        
        //Updating the membership
        List<Membership__c> memberships = [Select Id, Membership_Status_Text__c, Active_Contract_Annual_Contract_Value__c From Membership__c order by createdDate Desc];
        
        //Blank update the Membership
        //update memberships[0];
        
        //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
        List<Project__c> proejcts = [Select Id,Primary_Paid_Membership__c, Annual_Contract_Value__c/*, Membership_Status__c*/ From Project__c];
        
        system.assertEquals(proejcts.size(), 1);
        //system.assertEquals(proejcts[0].Annual_Contract_Value__c, memberships[0].Active_Contract_Annual_Contract_Value__c);
        //system.assertEquals(proejcts[0].Primary_Paid_Membership__c, memberships[0].Id);
        //system.assertEquals(proejcts[0].Membership_Status__c, memberships[0].Membership_Status_Text__c);
  
    }
    
    //Test method to verify that the Membership Status is determined by either the Active Contract Identified, OR the Active Subscription record.
    //Whichever is active should take precedence and determine status.
    //Modified - Victor Hanson - 10/10/17 - Issue--CR11637--QA--00006855
    static testmethod void testMembershipStatus() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be made easily
        Util.byPassAllTriggers = true;
        
        //Calling Utility method
        util.resetRecordtypeSettings();
        
        //Create test data
        Account acc = new Account(Name = 'Test Account Data');
        insert acc;
        
        //Program
        Program__c program = TestUtilities.CreateNewProgram(true);
        
        //Opportunity
        Opportunity opportunity = TestUtilities.CreateNewOpportunity(acc.Id, true);
        
        //Program Susbcription record that is active due to the date range
        SBQQ__Subscription__c subscription = new SBQQ__Subscription__c(SBQQ__Quantity__c = 1, Previous_Period_Negotiated__c = 100,
                                                                       SBQQ__ListPrice__c = 0, SBQQ__SegmentIndex__c = 10,  
                                                                       SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 10, SBQQ__ProrateMultiplier__c = 2,
                                                                       SBQQ__SubscriptionStartDate__c=Date.today().addDays(-10),
                                                                       SBQQ__SubscriptionEndDate__c=Date.today().addDays(2),
                                                                       Status__c = 'Committed' );
        //Insert 
        insert subscription;
        
        //Contract
        Contract__c contract = new Contract__c(Name='Test1', Payer_Account__c = acc.Id, Program__c = program.Id, Start__c = System.Today().addDays(-10), 
                                               End__c = System.Today().addDays(355), Contract_Renewal_Opportunity__c = opportunity.Id);
        insert contract;
        
        //Create a list of membership record to insert the data in bulk
        List<Membership__c> memberships = new List<Membership__c>();
        
        //Prepare data
        for(Integer i = 0; i < 3; i++) {
            memberships.add(new Membership__c(Name = 'Test Membership', Account_Name__c = acc.Id, Program__c = program.Id, 
                                              Active_Contract_Idenfied__c = contract.Id, 
                                              Active_Subscription__c=subscription.Id));
        }
        
        //Enabling Triggers
        Util.byPassAllTriggers = false;
        
        
        //insert membership record and assert the result
        insert memberships;
        
        //Start Test from here
        Test.startTest();
        
        //Update contract record so it's in the future
        contract.Start__c = Date.today() + 2;
        contract.End__c = Date.today() + 367;
        contract.Status__c = Constants.STATUS_ATL;
        update contract;
        
        //assert for the results
        memberships = [Select Membership_Status__c from Membership__c where Id IN: memberships];
        
        //Loop through the results
        for(Membership__c membership : memberships) {
            
            System.assertEquals('Member - Integrated', membership.Membership_Status__c, 'Membership Status should be Member - Payer, because the Active Subscription is active');
        }
        
        //Disabling Triggers
        Util.byPassAllTriggers = true;
        
        //Update contract record so it's currently active
        contract.Start__c = Date.today() - 2;
        contract.End__c = Date.today() + 2;
        contract.Status__c = Constants.STATUS_ATL;
        update contract;
        
        //Enabling Triggers
        Util.byPassAllTriggers = false;
        
        //update subscription so it's in future
        subscription.SBQQ__SubscriptionStartDate__c = Date.today().addDays(2);
        subscription.SBQQ__SubscriptionEndDate__c = Date.today().addDays(10);
        update subscription;
        
        //assert for the results
        memberships = [Select Membership_Status__c from Membership__c where Id IN: memberships];
        
        
        Test.stopTest();
        
        //This part is just to cover the Catch part of trigger. 
        ProgramTriggerHelper.CHECK_TRIGGER_EXCEPTION = true;
        
        try {
            update memberships[0];
        }catch(Exception e) {ProgramTriggerHelper.CHECK_TRIGGER_EXCEPTION = false;}
    }
    
    static testmethod void testPopulatePreviousCurrentNextYearProgramCost() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //Creating program record
        Program__c program = TestUtilities.CreateNewProgram(true);
        
        //Insert Products
        List<Product2> products = new List<Product2>();
        
        //Add new Products in List
        products.add(new Product2(Name = 'TMBH - Test Method', Family = 'Enrollment Services', Program__c = program.Id, IsActive = true,
                                  ProductCode = 'TMBH', SBQQ__Component__c = false, Program_Name_Member_Facing__c = 'Student Success Management Intelligence',
                                  SBQQ__AssetConversion__c = 'One per quote line', SBQQ__DefaultQuantity__c = 1,
                                  SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__SubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List'));
        
        //Add new Products in List
        products.add(new Product2(Name = 'Annual Fee', IsActive = true, ProductCode = 'Program Costs', SBQQ__Component__c = true,
                                  Product_Category__c = 'Annual Fee', Program_Name_Member_Facing__c = 'Program Costs',
                                  SBQQ__AssetConversion__c = 'One per quote line', SBQQ__DefaultQuantity__c = 1));
        
        insert products;
        
        //List to insert Feature
        List<SBQQ__ProductFeature__c> features = new List<SBQQ__ProductFeature__c>();
        
        //Add Feature record in list to insert
        features.add(new SBQQ__ProductFeature__c(Name = 'Annual Fee', SBQQ__Number__c = 10, SBQQ__MinOptionCount__c = 1, SBQQ__MaxOptionCount__c = 1,
                                                 SBQQ__ConfiguredSKU__c = products[0].Id));
        
        //Insert
        insert features;
        
        //List to insert Product Options
        List<SBQQ__ProductOption__c> productOptions = new List<SBQQ__ProductOption__c>();
        
        //Add records in list to insert
        productOptions.add(new SBQQ__ProductOption__c(SBQQ__ConfiguredSKU__c = products[0].Id, SBQQ__OptionalSKU__c = products[1].Id,
                                                      SBQQ__Number__c = 10, SBQQ__Quantity__c = 1, SBQQ__Feature__c = features[0].Id,
                                                      SBQQ__Type__c = 'Component', SBQQ__Selected__c = true, SBQQ__Required__c = true));
        
        //Insert
        insert productOptions;
        
        //Get Record Type
        Id accountUSCorporateRecordType = TestUtilities.FindRecordTypeId('Account', 'US Education'); 
        
        //Creating Account record
        Account account = TestUtilities.CreateNewAccount(false);
        account.RecordTypeId = accountUSCorporateRecordType;
        insert account; 
        
        //Creating Membership records
        Membership__c membership = TestUtilities.CreateNewMembership(account.Id, program.Id, false);
        membership.RecordTypeId = Constants.Membership_Record_Type_Enrollment;
        insert membership;
        
        //Program Package "EAB" Record Type Id
        Id programPackage_EAB_RTypeId = TestUtilities.FindRecordTypeId('Program_Package__c','EAB' );
        
        List<Program_Package__c> progPacks = new List<Program_Package__c>();
        
        progPacks.add(new Program_Package__c(Name = 'Test1', Account__c = account.Id, Fiscal_Year__c = String.valueOf(Date.Today().Year()-1), Membership__c = membership.Id,
                                             Client_Status_New__c = Label.Client_Status_Secured, Account_Status__c = 'Existing Client', RecordTypeId = programPackage_EAB_RTypeId));
        
        progPacks.add(new Program_Package__c(Name = 'Test2', Account__c = account.Id, Fiscal_Year__c = String.valueOf(Date.Today().Year()), Membership__c = membership.Id,
                                             Client_Status_New__c = Label.Client_Status_At_Risk, Account_Status__c = 'Existing Client', RecordTypeId = programPackage_EAB_RTypeId));
        
        progPacks.add(new Program_Package__c(Name = 'Test2', Account__c = account.Id, Fiscal_Year__c = String.valueOf(Date.Today().Year()+1), Membership__c = membership.Id,
                                             Client_Status_New__c = Label.Client_Status_At_Risk, Account_Status__c = 'Existing Client', RecordTypeId = programPackage_EAB_RTypeId));
        
        insert progPacks;
        
        //Create contact
        Contact contact = new Contact(LastName = 'TestingABC', AccountId = account.Id, Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855');
        insert contact;
        
        //Create Contract
        Contract StdContract = new Contract(AccountId = account.Id, Status = 'Draft', StartDate = Date.today(), ContractTerm = 12);
        insert StdContract;
        
        //Creating Opportunity 
        Opportunity opp = TestUtilities.CreateNewOpportunity(account.Id,false);
        opp.CloseDate = Date.today();
        insert opp; 
        
        //Query on Subscription Record Types
        List<RecordType> recrdTypes = [Select Id, DeveloperName From RecordType Where SobjectType = 'SBQQ__Subscription__c' 
                                       AND DeveloperName IN ('Program', 'Component') AND IsActive = true ORDER BY DeveloperName DESC];
        
        //Creating Subscription record
        //List to hold subscription
        List<SBQQ__Subscription__c> programSubscriptions = new List<SBQQ__Subscription__c>();  
        
        //Add new subscription record in list
        programSubscriptions.add(new SBQQ__Subscription__c(RecordTypeId = recrdTypes[0].Id, SBQQ__Account__c = account.Id,
                                                           SBQQ__Quantity__c = 1, Source_Opportunity__c = opp.Id,
                                                           SBQQ__ListPrice__c = 0, Stage_Period__c = 'Pending',SBQQ__Contract__c = StdContract.Id,
                                                           SBQQ__Product__c = products[0].ID, Program__c = program.ID, Membership__c = membership.Id,
                                                           SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0, SBQQ__ProrateMultiplier__c = 2,
                                                           Status__c = 'Committed', Invoice_Contact__c = contact.Id));
        
        //Insert
        insert programSubscriptions;
        
        List<Subscription_Period__c> subscriptionPeriods = new List<Subscription_Period__c>();
        
        //Creating Subscription Period record
        Subscription_Period__c sPeriod = TestUtilities.createNewSubscriptionPeriod(programSubscriptions[0].Id, false);
        
        sPeriod.Institution__c = account.Id;
        sPeriod.Period_End_Date__c = Date.Today();
        sPeriod.Contract__c = StdContract.Id;
        sPeriod.Source_Opportunity__c = opp.Id;
        sPeriod.Membership_Lookup__c = membership.Id;
        sPeriod.Program_Package__c = progPacks[1].Id;
        subscriptionPeriods.add(sPeriod);
        
        //Creating Subscription Period record
        Subscription_Period__c sPeriod1 = TestUtilities.createNewSubscriptionPeriod(programSubscriptions[0].Id, false);
        
        sPeriod1.Institution__c = account.Id;
        sPeriod1.Period_End_Date__c = Date.Today().addYears(1);
        sPeriod1.Contract__c = StdContract.Id;
        sPeriod1.Source_Opportunity__c = opp.Id;
        sPeriod1.Membership_Lookup__c = membership.Id;
        sPeriod1.Program_Package__c = progPacks[2].Id;
        subscriptionPeriods.add(sPeriod1);
        
        insert subscriptionPeriods;
        
        List<SBQQ__Subscription__c> listcomponentSubscription = new List<SBQQ__Subscription__c>();
        
        //Creating Subscription record
        SBQQ__Subscription__c componentSubscription1 = TestUtilities.createNewSubscription(membership.Id, false);
        
        componentSubscription1.SBQQ__Contract__c = StdContract.Id;
        componentSubscription1.Subscription_Period__c = subscriptionPeriods[0].Id;
        componentSubscription1.recordTypeId = recrdTypes[1].Id;
        componentSubscription1.Opportunity__c = opp.Id;
        componentSubscription1.Source_Opportunity__c = opp.Id;
        componentSubscription1.SBQQ__RequiredByProduct__c = products[0].ID;
        componentSubscription1.SBQQ__Product__c = products[1].ID;
        componentSubscription1.SBQQ__SegmentStartDate__c = Date.today();
        componentSubscription1.Program_Subscription__c = programSubscriptions[0].Id;
        componentSubscription1.SBQQ__RenewalPrice__c = 100;
        componentSubscription1.SBQQ__CustomerPrice__c = 100;
        
        listcomponentSubscription.add(componentSubscription1);
        
        //Creating Subscription record
        SBQQ__Subscription__c componentSubscription2 = TestUtilities.createNewSubscription(membership.Id, false);
        
        componentSubscription2.SBQQ__Contract__c = StdContract.Id;
        componentSubscription2.Subscription_Period__c = subscriptionPeriods[1].Id;
        componentSubscription2.recordTypeId = recrdTypes[1].Id;
        componentSubscription2.Opportunity__c = opp.Id;
        componentSubscription2.Source_Opportunity__c = opp.Id;
        componentSubscription2.SBQQ__RequiredByProduct__c = products[0].ID;
        componentSubscription2.SBQQ__Product__c = products[1].ID;
        componentSubscription2.SBQQ__SegmentStartDate__c = Date.today().addYears(1);
        componentSubscription2.Program_Subscription__c = programSubscriptions[0].Id;
        componentSubscription2.SBQQ__RenewalPrice__c = 100;
        componentSubscription2.SBQQ__CustomerPrice__c = 100; 
        
        listcomponentSubscription.add(componentSubscription2);
        
        //Insert componentSubscription
        insert listcomponentSubscription;
        
        //Update Membership record 
        membership.Previous_Year_Program_Package__c = progPacks[0].Id;
        membership.Current_Year_Program_Package__c  = progPacks[1].Id;
        membership.Next_Year_Program_Package__c  = progPacks[2].Id;
        
        Test.startTest();
        
        Util.byPassAllTriggers = false;
        update membership;
        
        
        //insert Events
        List<Event> events = new List<Event>();
        events.add(new Event(WhatId = membership.Id, OwnerId = UserInfo.getUserId(), StartDateTime = system.now(), DurationInMinutes = 60, Subject = 'Test', Event_Type__c = 'Phone Appointment', Event_Purpose__c = 'Prewire'));
        insert events;
        
        //Map Membership
        Map<Id, Membership__c> mapMembership = new Map<Id, Membership__c>();
        mapMembership.put(membership.Id, membership);
        
        MembershipTriggerHelper.populatePreviousCurrentNextYearProgramCost(mapMembership.values(),null);
        events = MembershipTriggerHelper.populateProgramInfo_Events(mapMembership, events);
        
        //Inserting the Meeting Utilization. 
        Meeting_Utilization__c futureMeeting = new Meeting_Utilization__c();
        futureMeeting.Membership__c = membership.Id;
        futureMeeting.Start_Date__c = system.today().addDays(5);
        futureMeeting.End_Date__c = system.today().addDays(5);
        futureMeeting.Contact__c = contact.Id; 
        insert futureMeeting; 
        
        Util.BypassAllTriggers = false;
        
        //Updating the Memberships. 
        membership.Active_Contract_Main_Contact__c =  contact.Id;
        update membership;
        
        Test.stopTest();
        
        //Asssertion.
        List<Meeting_Utilization__c> mutils = [Select Id, Main_Point_Of_Contact__c From Meeting_Utilization__c Where Membership__c =: membership.Id ];
        System.assert(true, mutils[0].Main_Point_Of_Contact__c);
    }
    static testmethod void testUpdateWebProgramAccessOnInstitution(){
        
        Util.bypassAllTriggers = true;
        
        //create Institute
        Account acct = TestUtilities.CreateNewAccount(true);
        acct.Entity__c= 'EAB';
        update acct;
        
        //Program
        Program__c program = TestUtilities.CreateNewProgram(true);
        
        //Opportunity
        Opportunity opportunity = TestUtilities.CreateNewOpportunity(acct.Id, true);
        
        // Modify By - Mahendra - 5/1/2020 - to increase the coverage
        //Program Susbcription record that is active due to the date range
        SBQQ__Subscription__c subscription = new SBQQ__Subscription__c(SBQQ__Quantity__c = 1, Previous_Period_Negotiated__c = 100,
                                                                       SBQQ__ListPrice__c = 0, SBQQ__SegmentIndex__c = 10,  
                                                                       SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 10, SBQQ__ProrateMultiplier__c = 2,
                                                                       SBQQ__SubscriptionStartDate__c=Date.today().addDays(-10),
                                                                       SBQQ__SubscriptionEndDate__c=Date.today().addDays(2),
                                                                       Status__c = 'Committed' );
        //Insert 
        insert subscription;
        
        //Contract
        Contract__c contract = new Contract__c(Name='Test1', Payer_Account__c = acct.Id, Program__c = program.Id, Start__c = System.Today().addDays(-10), 
                                               End__c = System.Today().addDays(355), Contract_Renewal_Opportunity__c = opportunity.Id);
        insert contract;
        
        //Get System Admin profile list
        List<Profile> profile = [select Id, Name From Profile Where Name = 'System Administrator']; 
        List<User> users = new List<User>();
        users.add(new User(Username= Math.random()+'@abc.com', LastName='TESTER1', FirstName='Test1', Email=Math.random()+'@test.com',
                           Alias='Test1', EmailEncodingKey='UTF-8', languagelocalekey='en_US', ProfileId=profile[0].Id, 
                           timezonesidkey='America/Los_Angeles', localesidkey='en_US', EmployeeNumber = '12121212', IsActive = true));
        users.add(new User(Username= Math.random()+'@abc.com', LastName='TESTER2', FirstName='Test1', Email=Math.random()+'@test.com',
                           Alias='Test2', EmailEncodingKey='UTF-8', languagelocalekey='en_US', ProfileId=profile[0].Id, 
                           timezonesidkey='America/Los_Angeles', localesidkey='en_US', EmployeeNumber = '12121212', IsActive = true));
        //insert users
        insert users;
        //Create a list of membership record to insert the data in bulk
        List<Membership__c> memberships = new List<Membership__c>();
        
        //Prepare data
        for(Integer i = 0; i < 3; i++) {
            memberships.add(new Membership__c(Name = 'Test Membership', Account_Name__c = acct.Id, Program__c = program.Id, 
                                              Active_Contract_Idenfied__c = contract.Id, BA_Assignment2__c = users[0].Id,DA_Assignment2__c = users[1].Id,
                                              Active_Subscription__c=subscription.Id,Active_Renewal_Opportunity__c = opportunity.Id));
        }        
        //Enabling Triggers
        Util.byPassAllTriggers = false;
        //insert membership record and assert the result
        insert memberships;
        
        
        // Modify By - Mahendra - 5/1/2020 - to increase the coverage
        Map<Id, Membership__c> mapOldMemberships;
        Map<Id, Membership__c> newMembershipMap = new Map<Id, Membership__c>();
        newMembershipMap.put(memberships[0].Id,memberships[0]);
        //MembershipTriggerHelper.updateCurrentYearFees(newMembershipMap,mapOldMemberships);
        
        Web_Program_Access__c wpAccess;
        //Start Test from here
        Test.startTest();
        
        //Update contract record so it's in the future
        contract.Start__c = Date.today() + 2;
        contract.End__c = Date.today() + 367;
        contract.Status__c = Constants.STATUS_ATL;
        update contract;
        
        
        //assert for the results
        memberships = [Select Membership_Status__c from Membership__c where Id IN: memberships];
        
        //Loop through the results
        for(Membership__c membership : memberships) {
            System.assertEquals('Member - Integrated', membership.Membership_Status__c, 'Membership Status should be Member - Payer, because the Active Subscription is active');
        }
        //create Web_Program_Access__c
        Web_Program_Access__c webPrgmAcc = new Web_Program_Access__c();
        webPrgmAcc.Name = 'Test';
        webPrgmAcc.Description__c = 'Testing';
        insert webPrgmAcc;
        
        //create Web_Program_Access_MTM__c
        Web_Program_Access_MTM__c webPrgmAccMTM = new  Web_Program_Access_MTM__c();
        webPrgmAccMTM.Membership_Program__c = program.Id;
        webPrgmAccMTM.Web_Program__c = webPrgmAcc.Id;
        insert webPrgmAccMTM ;
        
        Set<Id> ids = (new Map<Id, Account>([SELECT Id FROM Account])).keySet();
        wpAccess = [SELECT Program_Id_Autonumber__c FROM Web_Program_Access__c Where Id =: webPrgmAcc.Id];
        MembershipTriggerHelper.updateWebProgramAccessOnInstitution(ids);
        Test.stopTest();
        
        //assert for the result
        List<Account> accUpdatedList = [SELECT Web_Program_Access__c FROM Account Where Id =: acct.Id];
        System.assertEquals(wpAccess.Program_Id_Autonumber__c,accUpdatedList[0].Web_Program_Access__c);
    }
    
    static testmethod void test_UpdateMKConStatusChange(){
        
        Util.bypassAllTriggers = true;
        
        //create Institute
        Account acct = TestUtilities.CreateNewAccount(true);
        acct.Entity__c= 'EAB';
        update acct;
        
        Contact contact = TestUtilities.CreateNewContact(True);
        
        //Create Program
        Program__c program = TestUtilities.CreateNewProgram(true);
        
        //Create Opportunity
        Opportunity opportunity = TestUtilities.CreateNewOpportunity(acct.Id, true);
        
        //Creaate Contract
        Contract__c contract = new Contract__c(Name='Test1', Payer_Account__c = acct.Id, Program__c = program.Id, Start__c = System.Today().addDays(-10), 
                                               End__c = System.Today().addDays(355), Contract_Renewal_Opportunity__c = opportunity.Id);
        insert contract;
        
        //Program Susbcription record that is active due to the date range
        SBQQ__Subscription__c subscription = new SBQQ__Subscription__c(SBQQ__Quantity__c = 1, Previous_Period_Negotiated__c = 100,
                                                                       SBQQ__ListPrice__c = 0, SBQQ__SegmentIndex__c = 10,  
                                                                       SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 10, SBQQ__ProrateMultiplier__c = 2,
                                                                       SBQQ__SubscriptionStartDate__c=Date.today().addDays(-10),
                                                                       SBQQ__SubscriptionEndDate__c=Date.today().addDays(2),
                                                                       Status__c = 'Committed' );
        insert subscription;
        
        //Get System Admin profile list
        List<Profile> profile = [select Id, Name From Profile Where Name = 'System Administrator']; 
        
        //Create User
        List<User> users = new List<User>();
        users.add(new User(Username= Math.random()+'@abc.com', LastName='TESTER1', FirstName='Test1', Email=Math.random()+'@test.com',
                           Alias='Test1', EmailEncodingKey='UTF-8', languagelocalekey='en_US', ProfileId=profile[0].Id, 
                           timezonesidkey='America/Los_Angeles', localesidkey='en_US', EmployeeNumber = '12121212', IsActive = true));
        users.add(new User(Username= Math.random()+'@abc.com', LastName='TESTER2', FirstName='Test1', Email=Math.random()+'@test.com',
                           Alias='Test2', EmailEncodingKey='UTF-8', languagelocalekey='en_US', ProfileId=profile[0].Id, 
                           timezonesidkey='America/Los_Angeles', localesidkey='en_US', EmployeeNumber = '12121212', IsActive = true));
        insert users;
        
        //Create Membership
        List<Membership__c> memberships = new List<Membership__c>();
        memberships.add(new Membership__c(Name = 'Test Membership', Account_Name__c = acct.Id, Program__c = program.Id, 
                                          Membership_Status_Text__c = 'Member - Payer'));
        memberships.add(new Membership__c(Name = 'Test Membership', Account_Name__c = acct.Id, Program__c = program.Id, 
                                          Membership_Status_Text__c = 'Prospect- Pure'));
        insert memberships;
        
        List<Membership_Key_Contact__c> membershipsKeyContacts = new List<Membership_Key_Contact__c>();
        membershipsKeyContacts.add(new Membership_Key_Contact__c(Name= 'Test MKC', Contact__c= contact.Id, Key_Contact_Status__c = 'Active',
                                                                 Role_Type__c = 'Research', Role__c = 'Key Contact', Membership__c = memberships[0].Id));
        membershipsKeyContacts.add(new Membership_Key_Contact__c(Name= 'Test MKC1', Contact__c = contact.Id, Key_Contact_Status__c = 'Active',
                                                                 Inactive_On_Membership_Drop__c = true , Membership__c = memberships[1].Id));
        
        insert membershipsKeyContacts; 
        
        //Enabling Triggers
        Util.byPassAllTriggers = false;
        
        Test.startTest();
        
        memberships[0].Membership_Status_Text__c = Constants.PROSPECT_RECENT_DROP;
        update memberships[0];
        
        
        System.assertEquals(false, membershipsKeyContacts[0].Inactive_On_Membership_Drop__c);
        
        Test.stopTest();
    }
    
    // Modified By - Rajeev Jain - 12/01/2020 - CR-20201021-14625
    static testmethod void test_CreateCappexRequestCases(){
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be made easily
        Util.byPassAllTriggers = true;
        
        //Calling Util class methods
        util.resetRecordtypeSettings();
        
        //Fecth active user
        List<User> listUser = [Select id from User where IsActive = true AND Id !=: UserInfo.getUserId() limit 1];
        
        //Checking list for its size value
        if(listUser.size() > 0) {
            
            //Bypassing Triggers so then test data can be made easily
            Util.byPassAllTriggers = true;
            
            //Update User
            User user = new User(Id = UserInfo.getUserId(), Associate__c = listUser[0].Id);
            update user;
            
            //Create test data
            Account acc = TestUtilities.CreateNewAccount(true);
            
            //Create Program
            Program__c program = TestUtilities.CreateNewProgram(false);
            program.Program_Acronym__c = Constants.PROGRAM_ACRONYM_CXCN;
            program.Status__c = 'Active';
            insert program;
            
            //Opportunity
            Opportunity opportunity = TestUtilities.CreateNewOpportunity(acc.Id, true);
            
            //Contract
            Contract__c contract = new Contract__c(Name='Test1', Payer_Account__c = acc.Id, Program__c = program.Id, Start__c = System.Today().addDays(-10), 
                                                   End__c = System.Today().addDays(355), Contract_Renewal_Opportunity__c = opportunity.Id);
            insert contract;
            
            //Membership
            Membership__c member = new Membership__c(Name = 'Test Membership', Account_Name__c = acc.Id, Program__c = program.Id, Active_Contract_Idenfied__c = contract.Id);
            
            //Enabling Triggers
            Util.byPassAllTriggers = false;
            
            //insert membership record and assert the result
            insert member;
            
            //Bypassing Triggers 
            Util.byPassAllTriggers = true;
            
            //Update Earliest_Contract__r on contract
            contract.Start__c = Date.today() - 7;
            contract.End__c = Date.today() + 7;
            contract.Status__c = Constants.CLOSED;
            update contract;
            
            //Bypassing Triggers so then test data can be made easily
            Util.byPassAllTriggers = false;
            
            //start test from here
            Test.startTest();
            
            //update membership record
            member.Account_Name__c = acc.Id;
            update member;
            
            //stop test here
            Test.stopTest();
            
            //assert for the result
            member = [Select Id, Active_Contract_Idenfied__c, OwnerId, Membership_Status_Text__c from Membership__c where Id =: member.Id];
            System.assertEquals('Member - Payer', member.Membership_Status_Text__c);
            
            List<Case> caseRecord = [Select Id, AccountId, OwnerId, Membership__c From Case Limit 1];
            System.assertEquals(member.OwnerId, caseRecord[0].OwnerId);
            System.assertEquals(member.Id, caseRecord[0].Membership__c);
        }
    }
    
    @isTest(SeeAllData=true)
    // Created By - Mahendra Swarnkar - 12/01/2020 - CR-20200720-14338
    static void test_UpdateMainContactOnSIL(){
        
        //Setting flags for test 
        Util.IsTest(true);
        Util.IsTesting = true;
        
        //Bypassing Triggers so then test data can be made easily
        Util.byPassAllTriggers = true;
        
        //Create a new Program
        Program__c prog = TestUtilities.CreateNewProgram(true);
        
        //Create a new Account
        Account acc = testUtilities.CreateNewAccount(true);
        
        
        //Create a new Contact
        Contact testContact = TestUtilities.CreateNewContact(true);
        
        List<Membership__c> memberships = new List<Membership__c>();
        memberships.add(new Membership__c(Account_Name__c = acc.Id, Program__c = prog.Id));
        
        insert memberships;
        
        //Get Salesinvoice line item record and update the Membership
        c2g__codaInvoiceLineItem__c	sli = [Select Id, Membership__c From c2g__codaInvoiceLineItem__c limit 1]; 
        sli.Membership__c = memberships[0].Id;
        
        update sli;
        
        //Enable all the Triggers 
        Util.byPassAllTriggers = false;
        
        //Test starts from here
        test.startTest();
        
        //update Active main Contact
        memberships[0].Active_Contract_Main_Contact__c = testContact.Id;
        update memberships[0];
        
        //Get the Sales invoice line items 
        Id sliMainContact = [Select Id, Main_Contact__c From c2g__codaInvoiceLineItem__c Where Id =: sli.Id limit 1]?.Main_Contact__c;
        
        //Asserts
        System.assertEquals(testContact.Id, sliMainContact);
        
        //Test Ends Here
        test.stopTest();
    }
    
    //Added By - Neha Sharma - CR-20210324-15022 - 04/13/2021 - for insert case
    //Modified By - Neha Sharma - CR-20210608-15200 - 08/12/2021 - Test class fix
    static testmethod void test_syncRegistrationPartnerStatus(){
        
        //Added by - Neha Sharama - 08/12/2021
        //initialize mock response
        MockAcquiaHTTPCallout mockAcquiaCallOut = new MockAcquiaHTTPCallout();
        Test.setMock(HttpCalloutMock.Class, mockAcquiaCallOut);
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        User userA = [SELECT Id FROM User WHERE Id != :UserInfo.getUserId() AND ProfileId = :UserInfo.getProfileId() AND IsActive = true LIMIT 1];
        Id assigneeId = userInfo.getUserId();
        System.runAs(userA) {
            
            PermissionSet ps = [SELECT Id, Label FROM PermissionSet WHERE Label = 'EAB Event Manager'];
            
            PermissionSetAssignment assignPS = new PermissionSetAssignment (AssigneeId = assigneeId , PermissionSetId = ps.Id);
            insert assignPS;  
        }
        //List to hold Account records
        List<Account> accList = new List<Account>();
        
        accList.add(testUtilities.CreateNewAccount(false));
        accList.add(testUtilities.CreateNewAccount(false));
        
        //Insert record
        insert accList;
        
        //Insert Program data
        List<Program__c> progList = new List<Program__c>();
        
        progList.add(new Program__c(Program_Acronym__c = 'TEST', Program_Formal_Name__c = 'Test Program Formal', 
                                    Business_line__c = 'RI', Name = 'Test Program', Create_Memberships__c = 'No', 
                                    Industry_Member_for_Meetings__c = true, 
                                    New_Business_Marketer__c = 'RI Marketer'));         
        
        progList.add(new Program__c(Program_Acronym__c = 'TEST', Program_Formal_Name__c = 'Test Program Formal', 
                                    Business_line__c = 'RI', Name = 'Test Program', Create_Memberships__c = 'No', 
                                    Industry_Member_for_Meetings__c = false, New_Business_Marketer__c = 'RI Marketer'));
        insert progList;
        
        //Creating Contact record 
        // List to store test Contacts
        List<Contact> contacts = new List<Contact>();
        
        //Add contact data in list
        contacts.add(testUtilities.CreateNewContact(accList[0], false));
        contacts.add(testUtilities.CreateNewContact(accList[1], false));
        //Insert Contact Data
        
        insert contacts;
        
        //Opportunity
        Opportunity opportunity = new Opportunity(Name = 'Test Opp', StageName = Constants.CONTRACT_RECEIVED, Main_Contact__c = contacts[0].Id,
                                                  Amount = 1, CloseDate = System.today(), AccountId = accList[0].ID, Sales_Pursuit_Products__c = 'APS');
        insert opportunity;
        // Test Class Fix End Here 19Feb By: Mahendra Swarnkar - CR-20190904-13309
        
        //Contract
        Contract__c contract = new Contract__c(Name='Test1', Payer_Account__c = accList[0].ID, Program__c = progList[0].Id, 
                                               Start__c = System.Today().addDays(-10), End__c = System.Today().addDays(355), 
                                               Contract_Renewal_Opportunity__c = opportunity.Id, Negotiated_Amount__c = 10000,Type__c = 'NBB', Year__c = String.ValueOf(System.today().Year()), 
                                               Join_Date__c = System.today(), Main_Contact__c = contacts[0].Id, Invoice_Contact__c = contacts[0].Id);
        
        insert contract;
        
        // create two EAB events
        List<Advisory_Event__c> eabEvents = new List<Advisory_Event__c>();
        //Create the new EAB event record
        //Modified By - CR-20210608-15200 - Neha Sharma - 08/12/2021 - Addedfew fields value - start
        Advisory_Event__c cohortEvent = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_COHORT, null, false);
        cohortEvent.Short_Name__c = 'EAB 1';
        cohortEvent.Status__c = Constants.EAB_EVENT_STATUS_OPEN_REGISTRATION;
        cohortEvent.Primary_Program__c  = progList[1].Id;
        cohortEvent.Rules_Programs__c = 'Establish independent rules';
        cohortEvent.Begins__c = System.today();
        cohortEvent.Ends__c = System.today();
        cohortEvent.Public_Name__c = 'Test';
        cohortEvent.Event_Type__c = 'Research Working Sessions';
        eabEvents.add(cohortEvent);
        
        cohortEvent = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_EVENT, null, false);
        cohortEvent.Short_Name__c = 'EAB 2';
        cohortEvent.Status__c = Constants.EAB_EVENT_STATUS_OPEN_REGISTRATION;
        cohortEvent.Primary_Program__c  = progList[0].Id;
        cohortEvent.Rules_Programs__c = 'Establish independent rules';
        cohortEvent.Begins__c = System.today();
        cohortEvent.Ends__c = System.today();
        cohortEvent.Public_Name__c = 'Test';
        cohortEvent.Event_Type__c = 'Research Working Sessions';
        eabEvents.add(cohortEvent);
        //Modified By - Neha Sharma - 08/12/2021 - Addedfew fields value - end
        
        insert eabEvents;
        
        //Modified By - Neha Sharma - CR-20210608-15200 - 08/12/2021 - Added rules - start
        // create rules
        List<Rule__c> rules = new List<Rule__c>();
        rules.add(new Rule__c(Advisory_Event__c = eabEvents[0].Id, Program__c = progList[0].Id, Primary__c = true));
        rules.add(new Rule__c(Advisory_Event__c = eabEvents[0].Id, Program__c = progList[1].Id));
        rules.add(new Rule__c(Advisory_Event__c = eabEvents[1].Id, Program__c = progList[0].Id));
        rules.add(new Rule__c(Advisory_Event__c = eabEvents[1].Id, Program__c = progList[1].Id, Primary__c = true));
        
        Insert rules;
        //Modified By - Neha Sharma - 08/12/2021 - Added rules - end
        
        
        //create Registration
        List<Registration__c> registrations = new List<Registration__c>();
        //for cohort event
        registrations.add(Test_SiteMeetingController.CreateRegistration(eabEvents[0].Id, contacts[0].Id, false));
        registrations.add(Test_SiteMeetingController.CreateRegistration(eabEvents[0].Id, contacts[1].Id, false));
        //for event
        registrations.add(Test_SiteMeetingController.CreateRegistration(eabEvents[1].Id, contacts[0].Id, false));
        registrations.add(Test_SiteMeetingController.CreateRegistration(eabEvents[1].Id, contacts[1].Id, false));
        
        insert registrations;
        
        //stop bypassing trigger
        Util.byPassAllTriggers = false;
        User userB = [SELECT Id FROM User WHERE Id = :userInfo.getUserId()];
        
        System.runAs(userB){
            
            //List to hold Membership data
            List<Membership__c> membershipList = new List<Membership__c>();
            
            membershipList.add(new Membership__c(Name = 'Membership Test1', Account_Name__c = accList[0].Id, 
                                                 Program__c = progList[0].Id, Active_Contract_Idenfied__c = contract.Id,
                                                 Earliest_Contract__c = contract.Id,
                                                 Latest_Contract__c = contract.Id, Membership_Status_Text__c = 'Member - Payer'));
            //No contract is created for Account
            membershipList.add(new Membership__c(Name = 'Membership Test2', Account_Name__c = accList[1].Id, 
                                                 Program__c = progList[1].Id, Membership_Status_Text__c = 'Member - Payer'));
            
            Insert membershipList;
            
            registrations = [Select Id, Partner_Status__c From Registration__c Where Id IN: registrations];
            
            //check status of registration after insert
            
            
            
            System.assertEquals(Constants.REGISTRATION_PARTNER_STATUS_PARTNER, registrations[2].Partner_Status__c);
            System.assertEquals(Constants.REGISTRATION_PARTNER_STATUS_PARTNER, registrations[0].Partner_Status__c);
            System.assertEquals(Constants.REGISTRATION_PARTNER_STATUS_PROSPECT, registrations[1].Partner_Status__c);
            System.assertEquals(Constants.REGISTRATION_PARTNER_STATUS_PROSPECT, registrations[3].Partner_Status__c);
            
            
        }
        
    }
    
    //Added By - Neha Sharma - CR-20210324-15022  - 04/12/2021 - for update/delete case
    //Modified By  - Neha Sharma - CR-20210608-15200 - 08/12/2021 - Test class fix
    static testmethod void test_syncRegistrationPartnerStatusV2(){
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Added by - Neha Sharama - 08/12/2021
        //initialize mock response
        MockAcquiaHTTPCallout mockAcquiaCallOut = new MockAcquiaHTTPCallout();
        Test.setMock(HttpCalloutMock.Class, mockAcquiaCallOut);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        User userA = [SELECT Id FROM User WHERE Id != :UserInfo.getUserId() AND ProfileId = :UserInfo.getProfileId() AND IsActive = true LIMIT 1];
        Id assigneeId = userInfo.getUserId();
        System.runAs(userA) {
            
            PermissionSet ps = [SELECT Id, Label FROM PermissionSet WHERE Label = 'EAB Event Manager'];
            
            PermissionSetAssignment assignPS = new PermissionSetAssignment (AssigneeId = assigneeId , PermissionSetId = ps.Id);
            insert assignPS;  
        }
        //List to hold Account records
        List<Account> accList = new List<Account>();
        
        accList.add(testUtilities.CreateNewAccount(false));
        accList.add(testUtilities.CreateNewAccount(false));
        
        //Insert record
        insert accList;
        
        //Insert Program data
        List<Program__c> progList = new List<Program__c>();
        
        progList.add(new Program__c(Program_Acronym__c = 'TEST', Program_Formal_Name__c = 'Test Program Formal', 
                                    Business_line__c = 'RI', Name = 'Test Program', Create_Memberships__c = 'No', 
                                    Industry_Member_for_Meetings__c = true, 
                                    New_Business_Marketer__c = 'RI Marketer'));         
        
        progList.add(new Program__c(Program_Acronym__c = 'TEST', Program_Formal_Name__c = 'Test Program Formal', 
                                    Business_line__c = 'RI', Name = 'Test Program', Create_Memberships__c = 'No', 
                                    Industry_Member_for_Meetings__c = false, New_Business_Marketer__c = 'RI Marketer'));
        insert progList;
        
        //Creating Contact record 
        // List to store test Contacts
        List<Contact> contacts = new List<Contact>();
        
        //Add contact data in list
        contacts.add(testUtilities.CreateNewContact(accList[0], false));
        contacts.add(testUtilities.CreateNewContact(accList[1], false));
        //Insert Contact Data
        
        insert contacts;
        
        //Opportunity
        Opportunity opportunity = new Opportunity(Name = 'Test Opp', StageName = Constants.CONTRACT_RECEIVED, Main_Contact__c = contacts[0].Id,
                                                  Amount = 1, CloseDate = System.today(), AccountId = accList[0].ID, Sales_Pursuit_Products__c = 'APS');
        //Opportunity
        Opportunity opportunity1 = new Opportunity(Name = 'Test Opp', StageName = Constants.CONTRACT_RECEIVED, Main_Contact__c = contacts[1].Id,
                                                   Amount = 1, CloseDate = System.today(), AccountId = accList[1].ID, Sales_Pursuit_Products__c = 'APS');
        
        insert new List<Opportunity>{opportunity,opportunity1};
        // Test Class Fix End Here 19Feb By: Mahendra Swarnkar - CR-20190904-13309
            
        //Contract
        Contract__c contract = new Contract__c(Name='Test1', Payer_Account__c = accList[0].ID, Program__c = progList[0].Id, 
                                                   Start__c = System.Today().addDays(-10), End__c = System.Today().addDays(355), 
                                                   Contract_Renewal_Opportunity__c = opportunity.Id, Negotiated_Amount__c = 10000,Type__c = 'NBB', Year__c = String.ValueOf(System.today().Year()), 
                                                   Join_Date__c = System.today(), Main_Contact__c = contacts[0].Id, Invoice_Contact__c = contacts[0].Id);
        //Contract
        Contract__c contract1 = new Contract__c(Name='Test2', Payer_Account__c = accList[1].ID, Program__c = progList[1].Id, 
                                                Start__c = System.Today().addDays(-10), End__c = System.Today().addDays(355), 
                                                Contract_Renewal_Opportunity__c = opportunity1.Id, Negotiated_Amount__c = 10000,Type__c = 'NBB', 
                                                Year__c = String.ValueOf(System.today().Year()), Join_Date__c = System.today(), 
                                                Main_Contact__c = contacts[0].Id, Invoice_Contact__c = contacts[0].Id);
        
        insert new List<Contract__c>{contract,contract1};
            
        // create two EAB events
        List<Advisory_Event__c> eabEvents = new List<Advisory_Event__c>();
        //Modified By - Neha Sharma - CR-20210608-15200 - 08/12/2021 - Addedfew fields value - start
        Advisory_Event__c cohortEvent = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_COHORT, null, false);
        cohortEvent.Short_Name__c = 'EAB 1';
        cohortEvent.Status__c = Constants.EAB_EVENT_STATUS_OPEN_REGISTRATION;
        cohortEvent.Primary_Program__c  = progList[1].Id;
        cohortEvent.Rules_Programs__c = 'Establish independent rules';
        cohortEvent.Begins__c = System.today();
        cohortEvent.Ends__c = System.today();
        cohortEvent.Public_Name__c = 'Test';
        cohortEvent.Event_Type__c = 'Research Working Sessions';
        eabEvents.add(cohortEvent);
        
        cohortEvent = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_EVENT, null, false);
        cohortEvent.Short_Name__c = 'EAB 2';
        cohortEvent.Status__c = Constants.EAB_EVENT_STATUS_OPEN_REGISTRATION;
        cohortEvent.Primary_Program__c  = progList[0].Id;
        cohortEvent.Rules_Programs__c = 'Establish independent rules';
        cohortEvent.Begins__c = System.today();
        cohortEvent.Ends__c = System.today();
        cohortEvent.Public_Name__c = 'Test';
        cohortEvent.Event_Type__c = 'Research Working Sessions';
        eabEvents.add(cohortEvent);
        //Modified By - Neha Sharma - 08/12/2021 - Addedfew fields value - end
        
        insert eabEvents;
        
        //Modified By - Neha Sharma - CR-20210608-15200 - 08/12/2021 - Added rules - start
        // create rules
        List<Rule__c> rules = new List<Rule__c>();
        rules.add(new Rule__c(Advisory_Event__c = eabEvents[0].Id, Program__c = progList[0].Id, Primary__c = true));
        rules.add(new Rule__c(Advisory_Event__c = eabEvents[0].Id, Program__c = progList[1].Id));
        rules.add(new Rule__c(Advisory_Event__c = eabEvents[1].Id, Program__c = progList[0].Id));
        rules.add(new Rule__c(Advisory_Event__c = eabEvents[1].Id, Program__c = progList[1].Id, Primary__c = true));
        
        Insert rules;
        //Modified By - Neha Sharma - 08/12/2021 - Added rules - end
        
        //create Registration
        List<Registration__c> registrations = new List<Registration__c>();
        //for cohort event
        registrations.add(Test_SiteMeetingController.CreateRegistration(eabEvents[0].Id, contacts[0].Id, false));
        registrations.add(Test_SiteMeetingController.CreateRegistration(eabEvents[0].Id, contacts[1].Id, false));
        //for event
        registrations.add(Test_SiteMeetingController.CreateRegistration(eabEvents[1].Id, contacts[0].Id, false));
        registrations.add(Test_SiteMeetingController.CreateRegistration(eabEvents[1].Id, contacts[1].Id, false));
        
        insert registrations;
        
        //List to hold Membership data
        List<Membership__c> membershipList = new List<Membership__c>();
        
        membershipList.add(new Membership__c(Name = 'Membership Test1', Account_Name__c = accList[0].Id, 
                                             Program__c = progList[0].Id, Active_Contract_Idenfied__c = contract.Id,
                                             Earliest_Contract__c = contract.Id,
                                             Latest_Contract__c = contract.Id, Membership_Status_Text__c = 'Member - Payer'));
        //No contract is created for Account
        membershipList.add(new Membership__c(Name = 'Membership Test2', Account_Name__c = accList[1].Id, 
                                             Program__c = progList[1].Id, Membership_Status_Text__c = 'Prospect - pure'));
        
        //stop bypassing trigger
        Util.byPassAllTriggers = false;
        
        //test starts here
        test.startTest();
        Insert membershipList;

        User userB = [SELECT Id FROM User WHERE Id = :userInfo.getUserId()];
        
        System.runAs(userB){
            
            membershipList[1].Active_Contract_Idenfied__c = contract1.Id;
            membershipList[1].Earliest_Contract__c = contract1.Id;
            membershipList[1].Latest_Contract__c = contract.Id; 
            membershipList[1].Membership_Status_Text__c = 'Member - Payer';
            
            membershipList[0].Program__c = progList[1].Id;
            
            //update membership
            Update membershipList;
            
            registrations = [Select Id, Partner_Status__c From Registration__c Where Id IN: registrations];
            
            //check status of registration after update
            System.assertEquals(Constants.REGISTRATION_PARTNER_STATUS_PARTNER, registrations[0].Partner_Status__c);
            System.assertEquals(Constants.REGISTRATION_PARTNER_STATUS_PARTNER, registrations[1].Partner_Status__c);
            System.assertEquals(Constants.REGISTRATION_PARTNER_STATUS_PARTNER, registrations[2].Partner_Status__c);
            System.assertEquals(Constants.REGISTRATION_PARTNER_STATUS_PARTNER, registrations[3].Partner_Status__c);
            
            //delete Membership
            Delete membershipList[0];
            
            registrations = [Select Id, Partner_Status__c From Registration__c Where Id IN: registrations];
            
            //check status of registration after update
            System.assertEquals(Constants.REGISTRATION_PARTNER_STATUS_PROSPECT, registrations[0].Partner_Status__c);
            System.assertEquals(Constants.REGISTRATION_PARTNER_STATUS_PARTNER, registrations[1].Partner_Status__c);
            System.assertEquals(Constants.REGISTRATION_PARTNER_STATUS_PROSPECT, registrations[2].Partner_Status__c);
            System.assertEquals(Constants.REGISTRATION_PARTNER_STATUS_PARTNER, registrations[3].Partner_Status__c);
            
            //Test Ends Here
            test.stopTest();
        }
        
    }
    //Added By - Neha Sharma - CR-20210113-14804  - 05/24/2021 - for update/delete case
    static testmethod void test_updateCurrentYearFees(){
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //List to hold Account records
        List<Account> accList = new List<Account>();
        
        accList.add(testUtilities.CreateNewAccount(false));
        accList.add(testUtilities.CreateNewAccount(false));
        
        //Insert record
        insert accList;
        
        //Insert Program data
        List<Program__c> progList = new List<Program__c>();
        Program__c prog = TestUtilities.CreateNewProgram(false);
        Program__c prog1 = TestUtilities.CreateNewProgram(false);
        progList.add(prog);
        progList.add(prog1);
        
        insert progList;
        
        // List to store test Contacts
        List<Contact> contacts = new List<Contact>();
        
        //Add contact data in list
        contacts.add(testUtilities.CreateNewContact(accList[0], false));
        contacts.add(testUtilities.CreateNewContact(accList[1], false));
        //Insert Contact Data
        
        insert contacts;
        
        Opportunity opportunity = new Opportunity(Name = 'Test Opp', StageName = Constants.CONTRACT_RECEIVED, Main_Contact__c = contacts[0].Id,
                                                  Amount = 1, CloseDate = System.today(), AccountId = accList[0].ID, Sales_Pursuit_Products__c = 'APS');
        
        Opportunity opportunity1 = new Opportunity(Name = 'Test Opp', StageName = Constants.CONTRACT_RECEIVED, Main_Contact__c = contacts[1].Id,
                                                   Amount = 1, CloseDate = System.today(), AccountId = accList[1].ID, Sales_Pursuit_Products__c = 'APS');
        
        insert new List<Opportunity>{opportunity,opportunity1};
            
        Contract__c contract = new Contract__c(Name='Test1', Payer_Account__c = accList[0].ID, Program__c = progList[0].Id,Start__c = System.Today().addDays(-10), End__c = System.Today().addDays(355), 
                                                   Contract_Renewal_Opportunity__c = opportunity.Id, Negotiated_Amount__c = 10000,Type__c = 'NBB', Year__c = String.ValueOf(System.today().Year()), 
                                                   Join_Date__c = System.today(), Main_Contact__c = contacts[0].Id, Invoice_Contact__c = contacts[0].Id);
        insert contract;
        
        Contract__c contract1 = new Contract__c(Name='Test1', Payer_Account__c = accList[1].ID, Program__c = progList[1].Id,Start__c = System.Today().addDays(-10), End__c = System.Today().addDays(355), 
                                                Contract_Renewal_Opportunity__c = opportunity.Id, Negotiated_Amount__c = 10000,Type__c = 'NBB', Year__c = String.ValueOf(System.today().Year()), 
                                                Join_Date__c = System.today(), Main_Contact__c = contacts[1].Id, Invoice_Contact__c = contacts[1].Id);
        insert contract1;

        Product2 product = new Product2(Name = CPQConstants.PRODUCT_CATEGORY_ANNUAL_FEE, Family = 'EAB Tech', Program__c = progList[0].Id, IsActive = true,	Product_Category__c = 'Annual Fee',
                                        ProductCode = 'TMBH', SBQQ__Component__c = false, Program_Name_Member_Facing__c = 'Student Success Management Intelligence',
                                        SBQQ__AssetConversion__c = 'One per quote line', SBQQ__DefaultQuantity__c = 1,
                                        SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__SubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List');
        
        Product2 product1 = new Product2(Name = CPQConstants.PRODUCT_CATEGORY_TRAVEL_FEE, Family = 'EAB Tech', Program__c = progList[0].Id, IsActive = true,	Product_Category__c = 'Annual Fee',
                                         ProductCode = 'TMBH', SBQQ__Component__c = false, Program_Name_Member_Facing__c = 'Student Success Management Intelligence',
                                         SBQQ__AssetConversion__c = 'One per quote line', SBQQ__DefaultQuantity__c = 1,
                                         SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__SubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List');
        
        insert product;
        insert product1;
        
        SBQQ__Subscription__c subscription = new SBQQ__Subscription__c(RecordTypeId = constants.RECORD_TYPE_ID_SUBSCRIPTION_PROGRAM,SBQQ__Quantity__c = 1, Previous_Period_Negotiated__c = 100,
                                                                       SBQQ__ListPrice__c = 0, SBQQ__SegmentIndex__c = 10,
                                                                       SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 10, SBQQ__ProrateMultiplier__c = 2,SBQQ__Product__c = product.Id,
                                                                       SBQQ__SubscriptionStartDate__c=Date.today().addDays(-10),
                                                                       SBQQ__SubscriptionEndDate__c=Date.today().addDays(2),
                                                                       Status__c = 'Committed' );
        insert subscription;
        
        List<Membership__c> membershipList = new List<Membership__c>();
        
        membershipList.add(new Membership__c(Name = 'Membership Test1', Account_Name__c = accList[0].Id, 
                                             Program__c = progList[0].Id, Active_Contract_Idenfied__c = contract.Id,
                                             Earliest_Contract__c = contract.Id,Active_Subscription__c = subscription.Id,Current_Period_Start_Date__c = Date.today().addDays(-10), Current_Period_End_Date__c = Date.today().addDays(2),
                                             Latest_Contract__c = contract.Id, Membership_Status_Text__c = constants.MEMBER_PAYER));
        
        membershipList.add(new Membership__c(Name = 'Membership Test2', Account_Name__c = accList[1].Id, 
                                             Program__c = progList[1].Id, Active_Contract_Idenfied__c = contract1.Id,
                                             Earliest_Contract__c = contract1.Id,Active_Subscription__c = subscription.Id,Current_Period_Start_Date__c = Date.today().addDays(-10), Current_Period_End_Date__c = Date.today().addDays(2),
                                             Latest_Contract__c = contract1.Id, Membership_Status_Text__c = constants.MEMBER_PAYER));
        
        insert membershipList;
        
        Contract StdContract = new Contract(AccountId = accList[0].Id, Status = 'Draft', StartDate = Date.today().addDays(-10), ContractTerm = 12);
        insert StdContract;
        
        Contract StdContract1 = new Contract(AccountId = accList[1].Id, Status = 'Draft', StartDate = Date.today().addDays(-10), ContractTerm = 12);
        insert StdContract1;
        
        List<SBQQ__Subscription__c> listcomponentSubscription = new List<SBQQ__Subscription__c>();
        listcomponentSubscription.add(new SBQQ__Subscription__c(SBQQ__Quantity__c = 1,SBQQ__Contract__c = StdContract.Id,recordTypeId =constants.RECORD_TYPE_ID_SUBSCRIPTION_COMPONENT,Opportunity__c = opportunity.Id,
                                                                SBQQ__RequiredByProduct__c = product.Id,SBQQ__Product__c = product.Id,SBQQ__SegmentStartDate__c = Date.today().addDays(-10),SBQQ__SegmentEndDate__c = Date.today().addDays(2),Program_Subscription__c = subscription.Id,SBQQ__RenewalPrice__c = 100,SBQQ__CustomerPrice__c = 100,Membership__c = membershipList[0].Id));
        
        listcomponentSubscription.add(new SBQQ__Subscription__c(SBQQ__Quantity__c = 1,SBQQ__Contract__c = StdContract1.Id,recordTypeId = constants.RECORD_TYPE_ID_SUBSCRIPTION_COMPONENT,Opportunity__c = opportunity1.Id,
                                                                SBQQ__RequiredByProduct__c = product.Id,SBQQ__Product__c = product.Id,SBQQ__SegmentStartDate__c = Date.today().addDays(-10),SBQQ__SegmentEndDate__c = Date.today().addDays(2),Program_Subscription__c = subscription.Id,SBQQ__RenewalPrice__c = 100,SBQQ__CustomerPrice__c = 100,Membership__c = membershipList[0].Id));
        
        listcomponentSubscription.add(new SBQQ__Subscription__c(SBQQ__Quantity__c = 1,SBQQ__Contract__c = StdContract.Id,recordTypeId =constants.RECORD_TYPE_ID_SUBSCRIPTION_COMPONENT,Opportunity__c = opportunity.Id,
                                                                SBQQ__RequiredByProduct__c = product.Id,SBQQ__Product__c = product1.Id,SBQQ__SegmentStartDate__c = Date.today().addDays(-10),SBQQ__SegmentEndDate__c = Date.today().addDays(2),Program_Subscription__c = subscription.Id,SBQQ__RenewalPrice__c = 100,SBQQ__CustomerPrice__c = 100,Membership__c = membershipList[1].Id));

        listcomponentSubscription.add(new SBQQ__Subscription__c(SBQQ__Quantity__c = 1,SBQQ__Contract__c = StdContract1.Id,recordTypeId = constants.RECORD_TYPE_ID_SUBSCRIPTION_COMPONENT,Opportunity__c = opportunity1.Id,
                                                                SBQQ__RequiredByProduct__c = product.Id,SBQQ__Product__c = product1.Id,SBQQ__SegmentStartDate__c = Date.today().addDays(-10),SBQQ__SegmentEndDate__c = Date.today().addDays(2),Program_Subscription__c = subscription.Id,SBQQ__RenewalPrice__c = 100,SBQQ__CustomerPrice__c = 100,Membership__c = membershipList[1].Id));
        
        //Insert componentSubscription
        insert listcomponentSubscription;

        //Enabling Triggers
        Util.byPassAllTriggers = false;
        
        Map<Id, Membership__c> mapOldMemberships;
        Map<Id, Membership__c> newMembershipMap = new Map<Id, Membership__c>();
        newMembershipMap.put(membershipList[0].Id,membershipList[0]);
        newMembershipMap.put(membershipList[1].Id,membershipList[1]);
        
        MembershipTriggerHelper.updateCurrentYearFees(newMembershipMap,mapOldMemberships);
        
        //test starts here
        test.startTest();
        List<SBQQ__Subscription__c> compSubscriptions = [Select Id,Customer_Amount__c,SBQQ__Product__c,SBQQ__Product__r.Name from SBQQ__Subscription__c where recordTypeId =: constants.RECORD_TYPE_ID_SUBSCRIPTION_COMPONENT];
        List<membership__c> memberships = [Select Id, Current_Year_Travel_Fee__c,Current_Year_Annual_Fee__c  from membership__c ];
        
        System.assertEquals(200 , memberships[0].Current_Year_Travel_Fee__c);
        System.assertEquals(200 , memberships[0].Current_Year_Annual_Fee__c);
        System.assertEquals(200, memberships[1].Current_Year_Annual_Fee__c);
        System.assertEquals(200 , memberships[1].Current_Year_Annual_Fee__c);
        
        //Test Ends Here
        test.stopTest();
        
    }
}