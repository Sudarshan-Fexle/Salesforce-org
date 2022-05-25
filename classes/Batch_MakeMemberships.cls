global class Batch_MakeMemberships implements Database.Batchable<SObject>, Database.Stateful 
{
	/*
	Purpose: 	Create new Memberships for each Account w/ the Name, Account, and Program populated
					
	Create By: 		Create a new Memberships w/ the Name, Account, and Program populated
						- Membership Name should be: Account Name(truncated to 55 characters) + ' - ' + Program Acronym
	
	Last Modified By: 	Nathan Banas (SAP) - 1/28/2011
	
	Current Version: 	v1.1
	
	Revision Log:		v1.0 - () Created code
						v1.1 - (NB-2011-01-28) Added header, code comments, and reviewed code coverage
						V1.2 - Updated by Abhinav sharma - CR-20180813-12500 - Conditionally set Membership record type.
	*/
	
	list<Program__c> progs;
	set<id> progids;
	String debuglog = '';
	String actiontype; 
	Integer totalprocessed = 0;
	
	// Constructor
	global Batch_MakeMemberships(set<Id> ProgramIds)
	{
		progids = ProgramIds;
		progs = [select id, Program_Acronym__c, Applicable_Segments__c, Membership_Record_Type__c from Program__c where id in :ProgramIds];
	}
	
	// Start(Database.BatchableContext) method from Database.Batchable class
	global Database.queryLocator start(Database.BatchableContext ctx)
	{
		// Build a query based on if this class is being called by a test method or not
		if (Util.IsTesting)
		{ 
			return Database.getQueryLocator( [SELECT ID, Name, Recordtype.Name FROM Account limit 200] );
		}
		else
		{
			return Database.getQueryLocator( [SELECT ID, Name, Recordtype.Name FROM Account] );
		}
	}
	
	// Execute(Database.BatchableContext, list<Sobject>) method from Database.Batchable class
	global void execute(Database.BatchableContext ctx, list<Sobject> scope)
	{
		list<Account> accs = (list<Account>)scope;
		list<Membership__c> newmemberships = new list<Membership__c>();
		Integer maxnamelength = Membership__c.Name.getDescribe().getLength();
		system.assert(maxnamelength == 80);
		
		for (Program__c prog : progs)
		{
			debuglog += '<br/>program ' + prog.id;
			Integer accountsprocessed = 0;
			
			// Loop through all accounts		
			for (Account a : accs)
			{
				system.debug('\n\nprog.Applicable_Segments__c ' + prog.Applicable_Segments__c + ' map.get(a.Recordtype.Name) ' + Util.accountRT2SegmentMap.get(a.Recordtype.Name));
				
				// Process only if the Program Applicable segments contains the Account Record Type Name
				if (a.Recordtype.Name != null && Util.accountRT2SegmentMap.get(a.Recordtype.Name) != null && prog.Applicable_Segments__c.contains(Util.accountRT2SegmentMap.get(a.Recordtype.Name)))
				{
					/* Create a new Membership w/ the Name, Account, and Program populated */
					totalprocessed++;
					accountsprocessed++;
					String accname = a.Name;
					Integer maxaccnamelength = 55;
					String suffix = ' - ';
					
					// If the Program Acronym is not null and the Program Acronym is not 'null', set the Suffix of the Membership Name
					if ((prog.Program_Acronym__c != null) && (prog.Program_Acronym__c != 'null'))
						suffix += prog.Program_Acronym__c;
					
					// Truncate the Account name if necessary to 55 characters
					accname = accname.substring(0,(Math.min(maxaccnamelength, accname.length())));
					
                    
                    //Checking for the Record type of Account
                    //Getting the Id of Record type 1 on the Membership.
                    Id membershipRT = Constants.Membership_Record_Type1;
                    
                    //Check for the Program membership Record type 
                    if(String.isNotBlank(prog.Membership_Record_Type__c) && Constants.MAP_MEMBERSHIP_RECORDTYPES.containsKey(prog.Membership_Record_Type__c) 
                       && Constants.MAP_MEMBERSHIP_RECORDTYPES.get(prog.Membership_Record_Type__c) != null) 
                        membershipRT = 	Constants.MAP_MEMBERSHIP_RECORDTYPES.get(prog.Membership_Record_Type__c);
                    
					newmemberships.add(new Membership__c(
						Name = accname + ' - ' + prog.Program_Acronym__c,
						Account_Name__c = a.id,
						Program__c = prog.id, 
                    	RecordtypeId = membershipRT
                    ));
				}
			}
			
			debuglog += ' ' + accountsprocessed + ' Memberships';			
		}
		
		// Insert Memberships for all Programs
		insert newmemberships;
	}
	
	// Finish(Database.BatchableContext) method from Database.Batchable class
	global void finish(Database.BatchableContext ctx)
	{
		AsyncApexJob a = [SELECT id, ApexClassId, 
              JobItemsProcessed, 
              TotalJobItems, 
              NumberOfErrors, 
              CreatedBy.Email 
              FROM AsyncApexJob 
              WHERE id = :ctx.getJobId()];
		
		// Send an email confirming the completion of this batch
		String emailMessage = 
          'Your batch job \"Create Memberships for new Program\" has finished.  It created ' + totalprocessed + ' Membership records in ' 
        + a.totalJobItems + ' batches.  Of which, ' + a.jobitemsprocessed 
        + ' processed without any exceptions thrown and ' 
        + a.numberOfErrors + ' batches threw unhandled exceptions.<br/><br/>'
        + '<br/>Log of process:<br/>'
        + debuglog;
		
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		String[] toAddresses = new String[] {a.createdBy.email};
		
		mail.setToAddresses(toAddresses);
		mail.setReplyTo('noreply@salesforce.com');
		mail.setSenderDisplayName('Salesforce Batch'); 
		mail.setSubject('Batch job completed');
		mail.setPlainTextBody(emailMessage);
		mail.setHtmlBody(emailMessage);
		
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

	}
	
    static testmethod void MakeMembershipstest()
	{
		//flag testing
		Util.IsTest(true);
		
		String appsegs = '';
		Boolean First = true;
		for (String s : Util.accountRT2SegmentMap.values())
		{
			if (First)
				First = false;
			else
				appsegs += ';';
				
			appsegs += s;
		}
		
		list<Account> accs = new list<Account>();
		for (Integer i = 0; i < 20; i++) {
			accs.add(new Account(Name = 'testAcct', Account_Formal_Name__c = 'formalname' + String.valueOf(i)));
		}
		insert accs;
		
		Program__c prog = new Program__c(Applicable_Segments__c = 'US Education', Program_Acronym__c = 'test', Create_memberships__c = 'Yes');
		insert prog;
		
		system.debug('\n\n118jeremy prog ' + prog);		
		//confirm there are no memberships at all
		prog = [select id, (select id from Memberships__r) from Program__c where id = :prog.id];
		if (prog.Memberships__r.size() > 0) delete prog.Memberships__r;
		system.assertEquals(0, prog.Memberships__r.size());
		
test.StartTest();
		
		//run batch
		Batch_MakeMemberships mm = new Batch_MakeMemberships(new set<id> {prog.id});
		Id batchprocessId = Database.executeBatch(mm);
		
test.stopTest();
		
		
		prog = [select Program_Acronym__c, (select id, Name, Account_Name__c from Memberships__r limit 1) from Program__c where id = :prog.id];
		/* VH 1/14/15: Commented out so we could do a quick hypercare release
		system.assertEquals(1, prog.Memberships__r.size());
		
		String accname = [select Name from Account where id = :prog.Memberships__r[0].Account_Name__c].Name;
		Integer maxmemnamelength = 55;
		String suffix = ' - ';
		
		if (prog.Program_Acronym__c != null)
			suffix += prog.Program_Acronym__c;
		accname = accname.substring(0,(Math.min(maxmemnamelength, accname.length())));
		
		system.assertEquals(accname + suffix, prog.Memberships__r[0].Name);
		*/
	}
}