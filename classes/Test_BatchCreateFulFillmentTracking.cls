/*
* Purpose	:	This test class is used for the code coverage of Batch_CreateFulFillmentTracking
* 
* CreatedDate	:	16/10/2019
* 
* RevisionLog	        :	V_1.0 - Created - Dipesh Gupta
                        :	V_1.1 - Modified by - Shalu Sharma - 5/18/21 - CR-20210315-14997 - Update the "BRE" to "Reply Envelope (BRE/CRE)"
			:       V_1.2 - Modified By - 04/30/2021 - CR-20210323-15016 - Neha Sharma - populate drop type	 
*/

@IsTest
public class Test_BatchCreateFulFillmentTracking 
{
    @TestSetup static void testdata()
    {
        // Creating School record (Institute)
        Account inst = new Account(Vendor_Type__c = 'Vendor', Name = 'Test1');
        insert inst;
        
        //Creating ES Campaign record
        ES_Campaign__c esc = new ES_Campaign__c(Fiscal_Year__c = '2019', Status__c = 'Open', School__c = inst.Id);
        insert esc;
        
        //04/30/2021 - CR-20210323-15016 - Neha Sharma - populate drop type
        // Creating Record of Job_Ticket__c with Production_Tracking__c
        List<Job_Ticket__c> jobTickets = new List<Job_Ticket__c>();
        jobTickets.add(new Job_Ticket__c(Drop_Type__c = 'Pre Planned',ES_Campaign__c = esc.Id, Mail_Quantity__c = 500, Status__c = 'Draft'));
        jobTickets.add(new Job_Ticket__c(Drop_Type__c = 'Pre Planned',ES_Campaign__c = esc.Id, Mail_Quantity__c = 1000, Status__c = 'Draft'));
        jobTickets.add(new Job_Ticket__c(Drop_Type__c = 'Pre Planned',ES_Campaign__c = esc.Id, Mail_Quantity__c = 1500, Status__c = 'Draft'));
        insert jobTickets;
        
        // Creating record of Production_Tracking__c
        List<Production_Tracking__c> fullFillmentTrackings = new List<Production_Tracking__c>();
        fullFillmentTrackings.add(new Production_Tracking__c(Job_Ticket__c = jobTickets[0].Id));
        fullFillmentTrackings.add(new Production_Tracking__c(Job_Ticket__c = jobTickets[1].Id));
        fullFillmentTrackings.add(new Production_Tracking__c(Job_Ticket__c = jobTickets[2].Id));
        insert fullFillmentTrackings;
        
        //08/14/2020 - CR-20200812-14419 - Victor Hanson - added of_Drop__c
        // Creating record Job_Ticket__c without Production_Tracking__c
        //modified by Neha Sharma (Added Drop_Type__c missing field) on 05/12/2021
        List<Job_Ticket__c> JobWithoutfullFillmentTracking = new List<Job_Ticket__c>();
        JobWithoutfullFillmentTracking.add(new Job_Ticket__c(ES_Campaign__c = esc.Id, Mail_Quantity__c = 500, Status__c = 'Draft', of_Drops__c = 4, Drop_Type__c = 'Pre Planned'));
        JobWithoutfullFillmentTracking.add(new Job_Ticket__c(ES_Campaign__c = esc.Id, Mail_Quantity__c = 500, Status__c = 'Draft', of_Drops__c = 4, Drop_Type__c = 'Pre Planned'));
        insert JobWithoutfullFillmentTracking;
        
        // Creating record of Job_Ticket_Component__c
        List<Job_Ticket_Component__c> jobTicketComponents = new List<Job_Ticket_Component__c>();
        //Modify by - Shalu Sharma - 5/18/21 - CR-20210315-14997
        jobTicketComponents.add(new Job_Ticket_Component__c(Component__c = Constants.COMPONENT_TYPE_BRE));
        jobTicketComponents.add(new Job_Ticket_Component__c(Component__c = Constants.COMPONENT_TYPE_BRE));
        insert jobTicketComponents;
        
        // Creating record of Job_Ticket_MtM__c
        List<Job_Ticket_MtM__c> jobTicketsMTMs = new List<Job_Ticket_MtM__c>();
        jobTicketsMTMs.add(new Job_Ticket_MtM__c(Job_Ticket__c = JobWithoutfullFillmentTracking[0].Id, Job_Ticket_Component__c = jobTicketComponents[0].Id));
        jobTicketsMTMs.add(new Job_Ticket_MtM__c(Job_Ticket__c = JobWithoutfullFillmentTracking[0].Id, Job_Ticket_Component__c = jobTicketComponents[1].Id));
        insert jobTicketsMTMs;
        
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
    }
    
