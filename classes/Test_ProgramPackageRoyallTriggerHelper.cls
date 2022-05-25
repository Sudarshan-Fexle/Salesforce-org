/**
 *  Description     :   This Apex Test class used to test the "ProgramPackageRoyallTriggerHelper" functionality.
 * 
 *  Created By      :   Victor Hanson
 * 
 *  Created Date    :   03/18/2017
 * 
 *  Revision Logs   :   V_1.0 - Created (CR-20170110-10605)  
                    :   V_1.1 - Modified By Dipesh Gupta - CR-20170221-10712.
                    :   V_1.2 - Modified By Abhinav Sharma - CR-20180809-12493
                        V_1.3 - Modified by Subhash Gharwal -29-04-2019 - Spring cleanup - CR-20190425-13035  
 *
 **/
@isTest
private class Test_ProgramPackageRoyallTriggerHelper {
  
    private static final string Royall_Institution_Formal_Name = 'Test Royall Institution';
    
    /**
     * @description: setup test data for all tests
     **/
    @testSetup
    static void setup() {
        
        //create custom setting default so the trigger will fire to auto-populate programPackage fields
        Account_Status_Management__c acctStatusMgmt = new Account_Status_Management__c(Enable_Update_Account_Status_Trigger__c=true);
        insert acctStatusMgmt;
        
        //create the Royall programs
        list<Program__c> royallPrograms = new list<Program__c>();
        royallPrograms.add(new Program__c(name='Will autopopulate',Status__c='Active',Type__c='Standard',New_Business_Vertical__c='Royall',Business_Line__c=Label.Royall_Business_Line,
                                          New_Business_Business__c='Royall',Program_Line__c='Royall',Create_Memberships__c='Yes',Applicable_Segments__c='US Education',
                                          Program_Formal_Name__c='Royall Advancement',
                                          Program_Acronym__c='RYAF'));
        royallPrograms.add(new Program__c(name='Will autopopulate',Status__c='Active',Type__c='Standard',New_Business_Vertical__c='Royall',Business_Line__c=Label.Royall_Business_Line,
                                          New_Business_Business__c='Royall',Program_Line__c='Royall',Create_Memberships__c='Yes',Applicable_Segments__c='US Education',
                                          Program_Formal_Name__c='Royall Admissions - Graduate',
                                          Program_Acronym__c='RYAG'));
        royallPrograms.add(new Program__c(name='Will autopopulate',Status__c='Active',Type__c='Standard',New_Business_Vertical__c='Royall',Business_Line__c=Label.Royall_Business_Line,
                                          New_Business_Business__c='Royall',Program_Line__c='Royall',Create_Memberships__c='Yes',Applicable_Segments__c='US Education',
                                          Program_Formal_Name__c='Royall Admissions - Undergraduate',
                                          Program_Acronym__c='RYAU'));
        royallPrograms.add(new Program__c(name='Will autopopulate',Status__c='Active',Type__c='Standard',New_Business_Vertical__c='Royall',Business_Line__c=Label.Royall_Business_Line,
                                          New_Business_Business__c='Royall',Program_Line__c='Royall',Create_Memberships__c='Yes',Applicable_Segments__c='US Education',
                                          Program_Formal_Name__c='RYFA - Royall Admissions - Financial Aid',
                                          Program_Acronym__c='RYFA'));
        util.BypassAllTriggers = true;
        insert royallPrograms;
        util.BypassAllTriggers = false;
        
        //setup a US Education Institution
        Account acct = TestUtilities.CreateNewAccount('US Education', false);
        acct.Account_Formal_Name__c = 'Test Institution';
        insert acct;
        
        //setup a Royall Institutions
        list<Account> royallAccts = new list<Account>();
        
        //Advancement
        /*Account acctRoyallAdvancement = TestUtilities.CreateNewAccount(false);
        acctRoyallAdvancement.RecordTypeId = Constants.Account_Royall_Advancement_RT_ID;
        acctRoyallAdvancement.Account_Formal_Name__c = Royall_Institution_Formal_Name + '_Advancement';
        acctRoyallAdvancement.ParentId = acct.Id;
        royallAccts.add(acctRoyallAdvancement);
        //Undergraduate
        Account acctRoyallUndergrad = TestUtilities.CreateNewAccount(false);
        acctRoyallUndergrad.RecordTypeId = Constants.Account_Royall_Undergraduate_RT_ID;
        acctRoyallUndergrad.Account_Formal_Name__c = Royall_Institution_Formal_Name + '_Undergraduate';
        acctRoyallUndergrad.ParentId = acct.Id;
        royallAccts.add(acctRoyallUndergrad); */
        
        //Graduate
        Account acctRoyallGrad = TestUtilities.CreateNewAccount(false);
        acctRoyallGrad.RecordTypeId = Constants.Account_Royall_Graduate_RT_ID;
        acctRoyallGrad.Account_Formal_Name__c = Royall_Institution_Formal_Name + '_Graduate';
        acctRoyallGrad.ParentId = acct.Id;
        royallAccts.add(acctRoyallGrad);
        insert royallAccts;
        
    }
    
