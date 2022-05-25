@isTest(seeAllData = false)
public class AddToWatchListControllerTest {
    //Test method
    static testMethod void testController() {
        
        Test.startTest();
        //Insert Contact
        Contact contact = TestUtilities.CreateNewContact(true);
        List<Contact> conList = [SELECT Name FROM Contact LIMIT 1];
        ApexPages.StandardSetController controller = new ApexPages.StandardSetController(conList);
        AddToWatchListController addToWatchList = new AddToWatchListController(controller);
        Test.stopTest();
    }
}