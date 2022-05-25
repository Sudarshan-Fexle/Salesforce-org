//V_1.2 Modify By - Rajeev Jain - 06/02/2018 - CR-20160616-9947
public class DashboardQuickActionController {
	
    public string dashboardId {
        get {
            if (dashboard != null && dashboard.Id != null) dashboardId = dashboard.Id;
            return dashboardId;
        }
        set;
    }
    
    public boolean shareDashboard { get; set; }
    private string DASHBOARD_ID_PREFIX = '01Z';
    
    public DashboardQuickActionController() {
        //get the dashboard info from the url param
        dashboardId = ApexPages.currentPage().getParameters().get('id');
        shareDashboard = isShared;
    }
    //Modify By - Rajeev Jain - 06/02/2018 - CR-20160616-9947
    public void toggleShareDashboard() {
        Shared_Dashboard__c sd;
        if (!isShared) {
            if (dashboard != null)
            	sd = DashboardHelper.sharedDashboardMap.get(dashboardId);
            if (sd == null) {
                //create new shared dashboard record
                sd = new Shared_Dashboard__c(Name = dashboardId);
            }
            sd.Is_Shared__c = true;
            sd.Dashboard_Name__c = dashboard.Title;
            //copy the dashboard html and components
            Batch_CopyDashboards batch = new Batch_CopyDashboards();
            batch.dashboardIds = new set<string> { dashboardId };
            //Modify By - Rajeev Jain - 06/02/2018 - CR-20160616-9947
            System.scheduleBatch(batch,'Batch_CopyDashboards',0,1);
            shareDashboard = true;
        }
        else {
            //delete the shared dashboard record
            sd = DashboardHelper.sharedDashboardMap.get(dashboardId);
            sd.Is_Shared__c = false;
            sd.Dashboard_Name__c = dashboard.Title;
            //delete the dashboard's html document
            string dashboardDocumentName = dashboardId + '.html';
            list<Document> docsToDelete = [SELECT Id FROM Document WHERE Name = :dashboardDocumentName];
            if (docsToDelete.size() > 0) delete docsToDelete;
            shareDashboard = false;
        }
        
        upsert sd;
        
        //refresh the sharedDashboard map
        DashboardHelper.sharedDashboardMap = null;
    }
    
    public boolean isShared { 
        get {
            isShared = false;
            if (dashboard != null 
                && DashboardHelper.sharedDashboardMap.keySet().contains(dashboardId)
                && DashboardHelper.sharedDashboardMap.get(dashboardId).Is_Shared__c) 
            {
                isShared = true;
            }
            return isShared;
        }
        set;
    }
    
    public Dashboard dashboard {
        get {
            if (dashboard == null) {
                dashboard = new Dashboard();
                if (dashboardId != null && dashboardId instanceOf Id) {
                    list<Dashboard> dashboards = [SELECT Id, Title FROM Dashboard WHERE Id = :dashboardId];
                    if (dashboards.size() > 0) dashboard = dashboards[0];
                }
            }
            return dashboard;
        }
        set;
    }
    
    public string dashboardViewerURL {
        get {
            if (dashboardViewerURL == null) {
                dashboardViewerURL = URL.getSalesforceBaseUrl().toExternalForm() + '/apex/DashboardViewer?id=' + dashboardId + '&ud=' + UserInfo.getUserId();
            }
            return dashboardViewerURL;
        }
        set;
    }
}