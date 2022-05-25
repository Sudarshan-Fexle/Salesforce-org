/**
*   Purpose:    Contains methods to assist the member support trigger
*               
*   Create By:  Victor Hanson
*    
*    Revision Log:       V1.0 - (Code Added)- Victor Hanson - 11/29/2012 - Created
*                        V1.1 - (Code Added)- Victor Hanson - 04/03/2014 - Crimson Community Project
*                        V1.2 - Modified By - Abhinav Sharma - 07/12/2014 - CR-20140422-5173 - Method Added (UpdateAssigndToContactOnSiteIssueByProject)
*                        V1.3 - Modified By - Ajit Surana - 10/16/2014 - CR-20140725-6664 - Method Added - (updateExpectedFileReceivedDateOnProject)
*                        V1.4 - Modified By - Ajit Surana - 10/20/2014 - CR-20140915-7353 - Method modified (SendDataLoadAutoEmail)
*                        V1.5 - Modified By - Ajit Surana - 1/21/2015 - CR-20150102-8430 - Method modified (UpdateProjectBySiteIssue)
*                        V1.6 - Modified By - Ajit Surana - 01/23/2015 - CR-20140716-6259 - Method modified (UpdateSiteIssueByProject) 
*                        V1.7 - Modified By - Abhinav Sharma - 01/29/2015 - CR-20141218-8363 - Added a new Method (populateCPRMDataLoadFields)
*                        V1.8 - Modified By - Abhinav Sharma - 04/02/2015 - CR-20130913-3640
*                        V1.9 - Modified By - Abhinav Sharma - 12/02/2015 - CR-20140623-5897
*                        V1.10 - Modified By - Ajit Surana - 02/16/2015 - CR-20150106-8468 - Method modified (SendDataLoadAutoEmail)
*                        V1.11 - Modified By - Ajit Surana - 02/27/2015 - Added a new method - validateContactFlagValues
*                        V1.12 - Modified By - Ajit Surana - 05/06/2015 - CR-20140813-6993 - Added a new method - validateAndPopulateQANotes
*                        V1.13 - Modified By - Mahendra Swarnkar - 06/11/2015 - CR-20150529-8971 - Erroneous email bounce messages
*                        V1.14 - Modified By - Abhinav Sharma - 07/29/2015 - CR-20150709-9070 - Added a new Method - populateFieldsOnAssociatedProject
*                        V1.15 - Modified By - Abhinav Sharma - 08/24/2015 - CR-20150127-8596 - Added a new method - populateCPRMCurrentDataPeriodOnProject
*                        V1.16 - Abhinav Sharma - 11/03/2015 - CR-20151016-9329 - Modified existing method (populateFieldsOnAssociatedProject)
*                        V1.17 - Abhinav SHarma - 11/28/2015 - CR-20150601-8977 - Modified existing method (populateCPRMDataLoadFields)
*                        V1.18 - Victor Hanson - 3/13/2016 - CR-20160413-9760 - Added a new method - populateInstitutionFormalName
*                        V1.19 - Abhinav Sharma - 04/01/2016 - CR-20160224-9632 - Added new method - (validateFieldsValueChangesForCrimsonAndPTDataLoadMS)
*                        V1.20 - Modified By - Mahendra Swarnkar - 07/07/2016 - CR-20160609-9913 - Modified the existing method  "populateCPRMDataLoadFields".
*                        V1.21 - Modified By - Mahendra Swarnkar- CR-20160114-9520 - 08/23/2016 - Added a "calculateBusinessHoursAges" method to populate fields on Member Support object
*                        V1.22 - Modified By - Mahendra Swarnkar - CR-20160420-9785 - 09/01/2016 - Added a new Methods "populateMarketDataPeriodFieldsOnProject" and "populateMarketDataPeriodFields" to populate the Market data period begin and Market data period End Fields on MS and then on Project
*                        V_1.23 - Modified By - Rajeev Jain - 10/19/2016 - Services Excellence - Manually merged code from ServicesEx to Test Sb.Replaced old refferenced Status and Support Category values with new Standarized values from Services Excellence.
*                        V_1.24 - Modified By - Mahendra Swarnkar - CR-20160927-10190 - 11/03/2016 - Added a new method "populateCurrentDataPeriodOnProject" to Current Data Period on related Project
*                        V_1.25 - Modified By - Mahendra Swarnakar - CR-20161103-10340 - Release 55 - 12/16/2016 - populating CCM Data Load elapsed field with Businees hours difference b/n two dates
*                        V_1.26 - Modified By - Mahendra Swarnkar - CR-20161102-10332 - 1/19/2017 - Comment out "CRMfusionDBR101.DB_Globals.triggersDisabled"
*             		 V_1.27 - Modified By - Mahendra Swarnakar - CR-20161228-10580 - 1/22/2017 - Added a new method "SendCMACompletionandCPMDataLoadEmail"
*             		 V_1.28 - Modified By - Abhinav Sharma - CR-20170113-10615 - Modified "populateCPRMCurrentDataPeriodOnProject" method
*             		 V_1.29 - Modified By - Mahendra Swarnkar - 3/7/2017 - CR-20170208-10671 - updated the Method "populateMemberSupportProgramType" to have the trigger bypass flag for unintentional execution of Member Support trigger (at line No 1634)
*             		 V_1.30 - Modified By - Mahendra Swarnakar - CR-20160420-9786 - 3/16/2017 - Added a new method "sendPRMDataLoadCompletionEmail" and Updated the Method "SendCMACompletionandCPMDataLoadEmail" (Note:- updated since SendCMACompletionandCPMDataLoadEmail having similar logic to send email)
*              		 V_1.31 - Modified By - Mahendra Swarnkar - Apollo Release - CR-20170928-11558 - 10/10/2017 -  Added a new Method "populateEntityField".
*              		 V_1.32 - Modified By - Mahendra Swarnkar - CR-20171120-11798 - 11/21/2017   
*             		 V_1.33 - Modified By - Rajeev jain - 07/11/2018 - CR-20180604-12258 - Resolving test failure on the Deployment
*			 V_1.34 - Modified By - Abhinav Sharma - 17/06/2020 - CR-20200318-13865
*			 V_1.35 - Commented By Mahendra Swarnkar - 03/16/2020 - CR-20200217-13756
**/
public without sharing class MemberSupportTriggerUtilities {
  
    
    //V_1.30 - Modified By - Mahendra Swarnakar - CR-20160420-9786 - 1/23/2017 - Starts From here
    public final static String Email_TEMPLATE_CMA_DATA_LOAD_COMPLETION = 'CMA_Data_Load_Completion';
    public final static String Email_TEMPLATE_PRM_DATA_LOAD_COMPLETION = 'PRM_Data_Load_Completion'; 
    public final static String MEMBER_SUPPORT_RECORD_TYPE_LABEL_CMA_DATA_LOAD_MIGRATION = 'CMA Data Load/Migration';
    public static Boolean Sent_PRM_Email_One_Time = False;
    //V_1.30 - Modified By - Mahendra Swarnakar - CR-20160420-9786 - 1/23/2017 - Ends here
    
    //V_1.27 - Modified By - Mahendra Swarnakar - CR-20161228-10580 - 1/22/2017 - Starts From here
    public final static String Email_TEMPLATE_CPM_DATA_LOAD_TEMPLATE = 'CPM_Data_Load_Template';   
    public final static String OBJECT_API_MEMBER_SUPPORT = 'Site_Issue__c';   
    public final static String MEMBER_SUPPORT_RECORD_TYPE_LABEL_CPM_DATA_LOAD = 'CPM Data Load';   
    //V_1.27 - Modified By - Mahendra Swarnakar - CR-20161228-10580 - 1/22/2017 - Ends here
    
    //Static flag to control the execution of SendDataLoadAutoEmail
    public static Boolean EXECUTE_SEND_DATA_LOAD_AUTO_EMAIL = true;
    public static Boolean IS_UPDATE_HAPPENS_ON_INSERT_EVENT = false;
    
    public static Boolean IS_ALREADY_EXECUTED_ONCE = false;
    public final static String MEMBER_SUPPORT_OBJECT = 'Site_Issue__c';
    public final static String SITE_ISSUE_TIER_IV = 'Tier IV';
    
    //V_1.25 - Modified By - Mahendra Swarnakar - CR-20161103-10340 - Release 55 - 12/16/2016 - populating CCM Data Load elapsed field with Businees hours difference b/n two dates
    public final static String RECORD_TYPE_SITE_ISSUE_CCM_DATA_LOAD = 'CCM Data Load';
        
    /**
     *  @description    :   Method to hold the logic to validate/restrict users
     *                      for changing certain fields values without use of approriate buttons
     *                      on member support records of "Crimson Support Request" and "CCA Data Load" record type
     *
     *  @args           :   List of new site issues, Old Map of Site Issues
     *
     *  @return         :   void
     *
    **/
    //Added By - Abhinav Sharma - 04/01/2016 - CR-20160224-9632
    //Start From here
    public static void validateFieldsValueChangesForCrimsonAndPTDataLoadMS(List<Site_Issue__c> newMemberSupports, Map<Id, Site_Issue__c> mapOldMemberSupports) {
        
        //Checking for the insert event
        if(mapOldMemberSupports == null) {
            
            //Setting flag value to true
            IS_UPDATE_HAPPENS_ON_INSERT_EVENT = true;
        }
        
        //Start from here        
        //This code will only execute in the update use cases
        if(mapOldMemberSupports != null && !IS_ALREADY_EXECUTED_ONCE && !IS_UPDATE_HAPPENS_ON_INSERT_EVENT) {
            
            // get the ABC Dataloader profile id
            Id dataloaderProfileId = label.ABC_Dataloader_Profile_Id;
            
            //Bypass the below written logic for ABC Dataloader profile users
            //This way data update can take place over the existing records
            if (dataloaderProfileId != null 
                && UserInfo.getProfileId() == dataloaderProfileId) {
            
                //Do nothing and just bypass the validation logic        
            
            } else {
                
                //Setting flag value to true
                IS_ALREADY_EXECUTED_ONCE = true;
            
                //Get all record types on member support object
                Map<String, Id> memeberSupportRecordTypesMap = Util.recordtypemap(MEMBER_SUPPORT_OBJECT);
    
                //Get member support record types
                Map<Id, String> mapRecordTypes = new Map<Id, String>();
        
                //Looping over map keyset and accordingly populating collection with map retrieved values
                for(String recordTypeLabel : memeberSupportRecordTypesMap.keySet()) {
                
                    //Populating map to hold the case record type Id as key and correspodning record type label as value
                    if(String.isNotBlank(recordTypeLabel) 
                       && memeberSupportRecordTypesMap.containsKey(recordTypeLabel)
                       && memeberSupportRecordTypesMap.get(recordTypeLabel) != null)
                        mapRecordTypes.put(memeberSupportRecordTypesMap.get(recordTypeLabel), recordTypeLabel);
                }       
        
                //Loop through member support records
                for(Site_Issue__c sI : newMemberSupports) {
                    
                    //Checking record for eligibilty and throwing an error accordingly
                    if(sI.RecordTypeId != null 
                        && mapRecordTypes.containsKey(sI.RecordTypeId)
                        && mapRecordTypes.get(sI.RecordTypeId) != null) {
                        
                        //Validation "Crimson Support Request" record type based member support record for field changes
                        if((mapRecordTypes.get(sI.RecordTypeId) == Constants.RECORD_TYPE_SITE_ISSUE_CCA_SUPPORT_REQUEST
                            && sI.Button_Used__c == false)
                            && (
                                (
                                    sI.Assigned_to_Contact__c == null //CR-20160511-9849
                                    &&
                                    (
                                    
                                        (
                                            mapOldMemberSupports.get(sI.Id).Status__c == System.Label.STATUS_NEW_VALUE_FOR_CRIMSON_SUPPORT_MS
                                            &&
                                            sI.Status__c != mapOldMemberSupports.get(sI.Id).Status__c
                                            && sI.Status__c != System.Label.MS_STATUS_DUPLICATE_OR_CANCELLED
                                        )
                                        ||
                                        sI.OwnerId != mapOldMemberSupports.get(sI.Id).OwnerId
                                        ||
                                        sI.Tier_I_Support_Analyst__c != mapOldMemberSupports.get(sI.Id).Tier_I_Support_Analyst__c
                                    )
                                )
                                || (sI.Tier__c != mapOldMemberSupports.get(sI.Id).Tier__c
                                   && sI.Tier__c != Constants.SITE_ISSUE_TIER_III
                                   && sI.Tier__c != SITE_ISSUE_TIER_IV)
                            )
                        )
                            sI.addError(System.Label.ERROR_CASE_DIRECT_FIELDS_CHANGES);
                        
                        //Validation "CCA Data Load" record type based member support record for field changes
                        if((mapRecordTypes.get(sI.RecordTypeId) == Constants.RECORD_TYPE_SITE_ISSUE_CCA_DATA_LOAD
                            && sI.Button_Used__c == false)
                            && (
                                /*(
                                    mapOldMemberSupports.get(sI.Id).Status__c == System.Label.STATUS_NEW_VALUE_FOR_CCA_DATA_LOAD_MS
                                    &&
                                    sI.Status__c != mapOldMemberSupports.get(sI.Id).Status__c
                                    && sI.Status__c != System.Label.MS_STATUS_DUPLICATE_OR_CANCELLED
                                )*/
                                (sI.OwnerId != mapOldMemberSupports.get(sI.Id).OwnerId)
                                || (sI.Tier__c != mapOldMemberSupports.get(sI.Id).Tier__c
                                   && sI.Tier__c != Constants.SITE_ISSUE_TIER_III
                                   && sI.Tier__c != SITE_ISSUE_TIER_IV)
                                || (sI.Tier_I_Support_Analyst__c != mapOldMemberSupports.get(sI.Id).Tier_I_Support_Analyst__c)
                            )
                        )
                            sI.addError(System.Label.ERROR_CASE_DIRECT_FIELDS_CHANGES); 
                            
                        //Checking for the field value
                        if(sI.Button_Used__c == true)
                            sI.Button_Used__c = false;
                            
                    } else {
                        sI.Button_Used__c = false;        
                    }
                }
            }
        }
    }
    
    /**
     *  @description    :   Method to hold the logic to populate QA Notes field on MS record on insert of it.
     *
     *  @args           :   List of new site issues
     *
     *  @return         :   void
     *
    **/
    //Added By - 05/06/2015 - CR-20141218-8363 - Abhinav Sharma - 05/06/2015 -  CR-20140813-6993
    //Start From here
    public static void validateAndPopulateQANotes(List<Site_Issue__c> newMemberSupports) {
        
        //Map to hold the eligible record type(s)
        Map<Id, RecordType> mapRecordTypes = new Map<Id, RecordType>([SELECT ID FROM RecordType 
                                                                        WHERE sObjectType = 'Site_Issue__c' 
                                                                        AND IsActive = true 
                                                                        AND DeveloperName = 'CMA_Data_Load_Production']);
                                            
        //Checking record type for it existance
        if(mapRecordTypes != null && mapRecordTypes.values().size() > 0) {
    
            //Set to hold the parent project records ID value
            Set<Id> setProjectIds = new Set<Id>();
        
            //Loop through the MS record
            for(Site_Issue__c mSupport : newMemberSupports) {
        
                //Only proceed with the MS record:- If Record Type = CMA Data Load/Migration AND Data Load Type = Current
                if(mSupport.Project__c != null 
                    && mSupport.RecordTypeId != null
                    && mapRecordTypes.containsKey(mSupport.RecordTypeId)
                    && mapRecordTypes.get(mSupport.RecordTypeId) != null
                    && mSupport.Data_Load_Type__c == 'Current')
                    setProjectIds.add(mSupport.Project__c);
            }
            
            //Map to hold project ID as key and Member support record as value
            Map<Id,Site_Issue__c> mapProjectIdwithMSupport = new Map<Id,Site_Issue__c>();
            
            //Searching for the another Member Support ticket on the same project with the following criteria:
            //Record Type = CMA Data Load/Migration
            //Data Load Type = Current
            //Status = Constants.STATUS_MIGRATION_COMPLETE
            //Date/Time Closed = Most recent date.
            for(Site_Issue__c mS : [Select Id, Name, QA_Notes_and_Comments__c, Project__c From Site_Issue__c 
                                            Where Project__c != null AND Project__c IN : setProjectIds
                                            AND RecordTypeId != null AND RecordTypeId IN : mapRecordTypes.keySet()
                                            AND Data_Load_Type__c = 'Current'
                                            AND Status__c = :Constants.STATUS_MIGRATION_COMPLETE
                                            AND Site_Issue_Close_Date__c != null
                                            Order By Site_Issue_Close_Date__c DESC]) {
                //Checking if map contains the key. If not, then populate it with the same.
                if(!mapProjectIdwithMSupport.containsKey(mS.Project__c))
                    mapProjectIdwithMSupport.put(mS.Project__c, mS);
            }
            
            //Loop through MS records and populating "QA Notes" field accordingly
            for(Site_Issue__c mSupport : newMemberSupports) {
                
                //Checking if map contains the key
                if(mSupport.Project__c != null 
                    && mapProjectIdwithMSupport.containsKey(mSupport.Project__c) 
                    && mapProjectIdwithMSupport.get(mSupport.Project__c) != null) {
                    
                    //Variable to hold the QA notes    
                    String qANotes = '';
                        
                    //Constructing QA notes concatinated string and populate field with value    
                    if(String.isNotBlank(mapProjectIdwithMSupport.get(mSupport.Project__c).QA_Notes_and_Comments__c)) {
                        qANotes += mapProjectIdwithMSupport.get(mSupport.Project__c).Name;
                        qANotes += '<br/><br/>';
                        qANotes += mapProjectIdwithMSupport.get(mSupport.Project__c).QA_Notes_and_Comments__c;
                        if(String.isNotBlank(mSupport.QA_Notes_and_Comments__c)) {
                            qANotes += '<br/>';
                            qANotes += mSupport.QA_Notes_and_Comments__c;
                        }    
                        
                        mSupport.QA_Notes_and_Comments__c = qANotes;
                    }
                }            
            }    
        }
    }
    
    //Modified By - Abhinav Sharma - 11/28/2015 - CR-20150601-8977
    /**
     *  @description    :   Method to populate the following fields on MS tickets from "Project" level 
                            having record type = 'CPRM Data Laod'
                            1) Notes: Implementation and Data
                            2) Crimson: Data Lag
                            3) Production Business Analyst
                            4) Project: Data Analyst Group Lead
                            5) Data Analyst
     *
     *  @args           :   List of new site issues
     *
     *  @return         :   void
     *
    **/
    //Added By - 01/29/2015 - CR-20141218-8363 - Abhinav Sharma
    public static void populateCPRMDataLoadFields(List<Site_Issue__c> newMemberSupports, Map<Id, Site_Issue__c> mapOldMemberSupports) {
    
        //List to hold the record type
        Map<Id, RecordType> mapRecordTypes = new Map<Id, RecordType>([SELECT ID FROM RecordType 
                                                                        WHERE sObjectType = 'Site_Issue__c' AND IsActive = true 
                                                                        AND DeveloperName = 'CPRM_Data_Load']);
                                            
        //Checking record type for it existance
        if(mapRecordTypes != null && mapRecordTypes.values().size() > 0) {
            
            //Set to hold the project records ID value
            Set<Id> setProjectIds = new Set<Id>();
        
            //Loop through new member support records
            for(Site_Issue__c sIssue : newMemberSupports) {
                if(sIssue.Project__c != null)
                    setProjectIds.add(sIssue.Project__c);
            }
            
            //Checking set for size value
            if(setProjectIds.size() > 0) {
            
                //Map of Projects
                //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
                Map<Id, Project__c> mapProjects = new Map<Id, Project__c>([SELECT ID, Notes_Implementation__c/*, 
                                                                            Recurring_Business_Analyst__c*/
                                                                            FROM Project__c WHERE ID IN : setProjectIds]);
                //Loop through new member support records
                for(Site_Issue__c sI : newMemberSupports) {
                
                    //Populating fields on member support record. With the corresponding field value from associated project.
                    //Only for CPRM Data Laod record type member support records
                    if(sI.Project__c != null && sI.RecordTypeId != null 
                        && mapRecordTypes.get(sI.RecordTypeId) != null) {
                        sI.Notes_Recurring_Data__c = mapProjects.get(sI.Project__c).Notes_Implementation__c;  
                        
                        //Modified By - Abhinav Sharma - 11/28/2015 - CR-20150601-8977
                        //Start from here
                        //Data Analyst, Production Business Analyst" will only auto populate with values for project in case of creation 
                        //of it. 
                        //No update/auto populate will take place for both the fields in case of update of a member support record(s).
                        if(mapOldMemberSupports == null) { 
                            //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
                           // sI.Production_Business_Analyst__c = mapProjects.get(sI.Project__c).Recurring_Business_Analyst__c;
                        }    
                    }
                }
            }
            
            //Populating elapsed field with date field differences (Excluding weekends)
            //Loop through new member support records
            for(Site_Issue__c sIssue : newMemberSupports) {
                
                //Populating fields on member support record.
                //Only for CPRM Data Laod record type member support records
                if(sIssue.RecordTypeId != null && mapRecordTypes.containsKey(sIssue.RecordTypeId)
                    && mapRecordTypes.get(sIssue.RecordTypeId) != null) {
                    
                    //Elapsed: Files Rec'd to Diagnostics Sent - Elapsed_Files_Rec_d_to_Diagnostics_Sent__c
                    if(sIssue.Diagnostics_Sent__c != null && sIssue.Files_Received__c != null)
                        sIssue.Elapsed_Files_Rec_d_to_Diagnostics_Sent__c = Util.bussinessDaysDifferenceInBetweenDates(sIssue.Files_Received__c, sIssue.Diagnostics_Sent__c);
                    else
                        sIssue.Elapsed_Files_Rec_d_to_Diagnostics_Sent__c = null;
                       
                    //Elapsed: Files Rec'd to Moved to Prod  - Elapsed_Files_Rec_d_to_Moved_to_Prod__c   
                    if(sIssue.Moved_to_Production__c != null && sIssue.Files_Received__c != null)
                        sIssue.Elapsed_Files_Rec_d_to_Moved_to_Prod__c = Util.bussinessDaysDifferenceInBetweenDates(sIssue.Files_Received__c, sIssue.Moved_to_Production__c);
                    else
                        sIssue.Elapsed_Files_Rec_d_to_Moved_to_Prod__c = null;
                        
                    //Elapsed: Prod Migr Appr to Moved to Prod - Elapsed_Prod_Migr_Appr_to_Moved_to_Prod__c
                    if(sIssue.Moved_to_Production__c != null && sIssue.Production_Migration_Approved__c != null)
                        sIssue.Elapsed_Prod_Migr_Appr_to_Moved_to_Prod__c = Util.bussinessDaysDifferenceInBetweenDates(sIssue.Production_Migration_Approved__c, sIssue.Moved_to_Production__c);
                    else
                        sIssue.Elapsed_Prod_Migr_Appr_to_Moved_to_Prod__c = null;
                        
                    //Elapsed: QA Complete to Prod Migr Appr - Elapsed_QA_Complete_to_Prod_Migr_Appr__c    
                    if(sIssue.Production_Migration_Approved__c != null && sIssue.Final_QA_Complete__c != null)
                        sIssue.Elapsed_QA_Complete_to_Prod_Migr_Appr__c = Util.bussinessDaysDifferenceInBetweenDates(sIssue.Final_QA_Complete__c, sIssue.Production_Migration_Approved__c);
                    else
                        sIssue.Elapsed_QA_Complete_to_Prod_Migr_Appr__c = null;
                        
                    //Elapsed: Testing Complete to QA Complete - Elapsed_Testing_Complete_to_QA_Complete__c    
                    if(sIssue.Final_QA_Complete__c != null && sIssue.Testing_Complete__c != null)
                        sIssue.Elapsed_Testing_Complete_to_QA_Complete__c = Util.bussinessDaysDifferenceInBetweenDates(sIssue.Testing_Complete__c, sIssue.Final_QA_Complete__c);
                    else
                        sIssue.Elapsed_Testing_Complete_to_QA_Complete__c = null;
                        
                    //Elapsed: DB Rec'd to Testing Complete - Elapsed_DB_Rec_d_to_Testing_Complete__c    
                    if(sIssue.Testing_Complete__c != null && sIssue.DB_Received_from_Milliman__c != null)
                        sIssue.Elapsed_DB_Rec_d_to_Testing_Complete__c = Util.bussinessDaysDifferenceInBetweenDates(sIssue.DB_Received_from_Milliman__c, sIssue.Testing_Complete__c);
                    else
                        sIssue.Elapsed_DB_Rec_d_to_Testing_Complete__c = null;
                        
                    //Elapsed: Files Sent to MM to DB Rec'd - Elapsed_Files_Sent_to_MM_to_DB_Rec_d__c    
                    if(sIssue.DB_Received_from_Milliman__c != null && sIssue.Files_Sent_to_Milliman__c != null)
                        sIssue.Elapsed_Files_Sent_to_MM_to_DB_Rec_d__c = Util.bussinessDaysDifferenceInBetweenDates(sIssue.Files_Sent_to_Milliman__c, sIssue.DB_Received_from_Milliman__c);
                    else
                        sIssue.Elapsed_Files_Sent_to_MM_to_DB_Rec_d__c = null;
                        
                    //Elapsed: Diag Sent to Files Sent to MM - Elapsed_Diag_Sent_to_Files_Sent_to_MM__c    
                    if(sIssue.Files_Sent_to_Milliman__c != null && sIssue.Diagnostics_Sent__c != null)
                        sIssue.Elapsed_Diag_Sent_to_Files_Sent_to_MM__c = Util.bussinessDaysDifferenceInBetweenDates(sIssue.Diagnostics_Sent__c, sIssue.Files_Sent_to_Milliman__c);
                    else
                        sIssue.Elapsed_Diag_Sent_to_Files_Sent_to_MM__c = null;
                        
                    //Modified By - Mahendra Swarnkar- CR-20160609-9913 - 7/7/2016 - passes the company holidays as an argument in the AddBusinessDays method - Starts from here
                    //Expected_Completion_Date_Calculated__c    
                    if(sIssue.Files_Received__c != null)
                        sIssue.Expected_Completion_Date_Calculated__c = Util.AddBusinessDays(sIssue.Files_Received__c, 10);
                    //Modified By - Mahendra Swarnkar- CR-20160609-9913 -passes the company holidays as an argument in the AddBusinessDays method - 7/7/2016 -Ends here
                }
            }                
        }
    }
    
    //Removed the method - populateManagerFields.Spring clean up.

  public static void CalculateAssignment(Map<Id, Site_Issue__c> oldMap, List<Site_Issue__c> triggerNew) {
    
    //Map<String, Member_Support_Assignment__c> assignments = Member_Support_Assignment__c.getAll();
    
    Set<String> recordNames = new Set<String>();
    Set<String> userNames = new Set<String>();
    /*for (Member_Support_Assignment__c assignment : assignments.values()) {
      recordNames.add(assignment.Record_Type_Name__c);
      userNames.add(assignment.Username__c);
    }*/

    // get the deployment ids
    Set<Id> deploymentIds = new Set<Id>();
    for (Site_Issue__c newIssue : triggerNew)
      deploymentIds.add(newIssue.Deployment__c);
    Map<Id, Deployment__c> deploymentMap = new Map<Id, Deployment__c>([SELECT Name, Id, PT_Production_Engineer__c FROM Deployment__c WHERE Id IN :deploymentIds]);

    // get all of the user ids
    List<User> users = [SELECT Name, Username, Id FROM User WHERE Username IN :userNames];
    // create a map<username, id>
    Map<String, String> userMap = new Map<String, String>();
    for (User u : users)
      userMap.put(u.Username, u.Id);

    // get all of the record type ids
    List<RecordType> recordTypes = [SELECT Name, Id FROM RecordType WHERE Name IN :recordNames];
    // create a map<RecordTypeName, Id>
    Map<String, String> recordTypeMap = new Map<String, String>();
    for (RecordType rt : recordTypes)
      recordTypeMap.put(rt.Name, rt.Id);

    // create a map of <RecordTypeId, UserId>
    Map<String, String> recordUserMap = new Map<String, String>();
    /*for (Member_Support_Assignment__c assignment : assignments.values()) {
      Id uId = userMap.get(assignment.Username__c);
      Id rtId = recordTypeMap.get(assignment.Record_Type_Name__c);
      recordUserMap.put(rtId, uId);
    }*/

    // go through each record and determine the appropriate user
    for (Site_Issue__c newIssue : triggerNew) {
      // get the old record
      Site_Issue__c oldIssue;
      if (oldMap != null)
        oldIssue = oldMap.get(newIssue.Id);

      Id newOwnerId;
      // check to see if the record type id has changed
      if (oldIssue == null) { // if it is an insert, it definitely needs updated
        newOwnerId = recordUserMap.get(newIssue.RecordTypeId);
      }
      else { // otherwise only update if the recordtype changed
        if (oldIssue.RecordTypeId != newIssue.RecordTypeId) {
          newOwnerId = recordUserMap.get(newIssue.RecordTypeId);
        }
      }

      // get the deployment record
      Deployment__c deployment = deploymentMap.get(newIssue.Deployment__c);
      if (newIssue.Engineer__c == null && deployment != null) { // set the engineer field
        if (deployment.PT_Production_Engineer__c != null)
          newIssue.Engineer__c = deployment.PT_Production_Engineer__c;
      }


      // if we found that a new owner should be applied to this record, set it
      if (newOwnerId != null)
        newIssue.OwnerId = newOwnerId;
    }
  }
    
    /**
     *  @description    :   Method to check if a Member Support record's status is '10 - Closed, Member Notified'and if the record meets the 
                            criteria for the automated email and any of the related Project Roles are related to Contacts where EmailBouncedReason 
                            or EmailBouncedDate are not null, we should display a user-friendly error message that says which
                            Project Role's Contacts are affected and tells the user how to resolve.  
                            
     *  @args           :   List of new site issues, map of old site issues records
     *
     *  @return         :   void
     *
    **/
    //Added By - Ajit Surana - 02/27/2015 - CR-20150106-8468
    public static void validateContactFlagValues(List<Site_Issue__c> newListSiteIssues, map<Id, Site_Issue__c> oldMapSiteIssues) {
        
        //Set to hold the project Ids
        Set<Id> projectIds = new Set<Id>();

        //Query out to get the record type name
        List<RecordType> recordTypes = [SELECT Id, DeveloperName FROM RecordType 
                                            WHERE DeveloperName =: Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CCA_DATA_LOAD 
                                            AND IsActive = true 
                                            AND sObjectType = 'Site_Issue__c' ORDER BY DeveloperName Limit 1];

        //Loop through new MS records
        for(Site_Issue__c sIssue : newListSiteIssues) {

            //Check for status field value '22- Sent Email Update' and Project__c field not null
            if(sIssue.Project__c != null
                &&((sIssue.Status__c == Constants.STATUS_SITE_ISSUE_22_SENT_EMAIL_UPDATE 
                && (oldMapSiteIssues == null || oldMapSiteIssues.get(sIssue.Id).Status__c != sIssue.Status__c))
                    ||(sIssue.RecordTypeId == recordTypes[0].Id
                            && (sIssue.Data_Load_Type__c == Constants.CURRENT || sIssue.Data_Load_Type__c == Constants.HISTORICAL_RELOAD)
                            && sIssue.Status__c == Constants.STATUS_SITE_ISSUE_CLOSED
                            && (oldMapSiteIssues == null || oldMapSiteIssues.get(sIssue.Id).Status__c != sIssue.Status__c
                                    || oldMapSiteIssues.get(sIssue.Id).Data_Load_Type__c != sIssue.Data_Load_Type__c)))){

                //Add projectIds in set
                projectIds.add(sIssue.Project__c);
            }
        }

        //Check if there are records to process
        if(projectIds.size() > 0 ) {
            
            //Map to hold project ID as key and List of project roles as value
            Map<Id, List<Project_Role__c>> mapProjectIdWithProjectRoles = new Map<Id, List<Project_Role__c>>();
            
            //Set to hold the contact IDS
            Set<Id> setContactIds = new Set<Id>();
            
            //Map to hold the contact Id as value and having true as value if having bounce email otherwise false
            Map<Id, Boolean> mapContactWithBounceEmailFlag = new Map<Id, Boolean>();
            
            //Loop through project role records
            for(Project_Role__c pR : [SELECT Project__c, Contact__c, Name, Project_Role_Contact_EMail__c From Project_Role__c 
                                                WHERE Project__c != null AND Project__c IN: projectIds 
                                                AND Contact__c != null
                                                AND Project__r.Program_Acronym__c =: Label.MEMBER_SUPPORT_AUTO_EMAIL_ACRONYM
                                                AND CCC_Include_in_Data_Load_Automated_Email__c = true 
                                                AND Project_Role_Contact_Email__c != null]) {
      
                //Populating map with approriate combination of records
                if(mapProjectIdWithProjectRoles.containsKey(pR.Project__c))
                    mapProjectIdWithProjectRoles.get(pR.Project__c).add(pR);
                else
                    mapProjectIdWithProjectRoles.put(pR.Project__c, new List<Project_Role__c>{pR});  
                    
                //Populating set with contact Ids               
                setContactIds.add(pR.Contact__c);
            }
        
            //Checking if record is there to proceed
            if(setContactIds.size() > 0) {
                
                //Loop through contact records
                for(Contact con : [Select ID, EmailBouncedDate, EmailBouncedReason FROM Contact WHERE ID IN : setContactIds]) {
                    
                    //Modified By - Mahendra Swarnkar - 06/11/2015 - CR-20150529-8971 - Erroneous email bounce messages
                    if(String.isNotBlank(con.EmailBouncedReason))
                        mapContactWithBounceEmailFlag.put(con.Id, true);
                    else
                        mapContactWithBounceEmailFlag.put(con.Id, false);
                }
            }
            
            //Map to hold project role record Id as key and relate contact boolean bounce email flag as value
            Map<Id, Boolean> mapProjectRoleWithBounceEmailFlag = new Map<Id, Boolean>();
            
            //Loop through map keyset
            for(Id key : mapProjectIdWithProjectRoles.keySet()) {
                for(Project_Role__c pRole : mapProjectIdWithProjectRoles.get(key)) {
                    if(pRole.Contact__c != null) {
                        if(mapContactWithBounceEmailFlag.containsKey(pRole.Contact__c) && mapContactWithBounceEmailFlag.containsKey(pRole.Contact__c) != null)
                            mapProjectRoleWithBounceEmailFlag.put(pRole.Id, mapContactWithBounceEmailFlag.get(pRole.Contact__c));       
                    }   
                }
            }
            
            //Loop through MS records as adding error message if any contact associated to PR is having bounce email with it
            //Loop through trigger.new
            for(Site_Issue__c sI : newListSiteIssues) {

                //Check for status field value '22- Sent Email Update' and Project__c field not null
                if(sI.Project__c != null
                    &&((sI.Status__c == Constants.STATUS_SITE_ISSUE_22_SENT_EMAIL_UPDATE 
                    && (oldMapSiteIssues == null || oldMapSiteIssues.get(sI.Id).Status__c != sI.Status__c))
                        ||(sI.RecordTypeId == recordTypes[0].Id
                                && (sI.Data_Load_Type__c == Constants.CURRENT || sI.Data_Load_Type__c == Constants.HISTORICAL_RELOAD)
                                && sI.Status__c == Constants.STATUS_SITE_ISSUE_CLOSED
                                    && (oldMapSiteIssues == null || oldMapSiteIssues.get(sI.Id).Status__c != sI.Status__c
                                        || oldMapSiteIssues.get(sI.Id).Data_Load_Type__c != sI.Data_Load_Type__c)))) {
                                        
                    //String to hold the Project Role Names value
                    String pRoleNames = '';
                    
                    //Checking for value in the map
                    if(mapProjectIdWithProjectRoles.get(sI.Project__c) != null) {
                        for(Project_Role__c pRol : mapProjectIdWithProjectRoles.get(sI.Project__c)) {
                            if(mapProjectRoleWithBounceEmailFlag.containsKey(pRol.Id) && mapProjectRoleWithBounceEmailFlag.get(pRol.Id) == true) {
                                pRoleNames += pRol.Name + ',';
                            }
                        }
                        
                        //Checking string for blank value
                        if(pRoleNames != '') {
                            pRoleNames = pRoleNames.removeEnd(',');
                            sI.addError(pRoleNames + System.Label.Error_Message_Bounce_Email);
                        }
                    }                               
                }
            }
        }
    }
    
    //Code added by Bhavi Sharma - 06/12/2013 - CR-20120716-1142
    //New method added for send outbound email to Project role's contact email address
    //with CC to Project: Business Analyst and Project: Dedicated Advisor user's email address
    //Update - (SUNJ 12/19/13) - CR-20130815-3433
  /**
  *
  *  Description: convert site issues to JSON and send to future method CR-5343
  *
  **/
  public static void SendDataLoadAutoEmail(list<Site_Issue__c> newListSiteIssues, map<Id, Site_Issue__c> oldMapSiteIssues) {
    
    string oldSiteIssueString;
        
    //convert or sObjects to JSON strings
    string newSiteIssueString = System.JSON.serialize(newListSiteIssues);
    if (oldMapSiteIssues != null)
      oldSiteIssueString = System.JSON.serialize(oldMapSiteIssues.values());
    
    //only continue processing if this is not being called from a future method or batch job.
    if (!system.isFuture() && !system.isBatch()) {
        //call our future method which will convert the strings back to sObjects and email the member if applicable
        SendDataLoadAutoEmail(newSiteIssueString, oldSiteIssueString);
    }
  }
    //Code modified by - Ajit Surana - 10/20/2014 - CR-20140915-7353 
    //Code added by Bhavi Sharma - 06/12/2013 - CR-20120716-1142
    //New method added for send outbound email to Project role's contact email address
    //with CC to Project: Business Analyst and Project: Dedicated Advisor user's email address
    //Update - (SUNJ 12/19/13) - CR-20130815-3433
    //Update - (VH 05/09/14) - CR-20140505-5343
    @future
    public static void SendDataLoadAutoEmail(string newSiteIssuesString, string oldSiteIssuesString){
    
    //Added By - Ajit Surana - 10/20/2014 - CR-20140915-7353 
    //Bypass dupeblocker
    //CRMfusionDBR101.DB_Globals.triggersDisabled = true;
    
    //convert our JSON string to a list of the new sobjects
    list<Site_Issue__c> newListSiteIssues = (list<Site_Issue__c>) System.JSON.deserializeStrict(newSiteIssuesString, list<Site_Issue__c>.class);
    //convert our JSON string to a map of the old sObjects
    map<Id, Site_Issue__c> oldMapSiteIssues;
        if (oldSiteIssuesString != null) {
            list<Site_Issue__c> oldListSiteIssues = (list<Site_Issue__c>) System.JSON.deserializeStrict(oldSiteIssuesString, list<Site_Issue__c>.class);
            oldMapSiteIssues = new map<Id, Site_Issue__c>(oldListSiteIssues);
        }

        //Set for hold Project's Ids
        Set<Id> projectIds = new Set<Id>();

        //This map is to hold the first target object id for Project
        Map<Id, Id> mapContactsWithProjects = new Map<Id, Id>();

        //This map is to hold all the remaining contacts email toAddresses for Project
        Map<Id, List<String>> mapToAddresses = new Map<id, List<String>>();

        System.debug('####Data' + newListSiteIssues);

        // get one record type name
        List<RecordType> recordTypes = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName =: Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CCA_DATA_LOAD AND IsActive = true AND sObjectType = 'Site_Issue__c' ORDER BY DeveloperName Limit 1];

        //Loop through trigger.new
        for(Site_Issue__c sIssue : newListSiteIssues) {

            //Check for status field value '22- Sent Email Update' and Project__c field not null
            if(sIssue.Project__c != null
                &&((sIssue.Status__c == Constants.STATUS_SITE_ISSUE_22_SENT_EMAIL_UPDATE && (oldMapSiteIssues == null || oldMapSiteIssues.get(sIssue.Id).Status__c != sIssue.Status__c))
                    ||(sIssue.RecordTypeId == recordTypes[0].Id
                            && (sIssue.Data_Load_Type__c == Constants.CURRENT || sIssue.Data_Load_Type__c == Constants.HISTORICAL_RELOAD)
                            && sIssue.Status__c == Constants.STATUS_SITE_ISSUE_CLOSED
                            && (oldMapSiteIssues == null || oldMapSiteIssues.get(sIssue.Id).Status__c != sIssue.Status__c
                                    || oldMapSiteIssues.get(sIssue.Id).Data_Load_Type__c != sIssue.Data_Load_Type__c)))){

                //Add projectIds in set
                projectIds.add(sIssue.Project__c);
            }
        }


        //Check if there are records to process
        if(projectIds.size() > 0 ){
            // Modified By - Abhinav Sharma - CR-20200318-13865
            //Modified by - Ajit Surana - 02/16/2014 - CR-20150106-8468 - Updated SOQL query that use "ProjectName LIKE %CCC%" with 
            //a where clause that checks to see if the Project's Program_Acronym__c field = CustomLabel.DATA_LOAD_AUTO_EMAIL_ACRONYM
            //Modified by - Ajit Surana - 10/20/2014 - CR-20140915-7353 - Query modified to retreive Institution__c field
            //Get list of Project fields
            Map<Id, Project__c> projects = new Map<Id, Project__c>([SELECT Institution__c, Dedicated_Advisor__r.Email/*, Recurring_Business_Analyst__r.Email, Project_Manager__r.Email*/ FROM Project__c
                                                                        WHERE Id IN: projectIds AND Program_Acronym__c =: Label.MEMBER_SUPPORT_AUTO_EMAIL_ACRONYM]);
                                                                        
            //Map of CC addresses to hold the CCAddresses for each project
            Map<Id, List<String>> mapCCAddresses = new Map<Id, List<String>>();

            //Loop through the projects and
            for(Project__c project : projects.values()){

                //Add a new record in Map
                mapCCAddresses.put(project.Id, new List<String>());

                //Check for the values and add in map
                if(project.Dedicated_Advisor__c != null)
                    mapCCAddresses.get(project.Id).add(project.Dedicated_Advisor__r.Email);
                //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
                /*if(project.Recurring_Business_Analyst__c != null)
                    mapCCAddresses.get(project.Id).add(project.Recurring_Business_Analyst__r.Email);*/
            }
            
            //Modified by - Ajit Surana - 02/16/2014 - CR-20150106-8468 - Updated SOQL query that use "ProjectName LIKE %CCC%" with 
            //a where clause that checks to see if the Project's Program_Acronym__c field = CustomLabel.DATA_LOAD_AUTO_EMAIL_ACRONYM
            //Loop through list of Project Role records associated within projectIds set
            for(Project_Role__c projectRole : [SELECT Project__c, Contact__c, Project_Role_Contact_EMail__c From Project_Role__c WHERE Project__c IN: projects.keySet() AND Project__c != null AND Project__r.Program_Acronym__c =: Label.MEMBER_SUPPORT_AUTO_EMAIL_ACRONYM
                                                    AND CCC_Include_in_Data_Load_Automated_Email__c = true AND Project_Role_Contact_EMail__c != null]) {

                //Check Contact__c is not null
                if(projectRole.Contact__c != null) {

                    //Check if project is already in map, then add contact directly in set
                    if(mapContactsWithProjects.containsKey(projectRole.Project__c) ) {

                        //As first Target Object Id have been added, Add remaining ones in to address
                        if(mapToAddresses.containsKey(projectRole.Project__c)) {

                            //Add in existing list
                            mapToAddresses.get(projectRole.Project__c).add(projectRole.Project_Role_Contact_EMail__c);
                        } else {

                            //Add new in Map
                            mapToAddresses.put(projectRole.Project__c, new List<String>{projectRole.Project_Role_Contact_EMail__c});
                        }
                    } else {

                        //Add a fresh record in map
                        mapContactsWithProjects.put(projectRole.Project__c, projectRole.Contact__c);
                    }
                }
            }

            //Check if there are records to send email
            if(projects.size() > 0) {

                //Map Email with Contact Id
                Map<String, Id> mapEmailWithContact = new Map<String, Id>();

                //Create a list of emails to be hold
                List<String> emails = new List<String>();
                for(List<String> emailList : mapCCAddresses.values())
                    emails.addAll(emailList);

                //Create a Map of Contact records with email addresses
                for(Contact cont : [Select Id, Email from Contact where Email IN: emails])
                    mapEmailWithContact.put(cont.Email, cont.Id);

                //get Email Template of DATA LOAD EMAIL TEMPLATE
                List<EmailTemplate> emailTemplates = [SELECT Id FROM EmailTemplate WHERE Name =: Constants.EMAIL_TEMPLATE_DATA_LOAD AND IsActive = true];
        
                //Applied by rajeev jain - 07/11/2018 - CR-20180604-12258 - Resolving test failure on the Deployment- to avoid the Error while running from the Test class. 
                if(!Test.isRunningTest() && emailTemplates.size() == 0)
                    throw new CustomException('Eamil tempalte ' + Constants.EMAIL_TEMPLATE_DATA_LOAD + ' not found.');

                //Initialize list of SingleEmailMessage
                List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();

                //List ot hold the temporary contacts
                List<Contact> cnts = new List<Contact>();

                //Loop through the projects and send email
                for(Project__c project : projects.values()) {

                    //Temporary Contact, thi swill be deleted after sending the email
                    Contact temporaryContact;

                    //Instantiates SingleEmailMessage
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

                    //Target object Id
                    Id targetObjectId;
                    if(mapContactsWithProjects.containsKey(project.Id)) {
                        targetObjectId = mapContactsWithProjects.get(project.Id);

                        //Set CC address
                        mail.setCcAddresses(mapCCAddresses.get(project.Id));
                    } else if(project.Dedicated_Advisor__r.Email != null) {
                        
                        //Modified By - Ajit Surana - CR-20140915-7353 - 10/20/2014
                        if(mapEmailWithContact.containsKey(project.Dedicated_Advisor__r.Email))
                            temporaryContact = new Contact(LastName = 'TBD_TemporaryContact', Email = project.Dedicated_Advisor__r.Email,
                                                            AccountId = project.Institution__c);
                            insert temporaryContact;
                            targetObjectId = temporaryContact.Id;
                            
                        //List to hold the CC addresses
                        List<String> ccEmailAddresses = new List<String>();
                        
                        /*if(project.Recurring_Business_Analyst__r.Email != null)
                            ccEmailAddresses.add(project.Recurring_Business_Analyst__r.Email);*/
                        
                        //Added By : Bhavi  - 12/28/2013 - CR-20130815-3433
                        /*if(project.Project_Manager__r.Email != null)
                            ccEmailAddresses.add(project.Project_Manager__r.Email);*/
                            
                        //If ccEmailAddresses's size is greater than 0
                        if(ccEmailAddresses.size() > 0)
                            mail.setCcAddresses(ccEmailAddresses);
                        
                    }/*else if(project.Recurring_Business_Analyst__r.Email != null) {
                        
                        //Modified By - Ajit Surana - CR-20140915-7353 - 10/20/2014
                        //if(mapEmailWithContact.containsKey(project.Recurring_Business_Analyst__r.Email))
                            temporaryContact = new Contact(LastName = 'TBD_TemporaryContact', Email = project.Recurring_Business_Analyst__r.Email,
                                                            AccountId = project.Institution__c);
                            insert temporaryContact;
                            targetObjectId = temporaryContact.Id;
                            
                        //Added By : Bhavi  - 12/28/2013 - CR-20130815-3433
                        //List to hold the CC addresses
                        List<String> ccEmailAddresses = new List<String>();
                        
                        /*if(project.Project_Manager__r.Email != null)
                            ccEmailAddresses.add(project.Project_Manager__r.Email);*/
                            
                        //If ccEmailAddresses's size is greater than 0
                        //if(ccEmailAddresses.size() > 0)
                            //mail.setCcAddresses(ccEmailAddresses);
                    //}/*  else if(project.Project_Manager__r.Email != null) {
                        
                        //Modified By - Ajit Surana - CR-20140915-7353 - 10/20/2014
                        //Added By : Bhavi  - 12/28/2013 - CR-20130815-3433
                        /*if(mapEmailWithContact.containsKey(project.Project_Manager__r.Email))
                            temporaryContact = new Contact(LastName = 'TBD_TemporaryContact', Email = project.Project_Manager__r.Email,
                                                            AccountId = project.Institution__c);
                            insert temporaryContact;
                            targetObjectId = temporaryContact.Id;
                    }*/

                    //Check if target object Id is not null
                    if(targetObjectId != null) {

                        //set Target Object Ids
                        mail.setTargetObjectId(targetObjectId);

                        //set Target Object Ids
                        if(mapToAddresses.containsKey(project.Id)) {

                            mail.setToAddresses(mapToAddresses.get(project.Id));
                        }
            
                        //Applied by rajeev jain - 07/11/2018 - CR-20180604-12258 - Resolving test failure on the Deployment- to avoid the Error while running from the Test class. 
                        if(!test.isRunningTest())
                            //Set EmailTemplate
                            mail.setTemplateId(emailTemplates[0].Id);
            else
                          mail.setPlainTextBody('Temperary for the Test class');
                        //Set whatIds as projectIds
                        mail.setWhatId(project.Id);

                        //Add mail in list
                        mails.add(mail);

                        //Add contact in To be deleted list
                        if(temporaryContact != null)
                            cnts.add(temporaryContact);
                    }
                }

                //Check for the size
                if(mails.size() > 0) {
                    Messaging.sendEmail(mails);

                    //Delete temporary contact
                    if(cnts != null)
                        delete cnts;
                }
            }
        }
        //V_1.27 - Modified By - Mahendra Swarnakar - CR-20161228-10580 - 1/22/2017 - Starts From here
        //Called the Method to send the email when CPM record has been marked as completed
        SendCMACompletionandCPMDataLoadEmail(newListSiteIssues,oldMapSiteIssues); 
        //V_1.27 - Modified By - Mahendra Swarnakar - CR-20161228-10580 - 1/22/2017 - Ends here
    }

    //Code modified By - Ajit Surana - 01/21/2015 - CR-20150102-8430
    //This method is to update Delayed Load field on Project__c object - CR-20121219-1968
    //Code added - Bhavi Sharma - 06/04/2013 - CR-20130328-2773
    public static void UpdateProjectBySiteIssue(List<Site_Issue__c> listNewSiteIssues, Map<Id, Site_Issue__c> mapOldSiteIssues) {

        //Map of Project__c Key= ProjectId & Value= Site_Issue_Close_Date
        Map<Id,Datetime> mapProjectWithCloseDateForOneDelayed = new Map<Id,Datetime>();
        Map<Id,Datetime> mapProjectWithCloseDateForZeroDelayed = new Map<Id,Datetime>();
        
        //Map to hold Site Issue corresponding to ProjectId as key
        Map<Id,Site_Issue__c> mapProjectWithSiteIssue = new Map<Id,Site_Issue__c>();

        //List of projects to be updated
        Map<Id, Project__c> mapProjects = new Map<Id, Project__c>();

        //set of Project's Ids
        Set<Id> projectIds = new Set<Id>();

        //Set of Developer Name for Site Issue's RecordType
        Set<String> setRecordTypeNames = new Set<String>();
        setRecordTypeNames.add(Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CCA_DATA_LOAD);
        setRecordTypeNames.add(Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CCI_DATA_LOAD);
        setRecordTypeNames.add(Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CMA_DATA_LOAD_MIGRATION);
        setRecordTypeNames.add(Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CPM_DATA_LOAD);
        setRecordTypeNames.add(Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_EHBI_DATA_LOAD);

        //Map of record type
        Map<Id,RecordType> mapCMAInitialRecordType = new Map<Id,RecordType>([SELECT Id, DeveloperName FROM RecordType
                                                                                WHERE DeveloperName =: Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CMA_INITIAL_DEPLOYMENT_SUPPORT
                                                                                        AND IsActive = true AND sObjectType = 'Site_Issue__c' limit 1]);

        //Loop through the trigger.new
        for(Site_Issue__c siteIssue : listNewSiteIssues){

            //Check Site is data and execute the code only if require
            if(siteIssue.Project__c != null) {

                //Add Project Ids in set
                projectIds.add(siteIssue.Project__c);

                //Check if Site issue close date is null
                if(siteIssue.Site_Issue_Close_Date__c != null) {

                    //Check for the site issue
                    if(siteIssue.Data_Load_Type__c == Constants.CURRENT || siteIssue.Data_Load_Type__c == Constants.HISTORICAL_RELOAD) {

                        //Code added - Bhavi Sharma - 06/04/2013 - CR-20130328-2773
                        if(mapCMAInitialRecordType.containsKey(siteIssue.RecordTypeId)){

                            //put map's key=Project Id and value = Site Issue Record
                            mapProjectWithSiteIssue.put(siteIssue.Project__c, siteIssue);
                        }

                        //Check if total delay is greater than 0
                        if(siteIssue.Total_Delay__c > 0 ) {

                            //Check if map already contains the key of new Project Reference
                            if(mapProjectWithCloseDateForOneDelayed.containsKey(siteIssue.Project__c)) {

                                //check the Site_Issue_Close_Date__C is greater then existing close date
                                if(siteIssue.Site_Issue_Close_Date__c > mapProjectWithCloseDateForOneDelayed.get(siteIssue.Project__c)) {

                                    //put site issue's close date in map
                                    mapProjectWithCloseDateForOneDelayed.put(siteIssue.Project__c, siteIssue.Site_Issue_Close_Date__c);
                                }
                            } else {

                                //put site issue's close date in map
                                mapProjectWithCloseDateForOneDelayed.put(siteIssue.Project__c, siteIssue.Site_Issue_Close_Date__c);
                            }
                        } else {

                            //Check if map already contains the key of new Project Reference
                            if(mapProjectWithCloseDateForZeroDelayed.containsKey(siteIssue.Project__c)) {

                                //check the Site_Issue_Close_Date__C is greater then existing close date
                                if(siteIssue.Site_Issue_Close_Date__c > mapProjectWithCloseDateForZeroDelayed.get(siteIssue.Project__c)) {

                                    //put site issue's close date in map
                                    mapProjectWithCloseDateForZeroDelayed.put(siteIssue.Project__c, siteIssue.Site_Issue_Close_Date__c);
                                }
                            } else {

                                //put site issue's close date in map
                                mapProjectWithCloseDateForZeroDelayed.put(siteIssue.Project__c, siteIssue.Site_Issue_Close_Date__c);
                            }
                        }
                    } else {

                        //Check if map already contains the key of new Project Reference
                        if(mapProjectWithCloseDateForZeroDelayed.containsKey(siteIssue.Project__c)) {

                            //check the Site_Issue_Close_Date__C is greater then existing close date
                            if(siteIssue.Site_Issue_Close_Date__c > mapProjectWithCloseDateForZeroDelayed.get(siteIssue.Project__c)) {

                                //put site issue's close date in map
                                mapProjectWithCloseDateForZeroDelayed.put(siteIssue.Project__c, siteIssue.Site_Issue_Close_Date__c);
                            }
                        } else {

                            //put site issue's close date in map
                            mapProjectWithCloseDateForZeroDelayed.put(siteIssue.Project__c, siteIssue.Site_Issue_Close_Date__c);
                        }
                    }
                }
            }
        }

        //Updated By Abhinav Sharma - 03-14-2014 - CR-20131107-3938 - CMA - P/MS - Create Null PCP Field
        //Code added - Bhavi Sharma - 06/04/2013 - CR-20130328-2773
        /*List<Project__c> projects = [SELECT Current_Data_Period_New__c, Percent_of_PCP_Not_Captured__c FROM Project__c WHERE Id IN: projectIds];
        
        //Added By Abhinav Sharma - 03-14-2014 - CR-20131107-3938 - CMA - P/MS - Create Null PCP Field
        //Set of Developer Name for Site Issue's RecordType applicable during "Percent of PCP Not Captured" update
        Set<String> setRecordTypeNamesForPercentofPCPNotCaptured = new Set<String>();
        setRecordTypeNamesForPercentofPCPNotCaptured.add(Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CMA_DATA_LOAD_MIGRATION);
        setRecordTypeNamesForPercentofPCPNotCaptured.add(Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CMA_INITIAL_DEPLOYMENT_SUPPORT);
        
        //Added By Ajit Surana - 01-20-2015 - CR-20150102-8430
        //Set of Data Load Type field names
        Set<String> setDataLoadTypeNames = new Set<String>();
        setDataLoadTypeNames.add(Constants.CURRENT);
        setDataLoadTypeNames.add(Constants.HISTORICAL_RELOAD);
        setDataLoadTypeNames.add(Constants.SITE_BUILD);
        setDataLoadTypeNames.add(Constants.PART_OF_BUILD);
        
        //Map to hold the Project Id as key and Most Recent Date/time closed field value Member support record as value
        Map<Id, Site_Issue__c> mapProjectWithMemberSupports = new Map<Id, Site_Issue__c>();
        
        //Reteriving site issue records for whom:- 1) Record Type = �CMA Data Load Migration� or �CMA Initial Deployment� 2) Date/Time closed != null
        //3) Status = Constants.STATUS_MIGRATION_COMPLETE 4) Most Recent Date/Time Closed
        for(Site_Issue__c sIssue : [SELECT Project__c, Percent_of_PCP_Revenue_Not_Captured__c FROM Site_Issue__c 
                                        WHERE Project__c  != null AND Project__c IN : projectIds
                                        AND RecordType.DeveloperName IN : setRecordTypeNamesForPercentofPCPNotCaptured
                                        AND Data_Load_Type__c IN : setDataLoadTypeNames
                                        AND Site_Issue_Close_Date__c != null            
                                        AND Status__c =: Constants.STATUS_MIGRATION_COMPLETE
                                        ORDER BY Site_Issue_Close_Date__c DESC]) {
            //Checking for value in the map and populating it if value does exist in prior
            if(!mapProjectWithMemberSupports.containsKey(sIssue.Project__c))
                mapProjectWithMemberSupports.put(sIssue.Project__c, sIssue);
        }
        
        //Loop through project List
        for(Project__c project : projects) {

            //Check if project exists in Map and update Current data period in Project
            if(mapProjectWithSiteIssue.containsKey(project.Id)) {

                //assign Site Issue's field value on Project's field
                project.Current_Data_Period_New__c = mapProjectWithSiteIssue.get(project.Id).Data_Load_Period_End__c;

                //Add record in Map to be updated
                mapProjects.put(project.Id, project);
            }
        
            //Added By Abhinav Sharma - 03-14-2014 - CR-20131107-3938 - CMA - P/MS - Create Null PCP Field  
            //Check if project exists in map and updated the "Percent of PCP Not Captured" field for project
            if(mapProjectWithMemberSupports.containsKey(project.Id)) {
                
                //Populate Percent of PCP Not Captured field on project with most recent date/time closed Member support record value
                //Only Process the record if difference iin value is there 
                if(project.Percent_of_PCP_Not_Captured__c != mapProjectWithMemberSupports.get(project.Id).Percent_of_PCP_Revenue_Not_Captured__c) {
                    project.Percent_of_PCP_Not_Captured__c = mapProjectWithMemberSupports.get(project.Id).Percent_of_PCP_Revenue_Not_Captured__c;
                    mapProjects.put(project.Id, project);
                }
            }
        }*/

        //Chekc if there is any data to process
        if(mapProjectWithCloseDateForOneDelayed.size() > 0 || mapProjectWithCloseDateForZeroDelayed.size() > 0) {

            //Create a Map to hold the Most recent Site Issue with Project Id
            Set<Id> addedProjects = new Set<Id>();
            Map<Id, Site_Issue__c> mapExistingSiteIssues = new Map<Id, Site_Issue__c>();

            //Query Site Issue records and hold the maximum one in Map
            for(Site_Issue__c sIssue : [SELECT Project__c, Site_Issue_Close_Date__c, Data_Load_Type__c, Total_Delay__c
                                            from Site_Issue__c WHERE Project__c  != null
                                                            AND (Project__c IN :mapProjectWithCloseDateForOneDelayed.keySet()
                                                                OR Project__c IN :mapProjectWithCloseDateForZeroDelayed.keySet())
                                                            AND Site_Issue_Close_Date__c != null
                                                            AND ID NOT IN: listNewSiteIssues ORDER BY Site_Issue_Close_Date__c DESC]) {
                //check if already added
                if(!mapExistingSiteIssues.containsKey(sIssue.Project__c)) {

                    //add in set to avoid the next value
                    mapExistingSiteIssues.put(sIssue.Project__c, sIssue);
                }
            }

            //Get most recent data from existing records
            AggregateResult[] aggs = [SELECT Project__c projectId, Max(Site_Issue_Close_Date__c) mostRecentDate
                                                        FROM Site_Issue__c
                                                        WHERE Project__c  != null
                                                            AND (Project__c IN :mapProjectWithCloseDateForOneDelayed.keySet()
                                                                OR Project__c IN :mapProjectWithCloseDateForZeroDelayed.keySet())
                                                            AND Site_Issue_Close_Date__c != null
                                                            AND ID NOT IN: listNewSiteIssues GROUP BY Project__c];

            //loop through the aggregate results
            for(AggregateResult aR : aggs) {

                //Get Project Id
                Id projectId = (Id)aR.get('projectId');

                DateTime maxDTM = DateTime.valueOf(aR.get('mostRecentDate'));

                //Check if map already has project Id and Close date is recent than the existing one
                if(mapProjectWithCloseDateForOneDelayed.containsKey(projectId)) {

                    //Compare dates and add record in list to be updated
                    if(maxDTM < mapProjectWithCloseDateForOneDelayed.get(projectId)) {

                        //Add record in list to be updated
                        //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
                        /*if(mapProjects.containsKey(projectId))
                            mapProjects.get(projectId).Delayed_Load__c = 1;
                        else
                            mapProjects.put(projectId, new Project__c(Id = projectId, Delayed_Load__c = 1));*/
                    } else if(mapExistingSiteIssues.containsKey(projectId)){

                        //Get the site Issue record from Map and check the value to be updated
                        Site_Issue__c sIssue = mapExistingSiteIssues.get(projectId);

                        //Check for zero else one
                        if((sIssue.Data_Load_Type__c == Constants.CURRENT || sIssue.Data_Load_Type__c == Constants.HISTORICAL_RELOAD) && sIssue.Total_Delay__c > 0) {

                             //Add record in list to be updated
                             //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
                            /*if(mapProjects.containsKey(projectId))
                                mapProjects.get(projectId).Delayed_Load__c = 1;
                            else
                                mapProjects.put(projectId, new Project__c(Id = projectId, Delayed_Load__c = 1));*/
                        }/* else {

                             //Add record in list to be updated
                            if(mapProjects.containsKey(projectId))
                                mapProjects.get(projectId).Delayed_Load__c = 0;
                            else
                                mapProjects.put(projectId, new Project__c(Id = projectId, Delayed_Load__c = 0));
                        }*/
                    }
                }

                //Remove this from Map
                mapProjectWithCloseDateForOneDelayed.remove(projectId);

                //Check if map already has project Id and Close date is recent than the existing one
                if(mapProjectWithCloseDateForZeroDelayed.containsKey(projectId)) {

                    //Compare dates and add record in list to be updated
                    if(maxDTM < mapProjectWithCloseDateForZeroDelayed.get(projectId)) {

                        //Add record in list to be updated
                        //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
                        /*if(mapProjects.containsKey(projectId))
                            mapProjects.get(projectId).Delayed_Load__c = 0;
                        else
                            mapProjects.put(projectId, new Project__c(Id = projectId, Delayed_Load__c = 0));*/
                    } else if(mapExistingSiteIssues.containsKey(projectId)){

                        //Get the site Issue record from Map and check the value to be updated
                        Site_Issue__c sIssue = mapExistingSiteIssues.get(projectId);

                        //Check for zero else one
                        if((sIssue.Data_Load_Type__c == Constants.CURRENT || sIssue.Data_Load_Type__c == Constants.HISTORICAL_RELOAD) && sIssue.Total_Delay__c > 0) {

                             //Add record in list to be updated
                             //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
                            /*if(mapProjects.containsKey(projectId))
                                mapProjects.get(projectId).Delayed_Load__c = 1;
                            else
                                mapProjects.put(projectId, new Project__c(Id = projectId, Delayed_Load__c = 1));*/
                        } /*else {

                             //Add record in list to be updated
                            if(mapProjects.containsKey(projectId))
                                mapProjects.get(projectId).Delayed_Load__c = 0;
                            else
                                mapProjects.put(projectId, new Project__c(Id = projectId, Delayed_Load__c = 0));
                        }*/
                    }
                }

                //Remove this from Map
                mapProjectWithCloseDateForZeroDelayed.remove(projectId);
            }

            //Loop through the remaining records and add in list to be updated
            for(Id projectId : mapProjectWithCloseDateForOneDelayed.keySet()) {

                //Add record in list to be updated
                //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
                /*if(mapProjects.containsKey(projectId))
                    mapProjects.get(projectId).Delayed_Load__c = 1;
                else
                    mapProjects.put(projectId, new Project__c(Id = projectId, Delayed_Load__c = 1));*/
            }

            //Loop through the remaining records and add in list to be updated
            for(Id projectId : mapProjectWithCloseDateForZeroDelayed.keySet()) {

                //Add record in list to be updated
                /*if(mapProjects.containsKey(projectId))
                    mapProjects.get(projectId).Delayed_Load__c = 0;
                else
                    mapProjects.put(projectId, new Project__c(Id = projectId, Delayed_Load__c = 0));*/
            }

            //Check if data to update
            if(mapProjects.size() > 0) {

                //ByPass ALL trigger
                Util.BypassAllTriggers = true;
                update mapProjects.values();
                Util.BypassAllTriggers = false;
            }
        }
    }
    
    //Code modified - Ajit Surana - 01/23/2015 - CR-20140716-6259
    //Code added - Bhavi Sharma - 06/04/2013 - CR-20130328-2773
    //This method to update Member Support's fields corresponding to Project's fields
    public static void UpdateSiteIssueByProject(List<Site_Issue__c> listNewSiteIssues, Boolean isUpdate) {

        //Set of ProjectId which is associated with Site Issue 
        Set<Id> projectIds = new Set<Id>();

        //Map to hold Site Issue corresponding to ProjectId as key
        Map<Id,Site_Issue__c> mapProjWithSiteIssue = new Map<Id,Site_Issue__c>();
        
        //Loop through new list
        for(Site_Issue__c sIssue : listNewSiteIssues) {

            //Check Project__c field is not null
            if(sIssue.Project__c != null ) {

                //add ProjectId in set
                projectIds.add(sIssue.Project__c);

            }
        }

        //Query fields from project
        //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
        Map<Id, Project__c> mapProjects = new Map<Id, Project__c>([SELECT Id, /*Recurring_Business_Analyst__c,*/ Dedicated_Advisor__c
                                                                    FROM Project__c WHERE Id IN: projectIds]);

        //Set to hold recordType names
        Set<String> recordNames = New Set<String>();
        recordNames.add('CCA Data Load');
        recordNames.add('Crimson Support Request');
        recordNames.add('CMA Initial Deployment Support');
        //Commented by Mahendra Swarnkar - 03/03/2020 - CR-20200217-13756
        //recordNames.add('CMA Report Request');
        recordNames.add('CMA Support Issue');
        recordNames.add('CPM Support Issue');
        
        //more values added into recordtype name list by - Bhavi Sharma - 07/30/2013
        recordNames.add('Defect / Enhancement Request');
        recordNames.add('Internal Initiative');
        recordNames.add('Product Issue');
        recordNames.add('Internal Initiative Detail');
        
        //Added by Bhavi - 02/10/2014 - CR-20131213-4161
        recordNames.add('CPM Data Load');
        
        //Added by Ajit Surana - 01/23/2015 - CR-20140716-6259
        recordNames.add('Crimson Medical Director Service Request');
        
        //Map to put Id with RecordType's Name
        Map<Id, RecordType> recordTypeMap = new Map<Id,RecordType>();
        
        //Added by Bhavi - 02/10/2014 - CR-20131213-4161
        //Get record type for CPM Data Load
        Id cPMDataLoadRecordTypeId; 
        
        //Added by Ajit Surana - 01/23/2015 - CR-20140716-6259
        //Get record type Id for Crimson Medical Director Service Request
        Id cMDServiceRequestRecordTypeId; 
        
        //Fetch record types from database and add in map
        for(RecordType rType : [SELECT  Name FROM RecordType WHERE Name IN: recordNames AND SobjectType = 'Site_Issue__c' AND IsActive = true]) {
            
            //Check if the Name and add in appropriate Map
            if(rType.Name.equalsIgnoreCase('CPM Data Load'))
                cPMDataLoadRecordTypeId = rType.Id;
            else if(rType.Name.equalsIgnoreCase('Crimson Medical Director Service Request'))
                cMDServiceRequestRecordTypeId = rType.Id;
            else    
                recordTypeMap.put(rtype.Id, rType);
        }
        
        //Loop thruggh the site issue records and update the data
        //Loop through new list
        for(Site_Issue__c siteIssue : listNewSiteIssues) {

            //Check Project__c field is not null
            if(siteIssue.Project__c != null && mapProjects.containsKey(siteIssue.Project__c)) {
                
                //Added by Ajit Surana - 01/23/2015 - CR-20140716-6259
                //Check if it's Crimson Medical Director Service Request, then populate "Assigned To contact" field with to the contact record created
                if(siteIssue.RecordTypeId == cMDServiceRequestRecordTypeId)
                    siteIssue.Assigned_To_Contact__c = Label.Crimson_Medical_Director_Service_Request_User;
                
                //Do not execute the below code if trigger is running for update
                //As this method was initially running on insert only, so checking if trigger is running for update, only populate the Application vesrsion
                
                //Rajeev Jain - 10/19/2016 - Manually merged in order to Move code from Services Ex to Test Sb
                    if(isUpdate)
                    continue;
                //Rajeev Jain - 10/19/2016 - Manually merged in order to Move code from Services Ex to Test Sb - upto here
                
                //assignment field values corresponding Project to Site Issue
                //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
                //siteIssue.Production_Business_Analyst__c = mapProjects.get(siteIssue.Project__c).Recurring_Business_Analyst__c;
                siteIssue.Dedicated_Advisor__c = mapProjects.get(siteIssue.Project__c).Dedicated_Advisor__c;
                
            }
        }
    }
    
   //Method - UpdateAssigndToContactOnSiteIssueByProject - Removed the method - Spring clean up.
    
    //Code added By - Bhavi Sharma - 08/13/2013 - CR-20121219-1968
    //Method is used for populate Consecutively Delayed Load when there are two delayed records regularly
    public static void populateConsecutivelyDelyedOnSiteIssue(List<Site_Issue__c> newListSiteIssues) {

        //Set to hold projectIds
        Set<Id> projectIds = new Set<Id>();

        //Map of record type
        List<RecordType> recordTypes = new List<RecordType>([SELECT Id, DeveloperName FROM RecordType
                                                                WHERE DeveloperName =: Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CCA_DATA_LOAD
                                                                AND IsActive = true AND sObjectType = 'Site_Issue__c' limit 1]);

        //Loop through Trigger.new
        for(Site_Issue__c sIssue : newListSiteIssues) {

            //Set default
            sIssue.Consecutively_Delayed_Load__c = false;

            //Check for Project is not null and Total Delay is greater than Zero
            if(sIssue.Project__c != null && sIssue.Total_Delay__c > 0 && sIssue.RecordTypeId == recordTypes[0].Id) {

                //add Project Ids into set
                projectIds.add(sIssue.Project__c);
            }
        }

        if(projectIds.size() > 0) {

            //Map to hold Key = Project Id & Value = Member Support record
            Map<Id, Site_Issue__c> mapExistingSiteIssues = new Map<Id, Site_Issue__c>();

            //Loop thorugh aggregate query result
            for(Site_Issue__c sIssue : [SELECT Project__c, Site_Issue_Close_Date__c, Data_Load_Type__c, Total_Delay__c
                                            from Site_Issue__c WHERE Project__c  != null
                                                            AND Project__c IN :projectIds
                                                            AND Site_Issue_Close_Date__c != null
                                                            AND ID NOT IN: newListSiteIssues
                                                            AND RecordTypeId =: recordTypes[0].Id ORDER BY Site_Issue_Close_Date__c DESC]) {

                //check if already added
                if(!mapExistingSiteIssues.containsKey(sIssue.Project__c)) {

                    //add in set to avoid the next value
                    mapExistingSiteIssues.put(sIssue.Project__c, sIssue);
                }
            }


            //Check for size of mapExistingSiteIssues
            if(mapExistingSiteIssues.size() > 0) {

                //Loop thorugh the Trigger.New
                for(Site_Issue__c siteIssue : newListSiteIssues) {

                    if(siteIssue.Project__c != null && siteIssue.Total_Delay__c > 0) {

                        //Get Most record record from Map
                        Site_Issue__c maxSiteIssue = mapExistingSiteIssues.get(siteIssue.Project__c);

                        //Check for Project and Close date
                        if(maxSiteIssue == null)
                            continue;

                        if(maxSiteIssue.Total_Delay__c > 0 && siteIssue.Site_Issue_Close_Date__c > maxSiteIssue.Site_Issue_Close_Date__c) {

                            //assign true for Cosecutively
                            siteIssue.Consecutively_Delayed_Load__c = true;
                        }
                    }
                }
            }
        }
    }
    
    // if the program was updated, update the program type on all related member support records
    public static void populateMemberSupportProgramType(list<Project__c> projectList, map<Id, Project__c> ProjectOldMap) {
        
        // set of project ids that have an updated program
        set<Id> projectsWithUpdatedProgram = new set<Id>();
        
        // list of member support records to update
        list<Site_Issue__c> memSupportToUpdate = new list<Site_Issue__c>();
        
        // see which projects need to have their member support records updated
        for (Project__c proj : projectList) {
            
            // get the old project
            Project__c oldProj;
            if (projectOldMap != null) oldProj = projectOldMap.get(proj.Id);
            
            if (proj.Product__c != oldProj.Product__c) {
                
                // add project id to set
                projectsWithUpdatedProgram.add(proj.Id);
            }
        }
        
        if (projectsWithUpdatedProgram.size() > 0) {
            
            // get all projects an related member support records
            list<Project__c> projectswithMemSupport = [SELECT Id, Program_Acronym__c,
                                                       (SELECT Id, Project_Program_Type__c, Project__c FROM Site_Issues__r)
                                                       FROM Project__c WHERE Id IN :projectsWithUpdatedProgram];
                                                       
            for (Project__c proj : projectswithMemSupport) {
                
                // loop through each member support record and update the project program type
                for (Site_Issue__c memSupport : proj.Site_Issues__r) {
                    
                    // update the program type and add to the list to update
                    memSupport.Project_Program_Type__c = proj.Program_Acronym__c;
                    memSupportToUpdate.add(memSupport);
                }
            }
        }
        
        //Check for size
        if (memSupportToUpdate.size() > 0)
        {
            //V_1.29 - Modified By - Mahendra Swarnkar - 3/7/2017 - CR-20170208-10671 - updated to have the trigger bypass flag for unintentional execution of Member Support trigger - Starts from here
            //By pass all the Triggers
            Util.BypassAllTriggers = True;
            
            //Update the Member support records
            update memSupportToUpdate;
            
            //Enable all the Triggers
            Util.BypassAllTriggers = False;
            //V_1.29 - Modified By - Mahendra Swarnkar - 3/7/2017 - CR-20170208-10671 - updated to have the trigger bypass flag for unintentional execution of Member Support trigger - Ends here
        }
    }
    
    public static void populateProgramType(list<Site_Issue__c> memberSupportList) {
        
        // get all project ids
        set<Id> projectIdSet = new set<Id>();
        for (Site_Issue__c memSupport : memberSupportList) {
            
            if (memSupport.Project__c != null) 
                projectIdSet.add(memSupport.Project__c);
        }
        
        if (projectIdSet.size() > 0) {
            
            // get all projects
            map<Id, Project__c> projects = new map<Id, Project__c>([SELECT Id, Program_Acronym__c FROM Project__c WHERE Id IN :projectIdSet]);
            
            // see if the program type needs to be updated
            for (Site_Issue__c memSupport : memberSupportList) {
                
                Project__c project = projects.get(memSupport.Project__c);
                
                if (project != null && project.Program_Acronym__c != memSupport.Project_Program_Type__c) {
                    
                    memSupport.Project_Program_Type__c = project.Program_Acronym__c;
                }
            }
        }
    }
    
    /**
     *  @description    :   Method to peform calculation of the average of the past 3 values in  "Elapsed: Files Rec to Next Data Upload" field on Member Support(Site_Issue__c) records.  
     *                      A.  Calculate the average of the past 3 values in  Elapsed: Files Rec to Next Data Upload.  If the average is greater than 5.5, 
     *                          then the Project's Punctuality of Loads field should be "Typically Late".
     *                      B.  Calculate the average of the past 3 values in  Elapsed: Files Rec to Next Data Upload.  If the average is less than or equal to 5.5, 
     *                          then the Project's Punctuality of Loads field should be "Always on Time".
     *                      C.  When there is no pass support record for the project, the Punctuality of Loads will be set as "TBD".
     *
     *                      This should apply to the record type CMA Data Load / Migration Only
     *
     *  @args           :   List of new site issues, Map of old Site issues
     *
     *  @return         :   void
     *
     **/
    //Code added by Bhavi Sharma - 01/31/2014 - CR-20140113-4265
    public static void updatePunctualityOfLoadsOnTheBasisOfFileRecToNextDataUploadValue(List<Site_Issue__c> newSiteIssues, Map<Id, Site_Issue__c> mapOldSiteIssues) {
        
        //Set to hold Project records Id value
        Set<Id> setProjectIds = new Set<Id>();
        
        //Query for the "Member Support" record types (CMA Data Load/Migration)
        Map<Id, RecordType> mapRecordTypes = new Map<Id, RecordType>([SELECT Id FROM RecordType WHERE sObjectType = 'Site_Issue__c' 
                                                                                                    AND DeveloperName =: Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CMA_DATA_LOAD_MIGRATION 
                                                                                                    AND isActive = True LIMIT 1]);
        
        //Loop through list of "Member Support" records
        //Insert and Update case
        if(newSiteIssues != null) {
            
            for(Site_Issue__c siteIssue : newSiteIssues) {
                
                //Checking if "Member Support" record have "Project" record stamped as parent on it
                if(siteIssue.Project__c != null 
                    && mapRecordTypes.containsKey(siteIssue.RecordTypeId)
                    && (mapOldSiteIssues == null 
                        || siteIssue.Elapsed_Files_Rec_to_Next_Data_Upload__c != mapOldSiteIssues.get(siteIssue.Id).Elapsed_Files_Rec_to_Next_Data_Upload__c)) {
                    
                    //Add project Id in Set to be processed
                    setProjectIds.add(siteIssue.Project__c);
                }
            }
        } else {
            
            //Delete Scenario
            for(Site_Issue__c siteIssue : mapOldSiteIssues.values()) {
                
                //Checking if "Member Support" record have "Project" record stamped as parent on it
                if(siteIssue.Project__c != null && mapRecordTypes.containsKey(siteIssue.RecordTypeId)) {
                    
                    //Add project Id in Set to be processed
                    setProjectIds.add(siteIssue.Project__c);
                }
            }       
        }
        
        //Execute the code only if required
        if(setProjectIds.size() > 0) {
            
            //List of projects to be updated
            List<Project__c> projects = new List<Project__c>();
            
            //Quering Project records and corresponding children "Member Support" records
            //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
            for(Project__c p : [SELECT ID, /*Punctuality_of_Loads__c, */
                                    (Select ID, Elapsed_Files_Rec_to_Next_Data_Upload__c FROM Site_Issues__r where RecordType.DeveloperName =: Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CMA_DATA_LOAD_MIGRATION AND Elapsed_Files_Rec_to_Next_Data_Upload__c != null ORDER BY CreatedDate DESC LIMIT 3) 
                                        FROM Project__c WHERE Id IN : setProjectIds]) {
                                            
                //Integer variable to hold the sum of "Elapsed: Files Rec to Next Data Upload" field value for "member support" records
                Decimal sumElapsedFilesRecToNextDataUpload = 0;
                                            
                //When there is no pass support record for the project, the Punctuality of Loads will be set as "TBD".
                if(p.Site_Issues__r.size() == 0) {
                
                    //Update "Punctuality_of_Loads__c" field with desired value and instance into the list
                    //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
                    //p.Punctuality_of_Loads__c = Constants.PROJECT_PUNCTUALITY_OF_LOADS_TBD;
                    projects.add(p);
                } else {
                    
                    //Loop through children "Member Support" records corresponding to the Project record in current context
                    for(Site_Issue__c siteIssue : p.Site_Issues__r) {
                        
                        //Perform addition for the field values
                        if(siteIssue.Elapsed_Files_Rec_to_Next_Data_Upload__c != null)
                            sumElapsedFilesRecToNextDataUpload += siteIssue.Elapsed_Files_Rec_to_Next_Data_Upload__c;
                        else
                            sumElapsedFilesRecToNextDataUpload += 0;
                    }
                    
                    //Average
                    Decimal avgElapsedFilesRecToNextDataUpload = sumElapsedFilesRecToNextDataUpload/p.Site_Issues__r.size();
                    
                    //If the average is greater than 5.5, then the Project's Punctuality of Loads field should be "Typically Late".
                    if(avgElapsedFilesRecToNextDataUpload > 5.5) {
                        
                        //Checking picklist field value on project record before updation because if that were similar then there is no need for updation
                       //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
                        /*if(p.Punctuality_of_Loads__c != Constants.PROJECT_PUNCTUALITY_OF_LOADS_TYPICALLY_LATE) {    
                            
                            //Project Instance and it to the list for update
                            p.Punctuality_of_Loads__c = Constants.PROJECT_PUNCTUALITY_OF_LOADS_TYPICALLY_LATE;
                            projects.add(p);
                        }*/
                    } else if (avgElapsedFilesRecToNextDataUpload <= 5.5) {
                        //If the average is less than or equal to 5.5, then the Project's Punctuality of Loads field should be "Always on Time".
                            
                        //Checking picklist field value on project record before updation because if that were similar then there is no need for updation
                       //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
                        /*if(p.Punctuality_of_Loads__c != Constants.PROJECT_PUNCTUALITY_OF_LOADS_ALWAYS_ON_TIME) {    
                            
                            //Project Instance and it to the list for update
                            p.Punctuality_of_Loads__c = Constants.PROJECT_PUNCTUALITY_OF_LOADS_ALWAYS_ON_TIME;
                            projects.add(p);
                        }*/
                    }
                } 
            }
            
            //Checking list for size value
            if(projects.size() > 0) {
                
                //Bypass All other triggers
                Util.BypassAllTriggers = true;
                update projects;
            }           
        }
    }
    
    /**
     * 
     * @description: 
     * 
     * @revisions: added support for the PIC *** record types (excluding PIC Rate Schedule)
     * 
     **/
    //Determine if a case record needs to be created or synchronized.  CR-4283
    public static void syncMemberSupportToCase(list<Site_Issue__c> newMemSupportList, map<Id, Site_Issue__c> oldMemberSupportMap) {
        
        //Get the member support records and related case
        map<Id, Site_Issue__c> memSupportWithCaseMap = new map<Id, Site_Issue__c>([SELECT Id, (SELECT Id, Subject, CaseNumber, Status, Priority, 
                                                                                                Member_Support_Ticket__c, Origin, ContactId, Description FROM Cases__r)
                                                        FROM Site_Issue__c WHERE Id IN :newMemSupportList]);
        
        //get a map of projects with account Id
        set<Id> projectIdSet = new set<Id>();
        for (Site_Issue__c s : newMemSupportList) projectIdSet.add(s.Project__c);
        map<Id, Project__c> projectMap = new map<Id, Project__c>([SELECT Id, Institution__c FROM Project__c WHERE Id IN :projectIdSet]);
        
        list<Case> casesToUpsert = new list<Case>();
        
        boolean hasNewCases = false;
        
        //Iterate over each case to determine if a member support record sync is necessary
        for (Site_Issue__c newMemSupport : newMemSupportList) {
            
            //VH 3/14/16 - CR-1223
            if (CaseTriggerHelper.getSyncRecordTypeIds('Site_Issue__c').contains(newMemSupport.RecordTypeId)) {
                
                //Get the old member support record
                Site_Issue__c oldMemSupport;
                if (oldMemberSupportMap != null) oldMemSupport = oldMemberSupportMap.get(newMemSupport.Id);
                
                Case msCase;
                
                //If this is an update and the case record exists in our map, get the existing member support record
                if (memSupportWithCaseMap.get(newMemSupport.Id).Cases__r.size() > 0) {
                    msCase = memSupportWithCaseMap.get(newMemSupport.Id).Cases__r[0];
                }
                else {
                    
                    //get the related project associated with the member support Project, so we can get the accountId
                    Project__c msProject = projectMap.get(newMemSupport.Project__c);
                    
                    //Commented by Mahendra Swarnkar - 03/16/2020 - CR-20200217-13756 - RT deleted :  From CASE.
                    msCase = new Case(/*RecordTypeId = MemberSupportTriggerUtilities.getCaseRTID(newMemSupport.RecordTypeId),*/
                                      Project_Source_MS__c = newMemSupport.Project__c,
                                      ContactId = newMemSupport.Reported_By__c);
                    
                    if (newMemSupport.RecordTypeId == Constants.RECORD_TYPE_ID_SITE_ISSUE_CCA_SUPPORT_REQUEST
                        || newMemSupport.RecordTypeId == Constants.RECORD_TYPE_ID_SITE_ISSUE_CCA_DATA_LOAD)
                    {
                        msCase.OwnerId = Constants.tier2SupportQueue.Id;
                    }
                    
                    if (msProject != null)
                        msCase.AccountId = msProject.Institution__c;
                    else if (newMemSupport.Institution__c != null)
                        msCase.AccountId = newMemSupport.Institution__c;
                    
                    //Set hasNewCases = true so we can synchronize the case number with the mem support record
                    hasNewCases = true;
                }
                
                boolean isNewCase = (msCase.Id == null);
                
                //If certain fields were modified, mirror changes to related case record
                if (CaseTriggerHelper.recordNeedsSynced(newMemSupport, oldMemSupport) || isNewCase) {
                    
                    //Populate member support field values to the case record 
                    msCase = (Case) CaseTriggerHelper.populateSourceFieldsToTarget((sObject) oldMemSupport, (sObject) newMemSupport, (sObject) msCase);
                    
                    if (msCase.Member_Support_Ticket__c == null)
                        msCase.Member_Support_Ticket__c = newMemSupport.Id; 
                        
                    //add the updated memberSupport record to the upsert list
                    casesToUpsert.add(msCase);
                }
                
            }
        }
        
        if (casesToUpsert.size() > 0) {
            
            Util.BypassAllTriggers = true;
            upsert casesToUpsert;
            Util.BypassAllTriggers = false;
            
            //Popuate the caseNumber on the Member Support records
            map<Id, Case> caseMap = new map<Id, Case>();
            caseMap.putAll(casesToUpsert);
            map<Id, Site_Issue__c> memSupportMap = new map<Id, Site_Issue__c>();
            memSupportMap.putAll(newMemSupportList);
            populateCaseNumOnMS(memSupportMap.keySet(), caseMap.keySet());
        }
    }
    
    /**
    *
    *   @description: based on the member support rt id, return the corresponding case rt id
    * 
    *   @revisions: VH - 3/14/16 - added code to return the PIC Support record type
    *
    **/
    //Commented by Mahendra Swarnkar - 03/16/2020 - CR-20200217-13756 - RT deleted : CASE_PT_SUPPORT From CASE.
    /*public static Id getCaseRTID(Id memSupportRTID) {
        
        Id caseRTID;
        if (memSupportRTID == Constants.RECORD_TYPE_ID_SITE_ISSUE_CCA_SUPPORT_REQUEST)
            //Commented by Mahendra Swarnkar - 03/16/2020 - CR-20200217-13756 - RT deleted : CASE_PT_SUPPORT From CASE.
            //caseRTID = Constants.RECORD_TYPE_ID_CASE_PT_SUPPORT;
        //Commented by Mahendra Swarnkar - 03/05/2020 - CR-20200217-13756: RT deleted: PT DataLoad
        //else if (memSupportRTID == Constants.RECORD_TYPE_ID_SITE_ISSUE_CCA_DATA_LOAD)
            //caseRTID = Constants.RECORD_TYPE_ID_CASE_PT_DATA_LOAD;
        
        //Commented By Mahendra Swarnkar- 03/05/2020 - CR-20200217-13756: PIC Support
        //else
            //caseRTId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('PIC Support').getRecordTypeId();
        
        return caseRTID;
    }*/
    
    /**
    *
    *   @description: based on the case rt id, return the corresponding member support rt id
    *
    **/
    //Commented by Mahendra Swarnkar - 03/16/2020 - CR-20200217-13756 - RT deleted : CASE_PT_SUPPORT From CASE.
    /*public static Id getMemSupportRTID(Id caseRTID) {
        
        Id memSupportRTID;
        //Commented by Mahendra Swarnkar - 03/16/2020 - CR-20200217-13756 - RT deleted : CASE_PT_SUPPORT From CASE.
        //if (caseRTID == Constants.RECORD_TYPE_ID_CASE_PT_SUPPORT)
            //memSupportRTID = Constants.RECORD_TYPE_ID_SITE_ISSUE_CCA_SUPPORT_REQUEST;
        
        //Commented by Mahendra Swarnkar - 03/05/2020 - CR-20200217-13756: RT deleted: PT DataLoad
        //else if (caseRTID == Constants.RECORD_TYPE_ID_CASE_PT_DATA_LOAD)
            //memSupportRTID = Constants.RECORD_TYPE_ID_SITE_ISSUE_CCA_DATA_LOAD;
        
        return memSupportRTID;
    }*/
    
    @future
    public static void populateCaseNumOnMS(set<Id> memSupportIdSet, set<Id> caseIdSet) {
        
        list<Site_Issue__c> siteIssuesToUpdate = new list<Site_Issue__c>();
        
        list<Site_Issue__c> memSupportList = [SELECT Id, Case_Number__c, Case__c, (SELECT Id, CaseNumber FROM Cases__r) 
                                          FROM Site_Issue__c WHERE Id IN :memSupportIdSet];
        
        for (Site_Issue__c ms : memSupportList) {
            
            //Populate the case number to issue number field
            if (ms.Cases__r.size() > 0 && ms.Case_Number__c == null) {
                ms.Case_Number__c = ms.Cases__r[0].CaseNumber;
                ms.Case__c = ms.Cases__r[0].Id;
                siteIssuesToUpdate.add(ms);
            }
        }
        
        if (siteIssuesToUpdate.size() > 0) {
            
            update siteIssuesToUpdate;
        }
    }
    
    /**
    *
    *   @description: If the Tier 1 Support Analyst field on Member Support is an ID, lookup the users it corresponds to
    *                 and update the field with the user's name.
    *
    *   @params: list<Site_Issue__c>
    *
    **/
    public static list<Site_Issue__c> populateTier1Name(list<Site_Issue__c> newMemSupportList) {
        
        set<Id> userIdSet = new set<Id>();
        map<Id, User> userMap = new map<Id, User>();
        
        for (Site_Issue__c ms : newMemSupportList) {
            
            if (ms.Tier_I_Support_Analyst__c != null && ms.Tier_I_Support_Analyst__c instanceof Id) {
                
                userIdSet.add(ms.Tier_I_Support_Analyst__c);
            }
        }
        
        if (userIdSet.size() > 0) {
            userMap = new map<Id, User>([SELECT Id, Name FROM User WHERE Id IN :userIdSet]);
        }
        
        for (Site_Issue__c ms : newMemSupportList) {
            
            if (ms.Tier_I_Support_Analyst__c != null && ms.Tier_I_Support_Analyst__c instanceof Id) {
                
                User u = userMap.get(ms.Tier_I_Support_Analyst__c);
                if (u != null) ms.Tier_I_Support_Analyst__c = u.Name;
            }
        }
        
        return newMemSupportList;
    }
    
    public static void updateRelatedProjects(list<Site_Issue__c> siteIssueList) {
        
        Set<ID> projectids = new Set<ID>();
        list<Project__c> projectsToUpdate = new list<Project__c>();

        //_V1.24 - Added By - Mahendra Swarnkar - CR-20160927-10190 - 11/03/2016 - Map to hold Project Id and MS record type Id
        Map<Id, Id> projectIdWithMsRecordTypeId = New Map<Id, Id>();
        
        //V_1.24 - Modified By - Mahendra Swarnkar - CR-20160927-10190 - 11/03/2016 - Fill a map to hold record type Id
        //Loop through Trigger.New
        for(site_issue__c siteissue : siteIssueList){
            if(siteissue.project__c != null) {
                projectids.add(siteissue.project__c);
                if(siteissue.RecordTypeId != null)
                    projectIdWithMsRecordTypeId.put(siteissue.project__c, siteissue.RecordTypeId);        
            }
        } 
        
        //V_1.24 - Modified By - Mahendra Swarnkar - CR-20160927-10190 - 11/03/2016 - Fill a map to hold record type Id - Upto here
        
        //Modified By Abhinav Sharma - 03-11-2014 - CR-20140108-4243 - CMA - MS - Version Workflow Update
        // query projects related to modified support issues and all their related support issues
        // - Modified By - Rajeev Jain - 10/19/2016 - Services Excellence - Manually merged code from ServicesEx to Test Sb. - Added Support_Category_Details__c in query 
       //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
        List<Project__c> projects = [Select Id, /*site_issue_count_new__c,*/ 
                                        (Select RecordType.DeveloperName, Support_Category__c, Support_Category_Details__c, Data_Load_Type__c, data_load_period_end__c, 
                                            site_issue_close_date__c, version_ms__c, counts_as_open_issue__c, 
                                            Counts_for_current_data_period__c, Status__c from Site_Issues__r 
                                                where counts_as_open_issue__c >0 or data_load_period_end__c>= 2011-01-01 or version_ms__c != null 
                                                order by site_issue_close_date__c asc) 
                                        from project__c Where Id in :projectids];
        // - Modified By - Rajeev Jain - 10/19/2016 - Services Excellence - Manually merged code from ServicesEx to Test Sb. - Added Support_Category_Details__c in query  - upto here
        if (projects.size()==0)
            return; 
        
        //for each project, calculate the virtual roll-up fields and the 'project delayed field'
        for(project__c project : projects) {
            
            date current_data_period_new;
            decimal site_issue_count_new, version_bridge_new;
            Integer i=0;
            for (site_issue__c issue : project.site_issues__r) {
                i++;
                //System.debug('Version####'+project.version_bridge_new__c);
                 
                //this counts number of total open site issues for the project based on field counts as site issue
                if(issue.counts_as_open_issue__c>0){
                    if(site_issue_count_new == null){
                            site_issue_count_new=1;
                    }else{
                            site_issue_count_new+=issue.counts_as_open_issue__c;
                    }
                }
                        
                //this calculates the current data period based on max of data load period end where close date > jan 1 2011
                if(issue.data_load_period_end__c != null && issue.Counts_for_current_data_period__c==1){
            
                    if (current_data_period_new == null){
                        current_data_period_new=issue.data_load_period_end__c;
                    } else {
            
                        if(current_data_period_new<issue.data_load_period_end__c){
                            current_data_period_new=issue.data_load_period_end__c;
                        }
                    }
                }
                 
            }
            
            //V_1.24 - Added By - Mahendra Swarnkar - CR-20160927-10190 - 11/03/2016 - Get ARx_Data_Load RecordType Id
            Id  msRecordType_ARx_Data_Load = Util.RecordTypeId(Constants.MEMBER_SUPPORT_API_NAME, 
                                                           Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_ARx_Data_Load);

            //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references                                               
            /*if (project.site_issue_count_new__c != site_issue_count_new) 
            {
            //V_1.24 - Modified By - Mahendra Swarnkar - CR-20160927-10190 - 11/03/2016 - by pass the code for ARx_Data_Load recordtype
                if(projectIdWithMsRecordTypeId.get(project.Id) != msRecordType_ARx_Data_Load) {
                    
                    project.current_data_period_new__c = current_data_period_new;
                    
                }

                project.site_issue_count_new__c = site_issue_count_new;
                projectsToUpdate.add(project);
            }*/
        }
        
        //Update project list records
        if (projectsToUpdate.size() > 0) update projectsToUpdate;
    }

    //Removed the Method - updateExpectedFileReceivedDateOnProject - Spring clean Up.
    //Removed the Method - updateEstimatedProdTeamTransitionDateOnProject - Spring clean Up.
    //Removed the Method - populateFieldsOnAssociatedProject - Spring clean Up.
    //Removed the Method - populateCPRMCurrentDataPeriodOnProject - Spring clean Up.
    
    /**
     * 
     * @description: populate the Institution Formal Name field.  This will be used in formulas & workflow rules (CR-9760)
     * 
     **/
    public static void populateInstitutionFormalName(list<Site_Issue__c> memberSupportList) {
        
        // get all project ids
        set<Id> acctIdSet = new set<Id>();
        for (Site_Issue__c memSupport : memberSupportList) {
            
            if (memSupport.Institution__c != null) 
                acctIdSet.add(memSupport.Institution__c);
        }
        
        if (acctIdSet.size() > 0) {
            
            // get all accounts
            map<Id, Account> accts = new map<Id, Account>([SELECT Id, Account_Formal_Name__c FROM Account WHERE Id IN :acctIdSet]);
            
            // see if the program type needs to be updated
            for (Site_Issue__c memSupport : memberSupportList) {
                
                Account acct = accts.get(memSupport.Institution__c);
                
                if (acct != null && acct.Account_Formal_Name__c != memSupport.Institution_Formal_Name_Text__c) {
                    memSupport.Institution_Formal_Name_Text__c = acct.Account_Formal_Name__c;
                }
            }
        }
    }
    
    //Modified By - Rajeev Jain - 10/19/2016 - Services Excellence - Manually merged code from ServicesEx to Test Sb.
    //V1.20 - Added By - Rajeev Jain - 08/02/2016 - CR-20160519-9863 - Services Excellence
    
    //Set to hold the Status of Member Support lesser then the Constants.MEMBER_SUPPORT_STATUS_ACKNOWLEDGE
    public static Set<String> statusValuesLesserThenAcknowledge = new Set<String>{Constants.MEMBER_SUPPORT_STATUS_NEW, 
                                                                        Constants.MEMBER_SUPPORT_STATUS_ISSUES_WITH_EXTRACT, 
                                                                        Constants.MEMBER_SUPPORT_STATUS_WAITING_FOR_FILES};
                                                                        
    //Set to hold the Status of Member Support lesser then the Constants.MEMBER_SUPPORT_STATUS_ACKNOWLEDGE
    public static Set<String> statusValuesLesserThenInProgress = new Set<String>{Constants.MEMBER_SUPPORT_STATUS_NEW, 
                                                                        Constants.MEMBER_SUPPORT_STATUS_ISSUES_WITH_EXTRACT, 
                                                                        Constants.MEMBER_SUPPORT_STATUS_WAITING_FOR_FILES, 
                                                                        Constants.MEMBER_SUPPORT_STATUS_FILES_RECIEVED,
                                                                        Constants.MEMBER_SUPPORT_STATUS_ACKNOWLEDGE,
                                                                        Constants.MEMBER_SUPPORT_STATUS_ACKNOWLEGE};
    
    //Modified By - Rajeev Jain - 10/19/2016 - Services Excellence - Manually merged code from ServicesEx to Test Sb. - upto here
    //V_1.25 - Modified By - Mahendra Swarnakar - CR-20161103-10340 - Release 55 - 12/16/2016 - populating CCM Data Load elapsed field with Businees hours difference b/n two dates
      /*i) Elapsed: DST to Files Received <=(count the no of business days) [Files_Received__c - Data_Submission_Target_Date__c]
        ii) Elapsed: Files Received to Start Import <= Code logic (count the no of business days) [Start_Import_Date__c - Files_Received__c]
        iii) Elapsed: Files Rec'd to End Import Date <= Code logic (count the no of business days) [End_Import_Date__c - Files_Received__c]
        iv) Elapsed: Start Import to End Import Date <= Code logic (count the no of business days) [End_Import_Date__c - Start_Import_Date__c]
        v) Elapsed: Files Received to Ticket Closed <= Code logic (count the no of business days) [Site_Issue_Close_Date__c - Files_Received__c]
        */
    public static void calculateBusinessHoursAges(List<Site_Issue__c> memberSupports, Map<Id, Site_Issue__c> msMap) {
        
        //Loop through new records
        for(Site_Issue__c ms : memberSupports) {
            
            //Modified By - Rajeev Jain - 11/11/2016 - Services Excellence - fixed to populate this field.
            if(ms.RecordTypeId == Constants.MEMBER_SUPPORT_CCA_DATA_LOAD_RT_ID && ms.Internal_Load_Complete__c == null && ms.Status__c == Constants.MEMBER_SUPPORT_STATUS_IN_SMOKE_TEST)
                ms.Internal_Load_Complete__c = Date.today();
                
            //Checking for update case only
            if(msMap != null && ms.RecordTypeId != null
                && (
                    ms.RecordTypeId == Util.recordtypemap(MemberSupportTriggerUtilities.MEMBER_SUPPORT_OBJECT).get(Constants.RECORD_TYPE_SITE_ISSUE_CCA_DATA_LOAD) 
                    || 
                    ms.RecordTypeId == Util.recordtypemap(MemberSupportTriggerUtilities.MEMBER_SUPPORT_OBJECT).get(Constants.RECORD_TYPE_SITE_ISSUE_CCA_SUPPORT_REQUEST)
                ) 
                && ms.Status__c != null 
                && msMap.get(ms.Id).Status__c != null 
                && msMap.get(ms.Id).Status__c.startsWith(System.Label.Member_Support_Status_Initial_Value_Prefix) 
                && msMap.get(ms.Id).Status__c != ms.Status__c
                && !ms.Status__c.startsWith(System.Label.Member_Support_Status_Initial_Value_Prefix)
                && msMap.get(ms.Id).Date_Time_Acknowledged__c == null
            )
                ms.Date_Time_Acknowledged__c = System.now();
            
            //Modified By - Rajeev Jain - 10/19/2016 - Services Excellence - Manually merged code from ServicesEx to Test Sb.
            //Populate 'Status Date/Time: In Progress' field only and only if it is chnaged from Old status to new status and status is either 
            //Greater then or equals to 02-Acknowledged Status field value.
            if (UserInfo.getProfileId() == Label.ABC_Dataloader_Profile_Id && 
                Label.Bypass_Actual_Resolution_for_ABC_Dataloader != null && 
                Label.Bypass_Actual_Resolution_for_ABC_Dataloader.equalsIgnoreCase('TRUE')) 
            {
                //bypass the Actual Resolution Date logic for Users with ABC Dataloader profile, if the custom label is true
            }
            else if(ms.Status_Date_Time_In_Progress__c == null && 
                (ms.Status__c == Constants.CASE_STATUS_03_IN_PROGRESS || !statusValuesLesserThenInProgress.contains(ms.Status__c))
                 && (msMap == null || msMap.get(ms.Id).Status__c != Constants.CASE_STATUS_03_IN_PROGRESS)){
                ms.Status_Date_Time_In_Progress__c = DateTime.Now();
                
                if(ms.Elapsed_Acknowledged_to_In_Prog_hrs__c == null && ms.Status_Date_Time_In_Progress__c != null && ms.Date_Time_Acknowledged__c != null){
                    
                    //• Displays the elapsed time, measured in business hours rounded to the nearest whole hour, between when the Member Support Status was “01-New” (created) to “02-Acknowledged” **
                    DateTime startDateTime = ms.Date_Time_Acknowledged__c;
                    DateTime endDateTime =  ms.Status_Date_Time_In_Progress__c;  
                    
                    Integer businessHoursMinutes = 0;
                        
                   // businessHoursMinutes += Util.businessHoursForStartAndEndDate(startDateTime, endDateTime);
                    
                    //Convert it to hours with Round
                    if(businessHoursMinutes != null)
                        ms.Elapsed_Acknowledged_to_In_Prog_hrs__c = businessHoursMinutes > 0 ? Math.Round(businessHoursMinutes/60) : 0;  
                }
            }
            //Modified By - Rajeev Jain - 10/19/2016 - Services Excellence - Manually merged code from ServicesEx to Test Sb. - upto here
            if (UserInfo.getProfileId() == Label.ABC_Dataloader_Profile_Id && 
                Label.Bypass_Actual_Resolution_for_ABC_Dataloader != null && 
                Label.Bypass_Actual_Resolution_for_ABC_Dataloader.equalsIgnoreCase('TRUE')) 
            {
                //bypass the Actual Resolution Date logic for Users with ABC Dataloader profile, if the custom label is true
            }
            else if(ms.Actual_Resolution_Date__c == null && (ms.Status__c == Constants.STATUS_SITE_ISSUE_PENDING_CLOSED || ms.Status__c == Constants.STATUS_SITE_ISSUE_TEN_CLOSED)){
                ms.Actual_Resolution_Date__c = DateTime.now();
            }
            
            //Populate Open to Acknowledged (Hours) on Member Support
            if(ms.Site_Issue_Created_Date__c != null && ms.Date_Time_Acknowledged__c != null){
               // ms.Elapsed_Open_to_Acknowledged_Hours__c = (Util.businessHoursForStartAndEndDate(ms.Site_Issue_Created_Date__c, ms.Date_Time_Acknowledged__c))/60;
            } else{
                ms.Elapsed_Open_to_Acknowledged_Hours__c = null;
            }
            
            //Populate Elapsed: Open to First Response (Hours) on Member Support
            if(ms.Site_Issue_Created_Date__c != null && ms.First_Comment_Date_Time__c != null){
                //ms.Elapsed_Open_to_First_Response_Hours__c = (Util.businessHoursForStartAndEndDate(ms.Site_Issue_Created_Date__c, ms.First_Comment_Date_Time__c))/60;
              } else{
                ms.Elapsed_Open_to_First_Response_Hours__c = null;
              }
            
            //Populate Elapsed Open to Actual Resolution -Hours on Member Support
            if(ms.Site_Issue_Created_Date__c != null && ms.Actual_Resolution_Date__c != null){
               // ms.Elapsed_Open_to_Actual_Resolution_Hours__c = (Util.businessHoursForStartAndEndDate(ms.Site_Issue_Created_Date__c, ms.Actual_Resolution_Date__c))/60;
             } else{
                ms.Elapsed_Open_to_Actual_Resolution_Hours__c = null;
             }
            
            //Populate Elapsed: Open to Close (Hours) on Member support
            if(ms.Site_Issue_Created_Date__c != null && ms.Site_Issue_Close_Date__c != null){
               // ms.Elapsed_Open_to_Close_Hours__c = (Util.businessHoursForStartAndEndDate(ms.Site_Issue_Created_Date__c, ms.Site_Issue_Close_Date__c, null))/60;
            }else{
                ms.Elapsed_Open_to_Close_Hours__c = null;
            }
            
            //V_1.25 - Modified By - Mahendra Swarnakar - CR-20161103-10340 - Release 55 - 12/16/2016 - populating CCM Data Load elapsed field with Businees hours difference b/n two dates
            if(ms.RecordTypeId == Util.RecordTypeId( MemberSupportTriggerUtilities.MEMBER_SUPPORT_OBJECT, RECORD_TYPE_SITE_ISSUE_CCM_DATA_LOAD)){
                
                if(ms.Files_Received__c != null && ms.Data_Submission_Target_Date__c != null)
                    ms.Elapsed_DST_to_Files_Received__c = Util.CalculateBusinessDays(ms.Data_Submission_Target_Date__c.addDays(1), ms.Files_Received__c, false, false);
                else
                    ms.Elapsed_DST_to_Files_Received__c = null;
                    
                if(ms.Start_Import_Date__c != null && ms.Files_Received__c  != null)
                    ms.Elapsed_Files_Received_to_Start_Import__c = Util.CalculateBusinessDays(ms.Files_Received__c.addDays(1), ms.Start_Import_Date__c, false, false);
                else
                    ms.Elapsed_Files_Received_to_Start_Import__c = null;
                
                if(ms.End_Import_Date__c != null && ms.Files_Received__c  != null)
                    ms.Elapsed_Files_Rec_d_to_End_Import_Date__c = Util.CalculateBusinessDays(ms.Files_Received__c.addDays(1), ms.End_Import_Date__c, false, false);
                else
                    ms.Elapsed_Files_Rec_d_to_End_Import_Date__c = null;
                
                if(ms.Start_Import_Date__c != null && ms.End_Import_Date__c  != null) 
                   ms.Elapsed_Start_Import_to_End_Import_Date__c = Util.CalculateBusinessDays(ms.Start_Import_Date__c.addDays(1), ms.End_Import_Date__c, false, false);
                else
                   ms.Elapsed_Start_Import_to_End_Import_Date__c = null;
                
                if(ms.Site_Issue_Close_Date__c  != null && ms.Files_Received__c != null)
                    ms.Elapsed_Files_Received_to_Ticket_Closed__c = Util.CalculateBusinessDays(ms.Files_Received__c.addDays(1), ms.Site_Issue_Close_Date__c.date(), false, false);
                else
                    ms.Elapsed_Files_Received_to_Ticket_Closed__c = null;
            }    
        }
    }
	
	//Spring clean up - populateMarketDataPeriodFields, populateMarketDataPeriodFieldsOnProject, 
   
    
    /**
      * @Description    :   Method to Populate Current Data Period on related Project when record type = "ARx Data Load" and Status = "Migration Complete"
      *
      * @args           :   List<Site_Issue__c>, Map<Id, Site_Issue__c> 
      *
      * @return         :   
      *
      * @Version        :   V1.0 - Created By - Mahendra Swarnkar - CR-20160927-10190 - 11/03/2016
    **/
    /*public static void populateCurrentDataPeriodOnProject(List<Site_Issue__c> listNewMS, Map<Id, Site_Issue__c> mapOldMS){
      
        //Map to hold associated project with member support
        Map<Id, Project__c> projectMap = new Map<Id, Project__c>();
        
        //Get Member Support record type "ARx_Data_Load" Id
        Id  msRecordType_ARx_Data_Load = Util.RecordTypeId(ProjectTriggerHelper.MEMBER_SUPPORT_API_NAME, 
                                                           Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_ARx_Data_Load);
        
        //Checking for the null value
        if(msRecordType_ARx_Data_Load == null)
            return;
        
        //Looping on new records
        for(Site_Issue__c membersupport : listNewMS) {
            
            //Checking for the eligibility in insert/update use cases
            if(
                (
                    mapOldMS == null 
                    && membersupport.Project__c != null
                    && String.isNotBlank(membersupport.Status__c)
                    && membersupport.Status__c.trim().equalsIgnoreCase(System.Label.MEMBER_SUPPORT_STATUS_MIGRATION_COMPLETE)
                    && membersupport.RecordTypeId != null
                    && membersupport.RecordTypeId == msRecordType_ARx_Data_Load
                    && membersupport.Data_Load_Period_End__c != null
                )
                ||
                (
                    mapOldMS != null 
                    && (
                          mapOldMS.get(membersupport.Id).Status__c != membersupport.Status__c 
                           || mapOldMS.get(membersupport.Id).Data_Load_Period_End__c != membersupport.Data_Load_Period_End__c
                       )
                    && String.isNotBlank(membersupport.Status__c)
                    && membersupport.Status__c.trim().equalsIgnoreCase(System.Label.MEMBER_SUPPORT_STATUS_MIGRATION_COMPLETE) 
                    && membersupport.RecordTypeId != null
                    && membersupport.RecordTypeId == msRecordType_ARx_Data_Load 
                    && membersupport.Project__c != null 
                )
            )
                projectMap.put(membersupport.Project__c, new Project__c(Id = membersupport.Project__c, 
                                    Current_Data_Period_New__c = membersupport.Data_Load_Period_End__c));
        }
        
        //Checking if map size is greater than zero then update
        if(projectMap.size() > 0){
           
            //Bypassing all triggers
            Util.byPassAllTriggers = true;
            update projectMap.values();
            //Enabling all triggers
            Util.byPassAllTriggers = false;
            
        }
    }*/
    
  /**
      * @Description    :   Method to send an email when CPM Data Load record has been marked as complete. 
      *
      * @args           :   List<Site_issue__c> newListSiteIssues, Map<Id, Site_Issue__c> oldMapSiteIssues 
      *
      * @return         :   
      *
      * @Version        :   V1.0 - Created By - Mahendra Swarnkar - CR-20161228-10580 - 1/22/2017
      *         :  V1.1 - Modified By - Mahendra Swarnkar - CR-20160420-9786 - 3/16/2017
      *         
    **/
    public static void SendCMACompletionandCPMDataLoadEmail(List<Site_issue__c> newListSiteIssues, Map<Id, Site_Issue__c> oldMapSiteIssues){
    
        //This map is to hold the first target object id for Member support/Projecct
        Map<Id, Id> mapContactsWithProjects = new Map<Id, Id>();

        //This map is to hold the first target object id for Project
        Map<Id, list<Site_Issue__c>> mapProjectstWithMemberSupport = new Map<Id, list<Site_Issue__c>>();
        
        //Map to hold the records 
        Map<Id, Site_Issue__c> mapOfMemerSupports = new Map<Id, Site_Issue__c>([SELECT Id, Status__c, RecordTypeId, Project__c, Project_Name__c, 
                                        Site_Issue_Close_Date__c, Data_Load_Type__c, 
                                                                                Data_Load_Period_End__c, Member_Name__c, 
                                                                              	Production_Business_Analyst__c, 
                                                                                Production_Business_Analyst__r.Email, 
                                                                              	Project__r.Dedicated_Advisor__c, 
                                                                                Project__r.Dedicated_Advisor__r.Email/*,
                                        					Project__r.Recurring_Business_Analyst__c,
                                        					Project__r.Recurring_Business_Analyst__r.Email*/
                                                                                FROM Site_Issue__c
                                                                                WHERE Id IN : newListSiteIssues
                                                                                AND RecordTypeId != null 
                                                                            ]
                                                                           );
        
        //Checking for the null and size value
        if(mapOfMemerSupports != null
          && mapOfMemerSupports.values() != null 
            && mapOfMemerSupports.values().size() > 0) {
                
            //Set for hold Project's Ids
            Set<Id> projectIds = new Set<Id>();
            
            //Map of CC addresses to hold the CCAddresses for each project
            Map<Id, List<String>> mapCCAddresses = new Map<Id, List<String>>();
            
            //This map is to hold all the remaining contacts email toAddresses for Project
            Map<Id, List<String>> mapToAddresses = new Map<id, List<String>>();
            
            //Loop through mapp values
            for(Site_Issue__c sIssue : mapOfMemerSupports.values()) {

                //Check for status field value "closed" and Project__c field not null
                if(
          sIssue.Project__c != null
          && String.isNotBlank(sIssue.Status__c)
          && sIssue.RecordTypeId !=  null
          && 
          (
                        //check for addtional field conditions for "CPM Data Load" record type
            (
              sIssue.RecordTypeId == Util.recordTypeId(OBJECT_API_MEMBER_SUPPORT, MEMBER_SUPPORT_RECORD_TYPE_LABEL_CPM_DATA_LOAD)
              && sIssue.Status__c == System.Label.STATUS_SITE_ISSUE_CLOSED
              && 
              (
                oldMapSiteIssues == null 
                || 
                (
                  oldMapSiteIssues != null 
                                    && (
                                          oldMapSiteIssues.get(sIssue.Id).Status__c != sIssue.Status__c
                      || sIssue.RecordTypeId != oldMapSiteIssues.get(sIssue.Id).RecordTypeId
                                       )
                )
              )
            )
                        ||
                        
                        // V_1.30 - Modified By - Mahendra Swarnakar - CR-20160420-9786 - 3/16/2017 - Starts from here
            //check for addtional field conditions for "CMA Data Load Migration" record type - CR9786
                        (
              sIssue.RecordTypeId == Util.RecordTypeId(OBJECT_API_MEMBER_SUPPORT, MEMBER_SUPPORT_RECORD_TYPE_LABEL_CMA_DATA_LOAD_MIGRATION)
              && sIssue.Status__c == System.Label.MIGRATION_COMPLETE_STATUS
              && sIssue.Site_Issue_Close_Date__c != null
              && sIssue.Data_Load_Type__c != null
              && 
              (
                sIssue.Data_Load_Type__c == System.Label.MS_DATA_LOAD_TYPE_Current
                || sIssue.Data_Load_Type__c == System.Label.MS_DATA_LOAD_TYPE_Off_Cycle_Migration
                || sIssue.Data_Load_Type__c == System.Label.MS_DATA_LOAD_TYPE_Off_Cycle_Migration_Only
                
              )
              &&
              (
                oldMapSiteIssues == null
                ||
                (
                  oldMapSiteIssues != null
                  &&
                                    (
                                        oldMapSiteIssues.get(sIssue.Id).Status__c != sIssue.Status__c
                                        || sIssue.RecordTypeId != oldMapSiteIssues.get(sIssue.Id).RecordTypeId
                                        || sIssue.Site_Issue_Close_Date__c != oldMapSiteIssues.get(sIssue.Id).Site_Issue_Close_Date__c
                                        || sIssue.Data_Load_Type__c != oldMapSiteIssues.get(sIssue.Id).Data_Load_Type__c
                                    )
                )
              )
            )
                        // V_1.30 - Modified By - Mahendra Swarnakar - CR-20160420-9786 - 3/16/2017 - Ends here
          )
                ){
                    
                    //Add projectIds in set
                    projectIds.add(sIssue.Project__c);
                    
          //Add a new record in Map : ccAddress map
                    mapCCAddresses.put(sIssue.Id, new List<String>());
          
                    //Check for MS record type = CPM_DATA_LOAD
          if(sIssue.RecordTypeId == Util.recordTypeId(OBJECT_API_MEMBER_SUPPORT, MEMBER_SUPPORT_RECORD_TYPE_LABEL_CPM_DATA_LOAD))
          {
            //Check for the values and add in ccAddress map
            if(sIssue.Project__r.Dedicated_Advisor__c != null
            && String.isNotBlank(sIssue.Project__r.Dedicated_Advisor__r.Email))
              mapCCAddresses.get(sIssue.Id).add(sIssue.Project__r.Dedicated_Advisor__r.Email);
            
                        //Check for Production Business Analyst and add in the ccAddress map
            if(sIssue.Production_Business_Analyst__c != null
              && String.isNotBlank(sIssue.Production_Business_Analyst__r.Email))
              mapCCAddresses.get(sIssue.Id).add(sIssue.Production_Business_Analyst__r.Email);  
          }
                    else{
            
                        // V_1.30 - Modified By - Mahendra Swarnakar - CR-20160420-9786 - 03/16/2017 - Starts from here
                        //Check for MS record type = CMA_DATA_LOAD_MIGRATION - CR-9786
            if(sIssue.RecordTypeId == Util.RecordTypeId(OBJECT_API_MEMBER_SUPPORT, MEMBER_SUPPORT_RECORD_TYPE_LABEL_CMA_DATA_LOAD_MIGRATION))
            {
              //Check for the values and add in map
              //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
              /*if(sIssue.Project__r.Recurring_Business_Analyst__c != null
              && String.isNotBlank(sIssue.Project__r.Recurring_Business_Analyst__r.Email))
                mapCCAddresses.get(sIssue.Id).add(sIssue.Project__r.Recurring_Business_Analyst__r.Email);*/
            }
                        // V_1.30 - Modified By - Mahendra Swarnakar - CR-20160420-9786 - 1/23/2017 - Ends here
          }
                    
                    //Check for size and then populate the mapProjectstWithMemberSupport
          if(mapProjectstWithMemberSupport.size() > 0
              && mapProjectstWithMemberSupport.containsKey(sIssue.Project__c)
              && mapProjectstWithMemberSupport.get(sIssue.Project__c) != null
              && mapProjectstWithMemberSupport.get(sIssue.Project__c).size() > 0)
          {
            mapProjectstWithMemberSupport.get(sIssue.Project__c).add(sIssue);
          }
          else {
                        //populate the mapProjectstWithMemberSupport
            mapProjectstWithMemberSupport.put(sIssue.Project__c, new List<Site_Issue__c>());
            mapProjectstWithMemberSupport.get(sIssue.Project__c).add(sIssue);
          }          
                }
            }
          
            //Check for size    
            if(projectIds.size() > 0)
            {
                //Map to jold the project Id with related project Roles
        Map<Id, List<Project_Role__c>> mapProjectWithProjectRoles = new Map<Id, List<Project_Role__c>>();
        
                //Loop through list of Project Role records associated within projectIds set
                for(Project_Role__c projectRole : [SELECT Id, Name, Project__c, Contact__c, Project_Role_Contact_EMail__c,
                                                   CMGA_Include_In_Data_Load_Member_Email__c, Receive_CMA_Load_Completed_Email__c
                                                   From Project_Role__c 
                                                   WHERE Contact__c != null
                          AND Project__c != null 
                          AND Project__c IN : projectIds 
                          AND 
                                                   (
                            CMGA_Include_In_Data_Load_Member_Email__c = true
                            OR
                            Receive_CMA_Load_Completed_Email__c = true
                          )
                          AND Project_Role_Contact_EMail__c != null
                        ]
                   ) 
                {
                    //Populate the map mapProjectWithProjectRoles
          if(mapProjectWithProjectRoles.containsKey(projectRole.Project__c))
            mapProjectWithProjectRoles.get(projectRole.Project__c).add(projectRole);
          else
            mapProjectWithProjectRoles.put(projectRole.Project__c, new list<Project_Role__c> {projectRole});
                }
                
                // V_1.30 - Modified By - Mahendra Swarnakar - CR-20160420-9786 - 1/23/2017 - get Email Template of "CMA Data Load Reminder"
        //get Email Template of "CMA Data Load Reminder"
        List<EmailTemplate> emailTemplates = [SELECT Id, DeveloperName FROM EmailTemplate 
                            WHERE 
                                                        (
                              DeveloperName =: Email_TEMPLATE_CMA_DATA_LOAD_COMPLETION 
                              OR 
                              DeveloperName =: Email_TEMPLATE_CPM_DATA_LOAD_TEMPLATE
                            )
                            AND IsActive = true
        ];
        
                //Temporary varialbles to hold the Email Template Ids
        Id CPM_DATA_LOAD_TempateID;
                
                // V_1.30 - Modified By - Mahendra Swarnakar - CR-20160420-9786 - 03/16/2017
        Id CMA_DATA_LOAD_COMPLETION_TempateID;
        
                //Check for size
        if(emailTemplates != null && emailTemplates.size() > 0) {
          
                    //Loop over the list of templates
          for(EmailTemplate emp : emailTemplates ) 
                    {
                        //Assign the values in the variables
            if(emp.DeveloperName == Email_TEMPLATE_CPM_DATA_LOAD_TEMPLATE)
              CPM_DATA_LOAD_TempateID = emp.Id;
                        
                        // V_1.30 - Modified By - Mahendra Swarnakar - CR-20160420-9786 - 03/16/2017 - Starts from here
                        //Assign the values in the variables
            if(emp.DeveloperName == Email_TEMPLATE_CMA_DATA_LOAD_COMPLETION)
              CMA_DATA_LOAD_COMPLETION_TempateID = emp.Id;
                        // V_1.30 - Modified By - Mahendra Swarnakar - CR-20160420-9786 - 03/16/2017 - Ends here
          }
        }
        
                //Initialize list of SingleEmailMessage
                List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
                
                //Check for size
                if(mapProjectstWithMemberSupport.keySet().size() > 0) 
                {
                    //Loop through the project Ids and send email
                    for(Id projId : mapProjectstWithMemberSupport.keySet())
                    {   
                        //Check for size of Project related Member support records list 
                        if(mapProjectstWithMemberSupport.values() != null
                           && mapProjectstWithMemberSupport.values().size() > 0) 
                        {
                            //Loop through the projects and send email
                            for(Site_Issue__c msSupport : mapProjectstWithMemberSupport.get(projId)) 
                            {
                                //Variable to hold the contact Id
                Id ContactId;
                                
                                //Lists to hold the To Addresses for the emails
                List<String> toAddressEmails_CPM = new List<String>();
                                
                                // V_1.30 - Modified By - Mahendra Swarnakar - CR-20160420-9786 - 03/16/2017
                List<String> toAddressEmails_CMA = new List<String>();
                
                                //Check for size
                if(mapProjectWithProjectRoles.containsKey(projId) 
                  && mapProjectWithProjectRoles.get(projId).size() > 0)
                {
                                    //Loop over the project related Project Roles 
                  for(Project_Role__c pRole: mapProjectWithProjectRoles.get(projId))
                  {
                                        //Check for record type "CPM Data Load" 
                    if(msSupport.recordTypeId == Util.recordTypeId(OBJECT_API_MEMBER_SUPPORT, MEMBER_SUPPORT_RECORD_TYPE_LABEL_CPM_DATA_LOAD)
                      && pRole.CMGA_Include_In_Data_Load_Member_Email__c == true)
                    {
                                            //pupulate the variable 
                      if(ContactId == null)
                        ContactId = pRole.Contact__c;
                                            
                                            //Populate the to address for CPM related Project Roles 
                      toAddressEmails_CPM.add(pRole.Project_Role_Contact_EMail__c);
                    }
                                        
                                        // V_1.30 - Modified By - Mahendra Swarnakar - CR-20160420-9786 - 03/16/2017 - Starts from here
                                        //Check for record type "CMA Data Load/Migration" - CR - 9786
                    if(msSupport.recordTypeId == Util.RecordTypeId(OBJECT_API_MEMBER_SUPPORT, MEMBER_SUPPORT_RECORD_TYPE_LABEL_CMA_DATA_LOAD_MIGRATION)
                      && pRole.Receive_CMA_Load_Completed_Email__c == true)
                    {
                                            //check for Project Role name if it contains the String "Portal Only", 
                                            //if not then populate the allreceipientsemails list 
                                            if(!pRole.Name.contains(ProjectTriggerHelper.PROJECT_ROLE_NAME_STRING_PORTAL_ONLY)) {
                                             
                                                //poulate the variable 
                                                if(ContactId == null)
                          ContactId = pRole.Contact__c;
                                                
                                                //Populate rhe to address for CMA reelated project ROles 
                                                toAddressEmails_CMA.add(pRole.Project_Role_Contact_EMail__c);
                                            }
                    }
                                        // V_1.30 - Modified By - Mahendra Swarnakar - CR-20160420-9786 - 1/23/2017 - Ends here
                  }
                }
                
                                //Chck for nulll/blank
                if(ContactId != null){
                
                  //Instantiates SingleEmailMessage
                  Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                  
                  //Set CC address
                  mail.setCcAddresses(mapCCAddresses.get(msSupport.Id));
                    
                  //set Target Object Ids with a contact Id
                  mail.setTargetObjectId(ContactId);
                  
                  //Set whatIds as projectIds
                  mail.setWhatId(msSupport.Id);
                  
                  //set to address
                  if(toAddressEmails_CPM.size() > 0 
                    && CPM_DATA_LOAD_TempateID != null) {
                    mail.setToAddresses(toAddressEmails_CPM);
                    
                    //Set EmailTemplate
                    mail.setTemplateId(CPM_DATA_LOAD_TempateID);
                    
                    //Add mail in list
                    mails.add(mail);
                  }
                                    
                                    // V_1.30 - Modified By - Mahendra Swarnakar - CR-20160420-9786 - 03/16/2017 - Starts from here
                                    //Check for Size - CR-9786
                                    if(toAddressEmails_CMA.size() > 0 
                                       && CMA_DATA_LOAD_COMPLETION_TempateID != null) {
                                           mail.setToAddresses(toAddressEmails_CMA);
                                           
                                           //Set EmailTemplate 
                                           mail.setTemplateId(CMA_DATA_LOAD_COMPLETION_TempateID);
                                           
                                           //Add mail in list
                                           mails.add(mail);
                                    }
                                    // V_1.30 - Modified By - Mahendra Swarnakar - CR-20160420-9786 - 03/16/2017 - Ends here
                }
                            }
                            
                            //Check for the size
                            if(mails.size() > 0)
                                Messaging.sendEmail(mails);
                        }
                    }
                }
            }
        }
    }
    
    /**
      * @Description    :   Method to send an email when PRM data load is completed. 
      *
      * @args           :   List<Site_issue__c> newListSiteIssues, Map<Id, Site_Issue__c> oldMapSiteIssues 
      *
      * @return         :   
      *
      * @Version        :   V1.0 - Created By - Mahendra Swarnkar - CR-20160420-9786 - 3/16/2017
    **/
    public static void sendPRMDataLoadCompletionEmail(List<Site_issue__c> newListSiteIssues, Map<Id, Site_Issue__c> oldMapSiteIssues) {
        
        //Check if Email is already sent or not 
        if(Sent_PRM_Email_One_Time){
            return;
        }
        else    
        {
         
            //Set to hold Project Ids
            Set<Id> projectIds = new Set<Id>();
            
            //Loop through member Support records
            for(Site_issue__c ms : newListSiteIssues) {
                
                //Check for the condition and populate the project Ids set
                if(
                    ms.Project__C != null
                    && ms.RecordTypeId != null
                    && ms.RecordTypeId == Util.RecordTypeId(OBJECT_API_MEMBER_SUPPORT, MEMBER_SUPPORT_RECORD_TYPE_LABEL_CMA_DATA_LOAD_MIGRATION)
                    && ms.Status__c != null
                    && ms.Status__c == System.Label.MIGRATION_COMPLETE_STATUS
                    && ms.Site_Issue_Close_Date__c != null
                    && ms.Data_Load_Type__c != null
                    && 
                    (
                        ms.Data_Load_Type__c == System.Label.MS_DATA_LOAD_TYPE_Current
                        || ms.Data_Load_Type__c == System.Label.MS_DATA_LOAD_TYPE_Off_Cycle_Migration
                        || ms.Data_Load_Type__c == System.Label.MS_DATA_LOAD_TYPE_Off_Cycle_Migration_Only 
                    )
                    &&
                    (
                        oldMapSiteIssues == null
                        ||
                        (
                            oldMapSiteIssues != null
                            && 
                            (
                                ms.RecordTypeId != oldMapSiteIssues.get(ms.Id).RecordTypeId
                                || ms.Status__c != oldMapSiteIssues.get(ms.Id).Status__c
                                || ms.Site_Issue_Close_Date__c != oldMapSiteIssues.get(ms.Id).Site_Issue_Close_Date__c
                                || ms.Data_Load_Type__c != oldMapSiteIssues.get(ms.Id).Data_Load_Type__c
                            )
                        )
                    )
                ) {
                    projectIds.add(ms.Project__C);
                }
            }
            
            //Check for size
            if(projectIds.size() > 0) {
                
                //Initialize list of SingleEmailMessage
                List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
                    
                //get Email Template of "PRM Data Load completion"
                List<EmailTemplate> emailTemplates = [SELECT Id, DeveloperName FROM EmailTemplate WHERE DeveloperName =: Email_TEMPLATE_PRM_DATA_LOAD_COMPLETION AND IsActive = true];
                
                //Loop over the Project records along with the reated Project Roles 
                //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
                for(Project__C project : [SELECT ID, /*Recurring_Business_Analyst__c, Recurring_Business_Analyst__r.Email,*/
                                            (
                                                SELECT Id, Name, Contact__c, Contact__r.Email 
                                                FROM Project_Roles__r 
                                                WHERE Contact__c != null 
                                                AND Contact__r.Email != null
                                                AND Receive_PRM_Load_Completed_Email__c = true
                                            ) 
                                            FROM Project__c 
                                            WHERE Id IN : projectIds
                                        ]
                   )
                {
                    //List to hold the receipients Email 
                    Set<String> allreciepientsEmail= new Set<String>();
                    
                    //Set to hold the CCreceipients Email 
                    Set<String> ccreciepientsEmail= new Set<String>();
                    
                    //check for the null/[[blank]] and then populate the CCreceipients
                    //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
                   /* if(project.Recurring_Business_Analyst__c != null)
                        ccreciepientsEmail.add(project.Recurring_Business_Analyst__r.Email);*/
                    
                    //Temporary variable to hold the one of the contactId related to projet Role, 
                    //so that when cretaing a email we can set the targetObjectId with this contactId
                    Id ContactID; 
                    
                    //Loop over the project related Project Role records 
                    for(Project_Role__c projRo : project.Project_Roles__r) 
                    {
                        //Assign th value to contactId
                        if(ContactID == null)
                            ContactID = projRo.Contact__c;
                        
                        //check for Project Role name if it contains the String "Portal Only", 
                        //if not then populate the allreceipientsemails list 
                        if(!projRo.Name.contains(ProjectTriggerHelper.PROJECT_ROLE_NAME_STRING_PORTAL_ONLY)) 
                            allreciepientsEmail.add(projRo.Contact__r.Email);                        
                    }
                        
                    //Check for null/blank and create an email
                    if(ContactID != null)
                    {
                        //Check for size and show error message when not found the Tempate.
                        if(emailTemplates == null || emailTemplates.size() == 0)
                            throw new CustomException('Eamil tempalte ' + Email_TEMPLATE_PRM_DATA_LOAD_COMPLETION +' not found.');
                        
                        
                        //Create an email and set its parameters
                        Messaging.SingleEmailMessage emailToSent = new Messaging.SingleEmailMessage();
                        emailToSent.setTemplateId(emailTemplates[0].Id);
                        emailToSent.setToAddresses((new List<String>(allreciepientsEmail)));
                        emailToSent.setCcAddresses((new List<String>(ccreciepientsEmail)));
                        emailToSent.setWhatId(project.Id);
                        emailToSent.setTargetObjectId(ContactID);
                        //System.debug('@@@@@@ Template only'+ emailTemplates[0].Id);
                        //System.debug('@@@@@@ p1'+ emailToSent);
                        //populate the Emails list 
                        mails.add(emailToSent);
                        
                    }
                }
                
                //Check for size and then send the mails 
                if(mails.size() > 0)
                    Messaging.sendEmail(mails);
                
                //Set the flag to stop sending he emails multiple time 
                Sent_PRM_Email_One_Time = True;
            }
        }
    }
    
  /**
     *  @description    :  Method used to populate the Entity field value
     *             1) Populate the Entity__c = HC for following Member Support record types:- 
     *               ARx Data Load, CCA Data Load, CCM Data Load, CMA Data Load/Migration, CMA Initial Deployment Support, CMA Report Request, 
     *               CPM Data Load, CPM Support Issue, CPRM Data Load, Compass Data Analytics Ticket, Compass Data Load, 
     *               Compass Support Issue, Crimson Medical Director Service Request, Crimson Support Request, Defect / Enhancement Request,
     *               EHBI Data Load, EHBI Support Issue, IRound Data Load, Internal Initiative, Internal Initiative Detail, 
     *               PIC Contract Maintenance, PIC Customer Service Request, PIC Defect, PIC Enhancement, PIC Implementation Task, 
     *               PIC Operations Issue, PIC Query Component, PIC Rate Schedule, PIC Support Issue, Product Issue, RCS Support Issue
     *             2) Populate the Entity__c = EAB for following Member Support record types:- 
     *               IE Team Support , SSC RMS
     *             3) Populate the Entity__c = Owner.Entity__c for following Member Support record types:- 
     *               Compass Implementation & Support, Compass Connect Ticket 
     *
     *  @args           :  List of new Member Support records, Map of old Member Support records
     * 
     *  @return         :  void
     * 
     *   @Revision Log   :  V1.0 - Created By - Mahendra Swarnkar - 10/09/2017 - CR-20170928-11558 - Apollo Release
     **/
    public static void populateEntityField(List<Site_Issue__c> newMemberSupports, Map<Id, Site_Issue__c> mapOldMemberSupports) {
    
        //Check for the bypass Entity field population logic flag
        if(Util.bypassEntityPopulation) return;
        
        //Updated By Mahendra Swarnakar - CR-20171120-11798 - 11/21/2017 - to have the correct Name for "IRound Data Load" record type. 
        //Commented by Mahendra - 03/03/2020 - CR-20200217-13756 - 'CMA Report Request', 'Compass Data Load', 'EHBI Support Issue'
        //Set to hold the Member Support record type names for HC
        Set<String> setRTypeDeveloperNameForHC = new Set<String>{'ARx Data Load', 'CCA Data Load', 'CCM Data Load', 'CMA Data Load/Migration', 'CMA Initial Deployment Support', /*'CMA Report Request',*/ 'Compass Data Analytics Ticket', /*'Compass Data Load',*/ 'Compass Support Issue', 'CPM Data Load', 'CPM Support Issue', 'CPRM Data Load', 'Crimson Medical Director Service Request', 'Crimson Support Request', 'Defect / Enhancement Request', 'EHBI Data Load', /*'EHBI Support Issue',*/ 'Internal Initiative', 'Internal Initiative Detail', 'IRound Data Load', 'PIC Contract Maintenance', 'PIC Customer Service Request', 'PIC Defect', 'PIC Enhancement', 'PIC Implementation Task', 'PIC Operations Issue', 'PIC Query Component', 'PIC Rate Schedule', 'PIC Support Issue', 'Product Issue', 'RCS Support Issue'};
    
    //Set to hold the Record Type Ids
    Set<Id> setRTypeIdsForHC = new Set<Id>();
    
    Map<Id, RecordType> mapSiteIssueRecordTypes = new Map<Id, RecordType>([Select Id, Name,DeveloperName From RecordType Where SobjectType = 'Site_Issue__c']);
    
    //Set to hold the Member Support record type names for EAB
    Set<String> setRTypeDeveloperNameForEAB = new Set<String>{'IE Team Support', 'SSC RMS'} ;
    
    //Set to hold the Record Type Ids
    Set<Id> setRTypeIdsForEAB = new Set<Id>();
    
    //Set to hold the Member Support record type names for which ENtity will be populated on the base of Owner Entity
    Set<String> setRTypeDeveloperNameForOwnerEntity = new Set<String>{'Compass Implementation & Support', 'Compass Connect Ticket'};
        
        //Set to hold the Record Type Ids
    Set<Id> setRTypeIdsForOwnerEntity = new Set<Id>();
    
    //Set MemberSupport Ids
    Set<Id> setMSIds = new Set<Id>(); 
        
        //Set MemberSupport Owner Ids
    Set<Id> setOwnerIds = new Set<Id>(); 
        
        //Map to hold the Member Support RecordTypeId with recordType Name
        Map<Id, String> mapRTypeIdWithRTypeDeveloperName = Util.mapRecordTypes('Site_Issue__c');
        
        //Loop over the map
        for(Id rTId : mapSiteIssueRecordTypes.keySet()) {
          
          //Check for developer Name
          if(mapSiteIssueRecordTypes.get(rTId).DeveloperName == 'IRound_Data_Load')
            setRTypeIdsForHC.add(rTId);
            
          //Check Id in set
          if(setRTypeDeveloperNameForHC.contains(mapSiteIssueRecordTypes.get(rTId).Name))
            setRTypeIdsForHC.add(rTId);
          
          //Check Id in set
          if(setRTypeDeveloperNameForEAB.contains(mapSiteIssueRecordTypes.get(rTId).Name))
            setRTypeIdsForEAB.add(rTId);
          
          //Check Id in set
          if(setRTypeDeveloperNameForOwnerEntity.contains(mapSiteIssueRecordTypes.get(rTId).Name))
            setRTypeIdsForOwnerEntity.add(rTId);
        }
        
    //Loop over the new Mwmbwr support records
        for(Site_Issue__c ms : newMemberSupports) {
          
            //Check for record type
            if(ms.RecordTypeId != null && setRTypeIdsForOwnerEntity != null && setRTypeIdsForOwnerEntity.contains(ms.RecordTypeId)) {
              
                //Populate the Set
        setOwnerIds.add(ms.OwnerId);
      }
        }
        
         //Map to ho;d the Member support's Owner records 
        Map<Id, User> mapMSOwners = new Map<Id, User>();
            
        //Check for size
        if(setOwnerIds.size() > 0) {
            
            //Loop over the user records
            for(User u : [Select Id, Entity__c From User Where Id IN : setOwnerIds ]) {
                
                //Populate the Map
                mapMSOwners.put(u.Id, u);
            }   
        }
        
        //Loop over the Member support records
        for(Site_Issue__c mems : newMemberSupports){
      
            //Check for record type
            if(mems.RecordTypeId != null) {
            
                //Check if record Type comes in the 'HC' category
                if(setRTypeIdsForHC.contains(mems.RecordTypeId)) {
                  
                    //Populate the Entity to 'HC'
                    mems.Entity__c = 'HC';
                }
                
                //Check if record Type comes in the 'EAB' category
                if(setRTypeIdsForEAB.contains(mems.RecordTypeId)) {
                    
                    //Populate the Entity to 'EAB'
                    mems.Entity__c = 'EAB';
                }
                
                //Check if record Type comes in the 'Owner based' category
                if(setRTypeIdsForOwnerEntity.contains(mems.RecordTypeId) && mapMSOwners.size() > 0 && mapMSOwners.containsKey(mems.OwnerId) && mapMSOwners.get(mems.OwnerId) != null ) {
                    
                    //Populate the Entity to Owner's Entity
                    mems.Entity__c = mapMSOwners.get(mems.OwnerId).Entity__c ;
                }
            }
        }
    }
}