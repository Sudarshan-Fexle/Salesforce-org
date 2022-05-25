/**
*  Description     :   Class to download the vf page as doc file. 
*
*  Created By      :   Dipesh Gupta  
* 
*  Created Date    :   05/10/2020
* 
*  Revision Logs   :   V_1.0 - Created - CR-20190702-13205
		   :   V1.1 - Modified - Abhinav Sharma - 08/12/2020 - CR-20190826-13286 - MS 2: Change to Pending Future Start Date value
**/
public class TripPrepReportController {
    
    private ApexPages.StandardController standardController;
    public Event event{get;set;}
    public List<Account> accountList{get;set;}
    public List<Contact> contactList{get;set;}
    public List<Membership__c> membershipList{get;set;}
    public List<Opportunity> opportunityList{get;set;}
    public List<Opportunity> oppPastEvaluationsList{get;set;} 
    public List<Opportunity> oppList{get;set;}
    public List<Event> eventList{get;set;}
    public Boolean isdownloadReport{get;set;}
        
    public TripPrepReportController(ApexPages.StandardController stdController){
        accountList = new List<Account>();
        contactList = new List<Contact>();
        membershipList = new List<Membership__c>();
        oppList = new List<Opportunity>();
        oppPastEvaluationsList = new List<Opportunity>();
        event = new Event();
        isdownloadReport = false;
        this.standardController = stdController;
        this.event = (Event)standardController.getRecord();
        //Id eventrcdId = apexpages.currentpage().getparameters().get('Id');
        eventList = [Select Id,whoId,What.Type,What.Name,StartDateTime From Event where Id =:  this.event.Id Limit 1];
        generateReportData();
    }
	 public String getPrintView()
    {
        return
        '<!--[if gte mso 9]>' +
            '<xml>' +
            '<w:WordDocument>' +
            '<w:View>Print</w:View>' +
            '<w:Zoom>130</w:Zoom>' +
            '<w:DoNotOptimizeForBrowser/>' +
            '</w:WordDocument>' +
            '</xml>' +
            '<![endif]>';
        }
    
    
    public pageReference generateReportData(){
        set<String> setOfStageName = new set<String>{'0-Exploring','1-Considering','2-Evaluating','3-Confirming','4-Selected','5-Closing'};
         // Modified - Abhinav Sharma - 08/12/2020 - CR-20190826-13286 - Change value from "Prospect - Pending Future Start Date" to "Member - Pending Future Start Date".
	set<String> setOfMembershipStatus = new set<String>{'Member - Payer','Member - Integrated','Member - Integrated (Global)',
                                                            'Member - Integrated (Grace)','Member - Honorary','Member - Honorary (Grace)',
                                                            'Member - Payer (Grace)','Prospect - Past Member','Prospect - Recent Drop',
                                                            'Member - Pending Future Start Date'};
        List<String> listOfOppProducts = new List<String>();
      
        if(eventList.size() > 0){
            contactList = [Select Id,Name,Email,Phone,Account.Name FROM contact where Id =: eventList[0].WhoId];
            if(eventList[0].What.Type == 'opportunity'){
                
                isdownloadReport = true;
                
                oppList = [Select Id,Name,AccountId, Account.Name,Opportunity_Products__c From Opportunity where id =: eventList[0].WhatId LIMIT 1];
                
                
                if(oppList.size() > 0 && oppList[0].AccountId  != null){
                    //listOfOppProducts = (oppList[0].Opportunity_Products__c).split(';');
                    
                    if(String.isNotBlank(oppList[0].Opportunity_Products__c)){
                        if(oppList[0].Opportunity_Products__c.contains(';')){
                            for(String product : (oppList[0].Opportunity_Products__c).split(';')){
                                listOfOppProducts.add('%'+product+'%');
                            } 
                        }
                        else{
                           listOfOppProducts.add('%'+oppList[0].Opportunity_Products__c+'%'); 
                        }
                        
                    }
                    
                    accountList = [Select Id,Name,Enrollment_Contract_Value__c,Core_Contract_Value__c,
                                   Tech_Current_Period_Value_Rolled_Up__c,Active_RI_Memberships__c,Active_PT_Memberships__c,
                                   Active_ES_Memberships__c,Research_Strategic_Leader__r.Name,Student_Success_Strategic_Leader__r.Name,
                                   Enrollment_Undergrad_Strategic_Leader__r.Name,Advancement_Strategic_Leader__r.Name,Adult_Learner_Strategic_Leader__r.Name,
                                   r_Account_FA__c,Operating_Expense_In_Thousands__c,Students__c,r_UG_Enrollment__c,r_Grad_Enrollment__c,
                                   X6_Year_Graduation_Rate__c,Retention_Rate__c,Acceptance_Rate__c,Carnegie_Classification__c,Structure__c,
                                   Religious_Affiliation__c,Total_Contract_Value__c,Strategic_Account_Segment__c From Account where Id =: oppList[0].AccountId];   
                
            
                membershipList = [Select Id,Program_Acronym__c,Membership_Status__c,Join_Date_Earliest__c,End_Date_on_Last_Contract__c,
                                  Current_Year_Annual_Contribution__c,Active_Contract_Main_Contact__c,Active_Contract_Main_Contact__r.Title, 
                                  Active_Contract_Main_Contact__r.Name,Account_Name__r.Name FROM Membership__c 
                                  where Account_Name__c =: oppList[0].AccountId
                                  AND Membership_Status__c IN: setOfMembershipStatus ORDER BY Membership_Status__c ASC];
           
            
            oppPastEvaluationsList = [Select Marketer__r.Name,Main_Contact__r.Name,Main_Contact__r.title,Initial_Activity_Date__c,
                               Calculated_Close_Date__c,Primary_Reason_Lost__c,Closed_Opp_Comments__c
                               From Opportunity where AccountId =:  oppList[0].AccountId
                               AND StageName = 'Closed Lost' AND Opportunity_Products__c like : listOfOppProducts 
                               AND (RecordType.Name = 'EAB Initiating' OR RecordType.Name = 'Royall') ORDER BY Calculated_Close_Date__c DESC];
            
            opportunityList = [Select Marketer__r.Name,Opportunity_Products__c,Main_Contact__r.Name,Main_Contact__r.title,
                                Initial_Activity_Date__c,Next_PA_Date__c,StageName,Probability,CloseDate 
                                From Opportunity WHERE AccountId =:  oppList[0].AccountId
                                AND StageName IN: setOfStageName AND (RecordType.Name = 'EAB Initiating' OR RecordType.Name = 'Royall')];
                               
            
          
                }
            }
        }
        else{
            isdownloadReport = false;
        }
     //PageReference pageRef = new PageReference('/'+event.Id);
     return null;
        
    }
   
}