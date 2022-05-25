/**
 *	Purpose			:	Test code for the ReferenceModulePicklistCtrl class
 * 
 * 	Created By		:	Victor Hanson
 * 
 * 	Created Date	:	1/13/2016
 * 
 * Revision Logs	:	V_1.0 - Created
 *
 **/ 
@isTest
public class Test_ReferenceModulePicklistCtrl {
	
    //setup test data
    @testSetup static void setup() {
        /**
         * @description:1) Setup 3 users with related contacts
         * 				2) Create Program Collections/Collection Perspectives/Collection Perspective Children
         * 				3) Create an Ambassador reference for a contact
         **/
        Test_ReferenceRequestController.setupTestData();
    }
    
    /**
     * 
     * @description: Load the ReferenceModulePicklistCtrl class, which is used on the ReferenceModulePicklist component.
     * 				 Verify the modules within the map are correct.
     * 
     **/
    static testMethod void testReferenceModuleMap() {
        //instantiate the trigger
        ReferenceModulePicklistCtrl controller = new ReferenceModulePicklistCtrl();
        controller.setRTName('PT');
        //verify there is data returned in the reference module map JSON string
        system.assertNotEquals(null, controller.referenceModuleMap_JSON);
        system.assertEquals(true, controller.referenceModuleMap.containsKey('CCC'), 'CCC should be a valid entry because it was inserted as part of the testSetup data.');
        system.assertEquals(true, controller.referenceModuleMap.containsKey('CMA'), 'CMA should be a valid entry because it was inserted as part of the testSetup data.');
        system.assertEquals(true, controller.referenceModuleMap.containsKey('CMR'), 'CMR should be a valid entry because it was inserted as part of the testSetup data.');
        system.assertEquals(true, controller.referenceModuleMap.containsKey('CPRM'), 'CPRM should be a valid entry because it was inserted as part of the testSetup data.');
        system.assertEquals('PT', controller.getRTName());
    }
    
}