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
 *  Purpose         :   Test class for BoardroomInternalHomePageController
 * 
 *  Created By      :   Bhavi Sharma
 * 
 *  Created Date    :   09/24/2014
 * 
 *  Revision Logs   :   Created
 * 					:	V1.0 - Modified By - Rajeev Jain - CR-7579	- 09/03/2015 - Increase code coverage and code indentation, improve asserts
 * 
 *  Coverage        :   96%
 **/    
     
@isTest(seeAllData = false)
private class Test_IntranetInternalPageController {

    //Method to test IntranetInternalPageController Functionality
    static testMethod void myUnitTest() {
        
        //Test intranet Item record
        
        Intranet_Item__c intranetItem = new Intranet_Item__c(Name = 'Test-0', Active_Status__c = 'Active', Item_Type__c='Ad Item',Sort_Order__c = 1);
        insert intranetItem;
        
        //Test intranet Item record
        Intranet_Item__c intranetItem1 = new Intranet_Item__c(Name = 'Test-0', Active_Status__c = 'Active', Item_Type__c='Ad Item');
        insert intranetItem1;
        
        
        //Intranet container (parent) - This is the main Container and page will be displaying this one on Preview
        Intranet_Container__c intranetContainerParent = new Intranet_Container__c(Name= 'Parent-Contaiiner',
                                                                                  CurrencyIsoCode = 'USD',
                                                                                  Content_Types_Allowed__c = 'Ad Item',
                                                                                  Display_Name__c='Testing',
                                                                                  Container_Type__c = 'Flexible',
                                                                                  Max_Content_Items__c = 1);
        
        insert intranetContainerParent ;
        
        //List of Child Containetr
        //All these records have different Container Type.
        List<Intranet_Container__c> listChildContainers = new List<Intranet_Container__c>();
        
        listChildContainers.add(new Intranet_Container__c(Name= 'Parent-Container',
                                                          CurrencyIsoCode = 'USD',
                                                          Content_Types_Allowed__c = 'Ad Item',
                                                          Display_Name__c='Testing',
                                                          Container_Type__c = 'QuickLinks',
                                                          Parent_Container__c = intranetContainerParent.Id,
                                                          Default_Content_Item__c = intranetItem.Id,
                                                          Max_Content_Items__c = 1));
        listChildContainers.add(new Intranet_Container__c(Name= 'Parent-Container',
                                                          CurrencyIsoCode = 'USD',
                                                          Content_Types_Allowed__c = 'Ad Item',
                                                          Display_Name__c='Testing',
                                                          Container_Type__c = 'Page Actions',
                                                          Parent_Container__c = intranetContainerParent.Id,
                                                          Max_Content_Items__c = 1));
        listChildContainers.add(new Intranet_Container__c(Name= 'Parent-Container',
                                                          CurrencyIsoCode = 'USD',
                                                          Content_Types_Allowed__c = 'Ad Item',
                                                          Display_Name__c='Testing',
                                                          Container_Type__c = 'Page Bookmarks',
                                                          Parent_Container__c = intranetContainerParent.Id,
                                                          Max_Content_Items__c = 1));
        
        insert listChildContainers;       
        
        //Assert
        System.assertEquals(3, listChildContainers.size());                                                          
        
        //Intranet scheedule record for testing
        //List Intranet schedule
        List<Intranet_Schedule__c> listIntranetSchedule = new List<Intranet_Schedule__c>();
        listIntranetSchedule.add(new Intranet_Schedule__c(Name = 'Test' , Intranet_Container__c = intranetContainerParent.Id ,
                                                          Intranet_Item__c = intranetItem.Id,
                                                          End_Date_Time__c = Date.Today().addDays(9),
                                                          Start_Date_Time__c = Date.Today()));
        
        listIntranetSchedule.add(new Intranet_Schedule__c(Name = 'Test' , Intranet_Container__c = intranetContainerParent.Id ,
                                                          Intranet_Item__c = intranetItem1.Id,
                                                          End_Date_Time__c = Date.Today().addDays(9),
                                                          Start_Date_Time__c = Date.Today()));                                                                 
        
        
        insert  listIntranetSchedule;
        
        //Asseert 
        System.assertEquals(2, listIntranetSchedule.size());
        
        
        //List of Intranet Utilization
        List<Intranet_Utilization__c> listIntranetUtilization = new List<Intranet_Utilization__c>();
        listIntranetUtilization.add(new Intranet_Utilization__c(Name = 'Test', 
                                                                Intranet_Container__c = intranetContainerParent.Id,
                                                                Intranet_Item__c = intranetItem.Id,
                                                                Intranet_Schedule__c = listIntranetSchedule[0].Id,
                                                                User__c = UserInfo.getUserId(),
                                                                Click_Type__c = IntranetUtilizationHelper.CLICK_TYPE_LIKE));
        
        listIntranetUtilization.add(new Intranet_Utilization__c(Name = 'Test1',
                                                                Intranet_Container__c = intranetContainerParent.Id,
                                                                Intranet_Item__c = intranetItem1.Id,
                                                                Intranet_Schedule__c = listIntranetSchedule[1].Id,
                                                                User__c = UserInfo.getUserId(),
                                                                Click_Type__c = IntranetUtilizationHelper.CLICK_TYPE_LIKE));    
        
        
        
        insert  listIntranetUtilization;                    
        
        //Asseert 
        System.assertEquals(2, listIntranetUtilization.size());
        
        //Custom Setting  data
        Intranet_Defaults__c intranrtDefault = new  Intranet_Defaults__c(Name = 'Ad Item', Max_Content_Items__c = 12);  
        insert intranrtDefault;                                                                         
        
        //Set URL Parameters
        ApexPages.currentPage().getParameters().put('Preview', 'True');
        ApexPages.currentPage().getParameters().put('SchedId', listIntranetSchedule[0].Id);
        ApexPages.currentPage().getParameters().put('TopContainerId', intranetContainerParent.Id);
        
        //Constructer Initilizatiion
        IntranetInternalPageController controller = new IntranetInternalPageController();
        
        //Calling controller methods
        controller.getDataString();
        
        //Assert for results
        system.assertEquals(controller.container.MaxContentItems , 12);
        system.assertEquals(controller.container.RelatedContent.size(), 1);
        system.assertEquals(controller.container.ContainerClass, label.Intranet_ContainerClass_Ad);
        
    }
}