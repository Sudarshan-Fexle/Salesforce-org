/*
    Purpose         :   Batch class to 
    
    Create By       :   Mahendra Swarnkar
    
    Created Date    :   04/28/2020
    
    Revision Log    :   V1.0 - Created - 04/28/2020 - CR-20200415-13948
                        V1.1 - Modified by - Abhianv Sharma - 06/03/2020 - Issue--CR13948--QA--00009811

*/
global without sharing class Batch_TokenUsedChatterOnAccount implements Database.Batchable<sObject>, Database.Stateful {

    public String queryStr;
    public Set<Id> setSiteTokenIds;
    public List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();
    public set<Id> setOfExecutedSiteProfileIds = new Set<Id>();

    global Batch_TokenUsedChatterOnAccount()
    {
        if (queryStr == null) {
            queryStr = 'Select Id, Contact__r.name, Contact__r.Account.Name, Contact__r.AccountId, Contact__r.Account.Research_Strategic_Leader__c, Contact__r.Account.Research_Strategic_Leader__r.Name From Site_Profile__c Where Token_s_Pending_For_Chatter__c = true AND Contact__c != null AND Contact__r.AccountId != null AND Contact__r.Account.Research_Strategic_Leader__c != null';
        }    
    }
    
    global Database.Querylocator start(Database.BatchableContext BC) 
    {
        return Database.getQueryLocator(queryStr);
    }
    
    global void execute(Database.BatchableContext BC, List<Site_Profile__c> scope) 
    {   
        //Set to hold the site profiles. 
        Set<Id> setProfileIds = new Set<Id>();
		
        //List to hold the site token that will be updated after the token is used in the chatter post. 
        List<Site_Token__c> siteTokensToBeUpdatedWithChatterPostedField = new List<Site_Token__c>();
	
        for(Site_Profile__c sP : (List<Site_Profile__c>)scope) {
            setProfileIds.add(sP.Id);
        }
         
        if(setProfileIds.size() > 0 ) {
        	
        	Map<Id, List<FiveTokenGroup>> mapOfContentDetails = completeSiteContentTokenDetails(setProfileIds);
			
            if(mapOfContentDetails != null && mapOfContentDetails.size() > 0 ) {
            	
                //for each site profile returned
                for(Site_Profile__c sP : Scope)
                {
                    String Message = '';
                    String MessageBold = '';
                    String Message3 = '';
                    String Message2 = '';   
                    
                    List<FiveTokenGroup> fiveTokenCollection = mapOfContentDetails.get(sP.Id);
                    
                    if(fiveTokenCollection == null || fiveTokenCollection.size() == 0)
                        continue;
                    
                    
                    for(FiveTokenGroup fv : fiveTokenCollection) {
                        
                        Boolean contentIdentified = false; 
                        
                        //String to hold the Message
                        Message = '\r\n '
                            +' Please be advised that ' + sP.Contact__r.Name + ' from ' + sP .Contact__r.Account.Name
                            +' recently used 5 tokens to access freemium content. The pages which were accessed were as follows:';
                        
                        MessageBold ='\n\n Please generate a lead for each token, then flag the site '+
                            ' token record with whether a lead was generated, and if not, the reason why. ';
                        
                        Message3 = '\n\n Thank you.';
                        
                        //String to hold the accountId.
                        String tokenManager = '';
                        
                        if(String.isNotBlank(sP.Contact__r.AccountId))
                            tokenManager = sP.Contact__r.AccountId;
                        
                        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
                        ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
                        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
                        ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
                        ConnectApi.TextSegmentInput textSegmentInput2 = new ConnectApi.TextSegmentInput();
                        ConnectApi.TextSegmentInput textSegmentInput3 = new ConnectApi.TextSegmentInput();
                        
                        ConnectApi.TextSegmentInput textSegmentInput4 = new ConnectApi.TextSegmentInput();
                        
                        ConnectApi.TextSegmentInput textSegmentInput5 = new ConnectApi.TextSegmentInput();
                        
                        //Start
                        ConnectApi.MarkupBeginSegmentInput markupBeginSegment;
                        ConnectApi.MarkupEndSegmentInput markupEndSegment; 
                        //End
                        
                        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
                        textSegmentInput.text = 'Hello';
                        //Mention user here
                        mentionSegmentInput.id = sP.Contact__r.Account.Research_Strategic_Leader__c;
                        messageBodyInput.messageSegments.add(mentionSegmentInput);
                        
                        markupBeginSegment = new ConnectApi.MarkupBeginSegmentInput();
                        markupBeginSegment.markupType = ConnectApi.MarkupType.Paragraph;
                        messageBodyInput.messageSegments.add(markupBeginSegment);
                        
                        textSegmentInput4.text = '&nbsp;';
                        messageBodyInput.messageSegments.add(textSegmentInput4);
                        
                        markupEndSegment = new ConnectApi.MarkupEndSegmentInput();
                        markupEndSegment.markupType = ConnectApi.MarkupType.Paragraph;
                        messageBodyInput.messageSegments.add(markupEndSegment);
                        
                        textSegmentInput2.text = '\n'+ Message +'\n';
                        messageBodyInput.messageSegments.add(textSegmentInput2);
                        
                        //Start
                        markupBeginSegment = new ConnectApi.MarkupBeginSegmentInput();
                        markupBeginSegment.markupType = ConnectApi.MarkupType.Paragraph;
                        messageBodyInput.messageSegments.add(markupBeginSegment);
                        
                        textSegmentInput4.text = '&nbsp;';
                        messageBodyInput.messageSegments.add(textSegmentInput4);
                        
                        markupEndSegment = new ConnectApi.MarkupEndSegmentInput();
                        markupEndSegment.markupType = ConnectApi.MarkupType.Paragraph;
                        messageBodyInput.messageSegments.add(markupEndSegment);
                        //End
                        
                        if(fv != null && fv.siteTokenDetails.size() > 0 && fv.siteTokenDetails.size() == 5) {
                            
                            contentIdentified = true; 
                            
                            for(SiteTokenDetails details : fv.siteTokendetails) {
                                
                                //Start
                                markupBeginSegment = new ConnectApi.MarkupBeginSegmentInput();
                                markupBeginSegment.markupType = ConnectApi.MarkupType.Paragraph;
                                messageBodyInput.messageSegments.add(markupBeginSegment);
                                
                                ConnectApi.TextSegmentInput textSegmentInput6 = new ConnectApi.TextSegmentInput();
                                textSegmentInput6.text =  details.tokenName;
                                
                                messageBodyInput.messageSegments.add(textSegmentInput6);   
                                
                                markupEndSegment = new ConnectApi.MarkupEndSegmentInput();
                                markupEndSegment.markupType = ConnectApi.MarkupType.Paragraph;
                                messageBodyInput.messageSegments.add(markupEndSegment);
                                //End
                                
                                siteTokensToBeUpdatedWithChatterPostedField.add(new Site_Token__c (Id = details.siteTokenId, Chatter_Posted_For_This_Token__c = true));
                            }
                        }
                        
                        //Check if the content is identified. 
                        if(!contentIdentified)
                            continue;
                        
                        //Start
                        markupBeginSegment = new ConnectApi.MarkupBeginSegmentInput();
                        markupBeginSegment.markupType = ConnectApi.MarkupType.Paragraph;
                        messageBodyInput.messageSegments.add(markupBeginSegment);
                        
                        textSegmentInput4.text = '&nbsp;';
                        messageBodyInput.messageSegments.add(textSegmentInput4);
                        
                        markupEndSegment = new ConnectApi.MarkupEndSegmentInput();
                        markupEndSegment.markupType = ConnectApi.MarkupType.Paragraph;
                        messageBodyInput.messageSegments.add(markupEndSegment);
                        //End
                        
                        
                        //Start For MessageBold 
                        markupBeginSegment = new ConnectApi.MarkupBeginSegmentInput();
                        markupBeginSegment.markupType = ConnectApi.MarkupType.Paragraph;
                        messageBodyInput.messageSegments.add(markupBeginSegment);
                        
                        markupBeginSegment = new ConnectApi.MarkupBeginSegmentInput();
                        markupBeginSegment.markupType = ConnectApi.MarkupType.Bold;
                        messageBodyInput.messageSegments.add(markupBeginSegment);
                        
                        
                        textSegmentInput.text = '\n'+ MessageBold +'\n' ;
                        messageBodyInput.messageSegments.add(textSegmentInput);
                        
                        
                        markupEndSegment = new ConnectApi.MarkupEndSegmentInput();
                        markupEndSegment.markupType = ConnectApi.MarkupType.Bold;
                        messageBodyInput.messageSegments.add(markupEndSegment);           
                        
                        markupEndSegment = new ConnectApi.MarkupEndSegmentInput();
                        markupEndSegment.markupType = ConnectApi.MarkupType.Paragraph;
                        messageBodyInput.messageSegments.add(markupEndSegment);
                        //End
                        
                        markupBeginSegment = new ConnectApi.MarkupBeginSegmentInput();
                        markupBeginSegment.markupType = ConnectApi.MarkupType.Paragraph;
                        messageBodyInput.messageSegments.add(markupBeginSegment);
                        
                        textSegmentInput4.text = '&nbsp;';
                        messageBodyInput.messageSegments.add(textSegmentInput4);
                        
                        markupEndSegment = new ConnectApi.MarkupEndSegmentInput();
                        markupEndSegment.markupType = ConnectApi.MarkupType.Paragraph;
                        messageBodyInput.messageSegments.add(markupEndSegment);
                        
                        //Start
                        markupBeginSegment = new ConnectApi.MarkupBeginSegmentInput();
                        markupBeginSegment.markupType = ConnectApi.MarkupType.Paragraph;
                        messageBodyInput.messageSegments.add(markupBeginSegment);
                        
                        textSegmentInput3.text = '\n'+ Message3 +'\n';
                        messageBodyInput.messageSegments.add(textSegmentInput3);
                        
                        
                        markupEndSegment = new ConnectApi.MarkupEndSegmentInput();
                        markupEndSegment.markupType = ConnectApi.MarkupType.Paragraph;
                        messageBodyInput.messageSegments.add(markupEndSegment);
                        
                        
                        feedItemInput.body = messageBodyInput;
                        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
                        feedItemInput.subjectId = tokenManager;
                        
                        ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(feedItemInput);
                        batchInputs.add(batchInput);
                    }
                }
            }
        }
        
        if(siteTokensToBeUpdatedWithChatterPostedField.size() > 0)
            update siteTokensToBeUpdatedWithChatterPostedField;   
    }
    
    //Finish method
    global void finish(Database.BatchableContext BC) {
        
        if (!test.isRunningTest() && batchInputs.size() > 0){
        	ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), batchInputs);
        }
    }
    
    
	//Method to get the site profile and it's related token and Content Details. 
    public static Map<Id, List<FiveTokenGroup>> completeSiteContentTokenDetails(Set<Id> setSiteProfileIds) {
        
        //Map to hold the Site Profiles with site tokens.
        Map<Id, List<FiveTokenGroup>> mapSiteProfileWithDetails = new  Map<Id, List<FiveTokenGroup>>();
        
		if(setSiteProfileIds != null && setSiteProfileIds.size() > 0) {
    		
            //Get all the token related to the site profiles. 
            for (Site_Profile__c sP : [Select Id, Contact__r.AccountId, Tokens_Used_YTD__c, 
                                            (Select Id, Site_Content__c From Site_Tokens__r Where Expiration_Date__c != null AND
                                            (Status__c = 'Active' OR Status__c = 'Expired') AND Expiration_Date__c = THIS_YEAR AND Chatter_Posted_For_This_Token__c = false Order By CreatedDate ASC) 
                                          	From Site_Profile__c  Where Id IN: setSiteProfileIds]) {
        		
                
                List<FiveTokenGroup> fiveTokenDetail = new List<FiveTokenGroup>();
            	if(sP.Site_Tokens__r != null && sP.Site_Tokens__r.size() > 0)  {
					
                   	List<SiteTokenDetails> listOfSiteTokenDetail = new List<SiteTokenDetails>();
                    integer i = 0;
                    
                    for(Site_Token__c sToken : sP.Site_Tokens__r) {
                        i++;
                        
                        String contentURL = 'Site Content: ' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + sToken.Site_Content__c + '\n';
                        String tokenURL = 'Site Token ' + i + ': ' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + sToken.Id;
                        
                        listOfSiteTokenDetail.add(new SiteTokenDetails(tokenURL, contentURL, sToken.Id ));
                        
                        if(i == 5){
                            fiveTokenDetail.add(new FiveTokenGroup(listOfSiteTokenDetail));
                            i = 0; 
                            listOfSiteTokenDetail = new List<SiteTokenDetails>();
                        }
                    }
                    
                    //Map to hold the site Token Details. 
                	mapSiteProfileWithDetails.put(sP.Id, fiveTokenDetail);
                    
                }
            }
        }
        return mapSiteProfileWithDetails;
    }
    
    public Class FiveTokenGroup {
        
        public List<SiteTokenDetails> siteTokenDetails;
        
        public FiveTokenGroup(List<SiteTokenDetails> siteTokenDetails) {
            this.siteTokenDetails = siteTokenDetails;
        }
    }
    
    public Class SiteTokenDetails {
            
        public String tokenName;
        public String contentName;
        public Id siteTokenId;
        
        public SiteTokenDetails(String tokenName, String contentName, Id siteTokenId){
            this.tokenName = tokenName;
            this.contentName = contentName;
            this.siteTokenId = siteTokenId;
        }
    }
}