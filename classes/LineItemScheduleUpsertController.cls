/** 
*  Purpose      :  Controller class for Line Item Schedule Mass Upsert page
*
*  Created By    :  Victor Hanson
*
*  Created Date  :  10/23/2014
*
*  Revision Logs  :  V_1.0 - Created
*                    V_1.1 - Modified By - Abhinav Sharma - 12-01-2015 - CR-20141120-8130
*                    V_1.2 - Modified By - Abhinav Sharma - 13-02-2015 - CR-20150129-8606
*                    V_1.3 - Modified By - Subhash Garhwal - 06-07-2017 - Q2C Phase 2
*					 V_1.4 - Modified By - Colin McGloin - 04/04/2018 - CR-20180123-11898
*
**/ 
public class LineItemScheduleUpsertController {
    
    //Properties
    public boolean selectValue {get; set;}
    
    //Variable to hold the return URL value
    public string retURL { get; set; }
    
    //Contract
    public Contract__c contractABC {get; set;}
    
    //Invoice Billing Schedule
    public Invoice_Billing_Schedule__c invoiceBillingSchedule {get; set;}
    
    //Line Item Schedule Instances and collections
    public Line_Item_Schedule__c lISchedule {get; set;}
    public Line_Item_Schedule__c lItemSchedule {get; set;}
    
    //String variable to hold the historiocal linker input value on page
    public String hLinker {get; set;}
    
    //Wrapper instance
    public FilterWrapper filterInstance {get; set;}
    
    //Standard Set Controller instance
    public ApexPages.StandardSetController con {get; set;}
    
    //map to hold the updated values
    Map<Id, Line_Item_Schedule__c> mapLineItemSchedules;
    
    //Variable to hold the page size
    Integer PAGE_SIZE;
    
    //Subhash Garhwal - Added variables for Program Subscription
    public SBQQ__Subscription__c programSubscription {get;set;}
  
    //Constructor
    public LineItemScheduleUpsertController() {
        
        //Setting defaults
        selectValue = true;
        PAGE_SIZE = 200;
        
        //Memory allocation
        filterInstance = new FilterWrapper();
        lISchedule = new Line_Item_Schedule__c();
        lItemSchedule = new Line_Item_Schedule__c();
        mapLineItemSchedules = new Map<Id, Line_Item_Schedule__c>();
        
        //Fecthing return URL value from the current page URL value
        retURL = ApexPages.currentPage().getParameters().get('retURL');
        
        //Calling method to apply default logic
        inIt();
    }
    
    /**
     * @description: Method to perform the defalut logic on page load
    **/
    public void inIt() {
        
        //Checking Id value for sObject Type
        if(!String.isBlank(ApexPages.currentPage().getParameters().get('id'))) {
            
            //Populating standard set controller with LIS records
            populateStandardSetController();
            
        //User navigated to VF page from Line Item Schedule List view
        } else {
            
            //String to hold the param value to hold selected LIS records Ids
            String contractABCIdString = ApexPages.currentPage().getParameters().get('ids');
                            
            //Checking string for null value    
            if (String.isNotBlank(contractABCIdString)) {
                            
                //List to hold selected LIS records Ids
                list<string> contractABCIdList = contractABCIdString.split(',');
                            
                //Checking list for size value and populating standardSetController instance with list view LIS records
                if(contractABCIdList.size() > 0)
                    populateStandardSetControllerWithListViewSelectedLIS(quotedString(contractABCIdList));
            }
        }
    }
    
