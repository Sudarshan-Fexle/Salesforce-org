/*
    Purpose:        CR-446 - Gives users the ability to generate a sophisticated report on an institution
                    that they can bring with them on in-person visits.
                    
                    CR-1720 - Change the report to be useful for Marketing team.  This type of report will generate
                    when a user clicks the trip prep button from any PT or RI Marketing event/task.
                    
    Created By:     Victor Hanson
    
    Created Date:   3/10/13
    
    Revision Log:   V1.0 - VRH - 4/10/12 - Created      CR-446
                    V1.1 - VRH - 3/19/13 - Modified     CR-1720
                    V1.2 - SUNJ- 12/19/13- Modified     CR-20130118-2218
                    V1.3 - Ajit Surana - 04/26/2014 - Modified GeneratePDF() method - CR-20140411-5049
                    V1.4 - Modified by - Abhinav Sharma - CR-20160127-9565 - 01/29/2016 - Deleted out the grade field reference
                    V1.5 - Modified By Abhinav sharma - 03/27/2018 - CR-20171108-11770 - Avoid the Null pointer Exception - ContractSummaries
                    V1.6 - Modified By - Rajeev Jain - 02/18/2020 - CR-20190929-13381 -  Remove zzzRole(Role__c) field of institution_Role__c object.
    		    V1.7 - Modify By - Abhinav Sharma - 02/04/2020 - CR-20200814-14436 - Finish Deleting Fields from Oct 2020 Release -->
*/
public with sharing class SummaryReportController {
    
    // show/hide appendicies
    public boolean ShowPricingHistory { get; set; }
    public boolean ShowOpportunities { get; set; }
    public boolean ShowAcctMgmtVisits { get; set; }
    public boolean ShowRenewalNotes { get; set; }
    
    // show/hide marketing appendicies
    public boolean ShowRestrictions { get; set; }
    public boolean ShowMap { get; set; }
    public boolean ShowWarmLeads { get; set; }
    public boolean ShowMarketingOpps { get; set; }
    public boolean ShowAcctMgmtPhoneCalls { get; set; }
    
    public boolean ShowUtilizationSnapshot { get; set; }
    private Id EventId { get; set; }
    public double TotalMembershipAmt { get; set; }
    public integer TotalMembers { get; set; }
    
    // used to display the pricing history
    public class PricingHistoryWrapper {
        public string ReportingVertical { get; set; }
        public double PoolTotal { get; set; }
        public double PoolYear1Total { get; set; }
        public double PoolYear2Total { get; set; }
        public double PoolYear3Total { get; set; }
        public double PoolYear4Total { get; set; }
        public double PoolYear5Total { get; set; }
        public double PoolYear6Total { get; set; }
        public double PoolYear7Total { get; set; }
        public Map<String, PricingHistory> phMap {
            get {
                if (phMap == null) {
                    phMap = new Map<String, PricingHistory>();
                }
                return phMap;
            }
            set;
        }
        public List<PricingHistory> phList {
            get {
                if (phList == null) {
                    phList = new List<PricingHistory>();
                }
                return phList;
            }
            set;
        }
        // set some defaults in the constructor
        public PricingHistoryWrapper() {
            ReportingVertical = '';
            PoolTotal = 0;
            PoolYear1Total = 0;
            PoolYear2Total = 0;
            PoolYear3Total = 0;
            PoolYear4Total = 0;
            PoolYear5Total = 0;
            PoolYear6Total = 0;
            PoolYear7Total = 0;
        }
    }
    
    // class used to show Pricing History
    public class PricingHistory {
        public String ReportingVertical { get; set; }
        public String ProgramAcronym { get; set;}
        public double PoolYear1 { get; set; }
        public double PoolYear2 { get; set; }
        public double PoolYear3 { get; set; }
        public double PoolYear4 { get; set; }
        public double PoolYear5 { get; set; }
        public double PoolYear6 { get; set; }
        public double PoolYear7 { get; set; }
        public double ProgramTotal { get; set; }
        
        public PricingHistory() {
            ReportingVertical = '';
            ProgramAcronym = '';
            ProgramTotal = 0;
            PoolYear1 = 0;
            PoolYear2 = 0;
            PoolYear3 = 0;
            PoolYear4 = 0;
            PoolYear5 = 0;
            PoolYear6 = 0;
            PoolYear7 = 0;
        }
    }
    
    public Boolean IsMarketingEvent {
        get {
            if (IsMarketingEvent == null && EventId != null) {
                // get the event's record type
                Event event = [SELECT Id, RecordType.Name FROM Event WHERE Id = :EventId ALL ROWS];
                if (event.RecordType.Name.contains('Marketing')) IsMarketingEvent = true;
                else IsMarketingEvent = false;
            }
            return IsMarketingEvent;
        }
        set;
    }
    
    public Map<String, PricingHistory> PricingHistoryMap {
        get {
            if (PricingHistoryMap == null) {
                PricingHistoryMap = new Map<String, PricingHistory>();
            }
            return PricingHistoryMap;
        }
        set;
    }
    
    public List<PricingHistory>  PricingHistoryList {
        get {
            if (PricingHistoryList == null) {
                PricingHistoryList = new List<PricingHistory>();
            }
            return PricingHistoryList;
        }
        set;
    }
    
    // class used to summarize the utilization summary by program for contact
    public class UtilizationSummary {
        public String ProgramName { get; set; }
        public String ProgramAcronym { get; set;}
        public String BusinessLine { get; set;}
        public String MarketSegment { get; set; }
        public String UtilizationMetric { get; set; }
        public Integer PastMeetings { get; set; }
        public Integer FutureMeetings { get; set; }
        public Integer PastTeleconf { get; set; }
        public Integer FutureTeleconf { get; set; }
        public Integer ContractValue { get; set; }
        public Integer ActiveMemberships { get; set; }
        public Integer PubReorder { get; set; }
        public Integer Onsite { get; set; }
        public Integer DAGTool { get; set; }
        public Integer ExpertCenter { get; set; }
        
        public UtilizationSummary() {
            UtilizationMetric = '';
            ProgramName = '';
            ProgramAcronym = '';
            BusinessLine = '';
            PastMeetings = 0;
            FutureMeetings = 0;
            PastTeleconf = 0;
            FutureTeleconf = 0;
            ContractValue = 0;
            ActiveMemberships = 0;
            PubReorder = 0;
            Onsite = 0;
            DAGTool = 0;
            ExpertCenter = 0;
            
        }
    }
    
    
    
    public Membership__c mainMembership {
        get {
            if (mainMembership == null) {
                mainMembership = new Membership__c();
                if (mainEvent.What.Type == 'Membership__c') {
                    List<Membership__c> memberships = [SELECT Name, Id, Account_Name__c, Payer_Status__c, Membership_Status__c, Start_Date_on_First_Contract__c, End_Date_on_Last_Contract__c,
                    (SELECT Contact__r.Name, Meetings__c, Membership__c, Pubs__c, Role__c, Role_Type__c FROM Membership_Key_Contacts__r)
                    FROM Membership__c WHERE Id = :mainEvent.WhatId LIMIT 1000];
                    if (memberships.size() > 0)
                        mainMembership = memberships[0];
                }
                else if (mainEvent.What.Type == 'Opportunity') {
                    List<Membership__c> memberships = [SELECT Name, Id, Account_Name__c, Payer_Status__c, Membership_Status__c, Start_Date_on_First_Contract__c, End_Date_on_Last_Contract__c,
                    (SELECT Contact__r.Name, Meetings__c, Membership__c, Pubs__c, Role__c, Role_Type__c FROM Membership_Key_Contacts__r)
                    FROM Membership__c WHERE Id = :mainOpportunity.Membership__c LIMIT 1000];
                    if (memberships.size() > 0)
                        mainMembership = memberships[0];
                }
            }
            return mainMembership;
        }
        set;
    }
    
    public Opportunity mainOpportunity {
        get {
            if (mainOpportunity == null) {
                mainOpportunity = new Opportunity();
                if (mainEvent.What.Type == 'Opportunity') {
                    List<Opportunity> opps = [SELECT Name, Id, Membership__c, Program__r.Name, Primary_Competitor__c, Marketer__r.Name, Marketing_Associate__r.Name, Initial_Visit_Date__c, Owner.Name, Next_Step_Date__c, Risk_Notes__c, 
                                            Renewal_Contract_Strategy__c, Description, Next_Steps_Text__c, Contract_Strategy_Determined__c, Next_PA_Date__c, 
                                            AccountId, StageName, CloseDate, Amount, Main_Contact__r.Name, Probability, 
                    (SELECT Contact.Name, Role, IsPrimary FROM OpportunityContactRoles), 
                    (SELECT Name, Lead_Channel__c, Campaign__r.Name, Contact__r.Name, Qualification_Status__c, Comments__c FROM Warm_Leads__r ORDER BY CreatedDate ASC LIMIT 100)
                    FROM Opportunity WHERE Id = :mainEvent.WhatId LIMIT 1000];
                    if (opps.size() > 0)
                        mainOpportunity = opps[0]; 
                }
            }
            return mainOpportunity;
        }
        set;
    }
    
    public List<Event> AcctMgmtVisits {
        get {
            if (AcctMgmtVisits == null) {
                AcctMgmtVisits = new List<Event>();
                if (AllOpportunities.size() > 0) {
                    if (IsMarketingEvent) {
                        AcctMgmtVisits = [SELECT Who.Name, What.Name, Event_Type__c, ActivityDate, Subject, Owner.Name
                                        FROM Event WHERE WhatId IN :AllOpportunities AND ActivityDate >= LAST_N_DAYS:60 ORDER BY ActivityDate DESC LIMIT 1000 ALL ROWS];
                    }
                    else {
                        AcctMgmtVisits = [SELECT Who.Name, What.Name, Event_Type__c, ActivityDate, Subject, Owner.Name
                                        FROM Event WHERE WhatId IN :AllOpportunities AND ActivityDate >= LAST_N_YEARS:2 ORDER BY ActivityDate DESC LIMIT 1000 ALL ROWS];
                    }
                }
            }
            return AcctMgmtVisits;
        }
        set;
    }
    
    public List<Event> AcctMgmtPhoneCalls {
        get {
            if (AcctMgmtPhoneCalls == null) {
                List<Opportunity> opportunities = [SELECT Id FROM Opportunity WHERE (NOT StageName LIKE '%closed') AND AccountId = :MainAccount.Id LIMIT 1000];
                // get all memberships for the institution
                Set<Id> oppAndMembershipIdSet = new Set<Id>();
                for (Membership__c pastMem : PastMemberships)   oppAndMembershipIdSet.add(pastMem.Id);
                for (Membership__c curMem : CurrentMemberships) oppAndMembershipIdSet.add(curMem.Id);
                for (Opportunity opp : opportunities)           oppAndMembershipIdSet.add(opp.Id);
                
                AcctMgmtPhoneCalls = [SELECT Who.Name, What.Name, Event_Type__c, Event_Purpose__c, ActivityDate, Subject, Owner.Name
                                    FROM Event WHERE WhatId IN :oppAndMembershipIdSet AND ActivityDate >= LAST_N_DAYS:30 AND Id != :EventId ORDER BY ActivityDate DESC LIMIT 1000 ALL ROWS];
            }
            return AcctMgmtPhoneCalls;
        }
        set;
    }
    
    public List<Opportunity> WonOpportunities {
        get {
            if (WonOpportunities == null) {
                WonOpportunities = new List<Opportunity>();
                String SixYearsAgo = string.valueOf(system.today().addYears(-6));
                String ThisYear = string.valueOf(system.today().year());
                WonOpportunities = [SELECT Name, Program__c, Id, Amount, Account_Management_Reporting_Vertical__c, Pool_Year__c, Program_Acronym__c
                                FROM Opportunity
                                WHERE (StageName = 'ATL' OR StageName LIKE '%Won%') AND Program_Acronym__c != null AND Account_Management_Reporting_Vertical__c != null AND AccountId = :mainAccount.Id AND Pool_Year__c >= :SixYearsAgo AND Pool_Year__c <= :ThisYear ORDER BY Account_Management_Reporting_Vertical__c ASC LIMIT 1000];
            }
            return WonOpportunities;
        }
        set;
    }
    
    public List<Utilization_Data_Object__c> TeleconferenceUtilizations {
        get {
            if (TeleconferenceUtilizations == null) {
                TeleconferenceUtilizations = new List<Utilization_Data_Object__c>();
                TeleconferenceUtilizations = [SELECT Event_Name__c, Start_Date__c, Program__c, Status__c, Contact_Name__c, Contact_Title__c
                                            FROM Utilization_Data_Object__c WHERE (Payer_Institution__c = :mainAccount.Id OR Institution__c = :mainAccount.Id) AND Start_Date__c >= LAST_N_YEARS:1 AND Start_Date__c < TODAY ORDER BY Start_Date__c DESC LIMIT 1000];
            }
            return TeleconferenceUtilizations;
        }
        set;
    }
    
    public List<Meeting_Utilization__c> MembershipUtilizations {
        get {
            if (MembershipUtilizations == null) {
                MembershipUtilizations = new List<Meeting_Utilization__c>();
                MembershipUtilizations = [SELECT Event_Name__c, Program__c, Status__c, Start_Date__c, Contact_Name__c, Contact_Title__c
                                        FROM Meeting_Utilization__c WHERE Payer_Institution__c = :mainAccount.Id AND Start_Date__c >= LAST_N_YEARS:1 AND Start_Date__c < TODAY ORDER BY Start_Date__c DESC LIMIT 1000];
            }
            return MembershipUtilizations;
        }
        set;
    }
    
    public List<Other_Utilization__c> OtherUtilizations {
        get {
            if (OtherUtilizations == null) {
                OtherUtilizations = new List<Other_Utilization__c>();
                OtherUtilizations = [SELECT Event_Name__c, Program__c, Status__c, Utilization_Metric__c,
                                     Start_Date__c, Contact_Name__c, Contact_Title__c, Payer_Institution__c, Contact__c
                                     FROM Other_Utilization__c
                                     WHERE ((Institution__c != null AND Institution__c = :mainAccount.Id)
                                         OR (Payer_Institution__c != null AND Payer_Institution__c = :mainAccount.Id)
                                         OR (Contact__c != null AND Contact__c = :mainContact.Id)
                                         //OR (Contact_Name__c != null AND Contact_Name__c = :mainContact.Name)
                                     )
                                     AND Start_Date__c >= LAST_N_YEARS:1 AND Start_Date__c < TODAY ORDER BY Start_Date__c DESC LIMIT 1000];
            }
            return OtherUtilizations;
        }
        set;
    }
    
    public List<Other_Utilization__c> PubReorderUtilizations { 
        get {
            if (PubReorderUtilizations == null)
                PubReorderUtilizations = new List<Other_Utilization__c>();
            return PubReorderUtilizations;
        }
        set;
    }
    
    public List<Other_Utilization__c> OnsiteUtilizations { 
        get {
            if (OnsiteUtilizations == null)
                OnsiteUtilizations = new List<Other_Utilization__c>();
            return OnsiteUtilizations;
        }
        set;
    }
    
    public List<Other_Utilization__c> DAGToolUtilizations { 
        get {
            if (DAGToolUtilizations == null)
                DAGToolUtilizations = new List<Other_Utilization__c>();
            return DAGToolUtilizations;
        }
        set;
    }
    
    public List<Other_Utilization__c> ExpertCenterUtilizations { 
        get {
            if (ExpertCenterUtilizations == null)
                ExpertCenterUtilizations = new List<Other_Utilization__c>();
            return ExpertCenterUtilizations;
        }
        set;
    }
    
    public List<Opportunity> RenewalOpportunities {
        get {
            if (RenewalOpportunities == null) {
                RenewalOpportunities = new List<Opportunity>();
                RenewalOpportunities = [SELECT Name, Owner.Name, Program__c, CloseDate, Amount, Probability, StageName, Description, Program__r.Name
                    FROM Opportunity WHERE AccountId = :mainAccount.Id AND StageName LIKE '%Pending%' AND Type2__c LIKE 'Renewal' AND CreatedDate >= LAST_N_YEARS:1
                    ORDER BY CloseDate DESC LIMIT 1000];
            }
            return RenewalOpportunities;
        }
        set;
    }
    
    public List<Opportunity> AllOpportunities {
        get {
            if (AllOpportunities == null) {
                AllOpportunities = new List<Opportunity>();
                if (mainAccount != null) {
                    AllOpportunities = [SELECT Name, Owner.Name,Program__c, CloseDate, Amount, StageName, Program__r.Name
                    FROM Opportunity WHERE AccountId = :mainAccount.Id AND (StageName = 'Initial Visit Scheduled' OR StageName = 'Active in FastTrack' OR StageName = 'Active in SlowTrack' OR StageName = 'Verbal Yes')
                    ORDER BY CloseDate DESC LIMIT 1000];
                }
            }
            return AllOpportunities;
        }
        set;
    }
    
    public List<Opportunity> PastFiveOppsForSameProduct {
        get {
            if (PastFiveOppsForSameProduct == null) {
                PastFiveOppsForSameProduct = [SELECT Name, Owner.Name, Program__c, CloseDate, Marketer__r.Name, Amount, Primary_Reason_Lost__c,
                                            StageName, Program__r.Name, Closed_Opp_Comments__c, Main_Contact__r.Name
                                            FROM Opportunity 
                                            WHERE AccountId = :mainAccount.Id AND Program__c = :mainOpportunity.Program__c AND Id != :mainOpportunity.Id
                                            ORDER BY CloseDate DESC LIMIT 5];
            }
            return PastFiveOppsForSameProduct;
        }
        set;
    }
    
    public List<Membership__c> PastMemberships {
        get {
            if (PastMemberships == null) {
                PastMemberships = new List<Membership__c>();
                PastMemberships = [SELECT Id, Name, Program__r.Name, Renewal_Opp_Owner__c, Membership_Status__c, End_Date_on_Last_Contract__c FROM Membership__c WHERE Account_Name__c = :mainAccount.Id AND End_Date_on_Last_Contract__c < TODAY  ORDER BY End_Date_on_Last_Contract__c DESC LIMIT 1000];
            }
            return PastMemberships;
        }
        set;
    }
    
    public List<Membership__c> CurrentMemberships {
        get {
            if (CurrentMemberships == null) {
                CurrentMemberships = new List<Membership__c>();
                CurrentMemberships = [SELECT Id, Name, Renewal_Opp_Owner__c, DA_Assignment2__r.Name, BA_Assignment2__r.Name, Program__c, Program__r.Name, Membership_Status__c, End_Date_on_Last_Contract__c FROM Membership__c WHERE Account_Name__c = :mainAccount.Id AND Membership_Status__c LIKE 'Member%' ORDER BY End_Date_on_Last_Contract__c DESC LIMIT 1000];
            }
            return CurrentMemberships;
        }
        set;
    }
    
    public List<Opportunity> ActiveMarketingOpps {
        get {
            if (ActiveMarketingOpps == null) {
                ActiveMarketingOpps = [SELECT Name, CloseDate, Owner.Name, Marketing_Associate__r.Name, StageName, Probability, Next_Steps_Text__c
                                    FROM Opportunity
                                    WHERE AccountId = :mainAccount.Id
                                    AND (StageName = 'Initial Visit Scheduled' OR StageName = 'Active in FastTrack' OR StageName = 'Active in SlowTrack' OR StageName = 'Verbal Yes' OR StageName LIKE 'Sent To Finance%')];
            }
            return ActiveMarketingOpps;
        }
        set;
    }
    
     //Remove the fields from the query "Primary_GPO__c,Number_of_Employed_Docs__c,Surgeries_2__c,ED_Visits__c,Admissions__c" as delete from the CR-20190425-13032
    
    public Account mainAccount {
        get {
            if (mainAccount == null) {
                mainAccount = new Account();
                //Modify By - Abhinav Sharma - 02/04/2020 - CR-20200814-14436 - Finish Deleting Fields from Oct 2020 Release (Remove Provider_Type__c on Account from Query at line no 444)
                String query = 'SELECT Name,Id, Account_Formal_Name__c,Primary_Address_Line_1__c,Primary_City__c,Primary_State_Province__c,Primary_Postal_Code__c,ParentId,BI_Market_Segment__c,Core_Market_Segment__c,Account_Restriction_Status_2__c,' +
                                'Website,Students__c,Account_Restriction_Status__c,Number_of_Hospitals_in_System__c,NumberOfEmployees,Fiscal_Year__c,' +
                                'Operating_Expense_In_Thousands__c,System_Status__c,Description,Bed_Size__c,Fundraising_FTEs__c,' +
                                '(SELECT Id,Contact__r.Name FROM Account_Roles__r LIMIT 100),' +
                                '(SELECT Id,Start_Date__c,Program__c,Name FROM Meeting_Utilization1__r WHERE Start_Date__c >= LAST_N_YEARS:1 LIMIT 100),' +
                                '(SELECT Id,Start_Date__c,Program__c,Name FROM Teleconference_Utilization1__r WHERE Start_Date__c >= LAST_N_YEARS:1 LIMIT 100),' +
                                '(SELECT Id,Utilization_Metric__c, Program__c, Name FROM Other_Utilization__r WHERE Start_Date__c <= TODAY AND Start_Date__c >= LAST_N_YEARS:1 LIMIT 100),' + // get the last year of other utilizations
                                '(SELECT Id,Restriction__c,Restriction__r.Reason__c,Restriction__r.Category__c,Restriction__r.Source_Department__c,Restriction__r.Name, Restriction__r.Owner.Name, Restriction__r.Comments__c, Restriction__r.Expiration_Date__c FROM Restrictions_MtM__r WHERE (Restriction__r.Expiration_Date__c = null OR Restriction__r.Expiration_Date__c > TODAY) AND Restriction_Expired__c = false)' +
                                //'(SELECT Id, Name, Program__r.Name, Membership_Status__c, End_Date_on_Last_Contract__c FROM Memberships__r ORDER BY End_Date_on_Last_Contract__c DESC)' +
                                'FROM Account WHERE ';
                // determine what object the event is associated with, so that we get the correct account
                system.debug('@@WhatType: ' + mainEvent.What.Type);
                if (mainEvent.What.Type == 'Account')
                    query += 'id = \'' + mainEvent.WhatId + '\'';
                else if (mainEvent.What.Type == 'Opportunity')
                    query += 'id = \'' + mainOpportunity.AccountId + '\'';
                else if (mainEvent.What.Type == 'Membership__c')
                    query += 'id = \'' + mainMembership.Account_Name__c + '\'';
                else // error scenario
                    return mainAccount;
                   
                system.debug('@@QUERY: ' + query);
                List<Account> accounts = database.query(query);
                if (accounts.size() > 0)
                    mainAccount = accounts[0];
            }
            return mainAccount;
        }
        set;
    }
    
    boolean mainContactQueried = false;
    public Contact mainContact {
        get {
            if (mainContact == null && !mainContactQueried) {
                mainContact = new Contact();
                List<Contact> contacts = [SELECT Name, Id, AssistantName, AssistantPhone, Description, Phone, Title, ReportsTo.Name FROM Contact WHERE Id = :mainEvent.WhoId LIMIT 1000];
                mainContactQueried = true;
                if (contacts.size() > 0) {
                    mainContact = contacts[0];
                }
            }
            return mainContact;
        }
        set;
    }
    
    public Event mainEvent {
        get {
            if (mainEvent == null) {
                mainEvent = new Event();
                if (EventId != null) {
                    Set<String> extraFields = new Set<String> {'What.Name', 'Who.Phone', 'Who.Title', 'What.Type' };
                    string queryString = FieldDescribes.FullItemBaseQuery('Event', extraFields) + ' WHERE Id = \'' + EventId + '\'';
                    List<Event> events = database.query(queryString);
                    if (events.size() > 0)
                        mainEvent = events[0];
                }
            }
            return mainEvent;
        }
        set;
    }
    
    public Account ParentAccount {
        get {
            if (ParentAccount == null) {
                ParentAccount = new Account();
                List<Account> accts = [SELECT Name, Id FROM Account WHERE Id = :ParentAccountId LIMIT 1000];
                
                if (accts.size() > 0)
                    ParentAccount = accts[0];
            }
            return ParentAccount;
        }
        set;
    }
    
    public List<Account> ChildAccounts {
        get {
            if (ChildAccounts == null) {
                ChildAccounts = new List<Account>();
                List<Account> accts = [SELECT Name, Id, ParentId FROM Account WHERE ParentId = :ParentAccount.Id LIMIT 1000];
                if (accts.size() > 0)
                    ChildAccounts = accts;
            }
            return ChildAccounts;
        }
        set;
    }
    public List<Account> GrandChildAccounts {
        get {
            if (GrandChildAccounts == null) {
                GrandChildAccounts = new List<Account>();
                if (ChildAccounts.size() > 0) {
                    Set<Id> childAcctIds = new Set<Id>();
                    for (Account a : ChildAccounts)
                        childAcctIds.add(a.Id);
                    List<Account> accts = [SELECT Name, Id, ParentId FROM Account WHERE ParentId IN :childAcctIds LIMIT 1000];
                    if (accts.size() > 0)
                        GrandChildAccounts = accts;
                }
                
            }
            return GrandChildAccounts;
        }
        set;
    }
    
    private Id ParentAccountId {
        get {
            if (ParentAccountId == null) {
                // if the current account is the parent, great
                if (mainAccount.parentId == null) {
                    ParentAccountId = mainAccount.Id;
                }
                else {// otherwise we need to find the parent.  Note: this assumes only parent/child, doesn't go to grandchild accts
                    ParentAccountId = mainAccount.ParentId;
                }
            }
            return ParentAccountId;
        }
        set;
    }
    
    //Modified "summaryReportURL" parameter - Ajit Surana - 04/26/2014 - CR-20140411-5049
    // generate the pdf
    public PageReference GeneratePDF() {
        String summaryReportURL = Page.SummaryReport.getURL();
        if (IsMarketingEvent)
            summaryReportURL = Page.SummaryReport_Marketing.getURL();
        PageReference pg = new PageReference(summaryReportURL + '?id=' + mainEvent.Id);
        pg.setRedirect(false);
        return pg;
    }
    
    public boolean HasErrors { get; set; }
    
    public pageReference IsValid() {
        try {
            if (mainAccount.Id != null)
                return null;
            else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The event\'s related to field must reference an Opportunity, Account, or Membership.   Please contact <a href="mailto:salesforcehelp@advisory.com?Subject=Error when adding/updating event">salesforcehelp@advisory.com</a> with any questions.'));
                HasErrors = true;
            }
        }
        catch(exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The event\'s related to field must reference an Opportunity, Account, or Membership.   Please contact <a href="mailto:salesforcehelp@advisory.com?Subject=Error when adding/updating event">salesforcehelp@advisory.com</a> with any questions.'));
            HasErrors = true;
        }
        return null;
    }
    
    // constructor
    public SummaryReportController() {
        // set the Event ID
        EventId = ApexPages.currentPage().getParameters().get('Id');
        
        // make sure there is a "Related To" value
        if (mainEvent.WhatId != null) {
            FindMeetingUtilizations();
            FindInstitutionUtilizations();
            FindPricingHistory();
        }
    }
    
    public String TodaysDate {
        get {
            if (TodaysDate == null) {
                TodaysDate = system.now().format('MM/dd/yyyy');
            }
            return TodaysDate;
        }
        set;
    }
    
    // list of utilization records associated with the main Account (institution) record
    public List<UtilizationSummary> InstitutionUtilizations {
        get {
            if (InstitutionUtilizations == null)
                InstitutionUtilizations = new List<UtilizationSummary>();
            return InstitutionUtilizations;
        }
        set;
    }
    
    public string PoolYear1Label {
        get {
            if (PoolYear1Label == null) {
                PoolYear1Label = string.valueOf(system.today().addYears(-6).year());
            }
            return PoolYear1Label;
        }
        set;
    }
    
    public string PoolYear2Label {
        get {
            if (PoolYear2Label == null) {
                PoolYear2Label = string.valueOf(system.today().addYears(-5).year());
            }
            return PoolYear2Label;
        }
        set;
    }
    
    public string PoolYear3Label {
        get {
            if (PoolYear3Label == null) {
                PoolYear3Label = string.valueOf(system.today().addYears(-4).year());
            }
            return PoolYear3Label;
        }
        set;
    }
    
    public string PoolYear4Label {
        get {
            if (PoolYear4Label == null) {
                PoolYear4Label = string.valueOf(system.today().addYears(-3).year());
            }
            return PoolYear4Label;
        }
        set;
    }
    
    public string PoolYear5Label {
        get {
            if (PoolYear5Label == null) {
                PoolYear5Label = string.valueOf(system.today().addYears(-2).year());
            }
            return PoolYear5Label;
        }
        set;
    }
    
    public string PoolYear6Label {
        get {
            if (PoolYear6Label == null) {
                PoolYear6Label = string.valueOf(system.today().addYears(-1).year());
            }
            return PoolYear6Label;
        }
        set;
    }
    
    public string PoolYear7Label {
        get {
            if (PoolYear7Label == null) {
                PoolYear7Label = string.valueOf(system.today().year());
            }
            return PoolYear7Label;
        }
        set;
    }
    
    
    
    public List<PricingHistoryWrapper> PHWrapperList {
        get {
            if (PHWrapperList == null) {
                PHWrapperList = new List<PricingHistoryWrapper>();
            }
            return PHWrapperList;
        }
        set;
    }
    
    private map<String, PricingHistoryWrapper> PHWrapperMap {
        get {
            if (PHWrapperMap == null)
                PHWrapperMap = new map<String, PricingHistoryWrapper>();
            return PHWrapperMap;
        }
        set;
    }
    
    private Map<String, UtilizationSummary> ContactUtilizationMap {
        get {
            if (ContactUtilizationMap == null)
                ContactUtilizationMap = new Map<String, UtilizationSummary>();
            return ContactUtilizationMap;
        }
        set;
    }
    
    public List<UtilizationSummary> ContactUtilizationList {
        get {
            if (ContactUtilizationList == null)
                ContactUtilizationList = new List<UtilizationSummary>();
            return ContactUtilizationList;
        }
        set;
    }
    
    private void FindPricingHistory() {
        
        for (Opportunity opp : WonOpportunities) {
            PricingHistoryWrapper phWrapper = PHWrapperMap.get(opp.Account_Management_Reporting_Vertical__c);
            // get the pricing history wrapper or create one if it doesn't exist
            if (phWrapper == null) {
                phWrapper = new PricingHistoryWrapper();
                phWrapper.ReportingVertical = opp.Account_Management_Reporting_Vertical__c;
            }
            // get the pricing history records
            PricingHistory pHistory = phWrapper.phMap.get(opp.Program_Acronym__c);
            if (pHistory == null) {
                pHistory = new PricingHistory();
                pHistory.ProgramAcronym = opp.Program_Acronym__c;
                pHistory.ReportingVertical = opp.Account_Management_Reporting_Vertical__c;
            }
            
            // replace null amounts with zero
            if (opp.Amount == null)
                opp.Amount = 0;
            
            // add amount to Program total
            pHistory.ProgramTotal += opp.Amount;
            
            // get grand total
            phWrapper.PoolTotal += opp.Amount;
            
            // figure out the pool year totals
            if (opp.Pool_Year__c == PoolYear1Label) {
                pHistory.PoolYear1 += opp.Amount;
                phWrapper.PoolYear1Total += opp.Amount;
            }
            if (opp.Pool_Year__c == PoolYear2Label) {
                pHistory.PoolYear2 += opp.Amount;
                phWrapper.PoolYear2Total += opp.Amount;
            }
            if (opp.Pool_Year__c == PoolYear3Label) {
                pHistory.PoolYear3 += opp.Amount;
                phWrapper.PoolYear3Total += opp.Amount;
            }
            if (opp.Pool_Year__c == PoolYear4Label) {
                pHistory.PoolYear4 += opp.Amount;
                phWrapper.PoolYear4Total += opp.Amount;
            }
            if (opp.Pool_Year__c == PoolYear5Label) {
                pHistory.PoolYear5 += opp.Amount;
                phWrapper.PoolYear5Total += opp.Amount;
            }
            if (opp.Pool_Year__c == PoolYear6Label) {
                pHistory.PoolYear6 += opp.Amount;
                phWrapper.PoolYear6Total += opp.Amount;
            }
            if (opp.Pool_Year__c == PoolYear7Label) {
                pHistory.PoolYear7 += opp.Amount;
                phWrapper.PoolYear7Total += opp.Amount;
            }
            
            phWrapper.phMap.put(opp.Program_Acronym__c, pHistory);
            PHWrapperMap.put(opp.Account_Management_Reporting_Vertical__c, phWrapper);
        }
        
        if (PHWrapperMap.size() > 0) {
            for (PricingHistoryWrapper phw : PHWrapperMap.values()) {
                if (phw.phMap.size() > 0)
                    phw.phList.addAll(phw.phMap.values());
            }
            PHWrapperList.addAll(PHWrapperMap.values());
        }
        
    }
    
    private void FindInstitutionUtilizations() {
        Map<String, UtilizationSummary> utilizationMap = new Map<String, UtilizationSummary>();
        
        // check for null first
        
        if (mainAccount == null) return;
        
        for (Meeting_Utilization__c meeting : mainAccount.Meeting_Utilization1__r) {
            UtilizationSummary summary = utilizationMap.get(meeting.Program__c);
            if (summary == null) {
                summary = new UtilizationSummary();
                summary.ProgramName = meeting.Program__c;
            }
            if (meeting.Start_Date__c < system.today())
                summary.PastMeetings++;
            else
                summary.FutureMeetings++;
                
            utilizationMap.put(summary.ProgramName, summary);
        }
        
        for (Utilization_Data_Object__c teleconf : mainAccount.Teleconference_Utilization1__r) {
            UtilizationSummary summary = utilizationMap.get(teleconf.Program__c);
            if (summary == null) {
                summary = new UtilizationSummary();
                summary.ProgramName = teleconf.Program__c;
            }
            if (teleconf.Start_Date__c < system.today())
                summary.PastTeleconf++;
            else
                summary.FutureTeleconf++;
                
            utilizationMap.put(summary.ProgramName, summary);
        }
        
        for (Other_Utilization__c other : mainAccount.Other_Utilization__r) {
            UtilizationSummary summary = utilizationMap.get(other.Program__c);
            if (summary == null) {
                summary = new UtilizationSummary();
                summary.ProgramName = other.Program__c;
                summary.UtilizationMetric = other.Utilization_Metric__c;
            }
            if (other.Utilization_Metric__c == 'Publication Reorders')
                summary.PubReorder++;
            else if (other.Utilization_Metric__c == 'Onsites')
                summary.Onsite++;
            else if (other.Utilization_Metric__c == 'Advisory.com Tools')
                summary.DAGTool++;
            else if (other.Utilization_Metric__c == 'The Expert Center')
                summary.ExpertCenter++;
                
            utilizationMap.put(summary.ProgramName, summary);
        }
        
        InstitutionUtilizations.addAll(utilizationMap.values());
    }
    
    private void FindMeetingUtilizations() {
        
        // get past meeting utilizations
        List<aggregateResult> results = [select Program__c,count(Id) from Meeting_Utilization__c
                                        WHERE Contact__c = :mainContact.Id AND Start_Date__c < TODAY GROUP BY Program__c];
        system.debug('@@MeetingUtilizations:' + results);
        for (AggregateResult ar : results) {
            UtilizationSummary summary = ContactUtilizationMap.get((String)ar.get('Program__c'));
            if (summary == null)
                summary = new UtilizationSummary();
                
            summary.PastMeetings = (Integer)ar.get('expr0');
            summary.ProgramName = (String)ar.get('Program__c');
            ContactUtilizationMap.put((String)ar.get('Program__c'), summary);
        }
        
        // get future meeting utilizations
        results = [select Program__c,count(Id) from Meeting_Utilization__c
                                        WHERE Contact__c = :mainContact.Id AND Start_Date__c >= TODAY GROUP BY Program__c];
        for (AggregateResult ar : results) {
            UtilizationSummary summary = ContactUtilizationMap.get((String)ar.get('Program__c'));
            if (summary == null)
                summary = new UtilizationSummary();
                
            summary.FutureMeetings = (Integer)ar.get('expr0');
            summary.ProgramName = (String)ar.get('Program__c');
            ContactUtilizationMap.put((String)ar.get('Program__c'), summary);
        }
        
        // get past Teleconference utilizations
        results = [select Program__c,count(Id) from Utilization_Data_Object__c
                                        WHERE Contact__c = :mainContact.Id AND Contact__c != null AND Start_Date__c < TODAY GROUP BY Program__c];
        for (AggregateResult ar : results) {
            UtilizationSummary summary = ContactUtilizationMap.get((String)ar.get('Program__c'));
            if (summary == null)
                summary = new UtilizationSummary();
                
            summary.PastTeleconf = (Integer)ar.get('expr0');
            summary.ProgramName = (String)ar.get('Program__c');
            ContactUtilizationMap.put((String)ar.get('Program__c'), summary);
        }
        
        // get future Teleconference utilizations
        results = [select Program__c, Utilization_Metric__c,count(Id) from Other_Utilization__c
                WHERE (Contact__c = :mainContact.Id OR Contact_Name__c = :mainContact.Name) and Contact__c != null AND Start_Date__c >= LAST_N_YEARS:1 AND Start_Date__c <= TODAY
                GROUP BY Program__c,Utilization_Metric__c LIMIT 10000];
        for (AggregateResult ar : results) {
            UtilizationSummary summary = ContactUtilizationMap.get((String)ar.get('Program__c'));
            if (summary == null)
                summary = new UtilizationSummary();
            
            
            if ((String)ar.get('Utilization_Metric__c') == 'Publication Reorders')
                summary.PubReorder++;
            else if ((String)ar.get('Utilization_Metric__c') == 'Onsites')
                summary.Onsite++;
            else if ((String)ar.get('Utilization_Metric__c') == 'Advisory.com Tools')
                summary.DAGTool++;
            else if ((String)ar.get('Utilization_Metric__c') == 'The Expert Center')
                summary.ExpertCenter++;
            
            
            summary.FutureTeleconf = (Integer)ar.get('expr0');
            summary.ProgramName = (String)ar.get('Program__c');
            ContactUtilizationMap.put((String)ar.get('Program__c'), summary);
        }
        
        // get the last 1 year of Other utilizations
        results = [select Program__c,count(Id) from Utilization_Data_Object__c
                WHERE (Contact__c = :mainContact.Id OR Contact_Name__c = :mainContact.Name) AND Start_Date__c >= TODAY GROUP BY Program__c];
        for (AggregateResult ar : results) {
            UtilizationSummary summary = ContactUtilizationMap.get((String)ar.get('Program__c'));
            if (summary == null)
                summary = new UtilizationSummary();
                
            summary.FutureTeleconf = (Integer)ar.get('expr0');
            summary.ProgramName = (String)ar.get('Program__c');
            ContactUtilizationMap.put((String)ar.get('Program__c'), summary);
        }
        
        // set the map in to a list so it can be displayed on the vf page
        if (ContactUtilizationMap.size() > 0)
            ContactUtilizationList = ContactUtilizationMap.values();
        
        
        // setup all of the "Other" Utilization lists
        
        for (Other_Utilization__c otherUtil : OtherUtilizations) {
            if (otherUtil.Utilization_Metric__c == 'Publication Reorders')
                PubReorderUtilizations.add(otherUtil);
            else if (otherUtil.Utilization_Metric__c == 'Onsites')
                OnsiteUtilizations.add(otherUtil);
            else if (otherUtil.Utilization_Metric__c == 'Advisory.com Tools')
                DAGToolUtilizations.add(otherUtil);
            else if (otherUtil.Utilization_Metric__c == 'The Expert Center')
                ExpertCenterUtilizations.add(otherUtil);
        }
    }
    
    private boolean IsReportSelector {
        get {
            if (IsReportSelector == null) {
                IsReportSelector = false;
                if (ApexPages.CurrentPage().GetURL().contains('SummaryReportSelector'))
                    IsReportSelector = true;
            }
            return IsReportSelector;
            
        }
        set;
    }
    
    // Get the APIKeys object so we can find the Google_API_Key__c for our google map
    public API_Keys__c APIKeys {
        get {
            if (APIKeys == null) {
                APIKeys = API_Keys__c.getInstance();
            }
            return APIKeys;
        }
        set;
    }
    
    // Google_API_Key__c is used in the SummaryReportGoogleMap Component
    public String GoogleAPIKey {
        get {
            if (GoogleAPIKey == null) GoogleAPIKey = APIKeys.Google_API_Key__c;
            return GoogleAPIKey;
        }
        set;
    }
    
    // url encode the address so it can be used in our static google map
    public String UrlEncodedAddress {
        get {
            if (UrlEncodedAddress == null) {
                String addressString = MainAccount.Primary_Address_Line_1__c + ',';
                if (MainAccount.Primary_City__c != null) addressString += ',' + MainAccount.Primary_City__c;
                if (MainAccount.Primary_State_Province__c != null)  addressString += ',' + MainAccount.Primary_State_Province__c;
                if (MainAccount.Primary_Postal_Code__c != null)     addressString += ',' + MainAccount.Primary_Postal_Code__c;
                if (MainAccount.Primary_State_Province__c != null)  addressString += ',' + MainAccount.Primary_State_Province__c;
                UrlEncodedAddress = EncodingUtil.urlEncode(addressString, 'UTF-8');
            }
            return UrlEncodedAddress;
        }
        set;
    }
    
    public boolean ShowAppendices {
        get {
            if (ShowAppendices == null) {
                ShowAppendices = false;
                if (ShowPricingHistory || ShowOpportunities || ShowAcctMgmtVisits 
                || ShowRenewalNotes || ShowUtilizationSnapshot || ShowRestrictions
                || ShowWarmLeads || ShowMarketingOpps || ShowAcctMgmtPhoneCalls || ShowMap)
                    ShowAppendices = true;
            }
            return ShowAppendices;
        }
        set;
    }
    
    public String TimeStr {
        get {
            if (TimeStr == null) {
                TimeStr = mainEvent.StartDateTime.format('EEEEE MMMMM dd, yyyy   hh:mm a');
                TimeStr += mainEvent.EndDateTime.format(' - hh:mm a');
            }
            return TimeStr;
        }
        set;
    }
    
    public String StartTimeStr {
        get {
            if (StartTimeStr == null) {
                StartTimeStr = mainEvent.StartDateTime.format('MM/dd/yyyy hh:mm a');
            }
            return StartTimeStr;
        }
        set;
    }
    
    public String EndTimeStr {
        get {
            if (EndTimeStr == null) {
                EndTimeStr = mainEvent.EndDateTime.format('MM/dd/yyyy hh:mm a');
            }
            return EndTimeStr;
        }
        set;
    }
    
    //Modified By Abhinav sharma - 03/27/2018 - CR-20171108-11770 - Avoid the Null pointer Exception
    public List<UtilizationSummary> ContractSummaries {
        get {
            
            if (ContractSummaries == null) {
                
                Map<String, UtilizationSummary> summaryMap = new Map<String, UtilizationSummary>();
                ContractSummaries = new List<UtilizationSummary>();
                
                //Set to hold the program IDs
                Set<Id> setProgramIds = new Set<Id>();
                
                //loop through active contracts
                for(Contract__c c : [Select Program__c FROM Contract__c 
                                        WHERE Active__c = true
                                        AND Program__c != null
                                        LIMIT 1000])
                    setProgramIds.add(c.Program__c);
                
                //get remaining records count
                Integer i = 0;
                                
                //Checking for size of set
                if(setProgramIds.size() > 0) {    
                    if(setProgramIds.size() < 1000)
                        i = 1000 - setProgramIds.size();
                    else
                        i = 4000; //Some random value
                } else {
                    i =1000;
                }
                    
                //Checking for integer value and querying additional subscription records
                if(i != 4000) {
                    for(SBQQ__Subscription__c ss : [Select Id, Program__c 
                                                    FROM SBQQ__Subscription__c 
                                                    WHERE Active_Subscription__c = true 
                                                    AND RecordType.DeveloperName = 'Program'
                                                    AND Program__c != null
                                                    LIMIT : i
                                                   ]
                    )
                        setProgramIds.add(ss.Program__c);
                       
                }
                                  
                //Checking for set of size
                if(setProgramIds.size() > 0) {
                
                    // get all contracts with Programs so that we can match program acronyms and manually count contract value
                    List<Program__c> programsWithContracts = [SELECT Name, Id, Business_Line__c,
                                                                (SELECT Name, Program_Acronym__c, Annual_Contract_Value__c 
                                                                    FROM Contracts__r 
                                                                        WHERE Active__c = true
                                                                            AND Payer_Account__c != null 
                                                                            AND Payer_Account__c = :ParentAccountId
                                                                ),
                                                                (Select Id, Program_Acronym__c, 
                                                                Annualized_Amount__c
                                                                    From Subscriptions__r 
                                                                    Where SBQQ__Account__c != null
                                                                        AND SBQQ__Account__c =: ParentAccountId 
                                                                        AND RecordType.DeveloperName = 'Program'
                                                                        AND Active_Subscription__c = true
                                                                )
                                                                FROM Program__c 
                                                                WHERE Business_Line__c != null 
                                                                    AND ID IN : setProgramIds
                                                                LIMIT 1000];
                    
                    //Loop through program records
                    for (Program__c program : programsWithContracts) {
                        
                        //Populating wrapper instance
                        UtilizationSummary utilSummary = summaryMap.get(program.Business_Line__c);
                        
                        if (utilSummary == null) {
                            utilSummary = new UtilizationSummary();
                            utilSummary.BusinessLine = program.Business_Line__c;
                            if (program.Business_Line__c.toLowerCase().Contains('pt') && mainAccount != null)
                                utilSummary.MarketSegment = mainAccount.BI_Market_Segment__c;
                            else if (program.Business_Line__c.toLowerCase().Contains('ri') && mainAccount != null)
                                utilSummary.MarketSegment = mainAccount.Core_Market_Segment__c;
                        }
                        
                        // get the counts for each program type
                        for (Contract__c contract : program.Contracts__r) {
                            utilSummary.ActiveMemberships++;
                            utilSummary.ContractValue += contract.Annual_Contract_Value__c.intValue();
                        }
                                                
                        // get count for each program subscription type.
                       for(SBQQ__Subscription__c sub : program.Subscriptions__r) {
                            utilSummary.ActiveMemberships++;
                            
                           //To avoid the Null pointer exception - CR-20171108-11770 - Added by Abhinav Sharma - 03/27/2018.
                            if(sub.Annualized_Amount__c == null)
                                sub.Annualized_Amount__c = 0;
                            utilSummary.ContractValue += sub.Annualized_Amount__c.intValue();
                        }
                        
                        // place this in our map (ie: "PT", utilSummary object)
                        summaryMap.put(program.Business_Line__c, utilSummary);
                        
                    }   
                
                    TotalMembershipAmt = 0;
                    TotalMembers = 0;
                    
                    // calculate the membership totals
                    for (UtilizationSummary uSummary : summaryMap.values()) {
                        TotalMembers += uSummary.ActiveMemberships;
                        TotalMembershipAmt += uSummary.ContractValue;
                    }
                    
                    
                    // set the contract summaries to the map list
                    ContractSummaries = summaryMap.values();
                }
            }
            
            return ContractSummaries;
        }
        set;
    }
    
    public List<Event> PTQACallEventsThisYear {
        get {
            if (PTQACallEventsThisYear == null) {
                // get a list of all events where the record type = PT QA Call (bi_qa_call) and is associated with the membership
                PTQACallEventsThisYear = [SELECT Id, Would_Refer__c, 
                                          Title__c, 
                                          Would_Buy_Again__c, StartDateTime, Who.Name, Program__c
                        FROM Event WHERE WhatId = :mainMembership.Id AND RecordType.DeveloperName = 'BI_QA_Call' AND StartDateTime >= LAST_N_YEARS:1 ORDER BY StartDateTime DESC LIMIT 1000 ALL ROWS];
            }
            return PTQACallEventsThisYear;
        }
        set;
    }
    
    public  String EventDescription {
        get {
            if (EventDescription != null) 
                EventDescription = mainEvent.Description.ReplaceAll('\n', '<br/>');
                
            return EventDescription;
        }
        set;
    }
}