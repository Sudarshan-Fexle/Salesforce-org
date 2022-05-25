/**
 *  Purpose            :    Constants class to hold all the constants properties for Revenue Management system    
 *
 *  Created By         :    Subhash Garhwal
 *
 *  Created Date       :    02/07/2017
 *
 *  Revision Log       :    V_1.0 - Created - CR-20161102-10316 - Revenue Management
 *                                         
 **/
public class RMConstants {
    
    //Variables
    public final static String ABC_REVENUE_NO_ACCESS = 'NO';
    public final static String ABC_REVENUE_READ_ACCESS = 'READ';
    public final static String ABC_REVENUE_CREATE_ACCESS = 'CREATE';
    public final static String ABC_REVENUE_OBJECT = 'ABC_Revenue__c';
    public final static String CONTRACT_ABC_FIXED_TERM = 'Fixed Term';
    public final static String ABC_REVENUE_LINE_STATUS_DRAFT = 'Draft';
    public final static String ABC_REVENUE_FEE_TYPE_SETUP = 'Setup_Implementation';
    public final static String ABC_REVENUE_FEE_TYPE_ANNUAL = 'Annual - Program';
    public final static String REVENUE_MANAGEMENT_PAGE_VIEW_MODE_REVIEW = 'Review';
    public final static String REVENUE_MANAGEMENT_PAGE_VIEW_MODE_MANAGE = 'Manage';
    public final static String ABC_REVENUE_LINE_STATUS_PENDING = 'Pending';
    public final static String ABC_REVENUE_RISK_TYPE_NONE = 'None';
    public final static String ABC_REVENUE_RISK_TYPE_COMPLETE = 'Complete';
    public final static String ABC_REVENUE_RISK_TYPE_BLANK = '';
    public final static String ABC_REVENUE_RISK_TYPE_PENDING = 'Pending';
    public final static String ABC_REVENUE_RISK_TYPE_WRITE_OFF = 'Write-Off';
    public final static String ABC_REVENUE_RISK_TYPE_DROPPED = 'Dropped';
    public final static String ABC_REVENUE_RECORD_TYPE_CONTRACT_ABC = 'Contract_ABC';
    public final static String ABC_REVENUE_RECORD_TYPE_STANDARD_CONTRACT = 'Standard_Contract'; 
    
    //Added by Colin McGloin - CR-20170418-10859
    public final static String ABC_REVENUE_ADMIN = 'System Administrator';
    public final static String ABC_REVENUE_ABC_DATALOADER = 'ABC Dataloader';
    
    //Contract ABC object API Name string
    public final static String CONTRACT_ABC_OBJ_API_NAME = 'Contract__c';
    public final static String CONTRACT_ABC_OBJ_API_NAME_LOWERCASE = 'contract__c';    
    
    //SBQQ Subscription object API Name string
    public final static String CPQ_SUBSCRIPTION_OBJ_API_NAME = 'SBQQ__Subscription__c';
    public final static String CPQ_SUBSCRIPTION_OBJ_API_NAME_LOWERCASE = 'sbqq__subscription__c';
    
    //Standard Contract Object API Names string - Added by Abhinav Sharma -12/03/2018 - CR-20180918-12607
    public final static String STANDARD_Contract_OBJ_API_NAME = 'Contract';
    public final static String STANDARD_Contract_OBJ_API_NAME_LOWERCASE = 'contract'; 
    
    //URL parameter "parentid"
    public final static String URL_PARAM_PARENTID = 'parentid';
    
    //Select Option list to provide operation options to user
    public final static List<SelectOption> OPERATION_OPTIONS = new List<SelectOption>{new SelectOption('', '--None--'), new SelectOption('Add Blank Lines', 'Add Blank Lines'),new SelectOption('Copy Selected Lines', 'Copy Selected Lines'),
                                                                                      new SelectOption('Clone from Contract ABC', 'Clone from Contract ABC'), new SelectOption('Generate from Contract', 'Generate from Contract'),
                                                                                      new SelectOption('Mass Edit Lines', 'Mass Edit Lines')};
                                                                                          
    public final static List<SelectOption> OPERATION_OPTIONS_SUBSCRIPTIONS = new List<SelectOption>{new SelectOption('', '--None--'), new SelectOption('Add Blank Lines', 'Add Blank Lines'),new SelectOption('Copy Selected Lines', 'Copy Selected Lines'),
                                                                                      new SelectOption('Clone from Program Subscription', 'Clone from Program Subscription'), new SelectOption('Generate from Program Subscription', 'Generate from Program Subscription'),
                                                                                      new SelectOption('Mass Edit Lines', 'Mass Edit Lines')};                                                                                      

    //Standard Contract Object API Names string - Added by Abhinav Sharma -12/03/2018 - CR-20180918-12607
	public final static List<SelectOption> OPERATION_OPTIONS_STANDARD_CONTRACT = new List<SelectOption>{new SelectOption('Generate from Contract', 'Generate from Contract')};                                                                                         
        
 }