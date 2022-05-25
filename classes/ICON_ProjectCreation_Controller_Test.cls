/*
  Purpose:
    
    To test automated project creation from contract.
    
    
  Initiative: IconATG FinancialForce PSA Implementation 
  Author:     John McCarvill
  Company:    IconATG
  Contact:    john.mccarvill@iconatg.com
  Created:    6/30/2015
              V1.1 - Modified By - Abhinav Sharma - CR-20160127-9565 - 01/29/2016 - Commented out the % Likely To Close field reference
              V1.2 - Modified By - MAhendra Swarnkar - CR-20151111-9378 - 7/25/2016 - Removed the "Contact_List_Received__c", "Contact_List_Added_In_Salesforce" fields references.   
              V1.3 - Modified By - Rajiv Jain - 02/20/2020 - CR-20200110-13605 -  Remove zzzCount of Warm Leads (Count_of_Warm_Leads__c) field of opportunity.
	      V1.4 - Modified By - Neha sharma - CR-20201110-14683 - add the Sales_Pursuit_Products__c
              V1.5 - Modified By - Chirag Soni - CR-20210927-15464 - 09/28/2021 - Removed the 'Research' picklist value referece and updated to 'APS'
*/
@isTest (SeeAllData=true)
private class ICON_ProjectCreation_Controller_Test {
  
