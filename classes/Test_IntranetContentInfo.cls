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
/** Description     :	Test class for Intranet Content Class.
  * 
  * Created Date    :	09/15/2014
  *
  * Created By      :   
  *  
  * Current vision  :	v1.0
  *  
  * Revision Logs   :	v1.0 - Created
  * 				:	V2.0 - Modifled By - Rajeev Jain(09/10/2015) - CR-20141002-7579 -  Increase code coverage
  * Coverage        :	93%
  **/  
@isTest(SeeAllData=true)
private class Test_IntranetContentInfo {
    
    static testMethod void testIntranetContentInfo() {
    
        //Bypassing trigger so then test data can be created
        Util.byPassAllTriggers = true;
        
        Util.isTest(true);
        
		Map<String, RecordType> mapRecordTypesWithName = new Map<String, RecordType>();
        for(RecordType rType : [Select Id, DeveloperName From RecordType where sObjectType='Intranet_Item__c' AND isActive=true]) {
            
            //Put in map
            mapRecordTypesWithName.put(rType.DeveloperName.toLowerCase(), rType);
        }
        
        //List of Intranet items
        List<Intranet_Item__c> listIntranetItems = new List<Intranet_Item__c>();
        listIntranetItems.add(new Intranet_Item__c(Name = 'Test-0',Active_Status__c = 'Active', Item_Type__c = 'News Item',
                                                   RecordTypeId = mapRecordTypesWithName.get('item_chart').Id, 
                                                   Item_Title__c = 'Test News///',
                                                   Category_Name__c = 'A',Color_Set_Name__c = 'ColorSet', 
                                                   Office_Short_Name__c = 'Office'));
        
        listIntranetItems.add(new Intranet_Item__c(Name = 'Test-0',Active_Status__c = 'Active', Item_Type__c = 'Member Impact',
                                                   RecordTypeId = mapRecordTypesWithName.get('item_chart').Id, 
                                                   Item_Title__c = 'TestMember@#ImpactStory',
                                                   Category_Name__c = 'A',Color_Set_Name__c = 'ColorSet', 
                                                   Office_Short_Name__c = 'Office'));
        
        listIntranetItems.add(new Intranet_Item__c(Name = 'Test-0',Active_Status__c = 'Active', Item_Type__c = 'Training Event',
                                                   RecordTypeId = mapRecordTypesWithName.get('item_chart').Id, Item_Title__c = 'TestTrainingEvent',
                                                   Category_Name__c = 'A',Color_Set_Name__c = 'ColorSet', 
                                                   Office_Short_Name__c = 'Office', Link_URL__c = 'www.TestTrainingEvent.com'));
        
        listIntranetItems.add(new Intranet_Item__c(Name = 'Test-0',Active_Status__c = 'Active', Item_Type__c = 'Member Event',
                                                   RecordTypeId = mapRecordTypesWithName.get('item_chart').Id, Item_Title__c = 'TestMemberEvent',
                                                   Category_Name__c = 'A',Color_Set_Name__c = 'ColorSet', 
                                                   Office_Short_Name__c = 'Office', Link_URL__c = 'www.TestMemberEvent.com'));
        listIntranetItems.add(new Intranet_Item__c(Name = '2015 Southwind Retreat - Office Event ',Active_Status__c = 'Active', Item_Type__c = 'Office Event',
                                                   RecordTypeId = mapRecordTypesWithName.get('item_event').Id, Item_Title__c = '2015 Southwind Retreat', 
                                                   Link_URL__c = '', Event_Start_Date_Time__c = DateTime.now()));
        
        //Add Item of Page Section Type
        listIntranetItems.add(new Intranet_Item__c(Name = 'Advisory Board International - Page Section',Active_Status__c = 'Active', Item_Type__c = 'Page Section',
                                                   RecordTypeId = mapRecordTypesWithName.get('item_page').Id, Item_Title__c = 'Advisory Board International', 
                                                   Link_URL__c = ''));
        
        Intranet_Item__c officeIntranetItem = new Intranet_Item__c(Name = 'Austin - Office Location - Setting', 
                                                                   Approval_Status__c = 'Approved',
                                                                   RecordTypeId = mapRecordTypesWithName.get('settings_office').Id,
                                                                   Office_Name__c = 'Austin, TX',
                                                                   Office_Short_Name__c = 'Austin123',
                                                                   Item_Type__c = 'Office Location',
                                                                   Active_Status__c = 'Active',
                                                                   Location__Latitude__s = 38.9056,
                                                                   Location__Longitude__s = -77.05);
        
        listIntranetItems.add(officeIntranetItem);
        
        //Insert video Item
        Intranet_Item__c videoItem = new Intranet_Item__c();
		videoItem.Name = 'What are Bundled Payments? - Video Item';
        videoItem.Item_Type__c = 'Video Item';
        videoItem.Approval_Status__c = 'Approved';
        videoItem.Item_Title__c = 'What are Bundled Payments?';
        videoItem.Event_Type__c = 'Other';
        videoItem.RecordTypeId = mapRecordTypesWithName.get('item_video').Id;
        listIntranetItems.add(videoItem);
        
        insert listIntranetItems;
        
        List<RecordType> contentSubContainer = [select Id, DeveloperName, Name from RecordType where DeveloperName = 'Content_SubContainer'];
        
        //Insert Intranet Container
        Intranet_Container__c container = new Intranet_Container__c(Name = 'Test-1', CurrencyIsoCode = 'USD' , Content_Types_Allowed__c = 'App Link, News Item, Office Event, Member Impact, Training Event, Member Event' ,Display_Name__c = 'Testing');
        insert container;
        
        //Create parent Container of Containert Type Page section
        Intranet_Container__c parentContainer = new Intranet_Container__c(Name = 'Content - SubContainer-Departments-Cross-Departmental Functions',
                                                                          Content_Types_Allowed__c = 'Page Section' ,
                                                                          Sort_Order__c = 1,
                                                                          Container_Type__c = 'SubContainer',
                                                                          RecordTypeId = contentSubContainer[0].Id,
                                                                          Display_Name__c = 'Cross-Departmental Functions');
        insert parentContainer;
        
        //Insert Container of Page Section Type and Its parent Container
        Intranet_Container__c pageSectionContainer = new Intranet_Container__c(Name = 'Content - SubContainer-Cross-Departmental Functions-Advisory Board International',
                                                                               Content_Types_Allowed__c = 'Page Section' ,
                                                                               Parent_Container__c = parentContainer.Id,
                                                                               Container_Type__c = 'SubContainer',
                                                                               RecordTypeId = contentSubContainer[0].Id,
                                                                               Display_Name__c = 'Advisory Board International');
        insert pageSectionContainer;
        
        //Query on Page Section Container and 
        List<Intranet_Container__c> conTest = [select Id, Parent_Container__c, Top_Parent_Container_Id__c from Intranet_Container__c where Id = :pageSectionContainer.Id LIMIT 1];
        
        //Insert Page Section Schedule
        Intranet_Schedule__c pageSectionSchedule = new Intranet_Schedule__c(Name = 'Advisory Board Inter - Advisory Board International' , Intranet_Container__c = pageSectionContainer.Id , Intranet_Item__c = listIntranetItems[5].Id, Start_Date_Time__c = DateTime.now(), End_Date_Time__c = DateTime.now().addDays(1));
        insert pageSectionSchedule;
        
        //Insert Intranet Item
        Intranet_Item__c intranetItem = new Intranet_Item__c(Name = 'Test-0' , Active_Status__c = 'Active' , Item_Type__c = 'App Link' , Item_Title__c = 'A1');
        insert intranetItem;
        
        //Insert Intranet Schedule
        Intranet_Schedule__c intranetSchedule = new Intranet_Schedule__c(Name = 'Test' , Intranet_Container__c = container.Id , Intranet_Item__c = intranetItem.Id, Start_Date_Time__c = DateTime.now(), End_Date_Time__c = DateTime.now().addDays(1));
        insert intranetSchedule;
        
        //Insert Schduel of Page Section Item
        
        //Test will start from here
        Test.startTest();
        
        //Enabling triggers again
        Util.byPassAllTriggers = false;
        
        IntranetContentInfo newsItemContentInfo = new IntranetContentInfo(listIntranetItems[0], intranetSchedule, container, Intranet_Item__c.sObjectType.getDescribe().fieldSets.getMap().get('Intranet_Item_Fields'), Intranet_Item__c.sObjectType.getDescribe().fields.getMap(), Intranet_Item__c.Name.getDescribe().getSObjectField(), true);
        
        //Call Method for Code Coverage
        newsItemContentInfo.DuplicateToHeader();
        
        //Call Method for Code Coverage
        newsItemContentInfo.ToString('Test');
        
        IntranetContentInfo officeEventContentInfo = new IntranetContentInfo(listIntranetItems[4], intranetSchedule, container, Intranet_Item__c.sObjectType.getDescribe().fieldSets.getMap().get('Search_Results_Office_Event'), Intranet_Item__c.sObjectType.getDescribe().fields.getMap(), Intranet_Item__c.Name.getDescribe().getSObjectField(), true);
        
        //Only for coverage of code
        IntranetContentInfo officeEventContentInfoEx = new IntranetContentInfo(listIntranetItems[4], intranetSchedule, container, Intranet_Item__c.sObjectType.getDescribe().fieldSets.getMap().get('Search_Results_Office_Event'), Intranet_Item__c.sObjectType.getDescribe().fields.getMap(), null, true);
        officeEventContentInfoEx = new IntranetContentInfo(listIntranetItems[4], intranetSchedule, container, Intranet_Item__c.sObjectType.getDescribe().fieldSets.getMap().get('Search_Results_Office_Event'), Intranet_Item__c.sObjectType.getDescribe().fields.getMap(), Intranet_Item__c.Last_Content_Update__c.getDescribe().getSObjectField(), true);
        officeEventContentInfoEx = new IntranetContentInfo(listIntranetItems[4], intranetSchedule, container, Intranet_Item__c.sObjectType.getDescribe().fieldSets.getMap().get('Search_Results_Office_Event'), Intranet_Item__c.sObjectType.getDescribe().fields.getMap(), Intranet_Item__c.Trending_View_Count__c.getDescribe().getSObjectField(), true);
        
        IntranetContentInfo trainingEventContentInfo = new IntranetContentInfo(listIntranetItems[2], intranetSchedule, container, Intranet_Item__c.sObjectType.getDescribe().fieldSets.getMap().get('Search_Results_Training_Event'), Intranet_Item__c.sObjectType.getDescribe().fields.getMap(), Intranet_Item__c.Name.getDescribe().getSObjectField(), true);
        
        //Requery on Scheduel to Grab the Intranet Container Data
        List<Intranet_Schedule__c> scheduleList = [select Id, Intranet_Container__r.Reference_Number__c, Intranet_Container__r.Top_Parent_Container_Id__c from Intranet_Schedule__c where Id = :pageSectionSchedule.Id];
        
        //Item COntent info of Page Section Type
        IntranetContentInfo pageSectionContentInfo = new IntranetContentInfo(listIntranetItems[5], scheduleList[0], pageSectionContainer, Intranet_Item__c.sObjectType.getDescribe().fieldSets.getMap().get('Search_Results_Page_Section'), Intranet_Item__c.sObjectType.getDescribe().fields.getMap(), Intranet_Item__c.Name.getDescribe().getSObjectField(), true);
        
        //Item Content info for Video item
        IntranetContentInfo videoItemInfo = new IntranetContentInfo(videoItem, scheduleList[0], container, Intranet_Item__c.sObjectType.getDescribe().fieldSets.getMap().get('Search_Results_Video_Item'), Intranet_Item__c.sObjectType.getDescribe().fields.getMap(), Intranet_Item__c.Name.getDescribe().getSObjectField(), true);
            
        //Update Schedule with new Office Item
        intranetSchedule.Office__c = officeIntranetItem.Id;
        update intranetSchedule;
        
        scheduleList = [select Id, Intranet_Container__r.Reference_Number__c, Intranet_Container__r.Top_Parent_Container_Id__c, Office__c from Intranet_Schedule__c where Id = :pageSectionSchedule.Id];
        
        IntranetContentInfo officeEventContentInfo1 = new IntranetContentInfo(listIntranetItems[4], scheduleList[0], container, Intranet_Item__c.sObjectType.getDescribe().fieldSets.getMap().get('Search_Results_Office_Event'), Intranet_Item__c.sObjectType.getDescribe().fields.getMap(), Intranet_Item__c.Name.getDescribe().getSObjectField(), true);
        
        //Call sort Method to Coverage the Compare code of the class
        List<IntranetContentInfo> listController = new List<IntranetContentInfo>();
        listController.sort();
        listController.add(newsItemContentInfo);
        listController.sort();
        listController.add(officeEventContentInfo);
        listController.add(trainingEventContentInfo);
        listController.sort();
    	
        //Make Sort Order Null to cover code of the class
        officeEventContentInfo.SortOrder = null;
        trainingEventContentInfo.SortOrder = null;
        listController = new List<IntranetContentInfo>();
        listController.add(officeEventContentInfo);
        listController.add(trainingEventContentInfo);
        listController.sort();
        
        //Increase one content sortorder number so One condition can be covered in comparator
       	officeEventContentInfo.SortOrderNumber = 10;
        listController = new List<IntranetContentInfo>();
        listController.add(officeEventContentInfo);
        listController.add(trainingEventContentInfo);
        listController.sort();
        
        //Call two Property for code coverage
        Integer rowNumber = officeEventContentInfo.RowNumber;
        Double SortOrderNumber = officeEventContentInfo.SortOrderNumber;
        
        //Stop Test here
        Test.stopTest();
        
        //Get IntranetDefaultds
        Intranet_Defaults__c intranetDefault = IntranetHomeUtility.LookupIntranetDefault('News Item');
        
        String expectedNewsURL = '/apex/IntranetContentViewer?' + intranetDefault.ContentViewerView__c + '&SearchContentId=' + listIntranetItems[0].id + '&SearchContentType=' + listIntranetItems[0].Item_Type__c;
        
        intranetDefault = IntranetHomeUtility.LookupIntranetDefault('Office Event');
        
        String expectedOfficeEventUrl = '/apex/IntranetContentViewer?' + intranetDefault.ContentViewerView__c + '&SearchContentId=' + listIntranetItems[4].id + '&SearchContentType=' + listIntranetItems[4].Item_Type__c +
            							'&SearchStartDate=' + EncodingUtil.urlEncode(listIntranetItems[4].Event_Start_Date_Time__c.format('MM/dd/yyyy'), 'UTF-8');
        
        String expectedPagesectionUrl = '/apex/Boardroom_Internal_Home_Page?TopContainerId=' + scheduleList[0].Intranet_Container__r.Top_Parent_Container_Id__c + '#' + pageSectionContentInfo.ScheduleReferenceNumber;
        
        //Assert for Results
        System.assertEquals(expectedNewsURL, newsItemContentInfo.Permalink);
        
        //Assert to check OfficeEventInfor
        System.assertEquals(expectedOfficeEventUrl, officeEventContentInfo.Permalink);
        
        //Assert for Page Setion Info
        System.assertEquals(expectedPagesectionUrl, pageSectionContentInfo.Permalink);
    }
}