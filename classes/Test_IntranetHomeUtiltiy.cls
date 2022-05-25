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
/** Description       :   Test class for IntranetHomeUtility
  * 
  *  Created Date     :   08/20/2014
  *
  *  Created By       :   
  *  
  *  Current vision   :    v1.0
  * 
  *  Revision Logs    :    v1.0 - Created
  *					  :	   V2.0 - Modified By - Rajeev Jain - CR-7579 - Increase code coverage - 09/21/2015  
  *						   V3.0 - Modified By - Deepak Kumawat - Apollo - Test Failures Fixes
  *
  *  Coverage         :    92% 
  **/ 
@isTest(seeAllData = false) 
private class Test_IntranetHomeUtiltiy {
    
    /**
      * @Description    :   Method to check functionality of  PopulateUserSession
      *
      * @args           :   
      *
      * @return         :   void
      *
    **/
    static testMethod void testPopulateUserSession() {
        
        //Update User record with Job Level
        System.runAs(new User(Id = UserInfo.getUserId())) {
            
            update new User(Id = UserInfo.getUserId(), Job_Level__c = '10 B1 Early Professional');
        }
        
        //Start Testing from here
        Test.startTest();
        
        //Set values
        IntranetHomeUtility.UserBrowser = 'Chrome';
        IntranetHomeUtility.UserDevice = 'Mobile';
        IntranetHomeUtility.ScreenSize = 992;
        IntranetHomeUtility.NetworkAccess = 'Test';
        
        //Call PopulateUserSession method
        IntranetType.UserSession UserSession = IntranetHomeUtility.getUserSession;
        
        //Assert for the results
        User currentUser = [Select Id, FirstName, LastName, Office__c, Workspace__c, Job_Level__c, Department, ABC_Division__c, ABC_Function__c, ABC_Department__c from User where Id =: UserInfo.getUserId()];
        System.assertEquals(currentUser.FirstName, UserSession.FirstName);
        System.assertEquals(currentUser.LastName, UserSession.LastName);
        System.assertEquals(currentUser.Id, UserSession.UserId);
        System.assertEquals(currentUser.Office__c, UserSession.AssignedOffice);
        System.assertEquals(currentUser.Workspace__c, UserSession.Workspace);
        System.assertEquals('B', UserSession.JobLevel);
        System.assertEquals(currentUser.ABC_Department__c, UserSession.Department);
        System.assertEquals(currentUser.ABC_Division__c, UserSession.Division);
        System.assertEquals(currentUser.ABC_Function__c, UserSession.Function);
        System.assertEquals('Laptop (992 pixels)', UserSession.ScreenSize);
        System.assertEquals(IntranetHomeUtility.NetworkAccess, UserSession.AccessLocation);
        System.assertEquals(IntranetHomeUtility.UserBrowser, UserSession.Browser);
        System.assertEquals(IntranetHomeUtility.UserDevice, UserSession.Device);
        
        //Update the User level and Screen Size with a different value and assert for teh results
        //Update User record with Job Level
        System.runAs(new User(Id = UserInfo.getUserId())) {
            
            update new User(Id = UserInfo.getUserId(), Job_Level__c = '105 A Professional');
        }
        
        //Update Screen Size
        IntranetHomeUtility.ScreenSize = 256;
        
        //Empty the User Session as it is caching
        IntranetHomeUtility.getUserSession = null;
            
        //Call PopulateUserSession method
        UserSession = IntranetHomeUtility.getUserSession;
        
        //Assert for the results
        System.assertEquals('A', UserSession.JobLevel);
        System.assertEquals('Phone (<768 pixels)', UserSession.ScreenSize);
        
        //Update Screen Size
        IntranetHomeUtility.ScreenSize = 1300;
        
        //Call PopulateUserSession method
        UserSession = IntranetHomeUtility.getUserSession;
        
        //Update Screen Size
        IntranetHomeUtility.ScreenSize = null;
        
        //Empty the User Session as it is caching
        IntranetHomeUtility.getUserSession = null;
        
        //Call PopulateUserSession method
        UserSession = IntranetHomeUtility.getUserSession;
        
        //Get Job Level Code only for Covering Return null
        
        //Update User record with Job Level
        System.runAs(new User(Id = UserInfo.getUserId())) {
            
            update new User(Id = UserInfo.getUserId(), Job_Level__c = '');
        }
        
        //Empty the User Session as it is caching
        IntranetHomeUtility.getUserSession = null;
        
        //Call PopulateUserSession method
        UserSession = IntranetHomeUtility.getUserSession;
        
        //Stop testing here
        Test.stopTest();
    }
    
