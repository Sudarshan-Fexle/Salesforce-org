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
 *     Description     :	Test Class for "UltimateParentController" Controller To test the funtionality
 *
 *     Created By      :	Abhishek Mishra
 *
 *     Created Date    :	3/17/2016
 *     
 *     Code Coverage   :	82%
 * 
 *     Revision Logs   :	V1.0 - Created
 * 							V1.0 - Modified By - Rajeev Jain - 06/16/2016 - SFDC schema Release - Manual Code Migration from Royall Enviournment
 * 							V_2.0 - Modified By - Rajeev Jain - 09/01/2016 - Fixed Test class failure
 * 							V_2.1 - Modified By Deepak Kumar - Apollo - Run All Test Failures Fixes
 							V_2.2 - Modified By - Mahendra SwarnKar - 05/01/2019 - Commented the class code as per Spring Clean up - CR-20190501-13061	
 *     
 *     Deprecated      :	None                         
 **/ 
@isTest(SeeAllData = false)
private class UltimateParentControllerTest {
	
	// TO DO: implement unit test(Move test code from Main class)
    static testMethod void myUnitTest() {
		
        //Trigger Bypass
        Util.BypassAllTriggers = true;
        	
		//Bypass the entity population Logic  
     	Util.bypassEntityPopulation = true;
        
    	//Create list
    	List <Account> lstAccount = new List<Account>();
        List <Contact> lstContact = new List<Contact>();
        List <UltimateParent_ExcludedLists__c> lstExcludedRelated = new List<UltimateParent_ExcludedLists__c>();
        List <UltimateParent_ExcludedRollUp__c> lstExcludedRollUp = new List<UltimateParent_ExcludedRollUp__c>();
        
        // for Account Object         
        Account objAcc1 = new Account(Website = 'www.test.com', Phone = '9876541230', Name = 'Test1 ' + Datetime.now(), Type = 'Prospect');
        
        //Insert
        insert objAcc1;        
        Account objAcc2 = new Account(Website = 'www.test.com', Name = 'Test2 ' + Datetime.now(), ParentId = objAcc1.Id, Phone = '98765412301', Type = 'Prospect');
        lstAccount.add(objAcc2);               
        Account objAcc3 = new Account(Website = 'www.test.com', Name = 'Test3 ' + Datetime.now(), ParentId = objAcc1.Id, Phone = '98765412301',  Type = 'Prospect');
        lstAccount.add(objAcc3);
        
        //Insert
        insert lstAccount;
        
        // for Contact Object        
        Contact objContact1 = new Contact(LastName  = 'Contact1' + Datetime.now(), AccountId = objAcc1.Id, Phone = '9987123456', Email = 'test1@test.com', Title = 'Contact1', Birthdate = datetime.now().date() );//, RecordTypeId = [select Id from RecordType where name = 'Enterprise Record Type' Limit 1].Id);
        lstContact.add(objContact1);        
        Contact objContact2 = new Contact(LastName  = 'Contact2' + Datetime.now(), AccountId= objAcc3.Id, Phone = '9987123456', Email = 'test2@test.com', Title = 'Contact2', Birthdate = datetime.now().date()); //,RecordTypeId = [select Id from RecordType where name = 'Enterprise Record Type' Limit 1].Id);
        lstContact.add(objContact2);
        
        //Insert
        insert lstContact;
        
        //for Case Object        
        Case objCase1 = new Case(ContactId = objContact1.Id ,Status = 'Pending', Reason = 'Task', Origin = 'Chat', 
                                Subject = 'Case 1 ' + Datetime.now(), Priority = '2 - High Priority'/*, Request_Received__c=Date.Today()*/);//, RecordTypeId = [select Id from RecordType where name = 'Support' Limit 1].Id); 
        
        //Insert
        insert objCase1;
        
        //for Opportunity Object        
        Opportunity objOpp1 = new Opportunity(AccountId = objAcc2.Id,Main_Contact__c = lstContact[0].Id, Name = 'Oportunity1',StageName = 'Identification',Amount = 1000, CloseDate = datetime.now().date(),Type = 'Upsell' , LeadSource = '2010WEB');//,RecordTypeId = [select Id from RecordType where name = 'Prospective Partner Layout' Limit 1].Id );
        
        //Insert
        insert objOpp1;
        
        //V_2.0 - Modified - Rajeev Jain - 09/01/2016 - Fixed Test class failure - Added SBQQ__Quote__c Record
        //List of Quote
        List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
        
        //Add new quote record in list
        quotes.add(new SBQQ__Quote__c(SBQQ__Status__c = 'Draft', SBQQ__Type__c = 'Quote', SBQQ__Primary__c = true, SBQQ__Opportunity2__c = objOpp1.Id));
        
        //Insert list of Quote
        insert quotes;

        // for Contract Object
        Contract objContract1 = new Contract(AccountId= objAcc2.Id, Status = 'Draft', SBQQ__Quote__c = quotes[0].Id);
        
        //Insert
        insert objContract1;
        //V_2.0 - Modified - Rajeev Jain - 09/01/2016 - Fixed Test class failure - Added SBQQ__Quote__c Record - Upto here
         
        //OpenActivity Object
        Task objActivity1 = new Task(WhatId = objAcc1.Id,Status='In Progress');
        
        //Insert
        insert objActivity1;
         
        //ActivityHistory Object
        Task objActivityHistory1 = new Task(WhatId=objAcc1.Id,Status='Completed');
        
        //Insert
        insert objActivityHistory1;
        /*** Spring clean up - CR-20190501-13061 ***
        Rollup_Definition__c objRollupdefine = new Rollup_Definition__c(Name__c='test ' + Datetime.now(),Object_Aggregated__c='Case',Field_Aggregated__c='id',Aggregate_Function__c='count',Criteria__c='IsClosed = false');
        
        //Insert
        insert objRollupdefine;
        Rollup_Definition__c objRollupdefinition = new Rollup_Definition__c(Name__c = 'test1 ' + Datetime.now(), Object_Aggregated__c = 'Contract', Field_Aggregated__c = 'Id',Aggregate_Function__c = 'count',Criteria__c = 'IsDeleted = true');
		*/
        //Test method start here
        Test.startTest();
        
        //Enabling the triggers
        Util.BypassAllTriggers = false;
        
        /*** Spring clean up - CR-20190501-13061 ***
        //Insert
        //insert objRollupdefinition;
        */
        
        //Create Set
        Set<String> strExcludeObject = new Set<String>{'opportunity','contract','case','contact','activity history','open activity'};
                
        //Create Instant
        ApexPages.StandardController std = new ApexPages.StandardController(objAcc1); 
        UltimateParentController SUPClass = new UltimateParentController(std);
        
        //Call Method
        SUPClass.getData();
        
        //Set value
        System.currentPagereference().getParameters().put('id',objAcc1.Id);
        
        //Call Method
        SUPClass.getData();
        SUPClass.fields = 'Account#~opportunity#Name~contact#~contract#~case#';
        
        //Call Method
        SUPClass.getData();
        SUPClass.fields = 'Account#Name~opportunity#Name~contact#~contract#~case#';
        
        //Call Method
        SUPClass.getData();
        
        //Put Value
        System.currentPagereference().getParameters().put('id',objAcc1.Id);
        
        //Assert for result
        /*** Spring CleanUp CR-20190501-13061 ***
        System.assertequals(SUPClass.getlstRollupDetails().size(), 2);
        */
        //Create instant
        ApexPages.StandardController std1 = new ApexPages.StandardController(objAcc1);
        UltimateParentController SUPClass1 = new UltimateParentController(std1);
        
        
        SUPClass1.fields = 'Account#Name~opportunity#Name~contact#~contract#~case#';
        Map<String, UltimateParent_ExcludedLists__c> testMapFields = UltimateParent_ExcludedLists__c.getAll();
        if(testMapFields.keyset().size() > 0)
        {
            for(String str : testMapFields.keyset())
            {
                lstExcludedRelated.add(testMapFields.get(str));
            }
            delete lstExcludedRelated;
        }
        else
        {
            UltimateParent_ExcludedLists__c objRelatedExclude = new UltimateParent_ExcludedLists__c(name='opportunity');
            UltimateParent_ExcludedLists__c objRelatedExclude1 = new UltimateParent_ExcludedLists__c(name='case');
            lstExcludedRelated.add(objRelatedExclude);lstExcludedRelated.add(objRelatedExclude1);
            insert lstExcludedRelated;
        }
        Map<String , UltimateParent_ExcludedRollUp__c> testMapRollUp = UltimateParent_ExcludedRollUp__c.getAll();
        if(testMapRollUp.keyset().size() > 0)
        {
            for(String str1 : testMapRollUp.keyset())
            {
                lstExcludedRollUp.add(testMapRollUp.get(str1));
            } 
            delete lstExcludedRollUp;
        }
        else
        {           
            UltimateParent_ExcludedRollUp__c objExculdeRollup1 = new UltimateParent_ExcludedRollUp__c(name='total amount of won opportunity');          
            lstExcludedRollUp.add(objExculdeRollup1);
            insert lstExcludedRollUp;
        }
        
        //Call Method
        SUPClass1.getData();
        
        /*** Spring clean up - CR-20190501-13061 ***
        Rollup_Definition__c objRollupdefine1 = new Rollup_Definition__c(Name__c='test3 ' + Datetime.now(),Object_Aggregated__c='Opportunity',Field_Aggregated__c='Amount',Aggregate_Function__c='sum',Criteria__c='Name = \'testCoverageTest\'');
        
        //Insert
        insert objRollupdefine1;
        */
        System.currentPagereference().getParameters().put('id',objAcc3.Id);
        ApexPages.StandardController std3 = new ApexPages.StandardController(objAcc3);
        UltimateParentController SUPClass3 = new UltimateParentController(std3);
        SUPClass3.fields = 'Account#Name,y~opportunity#Name~contact#~contract#~case#';
        
        //Call Method
        lstExcludedRelated.clear();
        
        Map<String, UltimateParent_ExcludedLists__c> testMapFields1 = UltimateParent_ExcludedLists__c.getAll();
        
        
        if(testMapFields1.keyset().size() > 0)
        {
            for(String str : strExcludeObject)
            {
                if(!testMapFields1.keyset().contains(str))
                    lstExcludedRelated.add(new UltimateParent_ExcludedLists__c(name=str));
            }
        }
        
        //Insert
        insert lstExcludedRelated;
        
        //Call Method
        SUPClass3.getData();
        
        Set<Id> setAllChilds;
        
        //Call Method
        //SUPClass3.calculateRollups(setAllChilds);
         
        //Test method stop here
        Test.stopTest();
        
    }
}