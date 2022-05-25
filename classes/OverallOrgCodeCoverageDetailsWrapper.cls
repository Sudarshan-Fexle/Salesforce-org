/**
*  Purpose      :   Overall Org Code Coverage Details Wrapper class
*  Created By   :   Abhinav Sharma
**/
public without sharing class OverallOrgCodeCoverageDetailsWrapper 
{
    public Integer size {get;set;} 
    public Integer totalSize {get;set;} 
    public List<Records> records {get;set;} 
    
    public class Records 
    {
        public String Id {get;set;} 
        public Integer PercentCovered {get;set;} 
    }
}