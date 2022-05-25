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
private class Workday_BatchSyncCostCenterTest {
    
/**
 *   Purpose        :   Test class for Workday_BatchSyncCostCenter
 *               
 *   Created By     :   
 *   
 *   Created Date   :   
 *   
 *   Revision Log   :   V1.0 - Created
 *                      V1.1 - Modified By - Abhinav Sharma - CR-20150622-9018 - Test Class Time Zone issue - 06/24/2015
 *                      v1.2 - Modified - Abhinav Sharma - CR-20160728-10073 - 07/28/2016
 *                      V_1.3 - Modified By - Abhinav Sharma - 12/11/2016 - CR-20160408-9751  
 *                       
 *
 *  Coverage        :   v_1.2 - Workday_BatchSyncCostCenter - 82%
 *                      v_1.3 - Workday_BatchSyncCostCenter - 82%
**/    
    
    /** Description : Method to create WorkdayCostCenterSync__c custom setting record.
    **/
    static WorkdayCostCenterSync__c AddCustomSetting(Datetime cutoff) {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //Create Workday Cost Sync Setting record
        WorkdayCostCenterSync__c settings = new WorkdayCostCenterSync__c();
        settings.Error_Report_Email__c = 'email@email.com';
        settings.Web_Service_Url__c = 'http://abc.com';
        settings.Web_Service_User_Name__c = 'user';
        settings.Web_Service_Password__c = 'password';
        settings.Last_Update_Time_Stamp__c = cutoff;
        settings.SetupOwnerId = UserInfo.getUserId();
        insert settings;
 
        return settings;
    }
    
