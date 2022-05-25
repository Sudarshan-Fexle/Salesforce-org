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
 **/
/**
 *	Description		:	The test class to test the functionalities of Scheduler_Batch_Cleanup scheduler class
 *
 *	Created by		:	Saurabh Kumar
 * 
 * 	Created Date		:	08/17/2017
 * 
 * 	Revision Log		:	V1.0 Created - CR-20170803-111194
 *					V_1.1 - Modified By - Dipesh Kumar - Apollo - Run All Test Failures Fixes
 *					V_1.2 - Modified By - CR-20211005-15489 - Nikita kumari - 07/07/2021 - remove commented part
 *				
 **/
@isTest(seeAllData = false)
class Test_Scheduler_Batch_Cleanup{
    
   /**
    *	Description		:	The method is used to test scheduler functionalities
    *
    *	@args 
    *
    *	@return			:	Void
    *
    *	@revision		:	V1.0 Created - CR-20170803-11119. 
    **/
    static testMethod void unitTest(){
        //Creating Web Service record
        List<Web_Service_Log__c> webserviceLogs = new List<Web_Service_Log__c>();
        webserviceLogs.add(new Web_Service_Log__c(Card_Vendor__c = 'Out side'));
        insert webserviceLogs;
        
        //Start testing from here
        Test.startTest();
        
        //Executing the scheduler using crone expression
        System.schedule('Scheduler_Batch_Cleanup1', '0 0 0 * * ?', new Scheduler_Batch_Cleanup());
        
        //Stop testing here
        Test.stopTest();
        
        //Query on the the asynchronous job to make sure that batch execution get started
        List<AsyncApexJob> asyncJob = [Select Id From AsyncApexJob Where ApexClass.Name = 'Batch_Cleanup'];
        
    }
}