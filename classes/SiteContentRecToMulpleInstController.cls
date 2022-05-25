public class SiteContentRecToMulpleInstController {

    
    //Variables
    public Account acc{get; set;}
    
    public SiteContentRecToMulpleInstController(ApexPages.StandardController controller) {
        
        //Grab our Record
        acc = (Account)controller.getRecord();
        
        acc = [Select Id, Name From Account Where Id =: acc.Id];
        
        
    }

}