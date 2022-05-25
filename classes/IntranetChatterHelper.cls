/**
 * 	Purpose			:	This class is to hold all the helper methods for Intranet Chatter
 * 
 * 	Created By		:	Bhavi Sharma
 * 
 * 	Created Date	:	09/12/2014
 * 
 * 	Revision Logs	:	V_1.0 - Created
 **/ 
public with sharing class IntranetChatterHelper {
	
	/**
	 *	@description	:	This method is to create a FeedItem based on the input 
	 * 
	 * 	@args			:	Parent Id, Feed body
	 * 
	 * 	@return			:	FeedItem instance
	 * 	
	 *  @ Revision Logs :	v1.0 - Created
	 * 				    :	v1.1 - Modified By - Rajeev Jain (03/17/2020) (As Feed Tracking for Intranet Item off - Fix bug during Print MIS (Phase 5) deployment)
	 * 									 
	 * 
	 **/
	public static FeedItem CreateFeedItem(Id parentId, String contentBody) {
		
		//Feed Item
		FeedItem feedItem;
		
		//Create a new feed
		if(parentId != null && String.isNotBlank(contentBody)) {
			
			feedItem = new FeedItem(ParentId = parentId, Body = contentBody);
            // Modified By - Rajeev Jain (03/17/2020) (Comment : As Feed Tracking for Intranet Item off)
			//insert feedItem;
		}
		
		//return
		return feedItem;
	}  
}