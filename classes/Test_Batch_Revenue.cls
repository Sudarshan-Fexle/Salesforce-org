@isTest
public class Test_Batch_Revenue {
    
    static testmethod void testRevenueBatchLogic () {
        
        Util.IsTest(true);
        Util.BypassAllTriggers = true;
        
        //create Test data for Account object as an institute
        Account institute = new Account(Name = 'TestInstitute');
        insert institute;
        
        //Modified By Dipesh Gupta - CR-20190529-13156 - 09/04/2019 - Record type Label Modified From 'SSC' To 'Tech'
        //Getting Record Type Id Value for Project object
        String SSC_Proj_Id = Schema.SObjectType.Project__c.getRecordTypeInfosByName().get('Tech').getRecordTypeId();
        
        //Getting Record Type Id Value for Deployment object
        String SSC_Deploy_Id = Schema.SObjectType.Deployment__c.getRecordTypeInfosByName().get('SSC Navigate Deployment').getRecordTypeId();        
        
        //create new Project__c data
        Project__c project_1 = new Project__c(Name = 'Test-Data1', Institution__c = institute.Id, RecordTypeId = SSC_Proj_Id);
        
        //Make a try to insert the record
        insert project_1;
        
        //Create new Program
        Program__c newProgram = TestUtilities.CreateNewProgram(true);
        
        //Deployment Type record
        Deployment_Type__c deployType = new Deployment_Type__c(Name = 'Test-Deploy-type', Sign_Off_to_Move_to_Prod_Lag__c = 10);
        insert deployType;
        
        //Deployment record
        Deployment__c deployment = new Deployment__c(Name = 'Test-Deploy1', Project__c = project_1.Id, RecordTypeId = SSC_Deploy_Id,
                                                      Deployment_Type__c = deployType.Id, Program__c = newProgram.Id, Use_Standard_Milestone_Goals__c = false, C_A_DC__c = Date.today());
        
        insert deployment;

        //Create contact
        Contact contact = new Contact(LastName = 'TestingABC', AccountId = institute.Id, Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855');
        insert contact;

        //Query through Opportunity Record Types
        List<RecordType> recordTypes = [Select Id,DeveloperName From RecordType 
                                            Where SobjectType = 'Opportunity' 
                                                AND DeveloperName IN : CPQConstants.SET_OPPORTUNITY_CPQ_RT_DEVELOPER_NAME 
                                                    ORDER BY DeveloperName ASC];
        
        //Reinitialise list
        List<opportunity> opportunities = new List<Opportunity>();
	//Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
        //Add record to list                    
        opportunities.add(new Opportunity(StageName = '0-MQL', Name = 'Test3',Sales_Pursuit_Products__c = 'APS',
                                            Opportunity_Nickname__c = 'Renewal Opp 1', Amount = 0, CloseDate = Date.today(),
                                            RecordTypeId = recordTypes[0].Id, Competitor_Notes__c = 'ABC 1', CT_Pass_Status__c = 'Assigned', 
                                            CT_Reneg_Attempt__c = 'No', SBQQ__Renewal__c = true));
        insert opportunities;

        //create Contract ABC test data
        Contract__c contractABC = new Contract__c(Payer_Account__c = institute.Id, Name = 'TestContract', Invoicing_Arrangement__c = 'Special',
                                                Year__c = '2017', Type__c = 'NBB', Main_Contact__c = contact.Id, Invoice_Contact__c = contact.Id,
                                                Source_Opportunity__c = opportunities[0].Id, Program__c = newProgram.Id,
                                                Negotiated_Amount__c = 12 );

        //Inert
        insert contractABC;

        //List of Subscription
        List<SBQQ__Subscription__c> subscriptions = new List<SBQQ__Subscription__c>();
        
        SBQQ__Subscription__c subscription_1 = new SBQQ__Subscription__c(SBQQ__Quantity__c = 1, 
                                                    SBQQ__ListPrice__c = 0, Shadow_Contract_ABC__c = contractABC.Id,
                                                    SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0, SBQQ__ProrateMultiplier__c = 2,
                                                    Status__c = 'Committed', Program__c = newProgram.Id, SBQQ__Account__c = institute.Id);
                                                    
        SBQQ__Subscription__c subscription_2 = new SBQQ__Subscription__c(SBQQ__Quantity__c = 1, 
                                                    SBQQ__ListPrice__c = 0, Shadow_Contract_ABC__c = contractABC.Id,
                                                    SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0, SBQQ__ProrateMultiplier__c = 2,
                                                    Status__c = 'Committed', Program__c = newProgram.Id, SBQQ__Account__c = institute.Id);
        
        
        //Insert subscription
        subscriptions.add(subscription_1);
        subscriptions.add(subscription_2);
        insert subscriptions;
        
        //List to hold ABC Revenue Records
        List<ABC_Revenue__c> aBCRevenues = new List<ABC_Revenue__c>();
        
        //Creating ABC Revenue Records
        aBCRevenues.add(new ABC_Revenue__c(Program_Subscription__c = subscription_1.Id, GAAP_Amount__c = 0, Line_Status__c = 'Void', Historical_Linker__c  = 'Test Sample 1'));
        aBCRevenues.add(new ABC_Revenue__c(Program_Subscription__c = subscription_1.Id, Negotiated_Amount__c = 500, GAAP_Amount__c = 0, Line_Status__c = 'Void', Historical_Linker__c  = 'Test Sample 1'));
        //Modified - Neha Sharma - 02/10/2021- LineStatus value updated from Draft to pending
        aBCRevenues.add(new ABC_Revenue__c(Program_Subscription__c = subscription_2.Id, Negotiated_Amount__c = 500, GAAP_Amount__c = 1000, Line_Status__c = 'Pending', Historical_Linker__c  = 'Test Sample 2'));
        aBCRevenues.add(new ABC_Revenue__c(Program_Subscription__c = subscription_2.Id, Negotiated_Amount__c = 200, GAAP_Amount__c = 1000, Line_Status__c = 'Pending', Historical_Linker__c  = 'Test Sample 2'));
        insert aBCRevenues;
        
        //Reset variable
        Util.BypassAllTriggers = false;
        
        //Start our Test
        Test.startTest();
        
        //Run our Batch
        Batch_Revenue testBatch = new Batch_Revenue();
        Database.executeBatch(testBatch);
        
        //Stop our Test
        Test.stopTest();
        
        //Check to see if our Site Live Date has been populated
        List<ABC_Revenue__c> recordsWithSiteLive = [SELECT Id, Site_Live_Date__c FROM ABC_Revenue__c WHERE Historical_Linker__c = 'Test Sample 2'];
        List<ABC_Revenue__c> recordsWithoutSiteLive = [SELECT Id, Site_Live_Date__c FROM ABC_Revenue__c WHERE Historical_Linker__c = 'Test Sample 1'];
        
        //Check to see if we have a Site Live Date
        System.assert(recordsWithSiteLive[0].Site_Live_Date__c != NULL);
        
        //Check to see we do not have a Site Live Date
        System.assert(recordsWithoutSiteLive[0].Site_Live_Date__c == NULL);   
        
    }

}