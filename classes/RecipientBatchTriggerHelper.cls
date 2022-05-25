/** 
    *  Purpose         :  Helper class for RecipientBatch_Trigger trigger
    * 
    *  Created By      :  Shalu Sharma
    *
    *  Created Date    :  09/16/2021
    *
    *  Revision Logs   :  V_1.0 - Created - CR-20210824-15374
    * 			  V_1.1 - Modified By - 10/18/2021 - Subhash Garhwal - CR-20211017-15521
    *
    **/
public without sharing class RecipientBatchTriggerHelper {
    
   /**
    *  @description    :  Method to check if future is running from CPQ Contracted future job and bypass Subscription trigger if it is running and call a schduler to perform all the updates.
    *
    *  @args           :  List<SBQQ__Subscription>   
    *
    *  @return         :  void
    *
    *  @revision Log   :  V_1.0 - Created - 03/05/2019 - Subhash Garhwal - CR-20181019-12685
    * 			  V_1.1 - Modified By - 10/18/2021 - Subhash Garhwal - CR-20211017-15521
    * 
    **/
    public static void sendEmailForRecipientBatchReceived(List<Recipient_Batch__c> recipientBatches, Map<Id, Recipient_Batch__c> mapOldRecipientBatches) {
        
        Map<Id, Recipient_Batch__c> sendEmailOnRecipientBatches = new Map<Id, Recipient_Batch__c>();
        
        try{
            Map<Id, Production_Tracking__c> mapOfProdTrackings = new Map<Id, Production_Tracking__c>();
            
            //loop over newly created/Updated recipient batches
            for(Recipient_Batch__c recipientBatch : recipientBatches){
                
                //to calculate how many hours spent after data posted on batch
                Integer hoursDiff = Integer.valueOf((System.now().getTime() - (recipientBatch.Data_Posted_Date_Time__c != null ? recipientBatch.Data_Posted_Date_Time__c.getTime() : System.now().getTime()))/(1000*60*60));
                
                if(
                    recipientBatch.Production_Tracking__c != null 
                    && !recipientBatch.Is_Email_Or_Chatter_Sent__c
                    && (recipientBatch.Data_Posted_Date_Time__c != null || recipientBatch.Data_Posted_Quantity__c != null) &&
                    ((recipientBatch.Data_Posted_Quantity__c > 200 && hoursDiff < 24) 
                     || (recipientBatch.Data_Posted_Quantity__c > 200 && hoursDiff > 24) 
                     || (recipientBatch.Data_Posted_Quantity__c <= 200 && hoursDiff > 24)                     
                    )
                    && (mapOldRecipientBatches == null || 
                        (mapOldRecipientBatches != null 
                         && (recipientBatch.Data_Posted_Quantity__c != mapOldRecipientBatches.get(recipientBatch.Id).Data_Posted_Quantity__c 
                             || recipientBatch.Data_Posted_Date_Time__c != mapOldRecipientBatches.get(recipientBatch.Id).Data_Posted_Date_Time__c
                            )
                        ) 
                       )
                ){
                    //set PT id
                    mapOfProdTrackings.put(recipientBatch.Production_Tracking__c, new Production_Tracking__c()); 
                    sendEmailOnRecipientBatches.put(recipientBatch.Id, recipientBatch);
                }
            }
            
            //check set size
            if(mapOfProdTrackings.size() > 0 && mapOfProdTrackings.keySet().size() > 0){
                
                Set<Id> setRecipientBatchIds = new Set<Id>();
                
                String currentOrgLink = URL.getSalesforceBaseUrl().toExternalForm();
                //Modified By - 10/18/2021 - Subhash Garhwal - CR-20211017-15521 - Added School__c,Program__c in Query
                mapOfProdTrackings = new Map<Id, Production_Tracking__c>([Select Id, Name, Print_Production_Manager__c, JT_Project_Manager__c,School__c,Program__c From Production_Tracking__c Where Id IN :mapOfProdTrackings.keySet()]);
                
                List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
                for(Recipient_Batch__c recBatch: sendEmailOnRecipientBatches.values()){
                    
                    setRecipientBatchIds.add(recBatch.Id);
                    
                    Production_Tracking__c prodTrack = mapOfProdTrackings.get(recBatch.Production_Tracking__c);
                    
                    List<String> toAddresses = new List<String>();
                    toAddresses.add(Label.Xmpie_Support_Mail_Address);
                    
                    if(prodTrack.Print_Production_Manager__c != null && !toAddresses.contains(prodTrack.Print_Production_Manager__c))
                        toAddresses.add(prodTrack.Print_Production_Manager__c);
                    
                    if(prodTrack.JT_Project_Manager__c != null && !toAddresses.contains(prodTrack.JT_Project_Manager__c))
                        toAddresses.add(prodTrack.JT_Project_Manager__c);
                    
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setToAddresses(toAddresses);  
                    //Modified By - 10/18/2021 - Subhash Garhwal - CR-20211017-15521 - Start here
                    mail.setSubject('Records are available for this campaign: ' + prodTrack.School__c + ' ' + prodTrack.Program__c);
                    
                    String body = '<p>Team,</p><p></p>'+
                                  '<p>Records are available for this campaign: ' + prodTrack.School__c + ' ' +prodTrack.Program__c+'</p><p></p>'+
                                  '<p> Please click below to review the Production Tracking record:</p>'+
                                  '<p> Record Link: <a href="'+currentOrgLink+'/'+prodTrack.Id+'">'+prodTrack.Name+'</a></p><p></p>'+
                                  '<p> The details are below:</p>'+
                                  '<p> Production Tracking Name: '+prodTrack.Name+'</p>'+
                                  '<p> Data Posted Date/Time: '+recBatch.Data_Posted_Date_Time__c.formatLong()+'</p>'+
                                  '<p> Data Posted Quantity: '+recBatch.Data_Posted_Quantity__c+'</p>';
                    
                    //Modified By - 10/18/2021 - Subhash Garhwal - CR-20211017-15521 - end here
                    
                    mail.setHtmlBody(body);
                    
                    mails.add(mail);
                    
                }
                
                //List<Messaging.SendEmailResult> sentEmailResults = Messaging.sendEmail(mails);
                
                Set<Id> setOfFailedEmailRecpBatchIds = new Set<Id>();
                
                for(Messaging.SendEmailResult result : Messaging.sendEmail(mails)){
                    
                    if(!result.isSuccess()){
                        //System.assert(false, 'My Error:-- '+result.getErrors()[0].getMessage());
                        setOfFailedEmailRecpBatchIds.add(Id.valueOf(result.getErrors()[0].getTargetObjectId()));
                    }
                }
                
                if(setOfFailedEmailRecpBatchIds.size() > 0){
                    placeChatterOnRecord(setOfFailedEmailRecpBatchIds);
                }
                
                if(setRecipientBatchIds.size() > 0){
                    markChatterEmailFieldTrue(setRecipientBatchIds);
                }
            }
        } catch(Exception ex) {
            System.debug('#EX '+ ex.getMessage() + ' -- ' +ex.getLineNumber() +' -- '+ ex.getStackTraceString());
            if(ex.getMessage().toUpperCase().contains('EMAIL') || ex.getMessage().toUpperCase().contains('MAIL')){
                if(sendEmailOnRecipientBatches.size() > 0){
                    placeChatterOnRecord(sendEmailOnRecipientBatches.keyset());
                }           
            }
        }        
    }
    
    @future
    public static void markChatterEmailFieldTrue(Set<Id> setOfRecpBatchIds) {
        
        List<Recipient_Batch__c> recipientBatchToBeUpdate = new List<Recipient_Batch__c>();
        
        for(Id repBatchId : setOfRecpBatchIds){
            recipientBatchToBeUpdate.add(new Recipient_Batch__c(Id = repBatchId, Is_Email_Or_Chatter_Sent__c = true));
        }
        
        if(recipientBatchToBeUpdate.size() > 0){
            Util.BypassAllTriggers = true;
            Update recipientBatchToBeUpdate;
            Util.BypassAllTriggers = false;
        }
    }
    
   /**
    *  @description    :  Method to check if future is running from CPQ Contracted future job and bypass Subscription trigger if it is running and call a schduler to perform all the updates.
    *
    *  @args           :  List<SBQQ__Subscription>   
    *
    *  @return         :   void
    *
    *  @revision Log   :   V_1.0 - Created - 03/05/2019 - Subhash Garhwal - CR-20181019-12685
    * 
    **/
    public static void placeChatterOnRecord(Set<Id> setOfFailedEmailRecpBatchIds) {
        
        Id chatterReciverId = [Select Id from User Where Username =: Label.Recipient_Batch_Chatter_Receiver]?.Id;
        
        // Bulk post to the Contract feeds.
        List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();
        
        for(Id recpBatchId : setOfFailedEmailRecpBatchIds){
            
            //to place chatter create a feed item input instance
            ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
            ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
            ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
            
            messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
            
            ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
            mentionSegmentInput.id = chatterReciverId;
            messageBodyInput.messageSegments.add(mentionSegmentInput);
            
            // chatter body
            String postBody = '\n\nHi,\n The email notification is not sent for this recipient batch record.\nThanks\n';
            
            textSegmentInput.text = postBody;
            messageBodyInput.messageSegments.add(textSegmentInput);
            feedItemInput.body = messageBodyInput;
            feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
            
            //post chatter on Contract record
            feedItemInput.subjectId = recpBatchId; 
            
            //to hold all the chatter at a time so that chatter can be placed in single go 
            ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(feedItemInput);
            batchInputs.add(batchInput);
            
        }
        //Post chatter to the Contract Records
        if(batchInputs.size() > 0){
            ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), batchInputs);
        }
    }
}