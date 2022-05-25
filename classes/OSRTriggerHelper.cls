/**
 *  Purpose         :   This class is helper class for OSR Trigger.
 *
 *  Created By      :   Bhavi Sharma
 *
 *  Created Date    :   07/02/2013
 *
 *  Current Version :   v1.0 - Created
                        V_1.1 - Bhavi Sharma - 01/27/2014 - New method added(ProcessRequest)
						V_1.2 - Mahendra Swarnakar - 09/16/2015 - New method added( populateDefaultAdvisoryProfile) -CR-9236
						V_1.3 - Bhavi Sharma - 10/26/2015 - Updated populateDefaultAdvisoryProfile to only populate the defaultprofile for New Request - CR-20151013-9317
						V_1.4 - Mahendra Swarnakar - 10/27/2015 - CR-20151013-9317 - Modify the populateDefaultAdvisoryProfile to only populate the defaultprofile for New Request and related credit card's advisory profile for replacement request 
						
 **/
public without sharing class OSRTriggerHelper {

    /**
     * 	@description: link the related CPQ Document so the user can access the current version
     * 
     * 	@params: list<OSR__c>
     * 
     * 	@Revisions: 6/16/17 - Created - VH - CR-10808
     * 
     **/
    public static void linkContentDocument(List<OSR__c> newOSRs) {
        string SHARE_TYPE_VIEWER = 'V';
        set<Id> cpqTemplateIds = new set<Id>();
        list<ContentDocumentLink> links = new list<ContentDocumentLink>();
        
        //get list of cpq templates
        for (OSR__c osr : newOSRs) 
            if (osr.CPQ_Template__c != null) cpqTemplateIds.add(osr.CPQ_Template__c);
        
        if (cpqTemplateIds.size() > 0) {
            map<Id, CPQ_Template__c> templateMap = new map<Id, CPQ_Template__c>([SELECT Id, Template_Document_Id__c 
                                                                               FROM CPQ_Template__c 
                                                                               WHERE Id IN :cpqTemplateIds]);
            //create the contentDocumentLinks
            for (OSR__c osr : newOSRs) {
                links.add(new ContentDocumentLink(ContentDocumentId = templateMap.get(osr.CPQ_Template__c).Template_Document_Id__c,
                                                 LinkedEntityId = osr.Id,
                                                 ShareType = SHARE_TYPE_VIEWER));
            }
        }
        
        if (links.size() > 0) insert links;
    }
    
    //Modified by rajeev jain  
    //Starts here
    
    
    //Added by -Mahendra Swarnakar - 10/27/2015 - CR-20151013-9317
	//Starts from here
	//Query result of Credit Card Settings record
//	public static List<Credit_Card_Settings__c> configDefaultSettings = [Select Id, Default_Portfolio_Profile__c FROM Credit_Card_Settings__c WHERE Name =: CreditCardConstants.CC_DEFAULT_SETTINGS_NAME];
    //Ends here
     
    /**
     *  @description    :   This method is to check whether alert need to be sent to finanace team when OSR record created
     *
     *  @param          :   Trigger.new newListOpportunity
     *
     *  @retrun         :   void
     **/
    /* public static void updateOSRAlertFinance(List<OSR__c> newOSRs){

        //Query result of Credit Card Settings record
        List<Credit_Card_Settings__c> configDefaults = [Select Decline_Alert_To_Finance__c FROM Credit_Card_Settings__c WHERE Name =: CreditCardConstants.CC_DEFAULT_SETTINGS_NAME];
        
        //Loop through Trigger.new
        for(OSR__c osr : newOSRs){

            //Check for Alert Summary contains Decline
            if(osr.Alert_Summary__c != null && osr.Alert_Summary__c.containsIgnoreCase(CreditCardConstants.OSR_DECLINE_ALERT)){

                //Check for size of configDefault
                if(configDefaults.size() > 0)
                    osr.Alert_Finance__c = configDefaults[0].Decline_Alert_To_Finance__c;
            }
        }
     } */

     /**
     *  @description    :   This method is used for sending Agreement to User when OSR's status is 'New'.
     *
     *  @param          :   Trigger.new newListOSR
     *
     *  @retrun         :   void
     **/
	
    public static void sendAgreementForNewOSR(List<OSR__c> newListOSR) {
   /*
        //Query result of Document
        List<Document> documents = [SELECT Name, Body, BodyLength, ContentType, Type, Description FROM Document WHERE  DeveloperName =: CreditCardConstants.DOCUMENT_DEVELOPER_NAME_ADVISORY_BOARD_CREDIT_CARD_AGREEMENT];
        system.debug('sendAgreementForNewOSR.documents: '+documents);

        //Query result of User
        //List<User> users = [SELECT Id FROM User WHERE Alias =: Constants.USER_ALIAS_SFADMIN];
        //system.debug('sendAgreementForNewOSR.users: '+users);
        Id sendUser = CreditCardConstants.CONFIG_DEFAULT.Service_User__c;
        system.debug('sendAgreementForNewOSR.sendUser: '+sendUser);

        //OSRs list with Status = 'New'
        List<OSR__c> newOSRs = new List<OSR__c>();
        system.debug('sendAgreementForNewOSR.1newOSRs: '+newOSRs);

        //Check for Documents size
        if(documents.size() > 0) {

            //Loop through Tirgger.new
            for( OSR__c osr : newListOSR) {

                //Check OSR's Status is New
                if(osr.Status__c != null && osr.Status__c == CreditCardConstants.OSR_STATUS_NEW && osr.Request_Type__c == CreditCardConstants.OSR_REQUEST_TYPE_NEW_ABC_CREDIT_CARD ) {

                    //add OSR into list
                    newOSRs.add(osr);
                }
            }
            system.debug('sendAgreementForNewOSR.2newOSRs: '+newOSRs);

            //Check for size of list
            if( newOSRs.size() > 0 ) {

                //Map to hold OSR's Id as Key and OSR's Contact as Value
                Map<Id, Id> mapContacts = new Map<Id, Id>();

                //Loop through OSR list which have Status = New
                for( OSR__c oSR : newOSRs ) {

                    if(oSR.Contact__c != null) {

                        //put Contact field as value and OSR's Id as key
                        mapContacts.put( oSR.Id, oSR.Contact__c );
                    }
                }
                system.debug('sendAgreementForNewOSR.mapContacts: '+mapContacts);

                //List to hold EchoSing Agreements
                List<echosign_dev1__SIGN_Agreement__c> agreements = new List<echosign_dev1__SIGN_Agreement__c>();

                //Check for map's size
                if(mapContacts.size() > 0) {

                    //Loop through OSR list which have Status = New
                    for( OSR__c osr : newOSRs ) {

                        //Instance of EchoSign Agreement
                        echosign_dev1__SIGN_Agreement__c agreement = new echosign_dev1__SIGN_Agreement__c();
                        agreement.Name = 'Advisory Board Credit Card Agreement';
                        agreement.OSR__c = osr.Id;
                        //agreement.echosign_dev1__Recipient__c = osr.Contact__c;
                        //agreement.echosign_dev1__Sender_User__c = users[0].Id;
                        agreement.echosign_dev1__Sender_User__c = sendUser;
                        agreement.echosign_dev1__SenderSigns__c = false;
                        //agreement.echosign_dev1__SignatureOrder__c = 'Recipient signs, then I sign';
                        agreement.Contract_Document_Type__c = 'Letter of Agreement (Standard Terms)';

                        //add agreement into list of Agreements
                        agreements.add(agreement);
                    }
                    system.debug('sendAgreementForNewOSR.1agreements: '+agreements);

                    //Check for size of Agreements
                    if(agreements.size() > 0) {

                        //Insert EchoSign Agreements
                        insert agreements;
                        system.debug('sendAgreementForNewOSR - After Insert Agreements');

                        //List to hold EchoSign Recipients
                        List<echosign_dev1__SIGN_Recipients__c> recipients = new List<echosign_dev1__SIGN_Recipients__c>();

                        //Loop through agreements
                        for( echosign_dev1__SIGN_Agreement__c agreement : agreements ) {

                            //Instance of EchoSign Recipients
                            echosign_dev1__SIGN_Recipients__c recipient = new echosign_dev1__SIGN_Recipients__c();
                            recipient.echosign_dev1__Contact__c = mapContacts.get( agreement.OSR__c);
                            recipient.echosign_dev1__Agreement__c = agreement.Id;
                            recipient.echosign_dev1__Recipient_Type__c = 'Contact';
                            recipient.echosign_dev1__Order_Number__c = 1;
                            //recipient.echosign_dev1__useEmailAddress__c = true;

                            //add recipient into list
                            recipients.add(recipient);
                        }
                        system.debug('sendAgreementForNewOSR.recipients: '+recipients);

                        //Check for size of recipients
                        if(recipients.size() > 0) {

                            //insert EchoSign recipients for agreement
                            insert recipients;
                            system.debug('sendAgreementForNewOSR - After Insert Recipients');

                            //List to hold Attachments
                            List<Attachment> attachments = new List<Attachment>();

                            //Loop through agreements
                            for( echosign_dev1__SIGN_Agreement__c agreement : agreements ) {

                                //Instance of attachment
                                Attachment attachment = new Attachment();
                                attachment.ParentId = agreement.Id;
                                attachment.Body = documents[0].Body;
                                attachment.Description = documents[0].Description;
                                attachment.ContentType = documents[0].ContentType;
                                attachment.Name = documents[0].Name + ( documents[0].Type == null ? '' : '.' + documents[0].Type);

                                //add Attachment into list
                                attachments.add(attachment);
                            }
                            system.debug('sendAgreementForNewOSR.attachments: '+attachments);

                            //Check for size of Attachments list
                            if(attachments.size() > 0) {

                                //insert attachments
                                insert attachments;
                                system.debug('sendAgreementForNewOSR - After Insert Attachments');

                                //Loop through list of Agreements and update Background Action with Send
                                for( echosign_dev1__SIGN_Agreement__c agreement : agreements ) {
                                    agreement.echosign_dev1__Background_Action__c = 'Send';
                                    //agreement.echosign_dev1__LastEventId__c = '643643417';
                                    //agreement.echosign_dev1__Recipient_Addresses__c = 'bhawani.sh.sharma@gmail.com';
                                    //agreement.echosign_dev1__Status__c = 'Out for Signature';
                                    //agreement.Ready_To_Send__c = true;
                                }
                            }
                        }
                    }

                    //Update EchoSign Agreements
                    update agreements;
                    system.debug('sendAgreementForNewOSR.2agreements: '+agreements);
                    system.debug('sendAgreementForNewOSR - After Update Agreements');
                    
                }
            }
        }*/
    }
    
    public static void testEchoSignProcess()
    {
        /*
        PageReference p;
        p.getParameters().put('masterid','a4LM0000000CilB');
        p.getParameters().put('templateId','a2tM00000000Pex');
        p = Page.echosign_dev1__AgreementTemplateProcess;
        echosign_dev1.AgreementTemplateProcessorController atpc = new echosign_dev1.AgreementTemplateProcessorController();
        //sObject result = p.doProcess();
        system.debug('Result: '+result);
        */
        echosign_dev1__SIGN_Agreement__c agreement = new echosign_dev1__SIGN_Agreement__c();
        agreement.echosign_dev1__Trigger_Process_Template__c = true;
        agreement.Name = 'EchoSign Agreement';
        //agreement.OSR__c = osr.Id;
        //agreement.echosign_dev1__Recipient__c = osr.Contact__c;
        //agreement.echosign_dev1__Sender_User__c = users[0].Id;
        //agreement.echosign_dev1__SenderSigns__c = false;
        //agreement.echosign_dev1__SignatureOrder__c = 'Recipient signs, then I sign';
        agreement.Contract_Document_Type__c = 'Letter of Agreement (Standard Terms)';
        insert agreement;
        system.debug('Result: '+agreement);
    }
    
    /**
     *  @description    :   This method is to check if any request is created for Card Replacement or Deactivation
     *
     *  @param          :   List of new OSRs
     *
     *  @retrun         :   void
     **/
 /*   public static void ProcessRequest(List<OSR__c> newOSRs){

		Boolean processOSRs;
		
        //Loop through the OSR records and check if any OSR is created for Replacement or deactivation
        for(OSR__c oSR : newOSRs) {
            
            //Check request type
            if((oSR.Request_Type__c == CreditCardConstants.OSR_REQUEST_TYPE_REPLACEMENT_ABC_CREDIT_CARD 
               || oSR.Request_Type__c == CreditCardConstants.OSR_REQUEST_TYPE_REPLACEMENT_ABC_CREDIT_CARD_EXPEDITED 
               || oSR.Request_Type__c == CreditCardConstants.OSR_REQUEST_TYPE_DEACTIVATE_ABC_CREDIT_CARD)
               && oSR.Origin__c == CreditCardConstants.OSR_ORIGIN_TRAVEL_PORTAL) {
            	
            	processOSRs = true;
            }
        }
            
        //If one or more of the OSRs is for a Replacement or Deactivation, the call a batch process for them
        if(processOSRs == true) {
        
            //Check if batch is already running, then no need to execute the batch again
            List<AsyncApexJob> aSyncJobs = [SELECT Id, JobItemsProcessed, TotalJobItems, NumberOfErrors, CreatedBy.Email FROM AsyncApexJob
                                                    WHERE ApexClass.Name IN ('Batch_ProcessOSRs', 'Batch_AddCardsForReplacementRequest') 
                                                        AND Status IN: CreditCardConstants.ASYNC_APEX_JOB_PENDING_STATUSES];
            
            //Check for the size
            if(aSyncJobs.size() == 0) {
                
                //Execute batch
               // Batch_ProcessOSRs batchJob = new Batch_ProcessOSRs();
                //database.executeBatch(batchJob, 1);
            }
            
            //break to loop, no need to process other records, as batch will pick all the new appropriate OSRs
            //break;
        }
    
     }*/
     
    /**
     *  @description    :   This method is to check if address need to be updated on Credit Card record
     *
     *  @param          :   List of new OSRs
     *
     *  @retrun         :   void
     **/
 	/* public static void ProcessAddressUpdateRequest(List<OSR__c> newOSRs, Map<Id, OSR__c> mapOldOSRs){
    
        //get CC Default Settings instance  
        Credit_Card_Settings__c configDefaults = CreditCardConstants.CONFIG_DEFAULT;
        
        //Set to hold teh related Credit card Ids
        Set<Id> contactIds = new Set<Id>();
        
        //Loop through the OSR records and check if any OSR is created for Replacement or deactivation
        for(OSR__c oSR : newOSRs) {
            
            //Check request type
            if(oSR.Contact__c != null && (mapOldOSRs == null  || oSR.Contact__c != mapOldOSRs.get(oSR.Id).Contact__c)) {
                
                //Check if all address field are blank, only then fetch the address information from related portfolio and stamp on OSR
                if(String.IsBlank(oSR.Address_To_Name__c) && String.IsBlank(oSR.Address_Line_1__c) && 
                    String.IsBlank(oSR.Address_City__c) && String.IsBlank(oSR.Address_State__c) && String.IsBlank(oSR.Address_Postal_Code__c)) {
                    
                    //Add in set
                    contactIds.add(oSR.Contact__c);
                }
            }
        }
    
        //Query address information from the related credit cards
        Map<Id, Contact> mapContacts = new Map<Id, Contact>([Select Id, Legal_First_Name__c, Legal_Last_Name__c,
        																Personal_Address_Line_1__c, Personal_Address_Line_2__c,
        																Personal_Address_City__c, Personal_Address_State__c,
        																Personal_Address_PostalCode__c, Personal_Address_Country__c
                                                                                from Contact where Id IN: contactIds]);
    
        //Loop through the OSR records and check if any OSR is created for Replacement or deactivation
        for(OSR__c oSR : newOSRs) {
            
            //Check request type
            if(oSR.Contact__c != null && (mapOldOSRs == null || oSR.Contact__c != mapOldOSRs.get(oSR.Id).Contact__c)) {
                
                //Check if all address field are blank, only then fetch the address information from related portfolio and stamp on OSR
                if(String.IsBlank(oSR.Address_To_Name__c) && String.IsBlank(oSR.Address_Line_1__c) && 
                    String.IsBlank(oSR.Address_City__c) && String.IsBlank(oSR.Address_State__c) && String.IsBlank(oSR.Address_Postal_Code__c)) {
                    
                    //Get the contact
                    Contact contact = mapContacts.get(oSR.Contact__c);
                    
                    //Check for the Address to Name
                    String addressToName;
                    addressToName = contact.Legal_First_Name__c == null ? '' : contact.Legal_First_Name__c;
                    addressToName += ' ';
                    addressToName += contact.Legal_Last_Name__c == null ? '' : contact.Legal_Last_Name__c;
                    
                    
                    //Populate address fields
	                //Comdata doesn't  handle international addresses
	                //So alll the contact with non US address will be process with the CC Setings default address
	                if(!String.IsBlank(contact.Personal_Address_Country__c) && Constants.SET_UNITED_STATES.contains(contact.Personal_Address_Country__c.toLowerCase())) {
	                    
	                    //Populate address data in OSR from related CC record
	                    oSR.Address_To_Name__c = trunc(addressToName, 35);
	                    oSR.Address_Line_1__c = trunc(contact.Personal_Address_Line_1__c, 30);
	                    oSR.Address_Line_2__c = trunc(contact.Personal_Address_Line_2__c, 30);
	                    oSR.Address_City__c = trunc(contact.Personal_Address_City__c, 20);
	                    oSR.Address_State__c = trunc(contact.Personal_Address_State__c, 2);
	                    oSR.Address_Postal_Code__c = trunc(contact.Personal_Address_PostalCode__c, 10);
	                    
	                } else {
	                	
	                	//Populate address data in OSR from related CC record
	                    oSR.Address_To_Name__c = trunc(configDefaults.Alternate_Delivery_Attention_To__c, 35);
	                    oSR.Address_Line_1__c = trunc(configDefaults.Alternate_Delivery_Address_1__c, 30);
	                    oSR.Address_Line_2__c = trunc(configDefaults.Alternate_Delivery_Address_2__c, 30);
	                    oSR.Address_City__c = trunc(configDefaults.Alternate_Delivery_City__c, 20);
	                    oSR.Address_State__c = trunc(configDefaults.Alternate_Delivery_State__c, 2);
	                    oSR.Address_Postal_Code__c = trunc(configDefaults.Alternate_Delivery_Postal_Code__c, 10);    
	                }
                }
            }
        }
     }
    */
     
     /**
     *  @description    :   This method is to truncate the value upto given limit 
     * 
     *  @args           :   Value to be truncated, Characters limit
     * 
     *  @return         :   truncated value
     * 
     **/ 
    public static String trunc(String value, Integer length) {
        
        //Chekc if value is not null
        if(value != null && value.length() >= length) {
            
            //Trunc upto given length
            return value.left(length);
        }
        
        //Return
        return value;
    } 
    
    /**
     *  @description    :   This method is to only populate the default advisory profile for New Request on the OSR.
     * 						If advisory profile is not populated on OSR record with replacement request,then populate with related credit card's advisory profile on the OSR record.
     * 
     *  @args           :   Trigger.NEW
     * 
     *  @return         : 
     *  
     *  @revision Log	:	V_1.0 Created
     						V_1.1 Modified by -Mahendra Swarnkar -CR-20151013-9317 - 10/27/2015
     **/ 
   /*public static Void populateDefaultAdvisoryProfile(List<OSR__c> newOSRs) {
    	
        //Set to hold related Credit Card Ids
        Set<ID> setCreditCardIDs = new Set<ID>();
        
        //Loop through OSR's
        for(OSR__c oSR : newOSRs) {
            
            //Check for Advisory Profile. If it is not populated on OSR, then populate with default value
            //Bhavi Sharma - 10/26/2015 - CR-20151013-9317 - Updated populateDefaultAdvisoryProfile to only populate the defaultprofile for New Request 
            //Bhavi Sharma - 10/30/2015 - CR-20151013-9317 - No need to set the default profile.  
            /*If(String.isBlank(oSR.Advisory_Profile__c)
            	&& CreditCardConstants.OSR_REQUEST_TYPE_NEW_ABC_CREDIT_CARD.equalsIgnoreCase(oSR.Request_Type__c)) {
            		
                    //Check for size and availability of value
                    if(configDefaultSettings != null && configDefaultSettings.size() > 0 && !String.isBlank(configDefaultSettings[0].Default_Portfolio_Profile__c)) 
                        
                        //Populate advisory profile with default value
                        oSR.Advisory_Profile__c = configDefaultSettings[0].Default_Portfolio_Profile__c;
            }
            //Populate the set "setCreditCardIDs" with related credit card ids for replacement type OSR request
            else */
         /*   if(String.isBlank(oSR.Advisory_Profile__c)
            			&& ( CreditCardConstants.OSR_REQUEST_TYPE_REPLACEMENT_ABC_CREDIT_CARD.equalsIgnoreCase(oSR.Request_Type__c)
            					|| CreditCardConstants.OSR_REQUEST_TYPE_REPLACEMENT_ABC_CREDIT_CARD_EXPEDITED.equalsIgnoreCase(oSR.Request_Type__c)
            				)) {
                                
				//Populate Set setCreditCardIDs
	            setCreditCardIDs.add(oSR.Related_Card__c);
            } else continue;
        }
        
        //Check for size
        if(setCreditCardIDs.size() > 0){
        	
            //Map to hold related credit card records
            Map<ID, Credit_Card__c> mapRelatedCreditCards = new Map<ID, Credit_Card__c>([Select ID, Payment_Account__r.Advisory_Profile__c From Credit_Card__c Where Id != null AND ID IN : setCreditCardIDs]);
            
            //Check for size
            if(mapRelatedCreditCards != null && mapRelatedCreditCards.size() > 0 ) {
                
				//Loop through OSR's
                for(OSR__c oSR : newOSRs) {
					
                    //Check for Advisory Profile. If it is not populated on OSR record with replacement request,then populate with related credit card's advisory profile
					if(String.isNotBlank(oSR.Related_Card__c) 
						&& String.isBlank(oSR.Advisory_Profile__c)
						&& ( CreditCardConstants.OSR_REQUEST_TYPE_REPLACEMENT_ABC_CREDIT_CARD.equalsIgnoreCase(oSR.Request_Type__c)
								|| CreditCardConstants.OSR_REQUEST_TYPE_REPLACEMENT_ABC_CREDIT_CARD_EXPEDITED.equalsIgnoreCase(oSR.Request_Type__c)
							)
						&& mapRelatedCreditCards.containsKey(oSR.Related_Card__c) 
						&& mapRelatedCreditCards.get(oSR.Related_Card__c) != null
						&& mapRelatedCreditCards.get(oSR.Related_Card__c).Payment_Account__c != null
						&& String.isNotBlank(mapRelatedCreditCards.get(oSR.Related_Card__c).Payment_Account__r.Advisory_Profile__c)) {
                        
                        //Updating advisory profile on OSR record   
						oSR.Advisory_Profile__c = mapRelatedCreditCards.get(oSR.Related_Card__c).Payment_Account__r.Advisory_Profile__c;
                   } else 
                       continue;
                }
            }
        }
    } */
    
     //ends here
}