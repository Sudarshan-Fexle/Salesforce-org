/**
 *  Description     :  This class to hold all the constants properties for CPQ project
 *
 *  Created By      :  Subhash Garhwal
 *
 *  Created Date    :  06/09/2016
 *
 *  Revision Logs   :   V_1.0 - Created  - Subhash Garhwal - CR-20160414-9762
 *                      V_1.1 - Modified - Subhash Garhwal - CR-20160830-10158 - Q2C Hypercare
 *                      V_1.2 - Modified - Subhash Garhwal -  - 10/12/2016   Q2C Hypercare of Hypercare
 *                      V_1.3 - Modified - Subhash Garhwal - CR-20161205-10523 - 12/29/2016 
 *                      V_1.4 - Modified - Subhash Garhwal - CR-20170403-10807 - 04/06/2017 - Q2C Phase 2 
 *                      V_1.5 - Modified - Victor Hanson   - CR-20170403-10807 - 05/15/2017  - Added Merged recordType details
 *                      V_1.6 - Modified - Subhash Garhwal - CR-20170403-10807 - 05/17/2017 
 *                      V_1.7 - Modified - Saurabh Kumar   - CR-20170403-10807 - 05/18/2017  
 *                      V_1.8 - Modified - Subhash Garhwal - CR-20170403-10807 - 05/24/2017 
 *                      V_1.9 - Modified - Subhash Garhwal - CR-20170403-10807 - 05/30/2017  
 *                      V_2.0 - Modified - Subhash Garhwal - CR-20170403-10807 - 06/06/2017 
 *                      V_2.1 - Modified - Saurabh Kumar   - Issue--CR11094--UAT--00005392 - 08/11/2017 
 *                      V_2.2 - Modified - Deepak kumar    - Issue--CR11094--QA--00005396  - 08/17/2017 
 *                      V_2.3 - Modified - Colin McGloin   - Issue--CR11156--QA--00005594  - 08/24/2017 - Changed 'Merged' opp record type name to 'Merged/Migrated'
 *                      V_2.4 - Modified - Victor Hanson   - Issue--CR11141--QA--00005712  - 09/06/2017  - Updated SET_OPPORTUNITY_MERGE_FIELDS
 *                      V_2.5 - Modified - Subhash Garhwal - Issue--CR11637--QA--00006996  - 10/17/2017  - Change merge child from Warm Lead to Warm Lead MTM
 *			V_2.6 - Modified - Subhash Garhwal   - CR-20180827-12522 - 09/06/2018 
 *			V_2.7 - Modified - Subhash Garhwal   - CR-20181107-12737 - 11/12/2018  - Updated SET_OPPORTUNITY_MERGE_FIELDS
 *			V_2.8 - Modified - Rajeev Jain       - CR-20180726-12469 - 03/06/2019  - Deploying this to the production.
 *			V_2.9 - Modified - Colin McGloin     - CR-20190502-13078 - 06/26/2019  - Sunset certain Opp Stages and added new ones
 *			V_3.0 - Modified - Subhash Garhwal   - CR-20181019-12685 - 01/10/2019  - Added new values for ES CPQ setup
 *			V_3.1 - Modified - Mahendra Swarnkar - CR-20181019-12685 - 03/25/2019 
 *                      V_3.2 - Modified - Subhash Garhwal   - CR-20190911-13329 - 09/27/2019 
 *			V_3.3 - Modified - Subhash Garhwal   - CR-20200825-14471 - 8/31/2020  - New Constant Properties added
 *			V_3.4 - Modified - Subhash Garhwal   - CR-20200916-14518 - 9/25/2020  - Remove this Validation: If Additional Destinations is selected,
 *                              							        then Additional Destinations - Studio Services has to be selected. Remove it from both YOUVM and YOUVUG.
 *			V_3.5 - Modified - Subhash Garhwal   - CR-20200825-14471 - 8/31/2020 
 *			V_3.6 - Modified - Subhash Garhwal   - CR-20200922-14545 - 9/25/2020 
 *			V_3.7 - Modified - Victor Hanson     - CR-20201013-14598 - 10/27/2020  - added PRODUCT_CODES_COSTS
 *			V_3.8 - Modified - Subhash Garhwal   - CR-20201106-14674 - 11/10/2020 
 *			V_3.9 - Modified - Mahendra Swarnkar - CR-20200217-13756 - 03/16/2020  - RT deleted : HC Initiating From Opportunity.
 *			V_4.0 - Modified - Mahendra Swarnkar - CR-20201215-14746
 *			V_4.1 - Modified - Mahendra Swarnkar - CR-20210218-14932
 *			V_4.2 - Modified - Mahendra Swarnkar - CR-20210122-14829 - 02/25/2021 - Commented some code part
 *          		V_4.3 - Modified - Subhash Garhwal   - CR-20210421-15094 - 04/29/2021  - Removed Custom Application Marketing Validation
 *			V_4.4 - Modified - Subhash Garhwal   - CR-20210521-15172 - 05/26/2021 - Added Deal Summary bypass Products
 *			V_4.5 - Modified - Subhash Garhwal   - CR-20210315-14999
 *                      V_4.6 - Modified - Prateek Pant      - CR-20210712-15281 - 07/13/2021 - Removed Removed ES Undergrad Validation
 *			V_4.7 - Modified - Subhash Garhwal   - CR-20210726-15311 - 7/30/2021 
 *			V_4.8 - Modified - Mahendra Swarnkar - CR-20211213-15622 - 12/16/2021                
 **/
public class CPQConstants {
    
    // Modified - Mahendra Swarnkar - CR-20201215-14746
    //Set to hold the ESYO sub products for which Start/End dates will change.
    public final static Set<String> setDefaultANDStartEndDateChangeProducts = new Set<String>{'ESFAO','ESFAD', 'ESFBM', 'ESFYT', 'ESIQS', 'ESRTA', 'ESTFAO', 'ESYO','ESDISC','ESADLDISC', 'ESEMF'};
        
    //Set to hold the ESYO sub products for which Start/End dates are changed. 
    public final static Set<String> setStartEndDateChangeProducts = new Set<String>{'Program Costs - Financial Aid Optimization - Yield Optimization',
                                                                    'Program Costs - Financial Aid Descriptive Analysis - Yield Optimization',
                                                                    'Program Costs - Full Budget Model - Yield Optimization',
                                                                    'Program Costs - Four-Year Net Tuition Revenue Model - Yield Optimization',
                                                                    'Program Costs - Inquiry Scoring - Yield Optimization',
                                                                    'Program Costs - Retention Analysis - Yield Optimization',
                                                                    'Program Costs - Transfer Financial Aid Optimization - Yield Optimization'};
    
    public final static Map<String,String> mapApprovalStatusWithErrorMessage = new Map<String,String> {
    									'Approved' => 'If Approval Status is "Approved", Then "Status" should be "Approved" and proposal "Record Type" Should be "Approved Quote"',
                                                                        'Rejected' => 'If Approval Status is "Rejected", Then "Status" should be "Rejected" and proposal "Record Type" Should be "Open"',
                                                                        'Recalled' => 'If Approval Status is "Recalled", Then "Status" should be "Draft" and proposal "Record Type" Should be "Open"',
                                                                        'Pending' => 'If Approval Status is "Pending", Then "Status" should be "In Review" and proposal "Record Type" Should be "In Review"'};
    
    //Modified by Colin McGloin - 09/08/2020 - CR-20200720-14336
    public final static Set<String> THREE_LEVEL_PRODUCT_FAMILY_BYPASS_PENDING_SP_CREATION = new Set<String> {'Enrollment Services','YouVisit', 'Enrollment Services ALR'};
    
    //Added By Subhash Garhwal - 12/20/2018 - CR-20181019-12685
    public final static String ES_PRODUCT_FAMILY = 'Enrollment Services';
    public final static String ES_ALR_PRODUCT_FAMILY = 'Enrollment Services ALR';


    public final static String PROGRAM_PACKAGE_RT_ID_EAB = Schema.SObjectType.Program_Package__c.getRecordTypeInfosByName().get(Label.Program_Package_RT_Name_EAB).getRecordTypeId();
	
    //Added By Mahendra Swarnkar on - 08/13/2019 - CR-12685 - Starts From Here                                                                                            
    public final static String CUSTOM_PERMISSION_CPQ_DEAL_DESK = 'CPQ_Deal_Desk';
    public final static String FIELD_SET_QUOTE_CALCULATING_FIELDS = 'CalculatingFields';
    
    //Commented by Mahendra Swarnkar - 03/16/2020 - CR-20200217-13756 - RT deleted : HC Initiating From Opportunity.    
    //Variables added by VH 4/3/17
    //public final static String OPP_RT_ID_HC_INITIATING = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(Label.Opportunity_RT_Name_HC_Initiating).getRecordTypeId();
    
    //Commented by Mahendra Swarnkar - 03/16/2020 - CR-20200217-13756 - RT deleted : HC Continuing From Opportunity.
    //public final static String OPP_RT_ID_HC_CONTINUING = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(Label.Opportunity_RT_Name_HC_Continuing).getRecordTypeId();
    public final static String OPP_RT_ID_EAB_INITIATING = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(Label.Opportunity_RT_Name_EAB_Initiating).getRecordTypeId();
    public final static String OPP_RT_ID_EAB_CONTINUING = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(Label.Opportunity_RT_Name_EAB_Continuing).getRecordTypeId();
    public final static String OPP_RT_ID_MERGED = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Merged/Migrated').getRecordTypeId();
    public final static String SUBSCRIPTION_RT_ID_PROGRAM = Schema.SObjectType.SBQQ__Subscription__c.getRecordTypeInfosByName().get(CPQConstants.SBQQ_SUBSCRIPTION_RECORD_TYPE_DEVELOPERNAME_PROGRAM).getRecordTypeId();
    public final static String SUBSCRIPTION_RT_ID_COMPONENT = Schema.SObjectType.SBQQ__Subscription__c.getRecordTypeInfosByName().get(CPQConstants.SBQQ_SUBSCRIPTION_RECORD_TYPE_DEVELOPERNAME_COMPONENT).getRecordTypeId();
    
    //Subscription Period Record Type IDs
    public final static String SUBSCRIPTION_PERIOD_RT_ID_HC = Schema.SObjectType.Subscription_Period__c.getRecordTypeInfosByName().get('HC').getRecordTypeId();
    public final static String SUBSCRIPTION_PERIOD_RT_ID_EAB = Schema.SObjectType.Subscription_Period__c.getRecordTypeInfosByName().get('EAB').getRecordTypeId();
    
    //Commented by Mahendra Swarnkar - 03/16/2020 - CR-20200217-13756 - RT deleted : HC Initiating From Opportunity.
    public final static set<Id> OPP_INITIATING_RT_ID_SET = new set<Id> {/*OPP_RT_ID_HC_INITIATING,*/ OPP_RT_ID_EAB_INITIATING};
    //Commented by Mahendra Swarnkar - 03/16/2020 - CR-20200217-13756 - RT deleted : HC Continuing From Opportunity.
    public final static set<Id> OPP_CONTINUING_RT_ID_SET = new set<Id> {/*OPP_RT_ID_HC_CONTINUING,*/ OPP_RT_ID_EAB_CONTINUING};
        
    public final static string OPP_TYPE_INITIAL_TERM = 'Initial Term';
    public final static string OPP_TYPE_CONTINUING_FIRST_RENEWAL = 'Continuing - First Time Renewal';
    public final static string OPP_TYPE_CONTINUING_TENURED_RENEWAL = 'Continuing - Tenured Renewal';
    
    public final static string RECORD_SOURCE_PLACEHOLDER = 'Shadow';
    
    public final static integer DEFAULT_PROPOSAL_TERM_36_MONTHS = 36;
    
    //Variables
    public final static String CPQ_NEWOPPORTUNITY = 'CPQ_NewOpportunity';
    public final static String CPQ_OPPORTUNITYONDECK = 'CPQ_OpportunityOnDeck';
    public final static String CPQ_OPPORTUNITYPIPELINE = 'CPQ_OpportunityPipeline';
    public final static String CPQ_OPPORTUNITYCLOSEDWON = 'CPQ_OpportunityClosedWon';
    public final static String CPQ_OPPORTUNITYCLOSEDLOST = 'CPQ_OpportunityClosedLost';
    public final static String OPPORTUNITY_CONTRACT_LOA_NEW_AND_EDIT_PAGE_OPPORTUNITYCONTRACTLOAEDIT = 'OpportunityContractLOAEdit';
    public final static String PROGRAM_OPPORTUNITY_DUPLICATE_ERROR_MESG = 'Duplicate:  A Program Opportunity already exists for the selected Program.';
    public final static String CONTRACT_INT_ACC_RT_DN_STANDARD_CONTRACT = 'Standard_Contract';
    
    //Opportunity Stage
    public final static String OPPORTUNITY_STAGE_ON_DECK = 'On Deck';
    public final static String OPPORTUNITY_STAGE_ON_PIPELINE = 'Pipeline';
    public final static String OPPORTUNITY_STAGE_CLOSED_WON = 'Closed Won';
    public final static String OPPORTUNITY_STAGE_CLOSED_LOST = 'Closed Lost';
    public final static String OPPORTUNITY_STAGE_PROSPECT = 'Prospect';
    public final static String OPPORTUNITY_STAGE_ACTIVE_IN_SLOWTRACK = 'Active in SlowTrack';
    public final static String OPPORTUNITY_STAGE_ALTERNATE_PROPOSAL = 'Alternate Proposal';
    public final static String OPPORTUNITY_STAGE_CONTRACT_REC_SEND_TO_FINANCE = 'Contract Received - Send to Finance';
    public final static String OPPORTUNITY_STAGE_SEND_TO_FINANCE_OPP_REJECTED = 'Sent To Finance - Opp Rejected';
    public final static String OPPORTUNITY_STAGE_PENDING_RENEWAL_CALL_NOT_YET_OCCURED = 'Pending- Renewal Call Not Yet Occured';
    public final static String OPPORTUNITY_STAGE_PENDING = 'Pending';
    public final static String OPPORTUNITY_STAGE_CLOSED = 'Closed';
    public final static String OPPORTUNITY_STAGE_ACTIVITY_SCHEDULED = 'Activity Scheduled';
    public final static String OPPORTUNITY_STAGE_ORIGINATION = 'Origination';
    public final static String OPPORTUNITY_STAGE_MIGRATED = 'Migrated';
    
    //Old Opportunity Stage values - Sunset in VVS CR - CR-20190502-13078
    public final static String OPPORTUNITY_STAGE_MQL = '0-MQL';
    public final static String OPPORTUNITY_STAGE_MQL_Rejected = 'MQL Rejected';
    public final static String OPPORTUNITY_STAGE_CONNECT = '1-Connect';
    public final static String OPPORTUNITY_STAGE_CREATE = '2-Create';
    public final static String OPPORTUNITY_STAGE_COLLABORATE = '3-Collaborate';
    public final static String OPPORTUNITY_STAGE_CONFIRM = '4-Confirm';
    public final static String OPPORTUNITY_STAGE_CLOSE_PENDING = '5-Close-Pending';
    public final static String OPPORTUNITY_STAGE_HONORARY = 'Honorary';

    //New Opportunity Stage values - Introduced in VVS CR - CR-20190502-13078
    public final static String OPPORTUNITY_STAGE_EXPLORING = '0-Exploring';
    public final static String OPPORTUNITY_STAGE_OPPORTUNITY_STAGE_EXPLORING_Rejected = 'Exploring Rejected';
    public final static String OPPORTUNITY_STAGE_CONSIDERING = '1-Considering';
    public final static String OPPORTUNITY_STAGE_EVALUATING = '2-Evaluating';
    public final static String OPPORTUNITY_STAGE_CONFIRMING = '3-Confirming';
    public final static String OPPORTUNITY_STAGE_SELECTED = '4-Selected';
    public final static String OPPORTUNITY_STAGE_CLOSING = '5-Closing';
    
