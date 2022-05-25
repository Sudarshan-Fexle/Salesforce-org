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
 *   Coverage       :   V1.0 - 96% 
 *                  
 **/     
@isTest(seeAllData= true)
private class Test_ManageImageSetController {
    
    //Method to check functionaliy of ManageImageSetController
    static testMethod void testManageMainImageUploadException() {
        
        //Insert intranet item for testing
        Intranet_Item__c intranetItem = new Intranet_Item__c(Name = 'Test ABC');
        
        //Gete the Document Folder
        List<Folder> boardroomResourcesFolder = [Select Id from Folder where DeveloperName =: ManageImageSetController.FOLDER_BOARDROOM_RESOURCES limit 1];
        System.assertEquals(1, boardroomResourcesFolder.size());
                
        //Feed items
        Document document = new Document(Body = blob.valueOf('TestABCD'), Name = 'Test', FolderId = boardroomResourcesFolder[0].Id);
        
        //Test starts here
        Test.startTest();
        
        //Calling standard constructor
        ApexPages.StandardController sc = new ApexPages.StandardController(intranetItem);        
        ManageImageSetController controller = new  ManageImageSetController(sc);
        
        //select option 
        List<SelectOption> selectOption = controller.types;
        
        //Generate Page error for leaving blank doumcnet
        //Calling methods
        //controller.document = document;
        controller.selectedType = ManageImageSetController.IMAGE_TYPE_MAIN;
        
        //Calling methods of controller
        controller.uploadDocument();
        
        //Now Pass Orignal Document not blank so this exception not generate
        controller.document = document;
        controller.selectedType = ManageImageSetController.IMAGE_TYPE_MAIN;
        
        //Calling methods of controller
        controller.uploadDocument();
        
        controller.goToStep1();
        controller.goToStep2(); 
        controller.goToStep3();
        
        //Test stops here
        Test.stopTest();
    }
    
    //Method to check functionaliy of ManageImageSetController
    static testMethod void testManageMainImage() {
        
        //Insert intranet item for testing
        Intranet_Item__c intranetItem = new Intranet_Item__c(Name = 'Test ABC');
        insert intranetItem;
        
        //Gete the Document Folder
        List<Folder> boardroomResourcesFolder = [Select Id from Folder where DeveloperName =: ManageImageSetController.FOLDER_BOARDROOM_RESOURCES limit 1];
        System.assertEquals(1, boardroomResourcesFolder.size());
                
        //Feed items
        Document document = new Document(Body = blob.valueOf('TestABCD'), Name = 'Test', FolderId = boardroomResourcesFolder[0].Id);
        
        //Test starts here
        Test.startTest();
        
        //Calling standard constructor
        ApexPages.StandardController sc = new ApexPages.StandardController(intranetItem);        
        ManageImageSetController controller = new  ManageImageSetController(sc);
        
        //select option 
        List<SelectOption> selectOption = controller.types;
        
        //Set properties oof controller
        controller.document = document;
        controller.selectedType = ManageImageSetController.IMAGE_TYPE_MAIN;
        
        //Calling methods of controller
        controller.uploadDocument();
        controller.goToStep1();
        controller.goToStep2(); 
        controller.goToStep3();
        
        //Test stops here
        Test.stopTest();
    	
    	//Assert that Image_for_Main_Content__c field  should be populated with a document Id
        intranetItem = [SELECT Id, Image_for_Main_Content__c FROM Intranet_Item__c WHERE ID =: intranetItem.Id];
        System.assert(intranetItem.Image_for_Main_Content__c != null);
        
        //Fetch the newly created document in database
        List<Document> documents = [Select Id from Document where Id =: intranetItem.Image_for_Main_Content__c];
        System.assertEquals(1,  documents.size());
    }
    
    //Method to check functionaliy of ManageImageSetController
    static testMethod void testManageThumbImage() {
        
        //Insert intranet item for testing
        Intranet_Item__c intranetItem = new Intranet_Item__c(Name = 'Test ABC');
        insert intranetItem;
        
        //Gete the Document Folder
        List<Folder> boardroomResourcesFolder = [Select Id from Folder where DeveloperName =: ManageImageSetController.FOLDER_BOARDROOM_RESOURCES limit 1];
        System.assertEquals(1, boardroomResourcesFolder.size());
                
        //Feed items
        Document document = new Document(Body = blob.valueOf('TestABCD'), Name = 'Test', FolderId = boardroomResourcesFolder[0].Id);
        
        //Test starts here
        Test.startTest();
        
        //Calling standard constructor
        ApexPages.StandardController sc = new ApexPages.StandardController(intranetItem);        
        ManageImageSetController controller = new  ManageImageSetController(sc);
        
        //select option 
        List<SelectOption> selectOption = controller.types;
        
        //Set properties oof controller
        selectOption = controller.types; 
        
        //Set properties oof controller after initilization
        controller.document = document;
        controller.selectedType = ManageImageSetController.IMAGE_TYPE_THUMB;
       
        //Calling method
        controller.uploadDocument();
        
        //Test stops here
        Test.stopTest();
        
        //Assert that Image_for_Main_Content__c field  should be populated with a document Id
        intranetItem = [SELECT Id, Image_for_Thumbnail__c FROM Intranet_Item__c WHERE ID =: intranetItem.Id];
        System.assert(intranetItem.Image_for_Thumbnail__c != null);
        
        //Fetch the newly created document in database
        List<Document> documents = [Select Id from Document where Id =: intranetItem.Image_for_Thumbnail__c];
        System.assertEquals(1,  documents.size());
    }
}