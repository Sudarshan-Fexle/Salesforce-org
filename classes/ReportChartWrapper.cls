/**
 *  @description    :   Wrapper class for report charts
 * 
 *  @revision log	:	09/13/2019 - Victor Hanson - Created - CR-20181208-12776
 * 						V1.1 - Modified By - Mahendra Swarnkar - 02/04/2020 - CR-20200128-13664 - Added "without sharing" access modifier
 * 
**/
public without sharing class ReportChartWrapper {
	
    public String reportDevName { get; set; }
    public String filterRecordId { get; set; }
    public Reports.ReportResults results { get; set; }
    public Map<String, Reports.GroupingValue> keyToGroup { get; set; }
    
    /**
     *  @description    :   constructor
     * 
     *  @args           :   String, Id
     * 
     *  @revision log	:	09/13/2019 - Victor Hanson - Created
     * 
    **/ 
    public ReportChartWrapper(String reportDevName, Id filterRecordId) {
        this.reportDevName = reportDevName;
        this.filterRecordId = filterRecordId;
        getReportDetails();
    }
    
    /**
     *  @description    :   gets the report details
     * 
     *  @return         :   void
     * 
     *  @revision log	:	09/13/2019 - Victor Hanson - Created
     * 
    **/ 
    public void getReportDetails() {
        // Get the report ID
        List <Report> reportList = [SELECT Id,DeveloperName FROM Report where 
                                    DeveloperName = :reportDevName];
        String reportId = reportList[0].Id;
        
        // Get the report metadata
        Reports.ReportDescribeResult describe = Reports.ReportManager.describeReport(reportId);
        Reports.ReportMetadata reportMd = describe.getReportMetadata();
        
        // Override filter and run report
        Reports.ReportFilter filter = reportMd.getReportFilters()[0];
        filter.setValue(filterRecordId);
        results = Reports.ReportManager.runReport(reportId, reportMd);
        
        populateGroups();
    }
    
    /**
     *  @description    :   populates the group values
     * 
     *  @return         :   void
     * 
     *  @revision log	:	09/13/2019 - Victor Hanson - Created
     * 
    **/ 
    private void populateGroups() {
        keyToGroup = new Map<String, Reports.GroupingValue>();
        
        for (Reports.GroupingValue gv : results.getGroupingsDown().getGroupings()) {
            keyToGroup.put(gv.getKey(), gv);
        }
    }
    
    /**
     *  @description    :   get the label to colors map
     * 
     *  @args           :   void
     * 
     *  @return         :   String
     * 
     *  @revision log	:	09/13/2019 - Victor Hanson - Created
     * 
    **/ 
    public static Map<String, String> oppStageToColorMap {
        get {
            if (oppStageToColorMap == null) {
                oppStageToColorMap = ValueToColorHelper.getValueToHTMLColorMap('Opportunity', 'StageName');
            }
            return oppStageToColorMap;
        }
        set;
    }
}