/** 
*   Description   :     Controller for the VF page DeploymentTasks, which contains form navigation controls and basic functions. 
*                       Class containing functions to communicate with the Other Deployment Tasks Helper and Wrapper Classes.
*
*   Created By    :     Rajeev Jain (Simplyforce)
*
*   Created Date  :     04/22/2017
*
*   Revision Log  :     V1.0 Created
*                       V1.1 - Modified by Saurabh Kumar - CR-20170821-11154 - 08/21/2017. Improve the functionality.
*             V1.2 - Modified by - Saurabh Kumar - 09/15/2017 - CR-20170821-11154. Cross check and package perform functionalities are update
*                     V1.3 - Modified by - Diepsh Gupta - 04/01/2019 - Added the deletion mods.
**/   
public class DeploymentTasksController {
    
    //Press 24 Times equal sign for 
    //======================== Class Properties ========================
    
    //===================== Global variables for all functionalities =====================
    //V1.1 - Modified by Saurabh Kumar - CR-20170821-11154 - 08/24/2017. Error flag to check security level
    public boolean isAccessible {get; set;}
    
    //V1.1 - Modified by Saurabh Kumar - CR-20170821-11154 - 08/21/2017. Flag to display general message on the page
    public String information {get; set;}
    public String warningMessage {get;set;}
    
    // ====================== Individual Crosscheck ==================================
    //Instance to utilize to show Release lookup for Selection for Corsscheck
    public SFDC_Change_Request__c changeRequest {get; set;}
    
    //Instance to utilize to show Is System Modificaion lookup for Selection for Crosscheck
    public CR_Action_Item__c crActionItem {get; set;}
    
    //Instance to utilize to show Change Request lookup for Selection for Crosscheck
    public IS_System_Modification__c sfdcMod {get; set;}
    
    // ===================== Individual Package ===========================================
    //Instance to utilize to show Change Request lookup for Selection for Package
    public IS_System_Modification__c sfdcModForPackage {get; set;}
    
    //Instance to utilize to show Release lookup for Selection for Corsscheck
    public SFDC_Change_Request__c changeRequestForPackage {get; set;}
    
    //Instance to Hold Release Instance for Crosscheck Criteria
    public SFDC_Release__c release {get; set;}
    
    //================= Group Crosscheck =====================================
    //Hold Comma Seprated CRs, entered by user on the page
    public String changeRequestsForCrosscheck {get; set;}
    
    //Hold Comma Seprated SFDC mods, entered by user on the page
    public String sfdcModsForCrosscheck {get; set;}
    
    //Hold Comma Seprated CRs, entered by user on the page
    public String releasesForCrosscheck {get; set;}
    
    //Instance to utilize to show Release lookup for Selection for Corsscheck for attachment
    public SFDC_Change_Request__c changeRequestForAttachment {get;set;}
    
    //Instance to utilize to show Is System Modificaion lookup for Selection for Crosscheck for attachment
    public CR_Action_Item__c crActionItemForAttachment {get;set;}
    
    //Instance to utilize to show Change Request lookup for Selection for Crosscheck for attachment
    public IS_System_Modification__c sfdcModForAttachment {get;set;}
    //================= Crosscheck Criteria ================================
    //In Progress CR Status
    public List<String> inProgressStatusesMultiSelect {get;set;}
    public List<String> inProgressStatuses{get;set;}
    
    //Ecxclude CR Names for In Progress
    public String excludeCRNamesForPackage{get;set;}
    public String excludeModNamesForPackage{get;set;}
    
    //Variable to hold sandbox name
    public String sandboxName {get; set;}
    
    //Variable to hold email address for cross check
    public String emailAddressForCrosscheck {get;set;}
    
    //Variable to hold the flag for rendering on cross check & display result
    public Boolean isCrosscheckAndDisplay {get;set;}
    //================ Group Package ===========================================
    //Hold Comma Seprated CRs, entered by user on the page
    public String changeRequestsForPackage {get; set;}
    
    //Hold Comma Seprated SFDC mods, entered by user on the page
    public String sfdcModsForPackage {get; set;}
    
    //Hold Comma Seprated CRs, entered by user on the page
    public String releasesForPackage {get; set;}
    
    //Instance to utilize to show Release lookup for Selection for attachment of package file
    public SFDC_Change_Request__c changeRequestForAttachmentOfPackage {get;set;}
    
    //Instance to utilize to show Change Request lookup for Selection for attachment of package file
    public IS_System_Modification__c sfdcModForAttachmentOfPackage {get;set;}
    
    //Instance to utilize to show Is System Modificaion lookup for Selection for attachment of package file
    public CR_Action_Item__c crActionItemForAttachmentOfPackage {get;set;}
    
    //================= Package Criteria =====================================
    public List<String> excludeCRStatusMultiSelect {get;set;}
    public List<String> excludeCRStatus{get;set;}
    
    //Exclude CR Status
    public List<String> sourceCRExcludeStatuses {get;set;} 
    public List<String> sourceCRExcludeStatusesMultiSelect {get;set;} 
    
    //Variable to hold email address for package file
    public String emailAddressForPackage {get;set;}
    
    // ================= App Global Properties =======================================
    //Prop to Hold Selected Category in Crosscheck and Radio button
    public String selectedCrosscheckCategory {get; set;}
    public String selectedPackageCategory {get; set;}
    public String packageFileResultString {get; set;}
    public Integer noOfLinesInPackage {get; set;}
    public Map<string, modWrapper> overlappingMods {get; set;}
    public List<String> overlappingMapKey {get; set;}
    
