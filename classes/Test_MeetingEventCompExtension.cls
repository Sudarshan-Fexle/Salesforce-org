/**
 *   Purpose         :     Test class for MeetingEventCompExtension
 *
 *   Revision Log    :     V_1.0 - 10/17/2019 - Victor Hanson - Added test methods
**/
@isTest
private class Test_MeetingEventCompExtension {
	
    @testSetup static void setup() {
        
        //set trigger bypass
        util.bypassAllTriggers = true;
        
        //create an institution
        Account acct = TestUtilities.CreateNewAccount(true);
        
        //create a contact
        Contact con = TestUtilities.CreateNewContact(acct, true);
        
        // insert 2 meeting utilizations
        Meeting_Utilization__c mUtilization_future = new Meeting_Utilization__c(Start_Date__c = system.today().addDays(2),
                                                                                End_Date__c = system.today().addDays(3),
                                                                                Status__c = 'Confirmed',
                                                                                EventID__c = '1111-1111-1111-1111',
                                                                                ABC_Contact__c = con.Id);
        Meeting_Utilization__c mUtilization_past = new Meeting_Utilization__c(Start_Date__c = system.today().addDays(-4),
                                                                                End_Date__c = system.today().addDays(-5),
                                                                                Status__c = 'Attended',
                                                                                EventID__c = '2222-2222-2222-2222',
                                                                                ABC_Contact__c = con.Id);
        List<Meeting_Utilization__c> utilzationsToInsert = new List<Meeting_Utilization__c> { mUtilization_future, mUtilization_past };
        insert utilzationsToInsert;
        
    }
    
    
    /**
     * @description: test the various contact component extension methods
     **/
    static testmethod void testGetMeetingRegistrations() {
        //get the Institution that was created in test setup
        List<Account> accts = [SELECT Id FROM Account LIMIT 1];
        
        //get the meetings created in test setup
        List<AggregateResult> aggr = MeetingEventCompExtension.getMeetingRegistrations(new List<Id> { accts[0].Id });
        system.assertNotEquals(1, aggr.size());
    }
    
    
    /**
     * @description: test the various contact component extension methods
     **/
    static testmethod void testGetAggregate() {
        //get the Institution that was created in test setup
        List<Account> accts = [SELECT Id FROM Account LIMIT 1];
        
        //get the meetings created in test setup
        List<AggregateResult> aggr = MeetingEventCompExtension.getAggregate('Meeting_Utilization__c', 'Start_Date__c', 'Institution__c', accts[0].Id);
        system.assertNotEquals(2, aggr.size());
    }
    
    
}