public class DynamicPicklist {
    
    //object and field api name
    public string objAPIName { get; set; }
    public string fldAPIName { get; set; }
    private list<PicklistWrapper> pWrappers { get; set; }
    
    public DynamicPicklist(string objAPIName, string fldAPIName) {
        this.objAPIName = objAPIName;
        this.fldAPIName = fldAPIName;
    }
    
    /**
     * 
     * @description: get picklist values for the specified object/field and sort them.
     * 
     * @return: list<SelectOption> sorted picklist values
     * 
     **/
    public list<SelectOption> getPicklistValues() {
        //create picklist wrapper
        pWrappers = new list<PicklistWrapper>();
        list<SelectOption> picklistValues = new list<SelectOption>();
        
        //create a selectOption for each entry
        for (PicklistEntry__c pe : picklistEntries) {
            pWrappers.add(new PicklistWrapper(new SelectOption(pe.Label__c, pe.Label__c), pe.Sort_Order__c, picklist.Alpha_Sort__c));
        }
        
        //sort picklist options
        pWrappers.sort();
        
        //add the sorted values to the list
        for (PicklistWrapper wrapper : pWrappers) picklistValues.add(wrapper.option);
        
        return picklistValues;
    }
    
    /**
     * 
     * @description: returns all picklist usage
     * 
     **/
    public PicklistUsage__c picklistUsage {
        get {
            if (PicklistUsage == null) {
                for (PicklistUsage__c usage : PicklistUsage__c.getAll().values()) {
                    if (usage.Object__c != null && usage.Object__c.equalsIgnoreCase(objAPIName) &&
                        usage.Field__c != null && usage.Field__c.equalsIgnoreCase(fldAPIName)) {
                        picklistUsage = usage;
                        break;
                    }
                }
            }
            return picklistUsage;
        }
        set;
    } 
    
    /**
     * 
     * @description: returns picklist based on picklistUsage
     * 
     **/
    public Picklist__c picklist {
        get {
            if (picklist == null && picklistUsage != null) {
                picklist = Picklist__c.getInstance(picklistUsage.Picklist__c);
            }
            return picklist;
        }
        set;
    }
    
    /**
     * 
     * @description: returns all picklist entries
     * 
     **/
    public list<PicklistEntry__c> picklistEntries {
        get {
            if (picklistEntries == null && picklist != null) {
                picklistEntries = new list<PicklistEntry__c>();
                for (PicklistEntry__c entry : PicklistEntry__c.getAll().values()) {
                    if (entry.IsActive__c && 
                        entry.Picklist__c != null && 
                        entry.Picklist__c.equalsIgnoreCase(picklist.Name)) 
                    {
                        picklistEntries.add(entry);
                    }
                }
            }
            return picklistEntries;
        }
        set;
    }
    
    /**
     * 
     * @description: wrapper class to hold selectOption for dynamic picklist.
     * 
     **/
    public class PicklistWrapper implements Comparable{
        
        public SelectOption option { get; set; }
        public boolean alphaSort { get; set; }
        public decimal customSortOrder { get; set; }
        
        public PicklistWrapper(SelectOption option, decimal customSortOrder, boolean alphaSort) {
            this.option = option;
            this.alphaSort = alphaSort;
            this.customSortOrder = customSortOrder;
        }
        
        public Integer compareTo(Object compareTo) {
            PicklistWrapper wrapper = (PicklistWrapper) compareTo;
            if (wrapper.alphaSort) { //sort by the picklist alpha sort
                if (option.getLabel() == wrapper.option.getLabel()) return 0;
                if (option.getLabel() > wrapper.option.getLabel()) return 1;
            }
            else {//sort by the picklistEntry sort order
                if (customSortOrder == wrapper.customSortOrder) return 0;
                if (customSortOrder > wrapper.customSortOrder) return 1;
            }
            return -1;        
        }
    }
}