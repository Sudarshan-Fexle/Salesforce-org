/* 
* Name          : UltimateParentRecordController
* Author        : Unknown
* Description   : UltimateParentRecordController
*                 
* Maintenance History: 
* Date --------- Name -------- Version -- Remarks 
* 07/10/2014    Hermes Yan    1.0        Update of case declartion to account for field requirements
* 06/16/2016    Rajeev Jan    1.0        SFDC schema Release - Manual Code Migration from Royall Enviournment
*/

public class UltimateParentRecordController {
    // Variables for Pagination  
    public Integer FirstPage 
    {   get;set;    }  
    public Integer sumCount
    {   get;set;    }
    public Integer currentPageCount 
    {   get{ return 25;} set;    }
    public Integer LastPage 
    {   get; set;   }
    public Boolean isShow
    {   get;set;    } 
    public Double currTotalAmt
    {   get;set;    }
    // To store the Type of Object
    public String objectType
    {   get;set;    }
    // to Store the Account Id
    public String AccId
    {   get;set;    }
    // For rendering VF component after querying desired fields only
    public boolean isRender {get;set;}
    // List size to be render
    public integer MAX_RELATED_LIST_SIZE = 10000;
    // For preventing SOQL limit hit.
    public final integer MAX_ACCOUNT_LEVEL = 25;
    public String fields{get;set;}
    public List<Account> lstAccount{get;set;}
    public List<Contact> lstContact{get;set;}
    public List<Opportunity> lstOpportunity{get;set;}
    // List for storing the Program Package Details
    public List<Program_Package__c> lstProgram_Package
    {   get;set;        }
   
    /*<!--Modified By Dipesh Gupta -CR-20190524-13151 - Date-06/18/2019 -->	*/
    /*
    // List for storing the Visit Details
    public List<Visit__c> lstVisit
    {   get;set;        } */  
    
