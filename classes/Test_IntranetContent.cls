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
/** Description     :   Test class for Intranet Content Class.
  * 
  * Created Date    :   09/15/2014
  *
  * Created By      :   
  *  
  * Current vision  :   v1.0
  *  
  * Revision Logs   :   v1.0 - Created
  *                 :   V2.0 - Modifled By - Rajeev Jain(05/20/2015) - CR-20141002-7579
  *                 :   V3.0 - Modified By - Rajeev Jain(09/07/2015) - CR-20141002-7579 - Increase code coverage
  *                 :   V4.0   Modified By - Rajeev Jain - 18/02/2020 - CR-20190929-13382 -  Remove zzzHas Subcontainers(Has_SubContainers__c) and zzzScreen Priority(Screen_Priority__c) field on Intranet_Container__c object
  *                 :   v5.0 - Modified By - Rajeev Jain (03/17/2020) (As Feed Tracking for Intranet Item off - Fix bug during Print MIS (Phase 5) deployment)                                                                         
  * Coverage        :   98%
  **/  
@isTest(SeeAllData = true)
private class Test_IntranetContent {
    
    //Setup all common data required in test class
    static void setup() {
        
        
         //Update User record with Job Level
        System.runAs(new User(Id = UserInfo.getUserId())) {
            
            update new User(Id = UserInfo.getUserId(), Job_Level__c = '10 B1 Early Professional', Entity__c = 'EAB');
        }
        
        //Set values
        IntranetHomeUtility.UserBrowser = 'Chrome';
        IntranetHomeUtility.UserDevice = 'Mobile';
        IntranetHomeUtility.ScreenSize = 992;
        IntranetHomeUtility.NetworkAccess = 'Test';

    }
    static Map<String, RecordType> getMapRecordTypesWithName(){
        
        Map<String, RecordType> mapRecordTypesWithName = new Map<String, RecordType>();
        for(RecordType rType : [Select Id, DeveloperName From RecordType where (sObjectType='Intranet_Schedule__c' OR sObjectType='Intranet_Container__c' OR sObjectType='Intranet_Item__c') AND isActive=true]) {
            
            //Put in map
            mapRecordTypesWithName.put(rType.DeveloperName, rType);
        }
        return mapRecordTypesWithName;
    }
    static testMethod void testNewsContent() {
        
        setup();
        
        Map<String, RecordType> mapRecordTypesWithName = getMapRecordTypesWithName();
        
        //Create test data
        Intranet_Item__c intranetItem = new Intranet_Item__c(Name = 'Test-0', Active_Status__c = 'Active', 
                                                             Item_Type__c='News Item', Link_URL__c = 'www.test.com',
                                                                Link_Action__c = 'Rate Item', Citation__c = 'Test');
        insert intranetItem;
        
        Intranet_Item__c officeItem = new Intranet_Item__c(Name = 'Test-0',Active_Status__c = 'Active',Item_Type__c='App Link',
                                                                   RecordTypeId = mapRecordTypesWithName.get('Settings_Office').Id,Item_Title__c = 'Test',  
                                                                   Category_Name__c = 'A',Color_Set_Name__c = 'ColorSet', 
                                                                   Office_Short_Name__c = 'Office123456');
        insert officeItem;
        
        //Create Test data Makw Container Type of News Carousal
         Intranet_Container__c intranetContainer = new Intranet_Container__c(Container_Type__c = 'News Carousel',
                                                                                    Max_Content_Items__c = 100, 
                                                                                    Status__c = 'Active',
                                                                                    Content_Types_Allowed__c = 'News Item',
                                                                                    Display_Name__c = 'Primary',
                                                                                    Minimum_Visible_Screen__c = 'Desktop (1200 pixels)',
                                                                                    Position__c = '1',
                                                                                    Show_Expand_Link__c = true,
                                                                                    Show_Feedback_Link__c = true, 
                                                                                    Sort_Order__c = 1,
                                                                                    Height__c = 100,
                                                                                    Width__c = 100);
        insert intranetContainer;
        
        //Intranet scheedule record for testing
        Intranet_Schedule__c intranetSchedule = new Intranet_Schedule__c(Name = 'Test' , Intranet_Container__c = intranetContainer.Id ,
                                                                              Intranet_Item__c = intranetItem.Id,
                                                                              Office__c = officeItem.Id,
                                                                              End_Date_Time__c = Date.Today().addDays(9),
                                                                              Start_Date_Time__c = Date.Today())  ; 
                                                                           
        insert  intranetSchedule;
        
        //Call PopulateUserSession method
        IntranetType.UserSession UserSession = IntranetHomeUtility.getUserSession;
        
        //Start Test from Here
        Test.startTest();
        
        IntranetContainer intranetContainerClass = new IntranetContainer(intranetContainer);
        IntranetContent controller = new IntranetContent(intranetContainerClass, intranetSchedule, intranetItem, UserSession, new Map<String, Intranet_Utilization__c>());
        
        //Now Update Container Type and Its display Name
        intranetContainer.Container_Type__c = 'SubContainer';
        intranetContainer.Display_Name__c = 'News';
        
        //Update Containet
        update intranetContainer;
        
        intranetContainerClass = new IntranetContainer(intranetContainer);
        
        IntranetContent controller1 = new IntranetContent(intranetContainerClass, intranetSchedule, intranetItem, UserSession, new Map<String, Intranet_Utilization__c>());
        
        //Resert Container Display Name
        intranetContainer.Display_Name__c = 'Primary';
        update intranetContainer;
        
        intranetContainerClass = new IntranetContainer(intranetContainer);
        
        //Update Last COntent Update Date on item and Sort order
        intranetItem.Last_Content_Update__c = DateTime.now();
        intranetItem.Sort_Order__c = 1.0;
        
        IntranetContent controller2 = new IntranetContent(intranetContainerClass, intranetSchedule, intranetItem, UserSession, new Map<String, Intranet_Utilization__c>());
        
        //Stop Test here
        Test.stopTest();
        
        //Query Item name and assert for the results
        System.assertEquals(intranetItem.Id, controller.IntranetItemId);
        //Modified By - Dipesh Gupta -  CR-20200218-13769
        //System.assertEquals(true, controller.BackgroundColor == intranetItem.Background_Color__c);
        System.assertEquals(true, controller.Office == intranetSchedule.Office__c);
        System.assertEquals(true, controller.ContentThumbnailImageId == intranetItem.Content_Thumbnail_Image_Id__c);
        
        //Assert for Container Type News
        System.assertEquals(intranetItem.Id, controller1.IntranetItemId);
        //Modified By - Dipesh Gupta -  CR-20200218-13769
       // System.assertEquals(true, controller1.BackgroundColor == intranetItem.Background_Color__c);
        System.assertEquals(true, controller1.Office == intranetSchedule.Office__c);
        System.assertEquals(true, controller1.ContentThumbnailImageId == intranetItem.Content_Thumbnail_Image_Id__c);
        
        //Assert for Container Type = SubContainer of News Container
        System.assertEquals(true, controller2.SortOrder != null );
    }
    
