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
 //V1.1 Modified By - Rajiv Jain - 19/02/2020 - CR-20200130-13677  -  Remove zzzCurrent Status(Current_Status__c) and zzzReason(Reason__c) field of IS_System__c object.
@isTest
private class testChangeRequestUtilities {
    
    static testMethod void testISSystem_PartialOut() {
        
        // create a new Change Req
        
        SFDC_Change_Request__c CR = testUtilities.CreateChangeRequest(false);
        CR.Functionality__c = 'Partial';
        insert CR;
        
        // get the updated IS System
        
        // ------ Start ----  V1.1 Modified By - Rajiv Jain - 19/02/2020 - CR-20200130-13677  -  Remove zzzCurrent Status(Current_Status__c) field.
        IS_System__c ISS = [SELECT Name, Id /*Current_Status__c*/ FROM IS_System__c WHERE Id = :CR.IS_System__c];
        //system.assertEquals('Partial Out', ISS.Current_Status__c);
        //-------End------
        
    }
    
    static testMethod void testISSystem_AllOut() {
        
        Test.startTest();
        
        // create a new Change Req
        
        SFDC_Change_Request__c CR = testUtilities.CreateChangeRequest(true);
        
        update CR;
        
        Test.stopTest();
        
        // ------ Start ----  V1.1 Modified By - Rajiv Jain - 19/02/2020 - CR-20200130-13677  -  Remove zzzCurrent Status(Current_Status__c) field.
        // get the updated IS System   
        IS_System__c ISS = [SELECT Name, Id /*Current_Status__c*/ FROM IS_System__c WHERE Id = :CR.IS_System__c];
        //system.assertEquals('All Out', ISS.Current_Status__c);
        //-------End------
    }
    
    static testMethod void testISSystem_AllOut2() {
        
        // create a new Change Req
        Id sysOutageRTId = Util.RecordTypeId('SFDC_Change_Request__c', 'System Outage');
        SFDC_Change_Request__c CR = testUtilities.CreateChangeRequest(true);
        
        // create a new Change Req
        SFDC_Change_Request__c CR2 = testUtilities.CreateChangeRequest(false);
        CR2.Functionality__c = 'Partial';
        CR2.IS_System__c = CR.IS_System__c;
        CR2.Title__c = 'Maintenance';
        insert CR2;
        
        // ------ Start ----  V1.1 Modified By - Rajiv Jain - 19/02/2020 - CR-20200130-13677 -  Remove zzzCurrent Status(Current_Status__c) field.
        // get the updated IS System
        IS_System__c ISS = [SELECT Name, Id /*Current_Status__c*/ FROM IS_System__c WHERE Id = :CR.IS_System__c];
        //system.assertEquals('All Out', ISS.Current_Status__c);
        //-------End------
        
    }
    
    static testMethod void testISSystem_AllOut3() {
        // create a new is system
        IS_System__c ISS = new IS_System__c();
        ISS.Name = 'Servers';
        insert ISS;
        
        IS_System__c ISS2 = new IS_System__c();
        ISS2.Name = 'Email';
        ISS2.Primary_System__c = ISS.Id;
        //ISS2.Reason__c = 'because';
        insert ISS2;
        
        // create a new Change Req
        SFDC_Change_Request__c CR = testUtilities.CreateChangeRequest(false);
        CR.IS_System__c = ISS.Id;
        insert CR;
        
        // ------ Start ----  V1.1 Modified By - Rajiv Jain - 19/02/2020 - CR-20200130-13677 -  Remove zzzCurrent Status(Current_Status__c) field.
        // get the updated IS System
        ISS2 = [SELECT Name, Id /*Current_Status__c*/ FROM IS_System__c WHERE Id = :ISS2.Id];
        //system.assertEquals('All Out', ISS2.Current_Status__c);
        //-------End------
    }
    
    static testMethod void testISTeamInvolved() {
        Util.IsTest(true);
        
        // create a new Change Request
        SFDC_Change_Request__c CR = testUtilities.CreateChangeRequest(true);
        
        User sysAdmin = [SELECT Name, Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true AND Name != 'Salesforce Administrator' AND FirstName != 'Salesforce' LIMIT 1];
        
        // create a new user
        
        User u = TestUtilities.CreateNewUser(false);
        u.FirstName = 'Roger';
        u.LastName = 'Smith';
        insert u;
        
        // run as the sys admin user
        
        system.runAs(sysAdmin) {
            
            // create a request comment
            
            SFDC_Request_Comment__c comment = testUtilities.CreateRequestComment(CR.Id, u.Id, false);
            insert comment;
        }
        
        // get the updated Change Request
        
        CR = [SELECT Id, IS_Team_Involved__c FROM SFDC_Change_Request__c WHERE Id = :CR.Id];
        u = [SELECT Name FROM User WHERE Id = :u.Id];
        
        // make sure the user's name is in the IS Team Involved field
        
        system.assertEquals(u.Name, CR.IS_Team_Involved__c);
        
    }
    
