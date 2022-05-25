/**
 *  Desription      :   Standard Controller for Account Detail Page 
 * 
 *  Created By      :   Bhavi Sharma
 * 
 *  Created Date    :   08/16/2015
 * 
 *  Revision Logs   :   V1.0 - Created
 *                      V2.0 - 12/04/2015- VH - CR-41449 - Added licenseType
 *                      V3.0 - Modified - Mahendra swarnkar - 9/3/2016 - CR-20160126-9564.
 *                      V3.1 - Modified by - Subhash Garhwal - 02/04/2017 - CR-20151015-9324
 * 			V3.2 - Modified by - Rajeev jain - 08/24/2018 - CR-20180622-12296 - Replace PSS Incentive Credit with the SME Incentive Credit
 *                      V3.3 - Modifed By Dipesh Gupta - CR-20190726-13240 - 08/06/2019 - Remove the reference of Temporary_Program_Access__c
 * 			V3.4 - Modified by Dipesh Gupta CR-20190522-13123 10/03/2019  -Remove the reference of 'Syndicated_Research_Interaction__c'.	 
 *                      V3.5 - Modified By - Neha Sharma - 05/20/2021 - CR-20190620-13192 - Integrating subscription data from Marketo to Salesforce - old object removal
 *                      V3.6 - Modified By - Nikita Kumari - 08/03/2022 - CR-20220217-15921 - Boardroom Sunsetting Changes
 **/ 
