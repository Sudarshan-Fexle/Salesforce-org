/*
    Purpose         :   Controller class to show follower details on a utility bar.
    
    Created By      :   Abhinav Sharma
    
    Created Date    :   12/31/2019
    
    Current Version :   v1.0
    
    Revision Log    :   V_1.0 Created - 12/31/2019

*/
public with sharing class FollowersCmpController 
{
    @AuraEnabled(cacheable=false)
    public static LightningResponseEntity getFollowers(String recordId)
    {
        if(String.isNotBlank(recordId))
        { 
            try
            {
                List<EntitySubscription> listOfEntitySubscription = new List<EntitySubscription>();
                for(EntitySubscription es : EntitySubscriptionQueryBuilder.getAllEntitySubscriptionForRecord(recordId))
                {
                    listOfEntitySubscription.add(es);
                }
                return LightningResponseEntity.create().setBody(listOfEntitySubscription);
            }
            catch(Exception e)
            {
                throw new AuraHandledException('  occured:\r\n' + e.getMessage() + '\r\n' + e.getStackTraceString() + '\r\n');   
            }
        }
        else
        {
            return null;
        }
    }
}