    //Commented engagement_letter_sent__c, budget_approval_process_clear__c, honorary_conversion_check_box__c, tools_demonstration_completed__c  - By Mahendra Swarnkar - spring clean up - 04/29/2019
    //Modified By - Chirag Soni - CR-20210927-15464 - 09/28/2021 - Removed the 'Research' picklist value referece and updated to 'APS'
    static testMethod void ProjectCreationTests() {
        
        //Bypassing triggers
        Util.byPassAlltriggers = true;
        Util.IsTest(true);
        
        //Create Account
        Account pAccount = new Account(Name='Test');
        insert(pAccount);
        
        //get an active resource -- if current user is resource, then use them
        Contact pResource;
        list<Contact> listContacts=[SELECT c.Id, c.LastName, c.pse__Salesforce_User__c 
                                    FROM Contact c 
                                    WHERE c.pse__Salesforce_User__c!=null 
                                    AND c.pse__Is_Resource__c=true 
                                    AND c.pse__Is_Resource_Active__c=true 
                                    AND c.pse__Salesforce_User__r.Id=:UserInfo.getUserId()
                                    LIMIT 1];
        
        if (listContacts.size()>0)
        {
            pResource = listContacts[0];
        }
        else
        {
            //create a new resource
            pResource = new Contact(
                    LastName = 'test' + '-' + String.valueOf(Math.random()),
                    pse__Is_Resource__c=true,
                    pse__Is_Resource_Active__c=true,
                    pse__Salesforce_User__c = UserInfo.getUserId(),
          	    Email = 'Test'+Math.random()+'@eab.com',
		    Title = 'Test',
		    Phone = '614-555-8855'
          
                );
                insert(pResource);
        }
        
        string recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Royall').getRecordTypeId();
        
        
        // Test Class Fix Start Here 13Feb By: Dipesh Gupta
        //Creating Contact record 
        Contact cont = TestUtilities.CreateNewContact(True);
        // Test Class Fix End Here 13Feb By: Dipesh Gupta
        
        Opportunity pOpportunity = new Opportunity(
            recordTypeId = recordTypeId,
            
            AccountId = pAccount.Id,        //reference(Account)
            Main_Contact__c = cont.Id,
            //RecordTypeId = '012C0000000BkFXIA0',      //reference(RecordType)
            Name = 'Celtic Healthcare - Mars - PA - HICP - 2015 Renewal',       //text(120)
            Description = 'LOA out, questions answered',        //textarea(32000)
            StageName = 'ATL',      //picklist(40)
            Amount = 25573.0,       //currency(18,2)
            Probability = 100.0,        //percent(3,0)
            CloseDate = system.today(),         //date
            ForecastCategoryName = 'Closed',        //picklist(40)
            CurrencyIsoCode = 'USD',        //picklist(3)
            Add_Stakeholder_IdentifiedEnfranchised__c = false,      //boolean
            BAA_Sent__c = false,        //boolean
            Batch_Status__c = 'Step 1',         //text(100)
            //Budget_Approval_Process_Clear__c = false,       //boolean
            Budget_Secured__c = false,      //boolean
            Business_Case_Established__c = false,       //boolean
            CXO_Endorsement__c = false,         //boolean
            Calculated_Close_Date__c = system.today(),      //date
            //Chairman_s_Team_Rep__c = '005C0000003wnKvIAI',        //reference(User)
            Champion_Identified__c = false,         //boolean
            Closing_Call_Scheduled__c = system.today(),         //date
            Contract_Strategy_Determined__c = 'N/A - Opt Out',      //multipicklist(4099)
            //Count_of_Warm_Leads__c = 0.0,       //number(18,0)
            Current_YTD_Visits__c = 0.0,        //number(18,0)
            Decision_Maker_Identified__c = false,       //boolean
            Decision_Type__c = 'Need New LOA',      //picklist(255)
            Editable_by_Finance_Ops_Only__c = true,         //boolean
            End__c = system.today().addDays(100),       //date
            Forecasted__c = false,      //boolean
            Funding_Budget_Secured__c = false,      //boolean
            Historical_Linker__c = 'Q00590267b',        //text(30)
            //Honorary_Conversion_Check_Box__c = false,       //boolean
            Initial_Visit_Completed__c = false,         //boolean
            Is_Champion_CXO__c = false,         //boolean
            LOA_Walkthrough_Completed__c = false,       //boolean
            LOA_in_Legal__c = false,        //boolean
            //Main_Contact__c = '003C000001TNegtIAD',       //reference(Contact)
            Member_Health_Assessment__c = false,        //boolean
            //Membership__c = 'a0HC000000Tc93uMAB',         //reference(Membership__c)
            Negotiation_on_business_terms_complete2__c = false,         //boolean
            Opt_Out_Date__c = system.today().addDays(50),       //date
            Other_Outreach_Campaign__c = '#RIMHICampaign',      //text(80)
            //Parent_Opportunity__c = '006C000000lQn21IAC',         //reference(Opportunity)
            Pool_Month__c = '1',        //picklist(255)
            Pool_Year__c = '2015',      //text(4)
            //Previous_Contract__c = 'a0AC000000jEPF1MAO',      //reference(Contract__c)
            Previous_YTD_Visits__c = 0.0,       //number(18,0)
            Previous_Year_Negotiated_Adjustment__c = -9427.0,       //number(18,0)
            Previous_Year_Negotiated__c = 35000.0,      //currency(18,0)
            Previous_Year_Visits__c = 0.0,      //number(18,0)
            Prewire_Completed__c = false,       //boolean
            Probability_Field_Update__c = system.today(),       //date
            //Program__c = 'a0MC000000BMr36MAD',        //reference(Program__c)
            Proposal_Sent__c = false,       //boolean
            Prospect_Articulates_Need_for_Membership__c = false,        //boolean
            Prospect_Exposed_to_Research__c = false,        //boolean
            Quarterly_Checkin_Calls__c = system.today(),        //date
            Renewal_Negotiated__c = 25573.0,        //currency(18,0)
            Risk_Contract__c = false,       //boolean
            Signatory_Established__c = false,       //boolean
            //Signed_Opportunity_Contract__c = 'a0AC000001VjElVMAV',        //reference(Contract__c)
            Specific_need_priority_identified__c = false,       //boolean
            Start__c = system.today(),      //date
            Timeframe_for_Paperwork_Established__c = false,         //boolean
            //Tools_Demonstration_Completed__c = false,       //boolean
            Transition_Note_Sent__c = false,        //boolean
            Trigger_Update__c = false,      //boolean
            Urgency_Argument_Communicated__c = false,       //boolean
            User_Group_Scheduled__c = system.today(),       //date
            Utilization_of_Health_Reviewed__c = 'No',       //picklist(255)
            Verbal_Commitment__c = false,       //boolean
            Warm_Lead__c = false,       //boolean
            Welcome_Call__c = system.today(),       //date
            of_Revisits__c = 0.0,       //number(18,0)
            Campaign_Kicker__c = 105.0,         //percent(3,0)
            Are_They_Evaluating__c = 'Complete after Initial Meeting',      //picklist(255)
            Evaluated__c = 0.0,         //number(1,0)
            Is_there_are_hard_next_step__c = 'Complete after Initial Meeting',      //picklist(255)
            YTD_PAs__c = 0.0,       //number(18,0)
            Prev_YTD_PAs__c = 0.0,      //number(18,0)
            Active_Renewal__c = true,       //boolean
            Utilization_of_Health_Reviewed_3mo__c = 'No',       //picklist(255)
            //Engagement_Letter_Sent__c = false,      //boolean
            Num_Total_PAs__c = 0.0,         //number(18,0)
            Sent_To_Finance_1st_Time__c = false,        //boolean
            Next_Step_Date__c = system.today(),         //date
            //CT_Assignment__c = '005C0000003wnKvIAI',      //reference(User)
            //CT_Associate__c = '005C0000007C455IAC',       //reference(User)
            CT_Background_Situation__c = 'Bill sent an email voicing that Celtic would like to exercise their opt-out',         //text(255)
            CT_Date_Passed__c = system.today(),         //date
            CT_Date_Visit_Happens__c = system.today(),      //date
            CT_Pass_Reason__c = 'Lack of executive support',        //multipicklist(4099)
            CT_Pass_Status__c = 'Assigned',         //picklist(255)
            CT_Reneg_Attempt__c = 'No',         //picklist(255)
            //CT_Strategy_Session_Attendees__c = 'Emily Kelly and Megan Brownell',        //text(255)
            Next_Steps_Text__c = '1) Service: ',        //textarea(255)
            Is_the_Evaluation_Competitive__c = 'No',        //picklist(255)
            Owner_Manager_Email__c = 'gmelinm@advisory.com',        //email(80)
            Current_YTD_Follow_Up_Visits__c = 0.0,      //number(18,0)
            Current_Year_Follow_Up_Visits__c = 0.0,         //number(18,0)
            Current_Year_PAs__c = 0.0,      //number(18,0)
            Current_Year_Visits__c = 0.0,       //number(18,0)
            Next_Year_Follow_Up_Visits__c = 0.0,        //number(18,0)
            Next_Year_PAs__c = 0.0,         //number(18,0)
            Next_Year_Visits__c = 0.0,      //number(18,0)
            Num_Total_Visits__c = 0.0,      //number(18,0)
            Previous_YTD_Follow_Up_Visits__c = 0.0,         //number(18,0)
            Previous_Year_Follow_Up_Visits__c = 0.0,        //number(18,0)
            Scheduled_Follow_Up_Visits__c = 0.0,        //number(18,0)
            Scheduled_PAs__c = 0.0,         //number(18,0)
            Scheduled_Visits__c = 0.0,      //number(18,0)
            Total_Follow_Up_Visits__c = 0.0,        //number(18,0)
            Count_of_Sourced_Warm_Leads__c = 0.0,       //number(18,0)
            CT_Grade_on_Day_of_Pass__c = 'F',       //picklist(255)
            pse__IsParentOpportunityServices__c = false,        //boolean
            pse__Is_Change_Request__c = false,      //boolean
            pse__Is_Services_Opportunity__c = false,        //boolean
            //Modify By - Neha sharma - CR-20201110-14683 - add the Sales_Pursuit_Products__c 
            //Modify By - Chirag Soni - CR-20210927-15464 - 09/28/2021 - Removed the 'Research' picklist value referece and updated to 'APS'
            Sales_Pursuit_Products__c  = 'APS'
        );
        insert(pOpportunity);
        
        //create Contract
        Contract__c pContractABC = new Contract__c(
            Name = 'Graham Holdings - Arlington - VA - HICP - 2015',        //text(80)
            CurrencyIsoCode = 'USD',        //picklist(3)
            //RecordTypeId = '012C0000000BkFDIA0',      //reference(RecordType)
            Payer_Account__c = pAccount.Id,         //reference(Account)
            Active__c = true,       //boolean
            Business_Line_From_Trigger__c = 'RI',       //text(50)
            Comments__c = 'prorate 1/6/2015-12/31/2015',
            Contract_Count__c = 1.0,        //number(18,0)
            Contract_Currency__c = 'USD - US Dollar',       //picklist(255)
            //Contract_Renewal_Opportunity__c = pOpportunity.Id,        //reference(Opportunity)
            End__c = system.today(),        //date
            Exchange_Rate__c = 1.0,         //number(18,3)
            Historical_Linker__c = 'T00323025',         //text(80)
            Initial_Invoice_Date__c = system.today(),       //date
            //Invoice_Contact__c = '003C000001sT0n2IAC',        //reference(Contact)
            Invoicing_Arrangement__c = 'Semi-Annual',       //picklist(255)
            Invoicing_Instructions__c = 'see contract -- MY',       //text(255)
            Join_Date__c = system.today(),      //date
            //Main_Contact__c = '003C000001sT0n2IAC',       //reference(Contact)
            Negotiated_Amount__c = 348021.0,        //currency(18,0)
            //Negotiated_By__c = '005C0000003wmyaIAA',      //reference(User)
            Opt_Out_Date__c = system.today(),       //date
            Opt_Out_Type__c = 'Other Point In Time',        //picklist(255)
            //Previous_Contract__c = 'a0AC000000jEPF1MAO',      //reference(Contract__c)
            //Program__c = 'a0MC000000BMr36MAD',        //reference(Program__c)
            Receipt_of_LOA__c = system.today(),         //date
            Source_Opportunity__c = pOpportunity.Id,        //reference(Opportunity)
            Start__c = system.today(),      //date
            Status__c = 'ATL',      //picklist(255)
            Term_Type__c = 'Opt Out',       //picklist(255)
            Type__c = 'Renewal',        //picklist(255)
            Year__c = '2015',       //text(6)
            Years_in_Term__c = 7.0,         //number(18,0)
            Y1_Annual_Fee__c = 0.0,         //currency(18,0)
            Y2_Annual_Fee__c = 46865.0,         //currency(18,0)
            Y3_Annual_Fee__c = 48271.0,         //currency(18,0)
            Y4_Annual_Fee__c = 49719.0,         //currency(18,0)
            Y5_Annual_Fee__c = 51211.0,         //currency(18,0)
            Amount_Credited_Total__c = 7089.0,      //currency(18,2)
            //Invoice_Billing_Schedule__c = 'a2qC0000001nxZHIAY',       //reference(Invoice_Billing_Schedule__c)
            Invoice_Total__c = 44879.0,         //currency(18,2)
            CPI_Escalation_Clause__c = false,       //boolean
            Project_Description__c = 'Test'         //text(255)
        );
            insert(pContractABC);
        
        //create controller and execute on Opportunity
        PageReference pageRef = Page.ICON_ProjectCreation;

        //In this case, the Visualforce page is the starting point of this test method. 
        Test.setCurrentPage(pageRef);

        //set query string parameters
        ApexPages.StandardController stdController = new ApexPages.StandardController(pContractABC);

        //Instantiate and construct the controller class.
        ICON_ProjectCreation_Controller controller = new ICON_ProjectCreation_Controller(stdController);
        controller.showMessage = 'Test';
        controller.cancelEntry();
        controller.CreateProjectFromContract();
        
        //create another project to get different message
        controller.CheckForExistingProject();
        controller.CreateProjectFromContract();
        string sMessage = controller.showMessage; 
    }
}