    /**
     * @description: create a secured Program Package for the current fiscal year and make sure it activates the associated Royall membership
     *  //Modified by Subhash Gharwal -29-04-2019 - Spring cleanup - CR-20190425-13035  
     **/
    static testmethod void testActiveRoyallMembership() {
        Integer currentFY = shift_get_fiscal_year.current(); 
        
        Account acct,acctRoyallAdvancement,acctRoyallUndergrad,acctRoyallGrad;
        
        //get the institution and related memberships
        //Modified by Subhash Gharwal -29-04-2019 - Spring cleanup - CR-20190425-13035  
        list<Account> accts = [SELECT Id, RecordType.Name, Account_Formal_Name__c, (SELECT Id, Membership_Status_Text__c FROM Memberships__r) FROM Account];
        
        for (Account a : accts) {
            if (a.Account_Formal_Name__c == 'Test Institution')
              acct = a;
             
             /*
             Modified BY Abhianv Sharma - CR-20180809-12493 
             Commented Out all the references of Account_Royall_Advancement_RT_ID, and Account_Royall_Undergraduate_RT_ID - both the record type marked aa zzz.
           
           else if (a.RecordTypeId == Constants.Account_Royall_Advancement_RT_ID)
                acctRoyallAdvancement = a;
            else if (a.RecordTypeId == Constants.Account_Royall_Undergraduate_RT_ID)
                acctRoyallUndergrad = a;*/
                
            else if (a.RecordTypeId == Constants.Account_Royall_Graduate_RT_ID)
                acctRoyallGrad = a;
        }
        
        system.assertEquals('US Education', acct.RecordType.Name);
        system.assertEquals(4, acct.Memberships__r.size());
        
        //List of program Package            
        List<Program_Package__c> progPacks = new List<Program_Package__c>();
        
        //Test data of  Program Package (create an active program package for the current calendar year)
        /*progPacks.add(new Program_Package__c(Name = 'HD_Package_CurrentYear', Account__c = acctRoyallAdvancement.Id, Fiscal_Year__c = String.valueOf(String.ValueOf(currentFY)),
                                             Client_Status_New__c = Label.Client_Status_Secured, Account_Status__c = 'Existing Client', RecordTypeId = Constants.Program_Package_HD_RT_ID));
        progPacks.add(new Program_Package__c(Name = 'HD_Package_NextYear', Account__c = acctRoyallAdvancement.Id, Fiscal_Year__c = String.valueOf(String.ValueOf(currentFY + 1)),
                                             Client_Status_New__c = Label.Client_Status_At_Risk, Account_Status__c = 'Existing Client', RecordTypeId = Constants.Program_Package_HD_RT_ID));
        
        progPacks.add(new Program_Package__c(Name = 'Royall_Advancement_Package_CurrentYear', Account__c = acctRoyallAdvancement.Id, Fiscal_Year__c = String.valueOf(String.ValueOf(currentFY)),
                                             Client_Status_New__c = Label.Client_Status_Secured, Account_Status__c = 'Existing Client', RecordTypeId = Constants.Program_Package_Royall_RT_ID));
        progPacks.add(new Program_Package__c(Name = 'Royall_Advancement_Package_NextYear', Account__c = acctRoyallAdvancement.Id, Fiscal_Year__c = String.valueOf(String.ValueOf(currentFY + 1)),
                                             Client_Status_New__c = Label.Client_Status_At_Risk, Account_Status__c = 'Existing Client', RecordTypeId = Constants.Program_Package_Royall_RT_ID));
        
        progPacks.add(new Program_Package__c(Name = 'Royall_Undergrad_Package_CurrentYear', Account__c = acctRoyallUndergrad.Id, Fiscal_Year__c = String.valueOf(String.ValueOf(currentFY)),
                                             Client_Status_New__c = Label.Client_Status_Secured, Account_Status__c = 'Existing Client', RecordTypeId = Constants.Program_Package_Royall_RT_ID));
        progPacks.add(new Program_Package__c(Name = 'Royall_Undergrad_Package_NextYear', Account__c = acctRoyallUndergrad.Id, Fiscal_Year__c = String.valueOf(String.ValueOf(currentFY + 1)),
                                             Client_Status_New__c = Label.Client_Status_At_Risk, Account_Status__c = 'Existing Client', RecordTypeId = Constants.Program_Package_Royall_RT_ID));
        
        */        
        
        progPacks.add(new Program_Package__c(Name = 'Royall_Grad_Package_CurrentYear', Account__c = acctRoyallGrad.Id, Fiscal_Year__c = String.valueOf(String.ValueOf(currentFY)),
                                             Client_Status_New__c = Label.Client_Status_Secured, Account_Status__c = 'Existing Client', RecordTypeId = Constants.Program_Package_Royall_RT_ID));
        progPacks.add(new Program_Package__c(Name = 'Royall_Grad_Package_NextYear', Account__c = acctRoyallGrad.Id, Fiscal_Year__c = String.valueOf(String.ValueOf(currentFY + 1)),
                                             Client_Status_New__c = Label.Client_Status_At_Risk, Account_Status__c = 'Existing Client', RecordTypeId = Constants.Program_Package_Royall_RT_ID));
        //execute the test
        test.startTest();
        insert progPacks;
        test.stopTest();
        //Modified by Subhash Gharwal -29-04-2019 - Spring cleanup - CR-20190425-13035  
        //get the institution and updated memberships
        acct = [SELECT Id, 
                (SELECT Id, Name, Membership_Status_Text__c, Program_Acronym__c FROM Memberships__r)
                FROM Account WHERE Id = :acct.Id];
        
        //Assert the proper membership was updated with Active Program Package
        /*for (Membership__c membership : acct.Memberships__r) {
            if (membership.Program_Acronym__c == 'RYFA') 
                system.assertEquals('HD_Package_CurrentYear', membership.Active_Program_Package__r.Name);
            else if (membership.Program_Acronym__c == 'RYAU') 
                system.assertEquals('Royall_Undergrad_Package_CurrentYear', membership.Active_Program_Package__r.Name);
            else if (membership.Program_Acronym__c == 'RYAG') 
                system.assertEquals('Royall_Grad_Package_CurrentYear', membership.Active_Program_Package__r.Name);
            else if (membership.Program_Acronym__c == 'RYAF') {}
                //system.assertEquals('Royall_Advancement_Package_CurrentYear', membership.Active_Program_Package__r.Name);
            else
                system.assert(null, membership.Name);
        }*/
    }
    
