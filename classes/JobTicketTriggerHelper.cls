/**
    *  Purpose         :  This Class is having all the automation logic method on Job Ticket object.
    * 
    *  Created By      :   Dipesh Gupta
    *
    *  Created Date    :   10/14/2019
    *
    *  Revision Logs   :   V_1.0 - Created  - CR-20191011-13405
    *		       :   V_1.1 - Modified By Dipesh Gupta - CR-20200325-13887 - Added a new method - checkIfJobTicketDuplicated
    *                  :   V_1.2 - Modified By Dipesh Gupta - 4/22/2020  - CR-20200415-13951 - Change the status "Approved by Client" to "Approved by Partner"
    *                  :   V_1.3 - Modified By Victor Hanson - 05/04/2020 - CR-20200221-13792 - changeReasonRequiredForLockedRecord - only validate if one of the locked fields is updated
    *		       :   V_1.4 - Modified By Victor Hanson - 05/14/2020 - CR-20200514-14041 - checkUpdateJobTicketName - Removed dupeCheck logic & Modified naming convention to work with potential duplicates
    *		       :   V_1.5 - Modified By Victor Hanson - 06/11/2020 - CR-20200611-14176 - added updateProductionTracking
    *                  :   V_1.6 - Modified By Dipesh Gupta - 06/12/2020 - CR-20200612-14177 - JobTicket Name sections
    *		       :   V_1.7 - Modified By Victor Hanson - 06/18/2020 - CR-20200609-14157 - Updated checkUpdateJobTicketName to exclude CEEB Code from name if blank
    *		       :   V_1.8 - Modified By Abhinav Sharma - CR-20200709-14285 - Update box folder name
    *		       :   V_1.9 - Modified By Dipesh Gupta - CR-20200616-14191 - Approval Reminders
    *                  :   V_2.0 - Modified By Abhinav Sharma - 01/05/2021 - CR-20201105-14666 - Add automation when Drop # is updated on JT
    *		       :   V_2.1 - Modified By Abhinav Sharma - CR-20210510-15129 - Remove the "checkDuplicateJobTicketWithInstitutionProgramFY" method 
    *		       :   V_2.2 - Modified By Abhinav Sharma - 05/19/2021 - CR-20210518-15161 - Remove the method "approveJobTicketMTM"
    *		       :   V_2.3 - Modified By Mahendra Swarnakar - CR-20210325-15027 - 04/26/2021 - Added New method i.e. createPrintPTRecordsOnDropOnDemand
    *		       :   V_2.4 - Modified By Abhinav Sharma - 09/22/2021 - CR-20210913-15431 - Box folders not getting created and/or linked in some JTs
    *		       :   V_2.5 - Modified By Shalu Sharma - 09/24/2021 - CR-20210922-15453 - For on demand job tickets, generate auto-number for project ID
    *		       :   V_2.6 - Modified By Nikita Kumari - 10/01/2021 - CR-20210916-15441 - Modified method createFulfillmentRecords for postage class field update on PT records where Postage class field is blank
    *		       :   V_2.7 - Modified By Subhash Garhwal - 10/13/2021 - CR-20211012-15513 - Modified method changeReasonRequiredForLockedRecord - Added condition if project manager update # of drop in locked JT record.
    *		       :   V_2.8 - Modified By Shalu Sharma - 22/12/2021 - CR-20211213-15624 - Added new method "populatePTPrintQuantityContractedOnInventory"
    **/
public class JobTicketTriggerHelper
{
    
    //Variable that will Bypass the ChangeReasonCheck - Setting true from the AddJobComponentOnJobTicketController.
    public static boolean Bypass_changeReasonRequiredForLockedRecord = false;
    
    public static boolean  Bypass_createBoxFoldersForJobTicket = false;
    
    //Set boolean variable to prevent batch from running twice
    public static boolean firstRun = true;
    
    //06/11/2020 - CR-20200611-14176 - Victor Hanson - added
    public static final Id PRODUCTION_TRACKING_RT_ID_MAIL_SHOP = Schema.SObjectType.Production_Tracking__c.getRecordTypeInfosByName().get('Mail Shop').getRecordTypeId();
    
    public static boolean preventDuplicateCallouts = false;
    
    //Added By - Shalu Sharma - 22/12/2021 - CR-20211213-15624
    public static boolean sendEmailOnMailQuantityChange = false;
    
