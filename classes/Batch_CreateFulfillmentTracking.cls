/**
*  Purpose         :  This batch is used to create the Fullfillment tracking and Job ticket Estimates, 
*                     Job Ticket estimates component object records based on the related object values. 
*                     
*  Created By      :   Dipesh Gupta
*
*  Created Date    :   10/14/2019
*
*  Revision Logs   :   V_1.0 - Created  - CR-20191011-13405
*                      V_1.1 - Modified - CR-20200211-13723 - Added back in mapping of Mailshop fields from Job Ticket to Production Tracking
*                      V_1.2 - Modified - CR-20200128-13670 - Dipesh Gupta - 02/14/2020   Does the change to poulate the project manager 
*                                                                                         on production tracking from job ticket.
*                      V_1.3 - Modified - CR-20200415-13953 - Dipesh Gupta - 04/23/2020 - Production Tracking layout and workflow updates
*		       V_1.4 - Modified - CR-20200304-13828 - Victor Hanson - Added field automation for first drop digital prod tracking records
*                      V_1.5 - Modified - CR-20200616-14191 - Abhinav Sharma - Approval Reminders
*		       V_1.6 - Modified - CR-20200812-14419 - Victor Hanson  - 08/14/2020 - Corrected misspelled variable name & added code to populate previous production tracking
*		       V_1.7 - Modified - CR-20201105-14666 - Abhinav Sharma - 01/05/2021 - Add automation when Drop # is updated on JT
*		       V_1.8 - Modified - CR-20210524-15178 - Abhinav Sharma - 05/24/2021 - To remove the un-necessary system.debug statements and to proper indent the code.
*              	       V_1.9 - Modified - CR-20210330-15044 - Neha Sharma - 06/17/2021 - Remove the Laser field
*		       V_2.0 - Modified - CR-20211102-15560 - Shalu Sharma - 11/15/2021 - Added a check for Mail Shop PT records in mapOfDropWithProductionTracking 
**/
global class Batch_CreateFulfillmentTracking implements Database.Batchable<sObject>, Database.stateful { 
    
    //Set to hold the Ids of Job Tickets. 
    global set<Id> setOfJobTicketIds = new set<Id>();
    
    //Added By - CR-20211102-15560 - Shalu Sharma - 11/15/2021 - Added Mail Shop Record Type Id
    //Get the Mail Shop Record Type Id
    public static final Id mailShopRTId = Schema.SObjectType.Production_Tracking__c.getRecordTypeInfosByName().get('Mail Shop').getRecordTypeId();
    
    //Constructor for the getting the Set of Job Tickets Id  as a Parameter. 
    public Batch_CreateFulfillmentTracking(Set<Id> setOfJobTicketIds) {
        this.setOfJobTicketIds = setOfJobTicketIds;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        //Added by Abhinav Sharma - CR-20200616-14191 - Approval Reminders
        //Modified By - Neha Sharma - 06/17/2021 - CR-20210330-15044 - Removed the Laser field from Query
        //Modified By - CR-20211102-15560 - Shalu Sharma - 11/15/2021 - Add RecordTypeId field in query
        String query = 'Select Id, ES_Campaign__c, Mail_Quantity__c, PO_Box_Setup__c, GrayHair_Tracking__c, Postage_Class__c, Stamp__c, Mail_Date__c,' + 
                        'Insertion_Order__c,Production_Manager__c,'+/*Laser__c*/'MailShop_Notes__c, Precancel_Stamp__c, Vendor_Type__c, Meter__c, Indicia__c, Method__c, Project_Manager__c,Project_Manager__r.ManagerId, of_Drops__c, Keying_Screen__c, (Select Id, Drop__c, Job_Ticket__c, Art_File_Name__c, RecordTypeId From Fulfillment_Tracking__r) ' +
                        'From Job_Ticket__c Where Id IN: setOfJobTicketIds';
        
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<Job_Ticket__c> jobTkts){
        
        //Map to hold the eligible records of Job tickets.
        Map<Id, Job_Ticket__c> mapeligibleJobTickets = new Map<Id, Job_Ticket__c>();
        
        //08/14/2020 - CR-20200812-14419 - Victor Hanson - converted to map
        //List to hold the Fullfillment tracking records that is going to be created based on the Job Tkts. 
        Map<String, Production_Tracking__c> productionTrackingToBeCreated = new Map<String, Production_Tracking__c>();
        
        //Map to hold the Job Ticket Components. 
        Map<Id, List<Job_Ticket__c>> mapJobTktWithComponentIds = new Map<Id, List<Job_Ticket__c>>();
        
        //Map to hold the  with Vendor Component Pricing  with Vendor program per unit.
        Map<Id, List<Vendor_Pricing_Per_Unit__c>> mapVendorcomponentWithPricingPerUnit = new Map<Id, List<Vendor_Pricing_Per_Unit__c>>();
        
        //Map to hold the wrapper class. 
        Map<String, JobTicketRelatedObjectWrapper> mapJobtktWrappers = new Map<String, JobTicketRelatedObjectWrapper>();
        
        //Map to hold the vendor Component Pricing and it's vendor. 
        Map<String, String> mapVendorPricingComWithVendor = new Map<String, String>();
        
        //Added By - Abhinav Sharma - 01/05/2021 - CR-20201105-14666 - Add automation when Drop # is updated on JT
        //Map to hold Drop and Production Tracking 
        Map<Integer, Production_Tracking__c> mapOfDropWithProductionTracking = new Map<Integer, Production_Tracking__c>();
        Map<String, Production_Tracking__c> mapOfDropAndJTWithProductTracking = new Map<String, Production_Tracking__c>();

        //Get our Queue to set the Owner
        List<Group> mailQueue = [SELECT Id from Group WHERE Name = 'Mailshop Team' and Type = 'Queue'];
        
        //Check if these Job Tickets have existing "Fullfillment records."
        for(Job_Ticket__c Jobtkt : jobTkts) {
            
            //Modified By - Abhinav Sharma - 01/05/2021 - CR-20201105-14666 - Add automation when Drop # is updated on JT
            //Check for the Fullfillment records. 
            //if(Jobtkt.Fulfillment_Tracking__r != null && Jobtkt.Fulfillment_Tracking__r.size() > 0) 
            //    continue;
            
            if(Jobtkt.Fulfillment_Tracking__r != null && Jobtkt.Fulfillment_Tracking__r.size() > 0){
                for(Production_Tracking__c pT : Jobtkt.Fulfillment_Tracking__r)
                {
                    //Added By - CR-20211102-15560 - Shalu Sharma - 11/15/2021 - Added a check for Mail Shop PT records in mapOfDropWithProductionTracking 
                    if(pT.RecordTypeId == mailShopRTId){
                        mapOfDropWithProductionTracking.put(Integer.valueOf(pT.Drop__c), pT); 
                    }//End
                }
            } 
            //End Here
            
            //Tickets which doesn't have any fulfillment should be eligible for the further processing. 
            mapeligibleJobTickets.put(Jobtkt.Id, Jobtkt);
            
        }
        
        //Check the size of eligible records. 
        if(mapeligibleJobTickets.size() > 0) {
            
            //Modifed By - CR-20211102-15560 - Shalu Sharma - 11/15/2021 - Comment here and define mailShopRTId on the top
            //Get the Record Type Id
            //Id mailShopRTId = Schema.SObjectType.Production_Tracking__c.getRecordTypeInfosByName().get('Mail Shop').getRecordTypeId();
            
            for(Job_Ticket__c jobtkt : mapeligibleJobTickets.values()) {

                //Integer to track our number of records to create
                Integer mailshopRecordsToCreate = 1;

                //Added by Colin McGloin
                //We need to create a MailShop Ticket for every Drop
                if (jobtkt.of_Drops__c != null && jobtkt.of_Drops__c != 99) {
                    mailshopRecordsToCreate = Integer.valueof(jobtkt.of_Drops__c);
                }

                //Loop through and create as many tickets as needed
                for (Integer i = 1; i <= mailshopRecordsToCreate; i++){
                    
                    //Modified By - Abhinav Sharma - 01/05/2021 - CR-20201105-14666 - Add automation when Drop # is updated on JT
                    if(mapOfDropWithProductionTracking.containsKey(i))
                        continue;

                    //Create our Production Tracking record
                    Production_Tracking__c pTracking = new Production_Tracking__c();

                    //Set our values
                    pTracking.ES_Campaign__c = jobtkt.ES_Campaign__c;
                    pTracking.Job_Ticket__c = jobtkt.Id;
                    //Removed mapping by Colin McGloin - 07/07/2020 - CR-20200610-14169
                    //pTracking.Print_Quantity_Planned__c = jobtkt.Mail_Quantity__c;
                    pTracking.RecordTypeId = mailShopRTId;
                    
                    //--------Start - CR-20200128-13670 - By Dipesh Gupta - 2/14/2020 ------
                    pTracking.JT_Project_Manager__c = jobtkt.Project_Manager__c;
                    //--------End ----

                    //Set our Drop Number
                    pTracking.Drop__c = i;
                    
                    //VH 04/10/2020 - CR-20200304-13828 - If Vendor Type is digital and Drop # = 1, update certain fields on the first Production Tracking record
                    if (jobtkt.Vendor_Type__c == Constants.VENDOR_TYPE_DIGITAL && pTracking.Drop__c == 1) {
                        //automatically set New Art = true
                        pTracking.New_Art__c = true;
                        //set Status = Approved by Client
                        pTracking.Status__c = Constants.PRODUCTION_TRACKING_STATUS_APPROVED_BY_CLIENT;
                        pTracking.Planned_Mail_Date__c = jobtkt.Mail_Date__c;
                    }
                    
            
                    //Mailshop Mapping
                    //Added in by Colin McGloin - 02/13/2019
                    pTracking.PO_Box_Setup__c = jobtkt.PO_Box_Setup__c;
                    pTracking.GrayHair_Tracking__c = jobtkt.GrayHair_Tracking__c;
                    pTracking.Postage_Class__c = jobtkt.Postage_Class__c;
                    pTracking.Stamp__c = jobtkt.Stamp__c;
                    pTracking.Precancel_Stamp__c = jobtkt.Precancel_Stamp__c;
                    pTracking.Meter__c = jobtkt.Meter__c;
                    pTracking.Indicia__c = jobtkt.Indicia__c;
                    pTracking.Method__c = jobtkt.Method__c;
                    pTracking.Keying_Screen__c = jobtkt.Keying_Screen__c;
                    
                    //Added by Dipesh Gupta - 04/23/2020 - CR-20200415-13953 - Production Tracking layout and workflow updates
                    //Start
                    pTracking.Insertion_Order__c = jobtkt.Insertion_Order__c; //End
                    
                    //Added by Dipesh Gupta - 05/01/2020 - CR-20200429-13998 - Production Tracking info from JT population
                    pTracking.Print_Production_Manager__c = jobtkt.Production_Manager__c;
                    //pTracking.BOX_Folder_Link__c = jobtkt.BOX_Folder_Link__c;

                    //Commented By - Neha Sharma - 06/17/2021 - CR-20210330-15044 - Laser field on Job Ticket and Production Tracking object
                    //pTracking.Laser__c = jobtkt.Laser__c; 
                    pTracking.Mail_Shop_Notes__c = jobtkt.MailShop_Notes__c;
                    //Added by Abhinav Sharma - CR-20200616-14191 - Approval Reminders
                    pTracking.JT_PM_Manager__c = jobtkt.Project_Manager__r.ManagerId;

                    //Set our Owner
                    if (mailQueue.size() > 0)
                    {
                        pTracking.OwnerId = mailQueue[0].Id;
                    }
                    
                    //08/14/2020 - CR-20200812-14419 - Victor Hanson - converted to map
                    //Filling the map. 
                    productionTrackingToBeCreated.put(pTracking.Job_Ticket__c + '-' + pTracking.Drop__c, pTracking);

                }
            }
            
            //Inserting the FullFillment Records.
            if(productionTrackingToBeCreated.size() > 0) 
                insert productionTrackingToBeCreated.values();
            
            //Modified By - Abhinav Sharma - 01/05/2021 - CR-20201105-14666 - Add automation when Drop # is updated on JT [Start]
            if(mapOfDropWithProductionTracking.size() > 0)
            {
                for(Production_Tracking__c pT : mapOfDropWithProductionTracking.values())
                {
                    if(pT.Job_Ticket__c != null && pT.Drop__c != null)
                    {
                        if(!mapOfDropAndJTWithProductTracking.containsKey(pT.Job_Ticket__c + '-' + pT.Drop__c))
                            mapOfDropAndJTWithProductTracking.put(pT.Job_Ticket__c + '-' + pT.Drop__c, pT);
                    }
                }
                if(mapOfDropAndJTWithProductTracking.size() > 0)
                    productionTrackingToBeCreated.putAll(mapOfDropAndJTWithProductTracking);
            }
            //End
                
            //08/14/2020 - CR-20200812-14419 - Victor Hanson - populate Previous Production Tracking [start]
            for (Production_Tracking__c pTracking : productionTrackingToBeCreated.values()) 
            {
                String previousPTKey = pTracking.Job_Ticket__c + '-' + (pTracking.Drop__c-1);

                //08/14/2020 - CR-20200812-14419 - Victor Hanson - if drop is greater than 1, populate previous production tracking
                if (pTracking.Drop__c > 1 && productionTrackingToBeCreated.containsKey(previousPTKey)) 
                {
                    //set the previous Production Tracking record
                    pTracking.Previous_Production_Tracking__c = productionTrackingToBeCreated.get(previousPTKey).Id;
                    pTracking.Art_File_Name__c = String.isNotBlank(productionTrackingToBeCreated.get(previousPTKey).Art_File_Name__c) ? productionTrackingToBeCreated.get(previousPTKey).Art_File_Name__c : '';
                }
            }

            util.bypassAllTriggers = true;
            update productionTrackingToBeCreated.values();
            //08/14/2020 - CR-20200812-14419 - Victor Hanson - populate Previous Production Tracking [end]
            
            /*PART 2 - Creating JOB TICKET ESTIMATES and JOB TICKET ESTIMATES COMPONENTS*/
            
            //Query on the JoB Tickets MTM Records to get the Job Ticket Components. 
            for(Job_Ticket_MtM__c jobTktMtm : [Select Id, Job_Ticket__c, Job_Ticket_Component__c 
                                               From Job_Ticket_MtM__c Where Job_Ticket__c IN: mapeligibleJobTickets.keyset() AND Job_Ticket_Component__c != null]) 
            {
                                                   
                if(!mapJobTktWithComponentIds.containsKey(jobTktMtm.Job_Ticket_Component__c)) 
                    mapJobTktWithComponentIds.put(jobTktMtm.Job_Ticket_Component__c, new List<Job_Ticket__c>());
                
                //Filling map.
                mapJobTktWithComponentIds.get(jobTktMtm.Job_Ticket_Component__c).add(mapeligibleJobTickets.get(jobTktMtm.Job_Ticket__c));
            }
            
            //Check for the Job Ticket component set size. 
            if(mapJobTktWithComponentIds.size() > 0 ) 
            {
                
                //Getting the Related pricing records. 
                for(Vendor_Pricing_Per_Unit__c vPricingPerUnit : [Select Id, Quantity_Maximum__c, Quantity_Minimum__c, 
                                                                  Vendor_Component_Pricing__r.Job_Ticket_Component__c, Vendor_Component_Pricing__r.Vendor__c,
                                                                  Vendor_Component_Pricing__c,  Active__c From Vendor_Pricing_Per_Unit__c 
                                                                  Where Vendor_Component_Pricing__r.Job_Ticket_Component__c IN: mapJobTktWithComponentIds.keyset() 
                                                                  AND Active__c = true  ]) 
                {
                    //Fill the map with the Vendor Pricing and it's vendor. 
                    mapVendorPricingComWithVendor.put(vPricingPerUnit.Vendor_Component_Pricing__c, vPricingPerUnit.Vendor_Component_Pricing__r.Vendor__c );
                    
                    //Check for the Job Ticket Components. 
                    if(mapJobTktWithComponentIds != null || mapJobTktWithComponentIds.containsKey(vPricingPerUnit.Vendor_Component_Pricing__r.Job_Ticket_Component__c) ) 
                    {
                        //Initialise the wrapper class. 
                        JobTicketRelatedObjectWrapper jTktWrapper = new JobTicketRelatedObjectWrapper();
                        
                        //Adding the Job Component Id.
                        jTktWrapper.jobTicketComponentId = vPricingPerUnit.Vendor_Component_Pricing__r.Job_Ticket_Component__c;
                        
                        //Loop on the related Job Tkts. 
                        for(Job_Ticket__c jobtkt :  mapJobTktWithComponentIds.get(jTktWrapper.jobTicketComponentId)) 
                        {
                            //Check for the Eligibility of Per Unit Price.
                            if(vPricingPerUnit.Quantity_Maximum__c >= jobtkt.Mail_Quantity__c
                               && vPricingPerUnit.Quantity_Minimum__c <= jobtkt.Mail_Quantity__c ) 
                            {
                                //Check for the quantity match so we can only hold those Vendor pricing per unit record which is in range
                                if(!mapVendorcomponentWithPricingPerUnit.containsKey(vPricingPerUnit.Vendor_Component_Pricing__c) )                                                 
                                    mapVendorcomponentWithPricingPerUnit.put(vPricingPerUnit.Vendor_Component_Pricing__c, new List<Vendor_Pricing_Per_Unit__c>());
                                mapVendorcomponentWithPricingPerUnit.get(vPricingPerUnit.Vendor_Component_Pricing__c).add(vPricingPerUnit);
                                   
                                List<Vendor_Pricing_Per_Unit__c> vppus = new List<Vendor_Pricing_Per_Unit__c>();
                                for(Vendor_Pricing_Per_Unit__c vendorPricingPerUnnit : mapVendorcomponentWithPricingPerUnit.get(vPricingPerUnit.Vendor_Component_Pricing__c))
                                    vppus.add(vendorPricingPerUnnit);
                                
                                Map<Id, List<Vendor_Pricing_Per_Unit__c>> mapVPPU = new Map<Id, List<Vendor_Pricing_Per_Unit__c>>();
                                mapVPPU.put(vPricingPerUnit.Vendor_Component_Pricing__c, vppus);       
                                //Job Ticket assignment. 
                                jTktWrapper.jobTicket = jobtkt;
                                jTktWrapper.mapVendorPricingPerUnit = mapVPPU;
                                
                                //String to hold the unique key. 
                                String uniqueKey = vPricingPerUnit.Vendor_Component_Pricing__r.Job_Ticket_Component__c + '-' + jobtkt.Id;
                                
                                //Final Map fill that will hold all the relative object once. 
                                mapJobtktWrappers.put(uniqueKey,jTktWrapper);
                            }
                        }
                    }
                }
                
                //Check for the map size. 
                if(mapJobtktWrappers.size() > 0) 
                {
                    //List to hold the Job Ticket Estimates. 
                    Map<Id, Job_Ticket_Estimates__c> mapjobEstimatesToBeInserted = new Map<Id, Job_Ticket_Estimates__c>();
                    
                    //Map to hold the fulfillment tracking. 
                    Map<Id, Production_Tracking__c> mapfullfillmentsWithJobTicket = new Map<Id, Production_Tracking__c>();
                    
                    //List to hold the Job ticket Estimate components that is going to be created. 
                    List<Job_Ticket_Estimate_Component__c> jobTktEstimateComponentsToBeCreated = new List<Job_Ticket_Estimate_Component__c>();
                    
                    //08/14/2020 - CR-20200812-14419 - Victor Hanson - updated due to change from list to map
                    //Loop on the fulfillment list inserted above and convert this to the aboe map. 
                    for(Production_Tracking__c fullfillment : productionTrackingToBeCreated.values())
                        mapfullfillmentsWithJobTicket.put(fullfillment.Job_Ticket__c , fullfillment);
                    
                    /* THIS PART IS TO CREATE THE JOB TICKET ESTIMATES*/
                    for(String uKey : mapJobtktWrappers.keySet()) 
                    {
                        Job_Ticket_Estimates__c jTktEstimate = new Job_Ticket_Estimates__c();
                        
                        jTktEstimate.Production_Tracking__c = mapfullfillmentsWithJobTicket.get(mapJobtktWrappers.get(uKey).jobTicket.Id).Id;
                        for(String vendorPricing : mapJobtktWrappers.get(uKey).mapVendorPricingPerUnit.keySet())
                            jTktEstimate.Vendor_Name__c = mapVendorPricingComWithVendor.get(vendorPricing);
                        
                        //Filling the Map with the Job Component and Job Ticket Estimate. 
                        mapjobEstimatesToBeInserted.put(mapJobtktWrappers.get(uKey).jobTicketComponentId, jTktEstimate);
                    }
                    
                    if(mapjobEstimatesToBeInserted.size() > 0 )
                        //Inserting the job Ticket Estimate records. 
                        //insert mapjobEstimatesToBeInserted.values();
                        
                        /*THIS PART IS TO CREATE THE JOB TICKET ESTIMATE COMPONENT RECORDS.  */
                        for(String uKey : mapJobtktWrappers.keySet()) {
                            
                            //Loop on the pricing per unit map. 
                            for(String vendorPriceCom : mapJobtktWrappers.get(uKey).mapVendorPricingPerUnit.KeySet()) {
                                for(Vendor_Pricing_Per_Unit__c vPPU :  mapJobtktWrappers.get(uKey).mapVendorPricingPerUnit.get(vendorPriceCom)){
                                    
                                    //Intializing the Job tkt estimates.
                                    Job_Ticket_Estimate_Component__c jobTicketEstimateComponent = new Job_Ticket_Estimate_Component__c();
                                    
                                    jobTicketEstimateComponent.Job_Ticket_Estimate__c = mapjobEstimatesToBeInserted.get(mapJobtktWrappers.get(uKey).jobTicketComponentId).Id;
                                    jobTicketEstimateComponent.Job_Ticket_Component__c = mapJobtktWrappers.get(uKey).jobTicketComponentId;
                                    jobTicketEstimateComponent.Vendor_Pricing_Per_Unit__c = vPPU.Id;
                                    
                                    jobTktEstimateComponentsToBeCreated.add(jobTicketEstimateComponent);	    
                                }
                            }
                        }
                    
                    //Check for the size of List. 
                    //if(jobTktEstimateComponentsToBeCreated.size() > 0)
                    //insert jobTktEstimateComponentsToBeCreated;
                }
            }
        }
    }
    
    global void finish(Database.BatchableContext bc)
    {
        // execute any post-processing operations
        //Calling an another batch job. 
        Batch_CreateFulfilmentTrackingOnJTM b = new Batch_CreateFulfilmentTrackingOnJTM(setOfJobTicketIds);
        Database.executeBatch(b, 25);
    }    
    
    
    //Class to use for the combine properties of related objects in the above Batch. 
    public Class JobTicketRelatedObjectWrapper 
    {
        //Class variables to hold the properties. 
        public Job_Ticket__c jobTicket;
        public Id jobTicketComponentId;
        public Map<Id, List<Vendor_Pricing_Per_Unit__c>> mapVendorPricingPerUnit;
    }
}