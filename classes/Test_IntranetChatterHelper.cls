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
/** Description     :	Test class for IntranetChatterHelperController
  * 
  * Created Date    :	09/15/2014
  *
  * Created By      :   
  *  
  * Current vision  :	v1.0
  *  
  * Revision Logs   :	v1.0 - Created
  * 				:	V2.0 - Modifled By - Rajeev Jain(09/15/2015) - CR-20141002-7579
  *
  * Coverage        :	100%
  **/  
// ConnectApi methods are not supported in data siloed tests. Please use @IsTest(SeeAllData=true)
// Making true due to getting above mentined error while running test class
@isTest(SeeAllData = true)
private class Test_IntranetChatterHelper {

    static testMethod void testInsertFeedItem() {
        // TO DO: implement unit test
         
        //Create Intranet Item
        Intranet_Item__c intranetItem = new Intranet_Item__c(Name = 'Test-0' , Active_Status__c = 'Active' , Item_Type__c = 'App Link' , Item_Title__c = 'A1');
        insert intranetItem;
        
        //Feed Item Body
        String testFeedBody = 'Hello this is Test feed Body';
        
        //Instance of Feed Item
        FeedItem feedItem;
        
        Test.startTest();
        
        //Insert Feed Item
        feedItem = IntranetChatterHelper.CreateFeedItem(intranetItem.Id, testFeedBody);
        
        //Assert to Check Parent Id
        System.assertEquals(feedItem.ParentId, intranetItem.Id);
        
        //Assert to Check Item Body
        System.assertEquals(feedItem.Body, testFeedBody);
        
        Test.stopTest();
    }
}