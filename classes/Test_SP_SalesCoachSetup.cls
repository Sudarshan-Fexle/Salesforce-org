@isTest
public class Test_SP_SalesCoachSetup {
	
    // Modified By Rajeev Jain - 30July2020 - Add starttest & stoptest to solve 101 SOQL Error
    static testMethod void SP_SalesCoachSetup() {
      
      SP_TestingUtil obj = new SP_TestingUtil();
      SP_SalesCoachSetup SCS = new SP_SalesCoachSetup();
      System.assert(SCS.getShowSections()!=null);
      SCS.getScStage();
      System.assert(SCS.getScActivities()==null);
      System.assert(SCS.getSwi()==null);
      System.assert(SP_SalesCoachSetup.getOpptyStages()!=null);
      System.assert(SCS.getSections()==null);
      SCS.saveSections();
      SCS.stage='Closed Won';
      SCS.getSections();
        
      test.startTest();
        
      SCS.stage='Prospecting';      
      System.assert(SCS.getSections()==null);
      SCS.saveActivities();
      SCS.saveStage();      
      SCS.saveSections();
      SCS.deleteSection();
      SCS.deleteActivity();
      SCS.deleteSectionItem();
        
      test.stopTest();
        
      System.debug('!!!!!!!!!!!!END OF TESTS!!!!!!!!!!!!!!!!!');
	} 
}