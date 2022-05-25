/**
    Purpose:    This controller is to override case new and edit functionaliry.(CR-20111219-287)
                
    Create By:  Simplyforce Technology
    
    Created Date:   12/23/2011
    
    Current Version:    v2
    
    Revision Log:       V_1.0 - VH - 02/13/2014 - Modified for the Crimson Community project (CR-4283)
                        V_1.2 - Ajit Surana - 07/31/2014 - CR-20140709-6144 - Modified redirectToEdit() method
                        V_1.3 - Modified By - Ajit Surana - CR-20141103-7949 - 12/4/2014 - Modified to comment and De-comment out of Member_Facing_Resolution_Summary__c reference
                        V_1.4 - Modified By - Mahendra Swarnkar - CR-20150309-8737 - 08/04/2015
                        V_1.5 - Modified By - Abhinav Sharma - 03/31/2016 - CR-20160224-9632
                        V_1.6 - Modified By - Abhinav Sharma - 03/31/2016 - CR-20160224-9630
                        V_1.7 - Modified By - Abhinav Sharma - 09/05/2016 - CR-20160114-9520
                        V_1.8 - Modiofied By - Rajeev Jain - 10/19/2016 - Services Excellence - Manually merged code from Services Ex Sb to Test SB.
                        V_1.9 - Modified By - Mahendra Swarnkar - 10/08/2016 - CR-20160209-9593 - Updated to Setting the Case field values in the URL parameters to populate some case fields for Etech support and web help case RecordType 
                        V_2.0 - Modified By - Mahendra Swarnkar - 08/17/2017 - CR-20170407-10831 - Updated "projectOptions" to update the Query where clause condition to also fetch those Project Roles,
                                                                                                   where a user/contact is tagged to a CPRM, CQR, Crimson Connect(CCA), Population Health Analytics(CCA, CPRM, CQR), SPC i.e. Surgical Profitability Compass (CostOps) projects  
			V_2.1 - Modified by Mahendra Swarnkar - 03/16/2020 - CR-20200318-13867
			V_2.2 - Modified By - Mahendra Swarnkar - 03/16/2020 - CR-20200217-13756  
 *            
 **/
