@istest
class Test_WarmLeadSetName
{
    /*
    Purpose:    Test Trigger WarmLeadSetName
    
    Create By:          
    
    Last Modified By:   Nathan Banas (SAP) - 1/25/2011
    
    Current Version:    v1.1
    
    Revision Log:       v1.0 - () Created code
                        v1.1 - (NB-2011-01-25) - Added header, code comments, and reviewed code coverage
                        v1.2 - (Bhavi) - 05/02/2013 - Comment out the method testCreateMatchingWarmLeadsMtM - CR-20130411-2856
                        
    Code Coverage as of 1/25/2011: 100%
    */

    static Integer maxAccNameLength = 55;
    
    private static User[] usrs = [select Id, Name from User where isActive = true and Profile.Name = 'System Administrator' limit 2];
    
    static testmethod void testNameWarmLead()
    {
        //Flag for testing mode on triggers
        Util.IsTest(true);
        
        Account a = new Account(
            Name='Temp name',
            //80 characters in formalname
            Account_Formal_Name__c = '12345678901234567890123456789012345678901234567890123456789012345678901234567890',
            Primary_City__c = 'city',
            Primary_State_Province__c  = 'VA');
        insert a;
        a = [select id, Name from Account where id = :a.id];
        
        Account b = new Account(
            Name='Temp name',
            //80 characters in formalname, different from the other one
            Account_Formal_Name__c = '56789012345678901234567890123456789012345678901234567890123456789012345678901234',
            Primary_City__c = 'city',
            Primary_State_Province__c  = 'VA');
        insert b;
        b = [select id, Name from Account where id = :b.id];
        
        String orignamea = a.Name;
        String shortnamea = a.Name.substring(0,maxAccNameLength);
        String orignameb = b.Name;
        String shortnameb = b.Name.substring(0,maxAccNameLength);
        
        Program__c prog = new Program__c(
            Name = 'progname',
            Program_Acronym__c = 'TEST');
        insert prog;
        
        Warm_Lead__c testwl = new Warm_Lead__c(
            Name = 'tempname',
            Lead_Date__c = system.today(),
            Account__c = a.id,
            Primary_Program__c = prog.id,
            Grade__c = '1',
            OwnerId = usrs[0].Id,
            Marketer_Assignment__c = usrs[0].Id
            );


        test.startTest();
        
        insert testwl;
        
        //show that trigger used truncated account name
        testwl = [select Name from Warm_Lead__c where id = :testwl.id];
        system.assertEquals(system.today().format() + ' - ' + shortnamea + ' - TEST',testwl.Name);
        System.debug('false2--->'+testwl.Name);
        testwl.Account__c = b.id;
        update testwl;
        
        //show that trigger used truncated account name on new account
        testwl = [select Name from Warm_Lead__c where id = :testwl.id];
        system.assertEquals(system.today().format() + ' - ' + shortnameb + ' - TEST',testwl.Name);
        System.debug('false1--->'+testwl.Name);
        testwl.Grade__c = '3';
        update testwl;
        
        //show that trigger didn't change anything
        testwl = [select Name from Warm_Lead__c where id = :testwl.id];
        system.assertEquals(system.today().format() + ' - ' + shortnameb + ' - TEST',testwl.Name);
        
        //show that the trigger removed the Primary Program Acronym from the name
        testwl.Primary_Program__c = null;
        testwl.Lead_Date__c = null;
        update testwl;
        
        testwl = [select Name from Warm_Lead__c where id = :testwl.id];
        system.assertEquals(shortnameb + ' -',testwl.Name);
        
        //show that the trigger removed the Account from the name and readded the Primary Program Acronym
        testwl.Primary_Program__c = prog.id;
        testwl.Account__c = null;
        update testwl;
        
        testwl = [select Name from Warm_Lead__c where id = :testwl.id];
        system.assertEquals('- TEST',testwl.Name);
        
        testwl.Primary_Program__c = null;
        testwl.Account__c = null;
        update testwl;
        
        testwl = [select Name from Warm_Lead__c where id = :testwl.id];
        system.assertEquals('-',testwl.Name);
        
        test.stopTest();
    }

