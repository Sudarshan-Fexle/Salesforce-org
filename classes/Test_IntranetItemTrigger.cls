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
/** Description       :   Test class for IntranetItemTrigger
  * 
  *  Created Date     :   08/05/2014
  *
  *  Created By       :      
  *  
  *  Current vision   :    v1.0
  * 
  *  Revision Logs    :    v1.0 - Created
  *           :     V2.0 - Modified By - Rajeev Jain - CR-7579 - 09/11/2015 - Increase code coverage
  *
  *  Coverage         :    94% 
  **/
@isTest(seeAllData= false)
private class Test_IntranetItemTrigger {
    
    
    //Setup all common data required in test class
    @testSetup static void setup() {
      
        //Insert YouTube Video and Vimeo Video Image Custom Setting so Trigger can use those setting
        //List of Custom Setting
        List<Intranet_Video_Item_Links__c> videoLinks = new List<Intranet_Video_Item_Links__c>();
        videoLinks.add(new Intranet_Video_Item_Links__c(Name = 'Vimeo_Thumbnail_Large', Value__c = 'thumbnail_large', Is_Enabled__c = false));
        videoLinks.add(new Intranet_Video_Item_Links__c(Name = 'Vimeo_Thumbnail_Medium', Value__c = 'thumbnail_medium', Is_Enabled__c = true));
        videoLinks.add(new Intranet_Video_Item_Links__c(Name = 'Vimeo_Thumbnail_Small', Value__c = 'thumbnail_small', Is_Enabled__c = false));
        videoLinks.add(new Intranet_Video_Item_Links__c(Name = 'YouTube_0_JPG', Value__c = '/0.jpg', Is_Enabled__c = false));
        videoLinks.add(new Intranet_Video_Item_Links__c(Name = 'YouTube_1_JPG', Value__c = '/1.jpg', Is_Enabled__c = true));
        videoLinks.add(new Intranet_Video_Item_Links__c(Name = 'YouTube_2_JPG', Value__c = '/2.jpg', Is_Enabled__c = false));
        videoLinks.add(new Intranet_Video_Item_Links__c(Name = 'YouTube_3_JPG', Value__c = '/3.jpg', Is_Enabled__c = false));
        videoLinks.add(new Intranet_Video_Item_Links__c(Name = 'YouTube_Default_JPG', Value__c = '/default.jpg', Is_Enabled__c = false));
        
        //Indsert Setting Data
        insert videoLinks;
    }
    
    /**
      * @Description    :   Method to check functionality of  validateDate
      *
      * @args           :   
      *
      * @return         :   void
      *
    **/
    static testMethod void testValidateData() {
    
        Map<String, RecordType> mapRecordTypesWithName = new Map<String, RecordType>();
        for(RecordType rType : [Select Id, DeveloperName From RecordType where sObjectType='Intranet_Item__c' AND isActive=true]) {
            
            //Put in map
            mapRecordTypesWithName.put(rType.DeveloperName.toLowerCase(), rType);
        }
        
        //List of Intranet items
        List<Intranet_Item__c> listIntranetItems = new List<Intranet_Item__c>();
        listIntranetItems.add(new Intranet_Item__c(Name = 'Test-0',Active_Status__c = 'Active',Item_Type__c = 'App Link',
                                                                   RecordTypeId = mapRecordTypesWithName.get('item_chart').Id, Item_Title__c = 'Test',
                                                                   Category_Name__c = 'A',Color_Set_Name__c = 'ColorSet', 
                                                                   Office_Short_Name__c = 'Office'));
        
        listIntranetItems.add(new Intranet_Item__c(Name = 'Test-0',Active_Status__c = 'Active',Item_Type__c='App Link',
                                                                   RecordTypeId = mapRecordTypesWithName.get('settings_category').Id,Item_Title__c = 'Test',
                                                                   Category_Name__c = 'A',Color_Set_Name__c = 'ColorSet', 
                                                                   Office_Short_Name__c = 'Office'));
            
        listIntranetItems.add(new Intranet_Item__c(Name = 'Test-0',Active_Status__c = 'Active',Item_Type__c='App Link',
                                                                   RecordTypeId = mapRecordTypesWithName.get('settings_color_set').Id,Item_Title__c = 'Test',
                                                                   Category_Name__c = 'A',Color_Set_Name__c = 'ColorSet', 
                                                                   Office_Short_Name__c = 'Office'));
            
        listIntranetItems.add(new Intranet_Item__c(Name = 'Test-0',Active_Status__c = 'Active',Item_Type__c='App Link',
                                                                   RecordTypeId = mapRecordTypesWithName.get('settings_office').Id,Item_Title__c = 'Test',  
                                                                   Category_Name__c = 'A',Color_Set_Name__c = 'ColorSet', 
                                                                   Office_Short_Name__c = 'Office'));            
        
        //Test start here
        Test.startTest();                                                              
        
        //Insert Intranet items
        insert listIntranetItems ;
        
        //Test stop here
        Test.stopTest();
      
      //Assert for the results
        listIntranetItems = [Select Id, Name, RecordType.Name, Item_Title__c, Item_Type__c, Category_Name__c, Color_Set_Name__c, Image_Set_Name__c, Office_Short_Name__c, CreatedDate
                                FROM Intranet_Item__c WHERE Id IN: listIntranetItems];      
                                                         
        
        System.assertEquals(listIntranetItems[0].Item_Title__c + IntranetItemTriggerHelper.NAME_VALUES_SEPARATOR + listIntranetItems[0].Item_Type__c + IntranetItemTriggerHelper.NAME_VALUES_SEPARATOR + listIntranetItems[0].CreatedDate.date().year() + IntranetItemTriggerHelper.DATE_FORMAT_SEPARATOR + ('0' + listIntranetItems[0].CreatedDate.date().month()).right(2) + IntranetItemTriggerHelper.DATE_FORMAT_SEPARATOR + ('0' + listIntranetItems[0].CreatedDate.date().day()).right(2), listIntranetItems[0].Name);                                               
        System.assertEquals(listIntranetItems[1].Category_Name__c + IntranetItemTriggerHelper.NAME_VALUES_SEPARATOR + listIntranetItems[0].Item_Type__c + IntranetItemTriggerHelper.NAME_VALUES_SEPARATOR + IntranetItemTriggerHelper.KEYWORD_SETTING, listIntranetItems[1].Name);
        System.assertEquals(listIntranetItems[2].Color_Set_Name__c + IntranetItemTriggerHelper.NAME_VALUES_SEPARATOR + listIntranetItems[0].Item_Type__c + IntranetItemTriggerHelper.NAME_VALUES_SEPARATOR + IntranetItemTriggerHelper.KEYWORD_SETTING, listIntranetItems[2].Name);
        System.assertEquals(listIntranetItems[3].Office_Short_Name__c + IntranetItemTriggerHelper.NAME_VALUES_SEPARATOR + listIntranetItems[0].Item_Type__c + IntranetItemTriggerHelper.NAME_VALUES_SEPARATOR + IntranetItemTriggerHelper.KEYWORD_SETTING, listIntranetItems[3].Name);                                               
    }
    
