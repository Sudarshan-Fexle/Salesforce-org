@isTest
private class TestAccount_NameEAMemberships
{
    /*
    Purpose:    Test Trigger Account_NameEAMemberships
    
    Create By:          Pierre Eymard (SAP Contractor)
    
    Last Modified By:   Nathan Banas (SAP) - 1/25/2011
    
    Current Version:    v1.2
    
    Revision Log:       v1.0 - (PE) Created code
                        v1.1 - (JN) - Modified coverage to account for changes to trigger
                        v1.2 - (NB-2011-01-25) - Added header, code comments, and reviewed code coverage
                        v1.3 - Simplyforce - Bhavi- 2011-11-28 - CR-20110916-67
                        V1.4 - Simplyforce - 02/20/201- Q2C Enhancements/Bugs - Added util.BypassAllTriggers at line no 138
    Code Coverage as of 1/25/2011: 95%
    Code Coverage as of 11/28/2011: 87% 
    */
    
    static testmethod void myUnitTest()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.IsTesting = true;
        Util.byPassAllTriggers = true;
        
        Profile prof = [select Id from Profile Where Name ='System Administrator' limit 1];
        list<User> users = new list<User>();
        for (Integer i = 0; i < 3; i++) {
            String digit = String.valueOf(i);
            users.add(new User(
                alias = 'user' + digit, 
                email='standarduser19712' + digit + '@advisorytest2.com', 
                emailencodingkey='UTF-8', 
                lastname='Testing ' + digit, 
                languagelocalekey='en_US', 
                localesidkey='en_US', 
                profileid = prof.id, 
                timezonesidkey='America/Los_Angeles', 
                username='testuser19712' + digit + '@advisorytest2.com'
                ));
            
        } 
        insert users; 
        
        
        // 1) TEST OF NAME : we update an account, then insert one and check the name
        //Removed 4/25/11 for new data JN
        //Account a = [select id, name, Account_Formal_Name__c, Primary_City__c, Primary_State_Province__c from Account limit 1];
        
        Program__c prog = new Program__c(
            Name = 'testprog', 
            Program_Acronym__c = 'TEST', 
            Status__c = 'Active', 
            Create_Memberships__c = 'Yes',
            OwnerId = users[0].id);
        insert prog;
        
        //Enabling trigger again
        Util.byPassAllTriggers = false;
        
        Account a = new Account(Name = 'testacc');
        insert a;
        
        a.Account_Formal_Name__c = 'test';
        a.Primary_City__c = 'test';
        a.Primary_State_Province__c = 'test';
                
        test.startTest();
         
        //Enabling trigger again
        Util.byPassAllTriggers = false;
          
        update a;
        
        a = [select id, name, Account_Formal_Name__c, Primary_City__c, Primary_State_Province__c from Account where id = :a.id ];
        System.assertEquals(a.Account_Formal_Name__c + ' - ' + a.Primary_City__c + ' - ' + a.Primary_State_Province__c, a.name);
        
        // preparation of test #4)
        List<Program__c> allprograms = new List<Program__c> ([select id From Program__c where status__c = 'Active' and Create_memberships__c = 'Yes' ]);
        //Program__c prog; 
        
        if (allprograms.size() == 0)
        {
              allprograms = [select id From Program__c limit 10 ];
              
              for (Program__c p: allprograms)
              {
                  p.status__c = 'Active';
                  p.Create_memberships__c = 'Yes';
              }
              
              update allprograms;
        }
        
        System.assert(allprograms.size() != 0);
        prog = allprograms[0];
      
        a = new Account(name = 'test', Account_Formal_Name__c = ' tada' , Primary_City__c = 'city', Primary_State_Province__c ='sdf' );
        
        system.debug('\n\n55 insert')       ;
        
        //Enabling trigger again
        Util.byPassAllTriggers = false;
        
        insert a;
        
        a = [select id, name, ownerid from Account where id = :a.id ];
        System.assertEquals('tada - city - sdf', a.name);
        
        // 4) test of Membership__c
        /* This function was moved to Util as a @future method
        if (prog != null)
        {
            List<Membership__c> msps = new List<Membership__c> ([select id from Membership__c where account_name__c = :a.id and Program__c = :prog.id]);
            System.assert(msps.size() != 0);
        }
        */  
        // 2) test of EA_AE__c and 3) test
        
        //Removed 4/25/11 JN
        //User u = [select id from user where isactive = true and id != :a.ownerid limit 1];
        User u = users[1];
        AccountTeamMember atm = new AccountTeamMember(UserId = u.id, TeamMemberRole = 'AE or EA', accountid = a.id);
        
        insert atm;
        
        //Removed 4/25/11 for new data JN 
        //Contact c = [select id,Employee_User_Record__c from Contact limit 1];
        Contact c  = new Contact(
            AccountId = a.id,
            Employee_User_Record__c = u.id,
            LastName = 'testcontact',
			Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855'
            );

