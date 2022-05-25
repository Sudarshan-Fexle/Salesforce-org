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
 *   Purpose        :   Test class for BoardRoom HeaderController
 *       
 *   Created By     : 
 *
 *   Created Date   :   08/12/2014
 *
 *   Revision Log   :   V1.0 - Created 
 * 						V_2.0 - Modified By - Rajeev Jain - CR 7579 - Increase Coverage - 09/10/2015   
 *                      
 *   Coverage       :   V1.0 - 100% 
 *                  
 **/ 
@isTest
private class Test_BoardroomHeaderController {
    
    static testMethod void myUnitTest() {
        
        //Instantiate Controller
        BoardroomHeaderController controller = new BoardroomHeaderController();
        BoardroomHeaderController.MenuController subController = new BoardroomHeaderController.MenuController();
        SelectOption[] FullOptions = subController.FullOptions;
        
        System.assertEquals(true, FullOptions.size() > 0);
        
        //Loop over the Full Option List
		System.assertEquals('Community Impact', FullOptions[0].getValue());
        System.assertEquals('Travel', FullOptions[1].getValue());
        System.assertEquals('Expenses', FullOptions[2].getValue());
        System.assertEquals('Other Options...', FullOptions[3].getValue());
    }
}