/**
 * 	@description	:	Test class for the ExpenseAuthTriggerHelper Class.
 * 
 * 	@Created By		:	Victor Hanson
 * 
 * 	@Change History	:	V1.0 - Created - 01/27/2015 - Victor Hanson - CR-20140520-5562
 * 						V1.1 - Modified By - Mahendra SwarnKar - 05/01/2019 - Commented the class per Spring Clean up - CR-20190501-13061
 * 
 **/
@isTest
public class Test_ExpenseAuthTriggerHelper {
	//returns a budget GL record
    /*public static Cost_Center__c createCostCenter(Id userId, boolean createAndInsert) {
        
        Cost_Center__c costCenter = new Cost_Center__c(Approver__c = userId,
                                                   Description__c = 'Test');
        if (createAndInsert) insert costCenter;
        return costCenter;
    }*/
    
    /**
     * @description: For the first record, set the Approver on the Budget G/L record, then update the Expense Auth record and verify that the Approver field there is updated as expected.
	 *				 For the second record, leave the Approver blank on the main Budget G/L.  Add a Budget G/L and Approver for a Parent Meeting. Then update the Expense Auth record and verify that the Approver field is updated as expected.
	 *				 For the third record, leave the Approver blank on the main Budget G/L.  Update the Expense Auth record and verify that the Approver field remains blank.
     **/
    static testMethod void test1() {
        /*
        //create a contact
        Contact con = TestUtilities.CreateNewContact(true);
        
        //create 3 budget G/L
        Cost_Center__c budgetGL_Approver = createCostCenter(userInfo.getUserId(), false);
        Cost_Center__c budgetGL_noApprover = createCostCenter(null, false);
        Cost_Center__c budgetGL3 = createCostCenter(null, false);
        list<Cost_Center__c> budgetGLs = new list<Cost_Center__c> { budgetGL_Approver, budgetGL_noApprover, budgetGL3 };
        insert budgetGLs;
        
        //create the master
        Advisory_Event__c meeting1 = TestUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_SERIES, budgetGL_Approver.Id, false);
        Advisory_Event__c meeting2 = TestUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_SERIES, budgetGL_noApprover.Id, false);
        list<Advisory_Event__c> meetings = new list<Advisory_Event__c> { meeting1, meeting2  };
        insert meetings;
        
        //insert child meeting
        Advisory_Event__c meeting2Child = TestUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_SERIES, budgetGL_noApprover.Id, false);
        meeting2Child.Parent_Event__c = meeting2.Id;
        insert meeting2Child;
        
        //create registration
        Event_Registration__c reg1 = TestUtilities.createRegistration(meeting1.Id, con.Id, false);
        Event_Registration__c reg2Child = TestUtilities.createRegistration(meeting2Child.Id, con.Id, false);
        list<Event_Registration__c> registrations = new list<Event_Registration__c> { reg1, reg2Child };
        insert registrations;
        
        //create expense auth
        Expense_Authorization__c eAuth1 = new Expense_Authorization__c(Event_Registration__c = reg1.Id,
                                                                       Start_Date__c = system.today(),
                                                                       End_Date__c = system.today(),
                                                                       Amount__c = 123,
                                                                       Status__c = 'New',
                                                                       Type__c = 'Accomodations');
        Expense_Authorization__c eAuth2Child = new Expense_Authorization__c(Event_Registration__c = reg2Child.Id,
                                                                            Start_Date__c = system.today(),
                                                                            End_Date__c = system.today(),
                                                                            Amount__c = 123,
                                                                            Status__c = 'New',
                                                                            Type__c = 'Accomodations');
        list<Expense_Authorization__c> expenseAuths = new list<Expense_Authorization__c> { eAuth1, eAuth2Child };
        insert expenseAuths;
        
        //get the updated expense auth records
        expenseAuths = [SELECT Id, Approver__c FROM Expense_Authorization__c WHERE Id IN :expenseAuths];
        
        for (Expense_Authorization__c eAuth : expenseAuths) {
            if (eAuth.Id == eAuth1.Id) {
                system.assertEquals(budgetGL_Approver.Approver__c, eAuth.Approver__c);
            }
            
            else if (eAuth.Id == eAuth2Child.Id) {
                system.assertEquals(null, eAuth.Approver__c);
            }
        }
        
        //add an approver to the budget G/L related to the parent2 meeting
        budgetGL_noApprover.Approver__c = userInfo.getUserId();
        update budgetGL_noApprover;
        
        //now update the eAuth2Child
        update eAuth2Child;
        
        //verify the eAuth2Child record now has an approver due to the parent meeting's BudgetGL Approver being populated
        eAuth2Child = [SELECT Id, Approver__c FROM Expense_Authorization__c WHERE Id = :eAuth2Child.Id];
        system.assertEquals(userInfo.getUserId(), eAuth2Child.Approver__c);
    */
	}
}