    /**
      * @Description    :   Method to check functionality of  createTopics
      *
      * @args           :   
      *
      * @return         :   void
      *
    **/ 
    static testMethod void testCreateTopicsOnInsert() {
        
        //Record Type
        RecordType settingCatogary = [Select Name, Id From RecordType where sObjectType='Intranet_Item__c' AND isActive=true AND DeveloperName = 'Settings_Category' LIMIT 1];
        
         //Intranet container
        Intranet_Container__c IntranetContainer = new Intranet_Container__c(Name= 'Parent-Contaiiner',
                                                                            CurrencyIsoCode = 'USD',
                                                                            Content_Types_Allowed__c = 'App Link',
                                                                            Display_Name__c='Testing');
        insert IntranetContainer ;
        
        //List of main Intranet Item
        List<Intranet_Item__c> mainInterItems = new List<Intranet_Item__c>();
        mainInterItems.add(new Intranet_Item__c(Name= 'Test', CurrencyIsoCode = 'USD', RecordTypeId = settingCatogary.Id, Category_Name__c = 'A'));
        mainInterItems.add(new Intranet_Item__c(Name= 'Test', CurrencyIsoCode = 'USD', RecordTypeId = settingCatogary.Id, Category_Name__c = 'B'));
        mainInterItems.add(new Intranet_Item__c(Name= 'Test', CurrencyIsoCode = 'USD', RecordTypeId = settingCatogary.Id, Category_Name__c = 'C'));

        insert mainInterItems;
        
        //List of Intranet items  
        List<Intranet_Item__c> listIntranetItems = new List<Intranet_Item__c>();  
        listIntranetItems.add(new Intranet_Item__c(Name = 'DFG', Main_Category__c  = mainInterItems[0].Id, RecordTypeId = settingCatogary.Id,
                                                                   Category_Name__c ='A',
                                                                   CurrencyIsoCode = 'USD'));
                                                                   
        listIntranetItems.add(new Intranet_Item__c(Name = 'Test-1',Main_Category__c  = mainInterItems[0].Id ,
                                                                   RecordTypeId = settingCatogary.Id,
                                                                   Category_Name__c ='B',
                                                                   CurrencyIsoCode = 'USD'));
                                                                   
        listIntranetItems.add(new Intranet_Item__c(Name = 'Test-2',Main_Category__c  = mainInterItems[0].Id ,
                                                                   RecordTypeId = settingCatogary.Id,
                                                                   Category_Name__c ='C',
                                                                   CurrencyIsoCode = 'USD'));
                                                                   
        listIntranetItems.add(new Intranet_Item__c(Name = 'Test-4',Main_Category__c  = mainInterItems[1].Id ,
                                                                   RecordTypeId = settingCatogary.Id,
                                                                   Category_Name__c ='D',
                                                                   CurrencyIsoCode = 'USD'));
                                                                   
        listIntranetItems.add(new Intranet_Item__c(Name = 'Test-6',Main_Category__c  = mainInterItems[0].Id ,
                                                                   RecordTypeId = settingCatogary.Id,
                                                                   Category_Name__c ='E',
                                                                   CurrencyIsoCode = 'USD'));
                                                                   
        listIntranetItems.add(new Intranet_Item__c(Name = 'Test-7',Main_Category__c  = mainInterItems[1].Id ,
                                                                   RecordTypeId = settingCatogary.Id,
                                                                   Category_Name__c ='F',
                                                                   CurrencyIsoCode = 'USD'));
        
        //Start testing from here
        Test.startTest();
        
        //Insert Items
        insert listIntranetItems;
        
        //Stop Testing here
        Test.stopTest();
      
      //Assert for results
        //This will create topic for the Main Items #1 and #2
        List<Topic> listTopic  = [Select Id From Topic];
        system.assertEquals(listTopic.size(), 2);
        
        //6 Assignemnets will be get created
        List<TopicAssignment> tpcAssgs =  [Select Id, EntityId, TopicId FROM TopicAssignment];
        system.assertEquals(tpcAssgs.size(), 6);
    }
    
