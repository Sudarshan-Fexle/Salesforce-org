/**
 *  Purpose         :   Apex class to overide standard edit button of ContractABC
 *                      
 *  Created By      :   Subhash Garhwal
 * 
 *  Created Date    :   8/11/2016
 * 
 *  Revision Logs   :   V_1.0 - Issue--CR11094--UAT--00005355
 * 						V_1.1 - Modified - 09/14/2017 - Victor Hanson - Issue--CR11183--QA--00005771 - Added isShadowRecord variable
 * 
 **/
public without sharing class OverrideContractABCEditController {

	//variables
	public contract__c contract{get;set;} 

	//Constructor
	public OverrideContractABCEditController(ApexPages.StandardController controller) {

		//Contract record
        contract = (contract__c)controller.getRecord();

	}
    
    /**
     *  @description    :   This method is used to determine if it's a shadow record
     *
     *  @args           :   
     *
     *  @return         :   boolean
     *
     **/
    public boolean isShadowRecord {
        get {
            if (isShadowRecord == null) {
                contract = [Select Id, Record_Source__c From contract__c where Id =: contract.Id];
                
                isShadowRecord = contract.Record_Source__c == 'Shadow';
            }
            return isShadowRecord;
        }
        set;
    }
    
    /**
     *  @description    :   This method is used to check Record Source
     *
     *  @args           :   
     *
     *  @return         :   Pagereference
     *
     **/
    public Pagereference checkRecordSource() {

		if(isShadowRecord) {

			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Contract Shadow record cannot be edited directly.');
            ApexPages.addMessage(myMsg);
            return null;
		}
		else
			return new Pagereference('/' + contract.Id +'/e?retURL=/'+contract.Id +'&nooverride=1');
    }
}