/*
   Purpose	:    Test custom data entry for Journal
  Initiative	:    IconATG FinancialForce PSA Implementation 
  Author	:    John McCarvill
  Company	:    IconATG
  Contact	:    john.mccarvill@iconatg.com
  Created	:    3/31/2015

  		     - Added Apex Controller - ICON_JournalLine_Controller.cls
		     - Added Apex Unit Test - ICON_JournalLine_Controller_Test.cls
		     - Added Visualforce Page - ICON_JournalLine.page
		     - Added button to Journal
		     - Added jquery_ICON static resource

*/
public with sharing class ICON_JournalLine_Controller {
	
	public string m_sId {get; set;}

    //property for message display
    public string showMessage{get; set;}

	public c2g__codaJournal__c m_pHeader {get; set;}
	public List<c2g__codaJournalLineItem__c> m_listLines {get; set;}
	public Set<c2g__codaJournalLineItem__c> m_setLinesDelete {get; set;}

	public decimal m_dTotal {get; set;}
	public decimal m_dTotalDebits {get; set;}
	public decimal m_dTotalCredits {get; set;}
	
	public ICON_JournalLine_Controller(ApexPages.StandardController stdController)
	{
		//initialize 
		m_sId = ((c2g__codaJournal__c)stdController.getRecord()).Id;
		LoadDetails();
	}


	public Pagereference LoadDetails()
	{
		if (m_sId==null || m_sId=='')
		{
			this.showMessage='Invalid Journal ID.';
			return null;
		}
		else
		{
			//load header
			m_pHeader = [Select c.ffgl__DerivePeriod__c, c.ffgl__DeriveCurrency__c, c.c2g__Year__c, c.c2g__UnitofWork__c, 
								c.c2g__Type__c, c.c2g__Transaction__c, c.c2g__Total__c, c.c2g__SourceJournal__c, c.c2g__Reference__c, 
								c.c2g__Period__c, c.c2g__OwnerCompany__c, c.c2g__OverrideDebitValue3__c, c.c2g__OverrideDebitValue2__c, 
								c.c2g__OverrideDebitValue1__c, c.c2g__OverrideCurrency3__c, c.c2g__OverrideCurrency2__c, 
								c.c2g__OverrideCurrency1__c, c.c2g__OriginalJournal__c, c.c2g__JournalStatus__c, c.c2g__JournalDescription__c, 
								c.c2g__JournalDate__c, c.c2g__JournalCurrency__c, c.c2g__IncomeScheduleGroup__c, c.c2g__ExternalId__c, 
								c.c2g__DiscardReason__c, c.c2g__Debits__c, c.c2g__Credits__c, c.Registered_Date__c, 
								c.OwnerId, c.Name, c.Id, c.Approved__c, c.CurrencyIsoCode
								From c2g__codaJournal__c c
								WHERE c.Id =: m_sId];
			
			if (m_pHeader.c2g__JournalStatus__c!='In Progress') 
			{
				this.showMessage = 'You cannot edit this Journal (Status=' + m_pHeader.c2g__JournalStatus__c + ')';
				return(null);
			} 
			
			//set the totals
			m_dTotal = NotNull(m_pHeader.c2g__Total__c);
			m_dTotalDebits = NotNull(m_pHeader.c2g__Debits__c);
			m_dTotalCredits = NotNull(m_pHeader.c2g__Credits__c);
			
			//load line items
			//Modified By - Mahendra Swarnkar - 7/30/2021 - CR-20210119-14818 - Add Budget ID to Journals
			this.m_listLines = [Select c.ffgl__DeriveLineNumber__c, c.c2g__YearEndCriterionIdentifier__c, c.c2g__VendorValue__c, 
								c.c2g__Value__c, c.c2g__UnitOfWork__c, c.c2g__TaxCode__c, c.c2g__Product__c, c.c2g__OwnerCompany__c, 
								c.c2g__LineType__c, c.c2g__LineNumber__c, c.c2g__LineDescription__c, c.c2g__Journal__c, c.c2g__HomeValue__c, 
								c.c2g__GeneralLedgerAccount__c, c.c2g__GeneralLedgerAccountValue__c, c.c2g__ExternalId__c, 
								c.c2g__DualValue__c, c.c2g__Dimension4__c, c.c2g__Dimension4Value__c, c.c2g__Dimension3__c, 
								c.c2g__Dimension3Value__c, c.c2g__Dimension2__c, c.c2g__Dimension2Value__c, c.c2g__Dimension1__c, 
								c.c2g__Dimension1Value__c, c.c2g__DestinationCompany__c, c.c2g__DebitCredit__c, c.c2g__BankAccount__c, 
								c.c2g__BankAccountValue__c, c.c2g__Account__c, c.c2g__AccountValue__c, c.Transaction_Date__c, c.CurrencyIsoCode,
								c.Id, c.Job_Number_Name__c, c.c2g__AccountAnalysis__c, c.Budget_System_ID__c
								From c2g__codaJournalLineItem__c c
								WHERE c.c2g__Journal__c=:m_sId
								ORDER BY c.c2g__LineNumber__c];		
			
			//initialize delete cache
			this.m_setLinesDelete = new Set<c2g__codaJournalLineItem__c>(); 
			
		}
		
		return(null);
		
	}

	public Pagereference Cancel()
	{
		//send user to the original document
        PageReference redirect = new PageReference('/' + m_sId); 
    
    	return(redirect);
	}


	public Pagereference RemoveLine()
	{
		//grab passed in parameters for removal
		string sId = ApexPages.currentPage().getParameters().get('LineId');		
		
		System.debug('JM RemoveLine - sId: ' + sId);
		
		
		//scan line items for specified row to delete
		for(Integer i=0; i<this.m_listLines.size(); i++)
		{
			c2g__codaJournalLineItem__c pLine = this.m_listLines[i];
			System.debug('JM Before Remove - pLine.c2g__LineNumber__c: ' + pLine.c2g__LineNumber__c);
			System.debug('JM Before Remove - pLine.c2g__LineDescription__c: ' + pLine.c2g__LineDescription__c);
		}
		
		
		//scan line items for specified row to delete
		for(Integer i=0; i<this.m_listLines.size(); i++)
		{
			c2g__codaJournalLineItem__c pLine = this.m_listLines[i];

			System.debug('JM RemoveLine - pLine.c2g__LineNumber__c: ' + pLine.c2g__LineNumber__c);
						
			//remove the item from the display list
			if (pLine.c2g__LineNumber__c==decimal.valueOf(sId)) 
			{

				//remove this item from the list
				this.m_listLines.remove(i);
				
				System.debug('JM RemoveLine - this.m_listLines.remove(i): ' + i);
				System.debug('JM RemoveLine - pLine.Id: ' + pLine.Id);
				
				//cache the record for later delete if document is saved and line came from database with Id
				if (pLine.Id!=null) this.m_setLinesDelete.add(pLine);
			}
		}
		
		
		//scan line items total - needed because remove line refresh does not force jQuery recalculate
		m_dTotal = 0.0;
		m_dTotalDebits = 0.0;
		m_dTotalCredits = 0.0;
		
		for(Integer i=0; i<this.m_listLines.size(); i++)
		{
			c2g__codaJournalLineItem__c pLine = this.m_listLines[i];
			
			m_dTotal += NotNull(pLine.c2g__Value__c);
			if (NotNull(pLine.c2g__Value__c)<0) m_dTotalCredits-=NotNull(pLine.c2g__Value__c);
			if (NotNull(pLine.c2g__Value__c)>0) m_dTotalDebits+=NotNull(pLine.c2g__Value__c);
			
			System.debug('JM After Remove - pLine.c2g__Value__c: ' + pLine.c2g__Value__c);
			System.debug('JM After Remove - pLine.c2g__LineNumber__c: ' + pLine.c2g__LineNumber__c);
			System.debug('JM After Remove - pLine.c2g__LineDescription__c: ' + pLine.c2g__LineDescription__c);
						
		}
		
		
		return(null);
	}
	

	public Pagereference AddLine()
	{

		//reset message
		this.showMessage='';

		//get the next line number and last entry values for Dimension and description
		String sDimensionId=null;
		String sDescription=null;
		decimal iLineNumber=0;
		
		
		//iterate lines and make sure viewstate is stored before attempting to remove a line
		
		System.debug('JM FlushLines - this.m_listLines.size(): ' + this.m_listLines.size());
		
		//scan line items for specified row to delete
		for(Integer i=0; i<this.m_listLines.size(); i++)
		{
			System.debug('JM FlushLines - i: ' + i);
			c2g__codaJournalLineItem__c pLine = this.m_listLines[i];

			System.debug('JM FlushLines - pLine.c2g__LineNumber__c: ' + pLine.c2g__LineNumber__c);
			System.debug('JM FlushLines - pLine.c2g__LineDescription__c: ' + pLine.c2g__LineDescription__c);
						
		}
		
		
		//iterate to determine next defaults
		for(Integer i=0; i<this.m_listLines.size(); i++)
		{
			System.debug('JM AddLine - i: ' + i);
			c2g__codaJournalLineItem__c pLine = this.m_listLines[i];
			
			System.debug('JM AddLine - pLine.c2g__LineNumber__c: ' + pLine.c2g__LineNumber__c);
			System.debug('JM AddLine - iLineNumber: ' + iLineNumber);
			
			//is this the next number
			if (pLine.c2g__LineNumber__c>iLineNumber)
			{
				//set the defaults
				iLineNumber = pLine.c2g__LineNumber__c;
				sDimensionId = pLine.c2g__Dimension1__c;
				sDescription =  pLine.c2g__LineDescription__c;
				
				System.debug('JM AddLine - use as template - iLineNumber: ' + iLineNumber);
				System.debug('JM AddLine - use as template - sDescription: ' + sDescription);
				
			}
			
		}
		
		//increment from highest previous line
		iLineNumber+=1;
		
		
		//create new  line and add to list
		c2g__codaJournalLineItem__c pJournalLineItem = new c2g__codaJournalLineItem__c(
			CurrencyIsoCode = m_pHeader.CurrencyIsoCode, 		//picklist(3)
			c2g__Journal__c = m_pHeader.Id, 		//reference(c2g__codaJournal__c)
			c2g__Dimension1__c = sDimensionId, 		//reference(c2g__codaDimension1__c)
			//c2g__GeneralLedgerAccount__c = 'a1O190000008iymEAA', 		//reference(c2g__codaGeneralLedgerAccount__c)
			c2g__LineDescription__c = sDescription, 		//text(255)
			c2g__LineNumber__c = iLineNumber, 		//number(18,0)
			//c2g__LineType__c = 'General Ledger Account', 		//picklist(255)
			c2g__OwnerCompany__c = m_pHeader.c2g__OwnerCompany__c, 		//reference(c2g__codaCompany__c)
			c2g__UnitOfWork__c = 1.0, 		//number(18,0)
			c2g__Value__c = 0.0, 		//number(18,2)
			c2g__VendorValue__c = 0.0, 		//number(18,2)
			//c2g__DebitCredit__c = 'Debit', 		//picklist(255)
			ffgl__DeriveLineNumber__c = false 		//boolean
			//Transaction_Date__c = '2015-01-01', 		//date
		);
		
		System.debug('JM AddLine - pJournalLineItem.c2g__LineNumber__c: ' + pJournalLineItem.c2g__LineNumber__c);
		System.debug('JM AddLine - pJournalLineItem.c2g__Dimension1__c: ' + pJournalLineItem.c2g__Dimension1__c);
		System.debug('JM AddLine - pJournalLineItem.c2g__LineDescription__c: ' + pJournalLineItem.c2g__LineDescription__c);
		
		//put in set
		this.m_listLines.add(pJournalLineItem);
		
		//refer back to page
		return(null);
	}

	
    public Pagereference saveDocument()
    {
		
		try
		{
			//reset message
			this.showMessage='';
			
			//renumber in sequence
			decimal dCounter=1;
			for(c2g__codaJournalLineItem__c pLine:this.m_listLines)
			{
				pLine.c2g__LineNumber__c=dCounter;
				dCounter++;
			}
			
			//save lines
			upsert(this.m_listLines);
	
			//delete cached deletes		
			List<c2g__codaJournalLineItem__c> listLinesDelete = new List<c2g__codaJournalLineItem__c>(); 
			for(c2g__codaJournalLineItem__c pLine:this.m_setLinesDelete)
			{
				//only add to delete list if record has an ID - may have added a line and then decided to remove it
				if (pLine.Id!=null) listLinesDelete.add(pLine);
			}
	    	delete(listLinesDelete);
	
			
			//send user to the original document
	        //PageReference redirect = new PageReference('/' + m_sId); 
        	//return(redirect);
        	
		}
		catch(Exception err)
		{
			this.showMessage = err.getMessage();
		}
		
        return(null);
    }


	//utility function to remove nulls and default to 0.0 for decimal
	private decimal NotNull(decimal dValue)
	{
		decimal dReturn=0.0;
		if (dValue!=null) dReturn=dValue;
		return(dReturn);
	}

}