//Modified By - Abhinav Sharma - 05/24/2014 - CR-20140321-4840
//Modified By - Subhash Garhwal - 06/7/2017 - Q2C Phase 2 - DS145
public class LineItemScheduleCloneController{
    
    //Variables
    public Contract__c contractABC { get; set; }
    public boolean isSuccess {
        get {
            if (isSuccess == null) isSuccess = false;
            return isSuccess;
        }
        set;
    }
    private set<Id> selectedContractIds { get; set; }
    public boolean selectValue { get; set; }
    public string selectAllType { get; set; }
    public boolean isChecked_LineItems { get; set; }
    
    //Variables for Program Subscriptions
    Public SBQQ__Subscription__c proSubscription {get;set;}
    private set<Id> selectedproSubIds { get; set; }
    
    //Calling Constructor
    public LineItemScheduleCloneController() {
        
        //Get the contract ABC Id from the page parameters
        Id parentId = ApexPages.currentPage().getParameters().get('id');
        
        if(parentId == null) {return;}
        
        //Call method to populate Contract ABC or Program Subscription
        populateInitialData(parentId);
        
        //Check for Contract ABC
        if(contractABC != null) {
            
            getContractMap();
            
            //Checking for Invoice Billing Schedule attached on ContractsABC record
            if (contractABC.Invoice_Billing_Schedule__c == null) {
            
                //Return error to the VF Page
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The Contract ABC record must contain an Invoice Billing Schedule'));
            
            } else if (contractABC.Line_Item_Schedule__r.size() == 0) {
            
                //Return error to the VF Page
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The Contract ABC record must contain at least one Line Item Schedule'));
            }
            
                
        } else if(proSubscription != null) {
            
            getmapProgramSubscriptions();
            
            //Checking for Invoice Billing Schedule attached on ContractsABC record
            if (proSubscription.Invoice_Billing_Schedule__c == null) {
            
                //Return error to the VF Page
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The Program Subscription record must contain an Invoice Billing Schedule'));
            
            } else if (proSubscription.Line_Item_Schedules__r.size() == 0) {
            
                //Return error to the VF Page
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The Program Subscription record must contain at least one Line Item Schedule'));
            }
        }
        
        isChecked_LineItems = true;
        
    }
    
