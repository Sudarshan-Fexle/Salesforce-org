public class IdeaUserHelper {
    public Id ContactId { get; private set; }
    public Id UserId { get; private set; }
    public String Name { get; private set; }
    public String Email { get; private set; }
    public String SmallPhotoUrl { get; private set; }
    public String FullPhotoUrl { get; private set; }
    
    public boolean IsValid { get; private set; }
    public boolean HasUserAccount { get; private set; }
    
    public IdeaUserHelper(String employeeId) {
        System.debug('##IdeaUserHelper input: ' + employeeId);
        
        IsValid = false;
        List<Contact> contacts = [SELECT Id, Email, Name, Employee_User_Record__c FROM Contact
            WHERE Employee_Finance_Code__c=:employeeId];
        if(contacts.size() == 0) {
            return;
        }
        
        FromContact(contacts.get(0));   
    }
    
    public void FromContact(Contact contact)
    {
        IsValid = true;
        ContactId = contact.Id;
        UserId = contact.Employee_User_Record__c;
        Name = contact.Name;
        Email = contact.Email;
        
        List<User> users = [SELECT SmallPhotoUrl, FullPhotoUrl FROM User WHERE Id = :UserId];
        if(users.size() == 0) {
            HasUserAccount = false;
            SmallPhotoUrl = '';
            FullPhotoUrl = '';
        } else {
            User user = users.get(0);
            HasUserAccount = true;
            SmallPhotoUrl = user.SmallPhotoUrl;
            FullPhotoUrl = user.FullPhotoUrl;
        }
        
        System.debug('##IdeaUserHelper output: ' + this);
    }
}