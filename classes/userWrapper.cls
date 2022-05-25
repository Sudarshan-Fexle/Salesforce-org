/**
*  Description     :  Wrapper class for the userGrid LWC
*
*	Revision Logs   :  V_1.0 - 08/13/2020 - Abhinav Sharma - Created
**/
global class userWrapper implements Comparable 
{    
    @AuraEnabled
    public User u { get; set; }
    @AuraEnabled
    public String label { get; set; }
    @AuraEnabled
    public String url { get; set; }
    
    // Constructor
    public userWrapper(User u, String label) 
    {
        this.u = u;
        this.label = label;
        this.url = '/' + u.Id;
    }
    
    // Implement the compareTo() method
    global Integer compareTo(Object compareTo) 
    {
        userWrapper compareToUserWrap = (userWrapper)compareTo;
        if (label == compareToUserWrap.label) return 0;
        if (label > compareToUserWrap.label) return 1;
        return -1;        
    }
}