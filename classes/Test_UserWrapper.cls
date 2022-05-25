/**
 *   Purpose         :   Test class for userWrapper
 *            
 *   Create By       :   Abhishek Mishra
 * 
 *   Created Date    :   07/07/2021
 *
 *   Revision Log    :   V_1.0 - Created - CR-20211005-15489 - Abhishek Mishra
 *   
 *   Coverage        :   V_1.0 - 100%
 *
 **/
@isTest(seeAllData = false)
public with sharing class Test_UserWrapper 
{
    static testMethod void testUserWrapper()
    {
        Util.byPassAllTriggers = true;
        
        //Create User
        User usr = TestUtilities.CreatenewUser(true);
        
        Util.byPassAllTriggers = false;
        
        String label1 = 'test label';
        String label2 = 'test label';
        String label3 = 'test';
        
        Test.startTest();
        
        //Calling UserWrapper Class
        userWrapper usrWrapper1 = new userWrapper(usr,label1);
        userWrapper usrWrapper2 = new userWrapper(usr,label2);
        userWrapper usrWrapper3 = new userWrapper(usr,label3);
        
        System.assertEquals(0, usrWrapper1.compareTo(usrWrapper2));
        System.assertEquals(1, usrWrapper1.compareTo(usrWrapper3));
        System.assertEquals(-1, usrWrapper3.compareTo(usrWrapper2));
        
        Test.stopTest();
    }
}