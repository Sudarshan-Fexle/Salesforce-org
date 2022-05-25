/*
* Purpose          :   Test class for ArtifactTransferHelper
* 
* CreatedDate      :   4/13/2020
* 
* RevisionLog      :   V_1.0 - Created - Dipesh Gupta
*		       V_1.1 - 08/17/2020 - CR-20200803-14397 - Added testupdateArtifactTransfer_RetryCount
*                      V_1.2 - 12/14/2020 - CR-20201012-14597 - Victor Hanson - updated testSetupData & testupdateArtifactTransferAndProductionTracking to improve code coverage & assertion
*		       V_1.3 - Modified By - Neha Sharma (Added Drop_Type__c missing field) - 05/12/2021
*		       V_1.4 - Modified By - Neha Sharma - 05/18/21 - CR-20200701-14253 - Check if the the Status is Changed to Transferring
*                      V_1.5 - Modified By - Shalu Sharma - CR-20210517-15151 - Update method "testupdatesOnArtifactStatusChange" to populate Drop_Type__c field on Job Ticket 
* 
* Code Coverage    :   
* */
@IsTest
private class Test_ArtifactTransferHelper
{
    @testSetup static void testSetupData()
    {
        util.bypassAllTriggers = true;
        Account inst = TestUtilities.CreateNewAccount(true);
        util.bypassAllTriggers = false;

        //Create the Project
        Project__c proj = TestUtilities.createProject(false);
        proj.Institution__c = inst.Id;
        util.BypassAllTriggers = true;
        insert proj;
        util.BypassAllTriggers = false;

        //Creating Job Ticket record 
        //modified by Neha Sharma (Added Drop_Type__c missing field) on 05/12/2021
        Job_Ticket__c jt = new Job_Ticket__c(Project__c = proj.Id, Status__c = 'Draft', Project_Manager__c = UserInfo.getUserId(), Descriptive_Name__c = 'Test', Art_Director__c = UserInfo.getUserId(), Mail_Quantity__c = 100,
                                             Change_Reason__c = 'Testing before update', Project_ID__c = 'Test', Fiscal_Year__c='2020', Drop_Type__c = System.Label.DROP_TYPE_ON_DEMAND);
        util.BypassAllTriggers = true;
        insert jt;
        
        Contact con = new Contact(FirstName = 'TestContact1', LastName = 'Contact1', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855', AccountId = inst.Id, Employee_User_Record__c = Userinfo.getUserId());
        util.BypassAllTriggers = true;
        insert con;

        Team_Role__c artTxAssignmentRole = new Team_Role__c(Name = Label.Artifact_Transfer_Staff_Assignment,Active__c = true, Institution__c = true);
        util.BypassAllTriggers = true;
        insert artTxAssignmentRole;

        Team_Membership__c tMember = new Team_Membership__c(Role__c = artTxAssignmentRole.Id, Name = 'Test As 1',Institution__c = inst.Id, Staff_member__c = con.id, Start_date__c = System.today().addDays(-3), End_date__c = System.today().addDays(5));
        util.BypassAllTriggers = true;
        insert tMember;

        //Insert artifact
        util.BypassAllTriggers = false;
        List<Artifact__c> artifactList = new List<Artifact__c>();
        artifactList.add(new Artifact__c(Status__c ='failure', Job_Ticket__c = jt.Id));
        artifactList.add(new Artifact__c(Status__c ='Staging', Job_Ticket__c = jt.Id));
        insert artifactList;
        
        //Insert Artifact Transfer
        List<Artifact_Transfer__c> artifactTransList = new List<Artifact_Transfer__c>();
        artifactTransList.add(new Artifact_Transfer__c(Artifact__c = artifactList[0].Id, Direction__c = ArtifactTransferHelper.DIRECTION_PUSH,Status__c = 'Staging'));
        artifactTransList.add(new Artifact_Transfer__c(Artifact__c = artifactList[1].Id, Direction__c = ArtifactTransferHelper.DIRECTION_PUSH,Status__c = 'Staging'));
        artifactTransList.add(new Artifact_Transfer__c(Artifact__c = artifactList[0].Id, Direction__c = ArtifactTransferHelper.DIRECTION_PULL,Status__c = 'Transfer Now'));
        insert artifactTransList;
    }
    
    @IsTest static void testupdateArtifactTransferAndProductionTracking()
    {        
        Test.startTest();
        
        //Get Artifact Record
        List<Artifact__c> artifactList = [Select Id,Status__c,Production_Tracking__c,Job_Ticket__c From Artifact__c];
        
        //Get Artifact Transfer record
        List<Artifact_Transfer__c> artifactTransList = [Select Id,Status__c From Artifact_Transfer__c];
        
        //Mock class for callout
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponseGenerator());
        
        //update the status
        artifactTransList[0].Status__c = 'Transfer Now';
        artifactTransList[1].Status__c = 'FAILURE';
        artifactTransList[1].Status__c = 'success';
        update artifactTransList;
        
        //Assertion
        system.assertEquals('Failure', artifactList[0].status__c);
        
        //force suppression emails to send
        List<Id> artifactTxIds = new List<Id>();
        for (Artifact_Transfer__c aTx : artifactTransList)
            artifactTxIds.add(aTx.Id);
        ArtifactTransferHelper.buildAndSendSuppressionEmailAlert(artifactTxIds);
        
        Integer numEmailSent = Limits.getEmailInvocations();

        Test.stopTest();

        system.assert(numEmailSent > 0, 'at least one email should have been sent.');
    }
    
