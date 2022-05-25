/**
*   Description     :   This class is to hold the constant values for ISSP project
*               
*   Created By      :   Subhash Garhwal
*    
*   Created Date    :   09/03/2015
*    
*   Revision Log    :   V1.0 - Created- Subhash Garhwal - ISSP Project
*                   :   V1.1 - Modified - Rajeev Jain - ISSP Deployment E - 04/06/2016
*                       V1.2 - Modified - Rajeev Jain - ISSP Deployment E - CR-20160304-9675 - Added one more picklist option in Limit to Picklist,added here constant for that
*                       V1.3 - Modified - Rajeev Jain - ISSP Deployment E - CR-20151120-9402 - 04/20/2016 - Added new constants regarding Incentiv Change Management functionality
**/
public without sharing class ISSPConstants {
    
    //Staff Attribute duplicate rule values
    public final static String VALUE_TYPE_RULE_STAFF_MEMBER_MAY_HAVE_UNLIMITED_OVERLAPPING_RECORDS_FOR_THIS_ATTRIBUTE = 'Staff member may have unlimited, overlapping records for this attribute';
    public final static String VALUE_TYPE_RULE_STAFF_MEMBER_MAY_HAVE_MULTIPLE_NON_OVERLAPPING_RECORDS_FOR_THIS_ATTRIBUTE = 'Staff member may have multiple, non-overlapping records for this attribute';
    public final static String VALUE_TYPE_RULE_STAFF_MEMBER_MAY_HAVE_ONLY_ONE_RECORD_FOR_THIS_ATTRIBUTE = 'Staff member may have only one record for this attribute';
    public final static String VALUE_TYPE_RULE_STAFF_MEMBER_MAY_HAVE_ONLY_ONE_RECORD_ASSOCIATED_WITH_THIS_CATEGORY = 'Staff member may have only one record associated with this category';
    public final static String VALUE_TYPE_RULE_STAFF_MEMBER_MAY_HAVE_MULTIPLE_NON_OVERLAPPING_RECORDS_FOR_THIS_CATEGORY = 'Staff member may have multiple, non-overlapping records for this category';
    
    //Staff Attribute Source values
    public final static String STAFF_ATTRIBUTE_SOURCE_INTEGRATION = 'Integration';
    public final static String STAFF_ATTRIBUTE_SOURCE_NATIVE = 'Native';
    public final static String STAFF_ATTRIBUTES_CHECKBOX = 'Checkbox';
    
    //Incentive Change Log variables
    public final static String INCENTIVE_CHANGE_LOG_VALUE_TYPE_ADDITION = 'Addition';
    public final static String INCENTIVE_CHANGE_LOG_VALUE_TYPE_EFFECTIVE_DATES = 'Effective Dates';
    public final static String INCENTIVE_CHANGE_LOG_CHANGE_TYPE_TEXT = 'Text';
    public final static String INCENTIVE_CHANGE_LOG_CHANGE_TYPE_STATUS = 'Status';
    public final static String INCENTIVE_CHANGE_LOG_CHANGE_TYPE_ADDED_TO_COLLECTION_PERSPECTIVE = 'Added to Collection Perspective';
    
    //V1.3 - Modified - Rajeev Jain - ISSP Deployment E - CR-20151120-9402
    //Change Type Constants
    public final static String INCENTIVE_CHANGE_LOG_CHANGE_TYPE_NEW = 'New';
    public final static String INCENTIVE_CHANGE_LOG_CHANGE_TYPE_MODIFIED = 'Modified';
    
    //Change Value Constants
    public final static String INCENTIVE_CHANGE_LOG_CHANGE_VALUE_START_DATE = 'Start date';
    public final static String INCENTIVE_CHANGE_LOG_CHANGE_VALUE_END_DATE = 'End date';
    
    //Change Element Constants
    public final static String INCENTIVE_CHANGE_LOG_CHANGE_ElEMENT_CONTACT = 'Contact';
    public final static String INCENTIVE_CHANGE_LOG_CHANGE_ElEMENT_PROGRAM_COLLECTION = 'Program Collection';
    public final static String INCENTIVE_CHANGE_LOG_CHANGE_ElEMENT_STAFF_ASSIGNMENT = 'Staff Assignment';
    public final static String INCENTIVE_CHANGE_LOG_CHANGE_ElEMENT_BUSINESS_TITLE = 'Business Title';
    public final static String INCENTIVE_CHANGE_LOG_CHANGE_ElEMENT_PRIMARY_PROGRAM_COLLECTION = 'Primary Program Collection';
    public final static String INCENTIVE_CHANGE_LOG_CHANGE_ElEMENT_INCENTIVE_ROLE = 'Incentive Role';
    
    //Hold the Default option for Change Type Select List in ViewAffectedGoal Vf page
    public final static String INCENTIVE_CHANGE_LOG_CHANGE_TYPE_DEFAULT_SELECT_OPTION = 'All change types';
    public final static String INCENTIVE_CHANGE_LOG_CHANGE_TYPE_DEFAULT_SELECT_OPTION_VALUE = 'All';
    //V1.3 - Modified - Rajeev Jain - ISSP Deployment E - CR-20151120-9402 - Upto here
    
    //Personal Goal trigger variables
    public final static String PERSONAL_GOAL_RECORD_TYPE_PERSONAL_GOAL = 'Personal_Goal';
    public final static String PERSONAL_GOAL_RECORD_TYPE_PROPOSAL = 'Proposal';
    public final static String PERSONAL_GOAL_OBJECT = 'Personal_Goal__c';
    
    //Relationship Management controller variables
    public final static String VALUE_TYPE_NAME_JOB_TITLE = 'Job Title';
    
    //Define Std Goal VF page's controller variables
    public final static String STANDARD_GOAL_STANDARD_TYPE_GROUP = 'Group';
    public final static String STANDARD_GOAL_STANDARD_TYPE_PERSONAL = 'Personal';
    public final static String STANDARD_GOAL_DETAIL_TARGET_TYPE_PACED = 'Paced';
    public final static String STANDARD_GOAL_DETAIL_PACING_VALUE_TYPE_PERCENT = 'Percent';
    public final static String CLONED_GOAL_TEMPLATE_DETAIL_DESCRIPTION_PREPEND_VALUE = 'Clone of ';
    public final static String TEMPLATE_BASELINE = 'Template';
    public final static String CONDITION_RECORD_TYPE_DEVELOPER_NAME_COLLECTION_PERSPECTIVE = 'Collection_Perspective';
    public final static String CONDITION_RECORD_TYPE_DEVELOPER_NAME_ASSIGNMENT_ROLE = 'Assignment_Role';
    public final static String CONDITION_RECORD_TYPE_DEVELOPER_NAME_INSTITUTION = 'Institution';
    public final static String CONDITION_RECORD_TYPE_DEVELOPER_NAME_RELATIONSHIP = 'Relationship';
    public final static String CONDITION_RECORD_TYPE_DEVELOPER_NAME_RENEWAL_TYPE = 'Renewal_Type';
    public final static String CONDITION_RECORD_TYPE_DEVELOPER_NAME_ACTIVITY_DATE = 'Activity_Date';
    public final static String CONDITION_RECORD_TYPE_DEVELOPER_NAME_CREDIT_TYPE = 'Credit_Type';
    public final static String CONDITION_RECORD_TYPE_DEVELOPER_NAME_STAFF_MEMBER = 'Staff_Member';
    public final static String CONDITION_RECORD_TYPE_COLLECTION = 'Collection';
    public final static String CONDITION_RECORD_TYPE_ASSIGNMENT_ROLE = 'Assignment Role';
    public final static String CONDITION_RECORD_TYPE_RENEWAL_TYPE = 'Renewal Type';
    public final static String CONDITION_RECORD_TYPE_ACTIVITY_DATE = 'Activity Date';
    public final static String CONDITION_RECORD_TYPE_CREDIT_TYPE = 'Credit Type';
    public final static String CONDITION_RECORD_TYPE_STAFF_MEMBER = 'Staff Member';
    
    public final static String GTD_VALUE_TYPE_AMOUNT = 'Amount';
    public final static String GTD_VALUE_TYPE_COUNT = 'Count';
    public final static String GTD_VALUE_TYPE_PERCENT = 'Percent';
    
    //Create Personal Goal from std goal VF page's controller variables
    public final static String CLICKED_ICON_PAYEE = 'Payee';
    public final static String CLICKED_ICON_PERSONAL_GOAL = 'Personal Goal';
    public final static String STANDARD_GOAL_DETAIL_TARGET_TYPE_EXPLICIT = 'Explicit';
    public final static String PERSONAL_GOAL_VALUE_TYPE_AMOUNT = 'Amount';
    public final static String PERSONAL_GOAL_VALUE_TYPE_COUNT = 'Count';
    public final static String PERSONAL_GOAL_VALUE_TYPE_PERCENT = 'Percent';
    public final static String GOAL_TYPE_DISCOUNT_TYPE_MULTIPLIERS = 'Multipliers';
    public final static String GOAL_TYPE_DISCOUNT_TYPE_EXPLICIT = 'Explicit';
    public final static String LIMIT_TO_NAMED_PAYEE = 'Named Payee';
    public final static String LIMIT_TO_PAYEES_ALREADY_ASSIGNED = 'Payees already assigned';
    public final static String LIMIT_TO_BUSINESS_TITLE_MATCHES_GOAL_TEMPLATE = 'Business Title matches Goal Template';
    public final static String LIMIT_TO_SPECIFIC_BUSINESS_TITLE = 'Specific Business Title';
    public final static String LIMIT_TO_SPECIFIC_INCENTIVE_ROLE = 'Specific Incentive Role';
    public final static String LIMIT_TO_SPECIFIC_GOAL_TEMPLATE = 'Specific Goal Template';
    public final static String LIMIT_TO_SPECIFIC_RATE_TEMPLATE = 'Specific Rate Template';
    //V1.2 - Added By - Rajeev Jain - ISSP Deployment E - CR-20160304-9675
    public final static String LIMIT_TO_INDIVIDUAL_PAYEE = 'Individual Payee';
    public final static String TASK_STATUS_COMPLETED = 'Completed';
    public final static String TASK_PRIORITY_NORMAL = 'Normal';
    public final static String TASK_SUBJECT_OTHER = 'Other';
    public final static String TASK_SUBJECT_GOAL_COMMENTS = 'Goal Comments';
    public final static Integer CREATE_PERSONAL_GOAL_MULTIPLIER = 25000;
    public final static Decimal CREATE_PERSONAL_GOAL_PERCENT_MULTIPLIER = .10;
    public final static String TASK_SUBJECT_GOAL_COMMENTS_UPDATED = 'Updated after original creation';
    public final static String TASK_SUBJECT_GOAL_COMMENTS_GOAL_ADDED = 'Proposed Goal added';
    
    //Identify Impacts Variables
    public final static String TASK_SUBJECT_IMPACTS_IDENTIFIED = 'Impacts Identified';
    
    //Identify Affected Goals Variables
    public final static String INCENTIVE_CHANGE_LOG_CHANGE_TYPE_ADDED_COLLECTION_PERSPECTIVE = 'Added to Collection Perspective';
    public final static String INCENTIVE_CHANGE_LOG_CHANGE_TYPE_ADDED_EFFECTIVE_DATES = 'Effective Dates';
    public final static String INCENTIVE_CHANGE_LOG_CHANGE_TYPE_ADDED_ADDITION = 'Addition';
    public final static String INCENTIVE_CHANGE_LOG_CHANGE_TYPE_ADDED_DATES = 'Dates';
    public final static String INCENTIVE_CHANGE_BATCH_RECORD_TYPE_PROCESSED = 'Processed';
    public final static List<String> INCENTIVE_CHANGE_LOG_CHANGE_TYPES = new List<String>{'Text', 'Addition', 'Removal', 'Dates'};
    
    //Assign New Goals To Plans Variables
    public final static String VALUE_TYPE_CATEGORY_BUSINESS_TITLE = 'Business Title';
    public final static String VALUE_TYPE_CATEGORY_INCENTIVE_ROLE = 'Incentive Role';
    public final static String VALUE_TYPE_CATEGORY_OTHER = 'Other';
    public final static String VALUE_TYPE_NAME_TENURE = 'Tenure';
    public final static String PERSONAL_GOAL_COLOR_GREEN = 'green';
    public final static String PERSONAL_GOAL_COLOR_RED = 'red';
    public final static String PERSONAL_GOAL_COLOR_YELLOW = '#FF9900';
    public final static String STATUS_VOID = 'Void';
    public final static String CARRYOVERINNEWVERSION = 'carryOverInNewVersion';
    public final static String PERSONAL_PLAN_STATUS_PENDING = 'Pending';
    
    //Variables for Goal Template Clone apex 
    public final static String CLONED_GOAL_TEMPLATE_DESCRIPTION_PREPEND_VALUE = 'Clone of: ';
    
    //Variables for Personal Goal status Sumitted Status
    //Set to get stage name of Internal opportunity for Stage Received button
    public static final Set<String> SET_PERSONAL_GOAL_STATUS = new Set<String> {
                                                                                'Available',
                                                                                'Former'
                                                                                };
    public final static String PERSONAL_GOAL_STATUS_SUBMITTED = 'Submitted';
    public final static String PERSONAL_GOAL_STATUS_AVAILABLE = 'Available';
    public final static String PERSONAL_GOAL_STATUS_PENDING = 'Pending';
    public final static String PERSONAL_GOAL_STATUS_APPROVED = 'Approved';
    public final static String PERSONAL_GOAL_STATUS_PAYEE_APPROVED = 'Payee Approved';
    public final static String PERSONAL_GOAL_STATUS_FORMER = 'Former';
    
    //Variables for RequestFeedTransmission
    public final static String PERMISSION_SET_MASTER_FEED_MANAGER = 'Incentives_Master_Feed_Manager';
    public final static String EXECUTION_REQUESTED_NOW = 'Now';
    public final static String EXECUTION_REQUESTED_CUSTOM = 'Custom';
    public final static String PLEASE_SELECT_DATE = 'Please select date';
    public final static String SELECTED_DATETIME_SHOULD_BE_IN_FUTURE = 'Selected datetime should be in future';
    public final static String AM_TIME_PERIOD = 'AM';
    public final static String PM_TIME_PERIOD = 'PM';
    public final static String PROFILE_SYSTEM_ADMINISTRATOR = 'System Administrator';
    public final static List<SelectOption> TIMEOPTIONS = new List<SelectOption>{
                                                            new SelectOption('12:00','12:00'),
                                                            new SelectOption('12:30','12:30'),
                                                            new SelectOption('1:00','1:00'),
                                                            new SelectOption('1:30','1:30'),
                                                            new SelectOption('2:00','2:00'),
                                                            new SelectOption('2:30','2:30'),
                                                            new SelectOption('3:00','3:00'),
                                                            new SelectOption('3:30','3:30'),
                                                            new SelectOption('4:00','4:00'),
                                                            new SelectOption('4:30','4:30'),
                                                            new SelectOption('5:00','5:00'),
                                                            new SelectOption('5:30','5:30'),
                                                            new SelectOption('6:00','6:00'),
                                                            new SelectOption('6:30','6:30'),
                                                            new SelectOption('7:00','7:00'),
                                                            new SelectOption('7:30','7:30'),
                                                            new SelectOption('8:00','8:00'),
                                                            new SelectOption('8:30','8:30'),
                                                            new SelectOption('9:00','9:00'),
                                                            new SelectOption('9:30','9:30'),
                                                            new SelectOption('10:00','10:00'),
                                                            new SelectOption('10:30','10:30'),
                                                            new SelectOption('11:00','11:00'),
                                                            new SelectOption('11:30','11:30')
                                                            };
    
    //Variables for RequestFeedTransmission
    public final static List<SelectOption> AMPMOPTIONS = new List<SelectOption>{
                                                            new SelectOption('AM','AM'),
                                                            new SelectOption('PM','PM')
                                                            };
    
    
    //V_1.2 - Added BY - Rajeev Jain - 04/06/2016 - CR-20160304-9674 - ISSP Deployment E
    //Default value for Condition Set
    public static final Decimal DEFAULT_VALUE_CONDITION_SET = 1;
    
}