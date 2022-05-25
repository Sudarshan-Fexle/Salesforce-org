/**
*  Description     :    This is controller class for MailRoomManagementSystemController
*
*  Created Date    :    07/26/2021   
* 
*  Revision Logs   :   V_1.0 - Created By - Mahendar Swarnkar - CR-20210921-15452                      
**/

@IsTest
private class Test_MyEABBoardRoomModalPopupController {

    static testMethod void test_Method1(){
        //Bypassing trigger so then test data can be created
        Util.byPassAllTriggers = true;
        Util.isTest(true);
        
        // query custom metaData
        List<My_EAB_BoardRoom_Mapping__mdt> listMappingRecords = [Select ID, Active__c, Category__c, Identifier__c, Redirect_URL__c 
                                                                   From My_EAB_BoardRoom_Mapping__mdt 
                                                                   WHERE Active__c = true ORDER BY Category__c];
        
        Test.startTest();
        PageReference pageRef = Page.CaseRequest; 

        Test.setCurrentPage(pageRef);
        MyEABBoardRoomModalPopupController controller = new MyEABBoardRoomModalPopupController();
        controller.init();
        System.assertEquals(true, controller.showPopUp);
        
        controller.myEABBoardRoomModalcurrentvfpage = 'CaseRequest';
        controller.init();
        System.assertEquals(true, controller.showPopUp);
        
        controller.myEABBoardRoomModalcurrentvfpage = listMappingRecords[0].Identifier__c;
        controller.init();
        System.assertEquals(true, controller.showPopUp);
        
        Test.stopTest();
    }
}