public without sharing class CaseController {
    
    //class varibles
    public Case caseObj { get; set; }
    public String deadLine{ get; set; }
    public String retURL { get; set; }
    public string internalComments { get; set; }
    public Boolean isSynergyProfile {get; set;}
    
    //User Object API Name
    public final static string USER_OBJECT = 'User';
    
    //Added By - Mahendra Swarnkar - 10/08/2016 - CR-20160209-9593 - Starts from here
    public final static String RECORD_TYPE_CASE_WEB_HELP = 'WebHelp';
    public final static String RECORD_TYPE_CASE_ETECH_SUPPORT = 'eTech Support';
    //Added By - Mahendra Swarnkar - 10/08/2016 - CR-20160209-9593 - Ends here  

    
    //create an original copy of the case and member support record for field change comparison purposes
    public Case caseObj_Clone {
      get {
        if (caseObj_Clone == null) caseObj_Clone = caseObj.clone();
        return caseObj_Clone;
      }
      set;
    }
    public Site_Issue__c memberSupport_Clone {
      get {
        if (memberSupport_Clone == null) memberSupport_Clone = memberSupport.clone();
        return memberSupport_Clone;
      }
      set;
    }
    
    //Retreive picklist options for the browser used field
    public list<selectOption> browserUsedOptions {
      get {
        if (browserUsedOptions == null) {
          browserUsedOptions = new list<selectOption>();
          for (Schema.PicklistEntry picklistEntry : Site_Issue__c.Browser_Used__c.getDescribe().getPicklistValues()) {
            browserUsedOptions.add(new selectOption(picklistEntry.getValue(), picklistEntry.getLabel()));
          }
        }
        return browserUsedOptions;
      }
      set;
    }
    
    //Return all attachments associated with the case
    public list<Attachment> attachments {
        get {
            if (attachments == null) {
                attachments = [SELECT Id, BodyLength, ContentType, Description, IsPrivate, Name, OwnerId, ParentId, LastModifiedDate, CreatedById 
                               FROM Attachment WHERE parentId = :caseObj.Id ORDER BY CreatedDate DESC];
            }
            return attachments;
        }
        set;
    }
    
    //Return all comments associated with the case
    public list<CaseComment> caseComments {
        get {
            if (caseComments == null) {
                caseComments = [SELECT IsPublished, CommentBody, CreatedBy.Name, CreatedDate 
                                FROM CaseComment 
                                WHERE parentId = :caseObj.Id 
                                AND IsPublished = true
                                ORDER BY CreatedDate DESC];
            }
            return caseComments;
        }
        set;
    }
    
    /**
     *  @description    :   Constructor
     **/
    public CaseController() {
        inIt();
    }
    
    public void inIt() {
        
        Id caseId = ApexPages.currentPage().getParameters().get('id');
        
        //Modified By - Abhinav Sharma - 09/05/2016 - CR-20160114-9520 - "First_Comment_Date_Time__c" got included in the query
        if(caseId != null) {
            caseObj = [SELECT Id, AccountId, CaseNumber, ContactId, Status, Project_Source_MS__c, Case_Type__c, Subject, Priority, Description,
                       Tier_MS__c, 
                       //Spring Clean Up - Browser_MS__c, 
                       Support_Category_MS__c, Browser_Version_MS__c, Steps_to_Reproduce_MS__c, Current_Results__c,
                       Expected_Results__c, CreatedDate, Origin, ClosedDate, OwnerId, RecordTypeId, Member_Support_Ticket__c, IsClosed,
                       RecordType.DeveloperName, Case_Status__c, Deadline__c, Project_Source_MS__r.Name, Member_Facing_Resolution_Summary__c,
                       Contact.Name, RecordType.Name, Tier_I_Support_Analyst__c, Tier_II_Support_Analyst_Contact__c, 
                       First_Comment_Date_Time__c
                       FROM Case WHERE Id = :caseId]; 
        }
        
        isSynergyProfile = false;
        
        //Logged in user profile name
        Id profileId=userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        
        if(profileName == 'Gold Partner – Synergy')
            isSynergyProfile = true;
    }
    
    /**
     *  @description    :   Standard Set Controller
     **/
    public CaseController(ApexPages.StandardSetController controller) { }
    
    /**
     *  @description    :   Standard Controller Constructor
     **/
    public CaseController(ApexPages.StandardController controller) {
        
        //instantiate case record
        caseObj = (Case)controller.getRecord();

        isSynergyProfile = false;
        
        //Logged in user profile name
        Id profileId=userinfo.getProfileId();
        
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        
        //Setting falg value to true for synergy profile
        if(profileName == 'Gold Partner – Synergy')
            isSynergyProfile = true;
    
        //Set some defaults if this is a new Case
        if (isNewCase) {
            
            //Get the current user's contactId
            if (isPortalUser) {
                Id contactId = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId()].ContactId;
                caseObj.ContactId = contactId;
                caseObj.Origin = 'Community';
                caseObj.Priority = 'Low';
                caseObj.Status = Constants.CASE_STATUS_01_NEW;
            }
            
            //Get the project source and default if present
           // Community_Project_Source__c projSource = Community_Project_Source__c.getInstance(UserInfo.getUserId());
            //if (projSource != null) caseObj.Project_Source_MS__c = projSource.Project_Source_Id__c;
            
            //Set the assignment rule to true
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.assignmentRuleId = '01QC00000009P9N';
            caseObj.setOptions(dmo);
        }
        
        //Set the recordTypeId
        if (recordTypeId != null) caseObj.RecordTypeId = recordTypeId;
        
        //Get the retURL from the URL
        retURL = ApexPages.currentPage().getParameters().get('retURL');
        
        //get the dead line date from URL
        if(ApexPages.currentPage().getParameters().get('deadLine') != null 
        && ApexPages.currentPage().getParameters().get('deadLine') != '') 
        {
            deadLine = ApexPages.currentPage().getParameters().get('deadLine');
            caseObj.Deadline__c = Date.valueOf(deadLine);
        }
        
        //get the ownerId from URL
        if(ApexPages.currentPage().getParameters().get('ownerId') != null 
        && ApexPages.currentPage().getParameters().get('ownerId') != '' 
        && ApexPages.currentPage().getParameters().get('ownerId') != 'null') 
        {
            caseObj.OwnerId = ApexPages.currentPage().getParameters().get('ownerId');
        }
    }
    
     /**
     *  @description    :   Executed when a user clicks the Transfer to Tier 2 button on the Case
     *
     *  @args           :
     *
     *  @return         :   PageReference
     *
     **/
    public pageReference transferTier2() {
      
        //Set a savepoint in case the memSupport upserts but caseObj errors
        SavePoint sp = Database.setSavePoint();
      
        try {
        
            if (caseObj.Tier_MS__c != Constants.SITE_ISSUE_TIER_I)
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Constants.ERROR_CANNOT_TRANFER_TIER_II));
            
            //Set the member support owner to the Tier II Support Queue
            memberSupport.OwnerId = Constants.tier2SupportQueue.Id;
            memberSupport.Tier__c = Constants.SITE_ISSUE_TIER_II;
            
            //set the case owner to Tier II
            caseObj.OwnerId = Constants.tier2SupportQueue.Id;
          
            //Added By - Abhinav Sharma - 03/31/2016 - CR-20160224-9632
            //Setting "Button Used" flag to true to bypass the status and owner change validation code logic
            //Spring Clean Up - caseObj.Button_Used__c = true;
            memberSupport.Button_Used__c = true;
            
            //Updating records
            CaseTriggerHelper.syncRecordTypeIds = null;
            update memberSupport;
            CaseTriggerHelper.syncRecordTypeIds = null;
            update caseObj;
            
        } catch(DMLException ex) {
            
            //Return errors to the VF Page
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getDMLMessage(0)));
        
        } catch(Exception ex) {
          
            //Return errors to the VF Page
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
        
        }
        
        //if there are errors, revert back to the original save point
        if (apexPages.getMessages().size() > 0) {
        
            //Rollback the transaction
            database.rollback(sp);
            return null;
        }
        
        //return to the standard case detail page
        return new ApexPages.StandardController(caseObj).view();
    }
    
    /**
     *  @description    :   Executed when a user clicks the Accept Case button on the Case
     *
     *  @args           :
     *
     *  @return         :   PageReference
     *
    **/
    public pageReference acceptCase() {
      
        //Set a savepoint in case the memSupport upserts but caseObj errors
        SavePoint spac = Database.setSavePoint();
      
        try {
            
            //checks to make sure that Tier is = Tier I and the Case is not Closed
            if (acceptButtonError) return null;
        
            //Set the member support owner to Tier I Support Queue
            memberSupport.OwnerId = Constants.tier1SupportQueue.Id;
            
            //set the case owner to Tier I Support Queue
            caseObj.OwnerId = Constants.tier1SupportQueue.Id;
                
            //Set the Case Tier 1 Support Analyst to Current User
            caseObj.Tier_I_Support_Analyst__c = UserInfo.getUserId();
            
            //Rajeev - 10/19/2016 - Manaually merged code from Services Ex SB to Test Sb as a part of Services Ex migration to Test Sandbox
            //Set Case Status to "10-In Progress"
            //caseObj.Status = Constants.CASE_STATUS_10_IN_PROGRESS;
            
            //Set Case Status to "03-In Progress"
            caseObj.Status = Constants.CASE_STATUS_02_ACKNOWLEDGED;
            memberSupport.Status__c = Constants.MEMBER_SUPPORT_STATUS_ACKNOWLEDGE;
            //Rajeev - 10/19/2016 - Manaually merged code from Services Ex SB to Test Sb as a part of Services Ex migration to Test Sandbox - upto here
            
            //Checking member support instance "Date/Time Acknowledged" field for null value
            if(memberSupport.Date_Time_Acknowledged__c == null)
                memberSupport.Date_Time_Acknowledged__c = System.now();
          
            //Added By - Abhinav Sharma - 03/31/2016 - CR-20160224-9632
            //Setting "Button Used" flag to true to bypass the status and owner change validation code logic
            //Spring Clean Up - caseObj.Button_Used__c = true;
            memberSupport.Button_Used__c = true;
        
            //Updating records
            CaseTriggerHelper.syncRecordTypeIds = null;
            update memberSupport;
            CaseTriggerHelper.syncRecordTypeIds = null;
            update caseObj;
            
        } catch(DMLException ex) {
            
            //Return errors to the VF Page
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getDMLMessage(0)));
        
        } catch(Exception ex) {
          
            //Return errors to the VF Page
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
        
        }
        
        //if there are errors, revert back to the original save point
        if (apexPages.getMessages().size() > 0) {
          
            //Rollback the transaction
            database.rollback(spac);
            return null;
        }
        
        //return to the standard case detail page
        return new ApexPages.StandardController(caseObj).view();
    }
    
    /**
     *  @description    :   Executed when a user saves a Case
     *
     *  @args           :
     *
     *  @return         :   PageReference
     *
     **/
    public pageReference save() {
        
        //String to hold any error message(s)
        string errorMsg;
        string originalCasePriority = caseObj.Priority;
        
        //Set a savepoint in case the memSupport upserts but caseObj errors
        SavePoint sp = Database.setSavePoint();
        
        //Try to upsert the member support record first
        try {
            
            //Check for errors - if there are, return null immediately
            if (hasErrors) return null;
            
            //format the browser multipicklist - for some reason, the edit VF page makes it save in an unsupported format
            memberSupport.Browser_Used__c = formatPicklistValue(memberSupport.Browser_Used__c);
            
            //Populate member support field values to the case record
            memberSupport = (Site_Issue__c) CaseTriggerHelper.populateSourceFieldsToTarget((sObject) caseObj_Clone, (sObject) caseObj, (sObject) memberSupport);
            
            caseObj = (Case) CaseTriggerHelper.populateSourceFieldsToTarget((sObject) memberSupport_Clone, (sObject) memberSupport, (sObject) caseObj);
            caseObj.Priority = originalCasePriority; //make sure the chosen priority isn't overwritten by the case Sync
            
            //If this is a portal user, set Visible In Portal to true by default
            if (isNewCase && isPortalUser) {
              memberSupport.Visible_in_Portal__c = true;
              caseObj.OwnerId = Constants.tier1UnassignedQueue.Id;
            }
            
            Util.BypassAllTriggers = true;
            // this populates some fields from project to member support
            MemberSupportTriggerUtilities.UpdateSiteIssueByProject(new list<Site_Issue__c> { memberSupport }, false);
            CaseTriggerHelper.syncRecordTypeIds = null;
            upsert memberSupport;
            Util.BypassAllTriggers = false;
            
            //Try to upsert the Case
            caseObj.Member_Support_Ticket__c = memberSupport.Id;
            CaseTriggerHelper.syncRecordTypeIds = null;
            upsert caseObj;
            
            //If the internalComments field is populated, create a private comment and attach to the case
            if (internalComments != null && internalComments != '') {
              CaseComment comment = new CaseComment(ParentId = caseObj.Id, CommentBody = internalComments, IsPublished = false);
              insert comment;
            }
        }
        catch(DMLException ex) {
            //Return DML errors to the VF Page
            errorMsg = ex.getDMLMessage(0);
        }
        catch(Exception ex) {
            //Return any errors to the VF Page
            errorMsg = ex.getMessage();
        }
        
        if (errorMsg != null) {
          
            //Rollback the transaction
            database.rollback(sp);
            
            //Return errors to the VF Page
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMsg));
            return null;
        }
        
        PageReference pg = redirectToView();
        
        //custom redirect if it is a portal user, so the created message is displayed
        if (isNewCase && isPortalUser) {
          pg = redirectToView();
          pg.getParameters().put('id', caseObj.Id);
          pg.getParameters().put('showCreatedMsg', 'true');
        }
        
        //Save was successful, return the user to the detail page of the updated case
        return pg;
    }
    
    /**
     *  @description    :   Returns a user to the returnURL when they click the Cancel button from the Case VF page
     *
     *  @args           :
     *
     *  @return         :   PageReference
     *
     **/
    public pageReference cancel() {
        
        pageReference pg;
        
        if (retURL != null) {
          pg = new PageReference(retURL);
        }
        else {
          pg = redirectToView();
        }
        
        return pg;
    }
    
    /**
     *  @description    :   Redirects the user to the appropriate Case edit page depending on if they are internal or portal user
     *
     *  @args           :
     *
     *  @return         :   PageReference
     *
     **/
    public PageReference redirectToEdit() {
        
        //Create a new Pagereference instance
        PageReference pageRef;
        
        //Commented by Mahendra Swarnkar - 03/05/2020 - CR-20200217-13756: RT deleted: PT DataLoad, CASE_PT_SUPPORT - Start Here
        //Check, wheather the redirect page is defined for user is defined for the same record type
        /*if (caseObj.RecordTypeId == Constants.RECORD_TYPE_ID_CASE_PT_SUPPORT
         || caseObj.RecordTypeId == Constants.RECORD_TYPE_ID_CASE_PT_DATA_LOAD) {
          if (caseObj.RecordTypeId == Constants.RECORD_TYPE_ID_CASE_PT_DATA_LOAD){
            pageRef = Page.Case_Edit_DataLoad;
          }
          else {
            pageRef = Page.Case_Edit_SupportRequest;
          }
            pageRef.getParameters().put('id', caseObj.Id);
            pageRef.setRedirect(true);
        }//Changes starts from here - Made by Ajit Surana
        //else redirect user on standard page
        else */
	 if (isNewCase) {
            pageRef = new PageReference('/500/e');
            pageRef.getParameters().put('RecordType', ApexPages.currentPage().getParameters().get('RecordType'));
            pageRef.getParameters().put('def_account_id', ApexPages.currentPage().getParameters().get('def_account_id'));
            pageRef.getParameters().put('def_contact_id', ApexPages.currentPage().getParameters().get('def_contact_id')); 
            pageRef.getParameters().put('nooverride', '1');
        
            //Added By Mahendra Swarnkar - 10/08/2016 - CR-20160209-9593 - Setting the URL Parameters for populating the case fields for E-tech and Web help record types - Starts From Here.
            if(String.isNotBlank(ApexPages.currentPage().getParameters().get('RecordType'))
                && 
               (
                   ApexPages.currentPage().getParameters().get('RecordType') == Util.RecordTypeId('Case', RECORD_TYPE_CASE_WEB_HELP)
                   || ApexPages.currentPage().getParameters().get('RecordType') == Util.RecordTypeId('Case', RECORD_TYPE_CASE_ETECH_SUPPORT)
               )
            ){
                pageRef.getParameters().put('cas28', ApexPages.currentPage().getParameters().get('ParentCaseNumber'));
                pageRef.getParameters().put('cas28_lkid', ApexPages.currentPage().getParameters().get('ParentCaseId'));
                pageRef.getParameters().put('cas11', ApexPages.currentPage().getParameters().get('Origin'));     
            }
            //Added By Mahendra Swarnkar - 10/08/2016 - CR-20160209-9593 - Setting the URL Parameters for populating the case fields for E-tech and Web help record types - Ends here.
            
        }//Changes are upto here - Made by Ajit Surana
        else {
            pageRef = new ApexPages.StandardController(caseObj).edit();
            pageRef.getParameters().put('nooverride', '1');
        }
        
        //Add recordTypeId and RetURL to the URL Parameters
        if (recordTypeId != null) pageRef.getParameters().put('RecordType', recordTypeId);
        pageRef.getParameters().put('retURL', retURL);
        
        return pageRef;
    }
    
    /**
     *  @description    :   Redicts the user to the appropriate case detail page.
     *            Based on record type, ownerId, and whether or not they are a portal user
     *
     *  @args           :
     *
     *  @return         :   PageReference
     *
     **/
    public PageReference redirectToView() {
        
        //Create a new Pagereference instance
        PageReference pageRef;
        
        //If this is a community user and the record type is pt support, redirect to
        //custom VF page so they can view the details of the record
        /*if (isPortalUser
        && (caseObj.RecordTypeId == Constants.RECORD_TYPE_ID_CASE_PT_SUPPORT 
        || CaseObj.RecordTypeId == Constants.RECORD_TYPE_ID_CASE_PT_DATA_LOAD)
        ) 
        {
        
        if (caseObj.RecordTypeId == Constants.RECORD_TYPE_ID_CASE_PT_DATA_LOAD )
        pageRef = Page.Case_View_DataLoad_Community;
        else
        pageRef = Page.Case_View_SupportRequest_Community;
        
        pageRef.getParameters().put('id', caseObj.Id);
        pageRef.setRedirect(true);
        }//else redirect user on standard page*/
                /*pageRef = new ApexPages.StandardController(caseObj).view();
        pageRef.getParameters().put('nooverride', '1');*/
        pageRef = Page.Case_NoOverride;
        pageRef.getParameters().put('id', caseObj.Id);
        pageRef.setRedirect(true);
        
        return pageRef;
    }
    
    //Determine if the current user is accessing the page from the portal
    public boolean isPortalUser {
        get {
            if (isPortalUser == null) {
                isPortalUser = (userInfo.getUserType().equalsIgnoreCase('CspLitePortal') 
                                || userInfo.getUserType().equalsIgnoreCase('Partner')
                                || userInfo.getUserType().equalsIgnoreCase('PowerPartner'));
            }
            return isPortalUser;
        }
        set;
    }
    
    //Determines whether or not the site issue is Tier II
    public boolean isTierII {
      get {
        if (isTierII == null) {
          isTierII = (memberSupport.Tier__c == Constants.SITE_ISSUE_TIER_II);
        }
        return isTierII;
      }
      set;
    }
    
    /**
     *  @description    :   Returns the Member Support record related to the case
     *
     *  @args           :
     *
     *  @return         :   Site_Issue__c (Member Support)
     *
     **/
    public Site_Issue__c memberSupport {
        get {
            if (memberSupport == null) {
                
                //Modified By - Abhinav Sharma - 09/05/2016 - CR-20160114-9520 - "First_Comment_Date_Time__c" got included in the query
                if (caseObj.Member_Support_Ticket__c != null) {
                    memberSupport = [SELECT Id, Browser__c, Steps_to_Reproduce__c, Browser_Version__c, Current_Results__c, Visible_In_Portal__c,
                                    Expected_Results__c, Data_Load_Type__c, Data_Load_Period_End__c, Tier_I_Support_Analyst__c, Project__c,
                                    Crimson_Site_Issue_Description__c, Site_Issue_Priority__c, Status__c, Reported_By__c, Tier__c,
                                    Interaction_Type__c, Case_Number__c, Support_Category__c, Support_Category_Details__c, Browser_Used__c,
                                    Date_Time_Acknowledged__c, Button_Used__c, First_Comment_Date_Time__c
                                    FROM Site_Issue__c WHERE Id = :caseObj.Member_Support_Ticket__c];
                }
                else {
                    //Commented by Mahendra Swarnkar - 03/16/2020 - CR-20200217-13756 - RT deleted : CASE_PT_SUPPORT From CASE.
                    memberSupport = new Site_Issue__c(/*RecordTypeId = MemberSupportTriggerUtilities.getMemSupportRTID(caseObj.RecordTypeId),*/
                                      Tier__c = Constants.SITE_ISSUE_TIER_I,
                                      Created_from_Case__c = true);
                    
                    //if the case is logged by a portal user, set the Member Support owner to tier1SupportQueue
                    if (isPortalUser) {
                      memberSupport.OwnerId = Constants.tier1SupportQueue.Id;
                    }
                }
            }
            return memberSupport;
        }
        set;
    }
    
    //SelectList of Projects the user has access to
    public list<SelectOption> projectOptions {
        get {
            if (projectOptions == null) {
                projectOptions = new list<SelectOption>();
                if (caseObj.ContactId != null) {
                    /*
                     * v10 - Modified By - Mahendra Swarnkar - 08/17/2017 - CR-20170407-10831 - Updated the Where clause in the Query to also fetch those Project Roles,
                     * where a user/contact is tagged to a CPRM, CQR, Crimson Connect(CCA), Population Health Analytics(CCA, CPRM, CQR), SPC i.e. Surgical Profitability Compass (CostOps) projects
                    */  
                    list<Project_Role__c> projectRoles = [SELECT Project__r.Id, Project__r.Name 
                                                          FROM Project_Role__c 
                                                          WHERE Contact__c = :caseObj.ContactId
                                                          AND Contact__c != null 
                                                          AND 
                                                          (
                                                              (
                                                                  SIAM_Portal_Status__c = : Constants.SIAM_PORTAL_STATUS_ACTIVE
                                                                   /* ------ Strat ---- Commented by Mahendra Swarnkar - 03/16/2020 - CR-20200318-13867 - 'EHBI','CQR','CCA' From Project.
                                                                  AND 
                                                                  Project__r.RecordType.DeveloperName IN ('EHBI','CQR','CCA')
                                                                  -------------End - CR-20200318-13867 -----------*/
                                                              )
                                                              /* ------ Strat ---- Commented by Mahendra Swarnkar - 03/16/2020 - CR-20200318-13867 - 'CostOps' From Project.
                                                              OR
                                                              Project__r.RecordType.DeveloperName = : 'CostOps'
                                                               -------------End - CR-20200318-13867 -----------*/
                                                          )];
                                                          
                    for (Project_Role__c projRole : projectRoles) {
                        projectOptions.add(new SelectOption(projRole.Project__r.Id, projRole.Project__r.Name));
                    }
                }
            }
            return projectOptions;
        }
        set;
    }
    
     //list of available support categories for community users
    //V8 - Modified By - Rajeev Jain - 10/22/2016 - Services Excellecne - Reset Picklist values
    //VH 10/10/2016 -  updated picklist values - CR-9863
    public list<SelectOption> communitySupportCategoryOptions {
    get {
      if (communitySupportCategoryOptions == null) {
        communitySupportCategoryOptions = new list<SelectOption>();
        communitySupportCategoryOptions.add(new SelectOption('', '--None--'));
        communitySupportCategoryOptions.add(new SelectOption('Data Administration', 'Data Administration'));
        communitySupportCategoryOptions.add(new SelectOption('Defect', 'Defect'));
        communitySupportCategoryOptions.add(new SelectOption('Enhancement', 'Enhancement'));
        communitySupportCategoryOptions.add(new SelectOption('Integration', 'Integration'));
        communitySupportCategoryOptions.add(new SelectOption('Question/How To', 'Question/How To'));
        communitySupportCategoryOptions.add(new SelectOption('Reporting', 'Reporting'));
        communitySupportCategoryOptions.add(new SelectOption('User Management', 'User Management'));
        communitySupportCategoryOptions.add(new SelectOption('Practice/Provider Management', 'Practice/Provider Management'));
        communitySupportCategoryOptions.add(new SelectOption('Processing/Routing', 'Processing/Routing'));
        communitySupportCategoryOptions.add(new SelectOption('Site Performance', 'Site Performance'));
        /*communitySupportCategoryOptions.add(new SelectOption('Internal Administration', 'Internal Administration'));
        communitySupportCategoryOptions.add(new SelectOption('Site configuration', 'Site configuration'));*/
      }
      return communitySupportCategoryOptions;
    }
    set;
  }
  //V8 - Modified By - Rajeev Jain - 10/22/2016 - Services Excellecne - Reset Picklist values - upto here
    
    //Returns the Case record type Id
    private string recordTypeId {
        get {
            if (RecordTypeId == null) {
                
                string urlRecordTypeId = ApexPages.currentPage().getParameters().get('RecordType');
                if (urlRecordTypeId != null && urlRecordTypeId instanceof Id) {
                    
                    RecordTypeId = urlRecordTypeId;
                }
                else if (isNewCase && RecordTypeId == null) {
                    
                    //find all Case record types
                    List<Schema.RecordTypeInfo> infos = Schema.SObjectType.Case.RecordTypeInfos;
                    
                    //check each one to determine what this user's default record type id is
                    for (Schema.RecordTypeInfo rti : infos) {
                        if (rti.isDefaultRecordTypeMapping()) {
                            RecordTypeId = rti.getRecordTypeId();
                            break;
                        }
                    }
                }
            }
            
            return RecordTypeId;
        }
        set;
    }
    
    //Determine if this is a new case or if the case is being modified
    public boolean isNewCase {
        get {
            //If the case id is null, it's new
            if (isNewCase == null) isNewCase = (caseObj.Id == null);
            return isNewCase;
        }
        set;
    }
    
    //Returns true if fields have missing data
    public boolean hasErrors {
        
        get {
            
            //Set errors to false initially
            hasErrors = false;
            
            //check for errors on the case
            if (caseObj.Subject == null) 
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Subject: You must enter a value'));
            if (caseObj.ContactId == null) 
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Contact: You must enter a value'));
            
            //Commented by Mahendra Swarnkar - 03/16/2020 - CR-20200217-13756 - RT deleted : CASE_PT_SUPPORT From Case.
            /*if (memberSupport.Support_Category__c == null && (caseObj.RecordTypeId == Constants.RECORD_TYPE_ID_CASE_PT_SUPPORT))
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Support Category: You must enter a value'));*/
            
            /*if (memberSupport.Support_Category__c == 'Service Request / Task') {
                
                //Ensure the required fields have values
                if (caseObj.Current_Results__c == null)
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Current Results: You must enter a value'));
                if (caseObj.Expected_Results__c == null)
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Expected Results: You must enter a value'));
           
                                
            }*/
            
            //VH updated as part of Services Excellence (CR-9863)
            if (memberSupport.Support_Category_Details__c == 'Environment') {
                //Ensure the required fields have values
                if (caseObj.Steps_to_Reproduce_MS__c == null || caseObj.Steps_to_Reproduce_MS__c == '')
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Steps to Reproduce: You must enter a value'));
                if (caseObj.Current_Results__c == null || caseObj.Current_Results__c == '')
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Current Results: You must enter a value'));
                if (caseObj.Expected_Results__c == null || caseObj.Expected_Results__c == '')
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Expected Results: You must enter a value'));
                
            }
            
            //If the number of messags on the page is greater than 0, there is an error
            if (apexPages.getMessages().size() > 0)
                hasErrors = true;
            
            return hasErrors;
        }
        set;
    }
    
    public boolean acceptButtonError {
        
        get{ 
            
            acceptButtonError = False;
            
        if (caseObj.Tier_MS__c != 'Tier I' && caseObj.Member_Support_Ticket__c != null && caseObj.Member_Support_Ticket__r.OwnerId == Constants.tier2SupportQueue.Id)
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The Tier is not Tier I - Please change before using the Accept button'));
             
            //V8 - Modified By - Rajeev Jain - 10/19/2016 - Services Excellence - Manually merged code from ServicesEx to Test Sb. 
            //Modified By - Abhinav Sharma - 09/05/2016 - CR-20160114-9520 - Included additional check for null/blank
            //if (String.isNotBlank(caseObj.Status) && caseObj.Status == Constants.CASE_STATUS_90_CLOSED)
            if (String.isNotBlank(caseObj.Status) && caseObj.Status == Constants.CASE_STATUS_10_CLOSED)
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The Case is closed - Please review before using the Accept button'));
            //V8 - Modified By - Rajeev Jain - 10/19/2016 - Services Excellence - Manually merged code from ServicesEx to Test Sb.  - upto here
            
            if (apexPages.getMessages().size() > 0)
                acceptButtonError = true;
            
            return acceptButtonError;
        }
        set;
    }
    
    //set projectOptions to null - this will force a refresh of the available options
    public void refreshProjOptions() {
        projectOptions = null;
    }
    
    //The Browser Used multipicklist on the custom Case_Edit_PTCommunity page returns in an improper format (ie: [a, b, c])
    //this corrects the format and makes it align with what Salesforce expects.
    private string formatPicklistValue(string picklistValue) {
      if (picklistValue != null) {
        picklistValue = picklistValue.replace('[', '');
        picklistValue = picklistValue.replace(']', '');
        picklistValue = picklistValue.replace(',', ';');
      }
      return picklistValue;
    }
    
    //ContactId related to the case
    public Id contactId {
      get {
        if (contactId == null) {
          //Get the current user's contact
            contactId = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId()].ContactId;
        }
        return contactId;
      }
      set;
    }
    
    //Get the closed case status list for cases and remove any picklist values from the VF page that are displayed on edit of a non-closed case
    public list<string> closedCaseStatusList {
      get {
        if (closedCaseStatusList == null) {
          closedCaseStatusList = new list<string>();
          for (CaseStatus status : [SELECT Id, IsClosed, MasterLabel FROM CaseStatus WHERE IsClosed = true]) {
            closedCaseStatusList.add(status.MasterLabel);
          }
        }
        return closedCaseStatusList;
      }
      set;
    }
    
    //Added By - Abhinav Sharma - 03/31/2016 - CR-20160224-9630
    //Start from here
    public boolean isUnAssignedQueueAsOwner {
        get {
            if (isUnAssignedQueueAsOwner == null) {
                  isUnAssignedQueueAsOwner = (caseObj.OwnerId == Constants.tier1UnassignedQueue.Id);
            }
            return isUnAssignedQueueAsOwner;
          }
          set;
    }
    //upto here
    
    //Modified By - Abhinav Sharma - 03/31/2016 - CR-20160224-9630
    public boolean showEdit {
        get {
            if(!isTierII
            && isUnAssignedQueueAsOwner   
            && contactId == caseObj.ContactId
            //Commented by Mahendra Swarnkar - 03/16/2020 - CR-20200217-13756 - RT deleted : CASE_PT_SUPPORT From Case.
            /*&& caseObj.RecordTypeId == Constants.RECORD_TYPE_ID_CASE_PT_SUPPORT*/) {
                return true;
            }
            return false;
        }
        set;
    }
    
    //Added By - Abhinav Sharma - 09/05/2016 - CR-20160114-9520
    /**
     *  @description    :   This method will return the user details, corresponding to the user ID value passed to it.
     *
     *  @args           :  Id currentLoggedInUserId
     *
     *  @return         :   User
     *
    **/
    public static User retrieveLoggedInUserDetails(Id currentLoggedInUserId) {
        
      //Checking for the null value
        if(currentLoggedInUserId != null && String.valueOf(currentLoggedInUserId.getSObjectType()) == CaseController.USER_OBJECT) {
            
           //List of users
           List<User> users = [SELECT ID, FirstName, LastName FROM User WHERE ID =: currentLoggedInUserId];
            
            //Checking for null and size value
            if(users != null && users.size() > 0)
                return users[0];
            else
                return null;
        } else
            return null;
    }
}