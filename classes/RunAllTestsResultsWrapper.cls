/**
*  Purpose      :   Run All Tests Results Wrapper class
*  Created By   :   Abhinav Sharma
**/
public without sharing class RunAllTestsResultsWrapper 
{
    public String emailBodyApexTestItemsDetails {get; set;}
    public String emailBodyOverallCodeCoverageDetails {get; set;}
    public String emailBodyApexClassesCoverageDetails {get; set;}
    public String jobId {get; set;}
    
    public RunAllTestsResultsWrapper(String emailBodyApexTestItemsDetails, String jobId) 
    {
        this.emailBodyApexTestItemsDetails = emailBodyApexTestItemsDetails;
        this.emailBodyOverallCodeCoverageDetails = '';
        this.emailBodyApexClassesCoverageDetails = '';
        this.jobId = jobId;
    }
}