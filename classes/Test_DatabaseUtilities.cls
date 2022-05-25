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
    *   Purpose         :   Test class for DatabaseUtilities
    *            
    *   Create By       :   Dipesh Gupta
    * 
    *   Created Date    :   12/10/2019
    *
    *   Revision Log    :   V_1.0 - Created - Dipesh Gupta
    * 			:   V_1.1 - Modify by - Shalu Sharma - 5/18/21 - CR-20210315-14997 - Update the "BRE" to "Reply Envelope (BRE/CRE)" 
    *   
    *   Coverage        :   V_1.0 -
    *
    **/
@isTest(seeAllData = false)
private class Test_DatabaseUtilities 
{
    
    @testSetup static void dataSetup()
    {
        Util.IsTest(true);
        Util.isTesting = true;
        Util.byPassAllTriggers = true;
        
        Job_Ticket_MtM__c jobTickectMTM = PrintManagementTestDataFactory.CreateNewJobTicketMTM(true);
        List<Job_Ticket_MtM__c> listOfjobTickectMTM = [Select Id From Job_Ticket_MtM__c];
        System.assert(listOfjobTickectMTM.size() >0);
        System.assert(listOfjobTickectMTM[0].Id != null);
    }
    
    // test method for checkIfUserHasObjectLevelSecurity
    static testMethod void test_checkIfUserHasObjectLevelSecurity()
    {
        List<Job_Ticket_MtM__c> listOfjobTickectMTM = [Select Id From Job_Ticket_MtM__c];
        test.startTest();
        String res = DatabaseUtilities.checkIfUserHasObjectLevelSecurity('Job_Ticket_MtM__c',listOfjobTickectMTM[0].Id);
        System.assertEquals('', res);
        
    }
    
    // nagative testing for checkIfUserHasObjectLevelSecurity
    static testMethod void test_Nag_checkIfUserHasObjectLevelSecurity()
    {
        test.startTest();
        String res = DatabaseUtilities.checkIfUserHasObjectLevelSecurity(null,null);
        System.assert(res != null);   
    }
    
    // test method for getFieldsetQuery
    static testmethod void test_getFieldsetQuery()
    {
        List<Schema.FieldSetMember> fields = Schema.SObjectType.Job_Ticket_MtM__c.fieldSets.getMap().get('BREFieldSet').getFields();
        
        Test.startTest();
        
        String res = DatabaseUtilities.getFieldsetQuery('Job_Ticket_MtM__c',fields);
        System.assert(res !=  null);
        
        Test.stopTest();
    }
    
    // test method for getFieldsetQuery 4th method
    static testmethod void test_getFieldsetQueryOther()
    {
        List<String> mandatoryFields = new List<String>{'Job_Ticket__c','Job_Ticket_Component__c','Job_Ticket_Component__r.Id','Component_Type__c'}; 
        //Modify by - Shalu Sharma - 5/18/21 - CR-20210315-14997
        String whereClause = 'Component_Type__c = Reply Envelope (BRE/CRE)';
        String orderBy = 'Job_Ticket__c';
        String queryLimit = '5';
        Boolean convertFieldPaths = true;
        Boolean addPrefix = true;
        
        List<Schema.FieldSetMember> fields = Schema.SObjectType.Job_Ticket_MtM__c.fieldSets.getMap().get('BREFieldSet').getFields();
        
        Test.startTest();
        
        String res = DatabaseUtilities.getFieldsetQuery('Job_Ticket_MtM__c',fields,mandatoryFields,whereClause,orderBy,queryLimit,convertFieldPaths,addPrefix);
        System.assert(res !=null);
        
        Test.stopTest();    
    }
    
