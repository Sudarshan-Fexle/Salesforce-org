/**
 *  Description     :  Helper class for the Dependent Picklist functionality
 *
 *  Revision Logs   :   v1.0 - 12/10/2015 - Created - Victor Hanson - Reference Tracking project (CR-20150826-9191)
 * 						v1.1 - 03/26/2018 - Modified - Victor Hanson - Updated to fix an issue where no picklist options threw an error on the TimeTracking widget in sandboxes with no data (CR-20180220-12078)
 **/
public class PicklistHelper {
    //object and field api name
    public string objAPIName { get; set; }
    public string fldAPIName { get; set; }
    public string rtName { get; set; }
    //private list<PicklistWrapper> pWrappers { get; set; }
    
    public PicklistHelper(string objAPIName, string fldAPIName, string rtName) {
        this.objAPIName = objAPIName;
        this.fldAPIName = fldAPIName;
        this.rtName = rtName;
    }
    
    
    public list<DP_Picklist__c> picklists {
        get {
            if (picklists == null) {
                
                list<DP_Picklist__c> picklistQry = [SELECT Id, Alpha_Sort__c,
                                                  (SELECT Id, Controlling_Value__c, Controlling_Entry__c, Dependent_Value__c, Dependent_Entry__c, 
                                                   Dependent_Entry__r.Display_Name__c, Dependent_Entry__r.Sort_Order__c, Dependent_Picklist__r.Alpha_Sort__c 
                                                   FROM Picklist_Dependencies__r WHERE Dependent_Entry__r.Active__c = true) FROM DP_Picklist__c 
                                                  WHERE Id IN (SELECT Picklist__c 
                                                               FROM DP_Picklist_Usage__c 
                                                               WHERE Object__c = :objAPIName
                                                               AND Field__c = :fldAPIName
                                                               AND RecordType.Name = :rtName)];
                if (picklistQry != null && picklistQry.size() > 0) picklists = picklistQry;
                
            }
            return picklists;
        }
        set;
    }
    
    //map<Controlling_Value, list<PicklistEntries>>  (ie: <"CMA", list<PicklistEntries>>)
    public map<string, list<PicklistWrapper>> getWrapperMap() {
        //map<"CCC", list<picklistWrapper>>
        map<string, list<PicklistWrapper>> wrapperMap = new map<string, list<PicklistWrapper>>();
        //map<"Purchased Over Competitor", list<picklistWrapper>>
        map<string, list<PicklistWrapper>> tempWrapperMap = new map<string, list<PicklistWrapper>>();
        
        //list of dependent entries so we can query the child values
        set<Id> controllingEntryIds = new set<Id>();
        
        if (picklists != null) {
            for (DP_Picklist__c picklist : picklists) {
                if (picklist != null && picklist.Picklist_Dependencies__r != null) {
                    
                    //loop through each dependency value
                    for (DP_Picklist_Dependency__c pDependency : picklist.Picklist_Dependencies__r) {
                        list<PicklistWrapper> tempList = wrapperMap.get(pDependency.Controlling_Value__c);
                        if (tempList == null) tempList = new list<PicklistWrapper>();
                        //add the picklist entry to the list of wrappers
                        tempList.add(new PicklistWrapper(pDependency.Dependent_Entry__c,
                                                         pDependency.Dependent_Entry__r.Display_Name__c,
                                                         pDependency.Dependent_Entry__r.Sort_Order__c,
                                                         pDependency.Dependent_Picklist__r.Alpha_Sort__c));
                        wrapperMap.put(pDependency.Controlling_Value__c, tempList);
                        //add dependent entry id to our set of ids for query later
                        controllingEntryIds.add(pDependency.Dependent_Entry__c);
                    }
                }
            }
        }
        
        map<Id, DP_Picklist_Entry__c> controllingEntries = new map<Id, DP_Picklist_Entry__c>([SELECT Id, Display_Name__c, (SELECT Id, Controlling_Value__c, Controlling_Entry__c, Dependent_Value__c,
                                                                                      Dependent_Entry__r.Display_Name__c, Dependent_Entry__r.Sort_Order__c, Dependent_Entry__r.Picklist__r.Alpha_Sort__c
                                                                                      FROM Picklist_Dependencies__r) 
                                                              FROM DP_Picklist_Entry__c 
                                                              WHERE Id IN :controllingEntryIds]);
        
        for (DP_Picklist_Entry__c dependentEntry : controllingEntries.values()) {
            list<PicklistWrapper> tempList2 = new list<PicklistWrapper>();
            for (DP_Picklist_Dependency__c controllingEntry : dependentEntry.Picklist_Dependencies__r) {
                tempList2.add(
                    new PicklistWrapper(controllingEntry.Dependent_Entry__c,
                                        controllingEntry.Dependent_Entry__r.Display_Name__c, 
                                        controllingEntry.Dependent_Entry__r.Sort_Order__c, 
                                        controllingEntry.Dependent_Entry__r.Picklist__r.Alpha_Sort__c));
            }
            //sort the list
            tempList2.sort();
            tempWrapperMap.put(dependentEntry.Id, tempList2);
        }
        
        //add the values in to the master map
        for (string key : wrapperMap.keySet()) {
            list<PicklistWrapper> wrappers = wrapperMap.get(key);
            wrappers.sort(); // sort wrappers
            for (PicklistWrapper wrapper : wrappers) {
                list<PicklistWrapper> cWrappers = tempWrapperMap.get(wrapper.id);
                if (cWrappers != null) {
                    wrapper.childWrappers.addAll(cWrappers);
                }
            }
        }
        
        return wrapperMap;
    }
    
    
    
    /**
     * 
     * @description: wrapper class to hold selectOption for dynamic picklist.
     * 
    **/
    public class PicklistWrapper implements Comparable{
        
        public string id { get; set; }
        public string displayName { get; set; }
        public boolean alphaSort { get; set; }
        public decimal customSortOrder { get; set; }
        list<PicklistWrapper> childWrappers {
            get {
                if (childWrappers == null) childWrappers = new list<PicklistWrapper>();
                return childWrappers;
            }
            set;
        }
        
        public PicklistWrapper(string id, string displayName, decimal customSortOrder, boolean alphaSort) {
            this.id = id;
            this.displayName = displayName;
            this.alphaSort = alphaSort;
            this.customSortOrder = customSortOrder;
        }
        
        public Integer compareTo(Object compareTo) {
            PicklistWrapper wrapper = (PicklistWrapper) compareTo;
            if (wrapper.alphaSort) { //sort by the picklist alpha sort
                if (displayName == wrapper.displayName) return 0;
                if (displayName > wrapper.displayName) return 1;
            }
            else {//sort by the picklistEntry sort order
                if (customSortOrder == wrapper.customSortOrder) return 0;
                if (customSortOrder > wrapper.customSortOrder) return 1;
            }
            return -1;        
        }
    }
}