    //Added "OPPORTUNITY_STAGE_CONSIDERING" opportunity stage name in the set - By Mahendra Swarnkar - 02/20/2020 - CR-20190724-13231
    //opportunity stages that do not require a proposal
    public final static Set<String> OPP_STAGES_WITHOUT_PROPOSAL = new Set<String>{ OPPORTUNITY_STAGE_EXPLORING, OPPORTUNITY_STAGE_OPPORTUNITY_STAGE_EXPLORING_Rejected,
                                                                                   OPPORTUNITY_STAGE_CLOSED_LOST, OPPORTUNITY_STAGE_CLOSED_WON, OPPORTUNITY_STAGE_CONSIDERING,
                                                                                   OPPORTUNITY_STAGE_HONORARY, OPPORTUNITY_STAGE_MIGRATED };
    
    //Opportunity Type
    public final static String OPPORTUNITY_TYPE_CONTRACT_RENEWAL_OPPORTUNITY = 'Contract Renewal Opportunity';
    
    //V_1.12 - Added the new varibale 
    public final static String SBQQ_QUOTE_INVOICE_FREQUENECY_ANNUAL = 'Annual';
    
    
    //Opportunity Source Stage
    public final static String OPPORTUNITY_SOURCE_STAGE_ON_DECK = 'On Deck';
    public final static String OPPORTUNITY_SOURCE_STAGE_PIPELINE = 'Pipeline';
    public final static String OPPORTUNITY_SOURCE_STAGE_RENEWAL = 'Renewal';
    
    //Opportunity Program Proposal Status 
    public final static String PROGRAM_PROPOSAL_STATUS_PRIMARY_PROPOSAL = 'Primary Proposal';
    public final static String PROGRAM_PROPOSAL_STATUS_INACTIVE = 'Inactive';
    
    //Opportunity Record Type Developer Name
    //Commented by Mahendra Swarnkar - 03/17/2020 - CR-20200217-13756 - RT deleted : Contract LOA From Opportunity.
    //public final static String OPPORTUNITY_RECORD_TYPE_DEVELOPERNAME_CONTRACT_LOA = 'Contract_LOA';
    //Commented by Mahendra Swarnkar - 03/17/2020 - CR-20200217-13756 - RT deleted : Program – PT Marketing
    //public final static String OPPORTUNITY_RECORD_TYPE_DEVELOPERNAME_PROGRAM_PT_MARKETING = 'Program_PT_Marketing';
    //public final static String OPPORTUNITY_RECORD_TYPE_NAME_PROGRAM_PT_MARKETING = 'Program – PT Marketing';
    //Commented by Mahendra Swarnkar - 03/17/2020 - CR-20200217-13756 - RT deleted : Program – RI Marketing
    //public final static String OPPORTUNITY_RECORD_TYPE_DEVELOPERNAME_PROGRAM_RI_MARKETING = 'Program_RI_Marketing';
    //public final static String OPPORTUNITY_RECORD_TYPE_NAME_PROGRAM_RI_MARKETING = 'Program – RI Marketing';
    //Commented by Mahendra Swarnkar - 03/17/2020 - CR-20200217-13756 - RT deleted : Program_Consulting_Management.
    //public final static String OPPORTUNITY_RECORD_TYPE_DEVELOPERNAME_PROGRAM_CONSULTING_MANAGEMENT = 'Program_Consulting_Management';
    //Commented by Mahendra Swarnkar - 03/17/2020 - CR-20200217-13756 - RT deleted : Program – PT Contract Maintenance
    //public final static String OPPORTUNITY_RECORD_TYPE_DEVELOPERNAME_PROGRAM_PT_MAINTENANCE = 'Program_PT_Maintenance';
    //public final static String OPPORTUNITY_RECORD_TYPE_NAME_PROGRAM_PT_CONTRACT_MAINTENANCE = 'Program – PT Contract Maintenance';
    //Commented by Mahendra Swarnkar - 03/17/2020 - CR-20200217-13756 - RT deleted : Program – PT Contract Renewal
    //public final static String OPPORTUNITY_RECORD_TYPE_DEVELOPERNAME_PROGRAM_PT_RENEWAL = 'Program_PT_Renewal';
    //public final static String OPPORTUNITY_RECORD_TYPE_NAME_PROGRAM_PT_CONTRACT_RENEWAL = 'Program – PT Contract Renewal';
    //Commented by Mahendra Swarnkar - 03/17/2020 - CR-20200217-13756 - RT deleted :Program_RI_Maintenance
    //public final static String OPPORTUNITY_RECORD_TYPE_DEVELOPERNAME_PROGRAM_RI_MAINTENANCE = 'Program_RI_Maintenance';
    //Commented by Mahendra Swarnkar - 03/17/2020 - CR-20200217-13756 - RT deleted : Program – RI AM First Year Opp
    //public final static String OPPORTUNITY_RECORD_TYPE_NAME_PROGRAM_RI_AM_FIRST_YEAR_OPP = 'Program – RI AM First Year Opp';
    //Commented by Mahendra Swarnkar - 03/17/2020 - CR-20200217-13756 - RT deleted : Program_RI_Renewal
    //public final static String OPPORTUNITY_RECORD_TYPE_DEVELOPERNAME_PROGRAM_RI_RENEWAL = 'Program_RI_Renewal';
    //Commented by Mahendra Swarnkar - 03/17/2020 - CR-20200217-13756 - RT deleted :Program – RI AM Standard Opp
    //public final static String OPPORTUNITY_RECORD_TYPE_NAME_PROGRAM_RI_AM_STANDARD_OPP = 'Program – RI AM Standard Opp';
    
    //Subscription Variables
    //V_1.6 - Added by - Subhash Garhwal - 05/17/2017 - CR-20170403-10807 - New variable is added
    public final static String SBQQ_SUBSCRIPTION_RECORD_TYPE_DEVELOPERNAME_PROGRAM = 'Program';
    public final static String SBQQ_SUBSCRIPTION_RECORD_TYPE_DEVELOPERNAME_COMPONENT = 'Component';
    public final static String SBQQ_SUBSCRIPTION_RECORD_TYPE_DEVELOPERNAME_OFFER = 'Offer';
    public final static String SBQQ_SUBSCRIPTION_STATUS_VOID = 'Void';
    public final static String SBQQ_SUBSCRIPTION_STATUS_CLOSED = 'Closed';
    public final static String SBQQ_SUBSCRIPTION_STATUS_PENDING = 'Pending';
    public final static String SBQQ_SUBSCRIPTION_STATUS_ATL = 'ATL';
    public final static String SBQQ_SUBSCRIPTION_STATUS_DROPPED = 'Dropped';
    public final static String SBQQ_SUBSCRIPTION_STATUS_HONORARY = 'Honorary';
    
    //V_1.10 - Added by - Subhash Garhwal - 06/06/2017 - CR-20170403-10807
    public final static String SBQQ_QUOTE_TYPE_RENEWAL = 'Renewal';


    //V_1.8 - Added by - Subhash Garhwal - 05/24/2017 - CR-20170403-10807 - New variable is added
    public final static String SBQQ_SUBSCRIPTION_PERIOD_RECORD_TYPE_DEVELOPERNAME_HC = 'HC';
    public final static String SBQQ_SUBSCRIPTION_PERIOD_RECORD_TYPE_DEVELOPERNAME_EAB = 'EAB';

    //Variables to control the flow of sections on the OpportunityContractLOAEdit and OpportunityContractLOAView pages
    public final static String OPPORTUNITY_INFO_SECTION_STAGE_ONE_NEW = 'V1_INFO_New';
    public final static String OPPORTUNITY_INFO_SECTION_STAGE_TWO_OPEN = 'V2_INFO_Open';
    public final static String OPPORTUNITY_INFO_SECTION_STAGE_THREE_CLOSED = 'V3_INFO_Closed';
    public final static String OPPORTUNITY_RESULT_SECTION_STAGE_TWO_OPEN = 'V2_Result_Open';
    public final static String OPPORTUNITY_MF_SECTION_STAGE_TWO_OPEN = 'V2_MF_Open';
    public final static String OPPORTUNITY_MF_SECTION_STAGE_THREE_CLOSED = 'V3_MF_Closed';
    public final static String OPPORTUNITY_PIPELINE_SECTION_STAGE_TWO_OPEN = 'V2_Pipeline_Open';
    public final static String OPPORTUNITY_PIPELINE_SECTION_STAGE_THREE_CLOSED = 'V3_Pipeline_Closed';
    public final static String OPPORTUNITY_SB_SECTION_STAGE_ONE_TWO_NEW = 'V1_2_SB_New';
    public final static String OPPORTUNITY_SB_SECTION_STAGE_TWO_THREE_OPEN_OR_CLOSED = 'V2_3_SB_Open_Closed';
    public final static String OPPORTUNITY_OS_SECTION_STAGE_TWO_OPEN = 'V2_OS_Open';
    public final static String OPPORTUNITY_SI_SECTION_STAGE_TWO_THREE_OPEN = 'V2_3_SI_Open';
    public final static String OPPORTUNITY_RL_SECTION_STAGE_TWO_THREE = 'RL2_3_Open_Close';
    
    //Variables to control the flow of scetions for Program Opportunities
    public final static String PROGRAM_OPP_INFO_SECTION_OPEN_STAGE = 'V1_INFO_OPEN_STAGE';
    public final static String PROGRAM_OPP_INFO_SECTION_OPEN_ON_DECK_STAGE = 'V1_INFO_Open_ON_DECK';
    public final static String PROGRAM_OPP_INFO_SECTION_OPEN_ADVANCE_STAGE = 'V1_INFO_ADVANCE_STAGE';
    public final static String PROGRAM_OPP_INFO_SECTION_CLOSED_STAGE = 'V1_INFO_Closed';
    public final static String PROGRAM_OPP_PIPELINE_SECTION_NEW = 'V2_PIPELINE_NEW';
    public final static String PROGRAM_OPP_OPEN_ADVANCE = 'V2_OPEN_ADVANCE';
    public final static String PROGRAM_OPP_CLOSED_ADVANCE = 'V2_CLOSED_ADVANCE';
    public final static String PROGRAM_OPP_MSND_ADVANCE = 'V2_MSND_ADVANCE_STAGE';
    
    public final static string APEX_URL_INITIAL_PREFIX = '/apex/';
    public final static string BACK_SLASH_VAR = '/';
    public final static string NO_OVERRIDE = 'nooverride';
    public final static string ID_PARAM = 'id';
    public final static string RETURL = 'retURL';
    public final static string CONFIRMATIONTOKEN = '_CONFIRMATIONTOKEN';
    public final static string RECORD_EDIT = '/e';
    
    //Quote Line variables
    public final static string QUOTE_LINE_IS_PROGRAM_RI = 'RI';
    public final static string QUOTE_LINE_IS_PROGRAM_PT = 'PT';
    public final static string QUOTE_LINE_IS_PROGRAM_CONSULTING = 'Consulting';
    
    //Program Business Line
    public final static string PROGRAM_BUSINESS_LINE_RI = 'RI';
    public final static string PROGRAM_BUSINESS_LINE_PT = 'PT';
    public final static string PROGRAM_BUSINESS_LINE_CLN = 'CLN';
    
    //Quote Line/Product Identifiers
    public final static String QUOTE_LINE_PROGRAM_IDENTIFIER_CONSULTING = 'Consulting'; 
    
    //Quote Line SubscriptionCategory values
    public final static String QUOTE_LINE_PROGRAM_SUBSCRIPTIONCATEGORY_ANNUAL_FEE = 'Annual Fee';
    public final static String QUOTE_LINE_PROGRAM_SUBSCRIPTIONCATEGORY_TRAVEL_FEE = 'Travel Fee';
    public final static String QUOTE_LINE_PROGRAM_SUBSCRIPTIONCATEGORY_INITIATION = 'Initiation';
    
    //Object API Name
    //V_1.6 - Added by - Subhash Garhwal - 05/17/2017 - CR-20170403-10807 - New variable is added
    public final static String OBJECT_SBQQ_SUBSCRIPTION = 'SBQQ__Subscription__c';

    //V_1.10 - Added by - Subhash Garhwal - 06/06/2017 - CR-20170403-10807
    public final static String OBJECT_SBQQ_QUOTE = 'SBQQ__Quote__c';

    //V_1.8 - Added by - Subhash Garhwal - 05/17/2017 - CR-20170403-10807 - New variable is added
    public final static String OBJECT_SUBSCRIPTION_PERIOD = 'Subscription_Period__c';

    //Set to hold the SubscriptionCategory
    public final static Set<String> QUOTE_LINE_PROGRAM_SUBSCRIPTIONCATEGORY = new Set<String>{'Annual Fee', 'Travel Fee', 'Initiation'};
    
    //Set to hold the QuoteLine Program_or_Component__c values
    public final static Set<String> SET_QUOTE_LINE_PROGRAM_IDENTIFIERS = new Set<String>{'RI','PT', 'Consulting'};
    
    //Set to hold Opportunity Stage values for Opportunity Pipeline Section on OpportunityContractLOAEdit, OpportunityContractLOAView VF pages
    public final static Set<String> SET_OPPORTUNITY_STAGE_CONTRACT_LOA_VALUES = new Set<String>{'On Deck','Pipeline', 'Contract Received - Send to Finance', 'Sent To Finance - Opp Rejected'};
    
    //Set to hold the Opportunity Record Type DeveloperName's (CPQ related)
    public final static Set<String> SET_OPPORTUNITY_CPQ_RT_DEVELOPER_NAME = new Set<String>{'EAB_Continuing', 'EAB_Initiating'
                                                                                            /*'Program_PT_Marketing', 'Program_RI_Marketing',
                                                                                            'Program_PT_Maintenance', 'Program_PT_Renewal',
                                                                                            'Program_RI_Maintenance', 'Program_RI_Renewal'*/};
    
    //Set to hold all the Program Opportunity Record Type DeveloperName
    /*public final static Set<String> SET_OPPORTUNITY_CPQ_PROGRAM_OPP_RT_DEVELOPER_NAME = new Set<String>{'Program_Consulting_Management',
                                                                                            'Program_PT_Marketing', 'Program_RI_Marketing',
                                                                                            'Program_PT_Maintenance', 'Program_PT_Renewal',
                                                                                            'Program_RI_Maintenance', 'Program_RI_Renewal'};*/
                                                                                            
    //Set to hold all the Program Opportunity Record Type Name
    /*public final static Set<String> SET_OPPORTUNITY_CPQ_PROGRAM_OPP_RT_NAME = new Set<String>{'Program – Consulting & Management',
                                                                                            'Program – PT Marketing', 'Program – RI Marketing',
                                                                                            'Program – PT Contract Maintenance', 'Program – PT Contract Renewal',
                                                                                            'Program – RI AM First Year Opp', 'Program – RI AM Standard Opp'};*/
    
    //Set to hold all the Program Opportunity Record Type DeveloperName (PT Record Types)
    /*public final static Set<String> SET_OPPORTUNITY_CPQ_PROGRAM_OPP_RT_DEVELOPER_NAME_PT = new Set<String>{'Program_Consulting_Management',
                                                                                                           'Program_PT_Maintenance',
                                                                                                           'Program_PT_Renewal',
                                                                                                           'Program_PT_Marketing'};*/
    
    //Set to hold all the Program Opportunity Record Type DeveloperName (RI Record Types)
    /*public final static Set<String> SET_OPPORTUNITY_CPQ_PROGRAM_OPP_RT_DEVELOPER_NAME_RI = new Set<String>{'Program_RI_Maintenance',
                                                                                                           'Program_RI_Renewal',
                                                                                                           'Program_RI_Marketing'};*/
                                                                                            
