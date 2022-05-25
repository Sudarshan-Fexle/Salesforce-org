/** 
* Description   :   Controller for the VF page ShipItApp, which contains form navigation controls and basic functions. 
*                   Class containing functions to communicate with the shipping vendor.
*
* Created By    :   Rajeev Jain(Simplyforce)
*
* Created Date  :   03/03/2015
*
* Version       :   V1.0 Created
*                   V1.1 Modified By - Mahendra Swarnkar - 2/12/2016 - CR-20160104-9486
*                   V1.2 Modified By - Mahendra Swarnkar - 5/19/2016 - CR-20160210-9600 - Removed the package selection page and Correct the translation of Ground shiping date/time to utilize Business Days (correction of deployment of CR 9486)
*                   V1.3 Modified By - Mahendra Swarnkar - 07/07/2016 - CR-20160609-9913 - Modified the existing method "getDeleveryOptions".
*                   V1.4 Modified By - Subhash Garhwal - 10/03/2017 - CR-20171002-11631 - Commented a line remove the Personal option from the select options
*                   V1.5 Modified By - Mahendra Swarnkar - 11/28/2017 - CR-20171019-11731
                    V1.6 Modified By - Abhinav Sharma - 02/13/2018 - CR-20171002-11631 - un-Commented the code added rhe Personal option in the Select List 
		    V1.7 Modify by - Abhishek Mishra - 08/07/2019 - CR-20190806-13255 - Method Modified identifyRecepient
**/   
public without sharing class ShipItController {
    
    //============= Constants ================
    //This constant desides how many delivery options will be displayed in one carousal box at the page.
    //It works with very smooth transition in only size 3 but can also be applied size 4
    public final static Integer numberOfItems = 3;
    
    //Hold Stage Name 
    public final static String STAGE_NAME_DELIVERY_OPTIONS = 'Delivery Options';
    
    //============ Properties ================
    
    //Hold Selected Contact Id as Recipient Id, that can be populates while manually selecting on page or from URL.
    public String recipientId{get;set;}
    
    //Hold Id of Identified User as Sender for Ship It app
    public String senderId{get;set;}
    
    //Hold Default view of the App, It states that App is in which mode(New,Edit,Verify,Authorize,Details,Failed)
    public String appView{get;set;}
    
    //Hold States of the App, It show which panel should open on the Page while loads
    //Default State - Open ship it address Accordian
    public String appState{get;set;}
    
    //Hold Recipient Information
    public Contact recipientContact{get;set;}
    
    //Hold Sender Information
    public User senderUser{get;set;}
    
    //Hold Ship it app Information
    private Shipment__c shipment;
    public ShipmentWrapper shipmentWrapper{get;set;}
    
    //Boolean flag to decide if contactId in url parameter was passed is valid or invalid and display message on the page
    public Boolean isInvalidContactId{get;set;}
    
    //Boolean flag States that Address has verified in Controller Method
    public Boolean isAddressVerified{get;set;}
    
    //Boolean flag to decide when address field are required on the page and when 
    //It will be required only when App view is 'New' and not required when App view is 'Review Screen'
    public Boolean isAddressFieldsRequired{get;set;}
    
    //Hold Package items
    public MapPackageWrapper mapPackageWrapper{get;set;}
    
    //Hold the Name of Selected Package on the Package type Screen
    public String selectedPackageName{get;set;}
    
    //Hold Boolean flag to check if selected package varified so app is ready to move to next screen which is shipItOrder component.
    public Boolean isPackageSelectionVerified{get;set;}
    
    //Hold Ship It Package Type Custom Setting Instance
    public ShipIt_PackageType__c selectedPackage{get;set;}
    
    //Hold Delivery options
    public MapPackageWrapper deliveryOptionsWrapper{get;set;}
    
    //Delivery Option List
    List<DeliveryOptionWrapper> deliveryOptionsList = new List<DeliveryOptionWrapper>();
    
    //Hold Selected Delivery Item and Display on the Page
    public DeliveryOptionWrapper selectedDeliveryOption{get;set;}
    
    //Hold Shipment Id from the Url
    public String shipmentId{get;set;}
    
    //Hold flag to Show Success and Error message if Based on if Shipment Successfull or fail to Fedex and Label has printed
    //Default Null
    public Boolean isShipmentSuccessfull{get;set;}
    
    //Hold Error Message coming while printing Label
    public String printLabelErrorMsg{get;set;}
    
    //Find a Shipment Wrapper instance
    public FindAShipmentWrapper findAshipment{get;set;}
    
    //To Display Custom Validation and error message on the page
    public String customValidationMsg{get;set;}
    
    //Get Bill To Select List on the Page
    public List<SelectOption> billToListItems {
        get {
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('--', '--'));
            
            //V1.4 Modified By - Subhash Garhwal - 10/03/2017 - CR-20171002-11631, remove the Personal option from the select options
            //V1.6 Modified By - Abhinav Sharma - 02/13/2018 - CR-20171002-11631 - Added Personal option again in the Select options
            options.add(new SelectOption('Personal', 'Personal'));
            
            options.add(new SelectOption('Department', 'Department'));
            return options;
        }
    }
    private Date businessDay;
    public Date nextBusinessDay{
        get{
            
            if(businessDay == null){
                Datetime dt = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
                String dayOfWeek=dt.format('EEEE');
                if(dayOfWeek == 'Friday')
                    businessDay = Date.today().addDays(3);
                else if(dayOfweek == 'Saturday')
                    businessDay = Date.today().addDays(2);
                else if(dayOfweek == 'Sunday')
                    businessDay = Date.today().addDays(1);
                else
                    businessDay = Date.today().addDays(1);
            }
            return businessDay;
        }
    }
    //Hold Selected Date String on ShipDate List Items
    public String selectedShipDate{get;set;}
    
    //Get Ship Date Select List on the Page
    public List<SelectOption> shipDateListItems {
        get {
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption(Date.today()+'', 'Today'));
            options.add(new SelectOption(nextBusinessDay+'', 'Tomorrow'));
            return options;
        }
    }
    
    //String to hold selected signature data
    public String selectedSignature{get;set;}
    
    //List to hold Signatur Requirement Items
    private List<SelectOption> pSignatureRequirementList;
    public List<SelectOption> signatureRequirementList{
        get{
            if(pSignatureRequirementList == null){
                
                pSignatureRequirementList = new List<SelectOption>();
                
                //Add Default 
                pSignatureRequirementList.add(new SelectOption('', '--None--'));
                pSignatureRequirementList.addAll(ShipItHelper.getSelectOptionListByField('Shipment__c', 'Signature_Requirement__c'));
            }
            
            return pSignatureRequirementList;
        }
    }
    //Hold Id of selected Authorizer User
    public String selectedAuthorizer{get;set;}
    
    /** Hold List of Authorizers, List includes all active users where the Shipping Authorizer field is true,
    *   Plus Current User's manager. The current user must be excluded from the list 
    **/
    private List<SelectOption> pListOfAuthorizers;
    public List<SelectOption> listOfAuthorizers{
        get{
            if(pListOfAuthorizers == null){
                
                pListOfAuthorizers = new List<SelectOption>();
                
                //Add Defaul Blank Option
                pListOfAuthorizers.add(new SelectOption('', '--None--'));
                
                List<User> usersManager = [select Id , Name, ManagerID , Manager.Name, Manager.FirstName, Manager.LastName from User where Id = :UserInfo.getUserId()];
                
                //Add user Maanger At the top of the list
                if(usersManager.size() > 0 && usersManager[0].ManagerID != null){
                    string mgrName = usersManager[0].Manager.LastName + ', ' + usersManager[0].Manager.FirstName;
                    
                    //JRB pListOfAuthorizers.add(new SelectOption(usersManager[0].ManagerID, usersManager[0].Manager.Name));
                    pListOfAuthorizers.add(new SelectOption(usersManager[0].ManagerID, mgrName));
                }
                
                //Query on user who are authorized to authorize request
                List<User> authorizers = [select Id, Name, FirstName, LastName from User 
                                          where Shipping_Authorizer__c = true 
                                          AND IsActive = true 
                                          AND Id != :usersManager[0].ManagerID
                                          ORDER BY LastName, FirstName];
                
                //Loop over the User List and fill the Select Options List
                for(User user :authorizers){
                    //  //JRB pListOfAuthorizers.add(new SelectOption(user.Id, user.Name));
                    pListOfAuthorizers.add(new SelectOption(user.Id, (user.LastName + ', ' + user.FirstName)));
                }
            }
            
            //Return list of Users
            return pListOfAuthorizers;
        }
    }
    
    //================================ Fed Ex Address Validation Properties =======================
    // Here Below various flags are created to check field states for the address validation.
    // Some flag later can be removed and may be not in use.
    // 
    //Hold Comparision values after valdiation from fedex and display as comparision on screen
    private Shipment__c compShipment; 
    public ShipmentWrapper compShipmentWrapper{get;set;}
    
    //Flag to say was address suggestion from user was updated/accepted or declined or Blank
    //We make this flag String type because string can be initialized with any value
    //Will be more superior to use for various app validation status.
    public String isAddressUpdateAccepted{get;set;}
    
    //Flag for display and hide the address validation popup on the screen
    public Boolean isPopupDisplay{get;set;}
    
    //Flag to say if any field has changed after address validated or accepted by user according to Fed Ex Suggestion.
    public String isAddressFieldHasChanged{get;set;}
    
    //Hold Validation Status from fed Ex(Possible Status :- Resolved,Warning,Passed,No Change)
    public String validationStatus{get;set;}
    
    //Flag to make check box selected
    public Boolean isBillingAgreementAccepted{get;set;}
    
    //Flag to Say if any error occurs during getting delivery options
    public Boolean isDeliveryOptionHasError{get;set;}
    
    //Flag recorgnise that if App session is already started or any data of app has saved and decide confirmation dailog is need to be display or not
    public Boolean isAppDataHasSaved{get;set;}
    
    //Flag to flip flop Edit button
    public Boolean isToDisplayEditButtonOnAddressValidation{get;set;}
    public Boolean isToDisplayEditButtonOnPackageSelection{get;set;}
    
    /**Flag Indicate that Suit Number in Address was invlide while address vaidation request to FedEx,
    * So when suit number is invalide that flag sets to true otherwise it sets to false
    * */
    public Boolean isInvalidSuitNumber{get;set;}
    
    /** Counter to maintainee that how many times address has revalidated on Address Popup
    * */
    public Integer addressRevalidationCounter{get;set;}
    
    //Class Constructor
    public ShipItController(){
        
        //Initialize
        try{
            
            InIt();
        }catch(Exception e){
            ShipItHelper.displayErrorMessages(e.getMessage());
        }
        
        //loadPackageTypes();
    }
    
    //============= Methods =================
    /**
    *  @description    :   Method to Initialize ship it app properties and instances at the page load.
    *               
    *  @args           :   
    * 
    *  @return         :   Void
    * 
    **/
    private void InIt(){
        
        //Set Default False, This flag say if app data saved then confirmation dialog will appear on screen
        //ApexPages.currentPage().getParameters().put('isAppDataHasSaved','false');
        isAppDataHasSaved = false;
        
        //Initialize Ship It app Object
        shipment = new Shipment__c(Bill_To__c = 'Department');
        ShipmentWrapper = new ShipmentWrapper();
        ShipmentWrapper.BillTo = 'Department';
        selectedAuthorizer = '';
        
        selectedPackage = new ShipIt_PackageType__c();
        selectedDeliveryOption = new DeliveryOptionWrapper();
        compShipment = new Shipment__c();
        compShipmentWrapper = new ShipmentWrapper();
        
        //Set Default false
        isInvalidContactId = false;
        isAddressVerified = false;
        isPackageSelectionVerified = false;
        isBillingAgreementAccepted = false;
        isDeliveryOptionHasError = false;
        isToDisplayEditButtonOnAddressValidation = false;
        isToDisplayEditButtonOnPackageSelection = false;
        isInvalidSuitNumber = false;
        addressRevalidationCounter = 0;
        
        //Set Blank
        isAddressUpdateAccepted = '';
        isPopupDisplay = false;
        
        //Default true because first time we have to check validation on fed ex, later may not be based on user's Action
        isAddressFieldHasChanged = 'true';
        customValidationMsg = '';
        
        //Get Url Parameters over here and apply app state accroding to it.
        //Get Contact Id or recipient Id
        recipientId = ApexPages.currentPage().getParameters().get('contactId');
        shipmentId = ApexPages.currentPage().getParameters().get('shipmentId');
        
        System.debug('#########' + shipmentId);
        
        //Set FedEx Tracking URL
        ApexPages.currentPage().getParameters().put('trackingURL',ShipItHelper.shipItSettings.get('FedExTrackingURL').value__c);
        senderId = UserInfo.getUserId();
        
        //Initialize sender and Reciever Instances
        recipientContact = new Contact();
        senderUser = new User();
        
        //Instantiate Find A shipment Instance
        findAshipment = new FindAShipmentWrapper();
        
        //On Load decide that to dipslay Edit button or not on screent to navigates between various app states
        decideToDisplayOrNotEditButton();
        
        //Load all default Package 
        loadPackageTypes();
        
        //V1.2 Modified By - Mahendra Swarnkar - 5/19/2016 - CR-20160210-9600  - Starts from here
        //Set the selected package type to 'Your Packaging' for shipit ground services
        selectedPackageName = System.Label.SHIP_IT_YOUR_PACKAGING;
        
        //Called the service screen(Package details screen) method 
        describePackageDetails();
        //V1.2 Modified By - Mahendra Swarnkar - 5/19/2016 - CR-20160210-9600  - Ends here
        
        //If Shipment Id is found in the Url that means only Review Screen Should be accesible to User
        if(String.isNotBlank(shipmentId)){
            appView = 'Review';   
            isAddressFieldsRequired = false;
            isAppDataHasSaved = true;
            
            //Load All Shipment Details
            loadShipmentDetails(shipmentId);
            ///ApexPages.currentPage().getParameters().put('isAppDataHasSaved','true');
            
            //Check if Shipment Was Successfull then Provide link to the user to print there label
            if(shipment.Status__c == ShipItHelper.SHIPMENT_STATUS_SHIPPED || shipment.Status__c == ShipItHelper.SHIPMENT_STATUS_LABEL_PRINTED){
                
                //Fetch Attachment Id and record attached on this shipment.
                List<Attachment> attachments = [select Id, Name, ParentId from Attachment where ParentId = :shipmentId order by CreatedDate DESC LIMIT 1];
                if(attachments.size() >0 ){
                    
                    //If all steps successfully executed set flag to true
                    isShipmentSuccessfull = true;
                    
                    //Set Latest Attachment Id in page Parameter
                    ApexPages.currentPage().getParameters().put('attachmentId',attachments[0].Id);
                }
                
            }
        }else{
            
            appView = 'New';
            appState = 'Address';
            isAddressFieldsRequired = true;
            
            //Check if Contact Id is not found in the URL then set true to invalidContact Id flage
            if(!ApexPages.currentPage().getParameters().containsKey('contactId')){
                //isInvalidContactId = true;   
                shipment.Recipient_Selection_Method__c = 'Manual Entry';
            } else if(ApexPages.currentPage().getParameters().containsKey('contactId') && (String.isBlank(recipientId) || !(recipientId instanceof Id))) {
                isInvalidContactId = true;
                shipment.Recipient_Selection_Method__c = 'Manual Entry';
            } 
            //ApexPages.currentPage().getParameters().put('isAppDataHasSaved','false');
            isAppDataHasSaved = false;
            //Varify both values are not blank then set default State to ShipItAddress and App view to New
            if(String.isNotBlank(recipientId)){
                
                //Populate Recipient Id
                shipment.Recipient__c = recipientId;
                
                //Populate Recipient Selection Method
                shipment.Recipient_Selection_Method__c = 'Contact Record';
                
                //Identify Reciever
                identifyRecepient();
            }
            if(String.isNotBlank(senderId)){
                
                //Identify Sender
                identifySender();
            }
        }
        
        //Method call to decide which edit button should be vissible
        decideToDisplayOrNotEditButton();
    }
    /**
    *  @description    :   Method to Decide to display edit button on page or not.
    *                       We are creating just two property to flip flop edit button on the screen.
    *                       Handled from controller because it was two complex to maintain edid button on the page based on various use cases
    *               
    *  @args           :   
    * 
    *  @return         :   Void
    * 
    **/
    private void decideToDisplayOrNotEditButton(){
        
        /** There is not any sense of back date shipment **/
        if(Shipment.Ship_Date__c < Date.today()){
            isToDisplayEditButtonOnAddressValidation = false;
            isToDisplayEditButtonOnPackageSelection = false;
            //System.debug('Condition 1 :::: ');
            return;
        }    
        /** 
        * In this case a new shipment will be processed so we required to diplay Edit button on both screen
        **/
        if(appView == 'New' && Shipment != null && String.isBlank(shipment.Id)){
            isToDisplayEditButtonOnAddressValidation = true;
            isToDisplayEditButtonOnPackageSelection = true;
            //System.debug('Condition 2 :::: ');
        }
        
        /** In this case eithere a shipment already processed or can be any steps
        * And App state will be for review screen because there will be shipment Id already populated
        * There may be four cases 1- Either user only verified the address and left the app and later came from find a shipment screen
        * 2- User may be package selected and delivery option requested but Either not selected option for request authorization,
        * or not navigated to Review screen
        * 3- User navigated to review screen but not processed shipment or waiting for authorization.
        * 4- User processed shipment and printing label is pending
        * 5- Do not provide user a ficility to edit shipment, If shipment is in back date
        * So Here we are covering all cases and based on the critiria Edit button will be displayed and screens will be visible to user
        * */
        if(appView == 'Review' && Shipment != null && String.isNotBlank(shipment.id)){
            
            /**
            * In this case we can not provide Edit button for All cases We can just provide edit button for Address Validation,
            * Because it may be user just verified there address and never gone to next steps 
            * */ 
            if(Shipment != null && String.isNotBlank(shipment.Id) && shipment.Status__c == shipItHelper.SHIPMENT_STATUS_NEW){
                
                /** Here again two cases 1- Either user has selected package and selected one of the rate service.
                * 2- Or Just verified the address
                * For both cases Status is New and both steps will be Editable
                **/
                if(String.isNotBlank(shipment.Package_Type__c)){
                    
                    isToDisplayEditButtonOnAddressValidation = true;
                    isToDisplayEditButtonOnPackageSelection = true;
                    
                    //Set Is Package Selection is Verified to true so, that will provide a directly to Select Delivery option screen
                    isPackageSelectionVerified = true;
                    //System.debug('Condition 3 :::: ');
                }else{
                    isToDisplayEditButtonOnAddressValidation = true;
                    isToDisplayEditButtonOnPackageSelection = false;
                    //System.debug('Condition 4 :::: ');
                }
                
            }else if(Shipment != null && String.isNotBlank(shipment.Id) && 
                     (shipment.Status__c == shipItHelper.SHIPMENT_STATUS_PENDING_AUTHORIZATION || shipment.Status__c == shipItHelper.SHIPMENT_STATUS_READY_TO_PRINT) &&
                     shipment.Authorization_Requested_From__c != UserInfo.getUserId()){
                         isToDisplayEditButtonOnAddressValidation = true;
                         isToDisplayEditButtonOnPackageSelection = true;    
                         isPackageSelectionVerified = true;
                         //System.debug('Condition 5 :::: ');
                     }else if(shipment.Authorization_Requested_From__c == UserInfo.getUserId()){
                         isToDisplayEditButtonOnAddressValidation = false;
                         isToDisplayEditButtonOnPackageSelection = false;   
                         //System.debug('Condition 6 :::: ');
                     }
        }
        
    }
    
    /**
    *  @description    :   This method is to get the user iformation which is identified as sender in ship It app.
    *                       It calls Ship It helper class and get sender information from It.
    *               
    *  @args           :   
    * 
    *  @return         :   Void
    * 
    **/
    public void identifySender(){
        
        //Get sender Information 
        List<User> users = ShipItHelper.getSenderInformation(senderId);
        
        if(users.size()>0){
            
            //Populate User Information and Display on the 
            shipment.Sender__c = users[0].Id;
            shipment.Sender_Name__c = users[0].Name;
            
            //Modified By Mahendra Swarnkar - 11/28/2017 - CR-20171019-11731 - Starts from here
            shipment.Sender_Company__c = users[0].Entity__c == 'EAB' ? Label.ShipIt_SenderCompany_EAB : Label.ShipIt_SenderCompany;
            //Modified By Mahendra Swarnkar - 11/28/2017 - CR-20171019-11731 - Ends here
            
            shipment.Sender_Address_Line_1__c = users[0].Street;
            shipment.Sender_City__c = users[0].City;
            shipment.Sender_State_Province__c = users[0].State;
            shipment.Sender_PostalCode__c = users[0].PostalCode;
            shipment.Sender_Phone__c = users[0].Phone;
            shipment.Sender_Email__c = users[0].Email;
            shipment.Sender_Finance_Code__c = users[0].Finance_Code__c;
            shipment.Sender_Department__c = users[0].ABC_Department__c;
            shipment.Sender_Cost_Center__c = users[0].Cost_Center__c;
            shipment.Sender_Office_Name__c = users[0].Office__c;
            shipment.Sender_Office_Code__c = users[0].Location_Code__c;
            shipment.Sender_First_Name__c  = users[0].FirstName;
            shipment.Sender_Last_Name__c  = users[0].LastName;
            
        }
        //Populate Shipment Wrapper
        ShipmentWrapper = ShipItHelper.getShipmentWrapperInstance(shipment);
    }
    
    /**
    *  @description    :   This method is to get the contact Information which is identified as reciever in Ship It App.
    *                       It calls ship helper class methods to get recipient information.
    *           
    *  @args           :   
    * 
    *  @return         :   void
    * 
    *  Revision        :  Modified By Dipesh Gupta - CR-20190503-13079 - Condition to fill the Receipient_Company__c 
    *		       :  Modify by - Abhishek Mishra - 08/07/2019 - CR-20190806-13255.
    **/
    public void identifyRecepient(){
        
        //Get Recipient Information
        List<Contact> contacts = ShipItHelper.getRecipientInformation(recipientId);
        
        //Check Size of Contacts
        if(contacts.size()>0){
            
            //If contact found make flag to false to disappear invalid contact Id message on the Screen.
            isInvalidContactId = false;    
            
            //Populate Recipient Information in Shippment object and display on the page
            shipment.Recipient_Name__c = contacts[0].Name;
            shipment.Recipient_First_Name__c = contacts[0].FirstName;
            shipment.Recipient_Last_Name__c = contacts[0].LastName;
	    //Modify by - Abhishek Mishra - 08/07/2019 - CR-20190806-13255 - Uncommented the code that was mistakenly commneted during Spring cleaning. 
            shipment.Recipient_Company__c =  String.isNotBlank(contacts[0].Company__c) ? contacts[0].Company__c :contacts[0].Account.Account_Formal_Name__c;
            shipment.Recipient_Address_Line_1__c = contacts[0].Primary_Address_Line_1__c;
            shipment.Recipient_Address_Line_2__c = contacts[0].Primary_Address_Line_2__c;
            shipment.Recipient_City__c = contacts[0].Primary_City__c;
            shipment.Recipient_State_Province__c = contacts[0].Primary_State_Province__c;
            shipment.Recipient_PostalCode__c = contacts[0].Primary_Postal_Code__c;
            shipment.Recipient_Phone__c = contacts[0].Phone;
            shipment.Recipient_Email__c = contacts[0].Email;
            shipment.Recipient__c = contacts[0].Id;
            
            //Add Address Line 3 to Address Line 2 if it is populated
            if(String.isNotBlank(contacts[0].Primary_Address_Line_3__c)){
                shipment.Recipient_Address_Line_2__c += ', ' + contacts[0].Primary_Address_Line_3__c ;  
            }
        }else{
            
            //If nothing is returend in recipient information means contact Id was passed in url is invalid.
            //Make Invalid flag true to display the invlid contact id message on the screen and messge is stored as custom label.
            isInvalidContactId = true;
        }
        isAddressFieldHasChanged = 'true';
        
        //Populate Shipment Wrapper
        ShipmentWrapper = ShipItHelper.getShipmentWrapperInstance(shipment);
    }
    
    /**
    *  @description    :   Method to load all shipment details when appView = 'Review Screen' and shipment record Id is passsed to it.
    *           
    *  @args           :   Shipment Record Id 
    * 
    *  @return         :   void
    * 
    **/
    private void loadShipmentDetails(String shipmentRecordId){
        List<Shipment__c> shipments = ShipItHelper.populateShipmentData(shipmentId);    
        
        //Check Shipment is populated
        if(shipments != null && shipments.size() > 0){
            shipment = shipments[0];
            
            if(String.isNotBlank(shipment.Package_Type__c)){
                
                //get package Details was selected
                selectedPackage = ShipItHelper.getSelectedPackageInstanceByFullName(shipment.Package_Type__c);
                
                //Pass Name of Selected Package Detail
                selectedPackageName = selectedPackage.Name;
                
            }
            
        }else{
            ShipItHelper.displayErrorMessages('Invalid Shipment Id found');
        }
        
        //Populate Shipment Wrapper
        shipmentWrapper = ShipItHelper.getShipmentWrapperInstance(shipment);
    } 
    
    /**
    *  @description    :   Method to Load Package Types from Custom Settings and Store in the Map
    *           
    *  @args           :   
    * 
    *  @return         :   void
    * 
    **/
    public void loadPackageTypes(){
        
        Map<Integer,List<ShipIt_PackageType__c>> mapAllPackages = new Map<Integer,List<ShipIt_PackageType__c>>();
        
        List<ShipIt_PackageType__c> itemList = new List<ShipIt_PackageType__c>();
        
        //Get Packages Information from Custom Setting
        List<ShipIt_PackageType__c> packageTypes = ShipItHelper.getShipItPackageTypes();
        
        //Counter to Make Row Sequence
        Integer counter = 0;
        
        //Loop over list returned from custom settings
        for(ShipIt_PackageType__c shPackage  : packageTypes){
            
            itemList.add(shPackage);
            
            if(itemList.size() == 4){
                counter ++;
                
                //Put Items in the Map                
                mapAllPackages.put(counter,itemList);  
                
                //Reinitialize for Next Row
                itemList = new List<ShipIt_PackageType__c>();
            }
        }
        
        //Add in Map Package Wrapper
        mapPackageWrapper = new MapPackageWrapper(mapAllPackages);
    }
    
    /**
    *  @description    :   Method to describe package information based on selected package type and navigates to ShipItOrder component.
    *           
    *  @args           :   
    * 
    *  @return         :   void
    * 
    **/
    public void describePackageDetails(){
        
        //Check if Selected Package Details is not blank
        if(String.isNotBlank(selectedPackageName)){
            isPackageSelectionVerified = true;
            
            //Get Shipment Object
            shipment = ShipItHelper.getShipmentObject(shipmentWrapper);
            
            //Get Package Instance from ShipItHelper class from the Custom Setting
            selectedPackage = ShipItHelper.getSelectedPackageInstance(selectedPackageName);
            
            //Assign Selected Package details in Shipment instance
            shipment.Package_Type__c = selectedPackage.Package_Full_Name__c;
            
            //Reset Delivery options
            resetDeliveryOptions();
            
            
            shipmentWrapper = ShipItHelper.getShipmentWrapperInstance(shipment);
        }else{
            isPackageSelectionVerified = false;    
        }
    }
    
    /** Method to Reset Delivery options and other details on the Package Details Screen **/
    private void resetDeliveryOptions(){
        //Reset All other Info of shipment Package Details
        shipment.Bill_To__c = 'Department';
        shipment.Weight_Estimated__c = null;
        shipment.Declared_Value__c = null;
        shipment.Ship_Date__c = Date.today();
        
        //Modified By - Mahendra Swarnkar - 2/12/2016 - CR-20160104-9486 - added default package dimensions to (17x11x8 ).
        //List to hold Default dimensions
        List<String> listDefaultDimension = (shipment.Package_Type__c == 'Your Package' && String.isNotBlank(ShipItHelper.getSelectedPackageInstance('YOUR_PACKAGING').Default_Dimension__c))? (ShipItHelper.getSelectedPackageInstance('YOUR_PACKAGING').Default_Dimension__c).split('x') : new List<String>();
        
        // check for list size and package type
        if(listDefaultDimension.size() == 3 
           && String.isNotBlank(shipment.Package_Type__c) 
           && String.isNotBlank(ShipItHelper.getSelectedPackageInstance('YOUR_PACKAGING').Package_Full_Name__c) 
           && shipment.Package_Type__c == ShipItHelper.getSelectedPackageInstance('YOUR_PACKAGING').Package_Full_Name__c) {
               
               //Populating dimension fields with default values if package type is "Your packaging", else with blank/null values
               shipment.Package_Length_in__c = Integer.valueOf(listDefaultDimension[0].trim());
               shipment.Package_Width_in__c = Integer.valueOf(listDefaultDimension[1].trim());
               shipment.Package_Depth_in__c = Integer.valueOf(listDefaultDimension[2].trim());
           }
        else{
            shipment.Package_Depth_in__c = null;
            shipment.Package_Width_in__c = null;
            shipment.Package_Length_in__c = null;
        }
        //Modified By - Mahendra Swarnkar - 2/12/2016 - CR-20160104-9486 - added default package dimensions to (17x11x8 ) - upto here
        
        shipment.Accept_Billing_Agreement__c = '';
        shipment.Ship_Day__c = '';
        shipment.Signature_Requirement__c = '';
        isBillingAgreementAccepted = false;
        deliveryOptionsWrapper = null;
        selectedDeliveryOption = null; 
        shipment.Status__c = shipItHelper.SHIPMENT_STATUS_NEW;
        
    }
    
    
    /** Method to Populate Delivery Options **/
    private void populateDeliveryOption(){
        
        //Check if Map is filled 
        
        //Map to hold number of delivery option in each box of carousal
        Map<Integer,List<DeliveryOptionWrapper>> mapdeliveryOptions = new Map<Integer,List<DeliveryOptionWrapper>>();
        
        //This list hold number of items will come in single carousal box in delivery option section on the page.
        List<DeliveryOptionWrapper> itemList = new List<DeliveryOptionWrapper>();
        
        //Size defines how many box will be create to display delivery options in carousal
        Integer size = deliveryOptionsList.size();
        
        //Hold thos options which has already processed and later can be used to fill again in the box
        List<DeliveryOptionWrapper> discardList = new List<DeliveryOptionWrapper>();
        
        for(Integer i=1;i<=size;i++){
            
            discardList.add(deliveryOptionsList[i-1]);
            Integer counter = 0;
            
            for(Integer j=i;j<=(numberOfItems+i)-1;j++){
                
                if(j <= size){
                    itemList.add(deliveryOptionsList[j-1]);  
                }
                /* This Logic only use if, we wants cyclic carousal on the screen, to make cyclic,
                *   Just make wrap="true" in ship It order component.And enable this commented logic
                */
              /*else{     
                    itemList.add(discardList[counter]);
                    counter++;
                }*/
                
                /** Comment it out if wants cyclic carousal uncomment above code **/
                else{
                    itemList.add(new DeliveryOptionWrapper());    
                }
            }
            if(itemList.size() == numberOfItems){
                mapdeliveryOptions.put(i,itemList);
                itemList = new List<DeliveryOptionWrapper>();
            }
        }
        
        //Put Map In Wrapper
        deliveryOptionsWrapper = new MapPackageWrapper(mapdeliveryOptions);
        
        //Assign size of the box
        deliveryOptionsWrapper.numberOfItems = numberOfItems;
        
        //Assign Selected Item Index
        if(deliveryOptionsWrapper.selectedOptionIndex == null)
            deliveryOptionsWrapper.selectedOptionIndex = 0;
        
       //system.debug('@@@ Selected deliveryOptionsList ' + deliveryOptionsList.size()+ '::::' + deliveryOptionsList.get(deliveryOptionsWrapper.selectedOptionIndex));
        //Populate one Selected delivery Option based on selected option index
       if(deliveryOptionsList.size() > 0){
            selectedDeliveryOption = deliveryOptionsList.get(deliveryOptionsWrapper.selectedOptionIndex);
        //System.debug('CHeck Delivery Option List in if ' + deliveryOptionsList);
       }
        else
            selectedDeliveryOption = null;
        //System.debug('CHeck Delivery Option List  ' + deliveryOptionsList);
    }
    
    /** Currently Faek method to create fake delivery options **/
    public void getDeleveryOptions(){
        
        try{
            
            //Set false for Error
            isDeliveryOptionHasError = false;
            
            //Get Shipment Instance
            shipment = ShipItHelper.getShipmentObject(shipmentWrapper);
            
            //Conver String date to Date before saving the Shipment Record
            Date shipDate = Date.valueOf(selectedShipDate);
            
            //Assign date to Ship Date of Shipment Record
            shipment.Ship_Date__c = shipDate;
            
            //Assign Ship Day
            if(shipDate == Date.today()){
                shipment.Ship_Day__c = 'Today';    
            }else{
                shipment.Ship_Day__c = 'Next Business Day';
            }
           
            //System.debug('@@@@shipment.Ship_Day__c'+shipment.Ship_Day__c);
           
            //Set Value of Accepting Billing Agreement 
            shipment.Accept_Billing_Agreement__c = 'Yes';
            
            //Set Status to default
            shipment.Status__c = ShipItHelper.SHIPMENT_STATUS_NEW;
            
            //Assign Record Type According to Billing Selected on Screen
            RecordType rt = shipment.Bill_To__c == 'Personal' ? ShipItHelper.getRecordType('FedEx_Personal_Shipment') : ShipItHelper.getRecordType('FedEx_Department_Shipment');            
            
            //Assign Billing type based on Bill To Selected
            shipment.Billing_Type__c = shipment.Bill_To__c;
            if(rt != null)
                shipment.RecordTypeId = rt.Id;
            
            //Make Rate Request
            ShipItServiceController src = new ShipItServiceController();
            
            //Create Blank Instance of WebService Log
            Web_Service_Log__c webServiceLog = new Web_Service_Log__c();
            
            //Reinitialize Option List before getting fresh Options
            deliveryOptionsList = new List<DeliveryOptionWrapper>();
            
            //Pass both References in Service and Make Request to FedEx and Cath response in web Service log
            //Catch all responses of Web Serive in Web Serive Logging Object
            deliveryOptionsList = src.requestRateServiceToFedEx(shipment,webServiceLog);
            
            //Check for the Size and setting Error Flag if no delivery options
            if(deliveryOptionsList == null || deliveryOptionsList.size() == 0){
                isDeliveryOptionHasError = true;    
            }
            
            //Modified By - Mahendra Swarnkar - 2/12/2016 - CR-20160104-9486.
            if(!isDeliveryOptionHasError){
                
                //Temporary DeliveryOptionWrapper instance to hold the Ground Delivery option
                DeliveryOptionWrapper groundDeliveryOption;
                
                //Loop through delivery options list
                for(DeliveryOptionWrapper deliveryOppt : deliveryOptionsList){
                    
                    //System.debug('@@@@@DeliveryOptionWrapper deliveryOppt ::'+deliveryOppt);
                    //System.debug('@@@@@deliveryOppt.serviceType' + deliveryOppt.serviceType);
                    //System.debug('@@@@@DeliveryOptionWrapper deliveryOppt groundServiceDeliveryTime::'+groundServiceDeliveryTime);
                                        
                    //Check for shipIt method ie. "FEDEX_GROUND"
                    if(deliveryOppt.serviceType == 'FEDEX_GROUND' || deliveryOppt.serviceType == 'GROUND_HOME_DELIVERY') {
                        
                        //Check for groundServiceDeliveryTime
                        if(String.isNotBlank(deliveryOppt.groundServiceDeliveryTime)) {
                            
                            //V1.2 Modified By - Mahendra Swarnkar - 5/19/2016 - CR-20160210-9600 - Starts from here
                            //Corrected the translation of Ground shiping date/time to utilize Business Days (as a correction of deployment of CR 9486)
                            
                            //Check for the Ground service and Business days and then Populate the Ship it delivery date and time 
                            if(deliveryOppt.serviceType == 'FEDEX_GROUND' || deliveryOppt.serviceType == 'GROUND_HOME_DELIVERY' )
                                If(deliveryOppt.groundServiceDeliveryTime.containsIgnoreCase('Business Day')){
                                    
                                    //Modified By - Mahendra Swarnkar- CR-20160609-9913 - 7/7/2016 - passes the company holidays as an argument in the AddBusinessDays method - Starts from here
                                    //Populate deliveryDateTime 
                                    //deliveryOppt.deliveryDateTime = Datetime.newInstanceGmt(Util.AddBusinessDays(shipment.Ship_Date__c, Integer.valueOf(deliveryOppt.groundServiceDeliveryTime.substring(0, 2).trim()),null), Time.newInstance(16, 30, 0, 0));
                                }else{
                                //Populate deliveryOppt.deliveryDateTime
                                //deliveryOppt.deliveryDateTime = Datetime.newInstanceGmt(Util.AddBusinessDays(shipment.Ship_Date__c, 1, null), Time.newInstance(16, 30, 0, 0));
                                //Modified By - Mahendra Swarnkar- CR-20160609-9913 - 7/7/2016 - passes the company holidays as an argument in the AddBusinessDays method - Ends here
                            //V1.2 Modified By - Mahendra Swarnkar - 5/19/2016 - CR-20160210-9600 - Ends here
                                    }
                        } 
                        
                        //Check for delivery date time
                        if(deliveryOppt.deliveryDateTime != null){
                            
                            //System.debug('@@@@deliveryOppt.deliveryDate: '+ deliveryOppt.deliveryDateTime.format('EEE, MMM d'));
                            //System.debug('@@@@deliveryOppt.deliveryTime: '+ deliveryOppt.deliveryDateTime.format('hh:mm a'));
                            
                            //Update the delivery date and time as per the updated deliveryDateTime
                            deliveryOppt.deliveryDate = deliveryOppt.deliveryDateTime.format('EEE, MMM d');
                            deliveryOppt.deliveryTime = deliveryOppt.deliveryDateTime.format('hh:mm a');
                        }
                        
                        //Populating ground delivery options
                        groundDeliveryOption = deliveryOppt;
                    }
                }   
                //Check for Size
                if(groundDeliveryOption == null && deliveryOptionsList.size()>0)
                        groundDeliveryOption = deliveryOptionsList[0];
                
                //System.debug('@@@@ first Ground option in the List:' + deliveryOptionsList[0].serviceType +'::: shipment.Ship_Date__c:' + shipment.Ship_Date__c);
                
                //Sets to hold the more expensive deliveryOptions index to eliminate them from the main list
                Set<Integer> setEliminatedDeliveryOptionsIndexNo = new Set<Integer>();
                
                //Sets to hold the DeliveryOptionWrapper records temporarily  
                List<DeliveryOptionWrapper> listTempDeliveryOptions = new List<DeliveryOptionWrapper>();
                
                //check for null
                if(groundDeliveryOption != null){
                
                    //Loops to populating setEliminatedDeliveryOptionsIndexNo set and filter out the delivery options on the basis of net amount as well as the delivery date and time 
                    for(Integer i = 0; i< deliveryOptionsList.size(); i++ ) {
                        for(Integer j = i+1; j< deliveryOptionsList.size(); j++ ) {
                            
                            //Check for the service Type
                            if(String.isNotBlank(deliveryOptionsList[i].serviceType) 
                                && (!setEliminatedDeliveryOptionsIndexNo.contains(i))){
                                
                                //Check for the service Type
                                if(String.isNotBlank(deliveryOptionsList[j].serviceType) 
                                    && (!setEliminatedDeliveryOptionsIndexNo.contains(j))){
                                    
                                    //Check if dilivery amounts are equal
                                    if(deliveryOptionsList[i].totalNetCharge == deliveryOptionsList[j].totalNetCharge ) {
                
                                        //check for deliveryDateTime
                                        if((deliveryOptionsList[i].deliveryDateTime == deliveryOptionsList[j].deliveryDateTime)
                                            || (deliveryOptionsList[i].deliveryDateTime < deliveryOptionsList[j].deliveryDateTime)){
                                            
                                            setEliminatedDeliveryOptionsIndexNo.add(j);
                                        }
                                        else {
                                            setEliminatedDeliveryOptionsIndexNo.add(i);
                                        }
                                    }
                                    else {
                
                                        if(deliveryOptionsList[i].totalNetCharge < deliveryOptionsList[j].totalNetCharge){
                                        
                                            //check for deliveryDateTime
                                            if((deliveryOptionsList[i].deliveryDateTime == deliveryOptionsList[j].deliveryDateTime)
                                                || (deliveryOptionsList[i].deliveryDateTime < deliveryOptionsList[j].deliveryDateTime)){
                                                
                                                setEliminatedDeliveryOptionsIndexNo.add(j);
                                            }
                                        }
                                        else{
                                            
                                            //check for deliveryDateTime
                                            if((deliveryOptionsList[i].deliveryDateTime == deliveryOptionsList[j].deliveryDateTime)
                                                || (deliveryOptionsList[i].deliveryDateTime > deliveryOptionsList[j].deliveryDateTime)){
                                                
                                                setEliminatedDeliveryOptionsIndexNo.add(i);
                                            }
                                        }
                                    }
                                } 
                                else continue;
                            }
                            else continue;
                        }
                    }
                
                    //Adding valid delivery options in to the listTempDeliveryOptions list
                    if(setEliminatedDeliveryOptionsIndexNo.size()>0){
                        for(Integer i=0; i<deliveryOptionsList.size(); i++ ){
                            
                            //check for valid option
                            if(!setEliminatedDeliveryOptionsIndexNo.contains(i))
                                listTempDeliveryOptions.add(deliveryOptionsList[i]);
                        }
                    }
                    
                    //Check for size and adding valid delivery options in to the delivery option list
                    if(listTempDeliveryOptions.size()>0) {
                        
                        deliveryOptionsList.clear();
                        deliveryOptionsList.addAll(listTempDeliveryOptions);
                        //system.debug('@@@@@@@@n deliveryOptionsList' + deliveryOptionsList);
                    }
                    
                    //Loop over delivery option list and reindex it
                    for(Integer j=0;j<deliveryOptionsList.size();j++){
                        deliveryOptionsList[j].optionIndex = j;    
                    }
                    System.debug('@@@@tempDeliveryOptions After Assignment Temp : '+deliveryOptionsList.size());
                }
            }
            //Modified By - Mahendra Swarnkar - 2/12/2016 - CR-20160104-9486. - Upto here
            
            populateDeliveryOption();
            
            //Save Ship It Data
            ShipItHelper.shipItSaveData(shipment, STAGE_NAME_DELIVERY_OPTIONS);
            
            //Populate Shipment Wrapper
            shipmentWrapper = ShipItHelper.getShipmentWrapperInstance(shipment);
            
            webServiceLog.Shipment__c = shipment.Id;
            webServiceLog.RecordTypeId = shipItHelper.shipItSettings.get('WebServiceLogRecordType').value__c;
            
            //After Saving Shipment Record insert Web Service Log to Catch any error occurs 
            insert webServiceLog;
            
        }catch(Exception e){
            isDeliveryOptionHasError = false;    
            //ShipItHelper.displayErrorMessages(e.getMessage());
        }
    }
    
    /** Method to Save Data on Ship It order Screen when delivery option is selected or approved 
      * and ready to navigates to the review screen 
     **/
    public void saveAndNavigatesToReviewScreen(){
        
        try{
            //Repopulate Selected Delivery option
            selectedDeliveryOption = deliveryOptionsList.get(deliveryOptionsWrapper.selectedOptionIndex);
            
            //Populate Shipment Object
            shipment = ShipItHelper.getShipmentObject(shipmentWrapper);
            
            //Update information of selected delivery options details
            shipment.Ship_Method__c = selectedDeliveryOption.serviceType;
            shipment.Ship_Method_Category__c = selectedDeliveryOption.category;
            shipment.Delivery_Date__c = selectedDeliveryOption.deliveryDateTime;
            shipment.Ship_Amount__c = selectedDeliveryOption.totalNetCharge;
            shipment.Ship_Freight_Amount__c = selectedDeliveryOption.totalNetFreight;
            shipment.Ship_Surcharges__c = selectedDeliveryOption.totalSurcharges;
            //Commented by Mahendra Swarnkar -05/08/2020 - CR-20200218-13769 - Deleted Ship_Vendor_Amount__c field
            //shipment.Ship_Vendor_Amount__c = selectedDeliveryOption.totalVendorCharges;
            shipment.Ship_Taxes__c = selectedDeliveryOption.totalTaxes;
            shipment.Authorization_Status__c = ShipItHelper.SHIPMENT_AUTHORIZATION_STATUS_NO_AUTHORIZATION_NEEDED;
            shipment.Status__c = shipItHelper.SHIPMENT_STATUS_READY_TO_PRINT;
            shipment.Delivery_Date_Text__c = selectedDeliveryOption.groundServiceDeliveryTime;
            //populateDeliveryOption();
            //Format Time of Delivery Date to make same as returned from the Fed Ex
            if(shipment.Delivery_Date__c != null){
                
                TimeZone tz = UserInfo.getTimeZone();
                Integer timeOffset = tz.getOffset(shipment.Delivery_Date__c);
                Integer hours = timeOffset/3600000;
                
                //If timezone offset is in - then it will be added to hours and if + then it will be reduced
                hours = -(hours);
                shipment.Delivery_Date__c = shipment.Delivery_Date__c.addHours(hours);    
            }
            
            //Populate Selecte Delivery Option Info to Shipment Record
            shipmentWrapper = ShipItHelper.getShipmentWrapperInstance(shipment);
            
            //Save Ship It Data
            ShipItHelper.shipItSaveData(shipment, STAGE_NAME_DELIVERY_OPTIONS);
        }catch(Exception e){}
    }
    
    /**
    *  @description    :   Method to Send Authorization Request to authorized user based on selection screen.
    *                       Method is called on clicking on send Request button on Ship It order Screen on the Page
    *           
    *  @args           :   
    * 
    *  @return         :   void
    * 
    **/
    public void sendAuthorizationRequest(){
        
        //update authorization status and Status on shipment record and send request to User for authorization
        try{
            
            //Get Shipment Object from Wrapper
            shipment = ShipItHelper.getShipmentObject(shipmentWrapper);
            
            //Populate one Selected delivery Option based on selected option index
            selectedDeliveryOption = deliveryOptionsList.get(deliveryOptionsWrapper.selectedOptionIndex);
            
            
            shipment.Ship_Method__c = selectedDeliveryOption.serviceType;
            shipment.Ship_Method_Category__c = selectedDeliveryOption.category;
            shipment.Delivery_Date__c = selectedDeliveryOption.deliveryDateTime;
            shipment.Ship_Amount__c = selectedDeliveryOption.totalNetCharge;
            shipment.Ship_Freight_Amount__c = selectedDeliveryOption.totalNetFreight;
            shipment.Ship_Surcharges__c = selectedDeliveryOption.totalSurcharges;
            //Commented by Mahendra Swarnkar -05/08/2020 - CR-20200218-13769 - Deleted Ship_Vendor_Amount__c field
            //shipment.Ship_Vendor_Amount__c = selectedDeliveryOption.totalVendorCharges;
            shipment.Ship_Taxes__c = selectedDeliveryOption.totalTaxes;
            shipment.Delivery_Date_Text__c = selectedDeliveryOption.groundServiceDeliveryTime;
            
            //Format Time of Delivery Date to make same as returned from the Fed Ex
            if(shipment.Delivery_Date__c != null){
                
                TimeZone tz = UserInfo.getTimeZone();
                Integer timeOffset = tz.getOffset(shipment.Delivery_Date__c);
                Integer hours = timeOffset/3600000;
                
                //If timezone offset is in - then it will be added to hours and if + then it will be reduced
                hours = -(hours);
                shipment.Delivery_Date__c = shipment.Delivery_Date__c.addHours(hours);    
            }
            
            ShipItHelper.sendRequestForAuthorization(selectedAuthorizer, shipment);   
            
            //Populate Shipment Wrapper
            shipmentWrapper = ShipItHelper.getShipmentWrapperInstance(shipment);
            
        }catch(Exception e){
            ShipItHelper.displayErrorMessages(e.getMessage());
        }
    }
    
    /**
    *  @description    :   Method to Authorize Request Based on Authorization Parameter is Passed in Param
    *           
    *  @args           :   
    * 
    *  @return         :   void
    * 
    **/
    public void authorizeRequest(){
        
        try{
            
            //Get Shipment Objec
            shipment = ShipItHelper.getShipmentObject(shipmentWrapper);
            
            //Get Page Parameters
            ShipItHelper.updateAuthorizationResposne(shipment,Boolean.valueOf(ApexPages.currentPage().getParameters().get('isAuthorized')));    
            
            //Populate Shipment Wrapper
            shipmentWrapper = ShipItHelper.getShipmentWrapperInstance(shipment);
            
        }catch(Exception e){
            ShipItHelper.displayErrorMessages(e.getMessage());
        }
    }
    
    /**
    *  @description    :   Method to Print Shipping Label and Display Message of Success on the Screen
    *           
    *  @args           :   
    * 
    *  @return         :   void
    * 
    **/
    public void printShippingLabel(){
        
        //Print Shipment Label
        try{
            //isShipmentSuccessfull = ShipItHelper.sendShipmentAndPrintLabel(shipment);
            ShipItServiceController serviceController = new ShipItServiceController();
            
            //Get Shipment Instance from Shipment Wrapper
            shipment = ShipItHelper.getShipmentObject(shipmentWrapper);
            
            //Create Blank Instance of WebService Log
            Web_Service_Log__c webServiceLog1 = new Web_Service_Log__c();
            Web_Service_Log__c webServiceLog2 = new Web_Service_Log__c();
            webServiceLog1.RecordTypeId = webServiceLog1.RecordTypeId = shipItHelper.shipItSettings.get('WebServiceLogRecordType').value__c;
            webServiceLog2.RecordTypeId = webServiceLog2.RecordTypeId = shipItHelper.shipItSettings.get('WebServiceLogRecordType').value__c;
            
            Boolean isShipmentValidate = serviceController.validateShipment(shipment,webServiceLog1);
            
            //If validation is succcessfull then Process Shipment and Print Label
            if(isShipmentValidate){
                isShipmentSuccessfull = serviceController.processShipmentAndPrintLabel(shipment,webServiceLog2);    
            }
            
            //Add to List
            List<Web_Service_Log__c> webLogList = new List<Web_Service_Log__c>();
            webLogList.add(webServiceLog1);
            webLogList.add(webServiceLog2);
            
            //Insert Web serive Log
            insert webLogList;
            
            if(!isShipmentSuccessfull)
                printLabelErrorMsg = 'UnKnown Data to FedEx, would be change error msg in future';
            else{
                Shipment.Status__c = ShipItHelper.SHIPMENT_STATUS_LABEL_PRINTED;
                Shipment.Label_Printed_Date__c = DateTime.now();
                
                //Populate Shipment Wrapper
                shipmentWrapper = ShipItHelper.getShipmentWrapperInstance(shipment);
                
                //Update Shipment with Latest Status
                upsert shipment;
            }
        }catch(Exception e){ 
            ShipItHelper.displayErrorMessages(e.getMessage());
        }
    }
    
    //================================ Fed Ex Validation Methods  ==================================
    /**
    *  @description    :   Method to Vderify that all address information is filled and validated successfully then navigate to next screen.
    *           
    *  @args           :   
    * 
    *  @return         :   void
    * 
    **/
    public void verifyAndContinueAddress(){
        try{
            
            //Check Recipient and Sender Required values is populated or not, 
            //if not populated then show required error on the page
            if(String.isBlank(shipmentWrapper.SenderAddressLine1) || 
               String.isBlank(shipmentWrapper.SenderCity) || String.isBlank(shipmentWrapper.SenderStateOrProvince) ||
               String.isBlank(shipmentWrapper.SenderPostalCode) || String.isBlank(shipmentWrapper.SenderEmail) || 
               String.isBlank(shipmentWrapper.SenderPhone) ||
               String.isBlank(shipmentWrapper.RecipientName) || String.isBlank(shipmentWrapper.RecipientAddressLine1) || 
               String.isBlank(shipmentWrapper.RecipientCity) || String.isBlank(shipmentWrapper.RecipientStateOrProvince) || 
               String.isBlank(shipmentWrapper.RecipientPostalCode) || String.isBlank(shipmentWrapper.RecipientPhone)){
                   
                   isAddressVerified = false;   
                   return;
               }else{
                   
                   /**
                    * This flag says about , if any required field has filled on the page.
                    * If any required field is not filled on the page, this action method never set flag true
                    * And never this flag will be sets to true 
                    **/ 
                   isAddressVerified = true; 
               }
            
            //Get Shipment Object instance form Shipment wrapper
            shipment = ShipItHelper.getShipmentObject(shipmentWrapper);
            
            resetDeliveryOptions(); 
            
            /**
              * If any time field value change on the page that must be go to fed ex for corrections 
             **/
            if(isAddressFieldHasChanged == 'true'){
                
                ShipItServiceController serviceController = new ShipItServiceController();
                
                //Create Instnace of Web Service log
                Web_Service_Log__c webServiceLog = new Web_Service_Log__c();
                
                compShipment = ShipItHelper.getShipmentObject(compShipmentWrapper);
                
                //Get Validation Status
                validationStatus = serviceController.validateAddressOnFedEx(shipment,compShipment,webServiceLog);
                isInvalidSuitNumber = serviceController.isInvalidSuitNumber;
                //Validation Status prompt user actions
                if(validationStatus == 'No Change'){
                    
                    //Flag says don't display validation popup on the Screen
                    isPopupDisplay = false;
                    shipment.Address_Validation__c = shipItHelper.shipItSettings.get('AddrValidValue').value__c;
                }else{
                    
                    //If status is 'Resolved','Passed','Warning' show popup on the screen
                    isPopupDisplay = true;
                }
                
                //Repopulate CompShipmentWrapper
                compShipmentWrapper = ShipItHelper.getShipmentWrapperInstance(compShipment);
                
                //Set Status of Shipment is New
                shipment.Status__c = ShipItHelper.SHIPMENT_STATUS_NEW;
                
                //Before inserting webservice log, Shipment record insert so log can be relates to shipment record
                upsert shipment;
                
                //ApexPages.currentPage().getParameters().put('isAppDataHasSaved','true');
                isAppDataHasSaved = true;
                
                //Rj- Populate Internal Id for EDI Update as per CR- 8866 and workorder1.0
                shipment.Internal_Id__c = shipment.Id;
                
                //Assign shipment id to Web service log
                webServiceLog.Shipment__c = shipment.id;
                webServiceLog.RecordTypeId = shipItHelper.shipItSettings.get('WebServiceLogRecordType').value__c;
                
                //Insert web Service log on each request
                insert webServiceLog;
            }else{
                
                //This will decide that user is able to go on next screen
                if(isAddressUpdateAccepted == 'false' && validationStatus == ShipItHelper.VALIDATION_STATUS_PASSED){
                    shipment.Address_Validation__c = shipItHelper.shipItSettings.get('AddrNormalizeDecline').value__c;
                    
                    //Now no needs to display popup and ready to go to next screen
                    isPopupDisplay = false;
                }else if(isAddressUpdateAccepted == 'false' && (validationStatus == ShipItHelper.VALIDATION_STATUS_RESOLVED || validationStatus == ShipItHelper.VALIDATION_STATUS_WARNING)){
                    
                    //Now no needs to display popup Again and ask to user for Yes/No action
                    isPopupDisplay = false;
                }else if(isAddressUpdateAccepted == 'true'){
                    
                    isPopupDisplay = false;
                    
                    //Check Validation Stauts
                    if(validationStatus == 'Resolved'){
                        shipment.Address_Validation__c = shipItHelper.shipItSettings.get('AddrResolvedAcceptValue').value__c;    
                    }
                }
            }
            //Get Shipment Wrapper Instance
            shipmentWrapper = ShipItHelper.getShipmentWrapperInstance(shipment);
            
        }catch(Exception e){
            //ShipItHelper.displayErrorMessages(e.getMessage());
            customValidationMsg = e.getMessage(); 
        }
    }
    
    /**
    *  @description    :   Method which say to hold Existng address and neglect address suggestion from fedex.
    *                   :   Method called from address validation popup.move to package Selection Screen
    *           
    *  @args           :   
    * 
    *  @return         :   void
    * 
    **/
    public void keepExisting(){
        
        //Go to Package  Selection Screen
        //isAddressUpdateAccepted = 'false';
        //isAddressFieldHasChanged = 'false';
        isPopupDisplay = false;
    }
    
    /**
    *  @description    :   Method to Accept Address Suggestion from Fed Ex without any changes in valdiation field
    *                   :   Method called from address validation popup.
    *           
    *  @args           :   
    * 
    *  @return         :   void
    * 
    **/
    public void acceptUpdatesWithoutChange(){
        
        try{
            //Set to false that means user has Accepted address suggesstion from fedex.
            isAddressUpdateAccepted = 'true';
            
            //Setting false here, Reason for it user already accepted correction proposal of Fed Ex.
            //So no need to Send again to fed ex for cross check.
            isAddressFieldHasChanged = 'false';
            isPopupDisplay = false;
            
            compShipment = ShipItHelper.getShipmentObject(compShipmentWrapper);
            
            //Reset Recipient fields 
            shipment.Recipient_Address_Line_1__c = compShipment.Recipient_Address_Line_1__c;
            shipment.Recipient_Address_Line_2__c = compShipment.Recipient_Address_Line_2__c;
            shipment.Recipient_City__c = compShipment.Recipient_City__c;
            shipment.Recipient_State_Province__c = compShipment.Recipient_State_Province__c;
            shipment.Recipient_PostalCode__c = compShipment.Recipient_PostalCode__c;
            
            //Set Address Validation stauts
            shipment.Address_Validation__c = ShipItHelper.shipItSettings.get('AddrResolvedUpdateValue').value__c;
            //populate Shipment Wrapper
            shipmentWrapper = ShipItHelper.getShipmentWrapperInstance(shipment);
            
            upsert shipment;
        }catch(Exception e){
            ShipItHelper.displayErrorMessages(e.getMessage());
        }
    }
    
    /**
    *  @description    :   Method to Accept Address Suggestion from Fed Ex With any changes in valdiation field
    *                   :   Method called from address validation popup.
    *           
    *  @args           :   
    * 
    *  @return         :   void
    * 
    **/
    public void acceptUpdatesWithChange(){
        
        try{
            //Set to false that means user has Accepted address suggesstion from fedex.
            isAddressUpdateAccepted = 'true';
            
            //Setting false here, Reason for it user already accepted correction proposal of Fed Ex.
            //So no need to Send again to fed ex for cross check.
            isAddressFieldHasChanged = 'false';
            isPopupDisplay = false;
            
            compShipment = ShipItHelper.getShipmentObject(compShipmentWrapper);
            
            //Reset Recipient fields 
            shipment.Recipient_Address_Line_1__c = compShipment.Recipient_Address_Line_1__c;
            shipment.Recipient_Address_Line_2__c = compShipment.Recipient_Address_Line_2__c;
            shipment.Recipient_City__c = compShipment.Recipient_City__c;
            shipment.Recipient_State_Province__c = compShipment.Recipient_State_Province__c;
            shipment.Recipient_PostalCode__c = compShipment.Recipient_PostalCode__c;
            
            //Set Address Validation stauts
            shipment.Address_Validation__c = ShipItHelper.shipItSettings.get('AddrResolvedAcceptValue').value__c;
            
            //populate Shipment Wrapper
            shipmentWrapper = ShipItHelper.getShipmentWrapperInstance(shipment);
            
            upsert shipment;
        }catch(Exception e){
            ShipItHelper.displayErrorMessages(e.getMessage());
        }
    }
    
    /**
    *  @description    :   Method to revalidate address on fed ex if it was unable to resolve or validation status was with warning
    *                   :   Method called from address validation popup.
    *           
    *  @args           :   
    * 
    *  @return         :   void
    * 
    **/
    
    public void reValidateAddressOnFedEx(){
        
        try{
            
            ShipItServiceController serviceController = new ShipItServiceController();
            
            //Create Instnace of Web Service log
            Web_Service_Log__c webServiceLog = new Web_Service_Log__c();
            
            //New Reference of Shipment 
            Shipment__c newShipment = ShipItHelper.getShipmentObject(compShipmentWrapper);
            compShipment = ShipItHelper.getShipmentObject(compShipmentWrapper);
            
            //Get Validation Status
            validationStatus = serviceController.validateAddressOnFedEx(newShipment,compShipment,webServiceLog);
            isInvalidSuitNumber = serviceController.isInvalidSuitNumber;
            
            if(validationStatus == 'No Change'){
                shipment.Recipient_Address_Line_1__c = compShipment.Recipient_Address_Line_1__c;
                shipment.Recipient_Address_Line_2__c = compShipment.Recipient_Address_Line_2__c;
                shipment.Recipient_City__c = compShipment.Recipient_City__c;
                shipment.Recipient_State_Province__c = compShipment.Recipient_State_Province__c;
                shipment.Recipient_PostalCode__c = compShipment.Recipient_PostalCode__c;
                //Get updated shiipment wrapper Instnace
                shipmentWrapper = ShipItHelper.getShipmentWrapperInstance(shipment);
                isPopupDisplay = false;
            }else{
                isPopupDisplay = true;
                if(validationStatus == 'Warning')
                    addressRevalidationCounter++;
            }
            
            //Repopulate CompShipmentWrapper 
            compShipmentWrapper = ShipItHelper.getShipmentWrapperInstance(compShipment);
            
            shipment.Status__c = ShipItHelper.SHIPMENT_STATUS_NEW;
            
            //Before inserting webservice log, Shipment record insert so log can be relates to shipment record
            upsert shipment;
            
            //Assign shipment id to Web service log
            webServiceLog.Shipment__c = shipment.id;
            webServiceLog.RecordTypeId = shipItHelper.shipItSettings.get('WebServiceLogRecordType').value__c;
            
            //Insert web Service log on each request
            insert webServiceLog;
            
            //Reset flag to Send again to fed Ex
            isAddressFieldHasChanged = 'true';
        }catch(Exception e){
            ShipItHelper.displayErrorMessages(e.getMessage());
        } 
    }
    
    /**
    *  @description    :   Method to Keep Yes Answer of the User and it is called from Address Validation Confirmation prompt Popup 
    *                   :   Method called from address validation popup 2.
    *           
    *  @args           :   
    * 
    *  @return         :   void
    * 
    **/
    public void acceptYesAnswerFromUser(){
        isAddressFieldHasChanged = 'false';  
        isPopupDisplay = false;
        isAddressUpdateAccepted = '';
        try{
            
            if(validationStatus == ShipItHelper.VALIDATION_STATUS_RESOLVED)
                //Poopulate Data on Shipment according to user sesssion
                shipment.Address_Validation__c = shipItHelper.shipItSettings.get('AddrResolvedDeclineValue').value__c;
            else if(validationStatus == ShipItHelper.VALIDATION_STATUS_WARNING){
                shipment.Address_Validation__c = shipItHelper.shipItSettings.get('AddrWarningValue').value__c;    
            }
            
            //Populate Shipment Wrapper Instance
            shipmentWrapper = shipItHelper.getShipmentWrapperInstance(shipment);
            
            //upsert Shipment Object with Updated value
            upsert shipment;
        }catch(Exception e){
            ShipItHelper.displayErrorMessages(e.getMessage());
        }
    }
    
    //========================================== Find A Shipment ==================================================
    public void next(){
        findAshipment.userSelectedStep += 1;   
    }
    public void previous(){
        findAshipment.userSelectedStep -= 1;
    }    
}