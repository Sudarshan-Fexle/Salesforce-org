public class IdeaCommentWrapper {
    public Advisory_Idea_Comment__c WrappedItem { get; set; }
    
    public String CommenterName { get; set; }
    public String Email { get; set; }
    public String Comment { get; set; }
    public String SmallPhotoUrl { get; set; }
    public boolean IsMyComment { get; set; }
    public boolean IsNewComment { get; set; }
    public boolean UseDefaultPhoto { get { return SmallPhotoUrl == '' || SmallPhotoUrl == null; } }
    
    public IdeaCommentWrapper(Id ideaId, IdeaUserHelper currentUser) {
        System.debug('##IdeaCommentWrapper input: ' + ideaId + ',' + currentUser);
        
        WrappedItem = new Advisory_Idea_Comment__c(
                Commented_By__c = currentUser.ContactId,
                Advisory_Idea__c = ideaId,
                Comment__c = ''
            );
        IsNewComment = true;
        Comment = '';
        IsMyComment = true;
        CommenterName = currentUser.Name;
        Email = currentUser.Email;
        SmallPhotoUrl = '';
        
        System.debug('##IdeaCommentWrapper output: ' + this);
    } 
    
    public IdeaCommentWrapper(Advisory_Idea_Comment__c item, Map<Id,Contact> contacts, Map<Id,User> users, Id currentContactId) {
        System.debug('##IdeaCommentWrapper input: ' + item);
        WrappedItem = item;
        
        IsNewComment = (item.Id == null);
        if(item.Comment__c != null)
            Comment = item.Comment__c.replace('\n', '<br/>');
        IsMyComment = false;
        SmallPhotoUrl = '';

        if(item.Commented_By__c != null && contacts != null) {
            IsMyComment = item.Commented_By__c == currentContactId;
            Contact commenter = contacts.get(item.Commented_By__c);
            CommenterName = IsMyComment? 'myself' : commenter.Name;
            Email = commenter.Email;
            
            if(commenter.Employee_User_Record__c != null && users != null) {
                User user = users.get(commenter.Employee_User_Record__c);
                SmallPhotoUrl = (user!= null)? user.SmallPhotoUrl : '';
                
                if(SmallPhotoUrl != null && SmallPhotoUrl.contains('/profilephoto/005/T'))
                    SmallPhotoUrl = '';
            }
        }
        
        System.debug('##IdeaCommentWrapper output: ' + this);
    }
}