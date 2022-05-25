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
@isTest(seeAllData=false)
private class Test_DeploymentTriggerHelper { 

    /**
    *  Purpose          :   Test class for DeploymentTriggerHelper class.
    * 
    *  Created By       :   Bhavi Sharma    
    * 
    *  Created Date     :   05/25/2013
    * 
    *  Current Version  :   V_1.0 - Created -   CR-20130328-2773
    *                       V_1.1 - Modified By - Abhinav Sharma -03/03/2014 - CR-20130829-3543 - Method added (test_populateFirstDeploymentSignedOff) - 97% coverage
    *                       V_1.2 - Modified By - Abhinav Sharma - 04/29/2014 - CR-20140403-4958 - Method Modified (test_populateFirstDeploymentSignedOff)
    *                       V_1.3 - Modified By - Abhinav Sharma - 05/02/2014 - CR-20140408-5000 - New method added (test_populateDeploymentDataOnProject)
    *                       V_1.4 - Modified By - Ajit Surana   - 08/18/2014 -  CR-20140507-5388 - Test class modified
    *                       V_1.5 - Modified By - Ajit Surana - 09/08/2014 - CR-20140716-6256 - test_populateFirstDeploymentSignedOff method is modified
    *                       V_1.6 - Modified By - Abhinav Sharma - 10/17/2014 - CR-20140826-7138 - New method added (test_populateDeploymentSignOffOldestOnProject)
    *                       V_1.7 - Modified By - Ajit Surana - 03/10/2015 - CR-20141218-8365 - New method added (testupdateCalculatedDateFields)
    *                       V_1.8 - Modified By - Abhinav Sharma - 10/20/2015 - CR-20150623-9023 - Modified existing method (testupdateCalculatedDateFields)
    *                       V_1.9 - Modified By - Rajeev Jain - 07/29/2016 - CR-20160728-10071 - Services Excellence - Removed references of CCC_Deployment and CPRM_Deployment Record types  
    *                       V_2.0 - Modified By - Mahendra Swarnkar - 07/05/2017 - CR-20170320-10767 - Modified existing method (test_populateDeploymentDataOnProject)
    *			    V_2.1 - Modified By - Neha Sharma - CR-20210916-15439  - 11/15/2021 - Code coverage increase	
    **/ 
    //V1.9 - Rajeev Jain - 07/29/2016 - CR-20160728-10071 - Services Excellence - Removed references of CCC_Deployment
    
     @testSetup static void setup() {
          Util.byPassAllTriggers = true;
         
         //Record Type Id with Name.
        Id EDH_RECORDTYPE_ID = Schema.SObjectType.Deployment__c.getRecordTypeInfosByName().get('EDH').getRecordTypeId();
         
         //Project record
        List<Project__c> projectList = new List<Project__c>();
        Project__c project = new Project__c(Name = 'Test-Project',Learning_Management_System__c = 'Test',Current_SIS__c = 'Test',Enrollment_CRM__c = 'Test');
        Project__c project1 = new Project__c(Name = 'Test1-Project',Learning_Management_System__c = 'Test',Current_SIS__c = 'Test',Enrollment_CRM__c = 'Test');
        projectList.add(project);
        projectList.add(project1);
        insert projectList;
        
        Util.byPassAllTriggers = false;
        
        List<Deployment__c> deploymentList = new List<Deployment__c>();
        //Deployment record
        Deployment__c deployment = new Deployment__c(Name = 'Test-Deploy1', Project__c = projectList[0].Id, Use_Standard_Milestone_Goals__c = false,
                                                    C_A_DC__c = Date.today().addDays(5), Site_Live_Expected__c = Date.today().addDays(1));
        Deployment__c deployment1 = new Deployment__c(Name = 'Test-Deploy1', Project__c = projectList[0].Id, RecordTypeId = EDH_RECORDTYPE_ID, Use_Standard_Milestone_Goals__c = false,
                                                    C_A_DC__c = Date.today().addDays(5), Site_Live_Expected__c = Date.today().addDays(1));
        deploymentList.add(deployment);   
        deploymentList.add(deployment1);   
        insert deploymentList;
     }
    
