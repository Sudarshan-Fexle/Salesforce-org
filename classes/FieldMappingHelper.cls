/**
 *  Description     :   Helper class for mapping & converting field values from one field to another
 * 
 *  Created By      :   Victor Hanson  
 * 
 *  Created Date    :   05/26/2016
 * 
 *  Revision Logs   :   V_1.0 - Created
 * 			V_1.1 - Modified By - Mahendra Swarnkar - 3/7/2017 - CR-20170208-10671 - Added a new Method "getMappingByFieldByValue" and Commented out the existing method "fldMappingByFieldByValue" and move its code into the new method
 *			V_1.2 - Main purpose is that fldMappingByFieldByValue doesn't duplicate the query executed for each Member Support record passed in to mapMemSupportFields(list<Site_Issue__c> newMemberSupports)
 * 			V_1.3 - Modified By - Mahendra Swarnkar - 03/25/2019 - CR-20181019-12685 - Updated Method "mapFields" to have condition to check the value.
 *			V_1.4 - Modified By - Subhash Garhwal - 03/28/2019 - CR-20181019-12685 - Moved changes from cpqDev1 to full1
 *                      V_1.5 - Modified By - Victor Hanson - 01/14/2021 - CR-20210107-14791 - added logic to bypass twinning when Twin_Fields_Date_Time__c is populated and included without sharing
 *			V_1.6 - Modified By - Mahendra Swarnkar - CR-20210519-15165 - Change API Name from Twin_Fields_Date_Time__c to Twin_Fields_Date_Time_m__c
 *  
**/ 
public without sharing class FieldMappingHelper {
    
    //variables
    public sObject sourceObj { get; set; }
    public sObject targetObj { get; set; }
    private string sourceObjType { get; set; }
    
    //V_1.1 - Modified By - Mahendra Swarnkar - 3/7/2017 - CR-20170208-10671
	public static map<string, map<string, map<string, Field_Mapping_Value__mdt>>> objMappingByFieldByValue { get; set; }
    
    //constructor
    public FieldMappingHelper(sObject sourceObj, sObject targetObj) {
        this.sourceObj = sourceObj;
        if (targetObj != null) this.targetObj = targetObj;
        else this.targetObj = sourceObj;
        //get the source object and target object types
        sourceObjType = string.valueOf(sourceObj.getSObjectType());
        //map the field value
        mapFieldValue();
    }
    
    public FieldMappingHelper(String sourceObjType) {
        //get the source object and target object types
        this.sourceObjType = sourceObjType;
    }
    
    //constructor
    public FieldMappingHelper(sObject sourceObj, sObject targetObj, boolean test) {
        this.sourceObj = sourceObj;
        if (targetObj != null) this.targetObj = targetObj;
        else this.targetObj = sourceObj;
        //get the source object and target object types
        sourceObjType = string.valueOf(sourceObj.getSObjectType());
        //map the field value
        mapFieldValue2();
    }
    
	/**
	 * Check Member Support records for applicable Fields that need to be mapped
	 **/
    public static void mapMemSupportFields(list<Site_Issue__c> newMemberSupports) {
        for (Site_Issue__c sI : newMemberSupports) {
            new FieldMappingHelper((sobject) sI, null);
        }
    }
    
    /**
	 * Check Case records for applicable Fields that need to be mapped
	 **/
    public static void mapFields(list<Case> newCases) {
        for (Case c : newCases) {
            new FieldMappingHelper((sobject) c, null);
        }
    }
    
    /**
	 * Check Case records for applicable Fields that need to be mapped
	 **/
    public static void mapFields(List<SBQQ__Subscription__c> newSubscriptions, Map<Id, SBQQ__QuoteLine__c> qlMap) {
        
        FieldMappingHelper fmh = new FieldMappingHelper('SBQQ__QuoteLine__c');
        
        for (SBQQ__Subscription__c sub : newSubscriptions) {
            
            // Added the check for null - by Mahendra Swarnkar - 08/29/2019 - CR-20190828-13293 
            // so that it will set/map the field values only for those subscrition which holds the SBQQ__QuoteLine__c field value 
            if(sub.SBQQ__QuoteLine__c != null && qlMap != null && qlMap.get(sub.SBQQ__QuoteLine__c) != null) {
                
		// Modified By - Mahendra Swarnkar - CR-20210519-15165 - Change API Name from Twin_Fields_Date_Time__c to Twin_Fields_Date_Time_m__c
                //01/14/2021 - CR-20210107-14791 - Victor Hanson - skip if the fields have already been twinned
                if (sub.Twin_Fields_Date_Time_m__c != null) {
                    continue;
                }

                fmh.sourceObj = (SObject) qlMap.get(sub.SBQQ__QuoteLine__c);
                fmh.targetObj = (sobject) sub;
                
                //map the field value
                fmh.mapFieldValue2();
		
		// Modified By - Mahendra Swarnkar - CR-20210519-15165 - Change API Name from Twin_Fields_Date_Time__c to Twin_Fields_Date_Time_m__c
                //01/14/2021 - CR-20210107-14791 - Victor Hanson - set the date the twin fields were populated
                sub.Twin_Fields_Date_Time_m__c = dateTime.now();
            }
        }
    }
    
    /**
	 * Check Case records for applicable Fields that need to be mapped
	 **/
    public static void mapFields(List<SBQQ__QuoteLine__c> newQuoteLines, Map<Id, SBQQ__Subscription__c> subMap) {
        
        for (SBQQ__QuoteLine__c ql : newQuoteLines) {
            Id subId = ql.SBQQ__RenewedSubscription__c != null ? ql.SBQQ__RenewedSubscription__c : ql.SBQQ__UpgradedSubscription__c;
            
            //Added condition to check the value - By Mahendra Swarnkar - 03/25/2019 - CR-20181019-12685  
            //Check for value
            if(subId != null)
                new FieldMappingHelper(subMap.get(subId), (sobject) ql, true);
                
            //01/14/2021 - CR-20210107-14791 - Victor Hanson - set the date the twin fields were populated
            ql.Twin_Fields_Date_Time__c = dateTime.now();
        }
    }
    
    //V_1.1 - Modified By - Mahendra Swarnkar - 3/7/2017 - CR-20170208-10671
    /**
	 * @description: map values from the source field to the target field using field mappings
	 * 
	 **/
    public void mapFieldValue() {
        string srcFieldValue;
        
        //V_1.1 - Modified By - Mahendra Swarnkar - 3/7/2017 - CR-20170208-10671 - Starts from here
        //Map to hold the Source field API NAme as a key with the valuemap [i.e. map that hold the source field value name with field mapped value]
        map<string, map<string, Field_Mapping_Value__mdt>> mapByFieldByVal = MappingByFieldByValue;
        
        //Loop over the mapByFieldByVal key set
        for (string srcFieldAPIName : mapByFieldByVal.keySet()) {
            
            //Check for the Source field APi name
            //if this is an instance of a string, convert it and continue processing
            if (mapByFieldByVal.containsKey(srcFieldAPIName)
                && sourceObj.get(srcFieldAPIName) instanceOf string)
            {
                //Get the source field value
                srcFieldValue = (string) sourceObj.get(srcFieldAPIName);
                
                //Check for the field mapping record   
                if (srcFieldValue != null
                    && mapByFieldByVal.get(srcFieldAPIName.toLowerCase()) != null
                   	&& mapByFieldByVal.get(srcFieldAPIName.toLowerCase()).containsKey(srcFieldValue.toLowerCase())
                   	&& mapByFieldByVal.get(srcFieldAPIName.toLowerCase()).get(srcFieldValue.toLowerCase()) != null) 
                {
                    
                    //get the field mapping value record
                    Field_Mapping_Value__mdt fldMapping = mapByFieldByVal.get(srcFieldAPIName).get(srcFieldValue.toLowerCase());
                    
                    //set the source object's field to the mapped value
                    targetObj.put(fldMapping.Field_Mapping__r.Target_Field_API_Name__c, fldMapping.Target_Value__c);
                }
            }
        }
        //V_1.1 - Modified By - Mahendra Swarnkar - 3/7/2017 - CR-20170208-10671 - Ends here
    }
    
    //V_1.1 - Commented By - Mahendra Swarnkar - 3/7/2017 - CR-20170208-10671
    /**	
	 * @description: return a map of fieldMappings by Field & Value.  ie: map<'Status_Group__c', map<'Another ticket pending for client', 'Files Received'>>
	 * 																	  map<[SOURCE FIELD API NAME], map<[SOURCE VALUE], [TARGET VALUE]>>
	 **/
    /*public map<string, map<string, Field_Mapping_Value__mdt>> fldMappingByFieldByValue {
        get {
            if (fldMappingByFieldByValue == null) {
                fldMappingByFieldByValue = new map<string, map<string, Field_Mapping_Value__mdt>>();
                list<Field_Mapping__mdt> fMappings = [SELECT Id, Source_Object_API_Name__c, Source_Field_API_Name__c,
                                                      Target_Object_API_Name__c, Target_Field_API_Name__c,
                                                      (SELECT Id, Source_Value__c, Target_Value__c, 
                                                       Field_Mapping__r.Source_Field_API_Name__c, Field_Mapping__r.Target_Field_API_Name__c 
                                                       FROM Field_Mapping_Values__r)
                                                      FROM Field_Mapping__mdt
                                                      WHERE Source_Object_API_Name__c = :sourceObjType AND Active__c = true];
                for (Field_Mapping__mdt f : fMappings) {
                    map<string, Field_Mapping_Value__mdt> valueMap = fldMappingByFieldByValue.get(f.Source_Field_API_Name__c);
                    if (valueMap == null) valueMap = new map<string, Field_Mapping_Value__mdt>();
                    for (Field_Mapping_Value__mdt fv : f.Field_Mapping_Values__r) {
                        valueMap.put(fv.Source_Value__c.toLowerCase(), fv);
                    }
                    fldMappingByFieldByValue.put(f.Source_Field_API_Name__c.toLowerCase(), valueMap);
                }
            }
            return fldMappingByFieldByValue;
        }
        set;
    }
    */
    
    //V_1.1 - added By - Mahendra Swarnkar - 3/7/2017 - CR-20170208-10671
    /**	
	 * @description: return a map of fieldMappings by Field & Value.  ie: map<'Status_Group__c', map<'Another ticket pending for client', 'Files Received'>>
	 * 																	  map<[SOURCE FIELD API NAME], map<[SOURCE VALUE], [TARGET VALUE]>>
	 **/
    public map<string, map<string, Field_Mapping_Value__mdt>> MappingByFieldByValue {
        get {
            
            if (MappingByFieldByValue == null) {
                
                //Check for  objMappingByFieldByValue map
                if (objMappingByFieldByValue == null) objMappingByFieldByValue = new map<string, map<string, map<string, Field_Mapping_Value__mdt>>>();
                
                //Check to see if we've retrieved the field map for the given sourceObject
                if (objMappingByFieldByValue.get(sourceObjType) == null) {
                    
                    //MAp to hold the source field api name as a key with the (map of sorce value as a key and field mapping value as value) as a value  
                    map<string, map<string, Field_Mapping_Value__mdt>> fldMappingByFieldByValue = new map<string, map<string, Field_Mapping_Value__mdt>>();
                    
                    //Query over the field map and related field mapping values childs records
                    list<Field_Mapping__mdt> fMappings = [SELECT Id, Source_Object_API_Name__c, Source_Field_API_Name__c,
                                                          Target_Object_API_Name__c, Target_Field_API_Name__c,
                                                          (SELECT Id, Source_Value__c, Target_Value__c, 
                                                           Field_Mapping__r.Source_Field_API_Name__c, Field_Mapping__r.Target_Field_API_Name__c 
                                                           FROM Field_Mapping_Values__r)
                                                          FROM Field_Mapping__mdt
                                                          WHERE Source_Object_API_Name__c = :sourceObjType AND Active__c = true];
                    
                    //Loop over the queried field mapping records list
                    for (Field_Mapping__mdt f : fMappings) {
                        
                        String keyField = f.Source_Field_API_Name__c;
                        if (keyField == null) keyField = f.Source_Object_API_Name__c;
                        
                        //Map to hold the field mapping valued for sorce field 
                        map<string, Field_Mapping_Value__mdt> valueMap = fldMappingByFieldByValue.get(keyField);
                        
                        //Check for size else instantiate the map
                        if (valueMap == null) valueMap = new map<string, Field_Mapping_Value__mdt>();
                        
                        //Loop over the child i.e. "field mapping values" records 
                        for (Field_Mapping_Value__mdt fv : f.Field_Mapping_Values__r) {
                            
                            //Populate the map valueMap
                            //system.debug('@@f:' + f);
                            //system.debug('@@fv:' + fv);
                            if (fv != null)
                                valueMap.put(fv.Source_Value__c.toLowerCase(), fv);
                        }
                        
                        //Populate the fldMappingByFieldByValue
                        //system.debug('@@keyField:' + keyField + ' ---valueMap:' + valueMap);
                        //system.debug('@@@objMappingByFieldByValue:' + objMappingByFieldByValue);
                        if (keyField != null) {
                            fldMappingByFieldByValue.put(keyField.toLowerCase(), valueMap);
                        }
                    }
                    //Populate the objMappingByFieldByValue
                    objMappingByFieldByValue.put(sourceObjType, fldMappingByFieldByValue);
                    //system.debug('@@@objMappingByFieldByValue:' + objMappingByFieldByValue);
                }
            }
            
            MappingByFieldByValue = objMappingByFieldByValue.get(sourceObjType);
            
            //return statement
            return MappingByFieldByValue;
        }
        set;
    }
    
    /**
	 * @description: map values from the source field to the target field using field mappings
	 * 
	 **/
    public void mapFieldValue2() {
        string srcFieldValue;
        
        //Map to hold the Source field API NAme as a key with the valuemap [i.e. map that hold the source field value name with field mapped value]
        map<string, map<string, Field_Mapping_Value__mdt>> mapByFieldByVal = MappingByFieldByValue;
        
	//Loop over the mapByFieldByVal key set
        for (string srcKey : mapByFieldByVal.keySet()) {
            
            //get the source/target field values
            for (String srcFieldAPIName : mapByFieldByVal.get(srcKey).keySet()) {
                
                //get the field mapping value record
                Field_Mapping_Value__mdt fldMapping = mapByFieldByVal.get(srcKey).get(srcFieldAPIName);
                
                //11/16/2020 - Victor Hanson - commented out the if statement so the mapping fields are always populated
                //if(targetObj.get(fldMapping.Target_Value__c) == null )
                    //set the source object's field to the mapped value
                    targetObj.put(fldMapping.Target_Value__c, sourceObj.get(fldMapping.Source_Value__c));
            }
        }
    }
        
    //get source field values
    public static Set<String> getFields(String fieldMapDevName) {
        return getFields(fieldMapDevName, 'Source_Value__c');
    }

    //get set of field values
    public static Set<String> getFields(String fieldMapDevName, String fieldAPIName) {
        //Query over the field map and related field mapping values childs records
        list<Field_Mapping__mdt> fMappings = [SELECT Id, Source_Object_API_Name__c, Source_Field_API_Name__c,
                                              Target_Object_API_Name__c, Target_Field_API_Name__c,
                                              (SELECT Id, Source_Value__c, Target_Value__c, 
                                               Field_Mapping__r.Source_Field_API_Name__c, Field_Mapping__r.Target_Field_API_Name__c 
                                               FROM Field_Mapping_Values__r)
                                              FROM Field_Mapping__mdt
                                              WHERE DeveloperName = :fieldMapDevName AND Active__c = true];
        
        Set<String> fieldNames = new Set<String>();
        for (Field_Mapping_Value__mdt fldMapValue : fMappings[0].Field_Mapping_Values__r) {
            if (fldMapValue.get(fieldAPIName) != null) fieldNames.add( (String)fldMapValue.get(fieldAPIName) );
        }
        
        return fieldNames;
    }
}