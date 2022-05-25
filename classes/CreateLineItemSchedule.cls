public with sharing class CreateLineItemSchedule {

    public Id conID {get; set;}
    public Boolean err {get; set;}
    public Boolean showdate {get; set;}
    public Boolean showresults {get; set;}
    public Date FirstInvoiceDate {get; set;}
    public Decimal ExchangeRate {get; set;}
    public Decimal InvoiceAmt {get; set;}
    public Decimal TotInvoiceAmt {get; set;}
    public Id InvBillSchedID {get; set;}
    public Integer Periods {get; set;}
    public String strPeriods {get; set;}
    public Integer MonthsInterval {get; set;}
    public Contract__c c {get; set;}
    Integer InvArrangement;
    
    public CreateLineItemSchedule() {
        err = false;
        showdate = true;    
        showresults = false;
        conID = System.currentPageReference().getParameters().get('cid');
        if (conID == null) {return;}

        c = [select Initial_Invoice_Date__c, Exchange_Rate__c, Negotiated_Amount__c, Y1_Annual_Fee__c, Y2_Annual_Fee__c, Y3_Annual_Fee__c, Y4_Annual_Fee__c, Y5_Annual_Fee__c, Invoice_Billing_Schedule__c, Years_in_Term__c, Invoicing_Arrangement__c, Line_Item_Schedule_Total__c, Contract_Currency__c from Contract__c where Id = :conID];
        if (c.Invoice_Billing_Schedule__c == null) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Line Items cannot be auto-generated for this Contract.  The contract must have an Invoice Billing Schedule.');
                ApexPages.addMessage(msg);
                err = true;
                return;
        }
        if ((c.Years_in_Term__c == null) || (c.Years_in_Term__c < 1)) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Line Items cannot be auto-generated for this Contract.  The contract\'s Years in Term must be greater than 0.');
                ApexPages.addMessage(msg);
                err = true;
                return;
        }
        if ((c.Invoicing_Arrangement__c == null) || ((c.Invoicing_Arrangement__c.toLowerCase() != 'annual') && (c.Invoicing_Arrangement__c.toLowerCase() != 'semi-annual') && (c.Invoicing_Arrangement__c.toLowerCase() != 'quarterly') && (c.Invoicing_Arrangement__c.toLowerCase() != 'monthly'))) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Line Items cannot be auto-generated for this Contract.  The contract must have an Invoicing Arrangement of Annual, Semi-Annual, Quarterly, or Monthly.');
                ApexPages.addMessage(msg);
                err = true;
                return;
        }
	
        if (c.Line_Item_Schedule_Total__c != 0) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Line Items cannot be auto-generated for this Contract.  The contract already has  Line Item Schedule Items.');
                ApexPages.addMessage(msg);
                err = true;
                return;
        }

        ExchangeRate = c.Exchange_Rate__c;
        InvBillSchedID = c.Invoice_Billing_Schedule__c;
        TotInvoiceAmt = c.Negotiated_Amount__c;
        
        if (c.Invoicing_Arrangement__c.toLowerCase() == 'annual') {
            InvArrangement = 1;
            MonthsInterval = 12;
        }
        if (c.Invoicing_Arrangement__c.toLowerCase() == 'semi-annual') {
            InvArrangement = 2;
            MonthsInterval = 6;
        }
        if (c.Invoicing_Arrangement__c.toLowerCase() == 'quarterly') {
            InvArrangement = 4;
            MonthsInterval = 3;
        }
        if (c.Invoicing_Arrangement__c.toLowerCase() == 'monthly') {
            InvArrangement = 12;
            MonthsInterval = 1;
        }
        InvoiceAmt = ((c.Negotiated_Amount__c / c.Years_in_Term__c) / InvArrangement).setScale(2,system.roundingmode.HALF_EVEN);
        c.Initial_Invoice_Date__c = date.today();
        Periods = Integer.valueOf(c.Years_in_Term__c * InvArrangement);
        strPeriods = String.valueOf(Periods)+ ' Line Items Schedule records have been created.';
    }

    public PageReference DoIt() {
        if (err) {return null;}
        showdate = false;
        showresults = true;
        Decimal subtotal = 0.0;
        List<Decimal> amt = new List<Decimal>();
        for (Integer i = 0; i < Periods-1; i++) {
            amt.add(InvoiceAmt);
            subtotal += InvoiceAmt;
        }
        amt.add(TotInvoiceAmt - subtotal);  // determine final payment

        Boolean eom = false;
        FirstInvoiceDate = c.Initial_Invoice_Date__c;
        If ((FirstInvoiceDate.day() >= 29) && (FirstInvoiceDate.day() <= 31)) {
            eom = true;
        }
        
        List<Date> invdate = new List<Date>();
        invdate.add(FirstInvoiceDate);
        for (Integer i = 1; i < Periods; i++) {
            if (!eom) {
                FirstInvoiceDate = FirstInvoiceDate.addMonths(MonthsInterval);
            } else {
                FirstInvoiceDate = FirstInvoiceDate.addMonths(MonthsInterval);
                FirstInvoiceDate = FirstInvoiceDate.addDays(5);
                FirstInvoiceDate = FirstInvoiceDate.toStartOfMonth();
                FirstInvoiceDate = FirstInvoiceDate.addDays(-1);
            }
            invdate.add(FirstInvoiceDate);
        }

        List<Line_Item_Schedule__c> lIS = new List<Line_Item_Schedule__c>();

        //Added By Bhavi Sharma - 04/19/2014 - CR-20140205-4459
        Integer index = 0;
            
        //Loop throgh the Payment Terms
        for(Integer i = 1; i <= c.Years_in_Term__c; i++) {
            
            //Set Amount data here
            Decimal yearlyAmount = c.Negotiated_Amount__c/c.Years_in_Term__c;
            
            if(i == 1 && c.Y1_Annual_Fee__c != null)
            	yearlyAmount = c.Y1_Annual_Fee__c;
            else if(i == 2 && c.Y2_Annual_Fee__c != null)
            	yearlyAmount = c.Y2_Annual_Fee__c;
        	else if(i == 3 && c.Y3_Annual_Fee__c != null)
        		yearlyAmount = c.Y3_Annual_Fee__c;
            else if(i == 4 && c.Y4_Annual_Fee__c != null)
                yearlyAmount = c.Y4_Annual_Fee__c;
            else if(i == 5 && c.Y5_Annual_Fee__c != null)
                yearlyAmount = c.Y5_Annual_Fee__c; 
            
            //Term Amount
            Decimal termAmount = yearlyAmount/InvArrangement;
            
            //Loop through the InvArrangement and create new invoice records
            for(Integer j = 1; j <= InvArrangement; j++) {
                
                //Add Line Item Schedule
                lIS.add(new Line_Item_Schedule__c(Contract__c = conId,  Invoice_Billing_Schedule_del__c = InvBillSchedID, Type__c = 'Member Fee', 
                                                    Invoice_Date__c = invdate[index], Invoice_Amount__c = termAmount/ExchangeRate, Amount__c = termAmount));
        
                index++;
            }
        }
        
        //Commented By Bhavi Sharma - 04/19/2014 - CR-20140205-4459
        /*for (Integer i = 0; i < Periods; i++) {

         lIS.add(new Line_Item_Schedule__c(Contract__c = conId,
                Invoice_Billing_Schedule_del__c = InvBillSchedID,  
                Type__c = 'Member Fee', 
                Invoice_Date__c = invdate[i], 
//              Invoice_Comment__c = 'Test',
                Invoice_Amount__c = amt[i] * ExchangeRate, 
                Amount__c = amt[i]));
        }*/
        insert lIS;
        
        return null;
    }

    public PageReference Cancel() {
            PageReference pr = New PageReference('/' + conID);
            pr.setRedirect(true);
            return pr;
    }
}