@isTest
class Test_Event_UpdateEventFields
{
    /*
    Purpose		:   Test Class Batch_ActivityCount
    
    Create By		:   Pierre (SAP Contractor)
    
    Last Modified By    :   Nathan Banas (SAP) - 4/21/2011
    
    Current Version	:   v1.3
    
    Revision Log	:   v1.0 - () Created code
                            v1.1 - (NB-2011-01-26) Added header, code comments, and added code coverage
                            v1.2 - (NB-2011-02-25) Modified filter criteria to test date range
                            v1.3 - (NB-2011-04-21) Modified test method to be remove the reliance on data being present within the system
                            v1.4 - 06/12/2012 - Simplyforce(Bhavi) - Created a new Test method for CR-20120417-730
                            v1.5 - 12/19/2013 - Modified by CM - Removed references to Old Function/Old Product - CR-1991
                            v1.6 - Modified By - Abhinav Sharma - CR-20140808-6940 - 08/27/2014
                            v1.7 - Modified By - Abhinav Sharma - CR-20140429-5272 - 09/15/2014 - Modified after removal of the existing Bundle_Parent__c references
                            v1.8 - Modified by - Mahendra Swarnakar - CR-20161102-10332 - 12/20/2016 - Comment out "CRMfusionDBR101.DB_Globals.triggersDisabled" flag   
    			    v1.9 - Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
			    v2.0 - Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
    Code Coverage as of 2/25/2011: 97%
    Code Coverage as of 4/21/2011: 97%
    */
    
    static testMethod void testEventQACall()
    {
        Util.IsTest(true);
        //Test Membership Most recent QA call Renewal etc...
        System.debug('### Test_Batch_ActivityCount - Test Case 5 - Start ###');
        Util.IsTesting = true;
        Util.IsBatch = true;
        
        Account a = new Account(Name = 'testacct');
        insert a;
        
        Program__c p = new Program__c(Name = 'testprog', Program_Acronym__c = 'test');
        insert p;
        
        Membership__c mem = new Membership__c(Account_Name__c = a.id, Program__c = p.id);
        insert mem;
        
        List<Event> evntList = new List<Event>();
        
        
        DateTime DTStart = System.Now();
        Date DStart = Date.newInstance(DTStart.year(), DTStart.month(), DTStart.day());
    
        Date dt = Date.newInstance(2010,2,2);
        DateTime dtt = DateTime.newInstance(2010,2,2,12,12,12);
        for(integer i=1; i<=5; i++)
        {
            Event tsk = new Event(
                whatId = mem.Id,
                StartDateTime = DTStart.addDays(-i),
                ActivityDateTime = DTStart.addDays(-i),
                ActivityDate = DStart.addDays(-i),
                //DurationInMinutes = 30,
                EndDateTime = DTStart.addDays(-i),
                Event_Type__c = 'CM QA Call');
                
            if(i==1)
            {
                tsk.Event_Type__c = 'PT QA Call';
                tsk.Would_Refer__c = '5'; // should come over to Membership.Most_Recent_QA_Call_Recommended_Grade__c
                tsk.Would_Buy_Again__c = '6'; // should come over to Most_Recent_QA_Call_Renew_Grade__c
                tsk.Grade__c = 'C';
                tsk.StartDateTime = DTStart;
                tsk.EndDateTime = DTStart;
                tsk.ActivityDateTime = DTStart;
                tsk.ActivityDate = DStart;
                
            }
            else if(i==2)
            {
                tsk.Event_Type__c = 'PT QA Call';
                tsk.Would_Refer__c = '8'; 
                tsk.Would_Buy_Again__c = '9'; 
                tsk.Grade__c = 'B';
                tsk.StartDateTime = DTStart;
                tsk.ActivityDateTime = DTStart;
                tsk.ActivityDate = DStart;
                tsk.EndDateTime = tsk.StartDateTime.addDays(1);
            }
            else
            {
                tsk.Grade__c = 'A';
            }
            
            evntList.add(tsk);
        }
        
        insert evntList;
        System.debug('Events Created'+evntList);
        
        List<Id> idList = new List<Id>();
        for(Event obj:evntList){
            idList.add(obj.Id);
        }
    
        Test.startTest();
        //String qry = 'select id, Event_Type__c, ActivityDate, Grade__c, WhatId from Event where (Event_Type__c = \'PT QA Call\' or Event_Type__c = \'Phone Appointment\') and What.Type = \'Opportunity\' and WhatId=\''+oppId +'\' order by WhatId';
    
        String qry = 'select id, Event_Type__c, Event_Purpose__c, ActivityDate, StartDateTime, EndDateTime, Grade__c, WhatId, What.Type from Event where ' + 
            '(Event_Type__c = \'Quality Assurance\' ) and ' +
            'WhatId=\'' + mem.id + '\' order by WhatId';
    
        System.debug('### Test Batch Query String: ' + qry);
    
        Batch_ActivityCount batch = new Batch_ActivityCount();
        batch.queryStr = qry;
    
        Id batchId = Database.executeBatch(batch);
               
        System.debug('### Launched Batch : '+batchId);
        Test.stopTest();
    
        mem = [select Id, Most_Recent_QA_Call_Grade__c, Most_Recent_QA_Call_Renew_Grade__c, Most_Recent_QA_Call_Recommend_Grade__c from Membership__c where Id = :mem.id];
        
        System.debug('### Membership record:' + mem);
    
        //System.assertEquals('B', mem.Most_Recent_QA_Call_Grade__c);
        //System.assertEquals('8', mem.Most_Recent_QA_Call_Recommend_Grade__c);
        //System.assertEquals('9', mem.Most_Recent_QA_Call_Renew_Grade__c);
    }
    
