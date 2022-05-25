/**
 *  Purpose         :	Class used to serialize a single Lookup search result item
 * 						The Lookup controller returns a List<LookupSearchResult> when sending search result back to Lightning
 * 
 *  Create By       :   
 * 
 *  Created Date    :   
 * 
 *  Revision Log    :   V1.0 - Created  
 * 						V1.1 - Modified By - Mahendra Swarnkar - 02/04/2020 - CR-20200128-13664 - Added "without sharing" access modifier
 * 
 **/
public without sharing class LookupSearchResult {

    Public Id id;
    private String sObjectType;
    private String icon;
    private String title;
    private String subtitle;
    private Boolean isDisbled;
    private String anyAdditionalCommentsInBold;

    public LookupSearchResult(Id id, String sObjectType, String icon, String title, String subtitle, Boolean isDisbled, String anyAdditionalCommentsInBold) {
        this.id = id;
        this.sObjectType = sObjectType;
        this.icon = icon;
        this.title = title;
        this.subtitle = subtitle;
        this.isDisbled = isDisbled;
        this.anyAdditionalCommentsInBold = anyAdditionalCommentsInBold;
    }

    @AuraEnabled
    public Id getId() {
        return id;
    }

    @AuraEnabled
    public String getSObjectType() {
        return sObjectType;
    }

    @AuraEnabled
    public String getIcon() {
        return icon;
    }

    @AuraEnabled
    public String getTitle() {
        return title;
    }

    @AuraEnabled
    public String getSubtitle() {
        return subtitle;
    }

    @AuraEnabled
    public Boolean getisDisbled() {
        return isDisbled;
    }
    @AuraEnabled
    public String getanyAdditionalCommentsInBold() {
        return anyAdditionalCommentsInBold;
    }
    
}