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
/** Description     :   Test class for IntranetScheduleTrigger.
  * 
  * Created Date    :   08/06/2014
  *
  * Created By      :   
  *  
  * Current vision  :    v1.0
  *  
  * Revision Logs   :    v1.0 - Created
  * 				:	V2.0 - Modified By - Rajeev Jain - 09/14/2015 - CR-20141002-7579
  *
  * Coverage        :	100%
  **/ 
@isTest(seeAllData=false)
private class Test_IntranetScheduleTrigger {
    
    /**
      * @Description    :   Method to check functionality of  validateDate
      *
      * @args           :   
      *
      * @return         :   void
      *
    **/
    static testMethod void testValidateDate() {
        
        //List of Intranet Container 
        List<Intranet_Container__c> listIntranetContainers = new List<Intranet_Container__c>();
        listIntranetContainers.add(new Intranet_Container__c(Name = 'Test-1',
                                                             CurrencyIsoCode = 'USD' ,
                                                             Content_Types_Allowed__c = 'App Link' ,
                                                             Display_Name__c = 'Testing'));
                                                             
        listIntranetContainers.add(new Intranet_Container__c(Name = 'Test-2' ,
                                                             CurrencyIsoCode = 'USD' ,
                                                             Content_Types_Allowed__c = 'App Link',
                                                             Display_Name__c = '1234567891012345678901234'));
                                                              
        //Insert Intranet container 
        insert listIntranetContainers ;
        
        //List of ineternet items
        List<Intranet_Item__c> listIntranetItems = new List<Intranet_Item__c>();
        listIntranetItems.add(new Intranet_Item__c(Name = 'Test-0' , Active_Status__c = 'Active' , Item_Type__c = 'App Link' , Item_Title__c = 'A1'));
        listIntranetItems.add(new Intranet_Item__c(Name = 'Test-1' , Active_Status__c = 'Active' , Item_Type__c = 'App Link' , Item_Title__c = 'B1'));
        listIntranetItems.add(new Intranet_Item__c(Name = 'Test-2' , Active_Status__c = 'Active' , Item_Type__c = 'App Link' , Item_Title__c = 'C1'));
        listIntranetItems.add(new Intranet_Item__c(Name = 'Test-3' , Active_Status__c = 'Active' , Item_Type__c = 'App Link' , Item_Title__c = 'D1'));
        listIntranetItems.add(new Intranet_Item__c(Name = 'Test-4' , Active_Status__c = 'Active' , Item_Type__c = 'App Link' , Item_Title__c = 'E1'));

        //Insert Intranet items
        insert listIntranetItems ;
        
        //List of Intranet schedule 
        List<Intranet_Schedule__c> listIntranetSchedules = new List<Intranet_Schedule__c>();
        listIntranetSchedules.add(new Intranet_Schedule__c(Name = 'Test' , Intranet_Container__c = listIntranetContainers[0].Id ,
                                                                           Intranet_Item__c = listIntranetItems[0].Id,
                                                                           Start_Date_Time__c = DateTime.now(),
                                                                           End_Date_Time__c = DateTime.now().addDays(1)));
                                                                         
        listIntranetSchedules.add(new Intranet_Schedule__c(Name = 'Test1' , Intranet_Container__c = listIntranetContainers[1].Id ,
                                                                            Intranet_Item__c = listIntranetItems[1].Id,
                                                                           Start_Date_Time__c = DateTime.now(),
                                                                           End_Date_Time__c = DateTime.now().addDays(1)));
                                                                          
        listIntranetSchedules.add(new Intranet_Schedule__c(Name = 'Test2' , Intranet_Container__c = listIntranetContainers[0].Id ,
                                                                            Intranet_Item__c = listIntranetItems[2].Id,
                                                                           Start_Date_Time__c = DateTime.now(),
                                                                           End_Date_Time__c = DateTime.now().addDays(1)));
                                                                          
        listIntranetSchedules.add(new Intranet_Schedule__c(Name = 'Test3' , Intranet_Container__c = listIntranetContainers[0].Id ,
                                                                            Intranet_Item__c = listIntranetItems[3].Id,
                                                                           Start_Date_Time__c = DateTime.now(),
                                                                           End_Date_Time__c = DateTime.now().addDays(1)));
                                                                          
        listIntranetSchedules.add(new Intranet_Schedule__c(Name = 'Test4' , Intranet_Container__c = listIntranetContainers[0].Id ,
                                                                            Intranet_Item__c = listIntranetItems[4].Id,
                                                                           Start_Date_Time__c = DateTime.now(),
                                                                           End_Date_Time__c = DateTime.now().addDays(1)));
        
        //Test start here
        Test.startTest(); 
        
        insert listIntranetSchedules;
        
        //Test stops here
        Test.stopTest();
    	
    	//Asssert for results
        listIntranetSchedules = [SELECT Id , Name , Intranet_Container__r.Display_Name__c , Intranet_Item__r.Item_Title__c , CreatedDate 
                                                                                                        FROM Intranet_Schedule__c 
                                                                                                        WHERE ID IN: listIntranetSchedules];
                                                                                                        
        //Date Value
        String dateValue = Date.today().year() + IntranetScheduleTriggerHelper.DATE_FORMAT_SEPARATOR + ('0' + Date.today().month()).right(2) + IntranetScheduleTriggerHelper.DATE_FORMAT_SEPARATOR + ('0' + Date.today().day()).right(2);
                                                               
        System.assertEquals(listIntranetSchedules[0].Intranet_Container__r.Display_Name__c + IntranetScheduleTriggerHelper.NAME_VALUES_SEPARATOR + listIntranetSchedules[0].Intranet_Item__r.Item_Title__c + IntranetScheduleTriggerHelper.NAME_VALUES_SEPARATOR + dateValue, listIntranetSchedules[0].Name);                                                     
        System.assertEquals(listIntranetSchedules[1].Intranet_Container__r.Display_Name__c.left(20) + IntranetScheduleTriggerHelper.NAME_VALUES_SEPARATOR + listIntranetSchedules[1].Intranet_Item__r.Item_Title__c + IntranetScheduleTriggerHelper.NAME_VALUES_SEPARATOR + dateValue, listIntranetSchedules[1].Name);                                                     
        System.assertEquals(listIntranetSchedules[2].Intranet_Container__r.Display_Name__c + IntranetScheduleTriggerHelper.NAME_VALUES_SEPARATOR + listIntranetSchedules[2].Intranet_Item__r.Item_Title__c + IntranetScheduleTriggerHelper.NAME_VALUES_SEPARATOR + dateValue, listIntranetSchedules[2].Name);                                                      
        System.assertEquals(listIntranetSchedules[3].Intranet_Container__r.Display_Name__c + IntranetScheduleTriggerHelper.NAME_VALUES_SEPARATOR + listIntranetSchedules[3].Intranet_Item__r.Item_Title__c + IntranetScheduleTriggerHelper.NAME_VALUES_SEPARATOR + dateValue, listIntranetSchedules[3].Name);                                                     
        System.assertEquals(listIntranetSchedules[4].Intranet_Container__r.Display_Name__c + IntranetScheduleTriggerHelper.NAME_VALUES_SEPARATOR + listIntranetSchedules[4].Intranet_Item__r.Item_Title__c + IntranetScheduleTriggerHelper.NAME_VALUES_SEPARATOR + dateValue, listIntranetSchedules[4].Name);                                                     
    }
    
