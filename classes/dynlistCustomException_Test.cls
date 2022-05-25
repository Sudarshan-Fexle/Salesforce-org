/*
Purpose         :   Test Class for "dynlistCustomException" apex class
Created By      :   Abhinav Sharma
Created Date    :   08/11/2021
Current Version :   v1.0
Revision Log    :   V_1.0 Created - Abhinav Sharma - 08/11/2021
*/
@isTest(seeAllData=false)
public without sharing class dynlistCustomException_Test 
{
	// this method is basically to test all the use cases associated with "dynlistColumn.compareTo" method
    @isTest(seeAllData=false)
    static void doTesting()
    {
        //Start test from here
        Test.startTest();
        
        dynlistCustomException dExp = new dynlistCustomException();
        System.assert(dExp != null);
        
        //stop test here
        Test.stopTest();
    }    
}