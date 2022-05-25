/*
    Purpose:     update for each linked Opportunity: 
                     Opportunity.Count of Warm Leads : This should be a count of all Warm Lead MtM records attached to the Opportunity
                     Opportunity.Warm_Lead__c : This checkbox should be checked. (true <=> Count of Warm Leads > 0)
                 For each linked Warm Lead:
                    Warm_Lead__c.Number_of_Warm_Leads__c : This is a count of all Warm Lead MtMs on the Warm Lead that are connected to Opportunities
                    Warm_Lead__c.Initial_Visit_Date__c : Earliest Initial Visit Date of all attached Opportunities
    
    Created By:     Jeremy Nottingham (Synaptic) - 1/20/2011
    
    Last Modified By:   Nathan Banas (Synaptic) - 1/25/2011
    
    Current Version:    v1.4
    
    Revision Log:       v1.1 - (JN-2011-01-20) - Created this header and added the Warm Lead field
                        v1.2 - (NB-2011-01-25) - Reviewed code coverage and functionality
                        v1.3 - Code modified - Bhavi Sharma - 12/13/2013 - CR-20130417-2892  
                        v1.4 - Modified By - Abhinav Sharma - 07/07/2014 - CR-20140618-5849 - Catch DML errors in triggers to reduce exception emails to SFAdmin 
			v1.5 - Modified By - Subhash Garhwal - 09/27/2017 - CR-20170926-11418 -  Added the Util.areTriggersOnThisObjectBypassed flag.
*/
trigger WarmLeadMtM_UpdateOppFields on Warm_Lead_MtM__c (after insert, after update, after delete) {

    //return immediately if method returns true	
    if(Util.areTriggersOnThisObjectBypassed('Warm_Lead_MtM__c')) return;

    try {
    
        //declare this trigger is operating to any following processes
        Util.IsTrigger_WarmLeadMtM = true;
        
        // Build list of WLMtM to process based on if this trigger was called by and Insert or Delete operation
        List<Warm_Lead_MtM__c> triggeropps;
        
        if (Trigger.isInsert || Trigger.isUpdate)
            triggeropps = Trigger.new;
        else
            triggeropps = Trigger.old;
        
        //create sets of related record IDs
        Set<id> oppIds = new Set<id>();
        set<id> warmleadids = new set<id>();
        
        // Loop through the WLMtM that spawned this trigger 
        for (Warm_Lead_MtM__c wlmtm : triggeropps) {
        
            // If the WLMtM has an opportunity, add the related Opp and Warm Lead to a list
            if (wlmtm.Opportunity__c != null) {
                oppIds.add(wlmtm.Opportunity__c);
                warmleadids.add(wlmtm.Warm_Lead__c); 
                
                //Code added - Bhavi Sharma - 12/13/2013 - CR-20130417-2892
                //Check if trigger is running on update and user has changed the Opportunity id on Warm Lead MtM record,
                //Then add this opportunity in Map to update the counter values on it 
                if(Trigger.isUpdate && Trigger.oldMap.get(wlmtm.Id).Opportunity__c != null && Trigger.oldMap.get(wlmtm.Id).Opportunity__c != wlmtm.Opportunity__c)
                    oppIds.add(Trigger.oldMap.get(wlmtm.Id).Opportunity__c);
            }
        }
        
        //Update opportunities
        if(oppIds.size() > 0) {
        
            try {
                
                //Update opportunity infomration
                WarmLeadMtMTriggerHelper.updateWarmLeadInfoOnOpportunity(oppIds);
            
            //Catching DML type exception
            } catch(DMLException ex) {
                
                if (ex.getDMLMessage(0).contains('Only Finance Ops Users can set the stage field to')) {
                    for (Warm_Lead_MtM__c wl : triggeropps) {
                        wl.addError('Only Finance Ops Users can add/update warm leads to this Opportunity because it is in the stage Closed Won, Void, Dropped, Honorary, ATL, or Sent to Finance - Opp Rejected.<br/>'+
                            ' Please contact <a href="mailto:salesforcehelp@advisory.com?Subject=Error when creating warm lead MTM">salesforcehelp@advisory.com</a> with any questions.');
                    }
                } else { // this else stmt fixes the bug from CR-1614
                    for(Warm_Lead_MtM__c wl : triggeropps) {
                        wl.addError(ex.getDMLMessage(0));
                    }
                }
                
            //Catching all types of exceptions  
            } catch(Exception ex) {
                
                for(Warm_Lead_MtM__c wl : triggeropps) {
                    wl.addError(ex.getMessage());
                }
            }
        }
        
        /*   Warm Lead Field updates  */
        
        list<Warm_Lead__c> wlstoupdate = new list<Warm_Lead__c>();
        
        //Query for Warm Leads with associated Mtms
        list<Warm_Lead__c> wlstocheck = [select id, Number_of_Warm_Leads__c, Initial_Visit_Date__c,
            (select id, Opportunity__r.Initial_Visit_Date__c from Warm_Leads_MtM__r where Opportunity__c != null) 
            from Warm_Lead__c where id in :warmleadids];
            
        system.debug('\n\n### Number of Warm Leads to check: ' + wlstocheck.size());
        
        // Loop through the Warm Leads associated w/ the WLMtMs calling this trigger
        for (Warm_Lead__c wl : wlstocheck) {
            
            Integer mtmcount = 0;
            Boolean UpdateWL = false;
            
            system.debug('\n\n### Number of Warm Lead MtM related to check: ' + wl.Warm_Leads_MtM__r.size());
            
            // Loop through all WLMtM associated w/ the Warm Leads
            for (Warm_Lead_MtM__c wlmtm : wl.Warm_Leads_MtM__r) {
                
                mtmcount++;
                
                system.debug('\n\n### Warm Lead MtM Opportunity Initital Visit Date: ' + wlmtm.Opportunity__r.Initial_Visit_Date__c);
                
                // If the related Opportunity Initial Visit Date is null, skip processing this record
                if (wlmtm.Opportunity__r.Initial_Visit_Date__c == null)
                    continue;
                
                system.debug('\n\n### Warm Lead: ' + wl.id + ' / WL Initial Visit Date: ' + wl.Initial_Visit_Date__c  + ' / Opp Initial Visit Date: ' + wlmtm.Opportunity__r.Initial_Visit_Date__c);
                
                // If the Warm Lead Initial Visit Date is null OR the Warm Lead Initial Visit Date is greater than the WLMtM's Opportunity Initital Visit Date,
                // then set the Warm Lead's Initial Visit Date equal to the WLMtM Opportunity Initial Visit Date
                if ((wl.Initial_Visit_Date__c == null) || (wl.Initial_Visit_Date__c > wlmtm.Opportunity__r.Initial_Visit_Date__c)) {
                    UpdateWL = true;
                    wl.Initial_Visit_Date__c = wlmtm.Opportunity__r.Initial_Visit_Date__c;
                }
            }
            
            // Set the Count of Warm Leads on the Warm Lead based on the number of WLMtMs that were processed
            if (mtmcount != wl.Number_Of_Warm_Leads__c) {
                wl.Number_Of_Warm_Leads__c = mtmcount;
                UpdateWL = true;
            }
            
            // If there were changes to the current Warm Lead, then add it to a list to be updated
            if (UpdateWL)
                wlstoupdate.add(wl);
        }   
            
        //Update warm lead records, if any
        if (wlstoupdate.size() > 0)
            update wlstoupdate;
    
        //Added by Bhavi Sharma - 05/04/2013 - CR-20130411-2856
        if(Trigger.isAfter) {
            
            //Check for the event type
            if(Trigger.isInsert) {
                
                //update warm lead records
                if(wlstocheck != null && wlstocheck.size() > 0)
                    update wlstocheck;  
            }
        }
    //Catching DML Exceptions
    } catch(DMLException e) {

        //Add Error Message on Page
        if(Trigger.isDelete)
            Trigger.Old[0].addError(e.getDmlMessage(0));
        else
            Trigger.New[0].addError(e.getDmlMessage(0));

    //Catching all Exceptions
    } catch(Exception e) {

        //Add Error Message on Page
        if(Trigger.isDelete)
            Trigger.Old[0].addError(e.getMessage());
        else
            Trigger.New[0].addError(e.getMessage());
    }
}