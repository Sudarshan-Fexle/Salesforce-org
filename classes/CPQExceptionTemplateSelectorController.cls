/**
 * @description: get the cpq contract exception and update he template/order fields
 * 
 * @revision log: V_1.0 - 05/23/2019 - Created - Victor Hanson - CR-20181019-12685
 		: V_1.1 - Modified - Subhash Garhwal - 9/25/2020 - CR-20200922-14545 
**/
public class CPQExceptionTemplateSelectorController {
	
    public String searchString { get; set; }
    public String recordId { get; set; }				//checked template record id
    public String highlightedTemplateId { get; set; } 	//selected template record id (to see preview of template)
    public Id proposalId { get; set; }					//proposal id
    public SBQQ__Quote__c proposal { get; set; }
    
    //success or error message
    public Boolean displayError {get; set; }
    public Boolean displaySuccess {get; set; }
    public String pageMsg { get; set; }
    public Boolean redirectOnSave { get; set; }
    public String isRemoveItem { get; set; }
    //public List<CPQ_Contract_Exception__c> cpqExceptionsToDelete { get; set; }
    
    //constructor
    public CPQExceptionTemplateSelectorController() {
        // Modified - Subhash Garhwal - 9/25/2020 - CR-20200922-14545   
        if(!Schema.sObjectType.CPQ_Contract_Exception__c.isUpdateable() )
                throw new customException('You do not have permission to add/remove the CPQ Contract Exceptions');
        
        proposalId = ApexPages.currentPage().getParameters().get('id');
        getProposal();
    }
    
    /**
     * @description:	gets the proposal details
     * 
     * @revision log:	05/28/2019 - Created - Victor Hanson - CR-20181019-12685
     **/
    public void getProposal() {
        List<SBQQ__Quote__c> proposals = [SELECT Id, Name FROM SBQQ__Quote__c WHERE Id = :proposalId];
        if (proposals.size() > 0) {
            proposal = proposals[0];
        }
        else {
            throw new customException('No Proposal found with id ' + proposalId);
        }
    }
    
    /**
     * @description:	reset variables and search
     * 
     * @revision log:	05/23/2019 - Created - Victor Hanson - CR-20181019-12685
     **/
    public void init() {
        //cpqExceptionsToDelete = new public List<CPQ_Contract_Exception__c>();
        getCPQContractExceptions();
        search();
        
        //reset messages
        displayError = false;
        displaySuccess = false;
        pageMsg = null;
    }
    
    /**
     * @description:	gets the cpq contract exceptions for this proposal
     * 
     * @revision log:	05/23/2019 - Created - Victor Hanson - CR-20181019-12685
     **/
    public void getCPQContractExceptions() {
        
        //check to see if contract docs need generated
        //CPQExceptionTemplateHelper.generateContractDocs(proposalId);
        
        List<CPQ_Contract_Exception__c> cpqExceptions = [SELECT Id, Proposal__c, Order__c, Exception_Template__c, 
                                                       Exception_Template__r.Alternative_Language_Header__c, Exception_Template__r.Section_Name__c,
                                                       Exception_Template__r.Parent_Template__c
                                                       FROM CPQ_Contract_Exception__c WHERE Proposal__c = :proposalId AND Proposal__c != null];
        //add contract exceptions to list of selections
        setSelectedTemplates(cpqExceptions);
    }
    
    /**
     * @description:	get all selected templates
     * 
     * @revision log:	05/23/2019 - Created - Victor Hanson - CR-20181019-12685
     **/
    public void setSelectedTemplates(List<CPQ_Contract_Exception__c> cExceptions) {
        for (CPQ_Contract_Exception__c cException : cExceptions) {
            Exception_Template__c eTemplate = new Exception_Template__c(Id=cException.Exception_Template__c,
                                                                        Alternative_Language_Header__c = cException.Exception_Template__r.Alternative_Language_Header__c,
                                                                        Section_Name__c = cException.Exception_Template__r.Section_Name__c);
            SObjectRow sObjRow = new SObjectRow(cException, eTemplate, true, Integer.valueOf(cException.Order__c));
            selectedTemplates.put(cException.Exception_Template__c, sObjRow);
        }
    }
    
