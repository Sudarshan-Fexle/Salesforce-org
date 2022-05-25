public without sharing class RevenueManagementRedirectExt {
    
    //Declare our ABC Revenue record
    public ABC_Revenue__c revenue {get; set;}
    public List<ABC_Revenue__c> revenueRecords {get; set;}
    public Id parentId {get; set;}
	
    public RevenueManagementRedirectExt(ApexPages.standardController stdController) {
        
        //Grab our Parent Id to be used on Revenue Management Page
        revenue = (ABC_Revenue__c) stdController.getRecord();

        //Query for the fields we need for our Navigation Logic
        revenue = [SELECT Id, Program_Subscription__c, Contract_ABC__c FROM ABC_Revenue__c WHERE Id = :revenue.Id];
       
    }

    public RevenueManagementRedirectExt(ApexPages.standardSetController stdController) {

        //Grab our Parent Id to be used on Revenue Management Page
        parentId = ApexPages.currentPage().getParameters().get('id');

    }
    
    public pageReference redirectFromParent () {

        //Redirect to the Revenue Management VF Page
        PageReference redirect = new PageReference('/apex/RevenueManagement?parentid=' + parentId);
        redirect.setRedirect(true);
        return redirect;
        
    }

    public pageReference redirect () {

        if (revenue.Program_Subscription__c != null){
            //Redirect to the Revenue Management VF Page
            PageReference redirect = new PageReference('/apex/RevenueManagement?parentid=' + revenue.Program_Subscription__c);
            redirect.setRedirect(true);
            return redirect;
        }
        else {
            //Redirect to the Revenue Management VF Page
            PageReference redirect = new PageReference('/apex/RevenueManagement?parentid=' + revenue.Contract_ABC__c);
            redirect.setRedirect(true);
            return redirect;
        }
        
    }

}