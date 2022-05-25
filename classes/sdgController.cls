/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
global with sharing class sdgController {

    @AuraEnabled
    public static string GetNamespace()
    {
        return JSON.serialize( sdgNamespaceUtility.GetNamespace());
    }

    @AuraEnabled
    public static String GetSDGInitialLoad(String ParentRecordID, String SDGTag, String RelationshipName, String FieldSetName, integer DefaultPageSize)
    {
        //Create response object
        SDGInitialLoad initial = new SDGInitialLoad();
        // Salesforce bug with Lightning serializer requires re-casting this value
        //https://salesforce.stackexchange.com/questions/108355/limit-expression-must-be-of-type-integer-error-when-using-apex-variable-in-soq/108423#108423
        try {
            DefaultPageSize = Integer.valueOf(DefaultPageSize);
        }
        catch (Exception ex)
        {
            throw new AuraHandledException('Invalid DefaultPageSize provided');
        }
        
        system.debug('sdgController:GetSDGInitialLoad:-' + ParentRecordID + ' :SDGTag:- ' + SDGTag + ' :RelationshipName:- ' + RelationshipName + ' :FieldSetName:- ' + FieldSetName);
        try
        {
            SDG newSDG = SDGDataProviderFactory.LoadSDG(SDGTag, ParentRecordId, RelationshipName, FieldsetName);
            //Create a full request:
            SDGRequest req = new SDGRequest();

            if (!String.isBlank(SDGTag))
            {
                req = sdgPreferences.GenerateRequestWithFilters(newSDG, ParentRecordID, SDGTag);
            } 
            req.RelationshipName = RelationshipName;
            req.FieldSetName = FieldSetName;
            req.ParentRecordID = ParentRecordID;
            req.SDGTag = SDGTag;
            req.PageSize = DefaultPageSize;

            SDGResult result = sdgDataProviderFactory.getData( req, newSDG);
            //Blank out the internal data to save payload:
            newSDG.InternalData = null;

            //build response object:
            initial.SDGObject = newSDG;
            initial.results = result;
            initial.isError = false;
            
            system.debug('sdgController:GetSDGInitialLoad121:-' + ParentRecordID + ' :SDGTag:- ' + SDGTag + ' :RelationshipName:- ' + RelationshipName + ' :FieldSetName:- ' + FieldSetName);
        	
        }
        
        catch (SDGException ex)
        {
            initial.ErrorMessage = ex.getMessage();
            initial.isError = true;
        }
        catch (Exception standardex)
        {
            initial.ErrorMessage = standardex.getMessage();
            initial.isError = true;
        }
        return JSON.serialize(initial);
    }

    @AuraEnabled
    public static string getSDGResult(String jsonrequest)
    {
        SDGResult results = new SDGResult();

        String resultsstring = '';
        try
        {
            system.debug('sdgController:getSDGResult: getting request');
            SDGRequest request = (SDGRequest)JSON.deserialize(jsonrequest, SDGRequest.class);
            system.debug('sdgController:getSDGResult: getting result');

            results = sdgDataProviderFactory.getData(request);

            results.isError=false;
        }
        catch (Exception ex)
        {
            system.debug('sdgController:getSDGResult: Exception: ' + ex.getMessage() );
            results.ErrorMessage = ex.getMessage();
            results.isError = true;
        }
        return JSON.serialize(results);
    }
 
    
    global String sObjectAPIName { get; set; }
	
    //Created By Mahendra - 02/19/2019
    @RemoteAction
    global static List<SDG__c> getSDGRecords(String tagName) {
        List<SDG__c> listsdgRecords = [SELECT Id, Name, SDG_Tag__c, Default_Sort__c, Filter__c, Is_Valid__c, sObjectName__c, Default_Page_Size__c, Show_Debug_Log__c, Is_Full_List_View__c, Icon_Name__c
                                       FROM SDG__c 
                                       WHERE SDG_Tag__c = : tagName AND Is_Valid__c = true ORDER BY Grid_Order__c ASC];
		return listsdgRecords;

    }
    
    //Mahendra Swarnkar - 04/17/2020 - CR-20200225-13804 - Start here
    public static Map<Id, String> recordtypemap {get;set;}
    
   @AuraEnabled        
    public static List<String> fetchRecordTypeValues(){
        List<Schema.RecordTypeInfo> recordtypes = Event.SObjectType.getDescribe().getRecordTypeInfos();    
        recordtypemap = new Map<Id, String>();
        
        for(RecordTypeInfo rt : recordtypes){
            if(rt.getName() != 'Master' && rt.isActive() == true)
            recordtypemap.put(rt.getRecordTypeId(), rt.getName());
        }        
        return recordtypemap.values();
    }
    
    @AuraEnabled
    public static Id getRecTypeId(String recordTypeLabel){
        Id recid = Schema.SObjectType.Event.getRecordTypeInfosByName().get(recordTypeLabel).getRecordTypeId();        
        return recid;
    }
    //Mahendra Swarnkar - 04/17/2020 - CR-20200225-13804 - End here
}