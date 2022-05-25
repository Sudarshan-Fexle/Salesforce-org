public class IdeaWrapper {
    public Advisory_Idea__c WrappedItem { get; set; }

    public Integer TotalComments { get; set;}
    public Integer TotalScore { get; set; }
    public boolean HasMyVote { get; set; }
    public boolean HasMyComment { get; set; }
    public String HighLevelDescription { get; set;}
    public String Title{ get; set;}

    public IdeaWrapper(Advisory_Idea__c item, Id currentContactId) {
        System.debug('##IdeaWrapper input: ' + item);
        WrappedItem = item;

        TotalComments = (Integer) item.Comments_Count__c;
        TotalScore = (Integer) item.Score__c;
        HighLevelDescription = item.High_Level_Description__c;
        Title = item.Title__c;

        HasMyVote = false;
        try{
            for (Advisory_Idea_Vote__c vote : item.Advisory_Idea_Votes__r) {
                if (vote.Voted_By__c == currentContactId) {
                    HasMyVote = true;
                    break;
                }
            }
        } catch(Exception ex) {
            List<Advisory_Idea_Vote__c> myVotes = [SELECT Id FROM Advisory_Idea_Vote__c
                                                  WHERE Advisory_Idea__c=:item.id AND Voted_By__c=:currentContactId];
            HasMyVote = myVotes.size() > 0;
        }

        HasMyComment = false;
        for (Advisory_Idea_Comment__c comment : item.Advisory_Idea_Comments__r) {
            if (comment.Commented_By__c == currentContactId) {
                HasMyComment = true;
                break;
            }
        }

        System.debug('##IdeaWrapper output: ' + this);
    }
}