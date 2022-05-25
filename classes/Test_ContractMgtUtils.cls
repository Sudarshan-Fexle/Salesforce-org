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
private class Test_ContractMgtUtils {
	
	// get a map of all profiles where key = profile name, value = profile
	private static Map<String, Profile> NameToProfileMap {
		get {
			if (NameToProfileMap == null) {
				NameToProfileMap = new Map<String, Profile>();
				List<Profile> profiles = [SELECT Name, Id FROM Profile];
				for (Profile p : profiles) {
					NameToProfileMap.put(p.Name, p);
				}
			}
			return NameToProfileMap;
		}
		set;
	}
	
	static testMethod void testCheckUserPermissions_True() {
        Util.isTest(true);
        
        // get a profile that should have access to add vendors (accounts)
        Profile profile = NameToProfileMap.get('System Administrator');
        // create a new user with this profile and a specific employee Id
        User u = TestUtilities.CreateNewUser(profile, false);
        u.Employee_ID__c = '1231-1231-1231-1231';
        insert u;
        
        // create a new contact with this employee id
        Contact c = TestUtilities.CreateNewContact(false);
        c.Employee_ID__c = u.Employee_Id__c;
        c.Department_Description__c = 'IT Dept';
        insert c;
        
    	// check permissions for create a vendor
    	List<String> createVendorResponse = ContractMgtUtils.CheckUserPermissions(u.Employee_ID__c, ContractMgtUtils.CREATEVENDOR);
    	system.assertEquals('1', createVendorResponse[0]);
    	system.assertEquals(createVendorResponse[1], c.Id);
    	
    	// check permissions for create a Purchase Request
    	List<String> createPRResponse = ContractMgtUtils.CheckUserPermissions(u.Employee_ID__c, ContractMgtUtils.NEWPURCHASEREQUEST);
    	//system.assert(createPRResponse[0].equalsIgnoreCase('1'));
        //system.assertEquals(createVendorResponse[1], c.Id);
        //system.assertEquals(createVendorResponse[2], c.Department_Description__c);
    }
	
    static testMethod void testCheckUserPermissions_False() {
        Util.isTest(true);
        
        // get a profile that should not have access to add vendors (accounts)
        Profile profile = NameToProfileMap.get('Marketing Associates');
        // create a new user with this profile and a specific employee Id
        User u = TestUtilities.CreateNewUser(profile, false);
        u.Employee_ID__c = '1231-1231-1231-1231';
        insert u;
        
    	// check permissions for create a vendor
    	List<String> createVendorResponse = ContractMgtUtils.CheckUserPermissions(u.Employee_ID__c, ContractMgtUtils.CREATEVENDOR);
    	system.assertEquals('0', createVendorResponse[0]);
    	
    	// check permissions for create a Purchase Request
    	List<String> createPRResponse = ContractMgtUtils.CheckUserPermissions(u.Employee_ID__c, ContractMgtUtils.NEWPURCHASEREQUEST);
    	system.assertEquals('0', createPRResponse[0]);
        
    }
    
    static testMethod void testCheckUserPermissions_Error() {
        Util.isTest(true);
        
        // get a profile that should have access to add vendors (accounts)
        Profile profile = NameToProfileMap.get('System Administrator');
        // create a new user where isActive = false
        User u = TestUtilities.CreateNewUser(profile, false);
        u.Employee_ID__c = '1231-1231-1231-1231';
        u.IsActive = false;
        insert u;
        
    	// check permissions for create a vendor
    	List<String> createVendorResponse = ContractMgtUtils.CheckUserPermissions(u.Employee_ID__c, ContractMgtUtils.CREATEVENDOR);
    	system.assertEquals('no user found with employee id: 1231-1231-1231-1231', createVendorResponse[0].toLowerCase());
    	
    	// check permissions for create a Purchase Request
    	List<String> createPRResponse = ContractMgtUtils.CheckUserPermissions(u.Employee_ID__c, ContractMgtUtils.NEWPURCHASEREQUEST);
    	system.assertEquals('no user found with employee id: 1231-1231-1231-1231', createPRResponse[0].toLowerCase());
        
    }
    
    
}