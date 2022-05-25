/**
*   Description     :   Logic Controller which is used by the ApprovalDelegationOverride VF Page
*                
*   Created by      :   Colin McGloin
*
*   Created Date    :   06/05/2017
*
*   Revision Log    :   V1.0 - Created - CR-20161124-10488
*/

public without sharing class ApprovalRequestController {

	//Variables for records and current logged in User
	public Id userID {get; set;}
	public Id approvalId {get; set;}

	//Variables for storing what the User was doing on Approval Page originally
	public string approve {get; set;}
	public string reject {get; set;}
	public string reassign {get; set;}

	//Variable to mark if our user should be sent back to the standard Approval Page
	public boolean redirectToStandard {get; set;}

	public ApexPages.StandardController stdController;

	public ApprovalRequestController (ApexPages.StandardController stdController) {

		//Grab our Approval ID, Current User and what the user was doing originally
		approvalId = ApexPages.currentPage().getParameters().get('approvalId');
		userId = this.userID = UserInfo.getUserId();

		//Parameters provided by the button logic
		approve = ApexPages.currentPage().getParameters().get('approve');
        reject = ApexPages.currentPage().getParameters().get('reject');
        reassign = ApexPages.currentPage().getParameters().get('reassign');

		
	}

	public pageReference inIt () {

		if(approvalId != null && userId != null){

	        //Pass through our Approval and Logged in User to the Assigned To Logic
	        checkAssignedTo(approvalId, userId);

	    }

        //Go through our three redirection scenarios
		if (approve == '1'){
			pageReference redirect = new pageReference('/'+System.label.Steelbrick_Approve+'?scontrolCaching=1&id='+approvalId);
			redirect.setRedirect(true);
			return redirect;
		}
		else if (reject == '1'){
			pageReference redirect = new pageReference('/'+System.Label.Steelbrick_Reject+'?scontrolCaching=1&id='+approvalId);
			redirect.setRedirect(true);
			return redirect;
		}
		else if (reassign == '1'){
			pageReference redirect = new pageReference('/'+System.Label.Steelbrick_Reassign+'?scontrolCaching=1&id='+approvalId);
			redirect.setRedirect(true);
			return redirect;
		}

		//In theory we should never hit this
		return null;

	}


	/**
     * @description: Checks if we need to auto-populate the Assigned To field and then proceeds to the correct standard Steelbrick VF page
     **/

	public void checkAssignedTo (Id approvalId, Id userId) {

		sbaa__Approval__c app = [SELECT Id, sbaa__Status__c, sbaa__AssignedTo__c
							 	 FROM sbaa__Approval__c
							 	 WHERE Id = :approvalId];

		//Check to see if our record is in the status of Assigned or Requested
		if (app.sbaa__Status__c == 'Assigned' || app.sbaa__Status__c == 'Requested'){

             //Modified By - Dipesh Gupta - CR-20200102-13584 - 5/29/2020 - custom permission check  
			//Check for Admin permission
			if (FeatureManagement.checkPermission('CPQ_Approval_Admin') == true || checkHierarchy() == true){

					//Populate the Assigned To field with the Current User & redirect to the right page
					app.sbaa__AssignedTo__c = userID;
					update app;
				}

		}

	}

     //Modified By - Dipesh Gupta - CR-20200102-13584 - 5/29/2020 - Comment the method  
     /**
     * @description: Checks if the user has the CPQ Approval Admin Custom Permission
     **/

	/*public boolean checkForAdminPermission () {

		//Set our default to false
        boolean appAdmin = false;

        //Grab our CPQ Approval Admin Custom Permission
        CustomPermission appAdminPermission = [SELECT Id, DeveloperName
                                              	FROM CustomPermission
                                              	WHERE DeveloperName = 'CPQ_Approval_Admin'];

        //Check to see that the logged in user has the Custom Permission assigned
        List<SetupEntityAccess> adminSetupEntities = [SELECT SetupEntityId
                                                    	FROM SetupEntityAccess
                                                    	WHERE SetupEntityId = :appAdminPermission.Id AND
                                                        ParentId IN (SELECT PermissionSetId
                                                        FROM PermissionSetAssignment
                                                        WHERE AssigneeId = :this.userId)];

        //If the user is assigned as an Admin user then update our flag                                                   
        if (!adminSetupEntities.isEmpty()){
            appAdmin = True;
        }
        else {
            appAdmin = False;
        }
        //Return our flag
        return appAdmin;                                                

	}*/

	/**
     * @description: Checks if the user is in the Approvers Manager Hierarchy chain
     **/

	public boolean checkHierarchy () {

		//Grab our Approver user record
		sbaa__Approval__c approverUser = [SELECT Id, sbaa__Approver__c, sbaa__Approver__r.sbaa__User__c
							 			  FROM sbaa__Approval__c
							 			  WHERE Id = :approvalId];
		
        //VH 7/22/17 - Modified - if this isn't assigned to an approver user (ie: it's assigned to a queue), return false
        if (approverUser.sbaa__Approver__r.sbaa__User__c == null) return false;
        
		//Create a set of Ids to track all of the Ids
		Set<Id> managerChain = new Set<Id>();
		//If we have a really long chain then track the last Id and kick off a new search
		Id secondSearchId;
		//Boolean for makring if they are in the Approver's chain or not
		boolean approverManager = false;

		//Let's start with our approver and their Manager
		User userManager = [SELECT Id, managerId, 
							Manager.Manager.Id, 
							Manager.Manager.Manager.Id,
							Manager.Manager.Manager.Manager.Id, 
							Manager.Manager.Manager.Manager.Manager.Id FROM User WHERE Id = :approverUser.sbaa__Approver__r.sbaa__User__c];

		if (userManager.managerId != null){
			managerChain.add(userManager.managerId);
			if (userManager.manager.managerId != null){
				managerChain.add(userManager.manager.managerId);
				if(userManager.Manager.Manager.Manager.Id != null){
					managerChain.add(userManager.Manager.Manager.Manager.Id);
					if (userManager.Manager.Manager.Manager.Manager.Id != null){
						managerChain.add(userManager.Manager.Manager.Manager.Manager.Id);
						if(userManager.Manager.Manager.Manager.Manager.Manager.Id != null){
							managerChain.add(userManager.Manager.Manager.Manager.Manager.Manager.Id);
							secondSearchId = userManager.Manager.Manager.Manager.Manager.Manager.Id;
						}
					}
				}
			}
		}

		if (secondSearchId != null){

				//Let's have another search since we hit the limit on the last search
				User managerSearch2 = [SELECT Id, managerId, 
										Manager.Manager.Id, 
										Manager.Manager.Manager.Id,
										Manager.Manager.Manager.Manager.Id, 
										Manager.Manager.Manager.Manager.Manager.Id FROM User WHERE Id = :secondSearchId];


				if (managerSearch2.managerId != null){
					managerChain.add(managerSearch2.managerId);
					if (managerSearch2.manager.managerId != null){
						managerChain.add(managerSearch2.manager.managerId);
						if(managerSearch2.Manager.Manager.Manager.Id != null){
							managerChain.add(managerSearch2.Manager.Manager.Manager.Id);
							if (managerSearch2.Manager.Manager.Manager.Manager.Id != null){
								managerChain.add(managerSearch2.Manager.Manager.Manager.Manager.Id);
								if(managerSearch2.Manager.Manager.Manager.Manager.Manager.Id != null){
									managerChain.add(managerSearch2.Manager.Manager.Manager.Manager.Manager.Id);
							}
						}
					}
				}
			}

		}

		if (managerChain.contains(userID)){
			approverManager = true;
		}

		return approverManager;

	}

}