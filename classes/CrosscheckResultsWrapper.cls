/**
*  Desription      :   Wrapper Class To hold the Overlapping Results, used in Crosscheck Controller, DeloymentWizardCrosscheck Component and Deployment Wizard VF page - OneClick Deploy
* 
*  Created By      :   Rajeev Jain(Simplyforce)
* 
*  Created Date    :   02/25/2017
* 
*  Revision Logs   :   V1.0 - Created
*
**/ 
public class CrosscheckResultsWrapper {
    
	
    //Hold the Crosscheck Result Insatance as Main Overlapping Result
    public Crosscheck_Result__c mainMod {get;set;}
    
    //List to hold the Overlapping mods Results
    public list < Crosscheck_Result__c > overlappingMods {get; set;}
    
    public CrosscheckResultsWrapper(){}
    
    //Constructor with argument as Crosscheck Result
    public CrosscheckResultsWrapper(Crosscheck_Result__c mainMod) {
        
        //Assign the Result
        this.mainMod = mainMod;
        
        //Instantiate the overlapping Results list
        overlappingMods = new list < Crosscheck_Result__c > ();
    }
}