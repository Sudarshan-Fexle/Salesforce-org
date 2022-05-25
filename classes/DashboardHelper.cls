/**
 * Desription      :   	helper methods to get dashboard html and component images
 * 
 * Created By      :   	Victor Hanson
 * 
 * Created Date    :   	8/25/2015
 * 
 * Revision Logs   :   	v1.0 - Created
 **/
public without sharing class DashboardHelper {
    public Id dashboardId { get; set; }
    public string sessionId { get; set; }
    
    public blob getComponentImage(Id dCompId) {
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        string firstImageURL = URL.getSalesforceBaseUrl().toExternalForm() + '/htmldbcthumbnail?id=' + dCompId + '&runningUser=' + userInfo.getUserId() + '&dummyParam=1437441292881';
        //firstImageURL = EncodingUtil.urlEncode(firstImageURL, 'UTF-8');

        req.setEndpoint(firstImageURL);
        req.setMethod('GET');
        //If you want to get a PDF file the Content Type would be 'application/pdf'
        req.setHeader('Content-Type', 'image/jpeg');
        //system.debug('@@USess:' + userinfo.getSessionId() + '  otherSession:' + sessionId);
        req.setHeader('Cookie','sid='+sessionId ); //sessionId
        req.setCompressed(true);
        req.setTimeout(60000);
        
        HttpResponse res = null;
        res = h.send(req);
        system.debug('@@@firstImageURL:' + firstImageURL + '  RESPONSE:' + res.getStatusCode() + '-' + res.getBody());
        //These next three lines can show you the actual response for dealing with error situations
        string responseValue = '';
        responseValue = res.getBody();
        system.debug('Response Body for File: ' + responseValue);
        //This is the line that does the magic.  We can get the blob of our file.  This getBodyAsBlob method was added in the Spring 2012 release and version 24 of the API.
        blob image = res.getBodyAsBlob();
        return image;
    }
    
    public void doRefresh(Id dashboardId) {
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        string refreshURL = URL.getSalesforceBaseUrl().toExternalForm() + '/dash/dashboardRefresh.apexp?id=' + dashboardId;
        req.setEndpoint(refreshURL);
        req.setMethod('GET');
        //If you want to get a PDF file the Content Type would be 'application/pdf'
        //req.setHeader('Content-Type', 'image/jpeg');
        req.setHeader('Cookie','sid='+sessionId); //UserInfo.getSessionId()
        //req.setCompressed(true);
        req.setTimeout(60000);
        
        HttpResponse res = null;
        res = h.send(req);
        //These next three lines can show you the actual response for dealing with error situations
        string responseValue = '';
        responseValue = res.getBody();
        system.debug('@@:' + res);
    }
    
    /**
     * 
     * @description: get the dashboard image folder id
     * 
     **/
    public Id dashboardImageFolderId {
        get {
            if (dashboardImageFolderId == null) {
                dashboardImageFolderId = [SELECT Id FROM Folder WHERE DeveloperName = 'Dashboard_Images'].Id;
            }
            return dashboardImageFolderId;
        }
        set;
    }
    
    /**
     * 
     * @description: return a document from a body/type/name that is supplied.
     * 
     **/
    public Document createDocument(blob body, string type, string name) {
        Document doc = new Document();
        doc.Name = name;
        doc.Type = type;
        doc.AuthorId = UserInfo.getUserId();
        doc.FolderId = dashboardImageFolderId;
        doc.Body = body;
        return doc;
    }
    
    /**
     * 
     * @description: delete old version of the component images, copy the new component images, and insert.
     * 
     **/
    public void copyImages() {
        //create the list of dashboard component images to insert
        for (DashboardComponent dComp : dComponents) {
            docsToInsert.add(createDocument(getComponentImage(dComp.Id), 'image/jpeg', dComp.Id + '.jpg'));
        }
        //delete any existing images for this dashboard
        list<Document> dcsToDelete = [SELECT Id FROM Document WHERE Name IN :attachmentNames];
        if (dcsToDelete.size() > 0) delete dcsToDelete;
        if (docsToInsert.size() > 0) insert docsToInsert;
    }
    
    /**
     * 
     * @description: returns a list of dashboard components for the dashboard
     * 
     **/
    public list<DashboardComponent> dComponents {
        get {
            if (dComponents == null) {
                dComponents = [SELECT Id FROM DashboardComponent WHERE DashboardId = :dashboardId];
            }
            return dComponents;
        }
        set;
    }
    
    /**
     * 
     * @description: returns a list of component document names for each dashboard component
     * 
     **/
    public set<string> attachmentNames {
        get {
            if (attachmentNames == null) {
                attachmentNames = new set<string>();
                for (DashboardComponent dc : dComponents) attachmentNames.add(dc.Id + '.jpg');
            }
            return attachmentNames;
        }
        set;
    }
    
    /**
     * 
     * @description: gets the dashboard html via callout and saves the HTML to a document that 
     *   			 will be accessed when a user views that dashboard via DashboardViewer page.
     * 
     **/
    public void createDashboardHTMLDocument() {
        //set the page ref
        blob htmlBlob = getDashboardHTML();
        docsToInsert.add(createDocument(htmlBlob, 'text/html', dashboardId + '.html'));
    }
    
    /**
     * 
     * @description: list of documents to insert.  All dashboard html / images are added to this list
     * 
     **/
    public list<Document> docsToInsert {
        get {
            if (docsToInsert == null) docsToInsert = new list<Document>();
            return docsToInsert;
        }
        set;
    }
    
    /**
     * 
     * @description: callout to the dashboard url to simulate a normal page view and return all the html markup.
     * 
     **/
    public blob getDashboardHTML() {
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        string dashboardURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + dashboardId + '?isdtp=mn';
        req.setEndpoint(dashboardURL);
        req.setMethod('GET');
        //If you want to get a PDF file the Content Type would be 'application/pdf'
        req.setHeader('Content-Type', 'text/html; charset=utf-8');
        req.setHeader('Cookie','sid='+sessionId ); //sessionId
        req.setCompressed(true);
        req.setTimeout(60000);
        HttpResponse res = null;
        res = h.send(req);
        system.debug('@@@dashboardURL:' + dashboardURL + '  RESPONSE:' + res.getStatusCode() + '-' + res.getBody());
        //These next three lines can show you the actual response for dealing with error situations
        string responseValue = '';
        responseValue = res.getBody();
        system.debug('Response Body for File: ' + responseValue);
        //This is the line that does the magic.  We can get the blob of our file.  This getBodyAsBlob method was added in the Spring 2012 release and version 24 of the API.
        blob htmlPage = res.getBodyAsBlob();
        return htmlPage;
    }
    
    /**
     * 
     * @description: returns a map of all shared dashboards
     * 				 map<Shared_Dashboard__c.Name, Shared_Dashboard__c>
     * 
     **/
    public static map<string, Shared_Dashboard__c> sharedDashboardMap {
        get {
            if (sharedDashboardMap == null) {
                sharedDashboardMap = new map<string, Shared_Dashboard__c>();
                for (Shared_Dashboard__c sd : Shared_Dashboard__c.getall().values()) sharedDashboardMap.put(sd.Name, sd);
            }
            return sharedDashboardMap;
        }
        set;
    }

}