/**
    Purpose:        Helper class for the CaseComment trigger.(CR-4283)
                
    Create By:      Victor Hanson
    
    Created Date:   06/02/2014
    
    Revision Log:   V_1.0 - VH - 06/02/2014 - Created
                    V_1.1 - Mahendra Swarnkar - CR-20160603-9890 - 7/4/2016 - Added new method populateMostRecentPublicCaseComment 
         	    V_1.2 - Modified By - Abhinav Sharma - 09/05/2016 - CR-20160114-9520 - Added a new method "populateFirstCommentDateTimeOnParentCase"
		    V_1.3 - Modified By - Mahendra Swarnkar - 03/05/2020 - CR-20200217-13756: RT deleted: PT_SUPPORT_REQUEST
		    V_1.4 - Modified by - Ayush Gupta - 08/18/2021 - CR-20210817-15360
 *            
**/
public class CaseCommentTriggerHelper {
    
    public static void populateCaseCommentNotify(list<CaseComment> caseComments, map<Id, CaseComment> oldCommentMap) {
        
        string oldCaseCommentString;
            
        //convert sObjects to JSON strings
        string newCaseCommentString = System.JSON.serialize(caseComments);
        if (oldCommentMap != null)
          oldCaseCommentString = System.JSON.serialize(oldCommentMap.values());
        
        //only continue processing if this is not being called from a future method or batch job.
        if (!system.isFuture() && !system.isBatch()) {
            //call our future method which will convert the strings back to sObjects and email the member if applicable
            populateCaseCommentNotify(newCaseCommentString, oldCaseCommentString);
        }
    }
    
    /**
     * @description:    Update the Case Comment Notify field with system.now(), which triggers an email alert to the member
     * 
     * @params:         trigger.new, trigger.oldMap
    **/
    @future
    public static void populateCaseCommentNotify(string caseCommentNewString, string caseCommentOldString) {
        
        list<Case> casesToUpdate = new list<Case>();
        
        //convert our JSON string to a list of the new sobjects
        list<CaseComment> caseComments = (list<CaseComment>) System.JSON.deserializeStrict(caseCommentNewString, list<CaseComment>.class);
        //convert our JSON string to a map of the old sObjects
        map<Id, CaseComment> oldCommentMap;
        if (caseCommentOldString != null) {
            list<CaseComment> caseCommentOldList = (list<CaseComment>) System.JSON.deserializeStrict(caseCommentOldString, list<CaseComment>.class);
            oldCommentMap = new map<Id, CaseComment>(caseCommentOldList);
        }
        
        //get list of cases
        set<Id> caseIds = new set<Id>();
        for (CaseComment comment : caseComments) caseIds.add(comment.ParentId);
        map<Id, Case> caseMap = new map<Id, Case>([SELECT Id, Case_Comment_Notification__c, Visible_in_Portal__c, RecordTypeId
                                                  FROM Case WHERE Id IN :caseIds]);
        
        for (CaseComment comment : caseComments) {
            
            //get the old comment
            CaseComment oldComment;
            if (oldCommentMap != null) oldComment = oldCommentMap.get(comment.Id);
            
            //get the case
            Case aCase = caseMap.get(comment.parentId);
            
            //Commented by Mahendra Swarnkar - 03/05/2020 - CR-20200217-13756: RT deleted: PT Data Load, PT_SUPPORT
            if (aCase.Visible_in_Portal__c
               /*&& (  aCase.RecordTypeId == Constants.RECORD_TYPE_ID_CASE_PT_SUPPORT
                  || aCase.RecordTypeId == Constants.RECORD_TYPE_ID_CASE_PT_DATA_LOAD)*/
               && (  oldComment == null 
                  || oldComment.IsPublished == false)
               && comment.IsPublished)
            {
                
                aCase.Case_Comment_Notification__c = system.now();
                casesToUpdate.add(aCase);
            }
        }
        
        if (casesToUpdate.size() > 0) update casesToUpdate;
    }
    
