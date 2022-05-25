/** @Modified By - Rajeev Jain - 06/28/2016 - SFDC Royall Migration - Migrated from Royall Enviournment to Corporate Instance
                    Rajeev Jain - 07/16/2016 - Fixed error found during run all test.
 * 
 * */
public class CloneWithItemsController {
    
    //added an instance varaible for the standard controller
    private ApexPages.StandardController controller {get; set;}
    
    // add the instance for the variables being passed by id on the url
    private SOBject so {get;set;}
    
    private static Map<String,Schema.SObjectType> gd;  
    
    private static map<String, List<CloneChildItemSettings__c>> theClonedChildMap = new map<String, List<CloneChildItemSettings__c>>();
    
    private static map<String, Map<string,string>> therelParentFieldMap = new map<String, Map<string,string>>();
    
    private static map<String, set<string>> theClonedChildstrMap = new map<String, set<string>>();  
    
    // map to store objects and their prefixes  
    private static Map<String, String> keyPrefixMap;  
  
    // to hold set of all sObject prefixes  
    private static Set<String> keyPrefixSet;  
 
    // initialize the controller
    public CloneWithItemsController(ApexPages.StandardController controller) {
 
        //initialize the stanrdard controller
        this.controller = controller;
        
        // load the current record
        so = (SObject)controller.getRecord();
 
    }
 
    // method called from the VF's action attribute to clone the po
    public PageReference cloneWithItems() {
 
         // setup the save point for rollback
         Savepoint sp = Database.setSavepoint();   
         SObject newSO;
         
         try {
            init();
            newSO = returnSObject(so.Id);
         }  catch (Exception e){
             // roll everything back in case of error
            Database.rollback(sp);
            ApexPages.addMessages(e);
            return null;
         }
         
         return new PageReference('/'+newSO.id+'/e?retURL=%2F'+newSO.id);
    }
    
    private static void init() {  
        // get all objects from the org  
        gd = Schema.getGlobalDescribe();  
          
        // to store objects and their prefixes  
        keyPrefixMap = new Map<String, String>{};  
          
        //get the object prefix in IDs  
        keyPrefixSet = gd.keySet();  
          
        // fill up the prefixes map  
        for(String sObj : keyPrefixSet)  
        {  
            Schema.DescribeSObjectResult r =  gd.get(sObj).getDescribe();  
            String tempName = r.getName();  
            String tempPrefix = r.getKeyPrefix();  
            keyPrefixMap.put(tempPrefix, tempName);  
        }  
        
        //fill the custom settings map of the child object
        list<CloneChildItemSettings__c> theCloneSettings = CloneChildItemSettings__c.getall().values(); 
        list<CloneChildItemSettings__c> ChildObj ;
        set<String> SetChild ;
        Map<string,string> RelFieldMap;
        for (CloneChildItemSettings__c ch : theCloneSettings) {
            if (ch.Active__c == false)
                continue;
            
            if (theClonedChildMap.containskey(ch.Parent_Object__c.toLowerCase())) {
                ChildObj = theClonedChildMap.get(ch.Parent_Object__c.toLowerCase());
                SetChild = theClonedChildstrMap.get(ch.Parent_Object__c.toLowerCase());
                RelFieldMap = therelParentFieldMap.get(ch.Parent_Object__c.toLowerCase());
            }
            else {
                ChildObj = new list<CloneChildItemSettings__c>(); 
                SetChild = new set<String>();
                RelFieldMap = new Map<string,string>();
            }
            ChildObj.add(ch);
            SetChild.add(ch.child_object__c.toLowerCase());
            RelFieldMap.put(ch.child_object__c.toLowerCase(),ch.Lookup_Field_Name__c);
            theClonedChildMap.put(ch.Parent_Object__c.toLowerCase(),ChildObj);
            theClonedChildStrMap.put(ch.Parent_Object__c.toLowerCase(),SetChild);  
            therelParentFieldMap.put(ch.Parent_Object__c.toLowerCase(),RelFieldMap) ;    
        }
    }  
    
