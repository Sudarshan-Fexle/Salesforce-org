/**
    Purpose         :   This controller is to implement the Salesforce Help cases phase 2 functionality.(CR-20150113-8543)
                
    Created By      :   Abhinav Sharma
    
    Created Date    :   20/02/2015
    
    Current Version :   v1
    
    Revision Log    :   v1 - Abhinav Sharma - 02/13/2014 - CR-20150113-8543
		    :	v1.1 - Modified by - Subhash Garhwal - 01/31/2017 - CR-20160121-9555
                        
**/
public class CaseRequestController {
    
    //Properties
    public string usersAffected { get; set; }
    public string individualUserSelectedName {get; set;}
    public string individualUserSelectedID {get; set;}
    public string userToCloneName {get; set;}
    public string userToCloneID {get; set;}
    public string whatValue {get; set;}
    public string businsesCase {get; set;}
    public string reason {get; set;}
    public Date requestedCompletionDate {get; set;}
    public string dummyIndividualUserSelectedName {get; set;}
    public string dummyIndividualUserSelectedID {get; set;}
    public string dummyUserToCloneName {get; set;}
    public string dummyUserToCloneID {get; set;}
    
    //Boolean variable to check if case submitted successfully or not (Will be helpful in rendering on page)
    public Boolean isCaseSuccessfullySubmitted {get; set;}
    
    //Dynamically grab the picklist values for Case.Users_Affected__c picklist
    public List<SelectOption> usersAffectedOptions {
        get {
            if (usersAffectedOptions == null) {
                usersAffectedOptions = new List<SelectOption>();
                
                // add the unique picklist entries to the picklist
                Schema.DescribeFieldResult fieldResult = Case.Users_Affected__c.getDescribe();
                List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                for(Schema.PicklistEntry f : ple) {
                    usersAffectedOptions.add(new SelectOption(f.getLabel(), f.getValue()));
                }
            }
            return usersAffectedOptions;
        }
        set;
    }
    
    //Calling Constructor
    public CaseRequestController() {
        
        //Setting default values for properties
        usersAffected = '';
        individualUserSelectedName = '';
        individualUserSelectedID = '';
        userToCloneName = '';
        userToCloneID = '';
        whatValue = '';
        businsesCase = '';
        reason = '';
        requestedCompletionDate = null;
        dummyIndividualUserSelectedName = '';
        dummyIndividualUserSelectedID = '';
        dummyUserToCloneName = '';
        dummyUserToCloneID = '';
        isCaseSuccessfullySubmitted = false;
    }
    
