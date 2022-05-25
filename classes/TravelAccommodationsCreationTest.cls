/**
 *  Purpose         :  	Test Class for TravelAccommodationsCreationController
 *  Created By      :   
 *  Created Date    :   5/24/2021
 *  Revision Logs   :   V_1.0 - Created  - CR-20210511-15134
 *                     
 **/
@isTest(seeAllData = false)
public class TravelAccommodationsCreationTest {
    @testSetup static void setupTestData(){
        //create Registration
        util.bypassAllTriggers = true;
        
        //create a program
        Program__c p = TestUtilities.CreateNewProgram(true);
        
        //create meeting and registration
        Advisory_Event__c eabEvent = new Advisory_Event__c(Begins__c = system.now().addDays(30),
                                                           Ends__c = system.now().addDays(31),
                                                           Zoom_Meeting_ID__c = '111-1111-111',
                                                           Zoom_Type__c = 'Meeting');
        util.BypassAllTriggers = true;
        insert eabEvent;

        util.BypassAllTriggers = true;
        
        //create an account
        Account a = TestUtilities.CreateNewAccount(false);
        a.Time_Zone_Id__c = 'America/New_York';
        a.Time_Zone_Name__c = 'Eastern Timezone';
        insert a;
        
        //create contact
        Contact c = TestUtilities.CreateNewContact(a, true);
        
        //create registration
        Registration__c reg = new Registration__c(Contact__c = c.Id,
                                                  EAB_Event__c = eabEvent.Id,
                                                  Status__c = 'Registered',
                                                  Approval_Status__c = 'Approved',
                                                  Zoom_Participant_URL__c = 'https://www.google.com/',
                                                  Zoom_Registrant_ID__c = 'abc123abc123');
        insert reg;
        
    }
    
    @isTest static void testGetConfiguration(){
        Registration__c testReg = [Select id from Registration__c limit 1];
        List<TravelAccommodationsCreationController.AccommodationWrapper> wrapper = TravelAccommodationsCreationController.getAttendees(testReg.id);
        
        System.assertNotEquals(null, wrapper, 'System did not return a wrapper based on Registration id');
    }
    
    @isTest static void testGetExistingAccomodations(){
        Registration__c testReg = [Select id, Contact__c,EAB_Event__c from Registration__c limit 1];
        List<Travel_Accommodations__c> accomodationList = TravelAccommodationsCreationController.getExistingAccomodations(testReg.EAB_Event__c, 'Hotel');
        
        System.assertNotEquals(null, accomodationList, 'System did not return an empty list');
    }
    
    @isTest static void testSaveGuaranteeRecords(){
        Registration__c testReg = [Select id, Contact__c,EAB_Event__c from Registration__c limit 1];
        
        List<Travel_Accommodations__c> guaranteeList = new List<Travel_Accommodations__c>{new Travel_Accommodations__c (EAB_Event__c= testReg.EAB_Event__c, Registration__c = testReg.Id)};
        String serializedList = JSON.serialize(guaranteeList);
        try{
            TravelAccommodationsCreationController.saveAccommodationRecords(serializedList, 'Hotel');
        }catch(Exception e){
            system.debug(e.getMessage());
        }
        
        List<Travel_Accommodations__c> savedRecords = [Select id from Travel_Accommodations__c];
        
        system.assertEquals(1, savedRecords.size(), 'No saved Accommodations in the system, should have saved 1');
    }
    
    @isTest static void testWrapperCreation(){
        Test.startTest();
        
        //base constructor
        TravelAccommodationsCreationController.AccommodationWrapper testWrapper1 = new TravelAccommodationsCreationController.AccommodationWrapper();
        System.assertNotEquals(null, testWrapper1, 'Default wrapper creation did not return a wrapper');
		
        //registration constructor
        Registration__c testReg = [Select id from Registration__c limit 1];
        TravelAccommodationsCreationController.AccommodationWrapper testWrapper2 = new TravelAccommodationsCreationController.AccommodationWrapper(testReg);
        System.assertNotEquals(null, testWrapper2.registration, 'Registration Constructor wrapper creation did not return a wrapper with a Registration tied to it');
        
    }
}