    /*This method will check if the Job ticket status is set to the "reviewed" 
    then call a batch job that will create the fulfillment records below Job tickets.*/
    //Modified - Nikita Kumari - 10/01/2021 - CR-20210916-15441 - Modified method createFulfillmentRecords for postage class field update on PT records where Postage class field is blank
    public static void createFulfillmentRecords(List<Job_Ticket__c> newJobTickets, Map<Id, Job_Ticket__c> mapOldJobTickets)
    {
        //Set to hold the Job ticket Ids. 
        Set<Id> setJobTicketIds = new Set<Id>();
        
        //set of production status 
        Set<String> setOfInvalidPtStatus = new Set<String>{'Ready for Print','Cancelled'};
            
            // Added By - Nikita Kumari - CR-20210916-15441 - 10/01/2021
            //map to hold job ticket Id with job ticket record 
            Map<Id, Job_Ticket__c> mapJTidWithJTrecords = new Map<Id, Job_Ticket__c>();
        
        //Loop on the new list. 
        for(Job_Ticket__c jobtkt : newJobTickets)
        {
            //Check for the change if the status is changed. 
            //Modified By - Abhinav Sharma - 01/05/2021 - CR-20201105-14666 - Add automation when Drop # is updated on JT 
            //Add condition Drop is updated and status is not equal to 'Draft' 
            if(jobtkt.Drop_Type__c != System.Label.DROP_TYPE_ON_DEMAND && mapOldJobTickets != null && mapOldJobTickets.get(jobtkt.Id).Status__c != jobtkt.Status__c 
               && jobtkt.Status__c == System.Label.Print_Production_Tracking_Creation_Status
               || (jobtkt.of_Drops__c != mapOldJobTickets.get(jobtkt.Id).of_Drops__c && jobtkt.Status__c != System.Label.Job_Ticket_Draft_Status))
            {
                //Set to hold the Job ticket Ids.
                setJobTicketIds.add(jobtkt.Id);
            }
            
            // Added By - Nikita Kumari - CR-20210916-15441 - 10/01/2021 - codition to check if postage class field is updated 
            if(mapOldJobTickets != null && jobtkt.Postage_Class__c != mapOldJobTickets.get(jobtkt.Id).Postage_Class__c)
                mapJTidWithJTrecords.put(jobtkt.Id, jobtkt);
        }
        
        if(setJobTicketIds.size() > 0 && firstRun == true)
        {
            //Calling a Batch job that will create the respective fulfillment records. 
            Batch_CreateFulfillmentTracking b = new Batch_CreateFulfillmentTracking(setJobTicketIds);
            Database.executeBatch(b, 25);
            
            //Set our variable accordingly
            firstRun = false;
        }
        
        // Added By - Nikita Kumari - CR-20210916-15441 - 10/01/2021
        // check if postage class updated on any JT 
        if(mapJTidWithJTrecords.values().size() > 0)
        {
            //Query PT records whose Postage class is null 
            List<Production_Tracking__c> pTrackings = [SELECT Id, Job_Ticket__c, Postage_Class__c FROM Production_Tracking__c WHERE Job_Ticket__c IN :mapJTidWithJTrecords.keySet() AND Postage_Class__c = null
                                                       AND RecordTypeId = :Constants.RECORD_TYPE_ID_PRODUCTION_TRACKING_MAIL_SHOP AND ((Status__c = 'Live Proof' AND Status_Detail__c != 'Live Proof Approved') OR Status__c NOT IN :setOfInvalidPtStatus)];
            
            if(pTrackings != null && pTrackings.size()>0)
            {
                for(Production_Tracking__c prodTracking : pTrackings)
                {
                    //sync postage class field value from JT to PT's 
                    prodTracking.Postage_Class__c = mapJTidWithJTrecords.get(prodTracking.Job_Ticket__c).Postage_Class__c;
                }
                
                update pTrackings;
            }
        }
    }
    
    /*This method will provide Validation on locked records - preventing users who do not have the Custom Permission from
    editing a Locked Record and requiring users who do have the Permission to enter a Change Reason for the record*/
    //Modified By - Subhash Garhwal - 10/13/2021 -CR-20211012-15513 - Modified method changeReasonRequiredForLockedRecord - Added condition if project manager update # of drop in locked JT record.
    
    public static void changeReasonRequiredForLockedRecord (List<Job_Ticket__c> newJobTickets, Map<Id, Job_Ticket__c> mapOldJobTickets) {
        
        //Check if we need to execute the method or not. 
        if(Bypass_changeReasonRequiredForLockedRecord)
            return;
        
        //VH 05/04/2020 - CR-20200221-13792 if oldmap is null, return
        if (mapOldJobTickets == null) return;
        
        //Loop through the records
        for(Job_Ticket__c jobtkt : newJobTickets){
            
            //VH 05/04/2020 - CR-20200221-13792 get set of fields that should be locked from changes
            Set<String> lockFields = Util.getFieldSetFieldsAPINames('Job_Ticket__c', 'Job_Ticket_Lock_Fields');
            //if any of the lock fields have been modified, 
            //move on to the next step of checking if modification is allowed
            boolean lockFieldModified = false;
            
            //Added By - Subhash Garhwal - 10/13/2021 -CR-20211012-15513 - variable assign to true if project manager modified other than allowed field values.
            boolean isProjManagerRestrictedFieldModified = false;
            
            //Added By - Subhash Garhwal - 10/13/2021 -CR-20211012-15513 - Set hold api names of fields whose value can be updated by Project manager in Locked JT record. 
            Set<String> JtFieldsAllowedToChangeForProjManager = new Set<String>();
            JtFieldsAllowedToChangeForProjManager.addAll(Label.JTLockedFieldsAllowedToChangeForProjManager.replaceAll('\\s','').split(','));
            
            
            for (String fld : lockFields) {
                
                if (jobtkt.get(fld) != mapOldJobTickets.get(jobtkt.Id).get(fld)) {
                    
                    lockFieldModified = true;
                    
                    
                    //Added condition to break the loop if project manager is not current logged in user 
                    if (jobtkt.Project_Manager__c != UserInfo.getUserId()){
                        break;  
                    }
                    
                    //Added By - Subhash Garhwal - 10/13/2021 -CR-20211012-15513  condition to check if project manager modified other than allowed field values.
                     if(jobtkt.Project_Manager__c == UserInfo.getUserId() && !JtFieldsAllowedToChangeForProjManager.contains(fld)){
                        isProjManagerRestrictedFieldModified = true;
                         break;
                    }
                    
                }
            }
            
            //Check to see if our Job Ticket was previously locked and is still locked && that it's not a Project Manager change from the PB
            if (lockFieldModified 
                && (mapOldJobTickets.get(jobtkt.Id).Locked__c == true 
                    && jobtkt.Locked__c == true) 
                && (mapOldJobTickets.get(jobtkt.Id).Status__c == jobtkt.Status__c) 
                && (mapOldJobTickets.get(jobtkt.Id).Project_Manager__c == jobtkt.Project_Manager__c)
               )
            {
                //Check to see if our user has the Bypass Locked Custom Permission
                boolean hasPermission = FeatureManagement.checkPermission('Unlock_Job_Tickets');
                
                //If the user doesn't have permission to Edit the locked record then present error
                if (hasPermission == false & jobtkt.Project_Manager__c != UserInfo.getUserId()){
                    
                    //Return Exception
                    throw new CustomException ('You do not have permission to edit a Locked Record');
                }
                
                //Added By - Subhash Garhwal - 10/13/2021 -CR-20211012-15513  condition to check if project manager modified other than allowed field values then show error.
                else if(isProjManagerRestrictedFieldModified && !hasPermission){
                    throw new CustomException (Label.JT_LockedFieldEditAccessIssueMsg);
                }
                
                //Otherwise check to see they have added a Change Reason
                else 
                {
                    //Check for change in field
                    if (mapOldJobTickets.get(jobtkt.Id).Change_Reason__c == jobtkt.Change_Reason__c)
                    {
                        //Return Exception
                        throw new CustomException ('If editing a Locked Record then you must enter a new Change Reason');
                    }
                }
            }
        }
    }
    
