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
/** Description     :	Test class for BoardroomHomeContainerController.
  * 
  * Created Date    :	
  *
  * Created By      :   
  *  
  * Current vision  :	v1.0
  *  
  * Revision Logs   :	v1.0 - Created
  * 				:	V2.0 - Modifled By - Rajeev Jain(06/12/2015) - CR-20141002-7579
  *					:	V3.0 - Modified By - Rajeev Jain(09/15/2015) - CR-20141002-7579
					:	V4.0 - Modified By - Mahendra Swarnkar - 10/13/2016 - CR-20160926-10187
  * Coverage        :	90%
  **/ 
@isTest(seeAllData = false)
private class Test_IntranetOfficeController {
    
    //Setup all common data required in test class
    @testSetup static void setup() {
        
        //Insert intranet Constant Custom Setting
        Intranet_Constants__c intraConst = new Intranet_Constants__c();
        intraConst.SetupOwnerId = UserInfo.getUserId();
        intraConst.Allow_Schedule_Approval__c = true;
        insert intraConst;
        
        //Settings Office
        //Get Record Type for Content type fixed
        List<RecordType> headerRecordType = [select Id, DeveloperName, Name from RecordType where DeveloperName = 'Header'];
        List<RecordType> footerRecordType = [select Id, DeveloperName, Name from RecordType where DeveloperName = 'Footer'];
        List<RecordType> pageRecordType = [select Id, DeveloperName, Name from RecordType where DeveloperName = 'Page'];
        List<RecordType> contentFixed = [select Id, DeveloperName, Name from RecordType where DeveloperName = 'Content_Fixed'];
        List<RecordType> subContainetRecordType = [select Id, DeveloperName, Name from RecordType where DeveloperName = 'Content_SubContainer'];
		List<RecordType> staticRecordType = [select Id, DeveloperName, Name from RecordType where DeveloperName = 'Static'];
        List<RecordType> itemEventRecordType = [select Id, DeveloperName, Name from RecordType where DeveloperName = 'Item_Event'];
        List<RecordType> settingOfficeRecordType = [select Id, DeveloperName, Name from RecordType where DeveloperName = 'Settings_Office'];
        
        //Create Header and Footer Container
        List<Intranet_Container__c> listIntranetMainContainer = new List<Intranet_Container__c>();
        
        //Add Header Container
        listIntranetMainContainer.add(new Intranet_Container__c(Name = 'Header-Primary-BoardroomHeader',
                                                                Container_Type__c = 'Header',
                                                                Status__c = 'Active',
                                                                RecordTypeId = headerRecordType[0].Id));
        listIntranetMainContainer.add(new Intranet_Container__c(Name = 'Footer-Primary-BoardroomFooter',
                                                                Container_Type__c = 'Footer',
                                                                Status__c = 'Active',
                                                                RecordTypeId = footerRecordType[0].Id));
        
        insert listIntranetMainContainer;
        
        //Intranet Main Container and associate to header and footer
        Intranet_Container__c mainCOntainer = new Intranet_Container__c(Name='Page-Primary-Boardroom',
                                                                       	Container_Type__c = 'Page Section',
                                                                        Status__c = 'Active',
                                                                        RecordTypeId = pageRecordType[0].Id,
                                                                       	Display_Name__c='Boardroom',
                                                                        Header_Container__c = listIntranetMainContainer[0].Id,
                                                                        Footer_Container__c = listIntranetMainContainer[1].Id);
        insert mainCOntainer;
        
        //Intranet Office Container
        Intranet_Container__c officeContainer = new Intranet_Container__c(Name='Content - Fixed-Boardroom-Office',
                                                                       	Container_Type__c = 'ABC Office',
                                                                        Status__c = 'Active',
                                                                        Parent_Container__c = mainCOntainer.Id,
                                                                        RecordTypeId = contentFixed[0].Id,
                                                                       	Display_Name__c='Office',
                                                                        Content_Types_Allowed__c = 'Page Section');
        insert officeContainer;
        
        //Insert List of SubContainers Below It
        List<Intranet_Container__c> subContainers = new List<Intranet_Container__c>();
        
        //Food Container
        Intranet_Container__c foodContainer = new Intranet_Container__c(Name='Content - SubContainer-Office-Food',
                                                                       	Container_Type__c = 'SubContainer',
                                                                        Status__c = 'Active',
                                                                        RecordTypeId = subContainetRecordType[0].Id,
                                                                        Parent_Container__c = officeContainer.Id,
                                                                       	Display_Name__c='Food',
                                                                        Sort_Order__c = 1,
                                                                        Content_Types_Allowed__c = 'Food Link; Page Section');
        
        
        Intranet_Container__c weatherContainer = new Intranet_Container__c(Name='Content - SubContainer-Office-Weather',
                                                                           Container_Type__c = 'SubContainer',
                                                                           Status__c = 'Active',
                                                                           RecordTypeId = subContainetRecordType[0].Id,
                                                                           Parent_Container__c = officeContainer.Id,
                                                                           Display_Name__c='Weather',
                                                                           Sort_Order__c = 2,
                                                                           Content_Types_Allowed__c = 'Weather');
        
        
        Intranet_Container__c newsContainer = new Intranet_Container__c(Name='Content - SubContainer-Office-News',
                                                                       	Container_Type__c = 'SubContainer',
                                                                        Status__c = 'Active',
                                                                        RecordTypeId = subContainetRecordType[0].Id,
                                                                        Parent_Container__c = officeContainer.Id,
                                                                       	Display_Name__c='News',
                                                                        Sort_Order__c = 4,
                                                                        Content_Types_Allowed__c = 'Page Section');
        
        
        Intranet_Container__c officeEventContainer = new Intranet_Container__c(Name='Content - SubContainer-Office-Events',
                                                                               Container_Type__c = 'SubContainer',
                                                                               Status__c = 'Active',
                                                                               RecordTypeId = subContainetRecordType[0].Id,
                                                                               Parent_Container__c = officeContainer.Id,
                                                                               Display_Name__c='Events',
                                                                               Sort_Order__c = 4,
                                                                               Content_Types_Allowed__c = 'Office Event');
        
        subContainers.add(foodContainer);
        subContainers.add(weatherContainer);
        subContainers.add(newsContainer);
        subContainers.add(officeEventContainer);
        
        insert subContainers;
        
        //Item List
        List<Intranet_Item__c> itemList = new List<Intranet_Item__c>();
        
        //Insert Office Event Item
        Intranet_Item__c officeEventItem = new Intranet_Item__c();
		officeEventItem.Name = 'Come watch CNN - Office Event';
        officeEventItem.Item_Type__c = 'Office Event';
        officeEventItem.Item_Title__c = 'Come watch CNN';
        officeEventItem.Link_URL__c = 'http://www.cnn.com';
        officeEventItem.Link_Type__c = 'Standard';
        officeEventItem.Link_Action__c = 'Open in New Tab/Window';
        officeEventItem.RecordTypeId = itemEventRecordType[0].Id;
        officeEventItem.Active_Status__c = 'Active';
        officeEventItem.Approval_Status__c = 'Approved';
        officeEventItem.Event_Start_Date_Time__c = DateTime.now().addDays(1);
        officeEventItem.Event_End_Date_Time__c = DateTime.now().addDays(15);
        
        Intranet_Item__c officeIntranetItem = new Intranet_Item__c(Name = 'Austin - Office Location - Setting', 
                                                                   Approval_Status__c = 'Approved',
                                                                   RecordTypeId = settingOfficeRecordType[0].Id,
                                                                  Office_Name__c = 'Austin, TX',
                                                                  Office_Short_Name__c = 'Austin123',
                                                                  Item_Type__c = 'Office Location',
                                                                  Active_Status__c = 'Active',
                                                                  Location__Latitude__s = 38.9056,
                                                                  Location__Longitude__s = -77.05);
        
        itemList.add(officeEventItem);
        itemList.add(officeIntranetItem);
        
        //Insert Item List
        insert itemList;
        
        //List Of Schedules
        List<Intranet_Schedule__c> schedules = new List<Intranet_Schedule__c>();
        
        Intranet_Schedule__c cnnScheduleEvent = new Intranet_Schedule__c();
        cnnScheduleEvent.Name = 'Events - Come watch CNN';
        cnnScheduleEvent.Active_Status__c = 'Active';
        cnnScheduleEvent.Approval_Status__c = 'Approved';
        cnnScheduleEvent.Office__c = officeIntranetItem.Id;
        cnnScheduleEvent.Intranet_Container__c = officeEventContainer.Id;
        cnnScheduleEvent.Intranet_Item__c = officeEventItem.Id;
        cnnScheduleEvent.RecordTypeId = staticRecordType[0].Id; 
        
        schedules.add(cnnScheduleEvent);
        
        insert schedules;
        
        //Set User Session
        //Update User record with Job Level
        System.runAs(new User(Id = UserInfo.getUserId())) {
            
            update new User(Id = UserInfo.getUserId(), Job_Level__c = '10 B1 Early Professional',
                           office__c = officeIntranetItem.Id);
        }
    }
    
