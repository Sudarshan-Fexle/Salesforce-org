/* 
* Name          : shift_get_fiscal_year
* Author        : Edward Chow
* Description   : Class to calculate the current Fiscal Year
*            
* Maintenance History: 
* Date --------- Name ------------Version---Remarks 
* 05/06/2013    Edward Chow			1.0		Initial
* 06/28/2016	Rajeev Jain			1.1		SFDC Royall Migration - Migrated from Royall Enviournment to Corporate Instance			
* 04/07/2017	Mahendra Swarnkar	1.2		CR-20170405-10819 - Updated the Fiscal year month to 7th month i.e. July
*											and Updated the Current fiscal year calculation on given the month
*
*/
public class shift_get_fiscal_year{

    //V_1.2 - Modified By Mahendra Swarnkar - 4//7/2017 - CR-20170405-10819.
    //Return the current fiscal year
    public static integer current() {
    
        integer currentFY;
        date currentDate = date.today();
        integer currentMonth = currentDate.month();
        integer currentYear = currentDate.year(); 
        
        //V_1.2 - Modified By Mahendra Swarnkar - 4//7/2017 - CR-20170405-10819 - Updated the Fiscal year month to 7th month i.e. July 
        //and Updated the Current fiscal year calculation on given the month - Starts from here
            
        /*
        // Query to get the Org FY month and the Starting or Ending month flag                                         
        Organization org = [select Name, FiscalYearStartMonth, UsesStartDateAsFiscalYearName from Organization where id =: Userinfo.getOrganizationId()];
        
        integer fiscalYearMonth = org.FiscalYearStartMonth;
        boolean isStartMonth = org.UsesStartDateAsFiscalYearName;
       
        //Determine the current Fiscal Year given the month and isStartMonth flag 
        if( currentMonth >= fiscalYearMonth){
            if( isStartMonth ) currentFY = currentYear;
                else currentFY = currentYear + 1;
        }
        else if (currentMonth < fiscalYearMonth){
            if( isStartMonth ) currentFY = currentYear - 1;
                else currentFY = currentYear;
        }
        */
        
        //Get the Fiscal year start month
        integer fiscalYearMonth = Integer.valueOf(System.Label.FiscalYearStartMonth);
        
        //Determine the current Fiscal Year given the month
        if( currentMonth >= fiscalYearMonth)
        {
			currentFY = currentYear + 1;
        }
        else if (currentMonth < fiscalYearMonth)
        {
			currentFY = currentYear;
        }
        //V_1.2 - Modified By Mahendra Swarnkar - 4//7/2017 - CR-20170405-10819 - Ends here
        
        //Return statement
		return currentFY;
    }
}