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
/** Description     :  Test class for IntranetContentViewerController
  * 
  * Created Date    :  09/15/2014
  *
  * Created By      :   
  *  
  * Current vision  :  v1.0
  *  
  * Revision Logs   :  v1.0 - Created
  *                 :  V2.0 - Modifled By - Rajeev Jain(05/20/2015) - CR-20141002-7579
  *                 :  V3.0 - Modified By - Rajeev Jain(09/03/2015) - CR-20141002-7579
  *                 :  V4.0 - MOdified By - Rajeev Jain(08/20/2016) -
                    :  @Desc :  Manual merge of the code one line of code, which found different in both sandboxes during Q2C Deployment Task
  *					:  V5.0 - Modified By - Deepak kumawat - - Apollo - Run All Test Failures Fixes
  *	
  * Coverage        :  86%
  **/  
@isTest(seeAllData = false)
private class Test_IntranetContentViewerController {
    
    //Setup all common data required in test class
    @testSetup static void setup() {
        
        Intranet_Container__c container = new Intranet_Container__c(Name = 'TestContainer-1', CurrencyIsoCode = 'USD' , 
                                                                    Content_Types_Allowed__c = 'Training Event' ,
                                                                    Display_Name__c = 'TestContainer-1',
                                                                   Container_Type__c = 'ABC Office');
        insert container;
                                                                     
        Intranet_Item__c intranetItem = new Intranet_Item__c(Name = 'Test-0' , Active_Status__c = 'Active' , Entity__c = 'EAB',
                                                             Item_Type__c = 'Training Event' , Item_Title__c = 'Test-0');
        insert intranetItem;
        
        Intranet_Schedule__c intranetSchedule = new Intranet_Schedule__c(Name = 'TestSchedule1' , Intranet_Container__c = container.Id , Intranet_Item__c = intranetItem.Id, 
                                                                         Start_Date_Time__c = DateTime.now(), End_Date_Time__c = DateTime.now().addDays(28), Entity__c = 'EAB');
        insert intranetSchedule;
        
        //ANother Itranet Item which is not related to Scheudlue
        Intranet_Item__c officeItem = new Intranet_Item__c(Name = 'TestOfficeItem-0' , Active_Status__c = 'Active' , Entity__c = 'EAB',
                                                             Item_Type__c = 'Training Event' , Item_Title__c = 'OfficeItem-1');
        insert officeItem;
        
        //Insert Main Container
        //Insert intranet Constant Custom Setting to Allow user to approve schedule in test classes
        Intranet_Constants__c intraConst = new Intranet_Constants__c();
        intraConst.SetupOwnerId = UserInfo.getUserId();
        intraConst.Allow_Schedule_Approval__c = true;
        insert intraConst;
        
         //Update User record with Job Level
        System.runAs(new User(Id = UserInfo.getUserId())) {
            
            update new User(Id = UserInfo.getUserId(), Job_Level__c = '10 B1 Early Professional');
        }
        
        //Settings Office
        RecordType rType = [Select Id, DeveloperName From RecordType where sObjectType='Intranet_Item__c' AND DeveloperName = 'Settings_Office' AND isActive=true];
        
        //Insert SubContainer which will be used to test IntranetContainer By Passing SubContainer Id
        Intranet_Container__c subContainer = new Intranet_Container__c(Name = 'Test-1', CurrencyIsoCode = 'USD' , 
                                                                    Content_Types_Allowed__c = 'Training Event' ,
                                                                    Display_Name__c = 'NewsCarousal-SubContainer',
                                                                   Container_Type__c = 'News Carousel',
                                                                   Parent_Container__c = container.Id);
        insert subContainer;
        
        //Insert DC office Item
         Intranet_Item__c dcOfficeItem = new Intranet_Item__c(Name = 'Test-0' , Active_Status__c = 'Active' , Entity__c = 'EAB',
                                                             Item_Type__c = 'Training Event' , 
                                                           Item_Title__c = 'Dc Office Item',
                                                          Office_Short_Name__c = 'DC Office 1', 
                                                           RecordTypeId = rType.Id);
        insert dcOfficeItem;
        
        //Insert Office Schedule
        Intranet_Schedule__c intranetOfficeSchedule = new Intranet_Schedule__c(Name = 'Test Office Schdule' , Intranet_Container__c = container.Id ,
                                                                         Active_Status__c = 'Active',Entity__c = 'EAB',
                                                                         Intranet_Item__c = intranetItem.Id, Office__c = dcOfficeItem.Id,
                                                                         Start_Date_Time__c = DateTime.now().addDays(-1), 
                                                                         End_Date_Time__c = DateTime.now().addDays(28));
        insert intranetOfficeSchedule;
    }
    
