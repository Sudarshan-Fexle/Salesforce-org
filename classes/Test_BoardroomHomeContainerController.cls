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
/** Description     :  Test class for BoardroomHomeContainerController.
  * 
  * Created Date    :  09/15/2014
  *
  * Created By      :   
  *  
  * Current vision  :  v1.0
  *  
  * Revision Logs   :  v1.0 - Created
  *         		:  V2.0 - Modifled By - Rajeev Jain(05/20/2015) - CR-20141002-7579
  * 				:  V3.0 - Modified By - Rajeev Jain(07/10/2015) - CR-20150709-9072
  *
  * Coverage        :  86%
  **/  
@isTest(seeAllData = false)
private class Test_BoardroomHomeContainerController {
  private static String mainContainerId = '';
    
    static Map<String, RecordType> getMapRecordTypesWithName(){
    	
        Map<String, RecordType> mapRecordTypesWithName = new Map<String, RecordType>();
        for(RecordType rType : [Select Id, DeveloperName From RecordType where (sObjectType='Intranet_Schedule__c' OR sObjectType='Intranet_Container__c' OR sObjectType='Intranet_Item__c') AND isActive=true]) {
            
            //Put in map
            mapRecordTypesWithName.put(rType.DeveloperName, rType);
        }
        return mapRecordTypesWithName;
    }
    