    public List<Contract> lstContract{get;set;}
    public List<Case> lstCase{get;set;}
    public List<OpenActivity> lstOpenActivity{get;set;}
    public List<ActivityHistory> lstActivityHistory{get;set;}
    private Map<string, string> mapRelatedObjectToDefaultQuery;
    // Default Constructor
    public UltimateParentRecordController()
    {
        // Call for the Initalise Function
        Initialize();
    }
    // function for Initialise all the lists
    /** 

    * \Method initialize() 
    
    * \param None
    
    *\ return None  
    
    */ 
    private void Initialize()
    {
        isRender = false;
        // Storing the object Tpye from the URL parameter to String
        objectType = System.currentPagereference().getParameters().get('objectType');
        // Storing the object Tpye from the URL parameter to String
        AccId = System.currentPagereference().getParameters().get('id');
    }
    // Edited On 07/Jan By Nishant
    public pagereference getData()
    {  
        try
        {
            // Map between possible related list and respective query.
            mapRelatedObjectToDefaultQuery = new Map<string, string>{'Account'=>'Select Website, Industry, Phone, ParentId, Parent.Name, OwnerId, Name, Type From Account where Id IN : setAllChilds ORDER BY Name LIMIT :MAX_RELATED_LIST_SIZE',
                                                  'Opportunity'=>'Select AccountId, Name, StageName, Amount, CloseDate, Type, IsClosed, ForecastCategory From Opportunity where AccountId IN : setAllChilds ORDER BY Name LIMIT :MAX_RELATED_LIST_SIZE',
                                                  'Contact'=>'Select Name, Phone, Email, Title, Birthdate From Contact where AccountId IN : setAllChilds ORDER BY Name LIMIT :MAX_RELATED_LIST_SIZE',
                                                  'Program_Package'=>'Select Total_Contracted_Program_Cost__c, RFP_Release_Date__c, RFP_Due_Date__c, Proposal_Sent__c, Proposal_Approved__c, Name, Fiscal_Year__c, CreatedDate, Contract_Signature_Date__c, Contract_Sent__c, Account__c, OwnerId From Program_Package__c where Account__c IN : setAllChilds ORDER BY CreatedDate LIMIT :MAX_RELATED_LIST_SIZE',
                                                  'Visit'=>'Select Status__c, Program_Package__c, Name, Meeting_Type__c, Meeting_Location__c, Meeting_Date__c, LastModifiedDate, LastModifiedById, Initiated_by__c, Id, Fiscal_Year__c, CreatedDate, CreatedById, Account__c From Visit__c where Account__c IN : setAllChilds ORDER BY CreatedDate LIMIT :MAX_RELATED_LIST_SIZE',
                                                  'Contract'=>'Select AccountId, StartDate, EndDate, OwnerId, Status,ContractTerm, ContractNumber From Contract where AccountId IN : setAllChilds ORDER BY ContractNumber LIMIT :MAX_RELATED_LIST_SIZE',
                                                  'Case'=>'Select ContactId, CreatedDate, Id, SuppliedName, Status, Subject, CaseNumber, Priority, OwnerId From Case where AccountId IN : setAllChilds ORDER BY CaseNumber LIMIT :MAX_RELATED_LIST_SIZE',
                                                  'ActivityHistory'=>'Select Id ,(Select Subject, IsTask, OwnerId, ActivityType, AccountId, WhoId, WhatId, What.Name, ActivityDate, LastModifiedDate From ActivityHistories ORDER BY ActivityDate LIMIT :MAX_RELATED_LIST_SIZE) From Account where Id IN : setAllChilds ORDER BY Name LIMIT :MAX_RELATED_LIST_SIZE',
                                                  'OpenActivity'=>'Select Id , (Select AccountId, Subject, IsTask, OwnerId, Status, Priority, ActivityDate, ActivityType, WhoId, WhatId, What.Name From OpenActivities ORDER BY ActivityDate LIMIT :MAX_RELATED_LIST_SIZE) From Account where Id IN : setAllChilds ORDER BY Name LIMIT :MAX_RELATED_LIST_SIZE'};
            
            //if Parent Account Id or object name is not present in URL
            if(objectType == null || objectType == '' || AccId == null || AccId == '' || (AccId.length() != 15 && AccId.length() != 18 ) || mapRelatedObjectToDefaultQuery.get(objectType) == null)
            {    
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Invalid/Insufficient Parameter.');         
                ApexPages.addMessage(msg);
                return null;
            } 
            objectType = string.escapeSingleQuotes(objectType);
            AccId = string.escapeSingleQuotes(AccId);
            Set<Id> setAllChilds =  new Set<Id>();
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
                        strObjectFields = 'Select ' + strObjectAndFields[1] + ' ' + strObjectFields;
                        // Final map between related object and corresponding query
                        mapRelatedObjectToDefaultQuery.put(strObjectAndFields[0],strObjectFields);
                    }
                }
            }
            List<Set<Id>> lstSetIds = new List<Set<Id>>();
            // get a child Account Ids
            lstSetIds = UPUtility.generateHierarchy(AccId, MAX_RELATED_LIST_SIZE, MAX_ACCOUNT_LEVEL);
            setAllChilds = lstSetIds[1];
            getChildObjectRecords(setAllChilds);
            isRender = true;
            return null;
        }
        catch(Exception e)
        {
            system.debug('Error: '+e.getMessage());
            return null;
        }
        //return null;  
    }
    // Function for managing various function call.
    /** 
 
    * \Method getChildObjectRecords() 
    
    * \param None
    
    *\ return None  
    
    */
    private void getChildObjectRecords(Set<Id> setAllChilds)
    {   
        system.debug(mapRelatedObjectToDefaultQuery.get(objectType));        
        List<sobject> lstRecords = Database.query(mapRelatedObjectToDefaultQuery.get(objectType));
        if(objectType == 'Account')
            lstAccount = (List<Account>)lstRecords;
        //Call for fetching the Contact Records
        else if(objectType == 'Contact')
            lstContact = (List<Contact>)lstRecords;
        //Call for fetching the Opportunity Records
        else if(objectType == 'Opportunity')
            lstOpportunity = (List<Opportunity>)lstRecords;
        //Call for fetching the Program Package
        else if(objectType == 'Program_Package')
            lstProgram_Package = (List<Program_Package__c>)lstRecords;    
        //Call for fetching the Client Interaction
        
        /*<!--Modified By Dipesh Gupta -CR-20190524-13151 - Date-06/18/2019 -->	*/
        /*
        //Call for fetching the Visit
        else if(objectType == 'Visit')
            lstVisit = (List<Visit__c>)lstRecords; 
		*/
        //Call for fetching the Contract Records
        else if(objectType == 'Contract')
            lstContract = (List<Contract>)lstRecords;
        //Call for fetching the Case Records
        else if(objectType == 'Case')
            lstCase = (List<Case>)lstRecords;
        //Call for fetching the Open Activity Records
        else if(objectType == 'OpenActivity')
        {
            List<Account> lstAccountTemp = new List<Account>();
            lstAccountTemp = (List<Account>)lstRecords;
            lstOpenActivity = new List<OpenActivity>();
            for(Account objAcc : lstAccountTemp)
            {
                if(!objAcc.OpenActivities.isEmpty())
                lstOpenActivity.addAll(objAcc.OpenActivities);
            }
        }  
        //Call for fetching the Activity History Records
        else if(objectType == 'ActivityHistory')
        {
            List<Account> lstAccountTemp = new List<Account>();
            lstAccountTemp = (List<Account>)lstRecords;
            lstActivityHistory = new List<ActivityHistory>();
            for(Account objAcc : lstAccountTemp)
            {
                if(!objAcc.ActivityHistories.isEmpty())
                lstActivityHistory.addAll(objAcc.ActivityHistories);
            }
        }
        FirstPage = 0;
        // To calculate the value for Account Records
        if(objectType != 'ActivityHistory' &&  objectType != 'OpenActivity')
            sumCount = lstRecords.size();
        else if(objectType == 'ActivityHistory')
            sumCount = lstActivityHistory.size();
        else if(objectType == 'OpenActivity')
            sumCount = lstOpenActivity.size();
            
        if(lstRecords.size() <= 0)        
            LastPage = 1;        
        else       
            LastPage = Math.mod(sumCount , currentPageCount) == 0 ? sumCount / currentPageCount : sumCount / currentPageCount +1 ;                         
    }
    /*  Start Pagination Fuctions */
    public void previousPage()
     { 
        if(FirstPage - currentPageCount >= 0)
        {
            FirstPage -= currentPageCount;
        }
     }

      public void lastPage()
     {
        FirstPage = calcLastPage();        
     }
    
      private Integer calcLastPage()
     {
        if(sumCount >= currentPageCount)
        {
            return (LastPage-1)*currentPageCount;          
        }
        else
        {
            return 0;
        }
     }

    public void nextPage()
    {
        if(FirstPage + currentPageCount < sumCount)
        {
            FirstPage += currentPageCount;
        }
    }
    
    public void firstPage()
    {
        FirstPage = 0;
    }
    /*  End Pagination Functions */ 
    
    /*  End Pagination Functions */ 
    
}