    // test method for getConvertedFieldPath
    static testmethod void test_getConvertedFieldPath()
    {
        String res = DatabaseUtilities.getConvertedFieldPath('Id','Id');
        System.assertEquals('Id', res);
        
        String res2 = DatabaseUtilities.getConvertedFieldPath('Account.Id','Id');
        System.assertEquals('Account.Name', res2);
        
        String res3 = DatabaseUtilities.getConvertedFieldPath('AccountId','Id');
        System.assertEquals('Account.Name', res3);
        
        String res4 = DatabaseUtilities.getConvertedFieldPath('abc__c','REFERENCE');
        System.assertEquals('abc__r.Name', res4);
        
        String res5 = DatabaseUtilities.getConvertedFieldPath('Account','REFERENCE');
        System.assertEquals('Account.Name', res5);
    }
    
    // test method for getRecordTypeLabel
    static testmethod void test_getRecordTypeLabel()
    {
        Id devRecordTypeId = Schema.SObjectType.Job_Ticket__c.getRecordTypeInfosByName().get('Job Ticket').getRecordTypeId();
        
        Test.startTest();
        
        String res = DatabaseUtilities.getRecordTypeLabel(devRecordTypeId);
        System.assert(res != null);
        
        Test.stopTest();
    }
    
    // test method for getRecordTypeIdForObject
    static testmethod void test_getRecordTypeIdForObject()
    {
        Test.startTest();
        
        Id res = DatabaseUtilities.getRecordTypeIdForObject('Job_Ticket__c','Job Ticket');
        System.assert(res !=null);
        
        Test.stopTest();
    }
    
    // Nagative test method for getRecordTypeIdForObject
    static testmethod void test_Nag_getRecordTypeIdForObject()
    {
        Test.startTest();
        
        Id res = DatabaseUtilities.getRecordTypeIdForObject('','');
        System.assert(res ==null);
        
        Test.stopTest();
    }
    
    // test method for getRecordTypeIdForObject 2nd method
    static testmethod void test_getRecordTypeIdForObjectOther()
    {
        Id devRecordTypeId = Schema.SObjectType.Job_Ticket__c.getRecordTypeInfosByName().get('Job Ticket').getRecordTypeId();
        
        SObjectType sObjType = ((SObject) Type.forName('Job_Ticket__c').newInstance()).getSObjectType();
        
        Test.startTest();
        
        Id res = DatabaseUtilities.getRecordTypeIdForObject(sObjType,'Job Ticket');
        System.assert(res !=null);
        
        Test.stopTest();
    }
    
    // Nagative test method for getRecordTypeIdForObject 2nd method
    static testmethod void test_Nag_getRecordTypeIdForObjectOther()
    {
        
        SObjectType sObjType;
        Test.startTest();
        
        Id res = DatabaseUtilities.getRecordTypeIdForObject(sObjType,'');
        System.assert(res == null);
        test.stopTest();
    }
    
    // test method for getKeyPrefixForObject
    static testmethod void test_getKeyPrefixForObject()
    {
        Test.startTest();
        
        String res = DatabaseUtilities.getKeyPrefixForObject('Job_Ticket__c');
        System.assert(res != null);
        
        Test.stopTest();
    }
    
    // Nagative test method for getKeyPrefixForObject
    static testmethod void test_Nag_getKeyPrefixForObject()
    {
        Test.startTest();
        
        String res = DatabaseUtilities.getKeyPrefixForObject('');
        System.assert(res == null);
        
        Test.stopTest();
    }
    
    // test method for getKeyPrefixForObject 2nd
    static testmethod void test_getKeyPrefixForObjectOther()
    {
        SObjectType sObjType = ((SObject) Type.forName('Job_Ticket__c').newInstance()).getSObjectType();
        
        Test.startTest();
        
        String res = DatabaseUtilities.getKeyPrefixForObject(sObjType);
        System.assert(res != null);
        
        Test.stopTest();
    }
    
    // Nagative test method for getKeyPrefixForObject 2nd
    static testmethod void test_Nag_getKeyPrefixForObjectOther()
    {
        Test.startTest();
        
        String res = DatabaseUtilities.getKeyPrefixForObject('');
        System.assert(res == null);
        
        Test.stopTest();
    }
    
