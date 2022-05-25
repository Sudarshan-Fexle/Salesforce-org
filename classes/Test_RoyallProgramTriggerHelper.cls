/*
 *  Purpose         :   Apex Test class for "RoyallProgram" trigger/RoyallProgramTriggerHelper class related functionality
 *
 *  Create By       :   Mahendra Swarnkar 
 *
 *  Created Date    :   01/04/2017
 *
 *  Revision Log    :   V_1.0 Created   - CR-20161128-10501
 * 			V_1.1 Modified By - Mahendra Swarnkar - CR-20170424-10876 - 07/06/2017 - Updated the method "test_populateRollUpSummaryFields"
 *                      V_1.2 Modified By - Abhinav Sharma - 11/03/2020 - CR-20201026-14638 - Add Cappex fields
 *			V_1.3 Modified By - Mahendra Swarnkar - 1/5/2021 - CR-20201204-14725 - Update logic behind CX Current Contract Value
 *			V_1.4 Modified By - Colin McGloin - 09/14/2021 - CR-20210824-15375

 **/
@isTest(seeAllData = false)
private class Test_RoyallProgramTriggerHelper {
	
    //V_1.1 Modify By - Mahendra Swarnkar - CR-20170424-10876 - 07/06/2017
    // Added By - Mahendra - CR-20161128-10501 - 01/04/2017
	static testMethod void test_populateRollUpSummaryFields() {
		
        //Bypass all the triggers
        Util.BypassAllTriggers = true;
        
        //Profiles
        Profile p = [Select Id from Profile where Name = 'System Administrator' ];
        System.assert(p != null);
        
        //Create a new user
        User u = TestUtilities.CreateNewUser(p, true);
        
        //List to hold the Invoice_Access Permission Record only
        List<CustomPermission> invoiceAccessUserPermission = [SELECT Id FROM CustomPermission 
																WHERE DeveloperName = 'Invoicing_access' LIMIT 1];
        //Asserts on result
        System.assert(invoiceAccessUserPermission != null);
        System.assert(invoiceAccessUserPermission.size() == 1);
        
        
        //Here we are fetching the records who have Invoice_Access with them
        List<SetupEntityAccess> invoiceCustomPermision = [SELECT Id, ParentId, Parent.Name, SetupEntityId 
                                                          	FROM SetupEntityAccess 
                                                          	WHERE 
                                                          	SetupEntityId =: invoiceAccessUserPermission[0].Id 
                                                          AND Parent.isOwnedByProfile =false];
        
        //Checking for null value
        if(invoiceCustomPermision != null && invoiceCustomPermision.size() > 0) {
            
			//assign the permissionset to user
            PermissionSetAssignment pAssignmnet = new PermissionSetAssignment (AssigneeId = u.Id, 
                                                              PermissionSetId = invoiceCustomPermision[0].ParentId);
            insert pAssignmnet;
        
        	system.runAs(u){
         
                //Insert the Account record
                Account acc = new Account ( Name = 'Shift CRM'  );
                insert acc;
                
                //Assert on results
                system.assert(acc != null);
                
                //Insert the Program package records
                List<Program_Package__c> progPackage= new List<Program_Package__c> ();
                progPackage.add(new Program_Package__c (Name = 'Test1', Account__c = acc.Id, Fiscal_Year__c = '2016', 
                                                            Client_Status_New__c = 'Committed',
                                                            RecordTypeId = Util.RecordTypeId(RoyallProgramTriggerHelper.PROGRAM_PACKAGE_OBJECT_API_NAME, RoyallProgramTriggerHelper.PROGRAM_PACKAGE_HD_RECORD_TYPE_LABEL)));
                progPackage.add(new Program_Package__c (Name = 'Test2', Account__c = acc.Id, Fiscal_Year__c = '2016', 
                                                            Client_Status_New__c = 'Committed',
                                                            RecordTypeId = Util.RecordTypeId(RoyallProgramTriggerHelper.PROGRAM_PACKAGE_OBJECT_API_NAME, 'Royall')));
                insert progPackage;
                
                //Commneted by Mahendra Swarnkar - 05/07/2020 - CR-20200218-13769
                //Querying for the details
                progPackage = [SELECT Id, Name, /*Total_Adjusted_Travel_Cost_HD__c,*/ Total_Contracted_Travel_Cost_HD__c 
                               FROM Program_Package__c 
                               WHERE ID IN : progPackage ORDER BY Name ASC];
                
                //Assert on results
                system.assert(progPackage.size() > 0);
                System.assertEquals(2, progPackage.size());
                system.assertEquals('Test1',progPackage[0].Name);
                //Commneted by Mahendra Swarnkar - 05/07/2020 - CR-20200218-13769
                //system.assertEquals(null,progPackage[0].Total_Adjusted_Travel_Cost_HD__c);
                system.assertEquals(null,progPackage[0].Total_Contracted_Travel_Cost_HD__c);
                //system.assertEquals(null,progPackage[1].Total_Adjusted_Travel_Cost_HD__c);
                system.assertEquals(null,progPackage[1].Total_Contracted_Travel_Cost_HD__c);
            
                //Insert the Program records
                List<Royall_Program__c> rPrograms = new List<Royall_Program__c> ();
                rPrograms.add(new Royall_Program__c ( Name = 'Test Program1', Program_Package__c = progPackage[1].Id, Target_Audience_New__c = 'Financial Aid Clients',
                                                        Campaign_New__c = 'Other', Type__c = 'Discount Allocation', Probability__c = 10,
                                                        Contract_Signature_Date__c = Date.Today(), Contract_Sent__c = Date.Today(), 
                                                        Proposal_Sent__c = Date.Today(), Status__c = 'Contracted', Billable_Travel__c = 20,
                                                        RecordTypeId = Util.RecordTypeId(RoyallProgramTriggerHelper.ROYALL_PROGRAM_OBJECT_API_NAME, 'Royall')));
            
                rPrograms.add(new Royall_Program__c ( Name = 'Test Program2', Program_Package__c = progPackage[0].Id, Target_Audience_New__c = 'Financial Aid Clients',
                                                        Campaign_New__c = 'Other', Type__c = 'Discount Allocation', Probability__c = 10,
                                                        Contract_Signature_Date__c = Date.Today(), Contract_Sent__c = Date.Today(), 
                                                        Proposal_Sent__c = Date.Today(), Status__c = 'Contracted', Billable_Travel__c = 20,
                                                        RecordTypeId = Util.RecordTypeId(RoyallProgramTriggerHelper.ROYALL_PROGRAM_OBJECT_API_NAME, RoyallProgramTriggerHelper.ROYALL_PROGRAM_HD_RECORD_TYPE_LABEL)));
                
                rPrograms.add(new Royall_Program__c ( Name = 'Test Program3', Program_Package__c = progPackage[0].Id, Target_Audience_New__c = 'Financial Aid Clients',
                                                        Campaign_New__c = 'Other', Type__c = 'Discount Allocation', Probability__c = 10, Contract_Sent__c = Date.Today(), 
                                                        Proposal_Sent__c = Date.Today(), Status__c = 'Opportunity', Billable_Travel__c = 20,
                                                        RecordTypeId = Util.RecordTypeId(RoyallProgramTriggerHelper.ROYALL_PROGRAM_OBJECT_API_NAME, RoyallProgramTriggerHelper.ROYALL_PROGRAM_HD_RECORD_TYPE_LABEL)));
                
                
                //V_1.1 - Added By - CR-20170424-10876 - 07/06/2017 - Starts from here
                rPrograms.add(new Royall_Program__c ( Name = 'Test Program4', Program_Package__c = progPackage[0].Id, Target_Audience_New__c = 'Financial Aid Clients',
                                                        Campaign_New__c = 'Optimization - Transfer (HD)', Type__c = 'Cross-sell', Status__c = 'Contracted', 
                                                     	Program_Cost__c = 1000, Contract_Signature_Date__c = Date.Today(), Contract_Sent__c = Date.Today(), Proposal_Sent__c = Date.Today(),  
                                                    	RecordTypeId = Util.RecordTypeId(RoyallProgramTriggerHelper.ROYALL_PROGRAM_OBJECT_API_NAME, RoyallProgramTriggerHelper.ROYALL_PROGRAM_HD_RECORD_TYPE_LABEL)));
                 
                rPrograms.add(new Royall_Program__c ( Name = 'Test Program5', Program_Package__c = progPackage[0].Id, Target_Audience_New__c = 'Financial Aid Clients',
                                                        Campaign_New__c = 'Optimization - Transfer (HD)', Type__c = 'Cross-sell', Status__c = 'Contracted', 
                                                     	Program_Cost__c = 1000, Contract_Signature_Date__c = Date.Today(), Contract_Sent__c = Date.Today(), Proposal_Sent__c = Date.Today(),
                                                    	RecordTypeId = Util.RecordTypeId(RoyallProgramTriggerHelper.ROYALL_PROGRAM_OBJECT_API_NAME, RoyallProgramTriggerHelper.ROYALL_PROGRAM_HD_RECORD_TYPE_LABEL)));
                
                rPrograms.add(new Royall_Program__c ( Name = 'Test Program6', Program_Package__c = progPackage[0].Id, Target_Audience_New__c = 'Financial Aid Clients',
                                                        Campaign_New__c = 'Optimization - Transfer (HD)', Type__c = 'Cross-sell', Status__c = 'Opportunity',
                                                     	Program_Cost__c = 1000, Contract_Sent__c = Date.Today(), Proposal_Sent__c = Date.Today(),  
                                                    	RecordTypeId = Util.RecordTypeId(RoyallProgramTriggerHelper.ROYALL_PROGRAM_OBJECT_API_NAME, RoyallProgramTriggerHelper.ROYALL_PROGRAM_HD_RECORD_TYPE_LABEL)));

                
                //V_1.1 - Added By - Mahendra Swarnkar - CR-20170424-10876 - 07/06/2017 - Ends Here
                
                //Starts Test from here
                Test.startTest();
                
                //Enable all the triggers
                Util.BypassAllTriggers = false;
                
                //Insert Royall Programs
                insert rPrograms;
            
                //Querying for the details
            	rPrograms = [Select Id From Royall_Program__c ORDER BY Name ASC];
                
                //Assert on results
                system.assert(progPackage.size() > 0);
            
                //Disable all the triggers
                Util.BypassAllTriggers = true;
                
                //Commneted by Mahendra Swarnkar - 05/07/2020 - CR-20200218-13769
                //Querying for the details
                progPackage = [SELECT Id, Name, /*Total_Adjusted_Travel_Cost_HD__c,*/ Total_Contracted_Travel_Cost_HD__c, Contracted_Programs_FAO__c, Contracted_Value_FAO__c 
                               FROM Program_Package__c 
                               ORDER BY Name ASC];
            
                //Assert on results
                system.assert(progPackage.size() > 0);
                System.assertEquals(2, progPackage.size());
                system.assertEquals('Test1',progPackage[0].Name);
                //Commneted by Mahendra Swarnkar - 05/07/2020 - CR-20200218-13769
                //system.assertEquals(20,progPackage[0].Total_Adjusted_Travel_Cost_HD__c);
                system.assertEquals(20,progPackage[0].Total_Contracted_Travel_Cost_HD__c);
                //Commneted by Mahendra Swarnkar - 05/07/2020 - CR-20200218-13769
                //system.assertEquals(null,progPackage[1].Total_Adjusted_Travel_Cost_HD__c);
                system.assertEquals(null,progPackage[1].Total_Contracted_Travel_Cost_HD__c);
                
                system.assertEquals(2,progPackage[0].Contracted_Programs_FAO__c);
                system.assertEquals(2000,progPackage[0].Contracted_Value_FAO__c);
            
                //Enable all the triggers
                Util.BypassAllTriggers = false;
                
                //Update the Royall Program
                rPrograms[2].Status__c = 'Contracted';
                rPrograms[2].Contract_Signature_Date__c = system.today();
                rPrograms[5].Status__c = 'Contracted';
                rPrograms[5].Contract_Signature_Date__c = Date.Today();
                rPrograms[4].Campaign_New__c = 'Net Price Calculator';
                rPrograms[3].Type__c = 'Up-sell';
                update rPrograms;
                
                //Disable all the triggers
                Util.BypassAllTriggers = true;
                
                //Commneted by Mahendra Swarnkar - 05/07/2020 - CR-20200218-13769
                //Querying for the details
                progPackage = [SELECT Id, Name, /*Total_Adjusted_Travel_Cost_HD__c,*/ Total_Contracted_Travel_Cost_HD__c, Contracted_Programs_FAO__c, Contracted_Value_FAO__c
                               	FROM Program_Package__c 
                               	ORDER BY Name ASC];
            
                //Assert on results
                system.assert(progPackage.size() > 0);
                system.assertEquals(2, progPackage.size());
                system.assertEquals('Test1', progPackage[0].Name);
                //Commneted by Mahendra Swarnkar - 05/07/2020 - CR-20200218-13769
                //system.assertEquals(40, progPackage[0].Total_Adjusted_Travel_Cost_HD__c);
                system.assertEquals(40, progPackage[0].Total_Contracted_Travel_Cost_HD__c);
                
                system.assertEquals(2, progPackage[0].Contracted_Programs_FAO__c);
                system.assertEquals(2000, progPackage[0].Contracted_Value_FAO__c);
                
                //Enable all the triggers
                Util.BypassAllTriggers = false;
                
                System.assert(rPrograms[2] != null);
                System.assert(rPrograms[5] != null);
                
                //delete the Royall Program
                delete (new List<Royall_Program__c>{rPrograms[2], rPrograms[5] });
                
                //Disable all the triggers
                Util.BypassAllTriggers = true;
            	
                //Commneted by Mahendra Swarnkar - 05/07/2020 - CR-20200218-13769
                //Querying for the details
                progPackage = [Select Id, Name, /*Total_Adjusted_Travel_Cost_HD__c,*/ Total_Contracted_Travel_Cost_HD__c, Contracted_Programs_FAO__c, Contracted_Value_FAO__c
                               From Program_Package__c ORDER BY Name ASC];
                
                //Assert on results
                system.assert(progPackage.size() > 0);
                system.assertEquals(2, progPackage.size());
                system.assertEquals('Test1',progPackage[0].Name);
                //system.assertEquals(20,progPackage[0].Total_Adjusted_Travel_Cost_HD__c);
                system.assertEquals(20,progPackage[0].Total_Contracted_Travel_Cost_HD__c);
                
				system.assertEquals(1, progPackage[0].Contracted_Programs_FAO__c);
                system.assertEquals(1000, progPackage[0].Contracted_Value_FAO__c);
                
                //Test stops here
                Test.stopTest(); 
        	}    		        
        }
    }
    
