/* 
Copyright 2017 OpFocus, Inc

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation 
files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, 
modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the 
Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES 
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE 
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR 
IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.				
*/
//V_1.0 Modified By -Abhinav Sharma - 6/5/2020 -  CR-20200524-14104 - Access modifier based changes here for the @auraenabled properties
public with sharing class LightningLookupController 
{
	// Description	: executes the SOQL query and return records.
	// @param 		: sObjectName - name of SObject 
	// @param 		: valueFieldName - name of field from object to use as the value of the pick list 
	// @param 		: displayedFieldName - name of field from object to display in pick list 
	// @param 		: whereClause - optional where clause to add to the SOQL query 
	@AuraEnabled
	public static LookupRecords getRecords(String sObjectName, String valueFieldName, 
                                               String displayedFieldName, String otherFields, String whereClause, String recordId)
	{
        try
        {
            //Modified by - Dipesh Gupta- 04/06/2020 - CR-20200212-13739(Enable users to Clone an existing Job Ticket)
            if(sObjectName == 'Project__c')
            {
                //Set<Id> setOfProjectOnJT = new Set<Id>();
                //Set<Id> setOfAccountOnJT = new Set<Id>();
                Set<Id> setOfProjectInstitutionsId = new Set<Id>();
                LookupRecords retVal = new LookupRecords();
                
                
                for(job_Ticket__c jobTikt : [SELECT ID, Mail_Vendor__c, Project__c, Project__r.Institution__c
                                             FROM Job_Ticket__c 
                                             WHERE Id =: recordId
                                             AND Project__c != null 
                                             AND Project__r.Institution__c != null])
                {
                    //setOfProjectOnJT.add(jobTikt.Project__c);
                    //setOfAccountOnJT.add(jobTikt.Mail_Vendor__c);
                    setOfProjectInstitutionsId.add(jobTikt.Project__r.Institution__c);    
                }
                
                String soql = 'Select ' + valueFieldName + ',' + displayedFieldName;
                soql += otherFields == null || otherFields == '' ? '' : ',' + otherFields;
                soql += ' FROM ' + sObjectName; 
                soql += ' WHERE Institution__c IN : setOfProjectInstitutionsId ';
                //soql += ' AND Id IN : setOfProjectOnJT';
                soql += ' ORDER BY ' + displayedFieldName;
                
                System.debug('@@@ soql'+soql);
                
                SObject[]  lstRec = Database.query(soql);
                
                if(lstRec.isEmpty())
                {
                    retVal.add(DatabaseUtilities.getObjectTypeOnBasisOfObjectName(sObjectName).newSObject(),'','No records found!');
                }
                
                for(SObject obj : lstRec)
                {
                    retVal.add(obj,
                               String.valueOf(obj.get(valueFieldName)), 
                               String.valueOf(obj.get(displayedFieldName)));
                }
                return retVal;
                //End
            }
            else
		{
			if(String.isBlank(valueFieldName) || String.isBlank(displayedFieldName))
			{
				return null;
			}
            LookupRecords retVal = new LookupRecords();
            String soql = 'Select ' + valueFieldName + ',' + displayedFieldName;
            soql += otherFields == null || otherFields == '' ? '' : ',' + otherFields;
            soql += ' FROM ' + sObjectName;
            
            if(String.isNotBlank(whereClause))
            {
                soql += ' WHERE ' + whereClause;
            }
            
            soql += ' ORDER BY ' + displayedFieldName;
            
            SObject[] lstRec = Database.query(soql);
            if(lstRec.isEmpty())
            {
                retVal.add(DatabaseUtilities.getObjectTypeOnBasisOfObjectName(sObjectName).newSObject(),'','No records found!');
            }
            
			for(SObject obj : lstRec)
			{
				retVal.add(obj,
							String.valueOf(obj.get(valueFieldName)), 
							String.valueOf(obj.get(displayedFieldName)));
			}
            
			return retVal;
		}
        }
		catch (Exception ex)
		{
			throw new AuraHandledException('Exception occured:\r\n' + ex.getMessage() + '\r\n' + ex.getStackTraceString() + '\r\n');
		}
	}

	/**
	 * gets the help text from the field
	 * @param  field [Full Name of the field to describe]
	 * @return       [Help text of given field]
	 */
	@AuraEnabled
	public static String getHelpText(String field)
    {
		try
        {
			String[] data = field.split('\\.');
			return DatabaseUtilities.getObjectTypeOnBasisOfObjectName(data[0]).getDescribe().fields.getMap().get(data[1]).getDescribe().getInlineHelpText();
		}
		catch(Exception ex)
        {
			throw new AuraHandledException('Exception occured:\r\n' + ex.getMessage() + '\r\n' + ex.getStackTraceString() + '\r\n');
		}
	}

	/**
	 * gets the object that the given field is a lookup for
	 * NOTE: does not support polymorphic fields
	 * @param  field [Full Name of the field to describe]
	 * @return       [SObject Name of the lookup reference]
	 */
	@AuraEnabled
	public static String getReference(String field)
    {
		try
        {
			String[] data = field.split('\\.');
			Schema.DescribeFieldResult f = DatabaseUtilities.getObjectTypeOnBasisOfObjectName(data[0]).getDescribe().fields.getMap().get(data[1]).getDescribe();
			return f.getReferenceTo()[0].getDescribe().getName();
		}
		catch(Exception ex)
        {
			throw new AuraHandledException('Exception occured:\r\n' + ex.getMessage() + '\r\n' + ex.getStackTraceString() + '\r\n');
		}
	}

	/**
	 * gets the data needed for lookup component based on id provided to the component on init
	 * @param  obj   [SObject API]
	 * @param  objId [Record Id]
	 * @param  label [Search label]
	 * @return       [LookupRecords wrapper]
	 */
	@AuraEnabled
	public static LookupRecords getFieldValue(String obj, String objId, String label)
    {
        try
        {
            if(String.isNotBlank(obj) && String.isNotBlank(objId) && String.isNotBlank(label))
            {
                String q = 'Select Id, ' + label + ' from ' + obj + ' where Id = \'' + objId + '\'';
                LookupRecords retVal = new LookupRecords();
                for(SObject so : Database.query(q))
                {
                    retVal.add(so,(String)so.get('Id'),(String)so.get(label));
                }
                return retVal;
            }
            return null;
        }
		catch(Exception ex)
        {
			throw new AuraHandledException('Exception occured:\r\n' + ex.getMessage() + '\r\n' + ex.getStackTraceString() + '\r\n');
		}
	}

	// Description : Class for return value of getRecords method
	public Class LookupRecords
	{
        @AuraEnabled public List<SObject> lstRecords {get;set;}
		@AuraEnabled public List<String> lstValue {get;set;} // list of values corresponding to the display values
		@AuraEnabled public List<String> lstDisplay {get;set;} // list of display values

		public void add(SObject obj, String value, String display)
		{
			if(lstValue == null)
			{
				lstValue = new List<String>();
			}
			if(lstDisplay == null)
			{
				lstDisplay = new List<String>();
			}
			if(lstRecords == null)
			{
				lstRecords = new List<SObject>();
			}
			lstValue.add(value);	
			lstDisplay.add(display);
			lstRecords.add(obj);
		}
	}
}