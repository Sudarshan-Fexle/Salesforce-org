/**
 *  Purpose         :  	This trigger is to make requests to the Travel_Accommodations__c object for the TravelAccommodationsCreation Lightning Component.
 *  Created By      :   Lawrence Lam
 *  Created Date    :   5/24/2021
 *  Revision Logs   :   V_1.0 - Created  - CR-20210511-15134
 *                     
 **/

public without sharing class TravelAccommodationsCreationController {
    
    @AuraEnabled
    public static List<AccommodationWrapper> getAttendees(string recordId){
        List<AccommodationWrapper> wrapperList = new List<AccommodationWrapper>();
        
        Registration__c currentRecord = [Select id, Contact__c,EAB_Event__c from Registration__c where id =: recordId limit 1];
        
        //grab all potential registrants that we can add accommodations for
        for(Registration__c registration : [Select id,Contact__c,Contact__r.Name, Contact__r.Email,EAB_Event__c,Status__c from Registration__c where EAB_Event__c =: currentRecord.EAB_Event__c]){
            AccommodationWrapper temp = new AccommodationWrapper(registration);
            temp.name = registration.Contact__r.Name;
            temp.email = registration.Contact__r.Email;
            temp.status = registration.Status__c;
            temp.eabEvent = registration.EAB_Event__c;
            wrapperList.add(temp);
        }
        
        return wrapperList;
        
    }
    
    @AuraEnabled
    public static List<Travel_Accommodations__c> getExistingAccomodations(String recordId, String recordTypeName){
        List<Travel_Accommodations__c> accommodationList = [Select Id,Accommodation_Order__c,Agency_Record_Number__c,Airline__c,Arrival_Airport__c,Arrival_Date__c,Arrival_Time__c,
                                                            Check_In__c, Check_Out__c, Connection_Seat_Assignment__c, Confirmation_Num__c, ConnectionAirport__c, Connection_Arrival_Date__c,Connection_Arrival_Time__c,
                                                            Connection_Departure_Date__c,Connection_Departure_Time__c,Connection_Flight_Num__c,Contact_Name__c, Departure_Airport__c,Departure_Date__c,
                                                            Departure_Time__c,EAB_Event__c,Fare__c, Flight_Num__c,Hotel_Address1__c, Hotel_Address2__c, Hotel_City__c, Hotel_Country__c, Hotel_Name__c,
                                                            Hotel_State__c, Hotel_Zip__c,RecordTypeId,Registration__c, Seat_Assignment__c, Status__c, Venue__c, Registration__r.Contact__r.Name, Rate__c
                                                            from Travel_Accommodations__c where EAB_Event__c =: recordId and RecordType.Name =: recordTypeName];
        return accommodationList;
    }
    
    @AuraEnabled 
    public static boolean saveAccommodationRecords(String dynamicRowsList, String recordTypeName) {
        String recordtype = Schema.SObjectType.Travel_Accommodations__c.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
        
        try {
            List<Travel_Accommodations__c> accommodationRecordsList = (List<Travel_Accommodations__c>) JSON.deserialize(dynamicRowsList, List<Travel_Accommodations__c>.class);
            
            //set record type specifically for creation
            for(Travel_Accommodations__c accommodations : accommodationRecordsList){
                if(accommodations.Id == null){
                    accommodations.RecordTypeId = recordtype;
                }
            }
            
            //update 
            upsert accommodationRecordsList;
        } catch(Exception err) {
            throw new AuraHandledException('Error on Save: ' + err.getMessage());
        }
        return true;
    }
    
    public class AccommodationWrapper{
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String email;
        @AuraEnabled
        public String status;
        @AuraEnabled
        public String eabEvent;
        @AuraEnabled
        public Registration__c registration;
        
        public AccommodationWrapper(){
            name = '';
            email = '';
            status = '';
            eabEvent = '';
        }
        
        public AccommodationWrapper(Registration__c registration){
            this.registration = registration;
        }
        
    }
}