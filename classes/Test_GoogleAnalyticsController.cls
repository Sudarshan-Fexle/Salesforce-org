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
*    Purpose         :   Testing for GoogleAnalyticsController class
*                
*    Create By       :   
*    
*    Created Date    :   
*    
*    Revision Log    :   V1.1 - Modified by - Subhash Garhwal - 02/04/2017 - CR-20151015-9324
*   
*    Coverage        :   V1.1 - 94%                 
**/
@isTest
public class Test_GoogleAnalyticsController {
	
    /**
     * @description: Create a couple different types of objects, take their ids and create web service logs.  
     * 				 Verify the correct info is saved on the web service log via the trigger utilities.
     **/
    static testmethod void testWebServiceLogTrigger() {
        //create a contact
        Contact c = TestUtilities.CreateNewContact(true);
        
        string contactView = '/' + c.Id;
        string contactEdit = '/' + c.Id + '/e';
        string contactTab = '/' + string.valueOf(c.Id).subString(0, 3) + '/o';
        string homeTab = '/home/home.jsp';
        
        test.StartTest();
        test.setCurrentPage(Page.GoogleAnalytics);
        ApexPages.currentPage().getParameters().put('id', c.id);
        GoogleAnalyticsController controller = new GoogleAnalyticsController();
        test.stopTest();
        
        system.assertEquals(false, controller.enableTracking);
        
        controller.url = contactView;
        controller.getAnalyticsData();
        system.assertEquals(true, controller.enableTracking);
        //verify the correct info has been populated based on the url
        system.assertEquals('View', controller.activityType);
        system.assertEquals(c.Id, controller.recordId);
        system.assertEquals('Contact', controller.objAPIName);
        system.assertEquals('Contact', controller.objName);
        system.assertNotEquals(null, controller.usr);
        
        //clear the prefix maps, simulating a new object - ensure the code will get the new object
        controller.prefixToAPINameMap.clear();
        controller.prefixToObjectMap.clear();
        
        controller.url = contactEdit;
        controller.getAnalyticsData();
		system.assertEquals(null, controller.errorMsg);
        //verify the correct info has been populated based on the url
        system.assertEquals('Edit', controller.activityType);
        system.assertEquals(c.Id, controller.recordId);
        system.assertEquals('Contact', controller.objAPIName);
        system.assertEquals('Contact', controller.objName);
        system.assertNotEquals(null, controller.usr);
        
        controller.url = contactTab;
        controller.getAnalyticsData();
        //verify the correct info has been populated based on the url
        system.assertEquals('Tab', controller.activityType);
        system.assertEquals(string.valueOf(c.Id).subString(0, 3), controller.recordId);
        system.assertEquals('Contact', controller.objAPIName);
        system.assertEquals('Contact', controller.objName);
        system.assertNotEquals(null, controller.usr);
        system.assertEquals('Salesforce', controller.licenseType);
        
        //V1.1 - Added by - Subhash Garhwal - 02/04/2017 - CR-20151015-9324 - Start from here
        
        //clear the prefix maps, simulating a new object - ensure the code will get the new object
        controller.prefixToAPINameMap.clear();
        controller.prefixToObjectMap.clear();
        
        controller.url = 'https://advisory--dev6.cs51.my.salesforce.com/003?fcf=00BC0000008M3vO';
        controller.getAnalyticsData();
        
        //Assertion for list view
        System.assertEquals('List View', controller.activityType);
        System.assertEquals('Contact', controller.objAPIName);
        System.assertEquals('Contact', controller.objName);
        
        //V1.1 - Added by - Subhash Garhwal - 02/04/2017 - CR-20151015-9324 - Upto here
    }
    
}