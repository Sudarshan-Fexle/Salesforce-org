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
 **/
@isTest
private class Test_BatchUpdateMembershipOwnerAssociate 
{
   /**
    *	Purpose		:	Test class for Batch_UpdateMembershipOwnerAssociate
    *
    *	Create By	:	Bhavi Sharma
    *
    *	Created Date	:	06/14/2013
    *
    *	Current Version	:	v1.0
    *
    *	Revision Logs	:	V_1.0 - Created - CR-20130411-2851
    *			:	V_1.1 - Modified By - Nikita Kumari - 08/11/2021 - CR-20211005-15489 - Test class Fix (July)
    *
    *	Coverage	:	100%
    *
    **/
    static testMethod void myUnitTest() 
    {
        //Added by - Nikita Kumari - 08/11/2021 - CR-20211005-15489 - test class fix (july)
        Util.BypassAllTriggers = true;
        
        //Find user with Profile = System Adminsitrator
        Profile sysAdminProfile = [Select id from Profile where Name = 'System Administrator' limit 1];
        
        //Create user record
        User usr1 = new User(Alias = 'standt', Email='standarduser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                             LocaleSidKey='en_US', ProfileId = sysAdminProfile.Id, TimeZoneSidKey='America/Los_Angeles',UserName=Math.random()+'@testorg.com');
        
        insert usr1;
        
        //Create user record
        User usr2 = new User(Alias = 'standt', Email='test@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                             LocaleSidKey='en_US', ProfileId = sysAdminProfile.Id, TimeZoneSidKey='America/Los_Angeles',UserName=Math.random()+'@testorg.com', Associate__c = usr1.Id);
        
        insert usr2;
        
        //Create user record
        User usr3 = new User(Alias = 'standt', Email='test3@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                             LocaleSidKey='en_US', ProfileId = sysAdminProfile.Id, TimeZoneSidKey='America/Los_Angeles',UserName=Math.random()+'@testorg.com');
        
        insert usr3;
        
        //Insert new Account
        Account testAccount = testUtilities.CreateNewAccount(true);
        
        //Insert new Program
        Program__c testProgram = testUtilities.createNewProgram(true);
        
        //insert Membership record
        Membership__c membership = new Membership__c(Name = 'Test-Membership', OwnerId = usr2.Id, Account_Name__c = testAccount.Id, Program__c = testProgram.Id);
        insert membership;
        
        //update usr2
        usr2.Associate__c = usr3.Id;
        update usr2;
        
        Util.BypassAllTriggers = false;
        
        //Test starts here
        Test.startTest();
        
        //Added By  - Nikita Kumari - 08/11/2021 - CR-20211005-15489 - test class fix(july) - start
        Map<Id, User> mapUser = new Map<Id, User>();
        mapUser.put(usr2.Id,usr2);
        Batch_UpdateMembershipOwnerAssociate batchToUpdate = new Batch_UpdateMembershipOwnerAssociate(mapUser);
        Database.executeBatch(batchToUpdate);
        //Added By  - Nikita Kumari - 08/11/2021 - CR-20211005-15489 - test class fix(july) - end
        
        //test stop here
        Test.stopTest();
        
        //Query result of Membership
        membership = [SELECT Owner_Associate__c FROM Membership__c WHERE Id =: membership.Id];
        
        //assert statment
        System.assertEquals(usr3.Id, membership.Owner_Associate__c);
        
        //Added By  - Nikita Kumari - 08/11/2021 - CR-20211005-15489 - test class fix(july) - start
        List<AsyncApexJob> asyncApexJob = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob where JobType = 'BatchApex'];
        System.assertEquals('Batch_UpdateMembershipOwnerAssociate', asyncApexJob[0].ApexClass.Name);
        //Added By  - Nikita Kumari - 08/11/2021 - CR-20211005-15489 - test class fix(july) - end
    }
}