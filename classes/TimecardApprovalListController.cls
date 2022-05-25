/**
 *  Description     :   Apex class to hold methods associated with Timecard List Views
 * 
 *  Created By      :   Colin McGloin    
 * 
 *  Created Date    :   12/03/2018
 * 
 *  Revision Logs   :   V_1.0 - Created
 *
**/
public class TimecardApprovalListController 
{
    ApexPages.StandardSetController stdController;
    List<pse__Timecard_Header__c> selectedTimecardRecords;
    PageReference pgref;
    private String baseURL;
    String listViewId;
    String currentTheme;
    
    public TimecardApprovalListController(ApexPages.StandardSetController stdController) 
    {
        this.stdController = stdController;
        this.baseURL = URL.getSalesforceBaseUrl().toExternalForm();
        this.selectedTimecardRecords = new List<pse__Timecard_Header__c>();
        listViewId = stdController.getFilterId(); 
        currentTheme = UserInfo.getUiThemeDisplayed();
    }
    
    public PageReference validateApprovalList() 
    {
        //Check to make sure a Timecard record was selected
        if (this.stdController.getSelected().size() == 0) 
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'No records selected. Please select at least one record to approve.'));
        }
        else 
        {
            //get our original Page Address
            String retURL = ApexPages.currentPage().getParameters().get('retURL');
            
            //Get our selected records
            selectedTimecardRecords = stdController.getSelected();
            
            //Pass our selected records to the Bulk Approving process
            PSEUtilities.bulkApproveTimecardRecords(selectedTimecardRecords);
            
            //Bypass during test
            if (!Test.isRunningTest())
            {
                //Create our PageReference
                if(String.isNotBlank(retURL)) 
                {
                    pgref = new PageReference(retURL);
                    pgref.setRedirect(true);    
                }
                
                if(currentTheme == 'Theme4d' || currentTheme == 'Theme4t') 
                {
                    if(String.isNotBlank(listViewId)) 
                    {
                        String navigateURL = '/apex/URLNavigator?operationtype=navigatetolist&listViewId=' + listViewId + '&scope=pse__Timecard_Header__c';
                        pgref = new PageReference(navigateURL);
                        return pgref;     
                    }
                }
            }
        }
        
        //Return our redirect
        return pgref;
    }
    
    //Method for going back if the user gets the error message
    public PageReference back() 
    {
        return stdController.cancel();
    }
}