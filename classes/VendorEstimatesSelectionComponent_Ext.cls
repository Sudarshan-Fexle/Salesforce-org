/*
    Purpose         :   Controller class to display all of the Job Ticket Estimates associated with the Production Tracking.
						So that user can see the key information without having to click through each of the Job Ticket 
						Estimates individually and can do all the updates at a single view.
                
    Created By      :   Abhinav Sharma
    
    Created Date    :   11/25/2019
    
    Current Version :   v1.0
    
    Revision Log    :   V_1.0 Created - Abhinav Sharma - 11/25/2019
                        
*/
public class VendorEstimatesSelectionComponent_Ext 
{
    public Production_Tracking__c fulfillmentTracking {get; set;}
	public List<JobTicketEstimatesWrapper> jobTicketEstimatesWrapperList {get; set;}
    public JobTicketEstimateVendorDetailsWrapper jobTicketEstimateVendorDetails {get; set;}
    public List<JobTicketEstimatesChartWrapper> jobTicketEstimatesChartDetails {get; set;}
    public String selectedEstimateIdValue {get; set;}
    public Integer selectedSrNo {get; set;}
    public Boolean doJobTicketEstimatesExists {get; set;}
    private ApexPages.StandardController stdController;
    
    public VendorEstimatesSelectionComponent_Ext(ApexPages.StandardController standardController)
    {
        stdController = standardController;
        fulfillmentTracking = (Production_Tracking__c)standardController.getRecord();
    	inIt();
    }
    
    public List<Schema.FieldSetMember> getFields() 
    {
        return Schema.SObjectType.Job_Ticket_Estimates__c.fieldSets.getMap().get(System.Label.VendorSelectionScreen_FieldSetName).getFields();
    }
    