    static testMethod void testDataBase() {
        
        //Query on record type for SFDC_Release__c
        List<RecordType> recordTypesForRelease = [Select Id, DeveloperName From RecordType Where sObjectType = 'SFDC_Release__c'
                                                  Order by DeveloperName ASC];
        
        //Assertion on record types for SFDC_Release__c
        System.assert(recordTypesForRelease != null);
        System.assertEquals(2, recordTypesForRelease.size());
        System.assertEquals('eTech_Dev', recordTypesForRelease[1].DeveloperName);
        
        //Query on record type for SFDC_Change_Request__c
        List<RecordType> recordTypesForCR = [Select Id, DeveloperName From RecordType Where sObjectType = 'SFDC_Change_Request__c'
                                             Order by DeveloperName ASC];
        
        //Assertion on record types for SFDC_Change_Request__c
        System.assert(recordTypesForCR != null);
        System.assertEquals(6, recordTypesForCR.size());
        System.assertEquals('Level_I', recordTypesForCR[1].DeveloperName);
        System.assertEquals('Level_II', recordTypesForCR[2].DeveloperName);
        System.assertEquals('Level_III', recordTypesForCR[3].DeveloperName);
        
        //Query on record type for Cr_Action_Item__c
        List<RecordType> recordTypesForCrActionItem = [Select Id, DeveloperName From RecordType Where sObjectType = 'CR_Action_Item__c'
                                                       Order by DeveloperName ASC];
        //Assertion on record types for Cr_Action_Item__c
        System.assert(recordTypesForCrActionItem != null);
        System.assertEquals(2, recordTypesForCrActionItem.size());
        System.assertEquals('Deployment_Plan_Step', recordTypesForCrActionItem[0].DeveloperName);
        
        //Query on record type for IS_System_Modification__c
        List<RecordType> recordTypesForModification = [Select Id, DeveloperName From RecordType Where sObjectType = 'IS_System_Modification__c'
                                                       Order by DeveloperName ASC];
        
        //Assertion on record types for IS_System_Modification__c
        System.assert(recordTypesForModification != null);
        System.assertEquals(9, recordTypesForModification.size());
        System.assertEquals('Complex', recordTypesForModification[2].DeveloperName);
        System.assertEquals('Simple', recordTypesForModification[8].DeveloperName);
        
        //Query on record type for IS_System_Component__c
        List<RecordType> recordTypesForIsSystemComponent = [Select Id, DeveloperName From RecordType Where sObjectType = 'IS_System_Component__c'
                                                            Order by DeveloperName ASC];
        
        //Assertion on record types
        System.assert(recordTypesForIsSystemComponent != null);
        System.assertEquals(3, recordTypesForIsSystemComponent.size());
        System.assertEquals('Configuration', recordTypesForIsSystemComponent[1].DeveloperName);
        
        // create ISS system
        IS_System__c ISS = new IS_System__c();
        ISS.Name = 'Salesforce';
        insert ISS;
                
        // Create Is System Component Data (RecordType:- Configuration)
        List<IS_System_Component__c> testIsSystemComponentData = new List<IS_System_Component__c>();
        testIsSystemComponentData.add(new IS_System_Component__c(Name = 'TestData', Object_API_Name__c = 'Testing_Data', IS_System__c = ISS.Id,
                                                                 Object_Label__c ='Testing_Data', Object_Type__c = 'Custom Label',
                                                                 RecordTypeId = recordTypesForIsSystemComponent[1].Id));
        insert testIsSystemComponentData;
        
        // Modified - Dipesh Gupta - 2/27/2020 - CR-20191216-13564 Start Here 
        //Query on Profile
        Profile profile1 = [Select Id, Name From Profile Where name = 'System Administrator' LIMIT 1];
        
        // hold User
        User usr = new User(LastName = 'test',
                           FirstName='testing',
                           Alias = 'test',
                           Email = 'test@asdf.com',
                           Username = 'testing@asdf.com',
                           ProfileId = profile1.id,
                           IsActive = true,
                           TimeZoneSidKey = 'GMT',
                           LanguageLocaleKey = 'en_US',
                           EmailEncodingKey = 'UTF-8',
                           LocaleSidKey = 'en_US'
                           );
        
        //Insert User
        insert usr;
        
        // IS_Environment__c 1
        IS_Environment__c is_environment = new IS_Environment__c();
        is_environment.Name = 'Dev2 - Active';
        is_environment.Environment_Type__c = 'Development';
        is_environment.Status__c = 'Active';
        insert is_environment;
        
        List<IS_Environment__c> devEnv = [Select Id From IS_Environment__c];
        System.assert(devEnv[0].Id != null);
        System.assert(devEnv.size() > 0);
        
        // IS_Environment__c 2
        IS_Environment__c is_environment2 = new IS_Environment__c();
        is_environment2.Name = 'Full2 - Active';
        is_environment2.Environment_Type__c = 'UAT';
        is_environment2.Status__c = 'Active';
        insert is_environment2;
        
        List<IS_Environment__c> devEnv2= [Select Id From IS_Environment__c];
        System.assert(devEnv2[1].Id != null);
        System.assert(devEnv.size() > 0);
        
		// CR-20200130-13677 Start Here : For Test Class Fix during deploy 
        // Create Release Data
        List<SFDC_Release__c> testReleaseData = new List<SFDC_Release__c>();
        testReleaseData.add(new SFDC_Release__c(Name = 'TestRelease1', Status__c = 'Scheduled - Planned', RecordTypeId= recordTypesForRelease[1].Id, Release_level__c = 'L2', Dev_Sandbox__c = devEnv[0].Id, QA_Sandbox__c = devEnv2[1].Id, UAT_Sandbox__c = devEnv2[1].Id,Environment_Manager__c = usr.Id ,Release_Manager__c = usr.Id));
        testReleaseData.add(new SFDC_Release__c(Name = 'TestRelease2', Status__c = 'Deployed', RecordTypeId= recordTypesForRelease[1].Id, Release_level__c = 'L2', Dev_Sandbox__c = devEnv[0].Id, QA_Sandbox__c = devEnv2[1].Id, UAT_Sandbox__c = devEnv2[1].Id,Environment_Manager__c = usr.Id ,Release_Manager__c = usr.Id));
        testReleaseData.add(new SFDC_Release__c(Name = 'TestRelease3', Status__c = 'Cancelled', RecordTypeId= recordTypesForRelease[1].Id, Release_level__c = 'L2', Dev_Sandbox__c = devEnv[0].Id, QA_Sandbox__c = devEnv2[1].Id, UAT_Sandbox__c = devEnv2[1].Id,Environment_Manager__c = usr.Id ,Release_Manager__c = usr.Id));
        insert testReleaseData;
        // CR-20200130-13677 Ends Here
        // CR-20191216-13564 Ends Here 
		
        // Create a contact
        Contact con = TestUtilities.CreateNewContact(true);
        
        //System.assert(false, con );
        
      /*  // Create Change Request Data
        List<SFDC_Change_Request__c> testChangeRequestData = new List<SFDC_Change_Request__c>();
        testChangeRequestData.add(new SFDC_Change_Request__c(RecordTypeId = recordTypesForCR[2].Id, CR_Type__c = 'Enhancement',
                                                             Title__c = 'Testing1', Priority__c = 'C - Standard', Status__c = '01-New Request',
                                                             IS_System__c =  ISS.Id, Stage__C='Business Review', Requested_By2__c = con.Id,
                                                             What_Is_The_Business_Need__c = 'Testing Case',
                                                             Users_Affected__c = 'Single Division'));
        insert testChangeRequestData;
        
        // Create Is System Modification
        List<IS_System_Modification__c> testIsSystemModificationData = new List<IS_System_Modification__c>();
        testIsSystemModificationData.add(new IS_System_Modification__c(RecordTypeId = recordTypesForModification[8].Id,
                                                                       Change_Request__c = testChangeRequestData[0].Id,
                                                                       IS_System_Component__c = testIsSystemComponentData[0].Id,
                                                                       Type_of_Modification__c = 'Add',
                                                                       Description__c = 'Add New Custom Label as per CR Requirement' ));
        testIsSystemModificationData.add(new IS_System_Modification__c(RecordTypeId = recordTypesForModification[2].Id,
                                                                       Change_Request__c = testChangeRequestData[0].Id,
                                                                       IS_System_Component__c = testIsSystemComponentData[0].Id,
                                                                       Type_of_Modification__c = 'Modify',
                                                                       Description__c = 'Modified the Custom Label with the new value'));
        insert testIsSystemModificationData; */
    }
    
    static testMethod void testUpdateCurrentStatus() {
        /*// create ISS system
        IS_System__c ISS = new IS_System__c();
        ISS.Name = 'Servers' + crypto.getRandomInteger();
        insert ISS;
        
        // create ISS system
        
        IS_System__c ISS1 = new IS_System__c();
        ISS1.Name = 'Servers' + crypto.getRandomInteger();
        ISS1.Primary_System__c = ISS.Id;
        insert ISS1;
        
        List<IS_System__c> isSystList = [SELECT Id, Name, Primary_System__c FROM IS_System__c];
        system.assertEquals(2, isSystList.size());
        
        ChangeRequestUtilities.UpdateCurrentStatus(isSystList);*/
		
    }
	
	}