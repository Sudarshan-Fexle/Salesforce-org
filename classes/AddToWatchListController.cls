public class AddToWatchListController 
{
    public String returnURLValue {get; set;}
    public AddToWatchListController(ApexPages.StandardSetController controller) 
    {
        controller.setPageSize(20);
        returnURLValue = Org_Setting__c.getInstance().Org_Host_URL__c  + '/' + Contact.sObjectType.getDescribe().getKeyPrefix();
    }
}