@isTest
public class Test_VVSCustomHelper {
    
    //Test #1 - Test our Type Field is populated on our two records based on Record Type
    static testmethod void testRunVVSLogic_Test1() {
        
        Util.byPassAllTriggers = true;
        // Modified By - Rajeev Jain - 05Aug2020 - CR-20200218-13783
        Account acc = TestUtilities.CreateNewAccount(true);
        
        //Create a Contact
        Contact c = TestUtilities.CreateNewContact(false);
        c.Title = 'I AM IRON MAN';
        c.AccountId = acc.id;
        insert c;
        
        //create an EAB Initiating Opportunity
        Opportunity o = TestUtilities.CreateNewOpportunity(false);
        o.RecordTypeId = CPQConstants.OPP_RT_ID_EAB_INITIATING;
        o.StageName = '0-Exploring';
        o.Marketing_Manager_Comments__c = 'Test 1 EAB Initiating';
        o.Main_Contact__c = c.Id;
        o.CloseDate = System.today().addMonths(1);
        o.AccountId = acc.Id;
        
        //create an EAB Continuing Opportunity
        Opportunity o2 = TestUtilities.CreateNewOpportunity(false);
        o2.RecordTypeId = CPQConstants.OPP_RT_ID_EAB_CONTINUING;
        o2.Previous_Opportunity__c = o.Id;
        o2.StageName = '0-Exploring';
        o2.Marketing_Manager_Comments__c = 'Test 2 EAB Continuing';
        o2.Main_Contact__c = c.Id;
        o2.AccountId = acc.Id;
        
        //Start our Test
        Test.startTest();
        Util.byPassAllTriggers = false;
        //Insert our Opp Records
        insert o;
        insert o2;
        
        System.debug('@RecordType ID=' + o.RecordTypeId);
        
        //Stop Our Test
        Test.stopTest();
        
        //Query for our Contact
        List<Contact> contacts = [SELECT Id, Name, Title FROM Contact WHERE Title = 'I AM IRON MAN' LIMIT 1];
        
        //Query for our Opportunities
        List<Opportunity> opps = [SELECT Id, Name, Type, Marketing_Manager_Comments__c, Contact__c FROM Opportunity ORDER BY Marketing_Manager_Comments__c];
       
        System.assertEquals('NBB', opps[0].Type);
        System.assertEquals('Existing Client', opps[1].Type);
        
    }
    
    //Test #1 - Test our Opportunity Stage Field is populated according to our logic
    static testmethod void testRunVVSLogic_Test2() {
        
        Util.byPassAllTriggers = true;
        // Modified By - Rajeev Jain - 05Aug2020 - CR-20200218-13783
        Account acc = TestUtilities.CreateNewAccount(true);
        
        // Test Class Fix Start Here 13Feb By: Dipesh Gupta
        //Creating Contact record 
        Contact cont = TestUtilities.CreateNewContact(false);
        cont.AccountId = acc.id;
        insert cont;
        // Test Class Fix End Here 13Feb By: Dipesh Gupta
                
        //create an EAB Initiating Opportunity
        Opportunity opp = TestUtilities.CreateNewOpportunity(false);
        opp.RecordTypeId = CPQConstants.OPP_RT_ID_EAB_INITIATING;
        opp.StageName = '0-Exploring';
        opp.Marketing_Manager_Comments__c = 'Test 1 EAB Initiating';
        opp.Main_Contact__c = cont.Id;
        opp.AccountId = acc.Id;
        
        //create an EAB Continuing Opportunity
        Opportunity o2 = TestUtilities.CreateNewOpportunity(false);
        o2.RecordTypeId = CPQConstants.OPP_RT_ID_EAB_CONTINUING;
        o2.Previous_Opportunity__c = opp.Id;
        o2.StageName = '0-Exploring';
        o2.Marketing_Manager_Comments__c = 'Test 2 EAB Continuing';
        o2.Main_Contact__c = cont.Id;
        o2.AccountId = acc.Id;
        
        //Add our records to the List
        List<Opportunity> oppsList = new List<Opportunity>{opp, o2};
            
        //Start our Test
        Test.startTest();
        
        //Create VVS Data
		Opportunity_Stage__c stg = new Opportunity_Stage__c(Name = 'Dropped', Stage_Number__c = 1);
        insert stg;
		
		Stage_Objective__c obj1 = new Stage_Objective__c(Name = 'Objective 1', Opportunity_Stage__c = stg.Id, Order__c = 1);
		Stage_Objective__c obj2 = new Stage_Objective__c(Name = 'Objective 2', Opportunity_Stage__c = stg.Id, Order__c = 2);
		Stage_Objective__c obj3 = new Stage_Objective__c(Name = 'Objective 3', Opportunity_Stage__c = stg.Id, Order__c = 3);
		List<Stage_Objective__c> objList = new List<Stage_Objective__c>();
		objList.add(obj1);
		objList.add(obj2);
		objList.add(obj3);
		insert objList;
		
		Objective_Action__c act1 = new Objective_Action__c(Name = 'Not Required Action', Order__c = 1, Stage_Objective__c = obj1.Id);
		Objective_Action__c act2 = new Objective_Action__c(Name = 'Required Action', Order__c = 2, Stage_Objective__c = obj2.Id, Action_Type__c = 'Required', Opportunity_Order_Type__c = 'New');
		act2.Opportunity_Record_Type__c = 'Products and Services';
        List<Objective_Action__c> actList = new List<Objective_Action__c>();
		actList.add(act1);
		actList.add(act2);
		insert actList;
        
        Util.byPassAllTriggers = false;
        
        //Insert our Opp Records
        insert oppsList;
        
	//Modified by - Rajeev Jain - 01/15/2021 - Fix for L1 Weekly Release - 1/14/2021 Release
        SBQQ__Quote__c proposal = TestUtilities.createNewSbqqQuote(false);
        proposal.SBQQ__Opportunity2__c = oppsList[0].Id;
        
        insert proposal;
        
        //Assert out Opp Stage field is now null
        System.assertEquals(null, oppsList[0].Opportunity_Stage__c);
        
        //Update our Stage so it matches SP Opp Stage
        oppsList[0].StageName = 'Dropped';
        update oppsList;
        
        //Stop our Test
        Test.stopTest();
        
        //Query for Opp
        List<Opportunity> opps = [SELECT Id, Name, Type, Opportunity_Stage__c, Marketing_Manager_Comments__c FROM Opportunity ORDER BY Marketing_Manager_Comments__c];
        
        //Query for our Stage
        Opportunity_Stage__c oppStage1 = [SELECT Id FROM Opportunity_Stage__c WHERE Name = 'Dropped'];
        
        //Assert they match
        System.assertEquals(oppStage1.Id, opps[0].Opportunity_Stage__c);       
        
    }

}