    /**
     * @description: create a secured Program Package for the current fiscal year and make sure it activates the associated Royall membership
     * 
     * //Modified by Subhash Gharwal -29-04-2019 - Spring cleanup - CR-20190425-13035  
     **/
    static testmethod void testBatch_RoyallMembershipUpdate() {
        Integer currentFY = shift_get_fiscal_year.current(); 
        
        Account acct,acctRoyallAdvancement,acctRoyallUndergrad,acctRoyallGrad;
        
        //Modified by Subhash Gharwal -29-04-2019 - Spring cleanup - CR-20190425-13035  
        //get the institution and related memberships
        list<Account> accts = [SELECT Id, RecordType.Name, Account_Formal_Name__c, (SELECT Id, Membership_Status_Text__c/*, Active_Program_Package__c*/ FROM Memberships__r) FROM Account];
        for (Account a : accts) {
            if (a.Account_Formal_Name__c == 'Test Institution')
              acct = a;
            /*else if (a.RecordTypeId == Constants.Account_Royall_Advancement_RT_ID)
                acctRoyallAdvancement = a;
            else if (a.RecordTypeId == Constants.Account_Royall_Undergraduate_RT_ID)
                acctRoyallUndergrad = a;*/
            else if (a.RecordTypeId == Constants.Account_Royall_Graduate_RT_ID)
                acctRoyallGrad = a;
        }
        
        system.assertEquals('US Education', acct.RecordType.Name);
        system.assertEquals(4, acct.Memberships__r.size());
        
        //List of program Package            
        List<Program_Package__c> progPacks = new List<Program_Package__c>();
        
        //Test data of  Program Package (create an active program package for the current calendar year)
      /*  progPacks.add(new Program_Package__c(Name = 'HD_Package_CurrentYear', Account__c = acctRoyallAdvancement.Id, Fiscal_Year__c = String.valueOf(String.ValueOf(currentFY)),
                                             Client_Status_New__c = Label.Client_Status_Secured, Account_Status__c = 'Existing Client', RecordTypeId = Constants.Program_Package_HD_RT_ID));
        progPacks.add(new Program_Package__c(Name = 'HD_Package_NextYear', Account__c = acctRoyallAdvancement.Id, Fiscal_Year__c = String.valueOf(String.ValueOf(currentFY + 1)),
                                             Client_Status_New__c = Label.Client_Status_At_Risk, Account_Status__c = 'Existing Client', RecordTypeId = Constants.Program_Package_HD_RT_ID));
        
        progPacks.add(new Program_Package__c(Name = 'Royall_Advancement_Package_CurrentYear', Account__c = acctRoyallAdvancement.Id, Fiscal_Year__c = String.valueOf(String.ValueOf(currentFY)),
                                             Client_Status_New__c = Label.Client_Status_Secured, Account_Status__c = 'Existing Client', RecordTypeId = Constants.Program_Package_Royall_RT_ID));
        progPacks.add(new Program_Package__c(Name = 'Royall_Advancement_Package_NextYear', Account__c = acctRoyallAdvancement.Id, Fiscal_Year__c = String.valueOf(String.ValueOf(currentFY + 1)),
                                             Client_Status_New__c = Label.Client_Status_At_Risk, Account_Status__c = 'Existing Client', RecordTypeId = Constants.Program_Package_Royall_RT_ID));
        
        progPacks.add(new Program_Package__c(Name = 'Royall_Undergrad_Package_CurrentYear', Account__c = acctRoyallUndergrad.Id, Fiscal_Year__c = String.valueOf(String.ValueOf(currentFY)),
                                             Client_Status_New__c = Label.Client_Status_Secured, Account_Status__c = 'Existing Client', RecordTypeId = Constants.Program_Package_Royall_RT_ID));
        progPacks.add(new Program_Package__c(Name = 'Royall_Undergrad_Package_NextYear', Account__c = acctRoyallUndergrad.Id, Fiscal_Year__c = String.valueOf(String.ValueOf(currentFY + 1)),
                                             Client_Status_New__c = Label.Client_Status_At_Risk, Account_Status__c = 'Existing Client', RecordTypeId = Constants.Program_Package_Royall_RT_ID));
        */
        progPacks.add(new Program_Package__c(Name = 'Royall_Grad_Package_CurrentYear', Account__c = acctRoyallGrad.Id, Fiscal_Year__c = String.valueOf(String.ValueOf(currentFY)),
                                             Client_Status_New__c = Label.Client_Status_Secured, Account_Status__c = 'Existing Client', RecordTypeId = Constants.Program_Package_Royall_RT_ID));
        progPacks.add(new Program_Package__c(Name = 'Royall_Grad_Package_NextYear', Account__c = acctRoyallGrad.Id, Fiscal_Year__c = String.valueOf(String.ValueOf(currentFY + 1)),
                                             Client_Status_New__c = Label.Client_Status_At_Risk, Account_Status__c = 'Existing Client', RecordTypeId = Constants.Program_Package_Royall_RT_ID));
        //bypass triggers when inserting, so it doesn't trigger an update immediately
        util.BypassAllTriggers = true;
        insert progPacks;
        util.BypassAllTriggers = false;
        
        //start here 
        //Modified by Subhash Gharwal -29-04-2019 - Spring cleanup - CR-20190425-13035  
        acct = [SELECT Id, 
                (SELECT Id, Name, Membership_Status_Text__c/*, Active_Program_Package__c*/, Program_Acronym__c/*, Active_Program_Package__r.Name*/ FROM Memberships__r)
                FROM Account WHERE Id = :acct.Id];
       // for (Membership__c membership : acct.Memberships__r) system.assertEquals(null, membership.Active_Program_Package__c);
        
        //execute the test
        test.startTest();
        Batch_RoyallMembershipUpdate b = new Batch_RoyallMembershipUpdate();
        b.QueryString = 'SELECT Id FROM Program_Package__c WHERE CreatedDate = TODAY';
        database.executeBatch(b, 50);
        test.stopTest();
        
        //get the institution and updated memberships
        acct = [SELECT Id, 
                (SELECT Id, Name, Membership_Status_Text__c/*, Active_Program_Package__c*/, Program_Acronym__c/*, Active_Program_Package__r.Name*/ FROM Memberships__r)
                FROM Account WHERE Id = :acct.Id];
        //end here
        //Modified by Subhash Gharwal -29-04-2019 - Spring cleanup - CR-20190425-13035    
        
        //Assert the proper membership was updated with Active Program Package
        for (Membership__c membership : acct.Memberships__r) {
           /* if (membership.Program_Acronym__c == 'RYFA') 
                system.assertEquals('HD_Package_CurrentYear', membership.Active_Program_Package__r.Name);
            else if (membership.Program_Acronym__c == 'RYAU') 
                system.assertEquals('Royall_Undergrad_Package_CurrentYear', membership.Active_Program_Package__r.Name);
            else if (membership.Program_Acronym__c == 'RYAG') 
                system.assertEquals('Royall_Grad_Package_CurrentYear', membership.Active_Program_Package__r.Name);
            else if (membership.Program_Acronym__c == 'RYAF') 
                system.assertEquals('Royall_Advancement_Package_CurrentYear', membership.Active_Program_Package__r.Name);
            else
                system.assert(null, membership.Name);*/
        }
    }
    