    /*This method is used to throw an error message, whenever a Job Ticket is moved approved by client and doesn't fulfillment certain ceiteria*/
    public static void validateJobTicketMTM(List<Job_Ticket__c> newJobTickets, Map<Id, Job_Ticket__c> mapOldJobTickets) 
    {
        Set<Id> setOfJobTicketIds = new Set<Id>();
        
        for(Job_Ticket__c jobTkt : newJobTickets) 
        {
            //Modified by Dipesh Gupta -- 4/22/2020  --- CR-20200415-13951 --- Change the status "Approved by Client" to "Approved by Partner"
            if(newJobTickets != null 
               && mapOldJobTickets != null 
               && jobTkt.Status__c != mapOldJobTickets.get(jobTkt.Id).Status__c 
               && jobTkt.Status__c == 'Approved by Partner') 
            {
                setOfJobTicketIds.add(jobTkt.Id);
            }
        }
        
        if(setOfJobTicketIds.size()>0)
        {
            
            //Set to hold the eligibleComponentTypes
            Set<String> setEligibleComponentTypes = new Set<String>();
            
            //We should not validate all the Job ticket Mtm, only those where the component type is mentioned in the Label.ComponentTypesNeedsValidationOnJobTicket
            String eligibleComponentTypes = Label.ComponentTypesNeedsValidationOnJobTicket; 
            
            //Check if the string contains , that means we have more than one components. 
            if(eligibleComponentTypes.contains(',')) {
                
                //For loop on the eligible component types. 
                for(String component : eligibleComponentTypes.split(','))
                    setEligibleComponentTypes.add(component.trim());
            }else {
                setEligibleComponentTypes.add(eligibleComponentTypes.trim());
            }
            
            if(setEligibleComponentTypes.size() > 0) {
                
                Boolean addError = false;
                for(Job_Ticket_MtM__c jobTktMTM : [Select Id, Job_Ticket__c,Paper_Typex__c,Paper_Weightx__c,Component_Code__c,Front_of_Colors__c,Front_Colors_PMS__c
                                                   From Job_Ticket_MtM__c 
                                                   Where Job_Ticket__c IN : setOfJobTicketIds AND Component_Type__c IN: setEligibleComponentTypes]
                   )
                {
                    if(String.isBlank(jobTktMTM.Paper_Typex__c)
                       || String.isBlank(jobTktMTM.Paper_Weightx__c)
                       || String.isBlank(jobTktMTM.Component_Code__c)
                       || (jobTktMTM.Front_of_Colors__c == null 
                           &&
                           String.isBlank(jobTktMTM.Front_Colors_PMS__c))
                      ) 
                    {
                        addError = true;
                        break;
                    }
                }
                if(addError == true) 
                {
                    //Modified by Dipesh Gupta -- 4/22/2020  --- CR-20200415-13951 --- Change the status "Approved by Client" to "Approved by Partner"
                    newJobTickets[0].addError('Before setting a Job Ticket status as Approved by Partner, associated components must have value for Paper Type, Paper Weight, Component Code and at least one color designated on the Front.');
                }    
            }
        }
    }
    
