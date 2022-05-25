/**
 *  Purpose         :   This class is used to test the OABWarmLeadInfoSiteFormController class
 *
 *  Created By      :   Mahendra Swarnkar
 *
 *  Created Date    :   05/19/2017
 *
 *  Current Version :   V_1.0 Created 
 *                  
 **/
@isTest
public class OABWarmLeadInfoSiteFormController_Test {
    
    static testmethod void unitTest1() {
    
        //Bypassing triggers
        Util.isTest(true);
        Util.byPassAllTriggers = true;
        
        //Account Record
        Account acc = TestUtilities.CreateNewAccount(false);
        acc.Primary_City__c = 'Columbus';
		acc.Primary_State_Province__c = 'OH';
        insert acc;
        
        //Contact Record
        Contact con = TestUtilities.CreateAdvUserContact(acc, false);
        con.Title = 'TestTitle';
        insert con;
        
        //Program record
        Program__c prog = TestUtilities.CreateNewProgram(true);
        
        //Warm lead OAB record type
        List<RecordType> oABRtype = [Select Id From RecordType Where SobjectType = 'Warm_Lead__c' AND DeveloperName = 'OAB']; 
        System.assert(oABRtype.size()>0);
        
        //Create Warm Lead record
        Warm_Lead__c warmLead1 = new Warm_Lead__c (Account__c = acc.Id, Contact__c = con.Id, Primary_Program__c = prog.Id, 
                                                   	Contact_Level__c = 'Director', RecordTypeId = oABRtype[0].Id,
                                                  	Comments__c = 'Test Comments', Next_Step__c = 'Test Next Steps');
        
        //Start Test
        Test.startTest();
        
    	//instantiate the controller and set the page
        ApexPages.standardController standardController = new ApexPages.standardController(warmLead1);
        OABWarmLeadInfoSiteFormController controller = new OABWarmLeadInfoSiteFormController(standardController);
        controller.yourName = 'Test Warmlead';
        controller.isIntroduce = true;
        controller.getAccount();
        controller.getContact();
        controller.validateWarmLeadData();
        
        //Stop Test
        Test.stopTest();
    }
}