    //V1.2 - Modified by - Saurabh Kumar - 09/15/2017 - CR-20170821-11154. Variable to hold overlap summary
    public String summaryString {get; set;}
    
    //Check Selected Tab
    public String selectedTab {get;set;}
    
    //Get timezone offset
    public Double offset{
        get{
            
            TimeZone tz = UserInfo.getTimeZone();
            //Milliseconds to Day
            return tz.getOffset(DateTime.now()) / (1000 * 3600 * 24.0);
      }
    }
    
    //Constructor
    public DeploymentTasksController(){
        
        //V1.1 - Modified by Saurabh Kumar - CR-20170821-11154 - 08/24/2017. Checking for the user access and then only can procceed the functionality otherwise display a error message. Start from here
        
        //Query on the Custom Setting to check user access
        List<Deployment_Wizard_Access_Control__c> deploymentWAccessControl = [Select Id, Name From Deployment_Wizard_Access_Control__c Where Is_Deployment_Wizard_Accessible__c = true AND
                                                                                ( SetupOwnerId =: UserInfo.getProfileId() OR SetupOwnerId =: UserInfo.getUserId()) LIMIT 1];
        
        //Checking if record is not found in the Custom then return and display a message
        if(deploymentWAccessControl == null || deploymentWAccessControl.size() == 0){
            
            //Adding a error message and return
            ApexPages.Message message = new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.ONE_CLICK_INSUFFICIENT_PRIVILEGES_ERROR);
            ApexPages.addMessage(message);
            
            isAccessible = false;
            return;
        }
        
        isAccessible = true;
        //V1.1 - Modified by Saurabh Kumar - CR-20170821-11154 - 08/24/2017. Up to here
        
        changeRequest = new SFDC_Change_Request__c();
        sfdcMod = new IS_System_Modification__c();
        inProgressStatusesMultiSelect = new List<String>();
        inProgressStatuses = new List<String>();
        crActionItem = new CR_Action_Item__c();
        release = new SFDC_Release__c();
        selectedCrosscheckCategory = DeploymentConstants.ONE_CLICK_SELECTED_CATEGORY_INDIVIDUAL_CROSSCHECK;
        selectedPackageCategory = DeploymentConstants.ONE_CLICK_SELECTED_CATEGORY_INDIVIDUAL_PACKAGE;
        selectedTab = DeploymentConstants.ONE_CLICK_SELECTED_TAB_CROSSCHECKBLOCK;
        packageFileResultString = '';
        noOfLinesInPackage = 0;
        sfdcModForPackage = new IS_System_Modification__c();
        changeRequestForPackage = new SFDC_Change_Request__c();
        overlappingMods = new Map<string, modWrapper>();
        overlappingMapKey = new List<String>();
        changeRequestForAttachment = new SFDC_Change_Request__c();
        sfdcModForAttachment = new IS_System_Modification__c();
        crActionItemForAttachment = new CR_Action_Item__c();
        changeRequestForAttachmentOfPackage = new SFDC_Change_Request__c();
    sfdcModForAttachmentOfPackage = new IS_System_Modification__c();
    crActionItemForAttachmentOfPackage = new CR_Action_Item__c();
        information = '';
        warningMessage = '';
        emailAddressForCrosscheck = '';
        emailAddressForPackage = '';
        excludeCRNamesForPackage = '';
        excludeModNamesForPackage = '';
        changeRequestsForPackage = '';
    sfdcModsForPackage = '';
    summaryString = '';
    isCrosscheckAndDisplay = false;

        //Get current context record ID from URL
        String recordId = ApexPages.currentPage().getParameters().get('recordId');
        