    //Added By - Mahendra Swarnkar - CR-20160603-9890 - 07/04/2016 
    /**
     *  @description    :   This method use to populate most recent public case comment of case to the associated Member Support record.
     *
     *  @arg            :   List<CaseComment>, Map<Id, CaseComment>
     *
     *  @return         :   void
     *
     **/  
    public static void populateMostRecentPublicCaseComment(List<CaseComment> caseComments, Map<Id, CaseComment> oldCommentMap){
        
        //Set to hold the parent case records IDs
        Set<Id> setOfParentCaseIds = new Set<Id>();
        
        //Loop through case comment records
        for(CaseComment cCom : caseComments != null ? caseComments : oldCommentMap.values()) {
            
            //Insert use case
            if(caseComments != null && oldCommentMap == null && cCom.ParentId != null && cCom.IsPublished == true)
                setOfParentCaseIds.add(cCom.ParentId);
            
            //Update use case
            if(caseComments != null && oldCommentMap != null && cCom.ParentId != null) {
                
                //Checking for the comment body/Is publised field change
                if(cCom.CommentBody != oldCommentMap.get(cCom.Id).CommentBody 
                    || 
                    cCom.IsPublished != oldCommentMap.get(cCom.Id).IsPublished 
                )
                    setOfParentCaseIds.add(cCom.ParentId);   
            }    
                    
            //Delete use case
            if(caseComments == null && oldCommentMap != null && cCom.IsPublished == true && cCom.ParentId != null)  
                setOfParentCaseIds.add(cCom.ParentId);
        }
        
        //Checking set for size value
        if(setOfParentCaseIds.size() > 0) { 
            
            //Map of parent case records
            Map<Id, Case> mapCaseRecords = new Map<Id, Case>([SELECT Id, Member_Support_Ticket__c FROM Case 
                                                                WHERE Id IN : setOfParentCaseIds]);
                                                                
            //Map to hold parent case record ID as key and corresponding most recent public case comment instance as value
            Map<Id, CaseComment> mapOfParentCaseIdWithMostRecentCaseComment = new Map<Id, CaseComment>();                                                   
            
            //Loop over caseComment record and put value in map
            for(CaseComment cc : [SELECT Id, CommentBody, ParentId FROM CaseComment 
                                    WHERE ParentId != null AND ParentId IN : setOfParentCaseIds 
                                    AND IsPublished = true 
                                    ORDER By LastModifiedDate ASC])
                mapOfParentCaseIdWithMostRecentCaseComment.put(cc.ParentId, cc);
                
            //Checking map for size value
            if(mapCaseRecords.values().size() > 0) {
                
                //Map of member support - Will update to with "Latest Public Case Comment" field value
                Map<Id, Site_Issue__c> mapOfSiteIssues = new Map<Id, Site_Issue__c>();
                    
                //Retrive case comment records
                for(Case cse : mapCaseRecords.values()) {
                    
                    //Checking if "Member Support" is associated as parent to the current context record or not
                    if(cse.Member_Support_Ticket__c != null) {
                        
                        //Checking if current context case record Id exists as key in the most recent case comment based map
                        if(mapOfParentCaseIdWithMostRecentCaseComment.containsKey(cse.Id) 
                            && mapOfParentCaseIdWithMostRecentCaseComment.get(cse.Id) != null)
                            mapOfSiteIssues.put(cse.Member_Support_Ticket__c, new Site_Issue__c(Id = cse.Member_Support_Ticket__c,
                                                                                                Latest_Public_Case_Comment__c = mapOfParentCaseIdWithMostRecentCaseComment.get(cse.Id).CommentBody));
                        else
                            mapOfSiteIssues.put(cse.Member_Support_Ticket__c, new Site_Issue__c(Id = cse.Member_Support_Ticket__c,
                                                                                                Latest_Public_Case_Comment__c = ''));
                    }
                }
                
                //Checking for the size value
                if(mapOfSiteIssues.values().size() > 0) {
                    
                    //bypassing triggers for stopping the un-necessary execution while updating member support records
                    Util.byPassAlltriggers = true;
                            
                    //Update member support records
                    update mapOfSiteIssues.values();
                    
                    //Enabling triggers again
                    Util.byPassAlltriggers = false;
                }
            }       
        }               
    }
    
