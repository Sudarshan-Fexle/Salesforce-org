/**
 *   Purpose         :     Test class for ContactCompExtension
 *
 *   Revision Log    :     V_1.0 - 10/17/2019 - Victor Hanson - Added test methods
 * 			   V_1.1 - 10/20/2021 - Subhash - CR-20211012-15511
**/
@isTest
private class Test_ContactCompExtension {
	
    @testSetup static void setup() {
        //set trigger bypass
        util.bypassAllTriggers = true;
        
        //create an institution
        Account acct = TestUtilities.CreateNewAccount(true);
        Account acct2 = TestUtilities.CreateNewAccount(true);
        //Contact con = TestUtilities.CreateAdvUserContact(acct, true);
        //create some contacts with Site Profiles
        List<Site_Profile__c> sProfiles = new List<Site_profile__c>();
        for (integer i = 0; i < 5; i++)
        	sProfiles.add(TestUtilities.createSiteProfile(acct, false));
        insert sProfiles;
        
        //get a contact from the institution
        List<Contact> cons = [SELECT Id FROM Contact ];
        //system.assertEquals(1, cons.size());
        
        //create assignment role and institution role
        Team_Role__c assignRole = new Team_Role__c(Name= 'Role' , Business_Owner__c = cons[0].id, Entity__c = 'EAB',Institution_Role_External__c = true);
        insert assignRole;
        
        Institution_Roles__c  instRole = new Institution_Roles__c(Assignment_Role__c = assignRole.id, Institution__c = acct.Id, Contact__c = cons[0].Id);
        insert instRole;
        
        //create assignment role and institution role
        Team_Role__c assignRole2 = new Team_Role__c(Name= 'Role 2' , Business_Owner__c = cons[1].id, Entity__c = 'EAB',Institution_Role_External__c = true);
        insert assignRole2;
        
        Institution_Roles__c  instRole2 = new Institution_Roles__c(Assignment_Role__c = assignRole.id, Institution__c = acct2.Id, Contact__c = cons[1].Id);
        insert instRole2;
        
        //un-bypass triggers
        util.bypassAllTriggers = false;
    }
    
    
    /**
     * @description: test the various contact component extension methods
     **/
    static testmethod void getData() {
        //get the Institution that was created in test setup
        List<Account> accts = [SELECT Id FROM Account];
        //Updated method by Subhash - CR-20211012-15511
        List<Contact> con = [SELECT Id, Name, Title, EAB_com_Site_Profile__c, EAB_com_Site_Profile__r.Last_Access__c, Phone,
                                  (SELECT Id, Assignment_Role__r.Name FROM Institution_Roles__r ),
                                  (SELECT Id FROM Product_Lead_Stages__r ),
                                  (SELECT Id FROM Opportunities__r WHERE IsClosed = false AND RecordTypeId != :CPQConstants.OPP_RT_ID_MERGED)
                                  FROM Contact ];
        List<Id> accIds = new List<Id>();
        for(Account acc : accts)
            accIds.add(acc.Id);
        
        List<ContactCompExtension.contactWrapper> cWrappers = ContactCompExtension.getData(accIds);
        ContactCompExtension.ContactSortWrapper contSorWrap = new ContactCompExtension.ContactSortWrapper(con[0]);
        ContactCompExtension.ContactSortWrapper contSorWrap2 = new ContactCompExtension.ContactSortWrapper(con[1]);
        contSorWrap.compareTo(contSorWrap2);
        system.assertNotEquals(0, cWrappers.size());
    }
    
    
    /**
     * @description: test the various contact component extension methods
     **/
    static testmethod void getContactList() {
        //get the Institution that was created in test setup
        List<Account> accts = [SELECT Id FROM Account LIMIT 1];
        
        List<Contact> contacts = ContactCompExtension.getContactList(new List<Id> { accts[0].Id });
        system.assertEquals(2, contacts.size());
    }
    
    
}