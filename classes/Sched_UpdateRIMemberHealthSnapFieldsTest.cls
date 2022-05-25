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
@isTest(seeAllData=false)
private class Sched_UpdateRIMemberHealthSnapFieldsTest {
/*
    Purpose            :    Test class of "Sched_UpdateRIMemberHealthSnapshotFields" scheduler job.
    
    Created By         :    Abhinav Sharma
    
    Current Version    :    v1.0
    
    Revision Log       :    v1.0 - Abhinav Sharma - CR-20160114-9516 - 02/29/2016
	
	Coverage		   : 	v1.0 - Sched_UpdateRIMemberHealthSnapshotFields - 100%
*/
    //Test method
    static testMethod void unitTest1() {

        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.IsTesting = true;
        Util.byPassAllTriggers = true;
        
        //Test starts from here
        Test.startTest();
        
        //instance of Scheduler
        Sched_UpdateRIMemberHealthSnapshotFields sh1 = new Sched_UpdateRIMemberHealthSnapshotFields();
        
        //Cron expression string
        String sch = '0 0 23 * * ?';
        
        //schedule the scheduler
        system.schedule('Test Schedule', sch, sh1);
        
        //Test stops from here
        Test.stopTest();    
    }   
}