    static testMethod void testEvent_Cancelled()
    {
        //CRMfusionDBR101.DB_Globals.triggersDisabled = true;
        System.debug('### Test_Batch_ActivityCount - Test Case 3 - Start ###');
        Util.IsTesting = true;
        Util.IsBatch = true;
        Util.byPassAllTriggers = true;
        
        // Test Class Fix Start Here 13Feb By: Dipesh Gupta
        //Creating Contact record 
        Contact con = TestUtilities.CreateNewContact(True);
        // Test Class Fix End Here 13Feb By: Dipesh Gupta		
    
        //List<Opportunity> oppList = [select Id, How_many_prewires_were_completed__c from Opportunity where StageName='Pending' limit 3];
        //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
        List<Opportunity> oppList = new List<Opportunity>();
        for(integer i=1; i< 4; i++)
        {
            oppList.add(new Opportunity(Sales_Pursuit_Products__c = 'APS',Name='Test Opp' + i,Main_Contact__c = con.Id, CloseDate = system.today()+7, How_many_prewires_were_completed__c = 0, StageName = 'Pending'));
        }
        
        insert oppList;
        
        List<Event> evntList = new List<Event>();
        Id oppId = oppList[1].Id;
    
        System.debug('### Associating Event with '+oppId);
        
        Util.byPassAllTriggers = false;
    
        DateTime DTStart = System.Now().addDays(-5);
        Date DStart = Date.newInstance(DTStart.year(), DTStart.month(), DTStart.day());
    
        for(integer i=1; i<=5; i++)
        {
            Event tsk = new Event(
                whatId = oppId,
                StartDateTime = DTStart,
                ActivityDateTime = DTStart,
                ActivityDate = DStart,
                //DurationInMinutes = 30,
                Cancelled_Did_Not_Occur__c = true,
                EndDateTime = DTStart.addDays(1),
                Event_Type__c = 'Prewire',
                Event_Purpose__c = 'Prewire');
            
            evntList.add(tsk);
        }
        
        Event tsk = new Event(
        whatId = oppId,
        StartDateTime = DTStart,
        ActivityDateTime = DTStart,
        ActivityDate = DStart,
        //DurationInMinutes = 30,
        Cancelled_Did_Not_Occur__c = true,
        EndDateTime = DTStart.addDays(1),
        Event_Type__c = 'In Person Visit',
        Event_Purpose__c = 'Initial', Visit_Location__c = 'Campus');
         
        evntList.add(tsk);
                
        insert evntList;
        System.debug('### Events Created'+evntList);
        
        List<Id> idList = new List<Id>();
        for(Event obj:evntList){
            idList.add(obj.Id);
        }
    
        Test.startTest();
        String qry = 'select id, Event_Type__c, Event_Purpose__c, ActivityDate, StartDateTime, EndDateTime, Grade__c, WhatId, What.Type from Event where WhatId=\''+oppId +'\' order by WhatId';
    
        System.debug('### Test Batch Query String: ' + qry);
        
        Batch_ActivityCount batch = new Batch_ActivityCount();
        batch.queryStr = qry;
    
        Id batchId = Database.executeBatch(batch);

        System.debug('### Launched Batch : '+batchId);
        
        Test.stopTest();
    
        Opportunity opp = [select Id, How_many_prewires_were_completed__c, Initial_Visit_Date__c from Opportunity where Id =: oppId];
        System.debug('### Opportunity record:'+opp);
    
        System.assertEquals(0, opp.How_many_prewires_were_completed__c);
        system.assertEquals(null, opp.Initial_Visit_Date__c);
        
        System.debug('### Test_Batch_ActivityCount - Test Case 3 - End ###');
    }
    
