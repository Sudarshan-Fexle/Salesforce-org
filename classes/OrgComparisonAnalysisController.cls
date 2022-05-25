/*
*   Description     :   Class to send callout for org comaprision
*
*   Created by      :   Ishan Arora
*
*   Created Date    :   10/04/2019
*
*   Revision Log    :                   
*/
public class OrgComparisonAnalysisController {
    
    public static String recordId {get;set;}
    public static String recordProcessType;
    
    public OrgComparisonAnalysisController() {
        recordProcessType = ApexPages.currentPage().getParameters().get('process');
        recordId = ApexPages.currentPage().getParameters().get('Id');
        
    }
    
    //Process the heroku request
    public void processRequest() {
        
        //Check for record
        If(recordId != null && String.IsNotBlank(recordProcessType)) {
            
            if( recordProcessType != 'delete') {
                
                Org_Comparision__c orgComp = [Select Id, Status__c, Component_Types__c, User_Filter__c, Create_Additive_Mods__c, Create_destructive_mods__c,
                                            Compare_between_last_modified_dates__c, Change_Request__c,
                                            Created_Date_Bar__c, Last_Modified_Date_Bar__c, Last_Modified_Date_End_Bar__c,
                                            Save_Mods_To_Different_Org__c, Save_Mods_To__c, Save_Mods_To__r.Refresh_Token__c,Save_Mods_To__r.Org_type__c,   
                                            Source_of_Truth__c, Source_of_Truth__r.Refresh_Token__c, Source_of_Truth__r.Org_type__c,
                                            Comparison_Org__c, Comparison_Org__r.Refresh_Token__c, Release__c, Comparison_Org__r.Org_type__c,
                                           	Comparison_Org__r.Sandbox_Refresh_Date__c
                                            From Org_Comparision__c where id =: recordId Limit 1];
                
                if(orgComp.Status__c != 'In Progress') {
                    
                    //Get Wrapper Instance
                    OrgComparisionWrapper orgCompWrapper = OrgComparisionUtility.createOrgComparisionWrapperInstance(orgComp, null);
                    
                    if(orgCompWrapper != null ){
                    	
                        String endPointURL = buildURL(orgCompWrapper);
                    	
                        system.debug('@@@@@@' + endPointURL);
                        //Initialize http request
                        HttpRequest req = new HttpRequest();
                        //This the setting query into the endPoint
                        req.setEndpoint(endPointURL);
                        
                        req.setMethod('GET'); 
                        req.setTimeout(120000);
                        Http h = new Http();
                        HttpResponse res;
                        try{
                           system.debug('req--'+req);
                           res = h.send(req);
                           system.debug('res--'+res);
                        }
                        catch(Exception e){
                            
                        }
                        
                        orgComp.Status__c = 'In Progress';
                        
                        update orgComp;
                        
                        //add success message to page
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'Org Comparision process has been started.'));
                    }
                }
                else{
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'Comparision is in Progress.Please try after some time.'));
                } 
            } else {
            	
                Set<Id> OrgComparisionIds = new Set<Id>();
                OrgComparisionIds.add(recordId);
                
                Batch_DeleteCompChangeDetail bat = new Batch_DeleteCompChangeDetail (OrgComparisionIds, false);
                database.executeBatch(bat,200) ;
                
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, System.Label.cmpChangeDetailDeleteSuccesMessage));
                
            }
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'Record Id is not defined'));
        }
    }
    
    //Build the URL to hit the heroku  
    public static String buildURL(OrgComparisionWrapper orgCompWrapper){
        
        //Complete URL to hit Heroku App. 
        String returnURL = '';
        if(orgCompWrapper != null) {
        	
            //Base URL
            String requestSite = orgCompWrapper.requestSite;
            
            //Attributes to pass to Heroku app in the formate of URL.
            String requestAttributes = 'productionRefreshToken='+EncodingUtil.urlEncode(orgCompWrapper.productionRefreshToken, 'UTF-8')+
                                        '&productionOrgType='+EncodingUtil.urlEncode(orgCompWrapper.productionOrgType, 'UTF-8')+                                                                                                                                                  
                                        '&sandboxRefreshToken='+EncodingUtil.urlEncode(orgCompWrapper.sandboxRefreshToken, 'UTF-8')+
                                        '&sandboxOrgType='+EncodingUtil.urlEncode(orgCompWrapper.sandboxOrgType, 'UTF-8')+
                                        '&createdDateBarier='+ EncodingUtil.urlEncode(orgCompWrapper.createdDateBarier, 'UTF-8')+
                                        
                                        '&lastModifiedBarier='+EncodingUtil.urlEncode(orgCompWrapper.lastModifiedBarier, 'UTF-8')+
                
                                        '&OrgComparision='+EncodingUtil.urlEncode(orgCompWrapper.OrgComparisionId, 'UTF-8')+
                						'&OrgComparisionReleaseId='+EncodingUtil.urlEncode(orgCompWrapper.OrgComparisionReleaseId, 'UTF-8')+
                                        '&saveToThirdOrg='+EncodingUtil.urlEncode(orgCompWrapper.saveToThirdOrg+'', 'UTF-8')+
                                        '&createAdditiveMods='+EncodingUtil.urlEncode(orgCompWrapper.createAdditiveMods+'', 'UTF-8')+
                                        '&rangeComparision='+EncodingUtil.urlEncode(orgCompWrapper.rangeComparision + '', 'UTF-8')+
                                        '&createDestructiveMods='+EncodingUtil.urlEncode(orgCompWrapper.createDestructiveMods+ '', 'UTF-8')+
                            			'&modSaveOrg='+EncodingUtil.urlEncode(orgCompWrapper.modSaveOrg, 'UTF-8')+
                            			'&modSaveOrgType='+EncodingUtil.urlEncode(orgCompWrapper.modSaveOrgType, 'UTF-8')+
                						'&lastModifiedEndBar='+EncodingUtil.urlEncode(orgCompWrapper.lastModifiedEndBar, 'UTF-8')+
                						'&auditStartDateTime='+EncodingUtil.urlEncode(orgCompWrapper.auditStartDateTime, 'UTF-8')+
                						'&auditEndDateTime='+EncodingUtil.urlEncode(orgCompWrapper.auditEndDateTime, 'UTF-8')+
                						'&refreshDateOfConnectionSB='+EncodingUtil.urlEncode(orgCompWrapper.refreshDateOfConnectionSB, 'UTF-8')+
                						/*'&includeMetadata='+EncodingUtil.urlEncode(getListOfMetadata(orgCompWrapper.includeMetadata)+ '', 'UTF-8')+*/
                						//'&includeMetadata='+EncodingUtil.urlEncode(orgCompWrapper.includeMetadata+ '', 'UTF-8')+
                     					'&userFilterSet='+EncodingUtil.urlEncode(OrgComparisionUtility.getUserString(orgCompWrapper.userFilterSet)+ '', 'UTF-8');
            
            //Complete URL to hit Heroku App. 
            returnURL = requestSite + requestAttributes;
        }
        
        //return Statement
        return  returnURL;
    }    
}