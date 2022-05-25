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
*/

/**
 *  DOCUMENTATION MISSING //TODO
 *  
 *  @author Robert Soesemann (robert.soesemann@up2go.com)
 */
/**
*	Desription      :	Controller class to hold the logic for all pre post operations performed via tableGrid VF component
* 
*	Created By      :   Mahendra Swarnakar
* 
*	Created Date    :   04/30/2016
* 
*	Revision Logs   :   V1.0 - Created
						V1.1 - Modified By - Mahendra Swarnkar - 04/30/2016 - CR-9712
*
**/
public with sharing class TableGridController {
 	
 	// COMPONENT ATTRIBUTES 
    public String hiddenFields { get; set; }
    public String typeParam { get; set; }
    public String relationshipFieldAPIName { get; set; }
    public String parentRecordName {get; set;}
    public String relationshipFieldSchemaId { get; set; }
    public String childObjectSchemaId { get; set; }
    public String fieldsParam { get; set; }
    public String filterParam { get; set; }
    public Boolean sortDescParam { get; set; }
    public Integer pageSizeParam  { get; set; } 
    public String modeParam { get; set; }
    public String sortByParam { get; set; }
    public String gridIdParam { get; set; }
    public String lookupFieldValue { get; set; }
    public String hiddenFieldsV { get; set; }
    public SObject defaultSObjectInstance {get; set;}
    
    public List<Id> selectedIds { get; set; }
    List<SObjectRow> newSobjectRowsrecords;
    
    public Boolean saveSettingsParam { 
        get {
             return (saveSettingsParam == null) ? false : saveSettingsParam;
        }
        set; 
    }
    
    // MEMBER VARIABLES
    public SoqlQuery soqlQuery { get; set; }
    public RowManager rowManager { get; set; }
    public Boolean isInitialized  { get; private set; }
    public String previousSortField {get; set;}
    public String objectLabel  { get; private set; }
    public String objectLabelPlural  { get; private set; }
    public String parentFrameUrl { get; set; }
    public String currentMode { get; set; }
    public String currentPageUrl { 
        get {
            PageReference currentPage = ApexPages.currentPage();
            currentPage.getParameters().remove('AJAXREQUEST');
            return currentPage.getUrl();
        }
        private set;
    }
    public Boolean noneSelected { get; private set; }
    public Boolean allSelected { get; set; }
    public Boolean isPageLoaded { get; private set; }
    private Boolean isSaveAll = false;
    
    private TableGridState__c settings;
    
    //variable to hold the required fields string
    public String reqFieldsStr {get; set;}
    
    // COMPONENT INIT JOEL DIETZ STYLE
    //Init/costructor method for this class
    public void getInit() { 
        
        //initialise the flags
        isPageLoaded = false;
        isSaveAll = false;
        
        //Variable assignment
        typeParam = TableGridUtils.normalize(typeParam);
        gridIdParam = TableGridUtils.normalize(gridIdParam);
        
        try { 
            // Try to load user's saved settings for this grid instance
            settings = getSettings();

            // Init from saved settings if it exists
            if(settings.Id != null) {
                String fieldNames = settings.txtl_FieldNames__c;
                soqlQuery = new SoqlQuery(typeParam, fieldNames);

                // Always use the components initial filter
                if(filterParam != null) {
                    soqlQuery.filter(filterParam);
                }
                // Recreate additional filter statements
                String filterStatements = settings.txtl_FilterStatements__c;
                
                //check for size
                if(filterStatements != null) {
                    for(String statement : filterStatements.split(';')) {
                        String[] fragments = statement.split(',');
                        
                        try {
                            FilterStatement newStatement = new FilterStatement(typeParam, fragments[0], fragments[1], fragments[2]) ;
                            soqlQuery.filterStatements.add( newStatement );
                        }
                        catch(Exception initException) {
                            //Just do not add Filter
                        }
                    }
                }
                // Order By
                if(settings.txt_SortBy__c != null) {
                    soqlQuery.orderBy(settings.txt_SortBy__c, settings.chk_SortDescending__c == null ? false : settings.chk_SortDescending__c);
                } 
                
                //Setting mode from settings
                currentMode = settings.txt_Mode__c;
            }
            // Otherwise init from component attributes
            else {
                fieldsParam = TableGridUtils.normalize(fieldsParam);
                
                //initializing soqlQuery instance
                soqlQuery = new SoqlQuery(typeParam, fieldsParam);
                if(filterParam != null) {
                    soqlQuery.filter(filterParam);
                }
                if(sortByParam != null) {
                    soqlQuery.orderBy(sortByParam, sortDescParam == null ? false : sortDescParam);
                } 
                currentMode = modeParam;
            }
            objectLabel = SchemaCache.objectDescribe(typeParam).getLabel();
            objectLabelPlural = SchemaCache.objectDescribe(typeParam).getLabelPlural();
            noneSelected = true; 
            
            // Add lookup filter as editable statement
            if(currentMode == 'singleselect' && lookupFieldValue != null) {
                FilterStatement newStatement = new FilterStatement(typeParam, 'Name', 'contains', lookupFieldValue) ;

                // If Statement does not already exists 
                Boolean alreadyExists = false;
                for(FilterStatement fs : soqlQuery.filterStatements) {
                    if(fs.hashcode.equals(newStatement.hashcode)) {
                        alreadyExists = true;
                        break;
                    }
                }
                // Add it to SOQLQuery
                if(!alreadyExists) {
                    soqlQuery.filterStatements.add( newStatement );
                }
            }
        } 
        catch(Exception ex) {
            showMessage(ApexPages.Severity.FATAL, 'TableGrid Initialization Error: ' + ex.getMessage() + ' (Please contact your administrator)');
            return;
        }

        // Create RowManager from query
        rowManager = new RowManager(soqlQuery, settings); 
     
        previousSortField = soqlQuery.sortFieldName;
           
        // Mark initialisation as successful
        isInitialized = true;
        allSelected = false;
    }
   
    // ACTIONS 
    /**
     *  @description    :	Method responsible to perform sorting.  
     *
     *  @args           :
     *
     *  @return         :   Pagereference
     *
    **/ 
    public void doSort() {
        
        //Check for te lookup field and standard/custom field type
        /*if(Schema.DisplayType.Reference == Schema.getGlobalDescribe().get(typeParam).getDescribe().Fields.getMap().get(soqlQuery.sortFieldName).getDescribe().getType()
           && Schema.getGlobalDescribe().get(typeParam).getDescribe().Fields.getMap().get(soqlQuery.sortFieldName).getDescribe().isCustom()){
               
               soqlQuery.sortFieldName = soqlQuery.sortFieldName.replaceFirst('__c', '__r.Name');
           }else {
               if(Schema.DisplayType.Reference == Schema.getGlobalDescribe().get(typeParam).getDescribe().Fields.getMap().get(soqlQuery.sortFieldName).getDescribe().getType()
                  && !(Schema.getGlobalDescribe().get(typeParam).getDescribe().Fields.getMap().get(soqlQuery.sortFieldName).getDescribe().isCustom())){
                      
                      soqlQuery.sortFieldName = soqlQuery.sortFieldName + '.Name';            
                  }   
           }
        */
        // Flip sort direction if sort field is unchanged
        if(soqlQuery.sortFieldName == previousSortField) {
            soqlQuery.sortDescending = !soqlQuery.sortDescending;
        }
        else {
            soqlQuery.sortDescending = false;
        }
        
        // Refetch rows
        rowManager.fetchRows(soqlQuery);
        
        //Populate the previousSortField
        previousSortField = soqlQuery.sortFieldName;
        
        // Save settings
        saveSettings();
    }
     
    /**
     *  @description    :	Method responsible to navigate to child(related list object) record detail page to create new child record.  
     *
     *  @args           :
     *
     *  @return         :   Pagereference
     *
    **/ 
    public Pagereference doEditNew() { 
        
        //Check for null/blank and get the parent objectId from the URL    
        if(String.isBlank(parentFrameUrl))
            parentFrameUrl = ApexPages.currentPage().getParameters().get('Id');
            
        //Page reference to redirect to the related child object
        PageReference page;
        if(String.isNotBlank(typeParam) && String.isNotBlank(parentFrameUrl)){
            
            //Check for blank
			if(String.isNotBlank(relationshipFieldAPIName)) {
                
                //String to hold the URL tobe redirect
                String pageUrl = '/apex/RedirectWithVariables?redirect=Object--' + typeParam.trim() + '!!' +
                                                   		relationshipFieldAPIName.trim() + '--' + parentFrameUrl ; 
                
                //Set default values
                Map<String, Schema.SObjectField> fieldsMap = SchemaCache.fieldsMap(typeParam);
                System.debug('fieldsMap:::::'+ fieldsMap);
                for(String fName : fieldsMap.keySet()) {
                	
                	if(defaultSObjectInstance.get(fName) != null)
                		pageUrl += '!!' + fName + '--' + String.valueOf(defaultSObjectInstance.get(fName));
                }
                System.debug('pageUrl:::::'+ pageUrl);
                
                //Set the record Type Id and return URL
                if(defaultSObjectInstance != null  
                  	&& fieldsMap.keySet().contains('recordtypeid')
                   	&& defaultSObjectInstance.get('recordtypeid') != null) {
                    pageUrl = pageUrl + '!!RecordTypeId--' +defaultSObjectInstance.get('recordtypeid') + 
                    '!!afterSaveURL--/' + parentFrameUrl + '!!returnURL--/'+parentFrameUrl;
                } else {
                	
                	//Check if the object has Recordtype defined. If yes, then redirect user to the record type selection page
                	List<RecordType> recordTypes = [Select Id from RecordType where SObjectType =: typeParam AND IsActive = true limit 1];
                	if(recordTypes.size() > 0) {
                		
                		pageUrl = '/setup/ui/recordtypeselect.jsp?ent=' + childObjectSchemaId + '&retURL=%2Fapex%2FAccount_US_Provider_Strategic%3Fid%3D'+ parentFrameUrl 
                						+ '&save_new_url=%2Fa7U' +  
                						+ '%2Fe%3FCF' + relationshipFieldSchemaId + '%3D' + parentRecordName
                						+ '%26CF' + relationshipFieldSchemaId + '_lkid%3D' + parentFrameUrl
                						+ '%26scontrolCaching%3D1%26retURL%3D' + parentFrameUrl;
                	} else {
						
						pageUrl = pageUrl + '!!afterSaveURL--/' + parentFrameUrl + '!!returnURL--/'+parentFrameUrl;
                	}
                }
                
                //Instantiate the Page reference
                page = new PageReference(pageUrl);
            }
            else {
                
                //Get objects key prefix of child object
        		String typePrefix = SchemaCache.objectDescribe(typeParam).getKeyPrefix();
                
                //Instantiating the page reference to redirect the related child object
                page = new PageReference('/' + typePrefix + '/e');
                page.getParameters().put('retURL', parentFrameUrl);
                page.getParameters().put('cancelURL', parentFrameUrl);
                page.getParameters().put('saveURL', parentFrameUrl);
            }    
        }
        return page;
    }
    
    /**
     *  @description    :	Method responsible to Save the selected record.  
     *
     *  @args           :
     *
     *  @return         :   void
     *
    **/
    public void doSaveSelected() { 

        try { 
    
            //Lists to hold records to be updated or inserted 
            List<SObject> toUpdate = new List<SObject>(); 
            List<SObject> toInsert = new List<SObject>(); 
    
            //Set of Required fields Strings 
            Set<String> setReqFields = processRequiredFieldsStringVal(); 
    
            //Error message 
            String errorMsgStr = System.Label.Error_Required_Fields; 
            String errorMsgCompleteStr = ''; 
            Set<Integer> erredRowsNumbers = new Set<Integer>(); 
    
            //Row No. 
            Integer rowNo = 1; 
    
            //Checking map of schema for null value 
            if(setReqFields != null && setReqFields.size() > 0) { 
    
                //loop through sObjectRows 
                for(SObjectRow ro : rowManager.rows) { 
    
                    //temp. boolean variable 
                    Boolean isReqFieldErrorExists = false; 
    
                    //Loop over set of required fields strings 
                    for(String reqStr : setReqFields) { 
    
                        //Cheking for required field value 
                        if(ro.delegate != null) { 
    
                            //Checking if required field is having null/blank value with it 
                            if(ro.delegate.get(reqStr) == null && !isReqFieldErrorExists) { 
                                isReqFieldErrorExists = true; 
                                errorMsgCompleteStr += ('<b>Row #</b> ' + rowNo + ' ' + errorMsgStr + '<br/>'); 
                                erredRowsNumbers.add(rowNo-1); 
                            } 
                        } 
                    } 
    
                    //Increasing the row no. 
                    rowNo++; 
                } 
            } 
    
            //Re-initialize 
            rowNo = 0; 
    
            //loop through sObjectRows 
            for(SObjectRow row: rowManager.rows) { 
    
                //Skip a row if it will fail due to required field(s) error 
                if(!erredRowsNumbers.contains(rowNo)) { 
    
                    //check if applicable for save all records 
                    if(!isSaveAll) { 
    
                        //Check for selected records 
                        //populate list for insert and update 
                        if(row.isSelected && row.delegate != null) { 
                            if(row.delegate.Id != null) 
                                toUpdate.add(row.delegate); 
                            else 
                                toInsert.add(row.delegate); 
                        } 
    
                    } else { 
    
                        //Save All the records in the related list 
                        //populate list for insert and update 
                        if(row.isChanged && row.delegate != null) { 
                            if(row.delegate.Id != null) 
                                toUpdate.add(row.delegate); 
                            else 
                                toInsert.add(row.delegate); 
                        } 
                    } 
                } 
    
                //increasing the row no 
                rowNo++; 
            } 
    
            // Check for size 
            if(!toUpdate.isEmpty()) { 
    
                //Update 
                update toUpdate; 
                showMessage(ApexPages.Severity.INFO, 'Successfully updated changed records'); 
    
                if(String.isBlank(errorMsgCompleteStr)) 
                    doRefresh(); 
            } 
    
            // Check for size 
            if(!toInsert.isEmpty()) { 
    
                //Insert 
                insert toInsert; 
                showMessage(ApexPages.Severity.INFO, 'Records inserted successfully'); 
    
                //Refresh the related list content 
                if(String.isBlank(errorMsgCompleteStr)) 
                    doRefresh(); 
            } 
    
            //Setting isChanged property to false for successfully updated ones 
            for(SObjectRow r: rowManager.rows) 
                r.isChanged = false; 
    
            //Throw exception for the required fields based error 
            if(String.isNotBlank(errorMsgCompleteStr)) 
                throw new customException(errorMsgCompleteStr); 
        
        } catch(Exception ex) {
            currentMode = 'edit'; 
            showMessage(ApexPages.Severity.ERROR, ex.getMessage()); 
        } 
    }
    
    /**
     *  @description    :	Method responsible to delete the selected records in the related list from thr DB.  
     *
     *  @args           :
     *
     *  @return         :   void
     *
    **/
    public void doDeleteSelected() {
        
        List<SObjectRow> listNewObjrowsRetains = new List<SObjectRow>();
        
        try {
            List<SObject> toDelete = new List<SObject>();
            
            for(SObjectRow row: rowManager.rows) {
                if(row.isSelected && row.delegate.Id != null) {
                    toDelete.add(row.delegate);
                }
                else {
                    if(row.isSelected == false && row.delegate.Id == null){
                        listNewObjrowsRetains.add(row);
                    }
                }
            }
            
            if(toDelete.size() > 0) {
                delete toDelete;
                showMessage(ApexPages.Severity.INFO, 'Records deleted successfully');
            }
        } 
        catch(Exception ex){
            showMessage(ApexPages.Severity.ERROR, ex.getMessage());
        }
        
        //Refresh the related list content
        doRefresh();
        
        //check for size
        if(listNewObjrowsRetains.size() > 0){
        	
            //populate the list with new instance
            if(rowManager != null && rowManager.rows != null && rowManager.rows.size() > 0) {
                for(SObjectRow sR : rowManager.rows)
                    listNewObjrowsRetains.add(sR);
            }
            
            //Calling method to update the wrapper with new instance
            rowManager.fillSetController(listNewObjrowsRetains);
            
            currentMode ='edit';
        }
    }   
    
    /**
     *  @description    :	Method responsible to Refresh the related list content.  
     *
     *  @args           :
     *
     *  @return         :   void
     *
    **/
    public void doRefresh() {
        
        //Reinitialize the list that contains the newly added rows.
        rowManager.newAddedRows = new List<SObjectRow>();
        
        // Update field names and refetchs rows
        soqlQuery.updateFieldNames();
        rowManager.fetchRows(soqlQuery);
        
        //Reset to mode
        if(currentMode=='edit')
            currentMode = 'list';
        
        //Deselect all selected rows
        doSelectedRefresh(true);
    }
	
    /**
     *  @description    :	Method responsible to load defaults.  
     *
     *  @args           :
     *
     *  @return         :   void
     *
    **/
    public void doLoadDefaults() {
        if(settings.Id != null) {
            delete settings;
        }
        getInit();
    }  
	
    /**
     *  @description    :	Method responsible to Flip the mode from edit to list or list to edit.  
     *
     *  @args           :
     *
     *  @return         :   void
     *
    **/
    public void doChangeMode() {
        // Mode set already by apex:param that called this action
        if(currentMode=='edit')
            currentMode = 'list';
        else if(currentMode=='list')
                currentMode = 'edit';
        
        //Save the sattings
        saveSettings();
    } 
    
    /**
     *  @description    :	Method responsible for Selection handling.  
     *
     *  @args           :
     *
     *  @return         :   void
     *
    **/
    public void doHandleSelection() {
        isSaveAll = false;
        noneSelected = true;
        
        //Reset the rows selection
        if(selectedIds!=null)
            selectedIds.clear();
        else
            selectedIds = new List<Id>();
        
        for(SObjectRow row : rowManager.rows) {
            if(row.isSelected ) {
                noneSelected = false;

                if(currentMode=='select' && row.delegate.Id != null) {
                    selectedIds.add(row.delegate.Id);
                }
            }
        }
    }
    
    /**
     *  @description    :	Method responsible to Save settings override into users custom settings.  
     *
     *  @args           :
     *
     *  @return         :   void
     *
    **/
    private void saveSettings() {
        if(saveSettingsParam == true) {
            // SELECT
            settings.txtl_FieldNames__c = soqlQuery.fieldNames;
            
            // WHERE
            String serializedStatements = '';
            Iterator<FilterStatement> iter = soqlQuery.filterStatements.iterator();
            while(iter.hasNext()) {
                serializedStatements += iter.next().asStringSetting();
                serializedStatements += iter.hasNext() ? ';' : '';
            }
            settings.txtl_FilterStatements__c = serializedStatements;
            
            // ORDER BY
            settings.txt_SortBy__c = previousSortField;
            settings.chk_SortDescending__c = soqlQuery.sortDescending;
            
            // PAGINATION
            settings.num_PageSize__c = rowManager.pageSize;
            settings.num_PageNumber__c = rowManager.pageNumber; 
            
            // MODE
            settings.txt_Mode__c = currentMode; 
            
            upsert settings;
        }
    }
    
    /**
     *  @description    :	Returns existing (in the db) or new Settings object for this tablegrid.  
     *
     *  @args           :
     *
     *  @return         :   TableGridState__c
     *
    **/
    private TableGridState__c getSettings() {
        TableGridState__c settings;
        String currentPage;
        String uniqueGridId;
                            
        // Set instance and page id dependant on calling context                                                       
        if(Test.isRunningTest()) {
            currentPage = 'calledWithoutPage';  
            uniqueGridId = 'uniqueGridId';                                      
        }
        else {
            String wholeUrl = ApexPages.currentPage().getUrl();
            Integer firstPos = wholeUrl.lastIndexOf('/');
            Integer lastPos = wholeUrl.indexOf('?', firstPos);
            if(lastPos == -1) {
                lastPos = wholeUrl.length();
            }
            currentPage = wholeUrl.substring(firstPos, lastPos);
            uniqueGridId = gridIdParam;
        }
        
        settings = new TableGridState__c(lkp_User__c = UserInfo.getUserId(),
                                         txt_PageUrl__c = currentPage,
                                         txt_GridId__c = gridIdParam,
                                         num_PageSize__c = pageSizeParam); 
        
        if(saveSettingsParam == true) {
            // Check if settings are saved in the database
            List<TableGridState__c> fromDatabase = [SELECT txtl_FieldNames__c, txtl_FilterStatements__c, txt_SortBy__c, chk_SortDescending__c, num_PageSize__c, num_PageNumber__c, txt_Mode__c
                                                    FROM TableGridState__c
                                                    WHERE txt_GridId__c = :uniqueGridId
                                                    AND txt_PageUrl__c = :currentPage
                                                    AND lkp_User__c = :UserInfo.getUserId()
                                                    LIMIT 1];
            
            if(fromDatabase != null && !fromDatabase.isEmpty()) {
                 settings = fromDatabase[0]; 
            }
        }

        return settings;
     }
    
	/**
     *  @description    :	Method responsible to show messsages on the page.  
     *
     *  @args           :
     *
     *  @return         :   void
     *
    **/
    private void showMessage(ApexPages.Severity severity, String messageText) {
        ApexPages.Message message = new ApexPages.Message(severity, messageText);
        ApexPages.addMessage(message);
    }
    
    /**
     *  @description    :	Method responsible to populate wrapper list with values.  
     *
     *  @args           :
     *
     *  @return         :   void
     *
    **/
    public void doEditNewInlineEntryRecord() {
        
        //Method call to add new row 
        newSObjectRows();
        
		//Change to edit mode
        if(currentMode == 'list')
            currentMode = 'edit';
        
        //check for size
        //populate the list with new instance
        if(rowManager != null && rowManager.rows != null && rowManager.rows.size() > 0) {
            for(SObjectRow sR : rowManager.rows)
                newSobjectRowsrecords.add(sR);
        }
        System.debug('####### newSobjectRowsrecords ' + newSobjectRowsrecords );
        //Calling method to update the wrapper with new instance
        rowManager.fillSetController(newSobjectRowsrecords);
    }
    
    /**
     *  @description    :	Method responsible to add a new instance in the wrapper list.  
     *
     *  @args           :
     *
     *  @return         :   void
     *
    **/
    public void newSObjectRows() {
        
        //Reinitialize the wrapper list 
        newSobjectRowsRecords = new List<SObjectRow>();
        
        //Checking for the null value and updating sobject instance
        if(String.isNotBlank(typeParam)) {
    		//Add a new instance into the wrapper
            //If in future a requirement will come to add no of rows at a same time then will place 1 with a variable
            for(Integer i = 0; i < 1 ; i++) {
                //sObject tempsObject = Schema.getGlobalDescribe().get(typeParam).newSObject();
                newSobjectRowsRecords.add(new SObjectRow(defaultSObjectInstance, false));
            }        
        }
    }
    
    /**
     *  @description    :	Method responsible to save all the records in he related list.  
     *
     *  @args           :
     *
     *  @return         :   void
     *
    **/ 
    public void doSaveAll() {
        isSaveAll = true;
        currentMode = 'list';
        doSaveSelected();
        isSaveAll = false;
    }
    
    /**
     *  @description    :	Method responsible to deselecte the selected rows.  
     *
     *  @args           :	Boolean
     *
     *  @return         :   void
     *
    **/ 
    public void doSelectedRefresh(Boolean isRefreshSelected) {
        
        //Reset the flag
        if(isSaveAll)
			isSaveAll = false;
        
        if(isRefreshSelected == true){
         	
            noneSelected = true;
            
            //Reset the rows selection
            if(selectedIds!=null)
                selectedIds.clear();
            
            for(SObjectRow row : rowManager.rows) {
                if(row.isSelected)
                    row.isSelected = false;
            }
        }    
    }
    
    public Set<String> processRequiredFieldsStringVal() { 

        //Set to hold the required fields 
        Set<String> setReqFieldsStr = new Set<String>(); 
        
        //Checking string for null/blank value 
        if(String.isNotBlank(reqFieldsStr)) { 
        
            //processing required fields string 
            reqFieldsStr = TableGridUtils.normalize(reqFieldsStr); 
            
            //Checking list for its size and null value 
            if(reqFieldsStr.split(',') != null && reqFieldsStr.split(',').size() > 0) { 
        
                //Looping through list values 
                for(String str : reqFieldsStr.split(',')) 
                	setReqFieldsStr.add(str.trim()); 
            } 
        } 
    
        //return set 
        return setReqFieldsStr; 
    }
}