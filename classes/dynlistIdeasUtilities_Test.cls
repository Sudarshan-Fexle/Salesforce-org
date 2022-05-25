@isTest(seeAllData=false)
private without sharing class dynlistIdeasUtilities_Test {

    @TestSetup
    static void setupData(){
       //Create sample record
       List<Idea> listOfIdea = new List<Idea>();
        
       Idea ida = new Idea();
       ida.Categories = 'Functionality - Reporting';
       ida.CommunityId = '09a5g000001PaP6AAK';
       ida.Title = 'Title Test Idea'; 
       ida.status = 'Not Planned';
       listOfIdea.add(ida);

       Idea ida1 = new Idea();
       ida1.Categories = 'Process Improvement';
       ida1.CommunityId = '09a5g000001PaP6AAK';
       ida1.Title = 'Title Test Idea'; 
       ida.status = 'New - Not Yet Reviewed';
       listOfIdea.add(ida1);

       insert listOfIdea;
    }
    
	@isTest(seeAllData=false)
    static void testgetIdeas(){

        Test.startTest();
            List<Idea> IdeaList = dynlistIdeasUtilities.getIdeas();
            System.assertEquals(true, IdeaList.size() > 0);
        Test.stopTest();   
    }
    
    @isTest(seeAllData=false)
    static void testgetMyIdeas(){

        Test.startTest();
            List<Idea> IdeaList = dynlistIdeasUtilities.getMyIdeas();
            System.assertEquals(true, IdeaList.size() > 0);
        Test.stopTest();   
    }
    
    //getCommentedByMeIdeas
    @isTest(seeAllData=false)
    static void testgetCommentedByMeIdeas(){
		
        List<Idea> getIdeaRecord = [SELECT id FROM Idea LIMIT 1];
        
        IdeaComment iComment = new IdeaComment(IdeaId = getIdeaRecord[0].Id);
        insert iComment;
        
        Test.startTest();
            List<IdeaComment> ideaCommentList = dynlistIdeasUtilities.getCommentedByMeIdeas();
            System.assertEquals(true, ideaCommentList.size() > 0);
        Test.stopTest();   
    }
    
    //getIdeaDetailsWithSelectedCategoryOrStatus
    @isTest(seeAllData=false)
    static void testgetIdeaDetailsWithSelectedCategory(){
		List<Idea> getIdeaRecord = [SELECT id FROM Idea Where Categories = 'Functionality - Reporting'];
        
        Test.startTest();
            List<Idea> IdeaListforCategory = dynlistIdeasUtilities.getIdeaDetailsWithSelectedCategoryOrStatus('Functionality - Reporting', 'category');
            System.assertEquals(true, IdeaListforCategory.size() > 0);
        Test.stopTest();   
    }
    
    @isTest(seeAllData=false)
    static void testgetIdeaDetailsWithSelectedStatus(){
		List<Idea> getIdeaRecord = [SELECT id FROM Idea Where Status = 'New - Not Yet Reviewed'];
        
        Test.startTest();
            List<Idea> IdeaListforStatus = dynlistIdeasUtilities.getIdeaDetailsWithSelectedCategoryOrStatus('New - Not Yet Reviewed', 'Status');
            System.assertEquals(true, IdeaListforStatus.size() > 0);
        Test.stopTest();   
    }
    
    @isTest(seeAllData=false)
    static void testgetVottedByMeIdeas(){

        Test.startTest();
            List<Idea> ideaList = dynlistIdeasUtilities.getVottedByMeIdeas();
            System.assertEquals(true, ideaList.size() > 0);
        Test.stopTest(); 
        
    }
    
}