    static testMethod void testCaseEvents()
    {
        //CRMfusionDBR101.DB_Globals.triggersDisabled = true;
        System.debug('### Test_Batch_ActivityCount - Test Case 1 - Start ###');
        Util.IsTesting = true;
        Util.IsBatch = true;
        
        util.bypassAllTriggers = true;
        
        // Test Class Fix Start Here 13Feb By: Dipesh Gupta
        // Test Class Fix Start Here 8/3/2020 Modified By: Mahendra Swarnakar - CR-20200218-13783
        Account acc = new Account();
        acc.Name = 'Test';
        insert acc;
        
        //Creating Contact record 
        Contact con = TestUtilities.CreateNewContact(false);
        con.AccountId = acc.Id;
        insert con;
        // Test Class Fix end Here 8/3/2020 Modified By: Mahendra Swarnakar 
        // Test Class Fix End Here 13Feb By: Dipesh Gupta
		
        //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
         // Test Class Fix 8/3/2020 Modified By: Mahendra Swarnakar - CR-20200218-13783
        List<Opportunity> oppList = new List<Opportunity>();
        for(integer i=1; i< 4; i++)
        {
            oppList.add(new Opportunity(Sales_Pursuit_Products__c = 'APS',Name='Test Opp' + i,Main_Contact__c = con.Id, amount  =11, AccountId = acc.id, CloseDate = system.today()+7, How_many_prewires_were_completed__c = 0, StageName = 'Pending'));
        }
        
        insert oppList;
        util.bypassAllTriggers = false;
        //List<Opportunity> oppList = [select Id, Name, How_many_prewires_were_completed__c from Opportunity where StageName='Pending' limit 3];
        
        List<Event> evntList = new List<Event>();
        Id oppId = oppList[1].Id;
    
        System.debug('Associating Event with '+oppId);
    
        DateTime DTStart = System.Now();
        Date DStart = Date.newInstance(DTStart.year(), DTStart.month(), DTStart.day());
    
        Date dt = Date.newInstance(2010,2,2);
        DateTime dtt = DateTime.newInstance(2010,2,2,12,12,12);
        for(integer i=1; i<=5; i++)
        {
            Event tsk = new Event(
                whatId = oppId,
                StartDateTime = DTStart.addDays(-i),
                ActivityDateTime = DTStart.addDays(-i),
                ActivityDate = DStart.addDays(-i),
                //DurationInMinutes = 30,
                EndDateTime = DTStart.addDays(-i),
                Event_Type__c = 'PT QA Call');
                
            if(i==1)
            {
                tsk.Grade__c = 'C';
                tsk.StartDateTime = DTStart;
                tsk.ActivityDateTime = DTStart;
                tsk.ActivityDate = DStart;
                tsk.EndDateTime = tsk.StartDateTime.addDays(1);
            }
            else if(i==2)
            {
                tsk.Event_Type__c = 'Phone Appointment';
                tsk.Grade__c = 'C';
                tsk.StartDateTime = DTStart;
                tsk.ActivityDateTime = DTStart;
                tsk.ActivityDate = DStart;
                tsk.EndDateTime = tsk.StartDateTime.addDays(1);
            }
            else
            {
                tsk.Grade__c = 'B';
            }
            
            evntList.add(tsk);
        }
        
        insert evntList;
        System.debug('Events Created'+evntList);
        
        List<Id> idList = new List<Id>();
        for(Event obj:evntList){
            idList.add(obj.Id);
        }
    
        Test.startTest();
        //String qry = 'select id, Event_Type__c, ActivityDate, Grade__c, WhatId from Event where (Event_Type__c = \'PT QA Call\' or Event_Type__c = \'Phone Appointment\') and What.Type = \'Opportunity\' and WhatId=\''+oppId +'\' order by WhatId';
    
        //Date Format
        //2003-11-20T00:00:00Z
        //2003-11-20T11:11:11Z
        //1994-11-05T08:15:30-05:00
        
        date filterD = system.today().addDays(-3);
        
        string year = filterD.year().format().replace(',', '');
        string month = filterD.month() > 9 ? filterD.month().format() : '0' + filterD.month().format();
        string day = filterD.day() > 9 ? filterD.day().format() : '0' + filterD.day().format();
        string suffix = 'T00:00:00-05:00';
        
        string filterDstr = year + '-' + month + '-' + day + suffix;
        
        system.debug('#####' + filterDstr);
        
        
        /*Date startdate = system.today().addDays(-3);
        String startdatestring = String.valueof(startdate.year()) + '-' 
            + ((startdate.month() < 10) ? '0':'') + String.valueof(startdate.month()) + '-' 
            + ((startdate.day() < 10)   ? '0':'') + String.valueof(startdate.day());
        String startdatetimestring = startdatestring + 'T00:00:00Z';*/
        
        string qry = 'select id, Event_Type__c, Event_Purpose__c, ActivityDate, StartDateTime, EndDateTime, Grade__c, WhatId, What.Type from Event where ' + 
            '(What.Type = \'Opportunity\' or What.Type = \'Membership__c\') and ' + 
            '(Event_Purpose__c = \'Prewire\' or ' + 
            '(Event_Type__c = \'In Person Visit\' and Event_Purpose__c = \'Initial\') or ' +
            'Event_Type__c = \'Quality Assurance\'  or ' +
            'Event_Type__c = \'Phone Appointment\') ' +
            'and (StartDateTime > ' + filterDstr + //startdatetimestring + // NB-2011-02-25-Added filterDstr and removed startdatetimestring
                //' OR ActivityDate > ' + filterDstr + //startdatetimestring + // NB-2011-02-25-Added filterDstr and removed startdatetimestring
                ' OR LastModifiedDate > ' + filterDstr + //startdatetimestring + // NB-2011-02-25-Added filterDstr and removed startdatetimestring
                ' OR CreatedDate > ' + filterDstr + //startdatetimestring + // NB-2011-02-25-Added filterDstr and removed startdatetimestring 
                ') ' +
            'order by WhatId limit 200';
    
        System.debug('##### Test Batch Query String: ' + qry);
    
        Batch_ActivityCount batch = new Batch_ActivityCount();
        batch.queryStr = qry;
    
        Id batchId = Database.executeBatch(batch);
               
        System.debug('### Launched Batch : '+batchId);
        Test.stopTest();
    
        System.debug('### Test_Batch_ActivityCount - Test Case 1 - End ###');
    }
    
