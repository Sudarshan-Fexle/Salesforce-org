/**
 * @description: Test class for Intranet Chatter Group Controller
 * 
 * Current vision   :   v1.0 - Created
 *                      V2.0 - Modified
 * Revision Logs    :   V2.0 - Modified By -Rajeev Jain(05/22/2015) CR-20141002-7579
 *                  :   V3.0 - Modified By - Rajeev Jain(09/5/2015) CR-20141002-7579
 **/
@isTest
private class Test_IntranetChatterGroupController {
    
    /**
     * @description:    
     * 
    **/
    static testMethod void testInitializeController() {
        
        //Profiles
        List<Profile> profiles = [Select ID from profile 
                                    WHERE Name = 'System Administrator'];
        
        //Checking if profile exists in the system
        if(profiles != null && profiles.size() > 0) {
        
            //Create an user
            User newUser = new User();
            newUser.Alias = 'tUser';
            newUser.Email = 'tUser@noreply.com';
            newUser.EmailEncodingKey = 'UTF-8';
            newUser.LastName = 'User';
            newUser.ProfileId = profiles[0].Id;
            newUser.Username = 'tUser@noreply'+crypto.getRandomLong()+'.com';
            newUser.TimeZoneSidKey = 'America/New_York';
            newUser.LanguageLocaleKey = 'en_US';
            newUser.LocaleSidKey = 'en_US';
            insert newUser;
            
            //Running in system user context
            System.runAs(newUser) {
                
                // create a CollaborationGroup
                CollaborationGroup aGroup = new CollaborationGroup(CollaborationType='Public',
                                                                   Description='test',
                                                                   Name='Test Group12345');
                insert aGroup;
        
                //instantiate the controller
                IntranetChatterGroupController controller = new IntranetChatterGroupController();
                
                system.assertEquals(true, controller.groupMemberMap.get(aGroup.Id));
                system.assertEquals(1, controller.groups.size());
            }    
        }        
    }
    
    /**
     * @description:    
     * 
    **/
    static testMethod void testJoinGroup() {
        
        //Profiles
        List<Profile> profiles = [Select ID from profile 
                                    WHERE Name = 'System Administrator'];
        
        //Checking if profile exists in the system
        if(profiles != null && profiles.size() > 0) {
        
            //Create an user
            User newUser = new User();
            newUser.Alias = 'tUser';
            newUser.Email = 'tUser@noreply.com';
            newUser.EmailEncodingKey = 'UTF-8';
            newUser.LastName = 'User';
            newUser.ProfileId = profiles[0].Id;
            newUser.Username = 'tUser@noreply'+crypto.getRandomLong()+'.com';
            newUser.TimeZoneSidKey = 'America/New_York';
            newUser.LanguageLocaleKey = 'en_US';
            newUser.LocaleSidKey = 'en_US';
            insert newUser;
            
            // create a CollaborationGroup
            CollaborationGroup aGroup = new CollaborationGroup(CollaborationType='public',
                                                               Description='test',
                                                               Name='Test Group123456');
            insert aGroup;
            
            //Running in system user context
            System.runAs(newUser) {
                
                //instantiate the controller
                IntranetChatterGroupController controller = new IntranetChatterGroupController();
                
                system.assertEquals(false, controller.groupMemberMap.get(aGroup.Id));
                system.assertEquals(1, controller.groups.size());
                
                //join the group
                controller.groupId = aGroup.Id;
                controller.joinGroup();
             
                //assertions
                system.assertEquals(true, controller.groupMemberMap.get(aGroup.Id));
            }
        }
    }
}