    //Set to hold all the Program Opportunity Record Type DeveloperName
    /*public final static Set<String> SET_OPPORTUNITY_CPQ_SPECIFIC_PROGRAM_OPP_RT_DEVELOPER_NAME = new Set<String>{'Program_Consulting_Management',
                                                                                            'Program_PT_Marketing', 'Program_RI_Marketing'};*/
    
    //Map to hold Opportunity Record Types
    public final static Map<Id, RecordType> MAP_OPPORTUNITY_RECORD_TYPE = new Map<Id, RecordType>([Select Id, Name, DeveloperName From RecordType Where SobjectType = 'Opportunity' AND isActive = true]);
    
    //Map to hold the VF pages name with appropriate record type names
    public final static Map<String, String> MAP_OPPORTUNITY_RECORD_TYPE_WITH_DETAIL_VF_PAGE_NAME = new Map<String, String>{
    //Commented by Mahendra Swarnkar - 03/17/2020 - CR-20200217-13756 - RT deleted : Consulting & Management, Contract LOA From Opportunity.
                                                                                            /*'Southwind' => 'Opportunity_Consulting_And_Management',
                                                                                            'Contract_LOA' => 'OpportunityContractLOAView'*/
                                                                                            /*VH 3/28/17: Removing program opps as part of Q2C Part 2
                                                                                             * 'Program_Consulting_Management' => 'OpportunityProgramOppNBBDetailView',
                                                                                            'Program_PT_Marketing' => 'OpportunityProgramOppNBBDetailView',
                                                                                            'Program_RI_Marketing' => 'OpportunityProgramOppNBBDetailView'*/
                                                                                            };
                                                                           
    //Commented by Mahendra Swarnkar - 03/17/2020 - CR-20200217-13756 - RT deleted : Program_Consulting_Management, Program_PT_Marketing,Program_RI_Marketing
    //Map to hold the Opportunity Stage values prior to 'Active in Slow Track' according to record types
    public final static Map<String, Set<String>> MAP_OPPORTUNITY_STAGE_PRIOR_TO_AIST_WITH_RECORD_TYPE = new Map<String, Set<String>> {
                                                                                                    /*'Program_PT_Marketing' => new Set<String>{'Prospect', 'Outreach', 'Initial Visit Scheduled', 'Prewire'},
                                                                                                    'Program_RI_Marketing' => new Set<String>{'Prospect', 'Outreach', 'Initial Visit Scheduled', 'Prewire'},
                                                                                                    'Program_Consulting_Management' => new Set<String>{'Prospect', 'Outreach', 'Phone Appointment Scheduled','Initial Visit Scheduled','Proposal In Progress'}*/
                                                                                                    };
                                                                                                    
    //SelectOption list to display Opportunity stage according to current opp stage
    public final static List<SelectOption> OPPORTUNITY_ON_DECK_STAGE_OPTIONS = new List<SelectOption>{new SelectOption('On Deck','On Deck'), new SelectOption('Closed Lost','Closed Lost')};
    public final static List<SelectOption> OPPORTUNITY_ON_PIPELINE_STAGE_OPTIONS = new List<SelectOption>{new SelectOption('Pipeline','Pipeline'), new SelectOption('Contract Received - Send to Finance','Contract Received - Send to Finance'), new SelectOption('Closed Lost','Closed Lost')};
    public final static List<SelectOption> OPPORTUNITY_ON_CRSTF_STAGE_OPTIONS = new List<SelectOption>{new SelectOption('Contract Received - Send to Finance','Contract Received - Send to Finance'), new SelectOption('Sent To Finance - Opp Rejected','Sent To Finance - Opp Rejected'), new SelectOption('Closed Won','Closed Won'), new SelectOption('Closed Lost','Closed Lost')};
    public final static List<SelectOption> OPPORTUNITY_ON_STFR_STAGE_OPTIONS = new List<SelectOption>{new SelectOption('Pipeline','Pipeline'), new SelectOption('Contract Received - Send to Finance','Contract Received - Send to Finance'), new SelectOption('Sent To Finance - Opp Rejected','Sent To Finance - Opp Rejected'), new SelectOption('Closed Won','Closed Won'), new SelectOption('Closed Lost','Closed Lost')};
    public final static List<SelectOption> PROG_OPPORTUNITY_ON_DECK_STAGE_OPTIONS = new List<SelectOption>{new SelectOption('Prospect','Prospect'), new SelectOption('Outreach','Outreach'), new SelectOption('Initial Visit Scheduled','Initial Visit Scheduled'), new SelectOption('Prewire','Prewire'), new SelectOption('Closed Lost','Closed Lost')};
    
    //Modified - Subhash Garhwal - 12/29/2016 - CR-20161205-10523
    public final static List<SelectOption> PROG_OPPORTUNITY_PIPELINE_STAGE_OPTIONS = new List<SelectOption>{new SelectOption('Prospect','Prospect'), new SelectOption('Outreach','Outreach'), new SelectOption('Initial Visit Scheduled','Initial Visit Scheduled'), new SelectOption('Prewire','Prewire'), new SelectOption('Active in SlowTrack','Active in SlowTrack'), new SelectOption('Active in FastTrack','Active in FastTrack'), new SelectOption('Verbal Yes','Verbal Yes'), new SelectOption('Closed Lost','Closed Lost')};
    public final static List<SelectOption> PROG_OPPORTUNITY_CONTRACT_RECEIVED_STAGE_OPTIONS = new List<SelectOption>{new SelectOption('Contract Received - Send to Finance','Contract Received - Send to Finance'), new SelectOption('Closed Won','Closed Won'), new SelectOption('Closed Lost','Closed Lost')};
    public final static List<SelectOption> PROG_OPPORTUNITY_CLOSED_WON_NON_PRIMARY_STAGE_OPTIONS = new List<SelectOption>{new SelectOption('Closed Lost','Closed Lost')};
    
    //Program Opportunity On Deck stages
    public final static Set<String> SET_Program_Opp_ON_DECK_STAGES = new Set<String>{'Prospect', 'Outreach', 'Initial Visit Scheduled', 'Prewire'};
    public final static Set<String> SET_Program_Opp_PIPELINE_CONTRACT_STAGES = new Set<String>{'Active in SlowTrack', 'Active in FastTrack', 'Verbal Yes', 'Contract Received - Send to Finance', 'Sent To Finance - Opp Rejected'};
    
    //Set to hold Program Business line values
    public final static Set<String> SET_PROGRAM_BUSINESS_LINE_VALUES = new Set<String>{'RI','PT','CLN'};
    
    //Modified - 10/12/2016 - Subhash Garhwal - Change Record type developername to Name 
    //Map to hold the Program Opportunities Record Type according to selected Program's Business Line
    /*public final static Map<String, String> MAP_PROGRAM_OPP_RRECORD_TYPE_DN_WITH_PROGRAM_BL = new Map<String, String> {
                                                                                                                        'PT' => 'Program – PT Marketing',
                                                                                                                        'RI' => 'Program – RI Marketing',
                                                                                                                        'SW' => 'Program – Consulting & Management'
                                                                                                                      };*/
    
    //Set to hold the Contract Opp Stage values prior to Pipeline
    public final static Set<String> SET_CONTRACT_LOA_PIPELINE_PRIOR_STAGE_VALUES = new Set<String>{'On Deck'};
    
    //Commented by Mahendra Swarnkar - 03/17/2020 - CR-20200217-13756 - RT deleted : Core_AM_First_Year_Opp,Core_AM_Standard_Opp
    //Set to hold the Program Opportunities Record Type Developer Name to apply check in OpportunityTriggerHelper (Line : 580)
    public final static Set<String> SET_PROGRAM_OPP_RENEWAL_MAINTENANCE_RECORDTYPE_DN = new Set<String>{
                                                                                                        /*'Program_PT_Renewal', 'Program_PT_Maintenance',
                                                                                                        'Program_RI_Renewal', 'Program_RI_Maintenance',
                                                                                                        'Core_AM_Standard_Opp','Core_AM_First_Year_Opp',*/
                                                                                                        'BI_Contract_Maintenance','BI_Contract_Renewal'
                                                                                                        };
    
    //Map to hold the Program type with corresponding Renewal Opp Record types developerName Consulting
    /*public final static Map<String,String> MAP_PROGRAM_TYPE_WITH_RENEWAL_RECORDTYPE_DEVELOPERNAME = new Map<String, String> {'RI' => 'Program – RI AM Standard Opp',
                                                                                                         'PT' => 'Program – PT Contract Renewal',
                                                                                                         'Consulting' => 'Program – Consulting & Management'};*/
    
    //Set to hold the Proposal/Quote Status 
    public final static Set<String> SET_QUOTE_STATUS_VALUES = new Set<String>{'In Review', 'Approved'};
     
    //Added - 09/13/2016 - Subhash Garhwal - CR-20160830-10158
    public final static String PRODUCT_CATEGORY_INITIATION_FEE = 'Initiation Fee';
        
    /*******************            Q2C New Phase variables- Subhash Garhwal - 04/06/2017            *******************/
    
    //Opportunity Stage 
    public final static String OPP_STAGE_SENT_TO_CREDITED = 'Contract Received - Sent to Finance/Credited' ;
    public final static String OPP_STAGE_SENT_TO_BOOKED = 'Contract Received - Sent to Finance/Booked';
    public final static String OPP_STAGE_ACTIVE_FAST_TRACK = 'Active in FastTrack';

    //Opportunity Pipeline StageName
    public final static String OPP_PIPELINE_STAGE = '4 - Proposal Requested';

    //Set to hold the Opportunity Stages to identify the duplicate opps
    public final static Set<String> SET_OPP_DUPLICATE_CHECK_BYPASS_STAGES = new Set<String>{'Closed Lost', 'Closed Won', 'Dropped', 'Void', 'Closed'};
    
    //Commented by Mahendra Swarnkar - 03/16/2020 - CR-20200217-13756 - RT deleted : HC Initiating From Opportunity.
    //Set to hold the Opportunity Initiating record types
    public final static Set<String> SET_OPP_INITIATING_RECORDTYPES = new Set<String>{'EAB_Initiating'/*, 'HC_Initiating'*/};
    
    //Commented By - Mahendra Swarnkar - 02/25/2021 - CR-20210122-14829 - HC_Continuing deleted from Opportunity
    //Set to hold the Opportunity Initiating record types
    public final static Set<String> SET_OPP_CONTINUING_RECORDTYPES = new Set<String>{/*'HC_Continuing',*/ 'EAB_Continuing'};
    
    //Opportunity new Record Type Names
    //Commented by Mahendra Swarnkar - 03/16/2020 - CR-20200217-13756 - RT deleted : HC Initiating From Opportunity.
    //public final static String OPP_RECORD_TYPE_NAME_HC_INITIATING = 'HC Initiating';
    public final static String OPP_RECORD_TYPE_NAME_EAB_INITIATING = 'EAB Initiating';
    
    //Commented by Mahendra Swarnkar - 03/16/2020 - CR-20200217-13756 - RT deleted : HC Continuing From Opportunity.
    //public final static String OPP_RECORD_TYPE_NAME_HC_CONTINUING = 'HC Continuing';
    public final static String OPP_RECORD_TYPE_NAME_EAB_CONTINUING = 'EAB Continuing';
    public final static String OPP_RECORD_TYPE_DEVELOPER_NAME_MERGED = 'Merged_Migrated';

    
    //Initiating and Continuing record type name suffix
    public final static String OPP_INITIATING_RECORD_TYPE_SUFFIX = 'Initiating';
    public final static String OPP_CONTINUING_RECORD_TYPE_SUFFIX = 'Continuing';
    public final static String OPP_MERGED_RECORD_TYPE_SUFFIX = 'Merged/Migrated';
    public final static String CONTRACT_PREFIX = 'Contract-';
    
    //Contract object variables
    //V_1.7 - Modified - Saurabh Kumar - 05/18/2017 - CR-20170403-10807
    public final static String CONTRACT_STATUS_AMENDED_REPLACED = 'Amended Replaced';
    public final static String CONTRACT_AMENDMENT_RENEWAL_BEHAVIOR = 'Latest End Date';
    public final static String CONTRACT_AMENDMENT_OPPORTUNITY_STAGE = 'Proposal In Progress';
    public final static String CONTRACT_AMENDMENT_TYPE_UPSELL = 'Upsell';
    public final static String CONTRACT_STATUS_ACTIVATED_AMENDED = 'Activated_Amended';
    public final static String CONTRACT_AMENDMENT_TYPE_TERMINATION_OF_CONTRACT = 'Termination of Contract';
    public final static String CONTRACT_STATUS_TERMINATED = 'Terminated';
    public final static String CONTRACT_STATUS_AMEND_AND_EXTEND = 'Amend & Extend';

    //Subscription Period variables
    //V_1.8 - Added by - Subhash Garhwal - 05/24/2017 - CR-20170403-10807 - New variable to hold Subscription Period Type
    public final static String SUBSCRIPTION_PERIOD_COMPONENT_TYPE = 'Component';
    public final static String SUBSCRIPTION_PERIOD_RENEWAL_TYPE = 'Renewal';
    public final static String SUBSCRIPTION_PERIOD_STAGE_DROPPED = 'Dropped';
    public final static String SUBSCRIPTION_PERIOD_STAGE_VOID = 'Void';
    public final static String SUBSCRIPTION_PERIOD_STAGE_PENDING = 'Pending';
    public final static String SUBSCRIPTION_PERIOD_STAGE_ATL = 'ATL';
    
    //V_1.11 - Modified - Saurabh Kumar - 08/11/2017 - Issue--CR11094--UAT--00005392 - New variable is added
    public final static String SUBSCRIPTION_PERIOD_SUBSCRIPTION_TYPE_NET_NEW = 'Net New';
    //A flag is added to check insert case 
    public static Boolean SUBSCRIPTION_PERIOD_TRIGGER_INSERT_CASE = false;
    
    //Subscription Variables
    //V_1.8 - Modified - Subhash Garhwal - 05/24/2017 - CR-20170403-10807 
    public final static String PRODUCT_FAMILY_HIGHER_EDUCATION = 'Higher Education';
    public final static String PRODUCT_FAMILY_HEALTHCARE = 'Healthcare';
    public final static String RENEWAL_SUBSCRIPTION_PERIOD_STAGE_PENDING = 'Pending';
    public final static String SUBSCRIPTION_STAGE_ATL = 'ATL';

    //Set to hold the Opportunity Field API names those will merge from non-master opportunity to master opportunity
    public static Set<String> SET_OPPORTUNITY_MERGE_FIELDS {
        get {
            if (SET_OPPORTUNITY_MERGE_FIELDS == null) {
                
                //Updated By Subhash Garhwal - 11/12/2018 - CR-20181107-12737 - Starts from here
                /*SET_OPPORTUNITY_MERGE_FIELDS = new Set<String>{'Associate_Principal__c', 'Probability', 'Closing_Call_Scheduled__c',
                                                                'Date_Passed__c', 'Date_Visit_Happens__c', 'Initial_Visit_Date__c',
                                                                'Main_Contact__c', 'Meeting_Travel_Comp__c', 'National_Partner__c',
                                                                'NBB__c','NBB_Units__c','Next_Step_Date__c','Outreach_Campaign__c',
                                                                'Outreach_Campaign_Month__c', 'Executive_Sales_Support__c',
                                                                'Primary_Reason_Lost__c', 'Projection_Liklihood__c', 'RFP_Stage__c',
                                                                'Secondary_Reason_Lost__c', 'Sell_Type__c', 'Special_Commitments__c'};
                */
                                                                    
                SET_OPPORTUNITY_MERGE_FIELDS = new Set<String>();
                
                if (Label.Opportunity_Merge_Fields != null)
                    SET_OPPORTUNITY_MERGE_FIELDS.addAll(Label.Opportunity_Merge_Fields.split(','));
                //Updated By Subhash Garhwal - 11/12/2018 - CR-20181107-12737 -  Ends here
                                                                    
                if (Label.Opportunity_Merge_Additional_Fields != null)
                    SET_OPPORTUNITY_MERGE_FIELDS.addAll(Label.Opportunity_Merge_Additional_Fields.split(','));
            }
            
            return SET_OPPORTUNITY_MERGE_FIELDS;
        }
        set;
    }
    
