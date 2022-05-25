/**
    Desription      :   redirect controller extension for Site Content
  
    Revision Logs   :   v1.0 - Created - 06/21/2019 - Dipesh Gupta
						v1.1 - Modified - 08/23/2019 - Victor Hanson - CR-20190823-13279 - removed permissionsThrowError
**/ 
public with sharing class siteContentRedirectExt {
    
    //Variables
    public Contact con{get; set;}
    public Boolean isContactHaveEABSiteProfile {get; set;}

    public siteContentRedirectExt(ApexPages.StandardController controller) {
        
        //Grab our Record
        con= (Contact)controller.getRecord();
        
        con = [Select Id, Name, EAB_com_Site_Profile__c From Contact Where Id =: con.Id];
        
        isContactHaveEABSiteProfile = false;
        
        //Check for the Eab com site profiles. 
        if(String.isNotBlank(con.EAB_com_Site_Profile__c))
            isContactHaveEABSiteProfile = true;
        
        //VH - 08/23/2019 - CR-20190823-13279 - removed permissionsThrowError
        //Run Permissions Check
        //permissionsThrowError();
        
        redirectURL();

    }

    // URL to return to our Site Profile
    public String ReturnToSiteProfile {
        get {
            if(ReturnToSiteProfile == null) {
                ReturnToSiteProfile = '';
                ReturnToSiteProfile = ApexPages.currentPage().getParameters().get('retURL');
                if (ReturnToSiteProfile == null)
                    ReturnToSiteProfile = '/';
            }
            return ReturnToSiteProfile;
        }
        set;
    }
    
    private PageReference redirectURL() {

        string urlString = '/apex/SiteContentRecommendations?Id=' + con.Id;
        PageReference pageref = new PageReference(urlString);
        return pageref;
    }
    
	//VH - 08/23/2019 - CR-20190823-13279 - removed permissionsThrowError
    /*public static void permissionsThrowError(){

        //Run helper class to see if the user has the Access to the Permission
        CustomPermissionsReader cpr = new CustomPermissionsReader();
        Boolean scrUserAccess = cpr.hasPermission('Site_Content_Recommendations_Access');

        //Throw an exception if needed
        if (scrUserAccess = false) {
            throw new CustomException('You do not have permissions to access this Tool.');
        }                                       

    }*/


}