    public void inIt() 
    {
        selectedEstimateIdValue = '';
        jobTicketEstimatesWrapperList = new List<JobTicketEstimatesWrapper>();
        jobTicketEstimateVendorDetails = new JobTicketEstimateVendorDetailsWrapper();
        jobTicketEstimatesChartDetails = new List<JobTicketEstimatesChartWrapper>();
        doJobTicketEstimatesExists = false;
        
        if(fulfillmentTracking != null && fulfillmentTracking.Id != null) 
        {
            String fulfillmentTracking = fulfillmentTracking.Id;
			String whereClause = 'WHERE Production_Tracking__c =:fulfillmentTracking';
            String orderBy = 'ORDER BY Name ASC ';
            String jobTicketEstimatesQuery = DatabaseUtilities.getFieldsetQuery('Job_Ticket_Estimates__c', getFields(), 
                                                                                new List<String>{'Name', 'Total_Price__c', 'Partial_Estimate__c', 'Selected_Estimate__c'}, 
                                                                                whereClause, orderBy, null, true);
            Integer cnt = 0;
            for (sObject queriedObject : Database.query(jobTicketEstimatesQuery)) 
            {
                JobTicketEstimatesWrapper jTEW = new JobTicketEstimatesWrapper();
                jTEW.jobTicketEstimate = (Job_Ticket_Estimates__c)queriedObject;
                jtEW.srNo = cnt;
                
                JobTicketEstimatesChartWrapper jTECD = new JobTicketEstimatesChartWrapper();
                if(jTEW.jobTicketEstimate != null) 
                {
                    if(jTEW.jobTicketEstimate.Selected_Estimate__c) 
                    {
                        selectedEstimateIdValue = jTEW.jobTicketEstimate.Id;
                        selectedSrNo = jtEW.srNo;
                    }
                    jtEW.selectedEstimate = jTEW.jobTicketEstimate.Selected_Estimate__c;
                    jTECD.jobTicketEstimateName = jTEW.jobTicketEstimate.Name;
                    if(jTEW.jobTicketEstimate.Total_Price__c != null) 
                    {
                        jTECD.totalPrice = Integer.valueOf(jTEW.jobTicketEstimate.Total_Price__c);
                    }
                }
                doJobTicketEstimatesExists = true;
                jobTicketEstimatesWrapperList.add(jTEW);
                jobTicketEstimatesChartDetails.add(jTECD);
                cnt++;
            }
            retrieveVendorInformations();
        }
        else 
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, System.Label.Error_Unable_To_Access_Fulfillment_Tracking ));
        }
    }
    
    public void retrieveVendorInformations() 
    {
        if(String.isNotBlank(selectedEstimateIdValue) && selectedSrNo != null) 
        {
            jobTicketEstimateVendorDetails = new JobTicketEstimateVendorDetailsWrapper();
            jobTicketEstimateVendorDetails.doJobTicketEstimateComponentsExists = false;
            Set<String> setOfComponentTypes = new Set<String>();
            for(Job_Ticket_Estimate_Component__c jTEC : [Select Id, Job_Ticket_Estimate__c,
                                                         Job_Ticket_Component__c,
                                                         Job_Ticket_Component__r.Component__c,
                                                         Job_Ticket_Estimate__r.Vendor_Name__r.Name,
                                                         Job_Ticket_Estimate__r.Vendor_Name__r.Primary_City__c,
                                                         Job_Ticket_Estimate__r.Vendor_Name__r.Primary_State_Province__c
                                                         FROM Job_Ticket_Estimate_Component__c 
                                                         WHERE Job_Ticket_Estimate__c != null 
                                                         AND Job_Ticket_Estimate__c =: selectedEstimateIdValue
                                                         AND Job_Ticket_Estimate__r.Vendor_Name__c != null
                                                        ]
            )
            {
                jobTicketEstimateVendorDetails.doJobTicketEstimateComponentsExists = true;
                jobTicketEstimateVendorDetails.vendorName = jTEC.Job_Ticket_Estimate__r.Vendor_Name__r.Name;
                String priamryCity = jTEC.Job_Ticket_Estimate__r.Vendor_Name__r.Primary_City__c != null 
                    					? jTEC.Job_Ticket_Estimate__r.Vendor_Name__r.Primary_City__c : '';
                String primaryState = jTEC.Job_Ticket_Estimate__r.Vendor_Name__r.Primary_State_Province__c != null
                    					? jTEC.Job_Ticket_Estimate__r.Vendor_Name__r.Primary_State_Province__c : '';
                
                if(String.isNotBlank(priamryCity))
                {
                    jobTicketEstimateVendorDetails.vendorLocation += priamryCity;
                    
                    if(String.isNotBlank(primaryState))
                    {
                        jobTicketEstimateVendorDetails.vendorLocation += ',' + primaryState;
                    } 
                } 
                else 
                {
                	jobTicketEstimateVendorDetails.vendorLocation = primaryState;    
                } 
                
                if(jTEC.Job_Ticket_Component__c != null && String.isNotBlank(jTEC.Job_Ticket_Component__r.Component__c)
                   && !setOfComponentTypes.contains(jTEC.Job_Ticket_Component__r.Component__c)) 
                {
            		jobTicketEstimateVendorDetails.componentsEstimated += jTEC.Job_Ticket_Component__r.Component__c + ',';
                    setOfComponentTypes.add(jTEC.Job_Ticket_Component__r.Component__c);
                }
            }
            jobTicketEstimateVendorDetails.componentsEstimated = jobTicketEstimateVendorDetails.componentsEstimated.removeEnd(',');
            
            integer cnt = 0;
            for(JobTicketEstimatesWrapper jTET : jobTicketEstimatesWrapperList) 
            {
                if(selectedSrNo == cnt) 
                {
                    jobTicketEstimatesWrapperList[cnt].jobTicketEstimate.Selected_Estimate__c = true;
                    jobTicketEstimatesWrapperList[cnt].selectedEstimate = true;
                }
                else 
                {
                    jobTicketEstimatesWrapperList[cnt].jobTicketEstimate.Selected_Estimate__c = false;
                    jobTicketEstimatesWrapperList[cnt].selectedEstimate = false;
                }
                cnt++;
            }
        }
    }
    
    public Pagereference doSaveChanges() 
    {
        List<Job_Ticket_Estimates__c> listOfJobTicketEstimates = new List<Job_Ticket_Estimates__c>();
        for(JobTicketEstimatesWrapper jTEW : jobTicketEstimatesWrapperList) 
        {
            if(jTEW.jobTicketEstimate != null) 
            {
                listOfJobTicketEstimates.add(jTEW.jobTicketEstimate);
            }
        }
        if(listOfJobTicketEstimates.size() > 0) 
        {
            try 
            {
            	Util.BypassAllTriggers = true;
                update listOfJobTicketEstimates;
                Util.BypassAllTriggers = false;
                return stdController.view();
            } 
            catch(Exception ex) 
            {
            	ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, ex.getMessage()));
                return null;
            }
        } 
        else 
        {
            return stdController.view();
        }
    }
    
    public class JobTicketEstimatesWrapper 
    {
        public Job_Ticket_Estimates__c jobTicketEstimate {get; set;}
        public Boolean selectedEstimate {get; set;}
        public Integer srNo {get; set;}
        public JobTicketEstimatesWrapper() 
        {
        	jobTicketEstimate = new Job_Ticket_Estimates__c();
            selectedEstimate = false;
            srNo = 0;
        }
    }
        
    public class JobTicketEstimateVendorDetailsWrapper 
    {
        public String vendorName {get; set;}
        public String vendorLocation {get; set;}
        public String componentsEstimated {get; set;}
        public Boolean doJobTicketEstimateComponentsExists {get; set;}
        public JobTicketEstimateVendorDetailsWrapper() 
        {
            vendorName = '';
            vendorLocation = '';
            componentsEstimated = '';
            doJobTicketEstimateComponentsExists = false;
        }
    }
    
    public class JobTicketEstimatesChartWrapper 
    {
        public String jobTicketEstimateName {get; set;}
        public Integer totalPrice {get; set;} 
        public JobTicketEstimatesChartWrapper() 
        {
        	this.jobTicketEstimateName = '';
        }
    }
}