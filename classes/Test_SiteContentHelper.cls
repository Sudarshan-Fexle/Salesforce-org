/**
 *   Purpose:    Test class for SiteContentHelper
 *   
 *   Revision Log:      v1.00 - 07/29/2019 - CR-20190510-13101 - Victor Hanson - Created
 * 
**/
@isTest
public class Test_SiteContentHelper {
	
    @testSetup
    static void setup() {
        
        //create 2 programs
        List<Program__c> programs = new List<Program__c>();
        Program__c pEDAF = new Program__c(name='EDAF', Program_Acronym__c='EDAF');
        Program__c pEDPV = new Program__c(name='EDPV', Program_Acronym__c='EDPV');
        programs.add(pEDAF);
        programs.add(pEDPV);
        util.bypassAllTriggers = true;
        insert programs;
        
        //create web program access
        List<Web_Program_Access__c> wpas = new List<Web_Program_Access__c>();
        Web_Program_Access__c wpaEDAF = new Web_Program_Access__c(A_com_Program_ID__c = 100, 
                                                                  Description__c = 'Test', 
                                                                  Program_Code_to_Member__c = 'EDAF');
        Web_Program_Access__c wpaEDPV = new Web_Program_Access__c(A_com_Program_ID__c = 200, 
                                                                  Description__c = 'Test', 
                                                                  Program_Code_to_Member__c = 'EDPV');
        wpas.add(wpaEDAF);
        wpas.add(wpaEDPV);
        insert wpas;
    }
    
    /**
     * 
     * @description: test that the site content helper creates the Site Content & related Site Content MtM records
     * 
     **/
    static testmethod void test_SiteContentHelper() {
        //prepare a post wrapper
        SitePostWrapper post = new SitePostWrapper();
        post.guid = 'abc123';
        post.id_x = 'abc123';
        post.post_title = 'test';
        post.webProgramAccessIds = new Set<String> { '100', '200' };
        
        //instantiate site user and set the post variable
        SiteUser sUser = new SiteUser();
        sUser.post = post;
        
        //start the test
        test.startTest();
        
        //instantiate the SiteContentHelper class
        SiteContentHelper helper = new SiteContentHelper(sUser, post.guid);
        
        //stop the test
        test.stopTest();
        
        //verify the Site Content record was generated
        List<Site_Content__c> siteContents = [SELECT Id, Web_Program_Access_Ids__c, GUID__c,
                                              (SELECT Id, Program__c, Web_Program_Access__c, Web_Program_Access_Id__c, Program_Acronym__c FROM Site_Content_MtM__r)
                                              FROM Site_Content__c WHERE GUID__c = :post.guid];
        
        //assertions
        system.assertEquals(1, siteContents.size());
        system.assertEquals(2, sitecontents[0].Site_Content_MtM__r.size());
        
        //verify the site content MtM were created and related to the correct programs
        for (Site_Content_MtM__c sContentMtM : sitecontents[0].Site_Content_MtM__r) {
            
            if (sContentMtM.Web_Program_Access_Id__c == '100') {
                system.assertEquals('EDAF', sContentMtM.Program_Acronym__c);
            }
            else if (sContentMtM.Web_Program_Access_Id__c == '200') {
                system.assertEquals('EDPV', sContentMtM.Program_Acronym__c);
            }
        }
    }
    
    /**
     * 
     * @description: test that the site content helper updates the Site Content & related Site Content MtM records if they already exist
     * 
     **/
    static testmethod void test_SiteContentHelper_Update() {
        
        //get one of the programs created in test setup
        Program__c pEDAF = [SELECT Id FROM Program__c WHERE Program_Acronym__c = 'EDAF'];
        
        //get the related Web Program Access record for EDAF
        Web_Program_Access__c wpaEDAF = [SELECT Id FROM Web_Program_Access__c WHERE Program_Code_to_Member__c = 'EDAF'];
        
        //create the Site Content & Site Content MtM records
        Site_Content__c sContent = new Site_Content__c(Name='Test Content',
                                                      GUID__c = 'abc123',
                                                      Title__c = 'Test Content',
                                                      URL__c = 'http://www.google.com/',
                                                      Web_Program_Access_Ids__c = '100');
        insert sContent;
        
        //prepare a post wrapper
        SitePostWrapper post = new SitePostWrapper();
        post.guid = 'abc123';
        post.id_x = 'abc123';
        post.post_title = 'Test Content Updated!';
        post.webProgramAccessIds = new Set<String> { '200' };
        
        //instantiate site user and set the post variable
        SiteUser sUser = new SiteUser();
        sUser.post = post;
        
        //start the test
        test.startTest();
        
        //instantiate the SiteContentHelper class
        SiteContentHelper helper = new SiteContentHelper(sUser, post.guid);
        
        //stop the test
        test.stopTest();
        
        //verify the Site Content record was generated
        List<Site_Content__c> siteContents = [SELECT Id, Web_Program_Access_Ids__c, GUID__c,Title__c,
                                              (SELECT Id, Program__c, Web_Program_Access__c, Web_Program_Access_Id__c, Program_Acronym__c FROM Site_Content_MtM__r)
                                              FROM Site_Content__c WHERE Id = :sContent.Id];
        
        //assertions
        system.assertEquals(1, siteContents.size());
        system.assertEquals(post.post_title, sitecontents[0].Title__c);
        system.assertEquals('200', sitecontents[0].Web_Program_Access_Ids__c);
        //system.assertEquals(1, sitecontents[0].Site_Content_MtM__r.size());
        
        //verify the site content MtM were created and related to the correct programs
        system.assertEquals('EDPV', sitecontents[0].Site_Content_MtM__r[0].Program_Acronym__c);
    }
    
    /**
     * 
     * @description: test that the site content helper adds the Site Content MtM records when inserted 
     * 
     **/
    static testmethod void test_SiteContentHelper_TriggerInsert() {
        
        //create the Site Content & Site Content MtM records
        Site_Content__c sContent = new Site_Content__c(Name='Test Content',
                                                      GUID__c = 'abc123',
                                                      Title__c = 'Test Content',
                                                      URL__c = 'http://www.google.com/',
                                                      Web_Program_Access_Ids__c = '100,200');
        insert sContent;
        
        
        //verify the Site Content record was generated
        List<Site_Content__c> siteContents = [SELECT Id, Web_Program_Access_Ids__c, GUID__c,
                                              (SELECT Id, Program__c, Web_Program_Access__c, Web_Program_Access_Id__c, Program_Acronym__c FROM Site_Content_MtM__r)
                                              FROM Site_Content__c WHERE GUID__c = :sContent.GUID__c];
        
        //assertions
        system.assertEquals(1, siteContents.size());
        system.assertEquals(2, sitecontents[0].Site_Content_MtM__r.size());
        
        //verify the site content MtM were created and related to the correct programs
        for (Site_Content_MtM__c sContentMtM : sitecontents[0].Site_Content_MtM__r) {
            
            if (sContentMtM.Web_Program_Access_Id__c == '100') {
                system.assertEquals('EDAF', sContentMtM.Program_Acronym__c);
            }
            else if (sContentMtM.Web_Program_Access_Id__c == '200') {
                system.assertEquals('EDPV', sContentMtM.Program_Acronym__c);
            }
        }
    }
    
}