/**
 * 
 *  @description	: 	Checks the "Renewal Proposed" checkbox on Contract.  Allows users without the "Activate Contract" permission to create the renewal proposal.
 *
 *  @return         :   void
 *
 *  @revision Log   :   V_1.0 - 08/07/2017 - Created - Victor Hanson - Issue--CR11106--UAT--00005359
 *                      V_1.1 - Modified By - Dipesh Gupta - CR-20200102-13584 - 5/29/2020 -
 * 
**/
public without sharing class ContractRenewalProposalController {
	
    //Variables
    public Contract contract { get; set; }
    
    /**
     * 
     *  @description	: 	Constructor
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - 08/07/2017 - Created - Victor Hanson - Issue--CR11106--UAT--00005359
     * 
     **/
    public ContractRenewalProposalController() {
        
        //get the contract id
        Id contractId = System.currentPageReference().getParameters().get('id');
        
        list<Contract> contracts = [SELECT Id, SBQQ__RenewalQuoted__c, Active__c FROM Contract WHERE Id = :contractId];
        if (contracts.size() > 0) contract = contracts[0];
        else throw new customException('No contract exists with ID \'' + contractId + '\'');
    }
    
    /**
     * 
     *  @description	: 	update the Renewal Proposed field on Contract to true.
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - 08/07/2017 - Created - Victor Hanson - Issue--CR11106--UAT--00005359
     * 
     **/
    public void updateContract() {
        
        try {
            
            //validate the contract meets the requirements
            validate();
            
            //set the Renewal Proposed field to true and update the contract
            contract.SBQQ__RenewalQuoted__c = true;
            
            //bypass entity population triggers, because they contribute to SOQL limits
            Util.bypassEntityPopulation = true;
            
            update contract;
            
            //add success message to page
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM, Label.RENEWAL_SUCCESS));
        }
        catch(exception e) {
            
            //if there was an exception (most likely validation related), display it on the page
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
        }
    }
    
    /**
     * 
     *  @description	: 	verify that the user has permission to use the renewal proposal button and that it has not already been renewed
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - 08/07/2017 - Created - Victor Hanson - Issue--CR11106--UAT--00005359
     * 
     **/
    private void validate() {
        
        //Modified By - Dipesh Gupta - CR-20200102-13584 - 5/29/2020 -
        //create the custom permission reader
        /*CustomPermissionsReader cpr = new CustomPermissionsReader();
        boolean hasRenewalButtonAccess = cpr.hasPermission(CPQConstants.CUSTOM_PERMISSION_RENEWAL_PROPOSAL_BUTTON);*/
        boolean hasRenewalButtonAccess = FeatureManagement.checkPermission(CPQConstants.CUSTOM_PERMISSION_RENEWAL_PROPOSAL_BUTTON);
        
        //verify the use has the custom permission required
        if (hasRenewalButtonAccess) {
            
            //check if the renewal has already been proposed
            if (contract.SBQQ__RenewalQuoted__c) {
                
                //add an error because the renewal has already been proposed
                throw new CustomException(Label.RENEWAL_ALREADY_PROPOSED);
            }
            else if (!contract.Active__c) {
                
                //add an error because the Contract has to be Activated prior to creating the renewal proposal
                throw new CustomException(Label.RENEWAL_CONTRACT_NOT_ACTIVATED);
            }
            
        }
        else {
            
            //Add Error on page
            throw new CustomException(Label.RENEWAL_BUTTON_NO_ACCESS);
        }
    }
}