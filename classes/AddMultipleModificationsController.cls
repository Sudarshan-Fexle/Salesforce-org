/**
*	Description     :   Add Multiple Modification Screen controller class
* 
*	Created By      :   Abhinav Sharma    
* 
*	Created Date    :   12/12/2019
* 
*	Revision Logs   :   V_1.0 - Created
*                       
**/  

public without sharing class AddMultipleModificationsController 
{
    @AuraEnabled(cacheable=true)
    public static LightningResponseEntity getEnvironmentPickListValue(Id changeRequestId) 
    {
        try
        {
            Map<Id, String> mapOrgCompIdWithConnectionName = new Map<Id, String>();
            if(changeRequestId != null)
            {
                List<SFDC_Change_Request__c> listOfChangeRequests = [SELECT Id, Release__c, 
                                                                     Release__r.Last_Org_Comparision_Sync__c
                                                                     FROM SFDC_Change_Request__c 
                                                                     WHERE Release__c != null 
                                                                     AND Id =: changeRequestId];
                if(listOfChangeRequests.size() > 0) 
                {
                    String parentReleaseId = listOfChangeRequests[0].Release__c;
                    if(String.isNotBlank(parentReleaseId)) 
                    {
                        for(SFDC_Release__c release : [SELECT Id, Org_Comparison_QA__c, 
                                                       Org_Comparison_UAT__c,Last_Org_Comparision_Sync__c,
                                                       (SELECT Id, Comparison_Org__c, Comparison_Org__r.Name 
                                                        FROM Org_Comparisons__r
                                                        WHERE Comparison_Org__c != null
                                                       ) 
                                                       FROM SFDC_Release__c 
                                                       WHERE Id =: parentReleaseId 
                                                       AND Ready_for_Org_Comparison__c = true])
                        {
                            if(release.Org_Comparisons__r != null && release.Org_Comparisons__r.size() > 0) 
                            {
                                for(Org_Comparision__c oC : release.Org_Comparisons__r) 
                                {
                                    mapOrgCompIdWithConnectionName.put(oC.Id, oC.Comparison_Org__r.Name);            
                                }
                            }   
                        }
                    }
                }
            }
            return LightningResponseEntity.create().setBody(mapOrgCompIdWithConnectionName);
        }   
        catch(Exception e)
        {
            throw new AuraHandledException('  occured:\r\n' + e.getMessage() + '\r\n' + e.getStackTraceString() + '\r\n');   
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static LightningResponseEntity findComponentTypes() 
    {
        try
        {
            Map<String, String> mapComponentOptions = new Map<String, String>();
            Schema.DescribeFieldResult fieldResult = Component_Changes_Detail__c.Type__c.getDescribe();
            for(Schema.PicklistEntry f : fieldResult.getPicklistValues())
            {
                mapComponentOptions.put(f.getLabel(), f.getValue());
            }
            return LightningResponseEntity.create().setBody(mapComponentOptions);
        }   
        catch(Exception e)
        {
            throw new AuraHandledException('  occured:\r\n' + e.getMessage() + '\r\n' + e.getStackTraceString() + '\r\n');   
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static LightningResponseEntity getLastOrgComparisionSyncDate(Id changeRequestId) 
    {
        try
        {
            String lastOrgComparisionSyncDate = '';
            if(changeRequestId != null)
            {
                List<SFDC_Change_Request__c> listOfChangeRequests = [SELECT Id, Release__r.Last_Org_Comparision_Sync__c
                                                                     FROM SFDC_Change_Request__c 
                                                                     WHERE Release__c != null 
                                                                     AND Id =: changeRequestId];
                if(listOfChangeRequests.size() > 0 && listOfChangeRequests[0].Release__r !=null 
                   && listOfChangeRequests[0].Release__r.Last_Org_Comparision_Sync__c !=null) 
                {
                    //Fill the Last OrgComparision Sync Date
                    lastOrgComparisionSyncDate = listOfChangeRequests[0].Release__r.Last_Org_Comparision_Sync__c.format('MM/dd/yyyy HH:mm a');
                }
            }
            return LightningResponseEntity.create().setBody(lastOrgComparisionSyncDate);
        }   
        catch(Exception e)
        {
            throw new AuraHandledException('  occured:\r\n' + e.getMessage() + '\r\n' + e.getStackTraceString() + '\r\n');   
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static LightningResponseEntity getDataFromComponentsChangeDetails(Date oStartDate, Date oEndDate, 
                                                                             List<String> selectedComponentType, 
                                                                             List<String> lastModifiedByNames, 
                                                                             List<String> listOfOrgComparisionRecordsIds, 
                                                                             String cRId, 
                                                                             String environmentType, 
                                                                             List<String> typeOfModification) 
    {  
        try
        {
            List<ComponentChangeDetailsWrapper> listOfComponentChangeDetailsWrapper = new List<ComponentChangeDetailsWrapper>();
            if(listOfOrgComparisionRecordsIds != null && listOfOrgComparisionRecordsIds.size() > 0)
            {
                List<Component_Changes_Detail__c> componentsChangeDetails = new List<Component_Changes_Detail__c>();
                String sOQLQuery = '';
                String startDateFormat;
                String endDateFormat;
                
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
                
                // List to hold final data of selected user name as required for dynamic Query
                set<String> setOfLastModifiedByName = new set<String>();
                if(lastModifiedByNames != null && lastModifiedByNames.size() > 0) 
                {
                    for(String str : lastModifiedByNames)
                    {
                        String temp = str.trim().remove('\"');
                        if(String.isNotBlank(temp)) 
                        {
                            setOfLastModifiedByName.add(temp);    
                        }
                    }
                }
                sOQLQuery = 'SELECT Id, Name, Type__c, Type_Of_Mod__c, Last_Modified_By_Name__c, Last_Modified_Date__c, ';
                sOQLQuery += 'Created_Date__c, Org_Comparison__c, Description__c FROM Component_Changes_Detail__c ';
                sOQLQuery += 'WHERE Org_Comparison__c != null AND Org_Comparison__c IN : listOfOrgComparisionRecordsIds AND ';
                
                if(String.isNotBlank(startDateFormat)) 
                {
                    sOQLQuery += ' Last_Modified_Date__c >=' + startDateFormat + ' AND';
                } 
                
                if(String.isNotBlank(endDateFormat)) 
                {
                    sOQLQuery += ' Last_Modified_Date__c <=' + endDateFormat + ' AND';
                }
                
                if(selectedComponentType != null && selectedComponentType.size() > 0) 
                {
                    sOQLQuery += ' Type__c IN : selectedComponentType AND';
                } 
                
                if(String.isNotBlank(environmentType) && environmentType !='None') 
                {
                    sOQLQuery += ' Org_Comparison__c =\'' + environmentType +'\'  AND'; 
                }
                
                if(typeOfModification != null && typeOfModification.size() > 0) 
                {
                    sOQLQuery += ' Type_Of_Mod__c IN : typeOfModification AND'; 
                }
                
                if(lastModifiedByNames != null && lastModifiedByNames.size() > 0) 
                {
                    sOQLQuery += ' Last_Modified_By_Name__c IN : setOfLastModifiedByName';
                }
                sOQLQuery = sOQLQuery.trim();
                sOQLQuery = sOQLQuery.removeEnd('AND');
                
                sOQLQuery += ' ORDER By Name ASC ';
                
                componentsChangeDetails = (List<Component_Changes_Detail__c>)Database.query(sOQLQuery);
                if(componentsChangeDetails != null && componentsChangeDetails.size() > 0)
                { 
                    Map<String, IS_System_Modification__c> mapOfComponentNameKeyWithChangeRequest = new Map<String, IS_System_Modification__c>();
                    if(String.isNotBlank(crId)) 
                    {
                        for(IS_System_Modification__c isSystemMod : [SELECT Id, IS_System_Component__c,
                                                                     Change_Request__c,
                                                                     IS_System_Component__r.Object_Type__c,
                                                                     IS_System_Component__r.Object_API_Name__c 
                                                                     FROM IS_System_Modification__c
                                                                     WHERE Change_Request__c =: crId
                                                                    ]) 
                        {   
                            
                            String objectTypeObjectNameKey = isSystemMod.IS_System_Component__r.Object_Type__c 
                                + '-' 
                                + isSystemMod.IS_System_Component__r.Object_API_Name__c;
                            mapOfComponentNameKeyWithChangeRequest.put(objectTypeObjectNameKey, isSystemMod);
                        }
                    }
                    //Map to hold the picklist
                    Map<String, String> mapPickListValues = new Map<String, String>();
                    List<Schema.PicklistEntry> ple = Component_Changes_Detail__c.Type__c.getDescribe().getPicklistValues();
                    for( Schema.PicklistEntry pickListVal : ple)
                       mapPickListValues.put(pickListVal.getValue(), pickListVal.getLabel());
                    
                    System.debug('mapPickListValues=='+mapPickListValues);
            
                    
                    
                    for(Component_Changes_Detail__c modifiedData : componentsChangeDetails) 
                    {
                        ComponentChangeDetailsWrapper wrapObj = new ComponentChangeDetailsWrapper();
                        wrapObj.componentsChangeDetailsId = modifiedData.Id;
                        wrapObj.componentsChangeDetailsName = modifiedData.Name;
                        wrapObj.componentsChangeDetailsType = mapPickListValues.containsKey(modifiedData.Type__c) ? mapPickListValues.get(modifiedData.Type__c) : modifiedData.Type__c ;
                        wrapObj.componentsChangeDetailsTypeOfMod = modifiedData.Type_Of_Mod__c;
                        wrapObj.componentsChangeDetailsLastModifiedBy = modifiedData.Last_Modified_By_Name__c;
                        wrapObj.componentsChangeDetailsLastModifiedDate = modifiedData.Last_Modified_Date__c;
                        wrapObj.componentsChangeDetailsCreatedDate = modifiedData.Created_Date__c;
                        wrapObj.componentsChangeDetailsIsExistingMod = false;
                        wrapObj.existingModificationId = null;
                        wrapObj.description = modifiedData.Description__c;
                        if(mapOfComponentNameKeyWithChangeRequest.containsKey(wrapObj.componentsChangeDetailsType + '-' + wrapObj.componentsChangeDetailsName)) 
                        {
                            wrapObj.componentsChangeDetailsIsExistingMod = true;
                            wrapObj.existingModificationId = mapOfComponentNameKeyWithChangeRequest.get(wrapObj.componentsChangeDetailsType + '-' + wrapObj.componentsChangeDetailsName).Id;
                        }
                        listOfComponentChangeDetailsWrapper.add(wrapObj);
                    }
                }
                else 
                {
                    listOfComponentChangeDetailsWrapper = new List<ComponentChangeDetailsWrapper>();    
                }
            }
            return LightningResponseEntity.create().setBody(listOfComponentChangeDetailsWrapper); 
        }   
        catch(Exception e)
        {
            throw new AuraHandledException('  occured:\r\n' + e.getMessage() + '\r\n' + e.getStackTraceString() + '\r\n');   
        }
    }
    
    @AuraEnabled(cacheable=false)
    public static LightningResponseEntity updateRecords(String rowData, String crid)
    {
        try
        {
            
            String res = '';
            List<IS_System_Modification__c> modsToBeAdded = new List<IS_System_Modification__c>();
            if(String.isNotBlank(rowData) && String.isNotBlank(crid)) 
            {
                List<ComponentChangeDetailsWrapper> selectedData = (List<ComponentChangeDetailsWrapper>)System.JSON.deserialize(rowData, List<ComponentChangeDetailsWrapper>.class);
                if(selectedData.size() > 0) 
                {
                    //Map to hold the component type with the list of components - Apexclass => List<String> {'Class names'}
                    Map<String, List<String>> mapComponentDetails = new Map<String, List<String>>();
                    for(ComponentChangeDetailsWrapper wrap : selectedData) 
                    {
                        if(!mapComponentDetails.containsKey(wrap.componentsChangeDetailsType)) 
                        {
                            mapComponentDetails.put(wrap.componentsChangeDetailsType, new List<String>());        
                        }
                        mapComponentDetails.get(wrap.componentsChangeDetailsType).add('\''+ wrap.componentsChangeDetailsName+'\'');
                    }
                    if(mapComponentDetails.values().size() > 0) 
                    {
                        List<String> listOfCompChangeDetails = new List<String>();
                        String sOQLQuery = 'Select Id, Name, Object_API_Name__c, Object_Label__c, Object_Type__c From Is_System_Component__c ';
                        String whereClause = 'Where ';
                        /*for(String componentName : mapComponentDetails.keySet()) 
                        {
                            String component = '\''+componentName+'\'';
                            Set<String> setOfComponents = new Set<String>();
                            for(String compD : mapComponentDetails.get(componentName)) 
                            {
                                setOfComponents.add(compD.removeEnd('\'').removeStart('\'')); 
                            }
                            System.debug('setOfComponents====='+setOfComponents);
                            whereClause += '( Object_Type__c = ' + component + ' AND Object_API_Name__c IN :setOfComponents ) OR ';
                        }*/
                        
                        for(String componentName : mapComponentDetails.keySet()) 
                        {
                            String component = '\''+componentName+'\'';
                            System.debug('componentName=='+componentName);
                            
                            String allComponent = '';
                            
                            for(String compo : mapComponentDetails.get(componentName)){
                               // allComponent += '\'' + compo + '\', ';
                               allComponent +=  compo + ', ';
                            }
                            System.debug('allComponent ==='+allComponent);
                            allComponent = allComponent.removeEnd(', ');
                            
                            whereClause += '( Object_Type__c = ' + component + ' AND Object_API_Name__c IN  (' + allComponent +') ) ' + '  OR ';
                        }
                        
                        whereClause = whereClause.trim();
                        whereClause = whereClause.removeEnd('OR');
                        sOQLQuery += whereClause;
                        if(sOQLQuery.length() >= 20000) 
                        {
                            throw new AuraHandledException('SOQL Query Maximum Character Size Limit Exceeded. Please try again selecting less number of changes.');
                        }
                        List<Is_System_Component__c> existingComponents = Database.query(sOQLQuery);
                        Map<String, Is_System_Component__c> mapComponentWithName = new Map<String, Is_System_Component__c>();
                        for(Is_System_Component__c isSystemComp :  existingComponents) 
                        {
                            mapComponentWithName.put(isSystemComp.Object_Type__c + '-' + isSystemComp.Object_API_Name__c, 
                                                     isSystemComp);
                            
                            System.debug('Dupe -- '+ isSystemComp);
                        }
                        Map<String, Is_System_component__c> mapComToBeAdded = new Map<String, Is_System_component__c>();
                        Map<String, ComponentChangeDetailsWrapper> mapSelectedDataWithCompName = new Map<String, ComponentChangeDetailsWrapper>();
                        Set<String> setUniqueNewComingsKey = new Set<String>();
                        
                        for(ComponentChangeDetailsWrapper wrap : selectedData) 
                        {
                            String uniqueKey = wrap.componentsChangeDetailsType + '-' + wrap.componentsChangeDetailsName;
                            mapSelectedDataWithCompName.put(uniqueKey, wrap);
                            if(mapComponentWithName.containsKey(uniqueKey))
                            {
                                System.debug('Duplicate Detected' + uniqueKey);
                                continue;
                            }
                            else
                            {	
                                //Modified by Mahendra Swarnkar - 02/21/2020 - CR-20200221-13791
                                if(!setUniqueNewComingsKey.contains(uniqueKey)) {
                                
                                	 //80 Characters limits.
                                    String compName = String.isNotBlank(wrap.componentsChangeDetailsName) && wrap.componentsChangeDetailsName.length() > 79 ? wrap.componentsChangeDetailsName.subString(0, 78) : wrap.componentsChangeDetailsName; 
                                    
                                    mapComToBeAdded.put(uniqueKey, new Is_System_component__c(Name = compName, 
                                                                                          Object_Label__c =  compName,  
                                                                                          Object_API_Name__c = wrap.componentsChangeDetailsName, 
                                                                                          Object_Type__c = wrap.componentsChangeDetailsType));    
                                	
                                    setUniqueNewComingsKey.add(uniqueKey);	
                                }
                            }
                        }
                        if(mapComToBeAdded.values().size() > 0) 
                        {
                            Util.BypassAllTriggers = true;
                            insert mapComToBeAdded.values();
                            Util.BypassAllTriggers = false;
                        }
                        //Add both the existing and the new component maps and create mods accordingly. 
                        mapComponentWithName.putAll(mapComToBeAdded);
                        for(Is_System_component__c isSysCommp : mapComponentWithName.values()) 
                        {
                            IS_System_Modification__c isM = new IS_System_Modification__c();
                            isM.Change_Request__c = crid;
                            isM.IS_System_Component__c = isSysCommp.Id;
                            isM.Include_in_Change_Set__c = true;
                            if(mapSelectedDataWithCompName.containsKey(isSysCommp.Object_Type__c + '-'+  isSysCommp.Object_API_Name__c)) 
                            {
                                isM.Id = mapSelectedDataWithCompName.get(isSysCommp.Object_Type__c + '-' +  isSysCommp.Object_API_Name__c).existingModificationId;                        
                                isM.Type_of_Modification__c = mapSelectedDataWithCompName.get(isSysCommp.Object_Type__c + '-'+  isSysCommp.Object_API_Name__c).componentsChangeDetailsTypeOfMod;
                                isM.Description__c = mapSelectedDataWithCompName.get(isSysCommp.Object_Type__c + '-'+  isSysCommp.Object_API_Name__c).description;    
                            }
                            modsToBeAdded.add(isM);
                        }
                        if(modsToBeAdded.size() > 0) 
                        {
                            Util.BypassAllTriggers = true;
                            upsert modsToBeAdded;
                            Util.BypassAllTriggers = false;
                            res = 'Success';
                        }
                    }
                }
                else 
                {
                    throw new AuraHandledException('No record selected to be added as modification.');    
                }
                
            }
            return LightningResponseEntity.create().setBody(res);
        }
        catch(Exception e)
        {
            throw new AuraHandledException('  occured:\r\n' + e.getMessage() + '\r\n' + e.getStackTraceString() + '\r\n');   
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static LightningResponseEntity fetchCurrentLoggedInUserDetails(String userId)
    {
        try 
        {
            LightningResponseEntity lRE = LightningResponseEntity.create();
            if(String.isNotBlank(userId)) 
            {
                if(userId instanceOf Id) 
                {
                    List<User> users = [SELECT Id, Name 
                                        FROM User 
                                        WHERE Id =: userId
                                        AND IsActive = true 
                                       ];
                    if(users.size() > 0) 
                    {
                        return LightningResponseEntity.create().setBody(users[0]);    
                    }
                    else 
                    {
                        lRE.setError('Unable to retrieve current logged in user details.');
                        lRE.setBody(null);
                        return lRE;
                    }                    
                }
                else 
                {
                    lRE.setError('Invalid Id for current logged in user.');
                    lRE.setBody(null);
                    return lRE;
                }
            }
            else 
            {
                lRE.setError('Unable to access current logged in user Id.');
                lRE.setBody(null);
                return lRE;    
            }
        }
        catch(Exception e)
        {
            throw new AuraHandledException('  occured:\r\n' + e.getMessage() + '\r\n' + e.getStackTraceString() + '\r\n');   
        }
    }
    
    public class ComponentChangeDetailsWrapper 
    {
        @AuraEnabled public String errorMEssage {get;set;}
        @AuraEnabled public String componentsChangeDetailsId {get;set;}
        @AuraEnabled public Boolean componentsChangeDetailsIsExistingMod {get;set;}
        @AuraEnabled public String componentsChangeDetailsName {get;set;}
        @AuraEnabled public String componentsChangeDetailsType {get;set;}
        @AuraEnabled public String componentsChangeDetailsTypeOfMod {get;set;}
        @AuraEnabled public String componentsChangeDetailsLastModifiedBy {get;set;}
        @AuraEnabled public Date componentsChangeDetailsLastModifiedDate {get;set;}
        @AuraEnabled public Date componentsChangeDetailsCreatedDate {get;set;}
        @AuraEnabled public String description {get;set;}
        @AuraEnabled public String existingModificationId {get;set;}
    }
}