/**
 *	Purpose			:	Controller class for IntranetFeed page
 *
 *	Created By		:	Bhavi Sharma
 *
 *	Created Date	:	09/12/2014
 *
 *	Revision Logs	:	V_1.0 - Created
 *
 **/ 
public with sharing class IntranetFeedCommentController {
	
	//FeedComment
	public FeedComment feedComment {get; set;}
	public Id parentId {get; set;}
	public Id feedItemId {get; set;}
	public IntranetType.UserSession UserSession;
	public Id intranetContainerId{get;set;}
    public Id intranetItemId{get;set;}
	public Id intranetScheduleId{get;set;}
	public Double ratingValue;
    public Boolean isLiked {get; set;} 
    //public string strChatterLikeCount;
    public integer intChatterLikeCount {get; set;}
    //public string strChatterCommentCount {get; set;}
    public integer intChatterCommentCount {get; set;}
    public IntranetContent intranetItem;
    
    //Hold Intranet Item Instance
    public IntranetContent getIntranetItem(){
        return intranetItem;
    }
    
    public void setIntranetItem(IntranetContent i){
        intranetItem = i;
        if(i != null){
            if(i.ChatterIsLiked == null){
                isLiked = false;
            }else{
                isLiked = i.ChatterIsLiked;
            } 
            if(i.ChatterLikes == null){
                intChatterLikeCount = 0;
            }else{                
                intChatterLikeCount = integer.valueOf(i.ChatterLikes);   
            }
        }else{
            isLiked = false;
            intChatterLikeCount = 0;
        }
    }
	
	//Hold Chatter Post Text
	public String chatterBody{get;set;}
	
	//Hold Feed Item List
	public List<FeedItem> feedItems;
	
	//Property to Decide when Initialize Feed Item List with Data
	public String loadType{get;set;}
	
	//Constructor
	public IntranetFeedCommentController() {
		
		//Initialize
		feedComment = new FeedComment();
        
		
	}
	
    /**
	 *	@description	:	This mehod to insert a FeedComment record.
	 *
	 *	@args			:	
	 *
	 *	@return			:	void
	 *
	 **/
	public void insertComment() {
		
		try {
			
			//Call helper class method to insert comment
			insert feedComment;
			
		} catch(Exception e) {
			
			//Add error on page
			ApexPages.addMessages(e);
		}
	}
	
	/**
	 *	@description	:	This mehod to insert a FeedComment record.
	 *
	 *	@args			:	
	 *
	 *	@return			:	void
	 *
	 **/
	public PageReference likeFeed() {  
        
        intChatterLikeCount++;
        Map<string, Intranet_Utilization__c> mapLikedItems = IntranetUtilizationHelper.getLikedItems();
        if(mapLikedItems.containsKey(IntranetUtilizationHelper.CLICK_TYPE_LIKE + intranetItemId))
            return null;
        
        if(intranetItem != null ) {
            
            UserSession = IntranetHomeUtility.getUserSession;
            
            //Call future method to create a utilization record
            IntranetUtilizationHelper.createIntranetUtilizationRecord(JSON.serialize(UserSession), IntranetUtilizationHelper.CLICK_TYPE_LIKE, null, intranetContainerId, intranetItemId, intranetScheduleId, ratingValue);
            
            //Increase Like Counter
            //intranetItem.ChatterLikes = intranetItem.ChatterLikes == null ? 1 : intranetItem.ChatterLikes + 1;
            //intranetItem.ChatterIsLiked = true;
            //isLiked = true;
            //intChatterLikeCount +=1;
            //intChatterLikeCount++;
            //system.debug('likeFeed.intChatterLikeCount:'+intChatterLikeCount);
        }
        return null;
    } 
}