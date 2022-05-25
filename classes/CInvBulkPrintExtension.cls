/*
 * FinancialForce.com, inc. claims copyright in this software, its screen display designs and 
 * supporting documentation. FinancialForce and FinancialForce.com are trademarks of FinancialForce.com, inc. 
 * Any unauthorized use, copying or sale of the above may constitute an infringement of copyright and may 
 * result in criminal or other legal proceedings. 
 *
 * Copyright FinancialForce.com, inc. All rights reserved.
 */
public with sharing class CInvBulkPrintExtension {
    public ApexPages.StandardSetController controller;
    public CInvBulkPrintExtension(ApexPages.StandardSetController controller) 
    {
        this.controller = controller;   
    }
    
    public PageReference ContinuePrinting()
    {
        ffps_advisory.CInvBulkPrintController handler = new ffps_advisory.CInvBulkPrintController(controller);
        handler.setStatusToPrinted();
        return new PageReference('/apex/consolidatedinvoicebulkprint');
    }
}