    // Add New method populateProjectManagerOnProductionTracking for CR-20200128-13670
    //This method will check if project manager exits on job ticket then populate the project manager on Production tracking
    public static void populateProjectManagerOnProductionTracking(List<Job_Ticket__c> newJobTicketList,Map<Id,Job_Ticket__c> oldMapJobTicket) {
        
        //Set to hold the Job ticket Ids
        Set<Id> jobTicketIdSet = new Set<Id>();
        //List to hold the updated production manager data
        List<Production_Tracking__c> prodTrackingToBeUpdate = new List<Production_Tracking__c>();
        
        //Loop on the new list
        for(Job_Ticket__c  jobTicket : newJobTicketList) {
            //Check for the change if the project manager is changed.  
            if(oldMapJobTicket != null && jobTicket.Project_Manager__c != oldMapJobTicket.get(jobTicket.Id).Project_Manager__c){
                //Set to hold the Job ticket Ids.
                jobTicketIdSet.add(jobTicket.Id); 
            }
        }
        
        //Loop to update the project manager on production Tracking
        if(jobTicketIdSet.size() > 0){
            //Query the production tracking record on the basis of job ticket
            //Modify By - Dipesh Gupta - CR-20200616-14191 - Approval Reminders(Job_Ticket__r.Project_Manager__r.ManagerId)
            for(Production_Tracking__c prodTracking : [Select ID,Job_Ticket__r.Project_Manager__r.ManagerId,Job_Ticket__c,Job_Ticket__r.Project_Manager__c,JT_Project_Manager__c From Production_Tracking__c Where Job_Ticket__c IN: jobTicketIdSet]){
                //Create the instance of production tracking 
                Production_Tracking__c productionTracking = new Production_Tracking__c();
                productionTracking.Id = prodTracking.Id;
                productionTracking.JT_Project_Manager__c = prodTracking.Job_Ticket__r.Project_Manager__c;
                //Modify By - Dipesh Gupta - CR-20200616-14191 - Approval Reminders
                productionTracking.JT_PM_Manager__c = prodTracking.Job_Ticket__r.Project_Manager__r.ManagerId;
                //List to hold the production tracking record.
                prodTrackingToBeUpdate.add(productionTracking);
            }
        }
        
        //DML to update the production tracking record
        if(prodTrackingToBeUpdate.size() > 0){
            try{
                
                Util.ByPassAllTriggers = true;
                update prodTrackingToBeUpdate;
                Util.ByPassAllTriggers = false;
                
            }
            catch(Exception ex){
                //Return Exception
                throw new CustomException(ex.getMessage());
            }
        }
    }
    
    //This Method is used to check if the Job ticket is meeting the criteria.
    public Static void createBoxFoldersForJobTicket(List<Job_Ticket__c> newJobTickets, Map<Id, Job_Ticket__c> mapOldJobTickets) {
        
        if(Bypass_createBoxFoldersForJobTicket)
            return;
        
        //Set to hold the Job Ticket Ids that will pass to a Future Method which will call a Enqueue Job.
        Set<Id> setOfBoxCheckEligibleJTRecords = new Set<Id>();
        
        for(Job_Ticket__c jT : newJobTickets) {
            //Modified By Abhinav Sharma - 09/22/2021 - CR-20210913-15431 - Box folders not getting created and/or linked in some JTs
            //Check status of Job Tickets.
            //Modified By - Abhinav Sharma - 01/05/2021 - CR-20201105-14666 - Add automation when Drop # is updated on JT
            if(jT.Status__c == Label.Job_Ticket_BoxFolderCreation_Status 
               /*jT.Status__c == Label.Job_Ticket_BoxFolderCreation_Status 
                && (mapOldJobTickets != null && mapOldJobTickets.get(jT.Id).Status__c != jT.Status__c)
                || (jT.of_Drops__c != mapOldJobTickets.get(jT.Id).of_Drops__c && jT.Status__c != System.Label.Job_Ticket_Draft_Status)*/
              ) {
                  
                  //Check if the BoxFolder name is exist?
                  
                  //Comment the blank check Box_Folder_Id__c
                  //if(String.isBlank(jT.Box_Folder_Id__c)) {
                  setOfBoxCheckEligibleJTRecords.add(jT.Id);
                  //}
              }
        }
        
        if(setOfBoxCheckEligibleJTRecords.size() > 0) {
            
            //Calling a another batch job that will run for Job Ticket records. 
            Batch_CreateBoxFolderForJT batchJobTicket = new Batch_CreateBoxFolderForJT(setOfBoxCheckEligibleJTRecords);
            Database.executeBatch(batchJobTicket, Integer.valueOf(Label.ProductionTracking_BoxBatchSize));
            
            Bypass_createBoxFoldersForJobTicket = true;
        }
    }
    
