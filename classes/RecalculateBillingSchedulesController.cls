/**
*  Description     :  Controller class to recalculate the Billing Schedule Header, Billing Schedule Periods and Billing Schedule Lines.
*
*  Created By      :  Mahendra Swarnkar
*
*  Created Date    :  11/21/2019
*
*/
public class RecalculateBillingSchedulesController {
    
    //Variables
    public Billing_Schedule_Header__c billingScheduleHeader { get; set; }
    
    /**
     * 
     *  @description    :   Constructor
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - 11/21/2019 - Created - Mahendra Swarnkar
     * 
     **/
    public RecalculateBillingSchedulesController() {
        
        //get the contract id
        Id billingScheduleHeaderId = System.currentPageReference().getParameters().get('id');
        
        //get the Billing schedule record
        list<Billing_Schedule_Header__c> listBillingScheduleHeader = [SELECT Id, Name, Standard_Contract__c, Invoicing_Arrangement__c, Status__c, Invoice_Contact__c, Enrollment_Services_Product__c, YouVisit_Product__c FROM Billing_Schedule_Header__c WHERE Id = :billingScheduleHeaderId ];
        
        //Check for size and populate the instance
        if (listBillingScheduleHeader.size() > 0) 
            billingScheduleHeader = listBillingScheduleHeader[0];
        else 
            throw new customException('No Billing Schedule Header exists with ID \'' + billingScheduleHeaderId + '\'');
    }
    
    /**
     * 
     *  @description    :   update the Renewal Proposed field on Contract to true.
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - 08/07/2017 - Created - Victor Hanson - Issue--CR11106--UAT--00005359
     * 
     **/
    public void recalculateBillingSchedules() {
        
        try {
            
            //Check for contract on the Billing schedule Header
            if( billingScheduleHeader.Standard_Contract__c != null) {
                
                BillingScheduleUtilities.recalculateCreateBillingSchedulePeriodsFromBSH(billingScheduleHeader);
                
                //Once recalculation is complete update the Billing header status to 
                billingScheduleHeader.Status__c = 'Record In Sync';
                
                util.BypassAllTriggers = true;
                update billingScheduleHeader;
                util.BypassAllTriggers = false;
                
                
                //add success message to page
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'Billing Schedule periods/lines has been recalculated'));
            
            } else {
                //add error message to page
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'Please populate the Standard Contract on the Billing Schedule Header to perform the recalculation for this Billing Schedule Header'));
            }
        }
        catch(exception e) {
            
            //if there was an exception (most likely validation related), display it on the page
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
        }
    }
    
    

}