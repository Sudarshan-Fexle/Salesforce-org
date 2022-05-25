/*
    Purpose             :   This test class is to test OrgComparisonAnalysisController 
                
    Create By           :   Fexle Technology
    
    Created Date        :   24/09/2019
    
    Current Version     :    V1.0
                             V1.1 Modified By - Dipesh Gupta - 2/27/2020 - CR-20191216-13564 
                             V1.2 Modified By - Nikita Kumari - CR-20211012-15511

    Created By:  Seemu Saikia 
*/
@isTest(SeeAllData = False)
public class Test_OrgComparisonAnalysisController {
	
    @isTest
    public static void TestinitiateCompare(){
        //Inserting CR
        SFDC_Change_Request__c changeRequests = new SFDC_Change_Request__c (Title__c = 'Test219');
        insert changeRequests;
        
		//Inserting Connections for Source Org
        Connection__c con1 = new Connection__c();
        con1.Name = 'Source of Truth';
        con1.Org_type__c = 'Sandbox';
        con1.Refresh_Token__c = 'sfkjshfkjshfisjkdhfslkdf';
        con1.Sandbox_Refresh_Date__c = System.today();
        con1.Instance_URL__c = Url.getSalesforceBaseUrl().toExternalForm();
        insert con1;
        
        //Inserting Connections for Compairing  Org
        Connection__c con2 = new Connection__c();
        con2.Name = 'Comparison Org';
        con2.Org_type__c = 'Sandbox';
        con2.Refresh_Token__c = 'sfkjshfkjshfisjkdhfslkdf';
        con2.Sandbox_Refresh_Date__c = System.today();
        con2.Instance_URL__c = Url.getSalesforceBaseUrl().toExternalForm();
        insert con2;
        
        // Modified - Dipesh Gupta - 2/27/2020 - CR-20191216-13564 Start Here 
        //Query on Profile
        Profile profile1 = [Select Id, Name From Profile Where name = 'System Administrator' LIMIT 1];
        
        // hold User
        User usr = new User(LastName = 'test',
                           FirstName='testing',
                           Alias = 'test',
                           Email = 'test@asdf.com',
                           Username = 'testing@asdf.com',
                           ProfileId = profile1.id,
                           IsActive = true,
                           TimeZoneSidKey = 'GMT',
                           LanguageLocaleKey = 'en_US',
                           EmailEncodingKey = 'UTF-8',
                           LocaleSidKey = 'en_US'
                           );
        
        //Insert User
        insert usr;
        
        List<user> userList = [Select Id From user];
        System.assert(userList[0].Id != null);
        System.assert(userList.size() > 0);
        
        // IS_Environment__c 1
        IS_Environment__c is_environment = new IS_Environment__c();
        is_environment.Name = 'Dev2 - Active';
        is_environment.Environment_Type__c = 'Development';
        is_environment.Status__c = 'Active';
        insert is_environment;
        
        List<IS_Environment__c> devEnv = [Select Id From IS_Environment__c];
        System.assert(devEnv[0].Id != null);
        System.assert(devEnv.size() > 0);
        
        // IS_Environment__c 2
        IS_Environment__c is_environment2 = new IS_Environment__c();
        is_environment2.Name = 'Full2 - Active';
        is_environment2.Environment_Type__c = 'UAT';
        is_environment2.Status__c = 'Active';
        insert is_environment2;
        
        List<IS_Environment__c> devEnv2= [Select Id From IS_Environment__c];
        System.assert(devEnv2[1].Id != null);
        System.assert(devEnv.size() > 0);
        
        // Release
        SFDC_Release__c rel = new SFDC_Release__c();
        rel.Name = 'Tst_MS';
        rel.Status__c = 'Scheduled - Planned';
        rel.Ready_for_Org_Comparison__c = true;
        rel.Last_Org_Comparision_Sync__c = System.today()-5;
        rel.Start_Date__c = System.today();
        rel.Org_Comparison_QA__c = con1.Id;
        rel.Org_Comparison_UAT__c = con2.Id;
        rel.Environment_Manager__c = usr.Id;
        rel.Release_Manager__c = usr.Id;
        rel.Dev_Sandbox__c = devEnv[0].Id;
        rel.QA_Sandbox__c = devEnv2[1].Id;
        rel.UAT_Sandbox__c = devEnv2[1].Id;
        rel.Release_level__c = 'L2';
        insert rel;
        
        //Modified - Dipesh Gupta - 2/27/2020 - CR-20191216-13564 Ends Here
        
        //inserting Org Comparision 
        List<Org_Comparision__c> orgComp = new List<Org_Comparision__c>();
        orgComp.add(new Org_Comparision__c (Change_Request__c = changeRequests.id,Release__c = rel.Id,Type__c = 'QA',
                                          Created_Date_Bar__c = date.today(),Last_Modified_Date_Bar__c=date.today(),Source_of_Truth__c=con1.id,
                                          Comparison_Org__c=con2.id,Save_Mods_To__c = con1.id,Save_Mods_To_Different_Org__c = true,
                                          Create_Additive_Mods__c=false,Compare_between_last_modified_dates__c = true,
                                            Last_Modified_Date_End_Bar__c=date.today())); 
        
        insert orgComp;
        
        //set VFPage Url Parameter 
        PageReference pageRef = Page.OrgComparisonAnalysis;
		test.setCurrentPageReference(pageRef);
		pageRef.getParameters().put('Id',orgComp[0].id);
        pageRef.getParameters().put('process','Update');
        
        //initializing Class
        OrgComparisonAnalysisController obj = new OrgComparisonAnalysisController();
        //obj.initiateCompare();
        obj.processRequest();
        
        String urlGenereated = '';
        String requestSite = 'https://orgcomparator.herokuapp.com/compareOrgs?';
              
        // Creating URL for assert 
        urlGenereated = requestSite+'productionRefreshToken='+EncodingUtil.urlEncode(con1.Refresh_Token__c, 'UTF-8')+
                    '&productionOrgType='+EncodingUtil.urlEncode(con1.Org_type__c, 'UTF-8')+                                                                                                                                                  
                    '&sandboxRefreshToken='+EncodingUtil.urlEncode(con2.Refresh_Token__c, 'UTF-8')+
                    '&sandboxOrgType='+EncodingUtil.urlEncode(con2.Org_type__c, 'UTF-8')+
                    '&createdDateBarier='+ EncodingUtil.urlEncode(orgComp[0].Created_Date_Bar__c.format() , 'UTF-8')+
                    '&lastModifiedBarier='+EncodingUtil.urlEncode(orgComp[0].Last_Modified_Date_Bar__c.format(), 'UTF-8')+
                    '&OrgComparision='+EncodingUtil.urlEncode(orgComp[0].id, 'UTF-8')+
                    '&saveToThirdOrg='+EncodingUtil.urlEncode(orgComp[0].Save_Mods_To_Different_Org__c+'', 'UTF-8')+
                    '&createAdditiveMods='+EncodingUtil.urlEncode(orgComp[0].Create_Additive_Mods__c+'', 'UTF-8')+
                    '&rangeComparision='+EncodingUtil.urlEncode(orgComp[0].Compare_between_last_modified_dates__c + '', 'UTF-8')+
            	    '&modSaveOrg='+EncodingUtil.urlEncode(con1.Refresh_Token__c, 'UTF-8')+
                    '&modSaveOrgType='+EncodingUtil.urlEncode(con1.Org_type__c, 'UTF-8')+
            	    '&lastModifiedEndBar='+EncodingUtil.urlEncode((orgComp[0].Last_Modified_Date_End_Bar__c + 1).format(), 'UTF-8');
        

       	
        //check assert
        //system.assertEquals(urlGenereated, obj.url);
        
        //In case of status 'Completed'
        //Inserting Org Comparision
        List<Org_Comparision__c> orgComp2 = new List<Org_Comparision__c>();
        orgComp2.add(new Org_Comparision__c (Change_Request__c = changeRequests.id,Status__c = 'Completed',Release__c = rel.Id,Type__c = 'QA',
                                          Created_Date_Bar__c = date.today(),Last_Modified_Date_Bar__c=date.today(),Source_of_Truth__c=con1.id,
                                          Comparison_Org__c=con2.id,Save_Mods_To__c = con1.id,Save_Mods_To_Different_Org__c = true,
                                          Create_Additive_Mods__c=false,Compare_between_last_modified_dates__c = true,
                                          Last_Modified_Date_End_Bar__c=date.today())); 
        
        insert orgComp2;
        
        //set VFPage Url Parameter 
        PageReference pageRef1 = Page.OrgComparisonAnalysis;
		test.setCurrentPageReference(pageRef1);
        //initializing class
		pageRef1.getParameters().put('Id',orgComp2[0].id);
        pageRef1.getParameters().put('process','Insert');
        OrgComparisonAnalysisController obj2 = new OrgComparisonAnalysisController();
        String errorMsg = 'Comparision is already completed. Create new to restart process.';
        // catch the error
        try{
           //obj2.initiateCompare();
           obj.processRequest(); 
        }
        catch(Exception e){
            system.debug('Error : '+e.getMessage());
            system.assertEquals(e.getMessage(), errorMsg);
        }
        
        //CR-20211012-15511
        Map<String, String> mapOfComp = OrgComparisionUtility.mapAllComponentTypes;
        System.assert(mapOfComp != null);
        System.assert(mapOfComp.size() > 0);
    }
}