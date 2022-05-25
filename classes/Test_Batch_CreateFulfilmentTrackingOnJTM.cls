/**
 *  Purpose         :   Class is used to test the Functionality Batch_CreateFulfilmentTrackingOnJTM
 *
 *  Created By      :   Dipesh Gupta
 *
 *  Created Date    :   13/12/2019
 *
 *  Revision Logs   :   V1_0 - Modified By - Abhinav Sharma - CR-20200821-14466 - 8/25/2020 - start - Create Print Prod Tracking for Env & BREs component type and vendor type = 'Digital'
 *                      V1.1 - Modified By - Abhinav Sharma - CR-20200714-14298 - Updated the Back_of_Colors__c field value in test data as per the CR changes *
 *			V1.2 - Modified By - Abhinav Sharma - CR-20201118-14702 - Populate "Print Production Manager" on Prod Tracking
 * 			V1.3 - Modified By - Abhinav Sharma - 02/05/2021 - CR-20210108-14792 - JT Component field and record updates
 *			V1.4 - Modified By - Abhinav Sharma - 03/01/2021 - CR-20201111-14688
 * 			V1.5 - Modified By - Shalu Sharma - 5/18/21 - CR-20210315-14997 - Update the "BRE" to "Reply Envelope (BRE/CRE)"
 *                     
**/
@isTest(seeAllData=false)
public class Test_Batch_CreateFulfilmentTrackingOnJTM {
    
    @testSetup static void dataSetup()
      {
          // TO DO: implement unit test      
          //Bypass Flags
          Util.IsTest(true);
          Util.isTesting = true;
          Util.byPassAllTriggers = true;
          
         
          Job_Ticket__c jobTicket = PrintManagementTestDataFactory.CreateNewJobTicket(true);
          Job_Ticket_Component__c jobTicketComponent = PrintManagementTestDataFactory.CreateNewJobTicketComponent(true);
          
          Vendor_Component_Pricing__c vendorComponentPricing = PrintManagementTestDataFactory.CreateNewVendorComponentPricing(false);
          vendorComponentPricing.Job_Ticket_Component__c =  jobTicketComponent.Id ;
          
          insert vendorComponentPricing;
          
          Vendor_Pricing_Per_Unit__c vendorPricingPerUnit = PrintManagementTestDataFactory.CreateNewVendorPricingPerUnit(false);
          vendorPricingPerUnit.Vendor_Component_Pricing__c  = vendorComponentPricing.Id;
          vendorPricingPerUnit.Price_Effective_Start_Date__c = System.today() ;
          vendorPricingPerUnit.Price_Effective_End_Date__c = System.today()+1;
          //vendorPricingPerUnit.Quantity_Minimum__c = 4000;
          vendorPricingPerUnit.Quantity_Maximum__c = 40000;
          insert vendorPricingPerUnit;          
          
          
          List<Job_Ticket_MtM__c> jobTicketMtMs = new List<Job_Ticket_MtM__c>();
          for(Integer i=0; i<10; i++){
              
              
              Job_Ticket_MtM__c jobTickectMTM = new Job_Ticket_MtM__c();
              jobTickectMTM.Job_Ticket__c = jobTicket.Id;
              jobTickectMTM.Job_Ticket_Component__c = jobTicketComponent.Id;
              //Modify by - Shalu Sharma - 5/18/21 - CR-20210315-14997
              jobTickectMTM.Component_Type__c = Constants.COMPONENT_TYPE_BRE;
              jobTickectMTM.Front_of_Colors__c = 1;
              //Modified By Abhinav Sharma - CR-20200714-14298 - Updated the test data as per the CR changes
              jobTickectMTM.Back_of_Colors__c = 1000 ;
              jobTicketMtMs.add(jobTickectMTM);
          }
          
          insert jobTicketMtMs;
          
          
          
          
          
          /*Select Id, Quantity_Maximum__c, Quantity_Minimum__c, 
                                                                  Vendor_Component_Pricing__r.Job_Ticket_Component__c, Vendor_Component_Pricing__r.Vendor__c,
                                                                 Vendor_Component_Pricing__c,  Active__c From Vendor_Pricing_Per_Unit__c 
                                                                 Where Vendor_Component_Pricing__r.Job_Ticket_Component__c IN: mapJobTktWithComponentIds.keyset() 
                                                                 AND Active__c = true*/
          
          
      }
    
    static testmethod void test_Batch_CreateFulfilmentTrackingOnJTM() {
        
        //Bypass Flags
          Util.IsTest(true);
          Util.isTesting = true;
          Util.byPassAllTriggers = true;
        
        List<Job_Ticket__c> jobTickets = [SELECT Id FROM Job_Ticket__c];
        System.debug('jobTickets'+jobTickets);
        System.debug('jobTickets'+jobTickets.size());
        System.assertEquals(1, jobTickets.size());
        
        Set<Id> setOfJobTicketId = new Set<Id>{jobTickets[0].Id};
        
        Test.startTest();
        
        Batch_CreateFulfilmentTrackingOnJTM obj = new Batch_CreateFulfilmentTrackingOnJTM(setOfJobTicketId);
        DataBase.executeBatch(obj); 
        
        Test.stopTest();
        
        List<Production_Tracking__c> fulfillment = [Select Id,of_Colors_Back__c,Job_Ticket__c From Production_Tracking__c];
        System.assertEquals(jobTickets[0].Id, fulfillment[0].Job_Ticket__c);
        //Added the assert for the of_Colors_Back__c to check the value - Abhinav Sharma - CR-20200714-14298 - 
        System.assertEquals(1000, fulfillment[0].of_Colors_Back__c);
        
        
        List<Job_Ticket_Estimate_Component__c> jobTEs = [Select Id, Job_Ticket_Component__c From Job_Ticket_Estimate_Component__c];
        
        
    }
    
