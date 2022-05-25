/**
 *  Description     :   Helper class for various Financial Force triggers (ie: Transaction, SalesCreditNote, and SalesInvoice)
 * 
 *  Created By      :   Victor Hanson
 * 
 *  Created Date    :   05/13/2013
 * 
 *  Revision Logs   :   V1.0 - Created
 *                      V1.1 - Modified By - Abhinav Sharma - CR-20150308-8736 - 04/02/2015
 *			V1.2 - Modified By - Subhash Garhwal - Q2C Phase 2 - 06/07/2017
 *			V1.3 - Modified By - Colin McGloin - CR-20180329-12135 - 03/29/2018
 *			V1.4 - Modified By - Rajeev Jain after full2 refresh
 *			V1.5 - Modified By - Colin McGloin - CR-20200715-14316 
 *			V1.6 - Modified By - Neha Sharma - CR-20210628-15255
 *                      V1.7 - Modified By - Subhash Garhwal - CR-20211112-15581
**/ 
public with sharing class InvoiceTriggerHelper {
    
    // rollup the Invoice Total and Amount Credited Total
    public static List<Contract__c> RollupInvoiceAmtOnContract(Set<Id> contractIdSet, boolean calcCreditNoteTotal) {
        AggregateResult[] r = [select ContractABC__c, sum(c2g__NetTotal__c) NT
        from c2g__codaInvoice__c where ContractABC__c != null and ContractABC__c in :contractIdSet group by ContractABC__c];
        
        //Modified by Colin McGloin - Changed filter from AmtCredited__c > 0 to AmtCredited__c != NULL so it accounts for Negative Values in calculations moving forward
        AggregateResult[] creditAggr = [select ContractABC__c, sum(c2g__NetTotal__c) crNT, sum( c2g__Transaction__r.Outstanding_Total_Minus_Taxes__c) AC 
        from c2g__codaInvoice__c where ContractABC__c != null and ContractABC__c in :contractIdSet AND AmtCredited__c != NULL group by ContractABC__c];
        
        AggregateResult[] creditNoteAggr = [select ContractABC__c, sum(c2g__NetTotal__c) NT 
            from c2g__codaCreditNote__c where ContractABC__c != null and ContractABC__c in :contractIdSet group by ContractABC__c];
        
        // create a map of Contract_ABC.Id -> Amount_Credited_Total__c
        Map<Id, Decimal> contAbcToAmtCred = new Map<Id, Decimal>();
        Decimal NT, AC, crNT;
        for (Integer i = 0; i < creditAggr.size(); i++) {
            
            //V1.1 - Modified By - Abhinav Sharma - CR-20150308-8736 - 04/02/2015
            //Start From here
            //Id contractAbcId = String.valueOf(r[i].get('ContractABC__c'));
            Id contractAbcId = String.valueOf(creditAggr[i].get('ContractABC__c'));
            //Upto here
            
            AC = 0;
            crNT = 0;
            
            if (creditAggr[i].get('AC') != null) {
                AC = Decimal.valueOf(String.valueOf(creditAggr[i].get('AC')));
            }
            
            if (creditAggr[i].get('crNT') != null) {
                crNT = Decimal.valueOf(String.valueOf(creditAggr[i].get('crNT')));
            }
            
            
            Decimal amtCreditTotal = crNT - AC;
            system.debug('@@crNT:' + crNT);
            system.debug('@@AC:' + AC);
            system.debug('@@contractAbcId:' + contractAbcId + '    amtCreditTotal:' + amtCreditTotal);
            // add the contract abc and amt credited total to the map
            contAbcToAmtCred.put(contractAbcId, amtCreditTotal);
        }
        
        // create a map of Contract_ABC.Id -> CreditNote__c.SUM(c2g__NetTotal__c)
        Map<Id, Decimal> contAbcToCredNoteNetMap = new Map<Id, Decimal>();
        Decimal creditNoteNetTotal;
        for (Integer i = 0; i < creditNoteAggr.size(); i++) {
            creditNoteNetTotal = 0;
            if (creditNoteAggr[i].get('NT') != null) {
                creditNoteNetTotal = Decimal.valueOf(string.valueOf(creditNoteAggr[i].get('NT')));
            }
            Id contractAbcId = String.valueOf(creditNoteAggr[i].get('ContractABC__c'));
            // add credit note net total to map
            contAbcToCredNoteNetMap.put(contractAbcId, creditNoteNetTotal);
        }
        
        List<Contract__c> updContractList = new List<Contract__c>();
        for (Integer i = 0; i < r.size(); i++) {
            NT = 0;
            Id contractABCId = String.valueOf(r[i].get('ContractABC__c'));
    
            if (r[i].get('NT') != null) {
                NT = Decimal.valueOf(String.valueOf(r[i].get('NT')));
            }
            // get the credit note net total
            creditNoteNetTotal = contAbcToCredNoteNetMap.get(contractABCId);
            if (creditNoteNetTotal == null) creditNoteNetTotal = 0;
            
            // get the amount credit total
            Decimal amtCredTotal = contAbcToAmtCred.get(contractABCId);
            system.debug('@@contractABCId:' + contractABCId + '    amtCredTotal:' + amtCredTotal);
            if (amtCredTotal == null) amtCredTotal = 0;
            
            Contract__c updatedContract = new Contract__c( Id = contractABCId );
            
            if (calcCreditNoteTotal) {
                updatedContract.Credit_Note_Total__c = creditNoteNetTotal;
            }
            else {
                updatedContract.Invoice_Total__c = NT;
                updatedContract.Amount_Credited_Total__c = amtCredTotal;
            }
            updContractList.add(updatedContract);
                
        }
        return updContractList;
    }
    
    /**
     *  @description    :   This method is used to rollup the Amount Credited Total from Sales Credit Notes
     *
     *  @args           :   List<c2g__codaCreditNote__c>, Map<Id, c2g__codaCreditNote__c>
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - Created - Subhash Garhwal - Q2C Phase 2
     *
     **/
	public static void rollupAmountCreditedTotal(List<c2g__codaCreditNote__c> salesCreditNotes, Map<Id, c2g__codaCreditNote__c> mapOldSalesCreditNotes) {
		
		//Map to hold the Program Subscription Ids
		Map<Id, SBQQ__Subscription__c> mapProgramSubscriptions = new Map<Id, SBQQ__Subscription__c>();
		
		//Loop over the Sales Created Notes
		for(c2g__codaCreditNote__c sCN : salesCreditNotes != null ? salesCreditNotes : mapOldSalesCreditNotes.values()) {
			
			//Check for insert
			if(mapOldSalesCreditNotes == null && sCN.Program_Subscription__c != null && sCN.c2g__NetTotal__c != null)
				mapProgramSubscriptions.put(sCN.Program_Subscription__c, new SBQQ__Subscription__c(Id = sCN.Program_Subscription__c, Credit_Note_Total__c = 0));
			
			//Update case
			if(salesCreditNotes != null && mapOldSalesCreditNotes != null && (sCN.Program_Subscription__c != mapOldSalesCreditNotes.get(sCN.Id).Program_Subscription__c
				|| sCN.c2g__NetTotal__c != mapOldSalesCreditNotes.get(sCN.Id).c2g__NetTotal__c)) {
					
				//Add new subscription
				if(sCN.Program_Subscription__c != null)
					mapProgramSubscriptions.put(sCN.Program_Subscription__c, new SBQQ__Subscription__c(Id = sCN.Program_Subscription__c, Credit_Note_Total__c = 0));
				
				//Check for old
				if(mapOldSalesCreditNotes.get(sCN.Id).Program_Subscription__c != null)
					mapProgramSubscriptions.put(mapOldSalesCreditNotes.get(sCN.Id).Program_Subscription__c, new SBQQ__Subscription__c(Id = mapOldSalesCreditNotes.get(sCN.Id).Program_Subscription__c, Credit_Note_Total__c = 0));
			}
			
			//Delete case
			if(salesCreditNotes == null && sCN.Program_Subscription__c != null && sCN.c2g__NetTotal__c != null)
				mapProgramSubscriptions.put(sCN.Program_Subscription__c, new SBQQ__Subscription__c(Id = sCN.Program_Subscription__c, Credit_Note_Total__c = 0));
		}
		
		//Check for size
		if(mapProgramSubscriptions.size() > 0)
			rollupInvoiceAmtOnProgramSubscription(mapProgramSubscriptions, true);			
	}
	
	/**
     *  @description    :   This method is used to rollup the Invoice_Total__c from Transaction
     *
     *  @args           :   List<c2g__codaInvoice__c>, Map<Id, c2g__codaInvoice__c>
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - Created - Subhash Garhwal - Q2C Phase 2
     *
     **/
	public static void rollupInvoiceTotal(List<c2g__codaInvoice__c> invoices, Map<Id, c2g__codaInvoice__c> mapOldInvoices) {
		
		//Map to hold the Program Subscription Ids
		Map<Id, SBQQ__Subscription__c> mapProgramSubscriptions = new Map<Id, SBQQ__Subscription__c>();
		
		//Loop over the Sales Created Notes
		for(c2g__codaInvoice__c invoice : invoices != null ? invoices : mapOldInvoices.values()) {
			
			//Check for insert
			if(mapOldInvoices == null && invoice.Program_Subscription__c != null && invoice.c2g__NetTotal__c != null)
				mapProgramSubscriptions.put(invoice.Program_Subscription__c, new SBQQ__Subscription__c(Id = invoice.Program_Subscription__c, Invoice_Total__c = 0, Amount_Credited_Total__c = 0));
			
			//Update case
			if(invoices != null && mapOldInvoices != null && (invoice.Program_Subscription__c != mapOldInvoices.get(invoice.Id).Program_Subscription__c
				|| invoice.c2g__NetTotal__c != mapOldInvoices.get(invoice.Id).c2g__NetTotal__c
				|| invoice.c2g__Transaction__c != mapOldInvoices.get(invoice.Id).c2g__Transaction__c)) {
					
				//Add new subscription
				if(invoice.Program_Subscription__c != null)
					mapProgramSubscriptions.put(invoice.Program_Subscription__c, new SBQQ__Subscription__c(Id = invoice.Program_Subscription__c, Invoice_Total__c = 0, Amount_Credited_Total__c = 0));
				
				//Check for old
				if(mapOldInvoices.get(invoice.Id).Program_Subscription__c != null)
					mapProgramSubscriptions.put(mapOldInvoices.get(invoice.Id).Program_Subscription__c, new SBQQ__Subscription__c(Id = mapOldInvoices.get(invoice.Id).Program_Subscription__c, Invoice_Total__c = 0, Amount_Credited_Total__c = 0));
			}
			
			//Delete case
			if(invoices == null && invoice.Program_Subscription__c != null && invoice.c2g__NetTotal__c != null)
				mapProgramSubscriptions.put(invoice.Program_Subscription__c, new SBQQ__Subscription__c(Id = invoice.Program_Subscription__c, Invoice_Total__c = 0, Amount_Credited_Total__c = 0));
		}
		
		//Check for size
		if(mapProgramSubscriptions.size() > 0)
			rollupInvoiceAmtOnProgramSubscription(mapProgramSubscriptions, false);			
	}
    
    /**
     *  @description    :   This method is used to rollup the Invoice Total and Amount Credited Total
     *
     *  @args           :   Set<Id>, Boolean
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - Created - Subhash Garhwal - Q2C Phase 2
     *
     **/
    public static void rollupInvoiceAmtOnProgramSubscription(Map<Id, SBQQ__Subscription__c> mapProgramSubscriptions, Boolean calcCreditNoteTotal) {
    	
    	//Check for set size
    	if(mapProgramSubscriptions.size() > 0) {
			
			//codaInvoice logic
			if(!calcCreditNoteTotal) {
				
				//Aggregate query on c2g__codaInvoice__c
		        for(AggregateResult aR : [Select Program_Subscription__c pS, SUM(c2g__NetTotal__c) NT, SUM(c2g__Transaction__r.Outstanding_Total_Minus_Taxes__c) AC 
													From c2g__codaInvoice__c Where Program_Subscription__c != null and Program_Subscription__c IN : mapProgramSubscriptions.keySet()
		        									GROUP BY Program_Subscription__c]) {
		        												  									
		        	//Get Program Subscription Id
		        	Id proSubId = String.valueOf(aR.get('pS'));	
		        	
		        	//Check Program Subscription in map
		        	if(mapProgramSubscriptions.containsKey(proSubId) && aR.get('NT') != null)
		        		mapProgramSubscriptions.get(proSubId).Invoice_Total__c = Decimal.valueOf(String.valueOf(aR.get('NT')));
		        }
		        
		        //Aggregate query on c2g__codaInvoice__c
		        for(AggregateResult aR : [Select Program_Subscription__c pS, SUM(c2g__NetTotal__c) crNT, SUM(c2g__Transaction__r.Outstanding_Total_Minus_Taxes__c) AC 
													From c2g__codaInvoice__c Where Program_Subscription__c != null and Program_Subscription__c IN : mapProgramSubscriptions.keySet()
		        									AND AmtCredited__c > 0 GROUP BY Program_Subscription__c]) {
		        												  									
		        	//Get Program Subscription Id
		        	Id proSubId = String.valueOf(aR.get('pS'));	
		        	
		        	//Check Program Subscription in map
		        	if(mapProgramSubscriptions.containsKey(proSubId)) {
		        		
		        		//Variables to hold the total
			        	Decimal aC = 0;
			        	Decimal crNT = 0;
			        	
			        	//Check for AC total
			        	if(aR.get('AC') != null) 
			                aC = Decimal.valueOf(String.valueOf(aR.get('AC')));
			            
			            //Check for CRNT total
			        	if(aR.get('crNT') != null)
			        		crNT = Decimal.valueOf(String.valueOf(aR.get('crNT')));
			                		
			            //Update Amount_Credited_Total__c
			            mapProgramSubscriptions.get(proSubId).Amount_Credited_Total__c = (crNT - aC);		
		        	}
		        }
		        	
			//CodaCreditNote logic
			} else {
				
				//Aggregate query on c2g__codaInvoice__c
		        for(AggregateResult aR : [Select Program_Subscription__c pS, SUM(c2g__NetTotal__c) NT From c2g__codaCreditNote__c Where
		        													Program_Subscription__c != null AND Program_Subscription__c IN : mapProgramSubscriptions.keySet()
		        											   		GROUP BY Program_Subscription__c]) {
		        												  									
		        	//Get Program Subscription Id
		        	Id proSubId = String.valueOf(aR.get('pS'));	
		        	
		        	//Check Program Subscription in map
		        	if(mapProgramSubscriptions.containsKey(proSubId) && aR.get('NT') != null)
						mapProgramSubscriptions.get(proSubId).Credit_Note_Total__c = Decimal.valueOf(String.valueOf(aR.get('NT')));				
				}	
			}
			
			//Check for map
			if(mapProgramSubscriptions.size() > 0) {
				
				//Bypass triggers
				Util.BypassAllTriggers = true;
				
				//Update 
				Database.Saveresult[] sr = database.update(mapProgramSubscriptions.values(),false);
				
				//Rsset 
				Util.BypassAllTriggers = false;
			}
		}
	}
	
	public static void updateAssociatedBillingSchedulePeriod (List<c2g__codaInvoice__c> salesInvoices, Map<Id, c2g__codaInvoice__c> mapOldSalesInvoices){

		//Set for storing our Sales Invoice Ids
		Set<Id> sInvoiceIds = new Set<Id> ();

		//List for updating Billing Schedule Periods in bulk at the end
		List<Billing_Schedule_Period__c> bPeriodsToUpdate = new List<Billing_Schedule_Period__c>();
		
		//Ensure we have the right older values since this runs on Update only
		if (mapOldSalesInvoices != null) {

			//Loop through our Sales Invoices
			for(c2g__codaInvoice__c sInvoice : salesInvoices != null ? salesInvoices : mapOldSalesInvoices.values()) {

				//Check to see if the Status fields were updated
				if ((sInvoice.c2g__PrintStatus__c == 'Printed' && mapOldSalesInvoices.get(sInvoice.Id).c2g__PrintStatus__c != 'Printed') ||
					(sInvoice.Email_Status__c == 'Emailed' && mapOldSalesInvoices.get(sInvoice.Id).Email_Status__c != 'Emailed')) {

						//Add our Id to Set
						sInvoiceIds.add(sInvoice.Id);

					}
			}
		}

		//If we have IDs then work through them
		if (sInvoiceIds.size() > 0){

			//Query for any Billing Schedule Periods where the Sales Invoice is referenced and it is not already marked as completed
			List <Billing_Schedule_Period__c> bPeriods = [SELECT Id, Name, Actual_Invoice_Sent_Date__c, Sales_Invoice__c, Invoice_Sent__c
															FROM Billing_Schedule_Period__c
															WHERE Sales_Invoice__c IN :sInvoiceIds
															AND (Actual_Invoice_Sent_Date__c = NULL OR Invoice_Sent__c = FALSE)];

			//If we have records then proceed
			if (bPeriods.size() > 0) {

				//Loop through Billing Schedule Periods
				for (Billing_Schedule_Period__c bPeriod : bPeriods){

					//Boolean for update
					boolean updateNeeded = false;

					//Check to see if either of our fields are blank/not populated and populate them
					if (bPeriod.Invoice_Sent__c == false){
						bPeriod.Invoice_Sent__c = true;

						//Mark boolean so we add record to list
						updateNeeded = true;
					}

					if (bPeriod.Actual_Invoice_Sent_Date__c == null){
						bPeriod.Actual_Invoice_Sent_Date__c = Date.Today();

						//Mark boolean so we add record to list
						if (updateNeeded != true){
							updateNeeded = true;
						}
					}

					//If our boolean is true then add record to the list
					if (updateNeeded == true){
						bPeriodsToUpdate.add(bPeriod);
					}

				}

			}

		}

		//If we have records then run our update
		if (bPeriodsToUpdate.size() > 0){
			update bPeriodsToUpdate;
		}

	}
        
    /**
      * 
      *  @description	:   Added method to update the phone on Sales invoice from user
      *
      *  @args		:   List<c2g__codaInvoice__c>, Map<Id, c2g__codaInvoice__c>
      *
      *  @return	:   void
      *
      *  @revision Log	:   V1.0 - Created - 06/12/2020 - Mahendra Swarnkar - CR-20200605-14145                
      * 
    **/
    public static void populateCreditManagePhone(List<c2g__codaInvoice__c> salesinvoicelist,Map<Id, c2g__codaInvoice__c> mapOldSalesInvoices){
        
        set<Id> setOfUserId = new set<Id>();
        Map<Id,User> mapOfUser = new Map<Id,User>();
        
        for(c2g__codaInvoice__c invoice : salesinvoicelist){
           
            if(mapOldSalesInvoices == null || (mapOldSalesInvoices != null && (invoice.Credit_Manager__c != mapOldSalesInvoices.get(invoice.Id).Credit_Manager__c 
                                                                             || invoice.Credit_Manger_Phone__c != mapOldSalesInvoices.get(invoice.Id).Credit_Manger_Phone__c)) ){
               
                if(invoice.Credit_Manager__c != null){
                    setOfUserId.add(invoice.Credit_Manager__c);
                }
            }
        }
        
        if(setOfUserId.size() > 0){
            for(user usr  : [Select Id,phone from user where id =: setOfUserId]){
                if(!mapOfUser.containsKey(usr.Id)){
                	mapOfUser.put(usr.Id,usr);
                }
            }
        }
        
        for(c2g__codaInvoice__c invoice : salesinvoicelist){
            if(invoice.Credit_Manager__c != null && mapOfUser.containsKey(invoice.Credit_Manager__c)){
                if(mapOfUser.containsKey(invoice.Credit_Manager__c) && String.isNotBlank(mapOfUser.get(invoice.Credit_Manager__c).Phone)){
                	invoice.Credit_Manger_Phone__c = FormatPhone(mapOfUser.get(invoice.Credit_Manager__c).Phone);
                }
            }
            else if(invoice.Credit_Manager__c == null ){
                 invoice.Credit_Manger_Phone__c = '';
            }
        }
    }
    
    /**
      * 
      *  @description	:   Added method to format phone number
      *
      *  @args		:   List<c2g__codaInvoice__c>, Map<Id, c2g__codaInvoice__c>
      *
      *  @return	:   void
      *
      *  @revision Log	:   V1.0 - Created - 06/12/2020 - Mahendra Swarnkar - CR-20200605-14145                
      * 
    **/
    private static String FormatPhone(String Phone) {
        string nondigits = '[^0-9]';
        string PhoneDigits;
        
        // remove all non numeric
        PhoneDigits = Phone.replaceAll(nondigits,'');
        
        // 10 digit: reformat with dashes
        if (PhoneDigits.length() == 10) 
            return + '('+ PhoneDigits.substring(0,3) + ') ' +
            PhoneDigits.substring(3,6) + '-' +
            PhoneDigits.substring(6,10);
        // 11 digit: if starts with 1, format as 10 digit 
        if (PhoneDigits.length() == 11) {
            if (PhoneDigits.substring(0,1) == '1') {
                return  PhoneDigits.substring(1,4) + '-' +
                    PhoneDigits.substring(4,7) + '-' +
                    PhoneDigits.substring(7,11);
            }
        }
        
        // if it isn't a 10 or 11 digit number, return the original because
        // it may contain an extension or special information
        return( Phone );
    }
    
    // Modified By - Colin McGloin - CR-20200715-14316 
    @auraEnabled (cacheable=true)
    public static List<billingContactWrapper> getBillingContactsForSalesInvoice (String recordId){

        //List of BillingContactWrapper records 
        List<billingContactWrapper> billingContacts = new List<billingContactWrapper>();
        
        // CR-20211112-15581 Map to hold billingContactWrapper with contact Id.
	Map<Id, billingContactWrapper> billingContactsWrapperWithContactId  = new Map<Id, billingContactWrapper>();
        
        //We have our Record Id - let's go get the Record and necessary details
        c2g__codaInvoice__c sInvoice = [SELECT Id, Contract__c, Invoice_Contact__c, Invoice_Contact__r.Name, Invoice_Contact__r.Email, Invoice_Contact__r.AssistantName, Invoice_Contact__r.Asst_Email__c, ffaci__InvoiceEmail__c
                                        FROM c2g__codaInvoice__c
                                        WHERE Id = :recordId];

        //Let's get any Invoice Billing Contacts
        List<Invoice_Billing_Contact__c> invoiceBillContacts = InvoiceBillingContactTriggerHelper.getInvoiceBillingContacts(sInvoice.Contract__c);        

        //Check to see if we have Invoice Billing Contacts
        if (invoiceBillContacts.size() > 0){

            //Loop through Records
            for (Invoice_Billing_Contact__c ibc : invoiceBillContacts){

                //Check to see if Enabled for this Contract is Checked
                if (ibc.Enabled_for_this_Contract__c == true){

                    //Create our Billing Contact Wrapper record and add to our List
                    /*billingContactWrapper billWrap = new billingContactWrapper (ibc.Contact_Name__c, ibc.Invoice_Email__c, 'Invoice Billing Contact');
                    billingContacts.add(billWrap);*/
                    
                    //CR-20211112-15581
                    if(!billingContactsWrapperWithContactId.containsKey(ibc.Contact__c)){
                        billingContactWrapper billWrap = new billingContactWrapper (ibc.Contact_Name__c, ibc.Invoice_Email__c, 'Invoice Billing Contact');
                        billingContactsWrapperWithContactId.put(ibc.Contact__c, billWrap);
                    } 
                }
            }
        }

        //Check for Invoice Contact on Sales Invoice
        if (sInvoice.Invoice_Contact__c != null){

            /*billingContactWrapper billWrap = new billingContactWrapper (sInvoice.Invoice_Contact__r.Name, sInvoice.Invoice_Contact__r.Email, 'Invoice Contact');
            billingContacts.add(billWrap);*/
            
            //CR-20211112-15581
            if(!billingContactsWrapperWithContactId.containsKey(sInvoice.Invoice_Contact__c)){
                billingContactWrapper billWrap = new billingContactWrapper (sInvoice.Invoice_Contact__r.Name, sInvoice.Invoice_Contact__r.Email, 'Invoice Contact');
                billingContactsWrapperWithContactId.put(sInvoice.Invoice_Contact__c, billWrap);
            }

            //Check for Assistant Email being populated
            if (sInvoice.Invoice_Contact__r.Asst_Email__c != null){

                billingContactWrapper billWrapAsst = new billingContactWrapper (sInvoice.Invoice_Contact__r.AssistantName, sInvoice.Invoice_Contact__r.Asst_Email__c, 'Invoice Contact Assistant');
                billingContacts.add(billWrapAsst);
                
            }
        }

        //Check for our Invoice Email from Institution
        if (sInvoice.ffaci__InvoiceEmail__c != null){

            billingContactWrapper billWrap = new billingContactWrapper ('Institution: Invoice Email', sInvoice.ffaci__InvoiceEmail__c, 'Institution: Invoice Email');
            billingContacts.add(billWrap);

        }
        
	//CR-20211112-15581
        if(billingContactsWrapperWithContactId != null && billingContactsWrapperWithContactId.size() > 0){
            billingContacts.addAll(billingContactsWrapperWithContactId.values());
        }
        
        system.debug('Billing Contacts:' + billingContacts);
        system.debug('Billing Contacts Size:' + billingContacts.size());
        
        return billingContacts;

    }

    public class billingContactWrapper {
	
	// Modified By - Modified By - Neha Sharma - CR-20210628-15255
        @AuraEnabled public String billingContactName {get; set;}
        @AuraEnabled public String email {get; set;}
        @AuraEnabled public String type {get; set;}

        billingContactWrapper (String billName, String email, String type){

            this.billingContactName = billName;
            this.email = email;
            this.type = type;

        }

    }

}