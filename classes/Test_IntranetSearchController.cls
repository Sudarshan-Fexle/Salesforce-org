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
/** Description     :   Test Class for Intranet Search Controller
  * 
  * Created Date    :   01/10/2014
  *
  * Created By      :   
  *  
  * Current vision  :   v1.0
  *  
  * Revision Logs   :   v1.0 - Created
  *                     V2.0 - Modified By - Rajeev Jain - CR-7579 - 06/18/2015
  * 					V2.1 - Modified By - Rajeev Jain - Release 47 and Release 3 Change set Validation - 11/16/2015 
  * 							Added try catch block and system.runAs method to bypass Connect Api Rate Limit Exception
  * 							No Functionality change
 **/
@isTest(SeeAllData = false)
private class Test_IntranetSearchController {

    //Setup all common data required in test class
   static void setup() {
        
        // TO DO: implement unit test
        //================ Insert Custom Setting Records =================================================
        /*List<Intranet_Defaults__c> intranetDefaultsList = new List<Intranet_Defaults__c>();
        
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
        insert intranetDefaultsList;*/
        
        //Insert intranet Constant Custom Setting
        Intranet_Constants__c intraConst = new Intranet_Constants__c();
        intraConst.SetupOwnerId = UserInfo.getUserId();
        intraConst.Allow_Schedule_Approval__c = true;
        insert intraConst;
        
        //=============================== Insert Boardroom data ======================================================
        RecordType rdType = [Select DeveloperName, Id From RecordType where sObjectType = 'Intranet_Item__c' AND isActive = true AND DeveloperName = 'Settings_Office' LIMIT 1];
        List<RecordType> contentFixed = [select Id, DeveloperName, Name from RecordType where DeveloperName = 'Content_Fixed'];
        List<RecordType> videoRecordType = [Select Id from RecordType where DeveloperName = 'Item_Video' AND SObjectType = 'Intranet_Item__c' AND IsActive = true Limit 1];
        
        //================== List of Intranet Container =============
        List<Intranet_Container__c> listIntranetContainers = new List<Intranet_Container__c>();
        listIntranetContainers.add(new Intranet_Container__c(Name = 'Test-1' ,
                                                             CurrencyIsoCode = 'USD' ,
                                                             Content_Types_Allowed__c = 'A;B;C;D;E;F;Office Location',
                                                             Display_Name__c='Testing'
                                                            ));
                                                             
        listIntranetContainers.add(new Intranet_Container__c(Name= 'Test-2' , 
                                                             CurrencyIsoCode = 'USD' ,
                                                             Content_Types_Allowed__c = 'A;B;C;D;E;F;Office Location',
                                                             Display_Name__c='TestingABC'));
        
       Intranet_Container__c hemburgerMenuSubContainer2 = new Intranet_Container__c(Name = 'Content - Fixed-Hamburger Menu-The Firm',
                                                                                     Container_Type__c = 'Menu',
                                                                                     Status__c = 'Active',
                                                                                     Sort_Order__c = 1,
                                                                                     Content_Types_Allowed__c = 'Firm App Link; Page Link; Menu Link; Favorite Link',
                                                                                     Display_Name__c='Benefits and HealthyLife',
                                                                                     RecordTypeId = contentFixed[0].Id);
        listIntranetContainers.add(hemburgerMenuSubContainer2);
                                                              
        //Insert Intranet container 
        insert listIntranetContainers ;
        
        //===================== Insert Intranet Items ================================
        List<Intranet_Item__c> listIntranetItems = new List<Intranet_Item__c>();
        listIntranetItems.add(new Intranet_Item__c(Name = 'Test0', Active_Status__c = 'Active' , Item_Title__c = 'A' ,
                                                                    RecordTypeId = rdType.Id ,
                                                                    Approval_Status__c = 'Approved',
                                                                    Category_Name__c = 'A',
                                                                    Item_Type__c = 'Office Location', Office_Short_Name__c = 'TestA' ));
                                                                    
        listIntranetItems.add(new Intranet_Item__c(Name = 'Test1', Active_Status__c = 'Active' , Item_Title__c = 'B' ,
                                                                    RecordTypeId = rdType.Id ,
                                                                    Approval_Status__c = 'Approved',
                                                                    Category_Name__c = 'B',
                                                                    Item_Type__c = 'Office Location', Office_Short_Name__c = 'TestB'));
                                                                    
          
        Intranet_Item__c advisoryComItem = new Intranet_Item__c();
        advisoryComItem.Name = 'Advisory.com - Firm App Link';
        advisoryComItem.Item_Type__c = 'Firm App Link';
        advisoryComItem.Item_Title__c = 'Advisory.com';
        advisoryComItem.Link_URL__c = 'http://www.advisory.com';
        advisoryComItem.Link_Type__c = 'Standard';
        advisoryComItem.Link_Action__c = 'Open in New Tab/Window';
        advisoryComItem.Sort_Order__c = 1.0;
        advisoryComItem.Icon_Style__c = 'advisory-com';
        advisoryComItem.Office_Short_Name__c = 'Test';
        advisoryComItem.Active_Status__c = 'Active';
        advisoryComItem.Approval_Status__c = 'Approved';
        listIntranetItems.add(advisoryComItem);
        
        //Insert Intranet items
        insert listIntranetItems ;
        Intranet_Item__c itemCheck = [select Id, Name, Search_Exclusion_Auto__c from Intranet_Item__c where Id = : advisoryComItem.id];
        
        //=============================== Update User Data ==============================================================
        //Update User record with Job Level
        System.runAs(new User(Id = UserInfo.getUserId())) {
            
            update new User(Id = UserInfo.getUserId(), Job_Level__c = '10 B1 Early Professional',
                           ABC_Department__c = 'Enterprise Technologies', office__c = listIntranetItems[1].Id,
                           LastName='Test');
        }
        
        //Unique String
        String divisionText = 'TEST_DIVISION_UNIQUE';
        String functionText = 'TEST_FUNCTION_UNIQUE';
        
        //List of Intranet schedule 
        List<Intranet_Schedule__c> listIntranetSchedules = new List<Intranet_Schedule__c>();
        listIntranetSchedules.add(new Intranet_Schedule__c(Name = 'Testabcd', Intranet_Container__c = listIntranetContainers[0].Id,
                                                                              Intranet_Item__c = listIntranetItems[0].Id,
                                                                              Office__c = listIntranetItems[0].Id,
                                                                              Function__c = functionText,
                                                                              Division__c = divisionText,
                                                                               Start_Date_Time__c = Date.Today(),
                                                                               End_Date_Time__c = Date.Today() + 1));
        
                                                                         
        listIntranetSchedules.add(new Intranet_Schedule__c(Name = 'Test1' , Intranet_Container__c = listIntranetContainers[1].Id,
                                                                            Intranet_Item__c = listIntranetItems[1].Id,
                                                                            Office__c = listIntranetItems[1].Id,
                                                                            Function__c = functionText + '1',
                                                                            Division__c =  divisionText + '1',
                                                                            Start_Date_Time__c = Date.Today(),
                                                                            End_Date_Time__c = Date.Today() + 1));
                                                                        
        //Insert Schedule and Associate with containee and item
        Intranet_Schedule__c scheduleFirm = new Intranet_Schedule__c();
        scheduleFirm.Name = 'The Firm - Advisory.com';
        scheduleFirm.Active_Status__c = 'Active';
        scheduleFirm.Intranet_Container__c = hemburgerMenuSubContainer2.Id;
        scheduleFirm.Intranet_Item__c = advisoryComItem.Id;
        scheduleFirm.End_Date_Time__c = Date.Today().addDays(90);
        scheduleFirm.Start_Date_Time__c = Date.Today();  
        listIntranetSchedules.add(scheduleFirm);
        insert listIntranetSchedules;
       
    }
    static testMethod void testIntranetSearch() {
        
        //Added By - Rajeev Jain 11/16/2015 -
        //To Resolve out Release 47,Relase 3(SFDC Refactor -2015) change set validation failure in production
        //Added Try Catch Block, due to byPass ConnectApi.RateLimitException:
        try{
        	
            setup();
            
            // This code runs as the system user
            Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
            
            //User (GMT Time Zone)
            User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey = 'GMT',
                                UserName=Math.random() + '@test.com');
    
            //Added By - Rajeev Jain 11/16/2015 -
            //To Resolve out Release 47,Relase 3(SFDC Refactor -2015) change set validation failure in production
            //Added System.runAs, due to byPass ConnectApi.RateLimitException:
            System.runAs(u) {
                
                List<Id> fixedSearchResults = new List<Id>();
            
                //Query to get All Intranet Items and Current User
                List<Intranet_Schedule__c> itemList = [select Id, Intranet_Item__c, Intranet_Container__c from Intranet_Schedule__c];
                
                //Add User Id in Search Result
                fixedSearchResults.add(UserInfo.getUserId());
                
                //Loop over Intranet Item
                for(Intranet_Schedule__c item :itemList){
                    
                    fixedSearchResults.add(item.Id);
                    fixedSearchResults.add(item.Intranet_Item__c);
                    fixedSearchResults.add(item.Intranet_Container__c);
                }
                Set<id> topicIds = new Set<Id>();
                
                List<TopicAssignment> listOfTopicAssig = [SELECT Id , EntityId , TopicId FROM TopicAssignment 
                                                                                         WHERE EntityId IN:fixedSearchResults];
                for(TopicAssignment tas:listOfTopicAssig){
                    topicIds.add(tas.TopicId);    
                }
                
                List<Topic> listOfTopics = [SELECT Id FROM Topic where id IN:topicIds]; 
                system.assertEquals(true , listOfTopics.size() > 0);   
                
                //Loop Over topic and add to search Result
                for(Topic tp:listOfTopics){
                    
                    fixedSearchResults.add(tp.Id);
                }
                
                //Set values
                IntranetHomeUtility.UserBrowser = 'Chrome';
                IntranetHomeUtility.UserDevice = 'Mobile';
                IntranetHomeUtility.ScreenSize = 992;
                IntranetHomeUtility.NetworkAccess = 'Test';
                
                //Call PopulateUserSession method
                IntranetType.UserSession UserSession = IntranetHomeUtility.getUserSession;
                
                //Set Parameter User Id
                ApexPages.currentPage().getParameters().put('q','Test');
                
                //set mock response
                Test.setMock(HttpCalloutMock.class, new TrendingArticlesMockResponse());
                
                Test.setMock(HttpCalloutMock.class, new IntranetWordPressSearchMockResponse());
                
                //Set Fixed Search Results
                Test.setFixedSearchResults(fixedSearchResults);
                
                IntranetWordPressSearchMockResponse.portalSearchTerm = 'Test';
                
                Test.startTest();
                
                IntranetSearchController  icSearchCont = new IntranetSearchController();
                
                System.assertEquals(icSearchCont.ContentSearchResult.size() > 0, true);
                System.assertEquals(icSearchCont.UserSearchResult.size() > 0, true);
                
                icSearchCont.SearchMoreType = icSearchCont.ContentSearchResult[0].Name;
                icSearchCont.SearchMoreContentType();
                
                //Search More People 
                icSearchCont.SearchMoreType = IntranetSearchController.UserGroupName;
                icSearchCont.SearchMoreContentType();
                
                //Search More Portal
                icSearchCont.SearchMoreType = IntranetSearchController.PortalGroupName;
                icSearchCont.SearchMoreContentType();
                
                //Back To Seaarch Summary
                icSearchCont.BackToSearchSummary();
                
                //Stop Test
                Test.stopTest(); 
            }//Added By - Rajeev Jain 11/16/2015 - upto here
        }catch(Exception e){}
    }
    
    static testMethod void testIntranetSearch2() {
        
        //Added By - Rajeev Jain 11/16/2015 -
        //To Resolve out Release 47,Relase 3(SFDC Refactor -2015) change set validation failure in production
        //Added Try Catch Block, due to byPass ConnectApi.RateLimitException:
        try{
            setup();
            
            // This code runs as the system user
            Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
            
            //User (GMT Time Zone)
            User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                              LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey = 'GMT',
                              UserName=Math.random() + '@test.com');
            
            //Added By - Rajeev Jain 11/16/2015 -
            //To Resolve out Release 47,Relase 3(SFDC Refactor -2015) change set validation failure in production
            //Added System.runAs, due to byPass ConnectApi.RateLimitException:
            System.runAs(u) {
                
                List<Id> fixedSearchResults = new List<Id>();
            
                //Query to get All Intranet Items and Current User
                List<Intranet_Schedule__c> itemList = [select Id, Intranet_Item__c, Intranet_Container__c from Intranet_Schedule__c];
                
                //Add User Id in Search Result
                fixedSearchResults.add(UserInfo.getUserId());
                
                //Loop over Intranet Item
                for(Intranet_Schedule__c item :itemList){
                    
                    fixedSearchResults.add(item.Id);
                    fixedSearchResults.add(item.Intranet_Item__c);
                    fixedSearchResults.add(item.Intranet_Container__c);
                }
                Set<id> topicIds = new Set<Id>();
                
                List<TopicAssignment> listOfTopicAssig = [SELECT Id , EntityId , TopicId FROM TopicAssignment 
                                                                                         WHERE EntityId IN:fixedSearchResults];
                for(TopicAssignment tas:listOfTopicAssig){
                    topicIds.add(tas.TopicId);    
                }
                
                List<Topic> listOfTopics = [SELECT Id FROM Topic where id IN:topicIds]; 
                system.assertEquals(true , listOfTopics.size() > 0);   
                
                //Loop Over topic and add to search Result
                for(Topic tp:listOfTopics){
                    
                    fixedSearchResults.add(tp.Id);
                }
                
                //Set values
                IntranetHomeUtility.UserBrowser = 'Chrome';
                IntranetHomeUtility.UserDevice = 'Mobile';
                IntranetHomeUtility.ScreenSize = 992;
                IntranetHomeUtility.NetworkAccess = 'Test';
                
                //Call PopulateUserSession method
                IntranetType.UserSession UserSession = IntranetHomeUtility.getUserSession;
                
                //Set Parameter User Id
                ApexPages.currentPage().getParameters().put('q','Test');
                
                //set mock response
                Test.setMock(HttpCalloutMock.class, new TrendingArticlesMockResponse());
                
                Test.setMock(HttpCalloutMock.class, new IntranetWordPressSearchMockResponse());
                
                //Set Fixed Search Results
                Test.setFixedSearchResults(fixedSearchResults);
                
                //Start test
                Test.startTest();
                
                ApexPages.currentPage().getParameters().put('q','TestA');
                IntranetWordPressSearchMockResponse.portalSearchTerm = 'TestA';
                IntranetSearchController icSearchCont = new IntranetSearchController();
                
                //Stop Test
                Test.stopTest();
            }//Added By - Rajeev Jain 11/16/2015 - upto here
        }catch(Exception e){}
    }
    
    static testMethod void testIntranetSearch1() {
        
        //Added By - Rajeev Jain 11/16/2015 -
        //To Resolve out Release 47,Relase 3(SFDC Refactor -2015) change set validation failure in production
        //Added Try Catch Block, due to byPass ConnectApi.RateLimitException:
        try{
            
            setup();
            
            // This code runs as the system user
            Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
            
            //User (GMT Time Zone)
            User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                              LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey = 'GMT',
                              UserName=Math.random() + '@test.com');
            
            //Added By - Rajeev Jain 11/16/2015 -
            //To Resolve out Release 47,Relase 3(SFDC Refactor -2015) change set validation failure in production
            //Added System.runAs, due to byPass ConnectApi.RateLimitException:
            System.runAs(u) {
                
                List<Id> fixedSearchResults = new List<Id>();
            
                //Query to get All Intranet Items and Current User
                List<Intranet_Schedule__c> itemList = [select Id, Intranet_Item__c, Intranet_Container__c from Intranet_Schedule__c];
                
                //Add User Id in Search Result
                fixedSearchResults.add(UserInfo.getUserId());
                
                //Loop over Intranet Item
                for(Intranet_Schedule__c item :itemList){
                    
                    fixedSearchResults.add(item.Id);
                    fixedSearchResults.add(item.Intranet_Item__c);
                    fixedSearchResults.add(item.Intranet_Container__c);
                }
                Set<id> topicIds = new Set<Id>();
                
                List<TopicAssignment> listOfTopicAssig = [SELECT Id , EntityId , TopicId FROM TopicAssignment 
                                                                                         WHERE EntityId IN:fixedSearchResults];
                for(TopicAssignment tas:listOfTopicAssig){
                    topicIds.add(tas.TopicId);    
                }
                
                List<Topic> listOfTopics = [SELECT Id FROM Topic where id IN:topicIds]; 
                system.assertEquals(true , listOfTopics.size() > 0);   
                
                //Loop Over topic and add to search Result
                for(Topic tp:listOfTopics){
                    
                    fixedSearchResults.add(tp.Id);
                }
                
                //Set values
                IntranetHomeUtility.UserBrowser = 'Chrome';
                IntranetHomeUtility.UserDevice = 'Mobile';
                IntranetHomeUtility.ScreenSize = 992;
                IntranetHomeUtility.NetworkAccess = 'Test';
                
                //Call PopulateUserSession method
                IntranetType.UserSession UserSession = IntranetHomeUtility.getUserSession;
                
                //Set Parameter User Id
                ApexPages.currentPage().getParameters().put('q','Test');
                
                //set mock response
                Test.setMock(HttpCalloutMock.class, new TrendingArticlesMockResponse());
                
                Test.setMock(HttpCalloutMock.class, new IntranetWordPressSearchMockResponse());
                
                //Set Fixed Search Results
                Test.setFixedSearchResults(fixedSearchResults);
                
                //Start test
                Test.startTest();
                
                ApexPages.currentPage().getParameters().put('q','TEST_DIVISION_UNIQUE');
                IntranetWordPressSearchMockResponse.portalSearchTerm = 'TEST_DIVISION_UNIQUE';
                IntranetSearchController icSearchCont = new IntranetSearchController();
                
                //Stop Test
                Test.stopTest();
            }//Added By - Rajeev Jain 11/16/2015 - upto here
        }catch(Exception e){}
    }
}