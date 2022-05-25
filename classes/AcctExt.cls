/*
    Purpose     :   Change Account Owner
    
    Create By   :   Rajeev Jain - 06/15/2016 - SFDC schema Release - Code Migration from Royall Enviournment
    
    Revision Log:   v1.0 - (AW) Created Code
*/
public class AcctExt {

    private Account Acct;
    
    public AcctExt(ApexPages.StandardController controller) {
        this.Acct = (Account) Controller.getRecord();
        this.Acct.r_NewOwner__c = [Select ownerid from Account where id = :this.Acct.id].Ownerid;
    }
    
    public pagereference save() {
    
        If (Acct.r_NewOwner__c != null) {
            Acct.Ownerid = Acct.r_NewOwner__c;
            update Acct;
        }
        
        
        // Send the user to the detail page for the new account. 
    
        PageReference acctPage = new ApexPages.StandardController(Acct).view();
        acctPage.setRedirect(true);
        return acctPage;
        
    }
}