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
 *  Description     :   This class is used to check the functionality of ObjectsAccessValidatorController
 * 
 *  Created By      :   Dipesh Gupta  
 * 
 *  Created Date    :   07/31/2017
 * 
 *  Revision Logs   :   V_1.0 - Created - CR-20170109-10600
 * 						V_1.1 - Modified by Rajeev Jain - 28/11/2018 Release-PSA Re-Launch Project
 *
 **/ 

 
@isTest
private class ObjectsAccessValidatorControllerTest {
  
    // Modified by Rajeev Jain - 28/11/2018 Release-PSA Re-Launch Project
  @testSetup static void setup() {

    //Bypass Dupeblocker
    Util.IsTest(true);

    
    //Create a user for running the process
        Profile pfile1 = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        
        User user1 = testUtilities.CreateNewUser(pfile1, false);
        user1.IsActive = true;
       insert user1;
            
        //Create a user for running the process
        //Modified by Rajeev Jain - 28/11/2018 Release-PSA Re-Launch Project
        Profile pfile2 = [SELECT Id FROM Profile WHERE Name = 'Boardroom - App Subscription User' LIMIT 1];
        User user2 = testUtilities.CreateNewUser(pfile2, false);
        user2.IsActive = true;
        user2.LastName = 'PsaUser';
        insert user2;
      
    }

    //Test method to test the fi=unctionality of ObjectsAccessValidatorController  checkForObjectsCreateAccess method.  
    static testMethod void myUnitTest() {      
          
        //Inserting Account
        Account acc = TestUtilities.CreateNewAccount(true);
        
        //Creating a record of Program packge royall and HD.
        List<Program_Package__c> programPackage = new List<Program_Package__c>();
        
        programPackage.add(new Program_Package__c(Name='test', Account__c = acc.Id, Fiscal_Year__c = '2017'));
        insert programPackage;
        
        
        //Inserting royall Program object
        List<Royall_Program__c> royallProgram = new List<Royall_Program__c>();
        
        royallProgram.add(New Royall_Program__c(Name = 'Test', Program_Package__c = programPackage[0].Id, Target_Audience_New__c = 'Advancement Accounts', 
                            Campaign_New__c = 'Discount - No Campaign', Type__c = 'Up-sell', Status__c = 'Opportunity', 
                            Contact_Quantity__c = 1, Probability__c = 1, Discount__c = true, Discount_Reason__c = 'Client Retention Tool' ));
                            
        insert royallProgram;
         
        //Query on the user
        List<User> user = [Select Id From User Where IsActive = true ORDER BY LastName ASC];
        system.debug('user---'+user);
        
        system.runAs(user[1]) {
        
          //Calling the methos of class
          //Boolean isAccessible = ObjectsAccessValidatorController.checkForObjectsCreateAccess(programPackage[0].Id, //'Program_Package__c', 'Royall_Program__c');             
             //Check for programPackage size
             if(programPackage.size() > 0) {
             	
                 try { 
                     //Calling method while used to clone the program package and royall progrm record
                     //Id newRecordId = ObjectsAccessValidatorController.cloneWithProgram(programPackage[0].Id);
                     
                     //Query on the program package object toi get the updated list pof Program Package.
                     List<Program_Package__c> updatedListOfProgram = [Select Id,Name From Program_Package__c order By CreatedDate];
                     
                     //system.assertEquals(2, updatedListOfProgram.size());
                     //system.assertEquals(newRecordId, updatedListOfProgram[1].Id);
                     //system.assertEquals('test', updatedListOfProgram[0].Name);
                     //system.assertEquals('test', updatedListOfProgram[1].Name);
                     
                     
                     //Checking the royall program 
                     list<Royall_Program__c> royallPrograms = [Select Id, Name From Royall_Program__c order By CreatedDate];
                     
                     //system.assert(royallPrograms.size() > 0);
                     //system.assertEquals(2, royallPrograms.size());
                     //system.assertEquals( '1799', royallPrograms[0].Name);   
                     //system.assertEquals( '1799', royallPrograms[1].Name);
                 } catch(Exception e) { }
        	}
        }
      
      /* system.runAs(user[0]) {
        
          //Calling the methos of class
          Boolean isAccessible = ObjectsAccessValidatorController.checkForObjectsCreateAccess(programPackage[0].Id, 'Program_Package__c', 'Royall_Program__c');
        
             system.assertEquals(false, isAccessible);
             
        }*/
  }
}