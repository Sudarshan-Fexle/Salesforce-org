public class IntranetUserInfo implements Comparable {

    public Id UserId {get; private set;}
    public String FirstName {get; private set;}
    public String LastName {get; private set;}
    public String Title {get; private set;}
    public String Email {get; private set;}
    public String Phone {get; private set;}
    public String ChatterPicture {get; private set;}
    public Id ManagerUserId {get; private set;}
    public String ManagerName {get; private set;}
    public String SpaceNumber {get; private set;}
    public String Office {get; private set;}
    public String OfficeName {get; private set;}
    public String ChatterViewLink {get; private set;}
    public string Department { get; private set;}
    public String SortOrder {get; set;}
    
    public IntranetUserInfo(User u) {
        UserId = u.Id;
        FirstName = u.FirstName;
        LastName = u.LastName;
        Title = u.Title;
        Email = u.Email;
        Phone = u.Phone;
        ChatterPicture = u.SmallPhotoUrl;
        ManagerUserId = u.ManagerId;
        ManagerName = u.Manager.Name;
        SpaceNumber = u.Workspace_Number__c;
        Office = u.Office__c;
        OfficeName = IntranetHomeUtility.LookupOfficeNameById(u.Office__c);
        ChatterViewLink = (new PageReference('/' + u.Id)).getUrl();
        Department = u.ABC_Department__c;
        //ConnectApi.UserProfiles.getUserProfile(null, u.Id);
        SortOrder = this.FirstName + ' ' + this.LastName;
    }
    
    public Integer compareTo(Object compareTo) {
        if(compareTo == null) return 1;
        IntranetUserInfo compareToIContent = (IntranetUserInfo)compareTo;
        if(compareToIContent == null) return 1;
        
        if ( (SortOrder == null? '' : SortOrder) == (compareToIContent.SortOrder == null? '' : compareToIContent.SortOrder) ) return 0;
        if ( (SortOrder == null? '' : SortOrder) > (compareToIContent.SortOrder == null? '' : compareToIContent.SortOrder) ) return 1;
        return -1;
    }
    
    public string ToString(string indent) {
        return indent + 'UserInfo: (Id=' + this.UserId + ' name=' + this.FirstName + ' ' + this.LastName + ', sortOrder=' + this.sortOrder + ')<br>';
    }
}