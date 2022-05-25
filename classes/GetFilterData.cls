/**
 * Purpose		:	This Class is used to Get Record Data as Per Required Filter Values
 *
 * Created by	:	Dipesh Gupta
 * 	
 * Created Date :	27-Sep-2019
 * 
 * Version		:	V1.0 Created
 * 				 	V1.1 - Modified By - Mahendra Swarnkar - 02/04/2020 - CR-20200128-13664 - Added "without sharing" access modifier
 * 
 **/
public without sharing class GetFilterData  
{
    
    public List<Id> listOfRelatedOrgComparisonId {get;set;}
    
    public String crId {get;set;}
    
    public String lastOrgComparisionSyncDate {get;set;}
    
    public GetFilterData() {	
        
        crId = apexpages.currentpage().getparameters().get('id');
        System.debug('crId = '+ crId);    
        
        //Varible to hold the SB QA/UAT
        string whereActuallyChangeHappening = '';
        String releaseId = '';
        listOfRelatedOrgComparisonId = new List<Id>();
        //lastOrgComparisionSyncDate = '';
        
       	// getting  Release Id.
        SFDC_Change_Request__c cr = [Select Id, Release__c,Release__r.Last_Org_Comparision_Sync__c From SFDC_Change_Request__c where Release__c != null AND Id =: crId ];
        
        if(cr != null){
            //Fill the Release Id.                                 
            releaseId =  cr.Release__c;
            
            //Fill the Last OrgComparision Sync Date
            lastOrgComparisionSyncDate = cr.Release__r.Last_Org_Comparision_Sync__c.format('MM/dd/yyyy HH:mm a');
        }	 
        //Check for the Release Ids.
        if(String.isNotBlank(releaseId)) {
        	
            //Identifying the Release's related org comparison. 
            for(SFDC_Release__c release : [Select Id,
                                      (Select Id, Comparison_Org__c  From Org_Comparisons__r) 
                                      From SFDC_Release__c Where Id =: releaseId 
                                      AND Ready_for_Org_Comparison__c = true ]) {
            	
                //Check if the relase have org comparison records.
                if(release.Org_Comparisons__r != null && release.Org_Comparisons__r.size() > 0) {
                	
                    //For loop on the list. 
                    for(Org_Comparision__c oc : release.Org_Comparisons__r) {
                        //mapEnvTypeIdWithOCId.put(oc.Comparison_Org__c, );
                        listOfRelatedOrgComparisonId.add(oc.Id);
                        
                    }
                }
            }
        }
        /*
        System.debug('listOfRelatedOrgComparisonId = '+ listOfRelatedOrgComparisonId.size());
        System.debug('listOfRelatedOrgComparisonId = '+ listOfRelatedOrgComparisonId);
        */
    }
    /*@AuraEnabled(cacheable=true)
    public static List<Wrapper> getDataFromComponentsChangeDetails(Date oStartDate, Date oEndDate, List<String> typeFormat, String lastModifiedBy, List<String> listOfRecordIdValue, String cRId, String environmentType) {        
    	
        return null;
    }*/
    @AuraEnabled(cacheable=true)
    public static List<Wrapper> getDataFromComponentsChangeDetails1(Date oStartDate, Date oEndDate, List<String> typeFormat, List<String> lastModifiedBy, List<String> listOfRecordIdValue, String cRId, String environmentType, String typeOfMod) {        
        
        
        /*
        System.debug('oStartDate = '+ oStartDate);
        System.debug('oEndDate = '+ oEndDate);
        System.debug('typeFormat = '+ typeFormat);
        System.debug('lastModifiedBy = '+ lastModifiedBy);
        System.debug('listOfRecordIdValue size() = '+ listOfRecordIdValue.size());
        System.debug('listOfRecordIdValue = '+ listOfRecordIdValue);
        System.debug('cRId = '+ cRId);
        System.debug('environmentType = '+ environmentType);
        System.debug('typeOfMod = '+ typeOfMod);
		*/
        List<Id> listOrgCompId = new List<Id>();
        Set<Id> setOrgCompIds = new Set<Id>();
        
       if(listOfRecordIdValue != null && listOfRecordIdValue.size() > 0){
            // remove space and bracket
           listOfRecordIdValue[0] = listOfRecordIdValue[0].replaceAll( '\\s+', '').removeStart('[').removeEnd(']').removeStart('{').removeEnd('}');
            
            // convert string to list
            listOrgCompId = listOfRecordIdValue[0].split(',');
          	
            // adding values in set
            setOrgCompIds.addAll(listOrgCompId);
        }
        System.debug('setOrgCompIds = '+ setOrgCompIds);
        
        //String tempOcId = recordIdValue;
        String startDateFormat;
        String endDateFormat;
        String query;
        List<Wrapper> wrapList = new List<Wrapper>();
        List<Component_Changes_Detail__c> componentsChangeDetails = new List<Component_Changes_Detail__c>();
        /*
        List<String> listOflastModifiedBy = new List<String>();
        List<LookupSearchResult> deslastModifiedBy = (List<LookupSearchResult>)System.JSON.deserialize(lastModifiedBy, List<LookupSearchResult>.class);
        System.debug('deslastModifiedBy = '+ deslastModifiedBy);
        if(deslastModifiedBy.size()>0)
        {
            for(Integer i=0; i< deslastModifiedBy.size(); i++)
            {
        	    listOflastModifiedBy.add(deslastModifiedBy[i].getTitle());	    
            }
        }
       */
        
        //

        if(oStartDate != null)
        {
            Datetime startDateTime = Datetime.newInstance(oStartDate.year(), oStartDate.month(), oStartDate.day());
            startDateFormat  = startDateTime.format('yyyy-MM-dd');
        }

       if(oEndDate != null)
        {
            Datetime endDateTime = Datetime.newInstance(oEndDate.year(), oEndDate.month(), oEndDate.day());
        	endDateFormat  = endDateTime.format('yyyy-MM-dd');
        }

        /*if(listOflastModifiedBy.size() > 0) {
            setOfLastModifiedByName = new set<String>();
            for(String str: listOflastModifiedBy)
            {
            	setOfLastModifiedByName.add(str);
            }
            System.debug('setOfLastModifiedByName = '+ setOfLastModifiedByName);
        }
		*/
        
        // List to hold final data of selected user name as required for dynamic Query
        set<String> setOfLastModifiedByName = new set<String>();
        if(lastModifiedBy != null && lastModifiedBy.size() > 0) {
            for(String str : lastModifiedBy){
                
                String temp = str.trim().removeStart('[').removeEnd(']').removeStart('{').removeEnd('}').remove('\"'); 
                if(String.isNotBlank(temp))
                	setOfLastModifiedByName.add(temp);
            }
        }
        System.debug('setOfLastModifiedByName = '+ setOfLastModifiedByName);
       
        
        if(setOrgCompIds != null && setOrgCompIds.size() > 0 )
        {
            query = 'SELECT Id, Name, Type__c, Type_Of_Mod__c, Last_Modified_By_Name__c, Last_Modified_Date__c, Created_Date__c,Org_Comparison__c FROM Component_Changes_Detail__c WHERE Org_Comparison__c IN :  setOrgCompIds  AND';
            
            if( String.isNotBlank(startDateFormat) || String.isNotBlank(endDateFormat) || String.isNotBlank(typeOfMod) || String.isNotBlank(environmentType) || setOfLastModifiedByName.size() > 0 || typeFormat.size() > 0 ) {   
                if(String.isNotBlank(startDateFormat)) {
                    query += ' Last_Modified_Date__c >=' + startDateFormat + ' AND';
                }
                if(String.isNotBlank(endDateFormat)) {
                    query += ' Last_Modified_Date__c <=' + endDateFormat + ' AND';
                }
                if(typeFormat.size() > 0  && typeFormat!= null) {
                    query += ' Type__c IN : typeFormat  AND';
                }
                
                // nnn
               if(String.isNotBlank(environmentType) && environmentType!='None') {
                    query += ' Org_Comparison__c =\'' + environmentType +'\'  AND'; 
                }
                if(String.isNotBlank(typeOfMod) && typeOfMod !='None') {
                    query += ' Type_Of_Mod__c =\'' + typeOfMod +'\'  AND'; 
                }
                
                // nnn
                if(setOfLastModifiedByName.size() > 0) {
                    query += ' Last_Modified_By_Name__c IN : setOfLastModifiedByName';
                }
            }
            query = query.removeEnd('AND');  
			System.debug('query = '+ query);
            componentsChangeDetails = Database.query(query);
            System.debug('componentsChangeDetails--->'+componentsChangeDetails);
            
        }
        
        if(componentsChangeDetails != null && componentsChangeDetails.size() > 0){
         
        	Map<String, Id> mapComponentNameWithModificationId = new Map<String, Id>(); 
        	List<String> listOfComponentName = new List<String>();
        
        	if(String.isNotBlank(crId)) {
        	
            	for(SFDC_Change_Request__c changeReq : [SELECT Id, Name, (SELECT Id,IS_System_Component__c,IS_System_Component__r.Object_Type__c,IS_System_Component__r.Object_API_Name__c FROM SFDC_Modifications6__r) FROM SFDC_Change_Request__c where Id =: cRId]) {   
                
                	if(changeReq.SFDC_Modifications6__r != null) {
                    
                		for(IS_System_Modification__c isSystemMod : changeReq.SFDC_Modifications6__r) {
                        
                            //Popuklate the Key as component NAme
                            System.debug('isSystemMod.IS_System_Component__r.Object_API_Name__c = '  + isSystemMod.IS_System_Component__r.Object_API_Name__c);
                            String str = isSystemMod.IS_System_Component__r.Object_Type__c + '-'+ isSystemMod.IS_System_Component__r.Object_API_Name__c;
                            mapComponentNameWithModificationId.put(str , isSystemMod.id);
                            listOfComponentName.add(isSystemMod.IS_System_Component__r.Object_API_Name__c);
                    	}    
                	}
            	}
        	}
        	System.debug('mapComponentNameWithModificationId = '+ mapComponentNameWithModificationId);
        
            if(componentsChangeDetails.size()>0) {
                System.debug('componentsChangeDetails--->'+componentsChangeDetails);
                for(Component_Changes_Detail__c modifiedData: componentsChangeDetails) {
                    
                    Wrapper wrapObj = new Wrapper();
                   
                    wrapObj.componentsChangeDetailsId = modifiedData.Id;
                    wrapObj.componentsChangeDetailsName = modifiedData.Name;
                    wrapObj.componentsChangeDetailsType = modifiedData.Type__c;
                    wrapObj.componentsChangeDetailsTypeOfMod = modifiedData.Type_Of_Mod__c;
                    wrapObj.componentsChangeDetailsLastModifiedBy = modifiedData.Last_Modified_By_Name__c;
                    wrapObj.componentsChangeDetailsLastModifiedDate = modifiedData.Last_Modified_Date__c;
                    wrapObj.componentsChangeDetailsCreatedDate = modifiedData.Created_Date__c;
                    wrapObj.componentsChangeDetailsIsExistingMod = false;
                    
                    if(listOfComponentName != null && listOfComponentName.size() > 0 ){
                        
                        if(listOfComponentName.contains(wrapObj.componentsChangeDetailsName))
                                wrapObj.componentsChangeDetailsIsExistingMod = true;
                        
                    }
                    
                    wrapList.add(wrapObj);
                }
            }
            else {
                wrapList = new List<Wrapper>();
            }
			system.debug('@@@@@  wrapList.size() :  ' + wrapList.size());
        	system.debug('@@@@@wrapList : ' + wrapList); 
        }
        return wrapList;
    }
    

    @AuraEnabled(cacheable=true)
    //Method for finding the user data. 
    public static List<LookupSearchResult> findAdminUsers(String searchTerm, List<String> selectedUserIds ) {

        //List to hold the LookUp search Results. 
        List<LookupSearchResult> usersListToBeReturned = new List<LookupSearchResult>();

        searchTerm = '%'+searchTerm+'%';
        for(User u : [Select Id, Name,  Email From User Where Name LIKE : searchTerm AND Id Not IN: selectedUserIds 
            AND IsActive = true AND Profile.Name IN ('System Administrator', 'Specialist') ]) {

            usersListToBeReturned.add(new LookupSearchResult(u.Id, 'User', 'Contact', u.Name, u.Email, false, ''));  
        }
        return usersListToBeReturned;
    }
    
    @AuraEnabled(cacheable=true)
    //Method for finding the user data. 
    public static List<LookupSearchResult> findCurrentLoggedInUser() {

        //List to hold the LookUp search Results. 
        List<LookupSearchResult> usersListToBeReturned = new List<LookupSearchResult>();

        
        for(User u : [Select Id, Name,  Email From User Where Id =: UserInfo.getUserId() 
            AND IsActive = true AND Profile.Name IN ('System Administrator', 'Specialist') ]) {

            usersListToBeReturned.add(new LookupSearchResult(u.Id, 'User', 'Contact', u.Name, u.Email, false, ''));  
        }
        System.debug('usersListToBeReturned-->'+usersListToBeReturned);
        return usersListToBeReturned;
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, String> findComponentTypes() {

        //Map to hold the component types
        Map<String, String> mapComponentOptions = new Map<String, String>();

        //Describing the picklist field (Type) of Component_Changes_Detail__c Object, Type have all the values of component like class, Page etc....
        Schema.DescribeFieldResult fieldResult = Component_Changes_Detail__c.Type__c.getDescribe();
        
        //For loop on the picklist. 
        for(Schema.PicklistEntry f : fieldResult.getPicklistValues()){

            mapComponentOptions.put(f.getLabel(), f.getValue());
    
        }
            
        System.debug('mapComponentOptions---->'+ mapComponentOptions);
        return mapComponentOptions;
    }
    
    // nn start
    @AuraEnabled(cacheable=true)
    public static Map<Id, String> getEnvironmentPickListValue(List<String> listOfOrgCompId) {
        
        Map<Id, String> mapOrgCompIdWithConnectionName = new Map<Id, String>();
        Set<String> setOrgCompIds = new Set<String>();
        List<String> listOrgCompId = new List<String>();
        
        // remove space and brackets 
        listOfOrgCompId[0] = listOfOrgCompId[0].replaceAll( '\\s+', '').removeStart('[').removeEnd(']');
        
        // convert string to list
        listOrgCompId = listOfOrgCompId[0].split(',');
        
        // add values in set
        setOrgCompIds.addAll(listOrgCompId);
        
        for(Org_Comparision__c orgComp : [select id,Comparison_Org__r.Name from Org_Comparision__c Where Id IN: setOrgCompIds]){
            mapOrgCompIdWithConnectionName.put(orgComp.Id, orgComp.Comparison_Org__r.Name);
        }
                
        return  mapOrgCompIdWithConnectionName;
    }
    
    
    //Method Commenting
   /* @AuraEnabled
    public static Map<String, Id> getIsSystemModification(String crId){
        System.debug('crId = '+ crId);
        Map<String, Id> mapComponentNameWithModificationId = new Map<String, Id>(); 
        
        if(String.isNotBlank(crId)) {
        	
            for(SFDC_Change_Request__c changeReq : [SELECT Id, Name, (SELECT Id,IS_System_Component__c,IS_System_Component__r.Object_Type__c,IS_System_Component__r.Object_API_Name__c FROM SFDC_Modifications6__r) FROM SFDC_Change_Request__c where Id =: crId]) {   
                
                if(changeReq.SFDC_Modifications6__r != null) {
                    
                	for(IS_System_Modification__c isSystemMod : changeReq.SFDC_Modifications6__r) {
                        
                        //Popuklate the Key as component NAme
                        String str = isSystemMod.IS_System_Component__r.Object_Type__c + '-'+ isSystemMod.IS_System_Component__r.Object_API_Name__c;
                        mapComponentNameWithModificationId.put(str , isSystemMod.id);
                    }    
                }
            }
        }
        System.debug('mapComponentNameWithModificationId = '+ mapComponentNameWithModificationId);
        return mapComponentNameWithModificationId;
    }
    */
    // end nn
    
    @AuraEnabled
    public static String updateRecords(String rowData, String crid){
        
        List<Wrapper> selectedData = (List<Wrapper>)System.JSON.deserialize(rowData, List<Wrapper>.class);

       //Map to hold the component type with the list of compoents - Apexclass => List<String> {'Class names'}
        Map<String, List<String>> mapComponentDetails = new Map<String, List<String>>();
		
        //For loop on the selected list value.
        
        for(Wrapper wrap : selectedData) {
            
            if(!mapComponentDetails.containsKey(wrap.componentsChangeDetailsType))
                mapComponentDetails.put(wrap.componentsChangeDetailsType, new List<String>());
            mapComponentDetails.get(wrap.componentsChangeDetailsType).add('\''+ wrap.componentsChangeDetailsName+'\'');
            
        }
        
		
        List<String> listOfCompChangeDetails = new List<String>();
        String query = 'Select Id, Name, Object_API_Name__c, Object_Label__c, Object_Type__c From Is_System_Component__c ';
        String WhereClause = 'Where ';

        //Loop on the map to build a dynamic query. 
        for(String componentName : mapComponentDetails.keySet()) 
        {
            String component = '\''+componentName+'\'';
            
            //Check with the component type and Names
            WhereClause += '( Object_Type__c = '+ component+ ' AND Object_API_Name__c IN ' + mapComponentDetails.get(componentName) + ') OR ';
        }

        WhereClause = WhereClause.removeEnd('OR ');
        System.debug('query===='+query);
        query = query + WhereClause;

        System.debug('query=2222==='+query);
        List<Is_System_Component__c> existingComponents = Database.query(query);
        
        //map to hold the Is System components with its unique Key - Name _ Type
        Map<String, Is_System_Component__c> mapComponentWithName = new Map<String, Is_System_Component__c>();

        //For loop on the Is system component 
        for(Is_System_Component__c isSystemComp :  existingComponents) {
            
            String uniqueKey = isSystemComp.Object_Type__c + '-' + isSystemComp.Object_API_Name__c;
            mapComponentWithName.put(uniqueKey, isSystemComp);
        }
	
        //Map to hold the is system component. 
        Map<String, Is_System_component__c> mapComToBeAdded = new Map<String, Is_System_component__c>();
        Map<String, Wrapper> mapSelectedDataWithCompName = new Map<String, Wrapper>();

        //Loop on the List of component came from the page. 
        for(Wrapper wrap : selectedData) {
            //String to hold Unique key of type and Name of component. 
            String uniqueKey = wrap.componentsChangeDetailsType + '-' + wrap.componentsChangeDetailsName;
            mapSelectedDataWithCompName.put(uniqueKey, wrap);

            //Check if we alrady have the components. 
            if(mapComponentWithName.containsKey(uniqueKey)){
				System.debug('if part');
                //No Action required since we already have the Component for the same.
            }else{
                System.debug('else part');
                mapComToBeAdded.put(uniqueKey, new Is_System_component__c(Name = wrap.componentsChangeDetailsName, Object_Label__c =  wrap.componentsChangeDetailsName,  
                    Object_API_Name__c = wrap.componentsChangeDetailsName, Object_Type__c = wrap.componentsChangeDetailsType ));
            }
        }

        //Check the size of Is System compoent  map and Add it to the data base.
        System.debug('mapComToBeAdded.values() = '+ mapComToBeAdded.values()); 
        insert mapComToBeAdded.values();

        //Add both the existing and the new component maps and create mods accordingly. 
        mapComponentWithName.putAll(mapComToBeAdded);
		
        //List to hold the Is system modifications. 
        List<IS_System_Modification__c> modsToBeAdded = new List<IS_System_Modification__c>();

        //Now loop on the map to create the modification. 
        for(Is_System_component__c isSysCommp : mapComponentWithName.values() ) {
            IS_System_Modification__c isM = new IS_System_Modification__c();
            
            //check if the id is there for tghe existing mod if so then populate the modification Id
			if(String.isNotBlank(mapSelectedDataWithCompName.get(isSysCommp.Object_Type__c + '-'+  isSysCommp.Object_API_Name__c).componentsChangeDetailsModId) )
                isM.Id = mapSelectedDataWithCompName.get(isSysCommp.Object_Type__c + '-'+  isSysCommp.Object_API_Name__c).componentsChangeDetailsModId;
            
            isM.Change_Request__c = crid;
            isM.IS_System_Component__c = isSysCommp.Id;
            isM.Type_of_Modification__c = mapSelectedDataWithCompName.get(isSysCommp.Object_Type__c + '-'+  isSysCommp.Object_API_Name__c).componentsChangeDetailsTypeOfMod;
            isM.Description__c = mapSelectedDataWithCompName.get(isSysCommp.Object_Type__c + '-'+  isSysCommp.Object_API_Name__c).description;
            isM.Include_in_Change_Set__c = true;

            modsToBeAdded.add(isM);
        }

        try {
            //Check the size of the List. 
            upsert modsToBeAdded;
            return 'Success';
        }catch(Exception e) {

            return e.getMessage();
        }
    }

    @AuraEnabled(cacheable=true)
    public static void methodToRefreshPageVariable() {


    }

    //Wrapper Class
    public class Wrapper 
    {
        @AuraEnabled public String errorMEssage {get;set;}
        @AuraEnabled public String componentsChangeDetailsId {get;set;}
        @AuraEnabled public Boolean componentsChangeDetailsIsExistingMod {get;set;}
        @AuraEnabled public String componentsChangeDetailsModId {get;set;}
        
        @AuraEnabled public String componentsChangeDetailsName {get;set;}
        @AuraEnabled public String componentsChangeDetailsType {get;set;}
        @AuraEnabled public String componentsChangeDetailsTypeOfMod {get;set;}
        @AuraEnabled public String componentsChangeDetailsLastModifiedBy {get;set;}
        @AuraEnabled public Date componentsChangeDetailsLastModifiedDate {get;set;}
        @AuraEnabled public Date componentsChangeDetailsCreatedDate {get;set;}
        @AuraEnabled public String  description {get;set;}
        
    }
}