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
private class Test_Sched_DeleteWebServiceLogs {
/**
 *  Description     :   Test class for Sched_DeleteWebServiceLogs
 *
 *  Created By      :   Ajit Surana
 *
 *  Created Date    :   03/13/2015
 *
 *  Revision Logs   :   V_1.0 - Created - CR-20150122-8591
 *
 *  Coverage        :   100%
 *
 **/
    static testMethod void testDeleteSObjects() {

        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.IsTesting = true;
        Util.byPassAllTriggers = true;
        
        //Test starts from here
        Test.startTest();
        
        //instance of Scheduler
        Sched_DeleteWebServiceLogs sh1 = new Sched_DeleteWebServiceLogs();
        
        //Cron expression string
        String sch = '0 0 23 * * ?';
        
        //schedule the scheduler
        system.schedule('Test Delete Schedule', sch, sh1);
        
        //Test stops from here
        Test.stopTest();    
    }   
}