    /**
     * @description: Method to populate standard set controller with the line item schedule records.
    **/
    public void populateStandardSetController() {
    
        //ID value present in the URL
        ID sObjId = ID.valueOf(ApexPages.currentPage().getParameters().get('id'));
        
        //Query string
        String sOQLQuery = '';
            
        //ID of contract record
        if(sObjId.getSobjectType() == Schema.Contract__c.SObjectType) {
                
            //Checking contractABC instance for null value
            if (contractABC == null) {
                
                //Get the contract ABC record and all related Line Item Schedules
                contractABC = [SELECT Id, Invoice_Billing_Schedule__c, Name, Program_Acronym__c, Historical_Linker__c 
                                FROM Contract__c WHERE Id = : sObjId];
                                
                //Query string
                sOQLQuery += 'SELECT Id, Name, Contract__c, Program_Subscription__c, Invoice_Amount__c, Invoice_Billing_Schedule_del__c, Invoice_Comment__c, Invoiced__c,' +
                             'Invoice_Date__c, Line_Item_Comment__c, Line_Item_Comment_2__c, OriginalLineItemSchedule__c, SalesCreditNote__c,' + 
                             'Sales_Invoice__c, Solomon_Product_Code__c, Type__c, Amount__c, Validation__c, Contract__r.Record_Source__c FROM Line_Item_Schedule__c' +
                             ' WHERE Contract__c != null AND Contract__c = \'' + sObjId + '\' AND Contract__r.Record_Source__c != \'' + CPQConstants.RECORD_SOURCE_PLACEHOLDER + '\'' +
                             ' AND Invoiced__c = false' +
                             ' ORDER BY Invoice_Date__c ASC';
            }
        //ID of Invoice Billing Schedule record
        } else if(sObjId.getSobjectType() == Schema.Invoice_Billing_Schedule__c.SObjectType) {
                
            //Checking invoice billing schedule instance for null value
            if(invoiceBillingSchedule == null) {
                
                //Setting defaults
                lISchedule.Type__c = '';
                
                //Invoice billing schedule record details
                invoiceBillingSchedule = [SELECT Id FROM Invoice_Billing_Schedule__c WHERE Id = : sObjId];
                
                //Query string
                sOQLQuery += 'SELECT Id, Name, Contract__c, Invoice_Amount__c, Program_Subscription__c, Invoice_Billing_Schedule_del__c,' +
                            'Invoice_Comment__c, Invoiced__c, Invoice_Date__c, Line_Item_Comment__c,' +
                            'Line_Item_Comment_2__c, OriginalLineItemSchedule__c, SalesCreditNote__c,' +
                            'Sales_Invoice__c, Solomon_Product_Code__c, Type__c, Amount__c, Contract__r.ID,' + 
                            'Contract__r.Invoice_Billing_Schedule__c, Contract__r.Name,' + 
                            'Contract__r.Program_Acronym__c, Program_Subscription__r.Program_Acronym__c, Contract__r.Historical_Linker__c,  Program_Subscription__r.Historical_Linker__c,' +
                            'Program_Subscription__r.SBQQ__Contract__c, Program_Subscription__r.Invoice_Billing_Schedule__c, Program_Subscription__r.Name,' +   
                            'Validation__c FROM Line_Item_Schedule__c' +
                            ' WHERE Invoice_Billing_Schedule_del__c != null AND Invoice_Billing_Schedule_del__c = \'' + sObjId + '\'' +
                            ' AND Invoiced__c = false' +
                            ' ORDER BY Invoice_Date__c ASC';
            }
        
        //Subhash Garhwal - 06-07-2017 - ID of Program Subscription record 
        } else if(sObjId.getSobjectType() == Schema.SBQQ__Subscription__c.SObjectType) {
            
            //Get the contract ABC record and all related Line Item Schedules
            programSubscription = [SELECT Id, SBQQ__Contract__c, Invoice_Billing_Schedule__c, Program_Acronym__c,  Name FROM SBQQ__Subscription__c
                                          WHERE Id = : sObjId];
                            
            //Query string
            sOQLQuery += 'SELECT Id, Name, Program_Subscription__c, Contract__c, Invoice_Amount__c, Invoice_Billing_Schedule_del__c, Historical_Linker__c, Invoice_Comment__c, Invoiced__c,' +
                         'Invoice_Date__c, Line_Item_Comment__c, Line_Item_Comment_2__c, OriginalLineItemSchedule__c, SalesCreditNote__c,' + 
                         'Sales_Invoice__c, Solomon_Product_Code__c, Type__c, Amount__c, Validation__c FROM Line_Item_Schedule__c' +
                         ' WHERE Program_Subscription__c != null AND Program_Subscription__c = \'' + sObjId + '\'' +
                         ' AND Invoiced__c = false' +
                         ' ORDER BY Invoice_Date__c ASC';
            
        }
        
        //Checking query string for blank value
        if(sOQLQuery != '') {
            
            //Making query for the line items associated with the invoice billing schedule record
            con = new ApexPages.StandardSetController(Database.getQueryLocator(sOQLQuery));
            
            // sets the number of records in each page set
            con.setPageSize(PAGE_SIZE);
        }
    }
    
