/**
    Purpose			:	Controller class to hold the logic related to "MemberSupport_Accept_Issue" visualforce page.
                
	Created By		:	Abhinav Sharma
    
    Created Date	:   03/31/2016
    
    Current Version	:	v1.0
    
    Revision Log	:	v1.0 - Created - CR-20160224-9632 - 03/31/2016
						v1.1 - Modified By - Abhinav Sharma - 04/04/2017 - CR-20161228-10578
                        
**/
public without sharing class MemberSupportController {
    
    //Member Support
    public Site_Issue__c siteIssue {get; set;}
    
    //Case
    public Case caseObj {get; set;}
    
    //Standard Controller
    public MemberSupportController(ApexPages.StandardController controller) {
        
        //Initialization and memory allocation to record instances
        siteIssue = (Site_Issue__c)controller.getRecord();
        caseObj = new Case();
        
        //Checking member support instance for null value
        if(siteIssue != null) {
            
            List<Case> cases = [SELECT ID, Tier_MS__c, Status, Project_Source_MS__c, 
                                OwnerId, Tier_I_Support_Analyst__c, Tier_II_Support_Analyst_Contact__c
                                FROM Case 
                                WHERE Member_Support_Ticket__c != null 
                                AND Member_Support_Ticket__c =: siteIssue.Id LIMIT 1];
            if(cases.size() > 0) 
            {
                caseObj = cases[0];
            }
        }
    }  
    
    //Checking for the potentials errors that can occur as a result of "Accept Issue" button
    public boolean acceptButtonError {
        
        get { 
            
            //Setting boolean flag value to false
            acceptButtonError = false;
            
            //Checking for closed case status and accordingly adding an error message on the page
            if (caseObj != null && caseObj.Status == Constants.CASE_STATUS_90_CLOSED)
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.ERROR_CASE_CLOSED_ACCEPT_BUTTON));
            
            //Checking "Tier I Support Analyst" field for non null value and accordingly adding a message on the page
            if(caseObj.Tier_I_Support_Analyst__c != null 
            	&& caseObj.Tier_II_Support_Analyst_Contact__c == null
              	&& caseObj.Tier_MS__c == Constants.SITE_ISSUE_TIER_I)
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.ERROR_ASSIGNED_TO_TIER_I_ANALYST_ACCEPT_BUTTON));
            
            //Checking for error message existance on the page
            if (apexPages.getMessages().size() > 0)
                acceptButtonError = true;
            
            //Returning boolean flag value
        	return acceptButtonError;
        }
        set;
    }
   
    //Get the project's technical project manager
    public Id projectManagerId {
    	
        get {
        	    
            //Checking for the null value
        	if (projectManagerId == null && caseObj != null) {
          		
                //try to get the technical manager from the project
              	list<Project__c> projects = [SELECT Id, Project_Manager__c
                             					FROM Project__c 
                             					WHERE Id = :caseObj.Project_Source_MS__c 
                                             	AND Project_Manager__c != null];
              	
                //Checking list for it's size and null value
              	if (projects != null && projects.size() > 0) {
              		projectManagerId = projects[0].Project_Manager__c;
              	}
        	}
            
            //Returning project manager Id value
        	return projectManagerId;
      	}
        set;
    }
    
    //Get the user name value associated as "Technical Project Manager"
    public String projectTPM {
        
        get {
        	
            //Checking for the null value
            if (projectTPM == null) {
                
                //pull the user associated with the Technical Project Manager
                list<User> users = [SELECT Id, Name
                                  	FROM User
                                  	WHERE Id = :projectManagerId];
                
                //Checking list for it's size and null value
                if (users != null && users.size() > 0) {
                    projectTPM = users[0].Name;
                }
            }
            
            //Returning name value
            return projectTPM;
    	} 
        set;
    }
    
    //Method to hold the logic that will execute when an user will click on the "Accept Issue" button the MS detail page
    public Pagereference acceptIssue() {
        
        if(caseObj != null && caseObj.Id != null) 
        {
            //Set a savepoint in case the memSupport upserts but caseObj errors
            SavePoint spac = Database.setSavePoint();
            
            try {
                
                //checks to make sure that Tier is = Tier I and the Case is not Closed
                if (acceptButtonError) return null;
                
                //Set the member support owner to Tier II Support Queue
                siteIssue.OwnerId = Constants.tier2SupportQueue.Id;
                
                //set the case owner to Tier II Support Queue
                caseObj.OwnerId = Constants.tier2SupportQueue.Id;
                siteIssue.Tier__c = Constants.SITE_ISSUE_TIER_II;
                
                //Querying for the current user details
                List<User> users = [SELECT Employee_Id__c FROM User 
                                    WHERE IsActive = true AND ID =: Userinfo.getuserId()];
                
                //Checking list for size value
                if(users != null && users.size() > 0) {
                    
                    //List of contacts
                    List<Contact> contacts = [SELECT Id FROM Contact WHERE Employee_Id__c != null AND Employee_Id__c != '' 
                                              AND Employee_Id__c =: users[0].Employee_Id__c];
                    
                    //Checking list for null value and size
                    if(contacts != null && contacts.size() > 0) {
                        
                        if(siteIssue.Assigned_To_Contact__c == null) {
                            siteIssue.Assigned_To_Contact__c = contacts[0].Id;
                            caseObj.Tier_II_Support_Analyst_Contact__c = contacts[0].Id;
                        } else {
                            if(siteIssue.Assigned_To_Contact__c != contacts[0].Id)
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.ERROR_ISSUE_ALREADY_ASSIGNED));	        
                        }
                    } else {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.ERROR_NO_ASSIGNED_TO_CONTACT_EXISTS));
                    }
                }  
                
                //Get all record types on case object
                Map<String, Id> caseRecordTypesMap = Util.recordtypemap('Site_Issue__c');
                
                //Retrieving "CCA Data Load" record type Id from the map
                Id cCADataLoadRecordTypeId = caseRecordTypesMap.get('CCA Data Load');
                
                //Retrieving "Crimson Support Request" record type Id from the map
                Id crimsonSupportReqRecordTypeId = caseRecordTypesMap.get('Crimson Support Request');
                
                //Checking for the boolean variable value
                if(siteIssue.Date_Time_Acknowledged__c == null) {
                    
                    //Modified By - Abhinav Sharma - 04/04/2017 - CR-20161228-10578
                    //On the CCA Data Load (Member Support) ticket, when the Accept Issue button is clicked, 
                    //set Member Support ticket Status to '01 - Awaiting Files'
                    if(cCADataLoadRecordTypeId != null 
                       && siteIssue.RecordTypeId != null 
                       && siteIssue.RecordTypeId == cCADataLoadRecordTypeId)
                        siteIssue.Status__c = '01 - Awaiting Files';
                    else
                        caseObj.Status = System.Label.ACKNOWLEDGED_STATUS;
                    //caseObj.Status = Constants.CASE_STATUS_10_IN_PROGRESS;
                    
                    //Set the Technical Project Manager as Technical Project Manager from associated Project
                    siteIssue.Technical_Project_Manager_new__c = projectTPM;
                    
                    //Date/Time Acknowledged" field on MS record will only populate 
                    //if it is previously having blank/null value with it
                    if(siteIssue.Date_Time_Acknowledged__c == null)
                        siteIssue.Date_Time_Acknowledged__c = System.now();
                    
                    //Setting "Button Used" flag to true to bypass the status and owner change validation code logic
                    siteIssue.Button_Used__c = true;
                    //Spring Clean Up - caseObj.Button_Used__c = true;
                    
                    //Update records
                    CaseTriggerHelper.syncRecordTypeIds = null;
                    update siteIssue;
                    CaseTriggerHelper.syncRecordTypeIds = null;
                    update caseObj;
                    
                } else {
                    
                    if(crimsonSupportReqRecordTypeId != null 
                       && siteIssue.RecordTypeId != null 
                       && siteIssue.RecordTypeId == crimsonSupportReqRecordTypeId)
                        caseObj.Status = Constants.CASE_STATUS_10_IN_PROGRESS;
                    
                    //Setting "Button Used" flag to true to bypass the status and owner change validation code logic
                    siteIssue.Button_Used__c = true;
                    //Spring clean Up - caseObj.Button_Used__c = true;
                    
                    //Update records
                    CaseTriggerHelper.syncRecordTypeIds = null;
                    update siteIssue;
                    CaseTriggerHelper.syncRecordTypeIds = null;
                    update caseObj;
                }
            } catch(DMLException ex) {
                
                //Return errors to the VF Page
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getDMLMessage(0)));
                
            } catch(Exception ex) {
                
                //Return errors to the VF Page
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
                
            }
            
            //if there are errors, revert back to the original save point
            if (apexPages.getMessages().size() > 0) {
                
                //Rollback the transaction
                database.rollback(spac);
                return null;
                
            }
            
            //return to the standard case detail page
            return new ApexPages.StandardController(siteIssue).view();        
        }
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.NO_Case_Associated));
            return null;
        }    
    }
}