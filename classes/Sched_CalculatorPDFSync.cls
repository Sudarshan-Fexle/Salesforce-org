/**
 * 
 *  Purpose         :   Calls the Calculator PDF Endpoint, which attaches a copy of the calculator PDF to the Quote.
 *
 *  Revision Logs   :   V_1.0 - Created - 12/11/2018 - Victor Hanson - CR-20160414-9762
 * 			V_1.1 - Modified By - Mahendra Swarnkar - 05/28/2019 - CR-20181019-12685 - added check when approved reccord is updated from the QLE to pull the updated "proposal pricing sheet" and "Internal Pricing sheet"
 * 			V_1.2 - Modified By - Victor Hanson     - 02/06/2019 - CR-20200207-13708 - added nullcheck for oldQuote because it was causing issues during ES Historical Dataload
 * 			V_1.3 - Modified By - Subhash           - 10/30/2020 - CR-20201029-14645.- Added "scheduleCounter" and "debuglog" variables to restrict the execution not more than 5 times in a transaction.
 *			V_1.4 - Modified By - Subhash           - 12/16/2020 - CR-20201211-14739 - Updated the collection from List to Set to mainatin the unique values.
 *			V_1.5 - Modified By - Subhash           - 02/05/2021 - CR-20201209-14735
 *		 	V_1.6 - Modified By - Mahendra Swarnkar -            - CR-20210623-15234
 * 
**/
global class Sched_CalculatorPDFSync implements Schedulable, Database.Batchable<sObject>, Database.AllowsCallouts{
    
    public SBQQ__Quote__c quote { get; set; }
    public static boolean hasScheduledSync = false;
    
    //Added by Subhash on 03/03/2020
    public static boolean reShcheduleBatch = false;
    
    //Added by Subhash on 10/30/2020 - CR-20201029-14645 - Start from here 
    public Integer scheduleCounter = 0;
    public string debuglog = '';
    //Added by Subhash on 10/30/2020 - CR-20201029-14645 - ends here
     
    public Sched_CalculatorPDFSync() {
        
    }
    
    /**
     * 
     *  @description	:	Checks to see if a Quote needs to sync the calculator
     * 
     *  @Revision Logs	:	V1.1 - 12/11/2018 - Created - Victor Hanson - CR-20181019-12685
     * 
    **/
    public static void checkForSync(List<SBQQ__Quote__c> quotes, Map<Id, SBQQ__Quote__c> mapOldQuotes) {
        
        //prevent this from executing multiple times on save
        if (hasScheduledSync) return;
        
        for (SBQQ__Quote__c q : quotes) {
            
           // if (q.Is_Enrollment_Services__c) {
                
                SBQQ__Quote__c oldQuote;
                if (mapOldQuotes != null) oldQuote = mapOldQuotes.get(q.Id);
                
                //Modified By - Mahendra Swarnkar - 05/28/2019 - CR-20181019-12685 - Starts from here
                if(q.Schedule_Calculator_Sync_Execution__c == false && q.ApprovalStatus__c == 'Approved' && oldQuote != null && oldQuote.ApprovalStatus__c == 'Approved') 
                    continue;
                //Modified By - Mahendra Swarnkar - 05/28/2019 - CR-20181019-12685 - Ends here
                
                String optionsJSON = getArtifactOptions(q, oldQuote);
                
                if (optionsJSON != null) {
                    
                    //schedule the sync if needed
                    scheduleCalculatorPDFSync(q, optionsJSON, 0);
                    hasScheduledSync = true;
                }
           // }
        }
    }
    
    public static String getArtifactOptions(SBQQ__Quote__c quote, SBQQ__Quote__c oldQuote) {
        
        //Modified by Subhash - 12/16/2020 - CR-20201211-14739 - Updated the collection from List to Set to mainatin the unique values. 
        Set<String> artifacts = new Set<String>();
        
        //use when quote is not approved yet
        if (quote.Sync_Calculator_PDF__c) {
            artifacts.add('Comparison');
            artifacts.add('FullExport');
        }
        
	//Modified By - Mahendra Swarnkar - CR-20210623-15234
        //Modified By - Mahendra Swarnkar - 05/28/2019 - CR-20181019-12685 - Added check [oldQuote.ApprovalStatus__c == 'Approved' && quote.Schedule_Calculator_Sync_Execution__c == true]
        //Modified By - Victor Hanson - 02/06/2019 - CR-20200207-13708 - added nullcheck for oldQuote because it was causing issues during ES Historical Dataload
        //use when quote is approved
        if (quote.ApprovalStatus__c == 'Approved' && oldQuote != null && (quote.ApprovalStatus__c != oldQuote.ApprovalStatus__c || (oldQuote.ApprovalStatus__c == 'Approved' /*&& quote.Schedule_Calculator_Sync_Execution__c == true*/))) {
            artifacts.add('PricingSheet');
            artifacts.add('FullExport');
            
            //Added By Mahendra Swarnkar - 12/26/2019 - to also pull the comparision sheet while pulling in the pricing sheet to resolve the issue of versioning/blank sheet
            artifacts.add('Comparison');
        }
        
        //return null if no sync required
        if (artifacts.size() == 0) return  null;
        
        return JSON.serialize(artifacts);
    }
    
    /**
     *  @description	:	queries quotes where sync calculator pdf = true
     * 
     *  @Revision Logs	:	V1.1 - 12/11/2018 - Created - Victor Hanson - CR-20181019-12685
     *			:       V1.2 - Modified By - Mahendra Swarnkar - CR-20210623-15234
     *
    **/
    global database.querylocator start(database.batchableContext bc) {
        return database.getquerylocator('SELECT Id, Name, Sync_Calculator_PDF__c, Sync_Internal_Calculator_to_Proposal__c FROM SBQQ__Quote__c WHERE Id = \'' + quote.Id + '\'');
    }
    
    /**
     *  @description	:	Sends callout to AWS and sets the Sync Calculator PDF checkbox to false on quote
     * 
     *  @Revision Logs	:	V1.1 - 12/11/2018 - Created - Victor Hanson - CR-20181019-12685
     *
    **/
    global void execute(database.batchablecontext bd, list<sobject> sc) {
	
        List<SBQQ__Quote__c> quotesToUpdate = new List<SBQQ__Quote__c>();//update quotes where the callout was successful
        list<SBQQ__Quote__c> quotes = (list<SBQQ__Quote__c>) sc;
        for(SBQQ__Quote__c q : quotes) {
            
            //Http Request Object
            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://' + LOA_Generator_Settings__c.getInstance().Domain_Name__c + '/api/Calculator');
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            req.setBody(getRequestBody(q));
            req.setTimeout(120000);
            
            HttpResponse res;
            
            if(!Test.isRunningTest())
            {		
            	res = HTTPService.send(req);
                
		// Modified By - Mahendra Swarnkar - CR-20210623-15234 
                if (res.getStatusCode() == 200 || res.getStatusCode() == 202) {
                    q.Sync_Calculator_PDF__c = false;
                    q.Sync_Internal_Calculator_to_Proposal__c = 'Yes';
                    quotesToUpdate.add(q);
                }
                else {
                    
                    //Modified By - Subhash - 2/05/2021 - CR-20201209-14735 - Added check for Status code 500
                    //Modified By - Subhash - 10/30/2020 - CR-20201029-14645 - Starts from here
                    //Added by Subhash on 03/03/2020
                    if(( res.getStatusCode() == 500 || res.getStatusCode() == 504) && scheduleCounter < 5){
                    	scheduleCounter++ ;
                    	reShcheduleBatch  = true;
                    } else{
                    	debuglog = debuglog + res.getStatusCode() + ': ' + res.getBody() + '\n';
                    }
                    //Modified By - Subhash - 10/30/2020 - CR-20201029-14645 - Ends here
                    throw new customException(res.getStatusCode() + ': ' + res.getBody());
                }
            }
            else
            {
                 res = new MockHTTPCallOutForAWS().respond(req);
            }
        }
        System.debug('CPU Time2: ' + LIMITS.getCpuTime());
        if (quotesToUpdate.size() > 0) {
            
            Util.BypassAllTriggers = true;
            update quotesToUpdate;
            Util.BypassAllTriggers = false;
            
        }
    }
    
    /**
     *  @description	:	schedule the job
     * 
     *  @Revision Logs	:	V1.1 - 12/11/2018 - Created - Victor Hanson - CR-20181019-12685
     *
    **/
    global void execute(SchedulableContext ctx) {
        // execute the job
        Sched_CalculatorPDFSync batch = new Sched_CalculatorPDFSync();
        batch.scheduleCounter = scheduleCounter;
        batch.quote = quote;
        batch.artifactOptionsJSON = artifactOptionsJSON;
        Database.executeBatch(batch, 1);
    }
    
    /**
     *  @description	:	returns the JSON body of the request, containing the Quote ID and Name
     * 
     *  @Revision Logs	:	V1.1 - 12/11/2018 - Created - Victor Hanson - CR-20181019-12685
     *
    **/
    public String getRequestBody(SBQQ__Quote__c q) {
        return '{"AttachArtifacts": ' + artifactOptionsJSON + ','
            + '		"Quote": {'
            + '		"Id": "' + q.Id + '",'
            + '		"Name": "' + q.Name + '"'
            + '		}'
            + '	}';
    }
    
    public String artifactOptionsJSON { get; set; }
    
    /**
     *  @description	:	schedules the job that sync calculator PDF file to quote
     * 
     *  @Revision Logs	:	V1.1 - 12/11/2018 - Created - Victor Hanson - CR-20181019-12685
     * 				V1.2 - Modified By - Subhash - 10/30/2020 - CR-20201029-14645 - Added new parameter "scheduleCounter" in the method
     *
    **/
    public static void scheduleCalculatorPDFSync(SBQQ__Quote__c q, String optionsJSON, Integer scheduleCounter) {
    	
    	dateTime sysTime;
    	if(scheduleCounter == 0){
    		sysTime = dateTime.now().addSeconds(10);	
    	} else{
    		sysTime = dateTime.now().addMinutes(6);
    	}
        
        String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        Sched_CalculatorPDFSync job = new Sched_CalculatorPDFSync();
        job.scheduleCounter = scheduleCounter;
        job.quote = q;
        job.artifactOptionsJSON = optionsJSON;
        System.schedule('Sched_CalculatorPDFSync' + sysTime.getTime(),chron_exp, job);
    }
    
    global void finish(database.batchableContext bc) {
        cleanupChronJobs(50);
        
        //Added by Subhash on 03/03/2020
        if(reShcheduleBatch){
        	//schedule the sync if needed
		scheduleCalculatorPDFSync(quote, artifactOptionsJSON, scheduleCounter);    
        }
        
        //Modified By - Subhash - 10/30/2020 - CR-20201029-14645 - Starts from here
        if(String.isNotBlank(debuglog)){
        	Util.sendBatchStatus(BC.getJobId(), 'Sched_CalculatorPDFSync', debuglog, Label.Application_Support_Email);
        }
        //Modified By - Subhash - 10/30/2020 - CR-20201029-14645 - Ends here
    }
    
    /**
     *  @description	:	cleans up chron jobs that are not scheduled for future
     * 
     *  @Revision Logs	:	V1.1 - 12/11/2018 - Created - Victor Hanson - CR-20181019-12685
     *
    **/
    public static void cleanupChronJobs(Integer num) {
        List<CronTrigger> lstCron = [SELECT Id, State, NextFireTime, CronJobDetailId FROM CronTrigger WHERE NextFireTime = Null AND State = 'DELETED' LIMIT :num];
        
        if(lstCron != Null && !lstCron.isEmpty())
        {
            try
            {
                for(CronTrigger obj : lstCron)  
                {
                    system.abortjob(obj.Id);                    
                }
            }
            catch(Exception e)
            {
                system.debug('@@Exception in deleting job : ' + e.getMessage());
            }
        }
    }
}