    /**
      * @Description    :   Method to check functionality of  CalculateDPAScore
      *
      * @args           :   
      *
      * @return         :   void
      *
    **/
    static testMethod void testCalculateDPAScore() {
        
        //List of intranet containers
        List<Intranet_Container__c> intranetContainers = new List<Intranet_Container__c>();
        RecordType rTypeContainer = [Select Id, DeveloperName From RecordType where sObjectType='Intranet_Container__c' AND DeveloperName = 'Content_Flexible' AND isActive=true];
        intranetContainers.add(new Intranet_Container__c(DPA_Score_Type__c = 'Office', Name = 'Test', Content_Types_Allowed__c = 'Job Item', RecordTypeId = rTypeContainer.Id));
        intranetContainers.add(new Intranet_Container__c(DPA_Score_Type__c = 'Manager', Name = 'Test1', Content_Types_Allowed__c = 'Job Item', RecordTypeId = rTypeContainer.Id));
        intranetContainers.add(new Intranet_Container__c(DPA_Score_Type__c = 'Level', Name = 'Test1', Content_Types_Allowed__c = 'Job Item', RecordTypeId = rTypeContainer.Id));
        intranetContainers.add(new Intranet_Container__c(DPA_Score_Type__c = 'Full', Name = 'Test1', Content_Types_Allowed__c = 'Job Item', RecordTypeId = rTypeContainer.Id));
        
        insert intranetContainers;
        
        //List of intranet items
        List<Intranet_Item__c>  intranetItems = new List<Intranet_Item__c>();
        
        intranetItems.add(new Intranet_Item__c(Name = 'Test1', Item_Type__c = 'Job Item', Office_Short_Name__c = 'Test'));
        intranetItems.add(new Intranet_Item__c(Name = 'Test1', Item_Type__c = 'Job Item', Office_Short_Name__c = 'Test'));
                                
        insert intranetItems;
        
        //Settings Office
        RecordType rType = [Select Id, DeveloperName From RecordType where sObjectType='Intranet_Item__c' AND DeveloperName = 'Settings_Office' AND isActive=true];
        List<Intranet_Item__c> officeIntranetItems = new list<Intranet_Item__c>();
        officeIntranetItems.add(new Intranet_Item__c(Name = 'Test1', Office_Short_Name__c = 'Office1', RecordTypeId = rType.Id));
        officeIntranetItems.add(new Intranet_Item__c(Name = 'Test2', Office_Short_Name__c = 'TestAll', RecordTypeId = rType.Id));
        officeIntranetItems.add(new Intranet_Item__c(Name = 'Test3', Office_Short_Name__c = 'Dc', RecordTypeId = rType.Id));
        insert officeIntranetItems;
        
        //Custom Setting Record
        Intranet_Constants__c iC = new Intranet_Constants__c();
        iC.Allow_Importance_L1__c = true;
        iC.SetupOwnerId = UserInfo.getUserId();
        insert iC;
        
        //List of intranet schedule
        List<Intranet_Schedule__c> intranetSchedules = new List<Intranet_Schedule__c>();
        
        
        intranetSchedules.add(new Intranet_Schedule__c(Name = 'Test1', 
                                                       Intranet_Container__c = intranetContainers[0].Id,
                                                       Importance__c = 'L1',
                                                       Level__c = '10 B1 Early Professional',
                                                       Department__c  = 'Dep1',
                                                       Division__c = 'Div1',
                                                       Function__c = 'Fun1',
                                                       Start_Date_Time__c = system.today() - 1,
                                                       End_Date_Time__c = system.today().addDays(5),
                                                       Timeline_Emphasis__c = 'start',
                                                       Manager_Level_Only__c = false,
                                                       Critical_Visibility__c = true,
                                                       Intranet_Item__c = intranetItems[0].Id,
                                                       Office__c = officeIntranetItems[0].Id,
                                                       Entity__c = 'EAB'));
                                                       
        intranetSchedules.add(new Intranet_Schedule__c(Name = 'Test2', 
                                                       Intranet_Container__c = intranetContainers[1].Id,
                                                       Importance__c = 'L2',
                                                       Level__c = 'level2TestingAll',
                                                       Department__c  = 'Dep2',
                                                       Division__c = 'Div2',
                                                       Function__c = 'Fun2',
                                                       Start_Date_Time__c = system.today(),
                                                       End_Date_Time__c = system.today().addDays(5),
                                                       Timeline_Emphasis__c = 'start',
                                                       Manager_Level_Only__c = false,
                                                       Critical_Visibility__c = true,
                                                       Intranet_Item__c = intranetItems[1].Id,
                                                       Office__c = officeIntranetItems[0].Id,
                                                       Entity__c = 'EAB'));
        
         intranetSchedules.add(new Intranet_Schedule__c(Name = 'Test3', 
                                                       Intranet_Container__c = intranetContainers[2].Id,
                                                       Importance__c = 'L3',
                                                       Level__c = 'level3',
                                                       Department__c  = 'Dep3',
                                                       Division__c = 'Div3',
                                                       Function__c = 'Fun3',
                                                       Start_Date_Time__c = system.today() - 1,
                                                       End_Date_Time__c = system.today().addDays(5),
                                                       Timeline_Emphasis__c = 'End',
                                                       Manager_Level_Only__c = false,
                                                       Critical_Visibility__c = true,
                                                       Intranet_Item__c = intranetItems[1].Id,
                                                       Office__c = officeIntranetItems[1].Id,
                                                       Entity__c = 'EAB'));
        
         intranetSchedules.add(new Intranet_Schedule__c(Name = 'Test4', 
                                                       Intranet_Container__c = intranetContainers[3].Id,
                                                       Importance__c = 'L4',
                                                       Level__c = 'level4',
                                                       Department__c = 'Dep4',
                                                       Division__c = 'Div4',
                                                       Function__c = 'Fun4',
                                                       Start_Date_Time__c = system.today() - 1,
                                                       End_Date_Time__c = system.today().addDays(5),
                                                       Timeline_Emphasis__c = 'End',
                                                       Manager_Level_Only__c = false,
                                                       Critical_Visibility__c = true,
                                                       Intranet_Item__c = intranetItems[1].Id,
                                                       Office__c = officeIntranetItems[1].Id,
                                                       Entity__c = 'EAB'));
         
        insert intranetSchedules;
      
        //List of  IntranetSetting (Custom setting)
        List<Intranet_Settings__c>  intranetConfigs = new List<Intranet_Settings__c>();
        
        intranetConfigs.add(new Intranet_Settings__c(Name = 'Importance_L1', Type__c = 'DPA' , Value__c = '90'));
        intranetConfigs.add(new Intranet_Settings__c(Name = 'Importance_L2', Type__c = 'DPA' , Value__c = '70'));
        intranetConfigs.add(new Intranet_Settings__c(Name = 'Importance_L3', Type__c = 'DPA' , Value__c = '50'));
        intranetConfigs.add(new Intranet_Settings__c(Name = 'Importance_L4', Type__c = 'DPA' , Value__c = '30'));
        intranetConfigs.add(new Intranet_Settings__c(Name = 'Office_All', Type__c = 'DPA' , Value__c = '65'));
        intranetConfigs.add(new Intranet_Settings__c(Name = 'Office_Other', Type__c = 'DPA' , Value__c = '30'));
        intranetConfigs.add(new Intranet_Settings__c(Name = 'Office_Local', Type__c = 'DPA' , Value__c = '50'));
        intranetConfigs.add(new Intranet_Settings__c(Name = 'Level_Same', Type__c = 'DPA' , Value__c = '50'));
        intranetConfigs.add(new Intranet_Settings__c(Name = 'Level_Other', Type__c = 'DPA' , Value__c = '0'));
        intranetConfigs.add(new Intranet_Settings__c(Name = 'Division_Same', Type__c = 'DPA' , Value__c = '60'));
        intranetConfigs.add(new Intranet_Settings__c(Name = 'Division_Other', Type__c = 'DPA' , Value__c = '30'));
        intranetConfigs.add(new Intranet_Settings__c(Name = 'Function_Same', Type__c = 'DPA' , Value__c = '60'));
        intranetConfigs.add(new Intranet_Settings__c(Name = 'Function_Other', Type__c = 'DPA' , Value__c = '30'));
        intranetConfigs.add(new Intranet_Settings__c(Name = 'TimeframeEmphasisBreakpoint', Type__c = 'DPA' , Value__c = '25'));
        intranetConfigs.add(new Intranet_Settings__c(Name = 'CriticalVisible', Type__c = 'DPA' , Value__c = '100'));
        intranetConfigs.add(new Intranet_Settings__c(Name = 'Department_Same', Type__c = 'DPA' , Value__c = '60'));
        intranetConfigs.add(new Intranet_Settings__c(Name = 'Department_Other', Type__c = 'DPA' , Value__c = '30'));
        intranetConfigs.add(new Intranet_Settings__c(Name = 'AllOfficeShortName', Type__c = 'DPA' , Value__c = 'TestAll'));
        
        insert intranetConfigs;
        
        //Office Item
        //officeIntranetItem = [Select Id, Name from Intranet_Item__c where Id =: officeIntranetItem.Id];
        
        //Update User record with Job Level
        System.runAs(new User(Id = UserInfo.getUserId())) {
            
            update new User(Id = UserInfo.getUserId(), Job_Level__c = '10 B1 Early Professional',
                                                       ABC_Division__c = 'Div1',
                                                       ABC_Function__c = 'Fun1',
                                                       Office__c = officeIntranetItems[0].Id,
                                                       ABC_Department__c = 'Dep1',
                           							   Entity__c = 'EAB');
        }
        
        //Set values
        IntranetHomeUtility.UserBrowser = 'Chrome';
        IntranetHomeUtility.UserDevice = 'Mobile';
        IntranetHomeUtility.ScreenSize = 992;
        IntranetHomeUtility.NetworkAccess = 'Test';
        
        //Call UserSession method
            IntranetType.UserSession UserSession = IntranetHomeUtility.getUserSession;
        
        //Test start from here    
        Test.startTest();
        
        //Intranet Schedule
        Intranet_Schedule__c intranetSchedule = [Select Id, Intranet_Container__c, Intranet_Container__r.DPA_Score_Type__c, Importance__c, 
                                                    Level__c, Department__c, Division__c, Function__c, Start_Date_Time__c, End_Date_Time__c,
                                                    Office__c, Office__r.Name, Office__r.Office_Short_Name__c, Entity__c,
                                                    Timeline_Emphasis__c, Manager_Level_Only__c, Critical_Visibility__c from Intranet_Schedule__c 
                                                    where Id =: intranetSchedules[0].Id];
                                                    
        /***** OFFICE - Expected Values ****
        importanceScore = 90;       (L1)
        officeScore = 30; Other     
        jobLevelScore = 50; - Same
        departmentScore = 60 - Same
        divisionScore = 60;  - Same
        functionScore = 60; - Same
        startDate = Today - 1;
        endDate = Today + 5;
        daysRemaining = 5;
        daysVisible = 6;
        daysIn = 0;
        timeLineEmphasisScore = log10(400/6)/log10(25) = 1.82391 /1.39794= 1.30471
        managerScore = 1;
        criticalVisibilityScore = 100
        
        Visibility Multiplier - 1
        ****************************/
        
        /* 
            DPA Calculation for Office
            DPAScoreResult = ((((importanceScore + officeScore)/2) * timeframeEmphasisScore) + criticalVisibilityScore) * visibilityMultiplier;
            DPAScoreResult = ((((90 + 30)/2) * log10(500/6)/log10(25)) + 100)*1 = 182.XXXXXX
        */
        
        //calling controller method by passing all of three arguments
        Decimal dpaScore = IntranetHomeUtility.calculateDPAScore(UserSession, intranetSchedule, intranetItems[0]);
        
        //Assert for results
        System.assertEquals(true, Integer.valueOf(dpaScore)  > 100);
        
        //Get 2 Intranet Schedule
        intranetSchedule = [Select Id, Intranet_Container__c, Intranet_Container__r.DPA_Score_Type__c, Importance__c, 
                                                    Level__c, Department__c, Division__c, Function__c, Start_Date_Time__c, End_Date_Time__c,
                                                    Office__c, Office__r.Name, Office__r.Office_Short_Name__c, Entity__c,
                                                    Timeline_Emphasis__c, Manager_Level_Only__c, Critical_Visibility__c from Intranet_Schedule__c 
                                                    where Id =: intranetSchedules[1].Id];
        
        //calling controller method by passing all of three arguments
        dpaScore = IntranetHomeUtility.calculateDPAScore(UserSession, intranetSchedule, intranetItems[1]);
        
        //Assert for results
        System.assertEquals(1, Integer.valueOf(dpaScore));
        
         //Get 3 Intranet Schedule
        intranetSchedule = [Select Id, Intranet_Container__c, Intranet_Container__r.DPA_Score_Type__c, Importance__c, 
                                                    Level__c, Department__c, Division__c, Function__c, Start_Date_Time__c, End_Date_Time__c,
                                                    Office__c, Office__r.Name, Office__r.Office_Short_Name__c, Entity__c,
                                                    Timeline_Emphasis__c, Manager_Level_Only__c, Critical_Visibility__c from Intranet_Schedule__c 
                                                    where Id =: intranetSchedules[2].Id];
        
        //calling controller method by passing all of three arguments
        dpaScore = IntranetHomeUtility.calculateDPAScore(UserSession, intranetSchedule, intranetItems[1]);
        
        //Assert for results
        System.assertEquals(0, Integer.valueOf(dpaScore));
        
         //Get 4 Intranet Schedule
        intranetSchedule = [Select Id, Intranet_Container__c, Intranet_Container__r.DPA_Score_Type__c, Importance__c, 
                                                    Level__c, Department__c, Division__c, Function__c, Start_Date_Time__c, End_Date_Time__c,
                                                    Office__c, Office__r.Name, Office__r.Office_Short_Name__c, Entity__c,
                                                    Timeline_Emphasis__c, Manager_Level_Only__c, Critical_Visibility__c from Intranet_Schedule__c 
                                                    where Id =: intranetSchedules[3].Id];
        
        //calling controller method by passing all of three arguments
        dpaScore = IntranetHomeUtility.calculateDPAScore(UserSession, intranetSchedule, intranetItems[1]);
        
        //Assert for results
        System.assertEquals(0, Integer.valueOf(dpaScore));
        
        //Check for Office Name BY Id
        String officeName = IntranetHomeUtility.LookupOfficeNameById(officeIntranetItems[0].Id);
        System.assertEquals('Office1', officeIntranetItems[0].Office_Short_Name__c);
        
        //Method Cover related To Debugging
        //Debug Single Container
        IntranetHomeUtility.DebugContainer('Check Single Container', new IntranetContainer(intranetContainers[0]));
        
        //List of IntranetContainers
        List<IntranetContainer> icContainers = new List<IntranetContainer>();
        icContainers.add(new IntranetContainer(intranetContainers[0]));
        icContainers.add(new IntranetContainer(intranetContainers[1]));
        
        //Debug Multiple Container
        IntranetHomeUtility.DebugContainers('Check Multiple Containers', icContainers);
        
        //Empty the User Session as it is caching
        IntranetHomeUtility.getUserSession = null;
        
        UserSession = IntranetHomeUtility.getUserSession;
        
        //Test stop here 
        Test.stopTest(); 
    }
    