    static testMethod void test_populateDeploymentFieldsFromProject() {
        
       List<Project__c> projectList = [Select Id,Name,Learning_Management_System__c,Enrollment_CRM__c,Current_SIS__c From Project__c];
      
       List<Deployment__c> deploymentList = [Select Id,Project__c,Current_SIS__c,CRM__c,Learning_Management_System__c,Name,RecordTypeId,C_A_DC__c,Site_Live_Expected__c,Use_Standard_Milestone_Goals__c FROM Deployment__c];
       deploymentList[1].Project__c = projectList[1].Id;
       update deploymentList[1];
        
       system.assertEquals(deploymentList[1].Learning_Management_System__c,projectList[1].Learning_Management_System__c);
       system.assertEquals(deploymentList[1].CRM__c,projectList[1].Enrollment_CRM__c);
       system.assertEquals(deploymentList[1].Current_SIS__c,projectList[1].Current_SIS__c);
    }
    
    static testMethod void test_validateDeployment() {
      List<Project__c> projectList = [Select Id,Name From Project__c];
      
       List<Deployment__c> deploymentList = [Select Id,Project__c,Name,RecordTypeId,C_A_DC__c,Site_Live_Expected__c,Use_Standard_Milestone_Goals__c FROM Deployment__c];
       ABC_Revenue__c rev = new ABC_Revenue__c(Deployment__c = deploymentList[0].Id);
       insert rev;

      deploymentList[1].Project__c = projectList[1].Id;
      deploymentList[1].Deployment_Phase__c = 'X - Cancelled/Duplicate';
      deploymentList[1].RecordTypeId = Schema.SObjectType.Deployment__c.getRecordTypeInfosByName().get('SSC Academic Planning').getRecordTypeId(); 
      update deploymentList[1];
        
    }
    
    static testMethod void test_updateCalculatedDateFields(){
       Id recrdTypeId  = Schema.SObjectType.Deployment__c.getRecordTypeInfosByName().get('CPRM Deployment').getRecordTypeId();  
       Deployment__c deployment = new Deployment__c(Name = 'Test-Deploy1', Use_Standard_Milestone_Goals__c = false,RecordTypeId = recrdTypeId,
                                                    C_A_DC__c = Date.today().addDays(5), Site_Live_Expected__c = Date.today().addDays(1));
       insert deployment;
        
       Deployment__c deployment1 = new Deployment__c(Name = 'Test-Deploy1', RecordTypeId = recrdTypeId, Use_Standard_Milestone_Goals__c = false,
                                                    C_A_DC__c = Date.today().addDays(5), Site_Live_Expected__c = Date.today().addDays(1),C_A_DS__c =system.today()); 
       insert deployment1;
    }
    
