/**
 *  Desription      :   This class is Used to post the Chatter on the Parent Case, If any new email arrives from requester side.
 * 						This apex called by a process builder 
 * 
 *  Created By      :   Abhinav Sharma
 * 
 *  Created Date    :   01/24/2018
 * 
 *  Revision Logs   :   V1.0- App Support Update Release - Development
 * 						V1.1 - Modified By Abhinav Sharma - CR-20180427-12189 - Reduce the size of text posted on the Chatters - Now only 500 Characters will be posted to the Chatter.              
 **/
public class PostChatterOnCase {
    
    //Method invoke from the Process Builder - Update Case and Post Chatter If Requester Replied
    @InvocableMethod
    public static void postingChatterOnCase(List<String> CaseId) {
        
        //Set to hold the Ids
       	Set<String> caseIds = new Set<String>();
        
        //map to hold the Case with the Owner ids
        Map<Id, Id> mapCaseWithOwner = new map<Id, Id>();
        
        for(String c : CaseId) {
        	caseIds.add(c.split('<--Message-->')[0]);      
        }
        
        for(Case c : [Select Id, OwnerId From Case Where Id IN: caseIds ]) {
            mapCaseWithOwner.put(c.Id, c.OwnerId);    
        }
       
        for(String casId : CaseId) {
            
           String parentId =  casId.split('<--Message-->')[0];
           
           String Message = '';
           
           if(casId.split('<--Message-->')[1].length() > 500 )
          	  Message =   casId.split('<--Message-->')[1].subString(0, 500);
           else
              Message =   casId.split('<--Message-->')[1];
            
           String action =  casId.split('<--Action-->')[1];
           String textAddition = '';
           
           //Check for the Action string is exists in the Emails 
           if(String.isNotBlank(Message) && Message.contains('<--Action-->'))
           		Message = Message.split('<--Action-->')[0];
           
           if(action == '1')
              textAddition = 'Response Received from Stakeholder';
           if(action == '2')
              textAddition = 'Feedback Received from Stakeholder';           
          
           //String to hold the Message
            Message =  textAddition +  '\n' + Message + '\n\n' +  'Please go to the Emails Section for detailed threads... \n' + 'Thanks';
           
           //Posting Chatter to the case record
           //ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), parentId, ConnectApi.FeedElementType.FeedItem, Message);
    		
            ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
            ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
            ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
            ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
            
            messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
            
            if(mapCaseWithOwner.containskey(parentId) && String.valueOf(mapCaseWithOwner.get(parentId)).startsWith('005') ) {
                mentionSegmentInput.id = mapCaseWithOwner.get(parentId);
                messageBodyInput.messageSegments.add(mentionSegmentInput);
            }
            textSegmentInput.text = '\n'+Message;
            messageBodyInput.messageSegments.add(textSegmentInput);
            
            feedItemInput.body = messageBodyInput;
            feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
            feedItemInput.subjectId = parentId;
            
            ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItemInput);
        
        }
    }
}