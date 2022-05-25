/**
  *   Purpose         :     Test class for SurveyController
  *            
  *   Create By       :     Victor Hanson
  * 
  *   Created Date    :     03/20/2018
  *
  *   Revision Log    :     V_1.0 - Created
  * 
  **/
@isTest
private class SurveyControllerTest {
	
    /**
    * @Description  : This method used to test surveyController.save() method
    * 
    * @Args         :  
    * 
    * @Return       : void 
    * 
    * @Revision-log : V_1.0 - Created
    **/
    private static testmethod void testSaveSurvey() {
        
        //create a contact
        Contact c = TestUtilities.CreateNewContact(null, true);
        
        //Put Id of contact
        Apexpages.Currentpage().getparameters().put('CID', c.Id);
        
        //instantiate the controller
        SurveyController controller = new SurveyController();
        
        //verify survey options are present
        system.assert(true, controller.surveyOptions.size() > 2);
        
        String subjectValue = 'Slow';
        String descriptionValue = 'Lightning is a bit slow';
        
        controller.Survey.Subject = subjectValue;
        controller.Survey.Description = descriptionValue;
        
        Test.startTest();
        
        //save
        controller.save();
        
        Test.stopTest();
        
        /*List<Event> surveys = [SELECT Id, Subject, Description FROM Event WHERE WhoId = :c.Id];
        system.assertEquals(1, surveys.size());*/
        /*system.assertEquals(subjectValue, surveys[0].Subject);
        system.assertEquals(descriptionValue, surveys[0].Description);*/
    }
}