		//By pass all trigger due to CANNOT_INSERT_UPDATE_ACTIVATE_ENTITY,
		util.BypassAllTriggers = true;

        insert c;
        
        c = [select id,Employee_User_Record__c from Contact where id = :c.id ];
        System.debug(' ************ updated contact c= '+ c.id+' and c.employee user record: ' +c.Employee_User_Record__c );
        a.ownerid = u.id;
        
        //Enabling trigger again
        Util.byPassAllTriggers = false;
        
        update a;
        
        test.stopTest();    
    }
    
    static testmethod void testAccountTeamMember_RIRM()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        Account a = testUtilities.CreateNewAccount(true);
        
        List<User> users = new List<User>();
        User actUser_Mike = TestUtilities.CreatenewUser(false);
        actUser_Mike.FirstName = 'Mike';
        actUser_Mike.IsActive = true;
        users.add(actUser_Mike);
        
        User actUser_Joe = TestUtilities.CreatenewUser(false);
        actUser_Joe.FirstName = 'Joe';
        actUser_Joe.IsActive = true;
        users.add(actUser_Joe);
        
        User actUser_William = TestUtilities.CreatenewUser(false);
        actUser_William.FirstName = 'William';
        actUser_William.IsActive = true;
        users.add(actUser_William);
        
        insert users;
        
        // create Account Team Members
        List<AccountTeamMember> atmList = new List<AccountTeamMember>();
        AccountTeamMember atm_Mike = new AccountTeamMember();
        atm_Mike.AccountId = a.Id;
        atm_Mike.UserId = actUser_Mike.Id;
        atm_Mike.TeamMemberRole = 'Research & Insights RM';
        atmList.add(atm_Mike);
        
        AccountTeamMember atm_Joe = new AccountTeamMember();
        atm_Joe.AccountId = a.Id;
        atm_Joe.UserId = actUser_Joe.Id;
        atm_Joe.TeamMemberRole = 'AE or EA';
        atmList.add(atm_Joe);
        
        insert atmList;
        
        test.startTest();
        
        // update the owner of the institution -- this will execute the logic to update the fields
        a.OwnerId = actUser_William.Id;
        update a;
        
        test.stopTest();
        
        // retreive the updated account
        Account updatedAccount = [SELECT Id, EA_AE__c FROM Account WHERE Id = :a.Id];
        system.assertEquals(actUser_Joe.Id, updatedAccount.EA_AE__c);
        
    }
    
    static testmethod void testDelete()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.IsTesting = true;
        Util.byPassAllTriggers = true;
        
        Program__c prog = new Program__c(
            Name = 'testprog', 
            Program_Acronym__c = 'TEST', 
            Status__c = 'Active', 
            Create_Memberships__c = 'Yes',
            Applicable_Segments__c = 'US Corporate');
        insert prog;
        
        map<String, Id> rtmap = Util.recordtypemap('Account');
        // 1) TEST OF NAME : we update an account, then insert one and check the name
        Account a = new Account(
            Name='tempname',
            Account_Formal_Name__c = 'test');
            
        //Enabling trigger again
        Util.byPassAllTriggers = false;
            
        insert a;
        
        // preparation of test #4)
        List<Program__c> allprograms = new List<Program__c> ([select id, Applicable_Segments__c From Program__c where Create_memberships__c = 'Yes']);
        Integer totalprograms = 0;
        
        for (Program__c testprog : allprograms)
        {
            if ((testprog.Applicable_Segments__c != null) && (testprog.Applicable_Segments__c.contains('US Corporate'))) totalprograms++;
        }
        
        //Program__c prog; 
        if (totalprograms == 0)
        {
          allprograms = [select id From Program__c limit 10 ];
          
          for (Program__c p: allprograms)
          {
              p.Create_memberships__c = 'Yes';
              p.Applicable_Segments__c = 'US Corporate';
              totalprograms++;
          }
          
          update allprograms;
        }
        
        System.assert(totalprograms != 0);
        prog = allprograms[0];
        
        //This Account should have no Memberships now.
        a = [select id, (select id from Memberships__r) from Account where id = :a.id];
        System.assertEquals(0, a.Memberships__r.size());
        
        //Make new memberships for this account
        list<Membership__c> mems = new list<Membership__c>();
        for (Program__c p : allprograms)
        {
            mems.add(new Membership__c(
                Name = 'tempname',
                Program__c = p.id,
                Account_Name__c = a.id));
        }
        
        insert mems;
        
        //keep track of these memberships
        set<id> memids = new set<id>();
        for (Membership__c m : mems) memids.add(m.id);
        
        //Verify size of membership list
        a = [select id, (select id from Memberships__r) from Account where id = :a.id];
        System.assertEquals(memids.size(), a.Memberships__r.size());
        
        test.startTest(); 
        
        //Enabling trigger again
        Util.byPassAllTriggers = false;
        try {
        	delete a;     
        }catch(Exception e) {
            
        }
              
        test.stopTest();        
    }
}