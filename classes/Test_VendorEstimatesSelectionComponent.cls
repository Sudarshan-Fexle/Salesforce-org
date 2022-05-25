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
    /**
      *   Purpose         :   Test class for SBQQ_SubscriptionTrigger
      *            
      *   Create By       :   Dipesh Gupta
      * 
      *   Created Date    :   12/02/2019
      *
      *   Revision Log    :   V_1.0 - Created - Dipesh Gupta 
      *   
      *   Coverage        :   V_1.0 - 
      *
      **/
@isTest(seeAllData = false)
private class Test_VendorEstimatesSelectionComponent
{
    @testSetup static void dataSetup()
    {
        Util.IsTest(true);
        Util.isTesting = true;
        Util.byPassAllTriggers = true;
        
        Id fullfillmentTrackingId = PrintManagementTestDataFactory.CreateNewFulFillmentTracking(true).Id;
        
        Id accountId = TestUtilities.CreateNewAccount(true).Id;
        
        Production_Tracking__c fulFillment = PrintManagementTestDataFactory.CreateNewFulFillmentTracking(true);

        Job_Ticket_Component__c jobTicketComps = PrintManagementTestDataFactory.CreateNewJobTicketComponent(true);
        
        List<Job_Ticket_Estimates__c> jobTicketEstimates = new List<Job_Ticket_Estimates__c>();
        jobTicketEstimates.add(new Job_Ticket_Estimates__c(Production_Tracking__c = fullfillmentTrackingId, Vendor_Name__c = accountId, Total_Price__c = 1000, Mail_Quantity__c = 100, Selected_Estimate__c = true));
        jobTicketEstimates.add(new Job_Ticket_Estimates__c(Production_Tracking__c = fullfillmentTrackingId, Vendor_Name__c = accountId, Total_Price__c = 1000, Mail_Quantity__c = 100, Selected_Estimate__c = true));
        jobTicketEstimates.add(new Job_Ticket_Estimates__c(Production_Tracking__c = fullfillmentTrackingId, Vendor_Name__c = accountId, Total_Price__c = 1000, Mail_Quantity__c = 100, Selected_Estimate__c = false));
        jobTicketEstimates.add(new Job_Ticket_Estimates__c(Production_Tracking__c = fullfillmentTrackingId, Vendor_Name__c = accountId, Total_Price__c = 1000, Mail_Quantity__c = 100, Selected_Estimate__c = false));
        jobTicketEstimates.add(new Job_Ticket_Estimates__c(Production_Tracking__c = fullfillmentTrackingId, Vendor_Name__c = accountId, Total_Price__c = 1000, Mail_Quantity__c = 100, Selected_Estimate__c = true));
        insert jobTicketEstimates;

        List<Job_Ticket_Estimate_Component__c> jobEstimateComponent = new List<Job_Ticket_Estimate_Component__c>();
        jobEstimateComponent.add(new Job_Ticket_Estimate_Component__c(Job_Ticket_Estimate__c = jobTicketEstimates[0].Id,
                                                                      Job_Ticket_Component__c = jobTicketComps.Id));
        insert jobEstimateComponent;
        
        Util.byPassAllTriggers = false;
    }
    
    //Test method
    static testMethod void myUnitTest() {
    	
    	//Get 
    	List<Job_Ticket_Estimates__c> jobTicketEstimates = [Select Id From Job_Ticket_Estimates__c];

        //Get
        List<Job_Ticket_Estimate_Component__c> jobTicketsEstimateComps = [SELECT Id FROM Job_Ticket_Estimate_Component__c];
        System.assertEquals(1, jobTicketsEstimateComps.size());
        
        //Get
        List<Production_Tracking__c> fulfillments = [Select Id From Production_Tracking__c];
    	
    	//Assert
    	System.assertEquals(5, jobTicketEstimates.size());
        
        test.startTest();
        //Standard controller       
        ApexPages.StandardController sc = new ApexPages.standardController(fulfillments[0]);
        
        //Controller
        VendorEstimatesSelectionComponent_Ext controller = new VendorEstimatesSelectionComponent_Ext(sc);
        controller.doSaveChanges();

        test.stopTest();
            
    }
}