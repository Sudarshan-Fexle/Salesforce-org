/**
*  Description     :    This controller is used to create the PrintMIS Catalyst Test Data.
*
*  Created By      :    Chirag Soni   
* 
*  Created Date    :    09/22/2021
* 
*  Revision Logs   :    V_1.0 - Created - 09/22/2021 - CR-20210909-15418 - PrintMIS Catalyst Test Data Create Utility 
*
*/
public class CatalystDataUtilityPrintMISController {
    
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
                
                CatalystPrintDataUtilityWrapper deserializePrintDataWrap = (CatalystPrintDataUtilityWrapper)System.JSON.deserialize(jsonData, CatalystPrintDataUtilityWrapper.class);
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
                        String apexJobName = System.Label.Catalyst_Utility_PrintMIS_Schedule_Class_Name + ' ' + dateTime.now()+' '+math.random();
                        Sched_CreateCatalystTestData sched_Job = new Sched_CreateCatalystTestData(deserializePrintDataWrap);
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
}