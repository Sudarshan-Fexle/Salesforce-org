/**
* Purpose	   :	Test Class for Test_Trigger_OtherUtilizations
*
* Create By	   :	Shalu Sharma
*
* Created Date	   :	01/20/2022
* 
* Current Version  :	V1.0
* 
* Revision Log	   :	V1.0 - Created By - Shalu Sharma - CR-20220120-15733 - 01/20/2022 - L1 Weekly Release - 1/21/2022 -Validation Error Fixes
* 
**/
@IsTest(seeAllData = false)
public class Test_Trigger_OtherUtilizations 
{
    static testMethod void testValidateEntityValue() 
    {
        try  
        {
            Util.byPassAllTriggers = true;
            
            List<Other_Utilization__c> otherUtilizations = new List<Other_Utilization__c>();
            otherUtilizations.add(new Other_Utilization__c(Name = 'Test Other Utilization'));
            
            Program__c prog = TestUtilities.createNewProgram(null, 'ESNN', 'No', 'Enrollment Services', false);
            insert prog;
            
            List<Program_Reference_MtM__c> programReferenceMtMs = new List<Program_Reference_MtM__c>();
            programReferenceMtMs.add(new Program_Reference_MtM__c(Program__c = prog.Id));
            
            Util.byPassAllTriggers = false;
            
            insert otherUtilizations;
            insert programReferenceMtMs;
        }
        catch(Exception e){} 
    }
    
    static testMethod void testValidateEntityValueForProgramReferenceMtM() 
    {
        try  
        {
            Util.byPassAllTriggers = true;
            
            Program__c prog = TestUtilities.createNewProgram(null, 'ESNN', 'No', 'Enrollment Services', false);
            insert prog;
            
            List<Program_Reference_MtM__c> programReferenceMtMs = new List<Program_Reference_MtM__c>();
            programReferenceMtMs.add(new Program_Reference_MtM__c(Program__c = prog.Id));
            
            Util.byPassAllTriggers = false;
            
            insert programReferenceMtMs;
        }
        catch(Exception e){} 
    }
}