   /**
    *  @description    :   This method is used to test the functtionality of populating job no of royall Program.
    *
    *  @args           :   
    *
    *  @return         :   void 
    *
    *  Revision logs   :   Added By Dipesh Gupta - CR-20170221-10712
    *
    **/
    static testMethod void test_RoyallProgramJobNo() {
        
        //List to hold the Accoun
        List<Account> accounts = New List<Account>();
        
        Util.BypassAllTriggers = true; 
        
        //Add new account in list
        accounts.add(new Account(Name = 'Account 1',  r_School_Code__c = '11'));
        accounts.add(new Account(Name = 'Account 2',  r_School_Code__c = 'AB'));
        
        insert accounts;
        Util.BypassAllTriggers = false; 
        
        //Inserting program Package under the Account 
        //Get the Royall record type of Program Package 
        List<RecordType> ppRoyallRecordType = [Select Id From RecordType 
                                               Where sObjectType =: 'Program_Package__c' AND DeveloperName =: Label.PROGRAM_PACKAGE_RECORD_TYPE_DEVELOPER_NAME_ROYALL]; 
        
        //List to old the Program package records 
        List<Program_Package__c> listProgramPackage = new List<Program_Package__c>();
        
        //Populate the list
        listProgramPackage.add( new Program_Package__c ( Account__c = accounts[0].id, Name = 'ShiftTest1', Client_Status_New__c = 'In Play', 
                                                        Fiscal_Year__c = '2017' ,
                                                        RecordTypeId = ppRoyallRecordType[0].Id ));
        
        listProgramPackage.add( new Program_Package__c ( Account__c = accounts[1].id, Name = 'ShiftTest2', Client_Status_New__c = 'Secured',
                                                        Fiscal_Year__c = '2018', 
                                                        RecordTypeId = ppRoyallRecordType[0].Id ));
        
        insert listProgramPackage;
        
        //===============================================================Royall Programs==============================================================================================
        //Insert the Program records
        List<Royall_Program__c> rPrograms = new List<Royall_Program__c> ();
        
        rPrograms.add(new Royall_Program__c ( Name = 'Test Program1', Program_Package__c = listProgramPackage[0].Id, Target_Audience_New__c = 'Financial Aid Clients',
                                             Campaign_New__c = 'Other', Type__c = 'Discount Allocation', Probability__c = 10,
                                             Contact_Quantity__c = 1,
                                             Status__c = 'opportunity', Billable_Travel__c = 20));
        
        rPrograms.add(new Royall_Program__c ( Name = 'Test Program2', Program_Package__c = listProgramPackage[1].Id, Target_Audience_New__c = 'Financial Aid Clients',
                                             Campaign_New__c = 'Other', Type__c = 'Discount Allocation', Probability__c = 10,Contact_Quantity__c = 1, 
                                             Status__c = 'opportunity', Billable_Travel__c = 20));
        //Insert programs
        insert  rPrograms;
        
        List<Royall_Program__c> royallPrograms = [Select Id, Name,Lock_the_Record__c From Royall_Program__c order by CreatedDate DESC];
        system.assertEquals('11' , royallPrograms[0].Name.SubString(0,2) );
        system.assertEquals('AB',royallPrograms[1].Name.SubString(0,2) );
        system.assertEquals('1117',royallPrograms[0].Name.SubString(0,4));
        system.assertEquals('AB18', royallPrograms[1].Name.SubString(0,4));
        system.assertEquals('111753',royallPrograms[0].Name);
        system.assertEquals('AB1853', royallPrograms[1].Name);
        
        Test.startTest();
        
        List<Program_Package__c> programPackages = [Select Id, Account__c From Program_Package__c Order By Fiscal_Year__c];
        
        //Changing Account on both program packages
        programPackages[0].Account__c = accounts[1].id;
        programPackages[1].Account__c = accounts[0].id;
        
        update programPackages;   
        
        system.assertEquals(2,programPackages.size());
        
        //Query on the royall program 
        List<Royall_Program__c> royallPrograms1 = [Select Id, Name From Royall_Program__c order by CreatedDate DESC];
        
        system.assertEquals('AB1753', royallPrograms1[0].Name);
        system.assertEquals('111853', royallPrograms1[1].Name);
        
        //Permission set assignment. 
        PermissionSetAssignment pSA = [Select Id, AssigneeId  From PermissionSetAssignment Where Assignee.Profile.Name = 'System Administrator' 
                                       AND Assignee.IsActive = true LIMIT 1];
        
        //Query program Package.
        List<Program_Package__c> progPackage = [Select Name, Account__c, Fiscal_Year__c, Client_Status_New__c, Account_Status__c From Program_Package__c
                                                Where Client_Status_New__c != null AND Id IN: listProgramPackage];
        
        List<Membership__c> existingMemberships = [Select Id From Membership__c Limit 1];      
        
        List<User> usersHavingAccess = [Select Id From User Where Id =: pSA.AssigneeId LIMIT 1];
        
         
        System.runAs(usersHavingAccess[0]) {
            progPackage[0].Client_Lost_Date__c = Date.today();
            progPackage[0].Lost_To__c = 'Other' ;
            progPackage[0].Reason_for_Loss__c = 'Other' ;
            progPackage[0].Client_Status_New__c = 'Lost';
            progPackage[0].Membership__c = existingMemberships != null ? existingMemberships[0].Id : null ;
            
            try{
                //update propgram package
                update progPackage[0]; 
            }catch(Exception e) {
                System.assert(e.getMessage().contains(Label.Error_Msg_Prog_Pck_update));
            }   
        }
        Test.stopTest();
    }
    static testMethod void test_syncRenewalDetailsOnProgramPackage(){
        //Bypassing all triggers 
        Util.byPassAllTriggers = true;
        Util.IsTest(true); 
        
        //Creating program record
        List<Program__c> programs = new List<Program__c> ();
        programs.add(TestUtilities.CreateNewProgram(true));
        
        //Insert Products
        List<Product2> products = new List<Product2>();
        
        //Add new Products in List
        products.add(new Product2(Name = 'TMBH - Test Method', Family = 'Enrollment Services', Program__c = programs[0].Id, IsActive = true,
                                  ProductCode = 'TMBH', SBQQ__Component__c = false, Program_Name_Member_Facing__c = 'Student Success Management Intelligence',
                                  SBQQ__AssetConversion__c = 'One per quote line', SBQQ__DefaultQuantity__c = 1,
                                  SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__SubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List'));
        
        products.add(new Product2(Name = 'New Names', Family = 'Enrollment Services', IsActive = true,
                                  ProductCode = 'TMBH', SBQQ__Component__c = false, Program_Name_Member_Facing__c = 'New Names',
                                  SBQQ__AssetConversion__c = 'One per quote line', SBQQ__DefaultQuantity__c = 1,
                                  SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__SubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List'));
        
        //Add new Products in List
        products.add(new Product2(Name = 'Program Costs', IsActive = true, ProductCode = 'Program Costs', SBQQ__Component__c = true,
                                  Product_Category__c = 'Annual Fee', Program_Name_Member_Facing__c = 'Program Costs',
                                  SBQQ__AssetConversion__c = 'One per quote line', SBQQ__DefaultQuantity__c = 1));
        
        insert products;
        
        //List to insert Feature
        List<SBQQ__ProductFeature__c> features = new List<SBQQ__ProductFeature__c>();
        
        //Add Feature record in list to insert
        features.add(new SBQQ__ProductFeature__c(Name = 'New Name', SBQQ__Number__c = 10, SBQQ__MinOptionCount__c = 1, SBQQ__MaxOptionCount__c = 1,
                                                 SBQQ__ConfiguredSKU__c = products[0].Id));
        //Add Feature record in list to insert
        features.add(new SBQQ__ProductFeature__c(Name = 'Program Costs', SBQQ__Number__c = 10, SBQQ__MinOptionCount__c = 1, SBQQ__MaxOptionCount__c = 1,
                                                 SBQQ__ConfiguredSKU__c = products[1].Id));
        
        //Insert
        insert features;
        
        //List to insert Product Options
        List<SBQQ__ProductOption__c> productsOptions = new List<SBQQ__ProductOption__c>();
        
        //Add records in list to insert
        productsOptions.add(new SBQQ__ProductOption__c(SBQQ__ConfiguredSKU__c = products[0].Id, SBQQ__OptionalSKU__c = products[1].Id,
                                                       SBQQ__Number__c = 10, SBQQ__Quantity__c = 1, SBQQ__Feature__c = features[0].Id,
                                                       SBQQ__Type__c = 'Component', SBQQ__Selected__c = true, SBQQ__Required__c = true));
        
        //Add records in list to insert
        productsOptions.add(new SBQQ__ProductOption__c(SBQQ__ConfiguredSKU__c = products[1].Id, SBQQ__OptionalSKU__c = products[2].Id,
                                                       SBQQ__Number__c = 10, SBQQ__Quantity__c = 1, SBQQ__Feature__c = features[1].Id,
                                                       SBQQ__Type__c = 'Component', SBQQ__Selected__c = true, SBQQ__Required__c = true));
        
        //Insert
        insert productsOptions;
        
        //Get Record Type
        Id accountUSCorporateRecordType = TestUtilities.FindRecordTypeId('Account', 'US Education'); 
        
        //Get Account
        List<Account> accounts = new List<Account>();
        
        //Creating Account record
        Account account = TestUtilities.CreateNewAccount(false);
        account.RecordTypeId = accountUSCorporateRecordType;
        accounts.add(account);
        insert accounts;
        
        //Creating Membership records
        Membership__c membership = TestUtilities.CreateNewMembership(account.Id, programs[0].Id, false);
        membership.RecordTypeId = Constants.Membership_Record_Type_Enrollment;
        
        
        insert membership;
        
        //Program Package "EAB" Record Type Id
        Id programPackage_EAB_RTypeId = TestUtilities.FindRecordTypeId('Program_Package__c','EAB' );
        
        List<Program_Package__c> progPacks = new List<Program_Package__c>();
        
        progPacks.add(new Program_Package__c(Name = 'Test1', Account__c = account.Id, Fiscal_Year__c = String.valueOf(Date.Today().Year()), Membership__c = membership.Id,
                                             Client_Status_New__c = Label.Client_Status_Secured, Account_Status__c = 'New Client', RecordTypeId = programPackage_EAB_RTypeId));
        
        progPacks.add(new Program_Package__c(Name = 'Test2', Account__c = account.Id, Fiscal_Year__c = String.valueOf(Date.Today().Year()+1), Membership__c = membership.Id,
                                             Client_Status_New__c = Label.Client_Status_At_Risk, Account_Status__c = 'New Client', RecordTypeId = programPackage_EAB_RTypeId));
        
        progPacks.add(new Program_Package__c(Name = 'Test3', Account__c = account.Id, Fiscal_Year__c = String.valueOf(Date.Today().Year()+2), Membership__c = membership.Id,
                                             Client_Status_New__c = Label.Client_Status_At_Risk, Account_Status__c = 'New Client', RecordTypeId = programPackage_EAB_RTypeId));
        
        progPacks.add(new Program_Package__c(Name = 'Test4', Account__c = account.Id, Fiscal_Year__c = String.valueOf(Date.Today().Year()+3), Membership__c = membership.Id,
                                             Client_Status_New__c = Label.Client_Status_At_Risk, Account_Status__c = 'New Client', RecordTypeId = programPackage_EAB_RTypeId));
        
        insert progPacks;
        
        //Get Contact
        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(LastName = 'TestingABC', AccountId = account.Id, Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855'));
        insert contacts;
        
        //Get all record types of Opportunity
        Map<String, Id> mapOpportunityRecordTypes = Util.recordtypemap('Opportunity');
        
        //List of opportunity
        List<Opportunity> opportunities = new List<Opportunity>();
        
        //Creating Opportunity record
        Opportunity opp = TestUtilities.CreateNewOpportunity(false);
        opp.Contract_Signature_Date__c = Date.today();
        opp.StageName = 'O-MQL';
        opp.RecordTypeId = mapOpportunityRecordTypes.get('EAB Initiating');
        
        opportunities.add(opp);
        
        //Update
        insert opportunities;
        
        //List of Proposal
        List<SBQQ__Quote__c> proposals = new List<SBQQ__Quote__c>();
        
        //Add new proposal record in list
        proposals.add(new SBQQ__Quote__c(SBQQ__Type__c = 'Quote', SBQQ__Primary__c = true, 
                                         SBQQ__StartDate__c = Date.today(), SBQQ__SubscriptionTerm__c =36,
                                         SBQQ__EndDate__c = System.today().addYears(3), SBQQ__Opportunity2__c = opportunities[0].Id, 
                                         SBQQ__Status__c = 'Locked', SBQQ__PrimaryContact__c = contacts[0].Id, 
                                         SBQQ__Account__c = accounts[0].Id, SBQQ__SalesRep__c = Userinfo.getUserId(),
                                         SBQQ__Pricebook__c = Test.getStandardPricebookId(), SBQQ__PricebookId__c=Test.getStandardPricebookId()));
        
        Util.BypassAllTriggers = true;
        
        //Insert list of Quote
        insert proposals;
        
        //Add Proposal Lines under the Proposal
        SBQQ__QuoteLine__c mainProposalLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[0].Id, SBQQ__Number__c = 11,
                                                                     SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 4, SBQQ__SpecialPrice__c = 0,
                                                                     SBQQ__PricingMethod__c = 'List', Annual_Increase__c = 5, Calculator__c = 'Calculator - BHAN : 12 : NBB',
                                                                     SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List');
        
        //Insert list of Quote
        insert mainProposalLine;
        
        //Add Proposal Lines under the Proposal
        SBQQ__QuoteLine__c midProposalLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[1].Id, SBQQ__Number__c = 12,
                                                                    SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 1, SBQQ__SpecialPrice__c = 0, SBQQ__ProductOption__c = productsOptions[0].Id,
                                                                    SBQQ__RequiredBy__c = mainProposalLine.Id, SBQQ__PricingMethod__c = 'List', Annual_Increase__c = 5, Calculator__c = 'Calculator - BHAN : 12 : NBB',
                                                                    SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List');
        
        //Insert list of Quote
        insert midProposalLine;
        
        //List of Contract records
        List<Contract> contracts = new List<Contract>();
        
        //Add new contract record in list
        contracts.add(new Contract(AccountId = accounts[0].Id, Status = 'Draft', StartDate = Date.today() + 2, ContractTerm = 2,EndDate = Date.today() + 7, SBQQ__Opportunity__c = opportunities[0].Id, SBQQ__Quote__c = proposals[0].Id));
        insert contracts;
        
        opportunities[0].SBQQ__PrimaryQuote__c = proposals[0].Id;
        opportunities[0].StageName = 'Contract Received - Send to Finance';
        opportunities[0].SBQQ__Contracted__c = true;
        
        update opportunities;
        
        opportunities[0].StageName = 'Closed Won';
        
        Update opportunities;
        
        contracts[0].Status = 'Activated_Amended';
        contracts[0].Amendment_Type__c = 'Amend & Extend';
        contracts[0].SBQQ__RenewalTerm__c = 36;
        contracts[0].SBQQ__RenewalPricebookId__c = '01sC00000003gcn'; 
        contracts[0].SBQQ__RenewalOpportunityStage__c = 'pending';
        contracts[0].SBQQ__AmendmentRenewalBehavior__c = 'Latest End Date';
        contracts[0].SBQQ__DefaultRenewalContactRoles__c = true;
        contracts[0].SBQQ__DefaultRenewalPartners__c = true;
        
        Update contracts;
        
        //Assert
        System.assertEquals(1, contracts.size());  
        
        List<Membership__c> memberships = [select id from membership__c];
        
        //Query on Subscription Record Types
        List<RecordType> recrdTypes = [Select Id, DeveloperName From RecordType Where SobjectType = 'SBQQ__Subscription__c' 
                                       AND DeveloperName IN ('Program', 'Component') AND IsActive = true ORDER BY DeveloperName DESC];
        //Creating Subscription record
        //List to hold subscription
        List<SBQQ__Subscription__c> programSubscriptions = new List<SBQQ__Subscription__c>();  
        
        //Add new subscription record in list
        programSubscriptions.add(new SBQQ__Subscription__c(RecordTypeId = recrdTypes[0].Id, SBQQ__Account__c = accounts[0].Id,
                                                           SBQQ__Quantity__c = 1, Source_Opportunity__c = opportunities[0].Id,
                                                           SBQQ__ListPrice__c = 0, Stage_Period__c = 'Pending',SBQQ__Contract__c = contracts[0].Id,
                                                           SBQQ__Product__c = products[0].ID, Program__c = programs[0].ID,
                                                           SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0, SBQQ__ProrateMultiplier__c = 2,
                                                           Status__c = 'Committed', Invoice_Contact__c = contacts[0].Id));
        
        
        
        //Insert
        insert programSubscriptions;
        
        //Add new subscription record in list
        SBQQ__Subscription__c proSub = new SBQQ__Subscription__c(RecordTypeId = recrdTypes[0].Id, SBQQ__Account__c = accounts[0].Id,
                                                                 SBQQ__Quantity__c = 1, Source_Opportunity__c = opportunities[0].Id,
                                                                 SBQQ__ListPrice__c = 0, Stage_Period__c = 'Pending',SBQQ__Contract__c = contracts[0].Id,
                                                                 SBQQ__Product__c = products[1].ID, Parent_Program__c = programs[0].ID,
                                                                 SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0, SBQQ__ProrateMultiplier__c = 2,
                                                                 Status__c = 'Committed', Invoice_Contact__c = contacts[0].Id, 
                                                                 SBQQ__RequiredByProduct__c = products[0].ID, Program_Subscription__c = programSubscriptions[0].Id);
        insert proSub;
        
        programSubscriptions.add(proSub);
        
        List<Subscription_Period__c> subscriptionPeriods = new List<Subscription_Period__c>();
        
        //Creating Subscription Period record
        Subscription_Period__c sPeriod = TestUtilities.createNewSubscriptionPeriod(programSubscriptions[1].Id, false);
        sPeriod.Institution__c = accounts[0].Id;
        sPeriod.Period_End_Date__c = Date.Today().addYears(1);
        sPeriod.Contract__c = contracts[0].Id;
        sPeriod.Source_Opportunity__c = opportunities[0].Id;
        sPeriod.Membership_Lookup__c = membership.Id;
        sPeriod.Program_Package__c = progPacks[0].Id;
        sPeriod.Stage__c = 'ATL';
        subscriptionPeriods.add(sPeriod);
        
        //Creating Subscription Period record
        Subscription_Period__c sPeriod1 = TestUtilities.createNewSubscriptionPeriod(programSubscriptions[1].Id, false);
        sPeriod1.Institution__c = accounts[0].Id;
        sPeriod1.Period_Start_Date__c = Date.Today().addYears(1).addDays(1);
        sPeriod1.Period_End_Date__c = Date.Today().addYears(2);
        sPeriod1.Contract__c = contracts[0].Id;
        sPeriod1.Source_Opportunity__c = opportunities[0].Id;
        sPeriod1.Membership_Lookup__c = membership.Id;
        sPeriod1.Program_Package__c = progPacks[1].Id;
        sPeriod1.Stage__c = 'ATL';
        subscriptionPeriods.add(sPeriod1);
        
        //Creating Subscription Period record
        Subscription_Period__c sPeriod2 = TestUtilities.createNewSubscriptionPeriod(programSubscriptions[1].Id, false);
        sPeriod2.Institution__c = accounts[0].Id;
        sPeriod2.Period_Start_Date__c = Date.Today().addYears(2).addDays(1);
        sPeriod2.Period_End_Date__c = Date.Today().addYears(3);
        sPeriod2.Contract__c = contracts[0].Id;
        sPeriod2.Source_Opportunity__c = opportunities[0].Id;
        sPeriod2.Stage__c = 'ATL';
        sPeriod2.Membership_Lookup__c = membership.Id;
        sPeriod2.Program_Package__c = progPacks[2].Id;
        subscriptionPeriods.add(sPeriod2);
        
        //Creating Subscription Period record
        Subscription_Period__c sPeriod3 = TestUtilities.createNewSubscriptionPeriod(programSubscriptions[1].Id, false);
        
        sPeriod3.Institution__c = accounts[0].Id;
        sPeriod3.Period_Start_Date__c = Date.Today().addYears(3).addDays(1);
        sPeriod3.Period_End_Date__c = Date.Today().addYears(4);
        sPeriod3.Contract__c = contracts[0].Id;
        sPeriod3.Source_Opportunity__c = opportunities[0].Id;
        sPeriod3.Stage__c = 'Pending';
        sPeriod3.Membership_Lookup__c = membership.Id;
        sPeriod3.Program_Package__c = progPacks[3].Id;
        
        subscriptionPeriods.add(sPeriod3);
        
        insert subscriptionPeriods;
        
        
        Set<Id> spIds = new Set<Id>();
        
        for(Subscription_Period__c sp : [Select Id from Subscription_Period__c]) spIds.add(sp.Id);
        
        List<SBQQ__Subscription__c> listcomponentSubscription = new List<SBQQ__Subscription__c>();
        
        //Creating Component Subscriptions
        SBQQ__Subscription__c componentSubscription = TestUtilities.createNewSubscription(memberships[0].Id, false);
        
        componentSubscription.SBQQ__Contract__c = contracts[0].Id;
        componentSubscription.Subscription_Period__c = subscriptionPeriods[0].Id;
        componentSubscription.recordTypeId = recrdTypes[1].Id;
        componentSubscription.Opportunity__c = opportunities[0].Id;
        componentSubscription.Source_Opportunity__c = opportunities[0].Id;
        componentSubscription.SBQQ__RequiredByProduct__c = products[1].ID;
        componentSubscription.SBQQ__Product__c = products[2].ID;
        componentSubscription.SBQQ__SegmentStartDate__c = Date.today();
        componentSubscription.Program_Subscription__c = programSubscriptions[1].Id;
        componentSubscription.SBQQ__RenewalPrice__c = 100;
        componentSubscription.SBQQ__CustomerPrice__c = 100; 
        componentSubscription.Membership_Period__c  = progPacks[0].Id;
        
        listcomponentSubscription.add(componentSubscription);
        
        //Creating Subscription record
        SBQQ__Subscription__c componentSubscription1 = TestUtilities.createNewSubscription(memberships[0].Id, false);
        
        componentSubscription1.SBQQ__Contract__c = contracts[0].Id;
        componentSubscription1.Subscription_Period__c = subscriptionPeriods[1].Id;
        componentSubscription1.recordTypeId = recrdTypes[1].Id;
        componentSubscription1.Opportunity__c = opportunities[0].Id;
        componentSubscription1.Source_Opportunity__c = opportunities[0].Id;
        componentSubscription1.SBQQ__RequiredByProduct__c = products[1].ID;
        componentSubscription1.SBQQ__Product__c = products[2].ID;
        componentSubscription1.SBQQ__SegmentStartDate__c = Date.today().addYears(1);
        componentSubscription1.Program_Subscription__c = programSubscriptions[1].Id;
        componentSubscription1.SBQQ__RenewalPrice__c = 100;
        componentSubscription1.SBQQ__CustomerPrice__c = 100; 
        componentSubscription1.Postage_Costs_m__c = 100; 
        componentSubscription1.Media_Costs_m__c = 100; 
        componentSubscription1.Membership_Period__c  = progPacks[1].Id;
        
        listcomponentSubscription.add(componentSubscription1);
        
        //Creating Subscription record
        SBQQ__Subscription__c componentSubscription2 = TestUtilities.createNewSubscription(memberships[0].Id, false);
        
        componentSubscription2.SBQQ__Contract__c = contracts[0].Id;
        componentSubscription2.Subscription_Period__c = subscriptionPeriods[1].Id;
        componentSubscription2.recordTypeId = recrdTypes[1].Id;
        componentSubscription2.Opportunity__c = opportunities[0].Id;
        componentSubscription2.Source_Opportunity__c = opportunities[0].Id;
        componentSubscription2.SBQQ__RequiredByProduct__c = products[1].ID;
        componentSubscription2.SBQQ__Product__c = products[2].ID;
        componentSubscription2.SBQQ__SegmentStartDate__c = Date.today().addYears(1);
        componentSubscription2.Program_Subscription__c = programSubscriptions[1].Id;
        componentSubscription2.SBQQ__RenewalPrice__c = 100;
        componentSubscription2.SBQQ__CustomerPrice__c = 100; 
        componentSubscription2.Postage_Costs_m__c = 100; 
        componentSubscription2.Media_Costs_m__c = 100; 
        
        componentSubscription2.Membership_Period__c  = progPacks[1].Id;
        
        listcomponentSubscription.add(componentSubscription2);
        
        //Creating Subscription record
        SBQQ__Subscription__c componentSubscription3 = TestUtilities.createNewSubscription(memberships[0].Id, false);
        
        componentSubscription3.SBQQ__Contract__c = contracts[0].Id;
        componentSubscription3.Subscription_Period__c = subscriptionPeriods[2].Id;
        componentSubscription3.recordTypeId = recrdTypes[1].Id;
        componentSubscription3.Opportunity__c = opportunities[0].Id;
        componentSubscription3.Source_Opportunity__c = opportunities[0].Id;
        componentSubscription3.SBQQ__RequiredByProduct__c = products[1].ID;
        componentSubscription3.SBQQ__Product__c = products[2].ID;
        componentSubscription3.SBQQ__SegmentStartDate__c = Date.today().addYears(2);
        componentSubscription3.Program_Subscription__c = programSubscriptions[1].Id;
        componentSubscription3.SBQQ__RenewalPrice__c = 100;
        componentSubscription3.SBQQ__CustomerPrice__c = 100; 
        componentSubscription3.Postage_Costs_m__c = 100; 
        componentSubscription3.Media_Costs_m__c = 100;
        componentSubscription3.Membership_Period__c  = progPacks[2].Id;
        
        listcomponentSubscription.add(componentSubscription3);
        
        //Insert componentSubscription
        insert listcomponentSubscription;
        
        Test.startTest();
        
        Util.byPassAllTriggers = false;
        
        Map<Id, Program_Package__c> mapProPackage = new Map<Id, Program_Package__c>();
        mapProPackage.putAll(progPacks);
        
        ProgramPackageRoyallTriggerHelper.populateRollUpFields(mapProPackage);
        
        for(Program_Package__c pp : progPacks ){
            
            pp.Account_Status__c = 'New ClientExisting Client';
        }
        
        update progPacks;
        
        Util.byPassAllTriggers = true;
        
        //Creating Opportunity record
        Opportunity opp1 = TestUtilities.CreateNewOpportunity(false);
        opp1.Contract_Signature_Date__c = Date.today();
        opp1.StageName = 'Pending';
        opp1.RecordTypeId = mapOpportunityRecordTypes.get('EAB Continuing');
        
        insert opp1; 
        
        SBQQ__Quote__c renewProposal = new SBQQ__Quote__c(SBQQ__Type__c = 'Quote', SBQQ__Primary__c = true, 
                                                          SBQQ__StartDate__c = Date.today(), SBQQ__SubscriptionTerm__c =36,
                                                          SBQQ__EndDate__c = System.today().addYears(3), SBQQ__Opportunity2__c = opp1.Id, 
                                                          SBQQ__Status__c = 'Locked', SBQQ__PrimaryContact__c = contacts[0].Id, 
                                                          SBQQ__Account__c = accounts[0].Id, SBQQ__SalesRep__c = Userinfo.getUserId(),
                                                          SBQQ__Pricebook__c = Test.getStandardPricebookId(), SBQQ__PricebookId__c=Test.getStandardPricebookId());
        
        //Insert list of Quote
        insert renewProposal;
        
        //Add Proposal Lines under the Proposal
        SBQQ__QuoteLine__c renewMainProposalLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = renewProposal.Id, SBQQ__Product__c = products[0].Id, SBQQ__Number__c = 11,
                                                                          SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 4, SBQQ__SpecialPrice__c = 0,
                                                                          SBQQ__PricingMethod__c = 'List', Annual_Increase__c = 5, Calculator__c = 'Calculator - BHAN : 12 : NBB',
                                                                          SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List');
        
        //Insert list of Quote
        insert renewMainProposalLine;
        
        //Add Proposal Lines under the Proposal
        SBQQ__QuoteLine__c renewMidProposalLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = renewProposal.Id, SBQQ__Product__c = products[1].Id, SBQQ__Number__c = 12,
                                                                         SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 1, SBQQ__SpecialPrice__c = 0, SBQQ__ProductOption__c = productsOptions[0].Id,  
                                                                         SBQQ__RequiredBy__c = renewMainProposalLine.Id, SBQQ__PricingMethod__c = 'List', Annual_Increase__c = 5, Calculator__c = 'Calculator - BHAN : 12 : NBB',
                                                                         SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List', SBQQ__RenewedSubscription__c = programSubscriptions[1].Id);
        
        //Insert list of Quote
        insert renewMidProposalLine;
        
        //List to insert Annual Fee and Trevel fee Proposal Lines
        List<SBQQ__QuoteLine__c> subProposalLines = new List<SBQQ__QuoteLine__c>();
        
        //Add Proposal lines in list
        //Add Annual Fee products
        subProposalLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = renewProposal.Id, SBQQ__Product__c = products[2].Id, SBQQ__Number__c = 1,
                                                    SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 0.5861, SBQQ__ProductOption__c = productsOptions[1].Id,
                                                    SBQQ__RequiredBy__c = renewMidProposalLine.Id, SBQQ__PricingMethod__c = 'List',
                                                    Annual_Increase__c = 5, SBQQ__SubscriptionPricing__c = 'Fixed Price',
                                                    SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List', SBQQ__SegmentIndex__c = 1,
                                                    SBQQ__SegmentKey__c = '1521788947795', SBQQ__SegmentLabel__c = 'Year 1',
                                                    Program_or_Component__c = 'Annual Fee', SBQQ__RenewedSubscription__c = listcomponentSubscription[0].Id,
                                                    SBQQ__ListPrice__c = 100, Postage_Costs__c = 100, Media_Costs__c = 100, SBQQ__CustomerPrice__c = 100,
                                                    SBQQ__StartDate__c = System.today(),SBQQ__EndDate__c = System.today().addYears(1),
                                                    E_Only_New_Names__c = 100, Paper_New_Names__c = 100));
        
        subProposalLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = renewProposal.Id, SBQQ__Product__c = products[2].Id, SBQQ__Number__c = 1,
                                                    SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 1, SBQQ__ProductOption__c = productsOptions[1].Id,
                                                    SBQQ__RequiredBy__c = renewMidProposalLine.Id, SBQQ__PricingMethod__c = 'List',
                                                    Annual_Increase__c = 5,SBQQ__SubscriptionPricing__c = 'Fixed Price',
                                                    SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List', SBQQ__SegmentIndex__c = 2,
                                                    SBQQ__SegmentKey__c = '1521788947795', SBQQ__SegmentLabel__c = 'Year 2',
                                                    Program_or_Component__c = 'Annual Fee', SBQQ__RenewedSubscription__c = listcomponentSubscription[1].Id,
                                                    SBQQ__ListPrice__c = 100, Postage_Costs__c = 100, Media_Costs__c = 100, SBQQ__CustomerPrice__c = 100,
                                                    SBQQ__StartDate__c = System.today().addYears(1).addDays(1),SBQQ__EndDate__c = System.today().addYears(2),
                                                    E_Only_New_Names__c = 100, Paper_New_Names__c = 100));
        
        subProposalLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = renewProposal.Id, SBQQ__Product__c = products[2].Id, SBQQ__Number__c = 1,
                                                    SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 1, SBQQ__ProductOption__c = productsOptions[1].Id,
                                                    SBQQ__RequiredBy__c = renewMidProposalLine.Id, SBQQ__PricingMethod__c = 'List',
                                                    Annual_Increase__c = 5,SBQQ__SubscriptionPricing__c = 'Fixed Price',
                                                    SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List', SBQQ__SegmentIndex__c = 2,
                                                    SBQQ__SegmentKey__c = '1521788947795', SBQQ__SegmentLabel__c = 'Year 2',
                                                    Program_or_Component__c = 'Annual Fee', SBQQ__RenewedSubscription__c = listcomponentSubscription[2].Id,
                                                    SBQQ__ListPrice__c = 100, Postage_Costs__c = 100, Media_Costs__c = 100, SBQQ__CustomerPrice__c = 100,
                                                    SBQQ__StartDate__c = System.today().addYears(1).addDays(1),SBQQ__EndDate__c = System.today().addYears(2), 
                                                    E_Only_New_Names__c = 100, Paper_New_Names__c = 100));
        
        subProposalLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = renewProposal.Id, SBQQ__Product__c = products[2].Id, SBQQ__Number__c = 1,
                                                    SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 1, SBQQ__ProductOption__c = productsOptions[1].Id,
                                                    SBQQ__RequiredBy__c = renewMidProposalLine.Id, SBQQ__PricingMethod__c = 'List',
                                                    Annual_Increase__c = 5,SBQQ__SubscriptionPricing__c = 'Fixed Price',
                                                    SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List', SBQQ__SegmentIndex__c = 3,
                                                    SBQQ__SegmentKey__c = '1521788947795', SBQQ__SegmentLabel__c = 'Year 2',
                                                    Program_or_Component__c = 'Annual Fee', SBQQ__RenewedSubscription__c = listcomponentSubscription[3].Id,
                                                    SBQQ__ListPrice__c = 100, Postage_Costs__c = 100, Media_Costs__c = 100, SBQQ__CustomerPrice__c = 100,
                                                    SBQQ__StartDate__c = System.today().addYears(2).addDays(1),SBQQ__EndDate__c = System.today().addYears(3),
                                                    E_Only_New_Names__c = 100, Paper_New_Names__c = 100));
        
        //Insert list of Quote
        insert subProposalLines;
        
        Util.byPassAllTriggers = false;
        
        
        ProgramPackageRoyallTriggerHelper.syncRenewalDetailsOnProgramPackage(mapProPackage.keyset());
        ProgramPackageRoyallTriggerHelper.validateTotalContractedContactQty(mapProPackage.keyset(), CPQConstants.ORIGIN_PROPOSAL_LINE);
        
        Util.byPassAllTriggers = true;    
        
        Test.stopTest();
    }
    
    /**
    *  @description    :   This method is used to test the functionality of populating program cost on Membership.
    *
    *  @args           :   
    *
    *  @return         :   void 
    *
    *  Revision logs   :   Added By - Mahendra Swarnkar - 01/08/2021 - CR-20201204-14725 - Update logic behind CX Current Contract Value
    *
    **/
  static testMethod void test_UpdateProgramCostOnMembership() {
       
      //List to hold the Accoun
      List<Account> accounts = New List<Account>();
      
      Util.BypassAllTriggers = true; 
      
      //Add new account in list
      accounts.add(new Account(Name = 'Account 1',  r_School_Code__c = '11'));
      accounts.add(new Account(Name = 'Account 2',  r_School_Code__c = 'AB'));
      
      insert accounts; 
      
      //create a Program 
      Program__c prog = TestUtilities.CreateNewProgram(false);
      prog.Program_Acronym__c = Constants.PROGRAM_ACRONYM_CXCN;
      insert prog;
      
      Membership__c mem1 = TestUtilities.CreateNewMembership(accounts[0].Id, prog.Id, true);
      Membership__c mem2 = TestUtilities.CreateNewMembership(accounts[1].Id, prog.Id, true);
      
      //List to old the Program package records 
      List<Program_Package__c> listProgramPackage = new List<Program_Package__c>();
      
      //Populate the list
      listProgramPackage.add(new Program_Package__c (Name = 'Test1', Account__c = accounts[0].Id, Fiscal_Year__c = '2023',
                                                     Membership__c = mem1.Id));
      listProgramPackage.add(new Program_Package__c (Name = 'Test2', Account__c = accounts[1].Id, Fiscal_Year__c = '2024', 
                                                     Membership__c = mem2.Id));
      
      insert listProgramPackage;
      
      Util.BypassAllTriggers = false;
      
      //Royall Programs
      List<Royall_Program__c> rPrograms = new List<Royall_Program__c> ();
      
      rPrograms.add(new Royall_Program__c ( Name = 'Test Program1', Program_Package__c = listProgramPackage[0].Id, 
                                                     Probability__c = 10, Program_Cost__c = 1000, Proposal_Sent__c = System.today(),
                                                     End_Date_CX__c = System.today().addDays(1), Start_Date_CX__c = System.today().addDays(-1)));
            
      rPrograms.add(new Royall_Program__c ( Name = 'Test Program1', Program_Package__c = listProgramPackage[1].Id, 
                                                     Probability__c = 10, Program_Cost__c = 1000, Proposal_Sent__c = System.today(),
                                                     End_Date_CX__c = System.today().addDays(1), Start_Date_CX__c = System.today().addDays(-1)));
      //Insert programs
      insert rPrograms;
      
      test.startTest();
      
      List<Membership__c> memberships = [Select Id, CX_Current_Contract_Value__c From Membership__c 
                                         Where Id IN: new List<Id>{mem1.Id, mem2.Id} ORDER BY Name ASC];
      
      //assertion on result
      System.assertEquals(1000.00, memberships[0].CX_Current_Contract_Value__c);
      System.assertEquals(1000.00, memberships[1].CX_Current_Contract_Value__c);
      
      //update membership Id on Membership Periods
      listProgramPackage[0].Membership__c = mem2.Id;
      update listProgramPackage[0];
      
      //get Membership
      memberships = [Select Id, CX_Current_Contract_Value__c From Membership__c
                     Where Id IN: new List<Id>{mem1.Id, mem2.Id} ORDER BY Name ASC];
      
      //assertion on result
      System.assertEquals(0.00, memberships[0].CX_Current_Contract_Value__c);
      System.assertEquals(2000.00, memberships[1].CX_Current_Contract_Value__c);
      
      test.stopTest();
  }
}