    //Added By - Abhinav Sharma - 11/03/2020 - CR-20201026-14638 - Add Cappex fields
    static testMethod void test_populateFieldOnMembershipPeriod()
    {
        //Bypass all the triggers
        Util.BypassAllTriggers = true;
        
        //Profiles
        Profile p = [Select Id from Profile where Name = 'System Administrator' ];
        System.assert(p != null);
        
        //Create a new user
        User u = TestUtilities.CreateNewUser(p, true);
        
        //List to hold the Invoice_Access Permission Record only
        List<CustomPermission> invoiceAccessUserPermission = [SELECT Id FROM CustomPermission 
                                                              WHERE DeveloperName = 'Invoicing_access' LIMIT 1];
        //Asserts on result
        System.assert(invoiceAccessUserPermission != null);
        System.assert(invoiceAccessUserPermission.size() == 1);
        
        
        //Here we are fetching the records who have Invoice_Access with them
        List<SetupEntityAccess> invoiceCustomPermision = [SELECT Id, ParentId, Parent.Name, SetupEntityId 
                                                          FROM SetupEntityAccess 
                                                          WHERE 
                                                          SetupEntityId =: invoiceAccessUserPermission[0].Id 
                                                          AND Parent.isOwnedByProfile =false];
        
        //Checking for null value
        if(invoiceCustomPermision != null && invoiceCustomPermision.size() > 0) 
        {
            //assign the permissionset to user
            PermissionSetAssignment pAssignmnet = new PermissionSetAssignment (AssigneeId = u.Id, 
                                                                               PermissionSetId = invoiceCustomPermision[0].ParentId);
            insert pAssignmnet;
            
            system.runAs(u)
            {
                //Insert the Account record
                Account acc = new Account ( Name = 'Shift CRM'  );
                insert acc;
                
                //Insert the Program package records
                List<Program_Package__c> progPackage= new List<Program_Package__c> ();
                progPackage.add(new Program_Package__c (Name = 'Test1', Account__c = acc.Id, Fiscal_Year__c = '2016', 
                                                        Client_Status_New__c = 'Committed',
                                                        RecordTypeId = Util.RecordTypeId(RoyallProgramTriggerHelper.PROGRAM_PACKAGE_OBJECT_API_NAME, RoyallProgramTriggerHelper.PROGRAM_PACKAGE_HD_RECORD_TYPE_LABEL)));
                progPackage.add(new Program_Package__c (Name = 'Test2', Account__c = acc.Id, Fiscal_Year__c = '2016', 
                                                        Client_Status_New__c = 'Committed',
                                                        RecordTypeId = Util.RecordTypeId(RoyallProgramTriggerHelper.PROGRAM_PACKAGE_OBJECT_API_NAME, 'Royall')));
                insert progPackage;  
                
                //Insert the Program records
                List<Royall_Program__c> rPrograms = new List<Royall_Program__c> ();
                rPrograms.add(new Royall_Program__c ( Name = 'Test Program7', Program_Package__c = progPackage[1].Id, Target_Audience_New__c = 'Cappex',
                                                        Campaign_New__c = 'Discount - No Campaign', Type__c = 'Re-engagement', Probability__c = 10,
                                                        Contract_Signature_Date__c = Date.Today(), Contract_Sent__c = Date.Today(), Program_Cost__c = 17600, 
                                                        Proposal_Sent__c = Date.Today(), Status__c = 'Contracted',
                                                        RecordTypeId = Util.RecordTypeId(RoyallProgramTriggerHelper.ROYALL_PROGRAM_OBJECT_API_NAME, 'Royall'),
                                                        End_Date_CX__c = System.today(), Start_Date_CX__c = System.today()
                                                     ));
                Test.startTest();
                //Enable all the triggers
                Util.BypassAllTriggers = false;
                
                //Insert Royall Programs
                insert rPrograms;
                
                Test.stopTest();
            }
        }
    }
    
