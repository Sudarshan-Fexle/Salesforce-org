global class Batch_UpdateMemberships implements Database.Batchable<SObject>, Database.Stateful 
{
	/*
	Purpose: 	Batch process to deal with large numbers of Membership__c objects:
				If action type passed is "update"
					Memberships for passed Program__c IDs will be updated as to Assigned_Marketer__c
				If action type passed is "delete"
					Memberships for passed Program__c will be deleted.
	
	Create By: 		
	
	Last Modified By: 	Nathan Banas (SAP) - 1/28/2011
	
	Current Version: 	v1.1
	
	Revision Log:		v1.0 - (NB) Created code
						v1.1 - (NB-2011-01-28) Added header and code comments
	*/
	
	String actiontype;
	Integer totalprocessed = 0;
	map<Id, Program__c> id2progmap;
	
	global Batch_UpdateMemberships(set<Id> progids, String passedactiontype)
	{
		Util.IsBatch = true;
		actiontype = passedactiontype;
		id2progmap = new map<Id, Program__c>([select id, New_Business_Marketer__c from Program__c where id in :progids]);
	}
	
	// Start(Database.BatchableContext) method from Database.Batchable class
	global Database.queryLocator start(Database.BatchableContext ctx)
	{
		if (Util.IsTesting)
			return Database.getQueryLocator( [Select Id, Assigned_Marketer__c, Program__c, Account_Name__c from Membership__c where Program__c in :id2progmap.keyset() limit 200]);
		else
			return Database.getQueryLocator( [Select Id, Assigned_Marketer__c, Program__c, Account_Name__c from Membership__c where Program__c in :id2progmap.keyset()]);
	}
	
	// Execute(Database.BatchableContext, list<Sobject>) method from Database.Batchable class
	global void execute(Database.BatchableContext ctx, list<Sobject> scope)
	{
		list<Membership__c> membershiplist = (list<Membership__c>)scope;
		totalprocessed += membershiplist.size();
		
		//Assigned Marketer Updates
		If (actiontype == 'update')
		{
			set<id> accids = new set<Id>();
			for (Membership__c mem : membershiplist)
			{
				accids.add(mem.Account_Name__c);
			}
			
			map<Id, Account> id2accmap = new map<Id, Account>([select id, (select id, TeamMemberRole, UserID, AccountID from AccountTeamMembers) from Account where id in :accids]);
			
			for (Membership__c mem : membershiplist)
			{
				//If there is a matching Account in our map (should be!)
				if (id2accmap.keyset().contains(mem.Account_Name__c))
				{
					//go thru and find the right AccountTeamMember by (role = that New Business Marketer field on Program)
					for (AccountTeamMember atm : id2accmap.get(mem.Account_Name__c).AccountTeamMembers)
					{
// DAF - changed 9/27/11						if (atm.TeamMemberRole == id2progmap.get(mem.Program__c).New_Business_Marketer__c)
						if (atm.TeamMemberRole.contains(id2progmap.get(mem.Program__c).New_Business_Marketer__c))
						{
							mem.Assigned_Marketer__c = atm.UserID;
							
							//assume the first one we found is the right one.
							break;
						}
					}
				}
			}
			
			//make changes permanent
			update membershiplist;
		
		//delete if "delete"
		}
		else if (actiontype == 'delete')
		{
			delete membershiplist;
		}
	}
	
	// Finish(Database.BatchableContext) method from Database.Batchable class
	global void finish(Database.BatchableContext ctx)
	{
		
	}
	
	static testmethod void testupdatememberships()
	{
		Util.IsTest(true);
		//Replaced queries with new data 042111 JN
		//Membership__c mem = [select Program__c, Account_Name__c, Assigned_Marketer__c from Membership__c limit 1];
		Membership__c mem;
		String rolename = 'test new business';
		
		User u = [select id from User where IsActive = true and Profile.Name = 'System Administrator' limit 1];
		
		//Program__c prog = [select id, (select id from Memberships__r limit 100) from Program__c where id = :mem.Program__c];
		list<Account> testaccs = new list<Account>();
		for (Integer i = 0; i < 20; i++) {
			testaccs.add(new Account(
				Name = 'testacc' + String.valueof(i),
				Account_Formal_Name__c = 'testacc' + String.valueof(i)
				)); 
		}
		insert testaccs;
		
		Program__c prog = new Program__c(
			Name = 'testprog', 
			Program_Acronym__c = 'TEST',
			New_Business_Marketer__c = rolename);
		insert prog;
		
		list<Membership__c> testmems = new list<Membership__c>();
		for (Integer i = 0; i < 20; i++) {
			testmems.add(new Membership__c(
				Account_Name__c = testaccs[i].id,
				Program__c = prog.id)); 
		}
		insert testmems;
		
		
		prog = [select id, 
			(select id from Memberships__r limit 100) 
			from Program__c 
			where id = :prog.id];
			
		//Assert there are Memberships on this Program.
		system.assert(prog.Memberships__r.size() > 0);
		
		//pick a Membership and delete the Assigned Marketer value
		mem = prog.Memberships__r[0];
		
		//assert null value
		mem = [select Program__c, Account_Name__c, Assigned_Marketer__c from Membership__c where id = :mem.id];
		system.assertEquals(null, mem.Assigned_Marketer__c);
		
		//figure out what that value should be
		//String rolename = [select New_Business_Marketer__c from Program__c where id = :mem.Program__c].New_Business_Marketer__c;
		Id properMarketerId = u.id;
		for (AccountTeamMember atm : [select UserID, TeamMemberRole from AccountTeamMember where AccountID = :mem.Account_Name__c]) {
			if (atm.TeamMemberRole == rolename) properMarketerId = atm.UserID;
		}
		
		AccountTeamMember newatm = new AccountTeamMember(
			AccountId = mem.Account_Name__c,
			UserId = properMarketerId,
			TeamMemberRole = rolename);
		insert newatm;
		
test.StartTest();
		Util.IsTesting = true;
		
		Batch_UpdateMemberships um = new Batch_UpdateMemberships(new set<id>{mem.Program__c}, 'update');
		Id batchprocessid = Database.executeBatch(um);

test.StopTest();
		
		//assert the new Assigned Marketer value is what it should be		
		mem = [select Program__c, Account_Name__c, Assigned_Marketer__c from Membership__c where id = :mem.id];
		//system.assertEquals(properMarketerId, mem.Assigned_Marketer__c);
	}
	
	static testmethod void DeleteMembershipstest()
	{
		//Membership__c mem = [select Program__c from Membership__c limit 1];
		//Program__c prog = [select id, (select id from Memberships__r limit 100) from Program__c where id = :mem.Program__c];
		Util.IsTest(true);

		//Creating account.
        Account account = TestUtilities.CreateNewAccount(true);

        //Creating Program
		Program__c prog = new Program__c();
		insert prog;
		
		list<Membership__c> newmems = new list<Membership__c>();
		for (Integer i = 1; i <= 10; i++) {
			newmems.add(new Membership__c(Account_Name__c = account.Id, Program__c = prog.id));
		}
		insert newmems;
		
		prog = [select id, (select id from Memberships__r) from Program__c where id = :prog.id];
		//Assert there are Memberships on this Program.
		system.assert(prog.Memberships__r.size() > 0);
		
test.StartTest();		
		Batch_UpdateMemberships um = new Batch_UpdateMemberships(new set<id> {prog.id}, 'delete');
		Id batchprocessId = Database.executeBatch(um);
test.stopTest();		
		
		//requery prog and Membership list
		prog = [select id, (select id from Memberships__r limit 100) from Program__c where id = :prog.id];
		
		//No Memberships on this Program anymore. 
		system.assertEquals(0, prog.Memberships__r.size());
	}
}