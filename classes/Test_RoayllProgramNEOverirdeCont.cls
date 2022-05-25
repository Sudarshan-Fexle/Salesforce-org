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
  *     Description     :  Test Class for "ProgramNewEditOverrideController" Controller To test the funtionality
  *
  *     Created By      :   Subhash Garhwal
  *
  *     Created Date    :   2/11/2016
  *     
  *     Code Coverage   :   98%
  * 
  *     Revision Logs   :   V1.0 - Created
  * 			:   V1.1 - Modified By - Nikita Kumari - 08/05/2021 - CR-20210804-15332 - Added Method testdoRedirect 
  			:   V1.2 - Modified By - Nikita Kumari - CR-20211012-15511 - updated.
  *     
  *     Deprecated      :   None                         
  **/ 
@isTest(SeeAllData = false)
private class Test_RoayllProgramNEOverirdeCont {
	
     /**
      *     Description     :   Test method to test the funtionallity of  "doSave" method.
      *
      *     Created By      :   Subhash Garhwal
      *
      *     Created Date    :   2/11/2016
      * 
      *     Revision Logs   :   V1.0 - Created
      *
    **/ 
    static testMethod void testdoSave() {
        
        //Create Test account record
        Account account = new Account(Name = 'Test');
        
        //Insert
        insert account;
        
        //Create Test record of programPackage
        Program_Package__c programPackage = new Program_Package__c(Name = 'Test programPackage ', Account__c = account.Id, Fiscal_Year__c = '2015',
                                                                    At_Risk_Reason__c = 'Data');
        //Insert
        insert programPackage;
        
        //Create Test record of program
        Royall_Program__c program = new Royall_Program__c(Name = 'program', Program_Package__c = programPackage.Id, Contact_Quantity__c = 12,Probability__c = 20, Postage_Cost__c = 2,
                                            Target_Audience_New__c = 'Undergrad Accounts', Type__c = 'Re-engagement', Status__c = 'Proposed', Proposal_Sent__c = Date.today(),
                                            Campaign_New__c = 'Senior Search/PRE Fulfillment', Campaign_SubType__c = 'SS/PRE: New Name; SS/PRE: PRE Name',Program_Cost__c = 2, 
                                            QTY_SS_New_Name__c = 6, Postage_Cost_SS_New__c = 1, Program_Cost_SS_New__c = 1,
                                            QTY_SS_PRE_Name__c  = 6, Postage_Cost_SS_PRE__c = 1, Program_Cost_SS_PRE__c = 1);
        
        //Create Test record of program
        Royall_Program__c testprogram = new Royall_Program__c(Name = 'Test program', Program_Package__c = programPackage.Id, Contact_Quantity__c = 12,Probability__c = 20, Postage_Cost__c = 5,
                                                Target_Audience_New__c = 'Undergrad Accounts', Type__c = 'Re-engagement', Status__c = 'Proposed', Proposal_Sent__c = Date.today(),
                                                Campaign_New__c = 'Senior Search/PRE Fulfillment', Campaign_SubType__c = 'SS/PRE: New Name; SS/PRE: PRE Name', QTY_AM_IP_Name__c = 1,Program_Cost__c = 5, 
                                                QTY_AM_new_name__c = 1, QTY_AM_PRE_Name__c = 1, QTY_SE_IP_Name_Client__c = 1, QTY_SE_IP_Name_Royall__c = 1,
                                                QTY_SE_PRE_Name__c = 1, QTY_SS_New_Name__c = 1, Postage_Cost_SS_New__c = 1, Program_Cost_SS_New__c = 1,
                                                QTY_SS_PRE_Name__c  = 1, Postage_Cost_SS_PRE__c = 1, Program_Cost_SS_PRE__c = 1);
        
        
        //Create Test record of program
        Royall_Program__c testprogramCSNull = new Royall_Program__c(Name = 'Test program CsNull', Program_Package__c = programPackage.Id,Probability__c = 20,
                                            Target_Audience_New__c = 'Undergrad Accounts', Type__c = 'Re-engagement', Status__c = 'Proposed', Proposal_Sent__c = Date.today(),
                                            Campaign_New__c = 'Senior Search/PRE Fulfillment',Campaign_SubType__c = null);
        
        //Start test here
        Test.startTest();
        
        //Create instance of  StandardController
        ApexPages.StandardController standardController = new ApexPages.standardController(program); 
        
        //Create instance of  Controller
        RoyallProgramNewEditOverrideController controller = new RoyallProgramNewEditOverrideController(standardController);
        
        //Calling controller method                             
        Pagereference pagereference = controller.doSave();
        
        //Query List of Program__c
        List<Royall_Program__c> programs = [Select Id, Name, Program_Package__c, QTY_AM_IP_Name__c, QTY_AM_new_name__c, QTY_AM_PRE_Name__c, QTY_SE_IP_Name_Client__c,
                                        QTY_SE_IP_Name_Royall__c, QTY_SE_PRE_Name__c, QTY_SS_New_Name__c, Postage_Cost_SS_New__c, Program_Cost_SS_New__c,
                                        QTY_SS_PRE_Name__c, Postage_Cost_SS_PRE__c, Program_Cost_SS_PRE__c,Postage_Cost__c,Program_Cost__c From Royall_Program__c];
        //Assert result
        System.assertEquals(null, programs[0].QTY_AM_IP_Name__c);
        System.assertEquals(null, programs[0].QTY_AM_new_name__c);
        System.assertEquals(null, programs[0].QTY_AM_PRE_Name__c );
        System.assertEquals(null, programs[0].QTY_SE_IP_Name_Client__c );
        System.assertEquals(null, programs[0].QTY_SE_IP_Name_Royall__c );
        System.assertEquals(null, programs[0].QTY_SE_PRE_Name__c );
        System.assertEquals(6, programs[0].QTY_SS_New_Name__c );
        System.assertEquals(1, programs[0].Postage_Cost_SS_New__c );
        System.assertEquals(1, programs[0].Program_Cost_SS_New__c );
        System.assertEquals(6, programs[0].QTY_SS_PRE_Name__c );
        System.assertEquals(1, programs[0].Postage_Cost_SS_PRE__c );
        System.assertEquals(1, programs[0].Program_Cost_SS_PRE__c );
        System.assertEquals(2, programs[0].Postage_Cost__c);
        System.assertEquals(2, programs[0].Program_Cost__c);
          
        //Reinisitiolaize controller
        standardController = new ApexPages.standardController(testprogram);
        
        //Reinisitiolaize  Controller
        controller = new RoyallProgramNewEditOverrideController(standardController);
        
        //Calling controller method                             
        pagereference = controller.doSave();
     
        //Query List of Royall_Program__c
        List<Royall_Program__c> programsNull = [Select Id, Name, Program_Package__c, QTY_AM_IP_Name__c, QTY_AM_new_name__c, QTY_AM_PRE_Name__c, QTY_SE_IP_Name_Client__c,
                                        QTY_SE_IP_Name_Royall__c, QTY_SE_PRE_Name__c, QTY_SS_New_Name__c, Postage_Cost_SS_New__c, Program_Cost_SS_New__c,
                                        QTY_SS_PRE_Name__c, Postage_Cost_SS_PRE__c, Program_Cost_SS_PRE__c From Royall_Program__c Where Name =  'Test program'];
        
        //Assert Results
        System.assertEquals(0, programsNull.size());
        
        //Reinisitiolaize controller
        standardController = new ApexPages.standardController(testprogramCSNull);
        
        //Reinisitiolaize  Controller
        controller = new RoyallProgramNewEditOverrideController(standardController);
        
        //Calling controller method                             
        pagereference = controller.doSave();
        
        programs = [Select Id, Name, Program_Package__c, QTY_AM_IP_Name__c, QTY_AM_new_name__c, QTY_AM_PRE_Name__c, QTY_SE_IP_Name_Client__c,
                                        QTY_SE_IP_Name_Royall__c, QTY_SE_PRE_Name__c, QTY_SS_New_Name__c, Postage_Cost_SS_New__c, Program_Cost_SS_New__c,
                                        QTY_SS_PRE_Name__c, Postage_Cost_SS_PRE__c, Program_Cost_SS_PRE__c,Postage_Cost__c,Program_Cost__c From Royall_Program__c];
        
        //Assert Results
        System.assertEquals(2, programs.size());
                
        //CR-20211012-15511
        //Bypass Dupeblocker     
        Util.IsTest(true);
        Util.isTesting = true;
        Util.BypassAllTriggers = true;
        
        Program_Package__c pp = [Select Id, RecordTypeId From Program_Package__c Where ID =: testprogramCSNull.Program_Package__c];
        pp.RecordTypeId = Util.RecordTypeId('Program_Package__c', 'Hardwick Day');
        update pp;
        
        Royall_Program__c rp = [Select Id, RecordTypeId From Royall_Program__c Where Id = :testprogramCSNull.Id];
        rp.RecordTypeId = Util.RecordTypeId(RoyallProgramTriggerHelper.ROYALL_PROGRAM_OBJECT_API_NAME, RoyallProgramTriggerHelper.ROYALL_PROGRAM_HD_RECORD_TYPE_LABEL);
        update rp;
        
        Test.setCurrentPageReference(new PageReference('Page.RoyallProgramDetailOverride')); 
        //Reinisitiolaize controller
        standardController = new ApexPages.standardController(rp);
        
        //Reinisitiolaize  Controller
        controller = new RoyallProgramNewEditOverrideController(standardController);
        Pagereference pr = controller.doRedirect();
        System.assert(pr != null);
        
        Royall_Program__c testPR = new Royall_Program__c(Name = 'Test program CsNull', Program_Package__c = pp.Id,Probability__c = 20,
                                            Target_Audience_New__c = 'Undergrad Accounts', Type__c = 'Re-engagement', Status__c = 'Proposed', Proposal_Sent__c = Date.today(),
                                            Campaign_New__c = 'Senior Search/PRE Fulfillment',Campaign_SubType__c = null);
        
        standardController = new ApexPages.standardController(testPR);
        controller = new RoyallProgramNewEditOverrideController(standardController);
        pr = controller.doRedirect();
        
        
        
        testPR = new Royall_Program__c(Name = 'Test program CsNull', Program_Package__c = programPackage.Id,Probability__c = 20,
                                            Target_Audience_New__c = 'Undergrad Accounts', Type__c = 'Re-engagement', Status__c = 'Proposed', Proposal_Sent__c = Date.today(),
                                            Campaign_New__c = 'Senior Search/PRE Fulfillment',Campaign_SubType__c = null,
                                            RecordTypeId = Util.RecordTypeId(RoyallProgramTriggerHelper.ROYALL_PROGRAM_OBJECT_API_NAME, RoyallProgramTriggerHelper.ROYALL_PROGRAM_HD_RECORD_TYPE_LABEL) );
        
        standardController = new ApexPages.standardController(testPR);
        controller = new RoyallProgramNewEditOverrideController(standardController);
        pr = controller.doRedirect();
        
        System.assert(pr != null);
        //Finish method
        Test.stopTest();  
        
    }
    
