/**
 *  Purpose         :  	This trigger is to control the automation on 1EAB Lead object.
 *  Created By      :   Lawrence Lam
 *  Created Date    :   5/24/2021
 *  Revision Logs   :   V_1.0 - Created  - CR-20210511-15135
 *  Test Class 	    :   GuaranteeCreationControllerTest                   
 **/

public without sharing class GuaranteeCreationController {

    //grabs existing guarantees and validation data for component
    @AuraEnabled
    public static GuaranteeWrapper getConfiguration(string recordId){
        GuaranteeWrapper wrapper = new GuaranteeWrapper();
        Venue__c venue;
        
        //select Event and Existing Guarantees
        try{
            venue = [Select id, Advisory_Event__c,Advisory_Event__r.Begins__c,Advisory_Event__r.Ends__c ,(Select id, Name,Type__c, Date__c, EAB_Event__c,Guarantee__c,Venues_and_Vendors__c from Guarantees__r order by Date__c asc) from Venue__c where id =: recordId limit 1];
        }catch (Exception e){
            throw new AuraHandledException('Unable to find Venue record based on record id:' + recordId);
        }
        
        //build wrapper
        if(venue!= null){
            List<Guarantee__c> existingGuarantees = venue.Guarantees__r;
            wrapper = new GuaranteeWrapper(venue, venue.Advisory_Event__r.Begins__c, venue.Advisory_Event__r.Ends__c, existingGuarantees);
        }
        
        return wrapper;
    }
    
    //save records returned from Lightning Component
    @AuraEnabled 
    public static boolean saveGuaranteeRecords( String dynamicRowsList ) {
    	try {
    		List<Guarantee__c> guaranteeRecordsList = (List<Guarantee__c>) JSON.deserialize(dynamicRowsList, List<Guarantee__c>.class);
    		upsert guaranteeRecordsList;
    	} catch(Exception err) {
            throw new AuraHandledException('Error on Save: ' + err.getMessage());
    	}
        return true;
    }
    
    
    public class GuaranteeWrapper{
        @AuraEnabled
        public Date startDate;
        @AuraEnabled
        public Date endDate;
        @AuraEnabled
        public String eabEvent;
        @AuraEnabled
        public String venue;
        @AuraEnabled
        public List<Guarantee__c> existingGuarantees;
        @AuraEnabled
        public List<String> typeValues;
        
        public GuaranteeWrapper(){
            startDate = Date.today();
            endDate = Date.today();
            eabEvent = '';
            venue = '';
            existingGuarantees = new List<Guarantee__c>();
            
            //set list of picklist entries
            typeValues = new List<String>();
            List<Schema.PicklistEntry> typePicklistValues = Schema.getGlobalDescribe().get('Guarantee__c').getDescribe().fields.getMap().get('Type__c').getDescribe().getPickListValues();
            for (Schema.PicklistEntry entry : typePicklistValues) {
                if (entry.isActive()) {
                    typeValues.add(entry.getValue());
                }
            }
        }
        public GuaranteeWrapper(Venue__c venue, DateTime startDatetime, DateTime endDatetime, List<Guarantee__c> existingList){
            startDate = startDateTime.date()-1;
            endDate = endDateTime.date();
            eabEvent = venue.Advisory_Event__c;
            this.venue = venue.id;
            if(existingList != null){
                existingGuarantees = existingList;
            }else{
                existingGuarantees = new List<Guarantee__c>();
            }
            
            //set list of picklist entries
            typeValues = new List<String>();
            List<Schema.PicklistEntry> typePicklistValues = Schema.getGlobalDescribe().get('Guarantee__c').getDescribe().fields.getMap().get('Type__c').getDescribe().getPickListValues();
            for (Schema.PicklistEntry entry : typePicklistValues) {
                if (entry.isActive()) {
                    typeValues.add(entry.getValue());
                }
            }
        }
    }
}