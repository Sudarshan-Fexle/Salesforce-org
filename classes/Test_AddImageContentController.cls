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
 *   Purpose        :   Test class for AddImageContentController
 *       
 *   Created By     : 
 *
 *   Created Date   :   08/12/2014
 *
 *   Revision Log   :   V1.0 - Created 
 * 						V_2.0 - Modified By - Rajeev Jain - CR 7579 - Increase Coverage - 09/03/2015   
 *                      
 *   Coverage       :   V1.0 - 97% 
 *                  
 **/ 
@isTest(seeAllData = true)
private class Test_AddImageContentController {
    
    //Method to check functionality of AddImageContentController Generate Exception. covers Save and upload document excpetion lines
    static testMethod void testMainAdHocGenerateException() {
        
        //Insert intranet item for testing
        Intranet_Item__c intranetItem = new Intranet_Item__c(Name = 'Test ABC');
        //insert intranetItem ;
        
        //Gete the Document Folder
        List<Folder> boardroomResourcesFolder = [Select Id from Folder where DeveloperName =: ManageImageSetController.FOLDER_BOARDROOM_RESOURCES limit 1];
        System.assertEquals(1, boardroomResourcesFolder.size());
                
        //Feed items
        Document document = new Document(Body = blob.valueOf('TestABCD'), Name = 'Test', FolderId = boardroomResourcesFolder[0].Id);
        
        ///Test starts here
        Test.startTest();
        
        //Calling standard constructor
        ApexPages.StandardController sc = new ApexPages.StandardController(intranetItem);
        AddImageContentController controller = new  AddImageContentController(sc);
        
        //select option  list
        List<SelectOption> selectOption = controller.types;
        List<SelectOption> selectOptionContent = controller.contentTypes;
        
        //Generate Page error for leaving blank doumcnet
        //Calling methods
        //controller.document = document;
        controller.selectedType = AddImageContentController.IMAGE_TYPE_MAIN; 
        controller.uploadDocument();
        controller.save();
        
        //Now Set Document to COntroller Document Object
        //Now Pass Orignal Document not blank so this exception not generate
        controller.document = document;
        controller.selectedType = AddImageContentController.IMAGE_TYPE_MAIN; 
        controller.uploadDocument();
        controller.save();
        
        //This is just for Coverage and resetting boolean flag
        controller.goToStep1();
        controller.goToStep2();
        controller.goToStep3();
        controller.goToStep4();
        
        //Call controller property to increase code coverage
        controller.selectedContentType = '';
        
        //Test stops here
        Test.stopTest();
    }
    
    //Method to check functionality of AddImageContentController
    static testMethod void testMainAdHoc() {
        
        //Insert intranet item for testing
        Intranet_Item__c intranetItem = new Intranet_Item__c(Name = 'Test ABC');
        insert intranetItem ;
        
        //Gete the Document Folder
        List<Folder> boardroomResourcesFolder = [Select Id from Folder where DeveloperName =: ManageImageSetController.FOLDER_BOARDROOM_RESOURCES limit 1];
        System.assertEquals(1, boardroomResourcesFolder.size());
                
        //Feed items
        Document document = new Document(Body = blob.valueOf('TestABCD'), Name = 'Test', FolderId = boardroomResourcesFolder[0].Id);
        
        ///Test starts here
        Test.startTest();
        
        //Calling standard constructor
        ApexPages.StandardController sc = new ApexPages.StandardController(intranetItem);
        AddImageContentController controller = new  AddImageContentController(sc);
        
        //select option  list
        List<SelectOption> selectOption = controller.types;
        List<SelectOption> selectOptionContent = controller.contentTypes;
        
        //Calling methods
        controller.document = document;
        controller.selectedType = AddImageContentController.IMAGE_TYPE_MAIN; 
        controller.uploadDocument();
        controller.save();
        
        //This is just for Coverage and resetting boolean flag
        controller.goToStep1();
        controller.goToStep2();
        controller.goToStep3();
        controller.goToStep4();
        
        //Test stops here
        Test.stopTest();
        
        //Assert that Image_for_Main_Content__c field  should be populated with a document Id
        intranetItem = [SELECT Id, Ad_Hoc_Main_Image_Id__c FROM Intranet_Item__c WHERE ID =: intranetItem.Id];
        System.assert(intranetItem.Ad_Hoc_Main_Image_Id__c != null);
        
        //Fetch the newly created document in database
        List<Document> documents = [Select Id from Document where Id =: intranetItem.Ad_Hoc_Main_Image_Id__c];
        System.assertEquals(1,  documents.size());
    }
    
    //Method to check functionality of AddImageContentController
    static testMethod void testThumbAdHoc() {
        
        //Insert intranet item for testing
        Intranet_Item__c intranetItem = new Intranet_Item__c(Name = 'Test ABC');
        insert intranetItem ;
        
        //Get the Document Folder
        List<Folder> boardroomResourcesFolder = [Select Id from Folder where DeveloperName =: ManageImageSetController.FOLDER_BOARDROOM_RESOURCES limit 1];
        System.assertEquals(1, boardroomResourcesFolder.size());
                
        //Feed items
        Document document = new Document(Body = blob.valueOf('TestABCD'), Name = 'Test', FolderId = boardroomResourcesFolder[0].Id);
        
        ///Test starts here
        Test.startTest();
        
        //Calling standard constructor
        ApexPages.StandardController sc = new ApexPages.StandardController(intranetItem);
        AddImageContentController controller = new  AddImageContentController(sc);
        
        //select option  list
        List<SelectOption> selectOption = controller.types;
        List<SelectOption> selectOptionContent = controller.contentTypes; 
        
        //Calling methods
        controller.document = document;  
        controller.selectedType = AddImageContentController.IMAGE_TYPE_THUMB;
        
        //Calling methods of controller
        controller.uploadDocument();
        
        //Test stops here
        Test.stopTest();
        
        //Assert that Image_for_Main_Content__c field  should be populated with a document Id
        intranetItem = [SELECT Id, Ad_Hoc_Thumbnail_Image_Id__c FROM Intranet_Item__c WHERE ID =: intranetItem.Id];
        System.assert(intranetItem.Ad_Hoc_Thumbnail_Image_Id__c != null);
        
        //Fetch the newly created document in database
        List<Document> documents = [Select Id from Document where Id =: intranetItem.Ad_Hoc_Thumbnail_Image_Id__c];
        System.assertEquals(1,  documents.size());
    }
    
}