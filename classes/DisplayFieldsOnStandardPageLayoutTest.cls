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
public class DisplayFieldsOnStandardPageLayoutTest {
    
    /**
    Purpose         :   Test class for DisplayFieldsOnStandardPageLayoutCon
                
    Create By       :   Abhinav Sharma
    
    Created Date    :   02/10/2016

    Current Log     :   v1.0 - DisplayFieldsOnStandardPageLayoutCon - 90%
								
    Revision Log    :   V1.0 - Created - Abhinav Sharma - CR-20150909-9231
    			V1.1 - Modified By - Mahendra Swarnkar - CR-20160301-9657 - 10/14/2016
			V1.2 - Modified By - Abhinav Sharma - CR-20200218-13769 - 09/04/2020 - delete the fields which are added in the FieldSet(QA_Call_Fields)
			V1.3 - Comment By - Mahendra Swarnkar - CR-20200218-13769
						
    **/
    
    static testmethod void testUseCasesAssociatedWithInstitutionFieldsRelatedPage() { 
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Creating test data for testing purpose
        
        //Account
        Account account = TestUtilities.CreateNewAccount(false);
        account.GM__c = Userinfo.getUserId();
        account.Principal__c = null;
        account.Associate_Principal__c = Userinfo.getUserId();
        insert account;
        
        //Assert for results
        System.assert(account != null);
        
        //Test method start here
        Test.startTest();
        
        //Loading of inline VF page
        DisplayFieldsOnStandardPageLayoutCon controller = new DisplayFieldsOnStandardPageLayoutCon();
        
        //Setting variable values
        controller.objectNameStr = 'Account';
    	controller.fieldSetNameStr = 'NASA_Fields';
    	controller.parentIdValueStr = account.Id;
    	controller.pageBlockSectionCnt = 2;
        
        //sobject instance
        SObject sObj;
        
        //Field set members list - initilaization
        List<Schema.FieldSetMember> fieldSetFieldsList = new List<Schema.FieldSetMember>();
        
        //Calling getter setters of the respective class
        fieldSetFieldsList = controller.fieldSetFieldsList;
        sObj = controller.sObjectInstance;
        
        //Assert for the results
        System.assert(sObj != null);
        
        //Type casting of sobject instance into the account object
        Account accTypeCasted = new Account();
        accTypeCasted = (Account)sObj;
        
        //Asserting the results
        System.assertEquals(Userinfo.getUserId(), accTypeCasted.GM__c);
        System.assertEquals(null, accTypeCasted.Principal__c);
        System.assertEquals(Userinfo.getUserId(), accTypeCasted.Associate_Principal__c);
        System.assertEquals(account.Id, accTypeCasted.Id);
        
        //Updating account fields values and then refreshing/reloading of the respective VF page
        account.GM__c = null;
        account.Principal__c = Userinfo.getUserId();
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Updating account with fields value
        update account;
        
        //Loading of inline VF page
        DisplayFieldsOnStandardPageLayoutCon controller_1 = new DisplayFieldsOnStandardPageLayoutCon();
        
        //Setting variable values
        controller_1.objectNameStr = 'Account';
    	controller_1.fieldSetNameStr = 'NASA_Fields';
    	controller_1.parentIdValueStr = account.Id;
    	controller_1.pageBlockSectionCnt = 2;
        
        //Field set members list - initilaization
        fieldSetFieldsList = new List<Schema.FieldSetMember>();
        
        //Calling getter setters of the respective class
        fieldSetFieldsList = controller_1.fieldSetFieldsList;
        sObj = controller_1.sObjectInstance;
        
        //Assert for the results
        System.assert(sObj != null);
        
        //Type casting of sobject instance into the account object
        accTypeCasted = new Account();
        accTypeCasted = (Account)sObj;
        
        //Asserting the results
        System.assertEquals(null, accTypeCasted.GM__c);
        System.assertEquals(Userinfo.getUserId(), accTypeCasted.Principal__c);
        System.assertEquals(Userinfo.getUserId(), accTypeCasted.Associate_Principal__c);
        System.assertEquals(account.Id, accTypeCasted.Id);
        
        //Test method stop here
        Test.stopTest();
    }
    
