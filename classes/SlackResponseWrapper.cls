/**
 *   Purpose		:   Wrapper class for deserializing JSON sent back from Slack
 *   
 *   Revision Log	:   Created By - Nikita Kumari - CR-20220128-15759 - Slack API - Use the users.lookupByEmail method to populate User.Slack_Id__c
**/
public class SlackResponseWrapper {
    
	public boolean ok { get; set; }
	public UserWrapper user { get; set;}
    
    //to hold the details related to user
	public class UserWrapper {
		public String id { get; set; }
		public String team_id{ get; set; }
		public String name{ get; set; }
		public boolean deleted{ get; set; }
		public String color{ get; set; }
		public String real_name{ get; set; }
		public String tz{ get; set; }
		public String tz_label{ get; set; }
		public Integer tz_offset{ get; set; }
		public UserProfileWrapper profile{ get; set; }
		public boolean is_admin{ get; set; }
		public boolean is_owner{ get; set; }
		public boolean is_primary_owner{ get; set; }
		public boolean is_restricted{ get; set; }
		public boolean is_ultra_restricted{ get; set; }
		public boolean is_bot{ get; set; }
		public Integer updated{ get; set; }
		public boolean is_app_user{ get; set; }
		public boolean has_2fa{ get; set; }
	}
    
        //to hold the details related to user profile
	public class UserProfileWrapper {
		public String avatar_hash{ get; set; }
		public String status_text{ get; set; }
		public String status_emoji{ get; set; }
		public String real_name{ get; set; }
		public String display_name{ get; set; }
		public String real_name_normalized{ get; set; }
		public String display_name_normalized{ get; set; }
		public String email{ get; set; }
		public String image_24{ get; set; }
		public String image_32{ get; set; }
		public String image_48{ get; set; }
		public String image_72{ get; set; }
		public String image_192{ get; set; }
		public String image_512{ get; set; }
		public String team{ get; set; }
	}

}