    /**
     * @description:	search exception templates
     * 
     * @revision log:	05/23/2019 - Created - Victor Hanson - CR-20181019-12685
     **/
    public void search() {
        lstWrapper =  new List<SObjectRow>();
        mapWrapper = new Map<Id, SObjectRow>();
        lstSetController = new List<SObjectRow>();
        
        List<Exception_Template__c> lstTemplates = database.query(queryString);
        
        for(Exception_Template__c eTemplate : lstTemplates )
        {
            mapWrapper.put(eTemplate.Id, new SObjectRow(eTemplate,selectedTemplates.containsKey(eTemplate.Id), mapWrapper.size()));
            //lstWrapper.add(new SObjectRow(eTemplate,false));
        }
        //add list of wrappers to our list
        lstWrapper = mapWrapper.values();
        obj = new CustomIterable(lstWrapper); 
        obj.setPageSize = 10;
        next();
    }
    
    /**
     * @description:	returns the dynamic query string
     * 
     * @revision log:	05/23/2019 - Created - Victor Hanson - CR-20181019-12685
     **/
    public String queryString {
        get {
            //Added check [Status__c = 'Active'] so that only active templates can pull
            queryString = 'SELECT Id, Current_Version__c, Section__c, Section_Name__c, Alternative_Language_Header__c, Alternative_Language__c '
                          +  ' FROM Exception_Template__c '
                          +  ' WHERE Current_Version__c = true AND Status__c = \'Active\' ';
            
            System.debug('queryString' +queryString);
            if (String.isNotBlank(searchString)) {
                queryString += ' AND (Alternative_Language_Header__c LIKE \'%' + searchString + '%\' ';
                queryString += ' OR Section_Name__c LIKE \'%' + searchString + '%\' OR Section__c LIKE \'%' + searchString + '%\')';
            	
                System.debug('queryString' +queryString);
            	//Code Block to add Filter for number fields
            	/*try {
            		
            		//Integer
            		Integer convertedValue = Integer.valueOf(searchString);
            		
            		if(convertedValue != null) {
            			
            			//Add Search filter
            			queryString = queryString.removeEnd(')') + ' OR Section__c =' + convertedValue + ')';
            		}
            		
            	} catch(Exception ex) {
            		System.debug('Error' +ex);
            	}*/
            }
            
            queryString += ' ORDER BY Alternative_Language_Header__c ASC LIMIT 1000';
            
            System.debug('queryString' +queryString);
            return queryString;
        }
        set;
    }
    
    //returns custom sorted list of Current Order Documents
    public List<SObjectRow> lstCurrentOrderDocs {
        get {
            lstCurrentOrderDocs = new List<SObjectRow>();
            for (SObjectRow row : selectedTemplates.values()) {
                lstCurrentOrderDocs.add(row);
            }
            lstCurrentOrderDocs.sort();
            return lstCurrentOrderDocs;
        }
        set;
    }
    
    /***** RECORD SELECTION METHODS ******/
    public Map<Id, SObjectRow> selectedTemplates {
        get {
            if (selectedTemplates == null) {
                selectedTemplates = new Map<Id, SObjectRow>();
            }
            return selectedTemplates;
        }
        set;
    }
    
