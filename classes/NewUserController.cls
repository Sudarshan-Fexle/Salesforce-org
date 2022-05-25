/**
 *   Purpose        : Hobsons Compass Community
                      Self registration for end user:
             	      1) If user email address or email is already present in salesforce it shows an error.
                      2) If client Id matched we will check the contacts under that account and enable that contact if already not enabled.
             	      3) If client Id does not matched we will search contacts org wide and if found we will request for approval
                      4) Once reuqest is submitted for approval the hobsons agents (Queue users) will get an email and they have to attached the account before approving
                      5) Once record is approved customer will get the welcome email.  
 *
 *   Created By     :  Murtaza Ali
 *
 *   Created Date   :  14-May-2014
 *
 *   Current Version:  V1.0
 *
 *   Revision Log   :  
 * 
**/
public class NewUserController {
    
    public string FirstName{get;set;}
    public string LastName{get;set;}
    public string UserName{get;set;}
    public string EmailAdd{get;set;}
    public string PhoneNum{get;set;}
    public string InsName{get;set;}
    public string ClientId{get;set;}


    public Community_user_Request__c CommUserReq {get;set;}
    public boolean IsSuccess {get;set;}

    public NewUserController(){
        
        CommUserReq  = new Community_user_Request__c();
    }

    public pagereference SaveCommunityUserRequest(){
        
        CommUserReq.First_Name__c = FirstName;
        CommUserReq.Last_Name__c = LastName;
        CommUserReq.User_Name__c = UserName;
        CommUserReq.Email__c= EmailAdd;
       // CommUserReq.Phone_number__c = PhoneNum;
        CommUserReq.Institution_Name__c = InsName;
        CommUserReq.Client_Id__c = ClientId;
    
        if(validateNewUser()){
        System.debug('Ayush 1 validateNewUser %%%');
            
            //use case a1
            list<Account> LstOfAccounts = [select id,name from account where name =:CommUserReq.Institution_Name__c];
            
            system.debug('LstOfAccounts--'+LstOfAccounts);
            if(LstOfAccounts.size()>0){
            
                list<id> LstOfContactIds = new list<id>();
                for(User u : [select id,contactId from user where isportalenabled= true]){
                    LstOfContactIds.add(u.contactID);
                }
                
                system.debug('LstOfContactIds '+LstOfContactIds);
                list<Contact> ListOFContact = [select id from contact where email=:EmailAdd AND AccountId IN:LstOfAccounts and id not in :LstOfContactIds];
               
                system.debug('ListOFContact   '+ListOFContact);
                if(ListOFContact.size() > 0){   
                    //enable this contact as a community user.
                    createCommunityUser(ListOfContact[0].Id); 
                    pagereference pr = new pagereference('/CompassSuccess?UserCreated=Yes');
                    pr.setredirect(true);
                    return pr; 
                    
                } else{
                    //call method for creation of manual requests
                    SendForManualRequest(null);
                    pagereference pr = new pagereference('/CompassSuccess');
                    pr.setredirect(true);
                    return pr; 
                }
        
            } else {
                    //In case if account does not found and search all contacts
                    
                    list<id> LstOfContactIds = new list<id>();
                    for(User u : [select id,contactId from user where isportalenabled= true])
                    {
                        LstOfContactIds.add(u.contactID);
                    }
                    
                    list<Contact> ListOFContact = [select id from contact where email=:EmailAdd and ID not in: LstOfContactIds];
        
                    if(ListOFContact.size()>0){
                        //enable this contact as a community user.
                        // createCommunityUser(ListOfContact[0].Id);
                        //update logic send for manual approval
                        SendForManualRequest(ListOfContact[0].Id);
                        pagereference pr = new pagereference('/CompassSuccess');
                        pr.setredirect(true);
                        return pr;
                          
                    } else {                           //if both does not match we will create a custom object request
                        
                        //send request for manual approval
                        SendForManualRequest(null);
                        pagereference pr = new pagereference('/CompassSuccess');
                        pr.setredirect(true);
                        return pr; 
                    }
            }
            
        } else {
            
            return null;
        }
        
    }
    

