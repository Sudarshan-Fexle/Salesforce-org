/**
*   Description     :   SchedBatch_AutoRemovalUserPackageLicense
*
*   Created by      :   Shalu Sharma
*
*   Created Date    :   02/1/2022
*
*   Revision Log    :   V1.0 - Created - Shalu Sharma - CR-20220125-15750 - Remove Managed Package Licenses
*/
global class SchedBatch_AutoRemovalUserPackageLicense implements Schedulable
{
    global void execute(SchedulableContext SC) 
    {
        Batch_AutoRemovalUserPackageLicense b = new Batch_AutoRemovalUserPackageLicense();
        if(Test.isRunningTest())
        {
            b.query = 'select id, name, LastModifiedDate from user where firstname = \''+'Test'+'\' and IsActive = false';
        }
        Database.executeBatch(b,200);
    }  
}