    static testMethod void testIntranetContentViewerCalendar() {
        
        //Get Intranet Items
        List<Intranet_Item__c> items = [select Id from Intranet_Item__c where Item_Title__c = 'Test-0' LIMIT 1];
        List<Intranet_Schedule__c> schedules = [select Id from Intranet_Schedule__c where Intranet_Item__c = :items[0].Id LIMIT 1];
        List<Intranet_Container__c> containers = [select Id from Intranet_Container__c where Display_Name__c = 'TestContainer-1' LIMIT 1];
        
        List<Intranet_Item__c> dcOffice = [select Id from Intranet_Item__c where Item_Title__c = 'Dc Office Item' LIMIT 1];
        
        //Set Page Parameteres
        ApexPages.currentPage().getParameters().put('ScheduleId', schedules[0].Id);
        ApexPages.currentPage().getParameters().put('ContainerId', containers[0].Id);
        ApexPages.currentPage().getParameters().put('View', 'office event');
        ApexPages.currentPage().getParameters().put('Mode', 'calendar');
        ApexPages.currentPage().getParameters().put('OfficeId', items[0].Id);
        
        //Start Test
        Test.startTest();
        
        //Instantiate Controller
        IntranetContentViewerController controller = new IntranetContentViewerController();
        
        System.assertEquals(true, controller.getOfficeName() == null);
        
        //Get Data String for Container
        String dataString = controller.getDataString();
        
        //Get Current Week Dates
        List<Date> currentWeekDates = controller.getWeekDates();
        
        //Get Current Week Data
        List<IntranetContentViewerController.CalendarWrapper> currentWeekData = controller.getWrapperList();
        
        //Load Next WeekData
        controller.LoadNextWeekData();
        
        //Get Next Week Dates
        List<Date> nextWeekDates = controller.getWeekDates();
        
         //Get Next Week Data
        List<IntranetContentViewerController.CalendarWrapper> nextWeekData = controller.getWrapperList();
        
        //Load Previous WeekData
        controller.LoadPreviousWeekData();
        
        //Get Previous Week Dates
        List<Date> previousWeekDates = controller.getWeekDates();
        
         //Get Previous Week Data
        List<IntranetContentViewerController.CalendarWrapper> previousWeekData = controller.getWrapperList();
        
        //Get office name Defautl To DC office
        ApexPages.currentPage().getParameters().put('OfficeId', dcOffice[0].Id);
        IntranetContentViewerController controller1 = new IntranetContentViewerController();
        
        //Stop Test
        Test.stopTest();
        
        //Assert for Result
        System.assertEquals(true, IntranetContentViewerController.Container.RelatedContent.size()>0);
        System.assertEquals(true, !String.isBlank(dataString));
        System.assertEquals(true, currentWeekDates.size() > 0);
        System.assertEquals(true, currentWeekData.size() > 0);
        System.assertEquals(false, controller.getNoWeeklyData());
        System.assertEquals(Datetime.newInstance(2000, currentWeekDates[0].month(), 1).format('MMMM'), controller.getMonth());
        System.assertEquals(DateTime.now().format('yyMMdd'), controller.getTodayDate());
        System.assertEquals(true, nextWeekDates.size() > 0);
        System.assertEquals(true, nextWeekData.size() > 0);
        System.assertEquals(true, previousWeekDates.size() > 0);
        System.assertEquals(true, previousWeekData.size() > 0);
        System.assertEquals(true, controller1.getOfficeName() != null);
        System.assertEquals(true, controller1.MainIntranetContent == null);
    }
    
