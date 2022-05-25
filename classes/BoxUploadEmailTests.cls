/**
 * 	Description 	:	Test class for BoxUploadEmail
 * 
 * 	Revision Logs	:	V1.0 - 18/10/2021 - CR-20211012-15511 - Subhash Garhwal - Updated
 **/
@IsTest
public class BoxUploadEmailTests {
    public static testMethod void testParseAccess() {
        System.assertEquals(
            BoxUploadEmail.Access.OPEN,
            BoxUploadEmail.parseAccess('open')
        );
        System.assertEquals(
            BoxUploadEmail.Access.COLLABORATORS,
            BoxUploadEmail.parseAccess('collaborators')
        );
    }

    public static testMethod void testGetAccessAsString() {
        System.assertEquals(
            'open',
            BoxUploadEmail.getAccessAsString(BoxUploadEmail.Access.OPEN)
        );
        System.assertEquals(
            'collaborators',
            BoxUploadEmail.getAccessAsString(
                BoxUploadEmail.Access.COLLABORATORS
            )
        );
    }

    public static testMethod void testParseMember() {
        BoxApiConnection api = new BoxApiConnection('accesstoken');
        BoxUploadEmail uploadEmail = new BoxUploadEmail(api, '10543463');
        BoxUploadEmail.Info uploadEmailInfo = new BoxUploadEmail.Info();

        Test.startTest();
        uploadEmailInfo.parseMember('access', 'open');
        uploadEmailInfo.parseMember('email', 'test@box.com');
        Test.stopTest();

        System.assertEquals(BoxUploadEmail.Access.OPEN, uploadEmailInfo.access);
        System.assertEquals('test@box.com', uploadEmailInfo.email);
    }
    
    /*
     * To cover the getObjectType method - CR-20211012-15511
    */
    public static testMethod void BoxUploadEmailTest(){
        BoxApiConnection api = new BoxApiConnection('accesstoken');
        BoxUploadEmail uploadEmail = new BoxUploadEmail(api, '10543463');
        String getObjectString = uploadEmail.getObjectType();
    }
    /*
     * To cover the getObjectType method - CR-20211012-15511
    */
    public static testMethod void BoxUploadEmailTest2(){
        BoxApiConnection api = new BoxApiConnection('accesstoken');
        BoxUploadEmail uploadEmail = new BoxUploadEmail(api, '10543463');
        String getObjectString = uploadEmail.getObjectType();
        
        BoxUploadEmail.Info uplaodEmailInfo = new BoxUploadEmail.Info();
    }
}