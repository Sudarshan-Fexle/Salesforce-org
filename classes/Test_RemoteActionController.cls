/**
 * 	Purpose			:	Test Class for Remote Action Controller
 * 
 * 	Created By		:	Rajeev Jain
 * 
 * 	Created Date	:	06/22/2015 - CR-20141002-7579
 * 						V_2.0 - Modified By - Rajeev Jain - 07/10/2015 - CR-20150709-9072 -  
 * 						Added when some method modified in remote action controller to create most recent item on hamburger menu.
 * 
 *	Revision Logs	:	V_1.0 - Created
 *						
 **/ 
@isTest
public class Test_RemoteActionController {
	
    static testMethod void testCreateIntranetUtilizationRecord() {
    	
        //Intranet Container
        Intranet_Container__c intranetContainer = new Intranet_Container__c(Name = 'Test-2', CurrencyIsoCode = 'USD', Content_Types_Allowed__c = 'Firm App Link');
        insert intranetContainer;
        
        //Intranet Item
        Intranet_Item__c intranetItem = new Intranet_Item__c(Name = 'Test-0' , Active_Status__c = 'Active' , 
                                                             	Item_Type__c = 'Firm App Link' , Item_Title__c = 'A1');
        insert intranetItem;
        
        //Intranet Schedule
        Intranet_Schedule__c intranetSchedule = new Intranet_Schedule__c(Name = 'Test4' , Intranet_Container__c = intranetContainer.Id, Intranet_Item__c = intranetItem.Id,
                                                                        		Start_Date_Time__c = DateTime.Now()+1, End_Date_Time__c = DateTime.Now()+5 );
        insert intranetSchedule;
        
        //Update User record with Job Level
        System.runAs(new User(Id = UserInfo.getUserId())) {
            
            update new User(Id = UserInfo.getUserId(), Job_Level__c = '10 B1 Early Professional');
        }
        
        //Start Testing from here
        Test.startTest();
        
        //Set values
        IntranetHomeUtility.UserBrowser = 'Chrome';
        IntranetHomeUtility.UserDevice = 'Tablet';
        IntranetHomeUtility.ScreenSize = 992;
        IntranetHomeUtility.NetworkAccess = 'Test';
        
        //Call PopulateUserSession method
        IntranetType.UserSession UserSession = IntranetHomeUtility.getUserSession;
        
        //Serialize UserSession
        String serializedUserSession = JSON.serialize(UserSession);
        
        String remoteResponse = RemoteActionController.recordClickUtilization('Like', '', intranetItem.Id, intranetSchedule.Id, intranetContainer.Id, null,'Tablet','Chrome',992,null);
        
        String remoteResponse1 = RemoteActionController.recordClickUtilization('Comment', '', intranetItem.Id, intranetSchedule.Id, intranetContainer.Id, null,'Tablet','Chrome',992,null);
        
        String remoteResponse2 = RemoteActionController.recordClickUtilization('Expand', '', intranetItem.Id, intranetSchedule.Id, intranetContainer.Id, null,'Tablet','Chrome',992,null);
        
        String remoteResponse3 = RemoteActionController.recordClickUtilization('Feedback', '', intranetItem.Id, intranetSchedule.Id, intranetContainer.Id, null,'Tablet','Chrome',992,null);
        
        String remoteResponse4 = RemoteActionController.recordClickUtilization('Launch App', '', intranetItem.Id, intranetSchedule.Id, intranetContainer.Id, null,'Tablet','Chrome',992,null);
        
        String remoteResponse5 = RemoteActionController.recordClickUtilization('Office Change', '', intranetItem.Id, intranetSchedule.Id, intranetContainer.Id, null,'Tablet','Chrome',992,null);
        
        String remoteResponse6 = RemoteActionController.recordClickUtilization('Open Web', '', intranetItem.Id, intranetSchedule.Id, intranetContainer.Id, null,'Tablet','Chrome',992,null);
        
        String remoteResponse7 = RemoteActionController.recordClickUtilization('Open Page', '', intranetItem.Id, intranetSchedule.Id, intranetContainer.Id, null,'Tablet','Chrome',992,null);
        
        String remoteResponse8 = RemoteActionController.recordClickUtilization('Select', '', intranetItem.Id, intranetSchedule.Id, intranetContainer.Id, null,'Tablet','Chrome',992,null);
        
        String remoteResponse9 = RemoteActionController.recordClickUtilization('Share', '', intranetItem.Id, intranetSchedule.Id, intranetContainer.Id, null,'Tablet','Chrome',992,null);
        
        String remoteResponse10 = RemoteActionController.recordClickUtilization('Rate', '', intranetItem.Id, intranetSchedule.Id, intranetContainer.Id, null,'Tablet','Chrome',992,null);
        
        String remoteResponse11 = RemoteActionController.recordClickUtilization('Page Section', '', intranetItem.Id, intranetSchedule.Id, intranetContainer.Id, null,'Tablet','Chrome',992,null);
        
        String remoteResponse12 = RemoteActionController.recordClickUtilization('Office Page Section', '', intranetItem.Id, intranetSchedule.Id, intranetContainer.Id, null,'Tablet','Chrome',992,null);
        
        String remoteResponse13 = RemoteActionController.recordClickUtilization('xyz', '', intranetItem.Id, intranetSchedule.Id, intranetContainer.Id, null,'Tablet','Chrome',992,null);
        
        //Stop Test
        Test.stopTest();
        System.assertEquals(IntranetUtilizationHelper.ClICK_TYPE_REMOTESUCCESS + 'Like', remoteResponse);
    }
    
