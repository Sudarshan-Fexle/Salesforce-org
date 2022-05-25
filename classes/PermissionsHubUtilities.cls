/**
 *   Purpose      	:    
 *
 *   Created By      	:	Colin McGloin - CR-20220211-15910 - 02/11/2022
 *	
 *   Created Date    	:	02/11/2022
 *
 *   Current Version    :	V1.0
 *
 *   Revision Log    	:    	V1.0
 *
 **/            		  	
global with sharing class PermissionsHubUtilities {

  @AuraEnabled(cacheable=true)
  public static List<managedPackageLicenceWrapper> getUnusedManagedPackageLicenses() {
    //Get our Managed Package License count
    List<PackageLicense> packageLicenses = [
      SELECT AllowedLicenses, NamespacePrefix, UsedLicenses
      FROM PackageLicense
      WHERE UsedLicenses > 0
    ];

    //List of wrapper records to return
    List<managedPackageLicenceWrapper> licenseWrappers = new List<managedPackageLicenceWrapper>();

    //Once we have the records then let's work with them
    if (packageLicenses.size() > 0) {
      //Map used to bring back Managed Package Name for
      Map<String, Managed_Package_Names__mdt> mapNameSpaceToPackageName = new Map<String, Managed_Package_Names__mdt>();

      //Set for querying for our Users
      Set<Id> packageIds = new Set<Id>();

      //Map for linking the number of Inactive Assigned Users to the Package
      Map<Id, Integer> mapPackageIdToInactiveUsers = new Map<Id, Integer>();

      //Get our Managed Package Name values
      List<Managed_Package_Names__mdt> managedPackageNames = [SELECT Id, Namespace_Prefix__c, Managed_Package_Name__c, Package_ID__c, User_Package_License_ID__c FROM Managed_Package_Names__mdt];

      //Loop through and Populate Map
      for (Managed_Package_Names__mdt mpn : managedPackageNames) {

        //Add Id to the Set
        if (mpn.Package_ID__c != null){
          packageIds.add(Id.valueof(mpn.User_Package_License_ID__c));
        }

        if (mapNameSpaceToPackageName.get(mpn.Namespace_Prefix__c) == null) {
          mapNameSpaceToPackageName.put(mpn.Namespace_Prefix__c, mpn);
        }
      }

      //Get our Users
      if (packageIds.size() > 0){

        //Query to get all the Users associated with the Packages
        List<UserPackageLicense> packageUsers = [SELECT Id, UserId, PackageLicenseId FROM UserPackageLicense WHERE UserId IN (SELECT Id FROM User WHERE IsActive = FALSE) AND PackageLicenseId = :packageIds];

        //Loop through records
        if (packageUsers.size() > 0){

          for (UserPackageLicense uPackage : packageUsers){

            //Add values to Map
            if (mapPackageIdToInactiveUsers.get(uPackage.PackageLicenseId) != null){
              Integer count = mapPackageIdToInactiveUsers.get(uPackage.PackageLicenseId);
              count++;
              mapPackageIdToInactiveUsers.put(uPackage.PackageLicenseId, count);
            } else {
              Integer count = 1;
              mapPackageIdToInactiveUsers.put(uPackage.PackageLicenseId, count);
            }

          }

        }

      }

      //Loop through records
      for (PackageLicense pL : packageLicenses) {

        //Get our Metadata Record
        Managed_Package_Names__mdt packageMetadata = mapNameSpaceToPackageName.get(pL.NamespacePrefix);
        String managedPackageURL;
        String mpName;

        //Get our Managed Package Name
        if (packageMetadata == null || packageMetadata.Managed_Package_Name__c == null){
          mpName = 'Need to Add a Managed Package Metadata Record for this Managed Package';
        } else {
          mpName = packageMetadata.Managed_Package_Name__c;
        }

        //Get the correct Icon
        String iconName = (pL.AllowedLicenses - pL.UsedLicenses) > 0 ? 'action:approval' : 'action:close';

        //Create our Wrapper
        managedPackageLicenceWrapper mpw = new managedPackageLicenceWrapper(mpName, pL.AllowedLicenses, pL.UsedLicenses, pL.Id, iconName);

        //Set out Inactive Users
        if (mapPackageIdToInactiveUsers.get(pL.Id) != null){
          mpw.inactiveUsers = mapPackageIdToInactiveUsers.get(pL.Id);
        }

        //Build our Package Hyperlink String
        if (packageMetadata != null){
          if (packageMetadata.Package_ID__c != null && packageMetadata.User_Package_License_ID__c != null) {

            //Build our Hyperlink String
            managedPackageURL = URL.getSalesforceBaseUrl().toExternalForm();
            managedPackageURL += '/lightning/setup/Package/';
            managedPackageURL += packageMetadata.Package_ID__c;
            managedPackageURL += '/UserLicenses/';
            managedPackageURL += packageMetadata.User_Package_License_ID__c;
            managedPackageURL += '/view';
            mpw.managedPackageURL = managedPackageURL;
          }
        } else {
          mpw.managedPackageURL = 'Need to Add a Managed Package Metadata Record for this Managed Package';
        }
        

        //Put our Wrapper in the list
        licenseWrappers.add(mpw);
      }
    }

    return licenseWrappers;
  }

  @auraEnabled
  public static List<User> getPackageUsers (String packageId){

    List<User> ourUsers = [SELECT Id, Name, Department, Profile.Name, UserRole.Name FROM User WHERE Id IN (SELECT UserId FROM UserPackageLicense WHERE PackageLicenseId = :packageId)];

    return ourUsers;
  }

  global static void sendEmailToStakeholders(
    List<managedPackageLicenceWrapper> packagesForEmails
  ) {
    //Loop through and send the email to the various stakeholders
    for (managedPackageLicenceWrapper managedPackage : packagesForEmails) {
      //Build out Email Template String
      String emailCopy =
        'We are running low on licenses for the Managed Package: ' +
        '<b>' +
        managedPackage.ManagedPackageName +
        '</b>' +
        '<br><br>';
      emailCopy +=
        '<b>Allowed Licenses: </b>' +
        managedPackage.allowedLicenses +
        '<br><br>';
      emailCopy +=
        '<b>Used Licenses: </b>' +
        managedPackage.usedLicenses +
        '<br><br>';

      //start building the email message
      Messaging.Singleemailmessage email = new Messaging.Singleemailmessage();
      email.setHtmlBody(emailCopy);
      email.setSubject(
        'Managed Package License Alert: ' + managedPackage.ManagedPackageName
      );
      email.setReplyTo('noreply@salesforce.com');
      email.setSenderDisplayName('Mananged Package License Alert');

      //Loop through and get our Email Addresses
      List<String> emailAddresses = managedPackage.emailAddresses.split(';');
      email.setToAddresses(emailAddresses);

      //Send our email
      Messaging.sendEmail(new List<Messaging.SingleEmailmessage>{ email });
    }
  }

  @AuraEnabled
  public static Map<Id, List<permissionsOutputWrapper>> getUserPermissionsInformation(String originalUserString, String newUserString) {

    //Convert Ids from String to ID
    Id originalUserId = Id.valueOf(originalUserString);
    Id newUserID = Id.valueOf(newUserString);

    //List for all our Outputs
    Map<Id, List<permissionsOutputWrapper>> mapUserToOutputs = new Map<Id, List<permissionsOutputWrapper>>();

    //Query for User Records
    List<User> ourUsers = [
      SELECT Id, Name, ProfileId, Profile.Name, Profile.Description, UserRoleId, UserRole.Name
      FROM User
      WHERE Id = :originalUserId OR ID = :newUserId
    ];

    Integer userCounter = 0;

    //If there are no Users, then present error and return that
    for (User u : ourUsers) {

      if (mapUserToOutputs.get(u.Id) != null){
        //duplicate Id - present error
      } else {

        //Create new List of Permission Output Wrappers
        List<permissionsOutputWrapper> userPermissions = new List<permissionsOutputWrapper>();
        permissionsOutputWrapper profile = new permissionsOutputWrapper(u.Profile.Name, Constants.PERMISSIONS_HUB_OUTPUT_TYPE_PROFILE, u.ProfileId, u.Id, 0, u.Profile.Description);
        profile.originalId = ('Profile' + userCounter);
        if (u.Profile.Description != null){
          profile.displayDescription = true;
        }
        userPermissions.add(profile);
        permissionsOutputWrapper role = new permissionsOutputWrapper(u.UserRole.Name, Constants.PERMISSIONS_HUB_OUTPUT_TYPE_ROLE, u.UserRoleId, u.Id, 0, null);
        role.originalId = ('Role' + userCounter);
        userPermissions.add(role);

        //Add our User Id and start of our Outputs
        mapUserToOutputs.put(u.Id, userPermissions);

        //Increment counter
        userCounter++;
      }
    }

    //Query for Permission Sets
    List<PermissionSetAssignment> assignedPermissionSets = [
      SELECT Id, AssigneeId, PermissionSetId, PermissionSet.Label, PermissionSet.Description, PermissionSetGroupId, PermissionSetGroup.MasterLabel
      FROM PermissionSetAssignment
      WHERE AssigneeId = :ourUsers
      AND PermissionSet.IsOwnedByProfile = FALSE
      ORDER BY PermissionSet.Label ASC
    ];

    //Scenarios
    //1 - No values returned for either user
    //2 - same values returned for both users
    //3 - different values returned for both users

    //Check for values
    if (assignedPermissionSets.size() > 0){

      //Create a Map of permissionsOutputWrapper for linking to each user
      Map<Id, Map<String, permissionsOutputWrapper>> mapUserIdToMapPSA = new Map <Id, Map<String, permissionsOutputWrapper>>();

      //Set of our Permission Set Group Ids
      Set<Id> permissionSetGroupIds = new Set<Id>();

      //Map which stores our PermissionSetGroup Id and the associated Permission Sets
      Map<Id, List<PermissionSetGroupComponent>> mapPermSetGroupToPermSets = new Map<Id, List<PermissionSetGroupComponent>>();

      //Put the User IDs in from our initial list
      for (User u : ourUsers){
        mapUserIdToMapPSA.put(u.Id, new Map<String, permissionsOutputWrapper>());
      }

      //Loop through PSA and get any PermissionSetGroupIds
      for (PermissionSetAssignment psAGroup : assignedPermissionSets){

        //Check to see if the Group Id is populated
        if (psAGroup.PermissionSetGroupId != null){

          permissionSetGroupIds.add(psAGroup.PermissionSetGroupId);

        }
      }

      //Query for any Permission Set Group Components
      if (permissionSetGroupIds.size() > 0){

        //Query to get our Permission Set Groups and Components
        List <PermissionSetGroup> permSetGroups = [SELECT Id, Masterlabel, (SELECT Id, PermissionSetId, PermissionSet.Label, PermissionSet.Description FROM PermissionSetGroupComponents) FROM PermissionSetGroup WHERE Id IN :permissionSetGroupIds];

        //Loop through our Groups
        for (PermissionSetGroup pGroup : permSetGroups){

          //Add to our Map
          if (mapPermSetGroupToPermSets.get(pGroup.Id) == null){
            mapPermSetGroupToPermSets.put(pGroup.Id, pGroup.PermissionSetGroupComponents);
          }

        }

      }

      //Counter for Comparison
      Integer counter = 1;

      //Loop through our Permissio Set Assignments
      for (PermissionSetAssignment psA : assignedPermissionSets){
      
        //Return List of Permission Sets so far
        Map<String, permissionsOutputWrapper> userPermSetMap = mapUserIdToMapPSA.get(psa.AssigneeId);

        //Check to see if it exists already and just update blank record to show Permission Set Name
        if (userPermSetMap.get(String.valueOf(psA.PermissionSetId)) != null){
          permissionsOutputWrapper outputWrapper = userPermSetMap.get(String.valueOf(psA.PermissionSetId));
          outputWrapper.hideRow = false;
          outputWrapper.displayColor = 'Green';
          outputWrapper.originalId = String.valueOf(psa.Id);

          //Check to see if it's a Permission Set Group Id
          if (psa.PermissionSetGroupId != null){
            //Get the Child Components
            List<PermissionSetGroupComponent> childPermSets = mapPermSetGroupToPermSets.get(psa.PermissionSetGroupId);

            //Loop through and update the Output Components to be visibile
            if (childPermSets.size() > 0){
              for (PermissionSetGroupComponent childComp : childPermSets){
                //Create Unique String for getting Child Components
                String uniqueId = childComp.PermissionSetId + '-' + psa.AssigneeId;
                if (userPermSetMap.get(uniqueId) != null){
                  permissionsOutputWrapper childWrapper = userPermSetMap.get(uniqueId);
                  childWrapper.hideRow = false;
                  userPermSetMap.put(uniqueId, childWrapper);
                }
              }
            }
            
          }

          userPermSetMap.put(String.valueOf(psA.PermissionSetId), outputWrapper);
          PermissionsOutputWrapper childOutputWrapper = userPermSetMap.get('0PS2K000000W2M4WAK-005C0000003xesoIAA');
          mapUserIdToMapPSA.put(psa.AssigneeId,userPermSetMap);

        } else {

          //Get the User Id for the other user 
          Id otherUserId = psa.AssigneeId == originalUserId ? newUserId : originalUserId;

          //Create for the Assigned User
          permissionsOutputWrapper newOutputWrapper = new permissionsOutputWrapper(psA.PermissionSet.Label, Constants.PERMISSIONS_HUB_OUTPUT_TYPE_PERMISSION_SET, psA.PermissionSetId, psa.AssigneeId, counter, psa.PermissionSet.Description);
          newOutputWrapper.originalId = String.valueOf(psA.Id);

          if (psa.PermissionSet.Description != null){
            //Set our Output Variables needed for the table
            newOutputWrapper.displayDescription = true;
          }
          if (psa.PermissionSetGroupId != null){
            //Set our Output Variables needed for the table
            newOutputWrapper.outputUniqueId = psa.PermissionSetGroupId;
            newOutputWrapper.permissionSetGroupName = psa.PermissionSetGroup.MasterLabel;
            newOutputWrapper.displayPsStar = true;

            //Get our associated Permission Sets
            if (mapPermSetGroupToPermSets.get(psa.PermissionSetGroupId) != null){
              List<PermissionSetGroupComponent> childPermSets = mapPermSetGroupToPermSets.get(psa.PermissionSetGroupId);

              //Loop through Permission Sets
              for (PermissionSetGroupComponent pSet : childPermSets){

                //Add to our User Map
                if (userPermSetMap.get(String.valueOf(pSet.Id)) == null){

                  String uniqueOutputId = pSet.PermissionSetId + '-' + psa.AssigneeId;

                  //Create an ouput wrapper for the child
                  permissionsOutputWrapper childOutputWrapper = new permissionsOutputWrapper(pSet.PermissionSet.Label, Constants.PERMISSIONS_HUB_OUTPUT_TYPE_PERMISSION_SET, uniqueOutputId, psa.AssigneeId, counter, pSet.PermissionSet.Description);
                  if (pSet.PermissionSet.Description != null){
                    childOutputWrapper.displayDescription = true;
                  }
                  childOutputWrapper.parentPermissionSetGroupName = psa.PermissionSetGroup.MasterLabel;
                  childOutputWrapper.displayPSDescription = true;
                  childOutputWrapper.hideCheckbox = true;
                  userPermSetMap.put(uniqueOutputId, childOutputWrapper);
                }

                //Create a PS Group Specific ID for later if needed
                String uniqueOtherOutputId = pSet.PermissionSetId + '-' + otherUserId;

                //Get the Other User Map
                Map<String, permissionsOutputWrapper> otherUserMap = mapUserIdToMapPSA.get(otherUserId);
                if (otherUserMap.get(uniqueOtherOutputId) == null){
                  permissionsOutputWrapper childOutputDuplicateWrapper = new permissionsOutputWrapper(pSet.PermissionSet.Label, Constants.PERMISSIONS_HUB_OUTPUT_TYPE_PERMISSION_SET, uniqueOtherOutputId, otherUserId, counter, pSet.PermissionSet.Description);
                  childOutputDuplicateWrapper.hideRow = true;
                  childOutputDuplicateWrapper.hideCheckbox = true;
                  if (pSet.PermissionSet.Description != null){
                    childOutputDuplicateWrapper.displayDescription = true;
                  }
                  childOutputDuplicateWrapper.displayPSDescription = true;
                  childOutputDuplicateWrapper.parentPermissionSetGroupName = psa.PermissionSetGroup.MasterLabel;
                  otherUserMap.put(uniqueOtherOutputId, childOutputDuplicateWrapper);
                  mapUserIdToMapPSA.put(String.valueOf(otherUserId), otherUserMap);
                }
              }
            }
          }
          newOutputWrapper.displayColor = 'Green';
          userPermSetMap.put(String.valueOf(psA.PermissionSetId), newOutputWrapper);
          mapUserIdToMapPSA.put(psa.AssigneeId, userPermSetMap);

          //Create Duplicate 
          permissionsOutputWrapper duplicateOutputWrapper = new permissionsOutputWrapper(psA.PermissionSet.Label, Constants.PERMISSIONS_HUB_OUTPUT_TYPE_PERMISSION_SET, psA.PermissionSetId, otherUserId, counter, psa.PermissionSet.Description);
          duplicateOutputWrapper.hideRow = true;
          if (psa.PermissionSet.Description != null){
            //Set our Output Variables needed for the table
            duplicateOutputWrapper.displayDescription = true;
          }
          if (psa.PermissionSetGroupId != null){
            //Set our Output Variables needed for the table
            duplicateOutputWrapper.outputUniqueId = psa.PermissionSetGroupId;
            duplicateOutputWrapper.permissionSetGroupName = psa.PermissionSetGroup.MasterLabel;
            duplicateOutputWrapper.displayPsStar = true;
          }

          Map<String, permissionsOutputWrapper> otherUserMap = mapUserIdToMapPSA.get(String.valueOf(otherUserId));
          otherUserMap.put(psA.PermissionSetId, duplicateOutputWrapper);
          mapUserIdToMapPSA.put(String.valueOf(otherUserId), otherUserMap);

          //Add to the counter
          counter++;

        }

      }

      //Loop through Map and add them to our overall Map
      for (Id userId : mapUserIdToMapPSA.keyset()){

        //Get our new values
        Map<String, permissionsOutputWrapper> permSetToPSA = mapUserIdToMapPSA.get(String.valueOf(userId));
        //Get our existing values and add the new ones in
        List<permissionsOutputWrapper> existingValues = mapUserToOutputs.get(userId);
        if (existingValues.size() > 0){

          //Get our List of Permission Sets
          List<permissionsOutputWrapper> permSetValues = permSetToPSA.values();
          if (permSetValues.size() > 0){
            permSetValues.sort();
            Integer rowCounter = 0;
            for (permissionsOutputWrapper pWrapper : permSetValues){

              pWrapper.compareInteger = rowCounter;
              rowCounter++;

            }
          }
          
          //Add our sorted records to our User Map
          existingValues.addAll(permSetToPSA.values());
          mapUserToOutputs.put(userId, existingValues);
        }

      }

    }

    //Query for Package Licenses
    List<UserPackageLicense> assignedPackages = [
      SELECT Id, UserId, PackageLicenseId, PackageLicense.NamespacePrefix
      FROM UserPackageLicense
      WHERE UserId = :ourUsers
      ORDER BY PackageLicense.NamespacePrefix ASC
    ];

    //Check for values
    if (assignedPackages.size() > 0){

      //Map used to bring back Managed Package Name for
      Map<String, Managed_Package_Names__mdt> mapNameSpaceToPackageName = new Map<String, Managed_Package_Names__mdt>();

      //Get our Managed Package Name values
      List<Managed_Package_Names__mdt> managedPackageNames = [
        SELECT
          Id,
          Namespace_Prefix__c,
          Managed_Package_Name__c,
          Package_ID__c,
          User_Package_License_ID__c
        FROM Managed_Package_Names__mdt
      ];

      //Loop through and Populate Map
      for (Managed_Package_Names__mdt mpn : managedPackageNames) {
        if (mapNameSpaceToPackageName.get(mpn.Namespace_Prefix__c) == null) {
          mapNameSpaceToPackageName.put(mpn.Namespace_Prefix__c, mpn);
        }
      }

      //Create a Map of permissionsOutputWrapper for linking to each user
      Map<Id, Map<Id, permissionsOutputWrapper>> mapUserIdToMapPSA = new Map <Id, Map<Id, permissionsOutputWrapper>>();

      //Put the User IDs in from our initial list
      for (User u : ourUsers){
        mapUserIdToMapPSA.put(u.Id, new Map<Id, permissionsOutputWrapper>());
      }

      //Counter for Comparison
      Integer counter = 1;

      //Loop through our Assigned Packages
      for (UserPackageLicense upa : assignedPackages){

        //Check to see if the Package is one we care about or else continue
        if (mapNameSpaceToPackageName.get(upa.PackageLicense.NamespacePrefix) == null){
          continue;
        }
        
        //Return List of Permission Sets so far
        Map<Id, permissionsOutputWrapper> userPackageLicenseMap = mapUserIdToMapPSA.get(upa.UserId);

        //Check to see if it exists already and just update blank record to show Permission Set Name
        if (userPackageLicenseMap.get(upa.PackageLicenseId) != null){
          permissionsOutputWrapper outputWrapper = userPackageLicenseMap.get(upa.PackageLicenseId);
          outputWrapper.hideRow = false;
          outputWrapper.outputName = mapNameSpaceToPackageName.get(upa.PackageLicense.NamespacePrefix).Managed_Package_Name__c;
          outputWrapper.originalId = String.valueOf(upa.Id);
          userPackageLicenseMap.put(upa.PackageLicenseId, outputWrapper);
          mapUserIdToMapPSA.put(upa.UserId,userPackageLicenseMap);

        } else {

          //Get the User Id for the other user 
          Id otherUserId = upa.UserId == originalUserId ? newUserId : originalUserId;

          //Create for the Assigned User
          permissionsOutputWrapper newOutputWrapper = new permissionsOutputWrapper(mapNameSpaceToPackageName.get(upa.PackageLicense.NamespacePrefix).Managed_Package_Name__c, Constants.PERMISSIONS_HUB_OUTPUT_TYPE_LICENSE, upa.PackageLicenseId, upa.UserId, counter, null);
          newOutputWrapper.originalId = String.valueOf(upa.Id);
          userPackageLicenseMap.put(upa.PackageLicenseId, newOutputWrapper);
          mapUserIdToMapPSA.put(upa.UserId, userPackageLicenseMap);


          //Create Duplicate 
          permissionsOutputWrapper duplicateOutputWrapper = new permissionsOutputWrapper(' ', Constants.PERMISSIONS_HUB_OUTPUT_TYPE_LICENSE, upa.PackageLicenseId, otherUserId, counter, null);
          duplicateOutputWrapper.hideRow = true;
          Map<Id, permissionsOutputWrapper> otherUserMap = mapUserIdToMapPSA.get(otherUserId);
          otherUserMap.put(upa.PackageLicenseId, duplicateOutputWrapper);
          mapUserIdToMapPSA.put(otherUserId, otherUserMap);

          //Add to the counter
          counter++;

        }

      }

      //Loop through Map and add them to our overall Map
      for (Id userId : mapUserIdToMapPSA.keyset()){

        //Get our new values
        Map<Id, permissionsOutputWrapper> permSetToPSA = mapUserIdToMapPSA.get(userId);
        //Get our existing values and add the new ones in
        List<permissionsOutputWrapper> existingValues = mapUserToOutputs.get(userId);
        if (existingValues.size() > 0){
          existingValues.addAll(permSetToPSA.values());
          mapUserToOutputs.put(userId, existingValues);
        }

      }

    }

    //Group Types we need to display
    List<String> groupTypes = new List<String>{'Regular', 'Queue'};

    //Query for Public Groups and Queues
    List<GroupMember> assignedGroupsQueues = [
      SELECT GroupId, Id, UserOrGroupId, Group.Type, Group.Name
      FROM GroupMember
      WHERE UserOrGroupId = :ourUsers
      AND Group.Type = :groupTypes
      ORDER BY Group.Name ASC
    ];

    //Check for values
    if (assignedGroupsQueues.size() > 0){

      //Create a Map of permissionsOutputWrapper for linking to each user
      Map<Id, Map<Id, permissionsOutputWrapper>> mapUserIdToMapPSA = new Map <Id, Map<Id, permissionsOutputWrapper>>();

      //Put the User IDs in from our initial list
      for (User u : ourUsers){
        mapUserIdToMapPSA.put(u.Id, new Map<Id, permissionsOutputWrapper>());
      }

      //Counter for Comparison
      Integer counter = 0;

      //Loop through our Assigned Packages
      for (GroupMember groupMem : assignedGroupsQueues){
        
        //Return List of Permission Sets so far
        Map<Id, permissionsOutputWrapper> userGroupMap = mapUserIdToMapPSA.get(groupMem.UserOrGroupId);

        //Check to see if it exists already and just update blank record to show Permission Set Name
        if (userGroupMap.get(groupMem.GroupId) != null){
          permissionsOutputWrapper outputWrapper = userGroupMap.get(groupMem.GroupId);
          outputWrapper.outputName = groupMem.Group.Name;
          outputWrapper.hideRow = false;
          outputWrapper.originalId = String.valueOf(groupMem.Id);
          userGroupMap.put(groupMem.GroupId, outputWrapper);
          mapUserIdToMapPSA.put(groupMem.GroupId,userGroupMap);

        } else {

          //Get the User Id for the other user 
          Id otherUserId = groupMem.UserOrGroupId == originalUserId ? newUserId : originalUserId;
          
          //Converts the term Regular into Group for clarity on the UI
          String groupType = groupMem.Group.Type == 'Regular' ? Constants.PERMISSIONS_HUB_OUTPUT_TYPE_GROUP : Constants.PERMISSIONS_HUB_OUTPUT_TYPE_QUEUE;

          //Create for the Assigned User
          permissionsOutputWrapper newOutputWrapper = new permissionsOutputWrapper(groupMem.Group.Name, groupType, groupMem.GroupId, groupMem.UserOrGroupId, counter, null);
          newOutputWrapper.originalId = String.valueOf(groupMem.Id);
          userGroupMap.put(groupMem.GroupId, newOutputWrapper);
          mapUserIdToMapPSA.put(groupMem.UserOrGroupId, userGroupMap);


          //Create Duplicate 
          permissionsOutputWrapper duplicateOutputWrapper = new permissionsOutputWrapper(' ', groupType, groupMem.GroupId, otherUserId, counter, null);
          duplicateOutputWrapper.hideRow = true;
          Map<Id, permissionsOutputWrapper> otherUserMap = mapUserIdToMapPSA.get(otherUserId);
          otherUserMap.put(groupMem.GroupId, duplicateOutputWrapper);
          mapUserIdToMapPSA.put(otherUserId, otherUserMap);

          //Add to the counter
          counter++;

        }

      }

      //Loop through Map and add them to our overall Map
      for (Id userId : mapUserIdToMapPSA.keyset()){

        //Get our new values
        Map<Id, permissionsOutputWrapper> permSetToPSA = mapUserIdToMapPSA.get(userId);
        //Get our existing values and add the new ones in
        if (mapUserToOutputs.get(userId) != null){

          //Get our Existing Values
          List<permissionsOutputWrapper> existingValues = mapUserToOutputs.get(userId);
        
          if (existingValues.size() > 0){
          existingValues.addAll(permSetToPSA.values());
          mapUserToOutputs.put(userId, existingValues);
          }
        }

      }

    }

    return mapUserToOutputs;

  }

  @AuraEnabled
  public static void assignDeletePermissionRecords(Object data, String newUserStringValue, String command){

    //Get our Permission Wrappers
    List<permissionsOutputWrapper> perms = (List<permissionsOutputWrapper>) JSON.deSerialize( JSON.serialize(data) , List <permissionsOutputWrapper>.class);

    Id newUserID;

    if (perms.size() <= 0){
      
      //Add custom exception here
    }

    //Create our lists as needed
    List<PermissionSetAssignment> permissionSetsToBeProcessed = new List<PermissionSetAssignment>();
    Map<Id, User> mapUsersToUpdate = new Map<Id, User>();
    List<UserPackageLicense> packagesToProcess = new List<UserPackageLicense>();
    List<GroupMember> groupsAndQueuesToProcess = new List<GroupMember>();

    //Convert our String to Id
    if (command == Constants.PERMISSIONS_HUB_COMMAND_ASSIGN) {
      newUserID = Id.valueOf(newUserStringValue);
    }

    //Loop through our Permission Outputs and assign records
    for (permissionsOutputWrapper perm : perms){

      //Check for required field values
      if (perm.outputUniqueId != null && perm.outputType != null && perm.originalId != null){

        //Check for the outputType and make the appropriate record and assign to list
        switch on perm.outputType {
          when 'Permission Set' {

            if (command == Constants.PERMISSIONS_HUB_COMMAND_ASSIGN){

              //Check to see if the selected Assignment is a Permission Set or a Permission Set Group
              if (perm.permissionSetGroupName != null){

                //Create our PermissionSetAssignment records
                permissionSetsToBeProcessed.add(new PermissionSetAssignment(PermissionSetGroupId = perm.outputUniqueId, AssigneeId = newUserID));

              } else {

                //Create our PermissionSetAssignment records
                permissionSetsToBeProcessed.add(new PermissionSetAssignment(PermissionSetId = perm.outputUniqueId, AssigneeId = newUserID));

              }

            } else if (command == Constants.PERMISSIONS_HUB_COMMAND_REMOVE){

              //Create our PermissionSetAssignment records
              permissionSetsToBeProcessed.add(new PermissionSetAssignment(Id = Id.valueOf(perm.originalId)));

            }
  
          }	
          when 'Profile', 'Role' {

            if (command == Constants.PERMISSIONS_HUB_COMMAND_ASSIGN){
            
              //Check to see if User is already in Map
              if (mapUsersToUpdate.get(newUserID) != null){
                User u = mapUsersToUpdate.get(newUserID);
                if (perm.outputType == Constants.PERMISSIONS_HUB_OUTPUT_TYPE_PROFILE){
                  u.ProfileId = perm.outputUniqueId;
                } else {
                  u.UserRoleId = perm.outputUniqueId;
                }
                mapUsersToUpdate.put(u.Id, u);
              } else {
                User u = new User (Id = newUserID);
                if (perm.outputType == Constants.PERMISSIONS_HUB_OUTPUT_TYPE_PROFILE){
                  u.ProfileId = perm.outputUniqueId;
                } else {
                  u.UserRoleId = perm.outputUniqueId;
                }
                mapUsersToUpdate.put(newUserID, u);
              }
            }

            else if (command == Constants.PERMISSIONS_HUB_COMMAND_REMOVE){

              throw new DmlException('You cannot remove a Profile or Role since theses fields must always be populated on the User.');

            }

          }
          when 'License' {

            if (command == Constants.PERMISSIONS_HUB_COMMAND_ASSIGN){
            
            packagesToProcess.add(new UserPackageLicense(UserId = newUserID, PackageLicenseId = perm.outputUniqueId));

            } else if (command == Constants.PERMISSIONS_HUB_COMMAND_REMOVE){

              packagesToProcess.add(new UserPackageLicense(Id = Id.valueOf(perm.originalId)));

            }

          }
          when 'Group', 'Queue' {

            if (command == Constants.PERMISSIONS_HUB_COMMAND_ASSIGN){
          
              //Add User to Group or Queue
              groupsAndQueuesToProcess.add(new GroupMember(UserOrGroupId = newUserID, GroupId = perm.outputUniqueId));

            } else if (command == Constants.PERMISSIONS_HUB_COMMAND_REMOVE){

              groupsAndQueuesToProcess.add(new GroupMember(Id = Id.valueOf(perm.originalId)));

            }

          }
          when else {		  // default block, optional
              //Debug log
              System.debug('Hit Else Branch of Assign Switch');
            }
          }

        }
      }

      //Check our Lists and Insert as needed
      if (permissionSetsToBeProcessed.size() > 0){
        if (command == Constants.PERMISSIONS_HUB_COMMAND_ASSIGN ){
          try{
            insert permissionSetsToBeProcessed;
          } catch (System.Exception ex){
            throw new AuraHandledException(ex.getMessage());
          }
        } else if (command == Constants.PERMISSIONS_HUB_COMMAND_REMOVE){
          delete permissionSetsToBeProcessed;
        }
      }

      if (mapUsersToUpdate.values().size() > 0){
          List<User> updateUsers = mapUsersToUpdate.values();
          update updateUsers;
      }

      if (packagesToProcess.size() > 0){
        if (command == Constants.PERMISSIONS_HUB_COMMAND_ASSIGN ){
          insert packagesToProcess;
        } else if (command == Constants.PERMISSIONS_HUB_COMMAND_REMOVE){
          delete packagesToProcess;
        }
      }

      if (groupsAndQueuesToProcess.size() > 0){
        if (command == Constants.PERMISSIONS_HUB_COMMAND_ASSIGN ){
          insert groupsAndQueuesToProcess;
        } else if (command == Constants.PERMISSIONS_HUB_COMMAND_REMOVE){
          delete groupsAndQueuesToProcess;
        }
      }

  }

  global class managedPackageLicenceWrapper {
    @AuraEnabled
    public String ManagedPackageName { get; set; }
    @AuraEnabled
    public Integer allowedLicenses { get; set; }
    @AuraEnabled
    public Integer usedLicenses { get; set; }
    @AuraEnabled
    public String packageId { get; set; }
    @AuraEnabled
    public String iconName { get; set; }
    @AuraEnabled
    public String managedPackageURL { get; set; }
    @AuraEnabled
    public String emailAddresses { get; set; }
    @AuraEnabled
    public Integer inactiveUsers { get; set; }

    global managedPackageLicenceWrapper(
      String mpName,
      Integer allowedL,
      Integer usedL,
      String packageId,
      String iconName
    ) {
      this.ManagedPackageName = mpName;
      this.allowedLicenses = allowedL;
      this.usedLicenses = usedL;
      this.packageId = packageId;
      this.iconName = iconName;
      this.inactiveUsers = 0;
    }
  }

  global class permissionsOutputWrapper implements Comparable {

    @AuraEnabled 
    public String outputName { get; set; }
    @AuraEnabled 
    public String outputType { get; set; }
    @AuraEnabled 
    public String outputUniqueId { get; set; }
    @AuraEnabled 
    public Id userId { get; set; }
    @AuraEnabled 
    public Integer compareInteger { get; set; }
    @AuraEnabled 
    public String outputDescription { get; set; }
    @AuraEnabled 
    public Boolean displayDescription { get; set; }
    @AuraEnabled 
    public String permissionSetGroupName { get; set; }
    @AuraEnabled 
    public String parentPermissionSetGroupName { get; set; }
    @AuraEnabled 
    public Boolean displayPSDescription { get; set; }
    @AuraEnabled 
    public String displayColor { get; set; }
    @AuraEnabled
    public Boolean displayPsStar { get; set; }
    @AuraEnabled 
    public Boolean hideRow { get; set; }
    @AuraEnabled 
    public Boolean hideCheckbox { get; set; }
    @AuraEnabled 
    public Boolean outputChecked { get; set; }
    @AuraEnabled 
    public String originalId { get; set; }


    global permissionsOutputWrapper(String outputName, String outputType, String outputUniqueId, Id userId, Integer compareInteger, String outputDescription) {
      this.outputName = outputName;
      this.outputType = outputType;
      this.outputUniqueId = outputUniqueId;
      this.userId = userId;
      this.compareInteger = compareInteger;
      this.outputDescription = outputDescription;
      this.displayDescription = false;
      this.displayPSDescription = false;
      this.displayPsStar = false;
      this.displayColor = 'Red';
      this.outputChecked = false;
    }

    // Compare permissionsOutputWrapper based on the compare Integer
    global Integer compareTo(Object compareTo) {

      return outputName.CompareTo(((permissionsOutputWrapper)compareTo).outputName);

  }


  }
}