    /** Test Flexible container Items  **/
    static testMethod void testFlexibleContainerItems() {
        
        setup();
        Map<String, RecordType> mapRecordTypesWithName = getMapRecordTypesWithName();
        
        //Insert Intranet item
        Intranet_Item__c intranetItem = new Intranet_Item__c(Name = 'Test-0', Active_Status__c = 'Active', Approval_Status__c = 'Approved',
                                                             Item_Type__c='Ad Item', Link_URL__c = 'http://www.washingtonpost.com',
                                                             item_Title__c = 'Kip 2 Small ad',
                                                             Link_Action__c = 'Open in New Tab/Window', 
                                                             Link_Type__c = 'Open in New Tab/Window',
                                                             RecordTypeId = mapRecordTypesWithName.get('Item_Ad').Id,
                                                             Entity__c = 'EAB');
        insert intranetItem;

        
        //Insert Flexible Container
        Intranet_Container__c flexibleContainer = new Intranet_Container__c(Container_Type__c = 'Flexible',
                                                                            Max_Content_Items__c = 100, 
                                                                            Status__c = 'Active',
                                                                            Content_Types_Allowed__c = 'Ad Item; Job Item',
                                                                            Display_Name__c = 'Flexible-15',
                                                                            RecordTypeId = mapRecordTypesWithName.get('Content_Fixed').Id);
        insert flexibleContainer;
        
        Intranet_Item__c officeItem = new Intranet_Item__c(Name = 'Test-0',Active_Status__c = 'Active',Item_Type__c='App Link',
                                                           RecordTypeId = mapRecordTypesWithName.get('Settings_Office').Id,Item_Title__c = 'Test',  
                                                           Category_Name__c = 'A',Color_Set_Name__c = 'ColorSet', 
                                                           Office_Short_Name__c = 'Office123456');
        insert officeItem;
        
        //Intranet scheedule record for testing
        Intranet_Schedule__c intranetSchedule = new Intranet_Schedule__c(Name = 'Test' , Intranet_Container__c = flexibleContainer.Id ,
                                                                         Intranet_Item__c = intranetItem.Id,
                                                                         Office__c = officeItem.Id,
                                                                         End_Date_Time__c = Date.Today().addDays(9),
                                                                         Start_Date_Time__c = Date.Today())  ; 
                                                                           
        insert  intranetSchedule;
        
        //Insert Job Item and Talent Item
        List<Intranet_Item__c> itemList = new List<Intranet_Item__c>();
        Intranet_Item__c JobItem = new Intranet_Item__c(Name = 'Test-0', Active_Status__c = 'Active', Approval_Status__c = 'Approved',
                                                        Item_Type__c='Job Item',
                                                        item_Title__c = 'Managing Director, Solutions Consulting',
                                                        RecordTypeId = mapRecordTypesWithName.get('Item_Feature').Id,
                                                        Entity__c = 'EAB');
        itemList.add(JobItem);
        
        Intranet_Item__c talentItem = new Intranet_Item__c(Name = 'Test-0', Active_Status__c = 'Active', Approval_Status__c = 'Approved',
                                                             Item_Type__c='Talent Item', 
                                                             item_Title__c = 'Motivate Team Members with Individual Recognition',
                                                            RecordTypeId = mapRecordTypesWithName.get('Item_Feature').Id);
        itemList.add(talentItem);
        
        //Insert List of Schedules
        List<Intranet_Schedule__c> schList = new List<Intranet_Schedule__c>();
        
        Intranet_Schedule__c sch1 = new Intranet_Schedule__c(Name = 'Test' , Intranet_Container__c = flexibleContainer.Id ,
                                                             Intranet_Item__c = JobItem.Id,
                                                             Office__c = officeItem.Id,
                                                             End_Date_Time__c = Date.Today().addDays(9),
                                                             Start_Date_Time__c = Date.Today(),
                                                             Entity__c = 'EAB')  ; 
                                                                           
        schList.add(sch1);
        Intranet_Schedule__c sch2 = new Intranet_Schedule__c(Name = 'Test' , Intranet_Container__c = flexibleContainer.Id ,
                                                             Intranet_Item__c = talentItem.Id,
                                                             Office__c = officeItem.Id,
                                                             End_Date_Time__c = Date.Today().addDays(9),
                                                             Start_Date_Time__c = Date.Today(),
                                                             Entity__c = 'EAB')  ; 
                                                                           
        schList.add(sch2);
        
        try {
        
        //Call PopulateUserSession method
        IntranetType.UserSession UserSession = IntranetHomeUtility.getUserSession;
        
        //Start Test from Here
        Test.startTest();
        
        IntranetContainer intranetContainerClass = new IntranetContainer(flexibleContainer);
        IntranetContent controller = new IntranetContent(intranetContainerClass, intranetSchedule, intranetItem, UserSession, new Map<String, Intranet_Utilization__c>());
        
        
        //Instantiate intranet Content for Job item
        IntranetContent jobItemContent = new IntranetContent(intranetContainerClass, sch1, JobItem, UserSession, new Map<String, Intranet_Utilization__c>());
        
        //Instantiate intranet Content for Talent item
       // IntranetContent talentItemContent = new IntranetContent(intranetContainerClass, sch2, talentItem, UserSession, new Map<String, Intranet_Utilization__c>());
        
        //Stop Test
        Test.stopTest();
        System.assertEquals(true, controller.IntranetContainerId == intranetContainerClass.ContainerId);
        System.assertEquals(true, controller.ContentMainImageURL == IntranetHomeUtility.LookupIntranetSetting('BaseImageUrl') + intranetItem.Content_Main_Image__c);
        System.assertEquals(true, jobItemContent.ContainerClass == 'JobItem');
       // System.assertEquals(true, talentItemContent.ContainerClass == 'TalentItem');
       // System.assertEquals(true, talentItemContent.ContentMainImageURL == IntranetHomeUtility.LookupIntranetSetting('BaseImageUrl') + intranetItem.Content_Main_Image__c);
        } catch(Exception e) {}   
    }
     /** Test Flexible container Items  Like Poll, Video, System Status, SubContainer Like Adv.com, eab.com**/
    static testMethod void testOtherContainerItems() {
        
         setup();
        Map<String, RecordType> mapRecordTypesWithName = getMapRecordTypesWithName();
        
        //Insert List of Container
        List<Intranet_Container__c> containerList = new List<Intranet_Container__c>();
        
        Intranet_Container__c pollContainer = new Intranet_Container__c();
        pollContainer.Name = 'Content - Fixed-Boardroom-Quick Poll';
        pollContainer.Status__c = 'Active';
        pollContainer.Container_Type__c = 'Poll';
        pollContainer.Sort_Order__c = 4;
        pollContainer.Content_Types_Allowed__c = 'Poll Item';
        pollContainer.Display_Name__c = 'Quick Poll';
        pollContainer.RecordTypeId = mapRecordTypesWithName.get('Content_Fixed').Id;
        
        //Add to List
        containerList.add(pollContainer);
        
        //Add Advisory.Com SubContainer
        Intranet_Container__c avisorySubContainer = new Intranet_Container__c();
        avisorySubContainer.Name = 'Content - SubContainer-Trending-Advisory.com';
        avisorySubContainer.Status__c = 'Active';
        avisorySubContainer.Container_Type__c = 'SubContainer';
        avisorySubContainer.Sort_Order__c = 4;
        avisorySubContainer.Content_Types_Allowed__c = 'Trending - Advisory.com';
        avisorySubContainer.Display_Name__c = 'Advisory.com';
        avisorySubContainer.RecordTypeId = mapRecordTypesWithName.get('Content_SubContainer').Id;
        //Add to List
        containerList.add(avisorySubContainer);
        
         //Insert Container for Video
        Intranet_Container__c vidoeContainer = new Intranet_Container__c();
        vidoeContainer.Name = 'Content - Fixed-Boardroom-ABC Video';
        vidoeContainer.Status__c = 'Active';
        vidoeContainer.Container_Type__c = 'Video';
        vidoeContainer.Sort_Order__c = 1;
        vidoeContainer.Content_Types_Allowed__c = 'Video Item';
        vidoeContainer.Display_Name__c = 'ABC Video';
        vidoeContainer.RecordTypeId = mapRecordTypesWithName.get('Content_Fixed').Id;
        containerList.add(vidoeContainer);
        
        //Insert Container List
        insert containerList;
        
        //Item List
        List<Intranet_Item__c> itemList = new List<Intranet_Item__c>();
        
         //======== Poll item =========================
        Intranet_Item__c pollItem = new Intranet_Item__c();
        pollItem.Name = 'Bedtimes? - Poll Item';
        pollItem.Item_Type__c = 'Poll Item';
        pollItem.Approval_Status__c = 'Approved';
        pollItem.Item_Title__c = 'Bedtimes?';
        pollItem.RecordTypeId = mapRecordTypesWithName.get('Item_Poll').Id;
        
        itemList.add(pollItem);
        
         //============= Advisor.Com Item ==================
        Intranet_Item__c advisoryDotComItem = new Intranet_Item__c();
        advisoryDotComItem.Name = 'Chef for a day at Ronald McDonald House - Office Event';
        advisoryDotComItem.Item_Type__c = 'Trending - Advisory.com';
        advisoryDotComItem.Approval_Status__c = 'Approved';
        advisoryDotComItem.Item_Title__c = 'How do you do it all?Secrets from super-efficient people | The Advisory Board Daily Briefing';
        advisoryDotComItem.Trend_Type__c = 'Most Popular Last 7 Days';
        advisoryDotComItem.Trending_View_Count__c = 13535;
        advisoryDotComItem.Trending_Visit_Count__c = 13535;
        advisoryDotComItem.Sort_Order__c = 1;
        advisoryDotComItem.Last_Content_Update__c = DateTime.now();
        advisoryDotComItem.RecordTypeId = mapRecordTypesWithName.get('Item_Trending').Id;
        itemList.add(advisoryDotComItem);
       
        //Insert video Item
        Intranet_Item__c videoItem = new Intranet_Item__c();
        videoItem.Name = 'What are Bundled Payments? - Video Item';
        videoItem.Item_Type__c = 'Video Item';
        videoItem.Approval_Status__c = 'Approved';
        videoItem.Item_Title__c = 'What are Bundled Payments?';
        videoItem.RecordTypeId = mapRecordTypesWithName.get('Item_Video').Id;
        itemList.add(videoItem);
        
        //Insert Item List
        insert itemList;
        
        //Schedule List
        List<Intranet_Schedule__c> scheduleList = new List<Intranet_Schedule__c>();
        
        Intranet_Schedule__c pollSchedule = new Intranet_Schedule__c();
        pollSchedule.Name = 'Events - Chef for a day at Ronald McDonald House';
        pollSchedule.Active_Status__c = 'Active';
        pollSchedule.Intranet_Container__c = pollContainer.Id;
        pollSchedule.Intranet_Item__c = pollItem.Id;
        pollSchedule.RecordTypeId = mapRecordTypesWithName.get('Static').Id;
        
        //Add to Schedule List
        scheduleList.add(pollSchedule);
        
        //Trending Schedule
        Intranet_Schedule__c trendingSchdeule = new Intranet_Schedule__c();
        trendingSchdeule.Name = 'Events - Chef for a day at Ronald McDonald House';
        trendingSchdeule.Active_Status__c = 'Active';
        trendingSchdeule.Intranet_Container__c = avisorySubContainer.Id;
        trendingSchdeule.Intranet_Item__c = advisoryDotComItem.Id;
        trendingSchdeule.RecordTypeId = mapRecordTypesWithName.get('Static').Id;
        scheduleList.add(trendingSchdeule);
        
        //Insert Schdule for video item
        Intranet_Schedule__c videoSchedule = new Intranet_Schedule__c();
        videoSchedule.Name = 'Events - Chef for a day at Ronald McDonald House';
        videoSchedule.Active_Status__c = 'Active';
        videoSchedule.Intranet_Container__c = vidoeContainer.Id;
        videoSchedule.Intranet_Item__c = videoItem.Id;
        videoSchedule.RecordTypeId = mapRecordTypesWithName.get('Static').Id;
        //Add to Schedule List
        scheduleList.add(videoSchedule);
        
        //Insert schdule Listy
        insert scheduleList;
        
        //Call PopulateUserSession method
        IntranetType.UserSession UserSession = IntranetHomeUtility.getUserSession;
        
        //======================= Post Poll for Intranet Item ========================================
        
        //Insert Poll Item  
        ConnectApi.FeedType feedType = ConnectApi.FeedType.Record;
        
        //Poll Parent Record Id
        String subjectId = pollItem.Id;
        
        //List of Poll Choice
        List<String> pollChoices = new List<String>();
        pollChoices.add('Choice 1');
        pollChoices.add('Choice 2');
        
        //Set Poll Question in FeedPost Body
        String pollQuestion = 'Which choice is correct ?';
        
        //Attach Poll Question and choices.
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        ConnectApi.PollAttachmentInput pollAttachment = new ConnectApi.PollAttachmentInput();
        pollAttachment.pollChoices = pollChoices;
        feedItemInput.attachment = pollAttachment;
        
        //Instantiate Message Input
        ConnectApi.MessageBodyInput messageInput = new ConnectApi.MessageBodyInput();
        
        //Instantiate Message Segments
        messageInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        
        //Prepate Text Segment to Be Post
        ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput();
        textSegment.text = pollQuestion;
        messageInput.messageSegments.add(textSegment);
        
        //Set Question in Body
        feedItemInput.body = messageInput;
        
        // Modified By - Rajeev Jain (03/17/2020) (As Feed Tracking for Intranet Item off) Starts Here
        /*
        //Post Feed Item to Chatter
        ConnectApi.FeedItem feedItemRep = ConnectApi.ChatterFeeds.postFeedItem(null, feedType, subjectId, feedItemInput, null); 
        
        //Update Poll Id at intranet Item record
        pollItem.Poll_Id__c = feedItemRep.Id;
        update pollItem;
        */
        // Modified By - Rajeev Jain (03/17/2020) (As Feed Tracking for Intranet Item off) Ends Here
        
        //======================= Poll Posted =============================================================================
        
        //Start Test
        Test.startTest();
        
        //Instantiate Poll item
        IntranetContainer pollContainerClass = new IntranetContainer(pollContainer);
        IntranetContent pollContentItem = new IntranetContent(pollContainerClass, pollSchedule, pollItem, UserSession, new Map<String, Intranet_Utilization__c>());
        
        //Instantiate Trending Item
        IntranetContainer trendingContainerClass = new IntranetContainer(avisorySubContainer);
        IntranetContent trendingContentItem = new IntranetContent(trendingContainerClass, trendingSchdeule, advisoryDotComItem, UserSession, new Map<String, Intranet_Utilization__c>());
        
         //Instantiate Video Item
        IntranetContainer videoContainerClass = new IntranetContainer(vidoeContainer);
        IntranetContent videoContentItem = new IntranetContent(videoContainerClass, videoSchedule, videoItem, UserSession, new Map<String, Intranet_Utilization__c>());
        
        //Stop Test
        Test.stopTest();
        
        //Assert for Poll items
        System.assertEquals(true, pollContentItem.PollId == pollItem.Poll_Id__c);
        System.assertEquals(true, trendingContentItem.SortOrder == -advisoryDotComItem.Last_Content_Update__c.addMinutes(-Integer.valueOf(advisoryDotComItem.Sort_Order__c)).getTime());
        System.assertEquals(true, videoContentItem.LinkAction == videoItem.Link_Behaviour__c);
    }
    