    /**
      * @Description    :   Method to check functionality of createTopics
      *
      * @args           :   
      *
      * @return         :   void
      *
    **/
    static testMethod void testCreateTopicsOnInsert() {
         
        RecordType rdType = [Select DeveloperName, Id From RecordType where sObjectType = 'Intranet_Item__c' AND isActive = true AND DeveloperName = 'Settings_Office' LIMIT 1];

        //List of Intranet Container 
        List<Intranet_Container__c> listIntranetContainers = new List<Intranet_Container__c>();
        listIntranetContainers.add(new Intranet_Container__c(Name = 'Test-1' ,
                                                             CurrencyIsoCode = 'USD' ,
                                                             Content_Types_Allowed__c = 'A;B;C;D;E;F',
                                                             Display_Name__c='Testing'
                                                            ));
                                                             
        listIntranetContainers.add(new Intranet_Container__c(Name= 'Test-2' , 
                                                             CurrencyIsoCode = 'USD' ,
                                                             Content_Types_Allowed__c = 'A;B;C;D;E;F',
                                                             Display_Name__c='TestingABC'));
                                                              
        //Insert Intranet container 
        insert listIntranetContainers ;
        
        //List of ineternet items
        List<Intranet_Item__c> listIntranetItems = new List<Intranet_Item__c>();
        listIntranetItems.add(new Intranet_Item__c(Name = 'Test0', Active_Status__c = 'Active' , Item_Title__c = 'A' ,
                                                                    RecordTypeId = rdType.Id ,
                                                                    Category_Name__c = 'A',
                                                                    Item_Type__c = 'A', Office_Short_Name__c = 'A' ));
                                                                    
        listIntranetItems.add(new Intranet_Item__c(Name = 'Test1', Active_Status__c = 'Active' , Item_Title__c = 'B' ,
                                                                    RecordTypeId = rdType.Id ,
                                                                    Category_Name__c = 'B',
                                                                    Item_Type__c = 'B', Office_Short_Name__c = 'B'));
                                                                    
        listIntranetItems.add(new Intranet_Item__c(Name = 'Test2', Active_Status__c = 'Active' , Item_Title__c = 'C' ,
                                                                    RecordTypeId = rdType.Id ,
                                                                    Category_Name__c = 'C',
                                                                    Item_Type__c = 'C', Office_Short_Name__c = 'C'));
                                                                    
        listIntranetItems.add(new Intranet_Item__c(Name = 'Test3', Active_Status__c = 'Active' , Item_Title__c = 'D',
                                                                    RecordTypeId = rdType.Id ,
                                                                    Category_Name__c = 'D',
                                                                    Item_Type__c = 'D', Office_Short_Name__c = 'D'));
                                                                    
        listIntranetItems.add(new Intranet_Item__c(Name = 'Test4', Active_Status__c = 'Active', Item_Title__c = 'E',
                                                                    RecordTypeId = rdType.Id,
                                                                    Category_Name__c = 'E',
                                                                    Item_Type__c = 'E', Office_Short_Name__c = 'E'));
                                                                    
        listIntranetItems.add(new Intranet_Item__c(Name = 'Test5', Active_Status__c = 'Active', Item_Title__c = 'F',
                                                                    RecordTypeId = rdType.Id,
                                                                    Category_Name__c = 'F', Office_Short_Name__c = 'F'));                                                           
        
        system.runAs(new User(Id = userInfo.getUserId())) {
            //Insert Intranet items
            insert listIntranetItems ;
        }
        
        //Unique String
        String divisionText = 'TEST_DIVISION_UNIQUE';
        String functionText = 'TEST_FUNCTION_UNIQUE';
        
        //List of Intranet schedule 
        List<Intranet_Schedule__c> listIntranetSchedules = new List<Intranet_Schedule__c>();
        listIntranetSchedules.add(new Intranet_Schedule__c(Name = 'Testabcd', Intranet_Container__c = listIntranetContainers[0].Id,
                                                                              Intranet_Item__c = listIntranetItems[0].Id,
                                                                              Office__c = listIntranetItems[0].Id,
                                                                              Function__c = functionText,
                                                                              Division__c = divisionText,
                                                                               Start_Date_Time__c = Date.Today(),
                                                                               End_Date_Time__c = Date.Today() + 1));
        
                                                                         
        listIntranetSchedules.add(new Intranet_Schedule__c(Name = 'Test1' , Intranet_Container__c = listIntranetContainers[1].Id,
                                                                            Intranet_Item__c = listIntranetItems[1].Id,
                                                                            Office__c = listIntranetItems[1].Id,
                                                                            Function__c = functionText + '1',
                                                                            Division__c =  divisionText + '1',
                                                                            Start_Date_Time__c = Date.Today(),
                                                                            End_Date_Time__c = Date.Today() + 1));
                                                                        
        listIntranetSchedules.add(new Intranet_Schedule__c(Name = 'Test2' , Intranet_Container__c = listIntranetContainers[0].Id,
                                                                            Intranet_Item__c = listIntranetItems[2].Id,
                                                                            Office__c = listIntranetItems[2].Id,
                                                                            Function__c = functionText + '2',
                                                                            Division__c = divisionText + '2',
                                                                            Start_Date_Time__c = Date.Today(),
                                                                            End_Date_Time__c = Date.Today() + 1));
                                                                        
        listIntranetSchedules.add(new Intranet_Schedule__c(Name = 'Test3' , Intranet_Container__c = listIntranetContainers[0].Id,
                                                                            Intranet_Item__c = listIntranetItems[3].Id,
                                                                            Office__c = listIntranetItems[3].Id,
                                                                            Function__c = functionText + '3',
                                                                            Division__c = divisionText + '3',
                                                                            Start_Date_Time__c = Date.Today(),
                                                                            End_Date_Time__c = Date.Today() + 1));
                                                                        
        listIntranetSchedules.add(new Intranet_Schedule__c(Name = 'Test4' , Intranet_Container__c  = listIntranetContainers[0].Id,
                                                                            Intranet_Item__c = listIntranetItems[4].Id,
                                                                            Office__c = listIntranetItems[4].Id,
                                                                            Function__c = functionText + '4',
                                                                            Division__c = divisionText + '4',
                                                                            Start_Date_Time__c = Date.Today(),
                                                                            End_Date_Time__c = Date.Today() + 1));
                                                                               
        //Test start here    
        Test.startTest(); 
        
        system.runAs(new User(Id = userInfo.getUserId())) { 
            //insert Intranet schedule 
            insert listIntranetSchedules;    
        }      
        
         //Assert for results for topics for Office & Function & Divvson  
        List<Topic> listOfTopics = [SELECT Id FROM Topic]; 
        system.assertEquals(15 , listOfTopics.size());   
        
        //Assert for topic Assignmnet
        List<TopicAssignment> listOfTopicAssig = [SELECT Id , EntityId , TopicId FROM TopicAssignment 
                                                                                 WHERE EntityId IN: listIntranetItems 
                                                                                 AND TopicId IN: listOfTopics];
        system.assertEquals(15 , listOfTopicAssig.size());   
        
        //Update Intranet schedule
        listIntranetSchedules[0].Office__c = null;
        listIntranetSchedules[1].Function__c = '';
        listIntranetSchedules[2].Division__c = '';
        listIntranetSchedules[3].Office__c = listIntranetItems[5].Id;
        
        update listIntranetSchedules;
        
        //Assert for results
        listOfTopics = [SELECT Id FROM Topic]; 
        system.assertEquals(16 , listOfTopics.size()); 
            
        listOfTopicAssig = [SELECT Id , EntityId , TopicId FROM TopicAssignment 
                                                           WHERE EntityId IN: listIntranetItems 
                                                           AND TopicId IN: listOfTopics];
        system.assertEquals(12 , listOfTopicAssig.size()); 
        
        //Test stop here  
        Test.stopTest();  
    }
    