    //Constructed as future method otherwsie sometimes it will results as "recursively update itself" error
    //Added By - Abhinav Sharma - CR-20160114-9520 - 09/05/2016 
    /**
     *  @description    :   This method use to populate "First_Comment_Date_Time__c" field on the parent case record.
     *
     *  @arg            :   List<CaseComment>
     *
     *  @return         :   void
     *
     **/  
    //Commented by Mahendra Swarnkar - 03/05/2020 - CR-20200217-13756: RT deleted: PT_SUPPORT_REQUEST
    /*public static void populateFirstCommentDateTimeOnParentCase(List<CaseComment> caseComments) {
        
        //convert sObjects to JSON strings
        string newCaseCommentString = System.JSON.serialize(caseComments);
        
        //only continue processing if this is not being called from a future method or batch job.
        if (!system.isFuture() && !system.isBatch()) {
            
            //call our future method which will convert the strings back to sObjects
            //Will perform the further updates
            populateFirstCommentDateTimeOnCases(newCaseCommentString);
            
        }    
    }
    
    @future(callout = false)
    public static void populateFirstCommentDateTimeOnCases(string caseCommentNewString) {
        
        //Checking string for null/blank value
        if(String.isNotBlank(caseCommentNewString)) {
            
          //convert our JSON string to a list of the new sobjects
          list<CaseComment> caseComments = (list<CaseComment>) System.JSON.deserializeStrict(caseCommentNewString, list<CaseComment>.class);
            
            //Checking for null and size value
            if(caseComments != null && caseComments.size() > 0) {
                
                //Set to parent case records IDs
            Set<Id> setParentCasesIds = new Set<Id>();
        
                //Loop through newly created case comment records
                for(CaseComment cc : caseComments) {
                    if(cc.ParentId != null)
                        setParentCasesIds.add(cc.ParentId);
                }
            
                //Checking set for it's size
                if(setParentCasesIds.size() > 0) {
                    
                    //Map of cases
                    Map<Id, Case> mapOfCases = new Map<Id, Case>();
                    
                    //List of eligible case object record types
                    List<RecordType> caseRecordTypes = [SELECT ID FROM RecordType 
                                                        WHERE DeveloperName =: Constants.RECORD_TYPE_CASE_DEVELOPER_NAME_PT_SUPPORT_REQUEST 
                                                        AND IsActive = true 
                                                        AND sObjectType =: Constants.CASE_OBJECT];
                    
                    //Checking for the null and size value
                    if(caseRecordTypes != null && caseRecordTypes.size() > 0) {
                        
                    //Retrieving parent case records details
                        for(Case c : [SELECT ID, First_Comment_Date_Time__c, CreatedDate, Member_Support_Ticket__c
                                        FROM Case 
                                        WHERE ID IN : setParentCasesIds
                                       AND RecordTypeId != null
                                       AND RecordTypeId IN : caseRecordTypes
                                     ]) {
                            
                            //Checking "First_Comment_Date_Time__c" for null/blank value                
                            if(c.First_Comment_Date_Time__c == null) {
                                c.First_Comment_Date_Time__c = System.now();
                                mapOfCases.put(c.Id, c);
                            }
                        }
                    
                        //Checking map for size value
                        if(mapOfCases.values().size() > 0) {
                        
                            //Bypassing triggers
                            Util.byPassAllTriggers = true;
                            
                            //Update cases
                            update mapOfCases.values();
                            
                            //Enabling again
                            Util.byPassAllTriggers = false;
                            
                            //Map of Member Supports
                            Map<Id, Site_Issue__c> mapOfMemberSupports = new Map<Id, Site_Issue__c>();
                        
                            //Loop through updated instances of cases
                            for(Case cs : mapOfCases.values()) {
                                
                                //Checking for MS record reference
                                if(cs.Member_Support_Ticket__c != null) {
                                    
                                    //Member Support
                                    Site_Issue__c ms = new Site_Issue__c(Id = cs.Member_Support_Ticket__c);
                                    
                                    //Populate Elapsed: Open to First Response (Hours) on Member Support
                                    if(cs.CreatedDate != null && cs.First_Comment_Date_Time__c != null) {
                                      //  ms.Elapsed_Open_to_First_Response_Hours__c = (Util.businessHoursForStartAndEndDate(cs.CreatedDate, cs.First_Comment_Date_Time__c, null))/60;
                                        
                                        //Checking "First_Comment_Date_Time__c" for null/blank value                
                                        if(ms.First_Comment_Date_Time__c == null)
                                            ms.First_Comment_Date_Time__c = cs.First_Comment_Date_Time__c;
                                        
                                        //Populating map with the updated instance        
                                        mapOfMemberSupports.put(ms.Id, ms);
                                    }
                                    else {
                                        ms.Elapsed_Open_to_First_Response_Hours__c = null;
                                        mapOfMemberSupports.put(ms.Id, ms);
                                    }
                                }
                            }
                        
                            //Checking map for size value
                            if(mapOfMemberSupports.values().size() > 0) {
                        
                                //Bypassing triggers
                                Util.byPassAllTriggers = true;
                                
                                //Update cases
                                update mapOfMemberSupports.values();
                                
                                //Enabling again
                                Util.byPassAllTriggers = false;
                          }
                      }        
                    }
            }
            }
        }
    }*/
    
