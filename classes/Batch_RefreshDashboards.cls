/**
 * Desription      :   	nightly job that refreshes all dashboards.  This job must execute prior to the Batch_CopyDashboards job.
 * 
 * Created By      :   	Victor Hanson
 * 
 * Created Date    :   	8/25/2015
 * 
 * Revision Logs   :   	v1.0 - Created
 **/
global class Batch_RefreshDashboards implements database.batchable<sobject>, Database.AllowsCallouts, Schedulable {
    public string QueryString { get; set; }
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
    
    global Batch_RefreshDashboards() {
        if (QueryString == null)
            QueryString = 'SELECT Id FROM Dashboard WHERE Id IN :dashboardIds ORDER BY Title ASC';
        system.debug('@@QueryString:' + QueryString);
    }
    
    global database.querylocator start(database.batchableContext bc) {
        system.debug('@@QueryString:' + QueryString);
        system.debug('@@dashboardIds:' + dashboardIds);
        return database.getquerylocator(this.queryString);
    }
    
    global void execute(database.batchablecontext bd, list<sobject> sc) {
        
        //get the session id
        SessionHelper session = new SessionHelper();
        
        list<Dashboard> dashboards = (list<Dashboard>) sc;
        
        for (Dashboard db : dashboards) {
            //instantiate dashboardhelper
            DashboardHelper helper = new DashboardHelper();
            helper.dashboardId = db.Id;
            helper.sessionId = session.sessionId;
            helper.doRefresh(db.Id);
        }
        
        //delete existing dashboard html docs
        set<string> dashboardDocNames = new set<string>();
        for (Dashboard db : dashboards) dashboardDocNames.add(db.Id + '.html');
        list<Document> docsToDelete = [SELECT Id FROM Document WHERE Name IN :dashboardDocNames];
        if (docsToDelete.size() > 0) delete docsToDelete;
    }
    
    global void finish(database.batchableContext bc) {
        //Build the system time of now + 1 hour to schedule the batch that will copy the dashboard html/images.
        Datetime sysTime = System.now();
        if (dashboardIds.size() > 10) sysTime = sysTime.addHours(1);
        else sysTime = sysTime.addMinutes(2);
        String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        
        //Scheduler class
        Batch_CopyDashboards schedCopyDashboards = new Batch_CopyDashboards();
        schedCopyDashboards.dashboardIds = dashboardIds;
        
        //Schedule the next job, and give it the system time so name is unique
        System.schedule('Sched_CopyDashboards' + sysTime.getTime(), chron_exp, schedCopyDashboards);
    }
    
    public void execute(SchedulableContext ctx) {
        // Schedule it to run every day at 3am
        //System.schedule('Batch_RefreshDashboards', '0 0 3 * * ?', new Batch_RefreshDashboards() );
        Database.executeBatch(new Batch_RefreshDashboards(), 10);
    }
}