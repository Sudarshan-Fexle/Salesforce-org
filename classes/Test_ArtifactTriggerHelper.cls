/*
* Purpose          :   Test class for ArtifactTriggerHelper
* 
* CreatedDate      :   4/10/2020
* 
* RevisionLog      :   V_1.0 - Created - Dipesh Gupta
*                      V_1.1 - Modified By - 04/30/2021 - CR-20210323-15016 - Neha Sharma - populate drop type
* Code Coverage    :   
* */
@IsTest(SeeAllData=false)
private class Test_ArtifactTriggerHelper
{
    @testSetup static void testSetupData()
    {
         Map<String, List<Artifact_Transfer_Setting__mdt>> mapOfATS = new Map<String, List<Artifact_Transfer_Setting__mdt>>();
        
        //Get Data
        for(Artifact_Transfer_Setting__mdt atSetting: [SELECT Id, Artifact_Type__c, Artifact_Source__c, Artifact_Target__c, Drop_Type__c,
                                                       Direction__c, Mail_Shop_Vendor__c, Transfer_Type__c, Source_Host_Profile__c, 
                                                       Source_File_Name_Exact__c, Source_File_Name_Regex__c, Source_Directory_Path__c,
                                                       Target_Directory_Path__c, Target_Host_Profile__c, Transformation_Profile__c,
                                                       PGP_Encryption_Profile__c, PGP_Decryption_Profile__c, Proof_Generation__c
                                                       FROM Artifact_Transfer_Setting__mdt WHERE Status__c = 'Active' AND Proof_Generation__c = 'Internal'
                                                       AND Drop_Type__c = 'Pre Planned' AND Mail_Shop_Vendor__c = 'N00141688']){
        	                                              
            String key = atSetting.Artifact_Type__c + '-' + atSetting.Mail_Shop_Vendor__c + '-' + atSetting.Proof_Generation__c + '-' + atSetting.Drop_Type__c ;
            List<Artifact_Transfer_Setting__mdt> ats = mapOfATS.get(key);
            if (ats == null) ats = new List<Artifact_Transfer_Setting__mdt>();
            ats.add(atSetting);
            mapOfATS.put(key, ats);                                    
        }
        ArtifactTriggerHelper.keyToArtifactSetting = mapOfATS;
        
         Util.BypassAllTriggers = true;
        // Create Account
        Account inst = new Account(RecordTypeId = Constants.RECORD_TYPE_ID_ACCOUNT_VENDOR,Vendor_Type__c = 'Vendor', Name = 'Test1',Account_Formal_Name__c = 'Sepire',r_School_Code__c = '1234', 
                                   Historical_Linker__c = 'N00141688');  //N00141269
        insert inst;
        
        Account inst2 = new Account(RecordTypeId = Constants.RECORD_TYPE_ID_ACCOUNT_VENDOR,Vendor_Type__c = 'Vendor', Name = 'Test2',
                                    Account_Formal_Name__c = 'Sepire',r_School_Code__c = '123', 
                                   Historical_Linker__c = 'N00141688');  //N00141269
        insert inst2;
        //inst2.Historical_Linker__c = 'N00141688';
        //update inst2;
        
        List<Account> accLi = [SELECT Id,Historical_Linker__c FROM Account WHERE Id =: inst.Id OR Id =: inst.Id];
        
        //Create a user for running the process
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        
        User user1 = testUtilities.CreateNewUser(sysAdminProfile, false);
        user1.LastName = 'sysAdminUser';
        insert user1;
        
        //Creating ES Campaign record
        List<ES_Campaign__c> escCampaigns = new List<ES_Campaign__c>();
        escCampaigns.add(new ES_Campaign__c(Fiscal_Year__c = '2019', Status__c = 'Open', School__c = inst.Id, Project_Manager__c = user1.id));
        escCampaigns.add(new ES_Campaign__c(Fiscal_Year__c = '2020', Status__c = 'In Process', School__c = inst.Id, Project_Manager__c = user1.id));
        insert escCampaigns;
        
        Id programId = TestUtilities.CreateNewProgram(true).Id;
       
        //String jobTicketRecordTypeId = Schema.SObjectType.Project__c.getRecordTypeInfosByDeveloperName().get('SSC').getRecordTypeId();
        Project__c project = new Project__c(Name = 'Test Project', Institution__c = inst.Id);
        insert project;
        
        //04/30/2021 - CR-20210323-15016 - Neha Sharma - populate drop type
        //Creating Job Ticket record 
        List<Job_Ticket__c> jobTickets = new List<Job_Ticket__c>();
        jobTickets.add(new Job_Ticket__c(Drop_Type__c = 'Pre Planned',ES_Campaign__c = escCampaigns[0].Id, Project__c = project.Id, Project_ID__c = 'test', Status__c = 'Draft', Project_Manager__c = user1.Id, Descriptive_Name__c = 'Test', Art_Director__c = user1.Id, Mail_Quantity__c = 100, Change_Reason__c = 'Testing before update'));
        /*jobTickets.add(new Job_Ticket__c(ES_Campaign__c = escCampaigns[1].Id, Project__c = project.Id, Status__c = 'Draft', Project_Manager__c = user1.Id, Descriptive_Name__c = 'Test', Art_Director__c = user1.Id, Mail_Quantity__c = 500, Change_Reason__c = 'Testing before update'));
		jobTickets.add(new Job_Ticket__c(ES_Campaign__c = escCampaigns[1].Id, Project__c = project.Id, Status__c = 'Draft', Project_Manager__c = user1.Id, Descriptive_Name__c = 'Test', Art_Director__c = user1.Id, Mail_Quantity__c = 100, Change_Reason__c = 'Testing before update'));*/
        insert jobTickets;
                
        //Create Production Trackings
        List<Production_Tracking__c> productionTrackings = new List<Production_Tracking__c>();
        productionTrackings.add(new Production_Tracking__c(Drop__c = 1,Art_File_Name__c = 'test',Status__c = 'Planned', Job_Ticket__c = jobTickets[0].Id,Status_Detail__c = '',Mail_Shop_Vendor__c = inst.Id));
        insert productionTrackings;
                
        Util.BypassAllTriggers = false;
        //Creating artifact record
        List<Artifact__c> artifactList = new List<Artifact__c>();
        artifactList.add(new Artifact__c(Type__c = 'Artwork',Status__c ='Success',Production_Tracking__c = productionTrackings[0].Id,Job_Ticket__c = jobTickets[0].Id,
                                        Source_Directory_Path_Override__c ='/PrintMIS/<Production_Tracking__r.Job_Ticket__r.Fiscal_Year__c>/<Production_Tracking__r.Job_Ticket__r.Name>/'
                                        , Proof_Generation__c = 'Internal', Drop_Type__c = 'Pre Planned'));
        //artifactList.add(new Artifact__c(Type__c = 'Artwork',Status__c ='Transferring',Job_Ticket__c = jobTickets[0].Id,Production_Tracking__c = productionTrackings[0].Id ));
        Insert artifactList;
        
        Artifact__c artifact = [SELECT Id,Type__c,Production_Tracking__r.Mail_Shop_Vendor__r.Historical_Linker__c,Proof_Generation__c,Drop_Type__c 
                            FROM Artifact__c WHERE Id =: artifactList[0].Id LIMIT 1];
               
        //Creating artifact Transfer record
        List<Artifact_Transfer__c> artifactTransList = new List<Artifact_Transfer__c>();
        artifactTransList.add(new Artifact_Transfer__c(Artifact__c = artifactList[0].Id, Direction__c = ArtifactTransferHelper.DIRECTION_PULL,Status__c = 'Staging'));
        artifactTransList.add(new Artifact_Transfer__c(Artifact__c = artifactList[0].Id, Direction__c = ArtifactTransferHelper.DIRECTION_PULL,Status__c = 'Staging'));
        artifactTransList.add(new Artifact_Transfer__c(Artifact__c = artifactList[0].Id, Direction__c = ArtifactTransferHelper.DIRECTION_PULL,Status__c = 'Transfer Now'));
        insert artifactTransList;
    }
    
