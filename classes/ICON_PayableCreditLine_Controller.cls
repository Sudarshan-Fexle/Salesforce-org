/*
  Purpose:
    
    Test custom data entry for Payable Invoice
    
  Initiative: IconATG FinancialForce PSA Implementation 
  Author:     John McCarvill
  Company:    IconATG
  Contact:    john.mccarvill@iconatg.com
  Created:    4/1/2015

	- Added Apex Controller - ICON_PayableCreditLine_Controller.cls
	- Added Apex Unit Test - ICON_PayableCreditLine_Controller_Test.cls
	- Added Visualforce Page - ICON_PayableCreditLine.page
	- Added button to payable invoice
	- Added jquery_ICON static resource
  
*/

public with sharing class ICON_PayableCreditLine_Controller {
	
	public string m_sId {get; set;}

    //property for message display
    public string showMessage{get; set;}

	public c2g__codaPurchaseCreditNote__c m_pHeader {get; set;}
	public List<c2g__codaPurchaseCreditNoteExpLineItem__c> m_listLines {get; set;}
	public Set<c2g__codaPurchaseCreditNoteExpLineItem__c> m_setLinesDelete {get; set;}

	public decimal m_dTotal {get; set;}

	
	public ICON_PayableCreditLine_Controller(ApexPages.StandardController stdController)
	{
		//initialize 
		m_sId = ((c2g__codaPurchaseCreditNote__c)stdController.getRecord()).Id;
		LoadDetails();
	}


	public Pagereference LoadDetails()
	{
		if (m_sId==null || m_sId=='')
		{
			this.showMessage='Invalid Payable Invoice ID.';
			return null;
		}
		else
		{
			//load header
			m_pHeader = [Select c.ffbext__Approved__c, c.ffap__VATRegistrationNumber__c, c.ffap__DerivePeriod__c, c.ffap__DeriveDueDate__c, 
								c.ffap__DeriveCurrency__c, c.ffap__CopyAccountValues__c, c.ffap__AccountECCountryCode__c, 
								c.ffap__AccountAddress__c, c.c2g__Year__c, c.c2g__UnitOfWork__c, c.c2g__Transaction__c, 
								c.c2g__TaxTotal__c, c.c2g__TaxCode1__c, c.c2g__RegisteredDate__c, c.c2g__Reference2__c, 
								c.c2g__Reference1__c, c.c2g__Period__c, c.c2g__PaymentStatus__c, c.c2g__OwnerCompany__c, 
								c.c2g__OutstandingValue__c, c.c2g__NetTotal__c, c.c2g__MatchType__c, c.c2g__ItemsTax1Total__c, 
								c.c2g__ItemsNetTotal__c, c.c2g__InvoiceDate__c, c.c2g__IncomeTaxType__c, c.c2g__ExternalId__c, 
								c.c2g__ExpensesTax1Total__c, c.c2g__ExpensesNetTotal__c, c.c2g__DueDate__c, c.c2g__DualRate__c, 
								c.c2g__DiscardReason__c, c.c2g__Dimension4__c, c.c2g__Dimension3__c, c.c2g__Dimension2__c, 
								c.c2g__Dimension1__c, c.c2g__CreditNoteTotal__c, c.c2g__CreditNoteStatus__c, c.c2g__CreditNoteReason__c, 
								c.c2g__CreditNoteRate__c, c.c2g__CreditNoteDescription__c, c.c2g__CreditNoteDate__c, 
								c.c2g__CreditNoteCurrency__c, c.c2g__Account__c, c.c2g__AccountInvoiceNumber__c, 
								c.c2g__AccountCreditNoteNumber__c, c2g__Account__r.c2g__CODADefaultExpenseAccount__c, c.CurrencyIsoCode, c.Name  
								From c2g__codaPurchaseCreditNote__c c
								WHERE c.Id =: m_sId];
			
								
			
			if (m_pHeader.c2g__CreditNoteStatus__c!='In Progress') 
			{
				this.showMessage = 'You cannot edit this Payable Credit Note (Status=' + m_pHeader.c2g__CreditNoteStatus__c + ')';
				return(null);
			} 
			
			//set the total
			m_dTotal = NotNull(m_pHeader.c2g__ExpensesNetTotal__c);
			
			//load line items
			this.m_listLines = [Select c.ffap__SetTaxCodeToDefault__c, c.ffap__SetGLAToDefault__c, c.ffap__GLACode__c, 
								c.ffap__DeriveTaxRateFromCode__c, c.ffap__DeriveLineNumber__c, c.ffap__CalculateTaxValueFromRate__c, 
								c.c2g__UnitOfWork__c, c.c2g__TaxValueTotal__c, c.c2g__TaxValue1__c, c.c2g__TaxRateTotal__c, 
								c.c2g__TaxRate1__c, c.c2g__PurchaseCreditNote__c, c.c2g__OwnerCompany__c, c.c2g__NetValue__c, 
								c.c2g__LineNumber__c, c.c2g__LineDescription__c, c.c2g__InputVATCode__c, c.c2g__GeneralLedgerAccount__c, 
								c.c2g__ExternalId__c, c.c2g__EditTaxValue__c, c.c2g__Dimension4__c, c.c2g__Dimension3__c, 
								c.c2g__Dimension2__c, c.c2g__Dimension1__c, c.c2g__DateTo__c, c.c2g__DateFrom__c, c.SystemModstamp, 
								c.Non_Reportable__c, c.Id, c.CurrencyIsoCode, c.Name, c.Job_Number_Name__c  
								From c2g__codaPurchaseCreditNoteExpLineItem__c c
								WHERE c.c2g__PurchaseCreditNote__c=:m_sId
								ORDER BY c.c2g__LineNumber__c];		
			
			//initialize delete cache
			this.m_setLinesDelete = new Set<c2g__codaPurchaseCreditNoteExpLineItem__c>(); 
			
			
			//check for defaulting GL account on new payable
			/*
			if (m_pHeader.c2g__Account__r.c2g__CODADefaultExpenseAccount__c!=null && this.m_listLines.size()==0)
			{
				//create a default line item using this GL account
				//create new  line and add to list
				c2g__codaPurchaseCreditNoteExpLineItem__c pPayableCreditNoteExpenseLineItem = new c2g__codaPurchaseCreditNoteExpLineItem__c(
					CurrencyIsoCode = m_pHeader.CurrencyIsoCode, 		//picklist(3)
					c2g__PurchaseCreditNote__c = m_pHeader.Id, 		//reference(c2g__codaPurchaseCreditNote__c)
					c2g__EditTaxValue__c = false, 		//boolean
					c2g__GeneralLedgerAccount__c = m_pHeader.c2g__Account__r.c2g__CODADefaultExpenseAccount__c, 		//reference(c2g__codaGeneralLedgerAccount__c)
					c2g__LineNumber__c = 1.0, 		//number(18,0)
					c2g__NetValue__c = 0.0, 		//number(18,2)
					c2g__OwnerCompany__c = m_pHeader.c2g__OwnerCompany__c, 		//reference(c2g__codaCompany__c)
					c2g__UnitOfWork__c = 1.0, 		//number(18,0)
					ffap__CalculateTaxValueFromRate__c = false, 		//boolean
					ffap__DeriveLineNumber__c = false, 		//boolean
					ffap__DeriveTaxRateFromCode__c = false, 		//boolean
					ffap__SetGLAToDefault__c = false, 		//boolean
					ffap__SetTaxCodeToDefault__c = false, 		//boolean
					Non_Reportable__c = true 		//boolean
				);
				
				//put in set
				this.m_listLines.add(pPayableCreditNoteExpenseLineItem);
			}
			*/
						
			
			
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
			c2g__codaPurchaseCreditNoteExpLineItem__c pLine = this.m_listLines[i];
			System.debug('JM Before Remove - pLine.c2g__LineNumber__c: ' + pLine.c2g__LineNumber__c);
			System.debug('JM Before Remove - pLine.c2g__LineDescription__c: ' + pLine.c2g__LineDescription__c);
		}
		
		
		//scan line items for specified row to delete
		for(Integer i=0; i<this.m_listLines.size(); i++)
		{
			c2g__codaPurchaseCreditNoteExpLineItem__c pLine = this.m_listLines[i];

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
		for(Integer i=0; i<this.m_listLines.size(); i++)
		{
			c2g__codaPurchaseCreditNoteExpLineItem__c pLine = this.m_listLines[i];
			m_dTotal += NotNull(pLine.c2g__NetValue__c);
			
			System.debug('JM After Remove - pLine.c2g__NetValue__c: ' + pLine.c2g__NetValue__c);
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
			c2g__codaPurchaseCreditNoteExpLineItem__c pLine = this.m_listLines[i];

			System.debug('JM FlushLines - pLine.c2g__LineNumber__c: ' + pLine.c2g__LineNumber__c);
			System.debug('JM FlushLines - pLine.c2g__LineDescription__c: ' + pLine.c2g__LineDescription__c);
						
		}
		
		
		//iterate to determine next defaults
		for(Integer i=0; i<this.m_listLines.size(); i++)
		{
			System.debug('JM AddLine - i: ' + i);
			c2g__codaPurchaseCreditNoteExpLineItem__c pLine = this.m_listLines[i];
			
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
		c2g__codaPurchaseCreditNoteExpLineItem__c pPayableCreditNoteExpenseLineItem = new c2g__codaPurchaseCreditNoteExpLineItem__c(
			CurrencyIsoCode = m_pHeader.CurrencyIsoCode, 		//picklist(3)
			c2g__PurchaseCreditNote__c = m_pHeader.Id, 		//reference(c2g__codaPurchaseCreditNote__c)
			c2g__Dimension1__c = sDimensionId, 		//reference(c2g__codaDimension1__c)
			c2g__EditTaxValue__c = false, 		//boolean
			//c2g__GeneralLedgerAccount__c = 'a1O190000008j00EAA', 		//reference(c2g__codaGeneralLedgerAccount__c)
			c2g__LineDescription__c = sDescription, 		//textarea(255)
			c2g__LineNumber__c = iLineNumber, 		//number(18,0)
			c2g__NetValue__c = 0.0, 		//number(18,2)
			c2g__OwnerCompany__c = m_pHeader.c2g__OwnerCompany__c, 		//reference(c2g__codaCompany__c)
			c2g__UnitOfWork__c = 1.0, 		//number(18,0)
			ffap__CalculateTaxValueFromRate__c = false, 		//boolean
			ffap__DeriveLineNumber__c = false, 		//boolean
			ffap__DeriveTaxRateFromCode__c = false, 		//boolean
			ffap__SetGLAToDefault__c = false, 		//boolean
			ffap__SetTaxCodeToDefault__c = false, 		//boolean
			Non_Reportable__c = false 		//boolean
		);
		
		System.debug('JM AddLine - pPayableCreditNoteExpenseLineItem.c2g__LineNumber__c: ' + pPayableCreditNoteExpenseLineItem.c2g__LineNumber__c);
		System.debug('JM AddLine - pPayableCreditNoteExpenseLineItem.c2g__Dimension1__c: ' + pPayableCreditNoteExpenseLineItem.c2g__Dimension1__c);
		System.debug('JM AddLine - pPayableCreditNoteExpenseLineItem.c2g__LineDescription__c: ' + pPayableCreditNoteExpenseLineItem.c2g__LineDescription__c);
		
		//put in set
		this.m_listLines.add(pPayableCreditNoteExpenseLineItem);
		
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
			for(c2g__codaPurchaseCreditNoteExpLineItem__c pLine:this.m_listLines)
			{
				pLine.c2g__LineNumber__c=dCounter;
				dCounter++;
			}
			
			//save lines
			upsert(this.m_listLines);
	
			//delete cached deletes		
			List<c2g__codaPurchaseCreditNoteExpLineItem__c> listLinesDelete = new List<c2g__codaPurchaseCreditNoteExpLineItem__c>(); 
			for(c2g__codaPurchaseCreditNoteExpLineItem__c pLine:this.m_setLinesDelete)
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