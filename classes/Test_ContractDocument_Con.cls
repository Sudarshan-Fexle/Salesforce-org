@isTest
private class Test_ContractDocument_Con
{
    /*
    Purpose         :   Test Controller for a Visualforce page that combines creation of a Contract_Document__c record with attachment of a file to the newly-created record.
    Page			:   ContractDocumemt
    
    Create By       :   Yogesh (Synaptic) - 12/2010
    
    Last Modified By:   Nathan Banas (Synaptic) - 1/24/2011
    
    Current Version :   v1.1
    
    Revision Log    :   V1.0 - (Yogesh) Created this controller class and accompanying test and VF modules
                        V1.1 - (Nathan Banas) Added comments and this header
    			V1.2 - Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes

    Code Coverage as of 1/24/2011: 100%
    */
  
    public static testmethod void DoTest()
    {
        Util.IsTesting = true;
        test.startTest();
        // Create Account
        Account acc = new Account();
        acc.Name='Test Trigger Account1';
        acc.Account_Formal_Name__c='Test Trigger Account1';
        acc.Primary_City__c = 'Washington';
        acc.Primary_State_Province__c = 'DC';
            
        insert acc;
         
        system.assert(acc.Id != null);
        
        // Test Class Fix Start Here 13Feb By: Dipesh Gupta
        // Test Class Fix Start Here 07/19/20 By: Mahendra Swarnakar -CR-20200218-13783
        //Creating Contact record 
        Contact cont = TestUtilities.CreateNewContact(false);
        cont.AccountId = acc.Id;
        insert cont;
         Test.stopTest();
        // Test Class Fix end Here 07/19/20 By: Mahendra Swarnakar
        // Test Class Fix End Here 13Feb By: Dipesh Gupta
         
        string recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Royall').getRecordTypeId();
        //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
        // Create opportunity   
        Opportunity opp = new Opportunity();
        opp.AccountId = acc.Id;
        opp.Main_Contact__c = cont.Id;
        opp.Name = 'test';
        opp.CloseDate = system.today();
        opp.StageName = 'New';
        opp.RecordTypeId = recordTypeId;
        opp.Sales_Pursuit_Products__c = 'APS';
        insert opp;
      
        system.assert(opp.Id != null);
         

        ApexPages.CurrentPage().getParameters().put('id',opp.Id);
         
        // Initialize object
        ContractDocument_Con cls = new ContractDocument_Con();
         
        cls.CurrentContractDocument.Name = 'Test';
        cls.CurrentContractDocument.Name__c = 'Test';
        cls.CurrentContractDocument.Account__c = acc.Id;
        cls.CurrentContractDocument.Type__c = 'Terms of Agreement';
        cls.CurrentContractDocument.Comments__c = 'Test';
        cls.CDAttachment.Name = 'Test.txt';
         
        blob blb = blob.valueof('test');
        cls.CDAttachment.body = blb;
         
        try
        {
            PageReference pr = cls.DoSave();
            system.assert(pr != null);
        }   
        catch(Exception ex)
        {
            system.debug(ex.getMessage());
        }
         
        try
        {
            PageReference pr = cls.DoCancel();  
           
            system.assert(pr != null);
        }   
        catch(Exception ex)
        {
            system.debug(ex.getMessage());
        }
    }
 
