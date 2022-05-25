public class CRActionItem_Issue_ChartController {
    
    public string ChartType;
    public string issueType;
    public string chartTitle;
    public boolean showNewButton {get;set;}
    public string newButtonText {get;set;}
    public string linkNewButton {get;set;}
    public string linkReportDetail {get;set;}
    
    // Wrapper class
    public class PieWedgeData {

        public String name { get; set; }
        public Integer data { get; set; }

        public PieWedgeData(String name, Integer data) {
            this.name = name;
            this.data = data;
        }
    }
    
    public List<PieWedgeData> getPieData() {
        List<PieWedgeData> data = new List<PieWedgeData>();
        data.add(new PieWedgeData('New', 30));
        data.add(new PieWedgeData('In Progress', 15));
        //data.add(new PieWedgeData('QA Validation', 10));
        //data.add(new PieWedgeData('Resolved', 20));
        data.add(new PieWedgeData('Blocked', 20));
        //data.add(new PieWedgeData('Jun', 5));
        return data;
    }

    //public CRActionItem_Issue_ChartController(ApexPages.StandardController sc){
    //    
    //}
 
    
    public string getChartType() {
        return ChartType;
    }
    
    public void setChartType(string s){
        ChartType = s;
        //map<String,CRAI_Chart_Type__mdt> ChartType;
        CRAI_Chart_Type__mdt ChartSettings = null;
        
        //for(CRAI_Chart_Type__mdt ct : [SELECT MasterLabel, DeveloperName, Chart_Type__c, Chart_Title__c, Report_Detail_Link__c, Show_New_Button__c, 
        //                               New_Button_Link__c, New_Button_Text__c 
        //                               FROM CRAI_Chart_Type__mdt 
        //                               WHERE RecordType__c = 'Issue' AND Chart_Type__c = :TypeOfIssue LIMIT 1]){
        //                                   ChartType.put(ct.Chart_Type__c,ct);
        //                               }
        //system.debug('CRActionItem_Issue_ChartController - setTypeOfIssue: ChartType'+ChartType);
        
        ChartSettings = ([SELECT MasterLabel, DeveloperName, Chart_Type__c, Chart_Title__c, Report_Detail_Link__c, Show_New_Button__c, 
                          New_Button_Link__c, New_Button_Text__c 
                          FROM CRAI_Chart_Type__mdt 
                          WHERE RecordType__c = 'Issue' AND Chart_Type__c = :ChartType LIMIT 1]);
        system.debug('CRActionItem_Issue_ChartController - setTypeOfIssue: ChartSettings'+ChartSettings);
        
        newButtonText = '';
        issueType = '';
        chartTitle = '';
        linkNewButton = '';
        linkReportDetail = '';
        
        if(ChartSettings != null){
            chartTitle = ChartSettings.Chart_Title__c;
            issueType = ChartType;
            showNewButton = ChartSettings.Show_New_Button__c;
            newButtonText = ChartSettings.New_Button_Text__c;
            linkNewButton = ChartSettings.New_Button_Link__c;
            linkReportDetail = ChartSettings.Report_Detail_Link__c;
        }
        
        /*
        if(s == 'QA'){
            chartTitle = 'QA Issues';
            issueType = 'QA';
            newButtonText = 'New QA Issue';
            listButtonText = 'QA Issues List';
            showNewButton = true;
        }else if(s == 'UAT'){
            chartTitle = 'UAT Issues';
            issueType = 'UAT';
            newButtonText = 'New UAT Issue';
            listButtonText = 'UAT Issues List';
            showNewButton = true;
        }else if(s == 'Other'){
            chartTitle = 'Other Issues';
            issueType = 'Other';
            showNewButton = false;
            listButtonText = 'Other Issues List';
        }else{
        	chartTitle = 'All Issues';
            issueType = 'All';
            showNewButton = false;
            listButtonText = 'All Open Issues';
        }
		*/
    }
    
    public string getChartTitle() {
        return ChartTitle;
    }
    
    public void setChartTitle(string s){
        chartTitle = s;
    }
    
}