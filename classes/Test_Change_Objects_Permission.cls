/**
*  Description     :   This class is to test the functionality of Change_Objects_Permission
* 
*  Created By      :   Dipesh Gupta
* 
*  Created Date    :   06/3/2020
* 
**/
@istest
public without sharing class Test_Change_Objects_Permission {
    
    @istest Static void Test_createPermissionNode() {
        test.startTest();
        Change_Objects_Permission.createPermissionNode();
        test.stopTest();
    }
    
    @istest Static void Test_createNode() { 
        Map<String, String> mapObjApiNameWithPermission = new Map<String, String>();
        mapObjApiNameWithPermission.put('Account', 'Profile');
        
        List<String> profiles = new List<String>{'System Administrator'};
            
        test.startTest();
        Change_Objects_Permission.createNode(mapObjApiNameWithPermission, profiles);
        Integer invocations = Limits.getEmailInvocations();
        test.stopTest();
        system.assertEquals(1, invocations, 'An email should be sent');
    }
    
    @istest Static void Test_setRequiredPermission() {
        test.startTest();
        String str = Change_Objects_Permission.setRequiredPermission('Account','No Access');
        System.assert(true, str.contains('<object>Account</object>'));
        test.stopTest();
    }
    
    @istest Static void Test_setRequiredPermission_Check() {
        test.startTest();
        String str = Change_Objects_Permission.setRequiredPermission('Account','create');
        System.assert(true, str.contains('\t\t<allowCreate>true</allowCreate>\n'));
        
        String str1 = Change_Objects_Permission.setRequiredPermission('Account','delete');
        System.assert(true, str1.contains('\t\t<allowDelete>true</allowDelete>\n'));
        
        String str2 = Change_Objects_Permission.setRequiredPermission('Account','edit');
        System.assert(true, str2.contains('\t\t<allowEdit>true</allowEdit>\n'));
        
        String str3 = Change_Objects_Permission.setRequiredPermission('Account','read');
        System.assert(true, str3.contains('\t\t<allowRead>true</allowRead>\n'));
        
        String str4 = Change_Objects_Permission.setRequiredPermission('Account','Modify All');
        System.assert(true, str4.contains('\t\t<modifyAllRecords>true</modifyAllRecords>\n'));
        
        test.stopTest();
    }
    
    @istest Static void Test_setRequiredPermission_blankCheck() {
        test.startTest();
        String str = Change_Objects_Permission.setRequiredPermission('Account','');
        System.assert(true, str.contains('\t\t<allowCreate>true</allowCreate>\n'));
        test.stopTest();
    }
}