    /**
      * @Description    :   Method to check functionality of  createTopics
      *
      * @args           :   
      *
      * @return         :   void
      *
    **/ 
    static testMethod void testCreateTopicsOnUpdate() {
        
        //Record Type
        RecordType settingCatogary = [Select Name, Id From RecordType where sObjectType='Intranet_Item__c' AND isActive=true AND DeveloperName = 'Settings_Category' LIMIT 1];
        
         //Intranet container
        Intranet_Container__c IntranetContainer = new Intranet_Container__c(Name= 'Parent-Contaiiner',
                                                                            CurrencyIsoCode = 'USD',
                                                                            Content_Types_Allowed__c = 'App Link',
                                                                            Display_Name__c='Testing');
        insert IntranetContainer ;
        
        //List of main Intranet Item
        List<Intranet_Item__c> mainInterItems = new List<Intranet_Item__c>();
        mainInterItems.add(new Intranet_Item__c(Name= 'Test', CurrencyIsoCode = 'USD', RecordTypeId = settingCatogary.Id, Category_Name__c = 'A'));
        mainInterItems.add(new Intranet_Item__c(Name= 'Test', CurrencyIsoCode = 'USD', RecordTypeId = settingCatogary.Id, Category_Name__c = 'B'));
        mainInterItems.add(new Intranet_Item__c(Name= 'Test', CurrencyIsoCode = 'USD', RecordTypeId = settingCatogary.Id, Category_Name__c = 'C'));

        insert mainInterItems;
        
        //List of Intranet items  
        List<Intranet_Item__c> listIntranetItems = new List<Intranet_Item__c>();  
        listIntranetItems.add(new Intranet_Item__c(Name = 'DFG', Main_Category__c  = mainInterItems[0].Id, RecordTypeId = settingCatogary.Id,
                                                                   Category_Name__c ='A',
                                                                   CurrencyIsoCode = 'USD'));
                                                                   
        listIntranetItems.add(new Intranet_Item__c(Name = 'Test-1',Main_Category__c  = mainInterItems[0].Id ,
                                                                   RecordTypeId = settingCatogary.Id,
                                                                   Category_Name__c ='B',
                                                                   CurrencyIsoCode = 'USD'));
                                                                   
        listIntranetItems.add(new Intranet_Item__c(Name = 'Test-2',Main_Category__c  = mainInterItems[0].Id ,
                                                                   RecordTypeId = settingCatogary.Id,
                                                                   Category_Name__c ='C',
                                                                   CurrencyIsoCode = 'USD'));
                                                                   
        listIntranetItems.add(new Intranet_Item__c(Name = 'Test-4',Main_Category__c  = mainInterItems[1].Id ,
                                                                   RecordTypeId = settingCatogary.Id,
                                                                   Category_Name__c ='D',
                                                                   CurrencyIsoCode = 'USD'));
                                                                   
        listIntranetItems.add(new Intranet_Item__c(Name = 'Test-6',Main_Category__c  = mainInterItems[0].Id ,
                                                                   RecordTypeId = settingCatogary.Id,
                                                                   Category_Name__c ='E',
                                                                   CurrencyIsoCode = 'USD'));
                                                                   
        listIntranetItems.add(new Intranet_Item__c(Name = 'Test-7',Main_Category__c  = mainInterItems[1].Id ,
                                                                   RecordTypeId = settingCatogary.Id,
                                                                   Category_Name__c ='F',
                                                                   CurrencyIsoCode = 'USD'));
        
        //Insert Items
        insert listIntranetItems;
        
        //Assert for results
        //This will create topic for the Main Items #1 and #2
        List<Topic> listTopic  = [Select Id From Topic];
        System.assertEquals(listTopic.size(), 2);
        
        //6 Assignemnets will be get created
        List<TopicAssignment> tpcAssgs =  [Select Id, EntityId, TopicId FROM TopicAssignment];
        System.assertEquals(tpcAssgs.size(), 6);
        
        //Start testing from here
        Test.startTest();
        
        //Update Intranet Items and validate the topics
        listIntranetItems[0].Main_Category__c = mainInterItems[2].Id;
        listIntranetItems[1].Main_Category__c = null;
        update listIntranetItems;
        
        //Stop Testing here
        Test.stopTest();
      
      listTopic  = [Select Id From Topic];
        System.assertEquals(listTopic.size(), 3); 
        
        tpcAssgs =  [Select Id,EntityId,TopicId FROM TopicAssignment];
        System.assertEquals(tpcAssgs.size(), 5);
    }
    