    //09/24/2021 - CR-20210922-15453 - Shalu Sharma - For on demand job tickets, generate auto-number for project ID
    //06/18/2020 - CR-20200609-14157 - Victor Hanson - Updated to exclude CEEB Code from name if blank
    //05/14/2020 - CR-20200514-14041 - Victor Hanson - Modified naming convention to work with potential duplicates
    //This Method is used to check if the same name job ticket exist. Added By Dipesh Gupta - CR-20200325-13887
    public Static void checkUpdateJobTicketName(List<Job_Ticket__c> newJobTickets, Map<Id, Job_Ticket__c> oldMapJobTickets) {
        
        Map<String, List<Job_Ticket__c>> mapNameToJT = new Map<String, List<Job_Ticket__c>>();
        //Added By - Shalu Sharma - 09/24/2021 - CR-20210922-15453 - to hold JT project Ids for On demand JT's
        List<Job_Ticket__c> jobTicketsProjIdToBeUpdated = new List<Job_Ticket__c>();
        
        if(newJobTickets.size() > 0) {
            
            //Modified By - Shalu Sharma - 09/24/2021 - CR-20210922-15453 - For on demand job tickets, generate auto-number for project ID
            for(Job_Ticket__c jobTicket : [Select Id, Name, School_Code__c, CEEB_Code__c, Project__c,
                                           Project__r.Fiscal_Year__c, Program__c, Job_Ticket_Name_Number__c,
                                           Program__r.Program_Acronym__c, Drop_Type__c, Project_Id_Auto_Number__c, Project_ID__c
                                           From Job_Ticket__c 
                                           Where ID IN: newJobTickets AND RecordType.Name = 'Job Ticket']) //Modified by Dipesh Gupta - 06/12/2020 - CR-20200612-14177 (AND RecordType.Name = 'Job Ticket')
            {
                Job_Ticket__c oldJT;
                //Added By - Shalu Sharma - 09/24/2021 - CR-20210922-15453 - For on demand job tickets, generate auto-number for project ID
                if(jobTicket.Drop_Type__c != null && jobTicket.Drop_Type__c == Constants.JOB_TICKET_ON_DEMAND_DROP_TYPE &&
                   (oldMapJobTickets == null ||(oldMapJobTickets != null 
                                                && (jobTicket.Drop_Type__c != oldMapJobTickets.get(jobTicket.Id).Drop_Type__c
                                                    || jobTicket.Project_ID__c != oldMapJobTickets.get(jobTicket.Id).Project_ID__c
                                                   )
                                               )
                   )
                  )
                {
                    jobTicket.Project_ID__c = jobTicket.Project_Id_Auto_Number__c;
                    jobTicketsProjIdToBeUpdated.add(jobTicket);
                }
                
                if (oldMapJobTickets != null) {
                    oldJT = oldMapJobTickets.get(jobTicket.Id);
                    //if any fields used to determine the name have been changed, reset Job Name Number to blank
                    if (oldJT != null && (jobTicket.Program__c != oldJT.Program__c || jobTicket.Project__c != oldJT.Project__c)) {
                        jobTicket.Job_Ticket_Name_Number__c = null;
                    }
                }
                //Modified By Abhinav Sharma - CR-20200212-13739
                if (oldMapJobTickets == null && (jobTicket.Program__c != null || jobTicket.Project__c != null)) {
                    jobTicket.Job_Ticket_Name_Number__c = null;
                }
                
                String jobName = '';                                  
                jobName = jobTicket.School_Code__c + '-';
                //06/18/2020 - CR-20200609-14157 - Victor Hanson - Updated to exclude CEEB Code from name if blank
                if (!String.isBlank(jobTicket.CEEB_Code__c)) 
                    jobName += jobTicket.CEEB_Code__c + '-';
                jobName += jobTicket.Project__r.Fiscal_Year__c +  '-' + jobTicket.Program__r.Program_Acronym__c;                          
                
                //Check if the string goes bigger then 77 characters then shorten it. 
                if(jobName.length() >= 77) {
                    jobName = jobName.substring(0, 77);                                   
                }
                jobTicket.Name = jobName;
                
                List<Job_Ticket__c> jts = mapNameToJT.get(jobName);
                if (jts == null) jts = new List<Job_Ticket__c>();
                jts.add(jobTicket);
                
                mapNameToJT.put(jobName, jts);                                
            }
            
            //Modified by Dipesh Gupta - 06/12/2020 - CR-20200612-14177 - JobTicket Name sections
            for(Job_Ticket__c jobTicket : [Select Id, Name, Template_Name__c, Job_Ticket_Name_Number__c
                                           From Job_Ticket__c 
                                           Where ID IN : newJobTickets AND RecordType.Name ='Job Ticket Template'
                                           AND Template_Name__c != null]) 
            {
                //List<Job_Ticket__c> jts = new List<Job_Ticket__c>();
                if(jobTicket.Template_Name__c.length() > = 77)
                    jobTicket.Name =  jobTicket.Template_Name__c;
                else
                    jobTicket.Name =  jobTicket.Template_Name__c;
                
                List<Job_Ticket__c> jts = mapNameToJT.get(jobTicket.Name);
                if (jts == null) jts = new List<Job_Ticket__c>();
                jts.add(jobTicket);
                
                //jts.add(jobTicket);
                mapNameToJT.put(jobTicket.Name, jts);
            }
            
            Map<String, Decimal> mapNameToJTMaxNumber = new Map<String, Decimal>();
            for (Job_Ticket__c jt : [Select Id, Name, School_Code__c, CEEB_Code__c, Project__c,
                                     Project__r.Fiscal_Year__c, Program__c, Job_Ticket_Name_Number__c,
                                     Program__r.Program_Acronym__c, Job_Ticket_Name_Formula__c
                                     From Job_Ticket__c 
                                     WHERE Job_Ticket_Name_Formula__c IN :mapNameToJT.keySet() 
                                     AND Id NOT IN :newJobTickets
                                     AND Job_Ticket_Name_Number__c != null
                                     ORDER BY Job_Ticket_Name_Number__c ASC]) 
            {
                mapNameToJTMaxNumber.put(jt.Job_Ticket_Name_Formula__c, jt.Job_Ticket_Name_Number__c);
            }
            
            Map<String, Job_Ticket__c> mapJobTicketsToUpdate = new Map<String, Job_Ticket__c>();
            
            //if any jts are still in the map without a job ticket name number, update it to 1
            for (List<Job_Ticket__c> jts : mapNameToJT.values()) {
                for (Job_Ticket__c jt : jts) {
                    //
                    if (jt.Job_Ticket_Name_Number__c == null) {
                        if (mapNameToJTMaxNumber.containsKey(jt.Name)) {
                            //max number + 1 so we dont have overlapping names + numbers
                            jt.Job_Ticket_Name_Number__c = mapNameToJTMaxNumber.get(jt.Name) + 1;
                        }
                        else {
                            jt.Job_Ticket_Name_Number__c = 1;
                        }
                    }
                    
                    //double check that we aren't updating multiple records at the same time with the same number
                    Decimal maxVal = mapNameToJTMaxNumber.get(jt.Name);
                    if (maxVal == null || (maxVal != null && jt.Job_Ticket_Name_Number__c > maxVal)) {
                        mapNameToJTMaxNumber.put(jt.Name, jt.Job_Ticket_Name_Number__c);
                    }
                    
                    //only add the dash number if greater than 1 (ie: AG12-1535-2020-ESYRS-2)
                    if (jt.Job_Ticket_Name_Number__c > 1)
                        jt.Name += '-' + jt.Job_Ticket_Name_Number__c;
                    
                    //add job ticket to map
                    mapJobTicketsToUpdate.put(jt.Name, jt);
                }
            }
            
            //Added By - Shalu Sharma - 09/24/2021 - CR-20210922-15453 - For on demand job tickets, generate auto-number for project ID
            if(mapJobTicketsToUpdate.size() > 0 ) {
                Util.BypassAllTriggers = true;
                update mapJobTicketsToUpdate.values();
                Util.BypassAllTriggers = false;   
            }
            
        }
        //Added By - Shalu Sharma - 09/24/2021 - CR-20210922-15453 - For on demand job tickets, generate auto-number for project ID
        if(jobTicketsProjIdToBeUpdated.size() > 0 ) {
            Util.BypassAllTriggers = true;
            update jobTicketsProjIdToBeUpdated;
            Util.BypassAllTriggers = false;   
        }
    }
    
