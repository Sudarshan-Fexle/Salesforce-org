/*
 *  Purpose         :   Apex Test class for "RoyallProgram" trigger/RoyallProgramTriggerHelper class related functionality
 *
 *  Create By       :   Mahendra Swarnkar 
 *
 *  Created Date    :   01/05/2021
 *
 *  Revision Log    :   V_1.0 Created -  1/5/2021 - CR-20201204-14725 - Update logic behind CX Current Contract Value
 * 
 *  Coverage        :	V1.1 - 94.00 %.
 **/
@isTest(seeAllData = false)
private class Test_Batch_ProgramCostOnMembership {
	
    static testMethod void test_populateProgramCostOnMembership() {
		
        //Bypass all the triggers
        Util.BypassAllTriggers = true;
        
        //Profiles
        Profile p = [Select Id from Profile where Name = 'System Administrator'];
        System.assert(p != null);
        
        //Create a new user
        User u = TestUtilities.CreateNewUser(p, true);
        
        //List to hold the Invoice_Access Permission Record only
        List<CustomPermission> invoiceAccessUserPermission = [SELECT Id FROM CustomPermission 
							      WHERE DeveloperName = 'Invoicing_access' LIMIT 1];
        //Asserts on result
        System.assert(invoiceAccessUserPermission != null);
        System.assert(invoiceAccessUserPermission.size() == 1);
        
        
        //Here we are fetching the records who have Invoice_Access with them
        List<SetupEntityAccess> invoiceCustomPermision = [SELECT Id, ParentId, Parent.Name, SetupEntityId 
        						  FROM SetupEntityAccess 
                                                          WHERE 
                                                          SetupEntityId =: invoiceAccessUserPermission[0].Id 
                                                          AND Parent.isOwnedByProfile =false];
        
        //Checking for null value
        if(invoiceCustomPermision != null && invoiceCustomPermision.size() > 0) {
            
	    //assign the permissionset to user
            PermissionSetAssignment pAssignmnet = new PermissionSetAssignment (AssigneeId = u.Id, 
            		                                                       PermissionSetId = invoiceCustomPermision[0].ParentId);
            insert pAssignmnet;
        
        	system.runAs(u){
         
                //Insert the Account record
                Account acc = new Account ( Name = 'Shift CRM'  );
                insert acc;
                
                //Assert on results
                system.assert(acc != null);
                
                //create a Program 
                Program__c prog = TestUtilities.CreateNewProgram(true);
                
                //Assert on results
                system.assert(prog != null);
                
                Membership__c mem = TestUtilities.CreateNewMembership(acc.Id, prog.Id, true);
        		
        	mem.Membership_Status_Text__c = 'Member - Payer';
                update mem;
                
                //Insert the Program package records
                List<Program_Package__c> progPackage= new List<Program_Package__c> ();
                progPackage.add(new Program_Package__c (Name = 'Test1', Account__c = acc.Id, Fiscal_Year__c = '2016',
                                                        Membership__c = mem.Id));
                progPackage.add(new Program_Package__c (Name = 'Test2', Account__c = acc.Id, Fiscal_Year__c = '2016', 
                                                        Membership__c = mem.Id));
                insert progPackage;
                
                            
                //Insert the Program records for Membership Period 1
                List<Royall_Program__c> rPrograms = new List<Royall_Program__c> ();
                rPrograms.add(new Royall_Program__c ( Name = 'Test Program1', Program_Package__c = progPackage[0].Id, 
                                                     Probability__c = 10, Program_Cost__c = 1000, Proposal_Sent__c = System.today(),
                                                     End_Date_CX__c = System.today().addDays(1), Start_Date_CX__c = System.today().addDays(-1)));
            
                rPrograms.add(new Royall_Program__c ( Name = 'Test Program2', Program_Package__c = progPackage[0].Id, 
                                                     Probability__c = 10, Program_Cost__c = 1000, Proposal_Sent__c = System.today(),
                                                     End_Date_CX__c = System.today().addDays(1), Start_Date_CX__c = System.today().addDays(-1)));
                
                rPrograms.add(new Royall_Program__c ( Name = 'Test Program3', Program_Package__c = progPackage[0].Id, 
                                                     Probability__c = 10, Program_Cost__c = 1000, Proposal_Sent__c = System.today(),
                                                     End_Date_CX__c = System.today().addDays(1), Start_Date_CX__c = System.today().addDays(-1)));
                
                
                //Insert the Program records for Membership Period 2
                rPrograms.add(new Royall_Program__c ( Name = 'Test Program1', Program_Package__c = progPackage[1].Id, 
                                                     Probability__c = 10, Program_Cost__c = 1000, Proposal_Sent__c = System.today(),
                                                     End_Date_CX__c = System.today().addDays(1), Start_Date_CX__c = System.today().addDays(-1)));
            
                rPrograms.add(new Royall_Program__c ( Name = 'Test Program2', Program_Package__c = progPackage[1].Id, 
                                                     Probability__c = 10, Program_Cost__c = 1000, Proposal_Sent__c = System.today(),
                                                     End_Date_CX__c = System.today().addDays(1), Start_Date_CX__c = System.today().addDays(-1)));
                
                rPrograms.add(new Royall_Program__c ( Name = 'Test Program3', Program_Package__c = progPackage[1].Id, 
                                                     Probability__c = 10, Program_Cost__c = 1000, Proposal_Sent__c = System.today(),
                                                     End_Date_CX__c = System.today().addDays(1), Start_Date_CX__c = System.today().addDays(-1)));
                
                //Insert Royall Programs
                insert rPrograms;
                
                //Starts Test from here
                Test.startTest();
                
                //run batch
                Database.executeBatch(new Batch_PopulateProgramCostOnMembership(),20);
                                
                //Test stops here
                Test.stopTest(); 
            }    		        
        }
    }
    
}