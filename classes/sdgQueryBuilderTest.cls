/*
* Copyright (c) 2018, salesforce.com, inc.
* All rights reserved.
* SPDX-License-Identifier: BSD-3-Clause
* For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
*/
@isTest
public class sdgQueryBuilderTest {
    static testMethod void BuildFilterClauseString()
    {
        test.startTest();
        string result = sdgQueryBuilder.BuildFilterClause('abc', 'STRING', '=', '123');
        system.assertEquals(' abc = \'123\' ',result, 'STRING EQUALS');
        
        result = sdgQueryBuilder.BuildFilterClause('abc', 'STRING', 'NOT=', '123');
        system.assertEquals(' abc != \'123\' ',result, ' STRING NOT EQUALS');
        
        result = sdgQueryBuilder.BuildFilterClause('abc', 'STRING', 'CONTAINS', '123');
        system.assertEquals(' abc like \'%123%\' ',result, 'STRING CONTAINS');
        
        result = sdgQueryBuilder.BuildFilterClause('abc', 'STRING', 'NOTCONTAINS', '123');
        system.assertEquals(' (NOT abc like \'%123%\') ',result, 'STRING NOT CONTAINS');
        
        result = sdgQueryBuilder.BuildFilterClause('abc', 'STRING', 'STARTS', '123');
        system.assertEquals(' abc like \'123%\' ', result, 'STRING STARTS');
        
        result = sdgQueryBuilder.BuildFilterClause('abc', 'STRING', 'ENDS', '123');
        system.assertEquals(' abc like \'%123\' ',result, 'STRING ENDS');
        
        
        result  = sdgQueryBuilder.BuildSortClause('ABC' , 'A');
        system.assertEquals(' ORDER BY ABC ASC NULLS FIRST' ,result);
        
        result  = sdgQueryBuilder.BuildSortClause('ABC' , 'D');
        system.assertEquals(' ORDER BY ABC DESC NULLS LAST' ,result);
           
        result = sdgQueryBuilder.BuildFilterClause('abc', 'STRING', '', '123');
        system.assertEquals(' abc = \'123\' ' ,result);
          
        test.stopTest();
    }
    
