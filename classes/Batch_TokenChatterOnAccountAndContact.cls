/**
 *  Description     :   Class is used to post the chatter on the records (Institution or Site profile).
 * 						
 *  Design Notes	:	Couldn't use a trigger because guest Site Tokens are created by Site User.
 * 						Site Users are 'Guests' which have no access to chatter API.
 *
 *  Created By      :   Victor Hanson
 *
 *  Created Date    :   08/27/2019
 *
 *  Revision Logs   :   V_1.0 - Created - CR-20190827-13290
 * 						V_1.1 - Modified - 11/14/2019 - CR-20191029-13472 - Victor Hanson - Updated so the DateTime returned from is in proper GMT-24 hr format
 *                      
 **/
global class Batch_TokenChatterOnAccountAndContact implements Database.Batchable<sObject>, Schedulable {
	
    public String query;
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        if (query == null) {
            String strLastTokenCheckDate = DateTime.now().addHours(-1).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
            query = 'SELECT Id, Contact__c, Contact__r.Name, Contact__r.AccountId,' +
                'Contact__r.Account.Tokens_Available__c, Contact__r.Account.Token_Monitor__c,' +
                'Contact__r.Account.Account_Formal_Name__c,' +
                'Tokens_Available__c ' +
                'FROM Site_Profile__c ' +
                'WHERE Id IN (SELECT Site_Profile__c FROM Site_Token__c WHERE CreatedDate >= ' + strLastTokenCheckDate + ') ' +
                ' AND (Tokens_Available__c = 0 OR Contact__r.Account.Tokens_Available__c = 0)';
        }
        system.debug('@@Query:' + query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        
        //for each site profile returned
        for(Site_Profile__c sProfile : (List<Site_Profile__c>)scope)
        {
            //String to hold the Manager.
            String tokenManager = '';
            
            if(String.isNotBlank(sProfile.Contact__r.Account.Token_Monitor__c))
                tokenManager = sProfile.Contact__r.Account.Token_Monitor__c;
            
            //Check for the Site Profile if we have no token left. 
            if(sProfile.Tokens_Available__c == 0 )
            {
                
                //String to hold the Message
                String Message = ' ' + sProfile.Contact__r.Name +  ' from ' +  sProfile.Contact__r.Account.Account_Formal_Name__c 
                    + ' has used the last of their tokens.  Might be time to reach out and see if they found helpful. \n Thanks';
                
                //Method to post actual chatters.
                placeChatter(tokenManager, sProfile.Contact__c, Message);  
            }
            
            
            //Check for the Site Profile if we have no token left. 
            if(String.isNotBlank(sProfile.Contact__r.AccountId)  && sProfile.Contact__r.Account.Tokens_Available__c == 0 ) {
                
                //String to hold the Message
                String Message = ' ' + sProfile.Contact__r.Account.Account_Formal_Name__c 
                    + ' has used up their tokens for the entire institution.  Might be time to reach out and see if they found helpful. \n Thanks';
                
                //Method to post actual chatters.
                placeChatter(tokenManager, sProfile.Contact__r.AccountId, Message);  
            }
        }
    }
    
    global void finish(Database.BatchableContext BC) {
    }
    
    //insert chatter
    public static void placeChatter(String tokenMonitor, String parentId, String body) {

        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        
        if(String.isNotBlank(tokenMonitor)) {

            mentionSegmentInput.id = tokenMonitor;
            messageBodyInput.messageSegments.add(mentionSegmentInput);
        }

        textSegmentInput.text = body;
        messageBodyInput.messageSegments.add(textSegmentInput);
        feedItemInput.body = messageBodyInput;
        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
        feedItemInput.subjectId = parentId;
        
        if (!test.isRunningTest())
        	ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItemInput);
    }
    
    //schedule job
    public void execute(SchedulableContext ctx) {
        // execute the job
        Database.executeBatch(new Batch_TokenChatterOnAccountAndContact(), 10);
    }
}