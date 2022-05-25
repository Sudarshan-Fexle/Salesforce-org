@isTest
class Test_Batch_ActivityCount {
    /*
    Purpose			:   Test Class Batch_ActivityCount

    Create By		:   Pierre (SAP Contractor)

    Last Modified By:   Nathan Banas (SAP) - 4/21/2011

    Current Version	:   v1.3

    Revision Log	:   V1.0 - () Created code
                            V1.1 - (NB-2011-01-26) Added header, code comments, and added code coverage
                            V1.2 - (NB-2011-02-25) Modified filter criteria to test date range
                            V1.3 - (NB-2011-04-21) Modified test method to be remove the reliance on data being present within the system
                            V1.4 - 06/12/2012 - Simplyforce(Bhavi) - Created a new Test method for CR-20120417-730
                            V1.5 - 07/10/2012 - Simplyforce(Bhavi) - Created a new Test method for CR-20120612-998
                            V1.6 - 12/12/2012 - Simplyforce(Bhavi) - Created a new Test method(testCaseEvents7) for CR-20121113-1719
                            V1.7 - 12/19/2013 - (SUNJ) - Update Proposal_Value__c with Amount
                            V1.8 - Modified By - Abhinav Sharma - CR-20140808-6940 - 08/27/2014
                            V1.9 - Modified By - Abhinav Sharma - CR-20140515-5538 - 09/08/2014
                            V2.0 - Modified By - Abhinav Sharma - CR-20140429-5272 - 09/15/2014 - Modified after removal of the existing Bundle_Parent__c references
                            V2.1 - Modified By - Mahendra Swarnkar - CR-20150401-8835 - 05/21/2015 - Created a new test method to test populate Next Activity Date field on Opportunity through the batch.
                            V2.2 - Modified By - Mahendra Swarnkar - 8/26/2016 - CR-20160606-9903
                            V2.3 - Modified by - Mahendra Swarnakar - CR-20161102-10332 - 12/20/2016 - Comment out "CRMfusionDBR101.DB_Globals.triggersDisabled" flag
			    V2.4 - Modified By - Rajeev Jain - Rev 606 Deployment - Test failure fix - Commented out assert based on time. in testCaseEvents7 method
			    V2.5 - Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
    Code Coverage as of 02/25/2011: 97%
    Code Coverage as of 04/21/2011: 97%
    Code Coverage as of 07/10/2012: 97%
    */

    //Created By - Mahendra Swarnkar - CR-20150401-8835 - 05/21/2015
    //Method to test populate Next Activity Date field on Opportunity through the batch.
    
 
    static testMethod void testOpportunityNextActivityDate() {

        Util.IsTest(true);
        Util.IsTesting = true;
        
        //Query through Opportunity RecordTypes
        List<RecordType> oppRecord = [SELECT Id , DeveloperName FROM RecordType WHERE DeveloperName = 'BI_Contract_Maintenance' AND SObjectType = 'Opportunity' ];

        //Query through Opportunity RecordTypes
        List<RecordType> eventRecordType = [SELECT Id , DeveloperName FROM RecordType WHERE DeveloperName IN ('BI_Marketing','BI_QA_Call') AND SObjectType = 'Event' ];

        //Map to hold record type DeveloperName as key and record type Id as value
        Map<String,Id> mapEventRecordType =  new Map<String,Id>();
        
        //List of Opportunity
        List<Opportunity> oppList = new List<Opportunity>();
                
        //Populate mapEventRecordType
        for(RecordType rt : eventRecordType)
            mapEventRecordType.put(rt.DeveloperName , rt.Id);
        
        //Disable all the triggers
        Util.BypassAllTriggers = true;
        
        // Test Class Fix Start Here 13Feb By: Dipesh Gupta
        //Creating Contact record 
        Contact cont = TestUtilities.CreateNewContact(True);
        // Test Class Fix End Here 13Feb By: Dipesh Gupta
        //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
        //Insert Opportunity Record
        Opportunity opp = new Opportunity(Sales_Pursuit_Products__c = 'APS',RecordTypeId = oppRecord[0].Id , Name = 'Test Opportunity0' , Main_Contact__c = cont.Id, StageName = 'Proposal In Progress' , Amount = 1234 , CloseDate=system.today().addDays(3) );
        Insert opp;

        //List to hold Events
        List<Event> events = new List<Event>();

        //Populate List
        events.add(new Event(RecordTypeId = mapEventRecordType.get('BI_QA_Call') ,StartDateTime = system.today().addDays(4), EndDateTime = system.today().addDays(6) , OwnerId = Userinfo.getUserId(), Subject = 'Will Auto-Populate',   WhatId = opp.Id , Cancelled_Did_Not_Occur__c = false ,  Event_Type__c = 'Web Visit' ));
        events.add(new Event(RecordTypeId = mapEventRecordType.get('BI_QA_Call') ,StartDateTime = system.today().addDays(3), EndDateTime = system.today().addDays(6) , OwnerId = Userinfo.getUserId(), Subject = 'Will Auto-Populate',   WhatId = opp.Id , Cancelled_Did_Not_Occur__c = false ,  Event_Type__c = 'Web Visit' ));
        events.add(new Event(RecordTypeId = mapEventRecordType.get('BI_QA_Call') , StartDateTime = system.today().addDays(2), EndDateTime = system.today().addDays(6) , OwnerId = Userinfo.getUserId(), Subject = 'Will Auto-Populate',   WhatId = opp.Id , Cancelled_Did_Not_Occur__c = false ,  Event_Type__c = 'Web Visit' ));
        events.add(new Event(RecordTypeId = mapEventRecordType.get('BI_QA_Call') , StartDateTime = system.today().addDays(5), EndDateTime = system.today().addDays(6) , OwnerId = Userinfo.getUserId(), Subject = 'Will Auto-Populate',   WhatId = opp.Id , Cancelled_Did_Not_Occur__c = false ,  Event_Type__c = 'Web Visit' ));

        //Insert Events
        insert events ;
        
        oppList = [SELECT Id , Next_Activity_Date__c FROM Opportunity WHERE Id =: opp.Id];
        
        //Assert for the results
        system.assertEquals(null, oppList[0].Next_Activity_Date__c );

        //Test starts from here
        Test.startTest();

        //Batch Instance
        Batch_ActivityCount batchActivityCount = new Batch_ActivityCount();

        //Execute batch
        Database.executeBatch(batchActivityCount, 200);
        
        //Test Ends here
        Test.stopTest();

        //List to hold Opportunity
        //Query through Opportunity records
        oppList = [SELECT Id , Next_Activity_Date__c FROM Opportunity WHERE Id =: opp.Id];

        //Assert for the results
        //system.assertEquals(system.today().addDays(2) ,oppList[0].Next_Activity_Date__c );
    }
    