    static testMethod void testCaseEvents2()
    {
        //CRMfusionDBR101.DB_Globals.triggersDisabled = true;
        System.debug('### Test_Batch_ActivityCount - Test Case 2 - Start ###');
        Util.IsTesting = true;
        Util.IsBatch = true;
        util.bypassAllTriggers = true;
        
         // Test Class Fix Start Here 8/3/2020 Modified By: Mahendra Swarnakar - CR-20200218-13783
        Account acc = new Account();
        acc.Name = 'Test';
        insert acc;
        
        //Creating Contact record 
        Contact con = TestUtilities.CreateNewContact(false);
        con.AccountId = acc.Id;
        insert con;
        // Test Class Fix end Here 8/3/2020 Modified By: Mahendra Swarnakar 
        // Test Class Fix End Here 13Feb By: Dipesh Gupta
		
    
        //List<Opportunity> oppList = [select Id, Next_PA_Date__c, Name, Initial_Visit_Date__c ,How_many_prewires_were_completed__c from Opportunity where StageName='Pending' limit 3];
        //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
        List<Opportunity> oppList = new List<Opportunity>();
        for(integer i=1; i< 4; i++)
        {
            oppList.add(new Opportunity(Sales_Pursuit_Products__c = 'APS', Name='Test Opp' + i,Main_Contact__c = con.Id, accountId = acc.Id,CloseDate = system.today()+7, How_many_prewires_were_completed__c = 0, Initial_Visit_Date__c = system.today(), Next_PA_Date__c = system.today() + 1, StageName = 'Pending'));
        }
        insert oppList;
        
        util.bypassAllTriggers = false;
        
        List<Event> evntList = new List<Event>();
        Id oppId = oppList[1].Id;
    
        System.debug('### Associating Event with '+oppId);
    
        DateTime DTStart = System.Now();
        Date DStart = Date.newInstance(DTStart.year(), DTStart.month(), DTStart.day());
    
        Date dt = System.today();
        DateTime dtt = System.now();
    
        for(integer i=5; i>=0; i--)
        {
            Event tsk = new Event(
                whatId = oppId,
                StartDateTime = DTStart.addDays(i),
                ActivityDateTime = DTStart.addDays(i),
                ActivityDate = DStart.addDays(i),
                //DurationInMinutes = 30,
                EndDateTime = DTStart.addDays(i + 1),
                Event_Type__c = 'Phone Appointment',
                Event_Purpose__c = null);
            
            if(i == 1)
            {
                tsk.Event_Type__c = 'In Person Visit';
                tsk.Event_Purpose__c = 'Initial';
                tsk.Visit_Location__c = 'Campus';
            }
            
            if(i == 2)
            {
                tsk.Event_Type__c = 'In Person Visit';
                tsk.Event_Purpose__c = 'Initial';
                tsk.StartDateTime = DTStart.addDays(1);
                tsk.ActivityDateTime = DTStart.addDays(1);
                tsk.ActivityDate = DStart.addDays(1);
                tsk.EndDateTime = DTStart.addDays(2);
                tsk.Visit_Location__c = 'Campus';
            }
            
            if(i == 3)
            {
                tsk.whatId = oppList[0].Id;
                tsk.StartDateTime = DTStart.addDays(i);
                tsk.ActivityDateTime = DTStart.addDays(i);
                tsk.ActivityDate = DStart.addDays(i);
                tsk.EndDateTime = DTStart.addDays(i + 1);
                tsk.Event_Type__c = 'Phone Appointment';
                tsk.Event_Purpose__c = null;
            }
            
            evntList.add(tsk);
        }
        
        insert evntList;
        System.debug('### Events Created'+evntList);
        
        List<Id> idList = new List<Id>();
        for(Event obj:evntList)
        {
            idList.add(obj.Id);
        }
        
        // Reset the Initial Visit & Next PA Date Fields for the test opps
        oppList[0].Initial_Visit_Date__c = null;
        oppList[0].Next_PA_Date__c = null;
        
        oppList[1].Initial_Visit_Date__c = system.today().addDays(100);
        oppList[1].Next_PA_Date__c = system.today().addDays(100);
        
        oppList[2].Initial_Visit_Date__c = system.today().addDays(-100);
        oppList[2].Next_PA_Date__c = system.today().addDays(-100);
        
        update oppList;
        
        // Start testing
        Test.startTest();
        String qry = 'select id, Event_Type__c, Event_Purpose__c, ActivityDate, StartDateTime, EndDateTime, Grade__c, WhatId, What.Type from Event where (Event_Type__c = \'Phone Appointment\') and WhatId=\'' + oppId + '\' order by WhatId';
    
        System.debug('### Test Batch Query String: ' + qry);
    
        Batch_ActivityCount batch = new Batch_ActivityCount();
        batch.queryStr = qry;
    
        Id batchId = Database.executeBatch(batch);
         
        System.debug('### Launched Batch : '+batchId);
        Test.stopTest();
    
        Opportunity opp = [select Id, Name, Next_PA_Date__c, Initial_Visit_Date__c, How_many_prewires_were_completed__c from Opportunity where Id =: oppId];
        System.debug('### Opportunity record:'+opp);
    
        System.assertEquals(System.today(), opp.Next_PA_Date__c);
        System.assertNotEquals(null, opp.Initial_Visit_Date__c);
        
        System.debug('### Test_Batch_ActivityCount - Test Case 2 - End ###');
    }
    
