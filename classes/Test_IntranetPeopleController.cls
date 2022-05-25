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
/** Description     :	Test class for IntranetPeopleController
  * 
  * Created Date    :	10/01/2014
  *
  * Created By      :   
  *  
  * Current vision  :	v1.0
  *  
  * Revision Logs   :	v1.0 - Created
  * 				:	V2.0 - Modifled By - Rajeev Jain(06/12/2015) - CR-20141002-7579
  *					:	V3.0 - Modified By  -  Rajeev Jain(09/15/2015) - CR-20141002-7579 - Improved APi Version of the class
  * Coverage        :	89%
  **/ 
//Note : Needs to enable feed tracking in case to run this test class and class version must be above 33
@isTest(SeeAllData = false)
private class Test_IntranetPeopleController {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        
        //Create Intranet Item 
        Intranet_Item__c intranetItem = new Intranet_Item__c(Name = 'Test-0' , Active_Status__c = 'Active' , 
                                                                Item_Type__c = 'App Link' , Item_Title__c = 'A1',
                                                                Office_Name__c = 'ABC Test',Office_Short_Name__c = 'AT',
                                                                Location_Code__c = 'A08');
        insert intranetItem;
        
         //Create New User
        User testUser = new User(Id = UserInfo.getUserId(), Job_Level__c = '10 B1 Early Professional',Office__c = intranetItem.Id);
        
        update testUser;
        
        string before = 'Testing base 64 encode';            
        Blob beforeblob = Blob.valueOf(before);
        
        //Insert Attachment
        Attachment at =  new Attachment(Body = beforeblob, ParentID = intranetItem.Id,
                                             Name = 'Test Documennt', Description = 'Test Document Data',
                                             ContentType = 'application/pdf');
        insert at;
        
        ContentVersion versionDoc = new ContentVersion(Title = 'A08Floor', Description = 'This is the test Content Version Doc');
        /*versionDoc.ContentURL='<a target="_blank" href="http://www.salesforce.com/">'+'http://www.salesforce.com/'+'</a>';*/
        versionDoc.Origin = 'H';
        versionDoc.ContentLocation = 'S'; 
        versionDoc.VersionData = at.Body;
        versionDoc.PathOnClient = 'test.pdf';
        insert versionDoc;
        
        List<ContentVersion> versionDocs = [select Id, ContentDocumentId from ContentVersion where Id = :versionDoc.Id];
        
        List<ContentDocument> contDoc = [select Id, Title from ContentDocument where Id = :versionDocs[0].ContentDocumentId];
        
        //Insert Content Document Link
        ContentDocumentLink contDocLink = new ContentDocumentLink();
        contDocLink.ContentDocumentId = contDoc[0].Id;
        contDocLink.LinkedEntityId = intranetItem.Id;
        contDocLink.ShareType = 'V';
        insert contDocLink;
        
         //Set Parameter User Id
        ApexPages.currentPage().getParameters().put('sfdc.userId',testUser.Id);
        
        Test.startTest();
        
        //Instantiate IntranetPeopleController
        IntranetPeopleController intPeopleCont = new IntranetPeopleController();
        
        Id mapId = intPeopleCont.MapFileId;
        
        Boolean isRenderMap = intPeopleCont.renderMap;
        
        Test.stopTest();
    }
}