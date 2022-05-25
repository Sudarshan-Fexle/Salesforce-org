/**
 *   Purpose     :    To check the functionality of SiteContentRecToMulpleInstController
 *   
 *   Revision Log :   v1.00 - 07/28/2019 - CR-20190510-13101 - Victor Hanson - Created
 * 
**/
@istest
public class Test_SiteContentRecMulpleInstController {
	
    @istest
    static void testSiteContentRecToMulpleInstController() {

        Test.startTest();
        
        //Account creation
        Account acc = TestUtilities.CreateNewAccount(true);

        //Creating a standard controller instance. 
        ApexPages.StandardController sc = new ApexPages.StandardController(acc);
        
        //Initializing a class
        SiteContentRecToMulpleInstController controller = new SiteContentRecToMulpleInstController(sc);

        System.assert(controller.acc != null);
        
        Test.StopTest();
    }    
}