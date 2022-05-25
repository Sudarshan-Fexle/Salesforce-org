/*
    Purpose         :   Batch_UpdateProposalComponentIndexMatch
                
    Create By       :   
    
    Created Date    :   
    
    Current Version :   v1.0
    
    Revision Log    :   V_1.0 Created  
                        
**/ 
global class Batch_UpdateProposalComponentIndexMatch implements Database.Batchable<SObject>, Database.Stateful {
	
    public static Map<String,String> mapObjectNameWithQuery = new Map<String,String>()/*{'Proposal' ==> 'Select ID, SBQQ from SBQQ__Quote__c'}*/;
    global String debugLog;
    public string QueryString;
    public String emailAddress;
    public static Set<String> setProductCodes = new Set<String>{'Implementation','ImplementationFee', 'ImplementationFeeSS', 'AdditionalOnsites' };
    public Boolean IsExecuteupdateProposalLine;
    public Boolean IsExecuteupdateComponent;
    public Boolean IsExecuteupdateSP;
    public String csvStringQuotelineToUpdate = 'Proposal Line ID' + ',' + 'Proposal ID' + ',' + 'Product Code' + ',' + 'Segment Index' + ',' + 'Old Segment Label' + ',' + 'new Segment Label'+ ',' +  '\n';
    public String csvStringComponentSubscriptionToUpdate = 'Component Subscription ID' + ',' + 'Product Code' + ',' + 'Old Segment Index' + ',' + 'new Segment Index' + ',' + 'Old Segment Label' + ',' + 'new Segment Label'+ ',' +  '\n';
    public String csvStringSubscriptionPeriodToUpdate = 'Subscription Period ID' + ',' + 'Old Segment Index' + ',' + 'new Segment Index' + ',' +  '\n';
    //Start Method
    global Database.Querylocator start(Database.BatchableContext BC) {
    	
        if(String.isBlank(emailAddress))
            emailAddress = 'mswarnakar@eab.com';
        
        return Database.getQueryLocator('Select ID from Opportunity where RecordType.DeveloperName IN (\'EAB_Initiating\', \'EAB_Continuing\')');
    }
    
    //Execute Method
    global void execute(Database.BatchableContext BC, List<Opportunity> scope) {
        
        if(scope != null && scope.size() > 0){
            Set<Id> setOpportunityIds = new Set<ID>();
            for(Opportunity opp : scope) {
                setOpportunityIds.add(Opp.Id);
            }
            
            if(setOpportunityIds.size() > 0) {
                
                List<SBQQ__Quoteline__c> listQuotelinesToUpdate = new List<SBQQ__Quoteline__c>();
                for(SBQQ__Quoteline__c line : [Select ID, SBQQ__Quote__c, SBQQ__ProductCode__c, SBQQ__SegmentLabel__c, SBQQ__SegmentIndex__c 
                                               From SBQQ__Quoteline__c 
                                               where /*SBQQ__SegmentIndex__c != null AND*/ SBQQ__Quote__c != null AND SBQQ__Quote__r.SBQQ__Opportunity2__c != null 
                                               AND SBQQ__Quote__r.SBQQ__Opportunity2__c IN : setOpportunityIds ]) 
                {    
                    if(line.SBQQ__SegmentIndex__c != null && !setProductCodes.contains(line.SBQQ__ProductCode__c)){
                    	
                        String SegmentLabel =  'Year  '+ line.SBQQ__SegmentIndex__c;
                        
                        if(String.isBlank(line.SBQQ__SegmentLabel__c) || !SegmentLabel.equalsIgnoreCase(line.SBQQ__SegmentLabel__c)){
                            
                            csvStringQuotelineToUpdate += line.Id + ',' + line.SBQQ__Quote__c + ',' + line.SBQQ__ProductCode__c + ',' + line.SBQQ__SegmentIndex__c + ',' + line.SBQQ__SegmentLabel__c + ',' + SegmentLabel + ',' +  '\n';
                        	
                            line.SBQQ__SegmentLabel__c = SegmentLabel;
                            listQuotelinesToUpdate.add(line);
                        }
                    }
                    
                    if(line.SBQQ__SegmentIndex__c != 1 && (line.SBQQ__ProductCode__c == 'ImplementationFee' || line.SBQQ__ProductCode__c == 'Implementation'))
                    {
                        String SegmentLabel =  'Year  1'; 
                        
                        line.SBQQ__SegmentIndex__c = 1;
						line.SBQQ__SegmentLabel__c = SegmentLabel;  
                        
                        csvStringQuotelineToUpdate += line.Id + ',' + line.SBQQ__Quote__c + ',' + line.SBQQ__ProductCode__c + ',' + line.SBQQ__SegmentIndex__c + ',' + line.SBQQ__SegmentLabel__c + ',' + SegmentLabel + ',' +  '\n';
                        listQuotelinesToUpdate.add(line);
                    }
                }
                
                Map<Id, SBQQ__SUbscription__c> mapComponentSubscriptionToBeUpdated = new Map<Id, SBQQ__SUbscription__c>();
                List<SBQQ__SUbscription__c> listComponentSubscriptionToBeUpdated = new List<SBQQ__SUbscription__c>();
                
                //Map to hold the Program Subscription Segment Index value according to start and end date
                Map<String, String> mapProgramSubYearWithIndex = new Map<String, String>();
                Map<Id, Integer> mapProgramSubWithLastestIndex = new Map<Id, Integer>();
                
                
                for(SBQQ__SUbscription__c component : [Select ID, SBQQ__SegmentIndex__c, SBQQ__SegmentLabel__c, Product_Code__c,
                                                        SBQQ__QuoteLine__c, SBQQ__QuoteLine__r.SBQQ__SegmentIndex__c,
                                                        SBQQ__QuoteLine__r.SBQQ__ProductCode__c, SBQQ__SegmentStartDate__c, SBQQ__SegmentEndDate__c,
                                                        Program_Subscription__c, SBQQ__QuoteLine__r.SBQQ__StartDate__c, SBQQ__QuoteLine__r.SBQQ__EndDate__c
                                                       From SBQQ__SUbscription__c
                                                       WHERE RecordType.DeveloperName = 'Component' /*AND SBQQ__QuoteLine__c != null */ 
                                                        AND Program_Subscription__c != null AND Program_Subscription__r.Source_Opportunity__c != null 
                                                        AND Program_Subscription__r.Source_Opportunity__c IN : setOpportunityIds 
                                                        AND Product_Category__c NOT IN ('Opt In', 'Offer', 'Opt Out')
                                                       ORDER BY SBQQ__SegmentStartDate__c ASC NULLS LAST]) 
                {
                    mapComponentSubscriptionToBeUpdated.put(component.Id, new SBQQ__SUbscription__c(Id = component.Id, SBQQ__SegmentIndex__c = component.SBQQ__SegmentIndex__c, SBQQ__SegmentLabel__c = component.SBQQ__SegmentLabel__c));
                    
                    //Create UK
                    String uK = component.Program_Subscription__c + '-' + component.SBQQ__SegmentStartDate__c;
                     
                    //Add Index Value in the map for Program Subscription
                    if(!mapProgramSubYearWithIndex.containsKey(uK)) {
                    	
                    	Integer latestIndex = 1;
                    	
                    	//Check if Latest Index map contains the value
                    	if(mapProgramSubWithLastestIndex.containsKey(component.Program_Subscription__c))
                    		latestIndex = mapProgramSubWithLastestIndex.get(component.Program_Subscription__c) + 1;
                    	
                    	 mapProgramSubYearWithIndex.put(uK, 'Year  ' +latestIndex);
                    	 mapProgramSubWithLastestIndex.put(component.Program_Subscription__c, latestIndex);
                    }
                    	
                    if(component.SBQQ__QuoteLine__c != null && component.SBQQ__QuoteLine__r.SBQQ__SegmentIndex__c != null /*&& !setProductCodes.contains(component.SBQQ__QuoteLine__r.SBQQ__ProductCode__c)*/)
                    {
                        //Check if Start Date of QL and Comp. Sub is same or not
                        if(component.SBQQ__SegmentStartDate__c == component.SBQQ__QuoteLine__r.SBQQ__StartDate__c && component.SBQQ__SegmentEndDate__c == component.SBQQ__QuoteLine__r.SBQQ__EndDate__c) 
                        {
                        	//Check for 
	                        String SegmentLabel = 'Year  ' + component.SBQQ__QuoteLine__r.SBQQ__SegmentIndex__c;
	                        Boolean isUpdate = false;
	                        
	                        if(component.SBQQ__SegmentIndex__c == null || component.SBQQ__SegmentIndex__c != component.SBQQ__QuoteLine__r.SBQQ__SegmentIndex__c){
	                            component.SBQQ__SegmentIndex__c = component.SBQQ__QuoteLine__r.SBQQ__SegmentIndex__c;
	                            component.SBQQ__SegmentLabel__c = SegmentLabel;
	                            isUpdate = true;
	                        }
	                        
	                        if(String.isBlank(component.SBQQ__SegmentLabel__c)  || !SegmentLabel.equalsIgnoreCase(component.SBQQ__SegmentLabel__c)){
	                            component.SBQQ__SegmentLabel__c = SegmentLabel;
	                            isUpdate = true;
	                        }
	                        
	                        if(isUpdate){
	                            listComponentSubscriptionToBeUpdated.add(component);
	                            csvStringComponentSubscriptionToUpdate += component.Id + ',' + component.Product_Code__c + ',' + mapComponentSubscriptionToBeUpdated.get(component.Id).SBQQ__SegmentIndex__c + ',' + component.SBQQ__SegmentIndex__c + ',' + mapComponentSubscriptionToBeUpdated.get(component.Id).SBQQ__SegmentLabel__c + ',' + component.SBQQ__SegmentLabel__c + ',' +  '\n';
	                        }	
                        	
                        } else {
                        	
                        	//Check for Sement Label and index
                        	if(component.SBQQ__SegmentLabel__c != mapProgramSubYearWithIndex.get(uK) || component.SBQQ__SegmentIndex__c != mapProgramSubWithLastestIndex.get(component.Program_Subscription__c)) {
                        		
                        		component.SBQQ__SegmentIndex__c = mapProgramSubWithLastestIndex.get(component.Program_Subscription__c);
	                            component.SBQQ__SegmentLabel__c = mapProgramSubYearWithIndex.get(uK);
	                            
	                            listComponentSubscriptionToBeUpdated.add(component);
	                            csvStringComponentSubscriptionToUpdate += component.Id + ',' + component.Product_Code__c + ',' + mapComponentSubscriptionToBeUpdated.get(component.Id).SBQQ__SegmentIndex__c + ',' + component.SBQQ__SegmentIndex__c + ',' + mapComponentSubscriptionToBeUpdated.get(component.Id).SBQQ__SegmentLabel__c + ',' + component.SBQQ__SegmentLabel__c + ',' +  '\n';
                        	}
                        }
                        
                    } else {
                    	
                    	//Check for Sement Label and index
                    	if(component.SBQQ__SegmentLabel__c != mapProgramSubYearWithIndex.get(uK) || component.SBQQ__SegmentIndex__c != mapProgramSubWithLastestIndex.get(component.Program_Subscription__c)) {
                    		
                    		component.SBQQ__SegmentIndex__c = mapProgramSubWithLastestIndex.get(component.Program_Subscription__c);
                            component.SBQQ__SegmentLabel__c = mapProgramSubYearWithIndex.get(uK);
                            
                            listComponentSubscriptionToBeUpdated.add(component);
                            csvStringComponentSubscriptionToUpdate += component.Id + ',' + component.Product_Code__c + ',' + mapComponentSubscriptionToBeUpdated.get(component.Id).SBQQ__SegmentIndex__c + ',' + component.SBQQ__SegmentIndex__c + ',' + mapComponentSubscriptionToBeUpdated.get(component.Id).SBQQ__SegmentLabel__c + ',' + component.SBQQ__SegmentLabel__c + ',' +  '\n';
                    	}
                    }
                }
                
                List<Subscription_Period__c> listSubscriptionPeriodToBeUpdated = new List<Subscription_Period__c>();
                for(Subscription_Period__c sp : [Select ID, Segment_Index__c, (Select ID, SBQQ__SegmentIndex__c, SBQQ__QuoteLine__c, SBQQ__QuoteLine__r.SBQQ__SegmentIndex__c from Subscriptions__r where /*SBQQ__QuoteLine__c != null AND SBQQ__QuoteLine__r.SBQQ__SegmentIndex__c != null*/ SBQQ__SegmentIndex__c != null ORDER BY SBQQ__SegmentIndex__c ASC Limit 1) from Subscription_Period__c where Source_Opportunity__c != null AND Source_Opportunity__c IN : setOpportunityIds ]){
                    
                    if(sp.Subscriptions__r != null && sp.Subscriptions__r.size() > 0 && (sp.Segment_Index__c == null || sp.Subscriptions__r[0].SBQQ__SegmentIndex__c != sp.Segment_Index__c)){
                        csvStringSubscriptionPeriodToUpdate += sp.ID + ',' + sp.Segment_Index__c + ',' + sp.Subscriptions__r[0].SBQQ__SegmentIndex__c + ',' +  '\n';
                        sp.Segment_Index__c = sp.Subscriptions__r[0].SBQQ__SegmentIndex__c;
                        listSubscriptionPeriodToBeUpdated.add(sp);
                    }
                    
                    /*if(sp.Subscriptions__r != null && sp.Subscriptions__r.size() > 0 && (sp.Segment_Index__c == null || sp.Subscriptions__r[0].SBQQ__QuoteLine__r.SBQQ__SegmentIndex__c != sp.Segment_Index__c)){
                        csvStringSubscriptionPeriodToUpdate += sp.ID + ',' + sp.Segment_Index__c + ',' + sp.Subscriptions__r[0].SBQQ__QuoteLine__r.SBQQ__SegmentIndex__c + ',' +  '\n';
                        sp.Segment_Index__c = sp.Subscriptions__r[0].SBQQ__QuoteLine__r.SBQQ__SegmentIndex__c;
                        listSubscriptionPeriodToBeUpdated.add(sp);
                    }*/
                }  
                
                Util.BypassAllTriggers = true;
                if(IsExecuteupdateProposalLine){
                    Update listQuotelinesToUpdate;
                }
                if(IsExecuteupdateComponent){
                    Update listComponentSubscriptionToBeUpdated;
                }
                if(IsExecuteupdateSP){
                    Update listSubscriptionPeriodToBeUpdated;
                }
                Util.BypassAllTriggers = false;
            }
        }
    }
    
    //Finish method
    global void finish(Database.BatchableContext BC) {
        
        Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
		blob csvBlob = Blob.valueOf(csvStringQuotelineToUpdate);
		string csvname= 'ProposalLinesToUpdate.csv';
		csvAttc.setFileName(csvname);
		csvAttc.setBody(csvBlob);
        
        Messaging.EmailFileAttachment csvAttc1 = new Messaging.EmailFileAttachment();
		csvBlob = Blob.valueOf(csvStringComponentSubscriptionToUpdate);
		csvname= 'ComponentSubscriptionToUpdate.csv';
		csvAttc1.setFileName(csvname);
		csvAttc1.setBody(csvBlob);
        
        Messaging.EmailFileAttachment csvAttc2 = new Messaging.EmailFileAttachment();
		csvBlob = Blob.valueOf(csvStringSubscriptionPeriodToUpdate);
		csvname= 'SubscriptionPeriodToUpdate.csv';
		csvAttc2.setFileName(csvname);
		csvAttc2.setBody(csvBlob);
        
		Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
		String[] toAddresses = new list<string> {emailAddress};
		String subject ='Proposal line,Component, SP Index Miss Match Records From full2';
		email.setSubject(subject);
		email.setToAddresses( toAddresses );
		email.setPlainTextBody('Hi Subhsah, Please find the comparison list attached. Thanks! ');
		email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc, csvAttc1, csvAttc2});
		Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
    }
}