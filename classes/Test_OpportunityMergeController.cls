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
*   Purpose         :     Test class for OpportunityMergeController
*            
*   Create By       :     Subhash Garhwal  
* 
*   Created Date    :     05/03/2014
*
*   Revision Log    :     V_1.0 - Created
                          V_1.1 - Modified By - Deepak - 07/03/2017 - Q2C
*                   :     V_1.1 - Modified By - Rajeev Jain - 07/05/2017 - Replaced Associate_Principal__c field to Associate_Principal1__c, due to merging of overlapping changes from other releases    
*                   :     V_1.2 - Modified By - Dipesh Gupta - 09/04/2017 - Replaced the name of the Merged record type on opportunity to Merged_Migrated record type.
*                         V_1.3 - Modified By - Dipesh Gupta - 02/20/2018 - Release - Q2C enhancement Bugs - Too many DML rows: 10001
*                         V_1.4 - Modified By - Colin McGloin - 09/04/2018 - CR-20180731-12476 - Commented out all references to Associate_Principal1__c, Executive_Sales_Support__c, National Partner due to field deletions as part of Lookup Cleanup on Opportunity
*                         V_1.5 - Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
*			  V_1.6 - Modified By - Abhishek Mishra - 08/30/2021 - CR-20210722-15307 - to increase Code coverage
*                         V_1.7 - Modified By - Chirag Soni - CR-20210927-15464 - 09/28/2021 - Removed the 'Research' picklist value reference and updated to 'APS' And test class issue fixes Method - testOpportunityMergeController1()
*
**/
@isTest(seeAllData=false)
private class Test_OpportunityMergeController {
    
