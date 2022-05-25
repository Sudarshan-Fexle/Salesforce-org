/*
 * Description	:	Test classs for the code coverage of JobTicketMTMTriggerHelper
 * 
 * Created By 	:	Dipesh Gupta
 * 
 * Created Date	: 	27/11/2019
 * 
 * RevisionLog	:	V_1.0 - Created - Dipesh Gupta - CR-20191011-13405
 *                  	V_1.1 - Modified By - Abhinav Sharma - CR-20210106-14784 - 01/19/2021 - JobTicket MTM validation rules for 'Other'
 * 			V_1.2 - Modified By - Shalu Sharma - 5/18/21 - CR-20210315-14997 - Update the "BRE" to "Reply Envelope (BRE/CRE)"
 *			V_1.3 - Modified By - Abhinav Sharma - 05/20/2021 - CR-20210518-15161 - Update the method "test_approveJobTicketMtM"
 *			V_1.4 - Modified By - Mahendra Swarnakar - CR-20210325-15027 - 04/26/2021
 * 			V_1.5 - Modified By - Shalu Sharma - 06/16/2021 - CR-20210520-15168 - PrintMIS: field to display envelope size(s)
 *			V_1.6 - Modified By - Shalu Sharma - 06/16/2021 - CR-20210517-15150 - To increase the coverage of "checkForLockedRecordEdts" method
 *			V_1.7 - Modified By - Shalu Sharma - 10/05/2021 - CR-20210924-15459 - To increase the coverage of "populatesAvailablePriorYearInventoryOnJobTicket" method
 * Code Coverage:	100%	 	
 * */

@isTest
private class Test_JobTicketMTMTriggerHelper 
{
	
    @testsetup static void testSetupData()
    {
        
        // Create Account
        Account inst = new Account(Vendor_Type__c = 'Vendor', Name = 'Test1');
        
        insert inst;
        
        system.assert(inst.Id != null);
        
        //Creating ES Campaign record
        List<ES_Campaign__c> esc = new List<ES_Campaign__c>();
        esc.add(new ES_Campaign__c(Fiscal_Year__c = '2019', Status__c = 'Open', School__c = inst.Id));
        esc.add(new ES_Campaign__c(Fiscal_Year__c = '2020', Status__c = 'In Process', School__c = inst.Id));
        
        insert esc;
        
        System.assert(esc.size() > 0);
        
        // Creating Job Ticket record
        List<Job_Ticket__c> jobTickets = new List<Job_Ticket__c>();
        Job_Ticket__c jobTikt = PrintManagementTestDataFactory.CreateNewJobTicket(false);
        jobTikt.Locked__c = true;
        jobTikt.Production_Manager__c = UserInfo.getUserId();
        jobTikt.Project_Manager__c = UserInfo.getUserId();
        insert jobTikt;
        jobTickets.add(jobTikt);
               
        System.assert(jobTickets.size() > 0);
        
        // Creating Job Ticket Component Records
        List<Job_Ticket_Component__c> jobTicketComponents = new List<Job_Ticket_Component__c>();
        //Modify by - Shalu Sharma - 5/18/21 - CR-20210315-14997
        jobTicketComponents.add(new Job_Ticket_Component__c(Name = 'Test1', Component__c = Constants.COMPONENT_TYPE_BRE)); // BRE Component type
        jobTicketComponents.add(new Job_Ticket_Component__c(Name = 'Test2', Component__c = 'Envelope', Size__c = '4 x 6')); // Envelope Component type
        jobTicketComponents.add(new Job_Ticket_Component__c(Name = 'Test3', Component__c = Label.Component_Type_Value2)); // Card Component type
        jobTicketComponents.add(new Job_Ticket_Component__c(Name = 'Test4', Component__c = 'Form')); // Form Component type
        jobTicketComponents.add(new Job_Ticket_Component__c(Name = 'Test5', Component__c = 'Folder')); // Folder Component type
        jobTicketComponents.add(new Job_Ticket_Component__c(Name = 'Test6', Component__c = Label.Component_Type_Value)); //Collateral Component type
        jobTicketComponents.add(new Job_Ticket_Component__c(Name = 'Test7', Component__c = 'Envelope', Size__c = '4 x 6'));
        insert jobTicketComponents;
        
        System.assert(jobTicketComponents.size() > 0);
        
        // Creating Job Ticket MTM Record 
        List<Job_Ticket_MTM__c> jobTicketMTMs = new List<Job_Ticket_MTM__c>();
        jobTicketMTMs.add(new Job_Ticket_MTM__c(Job_Ticket__c = jobTIckets[0].Id, Job_Ticket_Component__c = jobTicketComponents[0].Id)); // JTM for BRE Component type
        jobTicketMTMs.add(new Job_Ticket_MTM__c(Job_Ticket__c = jobTickets[0].Id, Job_Ticket_Component__c = jobTicketComponents[1].Id, Paper_Weightx__c = '70#')); // JTM for Envelope Component type
        jobTicketMTMs.add(new Job_Ticket_MTM__c(Job_Ticket__c = jobTIckets[0].Id, Job_Ticket_Component__c = jobTicketComponents[1].Id)); // Another JTM for Envelope Component type
        jobTicketMTMs.add(new Job_Ticket_MTM__c(Job_Ticket__c = jobTIckets[0].Id, Job_Ticket_Component__c = jobTicketComponents[2].Id)); // JTM for Card Component type
        jobTicketMTMs.add(new Job_Ticket_MTM__c(Job_Ticket__c = jobTIckets[0].Id, Job_Ticket_Component__c = jobTicketComponents[3].Id)); // JTM for Form Component type
        jobTicketMTMs.add(new Job_Ticket_MTM__c(Job_Ticket__c = jobTIckets[0].Id, Job_Ticket_Component__c = jobTicketComponents[4].Id)); // JTM for Folder Component type
        jobTicketMTMs.add(new Job_Ticket_MTM__c(Job_Ticket__c = jobTIckets[0].Id, Job_Ticket_Component__c = jobTicketComponents[5].Id)); // JTM for Collateral Component type
        jobTicketMTMs.add(new Job_Ticket_MTM__c(Job_Ticket__c = jobTickets[0].Id, Job_Ticket_Component__c = jobTicketComponents[6].Id, Paper_Weightx__c = '70#')); // JTM for Envelope Component type        
        insert jobTicketMTMs;
        
        System.assert(jobTicketMTMs.size() > 0 );
        
    }
    
