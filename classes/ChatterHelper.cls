//Modified - Bhavi Sharma - 02/23/15 - added method: AddFollower
//Modified - Bhavi Sharma - 02/23/15 - added method: RemoveFollower
public without sharing class ChatterHelper {
	
	//Variable 
	final static Integer LIMIT_CHATTER_MAX_ENTITY_SUBSCRIPTION_RECORDS = 500;
	
    public static Id OOOAutoResponseId {
        get {
            if(OOOAutoResponseId == null) {
                List<User> users = [SELECT Id from user where name='out of office response' LIMIT 1];
                OOOAutoResponseId = users.size ()==0? UserInfo.getUserId() : users.get(0).Id;
            }
            return OOOAutoResponseId;
        }
        set;
    }
    
    // Turn an input String into a useful TextSegmentInput
    public static ConnectApi.TextSegmentInput AddTextSegment(String thisString) {
        ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput();
        textSegment.text = thisString;
        return textSegment;
    }
    
    // Turn an input Id into a useful MentionSegmentInput
    public static ConnectApi.MentionSegmentInput AddMentionSegment(Id thisId) {
        ConnectApi.MentionSegmentInput mentionSegment = new ConnectApi.MentionSegmentInput();
        mentionSegment.Id = thisId;
        return mentionSegment;
    }
    
    // Create and post a message to Chatter (Mention List)
    public static ConnectApi.FeedItem PostChatterFeedItem(ConnectApi.FeedType feedType, String subject,
                                                          String message, List<Id> userIds) {
        // Combine the needed messageSegments into one coherent messageInput
        ConnectApi.MessageBodyInput messageInput = new ConnectApi.MessageBodyInput();
        messageInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        if(userIds != null) {
            messageInput.messageSegments.add(addTextSegment(message + '\nCC: '));
            for (integer i=0; i<userIds.size(); i++) {
                messageInput.messageSegments.add(addMentionSegment(userIds.get(i)));
                if(i < userIds.size() - 1) messageInput.messageSegments.add(addTextSegment(', '));
            }
        } else {
            messageInput.messageSegments.add(addTextSegment(message));
        }
        
        // Attach the messageInput as the Input.body
        ConnectApi.FeedItemInput input = new ConnectApi.FeedItemInput();
        input.body = messageInput;
        
        // Post to Chatter
        return ConnectApi.ChatterFeeds.postFeedItem(null, feedType, subject, input, null);
    }

    // Create and post a comment to Chatter feed (Mention List)
    public static ConnectApi.Comment PostChatterCommentItem(String feedItemId, String message, List<Id> userIds) {
        // Combine the needed messageSegments into one coherent messageInput
        ConnectApi.MessageBodyInput messageInput = new ConnectApi.MessageBodyInput();
        messageInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        if(userIds != null) {
            messageInput.messageSegments.add(addTextSegment(message + '\nCC: '));
            for (integer i=0; i<userIds.size(); i++) {
                messageInput.messageSegments.add(addMentionSegment(userIds.get(i)));
                if(i < userIds.size() - 1) messageInput.messageSegments.add(addTextSegment(', '));
            }
        } else {
            messageInput.messageSegments.add(addTextSegment(message));
        }
        
        // Attach the messageInput as the Input.body
        ConnectApi.CommentInput input = new ConnectApi.CommentInput();
        input.body = messageInput;
        
        // Post comment to Chatter feed
        return ConnectApi.ChatterFeeds.postComment(null, feedItemId, input, null);
    }
        
    public static void OOOAutoRespondFeedItems(Set<Id> feedItemIds){
        Map<String, List<Id>> mentionedUsersMap = new Map<String, List<Id>>();
        
        //For each FeedItem (post) being inserted...
        for(Id feedItemId : feedItemIds){
            system.debug('##FeedItemId: ' + feedItemId);
            
            ConnectApi.FeedItem feedItem = ConnectApi.ChatterFeeds.getFeedItem(null, feedItemId);
            //Get the feed item message segments
            List<ConnectApi.MessageSegment> messageSegments = feedItem.body.messageSegments;
            //For each segment in the feed item...
            for (ConnectApi.MessageSegment messageSegment : messageSegments) {
                //If the segment is a mention...
                if (messageSegment instanceof ConnectApi.MentionSegment) {
                    //Get the data for the mention segment from the ConnectApi
                    ConnectApi.MentionSegment mentionSegment = (ConnectApi.MentionSegment) messageSegment;
                    //Add the mentioned user to the mentionedUsersMap(userid, username)
                    system.debug('##  mentionSegment.record.id: ' + mentionSegment.record.id);
                    system.debug('##  mentionSegment.name: ' + mentionSegment.name);
                    if(mentionedUsersMap.containsKey(mentionSegment.record.id)) {
                        List<Id> ids = mentionedUsersMap.get(mentionSegment.record.id);
                        ids.add(feedItemId);
                        mentionedUsersMap.put(mentionSegment.record.id, ids);
                    }
                    else {
                        List<Id> ids = new List<Id>();
                        ids.add(feedItemId);
                        mentionedUsersMap.put(mentionSegment.record.id, ids);                    
                    }
                }
            }
        }
        //Get the mentioned user records
        datetime now = datetime.now();
        List<Out_Of_Office_Comment__c> comments = new List<Out_Of_Office_Comment__c>();
        List<User> mentionedUsers = [SELECT Id, Name, Out_of_Office_Message__c FROM User
                                     WHERE Id IN :mentionedUsersMap.keySet() AND Out_of_Office_Start_Date__c <= :now AND
                                     (Out_of_Office_End_Date__c >= :now OR Out_of_Office_End_Date__c = null)];
        for(User user : mentionedUsers) {
            if(user.Out_of_Office_Message__c != null) {
                system.debug('##OOO Message: ' + user.Out_of_Office_Message__c);
                
                List<Id> ids = mentionedUsersMap.get(user.Id);
                for(Id feedItemId : ids){
                    system.debug('##  Comment to feed: ' + feedItemId);
                    // This deos not allow us to post comment on other user's behave, so I will have to store the record.
                    //ConnectApi.ChatterFeeds.postComment(null, feedItemId, user.Name + ' - ' + user.Out_of_Office_Message__c);
                    Out_Of_Office_Comment__c comment = new Out_Of_Office_Comment__c();
                    comment.OwnerId = OOOAutoResponseId;
                    comment.Feed__c = feedItemId;
                    comment.UserId__c = user.Id;
                    comment.Comment__c = '[' + user.Name + '] - ' + user.Out_of_Office_Message__c;
                    comments.add(comment);
                }
            }
        }
        
        if(comments.size()> 0)
            insert comments;
    }
    
    public static void OOOAutoRespondFeedComments(Set<Id> commentIds){
        Map<String, List<Id>> mentionedUsersMap = new Map<String, List<Id>>();
        
        //For each FeedItem (post) being inserted...
        for(Id commentId: commentIds){
            system.debug('##CommentId: ' + commentId);
            ConnectApi.Comment comment = ConnectApi.ChatterFeeds.getComment(null, commentId);
            if(comment == null || comment.feedItem == null) continue;
            
            Id feedItemId = comment.feedItem.Id;
            
            //Get the comment message segments
            List<ConnectApi.MessageSegment> messageSegments = comment.body.messageSegments;
            //For each segment in the feed item...
            for (ConnectApi.MessageSegment messageSegment : messageSegments) {
                //If the segment is a mention...
                if (messageSegment instanceof ConnectApi.MentionSegment) {
                    //Get the data for the mention segment from the ConnectApi
                    ConnectApi.MentionSegment mentionSegment = (ConnectApi.MentionSegment) messageSegment;
                    //Add the mentioned user to the mentionedUsersMap(userid, username)
                    system.debug('##  mentionSegment.record.id: ' + mentionSegment.record.id);
                    system.debug('##  mentionSegment.name: ' + mentionSegment.name);
                    if(mentionedUsersMap.containsKey(mentionSegment.record.id)) {
                        List<Id> ids = mentionedUsersMap.get(mentionSegment.record.id);
                        ids.add(feedItemId);
                        mentionedUsersMap.put(mentionSegment.record.id, ids);
                    }
                    else {
                        List<Id> ids = new List<Id>();
                        ids.add(feedItemId);
                        mentionedUsersMap.put(mentionSegment.record.id, ids);                    
                    }
                }
            }
        }
        //Get the mentioned user records
        datetime now = datetime.now();
        List<Out_Of_Office_Comment__c> comments = new List<Out_Of_Office_Comment__c>();
        List<User> mentionedUsers = [SELECT Id, Name, Out_of_Office_Message__c FROM User
                                     WHERE Id IN :mentionedUsersMap.keySet() AND Out_of_Office_Start_Date__c <= :now AND
                                     (Out_of_Office_End_Date__c >= :now OR Out_of_Office_End_Date__c = null)];
        for(User user : mentionedUsers) {
            if(user.Out_of_Office_Message__c != null) {
                system.debug('##OOO Message: ' + user.Out_of_Office_Message__c);
                
                List<Id> ids = mentionedUsersMap.get(user.Id);
                for(Id feedItemId : ids){
                    system.debug('##  Comment to feed: ' + feedItemId);
                    // This deos not allow us to post comment on other user's behave, so I will have to store the record.
                    //ConnectApi.ChatterFeeds.postComment(null, feedItemId, user.Name + ' - ' + user.Out_of_Office_Message__c);
                    Out_Of_Office_Comment__c comment = new Out_Of_Office_Comment__c();
                    comment.OwnerId = OOOAutoResponseId;
                    comment.Feed__c = feedItemId;
                    comment.UserId__c = user.Id;
                    comment.Comment__c = '[' + user.Name + '] - ' + user.Out_of_Office_Message__c;
                    comments.add(comment);
                }
            }
        }
        
        if(comments.size()> 0)
            insert comments;
    }

	/**
	 * 	@description	:	This method is to add the user as the record follower
	 							1. Takes a record Id and a User Id as input and adds the User to follow the Chatter feed for the record 
	 								(if the record has Chatter feed enabled).  
 								2. There is a limit that a User can follow only 500 total records � 
 									be sure to check the limit before adding the User to the record.  
 								3. If already at the limit, send an email notice to the user who requested the change and to the User 
 									(if they are different people).  
 								4. The email notice should state that the user could not be added to the Meeting�s feed 
 									and that the user will need to stop following at least one other record 
 									and then manually be added to follow the Meeting�s feed.
	 * 
	 * 	@args			:	Set<String> String = User Id-Record Id
	 * 
	 * 	@return			:	void
	 * 
	 **/
	public static void AddFollower(Set<String> setUserIdsRecordIds) {
		
		//Check for the Set Size
		if(setUserIdsRecordIds == null || setUserIdsRecordIds.size() == 0)
			return;
		
		//Set to hold the User Ids and Record Ids
		Set<Id> userIds = new Set<Id>();
		Set<Id> recordIds = new Set<Id>();
		
		//Loop through the main set and get the User and record Ids
		for(String uniqueKey : setUserIdsRecordIds) {
			
			//Split by "-"
			List<String> pair = uniqueKey.split('-');
			
			//Check for the pair size and get the user Id and Record Id
			if(pair.size() == 2) {
				
				//Add in set
				userIds.add(pair[0]);
				recordIds.add(pair[1]);		
			}
		}
		
		//Create a Set to Hold the list of existing followors and Records
		Set<String> setExistingUserIdsRecordIds = new Set<String>();
		
		//Get the existingFeed Items related to these if any
		for(EntitySubscription eS : [Select SubscriberId, ParentId from EntitySubscription where SubscriberId IN: userIds AND ParentId IN: recordIds]) {
			
			//Create the unique Key and add in set
			setExistingUserIdsRecordIds.add(eS.SubscriberId + '-' + eS.ParentId);		
		}
		
		//Create a Map of User with the # of records he is following 
		Map<String, Integer> mapUsersWithFollowCount = new Map<String, Integer>();
		for(AggregateResult aR : [Select Count(Id) totalCount, SubscriberId sId from EntitySubscription where SubscriberId IN: userIds GROUP BY SubscriberId]) {
			
			//Get data from result
			String sId = String.valueOf(aR.get('sId'));
			Integer totalCount = Integer.valueOf(aR.get('totalCount'));
			
			//Add in map
			mapUsersWithFollowCount.put(sId, totalCount);
		}
		
		//Create a list fo subscription
		List<EntitySubscription> lstES = new List<EntitySubscription>();
		
		//Create a list of users to be notified for 500 follow limits
		Set<Id> usersExceedingLimits = new Set<Id>();
		
		//Loop through the main set and get the User and record Ids
		for(String uniqueKey : setUserIdsRecordIds) {
			
			//Dont do anything if user us already following the record
			if(setExistingUserIdsRecordIds.contains(uniqueKey))
				continue;
			
			//Split by "-"
			List<String> pair = uniqueKey.split('-');
			
			//Check for the pair size and get the user Id and Record Id
			if(pair.size() == 2) {
				
				//User Id
				String userId = pair[0];
				
				//Check if user is already following 500 records and can't follow this one
				//Add this user in a set to notify with this error
				if(mapUsersWithFollowCount.containsKey(userId) && mapUsersWithFollowCount.get(userId) == ChatterHelper.LIMIT_CHATTER_MAX_ENTITY_SUBSCRIPTION_RECORDS) {
					
					//Error	
					usersExceedingLimits.add(Id.valueOf(userId));	
				} else {
					
					//Add as a follower
					lstES.add(new EntitySubscription(SubscriberId = userId, Parentid = pair[1]));
				}
			}
		}
		
		//Check for the list size and insert in database
		if(lstES.size() > 0)
			insert lstES;
			
		//Send error email to Users
		if(usersExceedingLimits.size() > 0) {
			
			//Send error email
			usersExceedingLimits.add(UserInfo.getUserId());
			EmailHandler.sendEmail(usersExceedingLimits, 
										Label.ERROR_LIMIT_CHATTER_MAX_ENTITY_SUBSCRIPTION_RECORDS_EMAIL_SUBJECT, 
										Label.ERROR_LIMIT_CHATTER_MAX_ENTITY_SUBSCRIPTION_RECORDS_EMAIL_BODY);
		}
	}
	
	/**
	 * 	@description	:	This method is to remove the user as the record follower
	 							1. Takes a record Id and a User Id as input and removes the User from the Chatter feed for the record 
	 								(if the user is following the record).
	 * 
	 * 	@args			:	Set<String> String = User Id-Record Id
	 * 
	 * 	@return			:	void
	 * 
	 **/
	public static void RemoveFollower(Set<String> setUserIdsRecordIds) {
		
		//Check for the Set Size
		if(setUserIdsRecordIds == null || setUserIdsRecordIds.size() == 0)
			return;
		
		//Set to hold the User Ids and Record Ids
		Set<Id> userIds = new Set<Id>();
		Set<Id> recordIds = new Set<Id>();
		
		//Loop through the main set and get the User and record Ids
		for(String uniqueKey : setUserIdsRecordIds) {
			
			//Split by "-"
			List<String> pair = uniqueKey.split('-');
			
			//Check for the pair size and get the user Id and Record Id
			if(pair.size() == 2) {
				
				//Add in set
				userIds.add(pair[0]);
				recordIds.add(pair[1]);		
			}
		}
		
		//Create a Set to Hold the list of existing followors and Records
		Map<String, EntitySubscription> setExistingUserIdsRecordIds = new Map<String, EntitySubscription>();
		
		//Get the existingFeed Items related to these if any
		for(EntitySubscription eS : [Select SubscriberId, ParentId from EntitySubscription where SubscriberId IN: userIds AND ParentId IN: recordIds]) {
			
			//Create the unique Key and add in set
			setExistingUserIdsRecordIds.put(eS.SubscriberId + '-' + eS.ParentId, eS);		
		}
		
		//Create a list fo subscription tobe deleted
		List<EntitySubscription> lstES = new List<EntitySubscription>();
		
		//Loop through the main set and get the User and record Ids
		for(String uniqueKey : setUserIdsRecordIds) {
			
			//Add in list to be deleted if user us already following the record
			if(setExistingUserIdsRecordIds.containsKey(uniqueKey))
				lstES.add(setExistingUserIdsRecordIds.get(uniqueKey));
		}
		
		//Check for the list size and insert in database
		if(lstES.size() > 0)
			delete lstES;
	}
}