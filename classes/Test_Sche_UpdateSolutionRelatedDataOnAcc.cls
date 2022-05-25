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
@isTest(seeAllData = false)
private class Test_Sche_UpdateSolutionRelatedDataOnAcc {
	/*
    Purpose		:	Test class for Sched_UpdateSolutionRelatedDataOnAccount
                
    Create By	:  	Mahendra Swarnkar (CR-20150908-9224)
    
    Created Date:   08/28/2016
    
    Revision Log:	
*/
	
	static testMethod void myUnitTest() {
		 
        //Disables all the trigger
        Util.IsTest(true);
        Util.BypassAllTriggers = true;
         
		//String for cron expression
		String cron = '0 5 * * * ?';
		
		//Test start here
		Test.startTest();
		  
		//Insatnce of Scheduler
		Sched_UpdateSolutionRelatedDataOnAccount sc = new Sched_UpdateSolutionRelatedDataOnAccount();
		  
		//Schedule job
		System.schedule('Schedule Name', cron, sc);
		  
		//Test stop here
		Test.stopTest();
    }
}