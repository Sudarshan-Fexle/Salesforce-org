@isTest(SeeAllData='True')
public class Test_PSEUtilities {
    
    //Unable to use TestSetup due to complex list of PSA specific settings which run 100's of records deep which would need to be recreated
    
    //@testSetup
    /*public static void createTestData () {
        
        //Insert our Region
        pse__Region__c globalRegion = new pse__Region__c();
        globalRegion.Name = 'Test Region';
        insert globalRegion;
        
        //Insert Permission Control
        pse__Permission_Control__c pControl = new pse__Permission_Control__c();
        pControl.pse__User__c = UserInfo.getUserId();
        pControl.pse__Region__c = globalRegion.Id;
        pControl.pse__Timecard_Entry__c = true;
        pControl.pse__Timecard_Ops_Edit__c = true;
        pControl.pse__Cascading_Permission__c = true;
        insert pControl;
        
        //Create a PSA Project record
        pse__Proj__c boboTheBear = new pse__Proj__c();
        boboTheBear.name = 'Bobo the Bear';
        boboTheBear.pse__Region__c = globalRegion.Id;
        boboTheBear.CurrencyIsoCode = 'USD';
        boboTheBear.Capitalizable__c = true;
        boboTheBear.pse__Is_Active__c = true;
        boboTheBear.pse__Allow_Timecards_Without_Assignment__c = true;
        boboTheBear.pse__Billing_Type__c = 'Fixed Price';
        boboTheBear.pse__Closed_for_Time_Entry__c = false;
        insert boboTheBear;
        
        //Grab a Profile for our Test User
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Specialist'];
        User anakinSkywalker = testUtilities.CreateNewUser(p, true);
        anakinSkywalker.LastName = 'Skywalker';
        update anakinSkywalker;
        
        //Insert a Contact
        Contact darthVader = TestUtilities.CreateNewContact(true);
        darthVader.pse__Salesforce_User__c = anakinSkywalker.Id;
        darthVader.pse__Is_Resource__c = true;
        darthVader.pse__Is_Resource_Active__c = true;
        darthVader.pse__Region__c = globalRegion.Id;
        update darthVader;
        
        //Insert a Timecard record
        pse__Timecard_Header__c timecard = new pse__Timecard_Header__c(
            pse__Project__c = boboTheBear.Id,
            pse__Resource__c = darthVader.Id,
            pse__Start_Date__c = Date.today().toStartOfWeek(),
            pse__End_Date__c = Date.today().toStartOfWeek().addDays(6),
            pse__Sunday_Hours__c = 0.0,
            pse__Monday_Hours__c = 8.0,
            pse__Tuesday_Hours__c = 8.0,
            pse__Wednesday_Hours__c = 8.0,
            pse__Thursday_Hours__c = 8.0,
            pse__Friday_Hours__c = 8.0,
            pse__Saturday_Hours__c = 0.0,
            pse__Status__c = 'Saved',
            pse__Approver__c = null,
            pse__Billable__c = false
        );
        
        insert timecard;
        
        //Insert a Timecard record
        pse__Timecard_Header__c timecard2 = new pse__Timecard_Header__c(
            pse__Project__c = boboTheBear.Id,
            pse__Resource__c = darthVader.Id,
            pse__Start_Date__c = Date.today().toStartOfWeek().addDays(7),
            pse__End_Date__c = Date.today().toStartOfWeek().addDays(13),
            pse__Sunday_Hours__c = 0.0,
            pse__Monday_Hours__c = 8.0,
            pse__Tuesday_Hours__c = 8.0,
            pse__Wednesday_Hours__c = 8.0,
            pse__Thursday_Hours__c = 8.0,
            pse__Friday_Hours__c = 8.0,
            pse__Saturday_Hours__c = 0.0,
            pse__Status__c = 'Saved',
            pse__Approver__c = null,
            pse__Billable__c = false
        );
        
        insert timecard2;
        
        //Insert PSA Approval Process Settings
        appirio_core__Config_Group__c testSettingGroup = new appirio_core__Config_Group__c(
            Name = 'Timecard',
            appirio_core__Key__c = 'Timecard-test');
        insert testSettingGroup;
        
        appirio_core__Config_Option__c testSettingOption = new appirio_core__Config_Option__c(
            Name = 'timecard-auto-submit-for-approval',
            appirio_core__Config_Group__c = testSettingGroup.Id,
            appirio_core__Allow_Multiple_Values__c = false,
            appirio_core__Type__c = 'Boolean'
        );
        insert testSettingOption;
        
        appirio_core__Config_Value__c testSettingValue = new appirio_core__Config_Value__c(
            appirio_core__Value__c = 'false',
            appirio_core__Config_Option__c = testSettingOption.Id
        );
        
    }*/
    
