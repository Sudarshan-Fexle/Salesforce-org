/**
*   Purpose		:   Mock class for Test_UserTrigger
*   
*   Revision Log	:   Created By - Nikita Kumari - CR-20220128-15759 - Slack API - Use the users.lookupByEmail method to populate User.Slack_Id__c
**/
@isTest
global  class MockHTTPResponseGeneratorForSlackDetails implements HttpCalloutMock {
    
    // Implement this interface method    
    global HTTPResponse respond(HTTPRequest req) {
        
        // Create a fake response        
        HttpResponse res = new HttpResponse();
        
        res.setHeader('Content-Type', 'application/json');
        
        res.setBody('{"ok": true,"user": {"id": "W012A3CDE","team_id": "T012AB3C4","name": "Test",'+
                    '"deleted": false,"color": "9f69e7","real_name": "Test User1","tz": "America/Los_Angeles",'+
                    '"tz_label": "Pacific Daylight Time","tz_offset": -25200,"profile": {"avatar_hash": "ge3b51ca72de",'+
                    '"status_text": "Print is dead","status_emoji": ":books:","real_name": "Test User1",'+
                    '"display_name": "Test","real_name_normalized": "Test User1","display_name_normalized": "Test",'+
                    '"email": "testuser1@test.com","image_24": "https://.../avatar/e3b51ca72dee4ef87916ae2b9240df50.jpg",'+
                    '"image_32": "https://.../avatar/e3b51ca72dee4ef87916ae2b9240df50.jpg","image_48": "https://.../avatar/e3b51ca72dee4ef87916ae2b9240df50.jpg",'+
                    '"image_72": "https://.../avatar/e3b51ca72dee4ef87916ae2b9240df50.jpg","image_192": "https://.../avatar/e3b51ca72dee4ef87916ae2b9240df50.jpg",'+
                    '"image_512": "https://.../avatar/e3b51ca72dee4ef87916ae2b9240df50.jpg","team": "T012AB3C4"},'+
                    '"is_admin": true,"is_owner": false,"is_primary_owner": false,"is_restricted": false,"is_ultra_restricted": false,'+
                    '"is_bot": false,"updated": 1502138686,"is_app_user": false,"has_2fa": false}}');
        
        res.setStatusCode(200);        
        return res;        
    }
}