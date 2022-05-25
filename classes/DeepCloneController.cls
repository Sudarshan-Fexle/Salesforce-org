/**
 *  Purpose         :   Used to clone a parent object and selected child objects.
 *
 *  Created By      :   Victor Hanson
 *
 *  Created Date    :   07/11/2014
 *
 *  Current Version :   V_1.0 - Created
 *			V_1.1 - Modified By - Colin McGloin - CR-20200715-14317 - 09/22/2020
 *			V_1.2 - Modified By - Mahendra Swarnkar - 12/21/2020 - CR-20201109-14678 - skip validation on installment for reversal
 *
 **/
public class DeepCloneController{
    
    public List<relatedObjects> objectChildren      { get; set; }
    public String               objectTypeName      { get; set; }
    public String               objectName          { get; set; }
    public boolean              reversalScenario    { get; set; }
    
    private SObject headSObject, headClone;
    
    /** Initialisation method called when the clone plus page is loaded.
* 	Use the id page parameter to find out what kind of 
* 	object we are trying to clone.
* 	Then load the object from the database.
* 	Finally call the populateObjectChildren method to  
**/    
    public void initialiseObjectsForCloning()
    {
        
        // Here we generate a keyprefixmap using the global describe 
        // Then compare that to our object to determine type.  
        Map<String, Schema.SObjectType> gd = 
            Schema.getGlobalDescribe(); 
        
        Map<String,String> keyPrefixMap = 
            new Map<String,String>();
        
        for(String sObj : gd.keySet()){
            Schema.DescribeSObjectResult r =  gd.get(sObj).getDescribe();
            keyPrefixMap.put(r.getKeyPrefix(), r.getName());
        }
        
        String objectID = 
            ApexPages.currentPage().getParameters().get('id');
        
        String objectTypeKey = 
            objectId.subString(0,3);
        
        //Added by Colin McGloin - Invoice Billing Scenario
        reversalScenario = false;
        if (ApexPages.currentPage().getParameters().get('reversal') != null){
            reversalScenario = true;
        }
        
        objectTypeName = 
            keyPrefixMap.get(objectTypeKey);
        
        String primaryObjectQueryString = 'SELECT Id, Name FROM '
            + objectTypeName
            + ' WHERE Id = \''
            + objectId
            + '\'';
        
        headSObject = Database.query(primaryObjectQueryString);
        objectName          = '' + headSObject.get('Name');
        populateObjectChildren();    
    }
    
    /** Get all of the children of the current object that have a 
* 	object type contained in the child object types page parameter.
* 	Not restricting the child objects to particular types 
* 	results in unclonable system objects being added to the options, 
* 	which we need to avoid (You will not want to clone these!)
* 	Making these object type choices also allows us 
* 	focus our efforts on the specific kinds of objects 
* 	we want to allow users to clone. 
**/  
    public void populateObjectChildren()
    {
        
        objectChildren = new List<relatedObjects>();
        
        Set<String> childObjectTypes = new Set<String>();
        
        // read the object types from the page parameter.    
        childObjectTypes.addAll(
            ApexPages.currentPage().getParameters()
            .get('childobjecttypes')
            .split(',')
        );
        
        // Use the sobjecttype describe method to retrieve all 
        // child relationships for the object to be cloned.    
        Schema.DescribeSObjectResult headDescribe = 
            headsObject.getSObjectType().getDescribe();
        
        List<Schema.ChildRelationship> childRelationships = 
            headDescribe.getChildRelationships(); 
        
        // Iterate through each relationship, 
        // and retrieve the related objects.       
        for (Schema.ChildRelationship childRelationship : 
             childRelationships)
        {
            Schema.SObjectType childObjectType = 
                childRelationship.getChildSObject();
            
            // Only retrieve the objects if their type is 
            // included in the page argument.          
            if (childObjectTypes.contains(
                childObjectType.getDescribe().getName()))
            {
                List<relatedObjectRow> relatedObjects = 
                    new List<relatedObjectRow>();
                
                Schema.SObjectField childObjectField = 
                    childRelationship.getField();
                
                String relatedChildSObjectsquery = 
                    'SELECT ID FROM ' 
                    + childObjectType.getDescribe().getName()
                    + ' WHERE '
                    + childObjectField.getDescribe().getName()
                    + ' = \'' 
                    + headsObject.Id
                    + '\''; 
                
                for (SObject childObject : 
                     Database.query(relatedChildSObjectsquery))
                {
                    relatedObjects.add(new relatedObjectRow(childObject));
                }
                
                if (!relatedObjects.isEmpty())
                {
                    objectChildren.add(new relatedObjects(relatedObjects, 
                                                          childObjectType.getDescribe().getLabelPlural(), 
                                                          childObjectField.getDescribe().getName()));
                }  
            }
        }
    }
    
