/**
 *	Desription      :	Wrapper class to define attributes/properties associated with "Visualforce TableGrid".
 * 
 *	Created By      :   Mahendra Swarnkar
 * 
 *  Created Date    :   04/30/2016
 * 
 *  Revision Logs   :   V1.0 - Created - (CR-20160323-9712)
 *
 **/
public class DynamicRelatedListTableGridWrapper {
    
    //Properties
    public Id parentRecordId {get; set;}
    
    public String parentObjectFieldAPIName {get; set;}
    public String childObjectAPIName {get; set;}
	public String relatedListName {get; set;}
	public String fielsNameString {get; set;}
    public String requiredFielsNameString {get; set;}
	public String sortByFieldName {get; set;}
	public String relatedListUniqueName {get; set;}
	public String relatedListDisplayMode {get; set;}
	public String filterCriteriaString {get; set;}
	public String hiddenFieldsString {get; set;}
    public String relatedlistImage {get; set;}
	public SObject defaultSObjectInstance {get; set;}
	
    public Integer relatedListPageSize {get; set;}
    
    public Boolean sortByOrderDescending {get; set;}
	public Boolean relatedListCustomizeFields {get; set;}
	public Boolean relatedListCustomizeFilter {get; set;}
	public Boolean relatedListSaveSettings {get; set;}
    public Boolean showRecordType {get; set;}
	
    //Constructor
    public DynamicRelatedListTableGridWrapper() {}
}