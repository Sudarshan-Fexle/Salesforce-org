/**
 *   Purpose         :	This trigger to handle all the processing for Attachment object.
 *               
 *   Created By      :	
 *   
 *   Created Date    :	
 *   
 *   Revision Logs   :	V_1.0 - Created
 * 			V1.1 - Modified By - Abhinav Sharma - 07/07/2014 - CR-20140618-5849 - Catch DML errors in triggers to reduce exception emails to SFAdmin
 *			V1.2 - Abhinav Sharma - 09/01/2016 - CR-20160224-9640
 *			V1.3 - Subhash Garhwal - 05/11/2017 - CR-20170403-10807
 *			V1.4 - Modified By - Subhash Garhwal - 09/27/2017 - CR-20170926-11418 -  Added the Util.areTriggersOnThisObjectBypassed flag.
 *			V1.5 - Commented By - Mahendra Swarnkar - 03/05/2020 - CR-20200217-13756
 *
**/
trigger CreateContractDocument on Attachment (after insert, before insert, before delete) {
    
    //return immediately if method returns true	
   if(Util.areTriggersOnThisObjectBypassed('Attachment')) return;

    try {
        
        //Bypass trigger logic if Util.byPassAllTriggers = true
        if (Util.BypassAllTriggers) 
            return;
    
    	//Checking for the event type
        if (trigger.isBefore) {
            
            //Checking for the request type
            if (trigger.isInsert) {
                
                // CR-20120806-1297
                AttachmentTriggerHelper.restrictMailingCampaignAttachmentToPDF(trigger.new);
            
            }
            
            // CR-2083
            if (trigger.isDelete) {
            	
                //Calling helper class method
                //AttachmentTriggerHelper.hasPurchOrPymtRequestDoc(trigger.new, trigger.oldMap, trigger.isDelete);
            }
        }
        
        //Checking for the event types
        if (trigger.isAfter) {
            
            //Checking for the request type
            if (trigger.isInsert) {
                
                //Added By - Abhinav Sharma - 09/01/2016 - CR-20160224-9640
                //Start from here
                //Calling helper method for granding additional sharing on uploaded ContentVersion File
                //Commented by Mahendra Swarnkar - 03/05/2020 - CR-20200217-13756
                //AttachmentTriggerHelper.grantAdditionalSharingOnFiles(Trigger.new);
                //upto here
                
                //Subhash Garhwal - 05/11/2017 - CR-20170403-10807
                AttachmentTriggerHelper.converAttachmentToFile(Trigger.new);
                
                // CR-2083
               // AttachmentTriggerHelper.1(trigger.new, trigger.oldMap, trigger.isDelete);
                
                Map<Id,List<Attachment>> attachmentsMap = new Map<Id,List<Attachment>>();
                Map<Id,Attachment> attachments = new Map<Id,Attachment>();
                
                for( Attachment attachment : Trigger.new ) {
                    if( ( attachment.ParentId == null ) ||
                        ( !attachment.Name.contains('- signed') ) ) {
                        continue;
                    }
                    
                    List<Attachment> curAttachments = attachmentsMap.get(attachment.ParentId);
                    if( curAttachments == null ) {
                        curAttachments = new List<Attachment>();
                        attachmentsMap.put(attachment.ParentId, curAttachments);
                    }
                    curAttachments.add(attachment);
                    
                    attachments.put(attachment.Id,attachment);
                }
                
                if( attachments.keySet().size() == 0 ) {
                    return;
                }
                
                attachments = new Map<Id,Attachment>([SELECT Id,Name,Description,ParentId,Body,BodyLength,ContentType,OwnerId FROM Attachment WHERE Id IN :attachments.keySet()]);
                
               /* Map<Id,echosign_dev1__SIGN_Agreement__c> agreements = new Map<Id,echosign_dev1__SIGN_Agreement__c>([SELECT Id, Contract_Document_Type__c, echosign_dev1__Opportunity__c, echosign_dev1__Status__c, echosign_dev1__Account__c 
                    from echosign_dev1__SIGN_Agreement__c where Id IN :attachmentsMap.keySet()]);
            
                List<Contract_Document__c> contractDocuments = new List<Contract_Document__c>();
                
                Map<Id,Contract_Document__c> contractsMap = new Map<Id,Contract_Document__c>();
                
               /* for( Attachment attachment : attachments.values() ) {
                    echosign_dev1__SIGN_Agreement__c agreement = agreements.get( attachment.ParentId );
                    if( ( agreement == null ) ||
                        ( agreement.Contract_Document_Type__c == null ) ||
                        ( agreement.echosign_dev1__Status__c != 'Signed' ) ) {
                        continue;
                    }
                    
                    Contract_Document__c contractDocument = new Contract_Document__c();
                    contractDocument.Account__c = agreement.echosign_dev1__Account__c;
                    contractDocument.Type__c = agreement.Contract_Document_Type__c;
                    contractDocument.Name__c = attachment.Name;
                    contractDocument.Name = attachment.Name;
                    //contractDocument.Agreement__c = agreement.Id;
                    
                    contractDocuments.add(contractDocument);
                    
                    contractsMap.put(attachment.Id, contractDocument);
                }
                
                insert contractDocuments;
                
                List<Attachment> newAttachments = new List<Attachment>();
                
                for( Attachment attachment : attachments.values() ) {
                    Contract_Document__c contractDocument = contractsMap.get( attachment.Id );
                    if( contractDocument == null ) {
                        continue;
                    }
                    
                    Attachment newAttachment = new Attachment();
                    newAttachment.ParentId = contractDocument.Id;
                    newAttachment.Body = attachment.Body;
                    newAttachment.Name = attachment.Name;
                    newAttachment.Description = attachment.Description;
                    
                    newAttachments.add(newAttachment);
                }
                
                insert newAttachments;
                
                List<Contract_Docs_to_Opps_MtM__c> docsToOpps = new List<Contract_Docs_to_Opps_MtM__c>();
                
                for( Attachment attachment : attachments.values() ) {
                    echosign_dev1__SIGN_Agreement__c agreement = agreements.get( attachment.ParentId );
                    if( ( agreement == null ) ||
                        ( agreement.Contract_Document_Type__c == null ) ||
                        ( agreement.echosign_dev1__Status__c != 'Signed' ) ||
                        ( agreement.echosign_dev1__Opportunity__c == null ) ) {
                        continue;
                    }
                    
                    Contract_Document__c contractDocument = contractsMap.get( attachment.Id );
                    if( contractDocument == null ) {
                        continue;
                    }
                    
                    Contract_Docs_to_Opps_MtM__c docToOpp = new Contract_Docs_to_Opps_MtM__c();
                    docToOpp.Contract_Documents__c = contractDocument.Id;
                    docToOpp.Opportunity__c = agreement.echosign_dev1__Opportunity__c;
                    
                    docsToOpps.add(docToOpp);
                }
                
                insert docsToOpps;*/
            }
        }
    //Catching DML Exceptions
    } catch(DMLException e) {

        //Add Error Message on Page
        if(Trigger.isDelete)
            Trigger.Old[0].addError(e.getDmlMessage(0));
        else
            Trigger.New[0].addError(e.getDmlMessage(0));

    //Catching all Exceptions
    } catch(Exception e) {

        //Add Error Message on Page
        if(Trigger.isDelete)
            Trigger.Old[0].addError(e.getMessage());
        else
            Trigger.New[0].addError(e.getMessage());
    }
}