    // Perform the cloning process.
    // First clone the parent, then all of the child objects. 
    // Then redirect the user to the new object page.
    public PageReference doClone()
    {
        headClone = cloneObjects(new List<sObject>{headSObject}).get(0);
        headClone.put('Name', headClone.get('Name') + ' (clone)');

        //Billing Scenario
        if (reversalScenario){
            headClone.put('Reversal__c', true);

            //Blank String
            String blankValue = '';

            //Clear out certain fields if needed
            if (String.valueOf(headClone.get('Sales_Invoice__c')) != null){
                headClone.put('Sales_Invoice__c', blankValue);
            }

            if (String.valueOf(headClone.get('Actual_Invoice_Sent_Date__c')) != null){
                headClone.put('Actual_Invoice_Sent_Date__c', null);
            }

            if (String.valueOf(headClone.get('Billing_Posted_Date__c')) != null){
                headClone.put('Billing_Posted_Date__c', null);
            }

            if (String.valueOf(headClone.get('Billing_Date_Override__c')) != null){
                headClone.put('Billing_Date_Override__c', null);
            }

            //Set our Billing Scheduled Date to Today
            headClone.put('Billing_Date_Calculated__c', Date.today());

        }

        //Modified By - Mahendra Swarnkar - 12/21/2020 - CR-20201109-14678 - skip validation on installment as per Taylor's chatter
        //skip validation on Installment on reversal
        BillingSchedulePeriodTriggerHelper.validateInstallment = true;
        insert headClone;
        //validation on Installment
        BillingSchedulePeriodTriggerHelper.validateInstallment = false;
        //Mahendra Swarnkar - 12/21/2020 - CR-20201109-14678 - comment ends here
        
        cloneSelectedObjects();
        
        return new PageReference('/' + headClone.Id);

    }
    
    // Clone the selected child objects.
    // Associate the cloned objects with the new cloned parent object.
    public void cloneSelectedObjects()
    {
        
        List<sObject> clonedObjects = new List<sObject>();
        List<sObject> selectedRelatedObjects;
        
        for (relatedObjects relatedObject : objectChildren)
        {
            selectedRelatedObjects = new List<sObject>();  
            clonedObjects = new List<sObject>();  
            
            for (relatedObjectRow row : relatedObject.objectRows) 
            {
                if (row.selected)
                {
                    selectedRelatedObjects.add(row.obj);
                }
            }
            
            if (!selectedRelatedObjects.isEmpty())
            {
                clonedObjects = cloneObjects(selectedRelatedObjects);

                //Added by Colin McGloin - 09/22/2020
                //Billing Scenario
                if (reversalScenario == true && clonedObjects.size() > 0){

                    //Loop through Line records
                    for (sObject billLines : clonedObjects){

                        //Set our Billing Amount to Negative amount equal to Billing Amount
                        //Integer ReversebillAmt = (Integer.valueOf(billLines.get('Billing_Amount__c')) * -1); 
                        Decimal ReversebillAmt = ((Decimal) billLines.get('Billing_Amount__c')) * -1; 
                        billLines.put('Billing_Amount__c', ReversebillAmt);

                    }

                }
                
                for (sObject clone : clonedObjects)
                {
                    clone.put(relatedObject.relatedFieldName, headClone.Id);  
                }
                
                insert clonedObjects;
            }
        }
    }
    
