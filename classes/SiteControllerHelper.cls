/**
Desription      :   Contains helper methods for site controller for EAB.com/Advisory.com.

Created By      :   Victor Hanson

Created Date    :   07/29/2014

Revision Logs   :   V1 - Created
                    V1.1 - Modified By - Neha Sharma - 05/20/2021 - CR-20190620-13192 - Integrating subscription data from Marketo to Salesforce - old object removal
**/ 
public class SiteControllerHelper {
	
    //CONSTANTS
    public final static String ADVISORY_SITE_USER_TYPE = 'Guest';
    public final static String UNSUBSCRIBE_BY_MEMBER = 'Inactive - Unsubscribed by Member';
    public final static String UNSUBSCRIBE_BY_SF_USER = 'Inactive - Unsubscribed by ' + UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
    public final static String SUBSCRIPTION_ACTIVE = 'Active';
    public final static String SUBSCRIPTION_CATEGORY_PRODUCT = 'EMAIL_WATCH';
    public final static String SUBSCRIPTION_CATEGORY_DAILY = 'EMAIL_DAILY';
    public final static String SUBSCRIPTION_CATEGORY_BLOG = 'EMAIL_BLOG';
    public final static String SUBSCRIPTION_CATEGORY_TOPIC = 'EMAIL_TOPICS';
    public final static string STRING_EDUCATION = 'Education';
    public final static String ProdKey = 'jTpjNkrQGmZdREP2G1HaxhEeHsDhOK+eC5d2ttr3cxE=';
    public final static String SandboxKey = '9WVAaQl734oCfJBIFrH1czDwueCOvDpOAI+wzbUTDm4=';
    
    /**
     * @description:	key used for the Advisory / EAB site integration
     * 
     **/
	public static Blob KEY {
		get {
			if (KEY == null) {
				if (SiteUserHelper.sitecoreSettings.Encryption_Key__c != null)
					KEY = EncodingUtil.base64Decode(SiteUserHelper.sitecoreSettings.Encryption_Key__c);
				else {
					KEY = EncodingUtil.base64Decode(SandboxKey);
				}
			}
			return KEY;
		}
		set;
	}
    
    public static list<string> catgories {
    	get {
    		if (catgories == null) {
    			catgories = new list<string> { 'EMAIL_DAILY', 'EMAIL_TOPICS', 'EMAIL_WATCH', 'EMAIL_BLOG' };
    		}
    		return catgories;
    	}
    	set;
    }
    
    //contact wrapper class that is used on the sites pages for EAB/ADV.com
    public class ContactWrapper {
        
        public Contact Con { get; set; }
        
