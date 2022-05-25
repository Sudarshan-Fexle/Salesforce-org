/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class Test_Batch_UpdateATMSharingOppNBB {
/**
 *	Purpose		:	Test class for Batch_UpdateATMSharingOppNBB.
 *               
 *	Create By	:  	Bhavi
 *   
 *	Created Date:   11/16/2013
 *   
 *	Revision Log:	V1.1 - Created
 *					v1.2 - (SUNJ) Update Proposal_Value__c with Amount
					V1.3 - Modified By - Abhinav Sharma - 04/05/2018 - CR-20180404-12147 = Increase Code coverage for the Partial Deployment.
 *   				
 *	Coverage	:	93%
 **/
 	
 	//Test method for testing populateSharingOnNBB method of Trigger
 	static testMethod void testPopulateSharingOnNBB(){
 		
        Util.byPassAllTriggers = true;
        
 		//Get System Admin profile list
        List<Profile> profile = [select Id, Name From Profile Where Name = 'System Administrator'];
        
	   	//Test User Create
        List<User> users = new List<User>();
        users.add(new User(Username= Math.random()+'@abc.com', LastName='TESTER1', FirstName='Test1', Email=Math.random()+'@test.com',
                            Alias='Test1', EmailEncodingKey='UTF-8', languagelocalekey='en_US', ProfileId=profile[0].Id, 
                            timezonesidkey='America/Los_Angeles', localesidkey='en_US', EmployeeNumber = '12121212', IsActive = true));
        users.add(new User(Username= Math.random()+'@abc.com', LastName='TESTER2', FirstName='Test1', Email=Math.random()+'@test.com',
                            Alias='Test2', EmailEncodingKey='UTF-8', languagelocalekey='en_US', ProfileId=profile[0].Id, 
                            timezonesidkey='America/Los_Angeles', localesidkey='en_US', EmployeeNumber = '12121212', IsActive = true));
        
        //insert users
        insert users;
        
        //List to hold Accounts record to be insert
 		List<Account> accounts = new List<Account>();
 		
 		//Looping for creating differt test Accounts
        for(Integer i = 1; i <= 3; i++) {
	    	
	    	//populate list of Accounts    
	 		accounts.add(new Account(Name = 'Test Case Account '+ i));
	 	}
	 	
	 	//insert Accounts
	 	insert accounts;
        // Test Class Fix Start Here 07/19/20 By: Mahendra Swarnakar - CR-20200218-13783
        accounts[1].Top_Parent_Institution__c = accounts[0].Id;
        accounts[2].Top_Parent_Institution__c = accounts[0].Id;
        Update accounts;
        
          // Test Class Fix Start Here 13Feb By: Dipesh Gupta
        
        //Creating Contact record 
        Contact cont = TestUtilities.CreateNewContact(false);
        cont.AccountId = accounts[0].Id;
        insert cont;
        // Test Class Fix end Here 07/19/20 By: Mahendra Swarnakar
        // Test Class Fix End Here 13Feb By: Dipesh Gupta
        
	 	Util.byPassAllTriggers = false;
        
        //List to hold Configuration Manager custom setting records
        List<Configuration_Manager__c> configManagers = new List<Configuration_Manager__c>();
        configManagers.add(new Configuration_Manager__c(Name = 'test1', Parameter_Key__c = 'TeamMemberRoleForNBBSharing' , Parameter_Value__c = '% RM'));
        configManagers.add(new Configuration_Manager__c(Name = 'test2',  Parameter_Key__c = 'TeamMemberRoleForNBBSharing' , Parameter_Value__c = '%AE or EA%'));
        
        //Insert configuration Manager custom setting records 
        insert configManagers;
        
	   	//List to hold Account Team Member to be insert 
	   	List<AccountTeamMember> accountTeamMembers = new List<AccountTeamMember>();
	   	
	   	//Loop through Accounts list for ATMs
	   	for(Account account : accounts) {
	   		
	   		accountTeamMembers.add(new AccountTeamMember(UserId = users[0].Id, AccountId = account.Id, TeamMemberRole = 'Research & Insights - RM'));
	   		accountTeamMembers.add(new AccountTeamMember(UserId = users[1].Id, AccountId = account.Id, TeamMemberRole = 'AE or EA'));
		}
	   	
        //insert Account Team Members
	    insert accountTeamMembers;
	    
	    //List to hold Opportunities
	    List<Opportunity> opportunities = new List<Opportunity>();
	    
	    //Loop through Accounts list for Opportunity
	   	for(Account account : accounts) {
	   	
	    	opportunities.add(new Opportunity(Name='Test Opp', Main_Contact__c = cont.Id,StageName = '0-Exploring', Amount = 1, CloseDate = System.today().addDays(32), 
	    											AccountId = account.Id));
	   	}
	   	
	    //Insert Opportunities
	    insert opportunities;
        
	    //Test starts here
	    Test.startTest();
        
	    //List to hold NBB test records
	    List<NBB__c> nBBs = new List<NBB__c>();
	    
	    //Loop through Opportunity List
	    for(Opportunity opportunity : opportunities) {
	    	
	    	nBBs.add(new NBB__c(Opportunity__c = opportunity.Id, OwnerId = Userinfo.getUserId(), Name = 'test1', NBB_Type__c = 'Base Fee', 
    								NBB__c = 10, Unit__c = 5, ATL_Date__c = system.today()));
			nBBs.add(new NBB__c(Opportunity__c = opportunity.Id, OwnerId = Userinfo.getUserId(), Name = 'test2', NBB_Type__c = 'Base Fee', 
									NBB__c = 20, Unit__c = 10, ATL_Date__c = system.today().addDays(2)));
	    }
	    
	    //insert nBBs here
	    insert nBBs;
	    
	    //List to hold NBB Share records to be insert
	    List<NBB__Share> nBBShares = new List<NBB__Share>();
	    
	    //Loop through NBBs list
	    for(NBB__c nBB : nBBs) {
	    	
	    	//add into list to be insert
			nBBShares.add(new NBB__Share(ParentId = nBB.Id, AccessLevel = 'Read', UserOrGroupId = users[0].Id,
											RowCause = Schema.NBB__Share.RowCause.Manual));
	    }
	    
		//Query results of ATMs
		accountTeamMembers = [SELECT Id, TeamMemberRole FROM AccountTeamMember WHERE TeamMemberRole = 'AE or EA'];
		
		//Loop through ATMs to update
		for(AccountTeamMember aTM : accountTeamMembers) {
			aTM.TeamMemberRole = 'Research & Insights - Marketer';
		}	 	
		
		//Update ATMs
		update accountTeamMembers;
        
        //Build the system time of now + 20 Seconds to schedule the batch apex.
        Datetime sysTime = System.now();
        sysTime = sysTime.addSeconds(20);
        String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();

		//Schedule the class
        System.schedule('Sched_UpdateAccTeamMemberSharingOppNBB', chron_exp, new Sched_UpdateAccTeamMemberSharingOppNBB());
	    
        //Execute Batch to give sharing on NBB for ATM's users
	    Database.executeBatch(new Batch_UpdateAccTeamMemberSharingOppNBB(), 200);
	    
		//Test stops here   
	    Test.stopTest();
	    
	    //Query result of NBB Share records
	 	nBBShares = [SELECT Id FROM NBB__Share WHERE ParentId IN: nBBs AND RowCause =: Schema.NBB__Share.RowCause.Manual];
	 	
	 	//Assert statements
	 	System.assertEquals(6, nBBShares.size());
	}
}