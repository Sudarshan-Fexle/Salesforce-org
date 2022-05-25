/**
*  Description     :   Helper class for Project object trigger.
*
*  Created By      :   Bhavi Sharma
*
*  Created Date    :   03/25/2013
*
*  Revision Logs   :   	V_1.0 - Created
                        V_1.1 - Modified By - Bhavi Sharma - 04/26/2013 - New method added (UpdateProjectByMembershipEvent)- CR-20130408-2822
                        V_1.2 - Modified By - Bhavi Sharma - 05/17/2013 - Code modified & method added (isChanged) - CR-20130116-2186
                        V_1.2 - Modified By - Bhavi Sharma - 05/31/2013 - New method added (updateProjectByCurrentRenewalOpportunity) - CR-20130328-2773
                        V_1.3 - Modified By - Bhavi Sharma - 06/28/2013 - Code commented in method (updateMembershipData) - CR-20130617-3170
                        V_1.4 - Modified By - Bhavi Sharma - 10/21/2013 - Method updated (updateMembershipData) - CR-20130529-3091
                        V_1.5 - Modified By - Bhavi Sharma - 12/23/2013 - New method added(UpdateSiteIssueByProject) - CR-20130813-3414
                        V_1.6 - Modified By - Abhinav Sharma - 03/01/2014 - CR-20140214-4520 - Remove following lines from code
                        V_1.7 - Modified By - Abhinav Sharma - 03/03/2014 - CR-20130829-3543 - CMA - Elapsed Time Field - Moved to Prod Team
                        V_1.8 - Modified By - Abhinav Sharma - 03/03/2014 - CR-20140220-4549 - Remove following lines from code
                        V_1.9 - Modified By - Abhinav Sharma - 04/03/2014 - CR-20140220-4549 - Remove Following Lines from code
                        V_2.0 - Modified By - Abhinav Sharma -  04/29/2014 - CR-20140403-4958 - Modified method: populateFirstDeploymentSignedOff
                        V_2.1 - Modified By - Ajit Surana - 09/08/2014 - CR-20140716-6256 - Exclude Project Record Type "SSC" from populateFirstDeploymentSignedOff() method
                        V_2.2 - Modified By - Ajit Surana - 09/08/2014 - CR-20140513-5475 - CMA Project - New Field - Data Lag Month (Method commented out)
                        V_2.3 - Modified By - Abhinav Sharma - 10/17/2014 - CR-20140826-7138 - New method populateDeploymentSignOffOldest added.
                        V_2.4 - Modified By - Abhinav Sharma - 10/18/2014 - CR-20140221-4576 - Removed reference of Opportunity_Refresh__c field.
                        V_2.5 - Modified By - Abhinav Sharma - 11/25/2014 - CR-20141106-8010 - Revert change to Site Live field on SSC projects 
                        V_2.6 - Modified By - Abhinav Sharma - 06/13/2015 - CR-20150601-8976 - Added new method (validateAndPopulateProjectFields)
                        V_2.7 - Modified By - Abhinav Sharma - 07/29/2015 - CR-20150709-9070 - Added new method (populateProjectFieldsFromChildren)
                        V_2.8 - Modified By - Abhinav Sharma - 08/24/2015 - CR-20150127-8596 - Modified existing method (populateProjectFieldsFromChildren)
                        V_2.9 - Modified By - Abhinav Sharma - 10/20/2015 - CR-20151016-9329 - Modified existing method (populateProjectFieldsFromChildren)
                        V_3.0 - Modified By - Mahedra Swarnkar - 07/05/2016 - CR-20160229-9651 - Added a new Method "populateCaseFieldsFromProject" to populate case fields from Project
                        V_3.1 - Modified By - Mahendra Swarnkar - CR-20160420-9785 - 09/01/2016 - Added a new Methods "populateMarketDataPeriodFieldsOnProject" and "populateProjectFieldsFromMemberSupport" to populate the Market data period begin and Market data period End Fields on Project 
                        V_3.2 - Modified By - Rajeev Jain - 10/20/2016 - Services Excellence - Manually merged code from Services Excellence to Test Sandbox
                        V_3.3 - Modified By - Mahendra Swarnkar - CR-20161101-10303 - 11/18/2016 - Remove delete field dependency.
                        V_3.4 - Modified By - Mahendra Swarnakar - CR-20161110-10358 - 12/10/2016 - Added a new method "createDeliveryMilestoneTasksOnproject"
                        V_3.5 - Modified By - Abhinav Sharma - CR-20170113-10615 - 1/31/2017 - Modified "populateProjectFieldsFromChildren" method
                        V_3.6 - Modified By - Mahendra Swarnakar - CR-20160420-9786 - 3/16/2017 - Added a new method "sendMailToContactsTaggedASProjectRoles"
                        V_3.7 - Modified By - Abhinav Sharma - 4/27/2017 - CR-20170321-10769 - Add the check for "Project Phase" field value "Implementation"
                        V_3.8 - Modified By - Abhinav Sharma - 06/02/2017 - DS114 - Updated existing method (validateAndPopulateProjectFields) and added a new method (updateMembershipsFromProject)
                        V_3.9 - Modified By - Rajeev Jain - 07/05/2017(In order of migration tasks of - Releases after Q2CDev3 sandbox refresh date[04/07/2017] in Q2CDev3 sandbox from Test sandbox in order to sync with Q2c Beta Release and Revenue Management
                        V_4.0 - Modified By - Rajeev Jain - 07/28/2017( Release 60 Deployment Merged the changes of R60 with Q2C Beta + Revenue Management Release) - Starts from here
                        V_4.1 - Modified By - Mahendra Swarnkar - 07/05/2017 - CR-20170616-11008 - Added a new method - populateTVMFieldsOnProjectFromMembership
                        V_4.2 - Modified By - Rajeev Jain - 07/28/2017( Release 60 Deployment Merged the changes of R60 with Q2C Beta + Revenue Management Release) - Ends here
                        V_4.3 - Modified By - DIpesh Gupta - 08/12/2017 - CR-20170426-10878 - updated method  validateAndPopulateProjectFields to populate fields (Membership Status, Number of Hospitals, Annual_Contract_Value__c) for  the record type (CCA, CMA, CMGA, CostOps, HP Consumer Scheduling, iRound or RCS)
                        V_4.4 - Modified By - Abhinav Sharma - 09/20/2018 - CR-20180917-12599 - Created a new Method - createShadowProjectOnProjectCreation
                        V_4.5 - Modified By - Rajeev jain - 12/06/2018 - Deployment of CR-20181205-12774
                        V_4.6 - Modified By - Abhinav Sharma - 12/11/2018 - CR-20181211-12780
                        V_4.7 - Modified By - Abhinav Sharma - 03/12/2018 - CR-20181025-12706 - new method populateFieldsOnProjectFromAsset  to populate 'Learning Management System' and 'Current SIS' fields On Project record from the 'Competitor and Tech System' object.
                        V_4.8 - Modified By - Subhash Gharwal -29-04-2019 - Spring cleanup - CR-20190425-13035  
                        V_4.9 - Modified By - Subhash Gharwal -29-04-2019 - Spring cleanup - CR-20190425-13035  
                        V_5.0 - Modified By - Dipesh Gupta - CR-20190529-13156 - 09/04/2019 - For Record type Label Modified From 'SSC' To 'Tech' Created new variable 'PROJECT_SSC_RECORD_TYPE_LABEL_NAME'
                        V_5.1 - Modified By - Dipesh Gupta - 09/26/2019 - CR-20190529-13156 - APS replaced by Tech (SSC) as per Taylor Chatter
                        V_5.2 - Modified By - Dipesh Gupta - 23/12/2019 - CR-20191204-13550 - modified method populateFieldsOnProjectFromAsset  to populate 'Learning Management System', 'Current SIS' and 'Enrollment CRM' fields On Project record from the 'Competitor and Tech System' object.
                        V_5.3 - Modified By - Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
			V_5.4 - Modified By - Neha Sharma - 03/08/2021 - CR-20201022-14630 - Fix Logic on SIS, LMS and Enrollment CRM SSC Project Fields
                        V_5.5 - Modified By - Neha Sharma - CR-20200615-14188 - 04/08/2021 - Add the logic for Audit Degree in populateFieldsOnProjectFromAsset
                        V_5.6 - Modified By - Mahendra Swarnkar - CR-20211118-15596 - 11/24/2021 - Commented existing method populateFieldsOnProjectFromAsset and created  new method populateFieldsOnProjectFromCompTechSystem to work with Competitor and Tech System Object and its fields instead of "Assets" object and fields.
                        V_5.7 - Modified By - Chirag Soni - CR-20211207-15617 - 5/24/2022 - Commented reference for formula status field and added picklist status field in place of it.
**/
public without sharing class ProjectTriggerHelper {
    
    //V_1.25 - Modified By - Mahendra Swarnakar - CR-20160420-9786 - 3/16/2017 - Starts from here
    public final static String PROJECT_RECORDTYPE_LABEL_CMA = 'CMA';
    public final static String OBJECT_API_NAME_PROJECT = 'Project__C';
    public final static String PROJECT_ROLE_NAME_STRING_PORTAL_ONLY = 'Portal Only';
    public final static String Email_TEMPLATE_CMA_DATA_LOAD_REMINDER = 'CMA_Data_Load_Reminder_New_Project';
    
    //V_1.25 - Modified By - Mahendra Swarnakar - CR-20160420-9786 - 3/16/2017 - Ends here 
    public final static String STATUS_22_PRODUCTION_MIGRATION_COMPLETE = 'Migration complete';
    
    //V 1.21 - Rajeev Jain - 10/20/2016 - Services Excellence - Manually merged code from Services Excellence to Test Sandbox
    //V 1.21 - Replaced old data load values with new Standarised values as a part of the Services Excellence Project
    //Added By - Mahendra Swarnkar - CR-20160420-9785 - 09/01/2016 - Starts From Here
    public final static String DATA_LOADTYPE_CURRENT = 'Current';
    public final static String DATA_LOADTYPE_OFF_CYCLE_DATA_LOAD_AND_OR_MIGRATION = 'Off-Cycle/Migration';
    public final static String DATA_LOADTYPE_OFF_CYCLE_MIGRATION = 'Off-Cycle Migration only';
    public final static String MEMBER_SUPPORT_API_NAME = 'Site_Issue__c';
    public final static String MEMBER_SUPPORT_RECORDTYPE_CMA_DATA_LOAD_MIGRATION = 'CMA Data Load/Migration';
    //Added By - Mahendra Swarnkar - CR-20160420-9785 - 09/01/2016 - End Here    
    //V 1.21 - Rajeev Jain - 10/20/2016 - Services Excellence - Manually merged code from Services Excellence to Test Sandbox - upto here
    
    //Constants like variable
    public final static String PROJECT_OBJECT_API_NAME = 'Project__c';
    public final static String PROJECT_APS_RECORD_TYPE_API_NAME = 'APS';
    public final static String PROJECT_SSC_RECORD_TYPE_API_NAME = 'SSC';
    
    //Modified By Dipesh Gupta - CR-20190529-13156 - 09/04/2019 - For Record type Label Modified From 'SSC' To 'Tech' Created new variable 'PROJECT_SSC_RECORD_TYPE_LABEL_NAME'
    public final static String PROJECT_SSC_RECORD_TYPE_LABEL_NAME = 'Tech';
    
    //V_1.24 - Modified By - Abhinav Sharma - CR-20170113-10615 - 1/31/2017
    //Method helpful in determining whether code is execute in before event context or not
    public static Boolean IS_EXECUTING_IN_BEFORE_EVENT = false;
    //V_1.24 - Modified By - Abhinav Sharma - CR-20170113-10615 - 1/31/2017 - Ends here
    
    //V_1.28 - Merged By - Rajeev Jain - 07/05/2017(In order of migration tasks of - Releases after Q2CDev3 sandbox refresh date[04/07/2017] in Q2CDev3 sandbox from Test sandbox in order to sync with Q2c Beta Release and Revenue Management
    //Added By - Abhinav Sharma - 06/02/2017 - DS114
    /**
    *  @description    :   Method to update membership fields from the project fields values.
    *
    *  @args           :   List<Project__c> newProjects, Map<Id, Project__c> mapOldProjects
    *
    *  @return         :   void
    *
    **/
    public static void updateMembershipsFromProject(List<Project__c> newProjects, Map<Id, Project__c> mapOldProjects) {
        
        //Checking for the update use case
        if(newProjects != null && mapOldProjects != null) {
            
            //Set of project records
            Set<Id> setOfProjects = new Set<Id>();
            
            //Loop through project records
            for(Project__c proj : newProjects) {
                
                //Checking for field value change
                if(proj.Dedicator_Advisor_Pod_Lead__c != mapOldProjects.get(proj.id).Dedicator_Advisor_Pod_Lead__c)
                    setOfProjects.add(proj.Id);
            }
            
            //Checking set for its size
            if(setOfProjects.size() > 0) {
                
                //Map of memberships to be Updated
                Map<Id, Membership__c> mapOfMemberships = new Map<Id, Membership__c>();
                
                //Loop through membership records
                for(Membership__c mem : [SELECT ID, Dedicated_Advisor_Pod_Lead__c, 
                                         Primary_Project__r.Dedicator_Advisor_Pod_Lead__c
                                         FROM Membership__c
                                         WHERE Primary_Project__c != null
                                         AND Primary_Project__c IN : setOfProjects
                                        ]
                   ) {
                       if(mem.Dedicated_Advisor_Pod_Lead__c != mem.Primary_Project__r.Dedicator_Advisor_Pod_Lead__c) {
                           mem.Dedicated_Advisor_Pod_Lead__c = mem.Primary_Project__r.Dedicator_Advisor_Pod_Lead__c;
                           mapOfMemberships.put(mem.Id, mem);
                       }
                   }
                
                //Checking map for its size
                if(mapOfMemberships.values().size() > 0) {
                    Util.byPassAlltriggers = true;
                    update mapOfMemberships.values();
                    Util.byPassAllTriggers = false;
                }    
            }
        }
    }
    //V_1.28 - Merged By - Rajeev Jain - 07/05/2017 - Upto Here
    //Modified by Subhash Gharwal -29-04-2019 - Spring cleanup - CR-20190425-13035  
    
    //This method is to set the data on Membership object
    public static void updateMembershipData(List<Project__c> newProjects, Map<Id, Project__c> mapOldProjects) {
        
        //Create a set of membership Ids
        Set<Id> membershipIds = new Set<Id>();
        
        //Loop through the Projects and get membership data
        for(Project__c project : newProjects) {
            
            //Check if membership is not Null
            if(project.Primary_Paid_Membership__c != null
               && (mapOldProjects == null || isChanged(project, mapOldProjects.get(project.Id)))) {
                   
                   //Add in membership set
                   membershipIds.add(project.Primary_Paid_Membership__c);
               }
            
            //Add Olfd Membership records Ids
            if(mapOldProjects != null && mapOldProjects.get(project.Id).Primary_Paid_Membership__c != null
               && project.Primary_Paid_Membership__c != mapOldProjects.get(project.Id).Primary_Paid_Membership__c) {
                   
                   //Add in membership set
                   membershipIds.add(mapOldProjects.get(project.Id).Primary_Paid_Membership__c);
               }
        }
        
        //Check if records to Process
        if(membershipIds.size() > 0) {
            
            //Get Membership records from database
            Map<Id, Membership__c> mapMemberships = new Map<Id, Membership__c>([Select Id, Primary_Project__c, Renewal_Opp_Owner__c from Membership__c
                                                                                where Id IN: membershipIds]);
            
            //Check for the mebership records
            if(mapMemberships.size() > 0) {
                
                //Replaced List of records with map of records - Abhinav Sharma - 05/03/2014 - Modified since Taylor got duplicate Id error while historical update - CR-20140403-4958
                //List of membersip records to be updated
                Map<Id, Membership__c> membershipsMap = new Map<Id, Membership__c>();
                
                //List of Projects to be updated with The membership information
                List<Project__c> projects = new List<Project__c>();
                
                //Loop through the New Projects
                for(Project__c project : newProjects) {
                    
                    //Check if membership is not Null
                    if(project.Primary_Paid_Membership__c != null
                       && (mapOldProjects == null || isChanged(project, mapOldProjects.get(project.Id)) )) {
                           
                           //Check if there membership do not have Primary_Project__c stamped on it
                           if(mapMemberships.containsKey(project.Primary_Paid_Membership__c)) {
                               
                               //Get Membership object data
                               Membership__c ms = mapMemberships.get(project.Primary_Paid_Membership__c);
                               
                               //Check if primary project is stamped on it
                               if(ms.Primary_Project__c == null || ms.Primary_Project__c == project.Id) {
                                   
                                   //Create membership instance
                                   Membership__c membership = new Membership__c(Id = ms.Id);
                                   
                                   //Update the Membership record with
                                   membership.Primary_Project__c = project.Id;
                                   
                                   //Bhavi Sharma - 10/21/2013 - CR-20130529-3091
                                   //Modified By Abhinav Sharma - 4/27/2017 - CR-20170321-10769 - Add for the projectPhase field value "Implementation"
                                   if(project.Project_Phase__c != null &&
                                      (project.Project_Phase__c.startsWith('0 - ')
                                       || project.Project_Phase__c.startsWith('1 - ')
                                       || project.Project_Phase__c.startsWith('2 - ')
                                       || project.Project_Phase__c.startsWith('3 - ')
                                       || project.Project_Phase__c.startsWith('4 - ')
                                       || project.Project_Phase__c == 'Implementation')
                                     ) {
                                        //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
                                         //membership.BA_Assignment2__c = project.Implementation_Business_Analyst__c;
                                     } /*else
                                         membership.BA_Assignment2__c = project.Recurring_Business_Analyst__c;*/
                                   
                                   membership.DA_Assignment2__c = project.Dedicated_Advisor__c;
                                   
                                   //CR-20140214-4520 - Remove following lines from code 
                                   //Commented By Abhinav Sharma - 03-01-2014
                                   //membership.Value_Pod__c = project.EHBI_Value_Pod__c;
                                   //membership.Implementation_Pod__c = project.Implementation_Pod__c;
                                   membership.Delivery_Project_Phase__c = project.Project_Phase__c;
                                   membership.Relationship_Grade__c = project.Relationship_Grade__c;
                                   //membership.Relationship_Grade_Notes__c = project.Relationship_Grade_Notes__c;
                                   //membership.Realized_ROI__c = project.Realized_ROI__c; //CR-20200415-13952
                                   //Modified by Subhash Gharwal 04/29/2019 - Spring cleanup - CR-20190425-13035  
                                   //membership.Site_Live__c = project.Date_Site_Live__c;
                                   //membership.Path_to_ROI_Grade__c = project.Path_to_ROI__c;
                                   //membership.Executive_Engagement_Grade__c = project.Executive_Engagement__c;
                                   //membership.Member_Expectations_Grade__c = project.Institution_Expectations__c;
                                   
                                   //Code modified - Bhavi Sharma - CR-20130116-2186
                                   //modified by Subhash Gharwal -29-04-2019 - Spring cleanup - CR-20190425-13035  
                                   //membership.Active_Outreach_Program__c = project.CMA_Outreach_Program__c;
                                   
                                   //CR-20140220-4549 - Remove following lines from code 
                                   //Commented By Abhinav Sharma - 03-04-2014
                                   //membership.CMA_Initiative_Last_Updated__c = project.CMA_Initiative_Last_Updated__c;
                                   ////Modified by Subhash Gharwal -29-04-2019 - Spring cleanup - CR-20190425-13035  
                                   // membership.CRM_Usage__c = project.CMA_CRM_Usage__c;
                                   //membership.Goals_and_Work_Plan_Call_Actual__c = project.Goals_Planning__c;
                                   //membership.Goals_and_Work_Plan_Call_Projected__c = project.Goals_and_Work_Plan_Call_Projected__c;
                                   //membership.Initial_Opp_Assessment_Actual__c = project.Initial_Opp_Assessment_Presented__c;
                                   //membership.Initial_Opp_Assessment_Target__c = project.Initial_Opp_Assessment_Projected_Target__c;
                                   //membership.Initial_Value_Meeting_Projected__c = project.Initial_Value_Meeting_Projected__c;
                                   //membership.Initial_Value_Meeting_Actual__c = project.initial_value_meeting__c;
                                   //membership.Initiatives_Series_1__c = project.Initiatives_Series_1__c;
                                   //Modified By - Dipesh Gupta -  CR-20200218-13769
                                   // Comment out for CR-20200318-13864
				   //membership.Institution_CRM_System__c = project.CMA_CRM_System__c;
                                   //membership.Institution_Perception_Use_of_Site_Data__c = project.Institution_Perception_Use_of_Site_Data__c;
			       	   //membership.Last_Case_Study__c = project.Date_LastCaseStudy__c; // CR-20200415-13952
                                   //membership.Last_Cohort_Summit_Attendance__c = project.Date_Last_Cohort_Summit_Attendance__c;
                                   
                                   //<!--Modified By Dipesh Gupta -CR-20190524-13152 - Date-06/14/2019 -->
                                   //membership.Last_Onsite__c = project.Date_Last_Onsite__c;
                                   
                                   //Commented By - Abhinav Sharma - 10/18/2014 - CR-20140221-4576 
                                   //membership.Last_Opportunity_Refresh__c = project.Opportunity_Refresh__c;
                                   
                                   //<!--Modified By Dipesh Gupta -CR-20190524-13152 - Date-06/14/2019 -->
                                   //membership.Last_Sponsor_Update__c = project.date_last_sponsor_update__c;
                                   
                                   //<!--Modified By Dipesh Gupta -CR-20190524-13152 - Date-06/14/2019 -->
                                   //membership.Last_Value_Summit__c = project.Last_Value_Summit__c;
                                   
                                   //membership.Launch_and_Onboarding_Planning_Actual__c = project.Launch_and_Onboarding_Planning__c;
                                   //membership.Launch_Onboarding_Planning_Projected__c = project.Launch_Onboarding_Planning_Projected__c;
                                   //membership.Licensed_Providers__c = project.CPM_Licensed_Providers__c;
                                   //membership.Next_Onsite_Target__c = project.Next_Onsite_Target__c;
                                   //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
                                   // membership.Next_Opportunity_Refresh_Target__c = project.Opportunity_Refresh_Target__c;
                                   //membership.Next_Sponsor_Update_Target__c = project.Next_Sponsor_Update_Target__c;
                                   //membership.Notes_Dedicated_Advisor__c = project.Notes_Dedicated_Advisor__c;
                                   //membership.Outreach_Plan_Development_Actual__c = project.Outreach_Plan_Development_Actual__c;
                                   //membership.Primary_Relationship_Risk_Category__c = project.Primary_Relationship_Risk_Category__c;
                                   //membership.PT_Member_Health__c = project.PT_Member_Health__c;
                                   //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
                                   //membership.Regular_Call_Schedule__c = project.Regular_Call_Schedule__c;
                                   //membership.Reference_Ambassador_Comments__c = project.Reference_Ambassador_Comments__c;
                                   //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
                                   //membership.Reference_Ready__c = project.Reference_Ready__c;
                                   //membership.Relationship_Trending__c = project.Relationship_Trending__c;
                                   //membership.ROI_Framework_Actual__c = project.ROI_Framework_Actual__c;
                                   //membership.ROI_Review_Actual__c = project.ROI_Review__c; // CR-20200415-13952
                                   //membership.ROI_Review_Target__c = project.ROI_Review_Target__c;
                                   //membership.Secondary_Relationship_Risk_Category__c = project.Relationship_Risk_Category_2__c;
                                   //Commented By Abhinav Sharma - 04/03/2014 - CR-20140220-4549
                                   //membership.Series_1_Initiatives_Activated_Actual__c = project.Series_1_Initiatives_Activated_Actual__c;
                                   //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
                                   // membership.Series_1_Initiatives_Activated_Target__c = project.Series_1_Initiatives_Activated_Target__c;
                                   //Commented By Abhinav Sharma - 04/03/2014 - CR-20140220-4549
                                   //membership.Series_1_Initiatives_Created_Actual__c = project.Series_1_Initiatives_Created_Actual__c;
                                   //membership.Series_1_Initiatives_Created_Target__c = project.Series_1_Initiatives_Created_Target__c;
                                   //Modified by Subhash Gharwal 04/29/2019 - Spring cleanup - CR-20190425-13035
                                   //membership.Service_Plan_Delivery_Actual__c = project.Service_Plan_Delivery_Actual__c;
                                   //membership.Service_Plan_Delivery_Projected__c = project.Service_Plan_Delivery_Projected__c;
                                   //membership.Value_Team__c = project.Value_Team__c;
                                   //membership.Value_Team_Comments__c = project.Value_Team_Comments__c;
                                   
                                   //Update the Membership record with
                                   membershipsMap.put(membership.Id, membership);
                               }
                               //Code commented - Bhavi Sharma - 06/28/2013 - CR-20130617-3170
                               /* else {
                                
                                throw new CustomException(Label.ERROR_ALREADY_PROJECT_ASSOCIATED);
                                }*/
                           }
                       }
                    
                    //Check for the old records
                    if(mapOldProjects != null && mapOldProjects.get(project.Id).Primary_Paid_Membership__c != null
                       && project.Primary_Paid_Membership__c != mapOldProjects.get(project.Id).Primary_Paid_Membership__c) {
                           
                           //Check if there membership do not have Primary_Project__c stamped on it
                           if(mapMemberships.containsKey(mapOldProjects.get(project.Id).Primary_Paid_Membership__c)) {
                               
                               //Get Membership object data
                               Membership__c ms = mapMemberships.get(mapOldProjects.get(project.Id).Primary_Paid_Membership__c);
                               
                               //Create membership instance
                               Membership__c membership = new Membership__c(Id = ms.Id);
                               
                               //Update the Membership record with
                               membership.Primary_Project__c = null;
                               membership.BA_Assignment2__c = null;
                               membership.DA_Assignment2__c = null;
                               
                               //CR-20140214-4520 - Remove following lines from code 
                               //Commented By Abhinav Sharma - 03-01-2014
                               //membership.Value_Pod__c = null;
                               //membership.Implementation_Pod__c = null;
                               membership.Delivery_Project_Phase__c = null;
                               membership.Relationship_Grade__c = null;
                               //membership.Relationship_Grade_Notes__c = null;
                               //membership.Realized_ROI__c = null; //CR-20200415-13952
                               //Modified by Subhash Gharwal 04/29/2019 - Spring cleanup - CR-20190425-13035  
                               membership.Site_Live__c = null;
                               //membership.Path_to_ROI_Grade__c = null;
                               //membership.Executive_Engagement_Grade__c = null;
                               //membership.Member_Expectations_Grade__c = null;
                               
                               //Code modified - Bhavi Sharma - CR-20130116-2186
                               //modified by Subhash Gharwal -29-04-2019 - Spring cleanup - CR-20190425-13035  
                               //membership.Active_Outreach_Program__c = null;
                               
                               //CR-20140220-4549 - Remove following lines from code 
                               //Commented By Abhinav Sharma - 03-04-2014
                               //membership.CMA_Initiative_Last_Updated__c  = null;
                               //Modified by Subhash Gharwal -29-04-2019 - Spring cleanup - CR-20190425-13035  
                               //membership.CRM_Usage__c  = null;
                               //membership.Goals_and_Work_Plan_Call_Actual__c = null;
                               //membership.Goals_and_Work_Plan_Call_Projected__c  = null;
                               //membership.Initial_Opp_Assessment_Actual__c  = null;
                               //membership.Initial_Opp_Assessment_Target__c  = null;
                               //membership.Initial_Value_Meeting_Projected__c  = null;
                               //membership.Initial_Value_Meeting_Actual__c  = null;
                               //membership.Initiatives_Series_1__c  = null;
                               //Modified By - Dipesh Gupta -  CR-20200218-13769
                               //membership.Institution_CRM_System__c  = null;
                               //membership.Institution_Perception_Use_of_Site_Data__c = null;
                               membership.Last_Case_Study__c  = null;
                               //membership.Last_Cohort_Summit_Attendance__c = null;
                               membership.Last_Onsite__c  = null;
                               //membership.Last_Opportunity_Refresh__c = null;
                               membership.Last_Sponsor_Update__c  = null;
                               //<!--Modified By Dipesh Gupta -CR-20190524-13152 - Date-06/14/2019 -->
                               //membership.Last_Value_Summit__c  = null;
                               //membership.Launch_and_Onboarding_Planning_Actual__c = null;
                               //membership.Launch_Onboarding_Planning_Projected__c  = null;
                               //membership.Licensed_Providers__c  = null;
                               //membership.Next_Onsite_Target__c  = null;
                               membership.Next_Opportunity_Refresh_Target__c = null;
                               membership.Next_Sponsor_Update_Target__c  = null;
                               //membership.Notes_Dedicated_Advisor__c  = null;
                               //membership.Outreach_Plan_Development_Actual__c  = null;
                               //membership.Primary_Relationship_Risk_Category__c  = null;
                               //membership.PT_Member_Health__c  = null;
                               membership.Regular_Call_Schedule__c  = null;
                               //membership.Reference_Ambassador_Comments__c  = null;
                               membership.Reference_Ready__c  = null;
                               //membership.Relationship_Trending__c  = null;
                               //membership.ROI_Framework_Actual__c  = null;
                               membership.ROI_Review_Actual__c  = null;
                               //membership.ROI_Review_Target__c  = null;
                               //membership.Secondary_Relationship_Risk_Category__c = null;
                               //membership.Series_1_Initiatives_Activated_Actual__c  = null;
                               membership.Series_1_Initiatives_Activated_Target__c  = null;
                               //Commented By Abhinav Sharma - 04/03/2014 - CR-20140220-4549
                               //membership.Series_1_Initiatives_Created_Actual__c  = null;
                               membership.Series_1_Initiatives_Created_Target__c  = null;
                               //Modified by Subhash Gharwal 04/29/2019 - Spring cleanup - CR-20190425-13035
                               //membership.Service_Plan_Delivery_Actual__c  = null;
                               //membership.Service_Plan_Delivery_Projected__c  = null;
                               //membership.Value_Team__c  = null;
                               //membership.Value_Team_Comments__c = null;
                               
                               //Update the Membership record with
                               membershipsMap.put(membership.Id, membership);
                           }
                       }
                    
                }
                //Update membership records
                if(membershipsMap.values().size() > 0) {
                    
                    //No need to execute any trigger
                    Util.BypassAllTriggers = true;
                    update membershipsMap.values();
                }
            }
        }
    }
    
    //This method is to update PT QA Call Event DT & PT QA Call Recommended Score fields on Project__c object - CR-20130408-2822
    public static void UpdateProjectByMembershipEvent(List<Project__c> listNewProjects, Map<Id, Project__c> mapOldProjects){
        
        //Set of Memberships associated with Project
        Set<Id> setMembershipIds = new Set<Id>();
        
        //Loop through the Trigger.new
        for(Project__c project : listNewProjects){
            
            //Check Project is data and execute the code only if require
            if(project.Primary_Paid_Membership__c != null ){
                
                //add membership into set
                setMembershipIds.add(project.Primary_Paid_Membership__c);
            }
        }
        
        //Check if there is any data to process
        if(setMembershipIds.size() >0){
            
            //Create map for Memebership with Event
            Map<Id,Event> mapMembershipWithEvent = new Map<Id,Event>();
            
            //get data from data base and loop through the results
            for(Event event : [SELECT StartDateTime, Cancelled_Did_Not_Occur__c, Would_Buy_Again__c, ActivityDate, WhatId
                               FROM Event
                               WHERE WhatId IN :setMembershipIds
                               AND RecordType.DeveloperName =: Constants.RECORD_TYPE_EVENT_DEVELOPER_NAME_BI_QA_CALL
                               AND Cancelled_Did_Not_Occur__c = false AND StartDateTime < Last_N_Days:364]){
                                   
                                   //Check Same membership hold event
                                   if(mapMembershipWithEvent.containsKey(event.WhatId)) {
                                       
                                       //Event instance get from map
                                       Event existingEvent = mapMembershipWithEvent.get(event.WhatId);
                                       
                                       //Check most recent event
                                       if(event.StartDateTime > existingEvent.StartDateTime) {
                                           
                                           //put Id = Membership , Key = Event Record
                                           mapMembershipWithEvent.put(event.WhatId, event);
                                       }
                                   } else {
                                       
                                       //put Id = Membership , Key = Event Record
                                       mapMembershipWithEvent.put(event.WhatId, event);
                                   }
                               }
            
            //Loop through trigger.new
            for(Project__c project : listNewProjects){
                
                //Check map is already contains the membership associate with project
                if(project.Primary_Paid_Membership__c != null && mapMembershipWithEvent.containsKey(project.Primary_Paid_Membership__c)) {
                    
                    //Get event
                    Event event = mapMembershipWithEvent.get(project.Primary_Paid_Membership__c);
                    
		    //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
                    //Check event's Start Date Time
                    //project.PT_QA_Call_Event_DT__c = event.StartDateTime;
                    
                    //Check event's Would Renew
                    //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 & CR-20200318-13864 - Project field deletions - references
                    /*if(event.Would_Buy_Again__c != null && event.Would_Buy_Again__c != '' && event.Would_Buy_Again__c.isNumeric()) {
                        
                        //assigning event's field Would renew value to Project
                        project.PT_QA_Call_Recommended_Score__c = Integer.valueOf(event.Would_Buy_Again__c);
                    } else{
                        
                        //Set null
                        project.PT_QA_Call_Recommended_Score__c = null;
                    }*/
                }
            }
        }
    }
    
    //Code modified - Bhavi Sharma - CR-20130116-2186
    //Boolean method for comparison of project data to its previous data
    public static Boolean isChanged(Project__c newProject, Project__c oldProject){
        
        //CR-20140214-4520 - Remove following lines from code -  || newProject.EHBI_Value_Pod__c != oldProject.EHBI_Value_Pod__c 
        //CR-20140220-4549 - Remove following lines from code - || newProject.CMA_Initiative_Last_Updated__c != oldProject.CMA_Initiative_Last_Updated__c
        //Specified condition removed from If statement By Abhinav Sharma - 03-01-2014
        //Removed By Abhinav Sharma - 04/03/2014 - CR-20140220-4549
        //|| newProject.Series_1_Initiatives_Activated_Actual__c != oldProject.Series_1_Initiatives_Activated_Actual__c
        //|| newProject.Series_1_Initiatives_Created_Actual__c != oldProject.Series_1_Initiatives_Created_Actual__c 
        //Check for newProject data is not equal to oldProject data
        //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
        if(newProject.Primary_Paid_Membership__c != oldProject.Primary_Paid_Membership__c
           || newProject.Project_Phase__c != oldProject.Project_Phase__c
           /*|| newProject.Implementation_Business_Analyst__c != oldProject.Implementation_Business_Analyst__c*/
           /*|| newProject.Recurring_Business_Analyst__c != oldProject.Recurring_Business_Analyst__c*/
           || newProject.Dedicated_Advisor__c != oldProject.Dedicated_Advisor__c
           || newProject.Project_Phase__c != oldProject.Project_Phase__c
           || newProject.Relationship_Grade__c != oldProject.Relationship_Grade__c
           || newProject.Relationship_Grade_Notes__c != oldProject.Relationship_Grade_Notes__c
           /*|| newProject.Realized_ROI__c != oldProject.Realized_ROI__c*/ //CR-20200415-13952
           || newProject.Date_Site_Live__c != oldProject.Date_Site_Live__c
           /*|| newProject.Initial_Opp_Assessment_Projected_Target__c != oldProject.Initial_Opp_Assessment_Projected_Target__c*/
           /*|| newProject.Date_LastCaseStudy__c != oldProject.Date_LastCaseStudy__c*/ //CR-20200415-13952
           
           //<!--Modified By Dipesh Gupta -CR-20190524-13152 - Date-06/14/2019 -->
           //|| newProject.Date_Last_Onsite__c != oldProject.Date_Last_Onsite__c
           
           //Commented By Abhinav Sharma - 10/18/2014 - CR-20140221-4576
           //|| newProject.Opportunity_Refresh__c != oldProject.Opportunity_Refresh__c
           
           //<!--Modified By Dipesh Gupta -CR-20190524-13152 - Date-06/14/2019 -->
           //|| newProject.date_last_sponsor_update__c != oldProject.date_last_sponsor_update__c
           /*|| newProject.Next_Onsite_Target__c != oldProject.Next_Onsite_Target__c*/
           /*|| newProject.Opportunity_Refresh_Target__c != oldProject.Opportunity_Refresh_Target__c*/
           /*|| newProject.Next_Sponsor_Update_Target__c != oldProject.Next_Sponsor_Update_Target__c*/
           || newProject.Notes_Dedicated_Advisor__c != oldProject.Notes_Dedicated_Advisor__c
           /*|| newProject.Regular_Call_Schedule__c != oldProject.Regular_Call_Schedule__c*/
           /*|| newProject.Reference_Ready__c != oldProject.Reference_Ready__c*/
           /*|| newProject.ROI_Review__c != oldProject.ROI_Review__c*/ //CR-20200415-13952
           /*|| newProject.ROI_Review_Target__c != oldProject.ROI_Review_Target__c*/
           /*|| newProject.Series_1_Initiatives_Activated_Target__c != oldProject.Series_1_Initiatives_Activated_Target__c*/
           /*|| newProject.Series_1_Initiatives_Created_Target__c != oldProject.Series_1_Initiatives_Created_Target__c*/){
               
               return true;
           } else {
               
               return false;
           }
    }
    
    //Bhavi Sharma - 05/31/2013 - CR-20130328-2773
    //This method is to pull the "Source Contract Type" and "Special Committments" data from current renewal opportunities
    //and will stamp these values on Project object in "Current Contract Risk Type" and "Special Considerations" fields
    //Current renewal opportunity will be idestified with opportunties related to PPM(Primary Paid Membership) on Project
    public static void updateProjectByCurrentRenewalOpportunity(List<Project__c> projects) {
        
        //Create a set of membership ids
        Set<Id> membershipIds = new Set<Id>();
        
        //Loop through the project data and create a set of membership records
        for(Project__c project : projects) {
            
            //Check if PPM is not null on record
            if(project.Primary_Paid_Membership__c != null) {
                
                //Add in set
                membershipIds.add(project.Primary_Paid_Membership__c);
            }
        }
        
        //Check for the size and process results
        if(membershipIds.size() > 0) {
            
            //String to hold teh current yeat
            String currentYear = String.valueOf(Date.today().year());
            
            //Create a map to hold teh Membership with Current renewal opportunities
            Map<Id, Opportunity> mapMembershipWithOpportunity = new Map<Id, Opportunity>();
            
            //Query all the opporutnity records related to membership
            for(Opportunity opportunity : [Select Id, Membership__c, Pool_Year__c, Pool_Date__c, Source_Contract_Type__c, Special_Commitments__c from Opportunity where
                                           Membership__c IN: membershipIds
                                           AND (
                                               Pool_Year__c =: currentYear
                                               OR (Pool_Date__c > TODAY AND Pool_Date__c < NEXT_N_QUARTERS:2)
                                               OR (IsClosed = false AND Pool_Date__c < TODAY AND Pool_Date__c > LAST_N_QUARTERS:4)
                                           )
                                          ]) {
                                              
                                              //Add opportunity record in map if not already exists
                                              if(mapMembershipWithOpportunity.containsKey(opportunity.Membership__c)) {
                                                  
                                                  //Get opportunity data from Map
                                                  Opportunity existingOpportunity = mapMembershipWithOpportunity.get(opportunity.Membership__c);
                                                  
                                                  //1. Check if existingOpportunity is in current Year, no need to do anything then
                                                  //2. existingOpportunity is not in current Year, but current opportunity is, replace the Opportunity record
                                                  //3. existingOpportunity is in Next 2 Quaters, no need to do anythin
                                                  //4. existingOpportunity is not in Next 2 quarters, but current opportunity is, replace the Opportunity record
                                                  //5. No need to change existingOpportunity record as thsi will be from Last 4 quarters already
                                                  if(existingOpportunity.Pool_Year__c == currentYear) {
                                                      
                                                      //move to next record
                                                      continue;
                                                  } else if(opportunity.Pool_Year__c == currentYear) {
                                                      
                                                      //replace opportunity record in map
                                                      mapMembershipWithOpportunity.put(opportunity.Membership__c, opportunity);
                                                  } else if(existingOpportunity.Pool_Date__c > Date.today()) {
                                                      
                                                      //move to next record
                                                      continue;
                                                  } else if(opportunity.Pool_Date__c > Date.today()) {
                                                      
                                                      //replace opportunity record in map
                                                      mapMembershipWithOpportunity.put(opportunity.Membership__c, opportunity);
                                                  }
                                              } else {
                                                  
                                                  //Add opportunity in map
                                                  mapMembershipWithOpportunity.put(opportunity.Membership__c, opportunity);
                                              }
                                          }
            
            //Loop through the project records
            for(Project__c project : projects) {
                
                //Check if Membership is not null
                if(project.Primary_Paid_Membership__c != null && mapMembershipWithOpportunity.containsKey(project.Primary_Paid_Membership__c)) {
                    
                    //Populate data from opportunity's "Source Contract Type" and "Special Committments" fields to project's "Current Contract Risk Type" and "Special Considerations"
                    project.Current_Contract_Risk_Type__c = mapMembershipWithOpportunity.get(project.Primary_Paid_Membership__c).Source_Contract_Type__c;
                    //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
                    //project.CPM_Special_Considerations__c = mapMembershipWithOpportunity.get(project.Primary_Paid_Membership__c).Special_Commitments__c;
                }
            }
        }
    }
    
    //Removed the method - UpdateSiteIssueByProject
    
    //Added by Rajeevjain - CR-20180504-12211 - 08/23/2018. - Avoid execution for APS Deployment
    //Modified By - Ajit Surana - 09/08/2014 - CR-20140716-6256 - Exclude Project Record Type "SSC" from this method
    //Added By - Abhinav Sharma - 03-03-2014 - CR-20130829-3543 - CMA - Elapsed Time Field - Moved to Prod Team
    //Modified By - Abhinav Sharma -  04/29/2014 - CR-20140403-4958 - Site Live - Target, Actual - not completed with 3968
    //Modified By - Abhinav Sharma - 11/25/2014 - CR-20141106-8010 - Revert change to Site Live field on SSC projects
    /**
    *  @description    :   Method to set First_Deployment_Signed_Off__c field on the Project with the earliest value from the "Deployment Sign Off (Actual)" field on 
    *                      the associated Deployment record whenever the project record is updated.
    *
    *  @args           :   List of projects
    *
    *  @return         :   void
    *
    **/
    public static void populateFirstDeploymentSignedOff(List<Project__c> newProjects) {
        
        //Set to hold the project ids
        Set<Id> setProjectIds = new Set<Id>();
        
        //Loop through project records
        for(Project__c pro : newProjects)
            setProjectIds.add(pro.Id);
        
        //Chech set size before executing the further logic
        if(setProjectIds.size() == 0)
            return;
        
        //Map of Projects
        Map<Id, Project__c> mapProjects = new Map<Id, Project__c>();
        
        //Modified By - Ajit Surana - CR-20140716-6256 - 09/08/2014 - Added an extra filter of Record Type not equal to 'SSC'
        //Modified By - Abhinav Sharma - 11/25/2014 - CR-20141106-8010 - Removed filter of record type not equals to 'SSC'    
        //Querying project record with the oldest value from the "Deployment Sign Off (Actual)" field on the associated Deployment record     
        //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
        for(Project__c project : [SELECT Id, /*First_Deployment_Signed_Off__c,*/ Date_Site_Live__c, /*Site_Live_Target__c,*/ RecordTypeId,  RecordType.DeveloperName,
                                  (SELECT Id, C_A_DC__c, C_E_DC__c FROM Deployments__r 
                                   WHERE C_A_DC__c != null ORDER BY C_A_DC__c ASC LIMIT 1)
                                  FROM Project__c WHERE Id IN : setProjectIds]) {
                                      
                                      //Only Process the record if found and
                                      if(project.Deployments__r.size() > 0) {
                                          
                                          //Add record in the list to be updated
                                          //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
                                          //project.First_Deployment_Signed_Off__c = project.Deployments__r[0].C_A_DC__c;
                                          
                                          //Added by Rajeevjain - CR-20180504-12211 - 08/23/2018. - Avoid execution for APS Deployment
                                          //Modified By Dipesh Gupta - 09/26/2019 - CR-20190529-13156 - APS replaced by Tech (SSC) as per Taylor Chatter
                                          //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
                                          if(project.RecordType.DeveloperName != 'SSC')
                                              project.Date_Site_Live__c = project.Deployments__r[0].C_A_DC__c;
                                          //project.Site_Live_Target__c = project.Deployments__r[0].C_E_DC__c;
                                          
                                          //Adding record back into newMap values
                                          mapProjects.put(project.ID, project);
                                          
                                      } 
                                  }
        
        //Modified By - Ajit Surana - CR-20140716-6256 - 09/08/2014 - Added an extra filter of Record Type not equal to 'SSC'
        //Modified By - Abhinav Sharma - 11/25/2014 - CR-20141106-8010 - Removed filter of record type not equals to 'SSC'   
        //Populating map with oldest Deployment Sign Off(Expected) field value in case when no deployment record will have Deployment Sign Off (Actual) field populated with them
        //Querying project record with the oldest value from the "Deployment Sign Off (Actual)" field on the associated Deployment record     
        //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
        for(Project__c project : [SELECT Id, /*First_Deployment_Signed_Off__c,*/ Date_Site_Live__c, /*Site_Live_Target__c,*/ RecordTypeId, RecordType.DeveloperName,  
                                  (SELECT Id, C_A_DC__c, C_E_DC__c FROM Deployments__r 
                                   WHERE C_E_DC__c != null ORDER BY C_E_DC__c ASC LIMIT 1)
                                  FROM Project__c WHERE Id IN : setProjectIds AND ID NOT IN : mapProjects.keySet()]) {
                                      
                                      //Only Process the record if found and
                                      if(project.Deployments__r.size() > 0) {
                                          
                                          //Add record in the list to be updated
                                          //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
                                          //project.First_Deployment_Signed_Off__c = project.Deployments__r[0].C_A_DC__c;
                                          
                                          //Added by Rajeevjain - CR-20180504-12211 - 08/23/2018. - Avoid execution for APS Deployment
                                          //Modified By Dipesh Gupta - 09/26/2019 - CR-20190529-13156 - APS replaced by Tech (SSC) as per Taylor Chatter
                                          //Modified By Mahendra Swarnkar - 04/02/2020 - CR-20191204-13551
                                          //if(project.RecordType.DeveloperName != 'SSC')
                                              project.Date_Site_Live__c = project.Deployments__r[0].C_A_DC__c;
                                         //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
                                         // project.Site_Live_Target__c = project.Deployments__r[0].C_E_DC__c;
                                          
                                          //Adding record back into newMap values
                                          mapProjects.put(project.ID, project);
                                      }   
                                  }
        
        //Call method to get the Record type Info.
        //Modified By Dipesh Gupta - 09/26/2019 - CR-20190529-13156 - APS replaced by Tech (SSC) as per Taylor Chatter
        Id APS_RECORDTYPE_ID = Util.RecordTypeId('Project__c', PROJECT_SSC_RECORD_TYPE_LABEL_NAME);
        
        //Loop through project records        
        for(Project__c proj : newProjects) {
            //Checking for value in the map
            if(mapProjects.containsKey(proj.Id)) {
                //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
                //proj.First_Deployment_Signed_Off__c = mapProjects.get(proj.Id).First_Deployment_Signed_Off__c;
                
                //Added by Rajeevjain - CR-20180504-12211 - 08/23/2018. - Avoid execution for APS Deployment
                //Check for the record type ids 
                if(proj.RecordTypeId != APS_RECORDTYPE_ID)
                    proj.Date_Site_Live__c = mapProjects.get(proj.Id).Date_Site_Live__c; 
                //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
                //proj.Site_Live_Target__c = mapProjects.get(proj.Id).Site_Live_Target__c;
            } else {
                //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
                //proj.First_Deployment_Signed_Off__c = null;
                
                //Added by Rajeevjain - CR-20180504-12211 - 08/23/2018. - Avoid execution for APS Deployment
                //Check for the record type ids 
                if(proj.RecordTypeId != APS_RECORDTYPE_ID)
                    proj.Date_Site_Live__c = null; 
                //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
                //proj.Site_Live_Target__c = null;
            }       
        }
    }
    
    //Added By - Ajit Surana - 09/08/2014 - CR-20140513-5475
    /*public static Integer calculateLastDayOfMonth(Project__c project){

    //Variables helpful in calculation
    Integer sumOfDates = 0;
    Integer loadFrequency = 0;
    Integer lastDayOfMonth;
    
    //Checking & validating field value for blank/null value
    if(project.Current_Data_Period_New__c != null && String.isNotBlank(project.Data_Lag_Month__c)) {
    
    //Making calculation for "Load Frequency" field 
    If(project.Load_Frequency__c == 'Monthly')
    loadFrequency = 1;
    else if(project.Load_Frequency__c == 'Quarterly')
    loadFrequency = 3;
    else
    loadFrequency = 0;
    
    
    //Variable to hold the intermediate calculations for fields
    sumOfDates = project.Current_Data_Period_New__c.month() + Integer.valueOf(project.Data_Lag_Month__c) + loadFrequency;
    
    //Calculation for getting last day of the month based on the other fields value
    lastDayOfMonth = (Date.newinstance((project.Current_Data_Period_New__c.year() + sumOfDates/12), (Math.mod(sumOfDates, 12)+1), 1) - 1).day();
    }
    
    return lastDayOfMonth;
    }*/
    
    //Added By - Abhinav Sharma - 10/17/2014 - CR-20140826-7138
    /**
    *  @description    :   Method is used to autopopulate the Deployment Sign-Off (Oldest) field on Project when a related Deployment record is 
    *                      created/updated/deleted and the Project's Record Type = "RCS".
    *                          1)  "Deployment Sign-Off (Oldest)" should be automatically updated to the oldest Deployment Sign Off (Actual) date.
    *
    *  @args           :   List of deployments, Map of old Deployments
    *
    *  @return         :   void
    *
    **/
        /*public static void populateDeploymentSignOffOldest(List<Project__c> newProjects, Map<Id, Project__c> mapOldProjects) {
    
    //Set to hold Project Id of Deployment record
    Set<Id> projectIds = new Set<Id>();
    
    //Query result of RCS record Type of Project sobject
    Id rcsRecordTypeId = [Select Id FROM RecordType WHERE SobjectType = 'Project__c' AND DeveloperName = 'RCS' AND IsActive = true].Id;
    
    //Map to hold key=> ProjectId & value=> instance of Project sobject
    Map<Id, Project__c> mapProjectToBeUpdated = new Map<Id, Project__c>();
    
    if(rcsRecordTypeId != null) {
    
    //Loop through Trigger.new
    for(Project__c newProject : newProjects) {
    
    //Check if Project is update on Deployment from previous
    if(newProject.RecordTypeId == rcsRecordTypeId && mapOldProjects != null 
    && newProject.Deployment_Sign_Off_Oldest__c != mapOldProjects.get(newProject.Id).Deployment_Sign_Off_Oldest__c)
    projectIds.add(newProject.Id);
    }
    }
    
    /*if(projectIds.size() > 0)
    mapProjectToBeUpdated = DeploymentTriggerHelper.getRCSProjectToUpdate(projectIds);
    
    //update the Projects with their "Deployment Sign-Off (Oldest)"
    if(mapProjectToBeUpdated.size() > 0)
    update mapProjectToBeUpdated.values();
    }*/
    
    //V_1.31 - Modified By - Dipesh Gupta - 08/12/2017 - CR-20170426-10878 
    //Modified By - Abhinav Sharma - 06/02/2017 - DS114
    //Added By - Abhinav Sharma - 06/13/2015 - CR-20150601-8976
    /**
    *  @description    :   Method to validate and then populate fields on project records. (On before events)
    * 
    *  @args           :   List of projects
    *
    *  @return         :   void
    *
    **/
    public static void validateAndPopulateProjectFields(List<Project__c> projects, map<Id, Project__c> oldMapProject) {
        
        //V_1.31 - Modified By Dipesh Gupta - CR-20170426-10878 - 08/17/2017 -- Stats Here-- also get Project record type (CCA, CMA, CMGA, CostOps, HP Consumer Scheduling, iRound or RCS)
        //V_1.28 - Merged By - Rajeev Jain - 07/05/2017(In order of migration tasks of - Releases after Q2CDev3 sandbox refresh date[04/07/2017] in Q2CDev3 sandbox from Test sandbox in order to sync with Q2c Beta Release and Revenue Management
        //Map of project record types'
        //Modified By - Abhinav Sharma - 06/17/2020 - CR-20200318-13867 - Project Page Layout and RT deletions
        Map<Id, RecordType> mapRecordTypes = new Map<Id, RecordType>([SELECT ID, DeveloperName FROM RecordType 
                                                                      WHERE sObjectType = 'Project__c'
                                                                      AND IsActive = true
                                                                      /*AND DeveloperName IN ('CMA', 'Talent_Development', 'CCA', 'CPM', 'CostOps', 'HP_Consumer_Scheduling', 'iRound','RCS')*/
                                                                      ORDER BY DeveloperName ASC]);
        
        //Project CMA RecordType Id
        ID rTypeIdProject_CMA;
        
        //Project Talent_Development RecordType Id
        ID rTypeIdProject_TalentDevelopment;
        
        //Check for size
        if(mapRecordTypes.size() > 0){
            
            //loop over Record type records
            for(RecordType rType : mapRecordTypes.values()) {
                
                //Checck for CMA record type Then populate the rTypeIdProject_CMA
                //Modified By - Abhinav Sharma - 06/17/2020 - CR-20200318-13867 - Project Page Layout and RT deletions
                /*if(rType.DeveloperName == 'CMA')
                    rTypeIdProject_CMA = rType.Id;*/
                
                //Checck for Talent_Development record type Then populate the rTypeIdProject_TalentDevelopment
               /* if(rType.DeveloperName == 'Talent_Development')
                    rTypeIdProject_TalentDevelopment = rType.Id;*/
            }
        }
        
        //Set to hold the Account Id.
        Set<Id> setAccountIds = New Set<Id>();
        
        //Set to hold the Account Id.
        Set<Id> setMembershipIds = New Set<Id>();
        
        //Getting the Accounnt(Institution) and Primary Paid Memberships Id
        for(Project__c proj : projects) {  
            
            if(mapRecordTypes.size() > 0 
               && mapRecordTypes.containsKey(proj.RecordTypeId)
               && proj.RecordTypeId != rTypeIdProject_TalentDevelopment
              ) {
                  //Check for Account on the Project
                  if(proj.Institution__c != null)
                      setAccountIds.add(proj.Institution__c);
                  
                  //Check for Account on the Project
                  if(proj.Primary_Paid_Membership__c != null)
                      setMembershipIds.add(proj.Primary_Paid_Membership__c);
              }
        }
        
        //Map to hold the related Account of Project
        Map<Id, Account> mapOfProjectRelatedAccount = new Map<Id, Account>();
        
        //Check for size
        if(setAccountIds.size() > 0 ){
            
            //Query on the Account(institutions)
            for(Account acc : [SELECT Id, Number_of_Hospitals_in_System__c 
                               FROM Account 
                               WHERE Id IN : setAccountIds]
               ) {
                   //populate the map of account
                   mapOfProjectRelatedAccount.put(acc.Id, acc);
               }
        }
        
        
        //Map to hold the Memberships 
        Map<Id, Membership__c> mapOfProjectRelatedMembership = new Map<Id, Membership__c>();
        
        //Check for size
        if(setMembershipIds.size() > 0 ){
            
            //Query on the membership
            for(Membership__c mem : [SELECT Id, Membership_Status_Text__c, Active_Contract_Annual_Contract_Value__c 
                                     FROM Membership__c 
                                     WHERE Id IN : setMembershipIds]
               ) {
                   //populate the map of Membership  
                   mapOfProjectRelatedMembership.put(mem.Id, mem);
               }
        }
        //V_1.31 - Modified By Dipesh Gupta - CR-20170426-10878 - 08/17/2017 ---- Ends here -----
        
        //Set to dedicated advisors
        Set<Id> setOfDedicatedAdvisors = new Set<Id>();
        Set<Id> setOfImplementationBusinessAnalysts = new Set<Id>();
        //V_1.28 - Merged By - Rajeev Jain - 07/05/2017 - Upto Here
        
        //Loop through project records
        for(Project__c proj : projects) {
            
            //V_1.28 - Merged By - Rajeev Jain - 07/05/2017(In order of migration tasks of - Releases after Q2CDev3 sandbox refresh date[04/07/2017] in Q2CDev3 sandbox from Test sandbox in order to sync with Q2c Beta Release and Revenue Management
            //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
            /*if(proj.Implementation_Business_Analyst__c != null)
                setOfImplementationBusinessAnalysts.add(proj.Implementation_Business_Analyst__c);*/
            
            if(proj.Dedicated_Advisor__c != null)
                setOfDedicatedAdvisors.add(proj.Dedicated_Advisor__c);
            //V_1.28 - Merged By - Rajeev Jain - 07/05/2017 - Upto Here
            
            //Checking set for it's size
            Map<Id, User> mapOfUsers = new Map<Id, User>();
            
            //Checking set for it's size
            if(setOfImplementationBusinessAnalysts.size() > 0 || setOfDedicatedAdvisors.size() > 0) {
                
                //temp set
                Set<Id> tempSet = new Set<Id>();
                
                if(setOfImplementationBusinessAnalysts.size() > 0)
                    tempSet.addAll(setOfImplementationBusinessAnalysts);
                
                if(setOfDedicatedAdvisors.size() > 0)
                    tempSet.addAll(setOfDedicatedAdvisors);
                
                mapOfUsers = new Map<Id, User>([SELECT ID, Alias
                                                FROM User
                                                WHERE ID IN : tempSet]);
            }
            
            //Check for the "Project Phase" field for null value
            if(!String.isNotBlank(proj.Project_Phase__c) 
               && proj.Project_Phase__c == System.Label.PROJECT_7_PHASE_VALUE_STREAM) {
                   
                   //Checking for Dedicated_Advisor__c field reference
                   /*if(proj.Dedicated_Advisor__c != null && mapOfUsers.containsKey(proj.Dedicated_Advisor__c))
                       proj.Primary_Owner__c = mapOfUsers.get(proj.Dedicated_Advisor__c).Alias;
                   else
                       proj.Primary_Owner__c = '';*/
                   
               } else {
                   
                   //Checking for Implementation_Business_Analyst__c field reference
                   //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
                   /*if(proj.Implementation_Business_Analyst__c != null && mapOfUsers.containsKey(proj.Implementation_Business_Analyst__c))
                       proj.Primary_Owner__c = mapOfUsers.get(proj.Implementation_Business_Analyst__c).Alias;
                   else
                       proj.Primary_Owner__c = '';  */ 
               }
            //V_1.28 - Merged By - Rajeev Jain - 07/05/2017 - Upto Here
            
            //V_1.31 - Modified By Dipesh Gupta - CR-20170426-10878 - 08/17/2017 - Populating project fields-- Stats Here--
            //Check if map contains record type.
            if(mapRecordTypes.size() > 0 
               && mapRecordTypes.containsKey(proj.recordTypeId)
               && proj.recordTypeId != rTypeIdProject_TalentDevelopment
              ) {
                  
                  //check if map contains membership Id
                  if(proj.Primary_Paid_Membership__c != null
                     && mapOfProjectRelatedMembership.size() > 0
                     && mapOfProjectRelatedMembership.containsKey(proj.Primary_Paid_Membership__c)
                     && mapOfProjectRelatedMembership.get(proj.Primary_Paid_Membership__c) != null
                    ) {
                        //Filling Project Fileds according to their parent account or m,embership fields
                        proj.Annual_Contract_Value__c = mapOfProjectRelatedMembership.get(proj.Primary_Paid_Membership__c).Active_Contract_Annual_Contract_Value__c;
                    }
                  
                  //Check If Member contains institution
                  if(proj.Institution__c != null
                     && mapOfProjectRelatedAccount.size() > 0
                     && mapOfProjectRelatedAccount.containsKey(proj.Institution__c)
                     && mapOfProjectRelatedAccount.get(proj.Institution__c) != null
                    ) {
                        
                        //proj.Number_of_Hospitals__c   = mapOfProjectRelatedAccount.get(proj.Institution__c).Number_of_Hospitals_in_System__c;  
                    }
              }
            
            //Update usecase
            //Check if Notes: Dedicated Advisor field chnged 
            if(oldMapProject != null && proj.Notes_Dedicated_Advisor__c != oldMapProject.get(proj.id).Notes_Dedicated_Advisor__c) {
                
                //Update the value as today.
                //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
                //proj.Notes_Updated_Date__c = Date.Today();
            }
        }
    }
    
    //upto here
    
    //Added By - - Mahedra Swarnkar - 07/05/2016 - CR-20160229-9651 - to populate case fields from Project
    /**
    *  @description    :   Method to populate the Cases object fields from Projects.
    * 
    *  @args           :   List of projects, map of old projects
    *
    *  @return         :   void
    *
    **/
    public static void populateCaseFieldsFromProject(List<Project__c> newProjects, Map<Id, Project__c> mapOldProjects) {
        
        //Set to hold the eligible Projects
        Set<Id> setProjectIds = new Set<Id>();
        
        
        //Populate the setProjectIds
        for(Project__c proj : newProjects) {
            
            //Check the conditions
            //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
            if(mapOldProjects == null 
               ||(  mapOldProjects != null 
                  && ( 
                      proj.Dedicated_Advisor__c != mapOldProjects.get(proj.Id).Dedicated_Advisor__c
                      /*|| proj.Contract_Start_Date__c != mapOldProjects.get(proj.Id).Contract_Start_Date__c*/
                      /*|| proj.Internal_Strat_Session_NPI_Actual__c != mapOldProjects.get(proj.Id).Internal_Strat_Session_NPI_Actual__c*/
                      || proj.Name != mapOldProjects.get(proj.Id).Name
                  )
                 )
              ) {
                  setProjectIds.add(proj.Id);
              }
        }
        
        if(setProjectIds.size() > 0) {
            Map<Id, Case> mapCase = new Map<Id, Case>([Select Id, 
                                                       //Spring Clean Up - RM__c, 
                                                       DA__c, Associate__c, 
                                                       //Spring Clean up
                                                       //No_of_Participants__c, 
                                                       //Cohort_ID__c, 
                                                       //Half_Day_or_Full_Day__c, Contract_Service_Start__c, 
                                                       //Spring Clean Up
                                                       //Contract_Service_End__c,  Service_Start__c, 
                                                       Project_Source_MS__c,
                                                       //Project_Source_MS__r.Membership_Advisor_Relationship_Manager__r.Name, 
                                                       Project_Source_MS__r.Dedicated_Advisor__r.Name, 
                                                       //Project_Source_MS__r.Program_Associate__r.Name,
                                                       /*Project_Source_MS__r.No_of_Participants__c, 
                                                       Project_Source_MS__r.Cohort_ID_s__c,  Project_Source_MS__r.X1_2_Day__c, 
                                                       Project_Source_MS__r.Full_Day__c, Project_Source_MS__r.Contract_Start_Date__c,
                                                       /*Project_Source_MS__r.Internal_Strat_Session_NPI_Actual__c, Project_Source_MS__r.Service_Date_Start__c,*/
                                                       Project_Source_MS__r.Name 
                                                       //Contract__c, Contract__r.End__c
                                                       From Case Where Project_Source_MS__c != null and Project_Source_MS__c IN : setProjectIds]);
            if(mapCase != null && mapCase.values() != null && mapCase.values().size() > 0 ) {
                
                //List of cases to be updated
                List<Case> listCaseToBeUpdate = new List<Case>();
                for(Case tdCas : mapCase.values()) {
                    
                    if(tdCas.Project_Source_MS__c != null) {
                        
                        //Populate the Case fields
                        //Spring Clean Up - tdCas.RM__c = tdCas.Project_Source_MS__r.Membership_Advisor_Relationship_Manager__r.Name;
                        tdCas.DA__c = tdCas.Project_Source_MS__r.Dedicated_Advisor__r.Name;
                        //tdCas.Associate__c = tdCas.Project_Source_MS__r.Program_Associate__r.Name;
                        
                        //tdCas.Contract_Service_Start__c = tdCas.Project_Source_MS__r.Contract_Start_Date__c;
                        //tdCas.Contract_Service_End__c = tdCas.Project_Source_MS__r.Internal_Strat_Session_NPI_Actual__c;
                        
                        /* Spring CleanUp
                        if(tdCas.Contract__c != null && tdCas.Contract__r.End__c != null)
                        tdCas.Project_Year__c =  tdCas.Project_Source_MS__r.Name + ' - ' + tdCas.Contract__r.End__c.year();
                        else
                        tdCas.Project_Year__c =  tdCas.Project_Source_MS__r.Name + ' - ' + 'null';
                        */    
                        listCaseToBeUpdate.add(tdCas);
                    }
                    else{
                        
                        //Populate the case fields to default values.
                        //Spring Clean Up - tdCas.RM__c = null;
                        tdCas.DA__c = null;
                        tdCas.Associate__c = null;
                        //Spring Clean Up
                        //tdCas.No_of_Participants__c = null;
                        //tdCas.Cohort_ID__c = null;
                        //tdCas.Half_Day_or_Full_Day__c = null;
                        //tdCas.Contract_Service_Start__c = null;
                        //Spring Clean Up
                        //tdCas.Contract_Service_End__c = null;
                        //tdCas.Service_Start__c = null;
                        /*Spring CleanUp
                        if(tdCas.Contract__c != null && tdCas.Contract__r.End__c != null)
                        tdCas.Project_Year__c =  'null - ' + tdCas.Contract__r.End__c.year();
                        else
                        tdCas.Project_Year__c =  'null - null';
                        */
                    }
                }
                
                if(listCaseToBeUpdate.size() > 0 ) {
                    Util.byPassAllTriggers = true;
                    update listCaseToBeUpdate;
                    Util.byPassAllTriggers = false;
                }   
            }
        }
    }
    
    //Added By - Mahendra Swarnakar - CR-20161110-10358 - 12/10/2016
    /**
    * @Description    :   Method to have the logic related to milestone tasks creation for project records.
    *            
    * @args           :   List<Project__c> 
    *
    * @return         :   void
    * 
    **/
    public static void createDeliveryMilestoneTasksOnproject(List<Project__c> newProjects) {
        
        //Check for list
        if(newProjects != null) {
            
            //list of tasks
            List<Task> tasksToBeInserted = new List<Task>();
            
            //Map of custom metadata type records
            Map<String, List<Delievery_Milestones_Task__mdt>> mapOfMilestonesMetadataTypes = new Map<String, List<Delievery_Milestones_Task__mdt>>();
            
            //Retriveing custom metadata type records and populating collection with the help of it.
            for(Delievery_Milestones_Task__mdt dMT : [SELECT Id, DeveloperName, MasterLabel, Due_Date_After__c, 
                                                      IsActive__c, Milestone_Field_API_Name__c, Object_API_Name__c,
                                                      Record_Type_API_Name__c, Task_Subject__c 
                                                      FROM Delievery_Milestones_Task__mdt 
                                                      WHERE Object_API_Name__c ='Project__c'
                                                      AND Record_Type_API_Name__c != null
                                                      AND Record_Type_API_Name__c != ''
                                                      AND IsActive__c = true
                                                      AND Milestone_Field_API_Name__c != null
                                                      AND Milestone_Field_API_Name__c != ''
                                                      AND Task_Subject__c != null
                                                      AND Task_Subject__c != ''
                                                      AND Due_Date_After__c != null
                                                     ]) {
                                                         
                                                         //Populating map with "Object API Name - Record Type API Name" key and corresponding records list as value
                                                         if(mapOfMilestonesMetadataTypes.containsKey(dMT.Object_API_Name__c + ' ' + dMT.Record_Type_API_Name__c))
                                                             mapOfMilestonesMetadataTypes.get(dMT.Object_API_Name__c + ' ' + dMT.Record_Type_API_Name__c).add(dMT);
                                                         else
                                                             mapOfMilestonesMetadataTypes.put(dMT.Object_API_Name__c + ' ' + dMT.Record_Type_API_Name__c, new List<Delievery_Milestones_Task__mdt>{dMT});
                                                     }
            
            //Set of eligible program acronyms for APS record type project records
            Set<String> setEligibleProgramAcronymsAPS = new Set<String>();                                                       
            
            //Checking for comman splitted string literal
            if(System.Label.PROJECT_APS_PROGRAM_ACRONYMS.split(',') != null
               &&
               System.Label.PROJECT_APS_PROGRAM_ACRONYMS.split(',').size() > 0
              ) {
                  
                  //Loop through splitted strings and populating collection with them
                  for(String pAcr : System.Label.PROJECT_APS_PROGRAM_ACRONYMS.split(','))
                      setEligibleProgramAcronymsAPS.add(pAcr);    
                  
              } else {
                  setEligibleProgramAcronymsAPS.add(System.Label.PROJECT_APS_PROGRAM_ACRONYMS);
              }
            
            //Set of eligible program acronyms for SSC record type project records
            Set<String> setEligibleProgramAcronymsSSC = new Set<String>(); 
            
            //Checking for comman splitted string literal
            if(System.Label.PROJECT_SSC_PROGRAM_ACRONYMS.split(',') != null
               &&
               System.Label.PROJECT_SSC_PROGRAM_ACRONYMS.split(',').size() > 0
              ) {
                  
                  //Loop through splitted strings and populating collection with them
                  for(String pAcr : System.Label.PROJECT_SSC_PROGRAM_ACRONYMS.split(','))
                      setEligibleProgramAcronymsSSC.add(pAcr);
                  
              } else {
                  setEligibleProgramAcronymsSSC.add(System.Label.PROJECT_SSC_PROGRAM_ACRONYMS);    
              }
            
            //Modified By Dipesh Gupta - 09/26/2019 - CR-20190529-13156 - APS replaced by Tech (SSC) as per Taylor Chatter
            //Id Of Project Record type "APS"
            Id aPSProjectRecordTypeID = Util.RecordTypeId(PROJECT_OBJECT_API_NAME, PROJECT_SSC_RECORD_TYPE_LABEL_NAME);
            
            //Modified By Dipesh Gupta - CR-20190529-13156 - 09/04/2019 - For Record type Label Modified From 'SSC' To 'Tech' Updated with 'PROJECT_SSC_RECORD_TYPE_LABEL_NAME'
            //Id Of Project Record type "SSC"
            Id sSCProjectRecordTypeID = Util.RecordTypeId(PROJECT_OBJECT_API_NAME, PROJECT_SSC_RECORD_TYPE_LABEL_NAME);
            
            //List of Record type
            List<RecordType> deliveryMilestoneRdTypes = new List<RecordType>();
            deliveryMilestoneRdTypes  = [SELECT Id FROM RecordType 
                                         WHERE sObjectType = 'Task' 
                                         AND DeveloperName = 'Delivery_Milestones' 
                                         AND IsActive = true];
            
            //Loop over lisst of project
            for(Project__c proj : newProjects) {
                
                //Checking if current project record instance is having "APS" record type
                if(proj.RecordTypeId != null && proj.RecordTypeId == aPSProjectRecordTypeID) {
                    
                    //Checking for eligible program acronyms
                    if(setEligibleProgramAcronymsAPS.size() > 0
                       && String.isNotBlank(proj.Program_Acronym__c)  
                       && setEligibleProgramAcronymsAPS.contains(proj.Program_Acronym__c)
                      ) {
                          
                          //Checking whether we are having custom metadata type records for milestone task creation
                          if(mapOfMilestonesMetadataTypes.containsKey(PROJECT_OBJECT_API_NAME + ' ' + PROJECT_SSC_RECORD_TYPE_API_NAME) 
                             && mapOfMilestonesMetadataTypes.get(PROJECT_OBJECT_API_NAME + ' ' + PROJECT_SSC_RECORD_TYPE_API_NAME) != null
                            ) {    
                                
                                //Loop over List of Meta data corresponding record type key value
                                for(Delievery_Milestones_Task__mdt dmTa : mapOfMilestonesMetadataTypes.get(PROJECT_OBJECT_API_NAME + ' ' + PROJECT_SSC_RECORD_TYPE_API_NAME)) {
                                    
                                    //Checking for field value in which the addition days will be added for the task due date
                                    if(proj.get(dmTa.Milestone_Field_API_Name__c) != null
                                       && Date.valueOf(proj.get(dmTa.Milestone_Field_API_Name__c)) != null
                                      ) {
                                          
                                          //Task instance
                                          Task ts = new Task();
                                          
                                          //Set properties - Static Type
                                          ts.RecordTypeId = deliveryMilestoneRdTypes[0].Id;
                                          ts.WhatId = proj.Id;
                                          ts.Type = System.Label.TYPE_DELIVERY_MILESTONE;
                                          ts.OwnerId = proj.Dedicated_Advisor__c != null ? proj.Dedicated_Advisor__c : UserInfo.getUserId();
                                          ts.Priority = System.Label.PRIORITY_DELIVERY_MILESTONE;
                                          ts.Status = System.Label.STATUS_DELIVERY_MILESTONE;
                                          
                                          //Set properties - Dynamic Type
                                          ts.Subject = dmTa.Task_Subject__c;
                                          ts.ActivityDate = Date.valueOf(proj.get(dmTa.Milestone_Field_API_Name__c)) != null ? Date.valueOf(proj.get(dmTa.Milestone_Field_API_Name__c)).addDays(Integer.valueOf(dmTa.Due_Date_After__c)):null;
                                          
                                          //Add in to task list
                                          tasksToBeInserted.add(ts);
                                      }
                                }
                            }    
                      }
                }
                
                //Checking if current project record instance is having "SSC" record type
                if(proj.RecordTypeId != null && proj.RecordTypeId == sSCProjectRecordTypeID) {
                    
                    //Checking for eligible program acronyms
                    if(setEligibleProgramAcronymsSSC.size() > 0
                       && String.isNotBlank(proj.Program_Acronym__c)  
                       && setEligibleProgramAcronymsSSC.contains(proj.Program_Acronym__c)
                      ) {
                          
                          //Checking whether we are having custom metadata type records for milestone task creation
                          if(mapOfMilestonesMetadataTypes.containsKey(PROJECT_OBJECT_API_NAME + ' ' + PROJECT_SSC_RECORD_TYPE_API_NAME) 
                             && mapOfMilestonesMetadataTypes.get(PROJECT_OBJECT_API_NAME + ' ' + PROJECT_SSC_RECORD_TYPE_API_NAME) != null
                            ) {    
                                
                                //Loop over List of Meta data corresponding record type key value
                                for(Delievery_Milestones_Task__mdt dmTak : mapOfMilestonesMetadataTypes.get(PROJECT_OBJECT_API_NAME + ' ' + PROJECT_SSC_RECORD_TYPE_API_NAME)) {
                                    
                                    //Checking for field value in which the addition days will be added for the task due date
                                    if(proj.get(dmTak.Milestone_Field_API_Name__c) != null
                                       && Date.valueOf(proj.get(dmTak.Milestone_Field_API_Name__c)) != null
                                      ) {
                                          
                                          //Task instance
                                          Task tsk = new Task();
                                          
                                          //Set properties - Static Type
                                          tsk.RecordTypeId = deliveryMilestoneRdTypes[0].Id;
                                          tsk.WhatId = proj.Id;
                                          tsk.Type = System.Label.TYPE_DELIVERY_MILESTONE;
                                          tsk.OwnerId = proj.Dedicated_Advisor__c != null ? proj.Dedicated_Advisor__c : UserInfo.getUserId();
                                          tsk.Priority = System.Label.PRIORITY_DELIVERY_MILESTONE;
                                          tsk.Status = System.Label.STATUS_DELIVERY_MILESTONE;
                                          
                                          //Set properties - Dynamic Type
                                          tsk.Subject = dmTak.Task_Subject__c;
                                          tsk.ActivityDate = Date.valueOf(proj.get(dmTak.Milestone_Field_API_Name__c)) != null ? Date.valueOf(proj.get(dmTak.Milestone_Field_API_Name__c)).addDays(Integer.valueOf(dmTak.Due_Date_After__c)):null;
                                          
                                          //Add in to task list
                                          tasksToBeInserted.add(tsk);
                                      }
                                }        
                            }    
                      }
                }
            }
            
            //Checking for the size value
            if(tasksToBeInserted.size() > 0) {
                
                //Bypassing all triggers
                Util.byPassAlltriggers = true;
                
                //Insert tasks
                insert tasksToBeInserted;
                
                //Enabling triggers
                Util.byPassAlltriggers = false;
            }        
        }
    }
    
    
    //V_1.30 - Merged By - Rajeev Jain - 07/28/2017( Release 60 Deployment Merged the changes of R60 with Q2C Beta + Revenue Management Release) - Ends here
    
    /**
    *  @description    :   Method to Create the PSA Project record on creation fo Project Records
    * 
    *  @args           :   List of Projects
    * 
    *  @return         :   void
    * 
    * Revision Log     :   Created Abhinav Sharma - 09/19/2018 - CR-20180917-12599.
    **/
    public static void createShadowProjectOnProjectCreation(List<Project__c> newProjects) {
        
        
        Id PSA_PROJ_RTYPE_ID = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByName().get('PSA Project').getRecordTypeId();
        
        //Check for the new List Null check
        if(newProjects != null && newProjects.size() > 0 ) {
            
            //Set to hold the eligible Recordtype DeveloperName 
            set<String> setProjectEligibleRecordTypes = new set<String>();
            
            //Set to hold the Ids of Project Records 
            set<Id> setProjectIds = new set<Id>();
            
            //Getting the Record type Information from the Custom label for which record type the Sync should be executed.  
            String eligibleRecordTypes = Label.SHADOW_PSA_PROJECT_RECORD_TYPES_TO_BE_SYNC;            
            
            //check If the String Contains the Comma
            if(eligibleRecordTypes.contains(',')) {
                
                //Spilitting the record type Developer Name from Comma (,)
                for(String str : eligibleRecordTypes.split(',')) {
                    setProjectEligibleRecordTypes.add(str.trim());  
                }
            }else {
                setProjectEligibleRecordTypes.add(eligibleRecordTypes);  
            }
            
            //Check if there is any eligible record type 
            if(setProjectEligibleRecordTypes.size() > 0) {
                
                //Map to hold the Source Field (Project) with the Target Field (pse__Proj__c) Object
                Map<String, String> mapSourceAndTargetMapping = new Map<String, String>();
                
                //List to hold the Parent Field Name
                List<String> parentObjectFieldName = new List<String>();
                
                //String to hold  a dynamic query 
                String query = '';
                
                //Getting the Data From the Custom MetaData which is only applicable for the Project and Psa Project sync records. 
                for(Shadow_PSA_Project_Mapping__mdt shadowProjectMapping : [Select Id, Parent_Object_Name__c, Parent_Field_Name__c, 
                                                                            Child_Field_Name__c, Child_Object_Name__c 
                                                                            From Shadow_PSA_Project_Mapping__mdt Where
                                                                            IsActive__c = true AND Is_Insert_Mapping__c = true 
                                                                            AND Is_Shadow_Project__c = true
                                                                            AND Parent_Object_Name__c = 'Project__c' AND Child_Object_Name__c = 'pse__Proj__c']) {
                                                                                //Map to hold the source and target mappings.                             
                                                                                mapSourceAndTargetMapping.put(shadowProjectMapping.Parent_Field_Name__c.trim(), shadowProjectMapping.Child_Field_Name__c.trim());  
                                                                                
                                                                                //Filling the List with the patrent Object Field name
                                                                                parentObjectFieldName.add(shadowProjectMapping.Parent_Field_Name__c);              
                                                                                
                                                                                //Getting the Parent Field Name
                                                                                query +=  shadowProjectMapping.Parent_Field_Name__c + ', ';                              
                                                                            }
                
                //Loop on the Project Object New List
                for(Project__c newPr : newProjects) {
                    
                    setProjectIds.add(newPr.Id);
                }
                
                //Cheking if the query is containg the Ids.
                if(!query.contains('ID,')) {
                    //Adding Id to the Query. 
                    query = 'Id, '+ query;
                }  
                query = query.removeEnd(', ');
                
                //Forming Query
                query = 'Select '+ query  + ', Institution__r.Account_Formal_Name__c, Institution__r.Primary_City__c, Product__r.Program_Acronym__c, Primary_Paid_Membership__r.Active_Subscription__r.Id From Project__c Where RecordType.DeveloperName IN: setProjectEligibleRecordTypes AND Id IN: setProjectIds';
                
                
                //Dynamic Query on the Project Object only querying those record which is going to be Map with PSA Project. 
                List<Project__c> pojectsToBeCreateShadowProjects = Database.query(query);
                
                List<sObject> listProjectToBeInserted = new List<sObject>();
                
                List<pse__Region__c> pseRegion = [Select id From pse__Region__c where Name =: Label.Shadow_Project_Region];
                
                //Loop through the Project object.
                for(Project__c project : pojectsToBeCreateShadowProjects) {
                    
                    //Creating a instance of Pse project.
                    sObject sObj = Schema.getGlobalDescribe().get('pse__Proj__c').newSObject();
                    
                    //Loop through the parent object Field name
                    for(String parValue : parentObjectFieldName) {
                        
                        //Checking for the Name field
                        if(mapSourceAndTargetMapping.get(parValue).trim() == 'Name'){
                            
                            //Colin McGloin - 11/05/18 - Added logic to account for Name longer than 80 characters
                            String psaProjName = project.Institution__r.Account_Formal_Name__c + ' - ' + project.Institution__r.Primary_City__c + ' - ' + project.Product__r.Program_Acronym__c;
                            
                            //If our combined string is greater than the limit then run logic
                            if(psaProjName.length() > 80){
                                //Calculate how far over we are
                                integer overage = psaProjName.length() - 80;
                                //Get the length of the Institution Name and remove the overage from that specific string
                                String shortenName = project.Institution__r.Account_Formal_Name__c;
                                shortenName.left(shortenName.length() - overage);
                                sObj.put(mapSourceAndTargetMapping.get(parValue).trim(), shortenName + ' - ' + project.Institution__r.Primary_City__c + ' - ' + project.Product__r.Program_Acronym__c);
                            }
                            //If our Name string is 80 characters or under then proceed as normal
                            else {
                                sObj.put(mapSourceAndTargetMapping.get(parValue).trim(), project.Institution__r.Account_Formal_Name__c + ' - ' + project.Institution__r.Primary_City__c + ' - ' + project.Product__r.Program_Acronym__c);
                            }
                        }
                        else
                            //Filling the Sobject
                            sObj.put(mapSourceAndTargetMapping.get(parValue).trim(), project.get(parValue));
                    }
                    
                    /*Some Fields Should be set as default*/
                    sObj.put('CurrencyIsoCode', 'USD');
                    sObj.put('Capitalizable__c', true);
                    sObj.put('pse__Is_Active__c', true);
                    sObj.put('pse__Allow_Timecards_Without_Assignment__c', true); //Modified by CM - 11/02 - Modified to default to True
                    if(pseRegion != null && pseRegion.size() > 0)
                        sObj.put('pse__Region__c', pseRegion[0].Id); //Modified by Abhinav - Pass the Id Of PSA Region
                    sObj.put('pse__Billing_Type__c', 'Fixed Price');
                    sObj.put('pse__Closed_for_Time_Entry__c', false);
                    sObj.put('pse__End_Date__c', Date.Today().addYears(3)); //Modified by CM - 11/07 - Add a default date of Today +3 Years
                    
                    //Adding a value to be populated via query due to not being able to grab related IDs and work with an sObject
                    if (project.Primary_Paid_Membership__r.Active_Subscription__r.Id != null){
                        sObj.put('Active_Program_Subscription__c', project.Primary_Paid_Membership__r.Active_Subscription__r.Id);
                    }
                    
                    //Check the Size of sObject
                    if(sObj != null) {
                        
                        //Set the Record type.
                        sObj.put('RecordTypeId', PSA_PROJ_RTYPE_ID);
                        
                        listProjectToBeInserted.add(sObj);
                    }
                }
                
                //Checking the list size. 
                if(listProjectToBeInserted != null && listProjectToBeInserted.size() > 0) {
                    
                    //Set a flag as true
                    PSAProjectTriggerHelper.PSA_PROJ_SYNC_PROCESS = true;
                    
                    //Inserting the List
                    insert listProjectToBeInserted;
                    
                    //List to hold the Projects 
                    List<Project__c> projectsToBeUpdated = new List<Project__c>();
                    
                    //New List to hold the Project that needs to be Updated.
                    //Look through the list
                    for(SObject psaProj : listProjectToBeInserted) {
                        
                        //check if the project__c is not blank than avoid the records
                        if(psaProj.get('Project__c') != null)
                            projectsToBeUpdated.add(new Project__c(Id = String.valueOf(psaProj.get('Project__c')), PSA_Project__c = String.valueOf(psaProj.get('Id'))));
                    }
                    
                    Util.BypassAllTriggers = true;
                    //Check for list size
                    if(projectsToBeUpdated.size() > 0)
                        update projectsToBeUpdated;
                    Util.BypassAllTriggers = false;
                }
            }    
        }       
    }
    
    /**
    *  @description    :   Method to populate Keep the Synce Betweeen Project and PSA Project
    * 
    *  @args           :   List of Projects, Map of old Projects
    * 
    *  @return         :   void
    * 
    * Revision Log     :   Created Abhinav Sharma - 09/19/2018 - CR-20180917-12599.
    **/
    public static void syncProjectWithPSAProject(List<Project__c> newProjects, Map<Id, Project__c> oldMapProjects) {
        
        //Map to hold the Source and Target mapping foer the Fields.
        Map<String, String> mapSourceAndTargetMapping = new Map<String, String>();
        
        //List to hold the Parent Object's Field API Name
        List<String> parentObjectFieldName = new List<String>();
        
        //Set to hold the Project Record ids on which the Sync Fields Changed.
        Set<Id> setEligibleProjectIds = new Set<Id>();
        
        //Set to hold the Eligible Record types. 
        set<String> setProjectEligibleRecordTypes = new Set<String>();
        
        //Set to hold the Record type Ids 
        set<Id> setProjectRecordTypeIds = new set<Id>();
        
        //map to hold the New Project records With ID and Map<String(FieldAPI), Object(API)>
        Map<Id, Map<String, Object>> mapParentObjectIdWithFieldValues = new Map<Id, Map<String, Object>>();
        
        //Check for the List Size
        if(newProjects != null && newProjects.size() > 0) {
            
            //Getting the Record type Information from the Custom label for which record type the Sync should be executed.  
            String eligibleRecordTypes = Label.SHADOW_PSA_PROJECT_RECORD_TYPES_TO_BE_SYNC;            
            
            //check If the String Contains the Comma
            if(eligibleRecordTypes.contains(',')) {
                
                //Spilitting the record type Developer Name from Comma (,)
                for(String str : eligibleRecordTypes.split(',')) {
                    setProjectEligibleRecordTypes.add(str.trim());  
                }
            }else {
                setProjectEligibleRecordTypes.add(eligibleRecordTypes);  
            }
            
            //Check if there is any eligible record type 
            if(setProjectEligibleRecordTypes.size() > 0) {
                
                //Query to the Custom setting and check for the 2 Record types of Project object.
                /*list<Recordtype_Setting__c> rtslist = Recordtype_Setting__c.getall().values();

                //Loop through all the record type
                for (Recordtype_Setting__c rts : rtslist) {
                
                //Check for the SObject type is only Project Object
                if (rts.SObjectType__c == 'Project__c') {
                
                //Check for the 4 Record type of Event Only.
                if(setProjectEligibleRecordTypes.contains(rts.DeveloperName__c))
                setProjectRecordTypeIds.add(rts.SFID__c);
                } 
                }*/
                for(String rTypeDevName : Util.sobjectRecordTypeId('Project__c').keyset()) {
                    if(setProjectEligibleRecordTypes.contains(rTypeDevName)){
                        setProjectRecordTypeIds.add(Util.sobjectRecordTypeId('Project__c').get(rTypeDevName));
                    }
                }
            }
            
            //Getting the Data From the Custom MetaData which is only applicable for the Project and Psa Project sync records. 
            for(Shadow_PSA_Project_Mapping__mdt shadowProjectMapping : [Select Id, Parent_Object_Name__c, Parent_Field_Name__c, 
                                                                        Child_Field_Name__c, Child_Object_Name__c 
                                                                        From Shadow_PSA_Project_Mapping__mdt Where
                                                                        IsActive__c = true AND Is_Update_Mapping__c = true 
                                                                        AND Is_Shadow_Project__c = true
                                                                        AND Parent_Object_Name__c = 'Project__c' AND Child_Object_Name__c = 'pse__Proj__c']) {
                                                                            
                                                                            
                                                                            //Map to hold the source and target mappings.                             
                                                                            mapSourceAndTargetMapping.put(shadowProjectMapping.Parent_Field_Name__c.trim(), shadowProjectMapping.Child_Field_Name__c.trim());  
                                                                            
                                                                            //Filling the List with the patrent Object Field name
                                                                            parentObjectFieldName.add(shadowProjectMapping.Parent_Field_Name__c);              
                                                                        }
            /*We need 2 Maps that can have Old and new values and in the way like FIeld API Name ==> VALUE */ 
            for(Project__c proj : newProjects) {
                
                //Check for the update Case, if Old map is null or doesn't contain the Id then continue;
                if(oldMapProjects == null || (oldMapProjects != null && !oldMapProjects.containsKey(proj.Id)))
                    continue;
                
                //Map to hold the Values of Field API Name and value
                Map<String, Object> mapForNewValues = proj.getPopulatedFieldsAsMap();
                Map<String, Object> mapForOldValues = oldMapProjects.get(proj.Id).getPopulatedFieldsAsMap();
                
                for(String parentObjectFieldAPIName : mapSourceAndTargetMapping.keyset()) {
                    
                    //Check for the field value change [Only those fields which needs to keep in sync between Project and PSA Project]
                    if(mapForNewValues != null && mapForOldValues != null && mapSourceAndTargetMapping != null 
                       && mapForNewValues.get(parentObjectFieldAPIName) != mapForOldValues.get(parentObjectFieldAPIName) && proj.PSA_Project__c != null &&
                       setProjectRecordTypeIds.contains(proj.RecordTypeId)
                      ) {
                          //Map to hold the New Values.
                          mapParentObjectIdWithFieldValues.put(proj.Id, mapForNewValues);
                      }
                }
            }
            
            //List to hold the Sobject that needs to be updated. 
            List<SObject> listOfPSAProjectToBeUpdated = new List<SObject>();
            
            //Checking the Size of the set
            if(mapParentObjectIdWithFieldValues.size() > 0) {
                
                for(Id prjId : mapParentObjectIdWithFieldValues.keyset()) {
                    
                    //Creating a instance of Pse project.
                    sObject sObj = Schema.getGlobalDescribe().get('pse__Proj__c').newSObject(String.valueOf(mapParentObjectIdWithFieldValues.get(prjId).get('PSA_Project__c')));
                    
                    //Checking for the null values
                    if(mapParentObjectIdWithFieldValues.get(prjId) != null) {
                        
                        //Loop on the Map
                        for(String parentObj : mapSourceAndTargetMapping.keyset()) {
                            
                            //Cheeck for the new Values is not null
                            if( mapParentObjectIdWithFieldValues.get(prjId).get(parentObj) == null)
                                continue;
                            
                            //Adding Field values to the list. 
                            sObj.put(mapSourceAndTargetMapping.get(parentObj).trim(), mapParentObjectIdWithFieldValues.get(prjId).get(parentObj));
                        }
                    }
                    
                    //Cheking the Size of Sobject
                    if(sObj != null && sObj.get('Id') != null)
                        listOfPSAProjectToBeUpdated.add(sObj); 
                }   
                
                //Set a flag as true
                PSAProjectTriggerHelper.PSA_PROJ_SYNC_PROCESS = true;
                
                
                //Checking for the size of list
                if(listOfPSAProjectToBeUpdated != null && listOfPSAProjectToBeUpdated.size() > 0)
                    update listOfPSAProjectToBeUpdated;
            }
        }
    }
    //Modified By Abhinav Sharma - 03/12/2018 - CR-20181025-12706 - Starts here
    //Modified By Dipesh Gupta - 23/12/2019 - CR-20191204-13550 - modified method to populate 'Enrollment CRM' field On Project record from the 'Competitor and Tech System' object.
    //Modified By - Neha Sharma - 03/08/2021 - CR-20201022-14630 - Fix Logic on SIS, LMS and Enrollment CRM SSC Project Fields
    //Modified by - Neha Sharma - CR-20200615-14188 - 04/08/2021 - Add the logic for Audit Degree
    //Modified by - Mahendra Swarnkar - CR-20211118-15596 - 11/24/2021 - Commented this method and created the new method populateFieldsOnProjectFromCompTechSystem to work with Competitor and Tech System Object and its fields instead of "Assets" object and fields.
    /**
    *  @description    :   Method to populate 'Learning Management System', 'Current SIS' and 'Enrollment CRM' fields On Project record from the 'Competitor and Tech System' object. 
    * 
    *  @args           :   List of Projects, Map of old Projects
    * 
    *  @return         :   void
    * 
    **/
  /*  public static void populateFieldsOnProjectFromAsset(List<Project__c> newProjects, Map<Id, Project__c> mapOldProjects)
    {
        //Modified By Dipesh Gupta - CR-20190529-13156 - 09/04/2019 - For Record type Label Modified From 'SSC' To 'Tech' 
        //Record type id for the project ssc.
        Id RECORD_TYPE_ID_SSC_PROJECT = Schema.SObjectType.Project__c.getRecordTypeInfosByName().get('Tech').getRecordTypeId();
        
        //Set to hold the Account Ids
        // System.assert(false,'fdsf');
        Map<Id, List<Project__c>> mapOfAccountIdandProjects = new Map<Id, List<Project__c>>();
        
        //Set to hold the Account Ids
        Set<Id> setOfProjecctSIS = new Set<Id>();
        
        //Set to hold the Project Ids
        Set<Id> setOfProjecctLMS = new Set<Id>();
        
        //Set to hold the Project Ids
        Set<Id> setOfProjecctCRM = new Set<Id>();
        
        //Set to hold the Project Ids
        Set<Id> setOfProjecctDegreeAudit = new Set<Id>();
        
        //map to hold the Project Ids
        Map<Id,Project__c> mapOfProject = new  Map<Id,Project__c>();
        
        //Loop over the New Project records
        for(Project__c proj : newProjects)
        {
            //Institution, Learning Management System, Current SIS and 'Enrollment CRM' checks
            if(proj.Institution__c != null
               && (mapOldProjects == null
                   || (mapOldProjects != null
                       && (proj.Institution__c != mapOldProjects.get(proj.Id).Institution__c
                           || proj.Learning_Management_System__c != mapOldProjects.get(proj.Id).Learning_Management_System__c
                           || proj.Current_SIS__c != mapOldProjects.get(proj.Id).Current_SIS__c
                           || proj.Degree_Audit__c != mapOldProjects.get(proj.Id).Degree_Audit__c
                           || proj.Enrollment_CRM__c != mapOldProjects.get(proj.Id).Enrollment_CRM__c)))
               && proj.RecordTypeId == RECORD_TYPE_ID_SSC_PROJECT)
            {
                if(!mapOfAccountIdandProjects.ContainsKey(proj.Institution__c))
                    mapOfAccountIdandProjects.put(proj.Institution__c, new List<Project__c>());
                mapOfAccountIdandProjects.get(proj.Institution__c).add(proj); 
                
               mapOfProject.put(proj.Id,proj);
            }
        }
        
        Map<Id,List<Asset>> mapOfAccountIdandAssets =  new Map<Id,List<Asset>>();
        for(Asset ass : [Select Id, Name, AccountId, TechStatus__c,TechSystem__c, TechCategory__c
                         From Asset
                         Where AccountId IN : mapOfAccountIdandProjects.keySet()
                         ORDER BY AccountId, CreatedDate DESC])
        {
           if(!mapOfAccountIdandAssets.ContainsKey(ass.AccountId))
                    mapOfAccountIdandAssets.put(ass.AccountId, new List<Asset>());
                mapOfAccountIdandAssets.get(ass.AccountId).add(ass);
        }
        
        for(Project__c pro : mapOfProject.values()){
            pro.Degree_Audit__c = '';
            pro.current_SIS__c = '';
            pro.Learning_Management_System__c = '';
            pro.Enrollment_CRM__c = '';
            
            if(mapOfAccountIdandAssets.containsKey(pro.Institution__c))
            {
                for(Asset ass : mapOfAccountIdandAssets.get(pro.Institution__c))
                {
                    //get list of techSystem values
                    List<String> techSystemValues = new List<String>();
                    
                    if(String.isNotBlank(ass.TechSystem__c) && ass.TechSystem__c.contains(';'))
                        techSystemValues = ass.TechSystem__c.split(';');
                    else
                        techSystemValues.add(ass.TechSystem__c); 
                    for(String techSys : techSystemValues)
                    {
		        //Modify by - Neha Sharma - CR-20200615-14188 - 04/08/2021 - Add the logic for Audit Degree
                        if(techSys == 'Degree Audit')
                        {
							if(ass.TechStatus__c == 'current'){
							    if(String.IsNotBlank(pro.Degree_Audit__c)){
									pro.Degree_Audit__c = pro.Degree_Audit__c +','+ass.Name ;
								}
								else{
									pro.Degree_Audit__c = ass.Name ;
								}	
							} 
                        }
					    else if(techSys == 'SIS')
						{
							if(ass.TechStatus__c == 'current'){
							    if(String.IsNotBlank(pro.current_SIS__c)){
									pro.current_SIS__c = pro.current_SIS__c +','+ass.Name ;
								}
								else{
									pro.current_SIS__c = ass.Name ;
								}	
							}
						}
						else if(techSys == 'LMS')
						{
							if(ass.TechStatus__c == 'current'){
							    if(String.IsNotBlank(pro.Learning_Management_System__c)){
									pro.Learning_Management_System__c = pro.Learning_Management_System__c + ','+ass.Name ;
								}
								else{
									pro.Learning_Management_System__c = ass.Name ;
								}
							}
						}
						else if(String.isNotBlank(ass.TechCategory__c) && ass.TechCategory__c == 'Enrollment' && techSys == 'CRM')
						{
							if(ass.TechStatus__c == 'current'){
							    if(String.IsNotBlank(pro.Enrollment_CRM__c )){
									pro.Enrollment_CRM__c = pro.Enrollment_CRM__c +','+ass.Name ;
								}
								else{
									pro.Enrollment_CRM__c = ass.Name ;
								}
							}
						}
                    }
                    
                }
            }
        }
                        
    }*/ 
    //Modified by - Mahendra Swarnkar - CR-20211118-15596 - 11/24/2021 - Commented existing method populateFieldsOnProjectFromAsset and created this new method to work with Competitor and Tech System Object and its fields instead of "Assets" object and fields.
     public static void populateFieldsOnProjectFromCompTechSystem(List<Project__c> newProjects, Map<Id, Project__c> mapOldProjects)
    {
        //Modified By Dipesh Gupta - CR-20190529-13156 - 09/04/2019 - For Record type Label Modified From 'SSC' To 'Tech' 
        //Record type id for the project ssc.
        Id RECORD_TYPE_ID_SSC_PROJECT = Schema.SObjectType.Project__c.getRecordTypeInfosByName().get('Tech').getRecordTypeId();
        
        // Set to hold account ids 
        Set<Id> accountIds = new Set<Id>();
        
        //map to hold the Project Ids
        Map<Id,Project__c> mapOfProject = new  Map<Id,Project__c>();
        
        //Loop over the New Project records
        for(Project__c proj : newProjects)
        {
            //Institution, Learning Management System, Current SIS and 'Enrollment CRM' checks
            if(proj.Institution__c != null
               && (mapOldProjects == null
                   || (mapOldProjects != null
                       && (proj.Institution__c != mapOldProjects.get(proj.Id).Institution__c
                           || proj.Learning_Management_System__c != mapOldProjects.get(proj.Id).Learning_Management_System__c
                           || proj.Current_SIS__c != mapOldProjects.get(proj.Id).Current_SIS__c
                           || proj.Degree_Audit__c != mapOldProjects.get(proj.Id).Degree_Audit__c
                           || proj.Enrollment_CRM__c != mapOldProjects.get(proj.Id).Enrollment_CRM__c)))
               && proj.RecordTypeId == RECORD_TYPE_ID_SSC_PROJECT)
            {
                accountIds.add(proj.Institution__c);
                mapOfProject.put(proj.Id,proj);
            }
        }
        
        if(accountIds.size()>0)
        {
            Map<Id,List<Competitor_and_Tech_System__c>> mapOfAccountIdandCompTechSystems =  new Map<Id,List<Competitor_and_Tech_System__c>>();
            //Modified By - Chirag Soni - CR-20211207-15617 - 5/24/2022 - Commented reference for formula status field and added picklist status field in place of it.
            for(Competitor_and_Tech_System__c compTechSystem : [Select Id, Name, Institution__c, /*Status__c,*/ Status2__c, Tech_System__c, Category__c
                                                                From Competitor_and_Tech_System__c Where Institution__c IN : accountIds AND recordtype.developerName = 'External_System' ORDER BY Institution__c, CreatedDate DESC])
            {
                if(!mapOfAccountIdandCompTechSystems.ContainsKey(compTechSystem.Institution__c))
                    mapOfAccountIdandCompTechSystems.put(compTechSystem.Institution__c, new List<Competitor_and_Tech_System__c>());
                mapOfAccountIdandCompTechSystems.get(compTechSystem.Institution__c).add(compTechSystem);
            }
            
            for(Project__c pro : mapOfProject.values())
            {
                pro.Degree_Audit__c = '';
                pro.current_SIS__c = '';
                pro.Learning_Management_System__c = '';
                pro.Enrollment_CRM__c = '';
                
                if(mapOfAccountIdandCompTechSystems.containsKey(pro.Institution__c))
                {
                    for(Competitor_and_Tech_System__c compTechSystem : mapOfAccountIdandCompTechSystems.get(pro.Institution__c))
                    {
                        //get list of techSystem values
                        List<String> techSystemValues = new List<String>();
                        
                        if(String.isNotBlank(compTechSystem.Tech_System__c) && compTechSystem.Tech_System__c.contains(';'))
                            techSystemValues = compTechSystem.Tech_System__c.split(';');
                        else
                            techSystemValues.add(compTechSystem.Tech_System__c); 
                        for(String techSys : techSystemValues)
                        {
                            if(techSys == 'Degree Audit')
                            {
                                //Modified By - Chirag Soni - CR-20211207-15617 - 5/24/2022 - Commented reference for formula status field and added picklist status field in place of it.      
                                if(/*compTechSystem.Status__c == 'current'*/ compTechSystem.Status2__c == 'Current'){
                                    if(String.IsNotBlank(pro.Degree_Audit__c)){
                                        pro.Degree_Audit__c = pro.Degree_Audit__c +','+compTechSystem.Name ;
                                    } else{
                                        pro.Degree_Audit__c = compTechSystem.Name ;
                                    }	
                                } 
                            }else if(techSys == 'SIS')
                            {
                                 //Modified By - Chirag Soni - CR-20211207-15617 - 5/24/2022 - Commented reference for formula status field and added picklist status field in place of it.      
                                if(/*compTechSystem.Status__c == 'current'*/ compTechSystem.Status2__c == 'Current'){
                                    if(String.IsNotBlank(pro.current_SIS__c)){
                                        pro.current_SIS__c = pro.current_SIS__c +','+compTechSystem.Name ;
                                    }else{
                                        pro.current_SIS__c = compTechSystem.Name ;
                                    }	
                                }
                            }else if(techSys == 'LMS')
                            {
                                 //Modified By - Chirag Soni - CR-20211207-15617 - 5/24/2022 - Commented reference for formula status field and added picklist status field in place of it.      
                                if(/*compTechSystem.Status__c == 'current'*/ compTechSystem.Status2__c == 'Current'){
                                    if(String.IsNotBlank(pro.Learning_Management_System__c)){
                                        pro.Learning_Management_System__c = pro.Learning_Management_System__c + ','+compTechSystem.Name ;
                                    }else{
                                        pro.Learning_Management_System__c = compTechSystem.Name ;
                                    }
                                }
                            }else if(String.isNotBlank(compTechSystem.Category__c) && compTechSystem.Category__c == 'Enrollment' && techSys == 'CRM')
                            {
                                 //Modified By - Chirag Soni - CR-20211207-15617 - 5/24/2022 - Commented reference for formula status field and added picklist status field in place of it.      
                                if(/*compTechSystem.Status__c == 'current'*/ compTechSystem.Status2__c == 'Current'){
                                    if(String.IsNotBlank(pro.Enrollment_CRM__c )){
                                        pro.Enrollment_CRM__c = pro.Enrollment_CRM__c +','+compTechSystem.Name ;
                                    }else{
                                        pro.Enrollment_CRM__c = compTechSystem.Name ;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }	
    
   
    
    //Added By Mahendra Swarnkar - 06/12/2019 - CR-CR-20190522-13122 - Starts here
    //popualte the program info on a given list of events
    public static list<Event> populateProgramInfo_Events(map<Id, Project__c> proMap, list<Event> events) {
        
        // get all events associated with these project and update their program
        for (Event e : events) {
            
            //Checking for null and size value
            if (proMap != null && proMap.containsKey(e.WhatId) && proMap.get(e.WhatId) != null) {
                
                // get the asociated project
                Project__c pro = proMap.get(e.WhatId);
                
                if (pro.Product__c != null) {
                    
                    // update the program
                    e.Program__c = pro.Product__r.Program_Acronym__c;
                }
                else {
                    
                    e.Program__c = null;
                }
            }
        }
        return events;
    }
    //Added By Mahendra Swarnkar - 06/12/2019 - CR-CR-20190522-13122 - Ends here
    
    // Added By Dipesh Gupta CR-20191223-13575 populateFieldsOndeployment Start here
    //Method to populate the Learning_Management_System__c,  Current_SIS__c, Enrollment_CRM__c. - Dipesh Gupta - CR-20191223-13575 
    public static void populateFieldsOndeployment(List<Project__c> newProjects, Map<Id, Project__c> oldMapProjects) { 
    	
        Map<Id, Project__c> mapEligibleProjectsDetail = new Map<Id, Project__c>();
            
        for(Project__c proj : newProjects != null ? newProjects : oldMapProjects.values()) {
		
        	if((oldMapProjects != null && 
                   	(oldMapProjects.get(proj.Id).Learning_Management_System__c != proj.Learning_Management_System__c
                       ||  oldMapProjects.get(proj.Id).Current_SIS__c != proj.Current_SIS__c
                       ||  oldMapProjects.get(proj.Id).Enrollment_CRM__c != proj.Enrollment_CRM__c)) 
               || (newProjects == null)) {
                   
            	//Add Projects to the Map. 
              	mapEligibleProjectsDetail.put(proj.Id, proj);     
            }
        }
        
        if(mapEligibleProjectsDetail.size() > 0) {
            
            List<Deployment__c> deploymentToBeUpdated = new List<Deployment__c>();
            
            
            //Query on the Deployments. 
            for(Deployment__c deployment : [Select Id, Learning_Management_System__c, Current_SIS__c, CRM__c, Project__c
                                           From Deployment__c 
                                            Where Project__c IN : mapEligibleProjectsDetail.keySet() AND RecordType.DeveloperName = 'EDH']) {
            	
            	if(mapEligibleProjectsDetail.containsKey(deployment.Project__c) && mapEligibleProjectsDetail.get(deployment.Project__c) != null) {
                	
                  	deployment.Learning_Management_System__c = mapEligibleProjectsDetail.get(deployment.Project__c).Learning_Management_System__c;
                    deployment.Current_SIS__c = mapEligibleProjectsDetail.get(deployment.Project__c).Current_SIS__c;
                    deployment.CRM__c = mapEligibleProjectsDetail.get(deployment.Project__c).Enrollment_CRM__c;	   
                    
                    deploymentToBeUpdated.add(deployment);
                }
           	}
            
            if(deploymentToBeUpdated.size() > 0) {
                //Bypassing the trigger to bypass the scenarios. 
                Util.bypassAllTriggers = true;
                update deploymentToBeUpdated;
                Util.bypassAllTriggers = false;
            }
         }
    }
    // Added By Dipesh Gupta CR-20191223-13575 populateFieldsOndeployment Ends Here
}