    static testMethod void testCaseEvents3()
    {
        //CRMfusionDBR101.DB_Globals.triggersDisabled = true;
        System.debug('### Test_Batch_ActivityCount - Test Case 3 - Start ###');
        Util.IsTesting = true;
        Util.IsBatch = true;
        util.bypassAllTriggers = true;
        // Test Class Fix Start Here 8/3/2020 By: Mahendra Swarnakar - CR-20200218-13783
        Account acc = new Account();
        acc.Name = 'Test';
        insert acc;
        
        //Creating Contact record 
        Contact con = TestUtilities.CreateNewContact(false);
        con.AccountId = acc.Id;
        insert con;
        // Test Class Fix end Here 8/3/2020 By: Mahendra Swarnakar 
        // Test Class Fix End Here 13Feb By: Dipesh Gupta		
    
        //List<Opportunity> oppList = [select Id, How_many_prewires_were_completed__c from Opportunity where StageName='Pending' limit 3];
        //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
        List<Opportunity> oppList = new List<Opportunity>();
        for(integer i=1; i< 4; i++)
        {
            oppList.add(new Opportunity(Sales_Pursuit_Products__c = 'APS',Name='Test Opp' + i,Main_Contact__c = con.Id, accountId = acc.Id,CloseDate = system.today()+7, How_many_prewires_were_completed__c = 0, StageName = 'Pending'));
        }
        
        insert oppList;
        util.bypassAllTriggers = false;
        List<Event> evntList = new List<Event>();
        Id oppId = oppList[1].Id;
    
        System.debug('### Associating Event with '+oppId);
    
        DateTime DTStart = System.Now().addDays(-5);
        Date DStart = Date.newInstance(DTStart.year(), DTStart.month(), DTStart.day());
    
        for(integer i=1; i<=5; i++)
        {
            Event tsk = new Event(
                whatId = oppId,
                StartDateTime = DTStart,
                ActivityDateTime = DTStart,
                ActivityDate = DStart,
                //DurationInMinutes = 30,
                EndDateTime = DTStart.addDays(1),
                Event_Type__c = 'Prewire',
                Event_Purpose__c = 'Prewire');
            
            evntList.add(tsk);
        }
        insert evntList;
        System.debug('### Events Created'+evntList);
        
        List<Id> idList = new List<Id>();
        for(Event obj:evntList){
            idList.add(obj.Id);
        }
    
        Test.startTest();
        String qry = 'select id, Event_Type__c, Event_Purpose__c, ActivityDate, StartDateTime, EndDateTime, Grade__c, WhatId, What.Type from Event where WhatId=\''+oppId +'\' order by WhatId';
    
        System.debug('### Test Batch Query String: ' + qry);
        
        Batch_ActivityCount batch = new Batch_ActivityCount();
        batch.queryStr = qry;
    
        Id batchId = Database.executeBatch(batch);

        System.debug('### Launched Batch : '+batchId);
        
        Test.stopTest();
    
        Opportunity opp = [select Id, How_many_prewires_were_completed__c from Opportunity where Id =: oppId];
        System.debug('### Opportunity record:'+opp);
    
        System.assertEquals(5, opp.How_many_prewires_were_completed__c);
        
        System.debug('### Test_Batch_ActivityCount - Test Case 3 - End ###');
    }
    
