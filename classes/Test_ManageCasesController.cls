/**
*    Purpose         :   Controller class for "Manage Cases" VF page, to close the selected Cases  
*                
*    Create By       :   Mahendra Swarnkar
*    
*    Created Date    :   09/05/2016
*    
*    Revision Log    :   V1.0 - Created By - Mahendra Swarnkar - CR-9802 
*   
*    Coverage        :   V1.0 - 95%                 
**/
@isTest(seeAllData=false)
public class Test_ManageCasesController {

    // TO DO: implement unit test
    static testMethod void myUnitTest() {
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        Profile p = [SELECT Id FROM Profile where Name = 'System Administrator' LIMIT 1];
        User u = TestUtilities.CreateNewUser(p , true );
        
        //Setting Custom Setting Data.
        List<Mass_Close_Case__c> customSettMassCaseClose = new List<Mass_Close_Case__c> ();
        
        Mass_Close_Case__c closeCaseEligibilityListUser = Mass_Close_Case__c.getInstance(u.Id);
        closeCaseEligibilityListUser.Close_Cases_Permitted__c = true;
        
        Mass_Close_Case__c closeCaseEligibilityListProfile = Mass_Close_Case__c.getInstance(p.Id);
        closeCaseEligibilityListUser.Close_Cases_Permitted__c = true;
        
        customSettMassCaseClose.add(closeCaseEligibilityListUser);
        customSettMassCaseClose.add(closeCaseEligibilityListProfile);
        insert customSettMassCaseClose;
        
        
        //Create institutions
        Account account = TestUtilities.CreateNewAccount(false);
        account.Account_Formal_Name__c = 'Acc1';
        insert account;
        
        //Assert for the results
        System.assertEquals('Acc1', account.Account_Formal_Name__c);
       
        //create contact
        Contact c = TestUtilities.CreateNewContact(account, true);
        System.assertEquals(account.Id, c.AccountId);
        
        //Querying Details for record types on Case Object
        List<RecordType> caseRdTypes = [SELECT ID, DeveloperName FROM RecordType 
                                        Where sObjectType = 'Case' 
                                        AND IsActive = true 
                                        AND DeveloperName = 'EAB_Custom'
                                        ORDER By DeveloperName ASC];
                
        //Assert for the results
        System.assert(caseRdTypes != null);
        System.assert(caseRdTypes.size() == 1);
        System.assert(caseRdTypes[0].DeveloperName == 'EAB_Custom');
        
        //List to hold the case records
        List<Case> cases = new List<Case>();
        
        //Create a sample case record to insert and test case trigger
        //1.Expert Center Type Case 
        Case aCase_1 = new Case(RecordTypeId = caseRdTypes[0].Id, Origin = 'ABC', Subject = 'Test', 
                                Description = 'Test', ContactId = c.Id, Deadline__c = System.today().addDays(1), Deadline_Reason__c = 'ABC1');
                                
        Case aCase_2 = new Case(RecordTypeId = caseRdTypes[0].Id, Origin = System.Label.ORIGIN_MEMBER_PRIORITY, Subject = 'Test',
                                Description = 'Test', ContactId = c.Id, Deadline__c = System.today().addDays(1), Deadline_Reason__c = 'ABC2');
        
        Case aCase_3 = new Case(RecordTypeId = caseRdTypes[0].Id, Origin = 'ABC', Subject = 'Test',
                                Description = 'Test', ContactId = c.Id, Deadline__c = System.today().addDays(1), Deadline_Reason__c = 'ABC3');
        
        
        //Populating list with case records
        cases.add(aCase_1);
        cases.add(aCase_2);
        cases.add(aCase_3);
        
        //Enabling triggers
        Util.byPassAllTriggers = false;
            
        //Setting the flags
        CaseTriggerHelper.IS_ALREADY_EXECUTED_ONCE = false;
        CaseTriggerHelper.IS_UPDATE_HAPPENS_ON_INSERT_EVENT = false; 
        
        //Insert cases
        insert cases;
        
        System.runAs(u){
            //Start Testing
            Test.startTest();
            
            //Standard controller 
            ApexPages.StandardSetController sc = new ApexPages.StandardSetController(Database.getQueryLocator([Select Id, Deadline__c, Priority From Case]));
            
            //Asserts for results
            System.assertEquals(sc.getRecords().size(), 3);
            
            PageReference pageRef = Page.ManageCloseCases;
            Test.setCurrentPage(pageRef);
            
            //Instance of controller
            ManageCasesController controller = new ManageCasesController(sc);
            
            for(ApexPages.Message msg : ApexPages.getMessages()){
                if(msg.getSeverity() == ApexPages.Severity.ERROR)
                    System.assertEquals(true, msg.getSummary().contains(System.Label.CASE_CLOSE_ERROR_MESSAGE_NO_SELECTED_CASES));
            }
            
            //Call Method
            controller.cancel();
            
            //Re-Instanciate the Standard controller
            sc = new ApexPages.StandardSetController(Database.getQueryLocator([Select Id, Deadline__c, Priority From Case]));
            sc.setSelected(sc.getRecords());
            
            pageRef = Page.ManageCloseCases;
            Test.setCurrentPage(pageRef);
            
            //Re-Instanciate the controller
            controller = new ManageCasesController(sc);
            Boolean eligible = controller.isEligible;
            List<SelectOption> caseReasonOpt = controller.CaseReasonOptions;
            List<SelectOption> caseStatusOpt = controller.CaseStatusOptions;
            controller.selectedStatus = System.Label.CASE_STATUS_90_Closed;
            controller.selectedReason = System.Label.CASE_Reason_EXPERT_CENTER;
            controller.caseInternalComments = 'Test Close Case';
            controller.selectedCasesOnFromListView();
            ///controller.selectedCases = sc.getRecords();
            System.assertEquals(3, controller.selectedCases.size());
            
            //Call Method
            Controller.updateCases();
            
            //Stop Testing
            Test.stopTest();
        }
        
        cases = [Select Id, status, Reason From Case ORDER By Deadline_Reason__c ASC];
        System.assertEquals(3, cases.size());
        System.assertEquals(System.Label.CASE_STATUS_90_Closed, cases[0].status);
        System.assertEquals(System.Label.CASE_STATUS_90_Closed, cases[1].status);
        System.assertEquals(System.Label.CASE_STATUS_90_Closed, cases[2].status);
        System.assertEquals(System.Label.CASE_Reason_EXPERT_CENTER, cases[0].Reason);
        System.assertEquals(System.Label.CASE_Reason_EXPERT_CENTER, cases[1].Reason);
        System.assertEquals(System.Label.CASE_Reason_EXPERT_CENTER, cases[2].Reason); 
        
    }
}