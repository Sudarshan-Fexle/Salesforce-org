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
private class UpdateQ2CTemplateController_Test {
    /**
        Purpose         :   Test class for UpdateQ2CTemplateController
                    
        Created By       :  Victor Hanson
        
        Revision Log    :   V1.0 - Created - DS061
                           
        Coverage        :   V_1.0 - UpdateQ2CTemplateController
			:   V_1.1 - Modified By - Neha Sharma - CR-20211012-15511
    **/
    static testmethod void testController() {
        //create content doc
        ContentVersion content = new ContentVersion(VersionData=Blob.valueOf('unit test Attachment Body'),
                                                    Title ='New Content Test',PathOnClient='test'); 
        insert content;
        content = [SELECT id, ContentDocumentId FROM ContentVersion WHERE Id = :content.Id];
        
        //create CPQ Template
        CPQ_Template__c cpqTemplate = new CPQ_Template__c(Name='BICO Calculator',Active__c=true,Published__c=true,
                                                          Category__c='Calculator',Template_Document_Id__c=content.ContentDocumentId);
        insert cpqTemplate;
        
        //create OSR
        OSR__c osr = new OSR__c(Request_Type__c='Modify',Requested_By__c=UserInfo.getUserId(),Approved_By__c=UserInfo.getUserId(),
                               Approved_Date__c=Date.today(),Description_of_Change__c='test',Reason_for_Change__c='test',
                                CPQ_Template__c=cpqTemplate.Id);
        insert osr;
        
        //instantiate controller
        PageReference pageRef = Page.UpdateQ2CTemplatePage;
        pageRef.getParameters().put('Id', cpqTemplate.Id);
        pageRef.getParameters().put('OSRID', osr.Id);
        Test.setCurrentPage(pageRef);
        
        updateQ2CTemplateController controller = new updateQ2CTemplateController();
        //attach new file content
        controller.fileContent = Blob.valueOf('Test content 2');
        controller.contentToUpload.PathOnClient = 'test';
        PageReference pg = controller.uploadContentAndUpdateQ2CTemplate();
        PageReference pg2 = controller.uploadContentAndUpdateQ2CTemplate();
        //get the updated OSR record
        osr = [SELECT Id, Completed_Date__c, Updated_Version_Number__c FROM OSR__c WHERE Id = :osr.Id];
        
        //assertions
        system.assertEquals(date.today(), osr.Completed_Date__c);
        system.assertEquals(2, osr.Updated_Version_Number__c);
        system.assertEquals(controller.back().getURL(), pg.getURL());
        
        //Modified By - Neha Sharma - CR-20211012-15511
        String str = OSRTriggerHelper.trunc('TestData',2);
        System.assertEquals('Te' ,str);
        
        OSRTriggerHelper.testEchoSignProcess();
        List<echosign_dev1__SIGN_Agreement__c> sa = [Select Id From echosign_dev1__SIGN_Agreement__c];
        System.assertEquals(1,sa.size());
    }
}