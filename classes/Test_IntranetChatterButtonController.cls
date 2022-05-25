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
 /**
 *   Description     :   Test Class for Intranet Chatter Button Controller
 *
 *   Created By      :   Rajeev Jain
 *
 *   Created Date    :   09/03/2015
 *
 *   Revision Log    :   V_1.0 - Created - CR-20150618-9016 - BoardRoom Mobile Phase 2
 * 					 :	 V_2.o - Modified By  - Rajeev Jain - CR - 7579 - 09/07/2015 - To Improve Code eovereage
 * 					 :	 V_2.1 - Modified By - Victor Hanson - CR-20171003-11642 - Updated to test Entity fields
 * 	 Code Coverage	 :	 98%;
**/
@isTest(seeAllData=false)
private class Test_IntranetChatterButtonController {
    
    @testSetup 
    static void testDataSetup(){
        
        //Insert Intranet Defaults
        List<Intranet_Defaults__c> intranetDefaultsList = new List<Intranet_Defaults__c>();
        
        Intranet_Defaults__c mycs = new Intranet_Defaults__c();
        mycs = new Intranet_Defaults__c(Name= 'Users');
        mycs.Item_Type__c='Users';
        mycs.SearchCategory__c ='People';
        
        intranetDefaultsList.add(mycs);
        
        Intranet_Defaults__c portals = new Intranet_Defaults__c();
        portals = new Intranet_Defaults__c(Name= 'Portals');
        portals.Item_Type__c='Portals';
        portals.SearchCategory__c ='Portals';
        
        intranetDefaultsList.add(portals);
        
        intranetDefaultsList.add(new Intranet_Defaults__c(Name = 'Office Location', Item_Type__c='Office Location'));
        intranetDefaultsList.add(new Intranet_Defaults__c(Name = 'Firm App Link', Item_Type__c='Firm App Link'));
        insert intranetDefaultsList;
        
         //Insert intranet Constant Custom Setting
        Intranet_Constants__c intraConst = new Intranet_Constants__c();
        intraConst.SetupOwnerId = UserInfo.getUserId();
        intraConst.Allow_Schedule_Approval__c = true;
        insert intraConst;
        
        //insert Office Item and Assign it to Usr or Update it for current User
        List<RecordType> settingOfficeRecordType = [select Id, DeveloperName, Name from RecordType where DeveloperName = 'Settings_Office'];
        
        //List of Office Item List
        List<Intranet_Item__c> officeItemList = new List<Intranet_Item__c>();
        
        //Only make the DC, Austin, and Chennai offices applicable to EAB
        //to verify the list of applicable offices works (later we assign the current user's entity to EAB)
        Intranet_Item__c dcOffice = new Intranet_Item__c(Name = 'DC - Office Location - Setting', 
                                                         Approval_Status__c = 'Approved',
                                                         RecordTypeId = settingOfficeRecordType[0].Id,
                                                         Office_Name__c = 'Washington, DC',
                                                         Office_Short_Name__c = 'DC',
                                                         Item_Type__c = 'Office Location',
                                                         Active_Status__c = 'Active',
                                                         Location__Latitude__s = 38.90543,
                                                         Location__Longitude__s = -77.05267,
                                                         Entity__c=Constants.ENTITY_ALL);
        Intranet_Item__c austinoffice = new Intranet_Item__c(Name = 'Austin - Office Location - Setting', 
                                                             Approval_Status__c = 'Approved',
                                                             RecordTypeId = settingOfficeRecordType[0].Id,
                                                             Office_Name__c = 'Austin, TX',
                                                             Office_Short_Name__c = 'Austin',
                                                             Item_Type__c = 'Office Location',
                                                             Active_Status__c = 'Active',
                                                             Location__Latitude__s = 30.42708,
                                                             Location__Longitude__s = -97.74334,
                                                             Entity__c=Constants.ENTITY_EAB);
        Intranet_Item__c australiaOffice = new Intranet_Item__c(Name = 'Australia - Office Location - Setting', 
                                                                Approval_Status__c = 'Approved',
                                                                RecordTypeId = settingOfficeRecordType[0].Id,
                                                                Office_Name__c = 'Australia',
                                                                Office_Short_Name__c = 'Australia',
                                                                Item_Type__c = 'Office Location',
                                                                Active_Status__c = 'Active',
                                                                Location__Latitude__s = -37.8147,
                                                                Location__Longitude__s = 144.9697,
                                                                Entity__c=Constants.ENTITY_HC);
        Intranet_Item__c chennaiOffice = new Intranet_Item__c(Name = 'Chennai - Office Location - Setting', 
                                                              Approval_Status__c = 'Approved',
                                                              RecordTypeId = settingOfficeRecordType[0].Id,
                                                              Office_Name__c = 'Chennai, India',
                                                              Office_Short_Name__c = 'Chennai',
                                                              Item_Type__c = 'Office Location',
                                                              Active_Status__c = 'Active',
                                                              Location__Latitude__s = 12.97,
                                                              Location__Longitude__s = 80.25,
                                                              Entity__c=Constants.ENTITY_EAB);
        Intranet_Item__c anArbor = new Intranet_Item__c(Name = 'Ann Arbor - Office Location - Setting', 
                                                        Approval_Status__c = 'Approved',
                                                        RecordTypeId = settingOfficeRecordType[0].Id,
                                                        Office_Name__c = 'Ann Arbor',
                                                        Office_Short_Name__c = 'Ann Arbor',
                                                        Item_Type__c = 'Office Location',
                                                        Active_Status__c = 'Active',
                                                        Location__Latitude__s = 42.30064,
                                                        Location__Longitude__s = -83.69134,
                                                        Entity__c=Constants.ENTITY_HC);
        //Add to the List
        officeItemList.add(dcOffice); officeItemList.add(austinoffice); officeItemList.add(australiaOffice); officeItemList.add(chennaiOffice); officeItemList.add(anArbor);
        
        //Insert List
        insert officeItemList;
        
        //Update User record with Job Level & Assign them to the Entity=EAB
        System.runAs(new User(Id = UserInfo.getUserId())) {
            
            update new User(Id = UserInfo.getUserId(), Job_Level__c = '10 B1 Early Professional',
                            ABC_Department__c = 'Enterprise Technologies', LastName='Test', Office__c = '', 
                            Entity__c = Constants.ENTITY_EAB);
        }
        
        
    }
    static List<Id> setupUserList(){
        
        
        //Create User Data for User search
        //Query through  profile to get Id Of Profile
        List<Profile> profileAdmin = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        
        
        //User Insert
        List<User> userList = new List<User>();
        
        userList.add(new User(Username = math.random()+'@testorg.com',
                            ProfileId = profileAdmin[0].Id, IsActive=true,
                            Alias = 'test',Email = 'testing@example.com',EmailEncodingKey='UTF-8', 
                            LastName='loremEpsum',LanguageLocaleKey='en_US',
                            FirstName = 'DollarSitAmet',
                            LocaleSidKey='en_US',TimeZoneSidKey='America/Los_Angeles'));
                            
        userList.add(new User(Username = math.random()+'@testorg.com',
                            ProfileId = profileAdmin[0].Id, IsActive=true,
                            Alias = 'test',Email = 'testing@example.com',EmailEncodingKey='UTF-8', 
                            LastName='Test loremEpsum',LanguageLocaleKey='en_US',
                            FirstName = 'SitDollarAmet',
                            LocaleSidKey='en_US',TimeZoneSidKey='America/Los_Angeles'));
                            
        userList.add(new User(Username = math.random()+'@testorg.com',
                            ProfileId = profileAdmin[0].Id, IsActive=true,
                            Alias = 'test',Email = 'testing@example.com',EmailEncodingKey='UTF-8', 
                            LastName='loremEpsum Edicted',LanguageLocaleKey='en_US',
                            FirstName = 'AmetDollaSitr',
                            LocaleSidKey='en_US',TimeZoneSidKey='America/Los_Angeles'));
    	userList.add(new User(Username = math.random()+'@testorg.com',
                            ProfileId = profileAdmin[0].Id, IsActive=true,
                            Alias = 'test',Email = 'testing@example.com',EmailEncodingKey='UTF-8', 
                            LastName='loremEpsum',LanguageLocaleKey='en_US',
                            FirstName = 'DollarSitAmet',
                            LocaleSidKey='en_US',TimeZoneSidKey='America/Los_Angeles'));
        
        userList.add(new User(Username = math.random()+'@testorg.com',
                            ProfileId = profileAdmin[0].Id, IsActive=true,
                            Alias = 'test',Email = 'testing@example.com',EmailEncodingKey='UTF-8', 
                            LastName='Test loremEpsum',LanguageLocaleKey='en_US',
                            FirstName = 'SitDollarAmet',
                            LocaleSidKey='en_US',TimeZoneSidKey='America/Los_Angeles'));
                            
        userList.add(new User(Username = math.random()+'@testorg.com',
                            ProfileId = profileAdmin[0].Id, IsActive=true,
                            Alias = 'test',Email = 'testing@example.com',EmailEncodingKey='UTF-8', 
                            LastName='loremEpsum Edicted',LanguageLocaleKey='en_US',
                            FirstName = 'AmetDollaSitr',
                            LocaleSidKey='en_US',TimeZoneSidKey='America/Los_Angeles'));
        userList.add(new User(Username = math.random()+'@testorg.com',
                            ProfileId = profileAdmin[0].Id, IsActive=true,
                            Alias = 'test',Email = 'testing@example.com',EmailEncodingKey='UTF-8', 
                            LastName='loremEpsum',LanguageLocaleKey='en_US',
                            FirstName = 'DollarSitAmet',
                            LocaleSidKey='en_US',TimeZoneSidKey='America/Los_Angeles'));
        
        userList.add(new User(Username = math.random()+'@testorg.com',
                            ProfileId = profileAdmin[0].Id, IsActive=true,
                            Alias = 'test',Email = 'testing@example.com',EmailEncodingKey='UTF-8', 
                            LastName='Test loremEpsum',LanguageLocaleKey='en_US',
                            FirstName = 'SitDollarAmet',
                            LocaleSidKey='en_US',TimeZoneSidKey='America/Los_Angeles'));
                            
        userList.add(new User(Username = math.random()+'@testorg.com',
                            ProfileId = profileAdmin[0].Id, IsActive=true,
                            Alias = 'test',Email = 'testing@example.com',EmailEncodingKey='UTF-8', 
                            LastName='loremEpsum Edicted',LanguageLocaleKey='en_US',
                            FirstName = 'AmetDollaSitr',
                            LocaleSidKey='en_US',TimeZoneSidKey='America/Los_Angeles'));
        //Insert User
        insert userList ;
        
         //We need to add fixed search results in Test classes for Dynamic SOSL
        //So Adding all user list id in expected search results and fixing it before it is searched throught the Controller
        List<Id> fixedSearchResults = new List<Id>();
        
        //Add User Id in Search Result
        fixedSearchResults.add(UserInfo.getUserId());
        
        //Add recently Inserted User
        for(User us: userList){
            fixedSearchResults.add(us.Id);
        }
        return fixedSearchResults;
    }
    
