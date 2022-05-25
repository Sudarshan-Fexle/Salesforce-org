/** @Modified By - Rajeev Jain - 06/28/2016 - SFDC Royall Migration - Migrated from Royall Enviournment to Corporate Instance
 * V1.1 - Modified By - Mahendra SwarnKar - 05/01/2019 - Commented the class as per Spring Clean up - CR-20190501-13061
 * */
public with sharing class DefineRollup 
{
	public boolean isRender {get;set;}
	public string rollupId {get;set;}
	public string rollupName {get;set;}
	public String selectedFunction {get;set;}
	public String selectedChildObject {get;set;}
	public String selectedField {get;set;}
	public string filter {get;set;}
    public static final integer MAX_USER_DEFINED_ROLLUP_LIMIT = 50;
	public List<SelectOption> lstChildObject {get;set;}
	public List<SelectOption> lstFunction {get;set;}
	public List<SelectOption> lstFields {get;set;}
	public List<AddCriteria> lstAddCriteria{get;set;}
	public List<SelectOption> lstADDCriteriaFields;
	public Map<String, Schema.SObjectField> fields;
	public Map<String,AddCriteria> mapStringToAddCriteria;
	public Set<String> numberType;
	public Set<String> stringType {get;set;}
	public Set<String> picklistType;
	public Set<String> booleanType;
	public List<String> lstDateRange {get;set;}
	//Inner Class
	public class AddCriteria
	{
		public String selectedCriteriaField {get;set;}
		public String value {get;set;}
		public String previousValue;
		public string datetimevalue {get;set;}
		public boolean blnCheckbox {get;set;}
		public String fieldName {get;set;}
		public string dataType {get;set;} 
		public string selectedOperator {get;set;}
		public List<SelectOption> lstACOperator {get;set;}
		public List<SelectOption> lstACFields {get;set;}
		public String rowNumber {get;set;}
		//Inner Class Constructor
		public AddCriteria(String rowNumber,List<SelectOption> lstField)
		{
			this.rowNumber = rowNumber;
			value='';
			previousValue = 'None';
			datetimevalue = '';
			dataType = '';
			fieldName = '';
			selectedOperator = '';
			blnCheckbox = false;
			selectedCriteriaField = 'None';
			lstAcOperator = new List<SelectOption>();
			lstACFields = new List<SelectOption>();
			lstACFields.addAll(lstField);
			lstACOperator.add(new SelectOption('None','--None--'));
		}
	}
	//Constructor
	//V1.2 - Modified By - Mahendra SwarnKar - 05/01/2019 - Commented the method as per Spring Clean up - CR-20190501-13061
	public DefineRollUp()
	{
		isRender = true;
		/**** Spring CleanUp CR-20190501-13061 ***
		List<Rollup_Definition__c> lstRollupLimit = [Select Id from Rollup_Definition__c limit : MAX_USER_DEFINED_ROLLUP_LIMIT];
		if(lstRollupLimit.size() == MAX_USER_DEFINED_ROLLUP_LIMIT)
		{
			isRender = false;
			ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO, 'Maximum number of Rollups you can define is 50. You have reached this limit.');
            ApexPages.addMessage(msg);
		}
		else*/
			initialize();
	}
	//Function for intialization of all variable
	/** 

    * \Method initialize() 
    
    * \param none
    
    * \return None
    
    */ 
	private void initialize()
	{
		selectedChildObject = 'None';
		selectedField = 'None';
		filter = '1';
		rollupName = '';
		lstChildObject = new List<SelectOption>();
		lstFunction = new List<SelectOption>();
		lstFields = new List<SelectOption>();
		lstADDCriteriaFields = new List<SelectOption>();
		lstAddCriteria = new List<AddCriteria>();
		numberType = new Set<String>{'INTEGER','DATETIME','DATE','CURRENCY','DOUBLE','PERCENT'};
		stringType = new Set<String>{'STRING','ID','EMAIL','TEXTAREA'};
		picklistType = new Set<String>{'PICKLIST','MULTIPICKLIST'};
		mapStringToAddCriteria = new Map<String,AddCriteria>();
		lstChildObject.add(new SelectOption('None','--None--'));
		lstChildObject.add(new SelectOption('Case','Case'));
		lstChildObject.add(new SelectOption('Contract','Contract'));
		lstChildObject.add(new SelectOption('Opportunity','Opportunity'));
		booleanType = new Set<String>{'BOOLEAN'};
		lstFunction.add(new SelectOption('None','--None--'));
		lstFields.add(new SelectOption('None','--None--'));
		lstADDCriteriaFields.add(new SelectOption('None','--None--'));
		AddCriteria objAddCriteria1 = new AddCriteria('1',lstFields);		
		AddCriteria objAddCriteria2 = new AddCriteria('2',lstFields);		
		AddCriteria objAddCriteria3 = new AddCriteria('3',lstFields);	
		lstAddCriteria.add(objAddCriteria1);lstAddCriteria.add(objAddCriteria2);lstAddCriteria.add(objAddCriteria3);
	}
	//Function for getting field according to selected child object
	/** 

    * \Method getFields() 
    
    * \param none
    
    * \return None
    
    */ 
	public void getFields()
	{
		Schema.DescribeSObjectResult R;
		if(selectedChildObject == 'Case')
			R = Case.SObjectType.getDescribe();
		else if(selectedChildObject == 'Contract')
			R = Contract.SObjectType.getDescribe();
		else if(selectedChildObject == 'Opportunity')
			R = Opportunity.SObjectType.getDescribe();
		if(R != null)
		{
			Map<String,String> mapBetweenFieldLabelToName = new Map<String,String>();
			Map<String,String> mapBetweenAggFieldLabelToAggFieldName = new Map<String,String>();
			lstFields.clear();
			lstADDCriteriaFields.clear();
			lstFields.add(new SelectOption('None','--None--'));
			lstADDCriteriaFields.add(new SelectOption('None','--None--'));
			fields = R.fields.getMap() ;
			for(String field :  fields.keyset())
			{
				Schema.SObjectField f = fields.get(field);
				Schema.DescribeFieldResult r2 = f.getDescribe();
				if(r2.isFilterable())
				{
					if(string.valueOf(r2.getType()) != 'REFERENCE')
					{
						mapBetweenFieldLabelToName.put(string.valueOf(r2.getLabel()),field);
						//lstADDCriteriaFields.add(new SelectOption(field,string.valueOf(r2.getLabel())));
						if(string.valueOf(r2.getType()) != 'BOOLEAN')
						{
							mapBetweenAggFieldLabelToAggFieldName.put(string.valueOf(r2.getLabel()),field);
						}
							//lstFields.add(new SelectOption(field,string.valueOf(r2.getLabel())));
					}
				}
			}
			List<String> lstFieldLabel = new List<String>();
			lstFieldLabel.addAll(mapBetweenFieldLabelToName.keyset());
			lstFieldLabel.sort();
			for(string label : lstFieldLabel)
			{
				lstADDCriteriaFields.add(new SelectOption(mapBetweenFieldLabelToName.get(label),label));
			}
			lstFieldLabel.clear();
			lstFieldLabel.addAll(mapBetweenAggFieldLabelToAggFieldName.keyset());
			lstFieldLabel.sort();
			for(string label : lstFieldLabel)
			{
				lstFields.add(new SelectOption(mapBetweenAggFieldLabelToAggFieldName.get(label),label));
			}
			lstFieldLabel.clear();
			lstAddCriteria.clear();
			AddCriteria objAddCriteria1 = new AddCriteria('1',lstADDCriteriaFields);		
			AddCriteria objAddCriteria2 = new AddCriteria('2',lstADDCriteriaFields);		
			AddCriteria objAddCriteria3 = new AddCriteria('3',lstADDCriteriaFields);		
			lstAddCriteria.add(objAddCriteria1);lstAddCriteria.add(objAddCriteria2);lstAddCriteria.add(objAddCriteria3);
		}
	}
	// Function for getting agg. function according to field selected.
	/** 

    * \Method getFieldByFunction() 
    
    * \param none
    
    * \return None
    
    */ 
	public void getFunctionByField()
	{
		Set<String> sum = new Set<String>{'INTEGER','DECIMAL','DOUBLE','LONG','CURRENCY','PERCENT'};
		Set<String> MaxMin = new Set<String>{'INTEGER','DECIMAL','DOUBLE','LONG','DATETIME','DATE','CURRENCY','PERCENT'};
		if(selectedField != 'None')
		{
			lstFunction.clear();
			lstFunction.add(new SelectOption('None','--None--'));
			lstFunction.add(new SelectOption('count','count'));
			if(fields != null)
			{
				Schema.SObjectField f = fields.get(selectedField);
				Schema.DescribeFieldResult r2 = f.getDescribe();
				if(string.valueOf(r2.getType()) != 'BOOLEAN')
				{
					if(sum.contains(string.valueOf(r2.getType())))
					lstFunction.add(new SelectOption('sum','sum'));
					if(MaxMin.contains(string.valueOf(r2.getType())))
					{
						lstFunction.add(new SelectOption('max','max'));
						lstFunction.add(new SelectOption('min','min'));
					}
				}
			}
		}
	}
	//Function for getting possible operator value according to field selected in add criteria
	/** 

    * \Method getOperatorByField() 
    
    * \param none
    
    * \return None
    
    */ 
	public void getOperatorByField()
	{
		//Loop for getting operator for each field selected
		for(AddCriteria obj : lstAddCriteria)
		{
			if(obj.selectedCriteriaField != 'None')
			{
				//This is for clearing input value field if we change field in field list
				if(obj.previousValue != 'None' && obj.selectedCriteriaField != obj.previousValue)
				{
					obj.value = '';
				}
				obj.previousValue = obj.selectedCriteriaField;
				Schema.SObjectField f = fields.get(obj.selectedCriteriaField);
				Schema.DescribeFieldResult r2 = f.getDescribe();
				obj.dataType = string.valueOf(r2.getType());
				obj.fieldName = string.valueOf(r2.getName());
				//If datatype of field selected is number type
				if(numberType.contains(obj.dataType))
				{
					List<String> operator = new List<String>{'equals','not equals to','less than','greater than','less or equal','greater Or equal'};
					obj.lstACOperator.clear();
					obj.lstACOperator.add(new SelectOption('None','--None--'));
					for(String str : operator)
					{
						obj.lstACOperator.add(new SelectOption(str,str));
					}
				}
				//If datatype of field selected is picklist type
				else if(picklistType.contains(obj.dataType))
				{
					List<String> operator = new List<String>{'includes','excludes'};
					obj.lstACOperator.clear();
					obj.lstACOperator.add(new SelectOption('None','--None--'));
					for(String str : operator)
					{
						obj.lstACOperator.add(new SelectOption(str,str));
					}
				}
				//If datatype of field selected is stringType type
				else if(stringType.contains(obj.dataType))
				{
					List<String> operator = new List<String>{'equals','not equals to','starts with'};
					obj.lstACOperator.clear();
					obj.lstACOperator.add(new SelectOption('None','--None--'));
					for(String str : operator)
					{
						obj.lstACOperator.add(new SelectOption(str,str));
					}
				}
				//If datatype of field selected is booleanType type
				else if(booleanType.contains(obj.dataType))
				{
					List<String> operator = new List<String>{'equals','not equals to'};
					obj.lstACOperator.clear();
					obj.lstACOperator.add(new SelectOption('None','--None--'));
					for(String str : operator)
					{
						obj.lstACOperator.add(new SelectOption(str,str));
					}
				}
			}
			else
			{
				//If selected field is None
				obj.lstACOperator.clear();
				obj.lstACOperator.add(new SelectOption('None','--None--'));
				obj.value = '';
			}
		}
	}
	//Function adding new row in add criteria section
	/** 

    * \Method addRow() 
    
    * \param none
    
    * \return None
    
    */ 
	public void addRow()
	{
		if(lstAddCriteria.size() > 0)
		{
			AddCriteria obj = new AddCriteria(String.valueOf(lstAddCriteria.size()+1),lstADDCriteriaFields);
			lstAddCriteria.add(obj);
		}
	}
	//Function for removing last row in add criteria section if row no. is greater then 3
	/** 

    * \Method removeRow() 
    
    * \param none
    
    * \return None
    
    */ 
	public void removeRow()
	{
		if(lstAddCriteria.size() > 3)
		{
			lstAddCriteria.remove(lstAddCriteria.size()-1);
		}
	}
	//Function for saving created rollup after all required validation checking
	/** 

    * \Method save() 
    
    * \param none
    
    * \return pagereference to object record
    * V1.1 - Modified By - Mahendra SwarnKar - 05/01/2019 - Commented the method as per Spring Clean up - CR-20190501-13061
    
    */ 
	public pagereference save()
	{
		Set<String> queryRow = new Set<String>();
		String query;
		Integer size;
		Integer index = 1;
		//Map between operator name to their corresponding symbol
		Map<String,String> MaOperatorToSymbol = new Map<string,string>{'equals' => '=',
																	   'not equals to' => '!=',
																	   'less than' => '<',
																	   'greater than' => '>',
																	   'less or equal' => '=<',
																	   'greater Or equal' => '=>',
																	   'includes' => 'IN',
																	   'excludes' => 'NOT IN',
																	   'starts with' => 'Like'};
		//Map between row no. in string to criteria selected
		Map<string,string> MapRowToCriteria = new Map<string,string>();
		//Map between row no. in integer to row no in string i.e.{1,'1_1'}
		Map<integer,string> MapRowNoToRow = new Map<integer,string>();
		//Loop for creating above map
		for(AddCriteria obj : lstAddCriteria)
		{
			//If selected criteria field is not none
			if(obj.selectedCriteriaField != 'None')
			{
				//If selected operator field is not none
				if(obj.selectedOperator != 'None')
				{
					String criteria = '';
					String value = '';
					if(booleanType.contains(obj.dataType))
						value = String.ValueOf(obj.blnCheckbox);
					else if(obj.value.length() > 0)
					{
						string escapeSingleQuotesvalue = string.escapeSingleQuotes(obj.value);
						if(stringType.contains(obj.dataType))
						{
							if(MaOperatorToSymbol.get(obj.selectedOperator) == 'Like')
							{
								value = '\'' + escapeSingleQuotesvalue + '%\'';
							}
							else
							{
								value = '\'' + escapeSingleQuotesvalue + '\'';	
							}
						}
						else if(numberType.contains(obj.dataType))
						{
							if(obj.dataType == 'DATETIME' || obj.dataType == 'DATE')
							{
								string tempValue;
								tempValue = escapeSingleQuotesvalue.replaceAll('/','-');
								if(obj.dataType == 'DATETIME')
								{
									value = tempValue + 'T10:00:00Z';
								}
								else
								{
									value = tempValue;
								}
							}
							else
							{
								value = escapeSingleQuotesvalue;
							}
						}
						else if(picklistType.contains(obj.dataType))
						{
							String [] strPickList = escapeSingleQuotesvalue.split(', ');
							for(integer i = 0; i<strPickList.size(); i++)
							{
								if(value == '')
									value = '\'' + strPickList[i].replaceAll('\'','\\\'') + '\'';
								else
									value += ', \'' + strPickList[i].replaceAll('\'','\\\'') + '\'';
							}
							value = '(' + value + ')';
						}
					}
					else
					{
						ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.error, 'Select value in add criteria.');
            			ApexPages.addMessage(msg);
            			return null;
					}
					//Finally creating criteria for each row.
					criteria = string.escapeSingleQuotes(obj.fieldName) + ' ' + MaOperatorToSymbol.get(string.escapeSingleQuotes(obj.selectedOperator)) + ' ' + value;
					//Adding value to map i.e. {'1*1',Criteria}
					string rowNumber = string.escapeSingleQuotes(obj.rowNumber);
					MapRowToCriteria.put(rowNumber+'***|***'+rowNumber,criteria);
					//Adding value to map i.e. {1,'1*1'}
					MapRowNoToRow.put(Integer.valueOf(rowNumber),rowNumber+'***|***'+rowNumber);
				}
				else
				{
					ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.error, 'Select operator in add criteria.');
            		ApexPages.addMessage(msg);
            		return null;
				}
			}
		}
		//There should be atleast one criteria for creting rolup
		if(MapRowToCriteria.keyset().size() == 0)
		{
			ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.error, 'Select atleast one condition in add criteria.');
            ApexPages.addMessage(msg);
            return null;
		}
		query = string.escapeSingleQuotes(filter.trim().toUpperCase());
		size = lstAddCriteria.size();
		//This loop will iterate = size
		for(;;index++)
		{
			string strRow = String.valueOf(index);
			//If filter logic contain that row no.
			if(query.contains(strRow))
			{
				//If criteria belong to that row is not specified
				if(MapRowNoToRow.get(index) != null)
				{
					size = size - 1;				
					query = query.replaceFirst(strRow,MapRowNoToRow.get(index));
					queryRow.add(MapRowNoToRow.get(index));
				}
				else
				{
					ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.error, 'Selected filter logic is not properly defined. Please correct it.');
		            ApexPages.addMessage(msg);
		            return null;
				}
			}		 
			else if(size > 0)
			{
				size = size - 1;
				continue;
			}
			else
				break;
		}
		//Loop for creating final string contains criteria
		for(string str : queryRow)
		{
			if(query.contains(str))
			{
				query = query.replace(str,MapRowToCriteria.get(str));
			}
		}
		string criteria = query;
		//Final query is here
		//string queryTemplate = 'Select {!selctedFunction} ({!selectedField}) from {!selectedChildObject} where {!criteria}';
		//query = queryTemplate.replace('{!selctedFunction}', selectedFunction).replace('{!selectedField}',selectedField).replace('{!selectedChildObject}',selectedChildObject).replace('{!criteria}',query);
		if(selectedFunction != null && selectedField != null && selectedChildObject != null)
			query = 'Select ' + string.escapeSingleQuotes(selectedFunction) + '(' + string.escapeSingleQuotes(selectedField) + ') from ' +  string.escapeSingleQuotes(selectedChildObject) + ' where ' + query;
		
		List<AggregateResult> lstAcc = new List<AggregateResult>();
		try
		{
			//This block is to check whether query generated is correct.
			lstAcc = Database.query(query);
			//If ok? then only will store it in custom object
			/*** Spring CleanUp CR-20190501-13061 ***
			CreateRollup objCreateRollup = new CreateRollup();
			rollupId = objCreateRollup.createRollupDefinition(rollupName, selectedChildObject, selectedField, selectedFunction, criteria);
			*/
			return null;
		}
		Catch(System.DmlException e)
		{
			//If got exception on insert
			system.debug('Error: '+e);
			ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.error, 'Rollup Name already exists.');
            ApexPages.addMessage(msg);
            return null;
		}
		Catch(Exception e)
		{
			//If query is not correct
			system.debug('Error: '+e);
			ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.error, 'Criteria is not properly defined. Please correct it.');
            ApexPages.addMessage(msg);
            return null;
		}
	}
	//Function for getting possible operator value according to field selected in add criteria
	/** 

    * \Method cancel() 
    
    * \param none
    
    * \return None
    
    */ 
	public void cancel()
	{
		initialize();
	}
}