    public static SObject returnSObject(String theStringId) {
        
        // get the opportunity Id
        Id theSobjectId = (Id) theStringId;
        Schema.DescribeSObjectResult descResult;
        String objectType;
        
        String tPrefix = theStringId;  
        tPrefix = tPrefix.subString(0,3); 
        
        for(String sObj : keyPrefixSet)  
        {  
            Schema.DescribeSObjectResult r =  gd.get(sObj).getDescribe();  
            String tempName = r.getName();  
            String tempPrefix = r.getKeyPrefix();
            if (tempPrefix != null ) {
                if (tempPrefix.compareTo(tPrefix) == 0) {
                    descResult = r;
                    objectType = tempName.toLowerCase();
                    break;
                }
            } 
        }  
         
        // get fields to ignore and create map
        map<String, set<String>> theIgnoredFieldMap = new map<String, set<String>>();
        list<CloneIgnoredFieldsSettings__c> theIgnoredFieldList = new list<CloneIgnoredFieldsSettings__c>([
            select Field__c, Object__c from CloneIgnoredFieldsSettings__c]);
        for (CloneIgnoredFieldsSettings__c r : theIgnoredFieldList) {
            if (!theIgnoredFieldMap.containsKey(r.Object__c.toLowerCase())) {
                set<String> temp = new set<String>();
                temp.add(r.Field__c.toLowerCase());
                theIgnoredFieldMap.put(r.Object__c.toLowerCase(), temp);
            } else {
                theIgnoredFieldMap.get(r.Object__c.toLowerCase()).add(r.Field__c.toLowerCase());
            }
        }
        
        //get the object field map now
        map<String, Schema.SObjectField> theSObjectFieldMap = descResult.fields.getMap();       
        
        //Retrieve a map of the fields on the SObject
        String theSObjectFields = '';
        for (String s : theSObjectFieldMap.keySet()) {
            if (s == 'Id') continue;
            theSObjectFields = theSObjectFields + s + ',';
        }
        theSObjectFields = theSObjectFields + 'Id' + ',Owner.Name';
        SObject theSObject;
        // get the opportunity with the Id passed and if it fails is probably because we are running a test method. 
        try {
            theSObject = Database.Query('select ' + theSObjectFields + ' from ' + objectType + ' where Id =: theSobjectId');
        } catch (Exception e) {
            return null;
        }
        SObject clonedParentObject = theSObject.clone(false,true);
        if (theIgnoredFieldMap.containsKey(objectType)) {
            for (String f : theIgnoredFieldMap.get(objectType)) {
                clonedParentObject.put(f,'');
            }
        }
        insert clonedParentObject;
        
        // List of Child relationships
        List<Schema.ChildRelationship> C = descResult.getChildRelationships();
        
        Map<String, Schema.SObjectType> ChildObjMap = new Map<String, Schema.SObjectType>();
        
        string childname ; 
        
        for (Schema.ChildRelationship child : C) {
            //system.debug(child.getChildSObject());
            childname = child.getChildSObject().getDescribe().getname().toLowerCase();
            if (theClonedChildStrMap.size()==0)
                break;
                
            if (theClonedChildStrMap==NULL)
                break;  
                
            if (theClonedChildStrMap.get(objectType.toLowerCase()).contains(childname))
                ChildObjMap.put(childname,child.getChildSObject());
        }
        
        string sobjectfields = '';
        List<SObject> SOb = new List<SObject>();
        for (Schema.SObjectType cobj : childObjMap.values()) {
            String parentLookupField = therelParentFieldMap.get(objectType).get(cobj.getDescribe().getname().Tolowercase());
            String childObjectType = cobj.getDescribe().getname().Tolowercase();
            map<String, Schema.SObjectField> theObjectFieldMap = cobj.getDescribe().fields.getMap();
            sobjectfields = 'Select ' ;
            for (string s : theObjectFieldMap.keyset()) {
                sobjectfields = sobjectfields + s + ', ';
            }
            sobjectfields = sobjectfields.substring(0,sobjectfields.length()-2) 
                            + ' from ' + childObjectType 
                            + ' where ' +  parentLookupField
                            + ' = \'' + theStringId + '\'';
            System.debug('@@@@@@ sobjectfields ' + sobjectfields);
            
            List<sObject> clonedSObjects = new List<sObject>();
            for (sobject sobb: database.query(sobjectfields)) {
                SObject sobb_temp = sobb.clone(false,true);
                sobb_temp.put (parentLookupField, clonedParentObject.Id);
                if (theIgnoredFieldMap.containsKey(childObjectType)) {
                    for (String f : theIgnoredFieldMap.get(childObjectType)) {
                        sobb_temp.put(f,'');
                    }
                }
                clonedSObjects.add(sobb_temp);
            }
            if (clonedSObjects.size()>0)
                insert(clonedSObjects);
        }
        
        return clonedParentObject;
    }
}