    public void SendForManualRequest(String ContactId){
        
        //custom object record for manual approval
        CommUserReq.User_Name__c = CommUserReq.User_Name__c+'@eab.community.com';
        CommUserReq.Contact__c = ContactId;
        CommUserReq.Email__c = EmailAdd;
        insert CommUserReq ;
        //User usr =  [Select Id From User Where Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];
        System.debug('Ayush CommUserReq %%% '+CommUserReq.Id);
        
        // code for auto submission of approval request
        Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitRequest();
        app.setComments('Submitted for approval. Please approve.');
        app.setObjectId(CommUserReq.id);
        //app.setSubmitterId(usr.Id); 
       // app.setProcessDefinitionNameOrId('Approval_Request_for_new_user');
       // app.setSkipEntryCriteria(true);
       system.debug('app echec '+app);
        Approval.ProcessResult result = Approval.process(app);
        System.debug('Ayush '+result.isSuccess());
        Apexpages.addmessage(new apexpages.message(apexpages.severity.confirm,'You requested is submitted. You will get a welcome email once approved.'));
    }
    
    
    public void createCommunityUser(String ContactId){
        
        String Todaysec = String.valueof(System.now());
        Todaysec  = Todaysec.substring(todaysec.length()-2,todaysec.length());
        
        Profile p = [select Id,name from Profile where name = 'Overage High Volume Customer Portal User']; 
        
        User newUser = new User(
            profileId = p.id,
            username = CommUserReq.User_Name__c+'@eab.community.com',
            email = EmailAdd,
            emailencodingkey = 'UTF-8',
            localesidkey = 'en_US',
            languagelocalekey = 'en_US',
            timezonesidkey = 'America/New_York',     //'America/Los_Angeles',
            CommunityNickname = CommUserReq.User_Name__c.length()>=40 ? CommUserReq.User_Name__c.substring(0,39) : CommUserReq.User_Name__c,
            //alias=(CommUserReq.First_Name__c+' '+ CommUserReq.Last_Name__c).substring(8),
            //alias= (CommUserReq.First_Name__c+' '+ CommUserReq.Last_Name__c).length()>= 8 ? (CommUserReq.First_Name__c+''+ CommUserReq.Last_Name__c).substring(0,7) : (CommUserReq.First_Name__c+''+ CommUserReq.Last_Name__c),
            alias= CommUserReq.User_Name__c.length()>= 6 ? CommUserReq.User_Name__c.substring(0,5)+Todaysec  : CommUserReq.User_Name__c+Todaysec ,
            lastname=CommUserReq.Last_Name__c,
            firstname=CommUserReq.First_Name__c,
            contactId = ContactId
        );
        
        insert newUser;
        //IsSuccess = true;
        
        Apexpages.addmessage(new apexpages.message(apexpages.severity.confirm,'Your User is created. You will get a welcome email soon.'));        
    
    }
    
    public boolean validateNewUser(){

        string username = CommUserReq.User_Name__c+'@eab.community.com';
        
        if([select id from user where email =: EmailAdd].size()>0) {
            
            apexpages.addmessage(new apexpages.message(apexpages.severity.Error,'We are sorry, but this email address already exists in our system. You can<a style="text-decoration: underline; color: red;font-size:13px;" href="/compass/CompassForgetPassword">reset your password</a>for this email address or register a new account with a different email address.'));
            return false;
            
        } else if([select id from Community_user_Request__c where email__c =: EmailAdd].size()>0) {
            
            apexpages.addmessage(new apexpages.message(apexpages.severity.Error,'An account has already been requested for this email address, and is pending approval. If you have any questions, please contact<a href="mailto:compasscommunity@eab.com" style="font-size:12px;margin-right: 3px;">compasscommunity@eab.com</a>'));
            return false;
            
        } else if([select id from user where username =: username ].size()>0 ) {
            
            apexpages.addmessage(new apexpages.message(apexpages.severity.Error,'We are sorry, but this user name is already taken. Please modify and try again.'));
            return false;
            
        } else if([select id from Community_user_Request__c where User_Name__c =:username ].size()>0) {
            
            apexpages.addmessage(new apexpages.message(apexpages.severity.Error,'This user name has already been requested, and is pending approval. If you did not previously submit this user name, please modify the user name and try again. If you have any questions, please contact<a href="mailto:compasscommunity@eab.com" style="font-size:12px;margin-right: 3px;">compasscommunity@eab.com</a>'));
            return false;
            
        } else {
            
            return true;
        }
    }
}