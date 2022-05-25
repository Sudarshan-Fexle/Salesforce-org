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
*   Purpose         :   Test class for FollowersCmpController
*            
*   Create By       :   Dipesh Gupta
* 
*   Created Date    :   12/31/2019
*
*   Revision Log    :   V_1.0 - Created - Dipesh Gupta 
*   
*   Coverage        :   V_1.0
*
**/
@isTest(seeAllData = false)
private class Test_FollowersCmpController 
{
    static testMethod void test_FollowersRecords()
    {
        Util.BypassAllTriggers = true;
        Account acct = TestUtilities.CreateNewAccount(true);
        List<Profile> profiles = [SELECT Id FROM Profile 
                                  WHERE Name='System Administrator'];
        if(profiles.size() > 0) 
        {
            User u = new User(ProfileId = profiles[0].Id, LastName='Testing', Alias = 'standt', Email='sysAdmin@testorg.com',
                              UserName= Math.random()+'@abc.com', TimeZoneSidKey='America/Los_Angeles',
                              LocaleSidKey='en_US', EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US');
            insert u;
            
            EntitySubscription eS = new EntitySubscription(SubscriberId =u.Id, ParentId =  acct.Id);
            insert eS;    
        }
        
        Test.startTest();
    	FollowersCmpController.getFollowers(acct.Id);
        Test.stopTest();
    }
    
    static testMethod void test_NegCaseFollowersRecords()
    { 
        Test.startTest();
    	FollowersCmpController.getFollowers(null);
        Test.stopTest();
    }
}