    //Modified By Dipesh Gupta - CR-20200212-13739 - Added a new method - populateFiscalYearWithSubsPeriodYear
    //Populate Fiscal Year field on Job Ticket with SubscriptionPeriod.Year__c if there no value in Fiscal Year Field.
    public static void populateFiscalYearWithSubsPeriodYear(List<Job_Ticket__c> newJobTickets, Map<Id, Job_Ticket__c> mapOldJobTickets )
    {
        Set<Id> setOfJobTicketIds = new Set<Id>();
        
        for(Job_Ticket__c jTickt : newJobTickets)
        {
            if(mapOldJobTickets != null && String.isBlank(jTickt.Fiscal_Year__c) &&  jTickt.Fiscal_Year__c != mapOldJobTickets.get(jTickt.Id).Fiscal_Year__c && jTickt.Subscription_Period__c != null)
            {
                setOfJobTicketIds.add(jTickt.Subscription_Period__c);   
            }
        }
        
        if(setOfJobTicketIds.size() > 0)
        {
            Map<Id,Subscription_Period__c> mapOfSubscriptionPeriods = new Map<Id,Subscription_Period__c>([SELECT Id, Year__c 
                                                                                                          FROM Subscription_Period__c 
                                                                                                          WHERE Year__c != null 
                                                                                                          AND Id IN : setOfJobTicketIds
                                                                                                         ]);
            if(mapOfSubscriptionPeriods.size() > 0)
            {
                for(Job_Ticket__c jTickt : newJobTickets)
                {
                    if(mapOfSubscriptionPeriods.containsKey(jTickt.Subscription_Period__c))
                    {
                        jTickt.Fiscal_Year__c = mapOfSubscriptionPeriods.get(jTickt.Subscription_Period__c).Year__c;  
                    }
                }
            }
        }
    }
      
   /**
    *  Purpose         :   Updates production tracking to trigger field updates when certain fields change on Job Ticket
    *
    *  Revision Logs   :   V1.0 - 06/11/2020 - CR-20200611-14176 - Victor Hanson - created
    *                     
    **/
    public static void updateProductionTracking(List<Job_Ticket__c> newJobTickets, Map<Id, Job_Ticket__c> mapOldJobTickets)
    {
        //set of job tickets where mail vendor is updated
        Set<Id> setJobTickets = new Set<Id>();
        List<Production_Tracking__c> prodTrackingToUpdate = new List<Production_Tracking__c>();
        
        for (Job_Ticket__c jt : newJobTickets) {
            Job_Ticket__c oldJT;
            //get the old JT
            if (mapOldJobTickets != null)
                oldJT = mapOldJobTickets.get(jt.Id);
            
            //check if mail vendor has been updated
            if (oldJT != null && jt.Mail_Vendor__c != null && jt.Mail_Vendor__c != oldJT.Mail_Vendor__c) {
                //add production tracking to list of records to update
                setJobTickets.add(jt.Id);
            }
        }
        
        //mail vendor was updated, get all related production tracking records where assigned vendor is blank
        if (setJobTickets.size() > 0) {
            update [SELECT Id FROM Production_Tracking__c WHERE Job_Ticket__c IN :setJobTickets AND RecordTypeId = :PRODUCTION_TRACKING_RT_ID_MAIL_SHOP];
        }
    }
    
    
    /**
     *  Purpose         :   To Update Box Folder Name on Job Ticket
     *
     *  Revision Logs   :   V1.0 - Created - Abhinav Sharma - CR-20200709-14285 - Update box folder name 
     *                     
    **/
    public static void updateBoxFolderNameForJT(List<Job_Ticket__c> newJobTickets, Map<Id, Job_Ticket__c> mapOldJobTickets)
    {
        Set<Id> setOfJobTicketIds = new Set<Id>();
        
        for(Job_Ticket__c jT : newJobTickets) 
        {
            if(jT.Box_Folder_Id__c != null && (mapOldJobTickets != null && 
                                               (jT.Program__c != mapOldJobTickets.get(jT.Id).Program__c || jT.Project__c != mapOldJobTickets.get(jT.Id).Project__c))
              )
            {
                setOfJobTicketIds.add(jT.Id);    
            }
        }
        if(setOfJobTicketIds.size() > 0)
        {
            //Calling a another batch job that will run for Job Ticket records. 
            Batch_UpdateBoxFolderForJT batchJobTicket = new Batch_UpdateBoxFolderForJT(setOfJobTicketIds);
            Database.executeBatch(batchJobTicket, Integer.valueOf(Label.ProductionTracking_BoxBatchSize));
        }
    }    
    
