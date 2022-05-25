/**
 * 
 * 	Description		:	Test class for formattedDateTimeController
 * 
 * 	Revision Logs		:	v1.0 - 07/20/2020 - CR-20200708-14279 - Victor Hanson - Created
 * 					v1.1 - 08/04/2020 - CR-20200804-14400 - Victor Hanson - updated to test AM/PM to a.m./p.m. conversion
 * 
 **/ 
@isTest
private class Test_FormattedDateTimeController {
	
    static testMethod void testFormatDateTime() {
        Date myDate = Date.newInstance(2020, 7, 21);
        Time myTime = Time.newInstance(10, 58, 0, 0);
        DateTime dt = DateTime.newInstanceGmt(myDate, myTime);
        String format = 'EEEE, MMM d | kk:mm a';
        String timezone = 'America/New_York';
        
        //instantiate the controller and set the format/timezone/dateTime
        FormattedDateTimeController controller = new FormattedDateTimeController();
        controller.defined_format = format;
        controller.timezone = timezone;
        controller.date_time = dt;
        
        //verify the results
        system.assertEquals('Tuesday, Jul 21 | 06:58 AM', controller.getFormattedDatetime());
        
        //add [] around the am/pm symbol [a] which tells our controller to replace AM/PM with a.m./p.m.
        format = 'EEEE, MMM d | kk:mm [a]';
        controller.defined_format = format;
        //verify the results
        system.assertEquals('Tuesday, Jul 21 | 06:58 a.m.', controller.getFormattedDatetime());
    }
}