/**
 * Purpose          :   Test class for CompassForgetPasswordController
 * 
 * CreatedDate      :   10-May-2021
 * 
 * RevisionLog      :   V_1.0 - Created - Ayush Gupta - CR-20210518-15154
 *
 * Code Coverage    :   
**/

@isTest
public class CompassForgetPasswordControllerTest{
     public static testmethod void testing(){
      CompassForgetPasswordController obj = new CompassForgetPasswordController ();
      //before input user name
      obj.submitRequest();
      
      // after providing username
      obj.UserInput = 'testCase@gmail.com';
      obj.submitRequest();
  }  
}