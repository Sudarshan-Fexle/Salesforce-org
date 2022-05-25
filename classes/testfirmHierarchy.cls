/**
 *  Description     :   Test class for FirmHierarchy controller
 *  
 *  Created By      :   Rajeev Jain
 *
 *  Created Date    :   06/16/2016
 *
 *  Deprecated      :   
 *
 *  Revision Logs   :  v1.0 - Created
 * 					:  V1.0 - Modified - Rajeev Jain - 06/16/2016 - SFDC schema Release - Manual Code Migration from Royall Enviournment, Rename this class with Preceeding text Royall
 *  
 **/
@isTest
private class testfirmHierarchy{

    static testMethod void testfirmHierarchy() {
        
        //Bypassing triggers and dupeblocker
        Util.IsTest(true);
        Util.byPassAllTriggers = true;
        
        //Get profile list
        List<Profile> testProfile = [Select Id, Name from Profile where Name = 'System Administrator'];
        
        //Assert for results
        System.assert(testProfile != null);
        System.assert(testProfile.size() > 0);
        
        //Test User Create
        List<User> userList = new List<User>();
        
        //Insert users
        userList.add(new User(Username= Math.random()+'@abc.com', LastName='Test User1', 
                              FirstName='Test1', Email='testuser1@test.com',
                              Alias='Test1', EmailEncodingKey='UTF-8', languagelocalekey='en_US', 
                              ProfileId=testProfile[0].Id, timezonesidkey='America/Los_Angeles', localesidkey='en_US', 
                              EmployeeNumber = '12121212', IsActive = true));
        insert userList;
        
        //Run as system administrator
        System.runAs(userList[0]){
        	
            Relationships__c topRelationship = new Relationships__c(Name='HierarchyTest0');
            insert topRelationship;
            
            Relationships__c middleRelationship = new Relationships__c(Name='middleRelationship', ParentFirm__c = topRelationship.Id);
            insert middleRelationship;
            
            Relationships__c bottomRelationship = new Relationships__c(Name='middleRelationship', ParentFirm__c = topRelationship.Id);
            insert bottomRelationship;

 
            //Start test from here
            test.startTest();
            
            PageReference firmHierarchyPage = Page.firmHierarchyPage;
            Test.setCurrentPage( firmHierarchyPage );
            ApexPages.currentPage().getParameters().put( 'id', topRelationship.id );
        
            // Instanciate Controller
            firmStructure controller = new firmStructure();
            
            // Call Methodes for top firm
            controller.setcurrentId( null );
            firmStructure.ObjectStructureMap[] smt1 = new firmStructure.ObjectStructureMap[]{};
            smt1 = controller.getObjectStructure();
            System.Assert( smt1.size() > 0, 'Test failed at Top firm, no Id' );
    
            controller.setcurrentId( String.valueOf( topRelationship.id ) );
            firmStructure.ObjectStructureMap[] smt2 = new firmStructure.ObjectStructureMap[]{};
            smt2 = controller.getObjectStructure();
            System.Assert( smt2.size() > 0, 'Test failed at Top firm, with Id: '+smt2.size() );
    
            //Call ObjectStructureMap methodes
            smt2[0].setnodeId( '1234567890' );
            smt2[0].setlevelFlag( true );
            smt2[0].setlcloseFlag( false );
            smt2[0].setnodeType( 'parent' );
            smt2[0].setcurrentNode( false );
            smt2[0].setfirm( topRelationship );
            
            String nodeId       = smt2[0].getnodeId();
            Boolean[] levelFlag = smt2[0].getlevelFlag();
            Boolean[] closeFlag = smt2[0].getcloseFlag();
            String nodeType     = smt2[0].getnodeType();
            Boolean currentName = smt2[0].getcurrentNode();
            Relationships__c smbRelationship  = smt2[0].getFirm();
    
            // Call Methodes for middle firm
            controller.setcurrentId( String.valueOf( middleRelationship.id ) );
            firmStructure.ObjectStructureMap[] smm = new firmStructure.ObjectStructureMap[]{};
            smm = controller.getObjectStructure();
            System.Assert( smm.size() > 0, 'Test failed at middle firm' );
    
            // Call Methodes for bottom firm
            controller.setcurrentId( String.valueOf( bottomRelationship.id ) );
            firmStructure.ObjectStructureMap[] smb = new firmStructure.ObjectStructureMap[]{};
            smb = controller.getObjectStructure();
            System.Assert( smb.size() > 0, 'Test failed at top firm' );
            
            //Stop Test here
            test.stopTest();
        }        
    }
}