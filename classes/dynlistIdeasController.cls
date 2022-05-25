/**
*	Description     :   Idea Community Controller
* 
*	Created By      :   Shalu Sharma 
* 
*	Created Date    :   03/14/2022
* 
*	Revision Logs   :   V_1.0 - Created By - Shalu Sharma - 03/14/2022
*                       
**/ 
public with sharing class dynlistIdeasController      
{
    @AuraEnabled(cacheable=true)
    public static dynlistLightningResponseEntity getCategoryPickList() 
    {
        dynlistLightningResponseEntity res = new dynlistLightningResponseEntity();
        try
        {
            List<IdeaPicklistFieldWrapper> listOfCategories = new List<IdeaPicklistFieldWrapper>();
            Schema.DescribeFieldResult categoryFieldResult = Idea.Categories.getDescribe();
            for(Schema.PicklistEntry f : categoryFieldResult.getPicklistValues())
            {
                listOfCategories.add(new IdeaPicklistFieldWrapper(f.getLabel(), f.getValue()));
            }
            if(listOfCategories.size() > 0)
            {
                res.setBody(listOfCategories);
                res.setSuccess(true);
            }
        }   
        catch(Exception e)
        {
            res.setError(e.getMessage());   
        }
        return res;
    }  
    
    @AuraEnabled(cacheable=true)
    public static dynlistLightningResponseEntity getStatusPickList() 
    {
        dynlistLightningResponseEntity res = new dynlistLightningResponseEntity();
        try
        {
            List<IdeaPicklistFieldWrapper> listOfStatus = new List<IdeaPicklistFieldWrapper>();
            Schema.DescribeFieldResult statusFieldResult = Idea.Status.getDescribe();
            for(Schema.PicklistEntry f : statusFieldResult.getPicklistValues())
            {
                listOfStatus.add(new IdeaPicklistFieldWrapper(f.getLabel(), f.getValue()));
            }
            if(listOfStatus.size() > 0)
            {
                res.setBody(listOfStatus);
                res.setSuccess(true);
            }
        }   
        catch(Exception e)
        {
            res.setError(e.getMessage());   
        }
        return res;
    }
    
    @AuraEnabled(cacheable=true)
    public static dynlistLightningResponseEntity getCommunityForIdeas()
    {
        dynlistLightningResponseEntity res = new dynlistLightningResponseEntity();
        try
        {
            List<IdeaPicklistFieldWrapper> listOfCommunities = new List<IdeaPicklistFieldWrapper>();
            if(Schema.sObjectType.Community.fields.ID.isAccessible() && Schema.sObjectType.Community.fields.IsActive.isAccessible()
               && Schema.sObjectType.Community.fields.Name.isAccessible()
              )
            {
                for(Community comm : [SELECT Id, Name, IsActive FROM Community Where IsActive = true])
                {
                    listOfCommunities.add(new IdeaPicklistFieldWrapper(comm.Name, comm.Id));
                }
                if(listOfCommunities.size() > 0)
                {
                	res.setBody(listOfCommunities);
                    res.setSuccess(true);   
                }
            }
        }
        catch(Exception e)
        {
            res.setError(e.getMessage());   
        }
        return res;   
    }
    
    @AuraEnabled(cacheable=false)
    public static dynlistLightningResponseEntity postIdea(String ideaJson)
    {
        dynlistLightningResponseEntity res = new dynlistLightningResponseEntity();
        try
        {
            if(String.isNotBlank(ideaJson))
            {
                IdeaWrapper idea = (IdeaWrapper)System.JSON.deserialize(ideaJson, IdeaWrapper.class);
                List<Idea> listOfIdeaToBeInserted = new List<Idea>();
                if(Schema.sObjectType.Idea.fields.Title.isCreateable() && Schema.sObjectType.Idea.fields.Body.isCreateable() 
                   && Schema.sObjectType.Idea.fields.CommunityId.isCreateable() && Schema.sObjectType.Idea.fields.Categories.isCreateable()
                   && Schema.sObjectType.Idea.fields.Status.isCreateable()
                  )
                {
                	listOfIdeaToBeInserted.add(new Idea(Title = idea.title, Body = idea.description, Categories = idea.category, CommunityId = idea.zoneId));    
                }
                
                if(listOfIdeaToBeInserted.size() > 0)
                {
                    insert listOfIdeaToBeInserted;
                    res.setBody(listOfIdeaToBeInserted);
                    res.setSuccess(true);	   
                }
            }
        }
        catch(Exception e)
        {
            res.setError(e.getMessage()); 
            System.debug('error->'+e.getMessage());
        }
        return res;
    }
    
    @AuraEnabled(cacheable=true)
    public static dynlistLightningResponseEntity getAllIdeaDetails()
    {
        dynlistLightningResponseEntity res = new dynlistLightningResponseEntity();
        try
        {
            List<IdeaWrapper> listOfIdea = new List<IdeaWrapper>();
            for(Idea idea : dynlistIdeasUtilities.getIdeas())
            {
                listOfIdea.add(new IdeaWrapper(idea.Id, idea.Title, idea.Body, idea.Categories, idea.CommunityId, idea.Status, idea.CreatorName, 
                                               idea.CreatedDate, idea.NumComments, idea.VoteTotal, dynlistIdeasUtilities.getIdeas().size(), false));						    
            }
            if(listOfIdea.size() > 0)
            {
                res.setBody(listOfIdea);
                res.setSuccess(true);  
            }
        }
        catch(Exception e)
        {
            res.setError(e.getMessage());   
        }
        return res;
    }

    @AuraEnabled(cacheable=true)
    public static dynlistLightningResponseEntity getIdeaDetailsWithSelectedAction(String selectedActionName, String activeAccSectionName)
    {
        dynlistLightningResponseEntity res = new dynlistLightningResponseEntity();
        try
        {
            if(String.isNotBlank(selectedActionName) && String.isNotBlank(activeAccSectionName))
            {
                List<IdeaWrapper> listOfIdea = new List<IdeaWrapper>();
                if(selectedActionName == 'allIdeas' && activeAccSectionName == 'show')
                {
                    for(Idea idea : dynlistIdeasUtilities.getIdeas())
                    {
                        listOfIdea.add(new IdeaWrapper(idea.Id, idea.Title, idea.Body, idea.Categories, idea.CommunityId, idea.Status, idea.CreatorName, 
                                                       idea.CreatedDate, idea.NumComments, idea.VoteTotal, dynlistIdeasUtilities.getIdeas().size(), false));						    
                    }
                }
                else if(selectedActionName == 'myIdeas' && activeAccSectionName == 'show')
                {
                    for(Idea idea : dynlistIdeasUtilities.getMyIdeas())
                    {
                        listOfIdea.add(new IdeaWrapper(idea.Id, idea.Title, idea.Body, idea.Categories, idea.CommunityId, idea.Status, idea.CreatorName, 
                                                       idea.CreatedDate, idea.NumComments, idea.VoteTotal, dynlistIdeasUtilities.getMyIdeas().size(), false));						    
                    }
                }
                else if(selectedActionName == 'myOrganizationIdeas' && activeAccSectionName == 'show')
                {
                   
                }
                else if(selectedActionName == 'commentedByMeIdeas' && activeAccSectionName == 'show')
                { 
                    for(IdeaComment ideaComm : dynlistIdeasUtilities.getCommentedByMeIdeas())
                    {
                        listOfIdea.add(new IdeaWrapper(ideaComm.IdeaId, ideaComm.Idea.Title, ideaComm.Idea.Body, ideaComm.Idea.Categories, ideaComm.Idea.CommunityId, ideaComm.Idea.Status, 
                                                       ideaComm.Idea.CreatorName, ideaComm.Idea.CreatedDate, ideaComm.Idea.NumComments, ideaComm.Idea.VoteTotal, 
                                                       dynlistIdeasUtilities.getCommentedByMeIdeas().size(), false));						    
                    }
                }
                else if(selectedActionName == 'votedByMeIdeas' && activeAccSectionName == 'show')
                {
                    for(Idea idea : dynlistIdeasUtilities.getVottedByMeIdeas())
                    {
                        listOfIdea.add(new IdeaWrapper(idea.Id, idea.Title, idea.Body, idea.Categories, idea.CommunityId, idea.Status, idea.CreatorName, 
                                                       idea.CreatedDate, idea.NumComments, idea.VoteTotal, dynlistIdeasUtilities.getVottedByMeIdeas().size(), false));						    
                    }
                }
                else if(activeAccSectionName == 'category' || activeAccSectionName == 'status')
                {
                    for(Idea idea : dynlistIdeasUtilities.getIdeaDetailsWithSelectedCategoryOrStatus(selectedActionName, activeAccSectionName))
                    {
                        listOfIdea.add(new IdeaWrapper(idea.Id, idea.Title, idea.Body, idea.Categories, idea.CommunityId, idea.Status, idea.CreatorName, 
                                                       idea.CreatedDate, idea.NumComments, idea.VoteTotal, dynlistIdeasUtilities.getVottedByMeIdeas().size(), false));						    
                    }
                }
                if(listOfIdea.size() > 0)
                {
                    res.setBody(listOfIdea);
                    res.setSuccess(true);  
                }
                else 
                {
                    res.setMessage('No Record(s) to display.');
                    res.setSuccess(true);
                }
            }
            else 
            {
                res.setError('Action Name can not be blank.'); 
            }
        }
        catch(Exception e)
        {
            res.setError(e.getMessage());   
        }
        return res;
    }
    
    @AuraEnabled(cacheable=false)
    public static dynlistLightningResponseEntity postIdeaComment(String ideaCommtJson)
    {
        dynlistLightningResponseEntity res = new dynlistLightningResponseEntity();
        try
        {
            if(String.isNotBlank(ideaCommtJson))
            {
                IdeaWrapper ideaComment = (IdeaWrapper)System.JSON.deserialize(ideaCommtJson, IdeaWrapper.class);
                List<IdeaComment> listOfIdeaCommentToBeInserted = new List<IdeaComment>();
                if(Schema.sObjectType.IdeaComment.fields.CommentBody.isCreateable() && Schema.sObjectType.IdeaComment.fields.IdeaId.isCreateable())
                {
                	listOfIdeaCommentToBeInserted.add(new IdeaComment(CommentBody = ideaComment.description, /*CommunityId = idea.zoneId, CreatorName = idea.creatorName,*/ 
                                                                      IdeaId = ideaComment.id /*UpVotes = idea.voteScore*/));    
                }
                
                if(listOfIdeaCommentToBeInserted.size() > 0)
                {
                    insert listOfIdeaCommentToBeInserted;
                    List<IdeaComment> ideaComments = [SELECT Id, IdeaId, CommentBody, CreatorName, UpVotes FROM IdeaComment WHERE IdeaId =: listOfIdeaCommentToBeInserted[0].IdeaId];
                    res.setBody(ideaComments); 
                    res.setSuccess(true);	   
                }
                else
                {
                	res.setError('No comments yet');   
                    res.setSuccess(true);
                }
            }
            else
            {
                res.setError('ideaCommtJson can not be null'); 
            }
        }
        catch(Exception e)
        {
            res.setError(e.getMessage());   
        }
        return res;
    }
    
    @AuraEnabled(cacheable=false)
    public static dynlistLightningResponseEntity getIdeaComment(String ideaId)
    {
        dynlistLightningResponseEntity res = new dynlistLightningResponseEntity();
        try
        {
            if(String.isNotBlank(ideaId))
            {
                List<IdeaComment> listOfIdeaComment = new List<IdeaComment>();
                listOfIdeaComment = [SELECT Id, IdeaId, CommentBody, CreatorName, UpVotes FROM IdeaComment WHERE IdeaId =: ideaId];
				if(listOfIdeaComment.size() > 0)
                {
                    res.setBody(listOfIdeaComment); 
                    res.setSuccess(true);	   
                }
                else
                {
                	res.setError('No comments yet'); 
                    res.setSuccess(true);
                }
            }
            else
            {
            	res.setError('ideaId can not be null');    
            }
        }
        catch(Exception e)
        {
            res.setError(e.getMessage());   
        }
        return res;
    }
    
    @AuraEnabled(cacheable=true)
    public static dynlistLightningResponseEntity getIdeaDetailsWithSelectedOptions(String selectedOptionName)
    {
        dynlistLightningResponseEntity res = new dynlistLightningResponseEntity();
        try
        {
            if(String.isNotBlank(selectedOptionName))
            {
                List<IdeaWrapper> listOfIdea = new List<IdeaWrapper>();
                for(Idea idea : dynlistIdeasUtilities.getIdeaDeatilsWithSelectedOption(selectedOptionName))
                {
                    listOfIdea.add(new IdeaWrapper(idea.Id, idea.Title, idea.Body, idea.Categories, idea.CommunityId, idea.Status, idea.CreatorName, 
                                                   idea.CreatedDate, idea.NumComments, idea.VoteTotal, dynlistIdeasUtilities.getIdeas().size(), false));						    
                }
                if(listOfIdea.size() > 0)
                {
                    res.setBody(listOfIdea);
                    res.setSuccess(true);  
                }
                else 
                {
                    res.setMessage('No Record(s) to display.');
                    res.setSuccess(true);
                }
            }
            else 
            {
                res.setError('selectedOptionName Name can not be blank.'); 
            }
        }
        catch(Exception e)
        {
            res.setError(e.getMessage());   
        }
        return res;
    }
    
    @AuraEnabled(cacheable=true)
    public static dynlistLightningResponseEntity getVoteDetails(String selectedIdeaId)
    {
        dynlistLightningResponseEntity res = new dynlistLightningResponseEntity();
        try
        {
            if(String.isNotBlank(selectedIdeaId))
            {
                List<Vote> listOfVote = new List<Vote>();
                for(Vote vote : [SELECT Id, CreatedBy.Name, Type FROM Vote where ParentId =: selectedIdeaId])
                {
                    listOfVote.add(vote);						    
                }
                if(listOfVote.size() > 0)
                {
                    res.setBody(listOfVote);
                    res.setSuccess(true);  
                }
                else 
                {
                    res.setMessage('No Record(s) to display.');
                    res.setSuccess(true);
                }
            }
            else 
            {
                res.setError('selectedIdeaId can not be blank.'); 
            }
        }
        catch(Exception e)
        {
            res.setError(e.getMessage());   
        }
        return res;
    }


    public class IdeaWrapper
    {
        @AuraEnabled public Id id {get;set;}
        @AuraEnabled public String title {get;set;}
        @AuraEnabled public String description {get;set;} 
        @AuraEnabled public String category {get;set;} 
        @AuraEnabled public Id zoneId {get;set;} 
        @AuraEnabled public String status {get;set;} 
        @AuraEnabled public String creatorName {get;set;}
        @AuraEnabled public DateTime createdDate {get;set;}
        @AuraEnabled public Integer numComments {get;set;}
        @AuraEnabled public Decimal voteTotal {get;set;}
        @AuraEnabled public Integer ideaRecordsCount {get;set;}
        @AuraEnabled public Boolean displayCommentsOrVotesSection {get;set;}
        
        public IdeaWrapper(Id id, String title, String description, String category, Id zoneId, String status,
                           String creatorName, DateTime createdDate, Integer numComments, Decimal voteTotal, Integer ideaRecordsCount, 
                           Boolean displayCommentsOrVotesSection)
        {
            this.id = id;
            this.title = title;
            this.description = description;
            this.category = category;
            this.zoneId = zoneId;
            this.status = status;
            this.creatorName = creatorName;
            this.createdDate = createdDate;
            this.numComments = numComments;
            this.voteTotal = voteTotal;
            this.ideaRecordsCount = ideaRecordsCount;
            this.displayCommentsOrVotesSection = displayCommentsOrVotesSection;
        }
    } 
    
    public class IdeaPicklistFieldWrapper
    {
        @AuraEnabled public String label {get;set;}
        @AuraEnabled public String value {get;set;}
        
        public IdeaPicklistFieldWrapper(String label, String value){
            this.label = label;
            this.value = value;
        }
    } 
}