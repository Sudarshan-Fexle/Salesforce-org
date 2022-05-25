/*
    Purpose:    This trigger is responsible for handling all the pre or post processing for
                any dml operation for Warm Lead object 
    
    Create By   :       Simplyforce Technology
    
    Created Date:       10/31/2012
    
    Current Version:    v1.4
    
    Revision Log:       v1.0 - Created
                        v1.1 - Modified - Bhavi - 4/24/2013 -CR-20130411-2856
                        v1.2 - Modified(before, after delete event added) - Bhavi - 12/13/2013 - CR-20130417-2892
                        v1.3 - Bhavi Sharma - 02/22/2014 - CR-20140121-4302
                        v1.4 - Modified By - Abhinav Sharma - 07/07/2014 - CR-20140618-5849 - Catch DML errors in triggers to reduce exception emails to SFAdmin
                        v1.5 - Modified By - Abhinav Sharma - 08/14/2014 - CR-20140623-5887 - Leveleven Follow Up Development work
                        v1.6 - Modified By - Abhinav Sharma - 11/24/2014 - CR-20141029-7923 - Initial Visit Date Trigger on Warm Leads
						v1.7 - Modified By - Victor Hanson - 06/29/2015 - CR-20150129-8609 - added reference to populateDefaultValues method
						v1.8 - Modified By - Abhinav Sharma - 10/20/2015 - CR-20150908-9227 - added reference to populateReportingLeadChannel method
						v1.9 - Modified By - Subhash Garhwal - 09/27/2017 - CR-20170926-11418 -  Added the Util.areTriggersOnThisObjectBypassed flag.
						v1.10 - Modified By - MAhendra Swarnkar - Apollo Release - 10/09/2017 -CR-20170928-11599  - Added a new call for Entity field.
						v1.11 - Modified By - Deepak kumawat - Hypercare - Apollo - SF and FF Workstream (CR-20171116-11784) - added reference to updateEntityValueOnWarmLead method
						V1.12 - Modified By - Dipesh Gupta - 03/20/2020 - CR-20191210-13556(Warm lead lookup field on Event)
*/
trigger Trigger_WarmLead on Warm_Lead__c (after insert, after update, before insert, before update, before delete,  after delete) {
    
	try {
    	
    	//Check for trigger
        if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
    		
            //Call the helper class method to populate the entity value - 11/17/2017 - CR-20171116-11784
            WarmLeadTriggerHelper.updateEntityValueOnWarmLead(Trigger.New, Trigger.oldMap);
        }    
            
    	//return immediately if method returns true	
    	if(Util.areTriggersOnThisObjectBypassed('Warm_Lead__c')) return;
        
        //Bypassing trigger according to the flag value
        if (Util.BypassAllTriggers) 
            return;
        
        //Check for the request type
        if(Trigger.isBefore) {
            
            //Check for the event type
            if(Trigger.isInsert || Trigger.isUpdate) {
                
                //Added Trigger.oldMap in method: "setName" by Mahendra Swarnkar - 04/04/2020 - CR-20200305-13830
                //Call the helper class method to set the name
                WarmLeadTriggerHelper.setName(Trigger.New, Trigger.oldMap);
                WarmLeadTriggerHelper.populateReportingLeadChannel(Trigger.New);
            }
            
            if (trigger.isInsert) {
                
                //method to default values when source interaction and outcome type are populated
                WarmLeadTriggerHelper.populateDefaultValues(trigger.new);
                // Added By - Dipesh Gupta - 03/20/2020 - CR-20191210-13556(Warm lead lookup field on Event)
                WarmLeadTriggerHelper.prepopulateAccountOnWarmLead(trigger.new);
            }
            
            //Check for the event type
            if(Trigger.isUpdate) {
             
                //Added By - Abhinav Sharma - 11/24/2014 - CR-20141029-7923
                //Added Trigger.oldMap in method "populateInitialVisitDate" by Mahendra Swarnkar - 04/04/2020 - CR-20200305-13830
                //Call helper class method
                WarmLeadTriggerHelper.populateInitialVisitDate(Trigger.new, Trigger.oldMap);
            }
            
            //Code added by Bhavi - 12/13/2013 - CR-20130417-2892
            //Check for event type 
            else if(Trigger.isDelete) {
                
                //Call the helper class method to delete related WarmLeadMtM records 
                WarmLeadTriggerHelper.populateOpportunityCountOfSourcedWarmLead(Trigger.Old, Trigger.isBefore);
            }
            
        } else {
        
            //Allows this object to be used in the Compete App
            //Added as part of CR-5887
            //ePrize_Zemzu.SCBCustomContestEvaluator.evaluate('Warm_Lead__c',Trigger.new,Trigger.old);
            
            //Check for the event type
            if(Trigger.isInsert || Trigger.isUpdate) {
                
                //Check if the method has not already been executed
                if(WarmLeadTriggerHelper.EXECUTE_TRIGGER_CREATE_MATCHING_WARM_LEADS_MTM) {
    
                    //Call the helper class method to create the MtM records
                    //Bhavi Sharma - 4/24/2013 -CR-20130411-2856
                    WarmLeadTriggerHelper.UpdateStatusOfRelatedOpp(Trigger.newMap, Trigger.oldMap);           
                }
            
                //After update
                if(Trigger.isUpdate) {
                    
                    //Call helper class to update the opportunity's sourced warm lead information if lead date changed
                    WarmLeadTriggerHelper.populateOpportunityCountOfSourcedWarmLead(Trigger.New, Trigger.oldMap);
                }
            }
            
            //Code added by Bhavi - 12/13/2013 - CR-20130417-2892
            //Check for event type 
            else if(Trigger.isDelete) {
                
                //Call the helper class method to delete related WarmLeadMtM records 
                WarmLeadTriggerHelper.populateOpportunityCountOfSourcedWarmLead(Trigger.Old, Trigger.isBefore);
            }
            
            //Added By Bhavi Sharma - 02/22/2014 - CR-20140121-4302
            //Update Most Recent Lead Information to Contact
            WarmLeadTriggerHelper.updateLeadInfoOnContact(Trigger.New, Trigger.oldMap);
        }
        
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