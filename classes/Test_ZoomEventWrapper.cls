/**
 * 	Description 	:	Test class for ZoomEventWrapper Class 
 * 
 * 	Revision Logs	:	V1.0 - 07/07/2021 - Chirag Soni - Created w.r.t CR-20211005-15489
 * 			
 **/

@isTest
private class Test_ZoomEventWrapper {
    
    static testmethod void testZoomEventWrapper(){
        
        //create a json body in order to fill the ZoomEventWrapper Class
        String JsonBody =   '{'
                                +'"page_count":1, '
                                +'"page_size":2, '
                                +'"total_records":3, '
                                +'"next_page_token":"Yes", '
                                +'"participants":['
                                +'{"id":"b6lKhyaZTQuZNGvxbRY9Ow","user_id":"16778240","name":"National Meetings 2", '             //-user 0
                                +'"user_email":"testZoomSessions0@eab.edu","join_time":"2021-03-30T17:39:35Z", '
                                +'"leave_time":"2021-03-30T18:58:56Z","duration":4761,"attentiveness_score":"","customer_key":""}, ' 
                                +'{"id":"K9vBg9A0TSOyQ9TaT4B1Wg","user_id":"16787456","name":"Ryan Quillard", '                   //-user 1
                                +'"user_email":"testZoomSessions1@eab.edu","join_time":"2021-03-30T17:40:51Z", '
                                +'"leave_time":"2021-03-30T18:58:57Z","duration":4686,"attentiveness_score":"","customer_key":""}, '
                                +'{"id":"XMX5H--3SgK3cEqfXyXGSw","user_id":"16788480","name":"Fiona Cavise", ' 				      //-user 2
                                +'"user_email":"testZoomSessions2@eab.edu","join_time":"2021-03-30T17:45:10Z", '
                                +'"leave_time":"2021-03-30T18:58:56Z","duration":4426,"attentiveness_score":"","customer_key":""}]}';    
        
        Test.startTest();
        
        //get parsed data in ZoomEventFormat format 
        ZoomEventWrapper zEventWrapper = ZoomEventWrapper.parse(JsonBody);
        
        //list to hold participants details 
        List<ZoomEventWrapper.cls_participant> zEventParticipants = zEventWrapper.participants;
        
        //assert to check page count
        System.assertEquals(1, zEventWrapper.page_count);
        
        //assert to check page size 
        System.assertEquals(2, zEventWrapper.page_size);
        
        //assert to check total records 
        System.assertEquals(3, zEventWrapper.total_records);
        
        //assert to check next page token
        System.assertEquals('Yes', zEventWrapper.next_page_token);
        
        //assert to check size of list 
        System.assertEquals(3, zEventParticipants.size());
        
        // assert for Id 
        System.assertEquals('16778240', zEventParticipants[0].user_id);
        System.assertEquals('16787456', zEventParticipants[1].user_id);
        System.assertEquals('16788480', zEventParticipants[2].user_id);
        
        //assert for name  
        System.assertEquals('National Meetings 2', zEventParticipants[0].name);
        System.assertEquals('Ryan Quillard', zEventParticipants[1].name);
        System.assertEquals('Fiona Cavise', zEventParticipants[2].name);
        
        //assert for user email 
        System.assertEquals('testZoomSessions0@eab.edu', zEventParticipants[0].user_email);
        System.assertEquals('testZoomSessions1@eab.edu', zEventParticipants[1].user_email);
        System.assertEquals('testZoomSessions2@eab.edu', zEventParticipants[2].user_email);
        
        Test.stopTest();
    }
}