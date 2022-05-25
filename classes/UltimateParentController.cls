/* 
* Name          : UltimateParentController
* Author        : Unknown
* Description   : UltimateParentController
*                 
* Maintenance History: 
* Date --------- Name -------- Version -- Remarks 
* 07/10/2014    Hermes Yan    1.0        Update of case declartion to account for field requirements
* 06/16/2016    Rajeev Jan    1.0        SFDC schema Release - Manual Code Migration from Royall Enviournment
* V1.1 - Modified By - Mahendra SwarnKar - 05/01/2019 - Commented the class as per Spring Clean up - CR-20190501-13061	
*/

public class UltimateParentController {   
    public static boolean isTest = false;
    // List for  Storing the 
    public List<Account> lstAccountRel
    {   get;set;        }
    // List for storing the Contact Details
    public List<Contact> lstContact
    {   get;set;        }
    // List for storing the Opportunity Details
    public List<Opportunity> lstOpportunity 
    {   get;set;        }
    // List for storing the Program Package Details
    public List<Program_Package__c> lstProgram_Package
    {   get;set;        }
    
    /*<!--Modified By Dipesh Gupta -CR-20190524-13151 - Date-06/18/2019 -->	*/
    /*
    // List for storing the Visit Details
    public List<Visit__c> lstVisit
    {   get;set;        }      
	*/
    // List for storing the Cases Details
    public List<Case> lstCase
    {   get;set;        }
    // List for storing the Open Activites Details
    public List<OpenActivity> lstOpenActivity
    {   get;set;        }
    // List for storing the Activity History Details
    public List<ActivityHistory> lstActivityHistory
    {   get;set;        }
    public Account objAccount
    {   get;set;        }  
    //Predefined Rollup Variables                                            
    public Double TotalWonAmtOpp  
    {       get;set;        }  
    public double TotalOpenAmtOpp  
    {       get;set;        }
    public Integer TotalNWonOpp  
    {       get;set;        }
    public Integer TotalNOpenOpp  
    {       get;set;        }
    public Integer TotalNOpenCase  
    {       get;set;        }
    public Integer TotalNClosedCase  
    {       get;set;        }
    public Integer TotalChildAccount  
    {       get;set;        }
    public Integer TotalCustChildCount  
    {       get;set;        }
    public Integer TotalNonCustChildCount  
    {       get;set;        }
    public double TotalRMRWonOpp  
    {       get;set;        }
    public String strObjectExcluded
    {       get;set;        }
    public String rollUpData
    {       get;set;        }
    // Field will 1st get data from field set and will re use for Account field
    public String fields{get;set;}
    //Set of All childs account
    //public Set<Id> setAllChilds = new Set<Id>(); 
    // For Dynamic query
    public String query;
    // Root Parent Account Id
    public String AccId;
    // For rendering VF component after querying desired fields only
    public boolean isRender {get;set;}
    // List size to be render
    public static integer MAX_RELATED_LIST_SIZE = 26;
    // For preventing SOQL limit hit.
    public static final integer MAX_ACCOUNT_LEVEL = 25;
    // set of object to be excluded
    public Set<String> setObjectExcluded = new Set<String>();
    // Map between rollup name and corresponding query
    public Map<string,string> queryRollup = new Map<string,string>();
    // Map between related object to their default query
    public Map<string, string> mapRelatedObjectToDefaultQuery;  
    // list of Class rollupdetails
    public map<String, RollupDetails> lstRollupDetails = new map<String, RollupDetails>();
    // map of All standard rollup to corresponding query.
    public Map<string,string> mapRollupQueries;
    // list of rollup definitions
    
    /**Spring CleanUp CR-20190501-13061**** 
    private list<Rollup_Definition__c> theRollupDefinitionList; */
        
