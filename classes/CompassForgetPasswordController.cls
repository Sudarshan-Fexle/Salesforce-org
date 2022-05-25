/*
	Project Name 	 : EAB Compass Community
	Created By	 : Ayush Gupta
	Created Date	 : 10-May-2021
	Last Modifed Date: 
	Description	 : 	1) User will enter the user name prefix and will recieve an email with forgot password link.
             			2) If username does not found we will show an error.
             			3) If username is blank we will show an inline error.           
*/


public class CompassForgetPasswordController {

	public string Screen {get;set;}
	public string UserInput {get;set;}
	public string ErrorMessage {get;set;}
	public string successMessage {get;set;}

	public CompassForgetPasswordController(){
		screen = '1';
	}

	public void submitRequest(){

		if(userInput !=null && userInput !='') 	{
			String userToSearch = userInput +'@eab.community.com';
			List<User> ListOfUser = new List<User>();
			ListOfUser  = Database.Query('SELECT Id, Name FROM User WHERE username =: userToSearch AND IsPortalEnabled = true ');
			if(ListOfUser.size()>0) {
		        
		        Site.forgotPassword(userToSearch);
		       
		        successMessage = 'Check the email account associated with your user name.';   
		        ErrorMessage = null;    
	
	        } else {
	        	
				//Apexpages.addmessage(new apexpages.message(apexpages.severity.error,'User does not exist in out Community data base'));
				ErrorMessage = 'This user name does not exist in our system. Please contact us at starfishsupport@eab.com if you need assistance.';
				successMessage =null;
			
			}
	
			Screen = '2';
		
		} else {
			
			//show error if user input blank user name
			//Apexpages.addmessage(new apexpages.message(apexpages.severity.error,'Please enter user name to search'));
			ErrorMessage = 'Please enter user name to search';
			successMessage =null;
		
		}

	}
}