    @isTest static void testCompTypes()
    {
        List<Job_Ticket__c> jobTickets = [SELECT Id, Descriptive_Name__c FROM Job_Ticket__c WHERE Descriptive_Name__c = '### Test Record ###'];
        System.assertEquals(1, jobTickets.size());
        
        List<Job_Ticket_Component__c> jobTicketComponents = [SELECT Id, Name, Component__c FROM Job_Ticket_Component__c];
        System.assertEquals(7, jobTicketComponents.size() );
        
        Test.startTest();
        //Modify by - Shalu Sharma - 5/18/21 - CR-20210315-14997
        List<Job_Ticket_MTM__c> jobTicketMTMs = [SELECT Id, Job_Ticket__c, Job_Ticket__r.Component_Types_Referenced__c, Job_Ticket_Component__c,
                                                 Job_Ticket__r.Envelope_Size__c
                                                 FROM Job_Ticket_MTM__c 
                                                 WHERE Job_Ticket_Component__r.Component__c IN : new Set<String> { Constants.COMPONENT_TYPE_BRE, Constants.COMPONENT_TYPE_ENVELOPE }
                                                 Order By Job_Ticket_Component__r.Component__c ASC];
        String testString = jobTicketMTMs[0].Job_Ticket__r.Component_Types_Referenced__c;
        // Before delete BRE should be populated in Component Types Referenced field
        //Modify by - Shalu Sharma - 5/18/21 - CR-20210315-14997
        System.assertEquals(true, testString.contains(Constants.COMPONENT_TYPE_BRE));
        
        //Added By - Shalu Sharma - 06/16/2021 - CR-20210520-15168 - PrintMIS: field to display envelope size(s)
        String testString1 = jobTicketMTMs[1].Job_Ticket__r.Envelope_Size__c;
        System.assertEquals(true, testString1.contains('4 x 6'));
        
        //update case for size update
        Job_Ticket_Component__c componentJT = new Job_Ticket_Component__c(Id = jobTicketMTMs[2].Job_Ticket_Component__c, Size__c = '4 x 7'); 
        Update componentJT;
        
        //get update JT_MTM records
        jobTicketMTMs = [SELECT Id, Job_Ticket__c, Job_Ticket__r.Component_Types_Referenced__c, Job_Ticket_Component__c,
                         Job_Ticket__r.Envelope_Size__c
                         FROM Job_Ticket_MTM__c 
                         WHERE Job_Ticket_Component__r.Component__c IN : new Set<String> { Constants.COMPONENT_TYPE_BRE, Constants.COMPONENT_TYPE_ENVELOPE }
                         Order By Job_Ticket_Component__r.Component__c ASC];

        //Added By - Shalu Sharma - 06/16/2021 - CR-20210520-15168 - PrintMIS: field to display envelope size(s)
        testString1 = jobTicketMTMs[1].Job_Ticket__r.Envelope_Size__c;
        
        //delete use case
        DELETE jobTicketMTMs;
        Test.stopTest();
        
        // After delete of JTM TIcket BRE should not be populated in Component Types Referenced field
        List<Job_Ticket__c> jobTickets_1 = [SELECT Id, Component_Types_Referenced__c, Envelope_Size__c FROM Job_Ticket__c];
        String testString2 = jobTickets_1[0].Component_Types_Referenced__c;
        //Modify by - Shalu Sharma - 5/18/21 - CR-20210315-14997
        System.assertEquals(false, testString2.contains(Constants.COMPONENT_TYPE_BRE));
        
        //Added By - Shalu Sharma - 06/16/2021 - CR-20210520-15168 - PrintMIS: field to display envelope size(s)
        System.assertEquals(null, jobTickets_1[0].Envelope_Size__c);
    }
    