    //Set to hold the Stage values for merge Opportunities
    public final static Set<String> SET_MERGE_OPPORTUNITY_STAGES = new Set<String>{'Pipeline', 'Pending', 
                                                                OPPORTUNITY_STAGE_EXPLORING, OPPORTUNITY_STAGE_OPPORTUNITY_STAGE_EXPLORING_Rejected,
                                                                OPPORTUNITY_STAGE_CONSIDERING,OPPORTUNITY_STAGE_EVALUATING,OPPORTUNITY_STAGE_CONFIRMING,
                                                                OPPORTUNITY_STAGE_SELECTED,OPPORTUNITY_STAGE_CLOSING,
                                                               'Proposal In Progress', 
                                                               'Origination', 'Need Confirmed', 'Commercial Interaction'
                                                               };
    
    //Commented by Mahendra Swarnkar - 03/16/2020 - CR-20200217-13756 - RT deleted : HC Initiating From Opportunity.
    //Commented by Mahendra Swarnkar - 03/16/2020 - CR-20200217-13756 - RT deleted : HC Continuing From Opportunity.
    //Map to hold the Non master opportunity record types with appropriate master record type
    //This map will used to verify the record type while merging opps
    //Commented By - Mahendra Swarnkar - 02/25/2021 - CR-20210122-14829 - HC_Initiating and HC_Continuing deleted from Opportunity
    public final static Map<String, Set<String>> MAP_MASTER_RECORD_TYPE_WITH_NON_MASTER_RECORD_TYPES = new Map<String,Set<String>>{
                                                                                   'EAB_Initiating' => new Set<String>{'EAB_Initiating', /*'HC_Initiating',*/
                                                                                                                       'BI_Marketing', 'Core_Marketing'
                                                                                                                      },
                                                                                    /*'HC_Initiating' => new Set<String>{'EAB_Initiating', /*'HC_Initiating',/
                                                                                                                       'BI_Marketing', 'Core_Marketing'
                                                                                                                      },*/
                                                                                    'EAB_Continuing' => new Set<String>{'EAB_Initiating', /*'HC_Initiating',*/
                                                                                                                        'EAB_Continuing', /*'HC_Continuing',*/
                                                                                                                        'BI_Marketing', 'Core_Marketing'
                                                                                                                      }/*,
                                                                                    'HC_Continuing' => new Set<String>{'EAB_Initiating', /*'HC_Initiating',/
                                                                                                                        'EAB_Continuing', /*'HC_Continuing',/
                                                                                                                        'BI_Marketing', 'Core_Marketing'
                                                                                                                      }*/
                                                                                   };
    
    
    
    
    //Map to hold the Opportunity Child object API name with Refreance Field API Name
    public final static Map<String,String> MAP_OPPORTUNITY_CHILDREN_OBJECT_WITH_REFERENCE_FIELD_API_NAME = new Map<String,String>{
                                                                                                           'SBQQ__Quote__c' => 'SBQQ__Opportunity2__c',
                                                                                                           'Task' => 'WhatId',
                                                                                                           'Event' => 'WhatId',
                                                                                                           /*'OpportunityContactRole' => 'OpportunityId',*/
                                                                                                           'Warm_Lead_MtM__c' => 'Opportunity__c',
                                                                                                           /*'OpportunityTeamMember' => 'OpportunityId',*/
                                                                                                           'Reference_Request__c' => 'Source_Opportunity__c',
                                                                                                           'NBB__c' => 'Opportunity__c',
                                                                                                           'Team_Membership__c' => 'Opportunity__c',
                                                                                                           'Integrated_Account__c' => 'Opportunity__c',
                                                                                                           /*'ContentDocumentLink' => 'LinkedEntityId',*/
                                                                                                           'CampaignMember' => 'Opportunity__c',
                                                                                                           'SBQQ__Subscription__c' => 'Renewal_Opportunity__c'
                                                                                                           /*'Contract' => 'SBQQ__RenewalOpportunity__c'*/
                                                                                                           };
    
    //Map to hold the addition field values to update while switching non master opportunity child records to master opportunity
    public final static Map<String, Map<String, Object>> map_Opportunity_Children_Other_Fields_With_Fixed_Values = new Map<String,Map<String, Object>>{
                                                                                                                   'SBQQ__Quote__c' => new Map<String, Object>{'SBQQ__Primary__c'=> false},
                                                                                                                   'OpportunityContactRole' => new Map<String, Object>{'IsPrimary'=> false}
                                                                                                                   };
    
    //Commented by Mahendra Swarnkar - 03/16/2020 - CR-20200217-13756 - RT deleted : HC Initiating, HC Continuing From Opportunity.
    //Set to hold the New Opp Record Type Names
    public final static Set<String> SET_OPPORTUNITY_RECORDTYPE_NAMES = new Set<String>{'EAB Continuing', 'EAB Initiating' /*, 'HC Continuing', 'HC Initiating'*/};
    
    //Commented by Mahendra Swarnkar - 03/16/2020 - CR-20200217-13756 - RT deleted : HC Initiating From Opportunity.
    //Commented by Mahendra Swarnkar - 03/16/2020 - CR-20200217-13756 - RT deleted : HC Continuing From Opportunity.
    //Set to hold the new Record Types Developer Names
    public final static Set<String> SET_OPPORTUNITY_RECORDTYPE_DEVELOPERNAMES = new Set<String>{'EAB_Continuing', 'EAB_Initiating'/*, 'HC_Continuing', 'HC_Initiating'*/};

    //Variable to hold document status
    public final static String DOCUMENT_STATUS_SIGNED = 'Signed';

    //Set to hold the Record types Developer NAmes
    public final static Set<String> SET_OPPORTUNITY_RECORDTYPES_NAMES_MARKETING = new Set<String>{'Core_Marketing', 'BI_Marketing'};
    
    //Variable to hold the document status
    public final static String PROPOSAL_DOCUMENTSTATUS_SENT_FOR_SIGNATURE = 'Sent for Signature';
    public final static String PROPOSAL_DOCUMENTSTATUS_SIGNATURE = 'Signed';
    public final static String DOCUMENT_STATUS_SIGNED_MANUAL_UPLOAD = 'Signed - Manual Upload';
    public final static String PROPOSAL_STATUS_APPROVED = 'Approved';
    public final static String PROPOSAL_STATUS_LOCKED = 'Locked';
    public final static String PROPOSAL_STATUS_REJECTED = 'Rejected';
    public final static String PROPOSAL_STATUS_RECALLED = 'Recalled';
    public final static String PROPOSAL_STATUS_PENDING = 'Pending';
    public final static String PROPOSAL_STATUS_DRAFT = 'Draft';
    public final static String PROPOSAL_STATUS_IN_REVIEW = 'In Review';
    
    public final static String PROPOSAL_APPROVAL_STATUS_OPEN = 'Open';
    public final static String PROPOSAL_APPROVAL_STATUS_DRAFT = 'Draft';
    
    
    
    public final static String SBQQ_QUOTE_OBJECT = 'SBQQ__Quote__c';
    public final static String CONTENT_DOCUMENT_OBJECT = 'ContentDocument';
    
    //Set to hold the Contract Received - Sent to Finance Stage Values
    public final static Set<String> SET_OPP_STAGE_CONTRACT_RECEIVED_SENT_TO_FINANCE_VALUES = new Set<String>{
                                                                                                            'Contract Received - Sent to Finance/Credited',
                                                                                                            'Contract Received - Sent to Finance/Booked',
                                                                                                            'Contract Received - Send to Finance'
                                                                                                            };
    //Set to hold Subscription stage
    public final static set<String> SUBSCRIPTION_STAGE = new set<String> {'Void' , 'Dropped'};

    //Opportunity StageName closed
    public final static String OPPORTUNITY_STAGENAME_CLOSED = 'Closed';
    
    public final static String CONTRACT_STATUS_ACTIVATED = 'Activated';
    
    //V_1.9 - Modified - Subhash Garhwal - 05/30/2017
    public final static String TERM_TYPE_FIXED_TERM = 'Fixed Term';
    public final static String PREVIOUS_SUBSCRIPTION_TYPE_YEAR_FIXED_TERM = 'Year Fixed Term';
    public final static String PREVIOUS_SUBSCRIPTION_TYPE_TERM_YEAR_OPT = 'Year with Opt Out';


    //Source opportunity type
    public final static String TYPE_NBB = 'NBB';
    public final static String Type_RENEWAL = 'RENEWAL';
    public final static String Type_NEWBUSINESS = 'New Business';

    //Set to hold the activate Contract Status
    public final static Set<String> CONTRACT_ACTIVATE_STATUS = new Set<String>{'Activated', 'Activated Amended', 'Amended Replaced', 'Terminated', 'Expired'};

    //String to hold Subscription Renewal Type
    public final static String SUBSCRIPTION_RENEWAL_TYPE_CONTINUING = 'Continuing';
    public final static String SUBSCRIPTION_RENEWAL_TYPE_INITIAL = 'Initial';
    
    //Opportunity object prefix
    public final static string OPPORTUNITY_OBJECT_PREFIX = '006';
    
    //custom permissions
    public final static String CUSTOM_PERMISSION_RENEWAL_PROPOSAL_BUTTON = 'Renewal_Proposal_Button_Access';
    
    //Variables for Issue--CR10808--QA--00004803
    public final static Set<String> CPQ_SUBSCRIPTION_FUND_AND_ANNUAL_OPT_OUT_TYPES = new Set<String>{'Funds Appropriation Opt Out', 'Annual Opt Out on Anniversary with penalty fee',
                                                                                                     'Annual Opt Out on Anniversary without penalty fee',  'Annual Opt Out On Anniversary With Stated Penalty Fee'};
    
    public final static Set<String> CPQ_SUBSCRIPTION_BOARD_AND_ROLLING_OPT_OUT_TYPES = new Set<String>{'Board Approval Opt Out', 'Rolling Opt Out with Penalty Fee',
                                                                                                       'Rolling Opt Out without Penalty Fee'};
    
    public final static Set<String> CPQ_SUBSCRIPTION_ONE_POINT_AND_AFTER_FIRST_YEAR_OPT_OUT_TYPES = new Set<String>{'One Point in Time Opt Out With Penalty Fee', 'One Point in Time Opt Out Without Penalty Fee',
                                                                                                       'Opt Out after First Year in Membership With Penalty Fee', 'Opt Out after First Year in Membership Without Penalty Fee', 'One Point in Time Opt Out With Stated Penalty Fee'};

    //Static Variables for holding the Decision Type values to set on Subscription Period                                                                                                   
    public final static String SUBSCRIPTION_PERIOD_DECISION_TYPE_OPT_OUT = 'Opt Out';
    public final static String SUBSCRIPTION_PERIOD_DECISION_TYPE_FIXED_TERM = 'Fixed Term'; 
    
    //CR-20180726-12469
    public final static String SUBSCRIPTION_PERIOD_DECISION_TYPE_NEED_NEW_LOA = 'Need New LOA';
 
    //CR-20180827-12522
    public final static String SUBSCRIPTION_PERIOD_SENT_TO_FINANCE_REQUEST_DROP= 'Sent To Finance - Request Drop';
    
    //Static variabl;e for holding the product category 
    public final static String PRODUCT_CATEGORY_TRAVEL_FEE = 'Travel Fee';
    public final static String PRODUCT_CATEGORY_IMPLEMENTATION_FEE = 'Implementation Fee';
    public final static String PRODUCT_CATEGORY_ANNUAL_FEE = 'Annual Fee';
    
    
    public static Boolean IS_FUTURE_JOB = true;
        
    //10/27/2020 - CR-20201013-14598 - Victor Hanson - added variables - start here
    public final static String PRODUCT_CODE_PROGRAM_COSTS = 'Program Costs';
    public final static String PRODUCT_CODE_CAPPEX_SERV_COST = 'Cappex Service Costs';
    public final static List<String> COST_PRODUCT_CODES = new List<String> { PRODUCT_CODE_PROGRAM_COSTS, PRODUCT_CODE_CAPPEX_SERV_COST };
    //10/27/2020 - CR-20201013-14598 - Victor Hanson - added variables - end here
    
    //Subhash Gargwal - 01/10/2019 - CR-20181019-12685 - Enrollment Services CPQ variables
    //public final static Set<String> CPQ_ES_PRODUCT_CODES = new Set<String>{'Program Costs', 'Media Costs', 'Postage Costs'};
    
    //10/27/2020 - CR-20201013-14598 - Victor Hanson - updated reference to program costs to reference the variable instance & added PRODUCT_CODE_CAPPEX_SERV_COST
    //Modified by Subhash Garhwal - 02/06/2020
    public final static Set<String> CPQ_ES_PRODUCT_CODES = new Set<String>{PRODUCT_CODE_PROGRAM_COSTS, PRODUCT_CODE_CAPPEX_SERV_COST, 'Additional Discount', 'Multi Year Discount'};
    
    //Variable to hold the Program Pakcage calculation origin
    public final static String ORIGIN_SUBSCRIPTION = 'Subscription';
    public final static String ORIGIN_PROPOSAL_LINE = 'Proposal Line';
    public final static String PRODUCT_NAME_YEAR_ROUND_SEARCH = 'Year Round Search';
    
    //Added by Subhash Garhwal - 09/27/2019 - CR-20190911-13329
    public final static String PRODUCT_Custom_Application_Marketing = 'Custom Application Marketing';
    public final static String PRODUCT_Name_Web_Application = 'Web Application';
    public final static String PRODUCT_NAME_New_Names = 'New Names';
    public final static String PRODUCT_NAME_PRE_Names = 'PRE Names';
    
    //Added by Subhash Garhwal - 12/18/2019
    public final static String PRODUCT_You_Visit_Main = 'YouVisit Main';
    //Updated by Subhash Garhwal - 02/11/2020 - Name changed from YouVisit to Virtual Tour
    public final static String PRODUCT_Virtual_Tour = 'Virtual Tour';
    // Modified By - Mahendra Swarnkar - CR-20210218-14932
    //public final static String PRODUCT_Studio_Services = 'Additional Studio Services Refresh';
    public final static String PRODUCT_Studio_Services = 'Legacy Photo Only Refresh';
    public final static String PRODUCT_NAME_SOPHOMORE_JUNIOR_FULFILLMENT = 'Sophomore/ Junior Fulfillment';
    public final static String PRODUCT_NAME_OFFER_1 = 'Offer 1';
    public final static String PRODUCT_NAME_OFFER_2 = 'Offer 2';
    public final static String PRODUCT_NAME_OFFER_3 = 'Offer 3';
    public final static String PRODUCT_NAME_INQUIRY_POOL = 'Inquiry Pool';
    
