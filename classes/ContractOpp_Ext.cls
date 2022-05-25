/*
    Purpose:    Controller Extension to support ABC Contract Booking Process and Visualforce page ContractOppCreator.
                Page will display the source Contract and a table of Opportunities with certain default values specified by ABC. 
                Page will allow adding rows, removing rows, and saving the entire table as desired by Booking user.
    
    Created By:     Jeremy Nottingham (Synaptic) 11/2010
    
    Last Modified By:   Rajeev Jain (Simplyforce) 12/08/2015
    
    Current Version:    V1.4
    
    Revision Log:       V1.0 - (JN) Created class and Visualforce page
                        V1.1 - (JN) Added this header
                             - Added population of Main Contact
                        V1.2 - (JN) Changed behavior on booking based on a non-NBB RI Contract with Term = 1 year (should be RI AM, not RI First Year)
                        V1.3 - (SUNJ) Update Proposal_Value__c with Amount
                        V1.4 - Rajeev Jain  - CR-20151202-9434 - 12/07/2015 -  Pre-populate Pool Year, Pool Month, Negotiated Amount, Previous Year Negotiated, and Opt Out Date fields populate from the Contract ABC's Source Opporutnity.
                        V1.5 - Colin McGloin - 06/28/2016 - CR-20160414-9762 - Added new record type check in opp naming.
                        V1.6 - Subhash Garhwal - 07/21/2016 - CR-20160414-9762 - Commented skip new record type logic and added additon condtion for new record types
			V1.7 - Modified By Mahendra Swarnkar - 03/17/2020 - CR-20200217-13756 - RT deleted : Consulting & Management From Opportunity              
    */

