/**
*   Purpose         :   Test class for AssociatedJobComponentsController
*            
*   Create By       :   Dipesh Gupta
* 
*   Created Date    :   03/11/2020
*
*   Revision Log    :   V_1.0 - Created - Dipesh Gupta
*   
*   Coverage        :   V_1.0
*		    :   V_1.1 - Modified By - Abhinav Sharma - 03/01/2021 - CR-20201111-14688 - Create Print PT when JT MtM is created
*                   :   V_1.2 - Modified By - Shalu Sharma - 5/18/21 - CR-20210315-14997 - Update the "BRE" to "Reply Envelope (BRE/CRE)"
*		    :   V_1.3 - Modified By - Abhinav Sharma - 05/17/2021 - CR-20210513-15145 - Details missing on PTR when component marked as Approved By Partner (Update test_approveJobTicketMtM method)
*		    :   V_1.4 - Modified By - Abhinav Sharma - 05/20/2021 - CR-20210518-15161 - Update the method "test_approveJobTicketMtM"
*		    :   V_1.5 - Modified By - Abhinav Sharma - 06/08/2021 - CR-20210607-15195
**/
@isTest(seeAllData = false)
private class Test_AssociatedJobComponentsController 
{
    @testSetup static void dataSetup()
    {
        Util.IsTest(true);
        Util.isTesting = true;
        Util.byPassAllTriggers = true;
        
        Job_Ticket__c jobTicket = PrintManagementTestDataFactory.CreateNewJobTicket(true);
        
        Job_Ticket_Component__c jobTctComponet = PrintManagementTestDataFactory.CreateNewJobTicketComponent(false);
        //Modify by - Shalu Sharma - 5/18/21 - CR-20210315-14997
        jobTctComponet.Component__c = Constants.COMPONENT_TYPE_BRE;
        insert jobTctComponet;
        
        List<Job_Ticket_Component__c> jobTickectCompo = [Select Id From Job_Ticket_Component__c];
        System.assert(jobTickectCompo[0].Id != null);
        System.assert(jobTickectCompo.size() > 0);
        
        Job_Ticket_MtM__c jobTickectMTMs = PrintManagementTestDataFactory.CreateNewJobTicketMTM(false);
        jobTickectMTMs.Job_Ticket_Component__c = jobTickectCompo[0].Id;
        insert jobTickectMTMs;
        List<Job_Ticket_MtM__c> jobTickectMTMsList = [Select Id,Job_Ticket_Component__c From Job_Ticket_MtM__c];
        System.assert(jobTickectMTMsList[0].Id != null);
        System.assert(jobTickectMTMsList.size() > 0);
        
        Associated_Features__c af = new Associated_Features__c();
        af.Job_Ticket_MtM__c = jobTickectMTMsList[0].Id;
        af.PMS__c = 'test';
        insert af;
        
        List<Associated_Features__c> associatedFeatList = [Select Id From Associated_Features__c];
        System.assert(associatedFeatList[0].Id != null);
        System.assert(associatedFeatList.size() > 0);
        
        Util.byPassAllTriggers = false;        
    }
    
    static testMethod void test_retrieveExistingJobTicketComponents() 
    {
        Util.IsTest(true);
        Util.isTesting = true;
        Util.byPassAllTriggers = true;
        
        List<Job_Ticket_MtM__c> jobTickectMTMsList = [Select Id,Name, Job_Ticket__c From Job_Ticket_MtM__c];
        Test.startTest();
        
        System.assert(AssociatedJobComponentsController.retrieveExistingJobTicketComponents(jobTickectMTMsList[0].Job_Ticket__c).size() > 0);
        List<AssociatedJobComponentsController.JobTicketComponentWrapper> newWrapperInstance = AssociatedJobComponentsController.retrieveExistingJobTicketComponents(jobTickectMTMsList[0].Job_Ticket__c);
        System.assertEquals(jobTickectMTMsList[0].Name, newWrapperInstance[0].Name );
        
        Test.stopTest();
    }
    
    static testMethod void test_deleteRecordsJobTicketMtm() 
    {
        List<Job_Ticket_MtM__c> jobTickectMTMsList = [Select Id From Job_Ticket_MtM__c];
        List<Id> listOfJobTicketMtmIds = new List<Id>(new Map<Id, Job_Ticket_MtM__c>(jobTickectMTMsList).keySet());
        
        Test.startTest();
        
        AssociatedJobComponentsController.deleteRecordsJobTicketMtm(listOfJobTicketMtmIds);
        List<Job_Ticket_MtM__c> jobTickectMTMsList2 = [Select Id From Job_Ticket_MtM__c Where Id IN: listOfJobTicketMtmIds];
        System.assert(jobTickectMTMsList2.size() == 0);
        
        Test.stopTest();
    }
    