    static testmethod void testUseCasesAssociatedWithQACallFieldsRelatedPage() { 
    
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Creating test data for testing purpose
        
        //Account
        Account account = TestUtilities.CreateNewAccount(false);
        account.GM__c = Userinfo.getUserId();
        account.Principal__c = null;
        account.Associate_Principal__c = Userinfo.getUserId();
        insert account;
        
        //Assert for results
        System.assert(account != null);
        
        //V1.1 - Modified By - Mahendra Swarnkar - CR-20160301-9657 - 10/14/2016 - Program_Acronym__c is updated
        //Program
        Program__c program = new Program__c(Name = System.Label.MEMBERSHIP_PROGRAM_FOR_LAST_QA_CALL_FIELDS, 
                                            Program_Formal_Name__c = 'Test', 
                                            Program_Acronym__c = 'ICDR');
        insert program;
        
        //Membership
        Membership__c membership = new Membership__c(Name = 'Membership 1', Account_Name__c = account.Id,
                                                     Program__c = program.Id);
        insert membership;
        
        //Querying Details for "PT QA Call" record type on Event Object
        List<RecordType> eventRdTypes = [SELECT ID FROM RecordType Where sObjectType = 'Event' AND IsActive = true 
                                   			AND Name =: DisplayFieldsOnStdPageLayoutConstants.EVENT_RECORD_TYPE_PT_QA_CALL];
		//Assert for the results
        System.assert(eventRdTypes != null);
       
        //Activities
        List<Event> events = new List<Event>();
        
        //Insert events associated with the membership record
        events.add(new Event(RecordTypeId = eventRdTypes[0].Id, OwnerId = Userinfo.getUserId(), 
                             StartDateTime = system.today(), EndDateTime = system.today().adddays(5), 
                             Would_Refer__c = '9', Would_Buy_Again__c = '9', Grade__c = 'A+',
                             WhatId = membership.ID));
        insert events;
        
        //Assert for the results
        System.assert(events != null);
        
        //Test method start here
        Test.startTest();
        
        //Loading of inline VF page
        DisplayFieldsOnStandardPageLayoutCon controller = new DisplayFieldsOnStandardPageLayoutCon();
        
        //Setting variable values
        controller.objectNameStr = 'Membership__c';
    	controller.fieldSetNameStr = System.Label.QA_Call_Fields;
    	controller.parentIdValueStr = membership.Id;
    	controller.pageBlockSectionCnt = 2;
        controller.orderByFieldStr = 'StartDateTime';
        controller.orderByDirectionStr = 'DESC';
        
        //sobject instance
        SObject sObj;
        
        //Field set members list - initilaization
        List<Schema.FieldSetMember> fieldSetFieldsList = new List<Schema.FieldSetMember>();
        
        //Calling getter setters of the respective class
        fieldSetFieldsList = controller.fieldSetFieldsList;
        sObj = controller.sObjectInstance;

	//Modified By - Abhinav Sharma - CR-20200218-13769 - 09/04/2020 - delete the fields which are added in the FieldSet(QA_Call_Fields)        
        //Assert for the results
        //System.assert(sObj != null);      
        
        //Type casting of sobject instance into the account object
        Membership__c memTypeCasted = new Membership__c();
        memTypeCasted = (Membership__c)sObj;
        
        //Modified by Mahendra Swarnakar - CR-20200218-13769 - 05/05/2020 -last_qa_call_date__c,Last_QA_Call_Grade__c,
        //Last_QA_Call_Would_Recommend__c, Last_QA_Call_Would_Renew__c deleted
        //Assert for the results
        //System.assertEquals(system.today(), memTypeCasted.Last_QA_Call_Date__c);
        //System.assertEquals('A+', memTypeCasted.Last_QA_Call_Grade__c);
        //System.assertEquals('9', memTypeCasted.Last_QA_Call_Would_Recommend__c);
        //System.assertEquals('9', memTypeCasted.Last_QA_Call_Would_Renew__c);
        
        //Updating event to mark it as cancelled
        events[0].Cancelled_Did_Not_Occur__c = true;
        update events;
        
        //Loading of inline VF page
        DisplayFieldsOnStandardPageLayoutCon controller_1 = new DisplayFieldsOnStandardPageLayoutCon();
        
        //Setting variable values
        controller_1.objectNameStr = 'Membership__c';
    	controller_1.fieldSetNameStr = System.Label.QA_Call_Fields;
    	controller_1.parentIdValueStr = membership.Id;
    	controller_1.pageBlockSectionCnt = 2;
        controller_1.orderByFieldStr = 'StartDateTime';
        controller_1.orderByDirectionStr = 'DESC';
        
        //Calling getter setters of the respective class
        fieldSetFieldsList = controller_1.fieldSetFieldsList;
        sObj = controller_1.sObjectInstance;
        
      	//Modified By - Abhinav Sharma - CR-20200218-13769 - 09/04/2020 - delete the fields which are added in the FieldSet(QA_Call_Fields)  
        //Assert for the results
        // System.assert(sObj != null);
        
        //Type casting of sobject instance into the account object
        memTypeCasted = new Membership__c();
        memTypeCasted = (Membership__c)sObj;
        
        //Assert for the results
        //Modified by Mahendra Swarnakar - CR-20200218-13769 - 05/05/2020 -last_qa_call_date__c,Last_QA_Call_Grade__c
        //Last_QA_Call_Would_Renew__c,Last_QA_Call_Would_Renew__c deleted
        //System.assertEquals(null, memTypeCasted.Last_QA_Call_Date__c);
        //System.assertEquals(null, memTypeCasted.Last_QA_Call_Grade__c);
        //System.assertEquals(null, memTypeCasted.Last_QA_Call_Would_Recommend__c);
        //System.assertEquals(null, memTypeCasted.Last_QA_Call_Would_Renew__c);
        
        //Loading of inline VF page
        DisplayFieldsOnStandardPageLayoutCon controller_2 = new DisplayFieldsOnStandardPageLayoutCon();
        
        //Setting variable values
        controller_2.objectNameStr = 'Membership__c';
    	controller_2.fieldSetNameStr = 'Test_TBD';
    	controller_2.parentIdValueStr = membership.Id;
    	controller_2.pageBlockSectionCnt = 2;
        controller_2.orderByFieldStr = 'StartDateTime';
        controller_2.orderByDirectionStr = 'DESC';
        
        //Calling getter setters of the respective class
        fieldSetFieldsList = controller_2.fieldSetFieldsList;
        sObj = controller_2.sObjectInstance;
        
        //Stop test here
        Test.stopTest();
    }