    // Clone a list of objects to a particular object type
    // Parameters 
    // - List<sObject> sObjects - the list of objects to be cloned 
    // The sObjects you pass in must include the ID field, 
    // and the object must exist already in the database, 
    // otherwise the method will not work.
    public static List<sObject> cloneObjects(List<sObject> sObjects){
        
        Schema.SObjectType objectType = sObjects.get(0).getSObjectType();
        
        // A list of IDs representing the objects to clone
        List<Id> sObjectIds = new List<Id>();
        // A list of fields for the sObject being cloned
        List<String> sObjectFields = new List<String>();
        // A list of new cloned sObjects
        List<sObject> clonedSObjects = new List<sObject>();
        
        // Get all the fields from the selected object type using 
        // the get describe method on the object type.    
        if(objectType != null)
        {
            for (Schema.SObjectField objField : 
                 objectType.getDescribe().fields.getMap().values())
            { 
                Schema.DescribeSObjectResult sObjDesc = objectType.getDescribe();
                Schema.DescribeFieldResult fieldDesc = objField.getDescribe();
                // If the field type is location, then do not include it,
                // otherwise it will cause a soql exception.
                // Note that excluding the field does not stop the location from
                // being copied to the new cloned object.
                if(fieldDesc.getType() != DisplayType.LOCATION)
                {
                    
                    // If this is a Campaign Member, don't include the Undeliverable or Status fields because they are unique to the Campaign
                    if (sObjDesc.Name == 'CampaignMember'
                        && (fieldDesc.Name == 'Undeliverable__c' || fieldDesc.Name == 'Status')) 
                    {
                        continue;
                    }
                    
                    sObjectFields.add(fieldDesc.Name);
                }
            }
        }
        
        // If there are no objects sent into the method, 
        // then return an empty list
        if (sObjects != null || 
            sObjects.isEmpty() || 
            sObjectFields.isEmpty()){
                
                // Strip down the objects to just a list of Ids.
                for (sObject objectInstance: sObjects){
                    sObjectIds.add(objectInstance.Id);
                }
                
                /* Using the list of sObject IDs and the object type, 
we can construct a string based SOQL query 
to retrieve the field values of all the objects.
*/
                
                String allSObjectFieldsQuery = 'SELECT ' + sObjectFields.get(0); 
                
                for (Integer i=1 ; i < sObjectFields.size() ; i++){
                    allSObjectFieldsQuery += ', ' + sObjectFields.get(i);
                }
                
                allSObjectFieldsQuery += ' FROM ' + 
                    objectType.getDescribe().getName() + 
                    ' WHERE ID IN (\'' + sObjectIds.get(0) + 
                    '\'';
                
                for (Integer i=1 ; i < sObjectIds.size() ; i++){
                    allSObjectFieldsQuery += ', \'' + sObjectIds.get(i) + '\'';
                }
                
                allSObjectFieldsQuery += ')';
                
                system.debug('allSObjectFieldsQuery: ' + allSObjectFieldsQuery);
                
                try{
                    
                    // Execute the query. For every result returned, 
                    // use the clone method on the generic sObject 
                    // and add to the collection of cloned objects
                    for (SObject sObjectFromDatabase:
                         Database.query(allSObjectFieldsQuery)){
                             clonedSObjects.add(sObjectFromDatabase.clone(false,true));  
                         }
                    
                } catch (exception e){
                }
                
            }
        
        return clonedSObjects;
        
    }
    
    // Related objects data construct - 
    // used to store a collection of child objects connected to 
    // the head object through the same relationship field.
    public class relatedObjects
    {
        public List<relatedObjectRow> objectRows { get; set; }
        public String                 pluralLabel      { get; set; }
        public String                 relatedFieldName { get; set; }
        
        public relatedObjects(List<relatedObjectRow> objectRows, 
                              String pluralLabel, 
                              String relatedFieldName) 
        {
            this.objectRows       = objectRows;
            this.pluralLabel      = pluralLabel;
            this.relatedFieldName = relatedFieldName;
        }   
    }     
    
    // An indidual child object row. 
    // Each instance simply contains the object definition, 
    // and a checkbox to select the row for cloning 
    // on the clone plus page.
    public class relatedObjectRow
    {
        public sObject obj      { get; set; }
        public Boolean selected { get; set; }
        
        public relatedObjectRow(Sobject obj)
        {
            this.obj      = obj;
            // All object rows are selected by default.
            this.selected     = true;
        }
        
        public String getName(){
            try{
                return '' + obj.get('Name');
            } catch (Exception e){
                return '';
            }    
        }   
    }
    
    /**
* 
* 
**/
    public pageReference cloneOnLoad() {
        
        //initialize the objects to be cloned
        initialiseObjectsForCloning();
        //clone immediately and return
        return doClone();
    }
}