    static testMethod void testUserSearch() {
        
        //Set values
        IntranetHomeUtility.UserBrowser = 'Chrome';
        IntranetHomeUtility.UserDevice = 'Mobile';
        IntranetHomeUtility.ScreenSize = 992;
        IntranetHomeUtility.NetworkAccess = 'Test';
        
        //Call PopulateUserSession method
        IntranetType.UserSession UserSession = IntranetHomeUtility.getUserSession;
        
        //Set Fixed Search Results
        Test.setFixedSearchResults(setupUserList());
        
        Test.startTest();
        
         //Instantiate Controller
        IntranetChatterButtonController controller = new IntranetChatterButtonController();
        
        //Asssert For Null Results
        System.assertEquals(true, controller.UserSearchResult != null);
        System.assertEquals(true, controller.TotalCount == 0);
        
        //Call with Blank Search Term
        controller.searchCore();
        
        System.assertEquals(true, controller.searchResultMsg1 == 'Your search query must be 3 or more characters.  Please adjust and try again.');
        
        controller.SearchTerm = 'loremEpsum';
        controller.searchCore();
        List<IntranetUserInfo> userSearchResult = controller.UserSearchResult;
        
        System.assertEquals(true, userSearchResult.size() > 0 );
        
        //Now Search with That term which actually does not exist any user
        controller.SearchTerm = 'xyz';
        controller.searchCore();
        
        //Check for Page message2 
        System.assertEquals(true, controller.searchResultMsg2 == 'Your search returned no results. Please adjust your query and try again.');
        
        
        //================================ Testing for Show More Resutls ==========================================
        controller.SearchTerm = 'loremEpsum';
        controller.searchCore();
        userSearchResult = controller.UserSearchResult;
        
        System.assertEquals(true, userSearchResult.size() == IntranetChatterButtonController.DEFAULT_USER_PAGE_SIZE );
        
        //If user list size is greater then default page size Show More Result Button will be enabled on the page.
        controller.showMoreResults();
        userSearchResult = controller.UserSearchResult;
        
        //Check If User Search Results Size 
        System.assertEquals(true, userSearchResult.size() ==  setupUserList().size()-1); 
        
        //If someone reenetered again blank string show More Result Must Reset Result Msg
        controller.SearchTerm = '';
        controller.showMoreResults();
        System.assertEquals(true, controller.searchResultMsg1 == 'Your search query must be 3 or more characters.  Please adjust and try again.');
        
        //Now Search with That term which actually does not exist any user
        controller.SearchTerm = 'xyz';
        controller.showMoreResults();
        
        //Check for Page message2 
        System.assertEquals(controller.searchResultMsg2, 'Your search returned no results. Please adjust your query and try again.');
        
        //Call UserGroup Getter Method
        String userGroupName = IntranetChatterButtonController.UserGroupName;
		
		//======================== Check Office Selection List ======================================
		
		List<SelectOption> officeSelectList = controller.currentOfficeSelectList;
		
		//Assert for Check if Office List is Not Null and Size is greater then zero
		System.assertEquals(true, officeSelectList != null && officeSelectList.size() > 0);
        
        //Check If Default Office Is not Assigned to the User, then Default Office Always will be set to DC office 
        //So Assert to check if Default Office COmes as selected office for DC office
        //Get Office Id of DC office
        List<Intranet_Item__c> dcOfficeItem = [select Id from Intranet_Item__c where Office_Name__c = 'Washington, DC' AND  Item_Type__c='Office Location']; 
        
        //Asert to check that If Default Selected Office Id match with THis Dc Office Item Id because user was not assigned to any office
        System.assertEquals(true, controller.getSelectedOfficeId() == dcOfficeItem[0].Id);
        
        //Reset User Assigned office Default from IntranetHomeUtitlity as Dc Office
        IntranetHomeUtility.getUserSession.AssignedOffice = null;
        
        //Not Same assert to check If Default Office is still DC office
        System.assertEquals(true, controller.getSelectedOfficeId() == dcOfficeItem[0].Id);
        
        //Update User with Austing Office Id
        List<Intranet_Item__c> austingOffice = [select Id from Intranet_Item__c where Office_Name__c = 'Austin, TX' AND  Item_Type__c='Office Location']; 
        
        //Update User record with Job Level
        System.runAs(new User(Id = UserInfo.getUserId())) {
            
            update new User(Id = UserInfo.getUserId(), Job_Level__c = '10 B1 Early Professional',
                           ABC_Department__c = 'Enterprise Technologies', LastName='Test', office__c = austingOffice[0].Id);
        }
        
        //ReInstantiate Controller TO Reset User Session and Get Updated Value in It for Latest update like user is updated with new office
        IntranetHomeUtility.getUserSession = null;
        
        //Set values
        IntranetHomeUtility.UserBrowser = 'Chrome';
        IntranetHomeUtility.UserDevice = 'Mobile';
        IntranetHomeUtility.ScreenSize = 992;
        IntranetHomeUtility.NetworkAccess = 'Test';
        
        controller = new IntranetChatterButtonController();
        officeSelectList = controller.currentOfficeSelectList;
        
        Set<String> setOfficeNames = new Set<String>();
        for (SelectOption o : controller.currentOfficeSelectList)
            setOfficeNames.add(o.getLabel());
        
        //only 3 offices should be in the list for the current user, because Entity=EAB
        system.assertEquals(true, setOfficeNames.contains('DC Office'));
        system.assertEquals(true, setOfficeNames.contains('Chennai Office'));
        system.assertEquals(true, setOfficeNames.contains('Austin Office'));
        system.assertEquals(3, controller.currentOfficeSelectList.size(), 'Only 3 offices should be available, since the current user Entity=EAB');
        System.assertEquals(true, controller.getSelectedOfficeId() == austingOffice[0].Id);
        
        //Now Set Chennai Office as Selected Office and Check Its name in asserts
        List<Intranet_Item__c> chennaiOffice = [select Id from Intranet_Item__c where Office_Name__c = 'Chennai, India' AND  Item_Type__c='Office Location']; 
        controller.setSelectedOfficeId(chennaiOffice[0].Id);
        
        //Assert for Result
        System.assertEquals(true, controller.getSelectedOfficeName() == 'Chennai Office');
        
        //Stop Test
        Test.stopTest();
    }
 }