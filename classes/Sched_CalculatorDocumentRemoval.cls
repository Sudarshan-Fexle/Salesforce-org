/**
 * 
 *  Purpose         :   Calls the Calculator PDF Endpoint, which removes the copy of the Document from a Proposal. Initially used on Proposals which were cloned to remove the Document from records that have been cloned
 *
 *  Revision Logs   :   V_1.0 - Created - 05/22/2020 - Colin McGloin - CR-20200518-14066
 * 
**/


global class Sched_CalculatorDocumentRemoval implements Schedulable, Database.Batchable<sObject>, Database.AllowsCallouts {

    //List of Proposals to pass through to the job
    public List<SBQQ__Quote__c> proposals { get; set; }

    public Sched_CalculatorDocumentRemoval() {

    }

    /**
     *  @description	:	schedule the job
     * 
     *  @Revision Logs	:	V1.0 - 05/22/2020 - Colin McGloin - CR-20200518-14066
     *
    **/
    global void execute(SchedulableContext ctx) {
        System.debug('@@@@ In Scheduler execute Method');
        // execute the job
        Sched_CalculatorDocumentRemoval batch = new Sched_CalculatorDocumentRemoval();
        batch.proposals = proposals;
        Database.executeBatch(batch, 1);
    }

    /**
     *  @description	:	Pass through Quotes which have been cloned and have Signing_Document_Id__c populated
     * 
     *  @Revision Logs	:	V1.0 - 05/22/2020 - Colin McGloin - CR-20200518-14066
     *
    **/
    global database.querylocator start(database.batchableContext bc) {
        //system.debug('@@quote.Id:' + quote.Id);
        String query = 'SELECT Id, Name, Signing_Document_Id__c FROM SBQQ__Quote__c WHERE Id IN :proposals';

        return database.getquerylocator(query);
    }


        /**
     *  @description	:	Sends callout to AWS to remove the Document
     * 
     *  @Revision Logs	:	V1.0 - 05/22/2020 - Colin McGloin - CR-20200518-14066
     *
    **/
    global void execute(database.batchablecontext bd, list<sobject> sc) {
        List<SBQQ__Quote__c> quotesToUpdate = new List<SBQQ__Quote__c>();//update quotes where the callout was successful
        list<SBQQ__Quote__c> props = (list<SBQQ__Quote__c>) sc;
        System.debug('@@@@ In Batch execute Method + quotes : ' + props);
        System.debug('CPU Time1: ' + LIMITS.getCpuTime());
        for(SBQQ__Quote__c q : props) {
            
            //Http Request Object
            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://' + LOA_Generator_Settings__c.getInstance().Domain_Name__c + '/api/SignNow?id=' + q.Id + '&number=' + q.Signing_Document_Id__c);
            req.setMethod('DELETE');
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('x-api-key', LOA_Generator_Settings__c.getInstance().API_Key__c);
            req.setTimeout(120000);
            
            HttpResponse res;
            
            if(!Test.isRunningTest())
            {		
                 res = HTTPService.send(req);
                 
                if (res.getStatusCode() == 200) {
                    q.Signing_Document_Id__c = null;
                    quotesToUpdate.add(q);
                    
                    System.debug('@@@@ Response : ' + res);
                }
                else {

                    if(res.getStatusCode() == 400 || res.getStatusCode() == 500)
                    
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
            System.debug('@@@@@@ quotesToUpdate' + quotesToUpdate);
            
            Util.BypassAllTriggers = true;
            update quotesToUpdate;
            Util.BypassAllTriggers = false;
            
        }
    }

    global void finish(database.batchableContext bc) {
        cleanupChronJobs(50);
        
    }

    /**
     *  @description	:	schedules the job to remove the Quotes from the Proposal Clone
     * 
     *  @Revision Logs	:	V_1.0 - Created - 05/22/2020 - Colin McGloin - CR-20200518-14066
     *
    **/
    public static void scheduleCalculatorDocumentRemoval(List<SBQQ__Quote__c> props) {
        dateTime sysTime = dateTime.now().addSeconds(10);
        String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        Sched_CalculatorDocumentRemoval job = new Sched_CalculatorDocumentRemoval();
        job.proposals = props;
        System.schedule('Sched_CalculatorDocumentRemoval' + sysTime.getTime(),chron_exp, job);
    }

        /**
     *  @description	:	cleans up chron jobs that are not scheduled for future
     * 
     *  @Revision Logs	:	V_1.0 - Created - 05/22/2020 - Colin McGloin - CR-20200518-14066
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