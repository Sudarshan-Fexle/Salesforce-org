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
/*
    Purpose     :   Test class for AcctExt.
    
    Create By   :   Rajeev Jain - 06/15/2016 - SFDC schema Release - Code Migration from Royall Enviournment
    
    Revision Log:   v1.0 - (AW) Created Code
                    
    Code Coverage: 02/18/2013: 100%
*/
@isTest(seeAllData = false)
public class Test_AcctExt {
	
    public static testMethod void testAcctExt() {
        
		Account a = new Account(Name='Test');
		insert a;
        
        //Start Test from Here
        Test.startTest();
        
		ApexPages.StandardController sc = new ApexPages.StandardController(a);
		AcctExt ext = new AcctExt(sc);
		
		PageReference ref = ext.save();
		String AccId = a.Id;
		AccId = AccId.subString(0,15);
        
        //Stop Test
        Test.stopTest();
		System.assert(ref.getUrl().contains(AccId));		
	}
}