public without sharing class GoogleAnalyticsController {
    public string url { get; set; }
    public string activityType { get; set; }
    public string recordId { get; set; }
    public string objAPIName { get; set; }
    public string objName { get; set; }
    public string recordTypeName { get; set; }
    public string dashboardTitle { get; set; }
    public string errorMsg { get; set; }
    
    /**
     * 
     * @description: get the user information that will be sent to google analytics
     * 
     **/
    public User usr {
        get {
            if (usr == null) {
                usr = [SELECT Id, Username, Department, UserType, Profile.Name FROM User WHERE Id = :userInfo.getUserId()];
            }
            return usr;
        }
        set;
    }
    
    /**
    * 
    * @description: return the type of license related to the user's profile
    * 
    **/
    public string licenseType {
        get {
            if (licenseType == null) {
                licenseType = [SELECT Id, UserLicense.Name FROM Profile WHERE Id = :userInfo.getProfileId()].UserLicense.Name;
            }
            return licenseType;
        }
        set;
    }
    
    /**
     * 
     * @description: constructor.
     * 
     **/
    public GoogleAnalyticsController() {}
    
    /**
     * 
     * @description: get analytics data and set variables that will be sent to google analytics.
     * 
    **/
    public void getAnalyticsData() {
        try {
            getIdAndType();
            
            if (recordId != null && recordId.length() >= 3) {
                objName = prefixToObjectMap.get(recordId.substring(0, 3));
                objAPIName = prefixToAPINameMap.get(recordId.substring(0, 3));
                
                if (recordId InstanceOf ID) {
                    
                    //get the record type developer name
                    string objQry = 'SELECT Id, RecordTypeId';
                    if (objAPIName == 'Dashboard') objQry = 'SELECT Id, Title';
                    objQry += ' FROM ' + objAPIName + ' WHERE Id = :recordId';
                    string rtId, rtName;
                    list<SObject> sobjs = database.query(objQry);
                    if (sobjs.size() > 0) {
                        if (objAPIName == 'Dashboard') {
                            dashboardTitle = (string)sobjs[0].get('Title');
                        }
                        else {
                            rtId = (string)sobjs[0].get('RecordTypeId');
                            string rtQry = 'SELECT Id, DeveloperName FROM RecordType WHERE Id = :rtId';
                            list<SObject> rts = database.query(rtQry);
                            if (rts.size() > 0) recordTypeName = (string)rts[0].get('DeveloperName');
                        }
                    }
                }
            }
        }
        catch(Exception e) {
            errorMsg = e.getMessage() + '  Stack Trace:' + e.getStackTraceString();
            system.debug('@@@error:' + e.getMessage() + '  ' + e.getStackTraceString());
        }
    }
    
    /**
     * 
     * @description: get the Id and RecordType based on the URL.
     * 
     **/
    public void getIdAndType() {
        // most record urls are in one of these formats: /701L0000000GOT7, /701L0000000GOT7/e, /apex/....?id=0000000000
        if (url != null) {
            url = url.split('(?i)[?&]returl')[0]; //get everything to the left of the ?returl or &returl
            list<string> tempUrls = url.split('/');
            list<string> urls = new list<string>();
            boolean isVFPage = url.contains('/apex/');
            
            for (string uVal : tempUrls) {
                urls.addAll(uVal.split('\\?'));
            }
            
            string finalURLVal = urls[urls.size()-1];
            
            for (integer i = 0; i < urls.size(); i++) {
                string uVal = urls[i];
                //if the url value contains =, split it and get the value... it's likely a record id
                if (uVal.contains('=')) {
                    uVal = uVal.split('=')[1];
                    if (uVal.contains('&')) uVal = uVal.split('&')[0];
                }
                
                if (uVal != null && (uVal instanceOf ID || uVal.length() == 3)) {
                    if (!prefixToObjectMap.containsKey(uVal.substring(0, 3))
                       || !prefixToAPINameMap.containsKey(uVal.substring(0, 3))) {
                        populatePrefixMaps(uVal.substring(0, 3));
                    }
                }
                
                if (uVal InstanceOf ID) {
                    
                    //set the record id variable
                    recordId = uVal;
                    //see if this is a VF Page, view, or edit
                    if (isVFPage) {
                        activityType = 'VF'; //ie: /apex/...?id=...
                        if (url.containsIgnoreCase('DashboardViewer')) {
                            activityType = 'DashboardViewer';
                            string dashId = url.substring(url.indexOf('id=')+3, url.indexOf('id=')+18);
                            if (dashId instanceOf Id) {
                                dashboardTitle = [SELECT Id, Title FROM Dashboard WHERE Id = :dashId].Title;
                            }
                        }
                    }
                    else if (finalURLVal != null && (finalURLVal.equalsIgnoreCase('e') || finalURLVal == 'clone=1')) {
                        activityType = 'Edit'; //ie: /003L000000IPx6s/e  OR  /003L000000IPx6s/e?clone=1
                    }
                    else {
                        activityType = 'View'; //ie: /003L000000IPx6s
                    }
                }
                else if (uVal.length() == 3 && prefixToObjectMap.containsKey(uVal)) { //get the object name if it's an object view (ie: 3-char obj id)
                    recordId = uVal;
                    if (urls.size() > i) finalURLVal = urls[i+1];
                    //see if this is a list view or new
                    if (finalURLVal.length() == 1) {
                        if (finalURLVal.equalsIgnoreCase('e')) activityType = 'Edit'; //ie: /003/e  technically this is 'new', but for our purposes, I think we only care about edit vs view
                        if (finalURLVal.equalsIgnoreCase('o')) activityType = 'Tab'; //ie: /003/o
                    }
                    else {
                        activityType = 'List View'; //ie: /003
                        //V3.1 - Added by - Subhash Garhwal - 02/04/2017 - CR-20151015-9324
                        break;
                    }
                }
            }
        }
    }
                        
    /**
     * 
     * @description: if the prefix doesn't exist, get it from the global describe.  
     * This is an expensive call, which is why we try to pre-populate as many existing objects in the map initially.
     * 
     **/
    public void populatePrefixMaps(string prefix) {
        for(Schema.SObjectType t : Schema.getGlobalDescribe().values() ) {
            Schema.DescribeSObjectResult descr = t.getDescribe();
            // If the Id starts with this objects prefix, then we know the type
            if( descr.getKeyPrefix() != null && descr.getKeyPrefix() == prefix){
                prefixToAPINameMap.put(descr.getKeyPrefix(), descr.getName());
                prefixToObjectMap.put(descr.getKeyPrefix(), descr.getLabel());
                break;
            }
        }
    }
    
    /**
     * 
     * @description: map of all SObject prefixes -> sObject label  (as of 8/13/15)
     * 
     **/
    //Modified By Rajeev jain - 08/24/2018 - CR-20180622-12296 - Replace PSS Incentive Credit with the SME Incentive Credit
    //Modified - Mahendra swarnkar - 9/3/2016 - CR-20160126-9564 - Modified object label "Event Venue" to "Venues and Vendors" 
    // Modified by Dipesh Gupta CR-20190522-13123 10/03/2019  -Remove the reference of 'Syndicated_Research_Interaction__c'.
    public map<string, string> prefixToObjectMap {
        get {
            if (prefixToObjectMap == null) {
                prefixToObjectMap = new map<string, string> {
                    '01J' => 'Opportunity Stage','012' => 'Record Type','019' => 'Business Process','800' => 'Standard Contract','806' => 'Approval','02a' => 'Standard Contract Contact Role','00D' => 'Organization','01H' => 'Mail Merge Template','01N' => 'Custom S-Control','02s' => 'Email Message','015' => 'Document','00l' => 'Folder','00b' => 'Custom Button or Link','00X' => 'Email Template',
                        '05X' => 'Document Entity Map','016' => 'Letterhead','0Ya' => 'Login History','710' => 'Login IP','713' => 'Client Browser','083' => 'Vote','09a' => 'Zone','0t0' => 'Tag Definition','701' => 'Campaign','08s' => 'Campaign Share','01Y' => 'Campaign Member Status','00v' => 'Campaign Member','001' => 'Institution',
                        '00r' => 'Account Share','003' => 'Contact','03s' => 'Contact Share','00Q' => 'Contact to Vet','01o' => 'Lead Share','006' => 'Opportunity','00t' => 'Opportunity Share','00K' => 'Opportunity Contact Role','008' => 'Opportunity History','00k' => 'Opportunity Product','00o' => 'Line Item Schedule','00J' => 'Opportunity: Competitor','00p' => 'User Team Member',
                        '01D' => 'User Account Team Member','00q' => 'Opportunity Team Member','01M' => 'Institution Team Member','00I' => 'Related Account','608' => 'Forecast Share','002' => 'Note','00P' => 'Attachment','022' => 'Fiscal Year Settings','026' => 'Period','01u' => 'Price Book Entry','01t' => 'Product','02i' => 'Asset','01m' => 'Business Hours',
                        '500' => 'Case','01n' => 'Case Share','00a' => 'Case Comment','03j' => 'Case Contact Role','010' => 'Case Solution','501' => 'Solution','0C0' => 'Holiday','04m' => 'Additional Directory Number','04v' => 'Call Center','068' => 'Content Version','069' => 'Content Document','06A' => 'Content Document Link','058' => 'Library',
                        '059' => 'Library Document','05D' => 'Content Delivery','05H' => 'Content Delivery View','07v' => 'Content Folder Link','07I' => 'Content Folder Member','08a' => 'Cron Job','08e' => 'Scheduled Jobs','0D5' => 'Feed Item','0D7' => 'Feed Comment','09A' => 'Feed Poll Choice','09B' => 'Feed Poll Vote','0E8' => 'Entity Subscription','0F9' => 'Group',
                        '0FB' => 'Group Member','0I5' => 'Group Member Request','0H1' => 'Chatter Invitation','0hd' => 'Hashtag Definition','0ca' => 'Chatter Activity','08U' => 'Feed Revision','0IF' => 'Push Topic','04P' => 'Connection','04V' => 'Connection History','01L' => 'Currency Type','04w' => 'Dated Conversion Rate','00O' => 'Report','01Z' => 'Dashboard',
                        '01a' => 'Dashboard Component','01Q' => 'Assignment Rule','04a' => 'Process Definition','04b' => 'Process Node','04g' => 'Process Instance','04h' => 'Process Instance Step','04i' => 'Approval Request','01p' => 'Apex Class','01q' => 'Apex Trigger','07L' => 'Apex Debug Log','07M' => 'Apex Test Result','707' => 'Apex Job','709' => 'Apex Test Queue Item',
                        '00E' => 'Role','00G' => 'Group','011' => 'Group Member','03g' => 'Queue Sobject','066' => 'Visualforce Page','099' => 'Visualforce Component','081' => 'Static Resource','100' => 'User License','050' => 'Package License','051' => 'User Package License','00e' => 'Profile','0PS' => 'Permission Set','0Pa' => 'Permission Set Assignment',
                        '110' => 'Object Permissions','01k' => 'Field Permissions','0J0' => 'Setup Entity Access','00T' => 'Task','00U' => 'Event','0RE' => 'Event Relation','02n' => 'Category Node','02o' => 'Category Data','0DM' => 'Site','0I4' => 'Domain','0Jf' => 'Custom URL','0D2' => 'Organization-wide From Email Address','0DB' => 'Network',
                        '0DL' => 'Network Member Group','0DO' => 'Network Member','0Id' => 'Network Moderation','07W' => 'Custom Brand','07X' => 'Custom Brand Asset','0H4' => 'Connected App','0SO' => 'Auth. Provider','091' => 'Email Service','093' => 'Email Services Address','0in' => 'Knowledgeable User','0TO' => 'Topic','0FT' => 'Record','005' => 'User',
                        '0N2' => 'User Share','035' => 'CSS User','0Yw' => 'User Login','03u' => 'User Preference','0Ak' => 'Auth Session','00B' => 'List View','0AT' => 'Event Log File','4ie' => 'Entity Definition','4fe' => 'Field Definition','0Nv' => 'Field Definition','4pb' => 'Publisher','4ft' => 'Service Field Data Type','4dt' => 'Data Type',
                        '07u' => 'User Entity Access','0Ju' => 'Relationship','0Jv' => 'Relationship Domain','074' => 'CORS Whitelist Origin','0MD' => 'Promoted Search Term','02Z' => 'Institution Contact Role','01s' => 'Price Book','0Bg' => 'Idea Theme','087' => 'Idea','00a' => 'Idea Comment','0JZ' => 'Macro','07H' => 'Content Folder','0Aa' => 'Group Record',
                        '0Bt' => 'Announcement','0M6' => 'Streaming Channel','07g' => 'Action Link Group Template','07l' => 'Action Link Template','0OO' => 'Process Instance Node','0PL' => 'Permission Set License','2LA' => 'Permission Set License Assignment','06d' => 'Setting Granted By License','0UT' => 'Tenant Usage Entitlement','0PD' => 'Custom Permission Dependency','0CP' => 'Custom Permission','0Fo' => 'Flow Interview','09P' => 'Email Domain Key',
                        '570' => 'Live Chat Transcript','0Ig' => 'LiveChatTranscriptSkill','0DZ' => 'Live Chat Transcript Event','571' => 'Live Chat Visitor','0C5' => 'Skill','0C9' => 'Skill User','0CA' => 'Skill Profile','0C6' => 'Live Agent Configuration','0CB' => 'Live Chat User Config User','0CD' => 'Live Chat User Config Profile','0Ie' => 'SupervisorAgentConfigSkill','0KA' => 'UserConfigTransferSkill','0KB' => 'UserConfigTransferButton',
                        '572' => 'Live Chat Deployment','573' => 'Chat Button','0If' => 'LiveChatButtonSkill','0HJ' => 'LiveChatButtonDeployment','574' => 'Quick Text','0HK' => 'Live Agent Session','0No' => 'Live Chat Blocking Rule','0J6' => 'Audited Object','0Dm' => 'Community Self Registration','0Dp' => 'Community Page Override','0NU' => 'Reputation Level','0NV' => 'Reputation Points Rule','0Ab' => 'Lightning Component Bundle',
                        '0Ad' => 'Lightning Component Definition','0DS' => 'AppMenuItem','07T' => 'Authentication Configuration','0LE' => 'SAML Single Sign-On Setting','07U' => 'Authentication Configuration Auth. Provider','0CQ' => 'Oauth Token','0Jr' => 'Third Party Account Link','0XU' => 'External Data User Authentication','0Je' => 'User Provisioning Config','0HP' => 'User Provisioning Request','0Hs' => 'User Provisioning Log','0HX' => 'User Provisioning Mock Target','0Ni' => 'User Provisioning Account',
                        '0HY' => 'User Provisioning Account Staging','04F' => 'Login Geo Data','3NA' => 'Custom Object Usage By User License Metric','0Sk' => 'Skill','0SM' => 'Skill User','0SE' => 'Endorsement','0W0' => 'Thanks','0W1' => 'Badge','0W2' => 'Badge Received','0W5' => 'Access','0IG' => 'Mobile Device Registrar','0El' => 'Installed Mobile App','0Na' => 'User List View',
                        '0JU' => 'User List View Criteria','0Dd' => 'List View Chart','0De' => 'List View Chart Instance','0Bm' => 'Duplicate Rule','0GK' => 'Duplicate Record Set','0GL' => 'Duplicate Record Item','0JD' => 'Matching Rule','0JE' => 'Matching Rule Item','0XC' => 'External Data Source','0XA' => 'Named Credential','0JV' => 'Platform Action','a00' => 'Intranet Video Item Links','a06' => 'Recordtype Setting',
                        'a07' => 'Contract Docs to Opps MtM','a08' => 'Contract Document','a09' => 'Contract Integrated Account','a0A' => 'Contract ABC','a0B' => 'Contracts to Contract Docs  MtM','a0C' => 'Express Web Activity','a0D' => 'Institution Role','a0E' => 'Invoice','a0F' => 'Meeting Utilization','a0G' => 'Membership Key Contact','a0H' => 'Membership','a0I' => 'NBB','a0J' => 'OAB Lead Passer',
                        'a0K' => 'Other Utilization','a0L' => 'SME Incentive Credit','a0M' => 'Program','a0N' => 'Restrictions MtM','a0O' => 'Restriction Clearance Request','a0P' => 'Restriction','a0Q' => 'Teleconference Utilization','a0R' => 'Warm Lead MtM','a0S' => 'Warm Lead','a0T' => '80-50','a0U' => 'Change Request','a0V' => 'IS System Modification','a0W' => 'SFDC Release',
                        'a0X' => 'IS Dev Activity','a0Y' => 'zzzPrograms Included','a0Z' => 'Case Blackout Date','a0a' => 'Case Category MTM','a0b' => 'Case Category','a0c' => 'Event Queue','a0d' => 'Expert MTM','a0e' => 'Program MTM','a0f' => 'SNAPSHOT: ExpCtr Cases','a0g' => 'Base URL','a0h' => 'Account Settings (FF)','a0i' => 'Budgets & Balances Settings (FF)','a0k' => 'Integration Rules Settings (FF)',
                        'a0l' => 'Reporting Balance','a0n' => 'Account In Use','a0o' => 'Accounting Currency','a0p' => 'Accounting Settings (FF)','a0q' => 'Aged Analysis Definition','a0r' => 'DEPRECATED: Balance Update Result','a0s' => 'Bank Account','a0t' => 'Bank Reconciliation Charge','a0u' => 'Bank Reconciliation Line Item','a0v' => 'Bank Reconciliation','a0w' => 'Bank Statement Definition','a0x' => 'Bank Statement Line Item','a0y' => 'Bank Statement',
                        'a0z' => 'Budget and Balance','a10' => 'Cash Entry Line Item','a11' => 'Cash Entry','a12' => 'Cash Matching History','a13' => 'Cash Matching Settings (FF)','a14' => 'Check Number','a15' => 'Check Range','a16' => 'Column Property','a17' => 'Company','a18' => 'Sales Credit Note Line Item','a19' => 'Sales Credit Note','a1A' => 'Currency Revaluation Batch Line Item','a1B' => 'Currency Revaluation Batch',
                        'a1C' => 'Currency Revaluation Line Item','a1D' => 'Currency Revaluation Summary','a1E' => 'Currency Revaluation','a1F' => 'Data Property','a1G' => 'Dimension 1','a1H' => 'Dimension 2','a1I' => 'Dimension 3','a1J' => 'Dimension 4','a1K' => 'Event Log','a1L' => 'Exchange Rate','a1M' => 'Finance Correspondence','a1N' => 'Format Data','a1O' => 'General Ledger Account',
                        'a1P' => 'Grouping Reference','a1Q' => 'DEPRECATED:Inc Sch Staging Jnl Line Item','a1R' => 'DEPRECATED:Inc Schedule Staging Jnl','a1S' => 'Income Schedule Definition','a1T' => 'Integration Rule Line Item','a1U' => 'Integration Rule','a1V' => 'Intercompany Definition','a1W' => 'Intercompany Transfer Line Item','a1X' => 'Intercompany Transfer','a1Y' => 'Intersect Definition','a1Z' => 'Sales Invoice Installment Line Item','a1a' => 'Sales Invoice Line Item','a1b' => 'Sales Invoice',
                        'a1c' => 'Item','a1d' => 'Journal Line Item','a1e' => 'Journal','a1f' => 'Lookup','a1g' => 'Mapping Format','a1h' => 'Mass Email Account Line Item','a1i' => 'Mass Email Account','a1j' => 'Matching Reference','a1k' => 'Field','a1l' => 'Page Num Property','a1m' => 'Payment Summary','a1n' => 'Payment Account Selection','a1o' => 'Payment Batch Line Item',
                        'a1p' => 'Payment Batch','a1q' => 'Deprecated: Payment History','a1r' => 'Payment Detail','a1s' => 'Payment Media Control','a1t' => 'Payment Media Detail','a1u' => 'Payment Media Summary','a1v' => 'Payment Settings (FF)','a1w' => 'Payment Template Line Item','a1x' => 'Payment Template','a1y' => 'Payment','a1z' => 'Period','a20' => 'Print Format','a21' => 'Product In Use',
                        'a22' => 'Payable Credit Note Expense Line Item','a23' => 'Payable Credit Note Line Item','a24' => 'Payable Credit Note','a25' => 'Payable Invoice Expense Line Item','a26' => 'Payable Invoice Line Item','a27' => 'Payable Invoice','a28' => 'Income Schedule Line Item','a29' => 'Section','a2A' => 'Selection Criterion','a2B' => 'Selection Definition','a2C' => 'Single Mapping','a2D' => 'Sort Order','a2E' => 'Table Property',
                        'a2F' => 'Tax Code','a2G' => 'Tax Rate','a2H' => 'Text Definition','a2I' => 'Transaction Line Item','a2J' => 'Transaction','a2K' => 'User Company','a2L' => 'Year','a2M' => 'DupeBlocker Auto-Convert Mapping','a2N' => 'DupeBlocker Auto-Convert Setting','a2O' => 'DupeBlocker Auto-Merge Mapping','a2P' => 'DupeBlocker Auto-Merge Setting','a2Q' => 'DupeBlocker Duplicate Warning','a2R' => 'DupeBlocker Potential Duplicate',
                        'a2S' => 'DupeBlocker Scenario Filter','a2T' => 'DupeBlocker Scenario Key','a2U' => 'DupeBlocker Scenario Link (Deprecated)','a2V' => 'DupeBlocker Scenario Rule','a2W' => 'DupeBlocker Scenario','a2X' => 'DupeBlocker Setting (Deprecated)','a2Y' => 'AMQA Distribution List','a2Z' => 'Contact Queue','a2a' => 'IS Process','a2b' => 'IS Project Checkin','a2c' => 'IS System Process','a2d' => 'IS System','a2e' => 'Chat Roll Up Option',
                        'a2f' => 'Chatter Unfollow Batch Job Queued','a2g' => 'Chatter Unfollow Delayed RecordId','a2h' => 'Chatter Unfollow Rule Job Batch','a2i' => 'Chatter Unfollow Rules','a2j' => 'Chatter Unfollow Test Data','a2k' => 'Document Mapping Field','a2l' => 'Document Mapping','a2n' => 'OneTouch Settings (FF)','a2o' => 'Consolidated Invoice Line Item','a2p' => 'Consolidated Invoice','a2q' => 'Invoice Billing Schedule','a2r' => 'Line Item Schedule','a2s' => 'EchoSign Push Mapping Settings',
                        'a2t' => 'Agreement Template','a2u' => 'Add File Attachment','a2v' => 'Document Key Mutex','a2w' => 'Map Data into Agreement Field','a2x' => 'EchoSign Merge Mapping Settings','a2y' => 'Add Recipient','a2z' => 'Agreement Event','a30' => 'Agreement','a31' => 'EchoSign Data Mapping','a32' => 'EchoSign Field Mapping','a33' => 'EchoSign File Mapping','a34' => 'EchoSign Form Field Import','a35' => 'EchoSign Form Field Mapping Entry',
                        'a36' => 'EchoSign Form Field Mapping','a37' => 'EchoSign Merge Mapping','a38' => 'EchoSign Object Mapping','a39' => 'Echosign Recipient','a3B' => 'EchoSign Settings','a3C' => 'Signed Agreement','a3D' => 'EchoSign Toolbar Settings','a3E' => 'EchoSign Trigger','a3F' => 'Conga Composer Settings','a3G' => 'Conga Template','a3I' => 'Intranet_Constants','a3J' => 'Advisory Idea Site URL',
                        'a3K' => 'Intranet Container','a3L' => 'Intranet Defaults','a3M' => 'Campaign\'s Marketing Asset','a3N' => 'Marketing Activity','a3O' => 'Marketing Asset','a3P' => 'ABCO Data Capture','a3Q' => 'Client Validation','a3R' => 'Correspondence Review Form','a3S' => 'Cubes/Reports','a3T' => 'Data Audit','a3U' => 'Implementation Checklist','a3V' => 'Milliman Data Mapping and ETL','a3W' => 'Milliman Data Procurement',
                        'a3X' => 'Milliman Setup','a3Y' => 'Move to Production','a3Z' => 'Notification and Welcome Call','a3a' => 'Processing/Analytics','a3b' => 'Project Risk Assessment Form','a3c' => 'Run MedInsight Engines','a3d' => 'Technical Kick-off','a3e' => 'Member Interaction','a3f' => 'Deployment Type','a3g' => 'Deployment','a3h' => 'EHBI Benchmark','a3i' => 'File','a3j' => 'LOA',
                        'a3k' => 'Member Support Assignment','a3l' => 'Opportunity and ROI','a3m' => 'Project Role','a3n' => 'Project','a3o' => 'Member Support','a3p' => 'Deployment Source System','a3q' => 'Source System','a3r' => 'PTD Utilization','a3s' => 'Vendor Relationship','a3t' => 'Vendor','a3u' => 'Workstream','a3v' => 'Workstream Task','a3w' => 'Milliman Project Relationship',
                        'a3x' => 'zzzAdvisory.com Site','a3y' => 'zzCallout Exception','a3z' => 'Eligible Domain','a40' => 'Eligible Subscription Option','a41' => 'Subscription Option','a42' => 'Subscription','a43' => 'Temporary Program Access','a44' => 'Web Conference','a45' => 'Web Program Access MTM','a46' => 'Web Program Access','a48' => 'Research Study','a49' => 'Meeting',
                        'a4A' => 'Registration','a4B' => 'Fogbridge_comments','a4C' => 'FBStatus','a4D' => 'FB Category','a4E' => 'FB Settings','a4F' => 'Fogbridge sObject Test','a4G' => 'Status Maping','a4H' => 'DupeBlocker Account Name Filters','a4I' => 'API Keys','a4J' => 'Presentation','a4K' => 'Shared Event Material','a4L' => 'Slide Note','a4M' => 'Slide',
                        'a4N' => 'Batch Lock Detail','a4O' => 'Batch Lock','a4Q' => 'Advisory Rewards Points','a4R' => 'Expense','a4S' => 'zzzCredit Card Profile','a4T' => 'Credit Card Settings','a4U' => 'Credit Card Transaction','a4V' => 'Credit Card','a4W' => 'Expense Summary','a4X' => 'OSR','a4Y' => 'Credit Portfolio','a4Z' => 'Web Service Log','a4a' => 'Budget Allocation',
                        'a4b' => 'Budget Exclusion','a4c' => 'Budget Line','a4d' => 'Budget','a4e' => 'Department','a4f' => 'Integration Job','a4g' => 'Integration Log','a4h' => 'Integration Mapping','a4i' => 'Integration','a4j' => 'Payment Request','a4k' => 'Purchase Request','a4l' => 'Advisory.com Visit','a4m' => 'Advisory Twitter Feed','a4n' => 'Account Standard Layouts',
                        'a4o' => 'DupeBlocker Batch Key Builder Data','a4p' => 'DupeBlocker Block Bypass','a4q' => 'DupeBlocker Convert Display Fields','a4r' => 'DupeBlocker Country Mapping','a4t' => 'DupeBlocker First Name Mapping','a4u' => 'DupeBlocker Fuzzy Rules','a4v' => 'DupeBlocker General Settings','a4x' => 'DupeBlocker Scenario Target Filter','a4y' => 'DupeBlocker State Mapping','a4z' => 'DupeBlocker Web Lead Sources','a50' => 'Related Content','a51' => 'Action','a52' => 'Awarding Method',
                        'a53' => 'Behavior Product','a54' => 'Contest Builder Assigned Observer','a55' => 'Contest Builder Assigned Participant','a56' => 'Contest Builder','a57' => 'Chatter Group','a58' => 'Configuration','a59' => 'Contest Admin','a5A' => 'ContestBuilderSettings','a5B' => 'Contest User','a5C' => 'Contest','a5D' => 'Custom Contest Available Object','a5E' => 'Custom Field Value Filter','a5F' => 'Event Filter',
                        'a5G' => 'Filter Field','a5H' => 'Lead Filter','a5I' => 'Message','a5J' => 'Motivate Sale','a5K' => 'Notification History','a5L' => 'Opportunity Filter Product','a5M' => 'Opportunity Filter','a5N' => 'Pipeline Behavior','a5O' => 'Prize','a5P' => 'Product Filter Product','a5Q' => 'Product Filter','a5R' => 'Proxy Object','a5S' => 'SCB Participant Profile',
                        'a5T' => 'Task Filter','a5U' => 'Team Member','a5V' => 'Team','a5W' => 'Win','a5X' => 'Customer','a5Y' => 'Partner Contract Terms','a5Z' => 'Partner Product Catalog','a5b' => 'Service Order Detail','a5c' => 'Service Order Log','a5d' => 'Service Order','a5e' => 'Configuration Manager','a5f' => 'Survey Question','a5g' => 'Survey Response',
                        'a5h' => 'Common Auth Site','a5i' => 'Community Profiles','a5j' => 'Community Project Source','a5k' => 'Contact to Project MTM','a5l' => 'Out Of Office Comment','a5m' => 'Site URLs','a5n' => 'Sync Field','a5o' => 'License','a5p' => 'Package Version','a5q' => 'Package','a5r' => 'Advisory Idea Comment','a5s' => 'Advisory Idea Team Member','a5t' => 'Advisory Idea Vote',
                        'a5u' => 'Advisory Idea','a5v' => 'SSO Settings','a5w' => 'MemberInteractionContactMtM','a5x' => 'Mailing List Settings','a5y' => 'Publication Item','a5z' => 'Publication','a60' => 'Intranet Item','a61' => 'Intranet Schedule','a62' => 'Intranet Settings','a63' => 'Intranet Utilization','a64' => 'Department-Division-Function','a65' => 'Chatter Group Management','a66' => 'Bundle',
                        'a67' => 'Bundled Siblings','a68' => 'As of Aging Process Log','a69' => 'As of Aging Report Settings','a6A' => 'As Of Aging Settings','a6B' => 'As of Aging','a6C' => 'Billing Settings','a6D' => 'Cancel Payment Log','a6E' => 'Cancel Payment Control','a6G' => 'Worker Item','a6H' => 'CashMatchingUtiliySettings','a6I' => 'Worker Log Group','a6J' => 'Worker Log','a6K' => 'Accounting Background Worker',
                        'a6L' => 'Currency Revaluation GLA Item','a6M' => 'Currency Revaluation Group','a6N' => 'Record Lock Group','a6O' => 'Record Lock','a6P' => 'Cancel Payment Criteria','a6Q' => 'Year End Log','a6R' => 'Batch Process','a6T' => 'Event','a6U' => 'Tax Detail Sales Credit Note','a6V' => 'Tax Detail Sales Invoice','a6W' => 'Site Profile','a6X' => 'Site User','a6Y' => 'Sitecore Settings',
                        'a6Z' => 'Account Relationship','a6a' => 'Field Analysis','a6b' => 'Field Trip','a6c' => 'Reporting Data Range','a6d' => 'Reporting Definition','a6e' => 'Reporting Filter Mapping','a6f' => 'Reporting Filter','a6g' => 'Reporting Label','a6h' => 'Reporting Log','a6i' => 'Reporting Object','a6j' => 'Reporting Prompt Mapping','a6k' => 'Reporting Prompt','a6l' => 'Reporting Value',
                        'a6m' => 'ClickLink Another Source Test','a6n' => 'ClickLink Managed Job','a6o' => 'ClickLink Action','a6p' => 'ClickLink Button','a6q' => 'ClickLink Job','a6r' => 'ClickLink Line Lookup Test','a6s' => 'ClickLink Log Line Item','a6t' => 'ClickLink Log','a6u' => 'ClickLink Lookup Test','a6v' => 'ClickLink Mapping','a6w' => 'ClickLink Relationship','a6x' => 'ClickLink Settings','a6y' => 'ClickLink Source Line Item Test',
                        'a6z' => 'ClickLink Source List View Test','a70' => 'ClickLink Source Test','a71' => 'ClickLink Target Line Item Test','a72' => 'ClickLink Target Test','a74' => 'ClickLink Rule','a76' => 'ShipIt PackageType','a77' => 'ShipIt Settings','a78' => 'ShipIt ShipMethod','a79' => 'Shipment','a7A' => 'Custom Attachment','a7B' => 'Journal Batch Header','a7C' => 'Journal Upload Lines','a7D' => 'Advisory Event',
                        'a7E' => 'Communication Template','a7F' => 'Cost Center','a7G' => 'Event Budget','a7H' => 'Event Registration','a7I' => 'Event Rule','a7J' => 'Expense Authorization','a7K' => 'Registration Membership','a7L' => 'Rule','a7M' => 'Team Member','a7N' => 'Venue Payment','a7O' => 'Venues and Vendors','a7P' => 'Feed Batch','a7Q' => 'Feed Item',
                        'a7R' => 'Feed Transaction','a7S' => 'Feed','a7T' => 'Program Hierarchy','a7U' => 'Staff Assignment','a7V' => 'Staff Role','a7W' => 'Group','a7X' => 'WorkdayCostCenterSync','a7Y' => 'Top 5 Frequently Accessed Apps','a7Z' => 'ABC Profile','a7a' => 'Provider Profile','a7b' => 'Liquid Planner Settings','h00' => 'Opportunity (Historical)','h01' => 'Membership (Historical)',
                        'h02' => 'Project (Historical)','h03' => 'Case (Historical)'
                        };
                            }
            return prefixToObjectMap;
        }
        set;
    }
    
    /**
     * 
     * @description: map of all SObject prefixes -> sObject api name  (as of 8/13/15)
     * 	//Modified by Ishan Arora 05-03-2019 CR-20190501-13072 - Spring Cleanup 
     * 
     *Version Log -  V1.1 Modifed By Dipesh Gupta - CR-20190726-13240 - 08/06/2019 - Remove the reference of Temporary_Program_Access__c
     **/
    public map<string, string> prefixToAPINameMap {
        get {
            if (prefixToAPINameMap == null) {
                //Modified by Ishan Arora 05-03-2019 CR-20190501-13072 - Spring Cleanup 
                //Modified by Dipesh Gupta 10-03-2019 CR-20190522-13123 -Remove the reference of 'Syndicated_Research_Interaction__c'.
                //Commented By - Neha Sharma - 05/20/2021 - CR-20190620-13192 - Integrating subscription data from Marketo to Salesforce - old object removal
                //Commented By - Nikita Kumari - 08/03/2022 - CR-20220217-15921 - Boardroom Sunsetting Changes	 
                prefixToAPINameMap = new map<string, string> {
                    '01J' => 'OpportunityStage','012' => 'RecordType','019' => 'BusinessProcess','800' => 'Contract','806' => 'Approval','02a' => 'ContractContactRole','00D' => 'Organization','01H' => 'MailmergeTemplate','01N' => 'Scontrol','02s' => 'EmailMessage','015' => 'Document','00l' => 'Folder','00b' => 'WebLink','00X' => 'EmailTemplate',
                        '05X' => 'DocumentAttachmentMap','016' => 'BrandTemplate','0Ya' => 'LoginHistory','710' => 'LoginIp','713' => 'ClientBrowser','083' => 'Vote','09a' => 'Community','0t0' => 'TagDefinition','701' => 'Campaign','08s' => 'CampaignShare','01Y' => 'CampaignMemberStatus','00v' => 'CampaignMember','001' => 'Account',
                        '00r' => 'AccountShare','003' => 'Contact','03s' => 'ContactShare','00Q' => 'Lead','01o' => 'LeadShare','006' => 'Opportunity','00t' => 'OpportunityShare','00K' => 'OpportunityContactRole','008' => 'OpportunityHistory','00k' => 'OpportunityLineItem','00o' => 'OpportunityLineItemSchedule','00J' => 'OpportunityCompetitor','00p' => 'UserTeamMember',
                        '01D' => 'UserAccountTeamMember','00q' => 'OpportunityTeamMember','01M' => 'AccountTeamMember','00I' => 'Partner','608' => 'ForecastShare','002' => 'Note','00P' => 'Attachment','022' => 'FiscalYearSettings','026' => 'Period','01u' => 'PricebookEntry','01t' => 'Product2','02i' => 'Asset','01m' => 'BusinessHours',
                        '500' => 'Case','01n' => 'CaseShare','00a' => 'CaseComment','03j' => 'CaseContactRole','010' => 'CaseSolution','501' => 'Solution','0C0' => 'Holiday','04m' => 'AdditionalNumber','04v' => 'CallCenter','068' => 'ContentVersion','069' => 'ContentDocument','06A' => 'ContentDocumentLink','058' => 'ContentWorkspace',
                        '059' => 'ContentWorkspaceDoc','05D' => 'ContentDistribution','05H' => 'ContentDistributionView','07v' => 'ContentFolderLink','07I' => 'ContentFolderMember','08a' => 'CronJobDetail','08e' => 'CronTrigger','0D5' => 'FeedItem','0D7' => 'FeedComment','09A' => 'FeedPollChoice','09B' => 'FeedPollVote','0E8' => 'EntitySubscription','0F9' => 'CollaborationGroup',
                        '0FB' => 'CollaborationGroupMember','0I5' => 'CollaborationGroupMemberRequest','0H1' => 'CollaborationInvitation','0hd' => 'HashtagDefinition','0ca' => 'ChatterActivity','08U' => 'FeedRevision','0IF' => 'PushTopic','04P' => 'PartnerNetworkConnection','04V' => 'PartnerNetworkRecordConnection','01L' => 'CurrencyType','04w' => 'DatedConversionRate','00O' => 'Report','01Z' => 'Dashboard',
                        '01a' => 'DashboardComponent','01Q' => 'AssignmentRule','04a' => 'ProcessDefinition','04b' => 'ProcessNode','04g' => 'ProcessInstance','04h' => 'ProcessInstanceStep','04i' => 'ProcessInstanceWorkitem','01p' => 'ApexClass','01q' => 'ApexTrigger','07L' => 'ApexLog','07M' => 'ApexTestResult','707' => 'AsyncApexJob','709' => 'ApexTestQueueItem',
                        '00E' => 'UserRole','00G' => 'Group','011' => 'GroupMember','03g' => 'QueueSobject','066' => 'ApexPage','099' => 'ApexComponent','081' => 'StaticResource','100' => 'UserLicense','050' => 'PackageLicense','051' => 'UserPackageLicense','00e' => 'Profile','0PS' => 'PermissionSet','0Pa' => 'PermissionSetAssignment',
                        '110' => 'ObjectPermissions','01k' => 'FieldPermissions','0J0' => 'SetupEntityAccess','00T' => 'Task','00U' => 'Event','0RE' => 'EventRelation','02n' => 'CategoryNode','02o' => 'CategoryData','0DM' => 'Site','0I4' => 'Domain','0Jf' => 'DomainSite','0D2' => 'OrgWideEmailAddress','0DB' => 'Network',
                        '0DL' => 'NetworkMemberGroup','0DO' => 'NetworkMember','0Id' => 'NetworkModeration','07W' => 'CustomBrand','07X' => 'CustomBrandAsset','0H4' => 'ConnectedApplication','0SO' => 'AuthProvider','091' => 'EmailServicesFunction','093' => 'EmailServicesAddress','0in' => 'KnowledgeableUser','0TO' => 'Topic','0FT' => 'TopicAssignment','005' => 'User',
                        '0N2' => 'UserShare','035' => 'SelfServiceUser','0Yw' => 'UserLogin','03u' => 'UserPreference','0Ak' => 'AuthSession','00B' => 'ListView','0AT' => 'EventLogFile','4ie' => 'EntityDefinition','4fe' => 'FieldDefinition','0Nv' => 'EntityParticle','4pb' => 'Publisher','4ft' => 'ServiceFieldDataType','4dt' => 'DataType',
                        '07u' => 'UserEntityAccess','0Ju' => 'RelationshipInfo','0Jv' => 'RelationshipDomain','074' => 'CorsWhitelistEntry','0MD' => 'SearchPromotionRule','02Z' => 'AccountContactRole','01s' => 'Pricebook2','0Bg' => 'IdeaTheme','087' => 'Idea','00a' => 'IdeaComment','0JZ' => 'Macro','07H' => 'ContentFolder','0Aa' => 'CollaborationGroupRecord',
                        '0Bt' => 'Announcement','0M6' => 'StreamingChannel','07g' => 'ActionLinkGroupTemplate','07l' => 'ActionLinkTemplate','0OO' => 'ProcessInstanceNode','0PL' => 'PermissionSetLicense','2LA' => 'PermissionSetLicenseAssign','06d' => 'GrantedByLicense','0UT' => 'TenantUsageEntitlement','0PD' => 'CustomPermissionDependency','0CP' => 'CustomPermission','0Fo' => 'FlowInterview','09P' => 'EmailDomainKey',
                        '570' => 'LiveChatTranscript','0Ig' => 'LiveChatTranscriptSkill','0DZ' => 'LiveChatTranscriptEvent','571' => 'LiveChatVisitor','0C5' => 'Skill','0C9' => 'SkillUser','0CA' => 'SkillProfile','0C6' => 'LiveChatUserConfig','0CB' => 'LiveChatUserConfigUser','0CD' => 'LiveChatUserConfigProfile','0Ie' => 'SupervisorAgentConfigSkill','0KA' => 'UserConfigTransferSkill','0KB' => 'UserConfigTransferButton',
                        '572' => 'LiveChatDeployment','573' => 'LiveChatButton','0If' => 'LiveChatButtonSkill','0HJ' => 'LiveChatButtonDeployment','574' => 'QuickText','0HK' => 'LiveAgentSession','0No' => 'LiveChatBlockingRule','0J6' => 'NetworkActivityAudit','0Dm' => 'NetworkSelfRegistration','0Dp' => 'NetworkPageOverride','0NU' => 'ReputationLevel','0NV' => 'ReputationPointsRule','0Ab' => 'AuraDefinitionBundle',
                        '0Ad' => 'AuraDefinition','0DS' => 'AppMenuItem','07T' => 'AuthConfig','0LE' => 'SamlSsoConfig','07U' => 'AuthConfigProviders','0CQ' => 'OauthToken','0Jr' => 'ThirdPartyAccountLink','0XU' => 'ExternalDataUserAuth','0Je' => 'UserProvisioningConfig','0HP' => 'UserProvisioningRequest','0Hs' => 'UserProvisioningLog','0HX' => 'UserProvMockTarget','0Ni' => 'UserProvAccount',
                        '0HY' => 'UserProvAccountStaging','04F' => 'LoginGeo','3NA' => 'CustomObjectUserLicenseMetrics','0Sk' => 'ProfileSkill','0SM' => 'ProfileSkillUser','0SE' => 'ProfileSkillEndorsement','0W0' => 'WorkThanks','0W1' => 'WorkBadgeDefinition','0W2' => 'WorkBadge','0W5' => 'WorkAccess','0IG' => 'MobileDeviceRegistrar','0El' => 'InstalledMobileApp','0Na' => 'UserListView',
                        '0JU' => 'UserListViewCriterion','0Dd' => 'ListViewChart','0De' => 'ListViewChartInstance','0Bm' => 'DuplicateRule','0GK' => 'DuplicateRecordSet','0GL' => 'DuplicateRecordItem','0JD' => 'MatchingRule','0JE' => 'MatchingRuleItem','0XC' => 'ExternalDataSource','0XA' => 'NamedCredential','0JV' => 'PlatformAction',/*'a00' => 'Intranet_Video_Item_Links__c',*/
                        'a07' => 'Contract_Docs_to_Opps_MtM__c','a08' => 'Contract_Document__c','a09' => 'Contract_Integrated_Accounts__c','a0A' => 'Contract__c','a0B' => 'Contracts_to_Contract_Docs_MtM__c','a0C' => 'Express_Web_Activity__c','a0D' => 'Institution_Roles__c','a0E' => 'Invoice__c','a0F' => 'Meeting_Utilization__c','a0G' => 'Membership_Key_Contact__c','a0H' => 'Membership__c','a0I' => 'NBB__c','a0J' => 'OAB_Lead_Passer__c',
                        'a0K' => 'Other_Utilization__c','a0L' => 'PSS_Incentive_Credit__c','a0M' => 'Program__c','a0N' => 'Restricted_MtM__c','a0O' => 'Restriction_Clearance_Request__c','a0P' => 'Restrictions__c','a0Q' => 'Utilization_Data_Object__c','a0R' => 'Warm_Lead_MtM__c','a0S' => 'Warm_Lead__c','a0T' => 'X80_50__c','a0U' => 'SFDC_Change_Request__c','a0V' => 'SFDC_Modification__c','a0W' => 'SFDC_Release__c',
                        'a0X' => 'SFDC_Request_Comment__c','a0Y' => 'Bundle_MTM__c','a0Z' => 'Case_Blackout_Days__c','a0a' => 'Case_Category_MTM__c','a0b' => 'Case_Category__c','a0c' => 'Event_Queue__c','a0d' => 'Expert_MTM__c','a0e' => 'Program_MTM__c','a0f' => 'SNAPSHOT_ExpCtr__c','a0g' => 'Base_URL__c','a0h' => 'c2g__AccountSettings__c','a0i' => 'c2g__BudgetsAndBalancesSettings__c','a0k' => 'c2g__IntegrationRulesSettings__c',
                        'a0l' => 'c2g__ReportingBalance__c','a0n' => 'c2g__codaAccountInUse__c','a0o' => 'c2g__codaAccountingCurrency__c','a0p' => 'c2g__codaAccountingSettings__c','a0q' => 'c2g__codaAgedAnalysisDef__c','a0r' => 'c2g__codaBalanceUpdateResult__c','a0s' => 'c2g__codaBankAccount__c','a0t' => 'c2g__codaBankReconciliationCharge__c','a0u' => 'c2g__codaBankReconciliationLineItem__c','a0v' => 'c2g__codaBankReconciliation__c','a0w' => 'c2g__codaBankStatementDefinition__c','a0x' => 'c2g__codaBankStatementLineItem__c','a0y' => 'c2g__codaBankStatement__c',
                        'a0z' => 'c2g__codaBudget__c','a10' => 'c2g__codaCashEntryLineItem__c','a11' => 'c2g__codaCashEntry__c','a12' => 'c2g__codaCashMatchingHistory__c','a13' => 'c2g__codaCashMatchingSettings__c','a14' => 'c2g__codaCheckNumber__c','a15' => 'c2g__codaCheckRange__c','a16' => 'c2g__codaColumnProperty__c','a17' => 'c2g__codaCompany__c','a18' => 'c2g__codaCreditNoteLineItem__c','a19' => 'c2g__codaCreditNote__c','a1A' => 'c2g__codaCurrencyRevalBatchLineItem__c','a1B' => 'c2g__codaCurrencyRevalBatch__c',
                        'a1C' => 'c2g__codaCurrencyRevaluationLineItem__c','a1D' => 'c2g__codaCurrencyRevaluationSummary__c','a1E' => 'c2g__codaCurrencyRevaluation__c','a1F' => 'c2g__codaDataProperty__c','a1G' => 'c2g__codaDimension1__c','a1H' => 'c2g__codaDimension2__c','a1I' => 'c2g__codaDimension3__c','a1J' => 'c2g__codaDimension4__c','a1K' => 'c2g__codaEventLog__c','a1L' => 'c2g__codaExchangeRate__c','a1M' => 'c2g__codaFinanceCorrespondence__c','a1N' => 'c2g__codaFormatData__c','a1O' => 'c2g__codaGeneralLedgerAccount__c',
                        'a1P' => 'c2g__codaGroupingReference__c','a1Q' => 'c2g__codaIncScheduleStagingJnlLineItem__c','a1R' => 'c2g__codaIncScheduleStagingJnl__c','a1S' => 'c2g__codaIncomeScheduleDefinition__c','a1T' => 'c2g__codaIntegrationRuleLineItem__c','a1U' => 'c2g__codaIntegrationRule__c','a1V' => 'c2g__codaIntercompanyDefinition__c','a1W' => 'c2g__codaIntercompanyTransferLineItem__c','a1X' => 'c2g__codaIntercompanyTransfer__c','a1Y' => 'c2g__codaIntersectDefinition__c','a1Z' => 'c2g__codaInvoiceInstallmentLineItem__c','a1a' => 'c2g__codaInvoiceLineItem__c','a1b' => 'c2g__codaInvoice__c',
                        'a1c' => 'c2g__codaItem__c','a1d' => 'c2g__codaJournalLineItem__c','a1e' => 'c2g__codaJournal__c','a1f' => 'c2g__codaLookup__c','a1g' => 'c2g__codaMappingFormat__c','a1h' => 'c2g__codaMassEmailAccountLineItem__c','a1i' => 'c2g__codaMassEmailAccount__c','a1j' => 'c2g__codaMatchingReference__c','a1k' => 'c2g__codaObjectField__c','a1l' => 'c2g__codaPageNumProperty__c','a1m' => 'c2g__codaPaymentAccountLineItem__c','a1n' => 'c2g__codaPaymentAccountSelection__c','a1o' => 'c2g__codaPaymentBatchLineItem__c',
                        'a1p' => 'c2g__codaPaymentBatch__c','a1q' => 'c2g__codaPaymentHistory__c','a1r' => 'c2g__codaPaymentLineItem__c','a1s' => 'c2g__codaPaymentMediaControl__c','a1t' => 'c2g__codaPaymentMediaDetail__c','a1u' => 'c2g__codaPaymentMediaSummary__c','a1v' => 'c2g__codaPaymentSettings__c','a1w' => 'c2g__codaPaymentTemplateLineItem__c','a1x' => 'c2g__codaPaymentTemplate__c','a1y' => 'c2g__codaPayment__c','a1z' => 'c2g__codaPeriod__c','a20' => 'c2g__codaPrintFormat__c','a21' => 'c2g__codaProductInUse__c',
                        'a22' => 'c2g__codaPurchaseCreditNoteExpLineItem__c','a23' => 'c2g__codaPurchaseCreditNoteLineItem__c','a24' => 'c2g__codaPurchaseCreditNote__c','a25' => 'c2g__codaPurchaseInvoiceExpenseLineItem__c','a26' => 'c2g__codaPurchaseInvoiceLineItem__c','a27' => 'c2g__codaPurchaseInvoice__c','a28' => 'c2g__codaScheduleLineItem__c','a29' => 'c2g__codaSection__c','a2A' => 'c2g__codaSelectionCriterion__c','a2B' => 'c2g__codaSelection__c','a2C' => 'c2g__codaSingleMapping__c','a2D' => 'c2g__codaSortOrder__c','a2E' => 'c2g__codaTableProperty__c',
                        'a2F' => 'c2g__codaTaxCode__c','a2G' => 'c2g__codaTaxRate__c','a2H' => 'c2g__codaTextDefinition__c','a2I' => 'c2g__codaTransactionLineItem__c','a2J' => 'c2g__codaTransaction__c','a2K' => 'c2g__codaUserCompany__c','a2L' => 'c2g__codaYear__c','a2M' => 'CRMfusionDBR101__AutoConvert_Mapping__c','a2N' => 'CRMfusionDBR101__AutoConvert_Setting__c','a2O' => 'CRMfusionDBR101__AutoMerge_Mapping__c','a2P' => 'CRMfusionDBR101__AutoMerge_Setting__c','a2Q' => 'CRMfusionDBR101__Duplicate_Warning__c','a2R' => 'CRMfusionDBR101__Potential_Duplicate__c',
                        'a2S' => 'CRMfusionDBR101__Scenario_Filter__c','a2T' => 'CRMfusionDBR101__Scenario_Key__c','a2U' => 'CRMfusionDBR101__Scenario_Link__c','a2V' => 'CRMfusionDBR101__Scenario_Rule__c','a2W' => 'CRMfusionDBR101__Scenario__c','a2X' => 'CRMfusionDBR101__Setting__c','a2Y' => 'AMQA_Distribution_List__c','a2Z' => 'Contact_Queue__c','a2a' => 'IS_Process__c','a2b' => 'IS_Project_Checkin__c','a2c' => 'IS_System_Process__c','a2d' => 'IS_System__c','a2e' => 'chatroll__Chatter_Roll_up_Option__c',
                        'a2f' => 'chttrunfollow__UnfollowBatchJobsQueue__c','a2g' => 'chttrunfollow__UnfollowQueue__c','a2h' => 'chttrunfollow__UnfollowRuleJob__c','a2i' => 'chttrunfollow__UnfollowRule__c','a2j' => 'chttrunfollow__UnfollowTest__c','a2k' => 'ffps_dm__DocumentMappingField__c','a2l' => 'ffps_dm__DocumentMapping__c','a2n' => 'ffbext__OneTouchSettings__c','a2o' => 'ConsolidatedInvoiceLineItem__c','a2p' => 'ConsolidatedInvoice__c','a2q' => 'Invoice_Billing_Schedule__c','a2r' => 'Line_Item_Schedule__c','a2s' => 'echosign_dev1__Agreement_Push_Mapping_Settings__c',
                        'a2t' => 'echosign_dev1__Agreement_Template__c','a2u' => 'echosign_dev1__Attachment_Template__c','a2v' => 'echosign_dev1__DocumentKeyMutex__c','a2w' => 'echosign_dev1__Field_Template__c','a2x' => 'echosign_dev1__Merge_Mapping_Settings__c','a2y' => 'echosign_dev1__Recipient_Template__c','a2z' => 'echosign_dev1__SIGN_AgreementEvent__c','a30' => 'echosign_dev1__SIGN_Agreement__c','a31' => 'echosign_dev1__SIGN_Data_Mapping__c','a32' => 'echosign_dev1__SIGN_Field_Mapping__c','a33' => 'echosign_dev1__SIGN_File_Mapping__c','a34' => 'echosign_dev1__SIGN_Form_Field_Import__c','a35' => 'echosign_dev1__SIGN_Form_Field_Mapping_Entry__c',
                        'a36' => 'echosign_dev1__SIGN_Form_Field_Mapping__c','a37' => 'echosign_dev1__SIGN_Merge_Mapping__c','a38' => 'echosign_dev1__SIGN_Object_Mapping__c','a39' => 'echosign_dev1__SIGN_Recipients__c','a3B' => 'echosign_dev1__SIGN_Settings__c','a3C' => 'echosign_dev1__SIGN_SignedAgreement__c','a3D' => 'echosign_dev1__SIGN_Toolbar_Settings__c','a3E' => 'echosign_dev1__SIGN_Trigger__c','a3F' => 'APXTConga4__Conga_Composer_Settings__c','a3G' => 'APXTConga4__Conga_Template__c',/*'a3I' => 'Intranet_Constants__c',*/'a3J' => 'Advisory_Idea_Site_URL__c',
                        /*'a3K' => 'Intranet_Container__c','a3L' => 'Intranet_Defaults__c',*/'a3M' => 'ELOQUA__Campaign_s_Marketing_Asset__c','a3N' => 'ELOQUA__Marketing_Activity__c','a3O' => 'ELOQUA__Marketing_Asset__c','a3P' => 'ABCO_Data_Capture__c','a3Q' => 'Client_Validation__c','a3R' => 'Correspondence_Review_Form__c','a3S' => 'Cubes_Reports__c','a3T' => 'Data_Audit__c','a3U' => 'Implementation_Checklista__c','a3V' => 'Milliman_Data_Mapping_and_ETL__c','a3W' => 'Milliman_Data_Procurement__c',
                        'a3X' => 'Milliman_Setup__c','a3Y' => 'Move_to_Production__c','a3Z' => 'Notification_and_Welcome_Call__c','a3a' => 'Processing_Analytics__c','a3b' => 'Project_Risk_Assessment_Form__c','a3c' => 'Run_MedInsight_Engines__c','a3d' => 'Technical_Kick_off__c','a3e' => 'Call__c','a3f' => 'Deployment_Type__c','a3g' => 'Deployment__c','a3h' => 'EHBI_Benchmark__c','a3i' => 'File__c','a3j' => 'LOA__c',
                        'a3k' => 'Member_Support_Assignment__c','a3l' => 'Opportunity_and_ROI__c','a3m' => 'Project_Role__c','a3n' => 'Project__c','a3o' => 'Site_Issue__c','a3p' => 'Source_System_JuncObj__c','a3q' => 'Source_System__c','a3r' => 'Utilization__c','a3s' => 'Vendor_Relationship__c','a3t' => 'Vendor__c','a3u' => 'Workstream__c','a3v' => 'Workstream_Task__c','a3w' => 'Milliman_Project_Relationship__c',
                        'a3x' => 'Advisory_com_Site__c','a3y' => 'Callout_Exception__c','a3z' => 'Eligible_Domain__c', /*'a40' => 'Eligible_Subscription_Option__c','a41' => 'Subscription_Option__c','a42' => 'Subscription__c',*/ 'a44' => 'Web_Conference__c','a45' => 'Web_Program_Access_MTM__c','a46' => 'Web_Program_Access__c','a48' => 'Syndicated_Study__c','a49' => 'Meeting__c',
                        'a4A' => 'Registration__c','a4B' => 'Fogbridge_comments__c','a4C' => 'Fogbridge1way__FBStatus__c','a4D' => 'Fogbridge1way__FB_Category__c','a4E' => 'Fogbridge1way__FB_Settings__c','a4F' => 'Fogbridge1way__Fogbridge_sobject_test__c','a4G' => 'Fogbridge1way__Status_Maping__c','a4H' => 'CRMfusionDBR101__Account_Name_Filter__c','a4I' => 'API_Keys__c','a4J' => 'Presentation__c','a4K' => 'Shared_Presentation__c','a4L' => 'Slide_Note__c','a4M' => 'Slide__c',
                        'a4N' => 'c2g__codaBatchControlDetail__c','a4O' => 'c2g__codaBatchControl__c','a4Q' => 'advisory_rewards_points__c','a4R' => 'Expense__c','a4S' => 'Credit_Card_Profile__c','a4T' => 'Credit_Card_Settings__c','a4U' => 'Credit_Card_Transaction__c','a4V' => 'Credit_Card__c','a4W' => 'Expense_Travel__c','a4X' => 'OSR__c','a4Y' => 'Portfolio__c','a4Z' => 'Web_Service_Log__c','a4a' => 'Budget_Allocation__c',
                        'a4b' => 'Budget_Exclusion__c','a4c' => 'Budget_Line__c','a4d' => 'Budget__c','a4e' => 'Department__c','a4f' => 'Integration_Job__c','a4g' => 'Integration_Log__c','a4h' => 'Integration_Mapping__c','a4i' => 'Integration__c','a4j' => 'Payment_Request__c','a4k' => 'Purchase_Request__c','a4l' => 'Advisory_Com_Visit__c','a4m' => 'Advisory_Twitter_Feed__c','a4n' => 'Account_Standard_Layouts__c',
                        'a4o' => 'CRMfusionDBR101__Batch_Key_Builder_Data__c','a4p' => 'CRMfusionDBR101__Block_Bypass__c','a4q' => 'CRMfusionDBR101__Convert_Display_Field__c','a4r' => 'CRMfusionDBR101__Country_Mapping__c','a4t' => 'CRMfusionDBR101__FirstName_Mapping__c','a4u' => 'CRMfusionDBR101__Fuzzy_Rule__c','a4v' => 'CRMfusionDBR101__General_Setting__c','a4x' => 'CRMfusionDBR101__Scenario_Target_Filter__c','a4y' => 'CRMfusionDBR101__State_Mapping__c','a4z' => 'CRMfusionDBR101__Web_Lead_Source__c','a50' => 'Related_Content__c','a51' => 'ePrize_Zemzu__Action__c','a52' => 'ePrize_Zemzu__AwardingMethod__c',
                        'a53' => 'ePrize_Zemzu__BehaviorProduct__c','a54' => 'ePrize_Zemzu__BuilderAdmin__c','a55' => 'ePrize_Zemzu__BuilderParticipant__c','a56' => 'ePrize_Zemzu__Builder__c','a57' => 'ePrize_Zemzu__ChatterGroup__c','a58' => 'ePrize_Zemzu__Configuration__c','a59' => 'ePrize_Zemzu__ContestAdmin__c','a5A' => 'ePrize_Zemzu__ContestBuilderSettings__c','a5B' => 'ePrize_Zemzu__ContestUser__c','a5C' => 'ePrize_Zemzu__Contest__c','a5D' => 'ePrize_Zemzu__CustomContestAvailableObject__c','a5E' => 'ePrize_Zemzu__CustomFieldValueFilter__c','a5F' => 'ePrize_Zemzu__EventFilter__c',
                        'a5G' => 'ePrize_Zemzu__FilterField__c','a5H' => 'ePrize_Zemzu__LeadFilter__c','a5I' => 'ePrize_Zemzu__Message__c','a5J' => 'ePrize_Zemzu__MotivateSale__c','a5K' => 'ePrize_Zemzu__NotificationHistory__c','a5L' => 'ePrize_Zemzu__OpportunityFilterProduct__c','a5M' => 'ePrize_Zemzu__OpportunityFilter__c','a5N' => 'ePrize_Zemzu__PipelineBehavior__c','a5O' => 'ePrize_Zemzu__Prize__c','a5P' => 'ePrize_Zemzu__ProductFilterProduct__c','a5Q' => 'ePrize_Zemzu__ProductFilter__c','a5R' => 'ePrize_Zemzu__ProxyObject__c','a5S' => 'ePrize_Zemzu__SCBParticipantProfile__c',
                        'a5T' => 'ePrize_Zemzu__TaskFilter__c','a5U' => 'ePrize_Zemzu__TeamMember__c','a5V' => 'ePrize_Zemzu__Team__c','a5W' => 'ePrize_Zemzu__Win__c','a5X' => 'CHANNEL_ORDERS__Customer__c','a5Y' => 'CHANNEL_ORDERS__Partner_Contract_Terms__c','a5Z' => 'CHANNEL_ORDERS__Partner_Product_Catalog__c','a5b' => 'CHANNEL_ORDERS__Service_Order_Detail__c','a5c' => 'CHANNEL_ORDERS__Service_Order_Log__c','a5d' => 'CHANNEL_ORDERS__Service_Order__c','a5e' => 'Configuration_Manager__c','a5f' => 'ePrize_Zemzu__Survey_Question__c','a5g' => 'ePrize_Zemzu__Survey_Response__c',
                        'a5h' => 'Common_Auth_Site__c','a5i' => 'Community_Profiles__c','a5j' => 'Community_Project_Source__c','a5k' => 'Contact_to_Project_MTM__c','a5l' => 'Out_Of_Office_Comment__c',/*'a5m' => 'Site_URLs__c',*/'a5n' => 'Sync_Field__c','a5o' => 'sfLma__License__c','a5p' => 'sfLma__Package_Version__c','a5q' => 'sfLma__Package__c','a5r' => 'Advisory_Idea_Comment__c','a5s' => 'Advisory_Idea_Team_Member__c','a5t' => 'Advisory_Idea_Vote__c',
                        'a5u' => 'Advisory_Idea__c','a5v' => 'SSO_Settings__c','a5w' => 'MemberInteractionContactMtM__c','a5x' => 'Mailing_List_Settings__c','a5y' => 'Publication_Item__c','a5z' => 'Publication__c',/*'a60' => 'Intranet_Item__c','a61' => 'Intranet_Schedule__c','a62' => 'Intranet_Settings__c','a63' => 'Intranet_Utilization__c',*/'a64' => 'Department_Division_Function__c','a65' => 'ChatterGroupManagement__c','a66' => 'Bundle__c',
                        'a67' => 'Bundled_Siblings__c','a68' => 'c2g__AsOfAgingProcessLog__c','a69' => 'c2g__AsOfAgingReportSettings__c','a6A' => 'c2g__AsOfAgingSettings__c','a6B' => 'c2g__AsOfAging__c','a6C' => 'c2g__BillingSettings__c','a6D' => 'c2g__CancelPaymentLog__c','a6E' => 'c2g__CancelPayment__c','a6G' => 'c2g__WorkerItem__c','a6H' => 'CashMatchingUtiliySettings__c','a6I' => 'c2g__WorkerLogGroup__c','a6J' => 'c2g__WorkerLog__c','a6K' => 'c2g__Worker__c',
                        'a6L' => 'c2g__codaCurrencyRevaluationGLAItem__c','a6M' => 'c2g__codaCurrencyRevaluationGroup__c','a6N' => 'c2g__codaRecordLockGroup__c','a6O' => 'c2g__codaRecordLock__c','a6P' => 'c2g__codaVoidPaymentCriteria__c','a6Q' => 'c2g__codaYearEndLog__c','a6R' => 'c2g__fflib_BatchProcess__c','a6T' => 'ffc__Event__c','a6U' => 'c2g__TaxDetailSalesCreditNote__c','a6V' => 'c2g__TaxDetailSalesInvoice__c','a6W' => 'Site_Profile__c','a6X' => 'Site_User__c','a6Y' => 'Sitecore_Settings__c',
                        'a6Z' => 'AccountRelationship__c','a6a' => 'Field_Trip__Field_Analysis__c','a6b' => 'Field_Trip__Object_Analysis__c','a6c' => 'ffr__ReportingDataRange__c','a6d' => 'ffr__ReportingDefinition__c','a6e' => 'ffr__ReportingFilterMapping__c','a6f' => 'ffr__ReportingFilter__c','a6g' => 'ffr__ReportingLabel__c','a6h' => 'ffr__ReportingLog__c','a6i' => 'ffr__ReportingObject__c','a6j' => 'ffr__ReportingPromptMapping__c','a6k' => 'ffr__ReportingPrompt__c','a6l' => 'ffr__ReportingValue__c',
                        'a6m' => 'ffirule__ClickLinkAnotherSourceTest__c','a6n' => 'ffirule__ClickLinkManagedJob__c','a6o' => 'ffirule__IntegrationRuleAction__c','a6p' => 'ffirule__IntegrationRuleButton__c','a6q' => 'ffirule__IntegrationRuleJob__c','a6r' => 'ffirule__IntegrationRuleLineLookupTest__c','a6s' => 'ffirule__IntegrationRuleLogLineItem__c','a6t' => 'ffirule__IntegrationRuleLog__c','a6u' => 'ffirule__IntegrationRuleLookupTest__c','a6v' => 'ffirule__IntegrationRuleMapping__c','a6w' => 'ffirule__IntegrationRuleRelationship__c','a6x' => 'ffirule__IntegrationRuleSettings__c','a6y' => 'ffirule__IntegrationRuleSourceLineItemTest__c',
                        'a6z' => 'ffirule__IntegrationRuleSourceListViewTest__c','a70' => 'ffirule__IntegrationRuleSourceTest__c','a71' => 'ffirule__IntegrationRuleTargetLineItemTest__c','a72' => 'ffirule__IntegrationRuleTargetTest__c','a74' => 'ffirule__IntegrationRule__c','a76' => 'ShipIt_PackageType__c','a77' => 'ShipIt_Settings__c','a78' => 'ShipIt_ShipMethod__c','a79' => 'Shipment__c','a7A' => 'Attachment__c','a7B' => 'Journal_Batch_Header__c','a7C' => 'Journal_Upload_Lines__c','a7D' => 'Advisory_Event__c',
                        'a7E' => 'Communication_Template__c','a7F' => 'Cost_Center__c','a7G' => 'Event_Budget__c','a7H' => 'Event_Registration__c','a7I' => 'Event_Rule__c','a7J' => 'Expense_Authorization__c','a7K' => 'Registration_Membership__c','a7L' => 'Rule__c','a7M' => 'Team_Member__c','a7N' => 'Venue_Payment__c','a7O' => 'Venue__c','a7P' => 'Feed_Batch__c','a7Q' => 'Feed_Item__c',
                        'a7R' => 'Feed_Transaction__c','a7S' => 'Feed__c','a7T' => 'Program_Hierarchy__c','a7U' => 'Team_Membership__c','a7V' => 'Team_Role__c','a7W' => 'Team_Segment__c','a7X' => 'WorkdayCostCenterSync__c','a7Y' => 'Top_5_Frequently_Accessed_Apps__c','a7Z' => 'ABC_Profile__c','a7a' => 'Provider_Profile__c','a7b' => 'Liquid_Planner_Settings__c','h00' => 'Opportunity__hd','h01' => 'Membership__c_hd',
                        'h02' => 'Project__c_hd','h03' => 'Case__hd'
                };
            }
            
            return prefixToAPINameMap;
        }
        set;
    }
    
    /**
     * 
     * @description: return true if the url variable is populated.  otherwise false.
     * 
     **/
    public boolean enableTracking {
        get {
            return (url != null);
        }
        set;
    }
}