    static testMethod void test_findJobComponentTypes()
    {
        List<Job_Ticket__c> jobTickets = [SELECT Id FROM Job_Ticket__c];
        System.assertEquals(2, jobTickets.size());
        List<Job_Ticket_Component__c> jobTicketComps = [SELECT Id, Component__c FROM Job_Ticket_Component__c];
        String jTC = '[\"'+ jobTicketComps[0].Id + '\"]';
        System.assertEquals(2, jobTicketComps.size());
        Test.startTest();
        AssociatedJobComponentsController.findJobComponentTypes();
        AssociatedJobComponentsController.fetchJobTicketInfo(jobTickets[0].Id);
        AssociatedJobComponentsController.fetchJobTicketComponents(jobTickets[0].Id,jobTicketComps[0].Component__c);
        AssociatedJobComponentsController.saveJobTicketMtm(jobTickets[0].Id,jTC);
        Test.stopTest();
    }
    
    static testMethod void test_NegTestCase() 
    {   
        String jobTicketMtmId = null;
        String jobTicketId = null;
        String compType = null;
        String selectedJobComp = null;
        Test.startTest();
        AssociatedJobComponentsController.fetchJobTicketInfo(jobTicketId);
        AssociatedJobComponentsController.fetchJobTicketComponents(jobTicketId,compType);
        List<AssociatedJobComponentsController.AssociatedFeatureWrapper> associatedFeatureWrap = AssociatedJobComponentsController.showAllAssociatedFeaturesRecords(jobTicketMtmId);
        System.assertEquals(null, associatedFeatureWrap);
        List<AssociatedJobComponentsController.JobTicketComponentWrapper> newWrapperInstance = AssociatedJobComponentsController.retrieveExistingJobTicketComponents(jobTicketId);
        System.assertEquals(null, newWrapperInstance);
        Test.stopTest();
    }
    
    static testMethod void test_deleteAssociatedFeaturesRecords() 
    {
        List<Associated_Features__c> asfList = [Select Id From Associated_Features__c ];
        List<Id> listofAssociatedFeaturesIds = new List<Id>(new Map<Id, Associated_Features__c>(asfList).keySet());
        Test.startTest();
        AssociatedJobComponentsController.deleteAssociatedFeaturesRecords(listofAssociatedFeaturesIds);
        List<Associated_Features__c> asfList2 = [Select Id From Associated_Features__c];
        System.assert(asfList2.size() == 0);
        
        Test.stopTest();
    }
    
    static testMethod void test_createRecordsForAssociatedFeatures() 
    {
        List<Job_Ticket_MtM__c> jobTickectMTMsList = [Select Id,Job_Ticket_Component__c From Job_Ticket_MtM__c];        
        List<String> pmsValueforFront = new List<String>{'Red','Green'};
        List<String> pmsValueforBack = new List<String>{'Blue','Black'};  
        Boolean frontCPType = true;
        Boolean backCPType = true;
        List<JTM_to_Associated_Features_Picklist__mdt> listOfJTMToAFPicklistRecords = CustomMetadataTypesQueryBuilder.getJTMToAssociatedFeaturesPicklistMapping(); 
        
        Test.startTest();
        AssociatedJobComponentsController.createRecordsForAssociatedFeatures(jobTickectMTMsList[0].Id,pmsValueforFront,pmsValueforBack,frontCPType,backCPType,
                                                                               listOfJTMToAFPicklistRecords[0].Associated_Feature_Field__c,
                                                                               listOfJTMToAFPicklistRecords[0].Associated_Feature_Field__c,'C','C');
        List<Associated_Features__c> asfList = [Select Id,Job_Ticket_MtM__c From Associated_Features__c ];
        System.assertEquals(jobTickectMTMsList[0].Id, asfList[0].Job_Ticket_MtM__c);
        AssociatedJobComponentsController.showAllAssociatedFeaturesRecords(jobTickectMTMsList[0].Id);
	//Modified by - Shalu Sharma - 5/18/21 - CR-20210315-14997
	try
        {
	    AssociatedJobComponentsController.fetchFieldsOfJobTicketMtM(jobTickectMTMsList[0].Id);
	}
	Catch(Exception e)
        {
            System.debug(e.getMessage());     
        }
        Test.stopTest();
    }
    