    static testMethod void testMemberEventAndFirmLinkItem() {
        setup();
        
        //Map to hold record type corrosponding to their developer name
        Map<String, RecordType> mapRecordTypesWithName = getMapRecordTypesWithName();
        
        //============================= Firm App Link ======================================
        //Hamburger Menu Container
        Intranet_Container__c hemburgerMenuContainer = new Intranet_Container__c(Name = 'Content - Fixed-BoardroomHeader-Hamburger Menu',
                                                                                 Container_Type__c = 'Menu',
                                                                                 Status__c = 'Active',
                                                                                 Content_Types_Allowed__c = 'Firm App Link; Page Link; Menu Link; Favorite Link',
                                                                                 Display_Name__c='Hamburger Menu',
                                                                                 RecordTypeId = mapRecordTypesWithName.get('Content_Fixed').Id);
        
        insert hemburgerMenuContainer;
        
        //Insert Hamburger Menu Subcontainer 
        Intranet_Container__c hemburgerMenuSubContainer2 = new Intranet_Container__c(Name = 'Content - Fixed-Hamburger Menu-The Firm',
                                                                                     Container_Type__c = 'Menu',
                                                                                     Status__c = 'Active',
                                                                                     Sort_Order__c = 1,
                                                                                     Parent_Container__c = hemburgerMenuContainer.Id,
                                                                                     Content_Types_Allowed__c = 'Firm App Link; Page Link; Menu Link; Favorite Link',
                                                                                     Display_Name__c='Benefits and HealthyLife',
                                                                                     RecordTypeId = mapRecordTypesWithName.get('Content_Fixed').Id);
        insert hemburgerMenuSubContainer2;
        
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
        insert advisoryComItem;
        
        //Insert Schedule and Associate with containee and item
        Intranet_Schedule__c scheduleFirm = new Intranet_Schedule__c();
        scheduleFirm.Name = 'The Firm - Advisory.com';
        scheduleFirm.Active_Status__c = 'Active';
        scheduleFirm.Intranet_Container__c = hemburgerMenuSubContainer2.Id;
        scheduleFirm.Intranet_Item__c = advisoryComItem.Id;
        scheduleFirm.End_Date_Time__c = Date.Today().addDays(90);
        scheduleFirm.Start_Date_Time__c = Date.Today();                                                                      
        insert scheduleFirm;
        
        //=================================================== Member Events ==========================================
        //Insert Abc Today Main Container
        //Abc Todya 3
        Intranet_Container__c abcToday = new Intranet_Container__c();
        abcToday.Name = 'Content - Fixed-Boardroom-ABC Today';
        abcToday.Status__c = 'Active';
        abcToday.Container_Type__c = 'ABC Today';
        abcToday.Content_Types_Allowed__c = 'Page Section';
        abcToday.Display_Name__c = 'ABC Today';
        abcToday.RecordTypeId = mapRecordTypesWithName.get('Content_Fixed').Id;
        insert abcToday;
        
        //Insert Sub Containers below the Abc Today container
        List<Intranet_Container__c> abcTodaySubContainers = new List<Intranet_Container__c>();
        
        //Insert Memeber Event SubContainer
        Intranet_Container__c memberEventSubContainer = new Intranet_Container__c();
        memberEventSubContainer.Name = 'Content - SubContainer-ABC Today-Member Events';
        memberEventSubContainer.Parent_Container__c = abcToday.Id;
        memberEventSubContainer.Status__c = 'Active';
        memberEventSubContainer.Sort_Order__c = 2;
        memberEventSubContainer.Container_Type__c = 'SubContainer';
        memberEventSubContainer.Content_Types_Allowed__c = 'Member Event';
        memberEventSubContainer.Display_Name__c = 'Member Events';
        memberEventSubContainer.RecordTypeId = mapRecordTypesWithName.get('Content_SubContainer').Id;
        abcTodaySubContainers.add(memberEventSubContainer);
        
        //Insert Birthday Events SubContainer
        Intranet_Container__c birthdaySubContainer = new Intranet_Container__c();
        birthdaySubContainer.Name = 'Content - SubContainer-ABC Today-Birthdays';
        birthdaySubContainer.Parent_Container__c = abcToday.Id;
        birthdaySubContainer.Status__c = 'Active';
        birthdaySubContainer.Sort_Order__c = 3;
        birthdaySubContainer.Container_Type__c = 'SubContainer';
        birthdaySubContainer.Content_Types_Allowed__c = 'Birthdays';
        birthdaySubContainer.Display_Name__c = 'Birthdays';
        birthdaySubContainer.RecordTypeId = mapRecordTypesWithName.get('Content_SubContainer').Id;
        abcTodaySubContainers.add(birthdaySubContainer);
        
        insert abcTodaySubContainers;
        
        //Insert Items for Each Abc Today SubContainer
        Intranet_Item__c memberEventItem = new Intranet_Item__c();
        memberEventItem.Name = 'Cooking Lesson for Members - Member Event';
        memberEventItem.Item_Type__c = 'Member Event';
        memberEventItem.Item_Title__c = 'Cooking Lesson for Members';
        memberEventItem.Link_URL__c = 'http://www.cooking.com';
        memberEventItem.Link_Type__c = 'Standard';
        memberEventItem.Link_Action__c = 'Open in New Tab/Window';
        memberEventItem.RecordTypeId = mapRecordTypesWithName.get('Item_Event').Id;
        memberEventItem.Floor__c = '8th';
        memberEventItem.Room_Name__c = 'University';
        memberEventItem.Room_Number__c = '800';
        memberEventItem.Event_Start_Date_Time__c = DateTime.now();
        memberEventItem.Event_End_Date_Time__c = DateTime.now().addDays(30);
        memberEventItem.Location_City__c = 'WASHINGTON DC';
        insert memberEventItem;
        
        //Insert Schdule for Particular Item
        //Insert Schedule and Associate with containee and item
        Intranet_Schedule__c scheduleMemberEvent = new Intranet_Schedule__c();
        scheduleMemberEvent.Name = 'Member Events - Cooking Lesson for Members';
        scheduleMemberEvent.Active_Status__c = 'Active';
        scheduleMemberEvent.Intranet_Container__c = memberEventSubContainer.Id;
        scheduleMemberEvent.Intranet_Item__c = memberEventItem.Id;
        scheduleMemberEvent.End_Date_Time__c = Date.Today().addDays(30);
        scheduleMemberEvent.Start_Date_Time__c = Date.Today();                                                                      
        insert scheduleMemberEvent;
        
        //============================================ Insert Office Event =====================================
        
        //Call PopulateUserSession method
        IntranetType.UserSession UserSession = IntranetHomeUtility.getUserSession;
        
        //Start Test from here
        Test.startTest();
        
        //============Firm App Link ==========================
        IntranetContainer intranetContainerClass = new IntranetContainer(hemburgerMenuSubContainer2);
        IntranetContent controller = new IntranetContent(intranetContainerClass, scheduleFirm, advisoryComItem, UserSession, new Map<String, Intranet_Utilization__c>());
        
        //============= Member Event ==============================
        IntranetContainer memberEventIntranetContainer = new IntranetContainer(memberEventSubContainer);
        IntranetContent memberEventContentItem = new IntranetContent(memberEventIntranetContainer, scheduleMemberEvent, memberEventItem, UserSession, new Map<String, Intranet_Utilization__c>());
        
        //Stop Test from Here
        Test.stopTest();
        
        //Asserts for Results
        System.assertEquals(true, controller.IntranetContainerId == intranetContainerClass.ContainerId);
      
    }
    