    static testMethod void BuildFilterClauseMultiPicklist()
    {
        String result = sdgQueryBuilder.BuildFilterClause('abc', 'MULTIPICKLIST', 'INCLUDES', '123');
        
        
        result = sdgQueryBuilder.BuildFilterClause('abc', 'MULTIPICKLIST', '=', '123');
        system.assertEquals(' abc INCLUDES (\'123\') ', result);
        
        
        result = sdgQueryBuilder.BuildFilterClause('abc', 'MULTIPICKLIST', 'NOT=', '123');
        system.assertEquals(' abc EXCLUDES (\'123\') ', result);
        
        
        result = sdgQueryBuilder.BuildFilterClause('abc', 'MULTIPICKLIST', 'NOTCONTAINS', '123');
        system.assertEquals(' abc EXCLUDES (\'123\') ', result);
        
        result = sdgQueryBuilder.BuildFilterClause('abc', 'MULTIPICKLIST', 'STARTS', '123');
        system.assertEquals(' abc INCLUDES (\'123\') ', result);
        
        
        result = sdgQueryBuilder.BuildFilterClause('abc', 'MULTIPICKLIST', 'ENDS', '123');
        system.assertEquals(' abc INCLUDES (\'123\') ', result);
        
        
        result = sdgQueryBuilder.BuildFilterClause('abc', 'MULTIPICKLIST', 'CONTAINS', '123');
        system.assertEquals(' abc INCLUDES (\'123\') ', result);
        
        result = sdgQueryBuilder.BuildFilterClause('abc', 'MULTIPICKLIST', 'INCLUDES', '123NULL');
        system.assertEquals('  ', result);
        
        
        result = sdgQueryBuilder.BuildFilterClause('abc', 'MULTIPICKLIST', '=', '123NULL');
        system.assertEquals(' abc = \'123NULL\' ', result);
        
        
        result = sdgQueryBuilder.BuildFilterClause('abc', 'MULTIPICKLIST', 'NOT=', '123NULL');
        system.assertEquals(' abc != \'123NULL\' ', result);
        
        
        result = sdgQueryBuilder.BuildFilterClause('abc', 'MULTIPICKLIST', 'NOTCONTAINS', '123NULL');
        system.assertEquals(' abc != \'123NULL\' ', result);
        
        
        result = sdgQueryBuilder.BuildFilterClause('abc', 'MULTIPICKLIST', 'STARTS', '123NULL');
        system.assertEquals(' abc = \'123NULL\' ', result);
        
        
        result = sdgQueryBuilder.BuildFilterClause('abc', 'MULTIPICKLIST', 'ENDS', '123NULL');
        system.assertEquals(' abc = \'123NULL\' ', result);
        
        
        result = sdgQueryBuilder.BuildFilterClause('abc', 'MULTIPICKLIST', 'CONTAINS', '123NULL');
        system.assertEquals(' abc = \'123NULL\' ', result);
        
        
    }
    static testMethod void BuildFilterClauseNumber()
    {
        test.startTest();
        string result = sdgQueryBuilder.BuildFilterClause('abc', 'INTEGER', '=', '123');
        system.assertEquals(' abc = 123 ',result, 'NUMBER EQUALS');
        
        result = sdgQueryBuilder.BuildFilterClause('abc', 'INTEGER', 'GT', '123');
        system.assertEquals(' abc > 123 ',result, ' NUMBER GT');
        
        result = sdgQueryBuilder.BuildFilterClause('abc', 'INTEGER', 'LT', '123');
        system.assertEquals(' abc < 123 ',result, 'NUMBER LT');
        
        result = sdgQueryBuilder.BuildFilterClause('abc', 'DOUBLE', '=', '123.5');
        system.assertEquals(' abc = 123.5 ',result, 'DOUBLE EQUALS');
        
        result = sdgQueryBuilder.BuildFilterClause('abc', 'DOUBLE', 'GT', '123.5');
        system.assertEquals(' abc > 123.5 ',result, ' DOUBLE GT');
        
        result = sdgQueryBuilder.BuildFilterClause('abc', 'DOUBLE', 'LT', '123.5');
        system.assertEquals(' abc < 123.5 ',result, 'DOUBLE LT');
        
        test.stopTest();
    }
    
    static testMethod void BuildFilterClausePicklist()
    {
        test.startTest();
        string result = sdgQueryBuilder.BuildFilterClause('abc', 'PICKLIST', '=', 'HAPPY');
        system.assertEquals(' abc = \'HAPPY\' ',result, 'PICKLIST =');
        
        result = sdgQueryBuilder.BuildFilterClause('abc', 'PICKLIST', '=', '');
        system.assertEquals('  ',result, 'PICKLIST blank');
        
        result = sdgQueryBuilder.BuildFilterClause('abc', 'PICKLIST', '=', 'NULL');
        system.assertEquals(' abc = null ', result);
        
        result = sdgQueryBuilder.BuildFilterClause('abc', 'PICKLIST', 'CONTAINS', 'abv');
        system.assertEquals(' abc like \'%abv%\' ', result);
        
        result = sdgQueryBuilder.BuildFilterClause('abc', 'PICKLIST', 'NOTCONTAINS', 'JJ');
        system.assertEquals(' (NOT abc like \'%JJ%\') ', result);
        
        result = sdgQueryBuilder.BuildFilterClause('abc', 'PICKLIST', 'STARTS', 'CODE');
        system.assertEquals(' abc like \'CODE%\' ', result);
        
        result = sdgQueryBuilder.BuildFilterClause('abc', 'PICKLIST', 'ENDS', 'SALESFORCE');
        system.assertEquals(' abc like \'%SALESFORCE\' ', result);
        
        result = sdgQueryBuilder.BuildFilterClause('abc', 'PICKLIST', 'ENDS', 'SALESFORCE,CODE');
        system.assertEquals(' abc like \'%SALESFORCE\'  OR abc like \'%CODE\' ', result);
        
        result = sdgQueryBuilder.BuildFilterClause('abc', 'PICKLIST', '=', 'SALESFORCE,CODE');
        system.assertEquals(' abc IN (\'SALESFORCE\',\'CODE\') ', result);
        
        result = sdgQueryBuilder.BuildFilterClause('abc', 'PICKLIST', 'CONTAINS', 'SALESFORCE,CODE');
        system.assertEquals(' abc like \'%SALESFORCE%\' OR abc like \'%CODE%\' ', result);
        
        result = sdgQueryBuilder.BuildFilterClause('abc', 'PICKLIST', 'NOTCONTAINS', 'SALESFORCE,CODE');
        system.assertEquals(' (NOT abc like \'%SALESFORCE%\')  OR  (NOT abc like \'%CODE%\') ', result);
        
        result = sdgQueryBuilder.BuildFilterClause('abc', 'PICKLIST', 'STARTS', 'SALESFORCE,CODE');
        system.assertEquals(' abc like \'SALESFORCE%\'  OR abc like \'CODE%\' ', result);
        
        test.stopTest();
    }
    
