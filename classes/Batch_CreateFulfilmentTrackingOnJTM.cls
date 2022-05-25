/**
 *  Purpose         :  This batch is used to create the Fullfillment tracking and Job ticket Estimates, 
 *                     Job Ticket estimates component object records based on the related object values. 

                        
 *                     
 *  Created By      :   Dipesh Gupta
 *
 *  Created Date    :   10/14/2019
 *
 *  Revision Logs   :   V_1.0 - Created  - CR-20191011-13405
 *                      V1.1 Modified By - Dipesh Gupta - 02/14/2020 - CR-20200128-13670 -  Does the change to poulate the project manager 
                                                                                            on production tracking from job ticket.
                        V1.2 - Modified By - Colin McGloin - 06/23/2020 - CR-20200619-14208 - Added logic to prevent duplicates being created // Commented out unnecessary code
			V1.3 - Modified By - Victor Hanson - 07/16/2020 - CR-20200716-14325 - added sendBatchStatus
			V1.4 - Modified By Abhinav Sharma - CR-20200616-14191 - Approval Reminders
			V1.5 - Modified By Abhinav Sharma - CR-20200714-14298 - Updated/Corrected "of_Colors_Back__c" Field mappings
     			V1.6 - Modify By - Abhinav Sharma - CR-20200821-14466 - 8/25/2020 - Added the logic to create production tracking record for 
 			                                                                    Job ticket.Vendor_Type__c = 'Digital' and (Component Type = 'BRE' OR Component Type = 'Envelope')
			V1.7 - Modified By - Abhinav Sharma - CR-20200914-14509 - 10/07/2020
			V1.8 - Modified By - Abhinav Sharama - CR-20201118-14702 - Populate "Print Production Manager" on Prod Tracking
                        V1.9 - Modified By - Abhinav Sharma - 03/01/2021 - CR-20201111-14688 - Create Print PT when JT MtM is created
			V2.0 - Modified By - Abhinav Sharma - 05/19/2021 - CR-20210518-15161 - Changing the "Production_Tracking_Created__c = true" location
			V2.1 - Modified By - Victor Hanson - 04/16/2021 - CR-20210420-15089 - added logic to support Inventory Tracking
**/
global class Batch_CreateFulfilmentTrackingOnJTM implements Database.Batchable<sObject>  
{    
    //Set to hold the Ids of Job Tickets. 
    set<Id> setOfJobTicketIds = new set<Id>();
    
    // Modified By - Victor Hanson - 07/16/2020 - CR-20200716-14325
    public String debugLogs = '';
    
    //Constructor for the getting the Set of Job Tickets Id  as a Parameter. 
    public  Batch_CreateFulfilmentTrackingOnJTM (Set<Id> setOfJobTicketIds) 
    {
        this.setOfJobTicketIds = setOfJobTicketIds;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) 
    {
        String query = 'Select Id, ES_Campaign__c, Mail_Quantity__c, Vendor_Type__c, (Select Id From Job_Ticket_MtM__r) From Job_Ticket__c Where Id IN: setOfJobTicketIds';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Job_Ticket__c> jobTkts)
    {
        //Map to hold the Eligible Job tickets. 
        Map<Id, Job_Ticket__c> mapEligibleJobTickets = new Map<Id, Job_Ticket__c>();

        //Map to hold the Job ticket with the List of Job ticket Mtm 
        Map<String, Job_Ticket_MTM__c> mapUniqueKeyMtms = new map<String, Job_Ticket_MTM__c>();

        //Set to hold the JOb ticket components.
        Set<Id> setOfJobTicketComponentIds = new Set<Id>();

        //Map to hold the Job Ticket Components. 
        Map<Id, List<Job_Ticket__c>> mapJobTktWithComponentIds = new Map<Id, List<Job_Ticket__c>>();

        //Map to hold the  with Vendor Component Pricing  with Vendor program per unit.
        Map<Id, List<Vendor_Pricing_Per_Unit__c>> mapVendorcomponentWithPricingPerUnit = new Map<Id, List<Vendor_Pricing_Per_Unit__c>>();

        //Map to hold the wrapper class. 
        Map<String, JobTicketRelatedObjectWrapper> mapJobtktWrappers = new Map<String, JobTicketRelatedObjectWrapper>();

        //Map to hold the vendor Component Pricing and it's vendor. 
        Map<String, String> mapVendorPricingComWithVendor = new Map<String, String>();

        //Get our Queue to set the Owner
        List<Group> printQueue = [SELECT Id from Group WHERE Name = 'Print Team' and Type = 'Queue'];
    
        //Check for the Job type if it is eligible.
        for(Job_Ticket__c jobTicket : jobTkts) 
        {
            //04/09/2020 - Victor Hanson - CR-20200325-13887 - Added check for Vendor Type not equal Digital
            // Modify By - Abhinav Sharma - CR-20200821-14466 - 8/25/2020  - Comment the  check for Vendor Type not equal Digital
            if(jobTicket != null && jobTicket.Job_Ticket_MtM__r.size() > 0 /*&& jobTicket.Vendor_Type__c != Constants.VENDOR_TYPE_DIGITAL*/)
                //Check the type. 
                mapEligibleJobTickets.put(jobTicket.Id, jobTicket);
        }

        //Check the size of batch. 
        if(mapEligibleJobTickets.size() > 0) 
        {
            //Map of fulfillment tracking
            Map<Id, Production_Tracking__c> mapfulfillmentTrackings = new Map<Id, Production_Tracking__c>();

            //List of JT MtM records to update Modified By - Colin McGloin - 06/23/2020 - CR-20200619-14208
	    //Added by Abhinav Sharma - CR-20200616-14191 - Approval Reminders
            List<Job_Ticket_MTM__c> jtmToUpdate = new List<Job_Ticket_MTM__c>();
            
            //04/16/2021 - CR-20210420-15089 - Victor Hanson - get a map of componentCode to InventoryTransaction
            Set<String> setComponentCodes = new Set<String>();
            List<Inventory_Transaction__c> invTransactionsToUpdate = new List<Inventory_Transaction__c>();
            Map<String, Inventory_Transaction__c> mapComponentCodeToInventoryTransaction = new Map<String, Inventory_Transaction__c>();
            for (Job_Ticket_MTM__c jTM : [Select Id, Component_Code__c From Job_Ticket_MTM__c 
                                          Where Job_Ticket__c =: mapEligibleJobTickets.keyset() 
                                          AND Production_Tracking_Created__c = false])
            {
                setComponentCodes.add(jTM.Component_Code__c);
            }
            
            for (Inventory_Transaction__c invTransaction : [SELECT Id, Inventory__r.Inventory_Control_Number__c, Job_Ticket_MtM__c,
                                                            Inventory__r.Quantity_Available__c, Quantity__c, Status__c
                                                            FROM Inventory_Transaction__c 
                                                            WHERE Job_Ticket_MtM__r.Job_Ticket__c IN :mapEligibleJobTickets.keyset() 
                                                            AND Inventory__r.Inventory_Control_Number__c IN :setComponentCodes]) 
            {
                mapComponentCodeToInventoryTransaction.put(invTransaction.Inventory__r.Inventory_Control_Number__c, invTransaction);
            }
            
            //04/16/2021 - CR-20210420-15089 - Victor Hanson - added Component_Code__c & Job_Ticket__r to query
            //Modified By - Abhinav Sharma - 03/01/2021 - CR-20201111-14688 - Create Print PT when JT MtM is created (Add Status, Approved DateTime)
            //Job ticket Mtm 
            for(Job_Ticket_MTM__c jTM : [Select Id, Component_Type__c, Job_Ticket_Component__c,  Window_Size__c, Job_Ticket__c, Job_Ticket__r.Project_Manager__c,
                                         Job_Ticket__r.Mail_Quantity__c, Job_Ticket__r.ES_Campaign__c, Job_Ticket_Component__r.Size__c, Front_of_Colors__c, Back_of_Colors__c,
                                         Job_Ticket_Component__r.Paper_Weight__c, Job_Ticket_Component__r.Paper_Type__c, 
                                         Fold__c, Paper_Weightx__c, Paper_Typex__c, Print_Method__c, Notes__c, Job_Ticket_Component__r.Component__c,
                                         Job_Ticket__r.Art_Director__c, Job_Ticket__r.Project_Manager__r.ManagerId, Job_Ticket__r.Production_Manager__c,
                                         Status__c, Approved_DateTime__c, Component_Code__c, Job_Ticket__r.Mail_Date__c
                                         From Job_Ticket_MTM__c 
                                         Where Job_Ticket__c =: mapEligibleJobTickets.keyset()
                                         AND Production_Tracking_Created__c = false]) 
            {
                                             
                //String to hold the unique key. 
                String uniqueKey = jTM.Job_Ticket_Component__c + '-' + jTM.Job_Ticket__c;

                //Condition to get the job ticket component exist.
                if(!mapJobTktWithComponentIds.containsKey(jTM.Job_Ticket_Component__c)) 
                    mapJobTktWithComponentIds.put(jTM.Job_Ticket_Component__c, new List<Job_Ticket__c>());
                 
                //Filling map.
                mapJobTktWithComponentIds.get(jTM.Job_Ticket_Component__c).add(mapeligibleJobTickets.get(jTM.Job_Ticket__c));

                //Filling map.
                mapUniqueKeyMtms.put(uniqueKey, jTM);

                //Initialising the fulfillnent records.
                Production_Tracking__c fulfillment = new Production_Tracking__c();

                fulfillment.Job_Ticket_MTM__c = jTM.Id;
                fulfillment.Job_Ticket__c = jTM.Job_Ticket__c;
                //fulfillment.Print_Quantity_Planned__c = jTM.Job_Ticket__r.Mail_Quantity__c; //Commented By - Colin McGloin - 06/23/2020 - CR-20200619-14208
                fulfillment.Component__c = jTM.Job_Ticket_Component__r.Component__c;
                fulfillment.Window__c 	= jTM.Window_Size__c;
                fulfillment.ES_Campaign__c = jTM.Job_Ticket__r.ES_Campaign__c;
                fulfillment.Size__c = jTM.Job_Ticket_Component__r.Size__c;
                fulfillment.Print__c = jTM.Print_Method__c;
                fulfillment.of_Colors_Front__c = jTM.Front_of_Colors__c;
                
                //V1.5 - Modified By Abhinav Sharma - CR-20200714-14298 - Updated/Corrected Fields mappings
                fulfillment.of_Colors_Back__c = jTM.Back_of_Colors__c;
                                            
                fulfillment.Paper_Weight__c = jTM.Paper_Weightx__c;
                fulfillment.Paper_Type__c = jTM.Paper_Typex__c;
                fulfillment.Type_of_Fold__c = jTM.Fold__c;
                fulfillment.Print_Shop_Notes__c = jTM.Notes__c;
                
                //--------Start - CR-20200128-13670 - By Dipesh Gupta - 2/14/2020 ------
                fulfillment.JT_Project_Manager__c = jTM.Job_Ticket__r.Project_Manager__c;
                fulfillment.JT_Art_Director_LU__c = jTM.Job_Ticket__r.Art_Director__c;
                //--------End ----
                
                //Added by Abhinav Sharma - CR-20200616-14191 - Approval Reminders
                fulfillment.JT_PM_Manager__c = jTM.Job_Ticket__r.Project_Manager__r.ManagerId;
		
                //Added by Abhinav Sharama - CR-20201118-14702 - Populate "Print Production Manager" on Prod Tracking                            
                fulfillment.Print_Production_Manager__c = jTM.Job_Ticket__r.Production_Manager__c; //End
                                            
                //Added By - Abhinav Sharma - 03/01/2021 - CR-20201111-14688 - Create Print PT when JT MtM is created
                fulfillment.Status__c = Label.Print_Production_Tracking_Creation_Status;
                jTM.Status__c = Label.Status_Approved;
                jTM.Approved_DateTime__c = System.now(); //End
                //Modified By - Abhinav Sharma - 05/19/2021 - CR-20210518-15161 - Changing the Production_Tracking_Created__c = true location                   
                //Added by Colin McGloin - CR-20200619-14208
                jTM.Production_Tracking_Created__c = true;
                
                //04/20/2021 - CR-20210420-15089 - Victor Hanson - default mail date (planned) & proof generation
                fulfillment.Planned_Mail_Date__c = jTM.Job_Ticket__r.Mail_Date__c;
                fulfillment.Proof_Generation__c = ProductionTrackingTriggerHelper.PROOF_GENERATION_EXTERNAL;
                
                //04/16/2021 - CR-20210420-15089 - Victor Hanson - get the related Inventory Transaction
                Inventory_Transaction__c invTransaction = mapComponentCodeToInventoryTransaction.get(jTM.Component_Code__c);
                if (invTransaction != null) 
                {
                    invTransaction.Job_Ticket_MtM__c = jTM.Id;
                    invTransactionsToUpdate.add(invTransaction);
                    //print quantity is the Inventory Transaction Quantity
                    if (invTransaction.Quantity__c > 0)
                        fulfillment.Print_Quantity_Planned__c = invTransaction.Quantity__c;
                }
                                             
                //Set Record Type to Print
                Id printRTId = Schema.SObjectType.Production_Tracking__c.getRecordTypeInfosByName().get('Print').getRecordTypeId();
                fulfillment.recordtypeId = printRTId;

                //Set our Owner
                if (printQueue.size() > 0){
                    fulfillment.OwnerId = printQueue[0].Id;
                }
                
                // Modify By - Abhinav Sharma - CR-20200821-14466 - 8/25/2020 - start - Create Print Prod Tracking for Env & BREs component type and vendor type = 'Digital'
                if(mapeligibleJobTickets.get(jTM.Job_Ticket__c).Vendor_Type__c == Constants.VENDOR_TYPE_DIGITAL && (jTM.Component_Type__c == Constants.COMPONENT_TYPE_BRE || jTM.Component_Type__c == Constants.COMPONENT_TYPE_ENVELOPE)){
                    
                    //Add the instance to the map.
                    mapfulfillmentTrackings.put(jTM.Id, fulfillment);
                    
                    jtmToUpdate.add(jTM);
                    
                }
                else if(mapeligibleJobTickets.get(jTM.Job_Ticket__c).Vendor_Type__c != Constants.VENDOR_TYPE_DIGITAL){
                    //Add the instance to the map.
                    mapfulfillmentTrackings.put(jTM.Id, fulfillment);
                    
                    jtmToUpdate.add(jTM);                              
                }
                // Modify By - Abhinav Sharma - CR-20200821-14466 - 8/25/2020 - End here -
            }
            try 
            {
                //Check for the list size. 
                if(mapfulfillmentTrackings.size() > 0)
                    insert mapfulfillmentTrackings.values();
                
                //Added by Colin McGloin - CR-20200619-14208
                if (jtmToUpdate.size() > 0)
                    update jtmToUpdate;
                
                //04/16/2021 - CR-20210420-15089 - Victor Hanson - set production tracking id on Inv Tracking
                for (Production_Tracking__c pt : mapfulfillmentTrackings.values()) 
                {
                    for (Inventory_Transaction__c invT : invTransactionsToUpdate) 
                    {
                        if (pt.Job_Ticket_MtM__c == invT.Job_Ticket_MtM__c) 
                        {
                            invT.Production_Tracking__c = pt.Id;
                            break;
                        }
                    }
                }
                
                if (invTransactionsToUpdate.size() > 0)
                    update invTransactionsToUpdate;
            }
            catch(Exception e) 
            {
                debugLogs += e.getMessage();
            }
        }
    }
    
    global void finish(Database.BatchableContext bc)
    {
        // execute any post-processing operations
        
	// Modified By - Abhinav Sharma - CR-20200914-14509 - 10/07/2020
        //Batch_CreateBoxFolderForJT batchJobTicket = new Batch_CreateBoxFolderForJT(setOfJobTicketIds);
        //Database.executeBatch(batchJobTicket, Integer.valueOf(Label.ProductionTracking_BoxBatchSize));
        
        //04/19/2021 - CR-20210420-15089 - Victor Hanson - added
        Batch_CreateBoxFolderForPT batchProductionTracking = new Batch_CreateBoxFolderForPT(setOfJobTicketIds);
        Database.executeBatch(batchProductionTracking, Integer.valueOf(Label.ProductionTracking_BoxBatchSize));
        
        // Modified By - Victor Hanson - 07/16/2020 - CR-20200716-14325
        if(debugLogs != '')
        {
            Util.sendBatchStatus(BC.getJobId(), 'Batch_CreateFulfilmentTrackingOnJTM', debugLogs, userInfo.getUserEmail());        
        }
    }   

    //Class to use for the combine properties of related objects in the above Batch. 
    public Class JobTicketRelatedObjectWrapper 
    {
        //Class variables to hold the properties. 
        public Job_Ticket__c jobTicket;
        public Id jobTicketComponentId;
        public Map<Id, List<Vendor_Pricing_Per_Unit__c>> mapVendorPricingPerUnit;
        public String colorBreakdown;
    }
}