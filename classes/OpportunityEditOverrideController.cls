/**
 *  Description     :  Controller for OpportunityEditIverride VF page
 *
 *  Created By      :  Subhash Garhwal
 *
 *  Created Date    :  06/13/2016
 *
 *  Revision Logs   :   V_1.0 - Created - Subhash Garhwal - CR-20160414-9762 
 *
 **/
public with sharing class OpportunityEditOverrideController {
	
	//Variables
	public Opportunity opp {get;set;}
	
	//Standard controller constructor
	public OpportunityEditOverrideController(ApexPages.StandardController controller) {
		
        //Getting/Reteriving current context opportunity record details
        opp = (Opportunity) controller.getRecord();
	}
	
	/**
	 *	@description		:	This method is used to redirect user on appropriate layout/VF page according to opportunity record type
	 *
	 *	@args			:
	 *
	 *	@return			:	PageReference
	 *
	 *	@revision Logs		:	Created - Subhash Garhwal - 06/13/2016 - CR-20160414-9762
	 					Mahendra Swarnkar - 03/17/2020 - CR-20200217-13756 - RT deleted : Contract LOA From Opportunity
	 *
	 **/
	public PageReference redirect() {
		
		//Create a new PageReference instance
        PageReference pageRef;
        
        //Commented by Mahendra Swarnkar - 03/17/2020 - CR-20200217-13756 - RT deleted : Contract LOA From Opportunity. - START HERE
        //Check for Opportunity Record Type in map
		/*if(opp.RecordType.DeveloperName == CPQConstants.OPPORTUNITY_RECORD_TYPE_DEVELOPERNAME_CONTRACT_LOA) {
			
			//Setting PageReference to navigate the user to custom VF page        
            pageRef = new PageReference(CPQConstants.APEX_URL_INITIAL_PREFIX + CPQConstants.OPPORTUNITY_CONTRACT_LOA_NEW_AND_EDIT_PAGE_OPPORTUNITYCONTRACTLOAEDIT);
            pageRef.getParameters().put(CPQConstants.ID_PARAM, opp.Id);
        
		} /*else if(CPQConstants.SET_OPPORTUNITY_CPQ_SPECIFIC_PROGRAM_OPP_RT_DEVELOPER_NAME.contains(opp.RecordType.DeveloperName)) {
			
			//Setting PageReference to navigate the user to custom VF page        
            pageRef = new PageReference(CPQConstants.APEX_URL_INITIAL_PREFIX + 'OpportunityProgramOppNBBEditView');
            pageRef.getParameters().put(CPQConstants.ID_PARAM, opp.Id);
            
		//Redirect user on std edit
		}*/ //else {
		// END Here
			
			//Set PageReference to navigate to std edit
			pageRef = new PageReference(CPQConstants.BACK_SLASH_VAR + opp.Id + CPQConstants.RECORD_EDIT);
            		//VH 4/14 - CR-10807 - add all existing params to the page.  This was done to fix a bug where record type change wouldn't carry forward.
            		pageRef.getParameters().putAll(ApexPages.currentPage().getParameters());			
           		pageRef.getParameters().put(CPQConstants.retURL, ApexPages.currentPage().getParameters().get(CPQConstants.retURL));
            		pageRef.getParameters().put(CPQConstants.CONFIRMATIONTOKEN, ApexPages.currentPage().getParameters().get(CPQConstants.CONFIRMATIONTOKEN));
			pageRef.getParameters().put(CPQConstants.NO_OVERRIDE, '1');
	
		
		//Return
		return pageRef;
	}
}