/** 
*	Purpose			:	This class is to update the Intranet Item records with the users birthdate 
*
*	Created By		:	Bhavi Sharma
*
*	Created Date	:	09/19/2014
*				
* Revision Logs   	:  v1.0 - Created
*         			:  V1.1 - Modifled - Victor Hanson - 10/05/2017 - CR-20171003-11642 - added Entity__c to the user query
**/ 
global class Intranet_Birthdays implements Schedulable {
    
    //Execute Method
    global void execute(SchedulableContext sc){
        getBirthdays();
    }
    
    public static void GetBirthdays() {    
        
        //Set of profile Id
        Set<Id> excludedProfileIds = new Set<Id>();
        
        //Populate profile ids set
        for(Intranet_Constants__c iC : [Select Id, SetupOwnerId  from Intranet_Constants__c where Exclude_Birthday__c = true]) {
            
            //Add in set
            excludedProfileIds.add(iC.SetupOwnerId);
        }
        system.debug('Intranet_Birthdays.GetBirthdays - excludedProfileIds: '+excludedProfileIds);
        
        //Set to hold the user records
        Set<Id> setEmployeeUserRecords = new Set<Id>();
        
        //List of users having BirthDay = Today
        List<User> usersWithBirthdayToday = new List<User>();
        
        //Get employee Contact with a birthday today
        for(Contact contact : [Select Id, Employee_User_Record__c from Contact where Employee_User_Record__c != null AND BirthDate = TODAY AND Employee_User_Record__r.IsActive = true]) {
            
            //Add in list
            setEmployeeUserRecords.add(contact.Employee_User_Record__c);
        }
        system.debug('Intranet_Birthdays.GetBirthdays - setEmployeeUserRecords: '+setEmployeeUserRecords);
        
        //Users
        usersWithBirthdayToday = [Select Id, FirstName, LastName, ABC_Department__c, ProfileId, SmallPhotoUrl, Office__c, Entity__c from User where ID IN: setEmployeeUserRecords AND ProfileId NOT IN: excludedProfileIds AND Id NOT IN: excludedProfileIds];
        
        //Offices
        map<Id,Intranet_Item__c> mapOffices = new map<Id,Intranet_Item__c>([select Id, Office_Short_Name__c 
                                               from Intranet_Item__c 
                                               where Item_Type__c = 'Office Location']);
        
        //Substitute Office Name for Id
        for(User u1 : usersWithBirthdayToday){
            if(mapOffices.keySet().contains(u1.Office__c)){
                u1.Office__c = mapOffices.get(u1.Office__c).Office_Short_Name__c;
            }
        }
        system.debug('Intranet_Birthdays.GetBirthdays - usersWithBirthdayToday:'+usersWithBirthdayToday);
        
        //Convert this into JSON
        String jSONUsersWithBirthdayToday = JSON.serialize(usersWithBirthdayToday);
        
        //Query Intranet Birthday Item record
        List<Intranet_Item__c> birthDayItems = [Select Id, Office_Short_Name__c 
                                                from Intranet_Item__c 
                                                where  Item_Type__c = 'Birthdays' 
                                                	AND Active_Status__c = 'Active' 
	                                                AND Approval_Status__c = 'Approved' 
                                                	AND Configuration_Item__c = TRUE];
        
        if(birthDayItems.size() > 0) {
            
            //Update the Intranet Container Item record
            Intranet_Item__c iI = birthDayItems[0];
            iI.Birthdays_Cache__c = jSONUsersWithBirthdayToday;
            iI.Last_Content_Update__c = DateTime.Now();
            iI.Change_Configuration_Item__c = true;
            
            //Update Intranet Item
            update iI;
        }
    }
}