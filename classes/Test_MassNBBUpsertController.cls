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
private class Test_MassNBBUpsertController {
	
    //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
    static testMethod void myUnitTest() {
        
        /********************       Create test data         **********************/
        
        //List of program
        List<Program__c> programs = new List<Program__c>();
        programs.add(new Program__c (Name = 'Program - 1', Program_Acronym__c = '123'));
        
        insert programs;
        
        //Query through the record type
        List<RecordType> rTypes = [Select Id, DeveloperName From RecordType Where SObjectType = 'Opportunity' AND DeveloperName = 'EAB_Continuing'];
        
        // Create data for parent object opportunity
        List <Opportunity> oppList = new List<Opportunity>();
        //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
        //Add new Opportunities in list to insert
        oppList.add(new Opportunity(Sales_Pursuit_Products__c = 'APS',Name = 'Test Opp 1', StageName = 'Open', CloseDate = System.today().addDays(1), RecordTypeId = rTypes[0].Id,
                        Program__c = programs[0].Id, Marketer__c = UserInfo.getUserId()));
        oppList.add(new Opportunity(Sales_Pursuit_Products__c = 'APS',Name = 'Test Opp 2', StageName = 'Closed', CloseDate = System.today().addDays(2), RecordTypeId = rTypes[0].Id,
                        Program__c = programs[0].Id, Marketer__c = UserInfo.getUserId(), Primary_Reason_Lost__c = 'Booking Team Use Only - Not A Drop'));
      
      //Insert
      insert oppList;
    
       // List of NBB records
        List <NBB__c> nbbList = new List<NBB__c>();
        
        //Add new records in NBB
        nbbList.add(new NBB__c(Name = 'Test NBB 1', NBB__c = 1, Unit__c = 1, Binder_Date__c = System.today().addDays(1), NA_Date__c = System.today().addDays(2), 
                     Opportunity__c = oppList[0].Id, Program__c = programs[0].Id, Marketer__c = UserInfo.getUserId(), 
                              X1st_Year_Revenue__c = 2000, Profit__c = 1000,NBB_Type__c = 'Base Fee'));
		nbbList.add(new NBB__c(Name = 'Test NBB 2', NBB__c = 2, Unit__c = 2, Binder_Date__c = System.today().addDays(2), NA_Date__c = System.today().addDays(3),
                 Opportunity__c = oppList[1].Id, Program__c = programs[0].Id,Marketer__c = UserInfo.getUserId(),
                              X1st_Year_Revenue__c = 2000, Profit__c = 1000, NBB_Type__c = 'Base Fee'));
      
		//Insert
		insert nbbList;
    
        //Put URL parameters
        ApexPages.currentPage().getParameters().put('oppoutunityId', oppList[0].Id);
          
        //Test start here
        Test.startTest();
        
        //Standard controller       
        ApexPages.StandardController sc = new ApexPages.standardController(oppList[0]);
        
        //Initialize constructor
        MassNBBUpsertController  massNBB = new MassNBBUpsertController(sc);
    
		//Assert for results
		System.assertEquals(11,  massNBB.nbbList.size());
         
        //Calling method
        for(Integer i=1 ; i<= 10 ; i++ ) {
        massNBB.nbbList[i].Unit__c = 1;
        massNBB.nbbList[i].Binder_Date__c = System.today();
        massNBB.nbbList[i].NA_Date__c = System.today();
        massNBB.nbbList[i].ATL_Date__c = System.today();
          massNBB.nbbList[i].SA_EA_Date__c = System.today();
            massNBB.nbbList[i].Profit__c = 1000;
          massNBB.nbbList[i].X1st_Year_Revenue__c = 2000;
            massNBB.nbbList[i].NBB__c = 3000;
            massNBB.nbbList[i].Opportunity__c = oppList[1].Id;
            massNBB.nbbList[i].NBB_Type__c = 'Base Fee';
        }
        
        //Calling save method
        Pagereference pg = massNBB.doSave();
        
        //Asser for result
        System.assert(pg != null);
        
        //set opportunity value in standard controller
        sc = new ApexPages.standardController(oppList[0]);
        
        //Re Initialize constructor
        massNBB = new MassNBBUpsertController(sc);
        
        //Calling methods of controller
        massNBB.doCancel();
        massNBB.addNewNBB();
        
        //Assert for results
		System.assertEquals(12,  massNBB.nbbList.size());
    
		//Re Initialize constructor
		sc = new ApexPages.standardController(oppList[0]);
        massNBB = new MassNBBUpsertController(sc);
        
        //Update the values in input field
        //Calling method
        for(Integer i=1 ; i<= 10 ; i++ ) {
        massNBB.nbbList[i].Unit__c = 1;
        massNBB.nbbList[i].Binder_Date__c = System.today();
        massNBB.nbbList[i].NA_Date__c = System.today();
        massNBB.nbbList[i].ATL_Date__c = System.today();
        massNBB.nbbList[i].SA_EA_Date__c = System.today();
        massNBB.nbbList[i].Profit__c = 1000;
        massNBB.nbbList[i].X1st_Year_Revenue__c = 2000;
        massNBB.nbbList[i].NBB_Type__c = 'Base Fee';
        
      }
		massNBB.nbbList[2].Unit__c = 2;
         
        //Calling save method
        pg = massNBB.doSave();
        
        //Assert for result
        System.assert(pg == null);
         
        //List of page message
        List<Apexpages.Message> msgs = ApexPages.getMessages();
        
        //Assert for results
        system.assertEquals('Require field(s) missing on Row# 3' , msgs[0].getDetail());
         
        //Test stop here
        Test.stopTest(); 
    }
}