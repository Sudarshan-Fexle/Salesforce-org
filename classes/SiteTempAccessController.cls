//Modified By Dipesh Gupta - CR-20190726-13240 - 08/06/2019 - Removed the Referece of "Temporary_Program_Access__c"
//Modified by Colin McGloin - CR-20190306-12917 - Removed getSiteType and getTypeFromApplicableSegment methods since we only have Education Site Profiles now
global class SiteTempAccessController {

    public final static String CONTACTQUERY_TEMPACCESS = 'SELECT Id, Name, AccountId, ' +
            '(SELECT Start_Date__c, Owner.Name, End_Date__c, CreatedBy.Name, Web_Program__r.Membership_Program__r.Applicable_Segments__c, Web_Program__r.Membership_Program__c, Web_Program__c, Site_Profile__c, '
            + 'Web_Program__r.Web_Program__c, Web_Program__r.Advisory_com_CS_Role__c, Web_Program__r.Program_Acronym__c, Web_Program__r.Program_Formal_Name__c, Web_Program__r.Web_Program__r.Description__c, '
            + 'Web_Program__r.Web_Program__r.Program_Code_to_Member__c, Web_Program__r.Web_Program__r.Advisory_com_CS_Role__c, Web_Program__r.Web_Program__r.A_com_Program_ID__c, Program_Acronym__c, Program_Formal_Name__c, '
            + 'Web_Program__r.Adv_com_Program_Id__c, Web_Program_Name__c FROM Temporary_Program_Access__r WHERE Start_Date__c <= TODAY AND End_Date__c >= TODAY LIMIT 1000),'
            + '(SELECT Id, Type__c FROM Site_Profiles__r)'
            + 'FROM Contact';
    
    // main contact
    public Contact MainContact { get; set; }
    public String ErrorString { get; set; }
    public boolean SaveSuccessful { get; set; }
    public Site_Profile__c siteProfile_EAB { get; set; }
    public Site_Profile__c siteProfile_Advisory { get; set; }
    
    public final static string STRING_EAB = 'EAB';
    public final static string STRING_ADVISORY = 'Advisory';
    
    //Added by Ajit Surana - 02/15/2014 - CR-20130528-3087
    //Set to hold Web Program Name string values
    private Set<String> setWebProgNames {
        get {
            if (setWebProgNames == null) setWebProgNames = new Set<String>();
            return setWebProgNames;
        }
        set;
    }
    
    
    // Temporary program access wrapper class
    global class TempAccess implements Comparable {
        
        // Implement the compareTo() method 
        
        global Integer compareTo(Object compareTo) {
            TempAccess compareToAcronym = (TempAccess)compareTo;
            if (ProgramAcronym == compareToAcronym.ProgramAcronym) return 0;
            if (ProgramAcronym > compareToAcronym.ProgramAcronym) return 1;
            return -1;        
        }
        
        public String ProgramDescription { get; set; }
        public String ProgramAcronym { get; set; }
        public String siteType { get; set; }
        public String applicableSegment { get; set; }
        public Integer Program_Id { get; set; }
        public String StartDate { get; set; }
        public String Expiration_Date { get; set; }
        public String Created_By { get; set; }
        public boolean HasAccess { get; set; }
        public boolean StartIsEditable { get; set; }
        public String Created_Date { get; set; }
        //public Id WebProgId { get; set; }
        public List<Web_Program_Access_MTM__c> WebProgMtMList { get; set; }
        public boolean NewItem { get; set; }
        public integer User_Id { get; set; }
        public String Modified_By { get; set; }
        /*public List<Temporary_Program_Access__c> TempProgAccessList {
            get {
                if (TempProgAccessList == null)
                    TempProgAccessList = new List<Temporary_Program_Access__c>();
                return TempProgAccessList;
            }
            set;
        }*/
        
        /*public TempAccess(List<Temporary_Program_Access__c> tpAccessList, boolean access) {
            ProgramDescription = tpAccessList[0].Program_Formal_Name__c;
            ProgramAcronym = tpAccessList[0].Web_Program__r.Program_Acronym__c;
            Program_Id = integer.valueOf(tpAccessList[0].Web_Program__r.Web_Program__r.A_com_Program_ID__c);
            StartDate = Date.valueOf(tpAccessList[0].Start_Date__c).format();
            Expiration_Date = Date.valueOf(tpAccessList[0].End_Date__c).format();
            Created_By = tpAccessList[0].Owner.Name;
            TempProgAccessList = tpAccessList;
            
            //get the applicable segment and use that to determine which siteType this program is associated with
            siteType = getSiteType(tpAccessList[0]);
            NewItem = false;
            
            if (Date.valueOf(tpAccessList[0].Start_Date__c) >= system.today())
                StartIsEditable = true;
            
            HasAccess = access;
            Modified_By = UserInfo.getName();
            
            system.debug('@@ProgramId:' + Program_Id);
        }*/
        
        public TempAccess (List<Web_Program_Access_MTM__c> wpAccessList, boolean access) {
            ProgramDescription = wpAccessList[0].Program_Formal_Name__c;
            ProgramAcronym = wpAccessList[0].Program_Acronym__c;
            Program_Id = integer.valueOf(wpAccessList[0].Web_Program__r.A_com_Program_ID__c);
            
            
            //get the applicable segment and use that to determine which siteType this program is associated with
            //Modified by Colin McGloin - CR-20190306-12917
            siteType = STRING_EAB;
            //WebProgId = wpAccess.Id;
            WebProgMtMList = wpAccessList;
            NewItem = true;
            StartDate = System.today().format();
            HasAccess = access;
            Modified_By = UserInfo.getName();
            Created_By = UserInfo.getName();
        }
        
        public TempAccess() { }
        
    }
    
     /**
    * @description:		return the site type, based on the Web Program
    *                   Modified by Colin McGloin - CR-20190306-12917 - Removed Method since we only have Education Site Profiles now
    *
    **/
    /*public static string getSiteType(Web_Program_Access_MTM__c webProgAccess) {
        return getTypeFromApplicableSegment(webProgAccess.Membership_Program__r.Applicable_Segments__c);
    }*/
    
    /**
    * @description:		return the site type, based on the Temp Access Program
    *
    **/
   /* public static string getSiteType(Temporary_Program_Access__c tempProgAccess) {
        return getTypeFromApplicableSegment(tempProgAccess.Web_Program__r.Membership_Program__r.Applicable_Segments__c);
    }*/
    
    /**
     * @description:	return the site type, based on the program's applicable segment
     *                  Modified by Colin McGloin - CR-20190306-12917 - Removed Method since we only have Education Site Profiles now
     * 
     **/
    /*public static string getTypeFromApplicableSegment(string applicableSegment) {
        if (applicableSegment != null && applicableSegment.containsIgnoreCase(SiteControllerHelper.STRING_EDUCATION)) {
        	return STRING_EAB;
        }
        
        return STRING_ADVISORY;
    }*/
    
    /**
    * @description:		get the Site Profile Id that is related to the same site as the webProgAccess's Program type
    *
    **/
    public string getSiteProfileId(Web_Program_Access_MTM__c webProgAccess) {
    	
    	//get the site type string
        //Modified by Colin McGloin - CR-20190306-12917
    	string siteType = STRING_EAB;
    	string siteProfileId;
    	
    	if (siteType == STRING_EAB && siteProfile_EAB != null)
        	siteProfileId = siteProfile_EAB.Id;
        else if (siteType == STRING_ADVISORY && siteProfile_Advisory != null)
        	siteProfileId = siteProfile_Advisory.Id;
        else
        	throw new customException('This contact does not have a Site Profile for ' + siteType + '.  Please create the site profile and try again.');
        
        return siteProfileId;
    }
    
    /**
    * @description:		get the Site Profile Id that is related to the same site as the tempProgAccess's Program type
    *
    **/
  /*  public string getSiteProfileId(Temporary_Program_Access__c tempProgAccess) {
    	
    	//get the site type string
    	string siteType = getSiteType(tempProgAccess);
    	string siteProfileId;
    	
    	if (siteType == STRING_EAB && siteProfile_EAB != null)
        	siteProfileId = siteProfile_EAB.Id;
        else if (siteType == STRING_ADVISORY && siteProfile_Advisory != null)
        	siteProfileId = siteProfile_Advisory.Id;
        else
        	throw new customException('This contact does not have a Site Profile for ' + siteType + '.  Please create the site profile and try again.');
        
        return siteProfileId;
    }*/
    
  /*  public PageReference SaveTempAccess() {
        // reset error msg
        ErrorString = '';
        SaveSuccessful = false;
        
        List<Temporary_Program_Access__c> tempAccessToUpsert = new List<Temporary_Program_Access__c>();
        List<Temporary_Program_Access__c> tempAccessToDelete = new List<Temporary_Program_Access__c>();
        
        for (list<TempAccess> taList : mapTempAccess.values()) {
	        for (TempAccess tAccess : taList) {
	            
	            if ((tAccess.newItem && tAccess.HasAccess) || (tAccess.TempProgAccessList.size() != 0 && tAccess.HasAccess)) {
	                
	                system.debug('@@Add/Update:' + tAccess);
	                try {
	                    
	                    if (tAccess.TempProgAccessList.isEmpty()) {
	                        for (Web_Program_Access_MTM__c webProgAccess : tAccess.WebProgMtMList) {
	                            //Added by Ajit Surana - 02/15/2014 - CR-20130528-3087
	                            //Check if set contains Web Program Name record, if contains then move to next record
	                            if(setWebProgNames.contains(webProgAccess.Web_Program__r.Name))
	                                continue;
	                            
	                            Temporary_Program_Access__c newTempAccess = new Temporary_Program_Access__c();
	                            system.debug('@@WebProgAccweb press:' + webProgAccess);
	                            newTempAccess.Contact__c = MainContact.Id;
	                            newTempAccess.Site_Profile__c = getSiteProfileId(webProgAccess);
	                            newTempAccess.Web_Program__c = webProgAccess.Id;
	                            newTempAccess.Start_Date__c = DateTime.Parse(tAccess.StartDate + ' 12:00 AM');
	                            newTempAccess.End_Date__c = DateTime.Parse(tAccess.Expiration_Date + ' 12:00 PM');
	                            tAccess.tempProgAccessList.add(newTempAccess);
	                            
	                            //Added by Ajit Surana - 02/15/2014 - CR-20130528-3087
	                            //Add Web Program Name to Set
	                            setWebProgNames.add(webProgAccess.Web_Program__r.Name);
	                            
	                        }
	                    }
	                    else {
	                        for (Temporary_Program_Access__c tpAccess : tAccess.TempProgAccessList) {
	                            
	                            System.debug('tpAccess :::::::::;'+ tpAccess);
	                            //Added by Ajit Surana -02/15/2014 - CR-20130528-3087
	                            //Check if set contains Program Acronym record, if contains then move to next record
	                           
	                            
	                            Temporary_Program_Access__c newTempAccess = new Temporary_Program_Access__c();
	                            newTempAccess = tpAccess;
	                            newTempAccess.Site_Profile__c = getSiteProfileId(tpAccess);
	                            newTempAccess.Start_Date__c = DateTime.Parse(tAccess.StartDate + ' 12:00 AM');
	                            newTempAccess.End_Date__c = DateTime.Parse(tAccess.Expiration_Date + ' 12:00 PM');
	                            system.debug('@@TEST:' + integer.valueOf(tpAccess.Web_Program__r.Web_Program__r.A_com_Program_ID__c));
	                            
	                        }
	                    }
	                    
	                    date ActualStartDate = date.parse(tAccess.StartDate);
	                    date ActualEndDate = date.parse(tAccess.Expiration_Date);
	                    system.debug('@@@ActualStartDate:' + ActualStartDate);
	                    system.debug('@@@ActualEndDate:' + ActualEndDate);
	                    
	                    if (ActualEndDate < system.today()) {
	                        ErrorString = '<b>Error</b>: Expiration date must be greater than today';
	                        return null;
	                    }
	                    if (ActualEndDate < ActualStartDate) { 
	                        ErrorString = '<b>Error</b>: Expiration date must be greater than the start date';
	                        return null;
	                    }
	                
	                    tempAccessToUpsert.addAll(tAccess.TempProgAccessList);
	                    
	                }
	                catch(DMLException ex) {
	                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getDMLMessage(0)));   
	                    ErrorString = '<b>Error</b>: ' + ex.getDMLMessage(0);
	                    return null;
	                }
	                catch(Exception ex) { // if there was an error, return null and display the error to the user
	                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));   
	                    ErrorString = '<b>Error</b>: ' + ex.getMessage();
	                    return null;
	                }
	                
	            }
	            else if (tAccess.HasAccess == false && tAccess.TempProgAccessList.size() != 0) {
	                for (Temporary_Program_Access__c tpAccess : tAccess.TempProgAccessList)
	                    tempAccessToDelete.add(tpAccess);
	                }
	            
	        }
        }
        
        if (tempAccessToUpsert.size() > 0) {
            
            try {
                upsert tempAccessToUpsert;
            }
            catch(DMLException ex) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getDMLMessage(0))); 
                ErrorString = '<b>Error</b>: ' + ex.getDMLMessage(0);
                return null;
            }
            catch(Exception ex) { // if there was an error, return null and display the error to the user
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));  
                ErrorString = '<b>Error</b>: ' + ex.getMessage();
                return null;
            }
            
        }
        
        if (tempAccessToDelete.size() > 0) {
            
            try {
                
                //Added by Ajit Surana - 04/03/2014 - CR-20130528-3087
                //List to hold the TAC
                List<Temporary_Program_Access__c> tACsUpdate = new List<Temporary_Program_Access__c>();
                List<Temporary_Program_Access__c> tACsDelete = new List<Temporary_Program_Access__c>();
                
                //Loop through through the tac to be deletced and check if Same Tac is also applicable for other program
                for(Temporary_Program_Access__c tAC : tempAccessToDelete) {
                    
                    //Create Unique Key
                    String uniqueKey = tAC.Web_Program__r.Web_Program__c;
                    
                    System.debug('tAC uniqueKey ::::::::::::::;'+uniqueKey);
                    //Check if Unique Key is in Available Option Map
                    if(tempAccessToUpsert.size() > 0 && mapUniqueKeyWithAvailableMtM.containsKey(uniqueKey)) {
                        
                        //Do not detele TAC, even attach to to the different MtM
                        tAC.Web_Program__c = mapUniqueKeyWithAvailableMtM.get(uniqueKey);
                        tACsUpdate.add(tAC);
                    }else {
                        
                        //Add in the list to be delected
                        tACsDelete.add(tAC);
                    }
                }
                
                //Update tACs
                if(tACsUpdate.size() > 0) 
                    update tACsUpdate;
                    
                //Delete TACs
                if(tACsDelete.size() > 0) 
                    delete tACsDelete;
            
            }
            catch(DMLException ex) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getDMLMessage(0)));   
                return null;
            }
            catch(Exception ex) { // if there was an error, return null and display the error to the user
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));   
                return null;
            }
            
        }
        
        SaveSuccessful = true;
        //tempAccessList.clear();
        
        //Added by Ajit Surana - 04/07/2014 - CR-20130528-3087
        //Redirect user back to Contact's detail page on clicking 'Update' button
        return new ApexPages.StandardController(new Contact(Id = conId)).view();
        
    }*/
    
    String conId;
    
    public SiteTempAccessController() {
        
        // get the contact id
        conId = ApexPages.currentPage().getParameters().get('id');
        String userId = ApexPages.currentPage().getParameters().get('advid');
        
        if (conId != null || userId != null)
            MainContact = FindContact(conId, userId);
        
        if (MainContact != null)
            FindAccess();
        
        //get the site profile(s) for this contact
        for (Site_Profile__c sp : MainContact.Site_Profiles__r) {
        	if (sp.Type__c.equalsIgnoreCase(SiteUserHelper.SITE_EAB))
        		siteProfile_EAB = sp;
        	else if (sp.Type__c.equalsIgnoreCase(SiteUserHelper.SITE_ADVISORY))
        		siteProfile_Advisory = sp;
        }
    }
    
    public static Contact FindContact(String contactId, String userId) {
        
        Contact retCon = new Contact();
        
        string queryString = CONTACTQUERY_TEMPACCESS;
        
        if (contactId != null)
            queryString += ' WHERE Id = \'' + contactId + '\'  LIMIT 1';
        else if (userId != null) 
            queryString += ' WHERE Id IN (SELECT Contact__c FROM Site_Profile__c WHERE User_Id__c = \'' + userId + '\')  LIMIT 1';
        
        List<Contact> cons = database.Query(queryString);
        
        if (cons.size() > 0)
            retCon = cons[0];
		system.debug('@@@retCon:' + retCon);        
        return retCon;
    }
    
    //Added by Ajit Surana - 04/03/2014 - CR-20130528-3087
    //Create a set to hold the WP Ids
    Set<Id> wIds = new Set<Id>();
    
    //Create a set to hold the PM Ids
    Set<Id> pMIds = new Set<Id>();
    
    //Map to hold the Unique Keys and there MTM
    Map<String, Id> mapUniqueKeyWithAvailableMtM = new Map<String, Id>();
    Map<String, Id> mapUniqueKeyWithExistingMtM = new Map<String, Id>();
    
    public void FindAccess() {
        
        if (MainContact != null) {
            
            // List of existing program access
            Set<Id> existingAccessIds = new Set<Id>();
            //Map<String, List<Temporary_Program_Access__c>> existingTempAccessMap = new Map<String, List<Temporary_Program_Access__c>>();
            Map<String, List<Web_Program_Access_MTM__c>> newWPAccessMap = new Map<String, List<Web_Program_Access_MTM__c>>();
            
            //Create a Set to hold the string Web-Program to avoid the duplicate data
            Set<String> uniqueWebPrograms = new Set<String>();
            
           /* // find all existing temporary access
            for (Temporary_Program_Access__c tAccess : MainContact.Temporary_Program_Access__r) {
                
                //Added by VH - 03/13/2014 - CR-20130528-3087
                //add existing temp access Web Program Name string values
                setWebProgNames.add(tAccess.Web_Program_Name__c);
                
                //Added by Ajit Surana - 04/03/2014 - CR-20130528-3087
                //Add Web Program to wIds
                wIds.add(tAccess.Web_Program__r.Web_Program__c);
                
                //Add Program Membership to pMIds
                pMIds.add(tAccess.Web_Program__r.Membership_Program__c);
                
                //Create a unique Web Program String
                uniqueWebPrograms.add(tAccess.Web_Program__r.Web_Program__c + '-' + tAccess.Web_Program__r.Membership_Program__c);
                
                //Create aa unique key an add with MtM in map
                String uniqueKey = tAccess.Web_Program__r.Web_Program__c;
                
                //Populate map
                mapUniqueKeyWithExistingMtM.put(uniqueKey, tAccess.Web_Program__c);
                
                List<Temporary_Program_Access__c> tAccessList = existingTempAccessMap.get(tAccess.Program_Acronym__c);
                if (tAccessList == null) {
                    tAccessList = new List<Temporary_Program_Access__c> { tAccess };
                }
                else {
                    tAccessList.add(tAccess);
                }
                existingTempAccessMap.put(tAccess.Program_Acronym__c, tAccessList);
                
                system.debug('@@Adding Value:' + tAccess.Program_Acronym__c + '  WebProgName:' + tAccess.Web_Program_Name__c);
                existingAccessIds.add(tAccess.Web_Program__c);
                
            }*/
            
            //Fetch all the WMTM records from database and populate the MtM availble Map
            for(Web_Program_Access_MTM__c wMtM : [Select Id, Web_Program__c, Membership_Program__c from Web_Program_Access_MTM__c where Web_Program__c IN: wIds AND Id NOT IN: existingAccessIds]) {
                
                //Populate the Map
                String uniqueKey = wMtM.Web_Program__c;
                if(mapUniqueKeyWithExistingMtM.containsKey(uniqueKey) 
                    && !mapUniqueKeyWithAvailableMtM.containsKey(uniqueKey)
                    && pMIds.contains(wMtM.Membership_Program__c)
                    && !uniqueWebPrograms.contains(wMtM.Web_Program__c + '-' + wMtM.Membership_Program__c)) {
                    
                    //Add in option available   
                    mapUniqueKeyWithAvailableMtM.put(uniqueKey, wMtM.Id);
                }       
            }
            
           /* // loop through each map value and create a temp access record
            for (List<Temporary_Program_Access__c> tAccessList : existingTempAccessMap.values()) {
                TempAccess TA = new TempAccess(tAccessList, true);
                
                //add the temp access value to the proper temp access list
                list<TempAccess> taList = mapTempAccess.get(TA.siteType);
                if (taList == null) taList = new list<TempAccess>();
                taList.add(TA);
                mapTempAccess.put(TA.siteType, taList);
                
                //TempAccessList.add(TA);
            }*/
            
            // find all prospective temporary access
            List<Membership__c> memberships = [SELECT Name, Program__c FROM Membership__c WHERE Membership_Status__c LIKE '%Prospect%' AND Account_Name__c = :MainContact.AccountId];
            Set<Id> programIds = new Set<Id>();
            for (Membership__c m : memberships)
                programIds.add(m.Program__c);
            
            // find all web program access that contains these prospective programs
            List<Web_Program_Access_MTM__c> WebProgramAccessMtMList = [SELECT Web_Program__r.Name, Program_Acronym__c, Program_Formal_Name__c, Web_Program__r.Description__c, 
            														Web_Program__r.A_com_Program_ID__c, Membership_Program__r.Applicable_Segments__c
                                                                    FROM Web_Program_Access_MTM__c WHERE Membership_Program__c != null AND Membership_Program__c IN :programIds AND Id NOT IN :existingAccessIds ORDER BY Program_Acronym__c ASC];
            
            for (Web_Program_Access_MTM__c wpAccess : WebProgramAccessMtMList) {
                
                /*if(existingTempAccessMap.containsKey(wpAccess.Program_Acronym__c))
                    continue;*/
                
                List<Web_Program_Access_MTM__c> newWPAccessList = newWPAccessMap.get(wpAccess.Program_Acronym__c);
                if (newWPAccessList == null) {
                    newWPAccessList = new List<Web_Program_Access_MTM__c> { wpAccess };
                }
                else {
                    newWPAccessList.add(wpAccess);
                }
                newWPAccessMap.put(wpAccess.Program_Acronym__c, newWPAccessList);
            }
            // loop through each map value and create a temp access record
            for (List<Web_Program_Access_MTM__c> newWPAccessList : newWPAccessMap.values()) {
                //system.debug('@@newWPAccessList:' + newWPAccessList);
                TempAccess TA = new TempAccess(newWPAccessList, false);
                
                //add the temp access value to the proper temp access list
                list<TempAccess> taList = mapTempAccess.get(TA.siteType);
                if (taList == null) taList = new list<TempAccess>();
                taList.add(TA);
                mapTempAccess.put(TA.siteType, taList);
                
                //TempAccessList.add(TA);
            }
               
            // sort the list of temp access values!
            for (list<TempAccess> taList : mapTempAccess.values())
            	taList.sort();
        }
    }
    
    public map<string, list<TempAccess>> mapTempAccess {
        get {
            if (mapTempAccess == null) {
                mapTempAccess = new map<string, list<TempAccess>>();
                
            }
            return mapTempAccess;
        }
        set;
    }
}