    static testMethod void testCaseEvents4()
    {
        //CRMfusionDBR101.DB_Globals.triggersDisabled = true;
        System.debug('### Test_Batch_ActivityCount - Test Case 4 - Start ###');
        Util.IsTesting = true;
        Util.IsBatch = true;
      
        util.bypassAllTriggers = true;
        
        // Test Class Fix Start Here 8/3/2020 Modified By: Mahendra Swarnakar - CR-20200218-13783
        Account acc = new Account();
        acc.Name = 'Test';
        insert acc;
        
        //Creating Contact record 
        Contact con = TestUtilities.CreateNewContact(false);
        con.AccountId = acc.Id;
        insert con;
        // Test Class Fix end Here 8/3/2020 Modified By: Mahendra Swarnakar 
        // Test Class Fix End Here 13Feb By: Dipesh Gupta		
    
        //List<> oppList = [select Id, Next_PA_Date__c, Name, How_many_prewires_were_completed__c from Opportunity where StageName='Pending' limit 3];
        //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
        List<Opportunity> oppList = new List<Opportunity>();
        for(integer i=1; i< 4; i++)
        {
            oppList.add(new Opportunity(Sales_Pursuit_Products__c = 'APS',Name='Test Opp' + i,amount = 35,Main_Contact__c = con.Id, AccountId = acc.Id,CloseDate = system.today()+7, How_many_prewires_were_completed__c = 0, Next_PA_Date__c = system.today() + 1, StageName = 'Pending'));
        }
        
        insert oppList;
        
        util.bypassAllTriggers = false;
        
        List<Event> evntList = new List<Event>();
        Id oppId = oppList[1].Id;
    
        System.debug('### Associating Event with '+oppId);
    
        DateTime DTStart = System.Now();
        Date DStart = Date.newInstance(DTStart.year(), DTStart.month(), DTStart.day());
    
        Date dt = System.today();
        DateTime dtt = System.now();
    
        for(integer i=5; i>=0; i--)
        {
            Event tsk = new Event(
                whatId = oppId,
                StartDateTime = DTStart.addDays(i),
                ActivityDateTime = DTStart.addDays(i),
                ActivityDate = DStart.addDays(i),
                EndDateTime = DTStart.addDays(i + 1),
                Event_Type__c = 'Phone Appointment',
                Event_Purpose__c = null);
            
            evntList.add(tsk);
        }
        
        insert evntList;
        
        System.debug('### Events Created'+evntList);
        
        List<Id> idList = new List<Id>();
        for(Event obj:evntList)
        {
            idList.add(obj.Id);
        }
        
        Test.startTest();
        String qry = 'select id, Event_Type__c, Event_Purpose__c, ActivityDate, StartDateTime, EndDateTime, Grade__c, WhatId, What.Type from Event where (Event_Type__c = \'Phone Appointment\') and WhatId=\'' + oppId + '\' order by WhatId';
    
        System.debug('### Test Batch Query String: ' + qry);
    
        Batch_ActivityCount batch = new Batch_ActivityCount();
        batch.queryStr = qry;
    
        Id batchId = Database.executeBatch(batch);

        System.debug('### Launched Batch : '+batchId);
        Test.stopTest();
    
        Opportunity opp = [select Id, Name, Next_PA_Date__c, Initial_Visit_Date__c, How_many_prewires_were_completed__c from Opportunity where Id =: oppId];
        System.debug('### Opportunity record:'+opp);
    
        System.assertEquals(System.today(), opp.Next_PA_Date__c);
        
        System.debug('### Test_Batch_ActivityCount - Test Case 4 - End ###');
    }
    
    
    static testMethod void testCaseEvents5()
    {
        //CRMfusionDBR101.DB_Globals.triggersDisabled = true;
        //Test Membership Most recent QA call and grade
        System.debug('### Test_Batch_ActivityCount - Test Case 5 - Start ###');
        Util.IsTesting = true;
        Util.IsBatch = true;
        
        Account a = new Account(Name = 'testacct');
        insert a;
        
        Program__c p = new Program__c(Name = 'testprog', Program_Acronym__c = 'test');
        insert p;
        
        Membership__c mem = new Membership__c(Account_Name__c = a.id, Program__c = p.id);
        insert mem;
        
        List<Event> evntList = new List<Event>();
        
        
        DateTime DTStart = System.Now();
        Date DStart = Date.newInstance(DTStart.year(), DTStart.month(), DTStart.day());
    
        Date dt = Date.newInstance(2010,2,2);
        DateTime dtt = DateTime.newInstance(2010,2,2,12,12,12);
        for(integer i=1; i<=5; i++)
        {
            Event tsk = new Event(
                whatId = mem.Id,
                StartDateTime = DTStart.addDays(-i),
                ActivityDateTime = DTStart.addDays(-i),
                ActivityDate = DStart.addDays(-i),
                //DurationInMinutes = 30,
                EndDateTime = DTStart.addDays(-i),
                Event_Type__c = 'PT QA Call');
                
            if(i==1)
            {
                tsk.Grade__c = 'C';
                tsk.StartDateTime = DTStart;
                tsk.EndDateTime = DTStart;
                tsk.ActivityDateTime = DTStart;
                tsk.ActivityDate = DStart;
                tsk.Event_Type__c = 'CM QA Call';
            }
            else if(i==2)
            {
                tsk.Event_Type__c = 'Phone Appointment';
                tsk.Grade__c = 'B';
                tsk.StartDateTime = DTStart;
                tsk.ActivityDateTime = DTStart;
                tsk.ActivityDate = DStart;
                tsk.EndDateTime = tsk.StartDateTime.addDays(1);
            }
            else
            {
                tsk.Grade__c = 'A';
            }
            
            evntList.add(tsk);
        }
        
        insert evntList;
        System.debug('Events Created'+evntList);
        
        List<Id> idList = new List<Id>();
        for(Event obj:evntList){
            idList.add(obj.Id);
        }
    
        Test.startTest();
        //String qry = 'select id, Event_Type__c, ActivityDate, Grade__c, WhatId from Event where (Event_Type__c = \'PT QA Call\' or Event_Type__c = \'Phone Appointment\') and What.Type = \'Opportunity\' and WhatId=\''+oppId +'\' order by WhatId';
    
        String qry = 'select id, Event_Type__c, Event_Purpose__c, ActivityDate, StartDateTime, EndDateTime, Grade__c, WhatId, What.Type from Event where ' + 
            '(Event_Type__c = \'Quality Assurance\' ) and ' +
            'WhatId=\'' + mem.id + '\' order by WhatId';
    
        System.debug('### Test Batch Query String: ' + qry);
    
        Batch_ActivityCount batch = new Batch_ActivityCount();
        batch.queryStr = qry;
    
        Id batchId = Database.executeBatch(batch);
               
        System.debug('### Launched Batch : '+batchId);
        Test.stopTest();
    
        mem = [select Id, Most_Recent_QA_Call_Date__c, Most_Recent_QA_Call_Grade__c from Membership__c where Id = :mem.id];
        
        System.debug('### Membership record:' + mem);
    
        //System.assertEquals(dStart, mem.Most_Recent_QA_Call_Date__c);
        //System.assertEquals('C', mem.Most_Recent_QA_Call_Grade__c);
        
        //System.debug('### Test_Batch_ActivityCount - Test Case 5 - End ###');
    }
    
