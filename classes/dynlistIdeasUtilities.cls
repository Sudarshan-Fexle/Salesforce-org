/*
Purpose         :   dynlistIdeasUtilities (Dynamic Related List)
Created By      :   Shalu Sharma
Created Date    :   04/04/2022
Current Version :   v1.0
Revision Log    :   V_1.0 Created - Shalu Sharma - 04/04/2022
*/
public with sharing class dynlistIdeasUtilities 
{
    public static List<Idea> getIdeas()
    {
        return [Select Id, Title, Status, Categories, Body, CreatorName, CreatedDate, NumComments, CommunityId, VoteTotal FROM Idea];
    } 

    public static List<Idea> getMyIdeas()
    {
        return [Select Id, Title, Status, Categories, Body, CreatorName, CreatedDate, NumComments, CommunityId, VoteTotal 
                FROM Idea WHERE CreatedById =: UserInfo.getUserId()];
    }

    public static List<IdeaComment> getCommentedByMeIdeas()
    {
        return [Select Id, IdeaId, Idea.Title, Idea.Status, Idea.Categories, Idea.Body, Idea.CreatorName, 
                Idea.CreatedDate, Idea.NumComments, Idea.CommunityId, Idea.VoteTotal 
                FROM IdeaComment WHERE IdeaId IN (SELECT Id FROM Idea) AND CreatedById =: UserInfo.getUserId()];
    }

    public static List<Idea> getVottedByMeIdeas()
    {
        List<Vote> votes = [SELECT Id, ParentId FROM Vote WHERE CreatedById =: UserInfo.getUserId() AND Parent.Type='Idea'];
        set<Id> setOfIdeaIds = new Set<Id>();
        for(Vote vote : votes)
        {
            setOfIdeaIds.add(vote.ParentId); 
        }
        return [Select Id, Title, Status, Categories, Body, CreatorName, CreatedDate, NumComments, CommunityId, VoteTotal FROM Idea WHERE Id IN : setOfIdeaIds];
    }
    
    public static List<Idea> getIdeaDetailsWithSelectedCategoryOrStatus(String selectedActionValue, String activeAccSectionName)
    {
        List<Idea> listOfIdeas = new List<Idea>();
        if(String.isNotBlank(selectedActionValue) && activeAccSectionName == 'category')
        {
            listOfIdeas = [Select Id, Title, Status, Categories, Body, CreatorName, CreatedDate, NumComments, CommunityId, VoteTotal 
                    	   FROM Idea WHERE Categories =: selectedActionValue];
        }
        else if(String.isNotBlank(selectedActionValue) && activeAccSectionName == 'status')
        {
            listOfIdeas = [Select Id, Title, Status, Categories, Body, CreatorName, CreatedDate, NumComments, CommunityId, VoteTotal 
                    	   FROM Idea WHERE Status =: selectedActionValue];
        }
        return listOfIdeas;
    }
    
    public static List<Idea> getIdeaDeatilsWithSelectedOption(String selectedOption)
    {
        List<Idea> listOfIdeas = new List<Idea>();
        if(selectedOption == 'trending')
        {
            listOfIdeas = [Select Id, Title, Status, Categories, Body, CreatorName, CreatedDate, NumComments, CommunityId, VoteTotal FROM Idea Order By VoteTotal Desc];
        }
        else if(selectedOption == 'popular')
        {
            listOfIdeas = [Select Id, Title, Status, Categories, Body, CreatorName, CreatedDate, NumComments, CommunityId, VoteTotal FROM Idea Order By VoteTotal Desc];    
        }
        else if(selectedOption == 'recent')
        {
            listOfIdeas = [Select Id, Title, Status, Categories, Body, CreatorName, CreatedDate, NumComments, CommunityId, VoteTotal FROM Idea Where LastViewedDate = THIS_WEEK];    
        }
        return listOfIdeas;
    } 
}