    /**
      *     Description     :   Test method to test the funtionallity of  "doRedirect" method.
      *
      *     Created By      :   Nikita Kumari
      *
      *     Created Date    :   08/05/2021
      * 
      *     Revision Logs   :   V1.0 - Created
      *
    **/ 
    static testMethod void testdoRedirect() {
        
        //get record type Ids
        List<RecordType> membershipPeriodRecordTypeIds = [Select Id,Name From RecordType Where IsActive = true AND DeveloperName IN ('Acquisition','EAB','Hardwick_Day', 'Royall') And SobjectType = 'Program_Package__c' Order By Name ASC];
        
        List<RecordType> royallProgramRecordTypeIds = [Select Id,Name From RecordType Where IsActive = true AND DeveloperName IN ('Royall','Hardwick_Day','Acquisition') And SobjectType = 'Royall_Program__c' Order By Name ASC];
        
        //assert on result
        System.assert(royallProgramRecordTypeIds != null);
        
        //Create an institution
        Account acct = TestUtilities.CreateNewAccount(true);
        
        //Create Test record of programPackage
        List<Program_Package__c> mempershipPeriod = new List<Program_Package__c>();
        mempershipPeriod.add(new Program_Package__c(RecordTypeId = membershipPeriodRecordTypeIds[0].Id,
                                                    Name = 'Test programPackage 1', Account__c = acct.Id,
                                                    Fiscal_Year__c = '2021', At_Risk_Reason__c = 'Data'));
        mempershipPeriod.add(new Program_Package__c(RecordTypeId = membershipPeriodRecordTypeIds[1].Id,
                                                    Name = 'Test programPackage 2', Account__c = acct.Id,
                                                    Fiscal_Year__c = '2021', At_Risk_Reason__c = 'Data'));
        mempershipPeriod.add(new Program_Package__c(RecordTypeId = membershipPeriodRecordTypeIds[2].Id,
                                                    Name = 'Test programPackage 3', Account__c = acct.Id,
                                                    Fiscal_Year__c = '2021', At_Risk_Reason__c = 'Data'));
        mempershipPeriod.add(new Program_Package__c(RecordTypeId = membershipPeriodRecordTypeIds[3].Id,
                                                    Name = 'Test programPackage 4', Account__c = acct.Id,
                                                    Fiscal_Year__c = '2021', At_Risk_Reason__c = 'Data'));
        //Insert
        insert mempershipPeriod;
        
        //Create Test record of program
        Royall_Program__c programAcquisition = new Royall_Program__c(Name = 'program1', Program_Package__c = mempershipPeriod[0].Id,
                                                                     Contact_Quantity__c = 12,Probability__c = 20,Status__c = 'Pending - Opt Out',
                                                                     Opt_Out_Date__c = System.today(), Type__c = 'Modification',
                                                                     Target_Audience_New__c = 'Intersect',Campaign_New__c = 'ISC Awareness for Scholarships');
                                                       
        Royall_Program__c programHardwick = new Royall_Program__c(Name = 'program2', Program_Package__c = mempershipPeriod[2].Id,
                                                                Contact_Quantity__c = 12,Probability__c = 20,Status__c = 'Opportunity',
                                                                Type__c = 'Up-sell',Target_Audience_New__c = 'Financial Aid Clients',
                                                                Campaign_New__c = 'Other (HD)');
                                                       
        Royall_Program__c programRoyall = new Royall_Program__c(Name = 'program3', Program_Package__c = mempershipPeriod[3].Id,
                                                                Contact_Quantity__c = 12,Probability__c = 20,Status__c = 'Opportunity',
                                                                Type__c = 'Modification',Target_Audience_New__c = 'Advancement Accounts',
                                                                Campaign_New__c = 'Calendar Year End');

        //Start test here
        Test.startTest();
        
        //Create instance of  StandardController
        ApexPages.StandardController standardController = new ApexPages.standardController(programAcquisition); 
        
        //Create instance of  Controller
        RoyallProgramNewEditOverrideController controller = new RoyallProgramNewEditOverrideController(standardController);
        
        //Calling controller method                             
        Pagereference pagereference = controller.doRedirect();
        //Calling controller method                             
        pagereference = controller.doSave();
 
        List<Royall_Program__c> programsList = [Select Id,Name,RecordTypeId From Royall_Program__c];
        System.assertEquals(royallProgramRecordTypeIds[0].Id, programsList[0].RecordTypeId);
        
        standardController = new ApexPages.standardController(programHardwick);
        
        //Reinisitiolaize  Controller
        controller = new RoyallProgramNewEditOverrideController(standardController);
        
        //Calling controller method                             
        pagereference = controller.doRedirect();
        //Calling controller method                             
        pagereference = controller.doSave();
        
        programsList = [Select Id,Name,RecordTypeId From Royall_Program__c];
        System.assertEquals(royallProgramRecordTypeIds[1].Id, programsList[1].RecordTypeId);
        
        
        standardController = new ApexPages.standardController(programRoyall);
        
        //Reinisitiolaize  Controller
        controller = new RoyallProgramNewEditOverrideController(standardController);
        
         //Calling controller method                             
        pagereference = controller.doRedirect();
        //Calling controller method                             
        pagereference = controller.doSave();
        
        programsList = [Select Id,Name,RecordTypeId From Royall_Program__c];
        System.assertEquals(royallProgramRecordTypeIds[2].Id, programsList[2].RecordTypeId);
        
        
         Royall_Program__c newRoyallProgram = new Royall_Program__c(RecordTypeId = royallProgramRecordTypeIds[1].Id,Program_Package__c = mempershipPeriod[2].Id,Name = 'program1', Contact_Quantity__c = 12,Probability__c = 30,Status__c = 'Opportunity',
                                                                    Type__c = 'Modification',Target_Audience_New__c = 'Advancement Accounts',Campaign_New__c = 'Calendar Year End');
        
        standardController = new ApexPages.standardController(newRoyallProgram);
        
        //Reinisitiolaize  Controller
        controller = new RoyallProgramNewEditOverrideController(standardController);
        
        //Calling controller method                             
        pagereference = controller.doRedirect();
        //Calling controller method                             
        pagereference = controller.doSave();
        programsList = [Select Id,RecordTypeId,Name,Probability__c From Royall_Program__c];
        System.assertEquals(4, programsList.size());
        
        //Finish method
        Test.stopTest();  

    }
}