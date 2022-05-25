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
/** Description     :   Test class for IntranetContainerTrigger.
  * 
  * Created Date    :   08/05/2014
  *
  * Created By      :   
  *  
  * Current vision  :    v1.0
  *  
  * Revision Logs   :    v1.0 - Created
  * 				:	 V2.0 - Modified By - Rajeev Jain - CR-7579 - 09/03/2015 - Increase code coverage
  *
  * Coverage        :   100%
  **/  
@isTest(seeAllData= false)
private class Test_IntranetContainerTrigger {
    
    /**
      * @Description    :   Method to check functionality of  validateDate
      *
      * @args           :   
      *
      * @return         :   void
      *
    **/
    static testMethod void testValidateData() {
    
        List<RecordType> rtypes = [Select Name, Id From RecordType where sObjectType='Intranet_Container__c' AND isActive=true limit 1];
        
        //List of Intranet items
        List<Intranet_Item__c> listIntranetItems = new List<Intranet_Item__c>();
        listIntranetItems.add(new Intranet_Item__c(Name = 'Test-0',Active_Status__c = 'Active',Item_Type__c='App Link'));
        listIntranetItems.add(new Intranet_Item__c(Name = 'Test-1',Active_Status__c = 'Active',Item_Type__c='App Link'));
        listIntranetItems.add(new Intranet_Item__c(Name = 'Test-2',Active_Status__c = 'Active',Item_Type__c='App Link'));
        listIntranetItems.add(new Intranet_Item__c(Name = 'Test-3',Active_Status__c = 'Active',Item_Type__c='App Link'));
        listIntranetItems.add(new Intranet_Item__c(Name = 'Test-4',Active_Status__c = 'Active',Item_Type__c='App Link'));

        //Insert Intranet items
        insert listIntranetItems ;
        
        //Intranet container (parent)
        Intranet_Container__c IntranetContainer = new Intranet_Container__c(Name= 'Parent-Contaiiner',
                                                                            CurrencyIsoCode = 'USD',
                                                                            Content_Types_Allowed__c = 'App Link',
                                                                            Display_Name__c='Testing');
        
        insert IntranetContainer ;
        
        //List of Intranet Container 
        List<Intranet_Container__c> listIntranetContainers = new List<Intranet_Container__c>();
        listIntranetContainers.add(new Intranet_Container__c(Name = 'Test-1',
                                                             Default_Content_Item__c =  listIntranetItems[0].Id,
                                                             CurrencyIsoCode = 'USD',
                                                             Content_Types_Allowed__c = 'App Link',
                                                             Display_Name__c='Testing',
                                                             RecordTypeId= rtypes[0].Id));
                                                             
        listIntranetContainers.add(new Intranet_Container__c(Name= 'Test-2',
                                                             Default_Content_Item__c =  listIntranetItems[1].Id,
                                                             Parent_Container__c = IntranetContainer.Id,
                                                             CurrencyIsoCode = 'USD',
                                                             Content_Types_Allowed__c = 'App Link',
                                                             RecordTypeId= rtypes[0].Id));
                                                             
        listIntranetContainers.add(new Intranet_Container__c(Name= 'Test-3',
                                                             Default_Content_Item__c =  listIntranetItems[2].Id,
                                                             Parent_Container__c = IntranetContainer.Id,
                                                             CurrencyIsoCode = 'USD',
                                                             Content_Types_Allowed__c = 'App Link',
                                                             RecordTypeId= rtypes[0].Id));
                                                             
        listIntranetContainers.add(new Intranet_Container__c(Name= 'Test-4',
                                                             Default_Content_Item__c =  listIntranetItems[3].Id,
                                                             Parent_Container__c = IntranetContainer.Id,
                                                             CurrencyIsoCode = 'USD',
                                                             Content_Types_Allowed__c = 'App Link',
                                                             RecordTypeId= rtypes[0].Id));
                                                             
        listIntranetContainers.add(new Intranet_Container__c(Name= 'Test-5',
                                                             Default_Content_Item__c =  listIntranetItems[4].Id,
                                                             CurrencyIsoCode = 'USD',
                                                             Content_Types_Allowed__c = 'App Link',
                                                             Display_Name__c= 'Testing',
                                                             RecordTypeId= rtypes[0].Id));
        
        //Test starts here
        Test.startTest();
        
        //Insert Intranet container 
        insert listIntranetContainers ;
        
        //Assert fopr the results
        listIntranetItems = [SELECT Id ,Name,Default_Content_Flag__c FROM Intranet_Item__c where Id IN: listIntranetItems];
        
        //Assert for results
        system.assertEquals(listIntranetItems[0].Default_Content_Flag__c , true);                                                                  
        system.assertEquals(listIntranetItems[1].Default_Content_Flag__c , true); 
        system.assertEquals(listIntranetItems[2].Default_Content_Flag__c , true); 
        system.assertEquals(listIntranetItems[3].Default_Content_Flag__c , true); 
        system.assertEquals(listIntranetItems[4].Default_Content_Flag__c , true); 
        
        //Update Intranet Conatiner records
        listIntranetContainers[0].Default_Content_Item__c = listIntranetItems[3].Id;
        listIntranetContainers[2].Default_Content_Item__c = listIntranetItems[4].Id;
        update listIntranetContainers;
        
        //assert for the results
        listIntranetItems = [SELECT Id ,Name,Default_Content_Flag__c FROM Intranet_Item__c where Id IN: listIntranetItems];
        
        //Assert for results
        system.assertEquals(listIntranetItems[0].Default_Content_Flag__c , false);                                                                  
        system.assertEquals(listIntranetItems[1].Default_Content_Flag__c , true); 
        system.assertEquals(listIntranetItems[2].Default_Content_Flag__c , false); 
        system.assertEquals(listIntranetItems[3].Default_Content_Flag__c , true); 
        system.assertEquals(listIntranetItems[4].Default_Content_Flag__c , true); 
        
        //Query through  Intranet container
        listIntranetContainers = [Select Id, Name, Display_Name__c, RecordTypeId, RecordType.Name, Parent_Container__r.Display_Name__c 
                                        FROM Intranet_Container__c WHERE Id IN: listIntranetContainers];
         
        //Aseert for results
        System.assertEquals(listIntranetContainers[0].RecordType.Name + '-Primary-' + listIntranetContainers[0].Display_Name__c, listIntranetContainers[0].Name); 
        System.assertEquals(listIntranetContainers[1].RecordType.Name + '-' + listIntranetContainers[1].Parent_Container__r.Display_Name__c + '-' + listIntranetContainers[1].Display_Name__c, listIntranetContainers[1].Name); 
        System.assertEquals(listIntranetContainers[2].RecordType.Name + '-' + listIntranetContainers[2].Parent_Container__r.Display_Name__c + '-' + listIntranetContainers[2].Display_Name__c, listIntranetContainers[2].Name); 
        System.assertEquals(listIntranetContainers[3].RecordType.Name + '-' + listIntranetContainers[3].Parent_Container__r.Display_Name__c + '-' + listIntranetContainers[3].Display_Name__c, listIntranetContainers[3].Name); 
        System.assertEquals(listIntranetContainers[4].RecordType.Name + '-Primary-' + listIntranetContainers[4].Display_Name__c, listIntranetContainers[4].Name); 
        
        //Nullify Parent
        for(Intranet_Container__c iC : listIntranetContainers)
            iC.Parent_Container__c = null;
        update listIntranetContainers;
        
        //Query through  Intranet container
        listIntranetContainers = [Select Id, Name, Display_Name__c, RecordTypeId, RecordType.Name, Parent_Container__r.Display_Name__c 
                                        FROM Intranet_Container__c WHERE Id IN: listIntranetContainers];
         
         //Aseert for results
        System.assertEquals(listIntranetContainers[0].RecordType.Name + '-Primary-' + listIntranetContainers[0].Display_Name__c, listIntranetContainers[0].Name); 
        System.assertEquals(listIntranetContainers[1].RecordType.Name + '-Primary-' + listIntranetContainers[1].Display_Name__c, listIntranetContainers[1].Name); 
        System.assertEquals(listIntranetContainers[2].RecordType.Name + '-Primary-' + listIntranetContainers[2].Display_Name__c, listIntranetContainers[2].Name); 
        System.assertEquals(listIntranetContainers[3].RecordType.Name + '-Primary-' + listIntranetContainers[3].Display_Name__c, listIntranetContainers[3].Name); 
        System.assertEquals(listIntranetContainers[4].RecordType.Name + '-Primary-' + listIntranetContainers[4].Display_Name__c, listIntranetContainers[4].Name); 
         
        //parent update
        for(Intranet_Container__c iC : listIntranetContainers)
            iC.Parent_Container__c = IntranetContainer.Id;
        update listIntranetContainers;
        
        //Query through  Intranet container
        listIntranetContainers = [Select Id, Name, Display_Name__c, RecordTypeId, RecordType.Name, Parent_Container__r.Display_Name__c 
                                        FROM Intranet_Container__c WHERE Id IN: listIntranetContainers];
         
        //Aseert for results
        System.assertEquals(listIntranetContainers[0].RecordType.Name + '-' + listIntranetContainers[0].Parent_Container__r.Display_Name__c + '-' + listIntranetContainers[0].Display_Name__c, listIntranetContainers[0].Name); 
        System.assertEquals(listIntranetContainers[1].RecordType.Name + '-' + listIntranetContainers[1].Parent_Container__r.Display_Name__c + '-' + listIntranetContainers[1].Display_Name__c, listIntranetContainers[1].Name); 
        System.assertEquals(listIntranetContainers[2].RecordType.Name + '-' + listIntranetContainers[2].Parent_Container__r.Display_Name__c + '-' + listIntranetContainers[2].Display_Name__c, listIntranetContainers[2].Name); 
        System.assertEquals(listIntranetContainers[3].RecordType.Name + '-' + listIntranetContainers[3].Parent_Container__r.Display_Name__c + '-' + listIntranetContainers[3].Display_Name__c, listIntranetContainers[3].Name); 
        System.assertEquals(listIntranetContainers[4].RecordType.Name + '-' + listIntranetContainers[4].Parent_Container__r.Display_Name__c + '-' + listIntranetContainers[4].Display_Name__c, listIntranetContainers[4].Name); 
        
        //Test stop here
        Test.stopTest();
    }
    
