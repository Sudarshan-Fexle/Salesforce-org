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
*   Description     :   The test class to test the functionalities of Schedule_zendeskQueue scheduler class
*
*   Created by      :   Neha Sharma
* 
*   Created Date    :   28/10/2021
* 
*   Revision Log    :   V1.0 Created - CR-20210301-14957
**/
@isTest(seeAllData = false)
class Test_Schedule_zendeskQueue {
    
    /**
     *  Description     :   The method is used to test scheduler functionalities
     *
     *  @args 
     *
     *  @return         :   Void
     *
     *  @revision       :   V1.0 Created - CR-20210301-14957. 
    **/
    static testMethod void unitTest(){
       
        
        //Start testing from here
        Test.startTest();
        
       //instance of Scheduler
        Schedule_zendeskQueue sh1 = new Schedule_zendeskQueue();
        
        //Cron expression string
        String sch = '0 0 23 * * ?';
        
        //schedule the scheduler
        system.schedule('Test Delete Schedule', sch, sh1);
            
        
        //Stop testing here
        Test.stopTest();
        
        
    }
}