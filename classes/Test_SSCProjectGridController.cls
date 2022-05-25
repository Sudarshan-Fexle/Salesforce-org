/**
*  Purpose         :   This Class is used to test all the manipulation of Apex Class - SSCProjectGridController 
*
*  Create By       :   Dipesh Gupta
*
*  Created Date    :   04/16/2019
*
*  Revision Logs   :   V_1.0 - Created.
					   V_1.1 - Modified By Dipesh Gupta - CR-20190529-13156 - 09/04/2019 - Record type Label Modified From 'SSC' To 'Tech'

*                      
**/
@isTest
public class Test_SSCProjectGridController {  
    
    /**
    *  @description    :  This method is used to Insert Data for testing purpose.  
    * 
    *  @args           :   
    * 
    *  @return         :   void
    *
    *	@Revision Log	:	V1.0 - 04/16/2019 - Dipesh Gupta - Created
    *
    **/ 
    @TestSetUp Static void testSetUpData(){
        
        //Trigger Bypass
        Util.BypassAlltriggers = true;
        SSCProjectGridController.byPass_DeploymentTrigger = true;
        
        
        //Program.
        Program__c testProgramData = TestUtilities.CreateNewProgram(true);
        
        //Inserting account record.
        Account testInstitutionData = TestUtilities.CreateNewAccount(true);
        
        //Trigger Bypass
        Util.BypassAllTriggers = false;
        
        //Modified By Dipesh Gupta - CR-20190529-13156 - 09/04/2019 - Record type Label Modified From 'SSC' To 'Tech'
        //Inserting Project 
        Project__c testProjectData = new Project__c();
        testProjectData.RecordTypeId = Schema.SObjectType.Project__c.getRecordTypeInfosByName().get('Tech').getRecordTypeId();
        testProjectData.Name  = 'Tech Hub Success';
        testProjectData.Product__c = testProgramData.Id;
        testProjectData.Institution__c = testInstitutionData.Id ;
        insert testProjectData;
        
        //Inserting Deployment 
        Deployment__c testDeploymentData = new Deployment__c();
        testDeploymentData.RecordTypeId = Schema.SObjectType.Deployment__c.getRecordTypeInfosByName().get('SSC - Grid').getRecordTypeId();
        testDeploymentData.Name = 'Server Side Instalation';
        testDeploymentData.Project__c = testProjectData.Id; 
        testDeploymentData.Module__c = 'APS';
        insert testDeploymentData;
        
        //Inserting Deployment with true checkbox
        Deployment__c gridRecord = new Deployment__c(RecordTypeId = Schema.SObjectType.Deployment__c.getRecordTypeInfosByName().get('SSC - Grid').getRecordTypeId(),
                                                     Name = 'Client Side Instalation',
                                                     Project__c = testProjectData.Id,
                                                     Module__c = 'APS');
	}
    
    Static testMethod void testSSCProjectGridController() {
        
        //Fetcing Project Id tu put into page
        Project__c proData = [SELECT Id FROM Project__c LIMIT 1];
        
        Test.StartTest();         
        
        //Putting Projecg Id into page 
        ApexPages.currentPage().getParameters().put('id', String.valueOf(proData.Id));
        
        ApexPages.StandardController sc = new ApexPages.StandardController(proData);

        //Instance of Controller Class
        SSCProjectGridController  testProjectGrid = new SSCProjectGridController(sc);
        
        testProjectGrid.fetchSSCGridDataInformation();
        
        //Upsert case.
        testProjectGrid.sscGridWrapper[0].isSelected = true;
        testProjectGrid.sscGridWrapper[0].gridRecord.Go_Live__c = date.today();
        testProjectGrid.doSave();
        
        List<Deployment__c> deploymentJustSaved = [Select Id, Go_Live__c From Deployment__c Where Go_Live__c != null];
        
        System.assertEquals(1, deploymentJustSaved.size());
        System.assertEquals(Date.Today(), deploymentJustSaved[0].Go_Live__c);
        
        //Deletion Case.  
        testProjectGrid.sscGridWrapper[0].isSelected = true;
        testProjectGrid.doDelete();
        
        List<Deployment__c> deploymentJustSaved1 = [Select Id, Go_Live__c From Deployment__c Where Go_Live__c != null];
        System.assertEquals(0, deploymentJustSaved1.size());
       	
        //Call methods.
        testProjectGrid.changeReadToEditMode ();
        testProjectGrid.changeReadToEditModeWithDeleted ();
        testProjectGrid.addNewLine();
        
        Test.StopTest();
        
    }
}