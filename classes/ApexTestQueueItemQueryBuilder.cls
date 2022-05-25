/**
*  Purpose 		: 	ApexTestQueueItem Query Builder Class
*  Created By   :   Abhinav Sharma	
**/
public with sharing class ApexTestQueueItemQueryBuilder 
{
    public static List<ApexTestQueueItem> returnRunTestsItemsForAJob(ID jobId) 
    {
        return Database.query('SELECT ID, ApexClass.Name, Status, ExtendedStatus FROM ApexTestQueueItem WHERE ParentJobId =: jobId ');
    }
    
    public static List<ApexTestQueueItem> returnRunTestsItemsRelatedToJob(ID jobId) 
    {
        return Database.query('SELECT ID, ParentJobId FROM ApexTestQueueItem WHERE Id =: jobId');
    }
}