    static testMethod void myUnitTest() {
        
        //Get Main Container
        List<Intranet_Container__c> mainContainerList = [select Id from Intranet_Container__c where Name = 'Page-Primary-Boardroom'];
       	
        //Get Schedule 
        List<Intranet_Schedule__c> intranetScheduleList = [select Id, Intranet_Container__c, Intranet_Item__c, Is_Visible__c, 
                                                           Intranet_Item__r.Is_Visible__c, Intranet_Item__r.Name, Office__c
                                                           from Intranet_Schedule__c where Name = 'Events - Come watch CNN'];
        
        //Set Url of Current Page
        Test.setCurrentPage(new PageReference('/apex/Boardroom_Home_Container'));
        
        ///Pass Main Container Id from the URL
        ApexPages.currentPage().getParameters().put('IntranetMainPageId',mainContainerList[0].Id);
        
        //Get Office Container
        List<Intranet_Container__c> officeContainerList = [select Id from Intranet_Container__c where Name = 'Content - Fixed-Boardroom-Office'];
        
        //Set Mock Response
        Test.setMock(HttpCalloutMock.class, new IntranetOfficeWeatherMockResponse());
        
        //Start Test
        Test.startTest();
        
        IntranetOfficeController controller = new IntranetOfficeController();
        
        controller.OfficeContainerId = officeContainerList[0].Id;
        
        IntranetContainer getOfficeContainer = controller.OfficeContainer;
        
        controller.setSelectedOffice(intranetScheduleList[0].Intranet_Item__c);
        
        //List Select Option
        List<SelectOption> officeSelectList = controller.OfficeSelectList;
        
        //Selected Office Name
        String officeName = controller.getSelectedOfficeName();
        
        Intranet_Item__c officeData = controller.office;
        
        DateTime lastContentUpdate = controller.LastContentUpdate;
        
        Id mainImageOfficeId = controller.MainImageOfficeId;
        
        //========================= Weather Information ==========================================
        String positionId = IntranetOfficeWeatherMockResponse.LAT + ',' + IntranetOfficeWeatherMockResponse.LON;
        
        //Get Weather Data with Exception
        String weatherData = IntranetOfficeController.getWeather(positionId);
        
        //Adding office Id
        positionId += ',' + intranetScheduleList[0].Office__c;
        
        String weatherData1 = IntranetOfficeController.getWeather(positionId);
        
        String waetherCache = controller.weatherCache;
        Boolean weatherUpdate = controller.UpdateWeather;
        String locationData = controller.LocationData;
        
        //Set Last Content Update Date Time
        controller.LastContentUpdate = DateTime.now();
        
        controller.office.Last_Content_Update__c = DateTime.now().addDays(-1);
        weatherUpdate = controller.UpdateWeather;
        
        String weatherData2 = IntranetOfficeController.WEATHER_DATA;
        
        //Stop Test
        Test.stopTest();
        
        //Assert for Result that waether data should not be null
        System.assertEquals(String.isBlank(weatherData), true);
        System.assertEquals(String.isNotBlank(weatherData1), true);
    }
}