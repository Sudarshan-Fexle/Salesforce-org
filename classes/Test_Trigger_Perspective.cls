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
@isTest(seeAllData = false)
private class Test_Trigger_Perspective {
    
    /**
    *   Purpose         :   Test class for Trigger_Perspective
    *            
    *   Create By       :   Subhash Garhwal
    *
    *   Created Date    :   06/27/2015
    *
    *   Revision Log    :   V_1.0 - Created - CR-20150618-9014
    *                   :   V_1.1 - Modified - Rajeev Jain - CR-20151120-9402 - 04/19/2016 - Removed usage of testIncentiveChangeLog
    * 
    *   Coverage        :   V_1.0 - 100%
    **/
    
    //Test method to test validatePerspective methods functionality
    static testMethod void myUnitTest() {
        
        //List of Perspective
        List<Perspective__c> perspectives = new List<Perspective__c>();
        
        //Add new Perspectives in list
        perspectives.add(new Perspective__c(Name = 'Test Perspective 1', Short_Name__c = 'test1211', Active__c = true));
        perspectives.add(new Perspective__c(Name = 'Test Perspective 2', Short_Name__c = 'test1212', Active__c = true));
        perspectives.add(new Perspective__c(Name = 'Test Perspective 3', Short_Name__c = 'test1213', Active__c = true));
        
        //Start testing from here
        Test.startTest();
        
        //Insert
        insert perspectives;
        
        //Update Perspectives Name
        perspectives[0].Name = 'Test Perspective 3';
        
        try {
            
            //Update perspectives
            update perspectives;
            
        } catch(Exception e) {
            
            //Assert
            System.assert(e.getMessage().contains(Label.DUPLICATE_PERSPECTIVE));        
        }
        
        //Stop Testing here
        Test.stopTest();
    }
    
    //Test method to test validateBeforeDelete methods functionality
    static testMethod void myUnitTest1() {
        
        //List of Program Groups
        List<Program_Group__c> programGroups = new List<Program_Group__c>();
        
        //Add new Program Groups in list
        programGroups.add(new Program_Group__c(Name = 'Test PG 1', Effective_Start__c = System.today().addDays(-3), Effective_End__c = System.today(),
                                               Short_Name__c = 'test1211', Active__c = true));
        
        programGroups.add(new Program_Group__c(Name = 'Test PG 2', Effective_Start__c = System.today().addDays(-5), Effective_End__c = System.today(),
                                               Active__c = true));
        
        //Insert
        insert programGroups;
        
        //Assert
        System.assert(programGroups.size() > 0);
        
        //List of Perspective
        List<Perspective__c> perspectives = new List<Perspective__c>();
        
        //Add new Perspective record in list
        perspectives.add(new Perspective__c(Name = 'Test Perspective 1', Short_Name__c = '1232Test230', Active__c = true));
        perspectives.add(new Perspective__c(Name = 'Test Perspective 2', Short_Name__c = '1332Test230', Active__c = true));
        
        //Insert
        insert perspectives;
        
        //Assert
        System.assert(perspectives.size() > 0);
        
        //List of Program Perspective
        List<Program_Perspective__c> programPerspectives = new List<Program_Perspective__c>();
        
        //Add new Program Perspective in list
        programPerspectives.add(new Program_Perspective__c(Name = 'Test PP 1', Program_Group__c = programGroups[0].Id, Perspective__c = perspectives[0].Id,
                                                           Effective_Start__c = System.today(), Effective_End__c = System.today().addDays(4), Active__c = true, In_use_Plans_Direct__c = 2));
        
        programPerspectives.add(new Program_Perspective__c(Name = 'Test PP 1', Program_Group__c = programGroups[1].Id, Perspective__c = perspectives[1].Id,
                                                           Effective_Start__c = System.today(), Effective_End__c = System.today().addDays(4), Active__c = true));
        
        programPerspectives.add(new Program_Perspective__c(Name = 'Test PP 1', Program_Group__c = programGroups[0].Id, Perspective__c = perspectives[1].Id,
                                                           Effective_Start__c = System.today(), Effective_End__c = System.today().addDays(4), Active__c = true));
        
        //Insert
        insert programPerspectives;
        
        //Assert
        System.assert(programPerspectives.size() > 0);
        
        //Start testing from here
        Test.startTest();
        
        //Delete Perspective__c
        delete perspectives[1];
        
        //Query through Perspective__c
        List<Perspective__c> perspective = [Select Id From Perspective__c];
        
        //Assert for result
        System.assertEquals(1, perspective.size());
        
        try {
            
            //Delete Perspective__c
            delete perspective;
            
        } catch(Exception e) {
            
            //Assert for result
            System.assert(e.getMessage().contains(Label.PERSPECTIVE_IN_USE));       
        }
        
        //Stop Testing here
        Test.stopTest();
    }
    
    //Test method to test  incentiveChangeLogmethods functionality
    /*static testMethod void testIncentiveChangeLog(){
    
        //List of Perspective
        List<Perspective__c> perspectives = new List<Perspective__c>();
        
        //Add new Perspective record in list
        perspectives.add(new Perspective__c(Name = 'Test Perspective 1', Short_Name__c = '1232Test230', Active__c = true));
        perspectives.add(new Perspective__c(Name = 'Test Perspective 2', Short_Name__c = '1332Test231', Active__c = true));
        perspectives.add(new Perspective__c(Name = 'Test Perspective 3', Short_Name__c = '1232Test232', Active__c = true));
        perspectives.add(new Perspective__c(Name = 'Test Perspective 4', Short_Name__c = '1332Test233', Active__c = true));
        
        //Insert
        insert perspectives;
        
        //start Testing here
        Test.startTest();
        
        //Assert for result
        System.assertEquals(4, perspectives.size());
        
        //Update perspective
        update perspectives;
        
        //Query Through Incentive Change Log
        List<Incentive_Change_Log__c> incentives = [Select Id, Name, Perspective__c From Incentive_Change_Log__c Where Perspective__c IN : perspectives];
        
        //Assert for result
        System.assertEquals(0, incentives.size());
        
        //Update perspective short name
        perspectives[0].Short_Name__c = 'update short name';
        perspectives[1].Name = 'Update name';
        
        //Update perspective
        update perspectives;
        
        //Query Through Incentive Change Log
        incentives = [Select Id, Name, Perspective__c From Incentive_Change_Log__c Where Perspective__c IN: perspectives];
        
        //Assert for result
        System.assertEquals(1, incentives.size());
        
        
        //Stop Testing here
        Test.stopTest();    
    }*/

}