    public static testmethod void DoTest2()
    {
    
        Util.IsTesting = true;
        Test.startTest();
        // Create Account
        Account acc = new Account();
        acc.Name='Test Trigger Account1';
        acc.Account_Formal_Name__c='Test Trigger Account1';
        acc.Primary_City__c = 'Washington';
        acc.Primary_State_Province__c = 'DC';
            
        insert acc;
         
        system.assert(acc.Id != null);
        
       // Test Class Fix Start Here 13Feb By: Dipesh Gupta
        // Test Class Fix Start Here 07/19/20 By: Mahendra Swarnakar -CR-20200218-13783
        //Creating Contact record 
        Contact cont = TestUtilities.CreateNewContact(false);
        cont.AccountId = acc.Id;
        insert cont;
        Test.stopTest();
        // Test Class Fix end Here 07/19/20 By: Mahendra Swarnakar
        // Test Class Fix End Here 13Feb By: Dipesh Gupta
        
        string recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Royall').getRecordTypeId();
        
        //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
        // Create opportunity   
        Opportunity opp = new Opportunity();
        opp.AccountId = acc.Id;
        opp.Main_Contact__c = cont.Id;
        opp.Name = 'test';
        opp.CloseDate = system.today();
        opp.StageName = 'New';
        opp.RecordTypeId = recordTypeId;
        opp.Sales_Pursuit_Products__c = 'APS';
        insert opp;
         
        system.assert(opp.Id != null);
         
       
        
        ApexPages.CurrentPage().getParameters().put('id',opp.Id);
         
        // Initialize object
        ContractDocument_Con cls = new ContractDocument_Con();
         
        cls.CurrentContractDocument.Name = 'Test';
        cls.CurrentContractDocument.Name__c = 'Test';
        cls.CurrentContractDocument.Account__c = acc.Id;
        cls.CurrentContractDocument.Type__c = 'Terms of Agreement';
        cls.CurrentContractDocument.Comments__c = 'Test';
        cls.CDAttachment.Name = 'Test.txt';
         
        try
        {
            PageReference pr = cls.DoSave();    
        }   
        catch(Exception ex)
        {
            system.debug(ex.getMessage());
        }
         
        try
        {
            PageReference pr = cls.DoCancel();  
           
            system.assert(pr != null);
        }   
        catch(Exception ex)
        {
            system.debug(ex.getMessage());
        }
    } 
  
    public static testmethod void DoTest3()
    {
        Util.IsTesting = true;
         Test.startTest();
        // Create Account
        Account acc = new Account();
        acc.Name='Test Trigger Account1';
        acc.Account_Formal_Name__c='Test Trigger Account1';
        acc.Primary_City__c = 'Washington';
        acc.Primary_State_Province__c = 'DC';
            
        insert acc;
         
        system.assert(acc.Id != null);
        
        // Test Class Fix Start Here 13Feb By: Dipesh Gupta
        // Test Class Fix Start Here 07/19/20 By: Mahendra Swarnakar -CR-20200218-13783
        //Creating Contact record 
        Contact cont = TestUtilities.CreateNewContact(false);
        cont.AccountId = acc.Id;
        insert cont;
         Test.stopTest();
        // Test Class Fix end Here 07/19/20 By: Mahendra Swarnakar
        // Test Class Fix End Here 13Feb By: Dipesh Gupta
         
        string recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Royall').getRecordTypeId();
        //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
        // Create opportunity   
        Opportunity opp = new Opportunity();
        opp.AccountId = acc.Id;
        opp.Main_Contact__c = cont.Id;
        opp.Name = 'test';
        opp.CloseDate = system.today();
        opp.StageName = 'New';
        opp.RecordTypeId = recordTypeId;
        opp.Sales_Pursuit_Products__c = 'APS';
        insert opp;
         
        system.assert(opp.Id != null);
         
       
         
        ApexPages.CurrentPage().getParameters().put('id',opp.Id);
         
        // Initialize object
        ContractDocument_Con cls = new ContractDocument_Con();
         
        cls.CurrentContractDocument.Name = 'Test';
        cls.CurrentContractDocument.Name__c = 'Test';
        cls.CurrentContractDocument.Account__c = acc.Id;
        cls.CurrentContractDocument.Type__c = 'Terms of Agreement';
        cls.CurrentContractDocument.Comments__c = 'Test';
        
        try
        {
            PageReference pr = cls.DoSave();    
        }   
        catch(Exception ex)
        {
            system.debug(ex.getMessage());
        }
         
        try
        {
           PageReference pr = cls.DoCancel();   
           
           system.assert(pr != null);
        }   
        catch(Exception ex)
        {
            system.debug(ex.getMessage());
        }
    }
}