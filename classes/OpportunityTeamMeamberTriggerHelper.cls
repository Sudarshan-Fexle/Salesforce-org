/**
 *  Purpose         :   This class is helper class of Trigger on OpportunityTeamMember
 *
 *  Create By       :   Subhash Garhwal
 *
 *  Created Date    :   11/8/2017
 *
 *  Revision Logs   :   V_1.0 - Created - 11/8/2017 - Subhash Garhwal - Issue--CR11753--QA--00007372
 **/
public class OpportunityTeamMeamberTriggerHelper {
    
    /**
     *  @description    :   This method hold logic 
                            If the Opportunity entity is equal to Opportunity Team member user entity
                            Or
                            If the Opportunity's Account has an entity of All,
                            then only opportunity team member is created .
     
     *
     *  @args           :   List<OpportunityTeamMember>
     *
     *  @return         :   void
     *
     *  @revision Log   :   V1.0 - Created - 11/8/2017 - Subhash Garhwal - Issue--CR11753--QA--00007372
     * 
     **/
    public static void preventNewOpportunityTeamMember(List<OpportunityTeamMember> opportunitiyTeamMembers) {

        //Set to hold UeserId 
        Set<Id> setofUserId = new Set<Id>();
        Set<Id> setOfOpportunityId = new Set<Id>();

        //Loop over new opportunity Team member
        for(OpportunityTeamMember oppTeamMember : opportunitiyTeamMembers) {

            //Check for opportunityTeamMember User and opportunityTeamMember opportunity
            if(oppTeamMember.userId != null && oppTeamMember.OpportunityId != null) {

                //Add Value to set
                setofUserId.add(oppTeamMember.userId);
                setOfOpportunityId.add(oppTeamMember.opportunityId);
                
            }
        }
        
        //Check for Size
        if(setofUserId.size() > 0 && setOfOpportunityId.size() > 0) {

            //loop through User
            Map<Id,User> mapOfUser = new Map<Id,User>([Select Id, Entity__c From User where Id IN: setofUserId ]);
            Map<Id,Opportunity> mapOfOpportunity = new Map<Id,Opportunity>([Select Id, AccountId, Account.Entity__c, Entity__c From Opportunity where Id IN:setOfOpportunityId]);
        
            //Loop through Opportunity Team Member
            for(OpportunityTeamMember oppTeamMember : opportunitiyTeamMembers){

                //Check value contains in map
                if(mapOfUser.containsKey(oppTeamMember.userId) && mapOfOpportunity.containskey(oppTeamMember.opportunityId)) {
                
                    //Check for Entity 
                    if(mapOfUser.get(oppTeamMember.userId).Entity__c != mapOfOpportunity.get(oppTeamMember.opportunityId).Entity__c
                        &&  (mapOfOpportunity.get(oppTeamMember.opportunityId).AccountId == null
                             || mapOfOpportunity.get(oppTeamMember.opportunityId).Account.Entity__c != 'All')) 
                        throw new customException(Label.PREVENT_OPPORTUNITY_TEAM_MEMBER);
                            
                }   
            }
        }
    }
}