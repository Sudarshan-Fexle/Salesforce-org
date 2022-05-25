@isTest
public class Test_DeepCloneController{
    
    public static testmethod void testDeepClone () {
       
        //create 2 new contacts
        Contact c1 = testUtilities.CreateNewContact(false);
        Contact c2 = testUtilities.CreateNewContact(false);
        list<Contact> contacts = new list<Contact> { c1, c2 };
        insert contacts;        
        
        //Create test data
        Util.BypassAllTriggers = true;
        
        //create a new campaign
        Id mailingCampaignId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Mailing_Campaign' AND IsActive = true LIMIT 1].Id;
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
        
        //Go to Page
        PageReference pageRef = Page.DeepClone;
        Test.setCurrentPage(pageRef);
        
        //Set Parameters to be passed in 
        ApexPages.currentPage().getParameters().put('Id', campaign.Id);
        ApexPages.currentPage().getParameters().put('childobjecttypes', 'CampaignMember');
        
        // Instantiate a new controller with all parameters in place
        DeepCloneController controller = new DeepCloneController();
        
        try{
        	//Simulate intial action call on page
        	controller.cloneOnLoad();
            
        }catch(exception e){
            
        }
        
        //Check there are now two Campaigns
        list<Campaign> testresults = [Select Id, Name from Campaign];
        system.assertequals(2,testresults.size());
        
        //Check there are now four CampaignMembers
        list<CampaignMember> testcresults = [Select Id, CampaignId from CampaignMember];
        //system.assertequals(4,testcresults.size());
        
    }
    
    // Modified By - Colin McGloin - CR-20200715-14317 - 09/22/2020
    public static testmethod void testDeepCloneBillingScenario () {

        //Create test data
        Util.BypassAllTriggers = true;

        //Create initial data
        Account testAcc = testUtilities.CreateNewAccount(true);
        Contract con = testUtilities.createNewStandardContract(testAcc.Id, true);
        Billing_Schedule_Header__c bsh = testUtilities.CreateNewBillingScheduleHeader(con.Id , testAcc.Id);

        //Create a Billing Schedule Period
        Billing_Schedule_Period__c bsp = new Billing_Schedule_Period__c();
        bsp.Billing_Schedule_Header__c = bsh.Id;
        bsp.Billing_Schedule_Period_Start_Date__c = date.newinstance(2020, 1, 1);
        bsp.Billing_Schedule_Period_End_Date__c = date.newinstance(2020, 12, 31);
        bsp.Installment__c = 1;
        insert bsp;

        //Create two Billing Schedule Lines
        Billing_Schedule_Line__c bsl1 = new Billing_Schedule_Line__c();
        bsl1.Billing_Schedule_Period__c = bsp.Id;
        bsl1.Billing_Schedule_Header__c = bsh.Id;
        bsl1.Installment__c = 1;
        bsl1.Billing_Amount__c = 20000;
        bsl1.PO__c = 'All Hail the BOD';
        
        Billing_Schedule_Line__c bsl2 = new Billing_Schedule_Line__c();
        bsl2.Billing_Schedule_Period__c = bsp.Id;
        bsl2.Billing_Schedule_Header__c = bsh.Id;
        bsl2.Installment__c = 2;
        bsl2.Billing_Amount__c = 5000;
        bsl2.PO__c = 'All Hail the BOD';

        List<Billing_Schedule_Line__c> bsls = new List<Billing_Schedule_Line__c>();
        bsls.add(bsl1);
        bsls.add(bsl2);
        insert bsls;
       
        Util.BypassAllTriggers = false;
        
        //Go to Page
        PageReference pageRef = Page.DeepClone;
        Test.setCurrentPage(pageRef);
        
        //Set Parameters to be passed in 
        ApexPages.currentPage().getParameters().put('Id', bsp.Id);
        ApexPages.currentPage().getParameters().put('childobjecttypes', 'Billing_Schedule_Line__c');
        ApexPages.currentPage().getParameters().put('reversal', 'reversal');
        
        // Instantiate a new controller with all parameters in place
        DeepCloneController controller = new DeepCloneController();
        
        try{
        	//Simulate intial action call on page
        	controller.cloneOnLoad();
            
        }catch(exception e){
            
        }
        
        //Check there are now two Campaigns
        list<Billing_Schedule_Line__c> testresults = [Select Id, Name, Billing_Amount__c, Installment__c, Billing_Schedule_Period__c, Billing_Schedule_Period__r.Reversal__c from Billing_Schedule_Line__c WHERE PO__c = 'All Hail the BOD' ORDER BY Installment__c ASC];
        system.assertequals(6,testresults.size());

        List<Billing_Schedule_Line__c> negativeBSLs = new List <Billing_Schedule_Line__c>();

        //Loop through our Results
        for (Billing_Schedule_Line__c bsl : testresults){
            if (bsl.Billing_Amount__c < 0){
                negativeBSLs.add(bsl);
            }
        }

        //Check there are two negative BSLs
        system.assertequals(2,negativeBSLs.size());
        system.assertEquals(-20000, negativeBSLs[0].Billing_Amount__c);
        system.assertEquals(true, negativeBSLs[0].Billing_Schedule_Period__r.Reversal__c);
        
    }

}