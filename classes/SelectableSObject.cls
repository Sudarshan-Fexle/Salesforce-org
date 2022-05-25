/**
    Purpose:    		This class allows a list of sObjects to be selectable on a VF page.
                
    Create By:  		Victor Hanson
    
    Created Date:   	07/02/2014
    
    Current Version:    v1.0
    
    Revision Log:       
 **/
public with sharing class SelectableSObject 
{
    private SObject record;
    public Boolean selected {get; set;}
    
    // Universal constructor for any SalesForce object type
    public SelectableSObject(SObject obj) {
        record = obj;
        selected = false;
    }
    
    // Universal constructor for any SalesForce object type
    public SelectableSObject(SObject obj, boolean selected) {
        record = obj;
        this.selected = selected;
    }
    
    // Getter for Publication
    public Publication__c getPublication() {
        return (Publication__c)record;
    }
    
}