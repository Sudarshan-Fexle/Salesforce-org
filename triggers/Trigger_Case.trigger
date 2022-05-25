/**
    Purpose         :   This trigger to handle all the processing for case object.(CR-20111219-287)
                
    Create By       :   Simplyforce Technology
    
    Created Date    :   12/24/2011
    
    Revision Logs   :   V_1.0 - Created
                        V_1.1 - Trigger refactored and added logic for CR-20130109-2074    
                        V_1.2 - Added reference to syncCaseToMemberSupport method CR-4283 
                        V_1.3 - Modified By - Abhinav Sharma - 06/19/2014 - CR-20140417-5120  
                        V_1.4 - Modfied By - Abhinav Sharma - 07/03/2014 - CR-20140618-5845
                        V_1.5 - Modified By - Abhinav Sharma - 07/07/2014 - CR-20140618-5849 - Catch DML errors in triggers to reduce exception emails to SFAdmin
                        V_1.6 - Modified By - Abhinav Sharma - 10/15/2014 - CR-20141001-7574
                        V_1.7 - Modified By - Mahendra Swarnkar - 10/17/2016 - CR-20160726-10065
                        V_1.8 - Modified By - Rajeev Jain - 10/19/2016 - Services Excellence - Manually merged code from ServicesEx to Test Sb.
                        V_1.9 - Modified By - Mahendra Swarnkar - 10/20/2016 - CR-20160209-9593
                        V_1.10 - Modified By - Subhash Garhwal - 09/27/2017 - CR-20170926-11418 -  Added the Util.areTriggersOnThisObjectBypassed flag.
			V_1.11 - Modified By - Mahendra Swarnkar - 10/12/2017 - CR-20170929-11625 - Apollo Release
			V_1.12 - Modified By - Victor Hanson - 11/07/2017 - Issue--CR11625--QA--00007247 - Apollo Release - Added populateOwner() method
			V_1.13 - Modified By - Abhinav Sharma - CR-20180928-12623 - Calling method checkIfCaseIsWebHelp.
			V_1.14 - Modified By - Victor Hanson - 03/31/2020 - CR-20200331-13896 - added updateRegistration
			V_1.15 - Modified By - Mahendra Swarnkar - 03/04/2020 - CR-20200217-13756 Comment
			V_1.16 - Modified By - Colin McGloin - 01/26/2021 - CR-20210126-14845 - Commented out manageTasksForSyndicatedServiceCases since it is no longer needed now both Record Types it previously supported were deleted
            		V_1.17 - Modified By - Ayush Gupta - 07/15/2021 - CR-20210625-15243 - Develop automation related to Case
			V_1.18 - Modified By - Ayush Gupta - 07/27/2021 - CR-20210526-15183 - Salesforce Surveys setup
**/
trigger Trigger_Case on Case (before insert, before update, after insert, after update) {
    
    
	try {
    	
        //Check for trigger
        if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate) && (!CaseTriggerHelper.BYPASS_TRIGGER_CASE_ENTITY_POPULATION))
            CaseTriggerHelper.populateEntityField(Trigger.New, Trigger.oldMap);
    	
    	//return immediately if method returns true	
    	if(Util.areTriggersOnThisObjectBypassed('Case')) return;
    	
        if (Util.BypassAllTriggers) return;
        
        //Checking for the event
        if (trigger.isBefore) {
            
            if(Trigger.isUpdate) {
                
                
                
                //Added By Ayush gupta - 07/27/2021 - CR-20210526-15183 - Salesforce Surveys setup
               // CaseTriggerHelper.sentSurveyToUsers(trigger.newMap, trigger.oldMap);
            }
            
            //V_1.7 - Modified By - Rajeev Jain - 10/19/2016 - Services Excellence - Manually merged code from ServicesEx to Test Sb.
            //populate Member Portal Status from Status
            FieldMappingHelper.mapFields(trigger.new);
            //V_1.7 - Modified By - Rajeev Jain - 10/19/2016 - Services Excellence - Manually merged code from ServicesEx to Test Sb. - upto here
            
            //Checking for the request type
            if(Trigger.isInsert || Trigger.isUpdate) {
                //Calling Helper method.
                //Added by Abhinav Sharma - 09/06/2019 - CR-20190905-13318
                //Modified by Neha Sharma   - 03/09/2021 - CR-20201207-14726 - Populate the cappex partner success manager on case
                CaseTriggerHelper.populateLookupFields(trigger.new,Trigger.oldMap);

                
                //Added By - Ayush Gupta - 07/15/2021 - CR-20210625-15243 - Develop automation related to Case
                CaseTriggerHelper.updateIntersectPartnerEmail(Trigger.New, Trigger.oldMap);
            }
            
            //Checking for the request type
            if(Trigger.isInsert || Trigger.isUpdate) {
                
                //Populate data from Case -> MS record CR-4283
                CaseTriggerHelper.syncCaseToMemberSupport(Trigger.New, Trigger.oldMap);
                
                //Calling Helper class method to do the validation and then populating fields on case records
                CaseTriggerHelper.beforeEventsLogicHandler(Trigger.New, Trigger.oldMap);
                
                //If the Resolution Summary field is updated and Status = 'Solution Provided', post the resolution to comments
                CaseTriggerHelper.postResolutionToComments(Trigger.New, Trigger.oldMap);
                
                //Victor Hanson - 03/31/2020 - CR-20200331-13896 - If the Case has a Registration with specific values, auto-approve the related registration
                CaseTriggerHelper.updateRegistration(Trigger.new);
            }
        }            
        
        //Added By - Abhinav Sharma - 06/19/2014 - CR-20140417-5120
        //Checking for event type
        if(Trigger.isAfter) {
            
            //Victor Hanson - 11/07/2017 - Issue--CR11625--QA--00007247 - Apollo Release
            CaseTriggerHelper.populateOwner(Trigger.new, Trigger.oldMap);
            
            //Checking for request type
            if(Trigger.isInsert) {
            	
                //Victor Hanson - 11/07/2017 - Issue--CR11625--QA--00007247 - Apollo Release - Commented out populateCaseFromEmailToCase().  Replaced with populateOwner() method.
                //Calling helper class method
                //CaseTriggerHelper.populateCaseFromEmailToCase(Trigger.newMap.keySet());
                
                //Calling Helper class method to deleted out the "Out of Office" Type case records
                CaseTriggerHelper.deletedOutOutOfOfficeCases(Trigger.newMap.keySet());
                
                //Commented by Mahendra Swarnkar - 03/04/2020 - CR-20200217-13756 - Start Here
                //Calling helper class method
                //Added By - Mahendra Swarnkar - 10/17/2016 - CR-20160726-10065
                //CaseTriggerHelper.UpdateContactTECCasesCount(Trigger.new);
                //Commented by Mahendra Swarnkar - 03/04/2020 - CR-20200217-13756 - End Here
                
                //Checking for the Insert case - Added By Abhinav sharma - CR-20180928-12623 - Calling method checkIfCaseIsWebHelp
                CaseTriggerHelper.checkIfCaseIsWebHelp(trigger.new);
                
                //Checking for the Insert case - Added By Ayush Gupta - 08/19/2021 - Calling method notifyAccountOwner
                CaseTriggerHelper.notifyAccountOwner(trigger.new);
            }
            
            //Added By - Abhinav Sharma - 10/15/2014 - CR-20141001-7574
            //Checking for the request type
            if(Trigger.isInsert || Trigger.isUpdate) {
                
                //Calling helper class method to manage the tasks according to events on Case records
                //CaseTriggerHelper.manageTasksForSyndicatedServiceCases(Trigger.New, Trigger.oldMap);
                
                //Added By - Mahendra Swarnkar - 10/20/2016 - CR-20160209-9593
                //Calling helper class method to Sent an email to parent case owner  whenever the child case is closed
                CaseTriggerHelper.sentEmailToParentCaseOwnerOnChildClosed(Trigger.New, Trigger.oldMap);
            	
                //Calling helper class method to set ownerId and send email to the owner if owner id is changed in case of WebHelp recordType.
                ////Added by Abhinav Sharma - 09/06/2019 - CR-20190905-13318
                CaseTriggerHelper.populateCaseOwner(Trigger.New, Trigger.oldMap);
            }
            
               if(Trigger.isUpdate) {
                
                   //Added By - Ayush Gupta - 07/15/2021 - CR-20210625-15243 - Develop automation related to Case
                   if (!CaseTriggerHelper.BYPASS_TRIGGER_CASE_UPDATE_SUPPORT_PRODUCT){
                    CaseTriggerHelper.updateSupportProduct(Trigger.New, Trigger.oldMap);
                   }
                   
                //Added By Ayush gupta - 07/27/2021 - CR-20210526-15183 - Salesforce Surveys setup
                CaseTriggerHelper.sentSurveyToUsers(trigger.newMap, trigger.oldMap);
            }
        }


    //Catching all Exceptions
    } catch(Exception e) {

        //Add Error Message on Page
        if(Trigger.isDelete)
            Trigger.Old[0].addError(e.getMessage());
        else
            Trigger.New[0].addError(e.getMessage());
    }
}