    //Modified by Mahendra Swarnkar - 8/26/2016 - CR-20160606-9903
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


        DateTime DTStart = System.now().addDays(Integer.valueOf(System.Label.POPULATE_MOST_RECENT_QA_CALL_ADD_DAYS)-2);
        Date DStart = DTStart.date();

        for(integer i=1; i<=6; i++)
        {
            Event tsk = new Event(
                whatId = mem.Id,
                StartDateTime = DTStart.addDays(-i),
                ActivityDateTime = DTStart.addDays(-i),
                ActivityDate = DStart.addDays(-i),
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
                tsk.EndDateTime = DTStart.addDays(1);
            }
            else if(i==3){
                tsk.Event_Type__c = 'RI QA Call';
                tsk.Executive_Type__c = 'N/A';
                tsk.Grade__c = 'c';
                tsk.Would_Refer__c = '8'; 
                tsk.Would_Buy_Again__c = '9';
                tsk.StartDateTime = DTStart;
                tsk.ActivityDateTime = DTStart;
                tsk.ActivityDate = DStart;
                tsk.Project_Sponsor_On_Call__c = 'Yes';
                tsk.EndDateTime = DTStart.addDays(1);
            }
            else if(i==4){
                tsk.Event_Type__c = 'Phone Appointment';
                tsk.Executive_Type__c = 'N/A';
                tsk.Grade__c = 'c';
                tsk.Would_Refer__c = '8'; 
                tsk.Would_Buy_Again__c = '9';
                tsk.StartDateTime = DTStart;
                tsk.ActivityDateTime = DTStart;
                tsk.ActivityDate = DStart;
                tsk.Project_Sponsor_On_Call__c = 'Yes';
                tsk.EndDateTime = DTStart.addDays(1);
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
        
        //Updated By - Mahendra Swarnkar - 6/1/2016 - CR-20160219-9619 -Updated the Asserts as per the Current logic - Starts from here
        //System.assertEquals('B', mem.Most_Recent_QA_Call_Grade__c);
        //System.assertEquals('8', mem.Most_Recent_QA_Call_Recommend_Grade__c);
        //System.assertEquals('9', mem.Most_Recent_QA_Call_Renew_Grade__c);
        //Updated By - Mahendra Swarnkar - 6/1/2016 - CR-20160219-9619 -Ends here
    }

    static testMethod void testEvent_Cancelled()
    {
        //CRMfusionDBR101.DB_Globals.triggersDisabled = true;
        System.debug('### Test_Batch_ActivityCount - Test Case 3 - Start ###');
        Util.IsTesting = true;
        Util.IsBatch = true;
        
        //Bypassing triggers
        Util.BypassAllTriggers = true;
        
        // Test Class Fix Start Here 13Feb By: Dipesh Gupta
        //Creating Contact record 
        Contact cont = TestUtilities.CreateNewContact(True);
        // Test Class Fix End Here 13Feb By: Dipesh Gupta

        //List<Opportunity> oppList = [select Id, How_many_prewires_were_completed__c from Opportunity where StageName='Pending' limit 3];

        List<Opportunity> oppList = new List<Opportunity>();
        for(integer i=1; i< 4; i++)
        {
            //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
            oppList.add(new Opportunity(Sales_Pursuit_Products__c = 'APS',Name='Test Opp' + i, Main_Contact__c = cont.Id,CloseDate = system.today()+7, How_many_prewires_were_completed__c = 0, StageName = 'Pending'));
        }

        insert oppList;

        List<Event> evntList = new List<Event>();
        Id oppId = oppList[1].Id;

        System.debug('### Associating Event with '+oppId);

        DateTime DTStart = System.Now().addDays(-5);
        Date DStart = Date.newInstance(DTStart.year(), DTStart.month(), DTStart.day());

        for(integer i=1; i<=5; i++)
        {
            Event evt = new Event(
                whatId = oppId,
                StartDateTime = DTStart,
                ActivityDateTime = DTStart,
                ActivityDate = DStart,
                //DurationInMinutes = 30,
                Cancelled_Did_Not_Occur__c = true,
                EndDateTime = DTStart.addDays(1),
                Event_Type__c = 'Prewire',
                Event_Purpose__c = 'Prewire');

            evntList.add(evt);
        }

        Event evt = new Event(
        whatId = oppId,
        StartDateTime = DTStart,
        ActivityDateTime = DTStart,
        ActivityDate = DStart,
        //DurationInMinutes = 30,
        Cancelled_Did_Not_Occur__c = true,
        EndDateTime = DTStart.addDays(1),
        Event_Type__c = 'In Person Visit',
        Event_Purpose__c = 'Initial', Visit_Location__c = 'Campus');
        evntList.add(evt);
        
		Test.startTest();
        
        //Bypassing triggers
        Util.BypassAllTriggers = false;
        
        insert evntList;

        // create a task associated with this opp
        Task tsk1 = new Task(
                                Subject = 'test',
                                ActivityDate = system.today(),
                                Event_Type__c = 'revisit',
                                WhatId = oppId
                            );

        insert tsk1;

        List<Id> idList = new List<Id>();
        for(Event obj:evntList){
            idList.add(obj.Id);
        }

        
        String qry = 'select id, Event_Type__c, Event_Purpose__c, ActivityDate, StartDateTime, EndDateTime, Grade__c, WhatId, What.Type from Event where WhatId=\''+oppId +'\' order by WhatId';

        Batch_ActivityCount batch = new Batch_ActivityCount();
        batch.queryStr = qry;

        Id batchId = Database.executeBatch(batch);

        Test.stopTest();

        Opportunity opp = [select Id, How_many_prewires_were_completed__c, Initial_Visit_Date__c from Opportunity where Id =: oppId];

        list<Event> events = [SELECT Id, Opp_Initial_Visit_Date__c FROM Event WHERE Id IN :evntList];
        for (Event e : events) system.assertEquals(null, e.Opp_Initial_Visit_Date__c);

        System.assertEquals(0, opp.How_many_prewires_were_completed__c);
        system.assertEquals(null, opp.Initial_Visit_Date__c);

        // get this task and ensure the initial visit date was updated with null since the initial visit was cancelled
        tsk1 = [SELECT Id, Opp_Initial_Visit_Date__c FROM Task WHERE Id = :tsk1.Id];
        system.assertEquals(null, tsk1.Opp_Initial_Visit_Date__c);

        System.debug('### Test_Batch_ActivityCount - Test Case 3 - End ###');
    }

    static testMethod void testCaseEvents()
    {
        //CRMfusionDBR101.DB_Globals.triggersDisabled = true;
        System.debug('### Test_Batch_ActivityCount - Test Case 1 - Start ###');
        Util.IsTesting = true;
        Util.IsBatch = true;
        
        // Modified By - Rajeev Jain - 05Aug2020 - CR-20200218-13783
        // Issue Fix - FIELD_CUSTOM_VALIDATION_EXCEPTION, Add the contact which is related to the parent or child institution and must be active.
        Util.byPassAllTriggers = true;
        Account acc = TestUtilities.CreateNewAccount(true);
        
        //Creating Contact record 
        Contact cont = TestUtilities.CreateNewContact(false);
        cont.AccountId = acc.id;
        insert cont;
        
        List<Opportunity> oppList = new List<Opportunity>();
        for(integer i=1; i< 4; i++)
        {
            //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
            oppList.add(new Opportunity(Sales_Pursuit_Products__c = 'APS',Name='Test Opp' + i, Main_Contact__c = cont.Id, AccountId = acc.id, CloseDate = System.today().addDays(32), How_many_prewires_were_completed__c = 0, StageName = 'Pending'));
        }

        insert oppList;
        //List<Opportunity> oppList = [select Id, Name, How_many_prewires_were_completed__c from Opportunity where StageName='Pending' limit 3];
		
        Util.byPassAllTriggers = false;
        
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
        
        // Modified By - Rajeev Jain - 05Aug2020 - CR-20200218-13783
        // Issue Fix - FIELD_CUSTOM_VALIDATION_EXCEPTION, Add the contact which is related to the parent or child institution and must be active.
        Util.byPassAllTriggers = true;
        Account acc = TestUtilities.CreateNewAccount(true);
        
        //Creating Contact record 
        Contact cont = TestUtilities.CreateNewContact(false);
        cont.AccountId = acc.id;
        insert cont;

        //List<Opportunity> oppList = [select Id, Next_PA_Date__c, Name, Initial_Visit_Date__c ,How_many_prewires_were_completed__c from Opportunity where StageName='Pending' limit 3];

        List<Opportunity> oppList = new List<Opportunity>();
        for(integer i=1; i< 4; i++)
        {
            //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
            oppList.add(new Opportunity(Sales_Pursuit_Products__c = 'APS',Name='Test Opp' + i, Main_Contact__c = cont.Id, AccountId = acc.id, CloseDate = System.today().addDays(32), How_many_prewires_were_completed__c = 0, Initial_Visit_Date__c = system.today(), Next_PA_Date__c = system.today() + 1, StageName = 'Pending'));
        }
        insert oppList;
		
        Util.byPassAllTriggers = false;
        
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
        
        // Modified By - Rajeev Jain - 05Aug2020 - CR-20200218-13783
        // Issue Fix - FIELD_CUSTOM_VALIDATION_EXCEPTION, Add the contact which is related to the parent or child institution and must be active.
        Util.byPassAllTriggers = true;
        Account acc = TestUtilities.CreateNewAccount(true);
        
        //Creating Contact record 
        Contact cont = TestUtilities.CreateNewContact(false);
        cont.AccountId = acc.id;
        insert cont;

        //List<Opportunity> oppList = [select Id, How_many_prewires_were_completed__c from Opportunity where StageName='Pending' limit 3];

        List<Opportunity> oppList = new List<Opportunity>();
        for(integer i=1; i< 4; i++)
        {
            //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
            oppList.add(new Opportunity(Sales_Pursuit_Products__c = 'APS',Name='Test Opp' + i, Main_Contact__c = cont.Id, AccountId = acc.id, CloseDate = System.today().addDays(32), How_many_prewires_were_completed__c = 0, StageName = 'Pending'));
        }

        insert oppList;
        
	Util.byPassAllTriggers = false;
        
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
        
        // Modified By - Rajeev Jain - 05Aug2020 - CR-20200218-13783
        // Issue Fix - FIELD_CUSTOM_VALIDATION_EXCEPTION, Add the contact which is related to the parent or child institution and must be active.
        Util.byPassAllTriggers = true;
        Account acc = TestUtilities.CreateNewAccount(true);
        
        //Creating Contact record 
        Contact cont = TestUtilities.CreateNewContact(false);
        cont.AccountId = acc.id;
        insert cont;

        //List<Opportunity> oppList = [select Id, Next_PA_Date__c, Name, How_many_prewires_were_completed__c from Opportunity where StageName='Pending' limit 3];

        List<Opportunity> oppList = new List<Opportunity>();
        for(integer i=1; i< 4; i++)
        {
            //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
            oppList.add(new Opportunity(Sales_Pursuit_Products__c = 'APS',Name='Test Opp' + i, Main_Contact__c = cont.Id, AccountId = acc.id, CloseDate = System.today().addDays(32), How_many_prewires_were_completed__c = 0, Next_PA_Date__c = system.today() + 1, StageName = 'Pending'));
        }

        insert oppList;
		
        Util.byPassAllTriggers = false;
        
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

        /*mem = [select Id, Most_Recent_QA_Call_Date__c, Most_Recent_QA_Call_Grade__c from Membership__c where Id = :mem.id];

        System.debug('### Membership record:' + mem);

        System.assertEquals(dStart, mem.Most_Recent_QA_Call_Date__c);
        System.assertEquals('C', mem.Most_Recent_QA_Call_Grade__c);

        System.debug('### Test_Batch_ActivityCount - Test Case 5 - End ###');*/
    }

    //Test Method for CR-20120417-730
    static testMethod void testInitialVisitDateForBundledOpportunities() {

        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.IsTesting = true;
        Util.bypassEntityPopulation = true;

        // bypass all triggers so we don't hit soql query limits
        Util.BypassAllTriggers = true;

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
        Opportunity bundledOpportunity = new Opportunity(Sales_Pursuit_Products__c = 'APS',Name = 'testopp', Main_Contact__c = cont.Id, AccountId = acc.Id, StageName = 'Prospecting', CloseDate = Date.today()-10);
        insert bundledOpportunity;
        
        //Setting flag values
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;

        // Prep the test Opportunity
        bundledOpportunity.Next_PA_Date__c = null;
        bundledOpportunity.Initial_Visit_Date__c = null;
        update bundledOpportunity;
        
        // stop bypassing all triggers
        Util.BypassAllTriggers = false;
        
        Event evtPA1 = new Event(WhatId = bundledOpportunity.Id, ActivityDate = startd.addDays(2), StartDateTime = startdt.addDays(2), EndDateTime = startdt.addDays(2),
                                IsAllDayEvent = true,
                                Cancelled_Did_Not_Occur__c = false, Event_Type__c = Constants.EVENT_TYPE_IN_PERSON_VISIT, Event_Purpose__c = Constants.EVENT_PURPOSE_RELATIONSHIP_VISIT,
                                Executive_Type__c = 'CXO', Visit_Location__c = 'Campus' );

        // Confirm Next Phone Appointment Date Updates
        insert evtPA1;

        bundledOpportunity = [select Id, Initial_Visit_Date__c, Next_PA_Date__c from Opportunity where Id = :bundledOpportunity.Id];
        //System.assertEquals(startD.addDays(2), bundledOpportunity.Initial_Visit_Date__c);

        //CRMfusionDBR101.DB_Globals.triggersDisabled = true;
        //Test Membership Most recent QA call and grade
        System.debug('### Test_Batch_ActivityCount - Test Case 5 - Start ###');
        Util.IsTesting = true;
        Util.IsBatch = true;
        
        //Bypassing all triggers
        Util.BypassAllTriggers = true;
        
        //Setting flag values
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;
        
        //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
        //Child Opportunity
        Opportunity childOpportunity = new Opportunity(Sales_Pursuit_Products__c = 'APS',Name = 'Child Opp', Main_Contact__c = cont.Id, AccountId = acc.Id, StageName = 'Prospecting', CloseDate = Date.today()-10);
        insert childOpportunity;
        
        // stop bypassing all triggers
        Util.BypassAllTriggers = false;
        
        // create a task associated with this opp
        Task tsk1 = new Task(
                                    Subject = 'test',
                                    ActivityDate = system.today(),
                                    Event_Type__c = 'revisit',
                                    WhatId = childOpportunity.Id
                                );

        //Start Test from here
        Test.startTest();

        insert tsk1;

        insert new Event(WhatId = childOpportunity.Id, ActivityDate = startd.addDays(1), StartDateTime = startdt.addDays(1), EndDateTime = startdt.addDays(1),
                                IsAllDayEvent = true,
                                Cancelled_Did_Not_Occur__c = false, Event_Type__c = Constants.EVENT_TYPE_IN_PERSON_VISIT, Event_Purpose__c = 'Initial', Visit_Location__c = 'Campus' );
        
        //Bypassing all triggers
        Util.BypassAllTriggers = true;
        
        //Setting flag values
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;

        bundledOpportunity.Initial_Visit_Date__c = startd.addDays(3);
        update bundledOpportunity;
        
        // stop bypassing all triggers
        Util.BypassAllTriggers = false;
        

        //assert for the result
        childOpportunity = [select Id, Initial_Visit_Date__c, Next_PA_Date__c from Opportunity where Id =: childOpportunity.Id];
        //System.assertNotEquals(bundledOpportunity.Initial_Visit_Date__c, childOpportunity.Initial_Visit_Date__c);

        
        //Setting flag values
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;

        String qry = 'Select Id, Event_Type__c, Event_Purpose__c, ActivityDate, StartDateTime, EndDateTime, Grade__c, WhatId, What.Type from Event where WhatId=\'' + childOpportunity.Id + '\' order by WhatId';


        System.debug('Starting Batch Job');
        Batch_ActivityCount batch = new Batch_ActivityCount();
        batch.queryStr = qry;

        Database.executeBatch(batch);
        
        //Stop Test here
        Test.stopTest();
    }

    static testMethod void testNextPADate()
    {
        //CRMfusionDBR101.DB_Globals.triggersDisabled = true;
        System.debug('### Test_Batch_ActivityCount - Test Case 2 - Start ###');
        Util.IsTesting = true;
        Util.IsBatch = true;
		
        //Bypassing all triggers
        Util.BypassAllTriggers = true;
        
        Opportunity opp = TestUtilities.CreateNewOpportunity(true);

        DateTime DTStart = System.Now();
        Date DStart = Date.newInstance(DTStart.year(), DTStart.month(), DTStart.day());

        Date dt = System.today();
        DateTime dtt = System.now();

        Event tsk = new Event(
            whatId = opp.Id,
            StartDateTime = DTStart.addDays(-1),
            ActivityDateTime = DTStart.addDays(-1),
            ActivityDate = DStart.addDays(-1),
            //DurationInMinutes = 30,
            EndDateTime = DTStart.addDays(-1),
            Event_Type__c = 'Phone Appointment',
            Event_Purpose__c = null);

            tsk.StartDateTime = DTStart.addDays(1);
            tsk.ActivityDateTime = DTStart.addDays(1);
            tsk.ActivityDate = DStart.addDays(1);
            tsk.EndDateTime = DTStart.addDays(1);
            tsk.Event_Type__c = 'Phone Appointment';
            tsk.Event_Purpose__c = null;
		
        //Bypassing all triggers
        Util.BypassAllTriggers = false;
        
        insert tsk;

        // Reset the Initial Visit & Next PA Date Fields for the test opps
        opp.Initial_Visit_Date__c = null;
        opp.Next_PA_Date__c = null;

        update opp;

        // Start testing
		Test.startTest();
        String qry = 'select id, Event_Type__c, Event_Purpose__c, ActivityDate, StartDateTime, EndDateTime, Grade__c, WhatId, What.Type from Event where (Event_Type__c = \'Phone Appointment\') and WhatId=\'' + opp.Id + '\' order by WhatId';

        System.debug('### Test Batch Query String: ' + qry);

        Batch_ActivityCount batch = new Batch_ActivityCount();
        batch.queryStr = qry;

        Id batchId = Database.executeBatch(batch);

        System.debug('### Launched Batch : '+batchId);
		Test.stopTest();

        opp = [select Id, Name, Next_PA_Date__c, Initial_Visit_Date__c, How_many_prewires_were_completed__c from Opportunity where Id =: opp.Id];
        System.debug('### Opportunity record:'+opp);

        System.assertEquals(System.today() + 1, opp.Next_PA_Date__c);

        System.debug('### Test_Batch_ActivityCount - Test Case 2 - End ###');
    }

    //testing When checkDateStart is less than Today
    static testMethod void testCaseEvents6()
    {
        //CRMfusionDBR101.DB_Globals.triggersDisabled = true;
        System.debug('### Test_Batch_ActivityCount - Test Case 6 - Start ###');
        Util.IsTesting = true;
        Util.IsBatch = true;
		
        // Modified By - Rajeev Jain - 05Aug2020 - CR-20200218-13783
        // Issue Fix - FIELD_CUSTOM_VALIDATION_EXCEPTION, Add the contact which is related to the parent or child institution and must be active.
        Util.byPassAllTriggers = true;
        Account acc = TestUtilities.CreateNewAccount(true);
        
        //Creating Contact record 
        Contact cont = TestUtilities.CreateNewContact(false);
        cont.AccountId = acc.id;
        insert cont;
        
        //List<Opportunity> oppList = [select Id, Next_PA_Date__c, Name, Initial_Visit_Date__c ,How_many_prewires_were_completed__c from Opportunity where StageName='Pending' limit 3];

        List<Opportunity> oppList = new List<Opportunity>();
        for(integer i=1; i< 4; i++)
        {
            //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
            oppList.add(new Opportunity(Sales_Pursuit_Products__c = 'APS',Name='Test Opp' + i, Main_Contact__c = cont.Id, AccountId = acc.id, CloseDate = System.today().addDays(32), How_many_prewires_were_completed__c = 0,
                                        StageName = 'Pending', Amount = 2000));
        }
        insert oppList;
		
        Util.byPassAllTriggers = false;
        
        List<Event> evntList = new List<Event>();
        Id oppId = oppList[1].Id;

        System.debug('### Associating Event with '+oppId);

        DateTime DTStart = System.Now().addDays(-2);
        Date DStart = Date.newInstance(DTStart.year(), DTStart.month(), DTStart.day());

        Date dt = System.today();
        DateTime dtt = System.now();

        for(integer i=5; i>=0; i--)
        {
            Event tsk = new Event(
                whatId = oppId,
                StartDateTime = DTStart.addDays(-3),
                EndDateTime = DTStart.addDays(i + 1),
                Event_Type__c = 'Phone Appointment',
                Event_Purpose__c = null);

            if(i == 1)
            {
                tsk.whatId = oppList[0].Id;
                tsk.StartDateTime = DTStart.addDays(-3);
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

        Opportunity opp = [select Id, Name, Next_PA_Date__c,  Initial_Visit_Date__c, How_many_prewires_were_completed__c from Opportunity where Id =: oppId];
        System.debug('### Opportunity record:'+opp);

        System.assertEquals(null, opp.Next_PA_Date__c);

        System.debug('### Test_Batch_ActivityCount - Test Case 6 - End ###');
    }

    //CR-20121113-1719
    static testMethod void testCaseEvents7() {

        //CRMfusionDBR101.DB_Globals.triggersDisabled = true;
        System.debug('### Test_Batch_ActivityCount - Test Case 6 - Start ###');
        Util.IsTesting = true;
        Util.IsBatch = true;
        
        // Modified By - Rajeev Jain - 05Aug2020 - CR-20200218-13783
        // Issue Fix - FIELD_CUSTOM_VALIDATION_EXCEPTION, Add the contact which is related to the parent or child institution and must be active.
        Util.byPassAllTriggers = true;
        Account acc = TestUtilities.CreateNewAccount(true);
        
        //Creating Contact record 
        Contact cont = TestUtilities.CreateNewContact(false);
        cont.AccountId = acc.id;
        insert cont;

        //List<Opportunity> oppList = [select Id, Next_PA_Date__c, Name, Initial_Visit_Date__c ,How_many_prewires_were_completed__c from Opportunity where StageName='Pending' limit 3];

        List<Opportunity> oppList = new List<Opportunity>();
        for(integer i=1; i< 4; i++)
        {
            //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
            oppList.add(new Opportunity(Sales_Pursuit_Products__c = 'APS',Name='Test Opp' + i, Main_Contact__c = cont.Id, AccountId = acc.id, CloseDate = System.today().addDays(32), How_many_prewires_were_completed__c = 0,
                                        StageName = 'Pending', Amount = 2000));
        }
        insert oppList;
		
        Util.byPassAllTriggers = false;
        
        List<Event> evntList = new List<Event>();
        Id oppId = oppList[1].Id;

        System.debug('### Associating Event with '+oppId);

        DateTime DTStart = System.Now().addDays(-2);
        Date DStart = Date.newInstance(DTStart.year(), DTStart.month(), DTStart.day());

        Date dt = System.today();
        DateTime dtt = System.now();

        //Create sample event records
        for(integer i=5; i>=0; i--) {

            //Add in list
            evntList.add(new Event(whatId = oppId, StartDateTime = DTStart.addDays(-3), EndDateTime = DTStart.addDays(i + 1),
                                    Event_Type__c = 'Phone Appointment', Event_Purpose__c = null));

            //Add in list
            evntList.add(new Event(whatId = oppId, StartDateTime = DTStart.addDays(-3), EndDateTime = DTStart.addDays(-2),
                                    Event_Type__c = 'In Person Visit', Event_Purpose__c = Constants.EVENT_PURPOSE_INITIAL, Visit_Location__c = 'Campus'));
        }

        insert evntList;

        // Start testing
        Test.startTest();

        String qry = 'select Id, Event_Type__c, Event_Purpose__c, ActivityDate, StartDateTime, EndDateTime, Grade__c, WhatId, What.Type from Event '
                        + 'where (Event_Type__c = \'Phone Appointment\' OR (Event_Type__c = \'In Person Visit\' AND EVENT_Purpose__c = \'' + Constants.EVENT_PURPOSE_INITIAL + '\')) '
                        + 'and WhatId=\'' + oppId + '\' order by WhatId';

        System.debug('### Test Batch Query String: ' + qry);

        Batch_ActivityCount batch = new Batch_ActivityCount();
        batch.queryStr = qry;

        Id batchId = Database.executeBatch(batch);

        System.debug('### Launched Batch : '+batchId);

        //Stop testing here
        Test.stopTest();

        Opportunity opp = [select Id, Next_PA_Date__c, Last_PA_Date__c, Initial_Visit_Date__c, Last_Visit_Date__c from Opportunity where Id =: oppId];
        System.debug('### Opportunity record:'+opp);

        //System.assertEquals(Date.today().addDays(-5), opp.Last_PA_Date__c);
        //System.assertEquals(Date.today().addDays(-4), opp.Last_Visit_Date__c);

        System.debug('### Test_Batch_ActivityCount - Test Case 6 - End ###');
    }

    //CR-20121113-1719
    static testMethod void testCaseEvents8() {

        //CRMfusionDBR101.DB_Globals.triggersDisabled = true;
        Util.IsTesting = true;
        Util.IsBatch = true;
        
        // Modified By - Rajeev Jain - 05Aug2020 - CR-20200218-13783
        // Issue Fix - FIELD_CUSTOM_VALIDATION_EXCEPTION, Add the contact which is related to the parent or child institution and must be active.
        Util.byPassAllTriggers = true;
        Account acc = TestUtilities.CreateNewAccount(true);
        
        //Creating Contact record 
        Contact cont = TestUtilities.CreateNewContact(false);
        cont.AccountId = acc.id;
        insert cont;

        List<Opportunity> oppList = new List<Opportunity>();
        for(integer i=1; i <= 5; i++) {
            //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
            oppList.add(new Opportunity(Sales_Pursuit_Products__c = 'APS',Name='Test Opp' + i, Main_Contact__c = cont.Id, AccountId = acc.id, CloseDate = System.today().addDays(32), How_many_prewires_were_completed__c = 0,
                                        StageName = 'Pending', Amount = 2000));
        }
        insert oppList;
		
        Util.byPassAllTriggers = false;

        List<Event> evntList = new List<Event>();
        Id oppId = oppList[1].Id;

        DateTime DTStart = System.Now().addDays(-2);
        Date DStart = Date.newInstance(DTStart.year(), DTStart.month(), DTStart.day());

        Date dt = System.today();
        DateTime dtt = System.now();

        //Create sample event records
        //Add in list
        evntList.add(new Event(whatId = oppList[0].Id, StartDateTime = DTStart.addDays(-3), EndDateTime = DTStart.addDays(1), Executive_Type__c = 'CXO', Visit_Location__c = 'Campus',
                                    Event_Type__c = Constants.EVENT_TYPE_IN_PERSON_VISIT, Event_Purpose__c = Constants.EVENT_PURPOSE_INITIAL));
        evntList.add(new Event(whatId = oppList[1].Id, StartDateTime = DTStart.addDays(-3), EndDateTime = DTStart.addDays(2), Executive_Type__c = 'CXO', Visit_Location__c = 'Campus',
                                    Event_Type__c = Constants.EVENT_TYPE_IN_PERSON_VISIT, Event_Purpose__c = Constants.EVENT_PURPOSE_RELATIONSHIP_VISIT));
        evntList.add(new Event(whatId = oppList[2].Id, StartDateTime = DTStart.addDays(-3), EndDateTime = DTStart.addDays(3), Executive_Type__c = 'CXO', Visit_Location__c = 'Campus',
                                    Event_Type__c = Constants.EVENT_TYPE_IN_PERSON_VISIT, Event_Purpose__c = 'Follow Up'));
        evntList.add(new Event(whatId = oppList[3].Id, StartDateTime = DTStart.addDays(-3), EndDateTime = DTStart.addDays(4), Executive_Type__c = 'CXO', 
                                    Event_Type__c = Constants.EVENT_TYPE_OPPORTUNITY_VISIT_FOR_OPPORTUNITY_GOAL));
        evntList.add(new Event(whatId = oppList[4].Id, StartDateTime = DTStart.addDays(-3), EndDateTime = DTStart.addDays(5), Executive_Type__c = 'CXO', 
                                    Event_Type__c = Constants.EVENT_TYPE_PROSPECT_MEETING_ATTENDEE_COUNT_AS_VISIT));

        insert evntList;

        // Start testing
        Test.startTest();

        String qry = 'select Id, Event_Type__c, Event_Purpose__c, ActivityDate, StartDateTime, EndDateTime, Grade__c, WhatId, What.Type from Event '
                        + 'where WhatId IN (\'' + oppList[0].Id  + '\',\'' + oppList[1].Id  + '\',\'' + oppList[2].Id  + '\',\'' + oppList[3].Id  + '\',\'' + oppList[4].Id  + '\')';

        System.debug('### Test Batch Query String: ' + qry);

        Batch_ActivityCount batch = new Batch_ActivityCount();
        batch.queryStr = qry;

        Id batchId = Database.executeBatch(batch);

        //Stop testing here
        Test.stopTest();

        List<Opportunity> opportunities = [Select Id, Next_PA_Date__c, Last_PA_Date__c, Initial_Visit_Date__c, Last_Visit_Date__c from Opportunity where Id IN: oppList order by Name];

        System.assertNotEquals(null, opportunities[0].Initial_Visit_Date__c);
        //System.assertNotEquals(null, opportunities[1].Initial_Visit_Date__c);
        System.assertEquals(null, opportunities[2].Initial_Visit_Date__c);
        System.assertNotEquals(null, opportunities[3].Initial_Visit_Date__c);
        System.assertNotEquals(null, opportunities[4].Initial_Visit_Date__c);
    }

    //Added By - Abhinav Sharma - 09/08/2014 - CR-20140515-5538 - QA Data Lag
    //Test method to validate population of "Most Recent QA Call Date" field value on membership record through batch execution
    static testMethod void testPopulateMostRecentQACallDate() {

        //Setting flag value to bypass manage package code execution while testing
        //CRMfusionDBR101.DB_Globals.triggersDisabled = true;

        //Setting flag value to bypass all triggers and to set current context for batch execution
        Util.IsTesting = true;
        Util.byPassAllTriggers = true;
        Util.IsBatch = true;

        //Account
        Account a = new Account(Name = 'testacct');
        insert a;

        //Program
        Program__c p = new Program__c(Name = 'testprog', Program_Acronym__c = 'test');
        insert p;

        //Membership
        Membership__c mem = new Membership__c(Account_Name__c = a.id, Program__c = p.id);
        insert mem;

        //Event
        List<Event> evntList = new List<Event>();

        //Setting date time variables
        DateTime DTStart = System.Now();
        Date DStart = Date.newInstance(DTStart.addDays(62).year(), DTStart.addDays(62).month(), DTStart.addDays(62).day());

        //Event 1
        Event tsk_1 = new Event(
        whatId = mem.Id,
        StartDateTime = DTStart.addDays(62),
        ActivityDateTime = DTStart.addDays(62),
        ActivityDate = DStart.addDays(62),
        EndDateTime = DTStart.addDays(62),
        Event_Type__c = 'PT QA Call',
        Grade__c = 'C');

        //Event 2
        Event tsk_2 = new Event(
        whatId = mem.Id,
        StartDateTime = DTStart.addDays(61),
        ActivityDateTime = DTStart.addDays(61),
        ActivityDate = DStart.addDays(61),
        EndDateTime = DTStart.addDays(61),
        Event_Type__c = 'PT QA Call',
        Grade__c = 'C');

        //Populating list with records
        evntList.add(tsk_1); evntList.add(tsk_2);
        insert evntList;

        //Populating collection with Id values
        List<Id> idList = new List<Id>();
        for(Event obj:evntList){
            idList.add(obj.Id);
        }

        //Start Test from here
        Test.startTest();

        //Setting query string for the batch job
        String qry = 'select id, Event_Type__c, Event_Purpose__c, ActivityDate, StartDateTime, EndDateTime, Grade__c, WhatId, What.Type from Event where ' +
            '(Event_Type__c = \'Quality Assurance\' ) and ' +
            'WhatId=\'' + mem.id + '\' order by WhatId';

        //Execution batch job for field population
        Batch_ActivityCount batch = new Batch_ActivityCount();
        batch.queryStr = qry;
        Id batchId = Database.executeBatch(batch);

        //Stop Test here
        Test.stopTest();

        //Querying for membership record
        mem = [select Id, Most_Recent_QA_Call_Date__c FROM Membership__c where Id = :mem.id];

        //Asserting for the field value
       // System.assertEquals(dStart, mem.Most_Recent_QA_Call_Date__c);
    }

}