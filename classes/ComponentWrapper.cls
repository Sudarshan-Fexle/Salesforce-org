/**
 * @description: Created for Deployment Strategy
 * 
 * @revision log:	V1.0 - 11/07/2015 - Victor Hanson - Created
 * 
 **/
public class ComponentWrapper {
	
    /** wrapper variables **/
    public integer pageNo;
    public integer pageSize;
    public integer pageCount;
    public string lastRefreshedTime { get; set; }
    public integer totalRecordCount { get; set; }
    public list<Component> items {
        get {
            if (items ==  null) {
                items = new list<Component>();
            }
            return items;
        }
        set;
    }
    
    public class Component implements Comparable {
        /** component variables **/
        public string lastModifiedBy { get; set; }
        public string lastModifiedDateTime { get; set; }
        public boolean isDeleted { get; set; }
        //public boolean isSelected { get; set; }
        public boolean selected { get; set; }
        public boolean isDupe { get; set; }
        public integer itemId { get; set; }
        public string itemType { get; set; }
        public string itemStatus { get; set; }
        public string apiName { get; set; }
        public string description { get; set; }
        public string sfId { get; set; }
        public string sbxName { get; set; }
        public string parent { get; set; }
        public string label { get; set; }
        public string createdDateTime { get; set; }
        public string createdBy { get; set; }
        public string fullName { get; set; }
        public string namespace { get; set; }
        public string dataType { get; set; }
        public string parentSFId { get; set; }
        public string parentAPIName { get; set; }
		public string parentLabel { get; set; }
		public string parentFullName { get; set; }
		public string parentItemType { get; set; }
		public string parentIsDeleted { get; set; }
        public string modType { get; set; }
        public string modId { get; set; }
        public string modOwnerId { get; set; }
        public string recordTypeName { get; set; }
        public boolean expanded { get; set; }
        public boolean ctrlClickSelected { get; set; }
        
        
        public Integer compareTo(Object compareTo) {
            Component c = (Component) compareTo;
            if (apiName == c.apiName) return 0;
            if (apiName > c.apiName) return 1;
            return -1;        
        }
    }
    
    public static ComponentWrapper parse(String jsonString) {
		return (ComponentWrapper) JSON.deserialize(jsonString, ComponentWrapper.class);
	}
    
    
}