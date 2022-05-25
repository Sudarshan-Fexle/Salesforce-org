public class AddToWatchListAccountController 
{
    public String returnURLValue {get; set;}
    public AddToWatchListAccountController(ApexPages.StandardSetController controller) 
    {
        controller.setPageSize(20);
        returnURLValue = Org_Setting__c.getInstance().Org_Host_URL__c  + '/' + Account.sObjectType.getDescribe().getKeyPrefix();
    }
}