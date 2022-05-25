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
/** Description     :   Test class for IntranetChatterHelperController
  * 
  * Created Date    :   09/15/2014
  *
  * Created By      :   
  *  
  * Current vision  :   v1.0
  *  
  * Revision Logs   :   v1.0 - Created
  *                 :   V2.0 - Modifled By - Rajeev Jain(09/15/2015) - CR-20141002-7579
  *                 :   V3.0   Modified By - Rajeev Jain - 18/02/2020 - CR-20190929-13382 -  Remove zzzHas Subcontainers(Has_SubContainers__c) field on Intranet_Container__c object
  *                 :                                                                         Remove zzzScreen Priority(Screen_Priority__c) field of Intranet_Container__c object.
  * Coverage        :   100%
  **/  
@isTest
private class Test_IntranetContainer {

    static Map<String, RecordType> getMapRecordTypesWithName(){
        
        Map<String, RecordType> mapRecordTypesWithName = new Map<String, RecordType>();
        for(RecordType rType : [Select Id, DeveloperName From RecordType where (sObjectType='Intranet_Schedule__c' OR sObjectType='Intranet_Container__c' OR sObjectType='Intranet_Item__c') AND isActive=true]) {
            
            //Put in map
            mapRecordTypesWithName.put(rType.DeveloperName, rType);
        }
        return mapRecordTypesWithName;
    }
    