    //Added by Subhash Garhwal - 08/04/2020 - CR-20200723-14357 start here
    public final static String PRODUCT_NAME_INQUIRY_POOL_SEARCH = 'Inquiry Pool – Search';
    public final static String PRODUCT_NAME_New_Names_SEARCH = 'New Names – Search';
    public final static String PRODUCT_NAME_PRE_Names_SEARCH = 'Pre Names – Search';
    public final static String PRODUCT_NAME_INQUIRY_POOL_CUSTOM_APP_MARKETING = 'Inquiry Pool – Custom App Marketing';
    public final static String PRODUCT_NAME_New_Names_CUSTOM_APP_MARKETING = 'New Names – Custom App Marketing';
    public final static String PRODUCT_NAME_PRE_Names_CUSTOM_APP_MARKETING = 'Pre Names – Custom App Marketing';
    public final static String PRODUCT_NAME_INQUIRY_POOL_OTHER_APP_MARKETING = 'Inquiry Pool – Common/Other Application Marketing';
    public final static String PRODUCT_NAME_New_Names_OTHER_APP_MARKETING = 'New Names – Common/Other Application Marketing';
    public final static String PRODUCT_NAME_PRE_Names_OTHER_APP_MARKETING = 'Pre Names – Common/Other Application Marketing';
    // end here
    
    //Added by Colin McGloin - 07/27/2020 - Student Journey Products
    public final static String PRODUCT_STUDENT_JOURNEY = 'Student Journey';
    public final static String PRODUCT_STUDENT_JOURNEY_ARCHITECTURE = 'Student Journey - Architecture';
    public final static String PRODUCT_STUDENT_JOURNEY_BUSINESS = 'Student Journey - Business';
    public final static String PRODUCT_STUDENT_JOURNEY_COE = 'Student Journey - Continuing Online Education';
    public final static String PRODUCT_STUDENT_JOURNEY_DEGREE = 'Student Journey - Degree Completion';
    public final static String PRODUCT_STUDENT_JOURNEY_EDUCATION = 'Student Journey - Education';
    public final static String PRODUCT_STUDENT_JOURNEY_ENGINEERING = 'Student Journey - Engineering';
    public final static String PRODUCT_STUDENT_JOURNEY_GRAD_WIDE = 'Student Journey - Grad Wide';
    public final static String PRODUCT_STUDENT_JOURNEY_HEALTH_SCIENCES = 'Student Journey - Health Sciences';
    public final static String PRODUCT_STUDENT_JOURNEY_LAW = 'Student Journey - Law';
    public final static String PRODUCT_STUDENT_JOURNEY_NURSING = 'Student Journey - Nursing';
    public final static String PRODUCT_STUDENT_JOURNEY_PHARMACY = 'Student Journey - Pharmacy';
    public final static String PRODUCT_HIGH_AFFINITY_AUDIENCE = 'High Affinity Audience';
    public final static String PRODUCT_ADDITIONAL_STUDENT_JOURNEY = 'Additional Student Journey';

    //Added by Colin McGloin - 07/27/2020 - Student Journey Sub Products Set
    public final static Map<String, String> MAP_STUDENT_JOURNEY_QUANTITY_VALIDATION_FIELDS = new Map<String, String> {'Student Journey - Architecture' => 'Student_Journey_Quantity_Arch__c',
                                                                                                                        'Student Journey - Business' => 'Student_Journey_Quantity_Bus__c',
                                                                                                                        'Student Journey - Continuing Online Education' => 'Student_Journey_Quantity_COE__c',
                                                                                                                        'Student Journey - Degree Completion' => 'Student_Journey_Quantity_DC__c',
                                                                                                                        'Student Journey - Education' => 'Student_Journey_Quantity_Edu__c',
                                                                                                                        'Student Journey - Engineering' => 'Student_Journey_Quantity_Eng__c',
                                                                                                                        'Student Journey - Grad Wide' => 'Student_Journey_Quantity_GW__c',
                                                                                                                        'Student Journey - Health Sciences' => 'Student_Journey_Quantity__c',
                                                                                                                        'Student Journey - Law' => 'Student_Journey_Quantity_Law__c',
                                                                                                                        'Student Journey - Nursing' => 'Student_Journey_Quantity_Nur__c',
                                                                                                                        'Student Journey - Pharmacy' => 'Student_Journey_Quantity_Pha__c'};

    public final static Set<String> SET_HA_AUDIENCE_QUANTITY_VALIDATION_SUBPRODUCTS = new Set<String> {'High Affinity Audience'};

    public final static Set<String> SET_ADDT_STUDENT_JOURNEY_VALIDATION_SUBPRODUCTS = new Set<String> {'Additional Student Journey'};

    public final static List<String> LIST_STUDENT_JOURNEY_QUANTITY_VALIDATION_FIELDS = new List<String> {'Student_Journey_Quantity__c'};
    
    public final static List<String> LIST_STUDENT_JOURNEY_HA_QUANTITY_VALIDATION_FIELDS = new List<String> {'High_Affinity_Audience_Quantity__c'};

    public final static List<String> LIST_ADDT_STUDENT_JOURNEY_VALIDATION_FIELDS = new List<String> {'Additional_Student_Journey_Versions__c'};
    
    // modified Subhash Garhwal - 08/04/2020  Inquiry Poo To Inquiry Pool – Search
    //Set to hold the "Year Round Search" sub product details
    public final static Set<String> SET_YRS_PARENT_SUBPRODUCTS = new Set<String> {'Sophomore/ Junior Fulfillment', 'Inquiry Pool – Search'};
    public final static Set<String> SET_YRS_CHILD_SUBPRODUCTS = new Set<String> {'Offer 1', 'Offer 2', 'Offer 3'};
        
    //Added by Subhash Garhwal - 12/18/2019
    public final static Set<String> SET_YOU_VISIT_MAIN_PARENT_SUBPRODUCTS = new Set<String> {'Virtual Tour'};
    public final static Set<String> SET_YOU_VISIT_MAIN_CHILD_SUBPRODUCTS = new Set<String> {'Studio Services'};

    //Added by Subhash Garhwal - 09/27/2019 - CR-20190911-13329
    //Set to hold the "Custom Application Marketing" sub product details
    public final static Set<String> SET_ESAM_PARENT_SUBPRODUCTS = new Set<String> {'Web Application', 'New Names – Custom App Marketing', 'Pre Names – Custom App Marketing', 'Inquiry Pool – Custom App Marketing'};
    
    //  modified by Subhash Garhwal - 08/04/2020 start here
    //Map to hold the mapping of the fields with fields details for Total Contracted Contact Qty and Total 'Pending Signature' Contact Qty fields.
    public final static Map<String, Set<String>> MAP_PRODUCTS_WITH_QL_FIELD_DETAILS = new Map<String, Set<String>>{
                                                                                                    'New Names' => new Set<String>{'Paper_New_Names__c', 'E_Only_New_Names__c'},
                                                                                                    'New Names – Search' => new Set<String>{'Paper_New_Names__c', 'E_Only_New_Names__c'},
                                                                                                    'New Names – Custom App Marketing' => new Set<String>{'Paper_New_Names__c', 'E_Only_New_Names__c'},
                                                                                                    'New Names – Common/Other Application Marketing' => new Set<String>{'Paper_New_Names__c', 'E_Only_New_Names__c'},
                                                                                                    'Inquiry Pool' => new Set<String>{'Paper_Inquiry_Pool__c', 'E_Only_Inquiry_Pool__c'},
                                                                                                    'Inquiry Pool – Search' => new Set<String>{'Paper_Inquiry_Pool__c', 'E_Only_Inquiry_Pool__c'},
                                                                                                    'Inquiry Pool – Custom App Marketing' => new Set<String>{'Paper_Inquiry_Pool__c', 'E_Only_Inquiry_Pool__c'},
                                                                                                    'Inquiry Pool – Common/Other Application Marketing' => new Set<String>{'Paper_Inquiry_Pool__c', 'E_Only_Inquiry_Pool__c'},
                                                                                                    'PRE Names' => new Set<String>{'Paper_PRE_Names__c', 'E_Only_PRE_Names__c'},
                                                                                                    'Pre Names – Search' => new Set<String>{'Paper_PRE_Names__c', 'E_Only_PRE_Names__c'},
                                                                                                    'Pre Names – Custom App Marketing' => new Set<String>{'Paper_PRE_Names__c', 'E_Only_PRE_Names__c'},
                                                                                                    'Pre Names – Common/Other Application Marketing' => new Set<String>{'Paper_PRE_Names__c', 'E_Only_PRE_Names__c'},
                                                                                                    'Sophomore/ Junior Fulfillment' => new Set<String>{'Paper_Quantity_Fulfillment__c', 'E_Only_Quantity_Fulfillment__c'},
                                                                                                    'Transfer Application Marketing' => new Set<String>{'Paper_Transfer_Marketing__c', 'E_Only_Transfer_Marketing__c'}
                                                                                                                };
    
    //Map to hold the mapping of the fields with fields details for Total Contracted Contact Qty and Total 'Pending Signature' Contact Qty fields.
    public final static Map<String, Set<String>> MAP_PRODUCTS_WITH_SUB_FIELD_DETAILS = new Map<String, Set<String>>{
                                                                                                    'New Names' => new Set<String>{'Paper_New_Names_m__c', 'E_Only_New_Names_m__c'},
                                                                                                    'New Names – Search' => new Set<String>{'Paper_New_Names_m__c', 'E_Only_New_Names_m__c'},
                                                                                                    'New Names – Custom App Marketing' => new Set<String>{'Paper_New_Names_m__c', 'E_Only_New_Names_m__c'},
                                                                                                    'New Names – Common/Other Application Marketing' => new Set<String>{'Paper_New_Names_m__c', 'E_Only_New_Names_m__c'},
                                                                                                    'Inquiry Pool' => new Set<String>{'Paper_Inquiry_Pool_m__c', 'E_Only_Inquiry_Pool_m__c', 'E_Only_Client_Provided_Inquiries_m__c', 'E_Only_EAB_Generated_Inquiries_m__c', 'Paper_Client_Provided_Inquiries_m__c', 'Paper_EAB_Generated_Inquiries_m__c'},
                                                                                                    'Inquiry Pool – Search' => new Set<String>{'Paper_Inquiry_Pool_m__c', 'E_Only_Inquiry_Pool_m__c', 'E_Only_Client_Provided_Inquiries_m__c', 'E_Only_EAB_Generated_Inquiries_m__c', 'Paper_Client_Provided_Inquiries_m__c', 'Paper_EAB_Generated_Inquiries_m__c'},    
                                                                                                    'Inquiry Pool – Custom App Marketing' => new Set<String>{'Paper_Inquiry_Pool_m__c', 'E_Only_Inquiry_Pool_m__c', 'E_Only_Client_Provided_Inquiries_m__c', 'E_Only_EAB_Generated_Inquiries_m__c', 'Paper_Client_Provided_Inquiries_m__c', 'Paper_EAB_Generated_Inquiries_m__c'},    
                                                                                                    'Inquiry Pool – Common/Other Application Marketing' => new Set<String>{'Paper_Inquiry_Pool_m__c', 'E_Only_Inquiry_Pool_m__c', 'E_Only_Client_Provided_Inquiries_m__c', 'E_Only_EAB_Generated_Inquiries_m__c', 'Paper_Client_Provided_Inquiries_m__c', 'Paper_EAB_Generated_Inquiries_m__c'},
                                                                                                    'PRE Names' => new Set<String>{'Paper_PRE_Names_m__c', 'E_Only_PRE_Names_m__c'},
                                                                                                    'Pre Names – Search' => new Set<String>{'Paper_PRE_Names_m__c', 'E_Only_PRE_Names_m__c'},    
                                                                                                    'Pre Names – Custom App Marketing' => new Set<String>{'Paper_PRE_Names_m__c', 'E_Only_PRE_Names_m__c'},    
                                                                                                    'Pre Names – Common/Other Application Marketing' => new Set<String>{'Paper_PRE_Names_m__c', 'E_Only_PRE_Names_m__c'},
                                                                                                    'Sophomore/ Junior Fulfillment' => new Set<String>{'Paper_Quantity_Fulfillment_m__c', 'E_Only_Quantity_Fulfillment_m__c'},
                                                                                                    'Transfer Application Marketing' => new Set<String>{'Paper_Transfer_Marketing_m__c', 'E_Only_Transfer_Marketing_m__c'},
                                                                                                    'Discount' => new Set<String>(),
                                                                                                    'EMF Recruitment Center' => new Set<String>()
                                                                                                                };
                                                                            
    // end here
    //Added By Mahendra Swarnkar - 03/25/2019 - CR-20181019-12685 - Starts from here
    //Set to hold the Paper Only fields for Total_Paper_only_Contract_Quantity__c.
    public final static Set<String> PAPER_ONLY_FIELDS = new Set<String>{'Paper_New_Names_m__c','Paper_Inquiry_Pool_m__c', 'Paper_PRE_Names_m__c',
                                                                        'Paper_Quantity_Fulfillment_m__c', 'Paper_Transfer_Marketing_m__c', 
                                                                        'Paper_Client_Provided_Inquiries_m__c', 'Paper_EAB_Generated_Inquiries_m__c'};
    
    //Set to hold the Paper Only fields for Total_e_only_Contract_Quantity__c.
    public final static Set<String> E_ONLY_FIELDS = new Set<String>{'E_Only_New_Names_m__c','E_Only_Inquiry_Pool_m__c', 'E_Only_PRE_Names_m__c',
                                                                    'E_Only_Quantity_Fulfillment_m__c', 'E_Only_Transfer_Marketing_m__c',
                                                                    'E_Only_Client_Provided_Inquiries_m__c','E_Only_EAB_Generated_Inquiries_m__c'};
    //Added By Mahendra Swarnkar - 03/25/2019 - CR-20181019-12685 - Ends here
    
    //Map to hold the Parent Product Name and then Sub Product Name with Related Sub Product that need to execlude in selection
    public final static Map<String, Map<String, Set<String>>> mapCustomProductSelectionValidations = new Map<String, Map<String, Set<String>>>{
                                                                                                'Transfer Recruitment' => new Map<String, Set<String>> {
                                                                                                                              'Transfer Application Marketing' => new Set<String>{'Transfer Custom Application Marketing'
                                                                                                                               }
                                                                                                }
                                                                                                       /*,
                                                                                                'Virtual Tour Main' => new Map<String, Set<String>> {
                                                                                                                              'PACK' => new Set<String>{'Virtual Tour - Studio Services'
                                                                                                                               }
                                                                                                },
                                                                                                'Virtual Tour- Undergraduate' => new Map<String, Set<String>> {
                                                                                                                              'PACK' => new Set<String>{'Virtual Tour - Studio Services'
                                                                                                                               }
                                                                                                }*/
                                                                                };
    //9/25/2020 - Subhash garhwal - CR-20200916-14518 - Remove Additional Destinations Products from list to remove the validation.
    //9/25/2020 - Subhash Garhwal - CR-20200922-14545 - Added Virtual Tour – PACK product in the validation.
    //04/29/2021 - Subhash Garhwal - CR-20210421-15094 - Removed Custom Application Marketing Validation
    //validation: If Additional Destinations is selected, then Additional Destinations - Studio Services has to be selected. Remove it from both YOUVM and YOUVUG.
    
    //07/13/2021 - Prateek Pant - CR-20210712-15281 - Removed ES Undergrad Validation.
    //validation: Must select Financial Aid Optimization if selecting Four-Year Net Tuition Revenue Model.
    
