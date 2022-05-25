/**
 *  Description     :   Controller class of visualforce component "DisplayFieldsOnStandardPageLayout".
 * 
 *  Created By      :   Abhinav Sharma    
 * 
 *  Created Date    :   02/10/2016
 * 
 *  Current Version :   V_1.0
 * 
 *  Revision Logs   :   V_1.0 - Created - Abhinav Sharma - CR-20150909-9231
 * 			V_1.1 - Modified by - Mahendra Swarnkar - CR-20160301-9657 - 10/14/2016 - Program name is replaced with list of program acronyms for getting eligible Membership
 *			V_1.2 - Comment By - Mahendra Swarnkar - CR-20200218-13769
 * 
**/ 
public class DisplayFieldsOnStandardPageLayoutCon {
    
    //Properties
    
    //Object Name String Variable
	public string objectNameStr {get; set;}
    
    //Field Set Name String Variable
    public string fieldSetNameStr {get; set;}
    
    //Parent Record Id value string variable
    public string parentIdValueStr {get; set;}
    
    //Order by Clause field name string variable
    public string orderByFieldStr {get; set;}
    
    //Varible to hold the direction value for the order by clause
    public string orderByDirectionStr {get; set;}
    
    //Variable to hold the page block section column count value
    public integer pageBlockSectionCnt {get; set;}
    
    //SObject List
    List<SObject> sObjectList;
    