    // test method for getObjectDescribeOnBasisOfObjectName
    static testmethod void test_getObjectDescribeOnBasisOfObjectName()
    {
        Test.startTest();
        
        Schema.DescribeSObjectResult res = DatabaseUtilities.getObjectDescribeOnBasisOfObjectName('Job_Ticket__c');
        System.assert(res !=null);
        
        Test.stopTest();
    }
    
    // nagative test method for getObjectDescribeOnBasisOfObjectName
    static testmethod void test_Nag_getObjectDescribeOnBasisOfObjectName()
    {
        Test.startTest();
        
        Schema.DescribeSObjectResult res = DatabaseUtilities.getObjectDescribeOnBasisOfObjectName('');
        System.assert(res == null);
        
        Test.stopTest();
    }
    
    // test method for readObjectValue
    /*static testmethod void test_readObjectValue()
    {
        sObject obj = Schema.getGlobalDescribe().get('Job_Ticket__c').newSObject();
        Object res = DatabaseUtilities.readObjectValue(obj,'kjsdkjfsdf\\.klkdfhjsd.jj__r.mmm');
    }*/
	
	// For Add Mode Release Start Here Date:01/01/2020 By Abhinav Sharma
	static testMethod void testDatabaseUtilities() 
    {
        Test.startTest();
        DatabaseUtilities.unscheduleJobsWithoutNextFireDate();
        DatabaseUtilities.extractTestClassesIds();
        DatabaseUtilities.sendBatchStatus(null,'AsynBatch','not sent','salesforce@fexle.com');
        
        Test.stopTest();
    }
    
    /**
     * 
     * @description: test the createLog() method
     * 
     **/
    static testMethod void test_createLog() 
    {
        List<Contact> conList = new List<Contact>();
        conList.add(new Contact(Phone = '34234324'));
        test.startTest();
        Database.SaveResult[] srList = Database.insert(conList, false);
        DatabaseUtilities.createLog(srList);
        test.stopTest();
    }
    
    /**
     * 
     * @description: test the createLog() method for delete
     * 
     **/
    static testMethod void test_Delete_createLog() 
    {
        /*List<Account> accList = new List<Account>();
        accList.add(new Account(Phone = '234543534'));
		//insert accList;*/
        
        
        
        List<Account> accList = new List<Account>();
        accList.add(new Account(Phone = '34234324'));
        insert accList;
        List<Account> listOfAcc = new List<Account>();//[SELECT Id, Name FROM Account];
        Database.DeleteResult[] drList = Database.delete(listOfAcc, false);
        
        test.startTest();
        
        DatabaseUtilities.createLog(drList);
        test.stopTest();
    }
    
    /**
     * 
     * @description: test the createLog() method for upsert
     * 
     **/
    static testMethod void test_Upsert_createLog() 
    {
        List<Account> accList = new List<Account>();
        accList.add(new Account(Name = '234543534'));
        
        Database.UpsertResult[] urList = Database.upsert(accList, false);
        
        test.startTest();
        
        DatabaseUtilities.createLog(urList);
        test.stopTest();
    }
    
    /**
     * 
     * @description: test the errorHTMLLog() method
     * 
     **/
    static testMethod void test_errorHTMLLog() 
    {
        List<Contact> conList = new List<Contact>();
        List<Database.Error> errors = new List<Database.Error>();
        conList.add(new Contact(Phone = '34234324'));
        test.startTest();
        //Database.SaveResult[] srList = Database.insert(conList, false);
        for (Contact con: conList)
        {
            Database.SaveResult result = Database.insert(con,false);
            if (!result.success)
            {
                //This is only asking for all of the errors on a single record here
                errors.addAll(result.getErrors());
            }
        }
        
        DatabaseUtilities.errorHTMLLog(errors);
        test.stopTest();
    }
    
    /**
     * 
     * @description: test the sendBatchStatus() method
     * 
     **/
    static testMethod void test_sendBatchStatus() 
    {
        
        test.startTest();
        
        DatabaseUtilities.sendBatchStatus(null,'AsynBatch','not sent');
        test.stopTest();
    }
	// For Add Mode Release End Here Date:01/01/2020 By Abhinav Sharma
}