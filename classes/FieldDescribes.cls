// This class will cache field describes for different objects so we don't end up 
// going over our field describe limits.
public with sharing class FieldDescribes {
    
    private static Map<string,Map<String, Schema.SObjectField>> cachedDescribes;
    
    public static Map<String, Schema.SObjectField> GetFieldDescribeMap(sObject inputObject) {
        if(inputObject == null)
            return null;
        // Get the name of the object we are looking for...
        Schema.DescribesObjectResult sdsor = inputObject.getSObjectType().getDescribe();
        string ObjectName = sdsor.getName();
        // First time through, initialize the map.
        if(cachedDescribes == null)
            cachedDescribes = new Map<string,Map<String, Schema.SObjectField>>();
        // If the object map has not been asked for, build the map
        if(!cachedDescribes.containsKey(ObjectName))
            cachedDescribes.put(ObjectName,sdsor.fields.getMap());
        // return the cached object field map
        return cachedDescribes.get(ObjectName);
    }
    
    private static testmethod void testFieldDescribesCaching()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        // Ask for the 'prospect' fields a couple of times.
        OpportunityLineItem prosp = new OpportunityLineItem();
        FieldDescribes.GetFieldDescribeMap(prosp);
        // Check that one describe has been used.
        system.assertequals(1,limits.getFieldsDescribes());
        Account app = new Account();
        FieldDescribes.GetFieldDescribeMap(app);
        // Check that two describes have been used.
        system.assertequals(2,limits.getFieldsDescribes());
        
        // Build a new prospect and describe it, should still only see two describes.
        OpportunityLineItem prosp2 = new OpportunityLineItem();
        FieldDescribes.GetFieldDescribeMap(prosp2);
        
        // Check that no more describes have been used.
        system.assertequals(2,limits.getFieldsDescribes());
        
    }
    
    public static List<string> AllFieldsList {
		get{
			Map<String, Schema.SObjectField> fields = FieldDescribes.GetFieldDescribeMap(new Restrictions__c());
			return new List<string>(fields.keySet());
		}
	} 
	
	// get all fields on the object so that we can safely use field sets
	public static string AllFields(String sObjectName, Set<String> extraFields) {
		Schema.SObjectType objectType = Schema.getGlobalDescribe().get(sObjectName);
		SObject newObject = objectType.newSObject();
		
		String AllFields = ''; 
		Map<String, Schema.SObjectField> fields = FieldDescribes.GetFieldDescribeMap(newObject);
		Set<String> fieldSet = fields.keySet();
		for(String s:fieldSet)
        {
            SObjectField fieldToken = fields.get(s);
            DescribeFieldResult selectedField = fieldToken.getDescribe();
            AllFields +=(selectedField.getName() + ',');
        }
        if (extraFields != null) {
        	// Add some references to parent objects that we commonly need.
	        for(String s : extraFields) 
	        	AllFields += s + ',';
        }
        
        
        // Remove the last comma.
        AllFields = AllFields.substring(0,AllFields.length()-1);
		return AllFields;
	}
	
	public static string FullItemBaseQuery(String sObjectName, Set<String> extraFields) {
		String FullItemBaseQuery = 'SELECT ' + AllFields(sObjectName, extraFields);
		FullItemBaseQuery += ' FROM ' + sObjectName;
		return FullItemBaseQuery;
	}
}