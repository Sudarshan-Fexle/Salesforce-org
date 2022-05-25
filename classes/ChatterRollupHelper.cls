public without sharing class ChatterRollupHelper {
    
    public static void processRollups (List<FeedItem> chatterComments) {

        //Collect our scenarios from the Custom Metadata object
        List<Chatter_Rollup__mdt> activeRollups = getChatterRollupScenarios();

        //Map of Object Names and our Rules
        Map<String, List<Chatter_Rollup__mdt>> mapObjNameChatRollup = new Map<String, List<Chatter_Rollup__mdt>>();

        //Set of PostTypes
        Set<String> postTypes = new Set<String>();

        //Check to ensure we have values
        if (activeRollups.size() > 0) {

            //Gather our Map of Object Names we care about
            for (Chatter_Rollup__mdt cRollup : activeRollups){
                
                //Check to see if our Map contains Source Object
                if (mapObjNameChatRollup.get(cRollup?.Source_Object__c) != null){
                    List<Chatter_Rollup__mdt> chatRollups = mapObjNameChatRollup.get(cRollup.Source_Object__c);
                    chatRollups.add(cRollup);
                    mapObjNameChatRollup.put(cRollup.Source_Object__c, chatRollups);
                } else if (cRollup?.Source_Object__c != null) {
                    List<Chatter_Rollup__mdt> chatRollups = new List <Chatter_Rollup__mdt>();
                    chatRollups.add(cRollup);
                    mapObjNameChatRollup.put(cRollup.Source_Object__c, chatRollups);
                }
                
            }

        }

        //Check to see if our FeedItem is on an object we care about
        for (FeedItem chatterC : chatterComments){

            //String which will contain the Target Fields
            String targetFields;

            //Get out Object Type
            string objType = String.valueOf(chatterC.ParentId.getsobjecttype());

            //if we do not care about this Object Type then exit method
            if (!mapObjNameChatRollup.keyset().contains(objType)){
                return;
            }

            //Get our List of Records for the Object Type
            List<Chatter_Rollup__mdt> rollupRecords = mapObjNameChatRollup.get(objType);

            //Loop through our records and check our Post Types and Target Fields
            for (Chatter_Rollup__mdt cR : rollupRecords){

                //Add our Post Types we care about to a Set
                postTypes.add(cR.Post_Type__c);

                //Add our Target Fields to our Set
                if (targetFields == null){
                    targetFields = cR.Target_Field__c;
                } else {
		
                    if(!targetFields.contains(cR.Target_Field__c))
                    {
                        targetFields += ',';
                    	targetFields += cR.Target_Field__c;
                    }   
                }
            }

            //Check to see if have a relevant Post Type or else exit method
            if (!postTypes.contains(chatterC.Type)){
                return;
            }

            //Call our method to duplicate Chatter Post
            createDuplicateChatterPost(objType, targetFields, chatterC.ParentId, chatterC.Title, chatterC.Body, chatterC.Type, chatterC.LinkUrl);
        }

    }

    @future
    public static void createDuplicateChatterPost (String objectType, String targetFields, Id sourceId, String sourceTitle, String sourceBody, String sourceType, string urllink) {
        
        //Build our String for the Rollup
        String soqlString = 'SELECT Id, Name, ' + targetFields + ' FROM ' + objectType + ' WHERE Id = :sourceId';
        system.debug('soqlString: ' + soqlString);

        //Run our Query
        sObject ourRecord = database.query(soqlString);

        //List for our new FeedItems
        List<FeedItem> newChatterPosts = new List<FeedItem>();

        List<String> listTargetFields = targetFields.split(',');

        //Loop through our Target Fields
        for (String s : listTargetFields){

            //Get the Related Id
            Id newRecordId = (Id) ourRecord.get(s);
            String bodyAmendment ;
            
            system.debug('sourceType-- '+ sourceType);
            if(sourceType == 'ContentPost')
            {
                sourceType = 'TextPost';
                bodyAmendment = '<p>&nbsp;</p> Original Post contained a File. Please see original Chatter Post for the file link. Originally Posted on: ' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + sourceId;
            	bodyAmendment += '<p>&nbsp;</p> Original Record Name: ' + (String) ourRecord.get('Name');
                
            }
            else{
                //Add our Body Amendment Id & Name
                bodyAmendment = '<p>&nbsp;</p> Originally Posted on: ' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + sourceId;
                bodyAmendment += '<p>&nbsp;</p> Original Record Name: ' + (String) ourRecord.get('Name');
                
            }
            
            //Combine our two
            if(sourceBody.contains('<img'))
            {
                Integer startIndex = sourceBody.indexOf('<img');
                Integer endIndex = sourceBody.indexOf('</img>') + 6;
                String toRemove = sourceBody.substring(startIndex, endIndex);
                sourceBody = sourceBody.remove(toRemove); 
            }
            
            String amendedBody = sourceBody + bodyAmendment;

            //Build our New Feed Item
            FeedItem newRecord = new FeedItem (ParentId = newRecordId, Status = 'Published', Title = sourceTitle, Body = amendedBody, isRichText = true, Type = sourceType, LinkUrl = urllink);
            newChatterPosts.add(newRecord);

        }

        //Insert our Chatter Posts
        insert newChatterPosts;

    }

    public static List<Chatter_Rollup__mdt> getChatterRollupScenarios () {

        //Query for our Chatter Rollup Scenarios which are active
        List<Chatter_Rollup__mdt> activeRollupScenarios = [SELECT Id, Active__c, Post_Type__c, 
                                                           Target_Field__c, Source_Object__c
                                                           FROM Chatter_Rollup__mdt
                                                           WHERE Active__c = true];

        return activeRollupScenarios;

    } 

}