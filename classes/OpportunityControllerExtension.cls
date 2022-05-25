/**
 *  Desription      :   Standard Controller for Opportunity Detail Page.
 * 
 *  Created By      :   Abhinav Sharma
 * 
 *  Created Date    :   05/19/2016
 * 
 *  Revision Logs   :   V1.0 - Created - 05/19/2016 - CR-20160308-9682
 *						V1.1 - Modified - By Saurabh kumar 09/13/2017 - CR-20170908-11190
			V1.2 - Rajeev Jain - Just to change the lat modified Date
 *
 **/ 
public with sharing class OpportunityControllerExtension {
    
    //Opportunity record
    public Opportunity opportunity {get; set;}
    public integer displayCount { get; set; }
    
    //Standard Controller Constructor
    public OpportunityControllerExtension(ApexPages.StandardController stdController) {
    	opportunity = (Opportunity)stdController.getRecord();
        //default the displayCount
        displayCount = 5;
    }
    
    /**
     *  @description    :   adds 5 to the number of visible opportunity products
     *
     *  @args           :    
     *
     *  @return         :   
     *
     **/
    public void showMore() {
        displayCount = displayCount + 5;
        listOppProducts = null;
    }
    
    /**
     *  @description    :   Returns total number of related Product records
     *
     *  @args           :    
     *
     *  @return         :   integer
     *
     **/
    public integer totalProductCount {
        get {
            if (totalProductCount == null) {
                totalProductCount = [SELECT COUNT() FROM OpportunityLineItem WHERE OpportunityId = :Opportunity.Id];
            }
            return totalProductCount;
        }
        set;
    }
    
    /**
     *  @description    :   Returns a sorted list of Opportunity Products
     *
     *  @args           :    
     *
     *  @return         :   list<OpportunityLineItem>
     *
     **/
    public list<OpportunityLineItem> listOppProducts {
        get {
            if (listOppProducts == null) {
                string qry = 'SELECT ' 
                    + fieldSetQryString('OpportunityLineItem', 'OppProductRelatedList') 
                    + ' FROM OpportunityLineItem WHERE OpportunityId = \'' + Opportunity.Id + '\' ORDER BY Sort__c ASC LIMIT ' + displayCount;
                system.debug('@@@@:' + qry);
                listOppProducts = database.query(qry);
            }
            return listOppProducts;
        }
        set;
    }
    
    /**
     *  @description    :   Returns a comma delimited list of a Field Set's Field API Names
     *
     *  @args           :    
     *
     *  @return         :   string
     *
     **/
    public static string fieldSetQryString(string objectAPIName, string fieldSetName) {
        DisplayFieldsOnStandardPageLayoutCon d = new DisplayFieldsOnStandardPageLayoutCon();
        d.objectNameStr = objectAPIName;
        d.fieldSetNameStr = fieldSetName;
        List<Schema.FieldSetMember> fields = d.fieldSetFieldsList;
        list<string> listFieldAPINames = new list<string>();
        for (Schema.FieldSetMember f : fields) {
            listFieldAPINames.add(f.getFieldPath());
        }
        return string.join(listFieldAPINames, ',');
    }
    
    //Added By Abhinav Sharma - 05/19/2016 - CR-20160308-9682
    /**
     *  @description    :   This future method will behave as "Onview trigger" for Opportunity Contact Role object.
     * 						Will keep "Main Contact" in sync with respect to the changes happened at OCR side.
     *
     *  @args           :    
     *
     *  @return         :   void
     *
    **/
    public void rollupOpportunityContactRoles() {
        OpportunityControllerExtension.rollupOpportunityContactsRolesFuture(opportunity.Id); 
    }
    
    //Future method to roll up values on opportunity record from the associated "Opportunity Contact Role" records
    @future(callout=false)
    public static void rollupOpportunityContactsRolesFuture(Id oppId)  {
        
        //Checking for the null value
        if(oppId != null) {
            
            //Opportunity instance
            //Modified by Saurabh Kumar - 09/13/2017 - added  more fields in query
            List<Opportunity> opportunities = [Select ID, Main_Contact__c, AccountId, RecordType.DeveloperName FROM Opportunity 
                                               	WHERE Id =: oppId];
            
            List<SBQQ__Subscription__c> subscriptionsToUpdate = new List<SBQQ__Subscription__c>();
            
            //Checking for null and size value
            if(opportunities != null && opportunities.size() > 0) {
                
                //Opportunity instance
                Opportunity opp = opportunities[0];

                //Allocate Memory to list
        		List<OpportunityContactRole> oppContactRole = new List<OpportunityContactRole>();
         
                //Fatching records from Opportunity Contact Role
                //Modified by Saurabh Kumar - 09/13/2017 - added  more fields in query
                oppContactRole = [Select Id, ContactId, Contact.Contact_Status__c, Contact.AccountId, Contact.Name From OpportunityContactRole 
                                    WHERE OpportunityId != null
                                    AND OpportunityId =: opp.Id
                                    AND IsPrimary = true ];
            	
                //Checking for size
                if(oppContactRole.size() > 0) {
                    
                    //Checking for field value difference
                    //Modified By Saurabh kumar - 09/13/2017 - Added condition to bypass VR_Restrict_Main_Contact for the 4 new CPQ record types
                    if(oppContactRole[0].ContactId != opp.Main_Contact__c 
                       &&
                       	(!CPQConstants.SET_OPPORTUNITY_RECORDTYPE_DEVELOPERNAMES.contains(opp.RecordType.DeveloperName)
                        ||
                        CPQConstants.SET_OPPORTUNITY_RECORDTYPE_DEVELOPERNAMES.contains(opp.RecordType.DeveloperName)
                       	&& oppContactRole[0].Contact.Contact_Status__c == 'Active' 
                    	&& oppContactRole[0].Contact.AccountId == opp.AccountId)) 
                    {
                        opp.Main_Contact__c = oppContactRole[0].ContactId;
                        
                        //Loop through Subscription records
                        for(SBQQ__Subscription__c ss : [SELECT ID, Renewal_Opportunity_Main_Contact__c
                                                        FROM SBQQ__Subscription__c
                                                        WHERE Renewal_Opportunity__c != null
                                                        AND Renewal_Opportunity__c = :oppId]) 
                        {
                            
                            ss.Renewal_Opportunity_Main_Contact__c = oppContactRole[0].Contact.Name;
                            subscriptionsToUpdate.add(ss);
                        }
                        
                        Util.BypassAllTriggers = true;
                        update opp;
                        if (subscriptionsToUpdate.size() > 0) update subscriptionsToUpdate;
                        Util.BypassAllTriggers = false;
                	} 
                     
            	} else {
                    
                    if(opp.Main_Contact__c != null) {
                        opp.Main_Contact__c = null;
                        Util.BypassAllTriggers = true;
                        update opp;
                        if (subscriptionsToUpdate.size() > 0) update subscriptionsToUpdate;
                        Util.BypassAllTriggers = false;
                    }
                }
            }
            
        }
    }
}