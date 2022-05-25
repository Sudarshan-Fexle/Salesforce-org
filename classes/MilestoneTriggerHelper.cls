public without sharing class MilestoneTriggerHelper {
     
    /**
     * 
     *   @description    :  This method is used to populate the most recent Deployment Sign Off (Actual)/Actual Date on the Project Record from Milestone. 
     *
     *   @args           :  List<pse__Milestone__c> newMileStone, Map<Id, pse__Milestone__c> oldMilestones
     *
     *   @return         :  void
     *
     *   @revision Log   :  V1.1  - Created by Colin McGloin - 09/24/2018 - CR-20180917-12599 
     * 
     **/
    
		public static void updateDeploymentSignOffOnProject (List<pse__Milestone__c> newMilestones, Map<Id, pse__Milestone__c> oldMilestones) {

			//Set for querying our Projects Later
			Set<Id> projIds = new Set<Id>();

			//List of Projects for Updating
			List<pse__Proj__c> projectsToBeUpdated = new List<pse__Proj__c>();

			//Populate for the Delete scenario
			if (trigger.isDelete) newMilestones = oldMilestones.values();

			//Loop through our Milestones
			for (pse__Milestone__c milestone : newMilestones){

				//Check for our insert scenario
				if (milestone.pse__Actual_Date__c != null && milestone.pse__Project__c != null && oldMilestones == null){

					//Add our Project to the Set
					projIds.add(milestone.pse__Project__c);

				}

				//Check for our update scenario
				if (trigger.isDelete || (oldMilestones != null && milestone.pse__Actual_Date__c != oldMilestones.get(milestone.Id).pse__Actual_Date__c)){

					//Add the Project to our Set
					projIds.add(milestone.pse__Project__c);

				}

			}

			//If we have records to be updated
			if (projIds.size() > 0){

				//Query for our Project Records
				List<pse__Proj__c> depProjs = [SELECT Id, Deployment_Sign_Off_Actual__c, (SELECT pse__Actual_Date__c FROM pse__Milestones__r WHERE pse__Actual_Date__c != NULL ORDER BY pse__Actual_Date__c DESC)
											   FROM pse__Proj__c
											   WHERE Id IN :projIds];

			//Loop through our Projects
			for (pse__Proj__c proj : depProjs){

				//If we have related Deployments
				if (proj.pse__Milestones__r.size() > 0){

					//Pull our most recent Sign Off Actual Date
					proj.Deployment_Sign_Off_Actual__c = proj.pse__Milestones__r[0].pse__Actual_Date__c;

					//Add to our list to be updated
					projectsToBeUpdated.add(proj);

				} else if (proj.Deployment_Sign_Off_Actual__c != null && proj.pse__Milestones__r.size() == 0) {

					//If we do not have any Milestones that meet the requirements moving forward then we populate the field with a blank value
					proj.Deployment_Sign_Off_Actual__c = null;

					//Add to our list to be updated
					projectsToBeUpdated.add(proj);

					}

				}

			}

			//If we have records that are due to be updated then run update
			if (projectsToBeUpdated.size() > 0){
				update projectsToBeUpdated;
			}

		}
    
     /**
     * 
     *   @description    :  This method is used to Add the PSA on the Mile Stone Reocrd. 
     *
     *   @args           :  List<pse__Milestone__c> newMileStone
     *
     *   @return         :  void
     *
     *   @revision Log   :  V1.1  - Created by Abhinav Sharma - 09/24/2018 - CR-20180917-12599 
     * 
     **/
    public static void updateNameForPSAMileStone(List<pse__Milestone__c> newMilestones) {
        
        //Checking the milestone
        if(newMilestones != null && newMilestones.size() > 0) {
            
            //Loop on the Mile stone
            for(pse__Milestone__c pMilestone : newMilestones) {
            	
                //Checking for the EAB Deployment Records 
                if(pMilestone.EAB_Deployment__c != null && !pMilestone.Name.contains(' - PSA')) {
                	
                    if(pMilestone.Name.Length() > 74)
                    	pMilestone.Name = pMilestone.Name.substring(0,73) + ' - PSA';
                     else
                        pMilestone.Name = pMilestone.Name + ' - PSA';
                }
            }
        }
    }
}