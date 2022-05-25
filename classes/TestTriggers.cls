@isTest ( SeeAllData=true )
public class TestTriggers
{
    @isTest ( SeeAllData=true )
    public static void TestTrigger1()
    {
        Journal_Batch_Header__c objToInsert = new Journal_Batch_Header__c();
        
        objToInsert.Journal_Description__c = 'Test Journal Description';
        objToInsert.Period__c =  '2015/001';
        
        try
        {
                insert objTOInsert;
        }
        catch( Exception ex)
        {
            // do nothing
        }
    }
 }