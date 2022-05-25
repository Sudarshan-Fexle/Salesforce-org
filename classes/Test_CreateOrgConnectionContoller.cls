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
*    Description     :    The class is used to as test class for create org connection controller
*
*    Created By      :    Ishan Arora
*
*    Created Date    :    08/04/2018
*
*    Revision Logs   :     V_1.0 - Created
*
*/

@isTest(seeAllData = false)
public class Test_CreateOrgConnectionContoller {
    
    /*  @description    :  Meathod to create custom setting data
	*
	*  @args           	:  none
	*
	*  @return         	:   void
	*
	**/
    public static void createTestRecords(){
        
        System.debug('Started');        
        Org_Connector_Config__c orgConfig = new Org_Connector_Config__c();
        orgConfig.SetupOwnerId = '00eC00000016HQP';
        orgConfig.Base_URL_Login__c	= 'https://login.salesforce.com';
        orgConfig.Base_URL_Test__c = 'https://test.salesforce.com';
        orgConfig.Client_Id_URL__c	= 'response_type=code&client_id=';
        orgConfig.Client_Secret_Key__c = '8925104254922037428';
        orgConfig.Connection_Type_Self__c = 'Self';
        orgConfig.Consumer_Key__c = '3MVG9U_dUptXGpYIWl6U3CZVSnm328FAYkPepRbR.ssNcbdf35_nwe0VM9AhU5imA3lDtAiuRKQriLZ4IBPKR';	
        orgConfig.Login_Hint__c	 = 'login_hint=';
        orgConfig.Oath_Token_Url__c	= '.salesforce.com/services/oauth2/token';
        orgConfig.OAuth_URL__c = '/services/oauth2/authorize';
        orgConfig.OrgType_Production_developer__c = 'Production/Developer';
        orgConfig.Prompt_Encoded__c	= 'prompt=login%20consent';
        orgConfig.Redirect_URI__c = 'redirect_uri=';
        orgConfig.Redirect_URL__c = 'https://orgconnector.herokuapp.com/createConnection?cs=hello'	;
        orgConfig.Self_Connection__c = 'Self Connection';
        orgConfig.State_URI__c = 'state='; 
        insert orgConfig;
        
        Org_Connector_Config_Validation__c configValidation = new Org_Connector_Config_Validation__c();
        configValidation.Duplicate_External_Connection__c = 'Connection name already exist,';	
        configValidation.Duplicate_Local_Connection__c	= 'Self Connection already exist.';
        configValidation.Invalid_Connection_Name__c	='Enter valid connection name';
        configValidation.Local_Connection_Absent__c	= 'Create Self Connection to continue';
        configValidation.OrgType_Not_Selected__c	= 'Select org type';
        configValidation.Username_length_error__c = 'Connection Name can have at max 60 characters' ;
        configValidation.SetupOwnerId = '00eC00000016HQP';
        insert configValidation;
        
        list<Org_Connector_Config_Validation__c> x = [Select id from Org_Connector_Config_Validation__c];
        system.debug('sixe'+ x.size());
        
        
    }
    
    /*  @description    :  Meathod to test createorgconnectioncontroller
	*
	*  @args           	:  none
	*
	*  @return         	:   void
	*
	**/
    static testmethod void testConnectionCreator(){
        createTestRecords();
        
        Test.startTest();
        
        //Initilize Class
        Connection__c con = new Connection__c();
        ApexPages.StandardController sc = new ApexPages.StandardController(con);
        CreateOrgConnectionController obj = new CreateOrgConnectionController(sc); 
        
        //Case 0 - org type missing
        obj.connectionType='Self';
        obj.orgType = '';
        obj.connectionName = 'Self Connection';
        PageReference pageRef = obj.createConnection();
        
        //Case 1 - org type missing
        obj.connectionType='Self';
        obj.orgType = 'Sandboz';
        obj.connectionName = '';
        pageRef = obj.createConnection();
        
        
        //Case 2 - name to long
        obj.connectionType='External';
        obj.orgType = 'Sandbox';
        obj.connectionName = 'Self Connectionnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn';
        pageRef = obj.createConnection();
        
        //Case 3 - name missing
        obj.connectionType='External';
        obj.orgType = 'Sandbox';
        obj.connectionName = '';
        pageRef = obj.createConnection();
        
        //Case 5 - create external connection without local connection
        obj.connectionType='External';
        obj.orgType = 'Sandbox';
        obj.connectionName = 'Ishan';
        pageRef = obj.createConnection();
        
        //Case 6 - Create Self connection
        obj.connectionType='Self';
        obj.orgType = 'Sandbox';
        obj.connectionName = 'Self Connection';
        pageRef = obj.createConnection();
        
        Connection__c conData = new Connection__c(Name='Self Connection' , Org_type__c = 'Sandbox');
        insert conData;
        
        //Case 7 -  Duplicate Self connection
        obj.connectionType='Self';
        obj.orgType = 'Sandbox';
        obj.connectionName = 'Self Connection';
        pageRef = obj.createConnection();
        
        //Case 8 - Create external connection
        obj.connectionType='External';
        obj.orgType = 'Sandbox';
        obj.connectionName = 'Ishan';
        pageRef = obj.createConnection();
        //System.debug(pageRef);
        
        // Insert external connection
        conData = new Connection__c(Name='Ishan' , Org_type__c = 'Sandbox');
        insert conData;
        
        // Case 9-Insert external connection duplicate
        obj.connectionType='External';
        obj.orgType = 'Sandbox';
        obj.connectionName = 'Ishan';
       	pageRef = obj.createConnection();
        
        //case - production type connection
        obj.connectionType='External';
        obj.orgType = 'Production/Developer';
        obj.connectionName = 'Ishanx';
       	pageRef = obj.createConnection();
        //System.debug(pageRef);
          
    }
    
}