    //Modified By - Neha Sharma - CR-20210916-15439  - 11/15/2021 - Code coverage increase
    static testMethod void test_updateDeploymentStatus(){
       Id recrdTypeId  = Schema.SObjectType.Deployment__c.getRecordTypeInfosByName().get('Compass Connect Deployment').getRecordTypeId();  
        
       List<Deployment__c> deploymentsToBeInsert = new List<Deployment__c>();
       
        deploymentsToBeInsert.add(new Deployment__c(Use_Standard_Milestone_Goals__c = false,RecordTypeId = recrdTypeId,
                                                    C_A_DC__c = Date.today().addDays(5), Site_Live_Expected__c = Date.today().addDays(1),
                                                   C_E_TPC__c = system.today().addDays(-1),C_E_IDI__c = system.today().addDays(-1),C_E_CDI__c = system.today() ,
                                                   C_E_DDC__c = system.today(),/*C_E_IDC__c = system.today(),*/ C_E_IVC__c = system.today() ,C_E_DC__c = system.today(),
                                                   Expected_Recurring_Update_Sign_Off2__c = system.today(),C_A_TPC__c = system.today().addDays(1),C_A_IDI__c= system.today(),
                                                   C_A_CDI__c = system.today(),C_A_DDC__c = system.today(),Actual_Recurring_Update_Sign_Off__c = system.today(),
                                                   C_A_ISBC__c = system.today(),C_A_IVC__c = system.today()));
        
        deploymentsToBeInsert.add(new Deployment__c(Use_Standard_Milestone_Goals__c = false,RecordTypeId = recrdTypeId,
                                                    C_A_DC__c = Date.today().addDays(5), Site_Live_Expected__c = Date.today().addDays(1),
                                                    C_E_TPC__c = system.today().addDays(-1),C_E_IDI__c = system.today(),C_E_CDI__c = system.today() ,
                                                    C_E_DDC__c = system.today(),C_E_IVC__c = system.today() ,C_E_DC__c = system.today(),
                                                    Expected_Recurring_Update_Sign_Off2__c = system.today(),C_A_IDI__c= system.today(),C_A_TPC__c= null,
                                                    C_A_CDI__c = system.today(),C_A_DDC__c = system.today(),
                                                    C_A_ISBC__c = system.today(),C_A_IVC__c = system.today()));
        
        deploymentsToBeInsert.add(new Deployment__c(Use_Standard_Milestone_Goals__c = false,RecordTypeId = recrdTypeId,
                                                    Site_Live_Expected__c = Date.today().addDays(1),
                                                    C_E_TPC__c = system.today().addDays(-1),C_E_IDI__c = system.today(),C_E_CDI__c = system.today() ,
                                                    C_E_DDC__c = system.today(),C_E_IVC__c = system.today() ,C_E_DC__c = system.today(),
                                                    Expected_Recurring_Update_Sign_Off2__c = system.today(),C_A_IDI__c= system.today(),C_A_TPC__c= null,
                                                    C_A_CDI__c = system.today(),C_A_DDC__c = system.today(),
                                                    C_A_ISBC__c = system.today(),C_A_IVC__c = system.today()));
        
        deploymentsToBeInsert.add(new Deployment__c(Use_Standard_Milestone_Goals__c = false,RecordTypeId = recrdTypeId,
                                                    Site_Live_Expected__c = Date.today().addDays(1),
                                                    C_E_TPC__c = system.today().addDays(-1),C_E_IDI__c = system.today(),C_E_CDI__c = system.today() ,
                                                    C_E_DDC__c = system.today(),C_E_IVC__c = system.today() ,C_E_DC__c = system.today(),
                                                    Expected_Recurring_Update_Sign_Off2__c = system.today(),C_A_IDI__c= system.today(),C_A_TPC__c= null,
                                                    C_A_CDI__c = system.today(),C_A_DDC__c = system.today(),
                                                    C_A_ISBC__c = system.today()));
        
        deploymentsToBeInsert.add(new Deployment__c(Use_Standard_Milestone_Goals__c = false,RecordTypeId = recrdTypeId,
                                                    Site_Live_Expected__c = Date.today().addDays(1),
                                                    C_E_TPC__c = system.today().addDays(-1),C_E_IDI__c = system.today(),C_E_CDI__c = system.today() ,
                                                    C_E_DDC__c = system.today(),C_E_IVC__c = system.today() ,C_E_DC__c = system.today(),
                                                    Expected_Recurring_Update_Sign_Off2__c = system.today(),C_A_IDI__c= system.today(),C_A_TPC__c= null,
                                                    C_A_CDI__c = system.today(),C_A_DDC__c = system.today()));
        
        deploymentsToBeInsert.add(new Deployment__c(Use_Standard_Milestone_Goals__c = false,RecordTypeId = recrdTypeId,
                                                    Site_Live_Expected__c = Date.today().addDays(1),
                                                    C_E_TPC__c = system.today().addDays(-1),C_E_IDI__c = system.today(),C_E_CDI__c = system.today() ,
                                                    C_E_DDC__c = system.today(),C_E_IVC__c = system.today() ,C_E_DC__c = system.today(),
                                                    Expected_Recurring_Update_Sign_Off2__c = system.today(),C_A_IDI__c= system.today(),C_A_TPC__c= null,
                                                    C_A_CDI__c = system.today()));
        
        deploymentsToBeInsert.add(new Deployment__c(Use_Standard_Milestone_Goals__c = false,RecordTypeId = recrdTypeId,
                                                    Site_Live_Expected__c = Date.today().addDays(1),
                                                    C_E_TPC__c = system.today().addDays(-1),C_E_IDI__c = system.today(),C_E_CDI__c = system.today() ,
                                                    C_E_DDC__c = system.today(),C_E_IVC__c = system.today() ,C_E_DC__c = system.today(),
                                                    Expected_Recurring_Update_Sign_Off2__c = system.today(),C_A_IDI__c= system.today(),C_A_TPC__c= null));
        
        deploymentsToBeInsert.add(new Deployment__c(Use_Standard_Milestone_Goals__c = false,RecordTypeId = recrdTypeId,
                                                    Site_Live_Expected__c = Date.today().addDays(1),
                                                    C_E_TPC__c = system.today().addDays(-1),C_E_IDI__c = system.today(),C_E_CDI__c = system.today() ,
                                                    C_E_DDC__c = system.today(),C_E_IVC__c = system.today() ,C_E_DC__c = system.today(),
                                                    Expected_Recurring_Update_Sign_Off2__c = system.today(),C_A_TPC__c= system.today()));
        
         deploymentsToBeInsert.add(new Deployment__c(Use_Standard_Milestone_Goals__c = false,RecordTypeId = recrdTypeId,
                                                    Site_Live_Expected__c = Date.today().addDays(1),
                                                    C_E_TPC__c = system.today().addDays(-1),C_E_IDI__c = system.today(),C_E_CDI__c = system.today() ,
                                                    C_E_DDC__c = system.today(),C_E_IVC__c = system.today() ,C_E_DC__c = system.today(),
                                                    Expected_Recurring_Update_Sign_Off2__c = system.today(),C_A_TPC__c= null));
        
        Insert deploymentsToBeInsert;
       
    }
    