    //Modified By - Mahendra Swarnkar - - CR-20211213-15622 -  12/16/2021
    //Map to hold the Parent Product Name and then Sub Product Name with Related Sub Product that need to include in selection
    //Map to hold the Parent Product Name and then Sub Product Name with Related Sub Product that need to include in selection
    public final static Map<String, Map<String, Set<String>>> MAP_CUSTOM_PRODUCT_INCLUDE_VALIDATIONS = new Map<String, Map<String, Set<String>>> { 
                                                                                                'Year Round Search' => new Map<String, Set<String>> {
                                                                                                                              'Offer 3' => new Set<String>{'Offer 2'}
                                                                                                },
                                                                                                /*'Yield Optimization' => new Map<String, Set<String>> {
                                                                                                                              'Four-Year Net Tuition Revenue Model' => new Set<String>{'Financial Aid Optimization'},
                                                                                                                              'Transfer Financial Aid Optimization' => new Set<String>{'Financial Aid Optimization'}
                                                                                                },*/
                                                                                                /*'Custom Application Marketing' => new Map<String, Set<String>> {
                                                                                                                                        'Web Application' => new Set<String>{'Inquiry Pool','PRE Names', 'New Names'}
                                                                                                },*/    
                                                                                                'Virtual Tour Main' => new Map<String, Set<String>> {
																	'Virtual Tour' => new Set<String>{/*'Virtual Tour - Studio Services',*/ 'PACK', 'Photo Only Onsite Shoot', 'Photo & Video Onsite Shoot', 'Virtual Tour Setup Fee - Upgrade', 'Virtual Tour Setup Fee - New Tour'},
                                                                                                                                        'Additional Audio Guide' => new Set<String>{'Additional Audio Guide - Setup Fee'},
                                                                                                                                        'Interactive Map' => new Set<String>{ 'Interactive Map - Setup Fee'}    
                                                                                                    					/*,
                                                                                                                                        '360 Degree Video' => new Set<String>{'360 Degree Video - Studio Services'},
                                                                                                                                        'Additional Virtual Tour' => new Set<String>{'Additional Virtual Tour - Studio Services'},
                                                                                                                                        'Additional Action Zones' => new Set<String>{'Additional Action Zones - Studio Services'}*/
																								},    
                                                                                                'Virtual Tour- Undergraduate' => new Map<String, Set<String>> {
																	'Virtual Tour' => new Set<String>{/*'Virtual Tour - Studio Services',*/ 'PACK', 'Photo Only Onsite Shoot', 'Photo & Video Onsite Shoot', 'Virtual Tour Setup Fee - Upgrade', 'Virtual Tour Setup Fee - New Tour'},
                                                                                                                                        'Additional Audio Guide' => new Set<String>{'Additional Audio Guide - Setup Fee'},
                                                                                                                                        'Interactive Map' => new Set<String>{ 'Interactive Map - Setup Fee'}
                                                                                                    					/*,
                                                                                                                                        '360 Degree Video' => new Set<String>{'360 Degree Video - Studio Services'},
                                                                                                                                        'Additional Virtual Tour' => new Set<String>{'Additional Virtual Tour - Studio Services'},
                                                                                                                                        'Additional Action Zones' => new Set<String>{'Additional Action Zones - Studio Services'}*/
																								}
																				};
	
	// Modified By - Mahendra Swarnkar - - CR-20211213-15622 - 12/16/2021
	//Map to hold the Validation messages for
	public final static Map<String, String> MAP_VALIDATION_MSG_FOR_PRODUCT_CONFIGURATOR = new Map<String, String>{'Transfer Application Marketing' => 'Can only select either \'Transfer Application Marketing\' or \'Transfer Custom Application Marketing\'',
                                                                                                                 													 'Offer 3' => '\'Offer 3\' can only selected with \'Offer 2\'',
                                                                                                                                                                                                                         /*'Four-Year Net Tuition Revenue Model' => 'Must select \'Financial Aid Optimization\' if selecting \'Four-Year Net Tuition Revenue Model\'',*/
                                                                                                                 												         /*'Transfer Financial Aid Optimization' => 'Must select \'Financial Aid Optimization\' if selecting \'Transfer Financial Aid Optimization\'', */
        																									         'Virtual Tour' => 'Must select either ' + /* '\'Virtual Tour - Studio Services\' OR ' */ +  '\'PACK\' OR \'Photo Only Onsite Shoot\', \'Photo & Video Onsite Shoot\' OR \'Virtual Tour Setup Fee - Upgrade\', \'Virtual Tour Setup Fee - New Tour\' if selecting \'Virtual Tour\'',
        																										 'Additional Audio Guide' => 'Must select \'Additional Audio Guide - Setup Fee\' if selecting \'Additional Audio Guide\'',
        																										 'Interactive Map' => 'Must select \'Interactive Map - Setup Fee\' if selecting \'Interactive Map\''
        																										 //,
        																									         //'360 Degree Video' => 'Must select \'360 Degree Video - Studio Services\' if selecting \'360 Degree Video\'',
        																									         //'Additional Virtual Tour' => 'Must select \'Additional Virtual Tour - Studio Services\' if selecting \'Additional Virtual Tour\'',
        																									         //'Additional Action Zones' => 'Must select \'Additional Action Zones - Studio Services\' if selecting \'Additional Action Zones\'',
                                                                                                             	                                                                                                         //'Additional Destinations' => 'Must select \'Additional Destinations - Studio Services\' if selecting \'Additional Destinations\''
        																									         //,
        																									         //'PACK' => 'You cannot select both the Virtual Tour – Studio Services and the PACK product code on the same Virtual Tour proposal. Please select one or the other.'
																											
        																									         //,
																										         //'Web Application' => '\'Web Application\' can only selected with either \'New Name\' OR \'Pre Name\' OR \'Inquiry Pool\''
																										     };
	
	//Map to hold the Offer Products and related fields those need to validate
	public final static Map<String, String> MAPOFFERPRODICTSWITHRELATEDFIELDS = new Map<String, String>{'Offer 1' => 'Paper_Offer_or_PDF1__c', 'Offer 2' => 'Paper_Offer_or_PDF2__c', 'Offer 3' => 'Paper_Offer_or_PDF3__c'};
	
    /*
        Removed these values 'Paper_EAB_Generated_Inquiries__c', 'E_Only_EAB_Generated_Inquiries__c' from MAP_INQUIRY_POOL_PRODICTS_WITH_RELATED_FIELDS as values are deleted.
        Modified by Subhash Garhwal - 09/24/2019 - CR-20190911-13329
    */
    // modified by Subhash Garhwal - 08/04/2020
    //Map to hold the Inquiry Pool Products and related fields those need to validate
    public final static Map<String, List<String>> MAP_INQUIRY_POOL_PRODICTS_WITH_RELATED_FIELDS = new Map<String, List<String>>{'Inquiry Pool' => new List<String>{'Paper_Client_Provided_Inquiries__c', 'E_Only_Client_Provided_Inquiries__c'},
                                                                                                                               'Inquiry Pool – Search' => new List<String>{'Paper_Client_Provided_Inquiries__c', 'E_Only_Client_Provided_Inquiries__c'},
                                                                                                                               'Inquiry Pool – Custom App Marketing' => new List<String>{'Paper_Client_Provided_Inquiries__c', 'E_Only_Client_Provided_Inquiries__c'},
                                                                                                                               'Inquiry Pool – Common/Other Application Marketing' => new List<String>{'Paper_Client_Provided_Inquiries__c', 'E_Only_Client_Provided_Inquiries__c'}  
                                                                                                                               };
    
    //Added by Subhash Garhwal - 12/18/2019
    public final static Map<String, List<String>> MAP_YOU_VIST_PRODICTS_WITH_RELATED_FIELDS = new Map<String, List<String>>{'Virtual Tour' => new List<String>{/*'Are_you_proposing_YouVisit__c', */'You_Visit_Package_Type__c'}};
        
    //Added by Subhash Garhwal - 09/27/2019 - CR-20190911-13329
    //Map to hold the Web Application Products and related fields those need to validate
    public final static Map<String, List<String>> MAP_Web_Application_PRODICTS_WITH_RELATED_FIELDS = new Map<String, List<String>>{'Web Application' => new List<String>{'Web_Application_Versions_Freshman__c', 'Web_Application_Versions_Transfer__c', 'Web_Application_Versions_International__c', 'Web_Application_Versions_Other__c'}};
    //06-Nov-2019 - Start
    // modified by subhash Garhwal - 08/04/2020 start here
    public final static Map<String, List<String>> MAP_Inquiry_Pool_WITH_RELATED_FIELDS = new Map<String, List<String>>{'Inquiry Pool' => new List<String>{'Paper_Inquiry_Pool__c', 'E_Only_Inquiry_Pool__c'},
                                                                                                                      'Inquiry Pool – Search' => new List<String>{'Paper_Inquiry_Pool__c', 'E_Only_Inquiry_Pool__c'},
                                                                                                                      'Inquiry Pool – Custom App Marketing' => new List<String>{'Paper_Inquiry_Pool__c', 'E_Only_Inquiry_Pool__c'},
                                                                                                                      'Inquiry Pool – Common/Other Application Marketing' => new List<String>{'Paper_Inquiry_Pool__c', 'E_Only_Inquiry_Pool__c'}
                                                                                                                      };
    public final static Map<String, List<String>> MAP_New_Names_WITH_RELATED_FIELDS = new Map<String, List<String>>{'New Names' => new List<String>{'Paper_New_Names__c', 'E_Only_New_Names__c'},
                                                                                                                    'New Names – Search' => new List<String>{'Paper_New_Names__c', 'E_Only_New_Names__c'},
                                                                                                                    'New Names – Custom App Marketing' => new List<String>{'Paper_New_Names__c', 'E_Only_New_Names__c'},
                                                                                                                    'New Names – Common/Other Application Marketing' => new List<String>{'Paper_New_Names__c', 'E_Only_New_Names__c'}
                                                                                                                   
                                                                                                                   };
    public final static Map<String, List<String>> MAP_Pre_Names_WITH_RELATED_FIELDS = new Map<String, List<String>>{'PRE Names' => new List<String>{'Paper_PRE_Names__c', 'E_Only_PRE_Names__c'},
                                                                                                                   'Pre Names – Search' => new List<String>{'Paper_PRE_Names__c', 'E_Only_PRE_Names__c'},
                                                                                                                   'Pre Names – Custom App Marketing' => new List<String>{'Paper_PRE_Names__c', 'E_Only_PRE_Names__c'},
                                                                                                                   'Pre Names – Common/Other Application Marketing' => new List<String>{'Paper_PRE_Names__c', 'E_Only_PRE_Names__c'}
                                                                                                                   };
    //06-Nov-2019 - End
    // end subhash - 08/04/2020 
    
    // modified by Subhash Garhwal - 08/04/2020 start here                                                                                                                   
    //Map to hold the Paper & E-only fields for all Products
    public final static Map<String, Set<String>> MAP_PRODUCT_NAME_TO_ADJUSTABLE_QUANTITY_FIELDS = 
        new Map<String, Set<String>>{
            'New Names' => new Set<String>{'E_Only_New_Names_CSV__c', 'Paper_New_Names_CSV__c'},
            'New Names – Search' => new Set<String>{'E_Only_New_Names_CSV__c', 'Paper_New_Names_CSV__c'},
            'New Names – Custom App Marketing' => new Set<String>{'E_Only_New_Names_CSV__c', 'Paper_New_Names_CSV__c'},
            'New Names – Common/Other Application Marketing' => new Set<String>{'E_Only_New_Names_CSV__c', 'Paper_New_Names_CSV__c'},
            'PRE Names' => new Set<String>{'E_Only_PRE_Names_CSV__c', 'Paper_PRE_Names_CSV__c'},
            'Pre Names – Search' => new Set<String>{'E_Only_PRE_Names_CSV__c', 'Paper_PRE_Names_CSV__c'},
            'Pre Names – Custom App Marketing' => new Set<String>{'E_Only_PRE_Names_CSV__c', 'Paper_PRE_Names_CSV__c'},
            'Pre Names – Common/Other Application Marketing' => new Set<String>{'E_Only_PRE_Names_CSV__c', 'Paper_PRE_Names_CSV__c'},
            'Inquiry Pool'=>new Set<String>{'Paper_Inquiry_Pool_CSV__c', 'E_Only_Inquiry_Pool_CSV__c',
            'Paper_Client_Provided_Inquiries_CSV__c','E_Only_Client_Provided_Inquiries_CSV__c',
            'Paper_EAB_Generated_Inquiries_CSV__c', 'E_Only_EAB_Generated_Inquiries_CSV__c'},
            'Inquiry Pool – Search'=>new Set<String>{'Paper_Inquiry_Pool_CSV__c', 'E_Only_Inquiry_Pool_CSV__c',
            'Paper_Client_Provided_Inquiries_CSV__c','E_Only_Client_Provided_Inquiries_CSV__c',
            'Paper_EAB_Generated_Inquiries_CSV__c', 'E_Only_EAB_Generated_Inquiries_CSV__c'},
            'Inquiry Pool – Custom App Marketing'=>new Set<String>{'Paper_Inquiry_Pool_CSV__c', 'E_Only_Inquiry_Pool_CSV__c',
            'Paper_Client_Provided_Inquiries_CSV__c','E_Only_Client_Provided_Inquiries_CSV__c',
            'Paper_EAB_Generated_Inquiries_CSV__c', 'E_Only_EAB_Generated_Inquiries_CSV__c'},
            'Inquiry Pool – Common/Other Application Marketing'=>new Set<String>{'Paper_Inquiry_Pool_CSV__c', 'E_Only_Inquiry_Pool_CSV__c',
            'Paper_Client_Provided_Inquiries_CSV__c','E_Only_Client_Provided_Inquiries_CSV__c',
            'Paper_EAB_Generated_Inquiries_CSV__c', 'E_Only_EAB_Generated_Inquiries_CSV__c'},
            'Transfer Application Marketing'=>new Set<String>{'Paper_Transfer_Marketing_CSV__c', 'E_only_Transfer_Marketing_CSV__c'},
            'Transfer Custom Application Marketing'=>new Set<String>{'Paper_Transfer_Marketing_CSV__c', 'E_only_Transfer_Marketing_CSV__c'},
            'Transfer Recruitment'=>new Set<String>{'Paper_Transfer_Marketing_CSV__c', 'E_only_Transfer_Marketing_CSV__c'},
            'Sophomore/ Junior Fulfillment'=>new Set<String>{'Paper_Quantity_Fulfillment_CSV__c','E_Only_Quantity_Fulfillment_CSV__c'},
            'Student Journey - Architecture' =>new Set<String>{'Student_Journey_Quantity_Arch_CSV__c'},
            'Student Journey - Business' =>new Set<String>{'Student_Journey_Quantity_Bus_CSV__c'},
            'Student Journey - Continuing Online Education' =>new Set<String>{'Student_Journey_Quantity_COE_CSV__c'},
            'Student Journey - Degree Completion' =>new Set<String>{'Student_Journey_Quantity_DC_CSV__c'},
            'Student Journey - Education' =>new Set<String>{'Student_Journey_Quantity_Edu_CSV__c'},
            'Student Journey - Engineering' =>new Set<String>{'Student_Journey_Quantity_Eng_CSV__c'},
            'Student Journey - Grad Wide' =>new Set<String>{'Student_Journey_Quantity_GW_CSV__c'},
            'Student Journey - Health Sciences' =>new Set<String>{'Student_Journey_Quantity_CSV__c'},
            'Student Journey - Law' =>new Set<String>{'Student_Journey_Quantity_Law_CSV__c'},
            'Student Journey - Nursing' =>new Set<String>{'Student_Journey_Quantity_Nur_CSV__c'},
            'Student Journey - Pharmacy' =>new Set<String>{'Student_Journey_Quantity_Pha_CSV__c'},
            'High Affinity Audience' =>new Set<String>{'High_Affinity_Audience_Quantity_CSV__c'},
            'Deposit IQ' =>new Set<String>{'Deposit_IQ_Quantity_CSV__c'},
            'Yield IQ' =>new Set<String>{'Yield_IQ_Quantity_CSV__c'},
            'Cappex Inquiry Subscription' =>new Set<String>{'Guaranteed_Inquiries_CSV__c'},
            'Cappex Candidate Names Subscription' =>new Set<String>{'Candidate_Names_CSV__c'}
        };
    //  end here
    /*
        2 => new Set<String>{'Paper_EAB_Generated_Inquiries__c', 'E_Only_EAB_Generated_Inquiries__c'}, is commented because its realted configration 
        attribute has been removed.
        Modified by Subhash Garhwal - 09/24/2019 - CR-20190911-1332
    */
            
