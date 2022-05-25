/*
Purpose         :   SOQL Builder Test class (Dynamic Related List)
Created By      :   Abhinav Sharma
Created Date    :   07/24/2021
Current Version :   v1.0
Revision Log    :   V_1.0 Created - Abhinav Sharma - 07/24/2021
*/
@isTest(seeAllData=false)
public with sharing class dynlistSOQLBuilder_Test 
{
    @IsTest
    static void testLinebreaks() 
    {
        dynlistSOQLBuilder builder = dynlistSOQLBuilder.create().addSelect('Name').addFrom('object_01__c').addWhere(dynlistSOQLBuilder.eq('Name', 'test'));
        String sql = null;
        
        sql = builder.toQuery();
        System.assert(sql.toLowerCase().contains('\n'), 'Expected linebreaks, was: ' + sql);
        
        sql = builder.setLinebreaks(false).toQuery();
        System.assert(!sql.toLowerCase().contains('\n'), 'Expected NO linebreaks, was: ' + sql);
    }
    
    @IsTest
    static void testSelect() 
    {
        dynlistSOQLBuilder builder = dynlistSOQLBuilder.create();
        String sql = null;
        
        sql = builder.addSelect('Id').toQuery();
        System.assert(sql.toLowerCase().startsWith('select id'));
        
        sql = builder.addSelect(new String[] { 'Name', 'Owner' }).toQuery();
        System.assert(sql.toLowerCase().startsWith('select id, name, owner'));
    }
    
    @IsTest
    static void testSelectWithoutFields() 
    {
        dynlistSOQLBuilder builder = dynlistSOQLBuilder.create();
        String sql = null;
        
        sql = builder.toQuery();
        System.assert(sql.toLowerCase().startsWith('select id'));
    }
    
    @IsTest
    static void testClearSelect() 
    {
        dynlistSOQLBuilder builder = dynlistSOQLBuilder.create().addSelect('Id').clearSelects().addSelect('Name');
        String sql = null;
        
        sql = builder.toQuery();
        System.assert(sql.toLowerCase().startsWith('select name'));
    }
    
    @IsTest
    static void testCount() 
    {
        dynlistSOQLBuilder builder = dynlistSOQLBuilder.create().setLinebreaks(false);
        String sql = null;
        
        sql = builder.toCountQuery();
        System.assert(sql.toLowerCase().startsWith('select count()'));
        
        sql = builder.toCountQuery(1000);
        System.assert(sql.toLowerCase().endsWith('limit 1000'));
    }
    
    @IsTest
    static void testFrom() 
    {
        dynlistSOQLBuilder builder = dynlistSOQLBuilder.create();
        String sql = null;
        
        sql = builder.addFrom('object_01__c').toQuery();
        System.assert(sql.toLowerCase().contains('from object_01__c'));
        
        sql = builder.addFrom(new String[] { 'object_02__c', 'object_03__c' }).toQuery();
        System.assert(sql.toLowerCase().contains('from object_01__c, object_02__c, object_03__c'));
    }
    
    @IsTest
    static void testSort() 
    {
        dynlistSOQLBuilder builder = dynlistSOQLBuilder.create().setLinebreaks(false);
        String sql = null;
        
        sql = builder.addSortAsc('id').toQuery();
        System.assert(sql.toLowerCase().endsWith('order by id asc nulls last'), 'Expected query to end with `order by id asc nulls last`, was: ' + sql);
        
        sql = builder.addSortDesc('name').toQuery();
        System.assert(sql.toLowerCase().endsWith('order by id asc nulls last, name desc nulls first'), 'Expected query to end with `order by id asc nulls last, name desc nulls first`, was: ' + sql);
    }
    
    @IsTest
    static void testSortDefaultNulls() 
    {
        dynlistSOQLBuilder builder = dynlistSOQLBuilder.create().setLinebreaks(false);
        String sql = null;
        
        sql = builder.addSortAscNullsFirst('id').toQuery();
        System.assert(sql.toLowerCase().endsWith('order by id asc nulls first'), 'Expected query to end with `order by id asc nulls first`, was: ' + sql);
        
        sql = builder.addSortDescNullsLast('name').toQuery();
        System.assert(sql.toLowerCase().endsWith('order by id asc nulls first, name desc nulls last'), 'Expected query to end with `order by id asc nulls first, name desc nulls last`, was: ' + sql);
    }
    
    @IsTest
    static void testClearSort() 
    {
        dynlistSOQLBuilder builder = dynlistSOQLBuilder.create().setLinebreaks(false);
        String sql = null;
        
        sql = builder.addSortAsc('id').clearSorts().toQuery();
        System.assert(!sql.toLowerCase().endsWith('order by id asc nulls last'), 'Expected query NOT to end with `order by id asc nulls last`, was: ' + sql);
    }
    
    @IsTest
    static void testGroup() 
    {
        dynlistSOQLBuilder builder = dynlistSOQLBuilder.create().setLinebreaks(false);
        String sql = null;
        
        sql = builder.addGroup('Id').toQuery();
        System.assert(sql.toLowerCase().endsWith('group by id'));
        
        sql = builder.addGroup(new String[] {'Name', 'Id', 'Amount'}).toQuery();
        System.assert(sql.toLowerCase().endsWith('group by id, name, amount'));
    }
    
    @IsTest
    static void testCriteria() 
    {
        dynlistSOQLBuilder builder = null;
        String sql = null;
        
        // eq
        builder = dynlistSOQLBuilder.create().setLinebreaks(false);
        sql = builder.addWhere(dynlistSOQLBuilder.eq('Id', '123456789')).toQuery();
        System.assert(sql.toLowerCase().endsWith('where id = \'123456789\''), 'Expected `where id = \'123456789\'`, was: ' + sql);
        
        // ne
        builder = dynlistSOQLBuilder.create().setLinebreaks(false);
        sql = builder.addWhere(dynlistSOQLBuilder.ne('Id', '123456789')).toQuery();
        System.assert(sql.toLowerCase().endsWith('where id != \'123456789\''), 'Expected `where id != \'123456789\'`, was: ' + sql);
        
        // gt
        builder = dynlistSOQLBuilder.create().setLinebreaks(false);
        sql = builder.addWhere(dynlistSOQLBuilder.gt('Amount', 10)).toQuery();
        System.assert(sql.toLowerCase().endsWith('where amount > 10'), 'Expected `where amount > 10`, was: ' + sql);
        
        // ge
        builder = dynlistSOQLBuilder.create().setLinebreaks(false);
        sql = builder.addWhere(dynlistSOQLBuilder.ge('Amount', 10)).toQuery();
        System.assert(sql.toLowerCase().endsWith('where amount >= 10'), 'Expected `where amount >= 10`, was: ' + sql);
        
        // lt
        builder = dynlistSOQLBuilder.create().setLinebreaks(false);
        sql = builder.addWhere(dynlistSOQLBuilder.lt('Amount', 10)).toQuery();
        System.assert(sql.toLowerCase().endsWith('where amount < 10'), 'Expected `where amount < 10`, was: ' + sql);
        
        // lt
        builder = dynlistSOQLBuilder.create().setLinebreaks(false);
        sql = builder.addWhere(dynlistSOQLBuilder.le('Amount', 10)).toQuery();
        System.assert(sql.toLowerCase().endsWith('where amount <= 10'), 'Expected `where amount <= 10`, was: ' + sql);
        
        // isNull
        builder = dynlistSOQLBuilder.create().setLinebreaks(false);
        sql = builder.addWhere(dynlistSOQLBuilder.isNull('Amount')).toQuery();
        System.assert(sql.toLowerCase().endsWith('where amount = null'), 'Expected `where amount = null`, was: ' + sql);
        
        // notNull
        builder = dynlistSOQLBuilder.create().setLinebreaks(false);
        sql = builder.addWhere(dynlistSOQLBuilder.notNull('Amount')).toQuery();
        System.assert(sql.toLowerCase().endsWith('where amount != null'), 'Expected `where amount != null`, was: ' + sql);
        
        // bind variable
        builder = dynlistSOQLBuilder.create().setLinebreaks(false);
        sql = builder.addWhere(dynlistSOQLBuilder.eq('Owner.id', ':userid')).toQuery();
        System.assert(sql.toLowerCase().endsWith('where owner.id = :userid'), 'Expected `where owner.id = :userid`, was: ' + sql);
        
        // in
        builder = dynlistSOQLBuilder.create().setLinebreaks(false);
        sql = builder.addWhere(dynlistSOQLBuilder.valueIn('name', ':names')).toQuery();
        System.assert(sql.toLowerCase().endsWith('where name in :names'), 'Expected `where name in :names`, was: ' + sql);
        
        // in with mixed List of values
        List<Object> objectValues = new List<Object> { null, 'test', 1234 };
            builder = dynlistSOQLBuilder.create().setLinebreaks(false);
        sql = builder.addWhere(dynlistSOQLBuilder.valueIn('name', objectValues)).toQuery();
        System.assert(sql.toLowerCase().endsWith('where name in (null,\'test\',1234)'), 'Expected `where name in (null,\'test\',1234)`, was: ' + sql);
        
        // in with List of string values
        List<String> stringValues = new List<String> { null, 'test', 'test2'};
            builder = dynlistSOQLBuilder.create().setLinebreaks(false);
        sql = builder.addWhere(dynlistSOQLBuilder.valueIn('name', stringValues)).toQuery();
        System.assert(sql.toLowerCase().endsWith('where name in (null,\'test\',\'test2\')'), 'Expected `where name in (null,\'test\',\'test2\')`, was: ' + sql);
        
        // in with List of integer values
        List<Integer> integerValues = new List<Integer> { null, 1, 2, 3};
            builder = dynlistSOQLBuilder.create().setLinebreaks(false);
        sql = builder.addWhere(dynlistSOQLBuilder.valueIn('name', integerValues)).toQuery();
        System.assert(sql.toLowerCase().endsWith('where name in (null,1,2,3)'), 'Expected `where name in (null,1,2,3)`, was: ' + sql);
        
        // in with mixed Set of values
        Set<Object> objectValuesSet = new Set<Object> { null, 'test', 1234 };
            builder = dynlistSOQLBuilder.create().setLinebreaks(false);
        sql = builder.addWhere(dynlistSOQLBuilder.valueIn('name', objectValuesSet)).toQuery();
        System.assert(sql.toLowerCase().endsWith('where name in (null,\'test\',1234)'), 'Expected `where name in (null,\'test\',1234)`, was: ' + sql);
        
        // not in
        builder = dynlistSOQLBuilder.create().setLinebreaks(false);
        sql = builder.addWhere(dynlistSOQLBuilder.valueNotIn('name', ':names')).toQuery();
        System.assert(sql.toLowerCase().endsWith('where name not in :names'), 'Expected `where name not in :names`, was: ' + sql);
        
        // value like
        builder = dynlistSOQLBuilder.create().setLinebreaks(false);
        sql = builder.addWhere(dynlistSOQLBuilder.valueLike('name', '%test%')).toQuery();
        System.assert(sql.toLowerCase().endsWith('where name like \'%test%\''), 'Expected `where name like \'%test%\'`, was: ' + sql);
        
        //distance
        builder = dynlistSOQLBuilder.create().setLinebreaks(false);
        sql = builder.addWhere(dynlistSOQLBuilder.distance('geolocation__c', 50.001, 4.001, 50)).toQuery();
        System.assert(sql.toLowerCase().endsWith('where (distance(geolocation__c, geolocation(50.001,4.001), \'km\') < 50)'), 'Expected `where (distance(geolocation__c, geolocation(50.001,4.001), \'km\') < 50)`, was: ' + sql);
        
        //Use Case - (value instanceof List<GeolocationValue>)
        String column = 'test';
        List<dynlistSOQLBuilder.GeolocationValue> value = new List<dynlistSOQLBuilder.GeolocationValue>{new dynlistSOQLBuilder.GeolocationValue(110,20,55)};
            
            builder = dynlistSOQLBuilder.create().setLinebreaks(false);
        sql = builder.addWhere(dynlistSOQLBuilder.valueIn(column, value)).toQuery();
        System.assert(sql != null);
        
        //Use Case - (value instanceof GeolocationValue)
        column = 'test';
        dynlistSOQLBuilder.GeolocationValue value1 = new dynlistSOQLBuilder.GeolocationValue(110,20,55);
        
        builder = dynlistSOQLBuilder.create().setLinebreaks(false);
        sql = builder.addWhere(dynlistSOQLBuilder.valueIn(column, value1)).toQuery();
        System.assert(sql != null);
        
    }
    
    @IsTest
    static void testLimit() 
    {
        dynlistSOQLBuilder builder = dynlistSOQLBuilder.create().setLinebreaks(false);
        String sql = null;
        
        sql = builder.setLimit(100).toQuery();
        System.assert(sql.toLowerCase().endsWith('limit 100'));
    }
    
    @IsTest
    static void testOffset() 
    {
        dynlistSOQLBuilder builder = dynlistSOQLBuilder.create().setLinebreaks(false);
        String sql = null;
        
        sql = builder.setOffset(50).toQuery();
        System.assert(sql.toLowerCase().endsWith('offset 50'));
    }
    
    @IsTest
    static void testConjunction() 
    {
        dynlistSOQLBuilder builder = dynlistSOQLBuilder.create();
        String sql = null;
        
        sql = builder.addWhere(dynlistSOQLBuilder.conjunction()
                               .add(dynlistSOQLBuilder.gt('amount', 10))
                               .add(dynlistSOQLBuilder.lt('amount', 100))
                              ).toQuery();
        
        System.assert(sql.toLowerCase().contains('(amount > 10 and amount < 100)'));
    }
    
    @IsTest
    static void testDisjunction() 
    {
        dynlistSOQLBuilder builder = dynlistSOQLBuilder.create();
        String sql = null;
        
        sql = builder.addWhere(dynlistSOQLBuilder.disjunction()
                               .add(dynlistSOQLBuilder.eq('owner.id', ':userid'))
                               .add(dynlistSOQLBuilder.isNull('owner.id'))
                              ).toQuery();
        
        System.assert(sql.toLowerCase().contains('(owner.id = :userid or owner.id = null)'));
    }
    
    @IsTest
    static void testEmptyDisjunction() 
    {
        dynlistSOQLBuilder builder = dynlistSOQLBuilder.create().setLinebreaks(false).addFrom('cxsPosition__c');
        String sql = null;
        
        sql = builder.addWhere(dynlistSOQLBuilder.disjunction()).toQuery();
        System.assert(sql != null);
        
    }
    
    @IsTest
    static void testNestedEmptyJunctions() 
    {
        dynlistSOQLBuilder builder = dynlistSOQLBuilder.create().setLinebreaks(false).addFrom('Account');
        String sql = null;
        
        builder.addWhere(
            dynlistSOQLBuilder.disjunction()
            .add(dynlistSOQLBuilder.conjunction().add(dynlistSOQLBuilder.disjunction()))
        );
        
        sql = builder.toQuery();
        System.assert(sql.toLowerCase() == 'select id from Account');
    }
    
    @IsTest
    static void testNestedEmptyJunctionsWithAValue() 
    {
        dynlistSOQLBuilder builder = dynlistSOQLBuilder.create().setLinebreaks(false).addFrom('Account');
        String sql = null;
        
        builder.addWhere(
            dynlistSOQLBuilder.disjunction()
            .add(
                dynlistSOQLBuilder.conjunction()
                .add(dynlistSOQLBuilder.disjunction())
                .add(dynlistSOQLBuilder.eq('Name', 'test'))
            )
        );
        
        sql = builder.toQuery();
        
        System.assert(sql.toLowerCase() == 'select id from Account where ((name = \'test\'))');
    }
    
    
    @IsTest
    static void testConditionLogic() 
    {
        dynlistSOQLBuilder builder = null;
        String sql = null;
        
        // eq
        builder = dynlistSOQLBuilder.create()
            .addWhere(dynlistSOQLBuilder.eq('Id', '123456789'))
            .addWhere(dynlistSOQLBuilder.eq('Name', 'Test'))
            .addWhere(dynlistSOQLBuilder.eq('Amount', 10))
            .setConditionLogic('({A} AND {B}) OR {C}')
            ;
        sql = builder.toQuery();
        
        System.assert(sql.toLowerCase().contains('(id = \'123456789\' and name = \'test\') or amount = 10'));
    }
    
    @IsTest
    static void testConditionLogicMissingConditions() 
    {
        dynlistSOQLBuilder builder = null;
        String sql = null;
        
        // eq
        builder = dynlistSOQLBuilder.create()
            .addWhere(dynlistSOQLBuilder.eq('Id', '123456789'))
            .addWhere(dynlistSOQLBuilder.eq('Name', 'Test'))
            .addWhere(dynlistSOQLBuilder.eq('Amount', 10))
            .addWhere(dynlistSOQLBuilder.valueIn('Name', ':names'))
            .addWhere(dynlistSOQLBuilder.eq('Owner.id', ':userid'))
            .setConditionLogic('({A} AND {B}) OR {C}')
            ;
        sql = builder.toQuery();
        
        System.assert(sql.toLowerCase().contains('((id = \'123456789\' and name = \'test\') or amount = 10) and (name in :names and owner.id = :userid)'));
    }
    
    @IsTest
    static void testToConditionLogicString() 
    {
        dynlistSOQLBuilder builder = null;
        String sql = null;
        
        builder = dynlistSOQLBuilder.create()
            .addWhere(dynlistSOQLBuilder.eq('Id', '123456789'))
            .addWhere(
                dynlistSOQLBuilder.disjunction()
                .add(dynlistSOQLBuilder.eq('Name', 'Test'))
                .add(dynlistSOQLBuilder.eq('Name', 'Test2'))
                .add(
                    dynlistSOQLBuilder.conjunction()
                    .add(dynlistSOQLBuilder.eq('Field1', 'value1'))
                    .add(dynlistSOQLBuilder.eq('Field2', 'value2'))
                )
            );
        
        String conditionLogicString = builder.toConditionLogicString();
        
        System.assert(conditionLogicString == '{A} AND ({B} OR {C} OR ({D} AND {E}))', 'Expected conditionLogicString to be `{A} AND ({B} OR {C} OR ({D} AND {E}))`, was: ' + conditionLogicString);
        
    }
    
    @IsTest
    static void testConditionLogicStringThatWasAlreadySet() 
    {
        dynlistSOQLBuilder builder = null;
        String sql = null;
        String conditionLogicString = null;
        
        builder = dynlistSOQLBuilder.create()
            .addWhere(dynlistSOQLBuilder.eq('Id', '123456789'))
            .addWhere(dynlistSOQLBuilder.eq('Name', 'Test'))
            .addWhere(dynlistSOQLBuilder.eq('Name', 'Test2'))
            .addWhere(dynlistSOQLBuilder.eq('Field1', 'value1'))
            .addWhere(dynlistSOQLBuilder.eq('Field2', 'value2'))
            ;
        
        conditionLogicString = builder.toConditionLogicString();
        System.assert(conditionLogicString == '{A} AND {B} AND {C} AND {D} AND {E}', 'Expected conditionLogicString to be `{A} AND {B} AND {C} AND {D} AND {E}`, was: ' + conditionLogicString);
        
        builder.setConditionLogic('{A} AND ({B} OR {C} OR ({D} AND {E}))');
        conditionLogicString = builder.toConditionLogicString();
        System.assert(conditionLogicString == '{A} AND ({B} OR {C} OR ({D} AND {E}))', 'Expected conditionLogicString to be `{A} AND ({B} OR {C} OR ({D} AND {E}))`, was: ' + conditionLogicString);
    }
    
    @IsTest
    static void testFieldSet() 
    {
        String sql = null;
        String sObjectName = System.Label.DYNLIST_APPLICATION_SETTINGS_OBJECT_NAME;
        String fieldsetName = System.Label.DYNLIST_APPLICATION_SETTINGS_FIELD_SET_NAME;
        dynlistSOQLBuilder builder = dynlistSOQLBuilder.create();
        //Use Case 2  -  (sObjectType != null)
        sql = builder.forFieldSet(sObjectName, fieldsetName).toQuery();
        sql = builder.forFieldSet(sObjectName, fieldsetName).toQuery();
        
        List<sObject> sobjectList = Database.query(sql);
        System.assert(sobjectList != null);
        
        //Use Case 2  -  (sObjectType == null)
        sObjectName = 'test';
        try{
            sql = builder.forFieldSet('test', System.Label.DYNLIST_APPLICATION_SETTINGS_FIELD_SET_NAME).toQuery();
        }
        Catch(exception e){
            System.assertEquals('No sObject found with name test', e.getMessage());
        }
        
        //Use Case 3  -  (schemaFieldset == null)
        fieldsetName = 'test';
        sObjectName = System.Label.DYNLIST_APPLICATION_SETTINGS_OBJECT_NAME;
        try{
            sql = builder.forFieldSet(System.Label.DYNLIST_APPLICATION_SETTINGS_OBJECT_NAME, 'test').toQuery();
        }
        Catch(exception e){
            System.assertEquals('Fieldset not found with name: '+fieldsetName + ' on sObject ' + sObjectName, e.getMessage());
        }
    }
    
    @IsTest
    static void testFieldSets() 
    {
        String sql = null;
        dynlistSOQLBuilder builder = dynlistSOQLBuilder.create();
        
        sql = builder.forFieldSets(System.Label.DYNLIST_APPLICATION_SETTINGS_OBJECT_NAME, new String[] {
            System.Label.DYNLIST_APPLICATION_SETTINGS_FIELD_SET_NAME}).toQuery();
        
        List<sObject> sobjectList = Database.query(sql);
        System.assert(sobjectList != null);
    }
    
    @IsTest
    static void testDateFunctions() 
    {
        String sql = null;
        dynlistSOQLBuilder builder = dynlistSOQLBuilder.create();
        
        sql = builder
            .addFrom('Account')
            .addWhere( dynlistSOQLBuilder.eq('CALENDAR_YEAR(CreatedDate)', 2017) )
            .toQuery();
        
        System.assert(!sql.contains('\'CALENDAR_YEAR(CreatedDate)\' = 2017'), 'Expected `CALENDAR_YEAR(CreatedDate) = 2017` without quotes');
        System.assert(sql.contains('CALENDAR_YEAR(CreatedDate) = 2017'), 'Expected `CALENDAR_YEAR(CreatedDate) = 2017` without quotes');
        
        sql = builder
            .addWhere( dynlistSOQLBuilder.eq('FISCAL_QUARTER(CreatedDate)', 1) )
            .toQuery();
        
        System.assert(!sql.contains('\'FISCAL_QUARTER(CreatedDate)\' = 1'), 'Expected `FISCAL_QUARTER(CreatedDate) = 1` without quotes');
        System.assert(sql.contains('FISCAL_QUARTER(CreatedDate) = 1'), 'Expected `FISCAL_QUARTER(CreatedDate) = 1` without quotes');
        
        List<sObject> sobjectList = Database.query(sql);
        
        System.assert(sobjectList != null);
    }
    
    @IsTest
    static void testDateLiterals() 
    {
        String sql = null;
        dynlistSOQLBuilder builder = dynlistSOQLBuilder.create();
        
        sql = builder
            .addFrom('Account')
            .addWhere( dynlistSOQLBuilder.eq('CreatedDate', 'THIS_YEAR') )
            .toQuery();
        
        System.assert(!sql.contains('CreatedDate = \'THIS_YEAR\''), 'Expected `THIS_YEAR` without quotes');
        System.assert(sql.contains('CreatedDate = THIS_YEAR'), 'Expected `THIS_YEAR` without quotes');
        
        sql = builder
            .addWhere( dynlistSOQLBuilder.eq('CreatedDate', 'LAST_N_DAYS:90') )
            .toQuery();
        
        System.assert(!sql.contains('CreatedDate = \'LAST_N_DAYS:90\''), 'Expected `CreatedDate = LAST_N_DAYS:90` without quotes');
        System.assert(sql.contains('CreatedDate = LAST_N_DAYS:90'), 'Expected `CreatedDate = LAST_N_DAYS:90` without quotes');
        
        List<sObject> sobjectList = Database.query(sql);
        
        System.assert(sobjectList != null);
    }
    
    @IsTest
    static void testDateFormats() 
    {
        String sql = null;
        dynlistSOQLBuilder builder = dynlistSOQLBuilder.create();
        
        /*sql = builder
.addFrom('Account')
.addWhere( dynlistSOQLBuilder.ge('SCMC__Credit_Card_Expiration_Date__c	', '2017-01-01') )
.toQuery();

System.assert(!sql.contains('Date_of_birth__c >= \'2017-01-01\''), 'Expected `2017-01-01` without quotes: ' + sql);*/
        
        sql = builder
            .addFrom('Account')
            .addWhere( dynlistSOQLBuilder.ge('CreatedDate', '2017-01-01T23:01:01+01:00') )
            .toQuery();
        
        System.assert(!sql.contains('CreatedDate >= \'2017-01-01T23:01:01+01:00\''), 'Expected `CreatedDate >= 2017-01-01T23:01:01+01:00` without quotes: ' + sql);
        System.assert(sql.contains('CreatedDate >= 2017-01-01T23:01:01+01:00'), 'Expected `CreatedDate >= 2017-01-01T23:01:01+01:00` without quotes: ' + sql);
        
        sql = builder
            .addWhere( dynlistSOQLBuilder.ge('CreatedDate', '2017-01-01T23:01:01-04:00') )
            .toQuery();
        
        System.assert(!sql.contains('CreatedDate >= \'2017-01-01T23:01:01-04:00\''), 'Expected `CreatedDate >= 2017-01-01T23:01:01-04:00` without quotes: ' + sql);
        System.assert(sql.contains('CreatedDate >= 2017-01-01T23:01:01-04:00'), 'Expected `CreatedDate >= 2017-01-01T23:01:01-04:00` without quotes: ' + sql);
        
        sql = builder
            .addWhere( dynlistSOQLBuilder.ge('CreatedDate', '2017-01-01T23:01:01Z') )
            .toQuery();
        
        System.assert(!sql.contains('CreatedDate >= \'2017-01-01T23:01:01Z\''), 'Expected `CreatedDate >= 2017-01-01T23:01:01Z` without quotes: ' + sql);
        System.assert(sql.contains('CreatedDate >= 2017-01-01T23:01:01Z'), 'Expected `CreatedDate >= 2017-01-01T23:01:01Z` without quotes: ' + sql);
        
        List<sObject> sobjectList = Database.query(sql);
        
        System.assert(sobjectList != null);
    }
    
    @IsTest
    static void testQuery() 
    {
        String sql = dynlistSOQLBuilder.create()
            .addSelect('Id')
            .addFrom('Account')
            .addWhere(dynlistSOQLBuilder.notNull('Id'))
            .addSortAsc('Id')
            .setLimit(1)
            .toQuery()
            ;
        
        List<sObject> sobjectList = Database.query(sql);
        
        System.assert(sobjectList != null);
    }
    
    @IsTest
    static void testCountQuery() 
    {
        String sql = dynlistSOQLBuilder.create()
            .addSelect('Id')
            .addFrom('Account')
            .addWhere(dynlistSOQLBuilder.notNull('Id'))
            .addSortAsc('Id')
            .setLimit(1)
            .setOffset(1)
            .toCountQuery()
            ;
        
        Integer count = Database.countQuery(sql);
        
        System.assert(count != null);
    }
    
    
    @IsTest
    static void testInvalidQuery() 
    {
        String sql = dynlistSOQLBuilder.create()
            .addSelect('someColumn')
            .addFrom('someObject')
            .setLimit(1)
            .toQuery()
            ;
        
        Boolean failed = false;
        
        try 
        {
            List<sObject> sobjectList = Database.query(sql);
        }
        catch(Exception e) 
        {
            failed = true;
        }
        
        System.assert(failed);
    }
    
    @IsTest
    static void testPages() 
    {
        Integer customPageSize = 10;
        Integer queryOffset;
        dynlistSOQLBuilder builder = dynlistSOQLBuilder.create().setLinebreaks(false).addSelect('Id').addFrom('Account');
        String sql = null;
        
        // set first page with default pageSize
        sql = builder.setPage(1).toQuery();
        System.assert(sql.endsWith('LIMIT ' + dynlistSOQLBuilder.DEFAULT_PAGE_SIZE), 'query should end with `LIMIT ' + dynlistSOQLBuilder.DEFAULT_PAGE_SIZE + '`, was: ' + sql);
        
        // set first page with custom pagesize
        sql = builder.setPage(1, customPageSize).toQuery();
        System.assert(sql.endsWith('LIMIT ' + customPageSize), 'query should end with `LIMIT ' + customPageSize + '`, was: ' + sql);
        
        // set 5th page, default pagesize
        sql = builder.setPage(5).toQuery();
        queryOffset = (5 * dynlistSOQLBuilder.DEFAULT_PAGE_SIZE) - dynlistSOQLBuilder.DEFAULT_PAGE_SIZE;
        System.assert(sql.endsWith('LIMIT ' + dynlistSOQLBuilder.DEFAULT_PAGE_SIZE + ' OFFSET ' + queryOffset), 'query should end with `LIMIT ' + dynlistSOQLBuilder.DEFAULT_PAGE_SIZE + ' OFFSET ' + queryOffset + '`, was: ' + sql);
        
        // set 5th page, custom pagesize
        sql = builder.setPage(5, customPageSize).toQuery();
        queryOffset = (5 * customPageSize) - customPageSize;
        System.assert(sql.endsWith('LIMIT ' + customPageSize + ' OFFSET ' + queryOffset), 'query should end with `LIMIT ' + customPageSize + ' OFFSET ' + queryOffset + '`, was: ' + sql);
    }
    
    @IsTest
    static void testRemoveWhere() 
    {
        dynlistSOQLBuilder builder = dynlistSOQLBuilder.create().addFrom('Account').setLinebreaks(false);
        String sql;
        
        // Simple where condition
        sql = builder.addWhere(dynlistSOQLBuilder.eq('removedField', 'someValue')).toQuery();
        System.assert(sql.contains('removedField'), 'Expected `removedField` in query, was: ' + sql);
        
        sql = builder.removeWhereCondition('removedField').toQuery();
        System.assert(!sql.contains('removedField'), 'Not expected `removedField` in query, was: ' + sql);
        
        // Nested where conditions
        sql = builder.addWhere(
            dynlistSOQLBuilder.conjunction()
            .add(dynlistSOQLBuilder.eq('removedField', '1234567890'))
            .add(dynlistSOQLBuilder.eq('someColumn', 'someValue'))
            .add(dynlistSOQLBuilder.disjunction()
                 .add(dynlistSOQLBuilder.eq('removedField', '1234567890'))
                 .add(dynlistSOQLBuilder.eq('someColumn', 'someValue'))
                 .add(dynlistSOQLBuilder.eq('someColumn2', 'someValue2'))
                )
        ).toQuery();
        System.assert(sql.contains('removedField'), 'Expected `removedField` in query, was: ' + sql);
        
        sql = builder.removeWhereCondition('removedField').toQuery();
        System.assert(!sql.contains('removedField'), 'Not expected `removedField` in query, was: ' + sql);
        
        // Try removing where conditions with a fresh and empty soqlbuilder
        builder = dynlistSOQLBuilder.create().removeWhereCondition('someField');
    }
    
    @IsTest
    static void testRemoveWhereNotRecursive() 
    {
        dynlistSOQLBuilder builder = dynlistSOQLBuilder.create().addFrom('Account').setLinebreaks(false);
        String sql;
        
        builder
            .addWhere(dynlistSOQLBuilder.eq('removedField', 'someValue'))
            .addWhere(dynlistSOQLBuilder.conjunction().add(dynlistSOQLBuilder.eq('removedField', 'someValue')));
        
        System.assert(builder.toQuery().countMatches('removedField') == 2, 'Expected 2 occurrences of `removedField` in query, was: ' + builder.toQuery().countMatches('removedField'));
        
        // remove top level conditions
        builder.removeWhereCondition(new dynlistSOQLBuilder.RemoveWhereOptions('removedField').setNestedStrategy(dynlistSOQLBuilder.RemoveWhereNestedStrategyEnum.ROOT_ONLY));
        
        System.assert(builder.toQuery().countMatches('removedField') == 1, 'Expected 1 occurrence of `removedField` in query, was: ' + builder.toQuery().countMatches('removedField'));
        
        //Use Case -  with Restriction
        List<dynlistSOQLBuilder.RestrictionEnum> resEnum = new List<dynlistSOQLBuilder.RestrictionEnum>();
        builder.removeWhereCondition(new dynlistSOQLBuilder.RemoveWhereOptions('removedField').ignoreRestrictions(resEnum));
        System.assert(builder != null);
        
    }
    
    //Added by - Abhinav sharma  -  11/09/2021 - Added a new method to test getWhere
    @IsTest
    static void testGetWhere() 
    {
        dynlistSOQLBuilder builder = dynlistSOQLBuilder.create().addFrom('Account').setLinebreaks(false);
        System.assert(builder.getWhere() != null);
        
    }
    //Added by - Abhinav sharma  -  11/09/2021 - Added a new method to test setWillReturnResults
    @IsTest
    static void testSetWillReturnResults() 
    {
        dynlistSOQLBuilder builder = dynlistSOQLBuilder.create().addFrom('Account').setLinebreaks(false);
        System.assert(builder.setWillReturnResults(true) != null);
        
    }
    //Added by - Abhinav sharma  -  11/09/2021 - Added a new method to test getWillReturnResults
    @IsTest
    static void testGetWillReturnResults() 
    {
        dynlistSOQLBuilder builder = dynlistSOQLBuilder.create().addFrom('Account').setLinebreaks(false);
        System.assert(builder.getWillReturnResults() == true);
        
    }
    //Added by - Abhinav sharma  -  11/09/2021 - Added a new method to test valueNotLike
    @IsTest
    static void testValueNotLike() 
    {
        System.assert(dynlistSOQLBuilder.valueNotLike('Name', dynlistTestDataFactory.createAccountTestData()) != null);
    }
}