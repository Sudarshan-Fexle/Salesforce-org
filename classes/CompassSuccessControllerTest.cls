@isTest
public class CompassSuccessControllerTest{
    public static testmethod void testingCompassSuccessController (){
      ApexPages.currentPage().getParameters().put('UserCreated', 'Yes'); 
      CompassSuccessController obj = new CompassSuccessController ();
      
      ApexPages.currentPage().getParameters().put('UserCreated', 'No');
      CompassSuccessController obj1 = new CompassSuccessController ();
      obj1.RedirectUser();
  }  

}