/**
*   Description     :   This is helper class for Inventory object.
*
*   Revision Log    :   V_1.0 - Created  - CR-20210924-15459 - 10/20/2021
*		    :   V_1.1 - Modified By - Shalu Sharma - 22/12/2021 - CR-20211213-15624 - Added new method "sendEmailWhenQtyInInventoryIsLessThanPrintQtyContracted"
*		    :   V_1.2 - Modified By - Shalu Sharma - 19/01/2021 - CR-20220105-15694 - Replace "Account AM off related Membership" field with "Account Manager field.
*                       
*/
public without sharing class InventoryTriggerHelper 
{
    //Constants
    public final static String PT_STATUS_MAILED = 'Mailed';
    public final static String PT_STATUS_CANCELLED = 'Cancelled';
    
    //Added by - CR-20210924-15459 - 10/20/2021
	//Method to update "Insufficient Inventory" field values on related Mail Shop PT records on the basis of "Current Available Inventory" field value
    public static void updateInsufficientInventoryOnRelatedMailShopPTs(List<Inventory__c> newInventories, Map<Id, Inventory__c> oldInventoriesMap) 
    { 
        Map<Id, Boolean> mapOfEligibleInventories = new Map<Id, Boolean>();
        
        Set<String> setOfMailShopPTStatusToSkip = new Set<String>();
        setOfMailShopPTStatusToSkip.add(InventoryTriggerHelper.PT_STATUS_MAILED);
        setOfMailShopPTStatusToSkip.add(InventoryTriggerHelper.PT_STATUS_CANCELLED);
        
        for(Inventory__c inv : newInventories) 
        {
            //execute the logic only and only if "Current Available Inventory" field value got changed on the Inventory record
            if (oldInventoriesMap != null
                &&
                oldInventoriesMap.get(inv.Id).Current_Available_Amount__c != inv.Current_Available_Amount__c
            ) 
            {
                //If the value of Current Available Inventory moves from a figure of positive/0 to a value in minus figures (less than 0)
                if(oldInventoriesMap.get(inv.Id).Current_Available_Amount__c >= 0 && inv.Current_Available_Amount__c < 0) 
                {
                    mapOfEligibleInventories.put(inv.Id, true);
                }
                
                //If the value of Current Available Inventory moves from a figure of negative to a value in plus figures (greater than 0),
                else if(oldInventoriesMap.get(inv.Id).Current_Available_Amount__c < 0 && inv.Current_Available_Amount__c > 0) 
                {
                    mapOfEligibleInventories.put(inv.Id, false);
                }
            }
        }
        if(mapOfEligibleInventories.values().size() > 0) 
        {
            Map<Id, Boolean> mapOfMailShopPTWithInsufficientInventoryValue = new Map<Id, Boolean>();
            
        	//Query all Inventory Transaction records linked to the Inventory record and get the Mailshop Production Tracking records listed in the 
            //field “Mailshop Production Tracking”
			//check to see if the Mailshop Production Tracking record is in a status != ‘Mailed’ or ‘Cancelled’
            for(Inventory_Transaction__c iTx : [SELECT ID, Mailshop_Production_Tracking__c, Inventory__c
                                                FROM Inventory_Transaction__c
                                                WHERE Inventory__c IN : mapOfEligibleInventories.keySet()
                                                	AND Mailshop_Production_Tracking__c != null
                                                	AND Mailshop_Production_Tracking__r.Status__c NOT IN : setOfMailShopPTStatusToSkip
                                               ]) 
            {
            	mapOfMailShopPTWithInsufficientInventoryValue.put(iTx.Mailshop_Production_Tracking__c, mapOfEligibleInventories.get(iTx.Inventory__c));            
            }  
            
            if(mapOfMailShopPTWithInsufficientInventoryValue.values().size() > 0) 
            {
                List<Production_Tracking__c> listOfMailShopPTRecords = new List<Production_Tracking__c>();
                for(Production_Tracking__c pT : [SELECT ID, Insufficient_Inventory__c 
                                                 FROM Production_Tracking__c 
                                                 WHERE ID IN : mapOfMailShopPTWithInsufficientInventoryValue.keySet()]) 
                {
                    pT.Insufficient_Inventory__c = mapOfMailShopPTWithInsufficientInventoryValue.get(pT.Id);
                    listOfMailShopPTRecords.add(pT);
                }
                if(listOfMailShopPTRecords.size() > 0) 
                {
                    Util.byPassAlltriggers = true;
                    update listOfMailShopPTRecords;
                    Util.byPassAlltriggers = false;
                }
            }
        }
    }
    
    //Added By - Shalu Sharma - 22/12/2021 - CR-20211213-15624 - Added new method "sendEmailWhenQtyInInventoryIsLessThanPrintQtyContracted"
    public static void sendEmailWhenQtyInInventoryIsLessThanPrintQtyContracted(List<Inventory__c> newInventories, 
                                                                               Map<Id, Inventory__c> oldInventoriesMap)
    {
        Set<Id> setOfInventoryIds = new Set<Id>();
        for(Inventory__c inv : newInventories) 
        {
            if(inv.Quantity_in_Inventory__c != null && inv.PT_Print_Quantity_Contracted__c != null 
               && inv.Quantity_in_Inventory__c > 0  && inv.PT_Print_Quantity_Contracted__c > 0
               && (oldInventoriesMap == null || (oldInventoriesMap != null && 
                                                 (oldInventoriesMap.get(inv.Id).Quantity_in_Inventory__c != inv.Quantity_in_Inventory__c
                                                  || oldInventoriesMap.get(inv.Id).PT_Print_Quantity_Contracted__c != inv.PT_Print_Quantity_Contracted__c)))
              ) 
            {
                setOfInventoryIds.add(inv.Id);   
            }
        }
        if(setOfInventoryIds.size() > 0)
        {
            for(Inventory__c inv : [SELECT Id, Quantity_In_Inventory__c, Production_Tracking__r.Print_Quantity_Contracted__c, Institution__c,
                                    Production_Tracking__r.Job_Ticket__r.Project_Manager__r.Email, Production_Tracking__r.Job_Ticket__r.Account_Manager__c,
                                    Production_Tracking__r.Job_Ticket__r.School__c, Production_Tracking__r.Job_Ticket__r.Fiscal_Year__c,
                                    Production_Tracking__r.Job_Ticket__r.Program_Type__c
                                    FROM Inventory__c
                                    WHERE Id IN : setOfInventoryIds
                                    AND Production_Tracking__c != null
                                    AND Production_Tracking__r.Job_Ticket__c != null])
            {
                if(inv.Quantity_in_Inventory__c <= inv.Production_Tracking__r.Print_Quantity_Contracted__c*.15)
                {
                    sendEmailToAccountAMAndProjectManager(inv);   
                }
            }
        }
    }
    
    //Added By - Shalu Sharma - 22/12/2021 - CR-20211213-15624 - Added new method
    public static void sendEmailToAccountAMAndProjectManager(Inventory__c inventory)
    {
        if(inventory != null)
        {
            List<User> listOfUser = [SELECT Id, Email FROM User WHERE Name =: inventory.Production_Tracking__r.Job_Ticket__r.Account_Manager__c];
            EmailTemplate emailTemplate = [SELECT Id, Subject, Body, HTMLValue FROM EmailTemplate WHERE DeveloperName = 'ET_Inventory_Less_Than_15_Of_Contracted_Quantity'];
            List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            List<String> toAddress = new List<String>();
            List<String> ccAddress = new List<String>();
            toAddress.add(listOfUser.size() > 0 ? listOfUser[0].Email : inventory.Production_Tracking__r.Job_Ticket__r.Project_Manager__r.Email);
            ccAddress.add(inventory.Production_Tracking__r.Job_Ticket__r.Project_Manager__r.Email);
            mail.setTemplateId(emailTemplate.Id);
            String subject = emailTemplate.Subject;
            subject = subject.replace('{!Job_Ticket__c.School__c}', String.isNotBlank(inventory.Production_Tracking__r.Job_Ticket__r.School__c) ? inventory.Production_Tracking__r.Job_Ticket__r.School__c : '');
            subject = subject.replace('{!Job_Ticket__c.Fiscal_Year__c}', String.isNotBlank(inventory.Production_Tracking__r.Job_Ticket__r.Fiscal_Year__c) ? inventory.Production_Tracking__r.Job_Ticket__r.Fiscal_Year__c : '');
            subject = subject.replace('{!Job_Ticket__c.Program_Type__c}', String.isNotBlank(inventory.Production_Tracking__r.Job_Ticket__r.Program_Type__c) ? inventory.Production_Tracking__r.Job_Ticket__r.Program_Type__c : '');
            mail.setSubject(subject);
            mail.setToAddresses(toAddress);
            mail.setCcAddresses(ccAddress);
            String htmlBody = emailTemplate.HTMLValue;
            htmlBody = htmlBody.replace('{!Job_Ticket__c.Account_Manager__c}', String.isNotBlank(inventory.Production_Tracking__r.Job_Ticket__r.Account_Manager__c) ? inventory.Production_Tracking__r.Job_Ticket__r.Account_Manager__c : '');
            mail.setHTMLBody(htmlBody);
            mail.setSaveAsActivity(false);
            mail.setUseSignature(false); 
            mailList.add(mail);
            if(mailList.size() > 0)
            {
                Messaging.sendEmail(mailList);
            }
        }
    }
}