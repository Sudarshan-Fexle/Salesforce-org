/**
 *  Description     :  Helper class for the ContactComp aura component
 *
 *	Revision Logs   :  V_1.0 - 09/20/2019 - Victor Hanson - Created
 *					   V_1.1 - 11/20/2019 - Victor Hanson - Modified - CR-20191111-13506 - limit product leads based on Stage and added main Opp Contact
**/
public without sharing class ContactCompExtension {
    
    //constructor
    public ContactCompExtension(ApexPages.StandardController stdController) {
        
    }
    
    /**
     *  Description     :  get contact summary data for the given institution
     *
     *	Revision Logs   :  09/20/2019 - Victor Hanson - Created
    **/
    @AuraEnabled
    public static List<contactWrapper> getData(List<Id> accountIds){
        
        //VH 10/01/2019 - disable caching for now.  This might be something we do in the future, assuming we can give users ability to refresh easily if they dont want cached data
        //get the reportChartWrapper
        /*if (accountIds != null && accountIds.size() == 1 && Cache.Org.contains('contactDataMap' + accountIds[0])) {
            myFunnelChartVars = (List<FunnelChartVar>) Cache.Org.get('contactDataMap' + accountIds[0]);
        }
        else {*/
        
        List<contactWrapper> wrapper = new List<contactWrapper>();
        
        //get contact summary details
        wrapper.add(new contactWrapper('# Active Contacts', (Integer) [SELECT COUNT(ID) FROM Contact WHERE Contact_Status__c = 'Active' AND AccountId IN :accountIds][0].get('expr0')));
        wrapper.add(new contactWrapper('# EAB.com Logins in the last 30 days', (Integer) [SELECT COUNT(ID) FROM Web_Service_Log__c 
                                                    WHERE Site_Profile__r.Contact__r.AccountId IN :accountIds AND Web_Service_Method__c = 'Login' AND CreatedDate >= LAST_N_DAYS:30][0].get('expr0')));
        wrapper.add(new contactWrapper('# Open Product Leads', (Integer) [SELECT COUNT(ID) FROM Product_Lead__c WHERE Stage__c IN ('AQL', 'TGL', 'TAL', 'EAL', 'SGL', 'MQL', 'SAL', 'SQL') AND Contact__r.AccountId IN :accountIds][0].get('expr0')));
        wrapper.add(new contactWrapper('# Active EAB.com Site Profiles', (Integer) [SELECT COUNT(ID) FROM Site_Profile__c WHERE Status__c = 'Active' AND Contact__r.AccountId IN :accountIds][0].get('expr0')));
            
        /*    Cache.Org.put('contactDataMap' + accountIds[0], dataMap, 86400);
        }*/
        return wrapper;
    }
    
    /**
     *  Description     :  get contact and institution role data for the given institution
     *
     *	Revision Logs   :  09/20/2019 - Victor Hanson - Created
	 *					:  11/20/2019 - Victor Hanson - Modified - CR-20191111-13506 - limit product leads based on Stage
    **/
    @AuraEnabled
    public static List<Contact> getContactList(List<Id> accountIds){
        
        List<Contact> contacts = [SELECT Id, Name, Title, EAB_com_Site_Profile__c, EAB_com_Site_Profile__r.Last_Access__c, Phone,
                                  (SELECT Id, Assignment_Role__r.Name FROM Institution_Roles__r),
                                  (SELECT Id FROM Product_Lead_Stages__r WHERE Stage__c IN ('AQL', 'TGL', 'TAL', 'EAL', 'SGL', 'MQL', 'SAL', 'SQL')),
                                  (SELECT Id FROM Opportunities__r WHERE IsClosed = false AND RecordTypeId != :CPQConstants.OPP_RT_ID_MERGED)
                                  FROM Contact
                                  WHERE AccountId IN :accountIds 
                                  AND Id IN (SELECT Contact__c FROM Institution_Roles__c)];
        List<ContactSortWrapper> conWrappers = new List<ContactSortWrapper>();
        List<Contact> sortedContacts = new List<Contact>();
        for (Contact c : contacts) {
            conWrappers.add(new ContactSortWrapper(c));
        }
        conWrappers.sort();
        
        for (ContactSortWrapper conSortWrapper : conWrappers) {
            sortedContacts.add(conSortWrapper.con);
        }
        
        return sortedContacts;
    }
    
    /**
     *  Description     :  wrapper class for membership
     *
     *	Revision Logs   :  09/20/2019 - Victor Hanson - Created
    **/
    public class contactWrapper {
        public contactWrapper(String fld, Integer val) {
            this.fieldName = fld;
            this.fieldValue = val;
        }
        @AuraEnabled public String fieldName { get; set; }
        @AuraEnabled public Integer fieldValue { get; set; }
    }
    
    /**
     *  Description     :  wrapper class for contact
     *
     *	Revision Logs   :  11/20/2019 - Victor Hanson - Created
    **/
    public class ContactSortWrapper implements Comparable {
        
        public Contact con;
        
        // Constructor
        public ContactSortWrapper(Contact con) {
            this.con = con;
        }
        
        // Compare opportunities based on the opportunity amount.
        public Integer compareTo(Object compareTo) {
            // Cast argument to OpportunityWrapper
            ContactSortWrapper compareToCon = (ContactSortWrapper)compareTo;
            
            // The return value of 0 indicates that both elements are equal.
            Integer returnValue = 0;
            if (con.Institution_Roles__r[0].Assignment_Role__r.Name > compareToCon.con.Institution_Roles__r[0].Assignment_Role__r.Name) {
                // Set return value to a positive value.
                returnValue = 1;
            } else if (con.Institution_Roles__r[0].Assignment_Role__r.Name < compareToCon.con.Institution_Roles__r[0].Assignment_Role__r.Name) {
                // Set return value to a negative value.
                returnValue = -1;
            }
            
            return returnValue;       
        }
    }
}