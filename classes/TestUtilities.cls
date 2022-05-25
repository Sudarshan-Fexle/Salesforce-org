/*
    Purpose         :   Utility class with methods to assist with unit test data creation.
                
    Create By       :   Victor Hanson
    
    Created Date    :   3/21/2012
    
    Revision Log    :   V1.0 Created
    			V1.1 - Victor Hanson - 10/15/2015 -CR-20140407-4977 - optimized a recordType calls
			V1.2 - Abhinav Sharma - 05/30/2016 - CR-20150202-8624 - Added a new method - CreateNewCaseComment
			V1.3 - Abhinav Sharma - 06/02/2016 - CR-20150202-8625 - Added new variables
			V1.4 - Abhinav Sharma - 06/03/2016 - CR-20150202-8626 - Added new variables
			V1.5 - Abhinav Sharma - 06/07/2016 - CR-20150202-8629 - Added new variables
			V1.6 - Abhinav Sharma - 06/15/2016 - CR-20150202-8628 - Added new sync field mapping
			V1.7 - Mahedra Swarnkar - 07/25/2016 - CR-20160229-9651 - Added a new variable "DEADLINE_REASON_NOT_POPULATED_ERROR"
			V1.8 - Colin McGloin - 02/01/2017 - CR-20161201-10511 - Added a new method for setting up FinancialForce data for test classes
			V1.9 - Saurabh Kumar - 06/26/2017 - Q2C Redesign - Beta Release - Added method to insert Subscription record
			V2.0 - Subhash Garhwal - 07/04/2017 - Q2C Redesign - Beta Release - Added method to insert Subscription Period "createNewSubscriptionPeriod"
			V2.1 - Saurabh Kumar - 07/05/2017 - Q2C Redesign - Beta Release - Added methods "createNewSbqqQuote, createNewAttachment"
			V2.2 - Saurabh Kumar - 07/12/2017 - Q2C Redesign - Beta Release - Added methods "createNewQuoteLine", "createNewProduct", "createNewContentVersion", "createNewStandardContract"
			V2.3 - Dipesh Gupta - 03/14/2017 - Q2c enhancement/bugs Release - NullPointerException ,FIELD_CUSTOM_VALIDATION_EXCEPTION line no 37 
			V2.4 - Rajeev Jain - Merged - CR-20180803-12480
			V2.5 - Victor Hanson - 07/31/2019 - CR-20190611-13177 - Added "createSiteProfile" and updated CreateNewContact() method to set the email domain to eab.com
			V2.6 - Victor Hanson - CR-20181019-12685 - Added PriceBook2Id to CreateNewOpportunity method.
			V2.7 - Updated by - Saurabh Kumar - 09/23/2020 - CR-20200819-14449 - Removed the reference of Date_Begins__c & Date_Ends__c
			V2.8 - Updated by - Saurabh Kumar - 11/09/2020 - CR-20201105-14664 - Replaced EAB Event's Type with EAB Event's Event Type
                        V2.9 - Updated By - Neha Sharma - 05/20/2021 - CR-20190620-13192 - Integrating subscription data from Marketo to Salesforce - old object removal
*/
public with sharing class TestUtilities {
    // get the record type id for a given record type name
    public static Id FindRecordTypeId(String ObjectType, String recordTypeName) {
        Id recordTypeId;
        List<RecordType> recordTypes = [SELECT Name, Id, SobjectType FROM RecordType WHERE IsActive = true AND SobjectType = :ObjectType AND Name = :recordTypeName LIMIT 1];
        if (recordTypes.size() > 0)
            recordTypeId = recordTypes[0].Id;
        return recordTypeId;
    }
    
    public static Opportunity CreateNewOpportunity(boolean CreateAndInsert) {
        return CreateNewOpportunity(null, CreateAndInsert);
    }
    
    public static SFDC_Change_Request__c CreateChangeRequest(boolean CreateAndInsert) {

        //V1.12 - Dipesh Gupta - 03/14/2017 - Q2c enhancement/bugs Release - NullPointerException 
        List<RecordType> recordTypes =[SELECT Name, Id, SobjectType FROM RecordType WHERE IsActive = true AND SobjectType = 'SFDC_Change_Request__c' LIMIT 1];
        //Id sysOutageRTId = Schema.SObjectType.SFDC_Change_Request__c.getRecordTypeInfosByName().get('Level II').getRecordTypeId();

        return CreateChangeRequest(recordTypes[0].Id, CreateAndInsert);

    }
    
    public static Contact CreateAdvUserContact(boolean CreateAndInsert) {
        // setup an account and contact
        Account acct = TestUtilities.CreateNewAccount(true);
        Eligible_Domain__c domain = new Eligible_Domain__c(Is_Included__c = true, Qualified_Domain__c = 'advisory.com', Account__c = acct.Id);
        insert domain;
        Contact con = CreateAdvUserContact(acct, CreateAndInsert);
        
        return con;
    }
    
    public static Contact CreateAdvUserContact(Account acct, boolean CreateAndInsert) {
        // create the eligible domain
        Eligible_Domain__c domain = new Eligible_Domain__c(Is_Included__c = true, Qualified_Domain__c = 'advisory.com', Account__c = acct.Id);
        insert domain;
        // setup an account and contact
        Contact con = TestUtilities.CreateNewContact(acct, false);
        //con.Advisory_com_User_Status__c = 'Active';
        
        con.Email = 'hansonv@advisory.com';
        //Commented to delete the field Advisory_com_Username__c on the contact -by mahendra swarnakar - CR-20140811-6954 - 09/04/2015 
        //con.Advisory_com_Username__c = 'hansonv@advisory.com';
        //con.Advisory_com_Email_Address__c = 'hansonv@advisory.com';
        con.Create_Advisory_com_User_Account__c = true;
        con.Primary_Country__c = 'USA';
        
        if (CreateAndInsert) insert con;
        
        return con;
    }
    
    
    public static SFDC_Change_Request__c CreateChangeRequest(Id recordTypeId, boolean CreateAndInsert) {
        
        // create ISS system
        
        IS_System__c ISS = new IS_System__c();
        ISS.Name = 'Servers' + crypto.getRandomInteger();
        insert ISS;
        
        // create a new Change Req
        
        Id sysOutageRTId = recordTypeId;
        SFDC_Change_Request__c CR = new SFDC_Change_Request__c();
        CR.RecordTypeId = sysOutageRTId;
        CR.Status__c = 'Open';
        CR.Functionality__c = 'All';
        CR.IS_System__c = ISS.Id;
        CR.Title__c = 'Maintenance';
        
        if (CreateAndInsert)
            insert CR;
        
        return CR;
    }
    
    public static SFDC_Request_Comment__c CreateRequestComment(boolean CreateAndInsert) {
        User u = CreateNewUser(true);
        SFDC_Change_Request__c changeRequest = CreateChangeRequest(true);
        SFDC_Request_Comment__c comment = CreateRequestComment(u.Id, changeRequest.Id, CreateAndInsert);
        return comment;
    }
    
    public static SFDC_Request_Comment__c CreateRequestComment(Id changeRequestID, Id userId, boolean CreateAndInsert) {
        SFDC_Request_Comment__c comment = new SFDC_Request_Comment__c();
        comment.User__c = userId;
        comment.Activity_Type__c = 'Analysis/Design';
        comment.Activity_Date__c = system.today();
        comment.Time__c = 2.5;
        comment.SFDC_Change_Request__c = changeRequestID;
        
        if (CreateAndInsert)
            insert comment;
            
        return comment;
    }
    
    /**
     * @description : creates a new Opportunity
     * 
     * @revisions   : V1.1 - Modified - 07/25/2019 - Victor Hanson - added Pricebook2Id
     * 		      V1.2 - Modified - 04/20/2021 - Neha Sharma - CR-20201110-14683
     **/
    public static Opportunity CreateNewOpportunity(Id accountId, boolean CreateAndInsert) {
        if (accountId == null)
            accountId = TestUtilities.CreateNewAccount(true).Id;
            
        Account acc = new Account(Id = accountId);
        Id contactId = TestUtilities.CreateNewContact(acc, true).Id;
        Opportunity opp = new Opportunity();
        Id PTMarketingRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('PT Marketing').getRecordTypeId();
        // make the opportunity a PTMarketing Opportunity record type
        if (PTMarketingRT != null) opp.RecordTypeId = PTMarketingRT;
        opp.Name = 'test' + crypto.getRandomInteger();
        opp.AccountId = accountId;
        opp.StageName = 'Pending- Renewal Call Not Yet Occured';
        opp.Amount = 100;
        opp.CloseDate = system.today().addDays(32);
        //VH added 07/25/2019
        opp.Pricebook2Id = Test.getStandardPricebookId();
        opp.Main_Contact__c = contactId;
        opp.Sales_Pursuit_Products__c = 'APS';
        if (CreateAndInsert)
            insert opp;
            
        return opp;
    }
    
    // create a basic event
    public static Event CreateNewEvent(boolean CreateAndInsert) {
        Event evt = new Event();
        evt.OwnerId = UserInfo.getUserId();
        evt.StartDateTime = system.now();
        evt.DurationInMinutes = 60;
        evt.Subject = 'Test';
        evt.Event_Type__c = 'Phone Appointment';
        evt.Event_Purpose__c = 'Prewire';
        if (CreateAndInsert)
            insert evt;
        
        return evt;
    }
    
    public static User CreatenewUser(boolean CreateAndInsert) {
        return CreateNewUser(null, CreateAndInsert);
    }
    
	// Modified By - Rajeev Jain - 20/Oct/2020 - CR-20201020-14615 - Add Where class in the profile query
    public static User CreateNewUser(Profile aProfile, boolean CreateAndInsert) {
        // if profile is null, grab an existing one
        if (aProfile == null)
            aProfile = [SELECT Id FROM Profile Where Name ='System Administrator' LIMIT 1];
        
        User newUser = new User();
        newUser.Alias = 'tUser';
        newUser.Email = 'tUser@noreply.com';
        newUser.EmailEncodingKey = 'UTF-8';
        newUser.LastName = 'User';
        newUser.ProfileId = aProfile.Id;
        newUser.Username = 'tUser@noreply'+crypto.getRandomLong()+'.com';
        newUser.TimeZoneSidKey = 'America/New_York';
        newUser.LanguageLocaleKey = 'en_US';
        newUser.LocaleSidKey = 'en_US';
        if (CreateAndInsert)
            insert newUser;
        
        return newUser;
    }
    
    // create a new account record
    public static Account CreateNewAccount(boolean CreateAndInsert) {
        // get the us corporate record type id
        return CreateNewAccount('US Corporate', CreateAndInsert);
    }
    
    public static Membership__c CreateNewMembership(Id accountId, Id programId, boolean CreateAndInsert) {
        Membership__c retMembership = new Membership__c();
        retMembership.Name = 'test' + crypto.getRandomInteger();
        retMembership.Account_Name__c = accountId;
        retMembership.Program__c = programId;
        
        if (CreateAndInsert) {
            Util.IsTest(true);
            insert retMembership;
            Util.IsTest(false); 
        }
        
        return retMembership;
    }
    
    // overloaded method to create a new account record -- this method allows the user to specify a record type
    public static Account CreateNewAccount(String RecordTypeLabel, boolean CreateAndInsert) {
        Account retAccount = new Account();
        retAccount.Name = 'TestHospital-' + crypto.getRandomInteger();
        retAccount.Account_Formal_Name__c = retAccount.Name;
        retAccount.Primary_City__c = 'Columbus';
        retAccount.Primary_State_Province__c = 'OH';
        retAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(RecordTypeLabel).getRecordTypeId();
        // if the recordtypemap is null for some reason, manually attempt to get the recordtypeId
        /*if (retAccount.RecordTypeId == null)
            retAccount.RecordTypeId = FindRecordTypeId('Account', RecordTypeLabel);*/
        
        retAccount.Academy_Programs_Available_for_Outreach__c = '';
        retAccount.BI_Programs_Available_for_Outreach__c = '';
        retAccount.Core_Programs_Available_for_Outreach__c = '';
        retAccount.Advisory_com_Organization_id__c = 14231;
        retAccount.Advisory_com_Organization_Status__c = 'Active';
        retAccount.Status__c = Constants.ACTIVE;
        
        if (CreateAndInsert)
            insert retAccount;
        
        return retAccount;
    }
    
    public static Contact CreateNewContact(boolean CreateAndInsert) {
        return CreateNewContact(null, CreateAndInsert);
    }
    
    public static Contact CreateNewContact(Account acct, boolean CreateAndInsert) {
        Id ExternalRecordType = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('External').getRecordTypeId();
        if (ExternalRecordType == null) {
            // reset record type settings
            Util.resetRecordtypeSettings();
            ExternalRecordType = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('External').getRecordTypeId();
        }
        
        Contact retContact = new Contact();
        retContact.FirstName = 'Joe';
        retContact.LastName = 'Thomas-' + Crypto.getRandomInteger();
        retContact.RecordTypeId = ExternalRecordType;
        if (retContact.RecordTypeId == null)
            FindRecordTypeId('Contact', 'External');
        if (acct == null)
            acct = CreateNewAccount(true);
        retContact.AccountId = acct.id;
        retContact.Is_Ignore_Phrase_Characters__c = true;
        retContact.Primary_Address_Line_1__c = '123 main st';
        retContact.Primary_City__c = 'Columbus';
        retContact.Primary_State_Province__c = 'OH';
        retContact.Primary_Postal_Code__c = '43235';
        retContact.Title = 'CEO';
        retContact.Email = 'testuser2' + crypto.getRandomInteger() + '@eab.com';
        retContact.Phone = '614-555-8855';
        
        
        if (CreateAndInsert)
            insert retContact;
        
        return retContact;
    }
    
    public static Program__c CreateNewProgram(boolean CreateAndInsert) {
        return CreateNewProgram('RI Marketer', 'HCAB', 'No', 'PT', CreateAndInsert);
    }
    
    public static Program__c CreateNewRIProgram(boolean CreateAndInsert) {
        return CreateNewProgram('RI Marketer', 'HCAB', 'No', 'RI', CreateAndInsert);
    }
    
    public static Program__c CreateNewProgram(String NewBusMarketer, String ProgAcronym, String CreateMemberships, String BusinessLine, boolean CreateAndInsert) {
        Program__c retProgram = new Program__c();
        retProgram.Name = 'TestProgram-' + crypto.getRandomInteger();
        retProgram.New_Business_Marketer__c = NewBusMarketer;
        retProgram.Program_Acronym__c= ProgAcronym;
        retProgram.Create_memberships__c= CreateMemberships;
        retProgram.Business_line__c = BusinessLine;
        
        if (CreateAndInsert)
            insert retProgram;
        
        return retProgram;
    }   
    //Commented By - Neha Sharma - 05/20/2021 - CR-20190620-13192 - Integrating subscription data from Marketo to Salesforce - old object removal
    /*public static Subscription_Option__c CreateNewSubscriptionOption(boolean CreateAndInsert) {
        return CreateNewSubscriptionOption('Test Subscription Option',CreateAndInsert);
    }
    
    public static Subscription_Option__c CreateNewSubscriptionOption(string sName, boolean CreateAndInsert) {
        Subscription_Option__c retSubscrOption = new Subscription_Option__c();
        retSubscrOption.Name = 'Test Subscription Option - Test';
        retSubscrOption.Description__c = 'This is a test';
        retSubscrOption.Subscription_Category__c = 'Testing';
        
        if(CreateAndInsert)
            insert retSubscrOption;
        
        return retSubscrOption;
    }
    
    public static Eligible_Subscription_Option__c CreateNewEligibleSubscriptionOption(boolean CreateAndInsert) {
        Program__c p = CreateNewProgram(true);
        Subscription_Option__c so = CreateNewSubscriptionOption(true);
        return CreateNewEligibleSubscriptionOption(p, so, CreateAndInsert);
    }
    
    public static Eligible_Subscription_Option__c CreateNewEligibleSubscriptionOption(Program__c p, boolean CreateAndInsert) {
        Subscription_Option__c so = CreateNewSubscriptionOption(true);
        return CreateNewEligibleSubscriptionOption(p, so, CreateAndInsert);
    }
    
    public static Eligible_Subscription_Option__c CreateNewEligibleSubscriptionOption(Subscription_Option__c so, boolean CreateAndInsert) {
        Program__c p = CreateNewProgram(true);
        return CreateNewEligibleSubscriptionOption(p, so, CreateAndInsert);
    }
    
    public static Eligible_Subscription_Option__c CreateNewEligibleSubscriptionOption(Program__c p, Subscription_Option__c so, boolean CreateAndInsert) {
        Eligible_Subscription_Option__c retESO = new Eligible_Subscription_Option__c();
        retESO.Program__c = p.Id;
        retESO.Related_Subscription__c = so.Id;
        
        if(CreateAndInsert)
            insert retESO;
        
        return retESO;
    }*/
    
    public static Contract__c CreateNewContract(boolean CreateAndInsert) {
        Account acct = CreateNewAccount(true);
        Contact con = CreateNewContact(acct, true);
        Program__c program = CreateNewProgram(true);
        return CreateNewContract(acct.Id, con.Id, program.Id, CreateAndInsert);
    }
    
    public static Contract__c CreateNewContract(Id payerAccountId, Id mainContactId, Id programId, boolean CreateAndInsert) {
        Contract__c retContract = new Contract__c();
        retContract.Payer_Account__c = payerAccountId;
        retContract.Main_Contact__c = mainContactId;
        retContract.Invoice_Contact__c = mainContactId;
        retContract.Program__c = programId;
        retContract.Year__c = String.valueof(system.today().year());
        retContract.Start__c = system.today().addDays(-1);
        retContract.End__c = system.today().addDays(2);
        retContract.Type__c = 'NBB';
        retContract.Negotiated_Amount__c = 1;
        
        if (CreateAndInsert)
            insert retContract;
            
        return retContract;
    }
    
    //Reset flags for Oppotunity Trigger
    public static void resetOpportunityTriggerFlags() {
        
        //Reset all flags
        Util.BypassAllTriggers = false;
        Util.IsTrigger_NBBOppFields = false;
        Util.IsTrigger_EventPrewire  = false;
        Util.IsTrigger_EventUpdateFields = false;
        Util.IsBatch = false;
        Util.IsTrigger_Task_PopulateNoOfRevisitField = false;
    }
    
    public static Id vendorRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Vendor').getRecordTypeId();
    
    public static Account CreateVendorAccount(boolean CreateAndInsert) {
        
        // create the vendor with the correct record type and status
        Account acct = new Account(RecordTypeId = vendorRecordTypeId, Name = 'new vendor',
                                   Status__c = 'Approved - All Services');
        
        // insert if requested
        if (CreateAndInsert) insert acct;
        
        // return vendor account
        return acct;
    }
    
    
    //Commented as object is deleted - Rajeev jain 
     // create a new Credit Card
  /*  public static Credit_Card__c CreateNewCreditCard(boolean CreateAndInsert) {
        // create a contact
        Contact c = TestUtilities.CreateNewContact(true);
        //Portfolio__c paymentAccount = new Portfolio__c(Card_Owner__c = UserInfo.getUserId(), Portfolio_Owner__c = c.Id);
        Portfolio__c paymentAccount = new Portfolio__c(Card_Holder__c = c.Id);
        insert paymentAccount;
        
        // return the credit card record
        return CreateNewCreditCard(userInfo.getUserId(), paymentAccount.Id, CreateAndInsert);
    }
    
    // create a new Credit Card
    public static Credit_Card__c CreateNewCreditCard(Id userId, Id pymtAcctId, boolean CreateAndInsert) {
        // update the custom setting to include the default CC profile id
        Credit_Card_Settings__c ccSettings = CreditCardConstants.CONFIG_DEFAULT;
        ccSettings.Name = CreditCardConstants.CC_DEFAULT_SETTINGS_NAME;
        ccSettings.Status__c = 'Active';
        upsert ccSettings;
        
        // insert credit card record
        Credit_Card__c creditCard = new Credit_Card__c(Payment_Account__c = pymtAcctId
                                                       );
        if (CreateAndInsert) insert creditCard;
        return creditCard;
    } */
    
    //Create the Credit Card Settings record
 /*   public static Credit_Card_Settings__c CreateCreditCardSettings(){
        User u = createNewUser(true);
        Credit_Card_Settings__c configCCDefaultSetting = new Credit_Card_Settings__c(Name = 'CC Default Settings', 
                                                                                     Account_Code__c = 'CR412', 
                                                                                     CC_Default_Limit_Warning_Level__c = 10,
                                                                                     CC_Month_Cycle_Reset_Date__c = 1,
                                                                                     Company_Name__c = 'The Advisory Board Company', 
                                                                                     Customer_Id__c = 'CUST2', 
                                                                                     Decline_Alert_To_Finance__c = true, 
                                                                                     Endpoint__c = 'https://w6cert.iconnectdata.com/fcws/services/FleetCreditWS',
                                                                                     Last_Transaction_Pull__c = DateTime.now(), 
                                                                                     Mask_Card_Num_On_Create__c = 'N', 
                                                                                     Mask_Card_Num_On_Inquiry_Update__c = 'Y',
                                                                                     Password__c = 'TABTEST1', 
                                                                                     Username__c = 'ADVISORYWS',
                                                                                     Portfolio_Record_Owner__c = u.Id,
                                                                                     Transaction_History_Days__c = 45, 
                                                                                     Statement_Email_Template__c = '', 
                                                                                     Card_Profile_Flag__c = 'Y', 
                                                                                     Default_Card_Profile_Value__c = '008', 
                                                                                     Default_Vendor_Card_Status__c = 'Blocked',
                                                                                     Status__c = 'Active',
                                                                                     xmlns_main__c = 'http://fleetCredit02.comdata.com/maintenance/',
                                                                                     xmlns_soapenv__c = 'http://schemas.xmlsoap.org/soap/envelope/',
                                                                                     xmlns_wsse__c = 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd',
                                                                                     xmlns_wsu__c = 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd');  
                                                                                     
                                                                
        return configCCDefaultSetting;
    } */
      //Commented as object is deleted - Rajeev jain 
    // return an event
    public static Event createEvent(boolean createAndInsert, DateTime dtStart, Id whatId) {
        
        if (dtStart == null)
          dtStart = system.now();
        
        Event evt = new Event(
                whatId = whatId,
                StartDateTime = dtStart,
                ActivityDateTime = dtStart,
                ActivityDate = dtStart.date(),
                EndDateTime = dtStart.addDays(1),
                Event_Type__c = 'Prewire',
                Event_Purpose__c = 'Prewire');
        
        if (createAndInsert) insert evt;
        
        return evt;
    }
    
    // return a task
    public static Task createTask(boolean createAndInsert, Id whatId) {
        
        Task tsk = new Task(Subject = 'test',
                            ActivityDate = system.today(),
                            Event_Type__c = 'revisit',
                            WhatId = whatId);
        
        if (createAndInsert) insert tsk;
        
        return tsk;
    }
    
    // create a new project
    public static Project__c createProject(boolean createAndInsert) {
      
        Project__c project = new Project__c(Name = 'Test-Data');
        
        if (createAndInsert) 

        //V1.12 - Dipesh Gupta - 03/14/2017 - Q2c enhancement/bugs Release - FIELD_CUSTOM_VALIDATION_EXCEPTION 
        try {
            insert project;
        }catch(Exception e){
            
        }
        return project;
    }
    
    // create a new member support record
    public static Site_Issue__c createSiteIssue(Id projectId, boolean createAndInsert) {
      
      Site_Issue__c sIssue = new Site_Issue__c(Site_Issue_Priority__c = 'High', 
                           Site_Issue_Short_Description__c = 'Test-Description',
                                                 Category__c = 'Test-Category', 
                                                 Data_Load_Type__c = Constants.HISTORICAL_RELOAD,
                                                 Crimson_Site_Issue_Description__c = 'Test Issue Description', 
                                                 RecordTypeId = Constants.RECORD_TYPE_ID_SITE_ISSUE_CCA_DATA_LOAD, 
                                                 Project__c = projectId, 
                                                 CCC_Date_Observed__c = System.Today(), 
                                                 Site_Issue_Created_Date__c = System.now().addDays(-54), 
                                                 Site_Issue_Close_Date__c = System.now().addDays(8), 
                                                 Data_Load_Period_End__c = Date.Today().addDays(-62),
                                                 Data_Load_Period_Begin__c = Date.today(), 
                                                 Files_Received__c = Date.today());
      
      if (createAndInsert) insert sIssue;
        
        return sIssue;
    }
    
    @TestVisible private static Sync_Field__c createSyncField(string name, string srcRTDevName, string srcObjAPIName, string srcFieldAPIName,
                           string targetObjAPIName, string targetFieldAPIName) 
    {
      
      return new Sync_Field__c(name = name,
                        Source_Record_Type_Developer_Name__c = srcRTDevName,
                        Source_Object_API_Name__c = srcObjAPIName,
                        Source_Field_API_Name__c = srcFieldAPIName,
                        Target_Object_API_Name__c = targetObjAPIName,
                        Target_Field_API_Name__c = targetFieldAPIName);
    }
    
    //Create test data for the Sync Fields custom setting
    public static void createSyncFields() {
      
      list<Sync_Field__c> syncFieldList = new list<Sync_Field__c>();
      
      //Sync Member Support fields to Case
      syncFieldList.add(createSyncField('MS.BrowserUsd->Case.BrowserUsd_DL', Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CCA_DATA_LOAD, 
                                         'Site_Issue__c', 'Browser_Used__c', 'Case', 'Browser_Used__c'));
    syncFieldList.add(createSyncField('MS.DLPBegin->Case.Desc_DL', Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CCA_DATA_LOAD, 
                                             'Site_Issue__c', 'Data_Load_Period_Begin__c', 'Case', 'Description'));
    syncFieldList.add(createSyncField('MS.DLPEnd->Case.Desc_DL', Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CCA_DATA_LOAD, 
                                             'Site_Issue__c', 'Data_Load_Period_End__c', 'Case', 'Description'));
    syncFieldList.add(createSyncField('MS.CurrentRes->Case.CurrentRes_DL', Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CCA_DATA_LOAD, 
                                             'Site_Issue__c', 'Current_Results__c', 'Case', 'Current_Results__c'));
    syncFieldList.add(createSyncField('MS.DiagNotes_DL->Case.DiagNotes', Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CCA_DATA_LOAD, 
                                             'Site_Issue__c', 'Diagnostics_Notes_Comments__c', 'Case', 'Diagnostics_Notes__c'));
    syncFieldList.add(createSyncField('MS.ExpectedRes->Case.ExpectedRes_DL', Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CCA_DATA_LOAD, 
                                             'Site_Issue__c', 'Expected_Results__c', 'Case', 'Expected_Results__c'));
    syncFieldList.add(createSyncField('MS.InteractionType->Case.Origin_DL', Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CCA_DATA_LOAD, 
                                             'Site_Issue__c', 'Interaction_Type__c', 'Case', 'Origin'));
    syncFieldList.add(createSyncField('MS.ResSummary->Case.ResSummary_DL', Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CCA_DATA_LOAD, 
                                             'Site_Issue__c', 'Member_Facing_Resolution_Summary__c', 'Case', 'Member_Facing_Resolution_Summary__c'));
    syncFieldList.add(createSyncField('MS.Project->Case.ProjectSrc_DL', Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CCA_DATA_LOAD, 
                                             'Site_Issue__c', 'Project__c', 'Case', 'Project_Source_MS__c'));
    syncFieldList.add(createSyncField('MS.ReportedBy->Case.ContactId_DL', Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CCA_DATA_LOAD, 
                                             'Site_Issue__c', 'Reported_By__c', 'Case', 'ContactId'));
    syncFieldList.add(createSyncField('MS.IssuePriority->Case.Priority_DL', Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CCA_DATA_LOAD, 
                                             'Site_Issue__c', 'Site_Issue_Priority__c', 'Case', 'Priority'));
    syncFieldList.add(createSyncField('MS.ShortDescription->Case.Subj_DL', Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CCA_DATA_LOAD, 
                                             'Site_Issue__c', 'Site_Issue_Short_Description__c', 'Case', 'Subject'));
    syncFieldList.add(createSyncField('MS.Status->Case.Status_DL', Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CCA_DATA_LOAD, 
                                             'Site_Issue__c', 'Status__c', 'Case', 'Status'));
    syncFieldList.add(createSyncField('MS.StepsToRepro->Case.StepsToRepro_DL', Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CCA_DATA_LOAD, 
                                             'Site_Issue__c', 'Steps_to_Reproduce__c', 'Case', 'Steps_to_Reproduce_MS__c'));
    syncFieldList.add(createSyncField('MS.SupportAnalyst->Case.TIIAnalyst_DL', Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CCA_DATA_LOAD, 
                                             'Site_Issue__c', 'Support_Analyst__c', 'Site_Issue__c', 'Tier_II_Support_Analyst_Contact__c'));
    syncFieldList.add(createSyncField('MS.BrowserUsd->Case.BrowserUsd', Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CCA_SUPPORT_REQUEST, 
                                             'Site_Issue__c', 'Browser_Used__c', 'Case', 'Browser_Used__c'));
    syncFieldList.add(createSyncField('MS.IssueDescription->Case.Description', Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CCA_SUPPORT_REQUEST, 
                                             'Site_Issue__c', 'Crimson_Site_Issue_Description__c', 'Case', 'Description'));
    syncFieldList.add(createSyncField('MS.CurrentResults->Case.CurrentResults', Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CCA_SUPPORT_REQUEST, 
                                             'Site_Issue__c', 'Current_Results__c', 'Case', 'Current_Results__c'));
    syncFieldList.add(createSyncField('MS.ExpectedResult->Case.ExpectedResult', Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CCA_SUPPORT_REQUEST, 
                                             'Site_Issue__c', 'Expected_Results__c', 'Case', 'Expected_Results__c'));
    syncFieldList.add(createSyncField('MS.InteractionType->Case.Origin', Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CCA_SUPPORT_REQUEST, 
                                             'Site_Issue__c', 'Interaction_Type__c', 'Case', 'Origin'));
    syncFieldList.add(createSyncField('MS.ResSummary->Case.ResSummary', Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CCA_SUPPORT_REQUEST, 
                                             'Site_Issue__c', 'Member_Facing_Resolution_Summary__c', 'Case', 'Member_Facing_Resolution_Summary__c'));
    syncFieldList.add(createSyncField('MS.Project->Case.ProjectSrc', Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CCA_SUPPORT_REQUEST, 
                                             'Site_Issue__c', 'Project__c', 'Case', 'Project_Source_MS__c'));
    syncFieldList.add(createSyncField('MS.ReportedBy->Case.ContactId', Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CCA_SUPPORT_REQUEST, 
                                             'Site_Issue__c', 'Reported_By__c', 'Case', 'ContactId'));
    syncFieldList.add(createSyncField('MS.IssuePriority->Case.Priority', Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CCA_SUPPORT_REQUEST, 
                                             'Site_Issue__c', 'Site_Issue_Priority__c', 'Case', 'Priority'));
    syncFieldList.add(createSyncField('MS.ShortDescription->Case.Subj', Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CCA_SUPPORT_REQUEST, 
                                             'Site_Issue__c', 'Site_Issue_Short_Description__c', 'Case', 'Subject'));
    syncFieldList.add(createSyncField('MS.Status->Case.Status', Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CCA_SUPPORT_REQUEST, 
                                             'Site_Issue__c', 'Status__c', 'Case', 'Status'));
    syncFieldList.add(createSyncField('MS.StepsToRepro->Case.StepsToRepro', Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CCA_SUPPORT_REQUEST, 
                                             'Site_Issue__c', 'Steps_to_Reproduce__c', 'Case', 'Steps_to_Reproduce_MS__c'));
    syncFieldList.add(createSyncField('MS.SupportAnalyst->Case.TIIAnalyst', Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CCA_SUPPORT_REQUEST, 
                                             'Site_Issue__c', 'Support_Analyst__c', 'Site_Issue__c', 'Tier_II_Support_Analyst_Contact__c'));
        //Commented by Mahendra Swarnkar - 03/05/2020 - CR-20200217-13756: RT deleted: PT DataLoad - START HERE
        /*
        syncFieldList.add(createSyncField('Case.CaseNum->MS.IssueNum_DL', Constants.RECORD_TYPE_CASE_DEVELOPER_NAME_PT_DATA_LOAD, 
                                                 'Case', 'CaseNumber', 'Site_Issue__c', 'Case_Number__c'));
        syncFieldList.add(createSyncField('Case.ContactId->MS.ReportedBy_DL', Constants.RECORD_TYPE_CASE_DEVELOPER_NAME_PT_DATA_LOAD, 
                                                 'Case', 'ContactId', 'Site_Issue__c', 'Reported_By__c'));
        syncFieldList.add(createSyncField('Case.CurrentRes->MS.CurrentRes_DL', Constants.RECORD_TYPE_CASE_DEVELOPER_NAME_PT_DATA_LOAD, 
                                                 'Case', 'Current_Results__c', 'Site_Issue__c', 'Current_Results__c'));
        syncFieldList.add(createSyncField('Case.DiagNotes->MS.DiagNotes_DL', Constants.RECORD_TYPE_CASE_DEVELOPER_NAME_PT_DATA_LOAD, 
                                                 'Case', 'Diagnostics_Notes__c', 'Site_Issue__c', 'Diagnostics_Notes_Comments__c'));
        syncFieldList.add(createSyncField('Case.ExpectedRes->MS.ExpextedRes_DL', Constants.RECORD_TYPE_CASE_DEVELOPER_NAME_PT_DATA_LOAD, 
                                                 'Case', 'Expected_Results__c', 'Site_Issue__c', 'Expected_Results__c'));
        syncFieldList.add(createSyncField('Case.ResSummary->MS.ResSummary_DL', Constants.RECORD_TYPE_CASE_DEVELOPER_NAME_PT_DATA_LOAD, 
                                                 'Case', 'Member_Facing_Resolution_Summary__c', 'Site_Issue__c', 'Member_Facing_Resolution_Summary__c'));
        syncFieldList.add(createSyncField('Case.Origin->MS.InteractionType_DL', Constants.RECORD_TYPE_CASE_DEVELOPER_NAME_PT_DATA_LOAD, 
                                                 'Case', 'Origin', 'Site_Issue__c', 'Interaction_Type__c'));
        syncFieldList.add(createSyncField('Case.Priority->MS.IssuePriority_DL', Constants.RECORD_TYPE_CASE_DEVELOPER_NAME_PT_DATA_LOAD, 
                                                 'Case', 'Priority', 'Site_Issue__c', 'Site_Issue_Priority__c'));
        syncFieldList.add(createSyncField('Case.ProjectSrc->MS.Project_DL', Constants.RECORD_TYPE_CASE_DEVELOPER_NAME_PT_DATA_LOAD, 
                                                 'Case', 'Project_Source_MS__c', 'Site_Issue__c', 'Project__c'));
        syncFieldList.add(createSyncField('Case.Status->MS.Status_DL', Constants.RECORD_TYPE_CASE_DEVELOPER_NAME_PT_DATA_LOAD, 
                                                 'Case', 'Status', 'Site_Issue__c', 'Status__c'));
        syncFieldList.add(createSyncField('Case.StepsToRepro->MS.StepsToRepro_DL', Constants.RECORD_TYPE_CASE_DEVELOPER_NAME_PT_DATA_LOAD, 
                                                 'Case', 'Steps_to_Reproduce_MS__c', 'Site_Issue__c', 'Steps_to_Reproduce__c'));
        syncFieldList.add(createSyncField('Case.Subj->MS.ShortDescription_DL', Constants.RECORD_TYPE_CASE_DEVELOPER_NAME_PT_DATA_LOAD, 
                                                 'Case', 'Subject', 'Site_Issue__c', 'Site_Issue_Short_Description__c'));
        syncFieldList.add(createSyncField('Case.Tier1->MS.Tier1_DL', Constants.RECORD_TYPE_CASE_DEVELOPER_NAME_PT_DATA_LOAD, 
                                                 'Case', 'Tier_I_Support_Analyst__c', 'Site_Issue__c', 'Tier_I_Support_Analyst__c'));
        syncFieldList.add(createSyncField('Case.TIIAnalyst->MS.SupportAnalyst_DL', Constants.RECORD_TYPE_CASE_DEVELOPER_NAME_PT_DATA_LOAD, 
                                                 'Case', 'Tier_II_Support_Analyst_Contact__c', 'Site_Issue__c', 'Support_Analyst__c'));
        */
        //Commented by Mahendra Swarnkar - 03/05/2020 - CR-20200217-13756: RT deleted: PT DataLoad - END HERE
        
        //Commented by Mahendra Swarnkar - 03/05/2020 - CR-20200217-13756: RT deleted: PT Support Request - START HERE
        /*syncFieldList.add(createSyncField('Case.CaseNum->MS.IssueNum', Constants.RECORD_TYPE_CASE_DEVELOPER_NAME_PT_SUPPORT_REQUEST, 
                                          'Case', 'CaseNumber', 'Site_Issue__c', 'Case_Number__c'));
        syncFieldList.add(createSyncField('Case.ContactId->MS.ReportedBy', Constants.RECORD_TYPE_CASE_DEVELOPER_NAME_PT_SUPPORT_REQUEST, 
                                          'Case', 'ContactId', 'Site_Issue__c', 'Reported_By__c'));
        syncFieldList.add(createSyncField('Case.CurrentResults->MS.CurrentResults', Constants.RECORD_TYPE_CASE_DEVELOPER_NAME_PT_SUPPORT_REQUEST, 
                                          'Case', 'Current_Results__c', 'Site_Issue__c', 'Current_Results__c'));
        syncFieldList.add(createSyncField('Case.Description->MS.IssueDescription', Constants.RECORD_TYPE_CASE_DEVELOPER_NAME_PT_SUPPORT_REQUEST, 
                                          'Case', 'Description', 'Site_Issue__c', 'Crimson_Site_Issue_Description__c'));
        syncFieldList.add(createSyncField('Case.ExpectedResult->MS.ExpextedResult', Constants.RECORD_TYPE_CASE_DEVELOPER_NAME_PT_SUPPORT_REQUEST, 
                                          'Case', 'Expected_Results__c', 'Site_Issue__c', 'Expected_Results__c'));
        syncFieldList.add(createSyncField('Case.ResSummary->MS.ResSummary', Constants.RECORD_TYPE_CASE_DEVELOPER_NAME_PT_SUPPORT_REQUEST, 
                                          'Case', 'Member_Facing_Resolution_Summary__c', 'Site_Issue__c', 'Member_Facing_Resolution_Summary__c'));
        syncFieldList.add(createSyncField('Case.Origin->MS.InteractionType', Constants.RECORD_TYPE_CASE_DEVELOPER_NAME_PT_SUPPORT_REQUEST, 
                                          'Case', 'Origin', 'Site_Issue__c', 'Interaction_Type__c'));
        syncFieldList.add(createSyncField('Case.Priority->MS.IssuePriority', Constants.RECORD_TYPE_CASE_DEVELOPER_NAME_PT_SUPPORT_REQUEST, 
                                          'Case', 'Priority', 'Site_Issue__c', 'Site_Issue_Priority__c'));
        syncFieldList.add(createSyncField('Case.ProjectSrc->MS.Project', Constants.RECORD_TYPE_CASE_DEVELOPER_NAME_PT_SUPPORT_REQUEST, 
                                          'Case', 'Project_Source_MS__c', 'Site_Issue__c', 'Project__c'));
        syncFieldList.add(createSyncField('Case.Status->MS.Status', Constants.RECORD_TYPE_CASE_DEVELOPER_NAME_PT_SUPPORT_REQUEST, 
                                          'Case', 'Status', 'Site_Issue__c', 'Status__c'));
        syncFieldList.add(createSyncField('Case.StepsToRepro->MS.StepsToRepro', Constants.RECORD_TYPE_CASE_DEVELOPER_NAME_PT_SUPPORT_REQUEST, 
                                          'Case', 'Steps_to_Reproduce_MS__c', 'Site_Issue__c', 'Steps_to_Reproduce__c'));
        syncFieldList.add(createSyncField('Case.Subj->MS.ShortDescription', Constants.RECORD_TYPE_CASE_DEVELOPER_NAME_PT_SUPPORT_REQUEST, 
                                          'Case', 'Subject', 'Site_Issue__c', 'Site_Issue_Short_Description__c'));
        syncFieldList.add(createSyncField('Case.Tier1->MS.Tier1', Constants.RECORD_TYPE_CASE_DEVELOPER_NAME_PT_SUPPORT_REQUEST, 
                                          'Case', 'Tier_I_Support_Analyst__c', 'Site_Issue__c', 'Tier_I_Support_Analyst__c'));
        syncFieldList.add(createSyncField('Case.TIIAnalyst->MS.SupportAnalyst', Constants.RECORD_TYPE_CASE_DEVELOPER_NAME_PT_SUPPORT_REQUEST, 
                                          'Case', 'Tier_II_Support_Analyst_Contact__c', 'Site_Issue__c', 'Support_Analyst__c'));
        */
        //Commented by Mahendra Swarnkar - 03/05/2020 - CR-20200217-13756: RT deleted: PT Support Request - END HERE
        
        //Added - by- Abhinav Sharma - 06/15/2016 - CR-20150202-8628
        //Start from here
        //Commented by Mahendra Swarnkar - 03/05/2020 - CR-20200217-13756: RT deleted: PT Support Request - START HERE
        /*syncFieldList.add(createSyncField('MS.DLPB__c->Case.DLPB__c', Constants.RECORD_TYPE_CASE_DEVELOPER_NAME_PT_SUPPORT_REQUEST, 
                                             'Site_Issue__c', 'Data_Load_Period_Begin__c', 'Case', 'Description'));
        syncFieldList.add(createSyncField('MS.DLPE__c->Case.DLPE__c', Constants.RECORD_TYPE_CASE_DEVELOPER_NAME_PT_SUPPORT_REQUEST, 
                                             'Site_Issue__c', 'Data_Load_Period_End__c', 'Case', 'Description'));
    	*/
        //Commented by Mahendra Swarnkar - 03/05/2020 - CR-20200217-13756: RT deleted: PT Support Request - END HERE
        
        syncFieldList.add(createSyncField('MS.DLPB1__c->Case.DLPB1__c', Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CCA_DATA_LOAD, 
                                             'Site_Issue__c', 'Data_Load_Period_Begin__c', 'Case', 'Description'));
        syncFieldList.add(createSyncField('MS.DLPE1__c->Case.DLPE1__c', Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CCA_DATA_LOAD,
                                          'Site_Issue__c', 'Data_Load_Period_Begin__c', 'Case', 'Description'));
    
        
        //Commented by Mahendra Swarnkar - 03/05/2020 - CR-20200217-13756: RT deleted: PT Support Request - START HERE
        /*syncFieldList.add(createSyncField('Case.DLPB__c->MS.DLPB__c', Constants.RECORD_TYPE_CASE_DEVELOPER_NAME_PT_SUPPORT_REQUEST, 
                                             'Case', 'Date_of_Presentation__c', 'Site_Issue__c', 'Data_Load_Period_Begin__c'));
        syncFieldList.add(createSyncField('Case.DLPE__c->MS.DLPE__c', Constants.RECORD_TYPE_CASE_DEVELOPER_NAME_PT_SUPPORT_REQUEST, 
                                          'Case', 'Date_of_Presentation__c', 'Site_Issue__c', 'Data_Load_Period_End__c'));*/
        //Commented by Mahendra Swarnkar - 03/05/2020 - CR-20200217-13756: RT deleted: PT Support Request - END HERE
        
        //Commented by Mahendra Swarnkar - 03/05/2020 - CR-20200217-13756: RT deleted: PT DataLoad - Start Here
        /*syncFieldList.add(createSyncField('Case.DLPB1__c->MS.DLPB1__c', Constants.RECORD_TYPE_ID_CASE_PT_DATA_LOAD, 
                                             'Case', 'Date_of_Presentation__c', 'Site_Issue__c', 'Data_Load_Period_Begin__c'));
        syncFieldList.add(createSyncField('Case.DLPE1__c->MS.DLPE1__c', Constants.RECORD_TYPE_ID_CASE_PT_DATA_LOAD, 
                                          'Case', 'Date_of_Presentation__c', 'Site_Issue__c', 'Data_Load_Period_End__c'));*/
        //Commented by Mahendra Swarnkar - 03/05/2020 - CR-20200217-13756: RT deleted: PT DataLoad - End Here
        //Upto here
        
      insert syncFieldList;
    }
    
    
  //Create a Registration
  /* Spring Cleanup
  public static Event_Registration__c createRegistration(Id eventId, Id contactId, boolean CreateAndInsert) {
        // create the registration
        Event_Registration__c registration = new Event_Registration__c();
        registration.Contact__c = contactId;
        registration.Advisory_Event__c = eventId;
        registration.Status__c = 'Scheduled';
        if (CreateAndInsert) insert registration;
        
        return registration;
    }
    */
    //Create a meeting
    public static Advisory_Event__c createEvent(boolean createAndInsert) {
        // create the meeting
        Advisory_Event__c meeting = createEvent(null, null, createAndInsert);
        if (createAndInsert) insert meeting;
        return meeting;
    }
    
    //create a meeting with a specific record type and cost center
    public static Advisory_Event__c createEvent(Id recordTypeId, Id costCenterId, boolean createAndInsert) {
        // create the meeting
        // v1.15 - Updated by - Saurabh Kumar 09/23/2020 - CR-20200819-14449 - Removed the reference of Date_Begins__c & Date_Ends__c
        // V1.16 - Updated by - Saurabh Kumar - 11/09/2020 - CR-20201105-14664 - Replaced EAB Event's Type with EAB Event's Event Type
        Advisory_Event__c meeting = new Advisory_Event__c(Begins__c = system.now().addDays(-30),
                                                          Ends__c = system.now().addDays(30),
                                                          //Date_Begins__c = system.today().addDays(-30),
                                                          //Date_Ends__c = system.today().addDays(30),
                                                          Event_Type__c = 'Research Webinar');
        if (recordTypeId != null)
          meeting.RecordTypeId = recordTypeId;
        
        if (createAndInsert) insert meeting;
        return meeting;
    }
    
    //Added By - Abhinav Sharma - 05/30/2016 - CR-20150202-8624
    //Start from here
    //Create a case comment
    public static CaseComment createNewCaseComment(Case parentCase, boolean createAndInsert) {
        
        //Checking parent case instance for null value and accordingly populating CaseComment instance with fields value
        if(parentCase != null && parentCase.Id != null) {
          
            //Initializing case comment instance
            CaseComment com = new CaseComment();
            
            //Populating fields with appropriate values
            com.ParentId = parentCase.Id;
            com.CommentBody = 'Testing Going On';
            com.IsPublished = true;
      
            //Checking for flag value
          if (createAndInsert) insert com;
            
            //Returning case comment instance
            return com;
        } else {
            return null;
    }
    }
    //Upto here
    
    //Added By - Abhinav Sharma - 06/02/2016 - CR-20150202-8625
    //Start from here
    //Constants like variables useful in test classes 
    public final static string EXPERT_CENTER_CASE_RECORD_TYPE = 'zzzExpert Center';
    public final static string ASK_EAB_CASE_RECORD_TYPE = 'Ask EAB';
    public final static string INTERNATIONAL_CASE_RECORD_TYPE = 'zzzABI Research Requests';
    public final static string CONTACT_EMPLOYEE_RECORD_TYPE = 'Employee';
    public final static string CONTACT_OBJECT = 'Contact';
    public final static string SELECTED_DEADLINE_DATE_ERROR = 'Selected deadline date is conflicting with some Case Blackout Days records';
    public final static string ID_NOT_SPECIFIED_IN_UPDATE_CALL = 'Id not specified in an update call';
    //upto here
    
    //Added By - Mahedra Swarnkar - 07/25/2016 - CR-20160229-9651 - Starts from Here
    public final static  string DEADLINE_REASON_NOT_POPULATED_ERROR = 'Deadline is less than 5 business days from Today. Please provide a reason for this urgency.';
    //Added By - Mahedra Swarnkar - 07/25/2016 - CR-20160229-9651 - Ends Here
    
    //Added By - Abhinav Sharma - 06/03/2016 - CR-20150202-8626
    //Start from here
    //Constants like variables useful in test classes
    public static final string CASE_RECORD_TYPE_EAB_CUSTOM = 'Ask EAB';
    //Commnetd by Mahendar Swarnkar  - 03/05/2020 - CR-20200217-13756 : IRC Request
    //public static final string CASE_RECORD_TYPE_IRC_REQUEST = 'IRC Request';
    public static final string CASE_RECORD_TYPE_MEMBER_AND_SUPPORT_REQUEST = 'Member & Employee Support';
    //upto here
    
    //Added By - Abhinav Swarnkar - 06/07/2016 - CR-20150202-8629
    //Start from here
    //Constants like variables useful in test classes
    public static final String CHANGE_REQUEST_OBJECT = 'SFDC_Change_Request__c';
    public static final String CHANGE_REQUEST_RECORD_TYPE_LEVEL_I = 'Level I';
    public static final String CHANGE_REQUEST_RECORD_TYPE_LEVEL_II = 'SFDC Change Request';
    public static final String CHANGE_REQUEST_RECORD_TYPE_LEVEL_III = 'Level III';
    //Upto here

    //Added by Colin McGloin
    //Sets up the data required as part of FinancialForce unit tests
    public static void setUpFinancialForceData (boolean FireRecords, Id PassThroughId) {

        //Let's start by checking if this is a sandbox or the big league
        Organization currOrg = [Select Id, IsSandbox from Organization limit 1];

        if (!currOrg.isSandbox) {
            //We need to make sure the running user has all of the right licenses
            //Query 1 - FFA License
            PackageLicense ffaLicense = [SELECT Id, AllowedLicenses, UsedLicenses, NamespacePrefix FROM PackageLicense WHERE NamespacePrefix = 'c2g'];

            //Need to make sure there is a free license
            if ((ffaLicense.AllowedLicenses - ffaLicense.UsedLicenses) <= 0){
                //Remove a user in the test method to allow it to pass
                UserPackageLicense user1 = [SELECT Id FROM UserPackageLicense WHERE PackageLicenseId = :ffaLicense.Id LIMIT 1];
                delete user1;

                UserPackageLicense currentUserFF = new UserPackageLicense (PackageLicenseId = ffaLicense.Id, UserId = PassThroughId);
                insert currentUserFF;

            }

            else {
                //We don't have to free up any licenses because they are some available
                UserPackageLicense currentUserFF = new UserPackageLicense (PackageLicenseId = ffaLicense.Id, UserId = PassThroughId);
                insert currentUserFF;

            }
        }

        //Create the users we need for our insertions
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User user1 = testUtilities.CreateNewUser(p, true);
        user1.LastName = 'O Driscoll';
        update user1;
        User user2 = testUtilities.CreateNewUser(p, true);
        Id user3 = PassThroughId;

        // Setup Company and User association within runAs to avoid mixed DML restriction
        Group companyGroup = null;
        System.runAs(user1) {

        // Create Company
        c2g__codaCompany__c company1 = new c2g__codaCompany__c();
        company1.Name = 'ApexTestCompany';
        company1.RecordTypeId = Schema.SObjectType.c2g__codaCompany__c.RecordTypeInfosByName.get('VAT').RecordTypeId;
        insert company1;

        // Create Company Queue
        c2g.CODACompanyWebService.createQueue(company1.Id, 'USD', company1.Name);

        // Activate the Company
        c2g.CODAYearWebService.calculatePeriods(null); // Workaround to bug in company API's, safe to remain once fixed
        c2g.CODACompanyWebService.activateCompany(company1.Id, 'USD', company1.Name);

        // Assign the User to the Company
        c2g__codaUserCompany__c userCompany1 = new c2g__codaUserCompany__c();
        userCompany1.c2g__Company__c = company1.Id;
        userCompany1.c2g__User__c = user1.Id;
        insert userCompany1;

        c2g__codaUserCompany__c userCompany2 = new c2g__codaUserCompany__c();
        userCompany2.c2g__Company__c = company1.Id;
        userCompany2.c2g__User__c = User2.Id;
        insert userCompany2;

        c2g__codaUserCompany__c userCompany3 = new c2g__codaUserCompany__c();
        userCompany3.c2g__Company__c = company1.Id;
        userCompany3.c2g__User__c = User3;
        insert userCompany3;

        // Assign the User to the Company Queue
        String queueName = 'FF ' + company1.Name;
        companyGroup = [select Id from Group where Name = :queueName And Type = 'Queue'];
        insert new GroupMember( GroupId = companyGroup.Id, UseroRGroupId = User1.Id);
        insert new GroupMember( GroupId = companyGroup.Id, UseroRGroupId = User2.Id);
        insert new GroupMember( GroupId = companyGroup.Id, UseroRGroupId = User3);

        }

        System.runAs(User2) {

        // Create Year and Periods
        c2g__codaYear__c yr = new c2g__codaYear__c();
        yr.Name = String.valueOf(Date.today().year());
        yr.OwnerId = companyGroup.Id;
        yr.c2g__NumberOfPeriods__c = 12;
        yr.c2g__AutomaticPeriodList__c = true;
        yr.c2g__StartDate__c = Date.valueOf(Date.today().year() + '-01-01 00:00:00');
        yr.c2g__EndDate__c = Date.valueOf(Date.today().year() + '-12-31 00:00:00');
        yr.c2g__PeriodCalculationBasis__c = 'Month End';
        insert yr;

        //Auto-Create the Periods
        c2g.CODAYearWebService.calculatePeriods(yr.Id);

        // Create Accounting Currency
        c2g__codaAccountingCurrency__c testCurrency = new c2g__codaAccountingCurrency__c();
        testCurrency.Name = 'USD';
        testCurrency.c2g__DecimalPlaces__c = 2;
        testCurrency.c2g__Home__c = true;
        testCurrency.c2g__Dual__c = true;
        insert testCurrency;

        // Create General Ledger Account
        c2g__codaGeneralLedgerAccount__c gla = new c2g__codaGeneralLedgerAccount__c();
        gla.Name = 'Brochures';
        gla.c2g__ReportingCode__c = 'xyz1';
        gla.c2g__Type__c = 'Balance Sheet';
        gla.Active__c = true;
        insert gla;

        //Create Dimension 1 Record
        c2g__codaDimension1__c dim1 = new c2g__codaDimension1__c();
        dim1.c2g__ExternalId__c = '13';
        dim1.c2g__ReportingCode__c = '13';
        dim1.I_S_Breakout__c = 'Allocations';
        dim1.Active__c = true;
        insert dim1;

        }

    }
  /**  Description    :  The method is used to create and insert Subscription record
    *
    *  Created  By    :  Saurabh Kumar
    *
    *  Created By    :  06/26/2017
    *
    *  @args      :  Id membershipId, Boolean createAndInsert
    *
    *  @return      :  SBQQ__Subscription__c
    *
    *  Revision Log  :  V1.0_Created - Q2C Redesign - Beta Release
    *
    **/
  public static SBQQ__Subscription__c createNewSubscription(Id membershipId, Boolean createAndInsert){
      
      SBQQ__Subscription__c subscription = new SBQQ__Subscription__c(SBQQ__Quantity__c = 1, Membership__c = membershipId, SBQQ__ListPrice__c = 0,
                                      SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0, SBQQ__ProrateMultiplier__c = 2,
                                      Status__c = 'Committed');
      
      if(createAndInsert)
        insert subscription;
        
      return subscription;
    }
  /**  Description    :  The method is used to create and insert Subscription Period record
    *
    *  Created  By    :  Subhash Garhwal
    *
    *  Created By     :  07/04/2017
    * 
    *  @args          :  Id programSubscription, Boolean createAndInsert
    *
    *  @return       :   Subscription_Period__c
    *
    *  Revision Log  :  V1.0_Created - Q2C Redesign - Beta Release
    *
    **/
  public static Subscription_Period__c createNewSubscriptionPeriod(Id programSubscription, Boolean createAndInsert){
      
      Subscription_Period__c subscriptionPeriod = new Subscription_Period__c(Name = 'TestSP', Program_Subscription__c = programSubscription, 
                                          Period_Start_Date__c = Date.Today(),
                                          Segment_Index__c = 1, Negotiated_Amount_Period__c  = 1.0,
                                           Stage__c = 'Pending', Pool_Month__c = '21');
      
      if(createAndInsert)
        insert subscriptionPeriod;
        
      return subscriptionPeriod;
    }
    
    /**  Description    :  The method is used to create and insert SBQQ__Quote__c record
    *
    *  Created  By    :  Saurabh Kumar
    *
    *  Created By    :  07/05/2017
    *
    *  @args      :  Boolean createAndInsert
    *
    *  @return      :  SBQQ__Quote__c
    *
    *  Revision Log  :  V1.0_Created - Q2C Redesign - Beta Release
    *                   V1.1_Modified - 07/25/2019 - Victor Hanson - added pricebook and pricebookId field references.  Latest version of cpq requires these fields
    *
    **/
    public static SBQQ__Quote__c createNewSbqqQuote(Boolean createAndInsert){
      
      //Creating Quote record
      SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Status__c = 'Draft', SBQQ__Type__c = 'Quote',
                                                SBQQ__Pricebook__c = Test.getStandardPricebookId(), SBQQ__PricebookId__c=Test.getStandardPricebookId());
      
      //Checking if flag is true then insert
      if(createAndInsert)
        insert quote;
      
      return quote;
    }
    
    /**  Description    :  The method is used to create and insert Attachment record
    *
    *  Created  By    :  Saurabh Kumar
    *
    *  Created By    :  07/05/2017
    *
    *  @args      :  Id parentId, Boolean createAndInsert
    *
    *  @return      :  Attachment
    *
    *  Revision Log  :  V1.0_Created - Q2C Redesign - Beta Release
    *
    **/
    public static Attachment createNewAttachment(Id parentId, Boolean createAndInsert){
      
      //Creating Attachment records
      Attachment attachment = new Attachment();
           
        attachment.Name='Unit Test Attachment';
        Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
        attachment.body = bodyBlob;
        attachment.parentId = parentId;
        attachment.ContentType = '.pdf';
        
        //Checking if flag is set the insert the record
        if(createAndInsert)
          insert attachment;
        
        return attachment;
    }
    
    /**  Description    :  The method is used to create and insert Document record
    *
    *  Created  By    :  Saurabh Kumar
    *
    *  Created By    :  07/05/2017
    *
    *  @args      :  Boolean createAndInsert
    *
    *  @return      :  Document
    *
    *  Revision Log  :  V1.0_Created - Q2C Redesign - Beta Release
    *
    **/
    public static Document createNewDocument(Boolean createAndInsert){
         
        Document document = new Document();
        
        //Getting folder Id
        List<Folder> folders = [Select Id From Folder Where AccessType = 'Public' LIMIT 1];
        if(folders.size() > 0){
           
            //Create document record
            document.Body = Blob.valueOf('Testing');
            document.ContentType = 'application/pdf';
            document.DeveloperName = 'Test_Document';
            document.IsPublic = true;
            document.Name = 'Test Doc';
            document.FolderId = folders[0].Id;
            
            if(createAndInsert)
                insert document;
        }
        return document;
    }
    
    /**  Description    :  The method is used to create and insert Quote Line record
    *
    *  Created  By    :  Saurabh Kumar
    *
    *  Created By    :  07/12/2017
    *
    *  @args      :  Id quoteId, Boolean createAndInsert
    *
    *  @return      :  SBQQ__QuoteLine__c
    *
    *  Revision Log  :  V1.0_Created - Q2C Redesign - Beta Release
    *
    **/
    public static SBQQ__QuoteLine__c createNewQuoteLine(Id quoteId, Boolean createAndInsert){
      
      SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c();
      
      quoteLine.SBQQ__Quote__c = quoteId;
      
      if(createAndInsert)
        insert quoteLine;
      
      return quoteLine;
    }
    
    /**  Description    :  The method is used to create and insert Product record
    *
    *  Created  By    :  Saurabh Kumar
    *
    *  Created By    :  07/12/2017
    *
    *  @args      :  Id programId, Boolean createAndInsert
    *
    *  @return      :  Product2
    *
    *  Revision Log  :  V1.0_Created - Q2C Redesign - Beta Release
    *
    **/
    public static Product2 createNewProduct(Id programId, Boolean createAndInsert){
      
      Product2 product = new Product2(Name = 'RI Product', Family = 'RI', Program__c = programId, IsActive = true, ProductCode = 'RIPRO');
      
      if(createAndInsert)
        insert product;
        
      return product;
    }
    
    /**  Description    :  The method is used to create and insert Product record
    *
    *  Created  By    :  Saurabh Kumar
    *
    *  Created By    :  07/12/2017
    *
    *  @args      :  Boolean createAndInsert
    *
    *  @return      :  ContentVersion
    *
    *  Revision Log  :  V1.0_Created - Q2C Redesign - Beta Release
    *
    **/
    public static ContentVersion createNewContentVersion(Boolean createAndInsert){
      
      ContentVersion contentVersion = new ContentVersion(Title ='Google.com', ContentURL = 'www.test.com');
      
      if(createAndInsert)
        insert contentVersion;
      
      return contentVersion;
    }
    
    /**  Description    :  The method is used to create and insert Contract record
    *
    *  Created  By    :  Saurabh Kumar
    *
    *  Created By    :  07/12/2017
    *
    *  @args      :  Boolean createAndInsert
    *
    *  @return      :  Contract
    *
    *  Revision Log  :  V1.0_Created - Q2C Redesign - Beta Release
    *
    **/
    public static Contract createNewStandardContract(Id accountId, Boolean createAndInsert){
      
      Contract contract = new Contract(Name = 'Test', AccountId = accountId, Status = 'Draft', StartDate = System.today(), ContractTerm = 4);
      
      if(createAndInsert)
        insert contract;
      
      return contract;
    }
    
    
    /**  Description    :  This Method is used to insert the Modications under a specific CR
        *
        *  Created  By    :  Rajeev jain
        *
        *  Created By    :  07/07/2018
        *
        *  @args      :  String, Set, String
        *
        *  Revision Log  :  V1.0_Created
        *
    **/
    public static void createModifications(String changeRequestId, set<String> setProfileToBeAddedAsAMOd, String descriptionOfChange) {
        
        //List to hold the Modifications which is goinng to added.
        List<IS_System_Modification__c> isSystemModificationToBeAdded = new List<IS_System_Modification__c>();
        
        //Check for the Set and CR ids
        if(setProfileToBeAddedAsAMOd.size() > 0 && String.IsNotBlank(changeRequestId) && descriptionOfChange.length() > 0 ) {
        
            //Loop through the Set iterate over Profile Which we want to add Modifications 
            for(String profileName : setProfileToBeAddedAsAMOd) {
            
                if(Constants.mapProfileWithIsSystemComponentId.containsKey(profileName)) {
                
                    IS_System_Modification__c isMod = new IS_System_Modification__c();
                    
                        //mapping of Modification Fields
                        isMod.Change_Request__c = changeRequestId;
                        isMod.IS_System_Component__c = Constants.mapProfileWithIsSystemComponentId.get(profileName);
                        isMod.Type_of_Modification__c = 'Modify';
                        isMod.Description__c = descriptionOfChange;
                    	isSystemModificationToBeAdded.add(isMod);
                }
            
            }
            
           //Check the size of the List
            if(isSystemModificationToBeAdded.size() > 0) 
                Database.insert(isSystemModificationToBeAdded, true); 
            
        }else {
        
            throw new CustomException ('Please Add CR Id and Fill Set and description of Change');
        
        }
    }
    
    /**
     * 
     * @description: returns a site profile and auto-generates related acct/contact/siteUser
     * 
     * @revisions: Victor Hanson - 07/31/2019 - CR-20190611-13177 - Added "createSiteProfile"
     * 
     **/
    public static Site_Profile__c createSiteProfile(Account a, boolean createAndInsert) {
        
        //return Site Profile
        return Test_SiteUserHelper.createSiteProfile(a, 'EAB.com', createAndInsert);
    }
    
    /**
     * 
     * @description: returns a site profile and auto-generates related acct/contact/siteUser
     * 
     * @revisions: Victor Hanson - 07/31/2019 - CR-20190611-13177 - Added "createSiteProfile"
     * 
     **/
    public static Site_Profile__c createSiteProfile(boolean createAndInsert) {
        
        //create Account
        Account a = CreateNewAccount(true);
        
        //return Site Profile
        return Test_SiteUserHelper.createSiteProfile(a, 'EAB.com', createAndInsert);
    }
    
      // create a new account record
    public static Deployment_Track__c CreateNewDeploymentTrack(boolean CreateAndInsert) {
        // get the us corporate record type id
        return CreateNewDeploymentTrack('',CreateAndInsert);
    }
    
    // overloaded method to create a new deployment track record -- this method allows the user to specify a record type
    public static Deployment_Track__c CreateNewDeploymentTrack(String RecordTypeLabel, boolean CreateAndInsert) {
         
        Deployment_Track__c retDeploymentTrack = new Deployment_Track__c();
        retDeploymentTrack.Start_Date__c = System.today();
        retDeploymentTrack.End_Date__c = System.today();
       
        if (CreateAndInsert)
            insert retDeploymentTrack;
        
        return retDeploymentTrack;
    }  
    
    // overloaded method to create a new account record -- this method allows the user to specify a record type
    public static Deployment_Process_Summary__c CreateNewDeploymentProcessSummary(String RecordTypeLabel, String validationStatus, String deploymentStatus, String status, boolean CreateAndInsert) {
        Deployment_Process_Summary__c retDeploymentProcessSummary = new Deployment_Process_Summary__c();
        if(String.isNotBlank(validationStatus))
            retDeploymentProcessSummary.Validation_Status__c = validationStatus;
        if(String.isNotBlank(deploymentStatus))
            retDeploymentProcessSummary.Deployment_Status__c = deploymentStatus;
        if(String.isNotBlank(status))
            retDeploymentProcessSummary.Status__c = status;
        if(String.isNotBlank(RecordTypeLabel))
            retDeploymentProcessSummary.RecordTypeId = Schema.SObjectType.Deployment_Process_Summary__c.getRecordTypeInfosByDeveloperName().get(RecordTypeLabel).getRecordTypeId();
        if (CreateAndInsert)
            insert retDeploymentProcessSummary;
        
        return retDeploymentProcessSummary;
    }

    public static Billing_Schedule_Header__c CreateNewBillingScheduleHeader (Id ContractId, Id accountId){

        Billing_Schedule_Header__c bsh = new Billing_Schedule_Header__c();
        if (ContractId != null){
            bsh.Standard_Contract__c = ContractId;
        }
        if (accountId != null){
            bsh.Institution__c = accountId;
        }
        bsh.Invoicing_Arrangement__c = 'Annual';
        bsh.Status__c = 'Record In Sync';
        insert bsh;

        return bsh;
    }
}