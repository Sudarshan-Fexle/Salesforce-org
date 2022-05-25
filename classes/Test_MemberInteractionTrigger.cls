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
private class Test_MemberInteractionTrigger {
/**
*   Purpose         :   This class is test class for Trigger on Member Interactions.
*
*   Create By       :   Bhavi Sharma
*
*   Created Date    :   06/13/2013
*
*   Current Version :   v1.0
*
*   Revision Logs   :   v1.0 - Created - CR-20130228-2612
*                       v1.1 - Modified By -Abhinav Sharma - 04/18/2014 - CR-20130730-3316
*                       V1.2 - Modified By - Mahendra Swarnkar - CR-20160610-9915 - 08/27/2016 - Added new method "testUpdateDateOfFirstELOnWarmLead"
**/
	
	//Commented of_els_sent__c - By Mahendra Swarnkar - spring clean up - 04/29/2019
    /*static testMethod void testPopulateMemberInteractionData() {
        
        Util.BypassAllTriggers = True;
        
        // get one record type name
        List<Id> recordTypes = new List<Id>();
        recordTypes.add(Util.RecordTypeId('Call__c',Constants.RECORD_TYPE_MEMBER_INTERACTION_QA_CALL));
        recordTypes.add(Util.RecordTypeId('Contact',Constants.RECORD_TYPE_CONTACT_NAME_EMPLOYEE));
        
        System.assertEquals(2,recordTypes.size());
        
        //insert account
        Account acc = new Account(Name = 'TestAcc', Account_Formal_Name__c = 'TestAcc');
        insert acc;
        
        //insert Contact
        Contact contact = new Contact(LastName = 'TestCon', AccountId = acc.Id, Employee_ID__c = 'abc', RecordTypeId = recordTypes[1]);
        insert contact;
        
        // create the opportunity
        Opportunity opp = testUtilities.CreateNewOpportunity(true);
        
        //Program__c prog = [select id from Program__c limit 1];
        Program__c prog = new Program__c(Name = 'TestProg', Program_Acronym__c = 'TEST', Status__c = 'Active', Create_Memberships__c = 'Yes');
        insert prog;
        
        //Create membership data
        Membership__c mem = new Membership__c(Account_Name__c = acc.id, Program__c = prog.id);
        insert mem;
        
        //Create a Project record
        Project__c project = new Project__c(Name = 'Test', Institution__c = acc.Id, Primary_Paid_Membership__c = mem.Id);
        insert project;
        
        //Create a memberInteraction
        Call__c memberInteraction = new Call__c(Call_Brief_Notes__c = 'test description', Call_Date__c = Date.today(), Current_Status__c = 'Completed',
                                                    Call_Type__c = 'Kickoff', Member__c = project.Id, Senior_Member_On_Call__c = contact.Id,
                                                    Opportunity__c = opp.Id);
        
        //start test here
        Test.startTest();
        
        Util.BypassAllTriggers = false;
        
        //insert member interaction
        insert memberInteraction;
        
        //Query data to assert the results
        memberInteraction = [SELECT Membership__c, Institution__c FROM Call__c WHERE Id =: memberInteraction.Id];
        
        //assert statements
        System.assertEquals(project.Primary_Paid_Membership__c, memberInteraction.Membership__c);
        System.assertEquals(mem.Account_Name__c, memberInteraction.Institution__c);
        
        //Opportunity
        /*opp = [Select of_ELs_Sent__c from Opportunity where Id =: opp.Id];
        System.assertEquals(null, opp.of_ELs_Sent__c);
        *
        
        //Bypassing triggers
        Util.BypassAllTriggers = false;
        
        //Update status to cancel
        memberInteraction.Current_Status__c = Constants.MEMBER_INTERACTION_CURRENT_STATUS_COMPLETED;
        update memberInteraction;
        
        //Opportunity
        /*opp = [Select of_ELs_Sent__c from Opportunity where Id =: opp.Id];
        System.assertEquals(1, opp.of_ELs_Sent__c);
        *
        
        //Bypassing triggers
        Util.BypassAllTriggers = false;
        
        //Update status to cancel
        memberInteraction.Opportunity__c = null;
        update memberInteraction;
        
        //Opportunity
        /*opp = [Select of_ELs_Sent__c from Opportunity where Id =: opp.Id];
        System.assertEquals(0, opp.of_ELs_Sent__c);
        *
        //Bypassing triggers
        Util.BypassAllTriggers = false;
        
        //Update status to cancel
        memberInteraction.Opportunity__c = opp.Id;
        update memberInteraction;
        
        //Opportunity
        /*opp = [Select of_ELs_Sent__c from Opportunity where Id =: opp.Id];
        System.assertEquals(1, opp.of_ELs_Sent__c);
        *
        //Bypassing triggers
        Util.BypassAllTriggers = false;
        
        //delete
        delete memberInteraction;
        
        //Opportunity
        /*opp = [Select of_ELs_Sent__c from Opportunity where Id =: opp.Id];
        System.assertEquals(0, opp.of_ELs_Sent__c);
        *
        //stop test here
        Test.stopTest();
    }
    
    
    //Added By - Abhinav Sharma - 04/18/2014 - CR-20130730-3316
    static testMethod void ValidateAndPopulateDataOnInteratcionRecords() {
    
        //By passing Dupeblocker
        Util.IsTest(true);
        
        //Bypassing all the trigger when creating test data
        Util.BypassAllTriggers = True;
        
        //Insert account
        Account acc = new Account(Name = 'TestAcc', Account_Formal_Name__c = 'TestAcc');
        insert acc;
        
        //Get one record type name
        List<Id> recordTypes = new List<Id>();
        recordTypes.add(Util.RecordTypeId('Call__c',Constants.RECORD_TYPE_MEMBER_INTERACTION_QA_CALL));
        recordTypes.add(Util.RecordTypeId('Contact',Constants.RECORD_TYPE_CONTACT_NAME_EMPLOYEE));
        System.assertEquals(2,recordTypes.size());
        
        //Insert Contact
        Contact contact = new Contact(LastName = 'TestCon', AccountId = acc.Id, Employee_ID__c = 'abc', RecordTypeId = recordTypes[1]);
        insert contact;
        
        //Create the opportunity
        Opportunity opp = testUtilities.CreateNewOpportunity(true);
        
        //Insert Program
        Program__c prog = new Program__c(Name = 'TestProg', Program_Acronym__c = 'TEST', Status__c = 'Active', Create_Memberships__c = 'Yes');
        insert prog;
        
        //Create membership data
        Membership__c mem = new Membership__c(Account_Name__c = acc.id, Program__c = prog.id);
        insert mem;
        
        //Create a Project record
        Project__c project = new Project__c(Name = 'Test', Institution__c = acc.Id, Primary_Paid_Membership__c = mem.Id);
        insert project;
        
        //List to hold the Member Interactions records
        List<Call__c> memberInteractions = new List<Call__c>();
        
        //Create member Interaction records
        Call__c memberInteraction_1 = new Call__c(Call_Brief_Notes__c = 'Test description 1', Call_Date__c = System.today(),
                                                  Call_Type__c = 'Kickoff', Member__c = project.Id, Senior_Member_On_Call__c = contact.Id,
                                                  Opportunity__c = opp.Id);
        Call__c memberInteraction_2 = new Call__c(Call_Brief_Notes__c = 'Test description 2', Current_Status__c = 'Completed',
                                                  Call_Type__c = 'Kickoff', Member__c = project.Id, Senior_Member_On_Call__c = contact.Id,
                                                  Opportunity__c = opp.Id);
        Call__c memberInteraction_3 = new Call__c(Call_Brief_Notes__c = 'Test description 3', Call_Date__c = System.today().addDays(-200), Current_Status__c = 'Completed',
                                                  Call_Type__c = 'Kickoff', Member__c = project.Id, Senior_Member_On_Call__c = contact.Id,
                                                  Opportunity__c = opp.Id);
        Call__c memberInteraction_4 = new Call__c(Call_Brief_Notes__c = 'Test description 4', Call_Date__c = System.today().addDays(-365), Current_Status__c = 'Cancelled',
                                                  Call_Type__c = 'Kickoff', Member__c = project.Id, Senior_Member_On_Call__c = contact.Id,
                                                  Opportunity__c = opp.Id);
        Call__c memberInteraction_5 = new Call__c(Call_Brief_Notes__c = 'Test description 5', Call_Date__c = System.today().addDays(-366), Current_Status__c = 'Completed',
                                                  Call_Type__c = 'Kickoff', Member__c = project.Id, Senior_Member_On_Call__c = contact.Id,
                                                  Opportunity__c = opp.Id);
        Call__c memberInteraction_6 = new Call__c(Call_Brief_Notes__c = 'Test description 6', Call_Date__c = System.today().addDays(-400), Current_Status__c = 'Void - Delete',
                                                  Call_Type__c = 'Kickoff', Member__c = project.Id, Senior_Member_On_Call__c = contact.Id,
                                                  Opportunity__c = opp.Id);
                                                  
        //Populate list with records
        memberInteractions.add(memberInteraction_1);
        memberInteractions.add(memberInteraction_2);
        memberInteractions.add(memberInteraction_3);
        memberInteractions.add(memberInteraction_4);
        memberInteractions.add(memberInteraction_5);
        memberInteractions.add(memberInteraction_6);
        
        //start test here
        Test.startTest();
        
        //Setting flag value so then trigger can be activated again
        Util.BypassAllTriggers = false;
        
        //Insert member interaction records
        insert memberInteractions;
        
        //Querying for member interaction records details
        memberInteractions = [SELECT ID, Call_Date__c, Date_in_Past_Year_Counter__c FROM Call__c LIMIT 10];
        
        //Assert for the results
        System.assertEquals(6, memberInteractions.size());
        System.assertEquals(1, memberInteractions[0].Date_in_Past_Year_Counter__c);
        System.assertEquals(null, memberInteractions[1].Date_in_Past_Year_Counter__c);
        System.assertEquals(1, memberInteractions[2].Date_in_Past_Year_Counter__c);
        System.assertEquals(null, memberInteractions[3].Date_in_Past_Year_Counter__c);
        System.assertEquals(0, memberInteractions[4].Date_in_Past_Year_Counter__c);
        System.assertEquals(null, memberInteractions[5].Date_in_Past_Year_Counter__c);
        
        //Update the member interaction record with call date field value
        memberInteractions[1].Call_Date__c = System.today().addDays(-300);
        memberInteractions[2].Call_Date__c = System.today().addDays(400);
        memberInteractions[3].Current_Status__c = 'Completed';
        memberInteractions[5].Current_Status__c = 'Completed';
        
        //Update member interatcion list
        update memberInteractions;
        
        //Querying for member interaction records details
        memberInteractions = [SELECT ID, Call_Date__c, Date_in_Past_Year_Counter__c FROM Call__c LIMIT 10];
        
        //Assert for the results
        System.assertEquals(6, memberInteractions.size());
        System.assertEquals(1, memberInteractions[0].Date_in_Past_Year_Counter__c);
        System.assertEquals(1, memberInteractions[1].Date_in_Past_Year_Counter__c);
        System.assertEquals(null, memberInteractions[2].Date_in_Past_Year_Counter__c);
        System.assertEquals(1, memberInteractions[3].Date_in_Past_Year_Counter__c);
        System.assertEquals(0, memberInteractions[4].Date_in_Past_Year_Counter__c);
        System.assertEquals(0, memberInteractions[5].Date_in_Past_Year_Counter__c);
        
        //Stop Test Here
        Test.stopTest();
    }
    
    //Added By - Mahendra Swarnkar - CR-20160610-9915 - 08/27/2016
    static testMethod void testUpdateDateOfFirstELOnWarmLead() {
        
        //By passing Dupeblocker
        Util.IsTest(true);
        
        //Bypassing all the trigger when creating test data
        Util.BypassAllTriggers = true;
        
        //Query to get record type to get Member Interaction record type.
        List<RecordType> rTypes = [SELECT Id FROM RecordType  
                                       WHERE Name =: Constants.MEMBER_INTERACTION_RT_SOUTHWIND
                                       AND sobjectType =: Constants.OBJECT_MEMBER_INTERACTION 
                                       AND IsActive = true]; 
        
        //Assert for result
        System.assert(rTypes.size() > 0);
        
        //Listt to hold custom setting data
       /* List<Recordtype_Setting__c> rTypeCustomSetting = new List<Recordtype_Setting__c>();
        rTypeCustomSetting.add(new Recordtype_Setting__c(Name = Constants.MEMBER_INTERACTION_RT_SOUTHWIND, 
                                                            Name__c = Constants.MEMBER_INTERACTION_RT_SOUTHWIND, 
                                                            SObjectType__c = Constants.OBJECT_MEMBER_INTERACTION, 
                                                            SFID__c = rTypes[0].Id));
        
        //Insert Custom setting record
        insert rTypeCustomSetting;*
        
        //Insert account
        Account acc = new Account(Name = 'TestAcc', Account_Formal_Name__c = 'TestAcc');
        insert acc;
        
        //Insert Contact
        Contact contact = new Contact(LastName = 'TestCon', AccountId = acc.Id, Employee_ID__c = 'abc', Email = 'Test'+Math.random()+'@eab.com', 
		Title = 'Test', Phone = '614-555-8855');
        insert contact;
        
        //Insert Program
        Program__c prog = new Program__c(Name = 'TestProg', Program_Acronym__c = 'TEST', Status__c = 'Active', Create_Memberships__c = 'Yes');
        insert prog;    
        
        //List to hold the Opportunity records
        List<Opportunity> opportunities = new List<Opportunity>();
        
        //Added Opportunity records in list
        opportunities.add(new Opportunity(AccountId = acc.Id, Program__c = prog.Id, Name = 'Test1', StageName = '0-Exploring', pool_Month__c = '1',
                                          CloseDate = System.today().addDays(7), Pool_Year__c = String.valueOf(Date.Today().Year()),
                                          Decision_Type__c = 'Need New LOA 1', Previous_Year_Negotiated_Adjustment__c = 4000));

        opportunities.add(new Opportunity(AccountId = acc.Id, Program__c = prog.Id, Name = 'Test2', StageName = '0-Exploring', pool_Month__c = '1',
                                          CloseDate = System.today().addDays(7), Pool_Year__c = String.valueOf(Date.Today().Year()),
                                          Decision_Type__c = 'Need New LOA 2', Previous_Year_Negotiated_Adjustment__c = 5000));
        
        //Insert
        insert opportunities;
        
        //Create membership data
        Membership__c mem = new Membership__c(Account_Name__c = acc.id, Program__c = prog.id);
        insert mem;
        
        //Create a Project record
        Project__c project = new Project__c(Name = 'Test', Institution__c = acc.Id, Primary_Paid_Membership__c = mem.Id);
        insert project;
        
        //List to hold the Warm Lead records
        List<Warm_Lead__c> warmLeads = new List<Warm_Lead__c>();
        
        warmLeads.add(new Warm_Lead__c(Name = 'Direct to Visit', Account__c = acc.Id, Primary_Program__c = prog.Id, Lead_Channel__c = 'Direct to Visit', 
                                       Lead_Date__c = system.today(), Grade__c = '1', Contact__c = contact.Id));
        
        warmLeads.add(new Warm_Lead__c(Name = 'Direct to Visit2', Account__c = acc.Id, Primary_Program__c = prog.Id, Lead_Channel__c = 'Direct to Visit', 
                                       Lead_Date__c = system.today(), Grade__c = '1', Contact__c = contact.Id));
        
        warmLeads.add(new Warm_Lead__c(Name = 'Direct to Visit3', Account__c = acc.Id, Primary_Program__c = prog.Id, Lead_Channel__c = 'Direct to Visit', 
                                       Lead_Date__c = system.today(), Grade__c = '1', Contact__c = contact.Id));
        
        warmLeads.add(new Warm_Lead__c(Name = 'Direct to Visit4', Account__c = acc.Id, Primary_Program__c = prog.Id, Lead_Channel__c = 'Direct to Visit', 
                                       Lead_Date__c = system.today(), Grade__c = '1', Contact__c = contact.Id));
        
        //Insert Warm lead records                                          
        insert warmLeads;
        
        //List of Warm Lead MtMs
        List<Warm_Lead_MtM__c> warmLeadMtMs = new List<Warm_Lead_MtM__c>();
        
        warmLeadMtMs.add(new Warm_Lead_MtM__c(Opportunity__c = opportunities[0].Id, Warm_Lead__c = warmLeads[0].Id));
        warmLeadMtMs.add(new Warm_Lead_MtM__c(Opportunity__c = opportunities[0].Id, Warm_Lead__c = warmLeads[1].Id));
        warmLeadMtMs.add(new Warm_Lead_MtM__c(Opportunity__c = opportunities[1].Id, Warm_Lead__c = warmLeads[2].Id));
        warmLeadMtMs.add(new Warm_Lead_MtM__c(Opportunity__c = opportunities[1].Id, Warm_Lead__c = warmLeads[3].Id));
        
        insert warmLeadMtMs;                                                           
         
        //List to hold the Member Interactions records
        List<Call__c> memberInteractions = new List<Call__c>();
        
        //Create member Interaction records
        memberInteractions.add(new Call__c(Call_Brief_Notes__c = 'Test description 1', Call_Date__c = System.today(),Number_of_Confirmed_Attendees__c = 'Note 1',
                                                  Call_Type__c = 'Kickoff', Member__c = project.Id, Senior_Member_On_Call__c = contact.Id,
                                                  Opportunity__c = opportunities[0].Id, recordTypeId = '012C0000000USTj', 
                                                  Completion_Date__c = System.Today()));
        
        memberInteractions.add(new Call__c(Call_Brief_Notes__c = 'Test description 2', Call_Date__c = System.today(),Number_of_Confirmed_Attendees__c = 'Note 2',
                                                  Call_Type__c = 'Kickoff', Member__c = project.Id, Senior_Member_On_Call__c = contact.Id,
                                                  Opportunity__c = opportunities[0].Id, recordTypeId = '012C0000000USTj', 
                                                  Completion_Date__c = System.Today().addDays(1)));
        
        memberInteractions.add(new Call__c(Call_Brief_Notes__c = 'Test description 3', Call_Date__c = System.today(),Number_of_Confirmed_Attendees__c = 'Note 3',
                                                  Call_Type__c = 'Kickoff', Member__c = project.Id, Senior_Member_On_Call__c = contact.Id,
                                                  Opportunity__c = opportunities[1].Id, recordTypeId = '012C0000000USTj', 
                                                  Completion_Date__c = System.Today().addDays(10)));
        
        memberInteractions.add(new Call__c(Call_Brief_Notes__c = 'Test description 4', Call_Date__c = System.today(),Number_of_Confirmed_Attendees__c = 'Note 4',
                                                  Call_Type__c = 'Kickoff', Member__c = project.Id, Senior_Member_On_Call__c = contact.Id,
                                                  Opportunity__c = opportunities[1].Id, recordTypeId = '012C0000000USTj', 
                                                  Completion_Date__c = System.Today().addDays(15)));
        
        //Stop Test Here
        Test.startTest();
        
        //Enabling triggers
        Util.BypassAllTriggers = false;
        
        //Insert Member Intraction records (Testing of insert use case)
        insert memberInteractions;
        
        //Query over Warm Lead Records
        List<Warm_Lead__c> warmLeadRetriveList = [SELECT Id, Name, Date_Of_First_EL__c 
                                                    FROM Warm_Lead__c 
                                                    WHERE Date_Of_First_EL__c != null ORDER BY Name ASC];
        
        //Assert for result
        System.assert(warmLeadRetriveList != null);
        System.assertEquals(4, warmLeadRetriveList.size());
        System.assertEquals(System.Today(), warmLeadRetriveList[0].Date_Of_First_EL__c);
        System.assertEquals(System.Today(), warmLeadRetriveList[1].Date_Of_First_EL__c);
        System.assertEquals(System.Today().addDays(10), warmLeadRetriveList[2].Date_Of_First_EL__c);
        System.assertEquals(System.Today().addDays(10), warmLeadRetriveList[3].Date_Of_First_EL__c);
       
        //Testing of Completion Date update based use case
        //Update Date value to check update case
        memberInteractions[0].Completion_Date__c = System.Today().addDays(5);
        memberInteractions[2].Completion_Date__c = System.Today().addDays(20);
        update memberInteractions;
        
        //Query over Warm Lead Records
        warmLeadRetriveList = [SELECT Id, Name, Date_Of_First_EL__c 
                                FROM Warm_Lead__c 
                                WHERE Date_Of_First_EL__c != null ORDER BY Name ASC];
        
        //Assert for result
        System.assert(warmLeadRetriveList != null);
        System.assertEquals(4, warmLeadRetriveList.size());
        System.assertEquals(System.Today().addDays(1), warmLeadRetriveList[0].Date_Of_First_EL__c);
        System.assertEquals(System.Today().addDays(1), warmLeadRetriveList[1].Date_Of_First_EL__c);
        System.assertEquals(System.Today().addDays(15), warmLeadRetriveList[2].Date_Of_First_EL__c);
        System.assertEquals(System.Today().addDays(15), warmLeadRetriveList[3].Date_Of_First_EL__c);
        
        //List to hold the Member Interactions records
        List<Call__c> memberInteractionsToBeDeleted = new List<Call__c>();
        
        //Populating collection with the records
        memberInteractionsToBeDeleted.add(memberInteractions[1]);
        memberInteractionsToBeDeleted.add(memberInteractions[3]);
        
        //Testing of delete use cases
        //Delete Records to check delete case
        delete memberInteractionsToBeDeleted;
        
        //Retrive Werm lead records
        warmLeadRetriveList = [SELECT Id, Name, Date_Of_First_EL__c 
                                FROM  Warm_Lead__c 
                                WHERE Date_Of_First_EL__c != null ORDER BY Name ASC];
        
        //Assert for result
        System.assert(warmLeadRetriveList != null);
        System.assertEquals(4, warmLeadRetriveList.size());
        System.assertEquals(System.Today().addDays(5), warmLeadRetriveList[0].Date_Of_First_EL__c);
        System.assertEquals(System.Today().addDays(5), warmLeadRetriveList[1].Date_Of_First_EL__c);
        System.assertEquals(System.Today().addDays(20), warmLeadRetriveList[2].Date_Of_First_EL__c);
        System.assertEquals(System.Today().addDays(20), warmLeadRetriveList[3].Date_Of_First_EL__c);
        
        //Retrive Mi Records
        List<Call__c> miRetriveRecords = [Select Id, Completion_Date__c, Number_of_Confirmed_Attendees__c, Name 
                                            From Call__c 
                                            ORDER BY Number_of_Confirmed_Attendees__c ASC];
        
        //Assert for result
        System.assert(miRetriveRecords != null);
        System.assertEquals(2, miRetriveRecords.size());
        
        //testing of opoortunity change based use cases
        //Update Date value to check update case
        miRetriveRecords[0].Opportunity__c = opportunities[1].Id;
        miRetriveRecords[1].Opportunity__c = opportunities[0].Id;
        update miRetriveRecords;
        
        //Retrive Werm lead records
        warmLeadRetriveList = [SELECT Id, Name, Date_Of_First_EL__c 
                                    FROM Warm_Lead__c 
                                    WHERE Date_Of_First_EL__c != null ORDER BY Name ASC];
        
        //Assert for result
        System.assert(warmLeadRetriveList != null);
        System.assertEquals(4, warmLeadRetriveList.size());
        System.assertEquals(System.Today().addDays(20), warmLeadRetriveList[0].Date_Of_First_EL__c);
        System.assertEquals(System.Today().addDays(20), warmLeadRetriveList[1].Date_Of_First_EL__c);
        System.assertEquals(System.Today().addDays(5), warmLeadRetriveList[2].Date_Of_First_EL__c);
        System.assertEquals(System.Today().addDays(5), warmLeadRetriveList[3].Date_Of_First_EL__c);
        
        //Stop Test Here
        Test.stopTest();
        
        //testing of opoortunity change based use case 2
        //Update Opportunity value to check update case
        miRetriveRecords[0].Opportunity__c = null;
        miRetriveRecords[1].Opportunity__c = null;
        update miRetriveRecords;
        
        //Retrive Werm lead records
        warmLeadRetriveList = [SELECT Id, Name, Date_Of_First_EL__c FROM Warm_Lead__c 
                                    WHERE Date_Of_First_EL__c != null ORDER BY Name ASC];
        
        //Assert for result
        System.assert(warmLeadRetriveList != null);
        System.assertEquals(0, warmLeadRetriveList.size());
    }*/
}