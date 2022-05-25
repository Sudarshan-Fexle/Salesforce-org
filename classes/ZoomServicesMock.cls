/**
 * 	Description 	:	mocking class for ZoomServices
 * 
 * 	Revision Logs	:	V1.0 - 03/29/2020 - Victor Hanson - Created
 * 				V1.1 - 05/12/2020 - Victor Hanson - CR-20200507-14026 - added getParticipants to methodNameToResponse map
 *                      	V1.2 - 04/23/2021 - Saurbh Kumar - CR-20210319-15008 - added ZoomServiceMockResponse method and restResourceRequestBody method
 * 
 **/
@isTest
global class ZoomServicesMock implements HttpCalloutMock {
	
    public static final String MOCK_MEETING_ID = '123456789';
    public static final String MOCK_REGISTRANT_ID = '85746065';
    public static final String ZOOM_MEETING_PARTICIPANTS = '/meetings/21987654321/participants';
    public static final String ZOOM_WEBINAR_PARTICIPANTS = '/webinars/12345678912/participants';
    public String methodName;
    public Integer statusCode;
    
    public map<string, string> methodNameToResponse {
        get {
            if (methodNameToResponse == null) {
                methodNameToResponse = new map<string, string> { 
                    'getMeeting' => '{"agenda":"API overview","created_at":"2019-09-09T15:54:24Z","duration":60,"host_id":"ABcdofjdogh11111","id":'+MOCK_MEETING_ID+',"join_url":"https://zoom.us/j/1234555466"}',
                    'getMeetingError' => '{"message":"Error - No meeting found with id xxxxxx"}',
                    'addZoomRegistrant' => '{"id":85746065,"join_url":"https://zoom.us/","registrant_id":"'+MOCK_REGISTRANT_ID+'","start_time":"2019-08-30T22:00:00","topic":"reprehenderit ea ut ex Excepteur"}',
                    'callWebServiceToSendCommunicationtTemplate' => '{"successful": true}',
                    'getParticipants' => '{"page_count":1,"page_size":80,"total_records":19,"next_page_token":"","participants":[{"id":"Ksq2dg8eSay-IyfZfn_iQQ","user_id":"16782336","name":"Tanya Crowley","user_email":"testParticipant@eab.com","join_time":"2021-02-10T18:57:48Z","leave_time":"2021-02-10T19:00:33Z","duration":165,"attentiveness_score":""},{"id":"Ksq2dg8eSay-IyfZfn_iQQ","user_id":"33555456","name":"Tanya Crowley","user_email":"testParticipant@eab.com","join_time":"2021-02-10T19:00:34Z","leave_time":"2021-02-10T19:45:59Z","duration":2725,"attentiveness_score":""}]}'
                };
            }
            return methodNameToResponse;
        }
        set;
    }
    
    // mock resposne for UpdateParticipantAttandance
    public static String ZoomServiceMockResponse(){
        String responseBody = '{'
                              +'"page_count":1, '
                              +'"page_size":2, '
                              +'"total_records":30, '
                              +'"next_page_token":"", '
                              +'"participants":['
                            +'{"id":"b6lKhyaZTQuZNGvxbRY9Ow","user_id":"16778240","name":"National Meetings 2", '             //-user 0
                              +'"user_email":"testZoomSessions0@eab.edu","join_time":"2021-03-30T17:39:35Z", '
                              +'"leave_time":"2021-03-30T18:58:56Z","duration":4761,"attentiveness_score":"","customer_key":""}, ' 
                            +'{"id":"K9vBg9A0TSOyQ9TaT4B1Wg","user_id":"16787456","name":"Ryan Quillard", '                   //-user 1
                              +'"user_email":"testZoomSessions1@eab.edu","join_time":"2021-03-30T17:40:51Z", '
                              +'"leave_time":"2021-03-30T18:58:57Z","duration":4686,"attentiveness_score":"","customer_key":""}, '
                            +'{"id":"XMX5H--3SgK3cEqfXyXGSw","user_id":"16788480","name":"Fiona Cavise", ' 				      //-user 2
                              +'"user_email":"testZoomSessions2@eab.edu","join_time":"2021-03-30T17:45:10Z", '
                              +'"leave_time":"2021-03-30T18:58:56Z","duration":4426,"attentiveness_score":"","customer_key":""}, '
                            +'{"id":"PrfMmKchTFyftnsmqmgezQ","user_id":"16789504","name":"Linda Marchlewski",'				  //-user 3
                              +'"user_email":"testZoomSessions3@eab.edu","join_time":"2021-03-30T17:48:51Z", '
                              +'"leave_time":"2021-03-30T18:58:54Z","duration":4203,"attentiveness_score":"","customer_key":""}, '
                            +'{"id":"gnTI1TX2TsqwmgBidCW6vw","user_id":"16790528","name":"Jessica Skipper", '				   //-user 4
                              +'"user_email":"testZoomSessions4@eab.edu","join_time":"2021-03-30T17:50:21Z",'
                              +'"leave_time":"2021-03-30T18:00:07Z","duration":586,"attentiveness_score":"","customer_key":""}, '
                            +'{"id":"YCAuICM4R4Cb9V2TsfBs5Q","user_id":"16791552","name":"Robert Cubriel", '				   //-user 5
                              +'"user_email":"testZoomSessions5@eab.edu","join_time":"2021-03-30T17:51:19Z", '
                              +'"leave_time":"2021-03-30T18:00:06Z","duration":527,"attentiveness_score":"","customer_key":""}, '
                            +'{"id":"zrnnlpE7QjC10UtShgNM2A","user_id":"16792576","name":"Lindsey Peterson", '				   //-user 6
                              +'"user_email":"testZoomSessions6@eab.edu","join_time":"2021-03-30T17:53:33Z", '
                              +'"leave_time":"2021-03-30T18:00:07Z","duration":394,"attentiveness_score":"","customer_key":""}, '
                            +'{"id":"bUm8VVmsTIGMiOGGvP76Cg","user_id":"16793600","name":"Linda Herndon", '					   //-user 7
                              +'"user_email":"testZoomSessions7@eab.edu","join_time":"2021-03-30T17:53:55Z",' 
            				  +'"leave_time":"2021-03-30T18:00:05Z","duration":370,"attentiveness_score":"","customer_key":""}, '
                            +'{"id":"CEfm2sQxQ8C1EX1G6WNQYQ","user_id":"16794624","name":"Carrie Flower", '					   //-user 8
                              +'"user_email":"testZoomSessions8@eab.edu","join_time":"2021-03-30T17:54:13Z", '
                              +'"leave_time":"2021-03-30T18:00:06Z","duration":353,"attentiveness_score":"","customer_key":""}, '
                            +'{"id":"J7gQCvjITuuHn3gcKeXKHA","user_id":"16795648","name":"Candiss Territo", '                  //-user 9
                              +'"user_email":"testZoomSessions9@eab.edu","join_time":"2021-03-30T17:54:33Z", '
                              +'"leave_time":"2021-03-30T18:00:06Z","duration":333,"attentiveness_score":"","customer_key":""}, '
                            +'{"id":"Lhpeg0cxQCqdYIz15iysTw","user_id":"16796672","name":"Judith Sanders", ' 				   //-user 10
                              +'"user_email":"testZoomSessions10@eab.edu","join_time":"2021-03-30T17:54:50Z", '
                              +'"leave_time":"2021-03-30T18:00:06Z","duration":316,"attentiveness_score":"","customer_key":""}, '
                            +'{"id":"5oOFq1hdT-SUaYg5bprOoA","user_id":"16797696","name":"Shanna Pendergrast", '               //-user 11
                              +'"user_email":"testZoomSessions11@eab.edu","join_time":"2021-03-30T17:55:05Z", '
                              +'"leave_time":"2021-03-30T18:00:05Z","duration":300,"attentiveness_score":"","customer_key":""}, '
                            +'{"id":"W_g-KVdlRB2XpE-0snIQIA","user_id":"16798720","name":"Molly Moorman", '                    //-user 12
                              +'"user_email":"testZoomSessions12@eab.edu","join_time":"2021-03-30T17:55:18Z", '
                              +'"leave_time":"2021-03-30T18:00:05Z","duration":287,"attentiveness_score":"","customer_key":""}, '
                            +'{"id":"TMSjnT9-SdGzBLgBc5Gr-A","user_id":"16799744","name":"Melody Loya", '					   //-user 13
                              +'"user_email":"testZoomSessions13@eab.edu","join_time":"2021-03-30T17:55:44Z", '
                              +'"leave_time":"2021-03-30T18:00:10Z","duration":266,"attentiveness_score":"","customer_key":""}, '
                            +'{"id":"JJGONtqiSbOevM3Sdca06g","user_id":"16800768","name":"Joetta Browning", '                  //-user 14
                              +'"user_email":"testZoomSessions14@eab.edu","join_time":"2021-03-30T17:55:54Z", '
                              +'"leave_time":"2021-03-30T18:00:08Z","duration":254,"attentiveness_score":"","customer_key":""}, '
                            +'{"id":"Usf773jnTI6IB9cmsCjIaQ","user_id":"16801792","name":"Anthony Varghese", '                 //-user 15
                              +'"user_email":"testZoomSessions15@eab.edu","join_time":"2021-03-30T17:55:55Z", '
                              +'"leave_time":"2021-03-30T18:00:04Z","duration":249,"attentiveness_score":"","customer_key":""}, '
                            +'{"id":"amreqRz1QqSYUNXVKwvssw","user_id":"16802816","name":"Nicholas Phelan", '                  //-user 16
                              +'"user_email":"testZoomSessions16@eab.edu","join_time":"2021-03-30T17:55:55Z", '
                              +'"leave_time":"2021-03-30T18:00:05Z","duration":250,"attentiveness_score":"","customer_key":""}, '
                            +'{"id":"lgkQCj3VR66LY5ur-hsNgw","user_id":"16803840","name":"Kim Sandlin", '                     //-user 17
                              +'"user_email":"testZoomSessions17@eab.edu","join_time":"2021-03-30T17:56:15Z", '
                              +'"leave_time":"2021-03-30T18:00:07Z","duration":232,"attentiveness_score":"","customer_key":""}, ' 
                            +'{"id":"fyEZqmUEQ-CqeNI85F9MOA","user_id":"16804864","name":"Sol Davis", '                       //-user 18
                              +'"user_email":"testZoomSessions18@eab.edu","join_time":"2021-03-30T17:56:23Z", '
                              +'"leave_time":"2021-03-30T18:00:05Z","duration":222,"attentiveness_score":"","customer_key":""}, '
                            +'{"id":"fJeY4AOCQhShVJ-yBPdL1Q","user_id":"16805888","name":"Lauren Thomas", '                   //-user 19
                              +'"user_email":"testZoomSessions19@eab.edu","join_time":"2021-03-30T17:56:34Z", '
                              +'"leave_time":"2021-03-30T18:00:06Z","duration":212,"attentiveness_score":"","customer_key":""}, '
                            +'{"id":"ZlAsHuPrQsW9pgejZf3Axg","user_id":"16806912","name":"Patricia Hurin", '				  //-user 20
                              +'"user_email":"testZoomSessions20@eab.edu","join_time":"2021-03-30T17:56:36Z", '
                              +'"leave_time":"2021-03-30T18:00:07Z","duration":211,"attentiveness_score":"","customer_key":""}, '
                            +'{"id":"2SalGLUbSPuXk1axGzcTdQ","user_id":"16807936","name":"Dana Sample", '				      //-user 21
                              +'"user_email":"testZoomSessions21@eab.edu","join_time":"2021-03-30T17:56:47Z", '
                              +'"leave_time":"2021-03-30T18:00:11Z","duration":204,"attentiveness_score":"","customer_key":""}, '
                            +'{"id":"yCIl_EZoQWGyX00ygE_YXQ","user_id":"16808960","name":"Gretel Stock", '					  //-user 22
                              +'"user_email":"testZoomSessions22@eab.edu","join_time":"2021-03-30T17:56:52Z", '
                              +'"leave_time":"2021-03-30T18:00:07Z","duration":195,"attentiveness_score":"","customer_key":""}, '
                            +'{"id":"SFR0psUERsC1QVWrYf_7Ag","user_id":"16809984","name":"Natasha Powell", '				  //-user 23
                              +'"user_email":"testZoomSessions23@eab.edu","join_time":"2021-03-30T17:57:02Z", '
                              +'"leave_time":"2021-03-30T18:00:09Z","duration":187,"attentiveness_score":"","customer_key":""}, '
                            +'{"id":"bcmBxauRShKIImDvaA8zzw","user_id":"16811008","name":"Kim Stewart", '                     //-user 24
                              +'"user_email":"testZoomSessions24@eab.edu","join_time":"2021-03-30T17:57:02Z", '
                              +'"leave_time":"2021-03-30T18:00:05Z","duration":183,"attentiveness_score":"","customer_key":""}, '
                            +'{"id":"16WUjSYqSy2ZoXL1F_JLXQ","user_id":"16812032","name":"Sharon Hoffman", '                  //-user 25
                              +'"user_email":"testZoomSessions25@eab.edu","join_time":"2021-03-30T17:57:02Z", '
                              +'"leave_time":"2021-03-30T18:00:05Z","duration":183,"attentiveness_score":"","customer_key":""}, '
                            +'{"id":"ZiF4wgymSwyuORGstTaGXw","user_id":"16813056","name":"Steve S", '                         //-user 26
                              +'"user_email":"testZoomSessions26@eab.edu","join_time":"2021-03-30T17:57:25Z", '
                              +'"leave_time":"2021-03-30T18:00:12Z","duration":167,"attentiveness_score":"","customer_key":""}, '
                            +'{"id":"QjuiSttKRla4yMNpYYbZkw","user_id":"16814080","name":"John Reichert", '					  //-user 27
                              +'"user_email":"testZoomSessions27@eab.edu","join_time":"2021-03-30T17:57:37Z", '
                              +'"leave_time":"2021-03-30T18:00:06Z","duration":149,"attentiveness_score":"","customer_key":""}, '
                            +'{"id":"e_bGXHLRQYeb-qHFqlzXMw","user_id":"16815104","name":"Pamela Witter", '                   //-user 28
                              +'"user_email":"testZoomSessions28@eab.edu","join_time":"2021-03-30T17:57:39Z", '
                              +'"leave_time":"2021-03-30T18:00:05Z","duration":146,"attentiveness_score":"","customer_key":""}, ' 
                            +'{"id":"MD5VOePuT5-i1zP9ONi0mg","user_id":"16816128","name":"Tanya Brown", '                     //-user 29
                              +'"user_email":"testZoomSessions29@eab.edu","join_time":"2021-03-30T17:57:54Z", '
                              +'"leave_time":"2021-03-30T18:00:06Z","duration":132,"attentiveness_score":"","customer_key":""}]}';
        return responseBody;
        
    }
    
    //mock request body for rest resource 
    public static String restResourceRequestBody(String meetingId, String event){
        
        String requestBody = '{'
                             +'"event":"'+event+'", '
                             +'"page_count":1, '
                             +'"page_size":1, '
                             +'"total_records":1, '
                             +'"next_page_token":null, '
                             +'"participants":[{"user_id":"167782040", '
                             +'"user_name":"test", '
                             +'"name":"Saurabh Kumar", '
                             +'"user_email":"saurabh.kumar@fexle.com", '
                             +'"id":"iFxeBPYun6SAiWUzBcEkX", '
                             +'"join_time":"2021-04-29T15:53:35Z", '
                             +'"leave_time":"2021-04-29T18:33:40Z"}], '
                             +'"payload":{"account_id":"o8KK_AAACq6BBEyA70CA", '
                             +'"cls_object":{"uuid" : "ok/pNqxOQyO+qIR8NvIrsg==", '
                             +'"type" : 2, '
                             +'"topic" : "Test Zoom Session", '
                             +'"timezone" : "America/New_York", '
                             +'"start_time" : "2021-04-29T15:53:35Z", '
                             +'"participant" : null, '
                             +'"id" : "'+meetingId+'", '
                             +'"host_id" : "B_KmLP70Skic__xqHX93wA", '
                             +'"end_time" : "2021-04-29T18:33:40Z", '
                             +'"duration" : 120}}}';
        
        return requestBody;
    }

    // V1.2 - 04/23/2021 - Modified by - Saurbh Kumar - CR-20210319-15008
    global HttpResponse respond(HTTPRequest req){
        HttpResponse res = new HttpResponse();
        String endpoint = req.getEndpoint();
        
        if(endpoint!= null && (endpoint.contains(ZOOM_MEETING_PARTICIPANTS) || endpoint.contains(ZOOM_WEBINAR_PARTICIPANTS))){
            res.setStatus('OK');
            res.setStatusCode(statusCode);
            res.setBody(ZoomServiceMockResponse());
        }  
        else{
            res.setStatus('OK');
            res.setStatusCode(statusCode);
            res.setBody(methodNameToResponse.get(methodName));
        }
        return res;
    }
}