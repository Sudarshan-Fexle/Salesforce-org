/**
* Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
**/
@IsTest
private class dlrs_pse_Timecard_HeaderTest
{
    private static testmethod void testTrigger()
    {
        Profile SysAdmin = [SELECT Id from Profile WHERE Name = 'System Administrator' LIMIT 1];
        UserRole TestRole = [SELECT Id from UserRole WHERE Name = 'Executive' LIMIT 1];
        
        //Create Test User
        User user = new User(FirstName = 'The', LastName = 'Great Ohioan', Alias = 'TGO', EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US', 
                             LocaleSidKey='en_US', Email = 'test@abc.com', ProfileId = SysAdmin.Id, UserRole = TestRole, department = 'STP',
                             TimeZoneSidKey = 'America/Los_Angeles', Username = 'thegreatohioan@test.com');
        insert user;
        
        System.runAs(user){
            
            //Need to Create a Institution record first
            Account acc = new Account(Name = 'TestAcc', Account_Formal_Name__c = 'TestAcc');
            insert acc;
            
            //Create Test Contact
            Contact contact = new Contact(LastName = 'TestCon', AccountId = acc.Id, Employee_ID__c = 'abc', 
			pse__Is_Resource__c = True, pse__Is_Resource_Active__c = True, Employee_User_Record__c = user.Id,
			Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855'
			
			);
            insert contact;
            
            //Create Test Region
            pse__Region__c Region = new pse__Region__c(Name = 'Test Region');
            insert Region;
            
            //Create Test Practice
            pse__Practice__c Practice = new pse__Practice__c (Name = 'Test Practice');
            insert Practice;
            
            //Create Test Group
            pse__Grp__c ProjGroup = new pse__Grp__c (name = 'Test Group');
            insert ProjGroup;
            
            date todayDate = Date.today();
            date startofMonth = todayDate.toStartOfMonth();
            
            //Create a Project record first
            pse__Proj__c Proj = new pse__Proj__c(Name = 'Test Project', Project_Nickname__c = 'ProjNN', pse__Account__c = acc.id, pse__Project_Manager__c = contact.id, Group_Manager__c = user.id, pse__Billing_Type__c = 'Fixed Price', pse__Practice__c = Practice.Id, pse__Region__c = Region.Id, pse__Group__c = ProjGroup.Id, pse__End_Date__c = todayDate, pse__Start_Date__c = startofMonth, pse__Is_Active__c = True);
            insert Proj;
            
            //Create Schedule record
            pse__Schedule__c Sched = new pse__Schedule__c (pse__Start_Date__c = System.today(), pse__End_Date__c = System.today() + 7, pse__Monday_Hours__c = 1.0, pse__Tuesday_Hours__c = 1.0);
            insert Sched;
            
            //Create Permission Control Record
            pse__Permission_Control__c PermControl1 = new pse__Permission_Control__c (pse__User__c = user.id, pse__Resource__c = contact.id, pse__Cascading_Permission__c = True, pse__Resource_Request_Entry__c = True, pse__Billing__c = True, pse__Timecard_Entry__c = True, pse__Expense_Entry__c = True, pse__Invoicing__c = True, pse__Staffing__c = True);
            insert PermControl1;
            
            pse__Permission_Control__c PermControl2 = new pse__Permission_Control__c (pse__User__c = user.id, pse__Region__c = Region.id, pse__Cascading_Permission__c = True, pse__Resource_Request_Entry__c = True, pse__Billing__c = True, pse__Timecard_Entry__c = True, pse__Expense_Entry__c = True, pse__Invoicing__c = True, pse__Staffing__c = True);
            insert PermControl2;
            
            pse__Permission_Control__c PermControl3 = new pse__Permission_Control__c (pse__User__c = user.id, pse__Project__c = Proj.id, pse__Cascading_Permission__c = True, pse__Resource_Request_Entry__c = True, pse__Billing__c = True, pse__Timecard_Entry__c = True, pse__Expense_Entry__c = True, pse__Invoicing__c = True, pse__Staffing__c = True);
            insert PermControl3;
            
            //Create Assignment Record
            pse__Assignment__c Assignment = new pse__Assignment__c (Name = 'Test Assignment 111', pse__Resource__c = contact.id, pse__Project__c = Proj.Id, pse__Schedule__c = sched.Id, pse__Bill_Rate__c = 0.0, pse__Planned_Bill_Rate__c = 0.5, Budgeted_Hours_Assignment__c = 6.0);
            insert Assignment;
            
            // Force the dlrs_pse_Timecard_HeaderTrigger to be invoked, fails the test if org config or other Apex code prevents this.
            dlrs.RollupService.testHandler(new pse__Timecard_Header__c(pse__Project__c = Proj.Id, pse__Resource__c = contact.id, pse__Start_Date__c = System.Today(), pse__End_Date__c = System.Today() + 7));
        }
    }
}