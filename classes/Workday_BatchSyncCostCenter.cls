global class Workday_BatchSyncCostCenter implements database.batchable<sobject>, Database.AllowsCallouts, Schedulable {
	@TestVisible private string QueryString;
    @TestVisible private WorkdayCostCenterSync__c settings;    
    @TestVisible private WorkdayHumanResources.Human_Resources stub;
    @TestVisible private string ErrorReportEmail;
    
	global Workday_BatchSyncCostCenter() {
        system.debug('##Workday_BatchSyncCostCenter.cstor');
        
        this.settings = WorkdayCostCenterSync__c.getInstance(UserInfo.getUserId());
        this.stub = new WorkdayHumanResources.Human_Resources();
        
        this.ErrorReportEmail = this.settings.Error_Report_Email__c;
        
        stub.endpoint_x = this.settings.Web_Service_Url__c;
        stub.Header = new WorkdayHumanResources.Security();
		stub.Header.usernameToken = new WorkdayHumanResources.UsernameToken();
		stub.Header.usernameToken.username = this.settings.Web_Service_User_Name__c;
		stub.Header.usernameToken.password = this.settings.Web_Service_Password__c;
        
        if(settings.Last_Update_Time_Stamp__c == null) {
        	QueryString = 'SELECT ID, Name, c2g__ReportingCode__c, LastModifiedDate	' +
                ' FROM c2g__codaDimension1__c ' +
                ' ORDER BY LastModifiedDate';
        } else {
            QueryString = 'SELECT ID, Name, c2g__ReportingCode__c, LastModifiedDate ' +
                ' FROM c2g__codaDimension1__c ' +
                ' WHERE LastModifiedDate >= ' + settings.Last_Update_Time_Stamp__c.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'') +
                ' ORDER BY LastModifiedDate';
        }
    }
    
    global database.querylocator start(database.batchableContext bc) {
        return database.getquerylocator(this.queryString);
    }
    
    global void execute(database.batchablecontext bd, list<sobject> sc) {

        for(sobject sobj : sc) {
            c2g__codaDimension1__c org = (c2g__codaDimension1__c) sobj;
            if(org == null) continue;
            string code = org.c2g__ReportingCode__c.replace('-', '');
            if(code == null || code == '') continue;
            string name = org.Name.replace(org.c2g__ReportingCode__c + ' - ', '');
            if(name == null || name == '') continue;
            
            try {
                WorkdayHumanResources.Organization_DataType cc = new WorkdayHumanResources.Organization_DataType();
                
                cc.Organization_Name = name;
                cc.Availability_Date = date.today();
                cc.Include_Organization_Code_In_Name = TRUE;
                
                //Modified By - Mahendra Swarnkar - CR-20150625-9025 - 07/30/2015
                //Starts from here
                try{
                    //Remove leading zero's
                    code = '' + Integer.valueOf(code);
                    cc.Organization_Reference_ID = 'COST-' + code ;
                    
                    //Append the leading zero's to make the code of standard size
                    if(code.length() <= 6 ){
                        
                        for(integer i = code.length() ; i<6 ;i++ ){
                            code = '0'+ code;
                        }
                        cc.Organization_Code = code; 
                    }
                    else
                        cc.Organization_Code = code.substring(0, 7); 
                    
                }catch(Exception e){
                    
                    cc.Organization_Reference_ID = 'COST-' + code;
                    cc.Organization_Code = code;
                }
                //Ends here
                
                cc.Organization_Type_Reference = new WorkdayHumanResources.Organization_Type_Reference_DataType();
                cc.Organization_Type_Reference.Organization_Type_Name = 'Cost Center';
                cc.Organization_Subtype_Reference = new WorkdayHumanResources.Organization_Subtype_Reference_DataType();
                cc.Organization_Subtype_Reference.Organization_Subtype_Name = 'Cost Center';
                cc.Organization_Visibility_Reference = new WorkdayHumanResources.Organization_Visibility_Reference_DataType();
                cc.Organization_Visibility_Reference.Organization_Visibility_Name = 'Everyone';
                
                WorkdayHumanResources.External_Integration_ID_Reference_DataType result = stub.Add_Update_Organization(cc);
                system.debug('##Call Add_Update_Organization: ' + result.Descriptor);
                
            } catch(Exception ex) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new String[] { this.ErrorReportEmail });
                mail.setSubject('[Error]: SF->Workday Cost Center Sync');
                mail.setHtmlBody('org:' + org.ID + '\r\nError:\r\n' + ex);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
        }
    }
    
    global void finish(database.batchableContext bc) {
        
        // Update Last_Update_Time_Stamp__c
        this.settings.Last_Update_Time_Stamp__c = datetime.now();
        update this.settings;
        system.debug('##Update Last_Update_Time_Stamp__c: ' + this.settings.Last_Update_Time_Stamp__c);
        
   		// Get the ID of the AsyncApexJob representing this batch job from Database.BatchableContext.
   		// Query the AsyncApexJob object to retrieve the current job's information.
   		AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email
                          FROM AsyncApexJob WHERE Id = :BC.getJobId()];
        if(a.JobItemsProcessed > 0 || a.NumberOfErrors > 0) {
            // Send an email to the Apex job's submitter notifying of job completion.
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {a.CreatedBy.Email};
            mail.setToAddresses(toAddresses);
            mail.setSubject('[' + a.Status + ']: SF->Workday Cost Center Sync');
            mail.setPlainTextBody('The batch Apex job has processed ' + a.JobItemsProcessed + 
                                  ' batch(es) with ' + a.NumberOfErrors + ' failures.');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }
    
    public void execute(SchedulableContext ctx) {
        // Schedule it to run every hour
        //System.schedule('Workday Cost Center Hourly Sync', '0 0 * * * ?', new Workday_BatchSyncCostCenter() );
        Database.executeBatch(new Workday_BatchSyncCostCenter(), 100);
    }
}