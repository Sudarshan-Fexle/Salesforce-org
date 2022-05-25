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
 * methods. Classes defined with the @isTest annmyUnitTestotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest(seeAllData = false)
private class Test_AssignNewGoalsToPlansController {
/**
 *   Purpose         :   Test class for AssignNewGoalsToPlansController
 *            
 *   Create By       :   Subhash Garhwal
 *
 *   Created Date    :   10/22/2015
 *
 *   Revision Log    :   V_1.0 - Created - CR-20150729-9114
 *                       V_1.1 - Modified - Subhash Garhwal - 12/18/2015 - ISSP Deployment C.
 *                       V_1.2 - Modified - Rajeev Jain - 05/10/2016 - ISSP Deployment E - improved asserts, Improved code coverage from 78% to 90%
 *
 *   Coverage        :   90%
 **
   
    //Test method
    static testMethod void myUnitTest() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //Create an Account
        Account account = TestUtilities.CreateNewAccount(false);
        
        //Insert
        insert account;
        
        //Assert
        System.assert(account != null);
        
        //LiSt of contact
        List<Contact> contacts = new List<Contact>();
        
        //Create a Contact
        contacts.add(new Contact(FirstName = 'Test 1', LastName = 'Contact 1', Email = 'test@test.com', AccountId = account.Id, Employee_User_Record__c = Userinfo.getUserId(),  Title = 'Test', Phone = '614-555-8855'));
        contacts.add(new Contact(FirstName = 'Test 2', LastName = 'Contact 2', Email = 'test@test.com', AccountId = account.Id, Employee_User_Record__c = Userinfo.getUserId(),  Title = 'Test', Phone = '614-555-8855'));
        contacts.add(new Contact(FirstName = 'Test 3', LastName = 'Contact 3', Email = 'test@test.com', AccountId = account.Id, Employee_User_Record__c = Userinfo.getUserId(),  Title = 'Test', Phone = '614-555-8855'));
        contacts.add(new Contact(FirstName = 'Test 4', LastName = 'Contact 4', Email = 'test@test.com', AccountId = account.Id, Employee_User_Record__c = Userinfo.getUserId(),  Title = 'Test', Phone = '614-555-8855'));
        contacts.add(new Contact(FirstName = 'Test 4', LastName = 'Contact 5', Email = 'test@test.com', AccountId = account.Id, Employee_User_Record__c = Userinfo.getUserId(),  Title = 'Test', Phone = '614-555-8855'));
        
        //Insert
        insert contacts;
        
        //Assert
        System.assert(contacts.size() > 0);
            
        //Create Goal Types
        List<Goal_Type__c> goalTypes = new List<Goal_Type__c>();
        
        //Add new goal type in list
        goalTypes.add(new Goal_Type__c(Name = 'GT 1', Active__c = true, Standard_Goal__c = true, Base_Process__c = 'NBB', Description__c = 'Testing of Goal Type'));
        goalTypes.add(new Goal_Type__c(Name = 'GT 2', Active__c = true, Standard_Goal__c = true, Base_Process__c = 'CM', Description__c = 'Testing of Goal Types'));
        goalTypes.add(new Goal_Type__c(Name = 'GT 3', Active__c = true, Standard_Goal__c = true, Base_Process__c = 'Activity', Description__c = 'Testing of Goal'));
        goalTypes.add(new Goal_Type__c(Name = 'GT 4', Active__c = true, Standard_Goal__c = true, Base_Process__c = 'Renewal', Description__c = 'Goal Type'));
        
        //Insert 
        insert goalTypes;
        
        //Assert
        System.assert(goalTypes.size() > 0);
        
        //List Of Rate Tempate
        List<Rate_Template__c> rateTemplates = new List<Rate_Template__c>();
        
        //Insert Rate Template
        rateTemplates.add(new Rate_Template__c(Name = 'RT 1', Active__c = true));
        rateTemplates.add(new Rate_Template__c(Name = 'RT 2', Active__c = true));
        rateTemplates.add(new Rate_Template__c(Name = 'RT 3', Active__c = true));
        
        //Insert
        insert rateTemplates;
        
        //Assert
        System.assert(rateTemplates.size() > 0);
        
        //Create Standard Goals
        List<Standard_Goal__c> goalTemplates = new List<Standard_Goal__c>();
        
        //Add new Standard Goals in list
        goalTemplates.add(new Standard_Goal__c(Name = 'GT 1', Active__c = true, Amount__c = 100, Business_Owner__c = contacts[0].Id,
                                               Description__c = 'Testing of goal Templates', Goal_Type__c = goalTypes[0].Id, 
                                               Period_Start__c = System.today(), Period_End__c = System.today().addDays(4)));
        goalTemplates.add(new Standard_Goal__c(Name = 'GT 2', Active__c = true, Amount__c = 200, Business_Owner__c = contacts[0].Id,
                                               Description__c = 'Testing of goal Templates', Goal_Type__c = goalTypes[1].Id,
                                               Period_Start__c = System.today().addDays(10), Period_End__c = System.today().addDays(20)));
        goalTemplates.add(new Standard_Goal__c(Name = 'GT 3', Active__c = false, Amount__c = 300, Business_Owner__c = contacts[0].Id,
                                               Description__c = 'Testing of goal Templates', Goal_Type__c = goalTypes[1].Id,
                                               Period_Start__c = System.today().addDays(25), Period_End__c = System.today().addDays(30)));
        
        //Insert 
        insert goalTemplates;
        
        //Assert
        System.assert(goalTemplates.size() > 0);
                               
        //Create Standard Goal Details
        List<Standard_Goal_Detail__c> goalTemplateDetails = new List<Standard_Goal_Detail__c>();
        
        //Add new Standard Goal Details in list
        goalTemplateDetails.add(new Standard_Goal_Detail__c(Name = 'GTD 1', Active__c = true, Description__c = 'Testing',Target_Type__c = 'Paced',
                                                            Standard_Goal__c = goalTemplates[0].Id));
        goalTemplateDetails.add(new Standard_Goal_Detail__c(Name = 'GTD 2', Active__c = true, Description__c = 'Testing',Target_Type__c = 'Paced',
                                                            Standard_Goal__c = goalTemplates[0].Id));
        goalTemplateDetails.add(new Standard_Goal_Detail__c(Name = 'GTD 3', Active__c = true, Description__c = 'Testing',Target_Type__c = 'Paced',
                                                            Standard_Goal__c = goalTemplates[1].Id));
        goalTemplateDetails.add(new Standard_Goal_Detail__c(Name = 'GTD 4', Active__c = true, Description__c = 'Testing',Target_Type__c = 'Paced',
                                                            Standard_Goal__c = goalTemplates[1].Id));
        goalTemplateDetails.add(new Standard_Goal_Detail__c(Name = 'GTD 5', Active__c = true, Description__c = 'Testing',Target_Type__c = 'Paced',
                                                            Standard_Goal__c = goalTemplates[2].Id));
        
        //Insert 
        insert goalTemplateDetails;
        
        //Assert
        System.assert(goalTemplateDetails.size() > 0);
        
        //List of Program collections
        List<Program_Group__c> programGroups = new List<Program_Group__c>();
        
        //Add new Program Groups in list
        programGroups.add(new Program_Group__c(Name = 'Test PG 1', Effective_Start__c = System.today().addDays(-3), Effective_End__c = System.today(),
                                               Short_Name__c = 'test1211', Active__c = true));
        programGroups.add(new Program_Group__c(Name = 'Test PG 2', Effective_Start__c = System.today().addDays(-5), Effective_End__c = System.today(),
                                               Active__c = true));
        
        //Insert
        insert programGroups;
        
        //Assert
        System.assert(programGroups.size() > 0);
        
        //List of Perspective
        List<Perspective__c> perspectives = new List<Perspective__c>();
        
        //Add new Perspective record in list
        perspectives.add(new Perspective__c(Name = 'Test Perspective 1', Business_Owner__c = contacts[0].Id, Short_Name__c = '1232Test230', Active__c = true));
        perspectives.add(new Perspective__c(Name = 'Test Perspective 2', Business_Owner__c = contacts[0].Id, Short_Name__c = '1332Test230', Active__c = true));
        
        //Insert
        insert perspectives;
        
        //Assert
        System.assert(perspectives.size() > 0);
        
        //List of Program Perspective
        List<Program_Perspective__c> programPerspectives = new List<Program_Perspective__c>();
        
        //Add new Program Perspective in list
        programPerspectives.add(new Program_Perspective__c(Name = 'PP 1', Program_Group__c = programGroups[0].Id, Perspective__c = perspectives[0].Id,
                                                           Business_Owner__c = contacts[0].Id, Effective_Start__c = System.today(), Effective_End__c = System.today().addDays(4), Active__c = true, In_use_Plans_Direct__c = 2, In_use_Plans_Indirect__c = 2));
        programPerspectives.add(new Program_Perspective__c(Name = 'PP 2', Program_Group__c = programGroups[1].Id, Perspective__c = perspectives[1].Id,
                                                           Business_Owner__c = contacts[0].Id, Effective_Start__c = System.today(), Effective_End__c = System.today().addDays(4), Active__c = true));
        
        //Insert
        insert programPerspectives;
        
        //Assert
        System.assert(programPerspectives.size() > 0);
        
        //List of Value Type
        List<Value_Type__c> valueTypes = new List<Value_Type__c>();
        
        valueTypes.add(new Value_Type__c(Name = 'VT 1', Values_Permitted__c = 'Text',Category__c = 'Business Title', Active__c = true));
        valueTypes.add(new Value_Type__c(Name = 'VT 2', Values_Permitted__c = 'Text', Category__c = 'Incentive Role', Active__c = true));
        valueTypes.add(new Value_Type__c(Name = 'VT 3', Values_Permitted__c = 'Text', Category__c = 'Goals', Active__c = true));
        valueTypes.add(new Value_Type__c(Name = 'VT 4', Values_Permitted__c = 'Program Collection', Category__c = 'Goals', Active__c = true));
        valueTypes.add(new Value_Type__c(Name = 'Tenure', Values_Permitted__c = 'Text', Category__c = 'Other', Active__c = true));
        
        //Insert
        insert valueTypes;
        
        //Assert
        System.assert(programPerspectives.size() > 0);  
        
        //List of Staff History
        List<Staff_History__c> staffHistory = new List<Staff_History__c>();

        //Add new Staff History in list.
        staffHistory.add(new Staff_History__c(Staff_Member__c = contacts[0].Id, Value_Type__c = valueTypes[0].Id, Start_Date__c = System.today().addDays(1), Text_Value__c = 'BT SA'));
        staffHistory.add(new Staff_History__c(Staff_Member__c = contacts[0].Id, Value_Type__c = valueTypes[1].Id, Start_Date__c = System.today().addDays(5), End_Date__c = System.today().addDays(10), Text_Value__c = 'Testing'));
        staffHistory.add(new Staff_History__c(Staff_Member__c = contacts[1].Id, Value_Type__c = valueTypes[1].Id, Start_Date__c = System.today().addDays(15), End_Date__c = System.today().addDays(20), Text_Value__c = 'Testing2'));
        staffHistory.add(new Staff_History__c(Staff_Member__c = contacts[1].Id, Value_Type__c = valueTypes[2].Id, Start_Date__c = System.today().addDays(25), End_Date__c = System.today().addDays(30), Text_Value__c = 'Testing3'));
        staffHistory.add(new Staff_History__c(Staff_Member__c = contacts[2].Id, Value_Type__c = valueTypes[3].Id, Start_Date__c = System.today().addDays(31), End_Date__c = System.today().addDays(35), Lookup_Value__c = programPerspectives[0].Id));
        staffHistory.add(new Staff_History__c(Staff_Member__c = contacts[2].Id, Value_Type__c = valueTypes[4].Id, Start_Date__c = System.today().addDays(36), End_Date__c = System.today().addDays(40), Text_Value__c = 'Testing3'));
        staffHistory.add(new Staff_History__c(Staff_Member__c = contacts[2].Id, Value_Type__c = valueTypes[3].Id, Start_Date__c = System.today().addDays(41), End_Date__c = System.today().addDays(50), Lookup_Value__c = programPerspectives[1].Id));
        staffHistory.add(new Staff_History__c(Staff_Member__c = contacts[0].Id, Value_Type__c = valueTypes[0].Id, Start_Date__c = System.today().addDays(-5), End_Date__c = System.today().addDays(-2), Text_Value__c = 'BT SA'));
        
        //Insert
        insert staffHistory;
        
        //Assert
        System.assert(staffHistory.size() > 0);
        
        //Create Personal Plan
        List<Personal_Plan__c> personalPlans = new List<Personal_Plan__c>();
        
        //Add new Personal Plan in list
        personalPlans.add(new Personal_Plan__c(Name = 'PersonalPlan1', Active__c = true, Description__c = 'Testing', Staff_Member__c = contacts[0].Id,
                                              Plan_Start__c = System.today().addDays(-1), Plan_End__c = System.today().addDays(10)));
        personalPlans.add(new Personal_Plan__c(Name = 'PersonalPlan2', Active__c = true, Description__c = 'Testing', Staff_Member__c = contacts[1].Id,
                                              Plan_Start__c = System.today().addDays(-12), Plan_End__c = System.today().addDays(18)));
        personalPlans.add(new Personal_Plan__c(Name = 'PersonalPlan3', Active__c = true, Description__c = 'Testing', Staff_Member__c = contacts[2].Id,
                                              Plan_Start__c = System.today().addDays(-20),  Plan_End__c = System.today().addDays(80)));
        
        //Insert
        insert personalPlans;
        
        //Assert
        System.assert(personalPlans.size() > 0);
        
        //List of record type
        List<RecordType> recordTypes = [Select Id, DeveloperName From RecordType Where SObjectType = 'Personal_Goal__c' 
                                        AND DeveloperName IN ('Personal_Goal', 'Proposal') ORDER BY DeveloperName ASC LIMIT 2];
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = false;
        
        //Create Personal Goal
        List<Personal_Goal__c> personalGoals = new List<Personal_Goal__c>();
        
        //Add new Personal Goal in list
        personalGoals.add(new Personal_Goal__c(Name = 'PersonalGoal1', Goal_Type__c = goalTypes[0].Id, Active__c = true, RecordTypeId = recordTypes[0].Id,
                                               Description__c = 'Testing1', Amount__c = 100,Personal_Plan__c = personalPlans[2].Id,
                                               Standard_Goal_Detail__c = goalTemplateDetails[0].Id, Rate_Template__c = rateTemplates[0].Id,
                                               Period_Start__c = System.today().addDays(-10), Period_End__c = System.today().addDays(-5),
                                               Payee__c = contacts[1].Id, Status__c = ISSPConstants.PERSONAL_GOAL_STATUS_SUBMITTED));
        
        personalGoals.add(new Personal_Goal__c(Name = 'PersonalGoal2', Goal_Type__c = goalTypes[0].Id, Active__c = true, RecordTypeId = recordTypes[0].Id,
                                               Description__c = 'Testing2', Amount__c = 100,Personal_Plan__c = personalPlans[2].Id,
                                               Standard_Goal_Detail__c = goalTemplateDetails[0].Id, Rate_Template__c = rateTemplates[1].Id,
                                               Period_Start__c = System.today().addDays(-4), Period_End__c = System.today().addDays(-1),
                                               Payee__c = contacts[1].Id, Status__c = ISSPConstants.PERSONAL_GOAL_STATUS_SUBMITTED));
        
        personalGoals.add(new Personal_Goal__c(Name = 'PersonalGoal3', Goal_Type__c = goalTypes[1].Id, Active__c = true, RecordTypeId = recordTypes[0].Id,
                                               Description__c = 'Testing3', Amount__c = 100,Personal_Plan__c = personalPlans[2].Id,
                                               Standard_Goal_Detail__c = goalTemplateDetails[0].Id, Payee__c = contacts[2].Id,
                                               Period_Start__c = System.today(), Period_End__c = System.today().addDays(40), Status__c = ISSPConstants.PERSONAL_GOAL_STATUS_SUBMITTED));
                                                 
        
        personalGoals.add(new Personal_Goal__c(Name = 'PersonalGoal4', Goal_Type__c = goalTypes[1].Id, Active__c = true, RecordTypeId = recordTypes[0].Id,
                                               Value_Type__c = valueTypes[1].Id,Description__c = 'Testing4', Amount__c = 100,Personal_Plan__c = personalPlans[2].Id,
                                               Standard_Goal_Detail__c = goalTemplateDetails[0].Id, Payee__c = contacts[2].Id,
                                               Period_Start__c = System.today().addDays(41), Period_End__c = System.today().addDays(50), Status__c = ISSPConstants.PERSONAL_GOAL_STATUS_SUBMITTED));
        
        personalGoals.add(new Personal_Goal__c(Name = 'PersonalGoal5', Goal_Type__c = goalTypes[2].Id, Active__c = true, RecordTypeId = recordTypes[0].Id, 
                                               Value_Type__c = valueTypes[1].Id, Description__c = 'Testing5', Amount__c = 100,Personal_Plan__c = personalPlans[2].Id,
                                               Standard_Goal_Detail__c = goalTemplateDetails[0].Id, Payee__c = contacts[3].Id,
                                               Period_End__c = System.today().addDays(60), Period_Start__c = System.today(), Status__c = ISSPConstants.PERSONAL_GOAL_STATUS_SUBMITTED));
        
        personalGoals.add(new Personal_Goal__c(Name = 'PersonalGoal6', Goal_Type__c = goalTypes[3].Id, Active__c = true, RecordTypeId = recordTypes[0].Id,  
                                               Description__c = 'Testing6', Amount__c = 100, Standard_Goal_Detail__c = goalTemplateDetails[0].Id,
                                               Period_Start__c = System.today().addDays(61), Status__c = ISSPConstants.PERSONAL_GOAL_STATUS_SUBMITTED,
                                               Period_End__c = System.today().addDays(70), Payee__c = contacts[3].Id,
                                               Personal_Plan__c = personalPlans[2].Id));
        
        //Insert
        insert personalGoals;
        
        //Assert
        System.assert(personalGoals.size() > 0);
        
        //Query through the Personal Goals (This list will use to create the data of measurement periods for all the Proposal PGs)
        List<Personal_Goal__c> proposals = [Select Id From Personal_Goal__c Where Primary_Goal__c IN : personalGoals ORDER BY Period_Start__c ASC];
        
        //List of Personal Goal Measurement Period
        List<Personal_Goal_Measurement_Period__c> pGMPeriods = new List<Personal_Goal_Measurement_Period__c>();
        
        //Added new Record in list
        pGMPeriods.add(new Personal_Goal_Measurement_Period__c(Name = 'PGMP 1', Personal_Goal__c = personalGoals[0].Id, Measurement_Date__c = System.today()));
        pGMPeriods.add(new Personal_Goal_Measurement_Period__c(Name = 'PGMP 2', Personal_Goal__c = personalGoals[1].Id, Measurement_Date__c = System.today().addDays(5)));
        pGMPeriods.add(new Personal_Goal_Measurement_Period__c(Name = 'PGMP 3', Personal_Goal__c = personalGoals[2].Id, Measurement_Date__c = System.today().addDays(10)));
        pGMPeriods.add(new Personal_Goal_Measurement_Period__c(Name = 'PGMP 4', Personal_Goal__c = personalGoals[3].Id, Measurement_Date__c = System.today().addDays(15)));
        pGMPeriods.add(new Personal_Goal_Measurement_Period__c(Name = 'PGMP 5', Personal_Goal__c = personalGoals[4].Id, Measurement_Date__c = System.today().addDays(20)));
        pGMPeriods.add(new Personal_Goal_Measurement_Period__c(Name = 'PGMP 6', Personal_Goal__c = personalGoals[5].Id, Measurement_Date__c = System.today().addDays(25)));
        pGMPeriods.add(new Personal_Goal_Measurement_Period__c(Name = 'PGMP 7', Personal_Goal__c = proposals[0].Id, Measurement_Date__c = System.today()));
        pGMPeriods.add(new Personal_Goal_Measurement_Period__c(Name = 'PGMP 8', Personal_Goal__c = proposals[1].Id, Measurement_Date__c = System.today().addDays(5)));
        pGMPeriods.add(new Personal_Goal_Measurement_Period__c(Name = 'PGMP 9', Personal_Goal__c = proposals[2].Id, Measurement_Date__c = System.today().addDays(10)));
        pGMPeriods.add(new Personal_Goal_Measurement_Period__c(Name = 'PGMP 10', Personal_Goal__c = proposals[3].Id, Measurement_Date__c = System.today().addDays(15)));
        pGMPeriods.add(new Personal_Goal_Measurement_Period__c(Name = 'PGMP 11', Personal_Goal__c = proposals[4].Id, Measurement_Date__c = System.today().addDays(20)));
        pGMPeriods.add(new Personal_Goal_Measurement_Period__c(Name = 'PGMP 12', Personal_Goal__c = proposals[5].Id, Measurement_Date__c = System.today().addDays(25)));
        
        //Insert
        insert pGMPeriods;
        
        //Assert
        System.assert(pGMPeriods.size() > 0);
        
        //Controller instance
        AssignNewGoalsToPlansController controller = new AssignNewGoalsToPlansController();
        
        //Asserts for result
        System.assertEquals(4,controller.goalHeaders.size());
        
        //Asserts for result
        System.assertEquals(3,controller.assignWrapperList.size());
        
        //Asserts for result
        System.assertEquals(2, controller.assignWrapperList[0].goalTypes[0].personalGoals.size());
        System.assertEquals(2, controller.assignWrapperList[0].goalTypes[1].personalGoals.size());
        System.assertEquals(2, controller.assignWrapperList[0].goalTypes[2].personalGoals.size());
        System.assertEquals(2, controller.assignWrapperList[0].goalTypes[3].personalGoals.size());
        System.assertEquals(2, controller.assignWrapperList[1].goalTypes[0].personalGoals.size());
        System.assertEquals(2, controller.assignWrapperList[1].goalTypes[1].personalGoals.size());
        System.assertEquals(2, controller.assignWrapperList[1].goalTypes[2].personalGoals.size());
        System.assertEquals(2, controller.assignWrapperList[1].goalTypes[3].personalGoals.size());
        System.assertEquals(1, controller.assignWrapperList[2].goalTypes[0].personalGoals.size());
        System.assertEquals(1, controller.assignWrapperList[2].goalTypes[1].personalGoals.size());
        System.assertEquals(1, controller.assignWrapperList[2].goalTypes[2].personalGoals.size());
        System.assertEquals(1, controller.assignWrapperList[2].goalTypes[3].personalGoals.size());
        
        //Business Title
        controller.personalGoal.Business_Title__c = valueTypes[0].Id;
           
        //Set Value type
        controller.personalGoal.Value_Type__c = valueTypes[1].Id;
        
        //Call Method
        controller.loadPersonalGoalData();
        
        //Result for Assert
        System.assertEquals(0,controller.goalHeaders.size());
        
        //Result for Assert
        System.assertEquals(0,controller.assignWrapperList.size());
        
        //Business Title
        controller.personalGoal.Business_Title__c = null;
           
        //Set Value type
        controller.personalGoal.Value_Type__c = null;
        
        //Set Flag True
        controller.isTenured = true;
        
        //Call Method
        controller.loadPersonalGoalData();
        
        //Result for Assert
        System.assertEquals(0,controller.goalHeaders.size());
        
        //Result for Assert
        System.assertEquals(0,controller.assignWrapperList.size());
        
        //Set Flag True
        controller.isTenured = false;
        
        //Set Collection perspective 
        controller.staffHistory.Lookup_Value__c = programPerspectives[0].Id;
        
        //Call Method
        controller.loadPersonalGoalData();
        
        //Result for Assert
        System.assertEquals(1,controller.goalHeaders.size());
        System.assertEquals(1,controller.assignWrapperList.size());
        System.assertEquals(1,controller.assignWrapperList[0].goalTypes.size());
        System.assertEquals(2,controller.assignWrapperList[0].goalTypes[0].personalGoals.size());
        
        //Set Collection perspective 
        controller.staffHistory.Lookup_Value__c = null;
        
        //Call Method
        controller.loadPersonalGoalData();
        
        //Result for Assert
        System.assertEquals(4,controller.goalHeaders.size());
        System.assertEquals(3,controller.assignWrapperList.size());
        System.assertEquals(4,controller.assignWrapperList[0].goalTypes.size());
        
        //Reinitialize  
        controller = new AssignNewGoalsToPlansController();
        
         //Business Title
        controller.personalGoal.Business_Title__c = null;
           
        //Set Value type
        controller.personalGoal.Value_Type__c = null;
        
        //Set Flag True
        controller.isTenured = true;
        
        //Call Method
        controller.loadPersonalGoalData();
        
        //Result for Assert
        System.assertEquals(0,controller.goalHeaders.size());
        System.assertEquals(0,controller.assignWrapperList.size());
       
         //Set Flag True
        controller.isTenured = false;
        
        //Call Method
        controller.loadPersonalGoalData();
               
        //Select the Row  
        controller.assignWrapperList[0].mapSelection.put(0,true); 
        controller.assignWrapperList[0].goalTypes[0].personalGoals[0].selected = true;
        controller.assignWrapperList[0].goalTypes[0].personalGoals[1].selected = true;
        controller.assignWrapperList[0].goalTypes[0].personalGoals[0].personalGoal.Rate_Template__c = rateTemplates[1].Id;
        controller.assignWrapperList[0].goalTypes[0].personalGoals[1].personalGoal.Rate_Template__c = rateTemplates[1].Id; 
        
        //Call the method to Draw the second tab's data
        controller.drawPlanAssignmentData();
        
        //set value
        ApexPages.currentPage().getParameters().put('rowIndex','0');
        controller.selectedPersonalGoalsWrapper[0].selectedPP = 'None';
        controller.assignWrapperList[0].goalTypes[0].personalGoals[0].personalGoal.Rate_Template__c = rateTemplates[1].Id;
        controller.assignWrapperList[0].goalTypes[0].personalGoals[0].personalGoal.Weighting__c = 100;
        
        //Call Method
        controller.updatePersonalPlan();
        
        ApexPages.currentPage().getParameters().put('rowIndex','0');
        controller.selectedPersonalGoalsWrapper[0].selectedPP = personalPlans[1].Id;
        controller.assignWrapperList[0].goalTypes[0].personalGoals[0].personalGoal.Rate_Template__c = rateTemplates[1].Id;
        controller.assignWrapperList[0].goalTypes[0].personalGoals[0].personalGoal.Weighting__c = 100;
        
        //Call Method
        controller.updatepersonalplan();
        
        //select row
        ApexPages.currentPage().getParameters().put('rowIndex','0');
        controller.selectedPersonalGoalsWrapper[0].selectedPP = personalPlans[2].Id;
        controller.assignWrapperList[0].goalTypes[0].personalGoals[0].personalGoal.Rate_Template__c = rateTemplates[1].Id;
        controller.assignWrapperList[0].goalTypes[0].personalGoals[0].personalGoal.Weighting__c = 100;
        
        //Call Method
        controller.updatepersonalplan();
        
        //Query Through Personal Plan
        List<Personal_Plan__c> pPList = [Select Id, Name From Personal_Plan__c];
        
        //Result For Assert
        System.assertEquals(3,pPList.size());
        
        //Add personal goal measurment period
        controller.mainRow = 0;
        controller.pGRow = 0;
        controller.pGMPeriod.Measurement_Date__c = system.today(); 
        controller.addPGMPeriod();
        
        //Add personal goal measurment period
        controller.mainRow = 0;
        controller.pGRow = 0;
        controller.pGMPeriod.Measurement_Date__c = system.today().addDays(5); 
        controller.loadPGMPs();
        
        //Call Method
        controller.addPGMPeriod();
        
        //Remove personal goal measurment period
        controller.mainRow = 0;
        controller.pGRow = 0;
        
        //Call method
        controller.removePGMPeriod();
        
        //Call method
        Pagereference pG = controller.Close();
        
        //Get Personal Plan key prefix
        String pPKeyPreFix = Personal_Goal__c.sObjectType.getDescribe().getKeyPrefix();
        
        //Result For Assert
        System.assert(pG.getUrl().contains('/'+pPKeyPreFix)); 
        
        //Query Through Personal Plan
        pPList = [Select Id, Name From Personal_Plan__c];
        
        //Result For Assert
        System.assertEquals(3,pPList.size());
        
        //Query Through Personal Goal
        List<Personal_Goal__c> pGList = [Select Id, Name, Goal_Type__c, Rate_Template__c, RecordTypeId, Personal_Plan__c From Personal_Goal__c Where Personal_Plan__c != null AND Rate_Template__c != null];
        
        //Assert For result
        System.assertEquals(2,pGList.size());
        
         //Test Start here
        Test.startTest();
        
        //ReInislization
        controller = new AssignNewGoalsToPlansController();
        
        //Business Title
        controller.personalGoal.Business_Title__c = null;
           
        //Set Value type
        controller.personalGoal.Value_Type__c = null;
        
        //Set Flag True
        controller.isTenured = true;
        
        //Call Method
        controller.loadPersonalGoalData();
        
        System.assertEquals(0,controller.goalHeaders.size());
        System.assertEquals(0,controller.assignWrapperList.size());
        
         //Set Flag false
        controller.isTenured = false;
        
        //Call Method
        controller.loadPersonalGoalData();
        
        //Result for Assert
        System.assertEquals(4,controller.goalHeaders.size());
        System.assertEquals(3,controller.assignWrapperList.size());
        System.assertEquals(4,controller.assignWrapperList[0].goalTypes.size());
        System.assertEquals(2,controller.assignWrapperList[0].goalTypes[0].personalGoals.size());
        
        //Select the Row  
        controller.assignWrapperList[0].mapSelection.put(0,true); 
        controller.assignWrapperList[0].goalTypes[0].personalGoals[0].selected = true;
        
        //Set Rate template on selected personal goal
        controller.assignWrapperList[0].goalTypes[0].personalGoals[0].personalGoal.Rate_Template__c = rateTemplates[1].Id; 
        
        //Call the method to Draw the second tab's data
        controller.drawPlanAssignmentData();
        
        //set start date
        controller.selectedPersonalGoalsWrapper[0].personalPlan.Plan_Start__c = system.today();
        
        //set end date
        controller.selectedPersonalGoalsWrapper[0].personalPlan.Plan_End__c = system.today();
        
        //call method
        pG = controller.saveAndClose();
        
        //Get Personal Plan key prefix
        pPKeyPreFix = Personal_Plan__c.sObjectType.getDescribe().getKeyPrefix();
        
        //Result For Assert
        System.assert(pG.getUrl().contains('/'+pPKeyPreFix)); 
        
        //Reinsilization
        //controller = new AssignNewGoalsToPlansController();
        
         //Business Title
        controller.personalGoal.Business_Title__c = null;
           
        //Set Value type
        controller.personalGoal.Value_Type__c = null;
        
        //Set Flag True
        controller.isTenured = true;
        
        //Call Method
        controller.loadPersonalGoalData();
        
         //Result for Assert
        System.assertEquals(0,controller.goalHeaders.size());
        System.assertEquals(0,controller.assignWrapperList.size());
        
        //Set Flag false
        controller.isTenured = false;
        
        //Call Method
        controller.loadPersonalGoalData();
        
        //Result for Assert
        System.assertEquals(4,controller.goalHeaders.size());
        System.assertEquals(3,controller.assignWrapperList.size());
        System.assertEquals(4,controller.assignWrapperList[0].goalTypes.size());
        System.assertEquals(1,controller.assignWrapperList[0].goalTypes[0].personalGoals.size());
        
        //Select the Row  
        controller.assignWrapperList[0].mapSelection.put(0,true); 
        
        //Set Value
        controller.assignWrapperList[0].goalTypes[0].personalGoals[0].selected = true;
        controller.assignWrapperList[0].goalTypes[0].personalGoals[0].personalGoal.Rate_Template__c = rateTemplates[1].Id; 
        
        //Call the method to Draw the second tab's data
        controller.drawPlanAssignmentData();
        
        //Add personal goal measurment period
        controller.mainRow = 0;
        controller.pGRow = 0;
        controller.pGMPeriod.Measurement_Date__c = system.today(); 
        controller.addPGMPeriod();
        
        //Call Method  
        controller.doSave();
        
        //Result for Assert
        //System.assert(ApexPages.getMessages()[1].getDetail().contains('Plan Start date can not be blank.'));
        
        //set start date
        controller.selectedPersonalGoalsWrapper[0].personalPlan.Plan_Start__c = system.today();
        
        //Call Method  
        controller.doSave();
            
        //Result for Assert
        //System.assert(ApexPages.getMessages()[2].getDetail().contains( 'Plan End date can not be blank.' ));
        
        //set end date
        controller.selectedPersonalGoalsWrapper[0].personalPlan.Plan_End__c = system.today();
        
        //call method
        controller.doSave();
        
        //Query through personal goal
        pGList = [Select Id, Name, Goal_Type__c, Rate_Template__c, RecordTypeId, Personal_Plan__c From Personal_Goal__c Where Personal_Plan__c != null AND Rate_Template__c != null];
        
        //Assert For result(2 + 2)
        System.assertEquals(2,pGList.size());
        System.assertEquals(goalTypes[0].Id,pGList[0].Goal_Type__c);
        System.assertEquals(goalTypes[0].Id,pGList[1].Goal_Type__c);
        System.assertEquals(rateTemplates[1].Id,pGList[0].Rate_Template__c);
        System.assertEquals(rateTemplates[1].Id,pGList[1].Rate_Template__c);
        System.assertEquals(PersonalPlans[2].Id,pGList[0].Personal_Plan__c);
        System.assertEquals(PersonalPlans[2].Id,pGList[1].Personal_Plan__c);
       
        //Query througt Personal Goal Measurement Period
        List<Personal_Goal_Measurement_Period__c> pGMPList = [Select Id, Name, Measurement_Date__c from Personal_Goal_Measurement_Period__c];
        
        //Assert For result(12 + 2)
        System.assertEquals(14,pGMPList.size());
        system.AssertEquals(system.today(), pGMPList[12].Measurement_Date__c);
        system.AssertEquals(system.today(), pGMPList[13].Measurement_Date__c);
        
         //Call Method
        controller.loadPersonalGoalData();
        
        //Set Value
        controller.assignWrapperList[0].goalTypes[0].personalGoals[0].selected = true;
        controller.assignWrapperList[0].goalTypes[0].personalGoals[0].personalGoal.Rate_Template__c = rateTemplates[1].Id; 
        
        //Call the method to Draw the second tab's data
        controller.drawPlanAssignmentData();
        //set start date
        controller.selectedPersonalGoalsWrapper[0].personalPlan.Plan_Start__c = system.today();
        //set end date
        controller.selectedPersonalGoalsWrapper[0].personalPlan.Plan_End__c = system.today();
        controller.selectedPersonalGoalsWrapper[0].selectedPP = personalPlans[2].Id;
        controller.selectedPersonalGoalsWrapper[0].personalPlan.Id = personalPlans[2].Id;
        
        //Call Save method again in order to call Cary over to Plan in new version for code coverage
        controller.selectedPersonalGoalsWrapper[0].selectedBehaviourOption = ISSPConstants.CARRYOVERINNEWVERSION;
        
        //call method
        controller.doSave();
        
        //Query through personal goal
        pGList = [Select Id, Name, Goal_Type__c, Rate_Template__c, RecordTypeId, Personal_Plan__c From Personal_Goal__c Where Personal_Plan__c != null AND Rate_Template__c != null];
        
        //Assert For result(2 + 2)
        System.assertEquals(5,pGList.size());
        System.assertEquals(goalTypes[0].Id,pGList[0].Goal_Type__c);
        System.assertEquals(goalTypes[0].Id,pGList[1].Goal_Type__c);
        System.assertEquals(rateTemplates[1].Id,pGList[0].Rate_Template__c);
        System.assertEquals(rateTemplates[1].Id,pGList[1].Rate_Template__c);
        System.assertEquals(PersonalPlans[2].Id,pGList[0].Personal_Plan__c);
        System.assertEquals(PersonalPlans[2].Id,pGList[1].Personal_Plan__c);
        
        //Test Stop Here
        Test.stopTest();
        
    }*/
}