    //Test validateAndFormatURL
    static testMethod void testValidateAndFormatURL() {
        
        //Start Test
        Test.startTest();
        
        //String url
        String linkURL = 'http://www.advisory.com';
        String expectedURL = 'http://www.advisory.com';
        
        //Call method and assert
        String actualURL = IntranetHomeUtility.validateAndFormatURL(linkURL);
        System.assertEquals(expectedURL, actualURL);
        
        //String url
        linkURL = 'https://www.advisory.com';
        expectedURL = 'https://www.advisory.com';
        
        //Call method and assert
        actualURL = IntranetHomeUtility.validateAndFormatURL(linkURL);
        System.assertEquals(expectedURL, actualURL);
        
        //String url
        linkURL = 'www.advisory.com';
        expectedURL = 'http://www.advisory.com';
        
        //Call method and assert
        actualURL = IntranetHomeUtility.validateAndFormatURL(linkURL);
        System.assertEquals(expectedURL, actualURL);
        
        //Stop Test
        Test.stopTest();
    }
    
    //test OfficeSelectList
    static testMethod void test_OfficeSelectList(){
        
        //Create the test data
        //
        RecordType rtOffice = [select Id, Name, DeveloperName from RecordType where DeveloperName = 'Settings_Office' and sobjectType = 'Intranet_Item__c' limit 1];
        system.debug('Test_IntranetHomeUtility.test_OfficeSelectList - rtOffice: '+rtOffice);
        
        List<Intranet_Item__c > testOffices = new list<Intranet_Item__c>();
        testOffices.add(new Intranet_Item__c(Name='a', Office_Name__c = 'Test 1', Office_Short_Name__c = 'test1', recordtypeid = rtOffice.Id, Active_Status__c = 'Active', Entity__c = 'EAB'));
        testOffices.add(new Intranet_Item__c(Name='b', Office_Name__c = 'Test 2', Office_Short_Name__c = 'test2', recordtypeid = rtOffice.Id, Active_Status__c = 'Active', Entity__c = 'EAB'));
        testOffices.add(new Intranet_Item__c(Name='c', Office_Name__c = 'Test 3', Office_Short_Name__c = 'test3', recordtypeid = rtOffice.Id, Active_Status__c = 'Active', Entity__c = 'EAB'));
        testOffices.add(new Intranet_Item__c(Name='d', Office_Name__c = 'Test 4', Office_Short_Name__c = 'test4', recordtypeid = rtOffice.Id, Active_Status__c = 'Active', Entity__c = 'EAB'));
        testOffices.add(new Intranet_Item__c(Name='e', Office_Name__c = 'Test 5', Office_Short_Name__c = 'test5', recordtypeid = rtOffice.Id, Active_Status__c = 'Inactive', Entity__c = 'EAB'));
        insert testOffices;
        
        List<SelectOption> listResults;
        
        //Run the test
        Test.startTest();
            listResults = IntranetHomeUtility.OfficeSelectList;
        Test.stopTest();
        
        //Validate the results
        system.assertEquals(4,listResults.size());
        system.assert(true,listResults[1].getLabel().contains(' Office'));
        
    }
    
