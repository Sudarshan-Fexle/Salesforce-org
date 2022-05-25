/*
    Purpose         :   Test methods to verify profile functionality.
                
    Create By       :   Victor Hanson
    
    Created Date    :   10/15/2015
    
    Revision Log    :   v1.0 Created - Victor Hanson - 10/15/2015 - CR-20151008-9307
						v1.1 Modified By - Mahendra Swarnakr - 1/5/2017 - CR-20161215-10546 - Added a new test Method 'testProfileAndPermissionsetVerification, SplitString'
                        v1.2 Modified By - Mahendra Swarnakr - 1/5/2017 - CR-20170315-10760 - Updated the test Method "testProfileAndPermissionsetVerification" to by pass the user assignments for "Chatter Free User" profile and "Accounting and Billing - Year" Permission set
						v1.3 Modified By - Colin McGloin - 10/10/2017 - CR-20170920-11384 - Updated the testmethod "testViewAllData" since two of the profiles will no longer have View All Data after Apollo deploys
						V1.4 Modified By - Rajeev jain - 02/12/2018 - Deployment of CR-20180126-11909 into the Production, fixing due to production failure
*/
@isTest
private class Test_ProfilePermissions {
	
    /**
     * 
     * @description: Method to Split string into Set.
     * 
     **/
    //Added By - Mahendra Swarnakr - 1/5/2017 - CR-20161215-10546
    public static Set<String> SplitString(String StrValue){
        
        //Set to hold Split value of string
        Set<String> setSplitString = new Set<String>();
        
        //Loop over splict value of string
        for(String ps : StrValue.split(',')) {
            if(String.isNotBlank(ps)
              	&& String.isNotBlank(ps.trim())){
                ps = ps.trim();
                setSplitString.add(ps);
            }
        }
        
        //Return Set of Split string
        return setSplitString;
    }
    
    /**
     * 
     * @description: verify the ABC Dataloader and Finance Ops profiles have the "View All Data" permission enabled.
     * 
     **/
    //Removed Profile References by Colin McGloin - These profiles ('Finance Ops', 'Specialist') no longer have "View All Data" permissions - Apollo Project
    static testMethod void testViewAllData() {
        set<string> profilesWithViewAllData = new set<string> { 'ABC Dataloader' };
        list<Profile> profiles = [SELECT Id, Name, PermissionsViewAllData FROM Profile WHERE Name IN :profilesWithViewAllData];
        for (Profile p : profiles) {
            system.assertEquals(true, p.PermissionsViewAllData, 'The profile "' + p.Name + '" should have the View All Data permission enabled.');
        }
    }
    
   
}