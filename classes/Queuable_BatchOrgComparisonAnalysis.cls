/*
*   Description     :   Queuable job which runs and hit the heroku and insert the the org changes in the form of Component Change Detail records.
*
*   Created by      :   Mahendra Swarnkar
*
*   Created Date    :   1/27/2020
*
*   Revision Log    :                   
*/
global class Queuable_BatchOrgComparisonAnalysis implements Queueable, Database.AllowsCallouts {
    
    //Map to ,Hold the index (starting from 1) with org comparision record 
    public Integer currentIndex = 0;
    
    //Jobs Status values
    public static final Set<String> releaseSatus = new Set<String>{'Deployed', 'Cancelled'};
          
    public Map<Integer, OrgComparisionWrapper> mapOrgComparisionWrappers;

    //Queuable Job's Execute Method
    public void execute(QueueableContext context) {
        system.debug('@@@@ In Queuable Execule Method' );
        
        //Check if the orgcomparision wrapper is available.
        if(currentIndex > 0){
        	system.debug('currentIndex > 0' );
            //Chekc for size
            if(mapOrgComparisionWrappers.size() > 0) {
                
                system.debug('@@@@ mapOrgComparisionWrappers.size() > 0' );
                
                if(mapOrgComparisionWrappers.containsKey(currentIndex)) {
                    
                	system.debug('@@@@ mapOrgComparisionWrappers.size() > 0' );
                    
                    //Get or Comparision wrapper
                    OrgComparisionWrapper orgCompa = mapOrgComparisionWrappers.get(currentIndex);
                    
                    system.debug('@@@@ currentIndex ' + currentIndex + ' @@@@ orgCompa  ' +  orgCompa );
                     
                    //Get the end point
                    String endPointURL = OrgComparisonAnalysisController.buildURL(orgCompa);
                    
                    system.debug('@@@@ endPointURL ' + endPointURL );
                    try{
                        
                        //Initialize http request
                        HttpRequest req = new HttpRequest();
                        
                        //This the setting query into the endPoint
                        req.setEndpoint(endPointURL);
                        req.setMethod('GET'); 
                        req.setTimeout(120000);
                        
                        //Create a HTTP instance and do callout
                        HttpResponse res;
                        
                        //If not running from the test class
                        if(!Test.isRunningTest()) {
                            
                            system.debug('@@@@ Http Request ' + req );
                            
                            //Get the response
                          	res = HTTPService.send(req);
                            
                            system.debug('@@@@ Http Response Status  ' + res.getStatusCode() + ' @@@@ Http Response ' + res + ' @@@getHeaderKeys' + res.getHeaderKeys());
                            
                            for(String str : res.getHeaderKeys()){
                                system.debug('res.getHeader '+str+' : ' + (res.getHeader(str)));
                            }
                            
                            //Check for Response status
                            if (res.getStatusCode() == 200 || (res.getStatusCode() == 503/* && res.getStatus().containsIgnoreCase('Request TimeOut')*/)) {
                                             
                                
                                //Set the Org comparision status to complete i.e. it will not execute in the next iteration.
                                orgCompa.OrgComparisionStatus = 'Complete';
                                orgCompa.OrgComparisionReleaseLastSyncTimeStamp = System.now();
                                mapOrgComparisionWrappers.put(currentIndex, orgCompa);
                                
                                system.debug('@@@@ currentIndex ' + currentIndex );
                                system.debug('@@@@ orgCompa ' + orgCompa );
                                
                                
                                updateOrgComparionRelatedRecords(orgCompa);
                                
                                
                                
                                currentIndex++;
                                
                                if(mapOrgComparisionWrappers.containsKey(currentIndex)){
                                	system.debug('@@@@ Schedule after 2 minutes ' );
                                    //Schedule the Job after 2 minutes
                                    Scheduler_BatchOrgComparisonAnalysis.scheduleAfterMinutes(2, mapOrgComparisionWrappers, currentIndex);
                                
                                } else {
                                    
                                    system.debug('@@@@ Schedule the Job after 3 hrs ' );
                                    //Schedule the Job after 3 hrs
                                    Scheduler_BatchOrgComparisonAnalysis.scheduleAfterMinutes(60, null, null);
                                }
                            } else {
                                
                                
                                system.debug('@@@@ Exception in response ' + res.getStatusCode() + ': ' + res.getStatus() + ': ' + res.getBody());
                                
                                //If we have any exception.
                                system.debug('@@@@@ res.getStatusCode() ::: ' + res.getStatusCode() + ' :  res.getBody():::  ' + res.getBody());
                                //throw new customException(res.getStatusCode() + ': ' + res.getBody());
                                
                                //Schedule the Job after 5 minute
                                Scheduler_BatchOrgComparisonAnalysis.scheduleAfterMinutes(5, null, null);
                            }
                        }
                        else {
                            //this block is there for mock responses while executing the test class  
                            //res = new MockHTTPCallOutForAWS().respond(req);
                        } 
                        
                    }catch(Exception e){
                        //Schedule the Job after 5 min
                         Scheduler_BatchOrgComparisonAnalysis.scheduleAfterMinutes(5, null, null);
                    }
                }
            } 
        }
    }
    
    public static void updateOrgComparionRelatedRecords(OrgComparisionWrapper orgCompa) {
		
        if(orgCompa.OrgComparisionReleaseLastSyncTimeStamp != null ) {
        
            system.debug('@@@@ Update Org co Last_Org_Comparision_Sync__c with the latest time stamp' );
            
            //List to hold the Release records to update Last_Org_Comparision_Sync__c with the latest time stamp
            List<SFDC_Release__c> listReleaseRecords = new List<SFDC_Release__c>();
            
            if(String.isNotBlank(orgCompa.OrgComparisionReleaseId))
            	listReleaseRecords.add(new SFDC_Release__c(Id = orgCompa.OrgComparisionReleaseId, Last_Org_Comparision_Sync__c = orgCompa.OrgComparisionReleaseLastSyncTimeStamp ));
            
            //List to hold the Release records to update Last_Org_Comparision_Sync__c with the latest time stamp
            List<Org_Comparision__c> listOrgComparisionToUpdate = new List<Org_Comparision__c>();
            if(String.isNotBlank(orgCompa.OrgComparisionId))
            	listOrgComparisionToUpdate.add(new Org_Comparision__c(Id = orgCompa.OrgComparisionId, Created_Date_Bar__c =  orgCompa.OrgComparisionReleaseLastSyncTimeStamp.date() ));
            
            system.debug('@@@@ Update listReleaseRecords ' + listReleaseRecords );
            system.debug('@@@@ Update listOrgComparisionToUpdate ' + listOrgComparisionToUpdate );
            
            //Disable all the trigger
            Util.BypassAllTriggers = true;
            
            //Check for size and update the release records
            if(listReleaseRecords.size() > 0) 
                update listReleaseRecords;
            
            //Check for size and update the Org Comparision records
            if(listOrgComparisionToUpdate.size() > 0) 
                update listOrgComparisionToUpdate;
                
			//Enable all the trigger
            Util.BypassAllTriggers = false;
                                   
        }    
    }   
}