/**********************************************************
* @Author       Heidi Tang (heidi.a.tang@accenture.com)
* @Date         2016-05-25
* @Description  Test data creations for all classes
**********************************************************/
public class TestDataFactory {
    
     /* -----------------------------Test Data for Users--------------------------*/
    
    public static User createInternalSysAdminUser(String email, String lastName, String userName, String nickName){
        
        Profile sysAdminProf = [SELECT Id FROM Profile WHERE Name='System Administrator'];

        User internalUser = new User(Alias = nickName, Email=email,
                    EmailEncodingKey='UTF-8', LastName=lastName, LanguageLocaleKey='en_US',
                    LocaleSidKey='en_US', ProfileId = sysAdminProf.Id,isActive=true,
                    TimeZoneSidKey='America/Los_Angeles', UserName=userName); 
                    
        return internalUser;
    }
    
    /* -----------------------------Set Record Types and Business Hours--------------------------*/
    
    public static Id getRecordTypeId(String recordTypeDevName, String objectName){
        
        RecordType recType = [SELECT Id FROM RecordType WHERE sObjectType =:objectName AND DeveloperName = :recordtypeDevName];
        
        return recType.Id;
    } 
    
    /* -----------------------------Test Data for Custom Settings--------------------------*/
    public static void caseFieldsSetting(){
        /*List<Case_Fields__c> caseFields = new List<Case_Fields__c>();
        
        caseFields.add(new Case_Fields__c(Name = 'Account',Field_Api_Name__c = 'AccountId'));
        caseFields.add(new Case_Fields__c(Name = 'Origin',Field_Api_Name__c = 'Origin'));
        caseFields.add(new Case_Fields__c(Name = 'Customer Escalation',Field_Api_Name__c = 'Customer_Escalated__c'));
        caseFields.add(new Case_Fields__c(Name = 'Priority',Field_Api_Name__c = 'Priority'));
        caseFields.add(new Case_Fields__c(Name = 'Severity',Field_Api_Name__c = 'Severity__c'));
        
        insert caseFields;*/
    }
    
    /* -----------------------------Test Data for Multiple Records--------------------------*/
    
    public static List<Account> createAcctList(Integer noOfAccts, String acctName){
        
        List<Account> acctList = new List<Account>();
        
        //Modified by Mahendra Swarnkar - 05/05/2020 - CAPdb_Rating__c deleted - CR-20200218-13769
        for(Integer i=1;i<=noOfAccts;i++){
            acctList.add(new Account(Name = acctName +'i', BillingCountry = 'United States',
                    ShippingCountry = 'United States',Overdue_Balance__c = 0/*,CAPdb_Rating__c = 'Something'*/));
        }
        
        return acctList;
        
    }
    
    public static List<Contact> createConList(Integer noOfCons, String lastName){
         List<Contact> conList = new List<Contact>();
        
        for(Integer i=1;i<=noOfCons;i++){
            conList.add(new Contact(LastName = lastName +'i', Email = 'testingxyz' + i + '@eab.com', 
                                    Phone = '1233445551', Title = 'testingxyz' + i,
                                   	Is_Ignore_Phrase_Characters__c = true
                                   ));
        }
        
        return conList;
    }
    
     public static List<Key_Players_Influencers__c> createKeyInfluencer(Integer noOfKeys,String formalRole, Id opportunityId){
        List<Key_Players_Influencers__c> keyList = new List<Key_Players_Influencers__c>();
        
        for(Integer i=1;i<=noOfKeys;i++){
            keyList.add(new Key_Players_Influencers__c(Formal_Role__c=formalRole,Opportunity__c=opportunityId));
        }
        
        return keyList;
    }
    /*
        public static List<Attachment> createAttachments(Integer noOfAttach, String parentId, String subjectName){
        
        List<Attachment> attachmentList = new List<Attachment>();
        
        for(Integer i=1;i<=noOfAttach;i++){
            Blob bodyBlob=Blob.valueOf(subjectName+i);
            attachmentList.add(new Attachment(ParentId=parentId,Name=subjectName+i,Body = bodyBlob));
        }
                
        return attachmentList;
    }
    
    public static List<Case_Internal_Attachment__c> createInternalAttachments(Integer noOfIntAttach, String parentId, String intName){
        
        List<Case_Internal_Attachment__c> intAttachmentList = new List<Case_Internal_Attachment__c>();
        
        for(Integer i=1;i<=noOfIntAttach;i++){
            intAttachmentList.add(new Case_Internal_Attachment__c(Case__c=parentId,Name=intName+i));
        }
                
        return intAttachmentList;
    }*/

    
}