    //This method is to test the Delete functionality where Default Content Flag  is true
    static testMethod void testDefaultContentItemDelete() {
      
        //Bypassing all triggers
        Util.isTest(true);
        Util.BypassAllTriggers = true;
        
      //RecordType
        List<RecordType> itemFeatureRecordType = [Select Id from RecordType where DeveloperName = 'Item_Feature' AND SObjectType = 'Intranet_Item__c' AND IsActive = true Limit 1];
        System.assertEquals(1, itemFeatureRecordType.size());
        
        //Create a defaould Intranet Item
        Intranet_Item__c defaultInranetItem = new Intranet_Item__c(RecordTypeId = itemFeatureRecordType[0].Id, 
                                                                     Active_Status__c = 'Active', Approval_Status__c = 'Approved',
                                                                    Item_type__c = 'System Status', Item_Title__c = 'All Systems Operating Normally',
                                                                    Default_Content_Flag__c = true);
        insert defaultInranetItem;
        
        //Start Testing from here
        Test.startTest();
        
        //Try to delete item, it should throw exception as Default_Content_Flag__c is true
        try {
          
            //Enabling trigger again
            Util.BypassAllTriggers = false;
        
            //delete
          delete defaultInranetItem;
          
        } catch(Exception e) {
          
          //Chechk the error message
          System.assert(e.getMessage().containsIgnoreCase(Label.ERROR_DELETE_DEFAULT_CONTENT_FLAG_TRUE));
        }
        
        //Now update the record and set Default_Content_Flag__c = false
        defaultInranetItem.Default_Content_Flag__c = false;
        update defaultInranetItem;
        
        //Try deleting record now
        delete defaultInranetItem;
        
        //Stop test
        Test.stopTest();
        
        //Query Intranet Item to make sure no record exists
        List<Intranet_Item__c> intranetItems = [Select Id from Intranet_Item__c where Id =: defaultInranetItem.Id];
        System.assertEquals(0, intranetItems.size());
    }
    
    //This method is to test the Populate PermaLink functionality
    static testMethod void testPopulatePermaLink() {
        
        //List of IntranetDefaultsRecords
        List<Intranet_Defaults__c> listIntranetDefaults = new List<Intranet_Defaults__c>();
        
        listIntranetDefaults.add(new Intranet_Defaults__c(Name = 'News Item',
                                                          Item_Type__c = 'News Item',
                                                          Permalink__c = 'view=news',
                                                          ContentViewerView__c = 'view=news',
                                                          SearchCategory__c = 'News'));
        listIntranetDefaults.add(new Intranet_Defaults__c(Name = 'Member Impact',
                                                          Item_Type__c = 'Member Impact',
                                                          Permalink__c = 'view=initiative',
                                                          ContentViewerView__c = 'view=initiative',
                                                          SearchCategory__c = 'Member Impact'));
        listIntranetDefaults.add(new Intranet_Defaults__c(Name = 'Training Event',
                                                          Item_Type__c = 'Training Event',
                                                          Permalink__c = IntranetItemTriggerHelper.KEYWORD_PERMALINK_LINK_URL,
                                                          ContentViewerView__c = IntranetItemTriggerHelper.KEYWORD_PERMALINK_LINK_URL,
                                                          SearchCategory__c = 'Training'));
        listIntranetDefaults.add(new Intranet_Defaults__c(Name = 'Member Event', 
                                                          Item_Type__c = 'Member Event',
                                                          Permalink__c = IntranetItemTriggerHelper.KEYWORD_PERMALINK_LINK_URL,
                                                          ContentViewerView__c = IntranetItemTriggerHelper.KEYWORD_PERMALINK_LINK_URL,
                                                          SearchCategory__c = 'Member Events'));
        listIntranetDefaults.add(new Intranet_Defaults__c(Name = 'Office Event',
                                                          Item_Type__c = 'Office Event',
                                                          Permalink__c = 'view=office+events&mode=calendar',
                                                          ContentViewerView__c = 'view=office+events&mode=calendar',
                                                          SearchCategory__c = 'Office Events'));
        insert listIntranetDefaults;  

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
      
      //Start Testing from here
      Test.startTest();
      
      //Insert records
      insert listIntranetItems;
      
      //Stop Test
      Test.stopTest();
      
      //Expected URLs
      String expectedNewsURL = '/apex/IntranetContentViewer?' + listIntranetDefaults[0].ContentViewerView__c + '&SearchContentId=' + listIntranetItems[0].id + '&SearchContentType=' + listIntranetItems[0].Item_Type__c;
      String expectedMemberImpactStoryURL = '/apex/IntranetContentViewer?' + listIntranetDefaults[1].ContentViewerView__c + '&SearchContentId=' + listIntranetItems[1].id + '&SearchContentType=' + listIntranetItems[1].Item_Type__c;
      String expectedTrainingResultURL = IntranetHomeUtility.HTTP + listIntranetItems[2].Link_URL__c;
        
      //Assert for the results
      listIntranetItems = [Select Link_URL__c, Permalink__c from Intranet_Item__c where Id IN: listIntranetItems];
        
        //Assert for Result
        System.assertEquals(expectedNewsURL, listIntranetItems[0].Permalink__c);
        System.assertEquals(expectedMemberImpactStoryURL, listIntranetItems[1].Permalink__c);
        System.assertEquals(expectedTrainingResultURL, listIntranetItems[2].Permalink__c);
        
    }
    