    //Added By - Shalu Sharma - 06/16/2021 - CR-20210520-15168 - If no Job Ticket MtMs on the Job Ticket
    @isTest static void testNegCase_updateJobTicketFields()
    {
        List<Job_Ticket__c> jobTickets = [SELECT Id FROM Job_Ticket__c];
        System.assertEquals(1, jobTickets.size());
        
        List<Job_Ticket_Component__c> jobTicketComponents = [SELECT Id FROM Job_Ticket_Component__c];
        System.assertEquals(7, jobTicketComponents.size());
        
        List<Job_Ticket_MtM__c> jobTicketMtMs = [SELECT Id FROM Job_Ticket_MtM__c];
        System.assertEquals(8, jobTicketMtMs.size());
        
        Test.startTest();
        //Delete all the Job Ticket MtMs on the Job Ticket
        Delete jobTicketMtMs;
        List<Job_Ticket_MtM__c> jTMs = [SELECT Id FROM Job_Ticket_MtM__c];
        System.assert(jTMs.size() == 0);
        List<Job_Ticket__c> jt = [SELECT Id, Component_Types_Referenced__c, Envelope_Size__c FROM Job_Ticket__c];
        System.assertEquals(null, jt[0].Component_Types_Referenced__c);
        System.assertEquals(null, jt[0].Envelope_Size__c);
        Test.stopTest();
    }
    
    //Added By - Shalu Sharma - 06/16/2021 - CR-20210517-15150 - To increase the coverage of "checkForLockedRecordEdts" method
    @isTest static void test_checkForLockedRecordEdts()
    {
        Util.bypassAllTriggers = true;
        
        List<Account> account = [SELECT Id FROM Account ];
        account[0].r_School_Code__c = 'BR';
        account[0].r_CEEB_Code__c = '1232';
        account[0].RecordTypeId = Constants.RECORD_TYPE_ID_ACCOUNT_VENDOR;
        account[0].Account_Formal_Name__c = 'Sepire';
        update account;
        
        Program__c prog = TestUtilities.CreateNewProgram(true);
        
        Project__c project = new Project__c(Name = 'Test Project', Institution__c = account[0].Id, Fiscal_Year__c = '2021');
        insert project;
        
        List<Job_Ticket__c> jobTickets = [SELECT Id FROM Job_Ticket__c];
        jobTickets[0].Project__c = project.Id;
        jobTickets[0].Vendor_Type__c ='Digital';
        jobTickets[0].Descriptive_Name__c = 'This is for testing';
        jobTickets[0].Art_Director__c = UserInfo.getUserId();
        jobTickets[0].Mail_Date__c = system.today();
        jobTickets[0].of_Drops__c = 2;
        jobTickets[0].of_Letter_Versions__c = 1;
        jobTickets[0].Project__c =project.Id;
        jobTickets[0].Mail_Quantity__c=2;
        jobTickets[0].Fiscal_Year__c = '2020';
        jobTickets[0].Status__c =  'Draft';
        jobTickets[0].Insertion_Order__c = 'ADM - Letter driver';
        jobTickets[0].Job_Code__c = '123';
        jobTickets[0].Locked__c =  True;
        jobTickets[0].Drop_Type__c = 'Pre Planned';
        jobTickets[0].Program__c = prog.Id;
        update jobTickets[0];
        
        Delete [SELECT Id FROM Job_Ticket_MTM__c WHERE Component_Type__c NOT IN : new Set<String> { Constants.COMPONENT_TYPE_BRE}];
        
        List<Job_Ticket_MtM__c> jobTicketMtMs = [SELECT Id, Component_Type__c, Paper_Weightx__c, Paper_Typex__c, Component_Code__c 
                                                 FROM Job_Ticket_MtM__c WHERE Job_Ticket__c =: jobTickets[0].Id];
        jobTicketMtMs[0].Paper_Weightx__c = '24#';
        jobTicketMtMs[0].Paper_Typex__c = 'White Wove';
        jobTicketMtMs[0].Component_Code__c = '8635';
        update jobTicketMtMs[0];
       	System.assertEquals(1, jobTicketMtMs.size());
        System.assertEquals(Constants.COMPONENT_TYPE_BRE, jobTicketMtMs[0].Component_Type__c);
        
        Id ASSOCIATED_FEATURE_RT_ID_COLOR = Schema.SObjectType.Associated_Features__c.getRecordTypeInfosByName().get('Color').getRecordTypeId();
        List<Associated_Features__c> associatedFeatures = new List<Associated_Features__c>();
        associatedFeatures.add(new Associated_Features__c(RecordTypeId = ASSOCIATED_FEATURE_RT_ID_COLOR, Feature_Type__c = 'Color',
                                                          Color_Placement__c = 'Front', PMS__c = 'Blue', Job_Ticket_MtM__c = jobTicketMtMs[0].Id));
        insert associatedFeatures;
        
        Util.bypassAllTriggers = false;
        
        Test.startTest();
        
        List<Job_Ticket__c> jTs = [SELECT Id, Status__c FROM Job_Ticket__c WHERE Descriptive_Name__c = 'This is for testing'];
        jTs[0].Status__c = 'Approved by Partner';
        update jTs[0];  
        
        List<Job_Ticket_MTM__c> jTMlist = [SELECT Id, Paper_Weightx__c, Job_Ticket_Locked__c, Job_Ticket__c, Job_Ticket__r.Program__c, Job_Ticket__r.Program__r.Name FROM Job_Ticket_MTM__c WHERE Job_Ticket__c =: jTs[0].Id];
        System.assertEquals(true, jTMlist[0].Job_Ticket_Locked__c);
        
        jTMlist[0].Paper_Weightx__c = '20#';
        update jTMlist[0];
        
        Test.stopTest(); 
    }
    
