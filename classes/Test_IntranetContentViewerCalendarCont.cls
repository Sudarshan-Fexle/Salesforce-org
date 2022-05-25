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
@isTest(SeeAllData = false)
private class Test_IntranetContentViewerCalendarCont {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        
         //Intranet Container
        Intranet_Container__c intranetContainer = new Intranet_Container__c(Name = 'Test-2', CurrencyIsoCode = 'USD', Content_Types_Allowed__c = 'App Link');
        insert intranetContainer;
        
        //Intranet Item
        Intranet_Item__c intranetItem = new Intranet_Item__c(Name = 'Test-0' , Active_Status__c = 'Active' , 
                                                                Item_Type__c = 'App Link' , Item_Title__c = 'A1');
        insert intranetItem;
        
        //Intranet Schedule
        Intranet_Schedule__c intranetSchedule = new Intranet_Schedule__c(Name = 'Test4' , Intranet_Container__c = intranetContainer.Id, Intranet_Item__c = intranetItem.Id,
                                                                                Start_Date_Time__c = DateTime.Now()+1, End_Date_Time__c = DateTime.Now()+5 );
        insert intranetSchedule;
        
        //Instantiate Intranet Content Viewer
        
        IntranetContentViewerCalendarController  calCont = new IntranetContentViewerCalendarController();
        
        //Create New Instance of Intranet Container
        IntranetContainer icContainer;
        calCont.setMainContainer(icContainer);
        
        icContainer = new IntranetContainer(intranetContainer);
        
        
        calCont.setMainContainer(icContainer);
        
        //Make Date List and Pass to Controller
        Date todayDate = Date.Today();
        
        //Start of Week
        Date startDate = todayDate.toStartOfWeek();
        
        //Add current Week Date in DateList
        List<Date> dateList;
        
        calCont.setWeekDates(dateList);
        
        dateList = new List<Date>(dateList);
        
        //Add dates to List
        for(Date dt=startDate;dt<=startDate.addDays(5);dt=dt.addDays(1)){
            dateList.add(dt);
        }
        calCont.setWeekDates(dateList);
        
        //Get WeekList
        List<IntranetContentViewerCalendarController.CalendarWrapper> wrapperList = calCont.getWrapperList();
        
        calCont.getWeekDates();
        
        calCont.getMainContainer();
        calCont.getMonth();
    }
}