    public List<RollupDetails> getlstRollupDetails() {
        //system.debug(theRollupDefinitionList);
        // sort list before returning results
        List<RollupDetails> theOrderedList = new List<RollupDetails>();
        /*for (Rollup_Definition__c rd : theRollupDefinitionList) {
            theOrderedList.add(lstRollupDetails.get(rd.Name__c));
        }*/
        
        
        return theOrderedList;
    }
    
    //Inner class for user defined rollup
    class RollupDetails
    {
        public String rollupName{get;set;}
        public String result {get;set;}
        public RollupDetails(String rollupName ,String result)
        {
            this.rollupName = rollupName;
            this.result = result;
        }
    }
    
    //Paramaterised constructor
    public UltimateParentController(Apexpages.standardController scAcc)
    {                                                               
        AccId = scAcc.getId();
        initialize();       
    }
    /** 

    * \Method initialize() 
    
    * \param None
    
    *\ return None  
    
    */ 
    /*
    *  V1.1 - Modified By - Mahendra SwarnKar - 05/01/2019 - Commented the method as per Spring Clean up - CR-20190501-13061
    */
    private void initialize()
    {
         // Initailising the Variables
         isRender = false;
         lstAccountRel = new List<Account>();
         lstOpportunity = new List<Opportunity>();
         lstContact = new List<Contact>();
         lstCase = new List<Case>();
         lstProgram_Package = new List<Program_Package__c>();
         
         /*<!--Modified By Dipesh Gupta -CR-20190524-13151 - Date-06/18/2019 -->	*/
    	 //lstVisit = new List<Visit__c>();
         lstOpenActivity = new List<OpenActivity>();
         lstActivityHistory = new List<ActivityHistory>();
         lstRollupDetails = new map<String, RollupDetails>();  
         TotalWonAmtOpp = 0.0;  
         TotalOpenAmtOpp = 0.0;
         TotalNWonOpp = 0;
         TotalNOpenOpp = 0;
         TotalNOpenCase = 0;
         TotalNClosedCase = 0;
         TotalChildAccount = 0;
         TotalCustChildCount = 0;
         TotalNonCustChildCount = 0;
         TotalRMRWonOpp = 0.0;
         
         //Getting user defined rollups
         //Spring CleanUp
	     //theRollupDefinitionList = new list<Rollup_Definition__c>([select Name__c,Object_Aggregated__c,Field_Aggregated__c,Aggregate_Function__c,Criteria__c,Account_Lookup_Field_Name__c from Rollup_Definition__c order by Order__c asc limit : DefineRollup.MAX_USER_DEFINED_ROLLUP_LIMIT]);
   
    }
    // Function for managing fields according to field set and calling various functions.
    /** 

    * \Method getData() 
    
    * \param None  
    
    * \return None
    
    */ 
    public pagereference getData()
    {  
        List<Set<Id>> lstSetIds = new List<Set<Id>>(); 
        Set<Id> setAllChilds = new Set<Id>();
        Set<Id> setLessAccount = new Set<Id>();
        //Check whether user has removed id from url
        string AccountId = System.currentPagereference().getParameters().get('id');
        //if Parent Account Id is not present in URL
        if(AccountId == null || AccountId == '')
        {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Insufficient Parameter.');         
            ApexPages.addMessage(msg);
            return null;
        }
        // Map between possible related list and respective query.
        mapRelatedObjectToDefaultQuery = new Map<string, string>{'opportunity'=>'(Select AccountId, Name, StageName, Amount, CloseDate, Type, IsClosed, ForecastCategory From Opportunities ORDER BY Name LIMIT :MAX_RELATED_LIST_SIZE)',
                                              'contact'=>'(Select Name, Phone, Email, Title, Birthdate From Contacts ORDER BY Name LIMIT :MAX_RELATED_LIST_SIZE)',
                                              'program_package'=>'(Select Total_Contracted_Program_Cost__c, RFP_Release_Date__c, RFP_Due_Date__c, Proposal_Sent__c, Proposal_Approved__c, Name, Fiscal_Year__c, CreatedDate, Contract_Signature_Date__c, Contract_Sent__c, Account__c, OwnerId From Program_Packages__r ORDER BY CreatedDate LIMIT :MAX_RELATED_LIST_SIZE)',/*
                                              'client_interaction'=>'(Select Type__c, Notes__c, Name, LastModifiedDate, LastModifiedById, LastActivityDate, Id, Date__c, CreatedDate, CreatedById, Account__c From Client_Interactions__r ORDER BY CreatedDate LIMIT :MAX_RELATED_LIST_SIZE)',*/
                                              'visit'=>'(Select Status__c, Program_Package__c, Name, Meeting_Type__c, Meeting_Location__c, Meeting_Date__c, LastModifiedDate, LastModifiedById, Initiated_by__c, Id, Fiscal_Year__c, CreatedDate, CreatedById, Account__c From Visits__r ORDER BY CreatedDate LIMIT :MAX_RELATED_LIST_SIZE)',
                                              'case'=>'(Select ContactId, CreatedDate, Id, SuppliedName, Status, Subject, CaseNumber, Priority, OwnerId From Cases ORDER BY CaseNumber LIMIT :MAX_RELATED_LIST_SIZE)',
                                              'activity history'=>'(Select Subject, IsTask, OwnerId, ActivityType, AccountId, WhoId, WhatId, What.Name, ActivityDate, LastModifiedDate From ActivityHistories ORDER BY ActivityDate DESC LIMIT :MAX_RELATED_LIST_SIZE)',
                                              'open activity'=>'(Select AccountId, Subject, IsTask, OwnerId, Status, Priority, ActivityDate, ActivityType, WhoId, WhatId, What.Name From OpenActivities ORDER BY ActivityDate ASC LIMIT :MAX_RELATED_LIST_SIZE)'};
                                      
        // Block for extract field sets values of various objects
        try
        {
            //here field contains field set data
            //spliting object.
            String [] objectsFields = fields.split('~');
            fields = '';
            //this loop is for creating map between related object and fields
            for(String str : objectsFields)
            {
                //spliting object with field's in field set. here 1st index contains object name and 2nd index contains fields
                String [] strObjectAndFields = str.split('#');
                //if some object have corresponding field choosed in field set.
                if(strObjectAndFields.size() == 2)
                {
                    //if object is not in map mapRelatedObjectToDefaultQuery i.e. Account
                    if(mapRelatedObjectToDefaultQuery.get(strObjectAndFields[0]) != null)
                    {
                        //fetching default query from map.
                        string strObjectFields = mapRelatedObjectToDefaultQuery.get(strObjectAndFields[0]);
                        //getting from and where part from default query
                        strObjectFields = strObjectFields.substring(strObjectFields.indexOf('From'));
                        //creating new query based on field set data
                        strObjectFields = '(Select ' + strObjectAndFields[1] + ' ' + strObjectFields;
                        // Final map between related object and corresponding query
                        mapRelatedObjectToDefaultQuery.put(strObjectAndFields[0],strObjectFields);
                    }//Field set is not available for Activity History and Open Activity.
                    else if(strObjectAndFields[0] != 'activity history' || strObjectAndFields[0] != 'open activity')
                    {
                        fields = 'Select ' + strObjectAndFields[1];
                    }
                }
                else if(strObjectAndFields[0] == 'Account')
                {
                    //If account is having no data in field set, then here is a default field to be queryied.
                    fields = 'Select Website, Industry, Phone, ParentId, Parent.Name, OwnerId, Name, Type ';
                }
            } 
            lstSetIds = UPUtility.generateHierarchy(AccId, MAX_RELATED_LIST_SIZE, MAX_ACCOUNT_LEVEL);
            setLessAccount = lstSetIds[0];
            setAllChilds = lstSetIds[1];
            //Calling function for creating dynamic query
            queryManager();
            //Calling function for getting rollup data
            calculateRollups(setAllChilds);
            //Calling function for getting related lists
            getRelatedLists(setLessAccount,setAllChilds);
            // to render only required information on page
            isRender = true;
            return null;
        }
        catch(Exception e)
        {
            system.debug('Error: '+e.getMessage());
            return null;
        }
    }
    // function for creating dynamic query. 
    /** 

    * \Method queryManager() 
    
    * \param None
    
    *\ return None
      
    */  
    /*
    * V1.1 - Modified By - Mahendra SwarnKar - 05/01/2019 - Commented the method as per Spring Clean up - CR-20190501-13061
    */  
    public void queryManager()
    {   
        Set<String> setRollup = new Set<String>();
        String dynamicRollupQuery;
        query = '';
        rollUpData = '';
        strObjectExcluded = '';
        //map between related fields and custom setting UltimateParent_ExcludedLists__c object
        Map<String, UltimateParent_ExcludedLists__c> mapFields = UltimateParent_ExcludedLists__c.getAll();
        //map between rollup and custom setting UltimateParent_ExcludedRollUp__c object 
        Map<String , UltimateParent_ExcludedRollUp__c> mapRollUp = UltimateParent_ExcludedRollUp__c.getAll();
        setObjectExcluded = mapFields.keyset();
        //Rollup set contains in custom setting
        for(UltimateParent_ExcludedRollUp__c obj : mapRollup.values())
        {
            setRollup.add(obj.Name);
        }
        // Map between possible rollup and respective query
         mapRollupQueries = new Map<string,string>{'total number of open cases'=>'select count(id)TotalOpenCases from Case where AccountId in :setAllChilds and IsClosed = false',
                                                                     'total amount of won opportunity'=>'select SUM(Amount)TotalWonAmtOpp from Opportunity where AccountId in : setAllChilds    and StageName in : setWonStages',
                                                                     'total number of closed cases'=>'select count(id)TotalClosedCases from Case where AccountId in :setAllChilds and IsClosed = true',
                                                                     'total amount of open opportunity'=>'select SUM(Amount)TotalOpenAmtOpp from Opportunity where AccountId in : setAllChilds and StageName not in : setWonStages',
                                                                     'total number of won opportunity'=>'select COUNT(Id)TotalWonOpps from Opportunity where AccountId in : setAllChilds    and StageName in : setWonStages',
                                                                     'total number of open opportunity'=>'select COUNT(Id)TotalOpenOpp from Opportunity where AccountId in : setAllChilds    and StageName not in : setWonStages',
                                                                     'total rmr of won opportunity'=>'select SUM(Amount)TotalWonRMR from Opportunity where AccountId in : setAllChilds    and StageName in : setWonStages',
                                                                     'total number of customer account'=>'select count(id)TotalCustChildCount from Account where Id in :setAllChilds and Type != \'Prospect\' and Type != \'Partner\'',
                                                                     'total number of non-customer account'=>'select count(id)TotalNonCustChildCount from Account where Id in :setAllChilds and Type = \'Prospect\''};
        /*** Spring CleanUp CR-20190501-13061 ***
        for(Rollup_Definition__c objRD : theRollupDefinitionList) 
        {
            //Generating dynamic query based on rollup information 
            dynamicRollupQuery = 'select '+objRD.Aggregate_Function__c+'('+objRD.Field_Aggregated__c+') '+' from '+objRD.Object_Aggregated__c+' where ('+objRD.Criteria__c + ') AND ' + objRD.Account_Lookup_Field_Name__c + ' in :setAllChilds ';
            if(!setRollup.contains(objRD.Name__c))
                queryRollup.put(objRD.Name__c , dynamicRollupQuery);     
        }  
        */         
        //loop for genereating query for related list
        For(String relatedObject : mapRelatedObjectToDefaultQuery.keyset())
        {
            //if object's related data is to be rendered
            if(!setObjectExcluded.contains(relatedObject))
            {
                if(query.length() == 0)
                {
                    query = mapRelatedObjectToDefaultQuery.get(relatedObject);
                }
                else
                {
                    query += ',' + mapRelatedObjectToDefaultQuery.get(relatedObject);
                }
            }
            else
            {
                //if object's related data is not to be rendered
                if(strObjectExcluded.length() == 0)
                {
                    strObjectExcluded = relatedObject;
                }
                else
                {
                    strObjectExcluded += ','+relatedObject;
                }
            }
        }
        //loop for generating final queries for rollups
        For(String objrollup : mapRollupQueries.keyset())
        {
            //Rollup to be rendered
            if(!mapRollup.keyset().contains(objrollup))
            {
                queryRollup.put(objrollup,mapRollupQueries.get(objrollup));
            }
            else
            {
                // rollUpData contains which rollup is not to be render
                if(rollUpData.length() == 0)
                {
                    rollUpData = objrollup;
                }
                else
                {
                    rollUpData += ','+objrollup;
                }
            }
        }
        //Final query is generated here.
        if(query.length() > 0)
        {
            query = fields + ',' + query + ' From Account where Id in : setLessAccount ORDER BY Name LIMIT :MAX_RELATED_LIST_SIZE'; 
        }
        else
        {
            //if no related list object is got selected.
            query = fields + ' From Account where Id in : setLessAccount ORDER BY Name LIMIT :MAX_RELATED_LIST_SIZE';
        }
    }
    
