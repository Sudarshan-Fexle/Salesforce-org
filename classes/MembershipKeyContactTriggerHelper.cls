/*
    Purpose         :   This class is helper class for trigger on Membership Key Contact object.
                
    Create By       :   Simplyforce Technology
    
    Created Date    :   12/15/2012
    
    Current Version :   v1.0
    
    Revision Log    :   V_1.0 Created
                        V_1.1 - Modified By - Mahendra Swarnkar - 1/21/2017 - CR-20160907-10171
                        V_1.2 - Modified By - Subhash Garhawal - 10/08/2018 - CR-20180720-12456
                        V_1.3 - Modified By - Dipesh Gupta - 11/11/2019 - CR-20190419-13012 - Added new method 'validateMembershipKeyContact'
            		V_1.4 - Modified By - Neha Sharma - 11/11/2019 - CR-20201020-14622
            		V_1.5 - Modified By - Subhash Garhwal - 03/30/2021 - CR-20210330-15043 - Modified "validateMembershipKeyContact" method to fix the duplicate membership issue.
			V_1.6 - Modified By - Subhash Garhwal - 04/27/2021 - CR-20210422-15095 - Modified "validateMembershipKeyContact" method
			V-1.7 - Added By - Neha Sharma - 4/28/2022 - CR-20210520-15169 - checkForSingleMembershipKeyContactRelatedToMembership() method to test for single Membership record for Primary as true and Key Status as Active
*/
public without sharing class MembershipKeyContactTriggerHelper {
  
    //Added By - Mahendra Swarnkar - 1/21/2017 - CR-20160907-10171
    /**
    *  @decription  :   Method to have logic whenever Pubs__c/Meetings__c/Contact's reference/Key Contact Status got updated on a MKC record
    *                   then check for the related Contact's status and Then set the Pubs and Meetings field values to false,
    *                   if contact's status is not active. Update Key Contact Status to 'Inactive'.
    *
    *  @args        :   List<Membership_Key_Contact__c>, Map<Id, Membership_Key_Contact__c>
    *
    *  @return      :   void
    *
    **/
    public static void updatePubMeetingStatusValue(List<Membership_Key_Contact__c> membershipKeyContacts, Map<Id, Membership_Key_Contact__c> mapOfOldmembershipKeyContacts) {
        
        //Set to hold ContactIDs
        Set<Id> setOfParentContactsIds = new Set<Id>();
        
        //Loop over MKC records 
        for(Membership_Key_Contact__c mkc : membershipKeyContacts) {
            
            //Check for Insert case and Contact not null 
            if(mapOfOldmembershipKeyContacts == null 
               && mkc.Contact__c != null) {
                   
                   //Populate collection with parent contact record ID
                   setOfParentContactsIds.add(mkc.Contact__c);
               }
            
            //Check for update case
            //Check for Contact/ reference/Key Contact Status got updated on MKC records
            if(mapOfOldmembershipKeyContacts != null 
               && 
               (
                   mkc.Contact__c != mapOfOldmembershipKeyContacts.get(mkc.Id).Contact__c
                   ||
                   mkc.Pubs__c != mapOfOldmembershipKeyContacts.get(mkc.Id).Pubs__c
                   ||
                   mkc.Key_Contact_Status__c != mapOfOldmembershipKeyContacts.get(mkc.Id).Key_Contact_Status__c
                   ||
                   mkc.Meetings__c != mapOfOldmembershipKeyContacts.get(mkc.Id).Meetings__c 
               )
              ){
                  
                  //Checking current parent reference for null value
                  if(mkc.Contact__c != null)
                      setOfParentContactsIds.add(mkc.Contact__c);
                  
                  //Checking old parent reference for null value
                  if(mapOfOldmembershipKeyContacts.get(mkc.ID).Contact__c != null)
                      setOfParentContactsIds.add(mapOfOldmembershipKeyContacts.get(mkc.ID).Contact__c);
              }
        }
        
        //Memory allocation to the map of parent contacts
        Map<Id, Contact> mapOfParentContats = new Map<Id, Contact>();
        
        //Checking set for it's size
        if(setOfParentContactsIds.size() > 0) {
            
            //Map of parent contacts
            mapOfParentContats = new Map<Id, Contact>([SELECT ID, Contact_Status__c 
                                                       FROM Contact
                                                       WHERE ID IN : setOfParentContactsIds
                                                       AND Contact_Status__c != null
                                                       AND Contact_Status__c != ''
                                                       AND Contact_Status__c != 'Active']);
        }  
        
        //Loop over MKC records 
        for(Membership_Key_Contact__c mkcRec : membershipKeyContacts) {
            
            //Checking for the key presence in the map of contacts
            if(mkcRec.Contact__c != null
               && mapOfParentContats.containsKey(mkcRec.Contact__c)
               && mapOfParentContats.get(mkcRec.Contact__c) != null
              ) {
                  
                  //Update the check box value as false as business requirments
                  mkcRec.Pubs__c = false;  
                  mkcRec.Meetings__c = false;  
                  mkcRec.Key_Contact_Status__c = 'Inactive';
                  
              }
        }
    }

    
    //This method is to fetch all the membership records from Membership Key Contacts and Populate the Contact Pubs and Contacts Meetings
    public static void populateContactData(List<Membership_Key_Contact__c> membershipKeyContacts) {
        
        //Create a Set of Membership Ids
        Set<Id> membershipIds = new Set<Id>();
        
        //Loop through the MKC
        for(Membership_Key_Contact__c mKC : membershipKeyContacts) {
            
            //Check for the Membership record id
            if(mKC.Membership__c != null) {
                
                //Add id in set
                membershipIds.add(mKC.Membership__c);
            }
        }
        
        //Fetch all the memebership records and push into the MembershipTriggerHelper.populateContactData(newMemberShips) method
        List<Membership__c> memberships = [Select Id, Membership_Status__c from Membership__c where Id IN: membershipIds];
        
        //Update Contacts
        MembershipTriggerHelper.populateContactData(memberShips, null);
    }
    
    
    //Added By - Dipesh Gupta - 11/11/2019 - CR-20190419-13012
    //Modify By - Neha Sharma - 11/11/2019 - CR-20201020-14622
    /**
    *	@decription  	:   Method to have logic to validate Membership key contact, One membership can not have multiple contacts as MPOC
    *
    *  	@args        	:   List<Membership_Key_Contact__c>, Map<Id, Membership_Key_Contact__c>
    *
    *  	@return      	:   void
    *
    *  	@revision Log	:   V1.2 - Subhash Garhwal - 03/20/2021 - CR-20210330-15043 
    * 			    V1.3 - Subhash Garhwal - 04/27/2021 - CR-20210422-15095 
    * 				V1.4 - Commented By - Neha Sharma - 4/28/2022 - CR-20210520-15169
    *
    **/
    /*
    public static void validateMembershipKeyContact(List<Membership_Key_Contact__c> membershipKeyContacts, Map<Id, Membership_Key_Contact__c> mapOldMembershipKeyContacts) {
        
        //Set of membership ids to validate 
        Set<Id> setOfMembershipIds = new Set<Id>();
        
        //Loop over new or updated membership key content
        for (Membership_Key_Contact__c memKeyCon : membershipKeyContacts){
            
            //Role Check 
            if(memKeyCon.Role__c == 'MPOC' && (mapOldMembershipKeyContacts == null || memKeyCon.Key_Contact_Status__c != mapOldMembershipKeyContacts.get(memKeyCon.Id).Key_Contact_Status__c
                                              || memKeyCon.Membership__c != mapOldMembershipKeyContacts.get(memKeyCon.Id).Membership__c
                                              || memKeyCon.Role__c != mapOldMembershipKeyContacts.get(memKeyCon.Id).Role__c)){
                
                //Adding membership ids into set
                setOfMembershipIds.add(memKeyCon.Membership__c);
            } 
        } 
        
        //Size check 
        if(setOfMembershipIds.Size() > 0){
            
            //Membership to be updated 
            Map<Id, Membership__c> mapMemToBeUpdated = new Map<Id, Membership__c>();
            
            //Map of membership ids and list of membership key contact 
            Map<Id, List<Membership_Key_Contact__c>> mapOfMemIdsWithMemKeyCon = new Map<Id, List<Membership_Key_Contact__c>>();
            
            //03/17/2021 - CR-20210317-15003 - Victor Hanson - added "AND Key_Contact_Status__c = 'Active'" to where clause
            //Loop to get all Membership Key Contact
            for(Membership_Key_Contact__c memKeyCon : [SELECT Id , Membership__c , Role__c, contact__c FROM Membership_Key_Contact__c WHERE Membership__c IN : setOfMembershipIds AND Role__c = 'MPOC' AND Key_Contact_Status__c = 'Active']){
                
                //Contains check 
                if(!mapOfMemIdsWithMemKeyCon.containsKey(memKeyCon.Membership__c))
                    mapOfMemIdsWithMemKeyCon.put(memKeyCon.Membership__c, new List<Membership_Key_Contact__c>());
                
                //Putting values into map 
                mapOfMemIdsWithMemKeyCon.get(memKeyCon.Membership__c).add(memKeyCon);
    
            }
            
            	//Getting list of Membership Key contact with there respected Membership 
                for (Membership_Key_Contact__c memKeyCon : membershipKeyContacts){
                    if(mapOfMemIdsWithMemKeyCon.containsKey(memKeyCon.membership__c) && mapOfMemIdsWithMemKeyCon.get(memKeyCon.membership__c).size() > 1){

                            //Adding Error message
                            memKeyCon.addError(system.Label.NO_MULTIPLE_CONTACT_AS_MPOC);
                    }
                    else{
                        //List of membership to be uodated with new Active Membership Main Contact
                        if(!mapMemToBeUpdated.containsKey(memKeyCon.Membership__c))
                        	mapMemToBeUpdated.put(memKeyCon.Membership__c, new Membership__c(Id = memKeyCon.Membership__c, Active_Contract_Main_Contact__c = memKeyCon.Contact__c,Active_Membership_Main_Con_Updated_Date__c = date.today()));
                    }
                }
        
        
         //Checking list for size value
            if(mapMemToBeUpdated.Size() > 0){
                
                //Disable membership triggers
                Util.byPassAllTriggers = true;
                update mapMemToBeUpdated.values();
                Util.byPassAllTriggers = false;
            }
        }
    } */

    /**
    *	@decription  	:   Method to test for single Membership record for Primary as true and Key Status as Active
    *
    *  	@args        	:   List<Membership_Key_Contact__c>, Map<Id, Membership_Key_Contact__c>
    *
    *  	@return      	:   void
    *
    *  	@revision Log	:   V1.0 - Added By - Neha Sharma - 4/28/2022 - CR-20210520-15169
    *
    **/
    public static void checkForSingleMembershipKeyContactRelatedToMembership(List<Membership_Key_Contact__c> membershipKeyContacts, Map<Id, Membership_Key_Contact__c> mapOldMembershipKeyContacts){

        Set<Id> setOfMembershipId = new Set<Id>();

        for(Membership_Key_Contact__c memKeyCon : membershipKeyContacts){
            if(memKeyCon.Primary__c == true && memKeyCon.Key_Contact_Status__c == 'Active' 
            && (mapOldMembershipKeyContacts == null || (mapOldMembershipKeyContacts != null 
                        && memKeyCon.Primary__c != mapOldMembershipKeyContacts.get(memKeyCon.Id).Primary__c 
                        || memKeyCon.Key_Contact_Status__c != mapOldMembershipKeyContacts.get(memKeyCon.Id).Key_Contact_Status__c)) ){
                            setOfMembershipId.add(memKeyCon.Membership__c);
                        }
        }

        if(setOfMembershipId.size() > 0){
            List<Membership_Key_Contact__c> memKeyConList = [SELECT Id,Primary__c, Key_Contact_Status__c, Membership__c FROM Membership_Key_Contact__c 
                                                            WHERE Primary__c = true AND Key_Contact_Status__c = 'Active'
                                                            AND  Membership__c IN : setOfMembershipId];
        
            if(memKeyConList.size() > 0){
                for(Membership_Key_Contact__c memKeyCon : membershipKeyContacts){
                    memKeyCon.addError('Membership can not have more than one primary Membership Key Contact');
                }
            }
            else{
                if(membershipKeyContacts.size() > 1){
                    membershipKeyContacts[0].addError('Membership can not have more than one primary Membership Key Contact');
                }
            }
        }
    }
}