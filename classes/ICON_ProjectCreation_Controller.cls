/*
  Purpose:
    
    Allow a user to create a custom project from a custom Contract__c (Contract ABC)
    
    
  Initiative: IconATG FinancialForce PSA Implementation 
  Author:     John McCarvill
  Company:    IconATG
  Contact:    john.mccarvill@iconatg.com
  Created:    6/30/2015
  
*/

public with sharing class ICON_ProjectCreation_Controller {

    //display any error messages to user
    public String showMessage {get; set;}
    
    //opportunity id
    public String m_sContractId {get; set;}
    
    //source objects
    public Contract__c m_pContract {get; set;}
    
    //existing projects
    public list<pse__Proj__c> m_listExistingProject {get; set;}

    //current user's resource
    public Contact m_pResource {get; set;}
    
    //display existing projects
    public boolean m_bHasProjects {get; set;}

    //display create project button
    public boolean m_bValidForProject {get; set;}
        
    public ICON_ProjectCreation_Controller(ApexPages.StandardController stdController)
    {
        
        //default 
        this.m_bValidForProject = true;
        
        //get OpportunityId parameter
        Contract__c pContract = (Contract__c)stdController.getRecord(); 
        this.m_sContractId = pContract.Id;
        
        //Commented by Mahendra Swarnkar - 04/25/2020 - CR-20200218-13769 - concessions__c,maint_end__c,maint_month__c,Maint_Negotiated__c,
        //maint_prev_negotiated__c,maint_start__c, maint_year__c
        //load source objects
        this.m_pContract = [Select c.Years_in_Term__c, c.Year__c, c.Year_One_Fees__c, c.Year_5_PI__c, c.Year_4_PI__c, c.Year_3_PI__c, 
                                c.Year_2_PI__c, c.Y5_PI__c, c.Y5_Annual_Fee__c, c.Y4_PI__c, c.Y4_Annual_Fee__c, c.Y3_PI__c, c.Y3_Annual_Fee__c, 
                                c.Y2_PI__c, c.Y2_Annual_Fee__c, c.Y1_Annual_Fee__c, c.Unit_Status__c, c.Type__c, c.Total_Unpaid_Contract_Amount__c, 
                                c.Total_Travel__c, c.Total_Paid__c, c.Total_Outstanding__c, c.Total_Counter__c, c.Termination_Payment__c,
                                c.Term_Type__c, c.SystemModstamp, c.Status__c, c.Start__c, c.Stage__c, c.Source_Opportunity__c, 
                                c.Setup_in_Negotiated__c, c.Risk_Start__c, c.Risk_Negotiated_Amount__c, c.Risk_End__c, c.Risk_Due_Date__c, 
                                c.Risk_Completed__c, c.Risk_Comments__c, c.Report_Team__c, c.Report_Division__c, c.Renewal_Opp_Status__c, 
                                c.Renewal_Opp_Owner_2__c, c.Renewable__c, c.RecordTypeId, c.Receipt_of_LOA__c, c.Project_Description__c, 
                                c.Program__c, c.Program_Line__c, c.Program_Acronym__c, c.Program_Abbreviation__c, c.Pricing_Metrics__c, 
                                c.Previous_Contract__c, c.Payer_Account__c, c.Opt_Out_Type__c, c.Opt_Out_Date__c, c.Opportunity_Stage__c, 
                                c.New_Business_Vertical__c, c.New_Business_Business__c, c.Net_Invoiced__c, c.Negotiated_By__c, 
                                c.Negotiated_Amount__c, c.Name, /*c.Maint_Year__c, c.Maint_Start__c, c.Maint_Prev_Negotiated__c,*/ 
                                /*c.Maint_Negotiated__c, c.Maint_Month__c, c.Maint_End__c,*/ c.Main_Contact__c, c.Line_Item_Schedule_Total__c,  
                                c.Likely_to_Close_in_Year__c, c.Likely_to_Close_in_Quarter__c, c.Join_Date__c, c.IsDeleted, 
                                c.Invoicing_Instructions__c, c.Invoicing_Arrangement__c, c.Invoice_Total__c, c.Invoice_Contact__c, 
                                c.Invoice_Billing_Schedule__c, c.Internal_ABC_Allocation__c, c.Initial_Invoice_Date__c, c.Id, 
                                c.Historical_Linker__c, c.HWorks_Contract_Value__c, c.GUID__c, c.Forecasting_Revenue_at_Risk_Type__c, 
                                c.Forecasting_Potential_Revenue_Change_Num__c, c.Forecasting_Expected_Closure_Date__c, 
                                c.Forecasting_End_Date_Change__c, c.Forecasted_in_Rev_Rec__c, c.First_Invoice_Created__c, 
                                c.Exchange_Rate__c, c.End__c, c.Date_Added_to_Rev_Rec__c, c.CurrencyIsoCode, c.Credited_Contract_Length__c, 
                                c.Credit_Note_Total__c, c.Counter_ID__c, c.Core_Contract_Value__c, 
                                c.Contract_Term_Category__c, c.Contract_Renewal_Opportunity__c, c.Contract_Opt_Out__c, c.Contract_Currency__c, 
                                c.Contract_Count__c, c.Contract_Active__c, c.Contract_5_Yr_Term__c, c.Contract_4_Yr_Term__c, 
                                c.Contract_3_Yr_Term__c, c.Contract_2_Yr_Term__c, c.Contract_1_Yr_Term__c, c.ConnectionSentId, 
                                c.ConnectionReceivedId, /*c.Concessions__c,*/ c.Concessions_Comments__c, c.Committed_Contract_Length__c, 
                                c.Comments_for_Revenue_at_Risk__c, c.Comments_for_Approval_Offer__c, c.Comments__c, c.Calculator_Total__c, 
                                c.Calculator_Set_Up__c, c.Calculator_Annual__c, c.CPI_Escalation_Clause__c, c.CPI_Escalation_Cap__c, 
                                c.Business_Line__c, c.Business_Line_From_Trigger__c, c.Bill_with_ID__c, c.BI_Contract_Value__c, c.Average_PI__c, 
                                c.Average_Credited_PI__c,c.At_Risk_Type__c,c.At_Risk_Internal_ABC_Allocation__c, 
                                c.At_Risk_Accounting_Contract_Value__c, c.Approved_By__c, c.Approval_Status__c, c.Approval_Date__c, 
                                c.Annual_Contract_Value__c, c.Amount_Credited_Total__c, c.Adjusted_Internal_ABC_Allocation__c, 
                                c.Adjusted_At_Risk_Internal_ABC_Allocation__c, c.Adjusted_Accounting_Contract_Value__c, 
                                c.Adj_At_Risk_Accounting_Contract_Value__c, c.Active__c, c.Active_2__c, c.Accounting_Contract_Value__c, 
                                c.Academies_Contract_Value__c, c.Academies_Contract_Value_2__c, c.Payer_Account__r.Name, c.Payer_Account__r.Id,
                                c.Source_Opportunity__r.OwnerId, c.Source_Opportunity__r.Id 
                                From Contract__c c
                                WHERE c.Id =: this.m_sContractId];

        
            //load any existing projects
            this.m_listExistingProject = [SELECT Id, Name, Contract_ABC__c  FROM pse__Proj__c WHERE Contract_ABC__c=:m_pContract.Id ORDER BY Name];
        
        
            //set flag
            if (m_listExistingProject.size()>0) m_bHasProjects=true; else m_bHasProjects=false;
            
            
            //get resource info
            list<Contact> listResource = [Select c.Id, c.pse__Salesforce_User__r.Id, c.pse__Salesforce_User__c
                                            From Contact c
                                            WHERE c.pse__Salesforce_User__r.Id=:UserInfo.getUserId()];
        
            if (listResource.size()==0)
            {
                this.showMessage = 'Could not find PSA Resource record for current user';
                this.m_bValidForProject = false;
                return;
            } 
            this.m_pResource = listResource[0];
        
    }

    public Pagereference CheckForExistingProject()
    {
        //if projects exist allow user to choose
        
        if (m_listExistingProject.size()>0)
        {
            //the page will display the list
            this.showMessage = 'There are already existing projects on this contract.';
            return(null);
        }


        //validate other requirements
        
        //user must be resource to be PM
        if (this.m_pResource==null)
        {
            this.showMessage = 'Could not find PSA Resource record for current user';
            this.m_bValidForProject = false;
            return(null);
        } 

        //must have project description
        if (m_pContract.Project_Description__c=='' || m_pContract.Project_Description__c==null)
        {
            this.showMessage = 'Contract ABC must have a "Project Description" in order to create a project.';
            this.m_bValidForProject = false;
            return(null);
        } 

        //must have payer account
        if (m_pContract.Payer_Account__c==null)
        {
            this.showMessage = 'Contract ABC must have a "Payer Account" set in order to create a project.';
            this.m_bValidForProject = false;
            return(null);
        } 
        

        //forward to create project
        return(CreateProjectFromContract());
        
    }

    public Pagereference cancelEntry()
    {
        //return to Contract
        PageReference redirect = new PageReference('/' + m_sContractId); 
        return redirect;
        
    }

    public Pagereference CreateProjectFromContract()
    {
        
        //start database transaction
        Savepoint sp = Database.setSavepoint();

        //create new project
        pse__Proj__c pProject = new pse__Proj__c();

        try
        {
            
            //map fields/properties
            //pProject.pse__Project_ID__c = ''; //(Auto Number)
            
            string sName = m_pContract.Payer_Account__r.Name + '--' + m_pContract.Project_Description__c;
            
            //if we already have projects with this name, then append increment
            integer iCount = 0;
            for(pse__Proj__c pExisting:m_listExistingProject)
            {
                if (pExisting.Name.indexOf(sName)!=-1) iCount++;
            }
            if (iCount>0) sName+= ' (' + string.valueOf(iCount+1) + ')';
            
            pProject.Name = sName; //<Payer Account> "--" <Project Description> (from Contract ABC)
            pProject.Contract_ABC__c = m_pContract.Id;
            
            pProject.pse__Account__c = m_pContract.Payer_Account__r.Id; //<Payer Account> (from Contract ABC)
            pProject.pse__Opportunity__c = m_pContract.Source_Opportunity__r.Id; //<Source Opportunity> (from Contract ABC)
            pProject.pse__Opportunity_Owner__c = m_pContract.Source_Opportunity__r.OwnerId; //<Source Opportunity Owner> (from Source Opportunity on Contract ABC)
            pProject.pse__Project_Manager__c = m_pResource.Id; //<Finance PM> (User who created Project)
            pProject.pse__Billing_Type__c = 'None';
            pProject.pse__Project_Type__c = 'Customer Project';
            pProject.pse__Pre_Bill_Type__c = 'None';
            //pProject.CreatedById = ''; //(User who created Project)
            pProject.OwnerId = UserInfo.getUserId(); //(User who created Project)
            pProject.pse__Start_Date__c = m_pContract.Start__c; //<Start Date (Contract ABC) >
            pProject.pse__End_Date__c = m_pContract.End__c; //<End Date (Contract ABC) >
            pProject.pse__Region__c = null; //NULL {Note to developer. If you can create the project without requiring an R,P, or G, that is what ABC would like}
            pProject.pse__Stage__c = 'Planned';
            pProject.pse__Share_with_Project_Manager__c = FALSE;
            pProject.pse__Share_with_Project_Resources__c = FALSE;
            pProject.pse__Exclude_from_Backlog__c = FALSE;
            pProject.pse__Include_In_Forecasting__c = FALSE;
            pProject.pse__Is_Template__c = FALSE;
            pProject.pse__Is_Active__c = TRUE;
            pProject.pse__Is_Billable__c = TRUE;
            pProject.pse__Closed_for_Time_Entry__c = TRUE;
            pProject.pse__Closed_for_Expense_Entry__c = TRUE;
            pProject.pse__Exclude_From_Billing__c = FALSE;
            pProject.pse__Allow_Self_Staffing__c = FALSE;
            pProject.pse__Time_Excluded__c = FALSE;
            pProject.pse__Time_Credited__c = FALSE;
            pProject.pse__Daily_Timecard_Notes_Required__c = TRUE;
            pProject.PM_Timecard_Expenses_Approval_Required__c = FALSE;
            pProject.Set_Max_Hours_per_Day__c = FALSE;
            
            insert(pProject);
        }
        catch(Exception err)
        {
            Database.rollback(sp);
            this.showMessage = 'Line: ' + err.getLineNumber() + ' - ' + err.getMessage(); 
            System.debug('JM - Line: ' + err.getLineNumber() + ' - ' + err.getMessage());
            return(null);
        }
        
        //if we made it here, then the project exists - forward to new project
        PageReference redirect = new PageReference('/' + pProject.Id); 
        return(redirect);
        
        
    } 

    //enable throwing custom errors
    public class customException extends Exception {}

}