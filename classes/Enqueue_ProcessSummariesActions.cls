public class Enqueue_ProcessSummariesActions implements Queueable {
    
    //Set to hold the Deployment Tracks. 
    Id deploymentTrackId;
    String processName;
    
    public Enqueue_ProcessSummariesActions(Id deploymentTrackId, String processName) {
        this.deploymentTrackId = deploymentTrackId;
        this.processName = processName;
    }
	    
    public void execute(QueueableContext context) {
    
		//Check if the Process Name Is backSync_PackageRetrival, call Retrival class. 
        if(processName == 'backSync_PackageRetrival')  {
			
            AutomatedRetrivalForBackSync.retrieveForBackSyncDeployment(deploymentTrackId); 
        }
        
        //Check if the Process Name Is backSync_PackageRetrival, call Retrival class. 
        if(processName == 'backSync_PackageValidation')  {
			
            AutomatedValidationForBackSync.doValidation(deploymentTrackId); 
        }
        
        if(processName == 'backSync_PackageDeployment') {
            AutomatedDeploymentForBackSync.doDeployment(deploymentTrackId);
        }
        
        if(processName == 'backSync_TargetBackup'){
            AutomatedValidationForBackSync.runTargetBackup(deploymentTrackId);
            
            //This Method will place the chatter on the Deployment Track. 
            placeChatterForValidationConfirmation(deploymentTrackId);
        }
    }
    
    public void placeChatterForValidationConfirmation(String deployemntTrackId){
    	
        String message1 = 'This Deployment Track has been validated successfully, Please review and complete the deployment.';
        String message2 = 'One-click URL:- ' + URL.getSalesforceBaseUrl().toExternalForm() + '/apex/DeploymentWizard?deploymentId=' + deployemntTrackId;
        
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
      	ConnectApi.MarkupBeginSegmentInput markupBeginSegment;
        ConnectApi.MarkupEndSegmentInput markupEndSegment; 
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();

        ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
        ConnectApi.TextSegmentInput textSegmentInput1 = new ConnectApi.TextSegmentInput();
     	ConnectApi.TextSegmentInput textSegmentInput2 = new ConnectApi.TextSegmentInput();
     	ConnectApi.TextSegmentInput textSegmentInput3= new ConnectApi.TextSegmentInput();
        ConnectApi.TextSegmentInput textSegmentInput4= new ConnectApi.TextSegmentInput();
        ConnectApi.TextSegmentInput textSegmentInput5= new ConnectApi.TextSegmentInput();

     
        //Adding User. 
        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        for(GroupMember gP : [Select Id, GroupId, UserOrGroupId From GroupMember Where Group.Developername = 'Back_Sync_Deployment_Chatter_Receiver']){
        	
            mentionSegmentInput = new ConnectApi.MentionSegmentInput();
			mentionSegmentInput.id =  gP.UserOrGroupId;
              
            messageBodyInput.messageSegments.add(mentionSegmentInput);    
        }
        
        //=================  ====================================

        markupBeginSegment = new ConnectApi.MarkupBeginSegmentInput();
        markupBeginSegment.markupType = ConnectApi.MarkupType.Paragraph;
        messageBodyInput.messageSegments.add(markupBeginSegment);
        
        textSegmentInput4.text = '&nbsp';
        messageBodyInput.messageSegments.add(textSegmentInput4);
        
        markupEndSegment = new ConnectApi.MarkupEndSegmentInput();
		markupEndSegment.markupType = ConnectApi.MarkupType.Paragraph;
        
        messageBodyInput.messageSegments.add(markupEndSegment);
        //=====================================================
        
        
        
        markupBeginSegment = new ConnectApi.MarkupBeginSegmentInput();
        markupBeginSegment.markupType = ConnectApi.MarkupType.Bold;
        
        
        markupEndSegment = new ConnectApi.MarkupEndSegmentInput();
        markupEndSegment.markupType = ConnectApi.MarkupType.Bold;
        
        //First Message Printed. === Started
        messageBodyInput.messageSegments.add(markupBeginSegment);
        
        textSegmentInput.text = '\n'+message1;
        messageBodyInput.messageSegments.add(textSegmentInput);
        
        messageBodyInput.messageSegments.add(markupEndSegment);
        //First Message Printed. === ENDED
        //
       	markupBeginSegment = new ConnectApi.MarkupBeginSegmentInput();
        markupBeginSegment.markupType = ConnectApi.MarkupType.Paragraph;
        messageBodyInput.messageSegments.add(markupBeginSegment);
        
        textSegmentInput3.text = '&nbsp';
        messageBodyInput.messageSegments.add(textSegmentInput3);
        
        markupEndSegment = new ConnectApi.MarkupEndSegmentInput();
		markupEndSegment.markupType = ConnectApi.MarkupType.Paragraph;
        
        messageBodyInput.messageSegments.add(markupEndSegment);
        
        markupBeginSegment = new ConnectApi.MarkupBeginSegmentInput();
        markupBeginSegment.markupType = ConnectApi.MarkupType.Paragraph;
        messageBodyInput.messageSegments.add(markupBeginSegment);
        
        textSegmentInput1.text = '\n'+message2;
        messageBodyInput.messageSegments.add(textSegmentInput1);
        
        markupEndSegment = new ConnectApi.MarkupEndSegmentInput();
		markupEndSegment.markupType = ConnectApi.MarkupType.Paragraph;
        
        messageBodyInput.messageSegments.add(markupEndSegment);
        
        //=====================================================

        markupBeginSegment = new ConnectApi.MarkupBeginSegmentInput();
        markupBeginSegment.markupType = ConnectApi.MarkupType.Paragraph;
        messageBodyInput.messageSegments.add(markupBeginSegment);
        
        textSegmentInput5.text = '&nbsp';
        messageBodyInput.messageSegments.add(textSegmentInput5);
        
        markupEndSegment = new ConnectApi.MarkupEndSegmentInput();
		markupEndSegment.markupType = ConnectApi.MarkupType.Paragraph;
        
        messageBodyInput.messageSegments.add(markupEndSegment);
        //=====================================================
        
        textSegmentInput2.text = 'Thanks!';
        messageBodyInput.messageSegments.add(textSegmentInput2);
        
        
        feedItemInput.body = messageBodyInput;
        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
        feedItemInput.subjectId = deployemntTrackId;
		
		if(!Test.isrunningTest()){
			ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItemInput);
		}
			

    }
}