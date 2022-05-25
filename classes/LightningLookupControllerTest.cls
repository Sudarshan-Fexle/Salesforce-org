/*
Copyright 2017 OpFocus, Inc
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation 
files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, 
modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the 
Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES 
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE 
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR 
IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.		
*/
@isTest(seeAllData=false)
public class LightningLookupControllerTest 
{
     	//V_1.1 - Modified by - Abhinav Sharma - Compile all classes Fix
	static testMethod void myTest1() 
    {
        Test.startTest();
        
        Util.byPassAllTriggers = true;
		Account acct = new Account(Name = 'Test Account');
		insert acct;
        Util.byPassAllTriggers = false;
		
        LightningLookupController.LookupRecords res = LightningLookupController.getRecords('Account', '', 'Name', '', 'Name like \'test%\'', acct.Id);
		System.assertEquals(null,res);
		res = LightningLookupController.getRecords('Account', 'Id', '', '', 'Name like \'test%\'', acct.Id);
		System.assertEquals(null,res);
		
        res = LightningLookupController.getRecords('Account', 'Id', '', 'CreatedDate', 'Name like \'test%\'', acct.Id);
		System.assertEquals(null,res);
		
        res = LightningLookupController.getRecords('Account', '', '', 'CreatedDate', 'Name like \'test%\'', acct.Id);
		System.assertEquals(null,res);
		
        res = LightningLookupController.getRecords('Account', 'Id', 'Name', 'CreatedDate', 'Name like \'test%\'', acct.Id);
		System.assertEquals(1,res.lstDisplay.size());
		System.assertEquals(1,res.lstValue.size());
		System.assertEquals(1,res.lstRecords.size());
		
        res = LightningLookupController.getRecords('Account', 'Id', 'Name', 'CreatedDate', 'Name like \'hufdehf%\'', acct.Id);
		System.assertEquals(1,res.lstDisplay.size());
		System.assertEquals(1,res.lstValue.size());
		System.assertEquals(1,res.lstRecords.size());
		System.assertEquals('No records found!',res.lstDisplay[0]);
        
        //Update by Subhash Garhwal - 13-10-2021 - CR-20211012-15511
        //Create the Project
        Project__c proj = TestUtilities.createProject(false);
        proj.Institution__c = acct.Id;
        util.BypassAllTriggers = true;
        insert proj;
        
        List<Job_Ticket__c> jobTickets = new List<Job_Ticket__c>();
        jobTickets.add(new Job_Ticket__c(Project__c = proj.Id,Drop_Type__c = 'Pre Planned', Status__c = 'Draft', Descriptive_Name__c = 'Test', Mail_Quantity__c = 100,
                                         Change_Reason__c = 'Testing before update', Project_ID__c = 'Test', Fiscal_Year__c='2020'));
        insert jobTickets;
        
        res = LightningLookupController.getRecords('Project__c', 'Id', 'Name', 'CreatedDate', 'Name like \'Test%\'', jobTickets[0].Id);
        Test.stopTest();
        
        String s = LightningLookupController.getHelpText('Account.Name');
		s = LightningLookupController.getReference('Account.OwnerId');
		System.assertEquals('User',s);
		
        res = LightningLookupController.getFieldValue('Account', acct.Id, 'Name');
		System.assertEquals(acct.Id,res.lstValue[0]);
        System.assertEquals(1, res.lstRecords.size());
	}
}