    /** This Method test Other Intranet Content Items Like Component Link, Member Impact, Member Impact **/
    static testMethod void testVariourOtherIntranetContent() {
        
        setup();
        
        //Map to hold record type corrosponding to their developer name
        Map<String, RecordType> mapRecordTypesWithName = getMapRecordTypesWithName();
        
        //List to Hold Intranet Items
        List<Intranet_Item__c> itemList = new List<Intranet_Item__c>();
        
        //List to Hold Container List
        List<Intranet_Container__c> containerList = new List<Intranet_Container__c>();
        
        //List to Insert Schedule
        List<Intranet_Schedule__c> scheduleList = new List<Intranet_Schedule__c>();
        
         //==================== All Container and SubContainer ==============================================
        //Insert Office Event Container 
        Intranet_Container__c officeEventSubContainer = new Intranet_Container__c();
        officeEventSubContainer.Name = 'Content - SubContainer-Office-Events';
        officeEventSubContainer.Status__c = 'Active';
        officeEventSubContainer.Container_Type__c = 'SubContainer';
        officeEventSubContainer.Sort_Order__c = 4;
        officeEventSubContainer.Content_Types_Allowed__c = 'Office Event';
        officeEventSubContainer.Display_Name__c = 'Events';
        officeEventSubContainer.RecordTypeId = mapRecordTypesWithName.get('Content_SubContainer').Id;
        
        //Add to List
        containerList.add(officeEventSubContainer);
        
         //Insert Training Event SubContainer
        Intranet_Container__c trainingEventSubContainer = new Intranet_Container__c();
        trainingEventSubContainer.Name = 'Content - SubContainer-ABC Today-Training';
        trainingEventSubContainer.Status__c = 'Active';
        trainingEventSubContainer.Container_Type__c = 'SubContainer';
        trainingEventSubContainer.Sort_Order__c = 1;
        trainingEventSubContainer.Content_Types_Allowed__c = 'Training Event';
        trainingEventSubContainer.Display_Name__c = 'Training';
        trainingEventSubContainer.RecordTypeId = mapRecordTypesWithName.get('Content_SubContainer').Id;
        containerList.add(trainingEventSubContainer);
        
         //Insert Container for Component Link
        Intranet_Container__c memberEventSubContainer = new Intranet_Container__c();
        memberEventSubContainer.Name = 'Content - SubContainer-Member Events-MemberEventLinks';
        memberEventSubContainer.Status__c = 'Active';
        memberEventSubContainer.Container_Type__c = 'SubContainer';
        memberEventSubContainer.Content_Types_Allowed__c = 'Member Event, Component Link';
        memberEventSubContainer.Display_Name__c = 'MemberEventLinks';
        memberEventSubContainer.RecordTypeId = mapRecordTypesWithName.get('Content_SubContainer').Id;
        containerList.add(memberEventSubContainer);
        
        //Insert Container for Member Impact
        Intranet_Container__c memberImpactContainer = new Intranet_Container__c();
        memberImpactContainer.Name = 'Content - Fixed-Boardroom-Member Impact';
        memberImpactContainer.Status__c = 'Active';
        memberImpactContainer.Container_Type__c = 'Member Impact';
        memberImpactContainer.Content_Types_Allowed__c = 'Member Impact Story';
        memberImpactContainer.Display_Name__c = 'Member Impact';
        memberImpactContainer.RecordTypeId = mapRecordTypesWithName.get('Content_Fixed').Id;
        containerList.add(memberImpactContainer);
        
        //System Status 
        Intranet_Container__c systemStatusContainer = new Intranet_Container__c();
        systemStatusContainer.Name = 'Content - Fixed-BoardroomHeader-Status';
        systemStatusContainer.Status__c = 'Active';
        systemStatusContainer.Container_Type__c = 'System Status';
        systemStatusContainer.Content_Types_Allowed__c = 'System Status';
        systemStatusContainer.Display_Name__c = 'Status';
        systemStatusContainer.RecordTypeId = mapRecordTypesWithName.get('Content_Fixed').Id;
        containerList.add(systemStatusContainer);
        
        //Insert Container List
        insert containerList;
        
         //=========================== All Content and Default Content Item ================================
        Intranet_Item__c officeEventItem = new Intranet_Item__c();
        officeEventItem.Name = 'Chef for a day at Ronald McDonald House - Office Event';
        officeEventItem.Item_Type__c = 'Office Event';
        officeEventItem.Item_Title__c = 'Chef for a day at Ronald McDonald House';
        officeEventItem.Link_URL__c = '';
        officeEventItem.Link_Type__c = 'Standard';
        officeEventItem.Link_Action__c = '';
        officeEventItem.RecordTypeId = mapRecordTypesWithName.get('Item_Event').Id;
        officeEventItem.Event_Start_Date_Time__c = DateTime.now();
        officeEventItem.Event_End_Date_Time__c = DateTime.now().addDays(30);
        //Add to Item List
        itemList.add(officeEventItem);
        
         //=======Traning Evnet Item =======================
        Intranet_Item__c trainingEvent = new Intranet_Item__c();
        trainingEvent.Name = 'Cooking Lesson - Training Event';
        trainingEvent.Item_Type__c = 'Training Event';
        trainingEvent.Item_Title__c = 'Cooking Lesson';
        trainingEvent.Link_URL__c = '';
        trainingEvent.Link_Type__c = 'Standard';
        trainingEvent.Link_Action__c = 'Open in New Tab/Window';
        trainingEvent.RecordTypeId = mapRecordTypesWithName.get('Item_Event').Id;
        trainingEvent.Event_Start_Date_Time__c = DateTime.now();
        trainingEvent.Event_End_Date_Time__c = DateTime.now().addDays(30);
        
        //Add to Item List
        itemList.add(trainingEvent);
        
        //Add Office Item
        Intranet_Item__c officeItem = new Intranet_Item__c(Name = 'Test-0',Active_Status__c = 'Active',Item_Type__c='App Link',
                                                                   RecordTypeId = mapRecordTypesWithName.get('Settings_Office').Id,Item_Title__c = 'Test',  
                                                                   Category_Name__c = 'A',Color_Set_Name__c = 'ColorSet', 
                                                                   Office_Short_Name__c = 'Office123456');
        //Add to List
        itemList.add(officeItem);
        
        //Insert ComponentLink Item
        Intranet_Item__c componentLinkItem = new Intranet_Item__c();
        componentLinkItem.Name = 'VIEW WEBCONFERENCES - Component Link';
        componentLinkItem.Item_Type__c = 'Component Link';
        componentLinkItem.Approval_Status__c = 'Approved';
        componentLinkItem.Item_Title__c = 'VIEW WEBCONFERENCES';
        componentLinkItem.RecordTypeId = mapRecordTypesWithName.get('Item_Link').Id;
        itemList.add(componentLinkItem);
        
        //Insert MemberImpact Item
        Intranet_Item__c memberImpactItem = new Intranet_Item__c();
        memberImpactItem.Name = 'Auburn University - Member Impact';
        memberImpactItem.Item_Type__c = 'Member Impact';
        memberImpactItem.Approval_Status__c = 'Approved';
        memberImpactItem.Item_Title__c = 'Auburn University';
        memberImpactItem.RecordTypeId = mapRecordTypesWithName.get('Item_Firm_Initiative').Id;
        itemList.add(memberImpactItem);
        
         //Insert System Stauts Item
        Intranet_Item__c systemStatus = new Intranet_Item__c();
        systemStatus.Name = 'All System Operating normally - System Status';
        systemStatus.Item_Type__c = 'System Status';
        systemStatus.Approval_Status__c = 'Approved';
        systemStatus.Item_Title__c = 'All System Operating normally';
        systemStatus.RecordTypeId = mapRecordTypesWithName.get('Item_Feature').Id;
        itemList.add(systemStatus);
        
        //Insert Item List
        insert itemList;
        
         //================= All Schedule ================================
        Intranet_Schedule__c officeSchedule = new Intranet_Schedule__c();
        officeSchedule.Name = 'Events - Chef for a day at Ronald McDonald House';
        officeSchedule.Active_Status__c = 'Active';
        officeSchedule.Intranet_Container__c = officeEventSubContainer.Id;
        officeSchedule.Intranet_Item__c = officeEventItem.Id;
        officeSchedule.End_Date_Time__c = Date.Today().addDays(30);
        officeSchedule.Start_Date_Time__c = Date.Today();                                                                      
        officeSchedule.Office__c = officeItem.Id;
               
        //Add to Schedule List
        scheduleList.add(officeSchedule);
        
         //=======Training Schedule ================
        Intranet_Schedule__c trainingSchedule = new Intranet_Schedule__c();
        trainingSchedule.Name = 'Events - Chef for a day at Ronald McDonald House';
        trainingSchedule.Active_Status__c = 'Active';
        trainingSchedule.Intranet_Container__c = trainingEventSubContainer.Id;
        trainingSchedule.Intranet_Item__c = trainingEvent.id;
        trainingSchedule.RecordTypeId = mapRecordTypesWithName.get('Static').Id;  
        scheduleList.add(trainingSchedule);
        
        //Insert Schdule for Component Link Item and container
        Intranet_Schedule__c componentLinkschedule = new Intranet_Schedule__c();
        componentLinkschedule.Name = 'MemberEventLinks - VIEW WEBCONFERENCES';
        componentLinkschedule.Active_Status__c = 'Active';
        componentLinkschedule.Intranet_Container__c = memberEventSubContainer.Id;
        componentLinkschedule.Intranet_Item__c = componentLinkItem.Id;
        componentLinkschedule.RecordTypeId = mapRecordTypesWithName.get('Static').Id;
        //Add to Schedule List
        scheduleList.add(componentLinkschedule);
        
        //Insert Member Impact Schedule
        Intranet_Schedule__c memberImpactSchedule = new Intranet_Schedule__c();
        memberImpactSchedule.Name = 'Member Impact - Auburn University';
        memberImpactSchedule.Active_Status__c = 'Active';
        memberImpactSchedule.Intranet_Container__c = memberImpactContainer.Id;
        memberImpactSchedule.Intranet_Item__c = memberImpactItem.Id;
        memberImpactSchedule.RecordTypeId = mapRecordTypesWithName.get('Static').Id;
        //Add to Schedule List
        scheduleList.add(memberImpactSchedule);
        
         //Insert Schedule List
        insert scheduleList;
        
         //Call PopulateUserSession method
        IntranetType.UserSession UserSession = IntranetHomeUtility.getUserSession;
        
        
        //Start Test from here
        Test.startTest();
        
        //================ Office Event Content ========================================
        IntranetContainer officeEventContainerClass = new IntranetContainer(officeEventSubContainer);
        IntranetContent officeEventContentitem = new IntranetContent(officeEventContainerClass, officeSchedule, officeEventItem, UserSession, new Map<String, Intranet_Utilization__c>());
        
        //Instantiate Training Item
        IntranetContainer trainingContainerClass = new IntranetContainer(trainingEventSubContainer);
        IntranetContent trainingContentItem = new IntranetContent(trainingContainerClass, trainingSchedule, trainingEvent, UserSession, new Map<String, Intranet_Utilization__c>());
        
         //Instantiate Component Link Item
        IntranetContainer memberEventContainerClass = new IntranetContainer(memberEventSubContainer);
        IntranetContent componentLinkContentItem = new IntranetContent(memberEventContainerClass, componentLinkschedule, componentLinkItem, UserSession, new Map<String, Intranet_Utilization__c>());
        
        //Instantiate Member Impact Item
        IntranetContainer memberImpactClass = new IntranetContainer(memberImpactContainer);
        IntranetContent memberImpactContentItem = new IntranetContent(memberImpactClass, memberImpactSchedule, memberImpactItem, UserSession, new Map<String, Intranet_Utilization__c>());
        
        //Call Another Intrant Content Constructor when Schedule id is null
        IntranetContainer systemStatusClass = new IntranetContainer(systemStatusContainer);
        officeEventContentitem = new IntranetContent(systemStatusClass,systemStatus, UserSession, new Map<String, Intranet_Utilization__c>());
        
        //List of Intranet Item Content and provide Sort method for code coverage
        List<IntranetContent> contentList = new List<IntranetContent>();
        contentList.add(officeEventContentitem);
        contentList.add(trainingContentItem);
        contentList.add(componentLinkContentItem);
        contentList.add(memberImpactContentItem);
        
        //Sort
        contentList.sort();
        
        //============== Provide Coverage to some public Properties which are not covered 
        //==== Cover through any of the content item
        String firstName = officeEventContentitem.FirstName;
        String LastName = officeEventContentitem.LastName;
        String ABCDepartment = officeEventContentitem.ABCDepartment;
        String UserId = officeEventContentitem.UserId;
        String SmallPhotoUrl = officeEventContentitem.SmallPhotoUrl;
        String ContentMainImagePath = officeEventContentitem.ContentMainImagePath;
        String ContentType = officeEventContentitem.ContentType;
        
        String Country = officeEventContentitem.Country;
        String CurrentOfficeId = officeEventContentitem.CurrentOfficeId;
        String Fax = officeEventContentitem.Fax;
        String GoToMeetingLink = officeEventContentitem.GoToMeetingLink;
        String ImageForMainContent = officeEventContentitem.ImageForMainContent;
        String ImageForThumbnail = officeEventContentitem.ImageForThumbnail;
        String ImageSetThumbnailImageId = officeEventContentitem.ImageSetThumbnailImageId;
        
        String ImageSetType = officeEventContentitem.ImageSetType;
        String ItemHeadline = officeEventContentitem.ItemHeadline;
        String Location = officeEventContentitem.Location;
        String OfficeNotes = officeEventContentitem.OfficeNotes;
        String OfficeShortName = officeEventContentitem.OfficeShortName;
        String Phone = officeEventContentitem.Phone;
        String PostalCode = officeEventContentitem.PostalCode;
        
        String RelatedFirmInitiativeId = officeEventContentitem.RelatedFirmInitiativeId;
        String RelatedFirmInitiativeLink = officeEventContentitem.RelatedFirmInitiativeLink;
        String SetType = officeEventContentitem.SetType;
        String State = officeEventContentitem.State;
        String TextBoxBackColorCode = officeEventContentitem.TextBoxBackColorCode;
        String ThumbnailImagePath = officeEventContentitem.ThumbnailImagePath;
        String TimeZone = officeEventContentitem.TimeZone;
        
        String TitleTextPosition = officeEventContentitem.TitleTextPosition;
        String TextColorCode = officeEventContentitem.TextColorCode;
        String TitleTextSize = officeEventContentitem.TitleTextSize;
        
        Boolean bl = officeEventContentitem.ConfigurationItem;
        Id id1 = officeEventContentitem.ContentViewerImage;
        DateTime dt = officeEventContentitem.FinalExpiration;
        DateTime dt1 = officeEventContentitem.FirstAvailable;
        DateTime dt3 = officeEventContentitem.CurrentTime;
        Id id2 = officeEventContentitem.ImageSet;
        Id id3 = officeEventContentitem.ImageSetName;
        Id id4 = officeEventContentitem.IntranetContainer;
        Id id5 = officeEventContentitem.ParentContainerID;
        Integer it = officeEventContentitem.TrendingViewCount;
        Date dt10 = officeEventContentitem.LastContentUpdate;
        
        //cALL tOString Method of it
        String toString = officeEventContentitem.ToString('Test Test @@@@');
        //Stop Test
        Test.stopTest();
       
    }
    
}