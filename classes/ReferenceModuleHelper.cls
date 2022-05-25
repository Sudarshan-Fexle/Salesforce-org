/**
 *  Description     :  Helper class for the ReferenceModule Extension
 *
 *  Revision Logs   :   v1.0 - 12/08/2015 - Created - Victor Hanson - Reference Tracking project (CR-20150826-9191)
 **/
public without sharing class ReferenceModuleHelper {
	
    private string recordTypeName { get; set; }
    
    /**
     * @description: map to hold the reference module hierarchy
     **/
    public map<string, set<string>> referenceModuleMap {
        get {
            if (referenceModuleMap == null) referenceModuleMap = new map<string, set<string>>();
            return referenceModuleMap;
        }
        set;
    }
    
    /**
     * @description: constructor
     **/
    public ReferenceModuleHelper(string recordTypeName) {
        this.recordTypeName = recordTypeName;
        //populate the reference picklists
        getReferences();
    }
    
    private void getReferences() {
        //create the dynamic query
        string qry = 'SELECT Program_Perspective__r.Program_Group__r.Name, Program_Group__r.Name, Name,'
            		+ '(SELECT Id, Name, Collection_Perspective_Child__r.Name FROM Grandchildren__r) '
            		+ 'FROM Program_Relationship__c '
            		+ 'WHERE Program_Perspective__r.Perspective__r.Name =  \'' + Label.Reference_Tracking + '\' ';
        
        if (recordTypeName != null)
            qry += ' AND Program_Perspective__r.Program_Group__r.Name = :recordTypeName ';
        
        qry += ' ORDER BY Program_Group__r.Name ASC';
        
        //query for collection perspectives and child records
        for (Program_Relationship__c collectionChild : database.query(qry)) 
        {
            set<string> grandChildren = referenceModuleMap.get(collectionChild.Program_Group__r.Name);
            if (grandChildren == null) grandChildren = new set<string>();
            if (collectionChild.Grandchildren__r != null) {
                for (CollectionContents__c grandChild : collectionChild.Grandchildren__r) {
                    grandChildren.add(grandChild.Name);
                }
            }
            referenceModuleMap.put(collectionChild.Program_Group__r.Name, grandChildren);
        }
    }
    
    /**
    * This method validates wether the record type is not set. This can only happen when the user has only
    * rights to one specific record type. In that scenario the user does not see the record type selection screen.
    * In these cases the record type is not set out of the box. This method finds the appropiate record type for this user and 
    * add this as a parameter to the page.  
    */
    public static string getDefaultRecordTypeId(string objAPIName) {
        Id rtId;
        Schema.DescribeSObjectResult describeObj = Schema.describeSObjects(new list<string> { objAPIName })[0];
        List<Schema.RecordTypeInfo> rtInfos = describeObj.getRecordTypeInfos();
        for(Schema.RecordTypeInfo rtInfo : rtInfos) {
            // walk through the map to determine the correct record type, this is done with the isAvailable() function
            if(rtInfo.getName() != 'Master' && rtInfo.isAvailable()) {
                // below lines will only run one time only
                rtId = rtInfo.getRecordTypeId();
            }
        }
        
        return rtId;
    }
    
}