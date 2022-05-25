/*
* Purpose          :   Test class for TableGridWrapperController
* 
* CreatedDate      :   6/3/2020
* 
* RevisionLog      :   V_1.0 - Created - Dipesh Gupta
* 
* Code Coverage    :   
* */
@isTest
private class Test_TableGridWrapperController {

    @TestSetup
    static void dataSetup(){

        //Util is bypass trigger
        Util.BypassAlltriggers = true;

        Util.IsTest(true);

        //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
        Opportunity opp = TestUtilities.CreateNewOpportunity(false);
        opp.Name = 'Opportunity 1';
        opp.Sales_Pursuit_Products__c = 'APS';
        insert opp;

        //Insert Institution
        Account testAcct = TestUtilities.CreateNewAccount(false); 
        insert testAcct;

        //Insert program
        Program__c swProgram = new Program__c(
        Program_Acronym__c = 'TEST',
        Program_Formal_Name__c = 'Test Program Formal',
        Name = 'Test Program',
        Create_Memberships__c = 'No',
        Renewal_Unit_Count__c = 1,
        Business_Line__c = 'SW');         
        insert swProgram;

        //Insert Account
        Account account = new Account(Name = 'Test Acc', Account_Formal_Name__c = 'testacc');
        insert account;
        
        //Insert program
        Program__c prog = TestUtilities.CreateNewProgram(false);
        insert prog;
        
        //Insert Membership
        Membership__c mem = TestUtilities.CreateNewMembership(account.Id, prog.Id, true);
        
        Util.BypassAlltriggers = false;

    }

    @isTest
    static void testOppType(){
        
        Test.startTest();
        //Query on Oppportunity
        Opportunity opp = [SELECT Name FROM Opportunity Where Name = 'Opportunity 1' LIMIT 1];
        
        //TableGridWrapperController class
        TableGridWrapperController tGWC = new TableGridWrapperController();
        List<DynamicRelatedListTableGridWrapper> dRLTW = new List<DynamicRelatedListTableGridWrapper>();
        tGWC.staffAssignmentFilterCriteria = 'Filter Criteria';
        tGWC.masterRecordId = opp.Id;
        tGWC.childObjectName = 'Team_Membership__c';
        tGWC.recordTypeName = 'Southwind';
        dRLTW = tGWC.dynamicRelatedListWrapperList; 
        
        Test.stopTest();
        
        //Assert
        system.assert(dRLTW != null);
        system.assertEquals('Name, Staff_member__c, Institution__c, Role__c, Start_date__c', dRLTW[0].requiredFielsNameString);
        system.assertEquals(opp.Id, dRLTW[0].parentRecordId);
        system.assertEquals('Staff Assignments', dRLTW[0].relatedListName);
        system.assertEquals('Institution__c', dRLTW[0].sortByFieldName);
        system.assertEquals(true, dRLTW[0].sortByOrderDescending);
        system.assertEquals('Opportunity__c = \'' + opp.ID + '\'', dRLTW[0].filterCriteriaString);
        system.assertEquals(10, dRLTW[0].relatedlistPageSize);
        system.assertEquals('recordtypeid', dRLTW[0].hiddenFieldsString);
    } 

    @isTest
    static void testAccountType(){
        
        Test.startTest();
        //Query on Account
        Account acct = [SELECT Name FROM Account Where Name = 'Test Acc' LIMIT 1];
        
        //TableGridWrapperController class
        TableGridWrapperController tGWC = new TableGridWrapperController();
        List<DynamicRelatedListTableGridWrapper> dRLTW = new List<DynamicRelatedListTableGridWrapper>();
        tGWC.staffAssignmentFilterCriteria = 'Filter Criteria';
        tGWC.masterRecordId = acct.Id;
        tGWC.childObjectName = 'Team_Membership__c';
        tGWC.recordTypeName = 'US_Provider_Strategic';
        dRLTW = tGWC.dynamicRelatedListWrapperList; 
        
        test.stopTest();
        
        //Assert 
        system.assert(dRLTW != null);
        system.assertEquals('Name, Staff_member__c, Institution__c, Role__c, Start_date__c', dRLTW[0].requiredFielsNameString);
        system.assertEquals(acct.Id, dRLTW[0].parentRecordId);
        system.assertEquals('Staff Assignments', dRLTW[0].relatedListName);
        system.assertEquals('Role__c', dRLTW[0].sortByFieldName);
        system.assertEquals(false, dRLTW[0].sortByOrderDescending);
        system.assertEquals('Filter Criteria AND Institution__c = \'' + acct.ID + '\'', dRLTW[0].filterCriteriaString);
        system.assertEquals(10, dRLTW[0].relatedlistPageSize);
        system.assertEquals('recordtypeid', dRLTW[0].hiddenFieldsString);

        
    } 

    @isTest
    static void testMemberShipType(){
        
        Test.startTest();
        //Query on membership
        Membership__c memb = [SELECT Name FROM Membership__c Where Name LIKE  'test%' LIMIT 1];
        
        //TableGridWrapperController class
        TableGridWrapperController tGWC = new TableGridWrapperController();
        List<DynamicRelatedListTableGridWrapper> dRLTW = new List<DynamicRelatedListTableGridWrapper>();
        tGWC.staffAssignmentFilterCriteria = 'Filter Criteria 1';
        tGWC.masterRecordId = memb.Id;
        tGWC.childObjectName = 'Membership_Key_Contact__c';
        tGWC.recordTypeName = 'Record_Type_1';
        dRLTW = tGWC.dynamicRelatedListWrapperList;  
        
        Test.stopTest();

        //Assert
        system.assert(dRLTW != null);
        system.assertEquals('Name, Membership__c, Contact__c', dRLTW[0].requiredFielsNameString);
        system.assertEquals(memb.Id, dRLTW[0].parentRecordId);
        system.assertEquals('Membership Key Contacts', dRLTW[0].relatedListName);
        system.assertEquals('Role__c', dRLTW[0].sortByFieldName);
        system.assertEquals(true, dRLTW[0].sortByOrderDescending);
        system.assertEquals('Membership__c = \'' + memb.ID + '\'', dRLTW[0].filterCriteriaString);
        system.assertEquals(5, dRLTW[0].relatedlistPageSize);
        system.assertEquals('recordtypeid,membership__c', dRLTW[0].hiddenFieldsString);
    } 

}