    /**
     * @description: Method to populate standard set controller instance with the LIS list view selected records
    **/
    public void populateStandardSetControllerWithListViewSelectedLIS(String selectedLISRecordsIds) {
        
        //Checking string for blank/null value
        if(String.isNotBlank(selectedLISRecordsIds)) {
        
            //Query String
            String sOQLQuery = 'SELECT Id, Name, Program_Subscription__c, Contract__c,  Contract__r.Program_Acronym__c, Program_Subscription__r.Program_Acronym__c, Invoice_Amount__c, Invoice_Billing_Schedule_del__c,' +
                               'Invoice_Comment__c, Invoiced__c, Invoice_Date__c, Line_Item_Comment__c, Line_Item_Comment_2__c,' +
                               'OriginalLineItemSchedule__c, SalesCreditNote__c, Program_Subscription__r.Historical_Linker__c, Contract__r.Historical_Linker__c,' +
                               'Sales_Invoice__c, Solomon_Product_Code__c, Type__c, Amount__c, Validation__c FROM Line_Item_Schedule__c' +
                               ' WHERE Id IN ' + selectedLISRecordsIds + ' ORDER BY Invoice_Date__c ASC';
                  
            //Making query for the line items associated with the invoice billing schedule record
            con = new ApexPages.StandardSetController(Database.getQueryLocator(sOQLQuery));
    
            // sets the number of records in each page set
            con.setPageSize(PAGE_SIZE);
        }
    }
    
    /**
     * @description: Method to populate standard set controller instance with the line item schedules
    **/
    public void populateStandardSetControllerWithFilters(String hLinkers, Date invoiceDate) {
        
        //Parent record ID
        ID sObjIdValue = ID.valueOf(ApexPages.currentPage().getParameters().get('id'));
        
         //String to hold the query string
        String sOQLQuery =  'SELECT Id, Name, Contract__c, Program_Subscription__c, Invoice_Amount__c, Invoice_Billing_Schedule_del__c,' +
                            'Invoice_Comment__c, Invoiced__c, Invoice_Date__c, Line_Item_Comment__c,' +
                            'Line_Item_Comment_2__c, OriginalLineItemSchedule__c, SalesCreditNote__c,' +
                            'Sales_Invoice__c, Solomon_Product_Code__c, Type__c, Amount__c, Contract__r.ID,' + 
                            'Contract__r.Invoice_Billing_Schedule__c, Contract__r.Name, Program_Subscription__r.Invoice_Billing_Schedule__c, ' + 
                            'Contract__r.Program_Acronym__c, Program_Subscription__r.Program_Acronym__c, Contract__r.Historical_Linker__c, Program_Subscription__r.Historical_Linker__c,' +  
                            'Validation__c FROM Line_Item_Schedule__c ' +
                            'WHERE Invoice_Billing_Schedule_del__c = \'' + sObjIdValue + '\' AND ' +
                            'Invoiced__c = false AND ';
        
        //Several filters related use cases
        if(String.isNotBlank(hLinkers) && invoiceDate != null)
            sOQLQuery += '(Contract__r.Historical_Linker__c = \'' + hLinkers + '\' OR Program_Subscription__r.Historical_Linker__c = \'' + hLinkers + '\')'
                        + ' AND Invoice_Date__c = : invoiceDate';
        else if(String.isNotBlank(hLinkers))
            sOQLQuery += '(Contract__r.Historical_Linker__c = \'' + hLinkers + '\' OR Program_Subscription__r.Historical_Linker__c  = \'' + hLinkers + '\')';
        else if(invoiceDate != null)
            sOQLQuery += 'Invoice_Date__c = : invoiceDate';
        else
            sOQLQuery = '';
            
        //Checking query string for blank value
        if(sOQLQuery != '') {
            
            //Applying ordering
            sOQLQuery += ' ORDER BY Invoice_Date__c ASC';
                    
            //Making query for the line items associated with the invoice billing schedule record
            con = new ApexPages.StandardSetController(Database.getQueryLocator(sOQLQuery));
            
            // sets the number of records in each page set
            con.setPageSize(PAGE_SIZE);
        }
    }
    
