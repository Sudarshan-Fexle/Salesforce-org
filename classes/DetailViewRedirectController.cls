/**
*	Desription      :	Controller class to hold the logic of navigation to appropriate object related VF detail page.
* 
*	Created By      :   Mahendra Swarnkar
* 
*	Created Date    :   04/30/2016
*  
*	Revision Logs   :   	V1.0 - Created
			:	V1.1 - Modified By - Mahendra Swarnakar - CR-20160308-9682
				V1.2 - Modified - 6/13/2016 - Subhash Garhwal - CR-20160414-9762 - Added Logic for additional record types (Q2C part)
				V1.3 - Modified - 8/27/2016 - Subhash Garhwal - CR-20160414-9762 - Added Logic to redirect users on VF page for std layouts to enable inline editing.
				V1.4 - Modified By - Mahendra Swarnkar - 03/17/2020 - CR-20200217-13756 - RT deleted : Consulting & Management From Opportunity.
*
**/
public class DetailViewRedirectController {
	
    //Commented by Mahendra Swarnkar - 03/17/2020 - CR-20200217-13756 - RT deleted : Consulting & Management From Opportunity.
    //Constants Variables
    //public final static string OPP_RECORD_TYPE_SOUTHWIND = 'Southwind';
    //public final static string ACCOUNT_RECORD_TYPE_US_PROVIDER_STRATEGIC = 'US_Provider_Strategic'; 
    public final static string MEMBERSHIP_RECORD_TYPE_RECORD_TYPE_1 = 'Record_Type_1';
    
    public final static string MEMBERSHIP_VIEW = 'MembershipView'; 
    public final static string APEX_URL_INITIAL_PREFIX = '/apex/';
    public final static string BACK_SLASH_VAR = '/';
    public final static string NO_OVERRIDE = 'nooverride';
    public final static string ID_PARAM = 'id';
    public final static string STDOPPORTUNITYDETAIL = 'StdOpportunityDetail';
    
	//SObject Instance
    Public sObject sObj {get; set;}
    
    //Map of record type names that should be redirected to the custom VF page
    //It will have kay vaue pair - Object Type as a key and set of record types as a value
	private Map<Schema.sObjectType,Set<String>> mapObjectNameWithListOfRecordTypesToRedirect {

		get {
            
            //Check for size
			if(mapObjectNameWithListOfRecordTypesToRedirect == null 
                || (mapObjectNameWithListOfRecordTypesToRedirect.get(sObj.getSObjectType()) == null)) {
                mapObjectNameWithListOfRecordTypesToRedirect = new Map<Schema.sObjectType,Set<String>>();
                	
                	//Set to hold the Opportunity Record Types (Developer Name)
                	Set<String> set_Opportunity_RT_DeveloperName = new Set<String>();
                	
                    	//Commented by Mahendra Swarnkar - 03/17/2020 - CR-20200217-13756 - RT deleted : Consulting & Management From Opportunity.
                	//Add Record Type in set
                	//set_Opportunity_RT_DeveloperName.add(OPP_RECORD_TYPE_SOUTHWIND);
                	
                	//Add CPQ related record types
                	set_Opportunity_RT_DeveloperName.addAll(CPQConstants.SET_OPPORTUNITY_CPQ_RT_DEVELOPER_NAME);
                   
                    mapObjectNameWithListOfRecordTypesToRedirect.put(Schema.Opportunity.SObjectType, set_Opportunity_RT_DeveloperName);
                    mapObjectNameWithListOfRecordTypesToRedirect.put(Schema.Membership__c.SObjectType, new set<string>{MEMBERSHIP_RECORD_TYPE_RECORD_TYPE_1});
			}
            return mapObjectNameWithListOfRecordTypesToRedirect;
		} set;
	}
    
	//Standard controller constructor
	public DetailViewRedirectController(ApexPages.StandardController controller) {
		
        //Getting/Reteriving current context opportunity record details
        sObj = controller.getRecord();
	}
    
    /**
     *  @description    :	Method will have the detail page navigation logic with it.
     *
     *  @args           :	void
     *
     *  @return         :   PageReference
     *
    **/
	public PageReference redirectTo() {

        //Create a new Pagereference instance
        PageReference pageRef;
        
        //Check, wheather the redirect page is defined for user is defined for the same record type
        If(mapObjectNameWithListOfRecordTypesToRedirect != null
           && mapObjectNameWithListOfRecordTypesToRedirect.get(sObj.getSObjectType()) != null){
            
            //Check for the opporutnity object
            if(sObj.getSObjectType() == Schema.Opportunity.SObjectType){
            	
				//Type cast
				Opportunity opportunity = (Opportunity) sObj;
                
                //Check for size and check for eligible record type
                if(opportunity.RecordType.DeveloperName != null
                   && mapObjectNameWithListOfRecordTypesToRedirect.get(sObj.getSObjectType()).contains(opportunity.RecordType.DeveloperName)
                   && CPQConstants.MAP_OPPORTUNITY_RECORD_TYPE_WITH_DETAIL_VF_PAGE_NAME.containsKey(opportunity.RecordType.DeveloperName)) {
                    
                    //Setting pagerefence to navigate the user to custom VF page        
                    pageRef = new PageReference(APEX_URL_INITIAL_PREFIX + CPQConstants.MAP_OPPORTUNITY_RECORD_TYPE_WITH_DETAIL_VF_PAGE_NAME.get(opportunity.RecordType.DeveloperName));
                    pageRef.getParameters().put(ID_PARAM, opportunity.Id);
                    pageRef.setRedirect(true);
                    
                    //Redirect user on appropriate page
                    return pageRef;
            	}
            	
            	//Added - Subhash Garhwal - 08/27/2016
				//Setting pagerefence to navigate the user to custom VF page        
		        pageRef = new PageReference(APEX_URL_INITIAL_PREFIX + STDOPPORTUNITYDETAIL);
		        pageRef.getParameters().put(ID_PARAM, opportunity.Id);
		        pageRef.setRedirect(true);
		        
		        //Redirect user on appropriate page
				return pageRef;
        	}
            
            //Else check for the Membership object
            else if(sObj.getSObjectType() == Schema.Membership__c.SObjectType){
            	
				//Type cast
				Membership__c membership = (Membership__c) sObj;
                
                //Check for size and check for eligible record type
                if(membership.RecordType.DeveloperName != null
                   && mapObjectNameWithListOfRecordTypesToRedirect.get(sObj.getSObjectType()).contains(membership.RecordType.DeveloperName)) {
                    
                    //Setting pagerefence to navigate the user to custom VF page        
                    pageRef = new PageReference(APEX_URL_INITIAL_PREFIX + MEMBERSHIP_VIEW);
                    pageRef.getParameters().put(ID_PARAM, membership.Id);
                    pageRef.setRedirect(true);
                    
                    //Redirect user on appropriate page
                    return pageRef;
            	}
        	}
		}
		
		//else redirect user on standard page
        pageRef = new PageReference(BACK_SLASH_VAR + sObj.Id);
        pageRef.getParameters().put(NO_OVERRIDE, '1');
        
        return pageRef;
	}
}