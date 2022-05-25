@isTest(seeAllData = false)
public class AddToWatchListAccountControllerTest {
 
    //Test method
    static testMethod void testController() {
        Test.startTest();
        //Insert Account
        Account acc = TestUtilities.CreateNewAccount(true);
        List<Account> accList = [SELECT Name FROM Account LIMIT 1];
        ApexPages.StandardSetController controller = new ApexPages.StandardSetController(accList);
        AddToWatchListAccountController addToWatchList = new AddToWatchListAccountController(controller);
        Test.stopTest();
    }
}