public with sharing class TaskNewOverrideExt
{
	/*
	Purpose: 	Extention controller for TaskNewOverride VF page used to override the Task 'New' button.  Includes test method.
	
	Create By: 	Nathan Banas (SAP)			
	
	Last Modified By: 	Nathan Banas (SAP) - 4/21/2011
	
	Current Version: 	v1.2
	
	Revision Log:		v1.0 - (NB) Created code
						v1.1 - (NB-2011-01-24) Added header, code comments, and reviewed code coverage
						v1.2 - (NB-2011-04-21) Modified test method to be remove the reliance on data being present within the system
						
	Code Coverage as of 1/24/2011: 97% (1 line not tested and unnecessary)
	Code Coverage as of 4/21/2011: 97% (1 line not tested and unnecessary)
	*/	
	
    private ApexPages.StandardController controller;
    public String retURL {get; set;}
    public String saveNewURL {get; set;}
    public String rType {get; set;}
    public String cancelURL {get; set;}
    public String ent {get; set;}
    public String confirmationToken {get; set;}
    public String whatID {get; set;}
    public String whoID {get; set;}
    
    public TaskNewOverrideExt(ApexPages.StandardController controller)
    {
        this.controller = controller;
        
        retURL = ApexPages.currentPage().getParameters().get('retURL');
        rType = ApexPages.currentPage().getParameters().get('RecordType');
        cancelURL = ApexPages.currentPage().getParameters().get('cancelURL');
        ent = ApexPages.currentPage().getParameters().get('ent');
        confirmationToken = ApexPages.currentPage().getParameters().get('_CONFIRMATIONTOKEN');
        saveNewURL = ApexPages.currentPage().getParameters().get('save_new_url');
        whatID = ApexPages.currentPage().getParameters().get('what_id');
        whoID = ApexPages.currentPage().getParameters().get('who_id');
    }
    
    public PageReference redirect()
    {
        PageReference returnURL;
            
        IF(rType == 'xxxxxxxxxxxxxxx')
        {
            // Redirect if Record Type corresponds to custom VisualForce page
            returnURL = new PageReference('/apex/insert_VF_Page_Here');
        }
        ELSE
        {
            // Redirect to standard page layout if record type does not match
            returnURL = new PageReference('/00T/e');
        }
        
        returnURL.getParameters().put('retURL', retURL);
        returnURL.getParameters().put('RecordType', rType);
        returnURL.getParameters().put('cancelURL', cancelURL);
        returnURL.getParameters().put('ent', ent);
        returnURL.getParameters().put('_CONFIRMATIONTOKEN', confirmationToken);
        returnURL.getParameters().put('save_new_url', saveNewURL);
        returnURL.getParameters().put('nooverride', '1');
        returnURL.getParameters().put('tsk5', 'Will Auto-Populate'); // Set Name = 'Will Auto-Populate'
        returnURL.getParameters().put('what_id', whatID); // Set WhatId
        returnURL.getParameters().put('who_id', whoID); // Set WhatId
        
        returnURL.setRedirect(true);
        
        return returnURL;
    }
    
    public static testmethod void TestCase()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
    	Util.IsTesting = true;
    	
    	test.startTest();
    	
        PageReference pageRef = Page.TaskNewOverride;
        Test.setCurrentPage(pageRef);
        
        //Account testAccount = [select Id, Name from Account where Name != null limit 1];
        Account testAccount = new Account(Name = 'Test');
        insert testAccount;
        
        //Contact testContact = [select Id, Name from Contact where Name != null limit 1];
        Contact testContact = new Contact(FirstName = 'Test', LastName = 'Contact', AccountId = testAccount.Id, Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855');
        insert testContact;
        
        DateTime startDT = System.now();
        Date startD = Date.newInstance(startDT.year(), startDT.month(), startDT.day());
        
        Task testTask = new Task(
        	Subject = '',
        	ActivityDate = startD,
        	Event_Type__c = 'revisit',
        	WhatId = testAccount.Id,
        	WhoId = testContact.Id
        	);      
        	
    	insert testTask;
        
        ApexPages.StandardController stdcontroller = new ApexPages.StandardController(testTask);
        TaskNewOverrideExt controller = new TaskNewOverrideExt(stdcontroller);
      
        String nextPage = stdcontroller.save().getUrl();

        // Verify that page fails without parameters  
    
        System.assertNotEquals(null, nextPage);

        // Add parameters to page URL  
    
    	string whoID = testContact.Id;
    	string whatID = testAccount.Id;
    
        ApexPages.currentPage().getParameters().put('who_id', whoID);
        ApexPages.currentPage().getParameters().put('what_id', whatID);
      
        // Instantiate a new controller with all parameters in the page  
    
        controller = new TaskNewOverrideExt(stdcontroller); 

		controller.whoID = whoID;
    	controller.whatID = whatID;

		nextPage = controller.redirect().getUrl();

        // Verify that the success page displays  
    
        System.assertNotEquals(null, nextPage);
        
        test.stopTest();
    }
}