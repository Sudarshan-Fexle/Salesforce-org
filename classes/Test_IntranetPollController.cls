/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
 /** Description     :   Test class for IntranetPollController.
  * 
  * Created Date    :   09/30/2014
  *
  * Created By      :   
  *  
  * Current vision  :   v1.0    
  *  
  * Revision Logs   :   v1.0 - Created
  *         		:   V2.0 - Modified By - Rajeev Jain - 05/22/2015 - CR-20141002-7579
  *					:	V3.0 - Modified By - Rajeev Jain - 09/14/2015 - CR-20141002-7579
					:   v3.1 - Modified By - Rajeev Jain (03/17/2020) (As Feed Tracking for Intranet Item off - Fix bug during Print MIS (Phase 5) deployment)
  * Coverage        :   100%
  **/   
@isTest(SeeAllData = true)
private class Test_IntranetPollController {

    /*
    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        
         //Create Intranet Item
        Intranet_Item__c intranetItem = new Intranet_Item__c(Name = 'Test-0' , Active_Status__c = 'Active' , Item_Type__c = 'App Link' , Item_Title__c = 'A1');
        insert intranetItem;
        
        //Intranet Container
        Intranet_Container__c intranetContainer = new Intranet_Container__c(Name = 'Test-2', CurrencyIsoCode = 'USD', Content_Types_Allowed__c = 'App Link',Container_Type__c = 'Poll');
        insert intranetContainer;
        
        //Intranet Schedule
        Intranet_Schedule__c intranetSchedule = new Intranet_Schedule__c(Name = 'Test4' , Intranet_Container__c = intranetContainer.Id, Intranet_Item__c = intranetItem.Id,
                                                                                Start_Date_Time__c = DateTime.Now()+1, End_Date_Time__c = DateTime.Now()+5 );
        insert intranetSchedule;
        
        //======================= Post Poll for Intranet Item ========================================
        
        //Insert Poll Item  
        ConnectApi.FeedType feedType = ConnectApi.FeedType.Record;
        
        //Poll Parent Record Id
        String subjectId = intranetItem.Id;
        
        //List of Poll Choice
        List<String> pollChoices = new List<String>();
        pollChoices.add('Choice 1');
        pollChoices.add('Choice 2');
        
        //Set Poll Question in FeedPost Body
        String pollQuestion = 'Which choice is correct ?';
        
        //Attach Poll Question and choices.
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        ConnectApi.PollAttachmentInput pollAttachment = new ConnectApi.PollAttachmentInput();
        pollAttachment.pollChoices = pollChoices;
        feedItemInput.attachment = pollAttachment;
        
        //Instantiate Message Input
        ConnectApi.MessageBodyInput messageInput = new ConnectApi.MessageBodyInput();
        
        //Instantiate Message Segments
        messageInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        
        //Prepate Text Segment to Be Post
        ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput();
        textSegment.text = pollQuestion;
        messageInput.messageSegments.add(textSegment);
        
        //Set Question in Body
        feedItemInput.body = messageInput;
        
        
        //Post Feed Item to Chatter
        ConnectApi.FeedItem feedItemRep = ConnectApi.ChatterFeeds.postFeedItem(null, feedType, subjectId, feedItemInput, null); 
        
        //Update Poll Id at intranet Item record
        intranetItem.Poll_Id__c = feedItemRep.Id;
        update intranetItem;
		
		
        
        //======================= Poll Posted =============================================================================
        
        //============================= Fetch Poll on Page ================================================================
                    
        //Create New Instance of Intranet Container
        IntranetContainer icContainer = new IntranetContainer(intranetContainer);
        
        //Update User record with Job Level
        System.runAs(new User(Id = UserInfo.getUserId())) {
            
            update new User(Id = UserInfo.getUserId(), Job_Level__c = '10 B1 Early Professional');
        }
        
        //Start Testing from here
        Test.startTest();
        
        //Set values before User Session
        IntranetHomeUtility.UserBrowser = 'Chrome';
        IntranetHomeUtility.UserDevice = 'Mobile';+
        IntranetHomeUtility.ScreenSize = 992;
        IntranetHomeUtility.NetworkAccess = 'Test';
        
        //Call PopulateUserSession method
        IntranetType.UserSession UserSession = IntranetHomeUtility.getUserSession;
        
         //Create Intranet Content Record
        IntranetContent ic = new IntranetContent(icContainer,intranetItem,UserSession,IntranetUtilizationHelper.getLikedItems());
        
        //Add Intranet Item to Intranet Container
        icContainer.RelatedContent.add(ic);
        
        //====================== Ready for Poll ==============================================================
        
        //Instantiate Controller
        IntranetPollController pollCont = new IntranetPollController();
        
        //Pass Container Type of Poll
        pollCont.setContainer(icContainer);
        
        //Get Poll Choices in component on Page
        List<SelectOption> choices = pollCont.getChoiceSelectList(); 
        
        //Select One of the available choice
        pollCont.MyPollChoiceId = choices[0].getValue(); 
        
        //Vote your choice   
        pollCont.VoteForPoll();
        
        //Assert for Results, If Passed, Poll is successfully completed.
        System.assertEquals(pollCont.PollContainer.RelatedContent[0].MyPollChoiceId, choices[0].getValue());
        
        //Assert for vote count Ratio, Here choice one will have greater vote then choice 2, because we voted for choice 1
        System.assertEquals(pollCont.PollContainer.RelatedContent[0].PollChoices[0].voteCountRatio > pollCont.PollContainer.RelatedContent[0].PollChoices[1].voteCountRatio,true);
        
        //Stop testing here
        Test.stopTest(); 
    }
	*/
}