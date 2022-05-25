/**
*    Purpose:    Controller class for Clone_LineItemSchedule
*           
*    Create By:  Simplyforce - Bhavi - 11/01/2011 - CR-20111021-173
*   
*    Revision Log:       v1.0 - (Bhavi-11/01/2011) Created code.
*                        v1.1 - (JSun-12/13/2013) CR-20130816-3454.
*   
**/
public with sharing class Clone_LineItemSchedule {
    
    //variable to hold the line item schedule information
    Line_Item_Schedule__c lineItemSchedule;
    public Line_Item_Schedule__c cloneLineItemSchedule{get; set;}
    
    //Constructor
    public Clone_LineItemSchedule(ApexPages.StandardController controller) {
        
        //clone the record
        lineItemSchedule = (Line_Item_Schedule__c)controller.getRecord();
        cloneLineItemSchedule = lineItemSchedule.clone(false);
    }
    
    //override  the save method
    public PageReference save() {
        try {
            // CR-20130816-3454: Invoiced should be set to false and Record type should be updated to reflect the Line Item Schedule RT.
            cloneLineItemSchedule.RecordTypeId = Util.RecordTypeId('Line_Item_Schedule__c', 'Line Item Schedule');
            cloneLineItemSchedule.Invoiced__c = false;
            
            //insert the clone record
            insert cloneLineItemSchedule;
            
            return new PageReference('/' + cloneLineItemSchedule.Id);
        } catch(Exception e) {
            //add error on page
            ApexPages.addMessages(e);
        } 
        
        return null;
    }
}