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
public class Test_Constants {
    /**
    Purpose         :   Test class for Constants class
                
    Create By       :   Abhinav Sharma 
    
    Created Date    :   06/07/2016
    
    Revision Log    :   v1.0 - Created - Abhinav Sharma - CR-20150202-8630

    Coverage        :   v1.0 - Constants - 99%   
**/
    //Added By - Abhinav Sharma - 06/07/2016 - CR-20150202-8630
    /**
     * @description : Test method to get the maximum possible coverage and to apply proper assertions 
     *					for various constants like getter-setter of "Constants" class.
     * 
    **/
    static testmethod void testCase1() {
    	
    	//Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //Start test from here
        Test.startTest();
        
        //MAP_WARM_LEAD_EVENTS
        Map<String,Integer> warmLeadEventMap = Constants.MAP_WARM_LEAD_EVENTS;
        System.assertNotEquals(null,warmLeadEventMap);
        System.assertEquals(18,warmLeadEventMap.size());
        System.assertEquals(15,warmLeadEventMap.get('CG - Video'));
        
        //SET_OOO_AND_AUTOMATIC_REPLY
        Set<String> setOOOAndAntoReply = Constants.SET_OOO_AND_AUTOMATIC_REPLY;
        System.assertNotEquals(null,setOOOAndAntoReply);
        System.assertEquals(5,setOOOAndAntoReply.size());
        System.assertEquals(true,setOOOAndAntoReply.contains('out of offices'));
        
        //SET_INSTITUTION_INACTIVE_TYPE_STATUS
        Set<String> institutionStatatus = Constants.SET_INSTITUTION_INACTIVE_TYPE_STATUS;
        System.assertNotEquals(null, institutionStatatus);
        System.assertEquals(3,institutionStatatus.size());
        System.assertEquals(true, institutionStatatus.contains('Inactive - Closed'));
        
        //SET_REGISTRATION_CANCELLED_STATUS
        Set<String> registrationCancelStatus = Constants.SET_REGISTRATION_CANCELLED_STATUS;
        System.assertNotEquals(null, registrationCancelStatus);
        System.assertEquals(2, registrationCancelStatus.size());
        System.assertEquals(true, registrationCancelStatus.contains('VOID'));
        
        //QUEUE_ID_IS_CRM
        Id queueIdIsCrm = Constants.QUEUE_ID_IS_CRM;
        System.assertNotEquals(null, queueIdIsCrm);
        
        //RECORD_TYPE_ID_CASE_PT_SUPPORT
        // Id caseRType = Constants.RECORD_TYPE_ID_CASE_PT_SUPPORT;
        //System.assertNotEquals(null, caseRType);
        
        //RECORD_TYPE_ID_CASE_PT_DATA_LOAD
       /*Id caseRType = Constants.RECORD_TYPE_ID_CASE_PT_DATA_LOAD;
        System.assertNotEquals(null, caseRType);
        
        //RECORD_TYPE_ID_SITE_ISSUE_CCA_SUPPORT_REQUEST
        caseRType = Constants.RECORD_TYPE_ID_SITE_ISSUE_CCA_SUPPORT_REQUEST;
        System.assertNotEquals(null, caseRType);
        
        //RECORD_TYPE_ID_SITE_ISSUE_CCA_DATA_LOAD
        caseRType = Constants.RECORD_TYPE_ID_SITE_ISSUE_CCA_DATA_LOAD;
        System.assertNotEquals(null, caseRType);
        */
        //SYNC_FIELDS_LIST
        List<Sync_Field__c> syncsFields = Constants.SYNC_FIELDS_LIST;
        System.assertNotEquals(null, syncsFields);
        
        //tier2SupportQueue
        Group grp = Constants.tier2SupportQueue;
        System.assertNotEquals(null, grp);
        
        //tier1SupportQueue
        grp = Constants.tier1SupportQueue;
        System.assertNotEquals(null,grp);
        
        //tier1UnassignedQueue
        grp = Constants.tier1UnassignedQueue;
        System.assertNotEquals(null,grp);
        
        //Configuration Manager custom setting records list
        List<Configuration_Manager__c> configurationManagers = new List<Configuration_Manager__c>();
        
        //Create a record of Configuration Manager (Custom Setting) without Key
        Configuration_Manager__c config = new Configuration_Manager__c();
        config.Name = 'Testing';
        configurationManagers.add(config);
        
        //Create a record of Configuration Manager (Custom Setting) with Key
        config = new Configuration_Manager__c();
        config.Name = 'Testing1';
        config.Parameter_Key__c = 'TestK';
        config.Parameter_Value__c = 'TestV';
        config.Parameter_Value__c = 'TestV';
        configurationManagers.add(config);
        
        //Create a record of Configuration Manager (Custom Setting) with same Key
        config = new Configuration_Manager__c();
        config.Name = 'Testing2';
        config.Parameter_Key__c = 'TestK';
        config.Parameter_Value__c = 'TestV1';
        configurationManagers.add(config);
        
        //Inserting custom setting records
        insert configurationManagers;
        
        //Asserting for the results
        System.assert(configurationManagers != null);
        System.assertEquals(3, configurationManagers.size());
        
        //Initilization the Configuration Manager Map
        Map<String, Set<String>> mapOfConfigurationManager = Constants.MAP_CONFIGURATION_MANAGER;
        System.assertNotEquals(null, mapOfConfigurationManager);
        System.assertEquals(1, mapOfConfigurationManager.keySet().size());
        
        //Stop testing here
        Test.stopTest();
    }
}