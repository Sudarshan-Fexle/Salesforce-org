/**
 * 	Purpose			:	Controller for CloneWithPrograms VF page.
 *						This class is used to clone all related RPPs (Role Program Perspective) according to sourceId 
 * 
 * 	Created By		:	Subhash Garhwal
 * 
 *	Created Date	:	07/01/2015 
 * 
 * 	Revision Logs	:	V_1.0 - Created - CR-20150618-9014
 * 
 **/
public with sharing class CloneWithProgramsController {
	
	//Constructor
	public CloneWithProgramsController() {
	}
	
	/**
	 *	@description	:	This method is used to clone all related RPPs (Role Program Perspective) according to sourceId
	 *
	 *	@args			:
	 *
	 *	@return			:	Pagereference
	 *
	 **/
	public Pagereference inIt() {
		
		//Get Parameters from URL
		String sourceId = Apexpages.currentPage().getParameters().get('sourceId');
		String newId = Apexpages.currentPage().getParameters().get('newid');
		
		//Check for URL parameters
		if(String.isNotBlank(sourceId) && String.isNotBlank(newId) && sourceId instanceof Id && newId instanceof Id) {
			
			//SOQL String to  build dynamic query string for RPP
			String SOQL = 'Select ';
			
			//Sobject getDescribe method to fatch all the RPP fields and add fields in SOQL query string
			for(String rPPField : Role_Program_Perspective__c.getSobjectType().getDescribe().fields.getMap().KeySet())
				SOQL +=  rPPField + ',';
			
			//Add Where clouse
			SOQL = SOQL.removeEnd(',') + ' From Role_Program_Perspective__c Where Staff_Assignment__c =\'' + sourceId + '\'';
			
			//Query through RPP
			List<Role_Program_Perspective__c> rPPs = Database.query(SOQL);
			
			//Check for RPP list
			if(rPPs.size() > 0) {
				
				//Clone Role Program Perspective using Salesforce standard method deepClone
				List<Role_Program_Perspective__c> clonedRPPs = rPPs.deepClone(false,true);
				
				//Query through Staff Assignment
				List<Team_Membership__c> staffAssign = [Select Id, Start_date__c, End_date__c From Team_Membership__c Where Id =: newId LIMIT 1];
				
				//Check for Staff Assignment
				if(staffAssign.size() > 0) {
					
					//Loop through Clone RPPs list to assign RPP to new Staff Assignmet
					for(Role_Program_Perspective__c rPP : clonedRPPs) {
						
						//Change Staff Assignment
						rPP.Staff_Assignment__c = newId;
						
						//Populate effective dates
						rPP.Effective_Start__c = staffAssign[0].Start_date__c;
						rPP.Effective_End__c = staffAssign[0].End_date__c;
					}	
				
					//Insert cloned RPPs
					insert clonedRPPs;
				}
			}
			
			//Return
			return new Pagereference('/' + newId); 
		}
		return null;  
	}
}