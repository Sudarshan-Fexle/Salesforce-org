/** Description     :   Test class for IntranetType
  * 
  * Created Date    :   07/27/2021
  *
  * Created By      :   Neha Sharma
  *  
  * Current vision  :   v1.0    
  *  
  * Revision Logs   :   v1.0 - Created - CR-20211005-15489
  *         	
  **/   
@isTest(SeeAllData = true)
private class Test_IntranetType {
    //Test method to initialize UserSession class
    static testMethod void myUnitTest() {
        //Calling Intranet Type
        IntranetType it = new IntranetType();
        //Creating instance of UserSession class
        IntranetType.UserSession us = new IntranetType.UserSession();
    }
}