    @isTest
    public static void testTimecardApproval () {
        
        //Insert our Region
        pse__Region__c globalRegion = new pse__Region__c();
        globalRegion.Name = 'Test Region';
        insert globalRegion;
        
        //Insert Permission Control
        pse__Permission_Control__c pControl = new pse__Permission_Control__c();
        pControl.pse__User__c = UserInfo.getUserId();
        pControl.pse__Region__c = globalRegion.Id;
        pControl.pse__Timecard_Entry__c = true;
        pControl.pse__Timecard_Ops_Edit__c = true;
        pControl.pse__Cascading_Permission__c = true;
        insert pControl;
        
        //Create a PSA Project record
        pse__Proj__c boboTheBear = new pse__Proj__c();
        boboTheBear.name = 'Bobo the Bear';
        boboTheBear.pse__Region__c = globalRegion.Id;
        boboTheBear.CurrencyIsoCode = 'USD';
        boboTheBear.Capitalizable__c = true;
        boboTheBear.pse__Is_Active__c = true;
        boboTheBear.pse__Allow_Timecards_Without_Assignment__c = true;
        boboTheBear.pse__Billing_Type__c = 'Fixed Price';
        boboTheBear.pse__Closed_for_Time_Entry__c = false;
        insert boboTheBear;
        
        //Grab a Profile for our Test User
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Specialist'];
        User anakinSkywalker = testUtilities.CreateNewUser(p, true);
        anakinSkywalker.LastName = 'Skywalker';
        update anakinSkywalker;
        
        //Insert a Contact
        Contact darthVader = TestUtilities.CreateNewContact(true);
        darthVader.pse__Salesforce_User__c = anakinSkywalker.Id;
        darthVader.pse__Is_Resource__c = true;
        darthVader.pse__Is_Resource_Active__c = true;
        darthVader.pse__Region__c = globalRegion.Id;
        update darthVader;
        
        //Insert a Timecard record
        pse__Timecard_Header__c timecard = new pse__Timecard_Header__c(
            pse__Project__c = boboTheBear.Id,
            pse__Resource__c = darthVader.Id,
            pse__Start_Date__c = Date.today().toStartOfWeek(),
            pse__End_Date__c = Date.today().toStartOfWeek().addDays(6),
            pse__Sunday_Hours__c = 0.0,
            pse__Monday_Hours__c = 8.0,
            pse__Tuesday_Hours__c = 8.0,
            pse__Wednesday_Hours__c = 8.0,
            pse__Thursday_Hours__c = 8.0,
            pse__Friday_Hours__c = 8.0,
            pse__Saturday_Hours__c = 0.0,
            pse__Status__c = 'Saved',
            pse__Approver__c = null,
            pse__Billable__c = false
        );
        
        insert timecard;
        
        //Insert a Timecard record
        pse__Timecard_Header__c timecard2 = new pse__Timecard_Header__c(
            pse__Project__c = boboTheBear.Id,
            pse__Resource__c = darthVader.Id,
            pse__Start_Date__c = Date.today().toStartOfWeek().addDays(7),
            pse__End_Date__c = Date.today().toStartOfWeek().addDays(13),
            pse__Sunday_Hours__c = 0.0,
            pse__Monday_Hours__c = 8.0,
            pse__Tuesday_Hours__c = 8.0,
            pse__Wednesday_Hours__c = 8.0,
            pse__Thursday_Hours__c = 8.0,
            pse__Friday_Hours__c = 8.0,
            pse__Saturday_Hours__c = 0.0,
            pse__Status__c = 'Saved',
            pse__Approver__c = null,
            pse__Billable__c = false
        );
        
        insert timecard2;
        
        //Start our Test after Data loads
        Test.startTest();
        
        //Query for our Project record
        pse__proj__c testProject = [SELECT Id FROM pse__proj__c WHERE Name = 'Bobo the Bear'];
        
        //Update our PSA Settings accordingly
        appirio_core__Config_Value__c testSetting = [SELECT Id, appirio_core__Config_Option__c FROM appirio_core__Config_Value__c WHERE appirio_core__Config_Option__r.Name = 'timecard-auto-submit-for-approval'];
        testSetting.appirio_core__Value__c = 'false';
        update testSetting;
        
        //Query for our Timecard
        List<pse__Timecard_Header__c> testTimecards = [SELECT Id FROM pse__Timecard_Header__c WHERE pse__Project__c = :testProject.Id];
        
        //Set our Timecards
        ApexPages.StandardSetController stdController = new ApexPages.StandardSetController(testTimecards);
        TimecardApprovalListController timecardController = new TimecardApprovalListController(stdController);
        
        //Run our Method without any selected records
        timecardController.validateApprovalList();
        
        //Test for our Error Message
        boolean isMessageFound = false;

        List<ApexPages.Message> msgs = ApexPages.getMessages();
            for(Apexpages.Message msg:msgs){
                if (msg.getDetail() == ('No records selected. Please select at least one record to approve.'))
                     isMessageFound = true;
                        }
        system.assertEquals(true, isMessageFound);
        
        //Code Coverage :)
        timecardController.back();
        
        //Create our Approval Process submittals in Apex
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
		req1.setComments('Submitting request for approval.');
        req1.setObjectId(testTimecards[0].id);
        req1.setSubmitterId(anakinSkywalker.Id);
        req1.setProcessDefinitionNameOrId('PSA_R_D_Time_Approval');
        req1.setSkipEntryCriteria(true);
        
        Approval.ProcessSubmitRequest req2 = new Approval.ProcessSubmitRequest();
		req2.setComments('Submitting request for approval.');
        req2.setObjectId(testTimecards[1].id);
		req2.setSubmitterId(anakinSkywalker.Id);
        req2.setProcessDefinitionNameOrId('PSA_R_D_Time_Approval');
        req2.setSkipEntryCriteria(true);

		//Submit our Requests
        Approval.ProcessResult result = Approval.process(req1);
        Approval.ProcessResult result2 = Approval.process(req2);
        
        //Query for our Timecard
        List<pse__Timecard_Header__c> testTimecards2 = [SELECT Id FROM pse__Timecard_Header__c WHERE pse__Project__c = :testProject.Id];
        
        //Set our Timecards
        ApexPages.StandardSetController stdController2 = new ApexPages.StandardSetController(testTimecards2);
        TimecardApprovalListController timecardController2 = new TimecardApprovalListController(stdController2);
        
        //Set our records
        stdController2.setSelected(testTimecards2);
        
        //Run our Method without any selected records
        timecardController2.validateApprovalList();
        
    }

}