/*
	Created By: 	Victor Hanson
	
	Summary:		This class is used in the MultiSelectPicklist component.  
					The MultiSelectPicklist component allows a developer to quickly/easily add a multi-select picklist to a visualforce page.
				
	Created Date:	2/28/12
	
	Code Coverage:	95%
*/
public with sharing class MultiSelectPicklistController {
	public string PickerType { get; set; }
	
	public sObject TargetObject{
			get;
			set{
				if(targetObject == null)
				{
					TargetObject = value;
					Init();
				}
			}
	}
	
	public string TargetField{
		get;
		set{
			
			if(TargetField == null)
			{
				TargetField = value;
				Init();
			}
		}
	}
	
	public boolean IsMultiPicklist {get;set;}
	
	public boolean IsRequired {
		get {
			if (IsRequired == null)
				IsRequired = false;
			return IsRequired;
		}
		set;
	}
	
	public String Size {
		get {
			if (Size == null)
				Size = '5';
			return Size;
		}
		set;
	}
	
	public List<String> TargetData {
		get;
		set{
			if(TargetData == null && value != null)
			{
				TargetData = value;
				if (FormattedData == null) {
					FormattedData = new Set<String>();
					for (String s : value) {
						FormattedData.add(s);
					}
				}
					
				Init();
			}
		}
	}
	
	public Set<String> FormattedData {
		get; /*{
			if (FormattedData == null) {
				FormattedData = new Set<String>();
				if (TargetData != null) {
					FormattedData.addAll(TargetData);
				}
			}
			return FormattedData;
		}*/
		set;
	}
	
    @TestVisible
	private void Init()
	{
		system.debug('@@INIT: ');
		// Only init after both critical items have been set.
		if(TargetObject == null || TargetField == null)
			return;
		
		//TODO: Figure out if the field is multi-select or single select.  Dispaly a different picker accordingly.
		leftselected = new List<string>();
        rightselected = new List<String>();
        string SelectedOptions;
        SelectedOptions = (string)TargetObject.get(TargetField);
        	
        if(SelectedOptions != null)
        {
        	for(string pickListVal : SelectedOptions.split(';'))
        		rightValues.add(pickListVal);
        }
        system.debug('@@ in INIT - TargetData:' + TargetData);
        system.debug('@@ in INIT - FormattedData:' + FormattedData);
        system.debug('@@ in INIT - Original Data:' + OriginalValues);
        leftvalues = originalValues.clone();
        leftvalues.RemoveAll(rightValues);
	}
	public MultiSelectPicklistController() {
       IsMultiPicklist = true;
       system.debug('@@OriginalValues:' + OriginalValues);
	}
	
    @TestVisible
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
	
	public static List<String> GetOptions(SObject Main, string FieldName)
	{

		Map<String, Schema.SObjectField> fieldMap = GetFieldDescribeMap(Main);

		try
		{
			Schema.DescribeFieldResult FieldRes = fieldMap.get(FieldName).getDescribe();
			List<Schema.PicklistEntry> PickListList = FieldRes.getPicklistValues();
			//System.debug('GetOptions - PickListList.Size() = ' + PickListList.Size());
			List<String> options = new List<String>();
			for (Schema.PicklistEntry PLE : PickListList)
			{
				options.Add(PLE.getValue());
			}
			//System.debug('GetOptions - options.Size() = ' + options.Size());
			return options;
		}
		catch (Exception exc)
		{
			//throw new Exception('Unable to get the picklist options: ' + exc.getMessage() );
			exc.setMessage('Unable to get the picklist options for Field: ' + FieldName + ': ' + exc.getMessage() );
			throw exc;
		}
	}
	
	private Set<String> originalvalues {
		get{
			if(originalValues == null)
			{
				system.debug('@@OriginalVals');
				if (FormattedData != null)
					originalValues = FormattedData;
				else if (TargetObject != null) {
					String sObjectName = TargetObject.getSObjectType().getDescribe().getName();
					Schema.SObjectType t = Schema.getGlobalDescribe().get(sObjectName);
					SObject newObj = t.newSObject();

					originalValues = new Set<String>( GetOptions(newObj, TargetField) );
				}
					
			}
			return originalValues;
		}
		set;
	}
	
    public List<string> leftselected{get;set;}
 
    public List<string> rightselected{get;set;}
    
    @TestVisible
    Set<string> leftvalues = new Set<string>();
    Set<string> rightvalues = new Set<string>();
 
 	private void UpdateTarget()
 	{
 		string SelectedOptions = '';
        for(string SelectedOption : rightValues)
        	SelectedOptions += SelectedOption + ';';
        TargetObject.put(TargetField,SelectedOptions);
 	}
 
    public PageReference selectclick(){
        rightselected.clear();
        for(String s : leftselected){
            leftvalues.remove(s);
            rightvalues.add(s);
        }
        UpdateTarget();
        return null;
    }
 
    public PageReference unselectclick(){
        leftselected.clear();
        for(String s : rightselected){
            rightvalues.remove(s);
            leftvalues.add(s);
        }
        UpdateTarget();
        return null;
    }
 
    public List<SelectOption> getunSelectedValues(){
        List<SelectOption> options = new List<SelectOption>();
        List<string> tempList = new List<String>();
        system.debug('@@getUnselectedVals: ' + leftValues);
        system.debug('@@OriginalVals: ' + OriginalValues);
        tempList.addAll(leftvalues);
        tempList.sort();
        for(string s : tempList)
            options.add(new SelectOption(s,s));
        return options;
    }
 
    public List<SelectOption> getSelectedValues(){
        List<SelectOption> options1 = new List<SelectOption>();
        List<string> tempList = new List<String>();
        tempList.addAll(rightvalues);
        tempList.sort();
        for(String s : tempList)
            options1.add(new SelectOption(s,s));
        return options1;
    }
}