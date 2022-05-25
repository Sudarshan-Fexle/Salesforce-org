/*
 * Purpose		:	Test class for RecalculateJobTicketEstimatesController
 * 
 * CreatedDate		:	21/10/2019
 * 
 * RevisionLog		: 	V_1.0 - Created - Dipesh Gupta
 * 				V_1.1 - Modified test class for deployment test class fixes for release Print MIS (Phase 2)
 * 				V_1.2 - Modified By - Shalu Sharma - 5/18/21 - CR-20210315-14997 - Update the "BRE" to "Reply Envelope (BRE/CRE)"
 * 				V_1.3 - Modified By - Abhinav Sharma - 05/20/2021 - CR-20210518-15161 - Update the method "test_approveJobTicketMtM"
 *                      	V_1.4 - Modified by - 04/30/2021 - CR-20210323-15016 - Neha Sharma - populate drop type
 * Code Coverage	:	
 * */

@IsTest
private class Test_RecalculateJobTicketEstController
{
	@testSetup static void testSetupData()
    {
        // Creating School record (Institute)
        Account inst = new Account(Vendor_Type__c = 'Vendor', Name = 'Test1');
        insert inst;
        
        Id userId = TestUtilities.CreatenewUser(true).Id;
        
        //Creating ES Campaign record
        ES_Campaign__c esc = new ES_Campaign__c(Fiscal_Year__c = '2019', Status__c = 'Open', School__c = inst.Id);
        insert esc;
        
        //04/30/2021 - CR-20210323-15016 - Neha Sharma - populate drop type
        // Changes for Release Print MIS (Phase 2) Start Here
        // Creating Record of Job_Ticket__c
        List<Job_Ticket__c> jobTickets = new List<Job_Ticket__c>();
        jobTickets.add(new Job_Ticket__c(Drop_Type__c = 'Pre Planned',ES_Campaign__c = esc.Id, Mail_Quantity__c = 500, Status__c = 'Draft',  Art_Director__c = userId, Descriptive_Name__c = '### Test Record ###', Change_Reason__c = 'Test', Project_Manager__c = userId));
        jobTickets.add(new Job_Ticket__c(Drop_Type__c = 'Pre Planned',ES_Campaign__c = esc.Id, Mail_Quantity__c = 1000, Status__c = 'Draft',  Art_Director__c = userId, Descriptive_Name__c = '### Test Record ###', Change_Reason__c = 'Test', Project_Manager__c = userId));
        jobTickets.add(new Job_Ticket__c(Drop_Type__c = 'Pre Planned',ES_Campaign__c = esc.Id, Mail_Quantity__c = 1500, Status__c = 'Draft',  Art_Director__c = userId, Descriptive_Name__c = '### Test Record ###', Change_Reason__c = 'Test', Project_Manager__c = userId));
        insert jobTickets;
        // Print MIS (Phase 2) Ends Here
        
        // Creating record of Production_Tracking__c
        List<Production_Tracking__c> fullFillmentTrackings = new List<Production_Tracking__c>();
        fullFillmentTrackings.add(new Production_Tracking__c(Job_Ticket__c = jobTickets[0].Id));
        fullFillmentTrackings.add(new Production_Tracking__c(Job_Ticket__c = jobTickets[1].Id));
        fullFillmentTrackings.add(new Production_Tracking__c(Job_Ticket__c = jobTickets[2].Id));
        insert fullFillmentTrackings;
        
        // Creating record of Job_Ticket_Component__c
        List<Job_Ticket_Component__c> jobTicketComponents = new List<Job_Ticket_Component__c>();
        //Modify by - Shalu Sharma - 5/18/21 - CR-20210315-14997
        jobTicketComponents.add(new Job_Ticket_Component__c(Component__c = Constants.COMPONENT_TYPE_BRE));
        jobTicketComponents.add(new Job_Ticket_Component__c(Component__c = Constants.COMPONENT_TYPE_BRE));
        insert jobTicketComponents;
        
        // Creating Institution Records 
        List<Account> institutions = new List<Account>();
        institutions.add(new Account(Vendor_Type__c = 'Vendor', Name = 'Test1'));
        institutions.add(new Account(Vendor_Type__c = 'Contractor', Name = 'Test2'));
        insert institutions;
        
        // Creating records of Vendor_Component_Pricing__r
        List<Vendor_Component_Pricing__c> vendorComponentPricings = new List<Vendor_Component_Pricing__c>();
        vendorComponentPricings.add(new Vendor_Component_Pricing__c(Vendor__c = institutions[0].Id, Job_Ticket_Component__c = jobTicketComponents[0].Id));
        vendorComponentPricings.add(new Vendor_Component_Pricing__c(Vendor__c = institutions[1].Id, Job_Ticket_Component__c = jobTicketComponents[0].Id));
        insert vendorComponentPricings;
        
        // Creating records of Vendor_Pricing_Per_Unit__c
        List<Vendor_Pricing_Per_Unit__c> vendorPricingPerUnits = new List<Vendor_Pricing_Per_Unit__c>();
        
        // Creating Date instances
        Date startDate = Date.today();
        startDate = startDate.addDays(-2);
        Date endDate = Date.today();
        endDate.addDays(5);
        
        vendorPricingPerUnits.add(new Vendor_Pricing_Per_Unit__c(Quantity_Maximum__c = 2000, Quantity_Minimum__c = 10, Vendor_Component_Pricing__c = vendorComponentPricings[0].Id,
                                                                Price_Effective_End_Date__c = endDate, Price_Effective_Start_Date__c = startDate));
        vendorPricingPerUnits.add(new Vendor_Pricing_Per_Unit__c(Quantity_Maximum__c = 1000, Quantity_Minimum__c = 20, Vendor_Component_Pricing__c = vendorComponentPricings[1].Id,
                                                                Price_Effective_End_Date__c = endDate, Price_Effective_Start_Date__c = startDate));
        insert vendorPricingPerUnits;
        
        // Create Job Ticket Estimate
        List<Job_Ticket_Estimates__c> jobTicketEstimates = new List<Job_Ticket_Estimates__c>();
        jobTicketEstimates.add(new Job_Ticket_Estimates__c(Production_Tracking__c = fullFillmentTrackings[0].Id, Vendor_Name__c = institutions[0].Id, Mail_Quantity__c = 100));
        jobTicketEstimates.add(new Job_Ticket_Estimates__c(Production_Tracking__c = fullFillmentTrackings[1].Id, Vendor_Name__c = institutions[1].Id, Mail_Quantity__c = 50));
        insert jobTicketEstimates;
        
        // Create Job Ticket Estimate Component
        List<Job_Ticket_Estimate_Component__c> jobTicketEstimateComponents = new List<Job_Ticket_Estimate_Component__c>();
        jobTicketEstimateComponents.add(new Job_Ticket_Estimate_Component__c(Job_Ticket_Component__c = jobTicketComponents[0].Id, Job_Ticket_Estimate__c = jobTicketEstimates[0].Id, Vendor_Pricing_Per_Unit__c = vendorPricingPerUnits[0].Id));
        insert jobTicketEstimateComponents;
        
        // Create Job_Ticket_MtM__c
        List<Job_Ticket_MtM__c> jobTicketMtMs = new List<Job_Ticket_MtM__c>();
        jobTicketMtMs.add(new Job_Ticket_MtM__c(Job_Ticket__c = jobTickets[0].Id, Job_Ticket_Component__c = jobTicketComponents[0].Id));
        insert jobTicketMtMs;  
    }
    
