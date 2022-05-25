/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest(seeAllData = false)
private class Test_Scope {
/**
    Purpose         :   Test class for ScopeHelper
                
    Create By       :   Abhinav Sharma
    
    Created Date    :   11/26/2015
    
    Revision Log    :   v1.0 - Created - Abhinav Sharma - CR-20151022-9346 - 100% Code Coverage
						v1.1 - Modified - Mahendra Swarnkar - CR-20151022-9346 - 12/08/2015 - 100% Code Coverage
**/    
    
	static testMethod void testScopeDupPreventer() {
        
        //Bypassing triggers. So, then test data can be created with un-necessary execution of existing code
        Util.BypassAllTriggers = true;
        Util.IsTest(true);
        
		// First make sure there are no scope already in the system
		// that have the name used for testing
		Set<String> setOfNameStrings = new Set<String>();
        setOfNameStrings.add('test1');
        setOfNameStrings.add('test2');
        setOfNameStrings.add('test3');
        setOfNameStrings.add('test4');
        setOfNameStrings.add('test5');
		System.assert([SELECT count() FROM Lead WHERE Name != null AND Name IN : setOfNameStrings] == 0);

        //Seed the database with some scopes, and make sure they can
        //be bulk inserted successfully.
        Scope__c sc_1 = new Scope__c(Name='test1', Active__c = true, Description__c = 'Testing 1');
        Scope__c sc_2 = new Scope__c(Name='test4', Active__c = true, Description__c = 'Testing 2');
        Scope__c sc_3 = new Scope__c(Name='test5', Active__c = true, Description__c = 'Testing 3');
        
        //List of scopes
        List<Scope__c> scopes = new List<Scope__c>();
        scopes.add(sc_1);
        scopes.add(sc_2);
        scopes.add(sc_3);
        
        //Start Test from here
        Test.startTest();
        
        //Enabling triggers again
        Util.BypassAllTriggers = false;
        
        //Insert scopes
        insert scopes;
        
        //Asserting for the results
        scopes = [SELECT ID, Name FROM Scope__c ORDER BY Name ASC];
        System.assertEquals(3, scopes.size());

        //Now make sure that some of these scopes can be changed and
        //then bulk updated successfully. Note that scopes[1] is not
        //being changed, but is still being passed to the update
        //call. This should be OK.
        scopes[1].Name = 'test2';
        scopes[2].Name = 'test3';
		update scopes;

        //Make sure that single row scope duplication prevention works
        //on insert.
        Scope__c sc = new Scope__c(Name='test1', Active__c = true, Description__c = 'Testing 4');
        
		try {
			insert sc;
			System.assert(false);
        } catch (DmlException e) {
            System.assert(e.getNumDml() == 1);
            System.assert(e.getDmlIndex(0) == 0);
            System.assert(e.getDmlFields(0).size() == 1);
            System.assert(String.valueOf(e.getDmlFields(0)[0]) == 'Name');
            System.assert(e.getDmlMessage(0).indexOf(System.Label.ERROR_A_SCOPE_WITH_SAME_NAME_EXIST) > -1);
		}

        //Make sure that single row scope duplication prevention works
        //on update.
        sc = new Scope__c(Id = scopes[0].Id, Name='test2', Active__c = true, Description__c = 'Testing 5');
        try {
        	update sc;
        	System.assert(false);
        } catch (DmlException e) {
            System.assert(e.getNumDml() == 1);
            System.assert(e.getDmlIndex(0) == 0);
            System.assert(e.getDmlFields(0).size() == 1);
            System.assert(String.valueOf(e.getDmlFields(0)[0]) == 'Name');
            System.assert(e.getDmlMessage(0).indexOf(System.Label.ERROR_A_SCOPE_WITH_SAME_NAME_EXIST) > -1);
        }

        //Make sure that bulk scope duplication prevention works on
        //insert. Note that the first item being inserted is fine,
        //but the second and third items are duplicates. Note also
        //that since at least one record insert fails, the entire
        //transaction will be rolled back.
        sc = new Scope__c(Name='test4', Active__c = true, Description__c = 'Testing 6');
        Scope__c sc_4 = new Scope__c(Name='test2', Active__c = true, Description__c = 'Testing 7');
        Scope__c sc_5 = new Scope__c(Name='test3', Active__c = true, Description__c = 'Testing 8');
        Scope__c[] dups = new Scope__c[] {sc, sc_4, sc_5};
        try {
        	insert dups;
            System.assert(false);
        } catch (DmlException e) {
            System.assert(e.getNumDml() == 2);
            System.assert(e.getDmlIndex(0) == 1);
            System.assert(e.getDmlFields(0).size() == 1);
            System.assert(String.valueOf(e.getDmlFields(0)[0]) == 'Name');
            System.assert(e.getDmlMessage(0).indexOf(System.Label.ERROR_A_SCOPE_WITH_SAME_NAME_EXIST) > -1);
            System.assert(e.getDmlIndex(1) == 2);
            System.assert(e.getDmlFields(1).size() == 1);
            System.assert(String.valueOf(e.getDmlFields(1)[0]) == 'Name');
            System.assert(e.getDmlMessage(1).indexOf(System.Label.ERROR_A_SCOPE_WITH_SAME_NAME_EXIST) > -1);
        }     

        //Make sure that bulk scope duplication prevention works on
        //update. Note that the first item being updated is fine,
        //because the name is new, and the second item is
        //also fine, but in this case it's because the name
        //doesn't change. The third case is flagged as an
        //error because it is a duplicate of the name of the
        //first scope's value in the database, even though that value
        //is changing in this same update call. It would be an
        //interesting exercise to rewrite the trigger to allow this
        //case. Note also that since at least one record update
        //fails, the entire transaction will be rolled back.
        sc = new Scope__c(Id = scopes[0].Id, Name='test4', Active__c = true);
        sc_4 = new Scope__c(Id = scopes[1].Id, Name='test2', Active__c = true);
        sc_5 = new Scope__c(Id = scopes[2].Id, Name='test1', Active__c = true);
        dups = new Scope__c[] {sc, sc_4, sc_5};
		try {
			update dups;
			System.assert(false);
        } catch (DmlException e) {
            System.debug(e.getNumDml());
            System.debug(e.getDmlMessage(0));
            System.assert(e.getNumDml() == 1);
            System.assert(e.getDmlIndex(0) == 2);
            System.assert(e.getDmlFields(0).size() == 1);
            System.assert(String.valueOf(e.getDmlFields(0)[0]) == 'Name');
            System.assert(e.getDmlMessage(0).indexOf(System.Label.ERROR_A_SCOPE_WITH_SAME_NAME_EXIST) > -1);
        }

        // Make sure that duplicates in the submission are caught when
        // inserting scopes. Note that this test also catches an
        // attempt to insert a scope where there is an existing
        // duplicate.
        sc = new Scope__c(Name='test4', Active__c = true);
        sc_4 = new Scope__c(Name='test4', Active__c = true);
        sc_5 = new Scope__c(Name='test3', Active__c = true);
		dups = new Scope__c[] {sc, sc_4, sc_5};
		try {
            insert dups;
            System.assert(false);
		} catch (DmlException e) {
            System.assert(e.getNumDml() == 2);
            System.assert(e.getDmlIndex(0) == 1);
            System.assert(e.getDmlFields(0).size() == 1);
            System.assert(String.valueOf(e.getDmlFields(0)[0]) == 'Name');
            System.assert(e.getDmlMessage(0).indexOf(System.Label.ERROR_ANOTHER_SCOPE_HAS_SAME_NAME) > -1);
            System.assert(e.getDmlIndex(1) == 2);
            System.assert(e.getDmlFields(1).size() == 1);
            System.assert(String.valueOf(e.getDmlFields(1)[0]) == 'Name');
            System.assert(e.getDmlMessage(1).indexOf(System.Label.ERROR_A_SCOPE_WITH_SAME_NAME_EXIST) > -1);
		}

        // Make sure that duplicates in the submission are caught when
        // updating scopes. Note that this test also catches an attempt
        // to update a scope where there is an existing duplicate.
        sc = new Scope__c(Id = scopes[0].Id, Name='test4', Active__c = true);
        sc_4 = new Scope__c(Id = scopes[1].Id, Name='test4', Active__c = true);
        sc_5 = new Scope__c(Id = scopes[2].Id, Name='test2', Active__c = true);
		dups = new Scope__c[] {sc, sc_4, sc_5};
        try {
            update dups;
            System.assert(false);
        } catch (DmlException e) {
            System.assert(e.getNumDml() == 2);
            System.assert(e.getDmlIndex(0) == 1);
            System.assert(e.getDmlFields(0).size() == 1);
            System.assert(String.valueOf(e.getDmlFields(0)[0]) == 'Name');
            System.assert(e.getDmlMessage(0).indexOf(System.Label.ERROR_ANOTHER_SCOPE_HAS_SAME_NAME) > -1);
            System.assert(e.getDmlIndex(1) == 2);
            System.assert(e.getDmlFields(1).size() == 1);
            System.assert(String.valueOf(e.getDmlFields(1)[0]) == 'Name');
            System.assert(e.getDmlMessage(1).indexOf(System.Label.ERROR_A_SCOPE_WITH_SAME_NAME_EXIST) > -1);
        }
        
        //Test will stop here
        Test.stopTest();
	}
    