    /**
      * @Description    :   Method to check functionality of createTopics
      *
      * @args           :   
      *
      * @return         :   void
      *
    **/
    static testMethod void testCreateTopicsOnUpdate() {
         
        RecordType rdType = [Select DeveloperName, Id From RecordType where sObjectType = 'Intranet_Item__c' AND isActive = true AND DeveloperName = 'Settings_Office' LIMIT 1];

        //List of Intranet Container 
        List<Intranet_Container__c> listIntranetContainers = new List<Intranet_Container__c>();
        listIntranetContainers.add(new Intranet_Container__c(Name = 'Test-1' ,
                                                             CurrencyIsoCode = 'USD' ,
                                                             Content_Types_Allowed__c = 'A;B;C;D;E;F',
                                                             Display_Name__c='Testing'));
                                                             
        listIntranetContainers.add(new Intranet_Container__c(Name= 'Test-2' , 
                                                             CurrencyIsoCode = 'USD' ,
                                                             Content_Types_Allowed__c = 'A;B;C;D;E;F',
                                                             Display_Name__c='TestingABC'));
                                                              
        //Insert Intranet container 
        insert listIntranetContainers ;
        
        //List of ineternet items
        List<Intranet_Item__c> listIntranetItems = new List<Intranet_Item__c>();
        listIntranetItems.add(new Intranet_Item__c(Name = 'Test0', Active_Status__c = 'Active' , Item_Title__c = 'A' ,
                                                                    RecordTypeId = rdType.Id ,
                                                                    Category_Name__c = 'A',
                                                                    Item_Type__c = 'A', Office_Short_Name__c = 'A' ));
                                                                    
        listIntranetItems.add(new Intranet_Item__c(Name = 'Test1', Active_Status__c = 'Active' , Item_Title__c = 'B' ,
                                                                    RecordTypeId = rdType.Id ,
                                                                    Category_Name__c = 'B',
                                                                    Item_Type__c = 'B', Office_Short_Name__c = 'B'));
                                                                    
        listIntranetItems.add(new Intranet_Item__c(Name = 'Test2', Active_Status__c = 'Active' , Item_Title__c = 'C' ,
                                                                    RecordTypeId = rdType.Id ,
                                                                    Category_Name__c = 'C',
                                                                    Item_Type__c = 'C', Office_Short_Name__c = 'C'));
                                                                    
        listIntranetItems.add(new Intranet_Item__c(Name = 'Test3', Active_Status__c = 'Active' , Item_Title__c = 'D',
                                                                    RecordTypeId = rdType.Id ,
                                                                    Category_Name__c = 'D',
                                                                    Item_Type__c = 'D', Office_Short_Name__c = 'D'));
                                                                    
        listIntranetItems.add(new Intranet_Item__c(Name = 'Test4', Active_Status__c = 'Active', Item_Title__c = 'E',
                                                                    RecordTypeId = rdType.Id,
                                                                    Category_Name__c = 'E',
                                                                    Item_Type__c = 'E', Office_Short_Name__c = 'E'));
                                                                    
        listIntranetItems.add(new Intranet_Item__c(Name = 'Test5', Active_Status__c = 'Active', Item_Title__c = 'F',
                                                                    RecordTypeId = rdType.Id,
                                                                    Category_Name__c = 'F', Office_Short_Name__c = 'F'));                                                           
        
        system.runAs(new User(Id = userInfo.getUserId())) {
            //Insert Intranet items
            insert listIntranetItems ;
        }
        
        //Unique String
        String divisionText = 'TEST_DIVISION_UNIQUE';
        String functionText = 'TEST_FUNCTION_UNIQUE';
        
        //List of Intranet schedule 
        List<Intranet_Schedule__c> listIntranetSchedules = new List<Intranet_Schedule__c>();
        listIntranetSchedules.add(new Intranet_Schedule__c(Name = 'Testabcd', Intranet_Container__c = listIntranetContainers[0].Id,
                                                                              Intranet_Item__c = listIntranetItems[0].Id,
                                                                              Office__c = listIntranetItems[0].Id,
                                                                              Function__c = functionText,
                                                                              Division__c = divisionText,
                                                                               Start_Date_Time__c = Date.Today(),
                                                                               End_Date_Time__c = Date.Today() + 1));
        
                                                                         
        listIntranetSchedules.add(new Intranet_Schedule__c(Name = 'Test1' , Intranet_Container__c = listIntranetContainers[1].Id,
                                                                            Intranet_Item__c = listIntranetItems[1].Id,
                                                                            Office__c = listIntranetItems[1].Id,
                                                                            Function__c = functionText + '1',
                                                                            Division__c =  divisionText + '1',
                                                                            Start_Date_Time__c = Date.Today(),
                                                                            End_Date_Time__c = Date.Today() + 1));
                                                                        
        listIntranetSchedules.add(new Intranet_Schedule__c(Name = 'Test2' , Intranet_Container__c = listIntranetContainers[0].Id,
                                                                            Intranet_Item__c = listIntranetItems[2].Id,
                                                                            Office__c = listIntranetItems[2].Id,
                                                                            Function__c = functionText + '2',
                                                                            Division__c = divisionText + '2',
                                                                            Start_Date_Time__c = Date.Today(),
                                                                            End_Date_Time__c = Date.Today() + 1));
                                                                        
        listIntranetSchedules.add(new Intranet_Schedule__c(Name = 'Test3' , Intranet_Container__c = listIntranetContainers[0].Id,
                                                                            Intranet_Item__c = listIntranetItems[3].Id,
                                                                            Office__c = listIntranetItems[3].Id,
                                                                            Function__c = functionText + '3',
                                                                            Division__c = divisionText + '3',
                                                                            Start_Date_Time__c = Date.Today(),
                                                                            End_Date_Time__c = Date.Today() + 1));
                                                                        
        listIntranetSchedules.add(new Intranet_Schedule__c(Name = 'Test4' , Intranet_Container__c  = listIntranetContainers[0].Id,
                                                                            Intranet_Item__c = listIntranetItems[4].Id,
                                                                            Office__c = listIntranetItems[4].Id,
                                                                            Function__c = functionText + '4',
                                                                            Division__c = divisionText + '4',
                                                                            Start_Date_Time__c = Date.Today(),
                                                                            End_Date_Time__c = Date.Today() + 1));
                                                                               
        System.runAs(new User(Id = userInfo.getUserId())) { 
            //insert Intranet schedule 
            insert listIntranetSchedules;    
        }      
        
         //Assert for results for topics for Office & Function & Divvson  
        List<Topic> listOfTopics = [SELECT Id FROM Topic]; 
        system.assertEquals(15 , listOfTopics.size());   
        
        //Assert for topic Assignmnet
        List<TopicAssignment> listOfTopicAssig = [SELECT Id , EntityId , TopicId FROM TopicAssignment 
                                                                                 WHERE EntityId IN: listIntranetItems 
                                                                                 AND TopicId IN: listOfTopics];
        system.assertEquals(15 , listOfTopicAssig.size());   
        
        
        //Test start here    
        Test.startTest(); 
        
        //Update Intranet schedule
        listIntranetSchedules[0].Office__c = null;
        listIntranetSchedules[1].Function__c = '';
        listIntranetSchedules[2].Division__c = '';
        listIntranetSchedules[3].Office__c = listIntranetItems[5].Id;
        
        update listIntranetSchedules;
        
        //Test stop here  
        Test.stopTest();  
    	
    	//Assert for results
        listOfTopics = [SELECT Id FROM Topic]; 
        System.assertEquals(16 , listOfTopics.size()); 
            
        listOfTopicAssig = [SELECT Id , EntityId , TopicId FROM TopicAssignment 
                                                           WHERE EntityId IN: listIntranetItems 
                                                           AND TopicId IN: listOfTopics];
        System.assertEquals(12 , listOfTopicAssig.size()); 
    }
    
