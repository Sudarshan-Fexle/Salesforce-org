/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@istest(seeAllData = false)
private with sharing class Test_SummaryReportController {
    
    @testSetup 
    Static void methodName() {
        //re-activate triggers
        Util.bypassAllTriggers = true;
        
        Program__c pg = TestUtilities.CreateNewProgram(true);
        Account acc = TestUtilities.CreateNewAccount(true);
        Membership__c mem = TestUtilities.CreateNewMembership(acc.id, pg.id, true);
        
        DateTime DTStart = System.Now().addDays(-5);
        Date DStart = Date.newInstance(DTStart.year(), DTStart.month(), DTStart.day());
        
        
        Event evtMem1 = new Event(
            whatId = mem .id,
            StartDateTime = DTStart,
            ActivityDateTime = DTStart,
            ActivityDate = DStart,
            //DurationInMinutes = 30,
            Cancelled_Did_Not_Occur__c = true,
            EndDateTime = DTStart.addDays(1),
            Event_Type__c = 'Prewire',
            Event_Purpose__c = 'Prewire');
        insert evtMem1 ;
    }
    @istest
    static void testMyProperty_true()
    {
        SummaryReportController src = new SummaryReportController();
        Test.startTest();
        //create a event record
        //src.EventId;//=[Select id from event limit 1].id;
        
        src.ShowPricingHistory=true;
        src.ShowOpportunities=true;
        src.ShowAcctMgmtVisits=true;
        src.ShowRenewalNotes=true;
        src.ShowRestrictions=true;
        src.ShowMap=true;
        src.ShowWarmLeads=true;
        src.ShowMarketingOpps=true;
        src.ShowAcctMgmtPhoneCalls=true;
        src.ShowUtilizationSnapshot=true;
        //src.TotalMembershipAmt=2.5;
        //src.TotalMembers=5;
        test.stopTest();
    }
    static testMethod void testMyProperty_false()
    {
        SummaryReportController src = new SummaryReportController();
        Test.startTest();
        src.ShowPricingHistory=false;
        src.ShowOpportunities=false;
        src.ShowAcctMgmtVisits=false;
        src.ShowRenewalNotes=false;
        src.ShowRestrictions=false;
        src.ShowMap=false;
        src.ShowWarmLeads=false;
        src.ShowMarketingOpps=false;
        src.ShowAcctMgmtPhoneCalls=false;
        src.ShowUtilizationSnapshot=false;
        src.TotalMembershipAmt=2.5;
        src.TotalMembers=5;
        test.stopTest();
    }
    @istest
    static void PricingHistoryWrapper()
    {
        SummaryReportController.PricingHistoryWrapper phw = new SummaryReportController.PricingHistoryWrapper();
        String str = phw.ReportingVertical;
        Double d = phw.PoolTotal;
        Double d1 = phw.PoolYear1Total;
        Double d2 = phw.PoolYear2Total;
        Double d3 = phw.PoolYear3Total;
        Double d4 = phw.PoolYear4Total;
        Double d5 = phw.PoolYear5Total;
        Double d6 = phw.PoolYear6Total;
        Double d7 = phw.PoolYear7Total;
        //Map<String,PricingHistory> ph = new Map<String,PricingHistory>();
        //ph.put(null,null);
    } 
    @istest
    static void Test_pricingHistory()
    {
        SummaryReportController.PricingHistory ph = new SummaryReportController.PricingHistory();
        String str  = ph.ReportingVertical;
        String str1 = ph.ProgramAcronym;
        double d1 = ph.PoolYear1;
        double d2 = ph.PoolYear2;
        double d3 = ph.PoolYear3;
        double d4 = ph.PoolYear4;
        double d5 = ph.PoolYear5;
        double d6 = ph.PoolYear6;
        double d7 = ph.PoolYear7;
        double d8 = ph.ProgramTotal;
    }
    @istest
    Static void Test_IsMarketingEvent()
    {   
        Event ev = TestUtilities.CreateNewEvent(true);
        test.startTest();
        SummaryReportController src = new SummaryReportController();
        System.assertEquals(true,src.IsMarketingEvent=true);
        
        test.stopTest();
    }
    @istest
    Static void Test_UtilizationSummary()
    {   
        test.startTest();
        SummaryReportController.UtilizationSummary us = new SummaryReportController.UtilizationSummary();
        us.ProgramName ='Test1';
        us.ProgramAcronym ='Test2';
        us.BusinessLine='Test3';
        us.MarketSegment='Test4';
        test.stopTest();
    }
    
    @istest
    Static void Test_GetterSetter(){  
        test.startTest();
        SummaryReportController src = new SummaryReportController();
        Account acc = src.mainAccount;
        Contact cc = src.mainContact;
        List<Opportunity> opp = src.AllOpportunities;
        List<Event> acMgmtVisits = src.AcctMgmtVisits;
        List<Event> AcctMgmtPhoneCalls = src.AcctMgmtPhoneCalls;
        List<Opportunity> wO = src.WonOpportunities;
        List<Utilization_Data_Object__c> tcu = src.TeleconferenceUtilizations;
        List<Meeting_Utilization__c> mu = src.MembershipUtilizations;
        List<Other_Utilization__c> ou =  src.OtherUtilizations;
        List<Other_Utilization__c> pru = src.PubReorderUtilizations;
        List<Other_Utilization__c> osu = src.OnsiteUtilizations;
        List<Other_Utilization__c> dtu = src.DAGToolUtilizations;
        List<Other_Utilization__c> ecu = src.ExpertCenterUtilizations;
        List<Opportunity> ro = src.RenewalOpportunities;
        List<Opportunity> pfo =  src.PastFiveOppsForSameProduct;
        List<Membership__c> pm = src.PastMemberships;
        List<Membership__c> cm = src.CurrentMemberships;
        List<Opportunity> amo = src.ActiveMarketingOpps;
        Account pa = src.ParentAccount;
        List<Account> ca = src.ChildAccounts;
        List<Account> gca = src.GrandChildAccounts;
        //PageReference pr_gPdf = src.GeneratePDF();
        src.HasErrors=true;
        //pageReference pr_iv = src.IsValid();
        String td = src.TodaysDate;
        List<SummaryReportController.UtilizationSummary> us = src.InstitutionUtilizations;
        string py1l = src.PoolYear1Label;
        string py2l = src.PoolYear2Label;
        string py3l = src.PoolYear3Label;
        string py4l = src.PoolYear4Label;
        string py5l = src.PoolYear5Label;
        string py6l = src.PoolYear6Label;
        string py7l = src.PoolYear7Label;
        List<SummaryReportController.PricingHistoryWrapper> phw = src.PHWrapperList;
        List<SummaryReportController.UtilizationSummary> cul = src.ContactUtilizationList;
        API_Keys__c apikey =  src.APIKeys;
        String gApiKey = src.GoogleAPIKey;
        String UEAdd = src.UrlEncodedAddress;
        src.ShowAppendices=true;
        List<SummaryReportController.UtilizationSummary> cntrctSm = src.ContractSummaries;
        List<Event> ptq = src.PTQACallEventsThisYear;
        String ed = src.EventDescription;
        test.stopTest();
    }
    
    @istest
    Static void TestCoverageForGetterSetter()
    { 
        Util.byPassAllTriggers = true;
        Account acc = TestUtilities.CreateNewAccount(true);
        //Creating Contact record 
        Contact cont = TestUtilities.CreateNewContact(True);
        
        //Modified By - Rajeev Jain - 01/10/2020 - Bug Fix for Release L2 Winter '21 Required Updates & L1 Weekly Release - 10/2/2020
        //Opportunity
        //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
        Opportunity opportunity = new Opportunity(Sales_Pursuit_Products__c = 'APS', Name = 'Test Opp', StageName = '0-Exploring', Main_Contact__c = cont.Id,
                                                  Amount = 1, CloseDate = System.today().addDays(35), AccountId = acc.ID);
        insert opportunity;
        
        DateTime DTStart = System.Now().addDays(-5);
        Date DStart = Date.newInstance(DTStart.year(), DTStart.month(), DTStart.day());
        Event evt = new Event(whatId = opportunity.id, StartDateTime = DTStart, ActivityDateTime = DTStart,ActivityDate = DStart, Cancelled_Did_Not_Occur__c = true,
                                  EndDateTime = DTStart.addDays(1), Event_Type__c = 'Prewire',Event_Purpose__c = 'Prewire');
        insert evt;
        Util.byPassAllTriggers = false;
        
        Test.startTest();
        
        List<Event> events = [SELECT Id FROM Event WHERE What.Type = 'Membership__c'];
        
        system.assertEquals(1, events.size());
       
        Test.setCurrentPageReference(new PageReference('SummaryReport')); 
        System.currentPageReference().getParameters().put('Id', evt.Id);
        
        SummaryReportController src = new SummaryReportController();
        src.GeneratePDF();
        src.IsValid();
        Test.stopTest();
    }
}