    static testMethod void test_fetchJTMToAssociatedFeaturesPickList()
    {
        Test.startTest();
        try
        {
            AssociatedJobComponentsController.fetchJTMToAssociatedFeaturesPickList();
        }
        Catch(Exception e)
        {
            Boolean expectedExceptionThrown =  e.getMessage().contains(System.Label.Error_Msg_For_Custom_Setting_Not_Exists) ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);     
        }
        Test.stopTest();
    }
    
    
    //Added by - Abhinav Sharma - 03/01/2021 - CR-20201111-14688 - Create Print PT when JT MtM is created
    //Modified By - Abhinav Sharma - 05/17/2021 - CR-20210513-15145
    //Modified By - Abhinav Sharma - 05/20/2021 - CR-20210518-15161
    static testMethod void test_approveJobTicketMtM()
    {
        util.bypassAllTriggers = true;
        
        Id calibratedColorRecordTypeId = PrintManagementTestDataFactory.FindRecordTypeId('Associated_Features__c','Calibrated Color');
        Id InstitutionUsEductaionId = PrintManagementTestDataFactory.FindRecordTypeId('Account', 'US Education');
        
        Account inst = new Account(RecordTypeId = InstitutionUsEductaionId, Vendor_Type__c = 'Vendor', Name = 'Test1');
        insert inst;
        
        Account inst1 = new Account(RecordTypeId = Constants.RECORD_TYPE_ID_ACCOUNT_VENDOR, Vendor_Type__c = 'Vendor', Name = 'Test1');
        insert inst1;
        
        //Create the Project
        Project__c proj = TestUtilities.createProject(false);
        proj.Institution__c = inst.Id;
        insert proj;
        
        Job_Ticket__c jT = PrintManagementTestDataFactory.CreateNewJobTicket(false);
        jT.Project__c = proj.Id;
        jT.Mail_Vendor__c = inst1.Id;
        //Added By - Abhinav Sharma - 06/08/2021 - CR-20210607-15195 - Include Vendor_Type__c = 'Offset'
        jT.Vendor_Type__c = 'Offset';  
        insert jT;
        
        Job_Ticket_Component__c jobTctComponet = PrintManagementTestDataFactory.CreateNewJobTicketComponent(false);
        //Modify by - Shalu Sharma - 5/18/21 - CR-20210315-14997
        jobTctComponet.Component__c = Constants.COMPONENT_TYPE_BRE;
        insert jobTctComponet;
        
        List<Job_Ticket_MtM__c> jobTicketMtMList = new List<Job_Ticket_MtM__c>();
        
        Job_Ticket_MtM__c jobTickectMTMs = PrintManagementTestDataFactory.CreateNewJobTicketMTM(false);
        jobTickectMTMs.Job_Ticket_Component__c = jobTctComponet.Id;
        jobTickectMTMs.Job_Ticket__c = jT.Id;
        jobTickectMTMs.Status__c = 'Draft';
        //Added By - Abhinav Sharma - 05/17/2021 - CR-20210513-15145 - Add Print Method field
        jobTickectMTMs.Print_Method__c = 'Jet';
        //Added By - Abhinav Sharma - 05/20/2021 - CR-20210518-15161
        jobTickectMTMs.Paper_Typex__c = 'White Wove';
        jobTickectMTMs.Paper_Weightx__c = '24#';
        jobTickectMTMs.Component_Code__c = '5114AE0004';
        jobTickectMTMs.Front_of_Colors__c = 1;
        jobTickectMTMs.Front_Colors_PMS__c = 'K';
        
        Job_Ticket_MtM__c jobTickectMTM1 = PrintManagementTestDataFactory.CreateNewJobTicketMTM(false);
        jobTickectMTM1.Job_Ticket_Component__c = jobTctComponet.Id;
        jobTickectMTM1.Job_Ticket__c = jT.Id;
        jobTickectMTM1.Status__c = 'Draft';
        
        jobTicketMtMList.add(jobTickectMTMs);
        jobTicketMtMList.add(jobTickectMTM1);
        insert jobTicketMtMList;
        
        util.bypassAllTriggers = true;
        
        Test.startTest(); 
        
        List<Id> listOfJobTicketMtMIds = new List<Id>();
        
        for(Job_Ticket_MtM__c jtm : [SELECT Id, Status__c, Approved_DateTime__c FROM Job_Ticket_MtM__c WHERE Status__c != 'Approved' AND Id =: jobTicketMtMList[0].Id])
            listOfJobTicketMtMIds.add(jtm.Id);
        
        AssociatedJobComponentsController.approveJobTicketMtM(listOfJobTicketMtMIds);
        
        List<Job_Ticket_MtM__c> listOfJobTicketMtMsAfterUpdate = [SELECT Id, Status__c, Approved_DateTime__c FROM Job_Ticket_MtM__c WHERE Id =: jobTicketMtMList[0].Id AND Status__c = 'Approved'];
        System.assertEquals(Label.Status_Approved, listOfJobTicketMtMsAfterUpdate[0].Status__c);
        System.assert(listOfJobTicketMtMsAfterUpdate[0].Approved_DateTime__c != null);
        
        //Added By - Abhinav Sharma - 05/17/2021 - CR-20210513-15145
        List<Production_Tracking__c> productionTrackings = [SELECT Id, Print__c, Paper_Weight__c FROM Production_Tracking__c WHERE Job_Ticket_MtM__c =: jobTicketMtMList[0].Id];
        System.assert(productionTrackings.size() > 0);
        System.assertEquals(jobTickectMTMs.Print_Method__c, productionTrackings[0].Print__c);//End
        Test.stopTest();
        
        //Added By - Abhinav Sharma - 05/20/2021 - CR-20210518-15161
        try
        {
            List<Id> listOfJobTicketMtMIds1 = new List<Id>{jobTicketMtMList[1].Id};
            LightningResponseEntity res = AssociatedJobComponentsController.approveJobTicketMtM(listOfJobTicketMtMIds1);
        }
        Catch(Exception e)
        {
            Boolean expectedExceptionThrown =  e.getMessage().contains(Label.Before_Status_As_Approved_Msg) ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);     
        }
    }
}