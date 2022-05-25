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
/**
 * 	Purpose			:	Test class for Intranet Utilization
 * 
 * 	Created By		:	
 * 
 * 	Created Date	:	09/30/2014
 * 
 *	Revision Logs	:	V_1.0 - Created
 *						V_1.1 - Modified By - Rajeev Jain - CR-7579	- 06/22/2015
 *					:	V_2.0 - Modfied By - Rajeev Jain - CR-7579 - 09/15/2015
 * 					:	V_2.1 - Modified By - Mahendra Swarnkar - as per the failure in Run all Test. - 1/31/2017
 *	Coverage		:	100%
 **/ 
@isTest
private class Test_IntranetUtilizationHelper {

    static testMethod void testCreateIntranetUtilizationRecord() {
        
        //Intranet Container
        Intranet_Container__c intranetContainer = new Intranet_Container__c(Name = 'Test-2', CurrencyIsoCode = 'USD', Content_Types_Allowed__c = 'Firm App Link');
        insert intranetContainer;
        
        //Intranet Item
        Intranet_Item__c intranetItem = new Intranet_Item__c(Name = 'Test-0' , Active_Status__c = 'Active' , Office_Short_Name__c = 'DC', 
                                                             	Item_Type__c = 'Firm App Link' , Item_Title__c = 'A1');
        insert intranetItem;
        
        //Intranet Schedule
        Intranet_Schedule__c intranetSchedule = new Intranet_Schedule__c(Name = 'Test4' , Intranet_Container__c = intranetContainer.Id, Intranet_Item__c = intranetItem.Id,
                                                                        		Start_Date_Time__c = DateTime.Now()+1, End_Date_Time__c = DateTime.Now()+5 );
        insert intranetSchedule;
        
        //Update User record with Job Level
        System.runAs(new User(Id = UserInfo.getUserId())) {
			
            //V_2.1 - Modified By - Mahendra Swarnkar - as per the failure in Run all Test. - 1/31/2017
            update new User(Id = UserInfo.getUserId(), Job_Level__c = '10 B1 Early Professional', Office__c = intranetItem.Id, IsManager__c = false);
            //V_2.1 - Modified By - Mahendra Swarnkar - as per the failure in Run all Test. - 1/31/2017 ends here
        }
        
        //Start Testing from here
        Test.startTest();
        
        //Set values
        IntranetHomeUtility.UserBrowser = 'Chrome';
        IntranetHomeUtility.UserDevice = 'Mobile';
        IntranetHomeUtility.ScreenSize = 992;
        IntranetHomeUtility.NetworkAccess = 'Test';
        
        //Call PopulateUserSession method
        IntranetType.UserSession UserSession = IntranetHomeUtility.getUserSession;
        
        //Serialize UserSession
        String serializedUserSession = JSON.serialize(UserSession);
        
        //Call helper class method
        IntranetUtilizationHelper.createIntranetUtilizationRecord(serializedUserSession, 'Test Click Type', null, intranetContainer.Id, intranetItem.Id, intranetSchedule.Id, 5);
        
        //Stop testing here
        Test.stopTest();
        
        //Assert for the results
        User currentUser = [Select Id, FirstName, LastName, Office__c, Workspace__c, Job_Level__c, ABC_Department__c, ABC_Division__c, ABC_Function__c from User where Id =: UserInfo.getUserId()];
        System.assertEquals(currentUser.FirstName, UserSession.FirstName);
        System.assertEquals(currentUser.LastName, UserSession.LastName);
        System.assertEquals(currentUser.Id, UserSession.UserId);
        System.assertEquals(currentUser.Office__c, UserSession.AssignedOffice);
        System.assertEquals(currentUser.Workspace__c, UserSession.Workspace);
        System.assertEquals('B', UserSession.JobLevel);
        System.assertEquals(currentUser.ABC_Department__c, UserSession.Department);
        System.assertEquals(currentUser.ABC_Division__c, UserSession.Division);
        System.assertEquals(currentUser.ABC_Function__c, UserSession.Function);
        System.assertEquals('Laptop (992 pixels)', UserSession.ScreenSize);
        System.assertEquals(IntranetHomeUtility.NetworkAccess, UserSession.AccessLocation);
        System.assertEquals(IntranetHomeUtility.UserBrowser, UserSession.Browser);
        System.assertEquals(IntranetHomeUtility.UserDevice, UserSession.Device);
        
        //Check for the newly created Utilization record
        List<Intranet_Utilization__c> intranetUtilization = [Select Id, Access_Location__c, Browser__c, Click_Type__c, Department__c, Device__c, Division__c, 
                                                                Function__c, Intranet_Container__c, Intranet_Item__c, Intranet_Schedule__c, 
                                                                Job_Level__c, Manager__c, Office__c, Rating__c, Screensize__c, User__c 
                                                                from Intranet_Utilization__c where Intranet_Container__c =: intranetContainer.Id];
        
        //Assert for the results
        System.assertEquals(1, intranetUtilization.size());
        System.assertEquals(UserSession.AccessLocation, intranetUtilization[0].Access_Location__c);
        System.assertEquals(UserSession.Browser, intranetUtilization[0].Browser__c);
        System.assertEquals('Test Click Type', intranetUtilization[0].Click_Type__c);
        System.assertEquals(UserSession.Department, intranetUtilization[0].Department__c);
        System.assertEquals(UserSession.Device, intranetUtilization[0].Device__c);
        System.assertEquals(UserSession.Division, intranetUtilization[0].Division__c);
        System.assertEquals(UserSession.Function, intranetUtilization[0].Function__c);
        System.assertEquals(intranetContainer.Id, intranetUtilization[0].Intranet_Container__c);
        System.assertEquals(intranetItem.Id, intranetUtilization[0].Intranet_Item__c);
        System.assertEquals(intranetSchedule.Id, intranetUtilization[0].Intranet_Schedule__c);
        System.assertEquals(UserSession.JobLevel, intranetUtilization[0].Job_Level__c);
        System.assertEquals(false, intranetUtilization[0].Manager__c);
        System.assertEquals(intranetItem.Office_Short_Name__c + ' Office', intranetUtilization[0].Office__c);
        System.assertEquals(5, intranetUtilization[0].Rating__c);
        System.assertEquals(UserSession.ScreenSize, intranetUtilization[0].Screensize__c);
        System.assertEquals(UserSession.UserId, intranetUtilization[0].User__c);
    }
    
