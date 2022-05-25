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
 *  Purpose         :   Test class for Schedule_SetReferenceDefaults
 *
 *  Created By      :   Mahendra Swarnkar
 *  
 *  Created Date    :   9/6/2016 
 *
 *  Revision Log    :   V1.0 - Create By - Mahendra Swarnkar - CR-20160809-10096 
 *
 *  Code Coverage   :	100%
 *
 **/
@isTest(SeeAllData = false)
private class Test_Schedule_SetReferenceDefaults {

    static testMethod void myUnitTest() {
        
        //Test starts from here
        Test.startTest();
        
        //instance of Scheduler
        Schedule_SetReferenceDefaults sh1 = new Schedule_SetReferenceDefaults();
        
        //Cron expression string
        String sch = '0 0 23 * * ?';
        
        //schedule the scheduler
        system.schedule('Test Schedule', sch, sh1);
        
        //Test stops from here
        Test.stopTest(); 
        
    }
}