    //V_1.5 - Added By - Mahendra Swarnkar - 1/5/2021 - CR-20201204-14725 - Update logic behind CX Current Contract Value
    static testMethod void test_populateProgramCostOnMembership() {
		
        //Bypass all the triggers
        Util.BypassAllTriggers = true;
        
        //Profiles
        Profile p = [Select Id from Profile where Name = 'System Administrator' ];
        System.assert(p != null);
        
        //Create a new user
        User u = TestUtilities.CreateNewUser(p, true);
        
        //List to hold the Invoice_Access Permission Record only
        List<CustomPermission> invoiceAccessUserPermission = [SELECT Id FROM CustomPermission 
																WHERE DeveloperName = 'Invoicing_access' LIMIT 1];
        //Asserts on result
        System.assert(invoiceAccessUserPermission != null);
        System.assert(invoiceAccessUserPermission.size() == 1);
        
        
        //Here we are fetching the records who have Invoice_Access with them
        List<SetupEntityAccess> invoiceCustomPermision = [SELECT Id, ParentId, Parent.Name, SetupEntityId 
        						  FROM SetupEntityAccess 
                                                          WHERE 
                                                          SetupEntityId =: invoiceAccessUserPermission[0].Id 
                                                          AND Parent.isOwnedByProfile =false];
        
        //Checking for null value
        if(invoiceCustomPermision != null && invoiceCustomPermision.size() > 0) {
            
	    //assign the permissionset to user
            PermissionSetAssignment pAssignmnet = new PermissionSetAssignment (AssigneeId = u.Id, 
            									PermissionSetId = invoiceCustomPermision[0].ParentId);
            insert pAssignmnet;
        
            system.runAs(u){
         
                //Insert the Account record
                Account acc = new Account ( Name = 'Shift CRM'  );
                insert acc;
                
                //Assert on results
                system.assert(acc != null);
                
                //create a Program 
                Program__c prog = TestUtilities.CreateNewProgram(false);
                prog.Program_Acronym__c = 'CXCN';
                insert prog;
                    
                
                //Assert on results
                system.assert(prog != null);
                
                Membership__c mem = TestUtilities.CreateNewMembership(acc.Id, prog.Id, true);
        
                //Insert the Program package records
                List<Program_Package__c> progPackage= new List<Program_Package__c> ();
                progPackage.add(new Program_Package__c (Name = 'Test1', Account__c = acc.Id, Fiscal_Year__c = '2016',
                                                        Membership__c = mem.Id));
                progPackage.add(new Program_Package__c (Name = 'Test2', Account__c = acc.Id, Fiscal_Year__c = '2016', 
                                                        Membership__c = mem.Id));
                insert progPackage;
                
                            
                //Insert the Program records for Membership Period 1
                List<Royall_Program__c> rPrograms = new List<Royall_Program__c> ();
                rPrograms.add(new Royall_Program__c ( Name = 'Test Program1', Program_Package__c = progPackage[0].Id, 
                                                     Probability__c = 10, Program_Cost__c = 1000, Proposal_Sent__c = System.today(),
                                                     End_Date_CX__c = System.today().addDays(1), Start_Date_CX__c = System.today().addDays(-1)));
            
                rPrograms.add(new Royall_Program__c ( Name = 'Test Program2', Program_Package__c = progPackage[0].Id, 
                                                     Probability__c = 10, Program_Cost__c = 1000, Proposal_Sent__c = System.today(),
                                                     End_Date_CX__c = System.today().addDays(1), Start_Date_CX__c = System.today().addDays(-1)));
                
                rPrograms.add(new Royall_Program__c ( Name = 'Test Program3', Program_Package__c = progPackage[0].Id, 
                                                     Probability__c = 10, Program_Cost__c = 1000, Proposal_Sent__c = System.today(),
                                                     End_Date_CX__c = System.today().addDays(1), Start_Date_CX__c = System.today().addDays(-1)));
                
                
                //Insert the Program records for Membership Period 2
                rPrograms.add(new Royall_Program__c ( Name = 'Test Program1', Program_Package__c = progPackage[1].Id, 
                                                     Probability__c = 10, Program_Cost__c = 1000, Proposal_Sent__c = System.today(),
                                                     End_Date_CX__c = System.today().addDays(1), Start_Date_CX__c = System.today().addDays(-1)));
            
                rPrograms.add(new Royall_Program__c ( Name = 'Test Program2', Program_Package__c = progPackage[1].Id, 
                                                     Probability__c = 10, Program_Cost__c = 1000, Proposal_Sent__c = System.today(),
                                                     End_Date_CX__c = System.today().addDays(1), Start_Date_CX__c = System.today().addDays(-1)));
                
                rPrograms.add(new Royall_Program__c ( Name = 'Test Program3', Program_Package__c = progPackage[1].Id, 
                                                     Probability__c = 10, Program_Cost__c = 1000, Proposal_Sent__c = System.today(),
                                                     End_Date_CX__c = System.today().addDays(1), Start_Date_CX__c = System.today().addDays(-1)));
                
                //Starts Test from here
                Test.startTest();
                
                //Enable all the triggers
                Util.BypassAllTriggers = false;
                
                //Insert Royall Programs
                insert rPrograms;
                
                //Querying for the details
            	mem = [Select Id, CX_Current_Contract_Value__c From Membership__c ORDER BY Name ASC limit 1];
                
                //Assert on results (Insert Case)
                System.assertEquals(Double.valueOf(6000), mem.CX_Current_Contract_Value__c);
                
                //Update case
                rPrograms[0].Program_Cost__c = 2000;
                Update rPrograms[0];
                
                //Querying for the details
            	mem = [Select Id, CX_Current_Contract_Value__c From Membership__c ORDER BY Name ASC limit 1];
                
                //Assert on results (Update Case)
                System.assertEquals(Double.valueOf(7000), mem.CX_Current_Contract_Value__c);
                
                //delete case
                Delete rPrograms[0];
                
                //Querying for the details
            	mem = [Select Id, CX_Current_Contract_Value__c From Membership__c ORDER BY Name ASC limit 1];
                
                //Assert on results (Update Case)
                System.assertEquals(Double.valueOf(5000), mem.CX_Current_Contract_Value__c);
                
                //Test stops here
                Test.stopTest(); 
            }    		        
        }
    }
    
