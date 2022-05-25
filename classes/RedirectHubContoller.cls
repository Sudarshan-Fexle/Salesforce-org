/**
Desription      :   Controller of Redirect hub-Vf page acting as redirect center for multiple buttons 
Created By      :   Abhinav Sharma
Created Date    :   17/07/2018
Revision Logs   :   v1 - Created
**/
public class RedirectHubContoller 
{
    public String envID {get; set;}
    public String navigateURL {get; set;}
    public String theme;
    public Boolean visibleEnv {get; set;}    
    public boolean hasError 
    {
        get {
            return (apexPages.getMessages().size() > 0);
        }
        set;
    }
    public Map<String,String>mapOfParameters {get; set;} 
    public String JsonMap {get;set;}
    public RedirectHubContoller() 
    { 
        envID= '';
        visibleEnv = false;
        theme = userinfo.getUiThemeDisplayed() ;
        mapOfParameters = new Map<String,String>();
        mapOfParameters = ApexPages.currentPage().getParameters();
        JsonMap=JSON.serialize(mapOfParameters);
    }
    
    //Method to evaluate various pages and their functionality
    public void evaluate()
    {
        switch on mapOfparameters.get('location') 
        {
            when 'ShipIt' 
            {
                contact_ShipIt();
            }
            when 'newCase' 
            {
                createNewCase();
            }
            when 'Meeting_Recruitment' 
            {
                contact_meetingRecruitment();
            }
            when 'SBQQ__AmendContract' 
            {
                pageSBQQ_AmendContract();
            }
            when 'Create_Invoice_Billing_Sched' 
            {
                createInvoiceBillingSched();
            }
            when 'Create_Invoice_Billing_Sched_Subscription'
            {
                createInvoiceBillingSchedSubscription();
            }
            when 'Post_Cash_Entry' 
            {
                postOnCashEntries();
            }
            when 'Post_Sales_Invoice'
            {
                postOnSalesInvoice();
            }
            when 'Post_Payable_Invoice'
            {
                postOnPayableInvoice();
            }
            when 'Post_Sales_Credit_Note'
            {
                postOnSalesCreditNote();
            }
            when 'Add_Program_Subscription'
            {
                addProgramSubscription();
            }  
            when 'Log_Outreach'
            {
                logOutreach();
            } 
            when else 
            {
                //Do something here      
            }
        }
    }  
    
    //Method to update environment record and redirect to new record
    public void setupEnv()
    {
        Map<String,Object> obj =(Map<String,Object> ) JSON.deserializeUntyped(JsonMap);
        if(obj.get('envId') != null) 
        {
            IS_Environment__c env = new IS_Environment__c(Id = ''+obj.get('envId'), Status__c = 'Deleted', End_Date__c = Date.today());
            update env;
            navigateURL = '/apex/URLNavigator?recordTypeId=012C0000000QdGV&operationtype=createRecord&'+
                'entityName=IS_Environment__c&fields=Name@~@Sandbox_Series__c@~@Status__c@~@Date_Refreshed__c'+
                '&classicfieldsid='+EncodingUtil.urlEncode('Name', 'UTF-8')+'@~@'+EncodingUtil.urlEncode('CF00NC0000006VjWy_lkid', 'UTF-8')+'@~@'+EncodingUtil.urlEncode('CF00NC0000006VjX1', 'UTF-8')+
                '@~@'+EncodingUtil.urlEncode('00NC0000006VjX1', 'UTF-8')+'@~@'+EncodingUtil.urlEncode('retURL', 'UTF-8')+'@~@'+EncodingUtil.urlEncode('CF00NC0000006VjWy', 'UTF-8')+
                '&defaults=' +EncodingUtil.urlEncode('Name will auto populate', 'UTF-8')+'@~@' +EncodingUtil.urlEncode(''+obj.get('sandboxSeriesId'), 'UTF-8')+'@~@'
                +EncodingUtil.urlEncode('Active','UTF-8')+'@~@'+EncodingUtil.urlEncode(''+Date.today(),'UTF-8')+'@~@'+EncodingUtil.urlEncode(''+obj.get('envId'), 'UTF-8')+
                '@~@'+EncodingUtil.urlEncode(''+obj.get('sandboxSeriesName'), 'UTF-8');    
        }
    }
    