    // modified by Subhash Garhwal - 08/04/2020 start here
    //Map to hold the Sub Product with the fields those need to compare
    public final static Map<String, Map<Integer, Set<String>>> MAP_SUB_PRODUCT_WITH_PAPER_AND_E_ONLY_COMPARISION_FIELDS = new Map<String,Map<Integer, Set<String>>>{
                                                                                        'Inquiry Pool' => new Map<Integer, Set<String>> {
                                                                                                                              1 => new Set<String>{'Paper_Inquiry_Pool__c', 'E_Only_Inquiry_Pool__c'},
                                                                                                                              /*2 => new Set<String>{'Paper_EAB_Generated_Inquiries__c', 'E_Only_EAB_Generated_Inquiries__c'},*/
                                                                                                                              3 => new Set<String>{'Paper_Client_Provided_Inquiries__c', 'E_Only_Client_Provided_Inquiries__c'}
                                                                                        },
                                                                                        'Inquiry Pool – Search' => new Map<Integer, Set<String>> {
                                                                                                                              1 => new Set<String>{'Paper_Inquiry_Pool__c', 'E_Only_Inquiry_Pool__c'},
                                                                                                                              3 => new Set<String>{'Paper_Client_Provided_Inquiries__c', 'E_Only_Client_Provided_Inquiries__c'}
                                                                                        },
                                                                                        'Inquiry Pool – Custom App Marketing' => new Map<Integer, Set<String>> {
                                                                                                                              1 => new Set<String>{'Paper_Inquiry_Pool__c', 'E_Only_Inquiry_Pool__c'},
                                                                                                                              3 => new Set<String>{'Paper_Client_Provided_Inquiries__c', 'E_Only_Client_Provided_Inquiries__c'}
                                                                                        },
                                                                                        'Inquiry Pool – Common/Other Application Marketing' => new Map<Integer, Set<String>> {
                                                                                                                              1 => new Set<String>{'Paper_Inquiry_Pool__c', 'E_Only_Inquiry_Pool__c'},
                                                                                                                              3 => new Set<String>{'Paper_Client_Provided_Inquiries__c', 'E_Only_Client_Provided_Inquiries__c'}
                                                                                        },
                                                                                        
                                                                                        'New Names' => new Map<Integer, Set<String>> {
                                                                                                                              1 => new Set<String>{'Paper_New_Names__c', 'E_Only_New_Names__c'}
                                                                                        },
                                                                                        'New Names – Search' => new Map<Integer, Set<String>> {
                                                                                                                              1 => new Set<String>{'Paper_New_Names__c', 'E_Only_New_Names__c'}
                                                                                        },
                                                                                        'New Names – Custom App Marketing' => new Map<Integer, Set<String>> {
                                                                                                                              1 => new Set<String>{'Paper_New_Names__c', 'E_Only_New_Names__c'}
                                                                                        },
                                                                                        'New Names – Common/Other Application Marketing' => new Map<Integer, Set<String>> {
                                                                                                                              1 => new Set<String>{'Paper_New_Names__c', 'E_Only_New_Names__c'}
                                                                                        },
                                                                                        'PRE Names' => new Map<Integer, Set<String>> {
                                                                                                                              1 => new Set<String>{'Paper_PRE_Names__c', 'E_Only_PRE_Names__c'}
                                                                                        },
                                                                                        'Pre Names – Search' => new Map<Integer, Set<String>> {
                                                                                                                              1 => new Set<String>{'Paper_PRE_Names__c', 'E_Only_PRE_Names__c'}
                                                                                        },
                                                                                        'Pre Names – Custom App Marketing' => new Map<Integer, Set<String>> {
                                                                                                                              1 => new Set<String>{'Paper_PRE_Names__c', 'E_Only_PRE_Names__c'}
                                                                                        },
                                                                                        'Pre Names – Common/Other Application Marketing' => new Map<Integer, Set<String>> {
                                                                                                                              1 => new Set<String>{'Paper_PRE_Names__c', 'E_Only_PRE_Names__c'}
                                                                                        },
                                                                                        'Transfer Application Marketing' => new Map<Integer, Set<String>> {
                                                                                                                              1 => new Set<String>{'Paper_Transfer_Marketing__c', 'E_Only_Transfer_Marketing__c'}
                                                                                        },
                                                                                        'Transfer Custom Application Marketing' => new Map<Integer, Set<String>> {
                                                                                                                              1 => new Set<String>{'Paper_Transfer_Marketing__c', 'E_Only_Transfer_Marketing__c'}
                                                                                        },
                                                                                        'Sophomore/ Junior Fulfillment' => new Map<Integer, Set<String>> {
                                                                                                                              1 => new Set<String>{'Paper_Quantity_Fulfillment__c', 'E_Only_Quantity_Fulfillment__c'}
                                                                                        }
                                                                                    };
    
        // end here 
    
    // modified by subhash Garhwal - 08/04/2020                                                                                    
    //Map to hold the Sub Product Decimal fields with Sub Product Name
    public final static Map<String, Set<Integer>> MAP_SUB_PRODUCT_WITH_INDEX_OF_FIELD_TO_EXECLUDE_ZERO_VALIDATION = new Map<String, Set<Integer>>{
                                                                                                    'Inquiry Pool' => new Set<Integer>{2,3},
                                                                                                    'Inquiry Pool – Search' => new Set<Integer>{2,3},
                                                                                                    'Inquiry Pool – Custom App Marketing' => new Set<Integer>{2,3},
                                                                                                    'Inquiry Pool – Common/Other Application Marketing' => new Set<Integer>{2,3}
                                                                                                };
    
    // modified by Subhash Garhwal - 08/04/2020                                                                                               
    //Map to hold the Paper and E-only Field validation 
    public final static Map<String, Map<String, Set<String>>> MAP_PAPER_AND_EONLY_VALIDATION = new Map<String,Map<String, Set<String>>>{
                                                                                        'Custom Application Marketing' => new Map<String, Set<String>> {
                                                                                                                              'Inquiry Pool' => new Set<String>{'Paper_Inquiry_Pool__c', 'E_Only_Inquiry_Pool__c'},
                                                                                                                              'Inquiry Pool – Custom App Marketing' => new Set<String>{'Paper_Inquiry_Pool__c', 'E_Only_Inquiry_Pool__c'},
                                                                                                                              'New Names' => new Set<String>{'Paper_New_Names__c', 'E_Only_New_Names__c'},
                                                                                                                              'New Names – Custom App Marketing' => new Set<String>{'Paper_New_Names__c', 'E_Only_New_Names__c'},
                                                                                                                              'PRE Names' => new Set<String>{'Paper_PRE_Names__c', 'Paper_PRE_Names__c'},
                                                                                                                              'Pre Names – Custom App Marketing' => new Set<String>{'Paper_PRE_Names__c', 'Paper_PRE_Names__c'}
                                                                                        },
                                                                                        
                                                                                        'Common/Other Application Marketing' => new Map<String, Set<String>> {
                                                                                                                              'Inquiry Pool' => new Set<String>{'Paper_Inquiry_Pool__c', 'E_Only_Inquiry_Pool__c'},
                                                                                                                              'Inquiry Pool – Common/Other Application Marketing' => new Set<String>{'Paper_Inquiry_Pool__c', 'E_Only_Inquiry_Pool__c'},
                                                                                                                              'New Names' => new Set<String>{'Paper_New_Names__c', 'E_Only_New_Names__c'},
                                                                                                                              'New Names – Common/Other Application Marketing' => new Set<String>{'Paper_New_Names__c', 'E_Only_New_Names__c'},
                                                                                                                              'PRE Names' => new Set<String>{'Paper_PRE_Names__c', 'Paper_PRE_Names__c'},
                                                                                                                              'Pre Names – Common/Other Application Marketing' => new Set<String>{'Paper_PRE_Names__c', 'Paper_PRE_Names__c'}
                                                                                        }
                                                                                    };
    
    //Set to hold the ESAM and ESOAM Product codes
    public final static Set<String> SET_ESAM_ESOAM_CODES = new Set<String>{'ESAM', 'ESOAM'};
    
        // modified by Subhash Garhwal - 08/04/2020
    //Map to hold the Paper and E-only Field names with related products
    public final static Map<String, Set<String>> MAP_PAPER_AND_EONLY_FIELDS_WITH_SUBPRODUCT = new Map<String, Set<String>>{
                                                                                        'Inquiry Pool' => new Set<String>{'Paper_Inquiry_Pool__c', 'E_Only_Inquiry_Pool__c'},
                                                                                        'Inquiry Pool – Search' => new Set<String>{'Paper_Inquiry_Pool__c', 'E_Only_Inquiry_Pool__c'},
                                                                                        'Inquiry Pool – Custom App Marketing' => new Set<String>{'Paper_Inquiry_Pool__c', 'E_Only_Inquiry_Pool__c'},
                                                                                        'Inquiry Pool – Common/Other Application Marketing' => new Set<String>{'Paper_Inquiry_Pool__c', 'E_Only_Inquiry_Pool__c'},
                                                                                        'New Names' => new Set<String>{'Paper_New_Names__c', 'E_Only_New_Names__c'},
                                                                                        'New Names – Search' => new Set<String>{'Paper_New_Names__c', 'E_Only_New_Names__c'},
                                                                                        'New Names – Custom App Marketing' => new Set<String>{'Paper_New_Names__c', 'E_Only_New_Names__c'},
                                                                                        'New Names – Common/Other Application Marketing' => new Set<String>{'Paper_New_Names__c', 'E_Only_New_Names__c'},
                                                                                        'PRE Names' => new Set<String>{'Paper_PRE_Names__c', 'E_Only_PRE_Names__c'},
                                                                                        'Pre Names – Search' => new Set<String>{'Paper_PRE_Names__c', 'E_Only_PRE_Names__c'},
                                                                                        'Pre Names – Custom App Marketing' => new Set<String>{'Paper_PRE_Names__c', 'E_Only_PRE_Names__c'},
                                                                                        'Pre Names – Common/Other Application Marketing' => new Set<String>{'Paper_PRE_Names__c', 'E_Only_PRE_Names__c'}
                                                                                        };
    