    //Setup all common data required in test class
    @testSetup static void setup() {
        
        Map<String, RecordType> mapRecordTypesWithName = getMapRecordTypesWithName();
        
        //Get Header and footer and Main page Record Type
        List<RecordType> headerRecordType = [select Id, DeveloperName, Name from RecordType where DeveloperName = 'Header'];
        List<RecordType> footerRecordType = [select Id, DeveloperName, Name from RecordType where DeveloperName = 'Footer'];
        List<RecordType> pageRecordType = [select Id, DeveloperName, Name from RecordType where DeveloperName = 'Page'];
        List<RecordType> contentFixed = [select Id, DeveloperName, Name from RecordType where DeveloperName = 'Content_Fixed'];
        List<RecordType> contentFlexible = [select Id, DeveloperName, Name from RecordType where DeveloperName = 'Content_Flexible'];
        List<RecordType> itemLinkRecordTypeId = [select Id, DeveloperName, Name from RecordType where DeveloperName = 'Item_Link'];
        List<RecordType> staticRecordType = [select Id, DeveloperName, Name from RecordType where DeveloperName = 'Static'];
        List<RecordType> settingOfficeRecordType = [select Id, DeveloperName, Name from RecordType where DeveloperName = 'Settings_Office'];
        List<RecordType> itemFeatureRecordType = [Select Id from RecordType where DeveloperName = 'Item_Feature' AND SObjectType = 'Intranet_Item__c' AND IsActive = true Limit 1];
        List<RecordType> itemTrendingRecordType = [Select Id from RecordType where DeveloperName = 'Item_Trending' AND SObjectType = 'Intranet_Item__c' AND IsActive = true Limit 1];
        
        //Insert Main Container
    	//Insert intranet Constant Custom Setting
        Intranet_Constants__c intraConst = new Intranet_Constants__c();
        intraConst.SetupOwnerId = UserInfo.getUserId();
        intraConst.Allow_Schedule_Approval__c = true;
        insert intraConst;
        
        Top_5_Frequently_Accessed_Apps__c top5AccessedApp = new Top_5_Frequently_Accessed_Apps__c();
        top5AccessedApp.SetupOwnerId = UserInfo.getUserId();
        insert top5AccessedApp;
        
        //Create Header and Footer Container
        List<Intranet_Container__c> listIntranetMainContainer = new List<Intranet_Container__c>();
        
        //Add Header Container
        listIntranetMainContainer.add(new Intranet_Container__c(Name = 'Header-Primary-BoardroomHeader',
                                                                Container_Type__c = 'Header',
                                                                Status__c = 'Active',
                                                                RecordTypeId = mapRecordTypesWithName.get('Header').Id));
        listIntranetMainContainer.add(new Intranet_Container__c(Name = 'Footer-Primary-BoardroomFooter',
                                                                Container_Type__c = 'Footer',
                                                                Status__c = 'Active',
                                                                RecordTypeId = mapRecordTypesWithName.get('Footer').Id));
        
        insert listIntranetMainContainer;
        
         //Hamburger Menu Container
        Intranet_Container__c hemburgerMenuContainer = new Intranet_Container__c(Name = 'Content - Fixed-BoardroomHeader-Hamburger Menu',
                                                                                 Container_Type__c = 'Menu',
                                                                                 Status__c = 'Active',
                                                                                 Parent_Container__c = listIntranetMainContainer[0].Id,
                                                                                 Content_Types_Allowed__c = 'Firm App Link; Page Link; Menu Link; Favorite Link',
                                                                                 Display_Name__c='Hamburger Menu',
                                                                                 RecordTypeId = mapRecordTypesWithName.get('Content_Fixed').Id);
        
        insert hemburgerMenuContainer;
        
        
        List<Intranet_Container__c> hamburgerMenuSubContainers = new List<Intranet_Container__c>();
        
        //Create Subcontainers of Hamburger menu
        Intranet_Container__c hemburgerMenuSubContainer1 = new Intranet_Container__c(Name = 'Content - Fixed-Hamburger Menu-Benefits and HealthyLife',
                                                                                     Container_Type__c = 'Menu',
                                                                                     Status__c = 'Active',
                                                                                     Sort_Order__c = 2,
                                                                                     Parent_Container__c = hemburgerMenuContainer.Id,
                                                                                     Content_Types_Allowed__c = 'Firm App Link; Page Link; Menu Link; Favorite Link',
                                                                                     Display_Name__c='Benefits and HealthyLife',
                                                                                     RecordTypeId = mapRecordTypesWithName.get('Content_Fixed').Id);
        hamburgerMenuSubContainers.add(hemburgerMenuSubContainer1);
        
        Intranet_Container__c hemburgerMenuSubContainer2 = new Intranet_Container__c(Name = 'Content - Fixed-Hamburger Menu-The Firm',
                                                                                     Container_Type__c = 'Menu',
                                                                                     Status__c = 'Active',
                                                                                     Sort_Order__c = 1,
                                                                                     Parent_Container__c = hemburgerMenuContainer.Id,
                                                                                     Content_Types_Allowed__c = 'Firm App Link; Page Link; Menu Link; Favorite Link',
                                                                                     Display_Name__c='Benefits and HealthyLife',
                                                                                     RecordTypeId = mapRecordTypesWithName.get('Content_Fixed').Id);
        
        hamburgerMenuSubContainers.add(hemburgerMenuSubContainer2);
        
        insert hamburgerMenuSubContainers;
        
        //Insert Intranet Item and then Intranet Scheduel and associate both contianer and item to that schedule
        //So it can display as menu
        
        //Inseret List of Menu items
        List<Intranet_Item__c> menuItemList = new List<Intranet_Item__c>();
        
        Intranet_Item__c advisoryComItem1 = new Intranet_Item__c();
    	advisoryComItem1.Name = 'Advisory.com - Firm App Link';
        advisoryComItem1.Item_Type__c = 'Firm App Link';
        advisoryComItem1.Item_Title__c = 'Advisory.com';
        advisoryComItem1.Link_URL__c = 'http://www.advisory.com';
        advisoryComItem1.Link_Type__c = 'Standard';
        advisoryComItem1.Link_Action__c = 'Open in New Tab/Window';
        advisoryComItem1.Sort_Order__c = 1.0;
        advisoryComItem1.Icon_Style__c = 'advisory-com';
        menuItemList.add(advisoryComItem1);
        
        Intranet_Item__c advisoryComItem2 = new Intranet_Item__c();
    	advisoryComItem2.Name = 'One Advisory Board - Menu Link';
        advisoryComItem2.Item_Type__c = 'Menu Link';
        advisoryComItem2.Item_Title__c = 'One Advisory Board';
        advisoryComItem2.Link_URL__c = 'http://www.advisory.com';
        advisoryComItem2.Link_Type__c = 'Standard';
        advisoryComItem2.Link_Action__c = 'Open in New Tab/Window';
        advisoryComItem2.Sort_Order__c = 1.0;
        advisoryComItem2.Icon_Style__c = '';
        menuItemList.add(advisoryComItem2);
        
        Intranet_Item__c advisoryComItem3 = new Intranet_Item__c();
    	advisoryComItem3.Name = 'EAB.com - Firm App Link';
        advisoryComItem3.Item_Type__c = 'Firm App Link';
        advisoryComItem3.Item_Title__c = 'EAB.com';
        advisoryComItem3.Link_URL__c = 'http://eab.com';
        advisoryComItem3.Link_Type__c = 'Standard';
        advisoryComItem3.Link_Action__c = 'Open in New Tab/Window';
        advisoryComItem3.Sort_Order__c = 1.0;
        advisoryComItem3.Icon_Style__c = 'eab-com';
        menuItemList.add(advisoryComItem3);
        
        Intranet_Item__c advisoryComItem4 = new Intranet_Item__c();
    	advisoryComItem4.Name = 'InnovACTION - Menu Link';
        advisoryComItem4.Item_Type__c = 'Menu Link';
        advisoryComItem4.Item_Title__c = 'InnovACTION';
        advisoryComItem4.Link_URL__c = '';
        advisoryComItem4.Link_Type__c = 'Standard';
        advisoryComItem4.Link_Action__c = 'Open in New Tab/Window';
        advisoryComItem4.Sort_Order__c = 1.0;
        advisoryComItem4.Icon_Style__c = '';
        menuItemList.add(advisoryComItem4);
        
        Intranet_Item__c advisoryComItem5 = new Intranet_Item__c();
    	advisoryComItem5.Name = 'Elevate Your Effectiveness - Page Link';
        advisoryComItem5.Item_Type__c = 'Page Link';
        advisoryComItem5.Item_Title__c = 'Elevate Your Effectiveness';
        advisoryComItem5.Link_URL__c = 'https://advisory--brmobile2--c.cs7.visual.force...';
        advisoryComItem5.Link_Type__c = 'Standard';
        advisoryComItem5.Link_Action__c = 'Open in New Tab/Window';
        advisoryComItem5.Sort_Order__c = 1.0;
        advisoryComItem5.Icon_Style__c = '';
         
        menuItemList.add(advisoryComItem5);
        insert menuItemList;
        
        //Insert Schedule and Associate with containee and item
        //Insert Scheduel List
       	List<Intranet_Schedule__c> scheduleList = new List<Intranet_Schedule__c>();
       	
        Intranet_Schedule__c scheduleFirm1 = new Intranet_Schedule__c();
        scheduleFirm1.Name = 'The Firm - Advisory.com';
        scheduleFirm1.Active_Status__c = 'Active';
        scheduleFirm1.Intranet_Container__c = hemburgerMenuSubContainer2.Id;
        scheduleFirm1.Intranet_Item__c = advisoryComItem1.Id;
        scheduleFirm1.End_Date_Time__c = Date.Today().addDays(90);
        scheduleFirm1.Start_Date_Time__c = Date.Today();                                                                      
        scheduleList.add(scheduleFirm1);
        
        Intranet_Schedule__c scheduleFirm2 = new Intranet_Schedule__c();
        scheduleFirm2.Name = 'The Firm - One Advisory Board';
        scheduleFirm2.Active_Status__c = 'Active';
        scheduleFirm2.Intranet_Container__c = hemburgerMenuSubContainer2.Id;
        scheduleFirm2.Intranet_Item__c = advisoryComItem2.Id;
        scheduleFirm2.End_Date_Time__c = Date.Today().addDays(90);
        scheduleFirm2.Start_Date_Time__c = Date.Today();
        scheduleList.add(scheduleFirm2);
        
        Intranet_Schedule__c scheduleFirm3 = new Intranet_Schedule__c();
        scheduleFirm3.Name = 'The Firm - EAB.com';
        scheduleFirm3.Active_Status__c = 'Active';
        scheduleFirm3.Intranet_Container__c = hemburgerMenuSubContainer2.Id;
        scheduleFirm3.Intranet_Item__c = advisoryComItem3.Id;
        scheduleFirm3.End_Date_Time__c = Date.Today().addDays(90);
        scheduleFirm3.Start_Date_Time__c = Date.Today();
        scheduleList.add(scheduleFirm3);
        
        Intranet_Schedule__c scheduleFirm4 = new Intranet_Schedule__c();
        scheduleFirm4.Name = 'The Firm - InnovACTION';
        scheduleFirm4.Active_Status__c = 'Active';
        scheduleFirm4.Intranet_Container__c = hemburgerMenuSubContainer2.Id;
        scheduleFirm4.Intranet_Item__c = advisoryComItem4.Id;
        scheduleFirm4.End_Date_Time__c = Date.Today().addDays(90);
        scheduleFirm4.Start_Date_Time__c = Date.Today();
        scheduleList.add(scheduleFirm4);
        
        Intranet_Schedule__c scheduleFirm5 = new Intranet_Schedule__c();
        scheduleFirm5.Name = 'The Firm - Elevate Your Effectiveness';
        scheduleFirm5.Active_Status__c = 'Active';
        scheduleFirm5.Intranet_Container__c = hemburgerMenuSubContainer2.Id;
        scheduleFirm5.Intranet_Item__c = advisoryComItem5.Id;
        scheduleFirm5.End_Date_Time__c = Date.Today().addDays(90);
        scheduleFirm5.Start_Date_Time__c = Date.Today();
        scheduleList.add(scheduleFirm5);
        
        insert scheduleList;
        
        //Intranet Main Container and associate to header and footer
        Intranet_Container__c mainCOntainer = new Intranet_Container__c(Name='Page-Primary-Boardroom',
                                                                         Container_Type__c = 'Page Section',
                                                                        Status__c = 'Active',
                                                                        RecordTypeId = mapRecordTypesWithName.get('Page').Id,
                                                                         Display_Name__c='Boardroom',
                                                                        Header_Container__c = listIntranetMainContainer[0].Id,
                                                                        Footer_Container__c = listIntranetMainContainer[1].Id);
        insert mainCOntainer;
        
        mainContainerId = mainCOntainer.Id;
        
        //Insert Main Container SubContainer
        List<Intranet_Container__c> MainPageSubContainerList = new List<Intranet_Container__c>();
        
        //News Carousal Container 1
        Intranet_Container__c newsCarousal = new Intranet_Container__c();
        newsCarousal.Name = 'Content - Fixed-Boardroom-News';
        newsCarousal.Status__c = 'Active';
        newsCarousal.Container_Type__c = 'News Carousel';
        newsCarousal.Content_Types_Allowed__c = 'News Item';
        newsCarousal.Display_Name__c = 'News';
        newsCarousal.RecordTypeId = mapRecordTypesWithName.get('Content_Fixed').Id;
        newsCarousal.Parent_Container__c = mainCOntainer.Id;
        MainPageSubContainerList.add(newsCarousal);
        
        //Quick Links 2
        Intranet_Container__c quickLinks = new Intranet_Container__c();
        quickLinks.Name = 'Content - Fixed-Boardroom-Quick Links';
        quickLinks.Status__c = 'Active';
        quickLinks.Container_Type__c = 'QuickLinks';
        quickLinks.Content_Types_Allowed__c = 'Quick Link';
        quickLinks.Display_Name__c = 'Quick Links';
        quickLinks.RecordTypeId = mapRecordTypesWithName.get('Content_Fixed').Id;
        quickLinks.Parent_Container__c = mainCOntainer.Id;
        MainPageSubContainerList.add(quickLinks);
        
        //Abc Todya 3
        Intranet_Container__c abcToday = new Intranet_Container__c();
        abcToday.Name = 'Content - Fixed-Boardroom-ABC Today';
        abcToday.Status__c = 'Active';
        abcToday.Container_Type__c = 'ABC Today';
        abcToday.Content_Types_Allowed__c = 'Page Section';
        abcToday.Display_Name__c = 'ABC Today';
        abcToday.RecordTypeId = mapRecordTypesWithName.get('Content_Fixed').Id;
        abcToday.Parent_Container__c = mainCOntainer.Id;
        MainPageSubContainerList.add(abcToday);
        
        //Abc Video
        Intranet_Container__c abcVideo = new Intranet_Container__c();
        abcVideo.Name = 'Content - Fixed-Boardroom-ABC Video';
        abcVideo.Status__c = 'Active';
        abcVideo.Container_Type__c = 'Video';
        abcVideo.Content_Types_Allowed__c = 'Video Item';
        abcVideo.Display_Name__c = 'ABC Video';
        abcVideo.RecordTypeId = mapRecordTypesWithName.get('Content_Fixed').Id;
        abcVideo.Parent_Container__c = mainCOntainer.Id;
        MainPageSubContainerList.add(abcVideo);
        
        //Quick Poll
        Intranet_Container__c quickPoll = new Intranet_Container__c();
        quickPoll.Name = 'Content - Fixed-Boardroom-Quick Poll';
        quickPoll.Status__c = 'Active';
        quickPoll.Container_Type__c = 'Poll';
        quickPoll.Content_Types_Allowed__c = 'Poll Item';
        quickPoll.Display_Name__c = 'Quick Poll';
        quickPoll.RecordTypeId = mapRecordTypesWithName.get('Content_Fixed').Id;
        quickPoll.Parent_Container__c = mainCOntainer.Id;
        MainPageSubContainerList.add(quickPoll);
        
        //Trending
        Intranet_Container__c trendingContainer = new Intranet_Container__c();
        trendingContainer.Name = 'Content - Fixed-Boardroom-Trending';
        trendingContainer.Container_Type__c = 'Trending';
        trendingContainer.Content_Types_Allowed__c = 'Page Section';
        trendingContainer.Display_Name__c = 'Trending';
        trendingContainer.RecordTypeId = mapRecordTypesWithName.get('Content_Fixed').Id;
        trendingContainer.Parent_Container__c = mainCOntainer.Id;
        MainPageSubContainerList.add(trendingContainer);
        
        //Flexible 13
        Intranet_Container__c flexible13 = new Intranet_Container__c();
        flexible13.Name = 'Content - Flexible-Boardroom-Flexible-13';
        flexible13.Status__c = 'Active';
        flexible13.Container_Type__c = 'Flexible';
        flexible13.Content_Types_Allowed__c = 'Job Item';
        flexible13.Display_Name__c = 'Flexible-13';
        flexible13.RecordTypeId = mapRecordTypesWithName.get('Content_Flexible').Id;
        flexible13.Parent_Container__c = mainCOntainer.Id;
        MainPageSubContainerList.add(flexible13);
        
        //FLexible 15
        Intranet_Container__c flexible15 = new Intranet_Container__c();
        flexible15.Name = 'Content - Flexible-Boardroom-Flexible-15';
        flexible15.Container_Type__c = 'Flexible';
        flexible15.Content_Types_Allowed__c = 'Ad Item; Job Item';
        flexible15.Display_Name__c = 'Flexible-15';
        flexible15.RecordTypeId = mapRecordTypesWithName.get('Content_Flexible').Id;
        flexible15.Parent_Container__c = mainCOntainer.Id;
        MainPageSubContainerList.add(flexible15);
        
        Intranet_Container__c flexible16 = new Intranet_Container__c();
        flexible16.Name = 'Content - Flexible-Boardroom-Flexible-16';
        flexible16.Container_Type__c = 'Flexible';
        flexible16.Content_Types_Allowed__c = 'Ad Item; Job Item';
        flexible16.Display_Name__c = 'Flexible-16';
        flexible16.RecordTypeId = mapRecordTypesWithName.get('Content_Flexible').Id;
        flexible16.Parent_Container__c = mainCOntainer.Id;
        MainPageSubContainerList.add(flexible16);
        
        Intranet_Container__c flexible17 = new Intranet_Container__c();
        flexible17.Name = 'Content - Flexible-Boardroom-Flexible-17';
        flexible17.Container_Type__c = 'Flexible';
        flexible17.Content_Types_Allowed__c = 'Talent Item';
        flexible17.Display_Name__c = 'Flexible-17';
        flexible17.RecordTypeId = mapRecordTypesWithName.get('Content_Flexible').Id;
        flexible17.Parent_Container__c = mainCOntainer.Id;
        MainPageSubContainerList.add(flexible17);
        
        Intranet_Container__c flexible19 = new Intranet_Container__c();
        flexible19.Name = 'Content - Flexible-Boardroom-Flexible-19';
        flexible19.Container_Type__c = 'Flexible';
        flexible19.Content_Types_Allowed__c = 'Ad Item';
        flexible19.Display_Name__c = 'Flexible-19';
        flexible19.RecordTypeId = mapRecordTypesWithName.get('Content_Flexible').Id;
        flexible19.Parent_Container__c = mainCOntainer.Id;
        MainPageSubContainerList.add(flexible19);
        
        insert MainPageSubContainerList;
        
        List<Intranet_Item__c> itemList = new List<Intranet_Item__c>();
        
        Intranet_Item__c JobItem = new Intranet_Item__c(Name = 'Test-0', Active_Status__c = 'Active', Approval_Status__c = 'Approved',
                                                             Item_Type__c='Job Item',
                                                             item_Title__c = 'Managing Director, Solutions Consulting',
                                                            RecordTypeId = mapRecordTypesWithName.get('Item_Feature').Id);
        itemList.add(JobItem);
        
        //Create Intranet Item and One Schedule to Display in Quick Links
        Intranet_Item__c bookTravel = new Intranet_Item__c();
        bookTravel.Active_Status__c = 'Active';
        bookTravel.Approval_Status__c = 'Approved';
        bookTravel.Name = 'Book Travel - Quick Link';
        bookTravel.Item_Type__c = 'Quick Link';
        bookTravel.Item_Title__c = 'Book Travel';
        bookTravel.Link_URL__c = 'http://travel.advisory.com';
        bookTravel.Link_Type__c = 'Standard';
        bookTravel.Link_Action__c = 'Open in New Tab/Window';
        bookTravel.RecordTypeId = mapRecordTypesWithName.get('Item_Link').Id;
        
        itemList.add(bookTravel);
        
        //Create Birthday Item
        Intranet_Item__c birthdayItem = new Intranet_Item__c();
        birthdayItem.Active_Status__c = 'Active';
        birthdayItem.Approval_Status__c = 'Approved';
        birthdayItem.Name = 'Birthdays - Birthdays';
        birthdayItem.Item_Type__c = 'Birthdays';
        birthdayItem.Item_Title__c = 'Birthdays';
        birthdayItem.Birthdays_Cache__c = '[{"attributes":{"type":"User","url":"/services/data/v33.0/sobjects/User/'+ UserInfo.getUserId() +'"},"Office__c":"DC","SmallPhotoUrl":"'+ 'http://advisory.force.com/Query'+'/profilephoto/729C00000000qIW/T","FirstName":"test","Id":"' + UserInfo.getUserId() + '","ProfileId":"' + UserInfo.getProfileId() +'","ABC_Department__c":"Cost and Operations","LastName":"testUser"}]';
        birthdayItem.RecordTypeId = mapRecordTypesWithName.get('Item_Trending').Id;
        
		itemList.add(birthdayItem);
        
        //Create a defaould Intranet Item
        Intranet_Item__c defaultInranetItem = new Intranet_Item__c(RecordTypeId = itemFeatureRecordType[0].Id, 
                                                                     Active_Status__c = 'Active', Approval_Status__c = 'Approved',
                                                                    Item_type__c = 'System Status', Item_Title__c = 'All Systems Operating Normally',
                                                                    Default_Content_Flag__c = true);
        itemList.add(defaultInranetItem);
        
        //Add Office Item
        Intranet_Item__c officeItem = new Intranet_Item__c(Name = 'Test-0',Active_Status__c = 'Active',Item_Type__c='App Link',
                                                                   RecordTypeId = mapRecordTypesWithName.get('Settings_Office').Id,Item_Title__c = 'Test',  
                                                                   Category_Name__c = 'A',Color_Set_Name__c = 'ColorSet', 
                                                                   Office_Short_Name__c = 'Office123456');
        //Add to List
        itemList.add(officeItem);
        
        //Insert Item List
        insert itemList;
        
        //Insert List of Conainet
        List<Intranet_Container__c> containetList = new List<Intranet_Container__c>();
        
         //Sub Container
        Intranet_Container__c subItemContainer = new Intranet_Container__c(RecordTypeId = mapRecordTypesWithName.get('Content_Fixed').Id,
                                                                             Parent_Container__c = abcToday.Id,
                                                                            Container_Type__c = 'Page Section', DPA_Score_Type__c = 'None',
                                                                            Display_Name__c = 'Status', Minimum_Visible_Screen__c = 'Phone (<768 pixels)',
                                                                            Content_Types_Allowed__c = 'Page Section', Max_Content_Items__c = 1, 
                                                                            Default_Content_Item__c = defaultInranetItem.Id);
        containetList.add(subItemContainer);
       
        //Abc Birthday
        Intranet_Container__c abcBirthdayToday = new Intranet_Container__c();
        abcBirthdayToday.Name = 'Content - SubContainer-ABC Today-Birthdays';
        abcBirthdayToday.Status__c = 'Active';
        abcBirthdayToday.Container_Type__c = 'SubContainer';
        abcBirthdayToday.Content_Types_Allowed__c = 'Birthdays';
        abcBirthdayToday.Display_Name__c = 'Birthdays';
        abcBirthdayToday.RecordTypeId = mapRecordTypesWithName.get('Content_Fixed').Id;
        abcBirthdayToday.Parent_Container__c = abcToday.Id;
        abcBirthdayToday.Default_Content_Item__c = birthdayItem.Id;
        containetList.add(abcBirthdayToday);
        
        //Insert Containet List
        insert containetList;
        
    	List<Intranet_Item__c> checkVisibleItem = [select Id, Is_Visible__c from Intranet_Item__c where Id = :birthdayItem.id];
        
        //List of Intranet_Schedule
        List<Intranet_Schedule__c> scheduleList1 = new List<Intranet_Schedule__c>();
        
        //Insert Shcedule
        //Insert Schedule and Associate with containee and item
        Intranet_Schedule__c scheduleQuickLinkBookTravel = new Intranet_Schedule__c();
        scheduleQuickLinkBookTravel.Name = 'Quick Links - Book Travel';
        scheduleQuickLinkBookTravel.Active_Status__c = 'Active';
        scheduleQuickLinkBookTravel.Approval_Status__c = 'Approved';
        scheduleQuickLinkBookTravel.Intranet_Container__c = quickLinks.Id;
        scheduleQuickLinkBookTravel.Intranet_Item__c = bookTravel.Id;
        scheduleQuickLinkBookTravel.RecordTypeId = mapRecordTypesWithName.get('Static').Id;
        
        scheduleList1.add(scheduleQuickLinkBookTravel); 
        
        Intranet_Schedule__c birthdaySchedule = new Intranet_Schedule__c();
        birthdaySchedule.Name = 'Quick Links - Book Travel';
        birthdaySchedule.Active_Status__c = 'Active';
        birthdaySchedule.Approval_Status__c = 'Approved';
        birthdaySchedule.Intranet_Container__c = abcBirthdayToday.Id;
        birthdaySchedule.Intranet_Item__c = birthdayItem.Id;
        birthdaySchedule.RecordTypeId = mapRecordTypesWithName.get('Static').Id;
        scheduleList1.add(birthdaySchedule);
        
        Intranet_Schedule__c jobItemSchedule = new Intranet_Schedule__c(Name = 'Test' , Intranet_Container__c = flexible13.Id ,
                                                             Intranet_Item__c = JobItem.Id,
                                                             Office__c = officeItem.Id,
                                                             End_Date_Time__c = Date.Today().addDays(30),
                                                             Start_Date_Time__c = Date.Today())  ; 
        scheduleList1.add(jobItemSchedule);
        
        //Insert Schedule List
        insert scheduleList1;
        
        List<Intranet_Schedule__c> checkVisibleSchedule = [select Id, Is_Visible__c from Intranet_Schedule__c where Id = :birthdaySchedule.id];
       
       //Update Top5 Access Setting which is used as most recent items
       top5AccessedApp.Recent_Intranet_Content_Item_1__c = advisoryComItem1.Id;
       top5AccessedApp.Recent_Intranet_Content_Item_2__c = advisoryComItem2.Id;
       top5AccessedApp.Recent_Intranet_Content_Item_3__c = advisoryComItem3.Id;
       top5AccessedApp.Recent_Intranet_Content_Item_4__c = advisoryComItem4.Id;
       top5AccessedApp.Recent_Intranet_Content_Item_5__c = advisoryComItem5.Id;
       update top5AccessedApp;
        
    }
    
