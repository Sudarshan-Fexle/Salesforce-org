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
@isTest(seeAllData=false)
Private class Test_Trigger_OpportunityTeamMember {
/**
 *   Purpose         :   Test class for Trigger_OpportunityTeamMember
 *            
 *   Create By       :   Subhash Garhwal
 *
 *   Created Date    :   11/08/2017
 *
 *   Revision Log    :   V_1.0 - Created  - 11/8/2017 - Subhash Garhwal - Issue--CR11753--QA--00007372
 *                       V_1.1 - Modified By - Rajeev Jain -  11/15/2017 - Apollo Full Deployment Production validation failure fix.(Commented out assert at line 126)
 * 			 V_1.2 - Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
 *                       V_1.3 - Modified By - Neha Sharma - CR-20211012-15511
 *
 **/
    //CR-20211012-15511 Update method
    @testSetup static void setUp () {

        Util.byPassAllTriggers = true;
    
        //Insert Account
        List<Account> accounts = new List<Account>();

        accounts.add(new Account(Name = 'Test', Entity__c = 'HC'));
        accounts.add(new Account(Name = 'Test1', Entity__c = 'HC'));

        //Insert Account
        insert accounts;
        
        // Test Class Fix Start Here 13Feb By: Dipesh Gupta
        //Creating Contact record 
        Contact cont = TestUtilities.CreateNewContact(True);
        // Test Class Fix End Here 13Feb By: Dipesh Gupta

        //Query on Record Type
        List<RecordType> oppRecord = [SELECT ID FROM RecordType Where sObjectType = 'Opportunity' AND IsActive = true 
                                         AND DeveloperName = 'EAB_Initiating' ];
 
        //Insert Opportunity Records
        //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
        List<Opportunity> oppList = new List<Opportunity>();
        oppList.add(new Opportunity(RecordTypeId = oppRecord[0].Id , Name = 'Test Opportunity' , 
                                    StageName = 'Proposal In Progress' , Amount = 1234 ,Main_Contact__c = cont.Id,
                                    CloseDate=system.today().addDays(3), Entity__c = 'HC' ,
                                    /*AccountID = accounts[0].Id,*/Sales_Pursuit_Products__c = 'APS'
                                   ));
        oppList.add(new Opportunity(RecordTypeId = oppRecord[0].Id , Name = 'Test Opportunity1' , 
                                    StageName = 'Proposal In Progress' , Amount = 1234 , Entity__c = 'EAB',
                                    CloseDate=system.today().addDays(3), Main_Contact__c = cont.Id,
                                    /*AccountID = accounts[1].Id,*/Sales_Pursuit_Products__c = 'APS'
                                   ));
        insert oppList;

        //Query on profiles
        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name = 'System Administrator' Limit 1];

        System.assert(profiles != null);
        
        //Creating User records
        List<User> users = new List<User>();
        
        users.add(new User(Alias = 'dAnalyst', Email='deliveryA@testorg1.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = profiles[0].Id, department = 'STP', Entity__c = 'HC',
                            TimeZoneSidKey='GMT', UserName=Math.random() + '0@test.com'));
        users.add(new User(Alias = 'sAdmin', Email='standarduser@testorg2.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = profiles[0].Id, department = 'STP', Entity__c = 'EAB',
                            TimeZoneSidKey='GMT', UserName=Math.random() + '1@test.com'));
        
        insert users;
 
         //Enable Triggers
        Util.BypassAllTriggers = false;
          
    }
    /**
     *  Description     :   test class to test the functionality of PreventNewOpportunityTeamMember
     * 
     *  Created By      :   Subhash Garhwal  
     * 
     *  Created Date    :   11/08/2017
     * 
     *  Revision Logs   :   V_1.0 - Created
     *			:   V_1.1 - CR-20211012-15511 Update method
     *
     **/ 
     static testMethod void check_PreventNewOpportunityTeamMember() {
         
         //Bypass Dupeblocker     
         Util.IsTest(true);
         Util.isTesting = true;
         Util.BypassAllTriggers = true;
         
         //Query on USer and Opportunity
         List<Account> accounts = [Select Id ,Entity__C From Account Order By Entity__c];
             
         List<User> users = [Select Id ,Entity__c From User Order By Entity__c];
         
         List<Opportunity> opp = [Select Id, Entity__c From Opportunity Order By Entity__c];
         System.assertEquals(2, opp.size());
         
         //List to hold Opportunity Team Member
         List<OpportunityTeamMember> oppTeamMembers = new List<OpportunityTeamMember>();
         
         oppTeamMembers.add(new OpportunityTeamMember(OpportunityId = opp[0].Id, UserId = users[0].Id ));
         oppTeamMembers.add(new OpportunityTeamMember(OpportunityId = opp[1].Id, UserId = users[1].Id ));
         
         //Testing Start here        
         Test.startTest();
         
		Util.BypassAllTriggers = false;         
         try {
             
             //Insert OpportunityTeamMmber
             insert oppTeamMembers;
         }
         catch(Exception exc) {
             System.assert((exc.getMessage().containsIgnoreCase(Label.PREVENT_OPPORTUNITY_TEAM_MEMBER)),exc.getMessage()); 
         }
         //Testing Stop here
         Test.stopTest();
         
     }
}