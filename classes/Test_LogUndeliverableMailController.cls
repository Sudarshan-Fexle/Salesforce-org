/**
 *  Purpose         :   Tests the LogUndeliverableMailController class
 *
 *  Created By      :   Victor Hanson
 *
 *  Created Date    :   06/23/2014
 *
 *  Current Version :   v1.0 - Created
 *
 **/
@isTest
private class Test_LogUndeliverableMailController{
    
    //verifies an error is thrown due to no search criteria being specified
    static testmethod void testUndeliverableMailing_Error_NoSearchCriteria() {
        
        Util.BypassAllTriggers = true;
        
        //create 2 new contacts
        Contact c1 = testUtilities.CreateNewContact(false);
        Contact c2 = testUtilities.CreateNewContact(false);
        list<Contact> contacts = new list<Contact> { c1, c2 };
        insert contacts;        
        
        //create a new campaign
        Id mailingCampaignId = [SELECT Id FROM RecordType 
                                WHERE DeveloperName = :Label.Record_Type_Developer_Name_Mailing_Campaign
                                AND IsActive = true 
                                LIMIT 1].Id;
        Campaign campaign = new Campaign(Name = 'Mailing Campaign 1',
                                        IsActive = true,
                                        Status = 'In Progress',
                                        RecordTypeId = mailingCampaignId);
        insert campaign;
        
        Util.BypassAllTriggers = false;
        
        //create 2 campaign members
        CampaignMember cm1 = new CampaignMember(CampaignId = campaign.Id, ContactId = c1.Id);
        CampaignMember cm2 = new CampaignMember(CampaignId = campaign.Id, ContactId = c2.Id);
        list<CampaignMember> cmList = new list<CampaignMember> { cm1, cm2 };
        insert cmList;
        
        //get the campaign member's mail piece id
        cm1 = [SELECT Id, ContactId, CampaignId, Mail_Piece_Id__c FROM CampaignMember WHERE Id = :cm1.Id];
        
        //Set the page reference
        PageReference pageRef = Page.LogUndeliverableMail;
        test.setCurrentPage(pageRef);
        
        //Instantiate the controller and set the page
        LogUndeliverableMailController controller = new LogUndeliverableMailController();
        
        test.startTest();
        
        //find campaign members
        controller.findCampaignMembers();
        system.assertEquals(1, apexPages.getMessages().size(),
                           'Should have received an error because no search criteria was specified.');
        system.assertEquals(Label.ERROR_UNDELIVERABLE_MAIL_SEARCH_REQ_FIELDS, apexPages.getMessages()[0].getSummary(),
                           'Should have received an error because no search criteria was specified.');
        
        test.stopTest();
    }
    
    //successfully mark a campaign member as undeliverable
    static testmethod void testUndeliverableMailing_Success() {
        
        Util.BypassAllTriggers = true;
        
        //create 2 new contacts
        Contact c1 = testUtilities.CreateNewContact(false);
        Contact c2 = testUtilities.CreateNewContact(false);
        list<Contact> contacts = new list<Contact> { c1, c2 };
        insert contacts;        
        
        //create a new campaign
        Id mailingCampaignId = [SELECT Id FROM RecordType 
                                WHERE DeveloperName = :Label.Record_Type_Developer_Name_Mailing_Campaign 
                                AND IsActive = true 
                                LIMIT 1].Id;
        Campaign campaign = new Campaign(Name = 'Mailing Campaign 1',
                                        IsActive = true,
                                        Status = 'In Progress',
                                        RecordTypeId = mailingCampaignId);
        insert campaign;
        
        Util.BypassAllTriggers = false;
        
        //create 2 campaign members
        CampaignMember cm1 = new CampaignMember(CampaignId = campaign.Id, ContactId = c1.Id);
        CampaignMember cm2 = new CampaignMember(CampaignId = campaign.Id, ContactId = c2.Id);
        list<CampaignMember> cmList = new list<CampaignMember> { cm1, cm2 };
        insert cmList;
        
        //get the campaign member's mail piece id
        cm1 = [SELECT Id, ContactId, CampaignId, Mail_Piece_Id__c FROM CampaignMember WHERE Id = :cm1.Id];
        
        //Set the page reference
        PageReference pageRef = Page.LogUndeliverableMail;
        test.setCurrentPage(pageRef);
        
        //Instantiate the controller and set the page
        LogUndeliverableMailController controller = new LogUndeliverableMailController();
        
        test.startTest();
        
        //set the mail piece id and then search for campaign members
        controller.mailPieceId = cm1.Mail_Piece_Id__c;
        controller.findCampaignMembers();
        system.assertEquals(ApexPages.Severity.CONFIRM, apexPages.getMessages()[0].getSeverity());
        
        //get the campaign member and related contact and make sure they were updated
        cm1 = [SELECT Id, Undeliverable__c, ContactId FROM CampaignMember WHERE Id = :cm1.Id];
        c1 = [SELECT Id, Num_Undeliverable_Mailings__c FROM Contact WHERE Id = :c1.Id];
        system.assertEquals(true, cm1.Undeliverable__c,
                           'This campaign member should have Undeliverable__c = true');
        system.assertEquals(1, c1.Num_Undeliverable_Mailings__c,
                           'There should be one undeliverable mailing on this contact.');
        
        test.stopTest();
        
    }
    
