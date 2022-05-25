@isTest(SeeAllData=true)
public class PostChatterOnCaseTest {
    
    static testMethod void myunitTest() {
    	
        //New List of Case
        List<Case> cases = new List<Case>();
        cases.add(New case(Subject = 'Test', Status = 'Submitted',  Origin = 'Other', OwnerId = userinfo.getUserid()));
        insert cases;
        
       	 List<String> caseIdAndDetails = new List<String>();
         caseIdAndDetails.add(cases[0].Id + '<--Message-->' + 'Text' + '<--Action-->1');
        
        	//Calling Method to get the response
       		PostChatterOnCase.postingChatterOnCase(caseIdAndDetails);
        
        
    }
}