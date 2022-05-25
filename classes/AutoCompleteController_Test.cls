@IsTest
public class AutoCompleteController_Test{
    static testMethod void TestFindSObjects(){
		Profile p = [select id, Name from profile where name='System Administrator'];
        
        SObject[] results = AutoCompleteController.findSObjects('Profile', p.Name, '', '');
        system.assertEquals(1, results.size());
        system.assertEquals(p.Id, results[0].Id);
        
        results = AutoCompleteController.findSObjects('Profile', p.Name, 'UserType', 'UserType=\'Standard\'');
        system.assertEquals(1, results.size());
        system.assertEquals(p.Id, ((Profile)results[0]).Id);
    }
}