    @IsTest static void testupdateArtifactTransfer_RetryCount()
    {
        
        //12/14/2020 - CR-20201012-14597 - Victor Hanson - remove unused local variable
        //Get Artifact Record
        //List<Artifact__c> artifactList = [Select Id,Status__c,Production_Tracking__c,Job_Ticket__c From Artifact__c];
        
        //Get Artifact Transfer record
        List<Artifact_Transfer__c> artifactTransList = [Select Id,Status__c,Retry_Count__c From Artifact_Transfer__c WHERE Status__c = 'Staging' LIMIT 2];
        
        artifactTransList[0].Retry_Count__c = 0;
        artifactTransList[1].Retry_Count__c = Decimal.valueOf(Label.Artifact_Transfer_Max_Retries); //set max retry count
        
        //update the status
        for (Artifact_Transfer__c aTx : artifactTransList)
        	aTx.Status__c = ArtifactTransferHelper.FAILURE;
        
        //Mock class for callout
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponseGenerator());
        
        Test.startTest();
        update artifactTransList;
        Test.stopTest();
        artifactTransList = [SELECT Id,Status__c,Retry_Count__c FROM Artifact_Transfer__c WHERE Id IN :artifactTransList AND Retry_Count__c > 0 ORDER BY Retry_Count__c ASC];
        
        //Assertion
        system.assertEquals(1, artifactTransList[0].Retry_Count__c);
        system.assertEquals(2, artifactTransList[1].Retry_Count__c);
        
