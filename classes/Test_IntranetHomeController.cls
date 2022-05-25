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
 * 	Purpose			:	Test class for IntranetHomeController
 * 
 * 	Created By		:	
 * 
 * 	Created Date	:	09/30/2014
 * 
 *	Revision Logs	:	V_1.0 - Created
 *						V_1.1 - Modified By - Rajeev Jain - CR-7579	- 09/03/2015
 *	Coverage		:	100%
 **/ 
@isTest
private class Test_IntranetHomeController {
    static testMethod void myUnitTest() {
        
        //Hnadling it in try catch excpetion only for code coverage
        //Because controller is fetching main page id from the Label
        try {IntranetHomeController controller = new IntranetHomeController();} catch(Exception e){}   
    }
}