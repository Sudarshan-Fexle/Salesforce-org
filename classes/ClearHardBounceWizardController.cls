/**
 *  Desription      :   This class is Used clear out the contact Fields.
 * 
 *  Created By      :   Abhinav Sharma
 * 
 *  Created Date    :   07/09/2018
 * 
 *  Revision Logs   :   V1.1 - Created
 * 						
**/
public class ClearHardBounceWizardController {
	
    //String to hold the Selected option
    public String selectedOne{get; set;}
    
    //Contact Instance
    public Contact conRec{get; set;}
    
    //Variable to hold the Contact Ids 
    public String conId{get; set;}
    
    //String to hold the Email
    Public String newEmail {get; set;}
    
    //variable to check the wizard completion
    Public Boolean isWizardComplete {get; set;}
    
    //Boolean to check if Sceen2 should be Visible and Succsss and Error Message
    public boolean isScreen2Visible {get; set;}
    public boolean isSuccess {get; set;}
    public boolean isError {get; set;}
    public String errorMessage{get;set;}
    
    //Getter setter method to select the value
    public List<SelectOption> getHardBounceOptions() {
    	
        //List to hold the Select option
        List<SelectOption> hardBounceOption = new List<SelectOption>();
        
        //Adding 2 Values in the Options
        hardBounceOption.add(new SelectOption('Screen1','Clear without changing Email'));
        hardBounceOption.add(new SelectOption('Screen2','Change Email'));
        return hardBounceOption;
        
    }  
    
   
    //Constructor.
    public ClearHardBounceWizardController() {
    	
         conId =  ApexPages.CurrentPage().getparameters().get('id');
         System.debug(conId);
        
        //Check for the IDs
        if(String.isNotBlank(conId)) {
			
            //Query on the contact to get the Field Info.
        	conRec = [Select Id, Name, Marketing_Hard_Bounce_Date__c, 
                      Marketing_Hard_Bounce_Reason__c, 
                      Marketing_Hard_Bounce_Email__c 
                      From Contact Where Id =: conId LIMIT 1];
        }
        
        isScreen2Visible = false;
        isSuccess = false;
        newEmail = '';
        isWizardComplete = false;
        isError = false;
        errorMessage ='';
       
    }
    
       /**
        *  @description    :   This method is used to handle 1st screen event on the wizard.
        * 
        *  @return         :   void
        *
        *  @Revision Log   :   V1.0 - Created - Abhinav Sharma - CR-20180417-12165 
        *   
     **/
    
    //Method to Next the Record
    public void goNextScreen1() {
      
        //Check for the selected Action
        if(selectedOne == 'Screen1') {
            
          conRec.Marketing_Hard_Bounce_Date__c = null;
          conRec.Marketing_Hard_Bounce_Reason__c = null;
          conRec.Marketing_Hard_Bounce_Email__c = null;
          conRec.Site_Profile_Disabled_from_Hard_Bounce__c = false;	
          
            try {
            	update conRec;
            	isSuccess = true;
                isWizardComplete = true;
            }catch(Exception e) {
            	isError = true;   
            }
        }else {
    		isScreen2Visible = true;
        }
    }
        
    /**
    *  @description    :   This mehtod is used to handle the 2nd screen event. 
    * 
    *  @return         :   void
    *
    *  @Revision Log   :   V1.0 - Created - Abhinav Sharma - CR-20180417-12165 
    *   
    **/
    //Method to change the Email of the Contact
    public void goNextScreen2() {
      
        //Check the new Email address
        if(String.isNotBlank(newEmail)) {
        	
            conRec.Email = newEmail;
            conRec.Company_Email__c = newEmail;
            conRec.Marketing_Hard_Bounce_Date__c = null;
            conRec.Marketing_Hard_Bounce_Reason__c = null;
            conRec.Marketing_Hard_Bounce_Email__c = null;
            conRec.Site_Profile_Disabled_from_Hard_Bounce__c = false;	
            /*True this flag to bypass the condition on the ContactSiteHelper.updateSiteProfilesFromContact 
			*/
            ContactSiteHelper.CLEAR_HARD_BOUNCE = true;
            try {
                
                
            	update conRec;
                isSuccess = true;
                isWizardComplete = true;
                isError = false;
            }catch(Exception e) {
                isError = true;
                isSuccess = false;
                errorMessage = e.getMessage();
                System.debug('error'+e.getMessage());
            }
        }
    }
     
}