    /**
     * @description:	toggles selection (check/un-check)
     * 
     * @revision log:	05/23/2019 - Created - Victor Hanson - CR-20181019-12685
     **/
    public void toggleSelection() {
        SObjectRow row = mapWrapper.get(recordId);
        
        /*system.debug('@@@IN toggleSelection row.isSelected:' + row.isSelected);
        system.debug('@@@IN toggleSelection containsKey:' + selectedTemplates.containsKey(recordId));*/
        if (row != null) {
            
            //when selected, add to default list of selected records
            if (row.isSelected) {
                if (!selectedTemplates.containsKey(recordId)) {
                    selectedTemplates.put(recordId, row);
                }
                else if (isRemoveItem == 'true') {
                    row.isSelected = false;
                    //when un-selected, remove from our list
                    if (selectedTemplates.containsKey(recordId)) {
                        selectedTemplates.get(recordId).isSelected = false;
                        //selectedTemplates.remove(recordId);
                    }
                    //unselect the value from the list
                    for (SObjectRow r : lstSetController) {
                        if (r.eTemplate.Id == row.eTemplate.Id) {
                            r.isSelected = false;
                        }
                    }
                }
                else {
                    selectedTemplates.get(recordId).isSelected = true;
                    
                    //unselect the value from the list
                    for (SObjectRow r : lstSetController) {
                        if (r.eTemplate.Id == row.eTemplate.Id) {
                            r.isSelected = true;
                        }
                    }
                }
            }
            else {
                row.isSelected = false;
                //when un-selected, remove from our list
                if (selectedTemplates.containsKey(recordId)) {
                    selectedTemplates.get(recordId).isSelected = false;
                    //selectedTemplates.remove(recordId);
                }
                //unselect the value from the list
                for (SObjectRow r : lstSetController) {
                    if (r.eTemplate.Id == row.eTemplate.Id) {
                        r.isSelected = false;
                    }
                }
            }
        }
    }
    
    
    /***** PAGINATION CONTROLS ******/
    public List<SObjectRow> lstWrapper {get;set;}
    public Map<Id, SObjectRow> mapWrapper {get;set;}
    public List<SObjectRow> lstSetController{get;set;}
    
    CustomIterable obj;
    
    
    public Boolean hasNext {
        get 
        {
            return obj.hasNext();
        }
        set;
    }
    
    public Boolean hasPrevious {
        get 
        {
            return obj.hasPrevious();
        }
        set;
    }
    
    public void next() 
    {
        lstSetController = obj.next();
    }
    
    public void previous() 
    {
        lstSetController = obj.previous();
    }
    
    public PageReference cancel() {
        return new PageReference('/' + proposalId);
    }
    
    public PageReference save() {
        
        
        
        PageReference pr = null;
        
        //upsert/delete lists
        List<CPQ_Contract_Exception__c> cExceptionsToUpsert = new List<CPQ_Contract_Exception__c>();
        List<CPQ_Contract_Exception__c> cExceptionsToDelete = new List<CPQ_Contract_Exception__c>();
        
        for (SObjectRow row : lstCurrentOrderDocs) {
            CPQ_Contract_Exception__c cException = row.getContractException();
            cException.Proposal__c = proposalId;
            
            //add
            if (row.isSelected) {
                cExceptionsToUpsert.add(cException);
            }
            //delete
            else if (!row.isSelected && cException.Id != null) {
                cExceptionsToDelete.add(cException);
                if (selectedTemplates.containsKey(cException.Exception_Template__c)) {
                    selectedTemplates.remove(cException.Exception_Template__c);
                }
            }
        }
        
        //set savepoint
        Savepoint sp = Database.setSavepoint();
        
        try {

                
            if (cExceptionsToUpsert.size() > 0) {
                
                upsert cExceptionsToUpsert;
            }    
                
            if (cExceptionsToDelete.size() > 0) {
                delete cExceptionsToDelete;
            }
            
            //reset
            getCPQContractExceptions();
            search();
        }
        catch(Exception e) {
            //rollback
            Database.rollback(sp);
            displayError = true;
            
            if(e.getMessage().containsIgnoreCase(System.label.CPQ_Contract_Exception_Validation_Message)){
                pageMsg = 'Error: '+ System.label.CPQ_Contract_Exception_Validation_Message;
            }
            else if(e.getMessage().containsIgnoreCase('You do not have permission to add/remove the CPQ Contract Exceptions')){
                pageMsg = 'Error: You do not have permission to add/remove the CPQ Contract Exceptions';
            }
            else {
            	pageMsg = 'Error: ' + e.getMessage() + '\r\n' + e.getStackTraceString();    
            }
            
            return null;
        }
        
        displaySuccess = true;
        pageMsg = 'Saved Successfully';
        
        //redirect to other page?
        if (redirectOnSave != null && redirectOnSave) {
            pr = null;
        }
        else {
            pr = new PageReference('/' + proposalId);
        }
        return pr;
    }
    
    
}