    //Added By Mahendra swarnkar - 12/08/2015 - CR-20151022-9346
    static testMethod void testDeleteScopeMTMWithScope() {
        
        //Bypassing triggers. So, then test data can be created with un-necessary execution of existing code
        Util.BypassAllTriggers = true;
        Util.IsTest(true);
        
        //Insert Programs records
        List<Program__c> programs = new List<Program__c>();
        programs.add(new Program__c(Name = 'Test',Create_memberships__c = 'NO',Program_Formal_Name__c = 'Test1' ));
        programs.add(new Program__c(Name = 'Test',Create_memberships__c = 'NO',Program_Formal_Name__c = 'Test2' ));
        insert programs;
        
        //Insert scope records
        List<Scope__c> scopes = new List<Scope__c>();
        scopes.add(new Scope__c(Name='test1', Active__c = true));
        scopes.add(new Scope__c(Name='test2', Active__c = true));
        insert scopes;
        
        //Insert Scope MtM records
        List<Scope_MtM__c> scopeMtMs = new List<Scope_MtM__c>();
        scopeMtMs.add(new Scope_MtM__c(Name = 'Test' , Program__c = programs[0].Id, Scope__c = scopes[0].Id ));
        scopeMtMs.add(new Scope_MtM__c(Name = 'Test' , Program__c = programs[1].Id, Scope__c = scopes[0].Id ));
        scopeMtMs.add(new Scope_MtM__c(Name = 'Test' , Program__c = programs[0].Id, Scope__c = scopes[1].Id ));
        scopeMtMs.add(new Scope_MtM__c(Name = 'Test' , Program__c = programs[1].Id, Scope__c = scopes[1].Id ));
        insert scopeMtMs;
        
        //Test starts from here
        Test.startTest();
        
        //Setting flag value to enable triggers
        Util.BypassAllTriggers = false;
        
        //delete the scope records
        delete scopes;
        
        //Query through scope MtMs
        scopeMtMs = new List<Scope_MtM__c>();
        scopeMtMs = [Select id from Scope_MtM__c];
        
        //Asserts on results
        system.assertEquals(0, scopeMtMs.size());
        
        //Test ends here
        Test.stopTest();       
    }
}