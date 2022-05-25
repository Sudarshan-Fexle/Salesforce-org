/*
Purpose			:   Test class for Sched_UpdateContactFieldProtocoled 

Create By		:   Mahendra Swarnkar

Created Date	        :   5/7/2020

Current Version		:   V1.1

Revision Log		:   V1.0 - Created  
                        :   V1.1 - Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
Coverage		:   V1.0 - Sched_UpdateContactFieldProtocoled - 100%

*/
@isTest(SeeAllData = false)
private class Test_Sched_UpdateContactFieldProtocoled {
    
   static testMethod void TestBatchUpdateContactFieldProtocoled(){
       
       //Bypassing all triggers
        Util.byPassAllTriggers = true;
        Util.IsTest(true);
        
        //Query through Opportunity RecordTypes
        List<RecordType> oppRecord = [SELECT Id , DeveloperName FROM RecordType 
                                        WHERE DeveloperName = 'BI_Contract_Maintenance' 
                                        AND SObjectType = 'Opportunity'
                                        AND IsActive = true];

        //Query through event RecordTypes
        List<RecordType> eventRecordType = [SELECT Id , DeveloperName FROM RecordType 
                                                WHERE (Name = 'Sales') 
                                                AND SObjectType = 'Event' AND IsActive = true];
       
        //Query through task RecordTypes
        List<RecordType> taskRecordType = [SELECT Id , DeveloperName FROM RecordType 
                                                WHERE (DeveloperName = 'Task_BI_Marketing') 
                                                AND SObjectType = 'Task' AND IsActive = true];
        //Profile    
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
      
        //User
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = p.Id, department = 'STP',
                            TimeZoneSidKey='GMT', UserName=Math.random() + '@test.com');

        System.runAs(u) {
        
            //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
            //Insert Opportunity Records
            List<Opportunity> oppList = new List<Opportunity>();
            oppList.add(new Opportunity(Sales_Pursuit_Products__c = 'APS',RecordTypeId = oppRecord[0].Id , Name = 'Test Opportunity0' , StageName = 'Proposal In Progress' , Amount = 1234 , CloseDate=system.today().addDays(3) ));
            oppList.add(new Opportunity(Sales_Pursuit_Products__c = 'APS',RecordTypeId = oppRecord[0].Id , Name = 'Test Opportunity1' , StageName = 'Proposal In Progress' , Amount = 1234 , CloseDate=system.today().addDays(4) ));
            Insert oppList;
            
            List<Contact> conList = new List<Contact>();
            conList.add(new Contact(LastName = 'Test1',Protocoled_Sales__c = false, Email = 'test@gmail.com',Phone='3456765458',Title='Director'));
            conList.add(new Contact(LastName = 'Test2',Protocoled_Sales__c = false, Email = 'preeti4@gmail.com',Phone='3456765458',Title='Director'));
            conList.add(new Contact(LastName = 'Test3',Protocoled_Sales__c = true, Email = 'aman1@gmail.com',Phone='3456765458',Title='Director'));
            conList.add(new Contact(LastName = 'Test4',Protocoled_Sales__c = true, Email = 'david4@gmail.com',Phone='3456765458',Title='Director'));
            conList.add(new Contact(LastName = 'Test5',Protocoled_Sales__c = true, Email = 'nan3@gmail.com',Phone='3456765458',Title='Director'));
            insert conList;
            
            //List to hold Events
            List<Event> events = new List<Event>();
            
            //Populate List
            events.add(new Event(RecordTypeId = eventRecordType[0].Id ,StartDateTime = system.today().addDays(4), 
                                 EndDateTime = system.today().addDays(7) , OwnerId = Userinfo.getUserId(), whoId = conList[0].Id,
                                 Subject = 'Will Auto-Populate',   WhatId = oppList[0].Id , Cancelled_Did_Not_Occur__c = false ,  
                                 Event_Type__c = 'Web Visit', Event_Purpose__c = 'Initial'));
            events.add(new Event(RecordTypeId = eventRecordType[0].Id ,StartDateTime = system.today().addDays(3), 
                                 EndDateTime = system.today().addDays(7) , OwnerId = Userinfo.getUserId(),whoId = conList[2].Id,
                                 Subject = 'Will Auto-Populate',   WhatId = oppList[0].Id , Cancelled_Did_Not_Occur__c = false ,  
                                 Event_Type__c = 'Web Visit', Event_Purpose__c = 'Initial'));
            events.add(new Event(RecordTypeId = eventRecordType[0].Id ,StartDateTime = system.today().addDays(-10), 
                                 EndDateTime = system.today() , OwnerId = Userinfo.getUserId(),whoId = conList[1].Id,
                                 Subject = 'Will Auto-Populate',   WhatId = oppList[0].Id , Cancelled_Did_Not_Occur__c = false ,  
                                 Event_Type__c = 'Web Visit', Event_Purpose__c = 'Initial' ));
            events.add(new Event(RecordTypeId = eventRecordType[0].Id ,StartDateTime = system.today().addDays(2), 
                                 EndDateTime = system.today().addDays(7) , OwnerId = Userinfo.getUserId(),whoId = conList[2].Id,
                                 Subject = 'Will Auto-Populate',   WhatId = oppList[0].Id , Cancelled_Did_Not_Occur__c = false ,  
                                 Event_Type__c = 'Web Visit', Event_Purpose__c = 'Prewire' ));
             events.add(new Event(Credit__c = 9 ,StartDateTime = system.today().addDays(2), whoId = conList[3].Id,
                                 EndDateTime = system.today().addDays(7) , OwnerId = Userinfo.getUserId(),
                                 Subject = 'Will Auto-Populate',   WhatId = oppList[0].Id , Cancelled_Did_Not_Occur__c = false ,  
                                 Event_Type__c = 'Web Visit', Event_Purpose__c= 'Initial' ));
            events.add(new Event(RecordTypeId = eventRecordType[0].Id,Credit__c = 9 ,StartDateTime = system.today().addDays(2), whoId = conList[4].Id,
                                 EndDateTime = system.today().addDays(+12) , OwnerId = Userinfo.getUserId(),
                                 Subject = 'Will Auto-Populate',   WhatId = oppList[0].Id , Cancelled_Did_Not_Occur__c = false ,  
                                 Event_Type__c = 'Web Visit', Event_Purpose__c= 'Initial' ));
            
            //Test Start from here
            Test.startTest();
            
            //Enables all the triggers
            Util.BypassAllTriggers = true;
            
            //Insert Events
            insert events;
            
            Task tsk = new Task();
            tsk.RecordTypeId = taskRecordType[0].Id;
            tsk.subject = 'call';
            tsk.whatId = oppList[0].Id ;
            tsk.whoId = conList[1].Id;
            tsk.Event_Type__c = 'In Person';
            tsk.Event_Purpose__c = 'Initial';
            tsk.Status = 'Not Started';
            tsk.ActivityDate = System.today().addDays(2);
            insert tsk;
            
            
            Sched_UpdateContactFieldProtocoled  sch = new Sched_UpdateContactFieldProtocoled();
            String schcron = '20 30 8 10 2 ?';
            String jobID = system.schedule('BatchUpdateContactFieldProtocoled', schcron, sch);
           
            
            Test.stopTest();
            
    }
   }

}