    //successfully mark a campaign member as undeliverable
    static testmethod void testUndeliverableMailing_MultipleCampaignMembers() {
        
        Util.BypassAllTriggers = true;
        
        //create 2 new contacts
        Contact c1 = testUtilities.CreateNewContact(false);
        c1.FirstName = 'Billy';
        c1.LastName = 'Blanks';
        c1.Primary_Country__c = 'USA';
        c1.Primary_Address_Line_2__c = 'addr line2';
        c1.Primary_Address_Line_3__c = 'addr line3';
        Contact c2 = testUtilities.CreateNewContact(false);
        list<Contact> contacts = new list<Contact> { c1, c2 };
        insert contacts;
        
        //create a new campaign
        Id mailingCampaignId = [SELECT Id FROM RecordType 
                                WHERE DeveloperName = :Label.Record_Type_Developer_Name_Mailing_Campaign 
                                AND IsActive = true 
                                LIMIT 1].Id;
        Campaign campaign1 = new Campaign(Name = 'Mailing Campaign 1',
                                        IsActive = true,
                                        Status = 'In Progress',
                                        RecordTypeId = mailingCampaignId);
        Campaign campaign2 = new Campaign(Name = 'Mailing Campaign 2',
                                        IsActive = true,
                                        Status = 'In Progress',
                                        RecordTypeId = mailingCampaignId);
        
        list<Campaign> campaigns = new list<Campaign> { campaign1, campaign2 };
        insert campaigns;
        
        Util.BypassAllTriggers = false;
        
        //create 4 campaign members - placing both contacts in two different campaigns
        CampaignMember cm1 = new CampaignMember(CampaignId = campaign1.Id, ContactId = c1.Id);
        CampaignMember cm2 = new CampaignMember(CampaignId = campaign1.Id, ContactId = c2.Id);
        CampaignMember cm3 = new CampaignMember(CampaignId = campaign2.Id, ContactId = c1.Id);
        CampaignMember cm4 = new CampaignMember(CampaignId = campaign2.Id, ContactId = c2.Id);
        list<CampaignMember> cmList = new list<CampaignMember> { cm1, cm2, cm3, cm4 };
        insert cmList;
        
        //Set the page reference
        PageReference pageRef = Page.LogUndeliverableMail;
        test.setCurrentPage(pageRef);
        
        //Instantiate the controller and set the page
        LogUndeliverableMailController controller = new LogUndeliverableMailController();
        
        test.startTest();
        
        //set the search criteria and then search for campaign members
        controller.firstName = c1.FirstName;
        controller.lastName = c1.LastName;
        controller.addressLine1 = c1.Primary_Address_Line_1__c;
        controller.addressLine2 = c1.Primary_Address_Line_2__c;
        controller.addressLine3 = c1.Primary_Address_Line_3__c;
        controller.city = c1.Primary_City__c;
        controller.state = c1.Primary_State_Province__c;
        controller.postalCode = c1.Primary_Postal_Code__c;
        controller.country = c1.Primary_Country__c;
        controller.findCampaignMembers();
        system.assertEquals(ApexPages.Severity.INFO, apexPages.getMessages()[0].getSeverity(),
                           'Should have severity INFO due to multiple Campaign Members being found.');
        system.assertEquals(2, controller.campaignMemberList.size(),
                           'Two campaign members should have been returned');
        
        //select the first campaign member to log an undeliverable piece of mail against
        ApexPages.currentPage().getParameters().put('campaignMemberId', cm1.Id);
        controller.recordUndeliverableMail();
        
        //get the campaign member and related contact and make sure they were updated
        cm1 = [SELECT Id, Undeliverable__c, ContactId FROM CampaignMember WHERE Id = :cm1.Id];
        c1 = [SELECT Id, Num_Undeliverable_Mailings__c FROM Contact WHERE Id = :c1.Id];
        system.assertEquals(true, cm1.Undeliverable__c,
                           'This campaign member should have Undeliverable__c = true');
        system.assertEquals(1, c1.Num_Undeliverable_Mailings__c,
                           'There should be one undeliverable mailing on this contact.');
        
        test.stopTest();
        
    }
}