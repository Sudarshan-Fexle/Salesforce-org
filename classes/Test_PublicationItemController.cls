@isTest
public class Test_PublicationItemController{
    
    public static testmethod void testAddPublication () {
        
        //Create test data
        Util.BypassAllTriggers = true;
        
        //create 2 new contacts
        Contact c1 = testUtilities.CreateNewContact(false);
        Contact c2 = testUtilities.CreateNewContact(false);
        list<Contact> contacts = new list<Contact> { c1, c2 };
            insert contacts;        
        
        //create a new campaign
        Id mailingCampaignId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Mailing_Campaign' AND IsActive = true LIMIT 1].Id;
        Campaign campaign = new Campaign(Name = 'Mailing Campaign 1',
                                         IsActive = true,
                                         Status = 'In Progress',
                                         RecordTypeId = mailingCampaignId);
        insert campaign;
        
        Util.BypassAllTriggers = false;
        
        //create 3 Publications - 2 that can be found via search, 
        //and 1 with Publicatoin Date more than 6 months ago, which should not be visible in search
        Publication__c pub1 = new Publication__c(Title__c='Publication 1',Stock_Num__c='HCB01', 
                                                 DERF__c=5531,Publication_Date__c=system.today().addMonths(-2));
        Publication__c pub2 = new Publication__c(Title__c='Publication 1',Stock_Num__c='HCB02', 
                                                 DERF__c=5532,Publication_Date__c=system.today().addMonths(-4));
        Publication__c pub3_NotFound = new Publication__c(Title__c='Publication 1 (not found)',Stock_Num__c='HCB03', 
                                                          DERF__c=5534,Publication_Date__c=system.today().addMonths(-7));
        list<Publication__c> pubList = new list<Publication__c> { pub1, pub2, pub3_NotFound };
        insert pubList;
        
        list<Publication__c> pubs = [SELECT Id FROM Publication__c WHERE Stock_Num__c='HCB01' AND  Publication_Date__c >= LAST_N_MONTHS:6];
        system.assertEquals(1, pubs.size());
        
        //Go to Page
        PageReference pageRef = Page.PublicationItem;
        Test.setCurrentPage(pageRef);
        
        //Set Parameters to be passed in 
        ApexPages.currentPage().getParameters().put('cid', campaign.Id);
        
        //Simulate a search for Publication
        ApexPages.currentPage().getParameters().put('searchString', 'HC');
        
        // Instantiate a new controller with all parameters in place
        PublicationItemController controller = new PublicationItemController();
        
        //SOSL searches must be fixed in unit tests (http://www.salesforce.com/us/developer/docs/apexcode/Content/apex_testing_SOSL.htm)
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = pub1.Id;
        Test.setFixedSearchResults(fixedSearchResults);
        
        //start the test
        test.startTest();
        
        controller.search();
        
        system.assertEquals('HC', controller.searchString);
        
        //Check that one record was found
        system.assertequals(1, controller.publications.size(),
                            'One publication should have been returned since we searched for the exact stock number "HCB01".');
        
        //select the publication
        ApexPages.currentPage().getParameters().put('selectedPublicationId', pub1.Id);
        controller.addItem();
        
        //save the selected item
        controller.save();
        
        //stop the test
        test.stopTest();
        
        //get all publication items associated with the campaign
        list<Publication_Item__c> pubItems = [SELECT Id, Name FROM Publication_Item__c WHERE Campaign__c = :campaign.Id];
        
        system.assertEquals(1, pubItems.size(),
                            'One publication item should have been inserted and associated with this campaign.');
    }
}