/**
* This class contains unit tests for validating the behavior of Apex classes
* and triggers.
*
* Unit tests are class methods that verify whether a particular piece
* of code is working properly. Unit test methods take no arguments,
* commit no data to the database, and are flagged with the testMethod
* keyword in the method definition.
*
* All test methods in an organization are executed whenever Apex code is deployed
* to a production organization to confirm correctness, ensure code
* coverage, and prevent regressions. All Apex classes are
* required to have at least 75% code coverage in order to be deployed
* to a production organization. In addition, all triggers must have some code coverage.
* 
* The @isTest class annotation indicates this class only contains test
* methods. Classes defined with the @isTest annotation do not count against
* the organization size limit for all Apex scripts.
*
* See the Apex Language Reference for more information about Testing and Code Coverage.
*/
/**
*   Purpose         :   Test class for DateOffsetCalculator
*            
*   Create By       :   Dipesh Gupta
* 
*   Created Date    :   12/30/2019
*
*   Revision Log    :   V_1.0 - Created - Dipesh Gupta 
*   
*   Coverage        :   V_1.0 - 
*
**/
@isTest(seeAllData = false)
private class Test_DateOffsetCalculator 
{
    static testMethod void testDateOffsetCalculotor()
    {
        Test.startTest();
        List<String> weekDays = new List<String>{'Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'};
        Date myDate = date.newinstance(2019, 12, 29);
        List<Date> returnDateForSun = new List<Date>();
        for(Integer i = 0 ; i< 7 ; i++)
        {
            returnDateForSun.add(Util.returnDateOfSpecificDayOfSpecificWeek(weekDays[i], -4, null, myDate.addDays(i)));
        }
        System.assertEquals(1,returnDateForSun[0].day());
        System.assertEquals(2,returnDateForSun[1].day());
        System.assertEquals(3,returnDateForSun[2].day());
        System.assertEquals(4,returnDateForSun[3].day());
        System.assertEquals(5,returnDateForSun[4].day());
        System.assertEquals(6,returnDateForSun[5].day());
        System.assertEquals(7,returnDateForSun[6].day());
        
        Date myDateMon = date.newinstance(2019, 12, 30);
    	List<Date> returnDateForMon = new List<Date>();
        for(Integer i = 0 ; i < 7 ; i++)
        {
            returnDateForMon.add(Util.returnDateOfSpecificDayOfSpecificWeek(weekDays[i], -4, null, myDateMon.addDays(i)));
        }
        System.assertEquals(8, returnDateForMon[0].day());
        System.assertEquals(2, returnDateForMon[1].day());
        System.assertEquals(3, returnDateForMon[2].day());
        System.assertEquals(4, returnDateForMon[3].day());
        System.assertEquals(5, returnDateForMon[4].day());
        System.assertEquals(6, returnDateForMon[5].day());
        System.assertEquals(7, returnDateForMon[6].day());
        
        Date myDateTue = date.newinstance(2019, 12, 31);
    	List<Date> returnDateForTue = new List<Date>();
        for(Integer i = 0 ; i < 7 ; i++)
        {
        	 returnDateForTue.add(Util.returnDateOfSpecificDayOfSpecificWeek(weekDays[i], -4, null, myDateTue.addDays(i)));  
        }
        System.assertEquals(8, returnDateForTue[0].day());
        System.assertEquals(2, returnDateForTue[1].day());
        System.assertEquals(3, returnDateForTue[2].day());
        System.assertEquals(4, returnDateForTue[3].day());
        System.assertEquals(5, returnDateForTue[4].day());
        System.assertEquals(6, returnDateForTue[5].day());
        System.assertEquals(14, returnDateForTue[6].day());
        
        
        Date myDateWed = date.newinstance(2020, 01, 01);
        List<Date> returnDateForWed = new List<Date>();
        for(Integer i = 0 ; i < 7 ; i++)
        {
            returnDateForWed.add(Util.returnDateOfSpecificDayOfSpecificWeek(weekDays[i], -4, null, myDateWed.addDays(i)));
        }
        System.assertEquals(8, returnDateForWed[0].day());
		System.assertEquals(2, returnDateForWed[1].day());
        System.assertEquals(3, returnDateForWed[2].day());
        System.assertEquals(4, returnDateForWed[3].day());
        System.assertEquals(5, returnDateForWed[4].day());
        System.assertEquals(13, returnDateForWed[5].day());
        System.assertEquals(14, returnDateForWed[6].day());
        
        Date myDateThu = date.newinstance(2020, 01, 02);
        List<Date> returnDateForThu = new List<Date>(); 
        for(Integer i = 0 ; i < 7 ; i++)
        {
            returnDateForThu.add(Util.returnDateOfSpecificDayOfSpecificWeek(weekDays[i], -4, null, myDateThu.addDays(i)));
        }
        System.assertEquals(8, returnDateForThu[0].day());
        System.assertEquals(2, returnDateForThu[1].day());
        System.assertEquals(3, returnDateForThu[2].day());
        System.assertEquals(4, returnDateForThu[3].day());
        System.assertEquals(12, returnDateForThu[4].day());
        System.assertEquals(13, returnDateForThu[5].day());
        System.assertEquals(14, returnDateForThu[6].day());
        
        Date myDateFri = date.newinstance(2020, 01, 03);
        List<Date> returnDateForFri = new List<Date>();
        for(Integer i = 0 ; i < 7 ; i++)
        {
            returnDateForFri.add(Util.returnDateOfSpecificDayOfSpecificWeek(weekDays[i], -4, null, myDateFri.addDays(i)));
        }
        System.assertEquals(8, returnDateForFri[0].day());
        System.assertEquals(2, returnDateForFri[1].day());
        System.assertEquals(3, returnDateForFri[2].day());
        System.assertEquals(11, returnDateForFri[3].day());
        System.assertEquals(12, returnDateForFri[4].day());
        System.assertEquals(13, returnDateForFri[5].day());
        System.assertEquals(14, returnDateForFri[6].day());
        
        Date myDateSat = date.newinstance(2020, 01, 04);
        List<Date> returnDateForSat = new List<Date>();
        for(Integer i = 0 ; i < 7 ; i++)
        {
            returnDateForSat.add(Util.returnDateOfSpecificDayOfSpecificWeek(weekDays[i], -4, null, myDateSat.addDays(i)));
        }
        System.assertEquals(8, returnDateForSat[0].day());
        System.assertEquals(2, returnDateForSat[1].day());
        System.assertEquals(10, returnDateForSat[2].day());
        System.assertEquals(11, returnDateForSat[3].day());
        System.assertEquals(12, returnDateForSat[4].day());
        System.assertEquals(13, returnDateForSat[5].day());
        System.assertEquals(14, returnDateForSat[6].day());
        
        Test.stopTest();
    }
    