        //Commented By - Neha Sharma - 05/20/2021 - CR-20190620-13192 - Integrating subscription data from Marketo to Salesforce - old object removal
        // prepare the list of potential Advisory subscription signups
        /*public List<SiteSubscriptionHelper.SubscriptionWrapper> DailyBriefing_Advisory {
            get {
                if (DailyBriefing_Advisory == null) DailyBriefing_Advisory = new List<SiteSubscriptionHelper.SubscriptionWrapper>();
                return DailyBriefing_Advisory;
            }
            set;
        }
        
        public List<SiteSubscriptionHelper.SubscriptionWrapper> Topic_Advisory {
            get {
                if (Topic_Advisory == null) Topic_Advisory = new List<SiteSubscriptionHelper.SubscriptionWrapper>();
                return Topic_Advisory;
            }
            set;
        }
        
        public List<SiteSubscriptionHelper.SubscriptionWrapper> ProductOrMembership_Advisory {
            get {
                if (ProductOrMembership_Advisory == null) ProductOrMembership_Advisory = new List<SiteSubscriptionHelper.SubscriptionWrapper>();
                return ProductOrMembership_Advisory;
            }
            set;
        }
        
        public List<SiteSubscriptionHelper.SubscriptionWrapper> BlogAndProject_Advisory {
            get {
                if (BlogAndProject_Advisory == null) BlogAndProject_Advisory = new List<SiteSubscriptionHelper.SubscriptionWrapper>();
                return BlogAndProject_Advisory;
            }
            set;
        }
        
        // prepare the list of potential EAB subscription signups
        public List<SiteSubscriptionHelper.SubscriptionWrapper> DailyBriefing_EAB {
            get {
                if (DailyBriefing_EAB == null) DailyBriefing_EAB = new List<SiteSubscriptionHelper.SubscriptionWrapper>();
                return DailyBriefing_EAB;
            }
            set;
        }
        
        public List<SiteSubscriptionHelper.SubscriptionWrapper> Topic_EAB {
            get {
                if (Topic_EAB == null) Topic_EAB = new List<SiteSubscriptionHelper.SubscriptionWrapper>();
                return Topic_EAB;
            }
            set;
        }
        
        public List<SiteSubscriptionHelper.SubscriptionWrapper> ProductOrMembership_EAB {
            get {
                if (ProductOrMembership_EAB == null) ProductOrMembership_EAB = new List<SiteSubscriptionHelper.SubscriptionWrapper>();
                return ProductOrMembership_EAB;
            }
            set;
        }
        
        public List<SiteSubscriptionHelper.SubscriptionWrapper> BlogAndProject_EAB {
            get {
                if (BlogAndProject_EAB == null) BlogAndProject_EAB = new List<SiteSubscriptionHelper.SubscriptionWrapper>();
                return BlogAndProject_EAB;
            }
            set;
        }
        
        // prepare the list of potential subscription signups
        public map<string, list<SiteSubscriptionHelper.SubscriptionWrapper>> mapTypeToSubscriptionList_Advisory {
        	get {
        		if (mapTypeToSubscriptionList_Advisory == null)
                    mapTypeToSubscriptionList_Advisory = new map<string, list<SiteSubscriptionHelper.SubscriptionWrapper>>();
                return mapTypeToSubscriptionList_Advisory;
        	}
        	set;
        }
        
        public map<string, list<SiteSubscriptionHelper.SubscriptionWrapper>> mapTypeToSubscriptionList_EAB {
        	get {
        		if (mapTypeToSubscriptionList_EAB == null)
                    mapTypeToSubscriptionList_EAB = new map<string, list<SiteSubscriptionHelper.SubscriptionWrapper>>();
                return mapTypeToSubscriptionList_EAB;
        	}
        	set;
        }
        
        
        // eligible subscriptions
        public List<SiteSubscriptionHelper.SubscriptionWrapper> EligibleSubscriptions { get; set; }
        */
        public String OrgSearchString { get; set; }
        
