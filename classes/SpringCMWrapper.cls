/**
 *  Description     :  Class to hold thr SpringCM Wrappers to hold/pass the data
 *
 *  Created By      :  Subhash Garhwal
 *
 *  Created Date    :  05/2/2017
 *
 *  Revision Logs   :   V1.0 - Created - Subhash Garhwal -  Code is written by Victor. Only moved wrapper classes from SpringCMHelper class to this
 **/
public with sharing class SpringCMWrapper {
	
	//Sender class
	public class Sender {
		
		//Vairable
		public String href { get; set; }
    }
    
    //Item class
    public class Item {
		
		//Variables
		public String href { get; set; }
    }
    
    //Document class
    public class Documents {
    	
    	//Variables
        public List<Item> items { get; set; }
        /*public int offset { get; set; }
        public int limit { get; set; }
        public int total { get; set; }*/
    }
    
    //Recipient class
    public class Recipient {
    	
        //Variables
        public String name { get; set; }
        public String email { get; set; }
    }
    
    //ExternalReviewTask class
    public class ExternalReviewTask {
    	
    	//Variables
        public Sender sender {get; set;}
        public Documents documents {get; set;}
        public Recipient recipient {get; set;}
        public List<Recipient> alsoNotify {get; set;}
        public String status {get; set;}
        public DateTime dueDate {get; set;}
        public String emailSubject {get; set;}
        public String emailMessage {get; set;}
        public Boolean addSignature {get; set;}
        public String href {get; set;}
        
        public ExternalReviewTask(String recipientName, String recipientEmail, DateTime dueDate, String documentGUID, String subject, String message, String senderhref, String itemhref) {
            
            //Setup defaults
            Recipient recip = new Recipient();
            
            List<Recipient> alsoNotify = new list<Recipient>();
            
            //Set Properties
            this.dueDate = dueDate;
            this.emailSubject = subject;
            this.emailMessage = message;
            this.addSignature = false; //default to false
            
            //setup the sender
            Sender aSender = new Sender();
            aSender.href = senderhref;
            this.sender = aSender;
            
            //setup docs
            Documents docs = new Documents();
            list<Item> items = new list<Item>();
            Item i = new Item();
            i.href = itemhref + documentGUID;
            items.add(i);
            docs.Items = items;
            this.documents = docs;
            
            //setup primary recipient
            Recipient r = new Recipient();
            r.Name = recipientName;
            r.Email = recipientEmail;
            this.Recipient = r;
            
            //setup additional recipient
            /*Recipient alsoNotifyRecipient = new Recipient();
            alsoNotifyRecipient.name = 'Inbound Email Service';
            alsoNotifyRecipient.email = 'sfadmin@advisory.com';
            alsoNotify.add(alsoNotifyRecipient);
            this.alsoNotify = alsoNotify;*/
        }
        
        public ExternalReviewTask() {}
    }
    
	/**
	 * 
	 * @description: Wrapper class to help set attributes on documents in SpringCM
	 * 
	 **/
    public class AttributeField
    {
        public string AttributeType { get; set; }
        public boolean RepeatingAttribute { get; set; }
        public string Value { get; set; }
    }
    
    public class SalesforceGroup
    {
        public AttributeField Status { get; set; }
        public AttributeField Proposal_GUID { get; set; }
        public SalesforceGroup(string status, string proposalId) {
            
            //set the status
            this.Status = new AttributeField();
            this.Status.RepeatingAttribute = false;
            this.Status.AttributeType = 'DropDown';
            this.Status.value = status;
            //set the proposal id
            this.Proposal_GUID = new AttributeField();
            this.Proposal_GUID.RepeatingAttribute = false;
            this.Proposal_GUID.AttributeType = 'String';
            this.Proposal_GUID.value = proposalId;
        }
    }
    
    public class AttributeGroups
    {
        public SalesforceGroup Salesforce_Group { get; set; }
        public AttributeGroups(string status, string proposalId) {
			this.Salesforce_Group = new SalesforceGroup(status, proposalId);
        }
    }
    
    public class DocAttributeWrapper
    {
        public AttributeGroups AttributeGroups { get; set; }
        public DocAttributeWrapper(string status, string proposalId) {
            this.AttributeGroups = new AttributeGroups(status, proposalId);
        }
    }
    
    public class workflowBody {
        public string Name { get; set; }
        public string Params { get; set; }
        public string Href { get; set; }
        public workflowBody(string workflowName, string parameterString, string fullDocPath) {
            this.Name = workflowName;
            this.Params = '<SF2><root ' + parameterString + '></root></SF2>';
            this.Href = fullDocPath;
        }
    }
}