    /**
    * @Description    :   Method to check functionality of  BoardroomHomeContainerController
    *
    * @args           :   
    *
    * @return         :   void
    *
    **/
    static testMethod void testBoardroomHomeContainerController() {
        System.debug('Check main Container Id ::: ' + mainContainerId);
        //Get Main Container
        List<Intranet_Container__c> mainContainerList = [select Id from Intranet_Container__c where Name = 'Page-Primary-Boardroom'];
       
        //Set Url of Current Page
        Test.setCurrentPage(new PageReference('/apex/Boardroom_Home_Container'));
        
        ///Pass Main Container Id from the URL
        ApexPages.currentPage().getParameters().put('IntranetMainPageId',mainContainerList[0].Id);
        
        //Get Birthday Item and set in Search Content Id
        List<Intranet_Item__c> birthdayItems = [select Id from Intranet_Item__c where Item_Title__c = 'Birthdays'];
        ApexPages.currentPage().getParameters().put('SearchContentId',birthdayItems[0].Id);
        
        //Test stert here
        Test.startTest();
        
        //Controller initilization
        BoardroomHomeContainerController controller = new BoardroomHomeContainerController();
        
        //Call getter properties for Child Containers
        IntranetContainer quickLinks = controller.QuickLinks;
        IntranetContainer MemberImpact = controller.MemberImpact;
        IntranetContainer NewsCarousel = controller.NewsCarousel;
        IntranetContainer ABCToday = controller.ABCToday;
        IntranetContainer ABCVideo = controller.ABCVideo;
        IntranetContainer ABCOffice = controller.ABCOffice;
        IntranetContainer ABCMenu = controller.ABCMenu;
        IntranetContainer Trending = controller.Trending;
        IntranetContainer ABCPoll = controller.ABCPoll;
        
        //Call getter properties for Flexible Containers
        IntranetContainer Flexible13 = controller.Flexible13;
        IntranetContainer Flexible15 = controller.Flexible15;
        IntranetContainer Flexible16 = controller.Flexible16;
        IntranetContainer Flexible17 = controller.Flexible17;
        IntranetContainer Flexible19 = controller.Flexible19;
        
        //Map to get SubContainers Map based on Top Parent Container Id
        Map<Id, IntranetContainer> mapContainersWrapper = BoardroomHomeContainerController.GetContainersByTopParentContainerId(mainContainerList[0].Id);
        
        //Get Container By Container Id
        IntranetContainer mainContainerWrapper = BoardroomHomeContainerController.GetContainer(mainContainerList[0].Id);
        
        //Get Schedules 
         //Get All Containers and add id to set
         Set<Id> containerIds = new Set<Id>();
        
        //Loop over least of containers and add to set
        for(Intranet_Container__c cont:[select Id from Intranet_Container__c]){
          containerIds.add(cont.id);    
        }
        Map<Id, Intranet_Schedule__c> allSchedules = BoardroomHomeContainerController.GetSchedules(containerIds,null);
        Map<Id, Intranet_Schedule__c> allSchedulesForIntranetContentViewer = BoardroomHomeContainerController.GetSchedulesForIntranetContentViewer(containerIds,null);
        
        //Get Birthday Schedule
        List<Intranet_Schedule__c> birthdaySchedule = [select Id from Intranet_Schedule__c where Name = 'Quick Links - Book Travel'];
        
        //Get Office Schedule
        Map<Id, Intranet_Schedule__c> officeSchdeule = BoardroomHomeContainerController.GetOfficeSchedules(containerIds, null, birthdaySchedule[0].Id);
        
        //V3.0 - Modified By - Rajeev Jain(07/10/2015) - CR-20150709-9072
        //Access top 5 Setting
        List<MostRecentContentItemWrapper> top5Apps = controller.top5AccessAppSetting;
        
        System.assertEquals(true,top5Apps != null);
        //Get office Selector
        controller.OfficeSelector();
        
        //Assert for results
        System.assertEquals(controller.intranetContainer.Id , mainContainerList[0].Id);
		
        //Test stop here
        Test.stopTest();
        
        
    }
    static testMethod void testHomePageComponents() {
        
    }
}