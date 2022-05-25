/**
 *  Description     :   Helper class for Trigger_ValueType trigger.
 *
 *  Created By      :   Subhash Garhwal 
 *
 *  Created Date    :   09/10/2015
 *
 *  Revision Logs   :   V_1.0 - Created - CR-20150825-9182
 *						
 **/
public without sharing class ValueTypeTriggerHelper {

	/**
     *	@description	:	This method is used to set all fields to blank when use as value is true or changed
     *
     *	@args			:	List<Value_Type__c> , Map<Id, Value_Type__c> 
     *
     *	@return			:	void
     *
     **/
	public static void reNameStaffHistory(List<Value_Type__c> valueTypes, Map<Id, Value_Type__c> mapValueTypes)	{
		
		/*
        //Set of value type ids
		Set<Id> setVTypeIds = new Set<Id>();			

		//Loop through value type
		for(Value_Type__c vT : valueTypes) {
		
			//Check when use as value field is true and field is changed
			if(vT.Use_As_Value__c && (vT.Use_As_Value__c != mapValueTypes.get(vT.Id).Use_As_Value__c || vT.Name != mapValueTypes.get(vT.Id).Name))
				//Add Id in sets
				setVTypeIds.add(vT.Id);
		}
		
		//Check for set size
		if(setVTypeIds.size()> 0) {
		
			//Loop Through staff History.
    		List<Staff_History__c> staffAttributes = [Select Id, Name, Text_Value__c, Checkbox_Value__c, Number_Value__c, Percent_Value__c, Date_Value__c, Lookup_Value__c,
    								   	              Value_Type__c, Value_Type__r.Name From Staff_History__c Where Value_Type__c IN : setVTypeIds];
    	
			//Check list size
			if(staffAttributes.size() > 0)
				update staffAttributes;
		}
	*/
	}
}