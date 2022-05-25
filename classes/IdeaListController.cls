public without sharing class IdeaListController extends IdeaBaseController {
    public List<IdeaWrapper> IdeaWrappers { get; set; }
    @TestVisible private integer counter=0;  //keeps track of the offset
    private integer list_size=10; //sets the page size or number of rows
    @TestVisible public integer total_size { get; set; }

    public PageReference Beginning() { //user clicked beginning
        counter = 0;
        return Load();
    }
    public PageReference Previous() { //user clicked previous button
        counter -= list_size;
        return Load();
    }
    public PageReference Next() { //user clicked next button
        counter += list_size;
        return Load();
    }
    public PageReference End() { //user clicked end
        counter = total_size - math.mod(total_size, list_size);
        if(counter == total_size) counter = total_size - list_size;
        return Load();
    }
    public Boolean DisablePrevious {
        get {
            //this will disable the previous and beginning buttons
            if (counter>0) return false;
            else return true;
        }
    }
    public Boolean DisableNext { //this will disable the next and end buttons
        get {
            if (counter + list_size < total_size) return false;
            else return true;
        }
    }
    public Integer PageNumber {
        get {
            return counter/list_size + 1;
        }
    }
    public Integer TotalPages {
        get {
            if (math.mod(total_size, list_size) > 0) {
                return total_size/list_size + 1;
            } else {
                return (total_size/list_size);
            }
        }
    }

    // (null) | all | toprated5 | mine | others are treated as category
    public String Filter {
        get {
            if(Filter == null) {
                Filter = ApexPages.currentPage().getParameters().get('show');
                if(Filter == null) Filter = '';
                System.debug('##Show Parameter: ' + filter);
            }
            return Filter;
        }
        set;
    }

	 public String TopIdeasTitle {
		 get {
			  return 'Top ' + [SELECT COUNT() FROM Advisory_Idea__c WHERE TopIdea__c=true AND IsDeleted=false] + ' Ideas';
		 }
	 }

    public static Map<Integer, Advisory_Idea__c> TopRated5{
        get {
            if(TopRated5 == null) {
                TopRated5 = new Map<Integer, Advisory_Idea__c>();

                List<Advisory_Idea__c> ideas = [SELECT Title__c, High_Level_Description__c, Id
                                                FROM Advisory_Idea__c WHERE IsDeleted=false AND TopIdea__c=true ORDER BY Title__c];
                for(Integer i=0; i<ideas.size(); i++) {
                    TopRated5.put(i, ideas.get(i));
                }

            }
            return TopRated5;
        }
        set;
    }

    public override PageReference Load() {
        PageReference pageRef = super.Load();
        if(pageRef != null) {
            return pageRef;
        }

        // Check if the deeplinking is there.
        String id = ApexPages.currentPage().getParameters().get('id');
        if(Filter == '' && id != '' && id != null) Filter = 'id';
        System.debug('##Filter: ' + Filter);

        List<Advisory_Idea__c> ideas;
        if(Filter == 'toprated5') {
            total_size = [SELECT COUNT() FROM Advisory_Idea__c WHERE IsDeleted=false AND TopIdea__c=true];
            ideas = [SELECT Title__c, High_Level_Description__c, Id, Score__c, Comments_Count__c, CreatedDate,
                     (SELECT Voted_By__c FROM Advisory_Idea_Votes__r),
                     (SELECT Commented_By__c FROM Advisory_Idea_Comments__r)
                     FROM Advisory_Idea__c WHERE IsDeleted=false AND TopIdea__c=true
                     ORDER BY Title__c
                     LIMIT :list_size offset :counter];
        } else if(Filter == 'id') {
            total_size = 1;
            ideas = [SELECT Title__c, High_Level_Description__c, Id, Score__c, Comments_Count__c, CreatedDate,
                     (SELECT Voted_By__c FROM Advisory_Idea_Votes__r),
                     (SELECT Commented_By__c FROM Advisory_Idea_Comments__r)
                     FROM Advisory_Idea__c WHERE IsDeleted=false AND id=:id];
        } else if(Filter == 'voted') {
            total_size = MyVote == null? 0 : 1;
            ideas = [SELECT Title__c, High_Level_Description__c, Id, Score__c, Comments_Count__c, CreatedDate,
                     (SELECT Voted_By__c FROM Advisory_Idea_Votes__r),
                     (SELECT Commented_By__c FROM Advisory_Idea_Comments__r)
                     FROM Advisory_Idea__c WHERE IsDeleted=false AND id =: MyVote.WrappedItem.Id];
        } else {
            total_size = [SELECT COUNT() FROM Advisory_Idea__c WHERE IsDeleted=false];
            ideas = [SELECT Title__c, High_Level_Description__c, Id, Score__c, Comments_Count__c, CreatedDate,
                     (SELECT Voted_By__c FROM Advisory_Idea_Votes__r),
                     (SELECT Commented_By__c FROM Advisory_Idea_Comments__r)
                     FROM Advisory_Idea__c WHERE IsDeleted=false
                     ORDER BY CreatedDate desc
                     LIMIT :list_size offset :counter];
        }

        IdeaWrappers = new List<IdeaWrapper>();
        if(ideas != null) {
            for (Advisory_Idea__c item : Ideas) {
                IdeaWrappers.add(new IdeaWrapper(item, CurrentUser.ContactId));
            }
        }
        return null;
    }

    @RemoteAction
    public static String PostComment(String ideaId, String contactId, String comment) {
        system.debug('##PostComment: ideaId=' + ideaId + ', contactId=' + contactId + ', comment=' + comment);

        if (comment != null && comment != '') {
            Advisory_Idea_Comment__c newComment = new Advisory_Idea_Comment__c(
                Advisory_Idea__c = ideaId,
                Commented_By__c = contactId,
                Comment__c = comment
            );
            try {
                insert newComment;
                system.debug('##New Comment Inserted: ' + newComment.Id);
                return '';
            } catch(Exception ex) {
                return 'Error has happened: ' + ex.getMessage();
            }
        }
        else {
            return 'You must enter a comment.';
        }
    }

    @RemoteAction
    public static string Vote(String ideaId, String contactId) {
        system.debug('##Vote: ideaId=' + ideaId + ', contactId=' + contactId);

        List<Advisory_Idea_Vote__c> myVotes = [SELECT Id, Advisory_Idea__r.Title__c FROM Advisory_Idea_Vote__c
                                               WHERE Voted_By__c = :contactId];
        if(myVotes.size() > 0) {
            return 'Sorry, you have voted for ' + myVotes.get(0).Advisory_Idea__r.Title__c + ' already.';
        }

        List<Advisory_Idea_Vote__c> existingVotes = [SELECT Id FROM Advisory_Idea_Vote__c
                                                     WHERE Advisory_Idea__c = :ideaId AND Voted_By__c = :contactId];
        if(existingVotes.size() == 0) {
            Advisory_Idea_Vote__c newVote = new Advisory_Idea_Vote__c (
                Advisory_Idea__c = ideaId,
                Voted_By__c = contactId
            );
            try {
                insert newVote;
                system.debug('##New Vote Inserted: ' + newVote.Id);
                return '';
            }
            catch(Exception ex) {
                return 'Error has happened: ' + ex.getMessage();
            }
        } else {
            return 'You have liked this idea already.';
        }
    }
}