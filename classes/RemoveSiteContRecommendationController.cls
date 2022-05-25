/*
 * Purpose		:	To delete Site Content Recommendation Records
 * 
 * CreatedDate	: 	11/10/2019
 * 
 * RevisionLog	:	V_1.0 -Created - Dipesh Gupta -CR-20190823-13280
*/
public class RemoveSiteContRecommendationController 
{
    public List<WrapperOfSiteContRecommendation> wrapperData {get;set;}
    public Integer count {get;set;}
    public Boolean isDataAvailable {get;set;}
    String  accountId = '';
    public Boolean uncheckWhenDelete {get;set;}
    // Constructor
    public RemoveSiteContRecommendationController()
    {
        isDataAvailable = false;
        wrapperData = new List<WrapperOfSiteContRecommendation>();
        accountId   = ApexPages.currentPage().getParameters().get('institutionId');
        if(accountId != null)
        {
        	init();   
        }
    }
    
    public void init() {
        
        List<Site_Content_Recommendation__c> siteContRecommendations = new List<Site_Content_Recommendation__c>([SELECT Id, Name, Contact__r.Name, Site_Profile__r.Name, Site_Content__r.Name 
                                                                        FROM Site_Content_Recommendation__c WHERE Institution__c =: accountId]);
        count = siteContRecommendations.size();
        
        if(siteContRecommendations.size() > 0)
        {
            wrapperData = new List<WrapperOfSiteContRecommendation>();
            isDataAvailable = true;
            for(Site_Content_Recommendation__c scr : siteContRecommendations)
            {
                WrapperOfSiteContRecommendation wrap = new WrapperOfSiteContRecommendation(scr, false);
                wrapperData.add(wrap);
            }    
        }
        else
        {
            isDataAvailable = false;
        }
    }
    
    /*
     * @Purpose		:	Method to delete the selected Site Content Recommendation records in vf page.
     * 
     * @Args		:		
     * 
     * @ReturnType	:	Void
     * 
     * @RevisionLog	:	V_1.0 -Created - Dipesh Gupta	
     * */
    public void deleteSelectedSiteContRecommendation()
    {
        List<Site_Content_Recommendation__c> siteContentRecommendationsToDelete = new List<Site_Content_Recommendation__c>();
        List<Id> siteContRecIds = new List<Id>();
        for(WrapperOfSiteContRecommendation wrap : wrapperData)
        {
            if(wrap.check == true)
                siteContentRecommendationsToDelete.add(wrap.siteContRecommendation);
        }
        
        if(siteContentRecommendationsToDelete.size() > 0)
        {
            try
            {
                spin();
                delete 	siteContentRecommendationsToDelete;
                uncheckWhenDelete = false;
                init();
            }
            catch(Exception ex)
            {
            	system.assert(false, 'error...'+ex.getMessage());    
            }   
        }
        //return null;
    }
    
    public void spin() {
        long now = datetime.now().gettime();
        while(datetime.now().gettime()-now<5000); // Busy loop for 3000 ms 
    }
    
    public PageReference redirectToInstitution()
    {
        PageReference ref = new PageReference('/'+accountId);
        ref.setRedirect(true);
        return ref;
    }
    
    /*
     * Wrapper Class with following attributes: Site_Content_Recommendation__c siteContRecommendation, Boolean check
     * 
	*/
    public class WrapperOfSiteContRecommendation
    {
        public Site_Content_Recommendation__c siteContRecommendation {get;set;}
        public Boolean check {get;set;}
        public WrapperOfSiteContRecommendation(Site_Content_Recommendation__c siteContRecommendation, Boolean check)
        {
            this.siteContRecommendation = siteContRecommendation;
            this.check = check;
        }
    }
}