    //Unit test for getLikedItems
    static testMethod void testGetLikedItems() {
    	
    	//Create Test data
    	//Intranet Container
        Intranet_Container__c intranetContainer = new Intranet_Container__c(Name = 'Test-2', CurrencyIsoCode = 'USD', Content_Types_Allowed__c = 'App Link');
        insert intranetContainer;
        
        //Intranet Item
        Intranet_Item__c intranetItem = new Intranet_Item__c(Name = 'Test-0' , Active_Status__c = 'Active' , Item_Type__c = 'App Link' , Item_Title__c = 'A1');
        insert intranetItem;
        
        //Intranet Schedule
        Intranet_Schedule__c intranetSchedule = new Intranet_Schedule__c(Name = 'Test4' , Intranet_Container__c = intranetContainer.Id, Intranet_Item__c = intranetItem.Id,
                                                                        		Start_Date_Time__c = DateTime.Now()+1, End_Date_Time__c = DateTime.Now()+5 );
        insert intranetSchedule;
        
        //Intranet Utilazation
        List<Intranet_Utilization__c> listUtilization = new List<Intranet_Utilization__c>();
        
        //Add data in list
        listUtilization.add(new Intranet_Utilization__c(Intranet_Container__c = intranetContainer.Id, Intranet_Item__c = intranetItem.Id, 
        													Intranet_Schedule__c = intranetSchedule.Id));
		listUtilization.add(new Intranet_Utilization__c(Intranet_Container__c = intranetContainer.Id, Intranet_Item__c = intranetItem.Id, 
        													Intranet_Schedule__c = intranetSchedule.Id, User__c = UserInfo.getUserId()));
		listUtilization.add(new Intranet_Utilization__c(Intranet_Container__c = intranetContainer.Id, Intranet_Item__c = intranetItem.Id, 
        													Intranet_Schedule__c = intranetSchedule.Id, User__c = UserInfo.getUserId(), 
        													Click_Type__c = IntranetUtilizationHelper.CLICK_TYPE_LIKE));
		listUtilization.add(new Intranet_Utilization__c(Intranet_Container__c = intranetContainer.Id, Intranet_Item__c = intranetItem.Id, 
        													Intranet_Schedule__c = intranetSchedule.Id, User__c = UserInfo.getUserId(), 
        													Click_Type__c = IntranetUtilizationHelper.CLICK_TYPE_LIKE));
		insert listUtilization;
		
		//Start testting from Here
		Test.startTest();
		
		//Call method
		Map<String, Intranet_Utilization__c> mapIntranetUtilization = IntranetUtilizationHelper.getLikedItems();
		
        //Get Tab Utilization Map
        Map<String,String> mapTabUtilization = IntranetUtilizationHelper.TabUtilizationItemMap;
        
		//Stop Test													
    	Test.stopTest();
     	
    	//Assertion
    	System.assertEquals(2, mapIntranetUtilization.size());
        System.assertEquals('Training Event Tab Utilization', mapTabUtilization.get('Training'));
        System.assertEquals('Board Room Main Page Utilization', mapTabUtilization.get('BoardRoom Home Page'));
    }
}