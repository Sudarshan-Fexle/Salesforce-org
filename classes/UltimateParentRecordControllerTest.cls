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
 *	Description	:	This class use to unit testing of UltimateParentRecordController.
 *
 *	Created By	:	Abhishek Mishra(Simplyforce)
 *	
 *	Created Date	:	3/17/2016
 *
 *	Revision Log	:	V_1.0 - Created
 *			:	V_1.1 - Modified - Rajeev Jain - 09/01/2016 - Fixed Test class failure
 *				V_1.2 - Modified By Deepak Kumawat - Apollo - Run All Test Failures Fixes
 *				V_1.3 - Modified By - Neha Sharma - 05/03/2021 - Test Class fixes
 *	Covrage		:	92%
 *
 **/
@isTest(SeeAllData = false)
private class UltimateParentRecordControllerTest {
	
	// TO DO: implement unit test
    static testMethod void testUltimateParentRecordController() {
        
        //Trigger Bypass
        Util.BypassAllTriggers = true;
        
        //Define List
        List <Account> lstAccount = new List<Account>();
        List <Contact> lstContact = new List<Contact>();
        List <UltimateParent_ExcludedLists__c> lstExcludedRelated = new List<UltimateParent_ExcludedLists__c>();
        List <UltimateParent_ExcludedRollUp__c> lstExcludedRollUp = new List<UltimateParent_ExcludedRollUp__c>();
        
        //Record for Account object         
        Account objAcc1 = new Account(Website = 'www.test.com',  Phone = '9876541230', Name = 'Test1 ' + Datetime.now(),  Type = 'Prospect');
        
        //Insert
        insert objAcc1;        
        
        //Record for Account object
        Account objAcc2 = new Account(Website = 'www.test.com',  ParentId = objAcc1.Id, Phone = '98765412301', Name = 'Test2 ' + Datetime.now(), Type = 'Prospect');
        
        //Add Account in list
        lstAccount.add(objAcc2);               
        
        //Record for Account object
        Account objAcc3 = new Account(Website = 'www.test.com', ParentId = objAcc1.Id, Phone = '98765412301', Name = 'Test3 ' + Datetime.now(), Type = 'Prospect');
        
        //Add record in list
        lstAccount.add(objAcc3);
        
        //Insert
        insert lstAccount;
        
        //Add record for Contact Object        
        Contact objContact1 = new Contact(LastName  = 'Contact1 ' + Datetime.now(), AccountId = objAcc1.Id, Phone = '9987123456', Email = 'test1@test.com', Title = 'Contact1', Birthdate = datetime.now().date());//, RecordTypeId = [select Id from RecordType where name = 'Enterprise Record Type' Limit 1].Id);
        
        //Add record in list
        lstContact.add(objContact1);
        
        //Create record      
        Contact objContact2 = new Contact(LastName  = 'Contact2 ' + Datetime.now(), AccountId = objAcc3.Id, Phone = '9987123456', Email = 'test2@test.com', Title = 'Contact2', Birthdate = datetime.now().date()); //,RecordTypeId = [select Id from RecordType where name = 'Enterprise Record Type' Limit 1].Id);
        
        //Add record in list
        lstContact.add(objContact2);
        
        //Insert
        insert lstContact;
        
        //for Case Object        
        Case objCase1 = new Case(ContactId = objContact1.Id ,Status = 'Pending', Reason = 'Task', Origin = 'Chat', 
        Subject = 'Case 1 ' + Datetime.now(), Priority = '2 - High Priority'/*, Request_Received__c=Date.Today()*/);//, RecordTypeId = [select Id from RecordType where name = 'Support' Limit 1].Id); 
        
        //Insert
        insert objCase1;
        //Modified By - Neha Sharma - 05/03/2021 - Test Class fixes
        //for Opportunity Object        
        Opportunity objOpp1 = new Opportunity(Sales_Pursuit_Products__c = 'APS', AccountId = objAcc2.Id,Main_Contact__c = lstContact[0].Id, Name = 'Oportunity1 '  + Datetime.now(),StageName = 'Identification',Amount = 1000, CloseDate = datetime.now().date(),Type = 'Upsell' , LeadSource = '2010WEB');//,RecordTypeId = [select Id from RecordType where name = 'Prospective Partner Layout' Limit 1].Id );
        
        //Insert
        insert objOpp1;
        
        //V_2.0 - Modified - Rajeev Jain - 09/01/2016 - Fixed Test class failure - Added SBQQ__Quote__c Record
        //List of Quote
        List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
        
        //Add new quote record in list
        quotes.add(new SBQQ__Quote__c(SBQQ__Status__c = 'Draft', SBQQ__Type__c = 'Quote', SBQQ__Primary__c = true, SBQQ__Opportunity2__c = objOpp1.Id));
        
        //Insert list of Quote
        insert quotes;
        
        //Record for Contract Object
        Contract objContract1 = new Contract(AccountId= objAcc2.Id, Status = 'Draft', SBQQ__Quote__c = quotes[0].Id);
        
        //Insert
        insert objContract1;
        //V_2.0 - Modified - Rajeev Jain - 09/01/2016 - Fixed Test class failure
        
        //OpenActivity Object
        Task objActivity1 = new Task(WhatId = objAcc1.Id,Status='In Progress');
        
        //Insert
        insert objActivity1;
         
        //ActivityHistory Object
        Task objActivityHistory1 = new Task(WhatId=objAcc1.Id,Status='Completed');
        
        //Insert
        insert objActivityHistory1;
        
        //Test method start here
        Test.startTest();
        
        //Define Instante
        UltimateParentRecordController UPRClass1 = new UltimateParentRecordController();
        
        //Call Method
        UPRClass1.getData();
        
        //Put Value
        System.currentPagereference().getParameters().put('id',objAcc1.Id);
        System.currentPagereference().getParameters().put('objectType','Account');
        
        //Define Instante
        UltimateParentRecordController UPRClass2 = new UltimateParentRecordController();
        
        //Assert for result
        system.assertEquals(UPRClass2.AccId,objAcc1.Id);
        
        //Call Method
        UPRClass2.getData();
        
        
        UPRClass2.fields='Account#~opportunity#~contact#~contract#~case#';
        
        //Call Method
        UPRClass2.getData();
        
        
        UPRClass2.fields='Account#Name~opportunity#Name~contact#~contract#~case#';
        
        //Call Method
        UPRClass2.getData();
        
        //Put Value
        System.currentPagereference().getParameters().put('id',objAcc1.Id);
        System.currentPagereference().getParameters().put('objectType','Contact');
        
        //Define Instant
        UltimateParentRecordController UPRClass3 = new UltimateParentRecordController();
        
        UPRClass3.fields='Account#~opportunity#~contact#~contract#~case#';
        
        //Call Method
        UPRClass3.getData();
        
        //Put value
        System.currentPagereference().getParameters().put('id',objAcc1.Id);
        System.currentPagereference().getParameters().put('objectType','Opportunity');
        
        //Create Instant
        UltimateParentRecordController UPRClass4 = new UltimateParentRecordController();
        
        
        UPRClass4.fields='Account#~opportunity#~contact#~contract#~case#';
        
        //Call Method
        UPRClass4.getData();
        
        //Put value
        System.currentPagereference().getParameters().put('id',objAcc1.Id);
        System.currentPagereference().getParameters().put('objectType','Contract');
        
        //Create Instant
        UltimateParentRecordController UPRClass5 = new UltimateParentRecordController();
        
        
        UPRClass5.fields='Account#~opportunity#~contact#~contract#~case#';
        
        //Call Method
        UPRClass5.getData();
        
        //Put Value
        System.currentPagereference().getParameters().put('id',objAcc3.Id);
        System.currentPagereference().getParameters().put('objectType','Case');
        
        //Create Instant
        UltimateParentRecordController UPRClass6 = new UltimateParentRecordController();
        
        
        UPRClass6.fields='Account#~opportunity#~contact#~contract#~case#';
        
        //Call Method
        UPRClass6.getData();
        
        //Put Value
        System.currentPagereference().getParameters().put('id',objAcc1.Id);
        System.currentPagereference().getParameters().put('objectType','OpenActivity');
        
        //Create Instant
        UltimateParentRecordController UPRClass7 = new UltimateParentRecordController();
        
        
        UPRClass7.fields='Account#~opportunity#~contact#~contract#~case#';
        
        //Call Method
        UPRClass7.getData();
        
        //Put Value
        System.currentPagereference().getParameters().put('id',objAcc1.Id);
        System.currentPagereference().getParameters().put('objectType','ActivityHistory');
        
        //Create Instant
        UltimateParentRecordController UPRClass8 = new UltimateParentRecordController();
        
        
        UPRClass8.fields='Account#~opportunity#~contact#~contract#~case#';
        
        //Call Method
        UPRClass8.getData();
        
        // to cover the Pagination functions */
        System.currentPagereference().getParameters().put('objectType','Contact');
        
        //Create Instant
        UltimateParentRecordController UPRClass9 = new UltimateParentRecordController(); 
        UPRClass9.fields='Account#~opportunity#~contact#~contract#~case#';
        
        //Call Method
        UPRClass9.getData();
        
        //Set Value
        UPRClass9.FirstPage = 26;
        UPRClass9.previousPage();
        UPRClass9.sumCount = 2; 
        UPRClass9.sumCount = 26;
        UPRClass9.LastPage = 2;
        UPRClass9.lastPage();
        UPRClass9.sumCount = 2;
        UPRClass9.lastPage();
        UPRClass9.sumCount = 28;
        UPRClass9.FirstPage = 1;
        
        //Call Method
        UPRClass9.nextPage();
        UPRClass9.firstPage();
        
        //Test method stop here
        Test.stopTest();
    }
}