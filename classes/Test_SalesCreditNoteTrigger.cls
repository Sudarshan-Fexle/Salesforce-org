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
@isTest(SeeAllData=true)
private class Test_SalesCreditNoteTrigger {
	
	/**
	  *   Purpose         :   Test class for SalesCreditNoteTrigger
	  *            
	  *   Create By       :   
	  * 
	  *   Created Date    :   
	  *
	  *   Revision Log    :   V_1.0 - Created
	  *						  V_1.1 - Modified by - Saurabh Kumar - 07/14/2017 - Q2C Phase 2
	  *
	  */ 
    static testMethod void test1() {
             List<c2g__codaCreditNote__c> salesinvoice2 = [Select Id from c2g__codaCreditNote__c limit 1];
            update salesinvoice2;
        
    }  
}