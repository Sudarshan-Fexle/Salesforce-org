/*
Purpose         :   AddProgramRulesManagerQueryBuilder
Created By      :   Saurabh Kumar
Created Date    :   03/18/2021
Current Version :   v1.0
Revision Log    :   V_1.0 Created - Saurabh Kumar - 03/18/2021 - CR-20201222-14763
*/
public class AddProgramRulesManagerQueryBuilder 
{
    
    /* 
    *	Description     :	This method is used to fetch all EAB Event records excluding Current EAB Event record.
    *
    *	@argument    	:	 
    *   
    *   return type     :   	List<Program__c>
    * 
    *	Revision Logs   : 	V_1.0 - Created
    */
    public static List<Program__c> getAllProgramRecords()
    {
        return [SELECT ID, Name, Sector__c, 
                Applicable_Segments__c, Business_Line__c
                FROM Program__c
                Order By Name ASC LIMIT 20];
    }
     
    /* 
    *	Description     :	This method is used to fetch EAB Event records based on Keyword.
    *
    *	@argument	:	String
    *   
    *   return type     :   	List<Program__c>
    * 
    *	Revision Logs   : 	V_1.0 - Created
    */
    public static List<Program__c> getAllProgramRecords(String searchText)
    {
        String modifiedSearchText = '%' + searchText + '%';
        return [SELECT ID, Name, Sector__c, 
                Applicable_Segments__c, Business_Line__c
                FROM Program__c
                WHERE Name LIKE :modifiedSearchText
                OR Sector__c LIKE :modifiedSearchText
                OR Applicable_Segments__c includes(:searchText)
                OR Business_Line__c LIKE :modifiedSearchText 
                Order By Name ASC LIMIT 20];
    }
}