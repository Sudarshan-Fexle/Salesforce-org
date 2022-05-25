/**
 *  Purpose         :   This class is to Manage the Image 
 * 
 *  Created By      :
 * 
 *  Created Date    :   
 * 
 *  Revision Logs   :   V_1.0 - Created     
 * 
 **/ 
public with sharing class AddImageContentController {
    
    //Properties
    public Intranet_Item__c intranetItem {get; set;}
    public Document document {get; set;}
    public String selectedContentType {get; set;}
    public String selectedType {get; set;}
    
    //Constants
    public static final String IMAGE_TYPE_IMAGE_SET = 'Image Set';
    public static final String IMAGE_TYPE_ADHOC = 'Ad-Hoc';
    public static final String IMAGE_TYPE_MAIN = 'Main';
    public static final String IMAGE_TYPE_THUMB = 'Thumbnail';
    public static final String FOLDER_BOARDROOM_RESOURCES = 'Boardroom_Resources';
    
    //Navigation
    public Boolean step1 {get; set;}
    public Boolean step2 {get; set;}
    public Boolean step3 {get; set;}
    public Boolean step4 {get; set;}
    
    //Content Types
    public List<SelectOption> contentTypes {
        get {
            
            //Initialize Select Option
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('', '--None--'));
            options.add(new SelectOption(AddImageContentController.IMAGE_TYPE_ADHOC, AddImageContentController.IMAGE_TYPE_ADHOC));
            options.add(new SelectOption(AddImageContentController.IMAGE_TYPE_IMAGE_SET, AddImageContentController.IMAGE_TYPE_IMAGE_SET));
            return options;
        }
    }
    
    //Types
    public List<SelectOption> types {
        get {
            
            //Initialize Select Option
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('', '--None--'));
            options.add(new SelectOption(AddImageContentController.IMAGE_TYPE_MAIN, AddImageContentController.IMAGE_TYPE_MAIN));
            options.add(new SelectOption(AddImageContentController.IMAGE_TYPE_THUMB, AddImageContentController.IMAGE_TYPE_THUMB));
            return options;
        }
    }
    
    //Constructor
    public AddImageContentController(ApexPages.StandardController controller) {
        
        //ImageSet Item
        intranetItem = (Intranet_Item__c)controller.getRecord();
        document = new Document();
        
        //step 1
        goToStep1();
    }
    
    /**
     *  @description    :   This method is to upload the feed attachment
     *
     *  @args           :
     *
     *  @return         :   
     *
     **/
    public void uploadDocument() {
        
        //Create a savepoint to rollback teh transaction in case of exception
        Savepoint sp = Database.setSavepoint();
            
        try {
        
            //process attachment record
            if(document.Body != null && document.Name != null) {
                
                //Gete the Document Folder
                List<Folder> boardroomResourcesFolder = [Select Id from Folder where DeveloperName =: ManageImageSetController.FOLDER_BOARDROOM_RESOURCES limit 1];
                
                //Check if folder exists, if tnot, then dispaly a friendly message to user
                if(boardroomResourcesFolder.size() == 0) {
                	
                	//Mesage
                	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Folder not found to upload the document.'));
                	return;
                }
                
                //Set folder Id
                document.FolderId = boardroomResourcesFolder[0].Id;
                insert document;
                
                //Update the Intranet item record
                if(selectedType == ManageImageSetController.IMAGE_TYPE_MAIN) {
                    
                    //Main Image
                    intranetItem.Ad_Hoc_Main_Image_Id__c = document.Id;
                    update intranetItem;
                } else if(selectedType == ManageImageSetController.IMAGE_TYPE_THUMB) {
                    
                    //Main Image
                    intranetItem.Ad_Hoc_Thumbnail_Image_Id__c = document.Id;
                    update intranetItem;
                }
                
                //Reinitialize to remove the view state issue
                document = new Document();
                
                //step 3
                goToStep4();
            } else {
                
                //Add Error message on Page
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select an image to upload.'));
            }
        } catch(Exception e) {
            
            //Rollback the complete transaction
            database.rollback(sp);
            
            //Add error on page
            ApexPages.addMessages(e);
        }
    }
    
    //Save
    public void save() {
       
       //Create a savepoint to rollback teh transaction in case of exception
        Savepoint sp = Database.setSavepoint();
            
        try {
            
            //Update record
            update intranetItem;
            
            //step 4
            goToStep4();
        } catch(Exception e) {
            
            //Rollback the complete transaction
            database.rollback(sp);
            
            //Add error on page
            ApexPages.addMessages(e);
        } 
        
    }
    
    //Go to step 1
    public void goToStep1() {
        
        //Set variables
        step1 = true;
        step2 = false;
        step3 = false;
        step4 = false;  
    }
    
    //Go to step 2
    public void goToStep2() {
        
        //Set variables
        step1 = false;
        step2 = true;
        step3 = false;
        step4 = false;  
    }
    
    //Go to step 3
    public void goToStep3() {
        
        //Set variables
        step1 = false;
        step2 = false;
        step3 = true;
        step4 = false;      
    }
    
    //Go to step 4
    public void goToStep4() {
        
        //Set variables
        step1 = false;
        step2 = false;
        step3 = false;
        step4 = true;
    }
}