    @IsTest static void testRecalculateJobTicketEstController()
    {
        List<Job_Ticket__c> jobTickets = [SELECT Id, ES_Campaign__c, Mail_Quantity__c, Status__c, Change_Reason__c FROM Job_Ticket__c];
        system.assertEquals(3 , jobTickets.size());
        
        List<Production_Tracking__c> fulFillMentTrackings = [SELECT Id, Job_Ticket__c FROM Production_Tracking__c];
        system.assertEquals(3 , fulFillMentTrackings.size());
        
        // List Of Job_Ticket_Component__c
        List<Job_Ticket_Component__c> jobTicketComponents = [SELECT Id, Name, Component__c FROM Job_Ticket_Component__c];
        system.assertEquals(2, jobTicketComponents.size());
        
        // List Of Vendor_Pricing_Per_Unit__c
        List<Vendor_Pricing_Per_Unit__c> vendorPricingPerUnits = [SELECT Id, Quantity_Maximum__c, Quantity_Minimum__c, Vendor_Component_Pricing__c,Vendor_Component_Pricing__r.Job_Ticket_Component__c,
                                                                  Price_Effective_End_Date__c, Price_Effective_Start_Date__c, Active__c
                                                                  FROM Vendor_Pricing_Per_Unit__c];
        system.assertEquals(2, vendorPricingPerUnits.size());
        
        List<Job_Ticket_Estimates__c> jobTicketEstimates = [Select Id, (Select Id, Job_Ticket_Component__c, Vendor_Pricing_Per_Unit__c From Job_Ticket_Estimate_Components__r) From Job_Ticket_Estimates__c];
        system.assert(jobTicketEstimates.size() > 0 , jobTicketEstimates.size());
        
        List<Job_Ticket_MtM__c> jobTicketMtMs = [SELECT Id, Job_Ticket__c, Job_Ticket_Component__c FROM Job_Ticket_MtM__c WHERE Job_Ticket__c =: jobTickets[0].Id];
        system.assertEquals(1, jobTicketMtMs.size());
        
        Test.startTest();
        
        PageReference pageRef = Page.RecalculateFulfillmentTracking;
        pageRef.getParameters().put('id', String.valueOf(fulFillMentTrackings[0].Id));
        Test.setCurrentPage(pageRef);
        RecalculateJobTicketEstimatesController.processRequest();
        
        Test.stopTest();
    }
}