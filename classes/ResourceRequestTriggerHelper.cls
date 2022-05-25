/**
    *  Purpose         :  This Class is having all the automation logic method on Resource Request object.
    * 
    *  Created By      :   Neha Sharma
    *
    *  Created Date    :   09/11/2021
    *
    *  Revision Logs   :   V_1.0 - Created - CR-20211103-15563
    * 
*/
public class ResourceRequestTriggerHelper 
{
    public static void validateResourceRequestStatus(Map<Id, pse__Resource_Request__c> mapOldResourceRequest)
    {
        for(pse__Resource_Request__c resourceRequest : mapOldResourceRequest.values())
        {
            if(resourceRequest.pse__Status__c != null &&  userinfo.getProfileId() != Label.System_Admin_Profile_Id)
            {
                resourceRequest.addError(System.Label.Error_Msg_For_Resource_Request_Deletion);
            }
        }
    }
}