    /**
    *  Purpose         :    Populate Subscription Period on Job Ticket as per - Issue--CR13739--QA--00010369 (Update Subscription Period on newly created record)
    *
    *  Revision Logs   :    V1.0 - Created - Abhinav Sharma - CR-20200212-13739 (Issue--CR13739--QA--00010369 - Update Subscription Period on newly created record)
    *                     
    **/
    
    public static void populateSubscriptionPeriodOnJobTicket(List<Job_Ticket__c> newJobTicketList,
                                                             Map<Id,Job_Ticket__c> oldMapJobTicket) 
    {
        Set<Id> setOfSubProgIds = new Set<Id>();
        Map<Id, List<Job_Ticket__c>> mapOfProjectIdWithNewJT = new Map<Id, List<Job_Ticket__c>>();
        
        for(Job_Ticket__c  jobTicket : newJobTicketList) 
        {
            //check project and sub-program is not blank on JT
            if(String.isNotBlank(jobTicket.Project__c) && jobTicket.Program__c != null &&
               (oldMapJobTicket == null || (oldMapJobTicket != null 
                                            && (jobTicket.Project__c != oldMapJobTicket.get(jobTicket.Id).Project__c
                                                || jobTicket.Program__c != oldMapJobTicket.get(jobTicket.Id).Program__c)
                                           )
               )
              )
            {
                setOfSubProgIds.add(jobTicket.Program__c);
                
                if(!mapOfProjectIdWithNewJT.containsKey(jobTicket.Project__c))
                    mapOfProjectIdWithNewJT.put(jobTicket.Project__c, new List<Job_Ticket__c>{jobTicket});
                else
                    mapOfProjectIdWithNewJT.get(jobTicket.Project__c).add(jobTicket);
            }
        }
        
        if(setOfSubProgIds.size() > 0 && mapOfProjectIdWithNewJT.size() > 0) {
            
            Map<String, Subscription_Period__c> mapOfSubscriptionPeriods = new Map<String, Subscription_Period__c>();
            
            for(Subscription_Period__c sp : [SELECT Id, Period_End_Date__c, Institution__c,
                                             Program_Subscription__r.SBQQ__RequiredByProduct__c,
                                             Program_Subscription__r.SBQQ__Product__c,
                                             Program_Subscription__r.SBQQ__ProductOption__r.Create_Job_Ticket__c
                                             FROM Subscription_Period__c 
                                             WHERE Program_Subscription__r.SBQQ__Product__r.Family =: System.Label.Enrollment_Services
                                             AND Program_Subscription__c != null
                                             AND Program_Subscription__r.SBQQ__Product__r.Disregard_for_Revenue_Automation__c != TRUE
                                             AND Stage__c != 'Pending'
                                             AND Contract__c != null
                                             AND Program_Subscription__r.SBQQ__ProductOption__r.Create_Job_Ticket__c = True
                                             AND Period_End_Date__c != null
                                             AND Program_Subscription__r.SBQQ__RequiredByProduct__c != null
                                             AND Program_Subscription__r.Program__c != null
                                             AND Program_Subscription__r.Program__c IN: setOfSubProgIds])
            {
                mapOfSubscriptionPeriods.put(sP.Institution__c + '-' + sP.Period_End_Date__c.year(), sp);
            }
            
            if(mapOfSubscriptionPeriods.size() > 0 && mapOfProjectIdWithNewJT.keySet().size() > 0) {
                
                for(Project__c proj : [SELECT Id, Fiscal_Year__c,Institution__c 
                                       FROM Project__c 
                                       WHERE Institution__c != null
                                       AND Fiscal_Year__c != null 
                                       AND Id IN : mapOfProjectIdWithNewJT.keySet()])
                {
                    if(mapOfProjectIdWithNewJT.containsKey(proj.Id)){
                        for(Job_Ticket__c jobTkt : mapOfProjectIdWithNewJT.get(proj.Id))
                        {
                            if(mapOfSubscriptionPeriods.containsKey(proj.Institution__c + '-' + proj.Fiscal_Year__c))
                                jobTkt.Subscription_Period__c = mapOfSubscriptionPeriods.get(proj.Institution__c + '-' + proj.Fiscal_Year__c).Id;
                            else
                                jobTkt.Subscription_Period__c = null;
                        }
                    }
                }
            }   
        }
    }
        
