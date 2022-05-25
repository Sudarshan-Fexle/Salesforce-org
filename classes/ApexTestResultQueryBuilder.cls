/**
*  Purpose      :   ApexTestResult Query Builder Class
*  Created By   :   Abhinav Sharma
*  Revision Log :   V_1.0 - Created - Abhinav Sharma
*					V_1.1 - Modified By - Mahendra Swarnakar - CR-20200721-14340 - 07/21/2020 - For Error Fix(Too many query rows: 50001)
* 
**/
public with sharing class ApexTestResultQueryBuilder 
{
    // Get the result for each test method that was executed.
    public static List<ApexTestResult> retrieveRunTestResultsForAJob(ID jobId) 
    {
        // Modified By - Mahendra Swarnakar - CR-20200721-14340 - 07/21/2020 - For Error Fix
        if(String.isNotBlank(jobId))
        {
        	ApexTestResult[] results = Database.query('SELECT ID, ApexClass.Name, MethodName, Outcome, Message, StackTrace FROM ApexTestResult WHERE AsyncApexJobId =: jobId');
        	return results;
        }
        return null;
    }
}