    //Added by Ayush Gupta - 08/18/2021 - CR-20210817-15360
    public static void populateLatestSupportRepComment(List<CaseComment> NewCaseComments){
        
        //Get System Admin profile list
        List<Profile> profile = [select Id, Name From Profile Where Name = 'System Administrator'];
        
        //set to store the id case comments
        Set<Id> setOfCaseComment = new Set<Id>();
        
        //set to store Case Id
        Map<Id,Case> mapOfCaseToUpdate = new Map<Id,Case>();
        
        //filtring out case comments on the basis of Published
        for(CaseComment cCommnts : NewCaseComments){
            if(cCommnts.IsPublished == True)
                //addind case commnet id in set 
                setOfCaseComment.add(cCommnts.Id);
        }
        
        //fetching created by Profile Id and parent RecordType Id
        for(CaseComment caseCommnts : [Select Id,CreatedBy.ProfileId,ParentId,Parent.RecordTypeId From CaseComment WHERE Id IN: setOfCaseComment]){
            //checking casecomment is not created by System Admin
            if(caseCommnts.CreatedBy.ProfileId != profile[0].Id){
                //checking case RecordTypeId != Intersect,Intersect APS,Starfish,APS Review
                if(caseCommnts.Parent.RecordTypeId != Constants.CASE_RT_ID_STARFISH || caseCommnts.Parent.RecordTypeId != Constants.CASE_RT_ID_APS_REVIEW ||
                   caseCommnts.Parent.RecordTypeId != Constants.CASE_RT_ID_INTERSECT || caseCommnts.Parent.RecordTypeId != Constants.CASE_RT_ID_INTERSECT_APS){
                      
                       //adding case in map to update value
                       mapOfCaseToUpdate.put(caseCommnts.ParentId, new Case(Id = caseCommnts.ParentId,Last_Support_Rep_Comment__c = true));
                   }
		   
                //checking case RecordTypeId = Starfish,APS Review,Technical Support
                else if(caseCommnts.Parent.RecordTypeId == Constants.CASE_RT_ID_STARFISH || caseCommnts.Parent.RecordTypeId == Constants.CASE_RT_ID_APS_REVIEW ||
                   caseCommnts.Parent.RecordTypeId == Constants.CASE_RT_ID_TECH_SUPPORT){
                      
                       //adding case in map to update value
                       mapOfCaseToUpdate.put(caseCommnts.ParentId, new Case(Id = caseCommnts.ParentId,Last_Support_Rep_Comment__c = true));
                   }
            }
        }
        //checking the size map
        if(mapOfCaseToUpdate.size() > 0 && mapOfCaseToUpdate.values().size() > 0){
            //updating the Case
            update mapOfCaseToUpdate.values();
        }
        
    }
}