/**
 *  Purpose         :   This trigger is to handle all teh pre and post processing operation for Event trigger
 * 
 *  Created By      :   Bhavi Sharma
 * 
 *  Created Date    :   01/19/2015
 * 
 *  Revision Logs   :   V_1.0 - Created (CR-20141119-8126)
                        V_1.1 - Modified By - Mahendra Swarnkar - 05/16/2015 - CR-20150401-8835
                        V_1.2 - Modified By - Mahendra Swarnkar - 08/26/2015 - CR-20140613-5790
                        V_1.3 - Modified By - Abhinav Sharma - 09/04/2015 - R-20150817-9161 
                        V_1.4 - Modified By - Subhash Garhwal - - 02/17/2017 - CR-20170403-10807 - primaryProposalRequiredForEvent(work order DS157)
                        V_1.5 - Modified By - Rajeev Jain - 07/05/2017(In order of migration tasks of - Releases after Q2CDev3 sandbox refresh date[04/07/2017] in Q2CDev3 sandbox from Test sandbox in order to sync with Q2c Beta Release and Revenue Management
                        V_1.4 - Modified By - Mahendra Swarnakar - 04/25/2017 - CR-20170302-10730 - Commentedout the method (syncUpPSSrequestsFields). Because as per the new "PSS process" it is no longer needed. 
                        V_1.5 - Modified By - Mahendra Swarnakar - 04/25/2017 - CR-20170302-10730 - invoked the methods (doIcsAttachment and  handleGoogleEvent) to sent and outlook invite on the creation of Event record on the PSS request.
                        V_1.5 - Modified By - Rajeev Jain - 07/05/2017 - UPTO HERE
                        V_1.6 - Modified By - Subhash Garhwal - 09/27/2017 - CR-20170926-11418 -  Added the Util.areTriggersOnThisObjectBypassed flag.
                        V_1.7 - Modified By - Abhinav Sharma - 03/28/2018 - CR-20170620-11016 - New Method call - syncWithPssRequest
                        V_1.8 - Modified By - Mahendra Swarnkar - 02/14/2019 - CR-20190204-12863 - New Method call - populateRelatedTypeField 
                        V_1.9 - Modified By - Victor Hanson - 04/24/2019 - CR-20190204-12863 - added populateAllInstRoles
                        V_2.0 - Modified By - Victor Hanson - 08/07/2019 - CR-20190204-12863 - added populateNoContact
                        V_2.1 - Modified By - Dipesh Gupta - 08/12/2019 - CR-20190429-13049  - New Method call - populateFirstCreditedEventDateOnOpportunity
                        V_2.2 - Modified By - Dipesh Gupta - 01/22/2020 - CR-20200102-13583  - New Method call - populateProjectFields
			V_2.3 - Modified By - Dipesh Gupta - 01/24/2020 - CR-20200110-13610 - New Method call - validateContactStatus
			V_2.4 - Modified By - Neha Sharma - CR-20210202-14862 - 04/12/2021 - Add calling of new method (populateCountOnOpportunityFields)
			V_2.6 - Modified By - Pankaj - 04/16/2021 - CR-20210407-15063 -added sendEmailNotification
			V_2.7 - Modified By - Neha Sharma - CR-20201021-14627 - 04/16/2021 - createMembershipMtMRecords,deleteMembershipMtMRecords
			V_2.8 - Modified By - Nikita Kumari - 02/08/2022 - CR-20220119-15726 - Update related MQL Credits
 **/ 
