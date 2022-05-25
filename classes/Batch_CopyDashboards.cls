/**
 * Desription      :   	batch job runs nightly to copy the HTML and images of all components on the dashboard which are saved as Documents.
 * 						these documents are used on the DashboardViewer page.
 * 
 * Created By      :   	Victor Hanson
 * 
 * Created Date    :   	8/25/2015
 * 
 * Revision Logs   :   	v1.0 - Created
 **/
global class Batch_CopyDashboards implements database.batchable<sobject>, Database.AllowsCallouts, Schedulable {
    public string QueryString;
    public set<string> dashboardIds {
        get {
            if (dashboardIds == null) {
                dashboardIds = new set<string>();
                for (Shared_Dashboard__c sd : DashboardHelper.sharedDashboardMap.values()) {
                    if (sd.Is_Shared__c) dashboardIds.add(sd.Name);
                }
            }
            return dashboardIds;
        }
        set;
    }
    global Batch_CopyDashboards() {
        if (QueryString == null)
        	QueryString = 'SELECT Id FROM Dashboard WHERE Id IN :dashboardIds ORDER BY Title ASC';
    }
    
    global database.querylocator start(database.batchableContext bc) {
        return database.getquerylocator(QueryString);
    }
    
    global void execute(database.batchablecontext bd, list<sobject> sc) {
        list<Dashboard> dashboards = (list<Dashboard>) sc;
        
        for (Dashboard db : dashboards) {
            
            //get the session id
            SessionHelper session = new SessionHelper();
            
            //instantiate dashboardhelper
            DashboardHelper helper = new DashboardHelper();
            helper.dashboardId = db.Id;
            helper.sessionId = session.sessionId;
            
            
            //create the dashboard html document
            helper.createDashboardHTMLDocument();
            
            //copies and inserts images + html doc
            helper.copyImages();
        }
    }
    
    global void finish(database.batchableContext bc) {
        
    }
    
    public void execute(SchedulableContext ctx) {
        // execute the job
        Database.executeBatch(new Batch_CopyDashboards(), 1);
    }
}