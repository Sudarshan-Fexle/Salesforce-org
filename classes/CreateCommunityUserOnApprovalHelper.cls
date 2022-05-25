/**
*	Purpose		:	Helper class for Trigger_CreateCommunityUserOnApproval trigger.
*
*	Created By	:	Ayush Gupta
*
*	Created Date	:	06/29/2021	
*
*	Revision Log	:	V_1.1 - Created - CR-20210422-15098
*
**/
public class CreateCommunityUserOnApprovalHelper {
    
    /**
    * 
    *  @description    :   The method is used to create contact for community users . 
    *
    *  @args           :   List<Community_user_Request__c>
    *
    *  @return         :   void
    *
    *  @revision Log   :   V_1.0 - Created by - Ayush Gupta - 06/29/2021 - CR-20210422-15098
    * 
    **/
    
    public static void validateCommunityUserOnApproval(List<Community_user_Request__c> newCommunityuserRequests){
        
        //to hold contacts with email
        Map<String, Contact> mapOfEmailWithContacts = new map<String, Contact>();
        
        for(Community_user_Request__c comUserReq : newCommunityuserRequests) {
            
            //check approval request
            if(comUserReq.Request_Status__c == 'Approved' && comUserReq.account__c ==null) {
                //throw validation if request is not approved
                comUserReq.Request_Status__c.adderror('You must have to associate the account before approving.');
            }
            
            //check user is created or not. if not then create new contact
            if(comUserReq.Request_Status__c == 'Approved' && comUserReq.account__c != null 
               && comUserReq.User_Created__c == false && comUserReq.Contact__c == null) {
                   //create contact
                   //NOTE:- Added phone no to prevent validation for required Email, Title and Phone
                   Contact con = new Contact(email = comUserReq.Email__c, firstname = comUserReq.First_Name__c,
                                             lastname = comUserReq.Last_Name__c, accountId = comUserReq.Account__c,
                                             Phone = '5555555', title = comUserReq.Last_Name__c);
                   
                   //add email with contact instance
                   mapOfEmailWithContacts.put(con.email, con);
               }
        }
        
        //check contact map size
        if(mapOfEmailWithContacts.size() > 0 && mapOfEmailWithContacts.values().size() > 0) {
            //bypass triggers before insert
            Util.BypassAllTriggers = true;
            Insert mapOfEmailWithContacts.values();
            Util.BypassAllTriggers = false;
        }
                
        //to hold profile id on which user is created
        Id protalUserProfileId = [select Id,name from Profile where name = 'Overage High Volume Customer Portal User']?.Id;
        
        //check profile id
        if(protalUserProfileId != null) {
            
            //to hold users list that needs to be created
            list<user> listOFUser = new list<user>();
            
            //get all new user request
            for(Community_user_Request__c cc : newCommunityuserRequests)  {
                
                //check if user is not created then create user
                if(CC.Request_Status__c == 'Approved' && CC.account__c !=null && CC.User_Created__c == false) {
                    
                    //get contact id
                    Id ContactId = cc.contact__c != null ? cc.Contact__c: 
                    mapOfEmailWithContacts.containskey(cc.email__c)? mapOfEmailWithContacts.get(cc.email__c).Id : null;
                    
                    String Todaysec = String.valueof(System.now());
                    Todaysec  = Todaysec.substring(todaysec.length()-2,todaysec.length());
                    
                    String CommunityNickname =  cc.user_name__c.substring(0,cc.user_name__c.indexof('@eab'));
                    
                    //create user
                    User newUser = new User( profileId = protalUserProfileId, Username = cc.user_name__c,
                                            email = cc.email__c, CommunityNickname = CommunityNickname ,
                                            emailencodingkey = 'UTF-8', localesidkey = 'en_US', languagelocalekey = 'en_US',
                                            timezonesidkey = 'America/New_York',
                                            alias = cc.user_name__c.length()>= 6 ? cc.user_name__c.substring(0,5)+Todaysec : cc.user_name__c+Todaysec,
                                            lastname = cc.Last_Name__c, firstname = cc.First_Name__c, ContactId = ContactID
                                           );
                    
                    //Only add new user if not running a test
                    if (Test.isRunningTest() == false)
                        listOFUser.add(newUser);
                    
                    //update field that user is already created for this request
                    cc.User_Created__c = true;
                    
                }
            }
            
            //check list size before insert
            if(listOFUser.size() > 0)  {
                Util.BypassAllTriggers = true;
                insert listOFUser;
                Util.BypassAllTriggers = false;
            }
        }
    }
}