	static testmethod void testMiscellaneousUseCases() { 
    
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Creating test data for testing purpose
        
        //Account
        Account account = TestUtilities.CreateNewAccount(false);
        account.GM__c = Userinfo.getUserId();
        account.Principal__c = null;
        account.Associate_Principal__c = Userinfo.getUserId();
        insert account;
        
        //Assert for results
        System.assert(account != null);
        
        //Program
        Program__c program = new Program__c(Name = System.Label.MEMBERSHIP_PROGRAM_FOR_LAST_QA_CALL_FIELDS, 
                                            Program_Formal_Name__c = 'Test', 
                                            Program_Acronym__c = 'Test');
        insert program;
        
        //Membership
        Membership__c membership = new Membership__c(Name = 'Membership 1', Account_Name__c = account.Id,
                                                     Program__c = program.Id);
        insert membership;
        
        //Querying Details for "PT QA Call" record type on Event Object
        List<RecordType> eventRdTypes = [SELECT ID FROM RecordType Where sObjectType = 'Event' AND IsActive = true 
                                   			AND Name =: DisplayFieldsOnStdPageLayoutConstants.EVENT_RECORD_TYPE_PT_QA_CALL];
		//Assert for the results
        System.assert(eventRdTypes != null);
        
        //Activities
        List<Event> events = new List<Event>();
        
        //Insert events associated with the membership record
        events.add(new Event(RecordTypeId = eventRdTypes[0].Id, OwnerId = Userinfo.getUserId(), 
                             StartDateTime = system.today(), EndDateTime = system.today().adddays(5), 
                             Would_Refer__c = '9', Would_Buy_Again__c = '9', Grade__c = 'A+',
                             WhatId = membership.ID));
        insert events;
        
        //Assert for the results
        System.assert(events != null);
        
        //Test method start here
        Test.startTest();
        
        //Loading of inline VF page
        DisplayFieldsOnStandardPageLayoutCon controller = new DisplayFieldsOnStandardPageLayoutCon();
        
        //Setting variable values
        controller.objectNameStr = 'Membership__c';
    	controller.fieldSetNameStr = System.Label.QA_Call_Fields;
    	controller.parentIdValueStr = membership.Id;
    	controller.pageBlockSectionCnt = 2;
        controller.orderByFieldStr = 'StartDateTime';
        controller.orderByDirectionStr = 'DESC';
        
        //sobject instance
        SObject sObj;
        
        //Field set members list - initilaization
        List<Schema.FieldSetMember> fieldSetFieldsList = new List<Schema.FieldSetMember>();
        
        //Calling getter setters of the respective class
        fieldSetFieldsList = controller.fieldSetFieldsList;
        sObj = controller.sObjectInstance;
        
       	//Modified By - Abhinav Sharma - CR-20200218-13769 - 09/04/2020 - delete the fields which are added in the FieldSet(QA_Call_Fields)
        //Assert for the results
        //System.assert(sObj != null);
        
        //Type casting of sobject instance into the account object
        Membership__c memTypeCasted = new Membership__c();
        memTypeCasted = (Membership__c)sObj;
        
        //Assert for the results
        //Modified by Mahendra Swarnakar - CR-20200218-13769 - 05/05/2020 -last_qa_call_date__c,Last_QA_Call_Grade__c,
        //Last_QA_Call_Would_Renew__c,Last_QA_Call_Would_Renew__c deleted
        //System.assertEquals(null, memTypeCasted.Last_QA_Call_Date__c);
        //System.assertEquals(null, memTypeCasted.Last_QA_Call_Grade__c);
        //System.assertEquals(null, memTypeCasted.Last_QA_Call_Would_Recommend__c);
        //System.assertEquals(null, memTypeCasted.Last_QA_Call_Would_Renew__c);
        
        //Stop test here
        Test.stopTest();
    }