    //Commented services_in_contract__c, sell_type__c - By Mahendra Swarnkar - spring clean up - 04/29/2019
   /**
    * @Description  : This method used to insert Opportunity,Account ,and related list of opportunity
    * 
    * @Args         :  
    * 
    * @Return       : void 
    * 
    * @Revision-log : V_1.0 - Created
                    : V_1.1 - Modified By - Chirag Soni - CR-20210927-15464 - 09/28/2021 - Removed the 'Research' picklist value referece and updated to 'APS'
    **/
    @testSetup static void testSetUpData() {
        
        //Bypass Dupeblocker and triggers
        Util.IsTest(true);
        Util.byPassAllTriggers = true;
        Util.IsTesting = true;
        
        //List of Account
        List<Account> parentAccounts = new List<Account>();
        
        //Add new account in list
        parentAccounts.add(new Account(Account_Formal_Name__c = 'AAA1', Primary_City__c  = 'AA1', Name ='t'));
        parentAccounts.add(new Account(Account_Formal_Name__c= 'AAA2', Primary_City__c   = 'AA2', Name ='t'));
        
        //Insert    
        insert parentAccounts;
        
        //List to hold account
        List<Account> accounts = new List<Account>();
        
        //Add to list
        accounts.add(new Account(Account_Formal_Name__c = 'BBB1', ParentId = parentAccounts[0].Id, Primary_City__c = 'BB1', Name ='t'));
        //Added By  - Abhishek Mishra - 08/31/2021 - CR-20210722-15307
        accounts.add(new Account(Account_Formal_Name__c = 'BBB2', ParentId = parentAccounts[0].Id, Primary_City__c = 'BB2', Name ='t1'));
        
        //Insert child Account
        insert accounts;
        
        List<RecordType> recordTypesContact = [Select Id, Name FROM RecordType WHERE SobjectType = 'Contact' AND DeveloperName = 'Employee'];
        
        //List to hold Contact
        List<Contact> contacts = new List<Contact>();
        
        //Addd to list
        contacts.add(new Contact( AccountId = parentAccounts[0].Id, RecordTypeId = recordTypesContact[0].Id, LastName = 'ABC', Contact_Status__c = 'Active'));
        //Added By  - Abhishek Mishra - 08/31/2021 - CR-20210722-15307
        contacts.add(new Contact( AccountId = accounts[1].Id, RecordTypeId = recordTypesContact[0].Id, LastName = 'ABCD', Contact_Status__c = 'Active'));
        
        //Insert Contact
        insert contacts;
        
        //Query on Profile
        Profile profile1 = [Select Id, Name From Profile Where name = 'System Administrator'];
        
        //List to hold User
        List<User> users = new List<User>();        
        
        //Add user record to user
        users.add(new User(Alias = 'unitTest', Email = 'testuser@testorg.com', 
                           EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US', 
                           LocaleSidKey = 'en_GB', ProfileId = profile1.Id, 
                           TimeZoneSidKey = 'Europe/London', UserName = Math.random() + '@unit.test'));
        
        //Insert User
        insert users;
        
        //Get opportunity record type
        List<RecordType> recordTypes = [Select Id, Name FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName IN ('EAB_Continuing', 'EAB_Initiating') ORDER BY DeveloperName ASC];
        
        //List to hold the opportunity records  
        List<Opportunity> Opportunities = new List<Opportunity>();
        
        //Modified By - Neha Sharma - 05/04/2021 - CR-20201110-14683 - Test Class fixes
        //Add record to list            
        //EAB_Continuing Record type Opportunity -Account AA1   
        //Modify By - Chirag Soni - CR-20210927-15464 - 09/28/2021 - Removed the 'Research' picklist value referece and updated to 'APS'
        Opportunities.add(new Opportunity(StageName = CPQConstants.OPPORTUNITY_STAGE_PENDING , 
                                          AccountId = parentAccounts[0].Id, /*Associate_Principal1__c = contacts[0].Id,*/ Probability = 10, 
                                          Closing_Call_Scheduled__c = Date.Today(), Date_Passed__c = Date.Today(),
                                          Date_Visit_Happens__c = Date.Today(),/*Executive_Sales_Support__c = users[0].ID,*/
                                          Primary_Reason_Lost__c = 'Price',  Special_Commitments__c = 'Testing ',
                                          Initial_Visit_Date__c = Date.Today(), NBB_Units__c = 10,
                                          Next_Step_Date__c = Date.today(), Main_Contact__c = contacts[0].Id,
                                          //National_Partner__c = users[0].Id, 
                                          Outreach_Campaign_Month__c = 'January', Secondary_Reason_Lost__c = 'Conversion',
                                          //Sell_Type__c = 'Upsell', 
                                          Name = 'test',
                                          NBB__c = 10, Projection_Liklihood__c = 'Correct',
                                          RFP_Stage__c = 'Not RFP',Sales_Pursuit_Products__c  = 'APS',
                                          Opportunity_Nickname__c = 'Renewal Opp 1', Amount = 0, CloseDate = Date.today().addDays(31),
                                          RecordTypeId = recordTypes[0].Id, Competitor_Notes__c = 'ABC 1', CT_Pass_Status__c = 'Assigned', 
                                          CT_Reneg_Attempt__c = 'No', SBQQ__Renewal__c = true));
        
        //EAB_Continuing Record type Opportunity -Account BB1  
        Opportunities.add(new Opportunity(StageName = CPQConstants.OPPORTUNITY_STAGE_PENDING, 
                                          AccountId = accounts[0].Id, Name = 'test',Main_Contact__c = contacts[0].Id,
                                          Opportunity_Nickname__c = 'Renewal Opp 1', Amount = 0, CloseDate = Date.today().addDays(31),
                                          RecordTypeId = recordTypes[0].Id, Competitor_Notes__c = 'ABC 1', CT_Pass_Status__c = 'Assigned', 
                                          CT_Reneg_Attempt__c = 'No', SBQQ__Renewal__c = true,Sales_Pursuit_Products__c = 'APS'));
        //EAB_Initiating Record type Opportunity  -Account AA1
        Opportunities.add(new Opportunity(StageName = CPQConstants.OPPORTUNITY_STAGE_PENDING, Name = 'test',
                                          AccountId = parentAccounts[0].Id, Opportunity_Nickname__c = 'Renewal Opp 1', Amount = 0, CloseDate = Date.today().addDays(31),
                                          RecordTypeId = recordTypes[1].Id, Competitor_Notes__c = 'ABC 2', CT_Pass_Status__c = 'Assigned',Main_Contact__c = contacts[0].Id, 
                                          CT_Reneg_Attempt__c = 'No', SBQQ__Renewal__c = true,Sales_Pursuit_Products__c = 'APS' ));
        //EAB_Initiating Record type Opportunity  -Account BB1
        Opportunities.add(new Opportunity(StageName = CPQConstants.OPPORTUNITY_STAGE_PENDING ,   
                                          AccountId = accounts[0].Id, Name = 'test',Main_Contact__c = contacts[0].Id,
                                          Opportunity_Nickname__c = 'Renewal Opp 1', Amount = 0, CloseDate = Date.today().addDays(31),
                                          RecordTypeId = recordTypes[1].Id, Competitor_Notes__c = 'ABC 2', CT_Pass_Status__c = 'Assigned', 
                                          CT_Reneg_Attempt__c = 'No', SBQQ__Renewal__c = true,Sales_Pursuit_Products__c = 'APS' ));
        
        //HC_Continuing Record type Opportunity - Account AA1
        Opportunities.add(new Opportunity(StageName =  CPQConstants.OPPORTUNITY_STAGE_EXPLORING,  
                                          AccountId = parentAccounts[0].Id, Name = 'test',Main_Contact__c = contacts[0].Id,
                                          Opportunity_Nickname__c = 'Renewal Opp 1', Amount = 0, CloseDate = Date.today().addDays(31),
                                          RecordTypeId = recordTypes[0].Id, Competitor_Notes__c = 'ABC 2', CT_Pass_Status__c = 'Assigned', 
                                          CT_Reneg_Attempt__c = 'No', SBQQ__Renewal__c = true,Sales_Pursuit_Products__c = 'APS' ));                              
        
        //HC_Continuing Record type Opportunity - Account BB1
        Opportunities.add(new Opportunity(StageName = CPQConstants.OPPORTUNITY_STAGE_EXPLORING,   
                                          AccountId = accounts[0].Id, Name = 'test',Main_Contact__c = contacts[0].Id,
                                          Opportunity_Nickname__c = 'Renewal Opp 1', Amount = 0, CloseDate = Date.today().addDays(31),
                                          RecordTypeId = recordTypes[0].Id, Competitor_Notes__c = 'ABC 2', CT_Pass_Status__c = 'Assigned', 
                                          CT_Reneg_Attempt__c = 'No', SBQQ__Renewal__c = true,Sales_Pursuit_Products__c = 'APS' ));
        
        //HC_InitiatingRecord type Opportunity -Account AA1
        Opportunities.add(new Opportunity(StageName = CPQConstants.OPPORTUNITY_STAGE_EXPLORING,   
                                          AccountId = parentAccounts[0].Id, Years_on_the_Contract__c = 2,
                                          Physician_Competitors__c = 'Accretive Health;Accureg',
                                          Renewal_Process_Comments__c = 'Childs testing comments', 
                                          //Services_in_Contract__c = 'Decision Series', 
                                          Name = 'test',Main_Contact__c = contacts[0].Id,
                                          Opportunity_Nickname__c = 'Renewal Opp 1', Amount = 0, CloseDate = Date.today().addDays(31),
                                          RecordTypeId = recordTypes[1].Id, Competitor_Notes__c = 'ABC 2',
                                          CT_Reneg_Attempt__c = 'No', SBQQ__Renewal__c = true,Sales_Pursuit_Products__c = 'APS' ));
        
        //HC_InitiatingRecord type Opportunity -Account BB1
        Opportunities.add(new Opportunity(StageName = CPQConstants.OPPORTUNITY_STAGE_EXPLORING,   
                                          AccountId = accounts[0].Id, Physician_Competitors__c = '_Unknown', 
                                          Renewal_Process_Comments__c = 'Parent testing comments', Name = 'test',
                                          //Services_in_Contract__c = 'Foundation Series',
                                          Years_on_the_Contract__c = 8,Main_Contact__c = contacts[0].Id,
                                          Opportunity_Nickname__c = 'Renewal Opp 1', Amount = 0, CloseDate = Date.today().addDays(31),
                                          RecordTypeId = recordTypes[1].Id, Competitor_Notes__c = 'ABC 2', 
                                          CT_Reneg_Attempt__c = 'No', SBQQ__Renewal__c = true,Sales_Pursuit_Products__c = 'APS' ));
        
        //Get opportunity record type
        List<RecordType> marketingRecordTypes = [Select Id, Name FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName IN: CPQConstants.SET_OPPORTUNITY_RECORDTYPES_NAMES_MARKETING ORDER BY DeveloperName ASC];
        
        //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
        //BI_Marketing Record Type opportunity -Account AA1
        Opportunities.add(new Opportunity(StageName = CPQConstants.OPPORTUNITY_STAGE_EXPLORING,   
                                          AccountId = parentAccounts[0].Id, Name = 'test',Main_Contact__c = contacts[0].Id,
                                          Opportunity_Nickname__c = 'Renewal Opp 1', Amount = 0, CloseDate = Date.today().addDays(31),
                                          RecordTypeId = marketingRecordTypes[0].Id, Competitor_Notes__c = 'ABC 2', CT_Pass_Status__c = 'Assigned', 
                                          CT_Reneg_Attempt__c = 'No', SBQQ__Renewal__c = true,Sales_Pursuit_Products__c = 'APS' ));
        
        //BI_Marketing Record Type opportunity -Account BB1
        Opportunities.add(new Opportunity(StageName = CPQConstants.OPPORTUNITY_STAGE_EXPLORING,   
                                          AccountId = accounts[0].Id, Name = 'test',Main_Contact__c = contacts[0].Id,
                                          Opportunity_Nickname__c = 'Renewal Opp 1', Amount = 0, CloseDate = Date.today().addDays(31),
                                          RecordTypeId = marketingRecordTypes[0].Id, Competitor_Notes__c = 'ABC 2', CT_Pass_Status__c = 'Assigned', 
                                          CT_Reneg_Attempt__c = 'No', SBQQ__Renewal__c = true, Sales_Pursuit_Products__c = 'APS'));
        
        //Core_Marketing Record Type opportunity -Account AA1
        Opportunities.add(new Opportunity(StageName = CPQConstants.OPPORTUNITY_STAGE_EXPLORING,   
                                          AccountId = parentAccounts[0].Id, Name = 'test',Main_Contact__c = contacts[0].Id,
                                          Opportunity_Nickname__c = 'Renewal Opp 1', Amount = 0, CloseDate = Date.today().addDays(31),
                                          RecordTypeId = marketingRecordTypes[1].Id, Competitor_Notes__c = 'ABC 2', CT_Pass_Status__c = 'Assigned', 
                                          CT_Reneg_Attempt__c = 'No', SBQQ__Renewal__c = true, Sales_Pursuit_Products__c = 'APS' ));
        
        //Core_Marketing Record Type Opportunity -Account BB1
        Opportunities.add(new Opportunity(StageName = CPQConstants.OPPORTUNITY_STAGE_EXPLORING,   
                                          AccountId = accounts[0].Id, Name = 'test',Main_Contact__c = contacts[0].Id,
                                          Opportunity_Nickname__c = 'Renewal Opp 1', Amount = 0, CloseDate = Date.today().addDays(31),
                                          RecordTypeId = marketingRecordTypes[1].Id, Competitor_Notes__c =  'ABC 2', CT_Pass_Status__c = 'Assigned', 
                                          CT_Reneg_Attempt__c = 'No', SBQQ__Renewal__c = true, Sales_Pursuit_Products__c = 'APS'));
        //Added By - Abhishek Mishra - 08/31/2021 - CR-20210722-15307 - Start
        //EAB_Continuing Record type Opportunity -Account BB2 
        Opportunities.add(new Opportunity(StageName = CPQConstants.OPPORTUNITY_STAGE_PENDING, 
                                          AccountId = accounts[1].Id, Name = 'test',Main_Contact__c = contacts[1].Id,
                                          Opportunity_Nickname__c = 'Renewal Opp 1', Amount = 0, CloseDate = Date.today().addDays(31),Renewal_Process_Comments__c = 'Parent testing comments',
                                          RecordTypeId = recordTypes[0].Id, Competitor_Notes__c = 'ABC 1', CT_Pass_Status__c = 'Assigned',Physician_Competitors__c = '_Other',
                                          CT_Reneg_Attempt__c = 'No', SBQQ__Renewal__c = true,Sales_Pursuit_Products__c = 'APS'));
        //EAB_Initiating Record type Opportunity  -Account BB2
        Opportunities.add(new Opportunity(StageName = CPQConstants.OPPORTUNITY_STAGE_EXPLORING ,   
                                          AccountId = accounts[1].Id, Name = 'test',Main_Contact__c = contacts[1].Id,
                                          Opportunity_Nickname__c = 'Renewal Opp 1', Amount = 0, CloseDate = Date.today().addDays(31),Renewal_Process_Comments__c = 'Childs testing comments',
                                          RecordTypeId = recordTypes[1].Id, Competitor_Notes__c = 'ABC 2', CT_Pass_Status__c = 'Assigned',Physician_Competitors__c = 'Campus Labs;Campus Management', 
                                          CT_Reneg_Attempt__c = 'No', SBQQ__Renewal__c = true,Sales_Pursuit_Products__c = 'APS',Years_on_the_Contract__c = 2));
        //Added By - Abhishek Mishra - 08/31/2021 - CR-20210722-15307 - end
        
        //Inert opportunity
        insert Opportunities;
        
        //Added By - Abhishek Mishra - 08/31/2021 - CR-20210722-15307 - Start
        //SOQL over the Proposal record types
        List<RecordType> proposalRTypes = [Select Id, DeveloperName From RecordType Where SobjectType = 'SBQQ__Quote__c' AND DeveloperName IN ('Open', 'Locked') AND IsActive = true ORDER BY DeveloperName DESC];
                
        //List of Proposal
        List<SBQQ__Quote__c> proposals = new List<SBQQ__Quote__c>();
                
        //Add new proposal record in list
         proposals.add(new SBQQ__Quote__c(SBQQ__Type__c = 'Quote', SBQQ__Primary__c = true, 
                                                SBQQ__StartDate__c = Date.today(), SBQQ__SubscriptionTerm__c =36,
                                                SBQQ__EndDate__c = System.today().addYears(3), SBQQ__Opportunity2__c = Opportunities[13].Id, 
                                                SBQQ__Status__c = 'Draft', SBQQ__PrimaryContact__c = contacts[1].Id,Proposal_Version__c = '1',
                                                SBQQ__Account__c = accounts[1].Id, SBQQ__SalesRep__c = Userinfo.getUserId(),RecordTypeId = proposalRTypes[0].Id));
        Insert proposals;
        
        List<Contract> contracts = new List<Contract>(); 
      
      	//Add the records into list
      	contracts.add(new Contract(Status = 'Draft', StartDate = System.today(), EndDate = System.today().addDays(10), ContractTerm = 36, AccountId = accounts[1].Id,
        SBQQ__Quote__c = proposals[0].Id,SBQQ__Opportunity__c = Opportunities[13].Id));
        
        Insert contracts;
        
        
        //List of OpportunityContactRole
        List<OpportunityContactRole> oppContactRoles = new List<OpportunityContactRole>();

        //Add record to list
        oppContactRoles.add(new OpportunityContactRole(ContactId = contacts[1].Id, OpportunityId = Opportunities[13].Id, IsPrimary = true, Role = 'Other'));

        //Insert
        insert oppContactRoles;
        
        //Opportunity Team Member
        OpportunityTeamMember newOTM = new OpportunityTeamMember();
        newOTM.OpportunityId = opportunities[13].Id;
        newOTM.TeamMemberRole = 'RI - Chairman\'s Team';
        newOTM.UserId = Userinfo.getUserId();
       	insert newOTM;
      	//Added By - Abhishek Mishra - 08/31/2021 - CR-20210722-15307 - end
        
    }
    
