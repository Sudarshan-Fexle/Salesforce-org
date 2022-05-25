/**
*  Purpose      :   Apex Classes/Triggers wise code coverage details wrapper class
*  Created By   :   Abhinav Sharma
**/
public without sharing class ApexClassesCoverageDetailsWrapper 
{
    public Integer size {get;set;} 
    public Integer totalSize {get;set;} 
    public List<Records> records {get;set;} 
    
    public class Records 
    {
        public String ApexClassOrTriggerId {get;set;} 
        public Integer NumLinesCovered {get;set;} 
        public Integer NumLinesUncovered {get;set;}
        public Decimal totalPercentageCoverage {get; set;}
    }
}