/**
    Desription      :   Helper class for Site Content Recommendation functionality
  
    Revision Logs   :   v1.0 - 05/17/2019 - Created
						v1.1 - 08/23/2019 - Victor Hanson - CR-20190823-13279 - removed permissionsThrowError
**/ 
@isTest(SeeAllData=false)
public class Test_SiteContentRedirectExt {
    
    @isTest static void testController(){
        
        //create Institute
        Account acct = TestUtilities.CreateNewAccount(true);
        Account eligibleParentAcct = TestUtilities.CreateNewAccount(false);
        eligibleParentAcct.r_School_Id__c = 12332;
        insert eligibleParentAcct;
        
        //create contact
        Contact c = TestUtilities.CreateNewContact(acct, false);
        c.Email = 'mike@royall.com';
        c.Company_Email__c = 'mike@royall.com';
        c.Bypass_Domain_Validation__c = true;
        insert c;
        
        //create site profile
        Site_Profile__c site_Profile = new Site_Profile__c(Status__c = 'Active',
                                                           Username__c = c.Company_Email__c,
                                                           Password__c = 'test',
                                                           Site_User__c = null,
                                                           Verify__c = '2',
                                                           Contact__c = c.Id,
                                                           r_Institution__c = eligibleParentAcct.Id,
                                                           RecordTypeId = Test_SiteProfileActionController.SITE_PROFILE_RT_ID_ROYALL,
                                                           Type__c = SiteUserHelper.SITE_ROYALL);
        
        
        SiteUserHelper.IsTriggerContact = false; //reset this so the code is triggered correctly
        insert site_Profile; 
        
        //Setting the Eab Site profile to the contact. 
		c.EAB_Com_Site_Profile__c = site_Profile.Id; 
        update c;
        
        ApexPages.StandardController sc = new ApexPages.standardController(c);
        
        siteContentRedirectExt redirectExit = new siteContentRedirectExt(sc);
        //08/23/2019 - Victor Hanson - CR-20190823-13279 - removed permissionsThrowError
        /*try {
            siteContentRedirectExt.permissionsThrowError();
        } catch (Exception e) {
            System.assertEquals('You do not have permissions to access this Tool.', e.getMessage());
        }*/
        
        String URl = redirectExit.ReturnToSiteProfile;
    }	
}