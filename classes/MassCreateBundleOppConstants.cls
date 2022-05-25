/**
*  Description      :   Class to hold the constants related to the "Mass Create Bundle Opportunity" functionality.
*
*  Created By       :   Abhinav Sharma
*
*  Created Date     :   09/15/2014
*
*  Revision Logs    :   V_1.0 - Created
*						V_1.1 - Modifield by - Mahendra Swarnkar - CR-20151022-9350 - Added a new constant "CONSULTING_AND_MANAGEMENT"
*						V_1.2 - Modified by - Victor Hanson - CR-20170403-10808 - Updated so this only has to query for opportunity stage once
*
**/  
public class MassCreateBundleOppConstants {
    
    //Constants variables
    public final static string RECORDTYPE = 'RecordType';
    public final static String OPPORTUNITY = 'Opportunity';
    public final static string PT_MARKETING = 'BI_Marketing';
    public final static string RI_MARKETING = 'Core_Marketing';
    //Commented By - Mahendra Swarnkar - 02/25/2021 - CR-20210122-14829 - Southwind deleted from Opportunity record type
    //public final static string SOUTHWIND = 'Southwind';
    
    //Added by - Mahendra Swarnkar - 12/042015 - CR-20151022-9350
    public final static string CONSULTING_AND_MANAGEMENT = 'Consulting & Management';
    
    public final static string BACKSLASH = '/';
    public final static String BUNDLE_RETURN_URL = '/a00/o';
    public final static string PT_MARKETING_LABEL = 'PT Marketing';
    public final static string RI_MARKETING_LABEL = 'RI Marketing';
    public final static string RETURL_URL = 'retURL';
    public final static string ID_Paramter = 'id';
    public final static string OPPORTUNITY_RETURN_URL = '/006/o';
    public final static string WILL_AUTO_POPULATE = 'Will Auto-Populate';
    public final static string BUNDLE = 'Bundle';
    public final static string DASH_SIGN = '-';
    public final static string NEW_ID = 'newid';
    public final static string OPP_EDIT_PAGE_INITIAL_PREFIX = '/006/e?ent=Opportunity&nooverride=1&opp3=Will+Auto-Populate';
    public final static string RECORD_TYPE = 'RecordType';
    public final static string SAVE_URL = 'saveURL';
    public final static string RETURN_PAGE_URL = '/apex/MassCreateBundleOpportunities?id='; 
    
    public static list<OpportunityStage> opportunityStages {
        get {
            
            if (opportunityStages == null) {
                
                opportunityStages = new list<OpportunityStage>();
                for(OpportunityStage oppStage : [Select MasterLabel, IsActive, IsClosed, IsWon From OpportunityStage]) 
                {
                    if(String.isNotBlank(oppStage.MasterLabel))
                        opportunityStages.add(oppStage);           
                }
            }
            
            return opportunityStages;
        }
        set;
    }
    
    //Set of "Close Won" type statuses for Case StageName field
    public static Set<String> setClosedWonStatus {
        
        get {
            
            if (setClosedWonStatus == null) {
                
                setClosedWonStatus = new Set<String>();
                
                for(OpportunityStage oppStage : opportunityStages) 
                {
                    if(String.isNotBlank(oppStage.MasterLabel) && oppStage.IsActive && oppStage.IsClosed && oppStage.IsWon)
                        setClosedWonStatus.add(oppStage.MasterLabel);           
                }
            }
            return setClosedWonStatus;
        }
    }
    
    //Set of "Close Lost" type statuses for Case StageName field
    public static Set<String> setClosedLostStatus {
        
        get {
            
            if(setClosedLostStatus == null) {
                
                setClosedLostStatus = new Set<String>();
                
                for(OpportunityStage oppStage : opportunityStages) {
                    if(String.isNotBlank(oppStage.MasterLabel) && oppStage.IsActive && oppStage.IsClosed && oppStage.IsWon == false)
                        setClosedLostStatus.add(oppStage.MasterLabel);           
                }
            }
            return setClosedLostStatus;
        }
    }
    
    //Set of "Open" type statuses for Case StageName field
    public static Set<String> setOpenStatus {
        
        get {
            
            if (setOpenStatus == null) {
                
                setOpenStatus = new Set<String>();
                
                for(OpportunityStage oppStage : opportunityStages) {
                    if(String.isNotBlank(oppStage.MasterLabel) && oppStage.IsActive && oppStage.IsClosed == false)
                        setOpenStatus.add(oppStage.MasterLabel);          
                }
            }
            return setOpenStatus;
        }
    }
}