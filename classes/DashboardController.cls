/**
 * Desription      :   	Allow SF Users without access to certain objects to view any dashboard, even if the dashboard is built using objects to which they do not have access.
 * 
 * Created By      :   	Victor Hanson
 * 
 * Created Date    :   	8/25/2015
 * 
 * Revision Logs   :   	v1.0 - Created
 **/
public with sharing class DashboardController {
	
    public Id dashboardId { get; set; }
    public User sharedBy { get; set; }
    public Dashboard dash { get; set; }
    public boolean isShared {
        get {
            return (DashboardHelper.sharedDashboardMap.keySet().contains(dashboardId)
                && DashboardHelper.sharedDashboardMap.get(dashboardId).Is_Shared__c);
        }
        set;
    }
    
    /**
     * 
     * @description: constructor that gets the dashboard, user who shared it, and checks for errors
     * 
     **/
    public DashboardController() {
        
        //get the dashboard info from the url param
        dashboardId = ApexPages.currentPage().getParameters().get('id');
        if (dashboardId != null) {
            list<Dashboard> dashboards = [SELECT Id, CreatedBy.Name, Title FROM Dashboard WHERE Id = :dashboardId];
            if (dashboards.size() > 0) dash = dashboards[0];
        }
        
        if (!isShared) {
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, Label.ERROR_DASHBOARD_NOT_SHARED ) );
        }
        
        //get the user who shared the dashboard
        list<User> users = new list<User>();
        string sharedById = ApexPages.currentPage().getParameters().get('ud');
        if (sharedById != null) {
            users = [SELECT Id, Name FROM User WHERE Id = :sharedById];
        }
        if (users.size() > 0) sharedBy = users[0];
        else sharedBy = new User();
    }
    
    public list<Document> dashboardComponents {
        get {
            dashboardComponents = new list<Document>();
            if (dashboardId != null) {
                set<string> docNames = new set<string>();
                for (DashboardComponent component : [SELECT Id FROM DashboardComponent WHERE DashboardId = :dashboardId]) {
                    docNames.add(component.Id + '.jpg');
                }
                
                dashboardComponents = [SELECT Id, Name FROM Document WHERE Name IN :docNames];
            }
            return dashboardComponents;
        }
        set;
    }
    
    public map<string, document> componentIdToDocMap {
        get {
            if (componentIdToDocMap == null) {
                componentIdToDocMap = new map<string, document>();
                for (Document d : dashboardComponents) {
                    componentIdToDocMap.put(d.Name, d);
                }
            }
            return componentIdToDocMap;
        }
        set;
    }
    
    private string getDashboardDocName() {
        return dashboardId + '.html';
    }
    
    public string getDashHTML() {
        //string that will be returned
        string htmlString;
        
        list<Document> docs = [SELECT body FROM Document WHERE Name = :getDashboardDocName()];
        if (docs.size() > 0) {
            document d = docs[0];
            htmlString = d.body.toString();
            htmlString = htmlString.replaceAll('<script(.*?)>(.*?)</script>', '');
            htmlString += getDashboardHtmlAdditions(); //add css and javascript to make the page look correct for less privileged users
            system.debug('@@helper.getDashboardHTMLString():' + htmlString);
        }
        
        return htmlString;
    }
    
    @TestVisible private string getDashboardHtmlAdditions() {
        string cssAddition = '<style>.btn{ display:none !important; }  .buttonBarContainer{ display:none !important; }</style>';
        string jsAddition = '<script>\r\n';
        for (string componentId : componentIdToDocMap.keySet()) {
            string cId = componentId.split('.jpg')[0].left(15);
            jsAddition += 'try { document.getElementById(\'' + cId + 'Img\').src = \'/servlet/servlet.FileDownload?file=' + componentIdToDocMap.get(componentId).Id + '\'; } \r\n'
                + 'catch(err) { console.log(\'No id found on the page for ' + cId + '\') }\r\n\r\n';
        }
        jsAddition += '</script>';
        return cssAddition + '\r\n\r\n' + jsAddition;
    }
}