    /**
    *  Purpose         :    This method is used to used to populate Job Code on Job ticket
    *
    *  Revision Logs   :    V1.0 - Created - Abhinav Sharma - CR-20200212-13739 - (Issue--CR13739--QA--00010518)
    *                     
    **/
    public static void populateJobCodeWithSubsPeriodJobNo(List<Job_Ticket__c> newJobTickets, Map<Id, Job_Ticket__c> oldMapJobTicket )
    {
        Set<Id> setOfSubscriptionPeriodIds = new Set<Id>();
        
        for(Job_Ticket__c jTickt : newJobTickets)
        {
            if(jTickt.Subscription_Period__c != null && 
               (oldMapJobTicket == null ||(oldMapJobTicket != null 
                                           && jTickt.Subscription_Period__c != oldMapJobTicket.get(jTickt.Id).Subscription_Period__c)))
            {
                setOfSubscriptionPeriodIds.add(jTickt.Subscription_Period__c);
            }
            
        }
        
        if(setOfSubscriptionPeriodIds.size() > 0)
        {
            Map<Id,Subscription_Period__c> mapOfSubscriptionPeriods = new Map<Id,Subscription_Period__c>([SELECT Id, Job_No__c 
                                                                                                          FROM Subscription_Period__c 
                                                                                                          WHERE Job_No__c != null 
                                                                                                          AND Id IN : setOfSubscriptionPeriodIds
                                                                                                         ]);
            if(mapOfSubscriptionPeriods.size() > 0)
            {
                for(Job_Ticket__c jTickt : newJobTickets)
                {
                    if(mapOfSubscriptionPeriods.containsKey(jTickt.Subscription_Period__c))
                    {
                        jTickt.Job_Code__c = mapOfSubscriptionPeriods.get(jTickt.Subscription_Period__c).Job_No__c;  
                    }
                    else{
                        jTickt.Job_Code__c = null;  
                    }
                }
            }
        }
    }
    
    //Added By Mahendra Swarnakar - CR-20210325-15027 - 04/26/2021
    /*This method will check if the Job ticket status is set to the "Approved by Partner" And Drop Type == �On Demand�,  
	then call a batch job that will create the Only Print type PT records below Job tickets.*/
    public static void createPrintPTRecordsOnDropOnDemand(List<Job_Ticket__c> newJobTickets, Map<Id, Job_Ticket__c> mapOldJobTickets) {
        
        //Set to hold the Job ticket Ids. 
        Set<Id> setJobTicketIds = new Set<Id>();
        
        //Loop on the new list. 
        for(Job_Ticket__c jobtkt : newJobTickets) {
            
            //Check for the change if the status is changed. 
            if(mapOldJobTickets != null && mapOldJobTickets.get(jobtkt.Id).Status__c != jobtkt.Status__c 
               && jobtkt.Status__c == System.Label.Print_Production_Tracking_Creation_Status 
               && jobtkt.Drop_Type__c == System.Label.DROP_TYPE_ON_DEMAND
              ) {
                  //Set to hold the Job ticket Ids.
                  setJobTicketIds.add(jobtkt.Id);
              }
        }
        
        if(setJobTicketIds.size() > 0 && firstRun == true) {
            
            //Calling a Batch job that will create the respective fulfillment records. 
            Batch_CreateFulfilmentTrackingOnJTM b = new Batch_CreateFulfilmentTrackingOnJTM(setJobTicketIds);
            Database.executeBatch(b, 25);
            
            //Set our variable accordingly
            firstRun = false;
        }
    }
    
    //Added By - Shalu Sharma - 22/12/2021 - CR-20211213-15624 - Added new method "populatePTPrintQuantityContractedOnInventory"
    public static void populatePTPrintQuantityContractedOnInventory(List<Job_Ticket__c> newJobTickets, Map<Id, Job_Ticket__c> mapOldJobTickets)
    {
        Set<Id> setOfJobTicketIds = new Set<Id>();
        List<Inventory__c> listOfInventoryToUpdate = new List<Inventory__c>();
        
        for(Job_Ticket__c jobTicket : newJobTickets)
        {
            if(jobTicket.Mail_Quantity__c != null && jobTicket.Mail_Quantity__c > 0 
               && (mapOldJobTickets != null && mapOldJobTickets.get(jobTicket.Id).Mail_Quantity__c != jobTicket.Mail_Quantity__c))
            {
                setOfJobTicketIds.add(jobTicket.Id);
            }
        }
        if(setOfJobTicketIds.size() > 0)
        {
            Map<Id, Production_Tracking__c> mapOfProductionTrackings = new Map<Id, Production_Tracking__c>([SELECT Id, Print_Quantity_Contracted__c 
                                                                                                            FROM Production_Tracking__c 
                                                                                                            WHERE Job_Ticket__c IN : setOfJobTicketIds]);
            if(mapOfProductionTrackings.size() > 0)
            {
                Map<Id, Inventory__c> mapOfInventory = new Map<Id, Inventory__c>([SELECT Id, Production_Tracking__c,PT_Print_Quantity_Contracted__c 
                                                                                  FROM Inventory__c WHERE Production_Tracking__c IN : mapOfProductionTrackings.keySet()]);
                if(mapOfInventory.size() > 0)
                {
                    for(Inventory__c inv : mapOfInventory.values())
                    {
                        if(mapOfProductionTrackings.containsKey(inv.Production_Tracking__c)){
                            inv.PT_Print_Quantity_Contracted__c = mapOfProductionTrackings.get(inv.Production_Tracking__c).Print_Quantity_Contracted__c;   
                        	listOfInventoryToUpdate.add(inv);
                        }
                    }
                    if(listOfInventoryToUpdate.size() > 0)
                    {
                        sendEmailOnMailQuantityChange = true;
                        Util.BypassAllTriggers = true;
                        update listOfInventoryToUpdate;
                        Util.BypassAllTriggers = false;
                    }
                }
            }
        }
    }
}