    /**
     * @description : Line Item Schedules 
    **/
    private list<Line_Item_Schedule__c> lineItemSchedules {
        get {
            
            //Checking if list of LIS is having null value with it
            //Populating list of LIS with the records returned via standard set controller
            if (lineItemSchedules == null)
                lineItemSchedules = (List<Line_Item_Schedule__c>)con.getRecords().deepClone(true, true, true);
            
            //Returning line Item Schedules    
            return lineItemSchedules;
        }
        set;
    }
    
    /**
     * @description:  list of line item wrappers
    **/
    public list<LineItemScheduleCloneController.LineItemWrapper> lineItemWrappers {
        get {
            
            if (lineItemWrappers == null) {
                    
                //Memory allocation
                lineItemWrappers = new list<LineItemScheduleCloneController.LineItemWrapper>();
                
                //loop through each existing line item schedule and add to our wrappers
                for (Line_Item_Schedule__c item : lineItemSchedules ) {
                    
                    //Wrapper instance
                    LineItemScheduleCloneController.LineItemWrapper itemWrapper;
                    
                    //Subhash Garhwal - 6/7/2017
                    String contractABCId = contractABC == null ? item.Contract__c : contractABC.Id;
                    String programSubsId = programSubscription == null ? item.Program_Subscription__c : programSubscription.Id; 
                    
                    itemWrapper = new LineItemScheduleCloneController.LineItemWrapper(item, contractABCId, false, programSubsId);
                    
                    /*if (contractABC == null)
                        itemWrapper = new LineItemScheduleCloneController.LineItemWrapper(item, item.Contract__c, false);
                    else
                        itemWrapper = new LineItemScheduleCloneController.LineItemWrapper(item, contractABC.Id, false);
                    */
                    if (item.Invoiced__c) itemWrapper.isSelected = false;
                    
                    //Adding wrapper instance into the list
                    lineItemWrappers.add(itemWrapper);
                }
            }
            return lineItemWrappers;
        }
        set;
    }
    
    /**
     * @description: Selected Line Item Schedules
    **/
    private list<Line_Item_Schedule__c> selectedLineItems {
        get {
            selectedLineItems = new list<Line_Item_Schedule__c>();
            for (LineItemScheduleCloneController.LineItemWrapper item : lineItemWrappers) {
                if (item.isSelected) {
                    selectedLineItems.add(item.LineItem);
                }
            }
            return selectedLineItems;
        }
        set;
    }
    
