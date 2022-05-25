/**
 *  Purpose      :  Test code for the ReferenceRequestController class
 * 
 *   Created By    :  Victor Hanson
 * 
 *   Created Date  :  1/13/2016
 * 
 * Revision Logs  :  V_1.0 - Created
 *                   V_1.1 - Modified By - Abhinav Sharma - CR-20160204-9586 - 04/13/2016
 *                   V_1.2 - Modified By Mahendra Swarnkar - CR-20160830-10157 - 09/02/2016 - modifies the "testSave" Method.
 *                   V_1.3 - Modified By Saurabh Kumar - Q2C Redesign - Beta Release - 07/13/2017
 *                   V_1.4 - Modified By Deepak Kumawat - Apollo - Run All Test Failures Fixes
 *                   V_1.5 - Modified By Dipesh Gupta - Rev Mgmt 606
 *                   V_1.6 - Modify By Mahendra Swarnakar - 6/12/2020 -  CR-20200520-14075
 **/ 
@isTest
public class Test_ReferenceRequestController {
  
    public static final string CONTACT_EXTERNAL_RT_ID = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('External').getRecordTypeId();
    
    /**
     * @description:1) Setup 3 users with related contacts
     *         2) Create Program Collections/Collection Perspectives/Collection Perspective Children
     *         3) Create an Ambassador reference for a contact
     **/
    @TestVisible private static void setupTestData() {
        
        //Bypassing triggers
        Util.BypassAllTriggers = true;
        Util.IsTest(true);
        Util.IsTesting = true;
        
        //create 3 users that will be associated with contacts
        list<User> users = new list<User>();
        User uTaraShimp = TestUtilities.CreatenewUser(false);
        uTaraShimp.FirstName = 'Tara';
        uTaraShimp.LastName = 'Shimp';
        users.add(uTaraShimp);
        User uDavidBlack = TestUtilities.CreatenewUser(false);
        uDavidBlack.FirstName = 'David';
        uDavidBlack.LastName = 'Black';
        users.add(uDavidBlack);
        User uMaureenHahn = TestUtilities.CreatenewUser(false);
        uMaureenHahn.FirstName = 'Maureen';
        uMaureenHahn.LastName = 'Hahn';
        users.add(uMaureenHahn);
        
        insert users;
        
        //create 3 contacts
        list<Contact> contacts = new list<Contact>();
        Contact cTaraShimp = TestUtilities.CreateNewContact(false);
        cTaraShimp.FirstName = 'Tara';
        cTaraShimp.LastName = 'Shimp';
        cTaraShimp.Employee_User_Record__c = uTaraShimp.Id;
        contacts.add(cTaraShimp);
        Contact cDavidBlack = TestUtilities.CreateNewContact(false);
        cDavidBlack.FirstName = 'David';
        cDavidBlack.LastName = 'Black';
        cDavidBlack.Employee_User_Record__c = uTaraShimp.Id;
        contacts.add(cDavidBlack);
        Contact cMaureenHahn = TestUtilities.CreateNewContact(false);
        cMaureenHahn.FirstName = 'Maureen';
        cMaureenHahn.LastName = 'Hahn';
        cMaureenHahn.Employee_User_Record__c = uTaraShimp.Id;
        contacts.add(cMaureenHahn);
        
        util.BypassAllTriggers = true;
        insert contacts;
        util.BypassAllTriggers = false;
        
        //add new Program Collections
        list<Program_Group__c> programCollections = new list<Program_Group__c>();
        Program_Group__c performanceTech = new Program_Group__c(Name = Label.PT, Effective_Start__c = System.today().addDays(-3),
                                                             Short_Name__c = 'PT', Active__c = true);
        programCollections.add(performanceTech);
        Program_Group__c CMA = new Program_Group__c(Name = 'CMA', Effective_Start__c = System.today().addDays(-3),
                                                             Short_Name__c = 'CMA', Active__c = true);
        programCollections.add(CMA);
        Program_Group__c CCC = new Program_Group__c(Name = 'CCC', Effective_Start__c = System.today().addDays(-3),
                                                             Short_Name__c = 'CCC', Active__c = true);
        programCollections.add(CCC);
        Program_Group__c CMR = new Program_Group__c(Name = 'CMR', Effective_Start__c = System.today().addDays(-3),
                                                             Short_Name__c = 'CMR', Active__c = true);
        programCollections.add(CMR);
        Program_Group__c CPRM = new Program_Group__c(Name = 'CPRM', Effective_Start__c = System.today().addDays(-3),
                                                             Short_Name__c = 'CPRM', Active__c = true);
        programCollections.add(CPRM);
        insert programCollections;
        
        //add the Perspective
        Perspective__c refTracking = new Perspective__c(Name = 'Reference Tracking', Business_Owner__c = cTaraShimp.Id, Short_Name__c = 'RefTracking', Active__c = true);
        insert refTracking;
        
        //add Collection Perspective
        Program_Perspective__c refTrackingPT = new Program_Perspective__c(Name = 'PT-Reference Tracking', Program_Group__c = performanceTech.Id, Perspective__c = refTracking.Id,
                                                                          Business_Owner__c = cTaraShimp.Id, Effective_Start__c = System.today().addDays(-3), 
                                                                          Active__c = true);
        insert refTrackingPT;
        
        //create collection perspective children
        list<Program_Relationship__c> collectionChildren = new list<Program_Relationship__c>();
        Program_Relationship__c childCMA = new Program_Relationship__c(Program_Perspective__c = refTrackingPT.Id, Program_Group__c = CMA.Id, Business_Owner__c = cTaraShimp.Id);
        collectionChildren.add(childCMA);
        Program_Relationship__c childCCC = new Program_Relationship__c(Program_Perspective__c = refTrackingPT.Id, Program_Group__c = CCC.Id, Business_Owner__c = cTaraShimp.Id);
        collectionChildren.add(childCCC);
        Program_Relationship__c childCMR = new Program_Relationship__c(Program_Perspective__c = refTrackingPT.Id, Program_Group__c = CMR.Id, Business_Owner__c = cDavidBlack.Id);
        collectionChildren.add(childCMR);
        Program_Relationship__c childCPRM = new Program_Relationship__c(Program_Perspective__c = refTrackingPT.Id, Program_Group__c = CPRM.Id, Business_Owner__c = cMaureenHahn.Id);
        collectionChildren.add(childCPRM);
        insert collectionChildren;
        
        //create an institution
        Account a = TestUtilities.CreateNewAccount('External', false);
        a.Principal__c = userInfo.getUserId(); 
        a.Associate_Principal__c = userInfo.getUserId();
        util.bypassAllTriggers = true;
        insert a;
        
        //create an external contact that will be used as a reference
        Contact ambassadorContact = TestUtilities.CreateNewContact(a, false);
        ambassadorContact.RecordTypeId = CONTACT_EXTERNAL_RT_ID;
        ambassadorContact.lastName = 'Ambassador';
        ambassadorContact.Reference_Program_Status__c = 'PT: CCC';
        insert ambassadorContact;
        util.BypassAllTriggers = true;
        //create the program
        Program__c prog = TestUtilities.CreateNewProgram(true);
        util.BypassAllTriggers = true;
        //create the membership
        Membership__c mem = TestUtilities.CreateNewMembership(ambassadorContact.AccountId, prog.Id, true);
        util.BypassAllTriggers = false;
        //create the Reference (vetted, ambassador) for the contact
        Reference__c ref = new Reference__c(Contact_Name__c = ambassadorContact.Id,
                                            Institution__c = ambassadorContact.AccountId,
                                            Reference_Status__c = 'Vetted',
                                            Reference_Level__c = 'Ambassador',
                                            Dedicated_Advisor__c = userInfo.getUserId(),
                                            Membership__c = mem.Id,
                                            Reference_Module__c = 'CCC',
                                            Member_Type__c = 'NASA',
                                            NASA_Principal__c = UserInfo.getUserId(),
                                            Reference_Vetter__c = userInfo.getUserId(),
                                            Projected_Vetting_Date__c = Date.today());
        util.BypassAllTriggers = true;
        insert ref;
        
        //create the requesting contact record
        Contact reqContact = TestUtilities.CreateNewContact(false);
        reqContact.lastName = 'reqContact';
        reqContact.recordTypeId = Test_ReferenceRequestController.CONTACT_EXTERNAL_RT_ID;
        insert reqContact;  

        Reference_Request__c req = new Reference_Request__c(Request_Status__c = 'New',
                                                            Reference_Modules__c = 'CCC',
                                                            Requesting_Contact__c = reqContact.Id,
                                                            Requesting_Institution__c = reqContact.AccountId,
                                                            Source_Membership__c = mem.Id,
                                                            Date_Needed_By__c = Date.today(),
                                                            Number_of_References_Needed__c = 1,
                                                            Reference_Type_Needed__c = 'Individual',
                                                            Submitted_By__c = userInfo.getUserId());
        insert req;
        
        //create the Reference Request Contact
        Reference_Request_Contact__c rrc = new Reference_Request_Contact__c(Reference_Contact__c = ambassadorContact.Id,
                                                                            Reference_Request__c = req.Id,
                                                                            Reference_Modules__c = 'CCC',
                                                                            Approval_Status__c = 'Pending',
                                                                            Reference_Lead__c = userInfo.getUserId());
        
        insert rrc;
        
    }
    