    /**
        Description     :   Method to hold the logic of "Submit" on the VF page.
        
        Param           :   void
        
        Return          :   void                
    
    **/ 
    public void submit() {
    
        //Making a try to populate and then submit the case instance with the user selected inputs from the VF page
        try {
        
            //Case new instance
            Case caseObj = new Case();
            
            //Populating case new instance with fields values
            
            //Querying for the current user details
            List<User> users = [SELECT Employee_Id__c FROM User 
                                    WHERE IsActive = true AND ID =: Userinfo.getuserId()]; 
            
            //Checking list for size value
            if(users != null && users.size() > 0) {
                
                //List of contacts
                List<Contact> contacts = [SELECT Id FROM Contact WHERE Employee_Id__c != null AND Employee_Id__c != '' 
                                            AND Employee_Id__c =: users[0].Employee_Id__c];
                                            
                //Checking list for null value and size
                if(contacts != null && contacts.size() > 0)
                    caseObj.contactId = contacts[0].Id;
            }
            
            //Individual User Affected
            if(String.isNotBlank(individualUserSelectedID))
                caseObj.Individual_User_Affected__c = ID.valueOf(individualUserSelectedID);
                
            //User to clone
            if(String.isNotBlank(userToCloneID))
                caseObj.User_to_Clone__c = ID.valueOf(userToCloneID);
                
            //Case Description
            caseObj.Description = '';
        
            //User to clone
            if(String.isNotBlank(userToCloneName))
                caseObj.Description += System.Label.CaseRequest_CL5  + ': ' + userToCloneName + '\n';
            else
                caseObj.Description += System.Label.CaseRequest_CL5  + ': ' + '' + '\n';
            
            caseObj.Description += System.Label.CaseRequest_CL6  + ': ' + whatvalue + '\n' +
                                   System.Label.CaseRequest_CL7  + ': ' + businsesCase + '\n' +
                                   System.Label.CaseRequest_CL8  + ': ' + reason + '\n';
                                   
            if(requestedCompletionDate != null) {
                String dateInYYYYMMDDFormat = String.valueOf(requestedCompletionDate).trim().removeEnd(' 00:00:00');
                //Checking and validating date field value before adding it to case description
                if(String.isNotBlank(dateInYYYYMMDDFormat) && dateInYYYYMMDDFormat.split('-').size() == 3) {
                    caseObj.Description += System.Label.CaseRequest_CL9  + ': ' +  dateInYYYYMMDDFormat.split('-')[1] + '/' + dateInYYYYMMDDFormat.split('-')[2] + '/' + dateInYYYYMMDDFormat.split('-')[0] + '\n';
                }
            } else {
                caseObj.Description += System.Label.CaseRequest_CL9  + ': ' + '' + '\n';
            }
            
            if(String.isNotBlank(dummyIndividualUserSelectedName))
                caseObj.Description += System.Label.CaseRequest_CL10  + ': ' + dummyIndividualUserSelectedName + '\n';
            else
                caseObj.Description += System.Label.CaseRequest_CL10  + ': ' + '' + '\n';
            
            if(String.isNotBlank(dummyUserToCloneName))
                caseObj.Description += System.Label.CaseRequest_CL11  + ': ' + dummyUserToCloneName + '\n';
            else
                caseObj.Description += System.Label.CaseRequest_CL11  + ': ' + '' + '\n';
                
            //Other Case fields
            caseObj.Origin = 'Web';
            caseObj.Priority = 'C - Standard';
            caseObj.Status = 'Submitted';
            caseObj.Subject = '';        
            if(String.isNotBlank(whatvalue)) {
                if(whatvalue.trim().length() > 255)
                    caseObj.Subject = whatvalue.trim().subString(0,255);
                else
                    caseObj.Subject = whatvalue.trim();
            }
            caseObj.Case_Category__c = 'Profiles/Roles/Permission Sets';
            
			//v1.1 - Modified by - Subhash Garhwal - 01/31/2017 - CR-20160121-9555 - set type = 'Application Support' instead of 'Salesforce Help'
            caseObj.Type = 'Application Support';
            
            caseObj.Requested_Completion_Date__c = requestedCompletionDate;
            caseObj.Users_Affected__c = usersAffected;
            
            //v1.1 - Added by - Subhash Garhwal - 01/31/2017 - CR-20160121-9555 - fetch the queue "Application Support" instead of "Salesforce_Help"
            //Quering for the "Salesforce Help" queue
            List<Group> queues = [Select ID FROM Group where Type = 'Queue' AND DeveloperName = 'Application_Support'];
            
            //Checking for list size and null value and setting queue as owner of the case record
            if(queues != null && queues.size() > 0)
                caseObj.OwnerID = queues[0].ID;
            
			//v1.1 - Added by - Subhash Garhwal - 01/31/2017 - CR-20160121-9555 -Start - Auto-populate the "IS System" field on the case record with a value equals to "Salesforce"
            
            //Query to get Is System record which is having Salesforce name
            List<IS_System__c> isSystems = [Select Id, Name From IS_System__c Where Name =: Label.Is_System_Name LIMIT 1];
            
            //Assign Is System field on case record
            if(isSystems.size() > 0)
                caseObj.IS_System__c = isSystems[0].Id;
            
            //v1.1 - Added by - Subhash Garhwal - 01/31/2017 - CR-20160121-9555 -Upto here

            //List of record types
            List<RecordType> recordTypes = [SELECT ID FROM RecordType WHERE sObjectType = 'Case' 
                                                AND IsActive = true AND DeveloperName = 'eTech_Support'];
            
            //Checking record type list for size value
            if(recordTypes != null && recordTypes.size() > 0) {
                caseObj.RecordTypeId = recordTypes[0].ID;
                insert caseObj;
                
                //List of cases
                List<Case> cases = [SELECT ID, CaseNumber FROM Case WHERE ID =: caseObj.ID];
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, System.Label.CaseRequest_CL13 + ' ' + cases[0].CaseNumber));
                isCaseSuccessfullySubmitted = true; 
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.CaseRequest_CL12));
                isCaseSuccessfullySubmitted = false;
            }
        } catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            isCaseSuccessfullySubmitted = false;
        }
    } 
}