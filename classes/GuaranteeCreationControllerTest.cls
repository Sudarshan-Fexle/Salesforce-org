/**
 *  Purpose         :   Test Class for GuaranteeCreationController
 *  Created By      :   Lawrence Lam
 *  Created Date    :   5/24/2021
 *  Revision Logs   :   V_1.0 - Created  - CR-20210511-15135
 * 			V_1.1 - Modified By - Chirag Soni  -  08/19/2021 - CR-20210818-15367 - Recordtype label is changed from "Vendor or Venue" to "Event Venue"
 *  Test Class 	    :   GuaranteeCreationControllerTest                   
 **/
@isTest(seeAllData = false)
public class GuaranteeCreationControllerTest {
    @testSetup static void setupTestData(){
        //create EAB Event
        Advisory_Event__c testEvent = TestUtilities.createEvent(null,null,true);
        
        //create institution
        //Modified By - Chirag Soni  -  08/19/2021 - CR-20210818-15367 - Recordtype label is changed from "Vendor or Venue" to "Event Venue"
        Account testAcc = TestUtilities.CreateNewAccount('Event Venue', false);
        testAcc.Type = 'Hotel';
        testAcc.Accommodations__c = true;
        testAcc.Event_Venue__c = true;
        insert testAcc;
        
        //create venue
        Venue__c testVenue = new Venue__c();
        testVenue.Primary__c = true;
        testVenue.Venue__c = testAcc.Id;
        testVenue.Advisory_Event__c = testEvent.Id;
        insert testVenue;
        
    }
    
    @isTest static void testGetConfiguration(){
        Venue__c testVenue = [Select id from Venue__c limit 1];
        GuaranteeCreationController.GuaranteeWrapper wrapper = GuaranteeCreationController.getConfiguration(testVenue.id);
        
        System.assertNotEquals(null, wrapper, 'System did not return a wrapper based on venue id');
    }
    
    @isTest static void testSaveGuaranteeRecords(){
        Venue__c testVenue = [Select id from Venue__c limit 1];
        Advisory_Event__c testEvent = [Select id from Advisory_Event__c limit 1];
        //Guarantee__c testInsertion = new Guarantee__c (Date__c = Date.today(), Type__c = 'Dinner', Guarantee__c = 5);
        List<Guarantee__c> guaranteeList = new List<Guarantee__c>{new Guarantee__c (Date__c = Date.today(), Type__c = 'Dinner',
                                                                                    Guarantee__c = 5, EAB_Event__c= testEvent.id, Venues_and_Vendors__c = testVenue.Id)};
            
        String serializedList = JSON.serialize(guaranteeList);
        try{
            GuaranteeCreationController.saveGuaranteeRecords(serializedList);
        }catch(Exception e){
            system.debug(e.getMessage());
        }
        
        List<Guarantee__c> savedRecords = [Select id from Guarantee__c];
        
        system.assertEquals(1, savedRecords.size(), 'No saved Guarantees in the system, should have saved 1');
    }
    
    @isTest static void testWrapperCreation(){
        GuaranteeCreationController.GuaranteeWrapper testWrapper1 = new GuaranteeCreationController.GuaranteeWrapper();
        System.assertNotEquals(null, testWrapper1, 'Default wrapper creation did not return a wrapper');
        System.assertNotEquals(0, testWrapper1.typeValues.size());
        
    }
}