    //This method is to test the valid content types
    static testMethod void testValidContentTypes() {
    	
    	//Create Test data
    	Intranet_Container__c intranetContainer = new Intranet_Container__c(Name = 'Test-1', CurrencyIsoCode = 'USD', Content_Types_Allowed__c = 'App Link', Display_Name__c = 'Testing');
    	insert intranetContainer;
    	
    	Intranet_Item__c intranetItem = new Intranet_Item__c(Name = 'Test-0' , Active_Status__c = 'Active' , Item_Type__c = 'App Link 1' , Item_Title__c = 'A1');
    	insert intranetItem;
    	
    	//Create Schedule record
    	Intranet_Schedule__c intranetSchedule = new Intranet_Schedule__c(Name = 'Test' , Intranet_Container__c = intranetContainer.Id, Intranet_Item__c = intranetItem.Id, Start_Date_Time__c = Date.Today(), End_Date_Time__c = Date.Today() + 1);
    	
    	//Start Testing from here
    	Test.startTest();
    	
    	//try inserting intranetSchedule record, it should throw exception
    	try {
    		insert intranetSchedule;
    		
    		//Fail test method if it gets passed
    		System.assert(false);
    	} catch(Exception e) {
    		
    		//Check if it contains the valid message
    		System.assert(e.getMessage().contains(IntranetScheduleTriggerHelper.ERROR_INVALID_ITEM_TYPE));
    	}
    	
    	//Update the Item_Type__c to a valid value and then update the record
    	intranetItem.Item_Type__c = 'App Link';
    	update intranetItem;
    	
    	//try inserting intranetSchedule record, it should not throw any exception
    	try {
    		insert intranetSchedule;
    		
    	} catch(Exception e) {
    		
    		//Check if it contains the valid message
    		System.assert(false);
    	}
    	
    	//Update the Item_Type__c to a valid value and then update the record
    	intranetItem.Item_Type__c = 'App Link 1';
    	update intranetItem;
    	
    	//try updating intranetSchedule record, it should throw exception
    	try {
    		update intranetSchedule;
 
    		//Fail test method if it gets passed
    		System.assert(false);
    	} catch(Exception e) {
    		
    		//Check if it contains the valid message
    		System.assert(e.getMessage().contains(IntranetScheduleTriggerHelper.ERROR_INVALID_ITEM_TYPE));
    	}
		
		//Stop testing here
		Test.stopTest();
    }
}