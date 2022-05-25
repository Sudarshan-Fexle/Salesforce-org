/**
 * Purpose          :   Test class for SignInController
 * 
 * CreatedDate      :   10-May-2021
 * 
 * RevisionLog      :   V_1.0 - Created - Ayush Gupta
 *
 * Code Coverage    :   
**/

@isTest
public class SignInControllerTest{
    
    public static testmethod void testSignInController(){
      
      SignInController Ins = new SignInController();
      Ins.signin();
    }  
  
}