public with sharing class ContractOpp_Ext {
    
    //Initial records. Will be modified.
    public Contract__c sourceContract {get; set; }
    public Opportunity sourceOpp;
    
    //list of Opportunities to display on page
    public list<xopp> displaylist {get; set; }
    
    //Max length of Opportunity Name field
    Integer maxnamelength;
    
    //Recordtypes for Opportunity
    map<String, Id> opprtmap = Util.recordtypemap('Opportunity');
    
    //V1.4 - Added By - Rajeev Jain  - CR-20151202-9434 - 12/07/2015
    //Record Type Name Constants, holds record type's developer name
    //Commented by Mahendra Swarnkar - 03/17/2020 - CR-20200217-13756 - RT deleted : Consulting & Management From Opportunity.
    //public final Static String OPPORTUNITY_RECORDTYPE_DEVELOPER_NAME_SOUTHWIND = 'Southwind';
    public final Static String OPPORTUNITY_RECORDTYPE_DEVELOPER_NAME_PT_MARKETING = 'BI_Marketing';
    public final Static String OPPORTUNITY_RECORDTYPE_DEVELOPER_NAME_RI_MARKETING = 'Core_Marketing';
    
    //Rajeev Jain  - CR-20151202-9434 - 12/07/2015 - UAT Changes
    public final static String DECISION_TYPE_DEFAUL_VALUE_NEED_NEW_LOA = 'Need New LOA';
    
    //Opportunity extended class to store additional information about each Opportunity, as well as handle text dates
    public class xopp
    {
        public Opportunity opp { get; set; }
        Boolean Selected;
        public String opprole { get; private set; } //source, rifirstyear, ristandard, rirenewal, ptcontractmaint, ptrenewal
        public String RecordTypeName { get; private set; }
        public Integer rownumber { get; set; }
        
        //V1.4 - Added By - Rajeev Jain  - CR-20151202-9434 - 12/08/2015 - To hold record type developer name
        public String oppRecordTypeDeveloperName{get;set;}
        
        //All these dates are stored in Date fields, but presented on screen as string values to avoid the date-picker and "Today" links. 
        //So get and set are somewhat complicated.
        public String getStartDate() { 
            if (this.opp.Start__c != null) return this.opp.Start__c.format(); 
            return null;
        }
        public void setStartDate( String d) { 
            list<String> stringdates = d.split('/',0);
            if (stringdates.size() == 3) {
                list<Integer> dates = new list<Integer>();
                
                for (String s : d.split('/',0)) {
                    dates.add(Integer.valueOf(s));
                }
                if (dates[2] < 100) dates[2] += 2000;
                this.opp.Start__c = Date.newInstance(dates[2], dates[0], dates[1]);
            } else {
                this.opp.Start__c = null;
            }
        }
        public String getEndDate() { 
            if (this.opp.End__c != null) return this.opp.End__c.format(); 
            return null;
        }
        public void setEndDate( String d) { 
            list<String> stringdates = d.split('/',0);
            if (stringdates.size() == 3) {
                list<Integer> dates = new list<Integer>();
                
                for (String s : d.split('/',0)) {
                    Integer sint = Integer.valueOf(s);
                    dates.add(sint);
                }
                if (dates[2] < 100) dates[2] += 2000;
                this.opp.End__c = Date.newInstance(dates[2], dates[0], dates[1]);
            } else {
                this.opp.End__c = null;
            }
            
        }
        public String getOptOutDate() { 
            if (this.opp.Opt_Out_Date__c != null) return this.opp.Opt_Out_Date__c.format(); 
            return null;
        }
        public void setOptOutDate( String d) { 
            list<String> stringdates = d.split('/',0);
            if (stringdates.size() == 3) {
                list<Integer> dates = new list<Integer>();
                
                for (String s : d.split('/',0)) {
                    dates.add(Integer.valueOf(s));
                }
                if (dates[2] < 100) dates[2] += 2000;
                this.opp.Opt_Out_Date__c = Date.newInstance(dates[2], dates[0], dates[1]);
            } else {
                this.opp.Opt_Out_Date__c = null;
            }
        }
        
        public Boolean getSelected() { return this.Selected; }
        public void setSelected(Boolean s) { this.Selected = s; }
        
        public xopp(Opportunity o) {
            this.opp = o;
            this.Selected = false;
            oppRecordTypeDeveloperName = '';
            if (o.RecordType.Name != null) this.RecordTypeName = o.RecordType.Name;
        }
    }
    
    /**
     * 
     * @description: returns true if there is an error that should cause the edit page to only display an error message.
     * 
     **/
    public boolean hasError {
        get {
            if (hasError == null) hasError = false;
            return hasError;
        }
        set;
    }
    
    public ContractOpp_Ext(ApexPages.standardController stdcon)
    {
        if (ApexPages.CurrentPage().getParameters().get('id') != null)
        {
            this.sourceContract = [Select Id, Name, Start__c, End__c,  
                                   Program__c, Program__r.Program_Acronym__c, Previous_Contract__c, Negotiated_Amount__c, Previous_Contract__r.Negotiated_Amount__c, Payer_Account__c, 
                                   Negotiated_By__c, Type__c, Term_Type__c, Years_In_Term__c, Source_Opportunity__c, Stage__c, Opt_Out_Type__c, Opt_Out_Date__c, 
                                   Year__c, Payer_Account__r.Name, Main_Contact__c, Y1_Annual_Fee__c, Y2_Annual_Fee__c, Y3_Annual_Fee__c, Y4_Annual_Fee__c, Y5_Annual_Fee__c, Risk_Due_Date__c
                                   from Contract__c 
                                   where Id = :((Contract__c)stdcon.getRecord()).id];
            
            //VH added for CR-8871
            if (sourceContract == null || sourceContract.Source_Opportunity__c == null) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.Contract_No_Opportunity_Error));
                hasError = true;
                return;
            }
            
            //V1.4 - Rajeev Jain  - CR-20151202-9434 - 12/07/2015 - Added field(Pool_Month__c,Renewal_Negotiated_Adjustment__c,Opt_Out_Date__c) in query to prepopulate source data
            this.sourceOpp = [select Name, CloseDate, RecordtypeID, RecordType.Name, RecordType.DeveloperName, Membership__c, Marketing_Associate__c, Marketer__c,
                              Start__c, End__c, Previous_Year_Negotiated__c, Amount, Signed_Opportunity_Contract__c, StageName, OwnerID, Owner.Name, AccountID,
                              Renewal_Negotiated__c, Pool_Year__c, Renewal_Negotiated_Adjustment__c, Pool_Month__c, Opt_Out_Date__c
                              from Opportunity 
                              where Id = :sourceContract.Source_Opportunity__c];
            //V1.4 - Rajeev Jain  - CR-20151202-9434 - 12/07/2015  - Upto here 
            
            displayList = new list<xopp>();
            
            maxnamelength = Opportunity.Name.getDescribe().getLength();
          
            //Only make Opps if Years in Term is populated
            if (sourceContract.Years_In_Term__c != null) MakeOppList();
        }
    }
    
    public PageReference saveAll()
    {
        // bypass some triggers due to soql limit
        Util.IsBatch = true;
        Util.BypassContactRestrictionTrigger = true;
            
        // try/catch to catch any errors
        try {
            //Modify Opp records as necessary, and save entired displayed list.
            list<Opportunity> oppstoinsert = new list<Opportunity>();
            map<Integer, Opportunity> rownumber2oppmap = new map<Integer, Opportunity>();
            Opportunity renewalopp = new Opportunity();
            
            for (xopp xo : displaylist) {
                
                //If row was added, it will have no CloseDate, a required field. Set it to today or day before Start
                if (xo.opp.CloseDate == null) {
                    xo.opp.CloseDate = system.today();
                    if (xo.opp.Start__c != null) xo.opp.CloseDate = xo.opp.Start__c.addDays(-1);
                }
                
                //set CloseDate to today on all opps if Decision Type = 'Fixed Term', otherwise go with original defaults
                if (xo.opp.Decision_Type__c == 'Fixed Term') xo.opp.CloseDate = system.today();
                
                //Renewal Opp                   
                if (xo.opprole == 'rirenewal' || xo.opprole == 'ptrenewal' || xo.opprole == 'tdrenewal') 
                {
                    renewalopp = xo.opp;
                    
                    //Proposal value on the final contract renewal opportunity that is saved should be populated with the ‘previous year negotiated’ amount.
                    xo.opp.Amount = xo.opp.Previous_Year_Negotiated__c;
                }
                
                //update or insert
                if (xo.opp.id != null) {
                    //Should only be 1 Opp with an ID already, the source opp
                    update xo.opp;
                } else {
                    oppstoinsert.add(xo.opp); 
                }
            }
            
            
            if (oppstoinsert.size() > 0) insert oppstoinsert;
            Set<Id> contractIdSet = new Set<Id> {sourceContract.Id};
            
            //Bhavi Sharma - 04/26/2013 - CR-20130227-2597 - Added condition to make the callout only if not current context is not batch or future
            if(!System.isFuture() && !System.isBatch())
                GlobalUtilities.ConnectDocsToOpp(contractIdSet);
            
            Util.IsBatch = false;
            
            //populate map of Opportunities with row numbers to preserve order
            for (Integer i = 0; i < displaylist.size(); i++) {
                
                rownumber2oppmap.put(displaylist[i].rownumber, displaylist[i].opp);
            }
     
            
            //go through and update new opps with Parent Opportunity values and new 'Primary' Contact Roles if necessary, starting with the first CM opp. 
            list<OpportunityContactRole> newocrs = new list<OpportunityContactRole>();
            list<Opportunity> oppstoupdate = new list<Opportunity>();
            for (Integer i = 2; i <= displaylist.size(); i++) {
                Opportunity thisopp = rownumber2oppmap.get(i);
                Opportunity previousopp = rownumber2oppmap.get(i-1);
               
                //Link created Opps together through Parent Opportunity
                thisopp.Parent_Opportunity__c = previousopp.Id;
                oppstoupdate.add(thisopp);
            
                //add Contact Roles for Main Contacts if there are any  
                if (thisopp.Main_Contact__c != null) {
                    OpportunityContactRole newocr = new OpportunityContactRole(
                        OpportunityID = thisopp.id,
                        ContactID = thisopp.Main_Contact__c,
                        IsPrimary = true);
                    newocrs.add(newocr);
                }
            }
            
            //Insert new OpportunityContactRoles
            if (newocrs.size() > 0) insert newocrs;
            
            //Update Opportunities
            if (oppstoupdate.size() > 0) update oppstoupdate;
            
            //Update Contract Renewal Opp field 
            sourceContract.Contract_Renewal_Opportunity__c = renewalopp.id; 
            update sourceContract;
        }
        catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            return null;
        }
        
        //Leave them back at Contract page
        Pagereference pageref = new PageReference('/' + sourceContract.id);
        return pageref;
    }
    
    //V1.4 - Modified By - Rajeev Jain  - CR-20151202-9434 - 12/07/2015v - PrePopulate Source Opportunity fields
    public PageReference addRow()
    {
        //If requested, add a row for a new Contract Maintenance opp
        xopp newxopp;
        
        //Initialize if found null
        displaylist = displaylist == null ? new list<xopp>() : displaylist;
        
        Integer rownumber = displaylist.size() + 2;
            
        Date startDate, endDate;
        
        //Hold counter of the next element added in the list
        Integer count = displaylist.size();
        
        //Get Start date of Last Added Rows in Display List
        if(displaylist.size() > 0){
            startDate = displaylist[displaylist.size()-1].opp.Start__c;
            startDate = startDate != null ? startDate.addYears(1) : null;
            endDate = startDate != null ? startDate.addYears(1).addDays(-1) : null;
        }
        //Commented by Mahendra Swarnkar - 03/17/2020 - CR-20200217-13756 - RT deleted :RI AM Standard Opp
        /*if (sourceOpp.Recordtype.Name.contains('RI')){
            //Commented by Mahendra Swarnkar - 03/17/2020 - CR-20200217-13756 - RT deleted :RI AM Standard Opp
            //1 RI AM Standard Opp (CM)
            /*newxopp = new xopp(new Opportunity(
                RecordtypeID = opprtmap.get('RI AM Standard Opp'),
                Previous_Contract__c = sourceContract.Id,
                AccountID = sourceContract.Payer_Account__c,
                Program__c = sourceContract.Program__c,
                Main_Contact__c = sourceContract.Main_Contact__c,
                Opt_Out_Date__c = sourceContract.Risk_Due_Date__c,
                Renewal_Negotiated_Adjustment__c = sourceOpp.Renewal_Negotiated_Adjustment__c,
                Start__c = startDate,
                End__c = endDate
            ));
            newxopp.opp.Name = makeOppName(newxopp.opp);
            
            newxopp.opprole = 'ristandard';
            newxopp.rownumber = rownumber;
            newxopp.RecordTypeName = 'RI AM Standard Opp (CM)';
            newxopp.oppRecordTypeDeveloperName = sourceOpp.Recordtype.DeveloperName;
            displaylist.add(newxopp);
        } else if (sourceOpp.Recordtype.Name.contains('TD')){
            //Commented by Mahendra Swarnkar - 03/17/2020 - CR-20200217-13756 - RT deleted :TD AM Standard Opp From Opportunity
            /*newxopp = new xopp(new Opportunity(
                RecordtypeID = opprtmap.get('TD AM Standard Opp'),
                Previous_Contract__c = sourceContract.Id,
                AccountID = sourceContract.Payer_Account__c,
                Program__c = sourceContract.Program__c,
                Main_Contact__c = sourceContract.Main_Contact__c,
                Opt_Out_Date__c = sourceContract.Risk_Due_Date__c,
                Renewal_Negotiated_Adjustment__c = sourceOpp.Renewal_Negotiated_Adjustment__c,
                Start__c = startDate,
                End__c = endDate
            ));
            newxopp.opp.Name = makeOppName(newxopp.opp);
            
            newxopp.opprole = 'tdstandard';
            newxopp.rownumber = rownumber;
            //newxopp.RecordTypeName = 'TD AM Standard Opp';
            newxopp.oppRecordTypeDeveloperName = sourceOpp.Recordtype.DeveloperName;
            displaylist.add(newxopp);
        } else End */if (sourceOpp.Recordtype != null) {
            
            //1 BI Contract Maintenance
            newxopp = new xopp(new Opportunity(
                RecordtypeID = opprtmap.get('PT Contract Maintenance'),
                Previous_Contract__c = sourceContract.Id,
                AccountID = sourceContract.Payer_Account__c,
                Program__c = sourceContract.Program__c,
                Main_Contact__c = sourceContract.Main_Contact__c,
                Opt_Out_Date__c = sourceContract.Risk_Due_Date__c,
                Renewal_Negotiated_Adjustment__c = sourceOpp.Renewal_Negotiated_Adjustment__c,
                Start__c = startDate,
                End__c = endDate
            ));
            newxopp.opp.Name = makeOppName(newxopp.opp);
            
            newxopp.opprole = 'ptcontractmaint';
            newxopp.rownumber = rownumber;
            newxopp.RecordTypeName = 'PT Contract Maintenance';
            newxopp.oppRecordTypeDeveloperName = sourceOpp.Recordtype.DeveloperName;
            displaylist.add(newxopp);
        }
        
        //Repopulate Opportunity Table Fields based on what in start and end date
        if(displaylist[count].opp.Start__c != null){
            
            displaylist[count].opp.Pool_Year__c = displaylist[count].opp.Start__c.year()  + '';
            displaylist[count].opp.Pool_Month__c = displaylist[count].opp.Start__c.month() + '';
            
            //Commented by Mahendra Swarnkar - 03/17/2020 - CR-20200217-13756 - RT deleted : Consulting & Management From Opportunity.
             //If Source Apportunity is a NBB opp (Record Type = RI Marketing/PT Marketing/Southwind), then set Pool Month default to 0
            if(/*displaylist[count].oppRecordTypeDeveloperName == OPPORTUNITY_RECORDTYPE_DEVELOPER_NAME_SOUTHWIND ||*/
               displaylist[count].oppRecordTypeDeveloperName == OPPORTUNITY_RECORDTYPE_DEVELOPER_NAME_PT_MARKETING ||
               displaylist[count].oppRecordTypeDeveloperName == OPPORTUNITY_RECORDTYPE_DEVELOPER_NAME_RI_MARKETING)
                
                displaylist[count].opp.Pool_Month__c = '0';       
            else
                displaylist[count].opp.Pool_Month__c = displaylist[count].opp.Start__c.month() + ''; 
        }
        
        //check for five individaul years and populate data based on that
        /** Negotiated Amount “Y# Annual Fee” (corresponding to which year of the contract it is
        Previous Year Negotiated “Y(#-1) Annual Fee”
        **/    
        if(count != 0)
            displaylist[count].opp.Renewal_Negotiated_Adjustment__c  = 0;  
        if(count == 0)
            displaylist[count].opp.Renewal_Negotiated__c = sourceContract.Y1_Annual_Fee__c;
        else if(count == 1){
            displaylist[count].opp.Renewal_Negotiated__c = sourceContract.Y2_Annual_Fee__c;
            displaylist[count].opp.Previous_Year_Negotiated__c = sourceContract.Y1_Annual_Fee__c;
        }else if(count == 2){
            displaylist[count].opp.Renewal_Negotiated__c = sourceContract.Y3_Annual_Fee__c;
            displaylist[count].opp.Previous_Year_Negotiated__c = sourceContract.Y2_Annual_Fee__c;    
        }else if(count == 3){
            displaylist[count].opp.Renewal_Negotiated__c = sourceContract.Y4_Annual_Fee__c;
            displaylist[count].opp.Previous_Year_Negotiated__c = sourceContract.Y3_Annual_Fee__c;
        }else if(count == 4){
            displaylist[count].opp.Renewal_Negotiated__c = sourceContract.Y5_Annual_Fee__c;
            displaylist[count].opp.Previous_Year_Negotiated__c = sourceContract.Y4_Annual_Fee__c;
        }
        
        Pagereference pageref = null;
        return pageref;
    }
    
    public PageReference deleteSelected()
    {
        //Remove one or more of the contract maintenance Opps from the display list
        
        //make new list with new rownumbers
        list<xopp> newdisplaylist = new list<xopp>();
        Integer count = 1;
        
        for (xopp xo : displaylist) {
            //only add the unselected rows to new list      
            if (!xo.Selected) {
                xo.rownumber = count;
                count++;
                newdisplaylist.add(xo);
            }
        }
        displaylist = newdisplaylist;
        
        Pagereference pageref = null;
        return pageref;
    }
    
    public PageReference cancelAll()
    {
        //Cancel Operation and return to Contract page
        Pagereference pageref = new PageReference('/' + sourceContract.Id);
        return pageref;
    }
    
    private String makeOppName(Opportunity o) {
        
        //Commented by Subhash Garhwal - 07/21/2016 - CR-20160414-9762
        //Added by Colin McGloin - 06/28/2016 - CR-20160414-9762
        /*Set <Id> programOppIds = new Set <Id>();
        programOppIds.add(opprtmap.get('Program_Consulting_Management'));
        programOppIds.add(opprtmap.get('Program_PT_Maintenance'));
        programOppIds.add(opprtmap.get('Program_PT_Marketing'));
        programOppIds.add(opprtmap.get('Program_PT_Renewal'));
        programOppIds.add(opprtmap.get('Program_RI_Maintenance'));
        programOppIds.add(opprtmap.get('Program_RI_Marketing'));
        programOppIds.add(opprtmap.get('Program_RI_Renewal'));
        */
        //Standard naming convention for Opps
        String suffix;
        String acronym = ' - ' + sourceContract.Program__r.Program_Acronym__c + ' - ';
        String accname = sourceContract.Payer_Account__r.Name;
        
        //Commented by Subhash Garhwal - 07/21/2016 - CR-20160414-9762
        //Determine NBB or Renewal and construct last part of oppname
        //Commented by Mahendra Swarnkar - 03/17/2020 - CR-20200217-13756 - RT deleted : Program – PT Marketing,Program – RI Marketing	
        //if(!(programOppIds.contains(o.RecordTypeId))){
            if ((o.Recordtype.Name == 'RI Marketing') || (o.Recordtype.Name == 'PT Marketing')
                /*|| o.RecordType.DeveloperName == CPQConstants.OPPORTUNITY_RECORD_TYPE_DEVELOPERNAME_PROGRAM_RI_MARKETING
                || o.RecordType.DeveloperName == CPQConstants.OPPORTUNITY_RECORD_TYPE_DEVELOPERNAME_PROGRAM_PT_MARKETING*/) {
                suffix = o.CloseDate.year() + ' NBB';
            } else {
                if (o.Pool_Year__c != null) {
                    suffix = o.Pool_Year__c + ' Renewal';
                } else {
                    suffix = ' Renewal';
                } 
            }
        //}
        
        //see how much of the account name we can use
        Integer maxaccountnamelength = 55;
        
        //truncate account name if necessary
        accname = accname.substring(0,Math.min(accname.length(), maxaccountnamelength));
        
        //build final name
        String newname = accname + acronym + suffix;
        
        return newname;
    }
    //V1.4 - Modified By - Rajeev Jain  - CR-20151202-9434 - 12/07/2015v - PrePopulate Source Opportunity fields
    public void makeOppList()
    {
        //Make list of Opportunities to display on page. This includes the source Opp as well as contract maintenance and renewal opps
        displaylist = new list<xopp>();
        Integer rowindex = 1;
        Date StartDate = sourceContract.Start__c;
        
        //modify original (source) opportunity and add to list
        sourceOpp.Start__c = StartDate;
        sourceOpp.End__c = StartDate.addYears(1).addDays(-1);
        sourceOpp.Name = makeOppName(sourceOpp);
        sourceOpp.Opt_Out_Date__c = sourceContract.Risk_Due_Date__c;
        
        xopp newxopp = new xopp(sourceOpp);
        newxopp.opprole = 'source';
        newxopp.rownumber = rowindex;
        newxopp.oppRecordTypeDeveloperName = sourceOpp.RecordType.DeveloperName;
        rowindex++;
        displaylist.add(newxopp);
        
        StartDate = StartDate.addYears(1);
            
        //RI
        if (sourceOpp.Recordtype.Name.contains('RI')) {
            
            //First Opp (RI First Year if NBB, else RI AM Standard)
            newxopp = new xopp(new Opportunity(
                Previous_Contract__c = sourceContract.Id,
                AccountID = sourceContract.Payer_Account__c,
                CloseDate = StartDate.addDays(-1),
                Start__c = StartDate,
                Program__c = sourceContract.Program__c,
                Pool_Year__c = sourceOpp.Pool_Year__c,
                Pool_Month__c = sourceOpp.Pool_Month__c,
                Renewal_Negotiated__c = sourceOpp.Renewal_Negotiated__c,
                Previous_Year_Negotiated__c = sourceOpp.Previous_Year_Negotiated__c,
                /*Opt_Out_Date__c = sourceOpp.Opt_Out_Date__c,*/
                Opt_Out_Date__c = sourceContract.Risk_Due_Date__c,
                Renewal_Negotiated_Adjustment__c = sourceOpp.Renewal_Negotiated_Adjustment__c
            ));
            
            newxopp.opp.Name = makeOppName(newxopp.opp);
            
            if (sourceOpp.Recordtype.Name == 'RI Marketing') {
                //Commented by Mahendra Swarnkar - 03/17/2020 - CR-20200217-13756 - RT deleted :RI AM First Year Opp
                /*newxopp.RecordTypeName = 'RI AM First Year Opp';
                newxopp.opp.RecordtypeID = opprtmap.get('RI AM First Year Opp');*/
            } 
            //Commented by Mahendra Swarnkar - 03/17/2020 - CR-20200217-13756 - RT deleted :RI AM Standard Opp
            /*else {
                newxopp.RecordTypeName = 'RI AM Standard Opp';
                newxopp.opp.RecordtypeID = opprtmap.get('RI AM Standard Opp');
            }*/
            
            if (sourceContract.Years_In_Term__c == 1) {
                newxopp.opprole = 'rirenewal';
                newxopp.opp.End__c = null;
                newxopp.opp.Decision_Type__c = 'Need New LOA';
                newxopp.RecordTypeName += ' (Renewal)';
            } else {
                newxopp.opprole = 'rifirstyear';
                newxopp.opp.End__c = StartDate.addYears(1).addDays(-1);
                newxopp.RecordTypeName += ' (CM)';
            }
            newxopp.rownumber = rowindex;
            newxopp.oppRecordTypeDeveloperName = sourceOpp.RecordType.DeveloperName;
            rowindex++;
            displaylist.add(newxopp);
            
            //Running Start Date for creating Opps
            StartDate = StartDate.addYears(1);
            
            //Create the "middle" CM opps
            for (Integer y = 1; y <= (sourceContract.Years_In_Term__c - 2); y++) {
                //Commented by Mahendra Swarnkar - 03/17/2020 - CR-20200217-13756 - RT deleted :RI AM Standard Opp
                //1 RI AM Standard Opp (CM)
                /*newxopp = new xopp(new Opportunity(
                    RecordtypeID = opprtmap.get('RI AM Standard Opp'),
                    Previous_Contract__c = sourceContract.Id,
                    AccountID = sourceContract.Payer_Account__c,
                    CloseDate = StartDate.addDays(-1),
                    Start__c = StartDate,
                    End__c = StartDate.addYears(1).addDays(-1),
                    Program__c = sourceContract.Program__c,
                    Pool_Year__c = sourceOpp.Pool_Year__c,
                    Pool_Month__c = sourceOpp.Pool_Month__c,
                    Renewal_Negotiated__c = sourceOpp.Renewal_Negotiated__c,
                    Previous_Year_Negotiated__c = sourceOpp.Previous_Year_Negotiated__c,
                    //Opt_Out_Date__c = sourceOpp.Opt_Out_Date__c,
                    Opt_Out_Date__c = sourceContract.Risk_Due_Date__c,
                    Renewal_Negotiated_Adjustment__c = sourceOpp.Renewal_Negotiated_Adjustment__c
                ));*/
                newxopp.opp.Name = makeOppName(newxopp.opp);
                newxopp.RecordTypeName = 'RI AM Standard Opp (CM)';
                newxopp.opprole = 'ristandard';
                newxopp.rownumber = rowindex;
                newxopp.oppRecordTypeDeveloperName = sourceOpp.RecordType.DeveloperName;
                rowindex++;
                displaylist.add(newxopp);
                
                StartDate = StartDate.addYears(1);
            
            }
            
            //Special RI Case: On 1 year term, the First Year opp is also the Renewal opp. 
            //Only do the following if that's not true
            if (sourceContract.Years_In_Term__c != 1) {
                //Commented by Mahendra Swarnkar - 03/17/2020 - CR-20200217-13756 - RT deleted :RI AM Standard Opp
                //1 RI AM Standard Opp (Renewal)
                /*newxopp = new xopp(new Opportunity(
                    RecordtypeID = opprtmap.get('RI AM Standard Opp'),
                    Previous_Contract__c = sourceContract.Id,
                    AccountID = sourceContract.Payer_Account__c,
                    CloseDate = StartDate.addDays(-1),
                    Start__c = StartDate,
                    End__c = null, //StartDate.addYears(1).addDays(-1),
                    Program__c = sourceContract.Program__c,
                    Pool_Year__c = sourceOpp.Pool_Year__c,
                    Pool_Month__c = sourceOpp.Pool_Month__c,
                    Renewal_Negotiated__c = sourceOpp.Renewal_Negotiated__c,
                    Previous_Year_Negotiated__c = sourceOpp.Previous_Year_Negotiated__c,
                    //Opt_Out_Date__c = sourceOpp.Opt_Out_Date__c,
                    Opt_Out_Date__c = sourceContract.Risk_Due_Date__c,
                    Renewal_Negotiated_Adjustment__c = sourceOpp.Renewal_Negotiated_Adjustment__c
                    ));*/
                newxopp.opp.Name = makeOppName(newxopp.opp);
                newxopp.opp.Decision_Type__c = 'Need New LOA';
                newxopp.opprole = 'rirenewal';
                newxopp.rownumber = rowindex;
                newxopp.RecordTypeName = 'RI AM Standard Opp (Renewal)';
                newxopp.oppRecordTypeDeveloperName = sourceOpp.RecordType.DeveloperName;
                rowindex++;
                displaylist.add(newxopp);
            } 
        //PT
        } else if (sourceOpp.Recordtype.Name.contains('PT')) {
            
            for (Integer y = 1; y <= (sourceContract.Years_In_Term__c - 1); y++) {
                //1 PT Contract Maintenance
                newxopp = new xopp(new Opportunity(
                    RecordtypeID = opprtmap.get('PT Contract Maintenance'),
                    Previous_Contract__c = sourceContract.Id,
                    AccountID = sourceContract.Payer_Account__c,
                    CloseDate = StartDate.addDays(-1),
                    Start__c = StartDate,
                    End__c = StartDate.addYears(1).addDays(-1),
                    Program__c = sourceContract.Program__c,
                    Pool_Year__c = sourceOpp.Pool_Year__c,
                    Pool_Month__c = sourceOpp.Pool_Month__c,
                    Renewal_Negotiated__c = sourceOpp.Renewal_Negotiated__c,
                    Previous_Year_Negotiated__c = sourceOpp.Previous_Year_Negotiated__c,
                    /*Opt_Out_Date__c = sourceOpp.Opt_Out_Date__c,*/
                    Opt_Out_Date__c = sourceContract.Risk_Due_Date__c,
                    Renewal_Negotiated_Adjustment__c = sourceOpp.Renewal_Negotiated_Adjustment__c
                ));
                newxopp.opp.Name = makeOppName(newxopp.opp);
            
                newxopp.opprole = 'ptcontractmaint';
                newxopp.rownumber = rowindex;
                newxopp.RecordTypeName = 'PT Contract Maintenance';
                newxopp.oppRecordTypeDeveloperName = sourceOpp.RecordType.DeveloperName;
                rowindex++;
                displaylist.add(newxopp);
            
                StartDate = StartDate.addYears(1);
            
            }
            
            //1 PT Contract Renewal
            newxopp = new xopp(new Opportunity(
                RecordtypeID = opprtmap.get('PT Contract Renewal'),
                Previous_Contract__c = sourceContract.Id,
                AccountID = sourceContract.Payer_Account__c,
                CloseDate = StartDate.addDays(-1),
                Start__c = StartDate,
                End__c = null, //StartDate.addYears(1).addDays(-1),
                Program__c = sourceContract.Program__c,
                Pool_Year__c = sourceOpp.Pool_Year__c,
                Pool_Month__c = sourceOpp.Pool_Month__c,
                Renewal_Negotiated__c = sourceOpp.Renewal_Negotiated__c,
                Previous_Year_Negotiated__c = sourceOpp.Previous_Year_Negotiated__c,
                /*Opt_Out_Date__c = sourceOpp.Opt_Out_Date__c,*/
                Opt_Out_Date__c = sourceContract.Risk_Due_Date__c,
                Renewal_Negotiated_Adjustment__c = sourceOpp.Renewal_Negotiated_Adjustment__c
                ));
            newxopp.opp.Name = makeOppName(newxopp.opp);
            newxopp.opp.Decision_Type__c = 'Need New LOA';
            newxopp.opprole = 'ptrenewal';
            newxopp.rownumber = rowindex;
            newxopp.RecordTypeName = 'PT Contract Renewal';
            newxopp.oppRecordTypeDeveloperName = sourceOpp.RecordType.DeveloperName;
            rowindex++;
            displaylist.add(newxopp);
        }  else if (sourceOpp.Recordtype.Name.contains('TD')) {
            
            for (Integer y = 1; y <= (sourceContract.Years_In_Term__c - 1); y++) {
                //Commented by Mahendra Swarnkar - 03/17/2020 - CR-20200217-13756 - RT deleted :TD AM Standard Opp From Opportunity
                //1 PT Contract Maintenance
                /*newxopp = new xopp(new Opportunity(
                    RecordtypeID = opprtmap.get('TD AM Standard Opp'),
                    Previous_Contract__c = sourceContract.Id,
                    AccountID = sourceContract.Payer_Account__c,
                    CloseDate = StartDate.addDays(-1),
                    Start__c = StartDate,
                    End__c = StartDate.addYears(1).addDays(-1),
                    Program__c = sourceContract.Program__c,
                    Pool_Year__c = sourceOpp.Pool_Year__c,
                    Pool_Month__c = sourceOpp.Pool_Month__c,
                    Renewal_Negotiated__c = sourceOpp.Renewal_Negotiated__c,
                    Previous_Year_Negotiated__c = sourceOpp.Previous_Year_Negotiated__c,
                    //Opt_Out_Date__c = sourceOpp.Opt_Out_Date__c,
                    Opt_Out_Date__c = sourceContract.Risk_Due_Date__c,
                    Renewal_Negotiated_Adjustment__c = sourceOpp.Renewal_Negotiated_Adjustment__c
                ));*/
                newxopp.opp.Name = makeOppName(newxopp.opp);
            
                newxopp.opprole = 'tdrenewal';
                newxopp.rownumber = rowindex;
                //newxopp.RecordTypeName = 'TD AM Standard Opp';
                newxopp.oppRecordTypeDeveloperName = sourceOpp.RecordType.DeveloperName;
                rowindex++;
                displaylist.add(newxopp);
            
                StartDate = StartDate.addYears(1);
            
            }
        }
        
        //fill in fields that are the same for all Opps
        Integer count = 0;
        for (xopp x : displaylist) {
            
            x.opp.Name = makeOppName(x.opp);
            if (sourceContract.Main_Contact__c != null) {
                x.opp.Main_Contact__c = sourceContract.Main_Contact__c;
                
                //Repopulate Opportunity Table Fields based on what in start and end date
                if(x.opp.Start__c != null){ 
                    
                    x.opp.Pool_Year__c = x.opp.Start__c.year()  + '';
                    
                    //Commented by Mahendra Swarnkar - 03/17/2020 - CR-20200217-13756 - RT deleted : Consulting & Management From Opportunity.
                    //If Source Apportunity is a NBB opp (Record Type = RI Marketing/PT Marketing/Southwind), then set Pool Month default to 0
                    if(/*x.oppRecordTypeDeveloperName == OPPORTUNITY_RECORDTYPE_DEVELOPER_NAME_SOUTHWIND ||*/
                       x.oppRecordTypeDeveloperName == OPPORTUNITY_RECORDTYPE_DEVELOPER_NAME_PT_MARKETING ||
                       x.oppRecordTypeDeveloperName == OPPORTUNITY_RECORDTYPE_DEVELOPER_NAME_RI_MARKETING)
                        
                        x.opp.Pool_Month__c = '0';       
                    else
                        x.opp.Pool_Month__c = x.opp.Start__c.month() + '';    
                }
                
                //check for five individaul years and populate data based on that
                /** Negotiated Amount “Y# Annual Fee” (corresponding to which year of the contract it is
                    Previous Year Negotiated “Y(#-1) Annual Fee”
                **/
                if(count < displaylist.size()){
                    //x.opp.Renewal_Negotiated__c = sourceContract.Y1_Annual_Fee__c;
                    // CR-20151202-9434 - Rajeev - 12/09/2015 - UAT Changes -As per the new changes from UAT top NBB Line should be blank for Negotiated field
                    // for first row Renewal_Negotiated_Adjustment__c should be zero
                    if(count != 0)
                        x.opp.Renewal_Negotiated_Adjustment__c  = 0;   
                    if(count == 0){
                        x.opp.Renewal_Negotiated__c = 0;
                        
                        //Commented by Mahendra Swarnkar - 03/17/2020 - CR-20200217-13756 - RT deleted : Consulting & Management From Opportunity.
                        if(/*x.oppRecordTypeDeveloperName == OPPORTUNITY_RECORDTYPE_DEVELOPER_NAME_SOUTHWIND ||*/
                            x.oppRecordTypeDeveloperName == OPPORTUNITY_RECORDTYPE_DEVELOPER_NAME_PT_MARKETING ||
                            x.oppRecordTypeDeveloperName == OPPORTUNITY_RECORDTYPE_DEVELOPER_NAME_RI_MARKETING)
                            x.opp.Decision_Type__c = DECISION_TYPE_DEFAUL_VALUE_NEED_NEW_LOA;
                    }else if(count == 1){
                        x.opp.Renewal_Negotiated__c = sourceContract.Y2_Annual_Fee__c;
                        x.opp.Previous_Year_Negotiated__c = sourceContract.Y1_Annual_Fee__c;
                    }else if(count == 2){
                        x.opp.Renewal_Negotiated__c = sourceContract.Y3_Annual_Fee__c;
                        x.opp.Previous_Year_Negotiated__c = sourceContract.Y2_Annual_Fee__c;    
                    }else if(count == 3){
                        x.opp.Renewal_Negotiated__c = sourceContract.Y4_Annual_Fee__c;
                        x.opp.Previous_Year_Negotiated__c = sourceContract.Y3_Annual_Fee__c;
                    }else if(count == 4){
                        x.opp.Renewal_Negotiated__c = sourceContract.Y5_Annual_Fee__c;
                        x.opp.Previous_Year_Negotiated__c = sourceContract.Y4_Annual_Fee__c;
                    }
                    count++;
                }    
            }       
        }
        
    }
}