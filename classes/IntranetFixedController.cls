/**
    Purpose:    This controller is to control the component block items displayed on Boardroom Page.
                
    Created By:  Colin McGloin
    
    Created Date:   7/21/2014
    
    Current Version:    v1.0
    
    Revision Log:       
 **/

public class IntranetFixedController {
    
    	public Id BoardroomHeader { get; set; }
        public Id BoardroomBody { get; set; }
    	public String QuickLinks { get; set; }
    	public Intranet_Container__c ic;
    
    	//public IntranetType.FixedContainer itemType {get; set;}
    	public IntranetContainer items {get; set;}
    
    public IntranetFixedController() {
        //if(ic == null){
        //    GetPageHeader();
        //}
        
		//sitemType = new IntranetType.FixedContainer(items);
		
    }
 
 /*   
    public IntranetType.FooterContainer BoardroomFooter{
        get{
            return IntranetHomeUtility.getFooterContent(ic.Footer_Container__c);
        }
        set;
    }
    
    public IntranetType.Container BodyCont{
        get{
            return IntranetHomeUtility.getContainers(ic.Name);
        }
        set;
    }
    
	//class to search for Header  
    public void GetPageHeader() {
        
        ic = [SELECT Id, Name, Header_Container__c, Footer_Container__c FROM Intranet_Container__c WHERE Id = :Label.IntranetMainPage];
        BoardroomBody = ic.Id;
		system.debug('IntranetFixedController.GetPageHeader - ic:' + ic);
		        
    }
    
    public void GetQuickLinks() {
        
        ic = [SELECT Id, Name FROM Intranet_Container__c WHERE Name = 'QuickLinks'];
            QuickLinks = ic.Id;
        system.debug('IntranetFixedController.GetQuickLinks - ic:' + ic);
    }
    */
}