    //This method is to test the Create IntanetSchedules By IntranetItems functionality
    static testMethod void testCreateIntanetSchedulesByIntranetItems() {
      
      //Query through schedule record type
      List<RecordType> rdTypes = [Select Id, DeveloperName From RecordType WHERE DeveloperName = 'Static' AND IsActive = true AND sObjectType = 'Intranet_Schedule__c' LIMIT 1]; 
      List<RecordType> intranetItemRT = [Select Id, DeveloperName From RecordType WHERE DeveloperName = 'Item_Event' AND IsActive = true AND sObjectType = 'Intranet_Item__c' LIMIT 1]; 
      system.assertEquals(1, rdTypes.size());
    
        //Load User Session
        IntranetType.UserSession userSession = IntranetHomeUtility.getUserSession;
        
      //Intranet Container 
        Intranet_Container__c intranetContainer = new Intranet_Container__c(Name= 'Test-2',
                                                             CurrencyIsoCode = 'USD',
                                                             Content_Types_Allowed__c = 'Event Item;Training Event;Member Event;National Meeting');
        insert intranetContainer;       
      
        //List of Intranet defaults
      List<Intranet_Defaults__c> listIntranetDefaults = new List<Intranet_Defaults__c>();
      listIntranetDefaults.add(new Intranet_Defaults__c(Name = 'Training Event',
                                ContentTypes__c = 'ABC Training',
                                Active_Status__c = 'Active',
                                  Approval_Status__c = 'Approved',
                                                          Item_RecordTypeId__c = intranetItemRT[0].Id,
                                  Schedule_RecordTypeId__c = rdTypes[0].Id,
                                                          Permalink__c = 'ContentViewer',
                                                          SearchCategory__c = 'Training',
                                                          SettingType__c = 'ItemType',
                                                          SearchResultOrder__c = 8,
                                  Intranet_Container__c = intranetContainer.Id));
      listIntranetDefaults.add(new Intranet_Defaults__c(Name = 'ABC Training',
                                Event_Type__c = 'ABC Training',
                                                          Item_Type__c = 'Training Event',
                                                          Link_Type__c = 'Standard',
                                                          LinkBaseURL__c = 'http://abctraining.advisory.com/default.aspx?CourseId=',
                                Link_Action__c = 'Open In New Tab/Window',
                                                          Active_Status__c = 'Active',
                                                          Category__c = 'Training',
                                                          ContentTypes__c = 'Training Event',
                                                          Create_Source__c = 'TRS',
                                                          Item_RecordTypeId__c = intranetItemRT[0].Id,
                                  Schedule_RecordTypeId__c = rdTypes[0].Id,
                                                          Permalink__c = 'Link_URL__c',
                                                          SearchCategory__c = 'Training',
                                                          SettingType__c = 'ContentType',
                                                          SearchResultOrder__c = 7,
                                  Intranet_Container__c = intranetContainer.Id));
        
        listIntranetDefaults.add(new Intranet_Defaults__c(Name = 'Member Event',
                                ContentTypes__c = 'National Meeting',
                                Active_Status__c = 'Active',
                                  Approval_Status__c = 'Approved',
                                                          Item_RecordTypeId__c = intranetItemRT[0].Id,
                                  Schedule_RecordTypeId__c = rdTypes[0].Id,
                                                          Permalink__c = 'ContentViewer',
                                                          SearchCategory__c = 'Member Events',
                                                          SettingType__c = 'ItemType',
                                                          SearchResultOrder__c = 14));
      listIntranetDefaults.add(new Intranet_Defaults__c(Name = 'National Meeting',
                                Event_Type__c = 'National Meeting',
                                                          Item_Type__c = 'Member Event',
                                                          Link_Type__c = 'Standard',
                                                          LinkBaseURL__c = 'http://abctraining.advisory.com/default.aspx?CourseId=',
                                Link_Action__c = 'Open In New Tab/Window',
                                                          Active_Status__c = 'Active',
                                                          Category__c = 'Training',
                                                          Create_Source__c = 'MRS',
                                                          Item_RecordTypeId__c = intranetItemRT[0].Id,
                                  Schedule_RecordTypeId__c = rdTypes[0].Id,
                                                          Permalink__c = 'Link_URL__c',
                                                          SearchCategory__c = 'Training',
                                                          SettingType__c = 'ContentType',
                                                          SearchResultOrder__c = 7,
                                  Intranet_Container__c = intranetContainer.Id));
      insert listIntranetDefaults;
      
      //List of intranet items
        List<Intranet_Item__c> intranetItems = new List<Intranet_Item__c>();
        intranetItems.add(new Intranet_Item__c(Name= 'Test', 
                                               CurrencyIsoCode = 'USD',
                                               Item_Type__c = 'Training Event',
                                               Event_Start_Date_Time__c = dateTime.NOW().addDays(-5),
                                               Event_End_Date_Time__c = dateTime.NOW().addDays(5),
                                               Item_Title__c = 'RCS Academy: Working with C-Suite Executives',
                                               Room_Name__c = 'Virtual Only',
                                               Unique_Id__c = 'B5417ACA-F4BA-4AFD-B3ED-FCF098B60000',
                                               Create_Source__c = 'TRS'));
        intranetItems.add(new Intranet_Item__c(Name= 'Test', 
                                               CurrencyIsoCode = 'USD',
                                               Item_Type__c = 'Member Event',
                                               Event_Start_Date_Time__c = dateTime.NOW().addDays(-2),
                                               Event_End_Date_Time__c = dateTime.NOW().addDays(5),
                                               Item_Title__c = '2014 Academic Affairs Forum National Meeting',
                                               Unique_Id__c = 'B5417ACA-F4BA-4AFD-B3ED-000',
                                               Create_Source__c = 'MRS'));
        
      //Test start here
      Test.startTest();
      
      insert intranetItems;
      
      //Test stops here
      Test.stopTest();   
      
        //Query through Intranet schedule
        List<Intranet_Schedule__c> listIntranetSchedule = [Select Id, Name, Active_Status__c, Approval_Status__c, RecordTypeId, Intranet_Container__c,
                                                          Intranet_Item__c From Intranet_Schedule__c];
      //Assert for results
      System.assertEquals(2, listIntranetSchedule.size());
      System.assertEquals(listIntranetDefaults[0].Active_Status__c, listIntranetSchedule[0].Active_Status__c);
      //System.assertEquals(listIntranetDefaults[0].Approval_Status__c, listIntranetSchedule[0].Approval_Status__c);
      System.assertEquals(intranetContainer.Id, listIntranetSchedule[0].Intranet_Container__c);
      System.assertEquals(intranetItems[0].Id, listIntranetSchedule[0].Intranet_Item__c);
        System.assertEquals(rdTypes[0].Id, listIntranetSchedule[0].RecordTypeId);
        
    //Create the intranet content
        Map<string, Intranet_Utilization__c> mapLikedItems = new Map<string, Intranet_Utilization__c>();
        IntranetContainer iContainer = new IntranetContainer(intranetContainer);
        IntranetContent iContent = new IntranetContent(iContainer, intranetItems[1], userSession, mapLikedItems);
        
        //assertions
        system.assertEquals(dateTime.now().date(), iContent.EventStartDateTime.date(),
                           'EventStartDateTime should equal today for Member Event items that span multiple days and today is within the date range.' );
    }
    
