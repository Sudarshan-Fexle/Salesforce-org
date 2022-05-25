@isTest
public class Test_Batch_UpdateLastExeAndIntDate {
    static testMethod void myUnitTest() {

        //Bypass Dupeblocker
        Util.IsTest(true);

        Util.IsTesting = true;
        Util.BypassAllTriggers = true;

        Account acc = new Account(Name = 'testacc', Account_Formal_Name__c = 'testacc');
        insert acc;

        Program__c prog = new Program__c(Name = 'testprog', Program_Acronym__c = 'TEST', Status__c = 'Active', Create_Memberships__c = 'Yes');
        insert prog;

        //Create membership data
        Membership__c mem = new Membership__c(Account_Name__c = acc.id, Program__c = prog.id);
        insert mem;

        
        //Member Success Record Type Id 
        Id memberSuccessRTId = Util.RecordTypeId('Event', 'Member Success');
        
        //Member Success Record Type Id 
        Id techRTId = Util.RecordTypeId('Project__c', 'Tech');
        
        //Create a Project record
        //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
        Project__c project1 = new Project__c(Name = 'Test', Institution__c = acc.Id, Primary_Paid_Membership__c = mem.Id,RecordTypeId = techRTId,
                                             Project_Phase__c = '1 - Test'/*, Implementation_Business_Analyst__c = UserInfo.getUserId()*/);
        insert project1;
        
        //Create a Project record
        Project__c project2 = new Project__c(Name = 'Test', Institution__c = acc.Id, Primary_Paid_Membership__c = mem.Id, CreatedDate = date.newinstance(2019, 09, 01),
                                             RecordTypeId = techRTId, Project_Phase__c = '1 - Test'/*, Implementation_Business_Analyst__c = UserInfo.getUserId()*/);
        insert project2;
        System.assert(project2!= null);
        
        //Create a Project record
        Project__c project3 = new Project__c(Name = 'Test', Institution__c = acc.Id, Primary_Paid_Membership__c = mem.Id,
                                             RecordTypeId = techRTId, Project_Phase__c = '1 - Test'/*, Implementation_Business_Analyst__c = UserInfo.getUserId()*/);
        
        insert project3;
        List<Event> evntList = new List<Event>();
        
    
        for(integer i=1; i<=5; i++)
        {
            DateTime DTStart1 = System.Now().addDays(-i);
            Date DStart1 = Date.newInstance(DTStart1.year(), DTStart1.month(), DTStart1.day());
            
            Event tsk1 = new Event(
                whatId = project1.Id,
                Subject = 'Executive Update',
                RecordTypeId = memberSuccessRTId,
                StartDateTime = DTStart1,
                ActivityDateTime = DTStart1,
                ActivityDate = DStart1,
                EndDateTime = DTStart1.addDays(1),
                Event_Type__c = 'Internal Event',
                Event_Purpose__c = 'Internal Discussion');
            
            evntList.add(tsk1);
        }
        for(integer i=1; i<=5; i++)
        {
            DateTime DTStart2 = System.Now().addDays(-i);
            Date DStart2 = Date.newInstance(DTStart2.year(), DTStart2.month(), DTStart2.day());
            
            Event tsk2 = new Event(
                Subject = 'Executive Update',
                whatId = project2.Id,
                RecordTypeId = memberSuccessRTId,
                StartDateTime = DTStart2,
                ActivityDateTime = DTStart2,
                ActivityDate = DStart2,
                EndDateTime = DTStart2.addDays(1),
                Event_Type__c = 'In Person Visit',
                Event_Purpose__c = 'Check In'	,
                Visit_Location__c = 'Campus' );
            
            evntList.add(tsk2);
        }
        
        for(integer i=1; i<=5; i++)
        {
            DateTime DTStart3 = System.Now().addDays(-i);
            Date DStart3 = Date.newInstance(DTStart3.year(), DTStart3.month(), DTStart3.day());
            
            Event tsk2 = new Event(
                Subject = 'Executive Update',
                whatId = project3.Id,
                RecordTypeId = memberSuccessRTId,
                StartDateTime = DTStart3,
                ActivityDateTime = DTStart3,
                ActivityDate = DStart3,
                EndDateTime = DTStart3.addDays(1),
                Event_Type__c = 'In Person Visit',
                Event_Purpose__c = 'Check In'	,
                Visit_Location__c = 'Campus' );
            
            evntList.add(tsk2);
        }
        Util.BypassAllTriggers = true;
        insert evntList;
        
        //Start testing here
        Test.startTest();
        
            //Executing Batch 
            Database.executeBatch(new Batch_UpdateLastExecutiveAndInternalDate());
            
        //Stop test here
        Test.stopTest();
        
        DateTime DTStart2 = System.Now().addDays(-1);
        Date DStart2 = Date.newInstance(DTStart2.year(), DTStart2.month(), DTStart2.day());
        
        Project__c pro1 = [Select Id,Last_Executive_Update__c,Last_Internal_Check_In__c from Project__c WHERE Id =: project1.Id LIMIT 1];
        System.assertEquals(DStart2, pro1.Last_Internal_Check_In__c);

        Project__c pro2 = [Select Id,Last_Executive_Update__c,Last_Internal_Check_In__c from Project__c WHERE Id =: project2.Id LIMIT 1];
        System.assertEquals(DStart2, pro2.Last_Executive_Update__c);
        
        Project__c pro3 = [Select Id,Last_Executive_Update__c,Last_Internal_Check_In__c from Project__c WHERE Id =: project3.Id LIMIT 1];
        System.assertEquals(DStart2, pro3.Last_Executive_Update__c);
    }
}