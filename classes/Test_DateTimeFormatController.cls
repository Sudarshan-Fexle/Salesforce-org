/**
 * 
 *  Description	    :	Test class for DateTimeFormatController
 * 
 *  Created By      :   Neha Sharma  
 * 
 *  Created Date    :   06/07/2021
 * 
 *  Revision Logs   :   V_1.0 - Created - CR-20211005-15489 - To increase code coverage
 **/ 
@isTest
private class Test_DateTimeFormatController {
    
    //Method to check functionality
    static testMethod void testDateTimeFormat() {
        DateTime myDateTime = DateTime.newInstance(1997, 1, 31, 7, 8, 16);
        String myFormatString = 'G';
        String myTimezone = 'GMT+5:30';
        
        //instantiate the controller 
        DateTimeFormatController controller = new DateTimeFormatController();
        //Calling method with values
        controller.setThisValue(myDateTime);
        controller.setThisFormatString(myFormatString);
        controller.setThisTimezone(myTimezone);
        
        //Fetching the value from controller
        DaTeTime value = controller.getThisValue();
        //Assert 
        System.assertEquals(myDateTime, value);
        
        //Fetching the value from controller
        String formatStr = controller.getThisFormatString();
        //Assert 
        System.assertEquals(myFormatString, formatStr);
        
        //Fetching the value from controller
        String tmZone = controller.getThisTimezone();
        //Assert
        System.assertEquals( myTimezone, tmZone);
        
        controller.getFormatedValue();
    }
    
    //Functionality to check When getThisTimezone() == null
    static testMethod void testDateTimeFormat2() {
        DateTime myDateTime = DateTime.newInstance(2000, 2, 20, 6, 8, 16);
        String myFormatString = 'G';
        String myTimezone = null;
        
        //instantiate the controller 
        DateTimeFormatController controller = new DateTimeFormatController();
        //Calling method with values
        controller.setThisValue(myDateTime);
        controller.setThisFormatString(myFormatString);
        controller.setThisTimezone(myTimezone);
        
        //Fetching the value from controller
        DaTeTime value = controller.getThisValue();
        //Assert 
        System.assertEquals(myDateTime, value);
        
        //Fetching the value from controller
        String formatStr = controller.getThisFormatString();
        //Assert 
        System.assertEquals(myFormatString, formatStr);
        
        //Fetching the value from controller
        String tmZone = controller.getThisTimezone();
        //Assert
        System.assertEquals( myTimezone, tmZone);
        
        controller.getFormatedValue();
    }
}