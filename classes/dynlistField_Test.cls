/*
Purpose         :   Test Class for "dynlistField" apex class
Created By      :   Abhinav Sharma
Created Date    :   08/13/2021
Current Version :   v1.0
Revision Log    :   V_1.0 Created - Abhinav Sharma - 08/13/2021
Dev Comments	:	options,values,fieldType and lookupData remaning. 
*/
@isTest(seeAllData=false)
private without sharing class dynlistField_Test 
{  
    // this method is to test all the use cases associated with "dynlistField.dynlistField()" DefaultConstructor.
    @isTest(seeAllData=false)
    static void testDynlistFieldDefaultConstructor() 
    {
        //Start test from here
        Test.startTest();
        
        //Use Case #1 testing out the logics/use cases for DefaultConstructor
        //START FROM HERE
        dynlistField dynlistFieldDefaultConstructor = new dynlistField();
        System.assertEquals(dynlistConstants.CHAR_BLANK_STRING, dynlistFieldDefaultConstructor.label);
        System.assertEquals(dynlistConstants.CHAR_BLANK_STRING, dynlistFieldDefaultConstructor.name);
        System.assertEquals(dynlistConstants.CHAR_BLANK_STRING, dynlistFieldDefaultConstructor.type);
        //Use Case #1
        //ENDS HERE
        
        //End test here
        Test.stopTest();
    }
    
    // this method is to test all the use cases associated with "dynlistField.dynlistField(label,name,type)" ParameterizedConstructor.
    @isTest(seeAllData=false)
    static void testDynlistFieldConstructor() 
    {
        //Start test from here
        Test.startTest();
        //Use Case #2 testing out the logics/use cases for ParameterizedConstructor
        //START FROM HERE
        
        String label = 'Account Name';
        String name = dynlistConstants.NAME_FIELD_NAME;
        String type = 'text';
        dynlistField dynlistFieldParameterizedConstructor = new dynlistField(label,name,type);
        System.assertEquals('Account Name', dynlistFieldParameterizedConstructor.label);
        System.assertEquals(dynlistConstants.NAME_FIELD_NAME, dynlistFieldParameterizedConstructor.name);
        System.assertEquals('text', dynlistFieldParameterizedConstructor.type);
        
        //Use Case #2
        //ENDS HERE
        
        //End test here
        Test.stopTest();
    }
    
    // this method is to test all the use cases associated with "dynlistField" class
    @isTest(seeAllData=false)
    static void testDynlist()
    {    
        String objectName = dynlistConstants.OBJECT_NAME_OPPORTUNITY;
        
        //Schema.FieldSetMember[] fieldSetMemberList = new List<Schema.FieldSetMember>();
        Schema.FieldSetMember fs = null;
        
        dynlistField dynlistFields = new dynlistField();
        dynlistFields.cellNumber = 0;
        dynlistFields.rowNumber = 0;
        dynlistFields.recordId = '0015g00000MuQbXAAV';
        dynlistFields.defaultValue = 'null';
        dynlistFields.digits = 3;
        dynlistFields.tooltip = dynlistConstants.CHAR_BLANK_STRING;
        dynlistFields.length = 5;
        dynlistFields.maxLength = 10;
        dynlistFields.max = 10;
        dynlistFields.min = 0;
        dynlistFields.minLength = 0;
        dynlistFields.localName = dynlistConstants.NAME_FIELD_NAME;
        dynlistFields.sourceLabel = dynlistConstants.NAME_FIELD_NAME;
        dynlistFields.selectedLabel = dynlistConstants.NAME_FIELD_NAME;
        dynlistFields.name = dynlistConstants.NAME_FIELD_NAME;
        dynlistFields.fieldName = dynlistConstants.NAME_FIELD_NAME;
        dynlistFields.precision = 7;
        dynlistFields.referenceTargetField = 'AccountId';
        dynlistFields.relationshipName = dynlistConstants.NAME_FIELD_NAME;
        dynlistFields.scale = 2;
        dynlistFields.fieldName = dynlistConstants.NAME_FIELD_NAME;
        dynlistFields.precision = 1;
        dynlistFields.referenceTargetField = dynlistConstants.NAME_FIELD_NAME;
        dynlistFields.relationshipName = 'Parent to  child';
        dynlistFields.scale = 3;
        dynlistFields.type = 'text';
        dynlistFields.isAccessible = true;
        dynlistFields.isAutoNumber = true;
        dynlistFields.isCalculated = true;
        dynlistFields.isImageFormula = false;
        dynlistFields.isCascadeDelete = false;
        dynlistFields.isCaseSensitive = false;
        dynlistFields.isCreateable = true;
        dynlistFields.isCustom = false;
        dynlistFields.isDefaultedOnCreate = true;
        dynlistFields.isDependentPicklist = false;
        dynlistFields.isHidden = false;
        dynlistFields.isExternalID = false;
        dynlistFields.isFilterable = false;
        dynlistFields.isGroupable = false;
        dynlistFields.isHtmlFormatted = false;
        dynlistFields.isIdLookup = false;
        dynlistFields.isNameField = true;
        dynlistFields.isNamePointing = false;
        dynlistFields.isNillable = true;
        dynlistFields.isPermissionable = true;
        dynlistFields.isSortable = false;
        dynlistFields.isUnique = true;
        dynlistFields.isUpdateable = false;
        dynlistFields.required = false;
        dynlistFields.readOnly = false;
        dynlistFields.value = 'test';
        dynlistFields.displayValue = 'Test';
        dynlistFields.error = 'exception';
        dynlistFields.format = 'Standard';
        dynlistFields.styleClass = 'intro';
        dynlistFields.placeholder = 'test';
        dynlistFields.referencedObjectName = dynlistConstants.OBJECT_NAME_ACCOUNT;
        dynlistFields.referencedObjectLabel = 'Account Name';
        dynlistFields.sObjectName = dynlistConstants.OBJECT_NAME_OPPORTUNITY;
        dynlistFields.selected = true;
        dynlistFields.isDropEnabled = true;
        dynlistFields.target = 'test';
        dynlistFields.editMode = true;
        dynlistFields.id = '0015g00000MuQbgAAF';
        dynlistFields.accessKey = 'Id';
        dynlistFields.dir = 'test';
        dynlistFields.draggable = true;
        dynlistFields.linkify = true;
        dynlistFields.spellcheck = true;
        dynlistFields.style = 'Inline';
        dynlistFields.tabindex = 2;
        dynlistFields.title = 'Related List';
        dynlistFields.headerLabel = 'Opportunities';
        dynlistFields.headerTitle = 'All Opportunitiies';
        dynlistFields.ariaControls = 'panel';
        dynlistFields.ariaDescribedBy = 'descriptionpanel';
        dynlistFields.ariaLabel = 'Close';
        dynlistFields.ariaLabelledBy = 'dialogheader';
        dynlistFields.autocomplete = false;
        dynlistFields.checked = false;
        dynlistFields.timeStyle = 'short';
        dynlistFields.dateStyle = 'short';
        dynlistFields.disabled = false;
        dynlistFields.fieldLevelHelp = 'field Level Help';
        dynlistFields.files = 'SpreadSheet';
        dynlistFields.formatFractionDigits = 1;
        dynlistFields.formatter = 'test';
        dynlistFields.isLoading = true;
        dynlistFields.messageToggleActive = 'Active';
        dynlistFields.messageToggleInactive = 'Inactive';
        dynlistFields.messageWhenBadInput = 'BadInput';
        dynlistFields.messageWhenPatternMismatch = 'PatternMismatch';
        dynlistFields.messageWhenRangeOverflow = 'Underflow';
        dynlistFields.messageWhenStepMismatch = 'StepMismatch';
        dynlistFields.messageWhenTooLong = 'TooLong';
        dynlistFields.messageWhenTooShort = 'TooShort';
        dynlistFields.messageWhenTypeMismatch = 'TypeMismatch';
        dynlistFields.messageWhenValueMissing = 'ValueMismatch';
        dynlistFields.multiple = 'test';
        dynlistFields.pattern = 'test';
        dynlistFields.step = 'Step';
        dynlistFields.timezone = 'IST';
        dynlistFields.validity = 'test';
        dynlistFields.variant = 'base';
        dynlistFields.disableLinkify = true;
        dynlistFields.customButtons = 'Edit';
        dynlistFields.disabledCategories = true;
        dynlistFields.formats = 'test';
        dynlistFields.hidefocus = false;
        dynlistFields.labelVisible = true;
        dynlistFields.shareWithEntityId = false;
        dynlistFields.valid = false;
        dynlistFields.uniqueKey = '0015g00000MuQbgAAF';
        dynlistFields.isRecordTypeField = true;
        dynlistFields.hideIcon = false;
        dynlistFields.minimumSignificantDigits = 2;
        dynlistFields.minimumIntegerDigits = 2;
        dynlistFields.minimumFractionDigits= 2;
        dynlistFields.maximumSignificantDigits = 3;
        dynlistFields.maximumFractionDigits = 3;
        dynlistFields.formatStyle = 'MEDIUM';
        dynlistFields.currencyDisplayAs = '$';
        dynlistFields.currencyCode = 'USD';
        dynlistFields.fieldType = Schema.DisplayType.MultiPicklist;
        dynlistFields.extraResultFields = new List<String>{'test'};
            dynlistFields.fsMember = fs;
        dynlistFields.accept = 'yes';
        dynlistFields.charset = '+-=!';
        dynlistFields.href = 'https://www.salesforce.com/in/?ir=1';
        dynlistFields.size = 'Large';
        dynlistFields.shape = 'Rectangle';
        dynlistFields.cssStyle = 'testcssStyle';
        dynlistFields.rev= 'section';
        dynlistFields.rel = 'alternate';
        dynlistFields.hreflang ='en-us';
        dynlistFields.messageWhenRangeUnderflow = 'RangeUnderFlow';
        dynlistFields.lang = 'langTest';
        dynlistFields.dateAriaControls = 'dateAriaControlsTest';
        dynlistFields.dateAriaDescribedBy = 'dateAriaDescribedByTest';
        dynlistFields.dateAriaLabel = 'dateAriaLabelTest';
        dynlistFields.dateAriaLabelledBy = 'dateAriaLabelledByTest';
        dynlistFields.timeAriaControls = 'timeAriaControlsTest';
        dynlistFields.timeAriaDescribedBy = 'timeAriaDescribedByTest';
        dynlistFields.timeAriaLabelledBy = 'timeAriaLabelledByTest';
        dynlistFields.values = new List<String>{'test'};
            dynlistFields.lookupData = new dynlistLookup();
        dynlistFields.options = new List<dynlistOption>();
        dynlistFields.hyperlinkLabel = 'Google';
        dynlistFields.hyperlinkTitle = 'Google';
        dynlistFields.hyperlinkURL = 'https://www.google.com/';
        dynlistFields.referenceFieldValue = 'AccountId';
        dynlistFields.operation = 'SOQL Test';
        dynlistFields.valueField = 'Id';
        dynlistFields.referencedObjectPluralLabel = 'Tests';
        
        //assert
        System.assert(dynlistFields!=null);
    }
}