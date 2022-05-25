/**
 *  Description     :  Helper class for Trigger_ProgramGroup trigger.
 *
 *  Created By      :  Subhash Garhwal
 *
 *  Created Date    :  06/24/2015
 *
 *  Revision Logs   :   V_1.0 - Created - Subhash Garhwal - CR-20150618-9014 
 *                      V_1.1 - Added - Subhash Garhwal - CR-20150729-9114 - 08/04/2015 -  New method incentiveChangeLog added.
 *                      V_1.2 - Modified - Rajeev Jain - CR-20151120-9402 - 04/19/2016 - Removed the usage of the incentiveChangeLog
 *			V_1.3 - Modified - Subhash Garhwal - Issue--CR10808--QA--00005222 - 08/25/2017 - Added a new logic to update the Program's Family field with Program Collection's Family field (validateProgramFamily method).
 *			V_1.4 - Modified - Abhinav Sharma - CR-20200806-14405 - 08/26/2020 - Error In Update Program Collection record
 **/
public without sharing class ProgramGroupTriggerHelper {

    //List to hold Staff Assignments
    //This list is to Summarize RPPs on Staff Assignments when, Staff Assignment is deleted
    public static List<Team_Membership__c> teamMemberships;
    
    /**
     *  @description    :   Method to check Program Group name. The Name value must be unique across all Program Groups
     *
     *  @args           :   List<Program_Group__c>, Map<Id, Program_Group__c>
     *
     *  @return         :   void
     *
     **/
    public static void validateProgramGroup(List<Program_Group__c> programGroups, Map<Id, Program_Group__c> mapOldProgramGroups) {
        
        //Set to hold Program Group name
        Set<String> setPGName = new Set<String>();

        //Loop through the Program Groups
        for(Program_Group__c pG : programGroups) {
            
            //Check appropriate condition
            if(mapOldProgramGroups == null || pG.Name != mapOldProgramGroups.get(pG.Id).Name) {
                
                //Check Program Group name in set
                if(setPGName.contains(pG.Name))
                    throw new CustomException(Label.DUPLICATE_PROGRAM_GROUP);
                
                //Add Program Group name in set
                setPGName.add(pG.Name);
            }
                
        }

        //Query through the Program Groups
        List<Program_Group__c> programGs = [Select Id, Name From Program_Group__c Where Name IN : setPGName LIMIT 1];
        
        //Check for list size
        if(programGs.size() > 0) {
            
            //Add Duplicate record error
            throw new CustomException(Label.DUPLICATE_PROGRAM_GROUP);
        }
    }

    /**
     *  @description    :   Method to notify related Perspective's owner, when update occurs to the following fields:
     *                      Name, Effective_Start__c, Effective_End__c or Active__c
     *
     *  @args           :   List<Program_Group__c>, Map<Id, Program_Group__c>
     *
     *  @return         :   void
     *
     **/
    public static void keyInformationChangedNotification(List<Program_Group__c> programGroups, Map<Id, Program_Group__c> mapOldProgramGroups) {
        
        //Set to hold Program Group's Ids
        Set<Id> setPGIds = new Set<Id>();

        //Loop through program group data
        for(Program_Group__c pG : programGroups != null ? programGroups : mapOldProgramGroups.values()) {
            
            //Subhash Garhwal - 23/7/2015 - CR-20150618-9013 - Code Commented as per Program Management Issues submitted by Taylor
            //Check appropriate condition (If changes occure in any key field)
            /*if(programGroups != null && (pG.Name != mapOldProgramGroups.get(pG.Id).Name || pG.Effective_Start__c != mapOldProgramGroups.get(pG.Id).Effective_Start__c
                || pG.Effective_End__c != mapOldProgramGroups.get(pG.Id).Effective_End__c || pG.Active__c != mapOldProgramGroups.get(pG.Id).Active__c)) {
                
                //Add Program Group Id in set
                setPGIds.add(pG.Id);
            
            //Check for delete case
            } else */
            if(programGroups == null)
                setPGIds.add(pG.Id);
        }

        //Check for set size
        if(setPGIds.size() > 0) {
            
            //Query through email templete
            List<EmailTemplate> eTemplate = [Select Id, Name, DeveloperName From EmailTemplate where DeveloperName =: Label.PROGRAM_GROUP_NOTIFICATION LIMIT 1];
            
            //List of SingleEmailMessage
            //This list is used to notify all the related program groups
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            
            //Check for email template
            if(eTemplate.size() == 1) {
                
                //Set to hold Business Owner Ids
                Set<String> setBOwners = new Set<String>();
                
                //Query through Program Perspective to get all the Perspective related to program group.
                for(Program_Perspective__c pP : [Select Id, Name, Perspective__c, Perspective__r.Business_Owner__c, Program_Group__c From Program_Perspective__c Where Program_Group__c != null AND Program_Group__c IN : setPGIds AND Perspective__r.Business_Owner__r.Email != null]) {
                    
                    //Check if set contains 
                    if(!setBOwners.contains(pP.Perspective__r.Business_Owner__c)) {
                        
                        //Add new email in email list
                        mails.add(EmailHandler.email(eTemplate[0].Id, pP.Perspective__r.Business_Owner__c, null));
                        
                        //Add Business Owner Id in set
                        setBOwners.add(pP.Perspective__r.Business_Owner__c);
                    }
                }
                
                //Subhash Garhwal - 27/7/2015 - CR-20150618-9013 - Code Commented as per Program Management Issues submitted by Taylor
                
                //Check for email list size to notify Program Group and Group Purpose owners
                //if(mails.size() > 0)
                    //Messaging.sendEmail(mails);
            }
        }
    }

    /**
     *  @description    :   Method to check related Program Perspective's In Use values on record delation, If "In Use" values > 0, then throw error.
     *
     *  @args           :   List<Program_Group__c>
     *
     *  @return         :   void
     *
     **/
    public static void validateBeforeDelete(List<Program_Group__c> programGroups) {
        
        //Query through Program_Perspective__c
        List<Program_Perspective__c> programPerspectives = [Select Id, In_use_Plans_Direct__c, In_use_Plans_Indirect__c, In_use_Staff_Direct__c, In_use_Staff_Indirect__c From Program_Perspective__c Where (Program_Group__c != null AND Program_Group__c IN: programGroups AND (In_use_Plans_Direct__c > 0 OR In_use_Plans_Indirect__c > 0 OR In_use_Staff_Direct__c > 0 OR In_use_Staff_Indirect__c > 0)) LIMIT 1]; 
        
        //Check for map size
        if(programPerspectives.size() > 0) {
            
            //throw exception
            throw new CustomException(Label.PROGRAM_GROUP_IN_USE);
        }
    }
    
    /**
     *  @description    :   This method is used to summarize RPPs on Staff Assignments if Shot name is changed or Program Group is deleted.
     *
     *  @args           :   List<Program_Group__c>, Map<Id, Program_Group__c>
     *
     *  @return         :   void
     *
     **/
    public static void SummarizeRPPs(List<Program_Group__c> programGroups, Map<Id, Program_Group__c> mapOldPGroups) {
        
        //Set to hold Program Group Ids
        Set<Id> setPGIds = new Set<Id>();
        
        //Loop through Program Groups
        for(Program_Group__c pG : programGroups) {
            
            //Check for appropriate condition to fire trigger
            if(pG.Short_Name__c != mapOldPGroups.get(pG.Id).Short_Name__c)
                setPGIds.add(pG.Id);
        }
        
        //Check for set size
        if(setPGIds.size() > 0) {
            //Modified - Abhinav Sharma - CR-20200806-14405 - Error In Update Program Collection record (Move recalculateProgramPerspectives method functinality in Batch and comment existing)
			Database.executeBatch(new Batch_SummarizeRPPs(setPGIds),200);
            /*
            //Set to hold Staff Assignment Ids
            Set<Id> setSAIds = new Set<Id>();
            
            //Query through RPPs
            for(Role_Program_Perspective__c rPP : [Select Id, Staff_Assignment__c From Role_Program_Perspective__c Where Staff_Assignment__c != null
                                                            AND Program_Perspective__r.Program_Group__c IN : setPGIds])
                setSAIds.add(rPP.Staff_Assignment__c);
            
            //Check for set size and call TeamMembershipTriggerHelper class method to summarize
            if(setSAIds.size() > 0)
                TeamMembershipTriggerHelper.recalculateProgramPerspectives([Select Id, Program_Perspectives__c From Team_Membership__c Where Id IN : setSAIds]);
	    */
        }
    }
    
    /**
     *  @description    :   This method is used to populate Staff Assignment's static list (teamMemberships) to summarize RPPs on SA.
     *  
     *  @args           :   List<Program_Group__c>
     *
     *  @return         :   void
     *
     **/
    public static void SummarizeRPPs(List<Program_Group__c> programGroups) {
        
        //Set to hold Program Group Ids
        Set<Id> setPGIds = new Set<Id>();
        
        //Loop through Program Groups
        for(Program_Group__c pG : programGroups)
            setPGIds.add(pG.Id);
        
        //Check for set size
        if(setPGIds.size() > 0) {
            
            //Set to hold Staff Assignment Ids
            Set<Id> setSAIds = new Set<Id>();
            
            //Query through RPPs
            for(Role_Program_Perspective__c rPP : [Select Id, Staff_Assignment__c From Role_Program_Perspective__c Where Staff_Assignment__c != null
                                                            AND Program_Perspective__r.Program_Group__c IN : setPGIds])
                setSAIds.add(rPP.Staff_Assignment__c);
            
            //Query through Staff Assignments
            teamMemberships = [Select Id, Program_Perspectives__c From Team_Membership__c Where Id IN : setSAIds];
        }
    }
    
    /**
     *  @description    :   This method is used to call TeamMemebershipTriggerHelper class method to Summarize RPPs on SA
     *  
     *  @args           :   
     *
     *  @return         :   void
     *
     **/
    public static void SummarizeRPPs() {
        
        //Check Staff Assignment list
        if(teamMemberships != null && teamMemberships.size() > 0){
            //Modified - Abhinav Sharma - CR-20200806-14405 - Error In Update Program Collection record (Move recalculateProgramPerspectives method functinality in Batch and comment existing)
            Database.executeBatch(new Batch_UpdateProgramPerspectives(teamMemberships));
        }
        //TeamMembershipTriggerHelper.recalculateProgramPerspectives(teamMemberships);
    } 
    
    //Code Added by - Subhash Garhwal - 08/04/2015 - CR-20150729-9114 - New method incentiveChangeLog added.
    //V_1.2 - Commented By - Rajeev Jain - CR-20151120-9402 - 04/19/2016
    /**
     *  @description    :   This method is used to create Incentive Change Log when Short name and Effective Dates change.
     *  
     *  @args           :   List<Program_Group__c>, map<Id, Program_Group__c>
     *
     *  @return         :   void
     *
     **/
     /*public static void incentiveChangeLog(List<Program_Group__c> programGroups, Map<Id, Program_Group__c> mapOldProgramGroup){
        
        //List to create ICL 
        List<Incentive_Change_Log__c> insertIcgWithPg = new List<Incentive_Change_Log__c>();
        
        //Loop Through Trigger.new 
        for(Program_Group__c pG : programGroups){
            
            //Check Update
            if(pG.Short_Name__c != mapOldProgramGroup.get(pG.Id).Short_Name__c 
                || pG.Effective_Start__c != mapOldProgramGroup.get(pG.Id).Effective_Start__c 
                || pG.Effective_End__c != mapOldProgramGroup.get(pG.Id).Effective_End__c){
                
                //Short Name modified 
                if(pG.Short_Name__c != mapOldProgramGroup.get(pG.Id).Short_Name__c)
                    insertIcgWithPg.add(new Incentive_Change_Log__c(Program_Collection__c = pG.Id, Change_Type__c = ISSPConstants.INCENTIVE_CHANGE_LOG_CHANGE_TYPE_TEXT));
                
                //Effective Dates modified 
                if((pG.Effective_Start__c != null || pG.Effective_End__c != null)
                    && (pG.Effective_Start__c != mapOldProgramGroup.get(pG.Id).Effective_Start__c 
                    || pG.Effective_End__c != mapOldProgramGroup.get(pG.Id).Effective_End__c)){
                    
                    //Instance of Incentive change log
                    Incentive_Change_Log__c iCL = new Incentive_Change_Log__c(Program_Collection__c = pG.Id, Change_Type__c = ISSPConstants.INCENTIVE_CHANGE_LOG_VALUE_TYPE_EFFECTIVE_DATES);
                    
                    //Check for Start Date
                    if(pG.Effective_Start__c != mapOldProgramGroup.get(pG.Id).Effective_Start__c)
                        iCL.Start_Date__c = pG.Effective_Start__c;
                    
                    //Check for end date
                    if(pG.Effective_End__c != mapOldProgramGroup.get(pG.Id).Effective_End__c)
                        iCL.End_Date__c = pG.Effective_End__c;
                    
                    //Add Change log in list
                    insertIcgWithPg.add(iCL);
                }
            }
        }
    
        //Check Size
        if(insertIcgWithPg.size() > 0) 
            insert insertIcgWithPg;         
     }*/
	
	/**
     *  @description    :   This method is used to update the Program's Family field with Program Collection's Family field (validateProgramFamily method).
     *
     *  @args           :   List<Program_Group__c>, Map<Id, Program_Group__c>
     *
     *  @return         :   void
     *
     *	@revision Log	:	V1.0 - Created - 08/25/2017 - Subhas Garhwal - Issue--CR10808--QA--00005222 
     *
     **/
	public static void validateProgramFamily(List<Program_Group__c> programCollections, Map<Id, Program_Group__c> mapOldProgramCollections) {
		
		//Set to hold the Program Collection
		Set<Id> setProCollectionIds = new Set<Id>();
		
		//Loop over the Program Collection
		for(Program_Group__c pG : programCollections) {
			
			//Check for Family field
			if(pG.Family__c != mapOldProgramCollections.get(pG.Id).Family__c || pG.Name != mapOldProgramCollections.get(pG.Id).Name  )
				setProCollectionIds.add(pG.Id);	

		}
		
		//Check for Program Collection
		if(setProCollectionIds.size() > 0) {

			//Set to hold Collection Perspectives
			Set<Id> setCollectionPerspectiveIds = new Set<Id>();

			//Loop through Collection Perspective
			for(Program_Perspective__c programPerspective : [Select Id, Program_Group__c From Program_Perspective__c Where Program_Group__c IN : setProCollectionIds ])
				setCollectionPerspectiveIds.add(programPerspective.Id);

			//Check for Size
			if(setCollectionPerspectiveIds.size() > 0) {
	
				//Set to hold the Program Ids
				Set<Id> setProgramIds = new Set<Id>();
				
				//SOQL over the Collection Perspective Child
				for(Program_Relationship__c pCC : [Select Id, Program__c, Program_Group__c From Program_Relationship__c Where Program_Perspective__c IN : setCollectionPerspectiveIds AND Program__c != null])
					setProgramIds.add(pCC.Program__c);	

				//Check for set size
				if(setProgramIds.size() > 0) {
					
					//List to update the Programs
					List<Program__c> programsToUpdate = new List<Program__c>(); 
					
					//SOQL over the Program
					for(Program__c program : [Select Id, Family__c, Name, (Select Id, Program_Group__c, Program_Perspective__r.Program_Group__r.Family__c, 
												Program_Perspective__r.Program_Group__r.Name From Program_Relationships__r ORDER BY LastModifiedDate DESC LIMIT 1) 
												From Program__c Where Id IN : setProgramIds]) {

						//Check for Family
						if(program.Program_Relationships__r != null && program.Program_Relationships__r.size() == 1) {
							
							//Check for Family
							if(program.Program_Relationships__r[0].Program_Perspective__r.Program_Group__c != null 
								&& (program.Family__c != program.Program_Relationships__r[0].Program_Perspective__r.Program_Group__r.Family__c
									|| program.Name != program.Program_Relationships__r[0].Program_Perspective__r.Program_Group__r.Name))
								programsToUpdate.add(new Program__c(Id = program.Id, 
								Family__c = program.Program_Relationships__r[0].Program_Perspective__r.Program_Group__r.Family__c,
								Parent_Bundle_s__c = program.Program_Relationships__r[0].Program_Perspective__r.Program_Group__r.Name ));	

						}	
					}
					
					//Check for size
					if(programsToUpdate.size() > 0) {
						
						//Bypass
						Util.byPassAllTriggers = true;
		                update programsToUpdate;
		                Util.byPassAllTriggers = false;
					}
				}
			}
		}
	}
}