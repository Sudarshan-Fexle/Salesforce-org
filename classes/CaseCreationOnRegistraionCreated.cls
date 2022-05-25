/**
 *  Description     :   This call will create a new case record of "Member & Employee Support" type on certain field value updates on the 
 *                      Registration record(s).
 * 
 *  Created By      :   Abhinav Sharma   
 * 
 *  Created Date    :   03/16/2017
 * 
 *  Revision Logs   :   V_1.0 - Created - CR-20161201-10516
 *                      V_1.1 - Modified By - Mahendra Swarnakar - 11/29/2017 - CR-20171128-11820 - Updated the method "createNewCaseOnRegistrationChanges" to populate the Site field on the case 
 *                              and remove the code logic to populate the Owner field on the case. 
 *                      V_1.2 - Modified by Mahendra Swarnkar - 02/12/2020 - CR-20200121-13646
 *                      V_1.3 - Modified by Saurabh Kumar - 10/09/2020 - CR-20200819-14447: Removed Meeting reference from createNewCaseOnRegistrationChanges() method.
 *                                                                      
 **/
public class CaseCreationOnRegistraionCreated {
    
    //Added By - Abhinav Sharma - CR-20161201-10516 - 03/16/2017
    /**
     *  @description    :   This method is to:-
     *                          Create Case when Legacy Registration ID (Legacy_Registration_Id__c) is updated from Null to a value 
     *                              and the Origin = Microsite
     *                          Case record type = Member & Employee Support
     *                          Case subject = “Registration requested - ” + Meeting Name (Meeting__c) + “ - “ + Contact (Contact__c)
     *                          Case status = “New request”
     *                          //Case Owner = “Events & Member Support”  (Queue)
     *                          Case Origin = Registration.Origin__c
     *                          Lookup fields:
     *                              Registration = Registration.Id
     *                              Meeting = Registration.Meeting__c
     *                              Contact Name = Registration.Contact__c
     *                              Institution Name = Registration.Contact__c.AccountId  
     * 
     *  @args           :   List<Id> RegistrationIds
     * 
     *  @return         :   void
     * 
     *  @revision log   :   V1.1 - Modified by Saurabh Kumar 10/09/2020 - CR-20200819-14447 : Replace Meeting with EAB Event
    **/
    @InvocableMethod
    public static void createNewCaseOnRegistrationChanges(List<Id> registrationIds) {
        
        //Querying Details for "Member & Employee Support" record type on Case Object
        List<RecordType> rdTypes = [SELECT ID FROM RecordType 
                                   WHERE sObjectType = 'Case' 
                                    AND IsActive = true 
                                    AND DeveloperName = 'Member_Employee_Support'];
        
        //Modified By - Mahendra Swarnakar - 11/29/2017 - CR-20171128-11820 - Starts from here
        /*
        //Query for queue                                
        List<QueueSobject> lstQueues = [SELECT Id, queue.Name, QueueId 
                                        FROM QueueSobject 
                                        WHERE SobjectType = 'Case' 
                                            AND queue.name= 'Events & Member Support'];
        */
        
        //Checking for the size value
        if(rdTypes.size() > 0) {
        //Modified By - Mahendra Swarnakar - 11/29/2017 - CR-20171128-11820 - Ends here
        
            //List to hold the case records  
            List<Case> listCaseRecordToBeInserted = New List<Case>();
            
            //Modified by Mahendra Swarnkar - 02/12/2020 - CR-20200121-13646
            List<Registration__c> listRegistraionsToDelete = new List<Registration__c>();
            
            //Modified by Saurabh Kumar - 10/09/2020 - CR-20200819-14447: Removed Meeting Reference. Start
            //Modify the query to not create case for registraion having Status = 'Cancelled' - Mahendra Swarnakar - 02/12/2020
            //Loop through updated registration records 
            for(Registration__c reg : [SELECT Id, Contact__c, 
                                       Contact__r.Name, Origin__c, Contact__r.AccountID, Status__c, (Select Id from Cases__r Limit 1)
                                       FROM Registration__c 
                                       WHERE Id IN : registrationIds ]) 
            {
                
                if(reg.Status__c == 'Cancelled' ) {
                    
                    //Before deleting the regidtration validate for a case if found then skip deleting that restration record.
                    if(reg.Cases__r == null)
                        listRegistraionsToDelete.add(reg);
                
                } else {
                    
                    Case caseRecordToBeInserted = new Case();
                    //populate fields value on the case record                           
                    caseRecordToBeInserted.RecordTypeId = rdTypes[0].Id;
                    //caseRecordToBeInserted.subject = 'Registration requested - ' + reg.Meeting__r.Name + ' - ' + reg.Contact__r.Name;
                    caseRecordToBeInserted.subject = 'Registration requested - ' + reg.Contact__r.Name;
                    caseRecordToBeInserted.status = 'New Request';
                    caseRecordToBeInserted.Origin = reg.Origin__c;
                    //caseRecordToBeInserted.Meeting__c = reg.Meeting__c;
                    caseRecordToBeInserted.Registration__c = reg.Id;
                    caseRecordToBeInserted.ContactId = reg.Contact__c;
                    caseRecordToBeInserted.AccountId = reg.Contact__r.AccountID;
                    
                    //Modified By - Mahendra Swarnakar - 11/29/2017 - CR-20171128-11820 - Starts from here  
                    //caseRecordToBeInserted.OwnerId = lstQueues[0].QueueId;
                    //if(reg.Meeting__c != null  )
                      //  caseRecordToBeInserted.Site__c = reg.Meeting__r.Site__c;
                    
                    //triggering the case Assignment Rules. i.e. Setting the flag to starts the case assignment rules for the case
                    Database.DMLOptions dmo = new Database.DMLOptions();
                    dmo.assignmentRuleHeader.useDefaultRule = true;
                    caseRecordToBeInserted.setOptions(dmo);
                    
                    listCaseRecordToBeInserted.add(caseRecordToBeInserted);
                    
                }
            }
            /*//Modify the query to not create case for registraion having Status = 'Cancelled' - Mahendra Swarnakar - 02/12/2020
            //Modified By - Mahendra Swarnakar - 11/29/2017 - CR-20171128-11820 - Updated the Query to get the Meeting__r.Site__c field values
            //Loop through updated registration records 
            for(Registration__c reg : [SELECT Id, Contact__c, Meeting__c, Meeting__r.Name, Meeting__r.Site__c,
                                       Contact__r.Name, Origin__c, Contact__r.AccountID, Status__c, (Select Id from Cases__r Limit 1)
                                       FROM Registration__c 
                                       WHERE Id IN : registrationIds ]) 
            {
                
                if(reg.Status__c == 'Cancelled' ) {
                    
                    //Before deleting the regidtration validate for a case if found then skip deleting that restration record.
                    if(reg.Cases__r == null)
                        listRegistraionsToDelete.add(reg);
                
                } else {
                    
                    Case caseRecordToBeInserted = new Case();
                    //populate fields value on the case record                           
                    caseRecordToBeInserted.RecordTypeId = rdTypes[0].Id;
                    caseRecordToBeInserted.subject = 'Registration requested - ' + reg.Meeting__r.Name + ' - ' + reg.Contact__r.Name;
                    caseRecordToBeInserted.status = 'New Request';
                    caseRecordToBeInserted.Origin = reg.Origin__c;
                    caseRecordToBeInserted.Meeting__c = reg.Meeting__c;
                    caseRecordToBeInserted.Registration__c = reg.Id;
                    caseRecordToBeInserted.ContactId = reg.Contact__c;
                    caseRecordToBeInserted.AccountId = reg.Contact__r.AccountID;
                    
                    //Modified By - Mahendra Swarnakar - 11/29/2017 - CR-20171128-11820 - Starts from here  
                    //caseRecordToBeInserted.OwnerId = lstQueues[0].QueueId;
                    if(reg.Meeting__c != null  )
                        caseRecordToBeInserted.Site__c = reg.Meeting__r.Site__c;
                    
                    //triggering the case Assignment Rules. i.e. Setting the flag to starts the case assignment rules for the case
                    Database.DMLOptions dmo = new Database.DMLOptions();
                    dmo.assignmentRuleHeader.useDefaultRule = true;
                    caseRecordToBeInserted.setOptions(dmo);
                    listCaseRecordToBeInserted.add(caseRecordToBeInserted);
                    //Modified By - Mahendra Swarnakar - 11/29/2017 - CR-20171128-11820 - Starts from here
                    
                }
            }*/
            //Modified by Saurabh Kumar - 10/09/2020 - CR-20200819-14447: Removed Meeting Reference. End
            //Checking for the null value
            if(listCaseRecordToBeInserted.size() > 0) 
                insert listCaseRecordToBeInserted;   
            
            //Check for size
            if(listRegistraionsToDelete.size() > 0)
                delete listRegistraionsToDelete;
        }
    }
}