/**
*  Purpose         :  Test class for sdgMapper
*               
*  Created By      :  Mahendra Swarnakar
*   
*  Created Date    :  6/14/2020 
*   
*  Revision Log    :   v1.0  
*                       
*  Coverage        :   88%
**/
@isTest
private class Test_sdgMapper {
    @TestSetup
    static void makeData(){

        //Bypass Flags
        Util.IsTest(true);
        Util.isTesting = true;
        Util.byPassAllTriggers = true;
        Util.ByPassDLRSForTest = true;

        SDG__c sdg = new SDG__c();
        sdg.name = 'whatever';
        sdg.sdg_tag__c = sdg.name;
        sdg.sObjectName__c = 'Contact';
        sdg.is_valid__c = true;
        sdg.Parent_Field_Name__c = 'account.Id';
        insert sdg;

        SDG_Action__c act = new SDG_Action__c();
        act.requires_createable__c = true;
        act.Requires_Editable__c= true;
        act.Action_Type__c = 'List';
        act.event_payload__c = '{ dummy payload}';
        act.Action_Order__c=1;
        //Added by Mahendra Swarnkar -04/17/2020 - CR-20200225-13804
        act.Requires_Record_Type_Selection__c=false;
        act.sdg__c = sdg.ID;
        act.Event__c='c.force:editRecord';
        insert act;

       
        
        SDG_Field__c efield = new SDG_Field__c();
        efield.apiname__c='amounts';
        efield.FieldOrder__c=5;
        efield.is_valid_field__c = true;
        efield.sdg__c= sdg.ID;
        insert efield;
        
        Account acc = new Account();
        acc.name = 'Test';
        insert acc;

    }

    @isTest
    static void test_Convert(){
        
        List<SDG_Action__c> actions = [SELECT ID,Name,Event__c,Action_Type__c,action_order__c,Event_Payload__c,Icon__c,Requires_Record_Type_Selection__c,   Requires_Createable__c, Requires_Editable__c,Requires_Deletable__c FROM SDG_Action__c];
        
        SDG__c core = [SELECT ID,sObjectName__c ,DisableSharing__c,  Parent_Field_Name__c , Filter__c , Default_Sort__c, All_Rows__c FROM SDG__c LIMIT 1];
        
        List<SDG_Field__c> fields = [SELECT ID, Name,APIName__c, Hide_Filter__c, Override_Label__c,Field_Style__c, fieldOrder__c , Select_Option_Query__c  FROM SDG_Field__c];
         
        
        Test.startTest();
        SDG sdg ;
        sdg = sdgMapper.Convert(core, fields, actions, true);

        system.assert(sdg != null);
        system.assertEquals(1, sdg.SDGActions[0].actionOrder);
        system.assertEquals(actions[0].event_payload__c, sdg.SDGActions[0].Payload);
        system.assertEquals('Contact', sdg.sObjectName);
        system.assertEquals(new List<SDGField> {}, sdg.SDGFields);

        Test.stopTest();
       
    }
    

    
    @isTest
    static void test_MapField(){

        Util.IsTest(true);
        Util.isTesting = true;
        Util.byPassAllTriggers = true;
        Util.ByPassDLRSForTest = true;

        Map<String, Schema.SObjectField> FieldMap =  Schema.SObjectType.Account.fields.getMap();
        
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
        Test.startTest();
        SDGField sdgF ;
        for(SObjectField sof: fieldmap.values())
        {
            DescribeFieldResult dfr = sof.getDescribe();
            if(dfr.isNameField())
            {
                SDGField namefield = sdgMapper.MapField(dfr,dfr.getName(), dfr.getName(), true,'', null, 1, '',Schema.SObjectType.Account.Name);
                
                system.assert(namefield != null);
                system.assertEquals(1, namefield.FieldOrder);
                system.assertEquals('STRING', namefield.FieldType);
            }
            if(String.valueOf(dfr.getType()) == 'PICKLIST')
            {
                
                SDGField namefield1 = sdgMapper.MapField(dfr,dfr.getName(), dfr.getName(), false,'', null, 1, null,   Schema.SObjectType.Account.Name);
                
                SDGField namefield = sdgMapper.MapField(dfr,dfr.getName(), dfr.getName(), false,'', null, 1, 'Select ID,Name from Account',   Schema.SObjectType.Account.Name);
                
                system.assert(namefield != null);
                system.assertEquals(1, namefield.FieldOrder);
                system.assertEquals('PICKLIST', namefield.FieldType);
            }

        }    
        Test.stopTest();
    }
    }

    @isTest
    static void test_getRecordTypeOptions(){

        Util.IsTest(true);
        Util.isTesting = true;
        Util.byPassAllTriggers = true;
        Util.ByPassDLRSForTest = true;
        
        List<RecordType> rType =  [Select Id, Name From RecordType where sObjectType =: 'Account'];
        
        Test.startTest();
        List<AuraSelectOption> listOfAuraSO = new List<AuraSelectOption>();

        listOfAuraSO = sdgMapper.getRecordTypeOptions('Account');

        system.assert(listOfAuraSO != null);
        system.assertEquals(rType.size() + 1, listOfAuraSO.size());

        Test.stopTest();
    }
    
}