    static testMethod void testIntranetContentViewerBasedOnSearchContentType() {
        
         //Get Intranet Items
        List<Intranet_Item__c> items = [select Id from Intranet_Item__c where Item_Title__c = 'Test-0' LIMIT 1];
        List<Intranet_Container__c> containers = [select Id from Intranet_Container__c where Display_Name__c = 'TestContainer-1' LIMIT 1];
        
        //Get Office Item
        List<Intranet_Item__c> officeItems = [select Id from Intranet_Item__c where Item_Title__c = 'OfficeItem-1' LIMIT 1];
        
        //Set Page 
        //Pass Content Id which is not related to Current Schedule so schedule can b e accessued based on Item Type
        ApexPages.currentPage().getParameters().put('SearchContentId', officeItems[0].Id);
        ApexPages.currentPage().getParameters().put('SearchContentType', 'Training Event');
        ApexPages.currentPage().getParameters().put('ContainerId', containers[0].Id);
        ApexPages.currentPage().getParameters().put('View', 'office event');
        ApexPages.currentPage().getParameters().put('Mode', 'calendar');
        ApexPages.currentPage().getParameters().put('OfficeId', items[0].Id);
        
        //Start Test
        Test.startTest();
        
        //Instantiate Controller
        IntranetContentViewerController controller = new IntranetContentViewerController();
        
        //Get Data String for Container
        String dataString = controller.getDataString();
        
        //Stop Test
        Test.stopTest();
        
        //Assert for Result
        System.assertEquals(true, IntranetContentViewerController.Container.RelatedContent.size()>0);
    }
    
    static testMethod void testIntranetContentViewerBasedOnContainer() {
        
        //Get NewsCarousal COntainer which was added as subcontainer
        List<Intranet_Container__c> containers = [select Id from Intranet_Container__c where Display_Name__c = 'NewsCarousal-SubContainer' LIMIT 1];
        
        //Set Page 
        //Pass Content Id which is not related to Current Schedule so schedule can b e accessued based on Item Type
        ApexPages.currentPage().getParameters().put('SearchContentType', 'Training Event');
        ApexPages.currentPage().getParameters().put('ContainerId', containers[0].Id);
        ApexPages.currentPage().getParameters().put('View', 'office event');
        ApexPages.currentPage().getParameters().put('Mode', 'calendar');
        
        //Start Test
        Test.startTest();
        
        //Instantiate Controller
        IntranetContentViewerController controller = new IntranetContentViewerController();
        
        //Get Data String for Container
        String dataString = controller.getDataString();
        
        
        //Stop Test
        Test.stopTest();
    }
    
    static testMethod void testIntranetContentViewerBasedOnOtherMode() {
        
         //Get Intranet Items
        List<Intranet_Item__c> items = [select Id from Intranet_Item__c where Item_Title__c = 'Test-0' LIMIT 1];
        List<Intranet_Schedule__c> schedules = [select Id from Intranet_Schedule__c where Intranet_Item__c = :items[0].Id LIMIT 1];
        List<Intranet_Container__c> containers = [select Id from Intranet_Container__c where Display_Name__c = 'TestContainer-1' LIMIT 1];
        
        //Set Page Parameteres
        ApexPages.currentPage().getParameters().put('ScheduleId', schedules[0].Id);
        ApexPages.currentPage().getParameters().put('ContainerId', containers[0].Id);
        ApexPages.currentPage().getParameters().put('View', 'office event');
        ApexPages.currentPage().getParameters().put('Mode', 'comment');
        ApexPages.currentPage().getParameters().put('OfficeId', items[0].Id);
        
        //Start Test
        Test.startTest();
        
         //Instantiate Controller
        IntranetContentViewerController controller = new IntranetContentViewerController();
        
        //Stop Test
        Test.stopTest();
        
        //Assert for Result
        System.assertEquals(true, IntranetContentViewerController.Container.RelatedContent.size()>0);
    }
    
