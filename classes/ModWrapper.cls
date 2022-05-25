/**
*  Desription      :   Wrapper Class for Deployment Auto mation 
* 
*  Created By      :   Team = The Griffin. (As a part of Heckthon - 4-22-2017)
* 
*  Created Date    :   4/22/2017
* 
*  Revision Logs   :   V1.0 - Created
*
**/ 
public  class ModWrapper {
    
    //Is system modification Instance
    public IS_System_Modification__c mainMod {get;set;}
    
    //List to hold the Overlapping mods
    public list < IS_System_Modification__c > overlappingMods {get; set;}
    
    //Constructor with argument as modification
    public modWrapper(IS_System_Modification__c mainMod) {
        
        //Assign the mods
        this.mainMod = mainMod;
        
        //Instantiate the overlapping mods list
        overlappingMods = new list < IS_System_Modification__c > ();
    }
}