    static testMethod void test_updateSiteLiveDateOnABCRevenue(){
       List<Project__c> projectList = [Select Id,Name From Project__c];
      
       List<Deployment__c> deploymentList = [Select Id,Project__c,Name,RecordTypeId,C_A_DC__c,Site_Live_Expected__c,Use_Standard_Milestone_Goals__c FROM Deployment__c];
       ABC_Revenue__c rev = new ABC_Revenue__c(Deployment__c = deploymentList[1].Id);
       insert rev;

      deploymentList[1].Project__c = projectList[1].Id;
      deploymentList[1].RecordTypeId = Schema.SObjectType.Deployment__c.getRecordTypeInfosByName().get('SSC Academic Planning').getRecordTypeId(); 
      deploymentList[1].C_A_DC__c  = system.today();  
      update deploymentList[1];
    }
    
    static testMethod void test_createMilestoneOnDeploymentCreation(){
       Util.byPassAllTriggers = true;
        pse__Proj__c pse = new pse__Proj__c(Name = 'TestPSA',pse__Is_Active__c = true);
        insert pse;
        
        ID projRecordTypeId = [Select Id, Name FROM RecordType WHERE SobjectType = 'Project__c' and RecordType.DeveloperName = 'SSC'].Id;
        
       Project__c project = new Project__c(Name = 'Test' ,PSA_Project__c = pse.Id,RecordTypeId = projRecordTypeId);
       insert project;
        
       Util.byPassAllTriggers = false;
       Deployment__c deployment = new Deployment__c(Project__c=  project.Id,C_A_DC__c = system.today(),Site_Live_Expected__c = system.today());
       insert deployment;
        
       
    }
    
    //Added By - Mahendra Swarnkar - 01/05/2021 - CR-20200615-14184 - Validation Rule for Deployments on revenue lines
    static testMethod void test_validateRevenue() {
        //get project from setup
        List<Project__c> projectList = [Select Id,Name From Project__c];
        
        //get deployment from setup
        List<Deployment__c> deploymentList = [Select Id,Project__c,Name,RecordTypeId,C_A_DC__c,Site_Live_Expected__c,Use_Standard_Milestone_Goals__c FROM Deployment__c];
        
        //create a new revenue with Deployment
        ABC_Revenue__c rev = new ABC_Revenue__c(Deployment__c = deploymentList[0].Id, Site_Live_Date__c = System.today());
        insert rev;
        
        //Assertion on result
        System.assertEquals(System.today(), rev.Site_Live_Date__c);
        
        //delete Deployment
        Delete deploymentList[0];
        
        test.startTest();
        
        rev = [Select Id , Site_Live_Date__c FROM ABC_Revenue__c limit 1];
        System.assertEquals(null, rev.Site_Live_Date__c);
        
        test.stopTest();
    }
    
}