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
private class Test_CustomIterable {

	@testSetup
    static void setupTestData() {
        
        //Bypassing triggers
        Util.BypassAllTriggers = true;
        
        //Creating Account record
        Account account = TestUtilities.CreateNewAccount(true);
        
        // Test Class Fix Start Here 13Feb By: Dipesh Gupta
        //Creating Contact record 
        Contact cont = TestUtilities.CreateNewContact(True);
        // Test Class Fix End Here 13Feb By: Dipesh Gupta
        
        //Creating Contract record
        Contract contract = TestUtilities.createNewStandardContract(account.Id, true);
        System.assert(contract.Id != null);
        
        //Creating Opportunity record
        Opportunity opportunity = TestUtilities.CreateNewOpportunity(false);
        opportunity.RecordTypeId = CPQConstants.OPP_RT_ID_EAB_INITIATING;
        opportunity.StageName = '0-MQL';
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
            
            exTemplates.add(new Exception_Template__c(  Name = 'Remove late payment charge for overdue payments',
                                                      RecordTypeId = ExceptionTemplateHelper.EXCEPTION_TEMPLATE_MASTER_RT_ID,
                                                      Alternative_Language_Header__c = 'Remove late payment charge for overdue payments',
                                                      Section__c = '16',
                                                      Section_Name__c = 'Fees and Payment',
                                                      Alternative_Language__c = 'Organization will pay EAB fees for...'));
            exTemplates.add(new Exception_Template__c(  Name = 'Remove late payment charge for overdue payments',
                                                      RecordTypeId = ExceptionTemplateHelper.EXCEPTION_TEMPLATE_MASTER_RT_ID,
                                                      Alternative_Language_Header__c = 'Remove late payment charge for overdue payments',
                                                      Section__c = '16',
                                                      Section_Name__c = 'Fees and Payment',
                                                      Alternative_Language__c = 'Organization will pay EAB fees for...'));
        
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
        //
        Util.BypassAllTriggers = false;
        insert exTemplates;
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
        system.assertEquals(10, controller.lstSetController.size());
        
        //remove the first selection
        controller.recordId = controller.lstSetController[0].eTemplate.Id;
        //controller.toggleSelection();
        for (SObjectRow r : controller.lstSetController) {
            //if (r.isSelected) selectionCount++;
        }
        
        try{
            //Previous
            controller.previous();
        }
        catch(exception ex){
            System.debug('Custom Error occured ' + ex.getMessage());
        }
    }

}