    //Modified By - Abhinav Sharma - 12/11/2016 - CR-20160408-9751
    //Modified By - Abhinav Sharma - CR-20160728-10073 - 07/28/2016 - To fix out the "Timestamp should be updated" related test failure
    //Modified By - Abhinav Sharma - CR-20150622-9018 -06/24/2015 - Update method to run in context of a GMT time zone user
    /** Description : This method will test out the "Workday_BatchSyncCostCenter" batch job related functionality and results.
    **/
    static testmethod void testBatchProcess() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1];
        
        //Asserting for the results
        System.assert(p != null);
        
        //Added by - Abhinav Sharma - CR-20160408-9751 - To resolve timezone issues
        //Start from here
        //Get the current User timezon based details 
        User currentUser = [SELECT TimeZoneSidKey, LanguageLocaleKey, LocaleSidKey, ProfileId, EmailEncodingKey 
                            FROM User WHERE ID =: UserInfo.getUserId()];
        System.assert(currentUser != null);
        //Upto here
        
        //Modified by - Abhinav Sharma - CR-20160408-9751
        //To update the runAs user timezone attributes/fields with current logged in user timezone attributes/values
        //This way, we will not get the timezone based issue, while deployment or during weekends due to timezone difference
        //Start from here
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                            EmailEncodingKey=currentUser.EmailEncodingKey, LastName='Testing', LanguageLocaleKey= currentUser.LanguageLocaleKey, 
                            LocaleSidKey= currentUser.LocaleSidKey, ProfileId = p.Id, TimeZoneSidKey = currentUser.TimeZoneSidKey,
                            UserName=Math.random() + '@test.com');
        insert u;
        //upto here
        
        //Running code in context of a "Current Logged In" user time zone user
        System.runAs(u) {
        
            //Current date time
            Datetime timestamp0 = Datetime.now();
            
            //Creating "Workday Cost Center Sync" custom setting record
            WorkdayCostCenterSync__c settings = AddCustomSetting(timestamp0);
            
            //List to hold the c2g__codaDimension1__c object records
            c2g__codaDimension1__c[] ml = new List<c2g__codaDimension1__c>();
        
            //Populating list with records instances    
            for (Integer i=0; i<10; i++) {
                
                //c2g__codaDimension1__c record instance
                c2g__codaDimension1__c m = new c2g__codaDimension1__c(Name='CC-00-00' + i,
                                                                        c2g__ReportingCode__c = string.valueOf(i));
                //Adding instance into the list
                ml.add(m);
            }
            
            //Insert records
            insert ml;
            
            //Setting mock response
            Test.setMock(WebServiceMock.class, new WorkdayHumanResourcesTest.WorkdayHumanResourcesMockImpl());
        
            //Workday_BatchSyncCostCenter batch job controller
            Workday_BatchSyncCostCenter c = new Workday_BatchSyncCostCenter();
            
            //Setting query parameters
            c.QueryString = 'SELECT ID, Name, c2g__ReportingCode__c, LastModifiedDate' +
                    ' FROM c2g__codaDimension1__c ORDER BY LastModifiedDate';
        
            //Start test from here
            Test.startTest();
            
            //Execute Batch
            Database.executeBatch(c);
            
            //Stop test here
            Test.stopTest();
            
            //Getting custom setting instance for the current logged in user
            WorkdayCostCenterSync__c newSettings1 = WorkdayCostCenterSync__c.getInstance(UserInfo.getUserId());
            
            //Asserting for the results
            System.assert(newSettings1 != null);
            system.assertNotEquals(null, newSettings1.Last_Update_Time_Stamp__c);
        }
    }        

    //Modified By - Abhinav Sharma - 12/11/2016 - CR-20160408-9751
    //Modified - Abhinav Sharma - CR-20160728-10073 - 07/28/2016 - To refactor this method existing test code
    //Modified By - Abhinav Sharma - CR-20150622-9018 -06/24/2015 - Update method to run in context of a GMT time zone user
    /** Description : This method will test out the "Workday_BatchSyncCostCenter" batch job related functionality and results.
    **/
    static testmethod void testSingleProcess() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1];
        
        //Asserting for the results
        System.assert(p != null);
        
        //Added by - Abhinav Sharma - CR-20160408-9751 - To resolve timezone issues
        //Start from here
        //Get the current User timezon based details 
        User currentUser = [SELECT TimeZoneSidKey, LanguageLocaleKey, LocaleSidKey, ProfileId, EmailEncodingKey 
                            FROM User WHERE ID =: UserInfo.getUserId()];
        System.assert(currentUser != null);
        //Upto here
        
        //Modified by - Abhinav Sharma - CR-20160408-9751
        //To update the runAs user timezone attributes/fields with current logged in user timezone attributes/values
        //This way, we will not get the timezone based issue, while deployment or during weekends due to timezone difference
        //Start from here
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                            EmailEncodingKey=currentUser.EmailEncodingKey, LastName='Testing', LanguageLocaleKey= currentUser.LanguageLocaleKey, 
                            LocaleSidKey= currentUser.LocaleSidKey, ProfileId = p.Id, TimeZoneSidKey = currentUser.TimeZoneSidKey,
                            UserName=Math.random() + '@test.com');
        insert u;
        //upto here
        
        //Running code in context of a "Current Logged In" user time zone user
        System.runAs(u) {
        
            //Creating "Workday Cost Center Sync" custom setting record
            WorkdayCostCenterSync__c settings = AddCustomSetting(null); 
            
            //Create c2g__codaDimension1__c object record
            c2g__codaDimension1__c m = new c2g__codaDimension1__c(Name='CC-00-0001',
                                                                    c2g__ReportingCode__c = '0001'
            );
            
            //Insert c2g__codaDimension1__c record
            insert m;
            
            //Querying for the updated details
            c2g__codaDimension1__c m1 = [SELECT LastModifiedDate FROM c2g__codaDimension1__c WHERE ID = :m.ID];
            
            //Asserting for the results
            System.assert(m1 != null);
            
            //Setting mock response
            Test.setMock(WebServiceMock.class, new WorkdayHumanResourcesTest.WorkdayHumanResourcesMockImpl());
            
            //Workday_BatchSyncCostCenter batch job controller
            Workday_BatchSyncCostCenter c = new Workday_BatchSyncCostCenter();
            
            //Setting query parameter string lieral
            c.QueryString = 'SELECT ID, Name, c2g__ReportingCode__c, LastModifiedDate' +
                ' FROM c2g__codaDimension1__c WHERE Name=\'CC-00-0001\'';
            
            //Start test from here
            Test.startTest();
            
            //Execute Batch Job
            Database.executeBatch(c);
            
            //Stop test here
            Test.stopTest();
            
            //Getting custom setting instance for the current logged in user
            WorkdayCostCenterSync__c newSettings1 = WorkdayCostCenterSync__c.getInstance(UserInfo.getUserId());
            
            //Asserting for the results
            System.assert(newSettings1 != null);
            system.assertNotEquals(null, newSettings1.Last_Update_Time_Stamp__c);
        }
    }
}