	static testmethod void testMiscellaneousUseCases_2() { 
    
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Creating test data for testing purpose
        
        //Account
        Account account = TestUtilities.CreateNewAccount(false);
        account.GM__c = Userinfo.getUserId();
        account.Principal__c = null;
        account.Associate_Principal__c = Userinfo.getUserId();
        insert account;
        
        //Assert for results
        System.assert(account != null);
        
        //Program
        Program__c program = new Program__c(Name = 'Test', 
                                            Program_Formal_Name__c = 'Test', 
                                            Program_Acronym__c = 'Test');
        insert program;
        
        //Membership
        Membership__c membership = new Membership__c(Name = 'Membership 1', Account_Name__c = account.Id,
                                                     Program__c = program.Id);
        insert membership;
        
        //Querying Details for "PT QA Call" record type on Event Object
        List<RecordType> eventRdTypes = [SELECT ID FROM RecordType Where sObjectType = 'Event' AND IsActive = true 
                                   			AND Name =: DisplayFieldsOnStdPageLayoutConstants.EVENT_RECORD_TYPE_PT_QA_CALL];
		//Assert for the results
        System.assert(eventRdTypes != null);
        
        
        //Activities
        List<Event> events = new List<Event>();
        
        //Insert events associated with the membership record
        events.add(new Event(RecordTypeId = eventRdTypes[0].Id, OwnerId = Userinfo.getUserId(), 
                             StartDateTime = system.today(), EndDateTime = system.today().adddays(5), 
                             Would_Refer__c = '9', Would_Buy_Again__c = '9', Grade__c = 'A+',
                             WhatId = membership.ID));
        insert events;
        
        //Assert for the results
        System.assert(events != null);
        
        //Test method start here
        Test.startTest();
        
        //Loading of inline VF page
        DisplayFieldsOnStandardPageLayoutCon controller = new DisplayFieldsOnStandardPageLayoutCon();
        
        //Setting variable values
        controller.objectNameStr = 'Membership__c';
    	controller.fieldSetNameStr = System.Label.QA_Call_Fields;
    	controller.parentIdValueStr = membership.Id;
    	controller.pageBlockSectionCnt = 2;
        controller.orderByFieldStr = 'StartDateTime';
        controller.orderByDirectionStr = 'DESC';
        
        //sobject instance
        SObject sObj;
        
        //Field set members list - initilaization
        List<Schema.FieldSetMember> fieldSetFieldsList = new List<Schema.FieldSetMember>();
        
        //Calling getter setters of the respective class
        fieldSetFieldsList = controller.fieldSetFieldsList;
        sObj = controller.sObjectInstance;
        
        //Modified By - Abhinav Sharma - CR-20200218-13769 - 09/04/2020 - delete the fields which are added in the FieldSet(QA_Call_Fields)
        //Assert for the results
        //System.assert(sObj != null);
        
        //Type casting of sobject instance into the account object
        Membership__c memTypeCasted = new Membership__c();
        memTypeCasted = (Membership__c)sObj;
        
        //Assert for the results
        //Modified by Mahendra Swarnakar - CR-20200218-13769 - 05/05/2020 -last_qa_call_date__c,Last_QA_Call_Grade__c,
        //Last_QA_Call_Would_Recommend__c,Last_QA_Call_Would_Renew__c deleted
        //System.assertEquals(null, memTypeCasted.Last_QA_Call_Date__c);
        //System.assertEquals(null, memTypeCasted.Last_QA_Call_Grade__c);
        //System.assertEquals(null, memTypeCasted.Last_QA_Call_Would_Recommend__c);
        //System.assertEquals(null, memTypeCasted.Last_QA_Call_Would_Renew__c);
        
        //Stop test here
        Test.stopTest();
    }    
}