    //V_1.1 - Added By - Abhinav Sharma - CR-20210106-14784 - 01/19/2021 - JobTicket MTM validation rules for 'Other'
    @isTest static void test_validationOnCustomTextFields()
    {
        List<Job_Ticket_MTM__c> jobTicketMTMs = [SELECT Id,Paper_Weightx__c, Fold__c, Letter_Size__c, Reply_Size__c, Window_1_Position_From_Bottom__c,
                                                 Window_1_Position_From_Left__c, Envelope_Window_1_Size__c, Perf__c, Type_of_Fold__c, Paper_Typex__c, 
                                                 Sub_type__c, Folded_Size__c, Form_Size__c, Paper_Weight_Custom__c, Fold_Custom__c, Letter_Size_Custom__c,
                                                 Reply_Size_Custom__c, Window1_Position_from_Bottom_Custom__c, Window1_Position_from_Left_Custom__c,
                                                 Window1_Size_Custom__c, Perforation_Custom__c, Type_of_Fold_Custom__c, Paper_Type_Custom__c,
                                                 Folded_Size_Custom__c, Form_Size_Custom__c, Special_Paper__c, Custom_Information__c
                                                 FROM Job_Ticket_MtM__c];
        Test.startTest();
        //check validation on Paper Weight
        try {
            
            jobTicketMTMs[1].Paper_Weightx__c = Constants.JOB_TICKET_MTM_SIZE_OTHER;
            jobTicketMTMs[1].Paper_Weight_Custom__c = null;
            update jobTicketMTMs[1];
        }
        catch(Exception ex) {
            System.assertEquals(true, ex.getMessage().contains(Label.JT_MTM_Paper_Weight_Error_Msg));
        }
        
        jobTicketMTMs[1].Paper_Weightx__c = Constants.JOB_TICKET_MTM_SIZE_OTHER;
        jobTicketMTMs[1].Paper_Weight_Custom__c = 'Paper Weight contains Other';
        update jobTicketMTMs[1];

        //check Validation on Fold
        try {
            
            jobTicketMTMs[5].Fold__c = Constants.JOB_TICKET_MTM_SIZE_OTHER;
            jobTicketMTMs[5].Fold_Custom__c = null;
            update jobTicketMTMs[5];
        }
        catch(Exception ex) {
            System.assertEquals(true, ex.getMessage().contains(Label.JT_MTM_Fold_Error_Msg));
        }
        
        jobTicketMTMs[5].Fold__c = Constants.JOB_TICKET_MTM_SIZE_OTHER;
        jobTicketMTMs[5].Fold_Custom__c = 'Fold contains Other';
        update jobTicketMTMs[5];  

        //check Validation on Letter Size
        try {
            
            jobTicketMTMs[4].Letter_Size__c = Constants.JOB_TICKET_MTM_SIZE_OTHER;
            jobTicketMTMs[4].Letter_Size_Custom__c = null;
            jobTicketMtMs[4].Custom_Information__c = 'Other';
            update jobTicketMTMs[0];
        }
        catch(Exception ex) {
            System.assertEquals(true, ex.getMessage().contains(Label.JT_MTM_Letter_Size_Error_Msg));
        }
        
        jobTicketMTMs[4].Letter_Size__c = Constants.JOB_TICKET_MTM_SIZE_OTHER;
        jobTicketMTMs[4].Letter_Size_Custom__c = 'Letter size contains Other';
        jobTicketMtMs[4].Custom_Information__c = 'Other';
        update jobTicketMTMs[4];

        //check Validation on Reply Size
        try {
            jobTicketMTMs[4].Reply_Size__c = Constants.JOB_TICKET_MTM_SIZE_OTHER;
            jobTicketMTMs[4].Reply_Size_Custom__c = null;
            update jobTicketMTMs[0];
        }
        catch(Exception ex) {
            System.assertEquals(true, ex.getMessage().contains(Label.JT_MTM_Reply_Size_Error_Msg));
        }
        
        jobTicketMTMs[4].Reply_Size__c = Constants.JOB_TICKET_MTM_SIZE_OTHER;
        jobTicketMTMs[4].Reply_Size_Custom__c = 'Reply Size Other';
        update jobTicketMTMs[4];

        //check Validation on Window1 Position From Bottom
        try {
            jobTicketMTMs[1].Window_1_Position_From_Bottom__c = Constants.JOB_TICKET_MTM_SIZE_OTHER;
            jobTicketMTMs[1].Window1_Position_from_Bottom_Custom__c = null;
            update jobTicketMTMs[1];
        }
        catch(Exception ex) {
            System.assertEquals(true, ex.getMessage().contains(Label.JT_MTM_Window1_Position_From_Bottom_Error_Msg));
        }
        
        jobTicketMTMs[1].Window_1_Position_From_Bottom__c = Constants.JOB_TICKET_MTM_SIZE_OTHER;
        jobTicketMTMs[1].Window1_Position_from_Bottom_Custom__c = 'Window 1 Posistion from bottom contains other';
        update jobTicketMTMs[1];

        //check Validation on Window1 Position From Left
        try {
            jobTicketMTMs[1].Window_1_Position_From_Left__c = Constants.JOB_TICKET_MTM_SIZE_OTHER;
            jobTicketMTMs[1].Window1_Position_from_Left_Custom__c = null;
            update jobTicketMTMs[1];
        }
        catch(Exception ex) {
            System.assertEquals(true, ex.getMessage().contains(Label.JT_MTM_Window1_Position_From_Left_Error_Msg));
        }
        
        jobTicketMTMs[1].Window_1_Position_From_Left__c = Constants.JOB_TICKET_MTM_SIZE_OTHER;
        jobTicketMTMs[1].Window1_Position_from_Left_Custom__c = 'Window 1 position from left contains Other';
        update jobTicketMTMs[1];

        //check Validation on Window1 Size
        try {
            jobTicketMTMs[1].Window_Size__c = Constants.JOB_TICKET_MTM_SIZE_OTHER;
            jobTicketMTMs[1].Window1_Size_Custom__c = null;
            jobTicketMTMs[1].Custom_Information__c = 'Other';
            update jobTicketMTMs[1];
        }
        catch(Exception ex) {
            System.assertEquals(true, ex.getMessage().contains(Label.JT_MTM_Window1_Size_Error_Msg));
        }
       
        jobTicketMTMs[1].Window_Size__c = Constants.JOB_TICKET_MTM_SIZE_OTHER;
        jobTicketMTMs[1].Window1_Size_Custom__c = 'Wondow 1 Size contains Other';
        jobTicketMTMs[1].Custom_Information__c = 'Other';
        update jobTicketMTMs[1];

        //check Validation on Pref
        try {
            jobTicketMTMs[6].Perf__c = Constants.JOB_TICKET_MTM_SIZE_OTHER;
            jobTicketMTMs[6].Perforation_Custom__c = null;
            update jobTicketMTMs[6];
        }
        catch(Exception ex) {
            System.assertEquals(true, ex.getMessage().contains(Label.JT_MTM_Perf_Error_Msg));
        }
        
        jobTicketMTMs[6].Perf__c = Constants.JOB_TICKET_MTM_SIZE_OTHER;
        jobTicketMTMs[6].Perforation_Custom__c = 'Perf contains Other';
        update jobTicketMTMs[6];

        //check Validation on Type of Fold
        try {     
            jobTicketMTMs[6].Type_of_Fold__c = Constants.JOB_TICKET_MTM_SIZE_OTHER;
            jobTicketMTMs[6].Type_of_Fold_Custom__c = null;
            update jobTicketMTMs[6];
        }
        catch(Exception ex) {
            System.assertEquals(true, ex.getMessage().contains(Label.JT_MTM_Type_of_Fold_Error_Msg));
        }
        
        jobTicketMTMs[6].Type_of_Fold__c = Constants.JOB_TICKET_MTM_SIZE_OTHER;
        jobTicketMTMs[6].Type_of_Fold_Custom__c = 'Type of Fold contains Other';
        update jobTicketMTMs[6];

        //check Validation on Paper Type
        try {
            jobTicketMTMs[6].Paper_Typex__c = Constants.JOB_TICKET_MTM_SIZE_OTHER;
            jobTicketMTMs[6].Paper_Type_Custom__c = null;
            update jobTicketMTMs[6];
        }
        catch(Exception ex) {
            //System.assertEquals(true, ex.getMessage().contains(Label.JT_MTM_Paper_Type_Error_Msg));
        }
        
        jobTicketMTMs[6].Paper_Typex__c = Constants.JOB_TICKET_MTM_SIZE_OTHER;
        jobTicketMTMs[6].Paper_Type_Custom__c = 'Paper Type contains Other';
        jobTicketMTMs[6].Special_Paper__c = 'Paper Type contains Other';
        update jobTicketMTMs[6];

        //check Validation on Sub Type
        try {     
            jobTicketMTMs[6].Sub_type__c = Constants.JOB_TICKET_MTM_SIZE_OTHER;
            jobTicketMTMs[6].Sub_type_Custom__c = null;
            update jobTicketMTMs[6];
        }
        catch(Exception ex) {
            System.assertEquals(true, ex.getMessage().contains(Label.JT_MTM_Sub_Type_Error_Msg));
        }
        
        jobTicketMTMs[6].Sub_type__c = Constants.JOB_TICKET_MTM_SIZE_OTHER;
        jobTicketMTMs[6].Sub_type_Custom__c = 'Sub-type contains Other';
        update jobTicketMTMs[6];

        //check Validation on Folded Size
        try {
            jobTicketMTMs[0].Component_Type__c = 'Self Mailer';
            jobTicketMTMs[0].Folded_Size__c = Constants.JOB_TICKET_MTM_SIZE_OTHER;
            jobTicketMTMs[0].Folded_Size_Custom__c = null;
            update jobTicketMTMs[0];
        }
        catch(Exception ex) {
            System.assertEquals(true, ex.getMessage().contains(Label.JT_MTM_Folded_Size_Error_Msg));
        }
        
        jobTicketMTMs[0].Folded_Size__c = Constants.JOB_TICKET_MTM_SIZE_OTHER;
        jobTicketMTMs[0].Folded_Size_Custom__c = 'Folded Size contains Other';
        jobTicketMTMs[0].Component_Type__c = 'Self Mailer';
        update jobTicketMTMs[0];

        //check Validation on Form Size
        try {     
            jobTicketMTMs[4].Form_Size__c = Constants.JOB_TICKET_MTM_SIZE_OTHER;
            jobTicketMTMs[4].Form_Size_Custom__c = null;
            update jobTicketMTMs[4];
        }
        catch(Exception ex) {
            System.assertEquals(true, ex.getMessage().contains(Label.JT_MTM_Form_Size_Error_Msg));
        }
        
        jobTicketMTMs[4].Form_Size__c = Constants.JOB_TICKET_MTM_SIZE_OTHER;
        jobTicketMTMs[4].Form_Size_Custom__c = 'Form Size contains Other';
        update jobTicketMTMs[4];
        Test.stopTest();
    } 
    