    static testMethod void test_NegativeUseCase()
    {
        Date myDate = date.newinstance(2019, 12, 29);
        Test.startTest();
        
        try
        {
        	Date returnDateForSpecifyDayWeek = Util.returnDateOfSpecificDayOfSpecificWeek('Sunday', -4, 4, myDate );   
        }
        Catch(Exception e)
        {
        	Boolean expectedExceptionThrown =  e.getMessage().contains('You can not specify both weeks and days for calculation prospective. Please specify only one of them.') ? true : false;
			System.AssertEquals(expectedExceptionThrown, true);  
        }
        try
        {
        	Date returnDate = Util.returnDateOfSpecificDayOfSpecificWeek('Sunday', -4, null, null );
        }
        Catch(Exception e)
        {
        	Boolean expectedExceptionThrown =  e.getMessage().contains('Please specify a date value for further calculation.') ? true : false;
			System.AssertEquals(expectedExceptionThrown, true);  
        }
        try
        {
            Date returnDateWhichdayAsBlank = Util.returnDateOfSpecificDayOfSpecificWeek(null, -4, null, myDate );     
        }
        Catch(Exception e)
        {
        	Boolean expectedExceptionThrown =  e.getMessage().contains('Please specify the day value for the date for further calculation') ? true : false;
			System.AssertEquals(expectedExceptionThrown, true);  
        }
        
        try
        {
            Date returnDatehowManyWeekBackOrAheadAsNull = Util.returnDateOfSpecificDayOfSpecificWeek('Friday', 0, null, myDate );     
        }
        Catch(Exception e)
        {
        	Boolean expectedExceptionThrown =  e.getMessage().contains('Please specify a non null and non zero value for week.') ? true : false;
			System.AssertEquals(expectedExceptionThrown, true);  
        }
        
        try
        {
            Date returnDateDaysAsNull = Util.returnDateOfSpecificDayOfSpecificWeek('Monday', null, 0, myDate );     
        }
        Catch(Exception e)
        {
        	Boolean expectedExceptionThrown =  e.getMessage().contains('Please specify a non null and non zero value for days.') ? true : false;
			System.AssertEquals(expectedExceptionThrown, true);  
        }
        
        try
        {
        	Date returnDateDayAndWeekAsNull = Util.returnDateOfSpecificDayOfSpecificWeek('Friday', null, null, myDate );  
        }
        Catch(Exception e)
        {
        	Boolean expectedExceptionThrown =  e.getMessage().contains('Please specify atleast either weeks value or days values for calculation prospective.') ? true : false;
			System.AssertEquals(expectedExceptionThrown, true);  
        }
        
        try
        {
        	DateOffsetCalculator.returnOffsetValue(null,null);
        }
        Catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Please specify a non null day value for calculation.') ? true : false;
			System.AssertEquals(expectedExceptionThrown, true); 
        }
        try
        {
        	DateOffsetCalculator.returnOffsetValue('Monday','Monnday');
        }
        Catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Please specify a valid day value for calculation.') ? true : false;
			System.AssertEquals(expectedExceptionThrown, true); 
        }
        Test.stopTest();
    }
}