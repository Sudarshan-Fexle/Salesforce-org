/**
 *  Description     :  Controller class for OpportunityMerge VF page. This class will hold all the logics to merge the Opportunities
 *
 *  Created By      :  Subhash Garhwal
 *
 *  Created Date    :  04/25/2017
 *
 *  Revision Logs   :   V_1.0 - Created - Subhash Garhwal - CR-20170403-10807 - Find details from "Merge Opportunities - Technical Design" on the CR
 *            		V_1.1 - Modified - Subhash Garhwal - Issue--CR11744--QA--00007311 - Added bypass logic to avoid SOQL limit issue  
 * 			V_1.2 - Modified  - Abhishek Mishra - 08/30/2021 - CR-20210722-15307 - Added StageName in SOQL Query 
 *
 **/
public without sharing class OpportunityMergeController {
	
	//Variables
    public static boolean isOpportunityMerge = false;
	
	//Instance of opportunity
	public Opportunity baseOpportunity {get;set;}
	public Opportunity secondaryOpportunity {get;set;}
	public Opportunity tempOpportunity {get;set;}
	
	//Select Option to select the Master opportunity
	public List<SelectOption> oppsOptions {get;set;}
	public String masterOpportunity {get;set;}
	
	//Map to hold all the Opportunity fields
	Map<String, Schema.SObjectField> opportunityFieldMap = Schema.getGlobalDescribe().get('Opportunity').getDescribe().fields.getMap();
	
	//String to hold the SOQL string for opportunity
	String SOQLString;
	
	//Winner opportunity Id
	public String winnerOppId {get;set;}
     
	//Constructor
	public OpportunityMergeController(ApexPages.StandardController controller) {
		
		//Get record
		baseOpportunity = (Opportunity)controller.getRecord();
		
		//Modified By - Abhishek Mishra - 08/30/2021 - CR-20210722-15307 - Added StageName in SOQL Query
		baseOpportunity = [Select Id, Name, Top_Parent_Institution_ID__c, Secondary_Opportunity__c, RecordType.DeveloperName,StageName From Opportunity Where Id =: baseOpportunity.Id];
		
		//inIt method
		inIt();
	}
	
	//inIt method to define all the variable values and load all the Properties
	public void inIt() {
		
		//Initilize all the properties
		oppsOptions = new List<SelectOption>();
		SOQLString = 'Select ';
		masterOpportunity = null;
		tempOpportunity = new Opportunity(Id = baseOpportunity.Id, Top_Parent_Institution_ID__c = baseOpportunity.Top_Parent_Institution_ID__c);
		
		//winnerOppId = '';
		
        //add a --None-- option
		oppsOptions.add(new SelectOption('', '--None--'));
        
		//Add Base Opportunity in options
		oppsOptions.add(new SelectOption(baseOpportunity.Id, 'Opportunity 1 (' + baseOpportunity.Name + ')'));
		
		//Loop over the opportunity fields
		for(String oppField : opportunityFieldMap.keySet())
			SOQLString += oppField + ',';
		
		//Add addition fields
		SOQLString += 'RecordType.DeveloperName From Opportunity Where Id IN : ';	
		
	}
	
	/**
	 *	@description	:	This method is used to validate the selected opportunity and also get all the fields for both opportunities.
	 *						Conditions: Opportunity should be in same institution hierarchy 
	 *						
	 *	@args			:	
	 *
	 *	@return			:	void
	 *
	 *	@revision Log	:	V_1.0 - 04/25/2017 - Created - Subhash Garhwal - CR-20170403-10807
	 *
	 **/
	public void validateSecondayOpportunity() {

		try {
			//Check for secondary Opportunity
			if(tempOpportunity.Secondary_Opportunity__c != null) {
				
				//Set to hold the opportunity Ids
				Set<Id> setOpportunitiesId = new Set<Id>();
				
				//Add Opportunity Ids in set
				setOpportunitiesId.add(baseOpportunity.Id);
				setOpportunitiesId.add(tempOpportunity.Secondary_Opportunity__c);
				
				//Check for opportunities size
				if(oppsOptions.size() == 3)
					oppsOptions.remove(2);
				
				//Set base opportunity as master opportunity VH commented out -- we want to force the user to choose which is the master
				//masterOpportunity = baseOpportunity.Id;
					
				//SOQL through the opportunity
				for(Opportunity opp: Database.query(SOQLString + 'setOpportunitiesId')) {
					
					//Check for both opportunity Stages
					if(!CPQConstants.SET_MERGE_OPPORTUNITY_STAGES.contains(opp.StageName))
						throw new CustomException('One or more of the Opportunities you have selected to merge has an Opportunity stage that does not qualify for a merge. Opportunity stages must be prior to "Sent to Finance" in order to be merged.');
					
					//Add opportunities in list
					if(opp.Id == tempOpportunity.Secondary_Opportunity__c) {
						
						//Add secondary opportunity
						secondaryOpportunity = opp;	
						
						//Add secondary opportunity in options
						oppsOptions.add(new SelectOption(opp.Id, 'Opportunity 2 (' + opp.Name + ')'));	
					
					} else
						baseOpportunity = opp;	
				}
			}
		
		} catch(Exception e) {
                        
            //Add Error on page
            ApexPages.addMessages(e);
        }
	}
		
	/**
	 *	@description	:	Save method 
	 *						
	 *	@args			:	
	 *
	 *	@return			:	void
	 *
	 *	@revision Log	:	V_1.0 - 04/25/2017 - Created - Subhash Garhwal - CR-20170403-10807
	 *
	 **/
	public void doSave() {
		
        //Used to bypass the validation rule that prevents events from being inserted for opps without primary proposal
        isOpportunityMerge = true;
        
		//Merge Opportunitiy
		mergeOpportunities();
		
		if(ApexPages.hasMessages(ApexPages.Severity.ERROR))
            return;
	}
	
	/**
	 *	@description	:	This method is used to merge the both opportunities and update the opps
	 *						
	 *	@args			:	
	 *
	 *	@return			:	void
	 *
	 *	@revision Log	:	V_1.0 - 04/25/2017 - Created - Subhash Garhwal - CR-20170403-10807
	 *						V_1.1 - 08/08/2017 - Modified - Colin McGloin - Added default value of "Migrated" for Record Source for Secondary Opp
	 						V_1.2 - 02/14/2018 - Modified - Abhinav Sharma - CR-20180209-12037 - replace the Migrated with Merged in the record Source
	 *
	 **/
	public void mergeOpportunities() {

		//Save point
        Savepoint sp = Database.setSavepoint();
        
        try {
        	
        	//Check for master and non mater opps
        	if(baseOpportunity == null || secondaryOpportunity == null || String.isBlank(masterOpportunity))
        		throw new CustomException('Please select Master Opportunity');
        			
			//Check for both Opportunity records
			if(baseOpportunity != null && secondaryOpportunity != null) {

				//Instances of Opportunities (This will define Master and non-Master opportunity)
				Opportunity masterOpp = (baseOpportunity.Id == masterOpportunity) ? baseOpportunity.clone() : secondaryOpportunity.clone();
				Opportunity nonMasterOpp = (baseOpportunity.Id == masterOpportunity) ? secondaryOpportunity.clone() : baseOpportunity.clone();

				//Set Ids of records
				masterOpp.Id = (baseOpportunity.Id == masterOpportunity) ? baseOpportunity.Id : secondaryOpportunity.Id;
				nonMasterOpp.Id = (baseOpportunity.Id == masterOpportunity) ? secondaryOpportunity.Id : baseOpportunity.Id;
				
				//Check for Master Opportunity record type
				if(!CPQConstants.MAP_MASTER_RECORD_TYPE_WITH_NON_MASTER_RECORD_TYPES.containsKey(masterOpp.RecordType.DeveloperName)
					|| !CPQConstants.MAP_MASTER_RECORD_TYPE_WITH_NON_MASTER_RECORD_TYPES.get(masterOpp.RecordType.DeveloperName).contains(nonMasterOpp.RecordType.DeveloperName))
					throw new CustomException('Selected opportunities record types are not appropriate for merge');
											

				//Check for both opportunity Stages
				if(!CPQConstants.SET_MERGE_OPPORTUNITY_STAGES.contains(masterOpp.StageName) || !CPQConstants.SET_MERGE_OPPORTUNITY_STAGES.contains(nonMasterOpp.StageName))
					throw new CustomException('One or more of the Opportunities you have selected to merge has an Opportunity stage that does not qualify for a merge. Opportunity stages must be prior to "Sent to Finance" in order to be merged.');
				
				//List of Opportunity to update
				List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
				
				//Query through the Opportunity Record Type
				List<RecordType> oppMergedRecordType = [Select Id From RecordType Where SobjectType = 'Opportunity' AND DeveloperName =: CPQConstants.OPP_RECORD_TYPE_DEVELOPER_NAME_MERGED];
				
				//Change values of Non master opportunity
				nonMasterOpp.Parent_Opportunity__c = masterOpp.Id;
				nonMasterOpp.RecordTypeId = oppMergedRecordType.size() > 0 ? oppMergedRecordType[0].Id : nonMasterOpp.RecordTypeId;
				nonMasterOpp.SBQQ__PrimaryQuote__c = null;
				//Added by Colin McGloin - Issue--CR10810--QA--00005150
				//Added Buy Abhinav Sharma - 02/14/2018 - CR-20180209-12037
				nonMasterOpp.Record_Source__c = 'Merged';
				  
				//Add Opportunity in list
				opportunitiesToUpdate.add(nonMasterOpp);

				//Loop over the Opportunity field those need to merge in procrss
				for(String oppField : CPQConstants.SET_OPPORTUNITY_MERGE_FIELDS) {
					
					//Check field value in parent record
					if(masterOpp.get(oppField) == null && nonMasterOpp.get(oppField) != null)
						masterOpp.put(oppField, nonMasterOpp.get(oppField));
				}
				
				//Combine field values
				
				//Set Years on the Contract
				if(nonMasterOpp.Years_on_the_Contract__c != null && (masterOpp.Years_on_the_Contract__c == null
					|| masterOpp.Years_on_the_Contract__c < nonMasterOpp.Years_on_the_Contract__c))
					masterOpp.Years_on_the_Contract__c = nonMasterOpp.Years_on_the_Contract__c;
				
				
				//Add any additional value in Competitors
				masterOpp.Physician_Competitors__c = setMultiselectPicklistValues(masterOpp.Physician_Competitors__c, nonMasterOpp.Physician_Competitors__c);
				
				//Add Renewal Process Comments values
				if(String.isBlank(masterOpp.Renewal_Process_Comments__c) && String.isNotBlank(nonMasterOpp.Renewal_Process_Comments__c))
					masterOpp.Renewal_Process_Comments__c = nonMasterOpp.Renewal_Process_Comments__c;
				else if(String.isNotBlank(nonMasterOpp.Renewal_Process_Comments__c))
					masterOpp.Renewal_Process_Comments__c = (masterOpp.Renewal_Process_Comments__c + nonMasterOpp.Renewal_Process_Comments__c).left(500);
				
				//Commented Services_in_Contract__c - By Mahendra Swarnkar - spring clean up - 04/29/2019
				//Add addition values in Services in Contract
				//masterOpp.Services_in_Contract__c = setMultiselectPicklistValues(masterOpp.Services_in_Contract__c, nonMasterOpp.Services_in_Contract__c);
				
				//Add Master opportunity in list
				opportunitiesToUpdate.add(masterOpp);
				
				//List of Sobject to update
				List<Sobject> sobjectsToUpdate = new List<Sobject>();
				
				//Loop over the related list objects
				for(String sobjName : CPQConstants.MAP_OPPORTUNITY_CHILDREN_OBJECT_WITH_REFERENCE_FIELD_API_NAME.keySet()) {
					
					//Get relationship field
					String relationshipField = CPQConstants.MAP_OPPORTUNITY_CHILDREN_OBJECT_WITH_REFERENCE_FIELD_API_NAME.get(sobjName);
					
					//SOQL String
					String SOQL = 'Select Id, ' + relationshipField + ' From ' + sobjName + ' Where ' + relationshipField + ' =\'' + nonMasterOpp.Id + '\'';
					
					//SOQL query over the releated data
					for(Sobject sobj : Database.query(SOQL)) {
						
						//Check for object to update the additional field
						if(sobjName == 'SBQQ__Quote__c') {
							
							//Update Proposal fields
							sobj.put('SBQQ__Primary__c', false);
							sobj.put('SBQQ__Account__c', masterOpp.AccountId);
                            
                            //Bypass Proposal trigger
                            SBQQ_QuoteTriggerHelper.BYPASSPROPOSALTRIGGERFORMERGE = true;
                            
                            //VH - 08/25/2017 - Issue--CR11094--UAT--00005444
                            update sobj;
                            
                            //Bypass Proposal trigger
                            SBQQ_QuoteTriggerHelper.BYPASSPROPOSALTRIGGERFORMERGE = false;
            
            }
                        
						//Set Parent field name
						sobj.put(relationshipField, masterOpp.Id);
						
						//Add Sobject in list to update
						sobjectsToUpdate.add(sobj);		
					}
				}
				
				//Check for Opportunity size
				if(opportunitiesToUpdate.size() > 0){
				
					//Bypass opportunity trigger
          				OpportunityTriggerHelper.BYPASSOPPORTUNITYTRIGGERFORMERGE = true;
					update opportunitiesToUpdate;
					OpportunityTriggerHelper.BYPASSOPPORTUNITYTRIGGERFORMERGE = false;	
				}

				//List to hold Contract
				List<Contract> contracts = new List<Contract>();

				//Loop over the NonMaster Contract
				for(Contract Contract : [Select Id, SBQQ__RenewalOpportunity__c, SBQQ__Opportunity__c From Contract Where SBQQ__Opportunity__c =: nonMasterOpp.Id ]) {

					//Update renewal opportunity field
					Contract.SBQQ__RenewalOpportunity__c = masterOpp.Id;

					//Add to list
					contracts.add(Contract);
				}

			        //Check for Contract size
			        if(contracts.size() > 0) {
          
			          ContractTriggerHelper.BYPASS_Contract_TRIGGER_FOR_MERGE = true;
			          update contracts;
			          ContractTriggerHelper.BYPASS_Contract_TRIGGER_FOR_MERGE = false;
			        }
          

				//List of OpportunityContactRole
				List<OpportunityContactRole> nonMasterContactRoles = [Select Id, ContactId, OpportunityId, IsPrimary, Role From OpportunityContactRole Where OpportunityId =: nonMasterOpp.Id];

				//List to hold OpportunityContactRole
				List<OpportunityContactRole> oppContractRoleTobeUpdate = new List<OpportunityContactRole>();
				
				//Check for Size
				if(nonMasterContactRoles.size() > 0) {
					
					//Clone roles
					List<OpportunityContactRole> masterContactRolesToClone = nonMasterContactRoles.deepClone();
					
					//Loop over the cloned record to change opportunity
					for(OpportunityContactRole oCR : masterContactRolesToClone) {
						oCR.OpportunityId = masterOpp.Id;
					}

					//insert cloned records
					insert masterContactRolesToClone;

					//Delete existing data
					delete 	nonMasterContactRoles;

					//Loop to update Opportuntiy Contract role
					for(OpportunityContactRole oppCR : masterContactRolesToClone){

						oppCR.isPrimary = false;
							
						oppContractRoleTobeUpdate.add(oppCR);
					}

					//Update list
					update oppContractRoleTobeUpdate;

				}
				
				//List of OpportunityTeamMember
				List<OpportunityTeamMember> nonMasterOppTeamMembers = [Select Id, OpportunityId, OpportunityAccessLevel,TeamMemberRole, UserId From OpportunityTeamMember Where OpportunityId =: nonMasterOpp.Id];
				
				//Check for Size
				if(nonMasterOppTeamMembers.size() > 0) {
					
					//Clone Teams
					List<OpportunityTeamMember> masterOppTeamMembersToClone = nonMasterOppTeamMembers.deepClone();
					
					//Loop over the cloned record to change opportunity
					for(OpportunityTeamMember oTM : masterOppTeamMembersToClone)
						oTM.OpportunityId = masterOpp.Id;
					
					//insert cloned records
					insert masterOppTeamMembersToClone;
					
					//Delete existing data
					delete 	nonMasterOppTeamMembers;
				}
				
				//List of ContentDocumentLink
				List<ContentDocumentLink> nonMasterContentDocumentLinks = [Select Id, ContentDocumentId, LinkedEntityId, ShareType, Visibility From ContentDocumentLink Where LinkedEntityId =: nonMasterOpp.Id];
				
				//Check for Size
				if(nonMasterContentDocumentLinks.size() > 0) {
					
					//Clone Teams
					List<ContentDocumentLink> masterContentDocumentLinkToClone = nonMasterContentDocumentLinks.deepClone();
					
					//Loop over the cloned record to change opportunity
					for(ContentDocumentLink oTM : masterContentDocumentLinkToClone)
						oTM.LinkedEntityId = masterOpp.Id;
					
					//insert cloned records
					insert masterContentDocumentLinkToClone;
					//Delete existing data
					delete nonMasterContentDocumentLinks;
				}
				
				//Update Child Sobject data
				if(sobjectsToUpdate.size() > 0){
					SBQQ_QuoteTriggerHelper.BYPASSPROPOSALTRIGGERFORMERGE = true;
					TaskTriggerHelper.BYPASS_TASK_TRIGGER_FOR_MERGE = true;
					EventTriggerHelper.BYPASS_EVENT_TRIGGER_FOR_MERGE = true;
					ReferenceTriggerHelper.BYPASS_REFERENCE_TRIGGER_FOR_MERGE = true;
					TeamMembershipTriggerHelper.BYPASS_TEAMMEMBERSHIP_TRIGGER_FOR_MERGE = true;
					SBQQ_SubscriptionTriggerHelper.BYPASS_SUBSCRIPTION_TRIGGER_FOR_MERGE = true;
          
					update sobjectsToUpdate;
          
					SBQQ_QuoteTriggerHelper.BYPASSPROPOSALTRIGGERFORMERGE = false;
					TaskTriggerHelper.BYPASS_TASK_TRIGGER_FOR_MERGE = false;
					EventTriggerHelper.BYPASS_EVENT_TRIGGER_FOR_MERGE = false;
					ReferenceTriggerHelper.BYPASS_REFERENCE_TRIGGER_FOR_MERGE = false;
					TeamMembershipTriggerHelper.BYPASS_TEAMMEMBERSHIP_TRIGGER_FOR_MERGE = false;
					SBQQ_SubscriptionTriggerHelper.BYPASS_SUBSCRIPTION_TRIGGER_FOR_MERGE = false;
				}	
				//Winner Opp Id
				winnerOppId = masterOpp.Id;
				
			}
		} 
		catch(Exception e) {
            
            		//Roll Back changes
            		Database.rollback(sp);
            
            		//Add Error on page
            		ApexPages.addMessages(e);

        	}
	}
	
	/**
	 *	@description	:	This method is used to add addition values in multiselect picklist fields
	 *						
	 *	@args			:	String,String
	 *
	 *	@return			:	String
	 *
	 *	@revision Log	:	V_1.0 - 04/26/2017 - Created - Subhash Garhwal - CR-20170403-10807
	 *
	 **/
	public String setMultiselectPicklistValues(String masterValue, String nonMasterValue) {
		
		//String to return
		String updatedMasterValue = '';
		
		//Add any additional value in Competitors
		if(String.isBlank(masterValue) && String.isNotBlank(nonMasterValue))
			updatedMasterValue = nonMasterValue;
		
		else if(String.isNotBlank(nonMasterValue)){
			
			//Set to hold all the Competitors values
			Set<String> setExistingCompetitoresValues = new Set<String>();
			
			//Add all the existing values
			setExistingCompetitoresValues.addAll(masterValue.split(';'));
			setExistingCompetitoresValues.addAll(nonMasterValue.split(';'));
			
			//Reset Competitors values
			updatedMasterValue = '';
			
			//Loop over all the competitors values
			for(String compVal : setExistingCompetitoresValues)
				updatedMasterValue += compVal + ';';
			
			
			updatedMasterValue.removeEnd(';');			
		}
		
		//Return
		return updatedMasterValue;
	}
}