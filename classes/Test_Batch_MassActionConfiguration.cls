/**
 *  Purpose         :   Class is used to test the Functionality Batch_MassActionConfiguration
 *
 *  Created By      :   Saurabh Kumar
 *
 *  Created Date    :   11/20/2020
 *
 *  Revision Logs   :   V_1.0 - Created- CR-20201117-14698
 *                     
**/
@isTest(seeAllData=true)
public class Test_Batch_MassActionConfiguration {
	
    testmethod static void test_MyUnitTest() { 
    	
        Util.bypassAllTriggers = true;
		
	//create the master record
        Advisory_Event__c master = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_COHORT, null, true);
        
        dca_mass_action__Mass_Action_Configuration__c massActionConfig = new dca_mass_action__Mass_Action_Configuration__c();
        massActionConfig.dca_mass_action__Active__c = true;
        massActionConfig.dca_mass_action__Source_Report_Column_Name__c = 'Contact.Id';
        massActionConfig.dca_mass_action__Source_Report_ID__c = '00O0v000000cRKF';
        insert massActionConfig;
        
        // create a new campaign
        Campaign camp = new Campaign(Name = 'Test Campaign', IsActive = True);
        insert camp;
        
        Util.bypassAllTriggers = false;
        
        Test.startTest();
        
        //create the child record
        Advisory_Event__c child = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_BREAKOUT, null, false);
        child.Parent_Event__c = master.Id;
        child.Invite_List__c = camp.Id;
        child.Mass_Action_Configuration__c = massActionConfig.Id;
        insert child;
        
        for(dca_mass_action__Mass_Action_Configuration__c mac : [Select dca_mass_action__Target_Apex_Script__c From dca_mass_action__Mass_Action_Configuration__c Where Id =: massActionConfig.Id])
            System.assert(mac.dca_mass_action__Target_Apex_Script__c != null);
        
        Database.executeBatch(new Batch_MassActionConfiguration(),1);
        Test.stopTest();
        
        System.schedule('Scheduled MassActionConfiguration', '0 50 * * * ?', new Schedule_Batch_MassActionConfiguration());
    }

}