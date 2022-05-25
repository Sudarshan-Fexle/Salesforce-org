/**
 * 	@description	:	Helper class for Expense Authorization Trigger.
 * 
 * 	@Created By		:	Victor Hanson
 * 
 *  @Change History :   V1.0 - Created - 01/27/2015 - Victor Hanson - CR-20140520-5562
 *                      V1.1 - Modified By - Mahendra SwarnKar - 05/01/2019 - Commented the class per Spring Clean up - CR-20190501-13061
 * 
 **/
public class ExpenseAuthTriggerHelper {
	
    /**
     * @description: populate the Expense Auth approver with the approver on the related Budget G/L
     **/
    /*public static void populateApprover(list<Expense_Authorization__c> newListExpenseAuth) {
        
        //get all registrations related to expense auths
        set<Id> registrationIdSet = new set<Id>();
        for (Expense_Authorization__c eAuth : newListExpenseAuth) registrationIdSet.add(eAuth.Event_Registration__c);
        
        map<Id, Event_Registration__c> mapRegistrations = new map<Id, Event_Registration__c>([SELECT Id, Advisory_Event__r.Cost_Center__r.Approver__c, Advisory_Event__r.Parent_Event__r.Cost_Center__r.Approver__c FROM Event_Registration__c WHERE Id IN :registrationIdSet]);
        
        for (Expense_Authorization__c eAuth : newListExpenseAuth) {
            
            if (eAuth.Status__c == 'New') {
                
                //reset the approver to null and get the related registration
                eAuth.Approver__c = null;
                Event_Registration__c reg;
                if (mapRegistrations.size() > 0) reg = mapRegistrations.get(eAuth.Event_Registration__c);
                
                if (reg != null) {
                    eAuth.Approver__c = reg.Advisory_Event__r.Cost_Center__r.Approver__c;
                    
                    //if the meeting's approver is null, check the parent's approver value
                    if (eAuth.Approver__c == null)
                        eAuth.Approver__c = reg.Advisory_Event__r.Parent_Event__r.Cost_Center__r.Approver__c;
                }
            }
        }
    }*/
    
    /**
     * @description: submit the expense authorization for approval
     * 
     * @return: list of error messages
     **/
    public static list<string> submitExpenseForApproval(Id expenseAuthId) {
        
        list<string> errors = new list<string>();
        
            /*try {
            //get the expense authorization record
            Expense_Authorization__c eAuth = [SELECT Id, Approver__c FROM Expense_Authorization__c WHERE Id = :expenseAuthId];
            
            
            if (eAuth.Approver__c != null) {
                // Create an approval request for the Opportunity
                Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                req1.setComments('Submitting request for approval');
                req1.setObjectId(expenseAuthId);
                req1.setNextApproverIds(new Id[] { eAuth.Approver__c });
                
                // Submit the approval request for the Opportunity
                Approval.ProcessResult result = Approval.process(req1);
                
                if (!result.isSuccess()) {
                    for (database.error e : result.getErrors())
                        errors.add(Label.ExpenseAuth_SubmitResultError + ' ' + e.getMessage());
                }
            }
            else {
                errors.add(Label.ExpenseAuth_MissingApproverMessage);
            }
        }
        catch(DMLException e) {
			//Return DML errors to the VF Page
			errors.add(e.getDMLMessage(0));
		}
		catch(Exception e) {
			//Return any errors to the VF Page
			errors.add(e.getMessage());
		}*/
        
        return errors;
    }
}