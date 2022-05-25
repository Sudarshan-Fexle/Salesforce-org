/**
*  Purpose         :  Test class for ReferenceRequestWrapper
*               
*  Created By      :  Mahendra Swarnakar
*   
*  Created Date    :  6/13/2020 
*   
*  Revision Log    :   v1.0  
*                       
*  Coverage        :   97%
**/
@isTest
private class Test_ReferenceRequestWrapper {
    @TestSetup
    static void testDataSetup(){

        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        Test.startTest();

        Account account = TestUtilities.CreateNewAccount(false);
        
        //Insert
        insert account;
        
        //Create a Contact
        List<Contact> contact = new List<Contact>();
                
        contact.add(new Contact(FirstName = 'Test', LastName = 'Contact', Email = 'test@test.com', AccountId = account.Id, Employee_User_Record__c = Userinfo.getUserId(), Reference_Program_Status__c = 'CCC', Title = 'Test', Phone = '614-555-8855'));
        contact.add(new Contact(FirstName = 'Test', LastName = 'Contact2', Email = 'test@test.com', AccountId = account.Id, Employee_User_Record__c = Userinfo.getUserId(), Reference_Program_Status__c = 'CCC', Title = 'Test', Phone = '614-555-8855'));
        
        //Insert
        insert contact;

        //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
        Opportunity opp = TestUtilities.CreateNewOpportunity(false);
        opp.Name = 'Test Opp';
        opp.Main_Contact__c = contact[0].Id;
        opp.Sales_Pursuit_Products__c = 'APS';
        insert opp;
        
        //Assert for result
        System.assert(contact.size() > 0);

        //create the Reference Request
        Reference_Request__c req = new Reference_Request__c(Request_Status__c = 'Vetted',
                                                            Reference_Modules__c = 'CCC',
                                                            Selection_Status__c = 'SELECTED',
                                                            Requesting_Contact__c = contact[0].Id,
                                                            Requesting_Institution__c = contact[0].AccountId,
                                                            Source_Opportunity__c = opp.Id,
                                                            Date_Needed_By__c = System.today(),
                                                            Number_of_References_Needed__c = 1,
                                                            Reference_Type_Needed__c = 'Individual',
                                                            Submitted_By__c = userInfo.getUserId());

        insert req;

        //create the Reference Request Contact
        list<Reference_Request_Contact__c> rrcsList = new list<Reference_Request_Contact__c>();
        Reference_Request_Contact__c rrc1 = new Reference_Request_Contact__c(Reference_Contact__c = contact[0].Id,
                                                                            Reference_Request__c = req.Id,
                                                                           Reference_Modules__c = 'CCC',
                                                                            Approval_Status__c = 'Pending',
                                                                            Reference_Lead__c = userInfo.getUserId());
        Reference_Request_Contact__c rrc2 = new Reference_Request_Contact__c(Reference_Contact__c = contact[0].Id,
                                                                            Reference_Request__c = req.Id,
                                                                           Reference_Modules__c = 'CCC',
                                                                            Approval_Status__c = 'Pending',
                                                                            Reference_Lead__c = userInfo.getUserId());
        Reference_Request_Contact__c rrc3 = new Reference_Request_Contact__c(Reference_Contact__c = contact[0].Id,
                                                                            Reference_Request__c = req.Id,
                                                                            Reference_Modules__c = 'CCC',
                                                                            Approval_Status__c = 'Pending',
                                                                            Reference_Lead__c = userInfo.getUserId());
        rrcsList.add(rrc1);
        rrcsList.add(rrc2);
        rrcsList.add(rrc3);

        insert rrcsList;
        

        //Assert for result
        System.assert(rrcsList.size() > 0);

        //Creating Account record
        Account account1 = TestUtilities.CreateNewAccount(true);
        
        //Creating program record
        Program__c program = TestUtilities.CreateNewProgram(true);

        //Creating Membership records
        Membership__c membership = TestUtilities.CreateNewMembership(account1.Id, program.Id, false);

        insert membership;

        Project__c proj1 = TestUtilities.createProject(false);
        proj1.Institution__c = account.ID;

        insert proj1;

        Util.byPassAllTriggers = false;

        //Asserting for the results
        List<Reference_Request_Contact__c> refReqContacts = [SELECT ID, Approver__c FROM Reference_Request_Contact__c];
        System.assert(refReqContacts != null);
        System.assertEquals(3, refReqContacts.size());
        System.assertEquals(null, refReqContacts[0].Approver__c);
        System.assertEquals(null, refReqContacts[1].Approver__c);
        System.assertEquals(null, refReqContacts[2].Approver__c);

        Test.stopTest();
    }
    
    @isTest
    static void test_ReferenceRequestWrapper(){

        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;

        Opportunity opp = [SELECT ID From Opportunity Where Name = 'Test Opp' LIMIT 1];

        system.assert(opp != null);

        Reference_Request__c rR = [SELECT ID, Name, Selection_Status__c FROM Reference_Request__c LIMIT 1];

        system.assert(rR != null);

        Membership__c memb = [SELECT Id FROM Membership__c LIMIT 1];

        system.assert(memb != null);

        Project__c proj = [SELECT Id FROM Project__c LIMIT 1];

        system.assert(proj != null);

        Contact cont = [SELECT Id, Name FROM Contact Where LastName = 'Contact' LIMIT 1];

        system.assert(cont != null);

        Account acct = [SELECT Id, Name FROM Account LIMIT 1];

        system.assert(acct != null);

        List<Reference_Request_Contact__c> listOfRRCont = [SELECT Id FROM Reference_Request_Contact__c LIMIT 3];

        Test.startTest();

        ReferenceRequestWrapper rrW1 = new ReferenceRequestWrapper(rR.ID, opp.ID);
        
        system.assert(rrW1 != null);
        system.assertEquals(rR.Name , rrW1.Name);
        system.assertEquals(rR.Id , rrW1.Id );
        system.assertEquals(acct.ID, rrW1.requestingInstitutionId);
        system.assertEquals(acct.Name, rrW1.requestingInstitution);
        system.assertEquals(cont.Id, rrW1.requestingContactId);
        system.assertEquals(rR.Selection_Status__c, rrW1.selectionStatus);
        system.assert(rrW1.recommendations != null);
        system.assertEquals(3, rrW1.recommendations.size());

        Set<Id> setOfrrCIds = new Set<Id>();
        for(ReferenceRequestWrapper.Recommendation rrW : rrW1.recommendations){
            setOfrrCIds.add(rrW.Id);
        }

        for(Reference_Request_Contact__c rrC : listOfRRCont)
            system.assert(setOfrrCIds.contains(rrc.ID));

        system.assertEquals(opp.Id, rrW1.sourceOpportunity);

        ReferenceRequestWrapper rrW2 = new ReferenceRequestWrapper(rR.ID, memb.ID);
        
        system.assert(rrW2 != null);
        system.assertEquals(memb.Id, rrW2.sourceMembership);
        
        ReferenceRequestWrapper rrW3 = new ReferenceRequestWrapper(rR.ID, proj.ID);

        system.assert(rrW3 != null);
        system.assertEquals(proj.Id, rrW3.sourceProject);

        ReferenceRequestWrapper rrW4 = new ReferenceRequestWrapper(rR.ID, proj.ID);
        List<SelectOption> listOfSO = new list<SelectOption>();
        rrW4.referenceModules = 'CMA;CCA';
        listOfSO = rrW3.attributeOptions;

        system.assert(listOfSO != null);

        Test.stopTest();


    }
}