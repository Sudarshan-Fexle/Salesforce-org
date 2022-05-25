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


/*
*    Description     :    The class is used to as test class for Deployement Wizard controller 
*
*    Created By      :    Ishan Arora
*
*    Created Date    :    13/04/2018
*
*    Revision Logs   :     V_1.0 - Created
*
*/

@isTest(seeAllData = false)
public class Test_CreateApexTestDependency {
 
    //Set up test data
    @testSetup static void setup() {
    
     //Setup connection custom setting data
        List<Connection__c>  conData = new List<Connection__c>();
        
        Connection__c con = new Connection__c();
        con.Name = 'Self Connection';
        con.Org_type__c = 'Sandbox';
        con.Refresh_Token__c = 'sfkjshfkjshfisjkdhfslkdf';
        con.Instance_URL__c = Url.getSalesforceBaseUrl().toExternalForm();
        conData.add(con);
        
        con = new Connection__c();
        con.Name = 'Connection 1';
        con.Org_type__c = 'Sandbox';
        con.Refresh_Token__c = 'sfkjshfkjshfisjkdhfslkdf';
        con.Instance_URL__c = 'Https://eab.my.salesforce.com';
        conData.add(con);
        
        con = new Connection__c();
        con.Name = 'Connection 2';
        con.Org_type__c = 'Sandbox';
        con.Refresh_Token__c = 'sfkjshfkjshfisjkdhfslkdf';
        con.Instance_URL__c = 'Https://eab.my.salesforce.com';
        conData.add(con);
        
        //Insert Connections
        insert conData;
    }
    
    /**  @description    :  Meathod to test CreateApexTestDependency
	*
	*  @args           	 :  none
	*
	*  @return         	 :  void
	*
	**/
    public static testMethod void testSaveDependencies(){
        
        Test.startTest();
        
        //Set mock heep class
       	Test.setMock(HttpCalloutMock.class, new Test_CreateApexTestDependencyMock());    
	
        //Initialize class object
        CreateApexTestDependency obj = new CreateApexTestDependency();
        //Call method to get and save dependencies
        obj.saveDependencies();
        
        //List to get saved records from object Apex_Test_Dependency__c
        List<Apex_Test_Dependency__c> records = [Select Id from Apex_Test_Dependency__c];
        
        //Assert forinserted records
        if(records.size() > 0)
            System.assert(true);
        else
            System.assert(false);
        
        
    	Test.stopTest();
        
    }
    

}