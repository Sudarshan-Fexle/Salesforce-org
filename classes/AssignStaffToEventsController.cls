/**
    Description   :   Controller class to have controller logic for "Assign Staff ToEvents" button on Staff Assignment object.
    Created By    :   Saurabh Kumar
    Created Date  :   10/07/2020
    Version       :   V1.0 Created - CR-20200821-14455
**/ 
public class AssignStaffToEventsController 
{
    //To hold EAB Event Id that is coming from selected detail page record
    public Id eabEventId {get; set;}
    private ApexPages.StandardSetController standardController;
    //To enable/disable component loading
    public Boolean loadAssignStaffToEventsComponent {get; set;}
    //To hold selected Staff Assignment record Ids
    public String selectedStaffAssignmentIds {get; set;}
    public Boolean backButtonShow {get; set;}
    
    //To set EAB Event Id from VF Page, disable Component loading
    public AssignStaffToEventsController(ApexPages.StandardSetController standardController)
    {
        this.standardController = standardController;
        this.eabEventId = ApexPages.currentPage().getParameters().get('id');  
        loadAssignStaffToEventsComponent = false;
        selectedStaffAssignmentIds = '';
        backButtonShow = true;
    }
    
    /* 
    *	Description     :	This method is used to load AssignStaffToEvents LWC and passing selected Staff Assignment records.
    *
    *	@argument	:	
    *   
    *   return type     :   	PageReference
    * 
    *	Revision Logs   : 	V_1.0 - Created
    */
    public PageReference loadAssignStaffToEventsLWCWithSelectedSARecords() 
    { 
        try 
        {
            //To hold set of staff Assignmnent Ids
            String staffAssignmentIds = '';
            List<Team_Membership__c> staffAssignmentsList = (List<Team_Membership__c>)standardController.getSelected();
            if(staffAssignmentsList.size() > 0)
            {
                //To fill set of Staff Assignment Ids
                for(Team_Membership__c staffAssignment : staffAssignmentsList){
                    staffAssignmentIds+=staffAssignment.Id+'-';
                }
                staffAssignmentIds = staffAssignmentIds.removeEnd('-');
                selectedStaffAssignmentIds = staffAssignmentIds;
                //To enable Component Loading
                loadAssignStaffToEventsComponent = true;
                backButtonShow = false;
                return null;
            }
            else
            {
                //Throw error in case of no Staff Assignment record selection
                //Disable Component Loading
                loadAssignStaffToEventsComponent = false;
                backButtonShow = true;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, System.Label.ERROR_RECORD_SELECTION));   
            	return null;
            }
        }
        catch(DmlException e) 
        {
            //Throw error If any
            //Disable Component Loading
            loadAssignStaffToEventsComponent = false;
            backButtonShow = true;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
            return null;
        }
    }
    
    /* 
    *	Description     :	This method is used to navigate to detail page record if no Staff Assignment record selected.
    *
    *	@argument	:	
    *   
    *   return type     :   	PageReference
    * 
    *	Revision Logs   : 	V_1.0 - Created
    */
    public pageReference back() 
    {   
        PageReference pg = new PageReference('/' + eabEventId);
        pg.setRedirect(true);
        return pg;  
    }   
}