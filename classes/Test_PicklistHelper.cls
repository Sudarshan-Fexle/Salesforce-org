@isTest
public class Test_PicklistHelper {
    
    /**
    * @description: create the dynamic picklists
    **/
    @TestVisible private static void createDynamicPicklist() {
        //get businses owner id
        Id businessOwnerId = userInfo.getUserId();
        //create picklists
        list<DP_Picklist__c> dpPicklists = new list<DP_Picklist__c>();
        DP_Picklist__c attribute = new DP_Picklist__c(Name='Attribute',
                                                      Description__c='A general list of property names',
                                                      Alpha_Sort__c=true,
                                                      Original_CR__c='CR-2015-0826-9191',
                                                      Business_Owner__c=businessOwnerId);
        DP_Picklist__c attributeValue = new DP_Picklist__c(Name='Attribute Value',
                                                           Description__c='A general list of property names',
                                                           Alpha_Sort__c=true,
                                                           Original_CR__c='CR-2015-0826-9191',
                                                           Business_Owner__c=businessOwnerId);
        dpPicklists.add(attribute);
        dpPicklists.add(attributeValue);
        insert dpPicklists;
        
        //create picklist entries
        list<DP_Picklist_Entry__c> dpPicklistEntries = new list<DP_Picklist_Entry__c>();
        DP_Picklist_Entry__c MultiRegionalHealthSystem = new DP_Picklist_Entry__c(Name='MultiRegionalHealthSystem',
                                                                                Display_Name__c='Multi/Regional Health System',
                                                                                Picklist__c=attribute.Id,
                                                                                Object__c='',
                                                                                Active__c=true);
        dpPicklistEntries.add(MultiRegionalHealthSystem);
        DP_Picklist_Entry__c SmallRural = new DP_Picklist_Entry__c(Name='SmallRural',
                                                                                Display_Name__c='Small Rural',
                                                                                Picklist__c=attribute.Id,
                                                                                Object__c='',
                                                                                Active__c=true);
        dpPicklistEntries.add(SmallRural);
        DP_Picklist_Entry__c Size = new DP_Picklist_Entry__c(Name='Size',
                                                            Display_Name__c='Size',
                                                            Picklist__c=attribute.Id,
                                                            Object__c='',
                                                            Active__c=true);
        dpPicklistEntries.add(Size);
        insert dpPicklistEntries;
        
        //create picklist usages
        list<DP_Picklist_Usage__c> dpPicklistUsages = new list<DP_Picklist_Usage__c>();
        DP_Picklist_Usage__c pluAttribute_A = new DP_Picklist_Usage__c(Picklist__c=attribute.Id,
                                                                       Object__c='Reference__c',
                                                                       Field__c='Field_A__c',
                                                                       Controlling_Field__c='Reference_Module__c',
                                                                       Record_Type_Dependent__c=true);
        dpPicklistUsages.add(pluAttribute_A);
        
        //reference request
        DP_Picklist_Usage__c pluReference_Attributes = new DP_Picklist_Usage__c(Picklist__c=attribute.Id,
                                                                                Object__c='Reference_Request__c',
                                                                                Field__c='Reference_Attributes__c',
                                                                                Controlling_Field__c='Reference_Products__c',
                                                                                Record_Type_Dependent__c=true);
        dpPicklistUsages.add(pluReference_Attributes);
        //attribute values
        DP_Picklist_Usage__c pluAttribute_Val_A = new DP_Picklist_Usage__c(Picklist__c=attributeValue.Id,
                                                                           Object__c='Reference__c',
                                                                           Field__c='Attribute_Value_A__c',
                                                                           Controlling_Field__c='Attribute_A__c',
                                                                           Record_Type_Dependent__c=true);
        dpPicklistUsages.add(pluAttribute_Val_A);
        
        //reference attributes
        DP_Picklist_Usage__c pluReference_Attributes_2 = new DP_Picklist_Usage__c(Picklist__c=attributeValue.Id,
                                                                                  Object__c='Reference_Request__c',
                                                                                  Field__c='Reference_Attributes__c',
                                                                                  Controlling_Field__c='Reference_Attributes__c',
                                                                                  Record_Type_Dependent__c=true);
        dpPicklistUsages.add(pluReference_Attributes_2);
        
        insert dpPicklistUsages;
        
        //create Picklist Dependencies
        list<DP_Picklist_Dependency__c> dpDependencies = new list<DP_Picklist_Dependency__c>();
        DP_Picklist_Dependency__c pdSize_MultiRegionalHealthSystem = new DP_Picklist_Dependency__c(Dependent_Picklist__c=attribute.Id,
                                                                                               Controlling_Entry__c=Size.Id,
                                                                                               Dependent_Entry__c=MultiRegionalHealthSystem.Id);
        dpDependencies.add(pdSize_MultiRegionalHealthSystem);
        DP_Picklist_Dependency__c pdSize_SmallRural = new DP_Picklist_Dependency__c(Dependent_Picklist__c=attribute.Id,
                                                                                               Controlling_Entry__c=Size.Id,
                                                                                               Dependent_Entry__c=SmallRural.Id);
        dpDependencies.add(pdSize_SmallRural);
        
        
        insert dpDependencies;
    }
    
    /**
     * @description: setup the test data
     **/
    @testSetup static void setup() {
        createDynamicPicklist();
    }
    
    /**
     * @description: test the dynamic picklist helper class and verify both alpha and custom sort orders.
     **/
    static testMethod void testPicklist() {
        //get the dependent picklist map
        map<string, list<PicklistHelper.PicklistWrapper>> picklistDependencyMap = new PicklistHelper('Reference__c', 'Field_A__c', 'Picklist Usage').getWrapperMap();
        system.assertEquals(1, picklistDependencyMap.size());
        //if the user selects reference module Size, the first attribute value should be Multi/Regional Health System
        list<PicklistHelper.PicklistWrapper> attributes = picklistDependencyMap.get('Size');
        system.assertEquals('Multi/Regional Health System', attributes[0].displayName, 'if the user selects reference module Size, the first attribute value should be Multi/Regional Health System (Alpha sort)');
        
        //change the sort to custom
        list<DP_Picklist__c>  picklists = [SELECT Id, Alpha_Sort__c FROM DP_Picklist__c];
        for (DP_Picklist__c p : picklists) p.Alpha_Sort__c = false;
        update picklists;
        
        //update the custom sort order to reverse the previous (alpha) order
        list<DP_Picklist_Entry__c> entries = [SELECT Id, Name, Sort_Order__c FROM DP_Picklist_Entry__c];
        for (DP_Picklist_Entry__c e : entries) {
            if (e.Name == 'SmallRural') e.Sort_Order__c = 1;
            else if (e.Name == 'MultiRegionalHealthSystem') e.Sort_Order__c = 2;
        }
        update entries;
        
        picklistDependencyMap = new PicklistHelper('Reference__c', 'Field_A__c', 'Picklist Usage').getWrapperMap();
        //if the user selects reference module Size, the first attribute value should be SmallRural, due to the custom sort order
        attributes = picklistDependencyMap.get('Size');
        system.assertEquals('Small Rural', attributes[0].displayName, 'if the user selects reference module Size, the first attribute value should be SmallRural (Custom sort)');
        
    }
}