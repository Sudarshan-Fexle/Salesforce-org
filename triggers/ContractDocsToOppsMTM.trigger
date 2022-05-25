//v1.0 - Created
//V1.1 - v1.1 - Modified By - Abhinav Sharma - 07/07/2014 - CR-20140618-5849 - Catch DML errors in triggers to reduce exception emails to SFAdmin
//V1.2 - Modified By - Subhash Garhwal - 09/27/2017 - CR-20170926-11418 -  Added the Util.areTriggersOnThisObjectBypassed flag.
trigger ContractDocsToOppsMTM on Contract_Docs_to_Opps_MtM__c (after delete, after insert, after update) {
    
    //return immediately if method returns true	
    if(Util.areTriggersOnThisObjectBypassed('Contract_Docs_to_Opps_MtM__c')) return;	

    try {
        if (trigger.isAfter && !trigger.isDelete) {
            // get the opp ids
            Set<Id> oppIds = new Set<Id>();
            for (Contract_Docs_to_Opps_MtM__c doc : trigger.new)
                oppIds.add(doc.Opportunity__c);
            // get all opps
            List<Opportunity> opps = [SELECT Id, Signed_Opportunity_Contract__c FROM Opportunity WHERE Id IN :oppIds AND Signed_Opportunity_Contract__c != null];
            // get the contract ids
            Set<Id> contractIds = new Set<Id>();
            for (Opportunity opp : opps)
                contractIds.add(opp.Signed_Opportunity_Contract__c);
                
            // only add docs to contracts if our contractId list has something in it
            if (contractIds.size() > 0)
                ContractsToContractDocsMTMUtilities.AddDocsToContract(contractIds);
        }
    //Catching DML Exceptions
    } catch(DMLException e) {

        //Add Error Message on Page
        if(Trigger.isDelete)
            Trigger.Old[0].addError(e.getDmlMessage(0));
        else
            Trigger.New[0].addError(e.getDmlMessage(0));

    //Catching all Exceptions
    } catch(Exception e) {

        //Add Error Message on Page
        if(Trigger.isDelete)
            Trigger.Old[0].addError(e.getMessage());
        else
            Trigger.New[0].addError(e.getMessage());
    }
}