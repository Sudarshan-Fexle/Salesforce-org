/** 
    *  Purpose         :  Helper class for Batch_CatalystRecipientBatchReceived
    * 
    *  Created By      :  Shalu Sharma
    *
    *  Created Date    :  09/16/2021
    *
    *  Revision Logs   :  V_1.0 - Created - CR-20210824-15374
    *			  V_1.1 - Modified By - 10/18/2021 - Subhash Garhwal - CR-20211017-15521
    *
    **/
global class Batch_CatalystRecipientBatchReceived extends batchjobsch.BatchJobBase implements Database.Batchable<sObject> 
{
    global Database.QueryLocator start(Database.BatchableContext BC)
    {  
        String query = 'Select Id, Name, Data_Posted_Quantity__c, Data_Posted_Date_Time__c, Production_Tracking__c, Production_Tracking__r.Name From Recipient_Batch__c Where Production_Tracking__c != null AND (Data_Posted_Quantity__c = null OR (Data_Posted_Quantity__c != null AND Data_Posted_Quantity__c <= 200)) AND Data_Posted_Date_Time__c != null AND Is_Email_Or_Chatter_Sent__c != true';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Recipient_Batch__c> recipientBatches)
    { 
        
        Map<Id, Recipient_Batch__c> sendEmailOnRecipientBatches = new Map<Id, Recipient_Batch__c>();
        try{
            //RecipientBatchTriggerHelper.sendEmailForRecipientBatchReceived(recipientBatches, null);
            Map<Id, Production_Tracking__c> mapOfProdTrackings = new Map<Id, Production_Tracking__c>();
            
            //loop over newly created/Updated recipient batches
            for(Recipient_Batch__c recipientBatch : recipientBatches){
                
                //to calculate how many hours spent after data posted on batch
                Integer hoursDiff = Integer.valueOf((System.now().getTime() - (recipientBatch.Data_Posted_Date_Time__c != null ? recipientBatch.Data_Posted_Date_Time__c.getTime() : System.now().getTime()))/(1000*60*60));
                
                if(recipientBatch.Data_Posted_Quantity__c <= 200 && hoursDiff > 24 )
                {
                    //set PT id
                    mapOfProdTrackings.put(recipientBatch.Production_Tracking__c, new Production_Tracking__c()); 
                    sendEmailOnRecipientBatches.put(recipientBatch.Id, recipientBatch);
                }
            }
            
            //check set size
            if(mapOfProdTrackings.size() > 0 && mapOfProdTrackings.keySet().size() > 0){
                
                List<Recipient_Batch__c> recipientBatchToBeUpdate = new List<Recipient_Batch__c>();
                
                String currentOrgLink = URL.getSalesforceBaseUrl().toExternalForm();
                //Modified By - 10/18/2021 - Subhash Garhwal - CR-20211017-15521 - Added School__c,Program__c in Query
                mapOfProdTrackings = new Map<Id, Production_Tracking__c>([Select Id, Name, Print_Production_Manager__c, JT_Project_Manager__c,School__c,Program__c From Production_Tracking__c Where Id IN :mapOfProdTrackings.keySet()]);
                
                List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
                for(Recipient_Batch__c recBatch: sendEmailOnRecipientBatches.values()){
                    
                    recBatch.Is_Email_Or_Chatter_Sent__c = true;
                    
                    recipientBatchToBeUpdate.add(recBatch);
                    
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
                    RecipientBatchTriggerHelper.placeChatterOnRecord(setOfFailedEmailRecpBatchIds);
                }
                
                if(recipientBatchToBeUpdate.size() > 0){
                    Util.BypassAllTriggers = true;
                    Update recipientBatchToBeUpdate;
                    Util.BypassAllTriggers = false;
                }
            }
        } catch(Exception ex) {
            System.debug('#EX '+ ex.getMessage() + ' -- ' +ex.getLineNumber() +' -- '+ ex.getStackTraceString());
            if(ex.getMessage().toUpperCase().contains('EMAIL') || ex.getMessage().toUpperCase().contains('MAIL')){
                if(sendEmailOnRecipientBatches.size() > 0){
                    RecipientBatchTriggerHelper.placeChatterOnRecord(sendEmailOnRecipientBatches.keyset());
                }           
            }
        }
    }
    
    global void finish(Database.BatchableContext BC)
    {
    }
}