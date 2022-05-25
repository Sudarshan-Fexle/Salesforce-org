//v1.0 - Created
//V1.1 - v1.1 - Modified By - Abhinav Sharma - 07/07/2014 - CR-20140618-5849 - Catch DML errors in triggers to reduce exception emails to SFAdmin
//V1.2 - Modified By - Subhash Garhwal - 09/27/2017 - CR-20170926-11418 -  Added the Util.areTriggersOnThisObjectBypassed flag.
//V1.3 - Modified By - Mahendra Swarnkar - 10/11/2017 - CR-20170928-11580 - Apollo Release - Added new method "populateEntityField"
trigger ContractsToContractDocsMTM on Contracts_to_Contract_Docs_MtM__c (after delete, after insert, after update, before insert, before update) {
    
	try {
        
        //Check for Event type
        if(Trigger.isBefore) {
         
            //Check for Event type
            if(Trigger.isInsert || Trigger.isUpdate) {
            	
                //V1.3 - Modified By - Mahendra Swarnkar - 10/11/2017 - CR-20170928-11580 - Apollo Release
                ContractsToContractDocsMTMUtilities.populateEntityField(Trigger.New,Trigger.oldMap);
        	}
        }
        
        //return immediately if method returns true	
    	if(Util.areTriggersOnThisObjectBypassed('Contracts_to_Contract_Docs_MtM__c')) return;
    
        //Check for Event type 
        if (trigger.isAfter && !trigger.isDelete) {
            
            // Add documents to the opportunities that are associated with these contracts.
            ContractsToContractDocsMTMUtilities.AddDocsToOpps(trigger.newMap);
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