    @testSetup
    static void setup() {
        
        //Bypass the entity population Logic  
        Util.bypassEntityPopulation = true;
        
        //setup the collection data
        setupTestData();
        
        //create a test contact
        Contact c = TestUtilities.CreateNewContact(false);
        c.LastName = 'referenceTest';
        insert c;
        
        //V_1.3 - Modified By Saurabh Kumar - Q2C Redesign - Beta Release - 07/13/2017 - Start from here
        
        //Calling method to insert Quote
        SBQQ__Quote__c quote = TestUtilities.createNewSbqqQuote(true);
        
        //By Pass All Triggers
        Util.ByPassAllTriggers = true;
        
        
        //create a test Opportunity
        Opportunity opp = TestUtilities.CreateNewOpportunity(c.AccountId, false);
        opp.SBQQ__PrimaryQuote__c = quote.Id;
        
       
        insert opp;
        
        //Reset Flag
        Util.ByPassAllTriggers = false;
        //V_1.3 - Modified By Saurabh Kumar - Q2C Redesign - Beta Release - 07/13/2017 - Upto here
    }
    
    /**
     * @description: This is the scenario where a user is viewing an Opportunity record and clicks the 'Request a Reference' button on the page layout.
     *          STEPS:
     *          1) Populate the required fields
     *          2) Use the identifyContact() method to get the chosen Contact's Institution details
     *          3) Save the Reference Request
     **/
    static testMethod void testSave() {
        
        //Bypass the entity population Logic  
        Util.bypassEntityPopulation = true;
        
        //get the contact created in the testsetup method
        Contact con = [SELECT Id, AccountId, Name FROM Contact WHERE LastName = 'referenceTest' LIMIT 1];
        
        //get the opportunity created in testsetup
        Opportunity opp = [SELECT Id FROM Opportunity WHERE AccountId = :con.AccountId LIMIT 1];
        
        //instantiate the controller
        ReferenceRequestController controller = new ReferenceRequestController();
        
        //set the request wrapper values
        controller.wrapper.requestingContactId = con.Id;
        controller.wrapper.requestingContact = con.Name;
        controller.wrapper.sourceOpportunity = opp.Id;
        controller.wrapper.referenceModules = 'CMA';
        controller.wrapper.numReferencesNeeded = 1;
        controller.wrapper.dateNeededBy = system.today().format();
        controller.wrapper.recordTypeId = Schema.SObjectType.Reference_Request__c.getRecordTypeInfosByName().get(Label.PT).getRecordTypeId();
        
        test.startTest();
        
        //identify the contact - this should populate the requesting institution info
        controller.contactLookupId = con.Id;
        controller.contactName = con.Name;
        controller.lookupField = 'Contact';
        controller.identifyContact();
        system.assertEquals(con.AccountId, controller.wrapper.requestingInstitutionId);
        
        //identify additional contact 1
        controller.contactLookupId = con.Id;
        controller.contactName = con.Name;
        controller.lookupField = 'Contact1';
        controller.identifyContact();
        system.assertEquals(con.Name, controller.wrapper.additionalContact1);
        
        //identify additional contact 2
        controller.contactLookupId = con.Id;
        controller.contactName = con.Name;
        controller.lookupField = 'Contact2';
        controller.identifyContact();
        system.assertEquals(con.Name, controller.wrapper.additionalContact2);
        
        
        //save the record
        controller.save();
        
        //verify there are no errors
        for(ApexPages.Message msg :  ApexPages.getMessages()) {
            if (msg.getSeverity() == ApexPages.Severity.ERROR) {
                //if there is an error, make sure it causes the test to fail
                system.assertEquals('ERROR', msg.getSummary());
            }
        }
        system.assertEquals(true, controller.isSaved);
        
        //verify the record saved successfully
        list<Reference_Request__c> reqs = [SELECT Id FROM Reference_Request__c WHERE Requesting_Contact__c = :con.Id];
        system.assertEquals(1, reqs.size());
        
        //Added By Mahendra Swarnkar - CR-20160830-10157 - 09/02/2016 - to check requiredness of "Reference_Modules__c" - Starts From here
        //Re-Instantiate the controller
        controller = new ReferenceRequestController();
        
        //set the request wrapper values
        controller.wrapper.requestingContactId = con.Id;
        controller.wrapper.requestingContact = con.Name;
        controller.wrapper.sourceOpportunity = opp.Id;
        controller.wrapper.referenceModules = '';
        controller.wrapper.numReferencesNeeded = 1;
        controller.wrapper.dateNeededBy = system.today().format();
        controller.wrapper.recordTypeId = Schema.SObjectType.Reference_Request__c.getRecordTypeInfosByName().get(Label.PT).getRecordTypeId();
        
        //identify the contact - this should populate the requesting institution info
        controller.contactLookupId = con.Id;
        controller.contactName = con.Name;
        controller.lookupField = 'Contact';
        controller.identifyContact();
        system.assertEquals(con.AccountId, controller.wrapper.requestingInstitutionId);
        
        //save the record
        controller.save();
        
        //verify there are no errors
        for(ApexPages.Message msg :  ApexPages.getMessages()) {
            if (msg.getSeverity() == ApexPages.Severity.ERROR) {
                //if there is an error, make sure it causes the test to fail
                system.assertEquals(true, msg.getSummary().contains('Reference Module(s)'));
            }
        }
        
        system.assertEquals(false, controller.isSaved);
        
        //verify the record saved successfully
        reqs = [SELECT Id FROM Reference_Request__c WHERE Requesting_Contact__c = :con.Id];
        test.stopTest();
        system.assertEquals(1, reqs.size());
        //Added By Mahendra Swarnkar - CR-20160830-10157 - 09/02/2016 - to check requiredness of "Reference_Modules__c" - Ends here
    }
    
