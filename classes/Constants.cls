/**
 *   Purpose			:    This class is to hold the constant values
 *
 *   Created By			:    Simplyforce Technology
 *
 *   Created Date		:    10//2011 
 *
 *   Current Version		:    V1.0
 *
 *   Revision Log		:    V1.1 - Created - Bhavi Sharma - 08/10/2013 - Credit Card Project
 *				     V1.2 - Modified - Ajit Surana - 03/13/2014 - CR-20140205-4458
 *				     V1.3 - Modified - Victor Hanson - 04/03/2014 - Crimson Community Project
 *				     V1.4 - Modified - Abhinav Sharma - 06/11/2014 - CR-20140610-5763
 *				     V1.5 - Modified - Abhinav Sharma - 07/03/2014 - CR-20140618-5845
 *				     V1.6 - Modified - Abhinav Sharma - 07/04/2014 - CR-20140629-6015
 *				     V1.7 - Modified - Abhinav Sharma - 08/05/2014 - CR-20140610-5761
 *				     V1.8 - Modified - Abhinav Sharma - 08/06/2014 - CR-20140707-6093
 *				     V1.9 - Modified - Abhinav Sharma - 08/12/2014 - CR-20140425-5234
 *				     V2.0 - Modified - Abhinav Sharma - 08/13/2014 - CR-20140604-5691
 *				     V2.1 - Modified - Abhinav Sharma - 08/14/2014 - CR-20140723-6571
 *				     V2.2 - Modified - Ajit Surana - 01/21/2015 - CR-20150102-8430
 *				     V2.3 - Modified - Victor Hanson - 01/27/2015 - CR-20140520-5562
 *				     V2.4 - Modified - Jeffery Sun - 10/01/2015 - CR-20130328-2770 (ABC_DATALOADER_PROFILE_ID)
 *				     V2.5 - Modified - Abhinav Sharma - CR-20150914-9243 - 11/27/2015
 *				     V2.6 - Modified - Abhinav Sharma - CR-20151118-9397 - 12/22/2015
 *				     V2.7 - Modified - Abhinav Sharma - CR-20150925-9267 - 02/11/2016
 *				     V2.8 - Modified - Mahendra Swarnkar - CR-20160114-9520 - 08/23/2016
 *				     V2.9 - Modified - Mahendra Swarnkar - CR-20160610-9915 - 08/27/2016
 *				     V3.0 - Modified - Mahendra Swarnkar - CR-20160729-10075 - 08/27/2016
 *				     V3.1 - Modified - Mahendra Swarnkar - CR-20160715-10014 - 9/2/2016
 *				     V3.2 - Modified - Mahendra Swarnkar - CR-20160126-9564 - 9/3/2016  - Update "RECORD_TYPE_ID_ACCOUNT_VENUE" value
 *				     V3.3 - Modified - Rajeev Jain - Services Excellence - Manually merged code from ServicesEx sb to Test as it was having too many overlapping in test sb.
 *				     V3.4 - Modified - Mahendra Swarnkar - 11/04/2016 - CR-20160927-10190 - New variables are added
 *				     V3.5 - Modified - Rajeev Jain - 11/22/2016 - Services Excellence - UAT Issue fix - Added new constants
 *				     V3.6 - Modified - Mahendra Swarnakar - 3/15/2017 - CR-20170210-10679
 *				     V3.7 - Modified - Subhash Garhwal - 10/06/2017 - Apollo Release
 *				     V3.8 - Modified - Victor Hanson - 10/06/2017 - Apollo Release
 *				     V3.9 - Modified - Subhash Garhwal - 06/20/2018 - CR-20180608-12273 Updated the VOIDER variable value from Voider to Void - CR-20180608-12273 Modified by Subhash Garhwal 
 *				     V4.0 - Modified - Rajeev Jain - 07/07/2018 - Map to hold the Profile Name with its Is system component Ids
 *				     V4.1 - Modified - Victor Hanson - 09/10/2018 - CR-20180803-12480
 *				     V4.2 - Modified - Subhash Garhawal - 10/11/2018 - CR-20180720-12456 - New Variables and Map added
 *				     V4.3 - Modified - Rajeev Jain in the Deploymentt of CR-20180720-12456
 *				     V4.4 - Modified - Abhinav sharma - CR-20180928-12623 - 10/11/2018 - Case web help record type Id Veriable.
 *				     V4.5 - Modified - Mahendra Swarankar - CR-20181116-12755 - Added string of Membership record type name - Record Type 1
 *				     V4.6 - Modified - Rajeev jain - 12/07/2018 - Account Merge - Hypercare
 *				     V4.7 - Modified - Victor Hanson - 07/28/2019 - CR-20190520-13117 - Added Institution recordTypeId references
 *				     V4.8 - Modified - Dipesh Gupta - CR-20190726-13240 - 08/06/2019 - Remove the reference of Temporary_Program_Access__c
 *				     V4.9 - Modified - Victor Hanson - 08/07/2019 - CR-20190204-12863 - Added values to support the 'no contact' functionality
 *				     V5.0 - Modified - Dipesh CR-20190620-13190 - Added MEMBER_PAYER_INTEGRATED_GLOBAL
 *				     V5.1 - Modified - Victor Hanson - 04/09/2020 - CR-20200304-13828 - added production tracking and artifact status values
 *				     V5.2 - Modified - Dipesh Gupta - CR-20200221-13792 - added the record type for Es Deployment and Es Project.
 *				     V5.3 - Modified - Dipesh Gupta -- 4/22/2020  --- CR-20200415-13951 --- Change the status "Approved by Client" to "Approved by Partner"
 *				     V5.4 - Modified - Victor Hanson - 05/19/2020 - CR-20200515-14047 - added ARTIFACT_TYPE_LIVE_PROOF_DATA
 *				     V5.5 - Modified - Victor Hanson - 05/27/2020 - CR-20200527-14113 - updated ARTIFACT_TYPE_LIVE_PROOF_DATA
 *				     V5.6 - Modified - Victor Hanson - 08/04/2020 - CR-20200804-14400 - added TIMEZONE_AMERICA_NEWYORK
 *				     V5.7 - Modified - Abhinav Sharma CR-20200821-14466 - Component_type 'BRE' or 'Envelope'
 *				     V5.8 - Modified - Abhinav Sharma CR-20200717-14331
 *				     V5.9 - Modified - Rajeev Jain - 08/18/2020 - CR-20200805-14403 - added APEXJOBSTATUS_QUEUED to CRONTRIGGER_STATE_DELETED
 *				     V6.0 - Modified - Abhinav Sharma - CR-20200821-14466 - Component_type 'BRE' or 'Envelope'
 *				     V6.1 - Modified - Abhinav Sharma - 08/12/2020 - CR-20190826-13286 - Change value from "Prospect - Pending Future Start Date" to "Member - Pending Future Start Date".
 *				     V6.2 - Modified - Mahendra Swarankar - 17/08/2020 - CR-20200427-13986
 *				     V6.3 - Modified - Abhinav Sharma CR-20200717-14438 - add the new costants for SLA tracking Controller.
 *				     V6.4 - Modified - Neha Sharma - 11/06/2020 - CR-20201029-14646
 *				     V6.5 - Modified - Neha Sharma - CR-20201021-14625 - add the new costants for MembershipTriggerHelper.
 *				     V6.6 - Modified - Neha Piproniyan - CR-20200716-14327 - 10/23/2020
 *				     V6.7 - Modified - Mahendra Swarnkar - on 10/24/2020 - CR-20200812-14427
 *				     V6.8 - Modified - Mahendra Swarnkar - 03/17/2020 - CR-20200217-13756
 *				     V6.9 - Modified - Saurabh Kumar - 09/18/2020 - CR-20200819-14449 - added TEAM_MEMBER_PRIMARY_ROLE_EVENT_COORDINATOR			 
 *				     V7.0 - Modified - Saurabh Kumar - 09/28/2020 - CR-20200821-14453 - add constant variables
 *				     V7.1 - Modified - Saurabh Kumar - 09/28/2020 - CR-20200821-14455 - add constant variables
 *				     V7.2 - Modified - Saurabh Kumar - 10/26/2020 - CR-20200821-14454 - Constants are added
 *				     V7.3 - Modified - Abhinav Sharama - CR-20210106-14784 - 01/19/2021 - Size value Other for Job Ticket MTM object
 *				     V7.4 - Modified - Victor Hanson - CR-20201012-14597 - 10/18/2020  added
 *				     V7.5 - Modified - Mahendra Swarnkar - 10/21/2020 - CR-20200715-14321
 *				     V7.6 - Modified - Shalu Sharma - 5/18/21 - CR-20210315-14997
 *				     V7.7 - Modified - Neha Sharma - 05/18/2021 - CR-20181203-12773 - Retain Acquisition Program data upon conversion
 *				     V7.8 - Modified - Saurabh Kumar - 03/03/2021 - CR-20210114-14812 - Constant added
 *				     V7.9 - Modified - Saurabh Kumar - 03/04/2021 - CR-20210302-14960 - Constant added
 *				     V8.0 - Modified - Saurabh Kumar - 04/15/2021 - CR-20210312-14994 - Constants added
 *				     V8.1 - Modified - Saurabh Kumar - 03/25/2021 - CR-20201116-14696 - Constant added
 *				     V8.2 - Modified - Saurabh Kumar - 03/18/2021 - CR-20210128-14855
 *				     V8.3 - Modified - Saurabh Kumar - 04/20/2021 - CR-20210318-15005
 *				     V8.4 - Modified - Saurabh Kumar - 04/07/2021 - CR-20210128-14854
 *				     V8.5 - Modified - Chirag Soni - 05/20/2021 - CR-20201116-14696 - (MRS2.0 UAT Issue Fixes) Added two new status (Invited, Cancelled) Values.
 *				     V8.6 - Modified - Chirag Soni - 06/15/2021 - CR-20201116-14696 - (MRS2.0 UAT Issue Fixes) Removed Registration Requested status.
 *				     V8.7 - Modified - Victor Hanson - 04/22/2021 - CR-20210325-15027
 *				     V8.8 - Modified - Mahendra Swarnakar - 06/18/2021 - CR-20210325-15027
 *				     V8.9 - Modified - Ayush Gupta - 06/08/2021 - CR-20210526-15184 - Added case related Constants
 *				     V9.0 - Modified - Nikita Kumari - 06/10/2021 - CR-20210518-15162 - Added Timecard status "Approved"
 *				     V9.1 - Modified - Shalu Sharma - 06/17/2021 - CR-20200924-14551 - Subscription Period Stages
 *				     V9.2 - Modified - Neha Sharma - 20/7/21 - CR-20210719-15300
 *				     V9.3 - Modified - Ayush Gupta - 08/09/2021 - CR-20210526-15183 - Added survey related constants
 *				     V9.4 - Modified - Ayush Gupta - 08/09/2021 - CR-20210805-15333 - Added Intersect Survey related constants
 *				     V9.5 - Modified - Shalu Sharma - 05/19/2021 - CR-20210423-15103 - Create Instance Type picklist value constant
 *				     V9.6 - Modified - Nikita Kumari - 08/05/2021 - CR-20210316-15000 - Added Contact Role value Other
 *				     V9.7 - Modified - Neha Sharma - 24/8/21 - CR-20210823-15372 - Added Greenlight Institution recordTypeId references
 *				     V9.8 - Modified - Subhash Garhwal - CR-20210722-15306 - 07/16/2021 - Eab MailRoom Management - Constants are added
 *				     V9.9 - Modified - Shalu Sharma - 09/24/2021 - CR-20210922-15453 - JT On demand Drop Type added
 *				     V10.0 - Modified - Chirag Soni - 08/19/2021 - CR-20210818-15367 - Constant modified
 *				     V10.1 - Modified - Chirag Soni - 07/28/2021 - CR-20210716-15294 - Constant added
 *				     V10.2 - Modified - Chirag Soni - 09/14/2021 - CR-20210902-15405 - Constant added
 *				     V10.3 - Modified - Chirag Soni - 09/20/2021 - CR-20210628-15254 - constant added
 *				     V10.4 - Modified - Shalu Sharma - 10/19/2021 - CR-20210924-15459
 *	       			     V10.5 - Modified - Chirag Soni - 09/15/2021 - CR-20210901-15400 - Constant Added
 *	                             V10.6 - Modified - Mahendar Swarnkar - 09/22/2021 - CR-20210909-15418 - Constant Added
 *             			     V10.7 - Modified - Chirag Soni - 11/16/2021 - CR-20211112-15582 - Constant added and commented
 *	       			     V10.8 - Modified - Chirag Soni -  12/03/2021 - CR-20211022-15545 - Enrolllment Service OnSite Record type name is changed to "Onsite"
 *				     V10.9 - Modified - Chirag Soni - 12/21/2021 - CR-20211217-15637
 *	       			     V11.0 - Modified - Shalu Sharma - 01/25/2022 - CR-20220125-15747 - Job Ticket Record Type Constant
 *              		     V11.1 - Modified - Nikita Kumari - 02/08/2022 - CR-20220119-15726 - Opp Record Type Developer Name holder
 *				     V11.2 - Modified - Colin McGloin - CR-20220211-15910 - 02/11/2022 - Constants Added for Permissions Hub
 **/
