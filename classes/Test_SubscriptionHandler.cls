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
 * The @isTest class annotation in  dicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
/**
 *	Purpose         :   Test class for SubscriptionHandler
 *                
 *  Created By      :  
 *   
 *  Created Date    :   6/7/2013
 *   
 *  Revision Log    :   V1.0 - Created
 *						V1.1 - Modified by - Mahendra Swarnkar - 8/30/2016- CR-20160505-9830 
 *						v1.2 - Modified By - Mahendra Swarnkar - 10/20/2016 - CR-20160715-10012
 *
 *  Coverage        :   V1.1 - 85%
 *						V1.2 - 86%
**/
@isTest(SeeAllData = false)  
private class Test_SubscriptionHandler {   
    
    
}