/*
    Purpose:        Utility methods needed for contract management (CR-2083)
                    
    Created By:     Victor Hanson
    
    Created Date:   09/15/13
    
    Revision Log:   v1.0 - Created
*/
Global without sharing class ContractMgtUtils {
	
	// constants that will be used to determine which type of record is attempting to be created
	public final static String CREATEVENDOR = 'CreateVendor';
	public final static String NEWPURCHASEREQUEST = 'NewPurchaseRequest';
	
	// verify that the user has the required permissions
	// @param actDirID - Active Directory ID
	// @param commandName - Valid values are CreateVendor or NewPurchaseRequest
	webService static List<String> CheckUserPermissions(String actDirID, String commandName) {
		List<String> response = new List<String>();
		if (actDirID == null) {
			response.add('No active User found with Employee ID: ' + actDirID);
			return response;
		}
		try {
			List<User> users = [SELECT Id, ProfileID, Name FROM User WHERE Employee_Id__c = :actDirID and IsActive = true LIMIT 1];
			if (users.size() == 0) {
				response.add('No User found with Employee ID: ' + ActDirId);
				return response;
			}
			
			// set of all unique permission set ids
			Set<Id> permSetIdSet = new Set<Id>();
			// get permission set assignments for one-off permission sets
			List<PermissionSetAssignment> psAssignments = [SELECT AssigneeId, PermissionSetId 
														   FROM PermissionSetAssignment 
														   WHERE AssigneeId = :users[0].Id];
			for (PermissionSetAssignment psa : psAssignments) permSetIdSet.add(psa.PermissionSetId);
			//get all profile permissions
			map<Id, PermissionSet> profPermissionSets = new map<Id, PermissionSet>([select id from permissionset where PermissionSet.ProfileId = :users[0].ProfileId]);
			permSetIdSet.addAll(profPermissionSets.keySet());
			
			// get the user's object level permissions
			Id profileId = users[0].ProfileId;
			String permissionQuery = 'SELECT Id, SObjectType, PermissionsRead, PermissionsCreate ' +
									 'FROM ObjectPermissions ' +
									 'WHERE parentId IN :permSetIdSet ';
			if (commandName == null) {
				response.add('invalid commandName: null');
				return response;
			}
			if (commandName.equalsIgnoreCase(CREATEVENDOR))
				permissionQuery += ' AND sObjectType = \'Account\' AND PermissionsCreate = true';
			else if (commandName.equalsIgnoreCase(NEWPURCHASEREQUEST))
				permissionQuery += ' AND sObjectType = \'Purchase_Request__c\' AND PermissionsCreate = true';
			else {
				response.add('Invalid commandName: ' + commandName);
				return response;
			}
			
			// query for object permissions for this user's profile
			List<ObjectPermissions> op = database.query(permissionQuery);
			
			// 0=false, 1=true - we use this because PHP has issues with True/Fals Strings instead of booleans
			if (op.size() > 0) {
				if (op[0].PermissionsCreate) {
					// get the contact
					List<Contact> contacts = [SELECT Id, Department_Description__c FROM Contact WHERE Employee_Id__c = :actDirID LIMIT 1];
					if (contacts.size() == 0) {
						response.add('0');
						response.add('No Contact found with Employee Id:' + actDirID);
						return response;
					}
					response.add('1');
					// return the contact associated with the user because 
					response.add(contacts[0].Id);
					response.add(contacts[0].Department_Description__c);
				}
				else {
					response.add('0');
				}
			}
			else {
				response.add('0');
			}
		}
		catch(exception ex) {
			response.add('Error: ' + ex.getMessage() + '  Stack Trace:' + ex.getStackTraceString());
			return response;
		}
		
		return response;
	}
	
}