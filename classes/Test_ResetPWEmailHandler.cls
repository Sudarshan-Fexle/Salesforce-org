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
@isTest
private class Test_ResetPWEmailHandler {

    static testMethod void myUnitTest() {
        
        // create the user
        User user = TestUtilities.CreateNewUser(false);
        user.IsActive = true;
        insert user;
        
        // create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        // setup the data for the email
        email.subject = 'Reset password';
        email.fromname = 'FirstName LastName';
        env.fromAddress = user.Email;
        
        // call the email service class and test it with the data in the testMethod
        ResetPWEmailHandler emailHandler = new ResetPWEmailHandler();
        emailHandler.handleInboundEmail(email, env);
        system.assertEquals(true, emailHandler.IsSuccess);
    }
    
    /*
     * Created by Subhash - CR-20211012-15511
     */
    
    static testMethod void myUnitTest2() {
        
        // create the user
        User user = TestUtilities.CreateNewUser(true);
        User user2 = TestUtilities.CreateNewUser(true);
        
        // create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        // setup the data for the email
        email.subject = 'Reset password';
        email.fromname = 'FirstName LastName';
        env.fromAddress = user.Email;
        
        // call the email service class and test it with the data in the testMethod
        Test.startTest();
        ResetPWEmailHandler emailHandler = new ResetPWEmailHandler();
        emailHandler.handleInboundEmail(email, env);
        Test.stopTest();
    }
}