/*
Purpose         :   This class is to allow user to add multiple contracts at a time with a specific criteria.
Class created under the CR-20111021-173

Create By       :  Simplyforce Technology

Created Date    :   10//2011

Current Version :   v1.0
v1.1 - Modified By - Mahendra Swarnkar - CR-20160113-9513 - 4/1/2016 - updated the "addContracts()" method 
to populate the default value for Division field on the basis of business line value on the 
program associated with the contract ABC

Revision Log    :   V1.2 - Modified By - Subhash Garhwal - Q2C Phase 2 - 6/8/2017 - Updated logic to woek for Program Subscriptions as well.
V1.3 - Modified By - Colin McGloin - Issue--CR11081--QA--00005037 - Updated Program Subscription SOQL logic to remove criteria for only 'ATL' records
V1.4 - Modified By - Subhash Garhwal - Issue--CR11081--QA--00005037 - 07/19/2017 - Updated Program Subscription SOQL query to include additional fields.
V1.5 - Modified By - Colin McGloin - CR-20171128-11817 - Apollo Hypercare - Added bypass to allow processes to be under the SOQL limit.
v1.6 - Modified BY - Mahendra Swarnkar - 12/06/2017 - CR-20171204-11830
*/
public with sharing class AddContractsToInvoiceBillingSchedule 
{
    
    //Variable to allow certain processes to be bypassed due to SOQL limits being hit
    //Added by Colin McGloin - 11/28/17 - CR-20171128-11817 - Apollo Hypercare
    public static Boolean bypassProcess = false;
    
    //variable to hold the Invoice Bu=illing Schedule properties
    public Invoice_Billing_Schedule__c invoiceBillingSchedule{get; set;}
    public List<ContractABCWrapper> listContractABCWrapper{get; set;}
    
    //flag to check if error occured in transaction
    //This flag will be used on the page to check wheater we need to show the error or we can close the window
    //as this page is using as a pop up page
    public Boolean isErrorOccured{get; set;}
    public Boolean isSaveCalled{get; set;}
    public Boolean isContractABC{get; set;}
    
    //properties to handle sorting functionality
    //Declare variable sorting parameter and Sorting direction(ASC/DESC)
    public String sortDirection {get; set;}
    public String sortExp{get; set;}
    private String lastSortExp;
    
    private ApexPages.StandardController stdController;
    
    //Default constructor for the class
    public AddContractsToInvoiceBillingSchedule(ApexPages.StandardController controller) 
    {
        invoiceBillingSchedule = (Invoice_Billing_Schedule__c)controller.getRecord();
        stdController = controller;
        
        //setup the initiale properties
        inIt();
    }
    
    //method to set up the initiale properties
    public void inIt() 
    {
        //initialize the listContractABCWrapper
        listContractABCWrapper = new List<ContractABCWrapper>();
        isErrorOccured = false;
        isSaveCalled = false;
        
        //set the initial sorting parameters
        sortDirection = 'ASC';
        sortExp = 'Name';
        
        //populate list
        populateListContractABCWrapper();
    }
    
    //Prperty to hold the list of contract records matching specified criteria
    public void populateListContractABCWrapper() 
    {
        listContractABCWrapper = new List<ContractABCWrapper>();
        
        //get the invoice billing scheduled record id from the URL
        if(invoiceBillingSchedule.Id != null) 
        {
            //Check for button
            String pSbutton = ApexPages.currentPage().getParameters().get('prosub');
            
            //Check for button
            if(String.isBlank(pSbutton)) 
            {
                isContractABC = true;
                
                //fecth the contracts records those have Status = "ATL"
                //Invoice Billing Schedule = Null
                //Payer Account = Current Invoice Billing Schedule's Institution id
                for(Contract__c contractABC : Database.query('Select Id, Name, Start__c, End__c, Invoice_Contact__c, Invoice_Contact__r.Name, Negotiated_Amount__C, CreatedDate'
                                                             + ' from Contract__c where Status__c = \'' +  Constants.STATUS_ATL + '\''
                                                             + ' AND Invoice_Billing_Schedule__c = null AND Payer_Account__c = '
                                                             + '\'' + invoiceBillingSchedule.Institution__c + '\' order by ' + sortExp + ' ' + sortDirection )) {
                                                                 
                                                                 //add the contract record in wrapper class list
                                                                 listContractABCWrapper.add(new ContractABCWrapper(false, contractABC, null));
                                                                 
                                                             }       
            } 
            else if(pSbutton == 'pSbutton') 
            {
                
                isContractABC = false;
                //Modified by Colin McGloin - Issue--CR11081--QA--00005037 - Removed criteria for Program Subscription to equal Status of 'ATL' 
                //Invoice Billing Schedule = Null
                //Std. Contract = Current Invoice Billing Schedule's Std. Contract
                for(SBQQ__Subscription__c pS : Database.query('Select Id, Name, SBQQ__StartDate__c, SBQQ__EndDate__c, Invoice_Contact__c, Invoice_Contact__r.Name, Negotiated_Amount_Subscription__c, CreatedDate,'
                                                              + 'SBQQ__Contract__c, SBQQ__Contract__r.ContractNumber, SBQQ__Product__c, SBQQ__Product__r.Name, Status__c, SBQQ__Account__c'
                                                              + ' From SBQQ__Subscription__c where RecordType.Name = \'' + 'Program' + '\''
                                                              + ' AND Invoice_Billing_Schedule__c = null AND SBQQ__Account__c = '
                                                              + '\'' + invoiceBillingSchedule.Institution__c + '\' order by ' + sortExp + ' ' + sortDirection )) {
                                                                  
                                                                  //add the contract record in wrapper class list
                                                                  listContractABCWrapper.add(new ContractABCWrapper(false, null, pS));
                                                                  
                                                              }
            }
        }
    }
    
    //Wrapper class to hold the contract record information with selected flag
    public class ContractABCWrapper 
    {
        //public properties
        public Boolean selected{get; set;}
        public Contract__c contractABC {get; set;}
        
        //Subhash Garhwal - 6/8/2017 - Added new variables to work the class for both Contract ABC and Program Subscriptions
        public SBQQ__Subscription__c programSubscription {get;set;}
        public String recordName {get;set;}
        public String recordId {get;set;}
        public Date startDate {get;set;}
        public Date endDate {get;set;}
        public String invoiceContactName {get;set;}
        public String invoiceContactId {get;set;}
        public Decimal negotiatedAmount {get;set;}
        public DateTime recordCreatedDate {get;set;}
        
        //Subhash Garhwal - Issue--CR11081--QA--00005037 - 7/19/2017 - Added new variables for additional information
        public String stdContractId {get;set;}
        public String stdContractNumber {get;set;}
        public String productId {get;set;}
        public String productName {get;set;}
        public String proSubStatus {get;set;}
        
        //Constructor
        public ContractABCWrapper(Boolean selected, Contract__c contractABC, SBQQ__Subscription__c programSubscription) 
        {
            //Set values
            this.selected = selected;
            this.contractABC = contractABC;
            this.programSubscription = programSubscription;
            
            //Set Record values
            this.recordName = programSubscription != null ? programSubscription.Name : contractABC.Name;
            this.recordId = programSubscription != null ? programSubscription.Id : contractABC.Id;
            this.startDate = programSubscription != null ? programSubscription.SBQQ__StartDate__c : contractABC.Start__c;
            this.endDate = programSubscription != null ? programSubscription.SBQQ__EndDate__c : contractABC.End__c;
            this.invoiceContactId = programSubscription != null ? programSubscription.Invoice_Contact__c : contractABC.Invoice_Contact__c;
            this.negotiatedAmount = programSubscription != null ? programSubscription.Negotiated_Amount_Subscription__c : contractABC.Negotiated_Amount__c;
            this.recordCreatedDate = programSubscription != null ? programSubscription.CreatedDate : contractABC.CreatedDate;
            
            //Check for Invoice Name
            if(programSubscription != null && programSubscription.Invoice_Contact__c != null)
                this.invoiceContactName = programSubscription.Invoice_Contact__r.Name;
            
            else if(contractABC != null && contractABC.Invoice_Contact__c != null)
                this.invoiceContactName = contractABC.Invoice_Contact__r.Name;
            
            //Subhash Garhwal - 7/19/2017 - Issue--CR11081--QA--00005037
            
            //Check for Program Subscription
            if(programSubscription != null) 
            {
                //Set values
                this.proSubStatus = programSubscription.Status__c;
                
                //Check for Contract
                if(programSubscription.SBQQ__Contract__c != null) 
                {
                    //Set values
                    this.stdContractId = programSubscription.SBQQ__Contract__c;
                    this.stdContractNumber = programSubscription.SBQQ__Contract__r.ContractNumber;
                }
                
                //Check for Product
                if(programSubscription.SBQQ__Product__c != null) 
                {
                    //Set values
                    this.productId = programSubscription.SBQQ__Product__c;
                    this.productName = programSubscription.SBQQ__Product__r.Name;
                } 
            }
        }
    }
    
    //Add contracts to the Invoice billing schedule
    public Pagereference addContracts() 
    {
        //Set bypass variable to true
        bypassProcess = true;
        
        //V1.6 - Modified BY - Mahendra Swarnkar - 12/06/2017 - CR-20171204-11830
        Util.bypassEntityPopulation = true;
        
        //create a savepoint to rolllback the transaction in case of exception
        SavePoint sp = Database.setSavePoint();
        
        try 
        {
            //set the flag as true
            isSaveCalled = true;
            
            //Create a new list of Contract ABC records to be updated
            List<Contract__c> listContractABCRecords = new List<Contract__c>();
            
            //List to update Program Subscriptions
            List<SBQQ__Subscription__c> programSubscriptions = new List<SBQQ__Subscription__c>();
            
            //Added By - Mahendra Swarnkar - CR-20160113-9513 - 4/1/2016 
            //Set to hold the business values from programs associated with those Contract ABCs which are associated with LIS
            Set<String> setBusinessLineValues = new Set<String> ();
            
            //get the selected records from the listContractABCWrapper list
            for(ContractABCWrapper wrapper : listContractABCWrapper) 
            {
                if(wrapper.selected == true) 
                {
                    
                    //update the invoice billing schedule id field with the current invoice billing schedule id
                    if(wrapper.contractABC != null) 
                    {
                        
                        wrapper.contractABC.Invoice_Billing_Schedule__c = invoiceBillingSchedule.Id;
                        
                        //add the contract abc record in list to update the record
                        listContractABCRecords.add(wrapper.contractABC);    
                    }
                    
                    //Check for Program Subscription
                    if(wrapper.programSubscription != null) 
                    {
                        
                        wrapper.programSubscription.Invoice_Billing_Schedule__c = invoiceBillingSchedule.Id;
                        
                        //add the contract abc record in list to update the record
                        programSubscriptions.add(wrapper.programSubscription);
                    }
                    
                }
            }
            
            //check for the list size and update the records in bulk
            if(listContractABCRecords.size() > 0)
                update listContractABCRecords;
            
            //check for the list size and update the records in bulk
            if(programSubscriptions.size() > 0)
                update programSubscriptions;
            
            //Added By - Mahendra Swarnkar - CR-20160113-9513 - 4/1/2016 - Starts from here 
            //Query trough Contract records which are associated with lis 
            for(Contract__c contractABC : [Select Id, Program__r.Business_line__c, Program__c, (Select Id From Line_Item_Schedule__r limit 1) 
                                           from Contract__c where Status__c = : Constants.STATUS_ATL
                                           AND Invoice_Billing_Schedule__c =: invoiceBillingSchedule.Id 
                                           AND Payer_Account__c =: invoiceBillingSchedule.Institution__c ]){
                                               
                                               //Populating set with business line values and it will help in when to populate the default division value on the IBS
                                               if(contractABC.Line_Item_Schedule__r != null && contractABC.Line_Item_Schedule__r.size() > 0
                                                  && contractABC.Program__c != null && String.isNotBlank(contractABC.Program__r.Business_line__c)){
                                                      
                                                      setBusinessLineValues.add(contractABC.Program__r.Business_line__c);       
                                                  }                         
                                           }
            
            //Query trough Contract records which are associated with lis
            //Modified by Colin McGloin - Issue--CR11081--QA--00005037 - Removed criteria for Program Subscription to equal Status of 'ATL' 
            for(SBQQ__Subscription__c pS : [Select Id, Program__r.Business_line__c, Program__c, (Select Id From Line_Item_Schedules__r LIMIT 1) 
                                            From SBQQ__Subscription__c Where Invoice_Billing_Schedule__c =: invoiceBillingSchedule.Id 
                                            AND SBQQ__Contract__c =: invoiceBillingSchedule.Standard_Contract__c]){
                                                
                                                //Populating set with business line values and it will help in when to populate the default division value on the IBS
                                                if(pS.Line_Item_Schedules__r != null && pS.Line_Item_Schedules__r.size() > 0
                                                   && pS.Program__c != null && String.isNotBlank(pS.Program__r.Business_line__c)){
                                                       
                                                       setBusinessLineValues.add(pS.Program__r.Business_line__c);       
                                                   }                         
                                            }
            
            //Check for the size
            if(setBusinessLineValues.size() > 0) 
            {
                
                //Counters to hold the count for business line values "SW" and "CLN"
                Integer countSW ;
                Integer countCLN;
                
                //Loop through Business line values helde by by setBusinessLineValues
                for(String businessLine : setBusinessLineValues)
                {
                    
                    //Check for the Business line values and update their respective counter
                    if(businessLine == 'SW')
                    {
                        if(countSW != null)
                            countSW++;
                        else
                            countSW = 1;
                    }
                    else
                    {
                        if(businessLine == 'CLN')
                        {
                            if(countCLN != null)
                                countCLN++;
                            else
                                countCLN = 1;
                        }
                    }
                }
                
                //Hold the prior value Division field on the IBS
                String priorIBS_Division = invoiceBillingSchedule.Division__c;
                
                //Check for business line values
                //  1)If all Contract ABCs associated with an Invoice Billing Schedule have Business Line = CLN, then Division = CLN.
                //  2) If all Contract ABCs associated with an Invoice Billing Schedule have Business Line = SW, then Division = SW.
                //  3) If more than 1 type of value  - then default Division on the IBS to "ABC Corporate"
                //  4) If have Business Line values other than CLN and SW - then default Division on the IBS to "ABC Corporate"
                if(countSW != null && countSW == setBusinessLineValues.size())
                    invoiceBillingSchedule.Division__c = 'SW';
                else 
                {
                    if(countCLN != null && countCLN == setBusinessLineValues.size())
                        invoiceBillingSchedule.Division__c = 'CLN';
                    else
                        invoiceBillingSchedule.Division__c = 'ABC Corporate';
                }
                
                //Check for the change of the division on IBS and then update IBS record
                if(priorIBS_Division != invoiceBillingSchedule.Division__c)
                {
                    Util.BypassAllTriggers = true;
                    update invoiceBillingSchedule;
                    Util.BypassAllTriggers = false;
                    priorIBS_Division = null;
                }
            }
            //Added By - Mahendra Swarnkar - CR-20160113-9513 - 4/1/2016 - Ends here
            
            return stdController.view();
            
        } 
        catch(Exception e) 
        {
            
            //rollback the complete transaction as teh exception occured
            database.rollback(sp);
            
            //add error on page
            ApexPages.addmessages(e);
            
            //set the error flag as true 
            isErrorOccured = true;
            return null;
        }
    }
    
    //sorting function
    public void setupSort() 
    {
        if(sortDirection == 'ASC')
            sortDirection = 'DESC';
        else
            sortDirection = 'ASC';
        
        //populate the data
        populateListContractABCWrapper();
    }
}