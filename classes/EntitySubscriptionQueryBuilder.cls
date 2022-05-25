/*
    Purpose         :   Entity Subscription Query Builder class
    
    Created By      :   Abhinav Sharma
    
    Created Date    :   12/31/2019
    
    Current Version :   v1.0
    
    Revision Log    :   V_1.0 Created - 12/31/2019

*/
public with sharing class EntitySubscriptionQueryBuilder 
{
    public static List<EntitySubscription> getAllEntitySubscriptionForRecord(String recordId) 
    {
        return [SELECT Id, ParentId, SubscriberId, Subscriber.Name, Subscriber.FullPhotoUrl
                FROM EntitySubscription
                WHERE ParentId =: recordId ORDER BY CreatedDate DESC LIMIT 1000];       
    }
}