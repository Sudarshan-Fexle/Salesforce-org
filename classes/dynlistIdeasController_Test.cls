@isTest(seeAllData=false)
private without sharing class dynlistIdeasController_Test {

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
    static void testgetCategoryPickList(){

        Test.startTest();
            dynlistLightningResponseEntity wrapperList = dynlistIdeasController.getCategoryPickList();
            List<Idea> ideaList = [SELECT Id, Categories FROM Idea WHERE Categories = 'Functionality - Reporting'];
            System.assertEquals('Functionality - Reporting', ideaList[0].Categories);
        Test.stopTest();   
    }

    @isTest(seeAllData=false)
    static void testgetStatusPickList(){

        Test.startTest();
            dynlistLightningResponseEntity wrapperList = dynlistIdeasController.getStatusPickList();
            List<Idea> ideaList = [SELECT Id, status FROM Idea WHERE Status = 'New - Not Yet Reviewed'];
            System.assertEquals('New - Not Yet Reviewed', ideaList[0].status);
        Test.stopTest();
    }

    @isTest(seeAllData=false)
    static void testgetCommunityForIdeas(){
        List<Community> com = [SELECT Id, Name, IsActive FROM Community Where IsActive = true AND Name ='Internal Zone'];

        Test.startTest();
            dynlistLightningResponseEntity wrapperList = dynlistIdeasController.getCommunityForIdeas();
            System.assertEquals('Internal Zone', com[0].Name);
        Test.stopTest();
    }

    @isTest(seeAllData=false)
    static void testpostIdea(){

        Datetime dt = Datetime.newInstance(
               Date.newInstance(2022, 4, 22),Time.newInstance(1, 15, 18, 0)); 

        dynlistIdeasController.IdeaWrapper idWrapper = new dynlistIdeasController.IdeaWrapper('0875g000000XxZvAAK', 'Test Idea',  'description',  'Process Improvement', '09a5g000001PaP6AAK', 'New - Not Yet Reviewed',
            'Abhinav Sharma', dt, 3, 4, 6, true);

        String str = JSON.serialize(idWrapper); 

        Test.startTest();
            dynlistLightningResponseEntity wrapperList = dynlistIdeasController.postIdea(str);
        		List<Idea> ListOfIdea = [SELECT Id,Categories FROM Idea WHERE Categories = 'Process Improvement'];
        		System.assertEquals('Process Improvement', ListOfIdea[0].Categories);
        Test.stopTest();
    }


    @isTest(seeAllData=false)
    static void testgetAllIdeaDetails(){

        List<Idea> getIdeaRecord = [SELECT id FROM Idea];


        Test.startTest();
            dynlistLightningResponseEntity wrapperList = dynlistIdeasController.getAllIdeaDetails();
            List<Idea> ListOfIdea = [SELECT Id, Status FROM Idea WHERE Id =: getIdeaRecord[0].Id];
            System.assertEquals(true, ListOfIdea.size() > 0);
        Test.stopTest();
    }

    @isTest(seeAllData=false)
    static void testgetIdeaDetailsWithSelectedAction(){
        List<Idea> getIdeaRecord = [SELECT id FROM Idea LIMIT 1];
        
        IdeaComment iComment = new IdeaComment(IdeaId = getIdeaRecord[0].Id);
        insert iComment;
        
        Test.StartTest();

        dynlistLightningResponseEntity wrapperList = dynlistIdeasController.getIdeaDetailsWithSelectedAction('allIdeas', 'show');
        
        dynlistLightningResponseEntity wrapperList1 = dynlistIdeasController.getIdeaDetailsWithSelectedAction('myIdeas', 'show');
        
        dynlistLightningResponseEntity wrapperList2 = dynlistIdeasController.getIdeaDetailsWithSelectedAction('commentedByMeIdeas', 'show');
        
        dynlistLightningResponseEntity wrapperList3 = dynlistIdeasController.getIdeaDetailsWithSelectedAction('votedByMeIdeas', 'show');
        
        dynlistLightningResponseEntity wrapperList4 = dynlistIdeasController.getIdeaDetailsWithSelectedAction('status', 'show');

        List<Idea> ListOfIdea = [SELECT Id, Status FROM Idea WHERE Id =: getIdeaRecord[0].Id];
        System.assertEquals(true, ListOfIdea.size() > 0);

        Test.stopTest();
    }

    @isTest(seeAllData=false)
    static void testpostIdeaComment(){

        Datetime dt = Datetime.newInstance(
               Date.newInstance(2022, 4, 22),Time.newInstance(1, 15, 18, 0)); 

        dynlistIdeasController.IdeaWrapper idWrapper = new dynlistIdeasController.IdeaWrapper('0875g000000XxZvAAK', 'Test Idea',  'IdeaComment',  'Process Improvement', '09a5g000001PaP6AAK', 'New - Not Yet Reviewed',
            'Abhinav Sharma', dt, 3, 4, 6, true);

        String str = JSON.serialize(idWrapper); 

        Test.startTest();
            dynlistLightningResponseEntity wrapperList = dynlistIdeasController.postIdeaComment(str);
            List<ideaComment> listOfIdeaComment = [SELECT Id, CommentBody FROM IdeaComment WHERE IdeaId = '0875g000000XxZvAAK'];
            System.assertEquals('IdeaComment', listOfIdeaComment[0].CommentBody);
        Test.stopTest();
    }

    @isTest(seeAllData=false)
    static void testgetIdeaComment(){

        List<Idea> getIdeaRecord = [SELECT id FROM Idea LIMIT 1];

        IdeaComment iComment = new IdeaComment(IdeaId = getIdeaRecord[0].Id);
        insert iComment;

        Test.startTest();

        dynlistLightningResponseEntity wrapperList = dynlistIdeasController.getIdeaComment(getIdeaRecord[0].Id);

        List<IdeaComment> iCommentList = [SELECT Id FROM IdeaComment where CommunityId = '09a5g000001PaP6AAK'];
        System.assertEquals(true, iCommentList.size() > 0);

        Test.stopTest();
    } 

}