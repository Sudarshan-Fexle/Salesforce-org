/*
* Copyright (c) 2018, salesforce.com, inc.
* All rights reserved.
* SPDX-License-Identifier: BSD-3-Clause
* For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
*/
@isTest
//CR-20211012-15511
public with sharing class sdgDatabaseTest {
    //CR-20211012-15511 create setupMethod
	@testSetup
    	static void testSetupData(){
        Util.IsTest(true);     
        Util.IsTesting = true;
        Util.BypassAllTriggers = true;
        
        List<Account> accounts = new List<Account>();
        accounts.add(new Account(Name = 'testacc', Account_Formal_Name__c = 'testacc'));
        accounts.add(new Account(Name = 'testacc1', Account_Formal_Name__c = 'testacc1'));
        insert accounts;
    }
    
    //CR-20211012-15511 create testMethod
    static testMethod void test_CountQuery()
    {
        Test.startTest();
        String query = 'Select count() From Account';
        Integer count = sdgDatabase.CountQuery(query, false);
        System.assertEquals(2, count);
        
        count = sdgDatabase.CountQuery(query, true);
        System.assertEquals(2, count);
        Test.stopTest();
    }
    
    static testMethod void test_query(){
        Test.startTest();
        String query = 'Select Id, Name From Account';
        List<Sobject> acc = sdgDatabase.Query(query, false);
        System.assertEquals(2, acc.size());
        
        acc = sdgDatabase.Query(query, true);
        System.assertEquals(2, acc.size());
        Test.stopTest();
    }
}