    /**
     * @description: verify that the updateModules() method concatenates the chosen Modules in a single field
     **/
    static testMethod void testUpdateModules() {
        
        //Bypass the entity population Logic  
        Util.bypassEntityPopulation = true;
        
        //instantiate the controller
        ReferenceRequestController controller = new ReferenceRequestController();
        
        //setup the modules that have been selected
        controller.referenceModuleInput1 = 'CCC';
        controller.referenceModuleInput2 = 'CMA';
        controller.referenceModuleInput3 = 'CMGA';
        controller.updateModules();
        
        //verify the modules have been added to the single field
        system.assertEquals('CCC; CMA; CMGA', controller.wrapper.referenceModules);
    }
    
    /**
     * @description: verify that the cancel() method returns the proper pageRef
     **/
    static testMethod void testCancel() {
        
        //Bypass the entity population Logic  
        Util.bypassEntityPopulation = true;
        
        //instantiate the controller
        ReferenceRequestController controller = new ReferenceRequestController();
        ApexPages.currentPage().getParameters().put('retURL', '/test');
        
        //setup the modules that have been selected
        controller.referenceModuleInput1 = 'CCC';
        controller.referenceModuleInput2 = 'CMA';
        controller.referenceModuleInput3 = 'CMGA';
        controller.updateModules();
        
        system.assertEquals(new PageReference('/test').getURL(), controller.cancel().getURL());
    }
    