        //force suppression emails to send
        List<Id> artifactTxIds = new List<Id>();
        for (Artifact_Transfer__c aTx : artifactTransList)
            artifactTxIds.add(aTx.Id);
        ArtifactTransferHelper.buildAndSendSuppressionEmailAlert(artifactTxIds);
    }
    
    // Modified By - Neha Sharma - PrintMIS: XMPie API Updates release coverage increase
    @IsTest static void testUpdateArtifactOnartifactTxStatusUpdate(){
       util.bypassAllTriggers = true;
        Account inst = TestUtilities.CreateNewAccount(true);
        util.bypassAllTriggers = false;

        //Create the Project
        Project__c proj = TestUtilities.createProject(false);
        proj.Institution__c = inst.Id;
        util.BypassAllTriggers = true;
        insert proj;
        util.BypassAllTriggers = false;

         //Creating Job Ticket record 
         //modified by Neha Sharma (Added Drop_Type__c missing field) on 05/12/2021
        Job_Ticket__c jt = new Job_Ticket__c(Project__c = proj.Id, Status__c = 'Draft', Project_Manager__c = UserInfo.getUserId(), Descriptive_Name__c = 'Test', Art_Director__c = UserInfo.getUserId(), Mail_Quantity__c = 100,
                                             Change_Reason__c = 'Testing before update', Project_ID__c = 'Test', Fiscal_Year__c='2020', Drop_Type__c = System.Label.DROP_TYPE_ON_DEMAND);
        insert jt;
        
        List<Production_Tracking__c> productionTrackings = new List<Production_Tracking__c>();
        productionTrackings.add(new Production_Tracking__c(Mail_Shop_Vendor__c =  null, Status__c = Constants.PRODUCTION_TRACKING_STATUS_PLANNED,Job_Ticket__c = jt.Id, RecordTypeId=Constants.RECORD_TYPE_ID_PRODUCTION_TRACKING_MAIL_SHOP, Proof_Generation__c = ProductionTrackingTriggerHelper.PROOF_GENERATION_EXTERNAL));
         insert productionTrackings;
        
        List<Artifact__c> artifactList = new List<Artifact__c>();
        artifactList.add(new Artifact__c(Status__c ='failure', Job_Ticket__c = jt.Id,Production_Tracking__c = productionTrackings[0].Id));
        artifactList.add(new Artifact__c(Status__c ='Staging', Job_Ticket__c = jt.Id,Production_Tracking__c = productionTrackings[0].Id));
        insert artifactList;
        
        util.bypassAllTriggers = false;
        
        //Insert Artifact Transfer
        String artFileName = 'Test1.zip';
        String STATUS_SUCCESS = 'Success';
        List<Artifact_Transfer__c> artifactTransList = new List<Artifact_Transfer__c>();
        artifactTransList.add(new Artifact_Transfer__c(Artifact__c = artifactList[0].Id, Direction__c = ArtifactTransferHelper.DIRECTION_PUSH,Status__c = 'Staging', Target_File_Name__c = artFileName));
        artifactTransList.add(new Artifact_Transfer__c(Artifact__c = artifactList[1].Id, Direction__c = ArtifactTransferHelper.DIRECTION_PUSH,Status__c = 'Staging', Target_File_Name__c = artFileName));
        artifactTransList.add(new Artifact_Transfer__c(Artifact__c = artifactList[0].Id, Direction__c = ArtifactTransferHelper.DIRECTION_PULL,Status__c = 'Transfer Now', Target_File_Name__c = artFileName));
        insert artifactTransList;
        
        artifactTransList[0].Target_File_Name__c = 'test.zip';
        artifactTransList[0].Status__c = STATUS_SUCCESS;
        update artifactTransList[0];
        
        
    }
    
    // Added By - Neha Sharma - 05/18/21 - CR-20200701-14253 - Check if the the Status is Changed to Transferring
    // Modified By - Shalu Sharma - CR-20210517-15151 - To populate Drop_Type__c field on Job Ticket
    @IsTest static void testupdatesOnArtifactStatusChange()
    {
       	util.bypassAllTriggers = true;
        Account inst = TestUtilities.CreateNewAccount(true);

        //Create the Project
        Project__c proj = TestUtilities.createProject(false);
        proj.Institution__c = inst.Id;
        insert proj;
        
        //Added By - Shalu Sharma - CR-20210517-15151 - To populate Drop_Type__c field on Job Ticket
        //Creating Job Ticket record
        Job_Ticket__c jt = new Job_Ticket__c(Project__c = proj.Id, Status__c = 'Draft', Project_Manager__c = UserInfo.getUserId(), Descriptive_Name__c = 'Test', Art_Director__c = UserInfo.getUserId(), Mail_Quantity__c = 100,
                                             Change_Reason__c = 'Testing before update', Project_ID__c = 'Test', Fiscal_Year__c='2020', Drop_Type__c = 'Pre Planned');
        insert jt;
        
        List<Production_Tracking__c> productionTrackings = new List<Production_Tracking__c>();
        productionTrackings.add(new Production_Tracking__c(Mail_Shop_Vendor__c =  null, Status__c = Constants.PRODUCTION_TRACKING_STATUS_PLANNED,Job_Ticket__c = jt.Id, RecordTypeId=Constants.RECORD_TYPE_ID_PRODUCTION_TRACKING_MAIL_SHOP, Proof_Generation__c = ProductionTrackingTriggerHelper.PROOF_GENERATION_EXTERNAL));
         insert productionTrackings;
        
        List<Artifact__c> artifactList = new List<Artifact__c>();
        artifactList.add(new Artifact__c(Status__c ='Staging', Job_Ticket__c = jt.Id,Production_Tracking__c = productionTrackings[0].Id));
        artifactList.add(new Artifact__c(Status__c ='Staging', Job_Ticket__c = jt.Id,Production_Tracking__c = productionTrackings[0].Id));
        artifactList.add(new Artifact__c(Status__c ='Staging', Job_Ticket__c = jt.Id,Production_Tracking__c = productionTrackings[0].Id));
        artifactList.add(new Artifact__c(Status__c ='Staging', Job_Ticket__c = jt.Id,Production_Tracking__c = productionTrackings[0].Id));
        insert artifactList;
    
        //Insert Artifact Transfer
        String artFileName = 'Test1.zip';
        String STATUS_SUCCESS = 'Success';
        List<Artifact_Transfer__c> artifactTransList = new List<Artifact_Transfer__c>();
        artifactTransList.add(new Artifact_Transfer__c(Artifact__c = artifactList[0].Id, Direction__c = ArtifactTransferHelper.DIRECTION_PUSH,Status__c = 'Staging', Target_File_Name__c = artFileName));
        artifactTransList.add(new Artifact_Transfer__c(Artifact__c = artifactList[1].Id, Direction__c = ArtifactTransferHelper.DIRECTION_PUSH,Status__c = 'Staging', Target_File_Name__c = artFileName));
        artifactTransList.add(new Artifact_Transfer__c(Artifact__c = artifactList[2].Id, Direction__c = ArtifactTransferHelper.DIRECTION_PULL,Status__c = 'Transfer Now', Target_File_Name__c = artFileName));
        artifactTransList.add(new Artifact_Transfer__c(Artifact__c = artifactList[3].Id, Direction__c = ArtifactTransferHelper.DIRECTION_PULL,Status__c = 'Transfer Now', Target_File_Name__c = artFileName));
        insert artifactTransList;
        
        Test.startTest();
        
        artifactTransList[2].Target_File_Name__c = 'test.zip';
        artifactTransList[2].Status__c = 'Transferring';
        
        artifactTransList[3].Target_File_Name__c = 'test.zip';
        artifactTransList[3].Status__c = 'Transferring';
        
        util.BypassAllTriggers = false;
        update artifactTransList;
        
        //Asserts
        List<Artifact_Transfer__c> artifactsTransfer = [select Id, Name, Status__c, Artifact__r.status__c From Artifact_Transfer__c 
                                                        Where Artifact__c IN : new Set<Id>{artifactList[2].Id, artifactList[3].Id}];
        system.assertEquals(artifactsTransfer[0].Status__c,artifactsTransfer[0].Artifact__r.status__c);
        system.assertEquals(artifactsTransfer[1].Status__c,artifactsTransfer[1].Artifact__r.status__c);

        Test.stopTest();
        
    }
}