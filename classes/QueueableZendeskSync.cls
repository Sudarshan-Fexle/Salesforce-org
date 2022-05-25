/**
*  Description     :    Syncs Zendesk Tickets and Comments to Cases and Case Comments
*
*  Revision Logs   :   V_1.0 - Created - Victor Hanson
*                      V_1.1 - 11/05/2019 - Victor Hanson - CR-20191031-13485 - fixed a bug caused by the wrapper class retaining some values
*                      V_1.2 - 03/18/2021 - Neha Sharam - CR-20210205-14877 - Modified to have additional error handling logic
*                      V_1.3 - 04/28/2021 - Modified By - Neha Sharma - upsert the membersupport - CR-20200731-14390
**/  
public class QueueableZendeskSync implements Queueable, Database.AllowsCallouts {
    
    //private List<ZendeskWrapper.zdTicket> ticketsToSync { get; set; }
    public ZendeskService zdService { get; set; }
    public String syncType { get; set; }
    
    public QueueableZendeskSync(ZendeskService zdService, String syncType) {
        this.zdService = zdService;
        this.syncType = syncType;
    }
    
    public void execute(QueueableContext context) {
        
        try {
            if (zdService == null) {
                zdService = new ZendeskService();
            }
            
            //Victor Hanson - 11/05/2019 - CR-20191031-13485
            //reset some field values
            if (zdService.zdWrapper != null) {
                zdService.zdWrapper = new ZendeskWrapper();
                zdService.caseCommentsToInsert = null;
            }
            
            //Sync Tickets
            if (syncType == ZendeskService.SYNC_TYPE_TICKETS) {         
                //search for tickets updated since the last sync
                zdService.getTickets();
                
                //upsert the cases
                if (zdService.casesToUpsert != null && zdService.casesToUpsert.size() > 0) {
                    List<Database.UpsertResult> upsertResults = zdService.upsertCases();
                }
                
                
                //get case comments
                zdService.populateCaseCommentMap();
                
                //upsert the comments
                if (zdService.caseCommentsToInsert != null && zdService.caseCommentsToInsert.size() > 0) {
                    List<Database.UpsertResult> commentUpsertResults = zdService.upsertCaseComments();
                }
                
                //Modified By - Neha Sharma - upsert the membersupport - CR-20200731-14390 
                if (zdService.memberSupportToUpsert != null && zdService.memberSupportToUpsert.size() > 0) {
                    List<Database.UpsertResult> upsertResults = zdService.upsertMemberSupport();
                }
                
            } //OR, Sync Organizations
            else if (syncType == ZendeskService.SYNC_TYPE_ORGANIZATIONS) {
                
                //sync organization and membership data
                zdService.syncOrganizations();
            }
            
        }
        catch(exception e) {
            insert new Web_Service_Log__c(RecordTypeId = Schema.SObjectType.Web_Service_Log__c.RecordTypeInfosByDeveloperName.get('Default').RecordTypeId,
                                          //External_Id__c = sObj.get('Zendesk_Ticket_Id__c') != null ? (String) sObj.get('Zendesk_Ticket_Id__c') : null,
                                          Web_Service_Method__c = 'QueueableZendeskSync.execute(zdService, \'' + syncType + '\')',
                                          Request_Sent__c = system.now(),
                                          Request_Message_Log__c = e.getMessage().abbreviate(32000),
                                          Response_Message_Log__c = e.getLineNumber() + '\r\n' + e.getStackTraceString(),
                                          Response_Message__c = 'Error');
        }
        
        
        //Modify By - Neha Sharam - 03/18/2021 - CR-20210205-14877 - Modified to have additional error handling logic
        //Start from here
        //if there are additional tickets to sync, re-queue the job with only the un-synced tickets
        if (zdService.next_page != null ) 
        {
            System.enqueueJob(new QueueableZendeskSync(zdService, syncType));
        } 
        //once the organization sync finishes, begin the tickets sync
        else if (zdService.next_page == null && syncType == ZendeskService.SYNC_TYPE_ORGANIZATIONS) 
        {
            System.enqueueJob(new QueueableZendeskSync(null, ZendeskService.SYNC_TYPE_TICKETS));
        }
        //End here
    }
}