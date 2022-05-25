/**
*  Purpose         :  This Controller is used for the RecalculateFulFillmentTracking
*                     
*  Created By      :   Dipesh Gupta
*
*  Created Date    :   10/18/2019
*
*  Revision Logs   :   V_1.0 - Created  - CR-20191011-13405
*                     
**/
public class RecalculateJobTicketEstimatesController
{
    public Static String navigateURL {get;set;}
    
    public  Static void processRequest()
    {
        String recordId = ApexPages.currentPage().getParameters().get('Id');
        checkForJobTicketEstimates(recordId);
        navigateURL = '/'+recordId;  
    }
    
    public static void checkForJobTicketEstimates(Id fulfillmentId)
    {
        //Set to hold the vendor pricing per unit. 
        Set<String> setVendorPricingPerUnitWithComponent = new Set<String>();
        
        //Set to hold the job ticket component ids. 
        Set<Id> setJobComponentIds = new Set<Id>();
        
        //List to hold the Jon tkt Estimate Components. 
        List<Job_Ticket_Estimate_Component__c> jobTktComponentEstimatesToBeDeleted = new List<Job_Ticket_Estimate_Component__c>();
        
        //List of Job Ticket estiamtes that needs to be delete (Which doesn't have any Child)
        List<Job_Ticket_Estimates__c> jobTicketEstiamtesToBeDeleted = new List<Job_Ticket_Estimates__c>();
        
        Id jobticketId;
        Decimal tokenQuantity;
        
        //Query on the Job estimates records. 
        for(Job_Ticket_Estimates__c JobEstimate : [Select Id, (Select Id, Job_Ticket_Component__c, Vendor_Pricing_Per_Unit__c From Job_Ticket_Estimate_Components__r) From Job_Ticket_Estimates__c])
        {
            //Check the related Job Estimates component records. 
            if(JobEstimate.Job_Ticket_Estimate_Components__r != null && JobEstimate.Job_Ticket_Estimate_Components__r.size() > 0)
            {
                //Loop on the related job tkt estimate component records. 
                for(Job_Ticket_Estimate_Component__c jobTktEstimateComp : JobEstimate.Job_Ticket_Estimate_Components__r)
                {
                    setVendorPricingPerUnitWithComponent.add(jobTktEstimateComp.Job_Ticket_Component__c + '-' + jobTktEstimateComp.Vendor_Pricing_Per_Unit__c);
                }
            }
            else
            {
                jobTicketEstiamtesToBeDeleted.add(JobEstimate);
            }
        }
        
        //Check for the size of list. 
        if(jobTicketEstiamtesToBeDeleted.size() > 0)
            delete jobTicketEstiamtesToBeDeleted;
        
        //Query on the fulfillment records. 
        for(Production_Tracking__c fulfillment : [Select Id, Job_Ticket__c From Production_Tracking__c Where Id =: fulfillmentId ])
            jobticketId = fulfillment.Job_Ticket__c;
        
        //Query on the Job MTM record to get the component Ids. 
        for(Job_Ticket_MtM__c jobTktMtm : [Select Id, Job_Ticket__c, Job_Ticket_Component__c, Job_Ticket__r.Mail_Quantity__c
                                           From Job_Ticket_MtM__c Where Job_Ticket__c =: jobticketId  AND Job_Ticket_Component__c != null])
        {
            setJobComponentIds.add(jobTktMtm.Job_Ticket_Component__c);
            tokenQuantity = jobTktMtm.Job_Ticket__r.Mail_Quantity__c;
        }
        
        if(setJobComponentIds.size() > 0)
        {
            //List to hold the IVendor_Pricing_Per_Unit__c which will create the Job tkt estiamte records. 
            List<Vendor_Pricing_Per_Unit__c> vPPUForJobTktEstimateComCreation = new List<Vendor_Pricing_Per_Unit__c>();
            
            //Set to hold the vendor pricing Component. 
            Set<Id> setVendorPricingCompIds = new Set<Id>();
            
            //Query on the vendor pricing per unit. 
            for(Vendor_Pricing_Per_Unit__c vPricingPerUnit : [Select Id, Quantity_Maximum__c, Quantity_Minimum__c,
                                                              Vendor_Component_Pricing__r.Job_Ticket_Component__c, Vendor_Component_Pricing__r.Vendor__c,
                                                              Vendor_Component_Pricing__c,  Active__c From Vendor_Pricing_Per_Unit__c 
                                                              Where Vendor_Component_Pricing__r.Job_Ticket_Component__c IN: setJobComponentIds
                                                              AND Active__c = true])
            {
                //Check for the Vendor pricing records which matches the criteria. 
                if(vPricingPerUnit.Quantity_Maximum__c >= tokenQuantity
                   && vPricingPerUnit.Quantity_Minimum__c <= tokenQuantity)
                {
                    String uniqueKey = vPricingPerUnit.Vendor_Component_Pricing__r.Job_Ticket_Component__c + '-' + vPricingPerUnit.Id;
                    
                    //Check if this record is previously created. 
                    if(setVendorPricingPerUnitWithComponent.contains(uniqueKey))
                    {
                        setVendorPricingPerUnitWithComponent.remove(uniqueKey);
                        //Remove the value from the set so we can determine, in the last the values remain in this set is no longer needed and we can delete out the respective Job Estimate conponent records. 
                        //No Action needed since this Record is previously created. 
                    }
                    else
                    {
                        //Filling the set with the vendor pricing per unit Ids that Id will create the records.    
                        vPPUForJobTktEstimateComCreation.add(vPricingPerUnit); 
                        setVendorPricingCompIds.add(vPricingPerUnit.Vendor_Component_Pricing__c);
                    }                
                }
            }            
            
            /*DELETION CASE */
            
            //Now we have 2 Sets one is to delete the Job Ticket Estimate component and one is for creating new ones. 
            for(Job_Ticket_Estimate_Component__c jte : [Select Id, Job_Ticket_Component__c, Vendor_Pricing_Per_Unit__c 
                                                        From Job_Ticket_Estimate_Component__c Where Job_Ticket_Estimate__r.Production_Tracking__c =: fulfillmentId])
            {
                //Check for the set. if value exists in set, Add to the delete list. 
                if(setVendorPricingPerUnitWithComponent.contains(jte.Job_Ticket_Component__c + '-' + jte.Vendor_Pricing_Per_Unit__c))
                    jobTktComponentEstimatesToBeDeleted.add(jte);
            }
            
            //Check the size of list. 
            if(jobTktComponentEstimatesToBeDeleted.size() > 0) 
                delete jobTktComponentEstimatesToBeDeleted;
            
            //Map to hold the Vendor_Pricing_Per_Unit__c with the Id of Job ticket estimate if any. 
            Map<String, Id> mapVendorPricingPerUnitWithJobTicketestimates = new map<String, Id>();
            
            //List to hold the Job tkt estimate record that needs to be created. 
            List<Job_Ticket_Estimate_Component__c> jobTktEstimateComponents = new List<Job_Ticket_Estimate_Component__c>();
            
            //List to hold the Job ticket estimate records. 
            Map<String, Job_Ticket_Estimates__c> mapjobTktEstimatesToBeCreated = new  Map<String, Job_Ticket_Estimates__c>();
            
            //List to hold the vppu record that need new Job tkt estimate records
            List<Vendor_Pricing_Per_Unit__c> vppusThatNeedsNewJobTicketComponents = new List<Vendor_Pricing_Per_Unit__c>();
            
            //Query on the Job Tkt estimates to check if there is any records already created for the same vendor pricing component. (This object is parent on Job tkt estimate component.)
            for(Job_Ticket_Estimate_Component__c jtec : [Select Id, Job_Ticket_Component__c, Job_Ticket_Estimate__c, Vendor_Pricing_Per_Unit__c 
                                                         From Job_Ticket_Estimate_Component__c Where  Vendor_Pricing_Per_Unit__c IN: vPPUForJobTktEstimateComCreation 
                                                         AND Job_Ticket_Estimate__r.Production_Tracking__c =: fulfillmentId ])
                mapVendorPricingPerUnitWithJobTicketestimates.put(jtec.Vendor_Pricing_Per_Unit__c + '-' + jtec.Job_Ticket_Component__c, jtec.Job_Ticket_Estimate__c );
            
            //NEW RECORD CREATION.
            for(Vendor_Pricing_Per_Unit__c vppU : vPPUForJobTktEstimateComCreation)
            {
                //Check if the map contains the values. That means we have the JOB tkt Estimate record created earlier. So we will utilze the same. 
                if(mapVendorPricingPerUnitWithJobTicketestimates!= null 
                   && mapVendorPricingPerUnitWithJobTicketestimates.containsKey(vppU.Id + '-' + vppU.Vendor_Component_Pricing__r.Job_Ticket_Component__c)
                   && String.isNotBlank(mapVendorPricingPerUnitWithJobTicketestimates.get(vppU.Id + '-' + vppU.Vendor_Component_Pricing__r.Job_Ticket_Component__c))
                  ) {
                      
                      
                      //Intializing the Job tkt estimates.
                      Job_Ticket_Estimate_Component__c jobTicketEstimateComponent = new Job_Ticket_Estimate_Component__c();
                      
                      //Job tkt estimate record values fill with the appropriate para meters. s
                      jobTicketEstimateComponent.Job_Ticket_Estimate__c = mapVendorPricingPerUnitWithJobTicketestimates.get(vppU.Id + '-' + vppU.Vendor_Component_Pricing__r.Job_Ticket_Component__c);
                      jobTicketEstimateComponent.Job_Ticket_Component__c = vppU.Vendor_Component_Pricing__r.Job_Ticket_Component__c;
                      jobTicketEstimateComponent.Vendor_Pricing_Per_Unit__c = vPPU.Id;
                      
                      jobTktEstimateComponents.add(jobTicketEstimateComponent);
                  }
                else
                {
                    //If we are in this condition that clearly means we need to create the Job ticket Estimate and it component records. 
                    mapjobTktEstimatesToBeCreated.put (vppU.Id + '-' + vppU.Vendor_Component_Pricing__r.Job_Ticket_Component__c, new Job_Ticket_Estimates__c(Production_Tracking__c = fulfillmentId, Vendor_Name__c = vppU.Vendor_Component_Pricing__r.Vendor__c));
                    vppusThatNeedsNewJobTicketComponents.add(vppU);
                }
            }
            
            //Check if the map size is > 0
            if(mapjobTktEstimatesToBeCreated.size() > 0)
                insert mapjobTktEstimatesToBeCreated.values();
            
            //Loop on the VPPUS.
            if(vppusThatNeedsNewJobTicketComponents.size() > 0) 
            {                
                //Loop on the vendor pricing per unit. 
                for(Vendor_Pricing_Per_Unit__c vppuRemaning :  vppusThatNeedsNewJobTicketComponents){
                    
                    //Intializing the Job tkt estimates.
                    Job_Ticket_Estimate_Component__c jobTicketEstimateComponent = new Job_Ticket_Estimate_Component__c();
                    
                    //Job tkt estimate record values fill with the appropriate para meters. s
                    jobTicketEstimateComponent.Job_Ticket_Estimate__c = mapjobTktEstimatesToBeCreated.get(vppuRemaning.Id + '-' + vppuRemaning.Vendor_Component_Pricing__r.Job_Ticket_Component__c).Id;
                    jobTicketEstimateComponent.Job_Ticket_Component__c = vppuRemaning.Vendor_Component_Pricing__r.Job_Ticket_Component__c;
                    jobTicketEstimateComponent.Vendor_Pricing_Per_Unit__c = vppuRemaning.Id;
             
                    jobTktEstimateComponents.add(jobTicketEstimateComponent);
                }
            }
            
            //Check for the list size. 
            if(jobTktEstimateComponents.size() > 0)
                insert jobTktEstimateComponents;
        }
    }
}