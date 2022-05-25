/*
*   Description     :   Wrapper class to hold the org specific/Org Comparison details to pull the org changes.
*
*   Created by      :   Mahendra Swarnkar
*
*   Created Date    :   1/27/2020
*
*   Revision Log    :                   
*/
public class OrgComparisionWrapper {
	
    Public Integer Index;
  
    //It can be a) In Progress b) Complete c) Will Start
    public String OrgComparisionStatus;
	public String OrgComparisionId;
	public String OrgComparisionReleaseId;
	public DateTime OrgComparisionReleaseLastSyncTimeStamp;    
    public String processedMetadataComponents;
    public String mainMetadatComponents;
    public String childMetadatMetadatComponents;
    
    //Base URL
    public String requestSite;   
    public String productionRefreshToken;
    public String productionOrgType;
    public String sandboxRefreshToken;
    public String sandboxOrgType;
    public String createdDateBarier;
    public String lastModifiedBarier;
    public String saveToThirdOrg;
    public String createAdditiveMods;
    public String rangeComparision;
    public String createDestructiveMods;
    public String modSaveOrg;
    public String modSaveOrgType;
    public String lastModifiedEndBar;
    public String includeMetadata;
    public String userFilterSet;
    
    public String auditEndDateTime;
    public String auditStartDateTime;
    public String refreshDateOfConnectionSB;
    
    public OrgComparisionWrapper (Integer Index, String requestSite ,  String productionRefreshToken,  String productionOrgType,  
                                  String sandboxRefreshToken,  String sandboxOrgType,  String createdDateBarier,  String lastModifiedBarier, 
                                  String OrgComparisionId,  String saveToThirdOrg,  String createAdditiveMods,  String rangeComparision,  
                                  String createDestructiveMods,  String modSaveOrg,  String modSaveOrgType,  String lastModifiedEndBar,  
                                  String includeMetadata, String userFilterSet, String OrgComparisionStatus, String OrgComparisionReleaseId) {
        this.OrgComparisionReleaseId = OrgComparisionReleaseId;
        this.OrgComparisionStatus = OrgComparisionStatus;
        this.Index = Index;
        this.requestSite = requestSite;
        this.productionRefreshToken = productionRefreshToken;
        this.productionOrgType = productionOrgType;
        this.sandboxRefreshToken = sandboxRefreshToken;
        this.sandboxOrgType = sandboxOrgType;
        this.createdDateBarier = createdDateBarier;
        this.lastModifiedBarier = lastModifiedBarier;
        this.OrgComparisionId = OrgComparisionId;
        this.saveToThirdOrg = saveToThirdOrg;
        this.createAdditiveMods = createAdditiveMods;
        this.rangeComparision = rangeComparision;
        this.createDestructiveMods = createDestructiveMods;
        this.modSaveOrg = modSaveOrg;
        this.modSaveOrgType = modSaveOrgType;
        this.lastModifiedEndBar = lastModifiedEndBar;
        this.includeMetadata = includeMetadata;
        this.userFilterSet = userFilterSet; 
        this.auditStartDateTime = '';
        this.auditEndDateTime = '';
        this.refreshDateOfConnectionSB = '';   
    }
}