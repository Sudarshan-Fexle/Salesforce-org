/*
    Purpose         :   Created a trigger with Name triggerFeedItemOOOAutoResponder
                
    Create By       :   Simplyforce Technology
    
    Created Date    :   
    
    Revision Log    :   V_1.0 Created
                        V_1.1 - Modified By - Abhinav Sharma - 07/07/2014 - CR-20140618-5849 - Catch DML errors in triggers to reduce exception emails to SFAdmin
                        V_1.2 - Modified By - Subhash Garhwal - 09/27/2017 - CR-20170926-11418 -  Added the Util.areTriggersOnThisObjectBypassed flag.
    			V_1.3 - Modified By - Ayush Gupta - 07/27/2021 - CR-20210714-15288 - Added Profile Check
			V_1.4 - Modified By - Ayush Gupta - 08/31/2021 - CR-20210829-15391
			V_1.5 - Modified By - Ayush Gupta - CR-20210930-15473
*/
trigger triggerFeedItemOOOAutoResponder on FeedItem (after insert) {
    
    //return immediately if method returns true 
    if(Util.areTriggersOnThisObjectBypassed('FeedItem')) return;
    
    try {
        
        // bypass flag
        if (Util.BypassAllTriggers) return;
        
        set<Id> caseIds = new Set<Id>();
        List<Case> updates = new List<Case>();
        for (FeedItem fi : Trigger.new) {
            if (fi.ParentId.getSObjectType() == Case.SObjectType) {
                caseIds.add(fi.ParentId);
            }
        }
        for(Case cs : [select id,status,RecordType.Name,IsClosed From Case where Id IN: caseIds]){
            
            if((cs.RecordType.Name == 'Starfish' || cs.RecordType.Name == 'Intersect'||cs.RecordType.Name == 'Intersect_APS'||cs.RecordType.Name == 'Technical_Support'
                ||cs.RecordType.Name == 'Projects' ||cs.RecordType.Name == 'APS_Review') && cs.IsClosed == false && cs.Status != 'New' &&  UserInfo.getUserType() != 'Standard'){
                    Case cc = new Case();
                    cc.id = cs.Id;
                    cc.Status = 'Replied';
                    updates.add(cc);
                }
        }
        if(updates.size() > 0){
            update updates;
        }
        
	//Modified By - Ayush Gupta - 08/31/2021 - CR-20210829-15391
        Profile pro = [select id,Name from profile where id =: userinfo.getProfileId()];
        if(pro.Name != 'Overage High Volume Customer Portal User' && pro.Name != 'Customer Community Super'
           && pro.Name != 'Account Management' && pro.Name != 'Analyst' && pro.Name != 'Customer Community User'){
               
               //Calling Helper Class Method
               ChatterHelper.OOOAutoRespondFeedItems(Trigger.newMap.keySet());
           }
    //Catching DML Exceptions
    } 
    catch(DMLException e) {

        //Add Error Message on Page
        if(Trigger.isDelete)
            Trigger.Old[0].addError(e.getDmlMessage(0));
        else
            Trigger.New[0].addError(e.getDmlMessage(0));

    //Catching all Exceptions
    }  catch(Exception e) {
        
        //Add Error Message on Page
        if(Trigger.isDelete)
            Trigger.Old[0].addError(e.getMessage());
        else
            Trigger.New[0].addError(e.getMessage());
    }
}