    //This method is to Update MRS And TRS IntranetItems
    static testMethod void testUpdatedMRSAndTRSIntranetItems() {
      
      //Query through schedule record type
      List<RecordType> rdTypes = [Select Id, DeveloperName From RecordType WHERE isActive = true AND sObjectType = 'Intranet_Item__c' LIMIT 1]; 
      System.assertEquals(rdTypes.size() , 1);
            
       //List of Intranet defaults
      List<Intranet_Defaults__c> listIntranetDefaults = new List<Intranet_Defaults__c>();
      listIntranetDefaults.add(new Intranet_Defaults__c(Name = 'Testing0',
                                  Event_Type__c = 'Event Item',
                                  ContentTypes__c = 'This is Event Item testing',
                                  Active_Status__c = 'Active',
                                  Approval_Status__c = 'Approved',
                                  Item_RecordTypeId__c = rdTypes[0].Id, 
                                  Create_Source__c = IntranetItemTriggerHelper.CREATE_SOURCE_MRS,
                                  LinkBaseURL__c = 'www.test.com',
                                  Item_Type__c = 'TestItem',
                                  Link_Type__c = 'App',
                                  Link_Action__c = 'New Window'));
                                  
      listIntranetDefaults.add(new Intranet_Defaults__c(Name = 'Testing1',
                                Event_Type__c = 'Event Item',
                                ContentTypes__c = ' Event Item testing',
                                Active_Status__c = 'Inactive',
                                  Approval_Status__c = 'Reject',
                                  Item_RecordTypeId__c = rdTypes[0].Id,
                                  Create_Source__c = IntranetItemTriggerHelper.CREATE_SOURCE_TRS,
                                  LinkBaseURL__c = 'www.test.com',
                                  Item_Type__c = 'TestItem',
                                  Link_Type__c = 'Quick',
                                  Link_Action__c = 'Same Window'));
      
      insert   listIntranetDefaults;  
      
      //List of intranet items
        List<Intranet_Item__c> intranetItems = new List<Intranet_Item__c>();
        intranetItems.add(new Intranet_Item__c(Name= 'Test', CurrencyIsoCode = 'USD',
                                   Category_Name__c = 'A',
                                     Item_Type__c = 'Testing0',
                                     Event_Type__c = 'Testing0',
                                     Create_Source__c = IntranetItemTriggerHelper.CREATE_SOURCE_MRS));
                                     
        intranetItems.add(new Intranet_Item__c(Name= 'Test', CurrencyIsoCode = 'USD',
                                   Category_Name__c = 'A',
                                     Item_Type__c = 'Testing1',
                                     Event_Type__c = 'Testing1',
                                     Create_Source__c = IntranetItemTriggerHelper.CREATE_SOURCE_TRS));
                                     
        intranetItems.add(new Intranet_Item__c(Name= 'Test', CurrencyIsoCode = 'USD',
                                   Category_Name__c = 'A',
                                     Item_Type__c = 'Testing2',
                                     Event_Type__c = 'Testing2'));
      
      //Test start here
      Test.startTest();
      
      insert intranetItems;
      
      //Test stops here
      Test.stopTest();
    
        //Query thyrough intarntt items
      intranetItems = [Select Id, Link_URL__c, Active_Status__c, Approval_Status__c, RecordTypeId, Event_Type__c, 
                        Item_Type__c, Link_Type__c, Link_Action__c From Intranet_Item__c WHERE
                                                Id IN: intranetItems];
      //Assert for results                                          
      System.assertEquals(intranetItems[0].Active_Status__c , listIntranetDefaults[0].Active_Status__c);
      System.assertEquals(intranetItems[1].Active_Status__c , listIntranetDefaults[1].Active_Status__c);                                          
      System.assertEquals(intranetItems[0].Approval_Status__c , listIntranetDefaults[0].Approval_Status__c);
      System.assertEquals(intranetItems[1].Approval_Status__c , listIntranetDefaults[1].Approval_Status__c);
      System.assertEquals(intranetItems[0].Link_Type__c , listIntranetDefaults[0].Link_Type__c);
      System.assertEquals(intranetItems[1].Link_Type__c , listIntranetDefaults[1].Link_Type__c);
      System.assertEquals(intranetItems[0].Link_Action__c , listIntranetDefaults[0].Link_Action__c);
      System.assertEquals(intranetItems[1].Link_Action__c , listIntranetDefaults[1].Link_Action__c);
      System.assertEquals(intranetItems[0].RecordTypeId , listIntranetDefaults[0].Item_RecordTypeId__c);
      System.assertEquals(intranetItems[1].RecordTypeId , listIntranetDefaults[1].Item_RecordTypeId__c);
    }
    
