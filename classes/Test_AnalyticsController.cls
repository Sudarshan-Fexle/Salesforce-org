/**
 *  Purpose         :  Test class for AnalyticsController Class 
 *                
 *  Created By      :  Chirag Soni
 *   
 *  Created Date    :  07/09/2021
 *   
 *  Revision Log    :  V1.0 - 07/09/2021 - Chirag Soni - Created w.r.t CR-20210706-15276
 *
 *  Coverage        :  V1.0 - 86%
**/
@isTest(SeeAllData = false) 
Private class Test_AnalyticsController {
    
    static testmethod void testGoogleAnalyticsData(){
        
        Util.BypassAllTriggers = true;
        //create a new account
        Account account = TestUtilities.createNewAccount(true);
        
        // create current location by base using url and account Id
        String currentLocation = System.Url.getSalesforceBaseUrl().toExternalForm()+'/lightning/r/Account/'+account.Id+'/view';
        
        //Query System Admin User 
        User usr = [SELECT Id, ProfileId FROM USER WHERE Profile.Name = 'System Administrator' AND IsActive = True LIMIT 1];
        
        //query license type for assert 
        String usrLicense = [SELECT Id, UserLicense.Name FROM Profile WHERE Id = :usr.ProfileId].UserLicense.Name;
        
        Util.BypassAllTriggers = false;
        
        Test.startTest();
        
        // Run test class in system admin user context
        System.runAs(usr){
            
            //get GoogleAnalyticsData from AnalyticsController
            AnalyticsController.GoogleAnalyticsData  googleAnalyticsData = AnalyticsController.getGoogleAnalyticsData(null, currentLocation);
            
            // assert to check current user id.
            System.assertEquals(UserInfo.getUserId(), googleAnalyticsData.userData.Id);
            
            // assert to check license type
            System.assertEquals(usrLicense, googleAnalyticsData.licenseType);
            
            // assert to check object name
            System.assertEquals('Institution', googleAnalyticsData.objectName);
           
            // assert to check object API name
            System.assertEquals('Account', googleAnalyticsData.objectAPIName);
            
            // assert to check record id
            System.assertEquals(Account.Id, googleAnalyticsData.recordId);
           
            // assert to check activity type
            System.assertEquals('View', googleAnalyticsData.activityType);
            
            // assert to check  current location
            System.assertEquals(currentLocation, googleAnalyticsData.currentLocation);
        }
        Test.stopTest();
    }
}