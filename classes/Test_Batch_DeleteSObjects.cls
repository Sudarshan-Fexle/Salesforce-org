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
private class Test_Batch_DeleteSObjects {
    /**
    *  Description     :   Test class for Batch_DeleteSObjects
    *
    *  Created By      :   Ajit Surana
    *
    *  Created Date    :   02/28/2015
    *
    *  Revision Logs   :   V_1.0 - Created - CR-20150122-8591
    * 			   V_1.1 - Modified By - Abhishek Mishra - CR-20210517-15151 - 06/25/2021
    *
    *  Coverage        :   100%
    *
    **/
    static testMethod void testDeleteSObjects() 
    {
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.IsTesting = true;
        Util.byPassAllTriggers = true;
        
        // Added By Abhishek Mishra -- 06/25/2021 --Start
        List<Web_Service_Log__c> webServiceLog = new List<Web_Service_Log__c>();
        webServiceLog.add(new Web_Service_Log__c(Card_Vendor__c = 'Out side',RecordTypeId = ProductionTrackingTriggerHelper.RT_WEB_SERVICE_LOG_PRODUCTION_TRACKING,Web_Service_Method__c = 'FindMeetings',
                                                 Response_Message__c = 'Success',CreatedDate = System.Today().addDays(-45)));
        webServiceLog.add(new Web_Service_Log__c(Card_Vendor__c = 'Out side',RecordTypeId = ProductionTrackingTriggerHelper.RT_WEB_SERVICE_LOG_PRODUCTION_TRACKING,Web_Service_Method__c = 'FindMeetings',
                                                 Response_Message__c = 'Success',CreatedDate = System.Today().addDays(-35)));
        webServiceLog.add(new Web_Service_Log__c(Card_Vendor__c = 'Out side',RecordTypeId = ProductionTrackingTriggerHelper.RT_WEB_SERVICE_LOG_PRODUCTION_TRACKING,Web_Service_Method__c = 'FindMeetings',
                                                 Response_Message__c = 'Success',CreatedDate = System.Today().addDays(-5)));
        webServiceLog.add(new Web_Service_Log__c(CreatedDate = System.Today().addDays(-45)));
        insert webServiceLog;
        System.assertEquals(4, webServiceLog.size());
        
        Util.byPassAllTriggers = false;
        
        List<Web_Service_Log__c> wSL = [Select Id From Web_Service_Log__c WHERE CreatedDate < LAST_N_DAYS:30 ];
        System.assertEquals(3, wSL.size());
        // Added By Abhishek Mishra -- 06/25/2021 -- end
        
        //Test starts from here
        Test.startTest();
        
        //Execute the batch class
        Batch_DeleteSObjects  c = new Batch_DeleteSObjects ('Web_Service_Log__c');
        Database.executeBatch(c);
        
        //Test stops from here
        Test.stopTest();
        
        List<Web_Service_Log__c> webServiceLogs = [SELECT Id FROM Web_Service_Log__c];
        System.assertEquals(1, webServiceLogs.size());
    }   
}