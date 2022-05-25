public without sharing class CrimsonMeetingController {
	
	public String JSONResponse { get; set; }
	
	public CrimsonMeetingController() {
		
	}
	
	public void Initialize() {
		String request = ApexPages.currentPage().getParameters().get('req');
		CrimsonMeeting cMeeting = new CrimsonMeeting(request);
		
		// return the results
		JSONResponse = cMeeting.ToEncryptedString();
	}
	
}