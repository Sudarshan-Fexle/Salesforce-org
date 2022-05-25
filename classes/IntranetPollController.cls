public class IntranetPollController extends IntranetBaseController {
    private IntranetContainer mContainer;
    public IntranetContainer getContainer() {
        return mContainer;
    }
    public void setContainer(IntranetContainer container)  {
        mContainer = container;
    }

    public IntranetContainer PollContainer {
        get {
            return getContainer();
        }
    }
    
    public IntranetPollController(){
        super();
    }
    
    public Id MyPollChoiceId { get; set; }
    
    private List<SelectOption> mChoiceSelectList;
    public List<SelectOption> getChoiceSelectList() {
        
        if(mChoiceSelectList != null) return mChoiceSelectList;
        
        mChoiceSelectList = new list<SelectOption>();
        
        IntranetContent pollItem = PollContainer.RelatedContent.get(0);
        
        for(ConnectApi.FeedPollChoice o : pollItem.PollChoices){
            mChoiceSelectList.add(new SelectOption(o.id, o.text));
        }
        
        return mChoiceSelectList;
	}
    
    public PageReference VoteForPoll() {
        IntranetContent pollItem = PollContainer.RelatedContent.get(0);
        pollItem.LoadPollChoice(ConnectApi.ChatterFeeds.voteOnFeedPoll('internal', pollItem.PollId, MyPollChoiceId));
        return null;
    }
}