/*
Purpose         :   

Create By       :   Mahendra Swarnkar

Created Date    :   07/13/2020

Revision Log    :   V1.0 Created

*/
global without sharing class Batch_ImplementationFeeIssue implements Database.Batchable<SObject>, Database.Stateful{
	public String queryString;
	public Boolean isUpdate;
	public Boolean isUpdateComponents;
	public Integer recordsLimit;
	public Set<Id> contractIdsExternal;
        
    //String which holds the csv values
    public String csvString = 'Proposal Line ID' + ',' + 'SBQQ__ProductCode__c' + ',' + 'Old SBQQ__StartDate__c' + ','  +'SBQQ__StartDate__c' + ',' + 'Old SBQQ__EndDate__c' + ',' + 'SBQQ__EndDate__c'+ ','+ 'SBQQ__EffectiveEndDate__c'+ ','  
                + 'Proposal Id'+ ',' +'Proposal Start Date' + ',' + 'Proposal End Date'+ ',' + 'Proposal.SBQQ__FirstSegmentTermEndDate__c' + ',' + 'Proposal.SBQQ__CustomerAmount__c' + ',' 
                + 'Opportunity Id'+ ',' +'Opportunity.Amount' + ',' + 'Opportunity.StageName' + ',' + 'Contract.Id' + ',' + 'Contract.Status' + ','+'Group.start date'+','+'Group end date'+',' + 'SBQQ__Group__c' + ',' + '\n';
    
    //String which holds the csv values  SBQQ__SegmentStartDate__c, SBQQ__SegmentEndDate__c
    public String csvStringComponentSubscriptions = 'Component Subscription ID' + ',' + 'SBQQ__Product__r.ProductCode' + ',' + 'Old SBQQ__SegmentStartDate__c' + ','  +'SBQQ__SegmentStartDate__c' + ',' + 'Old SBQQ__SegmentEndDate__c' + ',' + 'SBQQ__SegmentEndDate__c'+ ','+ '\n';
    
    //List of contentDocumentLink
    public Set<String> setOpportunityStages = new Set<String>{'Closed Won','Closed Lost', 'Dropped', 'Void'};
    //List of contentDocumentLink
	/* public Set<Id> setProposallineIds = new Set<Id>{'aCgA00000008Qh2KAE', 'aCgA00000008Qh0KAE', 'aCgA00000008QgyKAE', 'aCgA0000000PEI7KAO', 'aCgA0000000L07sKAC', 'aCgA0000000L07oKAC', 'aCgA0000000L07qKAC', 
            'aCg2K000000PXQISA4', 'aCg2K000000PXQGSA4', 'aCg2K0000000bq0SAA', 'aCg2K0000000iSkSAI', 'aCg2K0000000iSlSAI', 'aCg2K0000000iSmSAI', 'aCg2K0000000nOrSAI', 
            'aCg2K0000000nOsSAI', 'aCg2K0000000nOtSAI', 'aCg2K0000000nOuSAI', 'aCg2K0000000tztSAA', 'aCg2K0000000tzuSAA', 'aCg2K0000000tzvSAA', 'aCg2K000000147OSAQ', 
            'aCg2K000000147PSAQ', 'aCg2K000000147QSAQ', 'aCg2K000000147RSAQ', 'aCg2K0000001HzWSAU', 'aCg2K0000001HzXSAU', 'aCg2K0000001HzYSAU', 'aCg2K0000001HzZSAU', 
            'aCg2K0000001MNLSA2', 'aCg2K0000001MNMSA2', 'aCg2K000000CeoCSAS', 'aCg2K000000CeopSAC', 'aCg2K000000CepVSAS', 'aCg2K000000CepXSAS', 'aCg2K000000CepZSAS', 
            'aCg2K000000CepbSAC', 'aCg2K000000CeqJSAS', 'aCg2K000000TQbXSAW', 'aCg2K000000TQw5SAG', 'aCg2K000000TQw7SAG', 'aCg2K000000TQw9SAG', 'aCg2K000000TQwBSAW', 
            'aCgA00000000LwvKAE', 'aCgA00000000LwxKAE', 'aCgA00000000LwzKAE', 'aCgA00000000LxJKAU', 'aCgA00000000LxLKAU', 'aCgA00000000LxNKAU', 'aCgA00000000LzZKAU', 
            'aCgA00000000LzbKAE', 'aCgA00000000LzdKAE', 'aCgA00000000M0KKAU', 'aCgA00000000M0MKAU', 'aCgA00000000M0OKAU', 'aCgA00000000M1TKAU', 'aCgA00000000M1VKAU', 
            'aCgA00000000M1XKAU', 'aCgA00000000MBbKAM', 'aCgA00000000MBdKAM', 'aCgA00000000MBfKAM', 'aCgA00000000MINKA2', 'aCgA00000000MIRKA2', 'aCgA00000000MIjKAM', 
            'aCgA00000000P8VKAU', 'aCgA00000000P8XKAU', 'aCgA00000000P8ZKAU', 'aCgA00000000ROPKA2', 'aCgA00000000RORKA2', 'aCgA00000000ROTKA2', 'aCgA00000000SwKKAU', 
            'aCgA00000000U2uKAE', 'aCgA0000000LBQ2KAO', 'aCgA0000000LBRCKA4', 'aCgA0000000LBRKKA4', 'aCgA0000000LBRPKA4', 'aCgA0000000LBRmKAO', 'aCgA0000000LBRoKAO', 
            'aCgA0000000LBRqKAO', 'aCgA0000000LBWZKA4', 'aCgA0000000LBWbKAO', 'aCgA0000000LBWdKAO', 'aCgA0000000LBqrKAG', 'aCgA0000000LBqtKAG', 'aCgA0000000LBqvKAG', 
            'aCgA0000000PBxOKAW', 'aCgA0000000PC1LKAW', 'aCgA0000000PCB1KAO', 'aCgA0000000PCBQKA4', 'aCgA0000000PCJOKA4', 'aCgA0000000PCLEKA4', 'aCgA0000000PCLRKA4', 
            'aCgA0000000PCLyKAO', 'aCgA0000000PCS7KAO', 'aCgA0000000PCkDKAW', 'aCgA0000000PCkPKAW', 'aCgA0000000PCx9KAG', 'aCgA0000000PD2PKAW', 'aCgA0000000PD2hKAG', 
            'aCgA0000000PDAGKA4', 'aCgA0000000PDAfKAO', 'aCgA0000000PDAxKAO', 'aCgA0000000PDGLKA4', 'aCgA0000000PDilKAG', 'aCgA0000000PDx0KAG', 'aCgA0000000PE6TKAW', 
            'aCgA0000000PE6mKAG', 'aCgA0000000PE75KAG', 'aCgA0000000PET4KAO', 'aCgA0000000PEVjKAO', 'aCgA0000000PEmBKAW', 'aCgA0000000PF3rKAG', 'aCgC000000003ZGKAY', 
            'aCgC000000003ZIKAY', 'aCgC000000003ZKKAY', 'aCgC0000000Y4ALKA0', 'aCgC0000000Y4ANKA0', 'aCgC0000000Y4APKA0', 'aCgC0000000Y5epKAC', 'aCgC0000000Y5erKAC', 
            'aCgC0000000Y5etKAC', 'aCgC0000000Y5jEKAS', 'aCgC0000000Y63UKAS', 'aCgC0000000Y6w2KAC', 'aCgC0000000Y6w4KAC', 'aCgC0000000Y6w6KAC', 'aCgC0000000Y7fRKAS', 
            'aCgC0000000Y8WJKA0', 'aCgC0000000YCD2KAO', 'aCgC0000000YCD4KAO', 'aCgC0000000YCD6KAO', 'aCgC0000000YD7qKAG', 'aCgC0000000YD7sKAG', 'aCgC0000000YD7uKAG', 
            'aCg2K0000002DY3SAM', 'aCg2K0000002HVGSA2', 'aCg0v0000008mu8CAA', 'aCg0v0000008myQCAQ', 'aCg2K00000028ibSAA', 'aCg2K00000028wdSAA', 'aCg2K00000028xxSAA', 
            'aCg2K00000029ABSAY', 'aCg2K00000029BnSAI', 'aCg2K00000029dFSAQ', 'aCg2K00000029doSAA', 'aCg2K00000029hNSAQ', 'aCg2K00000029iUSAQ', 'aCg2K00000029l9SAA', 
            'aCg2K0000002A7ISAU', 'aCg2K0000002A7ZSAU', 'aCg2K0000002ABLSA2', 'aCg2K0000002ABhSAM', 'aCg2K0000002AHqSAM', 'aCg2K0000002ALMSA2', 'aCg2K0000002AN1SAM', 
            'aCg2K0000002ANISA2', 'aCg2K0000002ANZSA2', 'aCg2K0000002AO8SAM', 'aCg2K0000002APASA2', 'aCg2K0000002AWYSA2', 'aCg2K0000002Ak7SAE', 'aCg2K0000002AngSAE', 
            'aCg2K0000002Ao5SAE', 'aCg2K0000002Aq8SAE', 'aCg2K0000002Ar1SAE', 'aCg2K0000002AszSAE', 'aCg2K0000002AygSAE', 'aCg2K0000002AyxSAE', 'aCg2K0000002B1kSAE', 
            'aCg2K0000002B21SAE', 'aCg2K0000002B2ISAU', 'aCg2K0000002B48SAE', 'aCg2K0000002B4PSAU', 'aCg2K0000002B4gSAE', 'aCg2K0000002B4xSAE', 'aCg2K0000002B8VSAU', 
            'aCg2K0000002B9bSAE', 'aCg2K0000002B9qSAE', 'aCg2K0000002BA7SAM', 'aCg2K0000002BAOSA2', 'aCg2K0000002BDGSA2', 'aCg2K0000002BLLSA2', 'aCg2K0000002BXhSAM', 
            'aCg2K0000002Bg1SAE', 'aCg2K0000002Bw1SAE', 'aCg2K0000002BzQSAU', 'aCg2K0000002C06SAE', 'aCg2K0000002CFASA2', 'aCg2K0000002CT9SAM', 'aCg2K0000002CUUSA2', 
            'aCg2K0000002CXDSA2', 'aCg2K0000002D6xSAE', 'aCg2K0000002D7MSAU', 'aCg2K0000002D8fSAE', 'aCg2K0000002DblSAE', 'aCg2K0000002De4SAE', 'aCg2K0000002DeXSAU', 
            'aCg2K0000002DfISAU', 'aCg2K0000002DfkSAE', 'aCg2K0000002DltSAE', 'aCg2K0000002DmASAU', 'aCg2K0000002DmRSAU', 'aCg2K0000002DmiSAE', 'aCg2K0000002DmzSAE', 
            'aCg2K0000002DnMSAU', 'aCg2K0000002DnuSAE', 'aCg2K0000002DoBSAU', 'aCg2K0000002DoSSAU', 'aCg2K0000002DojSAE', 'aCg2K0000002E2YSAU', 'aCg2K0000002EF7SAM', 
            'aCg2K0000002EFOSA2', 'aCg2K0000002EHsSAM', 'aCg2K0000002EIKSA2', 'aCg2K0000002EJxSAM', 'aCg2K0000002ENrSAM', 'aCg2K0000002Eh4SAE', 'aCg2K0000002EhySAE', 
            'aCg2K0000002EjBSAU', 'aCg2K0000002EkZSAU', 'aCg2K0000002EpDSAU', 'aCg2K0000002EpESAU', 'aCg2K0000002EpFSAU', 'aCg2K0000002EpGSAU', 'aCg2K0000002EpHSAU', 
            'aCg2K0000002EqKSAU', 'aCg2K0000002EvYSAU', 'aCg2K0000002EvnSAE', 'aCg2K0000002EwBSAU', 'aCg2K0000002F5ASAU', 'aCg2K0000002F6TSAU', 'aCg2K0000002FM0SAM', 
            'aCg2K0000002FMYSA2', 'aCg2K0000002FQeSAM', 'aCg2K0000002FQfSAM', 'aCg2K0000002FQgSAM', 'aCg2K0000002FQhSAM', 'aCg2K0000002FQiSAM', 'aCg2K0000002FQjSAM', 
            'aCg2K0000002FQkSAM', 'aCg2K0000002FxCSAU', 'aCg2K0000002GmUSAU', 'aCg2K0000002GrySAE', 'aCg2K0000002GsqSAE', 'aCg2K0000002Gt7SAE', 'aCg2K0000002H5kSAE', 
            'aCg2K0000002H8oSAE', 'aCg2K0000002H9FSAU', 'aCg2K0000002H9qSAE', 'aCg2K0000002HACSA2', 'aCg2K0000002HAYSA2', 'aCg2K0000002HaPSAU', 'aCg2K0000002HdhSAE', 
            'aCg2K0000002HlsSAE', 'aCg2K0000002HndSAE', 'aCg2K0000002HoOSAU', 'aCg2K0000002HoTSAU', 'aCg2K0000002HyDSAU', 'aCg2K0000002HymSAE', 'aCg2K0000002IMdSAM', 
            'aCg2K0000002IiiSAE', 'aCg2K0000002IugSAE', 'aCg2K0000002IypSAE', 'aCg2K0000002Iz6SAE', 'aCg2K0000002IzNSAU', 'aCg2K0000002IzsSAE', 'aCg2K0000002JBuSAM', 
            'aCg2K0000002JDRSA2', 'aCg2K0000002JDwSAM', 'aCg2K0000002JFJSA2', 'aCg2K0000002Jc6SAE', 'aCg2K0000002JjaSAE', 'aCg2K0000002JkhSAE', 'aCg2K0000002K3eSAE', 
            'aCg2K0000002K54SAE', 'aCg2K0000002KHhSAM', 'aCg2K0000002KHySAM', 'aCg2K0000002KIFSA2', 'aCg2K0000002KKGSA2', 'aCg2K0000002KKmSAM', 'aCg2K0000002KL3SAM', 
            'aCg2K0000002KLKSA2', 'aCg2K0000002KPnSAM', 'aCg2K0000002KWoSAM'};
    */
    global Database.Querylocator start(Database.BatchableContext BC) 
    {
        if(String.isBlank(queryString) ){
            
            queryString = 'Select Id, SBQQ__ProductCode__c, SBQQ__StartDate__c, SBQQ__EndDate__c, SBQQ__EffectiveEndDate__c, SBQQ__Quote__c, '
							+ 'SBQQ__Quote__r.SBQQ__StartDate__c, SBQQ__Quote__r.SBQQ__EndDate__c,  SBQQ__Quote__r.SBQQ__FirstSegmentTermEndDate__c, '
                			+ 'SBQQ__Quote__r.SBQQ__CustomerAmount__c, SBQQ__Quote__r.SBQQ__Opportunity2__c, SBQQ__Quote__r.SBQQ__Opportunity2__r.Amount, '
                			+ 'SBQQ__Quote__r.SBQQ__Opportunity2__r.StageName,SBQQ__Quote__r.SBQQ__Opportunity2__r.LOA_Contract__c, SBQQ__Group__c, SBQQ__Group__r.SBQQ__StartDate__c, SBQQ__Group__r.SBQQ__EndDate__c, '
                			+ 'SBQQ__Quote__r.SBQQ__Opportunity2__r.LOA_Contract__r.Status From SBQQ__Quoteline__c '
                			+ 'Where (SBQQ__ProductCode__c = \'ImplementationFeeSS\' OR SBQQ__ProductCode__c = \'ImplementationFee\') ' /*AND SBQQ__EndDate__c = null*/ 
                			+ 'AND SBQQ__Quote__r.SBQQ__Account__c != \'001C000001WXl3r\' AND SBQQ__Quote__r.Legacy_Migrated_ES_Client__c != \'Migrated\' '
                			+ 'AND SBQQ__Quote__r.SBQQ__Opportunity2__r.StageName NOT IN : setOpportunityStages '
                			+ 'AND SBQQ__Group__c != null AND SBQQ__Quote__r.SBQQ__FirstSegmentTermEndDate__c != null '
                			+ 'ORDER BY SBQQ__Quote__c, SBQQ__Quote__r.SBQQ__FirstSegmentTermEndDate__c nulls Last' ;
							
                			
            /*+ 'OR SBQQ__Group__c != null AND SBQQ__Quote__r.SBQQ__FirstSegmentTermEndDate__c != null ) ' */
            if(recordsLimit != null){
                queryString = queryString + ' Limit ' + recordsLimit;
            }
        }
        
        //Query over the Membership where the Active subscription's research strategic leader in not null and not deactivated.
        return Database.getQueryLocator(queryString);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope) 
    {
        //Check for size
        if( !scope.isEmpty()) {
            
            //List to hold the new Value Of quotelines
            List<SBQQ__Quoteline__c> listQuotelinesToBeUpdate = new  List<SBQQ__Quoteline__c>();
            
            Set<Id> setContractIds = new Set<Id>();
            Set<Id> setQuotelineIds = new Set<Id>();
            
            
            for(SBQQ__Quoteline__c qline : (List<SBQQ__Quoteline__c>) scope) {
                
                setQuotelineIds.add(qline.Id);
                Date ProposalLinecalculatedEndDate; 
                Date startDate;
                Date endDate;
                if(qline.SBQQ__Group__c != null ){
                    
                    if(qline.SBQQ__Group__r.SBQQ__StartDate__c != null)
                    	startDate = qline.SBQQ__Group__r.SBQQ__StartDate__c;
                    else
                        startDate = qline.SBQQ__Quote__r.SBQQ__StartDate__c;
                        
                    if(qline.SBQQ__Group__r.SBQQ__EndDate__c != null)
                    	endDate = qline.SBQQ__Group__r.SBQQ__EndDate__c;
                    else
                        endDate = qline.SBQQ__Quote__r.SBQQ__EndDate__c;
                    
                    ProposalLinecalculatedEndDate = getEndDateForImplementationFee(startDate, endDate);
                    
                } else if (qline.SBQQ__Quote__r.SBQQ__EndDate__c != null && qline.SBQQ__Quote__r.SBQQ__StartDate__c != null) {
                        ProposalLinecalculatedEndDate = getEndDateForImplementationFee(qline.SBQQ__Quote__r.SBQQ__StartDate__c, qline.SBQQ__Quote__r.SBQQ__EndDate__c);
                    	startDate = qline.SBQQ__Quote__r.SBQQ__StartDate__c;
                }
                
                /*if(qline.SBQQ__Quote__r.SBQQ__FirstSegmentTermEndDate__c != null){
                    ProposalLinecalculatedEndDate = qline.SBQQ__Quote__r.SBQQ__FirstSegmentTermEndDate__c;
                }*/
				
                if(qline.SBQQ__Quote__r.SBQQ__FirstSegmentTermEndDate__c != null && startDate < qline.SBQQ__Quote__r.SBQQ__FirstSegmentTermEndDate__c){
                    ProposalLinecalculatedEndDate = qline.SBQQ__Quote__r.SBQQ__FirstSegmentTermEndDate__c;
                }
                
                Boolean isChanges = false;
                Date oldStartDate = qline.SBQQ__StartDate__c;
                Date oldEndDate = qline.SBQQ__EndDate__c;
                
                if(qline.SBQQ__Group__c != null && qline.SBQQ__Group__r.SBQQ__StartDate__c != null ){
                    if(qline.SBQQ__StartDate__c != qline.SBQQ__Group__r.SBQQ__StartDate__c){
                        isChanges = true;
                        qline.SBQQ__StartDate__c = qline.SBQQ__Group__r.SBQQ__StartDate__c;
                    }
                } else if(qline.SBQQ__StartDate__c != qline.SBQQ__Quote__r.SBQQ__StartDate__c){
                    isChanges = true;
                    qline.SBQQ__StartDate__c = qline.SBQQ__Quote__r.SBQQ__StartDate__c;
                    //qline.SBQQ__StartDate__c = oldStartDate;
                }
                
                if(qline.SBQQ__EndDate__c == null || (qline.SBQQ__Quote__r.SBQQ__FirstSegmentTermEndDate__c != null && qline.SBQQ__EndDate__c != qline.SBQQ__Quote__r.SBQQ__FirstSegmentTermEndDate__c)
                    || (ProposalLinecalculatedEndDate != null && ProposalLinecalculatedEndDate != qline.SBQQ__EndDate__c)) {	
                    
                    isChanges = true;
                    qline.SBQQ__EndDate__c = ProposalLinecalculatedEndDate;
                }
                
                if(qline.SBQQ__Quote__r.SBQQ__Opportunity2__r.LOA_Contract__c != null){
                    setContractIds.add(qline.SBQQ__Quote__r.SBQQ__Opportunity2__r.LOA_Contract__c);
                }
                
                if(isChanges /*|| setProposallineIds.contains(qline.Id)*/){
                    csvString = csvString + qline.Id + ',' + qline.SBQQ__ProductCode__c + ',' + oldStartDate + ',' + qline.SBQQ__StartDate__c + ',' + oldEndDate + ',' + qline.SBQQ__EndDate__c + ','+ qline.SBQQ__EffectiveEndDate__c + ','  
                        + qline.SBQQ__Quote__c + ',' + qline.SBQQ__Quote__r.SBQQ__StartDate__c + ',' + qline.SBQQ__Quote__r.SBQQ__EndDate__c + ',' + qline.SBQQ__Quote__r.SBQQ__FirstSegmentTermEndDate__c + ','
                        + qline.SBQQ__Quote__r.SBQQ__CustomerAmount__c + ',' + qline.SBQQ__Quote__r.SBQQ__Opportunity2__c + ','
                        + qline.SBQQ__Quote__r.SBQQ__Opportunity2__r.Amount + ',' + qline.SBQQ__Quote__r.SBQQ__Opportunity2__r.StageName + ',' 
                        + qline.SBQQ__Quote__r.SBQQ__Opportunity2__r.LOA_Contract__c + ',' + qline.SBQQ__Quote__r.SBQQ__Opportunity2__r.LOA_Contract__r.Status + ','+ qline.SBQQ__Group__r.SBQQ__StartDate__c +','+ qline.SBQQ__Group__r.SBQQ__EndDate__c +',' + qline.SBQQ__Group__c + ',' + '\n';
                
                    listQuotelinesToBeUpdate.add(new SBQQ__Quoteline__c(Id = qline.Id, SBQQ__StartDate__c = qline.SBQQ__StartDate__c, SBQQ__EndDate__c = qline.SBQQ__EndDate__c));
                }   
            }
            
            if(isUpdate && listQuotelinesToBeUpdate.size() > 0) {
            
                //Update the Quotelines
                Database.update(listQuotelinesToBeUpdate, false);
        	}
            
            if(setContractIds.size() > 0 || (contractIdsExternal != null && contractIdsExternal.size() > 0 )){
                
                List<SBQQ__Subscription__c> componentsToBeUpdate = new List<SBQQ__Subscription__c>();
                for(SBQQ__Subscription__c subs : [Select Id, SBQQ__Product__r.ProductCode, SBQQ__SegmentStartDate__c, SBQQ__SegmentEndDate__c, SBQQ__QuoteLine__c, 
                                                  	SBQQ__QuoteLine__r.SBQQ__StartDate__c, SBQQ__QuoteLine__r.SBQQ__EndDate__c From SBQQ__Subscription__c 
													Where (SBQQ__Contract__c IN : contractIdsExternal OR (SBQQ__Contract__c IN : setContractIds AND SBQQ__Product__c != null AND SBQQ__QuoteLine__c != null AND SBQQ__QuoteLine__c IN : setQuotelineIds)) 
                                                  	AND (SBQQ__Product__r.ProductCode = 'ImplementationFeeSS' OR SBQQ__Product__r.ProductCode = 'ImplementationFee')]) {
                    
					if(subs.SBQQ__QuoteLine__c != null ){
                    	Boolean IsChanged = false;
                        Date OldStartDate = subs.SBQQ__SegmentStartDate__c;
                        Date OldEndDate = subs.SBQQ__SegmentEndDate__c;
                        if(subs.SBQQ__QuoteLine__r.SBQQ__StartDate__c != null && subs.SBQQ__SegmentStartDate__c != subs.SBQQ__QuoteLine__r.SBQQ__StartDate__c) {
							subs.SBQQ__SegmentStartDate__c = subs.SBQQ__QuoteLine__r.SBQQ__StartDate__c;
                            IsChanged = true;
                    	}
                        if(subs.SBQQ__QuoteLine__r.SBQQ__EndDate__c != null && subs.SBQQ__SegmentEndDate__c != subs.SBQQ__QuoteLine__r.SBQQ__EndDate__c) {
							subs.SBQQ__SegmentEndDate__c = subs.SBQQ__QuoteLine__r.SBQQ__EndDate__c;
                            IsChanged = true;
                    	}
                        
                        if(IsChanged){
                        	csvStringComponentSubscriptions = csvStringComponentSubscriptions + subs.Id + ',' + subs.SBQQ__Product__r.ProductCode + ',' + OldStartDate + ','  + subs.SBQQ__SegmentStartDate__c + ',' + OldEndDate + ',' + subs.SBQQ__SegmentEndDate__c + ','+ '\n';
                            componentsToBeUpdate.add(new SBQQ__Subscription__c(Id = subs.Id, SBQQ__SegmentStartDate__c = subs.SBQQ__SegmentStartDate__c, SBQQ__SegmentEndDate__c = subs.SBQQ__SegmentEndDate__c));
                        }
                    }
                }
                
                if(isUpdateComponents && componentsToBeUpdate.size() > 0) {
            
                	//Update the Quotelines
                	Database.update(componentsToBeUpdate, false);
        		}
            }
        }
    }
    
    //Finish method
    global void finish(Database.BatchableContext BC) {
        
        if(!isUpdate){
            Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
            blob csvBlob = Blob.valueOf(csvString);
            string csvname= 'ImplementationFeeStartEndDateUpdate.csv';
            csvAttc.setFileName(csvname);
            csvAttc.setBody(csvBlob);
            
            Messaging.EmailFileAttachment csvAttc1 = new Messaging.EmailFileAttachment();
            blob csvBlob1 = Blob.valueOf(csvStringComponentSubscriptions);
            string csvname1= 'ImplementationFeeStartEndDateUpdateComponentSuscription.csv';
            csvAttc1.setFileName(csvname1);
            csvAttc1.setBody(csvBlob1);
            
            Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
            String[] toAddresses = new list<string> {'Mahendra.Swarnkar@fexle.com'};
            String subject = (Util.IS_PRODUCTION_INSTANCE ? 'Production :: ' : 'SandBox :: ') + 'Implementation Fee Issue : Start/End Date Update';
            email.setSubject(subject);
            email.setToAddresses( toAddresses );
            email.setPlainTextBody('Hi Mahendra, Please find the comparison list attached. Thanks! ');
            email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc, csvAttc1});
            Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});       
        }
    }
    
    public static Date getEndDateForImplementationFee(Date ProposalStartDate, Date ProposalEndDate) {
    
    	//Dayes to Add
        Integer daysToAdd = 364;
        
        //Start Date Leap Year calculation
        if(Date.isLeapYear(ProposalStartDate.Year()) && (ProposalStartDate.month() ==1 || (ProposalStartDate.month() == 2 && ProposalStartDate.day() < 29))) {
            daysToAdd = 365;
        }
        
        Date returnDate;
        
        if(ProposalStartDate.daysBetween(ProposalEndDate) > 363) {
            returnDate = ProposalStartDate.addDays(daysToAdd);
        } else {
            returnDate = ProposalEndDate;
        }
    
        //End Date Leap Year calculation
        if(daysToAdd == 364 && Date.isLeapYear(returnDate.year()) && returnDate.month() > 2) {
            returnDate = returnDate.addDays(1);
        }
    
        return (Date.newInstance(returnDate.year(),returnDate.month(),returnDate.day()));
    }
    
}