public without sharing class Constants {
    
    //Added By Mahendra Swarnkar - on 10/24/2020 - CR-20200812-14427 - Starts from here
    public final static Id RECORD_TYPE_ID_OPPORTUNITY_ROYALL = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Royall').getRecordTypeId();
    public final static Id RECORD_TYPE_ID_OPPORTUNITY_PT_MARKETING = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('BI_Marketing').getRecordTypeId();
    public final static Id RECORD_TYPE_ID_OPPORTUNITY_RI_MARKETING = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Core_Marketing').getRecordTypeId();
    
    public final static Id RECORD_TYPE_ID_OPPORTUNITY_PT_CONTRACT_MAINTENANCE = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('BI_Contract_Maintenance').getRecordTypeId();
    public final static Id RECORD_TYPE_ID_OPPORTUNITY_PT_CONTRACT_RENEWAL = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('BI_Contract_Renewal').getRecordTypeId();
    
    public final static String STAGE_OPPORTUNITY_INITIAL_VISIT_SCHEDULED = 'Initial Visit Scheduled';
    public final static String STAGE_OPPORTUNITY_OUTREACH = 'Outreach';
    
    public final static String STAGE_OPPORTUNITY_OPPORTUNITY_IDEBTIFIED = 'Opportunity Identified';
    public final static String STAGE_OPPORTUNITY_PROPOSAL_UNDER_REVIEW = 'Proposal under Review';
    public final static String STAGE_OPPORTUNITY_CONTRACT_UNDER_REVIEW = 'Contract under Review';
    
    public final static String STAGE_OPPORTUNITY_PENDING_RENEWAL_CALL_COMP_EVALUATING = 'Pending- Renewal Call Comp & Evaluating';
    public final static String STAGE_OPPORTUNITY_PENDING_RENEWAL_CALL_COMP_CONTRACTING = 'Pending- Renewal Call Comp & Contracting';
    public final static String DECISION_TYPE_OPPORTUNITY_OPT_OUT = 'Opt Out';
    //Added By Mahendra Swarnkar - on 10/24/2020 - CR-20200812-14427 - Ends here
    
    //Added By Neha Sharma - 5/4/21
    public final static Id RECORD_TYPE_ID_SITE_ISSUE_CCM_DATA_LOAD = Schema.SObjectType.Site_issue__c.getRecordTypeInfosByDeveloperName().get('CCM_Data_Load').getRecordTypeId();
    public final static Id MEMBER_SUPPORT_SSC_RMS_RT_ID = Schema.SObjectType.Site_Issue__c.getRecordTypeInfosByDeveloperName().get('SSC_RMS').getRecordTypeId();
    
    //Added By Mahendra Swarnkar - 10/21/2020 - CR-20200715-14321 - starts from here 
    public final static String SP_RENEWAL_HEALTH_VERBAL = 'Verbal';
    public final static String SP_PROJECTION_LIKELIHOOD_CORRECT = 'Correct';
    public final static String BILLING_SCHEDULE_PERIOD_TYPE_MULTIPLE_SUBSCRIPTION_PERIODS_ASSOCIATED_WITH_THIS_BSP = 'Multiple Subscription Periods associated with this BSP';
    public final static String BILLING_SCHEDULE_PERIOD_TYPE_BILLABLE_FEE = 'Billable Fee';
    public final static String BILLING_SCHEDULE_PERIOD_TYPE_RISK_FEE_OPT_OUT = 'Risk Fee - Opt Out';
    public final static String BILLING_SCHEDULE_PERIOD_TYPE_RISK_FEE_OPT_IN = 'Risk Fee - Opt In';
    public final static String BILLING_SCHEDULE_PERIOD_TYPE_RISK_FEE_OTHER = 'Risk Fee - Other';
    // Added By Mahendra Swarnkar - 10/21/2020 - CR-20200715-14321 - Ends here 
    
    //ATL status value of Contract's Status field
    public final static String STATUS_ATL = 'ATL';
    //Modified - Abhinav Sharma - 08/12/2020 - CR-20190826-13286 - Change value from "Prospect - Pending Future Start Date" to "Member - Pending Future Start Date". 
    public final static String PROSPECT_PENDING_FUTURE_START_DATE = 'Member - Pending Future Start Date';
    public final static String MEMBER_HONORARY = 'Member - Honorary';
    public final static String MEMBER_PAYER = 'Member - Payer';
    public final static String MEMBER_INTEGRATED = 'Member - Integrated';
    public final static String PENDING = 'pending';
    public final static String CONTRACT_RECEIVED = 'contract received';
    public final static String HONORARY = 'Honorary';
    public final static String MEMBER_HONORARY_GRACE = 'Member - Honorary (Grace)';
    public final static String MEMBER_PAYER_GRACE = 'Member - Payer (Grace)';
    public final static String MEMBER_INTEGRATED_GRACE = 'Member - Integrated (Grace)';
    public final static String DROPPED = 'Dropped';
    //Added By Abhinav Sharma CR-20200717-14331
    public final static String ON_TRACK = 'ON TRACK';
    public final static String AT_RISK = 'AT RISK';
    
    //Added By Abhinav Sharma CR-20200717-14438
    public final static String SLA_DATE = 'Date';
    public final static String PT_OBJECT_API_NAME = 'Production_Tracking__c';
    public final static String PRODUCTION_TRACKING_RECORDTYPE_MAIL_SHOP = 'Mail_Shop';
    public final static String CHAR_D = 'd';
    
    
    //Added By Abhinav Sharma CR-20200821-14466 
    //Modify by - Shalu Sharma - 5/18/21 - CR-20210315-14997
    public final static String COMPONENT_TYPE_BRE = 'Reply Envelope (BRE/CRE)';
    public final static String COMPONENT_TYPE_ENVELOPE = 'Envelope';
    
    //Added By Dipesh CR-20190620-13190
    public final static String MEMBER_PAYER_INTEGRATED_GLOBAL = 'Member - Integrated (Global)';
    
    //Updated the VOIDER variable value from Voider to Void - CR-20180608-12273 Modified by Subhash Garhwal
    public final static String VOIDER = 'Void';
    public final static String PROSPECT_RECENT_DROP = 'Prospect - Recent Drop';
    //Modified - Abhinav Sharma - 08/12/2020 - CR-20190826-13286 - Comment Out PROSPECT_PENDING_FUTURE_START
    //public final static String PROSPECT_PENDING_FUTURE_START = 'Prospect - Pending Future Start';
    public final static String PROSPECT_PAST_MEMBER = 'Prospect - Past Member';
    public final static String PROSPECT_PURE = 'Prospect - Pure';
    public final static String CLOSED = 'Closed';
    public final static String PAYER = 'Payer';
    //Added By Mahendra - 17/08/2020 - CR-20200427-13986
    public final static String PAYER_STATUS_INTEGRATED = 'Integrated';
    public final static String PAYER_STATUS_INTEGRATED_GLOBAL = 'Integrated - Global';
    
    public final static String EVENT_TYPE_OPPORTUNITY_VISIT_FOR_OPPORTUNITY_GOAL = 'Opportunity Visit - For Opportunity Goal';
    public final static String EVENT_TYPE_IN_PERSON_VISIT = 'In Person Visit';
    public final static String EVENT_TYPE_ADDITIONAL_CONTACT_MEETING = 'Additional Contact Meeting';
    public final static String EVENT_TYPE_PROSPECT_MEETING_ATTENDEE_COUNT_AS_VISIT = 'Prospect Meeting Attendee - Count as Visit';
    public final static String NEGATIVE_FEEDBACK_PRODUCT = 'Product';
    public final static String NEGATIVE_FEEDBACK_PRODUCT_AND_MARKETING = 'Product & Marketing';
    public final static String NEGATIVE_FEEDBACK_MARKETING = 'Marketing';
    public final static String EMAIL_SUBJECT_DISTRIBUTION_LIST = 'QA Call with Negative Feedback';
    public final static String YES = 'Yes';
    public final static String ACTIVE = 'Active';
    public final static String MEMBER = 'Member';
    public final static String CLOSED_WON = 'Closed Won';
    public final static String CLOSED_LOST = 'Closed Lost';
    public final static String DISQUALIFIED = 'Disqualified';
    public final static String RESTRICTION_UPDATED_NOTIFICATION = 'Restriction_Updated_Notification';
    public final static String ERROR_CANNOT_ADD_CONTACT_TO_INACTIVE_INSTITUTION = 'New Contacts cannot be added to non-Active Institutions.';
    public final static String ERROR_NO_CONTACT_ERROR = 'No contact associated with account(s) or No contact have valid email address.';
    public final static String ERROR_NO_RESTRICTION_EMAIL_TEMPLATE_DEFINED = 'No email template defined for restriction notifiction';
    public final static String ERROR_CHANGE_REQUEST_EMAIL_HANDLER_NO_USER_EXITS = 'No user exist with this email Id';
    public final static String SALESFORCE_HELP = 'Salesforce Help';
    public final static String STATUS_WARM_LEAD_PENDING_RESTRICTION_CLEARANCE = 'Pending Restriction Clearance';
    public final static String RENEWAL = 'Renewal';
    public final static String EVENT_PURPOSE_INITIAL = 'Initial';
    public final static String EVENT_PURPOSE_RELATIONSHIP_VISIT = 'Relationship Visit';
    public final static String INACTIVE_UNSUBSCRIBED_BY_MEMBER = 'Inactive - Unsubscribed by Member';
    public final static String BLANK = '';
    public final static String SPACE = ' ';
    public final static String COMMA = ',';
    public final static String CHAR_DOUBLEQUOTE = '\"';
    public final static String STAGE_OPPORTUNITY_CLOSED_LOST = 'Closed Lost';
    public final static String STAGE_OPPORTUNITY_VOID = 'Void';
    public final static String STAGE_OPPORTUNITY_DROPPED = 'Dropped';
    public final static String STATUS_AGREEMENT_CANCELLED_DECLINED = 'Cancelled / Declined';
    public final static String STATUS_AGREEMENT_OUT_FOR_SIGNATURE = 'Out for Signature';
    public final static String STATUS_AGREEMENT_SIGNED = 'Signed';
    public final static String STATUS_OSR_PENDING_APPLICATION = 'Pending Application';
    public final static String STATUS_OSR_PENDING_FINANCE = 'Pending Finance';
    public final static String PROFILE_ABC_DATA_LOADER = 'ABC Dataloader';
    public final static String STATUS_MEMBER_UTILIZATION_CANCELLED = 'Cancelled';
    
    //Neha Sharma - 08/23/2021 - CR-20210823-15372 - Added Greenlight Institution recordTypeId references
    public final static String RECORD_TYPE_ACCOUNT_GREENLIGHT = 'Greenlight';
    public static final Id ACCOUNT_RT_ID_GREENLIGHT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(RECORD_TYPE_ACCOUNT_GREENLIGHT).getRecordTypeId();
    
    //Record Types
    public final static String RECORD_TYPE_OPPORTUNITY_PT_CONTRACT_MAINTENANCE = 'PT Contract Maintenance';
    public final static String RECORD_TYPE_OPPORTUNITY_PT_CONTRACT_RENEWAL = 'PT Contract Renewal';
    //Commented by Mahendra Swarnkar - 03/17/2020 - CR-20200217-13756 - RT deleted : RI AM First Year Opp
    //public final static String RECORD_TYPE_OPPORTUNITY_RI_AM_FIRST_YEAR_OPP = 'RI AM First Year Opp';
    //Commented by Mahendra Swarnkar - 03/17/2020 - CR-20200217-13756 - RT deleted :RI AM Standard Opp
    //public final static String RECORD_TYPE_OPPORTUNITY_RI_AM_STANDARD_OPP = 'RI AM Standard Opp';
    public final static String RECORD_TYPE_EVENT_DEVELOPER_NAME_BI_QA_CALL = 'BI_QA_Call';
    public final static String RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CCC_DATA_LOAD = 'CCC_Data_Load';
    public final static String RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CCA_DATA_LOAD = 'CCA_Data_Load';
    public final static String RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CRIMSON_SUPPORT_REQUEST = 'Crimson_Support_Request';
    public final static String RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CMA_DATA_LOAD_MIGRATION = 'CMA_Data_Load_Production';
    public final static String RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_COMPASS_SUPPORT_ISSUE = 'Compass_Support_Issue';
    public final static String RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CMA_INITIAL_DEPLOYMENT_SUPPORT = 'CMA_Data_Load';
    public final static String RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CPM_DATA_LOAD = 'CPM_Data_Load';
    public final static String RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CCI_DATA_LOAD = 'CCI_Data_Load';
    public final static String RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_EHBI_DATA_LOAD = 'EHBI_Data_Load';
    public final static String RECORD_TYPE_DEPLOYMENT_COMPASS_CONNECT_DEPLOYMENT = 'Compass Connect Deployment';
    public final static String RECORD_TYPE_DEPLOYMENT_CMA_DEPLOYMENT = 'CMA Deployment';
    public final static String RECORD_TYPE_CALL_DEVELOPER_NAME_NPD = 'NPD';
    //Commented by Mahendra Swarnkar - 03/05/2020 - CR-20200217-13756: RT deleted: PT Support Request
    //public final static String RECORD_TYPE_CASE_PT_SUPPORT_REQUEST = 'zzzPT Support Request';
    
    //Commented by Mahendra Swarnkar - 03/05/2020 - CR-20200217-13756: RT deleted- PT Data Load
    //public final static String RECORD_TYPE_CASE_PT_DATA_LOAD = 'zzzPT Data Load';
    public final static String RECORD_TYPE_SITE_ISSUE_CCA_DATA_LOAD = 'CCA Data Load';
    public final static String RECORD_TYPE_SITE_ISSUE_CCA_SUPPORT_REQUEST = 'Crimson Support Request';
    public final static String RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CCA_SUPPORT_REQUEST = 'CCA_Support_Request';
    
    
    //Added by - Mahendra Swarnkar - 11/04/2016 - CR-20160927-10190 - New variable is added for Member Support record type
    public final static String RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_ARx_Data_Load = 'ARx Data Load';
    
    //Added by - Mahendra Swarnkar - 11/04/2016 - CR-20160927-10190 - New variable is added for Member Support API name
    public final static String MEMBER_SUPPORT_API_NAME = 'Site_Issue__c';
    
    //Commented by Mahendra Swarnkar - 03/05/2020 - CR-20200217-13756: RT deleted: PT Support Request
    //public final static String RECORD_TYPE_CASE_DEVELOPER_NAME_PT_SUPPORT_REQUEST = 'PT_Support_Request';
    
    //Commented by Mahendra Swarnkar - 03/05/2020 - CR-20200217-13756: RT deleted: PT DataLoad
    //public final static String RECORD_TYPE_CASE_DEVELOPER_NAME_PT_DATA_LOAD = 'PT_DATA_LOAD';
    //Added By Bhavi Sharma - 04/18/2014 - CR-20140414-5064
    public final static String RECORD_TYPE_ACCOUNT_DEVELOPER_NAME_INTERNATIONAL_EDUCATION = 'International_Education';
    public final static String RECORD_TYPE_ACCOUNT_DEVELOPER_NAME_US_EDUCATION = 'US_Education';
    public final static String RECORD_TYPE_ACCOUNT_DEVELOPER_NAME_US_INDEPENDENT_SCHOOL = 'US_Independent_School';
    //Added by Victor Hanson - 01/27/2015
    public final static Id RECORD_TYPE_ID_ADV_EVENT_SERIES = Schema.SObjectType.Advisory_Event__c.getRecordTypeInfosByName().get('Series').getRecordTypeId();
    
    // Modified from content session to included session w.r.t CR-20201116-14696
    public final static Id RECORD_TYPE_ID_ADV_EVENT_SESSION = Schema.SObjectType.Advisory_Event__c.getRecordTypeInfosByName().get('Included Session').getRecordTypeId();
    public final static Id RECORD_TYPE_ID_ADV_EVENT_EVENT = Schema.SObjectType.Advisory_Event__c.getRecordTypeInfosByName().get('Event').getRecordTypeId();
    
    //Modified By - Chirag Soni  -  08/19/2021 - CR-20210818-15367 - Recordtype label is changed from "Vendor or Venue" to "Event Venue"
    public final static Id RECORD_TYPE_ID_ACCOUNT_VENUE = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Event Venue').getRecordTypeId();
    
    //Added by Mahendra Swarnakar - 11/04/2020
    public final static Id RECORD_TYPE_ID_ACTION_PLANS = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Action Plans').getRecordTypeId();
    
    //Added by Neha Piproniyan - CR-20200716-14327 - 10/23/2020
    public final static Id RECORD_TYPE_ID_SYNDICATED_RESEARCH = Schema.SObjectType.Event.getRecordTypeInfosByName().get('Syndicated Research').getRecordTypeId();
    public final static Id RECORD_TYPE_ID_MEMBER_SUCCESS = Schema.SObjectType.Event.getRecordTypeInfosByName().get('Member Success').getRecordTypeId();
    
    
    //Added by Neha Sharma - 11/06/2020 - CR-20201029-14646
    //Commented by - chirag Soni - 11/16/2021 - CR-20211112-15582 - Constant Commented
    //public final static Id RECORD_TYPE_ID_LEGACY_CAPPEX = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Legacy Cappex').getRecordTypeId();
    
    //Added by Saurabh Kumar - 11/06/2020 - Replacing Series Record Type with Cohort Record Type
    public final static Id RECORD_TYPE_ID_ADV_EVENT_COHORT = Schema.SObjectType.Advisory_Event__c.getRecordTypeInfosByName().get('Cohort').getRecordTypeId();
    public final static Id RECORD_TYPE_ID_ADV_EVENT_BREAKOUT = Schema.SObjectType.Advisory_Event__c.getRecordTypeInfosByName().get('Breakout').getRecordTypeId();
    
    //Modified - Saurabh Kumar - 04/15/2021 - CR-20210225-14949/CR-20210312-14994 - Constants added - Conference Record Type
    //Modified - Chirag Soni - 05/13/2021 - CR-20210505-15123 - Onsite record type label changed to Enrollment Services Onsite
    //Updated to - Chirag Soni -  12/03/2021 - CR-20211022-15545 - Enrolllment Service OnSite Record type name is changed to "Onsite"
    public final static Id RECORD_TYPE_ID_EAB_EVENT_ONSITE = Schema.SObjectType.Advisory_Event__c.getRecordTypeInfosByName().get('Onsite').getRecordTypeId();
    public final static Id RECORD_TYPE_ID_EAB_EVENT_CONFERENCE = Schema.SObjectType.Advisory_Event__c.getRecordTypeInfosByName().get('Conference').getRecordTypeId();
    
    //Added by Victor Hanson - 03/13/2018
    public final static Id RECORD_TYPE_ID_SUBSCRIPTION_COMPONENT = Schema.SObjectType.SBQQ__Subscription__c.getRecordTypeInfosByName().get('Component').getRecordTypeId();
    public final static Id RECORD_TYPE_ID_SUBSCRIPTION_PROGRAM = Schema.SObjectType.SBQQ__Subscription__c.getRecordTypeInfosByName().get('Program').getRecordTypeId();
    
    //Added By Subhash Garhawal - 10/11/2018 - CR-20180720-12456
    public final static Id RECORD_TYPE_ID_SUBSCRIPTION_OFFER = Schema.SObjectType.SBQQ__Subscription__c.getRecordTypeInfosByName().get('Offer').getRecordTypeId();
    public final static Map<String,Id> MAP_SUBSCRIPTION_RTYPE  = new Map<String, Id>{
									    		CPQConstants.SBQQ_SUBSCRIPTION_RECORD_TYPE_DEVELOPERNAME_COMPONENT =>   RECORD_TYPE_ID_SUBSCRIPTION_COMPONENT, 
									            	CPQConstants.SBQQ_SUBSCRIPTION_RECORD_TYPE_DEVELOPERNAME_PROGRAM => RECORD_TYPE_ID_SUBSCRIPTION_PROGRAM,
									            	CPQConstants.SBQQ_SUBSCRIPTION_RECORD_TYPE_DEVELOPERNAME_OFFER => RECORD_TYPE_ID_SUBSCRIPTION_OFFER
									            };
                
    public final static Boolean BYPASS_SUBSCRIPTION_TRIGGER = false;
    //Membership record type - API name 
    public final static string MEMBERSHIP_RECORD_TYPE_RECORD_TYPE_1 = 'Record_Type_1';
    
    //Added Constants on - 03/11/2014 - Abhinav Sharma - CR-20140108-4243 - CMA - MS - Version Workflow Update
    //updated contacts on - 08/15/2016 - Victor Hanson - CR-20160519-9863 - updated string value
    public final static String STATUS_X_DUPLICATE_CANCELLED = 'Duplicate/Cancelled';
    
    //Added Constants on - 03-14-2014 - Abhinav Sharma -  CR-20131107-3938
    public final static String STATUS_22_PRODUCTION_MIGRATION_COMPLETE = '22 - Production Migration Complete';
    
    //Added Constants on - 03-14-2014 - Abhinav Sharma -  CR-20131107-3938
    public final static String STATUS_MIGRATION_COMPLETE = 'Migration complete';
    
    //Event Record Type
    public final static String RECORD_TYPE_EVENT_DEVELOPER_NAME_PT_AM = 'BI_AM';
    public final static String RECORD_TYPE_EVENT_DEVELOPER_NAME_RI_AM = 'Core_AM';
    public final static String RECORD_TYPE_EVENT_DEVELOPER_NAME_TD_AM = 'TD_AM';
    public final static String RECORD_TYPE_EVENT_DEVELOPER_NAME_PT_MARKETING = 'BI_Marketing';
    public final static String RECORD_TYPE_EVENT_DEVELOPER_NAME_RI_MARKETING = 'Core_Marketing';
    
    //Event Visit Location picklist value
    public final static String VISIT_LOCATION_EXTERNAL_EVENT_CONFERENCE = 'Event/Conference';
    public final static String VISIT_LOCATION_OTHER_NON_MQL = 'Other';
    public final static Set<String> SET_VISIT_LOCATION_EXCULDE_IVD = new Set<String>{'Other','Event/Conference','EAB Hosted Event'};
        
    //CR-20140214-4512
    public final static String RECORD_TYPE_TASK_DEVELOPER_NAME_TESTIMONIALS = 'Testimonials';
    public final static String TASK_SUBJECT_MEMBER_IMPACT_STORY = 'Member Impact';
    
    //Added constants on - 03/13/2014 - Ajit Surana - CR-20140205-4458
    public final static String EDITABLE_FIELD_AFTER_OPP_IS_CLOSED = 'Editable field after Opp is closed';
    public final static String PROFILE_EDIT_FIELDS_WHEN_OPP_IS_CLOSED = 'Profile edit fields when Opp is closed';
    public final static String STAGE_OPPORTUNITY_SENT_TO_FINANCE_OPP_REJECTED = 'Sent to Finance - Opp Rejected';
    
    //Added constants on - 07/18/2013 - Bhavi Sharma - Version Issue with 'CMA' contained record type
    public final static String CMA = 'CMA';
    
    //Added Constants on - 4/24/2013 - Bhavi Sharma
    public final static String CURRENT = 'Current';
    
    //Rajeev -10/19/2016 - Manaual merged from Services Ex
    public final static String HISTORICAL_RELOAD = 'Historical';
    //public final static String HISTORICAL_RELOAD = 'Historical/Reload';
    //Rajeev -10/19/2016 - Manaual merged from Services Ex - upto here
    
    public final static String CRIMSON_SUPPORT_REQUEST_SITE_ISSUE_SUPPORT_CATEGORY_PRODUCTION_MIGRATION = 'Production Migration';
    
    //Added Constants on - 1/21/2015 - Ajit Surana - CR-20150102-8430
    public final static String SITE_BUILD = 'Site Build';
    public final static String PART_OF_BUILD = 'Part of Build';
    
    //Added Constants on - 06/12/2013 - Bhavi Sharma - CR-20120716-1142
    public final static String EMAIL_TEMPLATE_DATA_LOAD = 'DATA LOAD EMAIL TEMPLATE';
    public final static String STATUS_SITE_ISSUE_22_SENT_EMAIL_UPDATE = '22- Sent Email Update';
    
    //Updated Constants on - 08/15/2016 - Victor Hanson - CR-20160519-9863
    public final static String STATUS_SITE_ISSUE_CLOSED = 'Closed';
    
    //V1.23 - Modified by - Rajeev Jain - 11/22/2016 - Services Excellence - UAT Issue fix - Added new constants
    public final static String STATUS_SITE_ISSUE_PENDING_CLOSED = '09-Pending Closed';
    public final static String STATUS_SITE_ISSUE_TEN_CLOSED = '10-Closed';
    //V1.23 - Modified by - Rajeev Jain - 11/22/2016 - Services Excellence - UAT Issue fix - Added new constants - upto here
    
    public final static String STATUS_SITE_ISSUE_10_CLOSED_MEMBER_NOTIFIED = '10 - Closed, Member Notified';
    public final static String ORG_WIDE_EMAIL_DISPLAY_NAME_CRIMSON_SUPPORT = 'CrimsonSupport';
    public final static String PROJECT_NAME_CCC = 'CCC';
    
    //Added Constants on - 06/13/2013 - Bhavi Sharma - CR-20130228-2612
    public final static String RECORD_TYPE_MEMBER_INTERACTION_QA_CALL = 'QA Call';
    public final static String RECORD_TYPE_CONTACT_NAME_EMPLOYEE = 'Employee';
    
    //Added Constants on - 06/13/2013 - Bhavi Sharma - CR-20121130-1808
    public final static String RECORD_TYPE_NAME_WARM_LEAD_STANDARD = 'Standard';
    
    //Added Constants on - 12/20/2013 - Bhavi Sharma - CR-20130925-3694
    public final static String MEMBER_INTERACTION_CURRENT_STATUS_COMPLETED = '7 - Completed';
    
    //Added Constants on - 07/03/2014 - Abhinav Sharma - CR-20140618-5845
    public final static String RIAM_LARGE_CONTRACTS = 'RIAMLargeContract';
    
    //Commneted  by Mahendra Swarnkar - 03/05/2020 - CR-20200217-13756
    //Added Constants on - 07/04/2014 - Abhinav Sharma -  CR-20140629-6015
    //public final static String CASE_RECORD_TYPE_IRC_REQUEST = 'IRC_Request';
    public final static String IRC_REQUEST_RESPONSE = 'IRC Request Response';
    public final static String CASE_NUMBER = 'Case Number';
    public final static String COLON = ':';
    public final static String ACCT_MGR = 'AcctMgr';
    public final static String MEMBER_READY_RESPONSE = 'Member Ready Response';
    public final static String IRCREQUEST = 'IRCRequest';
    
    //Added Constants on - 08/05/2014 - Abhinav Sharma - CR-20140610-5761
    //Start From Here
    public static Map<string, integer> MAP_WARM_LEAD_EVENTS {
        get {
            //Map to hold the warm lead event values proceedings
            map<string, integer> mapLeadEvents = new map<string, integer>();
            mapLeadEvents.put('Direct to Visit', 1);
            mapLeadEvents.put('Prospect Meeting', 2);
            mapLeadEvents.put('Breakout', 3);
            mapLeadEvents.put('HSPI Summit', 4);
            mapLeadEvents.put('Strategy Retreat', 5);
            mapLeadEvents.put('Webinar', 6);
            mapLeadEvents.put('Tradeshow', 7);
            mapLeadEvents.put('Speaking Engagement', 8);
            mapLeadEvents.put('CG - Archived Webinar', 9);
            mapLeadEvents.put('CG - Research', 10);
            mapLeadEvents.put('CG - Case Study', 11);
            mapLeadEvents.put('CG - Tool', 12);
            mapLeadEvents.put('CG - Whitepaper', 13);
            mapLeadEvents.put('CG - Benchmarks', 14);
            mapLeadEvents.put('CG - Video', 15);
            mapLeadEvents.put('CG - Infographic', 16);
            mapLeadEvents.put('Request Access', 17);
            mapLeadEvents.put('Other', 18);
            return mapLeadEvents;
        }
    }
    //Upto Here
    
    //Added Constants on - 08/06/2014 - Abhinav Sharma -  - CR-20140707-6093
    //Start From Here
    public static Set<String> SET_OOO_AND_AUTOMATIC_REPLY {
        get {
            Set<String> setoutOfOfficesStrings = new Set<String>();
            setoutOfOfficesStrings.add('out of offices');
            setoutOfOfficesStrings.add('out of office');
            setoutOfOfficesStrings.add('out of the office');
            setoutOfOfficesStrings.add('ooo');
            setoutOfOfficesStrings.add('automatic reply');
            return setoutOfOfficesStrings;
        }
    }
    public final static string CASE_RECORD_TYPE_MEMBER_EMPLOYEE_SUPPORT = 'Member_Employee_Support';
    public final static string CASE_OBJECT = 'Case';
    public final static string QUEUE_EVENTS_MEMBER_SUPPORT = 'Events & Member Support';
    public final static string EMAIL = 'Email';
    //Upto Here
    
    //Added By - Abhinav Sharma - 08/12/2014 - CR-20140425-5234
    //Start From Here
    public final static string LI_Tag = 'ii';
    public final static string LESS_THAN = '<';
    public final static string GREATER_THAN = '>';
    public final static string IMAGE_TAG = 'image';
    public final static string ATTACHMENT_LINK_PREFIX = '/servlet/servlet.FileDownload?file=';
    //Upto Here
    
    //Added By - Abhinav Sharma - 08/13/2014 - CR-20140604-5691
    //Start FROM Here
    public static Set<String> SET_INSTITUTION_INACTIVE_TYPE_STATUS {
        get {
            Set<String> setOfStatuses = new Set<String>();
            setOfStatuses.add('Inactive - Closed');
            setOfStatuses.add('Inactive - Duplicate');
            setOfStatuses.add('Inactive - Other');
            return setOfStatuses;
        }
    }
    //Upto here
    
    //Added By - Abhinav Sharma - 08/14/2014 - CR-20140723-6571
    //Start FROM Here
    public static Set<String> SET_REGISTRATION_CANCELLED_STATUS {
        get {
            Set<String> setCancelledStatuses = new Set<String>();
            setCancelledStatuses.add('Cancelled');
            setCancelledStatuses.add('VOID');
            return setCancelledStatuses;
        }
    }
    public final static string ERROR_ALREADY_REGISTERED = 'ERROR_ALREADY_REGISTERED';
    //Upto here
    
    //Get IS CRM queue id
    public static Id QUEUE_ID_IS_CRM {
        get {
            
            //get the IS CRM queue Id
            List<Group> isCRM = [Select Id from Group where Name = 'IS CRM'];
            
            //Check if IS CRM queue is there
            if(isCRM.size() > 0)
                return isCRM[0].Id;
            
            return null;
        }
    }
    
    // get the Salesforce Administrator User's ID
    //Refactored By Doug Roberts - 08/31/2015 - Removed constant definition and updated code to point to custom label
    //public static Id SF_ADMIN_USER_ID {
    //  get {
    //          if (SF_ADMIN_USER_ID == null) {
    //              SF_ADMIN_USER_ID = [SELECT Id FROM User WHERE Name = 'Salesforce Administrator' LIMIT 1].Id;
    //          }
    //          return SF_ADMIN_USER_ID;
    //      }
    //  set;
    //  }
    
    public final static String CONTACT_STATUS_ACTIVE = 'Active';
    public final static String CONTACT_STATUS_INACTIVE = 'Inactive';
    public final static String CONTACT_RECORD_TYPE_DEVELOPER_NAME_EMPLOYEE = 'Employee';
    
    //
    public final static String PROJECT_PUNCTUALITY_OF_LOADS_TYPICALLY_LATE = 'Typically Late';
    public final static String PROJECT_PUNCTUALITY_OF_LOADS_ALWAYS_ON_TIME = 'Always on Time';
    public final static String PROJECT_PUNCTUALITY_OF_LOADS_TBD = 'TBD';
    
    //Added By Bhavi
    public static Set<String> SET_UNITED_STATES = new Set<String>{'us', 'usa', 'united state', 'united states'};
        
    //Added by Ajit Surana - 03/13/2014 - CR-20140205-4458
   /**
    *  @description  :  This varibale is to create a static Map of custom Setting, so it is not being queried all the timeting) and return set
    *                   Key = Parameter Key, Value = List<Parameter Values>
    *
    *  @args         :
    *
    *  @return       :  Map<String, List<Configuration_Manager__c>>
    *
    **/
        public static Map<String, Set<String>> MAP_CONFIGURATION_MANAGER {
            
            get {
                if(MAP_CONFIGURATION_MANAGER == null) {
                    
                    MAP_CONFIGURATION_MANAGER = new Map<String, Set<String>>();
                    
                    //Get all values from custom setting
                    List<Configuration_Manager__c> configs = Configuration_Manager__c.getAll().values();
                    
                    //Loop through all the custom setting records
                    for(Configuration_Manager__c config : configs) {
                        
                        //Check if Parameter Key is not null
                        if(String.IsBlank(config.Parameter_Key__c))
                            continue;
                        
                        //Check if map already has Parameter Key
                        if(MAP_CONFIGURATION_MANAGER.containsKey(config.Parameter_Key__c))
                            MAP_CONFIGURATION_MANAGER.get(config.Parameter_Key__c).add(config.Parameter_Value__c.toLowerCase());
                        else
                            MAP_CONFIGURATION_MANAGER.put(config.Parameter_Key__c, new Set<String>{config.Parameter_Value__c.toLowerCase()});
                    }
                }
                return MAP_CONFIGURATION_MANAGER;
            }
            set;
        }
    
    //JRB 2013-12-17 Constant added for CR-20130610-3134
    public static final Set<String> SORT_IGNORE_WORDS = new Set<String>{'A','AN','THE'};
        
    //Bhavi Sharma - 04/18/2014 - CR-20140224-4597
    public static final String WL_LEAD_EVENT_SCHEMA_ID = 'WL_Lead_Event_Schema_Id';
    
    //VH 8/10/16 CR-9863
    public static final string SITE_ISSUE_WAITING_FOR_FILES = 'Waiting for files';
    public static final string SITE_ISSUE_02_ACKNOWLEDGED = '02-Acknowledged';
    
    //Constants added for CR-4283
    public static final string ERROR_MODS_NOT_AVAILABLE_TO_TIER_I = 'Mirrored fields cannot be modified on the Case record.  ' +
        															'Please have the Tier II group update the record.';
    public static final string ERROR_MODS_NOT_AVAILABLE_TO_TIER_II_OR_III = 'Mirrored fields cannot be modified on the Member Support record.  ' +
        																	'Please have the Tier I group update the record.';
    public static final string SITE_ISSUE_TIER_I = 'Tier I';
    public static final string SITE_ISSUE_TIER_II = 'Tier II';
    public static final string SITE_ISSUE_TIER_III = 'Tier III';
    public static final string SITE_ISSUE_STATUS_MEMBER_INPUT_REQUESTED = '03.1 - Member Input Required';
    
    //Rajeev - 10/19/2016 - Manaual merged from Services Ex to Test SB
    public static final string SITE_ISSUE_STATUS_RESPONSE_NEEDED_EXTERNAL = '04.2-Response needed - External';
    
    public static final string COMMUNITY_CASE_VIEW_MY_CASES = 'My Cases';
    public static final string COMMUNITY_CASE_VIEW_ALL_PROJECT_CASES = 'All Project Cases';
    public static final string CASE_STATUS_01_NEW = '01-New';
    public static final string CASE_STATUS_02_ACKNOWLEDGED = '02-Acknowledged';
    
    //Rajeev - 10/19/2016 - Manaual merged from Services Ex to Test SB
    public static final string CASE_STATUS_03_IN_PROGRESS = '03-In Progress';
    public static final string CASE_STATUS_10_CLOSED = '10-Closed';
    //Rajeev - 10/19/2016 - Manaual merged from Services Ex to Test SB - upto here
    
    public static final string CASE_STATUS_10_IN_PROGRESS = '10-In Progress';
    public static final string CASE_STATUS_90_CLOSED = '90-Closed';
    public static final string ERROR_CANNOT_TRANFER_TIER_II = 'Case must be Tier I in order to transfer to Tier II.';
    public static final string SIAM_PORTAL_STATUS_ACTIVE = 'Active';
    public static final string SIAM_PORTAL_STATUS_INACTIVE = 'Inactive';
    
    //Commented by Mahendra Swarnkar - 03/05/2020 - CR-20200217-13756: RT deleted: PT Support Request - START HERE
    /*public static Id RECORD_TYPE_ID_CASE_PT_SUPPORT {
    get {
    if (RECORD_TYPE_ID_CASE_PT_SUPPORT == null) {
    RECORD_TYPE_ID_CASE_PT_SUPPORT = Util.RecordTypeId('Case', RECORD_TYPE_CASE_PT_SUPPORT_REQUEST);
    }
    return RECORD_TYPE_ID_CASE_PT_SUPPORT;
    }
    set;
    }*/
    //Commented by Mahendra Swarnkar - 03/05/2020 - CR-20200217-13756: RT deleted: PT Support Request - END HERE
    
    //Commented by Mahendra Swarnkar - 03/04/2020 - CR-20200217-13756 ; RT deleted PT Data Load
    /*public static Id RECORD_TYPE_ID_CASE_PT_DATA_LOAD {
    get {
    if (RECORD_TYPE_ID_CASE_PT_DATA_LOAD == null) {
    RECORD_TYPE_ID_CASE_PT_DATA_LOAD = Util.RecordTypeId('Case', RECORD_TYPE_CASE_PT_DATA_LOAD);
    }
    return RECORD_TYPE_ID_CASE_PT_DATA_LOAD;
    }
    set;
    }*/
    
    public static Id RECORD_TYPE_ID_SITE_ISSUE_CCA_SUPPORT_REQUEST {
        get {
            if (RECORD_TYPE_ID_SITE_ISSUE_CCA_SUPPORT_REQUEST == null) {
                RECORD_TYPE_ID_SITE_ISSUE_CCA_SUPPORT_REQUEST = Util.RecordTypeId('Site_Issue__c', RECORD_TYPE_SITE_ISSUE_CCA_SUPPORT_REQUEST);
            }
            return RECORD_TYPE_ID_SITE_ISSUE_CCA_SUPPORT_REQUEST;
        }
        set;
    }
    
    public static Id RECORD_TYPE_ID_SITE_ISSUE_CCA_DATA_LOAD {
        get {
            if (RECORD_TYPE_ID_SITE_ISSUE_CCA_DATA_LOAD == null) {
                RECORD_TYPE_ID_SITE_ISSUE_CCA_DATA_LOAD = Util.RecordTypeId('Site_Issue__c', RECORD_TYPE_SITE_ISSUE_CCA_DATA_LOAD);
            }
            return RECORD_TYPE_ID_SITE_ISSUE_CCA_DATA_LOAD;
        }
        set;
    }
    public static list<Sync_Field__c> SYNC_FIELDS_LIST {
        get {
            if (SYNC_FIELDS_LIST == null) SYNC_FIELDS_LIST = Sync_Field__c.getall().values();
            return SYNC_FIELDS_LIST;
        }
        set;
    }
    
    
    //Tier2Unassigned queue.  Queue is assigned when changing from Tier 1 to Tier 2
    public static Group tier2SupportQueue {
        get {
            if (tier2SupportQueue == null) {
                list<Group> queues = [SELECT Id FROM Group WHERE DeveloperName = 'Tier_II_Support' AND Type = 'Queue'];
                if (queues.size() > 0) tier2SupportQueue = queues[0];
            }
            return tier2SupportQueue;
        }
        set;
    }
    
    //Tier1Support queue
    public static Group tier1SupportQueue {
        get {
            if (tier1SupportQueue == null) {
                list<Group> queues = [SELECT Id FROM Group WHERE DeveloperName = 'Tier_I_Support' AND Type = 'Queue'];
                if (queues.size() > 0) tier1SupportQueue = queues[0];
            }
            return tier1SupportQueue;
        }
        set;
    }
    
    //Tier1Unassigned queue.  Queue is assigned when creating a case from the portal
    public static Group tier1UnassignedQueue {
        get {
            if (tier1UnassignedQueue == null) {
                list<Group> queues = [SELECT Id FROM Group WHERE DeveloperName = 'Tier_I_Unassigned' AND Type = 'Queue'];
                if (queues.size() > 0) tier1UnassignedQueue = queues[0];
            }
            return tier1UnassignedQueue;
        }
        set;
    }
    //JRB*/
    
    //Added By - Abhinav Sharma - CR-20150914-9243 - 11/27/2015
    //Starts from here
    public static final string CASE_RECORD_TYPE_EAB_CUSTOM = 'EAB_Custom';
    public static final string REFERENCE_STR = 'referenceString';
    public static final string TYPE_PARAMETER = 'type';
    //Upto Here
    
    //Added By - Abhinav Sharma - CR-20151118-9397 - 12/22/2015
    //Starts from here
    public static final string CASE_ORIGIN_MEETINGS = 'Meetings';
    public static final string CASE_ORIGIN_WEBCONFERENCES = 'Webconferences';
    public static final string CASE_ORIGIN_CONFERENCE_ROOM_REQUESTS = 'ConferenceRoomRequests';
    public static final string CASE_ORIGIN_TRAVEL = 'Travel';
    public static final string CASE_ORIGIN_VOICE_MAIL = 'Voice Mail';
    public static final string CASE_ORIGIN_ADVISORY = 'Advisory';
    public static final string CASE_ORIGIN_EAB = 'EAB';
    public static final string CASE_ORIGIN_ABI = 'ABI';
    public static final string CASE_ORIGIN_DATA_INTEGRATIONS = 'Data Integrations';
    public static final String CASE_ORIGIN_EMAIL_TO_CASE_DATA_INTEGRATIONS = 'Email to Case: Data Integration';
    public static final string CASE_ORIGIN_EAB_MEETINGS = 'EAB Meetings';
    public static final String CASE_RECORD_TYPE_WEBHELP = 'WebHelp';
    public static final String QUEUE_NAME_EVENTS_MEMBER_SUPPORT = 'Events_Member_Support';
    public static final String QUEUE_NAME_EVENTS_MEMBER_SUPPORT_HC = 'Events_Member_Support_HC';
    public static final String QUEUE_NAME_WEBHELP = 'WebHelp';
    public static final String QUEUE_NAME_WEBHELP_HC = 'WebHelp_HC';
    public static final String QUEUE_NAME_DATA_INTEGRATIONS = 'Data_Integrations';
    public static final String CASE_RECORD_TYPE_ETECH_SUPPORT = 'eTech_Support';
    public static final String MAILER_DAEMON_ADVISORY_COM = 'mailer-daemon@advisory.com';
    public static final String SPAM_FILTER_ADVISORY_COM = 'spamfilter@advisory.com';
    //Upto Here
    //Added by Abhinav sharma - CR-20180928-12623 - 10/11/2018 - Case web help record type id. 
    public static final String CASE_WEBHELP_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByName().get(CASE_RECORD_TYPE_WEBHELP).getRecordTypeId();
    
    
    //Rajeev - 10/19/2016 - Manaual merged from Services Ex to Test Sb
    //(Code Added) - Rajeev Jain - 08/03/2016 - CR-20160519-9863 - Services Excellence
    public static final String MEMBER_SUPPORT_STATUS_ACKNOWLEDGE = '02-Acknowledged';
    public static final String MEMBER_SUPPORT_STATUS_ACKNOWLEGE = '02-Acknowleged';
    public static final String MEMBER_SUPPORT_STATUS_INPROGRESS = '02 - In Progress';
    
    //Less Then MEMBER_SUPPORT_STATUS_ACKNOWLEDGE status values
    public static final String MEMBER_SUPPORT_STATUS_NEW = '01-New';
    public static final String MEMBER_SUPPORT_STATUS_ISSUES_WITH_EXTRACT = 'Issues with extract';
    public static final String MEMBER_SUPPORT_STATUS_WAITING_FOR_FILES = 'Waiting for files';
    
    //Less Then MEMBER_SUPPORT_STATUS_INPROGRESS status values including above values, which are applicable for MEMBER_SUPPORT_STATUS_ACKNOWLEDGE
    public static final String MEMBER_SUPPORT_STATUS_FILES_RECIEVED = 'Files Received';
    public static final String MEMBER_SUPPORT_STATUS_IN_SMOKE_TEST = 'In smoke test';
    //(Code Added) - Rajeev Jain - 08/03/2016 - CR-20160519-9863 - Services Excellence - Upto here
    //Rajeev - 10/19/2016 - Manaual merged from Services Ex to Test Sb - upto here
    
    //Added By - Abhinav Sharma - CR-20150925-9267 - 02/11/2016
    //Start from here
    public static final String CONTRACT_TYPE_NBB = 'NBB';
    //Upto here
    
    //Added by - Mahendra Swarnkar - CR-20160114-9520 - 08/23/2016
    
    //Business Hours Constant
    public static String START_BUSINESS_HOURS = '8:30 AM';
    public static String END_BUSINESS_HOURS = '5:30 PM';
    
    //Added by - Mahendra Swarnkar - CR-20160114-9520 - 08/23/2016 - Upto here
    
    //Added by - Mahendra Swarnkar - CR-20160114-9520 - 08/27/2016  
    public static final String MEMBER_INTERACTION_RT_SOUTHWIND = 'Southwind EL Request';
    public static final String OBJECT_MEMBER_INTERACTION = 'Call__c';
    
    //Added by - Mahendra Swarnkar - CR-20160114-9520 - 08/27/2016 - Upto here
    
    //Commented by Mahendra Swarnkar -03/04/2020 - CR-20200217-13756 : Record type is deleted.
    //Added by - Mahendra Swarnkar - CR-20160729-10075 - 08/27/2016 - Starts From Here
    //Case record type "Expert center" developer Name
    //public final static String CASE_RECORD_TYPE_EXPERT_CENTER = 'Expert_Center';
    
    //Property to get/return the list of records from Internal_Applicable_Email_Suffix custom meta data type
    public static List<Internal_Applicable_Email_Suffix__mdt> LIST_OF_INTERNAL_APPLICABLE_EMAIL_SUFFIXES {
        
        get {
            
            //If true then user is in Production else SandBox.
            Boolean isProductionInstance = Util.IS_PRODUCTION_INSTANCE;
            
            //Checking for the null value
            if(LIST_OF_INTERNAL_APPLICABLE_EMAIL_SUFFIXES == null) {
                
                //Memory allocation
                LIST_OF_INTERNAL_APPLICABLE_EMAIL_SUFFIXES = new List<Internal_Applicable_Email_Suffix__mdt>();
                
                //For production instance
                if(isProductionInstance) {
                    
                    //Retrieving details from the database
                    LIST_OF_INTERNAL_APPLICABLE_EMAIL_SUFFIXES = [SELECT ID, DeveloperName, 
                                                                  Eligible_Email_Domain__c, Applicable_Record_Types__c, 
                                                                  Object_API_Name__c, Production__c
                                                                  FROM Internal_Applicable_Email_Suffix__mdt 
                                                                  WHERE Production__c = true];
                } else {
                    
                    //Retrieving details from the database
                    LIST_OF_INTERNAL_APPLICABLE_EMAIL_SUFFIXES = [SELECT ID, DeveloperName, 
                                                                  Eligible_Email_Domain__c, Applicable_Record_Types__c, 
                                                                  Object_API_Name__c, Production__c
                                                                  FROM Internal_Applicable_Email_Suffix__mdt];
                }
            }
            
            //returning list of records
            return LIST_OF_INTERNAL_APPLICABLE_EMAIL_SUFFIXES;
        }
        set;
    }
    //Added by - Mahendra Swarnkar - CR-20160729-10075 - 08/27/2016 - Ends Here 
    
    //Mahendra Swarnkar - CR-20160715-10014 - 9/2/2016
    public final static String CASE_TYPE_VOICE_MAIL = 'Voice Mail';
    
    //VH CR-9863 - Services Excellence - Save some record type queries by making them available without using SOQL
    public static final string RECORD_TYPE_SITE_ISSUE_CMA_DATA_LOAD = 'CMA Data Load/Migration';
    public static final string RECORD_TYPE_SITE_ISSUE_CPRM_DATA_LOAD = 'CPRM Data Load';
    public static final string MEMBER_SUPPORT_STATUS_ESCALATED_CONTRACT_ANALYST = '05.5-Escalated - Contract Analyst';
   /**
    * return the CMA Data Load record type id
    **/
    public static Id MEMBER_SUPPORT_CMA_DATA_LOAD_RT_ID {
        get {
            if (MEMBER_SUPPORT_CMA_DATA_LOAD_RT_ID == null) 
                MEMBER_SUPPORT_CMA_DATA_LOAD_RT_ID = Util.RecordTypeId('Site_Issue__c', RECORD_TYPE_SITE_ISSUE_CMA_DATA_LOAD);
            return MEMBER_SUPPORT_CMA_DATA_LOAD_RT_ID;
        }
        set;
    }
    
   /**
    * return the CCA Data Load record type id
    **/
    public static Id MEMBER_SUPPORT_CCA_DATA_LOAD_RT_ID {
        get {
            if (MEMBER_SUPPORT_CCA_DATA_LOAD_RT_ID == null) 
                MEMBER_SUPPORT_CCA_DATA_LOAD_RT_ID = Util.RecordTypeId('Site_Issue__c', RECORD_TYPE_SITE_ISSUE_CCA_DATA_LOAD);
            return MEMBER_SUPPORT_CCA_DATA_LOAD_RT_ID;
        }
        set;
    }
    
    //Added By - Mahendra Swarnakar - 3/15/2017 - CR-20170210-10679
    public static final string  OBJECT_CONTRACT_ABC_API_NAME = 'Contract__c';
    
    //Added By - Victor Hanson - 03/18/2017
    public static final Id Program_Package_HD_RT_ID = Schema.SObjectType.Program_Package__c.getRecordTypeInfosByName().get('Hardwick Day').getRecordTypeId();
    public static final Id Program_Package_Royall_RT_ID = Schema.SObjectType.Program_Package__c.getRecordTypeInfosByName().get('Royall').getRecordTypeId();
    //public static final Id Account_Royall_Graduate_RT_ID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Royall - Admissions - Graduate').getRecordTypeId();
    public static final Id Account_Royall_Graduate_RT_ID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Graduate Education').getRecordTypeId();
    
    //Commented by Mahendra Swarnkar - 03/04/2020 - CR-20200217-13756
    //public static final Id Account_Royall_Undergraduate_RT_ID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('zzzRoyall - Admissions - Undergraduate').getRecordTypeId();
    //public static final Id Account_Royall_Advancement_RT_ID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('zzzRoyall - Advancement').getRecordTypeId();
    
    //Added by Abhinav Sharma - To get the Membership Record type
    public static final Id Membership_Record_Type1 = Schema.SObjectType.Membership__c.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
    public static final Id Membership_Record_Type_Enrollment = Schema.SObjectType.Membership__c.getRecordTypeInfosByName().get('Enrollment').getRecordTypeId();
    public static final Map<String, Id> MAP_MEMBERSHIP_RECORDTYPES = new Map<String, String>{
        											'Standard' => Membership_Record_Type1,
										            	'Enrollment' =>   Membership_Record_Type_Enrollment
										            };
                
                
    //Added by - Victor Hanson - 10/06/2017
    public static final String ENTITY_ALL = 'All';
    public static final String ENTITY_EAB = 'EAB';
    public static final String ENTITY_ROYALL = 'Royall';
    public static final String ENTITY_HC = 'HC';
    
    //Commneted by Mahendra Swarnkar - 03/04/2020 - CR-20200217-13756 :US Provider - Hospital, US Provider Strategic, US Provider - System
    //	US Physician Practice - Network, US HCIC, International Physician Practice, International HCIC, C&M Consultant
    //Added By - Subhash Garhwal - 10/06/2017
    public static final Map<String, String> MAP_ACCOUNT_ENTITY_WITH_RECORD_TYPE = new Map<String, String>{
												            //'C&M Consultant' => 'HC',
												            'International Corporate' => 'All',
												            'International Education' => 'EAB',
                                    									    'Event Venue' => 'EAB',
												            //'International HCIC' => 'HC',
												            //'International Physician Practice' => 'HC',
												            //'International Provider' => 'HC',
												            'Other' => 'All',
												            //'Royall - Admissions - Graduate' => 'EAB',
												            'Graduate Education' => 'EAB',
												            //'Royall - Admissions - Undergraduate' => 'EAB',
												            //'Royall - Advancement' => 'EAB',
												            'Third Party' => 'All',
												            'US Corporate' => 'All',
												            'US Education' => 'EAB',
												            //'US HCIC' => 'HC',
												            'US Independent School' => 'EAB',
												            //'US Physician Practice' => 'HC',
												            //'US Physician Practice - Network' => 'HC',
												            //'Vendor' => 'All',
												            //'US Provider - Hospital' => 'HC',
												            //'US Provider Strategic' => 'HC',
												            //'US Provider - System' => 'HC',
												            //'Vendor' => 'All',
												            'Vendor or Venue' => 'All'
    													   };
                
                
	public static final Map<String, String> MAP_ACCOUNT_CHILD_WITH_RELATED_FIELDNAME = new Map<String, String>{
													            'Contact' => 'AccountId',
													            'Deployment__c' => 'Institution__c',
													            'Contract_Integrated_Accounts__c' => 'Account__c',
													            'Bundle__c' => 'Account__c',
													            'Other_Utilization__c' => 'Institution__c',
													            'Warm_Lead__c' => 'Account__c',
													            'Eligible_Domain__c' => 'Account__c',
													            'Reference__c' => 'Institution__c',
													            'Contract_Document__c' => 'Account__c'
													            };
                
	//Modifed By Dipesh Gupta - CR-20190726-13240 - 08/06/2019 - Remove the reference of Temporary_Program_Access__c
    	public static final Map<String, String> MAP_Contact_CHILD_WITH_RELATED_FIELDNAME = new Map<String, String>{
													            'Expert_MTM__c' => 'Expert__c',
													            // 'Temporary_Program_Access__c' => 'Contact__c',
													            'Registration__c' => 'Contact__c',
													            'Reference_Request_Contact__c' => 'Reference_Contact__c'
													            };
                                        
	//Added by Rajeev Jain - 07/07/2018 - Map to hold the Profile Name with its Is system component Ids 
	public static final Map<String, String> mapProfileWithIsSystemComponentId = new map<String, String> {
            'ABC Dataloader' => 'aAzC0000000CbHhKAK', 'ABC DataReader - Restricted' => 'aAzC0000000CbHiKAK',
            'ABC Information Systems - Restricted' => 'aAzC0000000CbHjKAK', 'Account Management' => 'aAzC0000000CbHkKAK',
            'AdvcomWebHelp' => 'aAzC0000000CbHnKAK', 'Analyst' => 'aAzC0000000CbHqKAK', 'Boardroom - App Subscription User' => 'aAzC0000000CbHrKAK',
            'Chatter External User' => 'aAzC0000000CbHsKAK','Chatter Free User' => 'aAzC0000000CbHuKAK',
            'Chatter Moderator User' => 'aAzC0000000CbHvKAK', 'Chatter Only User' => 'aAzC0000000CbHwKAK', 'Chatter Plus - Read Only' => 'aAzC0000000CbHxKAK', 
            'Chatter Plus User' => 'aAzC0000000CbHyKAK', 'Company Communities User' => 'aAzC0000000CbI0KAK', 'ContractManager' => 'aAzC0000000CbI1KAK',
            'Crimson Community HV Portal User' => 'aAzC0000000CbI2KAK', 'Customer Portal Manager Custom' => 'aAzC0000000CbI5KAK',
            'Delivery - App Subscription' => 'aAzC00000000153', 'Delivery Analyst' => 'aAzC0000000CbI6KAK',
            'Delivery Business Analyst - Restricted' => 'aAzC0000000CbI7KAK', 'Delivery Chatter Plus User - Restricted 15' => 'aAzC0000000CbI8KAK',
            'Delivery Operations - Restricted' => 'aAzC0000000CbI9KAK', 'Delivery Operations w Milliman - Restricted' => 'aAzC0000000CbIAKA0',
            'Expert Center Admin' => 'aAzC0000000CbIDKA0', 'Finance Ops' => 'aAzC0000000CbIEKA0',
            'FinancialForce Accountant - Restricted' => 'aAzC0000000CbIFKA0', 'FinancialForce AP Operations - Restricted' => 'aAzC0000000CbIGKA0',
            'FinancialForce AR Operations' => 'aAzC0000000CbIHKA0', 'FinancialForce Controller - Restricted' => 'aAzC0000000CbIIKA0',
            'FinancialForce Read Only - Restricted' => 'aAzC0000000CbIJKA0', 'FinancialForce Royall - Restricted' => 'aAzC0000000053vKAA',
            'Leadership' => 'aAzC0000000CbIRKA0', 'Legal' => 'aAzC0000000CbISKA0', 'MA With Institution Permission' => 'aAzC0000000CbIUKA0',
            'Marketers' => 'aAzC0000000CbIVKA0', 'Marketing Associates' => 'aAzC0000000CbIWKA0',
            'Marketing Manager' => 'aAzC0000000CbIXKA0', 'MarketingProfile' => 'aAzC0000000CbIYKA0',
            'Marketo-Salesforce Sync' => 'aAzA0000000Xa2i', 'Member Response' => 'aAzC0000000CbIZKA0',
            'NPD - Restricted' => 'aAzC0000000CbIcKAK', 'Product Marketing Manager' => 'aAzC0000000CbIfKAK',
            'PSA - Field User (All Field Resources)' => 'aAzC0000000CbIgKAK', 'PSA - Full User (Exec, Senior VP, VP, SLA)' => 'aAzC0000000CbIhKAK',
            'PSA - Full User (Exec, Senior VP, VP, SLA) - Restricted' => 'aAzC00000004DbUKAU', 'PSA Field User (with Marketing Permissions)' => 'aAzC0000000CfBIKA0',
            'PSA Full User (Exclude Marketing Permissions)' => 'aAzC000000000VtKAI', 'PSS' => 'aAzC0000000CbIiKAK',
            'Research Associate' => 'aAzC0000000CbIkKAK', 'Royall - App Subscription User' => 'aAzC0000000GncHKAS',
            'RoyallAPI - Restricted' => 'aAzC0000000GncIKAS', 'SFDC Dev Contractor - Restricted' => 'aAzC0000000CbIlKAK',
            'Specialist' => 'aAzC0000000CbIoKAK', 'Strategic Marketing Ops' => 'aAzC0000000CbIrKAK',
            'Syndicated - General Research - App Subscription' => 'aAzC0000000Gmi1KAC', 'System Administrator' => 'aAzA0000000XZpL' 
            };
                
    public static final String PROJECT_PHASE_X_CANCELLED_DUPLICATE = 'X - Cancelled/Duplicate';
    public static final String PROJECT_PHASE_X_DUPLICATE = 'X - Duplicate';
    public static final Set<String> SET_PROJECT_PHASES_TO_IGNORE = new Set<String>{ PROJECT_PHASE_X_CANCELLED_DUPLICATE, PROJECT_PHASE_X_DUPLICATE };
    public static final String ZENDESK = 'Zendesk';
    
    //Victor Hanson - 07/28/2019 - CR-20190520-13117 - Added Institution recordTypeId references
    public static final Id ACCOUNT_RT_ID_US_EDUCATION = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(RECORD_TYPE_ACCOUNT_DEVELOPER_NAME_US_EDUCATION).getRecordTypeId();
    public static final Id ACCOUNT_RT_ID_US_INDEPENDENT_SCHOOL = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(RECORD_TYPE_ACCOUNT_DEVELOPER_NAME_US_INDEPENDENT_SCHOOL).getRecordTypeId();
    public static final Id ACCOUNT_RT_ID_INTERNATIONAL_EDUCATION = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(RECORD_TYPE_ACCOUNT_DEVELOPER_NAME_INTERNATIONAL_EDUCATION).getRecordTypeId();
    
    //Victor Hanson - 08/07/2019 - CR-20190204-12863 - Added values to support the 'no contact' functionality
    public static final String CONTACT_STATUS_INACTIVE_NO_CONTACT = 'Inactive - No Contact';
    public static final Id CONTACT_RT_ID_EMPLOYEE = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(CONTACT_RECORD_TYPE_DEVELOPER_NAME_EMPLOYEE).getRecordTypeId();
    public static final String NO_CONTACT_NAME = '[No Contact]';
    
    //Added by - Abhinav Sharma - 12/31/2019 - Run All Tests Utility
    //Start From here
    //Characters
    public static final String CHAR_SEMI_COLON = ';';
    public static final String CHAR_BLANK_SPACE = ' ';
    public static final String CHAR_COLON = ':';
    public static final String CHAR_PERCENTAGE = '%';
    public static final String CHAR_QUESTION = '?';
    public static final String CHAR_EQUALS = '=';
    public static final String CHAR_AMPERSAND = '&';
    public static final String CHAR_BACKSLASH = '/';
    public static final String CHAR_COMMA = ',';
    public static final String CHAR_NEW_LINE = '\n';
    public static final String CHAR_DASH = '-';
    public static final String CHAR_DOT = '.';
    public static final String CHAR_FORWARDSLASH_COMMA = '\'';
    public static final String CHAR_OPENPARENTHESIS = '(';
    public static final String CHAR_CLOSEPARENTHESIS = ')';
    public static final String CHAR_OPENBRACE = '{';
    public static final String CHAR_CLOSEBRACE = '}';
    public static final String CHAR_UNDERSCORE = '_';
    public static final String CHAR_SPACE = ' ';
    
    //Days related collections
    public static final List<String> listOfDays = new List<String>{'Saturday' , 'Sunday' , 'Monday' , 'Tuesday' , 'Wednesday' , 'Thursday' , 'Friday'};
    public static final String DAY_MONDAY = 'Monday';  
    public static final String DAY_TUESDAY = 'Tuesday';
    public static final String DAY_WEDNESDAY = 'Wednesday';
    public static final String DAY_THURSDAY = 'Thursday';
    public static final String DAY_FRIDAY = 'Friday';
    public static final String DAY_SATURDAY = 'Saturday';
    public static final String DAY_SUNDAY = 'Sunday';
    
    //Configuration Manager Types
    public static final String CM_CASE_SUPPORT_TYPE = 'Case Support Type';
    public static final String CM_TEST_FACTORY_MAPPINGS = 'Test Factory Mappings';
    
    //Case Support Types
    public static final String CM_CASE_SUPPORT_TYPE_BASIC = 'Basic';
    public static final String CM_CASE_SUPPORT_TYPE_PREMIUM = 'Premium';
    public static final String CM_CASE_SUPPORT_TYPE_GOLD = 'Gold';
    
    //OAuth 2.0 Constants
    public static final String RESPONSE_TYPE = 'response_type';
    public static final String CODE = 'code';
    public static final String BEARER = 'Bearer';
    public static final String CLIENT_ID = 'client_id';
    public static final String REDIRECT_URL = 'redirect_uri';
    public static final String PROMPT = 'prompt';
    public static final String LOGIN = 'login';
    public static final String DISPLAY = 'display';
    public static final String POPUP = 'popup';
    public static final String STATE = 'state';
    public static final String GRANT_TYPE = 'grant_type';
    public static final String CLIENT_SECRET = 'client_secret';
    public static final String AUTHORIZATION_CODE = 'authorization_code';
    public static final String TOKEN_TYPE = 'token_type';
    public static final String ACCESS_TOKEN = 'access_token';
    public static final String INSTANCE_URL = 'instance_url';
    public static final String REFRESH_TOKEN = 'refresh_token';
    public static final String ERROR = 'error';
    public static final String ERROR_DESCRIPTION = 'error_description';
    
    //Status Constants
    public static final String STATUS_COMPLETED = 'completed';
    public static final String STATUS_ABORTED = 'aborted';
    public static final String STATUS_FAILED = 'failed';
    public static final String STATUS_FAIL = 'fail';
    public static final String STATUS_NOT_STARTED = 'not started';
    public static final String STATUS_PROCESSING = 'processing';
    public static final String STATUS_FINISHED = 'finished';
    
    //HTTP Request Constants
    public static final String HTTP_REQUEST_GET_TYPE = 'GET';
    public static final String HTTP_REQUEST_POST_TYPE = 'POST';
    public static final String HTTP_REQUEST_PUSH_TYPE = 'PUSH';
    public static final String HTTP_REQUEST_PUT_TYPE = 'PUT';
    //Modified - Saurabh Kumar - 03/18/2021 - CR-20210128-14855 - Added
    public static final String HTTP_REQUEST_PATCH_TYPE = 'PATCH';
    
    //Added By - Abhinav Sharma - 02/26/2020 - CR-20200224-13795
    //Start from here
    //Content Type Constants
    public static final String CONTENT_TYPE= 'content-type';
    public static final String ACCEPT = 'Accept';
    public static final String DATA_RAW = 'data-raw';
    public static final String INSTANCEURL = 'instanceUrl';
    public static final String X_API_KEY = 'x-api-key';
    public static final String ID_PARAMETER = 'id';
    public static final Integer GENERATE_SALES_INVOICE_CALLOUT_SUCCESS_RESPONSE_STAUTS_CODE = 202;
    public static final String PRODUCTION_URL_INSTANCE = 'https://login.salesforce.com';
    public static final String SANDBOX_URL_INSTANCE = 'https://test.salesforce.com';
    public static final String INVOICE_DOWNLOAD_URL = '/sfc/servlet.shepherd/version/download/';
    public static final String HTTP_URL = 'https://'; 
    public static final String STATUS_CODE = 'STATUS CODE :';
    public static final String ERROR_LINE =  'ERROR By Line #';
    public static final String DETAILS =   'Details :';
    
    //End here
    public static final String CONTENT_TYPE_APP_URLENCODED = 'application/x-www-form-urlencoded';
    public static final String CONTENT_TYPE_APP_JSON = 'application/json';
    public static final String AUTHORIZATION = 'Authorization';
    
    //File Extensions Constants
    public static final String FILE_EXTENSION_CSV = '.csv';
    
    //Encoding constants
    public static final String UTF_8_ENCODING = 'UTF-8';
    //upto here
    
    public static final Set<Integer> setOfSBCreateSuccessCodes = new Set<Integer>{200, 201};
    public static final Set<String> setOfJobStatus = new Set<String>{'WAITING', 'ACQUIRED', 'EXECUTING', 'PAUSED', 'BLOCKED','PAUSED_BLOCKED', 'Holding', 'Queued', 'Preparing', 'Processing'};
    public static final String JOB_TYPE_QUEUEABLE = 'Queueable';
    public static final String SB_STATUS= 'Completed';
    
    //Victor Hanson - 04/09/2020 - CR-20200304-13828 - added digital vendor type
    public static final String VENDOR_TYPE_DIGITAL = 'Digital';
    public static final String FULFILLMENT = 'Fulfillment';
    //Modified by Dipesh Gupta -- 4/22/2020  --- CR-20200415-13951 --- Change the status "Approved by Client" to "Approved by Partner" 
    public static final String JOB_TICKET_STATUS_APPROVED_BY_CLIENT = 'Approved by Partner';
    public static final String JOB_TICKET_STATUS_IN_PROGRESS = 'In Progress';
    public final static Id RECORD_TYPE_ID_ACCOUNT_VENDOR = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Vendor').getRecordTypeId();
    public final static Id RECORD_TYPE_ID_PRODUCTION_TRACKING_MAIL_SHOP = Schema.SObjectType.Production_Tracking__c.getRecordTypeInfosByDeveloperName().get('Mail_Shop').getRecordTypeId();
    
    //Mahendra Swarnakar - 06/18/2021 - CR-20210325-15027 - Starts from here
    public final static String CREATIVE_PACKAGE_APPROVAL_STATUS = 'Submitted';
    public final static String CREATIVE_PACKAGE_APPROVAL_STATUS_Approved = 'Approved';
    public static final String JOB_TICKET_STATUS_CANCELLED = 'Cancelled';
    public static final String JOB_TICKET_STATUS_COMPLETE = 'Complete';
    public static final String JOB_TICKET_STATUS_DRAFT = 'Draft';
    public static final String PRODUCTION_TRACKING_STATUS_CANCELLED = 'Cancelled';
    public static final String PRODUCTION_TRACKING_PROOF_GENERATION_INTERNAL = 'Internal';
    public static final String PRODUCTION_TRACKING_DROP_TYPE = 'On Demand';
    public static final String BATCH_TYPE_LIVEDATA = 'LiveData';
    public static final String BATCH_TYPE_ARTPROOF = 'ArtProof';
    //Mahendra Swarnakar - 06/18/2021 - CR-20210325-15027 - Ends here
    
    //Victor Hanson - 04/09/2020 - CR-20200304-13828 - production tracking status
    public static final String PRODUCTION_TRACKING_STATUS_PLANNED = 'Planned';
    //Modified by Dipesh Gupta -- 4/22/2020  --- CR-20200415-13951 --- Change the status "Approved by Client" to "Approved by Partner" 
    public static final String PRODUCTION_TRACKING_STATUS_APPROVED_BY_CLIENT = 'Approved by Partner';
    public static final String PRODUCTION_TRACKING_STATUS_PROOF = 'Proof';
    public static final String PRODUCTION_TRACKING_STATUS_LIVE_PROOF = 'Live Proof';
    public static final String PRODUCTION_TRACKING_STATUS_READY_FOR_PRINT = 'Ready for Print';
    public static final String PRODUCTION_TRACKING_STATUS_MAILED = 'Mailed';
    
    //04/22/2021 - CR-20210325-15027 - Victor Hanson - added
    public static final String PRODUCTION_TRACKING_STATUS_PRINTED = 'Printed';
    
    public static final String PRODUCTION_TRACKING_STATUS_DETAIL_SUBMITTED = 'Submitted';
    public static final String PRODUCTION_TRACKING_STATUS_DETAIL_PENDING_APPROVAL = 'Pending Approval';
    public static final String PRODUCTION_TRACKING_STATUS_DETAIL_APPROVED = 'Approved';
    public static final String PRODUCTION_TRACKING_STATUS_DETAIL_LIVE_PROOF_APPROVED = 'Live Proof Approved';
    public static final String PRODUCTION_TRACKING_STATUS_DETAIL_FILE_RECEIVED = 'File Received';
    public static final String PRODUCTION_TRACKING_STATUS_DETAIL_FILE_ISSUE = 'File Issue';
    //10/18/2020 - CR-20201012-14597 - Victor Hanson - added
    public static final String PRODUCTION_TRACKING_STATUS_DETAIL_PENDING_MAIL_DATE_CONFIRMATION = 'Pending Mail Date Confirmation';
    public static final String PRODUCTION_TRACKING_STATUS_DETAIL_MAIL_DATE_CONFIRMED = 'Mail Date Confirmed';
    
    //10/18/2020 - CR-20201012-14597 - Victor Hanson - added
    public static final String PRODUCTION_TRACKING_STATUS_DETAIL_ERROR = 'Error';
    
    //Victor Hanson - 04/09/2020 - CR-20200304-13828 - artifact status
    public static final String ARTIFACT_STATUS_STAGING = 'Staging';
    public static final String ARTIFACT_STATUS_TRANSFER_NOW = 'Transfer Now';
    public static final String ARTIFACT_TRANSFER_STATUS_TRANSFERRING = 'Transferring';
    public static final String FAILURE = 'Failure';  
    
    //Victor Hanson - 04/09/2020 - CR-20200304-13828 - artifact types
    public static final String ARTIFACT_TYPE_ARTWORK = 'Artwork';
    public static final String ARTIFACT_TYPE_ARTWORK_PROOF = 'Artwork Proof';
    public static final String ARTIFACT_TYPE_LIVE_PROOF = 'Live Proof'; //05/27/2020 - Victor Hanson - CR-20200527-14113 - updated to 'Live Proof'
    public static final String ARTIFACT_TYPE_LIVE_PROOF_DATA = 'Live Proof Data'; //12/04/2020 - CR-20201012-14597 - Victor Hanson - added
    public static final String ARTIFACT_TYPE_MAILING_LIST = 'Mailing List';
    public static final String ARTIFACT_TYPE_MAILING_LIST_RESULT = 'Mailing List Result';
    public static final String ARTIFACT_TYPE_MAILING_LIST_VALIDATION_RESULT = 'Mailing List Validation Result';
    public static final String ARTIFACT_TYPE_READY_TO_PRINT = 'Ready To Print'; //11/15/2020 - Victor Hanson - CR-20201012-14597 - added
    public static final String ARTIFACT_TRANSFER_DIRECTION_PULL = 'Pull';
    public static final String ARTIFACT_TRANSFER_DIRECTION_PUSH = 'Push';
    public static final String ARTIFACT_TYPE_SUPPRESSION_LIST = 'Suppression List'; //12/04/2020 - CR-20201012-14597 - Victor Hanson - added
    
    
    //Added By Dipesh Gupta - Added from CR-20200221-13792
    public final static Id RECORD_TYPE_ID_ES_DEPLOYMENT = Schema.SObjectType.Deployment__c.getRecordTypeInfosByName().get('ES Deployment').getRecordTypeId();
    public final static Id RECORD_TYPE_ID_ES_PROJECT = Schema.SObjectType.Project__c.getRecordTypeInfosByName().get('ES Project').getRecordTypeId();
    
    //Added By Abhinav Sharama -  CR-20200408-13920
    Public Static final Set<String> setOfEligiblePTStatusToArtifactCreation = new Set<String> {PRODUCTION_TRACKING_STATUS_PROOF, PRODUCTION_TRACKING_STATUS_READY_FOR_PRINT };
        
    //Modified - Victor Hanson - 08/04/2020 - CR-20200804-14400 - added TIMEZONE_AMERICA_NEWYORK
    public static final String TIMEZONE_AMERICA_NEWYORK = 'America/New_York';
    
    //Added Constants on - 08/10/2020 - Rajeev Jain - CR-20200805-14403 - added APEXJOBSTATUS_QUEUED to CRONTRIGGER_STATE_DELETED
    public static final String APEXJOBSTATUS_QUEUED = 'Queued';
    public static final String APEXJOBSTATUS_PREPARING = 'Preparing';
    public static final String APEXJOBSTATUS_PROCESSING = 'Processing';
    public static final String ASYNCAPEXJOB_JOBTYPE_SCHEDULEDAPEX = 'ScheduledApex';
    public static final String CRONTRIGGER_STATE_COMPLETE = 'COMPLETE';
    public static final String CRONTRIGGER_STATE_DELETED = 'DELETED';
    
    //Added By Abhinav Sharama - CR-20200226-13812
    //Modify by - Shalu Sharma - 5/18/21 - CR-20210315-14997
    Public Static final Set<String> setOfEligibleComponentTypes = new Set<String>{'Reply Envelope (BRE/CRE)', 'Envelope'};
        
    //Added by Neha Sharma - 11/06/2020 - CR-20201029-14646
    //Modified By - Neha Sharma - CR-20201021-14625 - add the new costants for MembershipTriggerHelper
    public static final String PROGRAM_ACRONYM_CXCN = 'CXCN';
    public static final String CASE_STATUS_NEW = 'New';
    public static final String CASE_REASON_CONTRACT_CRITERIA_AUDIT = 'Contract Criteria Audit';
    public static final String CASE_TYPE_CAPPEX_CLIENT_SUPPORT = 'Cappex - Client Support';
    public static final String CASE_ORIGIN_WORKFLOW = 'Workflow';
    public static final String CASE_RECORD_TYPE_CAPPEX_REQUESTS = 'Cappex Requests';
    public static final String CASE_CAPPEX_REQUESTS_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByName().get(CASE_RECORD_TYPE_CAPPEX_REQUESTS).getRecordTypeId();
    public static final String REVIEW_CALL_RT_ID = Schema.SObjectType.Review_Call__c.getRecordTypeInfosByName().get('Review Call').getRecordTypeId();
    
    //End here
    
    //Added By - Abhinav Sharama - CR-20210106-14784 - 01/19/2021 - Size value Other for Job Ticket MTM object 
    public static final String JOB_TICKET_MTM_SIZE_OTHER = 'Other';
    
    //Added By Saurabh Kumar - 09/18/2020 - CR-20200819-14449 
    public static final String TEAM_MEMBER_PRIMARY_ROLE_EVENT_COORDINATOR = 'Event Coordinator';
    public static final Id RECORD_TYPE_ID_EAB_EVENT_OF_STAFF_ASSIGNMENT = Schema.SObjectType.Team_Membership__c.getRecordTypeInfosByName().get('EAB Event').getRecordTypeId();
    public static final String ASSIGNMENT_ROLE_NAME_EVENT_COORDINATOR = 'Event Coordinator';
    public static final String ASSIGNMENT_ROLE_NAME_EVENT_MANAGER = 'Event Manager';
    public static final String ASSIGNMENT_ROLE_NAME_ONSITE_EVENT_MANAGER = 'Onsite Event Manager';
    public static final Set<String> SET_OF_ASSIGNMENT_ROLE_NAMES = new Set<String>{ASSIGNMENT_ROLE_NAME_EVENT_COORDINATOR,ASSIGNMENT_ROLE_NAME_EVENT_MANAGER,ASSIGNMENT_ROLE_NAME_ONSITE_EVENT_MANAGER};
    
    //Added By Saurabh Kumar - 09/28/2020 - CR-20200821-14453
    public static final String REGISTRATION_PARTNER_STATUS_PROSPECT = 'Prospect';
    public static final String REGISTRATION_PARTNER_STATUS_PARTNER = 'Partner';
    public static final String KEYWORD_MEMBER = 'Member';
    public static final String KEYWORD_APPROVED = 'Approved';

    //Added By Saurabh Kumar - 10/12/2020 - CR-20200821-14455
    public static final String STATUS_CLOSED_COMPLETED = 'Closed - Completed';
    public static final String STATUS_CLOSED_CANCELLED = 'Closed - Cancelled';
    public static final String STATUS_REGISTERED = 'Registered';
    public static final String STATUS_CANCELLED = 'Cancelled';
    public static final String CANCELLED_REASON = 'No other Staff Assignments exist on the EAB Event for this Contact';
    public static final String TEST_TEXT = 'Test';
    public static final Id REGISTRATION_RECORD_TYPE_ID_CORE_REGISTRATION = Schema.SObjectType.Registration__c.getRecordTypeInfosByName().get('Core Registration').getRecordTypeId();
    public static final Id REGISTRATION_RECORD_TYPE_ID_INTERNAL_ATTENDEE = Schema.SObjectType.Registration__c.getRecordTypeInfosByName().get('Internal Attendee').getRecordTypeId();
    public static final Id CONTACT_RECORD_TYPE_ID_EMPLOYEE = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Employee').getRecordTypeId();
    
    //Added by Saurabh Kumar - 03/03/2021 - CR-20210114-14812 (L2May21 Release) - Constant added
    public static final Id CONTACT_RECORD_TYPE_ID_EXTERNAL = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('External').getRecordTypeId();
    
    //Added by Saurabh Kumar - 10/26/2020 - CR-20200821-14454
    public static final String EAB_EVENT_INHERI_REGISTRATION_INHERIT_ALL_FROM_PARENT = 'Inherit all from parent';
    public static final String EAB_EVENT_INHERI_REGISTRATION_PARENT_REGISTRATIONS_ELIGIBLE = 'Parent registrants eligible';
    public static final String REGISTRATION_STATUS_REGISTERED = 'Registered';
    public static final String REGISTRATION_STATUS_WAITLIST = 'Waitlist';
    public static final String REGISTRATION_STATUS_CANCELLED = 'Cancelled';
    public static final String REGISTRATION_STATUS_VOID = 'VOID';
    public static final Set<String> setOfRegistrationStatus = new Set<String> {REGISTRATION_STATUS_REGISTERED, 
        									REGISTRATION_STATUS_WAITLIST, 
        									REGISTRATION_STATUS_CANCELLED, 
        									REGISTRATION_STATUS_VOID};
    // Modified - Saurabh Kumar - 04/20/2021 - CR-20210318-15005
    public static final String REGISTRATION_STATUS_DECLINED = 'Declined';                                                                                 
    public static final String REGISTRATION_WAITLIST_DECLINED_REASON_EVENT_REG_CAPACITY = 'Event Reg Capacity';
    
    //Modified - saurabh Kumar - 10/27/2020 - CR-20200821-14465
    public static final String REGISTRATION_ORIGIN_MANUAL = 'Manual';
    public static final String REGISTRATION_ORIGIN_MICROSITE = 'Microsite';
    public static final String REGISTRATION_ORIGIN_SALESFORCE = 'Salesforce';
    public static final String REGISTRATION_ORIGIN_EAB_DOT_COM = 'EAB.com';
    public static final String REGISTRATION_APPROVAL_STATUS_APPROVAL_NEEDED = 'Approval Needed';
    public static final String REGISTRATION_STATUS_REGISTRATION_REQUESTED = 'Registration Requested';
    public static final String REGISTRATION_APPROVAL_REASON_NOT_ON_INVITE_LIST = 'Not On Invite List';
    public static final String REGISTRATION_APPROVAL_REASON_OVER_INSTITUTION_CAP = 'Over Institution Cap';
    public static final String REGISTRATION_APPROVAL_REASON_ALL_REQUIRE_APPROVAL = 'All Require Approval';
    public static final String REGISTRATION_APPROVAL_TYPE_INVITE_LIST = 'Invite List';
    public static final String REGISTRATION_APPROVAL_TYPE_MANUAL = 'Manual';
    
    public static final String PERMISSION_SET_NAME_ADVISORY_EVENT_MANAGER = 'Advisory_Event_Manager';
    public static final String EAB_EVENT_STATUS_OPEN_REGISTRATION = 'Open - Registration';
    public static final String EAB_EVENT_STATUS_OPEN_WAITLIST_ONLY = 'Open - Waitlist Only';
    
    //Modified - Saurabh Kumar - 03/04/2021 - CR-20210302-14960 - Constant added
    public static final String EAB_EVENT_RULE_PROGRAMS_USE_PARENT_RULES = 'Use parent\'s rules';
    
    //Modified - Saurabh Kumar - 04/07/2021 - CR-20210128-14854 - Constant added
    public static final String EAB_EVENT_STATUS_OPEN_REGISTRATION_RESTRICTED = 'Open - Registration Restricted';
    public static final Set<String> SET_OF_EAB_EVENT_OPEN_STATUS = new Set<String>{EAB_EVENT_STATUS_OPEN_REGISTRATION, EAB_EVENT_STATUS_OPEN_WAITLIST_ONLY, EAB_EVENT_STATUS_OPEN_REGISTRATION_RESTRICTED};
        
    //Modified - Saurabh Kumar - 03/25/2021 - CR-20201116-14696 - Constant added
    //Modified - Chirag Soni - 05/20/2021 - CR-20201116-14696 - (MRS2.0 UAT Issue Fixes) Added two new status (Invited, Cancelled) Values.
    //Modified - Chirag Soni - 06/15/2021 - CR-20201116-14696 - (MRS2.0 UAT Issue Fixes) Removed Registration Requested status.
    public static final List<String> CAMPAIGN_MEMBER_MARKETO_STATUSES = new List<String>{'Invited', 'Registered', 'Waitlist', 'No Show', 'Attended','Cancelled'};
    public static final List<String> CAMPAIGN_MEMBER_STATUSES = new List<String>{'Invited', 'Registered', 'Waitlisted', 'No Show', 'Attended','Cancelled'};    
    public static final String REGISTRATION_STATUS_ATTENDED = 'Attended'; 
    
    //Modified - Saurabh Kumar - 04/19/2021 - CR-20210318-15005 - Constant added
    public static final String REGISTRATION_APPROVAL_STATUS_WAITLIST = 'Waitlist';
    public static final String REGISTRATION_APPROVAL_STATUS_DECLINED = 'Declined';
    public static final String REGISTRATION_APPROVAL_TYPE_AUTO_APPROVE_PARTNER = 'Auto-Approve Partner';
    
    //Added By - Neha Sharma - 05/18/2021 - CR-20181203-12773 - Retain Acquisition Program data upon conversion
    public static final String CONTACT_OBJECT_API_NAME = 'Contact';
    
    //Added by - Ayush Gupta - 06/08/2021 - CR-20210526-15184 - Develop automation related to Cases
    public final static ID CASE_RT_ID_TECH_SUPPORT = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Technical Support').getRecordTypeId();
    public final static ID CASE_RT_ID_APS_REVIEW = Schema.SObjectType.Case.getRecordTypeInfosByName().get('APS Review').getRecordTypeId();
    public final static ID CASE_RT_ID_STARFISH = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Starfish').getRecordTypeId();
    public final static ID CASE_RT_ID_INTERSECT = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Intersect').getRecordTypeId();
    public final static ID CASE_RT_ID_INTERSECT_APS = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Intersect APS').getRecordTypeId();
    public final static ID CASE_RT_ID_COUNSELOR_COMMUNITY = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Counselor Community').getRecordTypeId();
    
    public final static String CASE_ORIGIN_HOBSONS_INTERNAL = 'Hobsons Internal';
    public final static String CASE_TECH_SUPPORT_QUEUE_NAME = 'Level_2_Queue';
    
    public final static String CASE_STATUS_CLOSED = 'Closed';
    public final static String CASE_STATUS_ESCALATED_TO_TECH_SUPPORT = 'Escalated to Technical Support';
    public final static String CASE_STATUS_ESCALATED_TO_APS = 'Escalated to APS';
    public final static String CASE_STATUS_PENDING_ENGG = 'Pending Engineering';
    public final static String CASE_STATUS_RESPONDED = 'Responded';
    
    public final static String CASE_OBJECT_API_NAME = 'Case';
    
    public final static String CASE_SUBJECT_STOPPED_CAMPAIGN = 'Stopped Campaign';
    public final static String CASE_SUBJECT_PRINT_TASK_FAIL_REPORT = 'Print Task Failure Report';
    public final static String CASE_SUBJECT_SCHEDULED_IMPORT_FAILED = 'Scheduled Import Failed';
    public final static String CASE_SUBJECT_PDF_IMPORT_RESULT_FOR = 'PDF Import Results for';
    public final static String CASE_SUBJECT_SYNC_ERRORS = 'Sync Errors';
    public final static String CASE_SUBJECT_SCHEDULED_EXPORT_FAILED = 'Scheduled Export Failed';
    public final static String CASE_SUBJECT_VERIFICATION_REQUIRED = 'Verification Required';
    
    public final static String CASE_SUPPORT_PRODUCT_RADIUS = 'Radius';
    public final static String CASE_SUPPORT_PRODUCT_APPLY_YOURSELF = 'ApplyYourself';
    public final static String CASE_SUPPORT_PRODUCT_CONNECT = 'Connect';
    public final static String CASE_SUPPORT_PRODUCT_STARFISH = 'Starfish';
    
    public final static String BUSINESS_HOURS_NAME_STARFISH = 'Starfish';
    public final static String BUSINESS_HOURS_NAME_INTERSECT_COUNSELOR_COMM = 'Intersect/Counselor Community';
    
    public final static String CASE_MILESTONETYPE_NAME_INITIAL_RESPONSE = 'Initial Response';
    
    //Added by - Nikita Kumari - 06/10/2021 - CR-20210518-15162
    public final static String TIMECARD_STATUS_APPROVED = 'Approved';
    //Added By - Shalu Sharma - 05/19/2021 - CR-20210423-15103 - Print MIS Sandbox Endpoints
    public static final String INSTANCE_TYPE_PRODUCTION = 'Production';
    public static final String INSTANCE_TYPE_UAT = 'UAT';
    
    //Added By - Shalu Sharma - 06/17/2021 - CR-20200924-14551 - Subscription Period Stages
    public static final String SUBSCRIPTION_PERIOD_STATUS_PENDING = 'Pending';
    public static final String SUBSCRIPTION_PERIOD_STATUS_ATL = 'ATL';
    
    // Modified By - Neha Sharma - 20/7/21 - CR-20210719-15300
    public final static Id RECORD_TYPE_eTech_Dev = Schema.SObjectType.SFDC_Release__c.getRecordTypeInfosByName().get('eTech Dev').getRecordTypeId();
    
    //Added By - Ayush Gupta - CR-20210805-15333 & CR-20210526-15183 - Constants
    
    public final static Set<String> CASE_STARFISH_SURVEY_RELATED_RT_NAME = new Set<String>{'APS_Review','Starfish','Technical_Support'};
    public final static Set<String> CASE_INTERSECT_SURVEY_RELATED_RT_NAME = new Set<String>{'Intersect','Counselor_Community','Intersect_APS'};
    public final static Set<String> CASE_SURVEY_DEV_NAMES = new Set<String>{'eab_starfish','eab_intersect'};
    public final static Set<String> CASE_COMMUNITY_Network_NAMES = new Set<String>{'Starfish Survey','Intersect Survey'};
    public final static String EAB_STARFISH_SURVEY_DEVNAME = 'eab_starfish';
    public final static String EAB_NAVIANCE_SURVEY_DEVNAME = 'eab_intersect';
    public final static String STARFISH_SURVEY_NETWORK_NAME = 'Starfish Survey';
    public final static String NAVIANCE_SURVEY_NETWORK_NAME = 'Intersect Survey';
    public final static String STARFISH_NAME = 'Starfish';
    public final static String INTERSECT_NAME = 'Intersect';
    
    //Added By - Nikita Kumari - 08/05/2021 - CR-20210316-15000 - Added contact role type value other
    public final static String CONTACT_ROLE_TYPE_OTHER = 'Other';
    
    //Added by - Chirag Soni - 07/28/2021 - CR-20210716-15294 - Constant added
    public final static Id REGISTRATION_RECORD_TYPE_ELEVATED_MEAL = Schema.SObjectType.Registration__c.getRecordTypeInfosByName().get('Elevated Meal Registration').getRecordTypeId();
    public final static Id RECORD_TYPE_ID_EAB_EVENT_ELEVATED_MEAL = Schema.SObjectType.Advisory_Event__c.getRecordTypeInfosByName().get('Elevated Meal').getRecordTypeId();
    
    //Added By - Subhash Garhwal - CR-20210722-15306 - 07/16/2021 - Eab MailRoom Management - Constants are added
    public static final String AWS_MAIL_STRING = 'AWS_Mail';
    public static final String MAILROOM_STATUS_WAITING_FOR_USER = 'Waiting for user';
    public static final String MAILROOM_STATUS_COMPLETED = 'Completed-';
    public static final String MAILROOM_STATUS_NEW = 'New';  
    public static final String MAILROOM_STATUS_WAITING_SCANNING = 'Waiting-Scanning';
    public static final List<String> MAILROOM_WAITING_USER_RESPONSE_STATUS = new List<String>{'Waiting for user', 'Waiting-Picking up', 'Waiting-Scanning', 'Waiting-Discarding'};
    public static final List<String> MAILROOM_WAITING_USER_RESPONSE_WAITING_XXX_STATUS = new List<String>{'Waiting-Picking up', 'Waiting-Scanning', 'Waiting-Discarding'};
    public static final List<String> MAILROOM_WAITING_FOR_USER_STATUS = new List<String>{'Waiting for user'};
    public static final List<String> MAILROOM_HISTORY_DETAIL_FIELDS = new List<String>{'Status__c'};
                    
    public static final String NO_API_ENDPOINT_WITH_RECORD_ID = 'No API Endpoint where Related Record Id = \'';
    public static final String MAILROOM_NOTIFICATION_API = '/notification';
    
    //Added By -  Chirag Soni - CR-20210902-15405 - 09/14/2021 - Constant added
    public static final String REGISTRATION_CANCELLATION_REASON = 'Cancelled from Marketo';
    
    //Added By - Chirag Soni - 09/15/2021 - CR-20210901-15400 - Constant Added - From Here
    
    //-----------Account Object and fields ------------//

    public static final  String ACCOUNT_API_NAME = 'Account';

    public static final  String ACCOUNT_FIELD_NAME = 'Name';
    public static final  String ACCOUNT_FIELD_ACC_FORMAL_NAME = 'Account_Formal_Name__c';
    public static final  String ACCOUNT_FIELD_SCHOOL_CODE = 'r_School_Code__c';
    public static final  String ACCOUNT_FIELD_CEEB_CODE = 'r_CEEB_Code__c';

    //---------Contact Object and fields--------- //

    public static final  String CONTACT_API_NAME = 'Contact';
    public static final  String CONTACT_FIELD_FIRST_NAME = 'FirstName';
    public static final  String CONTACT_FIELD_EMAIL = 'Email';

    //---------Opportunity Object and fields--------- //
    public static final  String OPPORTUNITY_API_NAME = 'Opportunity';
    public static final  String OPPORTUNITY_FIELD_CLOSED_DATE = 'CloseDate';

    //---------Job Ticket Object and fields--------- //
    public static final  String JOB_TICKET_API_NAME = 'Job_Ticket__c';
    public static final  String JT_FIELD_STATUS_APPROVED_BY_PARTNER = 'Approved by Partner';
    public static final String JT_FIELD_DROP_TYPE = 'Drop_Type__c';
    public static final String JT_FIELD_VENDOR_TYPE = 'Vendor_Type__c';
    public static final String JT_FIELD_MAIL_VENDOR = 'Mail_Vendor__c';
    public static final String JT_FIELD_NO_OF_DROPS = 'of_Drops__c';
    public static final String JT_FIELD_PROJECT_ID = 'Project_ID__c';
    public static final String JT_FIELD_MAIL_DATE = 'Mail_Date__c';
    public static final String JT_FIELD_ART_DIRECTOR = 'Art_Director__c';
    public static final String JT_FIELD_PRODUCTION_MANAGER = 'Production_Manager__c';
    public static final String JT_FIELD_PROJECT_MANAGER = 'Project_Manager__c';


    //---------Production Tracking Object and fields--------- //
    public static final String PRODUCTION_TRACKING_API_NAME = 'Production_Tracking__c';

    public static final String PT_FIELD_PROOF_GENERATION = 'Proof_Generation__c';
    public static final String PT_FIELD_MAIL_SHOPE_VENDOR = 'Mail_Shop_Vendor__c';
    public static final String PT_FIELD_DROP_NO = 'Drop__c';
    public static final String PT_FIELD_PLANNED_MAIL_DATE = 'Planned_Mail_Date__c';
    public static final String PT_FIELD_INTERNAL_DROP = 'Internal_Data_Drop__c';

    //---------Proposal Line Object and fields---------// 
    public static final String PROPOSAL_LINE_API_NAME = 'SBQQ__QuoteLine__c';

    public static final String PROPOSAL_LINE_FIELD_PRODUCT = 'SBQQ__Product__c';
    public static final String PROPOSAL_LINE_FIELD_TOP_PARETN_PRODUCT = 'Top_Parent_Product__c';
    public static final String PROPOSAL_LINE_FIELD_PRICEBOOK_ENTRY = 'SBQQ__PricebookEntryId__c';
    public static final String PROPOSAL_LINE_FIELD_PRODUCT_OPTION = 'SBQQ__ProductOption__c';
    public static final String PROPOSAL_LINE_FIELD_DYNAMIC_OPTION_ID = 'SBQQ__DynamicOptionId__c';
    public static final String PROPOSAL_LINE_FIELD_DIMENSION = 'SBQQ__Dimension__c';


    //---------Inventory Transaction Object and fields --------- //
    public static final String INVENTORY_TRANSACTION_API_NAME = 'Inventory_Transaction__c';

    public static final String INVENTORY_TRANSACTION_FIELD_ORIGINAL_VENDOR = 'Original_Vendor__c';
    public static final String INVENTORY_TRANSACTION_FIELD_TARGET_VENDOR = 'Target_Vendor__c';

    //---------Job Tikcet MTM Object and fields ---------//
    public static final String JOB_TICKET_MTM_API_NAME = 'Job_Ticket_MtM__c';

    //--------- Inventory Object and fields --------- //
    public static final String INVENTORY_API_NAME = 'Inventory__c';

    //--------- Other Literals --------- //
    public static final String PRINT_PROCESS_OE_BRE = 'OE/BRE Test Data';

    public static final String OWNER_ID_FIELD = 'OwnerId';
    public final static String CREATIVE_PACKAGE_OBJECT_API_NAME = 'Creative_Package__c';
    //Added By - Chirag Soni - 09/15/2021 - CR-20210901-15400 - Constant Added - Till Here
    
    //Added By - Mahendar Swarnkar - 09/22/2021 - CR-20210909-15418 - Constant Added
    public static final String PRINT_PROCESS_OE_CAT = 'Catalyst Test Data';
    //Added By - Shalu Sharma - 09/24/2021 - CR-20210922-15453 - JT On demand Drop Type added
    public static final String JOB_TICKET_ON_DEMAND_DROP_TYPE = 'On Demand';
    public static final String JOB_TICKET_PRE_PLANNED_DROP_TYPE = 'Pre Planned';

    //Added By - Shalu Sharma - 10/19/2021 - CR-20210924-15459 - Inventory Transaction Picklist Values
    public static final String INVENTORY_TX_TYPE_PRINT_REQUEST_FROM_EAB = 'Print Request (from EAB)';
    public static final String INVENTORY_TX_STATUS_REQUESTED = 'Requested';
    public static final String INVENTORY_TX_TYPE_ALLOCATION_REQ_FROM_EAB = 'Allocation Request (from EAB)';
    public static final String INVENTORY_TX_STATUS_ALLOCATED = 'Allocated';
    public final static Id RECORD_TYPE_ALLOCATION_REQ_ID = Schema.SObjectType.Inventory_Transaction__c.getRecordTypeInfosByName().get('Adjustment Request').getRecordTypeId();
    
    //Added By - Chirag Soni - CR-20210628-15254 - 09/20/2021 - constant added
    public final static Id RECORD_TYPE_ID_VENUE_EVENT_VENUE = Schema.SObjectType.Venue__c.getRecordTypeInfosByName().get('Event Venue').getRecordTypeId();
    
    //Added By - Chirag Soni - CR-20210628-15254 - 10/18/2021 - constant added
    public final static String EAB_EVENT_IN_PERSON_EVENT_FORMAT = 'In-Person';

    //Added by Chirag Soni - 11/16/2020 - CR-20211112-15582 - constant added
    public final static Id RECORD_TYPE_ID_LEGACY_ACQUISITION = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Legacy Acquisition').getRecordTypeId();
    
    //Added by Shalu Sharma - 01/25/2022 - CR-20220125-15747 - Job Ticket Record Type Constant
    public static final Id JOB_TICKET_RT_ID = Schema.SObjectType.Job_Ticket__c.getRecordTypeInfosByName().get('Job Ticket').getRecordTypeId();
    
    //Added by - Nikita Kumari - 02/08/2022 - CR-20220119-15726 - Opp Record Type Developer Name holder
    public final static set<String> OPPORTUNITY_RT_DEV_NAME_FOR_ADD_MQL_CREDIT_REC = new Set<String>{'EAB_Initiating','Royall'};
    public final static String OPPORTUNITY_REC_ID_PREFIX = '006';
    
    //Added by Colin McGloin - CR-20220211-15910 - 02/11/2022 - Constants Added for Permissions Hub
    public final static string PERMISSIONS_HUB_OUTPUT_TYPE_PERMISSION_SET = 'Permission Set';
    public final static string PERMISSIONS_HUB_OUTPUT_TYPE_PROFILE = 'Profile';
    public final static string PERMISSIONS_HUB_OUTPUT_TYPE_ROLE = 'Role';
    public final static string PERMISSIONS_HUB_OUTPUT_TYPE_LICENSE = 'License';
    public final static string PERMISSIONS_HUB_OUTPUT_TYPE_GROUP = 'Group';
    public final static string PERMISSIONS_HUB_OUTPUT_TYPE_QUEUE = 'Queue';
    public final static string PERMISSIONS_HUB_COMMAND_ASSIGN = 'Assign';
    public final static string PERMISSIONS_HUB_COMMAND_REMOVE = 'Remove';

}