    //This method is to test the field update by Field Name
    static testMethod void testUpdateFieldValue() {
    	
    	//Intranet container (parent)
        Intranet_Container__c intranetContainer = new Intranet_Container__c(Name= 'Parent-Container',
                                                                            CurrencyIsoCode = 'USD',
                                                                            Content_Types_Allowed__c = 'Firm App Link',
                                                                            Display_Name__c='Testing');
        
        insert intranetContainer ;
        
        //Start Testing from here
        Test.startTest();
        
        //Call method
        IntranetContainerTriggerHelper.updateFieldValue(intranetContainer, 'Last_Content_Update__c', DateTime.now());
        update intranetContainer;
        
        //Stop test
        Test.stopTest();
        
        //Assertion
        intranetContainer = [Select Last_Content_Update__c from Intranet_Container__c where Id =: intranetContainer.Id];
        System.assert(intranetContainer.Last_Content_Update__c != null);
    }
    
    /**
      * @Description    :   Method to Test Rending Articale Items and Schedule Created Below Trneding Containers(EAB.com,Advisory.com)
      *
      * @args           :   
      *
      * @return         :   void
      *
    **/
    static testMethod void testTrendingArticle() {
    	
        //Get IntranetDefautls Custom setting Data for Asserts
        /*List<Intranet_Defaults__c> listIntranetDefaults = [select Id, Name, Category__c, Create_Source__c, TrendType__c, LinkBaseURL__c, SettingType__c, ContentTypes__c
                                                          from Intranet_Defaults__c where Category__c = :TrendingArticleConstants.CATEGORY_TRENDING];*/
        
        List<RecordType> contentFixed = [select Id, DeveloperName, Name from RecordType where DeveloperName = 'Content_Fixed' LIMIT 1];
        List<RecordType> contentSubContainer = [select Id, DeveloperName, Name from RecordType where DeveloperName = 'Content_SubContainer' LIMIT 1];
        
        //Insert Parent Container For Trending Containers
        Intranet_Container__c trendingContainer = new Intranet_Container__c(Name = 'Content - Fixed-Boardroom-Trending',
                                                                            Container_Type__c = 'Trending',
                                                                            Status__c = 'Active',
                                                                            Content_Types_Allowed__c = 'Page Section',
                                                                            Display_Name__c='Trending',
                                                                            DPA_Score_Type__c = 'None',
                                                                            RecordTypeId = contentFixed[0].Id);
        insert trendingContainer;
        
        //List of SubContainers
        List<Intranet_Container__c> subContainerList = new List<Intranet_Container__c>();
        
        //set mock response
        Test.setMock(HttpCalloutMock.class, new TrendingArticlesMockResponse());
        
        //Start Test from here
        Test.startTest();
        
        Intranet_Container__c advisoryContainer = new Intranet_Container__c(Name = 'Content - SubContainer-Trending-Advisory.com',
                                                                            Container_Type__c = 'SubContainer',
                                                                            Status__c = 'Active',
                                                                            Content_Types_Allowed__c = 'Trending - Advisory.com',
                                                                            Display_Name__c='Advisory.com',
                                                                            DPA_Score_Type__c = 'None',
                                                                            Sort_Order__c = 1,
                                                                            Parent_Container__c = trendingContainer.Id,
                                                                            Max_Content_Items__c = 3,
                                                                            RecordTypeId = contentSubContainer[0].Id);
        Intranet_Container__c eabContaier = new Intranet_Container__c(Name = 'Content - Fixed-Boardroom-Trending',
                                                                            Container_Type__c = 'SubContainer',
                                                                            Status__c = 'Active',
                                                                            Content_Types_Allowed__c = 'Trending - EAB.com',
                                                                            Display_Name__c='EAB.com',
                                                                            DPA_Score_Type__c = 'None',
                                                                      		Sort_Order__c = 2,
                                                                      		Parent_Container__c = trendingContainer.Id,
                                                                      		Max_Content_Items__c = 3,
                                                                            RecordTypeId = contentSubContainer[0].Id);
        
        subContainerList.add(advisoryContainer);subContainerList.add(eabContaier);
        
        //Insert SubCOntainer List
        insert subContainerList;
        
        
        //Loop over List
        for(Intranet_Container__c ic: subContainerList){
            System.assertEquals(true, ic.Update_Now__c == false);
            System.assertEquals(true, ic.Last_Content_Update__c == null);
            
            //Update the Flag Update Now so we can get Schedule and items below of each container
            ic.Update_Now__c = true;
        }
        
        //Update the List so After Update Trigger can run and can populate Schedule and items below of each container
       	update subContainerList;
       
        //Stop Test
        Test.stopTest();
        
       //Loop over List
        for(Intranet_Container__c ic: subContainerList){
            System.assertEquals(true, ic.Update_Now__c == true); 
        } 
	}
}