    //Test Method for CR-20120417-730
    static testMethod void testInitialVisitDateForBundledOpportunities() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.IsTesting = true;
        Util.byPassAlltriggers=true;
    
        Datetime startDT = Datetime.newInstanceGmt(2011,6,1,12,1,5).addDays(-10);
        Date startD = startDT.date();
        Datetime endDT = startDT.addDays(1);

        Account acc = new Account(Name = 'acc', Account_Formal_Name__c = 'acc');
        insert acc;
        
        // Test Class Fix Start Here 13Feb By: Dipesh Gupta
        //Creating Contact record 
        Contact cont = TestUtilities.CreateNewContact(True);
        // Test Class Fix End Here 13Feb By: Dipesh Gupta
		
        //Setting flag values
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;
        //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
        Opportunity bundledOpportunity = new Opportunity(Sales_Pursuit_Products__c = 'APS',Name = 'testopp',Main_Contact__c = cont.Id, AccountId = acc.Id, StageName = 'Prospecting', CloseDate = Date.today()-10);
        insert bundledOpportunity;
        
        //Setting flag values
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;
        
        // Prep the test Opportunity
        bundledOpportunity.Next_PA_Date__c = null;
        bundledOpportunity.Initial_Visit_Date__c = null;
        update bundledOpportunity;
        
