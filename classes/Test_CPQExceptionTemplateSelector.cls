/**
*  Purpose         :   This Class is used to test the CPQExceptionTemplateSelectorController class
*
*  Create By       :   Victor Hanson
*
*  Created Date    :   05/23/2019
*
*  Revision Logs   :   V_1.0 - Created.
*                      
**/
@isTest
public class Test_CPQExceptionTemplateSelector {
    
    @testSetup
    static void setupTestData() {
        
        //Bypassing triggers
        Util.BypassAllTriggers = true;
        
        //Creating Account record
        Account account = TestUtilities.CreateNewAccount(true);
        
        //Creating Contract record
        Contract contract = TestUtilities.createNewStandardContract(account.Id, true);
        System.assert(contract.Id != null);
        
        // Test Class Fix Start Here 13Feb By: Dipesh Gupta
        //Creating Contact record 
        Contact cont = TestUtilities.CreateNewContact(True);
        // Test Class Fix End Here 13Feb By: Dipesh Gupta
        
        //Creating Opportunity record
        Opportunity opportunity = TestUtilities.CreateNewOpportunity(false);
        opportunity.RecordTypeId = CPQConstants.OPP_RT_ID_EAB_INITIATING;
        opportunity.StageName = '0-MDQ';
        opportunity.Main_Contact__c = cont.Id;
        insert opportunity;
        System.assert(opportunity != null);
        
        //create quote
        SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Status__c = 'Draft', SBQQ__Type__c = 'Quote', SBQQ__Primary__c = true, SBQQ__Opportunity2__c = opportunity.Id);
        insert quote;
        System.assert(quote != null);
        
        //setup Exception Template(s)
        List<Exception_Template__c> exTemplates = new List<Exception_Template__c>();
        exTemplates.add(new Exception_Template__c(  Name = 'Alternate Governing Law - Alabama',
                                                  RecordTypeId = ExceptionTemplateHelper.EXCEPTION_TEMPLATE_MASTER_RT_ID,
                                                  Alternative_Language_Header__c = 'Alternate Governing Law - Alabama',
                                                  Section__c = '16',
                                                  Section_Name__c = 'Governing Law; Survival',
                                                  Alternative_Language__c = 'The Agreement is to be governed by...'));
        
        exTemplates.add(new Exception_Template__c(  Name = 'Alternate Governing Law - Texas',
                                                  RecordTypeId = ExceptionTemplateHelper.EXCEPTION_TEMPLATE_MASTER_RT_ID,
                                                  Alternative_Language_Header__c = 'Alternate Governing Law - Texas',
                                                  Section__c = '16',
                                                  Section_Name__c = 'Governing Law; Survival',
                                                  Alternative_Language__c = 'The Agreement is to be governed by...'));
        
        exTemplates.add(new Exception_Template__c(  Name = 'Remove late payment charge for overdue payments',
                                                  RecordTypeId = ExceptionTemplateHelper.EXCEPTION_TEMPLATE_MASTER_RT_ID,
                                                  Alternative_Language_Header__c = 'Remove late payment charge for overdue payments',
                                                  Section__c = '16',
                                                  Section_Name__c = 'Fees and Payment',
                                                  Alternative_Language__c = 'Organization will pay EAB fees for...'));
        //Bypassing triggers = false when inserting templates.  critical code executes in trigger
        Util.BypassAllTriggers = false;
        insert exTemplates;
    }
    
    static testMethod void testSearch() {
        
        //get quote
        List<SBQQ__Quote__c> quotes = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        system.assertEquals(1, quotes.size());
        SBQQ__Quote__c quote = quotes[0];
        
        //Go to Page
        PageReference pageRef = Page.CPQExceptionTemplateSelector;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', quote.Id);
        CPQExceptionTemplateSelectorController controller = new CPQExceptionTemplateSelectorController();
        
        //call the init() method, which will execute the initial search
        controller.init();
        system.assertEquals(3, controller.lstSetController.size());
        
        //update string & search
        controller.searchString = 'fee';
        controller.search();
        
        system.assertEquals(1, controller.lstSetController.size());
    }
    
    
    
    static testMethod void testAddProduct() {
        
        //get quote
        List<SBQQ__Quote__c> quotes = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        system.assertEquals(1, quotes.size());
        SBQQ__Quote__c quote = quotes[0];
        
        //Go to Page
        PageReference pageRef = Page.CPQExceptionTemplateSelector;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', quote.Id);
        CPQExceptionTemplateSelectorController controller = new CPQExceptionTemplateSelectorController();
        
        //call the init() method, which will execute the initial search
        controller.init();
        system.assertEquals(3, controller.lstSetController.size());
        
        system.assertNotEquals(null, controller.lstSetController[0].eTemplate.Id);
        
        //select one of the records
        controller.recordId = controller.lstSetController[0].eTemplate.Id;
        controller.lstSetController[0].isSelected = true;
        controller.toggleSelection();
        system.assertEquals(1, controller.selectedTemplates.size(), 'when a record is selected, it should appear in this list');
        
        //select another record
        controller.recordId = controller.lstSetController[1].eTemplate.Id;
        controller.lstSetController[1].isSelected = true;
        controller.toggleSelection();
        system.assertEquals(2, controller.selectedTemplates.size(), '2nd record should be selected');
        
        //remove the first selection
        controller.recordId = controller.lstSetController[0].eTemplate.Id;
        controller.isRemoveItem = 'true';
        controller.toggleSelection();
        integer selectionCount = 0;
        for (SObjectRow r : controller.lstSetController) {
            if (r.isSelected) selectionCount++;
        }
        system.assertEquals(1, selectionCount, 'should have deselected 1st the record, leaving only one record selected');
        
        //remove the second selection
        controller.recordId = controller.lstSetController[1].eTemplate.Id;
        controller.lstSetController[1].isSelected = false;
        controller.toggleSelection();
        selectionCount = 0;
        for (SObjectRow r : controller.lstSetController) {
            if (r.isSelected) selectionCount++;
        }
        system.assertEquals(0, selectionCount, 'No records should be selected now.');
    }
    
    static testMethod void testSave() {
        
        //get quote
        List<SBQQ__Quote__c> quotes = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        system.assertEquals(1, quotes.size());
        SBQQ__Quote__c quote = quotes[0];
        
        //Go to Page
        PageReference pageRef = Page.CPQExceptionTemplateSelector;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', quote.Id);
        CPQExceptionTemplateSelectorController controller = new CPQExceptionTemplateSelectorController();
        
        //call the init() method, which will execute the initial search
        controller.init();
        system.assertEquals(3, controller.lstSetController.size());
        
        system.assertNotEquals(null, controller.lstSetController[0].eTemplate.Id);
        
        //select one of the records
        controller.recordId = controller.lstSetController[0].eTemplate.Id;
        controller.lstSetController[0].isSelected = true;
        controller.toggleSelection();
        system.assertEquals(1, controller.selectedTemplates.size(), 'when a record is selected, it should appear in this list');
        
        //select another record
        controller.recordId = controller.lstSetController[1].eTemplate.Id;
        controller.lstSetController[1].isSelected = true;
        controller.toggleSelection();
        system.assertEquals(2, controller.selectedTemplates.size(), '2nd record should be selected');
        
        //save
        controller.save();
        
        //privous
        PageReference pG = controller.cancel();
      
        
        //verify the records were created
        List<CPQ_Contract_Exception__c> contractExceptions = [SELECT Id FROM CPQ_Contract_Exception__c WHERE Proposal__c = :quote.Id];
        system.assertEquals(2, contractExceptions.size());
    }
}