    //Method to Cover Custom Settings 
    static testMethod void test_IntranetConstants(){
    	
        //Insert Org Default Custom Setting Data
        Intranet_Constants__c iC = new Intranet_Constants__c();
        iC.Allow_Importance_L1__c = false;
        ic.ErrorMessage_SearchResults_Empty__c = 'No results were returned for your search';
        ic.Icon_Style__c = 'fa fa-bookmark-o';
        ic.Allow_Schedule_Approval__c = false;
        ic.ErrorMessage_SearchResults_Max__c = 'More then 2000 result found';
        ic.Exclude_Birthday__c = false;
        insert iC;
        
        //Create Intranet Default Settings
        Intranet_Defaults__c mycs = new Intranet_Defaults__c(Name= 'Users');
        mycs.Item_Type__c='Users';
        mycs.SearchCategory__c ='People';
        mycs.Category__c = 'Jobs';
        mycs.Intranet_Container__c = '00a456';
        mycs.Create_Source__c = 'Test Method';
        insert mycs;
        
        //Create Another Settting
        Intranet_Defaults__c mycs1 = new Intranet_Defaults__c(Name= 'Job Item');
        mycs1.Item_Type__c='Job Item';
        mycs1.SearchCategory__c ='Jobs';
        mycs1.Intranet_Container__c = '00a456';
        mycs.Create_Source__c = 'Test Method';
        mycs1.Category__c = 'Jobs';
        mycs1.SearchResultOrder__c = 7;
        insert mycs1;
        
        //Create Intranet Item Record
        Intranet_Item__c intraItem = new Intranet_Item__c(Name = 'Test1', Item_Type__c = 'Job Item', Office_Short_Name__c = 'Test', Image_for_Main_Content__c = UserInfo.getUserId());
        insert intraItem;
        
        //Create Intranet Settings Custom Setting Data
        Intranet_Settings__c intraSetting = new Intranet_Settings__c(Name = 'TalentImageSet_Manager', Type__c = 'Image Link' , Value__c = intraItem.Id);
        insert intraSetting; 
        
        Intranet_Settings__c intraSetting1 = new Intranet_Settings__c(Name = 'TalentImageSet_NonManager', Type__c = 'Image Link' , Value__c = intraItem.Id);
        insert intraSetting1;
        
        //Start Test
        Test.startTest();
        
        Intranet_Constants__c orgDefaults = IntranetHomeUtility.IntranetConstants;
        System.assertEquals(false, orgDefaults.Allow_Importance_L1__c);
        System.assertEquals(false, orgDefaults.Allow_Schedule_Approval__c);
        System.assertEquals('More then 2000 result found', orgDefaults.ErrorMessage_SearchResults_Max__c);
        System.assertEquals(UserInfo.getOrganizationId(), orgDefaults.SetupOwnerId);
        
        //List to Hold Intranet Default Custom Settings
        List<Intranet_Defaults__c> defaultList = IntranetHomeUtility.getIntranetDefaultByCategoryAndSource('Jobs', 'Test Method');
        System.assertEquals(1, defaultList.size());
        
        //Get Image Set Item
        String imgUrlId = IntranetHomeUtility.GetImagesetImage(true);
        System.assertEquals(imgUrlId, intraItem.Image_for_Main_Content__c);
        
        //Get Image Set for Non Manager Set
        String imgUrlId1 = IntranetHomeUtility.GetImagesetImage(false);
        System.assertEquals(imgUrlId1, intraItem.Image_for_Main_Content__c);
       
        //Get Intranet Default Custom Setting Data By Name
		Intranet_Defaults__c defaultSetting = IntranetHomeUtility.LookupIntranetDefaultByName('Users');
		System.assertEquals('People', defaultSetting.SearchCategory__c);
		System.assertEquals('Jobs', defaultSetting.Category__c); 
        
        //Assert for Null Setting
        System.assertEquals(null, IntranetHomeUtility.LookupIntranetDefaultByName('xyz'));
        
        //Intranet Category Type Map
        Map<String,Set<String>> mapCategoryItemType = IntranetHomeUtility.getIntranetItemCategoryTypeMaps();
        
        //Assert To check That Map Cateogry is Populated
       	System.assertEquals(true, mapCategoryItemType != null && mapCategoryItemType.size() > 0);
        
        for(String str:mapCategoryItemType.keySet()){
        	
            System.assertEquals(true, str == 'People' || str == 'Jobs');
            
            //Check if People Key Contains User as Item Type
            if(mapCategoryItemType.containsKey('People')){
                System.assertEquals(true, mapCategoryItemType.get('People').contains('Users'));
            }
            
            //Check if Jobs Key Contains Jon Item as item type
            if(mapCategoryItemType.containsKey('Jobs')){
            	
                System.assertEquals(true, mapCategoryItemType.get('Jobs').contains('Job Item'));
            }
            
        }
        
        //Stop Test
        Test.stopTest();
    }
}