    static testMethod void testIntranetContentViwerCalendarForMobile() {
        
        //Get Record Types
        List<RecordType> pageRecordType = [select Id, DeveloperName, Name from RecordType where DeveloperName = 'Page'];
        List<RecordType> subContainerRecordType = [select Id, DeveloperName, Name from RecordType where DeveloperName = 'Content_SubContainer'];
        List<RecordType> contentFixed = [select Id, DeveloperName, Name from RecordType where DeveloperName = 'Content_Fixed'];
        List<RecordType> itemEventRecordTypeId = [select Id, DeveloperName, Name from RecordType where DeveloperName = 'Item_Event'];
        List<RecordType> staticRecordType = [select Id, DeveloperName, Name from RecordType where DeveloperName = 'Static'];
        
        //Intranet Main Container and associate to header and footer
        Intranet_Container__c mainCOntainer = new Intranet_Container__c(Name='Page-Primary-Boardroom',
                                                                         Container_Type__c = 'Page Section',
                                                                        Status__c = 'Active',
                                                                        RecordTypeId = pageRecordType[0].Id,
                                                                         Display_Name__c='Boardroom'
                                                                        );
        insert mainCOntainer;
        
        //Insert primary Container as ABC Today Container which will be used to display Training Events in Calendar
        //Abc Todya 3
        Intranet_Container__c abcToday = new Intranet_Container__c();
        abcToday.Name = 'Content - Fixed-Boardroom-ABC Today';
        abcToday.Status__c = 'Active';
        abcToday.Container_Type__c = 'ABC Today';
        abcToday.Content_Types_Allowed__c = 'Page Section';
        abcToday.Display_Name__c = 'ABC Today';
        abcToday.RecordTypeId = contentFixed[0].Id;
        abcToday.Parent_Container__c = mainCOntainer.Id;
        insert abcToday;
        
        //Insert List of SubContainer for ABC Today component
        List<Intranet_Container__c> abcTodaySubContainers = new List<Intranet_Container__c>();
        
        Intranet_Container__c abcTraining = new Intranet_Container__c();
        abcTraining.Name = 'Content - SubContainer-ABC Today-Training';
        abcTraining.Status__c = 'Active';
        abcTraining.Container_Type__c = 'SubContainer';
        abcTraining.Content_Types_Allowed__c = 'Training Event';
        abcTraining.Display_Name__c = 'Training';
        abcTraining.RecordTypeId = subContainerRecordType[0].Id;
        abcTraining.Parent_Container__c = abcToday.Id;
        abcTodaySubContainers.add(abcTraining);
        
        //Insert List Of Items for Schedules
        Intranet_Container__c abcMemberEvent = new Intranet_Container__c();
        abcMemberEvent.Name = 'Content - SubContainer-ABC Today-Member Events';
        abcMemberEvent.Status__c = 'Active';
        abcMemberEvent.Container_Type__c = 'SubContainer';
        abcMemberEvent.Content_Types_Allowed__c = 'Member Event';
        abcMemberEvent.Display_Name__c = 'Member Events';
        abcMemberEvent.RecordTypeId = subContainerRecordType[0].Id;
        abcMemberEvent.Parent_Container__c = abcToday.Id;
        abcTodaySubContainers.add(abcMemberEvent);
        
        insert abcTodaySubContainers;
        
        //Insert ABC Training and Member Event Items
        List<Intranet_Item__c> eventList = new List<Intranet_Item__c>();
        Intranet_Item__c item1 = new Intranet_Item__c();
        item1.Active_Status__c = 'Active';
        item1.Approval_Status__c = 'Approved';
        item1.Name = 'Situational Leadership';
        item1.Item_Type__c = 'Training Event';
        item1.Item_Title__c = 'Situational Leadership';
        item1.Link_URL__c = 'http://abctraining.advisory.com/default.aspx';
        item1.Link_Type__c = 'Standard';
        item1.Link_Action__c = 'Open in New Tab/Window';
        item1.Event_Type__c = 'ABC Training';
        //V4.0 - MOdified By - Rajeev Jain(08/20/2016) - Manual merge as part of deployment task
        item1.Event_Start_Date_Time__c = DateTime.now().addDays(-10); 
        //V4.0 - MOdified By - Rajeev Jain(08/20/2016) - Upto here
        item1.Event_End_Date_Time__c = DateTime.now().addDays(50);
        item1.Room_Name__c = 'D.C. Only (Multipurpose 612)';
        item1.RecordTypeId = itemEventRecordTypeId[0].Id;
        
        Intranet_Item__c item2 = new Intranet_Item__c();
        item2.Active_Status__c = 'Active';
        item2.Approval_Status__c = 'Approved';
        item2.Name = 'Application Security 101';
        item2.Item_Type__c = 'Training Event';
        item2.Item_Title__c = 'Application Security 101';
        item2.Link_URL__c = 'http://abctraining.advisory.com/default.aspx';
        item2.Link_Type__c = 'Standard';
        item2.Link_Action__c = 'Open in New Tab/Window';
        item2.Event_Type__c = 'ABC Training';
        item2.Event_Start_Date_Time__c = DateTime.now();
        item2.Event_End_Date_Time__c = DateTime.now().addDays(10);
        item2.Room_Name__c = 'DC Only (Multipurpose 612)';
        item2.Event_Status__c = 'REGISTRATION OPEN';
        item2.RecordTypeId = itemEventRecordTypeId[0].Id;
        
        Intranet_Item__c item3 = new Intranet_Item__c();
        item3.Active_Status__c = 'Active';
        item3.Approval_Status__c = 'Approved';
        item3.Name = 'Application Security 102';
        item3.Item_Type__c = 'Training Event';
        item3.Item_Title__c = 'Application Security 102';
        item3.Link_URL__c = 'http://abctraining.advisory.com/default.aspx';
        item3.Link_Type__c = 'Standard';
        item3.Link_Action__c = 'Open in New Tab/Window';
        item3.Event_Type__c = 'ABC Training';
        item3.Event_Start_Date_Time__c = DateTime.now();
        item3.Event_End_Date_Time__c = DateTime.now().addDays(10);
        item3.Room_Name__c = 'DC Only (Multipurpose 612)';
        item3.Event_Status__c = 'REGISTRATION OPEN';
        item3.RecordTypeId = itemEventRecordTypeId[0].Id;
        
        Intranet_Item__c item4 = new Intranet_Item__c();
        item4.Active_Status__c = 'Active';
        item4.Approval_Status__c = 'Approved';
        item4.Name = 'Situational Leadership1';
        item4.Item_Type__c = 'Training Event';
        item4.Item_Title__c = 'Situational Leadership1';
        item4.Link_URL__c = 'http://abctraining.advisory.com/default.aspx';
        item4.Link_Type__c = 'Standard';
        item4.Link_Action__c = 'Open in New Tab/Window';
        item4.Event_Type__c = 'ABC Training';
        item4.Event_Start_Date_Time__c = DateTime.now().addDays(10);
        item4.Event_End_Date_Time__c = DateTime.now().addDays(20);
        item4.Room_Name__c = 'D.C. Only (Multipurpose 612)';
        item4.RecordTypeId = itemEventRecordTypeId[0].Id;
        
        Intranet_Item__c item5 = new Intranet_Item__c();
        item5.Active_Status__c = 'Active';
        item5.Approval_Status__c = 'Approved';
        item5.Name = 'Application Security 103 ';
        item5.Item_Type__c = 'Training Event';
        item5.Item_Title__c = 'Application Security 103';
        item5.Link_URL__c = 'http://abctraining.advisory.com/default.aspx';
        item5.Link_Type__c = 'Standard';
        item5.Link_Action__c = 'Open in New Tab/Window';
        item5.Event_Type__c = 'ABC Training';
        item5.Event_Start_Date_Time__c = DateTime.now().addDays(10);
        item5.Event_End_Date_Time__c = DateTime.now().addDays(20);
        item5.Room_Name__c = 'DC Only (Multipurpose 612)';
        item5.Event_Status__c = 'REGISTRATION OPEN';
        item5.RecordTypeId = itemEventRecordTypeId[0].Id;
        
        Intranet_Item__c item6 = new Intranet_Item__c();
        item6.Active_Status__c = 'Active';
        item6.Approval_Status__c = 'Approved';
        item6.Name = 'Application Security 104';
        item6.Item_Type__c = 'Training Event';
        item6.Item_Title__c = 'Application Security 104';
        item6.Link_URL__c = 'http://abctraining.advisory.com/default.aspx';
        item6.Link_Type__c = 'Standard';
        item6.Link_Action__c = 'Open in New Tab/Window';
        item6.Event_Type__c = 'ABC Training';
        item6.Event_Start_Date_Time__c = DateTime.now().addDays(10);
        item6.Event_End_Date_Time__c = DateTime.now().addDays(20);
        item6.Room_Name__c = 'DC Only (Multipurpose 612)';
        item6.Event_Status__c = 'REGISTRATION OPEN';
        item6.RecordTypeId = itemEventRecordTypeId[0].Id;
        
        Intranet_Item__c item7 = new Intranet_Item__c();
        item7.Active_Status__c = 'Active';
        item7.Approval_Status__c = 'Approved';
        item7.Name = 'Situational Leadership2';
        item7.Item_Type__c = 'Training Event';
        item7.Item_Title__c = 'Situational Leadership4';
        item7.Link_URL__c = 'http://abctraining.advisory.com/default.aspx';
        item7.Link_Type__c = 'Standard';
        item7.Link_Action__c = 'Open in New Tab/Window';
        item7.Event_Type__c = 'ABC Training';
        item7.Event_Start_Date_Time__c = DateTime.now().addDays(20);
        item7.Event_End_Date_Time__c = DateTime.now().addDays(30);
        item7.Room_Name__c = 'D.C. Only (Multipurpose 612)';
        item7.RecordTypeId = itemEventRecordTypeId[0].Id;
        
        Intranet_Item__c item8 = new Intranet_Item__c();
        item8.Active_Status__c = 'Active';
        item8.Approval_Status__c = 'Approved';
        item8.Name = 'Application Security 105';
        item8.Item_Type__c = 'Training Event';
        item8.Item_Title__c = 'Application Security 105';
        item8.Link_URL__c = 'http://abctraining.advisory.com/default.aspx';
        item8.Link_Type__c = 'Standard';
        item8.Link_Action__c = 'Open in New Tab/Window';
        item8.Event_Type__c = 'ABC Training';
        item8.Event_Start_Date_Time__c = DateTime.now().addDays(20);
        item8.Event_End_Date_Time__c = DateTime.now().addDays(30);
        item8.Room_Name__c = 'DC Only (Multipurpose 612)';
        item8.Event_Status__c = 'REGISTRATION OPEN';
        item8.RecordTypeId = itemEventRecordTypeId[0].Id;
        
        Intranet_Item__c item9 = new Intranet_Item__c();
        item9.Active_Status__c = 'Active';
        item9.Approval_Status__c = 'Approved';
        item9.Name = 'Application Security 106';
        item9.Item_Type__c = 'Training Event';
        item9.Item_Title__c = 'Application Security 106';
        item9.Link_URL__c = 'http://abctraining.advisory.com/default.aspx';
        item9.Link_Type__c = 'Standard';
        item9.Link_Action__c = 'Open in New Tab/Window';
        item9.Event_Type__c = 'ABC Training';
        item9.Event_Start_Date_Time__c = DateTime.now().addDays(20);
        item9.Event_End_Date_Time__c = DateTime.now().addDays(30);
        item9.Room_Name__c = 'DC Only (Multipurpose 612)';
        item9.Event_Status__c = 'REGISTRATION OPEN';
        item9.RecordTypeId = itemEventRecordTypeId[0].Id;
        
        eventList.add(item1); eventList.add(item2); eventList.add(item3); eventList.add(item4); eventList.add(item5);
        eventList.add(item6); eventList.add(item7); eventList.add(item8); eventList.add(item9);
        
        //Insert Items List
        insert eventList;
        
        //Insert Schedule
        List<Intranet_Schedule__c> scheduleList = new List<Intranet_Schedule__c>();
        
        Intranet_Schedule__c schedule1 = new Intranet_Schedule__c();
        schedule1.Name = 'Situational Leadership';
        schedule1.Active_Status__c = 'Active';
        schedule1.Approval_Status__c = 'Approved';
        schedule1.Intranet_Container__c = abcTraining.Id;
        schedule1.Intranet_Item__c = item1.Id;
        schedule1.RecordTypeId = staticRecordType[0].Id; 
        schedule1.Start_Date_Time__c = DateTime.now().addDays(-1);
        schedule1.End_Date_Time__c = DateTime.now().addDays(30);
       
        Intranet_Schedule__c schedule2 = new Intranet_Schedule__c();
        schedule2.Name = 'Application Security 101';
        schedule2.Active_Status__c = 'Active';
        schedule2.Approval_Status__c = 'Approved';
        schedule2.Intranet_Container__c = abcTraining.Id;
        schedule2.Intranet_Item__c = item2.Id;
        schedule2.RecordTypeId = staticRecordType[0].Id; 
        schedule2.Start_Date_Time__c = DateTime.now().addDays(-1);
        schedule2.End_Date_Time__c = DateTime.now().addDays(30);
        
        Intranet_Schedule__c schedule3 = new Intranet_Schedule__c();
        schedule3.Name = 'Application Security 101';
        schedule3.Active_Status__c = 'Active';
        schedule3.Approval_Status__c = 'Approved';
        schedule3.Intranet_Container__c = abcTraining.Id;
        schedule3.Intranet_Item__c = item3.Id;
        schedule3.RecordTypeId = staticRecordType[0].Id; 
        schedule3.Start_Date_Time__c = DateTime.now().addDays(-1);
        schedule3.End_Date_Time__c = DateTime.now().addDays(30);
        
        Intranet_Schedule__c schedule4 = new Intranet_Schedule__c();
        schedule4.Name = 'Situational Leadership1';
        schedule4.Active_Status__c = 'Active';
        schedule4.Approval_Status__c = 'Approved';
        schedule4.Intranet_Container__c = abcTraining.Id;
        schedule4.Intranet_Item__c = item4.Id;
        schedule4.RecordTypeId = staticRecordType[0].Id; 
        schedule4.Start_Date_Time__c = DateTime.now().addDays(-1);
        schedule4.End_Date_Time__c = DateTime.now().addDays(30);
        
        Intranet_Schedule__c schedule5 = new Intranet_Schedule__c();
        schedule5.Name = 'Application Security 103';
        schedule5.Active_Status__c = 'Active';
        schedule5.Approval_Status__c = 'Approved';
        schedule5.Intranet_Container__c = abcTraining.Id;
        schedule5.Intranet_Item__c = item5.Id;
        schedule5.RecordTypeId = staticRecordType[0].Id; 
        schedule5.Start_Date_Time__c = DateTime.now().addDays(-1);
        schedule5.End_Date_Time__c = DateTime.now().addDays(30);
        
        Intranet_Schedule__c schedule6 = new Intranet_Schedule__c();
        schedule6.Name = 'Application Security 104';
        schedule6.Active_Status__c = 'Active';
        schedule6.Approval_Status__c = 'Approved';
        schedule6.Intranet_Container__c = abcTraining.Id;
        schedule6.Intranet_Item__c = item6.Id;
        schedule6.RecordTypeId = staticRecordType[0].Id; 
        schedule6.Start_Date_Time__c = DateTime.now().addDays(-1);
        schedule6.End_Date_Time__c = DateTime.now().addDays(30);
       
        Intranet_Schedule__c schedule7 = new Intranet_Schedule__c();
        schedule7.Name = 'Situational Leadership2';
        schedule7.Active_Status__c = 'Active';
        schedule7.Approval_Status__c = 'Approved';
        schedule7.Intranet_Container__c = abcTraining.Id;
        schedule7.Intranet_Item__c = item7.Id;
        schedule7.RecordTypeId = staticRecordType[0].Id; 
        schedule7.Start_Date_Time__c = DateTime.now().addDays(-1);
        schedule7.End_Date_Time__c = DateTime.now().addDays(30);
        
        Intranet_Schedule__c schedule8 = new Intranet_Schedule__c();
        schedule8.Name = 'Application Security 105';
        schedule8.Active_Status__c = 'Active';
        schedule8.Approval_Status__c = 'Approved';
        schedule8.Intranet_Container__c = abcTraining.Id;
        schedule8.Intranet_Item__c = item8.Id;
        schedule8.RecordTypeId = staticRecordType[0].Id; 
        schedule8.Start_Date_Time__c = DateTime.now().addDays(-1);
        schedule8.End_Date_Time__c = DateTime.now().addDays(30);
        
        Intranet_Schedule__c schedule9 = new Intranet_Schedule__c();
        schedule9.Name = 'Application Security 106';
        schedule9.Active_Status__c = 'Active';
        schedule9.Approval_Status__c = 'Approved';
        schedule9.Intranet_Container__c = abcTraining.Id;
        schedule9.Intranet_Item__c = item9.Id;
        schedule9.RecordTypeId = staticRecordType[0].Id; 
        schedule9.Start_Date_Time__c = DateTime.now().addDays(-1);
        schedule9.End_Date_Time__c = DateTime.now().addDays(30);
        
        scheduleList.add(schedule1); scheduleList.add(schedule2); scheduleList.add(schedule3); scheduleList.add(schedule4); scheduleList.add(schedule5);
        scheduleList.add(schedule6); scheduleList.add(schedule7); scheduleList.add(schedule8); scheduleList.add(schedule9);
        insert scheduleList; 
        
        //Instantiate Controller and Load IntranetContentViewerData
        ApexPages.currentPage().getParameters().put('mode', 'calendar');
        ApexPages.currentPage().getParameters().put('view', 'training events');
        ApexPages.currentPage().getParameters().put('ContainerId', abcTraining.Id);
        ApexPages.currentPage().getParameters().put('lookAheadMobile', 'true');
        
        //Start Test
        Test.startTest();
        
         //Instantiate Controller
        IntranetContentViewerController controller = new IntranetContentViewerController();
        
        Date startDate = controller.StartDate;
        Date tempDate = Date.today().toStartOfWeek().addDays(1);
        
        Datetime dt = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
        String dayOfWeek=dt.format('EEEE');
        
        //Move it to next week if today is friday found in current week.
        if(dayOfWeek.equalsIgnoreCase('Friday')){
            tempDate = tempDate.addDays(7);    
        }
        
        //Assert for Result
        System.assertEquals(true, startDate == tempDate);
        
        //Get calendar Data without populating Wrapper List for WeekDays to Cover one condition
        IntranetContentViewerController.CalendarWrapper calData1 = controller.getDayCalendarData();
        
        //Assert to check if Calendar Data is not null
        System.assertEquals(true, calData1 != null);
        System.assertEquals(true, String.isBlank(calData1.fullDayString));
        System.assertEquals(true, String.isBlank(calData1.weekDayString));
        System.assertEquals(true, String.isBlank(calData1.weekDayNumber));
        System.assertEquals(true, String.isBlank(calData1.currentMonth));
        
        //Container will not have any items populated in Releted Content List
        System.assertEquals(true, IntranetContentViewerController.Container.RelatedContent.size()==0);
        
        //Reinstnatiate
        controller = new IntranetContentViewerController();
        
        //Wrapper List
        List<IntranetContentViewerController.CalendarWrapper> wrapperListData  = controller.getWrapperList();
        
        //Get Calendar Data for Look Ahead
        IntranetContentViewerController.CalendarWrapper calData = controller.getDayCalendarData();
        
        //Assert to check if Calendar Data is not null
        System.assertEquals(true, calData != null);
        
        //Assert to Check if Wrapper List having data
        System.assertEquals(true, wrapperListData != null && wrapperListData.size() > 0);
        
        //Go to Nexrt Day
        controller.navigateToNextDay();
        
        calData = controller.getDayCalendarData();
        
        //Assert to check if Calendar Data is not null
        System.assertEquals(true, calData != null);
        
        //Navigate to Previous Day
        controller.navigateToPreviousDay();
        
        //Assert to check if Calendar Data is not null
        System.assertEquals(true, calData != null);
        
        //Assert TO check Container is popualted with Event Items
        System.assertEquals(true, IntranetContentViewerController.Container.RelatedContent.size() == 0);
        
        //LOad Next Week Data
        controller.LoadNextWeekData();
        
        wrapperListData  = controller.getWrapperList();
        
        //Assert to Check if Wrapper List having data
        System.assertEquals(true, wrapperListData != null && wrapperListData.size() > 0);
        
        //LOad Next Week Data
        controller.LoadNextWeekData();
        
        wrapperListData  = controller.getWrapperList();
        
         //Assert to Check if Wrapper List having data
        System.assertEquals(true, wrapperListData != null && wrapperListData.size() > 0);
        
        //Load Previous Week Data
        controller.LoadPreviousWeekData();
        
        //Assert to Check if Wrapper List having data
        System.assertEquals(true, wrapperListData != null && wrapperListData.size() > 0);
        
        //Instantiate Controller and Load IntranetContentViewerData 
        ApexPages.currentPage().getParameters().put('lookAheadMobile', 'false');
        
        //ReInitialize COntroller
        controller = new IntranetContentViewerController();
        
        //Wrapper List
        wrapperListData  = controller.getWrapperList();
        
        //Get Calendar Data for Look Ahead
        calData = controller.getDayCalendarData();
        
        //Creater Search Start Date
        String searchStartDate = Date.today().addDays(2).month() + '/' + Date.today().addDays(2).day() +  '/' + Date.today().addDays(2).year();
        
        //========================== Test For Clicking on more info ===========================================
        //Instantiate Controller and Load IntranetContentViewerData
        ApexPages.currentPage().getParameters().put('mode', 'calendar');
        ApexPages.currentPage().getParameters().put('view', 'training events');
        ApexPages.currentPage().getParameters().put('ContainerId', abcTraining.Id);
        ApexPages.currentPage().getParameters().put('linkClick', 'MoreInfo');
        ApexPages.currentPage().getParameters().put('eventItemId', item1.Id);
        ApexPages.currentPage().getParameters().put('SearchStartDate', searchStartDate);
        
        //ReInitialize COntroller
        controller = new IntranetContentViewerController();
        
        //Wrapper List
        wrapperListData  = controller.getWrapperList();
        
        //Get Calendar Data for More Info
        calData = controller.getDayCalendarData();
        
        //Assert to check if Calendar Data is not null
        System.assertEquals(true, calData != null);
        
        //Assert to Check if Wrapper List having data
        System.assertEquals(true, wrapperListData != null && wrapperListData.size() > 0);
        
        //Assert to Check That Item Content List populated
        for(Integer i=0 ; i<wrapperListData.size();i++){
            System.assertEquals(true, wrapperListData[i].intranetContentList != null && wrapperListData[i].intranetContentList.size() == 0);
        }  
        
        //Load Next Week Data
        controller.navigateToNextDay(); 
        controller.navigateToPreviousDay();
        
        wrapperListData  = controller.getWrapperList();
        
        //Assert to Check if Wrapper List having data
        System.assertEquals(true, wrapperListData != null && wrapperListData.size() > 0);
        
        
        //Stop Test
        Test.stopTest();
        
    }
}