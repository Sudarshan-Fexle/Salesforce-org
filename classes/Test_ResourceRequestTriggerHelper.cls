/**
    * Purpose      :   Test class for ResourceRequestTriggerHelper
    * 
    * CreatedDate      :   21/19/2021
    * 
    * RevisionLog      :   V_1.0 - Created - CR-20211103-15563 - Neha Sharma -
    *					   Code Coverage    :   100%
    * */
@IsTest
private class Test_ResourceRequestTriggerHelper
{
    
    @IsTest static void testJobTicketTriggerHelper()
    {
        util.bypassAllTriggers = true;
        
        Profile SysAdmin = [SELECT Id from Profile WHERE Name = 'System Administrator' LIMIT 1];
        UserRole TestRole = [SELECT Id from UserRole WHERE Name = 'Executive' LIMIT 1];
        
        //Create Test User
        User user = new User(FirstName = 'The', LastName = 'Great Ohioan', Alias = 'TGO', EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US', 
                             LocaleSidKey='en_US', Email = 'test@abc.com', ProfileId = SysAdmin.Id, UserRole = TestRole, department = 'STP',
                             TimeZoneSidKey = 'America/Los_Angeles', Username = 'thegreatohioan@test.com');
        insert user;
        
         pse__Region__c region = new pse__Region__c(Name = 'Test Region');
        insert region;
        
        Opportunity opp = TestUtilities.CreateNewOpportunity(true);
       
        
        //Create Test Practice
        pse__Practice__c practice = new pse__Practice__c (Name = 'Test Practice');
        insert practice;
        
        //Create Test Contact
        Contact contact = new Contact(LastName = 'TestCon', Employee_ID__c = 'abc', 
                                      pse__Is_Resource__c = True, pse__Is_Resource_Active__c = True, Employee_User_Record__c = user.Id,
                                      Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855'
                                      
                                     );
        insert contact;
        
        //Create Test Group
            pse__Grp__c ProjGroup = new pse__Grp__c (name = 'Test Group');
            insert ProjGroup;
        
         //Create Permission Control Record
        pse__Permission_Control__c PermControl1 = new pse__Permission_Control__c (pse__User__c = user.id, pse__Region__c = Region.Id, 
                                                                                  pse__Cascading_Permission__c = True, pse__Resource_Request_Entry__c = True,
                                                                                  pse__Billing__c = True, pse__Timecard_Entry__c = True, pse__Expense_Entry__c = True,
                                                                                  pse__Invoicing__c = True, pse__Staffing__c = True);
        insert PermControl1;
        
         
        System.runAs(user){
        
        pse__resource_request__c res = new pse__resource_request__c();
        res.pse__End_Date__c = system.today().addDays(1);
        res.pse__SOW_Hours__c = 2.34;
        res.pse__Start_Date__c = system.today();
        res.pse__Region__c = region.Id;
        res.pse__Opportunity__c = opp.id;
        res.pse__Resource_Role__c = 'Accounting';
        res.pse__Practice__c = practice.Id;
        insert res;
        
        util.bypassAllTriggers = false;
        
        try{
        delete res;
        }
        catch(Exception e){
            system.assertEquals(System.Label.Error_Msg_For_Resource_Request_Deletion, e.getMessage());
        }

    }
        
    }
    
}