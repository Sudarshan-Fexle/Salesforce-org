/**
 *  Description     :   Controller class to have logic of VF page that will apply the logic to process the NBB records
 *
 *  Created By      :   
 *
 *  Created Date    :   12/12/2015
 *
 *  Current Version :   V_1.0
 *
 *  Revision Logs   :   V_1.0 - Created
 * 						V_1.1 - Modified by - Mahendra Swarnakar -12/22/2016 - CR-20161129-10504 
 *
 **/
public with sharing class MassNBBUpsertController {
    
    //Useful variables 
    Opportunity opportunity;
    public List<NBB__c> nbbList {get; set;}
    
    //Constructor
    public MassNBBUpsertController(Apexpages.StandardController sc) { 
        
        //Memory Allocation
        nbbList = new List<NBB__c>();
        
        //Get URL parameter
        String opportunityId = ApexPages.currentPage().getParameters().get('oppoutunityId');
        
        List<Opportunity> opps = [Select Id, Name, Account.Name, Marketer__c, Program__c, Program_Acronym__c from Opportunity where Id =: opportunityId];
        
        if(opps.size() > 0)
            opportunity = opps[0];
        
        // Added by - Mahendra Swarnakar -12/22/2016 - CR-20161129-10504 - Added new field in query
        //Pull the existing NBB records if any
        nbbList = [Select Id, Name, Opportunity__c, Marketer__c, Program__c, Unit__c, NBB__c, NBB_Type__c, Comments__c, Sales_Role__c, Upsell__c, Shadow_Credit_Type__c, Binder_Date__c, NA_Date__c, ATL_Date__c, SA_EA_Date__c, Profit__c, X1st_Year_Revenue__c from NBB__c where Opportunity__c =: opportunity.Id];
        
        // Loop to add 10 new default rows for add NBB records in list
        for(Integer i=1 ; i<=10 ; i++){
    
            nbbList.add(new NBB__c(Name = 'NBB - ' + opportunity.Account.Name + ' - ' + opportunity.Program_Acronym__c + ' - ' + UserInfo.getLastName(), Opportunity__c = opportunity.Id, Program__c = opportunity.Program__c, Marketer__c = opportunity.Marketer__c));
        }
    }
    
    /**
     *  @description    :   Method to perform logic of addNewNBB Button on page.
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     **/
    public void addNewNBB() {
        
        //Add a new NBB
        nbbList.add(new NBB__c(Name = 'NBB - ' + opportunity.Account.Name + ' - ' + opportunity.Program_Acronym__c + ' - ' + UserInfo.getLastName(), Opportunity__c = opportunity.Id, Program__c = opportunity.Program__c, Marketer__c = opportunity.Marketer__c, Unit__c = 1, Binder_Date__c = Date.today(), NA_Date__c = Date.today(), ATL_Date__c = Date.today(), SA_EA_Date__c = Date.today()));
    }
    
    /**
     *  @description    :   Usert the NBB records
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     **/
    public Pagereference doSave() {
        
        //Savepoint
        Savepoint sp = database.setSavepoint();
        
        //Exception handling
        try {
            
            //Create a list if records to be upserted
            List<NBB__c> upsertNBBList = new List<NBB__c>();
            
            //Error row count
            Integer i = 1;
            
            //Loop through the nbbList
            for(NBB__c nbb : nbbList){
                System.debug('##########' +opportunity.Marketer__c + nbb.Marketer__c);
                System.debug('##########' +opportunity.Program__c + nbb.Program__c);
                //Check if any of the row is incomplete
                //After clicking on the Save button, check if any of the required field is missing in any row but any other data is populated, 
                //throw the error message on screen with the row# and error message. 
                //Skip the row where no data is populated. Once data is corrected and upsert(insert/update) the remaining NBB records. 
                //Stamp the same opportunity on NBB where it came from. 
                //User requiredMark css from Salesforce to display the required mark on page instead of required attribute. 
                //So it doesn?t fire validation from each row.
                if((String.isNotBlank(nbb.Name) 
                        && nbb.Unit__c != null 
                        && nbb.NBB__c != null 
                        && nbb.Binder_Date__c != null 
                        && nbb.NA_Date__c != null
                   		&& nbb.Profit__c != null
                   		&& nbb.X1st_Year_Revenue__c != null
                   		&& String.isNotBlank(nbb.NBB_Type__c))){
                    
                    //Add in list to be upserted
                    upsertNBBList.add(nbb);
                }
                else if((nbb.NBB__c != null
                            || nbb.Marketer__c != opportunity.Marketer__c //Changed from default value
                            || nbb.Program__c != opportunity.Program__c //Changed from default value
                            || nbb.Unit__c != 1 //Changed from default value
                            //|| String.isNotBlank(nbb.NBB_Type__c)  //Commented, so that we can throw the Error message when NBB Type is blank - By Mahendra Swarnkar - CR-20161129-10504 - 12/27/2016 - As per the UAT change
                         	|| String.isNotBlank(nbb.Comments__c) 
                            || String.isNotBlank(nbb.Sales_Role__c) || nbb.Upsell__c == true 
                            || String.isNotBlank(nbb.Shadow_Credit_Type__c)
                            || nbb.Binder_Date__c != Date.today() //Changed from default value
                            || nbb.NA_Date__c != Date.today() //Changed from default value
                            || nbb.ATL_Date__c != Date.today() //Changed from default value
                            || nbb.SA_EA_Date__c != Date.today()
                            || nbb.Id != null) //Changed from default value
                        && (String.isBlank(nbb.Name) || nbb.Unit__c == null || nbb.NBB__c == null 
                            || nbb.Binder_Date__c == null || nbb.NA_Date__c == null || nbb.Profit__c == null || nbb.X1st_Year_Revenue__c == null
                            || String.isBlank(nbb.NBB_Type__c))
                        ){    
                    //Error    
                    ApexPages.Message msg = new Apexpages.Message(ApexPages.Severity.ERROR,'Require field(s) missing on Row# ' + i);
                    Apexpages.addMessage(msg);
                }
                i++;
            }
            
            //Check for the errors
            if(ApexPages.hasMessages(ApexPages.Severity.ERROR))
                return null;
            
            //check if there are records to process
            if(upsertNBBList.size() > 0)
                upsert upsertNBBList;
           
           return new PageReference('/' + opportunity.Id);
        
        } catch (Exception e) {
            
            //Rollback teh entire transaction in case of exception
            database.rollback(sp);  
            
            //Add error on page
            ApexPages.addMessages(e);
        }
       return null;
    }
    
     /**
     *  @description    :   Cancel
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     **/
    public PageReference doCancel() {
        
        //Redirect to opporutnity page
        return new PageReference('/' + opportunity.Id);
    }
}