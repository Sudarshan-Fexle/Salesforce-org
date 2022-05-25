/*
 *  Purpose         :   This class is Controller class for "OABWarmLeadInfoSiteForm" vf page.
 *
 *  Create By       :   Simplyforce Technology(Mahendra Swarnkar)
 *
 *  Created Date    :   05/19/2017
 *
 *  Revision Log    :   V_1.0 Created 
 * 						V_1.1 -Modify BY - Mahendra Swarnakar - 07/21/2017 - CR-20170720-11089 - Added a new Method "sentNotificationToOABTeam"
 *                      
 **/
public without sharing class OABWarmLeadInfoSiteFormController {
	
    //SObject Instance
    public Warm_Lead__c warmLeadObj {get; set;}
    public String yourName  {get; set;}
    public String cityStateName  {get; set;}
    public String errorMessage  {get; set;}
    public Boolean isIntroduce {get; set;}
	public String contactTitle  {get; set;}	
    public String warmLeadName;
    public Contact warmLeadContact;
    
    //Standard controller constructor
	public OABWarmLeadInfoSiteFormController(ApexPages.StandardController controller) {
		
        //Getting/Reteriving current context Warm Lead record details
        warmLeadObj = (Warm_Lead__c) controller.getRecord();
        
         yourName = '';
        cityStateName = '';
        contactTitle = '';
        warmLeadName = '';
	}
    
    //Method to validate the warm lead record
    public void validateWarmLeadData() {
        
        //Default Error message string
    	errorMessage = 'Please populate the following required Field values :- \n';
        String requiredFields = '';
        
        //Check for the size
        if(warmLeadObj != null ) {
          
            //check for value
            if(string.isBlank(yourName)){
                
                //Error Message for "Your Name"
                requiredFields =  requiredFields + 'Your Name, ';  
            } 
            
            //Error Message for Account 
            if(warmLeadObj.Account__c == null) {
                requiredFields =  requiredFields + 'Institution, ';
            }
            
            //Error Message for Contact
            if(warmLeadObj.Contact__c == null) 
                requiredFields =  requiredFields + 'Contact, ';
            
            //Error Message for Program/ 
            if(warmLeadObj.Primary_Program__c == null) 
                requiredFields =  requiredFields + 'Area/Program of Interest, ';
            
            //Error Message for Lead Details
            if(String.isBlank(warmLeadObj.Comments__c)) 
                requiredFields =  requiredFields + 'Lead Details';
            
            if(String.isNotBlank(requiredFields)){
            	
                //Identify (,) in error message
                String identifyComma = requiredFields.substring(requiredFields.length()-2,requiredFields.length()-1);
                System.debug('Check Comma Error :: ' + identifyComma);
                if(identifyComma.equalsIgnoreCase(','))
                	requiredFields = requiredFields.substring(0,requiredFields.length()-2);
                System.debug('Required field :: ' + requiredFields);
                requiredFields = requiredFields + '.';
            }
            
            //populate default Warm lead field values
            warmLeadObj.Name = warmLeadName; 
        	warmLeadObj.RecordTypeId = Util.RecordTypeId('Warm_Lead__c', 'OAB');
            warmLeadObj.OAB_Lead_Type__c = isIntroduce ? 'Introduction - No Direct Request' : null; 
			warmLeadObj.Qualification_Status__c = 'Unqualified'; 
            warmLeadObj.Lead_Date__c = Date.today();
            warmLeadObj.Lead_Channel__c = 'Direct to Visit';
            warmLeadObj.Status__c = 'Retained by Strategic Marketing';
            
            //User Rese Chorpening Id should be in the Label
            warmLeadObj.Marketer_Assignment__c = System.Label.MarketerAssignmetOnWarmLead;
            
            //Check for size
            if(String.isBlank(requiredFields) ) {
                
                 if(String.isNotBlank( yourName)) {
                  
                    //Append the Your Name in the comment Field 
                    warmLeadObj.Comments__c =   'Passer Name: ' + yourName+ '<br/>' + (String.isNotBlank( warmLeadObj.Comments__c) ? warmLeadObj.Comments__c : '');
           		 }
                
                //Method call to save the Warm lead record 
                save();
                
                //Method call to sent the Email notification to OAB Team.
                sentNotificationToOABTeam();
                
                //Reset the default values
                warmLeadObj = new Warm_Lead__c();
                yourName = '';
                cityStateName = '';
                contactTitle = '';
                warmLeadName = '';
            }
            else {
                ApexPages.addMessage(new ApexPages.message(ApexPages.SEVERITY.ERROR, errorMessage + requiredFields ));
            }
        }
    }
    
	//Method to save the records
    public void save() {
    	
        //Check for size
        if(warmLeadObj != null) {
        	
            //Try-catch block to handle any type of DML Exception
            try {
                
                //Insert Warm lead
                insert warmLeadObj;
                
                ApexPages.addMessage(new ApexPages.message(ApexPages.SEVERITY.INFO, 'Record Saved successfully'));
            }
            catch(Exception ex) {
                
                ApexPages.addMessage(new ApexPages.message(ApexPages.SEVERITY.ERROR, (ex.getMessage() + ex.getCause() + ex.getLineNumber())));
            }
        }
    }
    
    //Method to get the City and State
    public void getAccount() {
        
        cityStateName = '';
        
        //Check for size
        if(warmLeadObj != null && warmLeadObj.Account__c != null) {
            
			//Get the acount record
        	List<Account> acc = [Select Id, Name, Primary_City__c, Primary_State_Province__c From Account where Id =: warmLeadObj.Account__c Limit 1];
            
            if(acc != null && acc.size() > 0 ) {
                
                //Populate the City/State name
                cityStateName = (String.isNotBlank(acc[0].Primary_City__c) ? acc[0].Primary_City__c: '')  + ',' + (String.isNotBlank(acc[0].Primary_State_Province__c) ? acc[0].Primary_State_Province__c : '' );    
                    if(cityStateName.trim() == ',' )
                        cityStateName = '';
                
                	//Populate the Warm lead Name
                    warmLeadName = (''+ Date.today() + ' - ' + acc[0].Name).trim();
                    if(warmLeadName.length() > 80)
                        warmLeadName = warmLeadName.substring(0, 79);
                
            }
		}
    }
    
	//Method to get the contactTitle
	public void getContact() {
        
        contactTitle = '';
		//Check for size
		if(warmLeadObj != null && warmLeadObj.Contact__c != null) {
            
			//Get the acount record
			List<Contact> cont = [Select Id, Title, Name  From Contact where Id =: warmLeadObj.Contact__c Limit 1];
            
            //Check for size
            if(cont != null && cont.size() > 0 ) {
                
                warmLeadContact = cont[0];
                
                //Populate the contact title
                if(contactTitle == null )
                    contactTitle = '';
                else
                    contactTitle = cont[0].Title;
            }
		}
    }
 	
    //V_1.1 - Added By - Mahendra Swarnakar - 07/21/2017 - CR-20170720-11089
    /**
     *  @description    :   This method is used to send the email Notification to the OAB Team 
     *
     *  @args           :   
     *
     *  @return         :   void
     *
    **/
    public void sentNotificationToOABTeam() {
        
        //List to hold the To Email Addresses
        List<String> listToAddresses = new List<String> ();
        listToAddresses.add(System.Label.OAB_TEAM_EMAIL_ADDRESS);
        
        //String to hold the Email Subject
        String emailSubject = 'OAB Lead Submission via Salesforce';
            
        //Emails body
        String htmlString = 'Hello,<br/><br/>';
        htmlString += 'The following Warm Lead has been submitted:<br/><br/>';
        
        htmlString += '<b>&nbsp;&nbsp;Warm Lead Name: &nbsp;</b> <a href="'+URL.getSalesforceBaseUrl().toExternalForm()+'/'+warmLeadObj.Id+'" />'+warmLeadObj.Name+'</a> <br/><br/>';
        
        if(warmLeadContact != null)
        	htmlString += '<b>&nbsp;&nbsp;Contact: &nbsp;</b>  <a href="'+URL.getSalesforceBaseUrl().toExternalForm()+'/'+warmLeadContact.Id+'" />'+warmLeadContact.Name+'</a> <br/><br/>';    
        else
            htmlString += '<b>&nbsp;&nbsp;Contact: &nbsp;</b> <br/><br/>';
		
        htmlString += '<b>&nbsp;&nbsp;Lead Details: &nbsp;</b> '+warmLeadObj.Comments__c+' <br/><br/>';
        htmlString += 'Thanks.<br/><br/>';
        
        //check for size
        if(listToAddresses.size() > 0){
			//Method call to create and then send the email. 
			EmailHandler.createEmail(listToAddresses, emailSubject , '', htmlString, true);   
        }
    }
}