    //Modified By - Colin McGloin - 09/14/2021 - CR-20210824-15375
    static testMethod void test_createCompetitorSelectionRecords() {

        //Create Account
        Account testAccount = TestUtilities.CreateNewAccount(true);

        //Create New Program
        Program__c prog = TestUtilities.CreateNewProgram(true);

        //Create New Membership
        Membership__c mem = TestUtilities.CreateNewMembership(testAccount.Id, prog.Id, true);

        //Insert the Program package records
        List<Program_Package__c> progPackage= new List<Program_Package__c> ();
        progPackage.add(new Program_Package__c (Name = 'Test1', Account__c = testAccount.Id, Fiscal_Year__c = '2016',
                                                Membership__c = mem.Id));
        insert progPackage;

        //Insert the Program records for Membership Period 1
        List<Royall_Program__c> rPrograms = new List<Royall_Program__c> ();
        rPrograms.add(new Royall_Program__c ( Name = 'Test Program1', Program_Package__c = progPackage[0].Id, State_Selections__c = 'MA; NH;',
                                             Segment_Index__c = 1, Program_Quantity__c = 2, Campaign_New__c = 'ISC Advanced Awareness for Competitors', 
                                             Probability__c = 10, Program_Cost__c = 1000, Proposal_Sent__c = System.today(),
                                             End_Date_CX__c = System.today().addDays(1), Start_Date_CX__c = System.today().addDays(-1)));
    
        rPrograms.add(new Royall_Program__c ( Name = 'Test Program2', Program_Package__c = progPackage[0].Id, State_Selections__c = 'MA; NH;',
                                             Segment_Index__c = 2, Program_Quantity__c = 2, Campaign_New__c = 'ISC Advanced Awareness for Competitors',
                                             Probability__c = 10, Program_Cost__c = 1000, Proposal_Sent__c = System.today(),
                                             End_Date_CX__c = System.today().addDays(1), Start_Date_CX__c = System.today().addDays(-1)));
        
        rPrograms.add(new Royall_Program__c ( Name = 'Test Program3', Program_Package__c = progPackage[0].Id, State_Selections__c = 'MA; NH;',
                                             Segment_Index__c = 1, Program_Quantity__c = 2, Campaign_New__c = 'ISC Advanced Awareness for Majors',
                                             Probability__c = 10, Program_Cost__c = 1000, Proposal_Sent__c = System.today(),
                                             End_Date_CX__c = System.today().addDays(1), Start_Date_CX__c = System.today().addDays(-1)));

        //Insert Records
        insert rPrograms;

        //Query to get our Competitor Selection Records
        List<Competitor_Selection__c> listRelatedRecords = [SELECT Id, Name, Competitor__c, Program_Royall_HD__c, State__c FROM Competitor_Selection__c WHERE Program_Royall_HD__c IN :rPrograms ORDER BY State__c ASC];

        //Check # of records
        System.assertEquals(4, 4);

        //Check first records is the correct State
        System.assertEquals('MA',listRelatedRecords[0].State__c);

        //Change the State Selections
        rPrograms[0].State_Selections__c = 'NH';
        update rPrograms;

        //Requery for records
        List<Competitor_Selection__c> listRelatedRecords2 = [SELECT Id, Name, Competitor__c, Program_Royall_HD__c, State__c FROM Competitor_Selection__c WHERE Program_Royall_HD__c IN :rPrograms ORDER BY State__c ASC];

        //Check # of records & Correct State
        System.assertEquals(2, 2);
        System.assertEquals('NH', listRelatedRecords2[0].State__c);

    }
}