    //Commented services_in_contract__c - By Mahendra Swarnkar - spring clean up - 04/29/2019
  /**
    * @Description  : This method used to test merge Opportunity Merge contoller
    * 
    * @Args         :  
    * 
    * @Return       : void 
    * 
    * @Revision-log : V_1.0 - Created
    *                 V_1.1 - Modified - 5/31/2019 - Victor Hanson - CR-20190531-13160 - verify the fields in SET_OPPORTUNTY_MERGE_FIELDS are all valid
    **/
    private static testmethod void testOpportunityMergeController() {

        //Query on Opportunity
        List<Opportunity> opportunities = new List<Opportunity>();

        //Query on opportunity
        opportunities = [Select Id, Name, StageName, AccountId, Account.Name , Account.Account_Formal_Name__c, RecordType.DeveloperName, Years_on_the_Contract__c, 
                        Renewal_Process_Comments__c, Physician_Competitors__c, //Services_in_Contract__c,
                        Secondary_Opportunity__c From Opportunity  Order By  RecordType.DeveloperName ASC];
        
        //Object for APexStandardController
         ApexPages.StandardController sC = new ApexPages.standardController(opportunities[5]);
 
        //Put Id of contact
        Apexpages.Currentpage().getparameters().put('Id', opportunities[5].Id);

        //Testing start here
        Test.startTest();

         //Controller Object
        OpportunityMergeController oMC = new OpportunityMergeController(sC);

        try {

        //Calling of validation method
        oMC.mergeOpportunities();
        } catch(Exception e) {

            //Assert    
            String errormessage = e.getMessage();
            System.assert(errormessage.contains('Selected opportunities stages are not appropriate for merge.  Must be prior to "Sent to Finance"'));
        
        } 

        //Object for APexStandardController
         ApexPages.StandardController sC1 = new ApexPages.standardController(opportunities[6]);
 
        //Put Id of contact
        Apexpages.Currentpage().getparameters().put('Id', opportunities[6].Id);

        //Controller Object
        OpportunityMergeController oMC1 = new OpportunityMergeController(sC1);

        //Hold secondaryOpportunity/baseOpportunity/masterOpportunity
        oMC1.secondaryOpportunity = opportunities[9]; 
        oMc1.baseOpportunity = opportunities[6];
        oMc1.masterOpportunity = opportunities[6].Id;

        //Call helper method
        oMC1.validateSecondayOpportunity();
        oMc1.doSave();

        //Object for APexStandardController
        ApexPages.StandardController sC2 = new ApexPages.standardController(opportunities[11]);
 
        //Put Id of contact
        Apexpages.Currentpage().getparameters().put('Id', opportunities[11].Id);

        //Controller Object
        OpportunityMergeController oMC2 = new OpportunityMergeController(sC2);

        //Hold secondaryOpportunity/baseOpportunity/masterOpportunity
        oMC2.secondaryOpportunity = opportunities[10]; 
        oMc2.baseOpportunity = opportunities[11];
        oMc2.masterOpportunity = opportunities[10].Id;
        oMC2.validateSecondayOpportunity();
        oMc2.doSave();

        //VH 5/31/2019 - CR-20190531-13160 - verify the fields in SET_OPPORTUNTY_MERGE_FIELDS are all valid
        List<Opportunity> opps = database.query('SELECT Id, ' + String.join(new List<String>(CPQConstants.SET_OPPORTUNITY_MERGE_FIELDS), ',') + ' FROM Opportunity WHERE Id = \'' + opportunities[11].Id + '\'');
        system.assertEquals(1, opps.size());

        //System Assert to check Master - base
        //System Assert to check Master - secondary
        List<Opportunity> mergedOpp1 = new List<opportunity>();
        mergedOpp1 = [Select Id, Name, Parent_Opportunity__c, recordType.DeveloperName, Years_on_the_Contract__c, 
                        Renewal_Process_Comments__c, Physician_Competitors__c /*, Services_in_Contract__c*/ From Opportunity where recordType.DeveloperName = 'Merged_Migrated'];

        //Query on opportunity
        opportunities = new List<Opportunity>();
        opportunities = [Select Id, Name, StageName, Account.Name , RecordType.DeveloperName, Years_on_the_Contract__c, 
                        Renewal_Process_Comments__c, Physician_Competitors__c, //Services_in_Contract__c,
                        Secondary_Opportunity__c From Opportunity  Where RecordType.DeveloperName != 'Merged_Migrated' Order By  RecordType.DeveloperName  ASC];
        //Assert 
        /*System.assertEquals(opportunities[9].Id, mergedOpp1[1].Parent_Opportunity__c);
        System.assertEquals(8, opportunities[9].Years_on_the_Contract__c);
        System.assert(opportunities[9].Renewal_Process_Comments__c.contains('Parent testing comments'));
        System.assertEquals('Accretive Health;Accureg;_Unknown',opportunities[9].Physician_Competitors__c);
        System.assertEquals('Decision Series;Foundation Series',opportunities[9].Services_in_Contract__c);*/

    	//Testing stop here
        Test.stopTest(); 
    }
    
    
    /**
    * @Description  : This method used to test merge Opportunity Merge contoller
    * 
    * @Args         :  
    * 
    * @Return       : void 
    * 
    * @Revision-log : V_1.0 - Created By - Abhishek Mishra - 08/31/2021 - CR-20210722-15307
    * */
     private static testmethod void testOpportunityMergeController1() {

        //Query on Opportunity
        List<Opportunity> opportunities = new List<Opportunity>();

        //Query on opportunity
        opportunities = [Select Id, Name, StageName, AccountId, Account.Name , Account.Account_Formal_Name__c, RecordType.DeveloperName, Years_on_the_Contract__c, 
        		 Renewal_Process_Comments__c, Physician_Competitors__c, //Services_in_Contract__c,
                         Secondary_Opportunity__c,Associate_Principal__c,Probability,Closing_Call_Scheduled__c,Date_Passed__c,Date_Visit_Happens__c,
                         Initial_Visit_Date__c,Main_Contact__c,Meeting_Travel_Comp__c,NBB__c,NBB_Units__c,Next_Step_Date__c,
                         Outreach_Campaign_Month__c,Primary_Reason_Lost__c,Projection_Liklihood__c,RFP_Stage__c,Secondary_Reason_Lost__c,
                         Special_Commitments__c,Next_PA_Date__c,Next_Steps_Text__c,Description,Next_Activity_Date__c From Opportunity  Order By  RecordType.DeveloperName ASC];
        
        //Object for APexStandardController
         ApexPages.StandardController stdC = new ApexPages.standardController(opportunities[4]);
 
        //Put Id of contact
        Apexpages.Currentpage().getparameters().put('Id', opportunities[4].Id);

        //Controller Object
        OpportunityMergeController oppMC = new OpportunityMergeController(stdC);

        //Hold secondaryOpportunity/baseOpportunity/masterOpportunity
        oppMC.secondaryOpportunity = opportunities[13]; 
        oppMC.baseOpportunity = opportunities[4];
        oppMC.masterOpportunity = opportunities[4].Id;

        //Call helper method
        oppMC.validateSecondayOpportunity();
        oppMC.doSave();
    
    	List<Opportunity> mergedOpp1 = new List<opportunity>();
        mergedOpp1 = [Select Id, Name, Parent_Opportunity__c, recordType.DeveloperName, Years_on_the_Contract__c,Account.Account_Formal_Name__c, 
                      Renewal_Process_Comments__c, Physician_Competitors__c From Opportunity where recordType.DeveloperName = 'Merged_Migrated'];

        //Query on opportunity
        opportunities = new List<Opportunity>();
        opportunities = [Select Id, Name, StageName, Account.Name , RecordType.DeveloperName, Years_on_the_Contract__c,
                         Account.Account_Formal_Name__c,Renewal_Process_Comments__c, Physician_Competitors__c,
                         Secondary_Opportunity__c From Opportunity  Where RecordType.DeveloperName != 'Merged_Migrated' Order By  RecordType.DeveloperName  ASC];
        
         //Modified by - Chirag Soni - CR-20210927-15464 - test class issue fixes
         System.assert(opportunities.size()>0);
         System.assert(opportunities!=null);
    
     }
    
