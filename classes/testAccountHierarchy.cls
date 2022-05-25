/**
 *  Description     :   Test class for AccountHierarchy controller
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
private class testAccountHierarchy{

    static testMethod void testAccountHierarchy() {
        
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
        
        	AccountHierarchyTestData.createTestHierarchy();

            Account topAccount      = [ Select id, name from account where name = 'HierarchyTest0' limit 1 ];
            Account middleAccount   = [ Select id, parentID, name from account where name = 'HierarchyTest4' limit 1 ];
            Account bottomAccount   = [ Select id, parentID, name from account where name = 'HierarchyTest9' limit 1 ];
            Account[] accountList   = [ Select id, parentID, name from account where name like 'HierarchyTest%' ];
    		
            //Start test from here
            test.startTest();
            
            PageReference AccountHierarchyPage = Page.AccountHierarchyPage;
            Test.setCurrentPage( AccountHierarchyPage );
            ApexPages.currentPage().getParameters().put( 'id', topAccount.id );
        
            // Instanciate Controller
            AccountStructure controller = new AccountStructure();
            
            // Call Methodes for top account
            controller.setcurrentId( null );
            AccountStructure.ObjectStructureMap[] smt1 = new AccountStructure.ObjectStructureMap[]{};
            smt1 = controller.getObjectStructure();
            System.Assert( smt1.size() > 0, 'Test failed at Top account, no Id' );
    
            controller.setcurrentId( String.valueOf( topAccount.id ) );
            AccountStructure.ObjectStructureMap[] smt2 = new AccountStructure.ObjectStructureMap[]{};
            smt2 = controller.getObjectStructure();
            System.Assert( smt2.size() > 0, 'Test failed at Top account, with Id: '+smt2.size() );
    
            //Call ObjectStructureMap methodes
            smt2[0].setnodeId( '1234567890' );
            smt2[0].setlevelFlag( true );
            smt2[0].setlcloseFlag( false );
            smt2[0].setnodeType( 'parent' );
            smt2[0].setcurrentNode( false );
            smt2[0].setaccount( topAccount );
            
            String nodeId       = smt2[0].getnodeId();
            Boolean[] levelFlag = smt2[0].getlevelFlag();
            Boolean[] closeFlag = smt2[0].getcloseFlag();
            String nodeType     = smt2[0].getnodeType();
            Boolean currentName = smt2[0].getcurrentNode();
            Account smbAccount  = smt2[0].getaccount();
    
            // Call Methodes for middle account
            controller.setcurrentId( String.valueOf( middleAccount.id ) );
            AccountStructure.ObjectStructureMap[] smm = new AccountStructure.ObjectStructureMap[]{};
            smm = controller.getObjectStructure();
            System.Assert( smm.size() > 0, 'Test failed at middle account' );
    
            // Call Methodes for bottom account
            controller.setcurrentId( String.valueOf( bottomAccount.id ) );
            AccountStructure.ObjectStructureMap[] smb = new AccountStructure.ObjectStructureMap[]{};
            smb = controller.getObjectStructure();
            System.Assert( smb.size() > 0, 'Test failed at top account' );
            
            //Stop Test here
            test.stopTest();
        }        
    }
}