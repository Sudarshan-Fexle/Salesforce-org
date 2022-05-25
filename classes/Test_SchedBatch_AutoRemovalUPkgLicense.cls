/**
*   Description     :   Test Class for SchedBatch_AutoRemovalUserPackageLicense
*
*   Created by      :   Shalu Sharma
*
*   Created Date    :   02/1/2022
*
*   Revision Log    :   V1.0 - Created - Shalu Sharma - CR-20220125-15750 - Remove Managed Package Licenses
*/
@isTest(seeAllData = false)
public class Test_SchedBatch_AutoRemovalUPkgLicense 
{ 
    @isTest
    static void  testSchedBatch_AutoRemovalUserPackageLicense()
    {
        Test.startTest();
        
        Datetime sysTime = DateTime.now().addMinutes(5);
        String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        
        //Schedule the Job
        System.Schedule('Test SchedBatch_AutoRemovalUserPackageLicense', chron_exp, new SchedBatch_AutoRemovalUserPackageLicense());
        
        Test.stopTest();
        
        //Checking the Schedule Job
        List<AsyncApexJob> asyncApexJob = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob where JobType = 'ScheduledApex'];
        System.assertEquals('SchedBatch_AutoRemovalUserPackageLicense', asyncApexJob[0].ApexClass.Name);
    }
}