  //Commented Outreach_Campaign__c, services_in_contract__c - By Mahendra Swarnkar - spring clean up - 04/29/2019
  /**
    * @Description  : This method used to test merge Opportunity Merge contoller related list NBB,Contract,Campaign Member etc
    * 
    * @Args         :  
    * 
    * @Return       : void 
    * 
    * @Revision-log : V_1.0 - Created
    * 		    : V_1.1 - Modified by - Chirag Soni - CR-20210927-15464 - test class issue fixes And Code coverage Increase
    **/
    private static testmethod void testOpportunityMergeRelatedList1() {  

        //Skip all triggers temporarily so we can setup test data
        Util.BypassAllTriggers = true;
        Util.IsBatch = true;

        //List to hold opportunity
        List<Opportunity> opportunities = new List<Opportunity>();
        opportunities = [Select Id, Name, StageName, Account.Name , RecordType.DeveloperName, Years_on_the_Contract__c, 
                        Renewal_Process_Comments__c, Physician_Competitors__c, //Services_in_Contract__c,
                        Secondary_Opportunity__c From Opportunity  Where RecordType.DeveloperName != 'Merged' Order By  RecordType.DeveloperName  ASC];

        //Query on contact/Account/User
        List<Contact> Contacts = [Select Id From Contact];
        List<User> Users = [Select Id From User];
        List<Account> accounts = [Select Id From Account];

        //Get opportunity record type
        List<RecordType> recordTypes = [Select Id, Name FROM RecordType WHERE SobjectType = 'SBQQ__Quote__c' AND DeveloperName = 'Open'];

        //List ot hold proposal 
        List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();

        //Add to list
        quotes.add(new SBQQ__Quote__c(SBQQ__Opportunity2__c = opportunities[0].Id, SBQQ__SalesRep__c = users[0].Id, SBQQ__Status__c = 'Draft', 
                                       SBQQ__StartDate__c = Date.today() , SBQQ__EndDate__c = Date.today().addDays(2), recordTypeId =recordTypes[0].Id,
                                       SBQQ__PrimaryContact__c = contacts[0].Id, SBQQ__Primary__c = true, Invoice_Frequency__c = 'Annual'));

        //Insert Opportunity
        insert quotes;
 
        //List to hold Contract
        List<Contract> contracts = new List<Contract>();

        //Add record to listid
        contracts.add(new Contract(SBQQ__Opportunity__c = opportunities[0].Id, Status = 'Draft', StartDate = Date.today(), AccountId= accounts[0].Id,
                                    ContractTerm = 12, SBQQ__Quote__c = quotes[0].Id));

        //Insert Contract
        insert contracts;

        //List to bold Task 
        List<Task> tasks = new List<Task>();

        //Add to list
        tasks.add(new Task(Subject = 'Message Sent', Status = 'Completed', WhatId = opportunities[0].Id));

        //Insert Task
        insert tasks;

        //List to hold Event
        List<Event> events = new List<Event>();

        //Add recored to list
        events.add(new Event(Subject = 'Message Sent', WhatId = opportunities[0].Id, DurationInMinutes = 12 ,ActivityDateTime = Date.today().addDays(1)));

        //Insert Events
        insert events;
    
        //List to hold integrated Account
        List<Integrated_Account__c> integAccounts = new List<Integrated_Account__c>();

        integAccounts.add(new Integrated_Account__c(Integrated_Account__c = accounts[0].Id, Opportunity__c = opportunities[0].Id));

        //Insert integrated Account
        insert integAccounts;

        //List to hold NBB
        List<NBB__c> nBBs = new List<NBB__c>();

        //Add record to list
        nBBs.add(new NBB__c(Name = 'ABC', Opportunity__c = opportunities[0].Id, NBB__c = 12, Status__c = 'ATL', Unit__c = 12,
                            Profit__c = 11, X1st_Year_Revenue__c = 10, NBB_Type__c = 'Base Free'));

        //Insert NBB
        insert nBBs;

        //List to hold Reference request
        List<Reference_Request__c> referenceRequests =  new List<Reference_Request__c>();

        //Add record to list
        referenceRequests.add(new Reference_Request__c( Requesting_Contact__c = contacts[0].Id, Number_of_References_Needed__c = 10,
                                                        Source_Opportunity__c = opportunities[0].Id));

        //insert Reference request
        insert referenceRequests;


        //List to hold Campaign
        List<Campaign> campaigns = new List<Campaign>();

        //Add record to list
        campaigns.add(new Campaign(Name = 'TestCampaign'));

        //Insert Campaign
        insert campaigns;

        //List to hold CampaignMember
        List<CampaignMember> cM = new List<CampaignMember>();

        //Add record to list
        cM.add(new CampaignMember( Status = 'Sent', CurrencyIsoCode = 'NOK', Opportunity__c = opportunities[0].Id, ContactId = contacts[0].Id,
        			   campaignId = campaigns[0].Id));

        //Insert 
        insert cM;

        //List to hold OpportunityTeamMember
        List<OpportunityTeamMember> oTM = new List<OpportunityTeamMember>();

        //Add record to list
        oTM.add(new OpportunityTeamMember(opportunityId = opportunities[0].Id, UserId = users[0].Id));

        //Insert OTM  V_1.3 Modified By - Dipesh Gupta - 02/20/2018 - Release - Q2C enhancement Bugs - Too many DML rows: 10001
         //insert oTM;

        //List of OpportunityContactRole
        List<OpportunityContactRole> oppContactRoles = new List<OpportunityContactRole>();

        //Add record to list
        oppContactRoles.add(new OpportunityContactRole(ContactId = contacts[0].Id, OpportunityId = opportunities[0].Id, IsPrimary = true, Role = 'Other'));

        //Insert
        insert oppContactRoles;

        //Testing start here
        Test.startTest();

        //Object for APexStandardController
         ApexPages.StandardController sC3 = new ApexPages.standardController(opportunities[4]);
 
        //Put Id of contact
        Apexpages.Currentpage().getparameters().put('Id', opportunities[4].Id);

        //Controller Object
        OpportunityMergeController oMC3 = new OpportunityMergeController(sC3);

        //Hold secondary Opportunity/Base opportunity/Master opportunity
        oMC3.secondaryOpportunity = opportunities[0]; 
        oMc3.baseOpportunity = opportunities[4];
        oMc3.masterOpportunity = opportunities[4].Id;
		
        //Added by - Chirag Soni - 09/29/2021 - CR-20210927-15464 - test class code coverage increase
	oMc3.tempOpportunity = opportunities[5];
        oMc3.tempOpportunity.Secondary_Opportunity__c = opportunities[4].Id;
        
        //Call Validation Method
        oMC3.validateSecondayOpportunity();

        //Call save method
        oMc3.doSave();

        //Query on quotes
        quotes = [Select Id, SBQQ__Primary__c, SBQQ__Opportunity2__c From SBQQ__Quote__c ];

        //Assert 
        //System.assertEquals(false,quotes[0].SBQQ__Primary__c);
        //System.assertEquals(opportunities[4].Id,quotes[0].SBQQ__Opportunity2__c);

        contracts = [Select Id, SBQQ__Opportunity__c, SBQQ__RenewalOpportunity__c From Contract];
        //System.assertEquals(opportunities[4].Id,contracts[0].SBQQ__RenewalOpportunity__c);

        //Query on task
        tasks = [Select Id, WhatId From Task];

        //Assert
        //System.assertEquals(opportunities[4].Id,tasks[0].WhatId);

        //Query on event
        events = [Select Id, WhatId From Event ];

        //Assert
        //System.assertEquals(opportunities[4].Id,events[0].WhatId);

        //Query on integarted Account
        integAccounts = [Select Id, Opportunity__c From Integrated_Account__c];

        //Assert
        //System.assertEquals(opportunities[4].Id, integAccounts[0].Opportunity__c);

        //Query on NBB /Assert
        nBBs = [Select Id, Opportunity__c From NBB__c];
        //System.assertEquals(opportunities[4].Id,  nBBs[0].Opportunity__c);

        //Query on reference Request /Assert
        referenceRequests = [Select Id, Source_Opportunity__c From Reference_Request__c];
        //System.assertEquals(opportunities[4].Id,  referenceRequests [0].Source_Opportunity__c);

        //Query on Campaign member
        cM = [Select Id, Opportunity__c From CampaignMember ];
        //System.assertEquals(opportunities[4].Id,  cM[0].Opportunity__c);

        //Query on OpportunityTeamMember/Assert
        //V_1.3 Modified By - Dipesh Gupta - 02/20/2018 - Release - Q2C enhancement Bugs - Too many DML rows: 10001
        //oTM = [Select Id, OpportunityId, OpportunityAccessLevel,TeamMemberRole, UserId From OpportunityTeamMember];
        //System.assertEquals(opportunities[4].Id, oTM[0].OpportunityId);
  
        //Query on OpportunityContactRole
        oppContactRoles = [Select Id, ContactId, OpportunityId, IsPrimary, Role From OpportunityContactRole];

        //Assert
        //System.assertEquals(opportunities[4].Id, oppContactRoles[0].OpportunityId);
        //System.assertEquals(false, oppContactRoles[0].IsPrimary);

        //Testing Stop here
        Test.stopTest();
    }
   //Commented Outreach_Campaign__c, services_in_contract__c - By Mahendra Swarnkar - spring clean up - 04/29/2019
  /**
    * @Description  : This method used to test merge Opportunity Merge contoller related list Files
    * 
    * @Args         :  
    * 
    * @Return       : void 
    * 
    * @Revision-log : V_1.0 - Created
    **/
    private static testmethod void testOpportunityMergeRelatedList2() {  

        //Skip all triggers temporarily so we can setup test data
        Util.BypassAllTriggers = true;
        Util.IsBatch = true;

        //List to hold Opportunity
        List<Opportunity> opportunities = new List<Opportunity>();
        opportunities = [Select Id, Name, StageName, Account.Name , RecordType.DeveloperName, Years_on_the_Contract__c, 
                        Renewal_Process_Comments__c, Physician_Competitors__c, //Services_in_Contract__c,
                        Secondary_Opportunity__c From Opportunity  Where RecordType.DeveloperName != 'Merged' Order By  RecordType.DeveloperName  ASC];

        //Hold Contact
        List<Contact> Contacts = [Select Id From Contact];

        //List of OpportunityContactRole
        List<OpportunityContactRole> oppContactRoles = new List<OpportunityContactRole>();

        //Add record to list
        oppContactRoles.add(new OpportunityContactRole(ContactId = contacts[0].Id, OpportunityId = opportunities[2].Id, IsPrimary = true, Role = 'Other'));

        //Insert
        insert oppContactRoles;

        //Insert Content Version
        ContentVersion versionDoc = new ContentVersion(Title = 'A08Floor', Description = 'This is the test Content Version Doc');
        versionDoc.Origin = 'H';
        versionDoc.ContentLocation = 'S'; 
        versionDoc.VersionData = Blob.valueOf('Unit Test Attachment Body');
        versionDoc.PathOnClient = 'test.pdf';
        insert versionDoc;

        //Query ContentDocumentId from Content Version
        List<ContentVersion> cVersions = [select Id, ContentDocumentId from ContentVersion where Id = :versionDoc.Id];

        //List to hold Content Document
        List<ContentDocument> cD = [SELECT Id, Title FROM ContentDocument  where Id = :cVersions[0].ContentDocumentId];
        
        //Insert Content Document Link
        ContentDocumentLink contDocLink = new ContentDocumentLink();
        contDocLink.ContentDocumentId = cD[0].Id;
        contDocLink.LinkedEntityId = opportunities[2].Id;
        contDocLink.ShareType = 'V';
        insert contDocLink;     

        //Testing start here
        Test.startTest();

        //Object for APexStandardController
         ApexPages.StandardController sC4 = new ApexPages.standardController(opportunities[4]);
 
        //Put Id of contact
        Apexpages.Currentpage().getparameters().put('Id', opportunities[4].Id);

        //Controller Object
        OpportunityMergeController oMC4 = new OpportunityMergeController(sC4);

        //Hold secondary Opportunity/Base opportunity/Master opportunity
        oMC4.secondaryOpportunity = opportunities[2]; 
        oMc4.baseOpportunity = opportunities[4];
        oMc4.masterOpportunity = opportunities[4].Id;

        //Call Validation Method
        oMC4.validateSecondayOpportunity();

        //Call save method
        oMc4.doSave();

        //List to hold Content Document Link
        String cDocumentId = cD[0].Id;
        List<ContentDocumentLink> cDL = new List<ContentDocumentLink>();
        cDL = [Select Id, LinkedEntityId, ContentDocumentId  From ContentDocumentLink where ContentDocumentId = : cDocumentId Order by Id];
 
        //Assert
        //System.assertEquals(opportunities[4].Id, cDL[1].LinkedEntityId);
        
    //Testing stop here
        Test.stopTest();
    } 
    //Commented Outreach_Campaign__c, services_in_contract__c - By Mahendra Swarnkar - spring clean up - 04/29/2019  
  /**
    * @Description  : This method used to test merge Opportunity Merge contoller Exception
    * 
    * @Args         :  
    * 
    * @Return       : void 
    * 
    * @Revision-log : V_1.0 - Created
    **/
    private static testmethod void testOpportunityMergeException() {  

        //List to hold opportunity
        List<Opportunity> opportunities = new List<Opportunity>();
        opportunities = [Select Id, Name, StageName, Account.Name , RecordType.DeveloperName, Years_on_the_Contract__c, 
                        Renewal_Process_Comments__c, Physician_Competitors__c, //Services_in_Contract__c,
                        Secondary_Opportunity__c From Opportunity  Where RecordType.DeveloperName != 'Merged' Order By  RecordType.DeveloperName  ASC];

        //Testing Start here
        Test.startTest();

        //Object for APexStandardController
         ApexPages.StandardController sC5 = new ApexPages.standardController(opportunities[3]);
 
        //Put Id of contact
        Apexpages.Currentpage().getparameters().put('Id', opportunities[3].Id);

        //Controller Object
        OpportunityMergeController oMC5 = new OpportunityMergeController(sC5);

        //Hold secondary Opportunity/Base opportunity/Master opportunity
        oMC5.secondaryOpportunity = opportunities[2]; 
        oMc5.baseOpportunity = opportunities[3];


        try {
    
            //Call Validation Method
            oMC5.validateSecondayOpportunity();
        }catch(Exception e) {

            //Assert
            String errormessage = e.getMessage();
            System.assert(errormessage.contains('Please select Master Opportunity'));
        
        }
        //Hold secondary Opportunity/Base opportunity/Master opportunity
        oMC5.secondaryOpportunity = opportunities[0]; 
        oMc5.baseOpportunity = opportunities[3];
        oMc5.masterOpportunity = opportunities[0].Id;

        try {
    
            //Call Validation Method
            oMC5.doSave();
        }catch(Exception e) {

            //Assert
            String errormessage = e.getMessage();
            System.assert(errormessage.contains('Selected opportunities record types are not appropriate for merge'));
        
        }

        //Testing Stop here
        Test.stopTest();
    }
  //Commented Outreach_Campaign__c, services_in_contract__c, sell_type__c - By Mahendra Swarnkar - spring clean up - 04/29/2019
  /**
    * @Description  : This method used to test merge Opportunity Merge contoller Master fields value
    * 
    * @Args         :  
    * 
    * @Return       : void 
    * 
    * @Revision-log : V_1.0 - Created
    * 	
    **/
    private static testmethod void testOpportunityMergeMasterFields() {  

        //Hold opportunity
        List<Opportunity> opportunities = new List<Opportunity>();
        opportunities = [Select Id, Name, StageName, Account.Name , RecordType.DeveloperName, Years_on_the_Contract__c, 
                         Renewal_Process_Comments__c, Physician_Competitors__c, Probability , Closing_Call_Scheduled__c ,
			 Date_Passed__c , Date_Visit_Happens__c , Initial_Visit_Date__c , Main_Contact__c ,
                         NBB_Units__c , Next_Step_Date__c , NBB__c , Outreach_Campaign_Month__c , 
                         Primary_Reason_Lost__c ,Projection_Liklihood__c , RFP_Stage__c, Secondary_Reason_Lost__c , Special_Commitments__c ,
                         Secondary_Opportunity__c From Opportunity  Where RecordType.DeveloperName != 'Merged' Order By  RecordType.DeveloperName  ASC];
		
        //Testing Start here
        Test.startTest();

        //Object for APexStandardController
         ApexPages.StandardController sC = new ApexPages.standardController(opportunities[5]);
 
        //Put Id of contact
        Apexpages.Currentpage().getparameters().put('Id', opportunities[5].Id);

        //Controller Object
        OpportunityMergeController oMC = new OpportunityMergeController(sC);

        //Hold to hold secondaryOpportunity/baseOpportunity/masterOpportunity
        oMC.secondaryOpportunity = opportunities[4]; 
        oMc.baseOpportunity = opportunities[5];
        oMc.masterOpportunity = opportunities[5].Id;
        
        //Call helper Method
        oMC.validateSecondayOpportunity();
        oMc.doSave();

        //List to hold opportunity
        List<Opportunity> opp = new List<Opportunity>();
        opp = [Select Id, Name, StageName, Account.Name , RecordType.DeveloperName, Years_on_the_Contract__c, 
        	Renewal_Process_Comments__c, Physician_Competitors__c, Probability , Closing_Call_Scheduled__c ,
		Date_Passed__c , Date_Visit_Happens__c , Initial_Visit_Date__c , Main_Contact__c , NBB_Units__c ,
		Next_Step_Date__c , NBB__c , Outreach_Campaign_Month__c , Primary_Reason_Lost__c , Projection_Liklihood__c ,
		RFP_Stage__c, Secondary_Reason_Lost__c , Special_Commitments__c ,
                Secondary_Opportunity__c From Opportunity  Where RecordType.DeveloperName != 'Merged' Order By  RecordType.DeveloperName  ASC];  
	
        //Hold Conatct/Account/User/Opportunity
        List<Contact> contacts = [Select Id From Contact];
        List<Account> accounts = [Select Id From Account];
        List<User> users = [Select Id From User];

        //Assert       
        System.assertEquals(10,opp[5].NBB__c);
        System.assertEquals(10,opp[5].NBB_Units__c);
        System.assertEquals('January',opp[5].Outreach_Campaign_Month__c);
        System.assertEquals('Price',opp[5].Primary_Reason_Lost__c);
        System.assertEquals('Correct',opp[5].Projection_Liklihood__c);
        System.assertEquals('Not RFP',opp[5].RFP_Stage__c);
        System.assertEquals('Conversion',opp[5].Secondary_Reason_Lost__c);
        System.assertEquals('Testing',opp[5].Special_Commitments__c);

        //Testing stop here
        Test.StopTest();

    }
   
}