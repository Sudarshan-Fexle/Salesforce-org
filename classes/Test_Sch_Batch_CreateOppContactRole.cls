/**
 *  Description     :   test class for the Scheduler_Batch_CreateOppContactRole. 
 *
 *  Created By      :   Mahendra
 *
 *  Created Date    :   02/21/2020
 *
 *  Revision Logs   :   V_1.0 - Created - Mahindra - CR-20200121-13645
 *                      
 **/
@isTest(seeAllData=false)
private class Test_Sch_Batch_CreateOppContactRole { 
	static testmethod void testOpportunityEntityOverride() {
        
        // Modified By Rajeev Jain - CR-20200218-13783 - 30July2020 -(Add Account & its fields on contact to Fix the issue)
        Account testAcct1 = new Account(Name='Test Trigger Account1', Account_Formal_Name__c='Test Trigger Account1', Primary_City__c = 'Washington', Primary_State_Province__c = 'DC'); 
        insert testAcct1;
        
        List<Contact> contacts = new List<Contact>();
        Contact contact_1 = new Contact(LastName = 'Test', FirstName = 'Con', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855', AccountId = testAcct1.id);
        contacts.add(contact_1); 
        Contact contact_2 = new Contact(LastName = 'Testtesting', FirstName = 'ConTest', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855', AccountId = testAcct1.id);
        contacts.add(contact_2);     
        Contact contact_3 = new Contact(LastName = 'TesttestingTest', FirstName = 'ConTestTest', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855', AccountId = testAcct1.id);
        contacts.add(contact_3);
        insert contacts;
		
		Test.startTest();
		
        //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
        Opportunity opp = TestUtilities.CreateNewOpportunity(false);
        opp.RecordTypeId = OpportunityTriggerHelper.OPPORTUNITY_ROYALL_RT_ID;
        opp.Name = 'test';
        opp.Main_Contact__c = contacts[0].Id;
        opp.Sales_Pursuit_Products__c = 'APS';
        opp.AccountId = testAcct1.Id; // Modified By Rajeev Jain - 30July2020 -(Account & its fields to Fix the issue)
        insert opp;
        Test.stopTest();
		
        Warm_Lead__c warmLead = new Warm_Lead__c();
        warmLead.Name = 'Test';
        warmLead.Contact__c = contacts[0].Id;
        warmLead.Opportunity__c = opp.Id;
        insert warmLead;
        
		Scheduler_Batch_CreateOppContactRole sch = new Scheduler_Batch_CreateOppContactRole();
		system.schedule('Test Schedule','0 0 0 3 9 ? 2022',sch); 
        
    }
}