    //Modified By - Mahendra Swarnakar - CR-20210325-15027 - 04/26/2021
    @isTest static void testPopulateComponentCodeForOndemandJT()
    {
        List<Job_Ticket__c> jobTickets = [SELECT Id, Descriptive_Name__c, Drop_Type__c FROM Job_Ticket__c];
        System.assertEquals(1, jobTickets.size());
        
        jobTickets[0].Drop_Type__c = System.Label.DROP_TYPE_ON_DEMAND;
        update jobTickets;
        
        List<Job_Ticket_Component__c> jobTicketComponents = [SELECT Id, Name, Component__c FROM Job_Ticket_Component__c Where Component__c IN ('Envelope', 'Form') ORDER BY Component__c];
        System.assertEquals(3, jobTicketComponents.size() );
        
        // Creating Job Ticket MTM Record 
        List<Job_Ticket_MTM__c> jobTicketMTMs = new List<Job_Ticket_MTM__c>();
        jobTicketMTMs.add(new Job_Ticket_MTM__c(Job_Ticket__c = jobTIckets[0].Id, Job_Ticket_Component__c = jobTicketComponents[0].Id)); // JTM for Envelope Component type
        jobTicketMTMs.add(new Job_Ticket_MTM__c(Job_Ticket__c = jobTIckets[0].Id, Job_Ticket_Component__c = jobTicketComponents[1].Id)); // JTM for Form Component type
        
        Test.startTest();
        
        Util.BypassAllTriggers = false;
        insert jobTicketMTMs;
        Util.BypassAllTriggers = true;
        Test.stopTest();
        
    }