    /**
     * 
     *  @description:   :   This method is used to get the Program Subscription or Contract ABC   
     *
     *  @args           :   String
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - Created - 06/7/2017 - Subhash Garhwal - DS145
     * 
     **/
    private void populateInitialData(Id recordId) {
        
        //Id of Contract
        if(recordId.getSobjectType() == Schema.Contract__c.SObjectType) {
            
            //Get the contract ABC record we are going to clone IBS records to
            contractABC = [SELECT Id, Invoice_Billing_Schedule__c, Name, Program_Acronym__c, 
                            (SELECT Id, Name, Program_Subscription__c, Contract__c, Invoice_Amount__c, Invoice_Billing_Schedule_del__c, Invoice_Comment__c,
                             Invoice_Date__c, Line_Item_Comment__c, Line_Item_Comment_2__c, OriginalLineItemSchedule__c, SalesCreditNote__c,
                             Sales_Invoice__c, Solomon_Product_Code__c, Type__c, Amount__c, Validation__c FROM Line_Item_Schedule__r ORDER BY Invoice_Date__c ASC)  
                           FROM Contract__c WHERE Id = : recordId AND Record_Source__c != :CPQConstants.RECORD_SOURCE_PLACEHOLDER];
        } else if(recordId.getSobjectType() == Schema.SBQQ__Subscription__c.SObjectType) {
            
            //Get the Program Subscription record
            proSubscription = [SELECT Id, SBQQ__Contract__c, Invoice_Billing_Schedule__c, Name, Program_Acronym__c,
                                (SELECT Id, Name, Program_Subscription__c, Contract__c, Invoice_Amount__c, Invoice_Billing_Schedule_del__c, Invoice_Comment__c,
                                 Invoice_Date__c, Line_Item_Comment__c, Line_Item_Comment_2__c, OriginalLineItemSchedule__c, SalesCreditNote__c,
                                 Sales_Invoice__c, Solomon_Product_Code__c, Type__c, Amount__c, Validation__c FROM Line_Item_Schedules__r ORDER BY Invoice_Date__c ASC)  
                               FROM SBQQ__Subscription__c WHERE Id = : recordId];
        }
    }
    
    
    //Save the line item schedules to the contract
    public pageReference save() {
        
        //get the record type for un-invoiced line items
        Id rtId = Schema.SObjectType.Line_Item_Schedule__c.RecordTypeInfosByName.get('Line Item Schedule').RecordTypeId;
        
        //List to hold the line item schedule records
        list<Line_Item_Schedule__c> lineItemSchedToInsert = new list<Line_Item_Schedule__c>();
        
        //clone the line item schedules from the chosen contract(s)
        for (ContractWrapper wrapper : selectedContractWrappers) {
            
            //Modified By - Abhinav Sharma - 05/24/2014 - CR-20140321-4840
            //loop through each line item schedule and clone / add to our insert list
            for (LineItemWrapper lineItemWrapper : wrapper.lineItems) {
                
                //Checking for the selected value
                if (lineItemWrapper.isSelected) {
                    lineItemWrapper.LineItem.Invoice_Amount__c = lineItemWrapper.LineItem.Amount__c;
                    lineItemWrapper.LineItem.Sales_Invoice__c = null;
                    lineItemWrapper.LineItem.RecordTypeId = rtId;
                    lineItemWrapper.LineItem.Invoiced__c = false;
                    lineItemSchedToInsert.add(lineItemWrapper.LineItem);
                }
            }
        }
        
        //Make sure there is at least one record to clone
        if (lineItemSchedToInsert.size() == 0) {
            
            //Return errors to the VF Page
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You must select at least one record to clone'));
            return null;
        }
        
        //save
        try {
        
            insert lineItemSchedToInsert;
        
        } catch(DMLException ex) {
        
            //Return errors to the VF Page
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getDMLMessage(0)));
            return null;
        
        } catch(Exception ex) {
          
            //Return errors to the VF Page
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            return null;
        
        }
        
        //Reset our lists so we pull updated contract info
        contractWrappers = null;
        contractMap = null;
        
        //Saved successfully
        isSuccess = true;
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Saved Successfully'));
        return null;
    }
    
    transient map<Id, Contract__c> contractMap { get; set; }
    
    //Get all contracts and related line item schedules with the same Invoice Billing Schedule
    private map<Id, Contract__c> getContractMap() {
        if (contractMap == null && contractABC != null) {
            Id invBillingSched = contractABC.Invoice_Billing_Schedule__c;
            Id contractId = contractABC.Id;
            string queryString = 'SELECT Id, Name, Start__c, End__c, Program_Acronym__c, Historical_Linker__c, Negotiated_Amount__c, Line_Item_Schedule_Total__c,' +
                '(SELECT Id, Name, Contract__c, Invoice_Amount__c, Invoice_Billing_Schedule_del__c, Invoice_Comment__c,' +
                'Invoice_Date__c, Line_Item_Comment__c, Line_Item_Comment_2__c, OriginalLineItemSchedule__c, SalesCreditNote__c,' +
                'Sales_Invoice__c, Solomon_Product_Code__c, Type__c, Amount__c, Validation__c FROM Line_Item_Schedule__r) ' +
                'FROM Contract__c ' +
                'WHERE Invoice_Billing_Schedule__c = :invBillingSched AND Id != :contractId AND Record_Source__c != \'' + CPQConstants.RECORD_SOURCE_PLACEHOLDER + '\'';
            if (selectedContractIds != null && selectedContractIds.size() > 0) queryString += ' AND Id IN :selectedContractIds';
            queryString += ' ORDER BY Start__c ASC';
            contractMap = new map<Id, Contract__c>((list<Contract__c>)database.query(queryString));
        }
        return contractMap;
    }
    
    //Subhash Garhwal - 6/7/2017
    transient map<Id, SBQQ__Subscription__c> mapProgramSubscriptions { get; set; }
    
    //Get all Program Subscriptions and related line item schedules with the same Invoice Billing Schedule
    Private map<Id, SBQQ__Subscription__c> getmapProgramSubscriptions() {
        
        //Check for subs
        if (mapProgramSubscriptions == null && proSubscription != null && proSubscription.Invoice_Billing_Schedule__c != null) {
            
            //Get IBS Id
            Id invBillingSched = proSubscription.Invoice_Billing_Schedule__c;
            Id proSubId = proSubscription.Id;
            
            //SOQL query string
            String SOQL = 'SELECT Id, Name, SBQQ__StartDate__c, SBQQ__EndDate__c, Program_Acronym__c, Historical_Linker__c, Negotiated_Amount_Subscription__c, Line_Item_Schedule_Total_Subscription__c,' +
                '(SELECT Id, Name, Program_Subscription__c, Contract__c, Invoice_Amount__c, Invoice_Billing_Schedule_del__c, Invoice_Comment__c,' +
                'Invoice_Date__c, Line_Item_Comment__c, Line_Item_Comment_2__c, OriginalLineItemSchedule__c, SalesCreditNote__c,' +
                'Sales_Invoice__c, Solomon_Product_Code__c, Type__c, Amount__c, Validation__c FROM Line_Item_Schedules__r) ' +
                'FROM SBQQ__Subscription__c ' +
                'WHERE Invoice_Billing_Schedule__c =: invBillingSched AND Id !=: proSubId';
                
            //Check for     
            if (selectedproSubIds != null && selectedproSubIds.size() > 0) SOQL += ' AND Id IN :selectedproSubIds';
            SOQL += ' ORDER BY SBQQ__StartDate__c ASC';
            mapProgramSubscriptions = new Map<Id, SBQQ__Subscription__c>((List<SBQQ__Subscription__c>)database.query(SOQL));
        }
        return mapProgramSubscriptions;
    }
    
    //Wrapper list
    public list<ContractWrapper> contractWrappers {
        get {
            if (contractWrappers == null) {
                contractWrappers = new list<ContractWrapper>();
                
                //Get Contract
                Map<Id, Contract__c> mapContracts = getContractMap();
                
                if(mapContracts != null && mapContracts.size() > 0) {
                    
                    for (Contract__c contract : mapContracts.values())
                        contractWrappers.add(new ContractWrapper(contract, contractABC.Line_Item_Schedule__r, null));
                    
                    return contractWrappers;
                }
                
                //Get Program Subscriptions
                Map<Id, SBQQ__Subscription__c> mapProgramSubs = getmapProgramSubscriptions();
                
                if(mapProgramSubs != null && mapProgramSubs.size() > 0) {
                    
                    for (SBQQ__Subscription__c pS : mapProgramSubs.values())
                        contractWrappers.add(new ContractWrapper(null, proSubscription.Line_Item_Schedules__r, pS));
                    
                    return contractWrappers;
                }
            }
            
            return contractWrappers;
        }
        set;
    }
    
    public list<ContractWrapper> selectedContractWrappers {
        get {
            selectedContractWrappers = new list<ContractWrapper>();
            for (ContractWrapper wrapper : contractWrappers) {
                if (wrapper.isSelected) selectedContractWrappers.add(wrapper);
            }
            return selectedContractWrappers;
        }
        set;
    }
    
    //recalculate totals
    public void recalculateTotals() {
        for (ContractWrapper wrapper : selectedContractWrappers) {
            wrapper.total = null;
        }
    }
    
    //Wrapper Class for contracts
    public class ContractWrapper {
        
        //Properties
        public boolean isSelected { get; set; }
        public Id contractId { get; set; }
        public string contractName { get; set; }
        public string historicalLinker { get; set; }
        public string programAcronym { get; set; }
        public date startDate { get; set; }
        public date endDate { get; set; }
        public double negotiatedAmount { get; set; }
        public integer numLineItems { get; set; }
        public Id proSubId {get;set;}
        
        public double total {
            get {
                if (total == null) {
                    total = 0;
                    for (LineItemWrapper item : lineItems) {
                        if (item.lineItem.Amount__c != null)
                            total += item.lineItem.Amount__c;
                    }
                }
                return total;
            }
            set;
        }
        public double discrepancy {
            get {
                //just in case negotiated amt or total is null, default to zero
                if (negotiatedAmount == null)
                    negotiatedAmount = 0;
                if (total != null && negotiatedAmount != null)
                    discrepancy = total - negotiatedAmount;
                return discrepancy;
            }
            set;
        }
        public list<LineItemWrapper> lineItems {
            get {
                if (lineItems == null) lineItems = new list<LineItemWrapper>();
                return lineItems;
            }
            set;
        }
        
        //Constructor
        public ContractWrapper(Contract__c contract, list<Line_Item_Schedule__c> originalLineItems, SBQQ__Subscription__c proSub) {
            
            //Set values
            this.isSelected = false;
            this.contractId = contract != null ? contract.Id : null;
            this.proSubId = proSub != null ? proSub.Id : null;
            this.contractName = contract != null ? contract.Name : proSub.Name;
            this.programAcronym = contract != null ? contract.Program_Acronym__c : proSub.Program_Acronym__c;
            this.historicalLinker = contract != null ? contract.Historical_Linker__c : proSub.Historical_Linker__c;
            this.startDate = contract != null ? contract.Start__c : proSub.SBQQ__StartDate__c;
            this.endDate = contract != null ? contract.End__c : proSub.SBQQ__EndDate__c;
            this.negotiatedAmount = contract != null ? contract.Negotiated_Amount__c : proSub.Negotiated_Amount_Subscription__c;
            this.numLineItems = contract != null ? contract.Line_Item_Schedule__r.size() : proSub.Line_Item_Schedules__r.size();
            this.total = contract != null ? contract.Line_Item_Schedule_Total__c : proSub.Line_Item_Schedule_Total_Subscription__c;
            this.lineItems = createLineItemWrappers(originalLineItems);
        }
        
        private list<LineItemWrapper> createLineItemWrappers(list<Line_Item_Schedule__c> items) {
            //loop through each line item schedule and clone / add to our list
            for (Line_Item_Schedule__c lineItemSched : items) {
                
                lineItems.add(new LineItemWrapper(lineItemSched, contractId, proSubId));
            }
            return lineItems;
        }
    }
    
    //wrapper class for line items
    public class LineItemWrapper {
        
        //properties
        public boolean isSelected { get; set; }
        public Id originalLineItemId { get; set; }
        public Line_Item_Schedule__c lineItem { get; set; }
        
        //Subhash Garhwal - 6/7/2017 - Added Program sunscription Id
        public LineItemWrapper(Line_Item_Schedule__c originalLineItem, Id contractId, Id programSubscriptionId) {
            this.originalLineItemId = originalLineItem.Id;
            this.lineItem = cloneLineItem(originalLineItem, contractId, programSubscriptionId);
            this.isSelected = true;
        }
        
        //this constructor is used on the lineItemScheduleUpsertController
        //Subhash Garhwal - 6/7/2017 - Added Program sunscription Id
        public LineItemWrapper(Line_Item_Schedule__c originalLineItem, Id contractId, boolean cloneItem, Id programSubscriptionId) {
            this.originalLineItemId = originalLineItem.Id;
            if (cloneItem)
                this.lineItem = cloneLineItem(originalLineItem, contractId, programSubscriptionId);
            else
                this.lineItem = originalLineItem;
            this.isSelected = true;
        }
        
        //Subhash Garhwal - 6/7/2017 - Added Program sunscription Id
        private Line_Item_Schedule__c cloneLineItem(Line_Item_Schedule__c originalLineItem, Id contractId, Id programSubscriptionId) {
            Line_Item_Schedule__c item = originalLineItem.clone();
            item.Contract__c = contractId;
            item.Invoice_Amount__c = item.Amount__c;
            item.Line_Item_Comment__c = null;
            item.Line_Item_Comment_2__c = null;
            item.Invoiced__c = false;
            item.Program_Subscription__c = programSubscriptionId;
            return item;
        }
    }
    
    //toggle the selected values
    public void toggleSelected() {
        if (selectAllType != null) {
            if (selectAllType.equalsIgnoreCase('CONTRACTS') || selectAllType.equalsIgnoreCase('PROGRAMSUBSCRIPTIONS')) {
                for (ContractWrapper contractWrapper : contractWrappers) {
                    contractWrapper.isSelected = selectValue;
                }
            }
            else if (selectAllType.equalsIgnoreCase('LINEITEMS')) {
                isChecked_LineItems = selectValue;
                for (ContractWrapper contractWrapper : contractWrappers) {
                    for (LineItemWrapper itemWrapper : contractWrapper.lineItems) {
                        itemWrapper.isSelected = selectValue;
                    }
                }
            }
            else if (selectAllType instanceof Id) {
                //toggle the value for all items in the selected row
                for (ContractWrapper contractWrapper : ContractWrappers) {
                    for (LineItemWrapper itemWrapper : contractWrapper.lineItems) {
                        if (itemWrapper.originalLineItemId == selectAllType) itemWrapper.isSelected = selectValue;
                    }
                }
                //recalculate totals once the proper items have been checked or un-checked
                recalculateTotals();
            }
        }
    }
    
    public boolean hasErrors {
        get {
            return (apexPages.getMessages() != null && apexPages.getMessages().size() > 0 && !isSuccess);
        }
        set;
    }
}