    /**Added by Mahendra Swarnkar - CR-20190219-12888 - 07/02/2019 - Starts from here**/
    public final static Set<String> CPQ_SUBSCRIPTION_OPT_IN_TYPES = new Set<String>{'Annual Opt In', 'One Point In Time Opt In'};
    public final static String SUBSCRIPTION_PERIOD_DECISION_TYPE_OPT_IN = 'Opt In';
    /**Added by Mahendra Swarnkar - CR-20190219-12888 - 07/02/2019 - Ends here**/
    
                   
    //Added by Subhash Garhwal - 02/07/2020
    public static final Map<String, Map<String, String>> mapChildParentCodeWithCSVFieldMapping =  new Map<String, Map<String, String>>{
        
        'ESCAS - ESAM' => new Map<String, String> {
            'Estimated_Common_App_Starts__c' => 'Estimated_Common_App_Starts_CSV__c'
        },
        'ESEAMVC - ESAM' => new Map<String, String> {
            'EAM_Visit_Yes_No__c' => 'EAM_Visit_Yes_No_CSV__c'
        },
        'ESIP - ESAM' => new Map<String, String> {
            'Postage_Type_for_IP_Deadline_Marketing__c' => 'Postage_for_IP_Deadline_Marketing_CSV__c', 'Paper_Inquiry_Pool__c' => 'Paper_Inquiry_Pool_CSV__c',
            'Package_Size__c' => 'Package_Size_CSV__c', 'E_Only_Inquiry_Pool__c' => 'E_Only_Inquiry_Pool_CSV__c', 'Digital_Media_Inquiry_Pool__c' => 'Digital_Media_Inquiry_Pool_CSV__c'
        },
        // Modified by Subhash Garhwal - 08/04/2020 start here
        'ESIPESAM - ESAM' => new Map<String, String> {
            'Postage_Type_for_IP_Deadline_Marketing__c' => 'Postage_for_IP_Deadline_Marketing_CSV__c', 'Paper_Inquiry_Pool__c' => 'Paper_Inquiry_Pool_CSV__c',
            'Package_Size__c' => 'Package_Size_CSV__c', 'E_Only_Inquiry_Pool__c' => 'E_Only_Inquiry_Pool_CSV__c', 'Digital_Media_Inquiry_Pool__c' => 'Digital_Media_Inquiry_Pool_CSV__c'
        },
        'ESNNESAM - ESAM' => new Map<String, String> {
            'Postage_for_New_Name_Deadline_Marketing__c' => 'Postage_type_for_New_Name_CSV__c', 'Paper_New_Names__c' => 'Paper_New_Names_CSV__c',
            'E_Only_New_Names__c' => 'E_Only_New_Names_CSV__c', 'Digital_Media_New_Names__c' => 'Digital_Media_New_Names_CSV__c', 'Average_Overlap_New_Names__c' => 'Average_Overlap_New_Names_CSV__c'
        },
        'ESPNESAM - ESAM' => new Map<String, String> {
            'Postage_for_Pre_Name_Deadline_Marketing__c' => 'Postage_type_for_PRE_Names_CSV__c', 'Paper_PRE_Names__c' => 'Paper_PRE_Names_CSV__c', 
            'E_Only_PRE_Names__c' => 'E_Only_PRE_Names_CSV__c', 'Digital_Media_PRE_Names__c' => 'Digital_Media_PRE_Names_CSV__c'
        },
        // end here    
        'ESNN - ESAM' => new Map<String, String> {
            'Postage_for_New_Name_Deadline_Marketing__c' => 'Postage_type_for_New_Name_CSV__c', 'Paper_New_Names__c' => 'Paper_New_Names_CSV__c',
            'E_Only_New_Names__c' => 'E_Only_New_Names_CSV__c', 'Digital_Media_New_Names__c' => 'Digital_Media_New_Names_CSV__c', 'Average_Overlap_New_Names__c' => 'Average_Overlap_New_Names_CSV__c'
        },
        'ESPN - ESAM' => new Map<String, String> {
            'Postage_for_Pre_Name_Deadline_Marketing__c' => 'Postage_type_for_PRE_Names_CSV__c', 'Paper_PRE_Names__c' => 'Paper_PRE_Names_CSV__c', 
            'E_Only_PRE_Names__c' => 'E_Only_PRE_Names_CSV__c', 'Digital_Media_PRE_Names__c' => 'Digital_Media_PRE_Names_CSV__c'
        },    
        'ESWAP - ESAM' => new Map<String, String> {
            'Web_Application_Versions_Transfer__c' => 'Web_Application_Versions_Transfer_CSV__c', 'Web_Application_Versions_Other__c' => 'Web_Application_Versions_Other_CSV__c', 
            'Web_Application_Versions_International__c' => 'Web_App_Versions_International_CSV__c', 'Web_Application_Versions_Freshman__c' => 'Web_Application_Versions_Freshman_CSV__c'
        },    
        'ESIWC - ESIWCM' => new Map<String, String> {
            'Number_of_Destinations__c' => 'Number_of_Destinations_CSV__c'
        },    
        'ESCAS - ESOAM' => new Map<String, String> {
            'Estimated_Common_App_Starts__c' => 'Estimated_Common_App_Starts_CSV__c'
        },    
        'ESEAMVC - ESOAM' => new Map<String, String> {
            'EAM_Visit_Yes_No__c' => 'EAM_Visit_Yes_No_CSV__c'
        },
        'ESIP - ESOAM' => new Map<String, String> {
            'Postage_Type_for_IP_Deadline_Marketing__c' => 'Postage_for_IP_Deadline_Marketing_CSV__c', 'Paper_Inquiry_Pool__c' => 'Paper_Inquiry_Pool_CSV__c',
            'E_Only_Inquiry_Pool__c' => 'E_Only_Inquiry_Pool_CSV__c', 'Digital_Media_Inquiry_Pool__c' => 'Digital_Media_Inquiry_Pool_CSV__c'
        },
        // Modified by Subhash Garhwal - 08/04/2020 start here
        'ESIPESOAM - ESOAM' => new Map<String, String> {
            'Postage_Type_for_IP_Deadline_Marketing__c' => 'Postage_for_IP_Deadline_Marketing_CSV__c', 'Paper_Inquiry_Pool__c' => 'Paper_Inquiry_Pool_CSV__c',
            'E_Only_Inquiry_Pool__c' => 'E_Only_Inquiry_Pool_CSV__c', 'Digital_Media_Inquiry_Pool__c' => 'Digital_Media_Inquiry_Pool_CSV__c'
        },
        'ESNNESOAM - ESOAM' => new Map<String, String> {
            'Postage_for_New_Name_Deadline_Marketing__c' => 'Postage_type_for_New_Name_CSV__c', 'Paper_New_Names__c' => 'Paper_New_Names_CSV__c', 
            'E_Only_New_Names__c' => 'E_Only_New_Names_CSV__c', 'Digital_Media_New_Names__c' => 'Digital_Media_New_Names_CSV__c', 'Average_Overlap_New_Names__c' => 'Average_Overlap_New_Names_CSV__c'
        },
        'ESPNESOAM - ESOAM' => new Map<String, String> {
            'Postage_for_Pre_Name_Deadline_Marketing__c' => 'Postage_type_for_PRE_Names_CSV__c', 'Paper_PRE_Names__c' => 'Paper_PRE_Names_CSV__c', 
            'E_Only_PRE_Names__c' => 'E_Only_PRE_Names_CSV__c', 'Digital_Media_PRE_Names__c' => 'Digital_Media_PRE_Names_CSV__c'
        },
        // end here
        'ESNN - ESOAM' => new Map<String, String> {
            'Postage_for_New_Name_Deadline_Marketing__c' => 'Postage_type_for_New_Name_CSV__c', 'Paper_New_Names__c' => 'Paper_New_Names_CSV__c', 
            'E_Only_New_Names__c' => 'E_Only_New_Names_CSV__c', 'Digital_Media_New_Names__c' => 'Digital_Media_New_Names_CSV__c', 'Average_Overlap_New_Names__c' => 'Average_Overlap_New_Names_CSV__c'
        },    
        'ESPN - ESOAM' => new Map<String, String> {
            'Postage_for_Pre_Name_Deadline_Marketing__c' => 'Postage_type_for_PRE_Names_CSV__c', 'Paper_PRE_Names__c' => 'Paper_PRE_Names_CSV__c', 
            'E_Only_PRE_Names__c' => 'E_Only_PRE_Names_CSV__c', 'Digital_Media_PRE_Names__c' => 'Digital_Media_PRE_Names_CSV__c'
        },    
        'ESPA - ESPAA' => new Map<String, String> {
            'Pipeline_analytics_Yes_No__c' => 'Pipeline_Analytics_Yes_No_CSV__c'
        },    
        'ESSEO - ESSEOM' => new Map<String, String> {
            'SEO_Audit__c' => 'SEO_Audit_CSV__c'
        },
        'ESSUM - ESSUMM' => new Map<String, String> {
            'PostageType_SpecialUrgentMailing__c' => 'PostageType_SpecialUrgentMailng_CSV__c', 'Paper_Special_Urgent_Mailing__c' => 'Paper_Special_Urgent_Mailing_CSV__c'
        },    
        'ESCXFR - ESXFRR' => new Map<String, String> {
            'Participate_in_Undergrad_also__c' => 'Participate_in_Undergrad_also_CSV__c', 'Paper_Transfer_Marketing__c' => 'Paper_Transfer_Marketing_CSV__c', 
            'Number_of_PTK_Names__c' => 'Number_of_PTK_Names_CSV__c', 'E_only_Transfer_Marketing__c' => 'E_only_Transfer_Marketing_CSV__c', 
            'Digital_Media_Transfer_Marketing__c' => 'Digital_Media_Transfer_Marketing_CSV__c'
        },    
        'ESTDIQ - ESXFRR' => new Map<String, String> {
            'Include_Transfer_Deposit_IQ__c' => 'Include_Transfer_Deposit_IQ_CSV__c'
        },    
        'ESTP - ESXFRR' => new Map<String, String> {
            'of_Transfers_Quantity__c' => 'of_Transfers_Quantity_CSV__c'
        },    
        'ESXFR - ESXFRR' => new Map<String, String> {
            'Participate_in_Undergrad_also__c' => 'Participate_in_Undergrad_also_CSV__c', 'Paper_Transfer_Marketing__c' => 'Paper_Transfer_Marketing_CSV__c', 
            'Number_of_PTK_Names__c' => 'Number_of_PTK_Names_CSV__c', 'E_only_Transfer_Marketing__c' => 'E_only_Transfer_Marketing_CSV__c', 
            'Digital_Media_Transfer_Marketing__c' => 'Digital_Media_Transfer_Marketing_CSV__c' 
        },    
        'ESDIQ - ESYO' => new Map<String, String> {
            'Include_Digital_Media__c' => 'Include_Digital_Media_CSV__c', 'Include_a_Regional_Public_Yield_Bundle__c' => 'Include_a_Regnl_Public_Yield_Bundle_CSV__c', 
            'Deposit_IQ_Quantity__c' => 'Deposit_IQ_Quantity_CSV__c'
        },    
        'ESFAD - ESYO' => new Map<String, String> {
            'Include_Descriptive_without_Monitoring__c' => 'Incl_Descriptive_w_o_Monitoring_CSV__c', 'Include_Descriptive_Monitoring__c' => 'Include_Descriptive_Monitoring_CSV__c'    
        },    
        'ESFAO - ESYO' => new Map<String, String> {
            'Multiple_colleges_or_large_Institution__c' => 'Multiple_colleges_or_large_Inst_CSV__c', 'Is_This_A_Standalone_FAO_Client__c' => 'Is_This_A_Standalone_FAO_Client_CSV__c', 
            'Include_Financial_Aid_Optimization__c' => 'Include_Financial_Aid_Optimization_CSV__c'
        },
        'ESFBM - ESYO' => new Map<String, String> {
            'Include_Full_Budget_Model__c' => 'Include_Full_Budget_Model_CSV__c'
        },
        'ESFYT - ESYO' => new Map<String, String> {
            'Include_Four_Year_Tuition__c' => 'Include_Four_Year_Tuition_CSV__c'
        },    
        'ESIQS - ESYO' => new Map<String, String> {
            'Include_Inquiry_Scoring__c' => 'Include_Inquiry_Scoring_CSV__c'
        },    
        'ESNPC - ESYO' => new Map<String, String> {
            'Include_Net_Price_Calculator__c' => 'Include_Net_Price_Calculator_CSV__c'
        },    
        'ESQPY - ESYO' => new Map<String, String> {
            'Propose_Quick_Pay__c' => 'Propose_Quick_Pay_CSV__c'
        },    
        'ESRTA - ESYO' => new Map<String, String> {
            'Include_Retention_Analysis__c' => 'Include_Retention_Analysis_CSV__c'
        },    
        'ESTFAO - ESYO' => new Map<String, String> {
            'Multiple_colleges_large_Inst_Transfer__c' => 'TF_Multiple_colleges_or_large_Inst_CSV__c', 'Include_Transfer_FAO__c' => 'Include_Transfer_FAO_CSV__c'
        },    
        'ESUDM - ESYO' => new Map<String, String> {
            'Urgent_DepositIQ_Quantity__c' => 'Urgent_DepositIQ_Quantity_CSV__c'
        }, 
        /*CR-20210325-15031 - 03/31/2021 - Replaced the attribute mapping "Include_Digital_Media__c" with "Include_Digital_Media_Yield_IQ__c"*/
        'ESYIQ - ESYO' => new Map<String, String> {
            'Yield_IQ_Quantity__c' => 'Yield_IQ_Quantity_CSV__c', 'Include_Digital_Media_Yield_IQ__c' => 'Include_Digital_Media_Yield_IQ_CSV__c'
        },    
        'ESFUL - ESYRS' => new Map<String, String> {
            'Paper_Quantity_Fulfillment__c' => 'Paper_Quantity_Fulfillment_CSV__c', 'E_Only_Quantity_Fulfillment__c' => 'E_Only_Quantity_Fulfillment_CSV__c', 
            'Duration_of_Fulfillment_Program__c' => 'Duration_of_Fulfillment_Program_CSV__c', 'Did_Prior_Yr_Fulflmnt_have_anyPaper__c' => 'Did_Prior_Yr_Fulflmnt_have_anyPaper_CSV__c'
        },    
        'ESIOFFR - ESYRS' => new Map<String, String> {
            'Proposing_an_Interactive_Offer__c' => 'Proposing_an_Interactive_Offer_CSV__c'
        },    
        'ESIP - ESYRS' => new Map<String, String> {
            'Paper_Client_Provided_Inquiries__c' => 'Paper_Client_Provided_Inquiries_CSV__c', 'E_Only_Client_Provided_Inquiries__c' => 'E_Only_Client_Provided_Inquiries_CSV__c', 
            'Digital_Media_Inquiry_Pool__c' => 'Digital_Media_Inquiry_Pool_CSV__c' 
        },
        // Modified by Subhash Garhwal - 08/04/2020 start here
        'ESIPESYRS - ESYRS' => new Map<String, String> {
            'Paper_Client_Provided_Inquiries__c' => 'Paper_Client_Provided_Inquiries_CSV__c', 'E_Only_Client_Provided_Inquiries__c' => 'E_Only_Client_Provided_Inquiries_CSV__c', 
            'Digital_Media_Inquiry_Pool__c' => 'Digital_Media_Inquiry_Pool_CSV__c' 
        },
        'ESNNESYRS - ESYRS' => new Map<String, String> {
            'Paper_New_Names__c' => 'Paper_New_Names_CSV__c', 'E_Only_New_Names__c' => 'E_Only_New_Names_CSV__c', 
            'Digital_Media_New_Names__c' => 'Digital_Media_New_Names_CSV__c', 'Average_Overlap_New_Names__c' => 'Average_Overlap_New_Names_CSV__c'
        },
        'ESPNESYRS - ESYRS' => new Map<String, String> {
            'Paper_PRE_Names__c' => 'Paper_PRE_Names_CSV__c', 'E_Only_PRE_Names__c' => 'E_Only_PRE_Names_CSV__c', 'Digital_Media_PRE_Names__c' => 'Digital_Media_PRE_Names_CSV__c'
        },
        // end here
        'ESNN - ESYRS' => new Map<String, String> {
            'Paper_New_Names__c' => 'Paper_New_Names_CSV__c', 'E_Only_New_Names__c' => 'E_Only_New_Names_CSV__c', 
            'Digital_Media_New_Names__c' => 'Digital_Media_New_Names_CSV__c', 'Average_Overlap_New_Names__c' => 'Average_Overlap_New_Names_CSV__c'
        },    
        'ESOFFRA - ESYRS' => new Map<String, String> {
            'Quantity_Base_Price_Up_to_5_000_1__c' => 'Quantity_Base_Price_Up_to_5_000_1_CSV__c', 
            'Paper_Offer_or_PDF1__c' => 'Paper_Offer_or_PDF1_CSV__c', 'New_Creative_or_Reprint1__c' => 'New_Creative_or_Reprint1_CSV__c'
        },    
        'ESOFFRB - ESYRS' => new Map<String, String> {
            'Quantity_Base_Price_Up_to_5_000_2__c' => 'Quantity_Base_Price_Up_to_5_000_2_CSV__c', 
            'Paper_Offer_or_PDF2__c' => 'Paper_Offer_or_PDF2_CSV__c', 'New_Creative_or_Reprint2__c' => 'New_Creative_or_Reprint2_CSV__c' 
        },    
        'ESOFFRC - ESYRS' => new Map<String, String> {
            'Quantity_Base_Price_Up_to_5_000_3__c' => 'Quantity_Base_Price_Up_to_5_000_3_CSV__c', 
            'Paper_Offer_or_PDF3__c' => 'Paper_Offer_or_PDF3_CSV__c', 'New_Creative_or_Reprint3__c' => 'New_Creative_or_Reprint3_CSV__c' 
        },   
        'ESPN - ESYRS' => new Map<String, String> {
            'Paper_PRE_Names__c' => 'Paper_PRE_Names_CSV__c', 'E_Only_PRE_Names__c' => 'E_Only_PRE_Names_CSV__c', 'Digital_Media_PRE_Names__c' => 'Digital_Media_PRE_Names_CSV__c'
        },    
        'ESPRF - ESYRS' => new Map<String, String> {
            'Parent_First__c' => 'Parent_First_CSV__c'
        },    
        'YOUVLIWC - YOUVL' => new Map<String, String> {
            'Number_of_Destinations__c' => 'Number_of_Destinations_CSV__c'
        },    
        'YOUV - YOUVM' => new Map<String, String> {
            'You_Visit_Package_Type__c' => 'You_Visit_Package_Type_CSV__c'
        },    
        'YOUVADLDES - YOUVM' => new Map<String, String> {
            'How_Many_Additional_Destinations__c' => 'How_Many_Additional_Destinations_CSV__c'
        },    
        'YOUVAUDIO - YOUVM' => new Map<String, String> {
            'How_Many_Additional_Language_Versions__c' => 'How_Many_Additional_Language_Version_CSV__c'
        },    
        'YOUVSS - YOUVM' => new Map<String, String> {
            'One_Time_Refresh_Studio_Services__c' => 'One_Time_Refresh_Studio_Services_CSV__c'
        },    
        'YOUVLIWC - YOUVUGL' => new Map<String, String> {
            'Number_of_Destinations__c' => 'Number_of_Destinations_CSV__c'
        },    
        'YOUV - YOUVUG' => new Map<String, String> {
            'You_Visit_Package_Type__c' => 'You_Visit_Package_Type_CSV__c'
        },     
        'YOUVADLDES - YOUVUG' => new Map<String, String> {
            'How_Many_Additional_Destinations__c' => 'How_Many_Additional_Destinations_CSV__c'
        },
        'YOUVAUDIO - YOUVUG' => new Map<String, String> {
            'How_Many_Additional_Language_Versions__c' => 'How_Many_Additional_Language_Version_CSV__c'
        },    
        'YOUVSS - YOUVUG' => new Map<String, String> {
            'One_Time_Refresh_Studio_Services__c' => 'One_Time_Refresh_Studio_Services_CSV__c'
        }
    };
    
    //Subhash Garhwal - 8/31/2020 - CR-20200825-14471 - New Constant Properties added   
    public final static Set<String> SET_ESYRS_SUB_PRODUCTS = new Set<String>{'Inquiry Pool – Search', 'New Names – Search', 'Pre Names – Search'};
    
    
    //Subhash Garhwal - 05/26/2021 - CR-20210521-15172 - Added Deal Summary bypass Products
    public final static Set<String> SET_PRODUCT_CATEGORY_TO_SKIP_FOR_DEAL_SUMMARY = new Set<String>{'Opt Out'};
    
    //Subhash Garhwal - 7/30/2021 - CR-20210726-15311 - Set to hold the FAO ES Products
    public final static Set<String> SET_ES_FAO_PRODUCT_CODES = new Set<String>{'ESFAO', 'ESFAD', 'ESFBM', 'ESFYT', 'ESIQS', 'ESRTA', 'ESTFAO'};

}