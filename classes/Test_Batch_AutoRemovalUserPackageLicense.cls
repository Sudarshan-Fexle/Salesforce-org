/**
*   Description     :   Test Class for Batch_AutoRemovalUserPackageLicense
*
*   Created by      :   Shalu Sharma
*
*   Created Date    :   02/1/2022
*
*   Revision Log    :   V1.0 - Created - Shalu Sharma - CR-20220125-15750 - Remove Managed Package Licenses
*/
@isTest(seeAllData = false)
public class Test_Batch_AutoRemovalUserPackageLicense 
{
    @IsTest static void testBatch_AutoRemovalUserPackageLicense()
    { 
        Util.byPassAllTriggers = true;
        
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' limit 1];
        System.assert(profile != null);
        
        List<User> users = [select id, name, LastModifiedDate from user where firstname = 'Test' and IsActive = false];
        System.assert(users.size() > 0);
        
        List<PackageLicense> packageLicense = [SELECT Id, NamespacePrefix FROM PackageLicense  WHERE NamespacePrefix = 'bre'];
        
        List<UserPackageLicense> userPkgLicense = new List<UserPackageLicense>();
        userPkgLicense.add(new UserPackageLicense(UserId = users[0].Id, PackageLicenseId = packageLicense[0].Id));
        insert userPkgLicense;
        
        Util.byPassAllTriggers = false;
        
        Test.startTest();
        
        Batch_AutoRemovalUserPackageLicense batch = new Batch_AutoRemovalUserPackageLicense();
        database.batchablecontext bd ;
        batch.query = 'select id, name, LastModifiedDate from user where firstname = \''+'Test'+'\' and IsActive = false';
        batch.start(bd);
        batch.execute(bd, users);
        batch.finish(bd);
        
        Test.stopTest();
    }
}