    //Method for button ShipIt - Object - Contact
    public void contact_ShipIt()
    {
        if(mapOfparameters.get('contactStatus') != null && mapOfparameters.get('contactStatus').indexOf('Inactive') != -1) 
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ShipIt_InactiveContactError));
        }
        else if( mapOfparameters.get('currentUserProfile') != null &&  mapOfparameters.get('currentUserProfile').indexOf('Travel & Events Contractor - External') != -1) 
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, Label.ShipIt_UnauthorizedProfile));
        }
        else if( mapOfparameters.get('currentUserProfile') != null &&  mapOfparameters.get('currentUserProfile').indexOf('Portal') != -1) 
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, Label.ShipIt_UnauthorizedProfile));
        }
        else if(mapOfparameters.get('contactCountry') != null && mapOfparameters.get('contactCountry') != 'United States') 
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, Label.ShipIt_InternationalCountryError));
        }
        else 
        {
            navigateURL = '/apex/ShipIt?contactid='+mapOfparameters.get('contactid');
        }   
    }
    
    //Method for button Meeting_Recruitment - Object - Contact
    public void contact_meetingRecruitment()
    {
        List<Site_Profile__c> siteProfileRecords = [Select Id, Contact__c FROM Site_Profile__c 
                                                    WHERE Contact__c != null 
                                                    AND Contact__c =: mapOfparameters.get('conId')];
        If(siteProfileRecords.size() > 0)
        {
            if(mapOfparameters.get('conHistory') != null) 
            {
                navigateURL='http://meeting.eab.com/EntryPage.aspx?ContactID='+EncodingUtil.urlEncode(mapOfparameters.get('conHistory') , 'UTF-8');                
            }
        }
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Please create a Site Profile for this Contact so they can access electronic meeting materials while at the event. If you need assistance creating a Site Profile, please refer to the Box link here: https://advisory.box.com/Create-A-Site-Profile. If you experience any difficulty creating a Site Profile, please reach out to eabhelp@eab.com'));
        }
    }
    
    //Method for buttons redirecting to Page new case button object - case
    public void createNewCase()
    {
        String recordTypeId = Label.Case_WebHelp_RT_Id;
        String type = '';
        String endurl = '&save_new_url=%2F500%2Fe%3FretURL%3D%252F500%252Fo';
        String status = 'In Progress';
        String caseRecordType = ApexPages.currentPage().getParameters().get('caseRecordType');
        String cas28_lkid = ApexPages.currentPage().getParameters().get('cas28_lkid');
        String classic = ApexPages.currentPage().getParameters().get('classic');
        String cas28 = ApexPages.currentPage().getParameters().get('cas28');
        String cas21 = ApexPages.currentPage().getParameters().get('cas21');
        String ParentCaseNumber = ApexPages.currentPage().getParameters().get('ParentCaseNumber');
        String cas11 = ApexPages.currentPage().getParameters().get('cas11');
        String cas3_lkid = ApexPages.currentPage().getParameters().get('cas3_lkid');
        if(cas3_lkid == '' || cas3_lkid == null)
        {
            cas3_lkid ='';
        }
        String cas3 = ApexPages.currentPage().getParameters().get('cas3');
        if(caseRecordType == recordTypeId )
        {
            recordTypeId = Label.Case_eTech_Support_RT_Id;
            type = 'Application Support';
            
        }
        if( classic == 'true')
        {
            navigateURL ='/500/e?nooverride=1&cas28_lkid='+cas28_lkid+
                '&cas28='+cas28+'&cas21=1&ParentCaseNumber='+ParentCaseNumber+
                '&cas11='+cas11+'&cas3_lkid='+cas3_lkid+'&cas3='+cas3+
                '&RecordType=' +recordTypeId+ '&cas5=' +type+ '&cas7=' +status + endurl + '&retURL=/'+cas28_lkid;
        }
        else
        {
            navigateURL = '/apex/URLNavigator?operationtype=createRecord&recordTypeId='+recordTypeId+
                '&entityName=Case&fields=ParentId@~@Origin@~@ContactId@~@Type@~@Status&defaults='+cas28_lkid+'@~@'+'Outreach'+'@~@'
                +cas3_lkid+'@~@'+type+'@~@'+status+'&returnURL='+ApexPages.currentPage().getParameters().get('returnURL');
        }         
    }
    
    //Method for buttons redirecting to Page SBQQ_AmendContract
    public void pageSBQQ_AmendContract()
    {
        String recordId = ApexPages.currentPage().getParameters().get('Id');
        if(String.isNotBlank(recordId))
        {
            List<Contract> contracts = new List<Contract>([Select Id , EndDate, SBQQ__RenewalQuoted__c, StatusCode , 
                                                           Status 
                                                           FROM Contract 
                                                           where id=: recordId]);
            if(contracts.size() > 0) 
            {
                Contract con = contracts[0];   
                
                if(Date.today() > con.EndDate) 
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'Cannot amend if today is after the Contract End Date'));
                }
                else if (con.SBQQ__RenewalQuoted__c) 
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'Cannot Amend if the Renewal Proposed field is checked'));
                } 
                else if(con.StatusCode != 'Activated') 
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'Cannot Amend if the Contract is not activated'));
                } 
                else if(con.Status == 'Terminated' || con.Status == 'Expired') 
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'Cannot Amend if the Contract is Terminated or Expired'));
                }
                else 
                {
                    navigateURL = '/apex/SBQQ__AmendContract?id='+recordId;
                }
            }
            else 
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'Unable to access Contract record.'));    
            }
        }
    }
    
    //Method for button "Create Invoice Billing Sched" - Contract ABC
    public void createInvoiceBillingSched()
    {
        if(mapOfparameters.get('ibsID') != null && mapOfparameters.get('ibsID') != '')
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Contract is already linked to an Invoice Billing Schedule, you cannot create a new one for this contract.')); 
        }
        else
        {
            navigateURL = '/apex/AssociateContractABCWithInvoiceBilling?accountPayerId='+mapOfparameters.get('accountPayerId')+'&contractABCId='+mapOfparameters.get('contractABCId')+'&retURL=' +mapOfparameters.get('retURL');
        }
    }
    
    //Method for button "Create Invoice Billing Sched" - CPQ Subscription object
    public void createInvoiceBillingSchedSubscription()
    {
        if(mapOfparameters.get('ibsID') != null && mapOfparameters.get('ibsID') != '')
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Susbcription is already linked to an Invoice Billing Schedule, you cannot create a new one for this Susbcription.')); 
        }
        else
        {
            navigateURL = '/apex/AssociateContractABCWithInvoiceBilling?accountPayerId='+mapOfparameters.get('accountPayerId')+'&subscriptionId='+mapOfparameters.get('subscriptionId')+'&retURL=' +mapOfparameters.get('retURL');
        }
    }
    
    //Method for "Post" button - Cash Entries
    public void postOnCashEntries() 
    {
        Boolean hasCahEntryPostPermission = FeatureManagement.checkPermission('Cash_Entry_Post');
        Boolean hasABCFinancePermission = FeatureManagement.checkPermission('ABC_Finance');
        Boolean doWeNeedToCheckForCurrentUser = true;
        if (!hasCahEntryPostPermission) 
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'You do not have the permission to post this record.'));
        }
        else if(hasABCFinancePermission) 
        {
            navigateURL = '/apex/ffcash__cashentrypost?Id='+mapOfparameters.get('cashentryid');
            doWeNeedToCheckForCurrentUser = false;
        }
        String recordId = ApexPages.currentPage().getParameters().get('cashentryid');
        if(String.isNotBlank(recordId))
        {
            List<c2g__codaCashEntry__c> cashEntries = [Select Id, CreatedById, LastModifiedById 
                                                       FROM c2g__codaCashEntry__c 
                                                       WHERE id=: recordId];
            if(cashEntries.size() > 0) 
            {
                if(doWeNeedToCheckForCurrentUser) 
                {
                    if (cashEntries[0].CreatedById == UserInfo.getUserId())
                    {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'The creator cannot post this record.'));
                    }
                    else if (cashEntries[0].LastModifiedById == UserInfo.getUserId())
                    {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'The user who last edited this record cannot post this record.'));
                    }
                    else 
                    {
                        navigateURL = '/apex/ffcash__cashentrypost?Id='+mapOfparameters.get('cashentryid');
                    }        
                }
            } 
            else 
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'Unable to access Cash Entry record.'));
            }
        }
    }
    
    //Method for "Post" button - Sales Invoice object
    public void postOnSalesInvoice() 
    {
        Boolean hasSalesInvoicePostPermission = FeatureManagement.checkPermission('Sales_Invoice_Post');
        Boolean hasABCFinancePermission = FeatureManagement.checkPermission('ABC_Finance');
        Boolean doWeNeedToCheckForCurrentUser = true;
        if (!hasSalesInvoicePostPermission) 
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'You do not have the permission to post this record.'));
        }
        else if(hasABCFinancePermission) 
        {
            navigateURL = '/apex/c2g__codainvoiceconfirmpost?Id='+mapOfparameters.get('salesinvoiceid');
            doWeNeedToCheckForCurrentUser = false;
        }
        String recordId = ApexPages.currentPage().getParameters().get('salesinvoiceid');
        if(String.isNotBlank(recordId))
        {
            List<c2g__codaInvoice__c> salesInvoices = [Select Id, CreatedById, LastModifiedById 
                                                       FROM c2g__codaInvoice__c
                                                       WHERE id=: recordId];
            if(salesInvoices.size() > 0) 
            {
                if(doWeNeedToCheckForCurrentUser) 
                {
                    if (salesInvoices[0].CreatedById == UserInfo.getUserId())
                    {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'The creator cannot post this record.'));
                    }
                    else if (salesInvoices[0].LastModifiedById == UserInfo.getUserId())
                    {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'The user who last edited this record cannot post this record.'));
                    }
                    else 
                    {
                        navigateURL = '/apex/c2g__codainvoiceconfirmpost?Id='+mapOfparameters.get('salesinvoiceid');
                    }        
                }
            } 
            else 
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'Unable to access Sales Invoice record.'));
            }
        }
    }
    
    //Method for "Post" button - Payable Invoices
    public void postOnPayableInvoice()
    {
        Boolean hasPayableInvoicePostPermission = FeatureManagement.checkPermission('Payable_Invoice_Post');
        String recordId = ApexPages.currentPage().getParameters().get('payableinvoiceid');
        if(String.isNotBlank(recordId)) 
        {
            if (!hasPayableInvoicePostPermission) 
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'You do not have the permission to post this record.'));
            }
            else 
            {
                navigateURL = '/apex/PayableInvoiceValidation?Id='+mapOfparameters.get('payableinvoiceid');
            }        
        }
        else 
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'Unable to access Payable Invoice record.'));
        }
    }
    
    //Method for "Post" button - Sales Credit Note object
    public void postOnSalesCreditNote() 
    {
        Boolean hasPayableInvoicePostPermission = FeatureManagement.checkPermission('Sales_Credit_Note_Post');
        String recordId = ApexPages.currentPage().getParameters().get('salescreditnoteid');
        if(String.isNotBlank(recordId)) 
        {
            if (!hasPayableInvoicePostPermission) 
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'You do not have the permission to post this record.'));
            }
            else 
            {
                navigateURL = '/apex/SalesCreditNoteValidation?Id='+mapOfparameters.get('salescreditnoteid');
            }        
        }
        else 
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'Unable to access Sales Credit Note record.'));
        }
    }
    
    //Method for "Add Program Subscription" - CPQ Subscription object
    public void addProgramSubscription() 
    {
        String invoiceBillingScheduleId = ApexPages.currentPage().getParameters().get('invoicebillingscheduleid');
        String institutionId = ApexPages.currentPage().getParameters().get('institutionid');
        String institutionName = ApexPages.currentPage().getParameters().get('institutionname');
        if(String.isNotBlank(invoiceBillingScheduleId)) 
        {
            if(String.isNotBlank(institutionId)) 
            {
                List<SBQQ__Subscription__c> subscriptions = [SELECT ID FROM SBQQ__Subscription__c 
                                                             WHERE RecordType.DeveloperName = 'Program'
                                                             AND Invoice_Billing_Schedule__c = ''
                                                             AND SBQQ__Account__c =: institutionId];
                if(subscriptions.size() == 0) 
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'There are no Program Subscriptions for ' + institutionName + ' available to be linked to this Invoice Billing Schedule.'));    
                }
                else 
                {
                    navigateURL = '/apex/AddContractsToInvoiceBillingSchedule?id='+ invoiceBillingScheduleId + '&prosub=pSbutton';
                }
            }
            else 
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'Unable to access or find institution associated with invoice billing schedule.'));    
            }        
        }
        else 
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'Unable to access or find invoice billing schedule.'));
        }
    }
    
    //Method for "Log Outreach" button - Product Lead object
    public void logOutreach() 
    {
        String productLeadId = ApexPages.currentPage().getParameters().get('productleadid');
        if(String.isNotBlank(productLeadId)) 
        {
            List<Product_Lead__c> productLeads = [SELECT ID, Name, Contact__c, Contact__r.Name 
                                                  FROM Product_Lead__c
                                                  WHERE ID =: productLeadId
                                                 ];
            if(productLeads.size() > 0) 
            {
                //Sample - 10/31/2019
                String todaysDate = System.today().format();
                
                if(theme == 'Theme2' || theme == 'Theme3') 
                {
                    String objPrefix = Task.sObjecttype.getDescribe().getKeyPrefix();
                    navigateURL =  '/' + objPrefix + '/e';
                    navigateURL +=  '?retURL=' + productLeads[0].Id;
                    navigateURL +=  '&saveURL=' + productLeads[0].Id;
                    navigateURL +=  '&cancelURL=' + productLeads[0].Id;
                    navigateURL +=  '&tsk4=' + todaysDate;
                    navigateURL +=  '&tsk5=' + 'Call';
                    navigateURL +=  '&tsk12=' + 'Completed';
                    navigateURL +=  '&tsk2_lkid=' + productLeads[0].Contact__c;
                    navigateURL +=  '&tsk2=' + productLeads[0].Contact__r.Name;
                    navigateURL +=  '&tsk3_lkid=' + productLeads[0].Id;
                    navigateURL +=  '&tsk3=' + productLeads[0].Name;
                    navigateURL +=  '&RecordType=' + System.Label.Log_Outreach_Default_Record_Type_ID;
                    navigateURL += '&nooverride=1';
                }
                else 
                {
                    String formattedDateString;
                    if(todaysDate.split('/') != null && todaysDate.split('/').size() > 2) 
                    {
                        formattedDateString = todaysDate.split('/')[2] + '-' + todaysDate.split('/')[0] + '-' + todaysDate.split('/')[1];      
                    }
                    navigateURL = '/apex/URLNavigator?operationtype=createRecord&entityName=Task&recordTypeSelection=false';
                    navigateURL += '&recordTypeId=' + System.Label.Log_Outreach_Default_Record_Type_ID; 
                    navigateURL += '&fields=ActivityDate@~@Status@~@Subject@~@WhoId@~@WhatId';
                    navigateURL += '&defaults=' + formattedDateString + '@~@' + 'Completed' + '@~@' + 'Call' + '@~@' +  productLeads[0].Contact__c + '@~@' +  productLeads[0].ID;   
                    navigateURL += '&returnURL=' + productLeads[0].ID;        
                }
            }
            else 
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'Unable to access or find product lead.'));
            }
        }
        
    }
}