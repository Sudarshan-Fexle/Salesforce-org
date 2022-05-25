/**
*   Description     :   This Class is used to Test the functionality of 'Enqueue_CreateCMForPLContacts' class 

*   Created by      :   Dipesh Gupta
*
*   Created Date    :   
*
*   Revision Log    :   V1.0 - Created - Dipesh Gupta - CR-20190703-13207
*/
@isTest
public class Test_Enqueue_CreateCMForPLContacts {
    
    //test method 
    static testMethod void testCreateMembershipForContactTaggedInProductLead()
    {
        
        String progAcronym = 'EDAF';
        String progAcronym_BHAN = 'BHAN';
        
        //Create an Institution and Contact
        Account testAccount = TestUtilities.CreateNewAccount(true);
        Contact con = TestUtilities.CreateNewContact(true);
        
        //Create a new Program and set as Marketable to meet Lookup filter requirements
        List<Program__c> progs = new List<Program__c>();
        Program__c testProg = TestUtilities.CreateNewProgram(false);
        testProg.Program_Acronym__c = progAcronym;
        testProg.Marketable__c = true;
        progs.add(testProg);
        
        Program__c testProg_BHAN = TestUtilities.CreateNewProgram(false);
        testProg_BHAN.Program_Acronym__c = progAcronym_BHAN;
        testProg_BHAN.Marketable__c = true;
        progs.add(testProg_BHAN);
        insert progs;
        
        //create a new product lead
        Product_Lead__c pl_BHAN = new Product_Lead__c(Contact__c = con.Id,
                                                      Program__c = testProg_BHAN.Id,
                                                      Stage__c = 'Inquiry');
        insert pl_BHAN;
        
        system.assert(true, pl_BHAN.Id != null);
        
        Util.ByPassAllTriggers = true;
        
        Campaign cmp = new Campaign(Name = 'BHCNG_2019-11_CONNECTED', r_Submitted_by__c = con.Id);
        insert cmp;
        
        Util.ByPassAllTriggers = false;
        
        List<Campaign> cmpaigns = [Select Id, Name From Campaign where Id =: cmp.Id];
        //System.assert(false, cmpaigns[0].Name);
        
        test.startTest();
        
        Task tsk = new Task();
        tsk.subject = 'call';
        tsk.SalesLoft1__SalesLoft_Cadence_Name__c = 'BHCNG_2019-11_CONNECTED+Conference';
        tsk.whatId = pl_BHAN.Id;
        tsk.whoId = con.Id;
        
        Util.ByPassAllTriggers = true;
        insert tsk;
        
        system.assert(true, tsk != null);
        system.assertEquals(Schema.Product_Lead__c.SobjectType, tsk.whatId.getSObjectType());
        
        Set<Id> setOfTaskIds = new Set<Id>();
        setOfTaskIds.add(tsk.Id);
        
        System.enqueueJob(new Enqueue_CreateCMForPLContacts(setOfTaskIds));
        
        test.stopTest();
        
        List<CampaignMember> cmpMems = [SELECT Id FROM CampaignMember WHERE ContactId =:con.Id];
        system.assertEquals(true, cmpMems.size() == 1);  
    }
}