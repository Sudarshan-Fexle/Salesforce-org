/**
 *  Description     :   Test Class to CheckCaseFieldPopulatedToCreateCRClass
 *
 *  Created By      :   Neha Sharma  
 * 
 *  Created Date    :   06/07/2021
 * 
 *  Revision Logs   :   V_1.0 - Created - CR-20211005-15489
 **/
@Istest(seeAllData = false)
private class TestCheckCaseFieldPopulatedToCreateCR {
    @testsetup Static void setupData() {
        
        //Create Account record
        Account acc = new Account();
        //inserting account record
        insert acc;
        
        //Create Contact record
        Contact con = new Contact(LastName = 'Test', AccountId = acc.Id, Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855');
        //inserting contact record
        insert con;
        
        //Create IS_System__c record
        IS_System__c isSystem = new IS_System__c();
        isSystem.Name = 'Test';
        isSystem.Status__c = 'Active';
        //inserting IS_System__c record
        insert isSystem;
        
        //List to add Cases record
        List<Case> cases = new List<Case>();
        //Add cases records into the list
        cases.add(new Case(IS_System__c = isSystem.Id, Users_Affected__c = 'Single Department', Requested_Completion_Date__c = System.Today().addDays(10), 
                           Priority = 'Standard', Change_Request_Title__c = 'Change the Field', ContactId = con.Id, Steps_to_Reproduce_MS__c = 'Test Steps to reproduce', 
                           Summary__c = 'Test step of Summary', Change_Request_Level__c = 'L1 Weekly'));
        cases.add(new Case(IS_System__c = isSystem.Id, Users_Affected__c = 'Single Department', Requested_Completion_Date__c = System.Today().addDays(10), 
                           Priority = 'Standard', ContactId = con.Id, Steps_to_Reproduce_MS__c = 'Test Steps to reproduce', 
                           Summary__c = 'Test step of Summary', Change_Request_Level__c = 'L1 Weekly'));
        
        //inserting cases records
        insert cases;
    }
    //Method to test the functionality. 
    @istest static void testCheckCaseFieldPopulatedToCreateCRClass() {
        
        //query on the Cases records. 
        List<Case> cse = [Select Id From Case];
        
        //Setting the parameters on the apex pages so the conteroller can get it.
        ApexPages.currentPage().getParameters().put('id',cse[0].Id);
        
        //Initialising class. 
        CheckCaseFieldPopulatedToCreateCRClass controller = new CheckCaseFieldPopulatedToCreateCRClass();
        
        //Calling method if the Field of CR is not blank 
        String url = controller.redirect();
        
        controller.goBack();  
        
        //Assert to check url contains Change_Request_Title__c field
        System.assertEquals(true, url.contains('Change the Field'));
        
        //Setting the parameters on the apex pages so the conteroller can get it.
        ApexPages.currentPage().getParameters().put('id',cse[1].Id);
        
        //Calling method if the Field of CR is blank 
        try
        {
            controller.redirect();
        }
        catch(Exception e)
        {
            //Assert to check error message 
            System.assertEquals('The fields Change Request Level, Change Request Title, and Summary must be populated on the Case before creating a new Change Request.',e.getMessage());
        }    
    }
}