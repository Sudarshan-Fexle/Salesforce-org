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
  *   Purpose         :     Test class for CRActionItemExtension
  *            
  *   Create By       :     Saurabh Kumar  
  * 
  *   Created Date    :     02/15/2017
  *
  *   Revision Log    :     V_1.0 - Created - CR-20170216-10698
  * 						
  *   Coverage        :     100%
  **/
@isTest(seeAllData = false)
private class Test_CRActionItemExtension {
	
    /**
     * 	Description	:	Test method to test CRActionItemExtension 
     * 
     * 	@argu		:	
     * 
     * 	@return		:	Void
     **/
    static testMethod void unitTest(){
        
        //Query on record type
        List<RecordType> recordTypes = [Select Id, DeveloperName From RecordType Where sObjectType = 'CR_Action_Item__c' 
                                        Order by DeveloperName ASC];
        
        //Start testing frrom here
        Test.startTest();
        
        //Assertion on record types
        System.assert(recordTypes != null);
        System.assertEquals(2, recordTypes.size());
        System.assertEquals('Deployment_Plan_Step', recordTypes[0].DeveloperName);
        System.assertEquals('Issue', recordTypes[1].DeveloperName);
        
        //Initialization of standard controller
        ApexPages.StandardController sc = new ApexPages.StandardController(new CR_Action_Item__c());
        ApexPages.currentPage().getParameters().put('RecordType', recordTypes[0].Id);
        
        //Instantiate the controller
        CRActionItemExtension extension = new CRActionItemExtension(sc);
        
        //Calling extension method
        PageReference pageReference = extension.redirect();
        System.assert(pageReference != null);
        
        ApexPages.currentPage().getParameters().put('RecordType', recordTypes[1].Id);
        
        //Reinstantiate the controller
        extension = new CRActionItemExtension(sc);
        
        //Calling extension method
        pageReference = extension.redirect();
        System.assert(pageReference != null);
        
        //Stop testing here
        Test.stopTest();
    }
}