    @IsTest static void testBatchCreateFulfillmentTracking()
    {
        // List of job ticket with fullFillment records
        List<Job_Ticket__c> jobTicketsWithFullFillment = [SELECT Id, Name, ES_Campaign__c, Mail_Quantity__c, (SELECT Id FROM Fulfillment_Tracking__r) FROM Job_Ticket__c];
        
        // List of job Tickets without fullFillment records
        List<Job_Ticket__c> jobTicketsWithoutFullFillment = [SELECT Id, Name, ES_Campaign__c, Mail_Quantity__c FROM Job_Ticket__c];
        
        // List Of Job_Ticket_Component__c
        List<Job_Ticket_Component__c> jobTicketComponents = [SELECT Id, Name, Component__c FROM Job_Ticket_Component__c];
        
        // List Of Account
        List<Account> institutions = [SELECT Id, Vendor_Type__c, Name FROM Account];
        
        // List Of Vendor_Component_Pricing__c
        List<Vendor_Component_Pricing__c> vendorComponentPricings = [SELECT Id, Vendor__c, Job_Ticket_Component__c FROM Vendor_Component_Pricing__c];
        
        // List Of Vendor_Pricing_Per_Unit__c
        List<Vendor_Pricing_Per_Unit__c> vendorPricingPerUnits = [SELECT Id, Quantity_Maximum__c, Quantity_Minimum__c, Vendor_Component_Pricing__c,
                                                                  Vendor_Component_Pricing__r.Job_Ticket_Component__c,
                                                                  Price_Effective_End_Date__c, Price_Effective_Start_Date__c, Active__c
                                                                  FROM Vendor_Pricing_Per_Unit__c];
        // List of Job_Ticket_MtM__c
        List<Job_Ticket_MtM__c> jobTicketsMTMs = [SELECT Id, Name, Job_Ticket__c, Job_Ticket_Component__c FROM Job_Ticket_MtM__c];
        
        // Creating Set To store Job_Ticket__c Id
        Set<Id> jobTicketIds = new Set<Id>();
        
        for(Job_Ticket__c jobTicket : jobTicketsWithoutFullFillment)
        {
            jobTicketIds.add(jobTicket.Id);
        }
        
        Test.startTest();
        
        system.assertEquals(true , jobTicketIds.size() > 0);
        Batch_CreateFulfillmentTracking batch = new Batch_CreateFulfillmentTracking(jobTicketIds); 
        Database.executeBatch(batch,200);
        
        Test.stopTest();

        //get production tracking records
        List<Job_Ticket__c> jtsWithProdTracking = [SELECT Id, (SELECT Id, Drop__c, Previous_Production_Tracking__c
                                                                FROM Fulfillment_Tracking__r WHERE RecordType.Name = 'Mail Shop') 
                                                    FROM Job_Ticket__c WHERE Id IN :jobTicketsWithoutFullFillment];
        system.assertEquals(5, jtsWithProdTracking.size());
        for (Job_Ticket__c jt : jtsWithProdTracking) {
            for (Production_Tracking__c pt : jt.Fulfillment_Tracking__r) {
                //verify the previous production tracking record is populated
                if (pt.Drop__c > 1)
                    system.assertNotEquals(null, pt.Previous_Production_Tracking__c);
            }
        }
        
        /* // Commented By Rajeev Jain - for Release Validation bug Fix L1 Weekly Release - 7/2 (As this is already commented in Main Class)
        List<Job_Ticket_Estimate_Component__c> jobTicketEstimateComponents = [SELECT Id FROM Job_Ticket_Estimate_Component__c];
        system.assertEquals(2, jobTicketEstimateComponents.size());
        
        List<Job_Ticket_Estimates__c> jobTicketEstimates = [SELECT Id FROM Job_Ticket_Estimates__c];
        system.assertEquals(2, jobTicketEstimates.size());*/
    }
}