    static testMethod void testupdateArtifactTransferAndProductionTracking()
    {
        Test.startTest();
                
        List<Artifact__c> artifactList = [Select Id,Status__c,Production_Tracking__c,Job_Ticket__c From Artifact__c];
        
        //Update Artifact Status
        artifactList[0].Status__c = 'Success';
        update artifactList;
        
        List<Artifact_Transfer__c> artifactTransList = [Select Id,Status__c From Artifact_Transfer__c LIMIT 1];
        system.assert(true,artifactTransList.size() > 0);
        
        //Update Artifact Status
        artifactList[0].Status__c = 'Transfer Now';
        update artifactList;
        
        //Update Artifact Status
        artifactList[0].Status__c = 'Failure';
        update artifactList;
        Test.stopTest();
    }
    
   	static testMethod void test_createArtifactTransfer(){
       
        //Get Data of matadata
        List<Artifact_Transfer_Setting__mdt> ats = [SELECT Id,Source_File_Name_Exact__c,Source_Directory_Path__c,Target_Directory_Path__c,Source_File_Name_RegEx__c,
                                                    Direction__c,Source_Host_Profile__c,Transfer_Type__c,PGP_Decryption_Profile__c,PGP_Encryption_Profile__c,
                                                    Transformation_Profile__c,Target_Host_Profile__c,Artifact_Source__c,Artifact_Target__c
                                                    FROM Artifact_Transfer_Setting__mdt z];
        
        //Get data of Artifact
       	List<Artifact__c> artifactList = [Select Id,Status__c,Production_Tracking__c,Job_Ticket__c,Source_File_Name_Exact_Override__c,
                                          Source_Directory_Path_Override__c From Artifact__c];
		
        //Test start here
        Test.startTest();
        
        //Calling method
        ArtifactTriggerHelper.createArtifactTransfer(ats[0], artifactList[0]);
        
        //Test stop here
        Test.stopTest();
   	}
}