    //This method is to test to make Image Url from YouTube Video and Vimeo video
    static testMethod void testgetYouTubeVideoImageUrl() {
       
        List<Intranet_Item__c> intranetItems = new List<Intranet_Item__c>();
        
        List<RecordType> listVideoItemRecordType = [Select Id, DeveloperName From RecordType where DeveloperName = 'Item_Video' AND sObjectType='Intranet_Item__c' AND isActive=true];
        system.assertEquals(1, listVideoItemRecordType.size());
        
        Intranet_Item__c youtubeVideoItem = new Intranet_Item__c();
    youtubeVideoItem.Name = 'What are Bundled Payments? - Video Item';
        youtubeVideoItem.Item_Type__c = 'Video Item';
        youtubeVideoItem.Approval_Status__c = 'Approved';
        youtubeVideoItem.Item_Title__c = 'What are Bundled Payments?';
        youtubeVideoItem.RecordTypeId = listVideoItemRecordType[0].Id;
        youtubeVideoItem.Link_URL__c = 'https://www.youtube.com/embed/ZpCjZEikUGs';
        youtubeVideoItem.Video_Link_Image_Url__c = null;
        intranetItems.add(youtubeVideoItem);
        
        Intranet_Item__c vimeoVideoItem = new Intranet_Item__c();
    vimeoVideoItem.Name = 'CABEZONES - 5 MIN - Video Item';
        vimeoVideoItem.Item_Type__c = 'Video Item';
        vimeoVideoItem.Approval_Status__c = 'Approved';
        vimeoVideoItem.Item_Title__c = 'CABEZONES - 5 MIN';
        vimeoVideoItem.RecordTypeId = listVideoItemRecordType[0].Id;
        vimeoVideoItem.Link_URL__c = 'https://player.vimeo.com/video/123456789';
        vimeoVideoItem.Video_Link_Image_Url__c = null;
        intranetItems.add(vimeoVideoItem);
        
        //Query through Intranet Vimeo Item Custom Setting to get the youtube image format
        List<Intranet_Video_Item_Links__c> cS_youtubeImageFormat = [SELECT Id, Name, Value__c, Is_Enabled__c FROM Intranet_Video_Item_Links__c WHERE Is_Enabled__c = true AND Name Like 'YouTube_%'];
        
        //set mock response
        Test.setMock(HttpCalloutMock.class, new VimeoMockCallOut());
       
        //Start Test from here
        Test.startTest();
        
        //Insert Intranet Items
        insert intranetItems;
        
        //Stop Test
        Test.stopTest();
        
        //Get YouTube Url
        String url = intranetItems[0].Link_URL__c;
        String youTubeId = url.substring(url.lastIndexOf('/')+1,url.length());
        
        //Query to Get updated Intranet Item
        List<Intranet_Item__c> itemList = [select Id, Name, Item_Type__c, Approval_Status__c, Video_Link_Image_Url__c, Link_URL__c from Intranet_Item__c where Id = :vimeoVideoItem.Id];
        
        //Query to Get updated Intranet Item
        List<Intranet_Item__c> itemList1 = [select Id, Name, Item_Type__c, Approval_Status__c, Video_Link_Image_Url__c, Link_URL__c from Intranet_Item__c where Id = :youtubeVideoItem.Id];
        
        //Assert for results                                          
      System.assertEquals( IntranetItemTriggerHelper.youTubeimageURL + youTubeId + cS_youtubeImageFormat[0].Value__c, itemList1[0].Video_Link_Image_Url__c);
      System.assertEquals( 'https://i.vimeocdn.com/video/512806123_1280.webp', itemList[0].Video_Link_Image_Url__c);                                          
      
    }
    