        public ContactWrapper(Contact contact, boolean FindEligibleSubscriptions) {
            Con = contact;
            
            set<string> siteProfileTypes = new set<string>();
             
            for (Site_Profile__c sp : contact.Site_Profiles__r) {
            	siteProfileTypes.add(sp.Type__c.toLowerCase());
            }
            
            if (FindEligibleSubscriptions) {
                //Commented By - Neha Sharma - 05/20/2021 - CR-20190620-13192 - Integrating subscription data from Marketo to Salesforce - old object removal
                /*EligibleSubscriptions = SiteSubscriptionHelper.FindSubscriptionOptions(contact);
                
                // place the subscriptions in to their appropriate categories
                for (SiteSubscriptionHelper.SubscriptionWrapper subscription : EligibleSubscriptions) {
                    // go to the next record if the category is null
                    if (subscription.Category == null || subscription.ApplicableSegments == null) continue;
                    
                    //if the applicable segment contains 'Education', it's an EAB program, otherwise, Advisory
                    if (subscription.ApplicableSegments.containsIgnoreCase(STRING_EDUCATION) 
	                    && siteProfileTypes.contains(SiteUserHelper.SITE_EAB)) 
                    {
                    	list<SiteSubscriptionHelper.SubscriptionWrapper> tempEABSubList = mapTypeToSubscriptionList_EAB.get(subscription.Category);
                    	if (tempEABSubList == null) tempEABSubList = new list<SiteSubscriptionHelper.SubscriptionWrapper>();
                    	tempEABSubList.add(subscription);
                    	mapTypeToSubscriptionList_EAB.put(subscription.Category, tempEABSubList);
                    }
                    else if (siteProfileTypes.contains(SiteUserHelper.SITE_ADVISORY) && !subscription.ApplicableSegments.containsIgnoreCase(STRING_EDUCATION)) {
                    	list<SiteSubscriptionHelper.SubscriptionWrapper> tempAdvisorySubList = mapTypeToSubscriptionList_Advisory.get(subscription.Category);
                    	if (tempAdvisorySubList == null) tempAdvisorySubList = new list<SiteSubscriptionHelper.SubscriptionWrapper>();
                    	tempAdvisorySubList.add(subscription);
                    	mapTypeToSubscriptionList_Advisory.put(subscription.Category, tempAdvisorySubList);
                    }
                }
                // sort each list
                for (list<SiteSubscriptionHelper.SubscriptionWrapper> subWrapperList : mapTypeToSubscriptionList_EAB.values()) {
                	subWrapperList.sort();
                }
                for (list<SiteSubscriptionHelper.SubscriptionWrapper> subWrapperList : mapTypeToSubscriptionList_Advisory.values()) {
                	subWrapperList.sort();
                }
                
                
                for (string s : catgories) {
                    if (s.equalsIgnoreCase(SUBSCRIPTION_CATEGORY_DAILY)) {
                        if (mapTypeToSubscriptionList_Advisory.containsKey(s)) {
                            DailyBriefing_Advisory.addAll(mapTypeToSubscriptionList_Advisory.get(s));
                        }
                        if (mapTypeToSubscriptionList_EAB.containsKey(s)) {
                            DailyBriefing_EAB.addAll(mapTypeToSubscriptionList_EAB.get(s));
                        }
                    }
                    if (s.equalsIgnoreCase(SUBSCRIPTION_CATEGORY_TOPIC)) {
                        if (mapTypeToSubscriptionList_Advisory.containsKey(s)) {
                            Topic_Advisory.addAll(mapTypeToSubscriptionList_Advisory.get(s));
                        }
                        if (mapTypeToSubscriptionList_EAB.containsKey(s)) {
                            Topic_EAB.addAll(mapTypeToSubscriptionList_EAB.get(s));
                        }
                    }
                    if (s.equalsIgnoreCase(SUBSCRIPTION_CATEGORY_PRODUCT)) {
                        if (mapTypeToSubscriptionList_Advisory.containsKey(s)) {
                            ProductOrMembership_Advisory.addAll(mapTypeToSubscriptionList_Advisory.get(s));
                        }
                        if (mapTypeToSubscriptionList_EAB.containsKey(s)) {
                            ProductOrMembership_EAB.addAll(mapTypeToSubscriptionList_EAB.get(s));
                        }
                    }
                    if (s.equalsIgnoreCase(SUBSCRIPTION_CATEGORY_BLOG)) {
                        if (mapTypeToSubscriptionList_Advisory.containsKey(s)) {
                            BlogAndProject_Advisory.addAll(mapTypeToSubscriptionList_Advisory.get(s));
                        }
                        if (mapTypeToSubscriptionList_EAB.containsKey(s)) {
                            BlogAndProject_EAB.addAll(mapTypeToSubscriptionList_EAB.get(s));
                        }
                    }
                }*/
                
            }
        }
        
        public ContactWrapper() {
            Con = new Contact();
        }
        
    }
    
    /**
     * @description:	determines if the current user is a guest or not.  If not, it means they are an internal SF user.
     * 
     **/
    public static boolean IsGuestUser {
        get {
            if (UserInfo.getUserType().toLowerCase().contains('guest'))
                return true;
            else
                return false;
        }
        set;
    }
}