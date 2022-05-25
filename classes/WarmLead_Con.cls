public with sharing class WarmLead_Con {

    Campaign camp;
    list<Warm_Lead__c> newWLs = new list<Warm_Lead__c>();
    list<CampaignMember> cmlist;
    list<cmember> displaylist = new list<cmember>();
    Boolean IsAllSelected = false;
    map<id, Boolean> cmid2selectedmap; //keep track of selected campaignmembers
    
    //DAF - added 8/21/11
    public Event Evt {get; set;}

    //filtering by status
    list<SelectOption> filteroptions;
    String currentFilter = 'Show All';
    set<String> liststatuses = new set<String>(); //only statuses in this list right here.
    static set<String> CM_Statuses = new set<String> { //all applicable statuses
        'Registered', 
        'Attended', 
        'New (not invited yet)', 
        'Invitation Sent',
        'Confirmation Requested'
    };
    
    //Sorting
    AP_SortHelper sorter = new AP_SortHelper(); //open source utility class. See SortBy()
    String SortedBy = 'Status'; //Default
    Boolean sortAscending = true;
    
    public WarmLead_Con() 
    {
        // DAF - added 8/21/11
        Evt = new Event();
        Evt.ActivityDate = date.today();

         //Get current Campaign and list of CMs from query
         refreshCMlist();
         
         //make new list of cmembers
         refreshdisplaylist();
    }
    
    public Campaign getcamp() { return camp; }
    
    public list<cmember> getCMembers() { return displaylist; }
    public void setCMembers( list<cmember> dl) { 
        displaylist = dl; 
        system.debug('\n\n40set ' + dl);        
        
        //get Selected values from displaylist, in case we mess it up later.
        for ( cmember c : displaylist) {
            
            cmid2selectedmap.put(c.cm.id, c.Selected);
            system.debug('\n\nputting ' + c.LastName + ' is ' + c.Selected);            
        }
    }
    
    public Boolean getIsAllSelected() { return IsAllSelected; }
    public void setIsAllSelected(Boolean ias) { IsAllSelected = ias; }
    
    public list<SelectOption> getfilteroptions() 
    { 
        //create list of status filters to choose from      
        filteroptions = new list<SelectOption>();
        filteroptions.add(new SelectOption('Show All','Show All'));
        
        list<AggregateResult> ars = [select Status from CampaignMember where CampaignID = :this.camp.id group by Status];
        
        for (AggregateResult ar : ars) {
            filteroptions.add(new SelectOption((String)ar.get('Status'),(String)ar.get('Status')));
        }
        
        return filteroptions; 
    }
    
    public String getcurrentFilter() { return currentFilter; }
    public void setcurrentFilter(String s) { 
    
        //if filter changed, get new list. Otherwise, do nothing.       
        if (currentFilter != s) {
            currentFilter = s; 
        
            //Get current Campaign and list of CMs from query
            refreshCMlist();
             
            //make new list of cmembers
            clearSelected();
            refreshdisplaylist();
        }
    }
    
    public class cmember {
        
        public CampaignMember cm { get; set;}
        
        //from Lead or Contact
        public String AccountName { get; set; }
        public String FirstName { get; set; } 
        public String LastName { get; set; }
        public String cmType { get; set; } //Contact or Lead
        public Id cmTypeId { get; set; }
        
        public Boolean Selected { get; set; } //checkboxes on page
        
        public cmember(CampaignMember cm) {
            this.cm = cm;
        }
        
    }
    
    
    public void fixCampaignMemberStatuses()
    {
        list <CampaignMemberStatus> currentstatuses = [select id, HasResponded, IsDefault, Label, SortOrder from CampaignMemberStatus where CampaignID = :camp.id];
        
        //determine what needs to be added
        set<String> currentset = new set<String>();
        set<String> needset = new set<String>();
        for (CampaignMemberStatus sts : currentstatuses) {
            currentset.add(sts.Label);
        }
        for (String s : WarmLead_Con.CM_Statuses) {
            if (!currentset.contains(s)) needset.add(s);
        }

        //make new statuses
        list<CampaignMemberStatus> newstatuses = new list<CampaignMemberStatus>();
        Integer counter = currentstatuses.size() + 5;
        for (String s : needset) {
            
            newstatuses.add(new CampaignMemberStatus(Label = s, CampaignID = camp.id, SortOrder = counter++));
        }
        insert newstatuses;
        
        //sort alphabetically
        currentstatuses = [select id, HasResponded, IsDefault, Label, SortOrder from CampaignMemberStatus where CampaignID = :camp.id order by Label];
        Integer sortorder = 0;          
        for (CampaignMemberStatus s : currentstatuses) {
            s.SortOrder = sortorder++;
        }
        update currentstatuses;
    }
    
    private void Sort() { cmlist = (List<CampaignMember>) sorter.getSortedList(cmlist,SortedBy, sortAscending); }
    
    private void SortBy(String value) 
    {        
        sortAscending = !sortAscending;        
        sortedBy = value;   
        
        Sort();
        
        //Turn CampaignMembers into cmembers
        refreshdisplaylist();
    }
    
    public PageReference DoneWithPage()
    {
        PageReference pageref = new PageReference('/' + camp.id);
        return pageref;
    }
    
    public PageReference refreshlist()
    {
        PageReference pageref = null;
        return pageref;
    }
    
    public PageReference MakeWarmLeads() {

    //DAF - 8/21-22/11 added line below
        if (Evt.ActivityDate == null) {
            Evt.ActivityDate = date.today();
        }

        list<Warm_Lead__c> warmleadstoinsert = new list<Warm_Lead__c>();
        list<CampaignMember> cmstoupdate = new list<CampaignMember>();
        map<id, Warm_Lead__c> cmid2wlmap = new map<id, Warm_Lead__c>();
        system.debug('\n\n166 camp channel ' + this.camp.Type);     
        for (cmember cm : displaylist) {
            system.debug('\n\n172inside loop ' + cm);
            //DAF - 8/21/11 added Marketer_Assignment__c, MA Assignment
            if ((cm.Selected == False) || (cm.cm.Warm_Lead_Created__c != null))
                continue; //skip unselected cmembers or already made Warm Leads
            
            //CR-3699 Updated by JRB
            String wlStatus;
            if(cm.cm.Warm_Lead_Status__c != null && cm.cm.Warm_Lead_Status__c != ''){
                wlStatus = cm.cm.Warm_Lead_Status__c;
            }else{
              wlStatus = 'Pending';  // DAF 8-28-11 changed from 'Pending Lead'
            }
            
            Warm_Lead__c newWL = new Warm_Lead__c(
                Name = cm.LastName + ' ' + cm.FirstName + ' - ' + cm.cm.Status,
                Status__c = wlStatus,  //CR-3699 Updated by JRB
                Contact__c = cm.cm.ContactID,
                Account__c = cm.cm.Contact.AccountID,
                Campaign__c = camp.id,
                Attendee_Status__c = cm.cm.Member_Attendee_Status__c, //CR-3292 Updated by CM
                
                //Commented and assign By Campaign Event field value - Bhavi Sharma - CR-20130220-2552 - 07/29/2013 
                //Lead_Channel__c = camp.Type,
                Lead_Channel__c = camp.Channel__c,
                
                //Code modified by - Bhavi Sharma - CR-20130220-2552 - 07/24/2013
                Lead_Origin__c = cm.cm.Member_Lead_Origin__c,
                
                //DAF - 8/21-22/11 added below fields
                Marketer_Assignment__c = cm.cm.Marketer_Assignment__c,
                Marketing_Associate_Assignment__c = cm.cm.MA_Assignment__c,
                Grade__c = cm.cm.Grade__c,
                Qualification_Status__c = cm.cm.Qualification_Status__c,
                Contact_level__c = cm.cm.Contact_level__c,
                Primary_Program__c = cm.cm.Primary_Program__c,
                Comments__c = cm.cm.Comments__c, 
                
                //DAF - 8/21/11 removed this line and added below               Lead_Date__c = system.today()
                Lead_Date__c = Evt.ActivityDate
                
            );
            System.debug('@@@###'+newWL);
            warmleadstoinsert.add(newWL);
            
            //keep track of CampaignMember and Warm lead together
            cmstoupdate.add(cm.cm);
            cmid2wlmap.put(cm.cm.id, newWL);
        }
        system.debug('\n\n187 warmleadstoinsert ' + warmleadstoinsert);     
        insert warmleadstoinsert;
        
        //set counter on Campaign
        camp.Total_Warm_Leads__c = [select count() from Warm_Lead__c where Campaign__c = :camp.id];
        update camp;
        
        //connect CampaignMembers back to Warm Leads now that Warm Leads have ids
        for (CampaignMember cm : cmstoupdate) {
            cm.Warm_Lead_Created__c = cmid2wlmap.get(cm.id).id;
        }
            
        update cmstoupdate;
        
        //Get current Campaign and list of CMs from query
        refreshCMlist();
         
        //make new list of cmembers, unselected
        clearSelected();
        refreshdisplaylist();
        
        PageReference pageref = null;
        return pageref;
    }
    
    public PageReference SelectAll()
    {
        PageReference pageref = null;
        
        for (Id i : cmid2selectedmap.keyset()) {
            cmid2selectedmap.put(i, IsAllSelected);
        }
        
        system.debug('\n\nselectall map is ' + cmid2selectedmap);       
        //make new list of cmembers with current Selected properties
        refreshdisplaylist();
        
        return pageref;
    }
    
    public void refreshCMlist()
    {
        //query this campaign with CMs
         if (ApexPages.CurrentPage().getParameters().get('camp') != null) {
            //DAF - 8/21-22/11 added Marketer_Assignment__c, MA_Assignment__c line
            String querystring = 'select id, Name, StartDate, Total_Warm_Leads__c, Type, Channel__c,' 
                + '(select id, Warm_Lead_Created__c, ContactID, Contact.FirstName, Contact.LastName, Contact.AccountID, Contact.Account.Name, ' 
                + 'Marketer_Assignment__c, MA_Assignment__c, Grade__c, Qualification_Status__c, Contact_level__c, Primary_Program__c, Comments__c, '
                + 'LeadID, Lead.FirstName, Lead.LastName, Lead.Company, Status, Member_Lead_Origin__c, Member_Attendee_Status__c, Warm_Lead_Status__c '
                + 'from CampaignMembers '
                + 'where HasResponded = true';
            
            //add status filter if there is one
            if (currentFilter != 'Show All') {
                querystring += ' and Status = \'' + currentFilter + '\' ';
            }
            
            querystring += ' order by Status asc) from Campaign '
                + 'where id = \'' + ApexPages.CurrentPage().getParameters().get('camp') + '\' ';
            system.debug('\n\nquerystring ' + querystring);     
            
            this.camp = (Campaign)Database.query(querystring);
            system.debug('\n\n246 camp ' + this.camp);          
            cmlist = this.camp.CampaignMembers; 
            
            system.debug('\n\ncmlistjeremy ' + cmlist);                 
         } else {
            this.camp = new Campaign();
            cmlist = new list<CampaignMember>();
         }
    }

    
    private void ClearSelected()
    // Clear all Selected checkboxes within map
    {
        system.debug('\n\n258Starting ClearSelected ' + cmid2selectedmap);      
        cmid2selectedmap = new map<id, Boolean>();
        for (CampaignMember cm : cmlist) {
            cmid2selectedmap.put(cm.id, FALSE);
        }
    }
    
    public void refreshdisplaylist()
    //turn list of CampaignMembers into list of cmembers
    {
        displaylist.clear();
        
        //Initialize Selected map if necessary
        if (cmid2selectedmap == null) ClearSelected();
        
        //go through cmlist and create new list of cmembers
        for (CampaignMember cm : cmlist) {
            cmember newcmember = new cmember(cm);
            newcmember.Selected = cmid2selectedmap.get(cm.id);
            if (cm.ContactID != null) {
            //Contact
                newcmember.cmType = 'Contact';
                newcmember.cmTypeId = cm.ContactID;
                newcmember.FirstName = cm.Contact.FirstName;
                newcmember.LastName = cm.Contact.LastName;
                newcmember.AccountName = cm.Contact.Account.Name;
            } else {
            //Lead
                newcmember.cmType = 'Lead';
                newcmember.cmTypeId = cm.LeadID;    
                newcmember.FirstName = cm.Lead.FirstName;
                newcmember.LastName = cm.Lead.LastName;
                newcmember.AccountName = cm.Lead.Company;
            }
            displaylist.add(newcmember);
        } //for cm : cmlist
    }
    
    public PageReference sortByStatus() {
        PageReference pageref = null;
        SortBy('Status');
        return pageref;
    }
    
}