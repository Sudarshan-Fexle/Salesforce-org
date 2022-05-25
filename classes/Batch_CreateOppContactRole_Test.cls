/**
 *  Description     :   test class for the Batch_CreateOppContactRole. 
 *
 *  Created By      :   Mahindra
 *
 *  Created Date    :   02/21/2020
 *
 *  Revision Logs   :   V_1.0 - Created - Mahindra - CR-20200121-13645
 *		    :   V_1.1 - Modified By - Neha sharma - CR-20201110-14683 - add the Sales_Pursuit_Products__c 
 *                  :   V_1.2 - Modified By - Abhishek Mishra - CR-20210517-15149 - 05/31/2021 - To increase code coverage
 * 		    :   V_1.3 - Modified By - Shalu Sharma - CR-20210517-15151 - 07/09/2021 - Updated method "testOpportunityEntityOverride4" to fix System.LimitException: Too many SOQL queries: 101 error
 *                  :   V_1.4 - Modified By - Chirag Soni - CR-20210927-15464 - 09/28/2021 - Removed the 'Research' picklist value referece and updated to 'APS'
 *                      
 **/
@isTest(seeAllData=false)
private class Batch_CreateOppContactRole_Test {
    
    //Added By Abhishek Mishra - CR-20210517-15149 - 05/31/2021  
    @testSetup static void testSetupData(){

        Account acc = new Account();
        acc.Name = 'Test' ;
        insert acc;
        
        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(AccountId = acc.id,LastName = 'Test1', FirstName = 'Con', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855')); 
        contacts.add(new Contact(AccountId = acc.id,LastName = 'Test2', FirstName = 'Con', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855'));     
        contacts.add(new Contact(LastName = 'Test3', FirstName = 'Con', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855'));
        insert contacts;

    }

    
    static testmethod void testOpportunityEntityOverride() {
    	//Modify By Mahendra Swarnakar - CR-20200218-13783
        Account acc = new Account();
        acc.Name = 'Test' ;
        insert acc;
        
        List<Contact> contacts = new List<Contact>();
        Contact contact_1 = new Contact(AccountId = acc.id,LastName = 'Test', FirstName = 'Con', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855');
        contacts.add(contact_1); 
        Contact contact_2 = new Contact(AccountId = acc.id,LastName = 'Testtesting', FirstName = 'ConTest', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855');
        contacts.add(contact_2);     
        Contact contact_3 = new Contact(LastName = 'TesttestingTest', FirstName = 'ConTestTest', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855');
        contacts.add(contact_3);
        insert contacts;
        
        Test.startTest();
        //Modify By Mahendra Swarnakar - CR-20200218-13783
        Opportunity opp = TestUtilities.CreateNewOpportunity(false);
        opp.RecordTypeId = OpportunityTriggerHelper.OPPORTUNITY_ROYALL_RT_ID;
        opp.Name = 'test';
        opp.AccountId = acc.id;
        opp.Main_Contact__c = contacts[0].Id;
        //Modify By - Neha sharma - CR-20201110-14683 - add the Sales_Pursuit_Products__c 
        //Modify By - Chirag Soni - CR-20210927-15464 - 09/28/2021 - Removed the 'Research' picklist value referece and updated to 'APS'
        opp.Sales_Pursuit_Products__c  = 'APS';
        insert opp;
        
        List<Warm_Lead__c> warmLeads = new List<Warm_Lead__c>();

        Warm_Lead__c warmLead = new Warm_Lead__c();
        warmLead.Name = 'Test';
        warmLead.Contact__c = contacts[0].Id;
        warmLead.Opportunity__c = opp.Id;
        warmLeads.add(warmLead);

        // Added By Abhishek Mishra - CR-20210517-15149 - 05/31/2021
        warmLeads.add(new Warm_Lead__c(Name = 'Test1',Contact__c = contacts[1].Id,Opportunity__c = opp.Id));

        insert warmLeads;

        List<Warm_Lead_MtM__c> wLeadmtm = new List<Warm_Lead_MtM__c>();
        wLeadmtm.add(new Warm_Lead_MtM__c(Warm_Lead__c = warmLeads[0].Id,Opportunity__c = opp.Id));
        wLeadmtm.add(new Warm_Lead_MtM__c(Warm_Lead__c = warmLeads[1].Id,Opportunity__c = opp.Id));

        insert wLeadmtm;
        // Added By Abhishek Mishra - CR-20210517-15149 - 05/31/2021 -- end

	Batch_CreateOppContactRole batch = new Batch_CreateOppContactRole(1);
        Database.executeBatch(batch, 10); 

        Test.stopTest(); 
        // Added By Abhishek Mishra - 05/31/2021
        List<Warm_Lead_MtM__c> wrmLeadmtm = [Select Id,Warm_Lead__c,Opportunity__c,Name,Warm_Lead__r.Name From Warm_Lead_MtM__c ORDER BY Warm_Lead__r.Name ASC];
        List<OpportunityContactRole> oppConRole = [Select Id,Source_Record_Name__c,Role,Source_Record_Id__c,ContactId,OpportunityId FROM OpportunityContactRole ORDER BY Source_Record_Name__c ASC];
        System.assertEquals(2, oppConRole.size());
        System.assertEquals(oppConRole[0].Source_Record_Name__c, wrmLeadmtm[0].Warm_Lead__r.Name);
        System.assertEquals(oppConRole[1].Source_Record_Name__c, wrmLeadmtm[1].Warm_Lead__r.Name);
        System.assertEquals(oppConRole[0].Source_Record_Id__c, String.valueOf(wrmLeadmtm[0].Warm_Lead__c));
        System.assertEquals(oppConRole[1].Source_Record_Id__c, String.valueOf(wrmLeadmtm[1].Warm_Lead__c));
        // Added By Abhishek Mishra - 05/31/2021 -- end   
    }
    
    // Added By Abhishek Mishra - CR-20210517-15149 - 05/31/2021
    static testmethod void testOpportunityEntityOverride1() {

    	Account acc = [Select Id From Account];
        
        List<Contact> contactss = [Select Id,AccountId,Name,Email,Title,Phone From Contact ORDER BY Name ASC];
        System.assertEquals(3, contactss.size());

        //Test start
        Test.startTest();
        
        List<Opportunity> oppList = new List<Opportunity>();
        
        //creating opportunity
        Opportunity opp = TestUtilities.CreateNewOpportunity(false);
        opp.RecordTypeId = OpportunityTriggerHelper.OPPORTUNITY_ROYALL_RT_ID;
        opp.Name = 'test';
        opp.AccountId = acc.id;
        opp.Main_Contact__c = contactss[0].Id;
        //Modify By - Chirag Soni - CR-20210927-15464 - 09/28/2021 - Removed the 'Research' picklist value referece and updated to 'APS'
        opp.Sales_Pursuit_Products__c  = 'APS';

        //creating 2nd opportunity
        Opportunity opp1 = TestUtilities.CreateNewOpportunity(false);
        opp1.RecordTypeId = OpportunityTriggerHelper.OPPORTUNITY_ROYALL_RT_ID;
        opp1.Name = 'test';
        opp1.AccountId = acc.id;
        opp1.Main_Contact__c = contactss[1].Id;
        //Modify By - Chirag Soni - CR-20210927-15464 - 09/28/2021 - Removed the 'Research' picklist value referece and updated to 'APS'
        opp1.Sales_Pursuit_Products__c  = 'APS';

        oppList.add(opp);
        oppList.add(opp1);
        insert oppList;
        System.assertEquals(2, oppList.size());

        //Creating the KeyPlayersInfluncers data
        List<Key_Players_Influencers__c> keyPlayersInfluencers = new List<Key_Players_Influencers__c>();
        keyPlayersInfluencers.add(new Key_Players_Influencers__c (Name__c  = contactss[0].Id,Opportunity__c = oppList[0].Id));
        keyPlayersInfluencers.add(new Key_Players_Influencers__c (Name__c  = contactss[1].Id,Opportunity__c = oppList[1].Id));

        insert keyPlayersInfluencers;
        System.assertEquals(2, keyPlayersInfluencers.size());

	Batch_CreateOppContactRole batch = new Batch_CreateOppContactRole(2);
        Database.executeBatch(batch, 10); 
        //Test stop
        Test.stopTest();
        
        List<OpportunityContactRole> oppConRole = [Select Id,Source_Record_Name__c,Role,Source_Record_Id__c,ContactId,OpportunityId FROM OpportunityContactRole ORDER BY Source_Record_Name__c ASC];
        List<Key_Players_Influencers__c> buyer321 = [Select Id,Name,Name__c,Opportunity__c From Key_Players_Influencers__c ORDER BY Name ASC];
        System.assertEquals(2, oppConRole.size());
        System.assertEquals(oppConRole[0].Source_Record_Name__c, buyer321[0].Name);
        System.assertEquals(oppConRole[1].Source_Record_Name__c, buyer321[1].Name);
        System.assertEquals(oppConRole[0].Source_Record_Id__c, buyer321[0].Id);
        System.assertEquals(oppConRole[1].Source_Record_Id__c, buyer321[1].Id);
    }
    
    // Added By Abhishek Mishra - CR-20210517-15149 - 05/31/2021
    static testmethod void testOpportunityEntityOverride2() {
    	
        Account acc = [Select Id From Account];
        
        List<Contact> contactss = [Select Id,AccountId,Name,Email,Title,Phone From Contact ORDER BY Name ASC];
        System.assertEquals(3, contactss.size());

        //Start Test
        Test.startTest();
        List<Opportunity> oppList = new List<Opportunity>();
        //creating opportunity
        Opportunity opp = TestUtilities.CreateNewOpportunity(false);
        opp.RecordTypeId = OpportunityTriggerHelper.OPPORTUNITY_ROYALL_RT_ID;
        opp.Name = 'test';
        opp.AccountId = acc.id;
        opp.Main_Contact__c = contactss[0].Id;
        //Modify By - Chirag Soni - CR-20210927-15464 - 09/28/2021 - Removed the 'Research' picklist value referece and updated to 'APS'
        opp.Sales_Pursuit_Products__c  = 'APS';

        //creating 2nd opportunity
        Opportunity opp1 = TestUtilities.CreateNewOpportunity(false);
        opp1.RecordTypeId = OpportunityTriggerHelper.OPPORTUNITY_ROYALL_RT_ID;
        opp1.Name = 'test';
        opp1.AccountId = acc.id;
        opp1.Main_Contact__c = contactss[1].Id;
        //Modify By - Chirag Soni - CR-20210927-15464 - 09/28/2021 - Removed the 'Research' picklist value referece and updated to 'APS'
        opp1.Sales_Pursuit_Products__c  = 'APS';

        oppList.add(opp);
        oppList.add(opp1);
        insert oppList;
        System.assertEquals(2, oppList.size());
        //Creating Event data
        List<Event> eventList = new List<Event>();
        eventList.add(new Event(WhoId = contactss[0].Id,WhatId =  oppList[0].Id,Subject = 'Meeting',Type = 'Enrollment Services',
                                StartDateTime = System.Today(),EndDateTime = System.Today() + 1,DurationInMinutes = 1440));
        eventList.add(new Event(WhoId = contactss[1].Id,WhatId =  oppList[1].Id,Subject = 'Meeting',Type = 'Enrollment Services',
                                StartDateTime = System.Today(),EndDateTime = System.Today() + 1,DurationInMinutes = 1440));
       
        //To by pass all the triggers
        Util.byPassAllTriggers = true;
        //inserting the Event List
        insert  eventList;
        Util.byPassAllTriggers = false;
        System.assertEquals(2, eventList.size());
        
	    Batch_CreateOppContactRole batch = new Batch_CreateOppContactRole(3);
        Database.executeBatch(batch, 10); 

        //Stop Test
        Test.stopTest();
        List<OpportunityContactRole> oppConRole = [Select Id,Source_Record_Name__c,Role,Source_Record_Id__c,ContactId,OpportunityId FROM OpportunityContactRole ORDER BY Source_Record_Name__c ASC];
        List<Event> evntList = [Select Id,WhoId,WhatId,Subject From Event ORDER BY Subject ASC];
        System.assertEquals(2, evntList.size());
        System.assertEquals(2, oppConRole.size());
        System.assertEquals(oppConRole[0].Source_Record_Name__c, evntList[0].Subject);
        System.assertEquals(oppConRole[1].Source_Record_Name__c, evntList[1].Subject);
        System.assertEquals(oppConRole[0].Source_Record_Id__c, evntList[0].Id);
        System.assertEquals(oppConRole[1].Source_Record_Id__c, evntList[1].Id);
   
    }
    
    // Added By Abhishek Mishra - CR-20210517-15149 - 05/31/2021
    // Modified By - Shalu Sharma - CR-20210517-15151 - 07/09/2021 - To fix System.LimitException: Too many SOQL queries: 101 error
    static testmethod void testOpportunityEntityOverride4() 
    {
        Util.bypassAllTriggers = true;
        
        Account acc = [Select Id From Account];
        
        List<Contact> contactss = [Select Id, AccountId, Name, Email, Title, Phone From Contact ORDER BY Name ASC];
        System.assertEquals(3, contactss.size());
        
        List<Opportunity> oppList = new List<Opportunity>();
        //creating opportunity
        Opportunity opp = TestUtilities.CreateNewOpportunity(false);
        opp.RecordTypeId = OpportunityTriggerHelper.OPPORTUNITY_ROYALL_RT_ID;
        opp.Name = 'test';
        opp.AccountId = acc.id;
        opp.Main_Contact__c = contactss[0].Id;
        //Modify By - Chirag Soni - CR-20210927-15464 - 09/28/2021 - Removed the 'Research' picklist value referece and updated to 'APS'
        opp.Sales_Pursuit_Products__c  = 'APS';

        //creating 2nd opportunity
        Opportunity opp1 = TestUtilities.CreateNewOpportunity(false);
        opp1.RecordTypeId = OpportunityTriggerHelper.OPPORTUNITY_ROYALL_RT_ID;
        opp1.Name = 'test';
        opp1.AccountId = acc.id;
        opp1.Main_Contact__c = contactss[1].Id;
        //Modify By - Chirag Soni - CR-20210927-15464 - 09/28/2021 - Removed the 'Research' picklist value referece and updated to 'APS'
        opp1.Sales_Pursuit_Products__c  = 'APS';
                                                        
        oppList.add(opp);
        oppList.add(opp1); 
        insert oppList;
        System.assertEquals(2,oppList.size());

        //Creating Proposal data
        List<SBQQ__Quote__c> proposals = new List<SBQQ__Quote__c>();
        proposals.add(new SBQQ__Quote__c(SBQQ__PrimaryContact__c = contactss[0].Id,SBQQ__Opportunity2__c =  oppList[0].Id));
        proposals.add(new SBQQ__Quote__c(SBQQ__PrimaryContact__c = contactss[1].Id,SBQQ__Opportunity2__c =  oppList[1].Id));

        insert proposals;
        System.assertEquals(2, proposals.size());
        
        Util.bypassAllTriggers = false;
        
	//Start Test
        Test.startTest();
        
	Batch_CreateOppContactRole batch = new Batch_CreateOppContactRole(5);
        Database.executeBatch(batch, 10); 
        
        //Stop Test
        Test.stopTest();

        List<OpportunityContactRole> oppConRole = [Select Id,Source_Record_Name__c,Role,Source_Record_Id__c,ContactId,OpportunityId FROM OpportunityContactRole ORDER BY Source_Record_Name__c ASC];
        List<SBQQ__Quote__c> proposal = [Select Id,Name,SBQQ__PrimaryContact__c,SBQQ__Opportunity2__c From SBQQ__Quote__c ORDER BY Name ASC];
        System.assertEquals(2, proposal.size());
        System.assertEquals(2, oppConRole.size());
        System.assertEquals(oppConRole[0].Source_Record_Name__c, proposal[0].Name);
        System.assertEquals(oppConRole[1].Source_Record_Name__c, proposal[1].Name);
        System.assertEquals(oppConRole[0].Source_Record_Id__c, proposal[0].Id);
        System.assertEquals(oppConRole[1].Source_Record_Id__c, proposal[1].Id);
    }
}