    //This method is to test the properties being set in constructor
    static testMethod void testConstructorProperties() {
        //Map to hold record type corrosponding to their developer name
        Map<String, RecordType> mapRecordTypesWithName = getMapRecordTypesWithName();
        
        //Create Test data
        Intranet_Container__c intranetContainer = new Intranet_Container__c(Container_Type__c = 'Menu',
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
     
        //Add SubContainer  SubCOntainer
     
        //Start Test from Here
        Test.startTest();
        
        //Initialize Controller
        IntranetContainer controller = new IntranetContainer(intranetContainer);
        
        Boolean checkHasSubContainer = controller.getHasSubContainers();
        
        
        //Create another Intranet Container of  type of tab to make flag true for subcontainer
        Intranet_Container__c tabContainer = new Intranet_Container__c(Container_Type__c = 'ABC Today',
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
        IntranetContainer controller1 = new IntranetContainer(tabContainer);
        
        //Add Sub Containers to increase coverage only
        //controller1.SubContainers.add(controller1);
        Intranet_Container__c trainingEventSubContainer = new Intranet_Container__c();
        trainingEventSubContainer.Name = 'Content - SubContainer-ABC Today-Training';
        trainingEventSubContainer.Status__c = 'Active';
        trainingEventSubContainer.Container_Type__c = 'SubContainer';
        trainingEventSubContainer.Sort_Order__c = 1;
        trainingEventSubContainer.Content_Types_Allowed__c = 'Training Event';
        trainingEventSubContainer.Display_Name__c = 'Training';
        trainingEventSubContainer.RecordTypeId = mapRecordTypesWithName.get('Content_SubContainer').Id;
        insert trainingEventSubContainer;
        
        //Conver in Container Wrapper
        IntranetContainer trainingContainerClass = new IntranetContainer(trainingEventSubContainer);
        
        //================ Add Sub Containers to Container ================ 
        controller1.SubContainers.add(trainingContainerClass);
        
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
        insert trainingEvent;
        
        Intranet_Schedule__c trainingSchedule = new Intranet_Schedule__c();
        trainingSchedule.Name = 'Events - Chef for a day at Ronald McDonald House';
        trainingSchedule.Active_Status__c = 'Active';
        trainingSchedule.Intranet_Container__c = trainingEventSubContainer.Id;
        trainingSchedule.Intranet_Item__c = trainingEvent.id;
        trainingSchedule.RecordTypeId = mapRecordTypesWithName.get('Static').Id;
        insert trainingSchedule;
        
        //Get User Session
        //Call PopulateUserSession method
        IntranetType.UserSession UserSession = IntranetHomeUtility.getUserSession;
        
        //Create IntranetContent Wrapper Instance and Add it to related Content list of Container Wrapper
        IntranetContent trainingContentItem = new IntranetContent(trainingContainerClass, trainingSchedule, trainingEvent, UserSession, new Map<String, Intranet_Utilization__c>());
        
        //Add related Content to Parent Container
        controller1.RelatedContent.add(trainingContentItem);
        
        //Covert Container to String and print in debug
        String str = controller1.ToString('@@@@@ XXX');
        
        Boolean checkHasSubContainer1 = controller1.getHasSubContainers();
        
        ///Call blank Construcotr
        IntranetContainer controller2 = new IntranetContainer();
        
        //Create Another Container Type of Flexible also blank max content item
        Intranet_Container__c flexiblaContainer = new Intranet_Container__c(Container_Type__c = 'Flexible', 
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
        IntranetContainer controller3 = new IntranetContainer(flexiblaContainer);
        
        //Call another two properties to increase coverage only
        String containerClass = controller3.ContainerClass;
        String dpaScoreTYpe = controller3.DPAScoreType;
        
        //Stop Test here
        Test.stopTest();
        
        //Assert for the results
        System.assertEquals(intranetContainer.Height__c, controller.Height);
    }
    
    //This method is to test the Sorting Behaviour
    static testMethod void testIntranetContainerSortedList() {
        
        //Create Test data
        List<Intranet_Container__c> listIntranetContainer = new List<Intranet_Container__c>();
        
        //Add records in list
        listIntranetContainer.add(new Intranet_Container__c(Container_Type__c = 'Menu',
                                                            Max_Content_Items__c = 100, 
                                                            Status__c = 'Active',
                                                            Content_Types_Allowed__c = 'News Item',
                                                            Display_Name__c = 'Primary',
                                                            Minimum_Visible_Screen__c = 'Desktop (1200 pixels)',
                                                            Position__c = '1',
                                                            Show_Expand_Link__c = true,
                                                            Show_Feedback_Link__c = true, 
                                                            Sort_Order__c = 3,
                                                            Height__c = 100,
                                                            Width__c = 100));
        listIntranetContainer.add(new Intranet_Container__c(Container_Type__c = 'Menu',
                                                            Max_Content_Items__c = 100, 
                                                            Status__c = 'Active',
                                                            Content_Types_Allowed__c = 'News Item',
                                                            Display_Name__c = 'Primary',
                                                            Minimum_Visible_Screen__c = 'Desktop (1200 pixels)',
                                                            Position__c = '1',
                                                            Show_Expand_Link__c = true,
                                                            Show_Feedback_Link__c = true, 
                                                            Sort_Order__c = 4,
                                                            Height__c = 100,
                                                            Width__c = 100));
        listIntranetContainer.add(new Intranet_Container__c(Container_Type__c = 'Menu',
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
                                                            Width__c = 100));
        listIntranetContainer.add(new Intranet_Container__c(Container_Type__c = 'Menu', 
                                                            Max_Content_Items__c = 100, 
                                                            Status__c = 'Active',
                                                            Content_Types_Allowed__c = 'News Item',
                                                            Display_Name__c = 'Primary',
                                                            Minimum_Visible_Screen__c = 'Desktop (1200 pixels)',
                                                            Position__c = '1',
                                                            Show_Expand_Link__c = true,
                                                            Show_Feedback_Link__c = true, 
                                                            Sort_Order__c = 2,
                                                            Height__c = 100,
                                                            Width__c = 100));
        insert listIntranetContainer;
        
        //Start Test from Here
        Test.startTest();
        
        //Call Sort Method
        List<IntranetContainer> containers = new List<IntranetContainer>();
        for(Intranet_Container__c intranetContainer : listIntranetContainer)
            containers.add(new IntranetContainer(intranetContainer)); 
        
        //Call Sort methods
        containers.sort();
        
        //Stop Test here
        Test.stopTest();
        
        //Assert for the results
        for(Integer i = 1; i <= containers.size(); i++ )
            System.assertEquals(i, Integer.valueOf(containers[i-1].SortOrder));
    }
}