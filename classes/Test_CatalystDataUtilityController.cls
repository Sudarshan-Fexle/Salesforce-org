/**
*   Purpose         :   Test class for CatalystDataUtilityController
*            
*   Create By       :   Shalu Sharma 
* 
*   Created Date    :   09/10/2021
*
*   Revision Log    :   V_1.0 - Created - CR-20210901-15400 - test CatalystDataUtilityController class
*   
*   Coverage        :   
*
**/
@isTest(seeAllData = false)
private class Test_CatalystDataUtilityController 
{
	
    //V1.0 - Created - CR-20210901-15400 - setup data
    @testSetup 
    static void dataSetup() {
        
        //Bypass Flags
        Util.IsTest(true);
        Util.isTesting = true;
        Util.byPassAllTriggers = true;
        
        //Create contact
        List<Contact> contacts = new List<Contact>();
        contacts.add(TestUtilities.CreateNewContact(false));
        contacts.add(TestUtilities.CreateNewContact(false));
        
        contacts[0].email = 'test1.junkeab@eab.com';
        contacts[0].email = 'test2.junkeab@eab.com';
        
        //insert contacts
        insert contacts;
        
       	Util.byPassAllTriggers = false;
    }
    
    //V1.0 - Created - CR-20210901-15400 - test createData Method
    @isTest(seeAllData = false)
    static void testCreateData()
    {
        //String to hold jsonData
        String jsonData;
		
        List<Contact> contacts = [Select Id, Email From Contact];
        //Wrapper 
        PrintDataUtilityWrapper pWrapper = new PrintDataUtilityWrapper();
        
        // Job Ticket Fields 
        pWrapper.JT_Drop_Type = 'Pre Planned'; //--Drop Type 
        pWrapper.JT_Vendor_Type = 'Digital'; //-- Vendor Type
        pWrapper.JT_Mail_Vendor = '001C000001aXcKsIAK';  //-- Mail Vendor
        pWrapper.JT_No_Of_Drop = 2; //-- # of Drops
        pWrapper.JT_Project_ID = '15254'; //-- Project Id 
        
        // Production Tracking Fields 
        //List of user emails for send final mail
        pWrapper.emailList = new List<String>{contacts[0].Id,contacts[1].Id};
            
        jsonData = JSON.serialize(pWrapper);

        //test start from Here
        Test.startTest();
        
        //Use Case 1 - JSON Data Not Blank
		
		LightningResponseEntity res = CatalystDataUtilityController.createData(jsonData);
		if(!Util.IS_PRODUCTION_INSTANCE)
		{
			System.assertEquals('success',res.status);
			System.assertEquals(true,res.isSuccess);
		}
        
        //Use Case 2 - JSON Data is blank
        jsonData = '';
        res = CatalystDataUtilityController.createData(jsonData);
        System.assertEquals('error',res.status);
        System.assertEquals(false,res.isSuccess);
		if(!Util.IS_PRODUCTION_INSTANCE)
		{
			System.assertEquals(Label.Parameter_Can_Not_Null,res.message);
		}else{
			System.assertEquals('You are not allowed to create the Test Data in the Production Instance',res.message);
		}
        
        // Use Case 3 - NoRecipient
        pWrapper.emailList = new List<String>();
        jsonData = JSON.serialize(pWrapper);
        res = CatalystDataUtilityController.createData(jsonData);
		if(!Util.IS_PRODUCTION_INSTANCE)
		{
			System.assertEquals('success',res.status);
			System.assertEquals(true,res.isSuccess);
			System.assertEquals(Label.Message_For_Contact_Recipient,res.message);
		}
        //test stop here
        Test.stopTest();
    }
}