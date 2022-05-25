/** 
*   Purpose         :   Wrapper class to hold Most recent Items
*
*   Created By      :   Rajeev Jain(Simplyforce)
*
*   Created Date    :   07/30/2015 - CR-9072
*
*   Revision Logs   :   V_1.0 - Created
*                       	
**/ 
public class MostRecentContentItemWrapper {
	
    public String linkLocation{get;set;}
    public String displayName{get;set;}
    public String containerId{get;set;}
    public String itemId{get;set;}
    public String scheduleId{get;set;}
    public String iconStyle{get;set;}
    public String target{get;set;}
    
    //Class Constructor
    public MostRecentContentItemWrapper(String linkLocation, String displayName, String containerId, String itemId, String scheduleId, String iconStyle, String target){
        this.linkLocation = linkLocation;
    	this.displayName = displayName;
        this.containerId = containerId;
        this.itemId = itemId;
        this.scheduleId = scheduleId;
        this.iconStyle = iconStyle;
        this.target = target;
    }
}