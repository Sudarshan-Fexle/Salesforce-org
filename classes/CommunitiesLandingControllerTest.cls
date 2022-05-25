/**
 * An apex page controller that takes the user to the right start page based on credentials or lack thereof
 * Modified By - Abhishek Mishra - 06/28/2021 - CR-20210517-15151 - Test Class issue Fixes
 */
@IsTest public with sharing class CommunitiesLandingControllerTest 
{
    @IsTest(SeeAllData=true) public static void testCommunitiesLandingController() 
    {
        Test.startTest();
        
        // Instantiate a new controller with all parameters in the page
        CommunitiesLandingController controller = new CommunitiesLandingController();
        //Added By - Abhishek Mishra - 06/28/2021 - called the Controller Class Method  - Start Here
        controller.forwardToStartPage();
        //Added By - Abhishek Mishra - 06/28/2021 - called the Controller Class Method  - End Here
        
        Test.stopTest();
    }
}