    // function for the calculating the Rollup values
    /** 

    * \Method calculateRollups 
    
    * \param None
    
    *\ return None
      
    */ 
    private void calculateRollups(set<Id> setAllChilds)
    {                  
          //Calculating Amount and number of Closed won opportunities 
          set<string> setWonStages = new set<string>{'Closed Won'};
         List<AggregateResult> lstRollup = new List<AggregateResult>();
         try
         {
          //This loop can be iterate maximum 8 times.
          for(String objRollUp : queryRollup.keyset())
          {
            //Ignore current account id if roll are following.
            if(objRollUp == 'total number of customer account' || objRollUp == 'total number of non-customer account')
            {
                setAllChilds.remove(AccId);
                lstRollup = Database.query(queryRollup.get(objRollUp));
                setAllChilds.add(AccId); 
            }
            else
            {
                system.debug(queryRollup.get(objRollUp));
                lstRollup = Database.query(queryRollup.get(objRollUp));
            }
            if(!lstRollup.isEmpty())
            {
                if(objRollUp == 'total amount of won opportunity')
                {
                    TotalWonAmtOpp = double.valueOf(lstRollup[0].get('TotalWonAmtOpp'))!=null?double.valueOf(lstRollup[0].get('TotalWonAmtOpp')):0.0;
                    continue;
                }
                if(objRollUp == 'total number of open cases')
                {
                    TotalNOpenCase = integer.valueOf(lstRollup[0].get('TotalOpenCases'));
                    continue;
                }
                if(objRollUp == 'total number of closed cases')
                {
                    TotalNClosedCase = integer.valueOf(lstRollup[0].get('TotalClosedCases'));
                    continue;
                }
                if(objRollUp == 'total amount of open opportunity')
                {
                    TotalOpenAmtOpp = double.valueOf(lstRollup[0].get('TotalOpenAmtOpp'))!=null?double.valueOf(lstRollup[0].get('TotalOpenAmtOpp')):0.0;
                    continue;
                }
                if(objRollUp == 'total number of open opportunity')
                {
                    TotalNOpenOpp = integer.valueOf(lstRollup[0].get('TotalOpenOpp'));
                    continue;
                }
                if(objRollUp == 'total number of won opportunity')
                {
                    TotalNWonOpp = integer.valueOf(lstRollup[0].get('TotalWonOpps'));
                    continue;
                }
                if(objRollUp == 'total rmr of won opportunity')
                {
                    TotalRMRWonOpp = double.valueOf(lstRollup[0].get('TotalWonRMR'))!=null?double.valueOf(lstRollup[0].get('TotalWonRMR')):0.0;
                    continue;
                }
                if(objRollUp == 'total number of customer account')
                {
                    TotalCustChildCount = Integer.valueOf(lstRollup[0].get('TotalCustChildCount'));
                    continue;
                }
                if(objRollUp == 'total number of non-customer account')
                {
                    TotalNonCustChildCount = Integer.valueOf(lstRollup[0].get('TotalNonCustChildCount'));
                    continue;
                }
                //This is for user defined rollup
                if(lstRollup[0] != null)
                {
                    if(lstRollup[0].get('expr0') != null)
                    {
                        lstRollupDetails.put(objRollup, new RollupDetails(objRollup , String.valueOf(lstRollup[0].get('expr0'))));
                    }
                    else
                    {
                        lstRollupDetails.put(objRollup, new RollupDetails(objRollup , '0'));
                    }
                }
            } 
            else if(!mapRollupQueries.keySet().contains(objRollUp))
            {
                //some time query return empty list. this else part is to handle that sort of situation
                lstRollupDetails.put(objRollup, new RollupDetails(objRollup , '0'));
            } 
          }
         }
         catch(Exception e)
         {
            system.debug('Error: '+e.getMessage());
         }
    }
    // function for getting the Related List records. 
    /** 

    * \Method getRelatedLists() 
    
    * \param query,setObjectExcluded
    
    *\ return None
      
    */    
    public void getRelatedLists(set<Id> setLessAccount,set<Id> setAllChilds)
    {                
        try
        {   
            List<Account> lstAccountResult = new List<Account>();
            integer index = 1;
            system.debug(query);
            lstAccountResult = Database.query(query);
             for(Account aggRel : lstAccountResult)
             {
                    // storing the records in the lists
                    lstAccountRel.add(aggRel);
                   /* //For placing the root parent account at 0'th index of list
                    if(aggRel.Id == AccId)
                    {
                        Account objAccount = lstAccountRel[0];
                        Account parent = lstAccountRel[lstAccountRel.size() - 1];
                        lstAccountRel.set(0,parent);
                        lstAccountRel.set(lstAccountRel.size() - 1,objAccount);
                    }
                    //for placing 1st child of root parent account starting from index=1
                    else if(aggRel.ParentId == AccId)
                    {
                        if(lstAccountRel.size() > 1)
                        {
                            Account objAccount = lstAccountRel[index];
                            Account parentChild = lstAccountRel[lstAccountRel.size() - 1];
                            lstAccountRel.set(index,parentChild);
                            lstAccountRel.set(lstAccountRel.size() - 1,objAccount);
                            index++;
                        }
                    }*/
             }
            //this loop is for placing parent account related lists result at first while rendering list on page
            /*for(Account aggRel : lstAccountRel)
            {
                if(!setObjectExcluded.contains('opportunity'))
                        lstOpportunity.addAll(aggRel.Opportunities);
                if(!setObjectExcluded.contains('contact'))
                        lstContact.addAll(aggRel.Contacts);
                if(!setObjectExcluded.contains('case'))
                        lstCase.addAll(aggRel.Cases);
                if(!setObjectExcluded.contains('program_package'))
                        lstProgram_Package.addAll(aggRel.Program_Packages__r);
                if(!setObjectExcluded.contains('client_interaction'))
                        lstClient_Interaction.addAll(aggRel.Client_Interactions__r);       
                if(!setObjectExcluded.contains('visit'))
                        lstVisit.addAll(aggRel.Visits__r);                                           
                if(!setObjectExcluded.contains('open activity'))
                        lstOpenActivity.addAll(aggRel.OpenActivities);
                if(!setObjectExcluded.contains('activity history'))
                        lstActivityHistory.addAll(aggRel.ActivityHistories);
            }*/
            //This continues if condition: if 1st 26 prior parent account does not hv 26 related list's records, then have to query manually from all childs i.e. setAllChilds.
            if(!setObjectExcluded.contains('contact') && lstContact.size() < MAX_RELATED_LIST_SIZE)
            {   
                lstContact.clear();                 
                string newQuery = mapRelatedObjectToDefaultQuery.get('contact');
                newQuery = newQuery.replace('(','');
                newQuery = newQuery.replace(')','');
                newQuery = newQuery.trim().replace('Contacts ORDER BY Name LIMIT :MAX_RELATED_LIST_SIZE',' Contact where AccountId IN : setAllChilds ORDER BY FirstName LIMIT :MAX_RELATED_LIST_SIZE');                  
                lstContact = Database.query(newQuery);
            }
            if(!setObjectExcluded.contains('opportunity') && lstOpportunity.size() < MAX_RELATED_LIST_SIZE)
            {    
                lstOpportunity.clear();                 
                string newQuery = mapRelatedObjectToDefaultQuery.get('opportunity');
                newQuery = newQuery.replace('(','');
                newQuery = newQuery.replace(')','');
                newQuery = newQuery.trim().replace('Opportunities ORDER BY Name LIMIT :MAX_RELATED_LIST_SIZE',' Opportunity where AccountId IN : setAllChilds ORDER BY CloseDate DESC LIMIT :MAX_RELATED_LIST_SIZE');                     
                lstOpportunity = Database.query(newQuery);
            }
            if(!setObjectExcluded.contains('program_package') && lstProgram_Package.size() < MAX_RELATED_LIST_SIZE)
            {    
                lstProgram_Package.clear();                
                string newQuery = mapRelatedObjectToDefaultQuery.get('program_package');
                newQuery = newQuery.replace('(','');
                newQuery = newQuery.replace(')','');
                newQuery = newQuery.trim().replace('Program_Packages__r ORDER BY CreatedDate LIMIT :MAX_RELATED_LIST_SIZE',' Program_Package__c where Account__c IN : setAllChilds ORDER BY Fiscal_Year__c DESC LIMIT :MAX_RELATED_LIST_SIZE');                    
                lstProgram_Package = Database.query(newQuery);
            }    
            
            /*<!--Modified By Dipesh Gupta -CR-20190524-13151 - Date-06/18/2019 -->	*/
    		/*
            if(!setObjectExcluded.contains('visit') && lstVisit.size() < MAX_RELATED_LIST_SIZE)
            {    
                lstVisit.clear();                
                string newQuery = mapRelatedObjectToDefaultQuery.get('visit');
                newQuery = newQuery.replace('(','');
                newQuery = newQuery.replace(')','');
                newQuery = newQuery.trim().replace('Visits__r ORDER BY CreatedDate LIMIT :MAX_RELATED_LIST_SIZE',' Visit__c where Account__c IN : setAllChilds ORDER BY Meeting_Date__c DESC LIMIT :MAX_RELATED_LIST_SIZE');                    
                lstVisit = Database.query(newQuery);
            } */    
            if(!setObjectExcluded.contains('case') && lstCase.size() < MAX_RELATED_LIST_SIZE)
            {    
                lstCase.clear();                
                string newQuery = mapRelatedObjectToDefaultQuery.get('case');
                newQuery = newQuery.replace('(','');
                newQuery = newQuery.replace(')','');
                newQuery = newQuery.trim().replace('Cases ORDER BY CaseNumber LIMIT :MAX_RELATED_LIST_SIZE',' Case where AccountId IN : setAllChilds ORDER BY CaseNumber LIMIT :MAX_RELATED_LIST_SIZE');                    
                lstCase = Database.query(newQuery);
            }
        }
        catch(Exception e)     
        {
            system.debug('Error: '+e);
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'An unexpected error has occured.');          
            ApexPages.addMessage(msg);
            throw e;
        }
    }    
}