        Event evtPA1 = new Event(WhatId = bundledOpportunity.Id, ActivityDate = startd.addDays(2), StartDateTime = startdt.addDays(2), EndDateTime = startdt.addDays(2),
                                IsAllDayEvent = true,
                                Cancelled_Did_Not_Occur__c = false, Event_Type__c = Constants.EVENT_TYPE_IN_PERSON_VISIT , Event_Purpose__c = Constants.EVENT_PURPOSE_RELATIONSHIP_VISIT,
                                Executive_Type__c = 'CXO', Visit_Location__c = 'Campus' );
        
        Test.startTest();
        
         Util.byPassAlltriggers=false;
        
        // Confirm Next Phone Appointment Date Updates
        insert evtPA1;
        
        bundledOpportunity = [select Id, Initial_Visit_Date__c, Next_PA_Date__c from Opportunity where Id = :bundledOpportunity.Id];
        //System.assertEquals(bundledOpportunity.Initial_Visit_Date__c, startD.addDays(2));
        
        //Reset Opportunity trigger flags
        TestUtilities.resetOpportunityTriggerFlags();
        
        Util.byPassAlltriggers=true;
        
        //Setting flag values
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;
        
        //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
        //Child Opportunity
        Opportunity childOpportunity = new Opportunity(Sales_Pursuit_Products__c = 'APS',Name = 'Child Opp',Main_Contact__c = cont.Id, AccountId = acc.Id, StageName = 'Prospecting', CloseDate = Date.today()-10);
        insert childOpportunity;
        
        Test.stopTest();
        
        Util.byPassAlltriggers=false;
        
        insert new Event(WhatId = bundledOpportunity.Id, ActivityDate = startd.addDays(1), StartDateTime = startdt.addDays(1), EndDateTime = startdt.addDays(1),
                                IsAllDayEvent = true,
                                Cancelled_Did_Not_Occur__c = false, Event_Type__c = Constants.EVENT_TYPE_IN_PERSON_VISIT, Visit_Location__c = 'Campus' );
        
    }
}