        if(String.isNotBlank(recordId) && recordId instanceOf Id) {
            
            //Get Object type
            String sObjName = Id.valueOf(recordId).getSObjectType().getDescribe().getName();
            
            //Checking for the object type
            if(sObjName == DeploymentConstants.ONE_CLICK_SFDC_RELEASE) {
                changeRequest.SFDC_Release__c = recordId;
                changeRequestForPackage.SFDC_Release__c = recordId;
            } else if(sObjName == DeploymentConstants.ONE_CLICK_SFDC_CHANGE_REQUEST) {
                sfdcMod.SFDC_Change_Request__c = recordId;
                sfdcModForPackage.SFDC_Change_Request__c = recordId;
            } else if(sObjName == DeploymentConstants.ONE_CLICK_IS_SYSTEM_MODIFICATION) {
                crActionItem.IS_System_Modification__c = recordId;
            }
        }
    }
    
    //V1.1 - Modified by Saurabh Kumar - CR-20170821-11154 - 08/21/2017. Remove the '09-In IS QA', '10-In UAT', '11-Ready for Deployment'
    public List<SelectOption> getCRStatus() {
        List<SelectOption> Options = new List<SelectOption>();
        Options.add(new SelectOption('Cancelled','Cancelled'));
        Options.add(new SelectOption('On Hold','On Hold'));
        Options.add(new SelectOption('01-New Request','01-New Request'));
        Options.add(new SelectOption('02-Sponsored','02-Sponsored'));
        Options.add(new SelectOption('03-Approved','03-Approved'));
        Options.add(new SelectOption('04-Estimated','04-Estimated'));
        Options.add(new SelectOption('05-Prioritized','05-Prioritized'));
        Options.add(new SelectOption('06-In Development','06-In Development'));
        Options.add(new SelectOption('07-In Dev QA','07-In Dev QA'));
        Options.add(new SelectOption('08-To Test Sandbox','08-To Test Sandbox'));
        Options.add(new SelectOption('12-Deployed','12-Deployed'));
        return Options;
    }
    
    //V1.2 - Created by Saurabh Kumar - CR-20170821-11154 - 08/28/2017. To disply all CR Status on the page
    public List<SelectOption> getAllCRStatus() {
        List<SelectOption> Options = new List<SelectOption>();
        Options.add(new SelectOption('Cancelled','Cancelled'));
        Options.add(new SelectOption('On Hold','On Hold'));
        Options.add(new SelectOption('01-New Request','01-New Request'));
        Options.add(new SelectOption('02-Sponsored','02-Sponsored'));
        Options.add(new SelectOption('03-Approved','03-Approved'));
        Options.add(new SelectOption('04-Estimated','04-Estimated'));
        Options.add(new SelectOption('05-Prioritized','05-Prioritized'));
        Options.add(new SelectOption('06-In Development','06-In Development'));
        Options.add(new SelectOption('07-In Dev QA','07-In Dev QA'));
        Options.add(new SelectOption('08-To Test Sandbox','08-To Test Sandbox'));
        Options.add(new SelectOption('09-In IS QA','09-In IS QA'));
        Options.add(new SelectOption('10-In UAT','10-In UAT'));
        Options.add(new SelectOption('11-Ready for Deployment','11-Ready for Deployment'));
        Options.add(new SelectOption('12-Deployed','12-Deployed'));
        return Options;
    }
    
    //=========================== Page Methods ==================================================
    //=========================== Crosscheck Methods ========================================
    public void crosscheckAndDisplay() {
      
        performCrosscheckTasks(DeploymentConstants.ONE_CLICK_ACTION_TYPE_CROSSCHECK_AND_DISPLAY);
    }
    
    public void crosscheckAndAttach(){
        performCrosscheckTasks(DeploymentConstants.ONE_CLICK_ACTION_TYPE_CROSSCHECK_AND_ATTACH);    
    }
    
    public void crosscheckAndEmail(){
        performCrosscheckTasks(DeploymentConstants.ONE_CLICK_ACTION_TYPE_CROSSCHECK_AND_EMAIL);       
    }
    
    private void performCrosscheckTasks(String actionType) {
       
        //Reset variables
        information = '';
        warningMessage = '';
        String crStatusForCrossCheck = '';
        summaryString = '';
        isCrosscheckAndDisplay = false;
        
        //V1.1 - Modified by Saurabh Kumar - CR-20170821-11154 - 08/21/2017. Reset the collections
        overlappingMapKey = new List<String>();
        overlappingMods = new Map<string, modWrapper>();
        
        //V1.1 - Modified by Saurabh Kumar - CR-20170821-11154 - 08/30/2017. Start from here. Validating the input date. Start from here
    
        //If all input object is null than return and display a message
        if((String.isNotBlank(selectedCrosscheckCategory) && selectedCrosscheckCategory.equals(DeploymentConstants.ONE_CLICK_SELECTED_CATEGORY_INDIVIDUAL_CROSSCHECK) 
            && (changeRequest == null || String.isBlank(changeRequest.SFDC_Release__c)) 
            && (sfdcMod == null || String.isBlank(sfdcMod.SFDC_Change_Request__c)) 
            && (crActionItem == null || String.isBlank(crActionItem.IS_System_Modification__c))
        )
          ||(String.isNotBlank(selectedCrosscheckCategory) && selectedCrosscheckCategory.equals(DeploymentConstants.ONE_CLICK_SELECTED_CATEGORY_GROUP_CROSSCHECK) 
            && String.isBlank(releasesForCrosscheck) 
            && String.isBlank(changeRequestsForCrosscheck) && String.isBlank(sfdcModsForCrosscheck))
          ){
          
          warningMessage = System.Label.ONE_CLICK_SOURCE_INPUT_REQUIRED_FOR_CROSS_CHECK;
        return;
        }

        //If sandbox date is null than return and display a message
      if(release == null || release.Target_Release_Date__c == null){
        
        warningMessage = System.Label.ONE_CLICK_VALID_SANDBOX_REFRESH_DATE;
        return;
      }
      
      //Checking for sandbox name in case of cross chek & email, if blank than display a message and return the controller
      if(String.isNotBlank(actionType) && actionType.equals(DeploymentConstants.ONE_CLICK_ACTION_TYPE_CROSSCHECK_AND_EMAIL) && String.isBlank(sandboxName)){
        
        warningMessage = System.Label.ONE_CLICK_SANDBOX_NAME_REQUIRED;
        return;
      }
      
      //Checking if email aaddress is not blank and valid
      if(String.isNotBlank(actionType) && actionType.equals(DeploymentConstants.ONE_CLICK_ACTION_TYPE_CROSSCHECK_AND_EMAIL) && String.isNotBlank(emailAddressForCrosscheck) && 
                        !DeploymentConstants.validateEmail(emailAddressForCrosscheck)){
        
        warningMessage = System.Label.ONE_CLICK_VALID_EMAIL_ADDRESS_REQUIRED;
        return;
      }
      
      //Checking if whether email domain is correct
      if(String.isNotBlank(actionType) && actionType.equals(DeploymentConstants.ONE_CLICK_ACTION_TYPE_CROSSCHECK_AND_EMAIL) && String.isNotBlank(emailAddressForCrosscheck)){
        
        //Extract the domain of the email Id
        String domain = emailAddressForCrosscheck.substring(emailAddressForCrosscheck.indexOf('@'));
        
        //Flag to indicate that email or domain is found in custom meta data
        Boolean isValidEmailOrDomain = false;
        
        //Query on the custom metadata to get record with email id or email domaun
        for(Valid_Email_Domain_Manager__mdt validEmailDomainManager : [Select Id, Email_Address_Domain__c From Valid_Email_Domain_Manager__mdt Where Active__c = true AND Email_Address_Domain__c != null]){
          
          //Checking whether email Id or domain is matached then set the flag and break the loop
          if(validEmailDomainManager.Email_Address_Domain__c.equalsIgnoreCase(emailAddressForCrosscheck) || validEmailDomainManager.Email_Address_Domain__c.equalsIgnoreCase(domain))
            isValidEmailOrDomain = true;
          
        }
        
        //Checking if email or domain is not found then display a warning message and return the control
        if(!isValidEmailOrDomain){
          
          //Assigning the message and return
          warningMessage = System.Label.ONE_CLICK_INVALID_EMAIL_DOMAIN;
          return;
        }
      }
      //V1.1 - Modified by Saurabh Kumar - CR-20170821-11154 - 08/30/2017. Validating the input data Upto here
      
        ModHelper modHelper;

        //Convert Multiselect PickliSt in String
        if(inProgressStatusesMultiSelect != null)
          for(String str:inProgressStatusesMultiSelect)
              crStatusForCrossCheck += str + ',';
        
        //Variable to hold parent Id where file should attach
        Id parentId;
        
        //Variable to hold parent record name
    String parentName = '';
        
        // get SFDC_Change_Request__c instance
        if(String.isNotBlank(selectedCrosscheckCategory) && selectedCrosscheckCategory == DeploymentConstants.ONE_CLICK_SELECTED_CATEGORY_INDIVIDUAL_CROSSCHECK) {
            
            SFDC_Change_Request__c indidualCR;
            IS_System_Modification__c indidualMod;
            SFDC_Release__c indidualRelease;
            
            if(changeRequest != null && changeRequest.SFDC_Release__c != null){
                List<SFDC_Release__c> tempReleaes = [select Id, Name from SFDC_Release__c 
                                                        where Id = : changeRequest.SFDC_Release__c LIMIT 1];
                //Checking for list size
                if(tempReleaes != null && tempReleaes.size() > 0){
                  
                  indidualRelease = tempReleaes[0];
                  parentId = changeRequest.SFDC_Release__c;
                  parentName = tempReleaes[0].Name;
                }
                
            }
            
            else if(sfdcMod != null && sfdcMod.SFDC_Change_Request__c != null){
            
                List<SFDC_Change_Request__c> tempCRs = [select Id, Name 
                                                            from SFDC_Change_Request__c 
                                                            where Id = : sfdcMod.SFDC_Change_Request__c LIMIT 1];
                //Checking for list size
                if(tempCRs != null && tempCRs.size() > 0){
                  
                  indidualCR = tempCRs[0];
                  parentId = sfdcMod.SFDC_Change_Request__c;
                  parentName = tempCRs[0].Name;
                }
                
            }
            
            else if(crActionItem != null && crActionItem.IS_System_Modification__c != null){
                List<IS_System_Modification__c> tempMods = [select Id, Name from IS_System_Modification__c 
                                                                where Id = : crActionItem.IS_System_Modification__c LIMIT 1];
                //Checking for list size
                if(tempMods != null && tempMods.size() > 0){
                  
                  indidualMod = tempMods[0];
                  parentId = crActionItem.IS_System_Modification__c;
                  parentName = tempMods[0].Name;
                }
                
            }
            
            modHelper = new ModHelper(release.Target_Release_Date__c, indidualCR, indidualMod, 
                                      indidualRelease, parentId, parentName, null, null, 
                                      null, true, false, true, crStatusForCrossCheck );
            
        } else if(String.isNotBlank(selectedCrosscheckCategory) && selectedCrosscheckCategory == DeploymentConstants.ONE_CLICK_SELECTED_CATEGORY_GROUP_CROSSCHECK){
          
          //V1.1 - Modified by Saurabh Kumar - CR-20170821-11154 - 08/31/2017. Updated the code from here
          
          //Checking if Release & CR & Mod is not selected in case of attachment than display a warning message and return
          if(String.isNotBlank(actionType) && actionType.equals(DeploymentConstants.ONE_CLICK_ACTION_TYPE_CROSSCHECK_AND_ATTACH) && (changeRequestForAttachment == null || String.isBlank(changeRequestForAttachment.SFDC_Release__c)) && 
                                  (sfdcModForAttachment == null || String.isBlank(sfdcModForAttachment.SFDC_Change_Request__c)) && 
                                  (crActionItemForAttachment == null || String.isBlank(crActionItemForAttachment.IS_System_Modification__c))){
                                    
            warningMessage = System.Label.ONE_CLICK_WARNING_PLEASE_PROVIDE_PARENT_RECORD;
          return;
            
          }
          
          //Checking if Release is not null
          if(changeRequestForAttachment != null && String.isNotBlank(changeRequestForAttachment.SFDC_Release__c)){
            
            //Query on the release
            List<SFDC_Release__c> tempReleaes = [select Id, Name from SFDC_Release__c 
                                                        where Id = : changeRequestForAttachment.SFDC_Release__c LIMIT 1];
                //Checking for list size
                if(tempReleaes != null && tempReleaes.size() > 0){
                  
                  parentId = changeRequestForAttachment.SFDC_Release__c;
                  parentName = tempReleaes[0].Name;
                }
          }
          
          //Checking if Change request is not null
          else if(sfdcModForAttachment != null && String.isNotBlank(sfdcModForAttachment.SFDC_Change_Request__c)){
            
            List<SFDC_Change_Request__c> tempCRs = [select Id, Name 
                                                            from SFDC_Change_Request__c 
                                                            where Id = : sfdcModForAttachment.SFDC_Change_Request__c LIMIT 1];
                //Checking for list size
                if(tempCRs != null && tempCRs.size() > 0){
                  
                  parentId = sfdcModForAttachment.SFDC_Change_Request__c;
                  parentName = tempCRs[0].Name;
                }
          }
          //Checking if Modification is not null
          else if(crActionItemForAttachment != null && String.isNotBlank(crActionItemForAttachment.IS_System_Modification__c)){
            
            List<IS_System_Modification__c> tempMods = [select Id, Name from IS_System_Modification__c 
                                                                where Id = : crActionItemForAttachment.IS_System_Modification__c LIMIT 1];
                //Checking for list size
                if(tempMods != null && tempMods.size() > 0){
                  
                  parentId = crActionItemForAttachment.IS_System_Modification__c;
                  parentName = tempMods[0].Name;
                }
          }
          
          //V1.1 - Modified by Saurabh Kumar - CR-20170821-11154 - 08/31/2017. Upto here
            modHelper = new ModHelper(release.Target_Release_Date__c, null, null, 
                                      null, parentId, parentName, changeRequestsForCrosscheck, sfdcModsForCrosscheck, 
                                      releasesForCrosscheck, true, false, false, crStatusForCrossCheck );
        }
        
        if(String.isNotBlank(actionType) && actionType == DeploymentConstants.ONE_CLICK_ACTION_TYPE_CROSSCHECK_AND_DISPLAY) {
            
            Map<String, ModWrapper> modTempWrapper = new Map<String, ModWrapper>();
            
            //Calling method to get overlapping result
            overlappingMods = modHelper.crossCheckAndDisplay();
            
            Set<String> excludeIsSystemComponent = new Set<String>();
            excludeIsSystemComponent.add('Generic_Salesforce_Config_Object');
            excludeIsSystemComponent.add('Generic_Salesforce_Data_Update');
            excludeIsSystemComponent.add('Generic_Object');
            excludeIsSystemComponent.add('Generic_Validation_Rule');
            excludeIsSystemComponent.add('Generic_Salesforce_Code_Object');
            excludeIsSystemComponent.add('Generic_Page Layout');
            
            //V1.2 - Modified by Saurabh Kumar - 09/15/2017 - Creating a summary result.
            summaryString = '<div> <div style="margin-left:20px;"><b><u>Cross Check Completed. Overlapping found as:-</u></b></div></br>';
            
            //Creating table for summary result
            summaryString += '<table cellpading="0" cellspacing="0" border="0">';
            Integer counter = 1;
            Integer listCounter = 1;
            //Processing on the overlapping result and arranging them
            for(String str : overlappingMods.keySet()){
                if(overlappingMods.containsKey(str) 
                    && overlappingMods.get(str).overlappingMods.size() > 0 
                    && !excludeIsSystemComponent.contains(str)){
                    if(!modTempWrapper.containsKey(str)){
                      
                        if(listCounter <= 999){
                            modTempWrapper.put(str, overlappingMods.get(str));
                            overlappingMapKey.add(str); 
                        
                            summaryString += '<tr style="background:transparent;border:1px solid #ccc"><td style="word-break: normal;"><b>'+counter+'</b></td> <td>'+modTempWrapper.get(str).mainMod.Change_Request__r.Name + '('+modTempWrapper.get(str).mainMod.Name+')';
                            
                            //Looping on the all overlapp components and adding summary body
                            for(IS_System_Modification__c mod : modTempWrapper.get(str).overlappingMods){
                                
                                summaryString += ' & '+mod.Change_Request__r.Name + ' ('+ mod.Name + ') ' + '<b>- ' + mod.Change_Request__r.Release__r.Name + '</b>'; 
                                listCounter++;
                            }
                            
                            summaryString += '</td>';
                            summaryString += '</tr>';
                            //Increase the counter for next overlapping
                            counter ++;
            }
                    }    
                }
            }
            
            summaryString += '</table>';
            summaryString += '</div>';
            
            //Assigning the result in getter setter
            overlappingMods = modTempWrapper;
            
            //Checking if overlapping key is null
            if(overlappingMapKey == null || overlappingMapKey.size() == 0){
              
              //Assigning the message
            information = System.Label.ONE_CLICK_NO_OVERLAPPING_FOUND;
            return;
            }     
            //Set the flag to opne cross check tab option
            isCrosscheckAndDisplay = true;
            
            //If Item Size is Greater or Equals to 1000 Item, than display message on the screen
            if(listCounter == 1000){
                information = 'More than 1000 overlappings to display, please use Attach or Email Option';
            return;
            }
        }
            
        if(String.isNotBlank(actionType) && actionType == DeploymentConstants.ONE_CLICK_ACTION_TYPE_CROSSCHECK_AND_ATTACH)
            Attachment attach = modHelper.crossCheckAndattachFileOnRecord();
        if(String.isNotBlank(actionType) && actionType == DeploymentConstants.ONE_CLICK_ACTION_TYPE_CROSSCHECK_AND_EMAIL)
            modHelper.crossCheckAndSendEmail(sandboxName, emailAddressForCrosscheck);
        
        //Assigning the message
        information = modHelper.information;
        
        //Reset the valiable
        emailAddressForCrosscheck = '';
        
        //Reinitializatio
        changeRequestForAttachment = new SFDC_Change_Request__c();
        sfdcModForAttachment = new IS_System_Modification__c();
        crActionItemForAttachment = new CR_Action_Item__c();
        changeRequest = new SFDC_Change_Request__c();
        sfdcMod = new IS_System_Modification__c();
        crActionItem = new CR_Action_Item__c();
        
    }
    
    //=========================== Crosscheck Methods ========================================
    public void packageAndDisplay(){
        performPackageTasks(DeploymentConstants.ONE_CLICK_ACTION_TYPE_PACKAGE_AND_DISPLAY);
    }
    
    public void packageAndAttach(){
        performPackageTasks(DeploymentConstants.ONE_CLICK_ACTION_TYPE_PACKAGE_AND_ATTACH);
    }
    
    public void packageAndEmail(){
        performPackageTasks(DeploymentConstants.ONE_CLICK_ACTION_TYPE_PACKAGE_AND_EMAIL);
    }
    public void packageDeletedMods(){
        performPackageTasks('PackageDeletedMods');
    }
    
    private Set<String> prepareSetForSFDCChangeManagementRecords(String str){
        Set<String> strSet = new Set<String>();
        for(String tempStr : str.split(','))
            strSet.add(tempStr.trim());
        return strSet;
    }
    
    //Perform Package File Tasks
    private void performPackageTasks(String actionType){
        
        //Reset the flag
        information = '';
        warningMessage = '';
        
        //Reset the string
        packageFileResultString = '';
        noOfLinesInPackage = 0;
            
        Set<String> setOfReleases = new Set<String>();
        Set<String> setOfCRs = new Set<String>();
        Set<String> setOfSfdcMods = new Set<String>();
        
        //Variable to Hold Parent Id, will be needed while attaching the package file
        Id parentId;
        
        //String to hold Parent record name on which package file is attached
        String parentName = '';
        
        //V1.1 - Modified by Saurabh Kumar - CR-20170821-11154 - 08/31/2017. Validating the data. Start from here
        
        //Checking if nothing is selected and selected category is individual then display a message and return the control
        if(String.isNotBlank(selectedPackageCategory) && selectedPackageCategory.equals(DeploymentConstants.ONE_CLICK_SELECTED_CATEGORY_INDIVIDUAL_PACKAGE) && 
                                  (changeRequestForPackage == null || String.isBlank(changeRequestForPackage.SFDC_Release__c))
                              && (sfdcModForPackage == null || String.isBlank(sfdcModForPackage.SFDC_Change_Request__c))){
                                
          warningMessage = System.Label.ONE_CLICK_PACKAGE_INDIVIDUAL_INPUT_REQUIRED;
          return;
          
        }
        
        //Checking if selected category is group and input field is empty then display a messsage and return the control
        if(String.isNotBlank(selectedPackageCategory) && selectedPackageCategory.equals(DeploymentConstants.ONE_CLICK_SELECTED_CATEGORY_GROUP_PACKAGE) &&
                                 String.isBlank(releasesForPackage) && String.isBlank(changeRequestsForPackage) && String.isBlank(sfdcModsForPackage)){
                                   
          warningMessage = System.Label.ONE_CLICK_SOURCE_INPUT_REQUIRED_FOR_PACKAGE;
          return;
          
        }
        //Checking if user selected for the attachment then need to take input as well in case of group package file only
        if(String.isNotBlank(actionType) && actionType.equals(DeploymentConstants.ONE_CLICK_ACTION_TYPE_PACKAGE_AND_ATTACH) && String.isNotBlank(selectedPackageCategory) && 
                  selectedPackageCategory.equals(DeploymentConstants.ONE_CLICK_SELECTED_CATEGORY_GROUP_PACKAGE) && (changeRequestForAttachmentOfPackage == null 
                  || String.isBlank(changeRequestForAttachmentOfPackage.SFDC_Release__c)) && (sfdcModForAttachmentOfPackage == null || 
                  String.isBlank(sfdcModForAttachmentOfPackage.SFDC_Change_Request__c)) && (crActionItemForAttachmentOfPackage == null ||
                  String.isBlank(crActionItemForAttachmentOfPackage.IS_System_Modification__c))){
                    
          warningMessage = System.Label.ONE_CLICK_PARENT_RECORD_FOR_PACKAGE_ATTACHMENT;
          return;
          
        }
        //Checking if email aaddress is not blank and valid
      if(String.isNotBlank(actionType) && actionType.equals(DeploymentConstants.ONE_CLICK_ACTION_TYPE_PACKAGE_AND_EMAIL) && String.isNotBlank(emailAddressForPackage) 
                                           && !DeploymentConstants.validateEmail(emailAddressForPackage)){
        
        warningMessage = System.Label.ONE_CLICK_VALID_EMAIL_ADDRESS_REQUIRED;
        return;
      }
      
      //Checking if whether email domain is correct
      if(String.isNotBlank(actionType) && actionType.equals(DeploymentConstants.ONE_CLICK_ACTION_TYPE_PACKAGE_AND_EMAIL) && String.isNotBlank(emailAddressForPackage)){
        
        //Extract the domain of the email Id
        String domain = emailAddressForPackage.substring(emailAddressForPackage.indexOf('@'));
        
        //Flag to indicate that email or domain is found in custom meta data
        Boolean isValidEmailOrDomain = false;
        
        //Query on the custom metadata to get record with email id or email domaun
        for(Valid_Email_Domain_Manager__mdt validEmailDomainManager : [Select Id, Email_Address_Domain__c From Valid_Email_Domain_Manager__mdt Where Active__c = true AND Email_Address_Domain__c != null]){
          
          //Checking whether email Id or domain is matached then set the flag and break the loop
          if(validEmailDomainManager.Email_Address_Domain__c.equalsIgnoreCase(emailAddressForPackage) || validEmailDomainManager.Email_Address_Domain__c.equalsIgnoreCase(domain))
            isValidEmailOrDomain = true;
          
        }
        
        //Checking if email or domain is not found then display a warning message and return the control
        if(!isValidEmailOrDomain){
          
          //Assigning the message and return
          warningMessage = System.Label.ONE_CLICK_INVALID_EMAIL_DOMAIN;
          return;
        }
        
        
      }
        //V1.1 - Modified by Saurabh Kumar - CR-20170821-11154 - 08/31/2017. Upto here
        
        //Checking if package is for individual
        if(String.isNotBlank(selectedPackageCategory) && selectedPackageCategory == DeploymentConstants.ONE_CLICK_SELECTED_CATEGORY_INDIVIDUAL_PACKAGE){
            
            //If Release is selected
            if(changeRequestForPackage != null && changeRequestForPackage.SFDC_Release__c != null){
                List<SFDC_Release__c> sfdcRelease = [select Id, Name from SFDC_Release__c 
                                                        where Id = :changeRequestForPackage.SFDC_Release__c LIMIT 1];
 
                //V1.1 - Modified by Saurabh Kumar - CR-20170821-11154 - 08/21/2017. Checking if record is null then display a message only
                if(sfdcRelease == null || sfdcRelease.size() == 0){
                    
                    information = System.Label.ONE_CLICK_NO_RECORD_FOUND;
                    return;
                } 
                setOfReleases.add(sfdcRelease[0].Name);
                parentId = sfdcRelease[0].Id;
                parentName = sfdcRelease[0].Name;
            } 
            //If CR is selected
            else if(sfdcModForPackage != null && sfdcModForPackage.SFDC_Change_Request__c != null){
                List<SFDC_Change_Request__c> tempCRs = [select Id, Name from SFDC_Change_Request__c 
                                                            where Id =:sfdcModForPackage.SFDC_Change_Request__c LIMIT 1];
                                                            
                //V1.1 - Modified by Saurabh Kumar - CR-20170821-11154 - 08/21/2017. Checking if record is null then display a message only
                if(tempCRs == null || tempCRs.size() == 0){
                    
                    information = System.Label.ONE_CLICK_NO_RECORD_FOUND;
                    return;
                }
                setOfCRs.add(tempCRs[0].Name);
                parentId = tempCRs[0].Id;
                parentName = tempCRs[0].Name;
            }
            
        } 
        //Package in group
        else if(String.isNotBlank(selectedPackageCategory) && selectedPackageCategory == DeploymentConstants.ONE_CLICK_SELECTED_CATEGORY_GROUP_PACKAGE){
            
            //Checking if release is not null
            if(String.isNotBlank(releasesForPackage))
              setOfReleases.addAll(prepareSetForSFDCChangeManagementRecords(releasesForPackage));
            //Checking if CR is not null  
            if(String.isNotBlank(changeRequestsForPackage))
              setOfCRs.addAll(prepareSetForSFDCChangeManagementRecords(changeRequestsForPackage));
            //Checking if mod is not null
            if(String.isNotBlank(sfdcModsForPackage))
               setOfSfdcMods.addAll(prepareSetForSFDCChangeManagementRecords(sfdcModsForPackage));
               
            //Checking if release is not null and selected attach option
            if(String.isNotBlank(actionType) && actionType.equals(DeploymentConstants.ONE_CLICK_ACTION_TYPE_PACKAGE_AND_ATTACH) && changeRequestForAttachmentOfPackage != null 
                      && String.isNotBlank(changeRequestForAttachmentOfPackage.SFDC_Release__c)){
              
                List<SFDC_Release__c> sfdcRelease = [Select Id, Name From SFDC_Release__c Where ID =: changeRequestForAttachmentOfPackage.SFDC_Release__c LIMIT 1];
                
                //V1.1 - Modified by Saurabh Kumar - CR-20170821-11154 - 08/21/2017. Checking if record is null then display a message only
                if(sfdcRelease != null && sfdcRelease.size() > 0){
                  
                  parentId = sfdcRelease[0].Id;
                  parentName = sfdcRelease[0].Name;
                }else{
                  
                  information = System.Label.ONE_CLICK_NO_PARENT_RECORD_FOUND_FOR_ATTACHMENT;
                  return;  
                }
            } 
            //Checking if CR is not null
            else if(String.isNotBlank(actionType) && actionType.equals(DeploymentConstants.ONE_CLICK_ACTION_TYPE_PACKAGE_AND_ATTACH) && sfdcModForAttachmentOfPackage != null 
                        && String.isNotBlank(sfdcModForAttachmentOfPackage.SFDC_Change_Request__c)){
                
                List<SFDC_Change_Request__c> tempCRs = [Select Id, Name From SFDC_Change_Request__c Where ID =: sfdcModForAttachmentOfPackage.SFDC_Change_Request__c LIMIT 1];
                
                //V1.1 - Modified by Saurabh Kumar - CR-20170821-11154 - 08/21/2017. Checking if record is null then display a message only
                if(tempCRs != null || tempCRs.size() > 0){
                    
                    parentId = tempCRs[0].Id;
                  parentName = tempCRs[0].Name;
                }else{
                  
                  information = System.Label.ONE_CLICK_NO_PARENT_RECORD_FOUND_FOR_ATTACHMENT;
                  return;  
                }
                
            } 
            //Checking if mod is not null
            else if(String.isNotBlank(actionType) && actionType.equals(DeploymentConstants.ONE_CLICK_ACTION_TYPE_PACKAGE_AND_ATTACH) && crActionItemForAttachmentOfPackage != null 
                        && String.isNotBlank(crActionItemForAttachmentOfPackage.IS_System_Modification__c)){
                 
                List<IS_System_Modification__c> tempMods = [Select Id, Name From IS_System_Modification__c Where ID =: crActionItemForAttachmentOfPackage.IS_System_Modification__c LIMIT 1];
                
                //V1.1 - Modified by Saurabh Kumar - CR-20170821-11154 - 08/21/2017. Checking if record is null then display a message only
                if(tempMods != null || tempMods.size() > 0){
                    
                    parentId = tempMods[0].Id;
                  parentName = tempMods[0].Name;
                }else{
                  
                  information = System.Label.ONE_CLICK_NO_PARENT_RECORD_FOUND_FOR_ATTACHMENT;
                  return;
                }
                
            }
        }
        
        //Populate Sets for Criteria
        Set<String> ignoredCRs = new Set<String>();
        Set<String> ignoredMods = new Set<String>();
        Set<String> ignoredCrStatus = new Set<String>();
        
        if(String.isNotBlank(excludeCRNamesForPackage))
            ignoredCRs.addAll(prepareSetForSFDCChangeManagementRecords(excludeCRNamesForPackage));
        
        //V1.1 - Modified by Saurabh Kumar - CR-20170821-11154 - 08/28/2017 - Checking if Mod is mentioned to ignore then add in a saprate set  
        if(String.isNotBlank(excludeModNamesForPackage))
            ignoredMods.addAll(prepareSetForSFDCChangeManagementRecords(excludeModNamesForPackage)); 
        if(excludeCRStatusMultiSelect != null && excludeCRStatusMultiSelect.size() > 0)
            ignoredCrStatus.addAll(excludeCRStatusMultiSelect); 
        
        
        //Added By Dipesh Gupta - 04/01/2019 - Added a new functionality that check if the deletion button hit then only visible the deletion mods rather all. 
        Boolean isDeletionPackageNeeded = false;
        
        if(actionType == 'PackageDeletedMods')
          isDeletionPackageNeeded = true;
        
        //Modified by Dipesh Gupta - 04/01/2019 - new parameter on the methods. 
        PackageFileHelper packageHelper = new PackageFileHelper(setOfReleases, setOfCRs, setOfSfdcMods, ignoredCrStatus, 
                                                                    ignoredCRs, ignoredMods, isDeletionPackageNeeded);
        
        if(actionType == DeploymentConstants.ONE_CLICK_ACTION_TYPE_PACKAGE_AND_DISPLAY || actionType == 'PackageDeletedMods') {
            packageFileResultString = packageHelper.createXML(System.Label.DEPLOYMENT_PACKAGE_FILE_VERSION, sfdcModForPackage.Duplicate_Mod_on_CR__c);
            noOfLinesInPackage = packageHelper.numberOfAddedLines;
            
            //Assigning the message
            information = packageHelper.information;
            
        } else if(actionType == DeploymentConstants.ONE_CLICK_ACTION_TYPE_PACKAGE_AND_ATTACH){
            
            Attachment attach = packageHelper.createPackageAndAttach(System.Label.DEPLOYMENT_PACKAGE_FILE_VERSION, parentId, parentName, sfdcModForPackage.Duplicate_Mod_on_CR__c);
            
            //Assigning the message
            information = packageHelper.information;
        }
            
        else if(actionType == DeploymentConstants.ONE_CLICK_ACTION_TYPE_PACKAGE_AND_EMAIL){
           
            //Checking if email Id is not entered by user
            if(String.isBlank(emailAddressForPackage))
              emailAddressForPackage = UserInfo.getUserEmail();
            String emailBoyd = packageHelper.createPackageAndEmail(System.Label.DEPLOYMENT_PACKAGE_FILE_VERSION, emailAddressForPackage, sfdcModForPackage.Duplicate_Mod_on_CR__c);  
            
            //Assigning the message
            information = packageHelper.information;  
        }
        
        //Reset the valiable
        emailAddressForPackage = '';
        
        //Reset the instances
        changeRequestForAttachmentOfPackage = new SFDC_Change_Request__c();
    sfdcModForAttachmentOfPackage = new IS_System_Modification__c();
    crActionItemForAttachmentOfPackage = new CR_Action_Item__c();
        
    }
}