    static testMethod void testCreateRecentlyClickedItem() {
    	
        List<Intranet_Container__c> hamburgerMenuSubContainers = new List<Intranet_Container__c>();
        
        List<RecordType> contentFixed = [select Id, DeveloperName, Name from RecordType where DeveloperName = 'Content_Fixed'];
        List<RecordType> staticRecordType = [select Id, DeveloperName, Name from RecordType where DeveloperName = 'Static'];
        
        //Insert intranet Constant Custom Setting
        Intranet_Constants__c intraConst = new Intranet_Constants__c();
        intraConst.SetupOwnerId = UserInfo.getUserId();
        intraConst.Allow_Schedule_Approval__c = true;
        insert intraConst;
        
         //Create Subcontainers of Hamburger menu
        Intranet_Container__c hemburgerMenuSubContainer1 = new Intranet_Container__c(Name = 'Content - Fixed-Hamburger Menu-Benefits and HealthyLife',
                                                                                     Container_Type__c = 'Menu',
                                                                                     Status__c = 'Active',
                                                                                     Sort_Order__c = 2,
                                                                                     Content_Types_Allowed__c = 'Firm App Link; Page Link; Menu Link; Favorite Link',
                                                                                     Display_Name__c='Benefits and HealthyLife',
                                                                                     RecordTypeId = contentFixed[0].Id);
        hamburgerMenuSubContainers.add(hemburgerMenuSubContainer1);
        
        Intranet_Container__c hemburgerMenuSubContainer2 = new Intranet_Container__c(Name = 'Content - Fixed-Hamburger Menu-The Firm',
                                                                                     Container_Type__c = 'Menu',
                                                                                     Status__c = 'Active',
                                                                                     Sort_Order__c = 1,
                                                                                     Content_Types_Allowed__c = 'Firm App Link; Page Link; Menu Link; Favorite Link',
                                                                                     Display_Name__c='Benefits and HealthyLife',
                                                                                     RecordTypeId = contentFixed[0].Id);
        
        hamburgerMenuSubContainers.add(hemburgerMenuSubContainer2);
        
        insert hamburgerMenuSubContainers;
        
        //List of Item
        List<Intranet_Item__c> itemList = new List<Intranet_Item__c>();
        
         //Insert Intranet Item and then Intranet Scheduel and associate both contianer and item to that schedule
        //So it can display as menu
        Intranet_Item__c advisoryComItem = new Intranet_Item__c();
		advisoryComItem.Name = 'Advisory.com - Firm App Link';
        advisoryComItem.Item_Type__c = 'Firm App Link';
        advisoryComItem.Item_Title__c = 'Advisory.com';
        advisoryComItem.Link_URL__c = 'http://www.advisory.com';
        advisoryComItem.Link_Type__c = 'Standard';
        advisoryComItem.Link_Action__c = 'Open in New Tab/Window';
        advisoryComItem.Sort_Order__c = 1.0;
        advisoryComItem.Icon_Style__c = 'advisory-com';
        itemList.add(advisoryComItem);
        itemList.add(new Intranet_Item__c(Name = 'InnovACTION - Menu Link', Item_Type__c = 'Menu Link',
                                         Item_Title__c = 'InnovACTION', Link_URL__c = 'http://www.advisory.com',
                                         Link_Type__c = 'Standard', Link_Action__c = 'Open in New Tab/Window'));
        itemList.add(new Intranet_Item__c(Name = 'EAB.com - Firm App Link', Item_Type__c = 'Firm App Link',
                                         Item_Title__c = 'EAB.com', Link_URL__c = 'http://eab.com',
                                         Link_Type__c = 'Standard', Link_Action__c = 'Open in New Tab/Window'));
        itemList.add(new Intranet_Item__c(Name = 'Elevate Your Effectiveness - Page Link', Item_Type__c = 'Page Link',
                                         Item_Title__c = 'Elevate Your Effectiveness', Link_URL__c = '/apex/Boardroom_Internal_Home_Page?TopContainerID=a3KC0000000HTme',
                                         Link_Type__c = 'Standard', Link_Action__c = 'Open in New Tab/Window'));
        itemList.add(new Intranet_Item__c(Name = 'Benefits and HealthyLife Portal - Firm App Link ', Item_Type__c = 'Firm App Link',
                                         Item_Title__c = 'Benefits and HealthyLife Portal', Link_URL__c = 'http://portals.advisory.com/benefits',
                                         Link_Type__c = 'Standard', Link_Action__c = 'Open in New Tab/Window'));
        insert itemList;
        
        //List of Schedules
        List<Intranet_Schedule__c> scheduleList = new List<Intranet_Schedule__c>();
        Intranet_Schedule__c scheduleFirm = new Intranet_Schedule__c();
        scheduleFirm.Name = 'The Firm - Advisory.com';
        scheduleFirm.Active_Status__c = 'Active';
        scheduleFirm.Intranet_Container__c = hemburgerMenuSubContainer2.Id;
        scheduleFirm.Intranet_Item__c = advisoryComItem.Id;
        scheduleFirm.End_Date_Time__c = Date.Today().addDays(90);
        scheduleFirm.Start_Date_Time__c = Date.Today();  
		
        scheduleList.add(scheduleFirm);
        scheduleList.add(new Intranet_Schedule__c(Name = 'The Firm - InnovACTION', Active_Status__c = 'Active',
                                                 Intranet_Container__c = hemburgerMenuSubContainer2.Id,
                                                 Approval_Status__c = 'Approved',
                                                 Intranet_Item__c = itemList[1].Id,
                                                 RecordTypeId = staticRecordType[0].Id));
        scheduleList.add(new Intranet_Schedule__c(Name = 'The Firm - EAB.com', Active_Status__c = 'Active',
                                                 Intranet_Container__c = hemburgerMenuSubContainer2.Id,
                                                 Approval_Status__c = 'Approved',
                                                 Intranet_Item__c = itemList[2].Id,
                                                 RecordTypeId = staticRecordType[0].Id));
        scheduleList.add(new Intranet_Schedule__c(Name = 'The Firm - Elevate Effectiveness', Active_Status__c = 'Active',
                                                 Intranet_Container__c = hemburgerMenuSubContainer2.Id,
                                                 Approval_Status__c = 'Approved',
                                                 Intranet_Item__c = itemList[3].Id,
                                                 RecordTypeId = staticRecordType[0].Id));
        scheduleList.add(new Intranet_Schedule__c(Name = 'Benefits and Healthy - Benefits and HealthyLife Portal', Active_Status__c = 'Active',
                                                 Intranet_Container__c = hemburgerMenuSubContainer2.Id,
                                                 Approval_Status__c = 'Approved',
                                                 Intranet_Item__c = itemList[4].Id,
                                                 RecordTypeId = staticRecordType[0].Id));
        insert scheduleList;
        
        //Start Test
        Test.startTest();
        
        //Default Click on the Links
        String remoteResponse = RemoteActionController.recentlyClickedLinkItems('Open Page', advisoryComItem.Item_Title__c, 
                                                                                advisoryComItem.Id, scheduleFirm.Id, 
                                                                                hemburgerMenuSubContainer2.Id, null, 
                                                                                advisoryComItem.Link_URL__c, 
                                                                                advisoryComItem.Icon_Style__c, advisoryComItem.Link_Action__c);
        
		String remoteResponse1 = RemoteActionController.recentlyClickedLinkItems('Open Page', itemList[1].Item_Title__c, 
                                                                                itemList[1].Id, scheduleList[1].Id, 
                                                                                hemburgerMenuSubContainer2.Id, null, 
                                                                                itemList[1].Link_URL__c, 
                                                                                itemList[1].Icon_Style__c, itemList[1].Link_Action__c);
        
        String remoteResponse2 = RemoteActionController.recentlyClickedLinkItems('Open Page', itemList[2].Item_Title__c, 
                                                                                itemList[2].Id, scheduleList[2].Id, 
                                                                                hemburgerMenuSubContainer2.Id, null, 
                                                                                itemList[2].Link_URL__c, 
                                                                                itemList[2].Icon_Style__c, itemList[2].Link_Action__c);
        
        String remoteResponse3 = RemoteActionController.recentlyClickedLinkItems('Open Page', itemList[2].Item_Title__c, 
                                                                                itemList[3].Id, scheduleList[3].Id, 
                                                                                hemburgerMenuSubContainer2.Id, null, 
                                                                                itemList[3].Link_URL__c, 
                                                                                itemList[3].Icon_Style__c, itemList[3].Link_Action__c);
        String remoteResponse4 = RemoteActionController.recentlyClickedLinkItems('Open Page', itemList[2].Item_Title__c, 
                                                                                itemList[4].Id, scheduleList[4].Id, 
                                                                                hemburgerMenuSubContainer2.Id, null, 
                                                                                itemList[4].Link_URL__c, 
                                                                                itemList[4].Icon_Style__c, itemList[4].Link_Action__c);
        
        //Now Reclick on the most Recent Items, Custom setting in the method will be checked against the position of the data
        
	    String remoteResponse41 = RemoteActionController.recentlyClickedLinkItems('Open Page', itemList[2].Item_Title__c, 
                                                                                itemList[4].Id, scheduleList[4].Id, 
                                                                                hemburgerMenuSubContainer2.Id, null, 
                                                                                itemList[4].Link_URL__c, 
                                                                                itemList[4].Icon_Style__c, itemList[4].Link_Action__c);
        String remoteResponse31 = RemoteActionController.recentlyClickedLinkItems('Open Page', itemList[2].Item_Title__c, 
                                                                                itemList[3].Id, scheduleList[3].Id, 
                                                                                hemburgerMenuSubContainer2.Id, null, 
                                                                                itemList[3].Link_URL__c, 
                                                                                itemList[3].Icon_Style__c, itemList[3].Link_Action__c);
        String remoteResponse21 = RemoteActionController.recentlyClickedLinkItems('Open Page', itemList[2].Item_Title__c, 
                                                                                itemList[2].Id, scheduleList[2].Id, 
                                                                                hemburgerMenuSubContainer2.Id, null, 
                                                                                itemList[2].Link_URL__c, 
                                                                                itemList[2].Icon_Style__c, itemList[2].Link_Action__c);
        
        String remoteResponse11 = RemoteActionController.recentlyClickedLinkItems('Open Page', itemList[1].Item_Title__c, 
                                                                                itemList[1].Id, scheduleList[1].Id, 
                                                                                hemburgerMenuSubContainer2.Id, null, 
                                                                                itemList[1].Link_URL__c, 
                                                                                itemList[1].Icon_Style__c, itemList[1].Link_Action__c);
        String remoteResponse01 = RemoteActionController.recentlyClickedLinkItems('Open Page', advisoryComItem.Item_Title__c, 
                                                                                advisoryComItem.Id, scheduleFirm.Id, 
                                                                                hemburgerMenuSubContainer2.Id, null, 
                                                                                advisoryComItem.Link_URL__c, 
                                                                                advisoryComItem.Icon_Style__c, advisoryComItem.Link_Action__c);
        
        //Stop Test
        Test.stopTest();
    }
}