    /**
     * @description:  Upserts any selected Line Items
     * 
     **/
    public void save() {
        
        try {
            //validate that all required fields are populated
            validateSelectedItems();
            
            //Add in Bypass Trigger Flag - CM - CR-20180123-11898
            Util.BypassAllTriggers = true;
            
            //Upsert records
            upsert selectedLineItems;
            
            //Set Bypass Trigger Flag to False
            Util.BypassAllTriggers = false;
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, System.Label.LineItemSchedule_MassUpsert_CL2));
        }
        catch(DMLException ex) {
            //Return errors to the VF Page
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getDMLMessage(0)));
        }
        catch(Exception ex) {
            //Return errors to the VF Page
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
        }
        
        if (apexPages.getMessages().size() > 0 && String.valueOf(apexPages.getMessages()[0]) != System.Label.LineItemSchedule_MassUpsert_CL2)
            hasErrors = true;
    }
    
    /**
     * @description:  Delete selected line item schedules
     **/
    public void deleteRows() {
        
        list<Line_Item_Schedule__c> itemsToDelete = new list<Line_Item_Schedule__c>();
        
        //remove any items from the list that haven't been saved yet
        for (Line_Item_Schedule__c item : selectedLineItems) {
            if (item.Id != null) 
                itemsToDelete.add(item);
        }
        
        try {
            delete itemsToDelete;
        }
        catch(DMLException ex) {
            //Return errors to the VF Page
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getDMLMessage(0)));
        }
        catch(Exception ex) {
            //Return errors to the VF Page
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
        }
    }
    
    /**
     * @description: Validating selected line item schedules
    **/
    private void validateSelectedItems() {
        for (Line_Item_Schedule__c item : selectedLineItems) {
            if (item.Invoice_Date__c == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Invoice Date must contain a value.'));
            }
            if (item.Invoice_Amount__c == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Invoice Amount must contain a value.'));
            }
            if (item.Invoice_Comment__c == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Invoice Comment must contain a value.'));
            }
        }
        
        if (selectedLineItems.size() == 0) 
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'At least one line item must be selected.'));
    }
    
    /**
     * @description:  Create X new line item schedules and add them to our wrapper list
     **/
    public void addRows() {
        
        //validate the number of rows is between 1-100
        if (numRows == null || numRows < 1 || numRows > 100) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You can only add between 1 and 100 rows at once'));
            return;
        }
        
        for (Integer i = 0; i < numRows; i++) {
            Line_Item_Schedule__c item = new Line_Item_Schedule__c(Contract__c = (contractABC != null ? contractABC.Id : null),
                                                                   Program_Subscription__c = (programSubscription != null ? programSubscription.Id : null),
                                                                   Invoice_Billing_Schedule_del__c = (contractABC!= null ? contractABC.Invoice_Billing_Schedule__c : programSubscription.Invoice_Billing_Schedule__c),
                                                                   Type__c = 'Member Fee');
            lineItemWrappers.add(new LineItemScheduleCloneController.LineItemWrapper(item, contractABC != null ? contractABC.Id : null, false,programSubscription != null ? programSubscription.Id : null));
        }
    }
    
    /**
     * @description: Integer to hold the rows count to be added
    **/
    public integer numRows {
        get {
            if (numRows == null) numRows = 1;
            return numRows;
        }
        set;
    }
    
    /**
     * @description: Boolean variable to check if message was there on VF page or not
    **/
    public boolean hasErrors {
        get {
            return (apexPages.getMessages().size() > 0);
        }
        set;
    }
    
    /**
     * @description: Method to apply filters on Line Item Schedules
    **/
    public void applyFilters() {
        
        //Nullying the collection and wrapper list
        nullifyCollections();
        
        //When no filter was applied on the page
        if(String.isBlank(filterInstance.historicalLinker) && lItemSchedule.Invoice_Date__c == null) {
            invoiceBillingSchedule = null;
            populateStandardSetController();
        //User have applied the Filter(s) on the VF page
        } else {
            
            //Several filters related use cases
            if(String.isNotBlank(filterInstance.historicalLinker) && lItemSchedule.Invoice_Date__c != null) {
                filterInstance.historicalLinker = String.escapeSingleQuotes(filterInstance.historicalLinker.replaceAll('\\*','%').replaceAll('\\_', '').trim());
                populateStandardSetControllerWithFilters(filterInstance.historicalLinker, lItemSchedule.Invoice_Date__c);
            } else if(String.isNotBlank(filterInstance.historicalLinker)) {
                filterInstance.historicalLinker = String.escapeSingleQuotes(filterInstance.historicalLinker.replaceAll('\\*','%').replaceAll('\\_', '').trim());
                populateStandardSetControllerWithFilters(filterInstance.historicalLinker, null);
            } else if(lItemSchedule.Invoice_Date__c != null) {
                populateStandardSetControllerWithFilters('', lItemSchedule.Invoice_Date__c);
            } else {}
        }
    }
    
    /**
     * @description: Mass update line item values with the help of "UPDATE SELECTED:" section
    **/
    public void updateValuesOnLineItems() {
        
        //Loop through wrapper list
        for(LineItemScheduleCloneController.LineItemWrapper wrp : lineItemWrappers) {
            
            //Only update the line item if it was not invoiced earlier and selected on the page
            if(!wrp.LineItem.Invoiced__c && wrp.isSelected) {
            
                //Populating line item schedule instance fields with updated values
                if(String.isNotblank(lISchedule.Type__c))
                    wrp.LineItem.Type__c = lISchedule.Type__c;
                    
                //Checking and updating Line Item Comment 1
                if(String.isNotblank(lISchedule.Invoice_Comment__c))
                    wrp.LineItem.Invoice_Comment__c = lISchedule.Invoice_Comment__c;
                
                //Checking and updating Line Item Comment 1
                if(String.isNotblank(lISchedule.Line_Item_Comment__c)) {
                    if(lISchedule.Line_Item_Comment__c.toLowercase().trim() == 'blank')
                        wrp.LineItem.Line_Item_Comment__c = '';
                    else
                        wrp.LineItem.Line_Item_Comment__c = lISchedule.Line_Item_Comment__c;
                }
                
                //Checking and updating Line Item Comment 2
                if(String.isNotblank(lISchedule.Line_Item_Comment_2__c)) {
                    if(lISchedule.Line_Item_Comment_2__c.toLowerCase().trim() == 'blank')
                        wrp.LineItem.Line_Item_Comment_2__c = '';
                    else
                        wrp.LineItem.Line_Item_Comment_2__c = lISchedule.Line_Item_Comment_2__c;
                }
                
                //Checking and updating Invoice Date field value
                if(lISchedule.Invoice_Date__c != null)
                     wrp.LineItem.Invoice_Date__c = lISchedule.Invoice_Date__c;
            }
        }
    }
    
    /**
     * @description:  Method to fecth the program acronyms value corresponding to the historical linker value provided by the user on the VF page.
    **/
    public void fetchProgramAcronyms() {
        if(String.isNotBlank(hLinker)) {
            if(invoiceBillingSchedule != null) {
                Map<String, String> mapHistoricalLinkerWithPA = new Map<String, String>();
                for(Line_Item_Schedule__c item : lineItemSchedules) {
                    if(((item.Program_Subscription__c != null && String.isNotBlank(item.Program_Subscription__r.Historical_Linker__c)) || (item.Contract__c != null && String.isNotBlank(item.Contract__r.Historical_Linker__c)))) {
                        
                        //Check for Program Sub.
                        if(item.Program_Subscription__c != null && String.isNotBlank(item.Program_Subscription__r.Historical_Linker__c))
                            mapHistoricalLinkerWithPA.put(item.Program_Subscription__r.Historical_Linker__c.toLowerCase(), item.Program_Subscription__r.Program_Acronym__c);
                        else
                            mapHistoricalLinkerWithPA.put(item.Contract__r.Historical_Linker__c.toLowerCase(), item.Contract__r.Program_Acronym__c);   
                    }
                }
                
                if(mapHistoricalLinkerWithPA.get(hLinker.trim().toLowerCase()) != null)
                    filterInstance.programAcronyms = mapHistoricalLinkerWithPA.get(hLinker.trim().toLowerCase());
                else
                    filterInstance.programAcronyms = null;
            }
        } else {
            filterInstance.programAcronyms = null;
        }
    }
    
    /*Pagination related variables and method*/
    //Start from here
    // indicates whether there are more records after the current page set.
    public Boolean hasNext {
        get {
            return con.getHasNext();
        }
        set;
    }

    // indicates whether there are more records before the current page set.
    public Boolean hasPrevious {
        get {
            return con.getHasPrevious();
        }
        set;
    }

     // returns the page number of the current page set
    public Integer pageNumber {
        get {
            return con.getPageNumber();
        }
        set;
    }
    
    //Return the total page number
    public Integer totalPages {
        get {
            Decimal resultSize = con.getResultSize();
            Decimal pageSize = con.getPageSize();
            Decimal totalPageNo = resultSize/pageSize;
            return (Integer)totalPageNo.round(System.RoundingMode.CEILING);
        }
        set;
    }
    
    //returns the next page of records
    public void next() {
        populatingMapWithUpdatedInformations();
        nullifyCollections();
        con.next();
        updatingWrapperWithMapValues();
    }
    
    // returns the previous page of records
    public void previous() {
        populatingMapWithUpdatedInformations();
        nullifyCollections();
        con.previous();
        updatingWrapperWithMapValues();
    }

    // returns the first page of records
    public void first() {
        populatingMapWithUpdatedInformations();
        nullifyCollections();
        con.first();
        updatingWrapperWithMapValues();
    }

    // returns the last page of records
    public void last() {
        populatingMapWithUpdatedInformations();
        nullifyCollections();
        con.last();
        updatingWrapperWithMapValues();
    }
    //Upto here
    
    /**
     * @description:  Method to populate a map. Will be useful to keep track of changes made by user on VF page.
    **/
    public void populatingMapWithUpdatedInformations() {
    
        //Loop through wrapper list and populating map with latest informations
        for (LineItemScheduleCloneController.LineItemWrapper wrap : lineItemWrappers) {
            if(wrap.isSelected && wrap.LineItem != null && wrap.LineItem.Id != null)
                mapLineItemSchedules.put(wrap.LineItem.Id, wrap.LineItem);
        }
    }
    
    /**
     * @description:  Method to set null as value for the collection. Will be useful in populting of these collections via corresponding getter setters.
    **/
    public void nullifyCollections() {
        
        //Nullifying collections.
        lineItemSchedules = null;
        lineItemWrappers = null;
    }
    
    /**
     * @description:  Method to update the wrapper list with user made changes
    **/
    public void updatingWrapperWithMapValues() {
        
        //Loop through wrapper list and updating wrapper list with the help of map values
        for (LineItemScheduleCloneController.LineItemWrapper wrp : lineItemWrappers) {
            if(wrp.isSelected && wrp.LineItem != null && wrp.LineItem.Id != null 
                && mapLineItemSchedules.containsKey(wrp.LineItem.Id) && mapLineItemSchedules.get(wrp.LineItem.Id) != null)
                wrp.LineItem = mapLineItemSchedules.get(wrp.LineItem.Id);
        }
    }
    
    /**
     * @description:  Method to convert a List<String> into a quoted, 
     *                comma separated String literal for inclusion in a dynamic SOQL Query
    **/
    private String quotedString(List<String> listOfStrings) {
        String newStr = '' ;
        
        //Loop through List of String
        for(String myStr : listOfStrings) {
            String str = String.valueOf(myStr);
            newStr += '\'' + str + '\',';
        }
        newStr = newStr.lastIndexOf(',') > 0 ? '(' + newStr.substring(0,newStr.lastIndexOf(',')) + ')' : newStr ;
        return newStr;
    }
    
    //Wrapper class    
    public class FilterWrapper {
        public string historicalLinker {get; set;}
        public String programAcronyms {get; set;}
        public FilterWrapper() {}
    }
}