    //Method to Get Record Types of All Type
    static Map<String, RecordType> getMapRecordTypesWithName(){
        
        Map<String, RecordType> mapRecordTypesWithName = new Map<String, RecordType>();
        for(RecordType rType : [Select Id, DeveloperName From RecordType where sObjectType='Intranet_Item__c' AND isActive=true]) {
            
            //Put in map
            mapRecordTypesWithName.put(rType.DeveloperName, rType);
        }
        return mapRecordTypesWithName;
    }
    /** Method to Validate Various Link Url **/
    static testMethod void testValidateAndFormatLinkUtl(){
        
        Map<String, RecordType> mapRecordTypesWithName = getMapRecordTypesWithName();
        
        //Insert Item Invalid Link Url
        //============= Note Here we Are inserting All Item type of Video for making consistancy and to test only foramting of the links ==============
        List<Intranet_Item__c> itemList = new List<Intranet_Item__c>();
        
        //==== Link Url Start with '/'============
        Intranet_Item__c videoItem = new Intranet_Item__c();
    videoItem.Name = 'What are Bundled Payments? - Video Item';
        videoItem.Item_Type__c = 'Video Item';
        videoItem.Link_URL__c = '/blah/Test.com';
        videoItem.Approval_Status__c = 'Approved';
        videoItem.Item_Title__c = 'What are Bundled Payments?';
        videoItem.Content_URL__c = '/blah/Test.com';
        videoItem.Secondary_Link_1_Location__c = '/blah/Test.com';
        videoItem.Permalink__c = '/apex/IntranetContentViewer?SearchContentType=Page Section';
        videoItem.RecordTypeId = mapRecordTypesWithName.get('Item_Video').Id;
        itemList.add(videoItem);
        
        //========= Link url Not Starts with Http or HTTPs
        Intranet_Item__c videoItem1 = new Intranet_Item__c();
    videoItem1.Name = 'What are Bundled Payments? - Video Item';
        videoItem1.Item_Type__c = 'Video Item';
        videoItem1.Link_URL__c = 'file//:test.com';
        videoItem.Content_URL__c = 'file//:test.com';
        videoItem.Permalink__c = 'file//:apex/IntranetContentViewer?SearchContentType=Page Section';
        videoItem.Secondary_Link_1_Location__c = 'file//:blah/Test.com';
        videoItem1.Approval_Status__c = 'Approved';
        videoItem1.Item_Title__c = 'What are Bundled Payments?';
        videoItem1.RecordTypeId = mapRecordTypesWithName.get('Item_Video').Id;
        itemList.add(videoItem1);
        
        //Start Test
        Test.startTest();
        
        //Insert Item List
        insert itemList;
            
        Test.stopTest();
        itemList = [select Id, Link_URL_Validated__c, Content_URL_Validated__c, Permalink_Validated__c, Secondary_Link_1_Location_Validated__c from Intranet_item__c where Id IN:itemList];
        
        //Asserts for Results
        System.assertEquals('/blah/Test.com', itemList[0].Link_URL_Validated__c);
        System.assertEquals('http://:test.com', itemList[0].Content_URL_Validated__c);
        System.assertEquals('http://:apex/IntranetContentViewer?SearchContentType=Page Section', itemList[0].Permalink_Validated__c);
        System.assertEquals('http://:blah/Test.com',itemList[0].Secondary_Link_1_Location_Validated__c);
        System.assertEquals('http://:test.com', itemList[1].Link_URL_Validated__c); 
    }
}