    //Added By - Shalu Sharma - CR-20210924-15459 - 10/05/2021
    @isTest static void test_populatesAvailablePriorYearInventoryOnJobTicket()
    {
        Util.BypassAllTriggers = true;
        
        //Create Account
        Account inst = new Account(RecordTypeId = Constants.RECORD_TYPE_ID_ACCOUNT_VENDOR, Vendor_Type__c = 'Vendor', 
                                   Vendor_Sub_Type__c = Constants.VENDOR_TYPE_DIGITAL, Account_Formal_Name__c = 'Sepire',
                                   Name = 'Test1', r_School_Code__c='BR', r_CEEB_Code__c='1232');
        insert inst;
        
        //Create Project
        Project__c proj = TestUtilities.createProject(false);
        proj.Institution__c = inst.Id;
        proj.Fiscal_Year__c = '2021';
        insert proj;
        
        //Create a user for running the process
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        
        User user1 = testUtilities.CreateNewUser(sysAdminProfile, false);
        user1.LastName = 'sysAdminUser';
        insert user1;
        
        //Create new Program
        Program__c prog = TestUtilities.CreateNewProgram(true);
        
        //Creating Job Ticket record 
        List<Job_Ticket__c> jobTickets = new List<Job_Ticket__c>();
        jobTickets.add(new Job_Ticket__c(Project__c = proj.Id, Status__c = 'Draft', Project_Manager__c = user1.Id, 
                                         Descriptive_Name__c = 'Test Desciptive1', Art_Director__c = user1.Id, Mail_Quantity__c = 100,
                                         Change_Reason__c = 'Testing', Project_ID__c = 'Test', Fiscal_Year__c='2021', Drop_Type__c = 'Pre Planned',
                                         Vendor_Type__c ='Digital',Mail_Date__c = system.today(),of_Drops__c = 2,of_Letter_Versions__c = 1,
                                         Job_Code__c = '123',Production_Manager__c= user1.Id,Locked__c =  True, Program__c = prog.Id,
                                         Insertion_Order__c  = 'SrSEARCH - Insert with letter driving package and certificate/reply nested behind it with both facing front'));
        jobTickets.add(new Job_Ticket__c(Project__c = proj.Id, Status__c = 'Draft', Project_Manager__c = user1.Id, 
                                         Descriptive_Name__c = 'Test Desciptive2', Art_Director__c = user1.Id, Mail_Quantity__c = 100,
                                         Change_Reason__c = 'Testing', Project_ID__c = 'Test', Fiscal_Year__c='2021', Drop_Type__c = 'Pre Planned',
                                         Vendor_Type__c ='Digital',Mail_Date__c = system.today(),of_Drops__c = 2,of_Letter_Versions__c = 1,
                                         Job_Code__c = '123',Production_Manager__c= user1.Id,Locked__c =  True, Program__c = prog.Id,
                                         Insertion_Order__c  = 'SrSEARCH - Insert with letter driving package and certificate/reply nested behind it with both facing front'));
        insert jobTickets;
		
        //Create Job Ticket Component record 
        Job_Ticket_Component__c jobTctComponet = new Job_Ticket_Component__c(Name = 'Test1', Component__c = Constants.COMPONENT_TYPE_ENVELOPE);
        insert jobTctComponet;

        Job_Ticket_Component__c jobTctComponet1 = new Job_Ticket_Component__c(Name = 'Test2', Component__c = Constants.COMPONENT_TYPE_ENVELOPE);
        insert jobTctComponet1;
        
        //Create Job Ticket MtM record 
        List<Job_Ticket_MtM__c> jobTickectMTMs = new List<Job_Ticket_MtM__c>();
        jobTickectMTMs.add(new Job_Ticket_MTM__c(Job_Ticket__c = jobTickets[0].Id, Job_Ticket_Component__c = jobTctComponet.Id,
                                                Component_Code__c = 'AE0012',Paper_Weightx__c = '70#',Paper_Typex__c = 'Gloss Text',Status__c = 'Draft'));

        jobTickectMTMs.add(new Job_Ticket_MTM__c(Job_Ticket__c = jobTickets[1].Id, Job_Ticket_Component__c = jobTctComponet1.Id,
                                                Component_Code__c = 'AE0012',Paper_Weightx__c = '70#',Paper_Typex__c = 'Gloss Text',Status__c = 'Draft'));

        insert jobTickectMTMs;
		
        //Create Associated Feature record 
        Id ASSOCIATED_FEATURE_RT_ID_COLOR = Schema.SObjectType.Associated_Features__c.getRecordTypeInfosByName().get('Color').getRecordTypeId();
        List<Associated_Features__c> associatedFeatures = new List<Associated_Features__c>();
        associatedFeatures.add(new Associated_Features__c(RecordTypeId = ASSOCIATED_FEATURE_RT_ID_COLOR, Feature_Type__c = 'Color',
                                                          Color_Placement__c = 'Front', PMS__c = 'Blue', Job_Ticket_MtM__c = jobTickectMTMs[0].Id));

        associatedFeatures.add(new Associated_Features__c(RecordTypeId = ASSOCIATED_FEATURE_RT_ID_COLOR, Feature_Type__c = 'Color',
                                                          Color_Placement__c = 'Front', PMS__c = 'Blue', Job_Ticket_MtM__c = jobTickectMTMs[1].Id));
        insert associatedFeatures;
        
        //Create Production Tracking record 
        Id RECORD_TYPE_ID_PRODUCTION_TRACKING_PRINT = Schema.SObjectType.Production_Tracking__c.getRecordTypeInfosByDeveloperName().get('Print').getRecordTypeId();
        List<Production_Tracking__c> pTrackings = new List<Production_Tracking__c>();
        pTrackings.add(new Production_Tracking__c(Mail_Shop_Vendor__c =  inst.Id, Status__c = Constants.PRODUCTION_TRACKING_STATUS_PLANNED,
                                                  Job_Ticket__c = jobTickets[0].Id, Job_Ticket_MtM__c = jobTickectMTMs[0].Id, RecordTypeId = RECORD_TYPE_ID_PRODUCTION_TRACKING_PRINT, 
                                                  Proof_Generation__c = ProductionTrackingTriggerHelper.PROOF_GENERATION_EXTERNAL, Component__c = Constants.COMPONENT_TYPE_BRE,
                                                  Internal_Data_Drop__c = 1, Art_File_Name__c = 'Art.zip'));
        pTrackings.add(new Production_Tracking__c(Mail_Shop_Vendor__c =  inst.Id,Status__c = Constants.PRODUCTION_TRACKING_STATUS_PLANNED,
                                                  Job_Ticket__c = jobTickets[1].Id, Job_Ticket_MtM__c = jobTickectMTMs[1].Id, RecordTypeId = RECORD_TYPE_ID_PRODUCTION_TRACKING_PRINT, 
                                                  Proof_Generation__c = ProductionTrackingTriggerHelper.PROOF_GENERATION_EXTERNAL, Component__c = Constants.COMPONENT_TYPE_ENVELOPE,
                                                  Internal_Data_Drop__c = 1, Art_File_Name__c = 'Art.zip'));
        insert pTrackings;
		
        //Create Inventory record 
        List<Inventory__c> inventoryList = new List<Inventory__c>();
        inventoryList.add(new Inventory__c(Institution__c = inst.Id ,Job_Ticket_MtM__c = jobTickectMTMs[0].Id,
                                           Inventory_Control_Number__c = 'AE0012', Production_Tracking__c = pTrackings[0].Id));
        inventoryList.add(new Inventory__c(Institution__c = inst.Id ,Job_Ticket_MtM__c = jobTickectMTMs[1].Id, 
                                           Inventory_Control_Number__c = 'AE0012', Production_Tracking__c = pTrackings[1].Id));
        Insert inventoryList;

        jobTickets[0].Status__c = 'Approved by Partner';
        jobTickets[1].Status__c = 'Approved by Partner';

        Update jobTickets;
        
        Util.BypassAllTriggers = false;

        Test.startTest();
        
        jobTickectMTMs[0].Status__c='Approved';
        jobTickectMTMs[0].Status__c='Approved';
        Update jobTickectMTMs;
        
        jobTickectMTMs = [Select Id,Status__c,Job_Ticket__r.Descriptive_Name__c, Component_Code_Formula__c From Job_Ticket_MtM__c 
                          Where Job_Ticket__c =: jobTickets[0].Id OR Job_Ticket__c =: jobTickets[1].Id];
        
        List<Inventory__c> inventryListUpdateJTM = [Select Id, Inventory_Control_Number__c,
                                                    Job_Ticket_MtM__r.Job_Ticket__r.Available_Prior_Year_Inventory__c From Inventory__c
                                                    Where Job_Ticket_MtM__c IN : jobTickectMTMs];
        System.assert(inventryListUpdateJTM[0].Job_Ticket_MtM__r.Job_Ticket__r.Available_Prior_Year_Inventory__c == True);
        
        Test.stopTest();
    }
}