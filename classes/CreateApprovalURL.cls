/**
*   Description     :  This Controller is used to get Approval Record Link on the Template
*
*   Created by      :  Abhinav Sharma
*
*   Created Date    :  16/07/2020
*
*   Revision Log    :  V_1.0 - Created - 16/07/2020 Abhinav Sharma
*/
public class CreateApprovalURL {
    public String caseID {get; set;}  
    
    public String urlStr
    {  
        get  {  
            return CreateApprovalURL.generateApprovalURL(caseID);  
        }
    }
    
    private static String generateApprovalURL(String recordID)  {  
        String url='';  
        
        List<ProcessInstanceWorkitem> workItemLst =   
            [SELECT id  FROM ProcessInstanceWorkitem  
             WHERE processInstance.TargetObjectId=:recordID];   
        
        if(workItemLst.size() > 0)  {  
            
            url='https://'+ System.URL.getSalesforceBaseUrl().getHost() +   
                '/p/process/ProcessInstanceWorkitemWizardStageManager?id=' + workItemLst[0].id;      
        }  
        return url;  
    }  
}