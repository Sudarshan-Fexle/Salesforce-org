/*
Purpose         :   Field (Dynamic Related List)
Created By      :   Abhinav Sharma
Created Date    :   07/24/2021
Current Version :   v1.0
Revision Log    :   V_1.0 Created - Abhinav Sharma - 07/24/2021
*/
@SuppressWarnings('PMD.ExcessivePublicCount')
public with sharing class dynlistField 
{
    //Cell Number value
    @AuraEnabled
    public Integer cellNumber { get; set; }
    
    @AuraEnabled
    public Integer rowNumber { get; set; }
    
    @AuraEnabled
    public String recordId { get; set; }
    
    //default value for this field
    @AuraEnabled
    public String defaultValue { get; set; }
    
    //maximum number of digits specified for the field
    @AuraEnabled
    public Integer digits { get; set; }
    
    //content of the field-level help.
    @AuraEnabled
    public String tooltip { get; set; }
    
    //label for the field (fieldLabel)
    @AuraEnabled
    public String label { get; set; }
    
    //length for the field
    @AuraEnabled
    public Integer length { get; set; }
    
    //max length for the field
    @AuraEnabled
    public Integer maxLength { get; set; }
    
    @AuraEnabled
    public Decimal max { get; set; }
    
    @AuraEnabled
    public Decimal min { get; set; }
    
    @AuraEnabled
    public Integer minLength { get; set; }
    
    //name of the field, similar to the name attribute.
    //However, if the field is part of the current namespace, the namespace portion of the name is omitted.
    @AuraEnabled
    public String localName { get; set; }
    
    //list of picklist options (picklistValues)
    @AuraEnabled
    public List<dynlistOption> options { get; set; }
    
    @AuraEnabled
    public List<String> values { get; set; }
    
    @AuraEnabled
    public String sourceLabel { get; set; }
    
    @AuraEnabled
    public String selectedLabel { get; set; }
    
    //Lookup up/Reference field data
    @AuraEnabled
    public dynlistLookup lookupData { get; set; }
    
    //api name for the field (fieldAPIName)
    @AuraEnabled
    public String name { get; set; }
    
    @AuraEnabled
    public String fieldName { get; set; }
    
    //For fields of type Double, returns the maximum number of digits that can be stored,
    //including all numbers to the left and to the right of the decimal point (but excluding the decimal point character).
    @AuraEnabled
    public Integer precision { get; set; }
    
    //name of the custom field on the parent standard or custom object whose values are matched against the values of the
    //child external object's indirect lookup relationship field. The match is done to determine which records are related
    //to each other.
    @AuraEnabled
    public String referenceTargetField { get; set; }
    
    //name of the relationship.
    @AuraEnabled
    public String relationshipName { get; set; }
    
    //For fields of type Double, returns the number of digits to the right of the decimal point.
    //Any extra digits to the right of the decimal point are truncated.
    @AuraEnabled
    public Integer scale { get; set; }
    
    //type of field. (fieldDataType)
    @AuraEnabled
    public String type { get; set; }
    @AuraEnabled
    public Schema.DisplayType fieldType { get; set; }
    
    //Returns true if the current user can see this field, false otherwise.
    @AuraEnabled
    public Boolean isAccessible { get; set; }
    
    //Returns true if the field is an Auto Number field, false otherwise.
    @AuraEnabled
    public Boolean isAutoNumber { get; set; }
    
    //Returns true if the field is a custom formula field, false otherwise.
    //Note that custom formula fields are always read-only.
    @AuraEnabled
    public Boolean isCalculated { get; set; }
    
    //Returns true if the field is a custom formula field of image type, false otherwise.
    @AuraEnabled
    public Boolean isImageFormula { get; set; }
    
    //Returns true if the child object is deleted when the parent object is deleted, false otherwise.
    @AuraEnabled
    public Boolean isCascadeDelete { get; set; }
    
    //Returns true if the field is case sensitive, false otherwise.
    @AuraEnabled
    public Boolean isCaseSensitive { get; set; }
    
    //Returns true if the field can be created by the current user, false otherwise.
    @AuraEnabled
    public Boolean isCreateable { get; set; }
    
    //Returns true if the field is a custom field, false if it is a standard field, such as Name.
    @AuraEnabled
    public Boolean isCustom { get; set; }
    
    //Returns true if the field receives a default value when created, false otherwise.
    @AuraEnabled
    public Boolean isDefaultedOnCreate { get; set; }
    
    //Returns true if the picklist is a dependent picklist, false otherwise.
    @AuraEnabled
    public Boolean isDependentPicklist { get; set; }
    
    //if field is a hidden field
    @AuraEnabled
    public Boolean isHidden { get; set; }
    
    //Returns true if the field is used as an external ID, false otherwise.
    @AuraEnabled
    public Boolean isExternalID { get; set; }
    
    //Returns true if the field can be used as part of the filter criteria of a WHERE statement, false otherwise.
    @AuraEnabled
    public Boolean isFilterable { get; set; }
    
    //Returns true if the field can be included in the GROUP BY clause of a SOQL query, false otherwise.
    @AuraEnabled
    public Boolean isGroupable { get; set; }
    
    //Returns true if the field has been formatted for HTML and should be encoded for display in HTML, false otherwise.
    @AuraEnabled
    public Boolean isHtmlFormatted { get; set; }
    
    //Returns true if the field can be used to specify a record in an upsert method, false otherwise.
    @AuraEnabled
    public Boolean isIdLookup { get; set; }
    
    //Returns true if the field is a name field, false otherwise.
    @AuraEnabled
    public Boolean isNameField { get; set; }
    
    //Returns true if the field can have multiple types of objects as parents.
    @AuraEnabled
    public Boolean isNamePointing { get; set; }
    
    //Returns true if the field is nillable, false otherwise. A nillable field can have empty content.
    //A non-nillable field must have a value for the object to be created or saved.
    @AuraEnabled
    public Boolean isNillable { get; set; }
    
    //Returns true if field permissions can be specified for the field, false otherwise.
    @AuraEnabled
    public Boolean isPermissionable { get; set; }
    
    //Returns true if a query can sort on the field, false otherwise
    @AuraEnabled
    public Boolean isSortable { get; set; }
    
    @AuraEnabled
    public Boolean displaySortingIcon { get; set; }
    
    @AuraEnabled
    public Boolean displayArrowUpIcon { get; set; }
    
    @AuraEnabled
    public Boolean displayArrowDownIcon { get; set; }
    
    //Returns true if the value for the field must be unique, false otherwise
    @AuraEnabled
    public Boolean isUnique { get; set; }
    
    //Returns true if the field can be edited by the current user, or child records in a master-detail relationship field
    //on a custom object can be reparented to different parent records; false otherwise.
    @AuraEnabled
    public Boolean isUpdateable { get; set; }
    
    //Set as true if field is a required one (isRequired)
    @AuraEnabled
    public Boolean required { get; set; }
    
    //Set as true if field is a read-only type (isReadOnly)
    @AuraEnabled
    public Boolean readOnly { get; set; }
    
    //value for the field (fieldValue)
    @AuraEnabled
    public String value { get; set; }
    
    //display value for lookup/reference type of fields
    @AuraEnabled
    public String displayValue { get; set; }
    
    //Error Message for the field
    @AuraEnabled
    public String error { get; set; }
    
    //Format details for the field
    @AuraEnabled
    public String format { get; set; }
    
    //Style class for the field
    @AuraEnabled
    public String styleClass { get; set; }
    
    //Placeholer value for the field
    @AuraEnabled
    public String placeholder { get; set; }
    
    //Refernce Object API Name for the field (refrenceFieldObjectAPIName)
    @AuraEnabled
    public String referencedObjectName { get; set; }
    
    //Refernce Object Label for the field
    @AuraEnabled
    public String referencedObjectLabel { get; set; }
    
    @AuraEnabled
    public String referencedObjectPluralLabel { get; set; }
    
    //List of fieldnames, used in a lookup field to show more info about a record.
    @AuraEnabled
    public List<String> extraResultFields { get; set; }
    
    //object API Name to which this field is associated with
    @AuraEnabled
    public String sObjectName { get; set; }
    
    //Field Set Member details for this field
    public Schema.FieldSetMember fsMember { get; set; }
    
    //DO selected checkbox (booleanValue) got selected for the corresponding row
    @AuraEnabled
    public boolean selected { get; set; }
    
    //Other useful properties
    @AuraEnabled
    public Boolean isDropEnabled { get; set; }
    @AuraEnabled
    public String target { get; set; }
    @AuraEnabled
    public Boolean editMode { get; set; }
    @AuraEnabled
    public String id { get; set; }
    @AuraEnabled
    public String accessKey { get; set; }
    @AuraEnabled
    public String dir { get; set; }
    @AuraEnabled
    public Boolean draggable { get; set; }
    @AuraEnabled
    public String lang { get; set; }
    @AuraEnabled
    public Boolean linkify { get; set; }
    @AuraEnabled
    public Boolean spellcheck { get; set; }
    @AuraEnabled
    public String style { get; set; }
    @AuraEnabled
    public Integer tabindex { get; set; }
    @AuraEnabled
    public String title { get; set; }
    @AuraEnabled
    public String headerLabel { get; set; }
    @AuraEnabled
    public String headerTitle { get; set; }
    @AuraEnabled
    public String accept { get; set; }
    @AuraEnabled
    public String ariaControls { get; set; }
    @AuraEnabled
    public String ariaDescribedBy { get; set; }
    @AuraEnabled
    public String ariaLabel { get; set; }
    @AuraEnabled
    public String ariaLabelledBy { get; set; }
    @AuraEnabled
    public Boolean autocomplete { get; set; }
    @AuraEnabled
    public Boolean checked { get; set; }
    @AuraEnabled
    public String dateAriaControls { get; set; }
    @AuraEnabled
    public String dateAriaDescribedBy { get; set; }
    @AuraEnabled
    public String dateAriaLabel { get; set; }
    @AuraEnabled
    public String dateAriaLabelledBy { get; set; }
    @AuraEnabled
    public String timeAriaControls { get; set; }
    @AuraEnabled
    public String timeAriaDescribedBy { get; set; }
    @AuraEnabled
    public String timeAriaLabelledBy { get; set; }
    @AuraEnabled
    public String timeStyle { get; set; }
    @AuraEnabled
    public String dateStyle { get; set; }
    @AuraEnabled
    public Boolean disabled { get; set; }
    @AuraEnabled
    public String fieldLevelHelp { get; set; }
    @AuraEnabled
    public String files { get; set; }
    @AuraEnabled
    public Integer formatFractionDigits { get; set; }
    @AuraEnabled
    public String formatter { get; set; }
    @AuraEnabled
    public Boolean isLoading { get; set; }
    @AuraEnabled
    public String messageToggleActive { get; set; }
    @AuraEnabled
    public String messageToggleInactive { get; set; }
    @AuraEnabled
    public String messageWhenBadInput { get; set; }
    @AuraEnabled
    public String messageWhenPatternMismatch { get; set; }
    @AuraEnabled
    public String messageWhenRangeOverflow { get; set; }
    @AuraEnabled
    public String messageWhenRangeUnderflow { get; set; }
    @AuraEnabled
    public String messageWhenStepMismatch { get; set; }
    @AuraEnabled
    public String messageWhenTooLong { get; set; }
    @AuraEnabled
    public String messageWhenTooShort { get; set; }
    @AuraEnabled
    public String messageWhenTypeMismatch { get; set; }
    @AuraEnabled
    public String messageWhenValueMissing { get; set; }
    @AuraEnabled
    public String multiple { get; set; }
    @AuraEnabled
    public String pattern { get; set; }
    @AuraEnabled
    public String step { get; set; }
    @AuraEnabled
    public String timezone { get; set; }
    @AuraEnabled
    public String validity { get; set; }
    @AuraEnabled
    public String variant { get; set; }
    @AuraEnabled
    public Boolean disableLinkify { get; set; }
    @AuraEnabled
    public String customButtons { get; set; }
    @AuraEnabled
    public Boolean disabledCategories { get; set; }
    @AuraEnabled
    public String formats { get; set; }
    @AuraEnabled
    public Boolean hidefocus { get; set; }
    @AuraEnabled
    public Boolean labelVisible { get; set; }
    @AuraEnabled
    public Boolean shareWithEntityId { get; set; }
    @AuraEnabled
    public Boolean valid { get; set; }
    @AuraEnabled
    public String charset { get; set; }
    @AuraEnabled
    public String href { get; set; }
    @AuraEnabled
    public String hreflang { get; set; }
    @AuraEnabled
    public String rel { get; set; }
    @AuraEnabled
    public String rev { get; set; }
    @AuraEnabled
    public String shape { get; set; }
    @AuraEnabled
    public String size { get; set; }
    @AuraEnabled
    public String cssStyle { get; set; }
    @AuraEnabled
    public String currencyCode { get; set; }
    @AuraEnabled
    public String currencyDisplayAs { get; set; }
    @AuraEnabled
    public String formatStyle { get; set; }
    @AuraEnabled
    public Integer maximumFractionDigits { get; set; }
    @AuraEnabled
    public Integer maximumSignificantDigits { get; set; }
    @AuraEnabled
    public Integer minimumFractionDigits { get; set; }
    @AuraEnabled
    public Integer minimumIntegerDigits { get; set; }
    @AuraEnabled
    public Integer minimumSignificantDigits { get; set; }
    @AuraEnabled
    public Boolean hideIcon { get; set; }
    @AuraEnabled
    public Boolean isRecordTypeField { get; set; }
    @AuraEnabled
    public String uniqueKey { get; set; }
    
    @AuraEnabled
    public String hyperlinkLabel { get; set; }
    
    @AuraEnabled
    public String hyperlinkTitle { get; set; }
    
    @AuraEnabled
    public String hyperlinkURL { get; set; }
    
    @AuraEnabled
    public String referenceFieldValue { get; set; }
    
    @AuraEnabled
    public String operation { get; set; }
    
    @AuraEnabled
    public String valueField { get; set; }
    
    @AuraEnabled
    public Boolean optionalFilter { get; set; }
    
    @AuraEnabled
    public String fieldCellStyleClass { get; set; }
    
    @AuraEnabled 
    public Boolean viewable { get; set; }
    
    @AuraEnabled
    public Boolean fieldHistoryForReferenceField { get; set; }
    
    public dynlistField() 
    {
        label = dynlistConstants.CHAR_BLANK_STRING;
        name = dynlistConstants.CHAR_BLANK_STRING;
        type = dynlistConstants.CHAR_BLANK_STRING;
        editMode = false;
        variant = dynlistConstants.VARIENT_LABEL_HIDDEN;
        target = dynlistConstants.TARGET_BLANK;
        sourceLabel = dynlistConstants.TEXT_AVAILABLE;
        selectedLabel = dynlistConstants.TEXT_SELECTED;
        isNameField = false;
        isRecordTypeField = false;
        uniqueKey = dynlistConstants.CHAR_BLANK_STRING;
        readOnly = false;
        isSortable = false;
        displaySortingIcon = false;
        displayArrowUpIcon = false;
        displayArrowDownIcon = false;
        optionalFilter = false;
    }
    
    public dynlistField(String label, String name, String type) 
    {
        this.label = label;
        this.name = name;
        this.type = type;
        this.required = false;
        this.readOnly = false;
        editMode = false;
        variant = dynlistConstants.VARIENT_LABEL_HIDDEN;
        target = dynlistConstants.TARGET_BLANK;
        sourceLabel = dynlistConstants.TEXT_AVAILABLE;
        selectedLabel = dynlistConstants.TEXT_SELECTED;
        isNameField = false;
        isRecordTypeField = false;
        uniqueKey = dynlistConstants.CHAR_BLANK_STRING;
        isSortable = false;
        displaySortingIcon = false;
        displayArrowUpIcon = false;
        displayArrowDownIcon = false;
        optionalFilter = false;
    }
    
    public dynlistField(String name, String label, String tooltip, String type, Boolean required, Boolean viewable, 
                        Boolean readOnly, String value, String displayValue) 
    {
        this.name = name;
        this.fieldName = name;
        this.label = label;
        this.tooltip = tooltip;
        this.type = type;
        this.required = (name == dynlistConstants.NAME_FIELD_NAME)? true: required;
        this.viewable = viewable;
        this.readOnly = readOnly;
        this.value = value;
        this.displayValue = displayValue;
    }
}