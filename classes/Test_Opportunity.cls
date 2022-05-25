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
 * 	Description     :   This class is for test triggers of Account.
 *            
 *  Create By       :   Sudarshan Singh
 *
 *  Created Date    :   03/06/2022 
 *
 *  Revision Log    :   V_1.0 - Created - Fexle service
 *
 *  Coverage        :   100%
 *
 **/
@isTest(seeAllData = false)
private without sharing class Test_Opportunity {
    
    @TestSetup
    static void testSetup(){
        
        //Create Opportunity
        List<Opportunity> listOfOpportunity = new List<Opportunity>();
        listOfOpportunity.add(new Opportunity(Name = 'Test 1', CloseDate = Date.today(), StageName = 'Prospecting'));
        listOfOpportunity.add(new Opportunity(Name = 'Test 2', CloseDate = Date.today(), StageName = 'Value Proposition'));
        listOfOpportunity.add(new Opportunity(Name = 'Test 3', CloseDate = Date.today(), StageName = 'Proposal/Price Quote'));
        listOfOpportunity.add(new Opportunity(Name = 'Test 4', CloseDate = Date.today(), StageName = 'Id. Decision Makers'));
        
        //insert opportunities
        insert listOfOpportunity;
    
    }

    
    // @isTest
    // static void updateStageTrackingTest(){

    //     //Fetch opportunities
    //     List<Opportunity> listOfOpportunities = [SELECT Id,Name, StageName, Stage_Tracking__c FROM Opportunity ORDER BY Name];
    //     System.assertEquals('Prospecting', listOfOpportunities[0].Stage_Tracking__c);
    //     System.assertEquals('Value Proposition', listOfOpportunities[1].Stage_Tracking__c);
    //     System.assertEquals('Proposal/Price Quote', listOfOpportunities[2].Stage_Tracking__c);
    //     System.assertEquals('Id. Decision Makers', listOfOpportunities[3].Stage_Tracking__c);


    //     listOfOpportunities[0].StageName = 'Value Proposition';
    //     listOfOpportunities[1].StageName = 'Prospecting';
    //     listOfOpportunities[2].StageName = 'Proposal/Price Quote';
    //     listOfOpportunities[3].StageName = 'Proposal/Price Quote';

    //     //Test start here
    //     Test.startTest();
        
    //     update listOfOpportunities;

    //     List<Opportunity> listOfUpdatedOpportunities = [SELECT Id,Name, StageName, Stage_Tracking__c FROM Opportunity ORDER BY Name];
    //     System.assertEquals('Prospecting ==> Value Proposition', listOfUpdatedOpportunities[0].Stage_Tracking__c);
    //     System.assertEquals('Prospecting ==> Value Proposition', listOfUpdatedOpportunities[1].Stage_Tracking__c);
    //     System.assertEquals('Proposal/Price Quote', listOfUpdatedOpportunities[2].Stage_Tracking__c);
    //     System.assertEquals('Id. Decision Makers ==> Proposal/Price Quote', listOfUpdatedOpportunities[3].Stage_Tracking__c);
        
    //     listOfUpdatedOpportunities[0].StageName = 'Prospecting';
    //     listOfUpdatedOpportunities[3].StageName = 'Prospecting';
    //     update listOfUpdatedOpportunities;

    //     List<Opportunity> listOfNewUpdatedOpportunities = [SELECT Id,Name, StageName, Stage_Tracking__c FROM Opportunity ORDER BY Name];        
    //     System.assertEquals('Prospecting ==> Value Proposition', listOfNewUpdatedOpportunities[0].Stage_Tracking__c);
    //     System.assertEquals('Prospecting ==> Id. Decision Makers ==> Proposal/Price Quote', listOfNewUpdatedOpportunities[3].Stage_Tracking__c);
        
        
    //     //Test stop here
    //     Test.stopTest();

    // }

    
    @isTest
    static void updateStageTrackingTest(){

        //Fetch opportunities
        List<Opportunity> listOfOpportunities = [SELECT Id, StageName, Stage_Tracking__c FROM Opportunity ORDER BY Name];
        listOfOpportunities[0].StageName = 'Value Proposition';
        listOfOpportunities[1].StageName = 'Prospecting';
        listOfOpportunities[2].StageName = 'Value Proposition';
        listOfOpportunities[3].StageName = 'Id. Decision Makers';

        //Test start here
        Test.startTest();
        
        try {
            
            //Update stage name of opportunities
            update listOfOpportunities;

        } catch (Exception e) {

            //Check error is occurs.
            Boolean expectedExceptionThrown =  (e.getMessage().contains('Please select stage above previous stage')) ? true : false; 
            System.AssertEquals(true, expectedExceptionThrown, e.getMessage()); 
        }
        
        Opportunity opp = [SELECT Id, StageName FROM Opportunity WHERE Id =: listOfOpportunities[2].Id];

        opp.StageName = 'Prospecting';
        
        try {

            //Update stage name of opportunity
            update opp;
        } catch (Exception e) {

            //Check error is occurs.
            Boolean expectedExceptionThrown =  (e.getMessage().contains('Please select stage above previous stage')) ? true : false; 
            System.AssertEquals(true, expectedExceptionThrown, e.getMessage()); 
        }

        opp.StageName = 'Closed Won';

        //update opportunity
        update opp;
        
        //Test stop here
        Test.stopTest();

        Opportunity updatedOpportunity = [SELECT StageName FROM Opportunity WHERE Id =: opp.Id];
        System.assertEquals('Closed Won', updatedOpportunity.StageName);

    }
}