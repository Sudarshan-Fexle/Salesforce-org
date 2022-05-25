@isTest(seeAllData=false)
private class Test_ReviewCallTriggerHelper {

    //Added by Abhinav Sharma - 08/13/2020 - This method is used to test the Functional test  
    @istest static void test_CreateActionPlan(){
        
        Test.startTest();
        
        //Bypassing Triggers so then test data can be made easily
        Util.byPassAllTriggers = true;
        
        //Create test data
        Account acc = TestUtilities.CreateNewAccount(true);
        
        //Program
        Program__c program = TestUtilities.CreateNewProgram(true);
        
        //Opportunity
        Opportunity opportunity = TestUtilities.CreateNewOpportunity(acc.Id, true);
        
        //Contract
        Contract__c contract = new Contract__c(Name='Test1', Payer_Account__c = acc.Id, Program__c = program.Id, Start__c = System.Today().addDays(-10), 
                                                    End__c = System.Today().addDays(355), Contract_Renewal_Opportunity__c = opportunity.Id);
        insert contract;
        
        //Membership
        Membership__c member = new Membership__c(Name = 'Test Membership', Account_Name__c = acc.Id, Program__c = program.Id, Active_Contract_Idenfied__c = contract.Id);
        
        //Update Membership
        insert member;
        
        //List to hold the case records
        List<Review_call__c> reviewCallList = new List<Review_call__c>();
        
        //Create a sample review call record to insert and test review call trigger
        Review_call__c reviewCall = new Review_call__c( Name = 'Testing Record', Type__c = 'Annual Review', 
                                                       Review_Call_Due_Date__c = system.today(),Renewal_Issue_Identified__c = true, 
                                                       Renewal_Issue_Reason__c = 'testing',Renewal_Issue_Description__c = 'testing',
                                                       Membership__c = member.Id);
       
        reviewCallList.add(reviewCall);
        insert reviewCallList;
        
        List<task> task  = [SELECT Id FROM Task WHERE RecordTypeId =: constants.RECORD_TYPE_ID_ACTION_PLANS];
        system.assertEquals(1,task.size());
        
        Test.stopTest();   
    }
    
}