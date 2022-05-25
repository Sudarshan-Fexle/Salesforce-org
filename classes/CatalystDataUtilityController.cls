/**
*  Description     :    This controller is used to create the OE/BRE Test Data.
*
*  Created By      :    Shalu Sharma   
* 
*  Created Date    :    09/07/2021
* 
*  Revision Logs   :    V_1.0 - Created - 09/07/2021 - CR-20210901-15400 - PrintMIS OE/BRE Test Data Create Utility 
*
*/
public without sharing class CatalystDataUtilityController 
{
    @AuraEnabled(cacheable=false)
    public static LightningResponseEntity createData(String jsonData) 
    {
        LightningResponseEntity res = new LightningResponseEntity();
        try 
        {
            if(Util.IS_PRODUCTION_INSTANCE){
               Throw new CustomException(System.Label.Message_For_Restricting_User_In_Prod); 
            }
            if(String.isNotBlank(jsonData) )
            {
                Set<String> setOfContactsEmails = new Set<String>();
                List<String> listOfContactsEmails = new List<String>();
                
                PrintDataUtilityWrapper deserializePrintDataWrap = (PrintDataUtilityWrapper)System.JSON.deserialize(jsonData, PrintDataUtilityWrapper.class);
                if(deserializePrintDataWrap != null)
                {
                    for(Contact cont : [SELECT Id, Email FROM Contact WHERE (Id IN : deserializePrintDataWrap.emailList) OR (EAB_com_Site_Profile__c IN : deserializePrintDataWrap.emailList)])
                    {
                        setOfContactsEmails.add(cont.Email);   
                    }
                    if(setOfContactsEmails.size() > 0)
                    {
                        listOfContactsEmails.addAll(setOfContactsEmails);
                        deserializePrintDataWrap.emailList = listOfContactsEmails;
                        
                        DateTime sysTime = dateTime.now().addSeconds(Integer.valueOf(System.label.Catalyst_Data_Utility_Delay_in_Seconds));
                        String cronExpr = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
                        String apexJobName = System.Label.Catalyst_Utility_Schedule_Class_Name + ' ' + dateTime.now()+' '+math.random();
                        Sched_CreateDevSBRecord sched_Job = new Sched_CreateDevSBRecord(deserializePrintDataWrap);
                        System.schedule(apexJobName , cronExpr , sched_Job);
                        
                        res.setBody(deserializePrintDataWrap);
                        return res;
                    }
                    else
                    {
                        res.setMessage(System.Label.Message_For_Contact_Recipient);
                        res.setSuccess(true);
                        return res;
                    }
                }
                else
                {
                    res.setError(System.Label.Invalid_Json_Body);  
                    return res; 
                }
            }
            else
            {
                res.setError(System.Label.Parameter_Can_Not_Null);  
                return res;
            }
        }
        catch (Exception e) 
        {
            res.setError(e.getMessage());
            return res;
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static Boolean IS_PRODUCTION_INSTANCE() 
    {
        Boolean IS_PRODUCTION_INSTANCE1;
        //Checking for the null value
        if(IS_PRODUCTION_INSTANCE1 == null) {
            
            //Setting flag value to false
            IS_PRODUCTION_INSTANCE1 = false;
            
            //Fetching organization related details
            List<Organization> organizations = [SELECT Id, IsSandbox  
                                                FROM Organization 
                                                LIMIT 1];
            
            //Checking for the list size and value
            if(organizations != null 
               && organizations.size() > 0 
               && organizations[0].IsSandbox == false)
                IS_PRODUCTION_INSTANCE1 = true;   
            
        }
        
        //Return value
        return IS_PRODUCTION_INSTANCE1;
    }
}