trigger Trigger_Event on Event (after insert, after update,  after delete, before insert, before update) {
    
    //return immediately if method returns true 
    if(Util.areTriggersOnThisObjectBypassed('Event')) return;   

    //Bypass
    if(Util.BypassAllTriggers
        || Util.IsBatch
        || EventTriggerHelper.EXECUTE_TRIGGER == false)
        return;
    
    //Check for the request type
    if(Trigger.isAfter) {
        
    	//V_1.5 - Merged By - Rajeev Jain - 07/05/2017 - UPTO HERE
        //V_1.4 - Modified By - Mahendra Swarnakar - 04/25/2017 - CR-20170302-10730 - Commentedout the method (syncUpPSSrequestsFields). Because as per the new "PSS process" it is no longer needed. - Starts From Here
        /**
        //Check for the event type
        if(Trigger.isUpdate) {
            
            //Calling helper class method to sync up "PSS Request" records fields on the basis of event records
            EventTriggerHelper.syncUpPSSrequestsFields(Trigger.new, Trigger.oldMap);
        }
    	**/
    	//V_1.4 - Modified By - Mahendra Swarnakar - 04/25/2017 - CR-20170302-10730 - Commentedout the method (syncUpPSSrequestsFields). Because as per the new "PSS process" it is no longer needed. - Ends Here
    	//V_1.5 - Merged By - Rajeev Jain - 07/05/2017 - UPTO HERE
        
        //Check for the event type
        if(Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete) {
            
            EventTriggerHelper.populateCTFieldsOnSubsciptionPeriod(Trigger.New, Trigger.oldMap);
            //Added by - Dipesh Gupta - 01/22/2020 - CR-20200102-13583
            EventTriggerHelper.populateProjectFields(Trigger.New, Trigger.oldMap);
            
            //Added BY - Abhinav Sharma - CR-20200420-13963
            EventTriggerHelper.populateOpportunityFields(Trigger.New, Trigger.oldMap); 
            
            //Added BY - Abhinav Sharma - CR-20210202-14862
            EventTriggerHelper.populateCountOnOpportunityFields(Trigger.New, Trigger.oldMap); 

            //Call helper class method to update the most recent QA Call data
            if(!EventTriggerHelper.BYPASS_EVENT_TRIGGER_FOR_MERGE)
                EventTriggerHelper.populateMostRecentQACall(Trigger.New, Trigger.oldMap);
            
            //Added by - Mahendra Swarnkar -05/16/2015 - CR-20150401-8835
            //Starts from here
            //Call helper class method to update the Next Activity Date field on Opporutnity.
            EventTriggerHelper.updateNextActivityDate(Trigger.New, Trigger.oldMap);
            
            //Added by - Abhinav Sharma - 08/26/2015 - CR-20140613-5790
            //Starts from here
            //Call helper class method to update the Next Activity Date field on Opporutnity.
            EventTriggerHelper.populatePAsAndActivityFieldsOnOpportunity(Trigger.New, Trigger.oldMap);
            //Ends here
            
       	    //V_1.5 - Merged By - Rajeev Jain - 07/05/2017 -
            //V_1.5 - Modified By - Mahendra Swarnakar - 04/25/2017 - CR-20170302-10730 - Starts from here 
            if((Trigger.isInsert || Trigger.isUpdate) && EventTriggerHelper.isAlreadyExecuted == False){
                
                if(!EventTriggerHelper.BYPASS_EVENT_TRIGGER_FOR_MERGE)
                    EventTriggerHelper.handleGoogleEvent(Trigger.New, Trigger.oldMap);
                
                //Added by Victor Hanson - 04/24/2019 - CR-20190204-12863 - populates All Institution Roles on Event
                if (!system.isBatch() && !system.isFuture() && !system.isQueueable() && !system.isScheduled())
                    EventTriggerHelper.populateAllInstRoles(Trigger.newMap.keySet());
                
                //Added by Victor Hanson - 08/07/2019 - CR-20190204-12863 - populates whoId if blank for certain objects to link Event to Acct
                EventTriggerHelper.populateNoContact(Trigger.new);
            }
            //V_1.5 - Modified By - Mahendra Swarnakar - 04/25/2017 - CR-20170302-10730 - Ends here
            //V_1.5 - Merged By - Rajeev Jain - 07/05/2017 - UPTO HERE
            //V_1.5 - Added By - Dipesh Gupta - 08/12/2019 - CR-20190429-13049 
            if(Trigger.isInsert || Trigger.isUpdate){
                EventTriggerHelper.populateFirstCreditedEventDateOnOpportunity(Trigger.New, Trigger.oldMap);
                
                //Added new method : By mahendra swarnkar - 03/24/2020 - CR-20200122-13648
            	EventTriggerHelper.updateContactProtocoledField(Trigger.New, Trigger.oldMap);
                
            }
	    
            if(Trigger.isInsert){
	    
                //Added new method : By Pankaj - 04/16/2021 - CR-20210407-15063
                EventTriggerHelper.sendEmailNotification(Trigger.New);
	    }
            
            if(Trigger.isUpdate){
	    
               //Added new method : By Neha sharma - 04/16/2020 - CR-20201021-14627
            	EventTriggerHelper.createMembershipMtMRecords(Trigger.newMap,Trigger.Oldmap);
	    }
            
            //Added by neha sharma - 04/16/2021 - CR-20201021-14627
            if(Trigger.isDelete)
            {
                EventTriggerhelper.deleteMembershipMtMRecords(Trigger.New,Trigger.oldMap);
            }
        }
        
        //check for update
        if(Trigger.isUpdate)
        {
            //Added By - Nikita Kumari - 02/08/2022 - CR-20220119-15726 - Update related MQL Credits
            EventTriggerHelper.updateRelatedMQLCredits(Trigger.New, Trigger.oldMap);
        }
    }
    
    //Check for request type
    if(Trigger.isBefore) {
        //Added By - Abhinav Sharma - 09/04/2015 - R-20150817-9161 
        if(Trigger.isInsert || Trigger.isUpdate) {
            EventTriggerhelper.updateEventHistoryTrackingFields(Trigger.new, Trigger.oldMap); 
            
            //VH 03/05/2019 - added for Sortable Data Grid POC
            EventTriggerHelper.populateContactLookup(Trigger.new);
            
            //Added By Abhinav Sharma - 03/28/2018 - CR-20170620-11016
            EventTriggerhelper.syncWithPssRequest(Trigger.new, Trigger.oldMap);
           
            //Added by Mahendra Swarnkar - 02/14/2019 - CR-20190204-12863
            EventTriggerhelper.populateRelatedTypeField(Trigger.new, Trigger.oldMap);
            
            //Added by Dipesh Gupta - 01/24/2020 - CR-20200110-13610
            EventTriggerhelper.validateContactStatus(Trigger.new, Trigger.oldMap);

        }
    }
}