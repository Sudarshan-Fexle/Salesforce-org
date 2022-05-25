/**
 *  Description     :   Test Class for CustomLinkRetrieveController
 *
 *  Created By      :   Neha Sharma  
 * 
 *  Created Date    :   06/07/2021
 * 
 *  Revision Logs   :   V_1.0 - Created - CR-20211005-15489 - To increase code coverage
 **/
@Istest(seeAllData = true)
public class Test_CustomLinkRetrieveController {
    //Method to test the functionality. 
    @istest static void testCustomLinkRetrieveController() {
        //Fetch records of homePageComponents
        List<Home_Page_Component__mdt> homePageComponents = [Select Id, Label From Home_Page_Component__mdt];
        
        //Fetch records of homePageLinks
        List<Home_Page_Link__mdt> homePageLink = [SELECT Id, Label, MasterLabel, Custom_Link_Name__c,
                                                  Custom_Link_URL__c, Home_Page_Component__c, Custom_Link_URL_2__c FROM Home_Page_Link__mdt];
        
        //home page component name to fetch the records that matches the criteria
        String homePageComponentName = 'Board Room';
        List<CustomLinkRetrieveController.ResponseWrapper> res = CustomLinkRetrieveController.getCustomLinksDetails(homePageComponentName);
        
        //Assert to check wrapper object is created or not
        System.assert(res.size()>0);
        
        //home page component name to fetch the records that doesnot matches the criteria and gets error message
        String homePageComponentNme = 'Administration';
        try{
            CustomLinkRetrieveController.getCustomLinksDetails(homePageComponentNme);
        }
        catch(Exception e){
            
            //Assert to check the error message
            System.assertEquals(System.Label.Error_No_Home_Page_Component_Exists, e.getMessage());
        }    
    }
}