    static testmethod void testNameWarmLeadMarketerToOwner()
    {
        Util.IsTest(true);
        
        List<Warm_Lead__c> wrmLds = new List<Warm_Lead__c>();
        
        //Modified by - Abhinav Sharma - 06/02/2020 - CR-20200103-13588 - Warm Leads: Change Ownership
        Warm_Lead__c testwl = new Warm_Lead__c(
            Name = 'tempname',
            Lead_Date__c = system.today(),
            //Account__c = a.id,
            //Primary_Program__c = prog.id,
            //Marketer_Assignment__c = usrs[0].Id,
            Marketing_Associate_Assignment__c = usrs[0].Id,
            OwnerId = usrs[1].Id,
            Grade__c = '1'
            );
        
        wrmLds.add(testwl);
        
        Warm_Lead__c testwl2 = new Warm_Lead__c(
            Name = 'tempname',
            Lead_Date__c = system.today(),
            //Account__c = a.id,
            //Primary_Program__c = prog.id,
            //Marketer_Assignment__c = usrs[0].Id,
            OwnerId = usrs[0].Id,
            Grade__c = '1'
            );
        
        wrmLds.add(testwl2);
        
        test.startTest();
        insert wrmLds;
        test.stopTest();
        
        testwl = [select Id, OwnerId, /*Marketer_Assignment__c*/ Marketing_Associate_Assignment__c from Warm_Lead__c where Id = :testwl.Id];
        
        System.AssertEquals(testwl.Marketing_Associate_Assignment__c, testwl.OwnerId);
    }
    
    
    /*static testmethod void testCreateMatchingWarmLeadsMtM()
    {
        //Flag for testing mode on triggers
        Util.IsTest(true);
        
        //Create a test account
        Account a = new Account( Name='Temp Name', Account_Formal_Name__c = 'Test', Primary_City__c = 'city', Primary_State_Province__c  = 'VA');
        insert a;
        
        Program__c prog = new Program__c(Name = 'progname', Program_Acronym__c = 'TEST');
        insert prog;
        
        //Get appropriate record Type
        Map<String, Id> rtmap = Util.recordtypemap('Opportunity');
        if (rtmap == null) {
            // ensure that the record type custom setting has been updated with the correct values
            Util.resetRecordtypeSettings();
            rtmap = Util.recordtypemap('Opportunity');
        }
        String NBBRecordTypeId = rtmap.get('RI Marketing');
        
        //Create test Opportunity data
        Opportunity opp = new Opportunity(AccountId = a.Id, Name = 'Test', StageName = 'Pending', CloseDate = System.today(), 
                                            Program__c = prog.Id, RecordTypeId = NBBRecordTypeId);
        insert opp;
        
        //Create a Warm Lead
        Warm_Lead__c warmLead = new Warm_Lead__c(Name = 'tempname', Lead_Date__c = system.today(), Account__c = a.id, Primary_Program__c = prog.id,
                                                Grade__c = '1', OwnerId = usrs[0].Id, Marketer_Assignment__c = usrs[0].Id);
        
        //Start testing from here
        Test.startTest();
        
        //Insert record
        insert warmLead;
        
        //Assert for the result
        List<Warm_Lead_MtM__c> warmLeadsMtM = [Select Id from Warm_Lead_MtM__c where Warm_Lead__c =: warmLead.Id AND Opportunity__c =: opp.Id];
        System.assertEquals(1, warmLeadsMtM.size());
        
        //Check for the Warm Lead status
        warmLead = [Select Status__c from Warm_Lead__c where Id =: warmLead.Id];
        System.assertEquals('Opportunity Identified (Moved to Opportunity)', warmLead.Status__c);
        
        //Stop testing here
        Test.stopTest();
        
        
    }*/
}