    /**
     *  @description    :   Getter setter to return fields list for a specific field set
     * 
     *  @args           :   
     * 
     *  @return         :   List<Schema.FieldSetMember>
     * 
    **/ 
    public List<Schema.FieldSetMember> fieldSetFieldsList {
        
        get { 
        	
            //Checking for null value
            if(fieldSetFieldsList == null) {

                //Memory allocation to the list
                fieldSetFieldsList = new List<Schema.FieldSetMember>();

                //Overall Schema described information map
                Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
                
                //Specific object related schema 
                Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(objectNameStr);
                
                //Describing specific object schema to get the related informations
                Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
                
                //Getting field set related schema
                Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetNameStr);
                
                //Checking for the null value
                if(fieldSetObj != null) {
                    
                	//Retruning field set associated field list as return type
                	fieldSetFieldsList = fieldSetObj.getFields();
                }
                
                //memory allocation to sObject instance list
                sObjectList = new List<SObject>();
        	}
            return fieldSetFieldsList;
        }    
        set;
    } 
    
    /**
     *  @description    :   Getter setter method to retrieve and return field set associated fields details for a specified sObject instance.
     * 
     *  @args           :   
     * 
     *  @return         :   SObject
     * 
    **/ 
    //SObject Instance
    public SObject sObjectInstance {
        
        get { 
            
            //SOQL Query String
            String query = 'SELECT ';
            
            //Query string temp variable
            String queryStr = '';
            
            //Loop through Field Set associated fields and appending then into the SOQL query string
            for(Schema.FieldSetMember f : fieldSetFieldsList) {
               queryStr += f.getFieldPath() + ', ';
            }    
            
            //Checking if fields are added to the specified field set
            if(queryStr != '') {
                
                //Checking for the parent Id value
                if(String.isNotBlank((parentIdValueStr))) {
                    
                    //Checking for "orderByFieldStr" is specified or not
                    if(String.isNotBlank(orderByFieldStr)) {
                        
                        //Checking if user passed field set name is "QA Call Fields"
                        if(fieldSetNameStr.equalsIgnoreCase(System.Label.QA_Call_Fields)) {
                        	
                        	//Checking if parent ID is of membership object
                        	if(ID.valueOf(parentIdValueStr).getSObjectType() == Schema.Membership__c.SobjectType) {
                        		
                                //V_1.2 - Modified by - Mahendra Swarnkar - CR-20160301-9657 - 10/14/2016 - List to hold eligible program acronyms
                                List<String> eligibleProgramAcronyms = System.Label.ELIGIBLE_PROGRAM_ACRONYMS_FOR_MEMBERSHIP.split(',');
                                
                                //V_1.2 - Modified by - Mahendra Swarnkar - CR-20160301-9657 - 10/14/2016 - Program Name replaced with eligible program acronyms
                        		//Map of memberships
                            	Map<Id, Membership__c> mapMemberships = new Map<Id, Membership__c>([SELECT ID, Program__c, Program__r.Name 
								                    													FROM Membership__c
								                                                                        WHERE Program__c != null 
								                                                                        AND ID =: parentIdValueStr
								                                                                        //AND Program__r.Name =: System.Label.MEMBERSHIP_PROGRAM_FOR_LAST_QA_CALL_FIELDS
								                                                                        AND Program__r.Program_Acronym__c IN : eligibleProgramAcronyms]);    
                                            
                                                                                
                            	//Checking for same key existance in map of membership
                                if(mapMemberships != null && mapMemberships.keySet().size() > 0) {
                                	
                                	//List of events
                            		List<Event> events = new List<Event>();
                            
		                            //Get all record types on event object
		        					Map<String, Id> eventRecordTypesMap = Util.recordtypemap(DisplayFieldsOnStdPageLayoutConstants.EVENT_OBJECT);
                            
		                            //Set to hold the eligible record type IDs
		                            Set<Id> eligibleEventRecordTypes = new Set<Id>();
		                            
		                            //Looping over map keyset and accordingly populating collection with map retrieved values
		                            for(String recordTypeLabel : eventRecordTypesMap.keySet()) {
		                                if(recordTypeLabel != null 
		                                	&& recordTypeLabel.equalsIgnoreCase(DisplayFieldsOnStdPageLayoutConstants.EVENT_RECORD_TYPE_PT_QA_CALL)
		                            		&& eventRecordTypesMap.get(recordTypeLabel) != null	
		                                )
		                                	eligibleEventRecordTypes.add(eventRecordTypesMap.get(recordTypeLabel));	    
		                            }
                            
		                            //Checking set for size value
		                            if(eligibleEventRecordTypes.size() > 0) {
                                
		                                //Setting default value for the "orderByDirectionStr" variable, if having null value with it
		                                if(orderByDirectionStr == null)
		                                	orderByDirectionStr = 'DESC';
                                
		                    			//Retrieving the most recent activity (Start Date - DESC) record details 
		                                //where Record Type = PT QA Call AND
		                                //it is associated with the Primary Paid Membership record
		                                String soqlStr = 'SELECT Id, StartDateTime, Grade__c, Would_Refer__c, ';
		                                soqlStr += 'Would_Buy_Again__c, WhatId FROM Event ';
		                                soqlStr += 'WHERE WhatId != null AND WhatId =: parentIdValueStr ';
		                                soqlStr += 'AND Cancelled_Did_Not_Occur__c = false AND ';
		                                soqlStr += 'RecordTypeId IN : eligibleEventRecordTypes ';
		                                soqlStr += 'ORDER By ' + orderByFieldStr + ' ' + orderByDirectionStr + ' '  + 'LIMIT 1';
		                                events = Database.query(soqlStr);
                                
		                                //Checking events list for size value
		                                if(events.size() > 0) {
		                                	
                                            //Modified by Mahendra Swarnakar - CR-20200218-13769 - 05/05/2020 -last_qa_call_date__c,Last_QA_Call_Grade__c,
                                            //last_qa_call_would_recommend__c,Last_QA_Call_Would_Renew__c deleted
		                                	//Populating fields values on Membership instance
                                            Membership__c mem = new Membership__c(/*Last_QA_Call_Date__c = Date.valueOf(events[0].StartDateTime),
                                                                                 Last_QA_Call_Grade__c = events[0].Grade__c,*/ 
                                                                                 /*Last_QA_Call_Would_Recommend__c = events[0].Would_Refer__c,
                                                                                 Last_QA_Call_Would_Renew__c = events[0].Would_Buy_Again__c*/);
                                            
                                            //Adding membership instance to the list of sObjects               	
                                            sObjectList.add(mem); 
                          
                                            //Returning the sObject instance   
                                            return sObjectList[0];
                                            
		                                } else {
		                                	//Modified by Mahendra Swarnakar - CR-20200218-13769 - 05/05/2020 -last_qa_call_date__c,Last_QA_Call_Grade__c,
		                                	//last_qa_call_would_recommend__c,Last_QA_Call_Would_Renew__c deleted
		                                	//Populating fields values on Membership instance
	                                		Membership__c mem = new Membership__c(/*Last_QA_Call_Date__c = null,
	                                                                     Last_QA_Call_Grade__c = null,*/ 
	                                                                     /*Last_QA_Call_Would_Recommend__c = null,
	                                                                     Last_QA_Call_Would_Renew__c = null*/);
                                            
		                                    //Adding membership instance to the list of sObjects               	
		                                    sObjectList.add(mem); 
		                          
		                                    //Returning the sObject instance   
		                                    return sObjectList[0];
                                        }	
                            		
                            		} else {
                            			//Modified by Mahendra Swarnakar - CR-20200218-13769 - 05/05/2020 -last_qa_call_date__c,Last_QA_Call_Grade__c,
                            			//last_qa_call_would_recommend__c,Last_QA_Call_Would_Renew__c deleted
                            			//Populating fields values on Membership instance
                                		Membership__c mem = new Membership__c(/*Last_QA_Call_Date__c = null,
		                                                                     Last_QA_Call_Grade__c = null,*/ 
		                                                                     /*Last_QA_Call_Would_Recommend__c = null,
		                                                                     Last_QA_Call_Would_Renew__c = null*/);
                                            
	                                    //Adding membership instance to the list of sObjects               	
	                                    sObjectList.add(mem); 
	                          
	                                    //Returning the sObject instance   
	                                    return sObjectList[0];
                            		}	
                                
                                } else {
	                	        	//Modified by Mahendra Swarnakar - CR-20200218-13769 - 05/05/2020 -last_qa_call_date__c,Last_QA_Call_Grade__c,
	                	        	//last_qa_call_would_recommend__c,Last_QA_Call_Would_Renew__c deleted
	                	        	//Populating fields values on Membership instance
	                                Membership__c mem = new Membership__c(/*Last_QA_Call_Date__c = null,
	                                                                     Last_QA_Call_Grade__c = null,*/ 
	                                                                     /*Last_QA_Call_Would_Recommend__c = null,
	                                                                     Last_QA_Call_Would_Renew__c = null*/);
                                            
                                    //Adding membership instance to the list of sObjects               	
                                    sObjectList.add(mem); 
                          
                                    //Returning the sObject instance   
                                    return sObjectList[0];
                                } 	   
                            } else {
                            	return null;
                            }	
                        } else {
                            
                            //Setting default value for the "orderByDirectionStr" variable, if having null value with it
                            if(orderByDirectionStr == null)
                                orderByDirectionStr = 'DESC';
                                
                            //Concatinating query string's to build a complete SOQL string literal. 
                    		query = queryStr +  ' Id FROM ' + objectNameStr + ' WHERE Id = : parentIdValueStr ';
                            query += 'ORDER By ' + orderByFieldStr + ' ' + orderByDirectionStr + ' '  + 'LIMIT 1';
                            
                            //Fetching record details from the database and additing it's instance to the list of sObjects               	
                            sObjectList.addAll(Database.query(query)); 
                      
                            //Returning the sObject instance   
                            return sObjectList[0];
                        }
                    } else {
                    
                        //Concatinating query string's to build a complete SOQL string literal. 
                    	query += queryStr +  ' Id FROM ' + objectNameStr + ' WHERE Id = : parentIdValueStr';
                        
                        //Fetching record details from the database and additing it's instance to the list of sObjects               	
                    	sObjectList.addAll(Database.query(query)); 
                  
                        //Returning the sObject instance   
                        return sObjectList[0];
                	}
                } else {
                    return null;
                }
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, System.Label.ERROR_NO_FIELDS_ADD_TO_FIELD_SET));
            	return null;
            }
        } 
        set;         
	}
}