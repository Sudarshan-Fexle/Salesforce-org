/*
 * Purpose		:	Test class to test the "Batch_Create_Memberships" apex batch class functionality/logic.
 * 
 * Create By		:	Mahendra Swarnakar
 * 
 * Version		:	V1.0 (Created)
 * 
 * Revision Log	:		V1.0 - Created - CR-20160428-9806 - 5/17/2016 
 * 				V1.1 - Updated By Abhinav sharma - CR-20180813-12500
 *				V1.3 - Commented By - Mahendra Swarnkar - 03/04/2020 - CR-20200217-13756
 * 
*/
@istest
Private class Test_Batch_Create_Memberships {
   
    //Test Method 
    static testmethod void testBatchCreateMemberships() {
        
        //Get the System Admin profile
        Profile sysAdminProfile = [SELECT id, Name FROM Profile where name = 'System Administrator' ].get(0); 
        
        //Insert User Record
        User sysAdmin = new User(firstname= 'User1',
                      lastname='ABCtest',
                      Alias='ABCutest',
                      email = 'ABC@test.com',
                      username= 'ABCTestABC123@test.com',
                      profileId= sysAdminProfile.id,
                      emailencodingkey='UTF-8',
                      languagelocalekey='en_US',
                      localesidkey='en_US',
                      timezonesidkey='America/Los_Angeles');

        insert sysAdmin;  
        
        //Run as System Administrator
        System.runAs(sysAdmin){
         
            //Set the Flags
            //Disable all the triggers
            Util.BypassAllTriggers = true;
            
            //List to hold Program records
            List<Program__c> listProgram = new List<Program__c>();
            
            listProgram.add(new Program__c(Name = 'TestA', Program_Acronym__c = 'TA', Applicable_Segments__c = 'US Education', Status__c = 'Active', Create_memberships__c = 'Yes'));
            listProgram.add(new Program__c(Name = 'TestB', Program_Acronym__c = 'TB', Applicable_Segments__c = 'US Hospital', Status__c = 'Active', Create_memberships__c = 'Yes'));
            listProgram.add(new Program__c(Name = 'TestC', Program_Acronym__c = 'TC', Applicable_Segments__c = 'US Education; US Hospital', Status__c = 'Active', Create_memberships__c = 'Yes'));
            listProgram.add(new Program__c(Name = 'TestD', Program_Acronym__c = 'TD', Applicable_Segments__c = 'US Education', Status__c = 'Active', Create_memberships__c = 'No'));
            listProgram.add(new Program__c(Name = 'TestE', Program_Acronym__c = 'TD', Applicable_Segments__c = 'Graduate Education', Status__c = 'Active', Create_memberships__c = 'Yes'));
            
            //Insert the Programs records
            insert listProgram;
            
            //Get the Account's "US Education" and "US Provider - Hospital" records type Ids 
            Id accountUsEducationRecordTypeID = Util.RecordTypeId('Account', 'US Education');
            
            //Commented by Mahendra Swarnkar - 03/04/2020 - CR-20200217-13756
            //Id accountUsHospitalRecordTypeID = Util.RecordTypeId('Account', 'US Provider - Hospital');
            
            //List to hold the Accounts to be inserted
            List<Account> listAccountToBeInsert = new List<Account>(); 
            
            //Populating Accounts list to be inserted
            for (Integer i = 1 ; i < 199 ; i++)
                listAccountToBeInsert.add( new Account(Name = 'Test'+ i, Account_Formal_Name__c = 'Test'+ i, Status__c = 'Active', RecordTypeId = String.valueOf(accountUsEducationRecordTypeID)));
            
            //Crearting one new Graduate Education type of Account
            listAccountToBeInsert.add(new Account(Name = 'Test Grad', Account_Formal_Name__c = 'Test', Status__c = 'Active', RecordTypeId = Constants.Account_Royall_Graduate_RT_ID));
                
            //Disable all the triggers
            Util.BypassAllTriggers = True;
            
            //Insert Account records
            insert listAccountToBeInsert;
            
            //Enable all the triggers
            Util.BypassAllTriggers = False;
            
            listAccountToBeInsert = [Select Id, Name, Account_Formal_Name__c, Status__c, RecordTypeId From Account];
            
            System.assertEquals(199, listAccountToBeInsert.size());
            
            Set<Id> accountIds = new Set<Id>();
            
            for (Account acc : listAccountToBeInsert)
                accountIds.add(acc.Id);
            
            //Test Starts from here
            Test.startTest();
            
            //String to hold the Coma saparated Account Ids
            String idString = '';
            
            //Query string for Batch
			String queryStr;
            
            //Check for Size
            if(listAccountToBeInsert != null && listAccountToBeInsert.size() > 0){
                
                //Loop through Acount Ids 
                for(Account acc : listAccountToBeInsert)
                    idString += '\'' + String.valueof(acc.Id) + '\',';
                
                idString = idString.lastIndexOf(',') > 0 ? '(' + idString.substring(0,idString.lastIndexOf(',')) + ')' : idString ;
                
                //Check for emptyness of string
                if(String.isNotEmpty(idString)) {
                    
                    //Query string for Batch
                    queryStr = 'Select ID, Name, Recordtype.Name FROM Account WHERE ID != null AND ID IN ' + idString;
                    
                    //Batch Instance 
                    Batch_Create_Memberships con = new Batch_Create_Memberships();
                    con.soqlstr = queryStr;
                    
                    //Execute the batch to create the Membership records
                    Database.executeBatch(con, 200);
                }
            }
                       
            //Test Ends here
            Test.stopTest();
            
            //Fetch the Membership records
            List<Membership__c> listMembership = [SELECT Id, Account_Name__c FROM Membership__c where Account_Name__c =: listAccountToBeInsert[0].Id ]; 
            
            //Asserts for the results
            System.assertEquals(2, listMembership.size());
            
            listAccountToBeInsert = [Select Id, Name, Account_Formal_Name__c, Status__c, RecordTypeId From Account limit 5];
            
            //Change the record type of all the Account records to "US Hospital"
            /* Commented since the US Hospital record type is deactivated.
			for (Account ac : listAccountToBeInsert) 
            	ac.RecordTypeId = String.valueOf(accountUsHospitalRecordTypeID);
            
            //Enable all the triggers
            Util.BypassAllTriggers = false;
            
            //Update the Account records
            update listAccountToBeInsert;
            
            //Asserts for the results
            //List<Membership__c> listMembership = [SELECT Id, Account_Name__c FROM Membership__c where Account_Name__c =: listAccountToBeInsert[0].Id ]; 
            //System.assertEquals(3, listMembership.size()); */
        }        
    }
}