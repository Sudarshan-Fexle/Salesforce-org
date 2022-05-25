/**
    Description   :   Controller class to have controller logic for "Add/Edit Staff" button on Staff Assignment object.
    Created By    :   Saurabh Kumar
    Created Date  :   10/07/2020
    Version       :   V1.0 Created - CR-20200821-14455
**/ 
public class AddEditStaffAssignmentsController 
{
    public Id eabEventId {get; set;}
    private ApexPages.StandardSetController standardController;
    
    //To set EAB Event Id from VF Page
    public AddEditStaffAssignmentsController(ApexPages.StandardSetController standardController)
    {
        this.standardController = standardController;
        this.eabEventId = ApexPages.currentPage().getParameters().get('id');   
    }
}