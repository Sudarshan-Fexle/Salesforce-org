/**
 * 	Description 	:	Wrapper class for zoom events
 * 
 * 	Revision Logs	:	V1.0 - 03/27/2020 - Victor Hanson - Created
 * 
 **/
public class ZoomEventWrapper {
    public String event;	//meeting.participant_joined
    public cls_payload payload;
    
    public Integer page_count;
    public Integer page_size;
    public Integer total_records;
    public String next_page_token;
    public List<cls_participant> participants;
    
    public class cls_payload {
        public String account_id;	//o8KK_AAACq6BBEyA70CA
        public cls_object cls_object;
    }
    public class cls_object {
        public String uuid;	//czLF6FFFoQOKgAB99DlDb9g==
        public String id;	//111111111
        public String host_id;	//uLoRgfbbTayCX6r2Q_qQsQ
        public String topic;	//My Meeting
        public Integer type;	//2
        public String start_time;	//2019-07-09T17:00:00Z
        public String end_time;	//2019-07-09T17:00:00Z
        public Integer duration;	//60
        public String timezone;	//America/Los_Angeles
        public cls_participant participant;
    }
    public class cls_participant {
        public String user_id;	//167782040
        public String user_name;	//shree
		public String name;
		public String user_email;
        public String id;	//iFxeBPYun6SAiWUzBcEkX
        public String join_time;	//2019-07-16T17:13:13Z
        public String leave_time;	//2019-07-16T17:13:13Z
    }
    public static ZoomEventWrapper parse(String json){
        return (ZoomEventWrapper) System.JSON.deserialize(json, ZoomEventWrapper.class);
    }
}