    /**
     * @description: verify that the updateAttributes() method concatenates the chosen Attributes in a single field
     **/
    static testMethod void testUpdateAttributes() {
        
        //Bypass the entity population Logic  
        Util.bypassEntityPopulation = true;
        
        //instantiate the controller
        ReferenceRequestController controller = new ReferenceRequestController();
        
        //setup the modules that have been selected
        controller.referenceModuleInput1 = 'CCC';
        controller.referenceModuleInput2 = 'CMA';
        controller.referenceModuleInput3 = 'CMR';
        controller.referenceModuleInput4 = 'CMGA';
        controller.referenceModuleInput5 = 'CPRM';
        controller.updateModules();
        
        Test.startTest();
        
        //setup the attributes that have been selected
        controller.attributePicklist1 = 'CMA';
        controller.attributePicklist2 = 'CMA';
        controller.attributePicklist3 = 'CMA';
        controller.attributePicklist4 = 'CMA';
        controller.attributePicklist5 = 'CMA';
        controller.attributeModule1 = 'Market';
        controller.attributeModule2 = 'Outreach';
        controller.attributeModule3 = 'Pediatric';
        controller.attributeModule4 = 'Size';
        controller.attributeModule5 = 'Planning';
        controller.updateAttributes();
        
        //Stop test
        Test.stoptest();
        
        //verify the modules have been added to the single field
        system.assertEquals('CMA: Market; CMA: Outreach; CMA: Pediatric; CMA: Size; CMA: Planning', controller.wrapper.attributes);
        
        //verify record type options are present
        list<SelectOption> recordTypeOptions = controller.recordTypeOptions;
        system.assertNotEquals(0, recordTypeOptions.size());
        
    }
    
    
    /**
     * @description: verify the refrence module inputs get populated correctly
     **/
    static testMethod void testRefModuleInputs() {
        
        //Bypass the entity population Logic  
        Util.bypassEntityPopulation = true;
        
        list<string> referenceModules = new list<string>();
        referenceModules.add('CCC');
        referenceModules.add('CMA');
        referenceModules.add('CMR');
        referenceModules.add('CMGA');
        referenceModules.add('CPRM');
        
        //instantiate the controller
        ReferenceRequestController controller = new ReferenceRequestController();
        controller.wrapper.referenceModules = string.join(referenceModules, ReferenceRequestController.DELIMITER);
        controller.initRefModuleInputs();
        
        //verify the values
        system.assertEquals('CCC', controller.referenceModuleInput1);
        system.assertEquals('CMA', controller.referenceModuleInput2);
        system.assertEquals('CMR', controller.referenceModuleInput3);
        system.assertEquals('CMGA', controller.referenceModuleInput4);
        system.assertEquals('CPRM', controller.referenceModuleInput5);
    }
    
    
    //Modify By Mahendra Swarnakar - 6/12/2020 -  CR-20200520-14075
    @isTest
    static void testSubmitSelection(){

        //Bypass the entity population Logic  
        Util.bypassEntityPopulation = true;

        
        //get the contact created in the testsetup method
        Contact con = [SELECT Id, AccountId, Name FROM Contact WHERE LastName = 'referenceTest' LIMIT 1];
        
        //get the opportunity created in testsetup
        Opportunity opp = [SELECT Id FROM Opportunity WHERE AccountId = :con.AccountId LIMIT 1];

        //instantiate the controller
        ReferenceRequestController controller = new ReferenceRequestController();

        String recordType = controller.recordTypeName;
        Boolean isRecommended  = controller.isRecommended;
        String attributes = controller.attributes; 
        

        controller.wrapper.selectionStatus  = '--none--';

        //save the record
        controller.submitSelection();

        System.assert(ApexPages.getMessages() != null);
        
        System.assertequals(System.Label.ERROR_MUST_SELECT_SELECTION_STATUS,ApexPages.GetMessages().get(0).getSummary());
        Reference_Request__c rR = [SELECT Id FROM Reference_Request__c Where Reference_Type_Needed__c = 'Individual' LIMIT 1];

        Reference_Request_Contact__c rrC = [SELECT Reference_Contact__r.Account.Name , Reference_Contact__r.Account.Institution_Reference_Flag__c , Reference_Contact__c , Name , 
        Reference_Contact__r.Name , Reference_Contact__r.Contact_Reference_Flag__c , Reference_Contact__r.Title , Reference_Modules__c , 
        Reference_Attributes__c , Approval_Status__c , Reference_Contact_Comments__c FROM Reference_Request_Contact__c Where Reference_Request__c =: rR.ID];

       

        List<ReferenceRequestWrapper.Recommendation> listOfrRW = new List<ReferenceRequestWrapper.Recommendation>();
        ReferenceRequestWrapper.Recommendation rRW1 = new ReferenceRequestWrapper.Recommendation(rrC, true);
        rRW1.isSelected = true;

        listOfrRW.add(rRW1);

        ReferenceRequestWrapper.Recommendation rRW2 = new ReferenceRequestWrapper.Recommendation(rrC, true);
        rRW2.isSelected = false;
       
        listOfrRW.add(rRW2);
        
        ReferenceRequestWrapper.Recommendation rRW3 = new ReferenceRequestWrapper.Recommendation(rrC, true);
        rRW3.isSelected = false;
        rRW3.isSubmitted = false;
        
        
        listOfrRW.add(rRW3);
        
		Test.startTest();
        
        controller.wrapper.selectionStatus = 'Selected';
        controller.wrapper.recommendations = listOfrRW;
        controller.wrapper.Id = rR.ID;
        controller.submitSelection();
		
        system.assert(controller.wrapper != null);
        system.assertEquals(rR.ID, controller.wrapper.Id);
        system.assertEquals('Pending', controller.wrapper.recommendations[0].approvalStatus);
        system.assertEquals('Joe Ambassador', controller.wrapper.recommendations[0].contactName);
        system.assertEquals(null, controller.wrapper.recordTypeId);
        system.assertEquals(2, controller.wrapper.recommendations.size());
		
        listOfrRW.clear();
        listOfrRW.add(rRW2);
        
        controller.wrapper.selectionStatus = 'Selected';
        controller.wrapper.recommendations = listOfrRW;
        controller.wrapper.Id = rR.ID;

        controller.submitSelection();

        system.assert(controller.wrapper != null);
        system.assertEquals(rR.ID, controller.wrapper.Id);
        system.assertEquals('Pending', controller.wrapper.recommendations[0].approvalStatus);
        system.assertEquals('Joe Ambassador', controller.wrapper.recommendations[0].contactName);
        system.assertEquals(null, controller.wrapper.recordTypeId);
        system.assertEquals(1, controller.wrapper.recommendations.size());

        System.assert(ApexPages.getMessages() != null);

        System.assertequals('Please select a value for Selection status.',ApexPages.GetMessages().get(0).getSummary());
        
        Test.stoptest();
        
        controller.wrapper.selectionStatus = ReferenceRequestController.SELECTION_STATUS_NEED_ADDITIONAL_REFERENCE_RECOMMENDATIONS;
        controller.wrapper.recommendations = listOfrRW;
        controller.wrapper.Id = rR.ID;

        controller.submitSelection();

    }
    
    
    //Modify By Mahendra Swarnakar - 6/12/2020 -  CR-20200520-14075
     @isTest
    static void identifyContactErrorTest(){
    
    Test.startTest();
    
        Contact con = TestUtilities.CreateNewContact(false);
        con.FirstName = 'Test';
        con.LastName = 'Data';
        insert con;
        
        Contact con1 = TestUtilities.CreateNewContact(false);
        con1.FirstName = 'Test';
        con1.LastName = 'Data';
        insert con1;
        
        ReferenceRequestController controller = new ReferenceRequestController();
        controller.contactName = 'TestData';
        
        controller.identifyContact();
        controller.save();
        
        system.assertEquals(false, controller.isSaved);
        
        ReferenceRequestController controller1 = new ReferenceRequestController();
        controller1.contactName = 'Test';
        controller1.wrapper.recordTypeId = CONTACT_EXTERNAL_RT_ID;
        
       
        controller1.identifyContact();
        controller1.save();
        
        //verify there are no errors
        for(ApexPages.Message msg :  ApexPages.getMessages()) {
            if (msg.getSeverity() == ApexPages.Severity.ERROR) {
                //if there is an error, make sure it causes the test to fail
                //system.assertEquals(' No Contacts were found. Please click the lookup icon to find a Contact.', msg.getSummary());
            }
        }
        system.assertEquals(false, controller1.isSaved);

    Test.stopTest();
    
    }
}