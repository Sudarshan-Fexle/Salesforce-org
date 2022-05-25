/**
 *  Purpose         :   This class to work as a generic class for all the object where Name need to be populeted by "Will Auto Populate"
 *
 *  Created By      :   Bhavi Sharma
 *
 *  Created Date    :   08/30/2014
 *
 *  Revision Logs   :   V_1.0 - Created
 * 					:   V_1.1 - Updated the Class for the Staff assignment auto population.CR-20180917-12602 - Abhinav Sharma
 *
 **/ 
public with sharing class WillAutoPopulateExtension {
    
    //Redirect Page
    PageReference redirectPage;
    
    //Standard Controller Constructor
    public WillAutoPopulateExtension(ApexPages.StandardController controller) {
        
        String cf_Prefix = 'CF';
        String lkID_Suffix = '_lkid';
        String  noOveride = 'nooverride';
        String willAutoPopulate = 'Will Auto-Populate';
        String name = 'Name';
            
        //Create a new Pagereference 
        redirectPage = new PageReference('/' + controller.getRecord().getSobjectType().getDescribe().getKeyPrefix() + '/e' );
        
        //Check remove sfdc.override parameter from page
        //Loop through the parameters and add in new page referece sfdc.override
        for(String key : ApexPages.currentPage().getParameters().keySet()) {
            
           //in in new reference and remove 
            if(key != 'save_new' && key != cf_Prefix+Label.STAFF_ASSIGNMENT_ACTIVE_INSTITUTION_ID && key != cf_Prefix+Label.STAFF_ASSIGNMENT_ACTIVE_INSTITUTION_ID + lkID_Suffix)
                redirectPage.getParameters().put(key, ApexPages.currentPage().getParameters().get(key));
            
            
            if(key == cf_Prefix+Label.STAFF_ASSIGNMENT_ACTIVE_INSTITUTION_ID) {
            	redirectPage.getParameters().put(cf_Prefix+Label.STAFF_ASSIGNMENT_INSTITUTION_ID, ApexPages.currentPage().getParameters().get(key));
            }
            if(Key == cf_Prefix+Label.STAFF_ASSIGNMENT_ACTIVE_INSTITUTION_ID + lkID_Suffix)
                redirectPage.getParameters().put(cf_Prefix+Label.STAFF_ASSIGNMENT_INSTITUTION_ID + lkID_Suffix, ApexPages.currentPage().getParameters().get(key));
        }
        
        //nooverride parameter
        redirectPage.getParameters().put(noOveride, '1');
        redirectPage.getParameters().put(name, willAutoPopulate);
    }
    
    /**
     *  @description    :   This method is to redirect the user to the standard page and add a Name parameter in URL
     * 
     *  @args           :   
     * 
     *  @return         :   Standard PageReference
     **/
    public PageReference redirect() {
        
        //redirect to 
        return redirectPage;
    } 
}