/*
Copyright (c) 2013 Up2Go International LLC
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:

1. Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.
3. The name of the author may not be used to endorse or promote products 
   derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE AUTHOR "AS IS" AND ANY EXPRESS OR
IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, 
INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

/**
*   Desription      :   Functions as a facade to the database. 
                        For a given SOQLQuery the RowManager queries the database and returns paginated results.
                        Each instance delegate the querying and paging to a StandardSetController 
                        and only maintains the state of pages, page sizes.
                        Changes to this state are also updated in Settings object which is passed into the contructor by the parent controller.
                        The RowManager also keeps track of row selections by wrapping records in SObjectRows. 
*
*   Created By      :   Robert Soesemann (robert.soesemann@up2go.com)
* 
*   Created Date    :   04/30/2016
* 
*   Revision Logs   :   V1.0 - Created
                        V1.1 - Modified By - Mahendra Swarnkar - 04/30/2016 - CR-20160323-9712
*
**/
public with sharing class RowManager {
        
    // CONSTANTS 
    private final static String LIMIT_CLAUSE = ' LIMIT 10000 ';
    
    // PRIVATE MEMBERS
    public SoqlQuery soqlQuery { get; set; }
    private ApexPages.StandardSetController setController;
    public Map<Id, Boolean> selectionMap { get; private set; }
    public Map<Id, Boolean> selectionIsChangedMap { get; private set; }
    public TableGridState__c settings { get; private set; }
    
    public List<SObjectRow> newAddedRows{get;set;}
    
    // PROPERTIES 
    public List<SObjectRow> rows {  
        get {
            // Save old checkbox state
            for(SObjectRow row : this.rows) {
                
                //If Id is not null then fill this map
                // .. to internal map
                if(row.delegate.Id != null){
                    this.selectionMap.put(row.delegate.Id, row.isSelected);
                    this.selectionIsChangedMap.put(row.delegate.Id, row.isChanged);
                }
            }
            this.rows = new List<SObjectRow>();
            
            // Show records from db
            for(SObject so : this.setController.getRecords()) {
                Boolean isSelected = (selectionMap.get(so.Id) == null) ? false : selectionMap.get(so.Id);
                Boolean isChanged = (selectionIsChangedMap.get(so.Id) == null) ? false : selectionIsChangedMap.get(so.Id);
                SObjectRow sobj = new SObjectRow(so, isSelected);
                sobj.isChanged = isChanged;
                this.rows.add(sobj);
            }
            System.debug('@@@@@ aa ' + newAddedRows);
            //check for size and return the row list with newly added rows
            if(newAddedRows != null && newAddedRows.size() > 0 )
                return newAddedRows;
            return this.rows;
        }
        public set; 
    }
    
    //Page Number
    public Integer pageNumber {
        get {
            return this.setController.getPageNumber();
        }
        set {
            this.setController.setPageNumber(value);
            this.settings.num_PageNumber__c = value;
        }
    }
    
    //Page size
    private Integer cachedPageSize;
    public Integer pageSize {
        get {
            return this.cachedPageSize;
        }
        set {
            this.cachedPageSize = value;
            if(this.setController != null) {
                this.setController.setPageSize(this.cachedPageSize);
                this.settings.num_PageSize__c = this.cachedPageSize;
            }
        }
    }
    
    //Counting no of pages
    public Integer pageCount { 
        get{ 
            Integer result = Math.round(this.setController.getResultSize() / this.pageSize); 
            Integer remainder = Math.mod(this.setController.getResultSize(), this.pageSize); 
            result = (remainder > 0) ? result + 1 : result;
            result = (result == 0) ? 1 : result;
            return result;
        } 
    }
    
    //Counting no of records
    public Integer recordCount {
        get{ 
            return this.setController.getResultSize(); 
        } 
    }
    
    public Boolean hasNextPage {
        get{ 
            return this.setController.getHasNext();
        }
    }
    
    public Boolean hasPreviousPage {
        get{
            return this.setController.getHasPrevious();
        }
    }
    
    public List<Integer> previousSkipPageNumbers {
        get{
            //(this.setController.getPageNumber() == this.pageCount ? 4 : 3)
            List<Integer> returnValues = new List<Integer>(); 
            for(Integer i = this.pageCount; i > 0; i--){
                if(this.setController.getPageNumber()-i <= 0){
                    continue;
                }
                returnValues.add(this.setController.getPageNumber()-i);
            }
            return returnValues;
        }
    }
    
    public List<Integer> nextSkipPageNumbers {
        get{
            //(this.setController.getPageNumber() == 1 ? 4 : 3)
            List<Integer> returnValues = new List<Integer>();
            for(Integer i = 1; i <= this.pageCount; i++){
                if(this.setController.getPageNumber()+i > this.pageCount){
                    break;
                }
                returnValues.add(this.setController.getPageNumber()+i);
            }
            return returnValues;
        }
    }
    
    // CONSTRCUTOR
    public RowManager(SoqlQuery soqlQuery, TableGridState__c settings) {
    
        // Init members
        this.soqlQuery = soqlQuery;
        this.settings = settings;
        this.pageSize = (this.settings.num_PageSize__c == null) ? 10 : Math.round(this.settings.num_PageSize__c);
        this.selectionMap = new Map<Id, Boolean>();
        this.selectionIsChangedMap = new Map<Id, Boolean>();
        this.rows = new List<SObjectRow>(); 
        
        // Create StandardSetController from query
        fetchRows(this.soqlQuery);
        
        // Set page
        this.pageNumber = (this.settings.num_PageNumber__c == null) ? 1 : Math.round(this.settings.num_PageNumber__c);
    }
    
    //Fetch records from DB and initialize the controller 
    public void fetchRows(SoqlQuery soqlQuery) { 
        this.soqlQuery = soqlQuery;
        
        String soqlAsString = this.soqlQuery.asString() + LIMIT_CLAUSE;
        this.setController = new ApexPages.StandardSetController(Database.getQueryLocator(soqlAsString));
        this.setController.setPageSize(this.pageSize);       
    }
    
    // METHODS  
    
    //Added By - Mahendra Swarnkar - 04/30/2016 - CR-9712
    /**
     *  @description    :   Method responsible to update the row wrapper with new instance.  
     *
     *  @args           :
     *
     *  @return         :   void
     *
    **/ 
    public void fillSetController(List<SObjectRow> soBjectList) {
        newAddedRows = new List<SObjectRow>();
        newAddedRows.addAll(soBjectList);
        System.debug('####### newAddedRows ' + newAddedRows );
    }  

    public void skipToPage(){
        this.setController.setPageNumber(this.pageNumber);
    }
    
    public void loadNextPage(){
        this.setController.next();
    }
    
    public void loadPreviousPage(){
        this.setController.previous();
    }
    
    public void loadFirstPage(){
        this.setController.first();
    }
    
    public void loadLastPage(){
        this.setController.last();
    }
}