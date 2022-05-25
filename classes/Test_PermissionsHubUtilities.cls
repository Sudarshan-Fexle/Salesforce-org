@isTest(isParallel=false)
public with sharing class Test_PermissionsHubUtilities {

    @TestSetup
    static void makeData(){

        //Create a couple of Users
        User peterParker = TestUtilities.CreatenewUser(false);
        peterParker.alias = 'Spidey';
        insert peterParker;

        //Finance Ops
        Profile finOps = [SELECT Id FROM Profile Where Name ='Finance Ops' LIMIT 1];

        User steveRogers = TestUtilities.CreatenewUser(finops, false);
        steveRogers.alias = 'Cap';
        insert steveRogers;

        //Get Permission Set Group
        List<PermissionSetGroup> testGroup = [SELECT Id FROM PermissionSetGroup WHERE DeveloperName = 'PSA_TE_Users' OR DeveloperName = 'PSA_Project_Manager_Users'];

        //Grab some groups and assign those to the Users
        List<Group> randomGroups = [SELECT Id FROM Group WHERE Group.Type = 'Regular' LIMIT 10];
        List<Group> randomQueues = [SELECT Id FROM Group WHERE Group.Type = 'Queue' LIMIT 5];
        List<GroupMember> membersToAdd = new List<GroupMember>();

        //Loop through the Groups and create Assignments
        for (Group g : randomGroups){

            //Create GroupMember and add to List
            GroupMember capMember = new GroupMember(UserorGroupId = steveRogers.Id, GroupId = g.Id);
            GroupMember spiderMember = new GroupMember(UserorGroupId = peterParker.Id, GroupId = g.Id);
            membersToAdd.add(capMember);
            membersToAdd.add(spiderMember);
        }

        for (Group q : randomQueues){

            //Create GroupMember and add to List
            GroupMember capMember = new GroupMember(UserorGroupId = steveRogers.Id, GroupId = q.Id);
            GroupMember spiderMember = new GroupMember(UserorGroupId = peterParker.Id, GroupId = q.Id);
            membersToAdd.add(capMember);
            membersToAdd.add(spiderMember);

        }
        
        //Insert our Groups
        insert membersToAdd;

        //Insert our PermissionSet Assignment
        List<PermissionSetAssignment> psAssignments = new List<PermissionSetAssignment>();
        psAssignments.add(new PermissionSetAssignment(AssigneeId = steveRogers.Id, PermissionSetGroupId = testGroup[0].Id));
        psAssignments.add(new PermissionSetAssignment(AssigneeId = peterParker.Id, PermissionSetGroupId = testGroup[0].Id));
        psAssignments.add(new PermissionSetAssignment(AssigneeId = steveRogers.Id, PermissionSetGroupId = testGroup[1].Id));
        insert psAssignments;

        
    }

    static testmethod void testGetUserPermissions () {

        //Set of Aliases
        Set<String> aliasStrings = new Set<String>{'Spidey', 'Cap'};

        //Get our Users
        List<User> testUsers = [SELECT Id, Alias FROM User WHERE Alias = :aliasStrings ORDER BY Alias ASC];

        User cap = testUsers[0];
        User spiderman = testUsers [1];

        //Id values
        String capId = String.valueOf(cap.Id);
        String spiderId = String.valueOf(spiderman.Id);

        //Get Managed Packages
        List<Managed_Package_Names__mdt> managedPackageNames = [SELECT Id, Namespace_Prefix__c, Managed_Package_Name__c, Package_ID__c, User_Package_License_ID__c FROM Managed_Package_Names__mdt];

        if (managedPackageNames.size() > 0){

            //Assign License to a User
            UserPackageLicense uPackage = new UserPackageLicense(UserId = cap.Id, PackageLicenseId = managedPackageNames[0].User_Package_License_ID__c);
            insert uPackage;

        }

        //Start our Test
        Test.startTest();

        //Pass our Ids through to our method
        Map<Id, List<PermissionsHubUtilities.permissionsOutputWrapper>> mapUserToPermissions = PermissionsHubUtilities.getUserPermissionsInformation(capId, spiderId);

        //Run some assertions
        System.assertEquals(mapUserToPermissions.keyset().size(), 2);

        //Get our Groups
        Integer groupCounter = 0;
        List<PermissionsHubUtilities.permissionsOutputWrapper> userWrappers = mapUserToPermissions.get(cap.Id);
        for (PermissionsHubUtilities.permissionsOutputWrapper wrapper : userWrappers){
            if (wrapper.outputType == 'Group'){
                groupCounter++;
            }
        }
        System.AssertEquals(groupCounter, 10);

        //Stop our Test
        Test.stopTest();


    }

    static testmethod void testAssignDeletePermissionRecords () {

        //Set of Aliases
        Set<String> aliasStrings = new Set<String>{'Spidey', 'Cap'};

        //Get our Users
        List<User> testUsers = [SELECT Id, Alias, ProfileId, UserRoleId FROM User WHERE Alias = :aliasStrings ORDER BY Alias ASC];

        User cap = testUsers[0];
        User spiderman = testUsers [1];

        //Get some Permission Set Data to be Assigned
        List<PermissionSet> permsToAssign = [SELECT Id, Label FROM PermissionSet WHERE IsOwnedByProfile = FALSE LIMIT 2];

        //List for Assignment
        List<PermissionsHubUtilities.permissionsOutputWrapper> wrappersToAssign = new List<PermissionsHubUtilities.permissionsOutputWrapper>();

        //Create our Permission Set Data
        for (PermissionSet permSet : permsToAssign){

            //Create new Permission Output Wrapper
            PermissionsHubUtilities.permissionsOutputWrapper newWrapper = new PermissionsHubUtilities.permissionsOutputWrapper(permSet.Label, 'Permission Set', permSet.Id, cap.Id, null, null);
            newWrapper.originalId = permSet.Id;
            wrappersToAssign.add(newWrapper);

        }

        //Create new Permission Output Wrapper
        PermissionsHubUtilities.permissionsOutputWrapper profileWrapper = new PermissionsHubUtilities.permissionsOutputWrapper(null, 'Profile', cap.ProfileId, cap.Id, null, null);
        profileWrapper.originalId = cap.ProfileId;
        PermissionsHubUtilities.permissionsOutputWrapper roleWrapper = new PermissionsHubUtilities.permissionsOutputWrapper(null, 'Role', cap.UserRoleId, cap.Id, null, null);
        roleWrapper.originalId = cap.UserRoleId;
        wrappersToAssign.add(profileWrapper);
        wrappersToAssign.add(roleWrapper);

        //Pass through to method
        PermissionsHubUtilities.assignDeletePermissionRecords(wrappersToAssign, String.valueOf(spiderman.Id), Constants.PERMISSIONS_HUB_COMMAND_ASSIGN);

        //List of Wrappers for Removal
        List<PermissionsHubUtilities.permissionsOutputWrapper> wrappersToRemove = new List<PermissionsHubUtilities.permissionsOutputWrapper>();

        //Scenario Two - Remove Groups from Existing User
        List<GroupMember> groupsToRemove = [SELECT Id FROM GroupMember WHERE UserorGroupId = :spiderman.Id];

        //Loop through and create Wrappers for removal
        for (GroupMember gMember : groupsToRemove){

            //Create new Permission Output Wrapper
            PermissionsHubUtilities.permissionsOutputWrapper newWrapper = new PermissionsHubUtilities.permissionsOutputWrapper(null, 'Group', gMember.Id, spiderman.Id, null, null);
            newWrapper.originalId = gMember.Id;
            wrappersToRemove.add(newWrapper);

        }

        //Pass through to method
        PermissionsHubUtilities.assignDeletePermissionRecords(wrappersToRemove, String.valueOf(spiderman.Id), Constants.PERMISSIONS_HUB_COMMAND_REMOVE);

        //Check the Groups have been removed
        List<GroupMember> groupsThatHaveBeenRemoved = [SELECT Id FROM GroupMember WHERE UserorGroupId = :spiderman.Id];
        System.assertEquals(0, groupsThatHaveBeenRemoved.size());

    }

    static testmethod void testGetUnusedManagedPackageLicenses () {

        //Get License Wrappers
        List<PermissionsHubUtilities.managedPackageLicenceWrapper> licenseWrappers = PermissionsHubUtilities.getUnusedManagedPackageLicenses();

    }


}