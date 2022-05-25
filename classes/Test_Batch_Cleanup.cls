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
    *	Description		:	The test class to test the functionalities of Batch_Cleanup btach class
    *
    *	Created by		:	Saurabh Kumar
    * 
    * 	Created Date	        :	08/17/2017
    * 
    * 	Revision Log	        :	V1.0 Created - CR-20170803-11119
    *				:       V1.1 Modified By - Nikita Kumari - CR-20211005-15489
	*			:	V1.2 Commented By - Nikita Kumari - 03/07/2022 - CR-20220217-15921 - Boardroom Sunsetting Changes
    *				
    **/
@isTest(seeAllData = false)
class Test_Batch_Cleanup {
    
   /**
    *	Description		:	The setup method to insert common data
    *
    *	@args 
    *
    *	@return			:	Void
    *
    *	@revision		:	V1.0 Created - CR-20170803-11119. 
   				:	V1.1 - Commented By - Nikita Kumari - 03/07/2022 - CR-20220217-15921 - Boardroom Sunsetting Changes
    **/
    @testSetup
    static void setupDate(){
        
        Util.BypassAllTriggers = true;
        //Commented By - Nikita Kumari - 03/07/2022 - CR-20220217-15921 - Boardroom Sunsetting - Start from here
        //Intranet Container
        /*Intranet_Container__c intranetContainer = new Intranet_Container__c(Name = 'Test-2', CurrencyIsoCode = 'USD', Content_Types_Allowed__c = 'App Link');
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
        insert listUtilization;*/
	//Commented By - Nikita Kumari - 03/07/2022 - CR-20220217-15921 - Boardroom Sunsetting - Ends here        
        //Creating Web Service record
        List<Web_Service_Log__c> webserviceLog = new List<Web_Service_Log__c>();
        webserviceLog.add(new Web_Service_Log__c(Card_Vendor__c = 'Out side'));
        insert webserviceLog;
        
        Util.BypassAllTriggers = False;
    }
    
   /**
    *	Description		:	The method is for the batch functionality
    *
    *	@args 
    *
    *	@return			:	Void
    *
    *	@revision		:	V1.0 Created - CR-20170803-11119. 
    				: 	V1.1 Modified By - Nikita Kumari - 03/07/2022 - CR-20220217-15921 - Boardroom Sunsetting
    **/
    testMethod static void unitTest(){
        
        Util.IsTest(true);
        //Initializing the batch
        //Modified By - Nikita Kumari - 03/07/2022 - CR-20220217-15921 - Boardroom Sunsetting (Removed Intranet_Utilization__c and added Web_Service_Log_c in query)
        Batch_Cleanup cleanup = new Batch_Cleanup('Select Id From Web_Service_Log_c');
        cleanup.executionOrder = -1;
        
        //Start the batch execution
        Database.executeBatch(cleanup);
        
        //Query on the the asynchronous job to make sure that batch execution get started
        List<AsyncApexJob> asyncJob = [Select Id From AsyncApexJob Where ApexClass.Name = 'Batch_Cleanup'];
        
        //Assertions
        if(asyncJob != null && asyncJob.size() > 0 ) {
            System.assertNotEquals(null, asyncJob[0]);    
        }
    }
}