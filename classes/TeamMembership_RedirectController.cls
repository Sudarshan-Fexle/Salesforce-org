/**
 *  Purpose         :   This Method is used to handle edit Roll Button Functionality in LEX. 
 * 						1. This is a controller class of TeamMembership_Redirect page. 
 * 						2. Page is used as a inline vf page on the staff assignment records. 
 * 						3. If the Latest clone staff assignment field is filled then the page will be navigated to that cloned record 
 * 						   and blank out the field this is just a one time navigation while cloning a reocrd. 
 * 
 *  Created By      :   Dipesh Gupta
 * 
 *  Created Date    :   01/03/2020
 * 
 *  Revision Logs   :   V_1.0 - Created - CR-20191109-13503
 * 
 **/
public Without sharing class TeamMembership_RedirectController {
    
    //Team Membership Instance.
    Public Team_Membership__c oldStaffAssignment;
    
    //Constructor
    public TeamMembership_RedirectController(ApexPages.StandardController stdController) {
        
        Team_Membership__c staffAssignment = (Team_Membership__c)stdController.getRecord();
        
        //Query on the team Membership Record. 
		List<Team_Membership__c> staffAssignments = new List<Team_Membership__c>();
        staffAssignments = [Select Id, Latest_Cloned_Staff_Assignment__c From Team_Membership__c Where Id =: staffAssignment.Id];
        oldStaffAssignment = staffAssignments[0];
    }
    
    //Calling this method from the action of page. 
    public Pagereference redirect() {
        
        //Check if the staff Assignment has the latest clone staff Assignment. 
        if(oldStaffAssignment != null && String.isNotBlank(oldStaffAssignment.Latest_Cloned_Staff_Assignment__c)){
            
            //String to hold the  URL. 
            String returnURL = '/apex/URLNavigator?operationtype=NAVIGATETOSOBJECT&recordId='+oldStaffAssignment.Latest_Cloned_Staff_Assignment__c;
        
        	//Updating the record to remove Latest Cloned Staff Assignment. 
        	oldStaffAssignment.Latest_Cloned_Staff_Assignment__c = null;
            
            //Updating the Staff Assignment
            Util.ByPassAllTriggers = true;
            Update oldStaffAssignment;
            Util.ByPassAllTriggers = false;
            
        	return new Pagereference(returnURL);    
        }
          
        return null;
    }
}