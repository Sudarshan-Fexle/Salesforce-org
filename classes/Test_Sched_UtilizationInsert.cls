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
@isTest(seeAllData = false)
public class Test_Sched_UtilizationInsert {
    /**
	 *	Purpose     :   Test Sched_UtilizationInsert Apex Class.
	 *
	 *	Create By   :   Mahendra SWarnkar - 07/11/2017
	 * 
	 *	Revision Log:   v1.0 - Created. (CR-20161005-10203)
	 *
	 *	Code Coverage:	07/11/2017 
    **/
	
    static testMethod void myUnitTest() {
        
        //Intranet Item
        Intranet_Item__c intranetItem = new Intranet_Item__c(Name = 'Test-0' , Active_Status__c = 'Active' , Office_Short_Name__c = 'DC', 
                                                             	Item_Type__c = 'Firm App Link' , Item_Title__c = 'A1');
        insert intranetItem;
        
        //Update User record with Job Level
        System.runAs(new User(Id = UserInfo.getUserId())) {
			
            update new User(Id = UserInfo.getUserId(), Job_Level__c = '10 B1 Early Professional', Office__c = intranetItem.Id, IsManager__c = false);
        }
        
        //Instantiate the Intranet Utilization record
        Intranet_Utilization__c intranetUtilization = new Intranet_Utilization__c( Browser__c = 'Chrome 58.0.3029.110', Click_Type__c = 'Comment', 
                                                                                  	Container_Display_Name__c = 'BoardRoom Home Page', Department__c = 'Enterprise Technologies',
                                                                                  	Device__c = 'Desktop', Division__c = 'Firm Administration', Function__c = 'Firm Administration',
                                                                                  	Intranet_Item__c = intranetItem.id, Job_Level__c = 'B', Manager__c = FALSE, 
                                                                                  	Screensize__c = 'Desktop (1200 pixels)', User__c = UserInfo.getUserId(), Hour__c = system.now().hour());

        //Start Testing from here
        Test.startTest();
		
        //Instantiate the scheduler
        Sched_UtilizationInsert sched = new Sched_UtilizationInsert();
        	
        //Assign the value for intranetUtilization record
        sched.intranetUtilization = intranetUtilization;
        
        //Build Cron Expression.
        Datetime sysTime = System.now().addMinutes(1);
        String CRON_EXP = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        
        //schedule the scheduler
		Id jobId = System.schedule(IntranetUtilizationHelper.SCHEDULER_STATIC_NAME +((math.random()) * 10000), CRON_EXP, sched);
        
        //Stop testing here
        Test.stopTest();
        
        //Query out the Intranet Utilization records
        List<Intranet_Utilization__c> intranetUtilizations = [Select Id, Access_Location__c, Browser__c, Click_Type__c, Department__c, Device__c, Division__c, 
                                                                Function__c, Intranet_Container__c, Intranet_Item__c, Intranet_Schedule__c, 
                                                                Job_Level__c, Manager__c, Office__c, Rating__c, Screensize__c, User__c 
                                                                from Intranet_Utilization__c];
        //Assert on results
        system.assertEquals(1,intranetUtilizations.size() );        
    }
}