    static testmethod void ProcessMergeFieldsTest()
    {
        test.startTest();
        string result = sdgQueryBuilder.ProcessMergeFields('select name from account', '123');
        system.assertEquals('select name from account',result, 'MergeFields No data');
        
        result = sdgQueryBuilder.ProcessMergeFields('a string #userid# to merge', '123');
        system.assertEquals('a string \'' + userinfo.getUserId() + '\' to merge',result, 'MergeFields userid');
        
        result = sdgQueryBuilder.ProcessMergeFields('select #Id# from account', '123');
        system.assertEquals('select 123 from account',result, 'MergeFields parentid');
        
        test.stopTest();
    }
    
    static testmethod void BuildFilterClauseDate()
    {
        test.startTest();
        string result = sdgQueryBuilder.BuildFilterClause('abc', 'DATE', '=', '18-08-2000');
        
        
        result = sdgQueryBuilder.BuildFilterClause('abc', 'DATE', 'LT', '18-08-2000');
        
        
        result = sdgQueryBuilder.BuildFilterClause('abc', 'DATE', 'GT', '18-08-2022');
        
        
        result = sdgQueryBuilder.BuildFilterClause('abc', 'DATETIME', 'GT', '18-08-2022');
        
        
        result = sdgQueryBuilder.BuildFilterClause('abc', 'DATETIME', 'GT', '18-08-2022');
        
        
        result = sdgQueryBuilder.BuildFilterClause('abc', 'DATETIME', 'GT', '18-08-2022');
        
        
        result = sdgQueryBuilder.BuildFilterClause('abc', 'DATE', 'LAST_QUARTER', '');
        
        
        try {
            result = sdgQueryBuilder.BuildFilterClause('abc', 'DATE', 'GT', 'GGG');
            
        }catch(Exception e){
            system.assert(e.getMessage().contains('Invalid date provided'));
        }
        
        
        
        test.stopTest();
    }
    
    static testmethod void BuildFilterClauseBoolean()
    {
        test.startTest();
        string result = sdgQueryBuilder.BuildFilterClause('abc', 'BOOLEAN', '', 'true');
        system.assertEquals(' abc = true ', result);
        
        result = sdgQueryBuilder.BuildFilterClause('abc', 'BOOLEAN', '', 'false');
        system.assertEquals(' abc = false ', result);
        
        try {
            result = sdgQueryBuilder.BuildFilterClause('abc', 'BOOLEAN', '', 'invalid');
            system.assertEquals(' abc INCLUDES (\'123\') ', result);
            
        }catch(Exception e){
            system.assert(e.getMessage().contains('Invalid date filter value provided'));
        }
        
        test.stopTest();
    }
}