    // Modify By - Abhinav Sharma - CR-20200821-14466 - 8/25/2020 - start - Create Print Prod Tracking for Env & BREs component type and vendor type = 'Digital'
    // Modified By - Abhinav Sharama - CR-20201118-14702 - Populate "Print Production Manager" on Prod Tracking
    static testmethod void test_JobTicketWithOutDigital() {
        
          // TO DO: implement unit test      
          //Bypass Flags
          Util.IsTest(true);
          Util.isTesting = true;
          Util.byPassAllTriggers = true;
          
         
          Job_Ticket__c jobTicket = PrintManagementTestDataFactory.CreateNewJobTicket(false);
          jobTicket.Vendor_Type__c = 'Digital';
          jobTicket.Production_Manager__c = UserInfo.getUserId();
          insert jobTicket;
        
          Job_Ticket_Component__c jobTicketComponent = PrintManagementTestDataFactory.CreateNewJobTicketComponent(true);
          
          List<Job_Ticket_MtM__c> jobTicketMtMs = new List<Job_Ticket_MtM__c>();
          //Modify by - Shalu Sharma - 5/18/21 - CR-20210315-14997
          jobTicketMtMs.add(new Job_Ticket_MtM__c(Job_Ticket__c = jobTicket.Id,Job_Ticket_Component__c = jobTicketComponent.Id,Component_Type__c = Constants.COMPONENT_TYPE_BRE));
          jobTicketMtMs.add(new Job_Ticket_MtM__c(Job_Ticket__c = jobTicket.Id,Job_Ticket_Component__c = jobTicketComponent.Id,Component_Type__c = 'Form'));
          jobTicketMtMs.add(new Job_Ticket_MtM__c(Job_Ticket__c = jobTicket.Id,Job_Ticket_Component__c = jobTicketComponent.Id,Component_Type__c = 'Envelope'));
          //Modified By - Abhinav Sharma - 02/05/2021 - CR-20210108-14792 - JT Component field and record updates (Cut Sheet value is deactiavted)
          jobTicketMtMs.add(new Job_Ticket_MtM__c(Job_Ticket__c = jobTicket.Id,Job_Ticket_Component__c = jobTicketComponent.Id,Component_Type__c = Label.Component_Type_Value));
 
          insert jobTicketMtMs;
        
        List<Job_Ticket__c> listOfJobTicket = [Select Id, ES_Campaign__c, Mail_Quantity__c, Vendor_Type__c, (Select Id From Job_Ticket_MtM__r) From Job_Ticket__c where Id =: jobTicket.Id];
        system.assertEquals(4, listOfJobTicket[0].Job_Ticket_MtM__r.size());
        system.assertEquals('Digital', listOfJobTicket[0].Vendor_Type__c);
        
        Set<Id> setOfJobTicketId = new Set<Id>{jobTicket.Id};
        
        Test.startTest();
        
        Batch_CreateFulfilmentTrackingOnJTM obj = new Batch_CreateFulfilmentTrackingOnJTM(setOfJobTicketId);
        DataBase.executeBatch(obj); 
        
        Test.stopTest(); 
        
        List<Production_Tracking__c> fulfillment = [Select Id,Job_Ticket__c From Production_Tracking__c];
        System.assertEquals(2, fulfillment.size());
        
        List<Job_Ticket_MtM__c> listOfJobTicketMtM = [Select Id,Job_Ticket__c, Status__c, (Select Id From Fulfillment_Tracking__r) From Job_Ticket_MtM__c where Job_Ticket__c =:jobTicket.Id];
        System.assertEquals(1, listOfJobTicketMtM[0].Fulfillment_Tracking__r.size());
        System.assertEquals(0, listOfJobTicketMtM[1].Fulfillment_Tracking__r.size());
        System.assertEquals(1, listOfJobTicketMtM[2].Fulfillment_Tracking__r.size());
        System.assertEquals(0, listOfJobTicketMtM[3].Fulfillment_Tracking__r.size());
        //Added By - Abhinav Sharma - 03/01/2021 - CR-20201111-14688 - Create Print PT when JT MtM is created
        System.assertEquals('Approved', listOfJobTicketMtM[0].Status__c);//End
        
        //Modified By - Abhinav Sharama - CR-20201118-14702 - Populate "Print Production Manager" on Prod Tracking
        List<Production_Tracking__c> fulfillmentTracking = [Select Id,Job_Ticket__c, Print_Production_Manager__c, Status__c From Production_Tracking__c];
        System.assertEquals(jobTicket.Production_Manager__c, fulfillmentTracking[0].Print_Production_Manager__c);
        //Added By - Abhinav Sharma - 03/01/2021 - CR-20201111-14688 - Create Print PT when JT MtM is created
        System.assertEquals('Approved by Partner', fulfillmentTracking[0].Status__c);//End
    }

}