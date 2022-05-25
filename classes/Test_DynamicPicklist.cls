@isTest
public class Test_DynamicPicklist {
    
    public static string oAPIName = 'Relationship_Interaction__c';
    public static string fAPIName = 'Interaction_Type__c';
    
    //create dynamic picklist custom settings
    public static void setupDynamicPicklist(string objAPIName, string fldAPIName, map<string, boolean> picklistValuesMap) {
        //create picklist
        Picklist__c picklist = new Picklist__c(Name = objAPIName + '_PL',
                                               Label__c = fldAPIName,
                                               Alpha_Sort__c = true);
        insert picklist;
        
        //create the picklistUsage
        PicklistUsage__c usage = new PicklistUsage__c(Name = objAPIName + '_PU',
                                                      Picklist__c = picklist.Name,
                                                      Object__c = objAPIName,
                                                      Field__c = fldAPIName);
        insert usage;
        
        //create picklist entries
        list<PicklistEntry__c> entries = new list<PicklistEntry__c>();
        for (string val : picklistValuesMap.keySet()) {
            entries.add(new PicklistEntry__c(Name = val,
                                             Label__c = val,
                                             Picklist__c = picklist.Name,
                                             IsActive__c = picklistValuesMap.get(val),
                                             Description__c = 'test'));
        }
        insert entries;
    }
    
    public static void createInteractionPicklist() {
        map<string, boolean> picklistValueToActiveMap = new map<string, boolean>{'HSPI Summit' => true, 'NASA Visit' => true, 'VIP Day' => true, 'zzzzz' => false};
        setupDynamicPicklist('Relationship_Interaction__c', 'Interaction_Type__c', picklistValueToActiveMap);
    }
    
    public static void createOutcomePicklist() {
        map<string, boolean> picklistValueToActiveMap = new map<string, boolean>{'Meeting Recruitment' => true, 'Networking' => true, 'Reference Opton' => true, 'Strategic Plan Sourced' => true};
        setupDynamicPicklist('Outcome__c', 'Outcome_Type__c', picklistValueToActiveMap);
    }
    
    @testSetup static void setup() {
        //setup dynamic picklist custom settings
        createInteractionPicklist();
    }
    
    /**
     * 
     * @description: create picklist values with alpha sort = true.  Verify the picklist values are returned in the specified order.
     * 
     **/
    static testmethod void testGetPicklist() {
        DynamicPicklist dp = new DynamicPicklist(oAPIName, fAPIName);
        list<SelectOption> options = dp.getPicklistValues();
        
        system.assertEquals(3, options.size());
        //verify the sort order
        system.assertEquals('HSPI Summit', options[0].getLabel());
        system.assertEquals('NASA Visit', options[1].getLabel());
        system.assertEquals('VIP Day', options[2].getLabel());
    }
    
    /**
     * 
     * @description: create picklist values with a custom sort order.  Verify the picklist values are returned in the specified order.
     * 
     **/
    static testmethod void testGetPicklist_CustomSort() {
        map<string, Picklist__c> picklistMap = Picklist__c.getAll();
        for (Picklist__c p : picklistMap.values()) p.Alpha_Sort__c = false;
        update picklistMap.values();
        
        PicklistEntry__c pe1 = PicklistEntry__c.getInstance('VIP Day');
        pe1.Sort_Order__c = 1;
        PicklistEntry__c pe2 = PicklistEntry__c.getInstance('HSPI Summit');
        pe2.Sort_Order__c = 2;
        PicklistEntry__c pe3 = PicklistEntry__c.getInstance('NASA Visit');
        pe3.Sort_Order__c = 3;
        
        list<PicklistEntry__c> picklistEntries = new list<PicklistEntry__c>{ pe1, pe2, pe3 };
        update picklistEntries;
            
        DynamicPicklist dp = new DynamicPicklist(oAPIName, fAPIName);
        list<SelectOption> options = dp.getPicklistValues();
        
        system.assertEquals(3, options.size());
        //verify the sort order
        system.assertEquals('VIP Day', options[0].getLabel());
        system.assertEquals('HSPI Summit', options[1].getLabel());
        system.assertEquals('NASA Visit', options[2].getLabel());
    }
    
}